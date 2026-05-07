# Exercise 1 - Repository Structure and .gitignore

## Goal
Create a ROS 2-ready repository layout and prevent build artifacts from being tracked.

## Scenario
You are starting a new robotics project with two ROS 2 packages that will be developed by multiple teammates.

## Tasks
1. Create a local project folder named `my_robot_project`.
2. Inside it, create two placeholder package folders:
   - `package_a`
   - `package_b`
3. Initialize Git in the project root.
4. Add a `.gitignore` that excludes:
   - `build/`, `install/`, `log/`
   - Python artifacts (`__pycache__/`, `*.pyc`, `.pytest_cache/`)
   - Common editor/system files (`.vscode/`, `.idea/`, `.DS_Store`)
5. Add a `README.md` with:
   - Project purpose (2-3 lines)
   - Package list
6. Commit with message:
   - `docs: initialize repository layout and gitignore`

## Validation Checklist
- `git status` shows a clean working tree after commit.
- Build folders are ignored when created manually.
- Repository root contains only source and documentation files.

## Stretch Task
Add a short section in `README.md` describing why a full ROS 2 workspace should not be version-controlled.
