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
  - "what recurring gate proves repeated action results across every backend"
  - "which canonical CI switch runs repeated action result parity"
  - "why was the Lua repeated action result consumer missing from canonical tracking"
date: 2026-07-20
status: ADR 0048 accepted; all eight rollout legs complete; recurring and public no-drift closed at 8 complete / 0 pending
tags: [or, repetition, action-edge, output-shape, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "The original five-primary audit found Rust, Dart, Julia, and Lua returned first-hit scalar A while Perl collected explicit repetition. ADR 0048 accepted reference collection, scalar pipe, lifecycle whole-rule authority, corrected rep_acode classification, and unchanged generated-source v2. FUTURE-PARITY-BACKLOG.9.1.10.1 added the 8-mode/10-special executable contract and ten-role Perl admission. Rust, Dart, Julia, and Lua now make bare OR minimum-one repetition, classify bare action/blind OR as rep_acode/rep_bcode, collect typed action-block and fluent returns per hit in native and generated execution, preserve returned arrays/nulls as one outer element, and retain lifecycle/default/AND/pipe/blind-result boundaries. Each newer admitted backend has one exact 15-role consumer proving native, loaded, reconstructed, descriptor, emitted/generated direct/traced, primary, corpus, lifecycle, bounds, progress, and selected-slot trace. Dart, Julia, and Lua capture values at the action-edge boundary so implicit child dispatch continues while lifecycle return control stays outside collection. Julia executes freshly emitted source in an isolated host; one byte-identical Lua consumer executes freshly emitted modules on PUC Lua and LuaJIT. Both reject stale or_acode plans. FUTURE-PARITY-BACKLOG.9.1.10.6 adds one omission-sensitive recurring driver over all six runtime legs, the exact explicit_or_two_hits result across five commands and two environments, and three support ledgers. During topology retrieval, the prior canonical audit was found to repeat Julia while omitting the Lua consumer; the recurring leaf corrects that edge and locks both the Lua source and new driver exactly once. Public closeout FUTURE-PARITY-BACKLOG.9.1.10.7 requires 25 current documents, denies 12 stale claims, rejects 54 mutations, and makes all eight rollout legs complete."
evidence_update_2026_07_20_recurring_signoff: "The disposable recurring driver passes Perl 10 roles, Rust and Dart three admission tests each, Julia 162 assertions, PUC Lua and LuaJIT 175 assertions each, the selected primary projection on all 5x2 legs, generated-source and capability 80/0/0, and language coverage 246/105+1/122. The current manifest is 66 cases. Canonical local CI passes reference primary 66x2 and Phase 0 1,031/1,031 in 641 seconds, with the complete gate exiting 0 in 1,505.50 seconds."
evidence_update_2026_07_20_public_closeout: "The public contract reports 8 complete / 0 pending and rejects 54 mutations over 25 required documents, 12 stale-current denials, exact four-parent closure, and next-owner handoff. The exact recurring proof remains tools/check_repeated_action_result_five_backend.sh."
reverify: "bash tools/check_repeated_action_result_five_backend.sh"
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
all five backends, recurring composition, and public no-drift are complete at
8 complete / 0 pending with 54 rejected mutations. No backend is admitted from
the primary matrix alone.

Related: [[duplicate-regex-slot-identity-contract]],
[[blind-call-collection-shape]], [[handler-ir-design]],
[[spec-rule-mode-semantics-map]], ADR `0048`, and [[FUTURE-PARITY-BACKLOG]].

## September 10 Dart admission-prefix reading

`DART-STARTUP-READING.1.43` reads consumer lines 1-333; the full three-test consumer
passes within the selected 22-test suite. Neutral proof remains eight modes, ten special
cases, eight completed legs/zero pending and 54 mutations. Prefix source binds all fifteen
unique role names and covers metadata, native modes/special cases, loading, reconstruction
and descriptor projection; later role bodies remain the next reading child.

The emitted role creates a fresh offline caller/cache, directly runs both generated entry
points, compares results and checks two selected-slot trace records before owned cleanup.
It has no separate analyze command. Exact generated-plan validation rejects stale
`or_acode` classification for the admitted explicit repetition fixture.
