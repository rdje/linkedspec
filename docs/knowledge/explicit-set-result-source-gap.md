---
id: explicit-set-result-source-gap
title: Canonical set stored results need guarded direct read and fluent source roles
answers:
  - "why do direct set Array or Hash result reads fail to compile in Perl"
  - "why does set Array set_key raise Not a HASH reference"
  - "does canonical set already return the assigned typed value"
  - "does set result composition add a new copy or alias guarantee"
date: 2026-10-31
status: bounded Perl59.1 repaired/targeted-checked; independent peers/full admission pending
tags: [perl, set, assignment, fluent, selection, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.20; set-result-selection-intake.json.gz retains actual15 public source programs/native-fresh metadata/substitutions/emitted modules and unchanged Perl source custody."
reverify: "Recover finite assignment-result-assessment authored cases/observer from set-result-selection-intake.json.gz with project-local output and use public Perl wrapper. Historical activate/create/probe-target/finish/retain are one-shot, never replay."
---

At8f50c1c1f primitive String/Array/Hash assignment values and compatible String/
Array/scalar/default/with methods work. Direct Array/Hash result reads and
source-before-selector ordering emit unboxed assignment followed by brackets,
handler/fresh source compile-fails. Direct Array-to-Hash set_key is raw0/ready1
but native handler-eval/fresh generated_execution_failed: Not a HASH reference.
Canonical set is missing from MethodLowering computed data-call classification
and emitted_result_chain. Existing assignment value ABI is healthy; materialize
it as the source of current guarded reads/selected/default-result dispatch.

Fifteen finite programs: initial12 eight healthy/four failing, followed by full
direct/completed-bound twin and bound guard. Completed-bound full12 succeeds
native/fresh; direct raw5/unready/compile-fails, bound guard null/skips KV.
Perl59.1 owns P1 read/runtime repair next; peers independent. Preserve ordinary
assignment alias/copy semantics, no new updated-copy guarantee, operator/alias/
grouping/target/arity/deferred/context/schema rights. Full admission separate.

Bounded repair and preservation evidence: [[perl-canonical-set-result-composition]]. Historical selection observations above remain the original activation boundary; current status belongs to set-result-composition.md.

Independent bounded Rust59.2: [[rust-canonical-set-result-guards]]. Separately exposed P2 completed named-default guard is owned59.6 immediately next; current family status belongs to set-result-composition.md.
