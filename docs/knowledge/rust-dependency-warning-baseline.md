---
id: rust-dependency-warning-baseline
title: Dependency warning output is upstream-owned black-box evidence
answers:
  - why does canonical Rust compilation print thousands of warnings
  - how many warnings does pgen currently emit
  - which task owns Rust dependency warning reports
  - may LinkedSpec patch RGX or PGEN warning causes
  - what git boundary owns rgx and pgen warning fixes
date: 2026-09-20
status: observable baseline retained; upstream implementation investigation and edits forbidden
tags: [rust, dependencies, warnings, public-contract, task-tree]
evidence: "Repeated completed canonical build logs report 1870 pgen and26 rgx-core warnings. September20 director boundary restricts LinkedSpec to published dependency interfaces and upstream reports."
reverify: "Observe ordinary documented build output when a build is otherwise warranted; retain exact command, versions and exit status. Do not inspect dependency source or run source-changing repair tools."
---

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX owns PGEN and all transitive preparation; no separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec. Reports go to RGX.

Completed Rust builds repeatedly reported 1,870 warnings for `pgen` and 26 for
`rgx-core`. These are output counts for those runs, not a proven count of distinct
bugs or a causal explanation. Do not suppress the warnings to claim a clean build.

`RUST-DEPENDENCY-WARNING-ZERO` retains ownership of the desired warning-clean
outcome. For RGX/PGEN, its work is limited to public-interface reproduction,
upstream reports and evaluation of upstream-published results. It does not permit
reading dependency implementation, applying fixes, reconstructing generators or
changing pins. LinkedSpec-owned code can be repaired in its own task-owned slices.

Published contracts and observable command results are the integration authority.
Implementation-derived dependency plans and conclusions have been removed.
Related: [[rust-ci-pgen-missing-input-rebuilds]], [[verification-cadence-policy]].
