---
id: perl-legacy-cursor-input-source-origins
title: Legacy cursor/input source frames preserve balanced raw expressions and empty arguments
answers:
  - "which Legacy cursor and input producers retain source origins"
  - "does input_slice source provenance parse scanner arguments"
  - "where do balanced input_slice coordinates come from"
  - "do cursor save restore and rewind origins alter cursor movement"
  - "does cursor provenance preserve all earlier Legacy source families"
  - "why did the initial input_slice regex corruption change zero source bytes"
date: 2026-10-06
status: focused cursor/input source-provenance acceptance verified
tags: [perl, actionir, legacy, cursor, input, source-provenance]
evidence: "All15 original cursor/input producers preserve balanced raw/empty scanner arguments, physical bounds and actual event/argument identities. 4459 immutable originals/three overlays/eight commands retain112 contracts/115 cases/227 events under three seeds; private origins133→163. Original RED15/GREEN96; eleven suites1274 groups including Phase01035 and149 evidence RED pass. Book58 inputs/11 examples/three chapters/19 RED and30-hash historical freeze pass. Complete public compiler/callback channels and original grammar remain exact; entry/match32 next. Clearing-observation .2.7 and wrapper startup .7 remain separately owned."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_helper_source_provenance.t t/typed_source_location_perl_contract.t"
  - "The .1.4.5 review is historical at7113d085b4b7ec0ef11e2f009395d9f2b6e71f21; current entry/match .1.4.6 recurrence preserves all cursor/input origins."
---

# Balanced raw expressions have original physical coordinates

The15 original cursor/input producers are cursor_pos, cursor_line, cursor_col,
cursor_rest, cursor_rest_len, input_slice, input_text, input_len,
input_end_pos, input_end_line, input_end_col, save_cursor, restore_cursor,
rewind_entry_start and rewind_match_start. Each saves its own regex $-[0]/$+[0]
before constructing the original event, then passes that exact object and its
original argument reference to the existing private source recorder.

The input_slice scanner preserves the complete balanced raw expression,
including nested parentheses and quoted commas, with empty args. It has no
parser/trim callback. The separate Contracts lowerer still interprets the raw
expression through its existing lower_method_value_expr callback. Provenance
adds no scanner argument parser, helper-pattern view or grammar change.

The unchanged literal fixture independently carries Unicode/CRLF prefixes,
repeated equal calls and scalar intervals. Actual returned event, constructor
and argument identities distinguish equal-valued clones. Whole-file inversion
removes exactly15 snapshots/wrappers and restores the activation Git source,
including every original recognizer and raw/argument expression. Stable IDs
select original uninstrumented cursor, balanced input_slice and current untouched
entry controls; asserted families prevent ordinal label drift.

This source work changes no runtime cursor movement, source projections, public
event schema, scanner ordering or callback/compiler channels. Previously verified
call/anonymous/named/mark origins and boundary lexical repairs recur in the same
all112-contract probe. Entry/match origins now belong to [[perl-legacy-entry-match-source-origins]].
Executable quoted/comment membership,
source-based replacement and other backends remain separately owned. The existing
mark-copy deletion-observation gap remains CONFORMANCE-SOURCE-READING.2.7-owned.
Wrapper startup .7 still owns establishment/liveness; recovery/purge remain
prohibited and source acceptance supplies no lifecycle guarantee.

The initial source-regex corruption omitted the recursive named expr group and
changed zero bytes. Review stopped without publishing verification. Its original
instrument is retained; final review reproduces the zero-byte identity, requires
the unique actual recursive target and rejects every control only after asserting
that its mutation changes its input. All149 final controls observe their exact RED.
