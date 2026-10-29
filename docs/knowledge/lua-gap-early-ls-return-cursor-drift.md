---
id: lua-gap-early-ls-return-cursor-drift
title: Safe Lua early LS return exposes selected captures before advancing its live cursor
answers:
  - "why does Lua early LS return leave the caller cursor before the match"
  - "does LuaJIT capture_gaps LS return retain selected-match cursor position"
  - "which task owns Lua early LS cursor drift"
date: 2026-10-28
status: P1 owned38.3 after shared38.0/peer repairs, before37/full23.4/push
tags: [lua, luajit, cursor, lifecycle, gap, return, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.4 public Hcat dual-host four-route probes match exact Perl oracle source; active-edge-body-lua-intake.json.gz."
reverify: "Recover probe_active_edge_lua_gap_ls_cursor.lua from active-edge-body-lua-intake.json.gz; run through tools/run_lua_project_data.sh puc and luajit."
---

Top selects H on Hcat, calls Value and reports child payload plus caller cursor.
Value selects cat with capture_gaps; LS returns gap, match text and live cursor.
Both installed hosts/native/restored SpecFile/plan/fresh module return
[[empty,cat,1],1], while Perl native/fresh returns[[empty,cat,4],4] for the exact
same source. No competing untargeted pattern exists. M.prepare_gap_candidate
installs registers/context; accept_match writes live cursor only after LS, so
the lifecycle return unwinds first.36.4 leaves these cursor paths unchanged.

P1 owner38.3 reuses shared38.0 authority for live cursor versus committed gap
boundary, whole-rule return, rollback and authored LS cursor mutation. Correct4/4
and broad-carrier values must be verified before admission, without null rebasing
or a new cursor/frame owner. Declared5.4 proof remains separate. See also
[[dart-gap-early-ls-return-cursor-drift]] and
[[julia-gap-early-ls-return-cursor-drift]].

2026-10-29 shared authority38.0 freezes selected live end before flagged LS,
preserved explicit LS rewind through action/return, separate post-LE boundary
commit and existing cursor-regression guard. Public reference8sources10inputs
native/separate emitted agree, portable7/9 plus unflagged compatibility1/1.
[[gap-selected-match-ls-live-cursor-authority]] retains exact target/proof.
Independent backend repair still pending; no new backend RED or completion credit.
