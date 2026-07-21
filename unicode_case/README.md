# LinkedSpec Unicode case data

LinkedSpec pins `lowercase` and `uppercase` to Unicode 17.0.0 full Default Case Conversion under ADR `0027`.
This directory holds the exact normative Unicode Character Database inputs used to generate the executable neutral
contract. Ordinary builds and tests are offline; they never fetch Unicode data or substitute host/runtime tables.

## Upstream inputs

| File | Official source | SHA-256 |
| --- | --- | --- |
| `UnicodeData.txt.gz` | `https://www.unicode.org/Public/17.0.0/ucd/UnicodeData.txt` | `2e1efc1dcb59c575eedf5ccae60f95229f706ee6d031835247d843c11d96470c` |
| `SpecialCasing.txt.gz` | `https://www.unicode.org/Public/17.0.0/ucd/SpecialCasing.txt` | `efc25faf19de21b92c1194c111c932e03d2a5eaf18194e33f1156e96de4c9588` |
| `DerivedCoreProperties.txt.gz` | `https://www.unicode.org/Public/17.0.0/ucd/DerivedCoreProperties.txt` | `24c7fed1195c482faaefd5c1e7eb821c5ee1fb6de07ecdbaa64b56a99da22c08` |
| `LICENSE.txt.gz` | `https://www.unicode.org/license.txt` | `e7a93b009565cfce55919a381437ac4db883e9da2126fa28b91d12732bc53d96` |

The table hashes cover the exact uncompressed official bytes. Files are stored with deterministic gzip headers so
the upstream trailing whitespace remains byte-exact without conflicting with repository text-whitespace policy.
They are redistributed under the Unicode Data Files and Software License in
`unicode_case/upstream/17.0.0/LICENSE.txt.gz`.

## Regeneration

```bash
python3 unicode_case/generate_unicode_case_contract.py
python3 tools/check_unicode_case_contract.py
```

The generator verifies every source hash and the two version-bearing headers before parsing. It combines simple
UnicodeData mappings with unconditional full SpecialCasing mappings, retains the only locale-independent contextual
rule (`Final_Sigma`), deliberately rejects changes to the locale-tailoring inventory, and derives merged `Cased` and
`Case_Ignorable` ranges. The same run writes the neutral JSON plus deterministic Perl, Rust, Dart, Julia, and Lua
modules. The checker regenerates all generated outputs into temporary owned storage,
byte-compares them, validates the neutral schema/counts/order/digest, and independently executes every fixture.

ADR `0051` reuses the same pinned `DerivedCoreProperties.txt` to define rule labels independently of host `\w`
tables. It extracts maximally merged Unicode 17.0.0 `XID_Continue` ranges, applies the same class at every label
position, and writes the neutral contract plus the Rust classifier:

```bash
python3 unicode_case/generate_unicode_rule_label_contract.py
python3 tools/check_unicode_rule_label_contract.py
```

Label identity remains the exact case- and normalization-sensitive scalar sequence; this generator performs no
normalization or case mapping. The same run also writes
`unicode_case/unicode_rule_label_regex_class.txt`: one metadata-bearing UTF-8 literal-range class for the
self-hosted grammar. Its endpoints encode the same 806 ranges without host `\w`, Unicode-property lookup, or
runtime-version dependence. The checker reconstructs that class independently, byte-compares it, proves every
fixture, and rejects any delimiter character that would require host-specific escaping. Canonical
`specs/spec.spec` consumption is the next task-tree slice; the generated artifact alone changes no grammar.

Do not manually edit `capability_conformance/unicode_case_contract.json`,
`perl/LinkedSpec/UnicodeCaseMapping.pm`, `rust/linkedspec-runtime/src/unicode_case_mapping.rs`,
`dart/lib/src/runtime/unicode_case_mapping.dart`, `julia/src/runtime/UnicodeCaseMapping.jl`,
`lua/src/linkedspec/unicode_case_mapping.lua`, `capability_conformance/unicode_rule_label_contract.json`, or
`rust/linkedspec-core/src/unicode_rule_label.rs`, or `unicode_case/unicode_rule_label_regex_class.txt`. A Unicode
upgrade requires a new ADR, reviewed source hashes, regenerated artifacts, and explicit fixture-delta review.
