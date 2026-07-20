---
id: explicit-or-action-result-shape-parity-gap
title: "Explicit repeated OR action results are a tracked five-backend parity gap"
answers:
  - "why does Perl Top OR return an array"
  - "does Top double colon OR return the same shape on every backend"
  - "what is the difference between Top OR and Top pipe choice"
  - "which task owns explicit OR action result shape parity"
  - "why did the duplicate regex choice fixture change from OR to pipe"
date: 2026-07-20
status: confirmed gap; pending FUTURE-PARITY-BACKLOG.9.1.10
tags: [or, repetition, action-edge, output-shape, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.8.1.7, the duplicate-choice source Top::OR with two action edges returned [\"first\"] from Perl primary but \"first\" from Rust, Dart, Julia, and Lua primary adapters. Perl return_descriptor classifies ::OR as REP_OR_EXPLICIT / REP_ACODE with execution_shape repeat_loop. dump_parser_source shows _emit_rep_acode_handler rewrites each action return into a rule scalar, pushes that value into @Top_collect, and returns the collection. Top::| instead classifies as OR / OR_ACODE / or_choice_dispatch with uses_loop=false and returns scalar \"first\". Duplicate-slot identity needs genuine single choice, so its neutral fixture uses ::|; FUTURE-PARITY-BACKLOG.9.1.10 owns the broader explicit repeated-OR result decision and any migration."
reverify: "perl -Iperl bin/linkedspec --inline-spec 'Top::OR\n /a/ -> Top[0] { return(\"first\") }\n /b/ -> Top[1] { return(\"second\") }\n' --input a && perl -Iperl bin/linkedspec --inline-spec 'Top::|\n /a/ -> Top[0] { return(\"first\") }\n /b/ -> Top[1] { return(\"second\") }\n' --input a"
---

`Rule::OR` and `Rule::|` are not interchangeable in the Perl reference.
Explicit `OR` is a repeated choice family and collects one action value per
accepted hit. Pipe is a non-repeating single-choice family and returns the
selected action value directly.

Four newer backends currently collapse the explicit-OR example to the direct
scalar value. That is broader than duplicate regex-slot identity: distinct
patterns reproduce the same result-shape split. The duplicate-slot contract
therefore uses `::|` for its choice-priority fixture and leaves explicit-OR
collection semantics untouched until the dedicated task audits and decides the
portable rule.

Related: [[duplicate-regex-slot-identity-contract]],
[[blind-call-collection-shape]], [[handler-ir-design]], and
[[FUTURE-PARITY-BACKLOG]].
