# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item

# Recreate the per-tool agent aliases described in AGENTS.md, section 11.
#
# AGENTS.md and .agents/ are the single source of truth; every tool-specific path is a link
# pointing at them. This script is idempotent: existing links are replaced, and real files or
# directories are never clobbered.
#
# Notes for Windows:
#   - Git only materialises the committed symlinks when `git config core.symlinks true` is set.
#     Without it, CLAUDE.md is checked out as a text file containing "AGENTS.md" and this script
#     will report it as a real file to remove by hand.
#   - Creating a file symbolic link requires Developer Mode or an elevated shell. Directory
#     aliases use a junction instead, which needs no elevation.
#   - Link targets are absolute, so re-run this script after moving or renaming the repository.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

function New-AgentAlias {
    param(
        [Parameter(Mandatory = $true)][string] $Target,
        [Parameter(Mandatory = $true)][string] $Alias,
        [switch] $AsDirectory
    )

    $existing = Get-Item -LiteralPath $Alias -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType) {
            Remove-Item -LiteralPath $Alias -Force
        }
        elseif ($existing.PSIsContainer) {
            Write-Host "  skip  $Alias is a real directory: move its contents into $Target, remove it, then re-run"
            return
        }
        else {
            Write-Host "  skip  $Alias is a real file: remove it by hand, then re-run"
            return
        }
    }

    $itemType = if ($AsDirectory) { 'Junction' } else { 'SymbolicLink' }
    New-Item -ItemType $itemType -Path $Alias -Target (Join-Path $repoRoot $Target) | Out-Null
    Write-Host "  new   $Alias -> $Target ($itemType)"
}

Push-Location $repoRoot
try {
    if (-not (Test-Path -LiteralPath 'AGENTS.md' -PathType Leaf)) {
        throw "AGENTS.md not found in $repoRoot"
    }

    Write-Host "Agent aliases in $repoRoot"

    # File aliases -> AGENTS.md
    New-AgentAlias -Target 'AGENTS.md' -Alias 'CLAUDE.md'
    New-AgentAlias -Target 'AGENTS.md' -Alias 'GEMINI.md'
    New-AgentAlias -Target 'AGENTS.md' -Alias '.github\copilot-instructions.md'

    # Directory aliases -> .agents\
    New-AgentAlias -Target '.agents' -Alias '.claude' -AsDirectory
}
finally {
    Pop-Location
}
