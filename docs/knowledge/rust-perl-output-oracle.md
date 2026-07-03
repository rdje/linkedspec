---
id: rust-perl-output-oracle
title: The Perl↔Rust output oracle — a process-hard-timeout Perl generator (tools/gen_oracle_corpus.pl) emits canonical-JSON fixtures into rust/linkedspec-runtime/tests/corpus/, and a Rust fixture-runner (tests/corpus_oracle.rs) asserts engine.execute(input) == [reference]; the Rust engine wraps the Perl top-rule value one level
answers:
  - "what is the Perl↔Rust output oracle"
  - "how does the Rust variant test output parity against the Perl reference"
  - "where is the cross-variant test corpus"
  - "how do I regenerate the oracle corpus fixtures"
  - "how does gen_oracle_corpus enforce hard timeouts"
  - "does the oracle timeout cover parser construction"
  - "does the oracle timeout cover parser build"
  - "does the oracle generator still rely on alarm for catastrophic regex timeouts"
  - "is the RTLUtils oracle timeout still live"
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
  - "are explicit-target action-edge fluent continuations lowered in Rust"
  - "why is tclite still deferred after action-edge fluent continuations landed"
  - "what happened when tclite was retried after Rust fluent parity"
  - "which leaf owns Rust tclite default-mode repetition parity"
  - "when did the shipped tclite fixtures enter the Rust oracle corpus"
  - "when did the shipped Lispish fixture enter the Rust oracle corpus"
  - "when did hlink_curly_brace enter the Rust oracle corpus"
  - "when did lib_reader sattribute and cattribute enter the Rust oracle corpus"
  - "did Rust temporarily support scalaref(retv, {content}) before retirement"
  - "does child return leak into the parent accumulator in Rust"
  - "does a regex on a rule header line register in the Rust parser"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, corpus, parity, RUST-PARITY, testing]
evidence: "RUST-PARITY.7.1 (2026-06-17): tools/gen_oracle_corpus.pl (Perl, JSON::PP->canonical(1)) emits tests/corpus/<case>/{input.spec,input.txt,expected.json}; rust/linkedspec-runtime/tests/corpus_oracle.rs enumerates them and asserts engine.execute(input) == json!([expected]). Proven green on 2 authored grammars (scalar + nested-array). RUST-PARITY.7.5.1 (2026-06-17): fixed the header-line-regex bug (parser.rs:86 (\\S*)->([^\\s/]*)) so header-line regexes register and bracket pairs resolve open[0]/close[1] (4 unit tests; cargo test 242 passed). SPEC-FORMAT-TERSE.2.3.3.1 (2026-06-30): Rust parser/compiler/runtime now carry action-edge fluent_chain and execute no-arg .push, .return(expr), and .return_undef; focused core fluent_chain and runtime terse_2_3_3_1 tests pass. SPEC-FORMAT-TERSE.2.3.3.3.1 (2026-06-30): Rust compact lifecycle chains such as I.return(...) and I.declare(...).return(...) now normalize to lifecycle CodeBlock statements and execute. SPEC-FORMAT-TERSE.2.3.3.3.2 (2026-06-30): Rust action-edge explicit/flow chains now execute .push(target), .push(child,target), .if/.else/.endif gating, helper calls, and return continuations. SPEC-FORMAT-TERSE.2.3.3.3.3.1 (2026-06-30): Rust default mode is now zero-min repeated choice, I-block return exits child dispatch before local re-match, and tclite_command_subst/tclite_double_quote are active. RUST-PARITY.7.5.2 (2026-07-02) temporarily restored legacy Lispish scalaref parity; SCALAREF-RETIREMENT.3 migrated Lispish to direct access, and SCALAREF-RETIREMENT.4 removed scalaref implementation support. RUST-PARITY.7.2 fixed Rust captures-only numbered helper indexing and added two hlink_substitution raw-string fixtures. RUST-PARITY.7.3.2 (2026-07-03): verified the historic RTLUtils timeout is retired from the current core tree, changed gen_oracle_corpus run_oracle from alarm() to per-case fork+SIGKILL process timeout, regenerated 65 fixtures byte-identically, and proved ORACLE_TIMEOUT=0 hard-kills the first parse. RUST-PARITY.7.3.3.2 added hlink_curly_brace for {abc}; corpus_oracle passes over 66 fixtures."
evidence_update_2026_07_03: "RUST-PARITY.7.3.7: user-directed timeout trace census found BNF timing out under a 5s build+parse child wrapper because get_parser('BNF') spends about 6.4s in parser construction while parsing empty input takes about 0.03s. LINKEDSPEC_TRACE_LEVEL=debug reached Parser generation completed successfully, so the live issue was the oracle guard boundary, not a parser execution hang. tools/gen_oracle_corpus.pl now builds the parser and executes the parse inside the forked child so ORACLE_TIMEOUT hard-kills parser construction and parse execution."
evidence_update_2026_07_03_7344: "RUST-PARITY.7.3.4.4 added `lib_reader_sattribute` and `lib_reader_cattribute` after Rust implemented statement-form scalar regex substitution and array split mutation helpers. `perl -Iperl tools/gen_oracle_corpus.pl` now emits 68 fixtures, and Rust `corpus_oracle` passes over all 68."
reverify: "perl -c -Iperl tools/gen_oracle_corpus.pl; ORACLE_TIMEOUT=0 perl -Iperl tools/gen_oracle_corpus.pl 2>&1 | grep 'hard kill during parser build/parse'; perl -Iperl tools/gen_oracle_corpus.pl; cd rust && cargo test --manifest-path Cargo.toml --test corpus_oracle 2>&1 | grep -E 'test result|PASS|FAIL'; ls linkedspec-runtime/tests/corpus"
---

