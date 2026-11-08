# Dependencies

Third-party dependencies come from [vcpkg](https://learn.microsoft.com/en-us/vcpkg/) in manifest mode:
`vcpkg.json` lists them and pins the vcpkg registry with `builtin-baseline`, so every checkout resolves
the same versions. The configure step installs them into the build directory.

## Get vcpkg

Clone it anywhere and bootstrap it, then point `VCPKG_ROOT` at the clone. The presets read
`$env{VCPKG_ROOT}`; no path is committed.

```sh
git clone https://github.com/microsoft/vcpkg.git
./vcpkg/bootstrap-vcpkg.sh -disableMetrics        # Windows: .\vcpkg\bootstrap-vcpkg.bat
export VCPKG_ROOT="$PWD/vcpkg"                    # Windows (PowerShell): $env:VCPKG_ROOT = "$PWD\vcpkg"
```

Keep `VCPKG_ROOT` set in your shell profile. The clone must be a full one (not shallow) so vcpkg can
check out the baseline commit.

## Triplets

The presets select a custom triplet from `cmake/triplets/`, so ports build with the same compiler as
the engine:

| Host | Triplet | Compiler |
| --- | --- | --- |
| Linux | `x64-linux-clang` | `clang`, `clang++` |
| Windows | `x64-windows-clang-cl` | `clang-cl` |

## Add or update a dependency

Add it to `dependencies` in `vcpkg.json`, then run `vcpkg format-manifest vcpkg.json`. To update the
registry, set `builtin-baseline` to a newer vcpkg commit. Use `overrides` only to pin a port version.
