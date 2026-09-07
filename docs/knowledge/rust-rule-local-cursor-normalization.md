---
id: rust-rule-local-cursor-normalization
title: "Rust retains typed bare edges and separates authored family identity from staged cursor execution"
answers:
  - "does Rust parse bare rule edges"
  - "where does Rust normalize bare edge ownership"
  - "how does Rust classify compact pipe"
  - "where are Rust rule local cursor diagnostics represented"
  - "why does Rust have uses_legacy_and_interpretation"
  - "does Rust default bare edge execute yet"
  - "does Rust AND bare edge execute after normalization"
  - "which Rust leaf changes live cursor execution"
  - "how is Rust cursor execution frozen during normalization"
  - "why does the Rust Default mode comment disagree with its repetition minimum"
  - "is Rust Single ampersand mode choice or AND"
date: 2026-09-07
status: verified normalization; normal live policy migrated by FUTURE-PARITY-BACKLOG.9.1.4.3
tags: [rust, dsl, cursor, bare-edge, parser, compiler, validation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Rust core classifies compact `|` as authored OR and `&` as authored AND, retains complete-line/header-rest bare targets as `BareEdge`, validates all neutral edge diagnostics with stable code/stage/fields, and lowers family-derived ownership into typed acode/bcode tables. FUTURE-PARITY-BACKLOG.9.1.4.3 spends that normalized family in normal live/loaded/ordinary-reconstructed execution; .9.1.4.4 projects it through descriptor v1; .9.1.4.5 derives generated-source-v2 policy from its minimal neutral family plan and removes the bounded legacy artifact adapter. Contract-driven core tests consume all 36 family and 18 edge cases plus six ownership sets; runtime execution tests consume all 36 family rows, eight parent/child mechanisms, and two structural replacements."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-core --test rule_local_cursor_normalization_test; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test rule_local_cursor_normalization; bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py"
---

Rust syntax/representation normalization is current at four exact seams:

- `rust/linkedspec-core/src/ast.rs` defines authored family identity. `RuleMode::is_and()`
  includes `&`, `AND`, `AND+`, and bounded AND, but not compact `|`.
- `rust/linkedspec-core/src/parser.rs` retains a complete physical-line or header-rest
  bare plain/indexed/grouped/block/fluent member as `BodyElementKind::BareEdge`.
  Reserved lifecycle markers are recognized first, and a suffix after another
  same-line member does not become a bare edge.
- `rust/linkedspec-core/src/validation.rs` resolves against the complete rule-label set,
  derives AND bare ownership as blind and OR/default ownership as action, rejects
  invalid shape/mixed ownership, and emits `PortableDiagnostic` code/stage/fields.
- `rust/linkedspec-core/src/compiler.rs` lowers valid normalized bare ownership into
  `bcode_dispatch` for AND and `acode_dispatch` for OR/default. It no longer loses
  governed candidates through `Raw`.

Normalization `.9.1.4.2` deliberately stopped before cursor execution. Follow-up
`.9.1.4.3` now makes normal live, loaded, and ordinary reconstructed rules derive
policy from their exact authored family and makes blind orchestration follow that
family. Descriptor `.9.1.4.4` now projects the same normalized family/policy/edges.
Generated-source `.9.1.4.5` now derives policy from its minimal neutral v2 family
plan; `legacy_artifact_parse_mode()` and the private v1 wire serializer are gone.

`PortableDiagnostic` is a sorted, serializable Rust core record with stable `code`,
`stage`, human message, and contract-declared fields. The normalization suite checks
every governed diagnostic identity directly. Primary-command diagnostic projection
and retired global option bytes remain assigned to later Rust leaves.

The 2026-09-07 reading checkpoint `SESSION-STARTUP-READING.3.3.2` confirms two stale
comments in `rust/linkedspec-core/src/ast.rs`: `Default` is described as equivalent
to `OR+`, although `rep_min()` returns zero for Default and one for OR+; `Single`
(`&`) is described as choice, although `is_and()` includes Single. These comments
do not supersede the getters or neutral cursor authority. Existing repair
`SESSION-STARTUP-READING.41.2` owns their correction after prerequisite reading.

The fresh neutral contract check passes 36 family spellings, 18 edge cases, eight
parent/child cases, and 60 drift mutations. Earlier native test counts in this card
remain July evidence; this September reading checkpoint did not rerun those native
suites or change cursor behavior.

Checkpoint `.3.3.12` independently finds that the AND bare guard checks only the
legacy numeric `index`, although parsing now retains typed named/invalid selectors.
`Child[word]`, `Child[missing]` and `Child[!]` therefore compile as plain blind
calls while `Child[0]` is rejected. Perl descriptor probes confirm the same
provenance loss in its separate normalizer. `.57` owns both repairs and composed
recurrence: [[and-bare-nonnumeric-selector-loss]]. Existing numeric/bare fixtures
and the fresh 21 core validator tests do not cover those nonnumeric cases.

## September 7 selected core integration proof

Checkpoint `SESSION-STARTUP-READING.3.3.13` finishes reading
`rust/linkedspec-core/tests/rule_local_cursor_normalization_test.rs` and freshly
passes its five native tests, with no ignored or filtered cases, in 1.13 test
seconds. The managed invocation selects this target with `--locked --offline
--jobs 1`. The neutral checker independently passes 36 families, 18 edge cases,
eight parent/child cases and 60 mutations.

The native assertions compare governed diagnostic codes, stages and declared
fields, preserve complete portable-diagnostic serde equality, and inspect selected
compiled family/dispatch ownership after serde. This does not establish universal
compiled-object equality. Complete physical-line, header-rest and multiline bare
edges remain typed; a suffix following another same-line member is not a bare edge.
The six ownership sets and governed edge fixtures do not cover `.57`'s
nonnumeric AND selectors. Runtime execution, descriptor and generated-route suites
were not selected by this core-only run.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[rule-local-cursor-neutral-contract]], [[rust-rule-local-cursor-execution]],
[[rust-local-verification-gate]], and
[[FUTURE-PARITY-BACKLOG]].
