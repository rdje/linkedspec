---
id: emitcontext-owner-registry
title: RuleIR::EmitContext centralizes the ActionIR owner-package registry and default-dependency lookup for the bridge from RuleIR into ActionIR scanning and lowering
answers:
  - "how does EmitContext dispatch into ActionIR owners"
  - "where are ActionIR owner packages registered"
  - "what is the EmitContext owner registry"
  - "how does _actionir_owner_package work"
date: 2026-06-12
status: current
tags: [architecture, emitcontext, actionir, owner-registry]
evidence: "perl/LinkedSpec/RuleIR/EmitContext.pm: _actionir_owner_package maps 13 owner keys to package names; _call_actionir_owner_with_deps appends default dependency bundles automatically"
reverify: "grep -c '_actionir_owner_package\|owner_pkgs' perl/LinkedSpec/RuleIR/EmitContext.pm"
---

`LinkedSpec::RuleIR::EmitContext` is the bridge from RuleIR into ActionIR scanning and lowering.
It centralizes the ActionIR owner-package registry and default-dependency lookup that used to
be hardwired separately across dozens of local wrappers.

The registry (`_actionir_owner_package`) maps 13 owner keys to packages:
`rewrite_pipeline`, `method_expr`, `scanner`, `canonical_events`, `diagnostics`,
`statement_split`, `contracts`, `flow_expr`, `array_pipeline`, `control_flow`,
`method_lowering`, `declare_method`, `value_expr`, `trace`.

Three dispatch patterns:
- `_call_actionir_owner($key, $method, @args)` — dispatch without deps
- `_call_actionir_owner_with_deps($key, $method, @args)` — dispatch with auto-appended default deps
- `_actionir_owner_default_deps($key)` — fetch default deps only

This replaced the earlier pattern of each caller hand-rolling `_require_*_pkg(...)` wrappers
with hardcoded package names and local `$@` preservation. The registry is the single source of
truth for which ActionIR owner handles which concern.

Related: [[ownerdispatch-shared-seam]], [[actionir-lowering-stack]].
