---
name: prompt-audit-per-model-upgrade
description: 每次模型升级都用 /claude-api prompt-audit 重审 ~/.claude 配置，并用 claude -p 探针做前后对比
metadata:
  node_type: memory
  type: feedback
  originSessionId: 4dc66da2-bc78-42d2-8408-41eeba06c4b3
  modified: 2026-09-27T03:45:38.529Z
---

每次 Claude 模型升级后，对 Claude 独占的配置（`~/.claude/CLAUDE.md`、`rules/`、`agents/`、非软链 skill）跑 `/claude-api prompt-audit`；先出报告和 diff，用户确认后再应用。`~/.agents/skills` 下的软链 skill 由 Codex/Pi 共用，不在范围内，只 flag。

**Why:** 用户认为给旧模型写的保姆式规则会拖累新模型，同时要求每条删除都说明理由（有些行是绕 bug 的 workaround）。2026-09-27 针对 Opus 5.5 做了首轮审计：删掉 Plan Mode 五阶段流程，停用 session-planner / detect-scope-creep / verify-consistency 三个 skill（已移到 `~/.claude/backups/prompt-audit-20260927-112317/disabled-skills`）。

**How to apply:** 应用前先备份到 `~/.claude/backups/prompt-audit-<ts>/`。验证方法：在临时 git 仓库里用 `claude -p --output-format json` 跑三个探针（小 bug 修复、breaking 签名变更、跨文件改键名），新旧配置各跑一轮对比。首轮结果：旧配置在 breaking change 上没停下来等确认，新配置那一行明确规则生效了。同日又做了两项精简：一是移除 MCP sequential_thinking、context7、exa（用户判断 WebSearch/WebFetch 已够用；context7 和 exa 原本只配在 ~/ 目录的 local scope，真实项目里本来就用不到）；二是 lark-* 只保留 shared/im/doc/calendar/task 五个软链，停用前的完整列表存在备份目录 `lark-links-before.txt`。用户明确决定、以后审计不要再提的两项：默认 effort 用官方默认（Opus 5.5 为 `medium`，用户 2026-09-27 定；修老代码 bug 或需要重验证时用户手动 `/effort high`），settings 里不写 effort。注意：顶层 `effortLevel` 在 Opus 5.5 上不生效，真要固定档位得写 `modelSettings.<模型id>.effortLevel`。环境变量 `CLAUDE_CODE_EFFORT_LEVEL` 已删，它会锁死档位，导致 `--effort` 和 `/effort` 都切不动。审查用 high，安全审查由用户手动 `/effort max`。browser-verifier 试过换 Sonnet：成本 $1.65 降到 $0.88，但证据变弱（只截元素图、没做多视口检查、focus 靠脚本模拟、workspace_key 用了 default），所以保留 Opus；`settings.local.json` 放行 `python3:*`、`curl:*`、`pip3 install:*`。另见 [[claude-frontend-stack]]、[[skills-storage-and-recovery]]。
