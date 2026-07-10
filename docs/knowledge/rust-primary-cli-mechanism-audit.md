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
evidence: "FUTURE-PARITY-BACKLOG.1.5.2.0 audits/splits the workspace. .1 lands the command boundary at 29/61; .2 is active for native controls/direct result."
reverify: "sed -n '1,120p' rust/Cargo.toml; find rust -type f -path '*/src/bin/*' -print; rg -n 'parse_spec_with_user_functions|pub fn compile|pub fn validate|pub fn execute|top_rule\\(|parse_mode' rust/linkedspec-core/src rust/linkedspec-runtime/src"
---

At the `.1.5.2.0` audit, the Rust workspace contained `linkedspec-core` and `linkedspec-runtime` but no binary
target. The libraries already owned the substantive language pipeline: full-source parsing including staged user-function shells, validation,
compilation, interpreted execution, structured `serde_json::Value` results, generated-plan execution, and rich
backend-native trace controls/events.

Two primary-command controls remain unavailable as reusable runtime options. `Engine::execute` always selects
the first compiled rule whose `is_top` flag is true, and matching reads each `CompiledRule.parse_mode`; there is no
optional entry-rule selection or global parse-mode override. Those controls belong in an idiomatic native execution
seam so the CLI remains a thin adapter and host applications can request the same capability without a subprocess.

The initially remaining work was adapter policy, not language semantics: exact manual option parsing/help, deterministic
named/file/inline source and input loading, strict preserved UTF-8, canonical JSON byte rendering, stable phase
failure projection, and ADR `0024` canonical CLI trace. `FUTURE-PARITY-BACKLOG.1.5.2` is split into audit (`.0`),
boundary/loading (`.1`), native execution/results/failures (`.2`), portable trace (`.3`), and full unchanged
61-case closeout (`.4`).

`.1.5.2.1` now provides `linkedspec_runtime::primary_cli` and `linkedspec-rust`. Its exact manual parser, shared
help template, current-directory plus repository `specs/` resolution, deferred input loading, and strict UTF-8
file decoding pass all 22 help/usage cases, all three invalid-UTF-8 phase cases, and all four operational failures:
29/61 total. The 32 residuals are mechanically isolated: 11 successful direct-value cases expose the already
documented `Engine::execute == [reference]` accumulator wrapper, and 21 cases require ADR `0024` canonical trace.
`.1.5.2.2` owns a reusable native direct-result/entry/mode seam; `.3` owns trace. This is not a parser-language gap.

Related facts: [[cross-backend-cli-contract-gap]], [[neutral-cli-fixture-runner]],
[[user-observable-backend-cli-parity-contract]], [[primary-cli-strict-utf8-text-contract]],
[[canonical-primary-cli-trace-protocol]], [[native-in-memory-backend-contract]].
