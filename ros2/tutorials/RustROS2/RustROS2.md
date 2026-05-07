# RustROS2.md - ROS 2 Jazzy + Rust (rclrs) Working Tutorial

This tutorial documents a process that is verified to work for this repository layout.
It uses ROS 2 Jazzy, rclrs (0.7 series API), and colcon/ament_cargo.

## Quickstart

From `ROS2/RustROS2`:

```bash
source /opt/ros/jazzy/setup.sh
colcon build --packages-up-to rust_pubsub
source install/setup.sh
```

Run the talker in terminal 1:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ROS2/RustROS2/install/setup.sh
ros2 run rust_pubsub talker
```

Run the listener in terminal 2:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ROS2/RustROS2/install/setup.sh
ros2 run rust_pubsub listener
```

## 1. Why this workflow

For rclrs projects with ROS message dependencies such as std_msgs, a plain cargo-only workflow is not enough.
Use colcon with ament_cargo so ROS interface packages are discovered and linked correctly.

## 2. Prerequisites

Install core dependencies:

```bash
sudo apt update
sudo apt install -y git libclang-dev python3-pip python3-vcstool cmake
```

Install Rust using rustup (if not already installed):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install colcon Rust plugins:

```bash
pip install --break-system-packages colcon-cargo colcon-ros-cargo
cargo install cargo-ament-build
```

Install required ROS 2 Jazzy packages:

```bash
sudo apt install -y ros-jazzy-test-interface-files ros-jazzy-test-msgs
```

## 3. Workspace Layout

Expected structure:

```text
ROS2/RustROS2/
  src/
    rust_pubsub/
      Cargo.toml
      package.xml
      src/
        talker.rs
        listener.rs
```

The important part is that rust_pubsub is a ROS package with package.xml and build type ament_cargo.

## 4. Required package files

### 4.1 package.xml

Ensure package.xml includes:

- package name rust_pubsub
- build_type ament_cargo
- dependencies rclrs and std_msgs

### 4.2 Cargo.toml

Use:

```toml
[package]
name = "rust_pubsub"
version = "0.1.0"
edition = "2021"

[dependencies]
rclrs = "*"
std_msgs = "*"
anyhow = "1.0"

[[bin]]
name = "talker"
path = "src/talker.rs"

[[bin]]
name = "listener"
path = "src/listener.rs"
```

## 5. Source code that matches rclrs 0.7 API

### 5.1 Talker

```rust
use anyhow::Result;
use rclrs::{Context, CreateBasicExecutor};
use std::time::Duration;
use std_msgs::msg::String as StringMsg;

fn main() -> Result<()> {
    let context = Context::default_from_env()?;
    let executor = context.create_basic_executor();
    let node = executor.create_node("minimal_publisher")?;

    let publisher = node.create_publisher::<StringMsg>("chatter")?;

    let mut count = 0;
    println!("Talker node started. Publishing to /chatter...");

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

### 5.2 Listener

```rust
use anyhow::Result;
use rclrs::{Context, CreateBasicExecutor, RclrsErrorFilter, SpinOptions};
use std_msgs::msg::String as StringMsg;

fn main() -> Result<()> {
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
```

## 6. Build process (working)

From ROS2/RustROS2:

```bash
source /opt/ros/jazzy/setup.sh
colcon build --packages-up-to rust_pubsub
```

This command is validated in this repository and completes successfully.

## 7. Run process

Terminal 1:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ROS2/RustROS2/install/setup.sh
ros2 run rust_pubsub talker
```

Terminal 2:

```bash
source /opt/ros/jazzy/setup.sh
source /home/rsanz/git/learning/ROS2/RustROS2/install/setup.sh
ros2 run rust_pubsub listener
```

## 8. Verify communication

In another sourced terminal:

```bash
ros2 topic list
ros2 topic echo /chatter
ros2 node list
```

You should see the publisher and subscriber nodes and messages flowing on /chatter.

## 9. Notes and troubleshooting

- If you see "no matching package named std_msgs found", you are likely trying plain cargo build instead of colcon.
- If colcon reports missing cargo ament-build, run cargo install cargo-ament-build.
- If linking fails with missing test_msgs libraries, install ros-jazzy-test-msgs.
