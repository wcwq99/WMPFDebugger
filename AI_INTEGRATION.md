# AI-Powered WeChat Miniapp Reverse Engineering

[English](#english) | [中文](#中文)

---

## English

### Overview

This guide demonstrates how to integrate **WMPFDebugger** with **[AI_JS_DEBUGGER](https://github.com/Valerian7/AI_JS_DEBUGGER)** to enable AI-powered automatic reverse engineering of WeChat miniapps.

**WMPFDebugger** exposes WeChat miniapps through the Chrome DevTools Protocol (CDP), while **AI_JS_DEBUGGER** uses CDP to automatically analyze JavaScript encryption algorithms, extract keys, and generate analysis reports using AI.

### Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  WeChat Miniapp │ ◄─────► │  WMPFDebugger    │ ◄─────► │ AI_JS_DEBUGGER  │
│   (WMPF)        │  Frida  │  CDP Proxy       │   CDP   │  (AI Analysis)  │
└─────────────────┘         └──────────────────┘         └─────────────────┘
                                   ▲                              │
                                   │ ws://127.0.0.1:62000        │
                                   │                              ▼
                            ┌──────┴────────┐            ┌─────────────────┐
                            │  Chrome       │            │  AI Model API   │
                            │  DevTools     │            │  (GPT/Claude)   │
                            └───────────────┘            └─────────────────┘
```

### Prerequisites

#### For WMPFDebugger
- Node.js (LTS v22+)
- yarn package manager
- Chromium-based browser (Chrome, Edge, etc.)
- WeChat PC with WMPF plugin

#### For AI_JS_DEBUGGER
- Python 3.11+
- Chrome or Edge browser
- AI Model API key (OpenAI-compatible API: GPT, Claude, Qwen, DeepSeek, etc.)

### Installation

#### Step 1: Setup WMPFDebugger

```bash
# Clone and install WMPFDebugger
git clone https://github.com/wcwq99/WMPFDebugger
cd WMPFDebugger
yarn install
```

#### Step 2: Setup AI_JS_DEBUGGER

```bash
# Clone AI_JS_DEBUGGER in a separate directory
cd ..
git clone https://github.com/Valerian7/AI_JS_DEBUGGER.git
cd AI_JS_DEBUGGER
pip install -r requirements.txt
```

### Configuration

#### Step 1: Configure AI_JS_DEBUGGER for WMPFDebugger

Edit `AI_JS_DEBUGGER/config.yaml` to configure the CDP connection:

```yaml
# CDP Configuration
cdp:
  # Use WMPFDebugger's CDP endpoint instead of browser directly
  debug_url: "ws://127.0.0.1:62000"
  # Set to manual mode since WMPFDebugger manages the connection
  auto_connect: false

# AI Model Configuration
ai:
  api_key: "your-api-key-here"
  api_base: "https://api.openai.com/v1"  # Or other compatible endpoints
  model: "gpt-4"  # Or gpt-3.5-turbo, claude-3, etc.

# Debugging Configuration
debug:
  # Enable XHR breakpoint for API analysis
  xhr_breakpoint: true
  # File breakpoint settings
  file_breakpoint:
    enabled: true
    file_url: ""  # Leave empty for XHR mode
    line: 0
    column: 0
```

### Usage

#### Step 1: Start WMPFDebugger

In the WMPFDebugger directory:

```bash
cd WMPFDebugger
npx ts-node src/index.ts
```

You should see:
```
[server] debug server running on ws://localhost:9421
[server] proxy server running on ws://localhost:62000
[frida] script loaded, WMPF version: 18151, pid: xxxxx
```

#### Step 2: Launch the Target Miniapp

Open WeChat PC and navigate to the miniapp you want to reverse engineer.

> **Important:** Launch the miniapp BEFORE connecting AI_JS_DEBUGGER, otherwise you may need to restart the process.

#### Step 3: Start AI_JS_DEBUGGER

In the AI_JS_DEBUGGER directory:

```bash
cd AI_JS_DEBUGGER
python3 run_flask.py
```

Access the web interface at: `http://localhost:5001`

#### Step 4: Configure AI Debugging Session

1. **Debugging Configuration Page:**
   - Select debugging mode (XHR or File breakpoint)
   - For API reverse engineering, use **XHR mode** (recommended)
   - Configure breakpoint conditions

2. **Connect to WMPFDebugger:**
   - The AI debugger will automatically connect to `ws://127.0.0.1:62000`
   - Verify connection status in the web interface

3. **Start Debugging:**
   - Trigger the target functionality in the miniapp (e.g., login, API request)
   - AI_JS_DEBUGGER will automatically:
     - Set breakpoints
     - Capture call stacks
     - Extract encryption parameters
     - Analyze algorithms with AI
     - Generate analysis reports

#### Step 5: Review Results

The AI analysis will provide:
- Encryption/decryption algorithm identification
- Key extraction (AES, RSA, etc.)
- Parameter generation logic
- mitmproxy script for request reproduction
- Detailed analysis report

### Advanced Usage

#### Targeting Specific JavaScript Files

If you know which file contains the encryption logic:

1. Open Chrome DevTools: `devtools://devtools/bundled/inspector.html?ws=127.0.0.1:62000`
2. Navigate to Sources panel
3. Find the target JS file and note its URL, line, and column
4. Configure AI_JS_DEBUGGER with file breakpoint mode:

```yaml
debug:
  file_breakpoint:
    enabled: true
    file_url: "https://servicewechat.com/wxapp/main.js"
    line: 1245
    column: 15
```

#### Multiple Miniapp Debugging

For debugging multiple miniapps or sessions:
- Change `CDP_PORT` in `WMPFDebugger/src/index.ts`
- Update the corresponding `debug_url` in AI_JS_DEBUGGER's `config.yaml`
- Run multiple instances on different ports

### Troubleshooting

#### Connection Issues

**Problem:** AI_JS_DEBUGGER cannot connect to WMPFDebugger

**Solution:**
- Ensure WMPFDebugger is running and showing "proxy server running"
- Verify the miniapp is launched in WeChat
- Check that no other application is using port 62000
- Try manually connecting with DevTools first to verify CDP is working

#### No Breakpoint Triggers

**Problem:** Breakpoints are not triggered

**Solution:**
- In XHR mode, ensure you trigger the actual network request in the miniapp
- For file breakpoints, verify the file URL, line, and column are correct
- Check the console output in both WMPFDebugger and AI_JS_DEBUGGER for errors

#### AI Analysis Incomplete

**Problem:** AI analysis fails or provides incomplete results

**Solution:**
- Verify your AI API key is valid and has sufficient quota
- Try a different AI model (e.g., switch from GPT-3.5 to GPT-4)
- Check the prompt configuration in AI_JS_DEBUGGER settings
- Review the captured debugging data to ensure sufficient context was collected

### Limitations

1. **WMPF Version Support:** Only tested with WMPF versions supported by WMPFDebugger (see README.md)
2. **Network Encryption:** Some miniapps use additional network-level encryption that may require further analysis
3. **Anti-Debug:** Miniapps with anti-debugging measures may require additional configuration
4. **AI Model Dependency:** Analysis quality depends on the AI model's capabilities

### Security and Legal Notice

**IMPORTANT:** This tool is for educational and security research purposes only.

- Only analyze miniapps you have permission to test
- Respect intellectual property and terms of service
- Do not use for unauthorized access or data extraction
- Follow all applicable laws and regulations

---

## 中文

### 概述

本指南演示如何将 **WMPFDebugger** 与 **[AI_JS_DEBUGGER](https://github.com/Valerian7/AI_JS_DEBUGGER)** 集成，实现 AI 自动化微信小程序逆向分析。

**WMPFDebugger** 通过 Chrome 调试协议（CDP）暴露微信小程序，而 **AI_JS_DEBUGGER** 使用 CDP 自动分析 JavaScript 加密算法、提取密钥，并使用 AI 生成分析报告。

### 架构

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  微信小程序      │ ◄─────► │  WMPFDebugger    │ ◄─────► │ AI_JS_DEBUGGER  │
│   (WMPF)        │  Frida  │  CDP 代理        │   CDP   │  (AI 分析)      │
└─────────────────┘         └──────────────────┘         └─────────────────┘
                                   ▲                              │
                                   │ ws://127.0.0.1:62000        │
                                   │                              ▼
                            ┌──────┴────────┐            ┌─────────────────┐
                            │  Chrome       │            │  AI 模型 API    │
                            │  DevTools     │            │  (GPT/Claude)   │
                            └───────────────┘            └─────────────────┘
```

### 环境要求

#### WMPFDebugger 需求
- Node.js (LTS v22+)
- yarn 包管理器
- 基于 Chromium 的浏览器（Chrome、Edge 等）
- 安装了 WMPF 插件的微信 PC 版

#### AI_JS_DEBUGGER 需求
- Python 3.11+
- Chrome 或 Edge 浏览器
- AI 模型 API 密钥（兼容 OpenAI 的 API：GPT、Claude、Qwen、DeepSeek 等）

### 安装

#### 第一步：安装 WMPFDebugger

```bash
# 克隆并安装 WMPFDebugger
git clone https://github.com/wcwq99/WMPFDebugger
cd WMPFDebugger
yarn install
```

#### 第二步：安装 AI_JS_DEBUGGER

```bash
# 在另一个目录克隆 AI_JS_DEBUGGER
cd ..
git clone https://github.com/Valerian7/AI_JS_DEBUGGER.git
cd AI_JS_DEBUGGER
pip install -r requirements.txt
```

### 配置

#### 第一步：配置 AI_JS_DEBUGGER 连接 WMPFDebugger

编辑 `AI_JS_DEBUGGER/config.yaml` 配置 CDP 连接：

```yaml
# CDP 配置
cdp:
  # 使用 WMPFDebugger 的 CDP 端点，而不是直接连接浏览器
  debug_url: "ws://127.0.0.1:62000"
  # 设置为手动模式，因为 WMPFDebugger 管理连接
  auto_connect: false

# AI 模型配置
ai:
  api_key: "your-api-key-here"
  api_base: "https://api.openai.com/v1"  # 或其他兼容端点
  model: "gpt-4"  # 或 gpt-3.5-turbo、claude-3 等

# 调试配置
debug:
  # 启用 XHR 断点用于 API 分析
  xhr_breakpoint: true
  # 文件断点设置
  file_breakpoint:
    enabled: true
    file_url: ""  # XHR 模式下留空
    line: 0
    column: 0
```

### 使用方法

#### 第一步：启动 WMPFDebugger

在 WMPFDebugger 目录中：

```bash
cd WMPFDebugger
npx ts-node src/index.ts
```

你应该看到：
```
[server] debug server running on ws://localhost:9421
[server] proxy server running on ws://localhost:62000
[frida] script loaded, WMPF version: 18151, pid: xxxxx
```

#### 第二步：启动目标小程序

打开微信 PC 版，进入你想要逆向分析的小程序。

> **重要：** 在连接 AI_JS_DEBUGGER 之前启动小程序，否则可能需要重新启动流程。

#### 第三步：启动 AI_JS_DEBUGGER

在 AI_JS_DEBUGGER 目录中：

```bash
cd AI_JS_DEBUGGER
python3 run_flask.py
```

访问 Web 界面：`http://localhost:5001`

#### 第四步：配置 AI 调试会话

1. **调试配置页面：**
   - 选择调试模式（XHR 或文件断点）
   - 对于 API 逆向工程，推荐使用 **XHR 模式**
   - 配置断点条件

2. **连接到 WMPFDebugger：**
   - AI 调试器将自动连接到 `ws://127.0.0.1:62000`
   - 在 Web 界面验证连接状态

3. **开始调试：**
   - 在小程序中触发目标功能（例如登录、API 请求）
   - AI_JS_DEBUGGER 将自动：
     - 设置断点
     - 捕获调用堆栈
     - 提取加密参数
     - 使用 AI 分析算法
     - 生成分析报告

#### 第五步：查看结果

AI 分析将提供：
- 加密/解密算法识别
- 密钥提取（AES、RSA 等）
- 参数生成逻辑
- 用于请求重现的 mitmproxy 脚本
- 详细分析报告

### 高级用法

#### 定位特定 JavaScript 文件

如果你知道哪个文件包含加密逻辑：

1. 打开 Chrome DevTools：`devtools://devtools/bundled/inspector.html?ws=127.0.0.1:62000`
2. 导航到 Sources 面板
3. 找到目标 JS 文件并记录其 URL、行号和列号
4. 使用文件断点模式配置 AI_JS_DEBUGGER：

```yaml
debug:
  file_breakpoint:
    enabled: true
    file_url: "https://servicewechat.com/wxapp/main.js"
    line: 1245
    column: 15
```

#### 调试多个小程序

对于调试多个小程序或会话：
- 在 `WMPFDebugger/src/index.ts` 中更改 `CDP_PORT`
- 更新 AI_JS_DEBUGGER 的 `config.yaml` 中相应的 `debug_url`
- 在不同端口上运行多个实例

### 故障排除

#### 连接问题

**问题：** AI_JS_DEBUGGER 无法连接到 WMPFDebugger

**解决方案：**
- 确保 WMPFDebugger 正在运行并显示 "proxy server running"
- 验证小程序已在微信中启动
- 检查没有其他应用程序使用端口 62000
- 尝试先用 DevTools 手动连接以验证 CDP 是否工作

#### 断点未触发

**问题：** 断点没有被触发

**解决方案：**
- 在 XHR 模式下，确保在小程序中触发实际的网络请求
- 对于文件断点，验证文件 URL、行号和列号是否正确
- 检查 WMPFDebugger 和 AI_JS_DEBUGGER 的控制台输出是否有错误

#### AI 分析不完整

**问题：** AI 分析失败或提供不完整的结果

**解决方案：**
- 验证你的 AI API 密钥有效且有足够的配额
- 尝试不同的 AI 模型（例如从 GPT-3.5 切换到 GPT-4）
- 检查 AI_JS_DEBUGGER 设置中的提示词配置
- 查看捕获的调试数据，确保收集了足够的上下文

### 限制

1. **WMPF 版本支持：** 仅在 WMPFDebugger 支持的 WMPF 版本上测试（参见 README.md）
2. **网络加密：** 某些小程序使用额外的网络级加密，可能需要进一步分析
3. **反调试：** 具有反调试措施的小程序可能需要额外配置
4. **AI 模型依赖：** 分析质量取决于 AI 模型的能力

### 安全和法律声明

**重要：** 此工具仅用于教育和安全研究目的。

- 仅分析你有权限测试的小程序
- 尊重知识产权和服务条款
- 不要用于未经授权的访问或数据提取
- 遵守所有适用的法律法规

---

## References / 参考资源

- [WMPFDebugger Repository](https://github.com/wcwq99/WMPFDebugger)
- [AI_JS_DEBUGGER Repository](https://github.com/Valerian7/AI_JS_DEBUGGER)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)

## Contributing / 贡献

If you encounter issues or have improvements for this integration guide, please submit an issue or pull request.

如果你遇到问题或对本集成指南有改进建议，请提交 Issue 或 Pull Request。
