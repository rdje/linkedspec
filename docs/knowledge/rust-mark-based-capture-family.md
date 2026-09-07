---
id: rust-mark-based-capture-family
title: Rust engine implements the mark-based capture family (capture_*_from / capture_between / mark_copy / mark_input_*) with Perl parity; the non-cursor readers (capture_from/capture_len_from/capture_take_len_from) end at the START of the current match, not the cursor
answers:
  - "does capture_from read to the start or the end of the match in the Rust engine"
  - "where does capture_from stop in the Rust runtime"
  - "how does the Rust engine implement capture_len_from / capture_until_cursor_from / capture_rest_from"
  - "what are the endpoints of the mark-based capture readers"
  - "do capture_take_* helpers advance the mark in the Rust engine"
  - "is mark_copy one argument or two arguments"
  - "what does mark_input_start / mark_input_end store in the Rust engine"
  - "how does the mark-based capture family work in the Rust engine"
date: 2026-09-07
status: historical endpoint fix confirmed; current typed projection reconciled
tags: [rust, engine, runtime, capture, marks, RUST-PARITY]
evidence: "RUST-PARITY.5.5.3 (2026-06-16): rust/linkedspec-runtime/src/engine.rs call_helper arms for capture_from (fixed), capture_len_from, capture_until_cursor_from(+_len), capture_take_until_cursor_from(+_len), capture_take_len_from, capture_rest_from(+_len), capture_take_rest_from(+_len), capture_between, capture_len_between, mark_input_start, mark_input_end, mark_copy; span_text/span_char_len helpers. Authoritative contract: perl/LinkedSpec/ActionIR/Contracts.pm ~690-1047. 223/223 tests green (207 baseline + 16 helpers_5_5_3_*)."
reverify: "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract"
---

# Rust Engine: Mark-Based Capture Family

**Confirmed 2026-06-16 (RUST-PARITY.5.5.3).** Implements the mark-based readers and
mark setters the audit's Gap 5 listed missing, and fixes the pre-existing `capture_from`
endpoint to match the Perl reference (`perl/LinkedSpec/ActionIR/Contracts.pm` ~690–1047 is
the authoritative contract).

## The endpoint rule (the parity fix)

A capture reads from a named mark to one of three endpoints:

- **Start of the current local match** — the **non-cursor** readers: `capture_from`,
  `capture_len_from`, `capture_take_len_from`. In Perl this is `$LSPOS - length $LMATCH`;
  in Rust it is **`ctx.match_start_byte`** (the stored start of the local match).
- **The cursor** (`pos $$STRING` = `ctx.pos`) — the `_until_cursor_` readers.
- **End of input** (`length($$STRING)` = `ctx.input.len()`) — the `_rest_` readers.

The pre-`.5.5.3` `capture_from` read to `ctx.pos` (the cursor / match-**end**), so for a
mark at the match start it returned the whole match instead of the empty pre-match span.
It now reads to `ctx.match_start_byte`. The landed test `helpers_5_2_mark_and_capture_from`
(mark 0, whole-input match "hello") was updated from `"hello"` to `""` to reflect the
parity-correct semantics.

## `_take_` variants are destructive

`capture_take_until_cursor_from`, `capture_take_until_cursor_len_from`,
`capture_take_len_from`, `capture_take_rest_from`, `capture_take_rest_len_from` perform the
read, then advance the named mark to the read's endpoint — the **cursor** (`ctx.pos`) for
the until-cursor and `capture_take_len_from` forms, **end-of-input** for the `_rest_` forms.
(Note `capture_take_len_from` reports the length mark→match-start but advances the mark to
the cursor — matching `Contracts.pm`.) Non-take readers never mutate.

## Historical implementation and current typed projection

At the June milestone, flat mark storage and free span helpers implemented the
endpoint fix. Current named marks are rule-local and byte-based; helper reads
project through RuntimeContext typed span/position authority, then materialize text
or Unicode-scalar lengths. The September 7 reading covers these engine arms and
reconciles them with [[typed-source-location-runtime-rollout-plan]]. Missing marks
and reversed/invalid spans return undef. Mutation follows successful typed reads.

`mark_input_start(name)` stores byte 0; `mark_input_end(name)` stores the
input byte length. `mark_copy(target, source)` copies a known source position
or deletes the target when the source is unavailable.

The June follow-on gaps are historical: anonymous capture_slice/length now stop
at local match start, and named entry/match setters plus take/between helpers are
present. The complete 7879–9278 range ends inside match_end_line; later helper
arms remain owned by the next reading leaf. Fourteen complete / zero pending /
231 neutral mutations pass, but this reading does not rerun the June 223 tests or
the admitted native projection suite.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.5.3`)
- Related: [[rust-char-based-offsets]], [[rust-entry-match-separation]]
- Files: `rust/linkedspec-runtime/src/engine.rs`,
  `perl/LinkedSpec/ActionIR/Contracts.pm`,
  `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`
