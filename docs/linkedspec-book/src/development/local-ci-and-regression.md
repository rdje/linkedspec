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

## Optional Dart Gate

The Dart backend has its own focused local gate:

```bash
bash tools/run_dart_local.sh
```

It runs Dart formatting, analyzer checks, the full Dart test suite, Dart CLI help checks, a bounded Dart-specific
CLI corpus smoke, and the full 99-fixture corpus execution. The canonical local gate does not require a Dart SDK by default. When a checkout has
Dart installed and you want one command to include both gates, run:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

## Focused Julia Checks

The Julia backend currently has a package-level gate rather than a shared local-CI integration. From the repository
root, run:

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot julia --project=julia -e 'import Pkg; Pkg.test()'
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot julia --project=julia julia/bin/linkedspec_julia.jl status
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus
```

These checks currently cover package loading, source parsing/validation, function-shell projection, typed ActionIR
parsing, ActionIR contract resolution, user-function registry projection/stitching, compiled-state descriptor
projection, seek/consume runtime regex selection, capture/offset projection, cursor and entry/local match registers,
zero-progress detection, and manifest-backed corpus validation. Julia corpus `--execute` remains unavailable until
the executable interpreter leaves land.

## Hosted GitHub Actions status

Hosted GitHub Actions CI is currently disabled for cost-control reasons.

The workflow file remains tracked because the local CI script audits it as part of the repository's validation surface, but the hosted workflow no longer runs on `push` or `pull_request`. It is left behind `workflow_dispatch` with a disabled job guard, so even an accidental manual dispatch does not spend runner minutes.

To re-enable hosted CI later, restore the `push` and `pull_request` triggers in `.github/workflows/ci.yml`, remove the job-level disabled guard, and run the local gate before pushing the re-enable commit.

## What the local gate checks

`tools/run_ci_local.sh` currently does the following:

- verifies required commands are available: `git`, `perl`, and `prove`,
- verifies required tracked files exist, including `.github/workflows/ci.yml`, `tools/run_ci_local.sh`, `perl/LinkedSpec.pm`, and `t/phase0_regression.t`,
- verifies key tracked input directories are present and non-empty,
- rejects untracked files inside CI input areas,
- audits selected core paths for machine-specific absolute paths,
- runs Perl syntax checks,
- runs the main phase0 regression suite,
- runs `scripts/check_memory_architecture.sh` to verify memory architecture invariants (layer integrity, pointer freshness, bounded-layer consistency),
- runs `knowledge-map/scripts/check_knowledge_map.sh` to verify Knowledge Map integrity (derived map matches source cards, no stale entries),
- runs `scripts/check_diagnosis_evidence.sh` through the doctrine driver; in a pre-commit context this requires
  staged code/spec/test/tooling changes to carry a task-tree acceptance checklist with LinkedSpec-tool evidence
  signatures,
- enforces a RAM usage guard that refuses to run the test suite when system memory utilization exceeds 88%, preventing resource-exhaustion failures from masking real test results,
- optionally runs `tools/run_dart_local.sh` when `LINKEDSPEC_RUN_DART=1` is set.

The command sequence includes:

```bash
perl -c perl/LinkedSpec.pm
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
