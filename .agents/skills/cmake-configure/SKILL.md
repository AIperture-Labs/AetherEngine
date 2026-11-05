---
name: cmake-configure
description: Configure the AetherEngine CMake build through a preset. Use when asked to configure, reconfigure or regenerate the build, before a first build, or after changing CMakeLists.txt, files under cmake/, or build options.
---

# Configure

Always configure through a preset. Never run `cmake -S . -B <dir>` by hand.

## 1. Pick a preset

```bash
cmake --list-presets
```

Presets are named `x64-<config>-<toolchain>[-shared]`, all with the Ninja generator:

- `<config>`: `debug`, `release`
- `<toolchain>`: `clang` (Linux), `clang-cl` (Windows); only the presets of the host are listed
- `-shared`: builds the modules as shared libraries; without it they are static

When the user does not name one, default to the debug preset of the host:

| Host | Default preset |
| --- | --- |
| Linux | `x64-debug-clang` |
| Windows | `x64-debug-clang-cl` |

Use `release` for performance measurements.

## 2. Configure

```bash
cmake --preset <preset>
```

Pass options with `-D`, for example to switch the library kind without changing preset:

```bash
cmake --preset <preset> -DBUILD_SHARED_LIBS=ON
```

Every option is declared in `cmake/Config.cmake`. Read it before passing one; do not invent option
names.

To discard the existing cache and configure from scratch:

```bash
cmake --preset <preset> --fresh
```

The binary directory is `out/build/<preset>/`, ignored by git. The preset exports
`compile_commands.json` there, and the configure step links it at the repository root
(`compile_commands.json`, ignored by git), where clangd finds it (`CompilationDatabase: .`). The link
points to the last configured preset. On Windows without the symlink privilege (Developer Mode or an
elevated shell), configure warns and skips the link.

## 3. Before and after running it

- `clang-cl` presets must run from an x64 Visual Studio developer shell, where `clang-cl` and the Windows
  SDK are on the path.
- On failure, read the **first** error, not the last.
- Never rename entries in `CMakePresets.json` to get past an error.

## Report

State the preset, any `-D` options, and the outcome. On failure, quote the first relevant error
lines with the file and line they point at.
