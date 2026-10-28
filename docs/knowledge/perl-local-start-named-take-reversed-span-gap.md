---
id: perl-local-start-named-take-reversed-span-gap
title: Perl named local-start take helpers omit the documented reversed-span guard
answers:
  - "why does capture_take of a later mark throw source_location_reversed_span"
  - "does capture_take_len_from return undef on a reversed span in Perl"
  - "which task owns reversed named local-start take guards"
  - "why does native capture_take return null while generated execution throws"
date: 2026-10-28
status: owned42.5 P1 immediately after42.2.3 before39/full admission
tags: [perl, capture, marks, spans, errors, generated-source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.42.2.3 public19-case legacy intake at clean14c41151e; mark-advance-legacy-intake.json.gz retains exact producer/source/native/fresh/metadata/substitution and strict raw stdout prefix handling."
reverify: "Recover probe_mark_advance_legacy.pl and use bash tools/project_data_run.sh env PERL5LIB= perl -Iperl with reversed_capture_take reversed_capture_take_len_from labels; the output includes known framework diagnostics before one JSON object."
---

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
