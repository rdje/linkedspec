---
id: dart-runtime-string-numeric-helpers
title: Dart runtime executes current string/scalar and numeric helper families
answers:
  - does Dart runtime support trim lowercase substr split
  - does Dart runtime support string receiver chains
  - does Dart runtime support numeric helpers
  - does Dart runtime support numeric aliases and symbol callees
  - does Dart runtime support number receiver chains
  - does Dart runtime support str_eq string comparisons
date: 2026-07-09
status: current
tags: [dart, runtime, helpers, string, numeric, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.3.2 extends dart/lib/src/runtime/interpreter.dart and test/runtime_interpreter_test.dart. Focused tests prove string/scalar helpers, explicit str_* lexical comparisons, numeric arithmetic/reducer/comparison helpers, numeric aliases, arithmetic/comparison symbol callees, and string/number receiver chains."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime string/scalar and numeric helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` canonicalizes helper names with
`canonicalActionHelperName(...)` before pure-helper dispatch, so current helper
aliases and symbol callees reuse the same runtime implementation path.

The string/scalar surface now includes `cat`, `trim`, `lowercase`,
`uppercase`, `length`, `matches`, `starts_with`, `ends_with`,
`contains_substr`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`,
`split`, `coalesce`, `coalesce_nonempty`, `is_defined`, `is_undefined`,
`is_empty`, `is_nonempty`, and the explicit lexical comparison helpers
`str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`. Compatible
string receiver chains such as `raw.trim().lowercase()` execute through the
same helper dispatcher.

The numeric surface now includes arithmetic, unary, reducer, clamp, and
comparison helpers, plus word aliases such as `add`, `avg`, and `gt`, and
symbol callees such as `+(...)`, `*(...)`, and `<=(...)`. Compatible number
receiver chains such as `17.mod(5)` and `3.5.round()` execute as first-argument
helper calls. Invalid numeric input or invalid arithmetic such as divide-by-zero
returns `null`.

`DART-BACKEND-PARITY.4.3.3` has since landed the broader array helper family,
array receiver chains, and array mutation behavior. Hash helper breadth remains
owned by `DART-BACKEND-PARITY.4.3.4`.

Related facts: [[dart-runtime-array-helpers]],
[[dart-runtime-core-value-capture-helpers]],
[[terse-string-scalar-receiver-chains]], [[terse-number-receiver-dot-value-chains]],
[[terse-numeric-comparison-symbol-callees]], [[terse-string-comparison-bridge]].
