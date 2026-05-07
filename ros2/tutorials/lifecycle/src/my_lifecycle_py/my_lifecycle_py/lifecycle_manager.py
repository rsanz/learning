# Copyright 2024 Developer
# SPDX-License-Identifier: Apache-2.0
"""Simple lifecycle manager that drives another node through its states."""

import time
import rclpy
from rclpy.node import Node
from lifecycle_msgs.srv import ChangeState, GetState
from lifecycle_msgs.msg import Transition

TRANSITIONS = {
    'configure':  Transition.TRANSITION_CONFIGURE,
    'activate':   Transition.TRANSITION_ACTIVATE,
    'deactivate': Transition.TRANSITION_DEACTIVATE,
    'cleanup':    Transition.TRANSITION_CLEANUP,
    'shutdown':   Transition.TRANSITION_UNCONFIGURED_SHUTDOWN,
}


class LifecycleManager(Node):
    """Drives a target lifecycle node through a predefined sequence."""

    def __init__(self, target_node: str = 'lifecycle_talker') -> None:
        super().__init__('lifecycle_manager')
        self._target = target_node
        # Create service clients
        self._change_state = self.create_client(
            ChangeState, f'/{target_node}/change_state')
        self._get_state = self.create_client(
            GetState, f'/{target_node}/get_state')
        self.get_logger().info(
            f'LifecycleManager ready to manage: {target_node}')

    def get_state(self) -> str | None:
        """Return the current primary state label of the managed node."""
        if not self._get_state.wait_for_service(timeout_sec=5.0):
            self.get_logger().error('get_state service not available')
            return None
        future = self._get_state.call_async(GetState.Request())
        rclpy.spin_until_future_complete(self, future, timeout_sec=5.0)
        if future.result():
            return future.result().current_state.label
        return None

    def change_state(self, transition_name: str) -> bool:
        """Trigger a named transition. Returns True on success."""
        if transition_name not in TRANSITIONS:
            self.get_logger().error(f'Unknown transition: {transition_name}')
            return False
        if not self._change_state.wait_for_service(timeout_sec=5.0):
            self.get_logger().error('change_state service not available')
            return False
        req = ChangeState.Request()
        req.transition.id = TRANSITIONS[transition_name]
        req.transition.label = transition_name
        future = self._change_state.call_async(req)
        rclpy.spin_until_future_complete(self, future, timeout_sec=10.0)
        if future.result() and future.result().success:
            state = self.get_state()
            self.get_logger().info(
                f'Transition "{transition_name}" succeeded. New state: {state}')
            return True
        else:
            self.get_logger().error(f'Transition "{transition_name}" FAILED.')
            return False

    def run_demo_sequence(self) -> None:
        """Run configure -> activate -> (wait) -> deactivate -> cleanup."""
        steps = [
            ('configure', 2.0),
            ('activate',  5.0),
            ('deactivate', 1.0),
            ('cleanup',   1.0),
        ]
        for transition, wait in steps:
            if not self.change_state(transition):
                self.get_logger().error(f'Aborting sequence at: {transition}')
                return
            time.sleep(wait)
        self.get_logger().info('Demo sequence complete.')


def main(args=None):
    rclpy.init(args=args)
    manager = LifecycleManager(target_node='lifecycle_talker')
    # Wait briefly for the talker to come up
    time.sleep(2.0)
    manager.run_demo_sequence()
    manager.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
