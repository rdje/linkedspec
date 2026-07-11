---
id: non-codegen-capability-parity-closed
title: "All current non-codegen capabilities pass across Perl Rust Dart and Julia"
answers:
  - "is non-codegen capability parity closed"
  - "what capability gaps remain after FUTURE-PARITY-BACKLOG.1.6"
  - "are any trace diagnostics resolution CLI or language gaps still open"
  - "which three backend capability states remain non-pass"
  - "what does FUTURE-PARITY-BACKLOG.1.6.6 close"
  - "why is complete backend parity not claimed yet"
date: 2026-07-11
status: current
tags: [parity, capability, codegen, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "capability_conformance/manifest.json; tools/check_capability_conformance.pl; docs/tasks/FUTURE-PARITY-BACKLOG.md"
reverify: "perl tools/check_capability_conformance.pl"
---

`FUTURE-PARITY-BACKLOG.1.6.6` closes current non-codegen capability parity across
Perl, Rust, Dart, and Julia. The strict 15-capability/60-state census remains 57 pass,
one partial, and two gaps, with no missing evidence path or unowned residual.

Direct projection shows that all three non-pass states belong to exactly one capability:
`codegen.generated_parser_source`. Rust is `partial` because all structural families run
directly but manifest-backed generated-source proof is curated. Dart and Julia are `gap`
because they do not yet emit parser source. All three states are owned by active
`FUTURE-PARITY-BACKLOG.3`.

Therefore the current language/helper/runtime, descriptors, diagnostics, native resolution,
trace, execution controls, CLI, and corpus capabilities pass across all four implemented
variants. Complete backend parity is not yet claimed because generated source remains a
user-observable capability, and Lua is a later backend implementation.

Related facts: [[backend-capability-census]], [[dart-native-full-pipeline-trace]],
[[dart-generated-source-deferred]], [[julia-generated-source-deferred]],
[[rust-parity-followon-closed]].
