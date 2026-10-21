# CLAUDE.md 同步指南

> 本指南说明何时以及如何同步全局 CLAUDE.md

---

## 🎯 核心原则

**CLAUDE.md 应该反映你当前实际拥有的工具和能力**

---

## 🔀 两种维护模式

### 模式 1️⃣：简单同步（Simple Sync）

**适用场景**：工具变更时（新增/删除 workflow/skill/MCP）

**操作范围**：
- ✅ 更新索引（第 8.1/8.2 节）
- ✅ 更新路由表（第 3 章）
- ✅ 更新工具策略（第 4.1 节，仅 MCP 变化时）
- ❌ **不改变**核心原则、质量门禁、决策树等

**特点**：快速、无副作用、仅更新受影响的章节

**触发频率**：每次工具变更

---

### 模式 2️⃣：智能优化（Smart Optimize）

**适用场景**：发现 CLAUDE.md 存在问题时

**操作范围**：
- ✅ 调整章节结构
- ✅ 删除冗余内容
- ✅ 修复策略冲突
- ✅ 优化决策树
- ✅ 改进引用方式
- ✅ 重新组织内容

**特点**：深度分析、需要确认方案、可能重构多个章节

**触发频率**：每月 1 次或发现问题时

---

## 📊 模式对比

| 维度 | 简单同步 | 智能优化 |
|------|---------|---------|
| **触发** | 工具变更 | 文档问题 |
| **范围** | 索引和路由表 | 多个章节 |
| **耗时** | 1-2 分钟 | 5-15 分钟 |
| **风险** | 极低 | 需要确认 |
| **频率** | 每次变更 | 每月 1 次 |

---

## 📋 简单同步触发场景

当以下三类资源发生变化时，触发**简单同步**：
1. **CCG Workflows** - `npx ccg-workflow@latest` 更新
2. **Skills** - 安装/删除 skills
3. **MCP 服务** - 添加/删除 MCP 服务器

---

## 📋 同步触发场景

### 场景 1：CCG Workflow 更新

**触发条件**：
```bash
npx ccg-workflow@latest
```

**变化位置**：
- `~/.claude/.ccg/config.toml` - `installed` 列表变化
- `~/.claude/commands/ccg/*.md` - workflow 文档增删

**需要同步的 CLAUDE.md 章节**：
- ✅ 第 3 章 - 工作流路由器（3.1/3.2/3.3/3.4 节）
- ✅ 第 8.1 节 - 已安装 Workflow 索引
- ⚠️ 第 3.5 节 - 快速决策树（可选，如果是常用 workflow）

**同步命令**：
```
告诉 Claude: "CCG 更新到最新版了，请帮我同步 CLAUDE.md"
```

---

### 场景 2：Skills 变化

**触发条件**：
```bash
# 安装新 skill
git clone <skill-repo> ~/.claude/skills/<skill-name>

# 或删除 skill
rm -rf ~/.claude/skills/<skill-name>
```

**变化位置**：
- `~/.claude/skills/` - 目录增删

**需要同步的 CLAUDE.md 章节**：
- ✅ 第 8.2 节 - 可用 Skills 索引
- ⚠️ 第 4.2 节 - 质量控制策略（如果是质量控制类 skill）

**同步命令**：
```
告诉 Claude: "我安装/删除了 skill: <skill-name>，请帮我同步 CLAUDE.md"
```

---

### 场景 3：MCP 服务变化

**触发条件**：
```bash
# 修改 MCP 配置
vim ~/.config/claude/config.yaml
```

**变化位置**：
- `~/.config/claude/config.yaml` - `mcpServers` 配置

**需要同步的 CLAUDE.md 章节**：
- ✅ 第 2.4 节 - 知识获取优先级
- ✅ 第 4.1 节 - 上下文收集策略
- ⚠️ 第 4.2 节 - 质量控制策略（如果是质量控制类 MCP）

**同步命令**：
```
告诉 Claude: "我添加/删除了 MCP 服务: <mcp-name>，请帮我同步 CLAUDE.md"
```

---

## 🤖 Claude 自动同步流程

### 你只需说一句话

```
<场景描述>，请帮我同步 CLAUDE.md
```

### Claude 会自动执行

#### 第 1 步：检测变化

**CCG Workflows**：
```bash
# 读取配置
cat ~/.claude/.ccg/config.toml | grep "installed ="

# 扫描文档
ls ~/.claude/commands/ccg/

# 对比 CLAUDE.md
grep "| \`/ccg:" ~/.claude/CLAUDE.md
```

**Skills**：
```bash
# 扫描 skills
ls -1 ~/.claude/skills/

# 对比 CLAUDE.md
grep "^- \`" ~/.claude/CLAUDE.md | grep -A 20 "### 8.2"
```

