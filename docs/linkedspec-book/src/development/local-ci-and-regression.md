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

The suite currently locks both help forms, 20 strict usage cases, eleven success cases, four baseline operational
failures, 20 canonical trace cases, and eight strict UTF-8 behavior cases on Perl. All 65 pass with
`POSIXLY_CORRECT` unset or set. ADR `0024` trace cases cover exact
UTF-8 phase records, stdout/route/mirror, reset/persistence/append, levels/aliases, emoji, byte counts, field
escaping, and all failure phases. The canonical local gate invokes this same runner in both environments.
ADR `0025` defines Unicode scalar text encoded as strict preserved UTF-8 at process/file boundaries. `.6.2`
now decodes Perl argv/files, emits recursive UTF-8 JSON once, and locks inline/file Unicode, normalization
preservation, input BOM/newlines, non-stripped source BOM, invalid phases, and trace byte counts. `.6.3` closes
the reference. Rust `.1.5.2.4` historically closed reusable direct execution plus the then-current 61-case
canonical trace projection. During the rule-local cursor migration, Perl established the 63-case reference bytes
and Rust later passed them unchanged in both environments after `.9.1.4.6`. Root-selection admission advances the
shared manifest reference-first to 65 cases. Perl owns the reference bytes; Rust core/routes/admission `.2.1-.3`
and Dart `.3.1-.3` now pass them exactly at 65/65 in both environments. Julia core `.4.1` passes the root-owned
cases, route `.4.2` passes its 57-assertion composed proof, cursor `.9.1.6.5` makes the shared command 65/65 twice,
and root admission `.4.3` topology-locks that complete boundary. Lua
leaf `.5` owns its migration.
`tools/run_rust_local.sh` and `tools/run_dart_local.sh` are
green against the expanded manifest. UTF-16/UTF-32 are not
implicit inputs.

Julia core `.9.1.1.2.4.1` improved the expanded manifest from its 31/65 preflight to 32/65 in each environment by
closing the sole root-owned markerless compilation case. Cursor `.9.1.6.5` then removes the identical 22 help/
usage and 11 medium-or-higher request-trace failures. Julia now passes 65/65 twice; cursor admission `.6` closes
its cursor topology requirement, and root admission `.4.3` closes the separate root topology requirement through
137 focused assertions.

Lua behavior-free preflight `.9.1.1.2.5.0` runs the same shared manifest through disposable native adapters. PUC
Lua and LuaJIT are identical with `POSIXLY_CORRECT` unset and set: 31/65 in every leg. Only
`success_markerless_first_authored_rule` belongs to root selection; 22 help/usage and 11 request-trace mismatches
belong to cursor `.9.1.7`. Complete package execution is 176 passing groups plus one cursor help failure per ABI,
and corpus execution is 105/105 per ABI. Root core `.5.1` should improve only that single root row to 32/65;
routes `.5.2` preserve generated v1 identity, cursor `.9.1.7` owns the remaining 33, and topology admission `.5.3`
requires both tracks. Hand-authored selection fixtures use `I`; fixed shared request-trace bytes retain `E`.

Route leaf `.4.2` signs off with its 57 focused assertions, core 79, loader 82, emitter 59, corpus 105, root
governance 4/7 plus 34 rejected mutations, and the canonical Phase-0 total of 1,031 tests. It deliberately does
not advance Julia's rollout row. Cursor implementation and admission have since removed the 33 option/trace
mismatches and locked the complete cursor topology. Root topology admission `.4.3` now adds one exact 15-role
consumer, raises governance to 5/7 plus 39 rejected mutations, and passes package 3,428, primary 65x2, and corpus
105 without changing semantic owners. Canonical CI then passes root consumers 7+5, cursor admission 288, the
reference primary 65x2, and Phase 0 1,031/1,031 in 616 seconds.

Task dependencies preserve backend order around that root work. Dart's composed cursor admission `.9.1.5.6`
locks one exact 15-role consumer, advances only Dart from 3/5 to 4/4, and closes `.9.1.5` after package 271,
primary 65x2, and corpus 105. It is cleanly committed at `7aa9c578`; with Julia root routes already committed,
both cursor dependencies are satisfied and behavior-free Julia preflight `.9.1.6.0` is verified; its clean commit
precedes `.1-.6`.
That preflight parses all 36 neutral headers but finds current family classification at 34/36 because Julia still
treats compact `|` as AND. All engines store global seek; bare-edge parsing is 3 action / 3 blind / 1 lifecycle /
11 raw, with no exact portable result across the seven edge/edge-set error rows and silent acceptance of indexed
blind syntax. Exact mixed-family execution agrees on 5/8 rows and the two structural replacements on 1/2.
Descriptor state is still global-mode, generated source is v1, package execution reaches 56/57, shared primary is
32/65 twice, corpus is 105/105, and cursor governance remains 67 files / 4 complete / 4 pending / 39 mutations.
No executable behavior changes in `.0`; `.1-.6` isolate old v1 semantics until the generated-v2 leaf owns the bump.

