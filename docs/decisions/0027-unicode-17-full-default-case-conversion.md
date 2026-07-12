# 0027 - Lowercase and uppercase use pinned Unicode 17 full Default Case Conversion

- Date: 2026-07-12
- Status: accepted
- Tags: architecture, unicode, casing, generation, portability, cross-variant-parity

## Context

ADR `0023` requires exact user-observable behavior across every LinkedSpec variant. Direct probes show that host
case APIs violate that contract: Perl/Rust, Dart, and Julia disagree for sharp-s, dotted capital I, and ligatures;
PUC Lua and LuaJIT provide no portable Unicode casing API. UTF-8 versus UTF-16 storage does not resolve the semantic
question. The DSL must own the Unicode operation rather than inherit a host runtime's Unicode version or tailoring.

The director authorized the signoff, state-of-the-art route and delegated the concrete policy to engineering.
Unicode 17.0.0 Section 3.13 defines Default Case Conversion over full mappings from `UnicodeData.txt` plus
`SpecialCasing.txt`, including context-dependent rules. The standard treats simple one-codepoint conversion as a
legacy/common variant and locale-specific behavior as optional tailoring.

## Decision

1. LinkedSpec `lowercase` and `uppercase` implement Unicode 17.0.0 Default Case Conversion, rules R1 and R2.
2. Mappings are **full**, so one input scalar may yield multiple output scalars. Default examples include
   `uppercase("ß") == "SS"`, `lowercase("İ") == "i\u{0307}"`, and `uppercase("ﬃ") == "FFI"`.
3. Conversion is locale-independent. Locale-tagged Turkish, Azeri, Lithuanian, or other tailorings are excluded.
   A future locale-aware API would need a distinct task, signature, contract, and fixtures.
4. Standard context-dependent default rules are included. In particular, lowercasing implements `Final_Sigma`
   using the Unicode `Cased` and `Case_Ignorable` properties from `DerivedCoreProperties.txt`.
5. Conversion does not normalize before or after mapping. Canonically equivalent sequences remain distinct unless
   a separately specified normalization helper is applied. Combining output such as dotted-I is preserved exactly.
6. Unicode scalar text is the semantic input/output. UTF-8, UTF-16, UTF-32, and host string layouts are boundary
   encodings only. Existing strict decoding rules remain unchanged.
7. Normative inputs are the versioned Unicode 17.0.0 `UnicodeData.txt`, `SpecialCasing.txt`, and
   `DerivedCoreProperties.txt` files. Their source URLs, byte hashes, license, version headers, and generated counts
   are tracked. Ordinary checks are offline and never silently substitute newer system data.
8. One deterministic repository generator produces a neutral machine-readable contract and backend-native tables.
   Generated files carry the contract version and source digest. A gate regenerates into temporary owned storage
   and byte-compares outputs, so manual edits or host-version drift fail closed.
9. Every backend evaluates the same neutral fixture in function and receiver forms. Host casing APIs may be used
   only if they are proven to implement the pinned contract exactly; otherwise generated mappings are authoritative.
10. Null, aggregate, scalar-to-text, and error boundaries are not redefined here. Those retain their existing owners,
    including `LUA-BACKEND-PARITY.4.3.2.1.3` for cross-variant scalar-to-text normalization.

## Consequences

- Results are stable across OS/runtime upgrades and identical on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.
- Full expansions and contextual final sigma are intentional, testable language behavior rather than incidental host
  features. Uppercasing sharp-s to capital sharp-s is a locale/product tailoring and is not the default DSL result.
- Generated tables add repository size and a regeneration tool, but remove runtime dependencies on ICU, utf8proc,
  locale state, or host Unicode release cadence.
- Upgrading Unicode becomes an explicit new ADR/contract version with regenerated artifacts and reviewed fixture
  deltas; it cannot happen through a toolchain update alone.

## Links

- Task owner: `LUA-BACKEND-PARITY.4.3.2.1.2`
- Exact public parity: ADR `0023`
- Unicode versus UTF encoding boundary: ADRs `0025` and `0026`
- Unicode 17.0.0 Section 3.13: <https://www.unicode.org/versions/Unicode17.0.0/core-spec/chapter-3/>
- Unicode 17.0.0 case data model: <https://www.unicode.org/versions/Unicode17.0.0/core-spec/chapter-4/>
