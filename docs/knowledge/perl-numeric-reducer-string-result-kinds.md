---
id: perl-numeric-reducer-string-result-kinds
title: Perl min max and odd median retain numeric-string result kinds
answers:
  - "why does numeric array minimum return a string on Perl"
  - "why does odd median of capture groups return a quoted number"
  - "does is_deeply distinguish Perl numeric strings from JSON numbers"
  - "which task fixes numeric reducer result kinds"
date: 2026-09-26
status: confirmed defect; required repair SESSION-STARTUP-READING.95 after .93/.92/.94 before .51
tags: [perl, numeric, arrays, captures, serialization, mdbook]
evidence: "Eight exact/reconstructed helper-catalog examples through Get yield five exact matches and three JSON-kind mismatches: array min [1] versus [\"1\"], max [8] versus [\"8\"], odd median [3] versus [\"3\"]. Exact source/value evidence is docs/checkpoints/SESSION-STARTUP-READING.95-numeric-result-kinds.json."
reverify: "Replay checkpoint sources with LinkedSpec::Get/runtime_ctx_ref under tools/project_data_run.sh and compare canonical JSON bytes, not only Test::More scalar equality."
---

`MethodLowering.pm` array min/max compare terms but return a selected original
term. Odd median numerically sorts a copy and returns its selected term too.
When inputs are numeric strings (including regex capture groups), the result
retains string kind. Arithmetic sum/average/range and even median yield numbers;
the separate scalar min/max helpers already use the numeric contract adapter.

This predates `.91`; that value-composition repair does not change arithmetic
algorithms. Its numeric-string `is_deeply` controls prove scalar value equality,
not JSON number/string tags. The catalog's prior unquoted array min/max/median
outputs were inaccurate for Perl and are now explicitly labeled with observed
quoted values. The desired numeric-result repair remains mandatory under `.95`,
including strict JSON tests and a bounded audit of the aggregate authority and
other backend contracts before deciding whether canonical verification is needed.
