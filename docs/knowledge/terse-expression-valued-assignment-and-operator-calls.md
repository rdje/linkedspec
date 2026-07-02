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
  - "are assignment operators statement-only today"
date: 2026-07-02
status: current
tags: [spec-format-terse, operators, assignment, expressions, comparisons, task-tree]
evidence: "User clarification on 2026-07-01 accepted the uniform operator-call doctrine: comparison operators should be captured as ordinary call/method spellings such as gt(a,b), >=(a,b), ne(a,b), and !=(a,b). The same clarification states that assign(a,b) is replaced by a = b, that =(a,b) is equivalent to a = b, and that assignment is an expression with a value. SPEC-FORMAT-TERSE.3.2.3.4 landed comparison symbol calls on 2026-07-02. SPEC-FORMAT-TERSE.3.3 then audited assignment before code: TOOLBOX probes show statement `name = \"ok\"; return(name)` works, but `return(name = \"ok\")`, `return(=(name,\"ok\"))`, `return(set(name,\"ok\"))`, and nested assignment helper args fail/null today; Rust expression evaluation still diagnoses scalar assignment, array append, and hash-index assignment as statement-only. Therefore .3.3 split implementation into .3.3.1 scalar expression values, .3.3.2 aggregate target-kind expression values, .3.3.3 append/hash-index mutation expression values, and .3.3.4 compatibility/docs/oracle closure."
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

Current implementation is not yet at the full assignment contract. `SPEC-FORMAT-TERSE.1.3.4.1` landed
statement-only scalar assignment, and the `.3.3` audit confirmed value-position assignment is still not
runnable:

- `name = "ok"; return(name)` works as a statement followed by a scalar read.
- `return(name = "ok")` does not yield an assignment-expression value today.
- `return(=(name,"ok"))` is not runnable assignment operator-call syntax today.
- `return(set(name,"ok"))` and `set(out, name = "ok")` do not produce assignment-expression values today.
- Rust expression evaluation still treats scalar assignment, array append, and hash-index assignment as
  statement-only nodes.

`SPEC-FORMAT-TERSE.3.3` is therefore a completed split/ownership leaf, not an implementation leaf. The current
frontier is `SPEC-FORMAT-TERSE.3.3.1`: scalar assignment expression values and scalar `=(target,value)`
equivalence. Later children own aggregate target-kind assignment values (`.3.3.2`), append/hash-index mutation
expression values (`.3.3.3`), and compatibility/docs/oracle closure (`.3.3.4`).
