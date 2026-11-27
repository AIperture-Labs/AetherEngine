# Repository layout

Where things live. Read this before creating a file or a directory; if
nothing fits, ask instead of adding a top-level directory.

| Path | Content |
| --- | --- |
| `cmake/` | `Config.cmake`, the build options |
| `cmake/helpers/` | CMake functions, included by name |
| `cmake/triplets/` | vcpkg triplets and their toolchains |
| `extern/vcpkg/` | vcpkg, a git submodule pinned to the `builtin-baseline` commit |
| `docs/` | Engine documentation (Markdown) |
| `sources/<module>/` | An engine module (see [Modules](#modules)) |
| `tests/<module>/` | The unit tests of a module (doctest) |
| `tests/content/` | A content module that CI only builds |
| `.github/workflows/` | CI (`ci.yml`) |
| `.agents/instructions/` | Agent instructions |
| `.agents/instructions/coding/` | Coding rules, one file per language |
| `.agents/skills/` | Skills, one directory per skill |
| `.claude/skills` | Link to `.agents/skills`, so Claude Code finds the same skills |
| `.worktrees/` | Git worktrees, ignored by git (see [repo-workflow.md](repo-workflow.md)) |
| `out/build/<preset>/` | Build directories, ignored by git |

Root files: `CMakeLists.txt`, `CMakePresets.json`, `vcpkg.json`,
`.clang-format`, `.clang-tidy`, `.clangd`, `.editorconfig`, `.gitattributes`,
`.gitignore`, `.gitmodules`, `AGENTS.md`, `LICENSE`, `README.md`.

## Modules

A module `<name>` is `sources/<name>/` with its public headers under
`include/aether/<name>/` and its implementation under `src/`. Its tests are
`tests/<name>/*.test.cpp`. Each directory has its own `CMakeLists.txt`,
added from the parent one.

## Rules

- Build outputs and generated files never go in the tree: they live in the
  build directory, ignored by git.
- A dependency is declared in `vcpkg.json` (manifest mode, pinned by its
  `builtin-baseline`); see
  [docs/dependencies.md](../../docs/dependencies.md).
- A new directory or a new kind of file updates this page in the same
  change.
