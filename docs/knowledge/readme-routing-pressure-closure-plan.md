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
status: accepted plan; implementation pending
tags: [readme, documentation, routing, pressure, lifecycle, doctrine, containment, debt]
evidence: "README-STABILITY-POLICY.4.0 reads the supplied 185-line policy revision, compares it to LinkedSpec's 88-line policy and ADR 0063, derives 62 planned routes over 20 surfaces, and freezes a strict JSONL registry plus dependency-free checker and 32 mutation classes. Clean 7c2ff407 measurements identify debt at LIVE_ACHIEVEMENT_STATUS.md 14,769/1,262,969, docs/tasks 85 files/64,378/6,204,304 with FUTURE-PARITY-BACKLOG 26,979/2,720,175, CHANGES 44,128/3,091,199, and DEVELOPMENT_NOTES 21,169/2,277,541. Baselines are immutable; only finite named transition owners may grow debt. README-STABILITY-POLICY.4.1 owns registry/checker adoption, .4.2 unchanged closeout, and LIVE-DOCUMENT-PRESSURE-CONTAINMENT owns subsequent bounded-view migrations."
last_verified: 2026-08-09
reverify:
  - "wc -l -c README.md README_POLICY.md LIVE_ACHIEVEMENT_STATUS.md CHANGES.md DEVELOPMENT_NOTES.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
  - "rg --files docs/tasks -g '*.md' | sort | xargs wc -lc"
  - "rg -n 'README-STABILITY-POLICY\\.4|LIVE-DOCUMENT-PRESSURE-CONTAINMENT' docs/tasks/README-STABILITY-POLICY.md docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md docs/TASK_TREE.md"
---

# README routing-pressure closure plan

A bounded landing page is not sufficient when its routing advice can grow an unchecked neighboring document.
LinkedSpec's revision classifies direct reader navigation separately from author-overflow guidance, declares every
actual route in `doctrine/readme_stability/routes.jsonl`, and requires transitive closure at a lifecycle-appropriate
controlled terminal. The registry and checker are planned in `.4.0` and remain non-executable until `.4.1`.

Bounded snapshots use independent line/byte limits and current-state semantics; collections use an index plus
per-part, file-count, and aggregate limits; generated views retain freshness checks; append histories are query-
first with rollover; external services have named HTTPS authority; frozen records require identity. Repository
components used only for reader navigation need exact root-relative existence but are not prose overflow sinks.

Current large measurements are immutable debt baselines, not recommended values. Debt may consume only a finite
transition owned by README `.4` or its exact containment leaf; ordinary work cannot refresh the baseline merely by
changing the registry. Subsequent semantic migrations belong to `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`.
