# Exercise 4 - std::print and stacktrace for diagnostics

## Goal
Build a small diagnostic utility using `std::print`/`std::println` and `std::stacktrace`.

## Why This Matters
C++23 introduces better standard tools for formatting output and capturing call stacks, improving observability without external logging libraries.

## Task
Implement a tiny command runner with diagnostics.

1. Create function:
   - `int run_command(std::string_view command);`
2. Simulate a few command names:
   - `"start"` => success (return 0)
   - `"stop"` => success (return 0)
   - anything else => failure path
3. On failure:
   - print clear error message using `std::println`
   - capture and print a stack trace snippet (`std::stacktrace::current()`)
4. In `main`, call `run_command` for at least 3 inputs including one invalid command.

## Constraints
- Use `std::print` or `std::println` for output formatting.
- Keep diagnostic output concise and readable.

## Validation Checklist
- Success commands produce clean, minimal output.
- Invalid command prints both message and stack context.
- Program still exits normally after handling failure.

## Stretch
Add an enum error code and return `std::expected<void, ErrorCode>` while keeping diagnostic printing in one place.
