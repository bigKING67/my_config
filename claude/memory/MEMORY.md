# Memory Index

> 本文件是长期记忆的索引：一行一条，指向 `memory/` 下的 topic 文件。
> 不在此处写正文；正文放进各自的 topic 文件（含 frontmatter）。
> 格式：`- [标题](file.md) — 一句话钩子`

- [Skills 存储与恢复](skills-storage-and-recovery.md) — 源在 `~/.agents/skills`，`~/.claude/skills` 软链激活；停用删链留源，恢复用 `ln -s`
- [Claude 前端任务栈](claude-frontend-stack.md) — design-craft 基线 + browser67 浏览器运行时（tmwd_browser/js-reverse MCP）；已移除 Playwright/chrome-devtools；规则入口 `~/.claude/rules/frontend.md`
- [模型升级重跑 prompt-audit](prompt-audit-per-model-upgrade.md) — 升级模型后审计 ~/.claude 配置 + claude -p 探针前后对比；2026-09 已为 Opus 5.5 清理
- [原生优先于自建](prefer-native-over-custom.md) — 原生 /code-review、Agent 通知/worktree 已覆盖的不自建；已删 code-reviewer，并行策略在 `~/.claude/rules/multi-agent.md`
- [Review workflow 模型分配](review-workflow-model-allocation.md) — Fable 只给高风险 finder 和逐条仲裁；verify 一律 Opus 5.5；参考脚本 pi67-full-repo-review-v2.js
