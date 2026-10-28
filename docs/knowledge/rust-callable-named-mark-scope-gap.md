---
id: rust-callable-named-mark-scope-gap
title: Rust callable bodies preserve the invoking rule mark namespace after43.1
answers:
  - "why does Rust mark_pos use coalesce fallback inside a literal callback"
  - "can equal Rust callback names share marks across different rules"
  - "which task fixes Rust callable named-mark caller context"
date: 2026-10-28
status: repaired43.1 focused checks pass; full context admission23.4 separate
tags: [rust, callbacks, marks, scope, dynamic-caller, diagnostics]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.34.2 retains28-source intake, two distinguishing public scope controls and owned regressions in named-mark-number-rust-intake.json.gz."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test named_mark_number_results -- --test-threads=1 --nocapture"
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

43.0 freezes rust-callable-rule-label.md from ADR0031 and the exact named mark
scope policy. All five call sites already forward rule_label to the shared owner;
the repair needs no new parameter. Keep name-based diagnostics/recursion, cleanup
and function fences, while evaluating in the caller's rule bucket. Construction
captures no namespace. Production43.1 owns enabled oracles and helper/tree/nested
controls before34.3; no full admission is implied by authority freeze.

## Repair43.1 supersedes the observed gap

execute_codeblock_value now passes its existing caller rule_label to body
evaluation, keeping callback identity in the error wrapper and cycle machinery.
All three original oracles are enabled and pass. Seven helper/contextual/explicit/
Hash-tree/Array-tree/nested source controls and a returned callback observing Top's
call-time0 then6 go RED/GREEN. Original scope expectations were not rebased.
Nearest callable, mark, snapshot and function checks plus the cleanup unit pass;
bound/helper errors retain callback prefixes with semantic Top diagnostics and
restore parameters/active identity. Source/output epochs and exact summaries live
in rust-callable-rule-label-intake.json.gz. No new helper rights, lexical capture,
global bucket, invocation-frame migration or independent emitted-package claim.
