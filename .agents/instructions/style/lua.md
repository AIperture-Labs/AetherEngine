# Lua style

Applies to every Lua file in the repo: the game scripting runtime and its
tests. Never to `extern/`.

- Lua 5.4 syntax, unless the embedded runtime chosen for the engine says
  otherwise; then this page changes with it.
- Four spaces for indentation, no tabs, lines up to 120 characters: same as
  C++.
- `local` by default; a global is a bug. A module is a local table returned at
  the end of the file.
- Names: `snake_case` for functions, variables and modules; `PascalCase` for
  classes; `UPPER_SNAKE_CASE` for constants.
- Double quotes for strings, except to avoid escaping.
- One line for a short statement is fine: `if not items then return end`.
- Comments in English, explaining why. Annotate public functions with
  LuaLS-style `---@param` / `---@return`.
- Config at the repo root: `stylua.toml` (formatter), `.luacheckrc` (linter),
  `.busted` (tests). They are added with the first Lua file and never edited
  to make code pass.
- Tests are `*_spec.lua` files under `tests/`, with busted.
