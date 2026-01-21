
# OpenAI Codex AI (ai-codex)

OpenAI's Codex CLI with VS Code integration and skills support

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/ai-codex:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| skills | Comma-separated list of skills to install (e.g., 'tf-module,api-design') | string | - |

## Customizations

### VS Code Extensions

- `openai.chatgpt`

## OpenAI Codex AI Feature

This feature installs [OpenAI's Codex CLI](https://developers.openai.com/codex/skills/) with VS Code integration and support for DuploCloud AI skills.

### What's Included

- **Codex CLI** - `@openai/codex` npm package installed globally
- **VS Code Extension** - [ChatGPT extension](https://marketplace.visualstudio.com/items?itemName=openai.chatgpt) automatically installed
- **Skills Support** - Automatic installation of skills from [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops)

### Usage in devcontainer.json

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/ai-codex:1": {
      "skills": "tf-module,api-design"
    }
  }
}
```

### Options

- `skills` - Comma-separated list of skills to install (default: "")

### Skills Installation

Skills are installed to `$CODEX_HOME/skills/` (defaults to `~/.codex/skills/`) during container creation. You can specify skills in two ways:

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
    "ghcr.io/duplocloud/devcontainers/ai-codex:1": {
      "skills": "code-review"
    }
  }
}
```

This configuration installs all three skills: `tf-module`, `api-design`, and `code-review`.

### Skill Location

Codex discovers skills from multiple scopes (in order of precedence):
- **Repo (CWD)**: `$CWD/.codex/skills` - Current working directory
- **Repo (Parent)**: `$CWD/../.codex/skills` - Parent folders
- **Repo (Root)**: `$REPO_ROOT/.codex/skills` - Git repository root
- **User**: `$CODEX_HOME/skills` (installed by this feature)
- **Admin**: `/etc/codex/skills` - System-wide
- **System**: Bundled with Codex

For more details on how Codex uses skills, see the [Agent Skills documentation](https://developers.openai.com/codex/skills/).

### Managing Skills

Skills can be enabled/disabled in `~/.codex/config.toml`:

```toml
[[skills.config]]
path = "/path/to/skill"
enabled = false
```

### Available Skills

Skills are published in the [duplocloud/ai-ops releases](https://github.com/duplocloud/ai-ops/releases).

## References

- [Codex Overview](https://developers.openai.com/codex)
- [ChatGPT VS Code Extension](https://marketplace.visualstudio.com/items?itemName=openai.chatgpt)
- [Codex Skills Guide](https://developers.openai.com/codex/skills/)
- [Codex IDE Integration](https://developers.openai.com/codex/ide/)
- [Agent Skills Standard](https://agentskills.io/)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/ai-codex/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
