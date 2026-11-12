# Repository layout

Where things live. Read this before creating a file or a directory; if
nothing fits, ask instead of adding a top-level directory.

| Path | Content |
| --- | --- |
| `cmake/` | CMake entry points (`Config.cmake`), `helpers/`, find/config `modules/` and vcpkg `triplets/` |
| `extern/vcpkg/` | vcpkg, as a git submodule pinned to the `builtin-baseline` commit |
| `docs/` | Engine documentation (Markdown) |
| `sources/` | Engine modules, one directory per module |
| `tests/` | Unit tests, one directory per module under test (doctest) |
| `.github/` | GitHub configuration: `workflows/` (CI, see `ci.yml`) |
| `.agents/` | AI agent instructions (`instructions/`) and skills (`skills/`) |
| `.worktrees/` | Git worktrees, ignored by git (see `repo-workflow.md`) |
| `out/` | Build directories (`out/build/<preset>/`), ignored by git |

Root files: `CMakeLists.txt`, `CMakePresets.json`, `vcpkg.json`,
`.clang-format`, `.clang-tidy`, `.clangd`, `.editorconfig`, `.gitattributes`,
`.gitignore`, `.gitmodules`, `AGENTS.md`, `LICENSE`, `README.md`.

`.claude/skills` is a symlink to `.agents/skills`, so Claude Code finds the
same skills.

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
