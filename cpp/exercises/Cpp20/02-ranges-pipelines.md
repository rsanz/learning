# Exercise 2 - Ranges pipelines and views

## Goal
Transform and filter data using C++20 ranges pipelines.

## Why This Matters
Ranges reduce manual loops and improve composability by chaining operations as readable pipelines.

## Task
Process a list of log lines.

1. Create a `std::vector<std::string>` containing mixed log levels (`INFO`, `WARN`, `ERROR`).
2. Build a ranges pipeline that:
   - keeps only `ERROR` entries
   - removes a leading timestamp prefix
   - converts messages to a report-friendly format
3. Materialize results into a `std::vector<std::string>`.
4. Print the final processed lines.

## Constraints
- Use `std::views::filter` and `std::views::transform`.
- Keep core logic pipeline-based (avoid index loops).

## Validation Checklist
- Only `ERROR` lines remain.
- Transformation step is applied to every remaining line.
- Pipeline is easy to read and modify.

## Stretch
Add a second pipeline that groups messages by subsystem prefix (for example: `network`, `sensor`, `ui`).
