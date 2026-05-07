# Copyright 2024 Developer
# SPDX-License-Identifier: Apache-2.0
"""Lifecycle talker: publishes only while Active."""

import rclpy
from rclpy.lifecycle import LifecycleNode
from rclpy.lifecycle import TransitionCallbackReturn
from rclpy.lifecycle import State
from rclpy.timer import Timer
from std_msgs.msg import String


class LifecycleTalker(LifecycleNode):
    """A lifecycle node that publishes 'Hello' messages."""

    def __init__(self, node_name: str, **kwargs) -> None:
        """Initialise without creating ROS entities yet."""
        super().__init__(node_name, **kwargs)
        self._pub = None
        self._timer: Timer | None = None
        self._count: int = 0
        self.get_logger().info('LifecycleTalker created (Unconfigured)')

    # -- Transition callbacks --------------------------------------------------

    def on_configure(self, state: State) -> TransitionCallbackReturn:
        """Allocate resources: create publisher.

        Called by the 'configure' transition.
        Returning SUCCESS moves the node to Inactive.
        """
        self.get_logger().info(f'Configuring from state: {state.label}')
        # Create publisher -- it exists but is NOT active yet
        self._pub = self.create_lifecycle_publisher(String, 'lifecycle_chatter', 10)
        self._count = 0
        self.get_logger().info('Publisher created.')
        return TransitionCallbackReturn.SUCCESS

    def on_activate(self, state: State) -> TransitionCallbackReturn:
        """Start publishing: create a timer that fires every second.

        Called by the 'activate' transition.
        Returning SUCCESS moves the node to Active.
        """
        self.get_logger().info(f'Activating from state: {state.label}')
        # Timer is created here so it fires only in Active state
        self._timer = self.create_timer(1.0, self._timer_callback)
        # IMPORTANT: call super().on_activate() to activate the publisher
        return super().on_activate(state)

    def on_deactivate(self, state: State) -> TransitionCallbackReturn:
        """Pause publishing: destroy the timer.

        Called by the 'deactivate' transition.
        Returning SUCCESS moves the node to Inactive.
        """
        self.get_logger().info(f'Deactivating from state: {state.label}')
        if self._timer:
            self._timer.destroy()
            self._timer = None
        # Call super to deactivate the publisher
        return super().on_deactivate(state)

    def on_cleanup(self, state: State) -> TransitionCallbackReturn:
        """Release all resources.

        Called by the 'cleanup' transition.
        Returning SUCCESS moves the node back to Unconfigured.
        """
        self.get_logger().info(f'Cleaning up from state: {state.label}')
        if self._timer:
            self._timer.destroy()
            self._timer = None
        if self._pub:
            self.destroy_publisher(self._pub)
            self._pub = None
        self._count = 0
        self.get_logger().info('Resources released.')
        return TransitionCallbackReturn.SUCCESS

    def on_shutdown(self, state: State) -> TransitionCallbackReturn:
        """Graceful shutdown -- called from any primary state."""
        self.get_logger().info(f'Shutting down from state: {state.label}')
        if self._timer:
            self._timer.destroy()
            self._timer = None
        if self._pub:
            self.destroy_publisher(self._pub)
            self._pub = None
        return TransitionCallbackReturn.SUCCESS

    def on_error(self, state: State) -> TransitionCallbackReturn:
        """Error recovery handler."""
        self.get_logger().error(
            f'Error in state: {state.label}. Attempting recovery.')
        # Attempt to clean up; returning FAILURE sends to Finalized
        return TransitionCallbackReturn.SUCCESS

    # -- Internal --------------------------------------------------------------

    def _timer_callback(self) -> None:
        """Publish a message. Only called while Active."""
        if self._pub and self._pub.is_activated:
            msg = String()
            msg.data = f'Hello, lifecycle world! count={self._count}'
            self._pub.publish(msg)
            self.get_logger().info(f'Published: "{msg.data}"')
            self._count += 1


def main(args=None):
    rclpy.init(args=args)
    node = LifecycleTalker('lifecycle_talker')
    executor = rclpy.executors.SingleThreadedExecutor()
    executor.add_node(node)
    try:
        executor.spin()
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
