---
id: perl-legacy-named-capture-source-origins
title: Named Legacy capture origins preserve symbolic mark order and physical spelling
answers:
  - "which named capture Legacy producers retain source origins"
  - "does named capture provenance preserve start and end mark order"
  - "how does capture_take mark spelling differ from anonymous capture_take"
  - "does start_capture_slice_from keep its original source occurrence"
  - "do named capture origins preserve actual event and argument references"
  - "why was the initial named source report rejected despite expected exit codes"
date: 2026-10-06
status: focused named source-provenance acceptance verified; wrapper repair remains separately owned
tags: [perl, actionir, legacy, capture, marks, source-provenance]
evidence: "All17 named capture regex producers preserve symbolic mark/start-end order, original spelling, scalar bounds and actual event/argument identities. 4415 immutable originals/three overlays/eight accepted commands retain112 contracts/115 cases/227 events under three seeds; private origins71→105. Original RED17/GREEN67; eleven suites1245 groups including Phase01035 and152 evidence RED pass. Book58 inputs/seven examples/three chapters/15 RED and30-hash historical freeze pass. Four initial commands retain the strictly rejected wrapper warning; replay is unfiltered, startup .7 remains its owner. Public compiler/callback channels and original grammar stay exact."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_helper_source_provenance.t t/complete_named_mark_contract.t"
  - "The .1.4.3 review is historical at d0b40ade098e1c2e8e7fc983ee2d9f3980205e46; current cursor/input .1.4.5 recurrence preserves all named origins."
---

# Keep marks and source coordinates at their original producer

The17 named capture dispatcher IDs use their existing LegacyRules regexes.
Each saves $-[0]/$+[0] immediately after matching, then passes its original
event/argument objects and physical source through the existing private recorder.
One-mark helpers retain the symbolic mark value. Two-mark helpers retain first
as start and second as end. No equal-raw lookup supplies a coordinate.

The family includes start_capture_slice_from_mark, capture_from_mark and its
length/take/rest/cursor variants, plus four between-mark readers. Internal IDs
are compatibility dispatch names, not public helper admission. In particular,
capture_take_from_mark matches capture_take(edge); the anonymous overload matches
capture_take(). The original argument grammars stay distinct. The bridge
start_capture_slice_from(edge) keeps its own source occurrence while restoring
the anonymous boundary through the existing semantics.

Independently authored Unicode/CRLF repeated scalar intervals and literal mark
arguments remain unchanged from the current original diagnosis. The standard
fixture observes actual returned, constructor and argument references, preserving
public events and callback effects. Original call and anonymous origins remain
in the all112-contract recurrence. Complete named-mark live/generated execution
is a direct consumer check; this leaf changes no mark storage/runtime contract.

The first complete original capture retained a project_data_run.sh child
setpgid92090 permission warning in seed0 stderr. The strict reviewer rejects
that actual report. Its full initial inputs/channels remain tracked, and the
unchanged original replay passes strict acceptance without filtering the
warning. Existing [[project-data-liveness-permission-denial]] and startup .7 own
group-establishment/liveness repair; the warned child's final PGID was not
measured. Recovery/purge remain prohibited and no lifecycle guarantee follows.

The prior anonymous review's index34 control rejects an extra anonymous origin,
despite its historical label saying uninstrumented named origin. That narrower
scope is disclosed in [[perl-legacy-anonymous-capture-source-origins]]. This
leaf adds exact original named and current uninstrumented mark controls plus a
reversed two-mark argument control, preserving all prior artifact bytes.

Mark controls, cursor/input and entry/match producer families remain separate.
Executable quoted/comment membership, source-based replacement and other backend
admission do not follow from these private syntactic source frames.
