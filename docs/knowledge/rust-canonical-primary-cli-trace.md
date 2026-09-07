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
date: 2026-09-07
status: current
tags: [rust, cli, trace, utf8, parity, ADR-0024, FUTURE-PARITY-BACKLOG]
evidence: "Historical July 10 FUTURE-PARITY-BACKLOG.1.5.2.3 adds CanonicalTrace in primary_cli.rs and passes the then-current 61 CLI fixtures. September 7 reading .3.3.10 distinguishes its phase-success protocol from the rich core trace API and from correct numeric result conversion; it does not rerun the full CLI matrix."
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

With `.1.5.2.2`'s direct execution layer beneath it, the July milestone passed its then-current 61
neutral fixtures. `.1.5.2.4` closes the milestone in default/POSIX environments and adds recurring
`tools/run_rust_local.sh` verification.

The later startup canonical checkpoint `.3.2.55` records the current 66-case
default/POSIX matrix; the old 61 count is not a current inventory. September 7
`.3.3.10` separately observes successful compile/invoke phases while a large numeric
result is saturated during conversion: [[rust-large-number-conversion-defect]].
Phase success is not proof of exact result-value preservation.

Related facts: [[canonical-primary-cli-trace-protocol]], [[rust-primary-cli-mechanism-audit]],
[[rust-native-direct-value-execution]], [[rust-trace-controls-sinks]],
[[user-observable-backend-cli-parity-contract]], [[rust-local-verification-gate]].

## September 7 primary adapter prefix reading

`SESSION-STARTUP-READING.3.3.26` reads `primary_cli.rs` lines 1–168. Its
`CommandOutput` keeps stdout/stderr bytes and exit status separate (success 0, operational
failure 1, usage 2 with help). `CanonicalTrace` keeps selected file/mode/level/emoji and a
stdout buffer. A nonempty selected file implies route; explicit stdout/route/mirror overrides
that default. Reset creates/truncates the selected file during setup, before event thresholds;
emission appends and flushes only for route/mirror and separately accumulates stdout/mirror.
This prefix confirms sink ownership and byte framing; option parsing, phase event sequencing
and remaining primary-command source belong to the next reading leaf. It does not rerun
primary CLI conformance or broaden the older 66-case proof.
