---
id: perl-legacy-mark-control-source-origins
title: Legacy mark-control origins retain target/source arguments in their original event
answers:
  - "which Legacy mark-control producers retain source origins"
  - "does mark_copy provenance preserve target then source order"
  - "does private source text overwrite the mark_copy source argument"
  - "do mark query and clearing origins retain actual argument references"
  - "does mark provenance close the missing-source clearing observation gap"
date: 2026-10-06
status: focused mark-control source-provenance acceptance verified
tags: [perl, actionir, legacy, marks, source-provenance]
evidence: "All14 mark-control regex producers preserve original symbolic mark/target-source order, physical bounds and actual event/argument identities. 4438 immutable originals/three overlays/eight commands retain112 contracts/115 cases/227 events under three seeds; private origins105→133. Original RED14/GREEN81; eleven suites1259 groups including Phase01035 and148 evidence RED pass. Book58 inputs/nine examples/three chapters/17 RED and33-hash historical freeze pass. Public compiler/callback channels and original grammar remain exact; missing-source clearing observation .2.7 and wrapper startup .7 remain separately owned."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_helper_source_provenance.t t/complete_named_mark_contract.t"
  - "The .1.4.4 review is historical at907934281c4422baba6ef6580bd4080663c87e9e; current cursor/input .1.4.5 recurrence preserves all mark origins."
---

# Original mark arguments and private physical source have distinct roles

The14 Legacy mark-control producers retain their original regexes and argument
expressions. Each saves $-[0]/$+[0] before constructing the event, then passes
that exact event/argument object through the existing private source recorder.
The family is mark_here, mark_input_start/end, mark_entry_start/end,
mark_match_start/end, mark_copy, mark_capture_slice, clear_mark, mark_exists,
mark_pos, mark_line and mark_col. No equal-raw lookup supplies a source interval.

mark_copy(first, second) preserves target first and source second. The source
mark remains event.args.source; original action text belongs to the private
origin.source. Neither changes the other. Query and clearing calls retain their
original symbolic mark names, raw calls and public schema. Actual constructor,
returned event and argument references distinguish equal-valued copies.

The unchanged original115-case literal fixture carries independently authored
Unicode/CRLF repeated scalar intervals and mark-copy order. Stable contract IDs
select the reversed-copy, original uninstrumented mark and current cursor
corruption controls; a family guard prevents the prior ordinal label mistake.
Previously verified call/anonymous/named origins remain in the all112 recurrence.

This leaf changes source provenance, not mark storage or runtime semantics.
The existing missing-source mark_copy test never seeds its target and therefore
cannot distinguish deletion from doing nothing. CONFORMANCE-SOURCE-READING.2.7
owns that observation repair after its prerequisites; production clearing was
separately distinguished by its retained seeded control. See the mark-copy
section of [[conformance-perl-consumer-reading]]. This source acceptance cannot
close that unrelated fixture gap.

Cursor/input origins now belong to [[perl-legacy-cursor-input-source-origins]].
Entry/match producers, executable quoted/comment membership,
source-based replacement and other backends remain separately owned. Wrapper
startup .7 still owns group-establishment/denied-liveness repair; recovery/purge
remain prohibited and provenance tests admit no lifecycle guarantee.
