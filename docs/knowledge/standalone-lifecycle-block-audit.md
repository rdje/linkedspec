---
id: standalone-lifecycle-block-audit
title: "Standalone rule blocks have no current portable behavior and must normalize to lifecycle I"
answers:
  - "does a standalone brace block run as lifecycle I"
  - "what does a bare rule-level block mean"
  - "do plain blocks execute"
  - "what is PlainBlockBodyElementKind"
  - "why does Perl reject a standalone block"
  - "how should a dangling block normalize"
  - "who owns braces after action and blind edges"
  - "are duplicate I lifecycle blocks ordered"
  - "why does Rust keep only the last I block"
  - "does spec.spec classify I blocks correctly"
date: 2026-08-29
status: Perl and Rust implemented under FUTURE-PARITY-BACKLOG.15.1; remaining rollout pending under .15.2
tags: [dsl, lifecycle, codeblock, parser, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.15.0 ratified ADR 0094 from the five-backend audit. FUTURE-PARITY-BACKLOG.15.1 adds one neutral explicit/bare twin contract consumed by Perl and Rust: Perl bootstrap emits metadata-bearing ICODE, Rust emits lifecycle CodeBlock(I), both preserve exact source/opening line and ActionIR interior spans, all explicit/bare duplicate combinations return first-second in authored order, and edge/function/callable/nested braces retain their owners. Perl validation and Rust typed validation now reject missing close, unmatched close, and unmistakably unsupported same-line remainder as explicit/bare twins. Rust appends repeated I statements instead of overwriting the earlier preamble. Rust source parsing no longer emits PlainBlock, while legacy programmatic/serialized PlainBlock remains inert. Dart, Julia, Lua, and specs/spec.spec retain the audited pre-.15.2 boundary."
reverify: "prove -Iperl t/standalone_lifecycle_block_perl_contract.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test standalone_lifecycle_block_contract --no-fail-fast"
---

## Current implementation truth

Perl and Rust now implement the ratified shorthand:

- Perl validation admits a rule-item-leading `{`, and the bootstrap emits `ICODE` with marker `I`, exact authored
  block source, opening line, and `bare` provenance. The existing RuleIR joins repeated entry blocks in authored
  order, so explicit/bare mixtures execute identically and survive standalone generated Perl source.
- Rust source parsing emits `BodyElementKind::CodeBlock { lifecycle: "I", ... }` directly, retains exact outer
  source for provenance and malformed balance checks, and no longer emits `PlainBlock`. Compilation appends every
  `I` block's typed statements into the existing preamble slot, preserving the compiled ABI and per-interior spans.
- One neutral contract covers OR/AND, zero/one/two regex placements, same-line successors, multiline/nested/quoted
  braces, all four duplicate combinations, earlier brace owners, malformed twins, native/serialized/generated
  execution, and the inert legacy Rust plain carrier.

The remaining `.15.2` boundary is still not portable:

- Dart, Julia, and Lua create their corresponding plain-block AST nodes and compile `plain_action_payloads` with
  role `plain_block`. Runtime lifecycle loops read only `lifecycle_action_payloads`; plain payloads affect only an
  inert/passive-rule shape check.
- PUC Lua and LuaJIT share the same implementation and independently return null for `Top:: { return("bare") }`.
  Julia does the same. Two explicit `I` blocks execute in order and return `first-second` on all three routes.
- Dart, Julia, and Lua keep ordered explicit lifecycle payload lists; their bare forms remain inert until `.15.2`.

The permanent self-hosted grammar has no standalone production. Its generic line-level bare-edge block can match
the reserved label `I`; a direct `spec_file` probe currently reports explicit `I { ... }` as `{type: bare_edge,
targets: I}` and omits an actually bare `{ ... }`. Production compilation remains governed by the hardcoded
bootstrap, where lifecycle rules precede bare-edge rules, so this is self-hosted projection drift rather than proof
that explicit `I` is broken in the reference compiler.

## Ratified boundary

ADR `0094` makes a balanced `{ ... }` at a rule-item boundary exact semantic shorthand for explicit `I { ... }`
at that same position. Source parsing emits the existing lifecycle node, preserves the authored braces and opening
line, and gives the interior the same ActionIR parsing/spans as the explicit twin. Attached action/blind/bare-edge
blocks, function and callable bodies, and nested code/control/value braces retain their earlier owners.

New source parsing will not emit `PlainBlock`. Existing programmatic/serialized plain nodes and compiled plain
payload fields remain inert compatibility data; executing or removing them needs a separate versioned migration.
Malformed shorthand follows its explicit twin's block scanner and diagnostics. Mixed explicit/shorthand duplicates
execute in authored order; `.15.1` repairs Rust's existing last-`I`-wins defect without reopening the separate Perl
lifecycle handler-shape caveat.

Related: [[rule-local-cursor-and-bare-edge-contract]], [[spec-lifecycle-retv-order]],
[[terse-lifecycle-value-drop-return-channel]], and [[FUTURE-PARITY-BACKLOG]].
