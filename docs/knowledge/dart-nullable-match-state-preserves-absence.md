---
id: dart-nullable-match-state-preserves-absence
title: "Dart projects absent local matches from nullable match state"
answers:
  - "how does Dart distinguish no local match from a zero width match at offset zero"
  - "what do Dart match position helpers return without a local match"
  - "why do Dart match line and column helpers return one without a local match"
  - "why are Dart entry_has and match_has numeric one or zero"
date: 2026-07-10
status: confirmed
tags: [dart, runtime, match-state, positions, zero-width, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.2. Dart stores entry/local match registers as nullable RuntimeRegexMatch objects, so absence is already distinct from a present zero-width match at offset zero. Helper projection now maps absence to null capture/length/start/end values, empty group/map containers, numeric match_has=0, and 1-based line/column defaults. Entry/local named-presence helpers return numeric 1/0. A zero-width regression proves a present match at offset zero still returns empty capture text, length/start/end 0, and match_has=1. The governed exact position fixture, all 154 package tests, both 61-case CLI environments, and unchanged 99-case corpus pass."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart -n 'executes the governed empty-local-match position capability values|keeps a zero-width match at offset zero present'"
---

# Dart Match Absence Uses Nullability

The match object answers whether a match exists; its offsets answer where a present match exists. Dart therefore
keeps `RuntimeRegexMatch?` as the state boundary and projects each helper result according to the LinkedSpec
contract. Code must not infer match presence from a zero span or empty captures.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.2.2`.
- Governed source: `capability_conformance/fixtures/capability_position_helper_surface.spec`.
