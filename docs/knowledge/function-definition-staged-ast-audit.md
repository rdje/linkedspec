---
id: function-definition-staged-ast-audit
title: Function-definition staged AST tests need a wrapper harness, named captures, and exact provenance
answers:
  - "what is the expected staged function_definition AST shape"
  - "why should function_definition tests use a wrapper top rule"
  - "why does direct top function_definition return null captures"
  - "why are numbered captures wrong for zero-arg functions"
  - "how should zero-arg function definitions parse"
  - "how should regex braces in function bodies be tested"
  - "what function definition variation matrix is required"
  - "what did STAGED-LINKED-PARSING.5.2 audit"
date: 2026-07-02
status: current
tags: [architecture, staged-parsing, user-functions, ast, source-provenance, language-neutral]
evidence: "STAGED-LINKED-PARSING.5.2 audited specs/spec.spec, LinkedSpec::UserFunctionRegistry, Rust parser/compiler structs, phase0 user-function tests, and focused LinkedSpec::Get probes. Direct top regex rules read entry_group(...) as null, so focused AST-shape tests need a wrapper top rule dispatching into a normal function_definition rule. The current specs/spec.spec numbered captures mis-shape zero-arg functions because optional captures are compacted; named captures preserve body correctly. The current body regex also fails or truncates regex literals containing braces. ADR 0017 defines the target neutral function_definition AST shape and variation matrix before implementation."
reverify: "rg -n 'STAGED-LINKED-PARSING\\.5\\.2|0017|function_definition|entry_group\\(\\.\\.\\.\\) as null|zero-argument|regex literals containing braces|body_parse_job' docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0017-function-definition-staged-ast-contract.md docs/linkedspec-book/src ROADMAP_V2.md specs/spec.spec"
---

The focused function-definition AST harness should not make `function_definition` itself
the top regex rule. A top rule has no entering match, so `entry_group(...)` is null
there. Use a small wrapper top rule that dispatches to a normal
`function_definition:` rule, collects child values, and returns them from `LX`.

The current `specs/spec.spec` function rule uses numbered captures around an optional
parameter list. Numbered capture helpers are compacted to participating captures, so
zero-argument functions shift the body into the `params` slot and leave `body` null.
The implementation proof must use named captures or an equivalent structured parse.

The target staged node is a source-ordered function-definition object with `type`,
`name`, parsed `params`, `arity`, exact `source_text`, neutral `source_span`, exact inner
`body_source`, `body_span`, a `body_parse_job`, and a stitched `body_ast` after dispatch.

The variation matrix must include zero/one/many params, whitespace and newline variants,
functions before and between rules, nested bodies, quoted braces, escaped quotes, regex
literals containing braces, adjacency to comments/rules, malformed definitions,
duplicates, collisions, and reserved names.
