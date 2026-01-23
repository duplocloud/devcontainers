## Copilot Skills Location
GitHub Copilot agent skills are installed to the user scope directory `~/.copilot/skills` as documented in [Copilot Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills). This feature downloads skills during container creation so they are ready for Copilot to discover.

Example:
```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/github:1": {
      "skills": "tf-module,devcontainers"
    }
  }
}
```
This installs skills into `~/.copilot/skills/` inside the container.
