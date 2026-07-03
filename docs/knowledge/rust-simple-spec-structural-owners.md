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
  - "why does portmap warn unknown helper or in Rust"
  - "why does ebnf duplicate rule headers in Rust"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, parity, portmap, lib_reader, ebnf, RUST-PARITY]
evidence: "RUST-PARITY.7.3.4 reproduced the mismatches with `perl -Iperl` Perl reference probes and a temporary Rust probe using the same parse/validate/compile/execute path as `corpus_oracle`. Perl reference values are JSON-safe for representative cases: portmap `foo` -> `[\"?bare:\",[\"foo\"]]`, portmap `{foo bar[2]}` -> `[\"?concat:\",[[\"?bare:\",[\"foo\"]],[\"?bit:\",[\"bar\",\"2\"]]]]`, lib_reader `cell(\"foo\"){ attr(\"bar,baz\"); }` -> `[[\"GROUP\",\"cell\",\"foo\",[[\"CATTRIBUTE\",\"attr\",[\"bar\",\"baz\"]]]]]`, ebnf expression rules -> two rule arrays with token payloads. Rust diverged: portmap `foo` -> `[[\"?bare:\",[[\"foo\"]]]]`, `bar[3]` warns `unknown helper 'or'` and is tagged `?bare:`, concat -> `[[\"?multi:\",[]]]`; lib_reader sattribute/cattribute inputs initially -> `[[]]`; ebnf expression/logging inputs duplicate rule headers and drop token payloads. RUST-PARITY.7.3.4.1 fixed lib_reader parser/compiler ownership: `lib_file` now compiles the `group` `.push` action dispatch and representative Rust outputs produce `GROUP` nodes instead of `[[]]`. The remaining lib_reader null capture fields are runtime capture propagation for dependency-resolved edge-only child regex matches, owned by RUST-PARITY.7.3.4.4. Portmap and ebnf remain runtime semantic owners."
evidence_update_2026_07_03_7344: "RUST-PARITY.7.3.4.4 closed the lib_reader branch. A focused edge-only child-regex test showed child entry captures were already seeded correctly; the remaining lib_reader divergence was missing Rust statement-form helper mutation. Rust now mutates scalar targets for `substr(scalar(target), pattern, replacement, flags)` / `regex_subst(...)` and array targets for `split(array(target), scalar(source), delimiter)`. `lib_reader_sattribute` and `lib_reader_cattribute` are checked-in oracle fixtures; corpus_oracle passes over 68 fixtures. Portmap and ebnf remain runtime semantic owners."
reverify: "rg -n 'RUST-PARITY\\.7\\.3\\.4|RUST-PARITY\\.7\\.3\\.4\\.1|RUST-PARITY\\.7\\.3\\.4\\.4|lib_reader_sattribute|lib_reader_cattribute|unknown helper.*or|array\\(flat_array|duplicate.*rule headers|lib_file:: -> group' docs/tasks/RUST-PARITY.md DEVELOPMENT_NOTES.md CHANGES.md docs/knowledge/rust-simple-spec-structural-owners.md tools/gen_oracle_corpus.pl"
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
- `RUST-PARITY.7.3.4.2`: runtime helper/list-context parity. `portmap` needs the
  boolean helper surface (`or` at minimum) and Perl-style list-context splicing for
  constructs such as `array(flat_array(entry_parts))`.
- `RUST-PARITY.7.3.4.3`: runtime action-edge fluent child/target aggregation. `ebnf`
  compiles `.push(child, rule)` chains but executes them with duplicated rule headers
  and missing token payloads; `portmap` concatenation also depends on the no-arg
  recursive `.push` path.
