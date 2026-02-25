---
name: cli-tools
description: "Use when commands fail with 'command not found', when installing missing CLI tools, when auditing project environments, or when batch-updating managed tools."
---

# CLI Tools Skill

Manage CLI tool installation, environment auditing, and updates.

## Capabilities

1. **Reactive**: Auto-install missing tools on "command not found"
2. **Proactive**: Audit project dependencies and tool versions
3. **Maintenance**: Batch update all managed tools

## Preferred Tools

When multiple tools can accomplish the same task, prefer the modern alternative for speed, correctness, and simpler syntax.

| Instead of... | Use... | Why | Skill |
|--------------|--------|-----|-------|
| `grep` on code | `rg` (ripgrep) | 10x faster, respects .gitignore, better regex | file-search |
| `find` | `fd` | 5x faster, simpler syntax, respects .gitignore | file-search |
| `grep` on PDFs/docs | `rga` (ripgrep-all) | Searches inside PDFs, Office, archives, SQLite | file-search |
| `cloc` / `wc -l` | `tokei` or `scc` | 10-100x faster, accurate language detection | file-search |
| `grep`/`awk` on JSON | `jq` | Structured extraction, handles nesting/escaping | data-tools |
| `sed`/`awk` on YAML | `yq` | Syntax-aware, preserves comments and formatting | data-tools |
| `sed` on JSON | `jq` or `dasel` | Correct escaping, handles nested paths | data-tools |
| `awk`/Python on CSV | `qsv` | Handles quoting, headers, 100x faster on large files | data-tools |
| `sed` on TOML/XML | `dasel` | Universal format support, in-place editing | data-tools |
| `diff` on code | `difft` (difftastic) | Syntax-aware, ignores formatting-only changes | git-workflow |
| `git commit --fixup` | `git absorb` | Auto-detects correct parent commit | git-workflow |
| Manual security grep | `semgrep --config auto` | Pre-built OWASP/CWE rulesets, AST-aware | security-audit |
| `time` for benchmarks | `hyperfine` | Statistical analysis, warmup runs, comparison | (this skill) |
| `cat` for viewing | `bat` | Syntax highlighting, line numbers, git integration | - |

### hyperfine - Command Benchmarking

Statistical benchmarking tool. Use instead of ad-hoc `time` measurements.

```bash
# Benchmark a command (10 runs with warmup)
hyperfine 'fd -e py'

# Compare two commands
hyperfine 'find . -name "*.py"' 'fd -e py'

# With warmup and minimum runs
hyperfine --warmup 3 --min-runs 20 'rg pattern'

# Export results
hyperfine --export-markdown bench.md 'command1' 'command2'
```

**When to use:** When optimizing commands, comparing tool performance, or proving one approach is faster than another. Provides mean, stddev, min, max, and comparison percentages.

## Triggers

**Reactive** (auto-install):
```
bash: <tool>: command not found
```

**Proactive** (audit): "check environment", "what's missing", "update tools"

## Workflows

### Missing Tool Resolution

#### Phase 1: Diagnostic (BEFORE attempting install)

1. **Check if tool exists elsewhere:**
   ```bash
   which <tool>           # Is it installed but not in PATH?
   command -v <tool>      # Alternative check
   type -a <tool>         # Show all locations
   ```

2. **Why might it be missing?**
   - **PATH issue**: Tool installed but shell can't find it (check `~/.local/bin`, `/usr/local/bin`)
   - **Version conflict**: Multiple versions installed, wrong one active
   - **Shell state**: Installed in current session but shell hash table stale (`hash -r`)
   - **Package manager isolation**: Installed via pip/npm/cargo but not in global PATH

3. **If tool exists but not in PATH:**
   ```bash
   # Find the binary
   find /usr -name "<tool>" 2>/dev/null
   find ~/.local -name "<tool>" 2>/dev/null

   # Add to PATH temporarily
   export PATH="$PATH:/path/to/tool/directory"
   ```

#### Phase 2: Installation

1. Extract tool name from error
2. Lookup in `references/binary_to_tool_map.md` (e.g., `rg` → `ripgrep`)
3. Install: `scripts/install_tool.sh <tool> install`

#### Phase 3: Verification (AFTER install)

1. **Confirm installation succeeded:**
   ```bash
   which <tool>           # Should show path
   <tool> --version       # Should show version
   ```

2. **If "command not found" persists after install:**
   ```bash
   hash -r                # Clear shell's command hash
   source ~/.bashrc       # Reload shell configuration
   # Or start a new shell session
   ```

3. **Retry original command**

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

## Troubleshooting

### PATH Issues

When a tool installs but still shows "command not found":

1. **Check where it was installed:**
   ```bash
   # Common install locations
   ls -la ~/.local/bin/<tool>
   ls -la ~/.cargo/bin/<tool>
   ls -la ~/.npm-global/bin/<tool>
   ls -la /usr/local/bin/<tool>
   ```

2. **Ensure PATH includes common directories:**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
   ```

3. **Reload shell configuration:**
   ```bash
   source ~/.bashrc        # or ~/.zshrc
   hash -r                 # Clear command cache
   exec $SHELL             # Restart shell
   ```

### Installation Blocked (Permission/System Restrictions)

When system prevents normal installation, use these alternatives:

1. **Docker (no install required):**
   ```bash
   # Run tool in container
   docker run --rm -v "$PWD:/work" -w /work <tool-image> <tool> <args>

   # Create alias for convenience
   alias <tool>='docker run --rm -v "$PWD:/work" -w /work <tool-image> <tool>'
   ```

2. **Manual binary download:**
   ```bash
   # Download release binary directly
   curl -L <release-url> -o ~/.local/bin/<tool>
   chmod +x ~/.local/bin/<tool>
   ```

3. **Compile from source:**
   ```bash
   git clone <repo-url>
   cd <repo>
   make && make install PREFIX=~/.local
   ```

4. **Use package manager with user scope:**
   ```bash
   pip install --user <tool>
   npm install -g <tool> --prefix ~/.npm-global
   cargo install <tool>  # Installs to ~/.cargo/bin
   ```

## References

- `references/binary_to_tool_map.md` - Binary to catalog mapping
- `references/project_type_requirements.md` - Project type requirements
- `references/preferred-tools.md` - Detailed comparison and usage patterns for preferred tools

---

> **Contributing:** https://github.com/netresearch/cli-tools-skill
