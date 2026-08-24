# FUTURE-PARITY-PARTITION-CAPACITY: Bounded Stable-ID Growth

## Metadata

- Tree ID: `FUTURE-PARITY-PARTITION-CAPACITY`
- Status: `active` / `.1` canonical-signoff-complete; `.2` pending independent recomposition
- Roadmap lane: `Repository continuity / bounded task evidence`
- Created: `2026-08-18`
- Last updated: `2026-08-24`
- Owner: repo-local workflow

## Goal

Restore safe task-tree-first growth for `FUTURE-PARITY-BACKLOG.14.6.5+` without raising the 5,000-line member
ceiling, appending to immutable history, changing stable IDs, or losing exact lookup and consumer coverage.

## Trigger and measured boundary

Clean committed `HEAD` `3ccaf7c3ab1be95bf427818414f6aa5c83e22836` closes Dart progressive dispatch and
hands off to Julia parent `FUTURE-PARITY-BACKLOG.14.6.5`. The stable lookup owner
`docs/tasks/FUTURE-PARITY-BACKLOG.14.md` is exactly 5,000 lines / 544,542 bytes. Adding the required Julia RED,
authority/core, carrier, and admission children would violate the exact 5,000-line member limit enforced by ADR
`0068`, `tools/update_task_tree_index.pl`, `scripts/check_task_tree_partitions.pl`, task metadata doctrine, and the
README route registry.

The existing schema-v1 index has metadata plus eight part records and no overflow member. The real unstarted
stable boundary is `.14.6.5`: the current file ends with pending `.14.6.5-.14.8` nodes, and all completed evidence
through `.14.6.4.3` can remain in the original `.14` member. The saturation is a storage-topology defect, not a
reason to enlarge a bounded member or weaken task-tree-first doctrine.

## Accepted direction

- Preserve the original `.14` member as the sole owner through `.14.6.4.3`.
- Move the unchanged pending node blocks `.14.6.5-.14.8` to a new mutable semantic member, then add new Julia
  children only there after the infrastructure tree is clean and closed.
- Extend the strict index, stable-ID lookup/update tools, partition checker and mutations, bounded-route member
  registry, root navigation, and every all-parts consumer in one canonical implementation leaf.
- Preserve every stable ID exactly once, current status and dependency truth, source provenance, immutable legacy
  history, aggregate limits, per-member 5,000-line / 786,432-byte limits, and repository-relative paths.
- Close with an independent no-change recomposition leaf before returning to Julia `.14.6.5`.

## Non-Goals

- Do not change Julia, Lua, Perl, Rust, or Dart parser/compiler/runtime behavior.
- Do not activate or split Julia `.14.6.5` inside this infrastructure tree.
- Do not raise per-file, aggregate-line, aggregate-byte, or collection-file ceilings merely to accommodate
  unbounded evidence growth.
- Do not append new evidence to `docs/tasks/FUTURE-PARITY-BACKLOG.history.md` or rewrite immutable legacy bytes.
- Do not renumber, alias, duplicate, truncate, or summarize stable task IDs or their committed evidence.
- Do not change README content, generated formats, public DSL/API, facade/schema/MCP/CLI behavior, or hosted CI.

## Acceptance criteria

- The task-tree capacity defect and every affected authority/consumer are measured before implementation.
- A newly accepted decision authorizes only the additional bounded semantic member and exact schema/tool consumer
  changes; no pressure ceiling increases.
- Stable-ID lookup returns exactly one owner before and after the `.14.6.5` split.
- Exact source accounting proves no task node/evidence loss or duplication.
- All task metadata, route pressure, capability census, Knowledge, public book, continuity, and commit workflow
  surfaces remain aligned.
- The implementation leaf is canonical because it changes doctrine/checker/tool/routing infrastructure.
- The closeout leaf independently recomposes the committed topology without changing it.

## Task tree

- ID: `FUTURE-PARITY-PARTITION-CAPACITY`
  Status: `active` (2026-08-18; `.0` task-tree-first from clean `3ccaf7c3`)
  Goal: Extend bounded future-parity task storage at a stable semantic boundary and restore the Julia frontier.
  Depends on: `FUTURE-PARITY-BACKLOG.14.6.4.3`
  Children: `.0-.2`

