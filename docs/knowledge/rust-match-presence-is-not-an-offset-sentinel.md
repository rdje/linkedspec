---
id: rust-match-presence-is-not-an-offset-sentinel
title: "Rust match presence must not be inferred from zero offsets"
answers:
  - "how does Rust distinguish an absent local match from a zero width match at offset zero"
  - "why did Rust position helpers return zero or empty string instead of null"
  - "what do match_len match_start_pos and match_end_pos return without a local match"
  - "why are entry_has and match_has numeric one or zero"
date: 2026-09-07
status: confirmed
tags: [rust, runtime, match-state, positions, zero-width, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.1. RuntimeContext previously represented both an absent local match and a present zero-width match at input offset zero as empty capture maps plus match_start_byte=match_end_byte=0. The governed position fixture therefore serialized match_group as an empty string and match_len/start/end as zero instead of Perl's null values. Explicit entry_match_present and match_present bits now travel through SavedMatchState and every direct/general rule path. An absent local match returns null text/group/length/start/end positions, empty group/map containers, numeric match_has=0, and 1-based line/column defaults; entry_has is numeric 1 for the fixture entry. A separate zero-width regression proves a real match at offset zero still returns empty capture text, length/start/end 0, and match_has=1. The exact governed fixture, 137 library tests, 193 integration tests, and the unchanged 99-case oracle pass."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test future_parity_backlog_1_6_1_2_2_2_1_rust_position_capability_values -- --exact && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test future_parity_backlog_1_6_1_2_2_2_1_zero_width_match_is_present -- --exact"
---

# Rust Match Presence Is Explicit State

Offsets describe where a match occurred; they cannot prove whether a match occurred. In particular, the span
`[0, 0)` is valid for a real zero-width match and is also the natural initialized offset pair for no match.

Rust therefore carries explicit entry/local presence bits alongside groups, named captures, and byte spans. The
bits are saved and restored with the per-rule match frame so child dispatch cannot leak match state into its
caller. Helper projection uses the local bit only where absence is semantically different from a zero value.

The September 7 `SESSION-STARTUP-READING.3.3.21` helper reading confirms explicit
match_present checks for match_len/start/end/group. Coordinate helpers instead
project an optional explicit scalar offset or the stored byte position through typed
authority; their default coordinate behavior does not imply a present match.
Named/group containers retain their separate projections. The 99-case corpus and
137/193 counts above are July evidence, not fresh executions. Current neutral typed
source proof passes 14 complete / 0 pending / 231 mutations.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.2.1`.
- Governed source: `capability_conformance/fixtures/capability_position_helper_surface.spec`.
