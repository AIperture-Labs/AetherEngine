# Development

What every contributor needs before writing engine code.

## Prerequisites

- Git, with the submodules: `git clone --recurse-submodules` (see
  [dependencies.md](dependencies.md) for vcpkg).
- CMake 3.31 or newer, and Ninja.
- A C++23 compiler with `std::expected`: Clang on Linux, `clang-cl` from an
  x64 Visual Studio developer shell on Windows.
- clang-format and clang-tidy from LLVM 23 or newer.

## Error handling: avoid exceptions

Engine code avoids exceptions: it does not throw. A function that can fail says
so in its return type, `Result<T>` (a value or an `Error`) or `Status` (success
or an `Error`), and the caller decides what to do: report it and carry on,
retry, or pass it up.

```cpp
[[nodiscard]] Result<Texture> loadTexture(const std::filesystem::path &path);

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
