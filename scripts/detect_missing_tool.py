#!/usr/bin/env python3
"""
Detect "command not found" errors in Bash tool output.
Outputs a system reminder suggesting the cli-tools skill when a missing tool is detected.
"""

import sys
import re
import json

# Patterns that indicate a missing command/tool
MISSING_PATTERNS = [
    r"command not found",
    r"not found: (\w+)",
    r"(\w+): not found",
    r"bash: (\w+): No such file or directory",
    r"zsh: command not found: (\w+)",
    r"sh: (\d+): (\w+): not found",
    r"Cannot run program \"(\w+)\"",
    r"'(\w+)' is not recognized",
    r"The term '(\w+)' is not recognized",
]


def extract_tool_name(text: str) -> str | None:
    """Extract the missing tool name from error text."""
    for pattern in MISSING_PATTERNS:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            # Return the captured group (tool name) or indicate generic match
            groups = match.groups()
            for g in groups:
                if g and not g.isdigit():
                    return g
            return "unknown"
    return None


def main():
    # Read tool output from stdin (Claude Code passes tool result)
    try:
        input_data = sys.stdin.read()
    except Exception:
        return

    if not input_data:
        return

    # Try to parse as JSON (Claude Code format)
    try:
        data = json.loads(input_data)
        output = data.get("output", "") or data.get("stdout", "") or data.get("stderr", "")
    except (json.JSONDecodeError, TypeError):
        output = input_data

    # Check for missing tool patterns
    tool_name = extract_tool_name(output)

    if tool_name:
        # Output system reminder for Claude
        print(f"""<system-reminder>
Detected missing tool: '{tool_name}'

The cli-tools skill can help install this tool. Consider:
1. Use the cli-tools skill to check if '{tool_name}' is in the catalog
2. Install via: the skill's installation workflow

Quick reference - common tools in catalog:
- ripgrep (rg), fd, jq, yq, fzf, bat, eza
- docker, kubectl, terraform, ansible
- node, npm, pnpm, bun, deno
- python, pip, poetry, uv
- go, rust/cargo, php/composer
</system-reminder>""")


if __name__ == "__main__":
    main()
