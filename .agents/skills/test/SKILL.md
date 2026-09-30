---
name: test
description: Build and run the AetherEngine unit tests (doctest + CTest), or add new tests. Use when asked to run, write or fix tests, or to verify a change with tests.
---

# Test

Unit tests use [doctest](https://github.com/doctest/doctest) and are run through CTest.

## 1. Configure and build with tests enabled

`BUILD_TESTS` is `OFF` by default:

```bash
cmake --preset <preset> -DBUILD_TESTS=ON
cmake --build --preset <preset>-verbose
```

See the `configure` and `build` skills for choosing the preset and handling failures.

## 2. Run

There are no test presets; point CTest at the binary directory:

```bash
ctest --test-dir out/build/<preset> --output-on-failure
```

| Goal | Flag |
| --- | --- |
| Tests matching a regex | `-R <regex>` |
| Exclude tests | `-E <regex>` |
| List without running | `-N` |
| Parallel run | `-j <n>` |

Test names are prefixed with their executable: `<executable>/<test case>`.

**If CTest prints `No tests were found`, report exactly that.** It means nothing ran — never
present it as a passing run.

## 3. Add tests

1. Put sources under `tests/`, one executable per engine module.
2. Register each executable with `add_doctest()` from `cmake/helpers/Doctest.cmake`:

   ```cmake
   include(Doctest)

   add_doctest(
       NAME   <module>_tests
       SOURCES <module>/foo_tests.cpp
       LIBS   <engine target>
   )
   ```

   It creates the executable, links doctest, and registers every test case with CTest.
3. CTest only sees tests when testing is enabled. Check that, behind `if(BUILD_TESTS)`, the build
   calls `enable_testing()` and `add_subdirectory(${AETHER_ENGINE_TESTS_DIR})`. If either is missing,
   add it in the top-level `CMakeLists.txt` and say so in your report.

Write test names and assertion messages in English, like the rest of the repository.

## Report

State the preset, the command, and the counts CTest prints (passed, failed, not run). For each
failure, give the test name and the assertion output.
