---
id: readme-routing-pressure-closure-plan
title: README routes must terminate at classified pressure-controlled destinations
answers:
  - what routing pressure gap does the README policy revision close
  - why is bounding README alone insufficient
  - how are README reader routes different from author overflow routes
  - where will LinkedSpec declare README routed destinations
  - which README route surfaces are measured debt
  - how are README destination limits governed
  - what task owns live document pressure containment
  - may a routed destination baseline refresh automatically
  - what implements README route closure
date: 2026-08-09
status: implemented; canonical signoff complete
tags: [readme, documentation, routing, pressure, lifecycle, doctrine, containment, debt]
evidence: "README-STABILITY-POLICY.4.0 reads the supplied 185-line policy revision and freezes 62 routes over 20 surfaces plus 32 mutation classes. Implementation .4.1 adds the 83-line strict JSONL registry and a core-Perl resulting-tree checker; focused report passes 44 reader + 18 author routes, all 20 measured/classified surfaces, and 32/32 mutations. README remains 105 lines and shrinks 5,072->5,057 bytes after removing only stale test_input/. Clean 7c2ff407 debt baselines remain immutable; finite README .4 or LIVE-DOCUMENT-PRESSURE-CONTAINMENT owners alone may grow them. Canonical signoff exits 0 through CLI 66x2 and Phase 0 1,031/1,031 in 694 seconds."
last_verified: 2026-08-09
reverify:
  - "wc -l -c README.md README_POLICY.md LIVE_ACHIEVEMENT_STATUS.md CHANGES.md DEVELOPMENT_NOTES.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
  - "rg --files docs/tasks -g '*.md' | sort | xargs wc -lc"
  - "rg -n 'README-STABILITY-POLICY\\.4|LIVE-DOCUMENT-PRESSURE-CONTAINMENT' docs/tasks/README-STABILITY-POLICY.md docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md docs/TASK_TREE.md"
  - "perl scripts/check_readme_routing_pressure.pl --report"
---

# README routing-pressure closure plan

A bounded landing page is not sufficient when its routing advice can grow an unchecked neighboring document.
LinkedSpec's revision classifies direct reader navigation separately from author-overflow guidance, declares every
actual route in `doctrine/readme_stability/routes.jsonl`, and requires transitive closure at a lifecycle-appropriate
controlled terminal. `.4.0` ratified the data model; `.4.1` implements it and the unconditional core-Perl checker.

Bounded snapshots use independent line/byte limits and current-state semantics; collections use an index plus
per-part, file-count, and aggregate limits; generated views retain freshness checks; append histories are query-
first with rollover; external services have named HTTPS authority; frozen records require identity. Repository
components used only for reader navigation need exact root-relative existence but are not prose overflow sinks.

Current large measurements are immutable debt baselines, not recommended values. Debt may consume only a finite
transition owned by README `.4` or its exact containment leaf; ordinary work cannot refresh the baseline merely by
changing the registry. Subsequent semantic migrations belong to `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`.

The checker reads the staged resulting tree whenever an index change exists and otherwise reads the worktree. It
rejects a controlled staged/worktree split, derives all 39 README routes, five local-enforcement routes, 18 policy
overflow routes, and 18 emitted hints independently, then requires exact registry equality. Its `--report` mode
exposes deterministic per-surface counts without writing an artifact.
