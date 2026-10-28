---
id: lua-active-edge-body-candidate-ownership
title: Safe Lua body choice now uses cached outgoing compiled slots in authored order
answers:
  - "why did Lua wildcard entry declarations swallow body edges"
  - "where does Lua filter outgoing body choice candidates"
  - "does Lua preserve reversed duplicate action edge priority"
date: 2026-10-28
status: bounded36.4 targeted-checked on installed PUC5.5.1/LuaJIT; full23.4 and declared5.4 proof open
tags: [lua, luajit, regex, slots, dispatch, source, trace]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.4; active-edge-body-lua-intake.json.gz actual dual-host four-route baseline/candidate/source/trace/version outputs."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/active_edge_body_candidates_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/active_edge_body_candidates_test.lua"
---

regex_once and gap-preselected choice formerly used the full cached catalog.
Existing-table M._match_body_choice now queries outgoing edge.regex_index slots
through match_specific in authored order on non-AND action-edge choice. Earliest
start wins; equal starts keep first authored and at-cursor candidates may return
immediately. Cached programs/captures/indices/full catalogs remain intact; no
additional regex compilation inside the loop or persistent chunk-local binding.
Indexed-first/AND/blind/no-edge/cursor/frame/gap/formats keep existing owners.

Each installed host92 checks/34RED -> first candidate92pass on native/restored
SpecFile/plan/fresh loaded module, with exact source/capture/Unicode/gap/catalog/
mode/priority and in-memory slot traces. Duplicate112/rule-local108/capture checks
and module/runner loadfile pass. Declared5.4 remainsLUA2.2; no unsafe pattern,
full suite/matrix/isolated package admission is claimed. Normal runner registers
the new self-contained test without global helper leakage.

Separate early-LS cursor1 versus reference4 is owned38.3. Sparse AND catalog
enumeration still retests slot0 although only body edge1 is written; reference
BODY versus dual-host four-route null and exact required0 trace are owned39.
The bounded Default/OR repair does not waive either issue or admit formal23.4.
