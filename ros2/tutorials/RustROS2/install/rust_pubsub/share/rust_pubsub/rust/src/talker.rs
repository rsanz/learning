use anyhow::Result;
use rclrs::{Context, CreateBasicExecutor};
use std::time::Duration;
use std_msgs::msg::String as StringMsg;

fn main() -> Result<()> {
    // Initialize ROS and create a node through an executor (rclrs 0.7 API).
    let context = Context::default_from_env()?;
    let executor = context.create_basic_executor();
    let node = executor.create_node("minimal_publisher")?;

    let publisher = node.create_publisher::<StringMsg>("chatter")?;

    let mut count = 0;
    println!("Talker node started. Publishing to /chatter...");

    // 4. Main loop: publish every 1 second
    while context.ok() {
        let msg = StringMsg {
            data: format!("Hello World from Rust: {}", count),
        };
        
        println!("Publishing: [{}]", msg.data);
        publisher.publish(&msg)?;
        
        count += 1;
        std::thread::sleep(Duration::from_secs(1));
    }

    Ok(())
}