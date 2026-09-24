---
id: perl-same-line-regex-slot-metadata
title: Perl slot validation omits regex members sharing a line with lifecycle content
answers:
  - why is a named regex slot unknown after an I block on the same line
  - why does a named regex slot before E disappear from selector resolution
  - why does an anonymous regex after I report slot index out of range
  - which repair owns Perl same-line regex slot metadata
date: 2026-09-24
status: reproduced at fb955602e; required repair SESSION-STARTUP-READING.86.5.3 pending
tags: [perl, validation, regex-slots, metadata, source, lifecycle]
evidence: "The five public Get/descriptor controls in docs/checkpoints/SESSION-STARTUP-READING.86.5.3.pl select Done[slot] or Done[0] through an explicit action returning8. Separate I/named-declaration lines retain slot_id=slot and return8/undef for x/y. Named declarations after I, before E or between them fail resolve_selector/regex_slot_unknown_name; an anonymous regex after I fails regex_slot_index_out_of_range. Named div is used, so no slash-call ambiguity is involved."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.5.3.pl; inspect descriptor identity, exact values and typed errors, not exit status alone."
---

`Validation::_validate_inter_match_gap_authored_metadata` accepts a named
slot only when its regex matches the entire physical fragment. Anonymous slots
come only from `_extract_leading_regex_literals_from_fragment`. The subsequent
edge scan tracks braces and selectors but does not revisit declarations after
lifecycle content. Therefore later regex members do not enter the slot list
used by selector resolution. Named declarations with a following E block also
miss the whole-fragment match.

The repair must also reconcile both parser grammar paths:
`BootstrapSpec::Core::_build_named_re_pattern_rule` and `regex_slot_declaration` in
`specs/spec.spec` anchor a declaration to a whole physical line. The permanent
self-hosted grammar remains the authority; the hardcoded parser is its bridge.
Removing only the validation rejection would not establish parsed `RE_SLOT`
identity. These are source-level repair requirements; the five-case public
intake above currently stops at validation and does not prove later execution.

The formal paragraph grammar allows body members on the same line; ADR0045 and
the governed gap contract define a named declaration as one same-line
`REGEX_SLOT_NAME HSPACE* = HSPACE* REGEX` member outside code. This observation
identifies a Perl implementation gap, not a new slot syntax or a cross-backend
claim. `.86.5.3` is required before `.86.5`/`.86.3` close; `.86.5.2.2` remains the
immediate bounded slash repair. Keep lifecycle execution `.27` and bootstrap
regex-brace handling `.54.1` independent.

The standalone named-declaration control is the verified workaround. Matching
only an I assignment's numeric result can hide this failure; explicit slot
selection and descriptor identity expose it without relying on the known
no-edge lifecycle value leak.
