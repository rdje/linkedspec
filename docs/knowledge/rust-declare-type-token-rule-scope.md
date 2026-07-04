---
id: rust-declare-type-token-rule-scope
title: "Rust declaration semantics: `declare(array, items)` must treat the first bare arg as the literal declaration type token, not as a runtime variable; declared working variables are scoped per rule invocation, while undeclared mutations remain shared. This fixed TOP-RULE-AS-NORMAL.3.2 recursive `sexpr` value leakage."
answers:
  - "why did Rust recursive sexpr leak child values into the parent accumulator"
  - "why did declare(array, items) do nothing in Rust"
  - "how does Rust declare(array, name) resolve its type token"
  - "where are Rust declared working variables scoped"
  - "what fixed TOP-RULE-AS-NORMAL.3.2"
  - "does Rust child rule execution isolate all variable stores"
date: 2026-07-04
status: confirmed
tags: [rust, runtime, declare, recursion, top-rule, TOP-RULE-AS-NORMAL, oracle]
evidence: "TOP-RULE-AS-NORMAL.3.2 reproduced Rust recursive `sexpr` value leakage after RUST-PARITY closed the broader recursive-grammar blocker. The helper call `declare(array, items)` is parsed as raw positional args `Variable(\"array\")`, `Variable(\"items\")`. Rust previously evaluated `args[0]` and got an undefined runtime variable value (`\"\"`), so the declaration type was empty and no declaration happened. Recursive frames then auto-created/mutated the same `items` array in shared RuntimeContext stores. The fix in rust/linkedspec-runtime/src/engine.rs resolves a raw first positional `Expr::Variable { name }` as the literal type token (`scalar`/`array`/`hash`) before falling back to evaluated values. RuntimeContext records the pre-declaration scalar/array/hash/bare-kind snapshot for declared names, and Engine/GeneratedPlanExecutor wrap rule execution with enter_rule_variable_scope/exit_rule_variable_scope. User functions suspend rule declaration tracking because they already swap whole variable stores. Undeclared child mutations stay caller-visible by design. Focused top_rule_as_normal integration tests pass; corpus_oracle passes over 91 fixtures including top_rule_body_recursion_sexpr, top_rule_lx_recursion_nested, and top_rule_lx_recursion_sequence."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test top_rule_as_normal -- --nocapture && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

# Rust `declare(...)` Type Tokens and Rule-Local Declarations

**Confirmed 2026-07-04** (`TOP-RULE-AS-NORMAL.3.2`).

The recursive `sexpr` value failure was not fixed by isolating every child rule
call. That would have changed existing Rust behavior: undeclared child mutations
are still caller-visible.

The actual defect was narrower:

- `declare(array, items)` arrives as a helper call whose first raw argument is the
  variable syntax `array`.
- Rust evaluated that first argument as a runtime variable, so it became `""`.
- The declaration helper therefore did not recognize `array` as a type and did
  not declare `items`.
- Recursive rule frames then mutated the same auto-existing `items` array, so a
  nested child accumulator leaked into the parent.

The durable rule is:

- In `declare(...)`, the first bare positional argument is a literal declaration
  type token: `scalar`, `array`, or `hash`.
- Declared working variables are local to the current rule invocation. The Rust
  runtime snapshots any previous scalar/array/hash/bare-kind binding on first
  declaration in that invocation and restores it on rule exit.
- Undeclared variables keep the existing shared working-store behavior.
- User functions are excluded from rule declaration tracking because they already
  run with a function-local variable store.

## Links

- Tree: [[TOP-RULE-AS-NORMAL]] (`.3.2`)
- Related: [[top-rule-recursion-forward-progress-guard]], [[rust-perl-output-oracle]]
- Files: `rust/linkedspec-runtime/src/engine.rs`,
  `rust/linkedspec-runtime/src/runtime.rs`,
  `rust/linkedspec-runtime/tests/integration_test.rs`,
  `tools/gen_oracle_corpus.pl`,
  `rust/linkedspec-runtime/tests/corpus/`
