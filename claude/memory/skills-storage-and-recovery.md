---
name: skills-storage-and-recovery
description: Claude Code skills 的存储结构与恢复方法（源在 ~/.agents/skills，通过软链激活）
metadata: 
  node_type: memory
  type: reference
  originSessionId: cb609b52-9b64-4d46-8248-50138fb195a3
  modified: 2026-07-24T06:31:27.945Z
---

Claude Code 个人 skills 采用「源文件 + 软链激活」两层结构：

- **真实源文件**：`~/.agents/skills/<name>/`（含 `SKILL.md`）
- **激活入口**：`~/.claude/skills/<name>` 是指向源的相对软链 `../../.agents/skills/<name>`。Claude Code 只加载激活入口能解析到的 skill。
- **停用某 skill**：删 `~/.claude/skills/` 下的软链即可，源文件保留、可逆。
- **恢复/重新激活**：`ln -s ../../.agents/skills/<name> ~/.claude/skills/<name>`（在 `~/.claude/skills/` 目录内建相对软链）。
- **悬空软链** = 源已从 `~/.agents/skills/` 删除，属垃圾，可直接清理。

**2026-07-24 整理**：清掉 23 个悬空软链 + 残缺目录 `da-workspace`；停用（删软链、留源）10 个设计类 skill：brandkit、gpt-taste、high-end-visual-design、image-to-code、imagegen-frontend-mobile、imagegen-frontend-web、industrial-brutalist-ui、minimalist-ui、redesign-existing-projects、stitch-design-taste —— 待重新配置。飞书 lark-* 28 个全保留。
