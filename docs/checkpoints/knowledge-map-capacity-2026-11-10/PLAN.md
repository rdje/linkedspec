# Knowledge Map capacity plan

Owner: `TYPE-REFERENCE-BOOK.1.2.23.4.18.0`; implementation: `.18.1`.
Activation: `6cd8e78437df8693c31a9af64c2e242977c84786`.

The frozen map has 1,710 facts, 12,237 question keys, 22,499 lines and
7,872,229 bytes. Its unchanged registry ceilings are 22,500 lines and 8,388,608
bytes. These are independent axes. The duplicate per-fact `answers` display
uses 1,710 lines and 746,324 bytes; removing only that display projects 20,789
lines and 7,125,905 bytes. This is a prospective display calculation, not an
implemented capacity or canonical-admission claim.

Keep the full Questions section byte-for-byte, including each exact question,
fact ID, canonical path, date and reverify command/list anchor. Keep every
`### id` anchor, title, date/status/source, evidence and reverify value in the
Facts section. Keep all canonical card bytes and authored answer order/repeats.
Only the second display of each answer list is redundant. The preserved source
card remains the authority for its authored ordering and repeated entries.

This selection retains one generated, bounded, freshness-checked map and its
existing limits. It introduces no new index sink or collection and changes no
reader navigation destination. Capacity remains finite; future pressure must
receive its own owner before growth. README_POLICY/ADR0063 require separate
accepted authority for any limit increase; none is requested here. ADR0139
governs maintained card admission, not permission to widen the generated map.

Affected producers/readers and verification:

- `knowledge-map/scripts/gen_knowledge_map.sh`: remove only the redundant fact
  display line; retain question extraction/counting, all metadata rendering,
  deterministic sort, validation and atomic publication.
- `tools/test_knowledge_map_projection.py`: accept explicit legacy/current
  formats while preserving strict comparison within a format. Cross-format
  preservation must validate legacy answer content rather than simply ignore
  that field. Retain the previous producer image for historical consumers.
- `knowledge-map/scripts/check_knowledge_map.sh` and `.githooks/pre-commit`:
  retain validation, regeneration and exact synchronization. No schema weakening.
- `t/knowledge_map_header_lists.t` and
  `tools/test_knowledge_map_atomic_output.py`: run directly; evidence/reverify
  lists, anchors, atomic publication/failure behavior remain unchanged.
- `tools/test_tool_project_data_storage.sh` and
  `tools/test_project_data_workflow_routing.sh`: run directly; output-path and
  same-volume initialization contracts remain unchanged.
- `tools/check_capability_conformance.pl`: its required fact headings/status
  remain unchanged; run the direct checker.
- `scripts/check_readme_routing_pressure.pl`, the doctrine wrapper and canonical
  CI: retain both ceilings/freshness enforcement; exact staged canonical proof
  is required because the generator and recurring test are infrastructure.
- `knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md` and `knowledge-map/README.md`:
  explain the single question display and stable fact metadata; update the
  mdBook's relevant Knowledge retrieval guidance and render it.
- Root bootstrap/MEMORY_ARCHITECTURE/Toolbox readers continue to grep the same
  map and follow the same card paths. No bootstrap or root README rewrite.

`review.py` defaults to readonly replay. Its one-shot `--capture` retained exact
map, generator, checker, policy, registry and directly affected reader/test bytes
in `baseline.json.gz`. `result.json` is the actual successful capture output;
a separate readonly invocation agreed. The independent preservation walk allows
only exact answers-line deletions. Actual removed question, anchor, title, date,
source, evidence and reverify controls all raise its distinguishing error.
The production generator is unchanged at this planning boundary.

The three authorized external policy SHA-256 values match the canonical
Supplied-policy comparison evidence in
`docs/tasks/SESSION-STARTUP-READING.04-49.md`; no donor update is pending from
this comparison. All donor reads were read-only; no external build dependency
or donor implementation was inspected.

After capacity implementation, refresh the overdue named-scope artifact review
under its own leaf, retaining every artifact lacking proven disposal authority.
Then continue independent Dart78.3. Full feature/domain admission remains23.4.
