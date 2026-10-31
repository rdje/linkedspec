---
id: copied-null-presence-composition
title: Copied-null presence composition has an owned Dart mismatch
answers:
  - "why does Dart null copy has_key skip its key"
  - "are fluent and free copied-null presence calls equivalent"
  - "which task owns copied-null has_key composition"
date: 2026-10-31
status: owned P1 assessment and repair69.6 after69.5 before next selection and23.4
tags: [dart, copy, null, presence, composition]
evidence: "Read-only Julia69.4 investigation; presence-copy-null-composition source/command/raw channels/exit and identity record plus producer/qualifier retained in presence-guard-julia-intake.json.gz. Unchanged committed Dart source is in presence-guard-dart-intake.json.gz."
reverify: "Recover presence-copy-null-composition_test.dart into a new project-local path; from dart run tools/run_dart_project_data.sh test with JSON reporter. Historical writer is one-shot."
---

At committed Dart e5140ad93, one public native/restoredSpec/plan probe returns
`[null,0,0,null,"BC"]` instead of `[0,0,0,null,"ABC"]`: `{undef}.copy().has_key(key)`
skips its key while `copy({undef}).has_key(key)` and `has_key(copy({undef}),key)`
evaluate theirs. A rejected `.take(1).has_key(key)` control correctly skips D.
The test actually exits1, with exact declared source/probe/runner/package-config
identities before/after and empty stderr. Approved ADR0138 scalar/null copy plus
nullable has_key/source-key authority supplies the distinguishing oracle.
Own P1 TYPE-REFERENCE-BOOK.1.2.23.3.69.6 after69.5 and before the next method
selection/full23.4; locate dispatch through public AST/runtime tools and assess
other backends independently. Preserve rejection state and existing key domains;
no general nullable Hash-consumer policy or peer defect is established here.
