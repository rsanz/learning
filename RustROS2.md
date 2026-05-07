# RustROS2.md --- Comprehensive Guide to ROS 2 with Rust: Talker and Listener

Developing ROS 2 nodes in Rust provides the memory safety and performance of Rust while leveraging the robust communication middleware of ROS 2. This guide uses **`rclrs`**, the standard client library for Rust in the ROS 2 ecosystem.

---

## 1. Prerequisites

Before starting, ensure you have the following installed on your system:

*   **ROS 2** (Humble or Iron recommended).
*   **Rust and Cargo**: Install via [rustup.rs](https://rustup.rs/).
*   **System Dependencies**:
    ```bash
    sudo apt update
    sudo apt install -y git libclang-dev python3-pip python3-vcstool cmake
    ```

---

## 2. Project Setup

We will create a standard Cargo project and configure it to work with ROS 2 messages.

### Create the Workspace
```bash
mkdir -p ~/ros2_rust_ws/src
cd ~/ros2_rust_ws/src
cargo new rust_pubsub
cd rust_pubsub
```

### Configure `Cargo.toml`
Open `Cargo.toml` and update the dependencies. `rclrs` handles the ROS 2 logic, and `std_msgs` provides the standard string message type.

```toml
[package]
name = "rust_pubsub"
version = "0.1.0"
edition = "2021"

[dependencies]
rclrs = "0.3.0"
std_msgs = "0.3.0"
anyhow = "1.0"

[[bin]]
name = "talker"
path = "src/talker.rs"

[[bin]]
name = "listener"
path = "src/listener.rs"
```
*(Note: Version numbers may vary; check [crates.io](https://crates.io) for the latest `rclrs` release.)*

---

## 3. Source Code: The Talker (Publisher)

Create a new file at `src/talker.rs`. This node publishes a message to the `chatter` topic every second.

```rust
use std::time::Duration;
use anyhow::Result;
use rclrs::{Context, Node, QOS_PROFILE_DEFAULT};
use std_msgs::msg::String as StringMsg;

fn main() -> Result<()> {
    // 1. Initialize the ROS 2 context
    let context = Context::new(std::env::args())?;

    // 2. Create a node named 'minimal_publisher'
    let node = context.create_node("minimal_publisher")?;

    // 3. Create a publisher for the 'chatter' topic
    let publisher = node.create_publisher::<StringMsg>("chatter", QOS_PROFILE_DEFAULT)?;

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
```

---

## 4. Source Code: The Listener (Subscriber)

Create a new file at `src/listener.rs`. This node listens to the `chatter` topic and prints messages to the console.

```rust
use anyhow::Result;
use rclrs::{Context, Node, QOS_PROFILE_DEFAULT};
use std_msgs::msg::String as StringMsg;

fn main() -> Result<()> {
    // 1. Initialize the ROS 2 context
    let context = Context::new(std::env::args())?;

    // 2. Create a node named 'minimal_subscriber'
    let node = context.create_node("minimal_subscriber")?;

    // 3. Create a subscription
    // The closure is triggered every time a message is received
    let _subscription = node.create_subscription::<StringMsg, _>(
        "chatter",
        QOS_PROFILE_DEFAULT,
        move |msg: StringMsg| {
            println!("I heard: [{}]", msg.data);
        },
    )?;

    println!("Listener node started. Waiting for messages...");

    // 4. Spin the node to keep it alive and processing callbacks
    rclrs::spin(node).map_err(|e| e.into())
}
```

---

## 5. Compiling and Running

### Step 1: Source your ROS 2 Environment
Open a terminal and source your installation (e.g., Humble):
```bash
source /opt/ros/humble/setup.bash
```

### Step 2: Build the Project
From the `~/ros2_rust_ws/src/rust_pubsub` directory, run:
```bash
cargo build
```

### Step 3: Run the Talker
In the current terminal, run:
```bash
cargo run --bin talker
```

### Step 4: Run the Listener
Open a **new terminal**, source ROS 2 again, and run:
```bash
source /opt/ros/humble/setup.bash
cd ~/ros2_rust_ws/src/rust_pubsub
cargo run --bin listener
```

---

## 6. Verification with Command Line Tools

While the nodes are running, you can use standard ROS 2 CLI tools to inspect the system:

*   **List Topics**:
    ```bash
    ros2 topic list
    ```
*   **Echo the Messages**:
    ```bash
    ros2 topic echo /chatter
    ```
*   **Check Node Graph**:
    ```bash
    ros2 node list
    ```

## Conclusion
You have successfully built a ROS 2 communication system using Rust. This approach provides the safety benefits of Rust's ownership model while remaining fully interoperable with ROS 2 nodes written in C++ or Python.