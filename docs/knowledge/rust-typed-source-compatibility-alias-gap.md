---
id: rust-typed-source-compatibility-alias-gap
title: Rust executes all seven neutral source-boundary compatibility aliases through canonical helper semantics
answers:
  - "does Rust execute all seven typed source location compatibility aliases"
  - "which typed source compatibility aliases are missing in Rust"
  - "does Rust capture_from_rule_start match Perl"
  - "does Rust capture_len_from_rule_start match Perl"
  - "does Rust capture_rest_length match Perl"
  - "does Rust capture_slice_here match Perl"
  - "does Rust capture_slice_length match Perl"
  - "why can Rust typed source projection not preserve all alias behavior unchanged"
date: 2026-08-01
status: parity gap closed; Rust five-alias repair implemented and carrier-proved
tags: [rust, perl, source-location, helpers, aliases, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.2.0: exact source inventory finds all 92 canonical helper names in rust/linkedspec-runtime/src/engine.rs, but only entry_named_map and match_named_map among the seven neutral compatibility aliases. The Rust primary executable compiles each of capture_from_rule_start(), capture_len_from_rule_start(), capture_rest_length(), capture_slice_here(), and capture_slice_length() and returns JSON null. LinkedSpec::call_spec_handler_subst lowers those same five Perl calls through span_text/span_length/capture_boundary_write_position typed projections; LinkedSpec::Get returns numeric 0 for the same minimal matched fixture. Repair would therefore change observable Rust behavior rather than merely re-route an unchanged result."
evidence_update_2026_08_07: "The director confirms Rust must implement Perl-equivalent behavior. Exact Perl contract records and the mdBook prove the neutral JSON/checker mislabel capture_from_rule_start as capture_from and capture_len_from_rule_start as capture_len_from: both aliases are zero-argument anonymous-boundary forms and their correct targets are capture_slice and capture_slice_len. FUTURE-PARITY-BACKLOG.14.2.2.0.1 owns the neutral correction, .0.2 the five-alias Rust repair, and .0.3 the typed-source RED."
evidence_update_2026_08_07_neutral_correction: "FUTURE-PARITY-BACKLOG.14.2.2.0.1 corrects exactly the two neutral rows to capture_slice and capture_slice_len. The checker now proves each non-scanner alias has the canonical Perl diagnostic name, IR node, and ordered SourceLocation::Runtime lowering calls, while the old arity-wrong capture_from target is an explicit rejected mutation. Counts and rollout remain 7 aliases, 38 mutations, and 4/10."
evidence_update_2026_08_07_rust_parity: "FUTURE-PARITY-BACKLOG.14.2.2.0.2 adds the five names as alternatives on the existing canonical Engine arms and mark/capture trace classifier. RED returned five nulls and five unknown-helper warnings. GREEN proves Unicode input é🙂  ab, anonymous-boundary mutation/undef result, canonical-equivalent text and scalar widths, reversed-span undef, native Engine, serialized/reconstructed CompiledSpec, generated-plan execution, and independently compiled emitted source. Neutral rollout remains 4/10/38; this repairs compatibility spelling only and does not admit Rust typed source values."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_boundary_compatibility_aliases; bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
---

# Rust source-boundary compatibility-alias parity

The neutral typed-source contract lists seven callable compatibility aliases. Rust executes `entry_named_map()`
and `match_named_map()` plus these five capture spellings:

- `capture_from_rule_start()`;
- `capture_len_from_rule_start()`;
- `capture_rest_length()`;
- `capture_slice_here()`; and
- `capture_slice_length()`.

The Perl reference lowers those five to the canonical `capture_slice`, `capture_slice_len`, `capture_rest_len`,
`start_capture_slice`, and `capture_slice_len` projection families. Rust now routes each name through the same
existing canonical match arm, rather than copying its implementation. Its mark/capture trace classifier recognizes
the same names, so result, mutation, absence, Unicode width, and trace-category behavior share one semantic body.

This was an observable Rust parity repair: before implementation, the five calls compiled but reached generic
unknown-helper fallback and returned JSON null. The director confirmed that Rust must match Perl. Exact RED/GREEN
coverage now fixes normal and reversed spans over Unicode input across native, reconstructed, generated-plan, and
independently compiled emitted-source carriers. The neutral correction separately records the first two aliases'
zero-argument anonymous-boundary targets as `capture_slice()` and `capture_slice_len()`.

The repair does not promote `rust_runtime` in the typed source-location rollout. Public typed values,
transactions, recursive observation, and span-native dispatch remain owned by the later Rust core/projection/
admission leaves.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.2.0.2`.
- Neutral plan: [[typed-source-location-neutral-contract-plan]].
- Runtime rollout: [[typed-source-location-runtime-rollout-plan]].
