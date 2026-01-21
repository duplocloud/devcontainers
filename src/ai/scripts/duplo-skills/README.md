# duplo-skills

Downloads and verifies skills from the [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops) repository.

## Usage

```bash
duplo-skills --dir <install-dir> --skill <skill-name>
```

## Options

- `--dir <path>` - Directory to install the skill (required)
- `--skill <name>` - Name of the skill to download (required)
- `--version` - Show version
- `--help` - Show help message

## Environment Variables

- `DUPLO_SKILLS_VERSION` - Version to download (default: "latest")

## Examples

```bash
# Download the latest tf-module skill to Claude Code
duplo-skills --dir ~/.claude/skills --skill tf-module

# Download a specific version
DUPLO_SKILLS_VERSION=v0.0.2 duplo-skills --dir ~/.gemini/skills --skill api-design

# Download to Codex
duplo-skills --dir ~/.codex/skills --skill tf-module
```

## How it works

1. Queries GitHub API for the specified release (latest by default)
2. Downloads the `.skill` file for the requested skill
3. Verifies SHA256 checksum if available
4. Installs to the specified directory

Skills are packaged as `.skill` files in the [duplocloud/ai-ops releases](https://github.com/duplocloud/ai-ops/releases).
