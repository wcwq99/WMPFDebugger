# Quick Reference: WMPFDebugger + AI_JS_DEBUGGER

## Quick Start (TL;DR)

### Prerequisites
```bash
# Check versions
node --version  # Need v22+
python3 --version  # Need 3.11+ (use 'python' on Windows)
yarn --version
```

> **Note:** On Windows, use `python` instead of `python3`. On Linux/Mac, use `python3`.

### One-Time Setup
```bash
# Clone and setup
git clone https://github.com/wcwq99/WMPFDebugger
cd WMPFDebugger
yarn install

# Clone AI_JS_DEBUGGER
cd ..
git clone https://github.com/Valerian7/AI_JS_DEBUGGER.git
cd AI_JS_DEBUGGER
pip install -r requirements.txt

# Configure
cp ../WMPFDebugger/ai_debugger_config.example.yaml config.yaml
# Edit config.yaml and set your AI API key
```

### Every Session
```bash
# Terminal 1: Start WMPFDebugger
cd WMPFDebugger
npx ts-node src/index.ts

# Launch miniapp in WeChat PC

# Terminal 2: Start AI_JS_DEBUGGER  
cd AI_JS_DEBUGGER
python3 run_flask.py  # Use 'python' on Windows

# Open browser: http://localhost:5001
```

---

## Command Cheatsheet

### WMPFDebugger Commands
```bash
# Start debug server
npx ts-node src/index.ts

# Check WMPF version
# Task Manager → WeChatAppEx → Right click → Open file location
# Check number between "RadiumWMPF" and "extracted"

# Custom CDP port (edit src/index.ts)
const CDP_PORT = 62000;  # Change this value
```

### AI_JS_DEBUGGER Commands
```bash
# Install dependencies
pip install -r requirements.txt

# Start web interface
python3 run_flask.py

# Check connection
curl http://localhost:5001
```

### Browser DevTools
```
# Manual inspection (optional)
devtools://devtools/bundled/inspector.html?ws=127.0.0.1:62000
```

---

## Configuration Quick Reference

### config.yaml (AI_JS_DEBUGGER)
```yaml
# Essential settings only
cdp:
  debug_url: "ws://127.0.0.1:62000"
  auto_connect: false

ai:
  api_key: "your-key-here"
  api_base: "https://api.openai.com/v1"
  model: "gpt-4"

debug:
  xhr_breakpoint: true  # Recommended for APIs
  file_breakpoint:
    enabled: false      # Or true if targeting specific file
    file_url: ""
    line: 0
    column: 0
```

### Ports Reference
| Service | Default Port | Configurable |
|---------|-------------|--------------|
| WMPFDebugger Debug Server | 9421 | Yes (src/index.ts) |
| WMPFDebugger CDP Proxy | 62000 | Yes (src/index.ts) |
| AI_JS_DEBUGGER Web UI | 5001 | Yes (config.yaml) |

---

## Common Workflows

### 1. API Reverse Engineering (Recommended)
```
1. Start WMPFDebugger
2. Launch miniapp
3. Start AI_JS_DEBUGGER with XHR mode enabled
4. Trigger the API call in miniapp
5. Wait for AI analysis
6. Review report and mitmproxy script
```

### 2. Specific Function Analysis
```
1. Start WMPFDebugger
2. Launch miniapp
3. Open Chrome DevTools
4. Find target function in Sources
5. Note file URL, line, column
6. Configure AI_JS_DEBUGGER with file breakpoint
7. Start debugging session
8. Trigger the function
9. Review AI analysis
```

### 3. Encryption Key Extraction
```
1. Enable encryption hooks in config.yaml
2. Start debugging session
3. Trigger encryption operation
4. Hooks automatically capture:
   - Algorithm type (AES, RSA, etc.)
   - Keys and IVs
   - Input/output data
5. Review in analysis report
```

---

## Troubleshooting Quick Fixes

### Connection Failed
```bash
# Check WMPFDebugger is running
ps aux | grep WeChatAppEx  # Linux/Mac
tasklist | findstr WeChatAppEx  # Windows

# Check port availability
netstat -an | grep 62000  # Linux/Mac
netstat -an | findstr 62000  # Windows

# Verify miniapp is running in WeChat
```

