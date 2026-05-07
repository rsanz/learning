# Copyright 2024 Developer
# SPDX-License-Identifier: Apache-2.0
from launch import LaunchDescription
from launch_ros.actions import LifecycleNode
from launch.actions import EmitEvent, RegisterEventHandler
from launch_ros.events.lifecycle import ChangeState
from launch_ros.event_handlers import OnStateTransition
from lifecycle_msgs.msg import Transition


def generate_launch_description():
    # Declare the talker as a LifecycleNode action
    talker = LifecycleNode(
        package='my_lifecycle_py',
        executable='lifecycle_talker',
        name='lifecycle_talker',
        namespace='',
        output='screen',
    )

    # Declare the listener as a LifecycleNode action
    listener = LifecycleNode(
        package='my_lifecycle_py',
        executable='lifecycle_listener',
        name='lifecycle_listener',
        namespace='',
        output='screen',
    )

    # Automatically configure the talker when it reaches 'unconfigured'
    configure_talker = EmitEvent(
        event=ChangeState(
            lifecycle_node_matcher=lambda _: True,  # match all
            transition_id=Transition.TRANSITION_CONFIGURE,
        )
    )

    # When talker reaches 'inactive', activate it
    activate_on_inactive = RegisterEventHandler(
        OnStateTransition(
            target_lifecycle_node=talker,
            goal_state='inactive',
            entities=[
                EmitEvent(event=ChangeState(
                    lifecycle_node_matcher=lambda node: node == talker,
                    transition_id=Transition.TRANSITION_ACTIVATE,
                ))
            ],
        )
    )

    return LaunchDescription([
        talker,
        listener,
        configure_talker,
        activate_on_inactive,
    ])
