# ADR 0136: Finite continuity capacity

- Date: 2026-10-19
- Status: accepted engineering maintenance under `PERL-PRIVATE-FACTORY-CAPTURE.5.8`; exact canonical admission required
- Tags: history, capacity, continuity, verification

## Exact change_history authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":50,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":51,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":27983,"max_lines":49}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":28559,"max_lines":50}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Exact engineering_notes authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":48,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29512}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":48,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":30024}`

## Exact decisions authorization

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":136,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13285}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":137,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13326}`

## Context and decision

The required complete records trigger one actual change-history rollover and exceed the exhausted engineering-note aggregate. Unchanged production limits reject the resulting member, exact manifest line/byte growth and note lines. Every accepted archive and original compiler proof remains recoverable; routing already reaches its canonical owners, and editing, deleting or repacking immutable history cannot supply capacity.

Under full PNT and ADR0128/0129/0130/0131/0132/0133/0134/0135 engineering-maintenance precedent, admit only this measured change-history member/manifest increment and exactly one existing512-line hot-shard envelope of aggregate engineering-note lines. The concrete continuation is this maintenance, due metadata-only artifact review, private fixture admission .7, pipeline .6 and metadata .3.2.1.12, including bounded child splits within that finite envelope. This is no new or reused director grant.

The decision collection admits only this sole file and its exact physical lines plus one index row. All root, byte, per-file, engineering membership/manifest and unrelated limits stay exact. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. No future archive member or unlimited PNT reserve is granted; another exhausted allowance needs its own decision.

## Verification and consequences

Retain actual old-cap refusals with complete original-project data/helper/config/namespace and historical fixture inputs; reconstruct the exact complete clean-source suffix/root/manifest/blob/range/digest and all prior history/decision bytes independently. Preserve the whole565-input/129686-byte compiler publication and actual baseline at its real accepted Git boundary. Unchanged production functions distinguish inclusive numeric and accepted/indexed/exact-object authority alternatives; actual artifact corruptions must reject and restore. Full current Knowledge/book and exact staged canonical CI/receipt plus normal hooks govern admission.

Runtime, test, checker and dependency implementations remain unchanged. Other repositories/submodules stay read-only black boxes; startup.7 recovery/purge restrictions remain. Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/publish.py` through tools/run_python_project_data.sh. Due artifact review follows the clean capacity boundary.
