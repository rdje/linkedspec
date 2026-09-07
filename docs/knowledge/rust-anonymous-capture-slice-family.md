---
id: rust-anonymous-capture-slice-family
title: Rust engine implements the full anonymous capture-slice family (capture_slice/_len, capture_slice_until_cursor/_len, capture_take/_len, capture_take_until_cursor/_len, capture_rest/_len, capture_take_rest/_len) on the anonymous capture cursor (ctx.capture_start = Perl $IPOS); capture_slice/capture_slice_len now end at the START of the current match, not the cursor
answers:
  - "does capture_slice read to the start or the end of the match in the Rust engine"
  - "where does capture_slice stop in the Rust runtime"
  - "how does the Rust engine implement capture_slice_until_cursor / capture_take / capture_rest"
  - "what is the anonymous capture cursor in the Rust engine"
  - "do the anonymous capture_take_* helpers advance the capture cursor in the Rust engine"
  - "how does capture_take differ from capture_take_until_cursor in the Rust engine"
  - "what sets ctx.capture_start in the Rust runtime"
  - "how does the anonymous capture-slice family work in the Rust engine"
date: 2026-09-07
status: confirmed
tags: [rust, engine, runtime, capture, RUST-PARITY]
evidence: "RUST-PARITY.5.5.4 (2026-06-16): rust/linkedspec-runtime/src/engine.rs call_helper arms for capture_slice (fixed), capture_slice_len (fixed), capture_slice_until_cursor(+_len), capture_take(+_len), capture_take_until_cursor(+_len), capture_rest(+_len), capture_take_rest(+_len); historically reused span_text/span_char_len; current helpers use RuntimeContext typed projections. STAGED-LINKED-PARSING.5.3.2 (2026-07-02) additionally made dispatched rule invocations set ctx.capture_start to the entry match end, matching Perl's child-handler IPOS for opener/closer island parsing; user_function_definition.spec body_payload tests lock capture_slice() as the text after the function opener and before the outer close. Authoritative contract: perl/LinkedSpec/ActionIR/Contracts.pm ~366-656 plus the generated-handler child-entry behavior."
reverify: "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime helpers_5_5_4_; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime terse_2_3_2_child_rule_capture_slice_starts_after_entry_match"
---

# Rust Engine: Anonymous Capture-Slice Family

**Confirmed 2026-06-16 (RUST-PARITY.5.5.4).** Implements the anonymous capture-slice
readers the audit's Gap 5 listed missing, and fixes the pre-existing `capture_slice` /
`capture_slice_len` endpoint to match the Perl reference
(`perl/LinkedSpec/ActionIR/Contracts.pm` ~366–656 is the authoritative contract). This is
the anonymous counterpart of the named-mark family [[rust-mark-based-capture-family]].

## The anonymous capture cursor

These readers operate on a single **anonymous capture cursor**, `ctx.capture_start`
(`Option<usize>`, a byte offset) — Perl `$IPOS`. It is set by `start_capture_slice()`
(`ctx.capture_start = Some(ctx.pos)`), normally from an `I`-block which runs *before* the
rule's seek/match, so it records a position at or before the match start. Reads default an
unset cursor to 0.

When a rule is entered through a parent dispatch edge, Rust now initializes
`ctx.capture_start` to that child invocation's entry-match end. This mirrors the Perl
generated handler's child-entry `$IPOS` behavior and is what lets
`user_function_definition.spec` return a function body payload with `capture_slice()`:
the opener regex consumes through `{`, the capture cursor starts after that opener, and
the close edge reads up to the outer `}` match start.

## The endpoint rule (the parity fix)

A reader captures from `ctx.capture_start` to one of three endpoints:

- **Start of the current local match** — `capture_slice`, `capture_slice_len`,
  `capture_take`, `capture_take_len`. In Perl this is `$LSPOS - length $LMATCH`; in Rust it
  is **`ctx.match_start_byte`**.
- **The cursor** (`pos $$STRING` = `ctx.pos`) — the `_until_cursor` readers.
- **End of input** (`length($$STRING)` = `ctx.input.len()`) — the `_rest` readers.

The pre-`.5.5.4` `capture_slice` / `capture_slice_len` read to `ctx.pos` (the cursor /
match-**end**); they now read to `ctx.match_start_byte` (match-**start**), exactly mirroring
the `.5.5.3` `capture_from` fix. The two landed tests `helpers_5_2_capture_slice_basic` /
`helpers_5_2_capture_slice_len` (capture started at the match start) were updated from
`"hello"` → `""` and `>0` → `0`.

## `_take_` variants are destructive

`capture_take`, `capture_take_len`, `capture_take_until_cursor`(+`_len`), and
`capture_take_rest`(+`_len`) perform the read, then advance `ctx.capture_start` to the
**cursor** (`ctx.pos`, Perl `$IPOS = pos $$STRING`) — **except** the `_rest` forms, which
advance to **end-of-input**. Note `capture_take` / `capture_take_len` read up to the
match-**start** but still advance the cursor to the scan position. Non-take readers never
mutate; `_take_*` mutate only after a valid typed span read. The earlier description of a
blanket deviation from unguarded Perl substr is obsolete: the corresponding guarded reference
readers must be compared individually at their current lowering boundary.

## Text vs length and guards

- Text readers return the raw `input[a..b]` byte slice (correct chars); `_len` readers
  return its **char** count (DSL lengths are char-based, [[rust-char-based-offsets]]).
- A reversed / out-of-range span returns `undef` through RuntimeContext typed span/position
  authority, which replaced the historical free helpers. The `_until_cursor`/`_rest` Perl readers
  carry corresponding `defined`/`>=` guards; this is not a claim that every invalid route was rerun.

## Scope note (inventory gap folded in)

The leaf named 7 inventoried anonymous variants, but `Contracts.pm` showed the
`RUST-PARITY.1` inventory itself omitted the same-family `capture_rest`, `capture_rest_len`,
and bare `capture_take` (anonymous, no-mark). All 10 missing anonymous helpers were landed
together so the family is complete. The separately-discovered mark/match/entry-anchored
helpers (`mark_match_*`, `mark_entry_*`, `capture_take(mark)`, `capture_take_between(_len)`)
are a **different** family. They were deferred at that June milestone; current dispatch includes
those named routes, governed by [[typed-source-location-runtime-rollout-plan]].

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.5.4`; closes `.5.5` and `.5`)
- Related: [[rust-mark-based-capture-family]], [[rust-char-based-offsets]], [[rust-entry-match-separation]]
- Files: `rust/linkedspec-runtime/src/engine.rs`,
  `perl/LinkedSpec/ActionIR/Contracts.pm`,
  `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`

## September 7 source and assertion reconciliation

`SESSION-STARTUP-READING.3.3.22` reads exact text/length and post-take assertions through
engine line 12246. Explicit `OR{1,1}` fixtures isolate one seek: on `  ab cd` the match starts
at byte 2, cursor ends at 4, and input ends at 7. Anonymous reads select the appropriate endpoint;
take-to-match still advances to cursor 4, while take-rest advances to 7. The multibyte rest test
asserts eight characters for nine bytes. Named tests independently cover missing/deleted marks,
reversed spans and post-take state. No fresh native test execution is claimed. Typed-source and
rule-local-cursor neutral checks pass (231 and 60 drift mutations respectively).
