# 前端设计任务规则（Claude Code）

> 承接 `~/.claude/CLAUDE.md` 的前端专项合同。设计基线 skill 为 `design-craft`，浏览器运行时为 `browser67`。
> 本文件是 codex `~/.codex/rules/frontend.md` 的 Claude Code 适配版：保留质量合同，去掉 codex 专属机器路由。

## 触发与基线

- 前端 / UI / UX / 视觉 / 设计工程任务（页面、组件、样式、交互、信息架构、可访问性、可视化、视觉还原）→ **`design-craft` 是唯一设计基线**。
- Claude Code 按 skill `description` 自动触发。命中后先读 `~/.claude/skills/design-craft/SKILL.md`，再按其 Reference routing **最小加载** references，不整包读取。
- 覆盖 web / iOS / Android / adaptive；默认 `platform=web`，仅当源码与产品证据确认原生目标时才升级。mobile 视口 / PWA / Capacitor / WebView 本身不构成 native。

## 分档

- `L0`：文案、间距、色值、局部字体等微调，直接完成。
- `L1-F`：功能页面、组件、交互实现。
- `L1-V`：常规视觉优化。
- `L2`：新页面、重设计、跨模块视觉统一、高风险视觉改动，先明确验收与回滚。
- `frontend_tier` 表质量/证据等级；工程风险另用 `change_risk=low|normal|high|system` 表达。tier 不强制多代理。

## codex → Claude Code 映射合同

design-craft SKILL.md 为 codex 编写，以下 codex 专属约定在 Claude Code 语境按此映射：

- **Authority 顺序**里的 `AGENTS.md` → 读就近的 **`CLAUDE.md`**（项目级优先，再全局）。`PRODUCT.md`（产品/平台/用户/可访问性）与 `DESIGN.md`（视觉/tokens/组件/主题/motion）约定不变；显式路径优先，其次向上发现。可见视觉变更必须读取 authority；纯 plumbing 可标 `visual_contract_required=false`。
- **`~/.codex/tools/frontend_route_plan.sh`** → **可选**。Claude 侧不强制跑 codex 的 route 机器合同；如需结构化分档参考可只读调用，但不依赖其 telemetry / orchestration 输出。
- **委派** → 用 Claude 的 `Explore` / `Plan` / `general-purpose` subagent；不套用 codex 的 `delegation-authorization` 机器字段。route / 候选 skill **不等于执行**，只报告实际读取并应用的 skill。
- **维护脚本**（`$DESIGN_CRAFT_HOME`、`codex_route_pack.py`、`upstream_absorption_report.py`、`agents/openai.yaml`）→ Claude 侧忽略。design-craft 的只读检测/审计脚本（`design_craft_detect.sh` 等）可用，`python3` 已就绪，upstream detector 显示 degraded 属正常降级。

## 浏览器验证 —— 一律走 browser67

**禁止**使用 Playwright / chrome-devtools。所有浏览器操作、验证、截图、取证通过 **browser67** 运行时（用户自研，与 codex 共用同一 WS 桥）。

**路由真源**：browser67 完整集成与路由规则见 `~/Documents/sixseven/codeproject/craft67/packages/browser67/docs/codex-integration.md`（Tool routing / Tab ownership policy / JS reverse boundary / Failure policy）。它是 codex 与 Claude 共用的权威文档；本节只留常用摘要，边界情况以真源为准，不在此复制完整枚举。

**工具分工**（对应真源 Tool routing）：

- **真实浏览器 / UI 验证 / 截图证据 / 登录态 / cookies / 下载上传 / 后台 tab / managed tab lifecycle** → `mcp__tmwd_browser__*`。
- **JS 逆向 / 页面 API 发现 / 签名·加密参数 / 请求发起链 / 网络·WS 采样 / Hook / 补环境 / 反混淆 / 证据导出** → `mcp__js-reverse__*`（触发时读 `~/.claude/skills/js-reverse/SKILL.md`）；默认 browser67-backed，保留用户真实登录态。
- **无 profile 的 localhost / file 轻量预览** → Claude 内置 `WebFetch`（对应 codex 的 in-app Browser 定位）。
- **callframe 级持久断点调试** → 超出 js-reverse 的 observe-first/hook 边界，需专用 remote CDP debug 浏览器，属显式 debug 场景，不用于普通登录态任务。
- **运行时前提**：browser67 依赖本地 WS 桥（hub 进程 `src/tmwd-hub.mjs`，监听 `ws://127.0.0.1:18765` + `http://127.0.0.1:18766/link`）。桥未运行时 `mcp__tmwd_browser__*` / `mcp__js-reverse__*` 连接失败。恢复路径（`browser67` CLI 不在 PATH，用项目内 npm）：
  ```bash
  cd ~/Documents/sixseven/codeproject/craft67/packages/browser67
  npm run hub:status      # 查桥状态
  npm run doctor          # 就绪自检（tmwd 模式）
  npm run hub:start       # 拉起桥（hub:stop 停）
  ```
  MCP server 的 `command` 已固定为 node 绝对路径（`~/.nvm/versions/node/v24.18.0/bin/node`）；nvm 升级 node 版本后需在 `~/.claude.json` 同步这两处路径。
- **Failure policy**：登录态任务若 browser67 不可用则 **fail closed**，不静默回退 remote CDP（可能是另一个 profile），不改用 Playwright。
- **Tab ownership**（对应真源 Tab ownership policy）：主动操作用 browser67 managed tab（`select_or_create`，稳定 `workspace_key=<project>-<surface>`）；用户已打开/登录的 tab 是 `user_unmanaged`，默认只读，仅在用户明确要求操作当前 tab 时用 `inspect_adoption → adopt_existing` 接管，不重开、不重复登录；任务结束对当前 `workspace_key`/`task_id` 执行 scoped `finalize_task`（释放 adopted tab 不关闭），并在交付中报告 `delivery_summary`；见 `finalize_hint.required:true` 即提醒收尾。
- 截图只是证据不等于设计通过；DOM/surface 数量、panel height、overflow 检查不能替代产品级视觉判断。响应式截图需含 viewport / PNG 尺寸核验。

## 质量门（沿用 design-craft SKILL.md）

阻断「完成」直到相关门满足或明确报告 unverified：视觉（非模板化、层级清晰、密度合理、响应式、对比度达标；未经设计指示时避开这些默认风格：奶油色背景、标题里的斜体强调词、“01/02/03”编号式分节标签、等宽字体标签、药丸形按钮）、设计系统（token 角色、主题 parity、focus-visible、组件状态、UI 文案）、产品（解决用户 job、保留信息架构、覆盖空/加载/错误/长数据态）、可访问性（键盘、焦点、语义、对比度、有效点击尺寸）、性能（度量或可推理的热路径）、架构与结构（清晰边界、无无谓抽象、真实复用）。

可见 UI 变更**必须** browser67 真实验证 + 真实截图 artifact（`path` / 尺寸 / `sha256`）；计划、候选、pending 不算完成。

## 交付摘要（精简 5 组）

1. `frontend_tier` / `design_tier` 与 `change_risk`
2. PRODUCT / DESIGN authority 与实际 `selected_skills`
3. 实际改动与结构影响
4. 真实 test / browser（tmwd_browser）/ native / visual-review 结果与 artifacts
5. blocker、unverified 项、residual risk

完整细节、所有字段仅在失败、审计或用户明确要求时展开；默认只写读者需要的部分。
