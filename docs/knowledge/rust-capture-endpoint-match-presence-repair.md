---
id: rust-capture-endpoint-match-presence-repair
title: Rust anonymous capture endpoints distinguish absent state from a real zero-width match
answers:
  - "why did Rust capture_slice_len return zero before a local match"
  - "why did Rust capture_take advance without a local match"
  - "does the Rust capture endpoint repair reuse match_present"
  - "must Rust emitted source be regenerated for capture endpoint presence"
date: 2026-10-29
status: bounded40.2 focused repair verified; independent peers/selection/full admission separate
tags: [rust, capture, source-location, presence, match, generated-source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.40.2 rust-capture-endpoint-intake.json.gz retains16-source native/reconstructed/plan/separate emitted9healthy7RED ->16pass, exact unchanged input/source/metadata, same baseline module relink and8 integration/10 library tests."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test capture_endpoint_absence --test capture_boundary_number_results --test source_boundary_compatibility_aliases -- --test-threads=1"
---

Public root-I debug trace calls capture readers at initialized match_start0 before
selection while structural match projections return null. Engine::call_helper
anonymous text/width/take arms validated span bounds but ignored RuntimeContext's
existing match_present. A valid [0,0) span cannot prove that a match occurred;
manufactured empty/0 also made take movement appear successful.

Four guards now check that existing presence flag before typed span projection
or take mutation. Aliases share the same arms. Matcher/frame/presence ownership,
arity/function fences, cursor/rest endpoints and successful take behavior remain
unchanged; no new bit, API, compiler/emitter, schema or diagnostic policy is added.

Independent16-source native/reconstructed/plan/separate compiled emitted results
change9healthy7RED to16pass. Exact parsed/compiled/serialized/plan/emitted bytes,
public metadata and nine healthy observations are preserved. Real empty/zero/
Unicode and incoming/direct/cursor/boundary/take controls are retained. The same
baseline emitted source modules pass when relinked against the repaired runtime:
rebuild applications, no source regeneration. Existing binaries retain old code.

New endpoint1/Number6/alias1 integration groups and10 anonymous library tests pass.
Fresh lock versions/sources/checksums match native lock; data stays on-volume and
dependencies are black boxes. Cursor evidence is authored DSL readers in values,
not a direct native final-state channel or a Perl package-state seed. Initial
static-plan lifetime/temporary formatting errors receive no product RED credit.
Temporary producer is snapshotted/removed; normal test has no allocator. Broader
phase/slot/SESSION17, independent40.3-.5, canonical selection23.4.1 and admission
remain separately owned.
