---
id: julia-core-spec-parser
title: Julia parses core .spec rule paragraphs into source AST types
answers:
  - does Julia parse spec files yet
  - where is the Julia spec parser
  - what does Julia parse_spec produce
  - can Julia parse shipped specs
  - does Julia parse corpus input specs
date: 2026-07-10
status: current
tags: [julia, parser, ast, backend]
evidence: "julia/src/spec/Parser.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.2` adds `parse_spec(source)` in `julia/src/spec/Parser.jl`. It parses core `.spec` rule
paragraphs into the source AST types from `julia/src/spec/Ast.jl`, covering rule headers/modes, regex slots,
lifecycle blocks, action/blind-call edges, fluent continuations, split/conditional markers, plain blocks, raw
fallback lines, comments, and nested block boundaries.

The focused Julia parser tests cover representative headers, bounded modes, inline body elements, grouped/indexed
edges, attached `when`/`otherwise` blocks, compact lifecycle fluent chains, multiline fluent arguments, quoted
braces inside code blocks, raw fallback lines, all 21 checked-in `specs/*.spec` files, and rule-only corpus
`input.spec` files.

This is source parsing only. Frontend validation and strict syntax have since landed in
`JULIA-BACKEND-PARITY.2.3`; top-level function-shell projection through the
`specs/user_function_definition.spec` node shape has since landed in `JULIA-BACKEND-PARITY.2.4`. Direct
`parse_spec(...)` remains rule-only.

Related facts: [[julia-frontend-ast-json-contract]], [[julia-frontend-validation]],
[[julia-user-function-definition-projection]], [[dart-core-spec-parser]], [[julia-corpus-manifest-io]],
[[text-to-ast-backend-doctrine]].

## 2026-09-11 — parser prefix reading and complete-consumption limitation

Julia .1.30 reads Parser1-692. Unicode-label header scans, grouped action selectors,
numeric/named/invalid selector classification, bare/blind edges, trace cleanup,
bounded modes and inline/body collection are fully read. The single-element
dispatcher body and remaining scanner helpers are still unread.

Both collection loops conditionally discard a remainder after a recognized member.
Inline/body action-edge and E suffix controls lose unsupported text and pass default
and strict validation; I/arrow/separate-raw controls preserve and reject their text.
The exact self-target controls avoid unrelated strict unused-rule rejection. Julia
.2.19 owns source-retention repair; [[julia-parser-member-suffix-loss]] preserves
54 assertions including four explicit-return comparisons. Original parser185 and
adjacent validator23/AST16/lifecycle103 pass327 existing assertions plus selection1.

## 2026-09-11 — parser completion distinguishes three lexical owners

Julia .1.31 completes Parser693-1370. Single-member dispatch, attached conditions,
standalone-I normalization, block origins, brace/parenthesis/literal helpers and
UTF-8-safe substring operations are fully read. The body-fluent adapter discards
an already-returned suffix; compact extraction counts literal parentheses and can
substitute an empty call; outer block depth ignores regex state. These belong to
.2.19, .2.20 and .2.21 respectively. EOF still retains source for balance rejection.

Exact18-case116-assertion native proof is [[julia-spec-lexical-boundary-defects]].
Fresh original frontend224 plus selection1 and Unicode1755 pass. Earlier .2.19
inline/body/E evidence remains intact; no production repair, wider grammar or
fresh CLI/emitted/MCP recurrence is claimed.
