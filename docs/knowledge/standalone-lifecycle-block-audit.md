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
status: audited and ratified; implementation pending under FUTURE-PARITY-BACKLOG.15.1-.2
tags: [dsl, lifecycle, codeblock, parser, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.15.0 toolbox/source audit: Perl validation rejects rule-item-leading `{ ... }`, while its bootstrap CURLY_BRACE scanner returns only a balance sentinel; Rust parses PlainBlock then drops it in compilation; Dart, Julia, and Lua parse PlainBlock and compile inert plain_action_payloads that their runtimes never execute. Direct Julia, PUC Lua, and LuaJIT probes return null for a bare return block but `first-second` for two ordered explicit I blocks. Perl returns `first-second` for the explicit pair. Rust compiler source assigns each lifecycle to one Option and overwrites the earlier I. Direct self-hosted specs/spec.spec output omits a bare block and misclassifies line-start explicit I as a bare edge to target I. ADR 0094 selects direct source-parse normalization to I, exact authored source/line provenance, explicit-twin malformed behavior, ordered duplicates, and unchanged edge/callable/nested ownership."
reverify: "perl -Iperl -MLinkedSpec -MLinkedSpec::BootstrapSpec -MJSON::PP -e 'my $bare=qq{Top::\\n { return(\\\"bare\\\") }\\n}; my ($ok,$ast)=LinkedSpec::BootstrapSpec::run_bootstrap_parse(\\$bare); my %ctx; LinkedSpec::Get(\\$bare,runtime_ctx_ref=>\\%ctx); print JSON::PP->new->canonical(1)->encode({bootstrap_ok=>$ok?1:0,bootstrap=>$ast,last_error=>$ctx{last_error}}),qq{\\n};' && rg -n 'PlainBlock|plain_action_payloads|preamble = Some' rust/linkedspec-core/src dart/lib julia/src lua/src"
---

## Current implementation truth

There is no executable cross-backend standalone lifecycle block today:

- Perl's validation whitelist has no item beginning with `{`. The later bootstrap brace rule balances nested text
  but returns `1`, not `ICODE`; compilation is rejected first with `Unsupported top-level rule paragraph content`.
- Rust's source parser creates `BodyElementKind::PlainBlock`, but its compiler groups that node with raw text and
  emits no code.
- Dart, Julia, and Lua create their corresponding plain-block AST nodes and compile `plain_action_payloads` with
  role `plain_block`. Runtime lifecycle loops read only `lifecycle_action_payloads`; plain payloads affect only an
  inert/passive-rule shape check.
- PUC Lua and LuaJIT share the same implementation and independently return null for `Top:: { return("bare") }`.
  Julia does the same. Two explicit `I` blocks execute in order and return `first-second` on all three routes.
- Rust's compiled lifecycle representation is singular and assigns `preamble = Some(block)` for every `I`, so a
  later block replaces an earlier one. Perl joins code chunks in order; Dart, Julia, and Lua keep ordered lists.

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
