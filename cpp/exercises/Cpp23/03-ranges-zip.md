# Exercise 3 - Ranges improvements with views::zip

## Goal
Use C++23 ranges additions, especially `std::views::zip`, to process multiple sequences safely and clearly.

## Why This Matters
C++23 ranges reduce index-heavy loops and improve composability. `views::zip` is a major usability improvement for parallel iteration.

## Task
Compute weighted scores for students.

1. Create three vectors:
   - `names` (string)
   - `scores` (double)
   - `weights` (double)
2. Use `std::views::zip` to iterate them together.
3. Produce a vector of output rows: `"name: weighted_score"`.
4. Add a second pipeline that filters results with weighted score >= 70.
5. Print both full and filtered results.

## Constraints
- Prefer range pipelines over manual index loops.
- Avoid unchecked indexing.

## Validation Checklist
- Works correctly when vectors have different lengths (zip truncates to shortest).
- Filtered output contains only passing entries.
- No raw `for (size_t i = 0; ... )` loop in core logic.

## Stretch
Sort final rows by weighted score descending using ranges-friendly style.
