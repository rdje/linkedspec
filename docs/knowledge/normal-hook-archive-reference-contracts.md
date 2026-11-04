---
id: normal-hook-archive-reference-contracts
title: Normal-hook restoration preserves archive identity and admits maintained reference scope
answers:
  - "why are history lifetime totals replaced by archive contracts"
  - "how are canonical reference changes admitted without aggregate cap increases"
  - "where is the TYPE reference task tree after narrative containment"
  - "how can closed task narratives be reconstructed exactly"
  - "does claim caching preserve staged snapshot checks"
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
