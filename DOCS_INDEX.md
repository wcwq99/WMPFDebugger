# Documentation Index

This repository contains comprehensive documentation for integrating WMPFDebugger with AI_JS_DEBUGGER for AI-powered WeChat miniapp reverse engineering.

## Main Documentation

### Getting Started
1. **[README.md](README.md)** - Main project overview and basic usage
2. **[README.zh.md](README.zh.md)** - 中文项目概述和基本使用

### AI Integration
3. **[AI_INTEGRATION.md](AI_INTEGRATION.md)** ⭐ - Complete guide for integrating with AI_JS_DEBUGGER
   - Step-by-step installation
   - Configuration instructions
   - Usage examples
   - Troubleshooting
   - Both English and Chinese

4. **[QUICKSTART.md](QUICKSTART.md)** ⭐ - Quick reference card
   - TL;DR setup instructions
   - Command cheatsheet
   - Common workflows
   - Quick troubleshooting

5. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture
   - System diagrams (Mermaid)
   - Data flow diagrams
   - Component interactions
   - Performance considerations

### Configuration Files
6. **[ai_debugger_config.example.yaml](ai_debugger_config.example.yaml)** - Example configuration
   - Detailed comments
   - All available options
   - Copy to AI_JS_DEBUGGER as `config.yaml`

### Setup Scripts
7. **[setup_ai_integration.sh](setup_ai_integration.sh)** - Linux/Mac setup script
8. **[setup_ai_integration.bat](setup_ai_integration.bat)** - Windows setup script

### Additional Guides
9. **[FAQ.md](FAQ.md)** ⭐ - Frequently asked questions
10. **[EXTENSION.md](EXTENSION.md)** - WeChat embedded browser debugging
11. **[ADAPTATION.md](ADAPTATION.md)** - Adapting to new WMPF versions

## Documentation by Use Case

### I want to... Documentation to read

| Use Case | Primary Document | Supporting Documents |
|----------|-----------------|---------------------|
| Get started quickly | [QUICKSTART.md](QUICKSTART.md) | [README.md](README.md) |
| Integrate with AI_JS_DEBUGGER | [AI_INTEGRATION.md](AI_INTEGRATION.md) | [QUICKSTART.md](QUICKSTART.md) |
| Understand the architecture | [ARCHITECTURE.md](ARCHITECTURE.md) | [AI_INTEGRATION.md](AI_INTEGRATION.md) |
| Troubleshoot issues | [FAQ.md](FAQ.md) | [QUICKSTART.md](QUICKSTART.md) |
| Debug regular miniapps | [README.md](README.md) | - |
| Debug WeChat webpages | [EXTENSION.md](EXTENSION.md) | [README.md](README.md) |
| Support new WMPF version | [ADAPTATION.md](ADAPTATION.md) | - |

## Quick Links

### External Resources
- [AI_JS_DEBUGGER Repository](https://github.com/Valerian7/AI_JS_DEBUGGER)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [Frida Documentation](https://frida.re/docs/)
- [WeChat PC Download](https://pc.weixin.qq.com/)

### Support
- [WMPFDebugger Issues](https://github.com/wcwq99/WMPFDebugger/issues)
- [AI_JS_DEBUGGER Issues](https://github.com/Valerian7/AI_JS_DEBUGGER/issues)

## Document Status

| Document | Last Updated | Status | Language |
|----------|-------------|--------|----------|
| README.md | 2026-01 | ✅ Current | EN |
| README.zh.md | 2026-01 | ✅ Current | ZH |
| AI_INTEGRATION.md | 2026-01 | ✅ Current | EN/ZH |
| QUICKSTART.md | 2026-01 | ✅ Current | EN |
| ARCHITECTURE.md | 2026-01 | ✅ Current | EN |
| FAQ.md | 2026-01 | ✅ Current | EN |
| EXTENSION.md | 2024 | ✅ Current | EN |
| ADAPTATION.md | 2024 | ✅ Current | EN |

## Recommended Reading Order

### For New Users
1. [README.md](README.md) - Understand what WMPFDebugger does
2. [QUICKSTART.md](QUICKSTART.md) - Get up and running quickly
3. [AI_INTEGRATION.md](AI_INTEGRATION.md) - Set up AI integration

### For AI Integration
1. [AI_INTEGRATION.md](AI_INTEGRATION.md) - Complete integration guide
2. [ai_debugger_config.example.yaml](ai_debugger_config.example.yaml) - Configuration reference
3. Run [setup_ai_integration.sh](setup_ai_integration.sh) or [setup_ai_integration.bat](setup_ai_integration.bat)
4. [QUICKSTART.md](QUICKSTART.md) - Quick reference while working

### For Advanced Users
1. [ARCHITECTURE.md](ARCHITECTURE.md) - Understand the system design
2. [ADAPTATION.md](ADAPTATION.md) - Learn to adapt to new versions
3. [EXTENSION.md](EXTENSION.md) - Extended capabilities

## Contributing

When contributing documentation:
1. Keep it concise and practical
2. Include examples
3. Add both English and Chinese for major guides
4. Update this index if adding new documents
5. Test all commands and configurations

## License

All documentation in this repository is provided under the same license as the WMPFDebugger project (GPL-2.0).

See [LICENSE](LICENSE) for details.
