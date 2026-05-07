# Exercise 4 - std::jthread and cooperative cancellation

## Goal
Use `std::jthread` and `std::stop_token` for safer thread lifecycle management.

## Why This Matters
`std::jthread` automatically joins on destruction and supports cooperative cancellation, reducing common threading bugs.

## Task
Build a periodic worker that can be cancelled.

1. Create a worker function that accepts `std::stop_token`.
2. Every 200 ms, print a heartbeat counter.
3. Exit cleanly when stop is requested.
4. In `main`:
   - start worker in a `std::jthread`
   - let it run for about 2 seconds
   - request stop
   - report a clean shutdown message

## Constraints
- Use `std::jthread`, not `std::thread`.
- Use cooperative cancellation (no forced termination).

## Validation Checklist
- Worker starts and emits heartbeats.
- Stop request terminates the loop promptly.
- Program exits without dangling threads.

## Stretch
Run two workers with different intervals and stop them both from a shared controller function.
