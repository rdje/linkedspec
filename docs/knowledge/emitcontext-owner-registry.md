---
id: emitcontext-owner-registry
title: RuleIR::EmitContext centralizes the ActionIR owner-package registry and default-dependency lookup for the bridge from RuleIR into ActionIR scanning and lowering
answers:
  - "how does EmitContext dispatch into ActionIR owners"
  - "where are ActionIR owner packages registered"
  - "what is the EmitContext owner registry"
  - "how does _actionir_owner_package work"
date: 2026-09-06
status: current
tags: [architecture, emitcontext, actionir, owner-registry]
evidence: "SESSION-STARTUP-READING.3.2.12: EmitContext.pm lines 134–150 define 14 registry keys: thirteen ActionIR owners plus Trace; bounded registry extraction returns the same 14 names. The dependency wrapper appends the owner's default bundle."
reverify: bash tools/project_data_run.sh perl -0777 -ne 'my ($r) = /state \$owner_pkgs = \{(.*?)\n \};/s; die "registry missing\n" unless defined $r; my @keys = $r =~ /^\s*(\w+)\s*=>/mg; print scalar(@keys), " keys: ", join(", ", @keys), "\n";' perl/LinkedSpec/RuleIR/EmitContext.pm
---

`LinkedSpec::RuleIR::EmitContext` is the bridge from RuleIR into ActionIR scanning and lowering.
It centralizes the ActionIR owner-package registry and default-dependency lookup that used to
be hardwired separately across dozens of local wrappers.

The registry (`_actionir_owner_package`) maps 14 owner keys to packages: thirteen
`LinkedSpec::ActionIR::*` owners and `LinkedSpec::Trace`:
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

Reverified on 2026-09-06 under `SESSION-STARTUP-READING.3.2.12`. The original 2026-06-12
card listed all fourteen names but incorrectly called them thirteen keys; this corrects the
count without changing dispatch. The reverify command now extracts registry keys instead
of counting references to the registry helper.

Related: [[ownerdispatch-shared-seam]], [[actionir-lowering-stack]].
