# ADR 0069: Changes and engineering notes use bounded rollover hot stores

- Date: 2026-08-10
- Status: accepted and implemented under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` at `921f0507`
- Tags: documentation, history, retrieval, rollover, routing, continuity, doctrine

## Change-history routing transition authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes":4194304,"max_lines":55000,"transition_max_byte_delta":65536,"transition_max_file_delta":0,"transition_max_line_delta":512}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":16,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"debt_bounded","lifecycle":"append_only","member_limits":{},"members":["CHANGES.md"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md"],"state":"debt","transition_owners":["LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","README-STABILITY-POLICY.4"],"verifier":"internal:query_first"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":16}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Engineering-notes routing transition authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes":3145728,"max_lines":27000,"transition_max_byte_delta":65536,"transition_max_file_delta":0,"transition_max_line_delta":512}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":10,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- Previous routed contract: `{"authority":"docs/decisions/0063-bounded-readme-landing-page.md","control":"debt_bounded","lifecycle":"rolling_history","member_limits":{},"members":["DEVELOPMENT_NOTES.md"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md"],"state":"debt","transition_owners":["LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","README-STABILITY-POLICY.4"],"verifier":"internal:query_first"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":10}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

These exact staged transitions retire both immutable debt baselines. They do not refresh a high-water mark. The
new current collections clear debt metadata, preserve their prior aggregate ceilings, add finite file counts and
fixed per-member ceilings, and use the registered document-history verifier.

## Decision

`CHANGES.md` and `DEVELOPMENT_NOTES.md` remain stable author and reader paths, but each is now a bounded current
hot shard over exact immutable history. Both roots are limited to 512 lines / 65,536 bytes. The rollover command
warns at either 80% boundary, requires action at either 90% boundary, and moves the oldest complete clean-HEAD
records until the retained root is at or below 256 lines and 32,768 bytes.

The complete sources at `61a52dbdd625230a69ae7cbc792be7a1ca7ee702` are preserved before root replacement:

- `CHANGES.md`: 44,270 lines / 3,104,131 bytes, Git blob
  `2e951cabd39f4f8cc00b5eebb499c9fbf417b971`, SHA-256
  `c8ba1b7c92fe2536d75bad23f047f46da6cf1fc036f5f420bdf997f2b2c14e42`, eleven archive segments.
- `DEVELOPMENT_NOTES.md`: 21,308 lines / 2,291,424 bytes, Git blob
  `0522cdf5b9b1b182c44ffa764e56b1a6ed087508`, SHA-256
  `ca9ad5c3e3d243d972053cfbdc8a37fe545c92e41e143b1a70a8bd2fcfe9443c`, six archive segments.

The hot surfaces deliberately extend ADR `0066`'s schema-v1 segment ordering without changing its fields or the
already-landed live-status manifest. Initial legacy segments reserve IDs `5000` upward. A later rollover proves
its selected bytes are a complete-record suffix of the clean HEAD root, assigns the next lower ID, and prepends
the content-addressed record to the manifest. Consequently manifest IDs remain ascending, newer rollover chunks
sort before older archive content, and no immutable path ever needs renaming. The reserve permits 4,999 rollovers;
the stricter 16-file and 10-file route ceilings require a separately reviewed evolution much earlier.

Initial legacy segments may end at exact line-preserving boundaries. Future `CHANGES.md` rollover begins only at
`^## `; future engineering-notes rollover begins only at a dated-entry or `^## ` boundary. The tool rejects any
rewrite, reordering, or removal of clean-HEAD records and refuses to archive uncommitted new entries. Each archive
record remains an exact Git source slice, and manifest-order `--all`, bounded `--segment`, and literal `--grep`
queries remain repository-root derived.

The clean legacy notes also contain trailing spaces. Those bytes remain part of the bound Git source and cannot be
normalized. The existing raw-history-only Git attribute therefore exempts `docs/history/**/segment-*.md` from
blank-at-EOL/EOF reporting; ordinary current roots and non-archive files retain the normal whitespace contract.

Rollover is a recoverable three-file publication. It writes or verifies the content-addressed segment first,
publishes the manifest second, and replaces the bounded root last. If interrupted after the segment alone, rerun
reuses only exact matching bytes. If interrupted after the manifest, rerun recognizes the exact pending
clean-HEAD generation and completes the retained root. Mismatched targets or pending metadata fail closed, so an
interruption never removes the only current/queryable copy of a record.

## Consequences

- Exact prior chronology remains queryable and reconstructable without unbounded stable roots.
- Commit authors prepend complete records and must check both rollover boundaries before staging.
- The registered doctrine proves strict schemas, Git source slices, immutable targets, anchor reconstruction,
  manifest order, retrieval commands, hot-root shape, and threshold behavior.
- Parser, runtime, backend, MCP, CLI, `.spec` language, README, and project-data-root behavior do not change.

## Links

- Descriptor authority: `docs/decisions/0066-bounded-live-document-store.md`
- Owning task: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`
- Change history: `docs/history/changes/manifest.jsonl`
- Engineering notes: `docs/history/development-notes/manifest.jsonl`
- Route registry: `doctrine/readme_stability/routes.jsonl`
