---
id: perl-quoted-boundary-labels
title: Quoted boundary atoms stay whole; nested unknown escapes have a separate rewrite gap
answers:
  - "does capture_until_boundary preserve a quoted comma argument"
  - "why did a quoted comma label create a false Perl boundary"
  - "where are capture_until_boundary quoted labels decoded"
  - "does quoting an unresolved boundary label resolve its component words"
  - "why does an escaped comma boundary remain an undefined helper inside assignment"
  - "does the quoted boundary repair publish source sidecars"
date: 2026-10-06
status: atomic-label repair verified; nested unknown-escape child pending
tags: [perl, actionir, boundary, quoted, tokenization, source-ownership]
evidence: "Owning .1.4.0.1 verifies4346 originals/eight commands;18 cases/28 events/14 compiler cases/three seeds, RED9-GREEN18/1169 groups/36 RED.13 runtimes succeed; one nested unknown-escape P1 exclusion remains. Book58/2/3/9 and37-hash historical freeze pass."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1-review.py"
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

The independently observed `body = capture_until_boundary("a\,b", end)` gap is
not repaired by atomic label parsing. The direct scanner and substitution now
retain its whole label, but assignment lowering normalizes the unknown escape
to two backslashes. The later helper event still has the original spelling;
RewritePipeline reports `source_span_missing` for capture_until_boundary and the
generated parser retains an unresolved call. Runtime records an undefined-helper
error. P1 child `.1.4.0.1.1` is scheduled immediately after this clean commit,
before `.1.4.2`; its fix requires original-to-rewritten occurrence ownership.
The standard fixture explicitly excludes its two runtime assertions while actual
before/after public probes retain and verify the failure. No unknown-escape or
cross-backend escape acceptance is claimed.

The new quoted-label fixture is selected in this focused proof. Canonical CI
currently invokes Phase0 and selected explicit ActionIR suites rather than every
new t/ file. The immediate repair child also owns recurring Phase0 public
quoted-label/unknown-escape coverage; this leaf does not claim that the new
standalone fixture has separate canonical registration.
