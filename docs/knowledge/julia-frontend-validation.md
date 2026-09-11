---
id: julia-frontend-validation
title: Julia validates parsed .spec source ASTs before ActionIR or runtime work
answers:
  - does Julia validate spec files yet
  - where is the Julia spec validator
  - what does Julia validate_spec check
  - does Julia have strict syntax validation
  - how does Julia reject bad edge targets
date: 2026-07-10
status: current
tags: [julia, validation, parser, backend]
evidence: "julia/src/spec/Validator.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.2.3` adds `validate_spec(spec; strict_syntax=false)` in
`julia/src/spec/Validator.jl`, plus `SpecValidationException`.

The validator runs on the parsed source AST from `parse_spec(...)`. It checks top-rule presence, duplicate rule
labels, duplicate user function names, user-function registry collisions with rule labels / runtime symbols /
lifecycle markers / ActionIR helper-control names, invalid function names and params, parameter duplicates, arity
mismatches, raw fallback lines, mixed action/blind-call edge families, grouped action-edge targets without a shared
block, undefined edge targets, target regex-slot bounds, structural regex errors, and strict unused-rule behavior.

The focused Julia tests mirror the Dart frontend validator cases and validate all 21 checked-in `specs/*.spec`
files plus rule-only corpus `input.spec` files. `JULIA-BACKEND-PARITY.2.4` has since added projection of
`function_definition` / `function_definition_error` nodes shaped by `specs/user_function_definition.spec`, so
`validate_spec(...)` can validate `SpecFile.functions` produced by that frontend path.

Related facts: [[julia-core-spec-parser]], [[julia-frontend-ast-json-contract]],
[[julia-user-function-definition-projection]], [[dart-frontend-validation]], [[text-to-ast-backend-doctrine]].

## 2026-09-11 — strict validation cannot inspect discarded parser suffixes

Julia .1.30's self-target controls pass default and strict validation after their
unsupported action-edge or E suffixes disappear from parsed state. Initial strict
unused-rule rejection on a regex-only source would mask this loss. Retained raw I,
arrow and separate-line controls reject with the original text. This is parser
source retention under Julia .2.19, not permission to weaken validation or treat
unknown suffixes as comments. Exact evidence is [[julia-parser-member-suffix-loss]].
The unchanged validator testset passes23 assertions inside focused frontend224;
adjacent standalone-lifecycle103 preserves its accepted compatibility boundary.

## September 11 — validator prefix and downstream regex balance

Julia .1.32 reads Validator1-640. Quiet/traced validation follows the same ordered
checks; duplicate namespaces, signatures, retained raw syntax and gap eligibility
are covered before the unfinished edge-structure suffix. Compact lifecycle regex
braces retain full action source but fail the quote-only balance counter at437-460.
Three malformed rejections have identical traced/quiet errors; five comparisons
include correct genuine-EOF rejection. Julia .2.21.3 owns this distinct downstream
repair, coordinated with .2.21.1/.2. Exact evidence and replay are in
[[julia-function-projection-metadata-gaps]]. Existing validator23 remains green.

## September 11 — validator reading complete

Julia .1.33 completes641-1047. Reconstructed named/null selectors resolve anonymous
slots through nullable equality at797/848; moving the declaration moves the wrong
index. The identifier regex at1002-1004 admits terminal LF, letting reserved names
with LF pass exact namespace checks. New .2.23/.2.24 own distinct repair/recurrence
leaves. Ten selector96 and ten identifier54 assertions, with exact valid/rejected
comparisons, are in [[julia-null-selector-and-identifier-validation-gaps]]. Existing
validator23 and larger gap/duplicate matrices remain passing finite evidence.
