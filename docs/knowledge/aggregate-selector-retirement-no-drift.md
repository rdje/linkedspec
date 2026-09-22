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
  - "does the aggregate selector source scanner inspect untracked files"
  - "why did the pre-staging aggregate selector scan miss a new test"
date: 2026-09-22
status: current
tags: [language, bindings, retirement, no-drift, perl, rust, dart, julia, lua]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.6 adds tools/check_aggregate_selector_retirement.py. It requires Perl, Rust, Dart, Julia, and Lua focused suites to consume all six invalid_selector_cases and portable code/surface/identifier/replacement fields from linkedspec-uniform-binding-v1; requires each backend's compiled-state validation boundaries and eight retained constructor/literal classes; forbids known selector-only runtime symbols/patterns; and composes the executable-source scanner. On 2026-07-12 it reported five backends, six invalid selectors, eight retained classes, zero runtime compatibility, zero executable positives, and 19 classified rejection occurrences. Final admission .12.1.9 composes this under tools/check_public_aggregate_selector_surface.py and removes the capability future exclusion. Follow-up .12.1.10 removes 14 missed Rust/Dart/Julia/Lua README positives and expands public proof to 56 root/component/mdBook files, 31 classified references, and zero current examples."
evidence_update_2026_07_12_lua_array_closeout: "The public inventory remains 56 files and zero current examples; its corrected classified count is 27 after four `array (statement)` formal-grammar prose false positives were removed. Runtime/source retirement counts are unchanged."
evidence_update_2026_07_15_structured_format_page: "The discovered public inventory is now 57 files after FUTURE-PARITY-BACKLOG.18.0 added one mdBook architecture page. The classified/current counts remain 27/0; LUA-BACKEND-PARITY.4.3.7.4 updates the stale exact expected count without weakening discovery or admission."
evidence_update_2026_07_15_native_loading_page: "The discovered public inventory is now 58 files after LUA-BACKEND-PARITY.5.2.1 added the native spec loading API page. Classified/current counts remain 27/0."
evidence_update_2026_07_20_semantic_introspection_page: "FUTURE-PARITY-BACKLOG.10.2 adds the semantic-introspection mdBook page. The public no-drift checker reviews it and advances the exact discovered inventory to 59 files while classified/current selector counts stay 27/0."
evidence_update_2026_07_22_untracked_discovery: "FUTURE-PARITY-BACKLOG.10.5.1.3.0 found that a new untracked Dart semantic test could embed a retired selector without appearing in the pre-staging git-ls-files scan. tools/check_executable_aggregate_selector_sources.py now enumerates cached plus nonignored untracked files and self-proves discovery/rejection with a temporary untracked source whose cleanup is guaranteed. The semantic compile-failure test loads the canonical neutral invalid case instead of duplicating retired executable source."
evidence_update_2026_07_29_readme_routing: "README-STABILITY-POLICY.1 keeps all 59 public files in discovery while removing two duplicate historical selector mentions from the bounded root landing page. The current classified/current counts become 25/0; runtime/source retirement, backend anchors, and untracked discovery remain unchanged."
evidence_update_2026_08_25_staged_ast_enrichment_page: "FUTURE-PARITY-BACKLOG.14.7.2 adds compiler/staged-ast-enrichment.md. The exact discovered public inventory becomes 60 files while classified/current selector counts remain 25/0; runtime/source retirement, backend anchors, and untracked discovery remain unchanged."
evidence_update_2026_08_29_codegen_inspector_page: "FUTURE-PARITY-BACKLOG.13.1 adds development/codegen-inspector.md. Exact staged canonical discovery measures the public inventory at 61 files; the new page contains no selector-shaped current example, so classified/current counts remain 25/0 and every runtime, source, backend-anchor, and untracked-discovery control is unchanged. The composed executable-source proof reports zero positives and 20 classified implementation/rejection occurrences: commit c8501d3a added the 20th, an intentionally classified Lua semantic-compilation failure fixture, on 2026-07-26 after the prior 19-count evidence was recorded."
reverify: "bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
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

