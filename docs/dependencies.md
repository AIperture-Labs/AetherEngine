# Dependencies

Third-party dependencies come from
[vcpkg](https://learn.microsoft.com/en-us/vcpkg/) in manifest mode:
`vcpkg.json` lists them and pins the vcpkg registry with `builtin-baseline`,
so every checkout resolves the same versions. The configure step installs
them into the build directory.

## Get vcpkg

vcpkg is a git submodule, `extern/vcpkg`, pinned to the `builtin-baseline`
commit. Clone with the submodules, then configure: the first configure
bootstraps vcpkg and installs the dependencies. No `VCPKG_ROOT` and no system
install are needed.

```sh
git clone --recurse-submodules \
    https://github.com/AIperture-Labs/AetherEngine.git
cmake --preset <preset>
```

In an existing clone, run `git submodule update --init`. To use a vcpkg
installed elsewhere, override `toolchainFile` in a `CMakeUserPresets.json`
(ignored by git).

## Triplets

The presets select a custom triplet from `cmake/triplets/`, so ports build
with the same compiler as the engine:

| Host | Triplet | Compiler |
| --- | --- | --- |
| Linux | `x64-linux-clang` | `clang`, `clang++` |
| Windows | `x64-windows-clang-cl` | `clang-cl` |

## Add or update a dependency

Add it to `dependencies` in `vcpkg.json`, then run
`extern/vcpkg/vcpkg format-manifest vcpkg.json`. To update the registry, move
the submodule to a newer vcpkg commit and set `builtin-baseline` to that same
commit, in one change. Use `overrides` only to pin a port version.
