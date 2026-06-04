---
id: linkedspec-pm-is-thin-facade
title: LinkedSpec.pm is a thin lazy façade; the real compile spine is ParserFactory -> Runtime -> Compiler
answers:
  - "where does the real implementation live in linkedspec"
  - "is LinkedSpec.pm the implementation center"
  - "what is the practical compile/runtime spine"
  - "how does LinkedSpec.pm dispatch into owner modules"
  - "why is LinkedSpec.pm so small"
date: 2026-06-05
status: current
tags: [architecture, facade, ownerdispatch, compile-spine]
evidence: "perl/LinkedSpec.pm is ~258 lines; static imports are essentially File::Basename + LinkedSpec::OwnerDispatch"
reverify: "wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm"
---

`perl/LinkedSpec.pm` does almost no real work: it exposes the public API, lazily loads owner
modules through `LinkedSpec::OwnerDispatch`, normalizes options, and re-exports trace globals.
Read it as a **façade and routing layer**, not the place where semantics live.

The practical core spine is `ParserFactory -> Runtime -> Compiler`. Frontend syntax/bootstrap
truth concentrates in `BootstrapSpec::Core` + `Validation`; rule compilation / emitted runtime
behavior in `SpecEntry`, `RuleIR`, `RuleIR::EmitContext`; backend-neutral action semantics in
`LinkedSpec::ActionIR::*`; `RuntimeContext` is the shared state/diagnostics seam. Canonical
home: `ARCHITECTURE_STATE.md` (Current Owner Tree + What the Main Owners Do).
Related: [[actionrewriter-removed-phase1]].
