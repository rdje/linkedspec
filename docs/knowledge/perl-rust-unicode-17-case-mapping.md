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
regenerates the JSON and all five current backend modules in owned temporary storage and byte-compares all six files.

Related facts: [[unicode-17-case-contract-data]], [[unicode-case-mapping-cross-backend-gap]].

## September 6 first Perl table checkpoint

The complete physical table reading remains recorded under `SESSION-STARTUP-READING.31`.
`.3.2.49` reconciles lines 1–1500 (32,073 bytes; SHA-256
`a75e182640627d042dd282ef7257d5ae1ec20431abad1a7fb316498b6abd02a1`) with exact baseline identity,
the generated header, and the pinned authority. This fragment is the opening lower-mapping table;
the next ranges retain their own comprehension checkpoints. Dotted capital I maps to `0069 0307`,
while unchanged special-casing entries may legitimately appear in the full data. Identity entries are
not defects or normalization. The generator remains the sole table author.

`bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/unicode_case_mapping.t` passes 52 tests
in 13 seconds: pinned identity fields, direct lower/upper conversion, public compiled helper/receiver/
array forms for all 12 fixtures, and generated-source dependency declaration. The last check inspects
the emitted dependency string; it is not a newly executed fresh-process generated-carrier proof.
Rust and other backend native consumers are not rerun by this reading checkpoint. The July execution
counts in the evidence header remain historical. See [[unicode-17-case-contract-data]] for current
five-module regeneration proof.

## September 6 middle Perl table checkpoint

`.3.2.50` reconciles the complete `.31` reading of lines 1501–3000: 32,854 bytes,
SHA-256 `02b460974dd06064b0af0ea3ac7ff1164ffc53e2ee71c1721dd5a4f652c68f1f`.
The range finishes the lower map and begins the upper map; the upper-map tail and contextual-property
algorithm remain the next checkpoint. Full mappings such as sharp-s to `0053 0053` intentionally expand
one input scalar. They do not introduce locale tailoring or normalization. Current table, generator,
neutral contract, checker, and consumer bytes match the preceding checkpoint, whose five-module
regeneration, 12 neutral fixtures, and 52 Perl tests remain the retained proof. No second runtime run
or duplicate physical reading credit is claimed.
