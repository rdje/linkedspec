# Local CI and Regression

LinkedSpec relies heavily on a strong regression gate.

This is not incidental. LinkedSpec is being refactored while it remains a working dynamic parser system. The local gate is what lets the project change internal architecture without quietly breaking shipped specs, diagnostics contracts, or helper-DSL lowering semantics.

> **Perl reference implementation.** This chapter describes the **Perl reference
> backend's** CI and regression gate (`perl -c`, `t/phase0_regression.t`,
> `tools/run_ci_local.sh`). A backend in another language has its own build/test gate,
> but every backend must pass the shared, language-neutral test corpus that defines
> `.spec` compliance (see [Backend Handoff](../appendix/backend-handoff.md)).

## Main local gate

Run:

```bash
bash tools/run_ci_local.sh
```

This is the canonical regression gate for local development.

The GitHub workflow is intentionally kept as a thin wrapper around the same command:

```text
.github/workflows/ci.yml
  -> bash tools/run_ci_local.sh
```

That means local validation and hosted validation are intentionally not two separate systems when hosted CI is enabled.

## Primary CLI conformance fixtures

The primary command has a separate backend-neutral, byte-exact fixture runner:

```bash
PERL5LIB= perl tools/run_cli_conformance.pl \
  --display-command 'perl bin/linkedspec' \
  -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
```

`cli_conformance/manifest.json` is data, not a Perl-only test table. The runner accepts an arbitrary command array,
creates one isolated workspace per case, materializes checked-in inputs, captures raw stdout/stderr separately, and
compares exact channel bytes, exit status, and expected generated files. `{{COMMAND}}` represents the only allowed
help/diagnostic difference: the backend executable token or unavoidable host launch wrapper. `{{REPO_ROOT}}`,
`{{WORKSPACE}}`, and `{{CASE_ID}}` represent exact runner inputs rather than backend-specific expected results.

The suite locks both help forms, 20 strict usage cases, seven baseline success cases, four baseline operational
failures, 20 canonical trace cases, and eight strict UTF-8 behavior cases on Perl. All 61 pass with
`POSIXLY_CORRECT` unset or set. ADR `0024` trace cases cover exact
UTF-8 phase records, stdout/route/mirror, reset/persistence/append, levels/aliases, emoji, byte counts, field
escaping, and all failure phases. The canonical local gate invokes this same runner in both environments.
ADR `0025` defines Unicode scalar text encoded as strict preserved UTF-8 at process/file boundaries. `.6.2`
now decodes Perl argv/files, emits recursive UTF-8 JSON once, and locks inline/file Unicode, normalization
preservation, input BOM/newlines, non-stripped source BOM, invalid phases, and trace byte counts. `.6.3` closes
the reference. Rust `.1.5.2.4` closes reusable direct execution plus the exact canonical trace projection at all
61 unchanged cases in both option environments. UTF-16/UTF-32 are not implicit inputs.

Schema version 1 workspace inputs use `path` plus exactly one checked-in `source`
or explicit `bytes_hex`. Hex data is non-empty, lowercase, and even-length, and is
materialized raw; this makes invalid UTF-8 cases reviewable without binary blobs.

## Four-Backend Primary CLI Matrix

Run the complete exact-interface proof from the repository root:

```bash
bash tools/run_primary_cli_matrix.sh
```

The driver checks all toolchains, builds Rust, prepares and warms Dart, warms the normal Julia project, and runs
the same unchanged 61-case manifest against Perl, Rust, Dart, and Julia with `POSIXLY_CORRECT` unset and set. A
green run is therefore 4 backends x 2 environments x 61 cases; only the executable command token changes. This
recurring proof closes `FUTURE-PARITY-BACKLOG.1.5` exact primary CLI parity.

The core gate remains toolchain-independent by default. On a machine with all backends installed, include the
matrix explicitly:

```bash
LINKEDSPEC_RUN_CLI_MATRIX=1 bash tools/run_ci_local.sh
```

The admitted punctuation-light syntax has a narrower composed matrix that also includes PUC Lua and LuaJIT:

```bash
bash tools/check_punctuation_light_five_backend.sh
# or as an optional local-CI leg
LINKEDSPEC_RUN_PUNCTUATION_MATRIX=1 bash tools/run_ci_local.sh
```

## Capability Census Gate

The exact CLI and interpreter corpus are necessary but do not enumerate every public API and mdBook contract.
Validate the machine-readable broader census with:

```bash
perl tools/check_capability_conformance.pl
```

