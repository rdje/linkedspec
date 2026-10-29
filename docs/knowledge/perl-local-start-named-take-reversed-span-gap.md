---
id: perl-local-start-named-take-reversed-span-gap
title: Perl named local-start take helpers now guard documented reversed spans
answers:
  - "why does capture_take of a later mark throw source_location_reversed_span"
  - "does capture_take_len_from return undef on a reversed span in Perl"
  - "which task owns reversed named local-start take guards"
  - "why does native capture_take return null while generated execution throws"
date: 2026-10-28
status: Perl47.1 named endpoint/range repair focused-verified; independent47.2-.5/writer49/wider42.3/selection/full admission separate
tags: [perl, capture, marks, spans, errors, generated-source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.42.2.3 public19-case legacy intake at clean14c41151e; mark-advance-legacy-intake.json.gz retains exact producer/source/native/fresh/metadata/substitution and strict raw stdout prefix handling."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/named_take_reversed_span.t"
---

## Historical before-state

Onαβ:catTAIL at Value[2], finish is input end10, local match starts3,
live cursor6 and capture boundary2. Both existing bare-word capture_take(finish)
and capture_take_len_from(finish) throw fresh source_location_reversed_span,
start10/end3, while raw0/unresolved0/ready1. Native collecting parent returns
[null] and loses the child error under41; that is not valid undef/no-advance proof.
Four related until-cursor/between reversed forms correctly return undef and
preserve mark10/boundary2/cursor6 native/fresh. Ordinary8, missing8, bridge normal/
missing/bound-result and zero-arg anonymous controls distinguish existing roles.

Public substitution and original Contracts callbacks show only defined(mark)
before span_text/span_length in the two local-start takes. SourceLocation::Runtime
::_span calls direct_span, which correctly rejects reversed ranges. The published
named-span reference promises undef for reversed spans;42.5 owns the missing
helper guards, immediately after42.2.3 commits the name representations. Do not
weaken typed span validation, normalize operation/trace identities, add helper/
domain/deferred rights or silently redefine reversed spans. Pre-match endpoint40
and native child-error delivery41 remain distinct repairs.

42.2.3 now moves the two unchanged native strings into the sole shared
Contracts::_named_mark_advance_body_expr; original9 identities and22 name-source
groups pass without altering this known range defect.42.5 repairs that factory
immediately after the clean name-feature commit, before39.

## Current repaired42.5

The two shared branches now cache legacy local end once only if the mark exists
and check non-reversal before projection/write. Low-level typed span validation
is unchanged. Current unchanged11-source baseline fails8; final11 pass. Six
Word/quoted/computed reversals and two repeated uses produce full continued
post-call tuples with unchanged mark/capture boundary/cursor; native parent null
alone cannot pass. Equal empty String/Number0 remain defined and advance normally;
missing-before-match returns legitimate nulls without warnings. Nearest eight-
helper quoted/effect matrix plus anonymous0 overload2 and module syntax pass.
Exactly two public bodies change, other7 advancing/bridge bodies are identical.
Actual source/input/result/body/patch epochs: named-take-reversed-span-intake.json.gz.
Present-mark pre-match authority40 and native child error delivery41 stay open;
no new domain/role/deferred or full portable admission. SparseAND39.0 follows.

2026-10-29 Perl47.1 guards missing local endpoints in all four named match-start
bodies and readonly reversals through existing sole Contracts factories.15-source
7healthy8RED ->15pass native/separate clean+seeded; ordinary15 groups8RED ->15pass.
Endpoint15/range11/Number target-snapshot-function3 pass29 groups and syntax.
Public33 bodies exactly4 changed/29 unchanged, retaining name/effect/trace/available
endpoint/writer/anonymous semantics and full metadata. Prior byte identities are
historical pre-repair epochs. Old15 modules retain original outcomes in30 calls
and require regeneration. [[perl-named-capture-endpoint-presence-repair]] retains
actual proof/limits. Peers/writer49/wider domains/canonical selection/admission
remain independent; no new helper/key/schema/frame or argument-role policy.
