# Exercise 3 - Multi-Repo Dependencies with vcstool

## Goal
Use `vcstool` and `.repos` to make dependency setup reproducible.

## Scenario
Your project depends on external ROS 2 repositories and new developers need one command to bootstrap the workspace.

## Tasks
1. Create a file named `dependencies.repos` in your project root.
2. Add at least two repositories in YAML format (use real ROS 2 repos).
3. In a test workspace, import dependencies:
   - `vcs import src < dependencies.repos`
4. Install dependency packages:
   - `rosdep install --from-paths src --ignore-src -r -y`
5. Build selected packages with `colcon`.
6. Update your `README.md` with a setup section showing the exact bootstrap commands.

## Validation Checklist
- A new teammate can recreate the dependency set from `dependencies.repos`.
- No git submodules are used.
- The setup instructions are copy-paste ready.

## Stretch Task
Pin one dependency to a specific tag or commit and explain why deterministic versions matter.
