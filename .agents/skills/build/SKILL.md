---
name: build
description: Build AetherEngine, or a single target, from a configured CMake preset. Use when asked to build, compile or rebuild, or to check that a change compiles.
---

# Build

## 1. Make sure the preset is configured

The binary directory `out/build/<preset>/` must contain a `CMakeCache.txt`. If it does not, run the
`configure` skill first with the same preset.

## 2. Build

Build presets only exist in a `-verbose` variant, named after the configure preset:

```bash
cmake --build --preset <preset>-verbose
```

`cmake --build --preset <preset>` fails because no build preset has that name. Building the binary
directory directly is equivalent:

```bash
cmake --build out/build/<preset>
```

Useful flags:

| Goal | Flag |
| --- | --- |
| One target only | `--target <name>` |
| Limit parallel jobs | `--parallel <n>` |
| Clean, then build | `--clean-first` |

## 3. Handle failures

- First-party targets compile with warnings as errors (`enable_warnings()` in
  `cmake/helpers/CompilerWarnings.cmake`). Fix the cause of a warning. Do not relax the flags, and do
  not silence it with a pragma unless there is a documented reason next to it.
- A failure inside `extern/` is not fixed by editing `extern/`. Report it, with the submodule it
  comes from.
- Read the first error in the log; later errors are often consequences of it.

## Report

State the preset, the target (or "all"), and the outcome. On failure, quote the first error with
its `file:line`.
