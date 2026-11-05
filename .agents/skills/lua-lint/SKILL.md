---
name: lua-lint
description: Lint Lua code with luacheck. Use before committing Lua changes or when asked for static analysis of Lua.
---

# Lua lint

Run `luacheck <files>` from the project root. The rules come from
`.luacheckrc`; don't pass rule flags or override them.

Fix the finding rather than suppressing it. A `-- luacheck: ignore <code>` is
acceptable only with the specific code and a short reason. Never lint
`extern/`.
