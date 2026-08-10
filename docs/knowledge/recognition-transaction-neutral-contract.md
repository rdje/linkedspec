---
id: recognition-transaction-neutral-contract
title: The executable neutral recognition-transaction contract covers 132 node rows, 246 call rows, and 40 mutations
answers:
  - "where is the executable neutral recognition transaction contract"
  - "how do I run the recognition transaction checker"
  - "how many ActionIR node effects does the transaction contract classify"
  - "how many current ActionIR node kinds are there"
  - "why are there 128 ActionIR nodes but 122 public Perl contracts"
  - "how many canonical call effects does the recognition transaction contract classify"
  - "what recognition transaction fixtures are executable"
  - "how are recursive rule effects checked for transactions"
  - "how many recognition transaction mutations are rejected"
  - "is recognition transaction syntax executable in a backend"
  - "what is the recognition transaction rollout status"
  - "does the neutral transaction checker change parser behavior"
date: 2026-08-10
status: current neutral authority; all backend, recurring, and public legs remain RED
tags: [cursor, transactions, recognition, actionir, effects, progress, marks, recursion, conformance]
evidence: "FUTURE-PARITY-BACKLOG.14.3.1.1 adds linkedspec-recognition-transaction-v1 plus an independent checker. The checker derives 128 live ActionIR node kinds from Perl and the same 246 current call names from Dart, Julia, and Lua; adds four future RECOGNITION_* rows; executes token 8/17, effect graphs 6, marks 6, progress 8, diagnostics 15; and rejects 40 mutations."
reverify: "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl --report"
---

The canonical artifact is `capability_conformance/recognition_transaction_contract.json`; its independently
implemented oracle is `tools/check_recognition_transaction_contract.py`. Canonical and focused execution route the
checker through repository-local project data:

```bash
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
```

The checker derives 128 unique current canonical ActionIR node kinds from
`perl/LinkedSpec/ActionIR/Contracts.pm`. It requires one base-effect row for each plus the four future dedicated
transaction nodes, for 132 total. This is a different census from the 122 public identifier-shaped Perl contracts
reported by `tools/check_language_capability_coverage.pl`: the latter counts public call-contract names after
classifying internal/compatibility names, not unique ActionIR node kinds.

The call-effect side derives the exact 246-name inventories independently from Dart, Julia, and Lua and requires
them to agree before comparing all rows. Both surfaces use the closed nine-allowed/eleven-rejected vocabulary and
fail on missing, duplicate, unknown, stale, or reclassified rows. Six call graphs—including direct and mutual
recursion—are evaluated to a fixed point so a transitive forbidden effect cannot hide behind a callee.

Executable semantic fixtures cover eight valid falsey-safe token outcomes, seventeen token/ownership failures,
six invocation-mark snapshot/isolation cases, eight repetition/direct/mutual-recursion progress cases, and fifteen
portable diagnostic records. Forty in-memory mutations cover schema, syntax, token/result, effects, inventories,
graphs, marks, progress, diagnostics, rollout, canonical registration, tracked input, freshness, and the
public-current boundary.

Only the neutral rollout leg is complete. Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, recurring composition, and
public no-drift remain RED. The artifact is executable proof of a future target; no current grammar, compiler,
runtime, backend, generated source, descriptor/schema, CLI, semantic/MCP, capability, or authored feature changes.
