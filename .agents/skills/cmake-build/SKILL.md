---
name: cmake-build
description: Build AetherEngine, or a single target, from a configured CMake preset. Use when asked to build, compile or rebuild, or to check that a change compiles.
---

# Build

## 1. Make sure the preset is configured

The binary directory `out/build/<preset>/` must contain a `CMakeCache.txt`. If it does not, run the
[cmake-configure](../cmake-configure/SKILL.md) skill first with the same preset. Dependencies are
installed by vcpkg at configure time, not by the build.

## 2. Build

Each configure preset has a build preset of the same name:

```bash
cmake --build --preset <preset>
```

Useful flags:

| Goal | Flag |
| --- | --- |
| One target only | `--target <name>` |
| Limit parallel jobs | `--parallel <n>` |
| Clean, then build | `--clean-first` |
| Full command lines | `--verbose` |

## 3. Handle failures

- First-party targets compile with warnings as errors (`aether_enable_warnings()` in
  `cmake/helpers/CompilerWarnings.cmake`). Fix the cause of a warning. Do not relax the flags, and do
  not silence it with a pragma unless there is a documented reason next to it.
- Read the first error in the log; later errors are often consequences of it.

## Report

State the preset, the target (or "all"), and the outcome. On failure, quote the first error with
its `file:line`.
