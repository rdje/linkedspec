---
id: rust-canonical-primary-cli-trace
title: Rust projects the canonical primary CLI trace independently of its rich native trace API
answers:
  - does linkedspec-rust emit the canonical CLI trace
  - how does Rust keep primary CLI trace separate from native trace
  - which Rust primary CLI trace sinks are supported
  - does Rust primary CLI trace count UTF-8 bytes
  - does Rust primary CLI trace escape user fields
  - how many shared CLI cases does Rust pass after trace implementation
  - what did FUTURE-PARITY-BACKLOG 1.5.2.3 implement
date: 2026-07-10
status: current
tags: [rust, cli, trace, utf8, parity, ADR-0024, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.2.3 adds CanonicalTrace in primary_cli.rs and passes all 61 unchanged CLI fixtures."
reverify: "bash tools/run_rust_local.sh"
---

`linkedspec_runtime::primary_cli` owns a small `CanonicalTrace` adapter implementing ADR `0024`. It emits only
portable compile/input/invoke records and does not call or reduce the rich `linkedspec_core::trace` API used by
native embedding. Backend-internal scopes, source locations, and runtime decisions therefore cannot leak into
the primary command contract.

The adapter implements named and numeric thresholds, source/input/top-rule/mode metadata, UTF-8 argument and
loaded-input byte counts, canonical JSON byte length, uppercase bytewise percent escaping, exact emoji, and
stdout/route/mirror sinks. A selected file implies route unless a mode is explicit. Reset truncates even at
none/quiet; otherwise files persist or append. Trace setup/write failures map to the stable compilation failure,
and compile/input/invoke failures emit only their portable phase outcome.

With `.1.5.2.2`'s direct execution layer beneath it, the built `linkedspec-rust` command passes all 61 unchanged
neutral fixtures. `.1.5.2.4` closes the milestone in default/POSIX environments and adds recurring
`tools/run_rust_local.sh` verification.

Related facts: [[canonical-primary-cli-trace-protocol]], [[rust-primary-cli-mechanism-audit]],
[[rust-native-direct-value-execution]], [[rust-trace-controls-sinks]],
[[user-observable-backend-cli-parity-contract]], [[rust-local-verification-gate]].
