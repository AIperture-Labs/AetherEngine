# AetherEngine

AetherEngine is a lightweight, modular game engine written in C/C++23, targeting Vulkan for
high-performance real-time rendering. It is built so that projects only pull in the systems they
need, with a plugin-based architecture for custom modules, an asset pipeline for models, textures
and audio, and first-class support for profilers and GPU debuggers such as Tracy and RenderDoc.

The name refers to the classical *aether*, the pure upper air, and sets the three principles every
change should respect:

- **Purity** — clean, efficient, lightweight code.
- **Freedom** — modular design; systems stay decoupled and optional.
- **Performance** — real-time rendering is the target; costs are measured, not assumed.

---

## 1. Project at a glance

| Aspect | Value |
| --- | --- |
| Languages | C 23 and C++ 23, strict ISO (no compiler extensions) |
| Build system | CMake, **presets only**, generator Ninja |
| Task runner | [`just`](https://just.systems/man/en/) |
| Dependencies | git submodules under `extern/`, pinned to AIperture-Labs forks |
| Platforms | Cross-platform: Windows, Linux and macOS, with MSVC, clang-cl and clang toolchains |
| Toolchain extras | clangd, clang-format, clang-tidy, Vulkan SDK, uv + Python |

Required tool and SDK versions are defined by the build files (`cmake_minimum_required()`,
`find_package()` calls, `cmake/Config.cmake`), never by this document — read them there.

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
.agents/            Agent configuration: skills, commands, settings (.claude/ points here)
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

Recipes annotated with an OS attribute (`[windows]`, `[linux]`, …) only exist on that platform.

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

### Commit messages

Commit messages **must** follow Conventional Commits v1.0.0.
Specification: <https://www.conventionalcommits.org/en/v1.0.0/>

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

Required by the specification:

- A `type` prefix, followed by an optional `scope` in parentheses, an optional `!`, then a
  mandatory `: ` (colon and space) and the description.
- `feat` for a new feature, `fix` for a bug fix. Other types are allowed and carry no semantic
  versioning meaning.
- A breaking change is signalled by `!` before the colon, by a `BREAKING CHANGE: <reason>` footer,
  or both: `feat(cmake)!: drop the MSVC presets`.
- Body and footers are each separated from what precedes them by one blank line.

Project conventions on top of it:

- Use one of these types only: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`,
  `chore`, `revert`.
- `scope` is lowercase and names the affected area: `cmake`, `submodules`, `glm`, `yasm`, `agents`.
- The description is English, imperative, lowercase, with no trailing period.
- The same convention applies to **pull request titles**, so that a squash merge produces a valid
  commit message.

Examples taken from this repository's history:

```
feat(cmake): add UV package manager integration module
fix(cmake): correct variable name for force download in gh_release_download function
chore(submodules): switch submodules to AIperture-Labs forks
docs(cmake): clarify comment for GLM library
refactor(cmake): simplify Dependencies.cmake using helper module
```

The history also contains non-compliant subjects: untyped ones, a misspelled `chores:` type, and
French ones (see §2). They predate this file: do not imitate them, and do not rewrite history to
fix them.

### Branches and pull requests

- Branches: `feature/<topic>`, `fix/<topic>`, `examples/<topic>`, `wip/<topic>`. Work on a branch,
  never commit directly to `main`.
- Changes land on `main` through pull requests.

### Submodules

Submodules point at **AIperture-Labs forks** (`origin` = fork, `upstream` = original project).
Pinned versions are recorded in `configs/submodules.toml`. To change a dependency: commit in the
fork, push it, then bump the submodule pointer here in its own `chore(<name>):` commit.

---

## 8. Hard rules

Do not, without an explicit request from the maintainer:

1. **Edit anything under `extern/`.** Those are submodules of separate fork repositories.
2. Commit generated or downloaded content: `out/`, `.cache/`, `runtimes/`,
   `compile_commands.json`, `CMakeUserPresets.json`, `configs/runtimes/uv/uv.toml`.
3. Push to `main`, force-push, rewrite history, or merge branches.
4. Rename or restructure `CMakePresets.json` entries — the preset naming scheme is the project's
   stable interface for building, and is referenced from documentation and by habit.
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

- `cmake/Dependencies.cmake` hardcodes the Windows uv archive (`uv-x86_64-pc-windows-msvc.zip`)
  instead of selecting the archive for the host platform.
- `cmake/Config.cmake` declares the option `GIT_SUBMODULE_UPDATE`, while `cmake/Dependencies.cmake`
  tests `GIT_SUBMODULES_UPDATE` (plural) — so the guard is always false and
  `git_submodules_update()` never runs from the build.
- Standards disagree: CMake sets C/C++ **23**, while `.clang-format` declares `Standard: c++20`
  and `.clangd` adds `-std=c++20`.
- `.clangd` hardcodes an absolute, Windows-only Vulkan SDK include path.
- `Config.cmake` defines `AETHER_ENGINE_ASSETS_DIR` (and shaders/textures under it) but `assets/`
  does not exist.
- `Dependencies.cmake` hardcodes the uv version and `FORCE_DOWNLOAD` instead of using
  `AETHER_ENGINE_UV_VERSION` and the `FORCE_DOWNLOAD_DEPS` option.
- `README.md` still contains `# TODO` for the project structure and a FIXME on the test command.
- In `scripts/just/clean.just`, `clean-runtimes` depends on `clean-uv` and `clean-python`, which
  only have a `[windows]` variant, so the justfile fails to parse on any other platform.
- The `[windows]` clean recipes in `scripts/just/clean.just` use `rm -Force <dir>` without
  `-Recurse`, which PowerShell refuses on a non-empty directory. `just clean-all` therefore does
  not fully clean on Windows.

---

## 10. Working agreement

- Read before writing. This is a small, opinionated, heavily commented tree — match the
  surrounding style instead of importing conventions from elsewhere.
- **Every change targets all platforms.** Keep code, CMake and scripts portable; isolate anything
  platform-specific behind an explicit guard (`if(WIN32)`, `#if defined(_WIN32)`, a just OS
  attribute, …) and provide the other platforms' path alongside it.
- **Several agents may work on this repository in parallel.** Work in a git worktree or a
  dedicated branch, keep the change scoped, and do not touch unrelated files.
- State plainly what you verified and what you assumed. If a command was not run, say so.
- When the request and the code disagree, say so in one or two sentences and continue with the
  request, flagging the assumption.
