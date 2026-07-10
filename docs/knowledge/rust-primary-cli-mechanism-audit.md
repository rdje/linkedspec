---
id: rust-primary-cli-mechanism-audit
title: Rust primary CLI work is split across adapter and native execution seams
answers:
  - what Rust APIs can a primary LinkedSpec CLI reuse
  - why does Rust need a native top rule execution option
  - why does Rust need a global parse mode execution option
  - does Rust already have a LinkedSpec CLI binary
  - how is FUTURE-PARITY-BACKLOG 1.5.2 split
date: 2026-07-10
status: current
tags: [rust, cli, parser, runtime, utf8, trace, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.2.0 audits the two-crate workspace and splits .1-.4 before code."
reverify: "sed -n '1,120p' rust/Cargo.toml; find rust -type f -path '*/src/bin/*' -print; rg -n 'parse_spec_with_user_functions|pub fn compile|pub fn validate|pub fn execute|top_rule\\(|parse_mode' rust/linkedspec-core/src rust/linkedspec-runtime/src"
---

The Rust workspace contains `linkedspec-core` and `linkedspec-runtime`, but no binary target. The libraries already
own the substantive language pipeline: full-source parsing including staged user-function shells, validation,
compilation, interpreted execution, structured `serde_json::Value` results, generated-plan execution, and rich
backend-native trace controls/events.

Two primary-command controls are not yet available as reusable runtime options. `Engine::execute` always selects
the first compiled rule whose `is_top` flag is true, and matching reads each `CompiledRule.parse_mode`; there is no
optional entry-rule selection or global parse-mode override. Those controls belong in an idiomatic native execution
seam so the CLI remains a thin adapter and host applications can request the same capability without a subprocess.

The remaining work is adapter policy, not language semantics: exact manual option parsing/help, deterministic
named/file/inline source and input loading, strict preserved UTF-8, canonical JSON byte rendering, stable phase
failure projection, and ADR `0024` canonical CLI trace. `FUTURE-PARITY-BACKLOG.1.5.2` is split into audit (`.0`),
boundary/loading (`.1`), native execution/results/failures (`.2`), portable trace (`.3`), and full unchanged
61-case closeout (`.4`).

Related facts: [[cross-backend-cli-contract-gap]], [[neutral-cli-fixture-runner]],
[[user-observable-backend-cli-parity-contract]], [[primary-cli-strict-utf8-text-contract]],
[[canonical-primary-cli-trace-protocol]], [[native-in-memory-backend-contract]].
