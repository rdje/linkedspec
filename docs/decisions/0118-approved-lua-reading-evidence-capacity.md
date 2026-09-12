# ADR 0118: Approved finite Lua reading evidence capacity

- Date: 2026-09-12
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14`; explicit director approval
- Tags: lua, documentation, capacity, knowledge, history, verification

## Context and authorization

The director answered **Granted** to the complete proposal committed at
`b4ec6d39fb1e58bf3d8513f8c03d57b289ba15f6`: all eleven exact limits and the
containment .14-only focused-verification exception without canonical CI/receipt,
including this bounded capacity implementation before full codebase reading.
Lua .4.2 records that new explicit disposition in the admission commit.

The 51 Lua reading children remain pending. Their complete source inventory and
independent range proof cover 99 files, 71,268 physical lines and 2,732,450 bytes.
The capacity proposal and its historical models remain byte-exact in their
canonical task and Knowledge owners; earlier Julia approvals are not extended.

## Exact reviewed transitions

### knowledge_cards

- Routed surface: `knowledge_cards`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":79000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":7340032,"max_total_lines":93000}`

### task_evidence

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":9437184,"max_total_lines":88000}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":10485760,"max_total_lines":92000}`

### change_history

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":36,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":38,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":19919,"max_lines":35}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":21071,"max_lines":37}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### engineering_notes

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":32,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":34,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":28000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":18678,"max_lines":31}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":19902,"max_lines":33}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Decision and finite reserve

Change only these eleven registry scalars. Stable responsibilities remain
`docs/knowledge/`, `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2` for task evidence and
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` for both history collections. All other
limits, member/root controls, routes, owners, schema, lifecycle, verifier,
source, prior card, decision and immutable-history bytes remain unchanged.

The finite envelope is 57 units: 51 reading children plus proposal, capacity
admission, independent capacity review, independent reading audit, reading
closeout and one contingency. Disposition .4.2 lands with the admission.
The support slots are a reserve, not mandatory redundant commits.

Actual Julia reading maxima reserve 18,012 Knowledge lines / 1,007,418 bytes /
57 files, 5,985 task lines / 603,801 bytes / two additional members, and 912 map
lines / 205,542 bytes. Three decisions plus index rows reserve 576 lines /
49,152 bytes / three files. The complete current candidate plus this full reserve
must pass, conservatively charging proposal/admission overhead again.

Each history reserves 57 complete records of 14 lines / 2,048 bytes. Independent
and actual-function models agree on four rollovers per collection, with two
currently available slots. Maximum new manifest rows are 576 changes bytes and
612 notes bytes. Exact source, query and model identities remain in the proposal.
No rollover is performed unless the current complete candidate requires one.

Already partitioned stores cannot reduce aggregate volume by splitting members.
Routing away required records or densely packing unique evidence would weaken
retrieval and preservation; no sufficient removable duplication is established.
Retain readable unique evidence. The rounded finite ceilings cover the measured
reserve without altering existing per-member safeguards.

This is a Lua reading allowance, not runtime-repair, supporting-code or unlimited
future capacity. It does not guarantee that unknown findings fit. Remeasure each
actual leaf and all member limits; no later increase is automatically authorized.

## One-time verification exception

The director explicitly approves focused verification for containment .14,
including before-reading execution, without canonical CI or a receipt. Run exact
eleven-scalar/source/card/question/task/history preservation, the complete current
plus reserve census, independent history reconstruction and actual production
threshold/authorization controls, all nine normal doctrines, Knowledge/memory,
both history checks and rendered-book verification. Normal hooks stay enabled.

This exception applies only to .14. It changes no standing policy or gate,
authorizes no PGEN/RGX build and waives no later repair, milestone or push proof.
Startup .80 still owns dependency build-on-update implementation; source repairs
and all remaining startup prerequisites retain their existing owners.

## Consequences and handoff

After verified admission and independent checks, close Lua .4/.4.2, commit, clear
the message file and verify clean. Resume Lua .1.1 from that clean boundary.
No physical Lua reading, runtime signoff or defect closure is claimed here.

## Links

- Implementation: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, .14
- Exact proposal and disposition: `docs/tasks/LUA-STARTUP-READING.md`, .4.1/.4.2
- Models: `docs/knowledge/lua-reading-evidence-capacity-proposal.md`
- Standing authority: `README_POLICY.md`; `COMMIT.md`; ADR0073
- Proportionate planning principle: ADR0115