`capability_conformance/manifest.json` currently contains 16 capabilities and 64 backend states: all 64 pass.
Every evidence path must exist, and legacy/future exclusions remain explicit and task-owned. The canonical local
gate runs this check before focused suites. The 60/0/0 generated-source milestone is historical; punctuation-light
admission `.16.7` adds the four current passing states.

The file-oriented native API has a separate executable resolution/loading contract:

```bash
perl tools/check_native_spec_resolution_contract.pl
```

It validates the versioned schema plus 14 portable name cases, nine deterministic path-precedence/file-kind cases,
and four strict UTF-8 preservation/rejection cases before backend-specific consumers run. The canonical core gate
also requires `prove -Iperl t/native_spec_resolution.t`, which consumes the same fixture through Perl's public
portable facade; Rust, Dart, and Julia consume it in their focused package gates.

The same gate also enforces exhaustive current ActionIR coverage:

```bash
perl tools/check_language_capability_coverage.pl
```

That checker requires exact Dart/Julia/Lua inventory identity at 246 current names, occurrence across the mdBook
and governed 105-case corpus plus exact named-mark fixture, every one of 122 independently derived public Perl
contracts in each backend inventory, and rejection of nine classified non-public names.

## Focused Rust Gate

Run the repo-owned Rust gate from the repository root:

```bash
bash tools/run_rust_local.sh
```

It checks formatting, runs the complete `linkedspec-runtime` package (including the 105-fixture interpreter oracle,
generated-source subset, and native trace controls), builds `linkedspec-rust`, then runs all 61 primary-command
fixtures with `POSIXLY_CORRECT` unset and set. Override Cargo or its target directory with
`LINKEDSPEC_CARGO_CMD` or `CARGO_TARGET_DIR` when needed.

The canonical shared gate does not require a Rust toolchain by default. Opt in on a Rust-capable checkout:

```bash
LINKEDSPEC_RUN_RUST=1 bash tools/run_ci_local.sh
```

## Optional Dart Gate

The Dart backend has its own focused local gate:

```bash
bash tools/run_dart_local.sh
```

It runs Dart formatting, analyzer checks, all 151 Dart tests, shared primary-CLI help,
a bounded corpus-runner smoke, all 61 primary cases in default and POSIX environments, and the full 105-fixture
corpus execution. The separate corpus runner remains the 105-fixture owner. `FUTURE-PARITY-BACKLOG.1.5.3.4`
closes this recurring gate and Dart primary-command no-drift. The canonical local
gate does not require a Dart SDK by default. When a checkout has
Dart installed and you want one command to include both gates, run:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

## Focused Julia Gate

Run the repo-owned focused gate from the repository root:

```bash
bash tools/run_julia_local.sh
```

It runs `Pkg.test()`, the nine-family `tools/check_julia_primary_cli.sh` real-process checker, corpus-runner help,
and the complete 105-fixture corpus. The Julia
executable and depot are configurable:

```bash
LINKEDSPEC_JULIA_CMD=/path/to/julia \
LINKEDSPEC_JULIA_DEPOT_PATH=/path/to/depot \
bash tools/run_julia_local.sh
```

The canonical shared gate does not require Julia by default. Opt in explicitly on a Julia-capable checkout:

```bash
LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

These checks currently cover package loading, source parsing/validation, function-shell projection, typed ActionIR
parsing, ActionIR contract resolution, user-function registry projection/stitching, compiled-state descriptor
projection, seek/consume runtime regex selection, capture/offset projection, cursor and entry/local match registers,
zero-progress detection, first default/AND/OR/repetition dispatch, lifecycle and child-edge flow, narrow
accumulators/returns, recursion/progress guards, registered user functions, diagnostics/tracing, boundary capture,
manifest-backed corpus validation, controlled and full library corpus execution, public-parser leading-trivia
parity, spec-driven top-level user-function source composition, native primary request execution/canonical JSON,
stable primary failure/trace routing, and unbounded full-manifest CLI execution. The full package suite currently
passes with 1,023 assertions and status `runtime-corpus-primary-cli`. `.1.5.4.1` updates exact help/errors and adds
strict UTF-8 coverage; `.1.5.4.2` switches only primary trace to the independent canonical projection. Julia now
passes 61/61 default/POSIX, while separate package tests continue to exercise rich native trace.

The library executor and corpus CLI support named or bounded subsets. For example:

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --case proof_edge_array_literal
```

Validation-only loading remains the default. Adding `--execute` without selectors runs the complete validated
manifest and passes 105/105; `--case`, `--offset`, and `--limit` remain available for diagnostics. The permanent
aggregate regression locks manifest order, endpoints, 99 passes, zero failures, and exact output for every fixture.

