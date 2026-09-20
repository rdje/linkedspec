# ADR 0121: Approved history capacity for backend integration delivery

- Date: 2026-09-20
- Status: accepted under `BACKEND-INTEGRATION-GUIDES.5.1`; explicit director approval
- Tags: integration, documentation, history, capacity, verification

## Context and authorization

The director answered **Granted** to the exact six-control proposal in
docs/tasks/BACKEND-INTEGRATION-GUIDES.md after native Lua setup verification.
Both required hot-shard rollovers preserve clean 0b409e305 history but need one
additional archive slot in each collection. This decision implements that scope
within the existing canonical leaf; it does not pivot away from dirty work.

## Exact reviewed transitions

### change_history

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":38,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":39,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":21071,"max_lines":37}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":21647,"max_lines":38}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### engineering_notes

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":34,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":28000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":35,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":28000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":19902,"max_lines":33}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":20514,"max_lines":34}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Decision and consequences

Change exactly six scalars: collection files, manifest lines and manifest bytes
for each history. Keep all other controls, immutable archives, existing authority,
routes, schema, lifecycle and owner unchanged. Stable responsibility remains
LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3. The existing routing checker enforces these
data-only limits; no checker logic or exception is added.

The changes archive preserves 126 lines / 27065 bytes as segment4974; the notes
archive preserves 114 lines / 28169 bytes as segment4973. Their source is clean
0b409e305. Exact reconstruction, existing rows and all older segments must agree.
Keeping oversized hot shards violates the required 90% rollover; deleting or
repacking immutable history loses that contract. Shortening current summaries
could defer one rollover but cannot supply the measured remaining delivery space.

The finite forecast reserves seven complete records, each at most 14 lines and
2048 bytes: deployment, navigation, independent final review and four capacity or
closeout allowances. Charge the final admission overhead before evaluating it.
Both hot shards remain below their existing rollover thresholds with that reserve;
remeasure each real leaf. This is not capacity for unlimited later PNT reading.
No live-file, archive-size or aggregate limit increases. No record is discarded.

## Verification and handoff

Verify exact six-scalar and prior-content preservation, actual production boundary
and authorization behavior, both history checks and all normal doctrines. Run
receipt-bound canonical CI on the exact staged candidate before committing .5.1.
There is no CI, receipt, hook or source-reading exception. After clean commit,
continue Lua deployment .5.2, common navigation .6 and independent final review .7.
The later conformance .1.35 return point and all runtime repair owners remain.

## Links

- Proposal, approval and implementation: docs/tasks/BACKEND-INTEGRATION-GUIDES.md, .5.1
- Native and history facts: docs/knowledge/backend-integration-inventory.md
- Standing rules: README_POLICY.md; COMMIT.md; ADR0073
- Prior finite allowance: ADR0118 (unchanged)
