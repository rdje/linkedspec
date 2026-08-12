---
id: recursive-observation-public-no-drift
title: Recursive observation public projection closes without a new rollout row
answers:
  - "is recursive observation public no-drift current"
  - "does recursive observation have a public API"
  - "why did recursive observation public closeout not add a rollout row"
  - "is recurring_public_no_drift complete after recursive observation public closeout"
  - "how many typed source rollout rows exist after recursive observation public closeout"
  - "how many typed source mutations exist after recursive observation public closeout"
  - "which documents govern recursive observation public projection"
  - "which recursive observation public surfaces are guarded"
  - "what did FUTURE-PARITY-BACKLOG.14.4.8 close"
date: 2026-08-12
status: current public projection/no-drift; no public API admission; combined FUTURE-PARITY-BACKLOG.14.8 row pending
tags: [source-location, recursion, observation, public-no-drift, documentation, rollout, api-boundary]
evidence: "FUTURE-PARITY-BACKLOG.14.4.8 adds an independent recursive_observation_public_no_drift section to the typed-source contract. It requires six current projections, rejects six exact stale claims, and scans ten public/API/schema surfaces for five private observation tokens. Nine contract mutations plus eighteen in-memory document/surface mutations advance typed-source governance from 87 to 114. The accepted 14-row rollout remains 9 complete / 5 pending: recursive_observation stays complete under .14.4, while recurring_public_no_drift stays pending for final program-wide .14.8. The exact five-source/six-runtime recurrence and support ledgers recompose unchanged. No parser, compiler, runtime, storage root, public helper, authored Position/Span value, facade export, descriptor/generated or result schema, semantic/MCP field, CLI option, or README behavior moves."
last_verified: 2026-08-12
reverify:
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/check_recursive_observation_six_runtime.sh"
  - "bash scripts/check_readme_stability.sh"
  - "LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1 bash tools/run_ci_local.sh"
---

# Recursive-observation public no-drift

This closeout governs what the public documentation says and proves which public surfaces did not widen. It does
not export the private observation node or its detached carrier. Authors may use the grammar-owned
`observe_recognition(observation, call(Child))` form on all six admitted runtimes, but there is no separately
exported observation helper, `Position`/`Span` authored value, facade type, schema field, semantic/MCP response,
CLI option, or README promise.

The public checker owns six projections: the source-location chapter, backend handoff, project status, local-CI
guide, capability guide, and Toolbox. It requires one exact current marker in each and rejects six earlier
milestone claims. Ten surface guards cover the five public facades, outward descriptor contract, semantic model,
MCP schema, CLI manifest, and bounded root README.

This proof is intentionally independent of the rollout ledger. The original accepted contract has fourteen rows,
not fifteen. Recursive observation became complete when `.14.4.7` established recurrence; `.14.4.8` closes that
activity's public projection without consuming the final combined `recurring_public_no_drift` row owned by
`.14.8`. Current truth therefore remains 9 complete / 5 pending while governance advances to 114 mutations.

Definitive canonical evidence passes all eight doctrines, repository containment and relocation, CLI 66/66 in
both option environments, RAM 57%, Phase 0 1,031/1,031 in 713 seconds, and the full opt-in observation matrix
through exact local-CI success and exit 0. The first fully staged sandboxed run reached representative containment
before the outer harness denied nested `sandbox-exec`; the unchanged permission-authorized run is authoritative.

Related: [[recursive-observation-recurring-gate]], [[recursive-source-observation-audit]], and
[[typed-source-location-runtime-rollout-plan]].