- ID: `FUTURE-PARITY-PARTITION-CAPACITY.0`
  Status: `done; focused-signoff-complete` (2026-08-18; task-tree-first from exact clean `3ccaf7c3`; intended
  planning commit; no implementation change)
  Goal: Reproduce saturation, inventory all topology consumers, and freeze the exact `.14.6.5` split contract.
  Depends on: `FUTURE-PARITY-BACKLOG.14.6.4.3`
  Acceptance: retrieve ADR `0068`, the bounded-store and partition Knowledge authorities, task lookup/update/check
  tools, route registry, all direct part consumers, root navigation, mdBook, and live continuity before any
  implementation; prove the exact 5,000-line boundary and clean handoff; freeze the new member identity/range,
  exact moved pending bytes, schema/tool/checker/consumer changes, mutation/failure proof, rollback, `.1-.2`
  ownership, and no-behavior boundary; align durable planning truth and land focused from a clean tree.
  Verification tier: `focused`.
  Focused checks: exact clean/head/brief/book state; line/byte/file census; stable-ID lookup; affected-consumer
  scan; task metadata and route-pressure checks; Knowledge generation; mdBook render; memory architecture; all
  doctrines; bounded histories; exact diff and clean commit handoff.
  Canonical trigger: `none for the behavior-free audit; .1 is explicitly canonical because it changes task-tree
  schema, lookup/update tools, doctrine checker, route controls, and an all-parts capability consumer`.

  ### Acceptance checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove exact clean `3ccaf7c3`, zero-byte brief, absent rendered
    book, no background job, and make this task file the first mutation before any planning/doc change.
  - [x] **REPRODUCE / MEASURE** — Resolve `.14.6.5` through the stable lookup, measure `.14` at exactly
    5,000/5,000 lines, and prove update/metadata/route enforcement rejects an additional line.
  - [x] **ROOT CAUSE / CONSUMERS** — Map index cardinality, partition range routing, update/read/build tools,
    checker mutations, root navigation, route member limits, and every machine consumer that enumerates parts.
  - [x] **FREEZE SPLIT / ROLLBACK** — Select `.14.6.5` as the real pending boundary; specify exact move,
    provenance, unique-ID/count/digest checks, clean rollback, and `.1-.2` dependency order.
  - [x] **LOCKSTEP / NO BEHAVIOR** — Align ADR/Knowledge/task index/roadmaps/live docs/mdBook without parser,
    backend, generated-format, public surface, README, or progressive-rollout movement.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused checks, commit `.0`, clear the brief, and prove clean
    before `.1` changes any task partition or executable authority.

  ### TOOLBOX task-acceptance checklist

  - [x] **REPRODUCE / ISSUE** — Repository tools show the exact saturated owner and pending Julia stable ID.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Tool-backed evidence identifies the fixed eight-part schema and absent
    post-`.14.6.4` capacity at exact source locations.
  - [x] **FIX** — Freeze one additional bounded semantic member and all exact authority/consumer updates; code
    belongs only to `.1`.
  - [x] **ADDRESSED (verified)** — Planning checks prove the selected boundary and complete consumer inventory.
  - [x] **NO REGRESSION** — Stable IDs, current statuses, behavior, rollout, public surfaces, and pressure ceilings
    remain unchanged in `.0`.
  - [x] **LOCKSTEP** — Task, ADR, Knowledge, book, roadmaps, continuity, commit, brief, and next owner agree.

  Evidence: exact clean `3ccaf7c3`, zero-byte brief, absent initial book output, unique stable lookup to `.14.md`,
  5,000 lines / 544,542 bytes, nine-record schema-v1 index, and 12-line / 1,379-byte pending boundary are proved.
  Clean-source ranges `17123-21064` and `21065-21074` retain exact counts/bytes/digests. ADR `0084` freezes the
  eighth semantic member without increasing any pressure ceiling; index/read/update/build/check/root/route and
  capability-consumer changes belong only to `.1`. Knowledge Map 858/7,247, task mutations 26/26 over 547 IDs,
  capability 80/0/0, README routing 20/62/32, both bounded histories, memory architecture, all nine doctrines,
  exact diff checks, and real mdBook rendering pass; generated output is removed. No partition, executable tool,
  route, capability consumer, backend, generated format, rollout, public surface, README, or history byte changes.
  Commit: `FUTURE-PARITY-PARTITION-CAPACITY.0 - freeze bounded split plan`.

