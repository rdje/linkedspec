---
id: terse-string-receiver-value-chains
title: String receiver chains and predicate result flow
answers:
  - "why does rm_prefix numeric JSON still fail an Array-index write on Perl"
  - "can scalar String helpers preserve Number or Boolean identity kinds"
  - "why do starts_with ends_with contains_substr and matches stop before cat"
  - "how do string receiver-dot value chains work"
  - "does raw.trim().lowercase work"
  - "does raw.split().join_values work"
  - "does string literal receiver-dot work"
  - "does receiver-dot substr work"
  - "can string terminal methods continue"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.3"
  - "are block-valued receiver chains task-tree owned"
date: 2026-10-27
status: bounded five-backend predicate flow checked; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, string, rust-parity, mdbook]
evidence: "String2.3.5.3 historical detail/commands at Gite19f3ce83543d8befff3abc381d85a6b6285da15 for this path; Length23.3.3 and predicate23.2.9 public native/fresh distinctions."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/string_predicate_result_receiver_contract.t t/emptiness_result_receiver_contract.t"
---

String chains compose trim/case/replace/substr/cat and split-to-Array helpers; Length23.3.3 feeds scalar/number methods. Current bare bindings/cat supersede historical scalar()/concat. Original details and historical next2.3.5.4/block2.3.5.5 ownership remain at the Git pointer above.

TYPE23.2.9 public native/fresh producer/boundary/SOC controls work, but fluent predicates stopped at null because MethodLowering labeled them terminal. Perl23.3.10.1 now uses scalar_result/one-operand preflight for starts_with/ends_with/contains_substr/matches. Native/fresh result/direct checks pass after RED; source families, false retention/generic/bridges/scalar guards, no malformed effects and SOC/SC snapshots remain correct. Bodies/kinds/regex/source/copy unchanged.

Rust23.3.10.2 adds scalar/preflight lists and repairs dropped action-literal suffix flags in Core parse_regex. Native/restored/plan result/flag/split/filter, direct boundary and focused Core regex checks pass after null/SO/S/12-effect and suffix-flag RED. Preserve numeric substring/Boolean matches, existing pattern-string schema and domains. Rebuild old derived artifacts from source; details: [[action-regex-operands-and-runtime-kinds]]. Dart23.3.10.3 adds scalar/preflight guards, rejects null text operands and retains literal i/m/s modes. Shared/direct emptiness and native/restored/plan mode/split/filter checks pass; actual kinds and SOC/SC snapshots remain correct. Julia23.3.10.4 adds scalar/one-operand guards and null operand false; native/plan/fresh/direct emptiness pass with actual kinds/SOC/SC preserved. Lua23.3.10.5 removes terminal fences, adds scalar/shape guards and null operand false; safe native/plan/fresh/direct checks pass on5.5.1/JIT. Dart23.3.10.6 fixes complete grouped dotted literal priority; broader scanners/full admission and Perl registration23.4.1 remain open.

TYPE23.2.19 freezes scalar-string-results.md for eight ordinary transforms/text
helpers. Public native/fresh eight fluent/nested texts/bridges, SONC snapshots,
Unicode and sources pass; container/malformed tails retain raw DSL and fail.
Actual identity kinds matter: free/fluent/named rm_prefix/rm_suffix numeric0
Array-index writes fail even though JSON prints0. Before JSON, their values have
IOK+POK; empty-old replacement/literal0 retain IOK only, String0 POK only.
Substitution inspects original affix values with index/length/substr, while
BindingRuntime correctly prioritizes POK. Perl19.1 owns inspect-a-copy repair
and scalar flow/shapes before independent19.2-.5; reducer95 remains separate
([[perl-numeric-reducer-string-result-kinds]]). Existing free domains/Unicode/
strict cat/null/callback policy stay. Frozen scalar-text rejects null; the stale
catalog undef-as-empty line is corrected here, not a producer policy change.