Rust, Dart, and Julia root-selection admissions are omission-sensitive. The neutral contract declares one 15-role
consumer per backend over selection/failure/strict rows plus native, loaded/reconstructed, generated/emitted,
descriptor, diagnostic, trace, and primary routes. Its checker requires one exact function marker per role, the
six shared root-selection/request-trace primary case identities, each tracked canonical input, the complete
backend-package driver, and optional canonical registration. Julia additionally locks inclusion from
`julia/test/runtests.jl`; 39 mutations reject semantic, topology, inventory, and rollout drift. Its authored
selection fixtures return from `I`, distinguishing entered-rule proof from a coincidentally equal successful `E`
result, while the fixed shared request-trace fixture retains its canonical source bytes.

Rust cursor admission is also omission-sensitive. The neutral contract declares one 15-role consumer, and its
checker requires the consumer as a tracked canonical input, one exact marker per role, the complete runtime-package
command in `tools/run_rust_local.sh`, and that optional Rust driver's registration in `tools/run_ci_local.sh`.
The default canonical gate remains toolchain-independent; setting `LINKEDSPEC_RUN_RUST=1` executes the same complete
Rust package that contains the consumer. Dart cursor admission applies the same omission-sensitive pattern: its
15-role consumer is a tracked canonical input, `tools/run_dart_local.sh` runs the complete Dart suite containing
it, and `LINKEDSPEC_RUN_DART=1` invokes that registered driver. Julia now applies the same pattern: one exact
15-role consumer is included by the complete package driver, tracked by canonical CI, and reachable through
`LINKEDSPEC_RUN_JULIA=1`. The current cursor ledger is 5 complete / 3 pending with 67 governed migration files and
44 rejected drift mutations.

Schema version 1 workspace inputs use `path` plus exactly one checked-in `source`
or explicit `bytes_hex`. Hex data is non-empty, lowercase, and even-length, and is
materialized raw; this makes invalid UTF-8 cases reviewable without binary blobs.

## Five-Backend Primary CLI Matrix

Run the complete exact-interface proof from the repository root:

```bash
bash tools/run_primary_cli_matrix.sh
```

The driver checks all toolchains, builds Rust, prepares and warms Dart, warms the normal Julia project, builds PUC
Lua native adapters in disposable temporary storage, and runs the shared manifest against Perl, Rust, Dart,
Julia, and Lua with `POSIXLY_CORRECT` unset and set. The historical admitted boundary was 5x2x61. The later
rule-local cursor boundary reached 63 cases, with Perl, Rust, and Dart admitted before their remaining backend
leaves. Root-selection admission expands the current manifest to 65 cases reference-first: Perl and Rust are
admitted at 65/65 in both environments; Dart is also admitted at 65/65 twice through its exact 15-role consumer.
Julia now passes 65/65 twice and is topology-admitted. Lua preflight is exactly 31/65 twice on both PUC Lua and
LuaJIT, with one root-owned and 33 cursor-owned mismatches. A green 5x2x65 run is the
final rollout target rather than a current cross-backend claim.

The `LUA-BACKEND-PARITY.7.3` no-drift closeout leaves those executable contracts unchanged. Its canonical local
gate passes the Perl reference command at 61/61 in both default and POSIX option environments and Phase 0 at
1,031/1,031 in 608 seconds; the immediately preceding recurring Lua proof remains 169/169 per ABI, focused 61x2,
complete corpus 105/105, and shared matrix 5x2x61.

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

`capability_conformance/manifest.json` currently contains 16 capabilities and 80 backend states: all 80 pass.
Every evidence path must exist, and legacy/future exclusions remain explicit and task-owned. The canonical local
gate runs this check before focused suites. The 60/0/0 generated-source milestone is historical; punctuation-light
admission `.16.7` added four states, and Lua `.8.4` adds 16 all-pass states in one final admission.

The file-oriented native API has a separate executable resolution/loading contract:

```bash
perl tools/check_native_spec_resolution_contract.pl
```

It validates the versioned schema plus 14 portable name cases, nine deterministic path-precedence/file-kind cases,
and four strict UTF-8 preservation/rejection cases before backend-specific consumers run. The canonical core gate
also requires `prove -Iperl t/native_spec_resolution.t`, which consumes the same fixture through Perl's public
portable facade; Rust, Dart, Julia, and Lua consume it directly in their focused package gates. Lua proves the
14/9/4 fixture on both PUC Lua and LuaJIT.

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

