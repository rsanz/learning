# ROS 2 Lifecycle Nodes — Complete Tutorial

> Covers: Humble / Iron / Jazzy distributions

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [The Lifecycle State Machine](#2-the-lifecycle-state-machine)
3. [Lifecycle Nodes in Python](#3-lifecycle-nodes-in-python)
4. [Lifecycle Nodes in C++](#4-lifecycle-nodes-in-c)
5. [Building the Packages](#5-building-the-packages)
6. [Running and Testing](#6-running-and-testing)
7. [Advanced Topics](#7-advanced-topics)
8. [Best Practices](#8-best-practices)
9. [Quick Reference Card](#9-quick-reference-card)
10. [Appendix A — Installing ROS 2 on Ubuntu](#appendix-a--installing-ros-2-on-ubuntu)
11. [Appendix B — Troubleshooting](#appendix-b--troubleshooting)

---

## 1. Introduction

### 1.1 What is a Lifecycle Node?

In standard ROS 2, a node starts executing immediately upon creation, and the only way to stop it is to kill the process. This makes it difficult to coordinate the startup and shutdown of complex multi-node systems.

**Lifecycle Nodes** (also called *managed nodes*) address this by giving each node a well-defined state machine. A lifecycle node does not begin meaningful work until it is explicitly told to do so by an external manager or by user commands. The operator can also pause, reconfigure, and cleanly shut down the node at run-time without restarting the whole system.

Lifecycle nodes are standardised in [REP 2006](https://ros.org/reps/rep-2006.html) and implemented in the `rclcpp_lifecycle` (C++) and `rclpy` (Python, via `LifecycleNode`) packages.

### 1.2 Why Use Lifecycle Nodes?

- **Deterministic start-up**: ensure all dependencies are ready before a node becomes active.
- **Safe configuration**: allocate hardware resources only when needed; release them cleanly on shutdown.
- **Fault isolation**: deactivate a misbehaving node without restarting the entire robot pipeline.
- **System orchestration**: a lifecycle manager (e.g. from `nav2_lifecycle_manager`) can supervise multiple nodes as a unit.
- **Better testing**: each state transition can be unit-tested independently.

### 1.3 Scope of this Tutorial

1. The lifecycle state machine in detail.
2. Writing lifecycle nodes in Python and C++.
3. Building with colcon and CMake/setuptools.
4. Triggering transitions from the command line and programmatically.
5. Monitoring state via services and topics.
6. Implementing a simple lifecycle manager.
7. Best practices and common pitfalls.
8. Appendix: installing ROS 2 and setting up a workspace on Ubuntu.

---

## 2. The Lifecycle State Machine

### 2.1 Primary States

A lifecycle node always resides in one of the following **primary states**:

| State | Description |
|---|---|
| `Unconfigured` | Node has been created but not yet configured. No publishers, subscribers, or timers are active. |
| `Inactive` | Node has been configured (resources allocated) but is not processing data. |
| `Active` | Node is fully operational and processing data. |
| `Finalized` | Node has been shut down and cannot be restarted. |

### 2.2 Transition States

Between primary states the node briefly enters a *transition state* while executing callback logic. If the callback succeeds the node moves to the target primary state; if it fails the node returns to an error state instead.

| Transition | From | To (success) | To (failure) |
|---|---|---|---|
| `configure` | Unconfigured | Inactive | Unconfigured |
| `activate` | Inactive | Active | Inactive |
| `deactivate` | Active | Inactive | Active |
| `cleanup` | Inactive | Unconfigured | Inactive |
| `shutdown` | Any primary | Finalized | Finalized |
| `error` | Any | Unconfigured | Finalized |

### 2.3 Transition Callbacks

Each transition maps to a callback that you override in your node class:

| Callback | Triggered by |
|---|---|
| `on_configure` | `configure` transition |
| `on_activate` | `activate` transition |
| `on_deactivate` | `deactivate` transition |
| `on_cleanup` | `cleanup` transition |
| `on_shutdown` | `shutdown` transition |
| `on_error` | Error recovery |

All callbacks must return a transition result:
- **Python**: `return TransitionCallbackReturn.SUCCESS`, `.FAILURE`, or `.ERROR`
- **C++**: `return CallbackReturn::SUCCESS`, `CallbackReturn::FAILURE`, or `CallbackReturn::ERROR`

### 2.4 Full State-Machine Diagram

```
          configure           activate
            ───►                ───►
Unconfigured      Inactive           Active
            ◄───                ◄───
           cleanup            deactivate

Unconfigured ──── shutdown ────►
  Inactive   ──── shutdown ────► Finalized
    Active   ──── shutdown ────►
```

---

## 3. Lifecycle Nodes in Python

### 3.1 Package Structure

```
my_lifecycle_py/
  my_lifecycle_py/
    __init__.py
    lifecycle_talker.py    # publisher lifecycle node
    lifecycle_listener.py  # subscriber lifecycle node
    lifecycle_manager.py   # simple manager node
  resource/
    my_lifecycle_py
  package.xml
  setup.cfg
  setup.py
```

### 3.2 `package.xml`

```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd"
            schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>my_lifecycle_py</name>
  <version>0.1.0</version>
  <description>ROS 2 lifecycle node examples in Python</description>
  <maintainer email="dev@example.com">Developer</maintainer>
  <license>Apache-2.0</license>

  <exec_depend>rclpy</exec_depend>
  <exec_depend>lifecycle_msgs</exec_depend>
  <exec_depend>std_msgs</exec_depend>

  <test_depend>ament_copyright</test_depend>
  <test_depend>ament_flake8</test_depend>
  <test_depend>ament_pep257</test_depend>

  <export>
    <build_type>ament_python</build_type>
  </export>
</package>
```

### 3.3 `setup.py`

```python
from setuptools import setup

package_name = 'my_lifecycle_py'

setup(
    name=package_name,
    version='0.1.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages',
         ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Developer',
    maintainer_email='dev@example.com',
    description='ROS 2 lifecycle node examples in Python',
    license='Apache-2.0',
    entry_points={
        'console_scripts': [
            'lifecycle_talker  = my_lifecycle_py.lifecycle_talker:main',
            'lifecycle_listener = my_lifecycle_py.lifecycle_listener:main',
            'lifecycle_manager  = my_lifecycle_py.lifecycle_manager:main',
        ],
    },
)
```

### 3.4 Python — Lifecycle Talker (Publisher Node)

The following example implements a lifecycle node that publishes a `std_msgs/String` message only while in the **Active** state. It demonstrates the four main transition callbacks.

```python
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
```

> **Key point**: use `create_lifecycle_publisher()` instead of `create_publisher()`.
> A lifecycle publisher is automatically activated and deactivated with the node,
> preventing messages from being published in the wrong state.
> Always call `super().on_activate(state)` and `super().on_deactivate(state)` to trigger this behaviour.

### 3.5 Python — Lifecycle Listener (Subscriber Node)

```python
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
```

### 3.6 Python — Programmatic Lifecycle Manager

The following node drives another lifecycle node through its states programmatically by calling lifecycle change-state services.

```python
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
```

---

## 4. Lifecycle Nodes in C++

### 4.1 Package Structure

```
my_lifecycle_cpp/
  include/
    my_lifecycle_cpp/
      lifecycle_talker.hpp
      lifecycle_listener.hpp
      lifecycle_manager.hpp
  src/
    lifecycle_talker.cpp
    lifecycle_listener.cpp
    lifecycle_manager.cpp
  package.xml
  CMakeLists.txt
```

### 4.2 `package.xml`

```xml
<?xml version="1.0"?>
<package format="3">
  <name>my_lifecycle_cpp</name>
  <version>0.1.0</version>
  <description>ROS 2 lifecycle node examples in C++</description>
  <maintainer email="dev@example.com">Developer</maintainer>
  <license>Apache-2.0</license>

  <buildtool_depend>ament_cmake</buildtool_depend>
  <depend>rclcpp</depend>
  <depend>rclcpp_lifecycle</depend>
  <depend>lifecycle_msgs</depend>
  <depend>std_msgs</depend>

  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
```

### 4.3 `CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.14)
project(my_lifecycle_cpp)

# C++17 required
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_lifecycle REQUIRED)
find_package(lifecycle_msgs REQUIRED)
find_package(std_msgs REQUIRED)

set(DEPS rclcpp rclcpp_lifecycle lifecycle_msgs std_msgs)

# Lifecycle Talker
add_executable(lifecycle_talker src/lifecycle_talker.cpp)
ament_target_dependencies(lifecycle_talker ${DEPS})
target_include_directories(lifecycle_talker PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)

# Lifecycle Listener
add_executable(lifecycle_listener src/lifecycle_listener.cpp)
ament_target_dependencies(lifecycle_listener ${DEPS})
target_include_directories(lifecycle_listener PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)

# Lifecycle Manager
add_executable(lifecycle_manager src/lifecycle_manager.cpp)
ament_target_dependencies(lifecycle_manager ${DEPS})
target_include_directories(lifecycle_manager PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)

# Install
install(TARGETS lifecycle_talker lifecycle_listener lifecycle_manager
  DESTINATION lib/${PROJECT_NAME})

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
```

### 4.4 C++ — Lifecycle Talker Header

```cpp
// Copyright 2024 Developer
// SPDX-License-Identifier: Apache-2.0
#ifndef MY_LIFECYCLE_CPP__LIFECYCLE_TALKER_HPP_
#define MY_LIFECYCLE_CPP__LIFECYCLE_TALKER_HPP_

#include <memory>
#include <string>
#include "rclcpp/rclcpp.hpp"
#include "rclcpp_lifecycle/lifecycle_node.hpp"
#include "rclcpp_lifecycle/lifecycle_publisher.hpp"
#include "std_msgs/msg/string.hpp"

namespace my_lifecycle_cpp
{

using CallbackReturn =
  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn;

/**
 * @brief Lifecycle talker node.
 *
 * Publishes std_msgs::msg::String messages at 1 Hz only while Active.
 */
class LifecycleTalker : public rclcpp_lifecycle::LifecycleNode
{
public:
  explicit LifecycleTalker(
    const rclcpp::NodeOptions & options = rclcpp::NodeOptions());
  ~LifecycleTalker() override = default;

  // -- Transition callbacks --------------------------------------------------
  CallbackReturn on_configure(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_activate(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_deactivate(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_cleanup(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_shutdown(const rclcpp_lifecycle::State & state) override;

private:
  void timer_callback();

  rclcpp_lifecycle::LifecyclePublisher<std_msgs::msg::String>::SharedPtr pub_;
  rclcpp::TimerBase::SharedPtr timer_;
  size_t count_{0};
};

}  // namespace my_lifecycle_cpp
#endif  // MY_LIFECYCLE_CPP__LIFECYCLE_TALKER_HPP_
```

### 4.5 C++ — Lifecycle Talker Implementation

```cpp
// Copyright 2024 Developer
// SPDX-License-Identifier: Apache-2.0
#include "my_lifecycle_cpp/lifecycle_talker.hpp"
#include <chrono>
#include <memory>
#include <string>

using namespace std::chrono_literals;

namespace my_lifecycle_cpp
{

LifecycleTalker::LifecycleTalker(const rclcpp::NodeOptions & options)
: rclcpp_lifecycle::LifecycleNode("lifecycle_talker", options)
{
  RCLCPP_INFO(get_logger(), "LifecycleTalker created (Unconfigured)");
}

// -- on_configure -------------------------------------------------------------
CallbackReturn
LifecycleTalker::on_configure(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Configuring from state: %s", state.label().c_str());
  pub_ = create_lifecycle_publisher<std_msgs::msg::String>("lifecycle_chatter", 10);
  timer_ = create_wall_timer(1s, std::bind(&LifecycleTalker::timer_callback, this));
  count_ = 0;
  RCLCPP_INFO(get_logger(), "Publisher created.");
  return CallbackReturn::SUCCESS;
}

// -- on_activate --------------------------------------------------------------
CallbackReturn
LifecycleTalker::on_activate(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Activating from state: %s", state.label().c_str());
  // IMPORTANT: call the parent implementation to activate the publisher
  LifecycleNode::on_activate(state);
  return CallbackReturn::SUCCESS;
}

// -- on_deactivate ------------------------------------------------------------
CallbackReturn
LifecycleTalker::on_deactivate(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Deactivating from state: %s", state.label().c_str());
  timer_.reset();
  // Deactivate the publisher through the parent
  LifecycleNode::on_deactivate(state);
  return CallbackReturn::SUCCESS;
}

// -- on_cleanup ---------------------------------------------------------------
CallbackReturn
LifecycleTalker::on_cleanup(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Cleaning up from state: %s", state.label().c_str());
  timer_.reset();
  pub_.reset();
  count_ = 0;
  RCLCPP_INFO(get_logger(), "Resources released.");
  return CallbackReturn::SUCCESS;
}

// -- on_shutdown --------------------------------------------------------------
CallbackReturn
LifecycleTalker::on_shutdown(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Shutting down from state: %s", state.label().c_str());
  timer_.reset();
  pub_.reset();
  return CallbackReturn::SUCCESS;
}

// -- timer_callback -----------------------------------------------------------
void LifecycleTalker::timer_callback()
{
  if (!pub_ || !pub_->is_activated()) {
    return;
  }
  auto msg = std_msgs::msg::String();
  msg.data = "Hello, lifecycle world! count=" + std::to_string(count_++);
  pub_->publish(msg);
  RCLCPP_INFO(get_logger(), "Published: '%s'", msg.data.c_str());
}

}  // namespace my_lifecycle_cpp

// -- main ---------------------------------------------------------------------
int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<my_lifecycle_cpp::LifecycleTalker>();
  rclcpp::spin(node->get_node_base_interface());
  rclcpp::shutdown();
  return 0;
}
```

### 4.6 C++ — Lifecycle Listener Header

```cpp
// Copyright 2024 Developer
// SPDX-License-Identifier: Apache-2.0
#ifndef MY_LIFECYCLE_CPP__LIFECYCLE_LISTENER_HPP_
#define MY_LIFECYCLE_CPP__LIFECYCLE_LISTENER_HPP_

#include <memory>
#include "rclcpp/rclcpp.hpp"
#include "rclcpp_lifecycle/lifecycle_node.hpp"
#include "std_msgs/msg/string.hpp"

namespace my_lifecycle_cpp
{

using CallbackReturn =
  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn;

class LifecycleListener : public rclcpp_lifecycle::LifecycleNode
{
public:
  explicit LifecycleListener(
    const rclcpp::NodeOptions & options = rclcpp::NodeOptions());

  CallbackReturn on_configure(const rclcpp_lifecycle::State &) override;
  CallbackReturn on_activate(const rclcpp_lifecycle::State &) override;
  CallbackReturn on_deactivate(const rclcpp_lifecycle::State &) override;
  CallbackReturn on_cleanup(const rclcpp_lifecycle::State &) override;
  CallbackReturn on_shutdown(const rclcpp_lifecycle::State &) override;

private:
  void chatter_callback(const std_msgs::msg::String & msg);

  rclcpp::Subscription<std_msgs::msg::String>::SharedPtr sub_;
};

}  // namespace my_lifecycle_cpp
#endif  // MY_LIFECYCLE_CPP__LIFECYCLE_LISTENER_HPP_
```

### 4.7 C++ — Lifecycle Listener Implementation

```cpp
// Copyright 2024 Developer
// SPDX-License-Identifier: Apache-2.0
#include "my_lifecycle_cpp/lifecycle_listener.hpp"
#include <memory>
#include <functional>

namespace my_lifecycle_cpp
{

LifecycleListener::LifecycleListener(const rclcpp::NodeOptions & opts)
: rclcpp_lifecycle::LifecycleNode("lifecycle_listener", opts)
{
  RCLCPP_INFO(get_logger(), "LifecycleListener created (Unconfigured)");
}

CallbackReturn
LifecycleListener::on_configure(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Configuring: %s", state.label().c_str());
  sub_ = create_subscription<std_msgs::msg::String>(
    "lifecycle_chatter", 10,
    std::bind(&LifecycleListener::chatter_callback, this, std::placeholders::_1));
  return CallbackReturn::SUCCESS;
}

CallbackReturn
LifecycleListener::on_activate(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Activating: %s", state.label().c_str());
  return LifecycleNode::on_activate(state);
}

CallbackReturn
LifecycleListener::on_deactivate(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Deactivating: %s", state.label().c_str());
  return LifecycleNode::on_deactivate(state);
}

CallbackReturn
LifecycleListener::on_cleanup(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Cleaning up: %s", state.label().c_str());
  sub_.reset();
  return CallbackReturn::SUCCESS;
}

CallbackReturn
LifecycleListener::on_shutdown(const rclcpp_lifecycle::State & state)
{
  RCLCPP_INFO(get_logger(), "Shutting down: %s", state.label().c_str());
  sub_.reset();
  return CallbackReturn::SUCCESS;
}

void LifecycleListener::chatter_callback(const std_msgs::msg::String & msg)
{
  RCLCPP_INFO(get_logger(), "Received: '%s'", msg.data.c_str());
}

}  // namespace my_lifecycle_cpp

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<my_lifecycle_cpp::LifecycleListener>();
  rclcpp::spin(node->get_node_base_interface());
  rclcpp::shutdown();
  return 0;
}
```

### 4.8 C++ — Lifecycle Manager

```cpp
// Copyright 2024 Developer
// SPDX-License-Identifier: Apache-2.0
/**
 * @brief Simple lifecycle manager that orchestrates another lifecycle node.
 *
 * Calls /<target>/change_state and /<target>/get_state services.
 */
#include <chrono>
#include <memory>
#include <string>
#include <thread>
#include "rclcpp/rclcpp.hpp"
#include "lifecycle_msgs/srv/change_state.hpp"
#include "lifecycle_msgs/srv/get_state.hpp"
#include "lifecycle_msgs/msg/transition.hpp"

using namespace std::chrono_literals;
using ChangeState = lifecycle_msgs::srv::ChangeState;
using GetState    = lifecycle_msgs::srv::GetState;

class LifecycleManager : public rclcpp::Node
{
public:
  explicit LifecycleManager(const std::string & target = "lifecycle_talker")
  : Node("lifecycle_manager"), target_(target)
  {
    change_state_client_ = create_client<ChangeState>("/" + target + "/change_state");
    get_state_client_    = create_client<GetState>("/" + target + "/get_state");
    RCLCPP_INFO(get_logger(), "LifecycleManager ready to manage: %s", target_.c_str());
  }

  std::string get_state()
  {
    if (!get_state_client_->wait_for_service(5s)) {
      RCLCPP_ERROR(get_logger(), "get_state service unavailable");
      return "unknown";
    }
    auto req = std::make_shared<GetState::Request>();
    auto future = get_state_client_->async_send_request(req);
    if (rclcpp::spin_until_future_complete(
        get_node_base_interface(), future, 5s) == rclcpp::FutureReturnCode::SUCCESS)
    {
      return future.get()->current_state.label;
    }
    return "unknown";
  }

  bool change_state(uint8_t transition_id, const std::string & label)
  {
    if (!change_state_client_->wait_for_service(5s)) {
      RCLCPP_ERROR(get_logger(), "change_state service unavailable");
      return false;
    }
    auto req = std::make_shared<ChangeState::Request>();
    req->transition.id    = transition_id;
    req->transition.label = label;
    auto future = change_state_client_->async_send_request(req);
    if (rclcpp::spin_until_future_complete(
        get_node_base_interface(), future, 10s) == rclcpp::FutureReturnCode::SUCCESS)
    {
      if (future.get()->success) {
        RCLCPP_INFO(get_logger(), "Transition '%s' succeeded. New state: %s",
          label.c_str(), get_state().c_str());
        return true;
      }
    }
    RCLCPP_ERROR(get_logger(), "Transition '%s' FAILED.", label.c_str());
    return false;
  }

  // -- Convenience wrappers ---------------------------------------------------
  bool configure()  { return change_state(lifecycle_msgs::msg::Transition::TRANSITION_CONFIGURE,  "configure");  }
  bool activate()   { return change_state(lifecycle_msgs::msg::Transition::TRANSITION_ACTIVATE,   "activate");   }
  bool deactivate() { return change_state(lifecycle_msgs::msg::Transition::TRANSITION_DEACTIVATE, "deactivate"); }
  bool cleanup()    { return change_state(lifecycle_msgs::msg::Transition::TRANSITION_CLEANUP,    "cleanup");    }
  bool shutdown()   { return change_state(lifecycle_msgs::msg::Transition::TRANSITION_UNCONFIGURED_SHUTDOWN, "shutdown"); }

  void run_demo()
  {
    std::this_thread::sleep_for(2s);  // wait for talker to start
    if (!configure())  return;
    std::this_thread::sleep_for(1s);
    if (!activate())   return;
    std::this_thread::sleep_for(5s);  // let it publish for 5 s
    if (!deactivate()) return;
    std::this_thread::sleep_for(1s);
    if (!cleanup())    return;
    RCLCPP_INFO(get_logger(), "Demo sequence complete.");
  }

private:
  std::string target_;
  rclcpp::Client<ChangeState>::SharedPtr change_state_client_;
  rclcpp::Client<GetState>::SharedPtr    get_state_client_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);
  auto manager = std::make_shared<LifecycleManager>("lifecycle_talker");
  manager->run_demo();
  rclcpp::shutdown();
  return 0;
}
```

---

## 5. Building the Packages

### 5.1 Workspace Layout

```
~/ros2_ws/
  src/
    my_lifecycle_py/   # Python package
    my_lifecycle_cpp/  # C++ package
```

### 5.2 Building

```bash
# Source ROS 2 underlay (replace 'humble' with your distro)
source /opt/ros/humble/setup.bash

# Navigate to workspace root
cd ~/ros2_ws

# Build all packages
colcon build --symlink-install

# Source the overlay (so your packages are found)
source install/setup.bash
```

> **Tip**: `--symlink-install` links Python files directly from `src/` instead of copying them,
> so you can edit without rebuilding. This only applies to Python packages; C++ still needs a
> rebuild after source changes.

### 5.3 Building Individual Packages

```bash
# Build only the C++ package
colcon build --packages-select my_lifecycle_cpp

# Build only the Python package
colcon build --packages-select my_lifecycle_py --symlink-install
```

---

## 6. Running and Testing

### 6.1 Launching the Nodes

Open three terminals, each sourced with the workspace overlay.

**Terminal 1** — start the talker (Python):

```bash
source ~/ros2_ws/install/setup.bash
ros2 run my_lifecycle_py lifecycle_talker
```

**Terminal 2** — start the listener (Python):

```bash
source ~/ros2_ws/install/setup.bash
ros2 run my_lifecycle_py lifecycle_listener
```

**Terminal 3** — trigger transitions manually (see §6.2).

### 6.2 Manual Transitions via CLI

The `ros2 lifecycle` CLI is the easiest way to explore the state machine.

```bash
# List available transitions for a node
ros2 lifecycle list /lifecycle_talker

# Get the current state
ros2 lifecycle get /lifecycle_talker

# Trigger the 'configure' transition
ros2 lifecycle set /lifecycle_talker configure

# Trigger 'activate'
ros2 lifecycle set /lifecycle_talker activate

# Watch messages being published
ros2 topic echo /lifecycle_chatter

# Deactivate -- publishing stops
ros2 lifecycle set /lifecycle_talker deactivate

# Clean up -- resources released
ros2 lifecycle set /lifecycle_talker cleanup

# Shut down
ros2 lifecycle set /lifecycle_talker shutdown
```

### 6.3 Using the Programmatic Manager

```bash
# Runs the full sequence automatically
ros2 run my_lifecycle_py lifecycle_manager

# Or the C++ version
ros2 run my_lifecycle_cpp lifecycle_manager
```

### 6.4 Monitoring State via Topic

Lifecycle nodes automatically publish their current state on `/<node_name>/transition_event`
as a `lifecycle_msgs/msg/TransitionEvent` message.

```bash
ros2 topic echo /lifecycle_talker/transition_event
```

Sample output:

```yaml
---
timestamp: 1711000000000000000
transition:
  id: 1
  label: configure
start_state:
  id: 1
  label: unconfigured
goal_state:
  id: 2
  label: inactive
---
```

---

## 7. Advanced Topics

### 7.1 Using Parameters Inside Lifecycle Nodes

Parameters are typically declared in `on_configure` so they are available for resource allocation.

**Python:**

```python
def on_configure(self, state: State) -> TransitionCallbackReturn:
    # Declare parameters with defaults
    self.declare_parameter('publish_rate', 1.0)
    self.declare_parameter('topic_name', 'lifecycle_chatter')
    self.declare_parameter('queue_size', 10)
    # Read them
    rate  = self.get_parameter('publish_rate').value
    topic = self.get_parameter('topic_name').value
    qsize = self.get_parameter('queue_size').value
    # Use the parameters
    self._pub = self.create_lifecycle_publisher(String, topic, qsize)
    self._timer_period = 1.0 / rate
    self.get_logger().info(
        f'Configured: topic={topic}, rate={rate} Hz, queue={qsize}')
    return TransitionCallbackReturn.SUCCESS
```

**C++:**

```cpp
CallbackReturn LifecycleTalker::on_configure(const rclcpp_lifecycle::State & state)
{
  // Declare with defaults
  declare_parameter("publish_rate", 1.0);
  declare_parameter("topic_name",   std::string("lifecycle_chatter"));
  declare_parameter("queue_size",   10);
  // Read
  auto rate  = get_parameter("publish_rate").as_double();
  auto topic = get_parameter("topic_name").as_string();
  auto qsize = static_cast<size_t>(get_parameter("queue_size").as_int());
  // Use
  pub_ = create_lifecycle_publisher<std_msgs::msg::String>(topic, qsize);
  timer_period_ = std::chrono::duration<double>(1.0 / rate);
  RCLCPP_INFO(get_logger(), "Configured: topic=%s, rate=%.1f Hz, queue=%zu",
    topic.c_str(), rate, qsize);
  return CallbackReturn::SUCCESS;
}
```

### 7.2 Error Handling and Recovery

```python
def on_configure(self, state: State) -> TransitionCallbackReturn:
    try:
        # Attempt to open hardware device
        self._device = open_hardware('/dev/sensor0')
        self._pub = self.create_lifecycle_publisher(SensorData, 'sensor_data', 10)
        return TransitionCallbackReturn.SUCCESS
    except DeviceNotFoundError as e:
        # FAILURE: node returns to previous primary state (Unconfigured)
        self.get_logger().error(f'Device not found: {e}. Retryable.')
        return TransitionCallbackReturn.FAILURE
    except Exception as e:
        # ERROR: node calls on_error(); if that also fails -> Finalized
        self.get_logger().fatal(f'Unexpected error: {e}')
        return TransitionCallbackReturn.ERROR
```

| Return value | Effect |
|---|---|
| `SUCCESS` | Node moves to the target primary state. |
| `FAILURE` | Node returns to the previous primary state (retryable). |
| `ERROR` | `on_error()` is called; if it also fails, the node goes to `Finalized`. |

### 7.3 Using a Launch File with Lifecycle Nodes

```python
# Copyright 2024 Developer
# SPDX-License-Identifier: Apache-2.0
from launch import LaunchDescription
from launch_ros.actions import LifecycleNode
from launch.actions import EmitEvent, RegisterEventHandler
from launch_ros.events.lifecycle import ChangeState
from launch_ros.event_handlers import OnStateTransition
from lifecycle_msgs.msg import Transition


def generate_launch_description():
    talker = LifecycleNode(
        package='my_lifecycle_py',
        executable='lifecycle_talker',
        name='lifecycle_talker',
        namespace='',
        output='screen',
    )
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
```

Run with:

```bash
ros2 launch my_lifecycle_py lifecycle_demo.launch.py
```

### 7.4 Introspecting Lifecycle Services

Every lifecycle node exposes the following standard services:

| Service | Type |
|---|---|
| `/<name>/get_state` | `lifecycle_msgs/srv/GetState` |
| `/<name>/change_state` | `lifecycle_msgs/srv/ChangeState` |
| `/<name>/get_available_states` | `lifecycle_msgs/srv/GetAvailableStates` |
| `/<name>/get_available_transitions` | `lifecycle_msgs/srv/GetAvailableTransitions` |
| `/<name>/get_transition_graph` | `lifecycle_msgs/srv/GetAvailableTransitions` |

```bash
# Get current state
ros2 service call /lifecycle_talker/get_state \
  lifecycle_msgs/srv/GetState

# List available transitions from current state
ros2 service call /lifecycle_talker/get_available_transitions \
  lifecycle_msgs/srv/GetAvailableTransitions

# Trigger configure via service call
ros2 service call /lifecycle_talker/change_state \
  lifecycle_msgs/srv/ChangeState \
  "{transition: {id: 1, label: configure}}"
```

---

## 8. Best Practices

1. **Allocate in `on_configure`, start in `on_activate`**. Create publishers, subscribers, and service clients during configuration. Start timers and begin processing only on activation.

2. **Release symmetrically**. If you create something in `on_configure`, release it in `on_cleanup` (not `on_shutdown` only). Mirror every allocation with a corresponding teardown.

3. **Always call the parent implementation** for `on_activate` and `on_deactivate` when using lifecycle publishers; the parent toggles the publisher's activation flag.

4. **Use lifecycle publishers** (not regular publishers) for topics that should be silent in the `Inactive` state. Lifecycle publishers refuse to publish unless activated.

5. **Distinguish `FAILURE` from `ERROR`**. Return `FAILURE` for expected, recoverable problems (hardware not ready, parameter out of range). Return `ERROR` only for truly unexpected conditions.

6. **Keep callbacks fast**. Transition callbacks block the executor. Offload long-running initialisation (e.g. loading a large ML model) to a thread and return `SUCCESS` once the thread completes.

7. **Test each transition independently**. Write unit tests for each callback; do not rely solely on integration tests.

8. **Log state transitions**. Always log at the entry of each callback. Include the state label (`state.label()`) to make logs traceable.

9. **Avoid shared mutable state between states**. If a member variable is set in `on_configure` and used in `on_activate`, document this dependency clearly.

10. **Use a lifecycle manager for multi-node systems**. The `nav2_lifecycle_manager` package provides a production-grade manager that handles dependency ordering and error recovery.

> **Warning**: Do not attempt to publish messages from a lifecycle publisher while the node is in the `Inactive` state. The message will be silently dropped. Always check `pub_->is_activated()` (C++) or `pub.is_activated` (Python) before calling `publish()`.

---

## 9. Quick Reference Card

| | Python | C++ |
|---|---|---|
| Base class | `rclpy.lifecycle.LifecycleNode` | `rclcpp_lifecycle::LifecycleNode` |
| Return type | `TransitionCallbackReturn` | `CallbackReturn` |
| Lifecycle publisher | `create_lifecycle_publisher()` | `create_lifecycle_publisher<T>()` |
| Activate publisher | Call `super().on_activate(state)` | Call `LifecycleNode::on_activate(state)` |
| Check activated | `pub.is_activated` | `pub_->is_activated()` |
| Get state (CLI) | `ros2 lifecycle get /<node_name>` | |
| Set transition (CLI) | `ros2 lifecycle set /<node_name> <transition>` | |
| Monitor events | `ros2 topic echo /<node_name>/transition_event` | |

---

## Appendix A — Installing ROS 2 on Ubuntu

### A.1 Supported Ubuntu Versions

| ROS 2 Distribution | Ubuntu | EOL |
|---|---|---|
| Humble Hawksbill (LTS) | 22.04 (Jammy) | May 2027 |
| Iron Irwini | 22.04 / 23.04 | Nov 2024 |
| Jazzy Jalisco (LTS) | 24.04 (Noble) | May 2029 |

The steps below use **Humble** on Ubuntu 22.04. Replace `humble` with `jazzy` (and `jammy` with `noble`) for the Jazzy release.

### A.2 Step 1 — Set the Locale

```bash
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
```

### A.3 Step 2 — Add the ROS 2 APT Repository

```bash
sudo apt install -y software-properties-common curl gnupg lsb-release

sudo curl -sSL \
  https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  https://packages.ros.org/ros2/ubuntu \
  $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
  sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update
```

### A.4 Step 3 — Install ROS 2

```bash
# Full desktop install (recommended)
sudo apt install -y ros-humble-desktop

# Developer tools
sudo apt install -y \
  ros-dev-tools \
  python3-colcon-common-extensions \
  python3-rosdep \
  python3-argcomplete
```

### A.5 Step 4 — Initialise rosdep

```bash
sudo rosdep init
rosdep update
```

### A.6 Step 5 — Source the Installation

```bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Verify
ros2 --version
```

### A.7 Step 6 — Create and Initialise a Colcon Workspace

```bash
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws
colcon build
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### A.8 Step 7 — Clone or Create Your Packages

```bash
cd ~/ros2_ws/src

# Create a new Python package from scratch
ros2 pkg create --build-type ament_python \
  --dependencies rclpy lifecycle_msgs std_msgs \
  my_lifecycle_py

# Create a new C++ package from scratch
ros2 pkg create --build-type ament_cmake \
  --dependencies rclcpp rclcpp_lifecycle lifecycle_msgs std_msgs \
  my_lifecycle_cpp
```

### A.9 Step 8 — Install Package Dependencies

```bash
cd ~/ros2_ws
rosdep install --from-paths src --ignore-src -r -y
```

### A.10 Step 9 — Build and Test

```bash
# Full build
colcon build --symlink-install

# Build a specific package
colcon build --packages-select my_lifecycle_cpp

# Run tests
colcon test
colcon test-result --verbose
```

### A.11 Useful Development Tools

#### colcon Cheatsheet

```bash
# Build with verbose output
colcon build --event-handlers console_direct+

# Build in parallel (N jobs)
colcon build --parallel-workers 4

# Build only packages that have changed
colcon build --packages-above-and-dependencies my_lifecycle_cpp

# List all packages in workspace
colcon list

# Clean build artefacts (keep install/)
rm -rf build/ log/
```

#### ROS 2 Environment Utilities

```bash
# List all running nodes
ros2 node list

# Inspect a node's interfaces
ros2 node info /lifecycle_talker

# List all lifecycle nodes
ros2 lifecycle nodes

# Echo a topic with a rate limit
ros2 topic echo /lifecycle_chatter --max-count 5
```

#### Installing Extra Packages

```bash
# Lifecycle messages (included in desktop; explicit install for base)
sudo apt install -y ros-humble-lifecycle-msgs

# nav2 lifecycle manager (production-grade orchestration)
sudo apt install -y ros-humble-nav2-lifecycle-manager

# rqt plugins for graphical introspection
sudo apt install -y ros-humble-rqt-graph ros-humble-rqt-topic
```

### A.12 Full Install Script

```bash
#!/usr/bin/env bash
set -e

# 1. Locale
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# 2. Repository
sudo apt install -y software-properties-common curl gnupg lsb-release
sudo curl -sSL \
  https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  https://packages.ros.org/ros2/ubuntu \
  $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
  sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update

# 3. Install
sudo apt install -y ros-humble-desktop ros-dev-tools \
  python3-colcon-common-extensions \
  python3-rosdep python3-argcomplete

# 4. rosdep
sudo rosdep init && rosdep update

# 5. Source
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# 6. Workspace
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws && colcon build
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc

echo "ROS 2 Humble installed successfully!"
ros2 --version
```

> **Note**: Run this script once on a fresh Ubuntu 22.04 installation. Do not run inside a Docker container without adjusting the `sudo` invocations, and do not run as root.

---

## Appendix B — Troubleshooting

| Problem | Solution |
|---|---|
| `ros2: command not found` | Run `source /opt/ros/humble/setup.bash` or add it to `~/.bashrc`. |
| Node not found after build | Source the workspace overlay: `source ~/ros2_ws/install/setup.bash`. |
| Messages not received | Check that both talker and listener are in `Active` state. Use `ros2 lifecycle get` to inspect. |
| `change_state` service returns failure | The transition may not be valid from the current state. Use `ros2 lifecycle list` to see available transitions. |
| Publisher drops messages silently | The lifecycle publisher is inactive. Ensure you called `super().on_activate(state)` (Python) or `LifecycleNode::on_activate(state)` (C++). |
| Colcon build fails with missing dep | Run `rosdep install --from-paths src --ignore-src -r -y` from the workspace root. |
| Linking error in C++ | Add `rclcpp_lifecycle` to both `find_package` and `ament_target_dependencies` in `CMakeLists.txt`. |
| Python `ImportError` on `rclpy.lifecycle` | Install the package: `sudo apt install ros-humble-rclpy`. |
