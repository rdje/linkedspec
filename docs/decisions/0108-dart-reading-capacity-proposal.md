# ADR 0108: Proposed bounded capacity for Dart startup reading

- Date: 2026-09-08
- Status: design accepted by the director on 2026-09-08; execution authorized by ADR 0109 under `.7.2`
- Tags: documentation, capacity, task-tree, knowledge, continuity, reading-gate

Director update: "I greenlight the exception" approves the narrow scope below.
`docs/decisions/0109-approved-dart-reading-capacity.md` records its execution authorization.
The conditional wording below preserves the proposal as it stood at `.7.1` design closeout.

## Context

Clean activation `95915ffb7cf7643d8c3021aeaf83e2141194407d` commits the exact Dart inventory and
capacity measurement. `SESSION-STARTUP-READING.1` records a startup-tracking-only exception; that tree's
acceptance still says that implementation remains gated until required reading closes. Full codebase reading
is No. The active containment `.7` also requires preservation of every unique record and limit.

Dart cannot be admitted by the measured template: 55 groups require 605 task lines, or 616 lines using
the conservative 56-group allowance, before completion evidence and future findings. The governed task
collection has 37 lines available after `.7.0`; the startup file has 562. Knowledge has six Markdown slots.

The proposed aggregate task adjustment also requires code changes: `scripts/check_task_tree_partitions.pl`
lines 208-209 enforce the same 80,000-line / 8,388,608-byte aggregate caps independently of the route
registry; its boundary fixtures at lines 389-390 mirror them. A registry-only change cannot admit the
projected task population. This is the precise conflict requiring a narrow reading-gate exception.

## Measured reserve, not a completion guarantee

The comparison interval is clean Perl closeout `611d7b5c1a53fa8c38fb8fcc17e2304dc21ca63a` through
`.7.0` at `95915ffb7cf7643d8c3021aeaf83e2141194407d`. It includes Rust reading, repairs recorded
for later work, intervening continuity/capacity work and consolidation. It is an observed net-growth
sample, not a causal attribution to Rust alone or a bound on future defects.

| Store | Start | End | Net growth |
| --- | --- | --- | --- |
| Task Markdown, excluding the JSONL index | 99 files / 77,857 lines / 7,869,149 bytes | 100 / 79,953 / 8,187,730 | 1 / 2,096 / 318,581 |
| Knowledge Markdown | 982 files / 53,133 lines / 4,488,750 bytes | 1,018 / 58,998 / 4,896,566 | 36 / 5,865 / 407,816 |
| Generated Knowledge Map | 16,883 lines / 5,271,247 bytes | 17,412 / 5,422,756 | 529 / 151,509 |

There were 36 added and 108 modified Knowledge paths, with no deletion. The Knowledge population is
1,017 fact cards plus `docs/knowledge/README.md`. The `.7.0` commit body incorrectly calls that final
member INDEX; the measured counts and capacity conclusion are unchanged.

Use twice that observed net growth as an explicit planning reserve, plus a 56-group template and
bounded setup/closeout overhead. These are chosen admission margins, not measured future requirements:

| Projection from `.7.0` | Calculation | Projected use | Proposed ceiling |
| --- | --- | ---: | ---: |
| Task lines, including index | 79,963 + 616 template + 2 × 2,096 growth + 1,000 setup/closeout | 85,771 | 88,000 |
| Task bytes, including index | 8,193,445 + 39,000 template allowance + 2 × 318,581 growth + 200,000 overhead | 9,069,607 | 9,437,184 |
| Knowledge files | 1,018 + 2 × 36 growth + 4 setup cards | 1,094 | 1,152 |
| Knowledge lines | 58,998 + 2 × 5,865 growth + 256 overhead | 70,984 | 72,000 |
| Knowledge bytes | 4,896,566 + 2 × 407,816 growth + 65,536 overhead | 5,777,734 | 6,291,456, unchanged |
| Generated map lines | 17,412 + 2 × 529 growth + 256 overhead | 18,726 | 20,000, unchanged |
| Generated map bytes | 5,422,756 + 2 × 151,509 growth + 65,536 overhead | 5,791,310 | 8,388,608, unchanged |

Recompute actual resulting-tree capacity at admission and after each slice. Crossing an allowance requires
another owned review; this proposal does not pre-authorize another increase or promise that every
possible finding fits. All data remains tracked, root-relative and on the repository filesystem.

## Proposed decision — not yet authorized

Request an exception limited to the capacity guard and its directly dependent registry, verification
and continuity documentation before the remaining required reading. Preserve every existing task ID,
node, source scope, Knowledge card, immutable record and per-file ceiling. Preserve all other reading
and repair gates, especially the prohibition on recovery/purge under `SESSION-STARTUP-READING.7`.

Only these two aggregate limit objects would change:

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":8388608,"max_total_lines":80000}`
- Proposed routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":9437184,"max_total_lines":88000}`
- Routed surface: `knowledge_cards`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1024,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":64000}`
- Proposed routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":72000}`