Executable-source discovery covers both the index and nonignored untracked files. This matters because the commit
workflow validates before staging: a scanner based on plain `git ls-files` cannot see a newly created test until
after it is added to the index. The scanner now runs a temporary untracked-source discovery/rejection self-test on
every invocation and removes the probe in a `finally` block. Tests that need retired syntax obtain it from the
canonical neutral JSON invalid fixtures rather than embedding a second positive spelling.

`tools/check_public_aggregate_selector_surface.py` also discovers every immediate component README and requires
bare-binding anchors in the Rust, Dart, Julia, and Lua documents. Its exact 69-file inventory prevents a backend
entry document from falling outside the public zero-current-example claim.

The September13 integration .2.1 review adds the Rust integration page and updates
the exact current inventory from62 to63. The61-file wording previously in this
paragraph described the older codegen-page census; dated evidence above is retained.
See [[aggregate-selector-public-admission]] for the intervening macOS page and the
current one-path maintenance proof. Runtime/source retirement, classifier rules,
untracked discovery and all existing verification commands remain unchanged.

Related facts: [[spec-facing-aggregate-selector-retirement-inventory]],
[[aggregate-selector-public-admission]], [[uniform-binding-neutral-contract]],
[[perl-aggregate-selector-compile-rejection]],
[[rust-aggregate-selector-compile-rejection]], [[dart-aggregate-selector-compile-rejection]],
[[julia-aggregate-selector-compile-rejection]], [[lua-aggregate-selector-compile-rejection]].

## September 14 Perl integration-page review

`BACKEND-INTEGRATION-GUIDES.1.1` adds only the new Perl integration
chapter to public discovery. Preflight reproduces mutation expected64/observed65
and selector expected63/observed64. The reviewed correction changes only each
checker's expected file count and current census references. The selector's35
classified references, zero current examples and11 contrast mutations remain;
mutation's14 governed documents,11 example classes,10 denials and50 mutations
remain. Earlier dated evidence is preserved. Reverify with the existing command.

## September 19 Dart integration-page review

`BACKEND-INTEGRATION-GUIDES.3.1` adds the native Dart integration chapter.
Preflight reproduces mutation expected65/observed66 and selector expected64/observed65.
Only the two expected file counts and current census references advance. All
classifier logic, frozen authorities,35 selector references,zero current examples,
11 contrast mutations and mutation14/11/10/50 semantic checks remain unchanged.
Earlier dated evidence stays intact; reverify with the existing command.

## September 20 Julia integration-page review

`BACKEND-INTEGRATION-GUIDES.4.1` adds the native Julia integration chapter.
Preflight reproduces mutation expected66/observed67 and selector expected65/observed66.
Only the two expected file counts and current census references advance. Classifier
logic, frozen authorities,35 selector references,zero current examples,11 contrast
mutations and mutation14/11/10/50 checks remain unchanged. Earlier evidence stays
intact; reverify with the existing command.

## September22 document-grammar chapter review

Startup .83.2.2 reviews the new complete-document grammar chapter. The selector
guard first rejects expected68/observed69; the exact file count then advances to69.
The35 classified references, zero current examples, five migration contrasts and
eleven contrast mutations remain unchanged. The related mutation checker advances
from69 to70 public files with all semantic guards intact. Current census prose is
updated; earlier dated results retain their measured counts.

## September 20 Lua integration-page review

`BACKEND-INTEGRATION-GUIDES.5.1` adds the native Lua integration chapter.
Preflight reproduces mutation expected67/observed68 and selector expected66/observed67.
Only the two expected file counts and current census references advance. Classifier
logic, frozen authorities,35 selector references,zero current examples,11 contrast
mutations and mutation14/11/10/50 checks remain unchanged. Earlier evidence stays
intact; reverify with the existing command.
