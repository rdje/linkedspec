---
id: rust-simple-spec-structural-owners
title: RUST-PARITY.7.3.4 structural mismatches are implementation-owned, not fixture-owned: lib_reader starts in parser/compiler, portmap and ebnf expose Rust runtime semantic gaps
answers:
  - "who owns the portmap lib_reader ebnf Rust structural oracle mismatches"
  - "why did RUST-PARITY.7.3.4 not add portmap lib_reader ebnf fixtures"
  - "what is the next implementation owner after RUST-PARITY.7.3.4"
  - "why does lib_reader return empty array in Rust"
  - "why does lib_reader still return null groups after RUST-PARITY.7.3.4.1"
  - "when did lib_reader sattribute and cattribute enter the Rust oracle corpus"
  - "when did portmap scalar fixtures enter the Rust oracle corpus"
  - "when did portmap_concatenation enter the Rust oracle corpus"
  - "when did ebnf_expression_rules enter the Rust oracle corpus"
  - "when did ebnf_logging_annotation enter the Rust oracle corpus"
  - "why does portmap warn unknown helper or in Rust"
  - "why did portmap constant 0x1f return null in Rust"
  - "why does ebnf duplicate rule headers in Rust"
  - "why did ebnf stop duplicating rule headers in Rust"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, parity, portmap, lib_reader, ebnf, RUST-PARITY]
evidence: "RUST-PARITY.7.3.4 reproduced the mismatches with `perl -Iperl` Perl reference probes and a temporary Rust probe using the same parse/validate/compile/execute path as `corpus_oracle`. Perl reference values are JSON-safe for representative cases: portmap `foo` -> `[\"?bare:\",[\"foo\"]]`, portmap `{foo bar[2]}` -> `[\"?concat:\",[[\"?bare:\",[\"foo\"]],[\"?bit:\",[\"bar\",\"2\"]]]]`, lib_reader `cell(\"foo\"){ attr(\"bar,baz\"); }` -> `[[\"GROUP\",\"cell\",\"foo\",[[\"CATTRIBUTE\",\"attr\",[\"bar\",\"baz\"]]]]]`, ebnf expression rules -> two rule arrays with token payloads. Rust diverged: portmap `foo` -> `[[\"?bare:\",[[\"foo\"]]]]`, `bar[3]` warns `unknown helper 'or'` and is tagged `?bare:`, concat -> `[[\"?multi:\",[]]]`; lib_reader sattribute/cattribute inputs initially -> `[[]]`; ebnf expression/logging inputs duplicate rule headers and drop token payloads. RUST-PARITY.7.3.4.1 fixed lib_reader parser/compiler ownership: `lib_file` now compiles the `group` `.push` action dispatch and representative Rust outputs produce `GROUP` nodes instead of `[[]]`. The remaining lib_reader null capture fields are runtime capture propagation for dependency-resolved edge-only child regex matches, owned by RUST-PARITY.7.3.4.4. Portmap and ebnf remain runtime semantic owners."
evidence_update_2026_07_03_7344: "RUST-PARITY.7.3.4.4 closed the lib_reader branch. A focused edge-only child-regex test showed child entry captures were already seeded correctly; the remaining lib_reader divergence was missing Rust statement-form helper mutation. Rust now mutates scalar targets for `substr(scalar(target), pattern, replacement, flags)` / `regex_subst(...)` and array targets for `split(array(target), scalar(source), delimiter)`. `lib_reader_sattribute` and `lib_reader_cattribute` are checked-in oracle fixtures; corpus_oracle passes over 68 fixtures. Portmap and ebnf remain runtime semantic owners."
evidence_update_2026_07_03_7342: "RUST-PARITY.7.3.4.2 closed the portmap scalar branch. Rust now implements `or`/`and`/`not`, splices explicit `flat`/`flat_array`/`flat_hash` helper calls in `array(...)` list context, and wraps each rule regex as a non-capturing branch before building dispatch alternations. The wrapper fix prevents the internal `|(?i)(0x...)` branch in `bare_bit_slice` from being reported as the sibling `concatenation` action edge, which was why `0x1f` returned null. `portmap_bare`, `portmap_bit`, `portmap_slice`, and `portmap_constant` are checked-in oracle fixtures; corpus_oracle passes over 72 fixtures. Portmap concatenation and ebnf payloads remain owned by RUST-PARITY.7.3.4.3."
evidence_update_2026_07_04_7343: "RUST-PARITY.7.3.4.3 closed the portmap concatenation and ebnf payload branch. Rust now exposes scoped action-edge child returns to call(child), push(child), push(child,target), and child-index push forms, skips passive terminal child re-search after the parent edge regex has consumed the token, preserves scalar-vs-aggregate assignment boundaries, and reads bare aggregate variables from aggregate stores in helper-consuming slots. `portmap_concatenation`, `ebnf_expression_rules`, and `ebnf_logging_annotation` are checked-in oracle fixtures; corpus_oracle passes over 77 fixtures. The structural branch then moved to RUST-PARITY.7.3.5 null/action-parser candidate triage and RUST-PARITY.7.3.6 RTL/plugin/legacy safety-smoke audit, both now closed. RUST-PARITY.7.4 finalized the oracle corpus guard; RUST-PARITY.8.1 split the source-emitter lane; RUST-PARITY.8.2 landed the minimal generated-source scaffold/compile-run harness; RUST-PARITY.8.3.1 landed the generated family plan; RUST-PARITY.8.3.2/.8.3.3 landed direct acode generated execution; RUST-PARITY.8.3.4 landed direct AND/OR bcode generated execution; RUST-PARITY.8.3.5 closed the non-REP generated matrix; current RUST-PARITY frontier is .8.4."
reverify: "rg -n 'RUST-PARITY\\.7\\.3\\.4|RUST-PARITY\\.7\\.3\\.4\\.1|RUST-PARITY\\.7\\.3\\.4\\.2|RUST-PARITY\\.7\\.3\\.4\\.3|RUST-PARITY\\.7\\.3\\.4\\.4|lib_reader_sattribute|lib_reader_cattribute|portmap_bare|portmap_bit|portmap_slice|portmap_constant|portmap_concatenation|ebnf_expression_rules|ebnf_logging_annotation|passive terminal|action-edge child' docs/tasks/RUST-PARITY.md DEVELOPMENT_NOTES.md CHANGES.md docs/knowledge tools/gen_oracle_corpus.pl rust/linkedspec-runtime/src"
---

