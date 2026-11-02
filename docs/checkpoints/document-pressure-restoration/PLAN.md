# Normal-hook restoration: approved containment contracts

Owner: `TYPE-REFERENCE-BOOK.1.2.20.1.3`; implementation parent: `TYPE-REFERENCE-BOOK.1.2.20.1`.
Status: **approved by the director’s explicit archive/reference choice**. Implementation is owned by20.1.10; this plan alone does not claim migrated data or passing gates.
Source boundary: `7ec45b810a5ef6c853e8068a04d55167671dbbb2`, after the E2BIG implementation.

## Established boundary

The two path/storage checkers now execute successfully on the actual tracked tree. Their original E2BIG diagnosis and repaired controls are retained in `docs/checkpoints/type-operation-inventory/gate-argv-limit-intake.json.gz` and `docs/checkpoints/type-operation-inventory/gate-path-streaming-intake.json.gz`. Canonical closure is still pending; the normal hooks remain blocked by document pressure.

The local contract is `README_POLICY.md` plus `doctrine/readme_stability/routes.jsonl`. The supplied containment guide is a read-only input, SHA256 `8f77fa39c9bcb9cfc43166259a627a6ced64682030088400b727dccc5d674a53`; adopted rules must be copied locally. It distinguishes rolling ledgers, archive terminals, maintained references and generated projections. Its stop conditions include “a lifecycle choice would change what users can directly browse” and migrations crossing task-tree owners. The proposal below therefore requires an explicit decision before those migrations begin.

## Why a mechanical split is insufficient

The actual pressure diagnostic is retained in `docs/checkpoints/document-pressure-restoration/pressure-before-intake.json.gz`. It reports independent file-count, per-file, aggregate and freshness failures. Existing history segments are immutable; current task identities, accurate facts and public documentation cannot be discarded to make a counter green. Partitioning the TYPE tree alone would not reduce aggregate task bytes, and rotating another history shard would increase archive file count.

## Recommended contract and concrete work

| Surface | Proposed representation | Controls retained or added |
| --- | --- | --- |
| `change_history`, `engineering_notes` | Keep the current hot shards; classify sealed exact history as a declared query archive. Retain original segment bytes and stable segment IDs. Page the machine catalog under its existing root bounds. | Keep hot 512-line/65,536-byte caps and existing per-segment bounds. Replace lifetime archive file/aggregate caps with strict immutable source identity, complete ordered catalog, exact reconstruction and corruption/missing-segment rejection. Keep `tools/read_document_history.pl` query/segment/all interfaces. |
| `task_evidence` | Keep the complete current node graph and all active/pending requirements. Move only explicitly classified completed narrative/checklist history into bounded, linked, immutable source archives. | Keep every stable ID, status, goal, acceptance and current frontier addressable. Keep existing live task file/collection caps. Bind the predecessor Git blob, removed byte ranges and exact full-detail retrieval; reject lost/duplicated nodes and archival drift. Refresh mutable partition snapshots. Migrate one task owner per commit. |
| `knowledge_cards`, `decisions`, `public_reference` | Keep maintained canonical files directly browsable. Adopt the guide's maintained-reference exception with a complete, fresh, task-bound scope ledger. Consolidate proven duplicates only after comparing their richer canonical source. | Retain existing per-file limits, unique IDs, complete indexes and question routing. Replace decorative lifetime aggregate/file-count caps with exact scope admission: every member/content change is declared, source-owned and reviewed in its leaf; unknown/unindexed growth fails. No blanket numerical cap increase. |
| `knowledge_map` | Compact duplicated metadata while retaining every question, canonical home, fact ID, title, date/status, evidence and reverify value. Publish through validated same-directory staging and atomic replacement. | Keep existing 22,500-line/8,388,608-byte ceilings; prove exact question/home and metadata preservation. Interrupted rendering preserves the old complete map. Owner `.20.1.1`. |
| `diagnostics` and other maintained manual pages | Reflow prose and remove only proved duplicate explanation, retaining examples, anchors and technical meaning. | Preserve direct mdBook browsing and existing per-page caps; render and compare the changed material. No feature or language contract changes. |
| claim verifier | Reuse immutable Git blobs and owner snapshots without weakening validation. | Preserve all-record checks, strict schemas, hash validation, gap-owner status/uniqueness and staged-snapshot safety; use distinguishing stale-snapshot/owner-drift controls. Owner `.20.1.2`. |

This deliberately replaces lifetime aggregate constraints for declared immutable archives and legitimately growing maintained references. It does **not** raise their numbers to match current excess, grant unreviewed growth, change README/MEMORY budgets, or treat current excess as a healthy baseline. The exact old/new contract objects belong in newly accepted indexed ADRs and must be tested by the routing-governance negatives before activation.

## Alternative if existing aggregate contracts must remain

Keep all current aggregate/file-count caps and use only semantic consolidation and lossless, indexed historical extraction. This requires reviewing each affected canonical unit and its consumers; no representation is accepted until it demonstrably fits without losing unique information or leaving broken references. If unique current scope cannot fit, return with a measured contract-expansion decision rather than delete or silently widen. This alternative does not authorize guessing which facts are disposable.

## Ordered slices

1. `.20.1.3`: commit this reviewable proposal and retained diagnosis; record the director's decision. No migration yet.
2. `.20.1.1`: independently repair atomic Knowledge publication and bounded generated formatting; preserve all query/metadata values.
3. `.20.1.2`: repair claim-verifier repeated reads with snapshot/negative proof.
4. `.20.1.4`: migrate the two ledger catalogs/archive roles, one family per atomic child.
5. `.20.1.5`: extract completed task narrative, one registered task owner per atomic child, with exact source reconstruction and current graph preservation.
6. `.20.1.6`: implement the chosen Knowledge/ADR maintained-scope or consolidation policy, with complete question/index/consumer proof.
7. `.20.1.7`: reconcile maintained manual duplication/reflow under the chosen policy and render it.
8. `.20.1.8`: require all normal hook doctrines to pass, then canonical CI for the exact staged candidate; close pressure20.1 and E2BIG23.4.5 only after verified acceptance. Restore ordinary hook-enabled commits before resuming Rust73.2.

Each migration is separately owned, preserves exact source inputs/results, updates its readers and mechanical checks together, and commits before another family begins. Runtime features, other repositories and dependency internals remain outside these slices. No migration, numerical limit change, accepted ADR or normal-hook restoration is claimed by this proposal.

## Accepted execution boundary

The director explicitly selected “Adopt the proposed archive/reference contracts (recommended)”. The original feature-only no-verify permission is not an infrastructure exception. Because existing independent gate failures block partial infrastructure commits,20.1.10 integrates the interdependent contract/readers/checkers/data changes into one restoration candidate. Component evidence and preservation boundaries remain separate. Normal hooks and exact staged canonical CI must pass before its commit; no bypass, temporary pressure waiver or healthy-baseline relabeling is used. Subsequent work returns to ordinary per-slice commits.
