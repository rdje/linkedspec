---
id: perl-blind-latest-child-retv-binding
title: Perl blind-call bridge publishes latest child retv before attached code and IT
answers:
  - "why does Perl repeated blind post-call retv return null while Dart returns a child value"
  - "where does Perl bind the latest child result before blind attached code and IT"
  - "how does Perl blind child binding preserve authored source diagnostics"
date: 2026-10-28
status: bounded39.2.5.1 repaired/targeted-checked; Dart return/progress39.2.5.2 and admission open
tags: [perl, blind-call, retv, compiler-bridge, source-provenance, generated-source]
evidence: "perl-blind-retv-intake.json.gz retains10 native/fresh groups11 inputs2healthy8actualRED ->10pass, exact source/v2 metadata and sole emitted binding delta,4 source/provenance/compatibility/recursion suites61groups and syntax."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/blind_child_retv.t t/actionir_raw_dependency_provenance.t t/actionir_raw_dependency_metadata.t t/actionir_raw_dependency_compatibility.t t/shared_rule_progress_guard.t"
---

Core's generated blind bridge assigns the child's value to the parent rule
scalar. Previously attached code and repeated inner IT could read lexical
retv before its later outer binding, yielding null/stale values despite a
successful child. Existing published latest-child contract requires that
binding before attached code, independent of post-call return scope.

_rewrite_bcode_entries recognizes the exact Core-owned source bridge, retains
original full lowering/diagnostics and compiles that same bridge with the same
owner. Its exact emitted prefix identifies the insertion boundary; retv is
assigned after the existing child invocation, before authored code can return.
Compiler prefix drift fails closed. Mismatched bridges retain complete original
diagnostic source. No generic call primitive, bootstrap parser or variant emitter
change, duplicate invocation or authored-code pattern matching is introduced.

Ten normal public native/fresh groups11 input rows retain two healthy controls
and eight actual baseline failures. Fixed10pass: plain/AND/repeated retv, IT/E,
nonreturn effects, stale/override, nested and zero values/cursors agree. Exact
DSL sources and v2 metadata remain identical; removing each sole added binding
recovers byte-identical prior emitted source. Source-provenance/metadata/
compatibility/shared recursion four suites61groups and syntax pass. Direct
chained-assignment preview did not lower call and was rejected before production;
its diagnostic is retained without product RED credit.

Regenerate old standalone Perl parsers to obtain this body change. Original
DSL/v2 plan/families/schema remain compatible. t/blind_child_retv.t is owned by
explicit canonical registration23.4.1 before admission. Dart repeated post-call
return/count/minimum/progress39.2.5.2 follows; reference accepted-bit39.9,
broader lifecycle and full admission are not inferred repaired.
