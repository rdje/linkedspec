---
id: perl-multiline-helper-pattern-validation
title: Perl helper patterns retain structure and statement boundaries through validation and lowering
answers:
  - why does presence tracking break an escaped raw regex
  - why does an assigned multiline raw regex gain a semicolon
  - how does Perl validate a multiline regex helper operand
  - can rule like text inside a helper pattern become a rule or capture directive
  - does Perl preserve CRLF in an action regex pattern
  - why did multiline regex substitution fail after validation succeeded
  - which task fixes multiline matches followed by a newline statement
  - why does a quoted multiline regex subject fail validation
  - why does closing y slash swallow the next action statement
  - can Perl action strings contain physical newlines
  - how does validation distinguish quoted rule labels from real rules
date: 2026-10-23
status: scoped helper/recomposition and presence compatibility verified; raw payload fidelity remains owned
tags: [perl, validation, regex, source, diagnostics]
evidence: "SESSION-STARTUP-READING.86.4.3 passes six regression groups, focused173 and complete Phase0 1033/1033. .86.4.6 expands the consumer to seven groups: isolated committed d2af200325 fails groups5/7; candidate focused action suite passes52 top-level tests across four files. Both retained division controls independently/publicly return7; complete Phase0 passes1033/1033 in1545 seconds with the seven-group consumer. Both complete mdBook examples pass11 directly extracted live/generated assertions and rendering succeeds. .86.4.7 passes the expanded nine-group consumer, focused198, exact book16 and Phase0 1033/1033 in1276 seconds. No cross-backend or whole helper-family closeout follows."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/multiline_helper_pattern_validation.t t/phase0_validation_fuzz.t t/inter_match_gap_capture_perl_contract.t t/duplicate_regex_slot_identity_perl_contract.t t/sparse_and_action_slots_perl_regression.t t/actionir_ast_parser.t t/uniform_binding_contract.t t/callable_codeblock_literal_contract.t"
---

# Current helper and compatibility boundaries

Validation::_helper_pattern_validation_view masks complete multiline helper regexes and quoted tokens only
inside expression scopes. It preserves every character position and CR/LF; compilation uses the original
source. Structural-looking rule/directive payloads stay inside the operand. Real repeated malformed headers
retain cumulative physical-line attribution, including the measured line7 control. Bare/unclosed strings
and open blocks still reject.

StatementSplit::Mode recognizes naked helper patterns at parenthesized argument boundaries, using MethodExpr's
existing slash-call discriminator. This prevents a closing y/ from reopening translation state and swallowing
the following statement or endif. Assignment-position slash interpretation remains separate and line based.
Validation's full-source regex-first retry and final-block division precedence are governed by
[[perl-slash-call-outer-block-validation]], including the later .86.5 physical-line/same-line/slot repairs.
The shared closing-brace safeguard is unchanged.

The original multiline failures involved regex_subst, matches followed by note=7, and matches before endif.
Both lowered/raw helper contexts and whole-source validation must be checked: a valid isolated fragment does
not prove its surrounding spec. Source diagnostics use public Get/runtime_ctx_ref, call_spec_handler_subst,
return_descriptor and dump_parser_source. Use an explicit action edge for return evidence; legacy no-edge
I/regex/E values do not independently establish E execution.

## Presence compatibility (October23)

TYPE-REFERENCE-BOOK.1.2.12's broader caller-slot tracking exposed two regressions. A tracked statement assignment
ended in flag=1, replacing the assigned lifecycle value. MethodLowering::_tracked_scalar_assignment_expr now
returns the assigned value. The compatibility splitter can pass an incomplete naked regex before its next
physical source fragment supplies the closing slash. Inserting a flag wrapper there changed the pattern and
left unmatched braces. The emitter now leaves that incomplete fragment intact; complete canonical assignments
keep their presence updates. Tracked-assignment-trace2 and compatibility2 under
docs/checkpoints/type-deferred-indexed-writes/ retain the exact caller/RHS/source and native/fresh controls.

The legacy raw-regex probe supplies Perl's default subject explicitly. The first repaired probe instead
reported an uninitialized-$_ warning on fresh execution; accepted24e9 has the same warning and value7.
That rejected quietness check is an instrument limitation, not a remaining compilation failure. Its exact
source/channels remain retained. The first trace instrument's CODE serialization failure also receives no credit.

A separate P2 defect remains: joining incomplete raw-regex fragments inserts a semicolon into the pattern.
Two LF subjects distinguish the authored pattern from that altered pattern. Native/fresh execution on both
accepted24e9 and repaired12 agrees with the inserted-semicolon oracle and disagrees with the authored oracle.
compatibility2.json.gz and raw_regex_oracle.pl retain the complete source/subject/producer/rollback evidence.
TYPE-REFERENCE-BOOK.1.2.21 owns repair after grouped19, before policy20/inventory. Use documented matches helpers
for multiline patterns; no general raw-host regex fidelity or portable raw-host capability is admitted here.
Bootstrap .54.1 and attached-tail .9 retain their distinct unescaped-brace obligations.

## Historical verification

The complete pre-update card, original reproductions and detailed historical scopes remain recoverable with
git show 24e9c72a31b7eb31ce94b09beab9655ae85378cb:docs/knowledge/perl-multiline-helper-pattern-validation.md.
This contains the unchanged textual-backslash-n versus physical-LF finding owned by
SUPPORTING-SOURCE-READING.2.4; this regex work selects no new string escape semantics.

- .86.4.3: six groups, focused173, complete Phase01033/1033.
- .86.4.6: seven groups; clean d2af200325 fails5/7; four files/52 focused tests; both division controls return7;
  book11 and Phase01033/1033 in1545s. LF/CRLF, eight host-operator-like suffixes, punctuation, once-only mutation,
  nested numeric operands and following statements/terminators remain covered.
- .86.4.7: nine groups; clean36df52e46 fails8/9; eight files/198 focused tests; book16 and Phase01033/1033 in1276s.
  Both quote styles, leading/trailing LF/CRLF, returned literals, inline helpers and substitutions retain their
  values. Four independently emitted substitution parsers and all four escape-route records remain exact.
- .86.4.8.2: grouped-operand repair, focused187/book21/Phase01033. Final .86.4.4.2.2 recomposition has59 controls:
  helper13, grouped22, numeric12 and original12, with the full syntax-node record unchanged. The checkpoint is
  docs/checkpoints/SESSION-STARTUP-READING.86.4.4.2.2.pl. Its malformed quoted regex remains rule_handler_compile
  with Unmatched ); its dated EOF failures were followed by the separately verified .86.5 repairs.
- Fresh generated bootstrap tracing is covered by [[perl-generated-source-cold-trace-dependency]]. Four exact
  Markdown specs and production/tests match9f81d3162, with focused173/book66 and two documentation mutation
  controls. This closes the scoped recomposition, not every helper family or inherited repair owner.

Related: [[perl-grouped-regex-operand-boundaries]], [[single-quoted-action-strings-variant-contract]],
[[write-vivification-perl-reference]].
