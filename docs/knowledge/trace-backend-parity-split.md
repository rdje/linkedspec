---
id: trace-backend-parity-split
title: TRACE-OBSERVABILITY.4 owns Rust and future trace parity after the .3.5 contract closeout
answers:
  - "what is TRACE-OBSERVABILITY.4"
  - "what is TRACE-OBSERVABILITY.4.1"
  - "what is next after TRACE-OBSERVABILITY.3.5"
  - "how is backend trace parity split"
  - "does Rust currently have trace controls"
  - "what owns Rust trace parity"
date: 2026-07-04
status: current
tags: [trace, observability, rust, parity, task-tree, mdbook]
evidence: "TRACE-OBSERVABILITY.3.5 no-drift probes; docs/tasks/TRACE-OBSERVABILITY.md .4 split; docs/linkedspec-book/src/public-api/trace-api.md variant-neutral trace contract"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.4|TRACE-OBSERVABILITY\\.4\\.1|variant-neutral trace contract|Rust trace parity design|rust --glob' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md ROADMAP_V2.md docs/linkedspec-book/src/public-api/trace-api.md docs/knowledge/trace-backend-parity-split.md"
---

`TRACE-OBSERVABILITY.3.5` closed the Perl reference trace no-drift/contract leaf and split the required backend
parity work into `TRACE-OBSERVABILITY.4.*` before any Rust trace code changes. `TRACE-OBSERVABILITY.4.1` has since
closed the Rust design inventory; `.4.2` is the first Rust implementation leaf.

The split is:

- `.4.1`: done — Rust trace contract/design inventory before code;
- `.4.2`: active — Rust trace controls, levels, and sinks;
- `.4.3`: Rust compile/spec-parser trace events;
- `.4.4`: Rust runtime dispatch and branch trace events;
- `.4.5`: cross-variant trace parity closeout, docs, and future-variant checklist.

The active frontier is `TRACE-OBSERVABILITY.4.2`. The `.3.5` Rust inventory command excluded corpus fixtures and
found no Rust trace API/control hits, and `.4.1` changed only documentation/design. Rust cannot claim trace parity
until the `.4.*` lane implements and proves the mdBook-documented external trace contract.
