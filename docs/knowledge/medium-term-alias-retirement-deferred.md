---
id: medium-term-alias-retirement-deferred
title: Medium-term alias retirement (return_a, return_m, return_ma, return_imatch/return_im) is deferred; ~692 test references across complex Perl quoting contexts block automated migration
answers:
  - "why do return_a return_m return_ma return_imatch still exist"
  - "what happened with the medium-term alias retirement"
  - "are return_a return_m return_ma return_imatch deprecated"
  - "what is the test migration problem"
date: 2026-06-12
status: current
tags: [dsl, compat-aliases, deferred, testing]
evidence: "COMPAT-ALIAS-RETIREMENT.2/.3 deferred 2026-06-12; short-term aliases (tail/drop_last/flatten/array_values) successfully retired in .1"
reverify: "grep -c 'return_a(' t/phase0_regression.t"
---

The `COMPAT-ALIAS-RETIREMENT` task tree (2026-06-12) split alias retirement into two tiers:

**Short-term (done):** `tail`→`drop_front`, `drop_last`→`drop_back`, `flatten`→`flat`,
`array_values`→`array_copy`. Removed from 5 implementation files; tests and book updated;
1004 PASS. (~40 test references, no quoting conflicts.)

**Medium-term (deferred):** `return_a`, `return_m`, `return_ma`, `return_imatch`/`return_im`.
Infrastructure removal is technically correct (contracts, scanner rules, canonical event
mappings all removable), but the test file has ~692 `return_a(Label)` references that span
three Perl quoting contexts (`"..."`, `'...'`, `<<'SPEC'` heredocs). The canonical replacement
`return(array("?Label:", array_copy(array(Label))))` introduces `"` characters that break
double-quoted Perl strings. Three automated replacement strategies failed.

Future options: (a) context-aware Perl parser for the test file, (b) internal compatibility
redirects that keep aliases working but undocumented, (c) manual migration split across
multiple leaves.

Related: [[compat-alias-retirement-status]].
