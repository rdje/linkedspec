---
id: perl-legacy-anonymous-capture-source-origins
title: Anonymous Legacy capture origins come from each original regex producer
answers:
  - "which anonymous capture contracts retain private source origins"
  - "does CAPTURE macro provenance include its dollar sign"
  - "does capture_take alias provenance retain the original spelling"
  - "when are boundary call source bounds saved relative to quote decoding"
  - "do anonymous capture hooks preserve constructor and argument identities"
  - "does anonymous source provenance admit executable quoted membership"
  - "which Legacy origin control mislabeled an anonymous producer as named"
date: 2026-10-06
status: focused source-provenance acceptance verified
tags: [perl, actionir, legacy, capture, source-provenance, aliases]
evidence: "Owning .1.4.2 retains4394 immutable regular originals/three overlays/eight commands,112 contracts/115 cases under three seeds,227 events and18-to71 origins per seed. Original RED27/repaired GREEN50; ten suites1225 groups/Phase01035 and159 reason-specific controls pass. Book58 inputs/five examples/three chapters/13 RED;43 prior hashes verify."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_helper_source_provenance.t"
  - "The .1.4.2 review is historical at2bd501d5e03a28d98bc687dc885c9b04ca519bf8; current mark .1.4.4 recurrence preserves all anonymous origins."
---

# Snapshot original producer bounds before argument work

The 26 anonymous dispatcher contracts use their existing regex producers in
LegacyRules. Each now saves $-[0]/$+[0] immediately after its original match and
passes its original event and arguments through ScannerCore's private recorder.
Boundary capture saves those coordinates before the shared decoder consumes
quoted labels; caller match scope, whole labels and all runtime behavior remain
unchanged. No event is located by searching for equal raw text.

The family includes capture_macro/capture/capture_if/capture_if_macro, slice and
cursor-slice reads, structural boundary capture, take-until-cursor variants,
position/line/column/length reads, start/here, rest/take-rest, take-slice aliases
and from-rule-start reads. capture_take_slice matches actual capture_take(); its
source origin keeps that spelling. The capture_macro regex includes $CAPTURE,
while capture_if_macro's original match is CAPTURE_IF() even when the source has
a preceding dollar sign. Literal scalar intervals preserve that distinction.

The standard helper-source fixture observes actual constructor/event/argument
references, not JSON equality alone. Public event fields and default callback
results remain exact. The all-family probe preserves the previously repaired
call/return/push origins and current quoted comma labels; other producer families
remain uninstrumented until their own leaves. Source inverse reconstruction
removes only these26 snapshots/wrappers to recover the full clean d52 Legacy file.

These are internal compatibility IDs, not helper-admission authority. Quoted and
comment syntactic recognition remains the original population; executable source
membership, coordinate use in replacement, named captures/marks/read families,
other backends and global history audits remain separately owned. The earlier
nested boundary lexical repair stays independent of this coordinate provenance.

The historical159 controls all observed RED, but the control labeled
"invented uninstrumented named origin" targets original case34,
`capture_take_slice_len`, which was already an anonymous producer. Its actual
scope is rejection of an extra anonymous origin. The all-family literal oracle
still requires empty sidecars for untouched named producers. Successor .1.4.3
owns explicit original named and current uninstrumented mark denials; historical
producer/report bytes and counts remain exact.
