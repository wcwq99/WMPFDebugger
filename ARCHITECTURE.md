# WMPFDebugger + AI_JS_DEBUGGER Integration Architecture

This document provides detailed architectural diagrams for the integration between WMPFDebugger and AI_JS_DEBUGGER.

## System Architecture

```mermaid
graph TB
    subgraph WeChat["WeChat PC Environment"]
        MiniApp["WeChat Miniapp<br/>(WMPF Runtime)"]
        WMPF["WMPF Process<br/>(WeChatAppEx.exe)"]
        MiniApp -->|runs in| WMPF
    end
    
    subgraph WMPFDebugger["WMPFDebugger (Node.js)"]
        Frida["Frida Hook<br/>(hook.js)"]
        DebugServer["Debug Server<br/>(ws://localhost:9421)"]
        ProxyServer["CDP Proxy Server<br/>(ws://localhost:62000)"]
        Codex["Protocol Converter<br/>(RemoteDebugCodex)"]
        
        Frida -->|injects into| WMPF
        Frida -->|receives messages| DebugServer
        DebugServer -->|converts protocol| Codex
        Codex -->|CDP messages| ProxyServer
    end
    
    subgraph AIDebugger["AI_JS_DEBUGGER (Python)"]
        FlaskUI["Flask Web UI<br/>(localhost:5001)"]
        CDPClient["CDP Client"]
        Debugger["Auto Debugger"]
        HookInjector["Hook Injector<br/>(AES/RSA hooks)"]
        AIAnalyzer["AI Analyzer"]
        ReportGen["Report Generator"]
        
        FlaskUI -->|controls| CDPClient
        CDPClient -->|debugging commands| Debugger
        Debugger -->|injects| HookInjector
        Debugger -->|captures data| AIAnalyzer
        AIAnalyzer -->|generates| ReportGen
    end
    
    subgraph AI["AI Service"]
        LLM["Large Language Model<br/>(GPT-4/Claude/Qwen)"]
    end
    
    MiniApp <-->|custom protocol| DebugServer
    ProxyServer <-->|CDP WebSocket| CDPClient
    AIAnalyzer -->|API requests| LLM
    
    User["User"] -->|configures| FlaskUI
    User -->|views results| ReportGen
    
    DevTools["Chrome DevTools<br/>(Optional)"] -.->|can also connect| ProxyServer
    
    style MiniApp fill:#e1f5ff
    style WMPF fill:#e1f5ff
    style Frida fill:#ffebee
    style ProxyServer fill:#f3e5f5
    style CDPClient fill:#e8f5e9
    style AIAnalyzer fill:#fff3e0
    style LLM fill:#fce4ec
```

## Data Flow: XHR Breakpoint Mode

```mermaid
sequenceDiagram
    participant User
    participant UI as Flask Web UI
    participant AI as AI_JS_DEBUGGER
    participant CDP as WMPFDebugger<br/>CDP Proxy
    participant Miniapp as WeChat Miniapp
    participant LLM as AI Model

    User->>UI: Configure XHR breakpoint
    User->>UI: Start debugging session
    UI->>AI: Initialize debugger
    AI->>CDP: Connect WebSocket
    CDP-->>AI: Connection established
    
    AI->>CDP: Set XHR breakpoint
    CDP->>Miniapp: Inject breakpoint
    
    User->>Miniapp: Trigger action<br/>(e.g., login)
    Miniapp->>Miniapp: Execute XHR request
    Miniapp-->>CDP: Breakpoint hit
    CDP-->>AI: Paused at XHR
    
    AI->>CDP: Get call stack
    CDP-->>AI: Call stack data
    
    AI->>CDP: Backtrace to top
    AI->>CDP: Set function breakpoint
    
    User->>Miniapp: Trigger again
    Miniapp-->>CDP: Function breakpoint hit
    CDP-->>AI: Paused at function
    
    AI->>CDP: Inject encryption hooks
    AI->>CDP: Resume execution
    Miniapp->>Miniapp: Execute crypto operations
    Miniapp-->>CDP: Hook captured data
    CDP-->>AI: Encryption parameters
    
    AI->>AI: Collect debugging data
    AI->>LLM: Analyze with AI
    LLM-->>AI: Analysis results
    
    AI->>AI: Generate report
    AI->>UI: Display results
    UI-->>User: Show analysis report
```

## Component Communication

