import { promises } from "node:fs";
import { EventEmitter } from "node:events";
import path from "node:path";
import { spawn, execSync } from "node:child_process";
import * as os from "node:os";
import WebSocket, { WebSocketServer } from "ws";

const codex = require("./third-party/RemoteDebugCodex.js");
const messageProto = require("./third-party/WARemoteDebugProtobuf.js");


class DebugMessageEmitter extends EventEmitter { };


// default debugging port, do not change
const DEBUG_PORT = 9421;
// CDP port, change to whatever you like
// use this port by navigating to devtools://devtools/bundled/inspector.html?ws=127.0.0.1:${CDP_PORT}
const CDP_PORT = 62000;
// debug switch
const DEBUG = false;

const debugMessageEmitter = new DebugMessageEmitter();

const bufferToHexString = (buffer: ArrayBuffer) => {
    return Array.from(new Uint8Array(buffer)).map(byte => byte.toString(16).padStart(2, '0')).join("");
}

const debug_server = () => {
    const wss = new WebSocketServer({ port: DEBUG_PORT });
    console.log(`[server] debug server running on ws://localhost:${DEBUG_PORT}`);

    let messageCounter = 0;

    const onMessage = (message: ArrayBuffer) => {
        DEBUG && console.log(`[client] received raw message (hex): ${bufferToHexString(message)}`);
        let unwrappedData: any = null;
        try {
            const decodedData = messageProto.mmbizwxadevremote.WARemoteDebug_DebugMessage.decode(message);
            unwrappedData = codex.unwrapDebugMessageData(decodedData);
            DEBUG && console.log(`[client] [DEBUG] decoded data:`);
            DEBUG && console.dir(unwrappedData)
        } catch (e) {
            console.error(`[client] err: ${e}`);
        }

        if (unwrappedData === null) {
            return;
        }

        if (unwrappedData.category === "chromeDevtoolsResult") {
            // need to proxy to CDP client
            debugMessageEmitter.emit("cdpmessage", unwrappedData.data.payload);
        }
    }

    wss.on("connection", (ws: WebSocket) => {
        console.log("[conn] miniapp client connected");
        ws.on("message", onMessage);
        ws.on("error", (err) => { console.error("[client] err:", err) });
        ws.on("close", () => { console.log("[client] client disconnected") });
    });

    debugMessageEmitter.on("proxymessage", (message: string) => {
        wss && wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                // encode CDP and send to miniapp
                // wrapDebugMessageData(data, category, compressAlgo)
                const rawPayload = {
                    jscontext_id: "",
                    op_id: Math.round(100 * Math.random()),
                    payload: message.toString()
                };
                DEBUG && console.log(rawPayload);
                const wrappedData = codex.wrapDebugMessageData(rawPayload, "chromeDevtools", 0);
                const outData = {
                    seq: ++messageCounter,
                    category: "chromeDevtools",
                    data: wrappedData.buffer,
                    compressAlgo: 0,
                    originalSize: wrappedData.originalSize
                }
                const encodedData = messageProto.mmbizwxadevremote.WARemoteDebug_DebugMessage.encode(outData).finish();
                client.send(encodedData, { binary: true });
            }
        });
    });
}

const proxy_server = () => {
    const wss = new WebSocketServer({ port: CDP_PORT });
    console.log(`[server] proxy server running on ws://localhost:${CDP_PORT}`);

    const onMessage = (message: string) => {
        debugMessageEmitter.emit("proxymessage", message);
    }

    wss.on("connection", (ws: WebSocket) => {
        console.log("[conn] CDP client connected");
        ws.on("message", onMessage);
        ws.on("error", (err) => { console.error("[client] CDP err:", err) });
        ws.on("close", () => { console.log("[client] CDP client disconnected") });
    });

    debugMessageEmitter.on("cdpmessage", (message: string) => {
        wss && wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                // send CDP message to devtools
                client.send(message);
            }
        });
    });
}

