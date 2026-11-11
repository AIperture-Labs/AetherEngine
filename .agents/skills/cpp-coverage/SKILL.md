---
name: cpp-coverage
description: Measure the code coverage of AetherEngine with Clang source-based coverage and check the minimum thresholds. Use when asked for the coverage, to check that a change keeps it above the minimum, or to find untested code.
---

# Coverage

Clang source-based coverage (`-fprofile-instr-generate -fcoverage-mapping`) on the first-party targets,
Linux and Clang only. The `coverage` target runs the tests, prints the `llvm-cov` summary for `sources/`,
writes an HTML report and fails below the minimums: lines 85 %, functions 90 %, branches 75 %.

## 1. Configure and run

```bash
cmake --preset x64-coverage-clang
cmake --build --preset x64-coverage-clang --target coverage
```

The preset is Debug with `AETHER_COVERAGE=ON` and `BUILD_TESTS=ON`. See the `cmake-configure` and
`cmake-build` skills for failures. The tools (`llvm-cov`, `llvm-profdata`) are those found next to the
compiler, else on `PATH`; the configure step prints which.

## 2. Read the result

- The summary is printed per file, then one line per kind with the minimum.
- The HTML report is `out/build/x64-coverage-clang/coverage/html/index.html`: uncovered lines are red.
- A failure below a minimum ends with `The code coverage is below the minimum`. Add tests (see the
  `cpp-test` skill); never lower a threshold to make it pass.

## 3. Thresholds

They are the cache variables `AETHER_COVERAGE_MIN_LINES`, `AETHER_COVERAGE_MIN_FUNCTIONS` and
`AETHER_COVERAGE_MIN_BRANCHES`, defined in `cmake/helpers/Coverage.cmake`, the one place to change them.
To check that the target fails, pass a value above the current one:

```bash
cmake --preset x64-coverage-clang -DAETHER_COVERAGE_MIN_LINES=100
```

## CI

The `coverage` job in `.github/workflows/ci.yml` runs the same two commands and uploads the HTML report
as the `coverage-report` artifact.

## Report

State the preset, the three percentages with their minimums, and the files with the lowest coverage.
