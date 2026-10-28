---
id: capture-boundary-number-julia-method-compatibility
title: Julia readonly capture Number sources already compose through ordinary methods
answers:
  - "does Julia capture_rest_len support coalesce and String methods"
  - "can Julia anonymous capture Number readers feed Array selection"
  - "which Julia capture Number aliases preserve function-state errors"
date: 2026-10-28
status: bounded33.4 targeted-checked without runtime edits; pre-match endpoint40 and full admission open
tags: [julia, capture, number, fluent, aliases, source, generated]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.33.4 at clean75365a176; capture-boundary-number-julia-intake.json.gz retains exact intake/normal-test/source/output epochs."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/capture_boundary_number_results_test.jl"); include("julia/test/entry_match_number_results_test.jl")'"
---

Existing capture-helper dispatch and typed call/method evaluation in
julia/src/runtime/Interpreter.jl already support six canonical readonly sources
and three length aliases. New75 plus existing Number12 assertions pass native/
reconstructed SpecFile/plan/fresh emitted Module, strictly distinguishing Bool
from Number. Shared11/original9, snapshot4!/later boundary6/S, position-zero lazy
skip, String/Array/signed-selection and actual direct legacy4/[]/KVT are retained.

All nine function sources preserve authored helper names and typed native versus
generated exception classes. An explicit callback in parser context returns1!;
a registered callback invoked in pure apply rejects capture_rest_len. No new
parser-state rights in functions/callback vocabularies or runtime edits follow.
Fresh Module is same-process independent source loading, not isolated package
proof. Normal runner registers the self-contained test; no new temp owner.

The additional no-local-match capture_slice_len case stays diagnostic. Julia
returns null, Dart0, and Perl0 with unset-position warnings; see
[[capture-boundary-before-match-policy-divergence]]. Normal zero coverage uses
defined boundary positions, with no healthy credit for that unresolved width.
40 must resolve authority before admission;33.3.1 refines Dart's recent test.
