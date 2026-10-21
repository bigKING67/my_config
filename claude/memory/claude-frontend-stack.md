---
name: claude-frontend-stack
description: Claude Code 前端设计任务栈——design-craft 基线 + browser67 浏览器运行时的激活方式与规则入口
metadata: 
  node_type: memory
  type: project
  originSessionId: cae8b958-a859-46bc-a7e8-0ee5d61d0fb1
  modified: 2026-09-27T05:09:26.526Z
---

Claude Code 的前端设计任务栈已激活（2026-07-24），与 codex 共享同一份源与运行时。

- **skill 软链**（源在 `~/.agents/skills`，见 [[skills-storage-and-recovery]]）：`design-craft`（设计基线）、`browser67`、`js-reverse` 均软链到 `~/.claude/skills/`（`tmwd-browser-mcp` 已不存在）。
- **浏览器一律走 browser67，不用 Playwright / chrome-devtools**（已从 Claude 移除）：
  - `tmwd_browser` / `js-reverse` 两个 MCP server 已注册到 `~/.claude.json`（user scope），command=`node <browser67>/src/mcp/{browser,js-reverse}/server.mjs`，共用 4 个 `BROWSER_STRUCTURED_TMWD_*` env。
  - 依赖本地 WS 桥 `ws://127.0.0.1:18765` + `http://127.0.0.1:18766/link`（与 codex 共用，桥未起时按 browser67 SKILL 用 `browser67 doctor`/`setup` 拉起）。
  - **路由真源**：`~/Documents/sixseven/codeproject/browser67/docs/codex-integration.md`（Tool routing / Tab ownership policy / JS reverse boundary / Failure policy），codex 与 Claude 共用；rules 只留摘要不复制枚举。
  - Playwright MCP 已 `claude mcp remove`；chrome-devtools plugin 在 `settings.json` 置 `false`。
- **file:// 打不开**（2026-09-27 已确认原因）：打开 `file://` 页面后，后续操作都报 `NO_SESSION`。原因是 browser67 扩展源码 `extension/background.js` 里 `isScriptable = url => /^https?:/.test(url)` 把非 http(s) 的标签页过滤掉了；Chrome 的"允许访问文件网址"开关已打开，不是原因。在修改 browser67 之前，本地页面先用 `python3 -m http.server` 起服务再验证，并告知用户验证地址变了。
- **规则**：全局入口在 `~/.claude/CLAUDE.md` 第 2.3 节（现为一行指针）；详规则 `~/.claude/rules/frontend.md`（codex→Claude 映射：`AGENTS.md`→`CLAUDE.md`，route_plan.sh 可选，委派用 Explore/Plan/general-purpose）。
- MCP server 路径硬编码指向 `~/Documents/sixseven/codeproject/browser67`；项目迁移需同步更新（codex 侧同理）。
- **node 绝对路径**：两个 server 的 `command` 固定为 `/Users/gaoqian/.nvm/versions/node/v24.18.0/bin/node`（不用裸 `node`，因 node 是 nvm 装的、GUI 启动的 Claude 可能没有 nvm PATH）。nvm 升级 node 版本后需在 `~/.claude.json` 同步这两处。
- **桥恢复命令**（`browser67` CLI 不在 PATH）：`cd ~/Documents/sixseven/codeproject/browser67 && npm run hub:status|doctor|hub:start`。桥进程是 `src/tmwd-hub.mjs`，外部常驻，非 MCP 拉起。
