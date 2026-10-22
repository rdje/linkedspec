# ADR 0137: Finite selection history members

- Date: 2026-10-21
- Status: accepted engineering maintenance under `TYPE-REFERENCE-BOOK.1.2.10`; exact canonical admission required
- Tags: history, capacity, continuity, verification

## Exact change_history authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":51,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":52,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":28559,"max_lines":50}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":29134,"max_lines":51}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Exact engineering_notes authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":48,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":30024}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":49,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":30024}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":28469,"max_lines":47}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":29080,"max_lines":48}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Exact decisions authorization

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":137,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13326}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":138,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13360}`

## Decision and verification

Required complete count/first records cross both90% hot-shard boundaries. The normal roller preserves exact clean a8bd8620a suffixes, Git provenance and all older immutable bytes; unchanged routing limits reject the two new archive members and exact manifest overhead. Engineering-maintenance precedent permits only those measured members and this sole decision/index overhead. Root, per-file, aggregate, tool and unrelated limits stay exact. No future member or unlimited PNT reserve is granted.

The owning checkpoint retains full original sources, actual pressure/refusal/apply/check channels and independent suffix/current/manifest reconstruction. Source-closed readonly review checks every prior immutable identity and these exact transitions; actual staged routing/doctrine/canonical proof and normal hooks govern admission. No dependency implementation changes. Owner: docs/tasks/TYPE-REFERENCE-BOOK.md; review: docs/checkpoints/type-array-count-first/publish.py through tools/run_python_project_data.sh.
