---
id: capture-collection-selection-boundary
title: Read-only capture collection results compose with ordinary Perl typed reads
answers:
  - can entry_map result be indexed directly on Perl
  - can entry_groups feed a signed bracket and String method
  - why does capture helper indexing fail near a closing brace and bracket
  - why did the capture collection probe controls return null
  - is entry_named_map still an accepted source compatibility alias
  - which task repairs contextual callback computed read readiness
date: 2026-10-27
status: Perl25.1 implemented; contextual25.0 repaired; independent Rust25.2 next
tags: [captures, actionir, fluent, selection, perl, codeblock, documentation]
evidence: "TYPE23.1.5 public native/fresh/descriptor/substitution intake and callback-form distinction; ADR0044 resolves the old child-mode teaching."
reverify:
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
