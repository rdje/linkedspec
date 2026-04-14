# Local CI and Regression

LinkedSpec relies heavily on a strong regression gate.

This is not incidental. LinkedSpec is being refactored while it remains a working dynamic parser system. The local gate is what lets the project change internal architecture without quietly breaking shipped specs, diagnostics contracts, or helper-DSL lowering semantics.

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
- runs the main phase0 regression suite.

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
- `plugin`
- `conf`
- `tablescript`
- `ebnf`
- `perl`
- `t`

Untracked files in those areas fail the gate.

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
- corpus regression checks over `plugin/`, `conf/`, `tablescript/`, and `ebnf/`,
- trace and runtime-context checks.

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
