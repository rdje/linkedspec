---
id: terse-string-receiver-value-chains
title: String receiver chains and predicate result flow
answers:
  - "why do starts_with ends_with contains_substr and matches stop before cat"
  - "how do string receiver-dot value chains work"
  - "does raw.trim().lowercase work"
  - "does raw.split().join_values work"
  - "does string literal receiver-dot work"
  - "does receiver-dot substr work"
  - "can string terminal methods continue"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.3"
  - "are block-valued receiver chains task-tree owned"
date: 2026-10-26
status: bounded Perl predicate flow checked; other backends/full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, string, rust-parity, mdbook]
evidence: "String2.3.5.3 historical detail/commands at Gite19f3ce83543d8befff3abc381d85a6b6285da15 for this path; Length23.3.3 and predicate23.2.9 public native/fresh distinctions."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/string_predicate_result_receiver_contract.t t/emptiness_result_receiver_contract.t"
---

String chains compose current pure helpers: raw.trim().lowercase().replace_substr("-","_"), "abcdef".substr(1,3).uppercase() ->BCD, and raw.trim().split("-").trim_each().lowercase_each().join_values("|"). Current bare bindings/cat supersede historical scalar()/concat spellings. Length23.3.3 now feeds compatible scalar/number methods (count-length-results.md), rather than remaining terminal. Historical next leaf was2.3.5.4; block-valued2.3.5.5 scope and full original evidence remain at the Git pointer above.

TYPE23.2.9 observed native/fresh producer vector[1,1,1,1,0,0], null/empty boundaries and nested1!/SOC/zzztail snapshots agree. Fluent starts_with/ends_with/contains_substr/matches cat stopped at null: MethodLowering::_string_receiver_value_chain_return_family labeled them terminal; substitution was return undef. Preserve correct producers/actual kinds/regex policies; bounded frozen string-predicate-results.md scheduled Perl23.3.10.1 before independent backends. Malformed native controls return[null,""] without effects. Full domains/contexts/portable admission stay23.4; no String-comparison receiver or contains calibration change.

Perl23.3.10.1 now uses scalar_result/one-operand preflight for these four methods. Native/fresh shared/direct emptiness tests pass after RED, retaining true/false/null/empty/regex-i and source families, false retention/generic predicates/bridges/scalar nulls, eight malformed no-effect controls and SOC/SC/once-only snapshots. Producer/kind/regex/domain/source/copy unchanged; Rust2 assessment/full admission remain open.
