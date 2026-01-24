# Quick Start Guide for New Features

## 🎉 What's New

Your WMPFDebugger repository now has automated build and release capabilities!

### Key Features Added:

1. **Standalone Windows Executable**: Users can run WMPFDebugger without installing Node.js
2. **Automated Releases**: Push a tag to automatically build and publish releases
3. **Upstream Synchronization**: Daily automatic sync with upstream repository (evi0s/WMPFDebugger)

---

## 🚀 How to Create Your First Release

1. **Make sure your code is ready** on the main branch

2. **Create and push a version tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **Wait for the build** (takes ~5-10 minutes):
   - Go to your repository → Actions tab
   - Watch the "Build and Release" workflow run

4. **Your release is ready!**:
   - Go to Releases tab
   - Download `WMPFDebugger.exe` or the full ZIP package
   - Share with users!

---

## 📦 What Users Get

Users can now download and run your debugger without any setup:

1. Download `WMPFDebugger.exe` from Releases
2. Run it: `WMPFDebugger.exe`
3. That's it! No Node.js installation needed

The executable includes:
- Node.js runtime (embedded)
- All dependencies
- Frida hook scripts

---

## 🔄 Upstream Synchronization

Your fork will automatically stay in sync with the upstream repository:

- **When**: Daily at 2 AM UTC (or manual trigger)
- **What**: Creates a PR with upstream changes
- **You**: Review and merge the PR

### To Manually Sync:
1. Go to Actions tab
2. Select "Sync Upstream" workflow
3. Click "Run workflow"

---

## 👨‍💻 Development Commands

For contributors working on the code:

```bash
# Run in development mode (TypeScript directly)
yarn dev

# Build TypeScript to JavaScript
yarn build

# Package to Windows executable
yarn package:win

# Build and package in one command
yarn release
```

---

## 📚 More Information

- **Release Process**: See `RELEASE.md` for detailed instructions
- **End User Guide**: See `README.md` for usage instructions
- **Chinese Documentation**: See `README.zh.md`

---

## ⚠️ Important Notes

1. **Version Tags**: Must follow the format `vX.Y.Z` (e.g., v1.0.0, v1.2.3)
2. **Windows Only**: The executable is built for Windows x64 only
3. **Node.js Version**: Uses Node.js 22 LTS
4. **Frida Dependency**: The frida folder must exist with hook scripts

---

## 🐛 Troubleshooting

### Release Build Failed
- Check the Actions logs in GitHub
- Ensure TypeScript compiles without errors
- Verify all dependencies are in package.json

### Can't Find Frida Scripts
- The executable looks for the `frida` folder relative to its location
- Include the `frida` folder when distributing

### Upstream Sync Has Conflicts
- Clone the sync branch locally
- Resolve conflicts manually
- Push and merge the PR

---

## 🎯 Next Steps

1. **Test the build locally** (optional):
   ```bash
   yarn release
   ```

2. **Create your first release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **Watch it build** in the Actions tab

4. **Download and test** the executable from Releases

5. **Share with users** and enjoy! 🎉

---

For questions or issues, please check the documentation or open a GitHub issue.
