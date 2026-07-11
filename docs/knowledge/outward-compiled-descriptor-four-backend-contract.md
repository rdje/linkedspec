---
id: outward-compiled-descriptor-four-backend-contract
title: One executable schema fixes the outward compiled descriptor contract across all variants
answers:
  - "where is the exact outward compiled descriptor schema"
  - "what are the canonical outer user function descriptor fields"
  - "do Perl Rust Dart and Julia expose the same descriptor shape"
  - "how is descriptor shape drift prevented"
  - "is compiled descriptor parity complete"
date: 2026-07-11
status: current
tags: [descriptor, public-api, perl, rust, dart, julia, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.2.3 adds capability_conformance/outward_descriptor_contract.json and focused consumers in t/phase0_regression.t, rust/linkedspec-core/tests/descriptor_test.rs, dart/test/compiled_spec_test.dart, and julia/test/runtests.jl. All variants expose the same four top-level keys, required metadata identities, and exact function record; complete relevant backend gates pass."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test descriptor_test && cd dart && dart test test/compiled_spec_test.dart && cd .. && perl -Iperl t/phase0_regression.t"
---

# Outward Compiled Descriptor Four-Backend Contract

`capability_conformance/outward_descriptor_contract.json` is the executable public schema. It fixes the exact
top-level keys to `spec`, `functions`, `dependency_regex_map`, and `meta`; requires the composing and nested model
identities plus order/count metadata; and fixes each function record to:

`index`, `kind`, `version`, `name`, `params`, `arity`, `source_text`, `source_span`, `body_span`, `body_source`,
`body_payload`, `body_parse_job`, and `body_ast`.

Focused tests in every implemented variant load this same file. Perl adds the zero-based source-order index during
outward projection. Dart and Julia use descriptor-specific projections, preserving their internal AST JSON shape.
Rust's typed projection already uses the canonical fields. This prevents any variant's internal serialization
convention from silently redefining the shared user-facing API.
