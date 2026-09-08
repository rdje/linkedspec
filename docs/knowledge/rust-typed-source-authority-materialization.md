---
id: rust-typed-source-authority-materialization
title: Rust source values preserve private authority and recheck provenance when materializing text
answers:
  - "what does the Rust typed source contract consumer actually execute"
  - "how does Rust SourceAuthority own source identity and scalar coordinates"
  - "what may implement Rust MaterializableSourceValue"
  - "how does Rust materialize Span and DerivedText"
  - "does Rust reject a foreign empty DerivedText"
date: 2026-09-08
status: current source authority with bounded value and runtime-consumer evidence
tags: [rust, source-location, spans, provenance, authority, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.34-.35 read source_location.rs 1–561 completely, baseline-identical. The rollout card's per-card byte cap routes these exact source-reading sections here under .3.3.35."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test typed_source_location_contract"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "rg -n 'authority_id|MaterializableSourceValue|materialize_span|scalar_offset' rust/linkedspec-runtime/src/source_location.rs"
---

# Rust source authority and materialization

The full cross-runtime adoption and its dated native helper/carrier evidence remain in
[[typed-source-location-runtime-rollout-plan]]. This card owns the complete Rust value/authority source reading.

## September 7 immutable Rust value and authority prefix reading

`SESSION-STARTUP-READING.3.3.34` reads source_location.rs 1–464. Position, direct Span and DerivedText
keep private authority/source identities, scalar offsets and provenance; cloned records expose no text or live
owner. SourceAuthority snapshots decoded strings, assigns a checked monotonic AtomicU64 identity and retains
scalar-boundary UTF-8 byte plus one-based line/column tables. LF increments the line; byte-to-scalar conversion
requires an exact boundary. Direct spans require matching source/authority and non-reversed offsets; derived
text requires every span to belong to this authority. Coordinate projection checks authority and range again.
Materialization and the final helper suffix remain next. Current neutral proof is 14/0/231; this source reading
does not rerun the older native value/helper/generated consumers or widen the public authored-value boundary.

## September 7 Rust materialization completion

`SESSION-STARTUP-READING.3.3.35` reads source_location.rs 465–561 and completes the file. The sealed
MaterializableSourceValue trait admits only Span and DerivedText. Direct materialization validates the source
slice and authority again; derived text first checks its owning authority, then concatenates each validated
span in provenance order. Failures retain the exact provenance index/source ID with the invalid-derived-
provenance code, including foreign empty derived values. Returned strings and span records are detached.
Fresh neutral proof remains 14/0/231; no additional native authoring/helper/carrier suite is claimed.

## September 8 typed-source consumer reading

`SESSION-STARTUP-READING.3.3.65` reconciles all 546 lines of
`rust/linkedspec-runtime/tests/typed_source_location_contract.rs`. Two value tests
cover the three sources, seven positions, six direct spans and three derived texts,
coordinate/materialization privacy and detachment, and four exact private errors.
A catalog test compares all 92 unique helper rows and seven aliases and proves
returned catalog isolation. Catalog completeness is separate from per-helper
runtime execution.

The runtime test executes named-mark, cursor-control and Unicode alias fixtures
through native, reconstructed and validated generated-plan helper routes. This
consumer does not independently compile an emitted module or invoke every helper
merely by comparing the catalog. Its four tests passed in the .61 canonical run
(`64d82792`); .65 freshly verifies neutral 14/0/231 and the 3/7/6/3 plus 92+7
inventories without claiming another native execution or widening public values.
