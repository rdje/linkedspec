---
id: future-parity-task-partition-capacity
title: Future parity task evidence needs an eighth bounded semantic member at Julia progressive dispatch
answers:
  - "why can Julia progressive span dispatch not be split yet"
  - "why is the FUTURE-PARITY-BACKLOG .14 task member saturated"
  - "where will FUTURE-PARITY-BACKLOG.14.6.5 live"
  - "how many future parity semantic task parts will exist after the capacity extension"
  - "does the future parity partition capacity fix raise task evidence limits"
  - "which consumers must change for the future parity .14.6.5 partition"
date: 2026-08-24
status: implemented/canonical-verified under .1 and independently recomposed under FUTURE-PARITY-PARTITION-CAPACITY.2
tags: [task-tree, partition, retrieval, routing, pressure, continuity, doctrine]
evidence: "At clean 3ccaf7c3, docs/tasks/FUTURE-PARITY-BACKLOG.14.md was exactly 5,000 lines / 544,542 bytes and uniquely owned pending FUTURE-PARITY-BACKLOG.14.6.5. ADR 0084 preserves every pressure ceiling and splits at the first unstarted boundary: the old member now owns .14 through .14.6.4 at 4,988 lines / 543,163 bytes, while new bounded member docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md owns .14.6.5-.14.8 at 13 lines / 1,501 bytes. Schema v1 remains; semantic members are 8, total part records 9, and index records 10. Index, lookup/update/build tools, 27 checker mutations, root navigation, ADR-0085 route authorization, and capability all-parts census move atomically; stable IDs remain 547 and Julia behavior remains pending until independent .2 recomposition."
evidence_update_2026_08_24_recomposition: "From clean canonical implementation commit 0a8accb3, focused FUTURE-PARITY-PARTITION-CAPACITY.2 preserves index SHA-256 74221f0e... across refresh, resolves .14/.14.6/.14.6.4.3/.14.6.5/.14.8 and outside-CWD ownership exactly, rejects unowned .14.9, matches all 10 clean-source range/digest/topology records, and preserves immutable history byte-for-byte. Metadata remains 27/27 over 547 IDs, routing 20/62/32, and capability 80/0/0; capacity is composition-closed and Julia .14.6.5 task splitting is next."
evidence_update_2026_08_25_julia_closeout: "FUTURE-PARITY-BACKLOG.14.6.5.4 closes the subsequent five-leaf Julia split without changing partition topology, stable IDs, pressure ceilings, routes, or capability truth. The bounded owner now hands off shared Lua .14.6.6."
reverify:
  - "wc -lc docs/tasks/FUTURE-PARITY-BACKLOG.14.md docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"
  - "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.6.5"
  - "bash scripts/check_task_tree_metadata.sh"
  - "bash scripts/check_readme_stability.sh"
---

# The Julia frontier exposed a bounded-storage boundary

The stable-ID owner for `.14.6.5` is full at its deliberately strict 5,000-line ceiling. This is not a Julia
runtime defect and does not authorize a larger file. It is a partition-topology capacity defect discovered before
the required Julia task split, so `FUTURE-PARITY-PARTITION-CAPACITY` owns the repair first.

ADR `0084` adds one equally bounded mutable semantic member at the first unstarted boundary. The existing pending
`.14.6.5-.14.8` blocks move byte-for-byte; all completed `.14` through `.14.6.4.3` evidence stays in the original
member. Stable IDs remain unchanged and unique, immutable history remains untouched, aggregate limits remain
fixed, and lookup continues through the same repository-relative command.

Canonical leaf `.1` implements every authority and consumer, including the exact ADR `0085` route transition,
and focused proof resolves `.14.6.5` uniquely to the new member. Host-authorized locality and exact staged
canonical CI pass through primary CLI 66x2 and Phase 0 1,031/1,031 in 801 seconds. Focused leaf `.2` independently
recomposes the committed topology without changing it. Julia `.14.6.5.0-.4` later uses that bounded owner and is
now closed; shared Lua `.14.6.6` is the current clean frontier.
