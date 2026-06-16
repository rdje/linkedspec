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
date: 2026-06-16
status: confirmed
tags: [rust, engine, runtime, capture, marks, RUST-PARITY]
evidence: "RUST-PARITY.5.5.3 (2026-06-16): rust/linkedspec-runtime/src/engine.rs call_helper arms for capture_from (fixed), capture_len_from, capture_until_cursor_from(+_len), capture_take_until_cursor_from(+_len), capture_take_len_from, capture_rest_from(+_len), capture_take_rest_from(+_len), capture_between, capture_len_between, mark_input_start, mark_input_end, mark_copy; span_text/span_char_len helpers. Authoritative contract: perl/LinkedSpec/ActionIR/Contracts.pm ~690-1047. 223/223 tests green (207 baseline + 16 helpers_5_5_3_*)."
reverify: "cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n '\"capture_from\"\\|\"capture_len_from\"\\|\"capture_between\"\\|\"mark_copy\"\\|fn span_text' linkedspec-runtime/src/engine.rs | head"
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

## Text vs length, marks, and guards

- Marks are **byte** offsets in `ctx.marks` (a flat `HashMap<String, usize>`); text readers
  return the raw `input[a..b]` slice (correct chars), `_len_` readers return its **char**
  count (DSL lengths are char-based, [[rust-char-based-offsets]]).
- A missing mark, or a reversed / out-of-range span, returns `undef` — matching the Perl
  readers' `defined`/`>=` guards. Two free helpers `span_text` / `span_char_len` centralize
  the guarded slice so a degenerate span never panics.
- `mark_input_start(name)` stores 0; `mark_input_end(name)` stores `ctx.input.len()` (byte
  length); `mark_copy(target, source)` is **2-arg** — it copies `source`'s position to
  `target`, or deletes `target` when `source` is unset. (The book catalog previously showed
  a 1-arg `mark_copy` and a match-**end** `capture_from` — both imprecisions corrected in
  the Helper Contract Catalog §7 in this slice.)

## Known follow-on gaps (out of this leaf's scope)

- The **anonymous** `capture_slice()` / `capture_slice_len()` Rust arms still read to the
  cursor (`ctx.pos`), but the contract (and the now-corrected catalog) is the **start of the
  current match** (`$LSPOS - length $LMATCH`). Fix belongs to `RUST-PARITY.5.5.4`.
- `mark_match_start`/`mark_match_end`, `mark_entry_start`/`mark_entry_end`, `capture_take(mark)`,
  and `capture_take_between`/`capture_take_between_len` exist in `Contracts.pm` but are absent
  from both the Rust engine and the `RUST-PARITY.1` inventory — a discovered inventory gap.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.5.3`)
- Related: [[rust-char-based-offsets]], [[rust-entry-match-separation]]
- Files: `rust/linkedspec-runtime/src/engine.rs`,
  `perl/LinkedSpec/ActionIR/Contracts.pm`,
  `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`
