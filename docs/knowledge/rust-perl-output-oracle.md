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
  - "does a regex on a rule header line register in the Rust parser"
date: 2026-06-17
status: confirmed
tags: [rust, oracle, corpus, parity, RUST-PARITY, testing]
evidence: "RUST-PARITY.7.1 (2026-06-17): tools/gen_oracle_corpus.pl (Perl, alarm-timeout-guarded, JSON::PP->canonical(1)) emits tests/corpus/<case>/{input.spec,input.txt,expected.json}; rust/linkedspec-runtime/tests/corpus_oracle.rs enumerates them and asserts engine.execute(input) == json!([expected]). Proven green on 2 authored grammars (scalar + nested-array). RUST-PARITY.7.5.1 (2026-06-17): fixed the header-line-regex bug (parser.rs:86 (\\S*)->([^\\s/]*)) so header-line regexes register and bracket pairs resolve open[0]/close[1] (4 unit tests; cargo test 242 passed). But the oracle proved this NECESSARY-NOT-SUFFICIENT for tclite: it still returns [] because action-edge fluent continuations (-> command_subst .push / .return(...)) are dropped — the parser attaches .method chains only to blind (=>) edges, so the compiler discards them after a -> edge (compiler.rs:171). That second blocker is RUST-PARITY.7.5.3. Lispish (uses { } blocks) needs only .7.5.1 + .7.5.2 (scalaref)."
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

## What the oracle caught (root causes located → RUST-PARITY.7.5.1 done, .7.5.2, .7.5.3)

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
- **Action-edge fluent continuations dropped (→ `.7.5.3`; the SECOND tclite blocker, found
  by `.7.5.1`).** tclite accumulates via fluent continuations on ACTION edges
  (`-> command_subst .push`, `-> command_subst[1] .return(...)`). The Rust parser attaches a
  `.method` fluent chain only to a BLIND edge (`=>`, `parser.rs:443` calls
  `parse_fluent_chain`); after a `->` edge it captures only a following `{ }` block
  (`parser.rs:411-429`), so a trailing `.push`/`.return(...)` parses as a STANDALONE
  `FluentChain` body element that the compiler discards (`compiler.rs:171`,
  `BodyElementKind::FluentChain { .. } => { last_regex_line = None; }` — no codegen). So the
  edges dispatch their children but never push/return, and tclite still yields `[]`. Lowering
  action-edge fluent chains (attach to `ActionEdge`, execute after dispatch in the
  acode-dispatch loop) is `.7.5.3`. Lispish is unaffected — it uses `{ code }` blocks, not
  the fluent form.
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

- Task tree: [[RUST-PARITY]] (leaves `.7.1` oracle, `.7.5.1` header-regex fix done; tclite blocked on `.7.5.3` action-edge fluent lowering; Lispish on `.7.5.2` scalaref)
- ADR: `docs/decisions/0006-multi-backend-vision.md` (§Phase 8.6 language-neutral corpus)
- Related: [[rust-retv-propagation]], [[rust-edge-semantics-bug]], [[rust-entry-match-separation]]
- Files: `tools/gen_oracle_corpus.pl`, `rust/linkedspec-runtime/tests/corpus_oracle.rs`,
  `rust/linkedspec-runtime/tests/corpus/README.md`
