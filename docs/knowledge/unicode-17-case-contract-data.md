---
id: unicode-17-case-contract-data
title: LinkedSpec has an offline generated Unicode 17 full-casing contract
answers:
  - where is the LinkedSpec Unicode casing contract
  - which Unicode data files generate lowercase uppercase
  - what hashes pin LinkedSpec Unicode 17 casing
  - how many Unicode lower upper mappings does LinkedSpec use
  - how is Final Sigma implemented portably
  - how do I regenerate Unicode casing tables
  - how does CI detect Unicode casing drift
  - does Unicode casing regeneration require network access
  - which backend casing modules does the Unicode generator write
date: 2026-07-12
status: current
tags: [unicode, casing, generation, contract, fixtures, ci, portability]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.2.1 adds deterministic gzip-preserved official Unicode 17.0.0 UnicodeData.txt, SpecialCasing.txt, DerivedCoreProperties.txt, and license inputs with exact uncompressed SHA-256 values; unicode_case/generate_unicode_case_contract.py; capability_conformance/unicode_case_contract.json; tools/check_unicode_case_contract.py; and the tools/run_ci_local.sh contract step. The generated contract has 1,563 lower and 1,581 upper mappings, 158 Cased and 464 Case_Ignorable merged ranges, one Final_Sigma rule, data digest 5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae, and 12 fixtures. `.4.3.2.1.2.2` extends generation and byte comparison to Perl/Rust backend modules. The checker regenerates byte-identically and independently executes all fixtures offline."
reverify: "python3 tools/check_unicode_case_contract.py && bash tools/run_ci_local.sh"
---

## Fact

`capability_conformance/unicode_case_contract.json` is LinkedSpec's neutral executable casing data. It is generated
from exact Unicode 17.0.0 inputs stored under `unicode_case/upstream/17.0.0/`; the gzip layer is deterministic and
lossless, and all published hashes cover the decompressed official bytes.

The contract contains full lower/upper mapping sequences, merged `Cased` and `Case_Ignorable` ranges, the sole
locale-independent contextual `Final_Sigma` rule, and 12 expected-value fixtures. Fixtures cover ordinary identity,
ASCII, sharp-s and ligature expansion, dotted-I combining output, supplementary Deseret scalars, contextual sigma
with case-ignorable characters, and the explicit no-normalization policy.

`unicode_case/generate_unicode_case_contract.py` refuses source hash/version or conditional-rule inventory drift.
`tools/check_unicode_case_contract.py` regenerates into temporary owned storage, byte-compares the checked contract
and generated Perl/Rust modules, validates schema/counts/order/scalar values/logical digest, and executes the fixtures
through an independent evaluator. `tools/run_ci_local.sh` runs that checker before the other executable contracts.
No ordinary check needs network access or a host Unicode library.

Related facts: [[perl-rust-unicode-17-case-mapping]], [[dart-julia-unicode-17-case-mapping]], [[unicode-case-mapping-cross-backend-gap]],
[[user-observable-backend-cli-parity-contract]].