Leave Knowledge Map limits, all task member overrides, immutable-history protections, file/path safety,
all other route limits and all parser/runtime behavior unchanged. This proposed record is not the accepted,
newly staged execution ADR required by `README_POLICY.md`; the implementation leaf must add that exact
authorization only after the director's answer and bind the resulting old/new contract objects.

## Ownership and retrieval

Keep `SESSION-STARTUP-READING.3.4` as the existing Dart prerequisite/closeout owner. At admission,
create the separate bounded tree `docs/tasks/DART-STARTUP-READING.md`, linked from `.3.4`, the task index
and the book. This avoids moving any completed startup evidence or raising its 8,000-line member limit.

The new tree would own `.0` exact decomposition, `.1` bounded reading children, `.2` pending new repair
intakes, and `.3` coverage/delta/comprehension closeout. Do not create or credit source-reading children
until `.0`; obtain exact source membership and ranges from the baseline and the recorded audit. Existing
repair owners stay in place; new findings cross-reference existing owners when they describe the same defect.
Any new repair remains behind the startup reading/policy gates. Reading closeout may complete startup
`.3.4` while the separate tree retains pending repairs; those are distinct claims.

Use ordinary stable task-tree navigation for this unpartitioned tree. The existing FUTURE partition schema,
lookup/update tools, provenance and eight semantic parts remain unchanged. Reserve at most four added
task members in this projection; 105 total including the current index stays below the unchanged 128.
Before admission, project the new Dart member itself below 8,000 lines / 1,048,576 bytes; do not infer
per-member safety merely from aggregate headroom. The original startup member grew by 2,115 lines / 308,951
bytes across the same interval. A separate member projection of 616 template lines + twice that growth +
300 setup lines is 5,146 lines; 39,000 template bytes + twice that growth + 200,000 setup bytes is
856,902 bytes. Both fit the existing member limits; remeasure the actual proposed tree at admission.

## Alternatives considered

- Further duplicate consolidation: `.5` and `.6` already retain exact identities and recover duplicate
  chronology. A limited new scan finds no startup-ledger paragraph of at least 100 normalized characters
  copied verbatim into another tracked task/Knowledge file, and no runs of three or more consecutive blank lines in
  mutable task Markdown. This does not rule out semantic duplication; a further semantic rewrite would
  need its own record-by-record preservation proof and has no established sufficient reserve.
- Split the current startup file alone: fixes its member pressure but does not reduce aggregate lines
  or bytes and does not add Knowledge slots.
- Delete or move history outside the governed store: conflicts with unique-evidence preservation or
  would require a larger storage/retrieval migration. Hiding files from the census is not containment.
- Raise per-file limits or compress prose into dense lines: leaves the aggregate and Knowledge problems
  unresolved and weakens the existing readable-member constraints.
- Complete the remaining reading without tracked scopes or findings: violates task-tree-first and
  crash-recovery requirements. Source enumeration cannot substitute for reading.

## Ordered implementation and verification

`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2` remains blocked on the director's narrow exception. If approved:

1. `.7.2` adds a newly accepted/indexed execution ADR, applies the two exact route limit objects and
   synchronizes the task guard and boundary tests. Audit all current consumers of the limits before
   editing. Prove inclusive acceptance at the chosen limits and rejection just above them through the
   actual validator, including independent line/byte/file dimensions and unchanged member limits.
   Retain existing schema/path/digest/current-ID/immutable and routing mutations. Run exact staged
   canonical CI because this changes doctrine infrastructure; commit and verify clean.
2. `.7.3` independently recomposes the committed controls with focused proof: actual registry/guard
   agreement, exact old task-ID and node-body retention, Knowledge path/question preservation, unchanged
   immutable data and FUTURE retrieval, regenerated map, fresh resulting-tree capacity and the complete
   proposed Dart reserve. No further capacity change is bundled into this verification.
3. `.7.4` admits the bounded pending Dart tree and explicit startup bridge, updates the book and
   continuity, and closes the capacity parent only after exact canonical milestone proof. Commit and
   clear the brief before switching to `DART-STARTUP-READING.0`. No Dart source-reading credit at admission.

Ordinary design `.7.1` changes documentation only and uses focused proof. Until approval, no registry,
guard, capacity, source, task partition or Dart reading changes are authorized. Before implementation,
rollback is abandoning the proposal; after implementation, any rollback is an explicit atomic revert
only if the resulting current population fits the restored caps. Never partially revert the guard/registry.

## Links

- Owning tree: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- Reading gate: `docs/tasks/SESSION-STARTUP-READING.md`
- Measurements and executable inventory: `docs/knowledge/startup-task-chronology-compaction.md`
- Existing policy: `README_POLICY.md` and `docs/decisions/0073-tiered-verification-cadence.md`
- Existing task topology: `docs/decisions/0068-future-parity-task-partitions.md` and ADRs `0084`/`0085`
