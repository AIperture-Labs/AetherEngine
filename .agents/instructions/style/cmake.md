# CMake style

Applies to every `CMakeLists.txt` and `.cmake` file in the repo, never to
`extern/`.

- `cmake_minimum_required(VERSION 3.31...4.1)` at the top level only.
- Four spaces for indentation, no tabs. Lowercase commands, uppercase
  variables and keywords.
- Header: copyright line, then a `# Docs:` block listing the references used.
- A module's `CMakeLists.txt` opens with a banner naming its target, a short
  comment on its role, and `message(STATUS "Configuring ...")`.
- An engine module is declared with `aether_add_engine_module(<module> ...)`
  (`cmake/helpers/EngineModule.cmake`), never with `add_library`: it gives
  the target `aether_<module>`, the alias `AetherEngine::<module>` (link and
  consume the alias), hidden symbols with the export macro
  `AETHER_<MODULE>_API`, warnings as errors and coverage.
- `aether_add_module()` (`cmake/helpers/AetherModule.cmake`) is the public
  function, for content and plugins outside the engine tree: it uses no other
  helper of the engine, and nothing specific to the engine's own code goes in
  it.
- Target-based CMake only: `target_*` commands with explicit
  `PUBLIC`/`PRIVATE`/`INTERFACE`, never directory-wide `include_directories`,
  `add_definitions` or `link_libraries`.
- List sources explicitly, one per line; no `file(GLOB)`.
- A first-party target that no helper declares calls `enable_warnings(<target>)`
  (`cmake/helpers/CompilerWarnings.cmake`) and `enable_coverage(<target>)`
  (`cmake/helpers/Coverage.cmake`).
- Shared code goes in `cmake/helpers/` (functions) or `cmake/modules/` (find
  and config modules), included by name, not by path.
- Comments explain why, not what.
