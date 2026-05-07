# CppROS2.md - ROS 2 Jazzy + C++ (rclcpp) Working Tutorial

This tutorial documents a process that is verified to work for a standard ROS 2 C++ package layout.
It uses ROS 2 Jazzy, rclcpp, and colcon/ament_cmake.

## Quickstart

From `ros2/tutorials/CppROS2`:

```bash
source /opt/ros/jazzy/setup.sh
colcon build --packages-up-to cpp_pubsub
source install/setup.sh
```

Run the talker in terminal 1:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ros2/tutorials/CppROS2/install/setup.sh
ros2 run cpp_pubsub talker
```

Run the listener in terminal 2:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ros2/tutorials/CppROS2/install/setup.sh
ros2 run cpp_pubsub listener
```

## 1. Why this workflow

For ROS 2 C++ packages, use colcon with ament_cmake so dependencies, interfaces, and install targets are handled correctly.
A plain CMake-only workflow outside ROS package metadata is harder to maintain and integrate.

## 2. Prerequisites

Install core dependencies:

```bash
sudo apt update
sudo apt install -y build-essential cmake git python3-colcon-common-extensions
```

Install ROS 2 Jazzy C++ dependencies:

```bash
sudo apt install -y ros-jazzy-rclcpp ros-jazzy-std-msgs
```

## 3. Workspace Layout

Expected structure:

```text
ros2/tutorials/CppROS2/
  src/
    cpp_pubsub/
      package.xml
      CMakeLists.txt
      src/
        talker.cpp
        listener.cpp
```

The important part is that `cpp_pubsub` is a ROS package with `package.xml` and build type `ament_cmake`.

## 4. Required package files

### 4.1 package.xml

Use a package manifest like this:

```xml
<?xml version="1.0"?>
<package format="3">
  <name>cpp_pubsub</name>
  <version>0.1.0</version>
  <description>Minimal ROS 2 C++ talker/listener package.</description>
  <maintainer email="you@example.com">Your Name</maintainer>
  <license>Apache-2.0</license>

  <buildtool_depend>ament_cmake</buildtool_depend>

  <depend>rclcpp</depend>
  <depend>std_msgs</depend>

  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
```

### 4.2 CMakeLists.txt

Use:

```cmake
cmake_minimum_required(VERSION 3.8)
project(cpp_pubsub)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)

add_executable(talker src/talker.cpp)
ament_target_dependencies(talker rclcpp std_msgs)

add_executable(listener src/listener.cpp)
ament_target_dependencies(listener rclcpp std_msgs)

install(TARGETS
  talker
  listener
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
```

## 5. Source code (rclcpp)

### 5.1 Talker

```cpp
#include <chrono>
#include <memory>
#include <string>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"

using namespace std::chrono_literals;

class MinimalPublisher : public rclcpp::Node {
public:
  MinimalPublisher()
  : Node("minimal_publisher"), count_(0) {
    publisher_ = this->create_publisher<std_msgs::msg::String>("chatter", 10);
    timer_ = this->create_wall_timer(1s, [this]() { publish_message(); });
    RCLCPP_INFO(this->get_logger(), "Talker node started. Publishing to /chatter...");
  }

private:
  void publish_message() {
    std_msgs::msg::String msg;
    msg.data = "Hello World from C++: " + std::to_string(count_++);
    RCLCPP_INFO(this->get_logger(), "Publishing: [%s]", msg.data.c_str());
    publisher_->publish(msg);
  }

  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
  rclcpp::TimerBase::SharedPtr timer_;
  size_t count_;
};

int main(int argc, char * argv[]) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<MinimalPublisher>());
  rclcpp::shutdown();
  return 0;
}
```

### 5.2 Listener

```cpp
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"

class MinimalSubscriber : public rclcpp::Node {
public:
  MinimalSubscriber()
  : Node("minimal_subscriber") {
    subscription_ = this->create_subscription<std_msgs::msg::String>(
      "chatter", 10,
      [this](const std_msgs::msg::String & msg) {
        RCLCPP_INFO(this->get_logger(), "I heard: [%s]", msg.data.c_str());
      }
    );
    RCLCPP_INFO(this->get_logger(), "Listener node started. Waiting for messages...");
  }

private:
  rclcpp::Subscription<std_msgs::msg::String>::SharedPtr subscription_;
};

int main(int argc, char * argv[]) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<MinimalSubscriber>());
  rclcpp::shutdown();
  return 0;
}
```

## 6. Build process (working)

From `ros2/tutorials/CppROS2`:

```bash
source /opt/ros/jazzy/setup.sh
colcon build --packages-up-to cpp_pubsub
```

## 7. Run process

Terminal 1:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ros2/tutorials/CppROS2/install/setup.sh
ros2 run cpp_pubsub talker
```

Terminal 2:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ros2/tutorials/CppROS2/install/setup.sh
ros2 run cpp_pubsub listener
```

## 8. Verify communication

In another sourced terminal:

```bash
ros2 topic list
ros2 topic echo /chatter
ros2 node list
```

You should see the publisher and subscriber nodes and messages flowing on `/chatter`.

## 9. Notes and troubleshooting

- If `ros2 run cpp_pubsub talker` fails, confirm both terminals sourced ROS and local `install/setup.sh`.
- If build fails on missing `rclcpp` or `std_msgs`, install `ros-jazzy-rclcpp` and `ros-jazzy-std-msgs`.
- If executables are not found, confirm `install(TARGETS ...)` exists in `CMakeLists.txt`.
