# ADR 0106: Change history admits its thirtieth bounded member

- Date: 2026-09-07
- Status: accepted under `SESSION-STARTUP-READING.3.3.38`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":29,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":30,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":28}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16463,"max_lines":29}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The completed reading record takes CHANGES.md to 461 lines and triggers its mandatory 90% rollover.
The governed tool archives exact clean activation source `77cad4543e72ab304ce2a66b26a876b02cd6d3c4`
lines 211–457 as segment `4983`: 247 lines / 18,635 bytes, SHA-256
`90ac78b4747014cf1c23511da66b37cd4c1e2e3d100d0b62ef7719e4cbc5bc3a`.
Its source Git blob is `1affd77066b02718adca5aca9a7a14fbf03053da`. Independent source/blob/hash/count
comparison passes; every prior manifest record remains byte-identical, and only the header count advances.

The resulting store has 28 immutable segments plus root and manifest: 30 files.
The manifest needs 29 lines / 16,463 bytes. The previous controls allow 29 files, 28 manifest lines and
16,384 manifest bytes, so the routing checker rejects all three axes. The manifest exceeds its byte cap by
79 bytes. Before this decision's continuity note, the collection is 48,342 lines / 3,500,753 bytes, below
the retained aggregate ceilings. Current-root-only final blank-line cleanup does not alter archived bytes.

## Decision

Admit exactly max_files 29 to 30, manifest max_lines 28 to 29, and manifest max_bytes 16,384 to 16,463.
The byte limit is the measured manifest size, with no reserved additional member. Every subsequent increase
requires another newly indexed exact-limit decision.

The required rollover already moves complete older records out of the hot root. Deleting or rewriting
immutable history, shortening its exact source identities, or removing schema fields cannot create these
slots while preserving ADR 0069. A new partition/index architecture would be separate broader work.
Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3; this mandatory reading checkpoint owns
only the finite capacity admission needed to preserve its history.

Keep the root at 512 lines / 65,536 bytes, each segment at 4,096 / 524,288, and the aggregate at
55,000 / 4,194,304. Preserve member/route patterns, owner, lifecycle, verifier, immutable identities and
ADR 0069 storage authority. This changes no runtime or public language behavior.

## Consequences

- Exact prior history remains queryable on the repository volume.
- The hot root remains bounded; archive capacity has explicit finite limits.
- Routing infrastructure requires the exact staged canonical receipt before this checkpoint commits.
- Required codebase reading and product repairs remain incomplete and separately owned.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0104-change-history-twenty-ninth-member-capacity.md`
- Owning task: `docs/tasks/SESSION-STARTUP-READING.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