- ID: `FUTURE-PARITY-PARTITION-CAPACITY.1`
  Status: `done; canonical-signoff-complete` (2026-08-24; task-tree-first from exact clean planning commit
  `2cf4c9dd`; intended implementation commit; no topology change preceded activation)
  Goal: Implement the additional bounded semantic member and atomically migrate `.14.6.5-.14.8` with every
  index/tool/checker/consumer/route authority updated.
  Depends on: `.0`
  Acceptance: begin from the clean `.0` commit; move unchanged pending node blocks at the frozen boundary; extend
  the exact index schema, lookup/update/build/check tooling, checker mutation suite, root navigation, bounded route
  contract, capability all-parts census, ADR/Knowledge/book/live docs, and no-drift proof; preserve exact unique
  stable IDs and all committed evidence; pass focused direct dependents plus receipt-bound canonical CI; commit,
  clear the brief, and prove clean before `.2`.
  Verification tier: `canonical`.
  Focused checks: exact pre/post source accounting and ID uniqueness; lookup on both sides of the boundary; update
  index freshness; task metadata mutation suite; route pressure; capability conformance; every direct consumer;
  Knowledge, mdBook, bounded histories, memory architecture, doctrines, exact staged diff.
  Canonical trigger: `task-tree schema, doctrine checker, repository tools, bounded-route controls, and a canonical
  capability consumer change atomically with the partition topology`.

  ### Acceptance checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove exact clean planning commit `2cf4c9dd`, zero-byte brief, absent
    generated book, no background job, and `.1` activation as the first new mutation.
  - [x] **EXACT MOVE / SOURCE ACCOUNTING** — Move only the frozen 12-line / 1,379-byte pending block; preserve both
    source comments; prove old/new current and original-source counts, bytes, digests, unique IDs, and history bytes.
  - [x] **INDEX / RANGE TOOLS** — Retain schema v1 while changing to ten records / eight semantic parts; make
    `.14/.14.6/.14.6.4.3` and `.14.6.5/.14.8` resolve exactly once through read/update/build authorities.
  - [x] **CHECKER / CONSUMERS** — Extend partition contract/mutations/root navigation and require the capability
    census to enumerate all eight semantic members; preserve all other exact machine-consumer routes.
  - [x] **BOUNDED ROUTE** — Apply ADR `0084` through newly staged exact-route ADR `0085`; add one member limit and
    one index-record line only while every collection/per-file/aggregate/member ceiling stays fixed.
  - [x] **LOCKSTEP / NO BEHAVIOR** — Align ADRs, Knowledge, roadmaps, book, tasks, live docs, and memory without
    parser/compiler/runtime/backend/generated/progressive/typed/public/README/outward movement.
  - [x] **FOCUSED + CANONICAL / COMMIT / CLEAN** — Pass all direct dependents, real builder and book render,
    doctrines/histories/exact diff, staged receipt-bound canonical CI, commit, clear the brief, and prove clean.

  ### TOOLBOX task-acceptance checklist

  - [x] **REPRODUCE / ISSUE** — Committed `.0` evidence and repository tools reproduce the exact saturation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Schema/range functions and route oracle locate every fixed-topology seam.
  - [x] **FIX** — One bounded member plus exact index/tool/checker/route/consumer changes implement ADRs `0084/0085`.
  - [x] **ADDRESSED (verified)** — Both boundary lookups, source accounting, builder, refresh, route, and census pass.
  - [x] **NO REGRESSION** — All 547 IDs, immutable history, pressure ceilings, behavior, rollout, and public guards hold.
  - [x] **LOCKSTEP** — Task, ADR, Knowledge, book, roadmaps, continuity, receipt, commit, brief, and `.2` agree.

  Evidence: the new member is the byte-exact prior 12-line block plus source comment; prefix reconstruction proves
  the old member changed only by that move, and immutable history SHA-256 is unchanged. Current old/new measures are
  4,988/543,163/`d7d6f8c5...` and 13/1,501/`5e2762a3...`; original ranges retain exact 3,942/357,142/
  `6f04e2a0...` and 10/542/`a2b84198...`. Schema-v1 refresh is byte-idempotent at ten records; old, parent,
  boundary, new, and outside-CWD lookups pass while `.14.9` fails unowned. The repository-local clean-source
  builder writes 8 semantic + 1 immutable part and the ten-record index. Task metadata passes 27/27 over 547 IDs
  and 97 task files; route pressure passes 20/62/32 with exact staged ADR `0085`; capability remains 80/0/0;
  Knowledge Map is 858/7,247; the book renders and is removed; both histories, memory, exact staged/worktree diff,
  and all nine doctrines pass. The host-authorized representative process-locality proof passes. Exact staged
  canonical CI passes every required group, including Rust semantic admission 1/1 in 81.27s, Julia semantic
  admission 416/416 in 32.7s, primary CLI 66x2, RAM 37%, and Phase 0 1,031/1,031 in 801 seconds, and writes the
  staged candidate receipt. No product/runtime/generated/public behavior changes.
  Intended commit: `FUTURE-PARITY-PARTITION-CAPACITY.1 - implement eighth bounded semantic member`.

