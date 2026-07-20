---
id: explicit-or-action-result-shape-parity-gap
title: "Explicit repetition action returns collect per hit on all five backends"
answers:
  - "why does Perl Top OR return an array"
  - "does Top double colon OR return the same shape on every backend"
  - "what is the difference between Top OR and Top pipe choice"
  - "which task owns explicit OR action result shape parity"
  - "why did the duplicate regex choice fixture change from OR to pipe"
  - "why did Rust Dart Julia and Lua stop explicit OR after the first action return"
  - "is bare OR classified as repetition in every backend"
  - "do repeated action edge returns exit the whole rule"
  - "does explicit repeated choice require generated source v3"
  - "where is the explicit repetition action result neutral contract"
  - "how is Perl repeated action result behavior admitted"
  - "how is Dart repeated action result behavior admitted"
  - "how is Julia repeated action result behavior admitted"
  - "how is Lua repeated action result behavior admitted on PUC Lua and LuaJIT"
date: 2026-07-20
status: ADR 0048 accepted; neutral and all five backends complete; recurring/public rollout pending FUTURE-PARITY-BACKLOG.9.1.10.6-.7
tags: [or, repetition, action-edge, output-shape, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "The original five-primary audit found Rust, Dart, Julia, and Lua returned first-hit scalar A while Perl collected explicit repetition. ADR 0048 accepted reference collection, scalar pipe, lifecycle whole-rule authority, corrected rep_acode classification, and unchanged generated-source v2. FUTURE-PARITY-BACKLOG.9.1.10.1 added the 8-mode/10-special executable contract and ten-role Perl admission. Rust, Dart, Julia, and Lua now make bare OR minimum-one repetition, classify bare action/blind OR as rep_acode/rep_bcode, collect typed action-block and fluent returns per hit in native and generated execution, preserve returned arrays/nulls as one outer element, and retain lifecycle/default/AND/pipe/blind-result boundaries. Each newer admitted backend has one exact 15-role consumer proving native, loaded, reconstructed, descriptor, emitted/generated direct/traced, primary, corpus, lifecycle, bounds, progress, and selected-slot trace. Dart, Julia, and Lua capture values at the action-edge boundary so implicit child dispatch continues while lifecycle return control stays outside collection. Julia executes freshly emitted source in an isolated host; one byte-identical Lua consumer executes freshly emitted modules on PUC Lua and LuaJIT. Both reject stale or_acode plans. The Lua consumer passes 175 assertions on each ABI and the complete dual-ABI gate passes 177 package tests per ABI, primary 65x2, and corpus 105/105. The checker reports 6 complete plus 2 pending and rejects 35 mutations."
reverify: "python3 tools/check_repeated_action_result_contract.py && PERL5LIB= prove -Iperl t/repeated_action_result_perl_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test repeated_action_result_contract && (cd dart && dart test test/repeated_action_result_contract_test.dart) && julia --project=julia --compiled-modules=no julia/test/repeated_action_result_contract_test.jl && bash tools/run_lua_local.sh"
---

`Rule::OR` and `Rule::|` are not interchangeable. ADR `0048` fixes the portable
contract: explicit repetition forms `*`, `+`, `?`, `OR`, `OR+`, and bounded
`OR` collect one action-edge return value per accepted hit. Pipe is a
non-repeating single-choice family and returns the selected action value
directly. Lifecycle returns remain whole-rule returns; they are not iteration
values.

The exact audit found two separate defects in Rust, Dart, Julia, and Lua. Bare
`OR` was documented as repetition but its metadata excluded it and its generated
plan used `or_acode`. Modes already classified as repetition still stopped because
an action-edge return escaped through the lifecycle/whole-rule return channel.
The admitted repairs address both seams.

Current primary result matrix for distinct `/a/` and `/b/` action slots on
input `ab`:

| Mode | Perl / Rust / Dart / Julia / PUC Lua / LuaJIT | Accepted contract |
| --- | --- | --- |
| `::OR`, `::OR+`, `::OR{2}`, `::+`, `::*` | `["A","B"]` | `["A","B"]` |
| `::?` | `["A"]` | `["A"]` |
| `::|` | `"A"` | `"A"` |

Generated-source v2 already distinguishes `or_acode` from `rep_acode` and
embeds the action/lifecycle context, so the plan format does not change. A stale
newer-backend bare-`OR` row fails exact family validation and must be regenerated.
The unadorned historical default handler is outside this scoped decision.

The duplicate-slot contract uses `::|` for its genuine single-choice priority
fixture. The executable contract lives at
`capability_conformance/repeated_action_result_contract.json`; its checker owns
the neutral evaluator; its Perl consumer owns ten route roles and its Rust,
Dart, Julia, and byte-identical dual-ABI Lua consumers own 15 each. Neutral and
all five backends are complete at 6 complete / 2 pending. Recurring composition
and public no-drift remain `.9.1.10.6-.7`; no backend is admitted from the primary
matrix alone.

Related: [[duplicate-regex-slot-identity-contract]],
[[blind-call-collection-shape]], [[handler-ir-design]],
[[spec-rule-mode-semantics-map]], ADR `0048`, and [[FUTURE-PARITY-BACKLOG]].