# Rust Simple-Spec Structural Owners

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.4`).** The `portmap`, `lib_reader`, and `ebnf`
structural oracle mismatches are not safe fixture additions yet.

First owners:

- `RUST-PARITY.7.3.4.1`: done. Rust now compiles the regex-less top-rule
  header-rest action edge in `lib_reader` (`lib_file:: -> group .push`) and no longer
  returns an empty top accumulator for representative probes.
- `RUST-PARITY.7.3.4.4`: done. A focused edge-only child-regex test showed runtime
  capture propagation was already correct; the real lib_reader blocker was
  statement-form helper mutation. Rust now mutates scalar targets for
  `substr(scalar(target), pattern, replacement, flags)` / `regex_subst(...)` and array
  targets for `split(array(target), scalar(source), delimiter)`. The
  `lib_reader_sattribute` and `lib_reader_cattribute` oracle fixtures are active.
- `RUST-PARITY.7.3.4.2`: done. Runtime helper/list-context parity now covers
  `portmap` scalar classifications. Rust implements `or`/`and`/`not`, splices
  explicit `flat`/`flat_array`/`flat_hash` helper calls inside `array(...)`, and wraps
  each rule regex in its own non-capturing dispatch branch so internal alternations
  such as `|(?i)(0x...)` stay inside the owning action edge. The `portmap_bare`,
  `portmap_bit`, `portmap_slice`, and `portmap_constant` oracle fixtures are active.
- `RUST-PARITY.7.3.4.3`: done. Runtime action-edge child/target aggregation now
  reuses the already matched edge child return for block/fluent child calls and skips
  passive terminal child re-search. The `portmap_concatenation`,
  `ebnf_expression_rules`, and `ebnf_logging_annotation` oracle fixtures are active.

The structural branch is closed. The follow-on null-output/spec-smoke triage,
RTL/plugin/legacy safety-smoke audit, and oracle corpus finalization guard are
also closed. `RUST-PARITY.8.1` has since split the source-emitter lane,
`RUST-PARITY.8.2` landed the minimal generated-source scaffold and compile/run
harness, `RUST-PARITY.8.3.1` landed the generated family plan, `.8.3.2` /
`.8.3.3` landed direct acode generated execution, `.8.3.4` landed direct
AND/OR bcode generated execution, and `.8.3.5` closed the non-repetition
generated-family matrix. The current RUST-PARITY frontier is `.8.4`, REP
generated execution and termination guards.
