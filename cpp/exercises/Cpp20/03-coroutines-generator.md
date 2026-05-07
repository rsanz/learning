# Exercise 3 - Coroutines with a simple generator

## Goal
Implement a minimal coroutine-based generator.

## Why This Matters
Coroutines are one of the largest C++20 additions and enable lazy, asynchronous, and stream-like APIs.

## Task
Create a generator that yields Fibonacci numbers lazily.

1. Implement a `Generator<T>` type with:
   - `promise_type`
   - `co_yield` support
   - iterator-like consumption API
2. Implement:
   - `Generator<std::uint64_t> fibonacci(std::size_t count);`
3. In `main`, consume and print the first 20 Fibonacci values.
4. Add a second coroutine that yields only even Fibonacci numbers.

## Constraints
- Use `co_yield` in coroutine bodies.
- Ensure proper resource cleanup (`destroy` handle when done).

## Validation Checklist
- Values are produced lazily.
- Sequence is correct for first 20 terms.
- No leaks or invalid coroutine handle access.

## Stretch
Create a reusable `take(n)` adaptor for your generator.
