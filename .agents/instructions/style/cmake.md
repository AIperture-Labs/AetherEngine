# CMake style

Applies to every `CMakeLists.txt` and `.cmake` file in the repo, never to
`extern/`.

- `cmake_minimum_required(VERSION 3.31...4.1)` at the top level only.
- Four spaces for indentation, no tabs. Lowercase commands, uppercase
  variables and keywords.
- Header: copyright line, then a `# Docs:` block listing the references used.
- A module's `CMakeLists.txt` opens with a banner naming its target, a short
  comment on its role, and `message(STATUS "Configuring ...")`.
- Targets are `aether_<module>`, with an alias `AetherEngine::<module>`; link
  and consume the alias.
- Target-based CMake only: `target_*` commands with explicit
  `PUBLIC`/`PRIVATE`/`INTERFACE`, never directory-wide `include_directories`,
  `add_definitions` or `link_libraries`.
- List sources explicitly, one per line; no `file(GLOB)`.
- Every first-party target calls `enable_warnings(<target>)`
  (`cmake/helpers/CompilerWarnings.cmake`).
- Shared code goes in `cmake/helpers/` (functions) or `cmake/modules/` (find
  and config modules), included by name, not by path.
- Hide symbols by default on libraries and export through
  `generate_export_header`.
- Comments explain why, not what.
