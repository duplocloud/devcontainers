## AI Base Feature

This feature provides the foundation for all AI CLI tools in DuploCloud devcontainers. It handles Node.js installation and provides the `duplo-skills` CLI for downloading skills from the [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops) repository.

### What's Included

- **Node.js Installation**: Automatically checks for and installs Node.js if not present
  - First tries to use nvm if available
  - Falls back to apt package manager
  - Compatible with [stu-bell/devcontainer-features/node](https://github.com/stu-bell/devcontainer-features/tree/main/src/node)
  
- **duplo-skills CLI**: Global command for downloading AI skills
  - Downloads `.skill` files from GitHub releases
  - Verifies SHA256 checksums automatically
  - Supports version pinning via `DUPLO_SKILLS_VERSION`

### Usage

This feature is typically used as a dependency for AI provider features (claude, gemini, codex). You don't need to use it directly unless you want to download skills manually.

### Manual Skill Installation

```bash
# Download a skill to any directory
duplo-skills --dir ~/.claude/skills --skill tf-module

# Pin to a specific version
DUPLO_SKILLS_VERSION=v0.0.2 duplo-skills --dir ~/.gemini/skills --skill api-design
```

### Available Skills

Skills are published in the [duplocloud/ai-ops releases](https://github.com/duplocloud/ai-ops/releases). Each release contains multiple `.skill` files with corresponding `.sha256` checksums.

### Environment Variables

- `DUPLO_SKILLS_VERSION` - Specify which release version to download from (default: "latest")

## References

- [duplocloud/ai-ops Repository](https://github.com/duplocloud/ai-ops)
- [Agent Skills Standard](https://agentskills.io/)