# Perl↔Rust Output Oracle (RUST-PARITY.7)

**Confirmed 2026-06-17 (RUST-PARITY.7.1); updated 2026-07-03
(RUST-PARITY.7.3.7).** A language-neutral cross-variant parity gate
(ADR 0006 §Phase 8.6). The Perl reference is the behavioral oracle; the corpus is its
frozen output; `cargo test` validates the Rust backend against it with no Perl in the loop.

## Mechanism

- **Generator** `tools/gen_oracle_corpus.pl` — for each `(spec, input)` case it builds the
  Perl reference parser and runs the parse in a child process under a hard wall-clock
  timeout (default 15s). The parent kills the child with `SIGKILL` on timeout,
  deliberately avoiding `alarm()` because catastrophic regex backtracking can defer Perl
  safe signals. It writes one corpus directory per case:
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

## What the oracle caught (root causes located → tclite and Lispish minimal fixtures landed)

The `.7`-split note assumed the Perl↔Rust gap was *only* the wrap. The oracle disproved
that: the Rust engine initially did **not** reproduce the shipped recursive specs. Minimal
shipped `tclite` and `Lispish` fixtures are now active, with broader corpus expansion still
owned by `.7.2` / `.7.3`.

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
- **Action-edge no-arg fluent continuations (`.7.5.3`, LANDED 2026-06-30 under
  `SPEC-FORMAT-TERSE.2.3.3.1`).** tclite originally exposed that Rust dropped
  continuations on ACTION edges such as `-> command_subst .push` and
  `-> command_subst[1] .return(...)`. Rust now carries action-edge `fluent_chain` through
  `ActionEdge` / `AcodeEntry`, and runtime dispatch executes no-arg `.push`,
  `.return(expr)`, and `.return_undef`. Focused locks cover child return capture, child
  return-event suppression, and close-edge return without recursive child redispatch.
- **Compact lifecycle/body fluent chains (`SPEC-FORMAT-TERSE.2.3.3.3.1`, LANDED
  2026-06-30).** Rust now normalizes lifecycle-marker receiver chains such as
  `I.return(...)` and `I.declare(...).set(...).return(...)` into executable lifecycle
  `CodeBlock` statements. Focused parser/compiler/runtime locks cover no surviving
  standalone lifecycle-surface `FluentChain`, return-channel behavior, ordered
  declaration/mutation chains, and regex-first header-line inline placement.
- **Action-edge explicit/flow fluent chains (`SPEC-FORMAT-TERSE.2.3.3.3.2`, LANDED
  2026-06-30).** Rust now attaches multiline dotted continuations to the preceding action edge and executes
  `.push(target)`, `.push(child,target)`, `.if/.else/.endif` gating, helper calls such as `.say(...)`, and
  `.return(expr)` / `.return_undef()` through the parent-visible action-edge return channel.
