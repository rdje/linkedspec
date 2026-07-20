---
id: duplicate-regex-slot-identity-five-backend-admission
title: "Duplicate regex-slot identity has one exact six-runtime recurring gate"
answers:
  - "is duplicate regex slot identity rollout complete"
  - "how do I run every duplicate slot backend admission"
  - "which CI switch runs the duplicate slot matrix"
  - "what does the duplicate slot recurring gate compose"
date: 2026-07-20
status: confirmed; 7 complete / 0 pending
tags: [regex, slot-identity, recurring-gate, perl, rust, dart, julia, lua, luajit, local-ci, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.8.1.7 closes the seven-leg rollout. tools/check_duplicate_regex_slot_identity_five_backend.sh runs the neutral checker, exact 12-role Perl consumer, exact 15-role Rust/Dart/Julia consumers, the shared 15-role Lua consumer once on PUC Lua and once on LuaJIT, the success_and_rule_consumes primary case across five commands and default/POSIX environments, and generated-source/capability/language-coverage ledgers. The neutral checker requires that topology, 22 public documents, 12 stale-current denials, final parent closure, and 59 independent drift mutations. Canonical local CI exposes the all-toolchain proof behind LINKEDSPEC_RUN_DUPLICATE_SLOT_MATRIX=1."
reverify: "bash tools/check_duplicate_regex_slot_identity_five_backend.sh"
---

The recurring driver adds no parser or runtime mechanism. It composes every
already-admitted duplicate-slot behavior and rejects omissions in runtime, ABI,
role, primary, support, public, CI, rollout, and closure topology.

Run it directly with:

```bash
bash tools/check_duplicate_regex_slot_identity_five_backend.sh
```

Or opt the all-toolchain proof into canonical local CI:

```bash
LINKEDSPEC_RUN_DUPLICATE_SLOT_MATRIX=1 bash tools/run_ci_local.sh
```

Related: [[duplicate-regex-slot-identity-contract]],
[[duplicate-regex-slot-identity-cross-backend-audit]], and
[[FUTURE-PARITY-BACKLOG]].
