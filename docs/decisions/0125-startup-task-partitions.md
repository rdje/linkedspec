# ADR 0125: Startup task evidence uses lossless semantic partitions

- Date: 2026-09-24
- Status: accepted; atomic implementation and canonical acceptance owned by `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2`
- Tags: task-tree, continuity, retrieval, storage, verification, containment

## Context

The startup task member reaches 7994 lines / 960362 bytes after indexed-read repair .88.
Only six lines remain under its existing ceiling. The committed .16.1 plan verifies
396 stable definitions and nine disjoint source intervals; exact multiline duplicate
paragraphs offer no removable capacity. Ordinary repair work needs bounded task owners.
The director's standing PNT, task-first, no-loss, same-volume and book-sync instructions
already authorize this necessary containment. No larger limit is requested or admitted.

## Routing transition authorization

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":12582912,"max_total_lines":120000}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":12582912,"max_total_lines":120000}`
- Previous routed contract: `{"authority":"docs/decisions/0084-future-parity-task-partition-capacity.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`
- New routed contract: `{"authority":"docs/decisions/0125-startup-task-partitions.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.01-03.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.04-49.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.50-99.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/SESSION-STARTUP-READING.index.jsonl":{"max_bytes":16384,"max_lines":5},"docs/tasks/SESSION-STARTUP-READING.md":{"max_bytes":32768,"max_lines":256}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl","docs/tasks/SESSION-STARTUP-READING.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`

The newly staged record authorizes this exact execution-time route change. Every existing
collection/member ceiling, unrelated surface and historical FUTURE byte remains exact.
The new startup index is explicitly routed and its root/parts receive stricter limits.

## Decision

The clean .16.2 activation source is commit `58a5ff936e54f0699da2b33c35641a5e0155ed81`,
Git blob `f1aed39e1f7cb00d228642fed1b5ac49356747b9`, SHA-256
`e5a1199d0a15fbbd29ada47fb9a262dbeeefd831e971bc08cb084a7e8a7b6209`.
Its bytes are unchanged from the independently verified .16.1 source at `567b583f7`.

| Part suffix of `docs/tasks/SESSION-STARTUP-READING` | Original source lines | Original payload lines / bytes |
| --- | --- | ---: |
| `.01-03.md` | 41–2205; 5076–5574; 5826–7515 | 4354 / 528673 |
| `.04-49.md` | 2206–3416; 5575–5825 | 1462 / 140546 |
| `.50-99.md` | 3417–5040 | 1624 / 189983 |
| `.history.md` | 1–40; 5041–5075; 7516–7994 | 554 / 101160 |

Each part begins with five explanatory lines, followed by its exact original payload.
The immutable history header marks its old root/frontier/decisions as historical; current
AGENTS dependency boundaries and ADR0123 supersede contrary old instructions.
All 395 children retain semantic ownership; the .31 late intake stays with .04–49,
and .2/.3 reading evidence stays with .01–03. No current child is archived.

The original `.md` path becomes a 77-line current index with one root, one precise
frontier, current decisions/blockers, part navigation and lookup/update instructions.
Its limit is 256 lines / 32768 bytes. All four parts have limits of 5000 / 786432;
the schema-v1 index contains five records and is capped at 5 / 16384. Numeric ranges
reserve ownership only: lookup must reject absent IDs even inside an allocated range.
No source bytes rely on the mutable current root for preservation, so its source ranges
are empty and the corresponding source SHA-256 is the empty-string digest.

The existing shared lookup and snapshot-update tools explicitly register this tree.
A separate startup partition validator composes into the existing metadata doctrine;
FUTURE's builder, source, partitions and checker remain unchanged. The global current-ID
census excludes only registered immutable history, now two explicit histories.
The snapshot updater changes only mutable-part current counts/hashes. Historical source
identities, source ranges and immutable bytes never become refreshable current state.

The staged verification checker compares declarations by task ID and exact field value
across HEAD and the index. Relocating the 166 unchanged historical tier/focused/trigger
triplets is not a new slice. Exactly one changed owning leaf must contain one nonempty
triplet and a valid focused/canonical tier; missing, duplicate, unowned or split-owner
changes fail. Canonical path classification includes these infrastructure owners and
the existing receipt check remains unchanged. There is no verification exemption.

## Verification and consequences

Independent migration proof must reconstruct all original bytes in source order and
compare every original node/field, not merely count IDs. Production validation rejects
schema/topology/range/source/current-digest drift, unsafe or missing members, duplicate,
lost or misplaced IDs, mutable history, root/frontier drift and pressure overflow.
Public lookup covers every child, boundaries, absent/foreign IDs and outside-CWD use;
refresh must be idempotent and preserve history. Cadence controls test relocation and
malformed declarations without bypassing receipts. The resulting route and all previous
FUTURE data remain within existing controls. The mdBook documents the working commands.

The complete candidate requires ordinary exact staged canonical CI and normal hooks
before its atomic commit closes .16.2 and .16. Before landing, the activation commit is
recovery authority; after landing rollback is a reviewed atomic revert. All generated
proof stays on the repository volume. Perl read-purity startup .89 resumes before .51;
no parser repair, dependency internals, pin change or broader reading credit is included.

## Links

- Plan and independent replay: `docs/knowledge/startup-task-partition-plan.md`
- Frozen checkpoint: `docs/checkpoints/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.1-plan.json`
- Task owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- Current tree: `docs/tasks/SESSION-STARTUP-READING.md`
- Source/store protocol: `docs/decisions/0066-bounded-live-document-store.md`
- Verification tiers: `docs/decisions/0073-tiered-verification-cadence.md`
