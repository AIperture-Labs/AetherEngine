---
name: cpp-format
description: Format C and C++ sources with the repository's clang-format configuration. Use after editing C/C++ files, before committing, or when asked to format code or fix formatting.
---

# Format

The style is defined by `.clang-format` at the repository root.

## 1. Select the files

List the files of the change:

```bash
git diff --name-only --diff-filter=ACMR HEAD -- '*.cpp' '*.hpp'
```

Add `--cached` to limit the list to staged files.

## 2. Check or apply

Check without modifying (non-zero exit status when something is off):

```bash
clang-format --dry-run --Werror <files>
```

Apply in place:

```bash
clang-format -i <files>
```

## 3. Keep the diff clean

- Do not reformat code you did not otherwise touch.
- If formatting a changed file also reshapes large untouched regions, mention it rather than
  committing a noisy diff silently.

## Report

List the files formatted, or those failing `--dry-run --Werror`.
