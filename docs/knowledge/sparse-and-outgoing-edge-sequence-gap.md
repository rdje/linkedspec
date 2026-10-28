---
id: sparse-and-outgoing-edge-sequence-gap
title: Sparse Lua AND bodies retest declaration-catalog positions instead of required outgoing edges
answers:
  - "why does an AND body retest its already-consumed entry declaration"
  - "why does sparse Lua AND return null when Perl returns BODY"
  - "which task owns sparse AND outgoing-edge sequence repair"
  - "does the Default OR active-edge repair also fix AND sequence ownership"
date: 2026-10-28
status: P1 owned39 after33/35/34 before38/37/full23.4; Lua confirmed, peer intake independent
tags: [lua, luajit, and, regex, slots, sequence, source, trace]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.4 public Perl native/fresh versus dual-host Lua native/restored/plan/fresh Hcat source, compiled fields and exact required0 trace; active-edge-body-lua-intake.json.gz."
reverify: "Recover probe_active_edge_and_perl.pl and refined probe_active_edge_and_lua.lua from active-edge-body-lua-intake.json.gz and use retained project-routed commands."
---

Top selects Value entry /H/ on Hcat. Value:AND declares /H/ and /cat/, but writes
only ->Value[1] returning BODY. Perl native/fresh returns[BODY]; both installed
Lua hosts/native/restored SpecFile/plan/fresh module return[null]. Compiled fields
correctly retain catalogH/cat and sole edge regex_index1/child_regex_index1.
Native trace selects H in Top, then requires Value catalog0 H at cursor1 and
misses. regex_once enumerates all catalog positions, rather than the authored
required-edge sequence. This is distinct from ordinary choice and regex dialect.

Bounded36 intentionally repairs Default/OR choice and leaves AND unchanged. P1
owner39.0 must freeze required sequence/counters/minimum/repetition/indexed-entry
and generated-family authority before39.1-.4 independent backend repairs.
Retain full incoming/boundary catalogs and structural identities. A constant
return alone cannot prove complete repair: include non-returning and falsey
actions, reversed duplicate edge order, required-step counts, failed minimum,
repetition and exact native/generated source/cursor/capture traces. Other backend
failure is not inferred; actual public family/schema movement needs its own
canonical authority. Complete repair is required before admission/push.

Initial Lua descriptor serialization used ambiguous plain tables and failed its
JSON encoder. Exact source/error are retained; refined detached typed array/
object fields complete successfully. No product RED credit for that setup error.
