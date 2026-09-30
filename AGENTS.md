# AGENTS.md

Single source of truth for every AI coding agent working on **AetherEngine**.

This file is tool-agnostic on purpose. `CLAUDE.md`, `GEMINI.md` and
`.github/copilot-instructions.md` are symlinks to it, and `.claude/` is a symlink to `.agents/`.
**Edit this file only** — never the aliases. See [Agent tooling layout](#11-agent-tooling-layout).

---

## 1. Project at a glance

AetherEngine is a lightweight, modular game engine written in C/C++23, targeting Vulkan.

| Aspect | Value |
| --- | --- |
| Languages | C 23 and C++ 23, strict ISO (no compiler extensions) |
| Build system | CMake `3.31 … 4.1`, **presets only**, generator Ninja |
| Task runner | [`just`](https://just.systems/man/en/) |
| Dependencies | git submodules under `extern/`, pinned to AIperture-Labs forks |
| Primary platform | Windows x64 (MSVC / clang-cl / clang); Linux is work in progress |
| Toolchain extras | clangd, clang-format, clang-tidy, Vulkan SDK 1.4.335, uv + Python 3.14 |

**Current status: bootstrap phase.** `sources/`, `tests/` and `docs/` are empty, and the matching
`add_subdirectory()` calls in `CMakeLists.txt` are commented out. There is no engine code yet — do
not assume any type, module or test exists. Work so far is build-system plumbing under `cmake/`.

---

## 2. Language policy

- **Conversation** with the maintainer happens in the maintainer's language (expect French).
- **Everything that lands in the repository is English only**: code, identifiers, comments,
  docstrings, documentation, README files, commit messages, branch names, PR titles and
  descriptions, log and error strings, `TODO` / `FIXME` notes, CMake `message()` output.
- The only exception is an explicit request from the maintainer for a specific file or artefact.
- Some legacy commit messages are in French. They are history: do not imitate them, and do not
  rewrite history to translate them.

---

## 3. Repository layout

```
.agents/            Shared agent configuration (see §11); .claude/ symlinks here
.github/            CI workflows and tool prompt files
assets/             Shaders and textures (referenced by CMake, not created yet)
cmake/
  Config.cmake         All user-facing options, language standards, AETHER_ENGINE_* paths
  Dependencies.cmake   External dependency wiring, called from the top-level CMakeLists
  helpers/             Project-internal CMake functions (include(<Name>), then call)
  modules/             Find*/*Config modules for third-party tooling (find_package)
configs/
  dev/                 Visual Studio component manifests (.vsconfig-2022, .vsconfig-2026)
  runtimes/uv/         uv configuration, generated from uv.toml.in
  submodules.toml      Pinned tag/branch + fork URL for every submodule
docs/                Documentation (empty)
extern/              Submodules: glm, libjpeg-turbo, yasm, doctest — DO NOT EDIT
out/                 Build and install trees (gitignored)
runtimes/            Downloaded uv and Python runtimes (gitignored)
scripts/just/        just recipe modules, imported by the root justfile
sources/             Engine source code (empty)
tests/               doctest unit tests (empty)
```

`cmake/helpers/` vs `cmake/modules/`: helpers are project functions consumed with
`include(<Name>)`; modules are package-discovery files consumed with `find_package()`
(`cmake/modules` is on both `CMAKE_MODULE_PATH` and `CMAKE_PREFIX_PATH`).

---

## 4. Build, configure, test

Presets are the only supported entry point. Never call bare `cmake -S . -B build`.

```bash
cmake --list-presets              # configure presets
cmake --list-presets=build        # build presets

cmake --preset x64-debug-clang                    # configure
cmake --build --preset x64-debug-clang-verbose    # build
```

Preset naming: `x64-<debug|release|relwithdebinfo|minsizerel>-<clang|clang-cl|msvc>`.
Hidden bases: `base`, `base-clang`, `base-clang-cl`, `base-msvc`, `verbose`.

**Build presets only exist in the `-verbose` variant.** `cmake --build --preset x64-debug-clang`
fails; use `x64-debug-clang-verbose`, or build the binary dir directly with
`cmake --build out/build/x64-debug-clang`.

Artifacts land in `out/build/<presetName>/`, installs in `out/install/<presetName>/`.
`CMAKE_EXPORT_COMPILE_COMMANDS` is `ON` in the `base` preset, and
`setup_compile_commands_symlink()` links `compile_commands.json` at the repository root for
clangd. That link is gitignored — never commit it.

Tests: `BUILD_TESTS` defaults to `OFF`, `tests/` is empty and there are no test presets, so
`ctest` currently has nothing to run. The `ctest` snippet in `README.md` is still marked FIXME.

Common `just` recipes (run `just --list` for the full set):

| Recipe | Purpose |
| --- | --- |
| `just submodules-init` | `git submodule update --init --recursive` |
| `just submodules-status` / `submodules-branch` | inspect submodule state |
| `just submodules-update` | pull submodules from their forks (`origin`) |
| `just submodules-sync` / `submodules-full-sync` | fetch + merge `upstream`, push to fork |
| `just get-tools-version` | print versions of git, code, cmake, clang, clangd, ninja |
| `just clean-all` | remove `.cache`, runtimes and build trees |
| `just dev-bootstrap` | Windows only: winget install Git, Vulkan SDK, RenderDoc |
| `just agents-link` | recreate the agent alias symlinks (see §11) |
| `just agents-status` | show what every agent alias currently resolves to |

Several recipes are annotated `[windows]` and simply do not exist on Linux.

---

## 5. Code style

Formatting and linting are configuration-driven. Run the tools; do not hand-tune layout.

```bash
clang-format -i <files>       # or: clang-format --dry-run --Werror <files>
clang-tidy -p . <files>
```

`.clang-format` — Google base, and notably:

- 4-space indent, 120-column limit, `IndentPPDirectives: AfterHash`
- braces on their own line after struct / class / function / control statement, and before `else`
- never collapse short blocks, functions, `if`s or loops onto one line
- `SortIncludes` with `IncludeBlocks: Regroup`
- `PointerAlignment` / `ReferenceAlignment`: **Right** (`Type *ptr`, `Type &ref`)
- aligned consecutive assignments, declarations, operands and trailing comments
- `SeparateDefinitionBlocks: Always`

`.clang-tidy` — `modernize-*` and `cppcoreguidelines-*`, warnings are **not** errors,
`modernize-use-trailing-return-type` disabled, header filter `sources/**/*.hpp`.

`.clangd` — `UnusedIncludes: Strict` and `HeaderInsertion: IWYU`, so keep includes minimal and
include what you use.

Compiler warnings: call `enable_warnings(<target>)` from `cmake/helpers/CompilerWarnings.cmake`
on every first-party target. It applies `/W4 /WX` (MSVC) or `-Wall -Wextra -Wpedantic -Werror`
(GCC/Clang) as `PRIVATE`. **First-party code must compile warning-free**; do not silence a
warning by weakening the flags.

### File header

Every new source, CMake, config or script file starts with the copyright line, followed by a
blank line before the content:

```cmake
# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Docs:
#   - https://cmake.org/cmake/help/v4.1/index.html
```

The `Doc:` / `Docs:` lines pointing at upstream reference material are a strong convention here —
add them when a file leans on an external tool or format. The repository has no `LICENSE` file and
no file carries an SPDX identifier yet; do not invent one.

---

## 6. CMake conventions

- **Every user-facing knob lives in `cmake/Config.cmake`** as an `option()` or cached `set()`,
  grouped under a banner comment and documented inline. Do not scatter options elsewhere.
- Paths go through the `AETHER_ENGINE_*` cache variables (`AETHER_ENGINE_SOURCE_DIR`,
  `AETHER_ENGINE_EXTERN_DIR`, `AETHER_ENGINE_CACHE_DIR`, …) rather than raw
  `${CMAKE_CURRENT_SOURCE_DIR}/...` strings.
- Section banners use a `# ===…===` rule roughly 110 characters wide, matching existing files.
- Public functions in `cmake/helpers/` and `cmake/modules/` carry an
  `#[=======[.rst: … #]=======]` (or `#[=[ … ]=]`) docstring with Synopsis, Description, Arguments
  and Example sections. Match the surrounding style when adding one.
- `message()` output from a function is prefixed with the function name:
  `message(STATUS "[git_submodules_update] Updating submodules...")`.
- Argument parsing uses `cmake_parse_arguments()` with an uppercase prefix.
- Vendored dependency options are prefixed and mirrored in `Config.cmake` (`GLM_*`, `YASM_*`,
  `JPEG_*`), so upstream defaults stay overridable from one place.

---

## 7. Git conventions

- **Conventional Commits**, optionally scoped, subject in English and in the imperative:
  `feat(cmake): add UV package manager integration module`,
  `fix(cmake): correct variable name for force download`,
  `chore(submodules): switch submodules to AIperture-Labs forks`,
  `refactor:`, `docs:`, `test:`, `build:`, `ci:`.
- Branches: `feature/<topic>`, `examples/<topic>`, `wip/<topic>`, `fix/<topic>`. Work on a branch,
  never commit directly to `main`.
- Submodules point at **AIperture-Labs forks** (`origin` = fork, `upstream` = original project).
  Pinned versions are recorded in `configs/submodules.toml`. To change a dependency: commit in the
  fork, push it, then bump the submodule pointer here in its own `chore(<name>):` commit.
- Changes land on `main` through pull requests.

---

## 8. Hard rules

Do not, without an explicit request from the maintainer:

1. **Edit anything under `extern/`.** Those are submodules of separate fork repositories.
2. Commit generated or downloaded content: `out/`, `.cache/`, `runtimes/`,
   `compile_commands.json`, `CMakeUserPresets.json`, `configs/runtimes/uv/uv.toml`.
3. Push to `main`, force-push, rewrite history, or merge branches.
4. Rename or restructure `CMakePresets.json` entries — preset names are referenced by `.vscode/`,
   CI and muscle memory.
5. Add, remove or swap a third-party dependency, or relax the warning flags in
   `CompilerWarnings.cmake`.
6. Reformat, reorder or "clean up" files you are not otherwise changing. Keep diffs minimal and
   on-topic.
7. Run a full configure just to check something. It downloads the uv and Python runtimes and
   initialises every submodule. Prefer reading the CMake files.
8. Weaken a check to make something pass. If a build or lint fails, fix the cause or report it.

---

## 9. Known rough edges

Snapshot of real inconsistencies in the tree. Verify against the current files before relying on
any of them — this list ages.

- **Linux configure is not expected to work yet.** `cmake/Dependencies.cmake` unconditionally
  downloads `uv-x86_64-pc-windows-msvc.zip` and installs Python from it, before any platform
  check. Cross-platform support is active work; coordinate rather than patching around it.
- `cmake/Config.cmake` declares the option `GIT_SUBMODULE_UPDATE`, while `cmake/Dependencies.cmake`
  tests `GIT_SUBMODULES_UPDATE` (plural) — so the guard is always false and
  `git_submodules_update()` never runs from the build.
- Standards disagree: CMake sets C/C++ **23**, while `.clang-format` declares `Standard: c++20`
  and `.clangd` adds `-std=c++20`.
- `.clangd` hardcodes a Windows Vulkan include path (`-IC:/VulkanSDK/1.4.335.0/Include/`).
- `Config.cmake` defines `AETHER_ENGINE_ASSETS_DIR` (and shaders/textures under it) but `assets/`
  does not exist.
- `Dependencies.cmake` hardcodes uv `0.9.27` and `FORCE_DOWNLOAD` instead of using
  `AETHER_ENGINE_UV_VERSION` and the `FORCE_DOWNLOAD_DEPS` option.
- `README.md` still contains `# TODO` for the project structure and a FIXME on the test command.
- The `[windows]` clean recipes in `scripts/just/clean.just` use `rm -Force <dir>` without
  `-Recurse`, which PowerShell refuses on a non-empty directory. `just clean-all` therefore does
  not fully clean on Windows.

---

## 10. Working agreement

- Read before writing. This is a small, opinionated, heavily commented tree — match the
  surrounding style instead of importing conventions from elsewhere.
- **Several agents may work on this repository in parallel.** Work in a git worktree or a
  dedicated branch, keep the change scoped, and do not touch unrelated files.
- State plainly what you verified and what you assumed. If a command was not run, say so.
- When the request and the code disagree, say so in one or two sentences and continue with the
  request, flagging the assumption.

---

## 11. Agent tooling layout

One source of truth, one alias per tool. Agnostic by construction: adding a tool means adding a
link, never copying content.

| Path | Kind | Read by |
| --- | --- | --- |
| `AGENTS.md` | real file | the cross-tool standard (Codex, Cursor, Aider, Jules, …) |
| `CLAUDE.md` | symlink → `AGENTS.md` | Claude Code |
| `GEMINI.md` | symlink → `AGENTS.md` | Gemini CLI |
| `.github/copilot-instructions.md` | symlink → `../AGENTS.md` | GitHub Copilot |
| `.agents/` | real directory | shared agent configuration (skills, commands, settings) |
| `.claude/` | symlink → `.agents/` | Claude Code |

To wire up another tool, add its expected path as a relative symlink, then record it in the table
above and in `scripts/just/agents.just`:

```bash
ln -s AGENTS.md QWEN.md          # file alias
ln -s .agents .qwen              # directory alias
```

`just agents-link` recreates every alias idempotently. Run it after cloning if your platform or
git configuration did not materialise the symlinks — notably **on Windows, where git checks out
symlinks as plain text files unless `core.symlinks` is enabled**:

```bash
git config core.symlinks true    # then re-run: just agents-link
```

See `.agents/README.md` for the contents of that directory.
