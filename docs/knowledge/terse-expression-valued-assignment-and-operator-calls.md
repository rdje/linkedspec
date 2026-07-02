---
id: terse-expression-valued-assignment-and-operator-calls
title: "SPEC-FORMAT-TERSE: operator spellings are ordinary value-producing calls, and assignment is expression-valued with =(target,value) equivalent to target = value."
answers:
  - "is =(target, value) equivalent to target = value in terse .spec"
  - "does assignment have a value in the terse format"
  - "is assign(target, value) canonical or legacy after terse assignment"
  - "are comparison operators like >=(...) and !=(...) ordinary calls"
  - "are gt(a,b) and >=(a,b) part of the uniform operator call surface"
  - "why was SPEC-FORMAT-TERSE.3.3 split before code"
  - "what is the next assignment expression leaf after SPEC-FORMAT-TERSE.3.3"
  - "which assignment expression leaves are implemented after SPEC-FORMAT-TERSE.3.3.3"
date: 2026-07-02
status: current
tags: [spec-format-terse, operators, assignment, expressions, comparisons, task-tree]
evidence: "User clarification on 2026-07-01 accepted the uniform operator-call doctrine: comparison operators should be captured as ordinary call/method spellings such as gt(a,b), >=(a,b), ne(a,b), and !=(a,b). The same clarification states that assign(a,b) is replaced by a = b, that =(a,b) is equivalent to a = b, and that assignment is an expression with a value. SPEC-FORMAT-TERSE.3.2.3.4 landed comparison symbol calls on 2026-07-02. SPEC-FORMAT-TERSE.3.3 audited assignment before code and split implementation into .3.3.1 scalar expression values, .3.3.2 aggregate target-kind expression values, .3.3.3 append/hash-index mutation expression values, and .3.3.4 compatibility/docs/oracle closure. SPEC-FORMAT-TERSE.3.3.1 ships the scalar subset; SPEC-FORMAT-TERSE.3.3.2 ships direct RHS shape assignment expression values; SPEC-FORMAT-TERSE.3.3.3 ships append and hash-index mutation expression values; .3.3.4 remains the compatibility/docs/oracle closure."
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.3|SPEC-FORMAT-TERSE\\.3\\.3\\.1|=\\(target, value\\)|statement-only|expression-valued assignment\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/knowledge/terse-expression-valued-assignment-and-operator-calls.md docs/linkedspec-book/src/appendix/helper-contract-catalog.md"
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

The `.3.3` audit split implementation so the scalar, aggregate, append/hash-index, and compatibility/documentation
contracts could land separately. `SPEC-FORMAT-TERSE.3.3.1` landed the scalar subset:

- `return(name = "ok")` stores `ok` in scalar `name` and yields `ok`.
- `return(=(name,"ok"))` is the scalar operator-call equivalent.
- Scalar `set(name,value)` / `assign(name,value)` compatibility forms now yield the stored value in scalar
  value positions.
- Nested scalar assignment expressions and receiver chains on the assigned scalar value are supported.

`SPEC-FORMAT-TERSE.3.3.2` then landed the aggregate direct-shape subset:

- `return(items = [value])` stores the array working variable and yields the assigned array value.
- `return(=(meta, { key => value }))` stores the hash working variable and yields the assigned hash value.
- Matching explicit `array(target)` and `hash(target)` assignment targets yield aggregate snapshots.
- Explicit `scalar(target)` assignment targets still keep scalar-held shape payloads.

`SPEC-FORMAT-TERSE.3.3.3` then landed the mutation subset:

- `return(items += value)` mutates the named array and yields the updated array snapshot.
- `return(meta[key] = value)` mutates the named hash and yields the updated hash snapshot.
- Parenthesized mutation assignment expressions can feed compatible receiver chains.

The implementation frontier is now `.3.3.4` for compatibility/docs/oracle closure. See
[[terse-scalar-assignment-expression-values]], [[terse-aggregate-assignment-expression-values]], and
[[terse-mutation-assignment-expression-values]] for the landed subsets.
