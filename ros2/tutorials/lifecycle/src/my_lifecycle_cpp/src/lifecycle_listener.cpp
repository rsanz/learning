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
