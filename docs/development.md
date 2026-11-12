# Development

What every contributor needs before writing engine code.

## Prerequisites

- Git, with the submodules: `git clone --recurse-submodules` (see
  [dependencies.md](dependencies.md) for vcpkg).
- CMake 3.31 or newer, and Ninja.
- A C++23 compiler with `std::expected`: Clang on Linux, `clang-cl` from an
  x64 Visual Studio developer shell on Windows.
- clang-format and clang-tidy from LLVM 23 or newer.

## Code style

Formatting comes from `.clang-format`, the checks from `.clang-tidy`; names
follow [naming.md](naming.md).

## Error handling: avoid exceptions

Engine code avoids exceptions: it does not throw. A function that can fail says
so in its return type, `Result<T>` (a value or an `Error`) or `Status` (success
or an `Error`), and the caller decides what to do: report it and carry on,
retry, or pass it up.

```cpp
[[nodiscard]]
Result<Texture> loadTexture(const std::filesystem::path &path);

auto texture = loadTexture("hero.png");
if (!texture)
{
    log<ESeverity::Error>(kRender, "{}", texture.error().message);
    return fallbackTexture();
}
```

Why:

- **Predictable cost.** A thrown exception unwinds the stack at a cost and a
  moment the frame loop does not control. A `Result` is a plain return
  value, as cheap on failure as on success.
- **Failures are visible.** The signature says a function can fail, and a
  function returning a `Result` is marked `[[nodiscard]]`, so ignoring the
  error is a compiler warning. An exception is invisible until it is thrown.
- **Errors are reported, not fatal.** A missing texture or a bad config line
  is logged and handled where it happens; the engine keeps running.
- **Boundaries.** An exception must not cross a DLL built with another
  runtime, a C API, or a Lua or Python script. A `Result` crosses them all.
- **Portability.** Some platforms and many engines build without exceptions;
  code that never throws stays portable.

### Standard library exceptions

The standard library still throws (`std::bad_alloc` when memory runs out,
for instance), so exceptions stay enabled in the build. Engine code keeps
clear of them:

- Prefer the APIs that do not throw: `std::from_chars` over `std::stoi`, the
  `std::error_code` overloads of `std::filesystem`, `find` or `contains` over
  `at`, a `std::format` string checked at compile time.
- Catch what a standard or third-party call still throws at the call site,
  and turn it into a `Result`.
- Running out of memory is treated as fatal: there is no recovering from it
  in a game.

Building without exceptions (`-fno-exceptions`, `/EHs-c-`) would make the
binaries smaller and rule out any `throw`, but on x64 an exception that is
never thrown costs almost nothing at run time. The decision waits for
measurements: #32.

## Modules

A module is declared with one CMake function, which builds it in the engine's
[build mode](architecture.md#build-modes).

`aether_add_module()` (`cmake/helpers/AetherModule.cmake`) is the public one,
for the content of a project and for plugins:

```cmake
aether_add_module(my_project CONTENT SOURCES src/my_project.cpp)
target_link_libraries(my_project PRIVATE AetherEngine::core)
```

- The library is built in C++23 with hidden symbols: `MY_PROJECT_API`, from
  the generated `<my_project/export.hpp>`, marks what it exports.
  `INCLUDE_PREFIX <directory>` moves that header to
  `<directory>/export.hpp`.
- Public headers are in `include/`, next to the `CMakeLists.txt`.
- `CONTENT` declares the content of a project: in dynamic mode, a library
  that the host loads at run time, built into `bin/` next to the engine's
  libraries; in monolithic mode, a static library (its executable comes with
  the player, #49).
- Dependencies are added with `target_link_libraries()`; linking an engine
  module brings the [build profile](#build-profiles).

`aether_add_engine_module()` (`cmake/helpers/EngineModule.cmake`) declares a
module of the engine, in `sources/<module>/`:

```cmake
aether_add_engine_module(core SOURCES src/logger.cpp)
```

It calls `aether_add_module()` for the target `aether_core`, with the alias
`AetherEngine::core` and the macro `AETHER_CORE_API` in
`<aether/core/export.hpp>`, then adds what only the engine's own code gets:
warnings as errors and coverage.

## Build profiles

The profile says what is compiled in or out; it is independent of
`CMAKE_BUILD_TYPE`, which only sets the optimisation. One cache variable,
`AETHER_BUILD_PROFILE`, picks it, and `apply_build_profile()`
(`cmake/helpers/BuildProfile.cmake`) turns it into definitions on `aether_core`,
which reach every target linking it.

| | Debug | Development | Shipping |
| --- | --- | --- | --- |
| Definition | `AETHER_PROFILE_DEBUG` | `AETHER_PROFILE_DEVELOPMENT` | `AETHER_PROFILE_SHIPPING` |
| Logs (`AETHER_LOG_MIN_SEVERITY`) | all | from `Info` | from `Warning` |
| `AETHER_ASSERT` | on | on | compiled out |
| `AETHER_VERIFY` | checks | checks | evaluates only |
| `AETHER_VALIDATION` (internal validation checks) | `1` | `1` | `0` |

The presets set it: the `debug` ones use `Debug`, the `release` ones
`Development`, an optimized build that keeps the logs, assertions and
validation, for performance tests and profiling. `Shipping` has no preset yet;
pass it, or any other profile, with `-DAETHER_BUILD_PROFILE=<profile>`, for
instance to measure the final performance.

In code, read the profile from `<aether/core/profile.hpp>`: `kBuildProfile`,
`kAssertionsEnabled` and `kValidationEnabled`. Validation layers and other
costly checks key off `kValidationEnabled` or `#if AETHER_VALIDATION`.

## Assertions

`<aether/core/assert.hpp>`; the message is optional, with the syntax of
`std::format`:

```cpp
AETHER_ASSERT(index < size, "index {} out of range", index);
AETHER_VERIFY(file.close());  // the call stays in Shipping
AETHER_UNREACHABLE();
```

- `AETHER_ASSERT` checks the condition where assertions are enabled; in
  Shipping it compiles out, condition included, so it must have no side effect.
- `AETHER_VERIFY` always evaluates the condition, and checks it where
  assertions are enabled.
- `AETHER_UNREACHABLE` fails where assertions are enabled, and is an
  optimiser hint (`std::unreachable`) in Shipping.

A failure logs a fatal record (the `assert` category, with the expression, the
message, the file and the line), which flushes the sinks, then breaks into the
debugger, or kills the process when there is none.

An assertion reports a bug in the code, never an expected failure: those are
`Result` and `Status` (see above).

## Code coverage

Coverage is measured with Clang source-based coverage on the first-party
targets (`AETHER_COVERAGE`, off by default), the same way locally and in CI:

```sh
cmake --preset x64-coverage-clang
cmake --build --preset x64-coverage-clang --target coverage
```

The target runs the tests (child processes included, one profile per
process), prints the `llvm-cov` summary of `sources/`, writes the HTML report
to `out/build/x64-coverage-clang/coverage/html/` and fails below the minimums:
lines 85 %, functions 90 %, branches 75 %. They are the cache variables
`AETHER_COVERAGE_MIN_*` in `cmake/helpers/Coverage.cmake`. The CI `coverage`
job does the same and uploads the report as an artifact.

An assertion failure ends the process with a debug trap, which would lose its
profile: coverage builds write it first (`__llvm_profile_write_file()` in
`assertionFailed()`). Engine modules and tests are instrumented by their
CMake function; any other first-party target calls `enable_coverage()`.
