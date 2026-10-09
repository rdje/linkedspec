# ADR 0130: Finite engineering-notes aggregate capacity

- Date: 2026-10-09
- Status: accepted engineering maintenance under `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6`; exact canonical admission required
- Tags: history, capacity, continuity, verification

## Exact engineering_notes authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":45,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":45,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29512}`

## Exact decisions authorization

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":130,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13077}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":131,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13109}`

## Context and decision

The clean engineering-notes collection uses all29,000 admitted aggregate lines. Removing two redundant mutable separators admitted the preceding correction; further required records need an explicit finite decision. Existing routing already reaches the canonical owner, and immutable accepted history cannot be shortened, rewritten or repacked to manufacture space.

Under the current full-PNT engineering instruction, following ADR0128/0129, admit exactly512 aggregate lines: one existing bounded hot-shard line allowance. This is an engineering maintenance decision, not a reused or newly asserted director grant. The decision collection admits only this one file and the exact lines of this record plus its index row.

Every other registry value stays exact, including engineering-note membership, manifest, byte, per-file and root limits. No new archive member is admitted. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069. A future rollover or exhausted allowance requires its own finite decision; this does not authorize unlimited PNT growth.

## Verification

Independent Git-backed reconstruction preserves every prior history and decision byte. Actual unchanged production threshold functions reject the new note under the old aggregate ceiling and reject a value above the new ceiling. Exact indexed accepted-authority controls distinguish missing and mismatched decisions. Normal doctrines and exact staged canonical CI/receipt govern landing. Existing public documentation already describes these authority rules; parser, runtime, tests, dependencies and checker implementations are unchanged.

Owner: docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md. Retained producer/review: `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-capacity.py`; plan and actual controls: `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-plan.json`, `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-controls.json`.
