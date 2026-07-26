---
id: julia-anonymous-capture-boundary-helpers
title: Julia executes the complete direct anonymous capture-boundary family
answers:
  - does Julia support capture_slice
  - does Julia support start_capture_slice
  - does Julia support capture_take and capture_rest
  - are Julia capture lengths and positions character based
  - which Julia hlink corpus fixtures pass after capture boundary parity
  - why does Julia ebnf_logging_annotation still fail after capture helpers
  - what does JULIA-BACKEND-PARITY.6.2.4.1 prove
date: 2026-07-10
status: current
tags: [julia, runtime, capture, source-boundaries, corpus, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.1 adds anonymous capture execution in julia/src/runtime/Interpreter.jl over RuntimeMatchRegisters.capture_start_codeunit. Three Unicode/location/mutation runtime assertions plus six corpus assertions bring full Pkg.test() to 766. hlink_curly_brace, hlink_bracket_body, and hlink_mixed_bracket_brace pass; ebnf_logging_annotation advances from unsupported start_capture_slice to the same structural output mismatch class as ebnf_expression_rules; the full shipped-smoke window is 13/31."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()' && bash tools/run_julia_project_data.sh --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
---

Julia's runtime executes the complete direct anonymous capture-boundary family over the existing rule-local
`RuntimeMatchRegisters.capture_start_codeunit` state:

- `start_capture_slice()` sets the origin to the live cursor.
- `capture_slice()` / `_len` and `capture_take()` / `_len` read to the current local-match start.
- `capture_slice_until_cursor()` / `_len` and destructive take variants read to the live cursor.
- `capture_rest()` / `_len` and destructive take-rest variants read to input end.
- `capture_slice_pos()` / `_line` / `_col` report the origin location.

Text extraction is code-unit safe, while lengths and positions are in characters. Destructive variants advance the
anonymous origin to the live cursor, or to input end for take-rest, only after a valid span. Focused tests use `é`
and a newline to distinguish code units from character offsets and to lock line/column behavior.

`hlink_curly_brace`, `hlink_bracket_body`, and `hlink_mixed_bracket_brace` now pass. A permanent corpus test locks
that 3/3 result. `ebnf_logging_annotation` no longer fails on unsupported `start_capture_slice`; it now loses the
same structural items as `ebnf_expression_rules`, so `.6.2.4.4` owns that residual. The complete shipped-smoke
window is 13/31, full tests pass with 766 assertions, and status is `runtime-corpus-capture-boundaries`.

`.6.2.4.2.1` has since added eager logical helpers and moved shipped smoke to 17/31; `.6.2.4.2.3` then normalized
helper regex flags and moved it to 18/31.

Related facts: [[julia-helper-regex-flag-normalization]], [[julia-logical-helper-execution]], [[julia-shipped-corpus-smoke-split]], [[rust-anonymous-capture-slice-family]],
[[spec-capture-mark-family-taxonomy]], [[perl-capture-slice-delimiter-seek-boundary]],
[[dart-helper-action-surface-bridge]], [[rust-perl-output-oracle]].
