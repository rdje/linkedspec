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
date: 2026-06-16
status: confirmed
tags: [rust, engine, runtime, retv, dispatch, RUST-PARITY]
evidence: "RUST-PARITY.5.1 (2026-06-16): rust/linkedspec-runtime/src/engine.rs execute_rule + acode/bcode dispatch + return/call helpers; rust/linkedspec-runtime/src/runtime.rs return_value channel + set_retv. Matches book appendix/runtime-semantics.md §3.3/§5.4/§6.1. 186/186 tests green."
reverify: "cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'set_retv\\|return_value\\|fn execute_rule' linkedspec-runtime/src/engine.rs linkedspec-runtime/src/runtime.rs"
---

# Rust Engine: Child-Return (`retv`) Propagation

**Confirmed 2026-06-16 (RUST-PARITY.5.1).** Fixes the audit's top BLOCKER: before this,
`scalar(retv)` resolved to undef after `->`/`=>` dispatch, so nearly every grammar produced
null/wrong output.

## The model

The Rust runtime interprets against **one shared `RuntimeContext`** for the whole parse (a
single scalars/arrays/accumulator map — there is no per-rule variable scope yet). A rule's
result is modeled as pushes onto the single shared `ctx.accumulator`, which `execute()`
returns as the top-level JSON.

## How `retv` works now

1. `RuntimeContext` has a per-invocation channel `return_value: Option<RuntimeValue>` with
   `set_return_value` / `take_return_value` / `restore_return_value`.
2. `execute_rule` returns `Result<RuntimeValue, String>` (the rule's own return value). It
   `take`s the channel on entry (saving the **caller's** pending return) and reads + restores
   it on exit, so each invocation reports exactly its own last `return(...)`
   (Runtime Semantics §5.4) and nested child dispatch is transparent across stack frames.
3. After both `->` (acode) and `=>` (bcode) dispatch, the engine calls
   `ctx.set_retv(child_retv)`, so the parent's attached code / `LE` / `E` read the child's
   result as `scalar(retv)` (Runtime Semantics §3.3 / §6.1).
4. `return(expr)` records the channel **and** still pushes the accumulator — the accumulator
   is `execute()`'s return contract, so this is purely additive and the 182-test baseline is
   unchanged. `execute()` still returns `ctx.accumulator`, **not** the new channel.

## Gotcha: `call(child)` rule-name resolution

`call(child)` evaluates to the child's return value (the reference pattern
`assign(s(retv), call(child))`, `specs/tablegrep.spec`). The rule name must come from the
**raw AST arg** (`resolve_rule_name`, mirroring `resolve_array_target`): a bare
`call(RuleName)` evaluates to undef because a rule label is not a scalar variable — reading
the evaluated value (the old code) never resolved a bare rule.

## Still simplified (out of scope for `.5.1`)

`retv` is a single shared scalar (no per-rule scope), kept correct only because the
post-dispatch `set_retv` overwrites it to the latest child's return. True per-rule scope is a
larger change; see the related splits.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.1`)
- Related: [[rust-edge-semantics-bug]], [[runtimecontext-boundary]]
- Files: `rust/linkedspec-runtime/src/engine.rs`, `rust/linkedspec-runtime/src/runtime.rs`
- Contract: `docs/linkedspec-book/src/appendix/runtime-semantics.md` §3.3, §5.4, §6.1
