---
id: rust-working-vars-auto-vivify
title: Rust working variables use fresh per-parse stores, auto-vivify on write and retain explicit invocation scoping
answers:
  - "does the Rust variant need declare for working variables"
  - "do working variables auto-exist in the Rust backend"
  - "how does the Rust runtime store working variables"
  - "did SPEC-FORMAT-TERSE.1.1.2 require a Rust engine change"
  - "how is auto-existing variables (SPEC-FORMAT-TERSE.1.1.2) implemented/proven on Rust"
  - "can a Rust working variable leak across parser invocations or parses"
  - "what does declare do in the Rust runtime"
  - "why does the Perl auto-existing-variable codegen fix not apply to Rust"
  - "how is cross-variant auto-existence parity proven (oracle fixtures autoexist_*)"
  - "why do the recursive Perl .1.1.1 auto-exist lock specs fail on Rust"
  - "does Rust auto-vivify isolate undeclared recursive accumulators"
date: 2026-09-07
status: confirmed
tags: [rust, runtime, variables, declare, spec-format-terse, SPEC-FORMAT-TERSE, RUST-PARITY, cross-variant-parity]
evidence: "SPEC-FORMAT-TERSE.1.1.2 (2026-06-24). rust/linkedspec-runtime/src/runtime.rs: RuntimeContext holds scalars/arrays/hashes HashMaps; set_scalar = scalars.insert (unconditional), push_value = arrays.entry().or_default().push, set_hash_entry = hashes.entry().or_default; get_scalar/get_array/get_hash return Undef/empty when absent; declare_scalar/declare_array/declare_hash just pre-seed an entry (declare_scalar_with seeds an =init value). rust/linkedspec-runtime/src/engine.rs Engine::execute = `let mut ctx = RuntimeContext::new(input)` per call (fresh store per parse). Throwaway Rust + `perl -Iperl` LinkedSpec::Get probes on the same divergence-free edge-action grammars: scalar no-declare Perl \"ok\"/Rust [\"ok\"]; array no-declare Perl [\"a\",\"b\"]/Rust [[\"a\",\"b\"]]; declare twins identical; array(undef) Perl [null]/Rust [[null]] (Rust = Perl reference wrapped one level, the .7.1 output-shape rule). Locked: 5 oracle fixtures autoexist_* (tools/gen_oracle_corpus.pl) + 4 terse_1_1_2_* integration tests. cargo 244->248 green; 7/7 oracle fixtures PASS; clippy zero-new; phase0 968 green (Perl untouched). The recursive/REP auto-exist idiom the Perl phase0 locks use (top:: ... -> top[0]; Top::*) returns [null]/[[]] on Rust = the separately-owned RUST-PARITY recursive-grammar/REP-lifecycle gap, NOT auto-existence."
evidence_update_2026_07_07: "SPEC-FORMAT-TERSE.8.4 retired Rust `declare(...)` successful execution after explicit aggregate reset targets such as `set(array(items), [])` gained the recursive rule-local binding behavior needed to replace scoped declarations. `declare(...)` now emits `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:declare`; the auto-vivify/fresh-per-parse facts remain current."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test uniform_binding_contract && bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py"
---

# Rust variant: working variables auto-vivify (no `declare` needed)

**Confirmed 2026-06-24 (SPEC-FORMAT-TERSE.1.1.2 — Rust lockstep parity for auto-existing
variables).** The companion of the Perl-side card
[[working-vars-no-strict-need-my-lexical]], which explains why the *Perl* reference needed
an engine change for `.1.1.1`. The Rust variant needed **none**.

## Why no engine change

Perl generates handler source and `eval`s it; that source runs **non-strict**, so an
undeclared wrapper-referenced working variable would silently become a **leaky package
global** (state-leaks across invocations/recursion). `.1.1.1` fixed that by auto-injecting
a per-invocation `my` in the handler preamble.

The Rust native engine **interprets compiled plans**. Generated carriers also use the shared runtime;
the historical no-codegen wording did not describe those later carriers. Working variables
live in three `HashMap`s on `RuntimeContext` (`rust/linkedspec-runtime/src/runtime.rs`):

- **writes auto-vivify** — `set_scalar` = `scalars.insert(...)` (unconditional);
  `push_value` = `arrays.entry(name).or_default().push(...)`; `set_hash_entry` =
  `hashes.entry(name).or_default()`.
