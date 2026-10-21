#!/usr/bin/env bash
# design-craft-guard.sh — UserPromptSubmit 兜底钩子
#
# prompt 像前端 / UI / 视觉任务时注入一条提醒：真正调用 design-craft，可见 UI 变更用 browser67 验证。
# 缘由：曾出现模型口头声称"按 design-craft 基线"却没调用 skill。
# 英文词按整词匹配（避免 build/quick/guide 里的 "ui" 误命中）；中文词选前端专属说法。任何失败都 exit 0，不阻塞输入。

prompt="$(jq -r '.prompt // empty' 2>/dev/null)"
[ -z "$prompt" ] && exit 0

if printf '%s' "$prompt" | grep -qiE '\b(ui|ux|css|scss|tailwind|frontend|front-end|responsive|a11y|accessibility|dataviz|react|vue|svelte|next\.js|html|jsx|tsx|hover|focus-visible|button)\b|前端|按钮|表单|弹窗|配色|品牌色|主题色|界面|样式|页面|布局|视觉|交互设计|设计稿|设计系统|UI ?设计|响应式|无障碍|可访问性|可视化'; then
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"这条请求看起来是前端/UI 任务：用 Skill 工具调用 design-craft 作为设计基线；可见 UI 变更用 browser67（mcp__tmwd_browser__*）验证并附截图 artifact，不用 Playwright / chrome-devtools；只报告实际调用过的 skill。纯后端/CLI/数据任务忽略本条。"}}'
fi
exit 0
