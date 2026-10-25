---
id: rust-large-number-conversion-defect
title: Rust binary64 value transport and checked integer boundaries
answers:
  - "why does Rust return 9223372036854775807 for 100000000000000000000"
  - "does Rust preserve large finite numbers in direct JSON results"
  - "does cat stringify 1e20 identically on Rust and Perl"
  - "does the scalar text fixture cover scientific notation"
  - "which task owns Rust large number saturation"
  - "is numeric JSON value preservation the same as scalar text formatting"
  - "why does a Rust nested write report an index smaller than 18446744073709551616"
  - "does Rust nested write classification saturate its maximum usize index"
  - "why does numeric serde change values adjacent to the i64 limits"
  - "how does Rust preserve unsigned integer JSON tokens from binary64"
date: 2026-10-25
status: current
tags: [rust, perl, numeric, scalar-text, json, reading, defect]
evidence: "SESSION-STARTUP-READING.55.1; docs/checkpoints/rust-numeric-boundaries/"
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/rust-numeric-boundaries/publish.py"
---

# Rust numeric value transport

`SESSION-STARTUP-READING.55.1` repairs value conversion; `.55.2` still owns portable
scalar-text spelling and `.55.3` broad closeout. `RuntimeValue::Number` remains
binary64, with no arbitrary-precision integer promise.

`core/numeric.rs` supplies checked integer projection: finite whole values in
[-2^63,2^63) become signed integer JSON, then values in [0,2^64) use unsigned
integer JSON. Other finite values remain floating JSON; nonfinite values become
null. Negative zero remains floating negative zero. Exact integer tokens matter:
converting the wrong i64-max token back to f64 can mask its identity at 2^63.

`to_str`, numeric `len` and `Display` share checked integer text inside those
domains and the existing f64 formatter outside them. Aggregate JSON/Display
recurse. Engine finalization, text helpers, hash keys, recognition payloads,
serialized AST/compiled carriers and public emitted Rust are in the owned audit.
`to_scalar_text`/`cat` and the frozen scalar-text authority remain unchanged.

The workspace enables serde_json `float_roundtrip` without a version/pin change.
Actual raw numeric serde previously moved both representable neighbors immediately
inside the i64 limits to the limits; the same-source feature control and physical
feature inverse distinguish that second defect from saturation.

Positive nested writes and the definition-AST/v1-job integer readers use finite,
whole, nonnegative values strictly below 2^usize::BITS. The integer u64 branch
still uses checked usize conversion. The inclusive rounded `usize::MAX as f64`
guard formerly admitted 2^64 and changed its diagnostic index. Existing read,
bounded-count and child-push overload coercions remain; signed selectors retain
their separate normalization contract.

`runtime_value_from_json` recursively maps child payloads and typed source records
to the existing f64 model. No fallback-to-zero failure was observed. Nonrepresentable
integer inputs may round under that model. Actual progressive nested payloads
cover33 finite inputs through native/generated paths. Private definition-field
tests cover seven fields/both number branches; they do not claim a reachable
source with 2^usize::BITS characters. Public v1 dispatch has23 boundary controls.

Current retained evidence covers36 core inputs;53 source cases through native,
SpecFile JSON, compiled JSON and generated plans;49+4 independently compiled
emitted entries;52 CLI cases/104 quiet-trace processes plus4 function CLI controls;
and the real user-function definition AST/staged-body path. Five physical source
faults fail and restore fresh GREEN. Exact source/support admission keeps original
historical source/log/runtime identities and the prior signed-selector image.

Re-derive the actual item observations with `review_numeric.py`,
`review_processes.py` and `review_faults.py` under
`docs/checkpoints/rust-numeric-boundaries/`. `AUDIT.md` records the consumer
boundary. The readonly `publish.py` additionally binds all retained inputs,
executable bytes, book, dependent suites and historical recovery. All one-shot
capture writers stay retired; no historical runtime is refreshed.

## Dated pre-repair evidence and separate spelling

The September7 public Rust CLI returned i64-max/min for +/-1e20; Perl Get preserved
the values, and42 passed both. The complete original card, including every dated
command, source-only qualification and artifact pointer, remains recoverable in
`audit-before.json.gz` (context/sources at this path) under the same checkpoint
prefix, and in activation f0d974aa1b337bbf2ee16e51c0297182e1e94f82.
The fresh retained pre-repair CLI reproduces those results. Historical usize
diagnostics and source-only bridge/private AST inventories earn no new public
failure credit beyond their actual supplied controls.

Rust `cat(100000000000000000000, "")` still produces full decimal text while Perl
produces scientific text. The frozen neutral samples -0.0,1.0,1.25 do not decide
that magnitude. `.55.2` must reconcile the reference policy before changing that
authority. Initial overstrict wide-integer text targets, invalid key/dispatch
probes and incomplete first-capture custody stay explicitly qualified; none is
silently converted into product or portable admission.
