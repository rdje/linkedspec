# ADR 0067: Live achievement status is a bounded current view over exact history

- Date: 2026-08-09
- Status: accepted and implemented under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1`; atomic commit pending
- Tags: documentation, history, retrieval, routing, capability-governance, doctrine

## Routing transition authorization

- Routed surface: `live_status`
- Previous routed limits: `{"max_bytes":1572864,"max_lines":18000,"transition_max_byte_delta":65536,"transition_max_file_delta":0,"transition_max_line_delta":512}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":8,"max_lines_per_file":4096,"max_total_bytes":1572864,"max_total_lines":18000}`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"debt_bounded","lifecycle":"hot_live","member_limits":{},"members":["LIVE_ACHIEVEMENT_STATUS.md"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1","route_targets":["LIVE_ACHIEVEMENT_STATUS.md"],"state":"debt","transition_owners":["LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1","README-STABILITY-POLICY.4"],"verifier":"internal:overwrite"}`
- New routed contract: `{"authority":"docs/decisions/0067-live-achievement-status-history.md","control":"bounded_collection","lifecycle":"hot_live","member_limits":{"LIVE_ACHIEVEMENT_STATUS.md":{"max_bytes":32768,"max_lines":256},"docs/history/live-achievement-status/manifest.jsonl":{"max_bytes":16384,"max_lines":8}},"members":["LIVE_ACHIEVEMENT_STATUS.md","docs/history/live-achievement-status/*.md","docs/history/live-achievement-status/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.1","route_targets":["LIVE_ACHIEVEMENT_STATUS.md","docs/history/live-achievement-status/*.md","docs/history/live-achievement-status/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

This exact staged transition retires, rather than refreshes, the immutable debt baseline. The old baseline remains
historical evidence in Git and ADR `0063`; the new current-state contract carries no baseline or finite transition
allowance. The routing checker permits that clearing only for a `debt` to `current` change authorized by the exact
newly staged contract above. Every other baseline mutation remains rejected.

## Decision

`LIVE_ACHIEVEMENT_STATUS.md` remains the stable reader path but now contains only the five fixed sections
`Current Activity`, `Latest Completed Slice`, `Next Action`, `Recent Completions`, and `History`. It is limited to
256 lines / 32,768 bytes, and the recent list is limited to sixteen one-line rows.

The complete clean source at `dc8dd8969205b19e6bae7ddaae2dacf19504b7e1` is preserved in four immutable
repository-local segments described by `docs/history/live-achievement-status/manifest.jsonl`. Their concatenation
is byte-identical to Git blob `221159c6e15bdf1505186b3714c4b5c5848df889` and SHA-256
`683ef70df66c64e5f195c8bfe0e70f9561a13ed61ef4b1686a73a41ae35a9d55`. The normative full query is
`perl tools/read_document_history.pl --surface live_status --all`.

`scripts/check_document_history.sh` validates strict schema, safe relative nonsymlink paths, source identity,
contiguous order, exact counts/digests, Git reconstruction, immutable committed segments, current-view shape and
limits, and the absence of capability authority in live chronology. It is both a registered doctrine and the
fixed `document_history` route verifier.

## Transferred current assertions

The following exact current assertions move from chronological prose into this stable decision authority. Their
six JSON projections and seven duplicate-independent executable checkers now name this ADR, preserving governed
inventory counts while removing all live-history required-marker coupling:

- `Four-backend callable public no-drift is signoff-complete`; `parent `.11.7` is closed`;
  `Five-backend callable recurring/public admission is complete`.
- `FUTURE-PARITY-BACKLOG.5.2.9 — close logical-helper public no-drift`; `8 complete / 0 pending`.
- `FUTURE-PARITY-BACKLOG.9.1.1.2.6 — close root-selection public no-drift`; `7 complete / 0 pending`.
- `FUTURE-PARITY-BACKLOG.9.1.8.1.7 — close duplicate-slot recurring/public no-drift`; `7 complete / 0 pending`.
- `FUTURE-PARITY-BACKLOG.9.1.9 — close cursor public no-drift`;
  `74 migration files / 8 complete + 0 pending / 60 mutations`.
- `FUTURE-PARITY-BACKLOG.9.1.10.7 — close repeated-action public no-drift`;
  `Repeated-action rollout is closed at 8 complete / 0 pending`.
- `Capability exclusion public no-drift is closed`;
  `Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24``.

The repeated-action forbidden-current assertion also targets this ADR. Immutable archive segments are historical
positive evidence only and never become current-state denial inputs. The bounded current view intentionally
contains none of the transferred closeout markers.

## Consequences

- Exact prior chronology remains directly queryable and reconstructable without making a 14,872-line file the
  current status surface.
- Capability governance no longer depends on an append chronology, while each public inventory retains its exact
  document cardinality and independent expected projection.
- Live-route pressure becomes a current bounded collection with executable freshness/non-loss enforcement.
- Changes, engineering notes, and the future task monolith remain under `.2-.3`; this decision does not migrate
  them or change parser/runtime/backend/MCP/CLI/language behavior.

## Links

- Descriptor authority: `docs/decisions/0066-bounded-live-document-store.md`
- Owning task: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- History manifest: `docs/history/live-achievement-status/manifest.jsonl`
- Route registry: `doctrine/readme_stability/routes.jsonl`
