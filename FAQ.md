# Frequently Asked Questions (FAQ)

## General Questions

### Q: What is WMPFDebugger + AI_JS_DEBUGGER integration?
**A:** This integration combines WMPFDebugger (which exposes WeChat miniapps via Chrome DevTools Protocol) with AI_JS_DEBUGGER (which uses AI to automatically analyze JavaScript) to enable AI-powered reverse engineering of WeChat miniapps.

### Q: Is this legal?
**A:** This tool is for educational and security research purposes only. You should:
- Only analyze miniapps you have permission to test
- Follow responsible disclosure practices
- Respect intellectual property rights
- Comply with all applicable laws and regulations

### Q: What can this integration do?
**A:** It can automatically:
- Analyze JavaScript encryption algorithms
- Extract encryption keys (AES, RSA, etc.)
- Identify API endpoints and parameters
- Generate analysis reports
- Create mitmproxy scripts for request reproduction

---

## Setup and Installation

### Q: What are the system requirements?
**A:** You need:
- **OS:** Windows (for WeChat PC)
- **Node.js:** v22 or higher
- **Python:** 3.11 or higher
- **WeChat PC:** With WMPF plugin installed
- **AI API:** Access to OpenAI, Claude, Qwen, or compatible API

### Q: Can I run this on Mac or Linux?
**A:** WMPFDebugger requires WeChat PC which only runs on Windows. However, you could:
- Run WeChat in a Windows VM
- Use Wine (experimental, not officially supported)
- Run AI_JS_DEBUGGER on Mac/Linux, connecting to WMPFDebugger on Windows

### Q: Do I need to pay for AI API access?
**A:** Most AI providers offer:
- Free trial credits for new users
- Pay-as-you-go pricing (typically $0.001-0.03 per request)
- You can use cheaper models like GPT-3.5-turbo for most tasks

### Q: Which AI model should I use?
**A:** Recommendations:
- **GPT-4:** Best quality analysis, but more expensive
- **GPT-3.5-turbo:** Good balance of speed and quality
- **Claude:** Excellent for complex code analysis
- **Qwen/DeepSeek:** Cost-effective alternatives

---

## Configuration

### Q: Where do I put my AI API key?
**A:** In `AI_JS_DEBUGGER/config.yaml`:
```yaml
ai:
  api_key: "your-api-key-here"
```
Never commit this file to git! It's already in `.gitignore`.

### Q: What if I use a different CDP port?
**A:** 
1. Change `CDP_PORT` in `WMPFDebugger/src/index.ts`
2. Update `debug_url` in `AI_JS_DEBUGGER/config.yaml` to match

### Q: Can I debug multiple miniapps simultaneously?
**A:** Not on the same WMPFDebugger instance. To debug multiple:
1. Use different CDP ports for each WMPFDebugger instance
2. Configure separate AI_JS_DEBUGGER instances
3. Or debug one miniapp at a time (recommended)

---

## Usage

### Q: XHR mode or File mode - which should I use?
**A:** 
- **XHR mode (recommended):** For API reverse engineering
  - Automatically traces back to the root caller
  - Easier to set up
  - Better for finding encryption logic
  
- **File mode:** When you know the exact function to analyze
  - Requires file URL, line, and column
  - More precise but harder to configure
  - Good for targeted analysis

### Q: How do I find the file URL, line, and column for file mode?
**A:**
1. Start WMPFDebugger
2. Launch the miniapp
3. Open Chrome DevTools: `devtools://devtools/bundled/inspector.html?ws=127.0.0.1:62000`
4. Navigate to Sources panel
5. Find your target file
6. Click to set a manual breakpoint
7. Note the file URL (full URL in the tab), line number, and column number

### Q: Why do I need to trigger the action twice in XHR mode?
**A:** This is by design:
- **First trigger:** Hits the XHR breakpoint
- AI analyzes the call stack and sets a function breakpoint at the top
- **Second trigger:** Hits the function breakpoint
- Now AI can inject hooks and capture encryption parameters

### Q: How long does AI analysis take?
**A:** Typically:
- Simple analysis: 10-30 seconds
- Complex analysis: 1-3 minutes
- Depends on: AI model speed, code complexity, API latency

---

## Troubleshooting

### Q: "WeChatAppEx.exe process not found" error
**A:** 
1. Make sure WeChat PC is running
2. Launch any miniapp to start WMPF
3. Check Task Manager for WeChatAppEx.exe processes
4. Try restarting WeChat

