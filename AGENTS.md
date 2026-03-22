# CLI Tools Skill — Agent Index

## Repo Structure

```
├── skills/cli-tools/          # Skill definition (SKILL.md) and core logic
│   ├── SKILL.md               # Skill metadata, triggers, workflows
│   ├── catalog/               # 74+ tool definitions (JSON per tool)
│   ├── scripts/               # Installation, audit, detection scripts
│   │   ├── install_tool.sh    # Install/update/uninstall tools
│   │   ├── auto_update.sh     # Batch update package managers
│   │   ├── check_environment.sh # Environment audit
│   │   └── detect_project_type.sh
│   └── references/            # Binary maps, project requirements, preferred tools
├── evals/                     # Skill evaluation tests
├── Build/                     # Build artifacts
├── hooks/                     # Git hooks
├── .github/workflows/         # CI: lint, release, auto-merge-deps, harness-verify
├── composer.json              # Composer package (ai-agent-skill type)
├── docs/                      # Architecture and execution plans
│   └── ARCHITECTURE.md
└── scripts/                   # Repo-level scripts (verify-harness.sh)
```

## Commands

No Makefile or npm scripts. Key commands:

- `scripts/install_tool.sh <tool> install` — install a tool from the catalog
- `scripts/auto_update.sh` — batch update all managed tools
- `scripts/check_environment.sh audit .` — audit project environment
- `scripts/detect_project_type.sh` — detect project type from files
- `bash scripts/verify-harness.sh --format=text --status` — verify harness maturity

## Rules

- Tool catalog entries live in `catalog/<tool>.json` — one JSON file per tool
- Installation priority: GitHub Release Binary > Cargo > UV/Pip > NPM > Apt/Brew
- User-level paths (`~/.local/bin`, `~/.cargo/bin`) preferred over system-level
- jq is a hard dependency (auto-installed if missing); Bash 4+ required
- When adding tools: update `references/binary_to_tool_map.md` if binary name differs from tool name
- Split license: MIT for code, CC-BY-SA-4.0 for content

## References

- [skills/cli-tools/SKILL.md](skills/cli-tools/SKILL.md) — skill definition, triggers, workflows
- [skills/cli-tools/references/](skills/cli-tools/references/) — binary maps, project requirements, preferred tools
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — architecture overview
- [README.md](README.md) — installation and usage guide
