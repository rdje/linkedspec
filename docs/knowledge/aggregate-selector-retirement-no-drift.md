---
id: aggregate-selector-retirement-no-drift
title: "One canonical checker prevents aggregate-selector compatibility from returning"
answers:
  - "how is aggregate selector retirement enforced across all backends"
  - "which checker prevents selector runtime compatibility from returning"
  - "do all five backends consume the six invalid selector cases"
  - "what locks aggregate selector diagnostic fields and compile boundaries"
  - "is aggregate selector public documentation admitted"
  - "are backend READMEs checked for removed aggregate selector examples"
date: 2026-07-12
status: current
tags: [language, bindings, retirement, no-drift, perl, rust, dart, julia, lua]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.6 adds tools/check_aggregate_selector_retirement.py. It requires Perl, Rust, Dart, Julia, and Lua focused suites to consume all six invalid_selector_cases and portable code/surface/identifier/replacement fields from linkedspec-uniform-binding-v1; requires each backend's compiled-state validation boundaries and eight retained constructor/literal classes; forbids known selector-only runtime symbols/patterns; and composes the executable-source scanner. On 2026-07-12 it reported five backends, six invalid selectors, eight retained classes, zero runtime compatibility, zero executable positives, and 19 classified rejection occurrences. Final admission .12.1.9 composes this under tools/check_public_aggregate_selector_surface.py and removes the capability future exclusion. Follow-up .12.1.10 removes 14 missed Rust/Dart/Julia/Lua README positives and expands public proof to 56 root/component/mdBook files, 31 classified references, and zero current examples."
evidence_update_2026_07_12_lua_array_closeout: "The public inventory remains 56 files and zero current examples; its corrected classified count is 27 after four `array (statement)` formal-grammar prose false positives were removed. Runtime/source retirement counts are unchanged."
reverify: "python3 tools/check_public_aggregate_selector_surface.py"
---

# Aggregate-selector retirement no-drift

Exact `.spec` calls `array(IDENTIFIER)` and `hash(IDENTIFIER)` are removed language, not compatibility aliases.
Per-backend rejection tests are necessary but insufficient on their own: without one composed gate, a backend
could stop consuming the shared cases, lose one portable diagnostic field, move validation behind execution, or
reintroduce a selector-only runtime branch while its local happy-path tests remained green.

`tools/check_aggregate_selector_retirement.py` is the recurring cross-variant owner. It checks the neutral contract,
all five focused suites, the validation and generated/runtime admission anchors appropriate to each backend, all
eight retained constructor/literal classes, and a denylist of the selector-only runtime mechanisms removed by
`.12.1.8.1-.5`. It then runs `tools/check_executable_aggregate_selector_sources.py`, so public source admission and
runtime-deletion admission cannot drift apart.

The checker intentionally permits exact selector spellings only in neutral invalid fixtures, rejection logic,
diagnostics, and classified historical/documentation evidence. Generated Perl `$name`, `@name`, and `%name` are host
implementation details and are not spec-facing selector forms.

`tools/check_public_aggregate_selector_surface.py` also discovers every immediate component README and requires
bare-binding anchors in the Rust, Dart, Julia, and Lua documents. Its exact 56-file inventory prevents a backend
entry document from falling outside the public zero-current-example claim.

Related facts: [[spec-facing-aggregate-selector-retirement-inventory]],
[[aggregate-selector-public-admission]], [[uniform-binding-neutral-contract]],
[[perl-aggregate-selector-compile-rejection]],
[[rust-aggregate-selector-compile-rejection]], [[dart-aggregate-selector-compile-rejection]],
[[julia-aggregate-selector-compile-rejection]], [[lua-aggregate-selector-compile-rejection]].