```mermaid
graph LR
    subgraph Layer1["Layer 1: Miniapp Runtime"]
        A1["Miniapp JS Code"]
        A2["Crypto Functions"]
        A3["Network APIs"]
    end
    
    subgraph Layer2["Layer 2: Protocol Bridge"]
        B1["Frida Hook"]
        B2["Custom Protocol"]
        B3["CDP Protocol"]
    end
    
    subgraph Layer3["Layer 3: Debug Control"]
        C1["CDP Client"]
        C2["Breakpoint Manager"]
        C3["Hook Manager"]
    end
    
    subgraph Layer4["Layer 4: AI Analysis"]
        D1["Data Collector"]
        D2["AI Analyzer"]
        D3["Report Generator"]
    end
    
    A1 -->|intercepts| B1
    A2 -->|hooks| B1
    A3 -->|monitors| B1
    
    B1 -->|encodes| B2
    B2 -->|converts| B3
    
    B3 -->|controls| C1
    C1 -->|manages| C2
    C1 -->|injects| C3
    
    C2 -->|captures| D1
    C3 -->|extracts| D1
    D1 -->|feeds| D2
    D2 -->|produces| D3
    
    style A2 fill:#ffebee
    style B1 fill:#ffebee
    style C3 fill:#e8f5e9
    style D2 fill:#fff3e0
```

## Setup Flow

```mermaid
flowchart TD
    Start([Start]) --> CheckEnv{Environment<br/>Ready?}
    CheckEnv -->|No| InstallDeps[Install Dependencies:<br/>- Node.js & yarn<br/>- Python 3.11+<br/>- WeChat PC]
    InstallDeps --> CheckEnv
    
    CheckEnv -->|Yes| CloneWMPF[Clone WMPFDebugger]
    CloneWMPF --> InstallWMPF[yarn install]
    
    InstallWMPF --> CloneAI[Clone AI_JS_DEBUGGER]
    CloneAI --> InstallAI[pip install -r requirements.txt]
    
    InstallAI --> ConfigAI[Configure AI_JS_DEBUGGER:<br/>- Set API key<br/>- Set CDP URL<br/>- Configure debugging mode]
    
    ConfigAI --> StartWMPF[Start WMPFDebugger:<br/>npx ts-node src/index.ts]
    StartWMPF --> WaitWMPF{WMPF Ready?}
    WaitWMPF -->|No| WaitWMPF
    
    WaitWMPF -->|Yes| LaunchApp[Launch Target Miniapp<br/>in WeChat]
    LaunchApp --> StartAI[Start AI_JS_DEBUGGER:<br/>python run_flask.py]
    
    StartAI --> OpenUI[Open Web UI:<br/>http://localhost:5001]
    OpenUI --> ConfigSession[Configure Debug Session]
    
    ConfigSession --> StartDebug[Start Debugging]
    StartDebug --> TriggerAction[Trigger Target Action<br/>in Miniapp]
    
    TriggerAction --> AIProcess{AI Processing}
    AIProcess --> CollectData[Collect Debug Data]
    CollectData --> Analyze[AI Analysis]
    Analyze --> GenReport[Generate Report]
    
    GenReport --> ViewResults[View Results in UI]
    ViewResults --> Done([Complete])
    
    style Start fill:#e8f5e9
    style Done fill:#e8f5e9
    style ConfigAI fill:#fff3e0
    style Analyze fill:#fff3e0
    style GenReport fill:#e1f5ff
```

## Key Integration Points

### 1. CDP WebSocket Connection
- **WMPFDebugger exposes**: `ws://127.0.0.1:62000` (default)
- **AI_JS_DEBUGGER connects to**: Same WebSocket endpoint
- **Protocol**: Standard Chrome DevTools Protocol (CDP)

### 2. Hook Injection
- **Frida hooks**: Injected by WMPFDebugger into WMPF process
- **JS hooks**: Injected by AI_JS_DEBUGGER via CDP Runtime.evaluate
- **Target**: Crypto functions (AES, RSA, etc.)

### 3. Data Extraction
- **Breakpoints**: Set via CDP Debugger.setBreakpoint
- **Variable inspection**: Via CDP Runtime.getProperties
- **Call stack**: Via CDP Debugger.getStackTrace
- **Network data**: Via CDP Network domain events

### 4. AI Analysis Pipeline
1. Collect debugging context (code, variables, call stack)
2. Extract encryption parameters (keys, IVs, algorithms)
3. Send to AI model with analysis prompt
4. Parse AI response for insights
5. Generate human-readable report
6. Optionally generate mitmproxy script

