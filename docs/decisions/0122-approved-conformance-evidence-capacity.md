# ADR 0122: Approved finite remaining-conformance evidence capacity

- Date: 2026-09-21
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15`; explicit director approval
- Tags: conformance, reading, documentation, history, capacity, verification

## Context and authorization

The director answered **Granted** to the exact fourteen-control proposal in
CONFORMANCE-SOURCE-READING.4.1 and its bounded implementation before required
reading finishes. Clean activation is 5fab5aa6dfdf0f52f9a9018aba2dc5cb7449e537.
This grant does not waive canonical CI, receipts or normal hooks. Source reading
remains 50/143; MethodExpr .2.5 and EmitContext descriptions .2.6 remain open.

Both history collections and manifests are full at activation. The next normal
record requires the existing mandatory rollover. Existing cards, task evidence
and the derived map also cannot hold the measured remaining-reading envelope.
Shortening current summaries cannot supply archive slots or the complete reserve;
deleting evidence, removing questions or repacking immutable history is rejected.

## Exact reviewed transitions

### change_history

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":39,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":47,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":21647,"max_lines":38}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":26255,"max_lines":46}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### engineering_notes

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":35,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":28000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":43,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":20514,"max_lines":34}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":25410,"max_lines":42}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### knowledge_cards

- Routed surface: `knowledge_cards`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":7340032,"max_total_lines":93000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":1350,"max_lines_per_file":512,"max_total_bytes":8388608,"max_total_lines":108000}`

### knowledge_map

- Routed surface: `knowledge_map`
- Previous routed limits: `{"max_bytes":8388608,"max_lines":20000}`
- New routed limits: `{"max_bytes":8388608,"max_lines":22500}`

### task_evidence

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":10485760,"max_total_lines":92000}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":12582912,"max_total_lines":120000}`

## Decision and consequences

Change exactly the fourteen scalars in the preserved proposal. Retain every
other field, route, authority, owner, lifecycle, baseline and verifier. In
particular, hot files remain 512 lines / 65,536 bytes with 80% warning, 90%
mandatory rollover and 50% retained maximum. Generic archive, card and task
member limits remain unchanged. Existing stable responsibilities remain with
the registered owners; the current leaf owns only this finite admission.

The finite 99-unit envelope covers 93 unread groups, proposal, admission,
independent verification, closeout and two contingencies. Historical proposal
proof conservatively charged all 99 units after proposal overhead. Admission
consumes one unit, leaving 98 forecast units; an applied rollover consumes one
of eight archive slots. Recompute from the actual resulting candidate and model
the complete remaining suffix, rather than demanding eight more archive slots.
Knowledge/task/map projections charge their measured per-unit maxima after all
actual admission overhead. The new ADR consumes the reserved decision member;
no additional decision growth is silently assumed. This does not grant capacity
for unrelated later startup, runtime repairs or unlimited PNT activities.

## Verification and handoff

### Explicit checker-mirror extension

The initial staged candidate exposed four registry/partition-checker boundary
disagreements and received no canonical receipt. The director then answered
**Granted** to containment `.15.1`'s exact one-file correction before remaining
reading: mirror the already-approved 120,000-line /12,582,912-byte task limits in
`scripts/check_task_tree_partitions.pl`, including their messages and boundary
fixtures. Original SHA-256 is
`9f4e5c1a3f268fc8364e6430583a8df58a522cd9c12bc24575d11181758a0206`;
approved corrected SHA-256 is
`cb9dd627bb5d657d0fc504b611cd25b377e2b9b3b6602f352680bf3c635cd9e9`.
The registry-agreement guard, file/member controls and every other implementation
byte remain unchanged. This extension supersedes only the original proposal's
checker-source preservation for that exact diff. It grants no further capacity,
CI exception or other source repair. The correction is inseparable from .15's
admission and must land atomically after fresh exact staged canonical proof.

Verify exact fourteen-scalar identity and unchanged remaining controls, preserved
source and evidence, immutable archive bytes and complete ordered reconstruction.
Exercise production boundary/authorization functions and independently compare
history simulations. Recompute all collection/member forecasts, render the book
and run normal doctrines. Stage the complete candidate and obtain the ordinary
canonical receipt before committing; normal commit hooks remain enabled.
Independent admission proof and the exact staged gate close conformance .4/.4.2
within this owner. Resume unread .1.51 only after commit and clean handoff.

## Links

- Approved proposal and disposition: docs/tasks/CONFORMANCE-SOURCE-READING.md, .4
- Implementation: docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md, .15
- Reproduction: docs/knowledge/conformance-evidence-capacity-admission.md
- Standing controls: README_POLICY.md; COMMIT.md; ADR0073
