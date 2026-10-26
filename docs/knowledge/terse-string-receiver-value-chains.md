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
status: bounded Perl/Rust/Dart predicate flow checked; Julia/Lua/full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, string, rust-parity, mdbook]
evidence: "String2.3.5.3 historical detail/commands at Gite19f3ce83543d8befff3abc381d85a6b6285da15 for this path; Length23.3.3 and predicate23.2.9 public native/fresh distinctions."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/string_predicate_result_receiver_contract.t t/emptiness_result_receiver_contract.t"
---

String chains compose trim/case/replace/substr/cat and split-to-Array helpers; Length23.3.3 feeds scalar/number methods. Current bare bindings/cat supersede historical scalar()/concat. Original details and historical next2.3.5.4/block2.3.5.5 ownership remain at the Git pointer above.

TYPE23.2.9 public native/fresh producer/boundary/SOC controls work, but fluent predicates stopped at null because MethodLowering labeled them terminal. Perl23.3.10.1 now uses scalar_result/one-operand preflight for starts_with/ends_with/contains_substr/matches. Native/fresh result/direct emptiness tests pass after RED with source families, false retention/generic predicates/bridges/scalar nulls, eight malformed no-effect controls and SOC/SC snapshots; bodies/kinds/regex/domain/source/copy unchanged.

Rust23.3.10.2 adds scalar/preflight lists and repairs dropped action-literal suffix flags in Core parse_regex. Native/restored/plan result/flag/split/filter, direct boundary and focused Core regex checks pass after null/SO/S/12-effect and suffix-flag RED. Preserve numeric substring/Boolean matches, existing pattern-string schema and domains. Rebuild old derived artifacts from source; details: [[action-regex-operands-and-runtime-kinds]]. Dart23.3.10.3 adds scalar/preflight guards, rejects null text operands and retains literal i/m/s modes. Shared/direct emptiness and native/restored/plan mode/split/filter checks pass; actual kinds and SOC/SC snapshots remain correct. Julia4/Lua5, grouped Dart regex23.3.10.6/full admission and Perl registration23.4.1 remain open.
