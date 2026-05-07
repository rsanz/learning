use anyhow::Result;
use rclrs::{Context, CreateBasicExecutor, RclrsErrorFilter, SpinOptions};
use std_msgs::msg::String as StringMsg;

fn main() -> Result<()> {
    // Initialize ROS and attach the node to an executor (rclrs 0.7 API).
    let context = Context::default_from_env()?;
    let mut executor = context.create_basic_executor();
    let node = executor.create_node("minimal_subscriber")?;

    let _subscription = node.create_subscription::<StringMsg, _>("chatter", move |msg: StringMsg| {
        println!("I heard: [{}]", msg.data);
    })?;

    println!("Listener node started. Waiting for messages...");

    executor.spin(SpinOptions::default()).first_error()?;
    Ok(())
}