After gate hardening `.9.1.4.1`, it checks formatting, runs the complete `linkedspec-core` package, runs the
complete `linkedspec-runtime` package (including the 105-fixture interpreter oracle, exhaustive generated
classifier, and native trace controls), builds `linkedspec-rust`, then runs every current primary-command fixture
with `POSIXLY_CORRECT` unset and set. Override Cargo or its target directory with
`LINKEDSPEC_CARGO_CMD` or `CARGO_TARGET_DIR` when needed.

Core runs first because dependency compilation never executes a dependency crate's own tests. Normalization
`.9.1.4.2` raises current proof to 189 unit + 3 descriptor + 5 contract-driven family/edge integration + 8 type
tests. A separate three-test runtime integration locks the staged live boundary. Together they cover the parser/
compiler/validation/descriptor/serialization and embedding paths central to the cursor rollout.

The `.9.1.4.6` cursor boundary passed the then-63-case manifest in default and POSIX environments. The retired
flag returns the reference-owned targeted usage error and all eleven cursor-era request-trace projections omit
the legacy global field. Root-selection leaf `.9.1.1.2.2` owns Rust convergence to the current 65-case manifest.

The canonical shared gate does not require a Rust toolchain by default. Opt in on a Rust-capable checkout:

```bash
LINKEDSPEC_RUN_RUST=1 bash tools/run_ci_local.sh
```

### Rust mutation testing (planned)

ADR `0039` adopts `cargo-mutants` as a separate test-strength tool, not another commit gate. Mutation execution
will never run per commit, in pre-commit hooks, or in ordinary local CI—not even with diff/file scope. The existing
focused and broader Rust tests remain the normal workflow.

Mutation campaigns will be explicit on-demand investigations or meaningful milestone/release/admission work. A
2026-07-15 list-only census with `cargo-mutants 27.0.0` found 3,333 candidates across 19 production files, so
targeted files must precede any resource-guarded, sharded breadth. Every survivor, timeout, and unviable mutant
will receive a separate disposition; true test gaps gain behavior-focused tests. The generated Rust Unicode case
table is the initial narrow exclusion because its generator, exact-byte regeneration, neutral contract, and
runtime proof already own correctness. `RUST-MUTATION-TESTING` owns the future safe manual command and pilot. No
mutation command is admitted yet, and no mutation score is currently claimed.

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
stable primary failure/trace routing, and unbounded full-manifest CLI execution. The complete package now passes
3,291 assertions. Cursor-option removal eliminates the former 1/57 help mismatch and all 33 shared help/usage/
request-trace mismatches; the independent runner passes 65/65 twice. The neutral-consuming core suite passes 79
assertions, route proof passes 57, composed cursor admission passes 104, and the standalone complete corpus remains
105/105. Cursor rollout is admitted for Julia; root rollout still requires its separate `.4.3` topology consumer.

The library executor and corpus CLI support named or bounded subsets. For example:

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia \
  julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --case proof_edge_array_literal
