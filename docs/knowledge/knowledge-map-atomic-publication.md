---
id: knowledge-map-atomic-publication
title: Knowledge generation preserves complete live output across handled failures
answers:
  - "can Knowledge Map readers observe partial rendering"
  - "does failed Knowledge generation preserve the old map"
  - "how is Knowledge Map output published atomically"
  - "which control checks interrupted Knowledge publication"
date: 2026-11-01
status: implemented with focused controls; canonical closure pending pressure20.1.8
tags: [knowledge-map, generation, atomicity, interruption, publication]
evidence: "TYPE-REFERENCE-BOOK.1.2.20.1.1; docs/checkpoints/document-pressure-restoration/knowledge-map-atomic-intake.json.gz retains original/repaired producers and actual public-control inputs/outputs."
reverify: "bash tools/run_python_project_data.sh tools/test_knowledge_map_atomic_output.py; bash tools/project_data_run.sh env PERL5LIB= prove t/knowledge_map_header_lists.t"
---

The public generator originally redirected its renderer block directly to
`KM_OUTPUT`. A deterministic final-renderer barrier observes incomplete live
bytes; rendering errors, handled termination and rejected completed output can
leave the prior map replaced by partial/unaccepted bytes.

The repaired generator renders to a unique validated sibling. It retains the
existing destination permissions, validates completed output and its destination,
then renames atomically. EXIT/handled-signal cleanup removes the owned staging
file. Replacement readers see a complete old/new map; failed first publication
leaves no destination. Symlink protection remains. This is handled-failure proof,
not a claim that uncatchable process death executes cleanup.

Six actual public-generator controls change from five failed groups/one healthy
symlink group to all passing; the existing metadata/header regression passes.
Before adding this fact, the complete derived projection remains byte-identical
under unchanged inputs. Renderer/extraction/formatting changes are independently
owned by20.1.9. Full canonical/normal-hook closure remains20.1.8.
