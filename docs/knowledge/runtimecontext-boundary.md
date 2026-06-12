---
id: runtimecontext-boundary
title: RuntimeContext is one of the cleanest architectural boundaries; owns shared runtime state, structured error payloads, and handler attribution
answers:
  - "what is RuntimeContext and why is it important"
  - "where does last_error live"
  - "how does top_rule flow through the compile pipeline"
  - "what owns parser-source chunk capture"
  - "how does RuntimeContext anchor chdir-safety for runtime state"
date: 2026-06-12
status: current
tags: [architecture, runtimecontext, diagnostics, boundary]
evidence: "perl/LinkedSpec/RuntimeContext.pm; spent by Runtime, ParserFactory, Compiler, SpecEntry; ARCHITECTURE_STATE.md calls it 'one of the cleanest and highest-value seams in the project'"
reverify: "grep -l 'RuntimeContext' perl/LinkedSpec/*.pm perl/LinkedSpec/RuleIR/*.pm | wc -l"
---

`LinkedSpec::RuntimeContext` owns the shared mutable state that flows through the compile and
runtime pipeline: `spec_name`, `spec_path`, `top_rule`, `last_error`, and parser-source chunk
capture. It is reached through `LinkedSpec::OwnerDispatch::dispatch_owner_call` across
`Runtime.pm`, `ParserFactory.pm`, `Compiler.pm`, and `SpecEntry.pm`.

Key responsibilities:
- Normalizes `runtime_ctx_ref` (direct hashrefs + reusable scalar slots)
- Seeds `top_rule` during both inline `run_get()` and file-oriented `get_parser()` setup
- Generates `handler_source_label` for diagnostics (top-rule, rule-or-top, rule-metadata variants)
- Owns parser-source chunk allocation, emission, and full-capture reset
- Clears stale `last_error` at operation boundaries so reused contexts start fresh
- Owns paired `spec_name`/`spec_path` identity reset, deliberately separate from `top_rule`
- Preserves `top_rule` / `handler_source_label` continuity through structured error payloads

The `ARCHITECTURE_STATE.md` calls it "one of the cleanest and highest-value seams in the project."
It reduced drift and made structured diagnostics much more coherent compared to the earlier style
of each owner hand-rolling its own context management.

Related: [[ownerdispatch-shared-seam]], [[compilerstate-internal-model]].
