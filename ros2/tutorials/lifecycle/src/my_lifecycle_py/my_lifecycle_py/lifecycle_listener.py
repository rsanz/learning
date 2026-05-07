# Copyright 2024 Developer
# SPDX-License-Identifier: Apache-2.0
"""Lifecycle listener: receives messages only while Active."""

import rclpy
from rclpy.lifecycle import LifecycleNode
from rclpy.lifecycle import TransitionCallbackReturn
from rclpy.lifecycle import State
from std_msgs.msg import String


class LifecycleListener(LifecycleNode):
    """A lifecycle node that subscribes to the chatter topic."""

    def __init__(self, node_name: str, **kwargs) -> None:
        super().__init__(node_name, **kwargs)
        self._sub = None
        self.get_logger().info('LifecycleListener created (Unconfigured)')

    def on_configure(self, state: State) -> TransitionCallbackReturn:
        self.get_logger().info('Configuring listener...')
        # Subscription is created here; messages are queued but the
        # callback fires only when the node is Active.
        self._sub = self.create_subscription(
            String,
            'lifecycle_chatter',
            self._chatter_callback,
            10,
        )
        return TransitionCallbackReturn.SUCCESS

    def on_activate(self, state: State) -> TransitionCallbackReturn:
        self.get_logger().info('Activating listener...')
        return super().on_activate(state)

    def on_deactivate(self, state: State) -> TransitionCallbackReturn:
        self.get_logger().info('Deactivating listener...')
        return super().on_deactivate(state)

    def on_cleanup(self, state: State) -> TransitionCallbackReturn:
        self.get_logger().info('Cleaning up listener...')
        if self._sub:
            self.destroy_subscription(self._sub)
            self._sub = None
        return TransitionCallbackReturn.SUCCESS

    def on_shutdown(self, state: State) -> TransitionCallbackReturn:
        self.get_logger().info('Shutting down listener...')
        if self._sub:
            self.destroy_subscription(self._sub)
            self._sub = None
        return TransitionCallbackReturn.SUCCESS

    def _chatter_callback(self, msg: String) -> None:
        self.get_logger().info(f'Received: "{msg.data}"')


def main(args=None):
    rclpy.init(args=args)
    node = LifecycleListener('lifecycle_listener')
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
