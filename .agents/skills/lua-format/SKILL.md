---
name: lua-format
description: Format Lua code with StyLua. Use after editing Lua files, before committing, or when asked to format Lua.
---

# Lua format

Run from the project root; the style comes from `stylua.toml`.

Check without modifying (non-zero exit status when something is off):

```bash
stylua --check <files>
```

Apply in place:

```bash
stylua <files>
```

Format only the files you changed, never `extern/`.
