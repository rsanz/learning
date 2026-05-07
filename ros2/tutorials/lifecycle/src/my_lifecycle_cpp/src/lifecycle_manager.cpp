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
