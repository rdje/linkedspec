# ADR 0134: One finite change-history archive member

- Date: 2026-10-11
- Status: accepted engineering maintenance under `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7`; exact canonical admission required
- Tags: history, capacity, continuity, verification

## Exact change_history authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":49,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":50,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":27407,"max_lines":48}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":27983,"max_lines":49}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Exact decisions authorization

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":134,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13215}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":135,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13250}`

## Context and decision

The next complete change record crosses the mandatory line rollover threshold; the existing finite member and manifest limits reject its required new archive. The accepted array-end callback slice stayed below the boundary; this canonical prerequisite resolves the exact next capacity obligation. ADR0132 grants no further reserve.

Under the current full-PNT instruction and ADR0128/0129/0131/0132/0133 engineering-maintenance precedent, admit exactly one additional archive member and only its measured manifest line/byte growth. This is an engineering decision, not a newly asserted or reused director grant. Existing routes already reach the correct owner; deleting, repacking or shortening immutable accepted history cannot lawfully create the missing slot.

The decision collection admits only this sole new file and its exact line overhead plus one index row. Every other registry field stays exact: root, per-file, aggregate, byte and all unrelated surface controls. Stable storage responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. No future member reserve is granted.

## Verification and consequences

Independently reconstruct the entire clean-source suffix, source blob/range/digest, current root and prior manifest rows. Preserve all prior immutable history/decision bytes. Execute unchanged production threshold and accepted/indexed/exact-object authority functions with actual measured inputs and distinguishing RED controls. Retain actual reviewer-corruption channels and all producer/input identities. Exact staged canonical CI/receipt and normal hooks govern landing; focused evidence alone admits no capacity.

Existing book authority and chronology contracts remain accurate; parser/runtime, tests, checker implementations, dependency pins and other repositories are unchanged. Owner: docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md; readonly review: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-capacity.py review` through tools/run_python_project_data.sh. Required hash-index callbacks .3.1.6.5 resume after commit.
