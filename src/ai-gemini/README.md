
# Gemini CLI AI (ai-gemini)

Google's Gemini CLI with VS Code integration and skills support

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/ai-gemini:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| skills | Comma-separated list of skills to install (e.g., 'tf-module,api-design') | string | - |

## Customizations

### VS Code Extensions

- `Google.geminicodeassist`

## Gemini CLI AI Feature

This feature installs [Google's Gemini CLI](https://geminicli.com/docs/cli/skills/) with VS Code integration and support for DuploCloud AI skills.

### What's Included

- **Gemini CLI** - `@google/gemini-cli` npm package installed globally
- **VS Code Extension** - [Gemini Code Assist extension](https://marketplace.visualstudio.com/items?itemName=Google.geminicodeassist) automatically installed
- **Skills Support** - Automatic installation of skills from [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops)

### Usage in devcontainer.json

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/ai-gemini:1": {
      "skills": "tf-module,api-design"
    }
  }
}
```

### Options

- `skills` - Comma-separated list of skills to install (default: "")

### Skills Installation

Skills are installed to `~/.gemini/skills/` during container creation. You can specify skills in two ways:

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
    "ghcr.io/duplocloud/devcontainers/ai-gemini:1": {
      "skills": "code-review"
    }
  }
}
```

This configuration installs all three skills: `tf-module`, `api-design`, and `code-review`.

### Skill Location

Gemini CLI discovers skills from multiple tiers:
- **User skills**: `~/.gemini/skills/` (installed by this feature)
- **Workspace skills**: `.gemini/skills/` (commit to version control)
- **Extension skills**: Provided by installed extensions

Precedence: Workspace > User > Extension

For more details on how Gemini CLI uses skills, see the [Agent Skills documentation](https://geminicli.com/docs/cli/skills/).

### Managing Skills

In the Gemini CLI interactive session:
- `/skills list` - View all discovered skills
- `/skills disable <name>` - Disable a specific skill
- `/skills enable <name>` - Re-enable a disabled skill
- `/skills reload` - Refresh the skills list

### Available Skills

Skills are published in the [duplocloud/ai-ops releases](https://github.com/duplocloud/ai-ops/releases).

## References

- [Gemini CLI Documentation](https://geminicli.com/docs/)
- [Gemini Code Assist VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Google.geminicodeassist)
- [Gemini CLI Skills Guide](https://geminicli.com/docs/cli/skills/)
- [Agent Skills Standard](https://agentskills.io/)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/ai-gemini/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
