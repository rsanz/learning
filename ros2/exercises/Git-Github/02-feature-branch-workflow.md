# Exercise 2 - Feature Branch Workflow

## Goal
Practice safe team development using feature branches and pull requests.

## Scenario
A teammate asks you to add a small feature without breaking `main`.

## Tasks
1. Create a branch:
   - `feature/add-health-check-node`
2. In `package_a`, add a small documentation update to simulate a feature change.
3. Run local checks (mock commands are fine if package code is not ready):
   - `colcon build --packages-select package_a`
   - `colcon test --packages-select package_a`
4. Commit using a Conventional Commit message:
   - `feat: add health-check node documentation`
5. Push your branch to GitHub.
6. Open a pull request with:
   - Clear summary
   - Test evidence (commands + result)
   - Risks or assumptions

## Validation Checklist
- No direct commits were made to `main`.
- PR includes testing notes.
- Commit history is clear and reviewable.

## Stretch Task
Create a second commit that fixes a typo, then squash commits before merge.
