---
id: explicit-or-action-result-shape-parity-gap
title: "Explicit repetition action returns collect per hit; Rust is admitted and three newer backends remain"
answers:
  - "why does Perl Top OR return an array"
  - "does Top double colon OR return the same shape on every backend"
  - "what is the difference between Top OR and Top pipe choice"
  - "which task owns explicit OR action result shape parity"
  - "why did the duplicate regex choice fixture change from OR to pipe"
  - "why do Rust Dart Julia and Lua stop explicit OR after the first action return"
  - "is bare OR classified as repetition in every backend"
  - "do repeated action edge returns exit the whole rule"
  - "does explicit repeated choice require generated source v3"
  - "where is the explicit repetition action result neutral contract"
  - "how is Perl repeated action result behavior admitted"
date: 2026-07-20
status: ADR 0048 accepted; neutral, Perl, and Rust complete; five rollout legs pending FUTURE-PARITY-BACKLOG.9.1.10.3-.7
tags: [or, repetition, action-edge, output-shape, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "The original five-primary audit found Rust, Dart, Julia, and Lua returned first-hit scalar A while Perl collected explicit repetition. ADR 0048 accepted reference collection, scalar pipe, lifecycle whole-rule authority, corrected rep_acode classification, and unchanged generated-source v2. FUTURE-PARITY-BACKLOG.9.1.10.1 added the 8-mode/10-special executable contract and ten-role Perl admission. FUTURE-PARITY-BACKLOG.9.1.10.2 makes Rust bare OR minimum-one repetition, classifies bare action/blind OR as rep_acode/rep_bcode, collects typed action-block and fluent returns per hit in both native and generated executors, preserves returned arrays/nulls as one outer element, and retains lifecycle/default/AND/pipe/blind-result boundaries. One exact 15-role Rust consumer proves native, loaded, reconstructed, descriptor, emitted/generated direct/traced, primary, corpus, lifecycle, bounds, progress, and selected-slot trace. The checker reports 3 complete plus 5 pending and rejects 26 mutations."
reverify: "python3 tools/check_repeated_action_result_contract.py && PERL5LIB= prove -Iperl t/repeated_action_result_perl_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test repeated_action_result_contract"
---

`Rule::OR` and `Rule::|` are not interchangeable. ADR `0048` fixes the portable
contract: explicit repetition forms `*`, `+`, `?`, `OR`, `OR+`, and bounded
`OR` collect one action-edge return value per accepted hit. Pipe is a
non-repeating single-choice family and returns the selected action value
directly. Lifecycle returns remain whole-rule returns; they are not iteration
values.

The exact audit found two separate defects in Rust, Dart, Julia, and Lua. Bare
`OR` is documented as repetition but its metadata excludes it and its generated
plan uses `or_acode`. Modes already classified as repetition still stop because
an action-edge return escapes through the lifecycle/whole-rule return channel.
Fixing only one branch would leave the other drift intact.

Current primary result matrix for distinct `/a/` and `/b/` action slots on
input `ab`:

| Mode | Perl / Rust | Dart / Julia / Lua | Accepted contract |
| --- | --- | --- | --- |
| `::OR`, `::OR+`, `::OR{2}`, `::+`, `::*` | `["A","B"]` | `"A"` | `["A","B"]` |
| `::?` | `["A"]` | `"A"` | `["A"]` |
| `::|` | `"A"` | `"A"` | `"A"` |

Generated-source v2 already distinguishes `or_acode` from `rep_acode` and
embeds the action/lifecycle context, so the plan format does not change. A stale
newer-backend bare-`OR` row fails exact family validation and must be regenerated.
The unadorned historical default handler is outside this scoped decision.

The duplicate-slot contract uses `::|` for its genuine single-choice priority
fixture. The executable contract lives at
`capability_conformance/repeated_action_result_contract.json`; its checker owns
the neutral evaluator; its Perl consumer owns ten route roles and its Rust
consumer owns 15. Neutral, Perl, and Rust are complete at 3 complete / 5
pending. Remaining backend behavior begins at `.9.1.10.3`; no backend may claim
parity from the primary matrix alone.

Related: [[duplicate-regex-slot-identity-contract]],
[[blind-call-collection-shape]], [[handler-ir-design]],
[[spec-rule-mode-semantics-map]], ADR `0048`, and [[FUTURE-PARITY-BACKLOG]].
