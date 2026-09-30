---
name: configure
description: Configure the AetherEngine CMake build through a preset. Use when asked to configure, reconfigure or regenerate the build, before a first build, or after changing CMakeLists.txt, files under cmake/, or build options.
---

# Configure

Always configure through a preset. Never run `cmake -S . -B <dir>` by hand.

## 1. Pick a preset

```bash
cmake --list-presets
```

Presets are named `x64-<config>-<toolchain>`:

- `<config>`: `debug`, `release`, `relwithdebinfo`, `minsizerel`
- `<toolchain>`: `clang`, `clang-cl`, `msvc`

When the user does not name one, default to a debug preset for the host:

| Host | Default preset |
| --- | --- |
| Windows | `x64-debug-msvc`, or `x64-debug-clang-cl` when the user prefers Clang |
| Linux, macOS | `x64-debug-clang` |

Use `relwithdebinfo` for profiling and `release` for performance measurements.

## 2. Configure

```bash
cmake --preset <preset>
```

Pass options with `-D`, for example to enable the tests:

```bash
cmake --preset <preset> -DBUILD_TESTS=ON
```

Every option is declared in `cmake/Config.cmake`. Read it before passing one; do not invent option
names.

To discard the existing cache and configure from scratch:

```bash
cmake --preset <preset> --fresh
```

The binary directory is `out/build/<preset>/`. The preset exports `compile_commands.json` and links
it at the repository root for clangd.

## 3. Before and after running it

- Configuring is not free: it can initialise submodules and download the uv and Python runtimes into
  `runtimes/` and `.cache/`. Do not run it only to "check" something that reading the CMake files
  answers.
- `msvc` and `clang-cl` presets use Ninja with the Microsoft toolchain, so they must run from a
  Visual Studio developer shell where `cl` / `clang-cl` and the Windows SDK are on the path.
- On failure, read the **first** error, not the last. If it comes from `cmake/Dependencies.cmake`,
  check "Known rough edges" in `AGENTS.md` before patching anything.
- Never edit `extern/` or rename entries in `CMakePresets.json` to get past an error.

## Report

State the preset, any `-D` options, and the outcome. On failure, quote the first relevant error
lines with the file and line they point at.
