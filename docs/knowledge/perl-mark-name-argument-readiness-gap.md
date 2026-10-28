---
id: perl-mark-name-argument-readiness-gap
title: Perl ordinary named capture and mark calls share ordered String word-name lowering
answers:
  - "can Perl capture_take accept quoted or computed mark names"
  - "does capture_take with no arguments remain anonymous"
  - "can start_capture_slice_from accept a computed String name"
  - "can capture_from and mark_exists accept computed names in Perl"
  - "do unused named readonly calls evaluate name arguments"
  - "can Perl mark_input_end accept quoted or computed names"
  - "why did standalone named mark writes stay raw while nested statements worked"
  - "when does mark_copy read its source relative to name arguments"
  - "can Perl mark_pos accept a quoted name"
  - "why does mark_pos of cat fail an undefined host helper"
  - "why does quoted capture_len_between report ready1"
  - "which task owns mark-name argument validation and readiness"
date: 2026-10-28
status: bounded42.1/42.2.1-.3 and reversed guards42.5 targeted-checked; sparseAND39 next; wider and bare Unicode42.3 separate
tags: [perl, marks, arguments, readiness, diagnostics, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.34.0 retains actual quoted/evaluated/bare-shadowing controls, source/emitted bytes/metadata/channels in named-mark-number-authority.json.gz."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/mark_name_number_arguments.t"
---

With existing bare begin/finish marks, mark_pos("finish") and quoted two-mark
capture_len_between remain raw in generated Perl and fail undefined mark_pos.
mark_pos(cat("fin","ish")) leaves nested cat raw and fails undefined cat. Both
report raw0/unresolved0/ready1. Native collecting parent returns[null];41 separately
owns real nested error delivery loss, so this is not successful null handling.

Legacy/Contracts native name patterns accept symbolic word arguments, while
known-helper metadata does not reject these unmatched argument roles. The public
catalog uses logical string name signatures and the neutral contract specifies
bare identifiers as symbolic rather than variable reads.42 must reconcile exact
accepted roles before choosing implemented name forms or typed rejection. A host
undefined-subroutine error/ready1 does not define that policy.

The exact diagnostic mechanism is retained: RewritePipeline forwards each
Contracts unresolved_pattern unchanged; Diagnostics::_find_unresolved_action_helpers
counts only that regex in lowered statements. The same symbolic-word pattern
therefore misses quoted/computed calls both for native replacement and unresolved
reporting. RuleIR::EmitContext derives readiness from zero fallback/unresolved
counts rather than successful load/execution. Public substitution and actual
fresh failures distinguish this false-negative from a missing mark.

Owner42 preserves bare-name shadowing, existing arity, evaluation order, Unicode,
source provenance, helper identity and current scopes through the sole argument/
lowering owner. No guessed scalar-to-name conversion or generic helper grant.
34 repairs only existing readonly Number method composition on proven accepted
roles; deferred vocabulary31.6.4.4 and source endpoint40 remain distinct.

## October28 authority42.0 role distinctions

Public13-case intake confirms bare shadowing0/6 and legacy bare numeric mark0
return6 with ready1. Quoted/computed readers and wrong-arity mark_pos remain raw
with ready1; quoted/computed/punctuation/Unicode writers instead already report
raw1/ready0. Do not generalize all unmatched forms into the same metadata result.

The eager block source return(mark_pos({return("finish")})) returns String finish
native/fresh, not a mark offset or typed error. Public substitution and emitted
handler retain literal host return mark_pos({return("finish")}); the inner host
return exits during argument evaluation before undefined mark_pos can run.
Metadata is ready0/unresolved return in this case, so unready metadata alone does
not prevent raw-host control flow.42 owns argument support or pre-effect typed
rejection/local-return discipline, with this exact additional regression before
admission. Initial role producer has one final-output UTF-8 encoding warning;
runtime warning arrays are separately empty. No source/probe warning is called a
product RED, and parser_source_ref yields no native dump; emitted source and public
substitution are the actual retained source proof.

42.0 freezes perl-mark-name-roles.md: preserve bare symbols/legacy numeric token0,
add quoted/evaluated String representations only for existing Perl word keys,
capture names once left-to-right before mark reads, and keep argument returns
local. Julia2/four-route oracles distinguish0/AB/6 and6!/AB. Unsupported known
forms must not execute raw host calls; readiness/diagnostics must name the helper.
42.1 owns seven Number readers,42.2 remaining name operations. Wider nonword/empty
key authority42.3 follows feature coverage before full portable admission and is
canonical for real policy movement. No runtime implementation in authority leaf.
Exact inputs/producer epochs/results: perl-mark-name-role-authority.json.gz.

## Current bounded reader repair42.1

Seven ordinary Number readers now accept quoted and evaluated actual String
values yielding existing Word keys. Bare names remain symbolic, including legacy
numeric token0. The sole original Contracts bodies now take either quoted native
symbols or captured name expressions; all seven original public bodies remain
byte-identical. One MethodLowering argument owner captures names once left-to-right
before any mark read. The name2-writes-begin oracle yields0/AB/6, and an argument
local return skipsX before a later consumer, giving6!/AB. A smaller operand must
use the existing value-branch owner to clear its parent's recursion fence; public
emitted source isolates the first candidate's raw-block failure and final repair.

Unchanged18 authored groups fail17 before code,1 in the first candidate, then pass18.
Exact local-return1, nearest reset/named2 and both module syntax pass. Static bad
arity/unknown/direct-return roles use helper-specific unready placeholders before
effects. Actual runtime Number/Array, empty and nonword String results use controlled
LINKEDSPEC_MARK_NAME_ARGUMENT failures in fresh generated execution; fully lowered
syntax can remain ready1. The native collecting parent still loses these real
errors under41, and its null is never credited as a valid result. Pure-function7
fences remain specific/unready. Exact producer/source/result epochs are retained
in mark-name-number-reader-intake.json.gz. Historical gap descriptions above are
before-state evidence. Remaining ordinary names42.2, bare Unicode/wider keys42.3,
deferred vocabulary31.6.4.4 and full source/context23.4 admission remain separate.

Source-identity review also distinguishes lowering a trimmed local copy from
mutating authored argument bytes. Direct probe has one failing assertion before
the local-copy fix; both assertions and the unchanged18-source final rerun pass
afterward. Packet retains the earlier18-green epoch and exact final source/result.

## Current ordinary statement repair42.2.1

Ten writer/copy/clear statements now reuse42.1 ordered String word-name capture
and validation through sole original native bodies. All ten public/native bodies
remain byte-identical, including trace operation/name/positions and legacy returns.
The first candidate supports nested nonfinal statements but the standalone scanner
and Contracts statement-call recognizers omit writers. Public emitted/substitution
twins show raw1/ready0 standalone versus no raw writer/raw0/ready1 nested. One shared
Contracts method regex now connects the existing statement scanner/contract handoff.
No new AST/helper/schema or writer-as-value/fluent/deferred rights are introduced.

Unchanged16-source groups fail14 before code,12 first candidate, then pass16;
nearest complete named contract3 and three module syntax pass. Name snapshots,
source-read order, local returns, zero/missing/symbolic/numeric0 and quoted Unicode
word Strings work. Static bad arity/unknown/direct-return/value roles use specific
unready diagnostics; runtime invalid names produce controlled fresh errors, with
native delivery41 still open. Quoted Unicode String keys do not widen working-
variable grammar or claim bare Unicode readiness42.3. Remaining readonly42.2.2 and
advancing42.2.3 are next. Exact evidence: mark-name-write-statement-intake.json.gz.

## Readonly text/predicate and unused statements42.2.2

Four named text readers and mark_exists now share ordered String word-name
lowering with Number readers. Five original bodies remain byte-identical, as do
final historical7 Number/10 writer probes. The readonly call owner selects each
original body/arity without changing its value/kind, endpoints or empty/absence
rules. Independent public substitution exposed all12 computed unused readonly
calls still raw; shared scanner/contract statement recognition now routes them
through existing value lowering and discards results. The combined runtime oracle
observes all12 name effects once in order. No new method/value/deferred rights.

Final scoped16 pass; nearest Number order/function2 and three module syntax pass.
Initial16 has15 failures including one invalid new test line break before .cat;
candidate fixes14 valid failures, leaving only that invalid layout. Public source
twin and [[terse-statement-separator-contract]] confirm a depth-zero newline starts
a new statement. Join only that fixture expression and use ASCII JSON diagnostic
output to remove Test2 formatter warnings; exact inverse preserves other15 cases.
Production is unchanged for the refinement, with no extra product RED credit.
Actual epochs: mark-name-readonly-text-intake.json.gz. Advancing42.2.3, native
delivery41, bare Unicode/wider42.3 and full source-context23.4 remain separate.

## Advancing value and bridge names42.2.3

Eight named take values now use the same ordered names through sole original
bodies. New bridge name expressions use statement roles; existing bare bound
result0 remains legacy. Zero-arg capture_take value and unused anonymous effects
retain their old owner. All22 unchanged source groups go17failed to22pass; five
old controls were already healthy. Original9 named bodies and final historical7
Number/5 text/10 writer controls remain byte-identical, including old until-cursor
trace spellings. Nearest readonly ordering2 and both changed module syntax pass.
String/Number snapshots, empty/zero/missing/guarded-reversed spans, distinct local/
cursor/EOF/between advances, Unicode word Strings/EOF bridge, local returns/order,
specific static/runtime guards and all9 function fences are preserved.

Before-code19 legacy sources expose two different old local-start take reversed
errors. [[perl-local-start-named-take-reversed-span-gap]] owns42.5 immediately next;
they are not credited as correct undef behavior. Native child loss41 and pre-match
endpoint40 stay separate. mark-name-advancing-intake.json.gz retains feature22
and exact source/body inputs; mark-advance-legacy-intake.json.gz retains independent
legacy19 and strict four-line framework-prefix handling, including initial JSON
reader instrumentation failure. Wider/bare Unicode42.3/full23.4 remain open.

42.5 now fixes the two old local-start take reversed guards in their shared
factory. Current11 groups8RED/final11pass, nearest2 and syntax pass; exact2-body
change/7-body equality is retained in named-take-reversed-span-intake.json.gz.
Earlier31/nine-body equality describes the preceding name-feature epoch, not
the later behavior fix. [[perl-local-start-named-take-reversed-span-gap]] records
continuation/equal/missing-silence proof and remaining40/41/admission limits.
