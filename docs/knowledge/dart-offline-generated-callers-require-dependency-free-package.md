---
id: dart-offline-generated-callers-require-dependency-free-package
title: Dart generated callers require a dependency-free production package in fresh offline caches
answers:
  - "why does Dart semantic SHA-256 not use the crypto package"
  - "why must the Dart production package remain dependency-free"
  - "why did a Dart generated caller fail pub get after semantic source mapping"
  - "how is the Dart semantic source digest computed"
date: 2026-07-27
status: current
tags: [dart, semantic-introspection, generated-source, offline, dependencies, sha256]
evidence: dart/lib/src/semantic/sha256.dart; dart/lib/src/semantic/semantic_index.dart; dart/test/semantic_index_source_foundation_test.dart; dart/test/source_emitter_test.dart; dart/test/unicode_rule_label_identity_routes_test.dart; dart/pubspec.yaml; FUTURE-PARITY-BACKLOG.10.5.1.1
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/semantic_index_source_foundation_test[.]dart test/source_emitter_test[.]dart test/unicode_rule_label_identity_routes_test.dart && cd .. && ! rg -n '^dependencies:' dart/pubspec.yaml"
---

Dart's generated-source and Unicode-label identity suites create isolated caller packages, point each caller at
the checkout through a path dependency, set `PUB_CACHE` to a fresh empty directory, and run the targeted Dart
wrapper's offline package resolution.
That proves an emitted caller can consume the shipped production package without relying on the developer's global
cache. A new direct `crypto` dependency made all four isolated caller roles fail resolution even though the main
checkout already had `crypto` transitively through test tooling.

Semantic source foundation `.10.5.1.1` therefore keeps `dart/pubspec.yaml` free of production dependencies and
implements SHA-256 in the package-internal `dart/lib/src/semantic/sha256.dart`. The digest is locked by the standard
empty and `abc` vectors plus the 128-byte neutral graph fixture, whose expected identity is independently recorded
by the semantic contract. The complete isolated source-emitter and Unicode-label caller routes pass again with a
fresh offline cache.

This is a packaging invariant, not an argument against all future Dart dependencies. Any proposed production
dependency must first preserve the fresh-cache offline caller contract, for example by explicitly provisioning an
approved cache or by revising that contract in an owned task. Silent reliance on a warm developer cache is not
acceptable evidence.

Related facts: [[dart-generated-source-v2-rule-local-cursor]],
[[dart-semantic-introspection-authority-map]], and [[semantic-introspection-neutral-contract]].

## 2026-09-10 — complete package-internal digest reading

`DART-STARTUP-READING.1.33` reads all 162 SHA-256 lines. Padding retains a
big-endian bit count; each block expands 16 words to 64, performs masked 32-bit
rounds and emits eight fixed-width lowercase hexadecimal words. The selected
28 semantic tests include the existing empty/abc and neutral graph source
identity controls. Production dependencies remain unchanged; no fresh offline
emitted-caller run is claimed by this reading slice.
