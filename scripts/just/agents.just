# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://just.systems/man/en/

# Recreate the per-tool agent alias links (see AGENTS.md, section 11)
[unix]
agents-link:
    sh scripts/agents-link.sh

# Recreate the per-tool agent alias links (see AGENTS.md, section 11)
[windows]
agents-link:
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agents-link.ps1

# Show what every agent alias currently resolves to
[unix]
agents-status:
    ls -l AGENTS.md CLAUDE.md GEMINI.md .github/copilot-instructions.md .agents .claude

# Show what every agent alias currently resolves to
[windows]
agents-status:
    Get-Item AGENTS.md, CLAUDE.md, GEMINI.md, .github/copilot-instructions.md, .agents, .claude | Select-Object Name, LinkType, Target
