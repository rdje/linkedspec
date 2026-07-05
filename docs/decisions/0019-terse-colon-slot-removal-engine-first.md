# 0019 — `:name` removal is engine-first: bare reads are incomplete at the audit commit

- Date: 2026-07-05
- Status: accepted
- Tags: dsl, spec-format-terse, colon-slot, sequencing, engine, cross-variant-parity

## Context

`SPEC-FORMAT-TERSE.15` removes the colon scalar-slot spelling `:name` from the `.spec`
surface. The `.15.1` audit (commit `104088e5`) split the work source-first: `.15.2`
migrate current specs/corpus/docs/KM from `:name` to bare reads, then `.15.3`/`.15.4`
remove `:name` from Perl/Rust. That ordering assumed a bare-for-colon spelling swap is
**output-preserving** at `104088e5` — i.e. that bare identifiers are already read as the
bound variable value everywhere `:name` is.

Executing `.15.2` disproved that assumption. Applying a reviewed `:name`->bare converter
to `specs/*.spec` + `tools/gen_oracle_corpus.pl`, regenerating the oracle corpus, and
reading the byte-identity gate showed real output changes, confirmed by a direct
reference-engine probe:

- `switch(:kind)` -> `'good'` (reads scalar `kind`); `switch(kind)` -> `'def'` (bare
  `kind` is **not** read as the variable). Same class for numeric callees
  (`num_lt(...)`/`num_gt(...)`), `if(...)` conditions, and the second argument of the
  all-bare child-call form `push(A, B)`.
- In `spec.spec`/`ebnf.spec`, a bare name that **collides with a rule/token name**
  (`started`, `top`, `rule`, `on`) resolves as a **rule reference**, not a variable read,
  collapsing the parse (e.g. `spec_spec_minimal_rule` -> `[]`).

So `:name` was doing real work: it disambiguated a *variable read* from a *rule
reference*, and it forced a scalar-value read in positions where bare-read support had not
yet landed. A source-first migration is therefore not clean. Most shipped specs
(`ds_vhistory`, `lib_reader`, `pplugin`, `simenv`, `tablegrep`, `tkgui`, `vhdl`) were
output-preserving, but `spec.spec`, `ebnf.spec`, and the all-bare `push`/`switch`/`while`
fixtures were load-bearing.

The user directed (2026-07-05) that **`:name` shall not be supported** in the end state —
no disambiguation crutch retained.

## Decision

1. **Engine-first.** `.15.2` is re-scoped: complete bare-name value reads across **all**
   value positions on Perl + Rust so `:name` is fully redundant, then migrate sources.
   Children: `.15.2.1` design/inventory, `.15.2.2` Perl engine, `.15.2.3` Rust parity,
   `.15.2.4` source migration (now output-preserving, verified by a byte-identical
   regenerated oracle corpus + green phase0).
2. **Value-position-is-variable policy.** In a value-expression position a bare identifier
   is a variable/parameter read; rule references appear only in edge/dispatch positions
   (`-> Rule`, `call(Rule)`, `=> Rule`, and the all-bare child-call `push(RuleA, AccumB)`
   convention). Scalar push uses `items += value` or `push(array(items), value)`, never a
   colon slot.
3. **Full removal, no compat.** `.15.3` (Perl) and `.15.4` (Rust) then remove `:name`
   parsing/lowering entirely; `:name` in a value position becomes a migration diagnostic.
   `.15.5` closes drift.

## Consequences

- The load-bearing collision cases in `spec.spec`/`ebnf.spec` become migratable only after
  `.15.2.2`/`.15.2.3` make value-position bare reads win over rule references.
- The oracle byte-identity gate (`tools/gen_oracle_corpus.pl` -> `expected.json`) is the
  acceptance proof for `.15.2.4`: zero `expected.json` changes means output-preserving.
- A prior session's uncommitted, intermingled `.15.2/.15.3/.15.4/.8/.9` work (phase0 RED)
  is preserved on branch `recovery/terse-15-uncommitted-20260705`; `main` is clean at
  `104088e5`. That branch is reference-only, not a merge source.
- Baseline at `104088e5`: phase0 1021 pass / 1 pre-existing unrelated failure (test 796,
  `emit_context_lowers_split_tagged_records_helper`, `unresolved_helper_count == 1`).

## Links

- Tree: `docs/tasks/SPEC-FORMAT-TERSE.md` (`.15`, `.15.2.*`, `.15.3`, `.15.4`).
- Knowledge Map card: `docs/knowledge/terse-bare-read-value-position-gap.md`.
- Related: ADR `0007` (terse direction), `0011` (text-to-AST backend doctrine).
