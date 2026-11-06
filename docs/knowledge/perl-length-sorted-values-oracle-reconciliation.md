---
id: perl-length-sorted-values-oracle-reconciliation
title: Fluent Length guards differ from the free sorted_values source fallback
answers:
  - "why does sorted_values scalar isolation fluent Length expect empty Array but get null"
  - "does Hash-view76 change fluent Length sorted_values policy"
  - "why do sorted_values length and Length receiver sorted_values differ"
date: 2026-11-06
status: obsolete fluent expectation corrected; same four-file67 focused rerun passes
tags: [perl, length, sorted_values, guards, oracle]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.76.1; hash-view-result-guard-perl-2026-11-06/direct retains first four-file67 failure. Actual same-path activation/implemented policy-control returns[null,[]] on both public native/fresh routes; actual emitted module/handler bytes are identical."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/sorted_values_scalar_isolation.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-view-result-guard-perl-2026-11-06/review.py"
---

The scalar-isolation fixture's fluent Length row still expected[] although the
existing74.1 actual-result guard rejects its produced Number before the Hash
consumer. Public same-path owner controls at clean684597174 and implemented76.1
both evaluate `["abc".length().sorted_values(),sorted_values(length("abc"))]`
to `[null,[]]`. Their actual emitted module and handler bytes are identical.
This mismatch exists at activation; no introduction date is inferred.

The common actual-kind guard checks `ref($__ls_selected_default) eq 'HASH'`
before the fluent consumer. The distinct free sorted_values producer retains
its evaluated nonreference empty-Array fallback. Length's Number producer and
the free Hash-view producer remain unchanged. This is the existing source/result
ownership distinction, not a universal new wrong-kind policy.

Correct exactly the fluent fixture expectation to null. Keep nested Length,
scalar/numeric/free/null/Hash/order/source-once/legacy binding expectations and
localized native/fresh host-Hash seeds. The failed direct epoch, unchanged original
fixture and original producer survive; direct-qualified is a separate producer
and proof epoch. Full feature admission, native/transitive custody and general
isolation remain separately owned.
