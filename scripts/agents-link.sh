#!/usr/bin/env sh
# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html

# Recreate the per-tool agent aliases described in AGENTS.md, section 11.
#
# AGENTS.md and .agents/ are the single source of truth; every tool-specific path is a relative
# symlink pointing at them. This script is idempotent: correct links are left alone, stale links
# are replaced, and real files or directories are never clobbered.

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd -- "$repo_root"

# link <target> <alias_path>
#
# <target> is interpreted relative to the directory containing <alias_path>, as symlinks are.
link() {
    target=$1
    alias_path=$2

    if [ -L "$alias_path" ]; then
        if [ "$(readlink -- "$alias_path")" = "$target" ]; then
            printf '  ok    %s -> %s\n' "$alias_path" "$target"
            return 0
        fi
        rm -- "$alias_path"
    elif [ -d "$alias_path" ]; then
        printf '  skip  %s is a real directory: move its contents into %s, remove it, then re-run\n' \
            "$alias_path" "$target"
        return 0
    elif [ -e "$alias_path" ]; then
        printf '  skip  %s is a real file: remove it by hand, then re-run\n' "$alias_path"
        return 0
    fi

    ln -s -- "$target" "$alias_path"
    printf '  new   %s -> %s\n' "$alias_path" "$target"
}

if [ ! -f AGENTS.md ]; then
    printf 'error: AGENTS.md not found in %s\n' "$repo_root" >&2
    exit 1
fi

printf 'Agent aliases in %s\n' "$repo_root"

# File aliases -> AGENTS.md
link AGENTS.md CLAUDE.md
link AGENTS.md GEMINI.md

# Directory aliases -> .agents/
link .agents .claude
