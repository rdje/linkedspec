---
id: spec-format-brainstorm-rounds-1-3
title: Brainstorm outcomes Rounds 1–3 for .spec format evolution — variables, types, control flow, edge syntax, arithmetic (no decisions finalized)
answers:
  - "what format changes were brainstormed for .spec files"
  - "what is the future direction for declare assign push set_key"
  - "what was decided about function composability"
  - "what control flow syntax was agreed"
  - "what arithmetic function forms were settled"
  - "what is the status of -> edge semantics"
date: 2026-06-15
status: brainstorming
tags: [spec-format, brainstorm, design, dsl]
evidence: "Conversation transcript 2026-06-15. Three rounds of brainstorming completed. No code changes made. No decisions finalized."
reverify: "cat docs/knowledge/spec-format-brainstorm-rounds-1-3.md"
---

# .spec Format Brainstorm — Rounds 1–3 (2026-06-15)

**Status: brainstorming only. No decisions have been made. No code has been changed.**

## Round 1 — Variables, types, mutation, functions

Converged direction (tentative):
- No `declare(...)`. Variables auto-exist on first use within a rule scope.
- No `scalar()`/`s()`, `array()`/`a()`, `hash()`/`h()` wrappers. Bare words are variables or functions, never string literals.
- Type inference via RHS shape: `[]` → array, `{}` → hash, number/string/call → scalar.
- Helper arg position also infers: `push(X,v)` → X is array, `set(X,v)` → X is scalar, `name[k]=v` → X is hash.
- String/number literals: `"..."`, `'...'`, `42`, `3.14`, `true`, `false`, `undef`.
- Operators + composable function forms:
  - Scalar assign: `name = val` (op) or `set(name, val)` (function, renamed from `assign`).
  - Array push: `name += val` (op) or `push(name, val)` (function).
  - Hash set: `name[k] = v` (op) or `set_key(name, k, v)` (function).
  - Copy: `copy(name)` — applies to both arrays and hashes (replaces `array_copy`/`hash_copy`).
  - Concat: `cat(a, b, c)` (replaces `concat`).
- Nested access: `foo["a"][9]['b'][z]` — any mix of string/numeric/variable indices, any depth.
- Function calls always with `()`. Space before `()` allowed: `return (val)` same as `return(val)`.
- Semicolons required only when multiple statements on same line.
- Array methods: `.push_front(v)`, `.push_back(v)`, `.pop_front()`, `.pop_back()`.

## Round 2 — Control flow

Converged direction (tentative):
- Everything is an expression. Blocks `{ ... }` return values (last statement or explicit `return()`).
- `if (cond) { ... } elseif (cond) { ... } else { ... }` — parens for conditions, blocks for bodies. Blocks NEVER inside parens.
- `when (cond) { ... }` — inline conditional.
- `otherwise { ... }` — no parens, no args.
- `default { ... }` — no parens, no args.
- `while (cond) { ... }` — parens for condition, block for body.
- `switch (expr) { case(v) { ... } default { ... } }`.
- Fluent chains: `.when (cond) { ... }.otherwise { ... }` — parens for condition, block after.
- Lifecycle blocks: `I { ... }`, `LS { ... }`, etc. — block after keyword, values dropped.
- Lisp-style composability everywhere — any function can appear in any argument position at any depth.
- Method chaining by return type (array→array methods, hash→hash methods, string→string methods, number→number methods).

## Round 3 — Edge syntax and arithmetic

Edge syntax (kept as-is):
- `->` for action edges, `=>` for blind-call edges.
- Grouped targets: `-> A | B { code }` — factors shared code block across multiple child rules.
  Each target dispatches independently; the pipe is purely syntactic factoring.
  The block-less form `-> A | B` (without `{...}`) is NOT valid syntax in the current Perl implementation.

Arithmetic (functions-only, no operators):
- All arithmetic as composable functions: `add(a,b)` or `+(a,b)`, `sub(a,b)` or `-(a,b)`, etc.
- Comparisons: `gt(a,b)` or `>(a,b)`, `lt(a,b)` or `<(a,b)`, `eq(a,b)` or `==(a,b)`, etc.
- Single-arg: `abs(a)`, `floor(a)`, `ceil(a)`, `round(a)`.
- Multi-arg: `min(a,b)`, `max(a,b)`, `clamp(v,lo,hi)`.
- Array reducers: `sum(arr)`, `avg(arr)`, `median(arr)`, `range(arr)`.
- Two spellings per function (word and symbol) — parser treats `+` as a function name.
- No operator precedence. Deeply composable like any other call.

## Critical finding: Rust -> edge bug

During the brainstorm, analysis of the Perl bootstrap/compiler/HandlerVariantEmitter revealed that the Rust implementation's `->` edge dispatch is fundamentally wrong. See [[rust-edge-semantics-bug]].

## Pending rounds

Round 4+ not yet brainstormed: capture/marks, rule modes, split markers, lifecycle semantics, etc.
