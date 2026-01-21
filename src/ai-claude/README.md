
# Claude Code AI (ai-claude)

Anthropic's Claude Code CLI with VS Code integration and skills support

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/ai-claude:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| skills | Comma-separated list of skills to install (e.g., 'tf-module,api-design') | string | - |

## Customizations

### VS Code Extensions

- `anthropic.claude-code`

## Claude Code AI Feature

This feature installs [Anthropic's Claude Code](https://code.claude.com/docs/en/vs-code) CLI and VS Code extension with support for DuploCloud AI skills.

### What's Included

- **Claude Code CLI** - `@anthropic-ai/claude-code` npm package installed globally
- **VS Code Extension** - [Claude Code extension](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) automatically installed
- **Skills Support** - Automatic installation of skills from [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops)

### Usage in devcontainer.json

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/ai-claude:1": {
      "skills": "tf-module,api-design"
    }
  }
}
```

### Options

- `skills` - Comma-separated list of skills to install (default: "")

### Skills Installation

Skills are installed to `~/.claude/skills/` during container creation. You can specify skills in two ways:

1. **Feature option**: Set the `skills` option in your devcontainer.json
2. **Environment variable**: Set `DUPLO_AI_SKILLS` in your devcontainer.json

Both sources are merged, so you can have a common set via environment variable and feature-specific additions via the option.

### Example: Installing Multiple Skills

```json
{
  "containerEnv": {
    "DUPLO_AI_SKILLS": "tf-module,api-design"
  },
  "features": {
    "ghcr.io/duplocloud/devcontainers/ai-claude:1": {
      "skills": "code-review"
    }
  }
}
```

This configuration installs all three skills: `tf-module`, `api-design`, and `code-review`.

### Skill Location

Claude Code discovers skills from multiple locations:
- **User skills**: `~/.claude/skills/` (installed by this feature)
- **Project skills**: `.claude/skills/` (commit to version control)
- **Plugin skills**: Provided by extensions

For more details on how Claude Code uses skills, see the [Skills documentation](https://code.claude.com/docs/en/skills).

### Available Skills

Skills are published in the [duplocloud/ai-ops releases](https://github.com/duplocloud/ai-ops/releases).

## References

- [Claude Code Documentation](https://code.claude.com/docs/en/vs-code)
- [Claude Code VS Code Extension](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code)
- [Claude Code Skills Guide](https://code.claude.com/docs/en/skills)
- [Agent Skills Standard](https://agentskills.io/)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/ai-claude/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
