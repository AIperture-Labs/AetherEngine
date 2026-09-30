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
ln -s AGENTS.md QWEN.md                              # file alias
ln -s .agents .qwen                                  # directory alias
ln -s ../AGENTS.md .github/copilot-instructions.md   # nested alias, target relative to its dir
```

The nested example is how GitHub Copilot would be wired back in: `.github/` was removed from this
repository, so the alias is not created by default.

Then commit the link and record it in the table above and in the equivalent table in
`../AGENTS.md`.

## Windows

The links are committed, so git recreates them on clone and checkout. On Windows, however, git
checks symlinks out as plain text files unless symlink support is enabled: `CLAUDE.md` then
contains the string `AGENTS.md` and agents read nothing useful. Enable it (Developer Mode is also
required), then restore the aliases from the index:

```powershell
git config core.symlinks true
git checkout -- CLAUDE.md GEMINI.md .claude
```
