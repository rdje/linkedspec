---
id: perl-quoted-boundary-labels
title: Quoted boundary atoms stay whole through nested lexical serialization
answers:
  - "does capture_until_boundary preserve a quoted comma argument"
  - "why did a quoted comma label create a false Perl boundary"
  - "where are capture_until_boundary quoted labels decoded"
  - "does quoting an unresolved boundary label resolve its component words"
  - "why does an escaped comma boundary remain an undefined helper inside assignment"
  - "does the quoted boundary repair publish source sidecars"
date: 2026-10-06
status: atomic-label and nested lexical repair verified by separate retained epochs
tags: [perl, actionir, boundary, quoted, tokenization, source-ownership]
evidence: "Historical .1.4.0.1 at b215 verifies4346 originals/eight commands;18 cases/28 events/14 compiler cases/three seeds, RED9-GREEN18/1169 groups/36 RED.13 runtimes succeed; one nested unknown-escape P1 exclusion remains. Book58/2/3/9 and37-hash historical freeze pass."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1-review.py"
  - "bash tools/project_data_run.sh prove -v -Iperl t/capture_boundary_quoted_labels.t"
---

# Preserve the recognized quoted atom before decoding it

Both the original Legacy scanner and Contracts lowerer recognize complete quoted
or word atoms but subsequently split the captured payload on every comma. A
quoted unresolved `"a,b,c"` therefore produces a usable middle `b` rule. Public
Get with input `body b rest`, a `b: /b/` rule and an `end: /END/` rule actually
returns an empty body at cursor zero; correct whole-label lookup ignores the
unresolved comma label and captures through EOF because `end` is usable.

The shared private BoundaryLabels decoder consumes those already recognized
atoms, then preserves the existing quote/backslash unescape and empty-label
filter. It does not generalize CSV syntax, call MethodExpr callbacks or alter
the outer recognizers. Its function-local regex scope preserves the caller's
complete original helper match; repeated raw occurrences and Unicode/CRLF scalar
intervals remain exact. The scanner/lowerer public schema is unchanged. Boundary
source sidecars remain owned by the subsequent anonymous-capture leaf.

The original `body = capture_until_boundary("a\,b", end)` gap was not repaired
by atomic label parsing. Assignment serialization doubled the unknown backslash,
then the original helper event could not find its spelling: actual scoped trace
reported source_span_missing and runtime called an undefined helper. Parent
.1.4.0.1 preserves that failure and two skipped runtime assertions historically at
b2156813fffed53622e640583a46a4ca94186a08; its original evidence stays immutable.

Successor .1.4.0.1.1 restores this existing Perl behavior by preserving only a
fully recognized call spelling whose decoded atoms and count agree with typed
arguments. Read [the serializer fact](perl-boundary-call-lexical-serialization.md).
The standard quoted fixture enables both runtime assertions, and recurring Phase0
includes public comma/assignment/return/hash controls. Neither leaf adds boundary
source sidecars or admits quoted executable membership; .7.2.2 still owns that
separate failure and .1.4.2 owns anonymous-capture provenance.
