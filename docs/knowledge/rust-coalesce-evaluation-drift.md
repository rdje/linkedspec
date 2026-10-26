---
id: rust-coalesce-evaluation-drift
title: "Lazy defaults and selected result kinds"
answers:
  - "is there a defined-only coalesce fallback receiver method"
  - "does empty text or false skip a coalesce receiver fallback"
  - "can coalesce_nonempty Array or Hash results continue by actual kind"
  - "why does a valid coalesce_nonempty Hash literal emit hash_literal_use_colon"
  - "why does coalesce_nonempty make numeric array indices fail on Perl"
  - "does Perl coalesce_nonempty return undef when all operands are empty"
  - "does Rust coalesce preserve a defined empty string"
  - "does Rust coalesce short circuit operand evaluation"
  - "does coalesce_nonempty skip later assignment effects"
  - "what does the coalesce_short_circuits native test actually assert"
  - "why do Perl and Rust coalesce disagree on empty aggregates"
  - "why does a Hash default sorted_values first uppercase return null"
  - "how do Array successors consume emitted default guard expressions"
date: 2026-10-26
status: bounded defaults checked; Perl Hash projection successors repaired
tags: [rust, perl, helpers, defaults, projection, evaluation, startup-reading]
evidence: "Defaults62.1/62.2/TYPE23.3.6; TYPE23.3.16.1 public Get/substitution/dump/native/fresh default_hash_projection regression."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test default_selected_receivers --test joined_string_receivers --test coalesce_receiver_values"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/default_hash_projection_contract.t t/default_selected_receiver_contract.t t/default_literal_operand_contract.t"
---

Rust62.1/62.2 evaluates only needed operands with actual selected kinds;
coalesce retains defined empty text. Perl validates operands, compares a scalar
copy to preserve numeric kinds, and returns undef after nonempty exhaustion.
TYPE23.3.6 binds default results once and guards container consumers by actual
kind. Typed complete operands avoid reparsing emitted fat arrows; authored
retired Hash syntax still rejects. Broader62.3/.62.4/domain admission stays open.
[[action-regex-operands-and-runtime-kinds]] retains shared value boundaries.

TYPE23.3.16.1 exposes a pre-existing Hash default->sorted_values->first->uppercase
bug: numeric-root, canonical-call-root and direct undef default all return null/
unsupported-helper:first, while nested equivalent returns A. WHY: MethodLowering
append_array_chain_call builds DSL calls over emitted default-guard do code;
later typed lowering reparses that host expression. Finish Array calls through
the existing compatibility bridge when source is do, preserving dedicated
sorted/reversed and authored syntax checks. Native/fresh projection controls now
cover first/last/count/join/contains/index, sum/transform/reverse/take, multiple
root families, numeric index kinds and SDC/once-only/source snapshots. Arithmetic,
selected/literal default direct checks pass too; full admission remains separate.

Historical September7 mismatches were eager Rust coalesce evaluation, skipped
defined empty text, and aggregate observations beyond the scalar signature.
Historical controls distinguished empty-text/aggregate fallback behavior;
current bounded repair does not publish a universal aggregate-domain policy.
Full historical bodies/results, named-test/observer qualifications and exact
capture manifests/producer pointers are preserved in this file at Git
846a39094d1f0f1972169fc089098df43aad47d2. They are not current replay instructions;
use focused reverify above. Current original repair ownership is
SESSION-STARTUP-READING62, with selected-result scope TYPE23.3.6 and the direct
projection follow-up16.1. Compatibility observations do not close broader
signature/context/portable admission.

TYPE23.2.18 freezes a separate one-or-more-fallback ordinary coalesce receiver;
old23.2.5 explicitly excluded it. defined-default-results.md and retained public
probe record native/fresh free/nested defined empty/zero/false, actual containers,
numeric selector writes, independent copies and SDC snapshots/skipped runtime
errors. Receiver AST exists but lacks MethodLowering return-family admission,
leaving raw host DSL. Free Perl coalesce(one) returnsnull; no identity receiver
is inferred. Implement18.1-.5 independently; no free-signature or portable
aggregate-domain promotion. Empty containers remain defined selected values.
