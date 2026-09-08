---
id: rust-retv-propagation
title: Rust engine propagates child-return (retv) via a per-invocation return channel on RuntimeContext; execute_rule returns the rule's value and set_retv is called after -> / => dispatch
answers:
  - "how does the Rust engine propagate retv"
  - "how does a parent read a child rule's return value in Rust"
  - "why did scalar(retv) resolve to undef in the Rust runtime"
  - "what does execute_rule return in the Rust engine"
  - "how does return(expr) work in the Rust runtime vs the accumulator"
  - "how does call(child) resolve a rule name in Rust"
  - "does child return leak into the parent accumulator in Rust"
  - "how does Rust contain child accumulator pushes"
date: 2026-09-08
status: confirmed
tags: [rust, engine, runtime, retv, dispatch, RUST-PARITY]
evidence: "RUST-PARITY.5.1 (2026-06-16): rust/linkedspec-runtime/src/engine.rs execute_rule + acode/bcode dispatch + return/call helpers; rust/linkedspec-runtime/src/runtime.rs return_value channel + set_retv. Matches book appendix/runtime-semantics.md §3.3/§5.4/§6.1. 186/186 tests green. RUST-PARITY.7.5.2 (2026-07-02): execute_child_rule contains child accumulator pushes after dispatch/call while preserving child return values for retv/call results; focused rust_parity_7_5_2 and retv_5_1 tests pass."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test integration_test retv_5_1 -- --nocapture && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test integration_test top_rule_as_normal_3_2 -- --nocapture"
---

# Rust Engine: Child-Return (`retv`) Propagation

**Confirmed 2026-06-16 (RUST-PARITY.5.1); updated 2026-07-02
(RUST-PARITY.7.5.2).** Fixes the audit's top BLOCKER: before `.5.1`, `scalar(retv)`
resolved to undef after `->`/`=>` dispatch, so nearly every grammar produced null/wrong
output. `.7.5.2` then corrected the child-invocation accumulator boundary exposed by
Lispish.

## The model

The Rust runtime uses **one shared `RuntimeContext`**, with selective rule-variable
snapshot/restore and separate function-local stores. The June single-map/no-rule-scope
description predates those boundaries; see [[rust-declare-type-token-rule-scope]].
The per-invocation return channel is a separate mechanism. `execute()` returns
the top-level accumulator. A rule's own `return(expr)` records a return channel value and
pushes to the current invocation accumulator; child invocation boundaries now remove those
child pushes from the parent accumulator after dispatch/call.

## How `retv` works now

1. `RuntimeContext` has a per-invocation channel `return_value: Option<RuntimeValue>` with
   `set_return_value` / `take_return_value` / `restore_return_value`.
2. `execute_rule` returns `Result<RuntimeValue, String>` (the rule's own return value). It
   `take`s the channel on entry (saving the **caller's** pending return) and reads + restores
   it on exit, so each invocation reports exactly its own last `return(...)`
   (Runtime Semantics §5.4) and nested child dispatch is transparent across stack frames.
3. After both `->` (acode) and `=>` (bcode) dispatch, the engine calls
   `ctx.set_retv(child_retv)`, so the parent's attached code / `LE` / `E` read the child's
   result via `retv` (the June `scalar(retv)` spelling is historical).
4. `return(expr)` records the channel **and** still pushes the current invocation
   accumulator. `execute()` still returns `ctx.accumulator`, **not** the channel.
5. Child dispatch and `call(child)` route through `execute_child_rule`, which snapshots the
   accumulator length, runs the child, then truncates the accumulator back to the parent
   length. The child's return value is still returned and stored in `retv`; only the child's
   accumulator events are contained.

## Gotcha: `call(child)` rule-name resolution

`call(child)` evaluates to the child's return value. The June reference used
`assign(s(retv), call(child))`; that selector spelling is historical, not current authoring syntax.
The rule name comes from the **raw AST argument** (`resolve_rule_name`, mirroring
`resolve_array_target`). Evaluating the bare `RuleName` argument as an ordinary variable
would yield undef; resolving its authored name allows `call(RuleName)` to dispatch the rule.

## Historical scope limit and current boundary

The June implementation described shared stores and deferred rule scope. Subsequent
rule-variable snapshots now isolate explicitly scoped bindings, including aggregate
initialization, while undeclared child mutations remain caller-visible. This does not
turn every working variable into a private local. `retv` assignment after dispatch and
return-channel save/restore remain distinct from variable-binding scope. Startup
`.3.3.51` reconciles this history with the already-read runtime and integration controls;
no new integration execution is claimed.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.1`)
- Related: [[rust-edge-semantics-bug]], [[runtimecontext-boundary]]
- Files: `rust/linkedspec-runtime/src/engine.rs`, `rust/linkedspec-runtime/src/runtime.rs`
- Contract: `docs/linkedspec-book/src/appendix/runtime-semantics.md` §3.3, §5.4, §6.1
