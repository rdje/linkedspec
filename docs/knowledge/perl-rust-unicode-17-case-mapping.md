---
id: perl-rust-unicode-17-case-mapping
title: Perl and Rust casing execute one generated Unicode 17 contract
answers:
  - where is Perl Unicode casing implemented
  - where is Rust Unicode casing implemented
  - do Perl and Rust use host lowercase uppercase APIs
  - how does Perl generated source load Unicode casing
  - do lowercase_each uppercase_each use pinned Unicode data
  - which LinkedSpec variants already consume Unicode 17 casing
date: 2026-07-12
status: current
tags: [unicode, casing, perl, rust, generation, actionir, runtime, parity]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.2.2 extends unicode_case/generate_unicode_case_contract.py and tools/check_unicode_case_contract.py with byte-compared perl/LinkedSpec/UnicodeCaseMapping.pm and rust/linkedspec-runtime/src/unicode_case_mapping.rs. Perl ActionIR owners and generated-source preamble load the module; scalar and array lowering call it. Rust engine scalar and both array seams call its module. Twelve fixtures pass direct/helper/receiver/array paths; Perl focused 52 and phase0 1..1030 pass; the full Rust runtime package passes; authoritative local CI passes CLI 61x2 and phase0 1..1030. Source audit finds no lc/uc in Perl ActionIR and no to_lowercase/to_uppercase in Rust runtime casing paths."
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py && prove -q -Iperl t/unicode_case_mapping.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test unicode_case_mapping"
---

## Fact

Perl and Rust no longer delegate LinkedSpec `lowercase`, `uppercase`, `lowercase_each`, or `uppercase_each` semantics
to host Unicode tables. The neutral Unicode 17 contract deterministically generates one backend module for each:

- `perl/LinkedSpec/UnicodeCaseMapping.pm`
- `rust/linkedspec-runtime/src/unicode_case_mapping.rs`

Both modules embed the contract id, Unicode version, and logical data digest. They implement full mapping expansion,
Unicode-scalar iteration, binary-searched `Cased`/`Case_Ignorable` properties, contextual `Final_Sigma`, and no
normalization. Scalar function form, scalar receiver form, value-array form, and standalone array mutation form all
use the same evaluator in each backend.

Perl has two dependency boundaries. Ordinary compilation loads the module from both ActionIR emitters before emitted
handlers execute. Independently loadable parser source explicitly contains `use LinkedSpec::UnicodeCaseMapping ();`.
A fresh Perl process importing only `LinkedSpec` verifies the former; generated-source tests verify the latter.

The backend files are generated artifacts, not hand-maintained tables. `tools/check_unicode_case_contract.py`
regenerates the JSON and both modules in owned temporary storage and byte-compares all three.

Related facts: [[unicode-17-case-contract-data]], [[unicode-case-mapping-cross-backend-gap]].
