---
id: callable-mdbook-public-count-drift
title: The mdBook callable status says 24 while the governed inventory contains 25 documents
answers:
  - "how many callable codeblock public documents are governed"
  - "why does the mdBook callable status say 24 public documents"
  - "which task fixes the callable mdBook document count"
  - "why did the callable checker miss the stale public document count"
date: 2026-08-01
status: current sole-facing documentation defect; repair pending under FUTURE-PARITY-BACKLOG.24.0.2
tags: [mdbook, callable-codeblock, documentation-drift, public-contract, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.4 expanded the duplicate-independent callable public inventory from 24 to 25 by adding docs/linkedspec-book/src/appendix/helper-contract-catalog.md. Its checker and capability README require 25, but the newly added opening paragraph in docs/linkedspec-book/src/overview/project-status.md says 24. That page is inventoried only through other required markers, so the callable checker and successful 79-file render did not test the count. Git show 47b40c7a proves the stale number landed in the five-backend admission commit itself."
reverify: "rg -n '24 public documents|25 public documents|helper-contract-catalog|project-status' docs/linkedspec-book/src/overview/project-status.md capability_conformance/callable_codeblock_contract.json capability_conformance/README.md tools/check_callable_codeblock_contract.py && git show 47b40c7a:docs/linkedspec-book/src/overview/project-status.md | sed -n '1,10p'"
---

The actual governed callable public surface is 25 documents. The count mismatch changes no callable semantics,
backend result, route, or capability row, but it is user-visible factual drift because the mdBook is LinkedSpec's
sole-facing specification surface.

`FUTURE-PARITY-BACKLOG.24.0.2` owns the correction and the missing guard. It will change the mdBook count to 25,
make the callable checker require that exact marker on project status, add a path-scoped stale-24 denial/mutation,
and rebuild/review the complete book without touching runtime behavior.

Related: [[callable-codeblock-five-backend-admission]], [[capability-exclusion-freshness-model]].
