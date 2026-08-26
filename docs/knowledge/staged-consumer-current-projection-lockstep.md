---
id: staged-consumer-current-projection-lockstep
title: Admitted staged-AST consumers snapshot the complete neutral current projection
answers:
  - "why did Dart dormant activation require changing Perl and Rust staged tests"
  - "which staged AST assertions must move when a backend lifecycle changes"
  - "why did canonical CI fail after the neutral staged checker passed at 85 mutations"
  - "how do admitted staged consumers prevent stale backend lifecycle projections"
date: 2026-08-26
status: current
tags: [staged-parsing, conformance, tests, lifecycle, mutations, drift, perl, rust, dart]
evidence: "The first exact FUTURE-PARITY-BACKLOG.14.7.5.0 canonical candidate passed the independent 85-mutation neutral checker, then the admitted Perl consumer failed only its three pre-Dart current-projection values: status, mutation count, and Dart pending_absent lifecycle. Exact scan found the same values in the admitted Rust consumer. Both consumers intentionally snapshot the entire neutral contract, so backend lifecycle movement requires their projection literals to move even when their own runtime behavior is unchanged. The task-owned repair changes only those six literals/messages; production, carriers, policies, rollout, generated format, and outward behavior remain unchanged."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "prove -Iperl -It/lib t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
---

# Staged consumer current-projection lockstep

The independent neutral checker is the semantic authority, but every admitted backend consumer also freezes the
complete current neutral snapshot before exercising backend-specific behavior. A later backend's lifecycle change
therefore changes three cross-consumer projection values: the aggregate status string, the governed mutation
count, and that backend's lifecycle row.

This is an intentional cross-check, not backend behavior coupling. Perl and Rust runtime semantics do not change
when Dart enters dormant RED; only their current neutral snapshot must stop claiming Dart is absent. Any future
backend lifecycle transition must run every already-admitted staged consumer, not only the independent checker and
the backend currently moving.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[dart-staged-ast-enrichment-dormant-red]], and ADR
`0088`. Owner: [[FUTURE-PARITY-BACKLOG]] `.14.7.5.0`.
