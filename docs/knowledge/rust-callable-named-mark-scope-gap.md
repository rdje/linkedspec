---
id: rust-callable-named-mark-scope-gap
title: Rust callable diagnostic labels become mark buckets and leak state across rules
answers:
  - "why does Rust mark_pos use coalesce fallback inside a literal callback"
  - "can equal Rust callback names share marks across different rules"
  - "which task fixes Rust callable named-mark caller context"
date: 2026-10-28
status: P1 owner43 immediately after34.2 before34.3/full23.4/push; root confirmed
tags: [rust, callbacks, marks, scope, dynamic-caller, diagnostics]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.34.2 retains28-source intake, two distinguishing public scope controls and owned regressions in named-mark-number-rust-intake.json.gz."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test named_mark_number_results -- --ignored --test-threads=1 --nocapture"
---

Ordinary seven named Number sources work, but a literal cb reads seven0! defaults
instead of caller Value begin0/finish6 values. A callback write/read control returns
[[[6,null],null,6]]: its own inside write is visible only inside cb, caller finish
is hidden there and inside is absent afterward. Different First/Second rules
each bind cb; a mark written in First's callback appears in Second's callback,
yielding[[1,null],[1,null]] while both direct rule buckets lack it. This falsifies
both ordinary missing-mark and intended rule-local isolation explanations.

Engine::execute_codeblock_value creates diagnostic codeblock_label and
passes it to eval_block_value as rule_label. Named helper branches call typed_mark_
offset/byte with that parameter. The key therefore becomes codeblock 'cb', not the
invocation rule. Named scope is accidentally shared by diagnostic callback name;
no declared rule has that label. Native/restored CompiledSpec/plan agree.

43.0 freezes caller semantic label versus diagnostic identity authority, then43.1
repairs every supported Rust invocation path and enables the three exact owned
regressions. Preserve dynamic stores, parameter copy/restoration, parser-state
function fences, cycles, names and errors; no lexical closure/global bucket or
schema grant. Existing rule-label lifetime and future same-label invocation-frame
migration14.3 stay distinct. Do not count the current0! callback as healthy Number
composition. Other backend scopes are independently assessed by their34 peers.
