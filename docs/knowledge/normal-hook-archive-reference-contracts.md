---
id: normal-hook-archive-reference-contracts
title: Normal-hook restoration preserves archive identity and admits maintained reference scope
answers:
  - "why are history lifetime totals replaced by archive contracts"
  - "how are canonical reference changes admitted without aggregate cap increases"
  - "where is the TYPE reference task tree after narrative containment"
  - "how can closed task narratives be reconstructed exactly"
  - "does claim caching preserve staged snapshot checks"
  - "why does reference scope update reject a finished leaf when memory names the next leaf"
  - "why must the task narrative epoch fixture seed every retained source"
  - "why did the epoch fixture miss LUA-BACKEND-PARITY.md"
  - "how does recurring factory review separate current semantics from historical source bytes"
  - "why does adding lookup aliases change the Knowledge Map question total"
date: 2026-11-04
status: accepted
tags: [doctrine, history, tasks, knowledge-map, claim-verification]
evidence: "Accepted ADR0139, catalog/source corruption controls, independent task precursor oracle, full Knowledge projection comparison and claim snapshot/owner controls. 20.1.10 was canonically accepted at cd3b6adc. Later epoch20.2 retains focused source/CLI/contract proof; exact canonical acceptance separately governs its infrastructure landing."
reverify: "bash scripts/check_task_tree_metadata.sh; bash tools/run_python_project_data.sh tools/check_reference_scope.py; bash tools/run_python_project_data.sh tools/test_claim_verification_cache.py"
---

ADR `0139` records explicit director adoption of the archive/reference contracts.
History remains exact and immutable; bounded hot roots and segments coexist with content-addressed
catalog pages. The public history reader resolves both flat and paged catalogs. Publishing new pages
before replacing the root preserves readers using older roots. The gate retains all prior rows/pages
and compares segment bytes with their declared Git source slices.

Maintained decisions, facts and public references keep their canonical paths and existing per-file bounds.
The generated paged ledger under `doctrine/readme_stability/reference-scope/` binds every current member
and hash to a unique task owner. Its checker rejects undeclared membership, stale bytes, symbolic files,
provenance reassignment and removal without a preservation migration. Update it before staging with
`bash tools/run_python_project_data.sh tools/update_reference_scope.py --owner <leaf-id>`.

The current TYPE graph lives in four semantic parts. Resolve the current owner with
`perl tools/read_task_tree.pl --tree TYPE-REFERENCE-BOOK --id <stable-id>` and refresh its digest with
`perl tools/update_task_tree_index.pl --tree TYPE-REFERENCE-BOOK` after editing. Closed task contracts
remain current; exact predecessor narrative is available through
`python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id <stable-id>` or `--all`.
The archive explicitly names its historical source; it does not replace the current graph.

Later unpartitioned-tree extraction uses an explicit `--epoch` without changing those original queries.
The bounded immutable manifest under `docs/history/task-narrative-epochs/` binds a retained ancestor commit,
source path, Git blob/SHA-256 and selected IDs. Full-history Git supplies the complete original body.
The current graph retains every CORE field and complete open/unselected bodies. The task metadata gate
checks source identity, ancestry, current contracts/pointers and committed-manifest immutability.
The actual83-ID/72-closed/11-open extraction and22 specific denials are retained under
`docs/checkpoints/task-budget-renewal-2026-11-04/`; default review is read-only. Its dated collection count
precedes continuity edits; exact canonical acceptance and normal hooks separately gate the final candidate.

Knowledge compaction combines date/status/source display and removes redundant separators. It retains
authored question order and multiplicity, route rows, titles and all evidence/reverify values.
Publication still uses the independently checked validated sibling and atomic rename.

Claim verification reuses immutable blob identities within one captured index and constructs the unique
current owner/status table once. Cache entries do not cross snapshots; historical revision and mode
remain part of resolution, memory is bounded, and a changed index rejects the complete check.
The original and repaired complete checks passed the same retained index. Their dated timing is an
observation of those runs, not a portable performance or complete bottleneck claim.

2026-11-05 workflow clarification: before staging, reference-scope owner selection
reads `MEMORY.md` active_work_unit, whereas the staged verifier derives the changed
leaf. Keep the completed owning leaf in active_work_unit for its clean handoff,
with next_action naming the next frontier; refresh scope for that completed owner
before staging. A completed active leaf is supported by the memory contract when
it retains no in-flight work and does not schedule its own landing again. Merely
passing `--owner` cannot override a different worktree active_work_unit. Source:
`tools/reference_scope.py` Snapshot.selected_owner/build.

2026-11-10 — The epoch mutation fixture must seed every current source named by
its copied retained-manifest catalogue. Selecting one older epoch as the mutation
subject does not limit verify_epochs to that epoch. Lua4.16 exposed the incomplete
setup as a missing fixture LUA-BACKEND-PARITY.md even though production epoch
verification passed. TYPE23.4.18.1 derives every source through the validated
manifest owner, preserves the exact-old failure/repaired consumer, and checks
frozen copied membership/bytes with missing/altered-source controls. See
`docs/checkpoints/knowledge-map-capacity-2026-11-10/epoch_fixture_review.py`.
The earlier20.2 source observation is historical at accepted5801970b4d311e97b5764d16a2573a4094144e49;
restore that epoch for its original producer/current-namespace recipe. No production
reader or separately owned lowercase frontier4.17 behavior changes in this repair.

Recurring evidence review must distinguish historical byte preservation from
current semantic compatibility. The November4 factory capsule preserves its
original intake/after production bytes and original native records. Requiring
today's MethodLowering.pm to equal that snapshot incorrectly rejects later
feature changes before executing the unchanged compatibility oracle. TYPE23.4.18.1
retains that actual refusal and proves the unchanged native/fresh targets already
pass before correcting the reviewer. Current execution still checks original
values, kinds and effects; its historical source-calibration companion replays
the frozen single-correction image. Actual wrong-native-kind, missing-fresh-effect
and unrelated-historical-source-edit controls reject. Original claims already
bind accepted cd3b6adc3e58fb64283ae4ae4a5a37823eabd891; no hashes or observations
are refreshed. Source-only snapshots are not full native/transitive custody.
Readonly route: `docs/checkpoints/knowledge-map-capacity-2026-11-10/factory_boundary_review.py`.

Historical objective source-image admission is a separate boundary from those
factory compatibility probes. The canonical explanation and November10 exact
successor/first-image repair live in [[three-objective-language-readiness]].

2026-11-10 — Alias-only navigation edits also update the derived question-total
header: the generator counts question rows, including authored aliases and
repeats, independently of fact rows. Preserve every original route and Facts
byte; derive the expected header total from the complete question rows rather
than retaining an older total or changing a threshold. Exact readonly routing
review: `docs/checkpoints/lookup-aliases-2026-11-10/review.py` at this accepted
lookup source epoch. This describes deterministic projection, not fresh runtime
or wider evidence admission.
