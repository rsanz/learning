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
  pub_ = create_publisher<std_msgs::msg::String>("lifecycle_chatter", 10);
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
