## AI Base Feature

This feature provides the foundation for all AI CLI tools in DuploCloud devcontainers. It handles Node.js installation and provides the `duplo-skills` CLI for downloading skills from the [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops) repository.

### What's Included

- **Node.js Installation**: Automatically checks for and installs Node.js if not present
  - First tries to use nvm if available
  - Falls back to apt package manager
  - Compatible with [stu-bell/devcontainer-features/node](https://github.com/stu-bell/devcontainer-features/tree/main/src/node)
  
- **duplo-skills CLI**: Global command for downloading AI skills
  - Downloads `.skill` archive files from GitHub releases
  - Automatically extracts skill contents into target directory using `adm-zip` library
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

Skills are published in the [duplocloud/ai-ops releases](https://github.com/duplocloud/ai-ops/releases). Each release contains `.skill` archive files (ZIP format) with corresponding checksums. The archives contain the skill directory structure and are automatically extracted during installation.

### Skill Archive Format

Skills are packaged as `.skill` files using the following structure:
- Each `.skill` file is a ZIP archive containing a folder named after the skill
- Inside the folder is a `SKILL.md` file and any supporting files
- The publish workflow creates these archives from the `skills/` directory in [duplocloud/ai-ops](https://github.com/duplocloud/ai-ops)
- Example: `tf-module.skill` contains `tf-module/SKILL.md`

### Environment Variables

- `DUPLO_SKILLS_VERSION` - Specify which release version to download from (default: "latest")

## References

- [duplocloud/ai-ops Repository](https://github.com/duplocloud/ai-ops)
- [Agent Skills Standard](https://agentskills.io/)
