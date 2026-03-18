---
name: cli-tools
description: "Use when ANY command fails with 'command not found', when installing CLI tools (ripgrep, fd, jq, yq, bat, etc.), auditing project environments, or batch-updating tools. Triggers on: command not found, install tool, missing binary, environment audit, update tools, which, apt install, brew install."
license: "(MIT AND CC-BY-SA-4.0)"
compatibility: "Requires bash, common package managers."
metadata:
  version: "1.4.6"
  repository: "https://github.com/netresearch/cli-tools-skill"
  author: "Netresearch DTT GmbH"
allowed-tools:
  - "Bash(apt:*)"
  - "Bash(brew:*)"
  - "Bash(npm:*)"
  - "Bash(pip:*)"
  - "Read"
  - "Write"
---

# CLI Tools Skill

Manage CLI tool installation, environment auditing, and updates.

## Triggers

**Reactive** (auto-install):
```
bash: <tool>: command not found
```

**Proactive** (audit): "check environment", "what's missing", "update tools"

## Capabilities

1. **Reactive**: Auto-install missing tools on "command not found"
2. **Proactive**: Audit project dependencies and tool versions
3. **Maintenance**: Batch update all managed tools

## Preferred Tools

Modern alternatives for speed and correctness. See `references/preferred-tools.md` for full table.

Key replacements: `grep`->`rg`, `find`->`fd`, JSON->`jq`, YAML->`yq`, `diff`->`difft`, `cat`->`bat`, benchmarks->`hyperfine`, security->`semgrep`.

## Workflows

### Missing Tool Resolution

1. Diagnose: check if tool exists elsewhere (`which`, `command -v`, `type -a`)
2. Install: lookup in `references/binary_to_tool_map.md`, run `scripts/install_tool.sh <tool> install`
3. Verify: confirm with `which <tool>` and `<tool> --version`, retry original command

See `references/resolution-workflow.md` for detailed diagnostic and verification steps.

### Environment Audit

```bash
scripts/check_environment.sh audit .
```

## Scripts

| Script | Purpose |
|--------|---------|
| `install_tool.sh` | Install/update/uninstall tools |
| `auto_update.sh` | Batch update package managers |
| `check_environment.sh` | Audit environment |
| `detect_project_type.sh` | Detect project type |

## Catalog (74 tools)

Core CLI, Languages, Package Managers, DevOps, Linters, Security, Git Tools

## References

| Reference | Use when... |
|-----------|-------------|
| `references/binary_to_tool_map.md` | Mapping binary names to catalog entries |
| `references/project_type_requirements.md` | Checking what tools a project type needs |
| `references/preferred-tools.md` | Detailed usage patterns and examples for preferred tools |
| `references/resolution-workflow.md` | Full diagnostic/install/verify workflow for missing tools |
| `references/troubleshooting.md` | PATH issues, permission problems, installation blocked |

---

> **Contributing:** https://github.com/netresearch/cli-tools-skill
