# Exercise 4 - CI and Pull Request Quality Gates

## Goal
Add automated CI checks so pull requests are validated before merge.

## Scenario
Your team wants every push and PR to run build and test checks automatically.

## Tasks
1. Create workflow file:
   - `.github/workflows/ros_ci.yml`
2. Configure triggers for:
   - Pull requests to `main`
   - Pushes to `main`
3. Include steps for:
   - Checkout
   - ROS 2 setup
   - Dependency install
   - Build and test (for at least one package)
4. Open a test PR and confirm CI runs.
5. If CI fails, fix the issue and push again.
6. Merge only after all checks pass.

## Validation Checklist
- CI executes on every PR to `main`.
- Failing checks block merge.
- Build and test logs are visible in GitHub Actions.

## Stretch Task
Add a lint stage (for example `ament_flake8` or `ament_cpplint`) and document how developers can run it locally.
