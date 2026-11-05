# Repository layout

Where things live. Read this before creating a file or a directory; if
nothing fits, ask instead of adding a top-level directory.

| Path | Content |
| --- | --- |
| `cmake/` | CMake entry points (`Config.cmake`, `Dependencies.cmake`), `helpers/` and find/config `modules/` |
| `configs/` | Tooling and runtime configuration (`submodules.toml`, `dev/`, `runtimes/`) |
| `extern/` | Third-party dependencies, as git submodules of the AIperture-Labs forks |
| `docs/` | Engine documentation (Markdown); no plans or roadmaps, those live in issues and the org Project |
| `VERSIONS.md` | Versions of the languages, tools and dependencies in use |
| `scripts/just/` | `just` recipes, imported by the root `justfile` |
| `sources/` | Engine modules, one directory per module |
| `tests/` | Unit tests, one directory per module under test (doctest) |
| `.agents/` | AI agent instructions (`instructions/`) and skills (`skills/`) |
| `.worktrees/` | Git worktrees, ignored by git (see `repo-workflow.md`) |
| `out/` | Build directories (`out/build/<preset>/`), ignored by git |

Root files: `CMakeLists.txt`, `CMakePresets.json`, `justfile`,
`.clang-format`, `.clang-tidy`, `.clangd`, `.editorconfig`, `.gitmodules`, `AGENTS.md`, `LICENSE`.

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
- A dependency is a submodule under `extern/`, declared in
  `configs/submodules.toml` and wired in `cmake/Dependencies.cmake`.
- A new directory or a new kind of file updates this page in the same
  change.
