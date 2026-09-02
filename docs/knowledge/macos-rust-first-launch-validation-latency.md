---
id: macos-rust-first-launch-validation-latency
title: "A cold repository-local Rust test launch stalled in macOS validation before main"
answers:
  - "why did the Rust trace controls build take 55 minutes"
  - "was trace_controls looping after the cold build"
  - "why was the Rust test binary stuck at dyld_start"
  - "what task owns macOS syspolicyd Rust launch latency"
  - "is macOS first launch validation latency tracked"
date: 2026-09-01
status: observed and queued for audit under FUTURE-PARITY-BACKLOG.19.3.4
tags: [rust, macos, syspolicyd, gatekeeper, verification, performance, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.19.3.3 signoff, a plain-cargo test with repository-local target but user-home registry reads finished its cold build in 55m44s after prolonged per-crate waits. More than three minutes after Cargo launched trace_controls, it had 112 KiB footprint and no test output. Process census found Cargo/test alive and macOS syspolicyd consuming substantial CPU; a one-second sample contained only _dyld_start, proving Rust test code had not begun. The exact /tmp report created by sample was consumed, deleted, and verified absent. The eventual 12/12 result is diagnostic only until rerun through LinkedSpec's managed Cargo wrapper."
evidence_update_managed_2026_09_01: "The repository-managed root-selection driver then required 117m57s for its Rust admission test build before the binary ran 1/1 in 10.33s. A later exact managed trace command rebuilt in 2m07s, remained silent for about 98 seconds after launching the test binary, and then passed 12/12 in 2.23s. All project data for those accepted runs was routed by tools/project_data_env.sh. The large cold/warm and pre-test/execution split remains an audit input for .19.3.4.0, not a causal conclusion or permission to weaken trust checks."
evidence_update_canonical_2026_09_02: "During the successful receipt-bound canonical run, a read-only census found an independent Claude-owned shell deleting this checkout's rust/target/debug/incremental, rust/target/es19_boot, rust/target/audit_notest, and rust/target/coldprobe directories and invoking cargo sweep --time 7. No tracked file changed, but this is direct concurrent invalidation of repository-local Rust artifacts. Separately, mcp_server_rust_dispatch stayed at 112 KiB in macOS _dyld_start for more than five minutes and then passed 3/3 in 2.43s. The exact /tmp sample report was consumed, deleted, and verified absent. Controlled serial reproduction must separate this interference from OS validation latency."
reverify: "rg -n 'Rust launch-latency finding|FUTURE-PARITY-BACKLOG.19.3.4' docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md ROADMAP.md ROADMAP_V2.md docs/TASK_TREE.md"
---

This is a dated observation from the current macOS host and a noncanonical plain-Cargo route, not yet a universal
causal claim or an accepted same-volume signoff result. It rules out the new
root-target-regex trace fixture as the source of the initial silence because the test process had not passed the
dynamic loader entry point. It also separates compilation and first-launch latency from ordinary Rust test time.
The later canonical census additionally proves that at least one run was contaminated by concurrent deletion of
repository-local Rust artifacts, so no cold-versus-warm conclusion from that run may be treated as controlled.

`FUTURE-PARITY-BACKLOG.19.3.4.0` must reproduce the boundary under controlled clean/warm runs and inspect exact
process, executable-metadata, storage, and concurrency evidence. Only then may `.19.3.4.1` select a project-local
repair. Global Gatekeeper/trust changes, ambiguous shared-metadata deletion, off-volume project data, and weaker
test coverage are prohibited.

Related: [[project-data-storage-enforcement]], [[top-rule-is-ordinary-rule-entered-first]].
