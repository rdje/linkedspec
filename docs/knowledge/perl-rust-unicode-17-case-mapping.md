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
date: 2026-09-07
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

## September 6 final Perl table checkpoint

`.3.2.51` reconciles all 835 previously read lines 3001–3835 (17,404 bytes; SHA-256
`319a14861db1ff096bb78caecd6bc307fd1a0e38c2bd86680adefc64d8e8b31f`). The upper-map tail is followed
by 158 Cased and 464 Case_Ignorable ranges, then binary-search membership and the scalar evaluator.
Final Sigma examines the original input, skips Case_Ignorable on either side, requires a preceding
Cased scalar, and rejects the final form when a following Cased scalar remains. It applies only to
lowercasing capital sigma. Other scalars use full mapping sequences or retain identity; output is
packed without normalization. This is casing, not a general word-boundary or case-folding algorithm.

All 12 neutral fixtures, including the six sigma-context controls and combining-output cases, were
reconciled against this evaluator. Complete physical coverage stays credited to `.31`; the three
comprehension checkpoints now cover all 3,835 lines / 82,331 bytes without gaps. The unchanged
five-module regeneration and Perl52 proof from `.3.2.49` remains current retained evidence. No
new peer-runtime execution, generated-source execution, or altered input-type contract is claimed.

## September 7 first Rust mapping checkpoint

`SESSION-STARTUP-READING.3.3.38` reads Rust unicode_case_mapping.rs 1–206: 5,313 bytes,
SHA-256 `00c0ec0fcd97c4d6208ab8fe99957565274fa5e0056af7f120be27b869055e57`.
The generated header pins linkedspec-unicode-case-v1, Unicode17.0.0 and logical digest
5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae. The opening sorted lower mappings include
ASCII/Latin, dotted-I expansion to 0069 0307 and intentional identity entries. The generator remains sole author;
the rest of the Rust mappings and evaluator remain subsequent physical reading.

Fresh managed Unicode checking regenerates the contract and all five backend modules byte-identically and
passes all twelve independent neutral fixtures: 1,563 lower/1,581 upper mappings and 158/464 property ranges.
This is generation and neutral-evaluator proof, not a new six-runtime execution claim.

## September 7 Rust lower-map completion

`SESSION-STARTUP-READING.3.3.39` reads lines 207–1706 completely: 1,500 lines / 38,103 bytes,
SHA-256 `285db242fb8cd77506627568d96f91fd09a5ae4fefad69426331f730f4ea928d`,
with both the range and full file identical to the reading baseline. This completes the lower mapping table
through supplementary-plane entries and opens the upper table through U+019A. Lowercase identity entries
for ligatures and Greek special-casing records are intentional. The upper prefix includes full sharp-s
expansion to 0053 0053 and U+0149 to 02BC 004E; the maps are not mutual inverses.
The contextual evaluator is still outside this read range. Fresh managed regeneration and all twelve neutral
fixtures pass with the unchanged 1563/1581/158/464 counts; this adds no native runtime execution claim.
