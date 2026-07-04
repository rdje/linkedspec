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
evidence: "TRACE-OBSERVABILITY.3.5 no-drift probes; docs/tasks/TRACE-OBSERVABILITY.md .4 split; docs/linkedspec-book/src/public-api/trace-api.md variant-neutral trace contract; TRACE-OBSERVABILITY.4.2 Rust trace controls"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.4|TRACE-OBSERVABILITY\\.4\\.2|variant-neutral trace contract|Rust trace controls|parse_with_trace' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md ROADMAP_V2.md docs/linkedspec-book/src/public-api/trace-api.md docs/knowledge/trace-backend-parity-split.md rust/linkedspec-core/src/trace.rs rust/linkedspec-runtime/src"
---

`TRACE-OBSERVABILITY.3.5` closed the Perl reference trace no-drift/contract leaf and split the required backend
parity work into `TRACE-OBSERVABILITY.4.*` before any Rust trace code changes. `TRACE-OBSERVABILITY.4.1` has since
closed the Rust design inventory; `.4.2` has since added Rust controls, levels, sinks, and traced entrypoints.

The split is:

- `.4.1`: done — Rust trace contract/design inventory before code;
- `.4.2`: done — Rust trace controls, levels, sinks, and traced entrypoints;
- `.4.3`: active — Rust compile/spec-parser trace events;
- `.4.4`: Rust runtime dispatch and branch trace events;
- `.4.5`: cross-variant trace parity closeout, docs, and future-variant checklist.

The active frontier is `TRACE-OBSERVABILITY.4.3`. Rust now has the `.4.2` control layer, but it cannot claim trace
parity until `.4.3` compile/spec-parser events, `.4.4` runtime branch events, and `.4.5` proof close the
mdBook-documented external trace contract.
