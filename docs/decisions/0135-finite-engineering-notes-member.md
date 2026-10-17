# ADR 0135: One finite engineering-notes archive member

- Date: 2026-10-17
- Status: accepted engineering maintenance under `PERL-PRIVATE-FACTORY-CAPTURE.5.1.3`; exact canonical admission required
- Tags: history, capacity, continuity, verification

## Exact engineering_notes authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":47,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29512}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":48,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29512}`

- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":27857,"max_lines":46}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":28469,"max_lines":47}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Exact decisions authorization

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":135,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13250}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":136,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13285}`

## Context and decision

The next complete engineering note crosses the mandatory byte rollover threshold. Actual production rollover preserves one complete clean-source suffix; unchanged routing limits reject its new member and exact manifest line/byte growth. The accepted single-statement callback slice stayed below the trigger. ADR0133 grants no further archive reserve.

Under the current full-PNT instruction and ADR0128/0129/0131/0132/0133/0134 engineering-maintenance precedent, admit exactly that one archive member and its measured manifest growth. This is an engineering decision, not a newly asserted or reused director grant. Deleting, repacking or shortening immutable accepted history cannot create the missing slot.

The decision collection admits only this sole new file and its exact physical line overhead plus one index row. Every other registry field stays exact: root, aggregate, per-file, byte and unrelated controls. Stable storage responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. No future member reserve is granted.

## Verification and consequences

Independently reconstruct the complete clean-source suffix, source blob/range/digest, current root and prior manifest rows. Preserve all prior history/decision bytes and the complete accepted callback publication with its actual baseline. Retain first incomplete supplied snapshots and failures; complete helper/config/directory/attribute inputs through accepted Git and retain the original-project Git-root guard. Execute unchanged production threshold and accepted/indexed/exact-object authority controls, retain distinguishing corruptions and require exact staged canonical CI/receipt plus normal hooks.

Existing history tools, runtime/test/checker implementations, dependency pins and other repositories remain unchanged. Public documentation describes the finite current scope. Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/publish.py` through tools/run_python_project_data.sh. If/while callbacks .5.2 resume after commit.
