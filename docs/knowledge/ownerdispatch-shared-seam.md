---
id: ownerdispatch-shared-seam
title: LinkedSpec::OwnerDispatch is the shared seam for lazy owner loading, callback resolution, and $@ preservation
answers:
  - "how does lazy owner loading work in linkedspec"
  - "what is OwnerDispatch and why do all owners use it"
  - "how is $@ preserved across owner dispatch"
  - "where does build_dep_map live"
  - "how do ActionIR owners resolve their dependencies"
date: 2026-06-12
status: current
tags: [architecture, ownerdispatch, dependency-injection, seam]
evidence: "perl/LinkedSpec/OwnerDispatch.pm (220 lines); 12+ owner modules spend this seam directly; build_dep_map and build_dep_bundle centralize dependency assembly"
reverify: "grep -l 'OwnerDispatch' perl/LinkedSpec/*.pm perl/LinkedSpec/ActionIR/*.pm | wc -l"
---

`LinkedSpec::OwnerDispatch` (220 lines) is the small shared module that eliminated repeated
thin-wrapper boilerplate across the owner tree. It provides five primitives:

- `call_preserving_err($cb)` — execute a callback without clobbering caller-visible `$@`
- `require_pkg($owner, $target)` — lazy-load one package with owner-attributed diagnostics
- `require_pkg_cb($owner, $target, $subname)` — lazy-load + resolve one named callback
- `require_pkg_value($owner, $target, $subname)` — lazy-load + invoke callback to obtain a value
- `build_dep_map($owner, $default_target, $dep_specs)` — assemble a full dependency callback map
- `build_dep_bundle($owner, $default_target, $dep_specs)` — assemble mixed callback/value bundle
- `dispatch_owner_call($owner, $target, $subname, @args)` — shared thin-wrapper delegator

It also anchors lazy loading to an absolute repo `perl` path at module load time, so `chdir()`
does not strand the file-oriented parser/runtime owner tree on stale relative `@INC` entries.

Spent by: `LinkedSpec.pm`, `Trace`, `Runtime`, `ParserFactory`, `BootstrapSpec`, `BootstrapSpec::Core`,
`Compiler`, `SpecEntry`, `RuleIR`, `RuleIR::EmitContext`, `Resolver`, `Validation`, `PluginBridge`,
and all 12 `ActionIR::*` owners.

Related: [[linkedspec-pm-is-thin-facade]], [[compilerstate-internal-model]].
