---
id: perl-raw-readiness-source-unit-provenance
title: Raw-expression readiness counts source occurrences with blind-call provenance
answers:
  - "who owns grouped indexed assignment values"
  - "why does a canonical blind call contain a raw AST assignment"
  - "is EmitContext rewrite input always authored action text"
  - "where is the Perl blind-call assignment bridge generated"
  - "would a blanket raw AST walk falsely block blind calls"
  - "do unused raw function bodies block rule readiness"
  - "what do raw_perl_expression_dependencies source spans index"
  - "does raw_perl_dependency_count equal canonical fallback count"
  - "why do rejected keyword calls report raw dependencies"
  - "does readiness describe reached runtime operands"
  - "why does a generated named mark not add raw expression blockers"
  - "does generated lifecycle provenance remove canonical fallbacks"
  - "why are supported legacy wrappers raw in the AST but readiness canonical"
  - "does a canonical return cover unsupported inner operands"
  - "are grouped assignment receivers raw inside deferred codeblocks"
date: 2026-10-25
status: verified source-unit reporting and compatibility at363c79109; quoted/comment/marker successors remain open
tags: [perl, actionir, readiness, blind-call, provenance]
evidence: "Historical .7.1 proof: git show 24e9c72a31b7eb31ce94b09beab9655ae85378cb:docs/knowledge/perl-raw-readiness-source-unit-provenance.md. Exact admission remains363c79109; grouped values are repaired by TYPE-REFERENCE-BOOK.1.2.19."
reverify: "Current grouped values: bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/grouped_assignment_value_contract.t. Reporting proof remains frozen at363c79109; use its historical checkpoint review there, without refreshing captures. Metadata tests: t/actionir_raw_dependency_{metadata,provenance,compatibility}.t and t/actionir_nested_block_source_spans.t."
---

The authored control is:

```spec
Top:: I { i=2 } => Done { return(i+1) }

Done:: I { return("child") }
```

The observation wrapper around EmitContext's rewrite callback sees
`$Top = call(Done);` plus newline and the authored body. The public action AST
marks the generated assignment raw, as well as the authored nested `i+1`.
Yet the canonical fallback count is0; the compiler-owned call bridge is handled
by the existing lowering contract. Treating every raw AST node in this partially
derived unit as authored host code would introduce a false blocker.

BootstrapSpec/Core.pm:841/:883/:923 constructs explicit blind block, fluent and
empty bridges. :1016/:1046/:1073 constructs their bare-edge counterparts.
RuleIR.pm:443 forwards BCODE call/code, and its bare-edge normalization does the
same. EmitContext's `_rewrite_bcode_entries` passes that derived code into the
rewrite wrapper. This refines the proposed diagnostic boundary in
[[perl-nested-raw-readiness-diagnosis]]; ordinary I-action measurements there
remain exact. It does not permit an arbitrary host-assignment/raw-node waiver.

The same completed control population shows repeated raw spans in two original
I-units, and hidden raw expressions across action, AND-local and six additional
lifecycle surfaces. Raw function-body calls currently yield unresolved-helper1/
ready0; a canonical function call is ready, and an unused raw function leaves
the measured Top rule ready. These are descriptor observations, not an executed
function/runtime admission or a complete transitive dependency-count contract.

The initial census used Get(path), although Get requires a source reference.
Its22 shipped entries have no usable readiness metadata; compiler failure
traces and a JSON wide-character printing failure are retained as instrument
evidence. The corrected producer decodes exact file bytes, calls Get(source_ref),
uses UTF-8 JSON and records descriptor kind/context errors. Its complete shipped
results and baseline execution finished before production reporting changes.

## Source-unit reporting contract

The corrected55-row before/after census compiles33 controls and22 tracked shipped
specifications through exact source references, retaining800 rewrite units each.
It reports no descriptor/context/AST failures. All27 raw AST representations are
in controls; shipped units contain zero raw markers. Any assertion about covered
shipped raw nodes is therefore vacuous, not a tested legacy-syntax waiver.

`raw_perl_dependency_count` is the unchanged canonical fallback count plus
uncovered nonempty `unsupported_expression` occurrences. Aliases collapse per
unit/span/reason; equal text at separate spans or units remains separate. A whole
statement already represented by RAW_PERL covers its child raw nodes. Display
and blocker text remains unique. ASTs, canonical events, lowering and runtime
semantics retain their prior meanings.

`raw_perl_expression_dependencies` records source/reason/source_span/source_unit.
`raw_perl_expression_source_units` records kind/index/source, plus blind target.
Spans index that recorded action-unit text, not absolute authored .spec offsets;
normalized fluent units may be derived. Arrays are empty without added raw
expressions. BCODE's exact label/target bridge is separated; authored
bridge-shaped text and mismatched-target units retain their complete source.
The existing assign_call contract canonically owns the supported authored twin;
a genuine adjacent i+1 remains raw with its full-unit offset. The permanent
provenance suite checks these distinctions as well as canonical blind calls.

