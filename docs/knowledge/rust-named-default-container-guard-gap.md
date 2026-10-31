---
id: rust-named-default-container-guard-gap
title: Rust completed named default containers lose incompatible-consumer guards
answers:
  - "why does a Rust named Array coalesce set_key evaluate operands"
  - "is the Rust completed named default guard gap part of set source classification"
  - "which task owns Rust named default container result guards"
date: 2026-10-31
status: P2 owned59.6 immediately after59.2 before59.3/admission
tags: [rust, defaults, array, hash, guards, scope]
evidence: "Rust59.2 initial13 baseline9PASS4RED at1cf8949de; actual source/three-route output in set-result-rust-named-default-gap.json, retained by current set-result-rust intake."
reverify: "Recover exact named-gap source/public observer from set-result-rust intake and use offline project Cargo wrapper with new output names; current owner is59.6."
---

saved=set(items,["tail"]); saved.coalesce(undef).set_key(K/V blocks) retains
the Array and evaluates KV on native/restored CompiledSpec/generated-plan.
The original source includes a healthy completed read and returns
["TAIL",["tail"],["tail"],"KV"], expected null consumer and empty order.

Variable-root fluent dispatch calls eval_selected_receiver_value_chain with
scalar_result=false. After coalesce selects an Array that flag remains false,
so incompatible Hash operands run. This is separate from canonical set source
classification and from intentionally preserved unknown unbridged bound-call
missing counts. Existing defined-default actual-kind authority applies. P2 owner
59.6 fixes it immediately after59.2/before Dart59.3 with independent finite
controls and nearest bound-call preservation. Original initial13 normal/source/
output remain; current canonical normal isolates its healthy completed read,
then rebaselines before production. No Perl healthy credit imported into Rust.