### Cleaning generated build caches

Julia's generated precompile output lives in depot `compiled/` directories, not in a project-local Rust-style
target directory. When disk space is tight and no Cargo, mdBook, or Julia job is running, these are rebuildable
cleanup targets:

```bash
rm -rf rust/target
rm -rf docs/linkedspec-book/book
rm -rf /private/tmp/linkedspec-julia-depot/compiled
rm -rf ~/.julia/compiled
```

Remove only Julia's `compiled/` cache, never the whole depot. Preserve `packages/`, `registries/`, `environments/`,
`logs/`, `scratchspaces/`, `artifacts/`, project manifests, source, and fixture data.
`tools/run_julia_local.sh` prints its resolved depot path; apply the same `compiled/`-only rule there when the
configured/default depot differs from the examples above.

Large generation logs under `/private/tmp` need a stricter check: inspect the file header to prove it came from a
completed LinkedSpec/RGX run and confirm no process still has it open before deleting that exact file. Never
blanket-delete `/private/tmp`; it may contain agent state, application IPC, or another project's active test data.

The bounded command `--execute --offset 68 --limit 31` now passes 31/31. Anonymous capture, logical/output helper,
recursive top-rule, structural child-push, statement mutation, and public-parser leading-trivia leaves closed each
independent mechanism. `.6.2.4.6` now permanently runs that full window and locks its counts, endpoints, zero
failures, and exact outputs. Julia has since closed the routed top-level function fixtures under `.6.2.5` and the
complete 99/99 manifest gate under `.6.3`; `.6.4` has since added the focused gate and optional shared-CI wiring.

## Hosted GitHub Actions status

Hosted GitHub Actions CI is currently disabled for cost-control reasons.

The workflow file remains tracked because the local CI script audits it as part of the repository's validation surface, but the hosted workflow no longer runs on `push` or `pull_request`. It is left behind `workflow_dispatch` with a disabled job guard, so even an accidental manual dispatch does not spend runner minutes.

To re-enable hosted CI later, restore the `push` and `pull_request` triggers in `.github/workflows/ci.yml`, remove the job-level disabled guard, and run the local gate before pushing the re-enable commit.

## What the local gate checks

`tools/run_ci_local.sh` currently does the following:

- verifies required commands are available: `git`, `perl`, and `prove`,
- verifies required tracked files exist, including the primary CLI, neutral manifest/runner/tests, local gate,
  `perl/LinkedSpec.pm`, and `t/phase0_regression.t`,
- verifies key tracked input directories are present and non-empty,
- rejects untracked files inside CI input areas,
- audits selected core paths for machine-specific absolute paths,
- runs Perl syntax checks for the library, primary CLI, neutral runner, and focused tests,
- validates the machine-readable capability census, backend evidence paths, and task ownership,
- runs the focused runner/trace suites and all 61 primary CLI cases under default and POSIX option environments,
- runs the main phase0 regression suite,
- runs `scripts/check_memory_architecture.sh` to verify memory architecture invariants (layer integrity, pointer freshness, bounded-layer consistency),
- runs `knowledge-map/scripts/check_knowledge_map.sh` to verify Knowledge Map integrity (derived map matches source cards, no stale entries),
- runs `scripts/check_diagnosis_evidence.sh` through the doctrine driver; in a pre-commit context this requires
  staged code/spec/test/tooling changes to carry a task-tree acceptance checklist with LinkedSpec-tool evidence
  signatures,
- enforces a RAM usage guard that refuses to run the test suite when system memory utilization exceeds 88%, preventing resource-exhaustion failures from masking real test results,
- optionally runs `tools/run_dart_local.sh` when `LINKEDSPEC_RUN_DART=1` is set,
- optionally runs `tools/run_julia_local.sh` when `LINKEDSPEC_RUN_JULIA=1` is set,
- optionally runs the complete warmed four-backend primary CLI matrix when `LINKEDSPEC_RUN_CLI_MATRIX=1` is set.

The command sequence includes:

```bash
perl -c perl/LinkedSpec.pm
perl -c bin/linkedspec
perl -c tools/run_cli_conformance.pl
PERL5LIB= prove -Iperl t/cli_conformance_runner.t t/trace_cli.t
PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- \
  perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
perl -c -Iperl t/phase0_regression.t
prove -v -Iperl t/phase0_regression.t
```

## CI input areas

The local gate treats these as CI inputs:

- `.github/workflows`
- `tools`
- `specs`
- `conf`
- `tablescript`
- `ebnf`
- `perl`
- `t`

Untracked files in those areas fail the gate.

