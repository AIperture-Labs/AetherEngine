# CMake coding rules

Applies to every `CMakeLists.txt` and `.cmake` file in the repo, never to
`extern/`.

- `cmake_minimum_required(VERSION 3.31...4.1)` at the top level only.
- Indent with spaces, 4 per level; lines of 120 columns at most (also in
  `.editorconfig`). A command that does not fit takes one argument per
  line, with the closing parenthesis on its own line.
- Lowercase commands, uppercase variables and keywords.
- Functions are named `aether_<verb>_<object>`: CMake functions are global,
  and the prefix keeps them from colliding with those of a project that
  consumes the engine.
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
- A module lists the targets it links in the `PUBLIC` and `PRIVATE`
  arguments of the function that declares it, not in a separate
  `target_link_libraries()`.
- `target_*` commands only, never their directory-wide forms
  (`include_directories`, `add_compile_definitions`, `link_libraries`…).
- List sources explicitly, one per line; no `file(GLOB)`.
- A first-party target that no helper declares calls
  `aether_enable_warnings(<target>)` (`cmake/helpers/CompilerWarnings.cmake`)
  and `aether_enable_coverage(<target>)` (`cmake/helpers/Coverage.cmake`).
- Shared code goes in `cmake/helpers/` (functions) or `cmake/modules/` (find
  and config modules), included by name, not by path.
- Build options (`option()`, `set(... CACHE ...)`) are declared in
  `cmake/Config.cmake`, never in a helper.
