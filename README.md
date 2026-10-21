# my_config

Claude Code 全局配置备份（2026-10-21）。

| 路径 | 原位置 | 说明 |
|---|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | 全局提示词 |
| `claude/rules/` | `~/.claude/rules/` | frontend.md、multi-agent.md |
| `claude/agents/` | `~/.claude/agents/` | 自定义 subagent（browser-verifier） |
| `claude/hooks/` | `~/.claude/hooks/` | design-craft-guard.sh |
| `claude/statusline.sh` | `~/.claude/statusline.sh` | 状态栏脚本 |
| `claude/settings.json` | `~/.claude/settings.json` | **`ANTHROPIC_AUTH_TOKEN` 已脱敏**，恢复时需重新填写 |
| `claude/settings.local.json` | `~/.claude/settings.local.json` | 本地权限 |
| `claude/mcp-servers.json` | `~/.claude.json` 中的 `mcpServers` | MCP server 配置 |
| `claude/memory/` | `~/.claude/projects/-Users-gaoqian/memory/` | auto-memory |
| `claude/docs/` | `~/.claude/docs/` | 维护/同步说明 |
| `claude/skills/money-craft/` | `~/.claude/skills/money-craft/` | 唯一非软链的 skill |
| `claude/skills/symlinks.txt` | `~/.claude/skills/*` | 其余 skill 是软链（指向 `~/.agents/skills` 等），源文件不在本仓库 |

## 恢复

```bash
cd my_config/claude
cp CLAUDE.md statusline.sh settings.json settings.local.json ~/.claude/
cp -R rules agents hooks docs ~/.claude/
mkdir -p ~/.claude/skills ~/.claude/projects/-Users-gaoqian/memory
cp -R skills/money-craft ~/.claude/skills/
cp memory/*.md ~/.claude/projects/-Users-gaoqian/memory/
chmod +x ~/.claude/statusline.sh ~/.claude/hooks/*.sh
# 重建 skill 软链
while read -r name _ target; do ln -sfn "$target" ~/.claude/skills/"$name"; done < skills/symlinks.txt
# 合并 MCP 配置（在 Claude Code 会话外执行）
jq -s '.[0] * .[1]' ~/.claude.json mcp-servers.json > /tmp/c.json && mv /tmp/c.json ~/.claude.json
```

最后在 `~/.claude/settings.json` 里填回 `ANTHROPIC_AUTH_TOKEN`。
