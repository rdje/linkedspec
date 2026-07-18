---
id: rust-root-rule-selection-preflight
title: "Rust preserves authored root identity but markerless validation and route-local selection block full precedence"
answers:
  - "where does Rust parse and preserve Rule:: identity"
  - "why does Rust reject a markerless spec"
  - "which Rust root selection variants already pass"
  - "does Rust --top-rule override Rule::"
  - "how does Rust select the first authored marker"
  - "does Rust CompiledSpec JSON preserve rule order and is_top"
  - "does the Rust descriptor preserve definition order and is_top"
  - "can Rust generated source accept an explicit entry rule"
  - "what diagnostic does Rust return for an unknown top rule"
  - "does root selection change Rust strict unused rules"
  - "why is the Rust local gate currently 64 of 65"
  - "which Rust leaves own root selection implementation"
  - "is staged parser registry top_rule part of spec root selection"
date: 2026-07-18
status: current pre-implementation map
tags: [rust, root-rule, top-rule, validation, compiled-spec, descriptor, generated-source, trace, diagnostics, cli, FUTURE-PARITY-BACKLOG]
evidence: "At clean base 7029624d, the full shared primary runner passes Rust 64/65 with POSIXLY_CORRECT unset and set. Explicit ordinary selection, first-authored-marker default, unknown-selector failure, request trace, and every unrelated case pass; only success_markerless_first_authored_rule fails at compile validation with exit 1 and `linkedspec: parser compilation failed`. `parser.rs` preserves source order and `is_top = colon == \"::\"`; compiler, ordered `Vec<CompiledRule>`, serde round trip, descriptor `definition_order`, and per-rule `is_top` retain that identity. `validation.rs::check_top_rule_exists` rejects markerless and zero-rule sources. `SpecFile::top_rule` and `CompiledSpec::top_rule` return only the first marked row. Native direct `ExecutionOptions.entry_rule` already overrides markers and rejects unknown labels before rule execution, but uses current `rule_lookup` diagnostics; legacy/default and every generated-plan path call marker-only `top_rule`. Emitted v2 source embeds ordered CompiledSpec JSON, so it has enough authored state, but its execute/parse/traced APIs expose no selector. Strict unused remains declared labels minus authored edge references. The unrelated staged parser registry `top_rule` is parse-job grammar identity and is outside this contract. Safe rollout: .2.1 validation/core resolver/native diagnostics, .2.2 loaded/serialized/generated/emitted/descriptor/trace convergence, .2.3 topology-checked 65-case admission."
reverify: "cargo build --manifest-path rust/Cargo.toml -p linkedspec-runtime --bin linkedspec-rust; PERL5LIB= perl tools/run_cli_conformance.pl --display-command linkedspec-rust -- /absolute/path/to/rust/target/debug/linkedspec-rust; POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl --display-command linkedspec-rust -- /absolute/path/to/rust/target/debug/linkedspec-rust"
---

# Rust root-selection seam map

Rust already retains the source facts required by `linkedspec-root-rule-selection-v1`. The parser appends rules in
definition order and records `Rule::` as `RuleHeader.is_top = true`. Compilation copies that bit to each
`CompiledRule`; `CompiledSpec.rules` is an ordered vector whose serde representation survives reconstruction.
The outward descriptor publishes the same order as `meta.definition_order` and the authored bit as rule metadata
`is_top`. Generated-source v2 embeds the ordinary serialized `CompiledSpec`, so its artifact also retains both
facts without widening the deliberately minimal `{label,family}` generated plan.

The first divergence occurs before execution. `validation::check_top_rule_exists` requires at least one authored
marker, so a markerless one-or-more-rule source is rejected with `no top rule found: at least one rule must use
'::' (double colon)`. The same check currently owns zero-rule failure. After validation, both
`SpecFile::top_rule()` and `CompiledSpec::top_rule()` scan only for the first `is_top` row; neither falls back to
the first declared rule.

Native direct execution is partially ahead of that default path. `ExecutionOptions.entry_rule` lets
`Engine::execute_value*` select any declared rule, so an ordinary `Alternate` correctly overrides two authored
markers. A missing explicit label fails before `execute_rule`, but its structured diagnostic is the existing
`rule_lookup` stage with no portable `entry_rule_not_found` code. Omitted selection and the legacy accumulator
entrypoint use `CompiledSpec::top_rule()` directly. Generated direct, compatibility, diagnostic, and traced routes
also call marker-only generated-plan entrypoints and expose no per-invocation selector.

The exact shared primary measurement at base `7029624d` is 64/65 in both option environments. The explicit
selector case returns `"alternate"`, the earlier-ordinary/two-marker case returns `"marked"`, and the missing
selector case retains exit 1 plus `linkedspec: parser invocation failed`. Only the markerless case fails, during
compilation, with empty stdout and `linkedspec: parser compilation failed\n` instead of `"first"\n`. The full
matrix proves every other help, usage, UTF-8, execution, failure, and trace byte remains green.

Strict-unused is not a root resolver. `check_unused_rules` still computes declared labels minus labels named by
authored edges; it explicitly does not exempt a marked top rule. Entry selection must add neither a reference nor
an exemption. The `top_rule` fields in `staged_parser_registry.rs` and function-body parse jobs identify the entry
production of a different staged grammar (`action_block`); changing them would be an unrelated and incorrect
scope expansion.

The dependency-safe implementation order is therefore fixed:

1. `.2.1` replaces marker-required validation with one-or-more-rule validation, introduces one ordered resolver
   over compiled declaration state, routes native default/explicit execution through it, publishes contract
   identity, and makes zero-rule/unknown-selector diagnostics exact without changing authored bits or strictness.
2. `.2.2` proves loaded and serialized/reconstructed state reuse that resolver; adds compatibility-preserving
   generated/emitted selector entrypoints; aligns direct/traced/diagnostic attribution with the effective label;
   and locks existing descriptor order/`is_top` plus generated v2 stale-format rejection.
3. `.2.3` adds one topology-checked Rust admission consumer, advances only the Rust rollout row, and requires the
   complete focused Rust gate plus exact 65/65 primary bytes in both environments before closing parent `.2`.

Related: [[root-rule-selection-precedence]], [[rust-native-direct-value-execution]],
[[rust-outward-compiled-descriptor-projection]], [[rust-generated-source-v2-rule-local-cursor]],
[[rust-canonical-primary-cli-trace]], and [[rust-local-verification-gate]].
