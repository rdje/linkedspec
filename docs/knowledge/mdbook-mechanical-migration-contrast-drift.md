---
id: mdbook-mechanical-migration-contrast-drift
title: Mechanical aggregate-selector migration erased old-to-new contrast in mdBook examples
answers:
  - "why do mdBook migration examples say items becomes items"
  - "which commit corrupted aggregate selector migration examples"
  - "does the aggregate selector documentation checker verify migration meaning"
  - "where is the mdBook semantic drift repair tracked"
date: 2026-07-21
status: resolved by FUTURE-PARITY-BACKLOG.23.1 on 2026-08-30
tags: [mdbook, documentation, migration, aggregate-selector, no-drift, defect]
evidence: git commit ac217f6c; docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md; tools/check_public_aggregate_selector_surface.py; docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md leaf .23.1
reverify: "git show --stat --oneline ac217f6c; bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

Full-book startup review found migration prose whose old and new forms are now identical, including statements
equivalent to “`items` becomes `items`.” `git show ac217f6c` establishes the cause: the aggregate-selector rename
was applied mechanically inside historical/migration examples as well as current syntax, erasing the examples'
old-to-new contrast rather than merely updating a current spelling.

`tools/check_public_aggregate_selector_surface.py` originally did not catch the defect because it guarded
occurrence counts, required anchors, and retired current spellings, but did not encode the semantic relationship
between an example's old form and replacement form. This was a documentation contract gap, not parser/runtime
behavior.

`FUTURE-PARITY-BACKLOG.23.1` recovers seven exact historical forms from the parent of `ac217f6c`: two rejected
source examples and five ordered old-selector-to-bare-binding mappings. The public checker now bounds that one
migration section, requires its exact examples, verifies old and new sides are semantically distinct, and rejects
eleven collapse/omission/replacement/reorder mutations. It passes at 61 public files / 32 classified historical
references / zero current examples while the executable scanner remains zero-positive. `.23.2` still owns the
separate current-facing rollout audit and stale-claim guards.
