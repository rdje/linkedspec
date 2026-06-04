---
id: hosted-ci-disabled-run-local-gate
title: Hosted GitHub Actions CI is disabled; run the local gate tools/run_ci_local.sh
answers:
  - "is GitHub Actions CI running for linkedspec"
  - "how do I run CI / the regression gate"
  - "why is .github/workflows/ci.yml guarded off (workflow_dispatch / if false)"
  - "what does green CI mean here"
  - "where does the memory-arch and knowledge-map check run"
date: 2026-06-05
status: current
tags: [ci, environment]
evidence: ".github/workflows/ci.yml uses workflow_dispatch + job if: false; docs/decisions/0004-hosted-ci-disabled-local-gate.md"
reverify: "grep -n 'workflow_dispatch' .github/workflows/ci.yml"
---

Hosted GitHub Actions CI is intentionally **off** (to preserve account Actions minutes):
`.github/workflows/ci.yml` is `workflow_dispatch`-only with the job guarded `if: ${{ false }}`.
The canonical gate is `bash tools/run_ci_local.sh`, which runs (in order) the
memory-architecture self-check, the Knowledge Map check, `perl -c`, and the phase-0
regression suite. "Green CI" = that script exits 0 locally — not a hosted run. Do not
re-enable the hosted workflow without an explicit decision superseding the record.
Canonical home: `docs/decisions/0004-hosted-ci-disabled-local-gate.md`, `README.md` (Local CI).