- **tclite default-mode repetition parity (`SPEC-FORMAT-TERSE.2.3.3.3.3.1`, LANDED
  2026-06-30).** The fluent blockers were not the final shipped `tclite` gap. Rust now treats bare default
  rules as zero-min repeated-choice loops and mirrors Perl child-dispatch `I.return(...)` behavior: a preamble
  return exits before local entry-regex matching. `tclite_command_subst` (`[]`) and `tclite_double_quote`
  (`""`) are active fixtures in `tools/gen_oracle_corpus.pl` and the checked-in corpus; `corpus_oracle` passes
  with 41 fixtures.
- **Lispish fixture parity (`.7.5.2` then `SCALAREF-RETIREMENT`, LANDED 2026-07-02).**
  Lispish uses `{ code }` blocks rather than action-edge fluent continuations. `.7.5.2`
  temporarily restored legacy `scalaref(retv, {content})` parity so the shipped fixture
  could enter the oracle corpus. `SCALAREF-RETIREMENT.3` then migrated that fixture to
  direct nested access, and `SCALAREF-RETIREMENT.4` removed `ScalarRefPath` plus runtime
  helper support. The `lispish_x_y` fixture remains active in the 63-fixture corpus.
- **Child return accumulator containment (`.7.5.2`, LANDED 2026-07-02).** The `.5.1`
  model made `return(expr)` push to the current invocation accumulator and record the
  return channel. `.7.5.2` adds child invocation containment: after child dispatch or
  `call(child)`, child accumulator pushes are truncated from the parent accumulator while
  the child return still feeds `retv` / the call result. Top-level `execute()` still
  returns the accumulator.
- **retv-based inline grammars diverge** because Perl's *inline-spec* `retv` returns
  `undef` (the `.5.2` inline-spec friction) while Rust's retv works — so the more-correct
  Rust disagrees with flaky Perl-inline.
- **Group indexing divergence (`RUST-PARITY.7.2`, FIXED 2026-07-02).** Rust
  numbered capture helpers now match Perl and the mdBook contract:
  `entry_group(0)` / `match_group(0)` = first participating capture, while
  `entry_text()` / `match_text()` read the full match. See
  [[rust-capture-group-helper-indexing]].
- **hlink curly delimiter fixture (`RUST-PARITY.7.3.3.2`, LANDED 2026-07-03).**
  `hlink_curly_brace` (`{abc}`) is active in the generator and checked-in corpus
  with Perl reference value `["{abc}"]`. The 66-fixture corpus oracle passes.

The `.7.1` proof grammars deliberately avoid all of the above (parent→child dispatch with
a literal edge return and an action-less child), so both backends agree exactly.

## Regenerating

```sh
perl tools/gen_oracle_corpus.pl            # default 15s hard per-case build+parse timeout
ORACLE_TIMEOUT=30 perl tools/gen_oracle_corpus.pl
```

The historic `RTLUtils` catastrophic-backtrack timeout is retired with the deleted
legacy VHDL/RTL/FSM subsystem. The process-level guard now covers both parser construction
and parser execution, so future pathological shipped specs cannot wedge corpus generation
while being compiled before their input is parsed.

## Links

- Task tree: [[RUST-PARITY]] / [[SPEC-FORMAT-TERSE]] (leaves `.7.1` oracle, `.7.5.1`
  header-regex fix done; `.7.5.3` action-edge fluent closure reconciled done from
  `SPEC-FORMAT-TERSE.2.3.3.1`; compact lifecycle/body fluent forms landed under
  `SPEC-FORMAT-TERSE.2.3.3.3.1`; action-edge explicit/flow fluent chains landed under
  `SPEC-FORMAT-TERSE.2.3.3.3.2`; tclite retry under `.2.3.3.3.3` split default-mode recursive repetition
  parity, `.2.3.3.3.3.1` landed the two minimal shipped `tclite` fixtures, `.7.5.2`
  temporarily landed the minimal shipped Lispish fixture, and `SCALAREF-RETIREMENT.3/.4`
  migrated it to direct access before removing the legacy helper; `.7.3.2` hardens the oracle timeout path)
- ADR: `docs/decisions/0006-multi-backend-vision.md` (§Phase 8.6 language-neutral corpus)
- Related: [[rust-tclite-default-mode-repetition-gap]], [[rust-retv-propagation]],
  [[rust-lifecycle-i-return-dispatch-parity]], [[rust-edge-semantics-bug]], [[rust-entry-match-separation]]
- Files: `tools/gen_oracle_corpus.pl`, `rust/linkedspec-runtime/tests/corpus_oracle.rs`,
  `rust/linkedspec-runtime/tests/corpus/README.md`
