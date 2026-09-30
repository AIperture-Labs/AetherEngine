---
name: format
description: Format C and C++ sources with the repository's clang-format configuration. Use after editing C/C++ files, before committing, or when asked to format code or fix formatting.
---

# Format

The style is defined by `.clang-format` at the repository root. Never edit that file to make code
pass.

## 1. Select the files

Format only the files you changed, never the whole tree:

```bash
git diff --name-only --diff-filter=ACMR HEAD -- '*.c' '*.h' '*.cpp' '*.hpp' '*.cc' '*.cxx' '*.ixx' '*.cppm'
```

Add `--cached` to limit the list to staged files. Files under `extern/` are never formatted.

## 2. Check or apply

Check without modifying (non-zero exit status when something is off):

```bash
clang-format --dry-run --Werror <files>
```

Apply in place:

```bash
clang-format -i <files>
```

Piping the file list, per shell:

```bash
# bash / zsh
files=$(git diff --name-only --diff-filter=ACMR HEAD -- '*.cpp' '*.hpp')
[ -n "$files" ] && clang-format -i $files
```

```powershell
# PowerShell
git diff --name-only --diff-filter=ACMR HEAD -- '*.cpp' '*.hpp' | ForEach-Object { clang-format -i $_ }
```

## 3. Keep the diff clean

- Do not reformat code you did not otherwise touch.
- If formatting a changed file also reshapes large untouched regions, mention it rather than
  committing a noisy diff silently.

## Report

List the files formatted, or those failing `--dry-run --Werror`.
