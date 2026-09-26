---
id: rust-leading-input-trivia-boundary
title: Rust public entry must skip reference leading trivia before native or generated execution
answers:
  - "why did ds_vhistory fail after the Rust typed indexed-read repair"
  - "does Rust skip leading blank and comment lines before the top rule"
  - "did RGX f6e5acdc cause the history-parser object-name mismatch"
  - "does leading trivia change source coordinates or child entry"
date: 2026-09-26
status: verified under RGX-CONSUMER-BUILD-REPORTS.1.2 through full Rust component acceptance
tags: [rust, public-entry, cursor, oracle, regression]
evidence: "The preserved pre-adoption executable and fresh f6e5acdc build both returned /proj/foo for ds_vhistory, while Perl Get/get_parser returned the unchanged frozen null. RuntimeContext::new initializes pos0 and all four public engine carrier seams lacked the reference wrapper skip. Fourteen independent Perl cases establish exact starts; new Rust test is RED at newline-word, then GREEN alongside all105 unchanged corpus fixtures after the boundary correction."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test leading_input_trivia --test corpus_oracle; bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter emitted_public_entry_preserves_leading_trivia_positions_and_source"
---

The mismatch is a LinkedSpec public-entry gap, observed in both the preserved
pre-adoption binary and the fresh build. It is not attributed to RGX. The earlier
typed indexed-read defect returned null for a scalar-held array; correcting that
lookup in startup .88 exposed the object value because Rust still began at byte0.
The Perl public wrapper skips the initial newline, so its object regex requiring
that newline cannot match and the frozen object name remains null.

`engine.rs` now computes `public_input_start` once at each of the four native/
generated direct-value/accumulator seams, after validation and entry resolution.
It skips only complete spaces/tabs-plus-LF lines and leading spaces/tabs-plus-#
comments ending at LF or EOF. Ordinary horizontal/Unicode whitespace and blank
CRLF lines are preserved, matching the reference exactly. The full source stays
intact, byte/scalar coordinates remain absolute, internal RuntimeContext construction
is unchanged, and child handlers do not repeat the skip.

Tests cover native and reconstructed engines, both generated result projections,
repeat calls, Unicode comments, EOF, source retention and child-entry behavior.
A separately compiled emitted module exercises the same public boundary. The
book's previous "every handler/match" description was inaccurate and is corrected
to once per public invocation. See [[ds-vhistory-leading-newline-oracle-boundary]]
for the independently established Perl/Dart/Julia/Lua authority.

Strict grammars must also validate wrapper-skipped source. The subsequent
SExprDocumentV1 acceptance repair is owned by
[[sexpr-document-entry-prefix-validation]]; it preserves this public boundary
while rejecting hash comments that are not part of the document's trivia contract.
