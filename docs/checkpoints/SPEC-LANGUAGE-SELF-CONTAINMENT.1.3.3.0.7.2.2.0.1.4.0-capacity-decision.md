# ADR 0127: Finite engineering-note capacity for the original Legacy diagnosis

- Date: 2026-10-05
- Status: accepted under `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0`; explicit director Granted disposition
- Tags: documentation, history, capacity, continuity, verification

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":43,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":44,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":25410,"max_lines":42}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":26021,"max_lines":43}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The verified diagnosis adds one complete618-byte note to the clean58975-byte root, crossing the unchanged90% rollover boundary. Current43-file history and42-line/25410-byte manifest controls are full. Routing already uses the canonical owner; ADR0069 prohibits rewriting/deleting/repacking accepted history. The director answered Granted to the retained exact proposal; ADR0122 excluded later runtime/PNT growth.

## Decision

Admit exactly files43→44, manifest lines42→43 and bytes25410→26021. Preserve every other field, root/per-segment/aggregate control, surface and immutable prior history. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. The current Legacy leaf owns this canonical infrastructure prerequisite, avoiding a dirty task-tree pivot.

Governed segment4964 preserves clean da3d34945d5067410b79f51782395f15b5184ff4 lines142–342:201 lines/27233 bytes, SHA-2568783c6d63164ded0745e6fd2e9cd9a440d71e3d5b682635b1b5573e126507f0e. The governed root145 lines/32360 bytes becomes144 lines/32359 bytes after only its final blank separator is removed, within unchanged50% retention. Independent reconstruction and actual production threshold/authorization controls must verify these predictions.

## Consequences

Exactly one archive/row is admitted, with no unlimited PNT reserve or later threshold authority. Normal hooks, strict claim identities and exact staged canonical CI remain mandatory; no verification/push exception is granted. Parser behavior and the separately owned quoted-boundary repair remain outside this admission.

## Links

- Authority: `docs/decisions/0069-bounded-change-and-notes-history.md`; prior capacity: `docs/decisions/0122-approved-conformance-evidence-capacity.md`
- Owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`; registry: `doctrine/readme_stability/routes.jsonl`
- Exact proposal and actual proof: `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-capacity-proposal.json`, `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-capacity-review.py`