```

Validation-only loading remains the default. Adding `--execute` without selectors runs the complete validated
manifest and passes 105/105; `--case`, `--offset`, and `--limit` remain available for diagnostics. The permanent
aggregate regression locks manifest order, endpoints, 99 passes, zero failures, and exact output for every fixture.

## Focused Lua Gate

Run both supported Lua ABIs from the repository root:

```bash
bash tools/run_lua_local.sh
```

The gate builds ABI-specific disposable PCRE2 adapters, syntax-checks the Lua tree, runs the full native suite on
PUC Lua and LuaJIT, runs all 61 primary CLI cases under default and POSIX environments on PUC Lua, and validates
plus executes the exact 105-case manifest
through the developer corpus command. The current suite passes 177/177 on each ABI. Its library-level controlled corpus tests
exercise automatic function-aware parsing, explicit validation/compilation, source-identified execution, exact
wrapped output comparison, trace/diagnostic/endpoints, stable failure stages, named/bounded selection, and
continuation after failures. The developer corpus command validates by default and executes the complete manifest
only when passed bare `--execute`. Primary adapter `.7.1` independently implements exact options, strict UTF-8,
native execution/canonical JSON, stable failures/exits, and canonical phase trace. Admission `.7.2` makes both
61-case process legs recurring here and extends the warmed matrix to 5x2x61. Status is
`runtime-corpus-primary-cli`; no-drift `.7.3` closes parent `.7`, confirms the checkout-native setup plus separate
corpus/primary boundaries, and hands off to generated-source work without changing behavior. Planning `.8.1.0`
corrects the earlier v1/v2-only scaffold wording against outward descriptor v3. Deterministic exact-v1/v2/v3
emitter core `.8.1.1` is now covered here: metadata/errors match contract v1, equivalent input emits byte-identical
ASCII source, effective callable/rule state survives reconstruction, and direct/traced modules execute in process
on both ABIs. `.8.1.2` passes the exact selected ABI runtime into the suite, persists valid/corrupt modules plus a
runner in unique caller-owned storage, launches fresh PUC Lua and LuaJIT processes with the gate's native module
paths, captures exact stdout/stderr observations, and requires cleanup after normal and injected-failure paths.
`.8.2` adds exact plan rows/four rejections, plan-authoritative root/nested dispatch, portable generated trace, one
isolated all-family module, and emitted neutral variadic execution. The family matrix consumes the exact ABI
runtime passed by the gate and removes its caller-owned host root. The `.8.3` gate consumes the exact
contract-owned 8/105 list after full-manifest validation, proves interpreter
values before emission, and independently loads all eight modules with exact result/metadata/plan/trace identity
and cleanup in the selected ABI host. Final `.8.4` admits Lua across all 16 rows at 80/0/0.
The completed `.8.3` slice passes generated-source/callable/capability checks, Lua 177/177 per ABI, primary CLI
61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 620 seconds.
The completed `.8.2` slice passes generated-source/callable/capability checks, Lua 176/176 per ABI, primary CLI
61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 626 seconds.
The completed `.8.1.2` slice passes generated-source/callable/capability checks, Lua 173/173 per ABI, primary CLI
61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 607 seconds.
The planning-only `.8.1.0` slice passes generated-source/callable/capability checks, Lua 169/169 per ABI, primary
CLI 61/61 in both environments, corpus 105/105, and the canonical gate with both reference CLI legs at 61/61 plus
Phase 0 true reach `1..1031` in 609 seconds.
The `.7.1` adapter passes the canonical local gate without recurring Lua admission: both reference CLI
environments remain 61/61 and Phase 0 reaches `1..1031` in 606 seconds.
Admission `.7.2` independently passes the canonical local gate with the same reference CLI legs at 61/61 and
Phase 0 true reach `1..1031` in 607 seconds.
The same suite permanently executes exact manifest offsets 0-39 at 40/40, locks first/last names, every wrapped
expected output, and byte/character endpoint 1, without promoting the developer command.
It also permanently executes exact capability offsets 99-104 at 6/6, locking all six governed names, unchanged
wrapped outputs, and byte/character endpoints `2,1,2,1,5,5`.
Advanced/shipped admission likewise executes exact offsets 40-98 at 59/59. Its independent literal ledger locks
all selected names in manifest order, every byte/character endpoint, match and failure state, and exactly one
wrapping of each unchanged expected JSON value. Together these three windows cover the complete 105-case manifest;
`.6.3` adds the final no-selector 105/105 library gate and projects it through the developer runner. The runner
prints ordered PASS/FAIL records plus a summary and returns 0 for all-pass, 1 for fixture failures, and 2 for
arguments or manifest drift. The complete dual-ABI suites pass 167/167 with status `runtime-corpus-full`.
The `.6.3` closeout passes the canonical local gate: both 61-case primary CLI environments and Phase 0
`1..1031`, with Phase 0 completing in 621 seconds.
The `.6.2.6` admission passes the canonical local gate: both 61-case primary CLI environments and Phase 0
`1..1031`, with Phase 0 completing in 621 seconds.
The `.6.1.3` admission also passes the canonical local gate: both 61-case primary CLI environments and Phase 0
`1..1031`, with Phase 0 completing in 640 seconds. Allow at least 30 minutes for a complete gate under concurrent
machine load; this measured run took 1,316.33 seconds end to end.
The `.6.1.4` closeout independently passes that same canonical boundary, with Phase 0 completing in 651 seconds
and the load-affected full gate taking 1,328.76 seconds end to end.

Library selection is independent of that command:

```lua
local execution = linkedspec.execute_corpus_fixtures(corpus_root, {
  case_names = { "proof_edge_array_literal" },
})
assert(linkedspec.corpus_execution_passed(execution))
```

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

A compiled-only temporary depot cannot resolve packages by itself. For direct offline commands after cache
cleanup, layer the writable temporary depot before an existing source-bearing depot, for example
`JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia`. New compiled output stays in the first entry;
installed package source is read from the second. A trailing empty entry expands Julia's system depots, not the
user package depot, so it does not replace that explicit second path.

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
- optionally runs the complete warmed five-backend primary CLI matrix when `LINKEDSPEC_RUN_CLI_MATRIX=1` is set.

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
