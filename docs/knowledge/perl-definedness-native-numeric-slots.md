---
id: perl-definedness-native-numeric-slots
title: Perl definedness false preserves native numeric slots despite empty-text rendering
answers:
  - "why does is_defined undef add one return one on Perl"
  - "does empty JSON text prove a Perl definedness result is a String"
  - "does copying Perl definedness false preserve numeric behavior"
  - "why do native predicate false and typed false differ in Perl arithmetic"
  - "does is_undefined false preserve native numeric slots"
date: 2026-10-31
status: dated finite Perl5.34.1 capture; existing compatibility preserved
tags: [perl, definedness, numeric, scalar, copy]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.28.0; docs/claims/TYPE-REFERENCE-BOOK.1.2.23.1.28.0.json; docs/checkpoints/definedness-numeric-calibration/ retains the actual producer, all 147 captured inputs and native/fresh observations."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/definedness-numeric-calibration/review.py && bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/definedness_native_numeric_contract.t"
---

The captured Perl5.34.1 source epoch is
`d0174bb475fa6eabc02096713247e6605a1e1765`. Fifteen public programs produced
thirty native/fresh observations. Before serialization or numeric coercion,
false `is_defined` and `is_undefined` results, including copied false results,
exposed valid public integer, floating and string slots. Literal `""` exposed
only the public string slot. Both serialize as empty text, so JSON alone cannot
classify these host scalars. Recorded masks are derived from the observed host;
total/private flags remain diagnostics, not portable or cache invariants.

`LinkedSpec::Numeric::scalar_number` in `perl/LinkedSpec/Numeric.pm` rejects
references, accepts an existing native numeric slot before decimal-string
fallback, then checks finiteness. The captured predicate false therefore behaves
as numeric zero: nested `num_add(is_defined(undef),1)`, fluent
`is_defined(undef).add(1)` and copied forms return `1`. The inverse helper has
the same behavior. Literal `""` and the actual DSL Boolean `false` still produce
null in those arithmetic controls; Number `0` and decimal String `"0"` produce
`1`. Numeric inspection preserves the predicate's empty-text snapshot and its
`"!"` concatenation result. See also [[perl-logical-truthiness-host-scalars]].

This resolves an incorrect provisional expectation in selection28. Only its
authored `value_kinds.expected[2]` changes from null to `1`, in a separate
calibrated case epoch. The original cases and observations remain retained;
there is no product runtime RED or production repair. The permanent two-group
regression checks behavior, not machine-specific flag totals. The negative
JSON-kind hypothesis is observed RED (review exit1); capture verification exits0.
This is existing Perl compatibility, with no new cross-backend kind normalization
or claim about other Perl versions, all scalar domains or general host isolation.
