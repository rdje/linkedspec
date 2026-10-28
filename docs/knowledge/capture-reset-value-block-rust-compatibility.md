---
id: capture-reset-value-block-rust-compatibility
title: Rust already executes anonymous reset statements inside ordinary value blocks
answers:
  - "does Rust start_capture_slice work inside a cat operand block"
  - "does Rust capture_slice_here preserve local return and lazy skip"
  - "can Rust literal callbacks reset their caller capture boundary"
date: 2026-10-28
status: bounded35.2 targeted-checked without runtime edits; peer/context/package admission open
tags: [rust, blocks, capture, void, methods, callbacks, function]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.35.2 at clean d048d5fd3; capture-reset-value-block-rust-intake.json.gz retains14-source native/restored/plan intake and final regression epochs."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test capture_reset_value_block --test capture_boundary_number_results -- --test-threads=1"
---

The existing Engine::eval_block_value statement path and reset helper branch
already implement ordinary nonfinal reset/alias effects, typed live-cursor
capture_start writes and void result. New3 plus nearby Number6 pass after
independent14-source intake; runtime/frontend/emitter are unchanged and no product
RED is invented. Native/restored CompiledSpec/generated-plan agree on eight core
controls:4! snapshot, boundary2 versus6/rest4 versus0, SA order, local return
before/after reset, later-T skip and defined lazy fallback suppression.

Existing literal callback reset retains dynamic parser context and yields x!/6
for both authored helper names. Pure functions and callbacks invoked by pure apply
retain specific function/helper errors, with generated envelope prefix. These
were observed before normal expectations; no body-vocabulary/mutator-as-data or
scope grant follows. No new temp owner, schema, plan family or shared expected
source changes. Final3 tests/locked offline compile/rustfmt pass; normal fixture
uses the exact shared source. Initial consumer incorrectly demanded native and
generated error byte equality; its failure/source are retained and refined to
preserve existing envelopes, with no semantic RED credit. Fresh emitted package
and full source/context admission remain23.4; Dart35.3 independently follows.
