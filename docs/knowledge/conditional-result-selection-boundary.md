---
id: conditional-result-selection-boundary
title: Inline conditional values compose with ordinary Perl typed bracket reads
answers:
  - can an inline if or switch result be indexed directly
  - do inline conditional results already support direct methods on Perl
  - why does an eager block in an inline if condition fail compilation
  - why is an inline condition ready when generated Perl is invalid
  - does a switch subject block have the same failure as an if condition
  - which task owns conditional result bracket composition
  - why did is_defined false select the wrong inline condition branch
  - why did a named early-return block work while an inline payload failed
  - why does a one-argument switch remain outside computed read sources
  - how does Rust distinguish inline conditional result guards from headers
  - why must Dart inline result guards inspect sourceMethod and trailingBlockArg
date: 2026-10-27
status: producer26.0 repaired; bounded Perl26.1/Rust26.2/Dart26.3 implemented; independent Julia26.4 next
tags: [perl, actionir, control, selection, fluent, laziness]
evidence: "TYPE23.1.6 finite public native/fresh/descriptor/substitution and AST intake at fcfb7dcdc; ADR0007/current inline-value authority."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/conditional_selection_test.dart"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test conditional_selection"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/conditional_selection.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/inline_condition_value_blocks.t"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_conditional_result_composition.pl"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_conditional_result_composition.pl --condition-controls"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_conditional_result_composition.pl --ast-controls"
---

Existing inline if/switch producers and named reads work on native/fresh Perl,
as do direct Array-to-String and scalar method chains. They retain raw0,
unresolved0 and ready1. Direct bracket suffixes instead remain raw AST and fail
handler/fresh-source compilation, raw2/unready. The static computed-source owner
excludes these names. Family26 admits only existing inline value-control results,
preserving lazy selection, actual kinds, ordered reads and other control roles.

The laziness probe also exposes a distinct P1 producer defect: an eager first or
elseif condition block is typed/ready1/raw0 but remains authored DSL inside
RuntimeLogical::truthy in emitted Perl. _lower_inline_if_value_expr sends these
conditions through lower_flow_composite_expr, while branch payloads and switch
subjects use value/block lowering. The named-condition counterfactual returns
[[a,b],CT]; direct branch-only and switch-subject blocks return T and ST. Actual
native/fresh compile errors, substitution and exact programs are retained in the
conditional intake packets.26.0 repairs that producer before26.1 read expansion;
readiness must describe working lowering rather than being waived.

The frozen target and future shared fixture live under
docs/checkpoints/type-operation-inventory/conditional-result-selection.md.
Independent backend children follow Perl; full source/context/portable/generated
admission remains23.4. No new helper/type/schema or callback vocabulary is selected.


Producer26.0 now lowers first/elseif conditions through the existing value-payload
owner before RuntimeLogical truthiness. The old route also treated the Bool literal
in is_defined(false) as $false: standalone [1,bad] versus a successful named
predicate counterfactual distinguishes the mislowering; the extra predicate packet
retains actual native/fresh observations at92da37128 before production changes.
No predicate or truthiness contract changes.

The first two-site candidate repairs basic blocks/predicates, but early-return
condition and payload blocks still fail while an identical named block succeeds.
Its exact source delta is inline-condition-two-site-candidate.patch.gz against92da37128;
inline-condition-return-candidate-intake.json records that candidate epoch, not a
clean-base execution. The parent's same-expression AST compatibility fence leaked
to child operands, suppressing typed blocks/terminal assignments. The inline value
operand wrapper now copies dependencies and removes only that fence, allowing the
smaller child to use existing AST lowering without mutating its parent or siblings.
No new AST/schema/executor or deferred operation is introduced. Retained regression
covers native/fresh working lowering/ready metadata, lazy ordered conditions,
local early returns, function-local slots, existing direct methods, typed predicates
and nested conditionals. Conditional bracket expansion26.1 follows separately.


Perl26.1 passes the complete parsed Call into its static computed-source predicate.
Canonical inline if/switch calls with value arity and no attached block join the
existing value_access reader/result guards. One-operand headers are control_if/
control_switch AST nodes, not value Call nodes; marker aliases and unrelated
controls remain excluded. The initial zero-branch prototype is not part of this
role. The final authored baseline fails12/43; all43 pass after this narrow change,
including the unchanged shared target, actual Bool/Number/String/null/container
kinds, CTIM lazy order, snapshots, signed/missing/IJ paths, operand skips, bridges,
function-local selector/condition slots, Unicode spans and original source errors.
Explicit and both contextual callbacks retain raw AST; actual callback execution
keeps raw_perl rejection/raw1/unready. Ordinary metadata is raw0/unresolved0/ready1.
No parser node/schema/read-builder/executor field or wider control role is added.
Independent Rust26.2 follows; full admission stays23.4.


Rust26.2 independently observes3 failed cases/1 healthy lazy/local-return case
across native/restored CompiledSpec/plan. Its parser, lazy dispatcher and reader
already work; the static computed-result classifier excludes if/switch sources.
Recognizing those canonical Call names only with payload arity enables existing
actual-kind/with guards. Four new and six direct computed tests pass. Shared
kinds/CTIM/snapshots/IJ/bridges, CETM/local returns and old header/bound/flat counts
remain; wrong-kind operands skip and missing inline counts become null. No parser,
reader, serde, equality or deferred vocabulary change. Dart26.3 follows; full
source/context/portable/generated admission stays23.4.


Dart26.3 independently observes3 RED result cases/2 healthy lazy/AST cases. The
same missing static source flag bypasses existing actual-kind guards. Alias
canonicalization maps i/when to if, so guard admission checks canonical name plus
sourceMethod, payload arity and no trailingBlockArg. Four new execution cases pass native/restoredSpec/plan; a native parser group
and seven direct computed tests also pass. Shared kinds/CTIM/snapshots/IJ/bridges,
with operand skips and CETM/local returns pass; headers/i-alias/bound/flat counts0
and parsed role fields stay unchanged. Format/fatal analyze pass; no parser/read/
codec/truth/equality or deferred vocabulary change. Julia26.4 follows; full
admission stays23.4.
