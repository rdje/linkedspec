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
status: classified as external per-artifact macOS policy state; no repository repair required
tags: [rust, macos, syspolicyd, gatekeeper, verification, performance, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.19.3.3 signoff, a plain-cargo test with repository-local target but user-home registry reads finished its cold build in 55m44s after prolonged per-crate waits. More than three minutes after Cargo launched trace_controls, it had 112 KiB footprint and no test output. Process census found Cargo/test alive and macOS syspolicyd consuming substantial CPU; a one-second sample contained only _dyld_start, proving Rust test code had not begun. The exact /tmp report created by sample was consumed, deleted, and verified absent. The eventual 12/12 result is diagnostic only until rerun through LinkedSpec's managed Cargo wrapper."
evidence_update_managed_2026_09_01: "The repository-managed root-selection driver then required 117m57s for its Rust admission test build before the binary ran 1/1 in 10.33s. A later exact managed trace command rebuilt in 2m07s, remained silent for about 98 seconds after launching the test binary, and then passed 12/12 in 2.23s. All project data for those accepted runs was routed by tools/project_data_env.sh. The large cold/warm and pre-test/execution split remains an audit input for .19.3.4.0, not a causal conclusion or permission to weaken trust checks."
evidence_update_canonical_2026_09_02: "During the successful receipt-bound canonical run, a read-only census found an independent Claude-owned shell deleting this checkout's rust/target/debug/incremental, rust/target/es19_boot, rust/target/audit_notest, and rust/target/coldprobe directories and invoking cargo sweep --time 7. No tracked file changed, but this is direct concurrent invalidation of repository-local Rust artifacts. Separately, mcp_server_rust_dispatch stayed at 112 KiB in macOS _dyld_start for more than five minutes and then passed 3/3 in 2.43s. The exact /tmp sample report was consumed, deleted, and verified absent. Controlled serial reproduction must separate this interference from OS validation latency."
evidence_update_closeout_2026_09_02: "Controlled managed runs reproduced two older distinct trace_controls hashes at 45.32/0.00 and 51.75/0.00 seconds for first/warm --list launches, with zero user/system CPU, no visible Rust process, and syspolicyd at 51.1-57.8% CPU. Both binaries were provenance-tagged, ad-hoc linker-signed, and slowly rejected by spctl. Ordinary managed-run files also inherit provenance. However two fresh behavior-equivalent unique isolated builds completed in 37.18 and 23.17 seconds. The first hash's explicitly signed copy and original launched in 0.44/0.45 seconds; the second wholly unmanipulated provenance-tagged linker-signed hash first-launched in 0.41 seconds, then 0.00 warm. Fresh serial compile/link/launch is therefore healthy. The delay is external per-artifact macOS policy/cache state for older contaminated artifacts, not a persistent Linkedspec source/build/storage/signing defect. No trust, xattr, cache, coverage, or workflow repair is justified; FUTURE-PARITY-BACKLOG.19.3.4.1 is not required."
reverify: "rg -n 'Rust launch-latency finding|FUTURE-PARITY-BACKLOG.19.3.4' docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md ROADMAP.md ROADMAP_V2.md docs/TASK_TREE.md"
---

The controlled closeout is specific to macOS 26.5.2 build 25F84 / Darwin 25.5.0. It separates dependency build,
link, policy/loader wait, and test execution without deleting an existing target. The two delayed older hashes and
their instant warm twins prove a per-artifact first-use policy cache; a second wholly unmanipulated unique fresh
control proves that provenance, ad-hoc linker signing, executable size, SSD execution, and high `syspolicyd` CPU
are not sufficient to reproduce the delay. The original canonical run remains invalid as a cold/warm comparison
because independent target deletion and `cargo sweep` occurred concurrently.

The correct operational response is to preserve exact tests and project-local storage, avoid competing artifact
cleanup, and classify a silent binary with process/loader evidence before assuming a runtime loop. Do not disable
Gatekeeper, clear shared or original provenance metadata, re-sign production test artifacts, add speculative
prelaunch work, or move caches off-volume. `.19.3.4.1` is closed not-required unless new controlled evidence
contradicts the fresh unique controls.

Related: [[project-data-storage-enforcement]], [[top-rule-is-ordinary-rule-entered-first]].
