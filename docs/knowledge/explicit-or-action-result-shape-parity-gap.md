---
id: explicit-or-action-result-shape-parity-gap
title: "Explicit repetition action returns collect per hit; four newer backends currently exit on the first hit"
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
date: 2026-07-20
status: ADR 0048 accepted; backend rollout pending FUTURE-PARITY-BACKLOG.9.1.10.1-.7
tags: [or, repetition, action-edge, output-shape, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.10 toolbox probes cover Perl live, loaded, generated, and generated-traced routes, and a disposable exact five-primary-adapter matrix covers distinct patterns. On input ab, Perl returns [\"A\",\"B\"] for ::OR, ::OR+, ::OR{2}, ::+, and ::*, [\"A\"] for ::?, and scalar \"A\" for ::|; Rust, Dart, Julia, and Lua return scalar \"A\" for every repeated row and pipe. Perl descriptor/source reports REP_OR_EXPLICIT / REP_ACODE, min 1, repeat_loop, rewrites only action-edge return to the iteration scalar, and pushes once per successful iteration. Rust, Dart, Julia, and Lua AST metadata all omit Or from is_repetition/rep_min despite comments calling it repeated choice, and all four generated-v2 classifiers map Or with Pipe to or_acode. Their repeated runtime paths independently propagate an action-edge return through the whole-rule return channel. ADR 0048 accepts reference collection, scalar pipe, lifecycle whole-rule authority, corrected rep_acode classification, and unchanged generated-source v2."
reverify: "perl -Iperl bin/linkedspec --inline-spec 'Top::OR\n /a/ -> Top[0] { return(\"A\") }\n /b/ -> Top[1] { return(\"B\") }\n' --input ab; perl -Iperl bin/linkedspec --inline-spec 'Top::|\n /a/ -> Top[0] { return(\"A\") }\n /b/ -> Top[1] { return(\"B\") }\n' --input ab; rg -n 'is_repetition|isRepetition|is_generated_repetition|classify_generated_rule_family|classifyGeneratedRuleFamily' rust/linkedspec-core/src/ast.rs rust/linkedspec-runtime/src/source_emitter.rs dart/lib/src/ast/spec_ast.dart dart/lib/src/source_emitter.dart julia/src/spec/Ast.jl julia/src/source/SourceEmitter.jl lua/src/linkedspec/spec_ast.lua lua/src/linkedspec/source_emitter.lua"
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

| Mode | Perl reference | Rust / Dart / Julia / Lua | Accepted contract |
| --- | --- | --- | --- |
| `::OR`, `::OR+`, `::OR{2}`, `::+`, `::*` | `["A","B"]` | `"A"` | `["A","B"]` |
| `::?` | `["A"]` | `"A"` | `["A"]` |
| `::|` | `"A"` | `"A"` | `"A"` |

Generated-source v2 already distinguishes `or_acode` from `rep_acode` and
embeds the action/lifecycle context, so the plan format does not change. A stale
newer-backend bare-`OR` row fails exact family validation and must be regenerated.
The unadorned historical default handler is outside this scoped decision.

The duplicate-slot contract uses `::|` for its genuine single-choice priority
fixture. Behavior rollout is split under `.9.1.10.1-.7`; no backend may claim
parity from the primary matrix alone.

Related: [[duplicate-regex-slot-identity-contract]],
[[blind-call-collection-shape]], [[handler-ir-design]],
[[spec-rule-mode-semantics-map]], ADR `0048`, and [[FUTURE-PARITY-BACKLOG]].
