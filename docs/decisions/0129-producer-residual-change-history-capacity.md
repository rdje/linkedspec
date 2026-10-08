# ADR 0129: Finite change-history capacity for producer-bound residual repair

- Date: 2026-10-08
- Status: accepted engineering maintenance under `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0`; exact canonical admission required
- Tags: history, capacity, continuity, verification

## Exact change-history authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":47,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":48,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":26255,"max_lines":46}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":26831,"max_lines":47}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Exact decision-store prerequisite

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":129,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13043}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":130,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13077}`

## Context and decision

The clean change root is 58,959 bytes, 23 bytes below mandatory rollover. The admitted 47-member collection and 46-row manifest are full. The next complete maintenance record requires rollover under ADR0069. Routing already points to the correct canonical owner. Removing or rewriting accepted history cannot meet its retention contract.

Under the current autonomous full-PNT instruction, follow ADR0128 and admit one archive member, the actual manifest row and this one indexed decision. This is an engineering maintenance decision, not a new explicit director grant. The exact old/new objects above authorize only five scalar changes. Root, per-segment and aggregate history ceilings, thresholds, ownership, lifecycle and every other registry value remain unchanged.

The governed rollover archives clean `e7674382295936a1d6d3dbd34272d9c6803a269d` lines 148–263, 116 lines / 26826 bytes, SHA-256 `52ebe44bf0ea9e311c684dd73644558158156a59f445ff88640fe03a68de3226`. All prior archives, row bytes and accepted decisions remain exact. Stable responsibility remains `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` under ADR0069.

## Verification and consequences

Actual pressure RED precedes governed rollover GREEN. Independent clean Git line/suffix/manifest reconstruction, effective evidence corruptions and actual production threshold/accepted-authority denials verify the finite admission. Normal doctrines, exact staged canonical CI, receipt and hooks are mandatory. No future reserve, runtime change, dependency write or verification waiver is granted. Public parser teaching is unchanged. Producer-bound residual selection follows only after a clean commit; interval mapping and independent replacement admission remain open.

Exact producer and channels: `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0-capacity.py`, `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0-plan.json`, `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0-verification.json`; owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`.
