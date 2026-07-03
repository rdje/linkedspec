---
id: rust-header-rest-action-edge-spacing
title: Rust header-rest action edges preserve unrecognized header tokens; `->` and `=>` spacing is optional by grammar
answers:
  - "is whitespace required after -> or => in .spec"
  - "where is whitespace after -> required"
  - "why did Rust drop lib_file group push"
  - "what did RUST-PARITY.7.3.4.1 fix"
  - "why does lib_reader still return null groups after RUST-PARITY.7.3.4.1"
  - "which runtime owner follows RUST-PARITY.7.3.4.1"
date: 2026-07-03
status: confirmed
tags: [rust, parser, action-edge, blind-edge, lib_reader, RUST-PARITY]
evidence: "The authoritative grammar in specs/spec.spec uses `->[ \\t]*` for action_block/action_fluent/action_bare and `=>[ \\t]*` for blind_block/blind_fluent/blind_bare, so spaces or tabs after `->`/`=>` are optional. The old Rust parser used `[ \\t]+` in re_action/re_blind and the header scanner treated unrecognized post-colon tokens (`->`, `->Child.push`, `I.return(...)`) as default modes, dropping them from header-rest body syntax. RUST-PARITY.7.3.4.1 changes Rust to restore unrecognized header tokens into the body rest and changes action/blind edge regexes to optional spacing. Focused parser/compiler/runtime tests pass; lib_reader now compiles top group dispatch and no longer collapses to `[[]]`. Remaining lib_reader null capture fields are runtime capture propagation for dependency-resolved child regex matches, owned by RUST-PARITY.7.3.4.4."
reverify: "rg -n 'parse_mode_suffix_strict|re_action|re_blind|header_rest_action_edge|compact_arrow|RUST-PARITY\\.7\\.3\\.4\\.1|RUST-PARITY\\.7\\.3\\.4\\.4|->\\[ \\\\t\\]\\*|=>\\[ \\\\t\\]\\*' specs/spec.spec rust/linkedspec-core/src/parser.rs rust/linkedspec-core/src/compiler.rs rust/linkedspec-runtime/tests/integration_test.rs docs/tasks/RUST-PARITY.md docs/linkedspec-book/src docs/knowledge"
---

# Rust Header-Rest Action Edge Spacing

Confirmed 2026-07-03 (`RUST-PARITY.7.3.4.1`).

The `.spec` grammar does not require whitespace after `->` or `=>`. The grammar uses
`[ \t]*`, so both spaced and compact forms are valid:

- `-> Child`
- `->Child`
- `Top::->Child.push`
- `=> Child`
- `=>Child`

The Rust bug was implementation drift:

- the action/blind edge regexes required one or more spaces/tabs;
- the rule-header parser consumed compact body syntax as an unrecognized mode suffix
  and discarded it as default mode.

`RUST-PARITY.7.3.4.1` fixes the parser/compiler boundary. `lib_reader` still needs
runtime capture propagation work under `RUST-PARITY.7.3.4.4` before its oracle fixture
can land.
