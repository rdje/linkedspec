# ADR 0068: Future parity task evidence uses stable semantic partitions

- Date: 2026-08-09
- Status: accepted and implemented under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2` at `61a52dbd`
- Tags: documentation, task-tree, retrieval, routing, continuity, doctrine

## Routing transition authorization

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":4194304,"max_files":128,"max_lines_per_file":32000,"max_total_bytes":8388608,"max_total_lines":80000,"transition_max_byte_delta":524288,"transition_max_file_delta":2,"transition_max_line_delta":4096}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":8388608,"max_total_lines":80000}`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{},"members":["docs/tasks/*.md"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2","route_targets":["docs/tasks/"],"state":"debt","transition_owners":["LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2","README-STABILITY-POLICY.4"],"verifier":"internal:indexed"}`
- New routed contract: `{"authority":"docs/decisions/0068-future-parity-task-partitions.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":9},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000}},"members":["docs/tasks/*.md","docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2","route_targets":["docs/tasks/"],"state":"current","transition_owners":null,"verifier":"task_tree_metadata"}`

This exact staged transition retires the immutable task-evidence debt baseline. It does not refresh the old
high-water mark. The new current collection clears debt metadata, lowers the global per-file ratchet, gives every
future-backlog member a stricter limit, and uses the executable task-tree metadata verifier.

## Decision

`docs/tasks/FUTURE-PARITY-BACKLOG.md` remains the stable tree entry point but becomes a 381-line bounded current
index. It retains the original metadata, root node, authoritative frontier, current decisions, open questions,
and blockers, then adds exact part navigation and repository-rooted retrieval/update commands. It contains no
duplicated child node block.

The clean source at `99fe03f3adf28ba52b6ac4fa7af60b38c7ba7eb9` is 26,979 lines / 2,720,175 bytes, Git
blob `f3b59f72b3cf1b66da842350caec552408e28d7e`, and SHA-256
`48de44a56bcde1ae6d5e274e2786d939b596d2063756f994d4cfb407be4b3f95`. Its lines are source-accounted exactly
once by the root provenance ranges, seven mutable semantic parts, and one immutable history part:

| Partition | Source lines | Source bytes | Source SHA-256 |
| --- | ---: | ---: | --- |
| `.0-.8` plus late `.1`/`.5` evidence | 3,593 | 308,731 | `32cb59b4ff9decee24008e0c06bea71e8be87fabec300ce0c0a74707c9e90d73` |
| `.9` | 3,596 | 321,930 | `421b642d3249fabe28f1bdba11644b8d9871329ac7fa029fd4a4f74ad64ecea0` |
| `.10`, `.10.0-.6` | 4,188 | 380,436 | `dba86b3a37da0aed4ef3c158a9beb99fc40dee28322aa7599af11cb13bd8c1d9` |
| `.10.7-.10` | 4,139 | 382,618 | `c33fc911c7b0ce7bff865d60dc325dbccb2b024676dfeb56cf3960e7fa400fef` |
| `.11-.13` | 2,016 | 179,314 | `9281d7880215fe7ccd646eaecd582179f1150d22870167f827bc283c409a74c9` |
| `.14` | 3,952 | 357,684 | `dd687f9e196e83ead5e0d64715d32cde5103d6a6c573da30fdaf82be2e22e8e2` |
| `.15-.24` | 1,804 | 146,914 | `bfd2bd6f2775b614facea3846451e40539d3f5cb55293f00188df1d412bdc80a` |
| Immutable legacy global history | 3,340 | 609,734 | `3731fc8fa2faf26143c19a5b59a9033907311aa10d938281c5d4ad93768dfacf` |

`docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl` is the strict schema-v1 authority. It binds source commit/blob/
census/digest, root provenance, exact part order/ranges/mutability, initial source digests, and same-commit current
counts/digests. Mutable part digests are refreshed only with their owning task leaf via
`perl tools/update_task_tree_index.pl --tree FUTURE-PARITY-BACKLOG`. Stable-ID lookup is
`perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id <stable-id>` and returns the one bounded owner.

`scripts/check_task_tree_metadata.sh` composes the strict partition checker before its existing status/evidence
rules. It rejects unsafe/symlink paths, schema/order/range/source/digest/count drift, missing or duplicate IDs,
wrong-range placement, lost clean IDs, stale lookup, broken root references, root node duplication, mutable
history, old-monolith machine consumers, member pressure, and collection pressure. Twenty-six independent
in-memory mutations exercise those classes.

## Consumer transfer

The exact eleven machine consumers now read bounded semantic owners:

- capability exclusion checker: all seven semantic parts for its complete task-ID/status census, with `.15-.24`
  as its public exclusion projection;
- logical-helper, diagnostic-output, generated-source, and native-spec-resolution checkers: `.00-08`;
- duplicate-regex-slot-identity checker: `.09`;
- repeated-action JSON: `.9`; repeated-action checker: `.9` plus `.10.0-.6` for its preserved next-owner handoff;
- root-selection checker: `.9`;
- semantic-introspection JSON public projection: `.10.7-.10`;
- semantic-introspection executable owner check: `.10.0-.6`, with its public projection in `.10.7-.10`.

The checker rejects any restoration of the old monolith path under all nine executable and two JSON scopes. The stable root remains reader
navigation, not a compatibility content duplicate.

## Consequences

- All 510 pre-migration stable IDs remain exact, unique, range-owned, and retrievable without scanning a
  26,979-line monolith.
- The immutable history part remains positive historical evidence and cannot become a mutable append sink.
- Task evidence is now a current bounded collection with 8,000-line / 1-MiB global member limits and stricter
  5,000-line / 768-KiB future-backlog member limits.
- No parser, compiler, runtime, backend, MCP, CLI, fixture, protocol, schema, `.spec` language behavior, or README
  content changes. Changes and engineering-note migration is separately implemented by ADR `0069`.

## Links

- Descriptor authority: `docs/decisions/0066-bounded-live-document-store.md`
- Owning task: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- Task index: `docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl`
- Route registry: `doctrine/readme_stability/routes.jsonl`