- **reads are total** — `get_scalar`/`get_array`/`get_hash` return `Undef`/empty when the
  name is absent (no error).
- **Historically, `declare(...)` pre-seeded an entry** (`declare_scalar`/`declare_array`/
  `declare_hash`); `declare(scalar, x=expr)` seeds an initializer via
  `declare_scalar_with`. Current Rust no longer executes source-spelled `declare(...)`; it diagnoses it as retired.

Those historical wrapper probes established auto-existence without `declare`. Current bare bindings preserve
that behavior; exact aggregate selectors and source-spelled declarations have since retired. `Engine::execute` builds a **fresh
`RuntimeContext` per call** (`let mut ctx = RuntimeContext::new(input)`), so a value can
never leak across parses — the Rust analogue of Perl's per-invocation `my` lexical. The
hazard the Perl change fixed simply does not exist here; adding a "collector" to mirror it
would be dead ceremony, not parity.

## How parity was proven (cross-variant, divergence-free)

Ran the same minimal grammars on **both** backends in the divergence-free edge-action form
(the `corpus_oracle.rs` `.7.1` proof class — non-recursive `Parent:: /re/ -> Child { ... }`,
value set by the edge's own `return(...)`, action-less child). Rust output equals the Perl
reference value wrapped one level (the documented Perl↔Rust output-shape rule):

| case | Perl | Rust |
|---|---|---|
| scalar, no declare | `"ok"` | `["ok"]` |
| scalar, declare | `"ok"` | `["ok"]` |
| array, no declare | `["a","b"]` | `[["a","b"]]` |
| array, declare | `["a","b"]` | `[["a","b"]]` |
| `array(undef)` literal | `[null]` | `[[null]]` |

Locked by **5 oracle fixtures** `autoexist_{scalar,array}_{no_declare,declare}` +
`autoexist_undef_literal` (`tools/gen_oracle_corpus.pl` → `corpus_oracle.rs` checks
Rust == Perl reference) and **4 integration tests** `terse_1_1_2_*` (value anchors,
declare/no-declare convergence, per-parse no-leak via same-engine re-run).

## What is NOT covered (recursive accumulator isolation)

The recursive/REP auto-exist idiom the **Perl** `.1.1.1` phase0 locks use
(`top:: /(\w+)\s*/ -> top[0] { ... }` and `Top::*` REP) does **not** reproduce on Rust —
those exact specs return `[null]` / `[[]]`. That is the **separately-owned `RUST-PARITY`
recursive-grammar / REP-lifecycle gap** (the same general value-parity gap as
`TOP-RULE-AS-NORMAL.3.2`), **not** an auto-existence problem: the non-recursive
equivalents are at full parity.

`TOP-RULE-AS-NORMAL.3.2` later fixed recursive value parity for declared working
variables. `SPEC-FORMAT-TERSE.8.4` then closed the replacement gap: `set(array(items), [])`
now records the same rule-local aggregate binding before mutation, so current Rust no
longer needs `declare(...)` as the recursive accumulator isolation mechanism.

## Links

- Task tree: [[SPEC-FORMAT-TERSE]] (leaf `.1.1.2`; `.1.1` container).
- Perl-side companion: [[working-vars-no-strict-need-my-lexical]] (`.1.1.1`).
- Decisions: [0006](../decisions/0006-multi-backend-vision.md) (lockstep parity),
  [0007](../decisions/0007-spec-format-terse-direction.md) (terse direction).
- Output-shape rule + oracle: [[rust-perl-output-oracle]] ([[RUST-PARITY]] `.7.1`).
- Deferred recursive-grammar value parity: [[RUST-PARITY]] (`.3.2` / `.7.x`).

## 2026-09-07 current private store boundary

`SESSION-STARTUP-READING.3.3.29` reads scalar/array/hash accessors through runtime.rs 2318.
Writes ensure an invocation-local binding identity and update the bare-kind tag; reads clone their stored
values or return Undef/empty. Declaration/scoped entry allocate a replacement identity, while restoration
internals remain the next reading window. These host methods do not re-enable retired source-spelled declare.
The historical output-shape/declare probes above remain dated; current neutral binding proof passes
11 migrations/7 executions/6 invalid selectors/8 constructors. No native corpus rerun is claimed.
