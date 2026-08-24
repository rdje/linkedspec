# ADR 0085: Future parity task route implements the eighth semantic member

- Date: 2026-08-18
- Status: accepted/implemented under `.1`; independently recomposed under `FUTURE-PARITY-PARTITION-CAPACITY.2`
- Tags: documentation, task-tree, partition, routing, pressure, continuity, doctrine

## Routing-contract authorization

- Routed surface: `task_evidence`
- Previous routed contract: `{"authority":"docs/decisions/0068-future-parity-task-partitions.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":9},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`
- New routed contract: `{"authority":"docs/decisions/0084-future-parity-task-partition-capacity.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`

## Context

ADR `0084` accepted the exact stable-ID boundary and topology from the preceding clean planning commit. The route
oracle additionally requires any lifecycle/control/owner contract object change—including member limits and its
authority pointer—to be authorized by a newly staged indexed ADR containing the exact old and new canonical
objects. This implementation record satisfies that mechanical review boundary without reopening the topology.

## Decision

Apply ADR `0084` atomically. Add only the new `.14.6.5-.14.8` member limit, raise only the strict index member's
line allowance from 9 to 10 to hold its additional part record, and point the route at ADR `0084`. Preserve owner,
lifecycle, control, state, members, route targets, verifier, transition state, every byte limit, the 5,000-line
semantic-member limit, and all collection limits.

## Consequences

- The staged route change is exact, reviewable, and rejected if either canonical object drifts.
- ADR `0084` remains the implemented topology/storage authority; this record authorizes its same-slice route
  transition rather than defining another partition design.
- No behavior, public API, README content, aggregate capacity, or immutable history changes.

## Links

- Topology authority: `docs/decisions/0084-future-parity-task-partition-capacity.md`
- Owning task: `docs/tasks/FUTURE-PARITY-PARTITION-CAPACITY.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
