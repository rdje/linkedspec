---
id: capture-collection-selection-boundary
title: Read-only capture collection results compose with ordinary typed reads
answers:
  - can entry_map result be indexed directly on Perl
  - can entry_groups feed a signed bracket and String method
  - why does capture helper indexing fail near a closing brace and bracket
  - why did the capture collection probe controls return null
  - is entry_named_map still an accepted source compatibility alias
  - which task repairs contextual callback computed read readiness
  - why does Rust capture selection evaluate incompatible method operands
  - how do Dart named-map aliases receive capture result kind guards
  - how does Julia guard capture collection selection through with
date: 2026-10-27
status: bounded Perl25.1/Rust25.2/Dart25.3/Julia25.4 implemented; safe Lua25.5 next
tags: [captures, actionir, fluent, selection, perl, codeblock, documentation]
evidence: "TYPE23.1.5 public native/fresh/descriptor/substitution intake and callback-form distinction; ADR0044 resolves the old child-mode teaching."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/capture_collection_selection_test.jl\")'"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/capture_collection_selection_test.dart"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test capture_collection_selection"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/capture_collection_selection.t"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_capture_collection_selection.pl default"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_contextual_selection_boundary.pl"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/check_capture_collection_examples.pl"
---

At intake d0551dcc, existing entry_groups/entry_map/match_groups/match_map produce ordinary capture
Array/Hash snapshots. Native/fresh producers, named readers, existing fluent
methods, copy bridges and accepted entry_named_map/match_named_map aliases retain
their values, raw0/unresolved0/ready1. Direct four-helper postfix reads instead
fail child-handler/fresh-source compilation, raw4/unresolved0/ready0. Substitution
lowers the getters to do blocks but leaves raw bracket suffixes. TYPE25 owns the
bounded ordinary read class, not new capture operations or context privileges.

The first intake reused the old AND-child teaching and produced [null] controls.
Scoped runtime trace shows parent entry consumption to cursor4 followed by the
AND child's required slot0 match at that cursor. ADR0044/sparse-AND authority
requires this behavior. A default child establishes healthy entry/local controls;
three actual book examples and their old fact are corrected explicitly. The
retired-alias label is corrected against accepted source-boundary authority and
public alias values. See [[entry-match-divergence-verified-shape]].

The new source-class assessment also catches a P1 deferred grammar defect:
explicit callbacks report unsupported_codeblock_actionir/raw_perl/raw1/unready,
but attached/parenthesized registered callbacks with the same helper or literal
read carry unsupported value_access/raw0/ready1. Parser clears only registry-based
recognition in that role; helper/noncall admission remains active before
CallableContract transports the AST to CodeblockRuntime.25.0 must preserve the
explicit-literal vocabulary using actual final-slot signature/count ownership;
immediate/inline helpers retain their broader compiled bodies. No new deferred
operation is selected.25.0 restores that boundary by localizing the existing
deferred grammar flag only in the recognized registered final callback role;
ordinary arguments and builtin inline blocks remain compiled. Its retained
native/fresh/metadata/span/scope controls pass. See [[perl-generic-final-codeblock-normalization]] and
[[computed-value-selection-boundary]].

Frozen target/input/oracle, retained intake and scheduled children are in
docs/checkpoints/type-operation-inventory/capture-collection-selection.md.
Full source/context/portable/generated admission remains23.4; Lua uses only
available safe hosts until its declared-primary/native-formatting owners resolve.


Perl25.1 adds exactly these six already-known collection names to the existing
static computed-source classifier. Their old getters already box capture
Array/Hash snapshots; the existing value_access lowerer/read builder evaluates
that source once and ordered selectors, and selected-result dispatch owns actual-
kind guards. No getter, cursor, matching, copy depth, schema or executor changes.
The original6/18 failing target/parser controls resolve; the expanded regression
also checks all six source names in explicit and both contextual deferred forms.
The unchanged shared fixture passes native/fresh with raw0/unresolved0/ready1,
including entry/local divergence, signed/missing paths, IJ ordering, incompatible
operand skips and bridges. Finite String zero/empty/optional-capture compaction,
static helper shadowing, absent-capture and Unicode-span controls preserve current
contracts. Other context/control/unknown/grouped/flat sources remain excluded.
Independent Rust25.2 follows; full admission stays23.4.


Rust25.2 independently parses/read-selects capture calls already, but its static
ordinary-computed classifier excludes them. Before production the new four-test
probe records three failing cases and one healthy String/empty/compaction/static-
name case. Shared wrong-kind consumers return [[],name,AKV]; aliases/with also
run incompatible operands, and six missing collection selections yield legacy
counts0. All three execution routes agree on those observations. The repair adds
exactly the six existing capture helper spellings to is_ordinary_computed_read;
existing selected-result guards and persistent with tracking then reject before
operands, without changing the reader, getters, parser or representation. Four
new tests pass native/restored CompiledSpec/generated plan, including the unchanged
shared oracle; six direct computed controls also pass. Bound-call counts0/0 and
other context/flat count policies remain unchanged. No standalone emitted crate
or full context/portable admission; independent Dart25.3 follows.


Dart25.3 independently observes3 failing/1 healthy capture cases on native,
restoredSpec and generated plan: source/read values already work, but wrong-kind
consumers run operands and missing captures retain counts0. The static classifier
canonicalizes aliases before testing receiver/helper ownership, so adding only
four canonical capture names covers all six spellings. Existing kindGuardedResult
persists through with and bridges. New4 and direct computed7 pass all routes;
String zero/empty/compaction/static names and bound/context/flat count controls
stay unchanged. Format/fatal analyze pass; no parser/getter/read/codec or deferred
vocabulary change. Independent Julia25.4 follows; full admission remains23.4.


Julia25.4 independently records9 RED route assertions/3 healthy String-kind
controls across native/plan/fresh modules. Existing boxed capture getters and
readers preserve the values, but _runtime_is_ordinary_computed_read excludes the
four canonical capture names. Adding those names reuses alias normalization and
persistent actual-kind guards through with/bridges. New registered capture12 and
direct computed25 pass with strict recursive Bool/Number/String/null/container
comparison. Shared target, aliases/operand skips, compaction/static names and
bound/context/flat count controls agree; no parser/getter/read/compiled/executor
field change. Safe Lua25.5 follows; full admission stays23.4.
