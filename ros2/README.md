# ROS2

This folder contains learning material for **ROS2**.

## Structure
- `exercises/`: Practice tasks and solved examples.
- `tutorials/`: Guided learning notes and step-by-step walkthroughs.
- `resources/`: Topic-specific references and links.

## Tutorial Highlight: RustROS2

The RustROS2 tutorial explains how to build a working ROS 2 Jazzy publisher/subscriber example in Rust using `rclrs` with a `colcon` + `ament_cargo` workflow.

It covers:
- Why a plain `cargo build` flow fails for this setup and why `colcon` is required.
- Required system dependencies and ROS Jazzy packages.
- Correct package layout and metadata (`package.xml` + `Cargo.toml`).
- Updated `rclrs` 0.7-style talker/listener code.
- Verified build and run commands, plus troubleshooting for common errors.

Start here:
- `tutorials/RustROS2/RustROS2.md`
