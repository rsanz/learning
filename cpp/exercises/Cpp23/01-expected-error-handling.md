# Exercise 1 - std::expected for explicit error handling

## Goal
Replace exception-based control flow with `std::expected` to make success/error paths explicit.

## Why This Matters
`std::expected<T, E>` is one of the most practical C++23 additions for robust APIs. It communicates failure in function signatures without hidden control flow.

## Task
Implement a small parser for configuration values.

1. Create a type alias:
   - `using ParseResult = std::expected<int, std::string>;`
2. Implement:
   - `ParseResult parse_port(std::string_view text);`
3. Rules:
   - Valid range is `[1, 65535]`.
   - Return `std::unexpected("reason")` for invalid input.
4. Implement:
   - `std::expected<void, std::string> validate_config(std::string_view host, std::string_view port);`
5. In `main`, run at least 5 test cases and print either the parsed value or the error.

## Constraints
- Do not throw exceptions for validation errors.
- Keep all error reasons human-readable.

## Validation Checklist
- Invalid numeric strings are rejected.
- Out-of-range values are rejected.
- Callers handle both success and error branches.

## Stretch
Create a helper `and_then` pipeline where one validation runs only if the previous one succeeds.
