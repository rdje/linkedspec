---
id: mutation-public-surface-no-drift
title: "Current mutation teaching is bound to frozen semantics by one recurring public checker"
answers:
  - "which public documents teach write vivification and map_leaves bang"
  - "how is mutation public no drift checked"
  - "what prevents stale non-vivifying mutation claims"
  - "which mutation examples must the public guide contain"
  - "does mutation public closeout rewrite the frozen authorities"
  - "how many mutation public documents and mutations are governed"
date: 2026-09-20
status: current; public no-drift and parent FUTURE-PARITY-BACKLOG.19 closed under .19.9
tags: [documentation, mutation, autovivification, map-leaves, governance, no-drift, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.9 adds tools/check_mutation_public_surface.py and current examples without changing production or frozen contract bytes. The checker inventories 63 public Markdown files; requires exact current anchors in 14 mutation-owning documents; binds eleven example classes to exact write, map_leaves bang, and composition policy strings; rejects ten stale current claims; and rejects 50 isolated authority/document/status mutations. Canonical CI tracks and runs it unconditionally, while tools/check_capability_conformance.pl pins its .19.9 owner and exact-one registration through four additional mutations."
reverify: "bash tools/run_python_project_data.sh tools/check_mutation_public_surface.py && perl tools/check_capability_conformance.pl"
---

# Mutation public-surface no-drift

The canonical teaching destination is `docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md`.
Fourteen current public documents own exact mutation status or semantics; the checker inventories those documents
within a bounded 69-file public Markdown surface and fails when a new public file appears without explicit review.

The required examples cover missing-container creation, dense arrays, existing-kind conflicts, segment/RHS
evaluation order, original-shape traversal, callback fields, receiver-identity guarding, rollback, detached
results, callback-local nested-write composition, and post-commit continuation. Historical task, decision,
Knowledge, and history records are deliberately outside the stale-current scan.

The public checker reads exact policy strings from [[write-vivification-neutral-contract]],
[[map-leaves-mutation-neutral-contract]], and [[write-map-leaves-neutral-composition]]. It does not alter those
frozen authorities or replace the exact six-runtime behavior proof in [[mutation-recurring-six-runtime-gate]].

## September 13 integration-guide inventory update

`BACKEND-INTEGRATION-GUIDES.2.1` adds exactly one public Markdown file:
`docs/linkedspec-book/src/public-api/integration-rust.md`. The canonical gate and
focused checker both reproduce expected63/observed64. Its `public_markdown_paths`
function includes every book Markdown file; `validate_public_sources` rejects the
old count at `tools/check_mutation_public_surface.py:257`. The reviewed update
changes only `EXPECTED_PUBLIC_FILE_COUNT` from63 to64 and current census references.
The original .19.9 evidence above remains a dated63-file result. All three frozen
JSON authorities remain byte-exact; the fourteen governed documents, eleven
example classes, ten stale-claim denials and fifty mutation cases are unchanged.
Reverify with the existing command above. This inventory maintenance gives no
additional startup source-reading credit.

## September 14 Perl integration-page review

`BACKEND-INTEGRATION-GUIDES.1.1` adds only the new Perl integration
chapter to public discovery. Preflight reproduces mutation expected64/observed65
and selector expected63/observed64. The reviewed correction changes only each
checker's expected file count and current census references. The selector's35
classified references, zero current examples and11 contrast mutations remain;
mutation's14 governed documents,11 example classes,10 denials and50 mutations
remain. Earlier dated evidence is preserved. Reverify with the existing command.

## September 19 Dart integration-page review

`BACKEND-INTEGRATION-GUIDES.3.1` adds the native Dart integration chapter.
Preflight reproduces mutation expected65/observed66 and selector expected64/observed65.
Only the two expected file counts and current census references advance. All
classifier logic, frozen authorities,35 selector references,zero current examples,
11 contrast mutations and mutation14/11/10/50 semantic checks remain unchanged.
Earlier dated evidence stays intact; reverify with the existing command.

## September 20 Julia integration-page review

`BACKEND-INTEGRATION-GUIDES.4.1` adds the native Julia integration chapter.
Preflight reproduces mutation expected66/observed67 and selector expected65/observed66.
Only the two expected file counts and current census references advance. Classifier
logic, frozen authorities,35 selector references,zero current examples,11 contrast
mutations and mutation14/11/10/50 checks remain unchanged. Earlier evidence stays
intact; reverify with the existing command.

## September 20 Lua integration-page review

`BACKEND-INTEGRATION-GUIDES.5.1` adds the native Lua integration chapter.
Preflight reproduces mutation expected67/observed68 and selector expected66/observed67.
Only the two expected file counts and current census references advance. Classifier
logic, frozen authorities,35 selector references,zero current examples,11 contrast
mutations and mutation14/11/10/50 checks remain unchanged. Earlier evidence stays
intact; reverify with the existing command.

## September20 common integration-entry review

Integration .6 adds the common entry and backend navigation. The original guards
reject expected68/observed69 and expected67/observed68. Count-only updates admit
the one page; mutation69/14/11/10/50 and selector68/35/0/5/11 pass. Classifiers,
semantic examples and frozen authorities remain unchanged. Canonical staged
proof governs landing; prior dated results above retain their original counts.
