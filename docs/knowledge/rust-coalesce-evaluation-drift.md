---
id: rust-coalesce-evaluation-drift
title: "Lazy defaults and selected result kinds"
answers:
  - "why does a pick_keys expression-valued key block fail Perl compilation"
  - "is there a defined-only coalesce fallback receiver method"
  - "does empty text or false skip a coalesce receiver fallback"
  - "can coalesce_nonempty Array or Hash results continue by actual kind"
  - "why does a valid coalesce_nonempty Hash literal emit hash_literal_use_colon"
  - "why does coalesce_nonempty make numeric array indices fail on Perl"
  - "does Perl coalesce_nonempty return undef when all operands are empty"
  - "does Rust coalesce preserve a defined empty string"
  - "does Rust coalesce short circuit operand evaluation"
  - "does coalesce_nonempty skip later assignment effects"
  - "what does the coalesce_short_circuits native test actually assert"
  - "why do Perl and Rust coalesce disagree on empty aggregates"
  - "why does a Hash default sorted_values first uppercase return null"
  - "how do Array successors consume emitted default guard expressions"
date: 2026-10-27
status: bounded defined-only defaults targeted-checked on five recorded backends
tags: [rust, perl, dart, julia, lua, helpers, defaults, projection, evaluation, startup-reading]
evidence: "Defaults62/TYPE23.3.6/16.1; TYPE23.3.18.1-.5 retained public producer/shared/selected/kind/effect native/generated controls; defined-default-results.md."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test defined_default_receivers --test default_selected_receivers --test coalesce_receiver_values"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/defined_default_receiver_contract.t t/default_hash_projection_contract.t t/default_selected_receiver_contract.t"
  - "(cd dart && bash ../tools/run_dart_project_data.sh test test/defined_default_receivers_test.dart test/default_selected_receivers_test.dart)"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include(\"julia/test/defined_default_receivers_test.jl\");include(\"julia/test/default_selected_receivers_test.jl\")'"
  - "bash tools/run_lua_project_data.sh puc lua/test/defined_default_receivers_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/defined_default_receivers_test.lua"
---

Rust62.1/62.2 evaluates only needed operands with actual selected kinds;
coalesce retains defined empty text. Perl validates operands, compares a scalar
copy to preserve numeric kinds, and returns undef after nonempty exhaustion.
TYPE23.3.6 binds default results once and guards container consumers by actual
kind. Typed complete operands avoid reparsing emitted fat arrows; authored
retired Hash syntax still rejects. Broader62.3/.62.4/domain admission stays open.
[[action-regex-operands-and-runtime-kinds]] retains shared value boundaries.

TYPE23.3.16.1 exposes a pre-existing Hash default->sorted_values->first->uppercase
bug: numeric-root, canonical-call-root and direct undef default all return null/
unsupported-helper:first, while nested equivalent returns A. WHY: MethodLowering
append_array_chain_call builds DSL calls over emitted default-guard do code;
later typed lowering reparses that host expression. Finish Array calls through
the existing compatibility bridge when source is do, preserving dedicated
sorted/reversed and authored syntax checks. Native/fresh projection controls now
cover first/last/count/join/contains/index, sum/transform/reverse/take, multiple
root families, numeric index kinds and SDC/once-only/source snapshots. Arithmetic,
selected/literal default direct checks pass too; full admission remains separate.

Historical September7 mismatches were eager Rust coalesce evaluation, skipped
defined empty text, and aggregate observations beyond the scalar signature.
Historical controls distinguished empty-text/aggregate fallback behavior;
current bounded repair does not publish a universal aggregate-domain policy.
Full historical bodies/results, named-test/observer qualifications and exact
capture manifests/producer pointers are preserved in this file at Git
846a39094d1f0f1972169fc089098df43aad47d2. They are not current replay instructions;
use focused reverify above. Current original repair ownership is
SESSION-STARTUP-READING62, with selected-result scope TYPE23.3.6 and the direct
projection follow-up16.1. Compatibility observations do not close broader
signature/context/portable admission.

TYPE23.2.18 freezes a separate one-or-more-fallback ordinary coalesce receiver;
old23.2.5 explicitly excluded it. defined-default-results.md and retained public
probe record native/fresh free/nested defined empty/zero/false, actual containers,
numeric selector writes, independent copies and SDC snapshots/skipped runtime
errors. Receiver AST exists but lacks MethodLowering return-family admission,
leaving raw host DSL. Free Perl coalesce(one) returnsnull; no identity receiver
is inferred. Independent18.1-.5 own implementation; no free-signature or portable
aggregate-domain promotion. Empty containers remain defined selected values.

TYPE23.3.18.1 implements the bounded Perl counterpart with pre-effect zero-RHS
rejection, existing actual-result/host bridge composition and once-bound scalar
source. This preserves emitted Hash literal reference identity, avoiding both
host-arrow reparsing and unbound bare-block ambiguity. New13/direct17 checks
retain strict kinds/copies/indices/lazy SDC-SC/skipped failures/source effects.
The Hash consumer also reproduces free pick_keys block-key staging failure:
legacy keys kept raw DSL in foreach. Lower actual key blocks through the existing
typed block lowerer; native/fresh C/snapshot controls pass, ordinary key/free
signatures stay. Authored retired arrows still reject. Other backend progress follows below; full domain/context/portable admission
remains open; see frozen defined contract.

TYPE23.3.18.2 independently confirms free Rust producers, then receiver RED
reaches an unused typed write failure. Missing String admission selects generic
eager dispatch without receiver normalization. Admit coalesce in existing lazy
String/actual-result flow, mark its scalar results until a container is returned
and reject zero RHS before effects. New3/direct3 native/restored/in-process plan
tests plus offline compile/rustfmt pass, including strict shared values/copies/
indices/SDC-SC-HashC/skipped failures and selected/malformed no-effects. No free
signature/context/domain/format change or standalone Rust/portable admission.

TYPE23.3.18.3 confirms Dart's existing defined-only lazy selector and valid
SDC-SC-HashC/copies/indices/skipped runtime failures. Shared RED has scalar[]/SA
and malformed SC. Add coalesce to mayProduceScalar and common one-or-more
preflight; actual List/Map release/free/named-context/format/callback policy
stays. New3/direct3 native/restored/plan tests and format/fatal selected analysis
pass, including selected/malformed fournull/emptyorder. Julia/Lua/full admission
remain separate; no blanket named-context or standalone claim.

TYPE23.3.18.4 independently confirms Julia producers and valid selection/lazy
snapshots; all three routes expose scalar[]/SA and malformed SC. Add coalesce to
common one-or-more preflight and may_produce_scalar, preserving actual container
release/free/named-context/callback/format policy. Registered new36/direct9
native/plan/fresh assertions pass with strict compilation, false identity and
Number-not-Bool results/counters, shared SDC-SC-HashC/copies/indices/skipped errors
and selected/malformed no-effects. Lua18.5/full admission remain separate.

TYPE23.3.18.5 confirms Lua producers on safe PUC5.5.1/LuaJIT, then shared RED
has scalar[]/SA and malformed SC. Both default receiver selections now mark
scalar_result before actual container release; common zero-RHS preflight guards
effects. No new module locals/free/lazy/context/callback/format changes. Strict
native/plan/fresh producer/shared/selected and direct default/source loads pass
both hosts. All five bounded counterparts are targeted-checked; declared5.4,
full domain/context/portable admission and later canonical proof remain open.
