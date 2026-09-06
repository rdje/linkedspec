# ADR 0102: Change history admits its twenty-eighth bounded member

- Date: 2026-09-06
- Status: accepted under `SESSION-STARTUP-READING.3.2.5`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":27,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":28,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":26}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":27}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The required complete startup checkpoint record takes `CHANGES.md` from 459 to 465 lines, exceeding the 90%
rollover threshold. The governed rollover archives clean activation source `4f311a9e2bb7ee108d756e40bef829bd07d9914c`
lines 242–459 as immutable segment `4985`. Independent comparison proves its 218 lines / 20,348 bytes are the
exact clean-HEAD suffix and SHA-256 `3ac09e49b49f7bb8b05ea70af1286cd803310b212dcad344235ddce324b97f2c`.
The current root is 247 lines / 21,550 bytes immediately after rollover, and the manifest is 27 lines / 15,311
bytes. Together with 26 immutable segments, root, and manifest, the collection has 28 files rather than the 27
admitted by ADR 0100. The manifest similarly requires 27 lines rather than 26.

At that measured rollover boundary the collection totals 47,914/55,000 lines and 3,451,115/4,194,304 bytes.
Current-root, segment, manifest-byte, and aggregate controls all have capacity. Routing has already moved the
complete clean suffix out of the current view; removing or rewriting accepted history cannot supply the missing
file/manifest slots while preserving the existing immutable-store contract.

Current-view EOF whitespace normalization then removes one trailing blank line for diff hygiene: final root
246 lines / 21,549 bytes and final collection 47,913 lines / 3,451,114 bytes. The immutable segment is unchanged.

## Decision

Admit only `change_history.limits.max_files` 27 to 28 and the manifest member's `max_lines` 26 to 27. Preserve
all byte limits, current-root limits, per-segment limits, aggregate limits, owner, lifecycle, member patterns,
verifier, and ADR 0069 storage authority. This is one finite checkpoint-storage capacity step under the existing
README and history policies. Every later increase still requires its own newly indexed exact-limit decision.

## Consequences

- The mandatory startup checkpoint and exact accepted history remain durable and queryable on the repository volume.
- The current view shrinks by complete records, with immutable source identity and no archive rewrites.
- The checkpoint uses canonical verification because the route registry is an infrastructure owner.
- Required codebase/book reading and all product repairs remain separately owned and incomplete.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0100-change-history-twenty-seventh-member-capacity.md`
- Owning task: `docs/tasks/SESSION-STARTUP-READING.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