## Security Considerations

```mermaid
flowchart LR
    subgraph Safe["✅ Safe Operations"]
        S1["Read-only debugging"]
        S2["Local connections only"]
        S3["No network sniffing"]
    end
    
    subgraph Sensitive["⚠️ Sensitive Data"]
        T1["Encryption keys"]
        T2["User credentials"]
        T3["API tokens"]
    end
    
    subgraph Protection["🔒 Protections"]
        P1["Store API keys securely"]
        P2["Don't commit config files"]
        P3["Use for authorized testing only"]
    end
    
    S1 -.->|may access| T1
    S1 -.->|may access| T2
    S1 -.->|may access| T3
    
    T1 -->|requires| P1
    T2 -->|requires| P1
    T3 -->|requires| P1
    
    P1 --> P2
    P2 --> P3
    
    style Safe fill:#e8f5e9
    style Sensitive fill:#ffebee
    style Protection fill:#e3f2fd
```

## Troubleshooting Decision Tree

```mermaid
flowchart TD
    Problem[Integration Problem] --> Type{Problem Type?}
    
    Type -->|Connection| Conn{WMPFDebugger<br/>Running?}
    Conn -->|No| StartWMPF[Start WMPFDebugger]
    Conn -->|Yes| CheckPort{Port 62000<br/>Available?}
    CheckPort -->|No| ChangePort[Change CDP_PORT]
    CheckPort -->|Yes| CheckMiniapp{Miniapp<br/>Launched?}
    CheckMiniapp -->|No| LaunchMiniapp[Launch Miniapp]
    CheckMiniapp -->|Yes| CheckConfig[Check AI_JS_DEBUGGER<br/>config.yaml]
    
    Type -->|Breakpoint| BP{Breakpoint Mode?}
    BP -->|XHR| TriggerReq[Trigger Request<br/>in Miniapp]
    BP -->|File| VerifyLoc[Verify File URL,<br/>Line, Column]
    
    Type -->|AI Analysis| AI{API Key Valid?}
    AI -->|No| SetKey[Set Valid API Key]
    AI -->|Yes| CheckQuota{Sufficient<br/>Quota?}
    CheckQuota -->|No| AddQuota[Add API Credits]
    CheckQuota -->|Yes| TryModel[Try Different Model]
    
    Type -->|Data Collection| Data{Hook Injected?}
    Data -->|No| CheckHook[Check Hook Config]
    Data -->|Yes| CheckScope[Verify Variable Scope]
    
    StartWMPF --> Retry[Retry Connection]
    ChangePort --> Retry
    LaunchMiniapp --> Retry
    CheckConfig --> Retry
    TriggerReq --> Retry
    VerifyLoc --> Retry
    SetKey --> Retry
    AddQuota --> Retry
    TryModel --> Retry
    CheckHook --> Retry
    CheckScope --> Retry
    
    Retry --> Success{Works?}
    Success -->|Yes| Done([Resolved])
    Success -->|No| Support[Check Logs /<br/>Ask for Help]
    
    style Problem fill:#ffebee
    style Done fill:#e8f5e9
    style Support fill:#fff3e0
```

## Performance Considerations

| Component | Resource Usage | Optimization Tips |
|-----------|---------------|-------------------|
| **WMPFDebugger** | Low CPU, ~100MB RAM | Keep frida hooks minimal |
| **Frida Hook** | Minimal overhead | Avoid hooking hot paths |
| **CDP Proxy** | Network I/O bound | Use local connections only |
| **AI_JS_DEBUGGER** | Medium CPU, ~500MB RAM | Limit concurrent sessions |
| **AI API Calls** | Network latency | Use faster models for iteration |
| **Hook Injection** | JavaScript overhead | Selective hook injection |

## Limitations and Workarounds

| Limitation | Impact | Workaround |
|------------|--------|------------|
| WMPF version specific | May not work with all versions | Check supported versions in README |
| Single miniapp debugging | Can't debug multiple simultaneously | Use multiple ports/instances |
| Anti-debug detection | Some miniapps may detect debugging | Try different hook strategies |
| AI model dependency | Analysis quality varies | Use GPT-4 or Claude for best results |
| Network encryption | Additional layers may obscure data | Combine with network proxy tools |
| Performance impact | Debugging slows execution | Use selective breakpoints |

---

For implementation details and usage instructions, see [AI_INTEGRATION.md](AI_INTEGRATION.md).