- ID: `FUTURE-PARITY-PARTITION-CAPACITY.2`
  Status: `pending`
  Goal: Independently recompose the committed extended topology and hand the clean frontier back to Julia
  `FUTURE-PARITY-BACKLOG.14.6.5`.
  Depends on: `.1`
  Acceptance: add no replacement topology or behavior; independently rerun source accounting, exact stable-ID
  lookups across every part, metadata mutations, route pressure, all direct consumers, capability census,
  Knowledge/book/live continuity, and required focused checks; close this tree only on exact committed agreement;
  commit, clear the brief, and prove clean before activating Julia task children.
  Planned verification tier: `focused`.
  Planned focused checks: committed topology/source/ID/digest recomposition; all task consumers; task metadata and route
  pressure; capability conformance; Knowledge, mdBook, bounded histories, memory architecture, doctrines, exact
  diff and clean handoff.
  Planned canonical trigger: `none when the committed topology recomposes exactly; escalate only if .2 must change an
  executable authority or exposes cross-cutting uncertainty`.

## Current frontier

`FUTURE-PARITY-PARTITION-CAPACITY.2` — from the clean `.1` implementation commit, activate the focused leaf and
independently recompose every committed topology, lookup, route, and consumer invariant.

## Decisions

- Preserve the 5,000-line member ceiling; capacity comes from one additional bounded member.
- Split only at `.14.6.5`, the first unstarted stable parent after committed Dart closeout.
- Keep Julia behavior under `FUTURE-PARITY-BACKLOG.14.6.5`; this tree owns storage continuity only.
- ADR `0084` is the exact routing/topology authority; ADR `0068` remains the original partition authority.

## Blockers

- Julia `.14.6.5` task splitting remains sequenced behind clean independent `.2`; no environmental blocker remains.

## Change log

- `2026-08-18`: Tree created task-tree-first from clean `3ccaf7c3` after exact `.14` saturation blocked the next
  roadmap leaf.
- `2026-08-18`: `.0` freezes the exact bounded split, consumer inventory, rollback, and no-behavior boundary;
  focused gates pass and canonical `.1` is the next clean frontier.
- `2026-08-18`: `.1` activated task-tree-first from clean planning commit `2cf4c9dd`; topology remains unchanged
  at activation.
- `2026-08-18`: `.1` atomically implements the eighth semantic member and exact route/tool/checker/consumer
  updates without product behavior. Focused proof passes; canonical CI reaches the process-locality proof after
  all preceding groups pass, but the outer sandbox denies nested `sandbox-exec`. Host-authorized rerun is blocked
  by the approval service usage limit, so `.1` remains active and `.2` is not eligible.
- `2026-08-24`: Host-authorized locality and exact staged canonical CI pass through primary CLI 66x2 and Phase 0
  1,031/1,031 in 801 seconds; `.1` is canonical-signoff-complete for its intended commit and `.2` is next.
