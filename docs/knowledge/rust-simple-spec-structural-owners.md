---
id: rust-simple-spec-structural-owners
title: RUST-PARITY.7.3.4 structural mismatches are implementation-owned, not fixture-owned: lib_reader starts in parser/compiler, portmap and ebnf expose Rust runtime semantic gaps
answers:
  - "who owns the portmap lib_reader ebnf Rust structural oracle mismatches"
  - "why did RUST-PARITY.7.3.4 not add portmap lib_reader ebnf fixtures"
  - "what is the next implementation owner after RUST-PARITY.7.3.4"
  - "why does lib_reader return empty array in Rust"
  - "why does portmap warn unknown helper or in Rust"
  - "why does ebnf duplicate rule headers in Rust"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, parity, portmap, lib_reader, ebnf, RUST-PARITY]
evidence: "RUST-PARITY.7.3.4 reproduced the mismatches with `perl -Iperl` Perl reference probes and a temporary Rust probe using the same parse/validate/compile/execute path as `corpus_oracle`. Perl reference values are JSON-safe for representative cases: portmap `foo` -> `[\"?bare:\",[\"foo\"]]`, portmap `{foo bar[2]}` -> `[\"?concat:\",[[\"?bare:\",[\"foo\"]],[\"?bit:\",[\"bar\",\"2\"]]]]`, lib_reader `cell(\"foo\"){ attr(\"bar,baz\"); }` -> `[[\"GROUP\",\"cell\",\"foo\",[[\"CATTRIBUTE\",\"attr\",[\"bar\",\"baz\"]]]]]`, ebnf expression rules -> two rule arrays with token payloads. Rust diverges: portmap `foo` -> `[[\"?bare:\",[[\"foo\"]]]]`, `bar[3]` warns `unknown helper 'or'` and is tagged `?bare:`, concat -> `[[\"?multi:\",[]]]`; lib_reader sattribute/cattribute inputs -> `[[]]`; ebnf expression/logging inputs duplicate rule headers and drop token payloads. Rust compiled-rule dumps show lib_reader `lib_file` has no action dispatch despite shipped `lib_file:: -> group .push`, while ebnf fluent chains are present, so lib_reader starts in parser/compiler and ebnf/portmap are runtime semantic owners."
reverify: "rg -n 'RUST-PARITY\\.7\\.3\\.4|header-rest action edges|unknown helper.*or|array\\(flat_array|duplicate.*rule headers|lib_file:: -> group' docs/tasks/RUST-PARITY.md DEVELOPMENT_NOTES.md CHANGES.md docs/knowledge/rust-simple-spec-structural-owners.md"
---

# Rust Simple-Spec Structural Owners

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.4`).** The `portmap`, `lib_reader`, and `ebnf`
structural oracle mismatches are not safe fixture additions yet.

First owners:

- `RUST-PARITY.7.3.4.1`: parser/compiler. Rust drops the regex-less top-rule
  header-rest action edge in `lib_reader` (`lib_file:: -> group .push`), so the top
  rule has no dispatch and returns an empty top accumulator.
- `RUST-PARITY.7.3.4.2`: runtime helper/list-context parity. `portmap` needs the
  boolean helper surface (`or` at minimum) and Perl-style list-context splicing for
  constructs such as `array(flat_array(entry_parts))`.
- `RUST-PARITY.7.3.4.3`: runtime action-edge fluent child/target aggregation. `ebnf`
  compiles `.push(child, rule)` chains but executes them with duplicated rule headers
  and missing token payloads; `portmap` concatenation also depends on the no-arg
  recursive `.push` path.