const frida_server = async () => {
    // 使用 Windows 命令获取进程信息
    const getWmpfProcessInfo = (): { pid: number; path: string } | null => {
        try {
            // 使用 PowerShell Get-CimInstance 获取 WeChatAppEx.exe 进程信息（兼容新版 Windows）
            const output = execSync(
                'powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \\"Name=\'WeChatAppEx.exe\'\\" | Select-Object ProcessId,ExecutablePath | ConvertTo-Json"',
                {
                    encoding: 'utf-8',
                    windowsHide: true
                }
            );

            if (!output.trim()) {
                return null;
            }

            // 解析 JSON 输出
            let processes = JSON.parse(output.trim());

            // 如果只有一个进程，PowerShell 返回的是对象而不是数组
            if (!Array.isArray(processes)) {
                processes = [processes];
            }

            if (processes.length === 0) {
                return null;
            }

            // 获取父进程（路径最短或第一个）
            let bestMatch: { pid: number; path: string } | null = null;
            for (const proc of processes) {
                const pid = proc.ProcessId;
                const execPath = proc.ExecutablePath;
                if (pid && execPath) {
                    if (!bestMatch || execPath.length < bestMatch.path.length) {
                        bestMatch = { pid, path: execPath };
                    }
                }
            }
            return bestMatch;
        } catch (e) {
            console.error("[frida] Error getting process info:", e);
            return null;
        }
    };

    const processInfo = getWmpfProcessInfo();
    if (!processInfo) {
        throw new Error("[frida] WeChatAppEx.exe process not found");
    }

    const wmpfPid = processInfo.pid;
    const wmpfProcessPath = processInfo.path;

    console.log(`[frida] Found process: pid=${wmpfPid}, path=${wmpfProcessPath}`);

    // 从路径中提取版本号 (路径格式类似: C:\...\3.9.12.xxx\WeChatAppEx.exe)
    const wmpfVersionMatch = wmpfProcessPath.match(/(\d+)/g);
    const wmpfVersion = wmpfVersionMatch && wmpfVersionMatch.length > 0 ? Number(wmpfVersionMatch[wmpfVersionMatch.length - 1]) : 0;

    console.log(`[frida] Version matches: ${wmpfVersionMatch}, detected version: ${wmpfVersion}`);

    if (wmpfVersion === 0) {
        throw new Error(`[frida] error in find wmpf version from path: ${wmpfProcessPath}`);
    }

    // 获取项目根目录
    const projectRoot = path.dirname(process.execPath);

    // 查找 hook 脚本
    let scriptPath: string | null = null;
    const possibleScriptPaths = [
        path.join(projectRoot, "frida", "hook.js"),
        path.join(projectRoot, "..", "frida", "hook.js"),
        path.join(process.cwd(), "frida", "hook.js")
    ];

    for (const p of possibleScriptPaths) {
        try {
            await promises.access(p);
            scriptPath = p;
            break;
        } catch { }
    }

    if (!scriptPath) {
        throw new Error("[frida] hook script not found");
    }

    // 查找配置文件
    let configPath: string | null = null;
    const possibleConfigPaths = [
        path.join(projectRoot, "frida", "config", `addresses.${wmpfVersion}.json`),
        path.join(projectRoot, "..", "frida", "config", `addresses.${wmpfVersion}.json`),
        path.join(process.cwd(), "frida", "config", `addresses.${wmpfVersion}.json`)
    ];

    for (const p of possibleConfigPaths) {
        try {
            await promises.access(p);
            configPath = p;
            break;
        } catch { }
    }

    if (!configPath) {
        throw new Error(`[frida] version config not found: ${wmpfVersion}`);
    }

    // 读取并处理脚本内容，替换配置
    const scriptContent = (await promises.readFile(scriptPath)).toString();
    const configContent = JSON.stringify(JSON.parse((await promises.readFile(configPath)).toString()));
    const processedScript = scriptContent.replace("@@CONFIG@@", configContent);

    // 写入临时脚本文件
    const tempScriptPath = path.join(os.tmpdir(), `wmpf_hook_${Date.now()}.js`);
    await promises.writeFile(tempScriptPath, processedScript);

    // 查找 frida-inject
    let fridaInjectPath: string | null = null;
    const possibleFridaPaths = [
        path.join(projectRoot, "frida-inject.exe"),
        path.join(projectRoot, "..", "frida-inject.exe"),
        path.join(process.cwd(), "frida-inject.exe")
    ];

    for (const p of possibleFridaPaths) {
        try {
            await promises.access(p);
            fridaInjectPath = p;
            break;
        } catch { }
    }

    if (!fridaInjectPath) {
        throw new Error("[frida] frida-inject.exe not found. Please place it in the same directory as WMPFDebugger.exe");
    }

    console.log(`[frida] Injecting script, WMPF version: ${wmpfVersion}, pid: ${wmpfPid}`);

    // 使用 frida-inject 注入脚本
    const fridaProcess = spawn(fridaInjectPath, [
        '-p', String(wmpfPid),
        '-s', tempScriptPath,
        '--eternalize'  // 保持脚本运行
    ], {
        stdio: ['ignore', 'pipe', 'pipe'],
        windowsHide: true
    });

    fridaProcess.stdout.on('data', (data: Buffer) => {
        console.log('[frida]', data.toString().trim());
    });

    fridaProcess.stderr.on('data', (data: Buffer) => {
        console.error('[frida error]', data.toString().trim());
    });

    fridaProcess.on('close', (code: number | null) => {
        // 清理临时文件
        promises.unlink(tempScriptPath).catch(() => { });
        if (code === 0) {
            console.log(`[frida] script loaded successfully`);
        } else {
            console.error(`[frida] injection failed with code ${code}`);
        }
    });

    fridaProcess.on('error', (err: Error) => {
        console.error('[frida] Failed to start frida-inject:', err.message);
    });
}

const main = async () => {
    debug_server();
    proxy_server();
    frida_server();
}

(async () => {
    await main();
})();



