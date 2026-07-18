---
id: logical-helper-recurring-five-backend-gate
title: One omission-checked driver owns recurring logical-helper conformance
answers:
  - "how do I run the recurring five-backend logical helper gate"
  - "what prevents a logical generated role from being omitted"
  - "which logical helper consumers are required"
  - "which generated roles does the logical gate require"
  - "what is LINKEDSPEC_RUN_LOGICAL_MATRIX"
  - "which primary case does the logical gate run"
date: 2026-07-18
status: current
tags: [logical, recurring-gate, generated-source, primary-cli, ci, perl, rust, dart, julia, lua, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.8 adds tools/check_logical_helper_five_backend.sh and an exact recurring_gate topology to linkedspec-logical-helper-v1. The driver passes the neutral checker, Perl/Rust/Dart/Julia/PUC Lua/LuaJIT focused consumers, success_logical_helpers_eager through 5 commands x 2 environments, and generated-source/capability/coverage ledgers. FUTURE-PARITY-BACKLOG.5.2.9 adds public no-drift; the checker reports 8 complete / 0 pending and rejects 26 mutations, including backend, generated-role, primary, support, driver, CI-registration, public-surface, and rollout omissions. FUTURE-PARITY-BACKLOG.9.1.4.5 migrates the exact Rust typed role names and source markers to generated-source v2; canonical local CI registers the same all-toolchain leg behind LINKEDSPEC_RUN_LOGICAL_MATRIX=1."
reverify: "bash tools/check_logical_helper_five_backend.sh"
---

Run the complete recurring proof from the repository root:

```bash
bash tools/check_logical_helper_five_backend.sh
```

The driver is intentionally strict: Perl, Cargo/Rust, Dart, Julia, PUC Lua, and LuaJIT must all be available.
It runs one focused consumer for each runtime, builds disposable native Lua adapters for both ABIs, selects only
`success_logical_helpers_eager` from the existing primary matrix, then runs the generated-source, capability, and
language-coverage authorities. Canonical local CI executes this expensive all-toolchain leg only when
`LINKEDSPEC_RUN_LOGICAL_MATRIX=1`, while every ordinary run still audits its tracked path and shell syntax.

The neutral contract stores more than test paths. It records the exact ordered role set for each backend: Perl
native/primary plus `Execute`/`ExecuteWithTrace`/`Get`; Rust native/serialized, typed-v2 and compatibility
direct/traced, plus emitted execute/parse direct/traced; and Dart/Julia/Lua native/reconstructed/primary,
generated-plan direct/traced, and emitted direct/traced. The offline checker requires literal evidence for every
role and mutates each omission class, so a still-green test file cannot silently stop covering an entrypoint.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-generated-primary-projection]],
[[logical-helper-five-backend-audit]], [[generated-source-contract-v1]], [[logical-helper-public-no-drift]].
