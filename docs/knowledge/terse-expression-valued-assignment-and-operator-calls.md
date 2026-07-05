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
  - "is SPEC-FORMAT-TERSE.3.3.4 done"
date: 2026-07-04
status: current
tags: [spec-format-terse, operators, assignment, expressions, comparisons, task-tree]
evidence: "User clarification on 2026-07-01 accepted the uniform operator-call doctrine: comparison operators should be captured as ordinary call/method spellings such as gt(a,b), >=(a,b), ne(a,b), and !=(a,b). The same clarification states that assign(a,b) is replaced by a = b, that =(a,b) is equivalent to a = b, and that assignment is an expression with a value. SPEC-FORMAT-TERSE.3.2.3.4 landed comparison symbol calls on 2026-07-02. SPEC-FORMAT-TERSE.3.3 audited assignment before code and split implementation into .3.3.1 scalar expression values, .3.3.2 aggregate/direct-shape expression values, .3.3.3 append/hash-index mutation expression values, and .3.3.4 compatibility/docs/oracle closure. SPEC-FORMAT-TERSE.11.2 and .11.3 later changed bare direct-shape storage from target-kind inference to duck-typed value binding while preserving assignment expression values. SPEC-FORMAT-TERSE.3.3.4 temporarily kept assign(...) as a legacy alias only; SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file assign(...). Current syntax is target = value, =(target,value), or set(target,value). See [[terse-assignment-expression-closure]], [[terse-duck-typed-assignment-perl-reference]], [[terse-rust-duck-typed-assignment-parity]], and [[terse-retired-scalar-assign-spec-surface]]."
reverify: "rg -n \"SPEC-FORMAT-TERSE\\.3\\.3|SPEC-FORMAT-TERSE\\.3\\.3\\.1|=\\(target, value\\)|statement-only|expression-valued assignment\" docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md docs/knowledge/terse-expression-valued-assignment-and-operator-calls.md docs/linkedspec-book/src/appendix/helper-contract-catalog.md"
---

# Expression-valued assignment and operator calls

The accepted terse contract is uniform:

- Operator spellings are ordinary value-producing calls when the relevant leaf implements them.
- Comparison calls include word and symbol spellings such as `gt(a,b)` / `>(a,b)`, `ge(a,b)` / `>=(a,b)`,
  `ne(a,b)` / `!=(a,b)`, plus the matching `eq`/`==`, `lt`/`<`, and `le`/`<=` pairs.
- `target = value` is the canonical assignment spelling.
- `=(target, value)` is the operator-call equivalent of `target = value`.
- `assign(target, value)` was legacy migration debt and is now retired from authored specs.
- Assignment has a value: the typed value stored in the target after assignment.

The `.3.3` audit split implementation so the scalar, aggregate, append/hash-index, and compatibility/documentation
contracts could land separately. `SPEC-FORMAT-TERSE.3.3.1` landed the scalar subset:

- `return(name = "ok")` stores `ok` in scalar `name` and yields `ok`.
- `return(=(name,"ok"))` is the scalar operator-call equivalent.
- Scalar `set(name,value)` yields the stored value in scalar value positions; historical `assign(name,value)`
  compatibility was retired from authored specs by `.6.2.3.2`.
- Nested scalar assignment expressions and receiver chains on the assigned scalar value are supported.

`SPEC-FORMAT-TERSE.3.3.2` then landed the direct-shape subset, whose expression-valued result remains current even
though `.11.2`/`.11.3` later replaced bare target-kind storage inference with duck-typed value binding:

- `return(items = [value])` binds an array value and yields that stored array value.
- `return(=(meta, { key => value }))` binds a hash value and yields that stored hash value.
- Matching explicit `array(target)` and `hash(target)` assignment targets yield aggregate snapshots.
- Explicit aggregate targets still use aggregate storage.

`SPEC-FORMAT-TERSE.3.3.3` then landed the mutation subset:

- `return(items += value)` mutates the named array and yields the updated array snapshot.
- `return(meta[key] = value)` mutates the named hash and yields the updated hash snapshot.
- Parenthesized mutation assignment expressions can feed compatible receiver chains.

`SPEC-FORMAT-TERSE.3.3.4` then closed the parent assignment-expression contract and mdBook compatibility policy:
public examples prefer `set(...)` or operator assignment; `.6.2.3.2` later removed authored-spec `assign(...)`.
See [[terse-assignment-expression-closure]], [[terse-scalar-assignment-expression-values]],
[[terse-aggregate-assignment-expression-values]], and [[terse-mutation-assignment-expression-values]].
