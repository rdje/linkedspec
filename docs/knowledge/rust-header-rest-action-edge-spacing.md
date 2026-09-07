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
  - "what closed the lib_reader blocker after RUST-PARITY.7.3.4.1"
  - "how do Rust action blind and bare edges differ in selector spacing"
  - "does restoring a Rust header mode token preserve an invalid body suffix"
date: 2026-09-07
status: confirmed
tags: [rust, parser, action-edge, blind-edge, lib_reader, RUST-PARITY]
evidence: "The authoritative grammar in specs/spec.spec uses `->[ \\t]*` for action_block/action_fluent/action_bare and `=>[ \\t]*` for blind_block/blind_fluent/blind_bare, so spaces or tabs after `->`/`=>` are optional. The old Rust parser used `[ \\t]+` in re_action/re_blind and the header scanner treated unrecognized post-colon tokens (`->`, `->Child.push`, `I.return(...)`) as default modes, dropping them from header-rest body syntax. RUST-PARITY.7.3.4.1 changes Rust to restore unrecognized header tokens into the body rest and changes action/blind edge regexes to optional spacing. Focused parser/compiler/runtime tests pass; lib_reader now compiles top group dispatch and no longer collapses to `[[]]`. Remaining lib_reader null capture fields are runtime capture propagation for dependency-resolved child regex matches, owned by RUST-PARITY.7.3.4.4."
evidence_update_2026_07_03_7344: "RUST-PARITY.7.3.4.4 later proved dependency-resolved child entry captures already worked and closed lib_reader by implementing statement-form helper mutation in Rust: scalar regex substitution through `substr`/`regex_subst` and array replacement through `split(array(target), scalar(source), delimiter)`. The `lib_reader_sattribute` and `lib_reader_cattribute` oracle fixtures are active."
reverify: "rg -n 'parse_mode_suffix_strict|re_action|re_blind|header_rest_action_edge|compact_arrow|RUST-PARITY\\.7\\.3\\.4\\.1|RUST-PARITY\\.7\\.3\\.4\\.4|lib_reader_sattribute|lib_reader_cattribute|->\\[ \\\\t\\]\\*|=>\\[ \\\\t\\]\\*' specs/spec.spec rust/linkedspec-core/src/parser.rs rust/linkedspec-core/src/compiler.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/integration_test.rs docs/tasks/RUST-PARITY.md docs/linkedspec-book/src docs/knowledge"
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

`RUST-PARITY.7.3.4.1` fixes the parser/compiler boundary. `RUST-PARITY.7.3.4.4`
then closed the lib_reader fixture path by implementing the statement-form helper
mutations that the shipped spec uses after the top dispatch becomes reachable.

Reading checkpoint `SESSION-STARTUP-READING.3.3.9` confirms the current manual
prefix scanners. Rule labels use the pinned Unicode label helper; horizontal
spaces may separate a label from its colon, and a mode token ends at whitespace
or `/`. A recognized bounded/ordinary mode is consumed; an unrecognized token is
restored to header body text. This restoration does not guarantee that the later
inline body parser retains every suffix: `.53` owns a separately measured invalid
lifecycle suffix discarded only on the header line.

Action groups share the selector adjacent to their final label. Bare groups retain
each target's optional selector and permit preceding horizontal space. Blind edges
use the separate numeric-index parser with optional horizontal space. Named/numeric
selector parsing retains malformed authored brackets for whole-spec validation;
these source facts do not extend named selectors to the blind-index path.

The July native proofs and former regex scanner names in the historical evidence
retain their dates. September's reading and neutral cursor/Unicode checks do not
rerun that complete native fixture matrix. The new compact-fluent, header-suffix
and regex-brace gaps are recorded in [[rust-body-parser-lexical-boundary-defects]].
