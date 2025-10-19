# Automation Agents

PowerShell automation agents for research, repository management, and development workflow.

## Available Agents

### GitHub & Deployment
- **enable_github_pages.ps1** - Automated GitHub Pages configuration via API
- **test_codex_mcp.ps1** - Test codex MCP integration

### Research Tools
- **research_agent.ps1** - Online research tool (arXiv + web search)
- **extract_scientist_works.ps1** - Extract complete works of scientists
- **get_ece_papers.ps1** - ECE theory paper access guide generator
- **download_ece_papers.ps1** - ECE paper download automation

### Development Environment
- **add_codex_to_path.ps1** - Codex CLI PATH configuration
- **fix_codex_extension.ps1** - Fix codex extension issues
- **fix_codex_timeout.ps1** - Fix codex timeout problems

### Utilities
- **list_agents.ps1** - Display all available agents with details

---

## Usage

All agents are globally accessible via PATH. Run from any directory:

```powershell
# Enable GitHub Pages
.\enable_github_pages.ps1 -Owner "username" -Repo "repository"

# Research a topic
.\research_agent.ps1 -Query "quantum consciousness"

# List all agents
.\list_agents.ps1
```

## Features

- **Error Handling:** Built-in try-catch blocks
- **Colored Output:** Professional console formatting
- **Parameterized:** Flexible command-line arguments
- **Documented:** Complete help documentation

---

**Total Agents:** 10 automation scripts
**Platform:** Windows PowerShell 5.1+
**Last Updated:** October 19, 2025
