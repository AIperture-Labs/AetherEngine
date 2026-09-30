---
name: lint
description: Run clang-tidy static analysis on C and C++ sources using the project's compile database. Use when asked to lint, run static analysis, or check C++ code quality before a commit or review.
---

# Lint

Checks are configured in `.clang-tidy` at the repository root: `modernize-*` and
`cppcoreguidelines-*`. Warnings are not errors. Never edit `.clang-tidy` to make code pass.

## 1. Have a compile database

clang-tidy needs `compile_commands.json`, which every preset exports into its binary directory. If
`out/build/<preset>/compile_commands.json` is missing, run the `configure` skill first.

## 2. Run

Lint the files you changed, not the whole tree:

```bash
clang-tidy -p out/build/<preset> <files>
```

Prefer `-p out/build/<preset>` over `-p .`: the root `compile_commands.json` is a symlink on some
platforms and a copy on others, so it can be stale.

Apply suggested fixes only when the user asks for it, then review the resulting diff:

```bash
clang-tidy -p out/build/<preset> --fix <files>
```

Files under `extern/` are never linted or fixed.

## 3. Handle findings

- Fix the finding rather than suppressing it.
- A `// NOLINT(<check>)` or `// NOLINTNEXTLINE(<check>)` is acceptable only with the specific check
  name and a short comment explaining why the rule does not apply.

## Report

Group findings by file with `file:line`, the check name, and the message. Say which were fixed and
which remain.
