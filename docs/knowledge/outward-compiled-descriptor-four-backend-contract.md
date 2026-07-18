---
id: outward-compiled-descriptor-four-backend-contract
title: One executable schema fixes the outward compiled descriptor contract across all variants
answers:
  - "where is the exact outward compiled descriptor schema"
  - "what are the canonical outer user function descriptor fields"
  - "do Perl Rust Dart and Julia expose the same descriptor shape"
  - "how is descriptor shape drift prevented"
  - "is compiled descriptor parity complete"
  - "which outward descriptor metadata variant does Perl use"
date: 2026-07-18
status: current; Perl, Rust, and Dart use cursor v1 while Julia retains the staged legacy variant
tags: [descriptor, public-api, perl, rust, dart, julia, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.2.3 adds capability_conformance/outward_descriptor_contract.json and focused consumers. All variants expose the same four top-level keys, model/order/count identities, and exact function record. FUTURE-PARITY-BACKLOG.9.1.3.3 adds explicit metadata variants; .9.1.4.4 migrates Rust and .9.1.5.3 migrates Dart to rule_local_cursor_v1 with cursor_contract and no parse_mode. Julia retains legacy_global_v0 until its ordered leaf."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test descriptor_test && cd dart && dart test test/compiled_spec_test.dart && cd .. && perl -Iperl t/phase0_regression.t"
---

# Outward Compiled Descriptor Four-Backend Contract

`capability_conformance/outward_descriptor_contract.json` is the executable public schema. It fixes the exact
top-level keys to `spec`, `functions`, `dependency_regex_map`, and `meta`; requires the composing and nested model
identities plus order/count metadata; and fixes each function record to:

`index`, `kind`, `version`, `name`, `params`, `arity`, `source_text`, `source_span`, `body_span`, `body_source`,
`body_payload`, `body_parse_job`, and `body_ast`.

Cursor migration is explicitly staged rather than hidden as schema drift. `required_meta_keys` is labeled
`legacy_global_v0` for unmigrated backends. `meta_contract_variants.rule_local_cursor_v1` instead requires
`cursor_contract`, forbids `parse_mode`, and fixes `linkedspec-rule-local-cursor-v1`; Perl consumes that variant
from `.9.1.3.3`, Rust from `.9.1.4.4`, and Dart from `.9.1.5.3`, while Julia migrates in its later leaf.

Focused tests in every implemented variant load this same file. Perl adds the zero-based source-order index during
outward projection. Dart and Julia use descriptor-specific projections, preserving their internal AST JSON shape.
Rust's typed projection already uses the canonical fields. This prevents any variant's internal serialization
convention from silently redefining the shared user-facing API.
