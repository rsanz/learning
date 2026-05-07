# Exercise 2 - Deducing this for cleaner member APIs

## Goal
Use C++23 explicit object parameters ("deducing this") to reduce duplication between `const`, non-`const`, lvalue, and rvalue member overloads.

## Why This Matters
Before C++23, fluent APIs often needed many overloads. Deducing `this` lets one template member function adapt to object category and constness.

## Task
Create a `SmallBuffer` class with a fluent transform API.

1. Store data in `std::vector<int> values;`
2. Implement a single member using deducing `this`:
   - `template <class Self, class F> auto transform(this Self&& self, F&& f);`
3. Behavior:
   - Applies `f` to every element.
   - Returns `self` to allow chaining.
4. Demonstrate all of the following in `main`:
   - Transform on non-const lvalue object.
   - Transform on temporary object.
   - Read-only operation on const object (for example, a `sum` function).

## Constraints
- Avoid writing four separate overloads for `transform`.
- Preserve value category where possible (`std::forward<Self>(self)`).

## Validation Checklist
- Method chaining works.
- No unnecessary copies are introduced.
- Code compiles cleanly in C++23 mode.

## Stretch
Add a `filter` operation using the same explicit-object-parameter style.
