# 0043 - Logical helpers are eager boolean values over one typed truthiness policy

- Date: 2026-07-16
- Status: accepted; backend rollout pending
- Tags: architecture, logical, truthiness, helpers, arity, actionir, generated-source, portability, cross-variant-parity

## Context

`FUTURE-PARITY-BACKLOG.5.2.0` measured five current implementations rather than choosing one host as the answer.
Perl has two mechanisms: conditions lower `and`/`or` to lazy host operators while direct logical value calls remain
raw/broken. Dart short-circuits helper arguments. Rust, Julia, and Lua evaluate helpers eagerly. Empty calls and
truth conversion differ further, including three profiles for scalar `"0"`, scalar `"false"`, and empty
aggregates. Generated execution faithfully reproduces each native backend, so emission is not the root cause.

ADR `0011` requires typed AST/IR ownership instead of host keyword leakage. ADR `0023` requires observable
backend identity. ADR `0029` establishes that host coercion is not a language contract, and ADR `0042` establishes
the reusable pattern of validating helper arity before eager once-only argument evaluation.

## Decision

1. `capability_conformance/logical_helper_contract.json` is the executable
   `linkedspec-logical-helper-v1` authority. Its independent checker validates semantics, deterministic fixtures,
   rollout topology, and representative drift mutations before any backend is admitted.
2. Logical helpers are ordinary eager value calls. After a valid call's arity is accepted, every argument evaluates
   exactly once from left to right. `and` and `or` do not skip decisive operands; `not` has only one valid operand.
3. `and` and `or` accept one or more positional arguments. `not` accepts exactly one. Zero-argument `and`/`or` and
   zero- or multi-argument `not` fail before evaluating any argument with neutral fields `code`, `helper_name`,
   `actual_arity`, and `expected_arity`. The code is `helper_arity_mismatch`.
4. Every valid helper returns a real boolean. `and` is true when every evaluated value is truthful; `or` is true
   when at least one is truthful; `not` negates its single value. A one-argument `and` or `or` is therefore an
   explicit boolean projection of that value.
5. Truthiness is typed and independent of host rules:
   - null is false;
   - booleans retain their value;
   - finite numbers are false exactly when numerically zero, including negative zero;
   - strings are false exactly when empty, so `"0"`, `"false"`, whitespace, and nonempty Unicode text are true;
   - arrays and harrays are false exactly when empty and true when they contain at least one item/entry;
   - a codeblock value is true without invoking it.
   The codeblock row is a value-kind rule and backend-unit obligation. Its neutral source fixture deliberately
   omits explicit `{|...| ... }` literals because those remain separately owned by `FUTURE-PARITY-BACKLOG.11`;
   this decision does not activate generic first-class codeblock syntax.
6. String truth does not perform numeric or boolean parsing. This keeps truthiness separate from ADR `0028` text
   rendering and ADR `0029` explicit numeric conversion. Aggregate truth inspects size, not host reference identity.
7. Compatible receiver chains consume the boolean helper result as an ordinary value. They do not receive an
   original decisive operand or host truth token.
8. Lazy controls remain a separate language mechanism. `if`, `switch`, and `while` use the same typed truthiness
   for their condition values but evaluate only the selected branch/body according to their control contract.
   Authors who need skipped side effects use a control, not `and`/`or`.
9. Typed truthiness must be shared by helper and condition execution inside each backend. No implementation may
   delegate the policy directly to Perl/Lua host truth, Rust string parsing, Dart collection behavior, Julia
   conversion, or generated host operators.
10. Native, reconstructed, emitted/generated, receiver, and primary projections must preserve the same values,
    effect order, and diagnostics. Backend rollout remains pending until `.5.2.2-.7`; recurring admission and
    public no-drift remain `.5.2.8-.9`.

## Consequences

- All five backends require some behavior repair. Dart already has the selected typed truth table but must become
  eager and reject empty calls. Julia already has eager evaluation and the selected truth table but must enforce
  arity. Rust must stop treating nonempty `"0"`/`"false"` as false. Lua must normalize string-zero and empty
  aggregates. Perl needs first-class typed logical ownership, eager lowering, arity checks, and typed truthiness.
- Existing programs that depend on helper short-circuiting, empty-call identity values, extra `not` operands,
  string parsing, or host-reference truth must migrate to explicit controls or predicates.
- `and()` is deliberately not assigned mathematical empty-product identity. Logical helpers require an authored
  condition, making accidental missing arguments a diagnostic while retaining one-argument boolean projection.
- Codeblocks are values at the truthiness boundary; testing one never invokes user code.
- Keeping the codeblock row out of the portable source fixture prevents logical normalization from silently
  absorbing the separately dependency-gated callable-codeblock program.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.5.2.1-.9`)
- Executable contract: `capability_conformance/logical_helper_contract.json`
- Typed AST doctrine: ADR `0011`; exact backend parity: ADR `0023`
- Numeric separation: ADR `0029`; eager/arity precedent: ADR `0042`
- Audit fact: `docs/knowledge/logical-helper-five-backend-audit.md`
