# 0028 - Scalar-to-text coercion is typed and portable

- Date: 2026-07-12
- Status: accepted
- Tags: architecture, scalar, string, coercion, portability, cross-variant-parity

## Context

ADR `0023` requires exact user-observable behavior across every LinkedSpec variant, but `cat` inherited incompatible
host conversion rules. Perl rejected undefined values and references; Rust, Dart, Julia, and Lua could erase null
and containers to empty fragments. Perl/Rust and Dart/Julia disagreed on boolean and integral-looking decimal text.
The portable language also has four value kinds, so aggregate and codeblock values need an explicit disposition.

## Decision

1. `capability_conformance/scalar_text_contract.json` is the executable `linkedspec-scalar-text-v1` contract.
2. Strings pass through unchanged.
3. Booleans convert to `1` and `0`.
4. Finite numbers use shortest stable decimal text. Negative zero is `0`; integral-looking decimals omit `.0`;
   nonintegral values retain their necessary fractional text.
5. Null, array, harray, and codeblock values are not scalar text. If any `cat` fragment is non-text, the complete
   result is null; non-text fragments are never silently skipped or replaced by empty strings.
6. The codeblock row is a value-kind rule, not an early implementation of explicit final-codeblock call syntax.
   `FUTURE-PARITY-BACKLOG.11.1` still owns that syntax, callable-signature equivalence, and `with` disposition.
7. `concat` remains retired. This parity repair does not restore it as an alias.

## Consequences

- Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT execute one neutral `cat` fixture with identical values and nulls.
- Hosts need an explicit scalar conversion seam instead of relying on interpolation, generic display conversion, or
  empty fallback.
- Existing specs that depended on silently dropping null/container fragments now receive null and must make an
  explicit typed choice before concatenation.
- Non-finite numeric values remain outside the source-literal contract; a later task must specify them before they
  can become portable scalar text.

## Links

- Task owner: `LUA-BACKEND-PARITY.4.3.2.1.3`
- Exact public parity: ADR `0023`
- Four value kinds and generic final-codeblock follow-up: `FUTURE-PARITY-BACKLOG.11.1`
- Knowledge card: `docs/knowledge/scalar-to-text-coercion-cross-backend-gap.md`
