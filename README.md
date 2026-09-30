# AetherEngine

**AetherEngine** is a lightweight, modular game engine designed for flexible game development.  
The name *Aether* refers to the classical concept of the upper sky or pure air, symbolizing the engine's focus on high performance, openness, and limitless creative possibilities.

---

## Features

- **Lightweight & Modular**: Build only the systems you need.
- **Cross-platform Rendering**: Designed for Vulkan (and optionally Direct3D/OpenGL backends).
- **Flexible Asset Pipeline**: Supports 3D models, textures, and audio.
- **Integrated Debug & Profiling Tools**: Compatible with Tracy, RenderDoc, and other GPU/CPU profilers.
- **Extensible**: Plugin-based architecture for custom modules.

---

## Project Structure

```
cmake/          CMake entry points, helpers and find modules
configs/        Tooling and runtime configuration
extern/         Third-party dependencies, as git submodules
runtimes/       Vendored UV and Python runtimes (Windows, opt-in)
scripts/        just recipes
sources/        Engine modules -- one directory per module
tests/          Unit tests, one directory per module under test
```

---

## Requirements

- CMake 3.31+ and Ninja
- A C++23 compiler: GCC, Clang, clang-cl or MSVC
- Vulkan 1.4.335+, from the LunarG SDK or your distribution's packages
- An assembler for the libjpeg-turbo SIMD kernels: `nasm` or `yasm`. When neither is on
  `PATH`, the bundled `extern/yasm` is built instead.
- Python 3.14+. On Windows, `-DENABLE_RUNTIMES=ON` downloads a pinned UV and Python instead.

## Getting Started

1. **Clone the repository**

```bash
# --recurse-submodules matters: the dependencies in extern/ are submodules
git clone --recurse-submodules https://github.com/AIperture-Labs/AetherEngine.git
cd AetherEngine
```

2. **Build with CMake**

```bash
cmake --list-presets
cmake --preset <preset-name>          # configure using a preset
cmake --build --preset <preset-name>  # build using the same preset
```

The `x64-*-gcc` and `x64-*-clang` presets build natively on Linux; `x64-*-clang-cl` and
`x64-*-msvc` target Windows.

3. **Run tests**

```bash
ctest --preset x64-debug-gcc   # or x64-debug-clang
```

Tests are built by the `Debug` presets. On any other preset, configure with `-DBUILD_TESTS=ON`
and run `ctest --test-dir out/build/<preset-name>`.

## Aether - The Concept

In ancient philosophy, _Aether_ was considered the pure upper air that the gods breathed, distinct from the normal air we breathe on Earth.
In the context of AetherEngine, it represents:

- **Purity**: clean, efficient, and lightweight code
- **Freedom**: modular design allowing limitless creative possibilities
- **Performance**: targeting high-performance real-time rendering
