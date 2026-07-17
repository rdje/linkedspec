---
id: logical-helper-neutral-contract
title: ADR 0043 fixes eager logical helpers over one typed truthiness policy
answers:
  - "what is LinkedSpec logical truthiness"
  - "is string zero true in LinkedSpec"
  - "is string false true in LinkedSpec"
  - "are empty arrays truthful in LinkedSpec"
  - "what arity do and or not accept"
  - "are LinkedSpec logical helpers eager"
  - "how do logical helper arity errors work"
  - "does testing a codeblock invoke it"
  - "which ADR defines LinkedSpec logical helpers"
  - "does the logical contract activate codeblock literals"
date: 2026-07-16
status: accepted-target
tags: [logical, truthiness, arity, actionir, codeblock, generated-source, portability, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.1 adopts ADR 0043 and linkedspec-logical-helper-v1. The independent checker validates 17 truthiness rows, ten helper cases, three eager effect scenarios, receiver and lazy-control contrast, four invalid arities, deterministic embedded fixtures, exact projection obligations, and 15 representative drift mutations. Perl .5.2.2, Rust .5.2.3, and Dart .5.2.4 now consume the unchanged target across their native and available generated/emitted roles, moving the ledger to 3 complete / 5 pending. The explicit-codeblock row remains model/backend-unit evidence and does not activate FUTURE-PARITY-BACKLOG.11 syntax."
reverify: "python3 tools/check_logical_helper_contract.py && prove -Iperl t/logical_helper_perl_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test logical_helper_contract && (cd dart && dart test test/logical_helper_contract_test.dart) && rg -n '0043|linkedspec-logical-helper-v1|three complete / five pending' docs/decisions/0043-eager-logical-helper-and-typed-truthiness.md capability_conformance/logical_helper_contract.json capability_conformance/README.md"
---

The adopted target treats `and`, `or`, and `not` as ordinary boolean value helpers. `and` and `or` accept at
least one positional argument; `not` accepts exactly one. Invalid arity produces `helper_arity_mismatch` with
helper name, actual arity, and expected arity before any operand evaluates. After a valid call is accepted, every
operand evaluates exactly once from left to right. `and`/`or` never short-circuit.

Truthiness is typed:

- null and false are false;
- finite numeric zero, including negative zero, is false; every other finite number is true;
- only the empty string is false, so `"0"`, `"false"`, whitespace, and nonempty Unicode text are true;
- empty arrays and harrays are false; nonempty aggregates are true regardless of their contained values;
- codeblocks are true without invocation.

Every valid logical call returns a real boolean, including one-argument `and(value)` and `or(value)`. Compatible
receiver continuations consume that boolean. `if`, `switch`, and `while` use the same truthiness seam but remain
lazy controls that execute only the selected branch or body.

The codeblock row fixes value-kind behavior only. Because explicit `{|...| ... }` literals remain separately
owned by `FUTURE-PARITY-BACKLOG.11`, the neutral portable source fixture excludes them; backend rollout proves the
row at typed runtime/unit boundaries without silently expanding logical-helper scope.

The target is adopted and current on the Perl reference's native/live/standalone-emitted roles, Rust's native/
serialized/generated-plan/direct-value/compiled-emitted roles, and Dart's native/normalized/generated-plan/
standalone-emitted/primary roles. Cross-backend and public rollout remains 3 complete / 5 pending under
`FUTURE-PARITY-BACKLOG.5.2.5-.9`.

Related facts: [[logical-helper-five-backend-audit]], [[callable-codeblock-literal-contract]],
[[cross-backend-condition-truthiness-drift]], [[rust-logical-helper-neutral-runtime]],
[[dart-logical-helper-neutral-runtime]].
