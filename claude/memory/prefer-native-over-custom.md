---
name: prefer-native-over-custom
description: Claude Code 配置原生优先：有原生能力（/code-review、Agent 后台通知、worktree）就不自建等价子代理或规则
metadata:
  node_type: memory
  type: feedback
  originSessionId: a9022327-6c1f-460f-bf0d-6fbad39efc22
  modified: 2026-09-27T04:06:49.653Z
---

配置 Claude Code 时原生能力优先：原生 skill/工具已覆盖的功能，不再自建等价的子代理或流程规则；自定义只补原生不决定的策略或私有合同（如 browser67 的 browser-verifier）。

**Why:** 2026-09-27 用户确认删除自写的 `code-reviewer` 子代理，改用原生 `/code-review`；并行规则 `~/.claude/rules/multi-agent.md` 只写策略，不移植 Codex 的 wait_agent/awaiter 机制。原生能力随模型升级维护，自写版本重叠且需手动维护。

**How to apply:** 移植 Codex 配置或新增 agent/skill 前，先查 Claude Code 是否有原生对应；有则路由到原生，并删除重复的自定义件。相关：[[claude-frontend-stack]]、[[prompt-audit-per-model-upgrade]]。
