---
id: actionrewriter-removed-phase1
title: ActionRewriter.pm was deleted in Phase 1; the helper-rewrite compat entrypoint is now in RuleIR::EmitContext
answers:
  - "does perl/LinkedSpec/ActionRewriter.pm still exist"
  - "where did LinkedSpec::ActionRewriter go"
  - "where is the helper-rewrite compatibility entrypoint now"
  - "where did call_spec_handler_subst / rewrite_action_code_for_compat move"
  - "is ActionRewriter a live module in linkedspec"
date: 2026-06-05
status: current
tags: [architecture, actionir, compatibility, removed]
evidence: "commit 4f8e0b6 (PHASE1-PARSER-CORE-ISOLATION.2) deleted the 118-line forwarding shim; zero references remain under perl/"
reverify: "! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm"
---

`LinkedSpec::ActionRewriter` (`perl/LinkedSpec/ActionRewriter.pm`) **no longer exists**. It
had become a pure forwarding shim over `RuleIR::EmitContext`, so Phase 1
(`PHASE1-PARSER-CORE-ISOLATION.2`, commit `4f8e0b6`) deleted it. The focused helper-rewrite
compatibility entrypoint is now `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)`,
reachable from the façade as `LinkedSpec::call_spec_handler_subst(...)`.

Do not "restore" or look for `ActionRewriter`; treat any doc that calls it a live module as
stale. Canonical homes: `ARCHITECTURE_STATE.md`, `docs/tasks/PHASE1-PARSER-CORE-ISOLATION.md`.
Related: [[linkedspec-pm-is-thin-facade]].
