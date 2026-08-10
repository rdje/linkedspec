---
id: recognition-transaction-book-sequence-drift
title: Rendered review caught a stale neutral-next sentence after the transaction authority became executable
answers:
  - "why did the transaction book say the neutral artifact was next after it was executable"
  - "what caught the stale recognition transaction milestone sequence"
  - "does the neutral transaction checker govern public milestone ordering"
  - "who owns recognition transaction public sequence enforcement"
date: 2026-08-10
status: prose corrected; fail-closed public-sequence guard pending under FUTURE-PARITY-BACKLOG.14.3.1.2.0
tags: [transactions, documentation, mdbook, drift, governance, rendering]
evidence: "FUTURE-PARITY-BACKLOG.14.3.1.2 rendered the capture/source page and found adjacent claims that the neutral authority was executable and still next. Git blame traced the old sentence to 7c2ff407 and the missed update to e0cc7182; the existing checker governs artifact policy but no public milestone-sequence projection."
reverify: "bash tools/run_mdbook_local.sh && rg -n 'neutral artifact/checker is executable|neutral artifact/checker is next' docs/linkedspec-book/book/dsl/capture-marks-and-source-locations.html && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

`FUTURE-PARITY-BACKLOG.14.3.1.0` commit `7c2ff407` correctly taught that the neutral artifact/checker was the next
milestone before the authority existed. Implementation commit `e0cc7182` later inserted an executable-authority
paragraph and checker command but left the older sequencing sentence in place. The rendered page consequently
made two contradictory milestone claims within three paragraphs even though each individual statement originated
from a truthful slice.

The recognition-transaction checker could not catch this drift because its `current_boundary` assertion governs
the neutral JSON policy and prevents false current-runtime/public-capability claims; it does not scan the mdBook
for stale milestone-order prose. Rendered review in `.14.3.1.2` exposed the contradiction. That leaf corrects only
the sentence to say the neutral authority is executable while every runtime remains pending.

Fail-closed prevention is intentionally separate: `FUTURE-PARITY-BACKLOG.14.3.1.2.0` owns a governed public
milestone-sequence projection and mutation proof before Perl RED begins. Keeping that guard separate preserves
`.14.3.1.2` as a narrow public-boundary repair and avoids silently changing the neutral artifact's 40-mutation
semantic contract during recomposition.
