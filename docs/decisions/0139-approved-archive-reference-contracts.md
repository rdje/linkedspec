# 0139 — Approved archive and maintained-reference contracts

- Status: accepted; explicit director approval in the 2026-11-01 session.
- Scope adoption owner: `TYPE-REFERENCE-BOOK.1.2.20.1.10`
- Decision owner: LinkedSpec maintainers.

The director selected “Adopt the proposed archive/reference contracts (recommended)”.
This implements the reviewed plan in `docs/checkpoints/document-pressure-restoration/PLAN.md`.
No temporary waiver, refreshed debt baseline, hook bypass or numerical ceiling increase is authorized.
The interdependent normal-hook restoration lands atomically after normal hooks and canonical CI pass.

History is an exact query archive with bounded hot roots, immutable bounded source segments and
content-addressed catalog pages (32 entries per page, 64 KiB per file, bounded root fanout).
Historical pages remain readable after catalog replacement. Source byte identities and ordered records
remain gated against Git and retained files. Lifetime archive totals are not current working-set budgets.

Decisions, facts and public references remain directly browsable in their canonical locations.
Existing per-file ceilings remain. A bounded paged scope ledger admits each exact path and content hash
under the selected unique task owner; missing, unindexed, stale or reassigned provenance fails.
Adoption binds all existing inputs to the clean predecessor. Subsequent changed entries require their
own selected task owner. Removal requires a separately reviewed preservation migration.
This is explicit admission of maintained scope, not an unconstrained append terminal.

Current task collection ceilings remain unchanged. Closed narratives move to source-bound immutable
archives with exact reconstruction and node queries. Every current ID, status, goal and acceptance remains;
open bodies stay complete. TYPE is split into four bounded semantic parts with stable-ID retrieval.
All archived verification declarations remain in the current graph so owner selection remains exact.
Knowledge Map compaction retains every route and metadata field within its original limits.

## Exact resulting-tree contracts

### change_history

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":29134,"max_lines":51}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0139-approved-archive-reference-contracts.md","control":"query_terminal","lifecycle":"query_archive","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":29134,"max_lines":51}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/catalog/*.jsonl","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/catalog/*.jsonl","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":52,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_lines_per_file":4096}`

### decisions

- Routed surface: `decisions`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{},"members":["docs/decisions/*.md"],"owner":"docs/decisions/INDEX.md","route_targets":["docs/decisions/","docs/decisions/INDEX.md"],"state":"current","transition_owners":null,"verifier":"internal:indexed"}`
- New routed contract: `{"authority":"docs/decisions/0139-approved-archive-reference-contracts.md","control":"scoped_reference","lifecycle":"maintained_reference","member_limits":{},"members":["docs/decisions/*.md"],"owner":"docs/decisions/INDEX.md","route_targets":["docs/decisions/","docs/decisions/INDEX.md"],"state":"current","transition_owners":null,"verifier":"maintained_scope"}`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":138,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13360}`
- New routed limits: `{"max_bytes_per_file":65536,"max_lines_per_file":640}`

### engineering_notes

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":29080,"max_lines":48}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0139-approved-archive-reference-contracts.md","control":"query_terminal","lifecycle":"query_archive","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":29080,"max_lines":48}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/catalog/*.jsonl","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/catalog/*.jsonl","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":49,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":30024}`
- New routed limits: `{"max_bytes_per_file":524288,"max_lines_per_file":4096}`

### knowledge_cards

- Routed surface: `knowledge_cards`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{},"members":["docs/knowledge/*.md"],"owner":"docs/knowledge/","route_targets":["docs/knowledge/"],"state":"current","transition_owners":null,"verifier":"internal:indexed"}`
- New routed contract: `{"authority":"docs/decisions/0139-approved-archive-reference-contracts.md","control":"scoped_reference","lifecycle":"maintained_reference","member_limits":{},"members":["docs/knowledge/*.md"],"owner":"docs/knowledge/","route_targets":["docs/knowledge/"],"state":"current","transition_owners":null,"verifier":"maintained_scope"}`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1350,"max_lines_per_file":512,"max_total_bytes":8388608,"max_total_lines":108000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_lines_per_file":512}`

### public_reference

- Routed surface: `public_reference`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{},"members":["USER_GUIDE.md","dart/README.md","docs/linkedspec-book/src/**/*.md","docs/linkedspec-book/src/*.md","julia/README.md","lua/README.md","rust/README.md"],"owner":"docs/linkedspec-book/src/SUMMARY.md","route_targets":["USER_GUIDE.md","dart/README.md","docs/linkedspec-book/","docs/linkedspec-book/src/**/*.md","docs/linkedspec-book/src/*.md","julia/README.md","lua/README.md","rust/README.md"],"state":"current","transition_owners":null,"verifier":"internal:indexed"}`
- New routed contract: `{"authority":"docs/decisions/0139-approved-archive-reference-contracts.md","control":"scoped_reference","lifecycle":"maintained_reference","member_limits":{},"members":["USER_GUIDE.md","dart/README.md","docs/linkedspec-book/src/**/*.md","docs/linkedspec-book/src/*.md","julia/README.md","lua/README.md","rust/README.md"],"owner":"docs/linkedspec-book/src/SUMMARY.md","route_targets":["USER_GUIDE.md","dart/README.md","docs/linkedspec-book/","docs/linkedspec-book/src/**/*.md","docs/linkedspec-book/src/*.md","julia/README.md","lua/README.md","rust/README.md"],"state":"current","transition_owners":null,"verifier":"maintained_scope"}`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":64,"max_lines_per_file":5000,"max_total_bytes":4194304,"max_total_lines":50000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_lines_per_file":5000}`

### task_evidence

- Routed surface: `task_evidence`
- Previous routed contract: `{"authority":"docs/decisions/0125-startup-task-partitions.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.01-03.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.04-49.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.50-99.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.index.jsonl":{"max_bytes":16384,"max_lines":5},"docs/tasks/SESSION-STARTUP-READING.md":{"max_bytes":32768,"max_lines":256}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl","docs/tasks/SESSION-STARTUP-READING.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`
- New routed contract: `{"authority":"docs/decisions/0125-startup-task-partitions.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.01-03.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.04-49.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.50-99.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.index.jsonl":{"max_bytes":16384,"max_lines":5},"docs/tasks/SESSION-STARTUP-READING.md":{"max_bytes":32768,"max_lines":256},"docs/tasks/TYPE-REFERENCE-BOOK.helpers-01-39.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/TYPE-REFERENCE-BOOK.helpers-40-59.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl":{"max_bytes":16384,"max_lines":5},"docs/tasks/TYPE-REFERENCE-BOOK.md":{"max_bytes":65536,"max_lines":512},"docs/tasks/TYPE-REFERENCE-BOOK.overview.md":{"max_bytes":786432,"max_lines":5000}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl","docs/tasks/SESSION-STARTUP-READING.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":12582912,"max_total_lines":120000}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":12582912,"max_total_lines":120000}`
