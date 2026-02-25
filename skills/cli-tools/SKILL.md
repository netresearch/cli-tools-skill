---
name: cli-tools
description: "Use when commands fail with 'command not found', when installing missing CLI tools, when auditing project environments, or when batch-updating managed tools."
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

When multiple tools can accomplish the same task, prefer the modern alternative for speed, correctness, and simpler syntax.

| Instead of... | Use... | Why | Skill |
|--------------|--------|-----|-------|
| `grep` on code | `rg` (ripgrep) | 10x faster, respects .gitignore | file-search |
| `find` | `fd` | 5x faster, simpler syntax | file-search |
| `grep` on PDFs/docs | `rga` (ripgrep-all) | Searches inside PDFs, archives | file-search |
| `cloc` / `wc -l` | `tokei` or `scc` | 10-100x faster, accurate | file-search |
| `grep`/`awk` on JSON | `jq` | Structured extraction | data-tools |
| `sed`/`awk` on YAML | `yq` | Syntax-aware, preserves comments | data-tools |
| `sed` on JSON | `jq` or `dasel` | Correct escaping | data-tools |
| `awk`/Python on CSV | `qsv` | Handles quoting, 100x faster | data-tools |
| `sed` on TOML/XML | `dasel` | Universal format support | data-tools |
| `diff` on code | `difft` (difftastic) | Syntax-aware diffs | git-workflow |
| `git commit --fixup` | `git absorb` | Auto-detects parent commit | git-workflow |
| Manual security grep | `semgrep --config auto` | AST-aware, OWASP rulesets | security-audit |
| `time` for benchmarks | `hyperfine` | Statistical analysis, comparison | (this skill) |
| `cat` for viewing | `bat` | Syntax highlighting, git integration | - |

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
