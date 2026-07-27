---
id: mdbook-mechanical-migration-contrast-drift
title: Mechanical aggregate-selector migration erased old-to-new contrast in mdBook examples
answers:
  - "why do mdBook migration examples say items becomes items"
  - "which commit corrupted aggregate selector migration examples"
  - "does the aggregate selector documentation checker verify migration meaning"
  - "where is the mdBook semantic drift repair tracked"
date: 2026-07-21
status: current defect; repair and semantic no-drift guard pending under FUTURE-PARITY-BACKLOG.23
tags: [mdbook, documentation, migration, aggregate-selector, no-drift, defect]
evidence: git commit ac217f6c; docs/linkedspec-book/src; tools/check_public_aggregate_selector_surface.py; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .23
reverify: "git show --stat --oneline ac217f6c; rg -n 'items.*items|rows.*rows|result.*result' docs/linkedspec-book/src; bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

Full-book startup review found migration prose whose old and new forms are now identical, including statements
equivalent to “`items` becomes `items`.” `git show ac217f6c` establishes the cause: the aggregate-selector rename
was applied mechanically inside historical/migration examples as well as current syntax, erasing the examples'
old-to-new contrast rather than merely updating a current spelling.

`tools/check_public_aggregate_selector_surface.py` did not catch the defect because it guards occurrence counts,
required anchors, and retired current spellings, but does not encode the semantic relationship between an example's
old form and replacement form. This is a documentation contract gap, not parser/runtime behavior.

Pending `FUTURE-PARITY-BACKLOG.23.1` owns the collapsed-example audit, factual repair, and a semantic guard that
must fail when migration sides collapse to the same spelling. `.23.2` owns the remaining current-facing rollout
audit and stale-claim guards. The active Rust semantic leaf does not opportunistically repair those examples because the
task-tree pivot doctrine requires finishing and committing the current dirty leaf first.
