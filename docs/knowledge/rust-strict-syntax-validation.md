---
id: rust-strict-syntax-validation
title: The Rust variant has a strict_syntax validation mode (validate_with_options(spec, strict_syntax)); strict promotes the unused-rule warning to a hard error (undefined refs are already fatal in every mode), and the top rule is NOT exempt from the unused check
answers:
  - "does the Rust variant have a strict_syntax validation mode"
  - "how do I run strict validation in the Rust variant"
  - "what does strict_syntax do in the Rust validator"
  - "is the top rule flagged as unused in strict mode"
  - "why does the Rust validator reject undefined rule references by default"
  - "what is the difference between validate and validate_with_options in Rust"
  - "does strict_syntax reject unused rules in the Rust variant"
date: 2026-06-16
status: confirmed
tags: [rust, validation, strict_syntax, RUST-PARITY]
evidence: "RUST-PARITY.6 (2026-06-16): rust/linkedspec-core/src/validation.rs adds validate_with_options(spec, strict_syntax: bool) + check_unused_rules; validate(spec) = validate_with_options(spec, false). Perl reference: perl/LinkedSpec/Validation.pm validate_dsl_syntax(..., strict_syntax => 1), lines ~705-741. Semantics verified empirically (Top:: -> Child strict => 'Unused rule(s): Top'; Top:: -> Ghost strict => 'Undefined rule reference(s): Ghost'). 237/237 tests green (233 baseline + 4)."
reverify: "cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'fn validate_with_options\\|fn check_unused_rules\\|strict_syntax' linkedspec-core/src/validation.rs"
---

# Rust Variant: strict_syntax Validation Mode

**Confirmed 2026-06-16 (RUST-PARITY.6).** Closes the audit's Gap 4 — the Rust validator
had 6 hard checks but no strict mode. The Perl reference's `validate_dsl_syntax(...,
strict_syntax => 1)` (`perl/LinkedSpec/Validation.pm` ~705–741) emits two reference
*warnings* and `strict_syntax` promotes both to hard errors; this leaf brings the Rust
backend to parity.

## API

- `validate(spec)` — the default, non-strict pass (6 checks). Unchanged; every existing
  call site keeps working.
- `validate_with_options(spec, strict_syntax: bool)` — the same 6 checks, plus, when
  `strict_syntax` is true, `check_unused_rules`. `validate(spec) == validate_with_options(spec, false)`.

## The two reference warnings (and what strict does)

- **Unused** = `defined − used` (a rule defined but never referenced by any `->`/`=>`
  edge). Strict promotes this to a hard error (`check_unused_rules`). **The top rule is
  NOT exempt** — `Top:: -> Child` (with `Child` defined, `Top` referenced by nothing)
  fails strict with `"unused rule(s) in strict mode: Top"`. Verified empirically against
  the Perl reference (which fails the same case with "Unused rule(s): Top").
- **Undefined** = `used − defined` (an edge target that no rule defines). The Perl
  reference only *warns* on this by default and makes it fatal under strict. **This
  backend makes it fatal in every mode** via `check_edge_targets` — a deliberate,
  pre-existing divergence (the Rust default is stricter than the reference default). It is
  left as-is (relaxing it would break the landed `validate_rejects_undefined_target` test
  and a deliberate Rust contract).

## Ordering

`check_edge_targets` (undefined) runs before the strict `check_unused_rules`, so the Perl
reference's "undefined reported before unused" order is preserved, and strict mode's only
*new* observable behavior in this backend is the unused-rule rejection.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.6`)
- Files: `rust/linkedspec-core/src/validation.rs`, `perl/LinkedSpec/Validation.pm`,
  `docs/linkedspec-book/src/compiler/pipeline-overview.md` (documents the strict contract)
