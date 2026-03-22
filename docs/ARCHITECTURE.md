# Architecture — CLI Tools Skill

## Purpose

The CLI Tools Skill provides AI agents with the ability to automatically detect missing CLI tools, install them via optimal package managers, and audit project environments for tool completeness.

## Component Map

```
┌─────────────────────────────────────────────────┐
│  SKILL.md (entry point)                         │
│  Triggers: "command not found", "audit tools"   │
└──────────┬──────────────────────────────────────┘
           │
     ┌─────┴─────┐
     │  Scripts   │
     └─────┬─────┘
           │
  ┌────────┼────────────┬──────────────┐
  ▼        ▼            ▼              ▼
install  check_       detect_       auto_
_tool.sh environment  project_type  update.sh
           .sh         .sh
  │
  ▼
┌─────────────┐     ┌──────────────┐
│  Catalog/   │     │  References/ │
│  74+ JSON   │◄────│  binary map  │
│  tool defs  │     │  project req │
└─────────────┘     └──────────────┘
```

## Key Components

### Catalog (`catalog/*.json`)
Each JSON file defines a single tool: name, binary name, version detection command, and ordered list of installation methods with their commands.

### Scripts (`scripts/`)
- **install_tool.sh** — Core installer. Looks up tool in catalog, selects best installation method by priority, executes install, verifies with `--version`.
- **check_environment.sh** — Scans project files, detects project type, checks for required and recommended tools.
- **detect_project_type.sh** — Examines marker files (package.json, go.mod, Cargo.toml, etc.) to determine project type.
- **auto_update.sh** — Iterates managed tools and runs update commands per package manager.

### References (`references/`)
Lookup tables that map binary names to catalog entries and define per-project-type tool requirements.

## Integration Points

- **AI Agent** — Reads SKILL.md, invokes scripts via Bash tool
- **Package Managers** — apt, brew, npm, pip/uv, cargo, composer
- **GitHub Releases** — Direct binary downloads for supported tools
- **Composer** — Installable as a PHP package via `netresearch/composer-agent-skill-plugin`

## Data Flow

1. Agent encounters "command not found" or user requests audit
2. SKILL.md triggers skill activation
3. Script looks up tool in catalog JSON
4. Installation method selected by priority
5. Tool installed to user-level path
6. Verification via `which` + `--version`
