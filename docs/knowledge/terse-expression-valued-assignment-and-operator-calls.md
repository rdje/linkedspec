---
id: terse-expression-valued-assignment-and-operator-calls
title: "SPEC-FORMAT-TERSE: operator spellings are ordinary value-producing calls, and assignment is expression-valued with =(target,value) equivalent to target = value."
answers:
  - "is =(target, value) equivalent to target = value in terse .spec"
  - "does assignment have a value in the terse format"
  - "is assign(target, value) canonical or legacy after terse assignment"
  - "are comparison operators like >=(...) and !=(...) ordinary calls"
  - "are gt(a,b) and >=(a,b) part of the uniform operator call surface"
date: 2026-07-01
status: accepted
tags: [spec-format-terse, operators, assignment, expressions, comparisons, task-tree]
evidence: "User clarification on 2026-07-01 accepted the uniform operator-call doctrine: comparison operators should be captured as ordinary call/method spellings such as gt(a,b), >=(a,b), ne(a,b), and !=(a,b). The same clarification states that assign(a,b) is replaced by a = b, that =(a,b) is equivalent to a = b, and that assignment is an expression with a value. docs/tasks/SPEC-FORMAT-TERSE.md now records SPEC-FORMAT-TERSE.3.2.3 for comparison word/symbol migration and SPEC-FORMAT-TERSE.3.3 for expression-valued assignment plus =(target,value) equivalence. Existing shipped behavior remains narrower: SPEC-FORMAT-TERSE.1.3.4.1 landed statement-only scalar assignment, so implementation must not broaden parser/runtime behavior before the new leaf is selected."
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.3|=\\(target, value\\)|expression-valued assignment|gt\\(a,b\\)|>=\\(a,b\\)\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/knowledge/terse-expression-valued-assignment-and-operator-calls.md"
---

# Expression-valued assignment and operator calls

The accepted terse contract is uniform:

- Operator spellings are ordinary value-producing calls when the relevant leaf implements them.
- Comparison calls include word and symbol spellings such as `gt(a,b)` / `>(a,b)`, `ge(a,b)` / `>=(a,b)`,
  `ne(a,b)` / `!=(a,b)`, plus the matching `eq`/`==`, `lt`/`<`, and `le`/`<=` pairs.
- `target = value` is the canonical assignment spelling.
- `=(target, value)` is the operator-call equivalent of `target = value`.
- `assign(target, value)` is legacy migration debt, not the destination syntax.
- Assignment has a value: the value stored in the target after assignment and target-kind inference.

Current implementation is not yet at the full contract. `SPEC-FORMAT-TERSE.1.3.4.1` landed
statement-only scalar assignment. The follow-up owner is `SPEC-FORMAT-TERSE.3.3`, which must define and
split expression-valued assignment before changing parser/compiler/runtime behavior.

As of `SPEC-FORMAT-TERSE.3.2.3`, comparison calls are split before implementation: explicit string
comparison helpers come first, numeric comparison word aliases second, and comparison symbol callees third.
