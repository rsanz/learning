# Exercise 1 - Concepts and requires clauses

## Goal
Use Concepts to constrain templates and improve compile-time diagnostics.

## Why This Matters
C++20 Concepts make template interfaces explicit and readable, replacing many SFINAE-heavy patterns.

## Task
Build a small generic statistics utility.

1. Define a concept `Arithmetic` that accepts integral and floating-point types.
2. Implement:
   - `template <Arithmetic T> T average(const std::vector<T>& values);`
3. Add a constrained overload for ranges using a `requires` clause.
4. Ensure calling `average` with a non-numeric type fails at compile time with a clear message.
5. In `main`, test with:
   - `std::vector<int>`
   - `std::vector<double>`

## Constraints
- Use Concepts or `requires`, not old-style `enable_if`.
- Handle empty input safely (return `std::optional<T>` or throw with clear justification).

## Validation Checklist
- Numeric containers compile and run.
- Non-numeric containers fail at compile time.
- Error messages are easier to understand than unconstrained templates.

## Stretch
Define a concept for "Summable" user-defined types and support them in `average`.
