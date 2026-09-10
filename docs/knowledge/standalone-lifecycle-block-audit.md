---
id: standalone-lifecycle-block-audit
title: "Standalone rule blocks portably normalize to lifecycle I on all five backends"
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
  - "why does Dart not preserve a rule-header-shaped lifecycle remainder as raw body text"
  - "how does Dart keep standalone lifecycle validation from masking action diagnostics"
  - "why does Julia not preserve a rule-header-shaped lifecycle remainder as raw body text"
  - "how does Julia keep standalone lifecycle validation from masking action diagnostics"
  - "why did the Lua next control fixture fail after standalone lifecycle normalization"
  - "how must a Lua next action block be owned after bare blocks became lifecycle I"
  - "why did the Dart next control fixture fail after standalone lifecycle normalization"
  - "how must a Dart next action block be owned after bare blocks became lifecycle I"
  - "can lifecycle fluent calls have whitespace before their argument list"
  - "why did Dart and Julia reject I.return ([])"
date: 2026-09-08
status: implemented on all five backends and six runtime routes under FUTURE-PARITY-BACKLOG.15.1-.2
tags: [dsl, lifecycle, codeblock, parser, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.15.0 ratified ADR 0094 from the five-backend audit. `.15.1` adds one neutral explicit/bare twin contract to Perl/Rust and repairs Rust duplicate-I order. `.15.2` makes Dart, Julia, PUC Lua, and LuaJIT emit lifecycle I directly; preserves exact source/opening line and explicit-twin ActionIR semantics; proves native, reconstructed, emitted/generated, ownership, malformed, and inert legacy-plain paths; and gives specs/spec.spec a standalone production plus reserved lifecycle precedence. Dart and Julia retain a post-lifecycle raw suffix only when it is not a recognized rule header, preserving established typed action-diagnostic precedence. All explicit/bare duplicate combinations return first-second in authored order. The exact recurring gate covers five backends, six runtime routes, self-hosting, generated/capability/language ledgers, and public no-drift."
evidence_update_2026_08_30_mdbook_reconciliation: "FUTURE-PARITY-BACKLOG.23.2 repairs the action-placement and project-status pages that still described the completed `.15.2` rows as pending. The executable public projection now requires 15 documents, denies seven exact stale current claims, and rejects 14 contract/document mutations without changing parser, compiler, runtime, generated-format, or outward behavior."
evidence_update_2026_08_30_lua_next_fixture: "FUTURE-PARITY-BACKLOG.15.3 repairs one stale test, not lifecycle/runtime behavior. The original Lua interpreter fixture used /skip/ { next() }; before .15.2 the bare block was inert, so the test passed without exercising next. Correct normalization makes that block entry lifecycle I, where next exits before regex iteration with null/cursor 0. The repaired fixture uses -> Skip { next() } plus Skip: /skip/, assigning the block to the action edge and returning keep/cursor 8. Complete 178-test PUC Lua and LuaJIT harnesses, the 14-mutation neutral contract, and 109 assertions per ABI pass."
evidence_update_2026_09_01_fluent_whitespace: "FUTURE-PARITY-BACKLOG.19.3.3 repairs a pre-existing Dart/Julia parser gap exposed by the tclite corpus: `I.return ([])` was parsed as empty `return()` followed by invalid raw `([])` because both fluent scanners checked for `(` before skipping horizontal whitespace. Both now lower it to `return([])`, focused parser proof passes, and complete Dart/Julia corpus execution is 105/105 with unchanged expectations."
evidence_update_2026_09_01_dart_next_fixture: "FUTURE-PARITY-BACKLOG.19.3.3 repairs the exact Dart analogue of the Lua `.15.3` stale test without changing parser/runtime behavior. `/skip/ { next() }` correctly means a regex item followed by entry lifecycle I, so the old test exits before regex iteration. `-> Skip { next() }` plus `Skip: /skip/` assigns the block to the action edge and returns keep/cursor 8; the focused interpreter test passes."
reverify: "bash tools/check_standalone_lifecycle_block_five_backend.sh"
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

Dart, Julia, and Lua now normalize the bare form to their existing ordered lifecycle payload lists. PUC Lua and
LuaJIT prove the shared implementation independently. Source parsing emits no new plain node; legacy programmatic/
serialized plain nodes and compiled `plain_action_payloads` remain readable and inert. Generated-plan and emitted
host-source routes retain duplicate order and the shorthand result.

Dart and Julia preserve an unsupported same-line suffix after an explicit or shorthand lifecycle-I block as raw
body text so malformed twins reject deterministically. That preservation deliberately excludes text recognized by
the backend's existing rule-header scanner: compact negative fixtures use such a tail only to provide static-child
shape while an earlier action expression owns the intended typed diagnostic. Treating the tail as raw body text
would mask that diagnostic with generic body syntax. Each backend's standalone malformed-twin consumer and
recursive-observation consumer jointly lock the two precedence boundaries. Shared Lua's corresponding observation
fixtures put their child headers at actual line boundaries, where existing collection stops before body parsing.

Compact lifecycle fluent calls permit whitespace between the method name and its parenthesized argument list.
For example, `I.return ([])` and `I.return([])` both lower to the same `return([])` lifecycle statement. Dart and
Julia explicitly lock this spelling because the shipped tclite grammar uses it.

The September 7 reading controls find a remaining Rust gap in this accepted spelling:
`I.return ("ok")` and its tab twin fail Rust compilation while the compact no-space
and explicit-block forms succeed. Startup `.52.1` owns the repair. Quoted compact
parentheses, header-only invalid suffix loss, and outer regex-brace truncation have
separate owners `.52.2`, `.53`, and `.54`; exact controls and limits are retained in
[[rust-body-parser-lexical-boundary-defects]]. The earlier shorthand admission does
not close these newly measured boundaries.

The permanent self-hosted grammar now has a standalone production. A complete-line lifecycle production wins
before generic bare-edge matching, so all reserved markers remain lifecycle syntax and the bare form projects as
`{type: lifecycle, marker: I, source_form: bare}`. Its four governed `spec_spec_*` corpus inputs remain exact
canonical grammar mirrors at SHA-256 `03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004`.

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

## Lua runtime-control fixture ownership repair

The original Lua runtime-control test wrote `/skip/ { next() }`. That source contains two rule items: `/skip/`
and a rule-item-leading bare block. Before standalone lifecycle admission, the block was inert compatibility data,
so the test happened to reach `/keep/` and pass without executing `next()`. After `.15.2`, the same block correctly
normalizes to entry lifecycle `I`; `next()` therefore runs before regex iteration and returns null at cursor zero.

The valid control fixture is `-> Skip { next() }` with `Skip: /skip/`. Here the braces are owned by the action edge,
the skip regex is consumed, `next()` advances the enclosing rule iteration, and `/keep/` produces `keep` at cursor
eight. `.15.3` changes only this test ownership and preserves ADR `0094`, the neutral shorthand contract, and the
runtime interpreter.

## Dart runtime-control fixture ownership repair

The Dart interpreter had retained the same stale `/skip/ { next() }` fixture. Its complete component gate correctly
exposed the mismatch once standalone blocks normalized to lifecycle `I`: the entry action runs before regex
iteration and exits at cursor zero. `.19.3.3` gives the block exact action-edge ownership using `-> Skip { next() }`
and `Skip: /skip/`. The focused test locks the intended `keep` result and cursor eight; Dart parser and interpreter
semantics do not change for this repair.

Related: [[rule-local-cursor-and-bare-edge-contract]], [[spec-lifecycle-retv-order]],
[[terse-lifecycle-value-drop-return-channel]], and [[FUTURE-PARITY-BACKLOG]].

## September 8 Rust consumer boundaries

`SESSION-STARTUP-READING.3.3.64/.65` reconciles all 470 lines of
`rust/linkedspec-runtime/tests/standalone_lifecycle_block_contract.rs`. Placement
and provenance twins compare AST/ActionIR/compiled forms; duplicate combinations
execute through native engines and reconstructed compiled state. Ownership and
malformed twins retain their earlier brace owners and diagnostic fields; legacy
plain nodes stay inert, and programmatic lifecycle interiors remain balance-checked.

The final generated-route test inspects emitted source for identity/contract text,
validates the logical plan and executes the public generated-plan helper plus a
native engine. It does not independently compile an emitted Rust module. This is
the Rust target's precise boundary within the earlier multi-backend evidence;
other backend carrier results are unchanged. Fresh neutral checking passes nine
placements, four duplicate forms, six ownership cases, three malformed twins and
fourteen mutations. No new native or six-runtime matrix run is claimed, and the
separately measured Rust lexical repairs `.52`–`.54` remain pending.

## September 11 Dart consumer boundaries

Dart .1.52 reads standalone_lifecycle_block_contract_test.dart 1-207 through EOF.
Placement/provenance twins compare opening lines, authored source and normalized
payloads. Duplicate cases execute through native, SpecFile-JSON reconstructed and
generated-plan routes. This Dart consumer only requires nonempty emitted source;
it does not independently analyze or execute that emitted module. Malformed twins
compare exception runtime types and nonempty messages, not exact diagnostic fields.
Legacy reconstructed plain blocks remain inert. All 38 selected Dart tests pass,
including these six lifecycle tests; neutral governance remains 9 placements,
4 duplicates,6 ownership cases,3 malformed twins and14 mutations. This bounded
rerun adds no other-backend execution claim and closes no prior lexical defect.
