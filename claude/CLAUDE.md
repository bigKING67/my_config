# Claude Code 全局配置

## 一、工程原则

改代码前先读相关代码和它的调用方，优先复用现有实现；只解决真实存在的问题，不做预设性的过度设计。

- 不复制粘贴已有逻辑，抽取复用（3 行以内的样板除外）。
- 不破坏现有 API 和调用链；确需 breaking change 时附迁移说明。
- 关键路径要有错误处理。
- 明知方案有缺陷时直接指出，不默默妥协；接受次优方案时记录原因。

Breaking change、架构变更或 schema 变更：先给出方案并等我确认再动手。

查资料顺序：本地代码库 > WebSearch / WebFetch；GitHub 仓库级问题可用 deepwiki。

---

## 二、工具策略

### 2.1 审查

非平凡改动完成后：日常 diff 审查用原生 `/code-review high`，安全相关用 `/security-review`；仓库级或高保证审查用 `review-craft` skill。

### 2.2 共享长期记忆（agent-memory / EverOS）

User scope MCP server `agent-memory` 是和 Codex CLI、Pi agent 共用的长期记忆入口。

- 非平凡任务、历史决策、用户偏好、跨 session 上下文：优先用 `briefing` / `recall` 获取相关记忆。
- `remember` 只写入已经验证、可长期复用、非敏感的信息；默认 `async_mode=false` 且 `flush_after=true`，写后会同步抽取以便立即检索；批量导入时才显式改为 `async_mode=true, flush_after=false` 并在任务末尾调用 `flush`；不确定是否该写时先用 `propose_memory`。
- 采用 `automatic recall + curated remember`：读取记忆应主动发生；写入不是全量自动归档。用户明确说“记一下 / 写入长期记忆 / 以后都按这个来”时必须调用 `remember`；非平凡任务结束若产生新的长期偏好、项目决策、环境约束、稳定排错结论或可复用 workflow，默认主动写入，不确定时先问用户。`remember` 带 server-side pre-write guard 和结构化字段，默认阻止敏感凭据、raw logs、diff、stack trace、大段 blob 和低价值临时内容。
- 初期默认使用 `space_id=sixseven`；不要因新项目、新 agent 或 smoke 测试主动创建新 space；只有 recall 明显混杂、长期项目记忆量明显变多、需要 agent 专属隔离，或用户明确要求时，才按 `project:<name>`、`agent:<name>` 等命名空间拆分；全局偏好仍保留在 `sixseven`。
- 共享记忆 MCP 的本地运行手册是 `/Users/gaoqian/.local/lib/agent-memory-everos-mcp/README.md`；修改 recall/remember、namespace 策略或默认参数时，先更新该 runbook，再同步 Codex/Pi 指南；修改后运行 `memory_eval` 或 `/Users/gaoqian/.local/bin/agent-memory-eval`，日常整体验证用 `/Users/gaoqian/.local/bin/agent-memory-check`，定期用 `memory_healthcheck` / `memory_audit` 检查记忆质量。
- 容易漂移的环境/版本/API/临时 workaround 记忆要设置 `review_after`；使用 `confidence=low` 的记忆前必须重新现场验证。需要本地备份时用 `memory_export` 或 `/Users/gaoqian/.local/bin/agent-memory-export`，默认 redacted 导出；清理测试残留前先用 `memory_delete_probe` 在隔离 `_probe:*` session 验证 EverOS delete / search-index 一致性，禁止直接批量清理 `sixseven`。
- 禁止写入 API key、token、cookie、password、private key、原始凭据、无关私人数据和大段 raw logs。
- 记忆只是辅助线索；当前代码、配置、运行态和用户当前指令优先。

### 2.3 前端设计任务主链路

前端设计基线（design-craft）与浏览器运行时（browser67，不用 Playwright / chrome-devtools）的完整规则在 `~/.claude/rules/frontend.md`，每次会话自动加载。

### 2.4 并行与多代理

委派、并发上限、写隔离与 review 收口策略见 `~/.claude/rules/multi-agent.md`（自动加载）。

---

## 📋 Compact Instructions

When compressing, preserve in priority order:

1. **Architecture decisions** (NEVER summarize) - System designs, trade-offs, API contracts, security/performance decisions
2. **Modified files and their key changes** - File paths, what changed, breaking changes, dependency impacts
3. **Current verification status** (pass/fail) - Test results, critical functionality status, known issues
4. **Open TODOs and rollback notes** - Incomplete tasks, bug reports, technical debt, emergency procedures
5. **Tool outputs** (can delete, keep pass/fail only) - Intermediate logs, search results, code snippets (keep summary + result)

---

*最后更新: 2026-09-27 | 版本: 3.0.0（prompt-audit for Opus 5.5：移除 Plan Mode 五阶段仪式与旧 skill 流水线）*
