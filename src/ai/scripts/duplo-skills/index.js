#!/usr/bin/env node

const https = require('https');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const AdmZip = require('adm-zip');

const REPO_OWNER = 'duplocloud';
const REPO_NAME = 'ai-ops';
const GITHUB_API = 'https://api.github.com';

// Extract ZIP file using adm-zip library
function extractZip(buffer, targetDir) {
  const zip = new AdmZip(buffer);
  const zipEntries = zip.getEntries();
  
  // Extract all files
  zip.extractAllTo(targetDir, false);
  
  // Log extracted files (excluding directories)
  zipEntries.forEach(entry => {
    if (!entry.isDirectory) {
      console.log(`  ✓ Extracted: ${entry.entryName}`);
    }
  });
}

function showUsage() {
  console.log(`
Usage: duplo-skills --dir <install-dir> --skill <skill-name> [options]

Options:
  --dir <path>      Directory to install the skill (required)
  --skill <name>    Name of the skill to download (required)
  --version         Show version
  --help            Show this help message

Environment Variables:
  DUPLO_SKILLS_VERSION    Version to download (default: "latest")

Example:
  duplo-skills --dir ~/.claude/skills --skill tf-module
`);
}

function showVersion() {
  const pkg = require('./package.json');
  console.log(`duplo-skills v${pkg.version}`);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const parsed = {};
  
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    if (arg === '--help' || arg === '-h') {
      showUsage();
      process.exit(0);
    }
    
    if (arg === '--version' || arg === '-v') {
      showVersion();
      process.exit(0);
    }
    
    if (arg === '--dir' && i + 1 < args.length) {
      parsed.dir = args[++i];
    }
    
    if (arg === '--skill' && i + 1 < args.length) {
      parsed.skill = args[++i];
    }
  }
  
  return parsed;
}

function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, {
      headers: {
        'User-Agent': 'duplo-skills'
      }
    }, (res) => {
      if (res.statusCode === 302 || res.statusCode === 301) {
        // Follow redirect
        return resolve(httpsGet(res.headers.location));
      }
      
      if (res.statusCode !== 200) {
        return reject(new Error(`HTTP ${res.statusCode}: ${res.statusMessage}`));
      }
      
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => resolve(Buffer.concat(chunks)));
      res.on('error', reject);
    }).on('error', reject);
  });
}

async function getLatestRelease() {
  const url = `${GITHUB_API}/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest`;
  console.log(`Fetching latest release from ${REPO_OWNER}/${REPO_NAME}...`);
  
  const data = await httpsGet(url);
  return JSON.parse(data.toString());
}

async function getRelease(version) {
  if (version === 'latest') {
    return await getLatestRelease();
  }
  
  // Specific version
  const url = `${GITHUB_API}/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${version}`;
  console.log(`Fetching release ${version} from ${REPO_OWNER}/${REPO_NAME}...`);
  
  const data = await httpsGet(url);
  return JSON.parse(data.toString());
}

function calculateChecksum(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

function findSkillAsset(assets, skillName) {
  return assets.find(a => a.name === `${skillName}.skill`);
}

function expectedSha256FromAssetDigest(asset) {
  if (!asset || !asset.digest) return null;
  if (typeof asset.digest !== 'string') return null;
  if (!asset.digest.startsWith('sha256:')) return null;
  return asset.digest.slice('sha256:'.length);
}

function findChecksumAsset(assets, skillName) {
  return assets.find(a => a.name === `${skillName}.skill.sha256`);
}

async function downloadSkill(installDir, skillName) {
  const version = process.env.DUPLO_SKILLS_VERSION || 'latest';
  
  try {
    // Get release info
    const release = await getRelease(version);
    console.log(`Found release: ${release.tag_name}`);
    
    // Find the skill asset
    const skillAsset = findSkillAsset(release.assets, skillName);
    
    if (!skillAsset) {
      throw new Error(`Skill "${skillName}.skill" not found in release ${release.tag_name}`);
    }
    
    console.log(`Downloading ${skillAsset.name}...`);
    const skillData = await httpsGet(skillAsset.browser_download_url);
    
    // Verify checksum (prefer GitHub's asset digest when available)
    console.log(`Verifying checksum...`);
    const actualHash = calculateChecksum(skillData);
    const digestHash = expectedSha256FromAssetDigest(skillAsset);

    if (digestHash) {
      if (digestHash !== actualHash) {
        throw new Error(`Checksum mismatch!\n  Expected: ${digestHash}\n  Got: ${actualHash}`);
      }
      console.log(`✓ Checksum verified`);
    } else {
      const checksumAsset = findChecksumAsset(release.assets, skillName);
      if (!checksumAsset) {
        throw new Error(`No checksum available for "${skillName}.skill" (missing asset digest and "${skillName}.skill.sha256")`);
      }

      const expectedChecksum = await httpsGet(checksumAsset.browser_download_url);
      const expectedHash = expectedChecksum.toString().trim().split(/\s+/)[0];

      if (expectedHash !== actualHash) {
        throw new Error(`Checksum mismatch!\n  Expected: ${expectedHash}\n  Got: ${actualHash}`);
      }
      console.log(`✓ Checksum verified`);
    }
    
    // Ensure install directory exists
    const fullPath = path.resolve(installDir);
    if (!fs.existsSync(fullPath)) {
      fs.mkdirSync(fullPath, { recursive: true });
    }
    
    // Extract the skill archive
    console.log(`Extracting ${skillName}...`);
    extractZip(skillData, fullPath);
    console.log(`✓ Skill installed to: ${fullPath}/${skillName}`);
    
    return path.join(fullPath, skillName);
    
  } catch (error) {
    console.error(`Error downloading skill: ${error.message}`);
    process.exit(1);
  }
}

// Main execution
async function main() {
  const args = parseArgs();
  
  if (!args.dir || !args.skill) {
    console.error('Error: --dir and --skill are required\n');
    showUsage();
    process.exit(1);
  }
  
  await downloadSkill(args.dir, args.skill);
}

main();
