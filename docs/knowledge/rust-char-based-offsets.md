---
id: rust-char-based-offsets
title: Rust engine keeps internal positions as byte offsets but exposes char offsets to the DSL (Perl parity); substr/input_slice char-slice, cursor/match/entry positions and lengths convert via byte_to_char_offset
answers:
  - "does the Rust engine use byte or char offsets"
  - "why did substr panic on multibyte UTF-8 input in the Rust runtime"
  - "are cursor_pos / match_start_pos / length char-based or byte-based in Rust"
  - "how does the Rust engine convert between byte and char offsets"
  - "is match_start_pos / entry_start_pos implemented in the Rust runtime"
  - "how does Rust match Perl's char-based positions"
date: 2026-09-07
status: confirmed
tags: [rust, engine, runtime, utf8, offsets, RUST-PARITY]
evidence: "RUST-PARITY.5.3 (2026-06-16): rust/linkedspec-runtime/src/engine.rs byte_to_char_offset/char_substr + substr/input_slice/cursor_*/capture_*/mark_pos/entry_*/match_*/length helpers; rust/linkedspec-runtime/src/runtime.rs entry_*/match_*_byte span fields. 196/196 tests green (189 baseline + 7 chars_5_3_*)."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime chars_5_3_; rg -n 'byte_to_char_offset|char_substr|match_start_byte' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/runtime.rs"
---

# Rust Engine: Byte-Internal / Char-Exposed Offsets

**Confirmed 2026-06-16 (RUST-PARITY.5.3).** Fixes the audit's byte-indexing MAJOR:
`substr`/`input_slice` byte-sliced DSL char-offset arguments (panicking on a multibyte
boundary, diverging from Perl), `cursor`/`capture` lengths and columns were byte counts, and
`entry_start_pos`/`match_start_pos` were hardcoded `0.0`.

## The rule

- **Internal positions stay byte-based**: `ctx.pos`, `capture_start`, `marks`, the regex
  `MatchResult.start`/`.end`, and the new `entry_*_byte`/`match_*_byte` match-span fields are
  all **byte** offsets into `ctx.input` (the regex engine works in bytes). Engine-maintained offsets must
  remain valid UTF-8 boundaries before slicing the input between them (for example `capture_slice` or `capture_from`). A byte count alone does not prove that invariant.
- **The DSL boundary is char-based** (Perl `pos()`/`length`/`substr` are char-based):
  - Positions/lengths surfaced to the DSL convert byte→char via `byte_to_char_offset(input,
    byte)` = `input[..byte].chars().count()`: `cursor_pos`, `cursor_col`, `cursor_rest_len`,
    `input_len`, `input_end_pos`, `capture_slice_len`/`_pos`, `mark_pos`, `entry_start_pos`/
    `entry_end_pos`/`entry_len`, `match_start_pos`/`match_end_pos`/`match_len`, `length`.
  - Helpers taking DSL char-offset **arguments** char-slice via `char_substr(s, start, len)` =
    `s.chars().skip(start).take(len).collect()` (never panics): `substr`, `input_slice`.
- **Line numbers** are newline counts (`chars().filter(|c| *c=='\n').count()`), identical byte
  or char, so they were already correct; only **columns** (distance from the last newline)
  needed char counting.

## Match spans

`entry_start_pos`/`match_start_pos` are no longer hardcoded: `execute_rule` records the regex
`m.start`/`m.end` (bytes) into `match_start_byte`/`match_end_byte`, and the entry span follows
the same dispatcher-vs-own-first-match rule as the groups ([[rust-entry-match-separation]]).
The four byte spans are part of `SavedMatchState`, so they save/restore per invocation too.

## For ASCII this is a no-op

byte == char for ASCII, so all pre-existing (ASCII) tests are unchanged; the multibyte
`chars_5_3_*` tests pin the UTF-8 behavior.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.3`)
- Related: [[rust-entry-match-separation]], [[rust-retv-propagation]]
- Files: `rust/linkedspec-runtime/src/engine.rs`, `rust/linkedspec-runtime/src/runtime.rs`

## September 7 helper precondition reading

`SESSION-STARTUP-READING.3.3.15` confirms that `byte_to_char_offset` clamps to
input length but then slices at the supplied byte position; it does not independently
validate UTF-8 boundaries. `next_char_boundary_after` likewise starts at an already
valid boundary. The scalar substring helpers iterate characters directly. This
qualifies the private-helper precondition, not a newly reproduced public panic.
The old June native counts above remain historical.

## September 7 test-reading boundary

`SESSION-STARTUP-READING.3.3.22` reads the exact Unicode substring, input slice, cursor/entry/local
positions, input-end column and capture-length assertions. A named between-span asserts `héllo`
and length 5; anonymous rest asserts `ab,héllo` and length 8. These establish what the tests check,
not a fresh native run or proof for every helper. Current DSL projections use typed RuntimeContext
authority; the private byte helper precondition above remains separate. Scalar undefined input is
also distinct from character indexing: [[rust-scalar-helper-null-and-empty-drift]] owns that gap.
