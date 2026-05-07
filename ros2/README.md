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

## Tutorial Highlight: CppROS2

The CppROS2 tutorial explains how to build and run a minimal ROS 2 Jazzy publisher/subscriber project in C++ using `rclcpp` with a `colcon` + `ament_cmake` workflow.

It covers:
- Why `colcon` + `ament_cmake` is the recommended ROS 2 C++ workflow.
- Required system and ROS Jazzy C++ dependencies.
- Correct ROS package layout and metadata (`package.xml` + `CMakeLists.txt`).
- Working `talker.cpp` and `listener.cpp` using `rclcpp`.
- Verified build, run, and topic/node verification commands.

Start here:
- `tutorials/CppROS2/CppROS2.md`

## Tutorial Highlight: Git-Github

The Git-Github tutorial describes a practical collaboration workflow for ROS 2 projects, focused on clean repository structure, safe team development, and reproducible setup.

It covers:
- How to separate ROS 2 workspace usage from what should be version-controlled in Git repositories.
- A recommended `.gitignore` for ROS 2 build artifacts and common editor/system files.
- A feature-branch + pull request workflow (GitHub Flow) with local build/test steps before merge.
- Managing multi-repository dependencies using `.repos` files and `vcstool` instead of submodules.
- Adding automated CI with GitHub Actions to run build and test checks on pushes and PRs.

Start here:
- `tutorials/Git-Github/GIt-Github.md`

## Exercises

Hands-on practice for ROS 2 topics is organized under `exercises/`.

Git-Github workflow exercises:
- `exercises/Git-Github/README.md`
- `exercises/Git-Github/01-repository-structure-and-gitignore.md`
- `exercises/Git-Github/02-feature-branch-workflow.md`
- `exercises/Git-Github/03-multi-repo-dependencies-with-vcstool.md`
- `exercises/Git-Github/04-ci-and-pr-quality-gates.md`
