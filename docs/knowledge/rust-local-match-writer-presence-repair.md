---
id: rust-local-match-writer-presence-repair
title: Rust local-match writers require match presence before updating named marks
answers:
  - "why did Rust mark_match_start create a mark before matching"
  - "does a missing Rust local-match writer preserve a mark written by its name expression"
  - "which Rust state flag qualifies local-match mark writers"
  - "must emitted Rust source be regenerated for the local writer repair"
date: 2026-10-29
status: bounded49.2 focused repair verified; independent peers/selection/full admission separate
tags: [rust, marks, writer, match, absence, endpoint, mutation]
evidence: "rust-writer-endpoint-intake.json.gz retains own15-source7healthy8RED ->15pass native/reconstructed/plan/separate emitted,24 normal RED observations and3 selected integration tests."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test named_writer_endpoint_absence --test named_capture_endpoint_absence --test complete_named_mark_contract -- --test-threads=1"
---

engine.rs previously wrote match_start_byte/match_end_byte without checking
match_present, manufacturing positions when no local match existed. Existing
argument evaluation/name resolution/typed mark storage remain; each local writer
now checks existing presence after resolving its name and returns Undef before
the write when absent. No new state or mark/frame architecture is introduced.

## Rust repair49.2 (2026-10-29)

mark_match_start/end now require existing match_present after name resolution;
two guards prevent default numeric registers from fabricating/replacing targets.
Names already evaluate, current typed mark owner/state/frame/schema/domain/arity
remain. Independent15 SDK/reconstructed/plan/separate emitted7healthy8RED ->15pass;
ordinary1 harness24 bad routes ->pass. Writer1/named read-take1/complete marks1
tests pass3; engine/new normal/temp format clean. Seven healthy observations and
all source/parsed/compiled/serde/plan/emitted/public metadata exact. Same15 baseline
modules relink with updated runtime, rebuild apps/no source regeneration. Native/
fresh lock identities match; dependency diagnostics opaque. Temporary producer
exactly verified/snapshotted/removed, normal no allocator. Packet
rust-writer-endpoint-intake.json.gz retains closure. Independent49.3-.5/48/45,
selection23.4.1/full admission remain separate.
