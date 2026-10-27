---
id: rust-logical-helper-neutral-runtime
title: Rust logical helpers and lazy controls share one typed truthiness and arity boundary
answers:
  - "does Rust support and or not receiver methods"
  - "why can Rust logical methods after with require a result kind guard"
  - "where is Rust logical truthiness implemented"
  - "are string zero and string false true in Rust LinkedSpec"
  - "does Rust validate logical helper arity before operand effects"
  - "are Rust logical helpers eager or short circuit"
  - "do Rust logical helpers and lazy controls share truthiness"
  - "which Rust generated roles prove the logical helper contract"
  - "what fields are in a Rust logical arity diagnostic"
  - "does Rust logical parity activate explicit codeblock literals"
  - "does the current Rust logical consumer execute the codeblock truth row"
date: 2026-10-27
status: current
tags: [rust, logical, truthiness, arity, runtime, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "TYPE23.3.17.2 public producer/shared/error/rejected-effects native-restored-plan and direct neutral/default focused proof. Full prior July/September record, reading/replay and emitted admission details at Gita56732abcbf2af5968510246e23472c49d2fcadf for this path."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test logical_result_receivers --test default_selected_receivers --test logical_receiver_methods"

---

RuntimeValue::as_bool owns typed truthiness for helpers and if/while conditions:
null/false/zero/empty String/Array/Hash are false; other finite numbers, every
nonempty String including "0"/"false", and nonempty aggregates are true. Scalar
text and numeric parsing stay separate; switch compares coerced case Strings.
and/or/not validate positional arity before operands, then evaluate once left
to right and return actual Bool. Native diagnostics retain helper/actual/expected
arity and rule; generated errors preserve deterministic tokens. Unknown calls
try bound codeblocks before their ordinary warning/undef behavior; invalid
logical arity still precedes unknown or effectful operands.

Logical17.2 independently confirms producer/strict numeric-null/nested/LRC,
shared valid bridges/default/source kinds and typed source errors before code.
Only logical->sorted yields Array[] instead of clean scalar null. engine.rs
now evaluates known logical call receivers once and enters existing selected
scalar-result dispatch after dedicated trailing-block normalization. No typed
truthiness/free/numeric/helper-error change. Six focused tests across four new
native/restored/plan producer/shared/error/rejected-effect controls, direct
defaults and the actual named neutral logical consumer pass with offline
compilation/rustfmt. All three split bridgesX, Bool/false kinds, copied defaults,
LRC/SC snapshots and skipped incompatible consumer operands remain. Current
proof is in-process generated-plan, not fresh standalone emitted Rust.

A dependent reference check catches Perl17.1 dropping eager logical source
side effects on incompatible consumer rejection: public probe gives[null,0]
versus nested free[[],1]. New retained logical_rejected_consumer_effects fixtures
pass Rust LR/LRC/S/null/no-consumer-operand controls. Perl17.1.1 also repairs
that regression with24 focused native/fresh checks before Dart17.3. No other backend failure inferred.

Historical July logical admission predates inert RuntimeValue::Codeblock;
construction/invocation now have [[rust-callable-codeblock-literal-state]]. The
old neutral consumer still skips its model-only codeblock row and asserts that
it is the sole skipped row. That consumer's standalone workspace and September
source-reading facts remain at the exact Git pointer above; current narrow
checks do not establish its codeblock coverage or repair startup55 number loss.

Related: [[logical-helper-neutral-contract]], [[cross-backend-condition-truthiness-drift]].

## Ordinary logical receiver methods, October27

TYPE23.2 adds and/or/not to generic receiver/scalar-result roles and preflights
and/or one-plus RHS/not zero before effects. Source/RHS staging and typed free
truth/Bool/error policy stay. Intake free producer/source-error controls pass,
while method routes omit the source or run invalid/consumer effects. Role repair
isolates a scoped with-loop tail gap: correct Bool/restored value still permits
Array operands. Track logical prefixes there for actual kind rejection and scalar
copy; explicit Array/Hash fallback can still copy, and reduction-only copy policy
stays unchanged. Seven new native/restored/in-process-plan plus four direct result
tests pass with offline compilation/rustfmt and exact generated source-error tokens.
No new callable/deferred/context/serialized model or standalone emitted proof.
Full method/domain/context/portable admission/canonical selection remains23.4.
