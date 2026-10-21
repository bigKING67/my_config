---
name: review-workflow-model-allocation
description: "Multi-agent review workflow model policy — Fable 5.1 only for high-risk finders and per-finding adjudication, Opus 5.5 for all verify agents"
metadata:
  node_type: memory
  type: feedback
  originSessionId: a7eedcb3-30ab-4814-b87f-468414fac238
  modified: 2026-09-27T08:43:44.203Z
---

For full-repo / multi-agent review workflows (Workflow tool, review-craft style find → verify):
Find stage: Fable 5.1 (session default) only on high-risk cross-module finders (protocol, main process, agent runtime, cross-cutting red lines); Opus 5.5 `xhigh` for bounded modules.
Verify stage: always `model: 'opus'` — never inherit Fable.
Adjudicate stage: one small-context Fable 5.1 agent per escalated finding only (verdict UNVERIFIED, or P0/P1 by finder or verifier severity). Fable adjudication overrides the Opus verifier ruling.

**Why:** Agreed with user on 2026-09-27 after the pi-67-desktop full-repo review ran 8 verify agents on Fable (~1.08M tokens). Fable is 2.5× Opus 5.5 price on input and output; verification is a narrow claim check, and verifying Fable findings with Fable repeats the same reasoning bias. Cross-model verify plus targeted escalation keeps quality on the findings that go to implementation.

**How to apply:** When authoring a review workflow script, put `model: 'opus'` on verify `agent()` calls, note it in `meta.phases`, and add the adjudication stage as a third pipeline stage (no barrier). Reference implementation: `~/.claude/projects/-Users-gaoqian-Documents-sixseven-codeproject-pi-67-desktop/3554a459-72a5-480b-8d69-e63a2da55472/workflows/scripts/pi67-full-repo-review-v2.js`. Related: [[prefer-native-over-custom]].
