---
id: julia-shipped-corpus-smoke-split
title: Julia shipped-spec parser-smoke window starts 10/31 and is split by failure family
answers:
  - what does JULIA-BACKEND-PARITY.6.2.4.0 prove
  - why is the Julia shipped corpus smoke batch split
  - which Julia shipped-spec corpus fixtures already pass
  - which Julia shipped-spec corpus failures are known
  - what is the Julia corpus frontier after the middle batch
  - how many Julia shipped-spec parser-smoke fixtures pass initially
date: 2026-07-10
status: current
tags: [julia, corpus, shipped-specs, parser-smoke, helpers, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.0 runs julia/bin/corpus_runner.jl with --offset 68 --limit 31 and records 10 passed / 21 failed. The task tree accounts for every failure under anonymous capture boundaries, logical helpers, diagnostic-output helpers, recursive top-rule outputs, EBNF/spec.spec structural outputs, or lib_reader quote normalization before Julia behavior changes."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
---

`JULIA-BACKEND-PARITY.6.2.4.0` is a planning split, not a runtime fix. The complete shipped-spec/parser-smoke
window at manifest offsets 68 through 98 starts at 10 passed and 21 failed.

The initially passing fixtures are `tclite_command_subst`, `tclite_double_quote`, `lispish_x_y`,
`hlink_raw_string`, `hlink_raw_escaped_brackets`, `portmap_slice`, `regdef_nested_register_fields`,
`vhdl_library_use`, `pplugin_empty`, and `tkgui_empty`.

Every failing fixture is routed exactly once before implementation:

- `.6.2.4.1`: three hlink delimiter fixtures plus `ebnf_logging_annotation`, initially blocked by unsupported
  anonymous `capture_slice` / `start_capture_slice` helpers. That leaf now closes all three hlink cases; EBNF
  logging reaches the structural-output residual under `.6.2.4.4`.
- `.6.2.4.2.1`: four portmap fixtures plus `tablegrep_simple_term`, initially blocked by unsupported `or` / `not`
  helpers. That leaf now closes three portmap cases plus tablegrep; `.6.2.4.2.3` owns portmap constant's proven
  helper-regex `o` flag residual. `.6.2.4.2.3` has since closed that residual and all five cases pass.
  - `.6.2.4.2.2`: `simenv_multiline_value` and `ds_vhistory_version_entry`, initially blocked by unsupported
    `print`. That leaf advanced simenv to unsupported `exit_now` and history to its leading-trivia output mismatch.
    `.6.2.4.5.1` now executes the fatal helper and exposes simenv's earlier statement-mutation prerequisite.
- `.6.2.4.3`: three recursive top-rule fixtures that initially returned incorrect nested/caller values. That leaf
  now scopes explicit aggregate resets per rule invocation and all three cases pass.
- `.6.2.4.4`: `ebnf_expression_rules` plus four spec.spec smokes initially lost structural records. Action-edge
  child-push parity now closes all four spec.spec cases and advances both EBNF cases to quote-only statement
  mutation residuals under `.6.2.4.5.2`.
- `.6.2.4.5`: the remaining non-final mechanisms are split into `exit_now` control (`.5.1`), EBNF/lib_reader/
  simenv statement mutation (`.5.2`), and history public-parser leading trivia (`.5.3`).
- `.6.2.4.6`: final 31/31 regression and no-drift closeout.

The checked-in expected JSON remains the Perl/Rust oracle. Completed Dart facts identify portable mechanism
contracts, but the Julia leaves must establish their own root causes. After `.6.2.4.5.2`, statement regex mutation
closes both EBNF, both lib_reader, and simenv fixtures without fixture-specific cleanup. The complete window is
30/31. Full tests pass with 808 assertions, status is `runtime-corpus-statement-mutation`, and `.6.2.4.5.3` is
active for the sole history leading-trivia residual.

Related facts: [[julia-statement-regex-mutation]], [[julia-exit-now-control]], [[julia-action-edge-child-push]], [[julia-recursive-rule-local-reset-scope]], [[julia-diagnostic-output-helpers]], [[julia-helper-regex-flag-normalization]], [[julia-logical-helper-execution]], [[julia-anonymous-capture-boundary-helpers]], [[julia-middle-corpus-batch]], [[julia-controlled-corpus-execution]],
[[dart-shipped-corpus-smoke-split]], [[dart-helper-action-surface-bridge]],
[[rust-anonymous-capture-slice-family]], [[rust-perl-output-oracle]].