The former root `plugin/` corpus is intentionally not a CI input area. Its surviving `.plg` files were relocated to
`noncore/plugin/`, outside the core local gate.

That rule is deliberate. A local untracked file in `specs/`, `perl/`, or a corpus directory can make tests pass locally while CI fails or, worse, can hide a missing fixture. The gate forces those inputs to be tracked and reviewable.

## Why the regression discipline is important

This project is changing internals aggressively:

- naming cleanup
- compiler-state refactors
- diagnostics tightening
- helper-surface evolution

The regression suite is what makes that sustainable.

It protects behavior across:

- public facade APIs such as `Get(...)` and `get_parser(...)`,
- parser-factory resolution and file loading,
- runtime context and structured diagnostics,
- compiler pipeline stage contracts,
- compiled descriptor state and dependency-regex validation,
- generated handler dispatch,
- ActionIR helper scanning and lowering,
- shipped `.spec` behavior,
- corpus parsing over legacy and real-project inputs.

## Task-tree ownership requirement

All code changes must be task-tree tracked or task-tree owned before they are made.

This is not a guideline. It is a hard, non-negotiable requirement:

- Every code change belongs to a specific task-tree leaf with a stable `TREE.N.N` identifier.
- A leaf must exist in the active task tree before implementation begins.
- Commit messages must carry the leaf identifier for traceability.
- If a change does not fit an existing leaf, split the leaf or create a new one before writing code.

For staged code/spec/test/tooling changes, the doctrine gate also requires the owning task file to carry the
task-acceptance checklist from `TOOLBOX.md`. The checklist records the reproduction/issue, root cause, fix,
verification, no-regression evidence, and lockstep documentation state.

If that check fires unexpectedly, inspect the staged set with `git diff --cached --name-only`. The intended
fix is to unstage unrelated governed files, stage/update the owning task-tree checklist, or split the work into
a smaller leaf. The check is intentionally narrow: it does not audit historical task files and does not re-run
commands copied into Markdown. The actual proof remains the focused validation recorded in the task leaf plus
the local CI gate.

The task-tree workflow (`docs/TASK_TREE.md`) and per-phase tree files (`docs/tasks/<TREE>.md`) are the authoritative record of what leaf owns what work.

Task-tree ownership improves code quality by ensuring every change traces back to a documented intent with acceptance criteria. It enables interruption-safe recovery from task-tree state, prevents orphan changes that drift from the roadmap, and gives `git log --grep` on leaf IDs a complete ordered history of every leaf.

This requirement applies to all implementation, refactoring, bug-fix, and migration work. Documentation-only changes that do not touch code may reference a documentation-phase leaf but are not required to create a new leaf for small fixes.

When in doubt, create the leaf first.

## Important test surface

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

## Documentation-only changes

For book-only slices, the full phase0 gate is often not necessary.

Use the documentation gate:

```bash
git diff --check
mdbook build docs/linkedspec-book
```

`git diff --check` catches whitespace problems that should not enter the repo.

`mdbook build docs/linkedspec-book` proves the public book still builds.

If a documentation slice touches examples that depend on behavior, inspect the relevant source or tests as needed. If a documentation slice changes commands, public API examples, or documented behavior, run the relevant code/test gate too.

## Code or spec changes

For implementation, `.spec`, or regression changes, prefer the shared local CI gate:

```bash
bash tools/run_ci_local.sh
```

For a small syntax-only Perl change, at minimum run the focused syntax checks:

```bash
perl -c perl/LinkedSpec.pm
perl -c -Iperl t/phase0_regression.t
```

But before committing a real behavior change, run the full local gate unless there is a clear reason not to and the limitation is recorded.

## How to interpret failures

Read failures by owner and surface:

- A syntax failure in `perl/LinkedSpec.pm` means the facade or an eagerly loaded dependency is broken.
- A syntax failure in `t/phase0_regression.t` means the regression lock itself is malformed.
- A failure in shipped-spec helper-flow checks usually means ActionIR/lowering migration behavior changed.
- A descriptor metadata failure usually means compiler state, migration summary, or descriptor projection changed.
- A corpus failure usually means a parser change broke a realistic input class.
- An untracked CI input failure usually means a file was added locally but not staged/tracked.

When in doubt, preserve the failing test output and debug from the narrowest failing owner upward.

## Developer rule of thumb

Use this compact rule:

```text
docs-only change:
  git diff --check
  mdbook build docs/linkedspec-book

code/spec/runtime change:
  bash tools/run_ci_local.sh
```

If a code/spec/runtime change also changes public understanding, update the public book and run the book build too.
