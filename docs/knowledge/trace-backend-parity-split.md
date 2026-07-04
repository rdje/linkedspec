---
id: trace-backend-parity-split
title: TRACE-OBSERVABILITY.4 owns Rust and future trace parity after the .3.5 contract closeout
answers:
  - "what is TRACE-OBSERVABILITY.4"
  - "what is TRACE-OBSERVABILITY.4.1"
  - "what is TRACE-OBSERVABILITY.4.2"
  - "what is next after TRACE-OBSERVABILITY.3.5"
  - "how is backend trace parity split"
  - "does Rust currently have trace controls"
  - "what owns Rust trace parity"
date: 2026-07-04
status: current
tags: [trace, observability, rust, parity, task-tree, mdbook]
evidence: "TRACE-OBSERVABILITY.3.5 no-drift probes; docs/tasks/TRACE-OBSERVABILITY.md .4 split; docs/linkedspec-book/src/public-api/trace-api.md variant-neutral trace contract; TRACE-OBSERVABILITY.4.2 Rust trace controls; TRACE-OBSERVABILITY.4.3 compile/spec-parser trace events; TRACE-OBSERVABILITY.4.4 runtime trace events"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.4|TRACE-OBSERVABILITY\\.4\\.5|variant-neutral trace contract|Rust trace controls|rust_runtime:engine|rust_runtime:generated_plan|parse_with_trace|staged_parser_registry:execute' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md ROADMAP_V2.md docs/linkedspec-book/src/public-api/trace-api.md docs/knowledge/trace-backend-parity-split.md rust/linkedspec-core/src rust/linkedspec-runtime/src"
---

`TRACE-OBSERVABILITY.3.5` closed the Perl reference trace no-drift/contract leaf and split the required backend
parity work into `TRACE-OBSERVABILITY.4.*` before any Rust trace code changes. `TRACE-OBSERVABILITY.4.1` has since
closed the Rust design inventory; `.4.2` has since added Rust controls, levels, sinks, and traced entrypoints; `.4.3`
has since added Rust compile/spec-parser/staged-dispatch trace events; and `.4.4` has since added Rust interpreted
runtime and generated-plan runtime trace events.

The split is:

- `.4.1`: done — Rust trace contract/design inventory before code;
- `.4.2`: done — Rust trace controls, levels, sinks, and traced entrypoints;
- `.4.3`: done — Rust compile/spec-parser/staged-dispatch trace events;
- `.4.4`: done — Rust runtime dispatch, branch, lifecycle, and mark/capture trace events;
- `.4.5`: active — cross-variant trace parity closeout, docs, and future-variant checklist.

The active frontier is `TRACE-OBSERVABILITY.4.5`. Rust now has the `.4.2` control layer, `.4.3` compile/
spec-parser/staged-dispatch events, and `.4.4` runtime branch/mark/capture events, but it cannot claim trace parity
until `.4.5` proves the mdBook-documented external trace contract across variants.
