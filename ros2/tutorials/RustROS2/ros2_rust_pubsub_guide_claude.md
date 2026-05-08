# ROS2 Pub/Sub in Rust: A Complete Guide to Talker & Listener Nodes

## Introduction

ROS2 (Robot Operating System 2) is the de-facto middleware framework for robotics software. While Python and C++ are the most commonly used languages in the ROS2 ecosystem, **Rust** is an increasingly attractive alternative thanks to its memory safety guarantees, zero-cost abstractions, and performance characteristics that closely match C++.

This guide walks you through building a classic ROS2 **talker** (publisher) and **listener** (subscriber) system entirely in Rust, using the [`rclrs`](https://github.com/ros2-rust/ros2_rust) client library — the official Rust bindings for ROS2.

By the end of this guide you will have:

- A working ROS2 Rust workspace with two nodes.
- A **talker** node that publishes a string message every second.
- A **listener** node that subscribes to those messages and prints them.
- A full understanding of how to compile and run both nodes.

---

## Prerequisites

Before starting, make sure the following are installed on your system.

| Requirement | Version | Notes |
|---|---|---|
| Ubuntu | 22.04 LTS | Recommended; other distros work with adjustments |
| ROS2 | Humble Hawksbill | Or any active LTS release |
| Rust toolchain | 1.70+ | Install via `rustup` |
| `colcon` | Latest | ROS2 build tool |
| `cargo` | Matches Rust | Comes with `rustup` |

### Install ROS2 Humble

Follow the [official ROS2 installation guide](https://docs.ros.org/en/humble/Installation.html). Then source the environment:

```bash
source /opt/ros/humble/setup.bash
```

Add this to your `~/.bashrc` to avoid repeating it every session:

```bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
```

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

### Install Required System Dependencies

```bash
sudo apt update && sudo apt install -y \
    git \
    libclang-dev \
    python3-pip \
    python3-vcstool \
    python3-colcon-common-extensions
```

---

## Project Architecture

The project uses a standard ROS2 workspace layout (`ament_cargo` build type), with two separate Rust crates living inside a `src/` directory.

```
ros2_rust_ws/
├── src/
│   ├── ros2_rust_examples/        ← (optional) vcs import file
│   ├── talker/
│   │   ├── Cargo.toml
│   │   ├── package.xml
│   │   └── src/
│   │       └── main.rs
│   └── listener/
│       ├── Cargo.toml
│       ├── package.xml
│       └── src/
│           └── main.rs
└── (colcon build artifacts appear here after building)
```

Each package has both a `Cargo.toml` (for the Rust build) and a `package.xml` (for the ROS2/colcon build system). The `ament_cargo` CMake integration bridges the two.

---

## Step 1 — Create the Workspace

```bash
mkdir -p ~/ros2_rust_ws/src
cd ~/ros2_rust_ws
```

---

## Step 2 — Import `rclrs` and Message Packages

`rclrs` and the standard ROS2 message bindings (`std_msgs`) must be present in the workspace so that `colcon` can build them alongside your nodes.

```bash
cd ~/ros2_rust_ws
# Clone the ros2_rust repository which provides rclrs
git clone https://github.com/ros2-rust/ros2_rust.git src/ros2_rust

# Use vcs to import all required dependencies declared in ros2_rust
vcs import src < src/ros2_rust/ros2_rust_deps.repos
```

> **Note:** `ros2_rust_deps.repos` pulls in `rcl`, `rosidl`, and other C-layer dependencies that `rclrs` wraps. This step may take a few minutes.

---

## Step 3 — Create the `talker` Package

### 3.1 Scaffold the directory

```bash
mkdir -p ~/ros2_rust_ws/src/talker/src
cd ~/ros2_rust_ws/src/talker
```

### 3.2 `package.xml`

The `package.xml` tells ROS2/colcon about the package, its type (`ament_cargo`), and its ROS dependencies.

```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd"
            schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>talker</name>
  <version>0.1.0</version>
  <description>
    A minimal ROS2 publisher node written in Rust.
    Publishes a Hello World string on the /chatter topic every second.
  </description>
  <maintainer email="you@example.com">Your Name</maintainer>
  <license>Apache-2.0</license>

  <!-- Build tool -->
  <buildtool_depend>ament_cargo</buildtool_depend>

  <!-- Runtime / library dependencies -->
  <depend>rclrs</depend>
  <depend>std_msgs</depend>

  <export>
    <build_type>ament_cargo</build_type>
  </export>
</package>
```

### 3.3 `Cargo.toml`

```toml
[package]
name    = "talker"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "talker"
path = "src/main.rs"

[dependencies]
# rclrs is the Rust client library for ROS2.
# The version should match the one present in your workspace.
rclrs    = "*"
std_msgs = "*"
```

> **Tip:** Using `"*"` for local workspace crates lets `colcon` resolve the correct version automatically. For external crates you would pin an explicit semver.

### 3.4 `src/main.rs` — The Talker Node

```rust
//! talker/src/main.rs
//!
//! A minimal ROS2 publisher node.
//! Publishes a std_msgs::msg::String to the "/chatter" topic at 1 Hz.

use rclrs::{create_node, Context, Node, Publisher, RclrsError, QOS_PROFILE_DEFAULT};
use std::sync::Arc;
use std::thread;
use std::time::Duration;
use std_msgs::msg::String as StringMsg;

/// Holds the node and its publisher so both stay alive for the
/// duration of the program.
struct TalkerNode {
    /// The underlying ROS2 node handle.
    node: Arc<Node>,
    /// Publisher that sends StringMsg on "/chatter".
    publisher: Arc<Publisher<StringMsg>>,
    /// Running counter used to make each message unique.
    count: u64,
}

impl TalkerNode {
    /// Create a new TalkerNode.
    ///
    /// # Arguments
    /// * `context` – The ROS2 context obtained from `Context::new`.
    fn new(context: &Context) -> Result<Self, RclrsError> {
        // Create a node named "talker" in the default namespace "/".
        let node = create_node(context, "talker")?;

        // Advertise the "/chatter" topic.
        // QOS_PROFILE_DEFAULT gives keep-last(10) reliability.
        let publisher = node.create_publisher::<StringMsg>(
            "chatter",
            QOS_PROFILE_DEFAULT,
        )?;

        Ok(Self {
            node,
            publisher,
            count: 0,
        })
    }

    /// Build the message payload and publish it.
    fn publish(&mut self) -> Result<(), RclrsError> {
        let mut message = StringMsg::default();
        message.data = format!("Hello, ROS2 from Rust! [count: {}]", self.count);

        // Log to the ROS2 console (visible via `ros2 topic echo` and the terminal).
        println!("[talker] Publishing: '{}'", message.data);

        self.publisher.publish(message)?;
        self.count += 1;

        Ok(())
    }
}

fn main() -> Result<(), RclrsError> {
    // Initialise the ROS2 context, passing command-line arguments so that
    // ROS2 remapping and parameter arguments work correctly.
    let context = Context::new(std::env::args())?;

    let mut talker = TalkerNode::new(&context)?;

    println!("[talker] Node started. Publishing on /chatter at 1 Hz …");

    // Spin in a simple loop: publish, sleep, repeat.
    // For more advanced use-cases, rclrs also supports async/await execution.
    loop {
        talker.publish()?;
        thread::sleep(Duration::from_millis(1000));

        // rclrs::spin_some processes any pending callbacks
        // (not strictly needed for a pure publisher, but good practice).
        rclrs::spin_some(Arc::clone(&talker.node))?;
    }
}
```

**Key points in the talker:**

- `Context::new(std::env::args())` initialises RCL and forwards CLI arguments to the ROS2 middleware layer, enabling remapping.
- `create_node` returns an `Arc<Node>`, meaning the node is reference-counted and can be safely shared across threads.
- `create_publisher` is generic over the message type (`StringMsg`). The topic name `"chatter"` is automatically prefixed with the node namespace.
- The publishing loop is deliberately simple; production nodes would typically use `rclrs`'s async executor or a timer callback.

---

## Step 4 — Create the `listener` Package

### 4.1 Scaffold the directory

```bash
mkdir -p ~/ros2_rust_ws/src/listener/src
cd ~/ros2_rust_ws/src/listener
```

### 4.2 `package.xml`

```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd"
            schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>listener</name>
  <version>0.1.0</version>
  <description>
    A minimal ROS2 subscriber node written in Rust.
    Listens to Hello World strings on the /chatter topic.
  </description>
  <maintainer email="you@example.com">Your Name</maintainer>
  <license>Apache-2.0</license>

  <buildtool_depend>ament_cargo</buildtool_depend>

  <depend>rclrs</depend>
  <depend>std_msgs</depend>

  <export>
    <build_type>ament_cargo</build_type>
  </export>
</package>
```

### 4.3 `Cargo.toml`

```toml
[package]
name    = "listener"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "listener"
path = "src/main.rs"

[dependencies]
rclrs    = "*"
std_msgs = "*"
```

### 4.4 `src/main.rs` — The Listener Node

```rust
//! listener/src/main.rs
//!
//! A minimal ROS2 subscriber node.
//! Subscribes to std_msgs::msg::String on the "/chatter" topic and
//! prints each received message to stdout.

use rclrs::{create_node, Context, Node, RclrsError, Subscription, QOS_PROFILE_DEFAULT};
use std::sync::{Arc, Mutex};
use std_msgs::msg::String as StringMsg;

/// Holds the node and subscription.
///
/// The subscription must be kept alive for as long as we want to receive
/// messages; storing it in the struct achieves that automatically.
struct ListenerNode {
    /// The underlying ROS2 node handle.
    node: Arc<Node>,
    /// Subscription handle. Dropping this would unsubscribe the node.
    #[allow(dead_code)]
    subscription: Arc<Subscription<StringMsg>>,
    /// Shared counter so the callback can update state owned by this struct.
    /// In a real application this might hold sensor readings, command buffers, etc.
    message_count: Arc<Mutex<u64>>,
}

impl ListenerNode {
    /// Create a new ListenerNode and register the subscription callback.
    fn new(context: &Context) -> Result<Self, RclrsError> {
        let node = create_node(context, "listener")?;

        // A shared counter, accessible both from this struct and from the
        // move-captured callback closure below.
        let message_count = Arc::new(Mutex::new(0_u64));

        // Clone the Arc so the closure can own its own reference.
        let message_count_cb = Arc::clone(&message_count);

        // Subscribe to "/chatter".
        // The callback receives an Arc<StringMsg> for each incoming message.
        let subscription = node.create_subscription::<StringMsg, _>(
            "chatter",
            QOS_PROFILE_DEFAULT,
            move |msg: StringMsg| {
                // Update the counter inside a short critical section.
                let mut count = message_count_cb.lock().unwrap();
                *count += 1;

                println!(
                    "[listener] Heard message #{}: '{}'",
                    count, msg.data
                );
            },
        )?;

        Ok(Self {
            node,
            subscription,
            message_count,
        })
    }

    /// Return how many messages have been received so far.
    fn received_count(&self) -> u64 {
        *self.message_count.lock().unwrap()
    }
}

fn main() -> Result<(), RclrsError> {
    let context = Context::new(std::env::args())?;

    let listener = ListenerNode::new(&context)?;

    println!("[listener] Node started. Waiting for messages on /chatter …");

    // rclrs::spin blocks indefinitely, waking up each time a message arrives
    // and dispatching it to the registered callback.
    rclrs::spin(Arc::clone(&listener.node))?;

    // This line is only reached if spin exits cleanly (e.g. Ctrl-C).
    println!(
        "[listener] Shutting down. Total messages received: {}",
        listener.received_count()
    );

    Ok(())
}
```

**Key points in the listener:**

- `create_subscription` takes the topic name, a QoS profile, and a **closure** as its callback. The closure is `move`-captured so it can own an `Arc` to shared state.
- `rclrs::spin` is a blocking call that drives the executor loop; it dispatches incoming messages to registered callbacks automatically.
- The `#[allow(dead_code)]` attribute on the `subscription` field silences the compiler warning that arises from holding a field purely to extend its lifetime.

---

## Step 5 — Build the Workspace

Return to the workspace root and build with `colcon`:

```bash
cd ~/ros2_rust_ws

# Make sure the ROS2 environment is sourced before building
source /opt/ros/humble/setup.bash

colcon build --packages-select rclrs std_msgs talker listener
```

On the **first build**, Cargo will download and compile all Rust dependencies, which can take several minutes. Subsequent incremental builds are much faster.

### Understanding the build flags

| Flag | Purpose |
|---|---|
| `--packages-select` | Build only the listed packages instead of the entire workspace |
| *(omit flag)* | Build everything — useful after a fresh `vcs import` |

### Optional: release build for production

```bash
colcon build \
    --packages-select talker listener \
    --cmake-args -DCMAKE_BUILD_TYPE=Release
```

---

## Step 6 — Run the Nodes

Open **two separate terminal windows**.

### Terminal 1 — Start the Listener

```bash
# Source the ROS2 underlay
source /opt/ros/humble/setup.bash

# Source the workspace overlay (generated by colcon build)
source ~/ros2_rust_ws/install/setup.bash

ros2 run listener listener
```

Expected output:

```
[listener] Node started. Waiting for messages on /chatter …
```

### Terminal 2 — Start the Talker

```bash
source /opt/ros/humble/setup.bash
source ~/ros2_rust_ws/install/setup.bash

ros2 run talker talker
```

Expected output in **Terminal 2** (talker):

```
[talker] Node started. Publishing on /chatter at 1 Hz …
[talker] Publishing: 'Hello, ROS2 from Rust! [count: 0]'
[talker] Publishing: 'Hello, ROS2 from Rust! [count: 1]'
[talker] Publishing: 'Hello, ROS2 from Rust! [count: 2]'
…
```

Expected output in **Terminal 1** (listener):

```
[listener] Node started. Waiting for messages on /chatter …
[listener] Heard message #1: 'Hello, ROS2 from Rust! [count: 0]'
[listener] Heard message #2: 'Hello, ROS2 from Rust! [count: 1]'
[listener] Heard message #3: 'Hello, ROS2 from Rust! [count: 2]'
…
```

---

## Step 7 — Inspect the System with ROS2 CLI Tools

With both nodes running, open a **third terminal** and explore the live system:

```bash
source /opt/ros/humble/setup.bash
source ~/ros2_rust_ws/install/setup.bash

# List all active topics
ros2 topic list

# Show the message type used on /chatter
ros2 topic info /chatter

# Echo messages being published on /chatter
ros2 topic echo /chatter

# Display publishing rate (should be ~1 Hz)
ros2 topic hz /chatter

# List all active nodes
ros2 node list

# Inspect the talker node
ros2 node info /talker

# Inspect the listener node
ros2 node info /listener
```

Sample output of `ros2 topic echo /chatter`:

```yaml
data: 'Hello, ROS2 from Rust! [count: 42]'
---
data: 'Hello, ROS2 from Rust! [count: 43]'
---
```

---

## Project File Tree (Final)

```
ros2_rust_ws/
├── src/
│   ├── ros2_rust/                  ← cloned rclrs repo
│   ├── talker/
│   │   ├── Cargo.toml
│   │   ├── package.xml
│   │   └── src/
│   │       └── main.rs             ← publisher source
│   └── listener/
│       ├── Cargo.toml
│       ├── package.xml
│       └── src/
│           └── main.rs             ← subscriber source
├── build/                          ← colcon build artifacts
├── install/                        ← colcon install tree
└── log/                            ← colcon logs
```

---

## Troubleshooting

### `error: package 'rclrs' not found`

Ensure you ran `vcs import` and that `colcon build` included `rclrs` in the build list. Re-run:

```bash
colcon build --packages-select rclrs std_msgs talker listener
```

### Listener does not receive messages

1. Verify both nodes are sourcing **the same** `install/setup.bash`.
2. Check the ROS_DOMAIN_ID is the same in both terminals (default is `0`):
   ```bash
   echo $ROS_DOMAIN_ID
   ```
3. Confirm the topic name matches with `ros2 topic list`.

### `libclang` not found during build

```bash
sudo apt install -y libclang-dev clang
```

### `colcon build` fails on Rust nightly features

Pin your Rust toolchain to stable in the workspace root:

```bash
rustup override set stable
```

---

## Next Steps

Now that you have a working Rust pub/sub system in ROS2, consider exploring these extensions:

- **Custom message types** — Define your own `.msg` files and generate Rust bindings with `rosidl_generator_rs`.
- **Services and actions** — `rclrs` also supports request/reply services and preemptable action servers.
- **Parameters** — Declare and read node parameters at runtime using `Node::declare_parameter`.
- **Async execution** — Replace the blocking `spin` loop with the Tokio-based async executor provided by `rclrs` for high-throughput applications.
- **Launch files** — Write Python launch files that start both the talker and listener with a single `ros2 launch` command.
- **Unit testing** — Use `rclrs`'s mock context utilities together with standard Rust `#[test]` functions to test node logic in isolation.

---

## Summary

| Step | What you did |
|---|---|
| 1 | Created a colcon workspace |
| 2 | Imported `rclrs` and its dependencies |
| 3 | Wrote the **talker** node — publisher at 1 Hz |
| 4 | Wrote the **listener** node — subscriber with callback |
| 5 | Built both packages with `colcon build` |
| 6 | Ran both nodes and observed live communication |
| 7 | Inspected the system with `ros2` CLI tools |

Rust's ownership model maps naturally onto ROS2's reference-counted node handles and lifetime-managed subscriptions, making `rclrs` a robust foundation for production robotics software. Happy building!
