# 0029 - Scalar numeric helpers use one strict portable contract

- Date: 2026-07-12
- Status: accepted
- Tags: architecture, scalar, numeric, helpers, portability, cross-variant-parity

## Context

ADR `0023` requires exact user-observable behavior across every LinkedSpec backend, but scalar numeric helpers were
copied from host conversions and arithmetic. Perl/Rust/Dart/Julia disagree on typed booleans, invalid comparison
and unary results, extra operands, accepted numeric strings, and signed modulo. Happy-path helper examples and the
239-name inventory did not exercise these semantic edges, so adding Lua could only copy one accidental variant.

## Decision

1. `capability_conformance/scalar_numeric_contract.json` is the executable
   `linkedspec-scalar-numeric-v1` contract. `tools/check_scalar_numeric_contract.py` independently validates its
   schema, evaluates every case, and regenerates its `.spec` source.
2. Numeric inputs are finite JSON numbers or untrimmed decimal strings matching
   `-?(?:digits(?:.digits)?|.digits)`. Leading zeros are accepted. Plus signs, exponent, hexadecimal, surrounding
   whitespace, trailing decimal points, malformed text, and non-finite results are invalid.
3. Booleans, null, arrays, harrays, and codeblocks are not numeric inputs. Scalar-to-text conversion from ADR
   `0028` is a separate operation and does not make booleans numeric.
4. `num_add`, `num_mul`, scalar `num_min`, and scalar `num_max` take at least two operands. `num_sub`, `num_div`,
   `num_mod`, and comparisons take exactly two; unary helpers exactly one; clamp exactly three. Wrong arity is null.
   Array-form min/max and the aggregate reducers remain separately owned.
5. Every invalid input/result returns null, including invalid comparisons. Valid comparisons return numeric `1` or
   `0`, preserving the established flow/value convention.
6. Rounding is nearest integer with exact halves away from zero. Integer modulo uses the Euclidean/floor remainder
   `a - floor(a / b) * b`, so a nonzero result has the divisor's sign. Fractional operands and zero divisors are
   invalid. Clamp with inverted bounds is invalid.
7. Negative-zero results normalize to numeric zero. No backend may delegate these decisions to host parsing,
   rounding, remainder, truthiness, or display APIs without an adapter proving the same results.

## Consequences

- Perl and Rust require explicit invalid/null and signed-modulo repairs; Dart and Julia require strict parsing and
  exact-arity/signed-modulo alignment. Lua implements the settled policy only after those admitted pairs agree.
- Existing calls that relied on boolean arithmetic, invalid comparison as false, broad host numeric strings, extra
  fixed-arity operands, or truncating signed remainder become null or the portable floor remainder.
- The contract is scalar-only. Aggregate reducers, aliases/symbol callees, and receiver-chain terminal behavior
  remain in their existing downstream task-tree leaves.

## Links

- Task owner: `LUA-BACKEND-PARITY.4.3.3.1.1`
- Exact backend parity: ADR `0023`
- Scalar-to-text separation: ADR `0028`
- Knowledge card: `docs/knowledge/cross-backend-scalar-numeric-drift.md`
