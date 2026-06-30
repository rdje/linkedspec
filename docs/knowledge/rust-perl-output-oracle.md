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
  - "why does tclite still return [] after the header-line-regex fix"
  - "how does the Rust parser handle .push / .return on action edges"
  - "are action-edge fluent continuations lowered in the Rust variant"
  - "are no-arg action-edge fluent continuations lowered in Rust"
  - "why is tclite still deferred after action-edge fluent continuations landed"
  - "does a regex on a rule header line register in the Rust parser"
date: 2026-06-30
status: confirmed
tags: [rust, oracle, corpus, parity, RUST-PARITY, testing]
evidence: "RUST-PARITY.7.1 (2026-06-17): tools/gen_oracle_corpus.pl (Perl, alarm-timeout-guarded, JSON::PP->canonical(1)) emits tests/corpus/<case>/{input.spec,input.txt,expected.json}; rust/linkedspec-runtime/tests/corpus_oracle.rs enumerates them and asserts engine.execute(input) == json!([expected]). Proven green on 2 authored grammars (scalar + nested-array). RUST-PARITY.7.5.1 (2026-06-17): fixed the header-line-regex bug (parser.rs:86 (\\S*)->([^\\s/]*)) so header-line regexes register and bracket pairs resolve open[0]/close[1] (4 unit tests; cargo test 242 passed). SPEC-FORMAT-TERSE.2.3.3.1 / RUST-PARITY.7.5.3 partial action-edge parity (2026-06-30): Rust parser/compiler/runtime now carry action-edge fluent_chain and execute no-arg .push, .return(expr), and .return_undef; focused core fluent_chain and runtime terse_2_3_3_1 tests pass. tclite remains deferred because compact lifecycle/body fluent forms such as I.return(...) and default-mode repetition are separate blockers. Lispish (uses { } blocks) needs .7.5.2 (scalaref)."
reverify: "cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus"
---

# Perl↔Rust Output Oracle (RUST-PARITY.7)

**Confirmed 2026-06-17 (RUST-PARITY.7.1); updated 2026-06-30
(SPEC-FORMAT-TERSE.2.3.3.1).** A language-neutral cross-variant parity gate
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

## What the oracle caught (root causes located → RUST-PARITY.7.5.1 done, partial .7.5.3 done, .7.5.2 open)

The `.7`-split note assumed the Perl↔Rust gap was *only* the wrap. The oracle disproved
that: the Rust engine does **not** yet reproduce the shipped recursive specs.

- **Header-line-regex → 0-regex parser bug (`.7.5.1`, FIXED 2026-06-17; necessary, NOT
  sufficient for tclite).** `rust/linkedspec-core/src/parser.rs:86` — the rule-header regex
  `^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)` used `(\S*)` for the mode-suffix group, which
  greedily swallowed a `/…/` regex placed on the header line; `parse_mode_suffix("/;/")`
  returned `RuleMode::Default` and the regex was silently dropped (never reached `rest`/the
  body), so the rule registered 0 regexes (an open/close pair registered 1 — group 3 ate the
  first delimiter) and every `-> child[N]` dispatch edge "never fired". **It bit `:` and `::`
  alike** — "regex on the header line", not "single colon"; the integration tests / `::`
  top-rules escaped it only by putting the regex on a separate body line. **Fixed** by
  narrowing group 3 to `([^\s/]*)` so a `/`-led regex falls through to group 4 (`rest`),
  where `parse_inline_body` registers it; real mode suffixes (`AND`/`OR+`/`&`/`*`/`?`/
  `AND{2,4}`) are slash-free so behavior is unchanged for them. Bracket pairs are **repaired**:
  `command_subst : /open/ /close/` now registers `[open, close]` (entry idx 0 = open, the
  self-recursive `-> command_subst[1]` resolves to idx 1 = close). **BUT this alone did NOT
  green tclite** — with the regexes registering, the oracle still showed tclite `[]` → `[]`.
  See the next bullet.
- **Action-edge no-arg fluent continuations (`.7.5.3` partial, LANDED 2026-06-30 under
  `SPEC-FORMAT-TERSE.2.3.3.1`).** tclite originally exposed that Rust dropped
  continuations on ACTION edges such as `-> command_subst .push` and
  `-> command_subst[1] .return(...)`. Rust now carries action-edge `fluent_chain` through
  `ActionEdge` / `AcodeEntry`, and runtime dispatch executes no-arg `.push`,
  `.return(expr)`, and `.return_undef`. Focused locks cover child return capture, child
  return-event suppression, and close-edge return without recursive child redispatch.
- **tclite is still deferred after action-edge fluent parity.** The shipped spec also uses
  compact lifecycle/body fluent forms such as `I.return(...)`, which still parse as
  standalone `FluentChain` body elements that the compiler drops, and it depends on the
  separate default-mode repetition parity gap. Those blockers remain owned by follow-on
  `SPEC-FORMAT-TERSE.2.3.3.x` / `RUST-PARITY` work rather than by the action-edge slice.
- **Lispish remains independent.** Lispish uses `{ code }` blocks rather than action-edge
  fluent continuations and still needs the `scalaref(retv, {content})` hashref-field
  accessor parsed (`.7.5.2`).
- **`scalaref({content})` hash-literal parser gap (→ `.7.5.2`; independent; Lispish).**
  `rust/linkedspec-core/src/expr.rs:299` — `parse_expr` has no `{` case, so Lispish's
  `scalaref(retv, {content})` raises `unexpected character '{'`; needs a new `Expr`
  variant + parser production + engine field-access semantics. Depends on `.7.5.1`.
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

- Task tree: [[RUST-PARITY]] / [[SPEC-FORMAT-TERSE]] (leaves `.7.1` oracle, `.7.5.1`
  header-regex fix done; `.7.5.3` action-edge no-arg fluent lowering partially landed under
  `SPEC-FORMAT-TERSE.2.3.3.1`; tclite still blocked on compact lifecycle/body fluent forms
  plus default-mode repetition; Lispish on `.7.5.2` scalaref)
- ADR: `docs/decisions/0006-multi-backend-vision.md` (§Phase 8.6 language-neutral corpus)
- Related: [[rust-retv-propagation]], [[rust-edge-semantics-bug]], [[rust-entry-match-separation]]
- Files: `tools/gen_oracle_corpus.pl`, `rust/linkedspec-runtime/tests/corpus_oracle.rs`,
  `rust/linkedspec-runtime/tests/corpus/README.md`
