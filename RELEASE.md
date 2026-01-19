# Release and Automation Guide

This document explains the automated release and upstream synchronization process for WMPFDebugger.

## Overview

This repository includes two main automation workflows:

1. **Automated Releases**: Builds and publishes Windows executables when you create a version tag
2. **Upstream Synchronization**: Automatically syncs changes from the upstream repository (evi0s/WMPFDebugger)

## Release Process

### Creating a New Release

To create a new release, simply create and push a version tag:

```bash
# Make sure you're on the main branch with latest changes
git checkout main
git pull

# Create a version tag (use semantic versioning)
git tag v1.0.0

# Push the tag to trigger the release workflow
git push origin v1.0.0
```

### What Happens Automatically

When you push a tag:

1. **GitHub Actions** detects the tag and starts the build workflow
2. The workflow runs on **Windows** with **Node.js 22**
3. It installs all dependencies using `yarn`
4. Compiles TypeScript code to JavaScript (stored in `dist/`)
5. Uses `pkg` to package the JavaScript into a standalone Windows executable (`WMPFDebugger.exe`)
6. Creates a ZIP archive containing:
   - `WMPFDebugger.exe`
   - `frida/` folder (hook scripts)
   - `README.md`
   - `LICENSE`
7. Creates a **GitHub Release** with:
   - The ZIP archive (`WMPFDebugger-vX.Y.Z-win-x64.zip`)
   - The standalone executable (`WMPFDebugger.exe`)
   - Auto-generated release notes

### Release Assets

Users can download either:
- **WMPFDebugger-vX.Y.Z-win-x64.zip**: Complete package with all files
- **WMPFDebugger.exe**: Just the executable (recommended for simplicity)

## Upstream Synchronization

### How It Works

The repository automatically stays in sync with the upstream repository (evi0s/WMPFDebugger):

1. **Daily Sync**: Runs every day at 2 AM UTC
2. **Manual Sync**: Can be triggered manually from the Actions tab
3. When changes are detected:
   - Creates a new branch (`sync-upstream-YYYYMMDD-HHMMSS`)
   - Merges upstream changes
   - Opens a Pull Request for review
4. You review and merge the PR manually

### Manual Trigger

To manually trigger an upstream sync:

1. Go to the **Actions** tab in your repository
2. Select **Sync Upstream** workflow
3. Click **Run workflow**
4. Select the branch and click **Run workflow**

### Reviewing Sync PRs

When a sync PR is created:

1. Review the changes from upstream
2. Check for any conflicts or breaking changes
3. Test if needed
4. Merge the PR if everything looks good

### Handling Conflicts

If there are merge conflicts:

1. The workflow will create a PR with the conflict
2. You need to resolve conflicts manually:
   ```bash
   git checkout sync-upstream-YYYYMMDD-HHMMSS
   # Resolve conflicts in your editor
   git add .
   git commit
   git push
   ```
3. Then merge the PR

## Development Workflow

### For Developers

```bash
# Clone the repository
git clone https://github.com/wcwq99/WMPFDebugger
cd WMPFDebugger

# Install dependencies
yarn

# Run in development mode
yarn dev

# Build TypeScript to JavaScript
yarn build

# Package to Windows executable (requires Windows or pkg's fetch)
yarn package:win

# Build + Package in one command
yarn release
```

### Available Scripts

- `yarn dev`: Run the debugger in development mode (using ts-node)
- `yarn build`: Compile TypeScript to JavaScript (output to `dist/`)
- `yarn package:win`: Package JavaScript to Windows executable
- `yarn release`: Build and package in one command

## For End Users

End users don't need Node.js or any dependencies:

1. Download `WMPFDebugger.exe` from the latest release
2. Run it directly: `WMPFDebugger.exe`
3. Follow the usage instructions in README.md

## Technical Details

### Build Configuration

- **Target Platform**: Windows x64
- **Node Version**: 22 (LTS)
- **Packaging Tool**: pkg v5.8.1
- **TypeScript Target**: ES2020
- **Output Format**: CommonJS

### pkg Configuration

The `pkg` tool is configured in `package.json`:

```json
{
  "bin": "dist/index.js",
  "pkg": {
    "assets": [
      "frida/**/*"
    ],
    "outputPath": "."
  }
}
```

This ensures:
- Entry point is `dist/index.js`
- Frida hook scripts are included in the executable
- Output goes to the project root

### GitHub Actions Workflows

#### Release Workflow (`.github/workflows/release.yml`)
- **Trigger**: Tag push matching `v*.*.*`
- **Runner**: Windows Latest
- **Node**: 22.x
- **Steps**: Checkout → Setup Node → Install → Build → Package → Zip → Release

#### Sync Workflow (`.github/workflows/sync-upstream.yml`)
- **Trigger**: Daily schedule (2 AM UTC) or manual
- **Runner**: Ubuntu Latest
- **Steps**: Checkout → Fetch Upstream → Check Diff → Merge → Create PR

## Troubleshooting

### Release Build Fails

1. Check the Actions tab for error logs
2. Common issues:
   - TypeScript compilation errors
   - Missing dependencies
   - pkg compatibility issues

### Sync PR Has Conflicts

1. Clone the sync branch locally
2. Resolve conflicts manually
3. Push and merge the PR

### pkg Cannot Find Files

If `pkg` can't find the `frida` folder at runtime:
- Ensure the `pkg.assets` configuration includes `frida/**/*`
- The code uses `path.join(path.dirname(require.main.filename), "..")` to locate files

## Version Strategy

Use semantic versioning:
- **v1.0.0**: Major release (breaking changes)
- **v1.1.0**: Minor release (new features)
- **v1.0.1**: Patch release (bug fixes)

## Questions?

If you encounter any issues:
1. Check existing GitHub Issues
2. Review the Actions logs
3. Create a new issue with details
