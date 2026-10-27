---
id: logical-helper-neutral-contract
title: ADR 0043 fixes eager logical helpers over one typed truthiness policy
answers:
  - "are and or not available as fluent receiver methods"
  - "why does true and receiver syntax fail in Perl"
  - "which task implements logical receiver counterparts"
  - "what is LinkedSpec logical truthiness"
  - "is string zero true in LinkedSpec"
  - "is string false true in LinkedSpec"
  - "are empty arrays truthful in LinkedSpec"
  - "what arity do and or not accept"
  - "are LinkedSpec logical helpers eager"
  - "how do logical helper arity errors work"
  - "does testing a codeblock invoke it"
  - "which ADR defines LinkedSpec logical helpers"
  - "does the logical contract activate codeblock literals"
date: 2026-10-27
status: accepted-target
tags: [logical, truthiness, arity, actionir, codeblock, generated-source, portability, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.1 adopts ADR 0043 and linkedspec-logical-helper-v1. The independent checker validates 17 truthiness rows, ten helper cases, three eager effect scenarios, receiver and lazy-control contrast, four invalid arities, deterministic embedded fixtures, exact projection obligations, and 26 semantic/topology/public drift mutations. Perl .5.2.2, Rust .5.2.3, Dart .5.2.4, Julia .5.2.5, dual-ABI Lua .5.2.6, generated/primary .5.2.7, recurring admission .5.2.8, and public no-drift .5.2.9 consume and lock the unchanged target. Rollout is 8 complete / 0 pending. The explicit-codeblock row remains model/backend-unit evidence and does not activate FUTURE-PARITY-BACKLOG.11 syntax."
evidence_update_2026_08_30_mdbook_reconciliation: "FUTURE-PARITY-BACKLOG.23.2 makes the backend-handoff wording explicitly historical and forbids the two former present-tense `.5.2`-pending statements. Current governance is 19 documents / 14 stale-current denials / 26 mutations at rollout 8 complete / 0 pending; helper semantics, truthiness, arity, evaluation, runtime, and generated behavior remain unchanged."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/logical_receiver_method_contract.t"
  - "bash tools/check_logical_helper_five_backend.sh"
---

The adopted target treats `and`, `or`, and `not` as ordinary boolean value helpers. `and` and `or` accept at
least one positional argument; `not` accepts exactly one. Invalid arity produces `helper_arity_mismatch` with
helper name, actual arity, and expected arity before any operand evaluates. After a valid call is accepted, every
operand evaluates exactly once from left to right. `and`/`or` never short-circuit.

Truthiness is typed:

- null and false are false;
- finite numeric zero, including negative zero, is false; every other finite number is true;
- only the empty string is false, so `"0"`, `"false"`, whitespace, and nonempty Unicode text are true;
- empty arrays and harrays are false; nonempty aggregates are true regardless of their contained values;
- codeblocks are true without invocation.

Every valid logical call returns a real boolean, including one-argument `and(value)` and `or(value)`. Compatible
receiver continuations consume that boolean. `if`, `switch`, and `while` use the same truthiness seam but remain
lazy controls that execute only the selected branch or body.

The codeblock row fixes value-kind behavior only. Because explicit `{|...| ... }` literals remain separately
owned by `FUTURE-PARITY-BACKLOG.11`, the neutral portable source fixture excludes them; backend rollout proves the
row at typed runtime/unit boundaries without silently expanding logical-helper scope.

The target is adopted and current on the Perl reference's native/live/standalone-emitted roles, Rust's native/
serialized/generated-plan/direct-value/compiled-emitted roles, Dart's native/normalized/generated-plan/
standalone-emitted/primary roles, and Julia's native/normalized/generated-plan/standalone-emitted/primary roles.
Lua also conforms through native/reconstructed/generated-plan/loaded-emitted/primary roles on both ABIs.
Generated/primary, recurring admission, and public no-drift are complete at 8 complete / 0 pending. Parent
`FUTURE-PARITY-BACKLOG.5.2` is closed.

Related facts: [[logical-helper-five-backend-audit]], [[callable-codeblock-literal-contract]],
[[cross-backend-condition-truthiness-drift]], [[rust-logical-helper-neutral-runtime]],
[[dart-logical-helper-neutral-runtime]], [[julia-logical-helper-execution]],
[[logical-helper-recurring-five-backend-gate]], [[logical-helper-public-no-drift]].

## Ordinary result breadth (2026-10-26)

TYPE23.2.17 retains public native/fresh producer/nested/fluent/AST distinctions
in probe_logical_results.pl and freezes logical-results.md. Direct text/false
selection/named-selected/typed truth/eager LRC controls pass. Longer Boolean->
cat->split->last emits unsupported cat/null versus nestedX; String-first DSL
composition lacks typed logical-result handoff. Hash-only tail leaves raw DSL;
Array-only tail raises binding_kind_mismatch. Unknown-call scanning also hides
invalid not arity behind unsupported fail/null, unlike direct/nested typed
errors.23.3.17.1 now validates source arity before that scan, uses typed logical
lowering/scalar dispatch and finishes each composed emitted helper through the
existing compatibility bridge.26 focused native/fresh new/direct/literal-default
checks and syntax pass: all three bridgesX, clean boundaries, real Bool/default
copies, eager LRC/SC and typed source errors remain. Retired authored Hash arrows
still reject. Rust/Dart/Julia/Lua17.2-.5 independently assess next; no new logical
methods/truth policy or reopened historical5.2 projection admission.

Rust17.2 adds logical-call scalar dispatch after[]-boundary RED; six focused
native/restored/plan/direct tests pass without producer/error changes. Its
rejected-effect control also catches Perl17.1 skipping valid sources before
incompatible tails. Perl17.1.1 now binds the prior source/prefix once in scalar
context before null rejection;24 focused native/fresh checks retain LR/LRC/S,
skip incompatible consumer operands and preserve malformed-shape preflight.
Dart17.3 is next. No complete result-family admission is claimed.

Dart17.3 tracks actual Bool at fluent entry and after selection:15 focused
native/restored/plan/direct tests and fatal analysis pass after container[]/SA
operand-effect RED. LR/LRC/S, source typed errors, real Bool and strict numeric
rejection remain; named container-context normalization is unchanged. Julia/
Lua17.4-.5 independently assess next; full admission stays separate.

Julia17.4 adds matching actual-Bool tracking after the same[]/SA RED;214 strict
native/plan/fresh/direct assertions pass, explicitly checking Bool identity and
Number-not-Bool counters. Logical/free/named-context/error policies remain;
safe Lua17.5 independently assesses next.

Lua17.5 adds actual-Boolean tracking after shared[] RED on PUC5.5.1/LuaJIT.
Strict native/plan/fresh producer/source-error/shared/rejected-effect/selection
and direct neutral/default checks pass; LR/LRC/S and skipped consumer operands
hold without new module locals or helper/truth policies. All five bounded
implementations are targeted-checked; declared5.4/full admission remain open.

## October27 ordinary logical method target

TYPE23.1.3 selects useful .and/.or/.not receiver counterparts excluded by result17.
logical-receiver-methods.md freezes generic typed inputs/real Bool output: and/or
require one authored RHS or more, not takes none. Source and all valid RHS run
once eagerly left-to-right with snapshots, then compatible consumers. Free unary
projections, typed helper errors, truthiness/lazy controls and callable/deferred/
context/mutation/serialization admission stay unchanged; no neutral JSON rewrite.
Public probe_logical_receivers.pl confirms native/fresh free producers retain
exact Bool kinds while methods leak raw DSL/host compilation and an unlowered
not/coalesce prefix calls an undefined host helper. MethodLowering lacks input
method admission; this is not a free logical/coalesce producer-domain failure.
Perl23.3.23.1 then independent other backends own implementation; do not infer
support or failure elsewhere. Full new-method/domain/context/portable admission
remains23.4 after feature coverage with canonical registration/parity/pressure.
Reverify this bounded intake with the project-data Perl wrapper and
-Iperl docs/checkpoints/type-operation-inventory/probe_logical_receivers.pl;
the existing full neutral reverify above remains for later canonical admission.

Perl23.3.23.1 now implements the ordinary logical methods. Preflight requires
and/or one-plus RHS and not zero; only logical links fold into typed call AST,
with source/prefix/operands preserved. RuntimeLogical and existing actual-Bool
consumer dispatch own evaluation/truth/results, avoiding String/Array input
classification and emitted-host DSL reparsing. New native/fresh PASS20 top-level
tests include source-error subtests; existing result/rejected-prefix checks PASS24
plus syntax. Real Bool/kinds, SRTC, snapshots/container sources, false/default,
numeric rejection/Array recovery and ordinary malformed skip pass. Invalid free
and0/not2 retain typed errors and zero evaluated operands through new methods.
Only Perl method support is established here; Rust23.2 independently follows.
The full neutral command above is broader existing-helper admission, separate
from this new method fixture and later canonical registration23.4.1.
