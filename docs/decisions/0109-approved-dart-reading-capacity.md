# ADR 0109: Approved aggregate capacity supports bounded Dart reading

- Date: 2026-09-08
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2` with the director's explicit exception
- Tags: documentation, capacity, task-tree, knowledge, continuity, doctrine, reading-gate

## Authorization

The director approved ADR 0108's narrow exception with: "I greenlight the exception".
This authorizes the capacity guard, its registry and direct verification/continuity changes before
the remaining required reading. All other startup reading and repair gates remain in force.

Clean activation is `b7638e34ad5e3fe245a639bc8bfb378b8fd3ba63`. The roadmap and physical mdBook
reading are complete; full codebase reading remains No. This is capacity infrastructure, not Dart
source-reading credit, parser behavior, a mutation campaign or activation of parked DBINP ideas.

## Exact routing-limit authorization

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":8388608,"max_total_lines":80000}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":9437184,"max_total_lines":88000}`
- Routed surface: `knowledge_cards`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1024,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":64000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":72000}`

Only those four aggregate scalars change. Both route contract objects remain identical: owners,
authorities, members, member overrides, lifecycle, control, state, verifiers, targets, baselines and
transition fields retain their prior values. ADRs 0063 and 0084 remain the respective storage/topology
authorities; this new indexed record authorizes the exact capacity adjustment at this commit boundary.
All other route records and the existing Knowledge Map limits remain byte-identical.

## Context and bounded reserve

At clean activation, task evidence is 101 files / 79,990 lines / 8,196,220 bytes, leaving ten
aggregate lines under the former limit. Knowledge is 1,018 files / 59,073 lines / 4,901,012 bytes.
The startup member has 7,438 lines and cannot fit even the full Dart task template within 8,000.

ADR 0108 measures all 115 Dart paths / 80,296 physical lines / 2,471,305 bytes and projects a
605-line 55-group template or a conservative 616-line 56-group allowance. Its growth sample and
explicit overhead yield 85,771 task lines / 9,069,607 bytes and 1,094 Knowledge files / 70,984 lines
/ 5,777,734 bytes. These margins fit the approved caps and are planning reserves, not guarantees
about unknown future findings. Admission `.7.4` must remeasure the complete actual candidate.

Further exact duplicate consolidation had no demonstrated sufficient reserve; a member split alone
cannot reduce aggregate pressure or create Knowledge slots. Deleting unique evidence or routing it
outside the census would violate preservation. The accepted design therefore keeps every current
record and every per-file ceiling, with a separate bounded future Dart tree rather than a larger
startup monolith. The original proposal retains its alternatives and measurements in full.

## Implementation and proof

`doctrine/readme_stability/routes.jsonl` admits exactly the two limit objects above.
`scripts/check_task_tree_partitions.pl` independently enforces the task collection at 88,000 lines
and 9,437,184 bytes for its Markdown census; the routing census additionally includes the registered
JSONL index, preserving the existing scope of each check. Its main census calls the same pure member/aggregate validators as its
boundary tests. File count remains 128; global task members remain 8,000 lines / 1,048,576 bytes;
all stricter FUTURE members and its exact ten-record partition index remain unchanged.

The partition checker retains the original non-capacity checks and now has 31 self-test classes.
Seven collection classes exercise inclusive limits, each independent file/line/byte overflow,
unchanged member line/byte ceilings and simultaneous violations through the actual validators.
The new boundary assertions failed with the old aggregate guards and pass with the approved ones.

The existing routing validator remains unchanged. The recorded executable audit in
`docs/knowledge/dart-reading-capacity-controls.md` loads its exact `exceeds_limits` function and
the actual approved registry records, then exercises both collections at, below and above each
aggregate/member boundary. This is isolated validator proof; the full resulting-tree routing check
separately validates the staged repository, exact ADR authorization and all 32 existing mutation classes.

Verify registry old/new scope, task IDs/node bodies, Knowledge paths/questions, immutable data and
FUTURE lookup before canonical signoff. Build and inspect the affected mdBook page; synchronize the
derived map, both bounded histories, roadmap, task index and resume pointer. This doctrine
infrastructure leaf requires an exact staged canonical receipt before its atomic commit.

## Consequences and next ownership

- Capacity controls now have the approved finite reserve without altering parser/runtime behavior.
- `.7.3` independently verifies the committed controls and complete proposed Dart reserve.
- `.7.4` admits the pending Dart tree and startup `.3.4` bridge only after its milestone proof.
- Dart decomposition and physical reading begin after that clean admission boundary.
- No further capacity increase, cleanup/purge or parked feature activation is authorized here.
- Rollback requires an explicit atomic guard/registry revert and proof that the resulting population
  fits the restored limits; never partially roll back the guard or silently discard records.

## Links

- Approved design: `docs/decisions/0108-dart-reading-capacity-proposal.md`
- Owning tree: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- Reading prerequisites: `docs/tasks/SESSION-STARTUP-READING.md`
- Current controls: `doctrine/readme_stability/routes.jsonl`
- Direct proof: `docs/knowledge/dart-reading-capacity-controls.md`
