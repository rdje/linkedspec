---
id: accumulator-convention-healthy
title: The implicit-target push(Child) accumulator convention is healthy and idiomatic; 95.5% of accumulator ops already use explicit targets with push_value preferred
answers:
  - "is push(Child) without an explicit target deprecated"
  - "what is the accumulator convention in linkedspec"
  - "should I use push_value or push(Child)"
  - "what did the accumulator audit find"
  - "how many specs use convention-based accumulators"
date: 2026-06-12
status: current
tags: [dsl, accumulator, convention, method-lowering]
evidence: "docs/tasks/ACCUMULATOR-CONVENTION-AUDIT.md (3 leaves, done 2026-06-11): 88 total accumulator ops across 19 specs; only 4 convention-based (4.5%) across 3 specs"
reverify: "grep -c 'push(Child)' specs/*.spec; grep -c 'push_value' specs/*.spec"
---

The ACCUMULATOR-CONVENTION-AUDIT task tree (2026-06-11, 3 leaves) established that the implicit-target
`push(Child)` convention is healthy and serves a clear purpose. Key findings:

- **88 total accumulator ops** across 19 shipped specs
- **84 explicit-target (95.5%)**: 63 `push_value`, 19 fluent `.push()`, 2 `push_nonempty`
- **4 convention-based (4.5%)** across 3 specs: `regdef`, `tkgui`, `ebnf`
- **10 specs use zero accumulators**

The audit recommended: keep the convention as-is, document in mdBook, teach `push_value` as
the preferred explicit form for new `.spec` code. The convention is idiomatic, not broken.
It was never migration debt — it was a deliberate framework design choice.

Related: [[method-like-dsl-migration-status]].
