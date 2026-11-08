# AI Agents Instructions

## The Eleven Commandments

For every agent, on every task:

1. Thou shalt state thy assumptions, and ask when unsure.
2. Thou shalt present every interpretation of a request, and never pick one
   silently.
3. Thou shalt propose the simpler solution when one exists, even against the
   user's idea.
4. Thou shalt stop and ask when something is unclear, saying exactly what.
5. Thou shalt do only what is asked: no hidden feature, no extra option or
   flexibility, except what a `TODO-AI` comment asks (see the
   [todo-ai](.agents/skills/todo-ai/SKILL.md) skill).
6. Thou shalt not handle errors that cannot happen.
7. Thou shalt be concise and compact, in writing and in code, without
   repetition, and rewrite in 50 lines what thou wrote in 200.
8. Thou shalt let the code explain itself, without an avalanche of comments.
9. Thou shalt follow the coding rules strictly. Where none exists, thou shalt
   neither invent one nor mix styles, but ask, and the rule gets added to
   `.agents/`.
10. Thou shalt not touch code next to the change, nor refactor working code,
    unless that is the request.
11. Thou shalt stay agnostic: nothing specific to a person or a machine
    (name, email, path, host) is hardcoded; read it from the configuration.

## Security

Never hardcode a login, password, token, key or any other secret, in code,
configs, docs, commits, PRs or issues. Read it from the environment or a
git-ignored file (e.g. `.env`), and commit only a placeholder file
(`.env.example`). Don't print or repeat a secret in a reply, and don't open
a secret file unless the task needs it. If a secret leaks, stop and tell the
user: it must be rotated, deleting the commit is not enough.

## Language

English is the language of the repo: code, comments, identifiers, docs,
commits and PRs. Interactive exchanges with the user use the user's language.

## Repository Workflow

Branches (`main`, feature branches), worktrees, commits, pull requests,
releases and tracking: read
[repo-workflow.md](.agents/instructions/repo-workflow.md) before any git,
branch, commit, PR or issue operation.

## Repository Layout

Where files and modules live: read
[.agents/instructions/repo-layout.md](.agents/instructions/repo-layout.md) before
creating a file or a directory.

## Coding Workflow

Every code change follows the same loop; a task is done only when one pass
goes through with everything green:

1. Read the matching [style guide](#style-guide).
2. Code the feature, or the fix (a bug starts with a test that reproduces
   it), following the guide.
3. Lint, with the language's lint [skill](#skills) (`<language>-lint`).
4. Test, with the language's test skill (`<language>-test`).
5. If any step fails, fix and restart from step 2; otherwise, move on.

If a language has no lint or test skill, say so instead of skipping the step.

For a task of more than one step, state a short plan first, each step with
its check:

1. [Step] → verify: [check]
2. [Step] → verify: [check]

## Style Guide

Language-specific rules live in `.agents/instructions/style/<language>.md`;
read the matching one before editing a file in that language.

## Header Comment

Every source or config file starts with a header comment (copyright, license
and, if useful, documentation), in the file's comment syntax and after the
shebang if there is one. Docs and Markdown, generated files and files that
can't hold comments have none.

- A file starts with the organization line and the license identifier
  (the project is under the [MPL-2.0](LICENSE)):
  `Copyright (c) <year> AIperture-Labs <xavier.beheydt@gmail.com>` then
  `SPDX-License-Identifier: MPL-2.0`.
- Then, if useful, a `Doc:` line linking the documentation of the format or
  the tool the file configures.
- `<year>` is the current year.

Example, in a C++ file:

```cpp
// Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
// SPDX-License-Identifier: MPL-2.0
```

## Skills

Procedures live in `.agents/skills/<name>/SKILL.md`; use the matching one
instead of improvising the command:

- [cmake-configure](.agents/skills/cmake-configure/SKILL.md): configure the
  build through a preset.
- [cmake-build](.agents/skills/cmake-build/SKILL.md): build a preset or a
  target.
- [cpp-format](.agents/skills/cpp-format/SKILL.md): format with clang-format.
- [cpp-lint](.agents/skills/cpp-lint/SKILL.md): lint with clang-tidy.
- [cpp-test](.agents/skills/cpp-test/SKILL.md): build and run the tests
  (doctest, CTest), or add some.
- [lua-format](.agents/skills/lua-format/SKILL.md): format with StyLua.
- [lua-lint](.agents/skills/lua-lint/SKILL.md): lint with luacheck.
- [lua-test](.agents/skills/lua-test/SKILL.md): run tests with busted.
- [python-deps](.agents/skills/python-deps/SKILL.md): install, add or update
  dependencies (uv).
- [python-lint](.agents/skills/python-lint/SKILL.md): lint with ruff.
- [python-test](.agents/skills/python-test/SKILL.md): run tests with pytest.
- [todo-ai](.agents/skills/todo-ai/SKILL.md): resolve the `TODO-AI` comments,
  grouped, one subagent per group.
- [vibe](.agents/skills/vibe/SKILL.md): delegate a bounded read-only task to
  Mistral Vibe.

## New language or feature

Introducing a new language adds both a style guide
(`.agents/instructions/style/<language>.md`) and its skills
(`.agents/skills/<language>-format`, `-lint`, `-test`).

Introducing a new tool or feature (build system, CI, runtime…) adds its
skill (`.agents/skills/<tool>-<action>`) and, if it changes where files
live, updates [repo-layout.md](.agents/instructions/repo-layout.md).

Each addition is listed in [Skills](#skills) in the same change.
