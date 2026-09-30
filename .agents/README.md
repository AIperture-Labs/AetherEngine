# .agents/

Shared, tool-agnostic configuration for AI coding agents working on this repository.

The instructions themselves live in [`../AGENTS.md`](../AGENTS.md). This directory holds the
*machine-readable* side: per-tool settings, reusable prompts, skills and commands.

## Principle

One real file or directory, one symlink per tool. Content is never duplicated, so a tool added
tomorrow inherits everything written today.

| Path | Kind | Read by |
| --- | --- | --- |
| `AGENTS.md` | real file | the cross-tool standard (Codex, Cursor, Aider, Jules, …) |
| `CLAUDE.md` | symlink → `AGENTS.md` | Claude Code |
| `GEMINI.md` | symlink → `AGENTS.md` | Gemini CLI |
| `.github/copilot-instructions.md` | symlink → `../AGENTS.md` | GitHub Copilot |
| `.agents/` | real directory | this directory |
| `.claude/` | symlink → `.agents/` | Claude Code |

## Layout

```
.agents/
  README.md            This file
  commands/            Reusable prompts / slash commands (create on demand)
  skills/              Skill definitions (create on demand)
  settings.json        Shared tool settings, committed (create on demand)
  settings.local.json  Per-developer overrides (gitignored)
  worktrees/           Scratch git worktrees created by agents (gitignored)
```

Anything a specific tool expects under its own dotfolder goes here and is reached through the
symlink. For example Claude Code reads `.claude/skills/`, which resolves to `.agents/skills/`.

## Adding a tool

```bash
ln -s AGENTS.md QWEN.md          # file alias
ln -s .agents .qwen              # directory alias
```

Then record it in the table above, in the equivalent table in `../AGENTS.md`, and in the
`agents-link` recipe in `../scripts/just/agents.just`.

## Recreating the links

```bash
just agents-link
```

The recipe is idempotent: it replaces existing links and refuses to clobber a real file or a
non-empty real directory.

### Windows

Git does not materialise symlinks on Windows unless symlink support is enabled. Without it,
`CLAUDE.md` is checked out as a plain text file containing the string `AGENTS.md`, and agents read
nothing useful. Enable it once, then recreate the links:

```powershell
git config core.symlinks true
just agents-link
```

Creating symbolic links on Windows additionally requires Developer Mode or an elevated shell. The
`agents-link` recipe falls back to directory junctions, which need no elevation, for the directory
aliases.