The collector scans original rule-action/deferred ASTs, not function registries.
The observed referenced/transitive raw-function guards remain unresolved1/ready0;
unused raw functions do not newly block Top. These are bounded observations,
not transitive-function dependency counting or portable infix admission.

Keyword-call controls retain unsupported_expression spans18–27 `value:"x"` and69–79 `second:"y"`. Six supplemental native/fresh before-after records across three seeds preserve AST structure/source except corrected nested coordinates and corresponding serialized payloads, plus the original `user_function_keyword_arguments_unsupported` identity with arguments_evaluated0. The effectful control leaves both actual effect arrays empty. CodeblockRuntime.pm:170–173 rejects these nodes before operands; raw1/ready0 therefore describes source presence, not execution reachability. No keyword waiver or syntax admission follows. Only two old metadata oracles in the605-test composition fixture change; removing their exact insertions/comment recovers every original runtime/source/error/effect assertion. Activation owners fail precisely86/181 against the new expectations; current owners pass605. Complete second canonical failure is losslessly envelope-bound.


`RuleIR::_collect_rule_ir` records generated LE chunks only for semantic MARK_POS
and MOVE_POS entries, retaining exact kind/index/source. EmitContext compares
both slot and bytes before excluding that chunk from added expression scanning;
it still runs the existing canonical rewrite/events. The named mark keeps
ready1/raw0. Three position-marker spellings keep their prior RAW_PERL fallback1,
raw1/ready0; provenance does not erase those old events. An authored identical
later chunk or a changed recorded slot remains scanned. Genuine owner diagnostics
have `canonical_action_ir_events` arrays; opaque delegation payloads and caller
`$@` remain exact. The span suite preserves typed diagnostic identities while
correcting all three missing child-frame handoffs, with nine success forms and
nine diagnostic controls at nonzero bases including nested Unicode/CRLF.
See [[perl-actionir-nested-block-span-loss]] for the historical defect boundary.

Pre-existing generated position-marker fallback classification is owned by
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.4` (P2, after quoted/comment repairs and
before readiness/dispatcher closeout). It must establish the canonical marker
contract before fixing a defect or documenting the precise partial scope.
Healthy runtime equivalence alone does not settle that classification.

## Legacy ownership and ordinary grouping

Exact whole-expression raw nodes owned by sixteen sanctioned fenced legacy
helper contracts retain that canonical ownership, requiring helper_contract
origin and exact event.raw/node.source identity. DECLARE/ASSIGN/call wrappers,
position tracking and bounded capture/printing compatibility forms therefore
keep their established readiness. Generic canonical outer calls never cover
arbitrary raw descendants. Bare return/exit payloads are parsed at their actual
authored offsets; return i+1 reports its inner i+1, not a false whole-statement
dependency or a blanket waiver. Additional diagnostic parsing preserves caller
$@ and retains raw source when parsing fails.

At the reporting revision, ordinary balanced assignment groups decompose to existing typed
assign_scalar/assign_array_append/assign_hash_index/assign_nested_access nodes,
whose children remain scanned. Published ordinary mutation receiver lowering
already supports these nodes. Deferred codeblock descendants are never
decomposed: their executor consumes the original raw AST and still rejects it.
No AST schema, grammar or runtime admission changes.

The complete focused1034 Phase0 run exposed24 metadata failures. Final collector
with original oracles leaves five failures: genuine $x and host map/reference
operands previously absent from reporting. Fourteen exact telemetry assertion
updates in those five subtests preserve sources, plans, values, errors and all
canonical expectations; independent reversal recovers the original fixture.
The final extracted24-body run passes. Full canonical acceptance remains
required; extracted proof is not a complete Phase0 claim.

An attempted unchanged-input replay instead used full wrapper input, including
generated BCODE prefixes absent from actual diagnostic units. It differs only
at blind_edge_raw under the three seeds and is retained as diagnostic evidence,
not unchanged metadata or runtime acceptance. Final proof uses complete fresh
primary/census captures. The initial provenance negative also misclassified a
supported assign_call twin as host raw; its original source/failing stream are
preserved, and corrected tests use genuine adjacent operands and exact offsets.

Canonical landing is now complete at `363c79109ea8498252927547438ade47117ae71e`:
the exact staged candidate passes Phase01034/1034, both primary CLI environments66/66
and all mandatory gate stages; all ten commit doctrines/post-pointer pass and the
receipt is promoted. Optional environment-selected gates are skipped, without a
broader optional-coverage claim. `.0.7.2.0` freezes the focused claim at that
revision and routes quoted-data diagnosis `.0.7.2.1` before implementation.

October25: TYPE-REFERENCE-BOOK.1.2.19 repairs ordinary stored grouped assignments. MethodLowering skipped raw whole-expression ASTs, including the compatibility bridge used by helper operands. It now unwraps only balanced assignment groups into existing typed nodes, preserving inner offsets; function-local declaration discovery follows the same nodes. Native/fresh focused checks cover stored snapshots, arguments, receivers, locals and ordered effects. Parser schema/reporting and deferred raw-group rejection remain unchanged. No broad or portable admission is claimed.
