---
id: rust-perl-output-oracle
title: The Perl↔Rust output oracle — a timeout-guarded Perl generator (tools/gen_oracle_corpus.pl) emits canonical-JSON fixtures into rust/linkedspec-runtime/tests/corpus/, and a Rust fixture-runner (tests/corpus_oracle.rs) asserts engine.execute(input) == [reference]; the Rust engine wraps the Perl top-rule value one level
answers:
  - "what is the Perl↔Rust output oracle"
  - "how does the Rust variant test output parity against the Perl reference"
  - "where is the cross-variant test corpus"
  - "how do I regenerate the oracle corpus fixtures"
  - "why does the Rust engine output wrap the Perl reference value one level"
  - "does the Rust engine reproduce tclite or Lispish output yet"
  - "why does tclite return [] in the Rust engine"
  - "what is the single-regex rule 0-regex compiler gap in the Rust variant"
  - "do single-colon name : /re/ rules work in the Rust compiler"
  - "why do retv-based inline grammars diverge between Perl and Rust"
date: 2026-06-17
status: confirmed
tags: [rust, oracle, corpus, parity, RUST-PARITY, testing]
evidence: "RUST-PARITY.7.1 (2026-06-17): tools/gen_oracle_corpus.pl (Perl, alarm-timeout-guarded, JSON::PP->canonical(1)) emits tests/corpus/<case>/{input.spec,input.txt,expected.json}; rust/linkedspec-runtime/tests/corpus_oracle.rs enumerates them and asserts engine.execute(input) == json!([expected]). Proven green on 2 authored grammars (scalar + nested-array). cargo test 238 passed (237 baseline + 1). Oracle caught: tclite [] -> Rust [] (vs Perl ['?tcl_script:',[['?command_subst:',[]]]]) and Lispish exit_now(1) — both blocked by the single-regex-rule 0-regex compiler gap (deferred to RUST-PARITY.7.5)."
reverify: "cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus"
---

# Perl↔Rust Output Oracle (RUST-PARITY.7)

**Confirmed 2026-06-17 (RUST-PARITY.7.1).** A language-neutral cross-variant parity gate
(ADR 0006 §Phase 8.6). The Perl reference is the behavioral oracle; the corpus is its
frozen output; `cargo test` validates the Rust backend against it with no Perl in the loop.

## Mechanism

- **Generator** `tools/gen_oracle_corpus.pl` — for each `(spec, input)` case it runs the
  Perl reference parser under a hard `alarm(...)` timeout (default 15s — guards the known
  RTLUtils catastrophic-backtrack hang) and writes one corpus directory per case:
  `tests/corpus/<case>/{input.spec, input.txt, expected.json}`. `expected.json` is
  `JSON::PP->canonical(1)` (sorted keys → byte-stable regeneration). A case is either a
  shipped spec (`spec => 'tclite'`, slurped from `specs/`) or an authored inline grammar
  (`source => "..."`).
- **Runner** `rust/linkedspec-runtime/tests/corpus_oracle.rs` — enumerates the corpus,
  runs `parse_spec → validate → compile → Engine::new → execute(input.txt)`, and compares.
  It reports every entry (PASS/FAIL) and fails once at the end, so one run surfaces all
  divergences.

## Output-shape rule (the canonical reconciliation)

The Perl reference returns the top rule's value **directly**; the Rust engine wraps the
accumulator **one level** (`Engine::execute` returns `RuntimeValue::Array(accumulator)` —
`engine.rs` ~150). So `expected.json` stores the backend-neutral **reference value** and
the Rust runner compares `engine.execute(input) == json!([expected])`. Proven on a scalar
(`"scalar-ok"` → `["scalar-ok"]`) and a nested array (`["?proof:","ok"]` →
`[["?proof:","ok"]]`).

## What the oracle caught on its first run (deferred to RUST-PARITY.7.5)

The `.7`-split note assumed the Perl↔Rust gap was *only* the wrap. The oracle disproved
that: the Rust engine does **not** yet reproduce the shipped recursive specs.

- **Single-regex rule → 0-regex compiler gap (root cause for tclite AND Lispish).** A rule
  written `name : /re/` (single colon, single regex) — incl. the inline
  `name : /re/  I.return(...)` form — compiles in Rust as **0 regexes**, so every
  `-> child[0]` dispatch edge "never fires". tclite on `[]` returns `[]` instead of
  `["?tcl_script:",[["?command_subst:",[]]]]`; Lispish falls through to its
  `parenthesis[1]` syntax-error branch and `exit_now(1)`. (`::` single-regex rules are
  fine — the integration tests prove that; the gap is the single-colon `:` form.)
- **Lispish also needs** the `scalaref(retv, {content})` hashref-field accessor parsed
  (Rust action-code parser: `unexpected character '{'`).
- **Child `return` leaks into the parent accumulator.** Rust's `return(expr)` pushes to the
  shared accumulator (RUST-PARITY.5.1 contract), so a child rule's `return(0)` adds a
  stray `0` to the parent's output; Perl routes a child return to `retv` instead.
- **retv-based inline grammars diverge** because Perl's *inline-spec* `retv` returns
  `undef` (the `.5.2` inline-spec friction) while Rust's retv works — so the more-correct
  Rust disagrees with flaky Perl-inline.
- **Group indexing differs** — Perl `entry_group(0)` = first capture; Rust = full match.

The `.7.1` proof grammars deliberately avoid all of the above (parent→child dispatch with
a literal edge return and an action-less child), so both backends agree exactly.

## Regenerating

```sh
perl tools/gen_oracle_corpus.pl            # default 15s per-parse timeout
ORACLE_TIMEOUT=30 perl tools/gen_oracle_corpus.pl
```

## Links

- Task tree: [[RUST-PARITY]] (leaf `.7.1`; divergences deferred to `.7.5`)
- ADR: `docs/decisions/0006-multi-backend-vision.md` (§Phase 8.6 language-neutral corpus)
- Related: [[rust-retv-propagation]], [[rust-edge-semantics-bug]], [[rust-entry-match-separation]]
- Files: `tools/gen_oracle_corpus.pl`, `rust/linkedspec-runtime/tests/corpus_oracle.rs`,
  `rust/linkedspec-runtime/tests/corpus/README.md`
