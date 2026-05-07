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

  CallbackReturn on_configure(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_activate(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_deactivate(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_cleanup(const rclcpp_lifecycle::State & state) override;
  CallbackReturn on_shutdown(const rclcpp_lifecycle::State & state) override;

private:
  void chatter_callback(const std_msgs::msg::String & msg);

  rclcpp::Subscription<std_msgs::msg::String>::SharedPtr sub_;
};

}  // namespace my_lifecycle_cpp
#endif  // MY_LIFECYCLE_CPP__LIFECYCLE_LISTENER_HPP_