### Breakpoint Not Triggered
```yaml
# For XHR mode: Make sure to trigger actual request
# For file mode: Verify these are correct:
file_breakpoint:
  file_url: "full-url-from-devtools"  
  line: 123  # 0-indexed
  column: 45  # 0-indexed
```

### AI Analysis Failed
```yaml
# Check API key
ai:
  api_key: "sk-..."  # Must be valid

# Try different model
model: "gpt-3.5-turbo"  # Faster, cheaper
# or
model: "gpt-4"  # Better analysis

# Check API quota
# Visit your AI provider's dashboard
```

### No Data Captured
```yaml
# Enable hooks
hooks:
  encryption_hook: true
  xhr_hook: true
  fetch_hook: true

# Increase timeout
debug:
  timeout: 120  # seconds
```

---

## File Locations

### WMPFDebugger
```
WMPFDebugger/
├── src/index.ts          # Main entry point (CDP_PORT here)
├── frida/hook.js         # Frida injection script
├── frida/config/         # Version-specific configs
├── AI_INTEGRATION.md     # Full integration guide
├── ARCHITECTURE.md       # Architecture diagrams
└── ai_debugger_config.example.yaml  # Config template
```

### AI_JS_DEBUGGER
```
AI_JS_DEBUGGER/
├── run_flask.py          # Web UI entry point
├── config.yaml           # Main configuration (create this)
├── backend/              # Flask backend
├── ai_debugger/          # Core debugging logic
├── modules/              # CDP and hooks
├── hooks/                # Hook scripts
└── reports/              # Generated reports (auto-created)
```

---

## API Key Sources

| Provider | URL | Notes |
|----------|-----|-------|
| OpenAI | https://platform.openai.com/api-keys | GPT-3.5, GPT-4 |
| Anthropic | https://console.anthropic.com/ | Claude models |
| Alibaba Cloud | https://dashscope.aliyun.com/ | Qwen models |
| DeepSeek | https://platform.deepseek.com/ | DeepSeek models |

Most providers offer free trial credits.

---

## Useful URLs

- WMPFDebugger: https://github.com/wcwq99/WMPFDebugger
- AI_JS_DEBUGGER: https://github.com/Valerian7/AI_JS_DEBUGGER
- Chrome DevTools Protocol: https://chromedevtools.github.io/devtools-protocol/
- Frida: https://frida.re/

---

## Debug Logs

### View WMPFDebugger Logs
```bash
# Logs appear in terminal where you ran:
npx ts-node src/index.ts

# Enable debug mode (edit src/index.ts):
const DEBUG = true;
```

### View AI_JS_DEBUGGER Logs
```bash
# Logs appear in terminal and file
tail -f logs/ai_debugger.log

# Or configure in config.yaml:
logging:
  level: "debug"  # More verbose
```

---

## Performance Tips

1. **Use XHR mode** - Faster than file breakpoints
2. **Selective hooks** - Only enable hooks you need
3. **Use GPT-3.5** for iteration - Switch to GPT-4 for final analysis
4. **Close other miniapps** - Focus on one at a time
5. **Restart cleanly** - If issues, restart both tools

---

## Security Checklist

- [ ] Only debug miniapps you're authorized to test
- [ ] Never commit config.yaml with API keys
- [ ] Use .gitignore to exclude sensitive files
- [ ] Store API keys securely
- [ ] Follow responsible disclosure for findings
- [ ] Respect terms of service

---

## Getting Help

1. **Check logs** - Both WMPFDebugger and AI_JS_DEBUGGER terminals
2. **Review docs** - AI_INTEGRATION.md and ARCHITECTURE.md
3. **GitHub Issues**:
   - WMPFDebugger: https://github.com/wcwq99/WMPFDebugger/issues
   - AI_JS_DEBUGGER: https://github.com/Valerian7/AI_JS_DEBUGGER/issues
4. **Include in bug reports**:
   - WMPF version
   - Node.js version
   - Python version
   - Error messages from logs
   - Steps to reproduce

---

## Version Compatibility

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| Node.js | v22.0.0 | Latest LTS |
| Python | 3.11 | 3.11+ |
| WeChat WMPF | See README.md | Latest supported |
| Chrome/Edge | Any recent | Latest |

---

*For detailed information, see [AI_INTEGRATION.md](AI_INTEGRATION.md)*