**MCP 服务**：
```bash
# 读取 MCP 配置
cat ~/.config/claude/config.yaml | grep -A 50 "mcpServers:"

# 对比 CLAUDE.md
grep "mcp__" ~/.claude/CLAUDE.md
```

---

#### 第 2 步：生成同步报告

示例报告：
```
📊 同步检测报告
==================

【需要添加】
- Workflow: /ccg:refactor (探索式)
- Skill: /code-quality
- MCP: mcp__code-analyzer__*

【需要删除】
- Workflow: /ccg:old-feature (已被 CCG 移除)
- Skill: /deprecated-skill (已卸载)

【需要更新章节】
- 第 3.1 节：添加 /ccg:refactor
- 第 8.1 节：更新 workflow 总数 (26 → 27)
- 第 8.2 节：添加 code-quality skill
- 第 4.1 节：添加 mcp__code-analyzer__ 到工具策略
```

---

#### 第 3 步：自动更新 CLAUDE.md

**新增 Workflow** - 添加到对应路由表：
```markdown
# 第 3.1 节（探索式）
| **重构代码** | 重构、优化结构 | `/ccg:refactor` | [refactor.md](~/.claude/commands/ccg/refactor.md) |

# 第 8.1 节
- 探索式（12 个）：feat, plan, analyze, backend, frontend, workflow, debug, optimize, test, review, commit, refactor
```

**新增 Skill** - 添加到索引：
```markdown
# 第 8.2 节
- `code-quality` - 代码质量检查
```

**新增 MCP** - 添加到工具策略：
```markdown
# 第 4.1 节
- **代码分析**（代码质量/复杂度）→ `mcp__code-analyzer__analyze`
```

---

#### 第 4 步：验证同步

```bash
# 检查长度（应该在 220-380 行）
wc -l ~/.claude/CLAUDE.md

# 检查是否有语法错误
grep "^#" ~/.claude/CLAUDE.md

# 更新日期
# 自动更新最后一行的日期
```

---

## 📝 快速参考卡片

### 三种场景，一句话触发

| 场景 | 触发命令 |
|------|---------|
| **CCG 更新** | `CCG 更新到最新版了，请帮我同步 CLAUDE.md` |
| **Skills 变化** | `我安装/删除了 skill: <name>，请帮我同步 CLAUDE.md` |
| **MCP 变化** | `我添加/删除了 MCP 服务: <name>，请帮我同步 CLAUDE.md` |

### Claude 会自动

1. ✅ 检测差异
2. ✅ 生成同步报告
3. ✅ 更新 CLAUDE.md
4. ✅ 验证同步
5. ✅ 备份旧版

---

## 🔄 智能优化触发方式

### 月度审计（推荐）

即使没有主动变化，建议每月检查一次：

```
请帮我做一次 CLAUDE.md 月度审计
```

Claude 会：
- ✅ 扫描所有 workflows、skills、MCP（检查是否同步）
- ✅ 检查长度是否超预算（220-380 行）
- ✅ 检测重复内容和策略冲突
- ✅ 生成问题诊断报告
- ✅ 提出优化建议（需要你确认）

### 主动优化

发现问题时可以主动触发：

```
CLAUDE.md 感觉有点乱，帮我优化下
请检查 CLAUDE.md 是否需要优化调整
```

---

## 🎯 使用建议

**90% 情况 → 简单同步**：
```
"CCG 更新了，请帮我同步 CLAUDE.md"           # 只更新索引
"我安装了 skill: xxx，请帮我同步 CLAUDE.md"  # 只加索引
"我添加了 MCP: xxx，请帮我同步 CLAUDE.md"    # 只加工具策略
```

**10% 情况 → 智能优化**：
```
"请帮我做一次 CLAUDE.md 月度审计"             # 每月 1 次
"CLAUDE.md 感觉需要优化下"                   # 发现问题时
```

**核心原则**：
> **工具变更 = 简单同步（快速更新索引）**
> **文档问题 = 智能优化（深度重构调整）**

---

## 🛡️ 安全保障

**每次同步前自动备份**：
```bash
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.$(date +%Y%m%d_%H%M%S).bak
```

**如需回滚**：
```bash
# 列出备份
ls -lt ~/.claude/CLAUDE.md.*.bak | head -5

# 恢复
cp ~/.claude/CLAUDE.md.20260210_113000.bak ~/.claude/CLAUDE.md
```

---

## 📖 相关文档

- **维护指南**：`~/.claude/docs/MAINTENANCE.md`
- **全局配置**：`~/.claude/CLAUDE.md`
- **CCG 配置**：`~/.claude/.ccg/config.toml`
- **MCP 配置**：`~/.config/claude/config.yaml`

---

*最后更新: 2026-02-10 | 维护: 你和 Claude*
