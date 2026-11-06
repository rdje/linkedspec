---
id: perl-key-count-typed-source
title: Perl CountKeys value blocks use typed argument ownership
answers:
  - "how are Perl CountKeys value-block sources lowered"
  - "why does a CountKeys source binding error occur during execution"
  - "does terminal receiver count_keys share the typed free-call source"
  - "must emitted Perl be regenerated after CountKeys typed-source repair"
date: 2026-11-06
status: P1 typed-source75.0.1 and domain75.0.2 focused-checked; guards75.1 pending
tags: [perl, count_keys, typed, block, source, errors]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.75.0.1; actual declared first inputs, complete raw channels and pre-run modules in docs/checkpoints/key-count-typed-source-2026-11-06. Unchanged9 groups5PASS4RED to9PASS, five healthy exact, four module changes, nearest28/syntax/five corruptions pass."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/key_count_block_source_composition.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/key-count-typed-source-2026-11-06/review.py"
---

CountKeys joins the existing contains/index_of/Count typed block-argument owner.
Canonical zero-extra/non-trailing terminal CountKeys block receivers delegate to
that same free call with original receiver/source span. Mutations/declarations
stay typed, so required binding_kind_mismatch errors execute after successful
loading rather than producing invalid Perl. Ordinary Count paths stay unchanged.

Unchanged nine native/fresh controls move5PASS4RED to9PASS. Five healthy complete
observations stay exact: already-working receiver/default error, source-once/
in-place Hash snapshot/order, pure Hash block, function parameter and malformed
receiver preflight. Exactly four originally failing module bodies change; new9/
Count block14/Count-length5=28 focused groups and owner syntax pass. Regenerate
emitted Perl; no parser/schema/free-signature/copy-depth change is claimed.

All runtime bytes outside the typed argument/terminal delegation clauses are
exact. Hash-kind/host-symbol producer logic and result guards are untouched.
The later domain75.0.2 repair is focused-checked in
[[perl-key-count-source-domain]]; main::2 consumer75.1 remains open:
[[key-count-source-and-guard-gaps]]. Actual declared inputs/new-normal modules
precede execution and recover byte/mode-exactly; full native/transitive custody4.2,
general isolation/discovery/full23.4 remain separate. Same-process fresh packages.
Historical recovery never claims latest-code freshness after later repairs.
