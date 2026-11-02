# Regression Fixtures

## Phase 0 regression spine

The main regression spine is:

```text
t/phase0_regression.t
```

That file is large because it is doing real work: protecting runtime behavior, compiler contracts, shipped specs, and migration slices.

The test file includes several kinds of checks:

- direct unit-style checks for helper/lowering seams,
- descriptor introspection checks for metadata and migration summaries,
- source-level checks that shipped specs use preferred helper DSL forms,
- smoke checks for selected shipped parsers,
- corpus regression checks over `conf/`, `tablescript/`, and `ebnf/`; the former root `plugin/` corpus was relocated
  to `noncore/` and no longer participates in the core gate,
- trace and runtime-context checks.

### Validation fuzzing harness

A dedicated validation fuzzing harness exists at:

```text
t/phase0_validation_fuzz.t
```

This test uses systematic edge-case generation (combinatorial, boundary, and
malformed-input patterns) across the main Validation.pm surfaces:

- `_parse_rule_label_line` — rule label parsing (~60+ edge cases)
- `_scan_rule_edges_in_fragment` — edge scanning with depth tracking (~20+ cases)
- `validate_spec_content` — envelope validation (15 cases)
- `validate_dsl_syntax` — full DSL syntax validation (~10+ cases)
- combinatorial rule label fuzzing (168 generated combinations)

Run it with:

```bash
prove -v -Iperl t/phase0_validation_fuzz.t
```

## Legacy discovery regression isolation

Phase 0 runs `t/legacy_pathsearch_fallback.t` in a fresh Perl process. It copies the
unchanged `PathSearch.pm` into a small consumer tree and uses the checkout's real
`LinkedSpec::get_parser` resolver and compiler. The test checks a nested fallback
hit, the exact parser result, a missing-name warning, explicit-path bypass and
process-local discovery caching. An unrelated tree containing 1,024 directories
and a matching decoy is excluded from discovery, and the fixture is removed.

This keeps verification independent of retained build/cache size. It does not
change legacy production discovery: a cold bare-name miss can still recursively
scan its module checkout. New integrations should use the explicit ordered roots
of `LinkedSpec::SpecLoader`, described in the public API chapter.

```bash
env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/legacy_pathsearch_fallback.t
```

See [Local CI and Regression](local-ci-and-regression.md#verification-tiers) for verification tiers and gate composition.

## Retained rejected-source diagnostics

A historical diagnostic can deliberately contain language that the current compiler
rejects. Keep the original producer and failure channels so the observation remains
reproducible. The executable-source retirement scan classifies the two retained
pipeline diagnosis artifacts by exact repository-relative path and full SHA-256
identity. This preserves the rejected experiment and its historical description.
An edited artifact, copied source or added selector remains a positive candidate;
the existing untracked-discovery and concurrent-scan checks still run. This
classification grants no authoring compatibility or executable admission.

## Behavior checks across lowering changes

Compiler output can add materialized receiver values or endpoint guards without
changing the language contract. Keep source checks for public structure and
readiness, and execute the emitted expression when checking its result:

- `capture_from(name)` reads the rule-local mark; an absent or reversed local
  endpoint returns no value, while a valid empty span remains an empty string.
- `capture_slice_len()` distinguishes an unavailable boundary from a valid zero.
- `3.5.floor().add(0.75)` returns `3.75`. This fractional addition distinguishes
  floor-before-add from a reversed chain, which would return `4`.
- `(items += value).count()` appends once, returns the new count, and leaves an
  earlier aggregate snapshot unchanged. A block receiver's effects also run once.

The six Phase0 calibrations owned by `TYPE-REFERENCE-BOOK.1.2.20.1.21` retain every
other assertion, all top-level test identities and the descriptor readiness
checks. Their retained probes compare native execution with freshly emitted
programs and show the new assertions rejecting lost guards, wrong values,
reversed numeric order and a count result that skips the mutation.

Historical evidence keeps the committed activation fixture separately. A pinned
table restores exactly those six assertion edits before the original committed
image and predecessor checks. It reports the actual current fixture hash as a
separate source stage; it does not refresh old hashes or claim a new runtime
admission from historical results. Complete canonical CI and normal commit hooks
remain the landing requirements.
