---
id: aggregate-selector-retirement-no-drift
title: "One canonical checker prevents aggregate-selector compatibility from returning"
answers:
  - "how is aggregate selector retirement enforced across all backends"
  - "which checker prevents selector runtime compatibility from returning"
  - "do all five backends consume the six invalid selector cases"
  - "what locks aggregate selector diagnostic fields and compile boundaries"
date: 2026-07-12
status: current
tags: [language, bindings, retirement, no-drift, perl, rust, dart, julia, lua]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.6 adds tools/check_aggregate_selector_retirement.py to canonical local CI. It requires Perl, Rust, Dart, Julia, and Lua focused suites to consume all six invalid_selector_cases and portable code/surface/identifier/replacement fields from linkedspec-uniform-binding-v1; requires each backend's compiled-state validation boundaries and eight retained constructor/literal classes; forbids known selector-only runtime symbols/patterns; and composes the executable-source scanner. On 2026-07-12 it reported five backends, six invalid selectors, eight retained classes, zero runtime compatibility, zero executable positives, and 19 classified rejection occurrences. Focused proof passed Perl 11, Rust 15/15, Dart 15/15, Julia 59/59, and Lua 88/88 on both PUC Lua and LuaJIT."
reverify: "python3 tools/check_aggregate_selector_retirement.py"
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

Related facts: [[spec-facing-aggregate-selector-retirement-inventory]],
[[uniform-binding-neutral-contract]], [[perl-aggregate-selector-compile-rejection]],
[[rust-aggregate-selector-compile-rejection]], [[dart-aggregate-selector-compile-rejection]],
[[julia-aggregate-selector-compile-rejection]], [[lua-aggregate-selector-compile-rejection]].
