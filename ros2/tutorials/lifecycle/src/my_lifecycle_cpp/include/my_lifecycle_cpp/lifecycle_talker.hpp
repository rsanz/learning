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
