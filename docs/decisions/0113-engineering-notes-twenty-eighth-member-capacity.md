# ADR 0113: Engineering-notes history admits its twenty-eighth bounded member

- Date: 2026-09-10
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.11`; director approval granted
- Tags: documentation, history, rollover, routing, capacity, continuity, doctrine

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":27,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":28,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":26}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":27}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

Dart reading .1.46 reproduced a mandatory engineering-history rollover that
exceeded exactly collection files 28/27 and manifest lines 27/26. Its exact
source, restored history and production-validator boundary checks are retained
in the proposal below. The completed reading committed at
`01a2159c093c71d6cd15b9d1aceee5dfc3505008`, leaving the engineering hot root
at 459 lines / 40,321 bytes. Intake `DART-STARTUP-READING.7` owns the decision.

The director explicitly grants the proposed engineering-history capacity change.
This authorizes the two count controls below. Implementation remeasures the
actual clean activation source; the earlier .1.46 draft remains dated evidence
and does not replace the new source/blob/range/count/hash proof.

## Decision

Increase only engineering_notes max_files 27 to 28 and its manifest max_lines
26 to 27. Manifest max_bytes remains 16,384; root limits remain 512 lines /
65,536 bytes; segment limits remain 4,096 lines / 524,288 bytes; aggregate
limits remain 27,000 lines / 3,145,728 bytes.

Stable responsibility remains `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`. Retain
all owners, routes, lifecycle, schema, verifier and ADR0069 storage authority.
The governed rollover moves only complete clean-source suffix records and
preserves every prior manifest record and immutable byte. Relocating that suffix
cannot create the missing archive slot; rewriting history or dropping unique
evidence would violate the preservation contract.

This admits one additional archive member. It grants no further capacity,
parser repair, cleanup/purge or parked-feature activation. The concurrent
PGEN/RGX build-on-submodule-update requirement stays separately owned by
`SESSION-STARTUP-READING.80`; this ADR changes no dependency or build behavior.

## Consequences

- Prior engineering history remains queryable through repository-relative paths.
- .11 lands on independent focused proof under the explicit one-time receipt exception below.
- Actual-source coordinates and full-history reconstruction are verified before landing.
- After commit, empty brief and clean proof, Dart .1.47 resumes required reading.
- Remaining startup prerequisites and existing defect ownership remain in force.

## One-time verification exception — 2026-09-11

On 2026-09-11 the director explicitly granted a one-time canonical-receipt exception for .11 using passing focused checks, to avoid the current gate’s repeated PGEN/RGX builds. Normal commit hooks and all nine doctrines remain enabled; no full CI, dependency build or canonical receipt is claimed. All future verification boundaries retain their existing requirements.

The director answered “Granted” to the explicit request to commit this capacity
change using its passing focused checks without the canonical receipt. This
exception changes neither COMMIT.md nor hooks and applies only to this leaf.

## Links

- Storage authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0111-engineering-notes-twenty-seventh-member-capacity.md`
- Proposal and proof: `docs/knowledge/dart-reading-next-engineering-history-capacity.md`
- Owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, leaf .11
- Intake: `docs/tasks/DART-STARTUP-READING.md`, leaf .7
- Registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/development-notes/manifest.jsonl`
