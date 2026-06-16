# Output-oracle test corpus (`RUST-PARITY.7`)

A **language-neutral** parity corpus (ADR 0006 §Phase 8.6). The Perl reference is
the behavioral oracle; this corpus is its frozen output. Every LinkedSpec backend
validates against the same fixtures, so a backend is "compliant" when it
reproduces the reference value for every entry.

## Entry layout

One directory per case:

```
<case>/
  input.spec    — the .spec source (copied verbatim from specs/<spec>.spec)
  input.txt     — the exact input bytes fed to the parser
  expected.json — canonical JSON of the reference (Perl) top-rule value
```

`expected.json` is canonicalized with `JSON::PP->canonical(1)` (object keys
sorted), so regenerating an unchanged case is byte-stable — no spurious diffs.

## Output-shape rule (Perl ↔ Rust)

`expected.json` holds the **backend-neutral reference value**: the Perl reference
returns the top rule's value *directly* (e.g. tclite on `[]` →
`["?tcl_script:",[["?command_subst:",[]]]]`). Each backend applies its own known
output-shape mapping when comparing:

- **Perl reference:** identity — output equals `expected.json`.
- **Rust engine:** `Engine::execute` wraps the accumulator one level (it returns
  `Array(accumulator)`), so its output is `[ <expected> ]`. The Rust fixture
  runner (`../corpus_oracle.rs`) compares `engine.execute(input) == [expected]`.

## Regenerating

```sh
perl tools/gen_oracle_corpus.pl            # default 15s per-parse timeout
ORACLE_TIMEOUT=30 perl tools/gen_oracle_corpus.pl
```

The generator runs every oracle parse under a hard `alarm(...)` timeout so a
pathological grammar (e.g. the known RTLUtils catastrophic-backtrack hang) cannot
wedge corpus generation. The case list lives at the top of
`tools/gen_oracle_corpus.pl`; `.7.2`/`.7.3` extend it, `.7.4` adds the
enumerate-all-fixtures drift guard.