### Q: "Version config not found" error
**A:** Your WMPF version is not supported. Options:
1. Check [WMPF version support](README.md#support-status)
2. Update to a supported version
3. Follow [ADAPTATION.md](ADAPTATION.md) to add support
4. Open an issue requesting version support

### Q: AI_JS_DEBUGGER won't connect to WMPFDebugger
**A:** Checklist:
- [ ] WMPFDebugger is running (check for "proxy server running" message)
- [ ] Miniapp is launched in WeChat
- [ ] Port 62000 is not blocked by firewall
- [ ] `debug_url` in config.yaml is correct
- [ ] Try connecting with Chrome DevTools manually first

### Q: Breakpoint not triggering
**A:**
- **XHR mode:** Make sure you actually trigger a network request in the miniapp
- **File mode:** Verify the file URL, line, and column are exact (0-indexed)
- Check browser DevTools to confirm the file exists and is loaded
- Look for errors in both WMPFDebugger and AI_JS_DEBUGGER logs

### Q: "Invalid API key" or "Quota exceeded" errors
**A:**
1. Verify API key is correct in config.yaml
2. Check your AI provider's dashboard for quota status
3. Try a different API provider
4. Wait if you've hit rate limits

### Q: "Connection error" or "InternalServerError" with AI API
**A:** This usually means AI_JS_DEBUGGER cannot reach the AI API endpoint:

**For SiliconFlow or other alternative providers:**
1. Check if AI_JS_DEBUGGER uses environment variables instead of config.yaml:
   ```bash
   export OPENAI_API_KEY="your-key"
   export OPENAI_API_BASE="https://api.siliconflow.cn/v1"
   export OPENAI_MODEL="deepseek-ai/DeepSeek-V3.2"
   ```
2. Verify the API endpoint URL is correct
3. Test the API directly with curl:
   ```bash
   curl -X POST https://api.siliconflow.cn/v1/chat/completions \
     -H "Authorization: Bearer your-key" \
     -H "Content-Type: application/json" \
     -d '{"model":"deepseek-ai/DeepSeek-V3.2","messages":[{"role":"user","content":"test"}]}'
   ```
4. Check AI_JS_DEBUGGER logs for detailed error messages
5. Ensure your network can reach the API endpoint (not blocked by firewall/proxy)

**Note:** This is an AI_JS_DEBUGGER configuration issue, not a WMPFDebugger issue. WMPFDebugger only provides the CDP proxy.

### Q: AI analysis produces poor results
**A:**
1. **Try a better model:** Switch from GPT-3.5 to GPT-4
2. **Adjust prompts:** Edit prompt configuration in AI_JS_DEBUGGER settings
3. **Provide more context:** Trigger the action multiple times to gather more data
4. **Check hook injection:** Ensure encryption hooks are enabled
5. **Manual verification:** Use Chrome DevTools to verify captured data

### Q: High memory usage or performance issues
**A:**
1. Close other miniapps in WeChat
2. Restart WMPFDebugger and AI_JS_DEBUGGER
3. Disable unnecessary hooks in config.yaml
4. Use selective breakpoints instead of broad XHR filters
5. Increase timeout values if analysis is timing out

---

## Advanced Topics

### Q: Can I customize the AI prompts?
**A:** Yes! AI_JS_DEBUGGER allows prompt customization in its web interface under "Prompt Configuration". You can tailor prompts for specific analysis needs.

### Q: How do I generate mitmproxy scripts?
**A:** Enable in config.yaml:
```yaml
analysis:
  generate_mitm_script: true
```
Scripts will be generated automatically in the reports directory.

### Q: Can I export debugging data?
**A:** Yes, AI_JS_DEBUGGER saves:
- Analysis reports in `reports/` directory
- Logs in `logs/` directory
- Format options: Markdown, JSON, HTML

### Q: How do I hook custom encryption functions?
**A:** 
1. Identify the function name via DevTools
2. Add custom hook in `AI_JS_DEBUGGER/hooks/`
3. Configure in config.yaml under `hooks.custom_hooks`
4. Refer to AI_JS_DEBUGGER documentation for hook format

### Q: Can I use this with other tools?
**A:** Yes! The CDP proxy can be used with:
- Chrome DevTools (manual debugging)
- Puppeteer (automated testing)
- Other CDP-compatible tools
- Just connect to `ws://127.0.0.1:62000`

---

## Security and Privacy

### Q: Is my data sent to the AI provider?
**A:** Yes, when AI analysis is performed:
- Code snippets from breakpoints
- Variable values and call stacks
- Debugging context
- **Not sent:** Full source code, personal data (unless in variables)

### Q: How do I protect sensitive data?
**A:**
1. Use .gitignore to exclude config files with API keys
2. Review analysis reports before sharing
3. Use local AI models if available (requires AI_JS_DEBUGGER modification)
4. Test with non-sensitive miniapps first

### Q: Can miniapp developers detect this?
**A:** Potentially, yes. Some miniapps may have:
- Anti-debugging checks
- DevTools detection
- Unusual behavior detection
- Use responsibly and ethically

---

## Contributing and Support

### Q: How can I contribute?
**A:**
- Test with different WMPF versions
- Improve documentation
- Report bugs
- Share successful reverse engineering workflows
- Submit pull requests

### Q: Where do I report bugs?
**A:**
- WMPFDebugger issues: https://github.com/wcwq99/WMPFDebugger/issues
- AI_JS_DEBUGGER issues: https://github.com/Valerian7/AI_JS_DEBUGGER/issues

### Q: How do I get help?
**A:**
1. Check this FAQ
2. Read [QUICKSTART.md](QUICKSTART.md) for quick fixes
3. Review [AI_INTEGRATION.md](AI_INTEGRATION.md) for detailed instructions
4. Check both project's GitHub issues
5. Open a new issue with:
   - Your WMPF version
   - Error messages and logs
   - Steps to reproduce

---

## Additional Resources

- **[AI_INTEGRATION.md](AI_INTEGRATION.md)** - Complete integration guide
- **[QUICKSTART.md](QUICKSTART.md)** - Quick reference
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture
- **[DOCS_INDEX.md](DOCS_INDEX.md)** - Documentation index

---

*Last updated: 2026-01*
