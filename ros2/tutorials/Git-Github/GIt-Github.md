This tutorial provides a professional workflow for collaborative ROS 2 development using Git and GitHub. It follows the standard practices used by the Open Robotics team and major industry players.

---

# Collaborative ROS 2 Development with Git & GitHub

## 1. Project Structure: Workspace vs. Repository
In ROS 2, you work within a **workspace** (e.g., `dev_ws`), but you **never** version control the entire workspace. You only version control the packages inside the `src` folder.

### Recommended Repository Layouts
*   **Single-Package Repo:** The repository root contains `package.xml` and `CMakeLists.txt`.
*   **Multi-Package Repo (Monorepo):** The repository root contains multiple folders, each being a valid ROS 2 package.

```text
my_robot_project/          # The Git Repository
├── .gitignore
├── .github/workflows/     # CI/CD scripts
├── README.md
├── package_a/             # ROS 2 Package
│   ├── package.xml
│   └── ...
└── package_b/             # ROS 2 Package
    ├── package.xml
    └── ...
```

---

## 2. Setting Up Your `.gitignore`
Build artifacts in ROS 2 are bulky and platform-specific. You must prevent them from being tracked. Create a `.gitignore` file in your repository root:

```gitignore
# ROS 2 Build Folders
install/
build/
log/

# Python artifacts
__pycache__/
*.pyc
.pytest_cache/

# C++ artifacts
*.o
*.so
*.a

# IDEs and System
.vscode/
.idea/
.DS_Store
```

---

## 3. The Collaborative Workflow (GitHub Flow)
To avoid breaking the `main` branch, use a "Feature Branch" workflow.

### Step 1: Clone and Branch
```bash
cd ~/ros2_ws/src
git clone https://github.com/YourOrg/my_robot_project.git
cd my_robot_project
git checkout -b feature/add-lidar-processing
```

### Step 2: Develop and Test Locally
Build only your specific packages to save time:
```bash
colcon build --packages-select package_a
source install/setup.bash
colcon test --packages-select package_a
```

### Step 3: Commit and Push
Follow [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat:`, `fix:`, `docs:`) for a clean history.
```bash
git add .
git commit -m "feat: implement laser scan filtering"
git push origin feature/add-lidar-processing
```

### Step 4: Pull Request (PR)
1.  Go to GitHub and open a **Pull Request**.
2.  Assign a reviewer.
3.  Ensure CI passes (see Section 5).
4.  Once approved, use **"Squash and Merge"** to keep the `main` history clean.

---

## 4. Managing Multi-Repo Projects with `vcstool`
If your project depends on several different Git repositories, do not use Git Submodules (they are often clunky for ROS). Instead, use `.repos` files and `vcstool`.

Create a file named `dependencies.repos`:
```yaml
repositories:
  sllidar_ros2:
    type: git
    url: https://github.com/Slamtec/sllidar_ros2.git
    version: humble
  navigation2:
    type: git
    url: https://github.com/ros-navigation/navigation2.git
    version: main
```

**How to use it:**
Collaborators can set up their workspace instantly with:
```bash
vcs import src < dependencies.repos
rosdep install --from-paths src --ignore-src -r -y
```

---

## 5. Automating Quality with GitHub Actions
Create a `.github/workflows/ros_ci.yml` file. This will automatically build and test your code on every PR to ensure no one "breaks the build."

```yaml
name: ROS 2 CI
on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup ROS 2
        uses: ros-tooling/setup-ros@v0.7
        with:
          required-ros-distributions: humble

      - name: Install Dependencies
        run: |
          sudo apt update
          rosdep update
          rosdep install --from-paths . --ignore-src -y

      - name: Build and Test
        uses: ros-tooling/action-ros-ci@v0.3
        with:
          target-ros2-distro: humble
          # This runs colcon build, ament_lint, and colcon test automatically
```

---

## 6. Pro Tips for ROS 2 Teams
1.  **Linters are Non-Negotiable:** Run `ament_cpplint` or `ament_flake8` locally before pushing. ROS 2 is strict about code style.
2.  **README is your Front Door:** Always include:
    *   Hardware requirements.
    *   List of ROS 2 Nodes, Topics, and Parameters.
    *   How to run the launch files.
3.  **Binary Assets:** If you have large `.mesh` files or `.urdf` assets, consider using **Git LFS** (Large File Storage) to keep the repository size manageable.
4.  **License:** Always include a `LICENSE` file (Apache 2.0 is the ROS 2 standard).