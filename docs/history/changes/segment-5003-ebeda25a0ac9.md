UTF-8 byte counts, uppercase percent-escaped fields, optional emoji, and canonical JSON byte length.

**Sinks/failures:** Implemented stdout/route/mirror, file-implied route, reset even at silent levels,
append/persistence, byte-identical mirror output, and phase-stable failure records. Trace-file setup/write errors
map to the stable compilation failure without leaking host details.

**Proof/frontier:** Six focused adapter tests, the full runtime package (137 unit, 99 oracle, 190 integration,
three source-emitter, 10 native trace-control), and all 61 unchanged neutral CLI cases pass. Formatting and
touched-file Clippy are clean; strict package Clippy remains blocked only by the pre-existing runtime/core lint
backlog. Docs/KM/governance/book/whitespace and safe cache cleanup pass. `.1.5.2.4` now owns default/POSIX
recurring-gate and no-drift closeout.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.2.2 — add Rust direct execution API

**Native API:** Added owned `ExecutionOptions` plus `Engine::execute_value` and native traced variants. Each call
can select an entry rule and global seek/consume override without mutating `CompiledSpec`; it returns the rule value
directly. Legacy `execute` retains its accumulator result. The CLI now consumes the reusable API.

**Parity correction:** The nested-object fixture exposed implicit Rust splicing of every hash-valued constructor
argument. Ordinary hash values now remain nested; only explicit `flat`/`flat_hash` splices, matching the existing
book and Perl/Dart/Julia behavior.

**Proof/frontier:** Three focused native/hash tests and all 11 direct result cases pass. Full manifest status is
41/61; only 20 non-quiet canonical trace cases remain under `.1.5.2.3`. Full runtime package, formatting/build,
docs/KM/governance/book/whitespace, and safe cache cleanup pass; strict Clippy finds only the pre-existing backlog.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.2.1 — add Rust CLI boundary

**Implementation:** Added `linkedspec_runtime::primary_cli` plus `linkedspec-rust`. The adapter uses one exact
case-sensitive/non-abbreviating parser and the shared help template, prepares named/file/inline source and
literal/deferred-file input deterministically, strictly decodes file bytes as UTF-8, preserves text unchanged,
delegates language execution to native APIs, and projects stable usage/phase exits onto raw process channels.

**Proof/frontier:** Four focused tests and all 22 exact help/usage cases pass. The full unchanged manifest baseline
is 29/61: strict invalid-UTF-8 phases and all operational failures also pass. Eleven direct-value cases isolate the
documented Rust accumulator wrapper for `.1.5.2.2`; 21 trace cases remain owned by `.3`. The full Rust runtime
package (133 unit, 99 oracle, 190 integration, three source-emitter, 10 trace-control) passes, as do formatting,
build, default/POSIX arguments, docs/KM/governance/book, and safe Rust artifact cleanup.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.2.0 — split Rust primary CLI work

**Audit:** The Rust workspace has native full-spec parsing, validation, compilation, structured execution, and rich
trace, but no binary. `Engine::execute` selects only the compiled `Top` rule and matching consumes per-rule compiled
mode; exact primary entry/global-mode controls are not reusable library options yet.

**Split:** `.1.5.2.1` owns binary arguments/help/strict-UTF-8 loading and named resolution; `.2` owns native
entry/mode controls plus execution/JSON/failures; `.3` owns canonical CLI trace; `.4` owns unchanged 61-case and
gate/no-drift closeout. No Rust implementation or fixture bytes changed.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.6.3 — close Perl CLI reference

**Closeout:** Reconciled parent task status, roadmaps, live docs, mdBook, help/fixture counts, and Knowledge Map.
Live surfaces now consistently identify Perl as the strict 61-case primary-command reference and the prior
mojibake as resolved; dated 53-case and pre-fix evidence remains historical.

**Frontier:** `FUTURE-PARITY-BACKLOG.1.5.1` and `.1.5.1.6` are done. Rust `.1.5.2` is active to add its missing
thin primary command against the unchanged neutral manifest. No implementation or expected-byte behavior changed.

**Verification:** Current-state drift scans, focused suites, 61/61 default/POSIX, full local CI/Phase 0, docs/KM/
governance/mdBook/whitespace, and generated-artifact cleanup pass.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.6.2 — enforce Perl CLI UTF-8 text

**Implementation:** `bin/linkedspec` strictly decodes valid argv before option parsing and raw source/input files
inside their compilation/input-load phases. It preserves code points, U+FEFF, CRLF/LF, and normalization form;
usage/errors and recursive canonical JSON are encoded as UTF-8 exactly once. Invalid spec/input bytes keep their
stable phase headings. UTF-16/UTF-32 remain outside the implicit primary-command contract.

**Fixtures:** Eight shared cases add inline and file Unicode source, nested Unicode JSON, composed/decomposed
literal input, input-file BOM/newline preservation, non-stripped leading spec BOM, invalid source/input bytes, and
full-trace input/result byte counts. The neutral suite grows from 53 to 61 cases.

**Verification:** Adapter/runner syntax, focused runner/trace suites, selected UTF-8 cases, 61/61 default and POSIX
contracts, full local CI through Phase 0, docs/KM/governance/mdBook/whitespace, and generated-artifact cleanup pass.
`.1.5.1.6.3` is active for final Perl-reference no-drift before Rust.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.11.0 — capture generic trailing codeblocks

**Audit:** Perl, Rust, Dart, and Julia implement helper `with(...) { ... }`, receiver `.with() { ... }`, and
selected traversal receiver blocks; Lua is not implemented. The closed `SPEC-FORMAT-TERSE.14` contract explicitly
excluded inline parenthesized final blocks and arbitrary block-taking callables. A LinkedSpec lowering probe proves
`with("x") { ... }` succeeds while `with("x", { ... })` and unknown trailing-block callees are unsupported.

**Corrective direction:** The language has four object/value kinds—scalar, array, harray/hash, and codeblock. A
callable signature that accepts a final codeblock must make `call(args) { block }` equivalent to
`call(args, { block })` for helpers, user functions, and receiver methods in every backend. The parser must not
hard-code `with` as the syntax abstraction.

**Next owner:** Parked `.11.1` designs canonical AST/IR, runtime/return/context semantics, diagnostics, hash-literal
boundaries, neutral parity fixtures, terminology, and the choice to retain `with` as an ordinary helper or remove
it. The active UTF-8/CLI frontier remains `.1.5.1.6.2`; this slice changes no behavior.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.6.1 — add neutral hex byte fixtures

**Implementation:** Schema-v1 input workspace records accept `path` plus exactly one of checked-in `source` or
explicit `bytes_hex`. Hex is non-empty, lowercase, and even-length; raw `pack` materialization reuses safe workspace
paths. Ambiguous/missing/empty/uppercase/odd/non-hex data fails before backend launch.

**Verification:** Six runner subtests prove exact `00c328ff0a` bytes and every validation boundary; syntax,
checked-in help, full local CI/Phase 0, docs/KM/governance/mdBook/cleanup pass. The current suite remains 53 cases.

**Next:** `.1.5.1.6.2` uses this mechanism for invalid UTF-8 source/input fixtures while repairing Perl decoding.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.6.0 — split primary CLI UTF-8 boundary

**Scope:** Read-only root-cause/variant/runner audit, ADR `0025`, three-leaf implementation split, and synchronized
task/roadmap/live/book/Knowledge Map/memory state; no behavior code.

**Finding/decision:** Perl raw argv `xé` becomes JSON `xÃ©`, but decoded native `Get` input and Unicode regex probes
emit exact `c3 a9`, isolating the defect to the adapter. All primary text is strict UTF-8, preserved without
normalization/BOM stripping/newline conversion/trimming; invalid source/input files retain stable phase errors.

**Next:** `.1.5.1.6.1` adds neutral runner hex-byte materialization, `.6.2` implements Perl decoding and shared
valid/invalid fixtures, and `.6.3` closes the reference before Rust.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.10.0 — capture semantic introspection MCP direction

**Scope:** Durable planning capture across task tree, roadmaps/live docs, mdBook, resume pointer, and Knowledge Map;
no implementation or active-frontier change.

**Direction:** Each backend should expose one equivalent, versioned, deterministic semantic introspection API from
its native in-memory library. The public model should answer rule/edge/call graph, source/provenance, inferred
shape, resolution, generated-source relationship, diagnostic, and explain-why questions without exposing backend
AST/IR layouts. MCP should be a thin, bounded, privacy-aware transport over that API and own no semantic behavior.

**Next owner:** Parked `.10.1` designs schema evolution, stable ids/order, query breadth, pagination/cost controls,
cross-backend exact fixtures, idiomatic host APIs, and MCP projection before code. `.1.5.1.6` remains active.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.5 — close Perl CLI trace conformance

**Scope:** ADR `0024`, canonical primary trace projection, 20 exact trace cases, UTF-8 sink handling, updated
focused locks/help, canonical local-gate integration, UTF-8 boundary risk capture, and synchronized docs/book/KM.

**Implementation:** The primary CLI now emits concise `[linkedspec][LEVEL] EVENT` phase records with deterministic
level thresholds and no timestamps/source locations/backend names. Stdout/route/mirror, file defaults/reset,
none/quiet, emoji, success/failure, and JSON separation are exact. Native in-memory tracing remains unchanged.

**Verification:** Pre-change low/high probes measured roughly 1.7/6.8 MB and emoji wide-character stderr warnings.
Twenty trace cases bring both default/POSIX suites to 53/53. They include the signoff-added exact locks for all
levels/aliases, a numeric threshold, default routing, append, input/invocation failure phases, process-boundary
UTF-8 byte counts, and percent-escaped user fields. Four runner and three trace subtests pass; the local gate runs
both 53-case environments before Phase 0 and passes through `1..1028`.

**Surfaced next owner:** A separated `input_text()` probe proves raw UTF-8 argv `xé` currently serializes as
`xÃ©` bytes through Perl `JSON::PP`. Active `.1.5.1.6` owns the backend-neutral UTF-8 argv/file/JSON policy and
repair before Rust `.1.5.2`; this trace leaf does not hide or misclassify the pre-existing success-boundary gap.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.4 — normalize Perl CLI failures

**Scope:** Four exact operational-failure fixtures, adapter-owned untraced stdout purity, stable cross-backend
stderr, phase-order proof, ambient trace isolation, focused regression, and synchronized durable documentation.

**Implementation:** With no CLI trace option, `bin/linkedspec` clears backend trace environment inputs and passes
an internal below-`none` level plus empty route sink. Compilation/input/invocation failures now print only their
stable shared heading and exit `1`; paths, `$!`, raw exceptions, owner fields, and timestamps stay out of stderr.
The exact help/usage snapshots now document operational exit `1` and usage exit `2`.

**Verification:** Invalid and missing source, compilation-before-missing-input, missing input, and missing top rule
are exact. All 33 cases pass in default/POSIX environments. Four runner subtests and three trace CLI subtests pass,
including proof that ambient debug/file/reset state produces neither stdout nor a trace file.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.3 — lock Perl CLI success behavior

**Scope:** Seven backend-neutral success cases for exact source/input loading, parser controls, canonical JSON,
process channels/status, durable task/Knowledge Map facts, and synchronized user-facing documentation.

**Fixtures:** The suite now covers repository-named `Lispish`, file and inline source, literal and file input,
explicit top rule, seek/consume, recursively sorted nested objects, and an input newline returned through
`input_text()`. Each success requires empty stderr, exit `0`, no unexpected files, and one JSON-record newline.

**Evidence:** `LinkedSpec::Get`, `get_parser`, generated-source, and debug-trace probes reverified both the selected
portable action-edge return shape and ADR `0020`'s existing direct-default-rule `E` caveat. Perl needed no runtime
change. All 29 cases pass with `POSIXLY_CORRECT` unset and set; `.1.5.1.4` has since closed operational failures.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.2 — normalize Perl CLI arguments

**Scope:** Explicit Perl primary option parser, reusable expected-channel template variables, 20 exact usage cases,
environment-independence proof, and synchronized docs/task/Knowledge Map status.

**Implementation:** `bin/linkedspec` now recognizes only exact case-sensitive ADR `0023` options and `-h`, with
separate/equals value forms and ordered lexical errors. It rejects all positionals/subcommands, literal `--`,
uppercase/abbreviated/negated aliases, missing or flag values, selector conflicts, and invalid parser/trace values.
Manifest channel variables deduplicate one exact usage template but cannot override runner placeholders.

**Verification:** Two help plus 20 usage cases pass byte-for-byte with `POSIXLY_CORRECT` unset and `1`; every usage
failure has empty stdout, exact stderr, no output files, and exit `2`. CLI/runner/test syntax, four runner subtests,
and two existing trace CLI subtests pass. `.1.5.1.3` owns successful source/input/parser behavior.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.1 — add neutral CLI fixture runner

**Scope:** Backend-neutral fixture schema, arbitrary command runner, exact help case, runner regressions, neutral
Perl help wording, and synchronized public/toolbox/task/live documentation.

**Implementation:** `cli_conformance/manifest.json` defines ordered cases and exact expected channels/files.
`tools/run_cli_conformance.pl` validates strict schema/path invariants, runs any command array in canonical private
workspaces, materializes raw fixture files, drains stdout/stderr concurrently, and compares raw channels, exit
status, and generated files byte-for-byte. Explicit command/repo/workspace/case placeholders and first-byte
mismatch excerpts make one manifest reusable and diagnosable across host wrappers/backends.

**Verification:** Perl passes the exact backend-neutral help case with empty stderr and exit `0`. CLI/runner/test
syntax passes; four runner subtests (13 assertions) cover checked-in help, schema failure before launch,
placeholder/workspace/input/generated-file behavior, and a one-byte mismatch; two existing trace CLI subtests pass.
`.1.5.1.2` owns strict argument/usage fixtures.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.5.1.0 — split neutral CLI fixture work

**Scope:** Read-only Perl primary-CLI/source/test/toolbox audit, direct process probes, durable gap record, and
five-leaf neutral fixture/reference split; no implementation behavior change.

**Findings:** `t/trace_cli.t` passes its help/routed-success smokes, but `bin/linkedspec` ignores residual
positionals; accepts uppercase, unique-abbreviation, and undocumented negated boolean aliases; and changes option
behavior under `POSIXLY_CORRECT`. `GetOptions` emits an uncontrolled warning for unknown options. Compile and
invocation failures exit `1` with structured stderr but also leak timestamped/source-located `DUMP_NONE` trace to
stdout; input failure text includes host `$!`.

**Split:** `.1.5.1.1` owns a reusable neutral manifest/runner and help baseline; `.2` strict deterministic
arguments; `.3` source/input/parser success and canonical bytes; `.4` operational failures/stdout purity; `.5`
deterministic trace plus reusable-runner local-gate integration. Existing trace tests remain green and no
CLI/parser/runtime source changed.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.3 — reconcile Julia scoped parity status

**Scope:** Outer current-surface audit, stale mdBook correction, exact global-owner routing, and handoff to the
language-neutral CLI fixture frontier; no implementation behavior change.

**Finding and correction:** The Julia handoff section correctly described the process-locked exact primary CLI,
but an adjacent sentence inherited from `.7.3.2.1` still denied that capability “yet.” `git blame` confirmed the
provenance. The limitation now names only the still-open cross-backend fixture identity and generated-source gap.

**Result:** `.7.3.3` is done at the precise `runtime-corpus-primary-cli` milestone. The Julia root remains active/
delegated—not complete—through `.1.5` CLI identity, `.1.6` capability census, and `.3` generated-source parity;
`.1.5.1` is next. No source changed. Static status scans, Knowledge Map, governance, mdBook, and whitespace pass;
commit `431f0472` immediately prior supplies the full 1,017/nine-process/99-fixture Julia proof.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.2.5 — close Julia primary CLI conformance

**Scope:** Standalone real-process conformance, focused-gate delegation, precise public status, task/live/book/
Knowledge Map alignment, and safe generated-artifact cleanup.

**Implementation:** `tools/check_julia_primary_cli.sh` runs nine isolated Julia process families and compares exact
stdout/stderr/newline/file bytes plus exit 0/1/2. It covers help, rule/file and function/inline success, parser
controls, retired usage, compilation/input/invocation failure, ordered context, routed emoji, and byte-identical
mirror trace. The focused gate delegates primary checks to it. Status is now `runtime-corpus-primary-cli`.

**Verification:** The standalone checker passes; `tools/run_julia_local.sh` additionally passes all 1,017 package
assertions, separate corpus-runner help, and 99/99 exact corpus outputs. The local status deliberately does not
claim global CLI fixtures, capability census, or generated-source parity; `.7.3.3` has since closed honest outer
no-drift while keeping those global owners explicit.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.2.4 — normalize Julia CLI failures and trace routing

**Scope:** Primary phase ordering, stable operational stderr/exit status, structured runtime fields, complete trace
sink/file/reset/emoji behavior, fatal-error preservation, focused tests, and docs.

**Implementation:** Source preparation and native compilation now precede deferred input-file loading. Compilation,
input, and invocation failures use fixed headings, ordered available runtime fields, raw error text, and exit `1`;
usage remains `2`. The existing emitter now honors level-specific emoji and reset even with explicit stdout mode.
Empty/no-file, stdout, route, and mirror semantics preserve canonical JSON exactly where expected.

**Verification:** Seventy-five focused assertions cover failure precedence/headings/fields/status, source identity,
fatal rethrows, every sink/file combination, reset, quietness, emoji, and file setup failure. The complete 1,017-
assertion suite and 99/99 corpus gate pass. `.7.3.2.5` owns direct-process/no-drift closeout.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.2.3 — execute Julia primary parser requests

**Scope:** Native primary request execution, rule/function source composition, top-rule/parse-mode/trace controls,
recursive canonical direct-value JSON, focused/process regression proof, gate adaptation, and docs.

**Implementation:** Prepared requests now reuse the native rule-first/spec-driven-function fallback, compiler, and
runtime pipeline with one emitter and exact source identity. Success serializes `RuntimeParseResult.value` rather
than the corpus wrapper. The compact writer recursively sorts every string-keyed object while preserving arrays,
scalars, nulls, and JSON escaping, then the CLI adds exactly one newline.

**Verification:** Twenty-two focused assertions cover rule-only/function source, explicit top rule, consume mode,
file IO, routed trace reset, direct shape, and nested canonicalization. The complete 942-assertion suite, direct
canonical primary smoke, and 99/99 corpus gate pass. `.7.3.2.4` owns final errors/exits/trace routing.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.2.2 — align Julia CLI arguments and loading

**Scope:** Exact Julia primary option model, selector/mode/trace validation, subcommand/positional rejection,
named/current/repository spec resolution, file/inline loading, focused tests, focused-gate adaptation, and docs.

**Implementation:** `LinkedSpecJuliaCli.jl` now prepares typed requests from only ADR `0023` flags. Named specs
resolve exact current path, current `NAME.spec`, repository `specs/NAME.spec`, then deterministic authored fallback;
explicit paths/names do not fall through. Source/input files preserve exact text. The old primary `status`/`corpus`
commands are rejected with usage `2`, while `corpus_runner.jl` remains the developer adapter.

**Verification:** Fifty focused assertions cover all flags, aliases/numerics, exclusivity/errors, resolution order,
fallback pruning, exact contents, and load failures. `tools/run_julia_local.sh` passes 920 assertions, direct CLI
help/subcommand rejection, and 99/99. `.7.3.2.3` has since connected the prepared requests to execution/JSON.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.2.1 — trace Julia frontend compiler and staged dispatch

**Scope:** Julia trace propagation through source parse, validation, compiled-state construction, spec-driven
function-shell parsing/projection/runtime execution, and staged parse-job dispatch; focused tests and public/live
documentation.

**Implementation:** Frontend owners now accept one optional caller-owned `LinkedSpecTraceEmitter`. Low-level
operation scopes and medium result/pass/phase decisions reuse the existing levels, stdout/route/mirror sinks,
reset behavior, and rendering. Omitted tracing retains the direct quiet path; disabled tracing records and writes
nothing. All emitted error paths pair scopes with failure exits.

**Verification:** Twenty-eight focused assertions prove success/failure events, routed output, quiet disabled
behavior, and traced/untraced spec/descriptor identity. `tools/run_julia_local.sh` passes the complete 868-assertion
suite, CLI smokes, and 99/99 exact corpus execution. Regenerable Julia compiled cache output was removed;
`.7.3.2.2` is active for exact primary arguments and source/input loading.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.2.0 — split Julia primary CLI alignment

**Scope:** Read-only Julia native/CLI seam audit, mechanism task split, public/live status, Knowledge Map, and
resume pointer. No parser/compiler/runtime/CLI behavior changed.

**Finding:** The native package already provides rule/staged source parsing, compilation, top-rule/parse-mode
runtime execution, structured diagnostics, and runtime trace configs/sinks. The primary CLI still only dispatches
status/corpus and lacks compile/parser/staged trace events, the ADR `0023` option/resolution model, parser execution,
key-sorted canonical JSON, normalized failures, and direct-command proof.

**Split:** `.7.3.2.1` owns trace prerequisites, `.2` arguments/source/input resolution, `.3` execution/JSON, `.4`
failures/exits/trace routing, and `.5` direct conformance plus focused verification/docs. Governance/book checks
pass; `.7.3.2.1` is active.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.1 — ratify exact backend interface parity

**Scope:** ADR `0023`, canonical primary CLI schema, strict completion terminology, global repair/capability owners,
generated-source public-capability classification, mdBook, Knowledge Map, roadmaps/tasks/live docs, and memory.

**Decision:** Complete backend parity means identical user-observable capabilities and behavior. Distinct
executable tokens expose one parser-oriented CLI: the same source/input/parser/trace/help options, no subcommands
or positional arguments, canonical JSON, normalized stdout/stderr, and exit `0`/`1`/`2`. Host APIs may remain
idiomatic only while capabilities and behavior match.

**Routing:** Julia `.7.3.2` owns immediate CLI alignment. `FUTURE-PARITY-BACKLOG.1.5` owns neutral fixtures plus
Perl/Rust/Dart/global CLI convergence, `.1.6` owns the complete public capability census, and `.3` owns generated-
source parity. Rust publicly exports its emitter, so codegen deferral remains valid scheduling but blocks complete
Dart/Julia/Lua parity. No implementation behavior changed; docs/governance checks pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.3.0 — split strict user-facing parity closeout

**Scope:** Read-only current CLI census, task split, public status correction, Knowledge Map fact, and live resume
alignment; no parser/compiler/runtime/CLI behavior change.

**Finding:** ADR `0006` already requires the same features and runtime semantics, and the director clarified that
distinct variant executables must expose the exact same CLI API. Source audit proves the current commands differ:
Perl is a parser CLI with source/input/parser/trace options and JSON output; Dart/Julia expose corpus/status flows;
Rust declares no binary target.

**Routing:** `.7.3` is split into `.7.3.1` for the durable exact contract and cross-backend repair ownership,
`.7.3.2` for Julia CLI alignment, and `.7.3.3` for honest no-drift. The 99/99 interpreter gate remains valid but
is not represented as proof of CLI or complete user-observable parity. Docs/governance checks pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.2 — defer Julia generated source proof

**Scope:** Post-interpreter generated-source decision, future owner/prerequisites, mdBook status, Knowledge Map,
roadmaps/tasks/live docs, and resume pointer.

**Decision:** Generated Julia source is deliberately deferred. Julia already satisfies ADR `0022` through native
in-memory parse/stage/compile/runtime APIs and passes the full interpreter corpus at 99/99. Rust's source-emitter
precedent shows a credible generated path requires its own emitter scaffold/compile-run harness, typed generated-
family plan, direct structural-family execution, and curated manifest-backed corpus proof; it is not a one-slice
closeout addition.

**Ownership and validation:** `FUTURE-PARITY-BACKLOG.3` now owns Rust generated breadth plus separate Dart/Julia
source-emitter splits with those prerequisites. No Julia behavior changed; the focused gate remains 840 assertions
and 99/99 at `runtime-corpus-full`. mdBook, Knowledge Map, memory, task, doctrine, and whitespace checks pass;
`.7.3` becomes active for final no-drift.

## 2026-07-10 — JULIA-BACKEND-PARITY.7.1 — document Julia usage and parity boundary

**Scope:** mdBook backend handoff, public native API, trace status, project status, local verification page, Julia
README, Knowledge Map, roadmaps/tasks/live docs, and resume pointer.

**Change:** The public book now presents Julia as a mature native in-memory backend rather than a scaffold. It adds
self-contained rule-only and top-level-function embedding examples, completes the package layout, retains focused/
direct/optional-shared-CI commands, and names the accepted 99/99 `runtime-corpus-full` interpreter boundary.
Historical `runtime-trace-events` wording is explicitly scoped to its old mechanism boundary.

**Limitations and validation:** Generated Julia source remains a separate `.7.2` decision; current tracing covers
runtime controls/events/sinks and interpreter instrumentation, not compile/parser trace parity; JuliaFormatter/JET
remain optional tooling. No behavior changed. mdBook, Knowledge Map, memory, task, doctrine, and whitespace checks
pass; the previously verified focused gate remains 840 assertions plus 99/99.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.4 — wire Julia local verification

**Scope:** Repo-owned focused Julia gate, optional shared-CI integration, configurable executable/depot handling,
root/backend/mdBook commands, Knowledge Map, task/index/roadmap alignment, live docs, and resume pointer.

**Change:** Added `tools/run_julia_local.sh`. It runs Julia `Pkg.test()`, both Julia CLI help/status surfaces,
corpus-runner help, and the full 99-fixture corpus from the repository root. `LINKEDSPEC_JULIA_CMD` and
`LINKEDSPEC_JULIA_DEPOT_PATH` override the executable and writable depot. `tools/run_ci_local.sh` invokes this gate
only under `LINKEDSPEC_RUN_JULIA=1`; default local CI remains SDK-independent.

**Validation:** The focused gate passes all 840 package assertions, CLI checks, and 99/99 corpus execution. Shell
syntax and the default core local-CI gate pass. The mdBook, root README, and Julia README document focused/direct/
opt-in commands; `.7.1` now owns public Julia documentation closeout.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.3 — close full Julia corpus gate

**Scope:** Complete manifest execution, unbounded/offset-only CLI behavior, permanent 99-fixture regression,
package status, live docs, mdBook, Knowledge Map, task/index/roadmap alignment, and resume pointer.

**Change:** Removed the temporary staged-rollout rejection for CLI `--execute` without selectors. Bare execute now
runs the complete validated manifest; repeated `--case`, `--offset`, and `--limit` remain diagnostic selectors,
including offset-only execution through the manifest end. Added one atomic full-corpus test that locks format,
counts, order, endpoints, pass/failure totals, and exact expected output for every fixture. Manifest validation and
per-fixture failure behavior are unchanged.

**Validation:** Direct unbounded CLI execution prints 99 `PASS` results and finishes 99 passed / 0 failed. Full
Julia tests pass with 840 assertions; mismatch execution still returns `1`, invalid arguments/manifest state return
`2`, and status is `runtime-corpus-full`. `.6.4` now owns local verification wiring.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.5 — execute Julia function shell corpus

**Scope:** Spec-driven top-level user-function source parsing, corpus composition, three routed fixture regressions,
package status, live docs, mdBook, Knowledge Map, task/index/roadmap alignment, and resume pointer.

**Change:** Added a cached `UserFunctionDefinitionAstParser` that compiles
`specs/user_function_definition.spec`, executes it over caller-provided source in memory, and normalizes its neutral
definition nodes before the existing staged body parser and registry compiler run. The default corpus path still
tries rule-only `parse_spec(...)` first and uses this composition only after a source parse error. No raw Julia
function scanner, fixture-name branch, temporary file, or subprocess path was added.

**Validation:** Seven focused source-driven parser assertions and four permanent three-fixture corpus assertions
pass. Direct corpus CLI execution is 3 passed / 0 failed; full Julia tests pass with 827 assertions; status is
`runtime-corpus-function-shells`. `.6.3` now owns the independent full 99-fixture manifest gate.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.6 — close Julia shipped corpus no drift

**Scope:** Permanent complete shipped-spec corpus regression, honest Julia package/CLI status, task/roadmap/live
docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added one Julia test that executes the exact manifest offset-68/limit-31 window and locks manifest
count `99`, result count `31`, stable `tclite_command_subst` / `lib_reader_cattribute` endpoints, pass count `31`,
zero failures, and exact expected-output equality for every result. Package/CLI status advances from the last
leading-trivia mechanism label to `runtime-corpus-shipped`. No parser, compiler, runtime, or fixture changed.

**Validation:** Direct corpus-runner execution prints all 31 fixtures as `PASS` and finishes 31 passed / 0 failed.
Full `Pkg.test()` passes with 816 assertions. The shipped batch and `.6.2.4` parent close; `.6.2.5` becomes active
for the three separately routed top-level function fixtures.

## 2026-07-10 — FUTURE-PARITY-BACKLOG.1.4 — ratify native in-memory backend contract

**Scope:** Cross-backend product architecture, public API/handoff documentation, Perl/Rust/Dart/Julia surface
audit, future Lua acceptance, ADR/Knowledge Map, roadmap/task-tree alignment, and live continuity docs.

**Change:** ADR `0022` now states why LinkedSpec is multi-backend: Rust, Dart, Julia, Lua, and later host-language
applications must be able to embed LinkedSpec natively and keep `.spec` source, parser input, and structured
results in memory. Every backend must expose host-process parse/compile/execute APIs without requiring a CLI,
subprocess, temporary file, or serialized handoff. Distinct variant CLIs and corpus runners remain thin adapters
with no exclusive semantics.

**Audit boundary:** Perl already exposes `LinkedSpec::Get(...)`; Rust exposes core parser/compiler crates plus
the runtime `Engine`; Dart exports `parseSpec(...)`, `compileSpec(...)`, and `LinkedSpecRuntimeEngine`; Julia
exports `parse_spec(...)`, `compile_spec(...)`, `runtime_parse(...)`, and `runtime_execute(...)`. This is a
documentation/architecture ratification only—no parser/compiler/runtime behavior changed. Lua's future plan now
requires a native module and direct library-level tests before CLI completion can count.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.5.3 — mirror Julia public parser leading trivia

**Scope:** Julia public in-memory runtime entry cursor, focused leading-trivia/indexed-read proof, history fixture
closeout, shipped-window verification, package status, live docs, mdBook, Knowledge Map, and resume pointer.

**Change:** `runtime_parse(...)` now starts the top rule after only leading blank lines and leading `#` comment
lines, mirroring the Perl public wrapper and completed Dart backend. The scan is byte-safe and updates the existing
cursor/register seam; direct indexing and rule execution are otherwise unchanged.

**Validation:** A focused minimal skips a blank line plus indented comment before `object:` while still parsing the
later version record; ordinary scalar-held `payload[1]` still returns `"name"`. `ds_vhistory_version_entry` passes
exact checked-in output, the offset-68/limit-31 shipped window is 31/31, and full `Pkg.test()` passes with 810
assertions. Status is `runtime-corpus-leading-trivia`; `.6.2.4.6` owns permanent 31/31 no-drift.

## 2026-07-10 — REPO-HYGIENE.4 — clean Rust and Julia generated caches

**Scope:** Recurring disk-pressure cleanup covering ignored Rust/mdBook output, Julia-specific compiled cache
locations, and provenance-checked stale LinkedSpec/RGX temp logs, with depot data, unrelated temp trees, and `rgx`
corpus artifacts preserved.

**Change:** Removed ignored/untracked `rust/target` (1.7G) and mdBook output (7.8M), plus only the regenerable
`compiled/` directories from the dedicated LinkedSpec Julia depot (148M) and the user Julia depot (261M). Julia
packages, registries, environments, logs, scratchspaces, and all source/fixture data remain intact.

**Root cause and validation:** A follow-up scan found `/private/tmp` at 46G. Twelve closed July 6–9 LinkedSpec/RGX
parser-generation logs accounted for about 18G; headers tied them to repo generation commands and process/`lsof`
checks found no writers. Removing exactly those logs brings this leaf's reclaimed total to about 20G and moves
availability from 50G/90% to 68G/86%. Post-clean checks confirm all targets are absent and Julia depots retain
their noncompiled content. The unrelated 29G `claude-501` directory, unrelated cargo-mutants trees, and `rgx`
corpus artifacts remain untouched.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.5.2 — add Julia statement regex mutation

**Scope:** Julia statement-form `substr(...)` / `regex_subst(...)` scalar mutation, replacement capture/flag
coverage, five shipped-smoke closeouts, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Statement-context four-argument regex substitution now mutates a bare scalar target before pure helper
fallback. Regex/string patterns use strict helper flags, `g` replaces globally, `o` is a no-op, `$n` expands
captures, and invalid patterns/flags retain rule-attributed failure. Numeric value-form slicing remains pure.

**Validation:** Six focused assertions lock global/single/case-insensitive replacement and unchanged pure slicing.
Both EBNF, both lib_reader, and simenv fixtures pass exact oracle output. The shipped window moves from 25/31 to
30/31; full `Pkg.test()` passes with 808 assertions and status `runtime-corpus-statement-mutation`. CLI, mdBook,
memory, Knowledge Map, task, doctrine, and whitespace gates pass. Julia executes the exact single-quoted pattern;
narrow Perl and Dart locks plus the focused Rust single-quote parser unit prove the same spelling. This is recorded
as a language-wide contract for every current and future backend. The touched mutation example uses newline
separators and no trailing semicolons;
broader historical example cleanup remains separately routed.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.5.1 — add Julia terminating exit control

**Scope:** Julia `exit_now(...)` runtime execution, explicit/default status and diagnostic tests, simenv boundary
routing, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added immediate `exit_now(...)` dispatch. Julia evaluates the optional status expression, defaults to
status `1`, and throws `RuntimeInterpreterException` with rule attribution; the existing runtime wrapper retains
structured top/rule/spec diagnostic fields. Statements after the helper are unreachable.

**Validation:** Focused assertions lock `exit_now(7)`, default `exit_now(1)`, termination before a following
return, and structured attribution. Simenv advances from an unsupported-helper failure to the deliberate
`exit_now(1) in rule begin_end_blocks` control boundary, routing its unmet statement-form mutation prerequisite to
`.6.2.4.5.2`. The shipped window remains 25/31 without regression; full `Pkg.test()` passes with 801 assertions and
status `runtime-corpus-exit-now`. CLI, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.4 — add Julia action-edge child push

**Scope:** Julia action-edge child-result append overloads, focused whole/indexed tests, spec.spec closeout, EBNF
residual routing, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** A compiled-rule first argument now gives `push(...)` child-call precedence. Julia reuses the current
edge's cached child result and supports implicit/explicit whole and literal-indexed appends while retaining ordinary
`push(array(target), value)` semantics.

**Validation:** All four push forms pass in focused runtime coverage. Four spec.spec smokes pass. Both EBNF cases
retain complete structures and are locked at quote-only statement-mutation residuals under `.6.2.4.5.2`. The full
window moves from 21/31 to 25/31; full `Pkg.test()` passes with 793 assertions and status
`runtime-corpus-action-edge-child-push`. CLI, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates
pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.3 — scope Julia recursive rule resets

**Scope:** Julia per-rule aggregate reset scoping, focused caller/child store tests, recursive top-rule corpus
closeout, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added a first-reset binding-snapshot map to each runtime rule invocation. Explicit array/hash `set(...)`
and explicit split-target replacement now restore the caller's prior scalar/array/hash binding on rule exit.
Ordinary undeclared child mutations remain caller-visible, and registered user functions retain independent
whole-store isolation.

**Validation:** Focused Julia trace showed the shared `items` overwrite before the fix. Array/hash restoration and
shared-mutation tests pass; all three recursive top-rule corpus fixtures pass unchanged. The full shipped window
moves from 18/31 to 21/31; full `Pkg.test()` passes with 785 assertions and status
`runtime-corpus-recursive-rule-scope`. CLI, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates
pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.2.2 — add Julia diagnostic output helpers

**Scope:** Julia `print`/`print_each`/`say` runtime execution, focused diagnostic-sink coverage, permanent shipped-
corpus boundary regression, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added eager diagnostic helper dispatch. `print` concatenates values, `say` adds a newline, and
`print_each` walks array items with optional prefix/suffix text. Messages route through the configured low-level
trace sink; all helpers return `nothing` and never enter parser output. The touched mdBook examples use newlines as
statement separators and omit line-ending semicolons.

**Validation:** Simenv advances from unsupported `print` to unsupported `exit_now`; history reaches its known
leading-trivia output mismatch. Seven permanent corpus assertions lock both advanced boundaries and reject renewed
unsupported-`print` failures. The full window remains 18/31; full `Pkg.test()` passes with 780 assertions and
status `runtime-corpus-diagnostic-output`. CLI, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates
pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.2.3 — normalize Julia helper regex flags

**Scope:** Shared Julia helper-regex flag compilation, focused matches/split/invalid-flag coverage, portmap constant
corpus closeout, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added a strict compiler seam that preserves `i`/`m`/`s`/`x`, ignores execution-only `g` and Perl's
compile-once `o`, and rejects unknown flags or invalid patterns. Both `matches(...)` and regex `split(...)` use it.
`portmap_constant` now passes exact checked-in output.

**Validation:** Focused `igo`, regex split `go`, and invalid `q` behavior pass. The full window moves from 17/31 to
18/31; full `Pkg.test()` remains green with 772 assertions and status `runtime-corpus-helper-regex-flags`. CLI,
mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.2.1 — add Julia logical helpers

**Scope:** Julia eager logical-helper execution, focused truthiness/eagerness and corpus routing tests, a narrow
helper-regex flag follow-up split, package status, lockstep docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added boolean `and`/`or`/`not` to the pure helper runtime using existing truthiness and normal eager
argument evaluation. Three portmap cases and tablegrep pass. Direct capture and trace probes route
`portmap_constant` to `.6.2.4.2.3`: Perl's no-op `o` flag currently makes Julia helper regex compilation fail.

**Validation:** Focused logical corpus is 4 passed plus one explicitly routed regex-flag residual; the full window
moves from 13/31 to 17/31. Full `Pkg.test()` passes with 772 assertions and status
`runtime-corpus-logical-helpers`; CLI, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.1 — add Julia anonymous capture boundaries

**Scope:** Julia anonymous capture-boundary runtime execution, Unicode/location/mutation tests, permanent hlink/
EBNF corpus routing proof, package status, task/roadmap/live docs, mdBook, Knowledge Map, and resume pointer.

**Change:** Added the complete direct anonymous family over existing match registers: capture start; match-start,
cursor, and input-end text/character-length readers; origin position/line/column; and destructive take variants.
All three hlink delimiter fixtures pass. EBNF logging now reaches its structural residual and routes to `.6.2.4.4`.

**Validation:** Focused corpus is 3 hlink passes plus one explicitly structural EBNF residual; the full window moves
from 10/31 to 13/31. Full `Pkg.test()` passes with 766 assertions and status
`runtime-corpus-capture-boundaries`; CLI, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.4.0 — split Julia shipped corpus smoke batch

**Scope:** Diagnostic execution and planning-only decomposition of Julia manifest fixtures 68–98, plus task,
roadmap/live, mdBook, Knowledge Map, architecture, and resume-pointer alignment.

**Change:** Measured the complete shipped-spec/parser-smoke window at 10 passed / 21 failed. Split every failure
into owned capture-boundary, logical helper, diagnostic-output helper, recursive top-rule, EBNF/spec.spec structural
output, and lib_reader quote-normalization leaves before source changes. Status remains `runtime-corpus-middle`.

**Validation:** Bounded runner `--offset 68 --limit 31` accounts for all 31 fixtures. mdBook, memory, Knowledge Map,
task, doctrine, and whitespace gates pass; no Julia source, test, fixture, or runtime behavior changed.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.3 — close Julia middle corpus batch

**Scope:** Julia non-function manifest fixtures 40–67, permanent three-window regression proof, explicit function
routes, package status, task/roadmap/live docs, mdBook, Knowledge Map, architecture, and resume pointer.

**Change:** Executed windows 40–56, 58–59, and 62–67: all 25 non-function fixtures pass unchanged across helper,
control, receiver, assignment, with-block, and tree traversal behavior. Added six permanent assertions for exact
window sizes/endpoints, 25 results/passes, empty failures, and the three top-level function offsets routed to
`.6.2.5`. Status advances to `runtime-corpus-middle`; no production or fixture change was required.

**Validation:** Direct windows report 17/17, 2/2, and 6/6; full `Pkg.test()` passes with 757 assertions. CLI,
mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates pass; `.6.2.4` shipped-spec/parser-smoke is next.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.2 — close Julia starter corpus batch

**Scope:** Julia shipped-corpus fixtures 0–39, permanent bounded regression proof, package status, task/roadmap/live
docs, mdBook, Knowledge Map, architecture, and resume pointer.

**Change:** Executed the first 40 manifest fixtures through the bounded Julia runner: every fixture passed against
the checked-in Perl/Rust expected JSON without a parser/runtime or fixture change. Added a six-assertion permanent
`Starter corpus batch` test locking the 99-case manifest, exact window endpoints, 40 results, 40 passes, and empty
failure ledger. Status advances to `runtime-corpus-starter`.

**Validation:** Direct bounded execution reports 40 passed / 0 failed and exits `0`; full `Pkg.test()` passes with
751 assertions. CLI status/help/default validation, mdBook, memory, Knowledge Map, task, doctrine, and whitespace
gates pass; `.6.2.3` middle non-function fixtures 40–67 are next.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.1 — add Julia executable corpus selection

**Scope:** Julia library corpus selection, bounded corpus-runner execution/reporting, CLI option parsing/help,
selection and exit-code tests, package status, task/roadmap/live docs, mdBook, Knowledge Map, architecture, and
resume pointer.

**Change:** `execute_corpus_fixtures(...)` now accepts ordered named cases or an offset/limit window with strict
missing/duplicate/mixed/invalid/out-of-range diagnostics. The runner accepts repeated `--case` plus `--offset` and
`--limit` in separate or equals forms, prints every selected PASS/FAIL plus a summary, and returns `0`/`1` for
all-pass/fixture-failure runs. Selection flags require `--execute`; unbounded and offset-only CLI execution remain
rejected until full parity. Validation-only behavior stays the default. Status advances to
`runtime-corpus-selection`.

**Validation:** Thirty added assertions bring full `Pkg.test()` to 745. Julia status/help, validation-only 99-case
load, bounded execute, unbounded rejection, mdBook, memory, Knowledge Map, task, doctrine, and whitespace gates
pass; `.6.2.2` starter fixtures 0–39 are next.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.2.0 — split Julia corpus expansion batches

**Scope:** Planning-only decomposition of the Julia 99-fixture rollout, task/frontier metadata, roadmap/live docs,
mdBook handoff/status, Knowledge Map, architecture, and resume pointer.

**Change:** Split `.6.2` before shipped-corpus behavior changes into `.6.2.1` bounded library/CLI selection and
reporting, `.6.2.2` fixtures 0–39, `.6.2.3` non-function fixtures 40–67, `.6.2.4` shipped-spec/parser-smoke fixtures
68–98, and `.6.2.5` spec-defined top-level function-shell execution. Each implementation batch must pass unchanged
fixtures or split observed mismatches with Perl/Rust/Dart oracle evidence; Julia-only fixture weakening and raw
function scanning remain prohibited.

**Validation:** Planning/docs only; Julia behavior and the green 715-assertion `.6.1` boundary are unchanged.
mdBook, memory architecture, Knowledge Map, task metadata, doctrine, and whitespace gates pass; `.6.2.1` is next.

## 2026-07-10 — JULIA-BACKEND-PARITY.6.1 — add Julia controlled corpus execution

**Scope:** Julia library-level corpus execution/results, wrapped output comparison, trace/diagnostic retention,
controlled value/dispatch/lifecycle/function/boundary fixtures, failure continuation, package status, task/roadmap/
live docs, mdBook, Knowledge Map, architecture, and resume pointer.

**Change:** Added `execute_corpus_fixtures(...)`, public execution/result records, and result query helpers. The
harness reuses manifest validation, runs every fixture through parse/compile/runtime, compares the backend-neutral
expected value after the required one-level output wrap, preserves optional trace lines and structured diagnostics,
and accumulates parse/validate/compile/execute/no-match/mismatch failures without aborting. Controlled staged
function fixtures can provide a parser callback; ordinary callers default to `parse_spec(...)`. Package status
advances to `runtime-controlled-corpus`. All new multiline fixtures use newline separators without terminator-style
semicolons.

**Validation:** Twenty-four focused assertions cover six passing fixtures and diagnostic/mismatch continuation;
full `Pkg.test()` passes with 715 assertions. CLI `--execute` remains deliberately rejected until its later owner.
mdBook, memory, Knowledge Map, task metadata, doctrine, and whitespace gates pass; `.6.2` manifest batches are next.

## 2026-07-10 — JULIA-BACKEND-PARITY.5.3 — preserve Julia staged descriptor shapes

**Scope:** Julia neutral staged user-function shape proof across spec-returned definitions, staged dispatch,
compiled registry, public descriptor JSON, runtime output, task/roadmap/live docs, mdBook, Knowledge Map,
architecture, and resume pointer.

**Change:** Added one end-to-end 20-assertion fixture over two source-ordered functions. It locks neutral
`body_payload` provenance, normalized `body_parse_job` ids/paths/policies, stitched ActionIR `body_ast`, compiled
registry job order, descriptor function order/count, and runtime output from the same compiled state. No production
projection correction was required; package status remains `runtime-user-functions`.

**Validation:** Full `Pkg.test()` passes with 691 assertions. Julia CLI status/help, mdBook, memory, Knowledge Map,
task metadata, doctrine, and whitespace gates pass. `.5` closes and `.6.1` controlled corpus execution is active.

## 2026-07-10 — JULIA-BACKEND-PARITY.5.2 — execute Julia user functions

**Scope:** Julia registered-call runtime resolution, eager arguments, isolated typed local stores, cached ActionIR
function bodies, return/drop/receiver behavior, arity/recursion diagnostics, focused tests, package/CLI status,
mdBook, task/roadmap/live docs, Knowledge Map, architecture, and resume pointer.

**Change:** `LinkedSpecRuntimeEngine` now resolves exact-arity registered functions before ordinary helper fallback,
evaluates arguments in caller scope, runs each body with fresh scalar/array/hash stores, restores caller stores,
returns the final expression or local `return(...)` payload, composes values into receiver chains, and executes
standalone calls while discarding their results. Direct and mutual recursion report structured cycle diagnostics.
Package status advances to `runtime-user-functions`.

**Validation:** Nine focused assertions cover eager evaluation, local isolation, aggregate params, final/local
returns, value/receiver/drop positions, wrong arity, and direct/mutual recursion. Full `Pkg.test()` passes with 671
assertions. CLI status, mdBook, memory, KM, task, doctrine, and whitespace gates pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.5.1 — add Julia staged function-body registry

**Scope:** Julia staged parser registry/provider, stable function-body job queue, portable dispatch records,
immutable `body_ast` stitching, composed shell API, focused tests, package/CLI status, mdBook staged/status/handoff,
task/roadmap/live docs, Knowledge Map, architecture, and resume pointer.

**Change:** Added `julia/src/parser/StagedParserRegistry.jl` with the fixed built-in ActionIR-body provider,
portable adapter digest/cache/compiled/result records, path/span/id ordering, contextual diagnostics, immutable
function-body dispatch/stitching, and `parse_spec_with_staged_user_function_definition_asts(...)`. Package status
advances to `runtime-staged-registry`.

**Validation:** Thirty-one focused assertions cover queue order, provider metadata, exact ActionIR parsing,
stitching immutability, wrapper composition, resolve/compile failures, and policy drift; full `Pkg.test()` passes
with 662 assertions. CLI status, mdBook, memory, KM, task, doctrine, and whitespace gates pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.5.4 — close Julia diagnostics trace no drift

**Scope:** Julia diagnostics/trace status and test audit, `.4.5` parent closeout, README/CLI status, mdBook
trace/status/handoff, roadmap/task/live docs, Knowledge Map boundary fact, architecture, and resume pointer.

**Change:** Confirmed the 631-assertion structured diagnostics, trace controls/sinks/events, and runtime
instrumentation boundary is internally consistent. Retained precise package status `runtime-trace-events`, closed
`.4.5` without source changes or broader parity overclaim, and advanced the active frontier to `.5.1`.

**Validation:** Full `Pkg.test()`, Julia CLI status/help, stale-frontier scans, mdBook, memory architecture,
task-tree metadata, Knowledge Map, doctrine, and whitespace checks pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.5.3 — add Julia runtime trace events

**Scope:** Julia interpreter rule/regex/dispatch/lifecycle/recursion/cursor/boundary instrumentation, focused
trace tests, package/CLI status, mdBook trace/status/handoff, task-tree/roadmaps/live docs, Knowledge Map,
architecture, and resume pointer.

**Change:** Added default-no-op trace helpers over the optional emitter and instrumented the existing runtime path
with rule scopes; regex and child-dispatch decisions; lifecycle marks; recursion-cutoff decisions; cursor/stack
transitions; and successful/unusable boundary events. Package status advances to `runtime-trace-events`.

**Validation:** Fourteen added trace assertions prove every required mechanism and traced/untraced output identity;
full `Pkg.test()` passes with 631 assertions. Julia CLI status, mdBook, memory architecture, task-tree metadata,
Knowledge Map, doctrine, and whitespace checks pass.

## 2026-07-10 — STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1 — align separator example style

**Scope:** The director-identified Dart hash-helper executable fixture, statement-separator mdBook/KM wording,
task-tree ownership, live docs, and resume state.

**Change:** Removed eight redundant line-ending semicolons from multiline `.spec` source. Each newline remains the
statement boundary; no grammar or runtime behavior changed. The book and Knowledge Map now also state that
executable examples omit terminator-style semicolons.

**Validation:** The focused Dart runtime test passes with unchanged output; mdBook, memory architecture, task-tree
metadata, Knowledge Map, doctrine, and whitespace checks pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.5.2 — add Julia trace controls

**Scope:** Julia trace levels, environment/config controls, structured events/scopes/decisions/logs/dumps,
stdout/routed-file/mirror sinks, reset behavior, optional runtime emitter plumbing, traced entrypoints, package/CLI
status, focused tests, mdBook trace/status/handoff, task-tree/live docs, Knowledge Map, architecture, and resume
pointer.

**Change:** Added `julia/src/trace/Trace.jl` with the portable control/sink/event capabilities in Julia-native
types and exported functions. `runtime_parse` / `runtime_execute` accept optional emitters, while traced wrappers
construct an emitter from config and emit a parse scope. Disabled/default execution stays quiet; traced results
match untraced results. Package status now reports `runtime-trace-controls`; internal runtime events remain `.4.5.3`.

**Validation:** `Pkg.test()` passes with 617 assertions, including 29 focused trace assertions; Julia CLI status,
mdBook build, memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check` pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.5.1 — add Julia runtime diagnostics

**Scope:** Exported Julia runtime diagnostic payloads, diagnostic-carrying exceptions, optional spec identity,
top/rule/handler attribution, successful-output compatibility, package/CLI status, focused tests, mdBook
diagnostics/runtime/trace/status/handoff, task-tree/live docs, Knowledge Map, architecture, and resume pointer.

**Change:** Added `RuntimeDiagnostic` with deterministic neutral-field JSON and optional
`RuntimeInterpreterException.diagnostic`. `LinkedSpecRuntimeEngine` accepts `spec_name` / `spec_path`; direct rule
lookup and rule execution attach top/current-rule/Julia-handler attribution before unwind, while outer wrappers
preserve richer inner payloads. Existing textual errors and successful parse output are unchanged. Package status
now reports `runtime-diagnostics`.

**Validation:** `Pkg.test()` passes with 588 assertions, including seven focused diagnostic assertions; Julia CLI
status, mdBook build, memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`
pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.5.0 — split Julia diagnostics trace controls

**Scope:** Planning-only decomposition of Julia runtime diagnostics and trace parity into structured diagnostics,
trace controls/events/sinks, runtime instrumentation, and final no-drift owners.

**Change:** Converted `.4.5` into a container with `.4.5.1` stable runtime diagnostic payloads, `.4.5.2` ordered
trace levels/config/events/stdout-route-mirror sinks, `.4.5.3` runtime branch/lifecycle/cursor/boundary events, and
`.4.5.4` no-drift closeout. Selected `.4.5.1` as the sole active frontier. Julia runtime behavior and package
status `runtime-cursor-boundary` are unchanged.

**Validation:** mdBook build, memory architecture, task-tree metadata, Knowledge Map generation/check, doctrine,
and `git diff --check` pass; no Julia package test rerun is required for this documentation-only split.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.4 — add Julia runtime cursor controls

**Scope:** Julia explicit cursor stack and anchor rewinds, cursor/input helper reads, non-consuming named-rule
boundary capture, parse-mode continuation, package/CLI status, focused runtime tests, mdBook status/handoff,
task-tree/live docs, Knowledge Map, architecture snapshot, and resume pointer.

**Change:** Added `save_cursor()` / `restore_cursor()`, `rewind_match_start()` / `rewind_entry_start()`, and a
single synchronized cursor/register update path to the Julia runtime. Added character-based cursor/input helper
projection over the internal UTF-8 code-unit cursor, overflow-safe `input_slice`, and
`capture_until_boundary(rule[, ...])` with earliest-boundary, EOF fallback, and unresolved-rule no-op semantics.
Cursor movement preserves match records and semantic stores. Package status now reports `runtime-cursor-boundary`.

**Validation:** `Pkg.test()` passes with 581 assertions, including 14 focused cursor/boundary assertions; Julia
CLI status, mdBook build, memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`
pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.6 — close Julia helper value no drift

**Scope:** Final Julia helper/value runtime no-drift across focused tests, package/CLI status, mdBook helper
contracts and status/handoff, live docs, task metadata, Knowledge Map, architecture snapshot, and resume pointer.

**Change:** Audited the `.4.3.1` through `.4.3.5` implementation boundary against the portable helper catalog and
confirmed Julia already implements final checked nested writes plus current helper/control/callback behavior.
Runtime behavior and package status `runtime-value-control-tree` are unchanged. Reconciled stale `.3` and `.4.3`
parent statuses, normalized central helper-catalog `.spec` examples so end-of-line statements do not carry
redundant semicolons, closed `.4.3`, and advanced the frontier to `.4.4` cursor controls.

**Validation:** `Pkg.test()` remains green with 567 assertions; Julia CLI status, mdBook build, memory architecture,
task-tree metadata, Knowledge Map, doctrine, and `git diff --check` pass.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.5 — add Julia runtime controls and tree callbacks

**Scope:** Julia expression-valued block flow, structured action controls, lazy inline branches, helper/receiver
trailing with-blocks, hash/array tree traversal callbacks, scoped binding restoration, package status, focused
runtime tests, README, task-tree frontier, roadmaps/index, mdBook status/handoff, Knowledge Map, architecture
snapshot, live docs, and resume pointer.

**Change:** Extended `julia/src/runtime/Interpreter.jl` with distinct rule/value block flow, block-local
`return(...)` / `return_undef()`, attached and marker controls, lazy inline `if` / `switch`, deterministic while
limits, immediate helper/receiver with-blocks, full scalar/array/hash binding snapshots, and hash/array
walk/map/reduce receiver callbacks. Traversals preserve their current sorted-key or zero-based depth-first
contracts and return `nothing` lazily for non-aggregate receivers. Package status now reports
`runtime-value-control-tree`.

**Validation:** `Pkg.test()` passes with 567 assertions, including eight focused block/control/callback assertions
and all prior Julia coverage. Commit-time docs/governance validation covers mdBook, memory architecture,
task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.4 — add Julia runtime hash helpers

**Scope:** Julia runtime hash helper/receiver dispatch, copied views and transformations, statement-only named
mutation, direct hash-index assignment integration, merge-slot resolution, explicit flatten splicing, package
status, focused runtime tests, README, task-tree frontier, roadmaps/index, mdBook status/handoff, Knowledge Map,
architecture snapshot, live docs, and resume pointer.

**Change:** Extended `julia/src/runtime/Interpreter.jl` with copied key/value views and pure
merge/pick/drop/rename/set-key transformations, compatible hash-to-array receiver chains, statement-form named
typed `set_key` mutation, base/overlay-aware `merge_hash` argument resolution, map-to-array flattening, and
explicit `flat` / `flat_hash` splicing inside `hash(...)`. Ordinary nested maps remain nested, and the focused
`.spec` proof uses canonical newline-separated statements without redundant semicolons. Package status now
reports `runtime-hash-helpers`.

**Validation:** `Pkg.test()` passes with 559 assertions, including one focused end-to-end hash case and all prior
Julia coverage. Commit-time docs/governance validation covers mdBook, memory architecture, task-tree metadata,
Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.3 — add Julia runtime array helpers

**Scope:** Julia runtime array helper/receiver dispatch, flatten/splice and split bridges, statement-only end
mutations, package status, focused runtime tests, README, task-tree frontier, roadmaps/index, mdBook
status/handoff, Knowledge Map, architecture snapshot, live docs, and resume pointer.

**Change:** Extended `julia/src/runtime/Interpreter.jl` with copied array selection/order/membership and
transform/filter pipelines, delimiter-first joins, one-level flatten/concat and explicit constructor splicing,
tagged records, string/regex split bridges, numeric reducer terminals, `split(array(target), ...)` replacement,
and statement-only `push_back` / `push_front` / `pop_back` / `pop_front` over named and scalar-held arrays. The same
end methods in value positions return `nothing` without mutation. Package status now reports
`runtime-array-helpers`.

**Validation:** `Pkg.test()` passes with 558 assertions, including two focused end-to-end array cases and all
prior Julia coverage. Commit-time docs/governance validation covers mdBook, memory architecture, task-tree
metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.2 — add Julia runtime string numeric helpers

**Scope:** Julia runtime string/scalar and numeric pure helpers, regex value flags, fluent-chain execution, package
status, focused runtime tests, README, task-tree frontier, roadmaps/index, mdBook status/handoff, Knowledge Map,
architecture snapshot, live docs, and resume pointer.

**Change:** Extended `julia/src/runtime/Interpreter.jl` with one canonical function/receiver pure-helper
dispatcher. Julia now executes current string transforms/predicates/splitting/coalescing/definedness/emptiness and
explicit `str_*` comparisons; preserves regex pattern flags internally; executes numeric arithmetic, unary,
reducer, clamp, and comparison helpers through word and symbol aliases; normalizes finite JSON numbers; returns
`nothing` for invalid numeric operations; and composes compatible string/number fluent chains. Package status now
reports `runtime-string-numeric`.

**Validation:** `Pkg.test()` passes with 556 assertions, including two focused end-to-end string/scalar/numeric
cases and all prior Julia coverage. Commit-time docs/governance validation covers mdBook, memory architecture,
task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.1 — add Julia runtime value capture helpers

**Scope:** Julia runtime scalar/array/hash stores, typed snapshots, structural assignments/access, capture helper
reads, package status, focused runtime tests, README, task-tree frontier, roadmaps/index, mdBook status/handoff,
Knowledge Map, architecture snapshot, live docs, and resume pointer.

**Change:** Extended `julia/src/runtime/Interpreter.jl` with separate scalar, array, and hash stores; copied bare
reads; `array(...)` / `hash(...)` / `copy(...)`; array/hash literals; scalar, append, hash-index, and nested
assignment; indexed/nested reads; and final checked no-autovivification nested writes that return updated roots or
`nothing` without partial mutation. Entry/local capture execution now covers bare-name named reads, existence,
named maps, character lengths/spans, and start/end line-column helpers. Package status now reports
`runtime-core-values`.

**Validation:** `Pkg.test()` passes with 554 assertions, including four focused end-to-end core-value/store/capture
cases and all prior Julia coverage. Commit-time docs/governance validation covers mdBook, memory architecture,
task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.3.0 — split Julia runtime helper families

**Scope:** Planning-only decomposition of the broad Julia helper/value runtime container, task-tree frontier,
roadmap/task-tree index, README/mdBook status and handoff text, Knowledge Map pointer, architecture snapshot, live
docs, and resume pointer.

**Change:** Converted `JULIA-BACKEND-PARITY.4.3` into an active container with signoff-sized children: `.4.3.1`
core value/store/capture semantics, `.4.3.2` string/scalar and numeric helpers, `.4.3.3` array helpers, `.4.3.4`
hash helpers, `.4.3.5` value/control/block/callback execution, and `.4.3.6` final helper/value no-drift. The split
reuses the completed Dart rollout as sequencing evidence and makes `.4.3.1` the only executable frontier.

**Validation:** No Julia behavior changed; the `.4.2` 550-assertion result remains the baseline. Commit-time
validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, stale-frontier scans,
and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.2 — add Julia runtime rule interpreter

**Scope:** Julia compiled-rule execution engine, parse result/lifecycle event records, dispatch-facing ActionIR
evaluation, package exports/status, focused interpreter tests, README, task-tree frontier update, roadmap/task-tree
index alignment, mdBook status/handoff/check text, Knowledge Map, architecture snapshot, live docs, and resume
pointer.

**Change:** Added `julia/src/runtime/Interpreter.jl` with `LinkedSpecRuntimeEngine`, `runtime_parse(...)`,
`runtime_execute(...)`, `RuntimeParseResult`, `RuntimeLifecycleEvent`, and `RuntimeInterpreterException`. Julia now
executes compiled default, AND, OR, and bounded/unbounded repetition families in seek/consume mode; preserves
entry/local state across action and blind-call children; carries `retv`; applies `I/LS/LE/IT/EX/LX/E` lifecycle
order; supports explicit call/return, narrow explicit-array/rule accumulators, and entry/local capture reads; emits
the one-element output wrapper; and enforces repetition bounds, zero-progress cutoffs, and same-rule/slot/cursor
recursion guards. Broader helper/value semantics remain `.4.3`. Package status now reports `runtime-dispatch`.

**Validation:** `Pkg.test()` passes with 550 assertions, including 34 focused runtime-interpreter assertions and
the existing runtime-matching/compiled-state/registry/ActionIR/frontend/corpus coverage. Commit-time
docs/governance validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and
`git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.4.1 — add Julia runtime matching state

**Scope:** Julia runtime regex alternatives, match/capture records, cursor and entry/local registers, character and
line/column projection, zero-progress detection, package exports/status, focused matching tests, README, task-tree
frontier update, roadmap/task-tree index alignment, mdBook status/handoff/check text, Knowledge Map, architecture
snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/runtime/Matching.jl` with seek/consume parse modes, stable zero-based alternative
identity, native-PCRE compilation diagnostics, earliest-match/tie ordering, full and compact capture projections,
named captures, zero-based code-unit spans, public character offsets, line/column positions, cursor/capture anchors,
separate entry/local match registers, immutable register updates, and zero-width/zero-progress predicates. Julia's
native PCRE engine accepts the currently required named-capture, POSIX, flag, possessive, and recursive forms
directly. The Julia package status now reports `runtime-matching`.

**Validation:** `Pkg.test()` passes with 516 assertions, including 60 runtime-matching assertions and the existing
compiled-state/registry/ActionIR/frontend/corpus coverage. Commit-time docs/governance validation covers mdBook,
memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.3.4 — add Julia compiled-spec state

**Scope:** Julia compiled-spec/interpreter-state records, dependency-regex state, descriptor projection, package
exports/status, focused compiled-state tests, README, task-tree frontier update, roadmap/task-tree index alignment,
mdBook status/handoff text, Knowledge Map, architecture snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/compiler/CompiledSpec.jl` with `compile_spec(...)`, `CompiledSpec`,
`CompiledRule`, `CompiledRuleModeMetadata`, `DependencyRef`, action/blind edge records, action payload records,
`CompiledDependencyRegexState`, `CompiledDependencyRegexEntry`, `CompiledDescriptorState`, and JSON/descriptor
projection helpers. Julia compiled state now records ordered rule metadata, last-definition-wins metadata when
validation is deliberately skipped, dependency refs, derived dependency-regex rows, lifecycle/plain/action-edge
payload ASTs with registry-aware contracts, function registry projection, and descriptor-shaped `spec` /
`functions` / `dependency_regex_map` / `meta` JSON. The Julia package status now reports `compiled-state`.

**Validation:** `Pkg.test()` passes with 456 tests, including 41 compiled-state assertions and the existing
registry/ActionIR/frontend/corpus coverage. Commit-time docs/governance validation covers mdBook, memory
architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.3.3 — add Julia user-function registry

**Scope:** Julia user-function registry records, staged body parse-job queue exposure, body-AST stitching helper,
registry-aware ActionIR contract resolution, package exports/status, focused registry tests, README, task-tree
frontier update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map, architecture
snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/action/FunctionRegistry.jl` with `UserFunctionRegistry`, `UserFunctionEntry`,
`UserFunctionCallResolution`, duplicate-name diagnostics, ordered registry construction from `SpecFile` or
`FunctionDefinition` records, `body_parse_jobs(...)`, exact-arity lookup, JSON projection, and
`stitch_function_body_ast(...)` for immutable replacement of staged `body_ast` payloads. The ActionIR contract
resolver now accepts `function_registry=...`: exact-arity user calls classify as `family = user_function` before
helper fallback, while wrong-arity registered calls diagnose as `user_function_arity_mismatch`. The Julia package
status now reports `function-registry`.

**Validation:** `Pkg.test()` passes with 415 tests, including 23 user-function registry assertions and the existing
39 Action contract resolver assertions. Commit-time docs/governance validation covers mdBook, memory architecture,
task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.3.2 — add Julia ActionIR contract resolver

**Scope:** Julia ActionIR contract-resolution records, canonical helper-name table, typed-node resolver traversal,
validator helper-name sharing, package exports/status, focused resolver tests, README, task-tree frontier update,
roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map, architecture snapshot, live docs,
and resume pointer.

**Change:** Added `julia/src/action/ActionContracts.jl` with `resolve_action_block_contracts(...)`,
`resolve_action_statement_contracts(...)`, `resolve_action_expression_contracts(...)`,
`canonical_action_helper_name(...)`, and `is_known_action_ir_call_name(...)`. The resolver records current
canonical helper/control contracts through typed ActionIR calls, receiver methods, structural assignments,
structured controls, nested arguments, block values, shape literals, and access expressions. Unknown
helper-looking calls diagnose as generic `unknown_helper`, and raw fallback nodes diagnose as `raw_perl`; there is
no table of non-current helper spellings or Julia-host fallback call path. `validate_spec(...)` now shares the
same current helper/control name predicate for user-function collision checks. The Julia package status now reports
`action-contracts`.

**Validation:** `Pkg.test()` passes with 392 tests, including 39 Action contract resolver assertions. Commit-time
docs/governance validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and
`git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.3.1 — add Julia ActionIR AST parser

**Scope:** Julia helper/action AST data types, typed action parser, package exports/status, focused parser tests,
README, task-tree frontier update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map,
architecture snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/action/ActionAst.jl` and `julia/src/action/ActionParser.jl`. Julia now exposes
`parse_action_block(...)`, `parse_action_statement(...)`, and `parse_action_expression(...)` for typed ActionIR
blocks and value-drop statements. The parser projects calls, literals, variables, indexed/nested access, array and
hash literals, block values, scalar/array/hash/nested assignments, receiver fluent chains, helper/receiver trailing
blocks, structured if/elseif/else/while/switch/case/default controls, and unsupported expressions as structural
`raw_perl` nodes. The Julia package status now reports `action-ast-parser`.

**Validation:** `Pkg.test()` passes with 353 tests, including 74 Action AST parser assertions. Commit-time
docs/governance validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and
`git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.2.4 — project Julia function-definition shells

**Scope:** Julia spec-defined user-function shell projection, package exports/status, focused projection tests,
README, task-tree frontier update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map,
architecture snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/spec/UserFunctionDefinitionShell.jl` with
`project_user_function_definition_asts(...)`, `parse_spec_with_user_function_definition_asts(...)`, and
`definition_nodes_from_user_function_definition_output(...)`. Julia now consumes the neutral
`function_definition` / `function_definition_error` node shape owned by `specs/user_function_definition.spec`,
validates source/body spans and staged sidecars, normalizes `functions.<index>.body_source` paths/job IDs, strips
function-definition spans before rule parsing, and preserves direct `parse_spec(...)` as rule-only rather than a
raw Julia scanner. The Julia package status now reports `function-shell-projection`.

**Validation:** `Pkg.test()` passes with 279 tests, including 27 function-shell projection tests. Commit-time
docs/governance validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and
`git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.2.3 — add Julia frontend validation

**Scope:** Julia source-AST validation, package exports/status, focused validation tests, README, task-tree
frontier update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map, architecture
snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/spec/Validator.jl` with `validate_spec(spec; strict_syntax=false)` and
`SpecValidationException`. The validator checks top-rule presence, duplicate rule labels, duplicate/function
registry records, user-function name/parameter reservations, raw body fallback lines, mixed action/blind edge
families, grouped action-edge target blocks, undefined edge targets, target regex-slot bounds, structural regex
errors, and strict unused-rule detection. The Julia package status now reports `source-validator`.

**Validation:** `Pkg.test()` passes with 252 tests, including 23 source-validator tests over the Dart parity
validation cases, all 21 checked-in `specs/*.spec` files, and rule-only corpus `input.spec` files. Commit-time
docs/governance validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and
`git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.2.2 — add Julia source spec parser

**Scope:** Julia source `.spec` parser, package exports/status, focused parser tests, README, task-tree frontier
update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map, architecture snapshot, live
docs, and resume pointer.

**Change:** Added `julia/src/spec/Parser.jl` with `parse_spec(source)` and `SpecParseException`. The parser turns
core `.spec` rule paragraphs into the `.2.1` source AST types: headers/modes, inline/body regex slots, lifecycle
blocks, action edges, blind-call edges, fluent chains and continuation lines, split/conditional markers, plain
blocks, raw fallback lines, comments, and nested block boundaries. The Julia package status now reports
`source-parser`. Validation, top-level function-shell projection, ActionIR, compilation, runtime execution, and
corpus `--execute` remain later leaves.

**Validation:** `Pkg.test()` passes with 229 tests, including 177 source-parser tests over focused constructs, all
21 checked-in `specs/*.spec` files, and rule-only corpus `input.spec` files. Commit-time docs/governance validation
covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.2.1 — define Julia frontend AST data types

**Scope:** Julia source AST/data records, JSON projection, package exports, focused tests, README, task-tree
frontier update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map, architecture
snapshot, live docs, and resume pointer.

**Change:** Added `julia/src/spec/Ast.jl` with Julia data types for spec files, function definitions, source spans,
staged parse jobs, rule headers/modes, body element variants, edge targets, and fluent calls. The JSON projection
uses the neutral Rust/Dart/mdBook field names (`functions`, `rules`, `source_span`, `body_parse_job`,
`parent_ast_path`, `result_policy`, `failure_policy`, and related span fields). Parser behavior is still deferred;
`.2.2` owns parsing `.spec` text into this data model.

**Validation:** `Pkg.test()` passes with 52 tests, including source-AST JSON round-trip coverage. Commit-time
docs/governance validation covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and
`git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.1.3 — add Julia corpus manifest IO

**Scope:** Julia corpus manifest IO, JSON dependency lock, corpus-runner validation behavior, tests, README,
task-tree frontier update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map,
architecture snapshot, live docs, and resume pointer.

**Change:** Added JSON3-backed corpus manifest loading in `julia/src/corpus/CorpusManifest.jl`. Julia now validates
the checked-in corpus directory, manifest format/count/names, duplicate names, missing/stale fixture directories,
required `input.spec` / `input.txt` / `expected.json` files, and expected JSON syntax. Non-execute corpus commands
report format `1` and 99 fixtures. `--execute` remains deliberately unavailable until parser/runtime semantics
exist.

**Validation:** `Pkg.instantiate()`, `Pkg.test()` (36 tests), Julia-specific corpus validation commands, and
`--execute` rejection pass with `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot`. Docs/governance validation
covers mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`.

## 2026-07-10 — JULIA-BACKEND-PARITY.1.2 — scaffold Julia package

**Scope:** Minimal Julia backend package scaffold, CLI/corpus-runner stubs, smoke tests, README, task-tree frontier
update, roadmap/task-tree index alignment, mdBook status/handoff text, Knowledge Map, architecture snapshot, live
docs, and resume pointer.

**Change:** Added the repo-owned `julia/` package for `LinkedSpecJulia`: `Project.toml`, committed
`Manifest.toml`, module status helpers, Julia-specific CLI entrypoint, corpus-runner entrypoint, scaffold README,
and a Julia `Test` smoke suite. The CLI exposes help/status and a scaffold `corpus` command. The corpus runner
accepts `--corpus <path>` but deliberately rejects `--execute` until `.1.3` adds manifest IO/drift detection.

**Validation:** `Pkg.instantiate()`, `Pkg.test()`, Julia-specific CLI help/status, and corpus-runner scaffold
commands pass with `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot`. Docs/governance validation covers
mdBook, memory architecture, task-tree metadata, Knowledge Map, doctrine, and `git diff --check`. The initial
fresh-depot registry access needed approved network once; the committed manifest records only the local package.

## 2026-07-10 — JULIA-BACKEND-PARITY.1.1 — verify Julia toolchain preflight

**Scope:** Julia backend toolchain/package-layout preflight, task-tree frontier update, roadmap/task-tree index
alignment, mdBook status/handoff text, architecture snapshot, live docs, and resume pointer.

**Change:** Verified that the local Julia backend toolchain is Homebrew-managed Julia `1.12.6`, which matches the
official current stable release. Recorded the exact local command evidence, the writable-depot requirement for
standard-library precompilation under the managed harness, the intended repo-owned `julia/` package layout,
`Pkg.instantiate()` / `Pkg.test()` commands, optional `JuliaFormatter` / `JET` commands, and the Julia-specific
`julia/bin/linkedspec_julia.jl` plus `julia/bin/corpus_runner.jl` entrypoints. The active Julia frontier advances
to `JULIA-BACKEND-PARITY.1.2` for the minimal package scaffold.

**Validation:** Julia version/Homebrew probes and `Pkg`/`Test` import with a writable depot pass. `JuliaFormatter`
and `JET` are absent optional tools. Docs/governance validation covers mdBook, memory architecture, task-tree
metadata, doctrine, and `git diff --check`. No Julia source scaffold or parser behavior changed.

## 2026-07-09 — FUTURE-PARITY-BACKLOG.1.2 — scope Julia backend parity plan

**Scope:** Julia backend task-tree creation, future-backlog frontier update, roadmap/task-tree index alignment,
mdBook status/handoff text, Knowledge Map, architecture snapshot, and live docs.

**Change:** Created `docs/tasks/JULIA-BACKEND-PARITY.md` as the dedicated Julia backend parity plan after the Dart
scoped milestone closed. The Julia lane starts interpreter-first, requires typed `.spec` and helper/action AST
ownership, schedules compiled state/runtime/staged registry/diagnostics/trace/corpus parity work, requires a
Julia-specific CLI during toolchain/package planning, and leaves generated Julia source as a later proof decision.
The next active leaf is `JULIA-BACKEND-PARITY.1.1` for toolchain/package-layout preflight.

**Validation:** Docs/governance validation covers mdBook, memory architecture, Knowledge Map generation/check,
task-tree metadata, doctrine, stale-status scans, and `git diff --check`. No Julia package or implementation code
was created.

## 2026-07-09 — DART-BACKEND-PARITY.7.5 — close Dart parity milestone

**Scope:** Dart task-tree closeout, future-backlog frontier unblocking, roadmaps, mdBook status/handoff text,
architecture snapshot, live docs, resume pointer, and Knowledge Map.

**Change:** Closed the Dart scoped interpreter-first milestone. The Dart tree now records no active frontier:
parser/frontend, typed ActionIR, compiled state, runtime interpretation, staged user-function execution,
diagnostics/trace, focused local verification, Dart-specific CLI productization, and 99/99 corpus execution are
all complete for the accepted milestone. Generated Dart source remains deliberately deferred to a future split
proof lane. Future backend rollout then completed `FUTURE-PARITY-BACKLOG.1.2` for Julia planning and delegated
executable Julia work to `JULIA-BACKEND-PARITY.1.1`.

**Validation:** Focused Dart gate, mdBook build, memory architecture, Knowledge Map generation/check,
task-tree metadata, doctrine, default local CI, stale-status scans, and `git diff --check` pass. The focused Dart
gate includes 140 Dart tests and 99/99 corpus execution; default local CI includes phase0 `1..1028`. No Dart
runtime behavior changed.

## 2026-07-09 — DART-BACKEND-PARITY.7.4 — productize Dart-specific CLI

**Scope:** Dart-specific CLI entrypoint, shared corpus command runner, compatibility corpus-runner wrapper, CLI
smoke coverage, Dart README, mdBook status/handoff text, live docs, roadmaps, resume pointer, and Knowledge Map.

**Change:** `dart run bin/linkedspec_dart.dart` now owns the Dart backend CLI contract. Its `corpus` command
validates or executes the manifest-backed corpus through the existing Dart parse/compile/runtime path, while
`bin/corpus_runner.dart` remains as a compatibility wrapper over the same implementation. Help text, selected
fixture execution, full-manifest execution, and package status text now reflect the 99-fixture corpus boundary.

**Validation:** Focused Dart local gate passes: format, analyzer, 140 tests, CLI help, bounded Dart-specific CLI
corpus smoke, and full 99-fixture corpus execution. Additional `.7.4` validation covers mdBook, memory
architecture, Knowledge Map, task-tree metadata, doctrine, stale-status scans, and `git diff --check`.

## 2026-07-09 — DART-BACKEND-PARITY.7.2 — defer Dart generated source

**Scope:** Dart generated-source deferral, mdBook status, task-tree frontier, live docs, roadmaps, resume
pointer, and Knowledge Map.

**Change:** Generated Dart source is deliberately deferred out of the current Dart parity closeout. The decision
records the prerequisites for a future source-emitter lane: a minimal Dart emitter scaffold/compile-run harness,
generated family-plan metadata, direct execution coverage by structural family, and a curated manifest-backed corpus
subset. The 99/99 interpreter corpus remains the current Dart conformance gate.

**Validation:** mdBook build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine,
stale-status scans, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.7.1 — close Dart mdBook usage status

**Scope:** mdBook Dart backend usage/status/handoff docs, trace-status cross-reference, task tree, live docs,
roadmaps, resume pointer, and Knowledge Map.

**Change:** The mdBook now gives Dart readers one explicit command surface for the focused Dart gate, optional
local-CI integration, direct Dart tests/corpus execution, the 99/99 interpreter-first parity claim, and remaining
limitations: generated Dart source and Dart-specific CLI productization are follow-up lanes, not requirements for
the current corpus conformance claim.

**Validation:** mdBook build, focused Dart gate, default local-CI gate, memory architecture, Knowledge Map
generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.4 — wire Dart local verification

**Scope:** Dart local verification script, optional local-CI integration, root/Dart READMEs, mdBook local-CI and
backend-handoff docs, live docs, roadmap status, resume pointer, and Knowledge Map.

**Change:** Added `tools/run_dart_local.sh` as the focused Dart gate: format, analyzer, full Dart tests, CLI help,
and the full 99-fixture corpus execution. `tools/run_ci_local.sh` remains core-only by default but can include the
Dart gate with `LINKEDSPEC_RUN_DART=1`, avoiding a hard dependency on Dart SDK availability in every checkout.

**Validation:** The focused Dart gate passes; the default local CI gate still skips Dart unless opted in; Dart
format/analyze/full tests, full 99-fixture corpus execution, mdBook, memory architecture, Knowledge Map
generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.3 — close full Dart corpus gate

**Scope:** Dart corpus-runner CLI gate promotion, corpus manifest guard tests, full checked-in corpus execution
test, Dart README, mdBook status/backend handoff, live docs, roadmap status, resume pointer, and Knowledge Map.

**Change:** Dart `--execute` no longer requires `--case` or `--limit`; without a selector it runs the full
manifest in order. The checked-in 99-fixture corpus now passes through Dart parse/compile/runtime execution, while
the manifest loader remains strict about unsupported manifest formats, case-count drift, invalid or duplicate
names, missing fixture directories, stale extra directories, missing required files, and output mismatches.

**Validation:** Full 99-fixture corpus execution passes; focused corpus tests cover the full gate, CLI full-run
mode, manifest format/name guards, drift guards, and mismatch reporting; Dart format, analyze, full tests, mdBook,
memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.5 — route Dart fn corpus through spec shell

**Scope:** Dart function-definition shell execution, corpus runner parsing route, runtime helper parity needed by
the shell, focused parser/runtime/corpus tests, Dart README, mdBook status/backend handoff, live docs, roadmap
status, resume pointer, and Knowledge Map.

**Change:** Dart now executes `specs/user_function_definition.spec` through the runtime to obtain
`function_definition` nodes, normalizes the returned output wrapper shape, and feeds those nodes through
`parseSpecWithStagedUserFunctionDefinitionAsts(...)`. Corpus execution keeps the rule-only `parseSpec(...)` path
for ordinary fixtures and falls back to the spec-defined shell when top-level `fn` source requires it. Runtime
support for statement-form `next()` loop continuation and the documented entry/match line-end helper family was
added because the shell spec depends on those current helper contracts.

**Validation:** The routed three-fixture corpus run passes; focused parser/corpus/runtime/contract tests pass; Dart
format, analyze, full tests, default 99-fixture corpus loader, and the 31-fixture parser-smoke window pass; mdBook,
memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.6 — close Dart structural regex smoke

**Scope:** Dart runtime regex matching, action-edge child payload extraction, focused runtime/corpus tests,
shipped-smoke status, Dart README, mdBook status/backend handoff, live docs, roadmap status, resume pointer, and
Knowledge Map.

**Change:** Dart now routes the exact shipped structural PCRE forms through bounded matchers before normal
`RegExp` compilation: Lispish recursive square brackets, EBNF `\K` / recursive named subpatterns /
`(?(DEFINE)...)` return structures, and spec.spec recursive action/blind/lifecycle/function block forms. Dart also
implements action-edge `push(child, index)` so `ebnf_logging_annotation` preserves indexed quoted-string payloads.

**Validation:** Focused matching/interpreter/corpus-manifest tests pass; the 31-fixture shipped-spec/parser-smoke
window reports 31 passed / 0 failed; Dart format, analyze, full tests, and default 99-fixture corpus loader pass;
mdBook, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check`
pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.5 — close parser smoke no drift

**Scope:** Final shipped-spec/parser-smoke no-drift closeout for the non-PCRE residual group, task-tree frontier
state, Dart README, mdBook status/backend handoff, roadmaps, live docs, resume pointer, and Knowledge Map.

**Change:** No Dart runtime behavior changed. This slice closes the final no-drift leaf after
`ds_vhistory_version_entry` turned green: the 31-fixture shipped-spec/parser-smoke diagnostic window is 24/31
green, all non-PCRE residual leaves are complete, and the only remaining failures are the seven PCRE structural
regex blockers already owned by `DART-BACKEND-PARITY.6.2.4.6`.

**Validation:** Diagnostic shipped-smoke corpus execution reports 24 passed / 7 PCRE structural failures; Dart
format, analyze, and full tests pass; mdBook, memory architecture, Knowledge Map generation/check,
task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.6 — mirror public parser leading trivia

**Scope:** Dart runtime parse entry boundary, focused runtime/corpus tests, shipped-smoke status, Dart README,
mdBook status, live docs, roadmap status, resume pointer, and Knowledge Map.

**Change:** Dart now mirrors the Perl public parser wrapper that resets the input cursor and skips leading blank
lines or `#` comment lines before invoking the top rule. Direct descriptor handlers still bypass that wrapper on
Perl; Dart's public runtime entrypoint now matches the public parser oracle. This closes
`ds_vhistory_version_entry` without weakening ordinary scalar-held indexed reads.

**Validation:** Focused runtime/corpus tests pass; focused `ds_vhistory_version_entry` corpus execution passes; the
31-fixture shipped-smoke diagnostic run is now 24/31 green with only the routed PCRE structural regex blockers
remaining; Dart format, mdBook, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine,
and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.5 — split ds_vhistory oracle boundary

**Scope:** Dart residual parser-smoke task-tree split, Perl/Rust/Dart oracle evidence, mdBook status, live docs,
roadmap status, resume pointer, and Knowledge Map.

**Change:** Closed `.6.2.4.4.5` as an evidence split rather than a runtime patch. Public
`LinkedSpec::get_parser("ds_vhistory")` returns the checked null object name for the leading-newline fixture, while
the direct `vhistory` descriptor handler returns `/proj/foo` for the same source. A minimal public parser still
returns `"name"` for ordinary scalar-held `payload[1]`, so globally weakening Dart `ActionIndexedVarExpr` would
regress valid direct-access behavior. The new `.6.2.4.4.6` leaf owns the actual leading-newline public-parser/oracle
boundary decision.

**Validation:** Perl public-parser, descriptor-handler, scalar-held indexed-read, and leading-newline minimal
probes; focused Dart `ds_vhistory_version_entry` corpus run; Rust `oracle_corpus_matches_perl_reference`; mdBook
build; memory architecture; Knowledge Map generation/check; task-tree metadata; doctrine; and `git diff --check`
pass or record the expected Dart mismatch as evidence. No Dart runtime behavior changed.

## 2026-07-09 — FUTURE-PARITY-BACKLOG.9.0 — capture AND OR edge default correction

**Scope:** Future parity backlog task-tree, roadmap/live docs, mdBook status, resume pointer, and Knowledge Map.

**Change:** Captured the director's corrected AND/OR edge-default model as a future design lane. The parked design
direction is mode-sensitive: AND rules should default bare entries to blind-call sequence semantics, while
OR/default rules should default bare entries to action-edge regex-dispatch semantics. Related questions around
explicit `->` in AND rules, explicit `=>` in OR rules, first-rule-as-top, and OR-rule pipe sugar are owned by the
future design leaf. No parser/runtime behavior changed.

**Validation:** `git diff --check`, memory architecture, Knowledge Map generation/check, task-tree metadata,
doctrine, and mdBook build pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.4 — close Dart legacy accumulator smoke

**Scope:** Dart runtime action-edge `push(Child)` accumulator convention, focused runtime/corpus tests, residual
`ds_vhistory` routing evidence, Dart README/mdBook status, live docs, roadmap status, task-tree status, and
Knowledge Map.

**Change:** Dart now detects one-argument action-edge `push(Child)` calls whose argument names a rule, executes the
child, refreshes `retv`, and appends the child result to the current rule accumulator. This closes
`regdef_nested_register_fields`. `ds_vhistory_version_entry` remains routed to residual closeout because the
checked fixture expects a null object name while the current direct-access surface reads `cur_object[1]` from the
scalar-held `call(object)` payload as `/proj/foo`. The shipped-spec/parser-smoke diagnostic window is now 23/31
green.

**Validation:** Dart format, analyze, focused runtime/corpus tests, full Dart tests, focused structural corpus run,
diagnostic 31-fixture parser-smoke measurement, CLI/help corpus-loader smokes, mdBook build, memory architecture,
Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.3 — close Dart helper mutation surfaces

**Scope:** Dart runtime statement-form helper mutation, entry/local line helpers, explicit split target
replacement, focused runtime/corpus tests, Dart README/mdBook status, live docs, roadmap status, task-tree status,
and Knowledge Map.

**Change:** Dart now executes statement-context `substr(...)` / `regex_subst(...)` mutations against scalar
targets, expands `$n` replacement captures, honors helper regex flags, replaces explicit `split(array(target), ...)`
targets, and exposes entry/local regex start line/column helpers. `simenv_multiline_value`,
`lib_reader_sattribute`, and `lib_reader_cattribute` now pass. The shipped-spec/parser-smoke diagnostic window is
now 22/31 green.

**Validation:** Dart format, analyze, focused runtime/corpus tests, full Dart tests, focused helper/text-normalizing
corpus run, CLI/help corpus-loader smokes, mdBook build, memory architecture, Knowledge Map generation/check,
task-tree metadata, doctrine, and `git diff --check` pass. The diagnostic parser-smoke corpus command measures the
expected 22/31 boundary with the remaining failures routed.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.2 — close Dart hlink delimiter captures

**Scope:** Dart runtime return-channel and scalar-held array append semantics, focused runtime/corpus tests, hlink
corpus diagnostics, Dart README/mdBook status, live docs, roadmap status, task-tree status, and Knowledge Map.

**Change:** Dart `call(...)` now refreshes the runtime `retv` channel with the called child result, and
append-style array mutations now update scalar-held lists created by assignments such as `items = []`. This makes
`push(array(word_items), retv)` visible through later `array(word_items)` reads in `hlink_substitution.spec`, so
all five hlink delimiter/capture fixtures pass. The shipped-spec/parser-smoke diagnostic window is now 19/31 green;
`tablegrep_simple_term` is also green from the same scalar-held append path.

**Validation:** Dart format, analyze, focused runtime/corpus tests, full Dart tests, focused hlink corpus run,
diagnostic corpus run, CLI/help corpus-loader smokes, mdBook build, memory architecture, Knowledge Map
generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.1 — close Dart portmap result shapes

**Scope:** Dart runtime array constructor list-context splicing, focused runtime/corpus tests, portmap corpus
diagnostics, Dart README/mdBook status, live docs, roadmap status, task-tree status, and Knowledge Map.

**Change:** Dart `array(...)` now treats explicit `flat(...)`, `flat_array(...)`, and `flat_hash(...)` call or
fluent arguments as list-context splices, matching the Rust/Perl contract while leaving `copy(...)` and ordinary
array-valued arguments nested. This removes the extra result nesting from `portmap_bare`, `portmap_bit`,
`portmap_slice`, `portmap_constant`, and `portmap_concatenation`; `vhdl_library_use` also turns green because it
depended on the same splice behavior. The shipped-spec/parser-smoke diagnostic window is now 13/31 green.

**Validation:** Dart format, analyze, focused runtime/corpus tests, full Dart tests, focused portmap corpus run,
diagnostic corpus run, mdBook build, memory architecture, Knowledge Map generation/check, task-tree metadata,
doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.4.0 — split Dart residual parser-smoke parity

**Scope:** Dart residual parser-smoke task-tree split, failure routing, Dart README/mdBook status, live docs,
roadmap status, resume pointer, and Knowledge Map.

**Change:** Split the post-recursive/default-mode parser-smoke residuals into focused implementation leaves:
portmap/action-edge child result shape parity, hlink delimiter/capture parity, helper mutation and text
normalization, legacy structural smoke output parity, residual closeout, and the separate PCRE structural-regex
follow-up. The measured boundary remains 7/31 green; no implementation code changed. The next implementation
frontier is `DART-BACKEND-PARITY.6.2.4.4.1`.

**Validation:** mdBook build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine,
and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.3 — close Dart recursive dispatch semantics

**Scope:** Dart compiled action-edge dispatch metadata, runtime action-edge resolution, rule-local aggregate reset
scoping, focused compiler/runtime tests, corpus diagnostics, Dart README/mdBook status, live docs, roadmap status,
task-tree status, and Knowledge Map.

**Change:** Dart compiled action edges now carry resolved regex-dispatch metadata and edge-only child regexes are
folded into each rule's runtime alternation, so tclite-style close edges no longer depend on fragile action-edge
list positions. Runtime dispatch now executes every action edge tied to the matched regex index. Explicit aggregate
resets through `set(array(name), ...)` and `set(hash(name), ...)` now create rule-local bindings restored on rule
exit, matching the Rust/Perl recursive `sexpr` contract while leaving undeclared child mutations caller-visible.
The final shipped-spec/parser-smoke window moves from 2/31 to 7/31 green.

**Validation:** Focused compiler/runtime tests, Dart format/analyze, full Dart tests, selected tclite/top-rule
corpus cases, diagnostic corpus run, mdBook build, memory architecture, Knowledge Map generation/check, task-tree
metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.2 — bridge Dart helper action surfaces

**Scope:** Dart action parser delimiter handling, runtime helper execution, focused parser/runtime tests, corpus
diagnostics, Dart README/mdBook status, live docs, roadmap status, task-tree status, and Knowledge Map.

**Change:** Added Dart execution for direct anonymous capture-slice helpers, diagnostic `print`/`print_each`/`say`
helpers, logical `and`/`or`/`not`, and terminating `exit_now(...)`. The action parser now keeps delimiters inside
quoted helper string arguments when matching call parentheses, so shipped `print("...", "\n")` forms no longer fall
back to raw action expressions. The final shipped-spec/parser-smoke corpus window still measures 2/31 green, but
the helper/action blockers now move to explicit recursion/default-mode/output mismatches, deliberate
`exit_now(...)` diagnostic branches, and already routed PCRE structural regex blockers.

**Validation:** Focused action parser/runtime interpreter tests, Dart format/analyze, full Dart tests, diagnostic
corpus run, mdBook build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.1 — bridge Dart shipped regex dialect

**Scope:** Dart runtime regex normalization, helper regex compilation, focused runtime tests, corpus diagnostics,
Dart README/mdBook status, live docs, roadmap status, task-tree status, and Knowledge Map.

**Change:** Added a shared Dart runtime regex compiler that normalizes the shipped regex dialect forms Dart
`RegExp` lacks: POSIX character classes, inline `i`/`m`/`s` flag groups, scoped inline flag groups accepted by
lowering to non-capturing groups plus Dart `RegExp` flags, possessive quantifier markers, lower-bound `{,n}`
quantifiers, and Python-style named captures. Rule regexes and helper regex values now share that path. The final
shipped-spec/parser-smoke corpus window still measures 2/31 green, but the
previous POSIX/inline-flag/possessive FormatExceptions now move to narrower runtime/helper/output failures. Deeper
PCRE structural constructs (`\K`, `(?&name)`, `(?(DEFINE)...)`) are routed to `DART-BACKEND-PARITY.6.2.4.6`.

**Validation:** Focused runtime matching/interpreter tests, Dart format/analyze, diagnostic corpus run, mdBook
build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check`
pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.4.0 — split Dart shipped corpus smoke batch

**Scope:** Dart corpus-batch task-tree split, failure taxonomy, README/mdBook status, live docs, roadmap status,
resume pointer, and Knowledge Map.

**Change:** Measured the final shipped-spec/parser-smoke corpus window with `--execute --offset 68 --limit 31`.
Dart currently passes `pplugin_empty` and `tkgui_empty`; the remaining failures split into regex-dialect
translation, missing runtime/helper surfaces, recursive/default-mode output semantics, and residual shipped-spec
smoke parity. `.6.2.4` now has focused implementation children with `.6.2.4.1` next for the regex-dialect bridge.
No implementation code changed.

**Validation:** Diagnostic corpus run, mdBook build, memory architecture, Knowledge Map generation/check,
task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — FUTURE-PARITY-BACKLOG.8.0 — capture spec-derived roundtrip idea

**Scope:** Future parity backlog task-tree, roadmap/live docs, mdBook status, resume pointer, and Knowledge Map.

**Change:** Captured the director's `foo.spec` closed-loop idea as a future design lane:
derive both the parser for `foo` and a stimuli generator for that parser solely from `foo.spec`, making `.spec`
the semantic source of truth. The active follow-up is `FUTURE-PARITY-BACKLOG.8.1`; no implementation code changed,
and the Dart frontier remains `DART-BACKEND-PARITY.6.2.4`.

**Validation:** mdBook build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine,
and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.3 — close Dart middle corpus batch

**Scope:** Dart ActionIR argument parsing, runtime helper/value semantics, middle corpus-batch evidence, Dart
README/mdBook status text, live docs, task-tree status, and Knowledge Map facts.

**Change:** Closed the non-`fn` middle terse corpus fixtures by preserving assignment expressions inside helper
argument lists, supporting plain third-argument inline `if(...)` fallback values, evaluating single-argument
numeric aggregate reducers through the aggregate-aware argument path, and aligning scalar-held list/map readback
with the duck-typed assignment contract. Explicit aggregate writes now clear stale scalar-held values so
`set(array(name), ...)` and `set_key(hash(name), ...)` are visible through later receiver/wrapper reads. The owned
middle window is now 25/28 green; the three remaining top-level `fn` fixtures are routed to
`DART-BACKEND-PARITY.6.2.5` because the corpus runner still needs spec-produced `function_definition` nodes rather
than a Dart raw scanner.

**Validation:** Focused ActionIR parser and runtime interpreter tests, Dart format/analyze/full tests, split
execute-mode corpus smokes covering all 25 passing middle fixtures, default corpus loader, corpus runner/CLI help,
mdBook build, memory architecture, Knowledge Map check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.2 — close Dart starter corpus batch

**Scope:** Dart runtime interpreter semantics, focused runtime tests, starter corpus-batch evidence, Dart
README/mdBook status text, live docs, task-tree status, and Knowledge Map facts.

**Change:** Closed the first shipped-corpus execution batch by making Dart treat non-null empty aggregate returns
as successful rule matches, making blind child dispatch trust the child rule's match bit instead of output
truthiness, and executing marker-form `if(...)` / `elseif(...)` / `else()` / `endif()` statement chains as one
branch group. The previously failing starter fixtures for empty `copy(hash(...))` returns and boolean/mutation
marker-form flow now pass, bringing the bounded `--execute --limit 40` corpus run green.

**Validation:** Focused runtime interpreter tests, Dart format/analyze/full tests, default 99-fixture corpus loader,
corpus runner help, bounded 40-fixture execute-mode smoke, CLI help, mdBook build, memory architecture, Knowledge
Map check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.1 — add Dart executable corpus selection

**Scope:** Dart corpus-runner CLI, corpus execution selection API, focused corpus tests, Dart README/mdBook
status text, live docs, task-tree status, and Knowledge Map facts.

**Change:** Added named and bounded fixture selection to `executeCorpusFixtures(...)` via `caseNames`,
`offset`, and `limit`. `bin/corpus_runner.dart` now supports opt-in `--execute` mode with repeated `--case`,
`--offset`, and `--limit` flags, prints per-fixture pass/fail lines plus a summary, returns nonzero on selected
fixture failures, and rejects unbounded CLI execution until the full corpus gate is ready. The default
`--corpus <path>` command remains the stable 99-fixture manifest-loader smoke.

**Validation:** Focused corpus manifest tests, Dart format/analyze/full tests, default 99-fixture corpus loader,
corpus runner help, bounded execute-mode smoke, explicit unbounded-execute rejection, mdBook build, memory
architecture, Knowledge Map check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.2.0 — split Dart corpus expansion batches

**Scope:** Dart corpus-parity task-tree split, live docs, roadmap status, and resume pointer.

**Change:** Split the broad `.6.2` shipped 99-fixture corpus expansion into committed child leaves for
opt-in executable corpus selection/reporting, starter proof-edge/autoexist/core terse fixtures,
helper/control/receiver/user-function/tree traversal fixtures, and shipped-spec/parser-smoke fixtures. No
parser/runtime behavior changed in this planning slice.

**Validation:** mdBook build, memory architecture, Knowledge Map check, task-tree metadata, doctrine, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.6.1 — add Dart controlled corpus execution

**Scope:** Dart corpus execution harness, focused controlled corpus tests, public Dart exports, mdBook/status
text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added `executeCorpusFixtures(...)` plus `CorpusExecutionResult` /
`CorpusFixtureExecutionResult` to run manifest-backed fixtures through `parseSpec(...)`, `compileSpec(...)`,
and `LinkedSpecRuntimeEngine`. The harness preserves manifest validation, compares runtime output against the
backend-neutral expected value wrapped one level, reports every fixture failure without aborting the run, and
uses structural JSON equality for list/map payloads. Focused temporary corpus fixtures now prove scalar output,
nested array/hash/null/boolean output, rule dispatch, lifecycle return shape, and mismatch reporting before the
full 99-fixture manifest expansion.

**Validation:** Focused corpus manifest tests, Dart format/analyze/full tests, default 99-fixture corpus loader,
corpus runner help, CLI help, mdBook build, memory architecture, Knowledge Map generation/check, task-tree
metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.5.3 — preserve Dart staged descriptor shapes

**Scope:** Dart compiled-state descriptor tests, mdBook descriptor/status text, live docs, roadmap/task-tree
status, and Knowledge Map facts.

**Change:** Added a focused Dart descriptor-shape proof for staged user functions. The new compiled-state test
starts from spec-returned `function_definition` nodes, dispatches `body_parse_job` records through the Dart staged
registry, compiles the stitched `SpecFile`, asserts parsed function order, compiled registry jobs, descriptor
`body_payload`, normalized `body_parse_job`, stitched `body_ast`, descriptor `function_order` / `function_count`,
and stable runtime output from the same compiled state.

**Validation:** Focused compiled-state tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook
build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check`
pass.

## 2026-07-09 — DART-BACKEND-PARITY.5.2 — execute Dart user functions

**Scope:** Dart runtime interpreter, focused runtime tests, Dart CLI/scaffold status, Dart README, mdBook status
text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added Dart runtime execution for registered exact-arity user functions before ordinary helper
fallback. Calls evaluate args eagerly in the caller, bind params into fresh function-local scalar/array/hash
stores, execute parsed ActionIR function bodies as value blocks, return the final expression or local
`return(...)` payload, feed returned values into compatible receiver chains, execute standalone calls with
dropped results, diagnose registered arity mismatches, and reject direct/mutual recursion with structured
`user_function_call` diagnostics.

**Validation:** Focused runtime interpreter tests, Dart format/analyze/full tests, corpus runner, CLI help,
mdBook build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.5.1 — add Dart staged function-body registry

**Scope:** Dart staged parser registry, package exports, focused staged-dispatch tests, Dart README, mdBook
pipeline/status/handoff text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added the minimal Dart staged parser registry for function-body parse jobs. `actionir-body.spec`
resolves to `builtin:actionir-body.spec`, loads the fixed ActionIR-body adapter digest, compiles top rule
`action_block` with staged cache-key metadata, executes queued jobs in stable parent-path/source-span/job-id order,
and stitches returned `action_block` JSON into `body_ast` through `dispatchFunctionBodyParseJobs(...)` and
`parseSpecWithStagedUserFunctionDefinitionAsts(...)`.

**Validation:** Focused staged-registry tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook
build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check`
pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.5.4 — close Dart diagnostics trace no drift

**Scope:** Dart diagnostics/trace status no-drift across README, CLI/scaffold text, mdBook trace/status/handoff
pages, live docs, roadmap, task-tree index, MEMORY, and Knowledge Map facts.

**Change:** Closed the `.4.5` diagnostics/trace container. All live status surfaces now agree that Dart has
structured runtime diagnostics, trace controls/sinks/events, and runtime interpreter trace events; Dart still does
not claim full backend parity, and the active frontier advances to `.5.1` staged registry work.

**Validation:** CLI help, focused drift scans, mdBook build, memory architecture, Knowledge Map generation/check,
task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.5.3 — add Dart runtime trace events

**Scope:** Dart runtime interpreter tracing, focused trace coverage, Dart CLI/scaffold status, Dart README,
mdBook trace/status/handoff text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added trace-only runtime instrumentation behind the optional `LinkedSpecTraceEmitter`: rule scopes,
recursion-cutoff decisions, regex match/no-match decisions, action-edge and blind-call child-dispatch decisions,
lifecycle block marks, cursor-control helper marks, and `capture_until_boundary(...)` source-boundary marks.
Untraced execution remains default-quiet and traced parse results preserve the untraced output JSON.

**Validation:** Focused trace tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook build, memory
architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.5.2 — add Dart trace controls

**Scope:** Dart trace-control module, runtime traced entrypoints, public exports, focused trace tests, Dart
README/CLI/scaffold status, mdBook trace/status/handoff text, live docs, task-tree metadata, and Knowledge Map
facts.

**Change:** Added Dart trace levels, `LinkedSpecTraceConfig`, documented environment control parsing, structured
event/scope/decision/log/dump primitives, stdout/routed-file/mirror sink behavior, reset/truncate support, and
`LinkedSpecRuntimeEngine` traced entrypoints. Traced runtime entrypoints preserve successful parse output and emit
a parse-scope event; branch/lifecycle/source-boundary runtime instrumentation remains `.4.5.3`.

**Validation:** Focused trace tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook build, memory
architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.5.1 — add Dart runtime diagnostics

**Scope:** Dart runtime diagnostic API, public package exports, focused runtime coverage, Dart README/CLI status,
mdBook diagnostics/runtime/status/handoff text, live docs, task-tree metadata, and Knowledge Map facts.

**Change:** Added `RuntimeDiagnostic` and attached it to `RuntimeInterpreterException.diagnostic`. Runtime failures
now carry stable structured fields for `type`, `stage`, `owner_stage`, `summary`, `detail`, `top_rule`,
`rule_label`, `handler_source_label`, and optional `spec_name` / `spec_path`; `LinkedSpecRuntimeEngine` accepts
optional source identity and preserves richer lower-level diagnostics when wrapping failures. Successful
`RuntimeParseResult` output remains unchanged.

**Validation:** Focused runtime interpreter tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook
build, memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and `git diff --check`
pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.5.0 — split Dart diagnostics trace controls

**Scope:** Dart backend task-tree planning, task-tree index, roadmap tracker, live docs, and Knowledge Map facts.

**Change:** Split the broad Dart runtime diagnostics/trace-controls leaf before code. The `.4.5` container now has
focused implementation leaves for structured runtime diagnostics (`.4.5.1`), trace levels/controls/event
classes/sinks (`.4.5.2`), runtime branch/lifecycle/source-boundary trace instrumentation (`.4.5.3`), and
no-drift closeout (`.4.5.4`). The active implementation frontier is `.4.5.1`.

**Validation:** Memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and
`git diff --check` pass. No Dart runtime behavior changed.

## 2026-07-09 — BACKTRACK-SURFACE-RUST-ALIGNMENT.2 — add non-consuming boundary capture

**Scope:** Perl ActionIR contracts/scanner/canonical events, Rust runtime/validation/tests, Dart ActionIR
contracts/runtime/tests, active EBNF spec/corpus copies, mdBook helper/runtime/status text, live docs, task-tree
metadata, and Knowledge Map facts.

**Change:** Added `capture_until_boundary(rule[, ...])` as the cross-variant zero-width/lookahead boundary
primitive. The helper starts at the live cursor, probes one or more named boundary rules, captures text before the
earliest boundary match, and leaves that boundary unconsumed for the normal rule path. If at least one named
boundary resolves but no later boundary is found, it captures to end-of-input and moves the cursor there; if no
requested boundary resolves to a usable pattern, it returns `undef`/`null` and leaves the cursor unchanged. The
active EBNF `semantic_annotation` rule now uses this helper to stop before the next `semantic_annotation` or
`grammar_rule`, eliminating the previous consume-then-rewind workaround.

**Validation:** Focused Perl probe for `capture_until_boundary(...)` passes and leaves the next structural
boundary unconsumed; `PERL5LIB= perl -Iperl t/phase0_regression.t` passes `1..1028`; Rust formatting,
`linkedspec-core`, and `linkedspec-runtime` package tests pass;
Dart format/analyze/full tests pass; `mdbook build docs/linkedspec-book`, Knowledge Map generation/checks, memory
architecture, doctrine driver, local CI, and `git diff --check` pass.

## 2026-07-09 — BACKTRACK-SURFACE-RUST-ALIGNMENT.1 — replace backtrack surface with explicit cursor controls

**Scope:** Perl ActionIR contracts/scanner/canonical events, Rust runtime/validation/tests, Dart ActionIR
contracts/runtime/tests, active EBNF spec/corpus copies, mdBook runtime/helper/status text, live docs, task-tree
metadata, and Knowledge Map facts.

**Change:** Retired the broad current `BACKTRACK`/`IBACKTRACK` helper surface and the lowercase
`backtrack(label)` / `ibacktrack(label)` forms in favor of explicit cursor controls. Perl, Rust, and Dart now
share `save_cursor()` / `restore_cursor()` for stack-based cursor save/restore, and
`rewind_match_start()` / `rewind_entry_start()` for direct lifecycle-anchor rewinds. The active EBNF
`semantic_annotation` rule and Rust corpus copies moved from `BACKTRACK()` to `rewind_match_start()` as the
semantic-preserving current spelling. The zero-width/lookahead boundary primitive is recorded as the next required
cross-variant capability so the EBNF case can later avoid consume-then-rewind entirely.

**Validation:** Perl syntax checks for the edited ActionIR modules and phase0 test pass; `PERL5LIB= perl -Iperl
t/phase0_regression.t` passes `1..1027`; `bash tools/run_ci_local.sh` passes; Rust `cargo fmt --all --check`,
`cargo test -p linkedspec-core`, and `cargo test -p linkedspec-runtime` pass; Dart format/analyze/full tests, CLI
help, and corpus runner pass; `mdbook build docs/linkedspec-book`, Knowledge Map, memory architecture, doctrine
driver, active old-helper scan, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.4 — add Dart backtrack cursor rewinds

**Scope:** Dart runtime cursor/input helper execution, BACKTRACK/IBACKTRACK cursor rewinds, focused runtime
coverage, Dart package/CLI status text, mdBook runtime/status/handoff text, live docs, roadmap/task-tree status,
and Knowledge Map facts.

**Change:** Extended `LinkedSpecRuntimeEngine` with cursor-aware helper dispatch. `BACKTRACK()` now rewinds the
live cursor to the current local match start, while `IBACKTRACK()` rewinds it to the initial/entry match start for
the current context; the `I` is the Initial/`I` lifecycle context rather than case-insensitivity. The rewind is
cursor-only: match records, variables, accumulators, and branch state are not rolled back. The runtime also exposes
char-based cursor/input helpers including `cursor_pos`, `cursor_line`, `cursor_col`, `cursor_rest`,
`cursor_rest_len`, `input_text`, `input_len`, `input_slice`, `input_end_pos`, `input_end_line`, and
`input_end_col`, while preserving Dart's internal code-unit cursor state. A later Rust-reference cleanup removes
the short-lived Dart lowercase backtrack compatibility aliases before they become a durable public surface.

**Validation:** Focused runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook, memory
architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.6 — close Dart helper value no drift

**Scope:** Dart runtime nested assignment no-drift fix, focused runtime coverage, package README, mdBook
status/handoff text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Closed the `.4.3` Dart helper/value container by aligning nested value-path assignment with the
Perl/Rust contract. Successful nested writes now return the updated root aggregate; missing or wrong intermediate
paths return `null` without mutating; final hash keys may be created; final array writes only replace an existing
slot or append exactly at `len`; and intermediate containers are no longer autovivified. Direct hash-index
assignment on scalar-held map/list roots now preserves root ownership and array index boundaries before falling
back to named hash storage. Nested assignment now also evaluates segment index expressions before the RHS value,
matching the Perl/Rust lowering order.

**Validation:** Focused parser/runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.5 — add Dart runtime controls and tree callbacks

**Scope:** Dart action parser branch splitting, runtime value-block/control/callback execution, focused
parser/runtime tests, Dart CLI help, package README, mdBook Dart handoff/status text, live docs,
roadmap/task-tree status, and Knowledge Map facts.

**Change:** Extended Dart runtime helper/value execution with expression-valued blocks, block-local
`return(...)` / `return_undef()`, attached `if` / `elseif` / `else` and `when` / `otherwise` branch chains,
attached `switch` / `case` / `default`, attached `while` with the deterministic iteration guard, inline lazy
`if(...)` / `switch(...)`, helper-form `with(value) { ... }` / `with() { ... }`, receiver `.with() { ... }`,
and hash/array `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver callbacks. Callback frames
bind scoped `value`, `path`, `depth`, hash `key`, array `index`, and reduce-only `acc`, then restore any outer
scalar/array/hash bindings.

**Validation:** Focused parser/runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.7.3 — record variant-specific CLI requirement

**Scope:** Dart backend task-tree planning, future-backlog directive capture, top-level task-tree index,
live docs, mdBook Dart handoff text, roadmap trackers, and Knowledge Map facts.

**Change:** Recorded the director directive that each LinkedSpec backend variant should have a distinct CLI.
The Dart tree now has a docs-only `.7.3` planning slice, a pending `.7.4` Dart-specific CLI productization leaf,
and `.7.5` as the shifted final no-drift closeout. The future-backlog tree now carries the cross-variant
requirement so Julia and Lua planning must include their own CLI ownership when those lanes activate.

**Validation:** mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine checks, and
`git diff --check` pass. No source behavior changed.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.4 — add Dart runtime hash helpers

**Scope:** Dart runtime hash helper evaluator, focused interpreter/contract tests, Dart CLI help, package README,
mdBook Dart handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Extended Dart runtime helper execution with hash-aware argument evaluation and receiver dispatch.
The runtime now executes `count_keys`, `sorted_keys`, `sorted_values`, `has_key`, `merge_hash`, `set_key`,
`rename_key`, `drop_keys`, `pick_keys`, `flat_hash`, and hash receiver chains. Statement-form `set_key(...)`
mutates named working hashes, while value-form and receiver-form `set_key(...)` remain pure unless assigned back.
`merge_hash(copy(hash(base)), overlay)` preserves the documented bare-overlay boundary, direct hash-index
assignment values return hash snapshots, and `hash(... flat(...))` splices only explicit flat-style hash arguments
instead of ordinary map field values.

**Validation:** Focused runtime interpreter and ActionIR contract tests, Dart format/analyze/full tests, corpus
runner, CLI help, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis evidence,
and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.3 — add Dart runtime array helpers

**Scope:** Dart runtime array helper evaluator, ActionIR contract recognition, focused interpreter/contract tests,
package README, mdBook Dart handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Extended Dart runtime helper execution with array-aware argument evaluation and receiver dispatch.
The runtime now executes array helper family breadth: count/first/last, order/select helpers, membership/index
helpers, delimiter-first `join_values`, split bridges with regex delimiters, transform/filter pipelines,
`flat_array` / `concat_arrays`, `split_tagged_records`, array numeric reducers, bare array working-variable
receiver chains, and statement-only `push_back` / `push_front` / `pop_back` / `pop_front` mutations. Value-slot end
mutations return `null` and leave arrays unchanged.

**Validation:** Focused runtime interpreter and ActionIR contract tests, Dart format/analyze/full tests, corpus
runner, CLI help, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis evidence,
and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.2 — add Dart runtime string numeric helpers

**Scope:** Dart runtime pure helper evaluator, focused interpreter tests, package README, mdBook Dart
handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Extended `LinkedSpecRuntimeEngine` pure helper execution beyond the core value/capture subset.
The Dart runtime now canonicalizes ActionIR helper names through the shared contract table, evaluates
string/scalar helpers and receiver chains, executes explicit `str_*` lexical comparisons, and supports numeric
arithmetic, reducers, comparisons, word aliases, arithmetic/comparison symbol callees, and numeric receiver chains.
Unsupported numeric inputs and invalid arithmetic such as divide-by-zero return `null` rather than throwing.

**Validation:** Focused runtime interpreter tests, Dart format/analyze/full tests, corpus runner, CLI help,
mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis evidence, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.1 — add Dart runtime value capture helpers

**Scope:** Dart runtime core value/store evaluator, focused interpreter tests, package README, mdBook Dart
handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Extended `LinkedSpecRuntimeEngine` beyond the `.4.2` dispatch-facing evaluator with core value
semantics: scalar/array/hash/null/boolean/number shapes survive assignment and wrapper snapshots; `hash(...)` and
`set(hash(...), ...)` work; hash-index mutation and nested reads execute; map indexing supports non-numeric keys;
`copy(...)`, `array(...)`, and `hash(...)` read typed aggregate stores or variable-held shapes; and `entry_*` /
`match_*` now include named capture reads, participation checks, named maps, lengths, and start/end positions with
bare capture-name syntax.

**Validation:** Focused runtime interpreter test, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.3.0 — split Dart runtime helper families

**Scope:** Dart runtime helper/value task-tree split, live docs, task-tree index, and resume pointer.

**Change:** Split the broad `.4.3` runtime value/helper-family leaf before code. The child leaves now isolate
core value/store/capture helpers, string/number helpers, array helpers, hash helpers, value-block/control/tree
traversal helpers, and final helper/value no-drift closeout. The first child frontier was `.4.3.1`.

**Validation:** Memory architecture, task-tree metadata, doctrine checks, and `git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.2 — add Dart runtime rule interpreter

**Scope:** Dart runtime rule dispatch, lifecycle execution, focused interpreter tests, public exports,
package README, mdBook Dart handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added `dart/lib/src/runtime/interpreter.dart` with `LinkedSpecRuntimeEngine`,
`RuntimeParseResult`, `RuntimeLifecycleEvent`, and `RuntimeInterpreterException`. The interpreter runs compiled
rules over the `.4.1` matching state, supports default/AND/OR/repetition families, action-edge and blind-call
dispatch, entry/local match handoff, explicit `return(...)` / `return_undef()`, `retv`, accumulator collection,
bounded repetition, zero-progress cutoffs, and a small dispatch-facing ActionIR evaluator for `set`, `push`,
`array`, `copy`, `cat`, `call`, `entry_*`, and `match_*`. Broader helper/value semantics remain owned by `.4.3`.

**Validation:** Focused `dart test test/runtime_interpreter_test.dart`, `dart format --set-exit-if-changed .`,
`dart analyze --fatal-infos --fatal-warnings`, full `dart test`, the 99-fixture corpus manifest runner, corpus
runner help, CLI help, mdBook build, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.4.1 — add Dart runtime matching state

**Scope:** Dart runtime regex matching primitives, match-state tracking API, focused tests, package README,
mdBook Dart handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added `dart/lib/src/runtime/matching.dart` with `RuntimeRegexAlternation`,
`RuntimeRegexMatch`, `RuntimeMatchRegisters`, `LinkedSpecParseMode`, line/column helpers, and char/code-unit
offset conversion helpers. The matcher supports seek and consume modes, stable alternative indexes, compiled-rule
regex lists, capture-only groups, named captures, char-offset projection over Dart code-unit match spans,
entry/local match separation for child invocation state, cursor position reporting, and zero-progress detection.

**Validation:** Focused `dart test test/runtime_matching_test.dart`, `dart format --set-exit-if-changed .`,
`dart analyze --fatal-infos --fatal-warnings`, full `dart test`, the 99-fixture corpus manifest runner, corpus
runner help, CLI help, mdBook build, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.3.4 — add Dart compiled spec state

**Scope:** Dart compiled-spec state API, descriptor projection, dependency-regex data, focused tests, package
README, mdBook Dart handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added `dart/lib/src/compiler/compiled_spec.dart` with `compileSpec(...)`, `CompiledSpec`,
`CompiledRule`, `CompiledDependencyRegexState`, `CompiledDescriptorState`, dependency refs, rule mode metadata,
and compiled action payload records. The compiler validates source ASTs by default, preserves definition and
compiled rule order, records last-definition metadata when validation is deliberately skipped, derives structured
dependency-regex entries from child rule regex slots, carries the `UserFunctionRegistry`, parses lifecycle and
edge action payloads into `ActionBlock` ASTs, resolves their ActionIR contracts with registry-aware user-call
classification, and projects public descriptor-shaped JSON with `spec`, `functions`, `dependency_regex_map`, and
`meta`.

**Validation:** Focused `dart test test/compiled_spec_test.dart`, `dart format --set-exit-if-changed .`,
`dart analyze --fatal-infos --fatal-warnings`, full `dart test`, the 99-fixture corpus manifest runner, corpus
runner help, CLI help, mdBook build, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
`git diff --check` pass.

## 2026-07-09 — DART-BACKEND-PARITY.3.3 — add Dart function registry

**Scope:** Dart user-function registry API, ActionIR contract resolver integration, Dart tests, package README,
mdBook Dart handoff/status text, live docs, roadmap/task-tree status, and Knowledge Map facts.

**Change:** Added `dart/lib/src/action/function_registry.dart` with `UserFunctionRegistry`,
`UserFunctionEntry`, and `UserFunctionCallResolution`. The registry preserves ordered `FunctionDefinition`
records, params, arity, source/body spans, `body_payload`, `body_parse_job`, optional stitched `body_ast`, and
staged function-body parse jobs. `resolveActionBlockContracts(...)`, `resolveActionStatementContracts(...)`, and
`resolveActionExpressionContracts(...)` now accept an optional registry and classify exact-arity user calls before
helper fallback; wrong-arity registered calls diagnose as `user_function_arity_mismatch`.

**Validation:** Focused `dart test test/function_registry_test.dart test/action_contracts_test.dart`,
`dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`, full `dart test`,
`dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, corpus runner help, CLI help,
and mdBook build pass.

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.5 — close helper purge no-drift

**Scope:** Final active source/test/tool/spec no-drift scan, Rust runtime unit-test fixture cleanup, live docs,
task-tree closure, roadmap status, and Knowledge Map facts for the non-current helper purge.

**Change:** Closed the purge by migrating the last active Rust runtime unit-test fixture that still embedded
retired helper-call strings for generic fallback coverage. The fixture now uses invented unknown helper names and
keeps the same null/no-mutation expectations. The task tree is marked done, roadmap rows move the purge to done,
and the resume pointer returns the PNT frontier to `DART-BACKEND-PARITY.3.3`.

**Validation:** Final exact retired-helper call-shape scans, retired label/tag scans, exact `?concat:` scans,
scalar-wrapper scans, and short-wrapper spec-surface scans are clean or classified as non-helper input text.
`cargo fmt --manifest-path rust/Cargo.toml --all --check` and focused
`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime
helpers_5_1_unknown_helper_spellings_use_generic_unknown_helper_path` pass.

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.4 — migrate retired helper fixtures

**Scope:** Active Perl/Rust tests, tooling examples, generated Rust oracle corpus inputs, checked-in `.spec`
label/output strings, mdBook spec walkthroughs, live docs, and Knowledge Map facts for the non-current helper purge.

**Change:** Active executable fixtures no longer embed retired helper spellings as helper calls or colliding
labels/tags. Inspection-tool examples now use current `return(...)` syntax, metadata tests use invented
unknown-helper names for generic diagnostics, and validation fuzzing uses current assignment syntax. EBNF return
annotation rule/output labels were renamed to `return_scalar_value` / `return_array_value` in `specs/ebnf.spec`
and the copied corpus inputs. Portmap concatenation output was renamed from `?concat:` to `?concatenation:` in
`specs/portmap.spec`, Rust corpus expected output, integration tests, Perl regression locks, and mdBook examples.

**Validation:** Exact retired-helper call-shape scans, retired label/tag scans, and exact `?concat:` scans are
clean over active test/tool/spec/corpus/book surfaces. Syntax checks pass for touched Perl tests/tools. Focused
Perl tests, full `t/phase0_regression.t` (`1027` tests), regenerated 99-fixture oracle corpus,
`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle`, full
`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime`, and `mdbook build
docs/linkedspec-book` pass.

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.3 — purge Rust helper diagnostics

**Scope:** Rust parser/validation/runtime retired-helper source paths, Rust docs/fixtures touched by verification,
mdBook status/backend handoff, live docs, and Knowledge Map facts for the non-current helper purge.

**Change:** Rust no longer preserves retired helper spellings as known ActionIR helper names or as
name-specific runtime diagnostics. Removed the `declare(...)` keyword-argument parser exception, deleted the
runtime `retired_helper_error(...)` dispatch branch, and renamed internal runtime context append/snapshot helpers
away from retired public-looking names. Retired helper-looking calls now follow the generic unknown-helper fallback
(`undef` plus warning). Current hash-literal display now emits `{ key : value }`, and one positive Rust
parser/runtime fixture was migrated from retired fat-arrow hash-literal syntax to current colon syntax while the
explicit fat-arrow retirement diagnostic tests remain.

**Validation:** Rust focused retired-helper scans, `cargo fmt --manifest-path rust/Cargo.toml --all --check`,
`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core`,
`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime`, and focused runtime
`helpers_5_1_retired_terse_8_4_spellings_use_generic_unknown_helper_path` / `scalaref_retirement_4` runs pass.

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.2.4 — close Perl source purge scans

**Scope:** Perl source purge closeout scans/probes, roadmap/task-tree status, mdBook project status,
architecture state, live docs, and Knowledge Map facts for the non-current helper purge.

**Change:** Closed the Perl source container for the non-current helper spelling purge without additional source
edits. Focused scans over `perl/LinkedSpec.pm` and `perl/LinkedSpec` show no exact retired helper call-shape
recognition paths for the `SPEC-FORMAT-TERSE.8` spelling set; remaining exact-name matches are ordinary
raw-compat comments about declaration generation. Direct `call_spec_handler_subst` probes confirm current
`cat(...)`, `copy(...)`, `set(...)`, and `push(...)` still lower through current helper names, while retired
value-position helper-looking calls such as `concat(...)`, `a(...)`, and `scalaref(...)` use the same generic
unsupported-helper sentinel path as an invented unknown helper. The active frontier moves to Rust source cleanup.

**Validation:** Exact retired-helper call-shape scans over Perl source, direct current-helper and retired-helper
behavior probes, `perl -c perl/LinkedSpec.pm`, `perl -c -Iperl t/noncurrent_helper_metadata.t`, `prove -q -Iperl
t/noncurrent_helper_metadata.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t
t/trace_actionir_pipeline.t`, and `PERL5LIB= prove -q -Iperl t/phase0_regression.t` pass (`1027` tests).

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.2.3 — purge Perl helper metadata names

**Scope:** Perl ActionIR contract metadata, focused metadata regression coverage, mdBook/architecture
status, live docs, and Knowledge Map facts for the non-current helper purge.

**Change:** Raw-Perl passthrough contracts no longer publish exact retired helper names through
`diag_name`: lexical declaration and raw assignment compatibility events now use neutral `raw_*`
diagnostic labels instead of `declare` / `assign`. Added `t/noncurrent_helper_metadata.t` to lock the
ActionIR contract table, rewrite-contract metadata, canonical ActionIR events, and generic unsupported-helper
events against the `SPEC-FORMAT-TERSE.8` retired helper set. The mdBook and architecture notes now state that
deleted helper names are not replacement-canonicalized and that retired `push_value(...)` /
`push_nonempty(...)` statement spellings are not current typed helper statement contracts.

**Validation:** `perl -c -Iperl perl/LinkedSpec/ActionIR/Contracts.pm`, `perl -c -Iperl
t/noncurrent_helper_metadata.t`, `prove -q -Iperl t/noncurrent_helper_metadata.t`, focused exact metadata
scan, `prove -q -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t
t/noncurrent_helper_metadata.t`, and `PERL5LIB= prove -q -Iperl t/phase0_regression.t` pass (`1027`
tests).

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.2.2 — purge Perl declaration and return helper paths

**Scope:** Perl ActionIR declaration/setup owners, return-family/helper-call classification, short-wrapper
source-owner paths, active Perl regression fixtures, mdBook helper/status chapters, live docs, and Knowledge Map.

**Change:** Removed the Perl source-owner paths that still recognized removed declaration helper spellings, old
return-family helper spellings, and old short-wrapper spellings through dedicated extractor, lowerer, contract,
scanner, canonical-event, rewrite-pipeline, and control-flow lookahead branches. Active tests now use current
`return(...)`, `set(...)`, assignment/reset, `array(...)`, `hash(...)`, `push(...)`, `copy(...)`, and bare-read
forms, or generic invented helper names where the test is specifically about generic diagnostics. The mdBook
helper references now describe current working-variable setup and value/container flow without preserving removed
helper-call spellings as compatibility/reference content.

**Validation:** Syntax checks pass for touched Perl owners and tests. `prove -q -Iperl
t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t` passes, and `PERL5LIB= prove -q -Iperl
t/phase0_regression.t` passes with `1027` tests. Scoped scans over edited mdBook helper/status chapters and
touched Perl/test surfaces are clean for exact removed helper-call source-owner spellings, with remaining matches
limited to ordinary Perl implementation words or built-in `scalar(...)` usage.

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.2.1 — purge Perl current helper compatibility

**Scope:** Perl ActionIR current helper lowering, append contract/scanner dispatch, bootstrap helper classification,
AST/parser regression tests, mdBook, and live docs.

**Change:** Current `cat(...)`, `copy(...)`, `set(...)`, and `push(...)` paths now stay on current method and
contract names in Perl source. Removed the old current-helper normalization through non-current string/copy/
assignment names, deleted the short-wrapper alias helper path from AST known-call handling, removed the
removed append-helper contract/scanner/lowering branches, and renamed the explicit append lowerer/dependency
to current `push` terminology. The `set(...)` owner now uses a current-only top-level argument fallback for
slash-regex payloads instead of relying on the older normalized method name path, and the bootstrap return
payload classifier no longer whitelists deleted current-helper-family names. `t/actionir_ast_parser.t` now
fabricates current `set`/`push` AST calls and expects the current `__ls_cat_*` generated local names.

**Validation:** Syntax checks pass for touched Perl ActionIR/RuleIR/bootstrap owners. `prove -q -Iperl
t/actionir_ast_parser.t`, `prove -q -Iperl t/trace_actionir_compact_lowerers.t`, `PERL5LIB= prove -q -Iperl
t/phase0_regression.t` (`1..1028`), direct `call_spec_handler_subst` probes for current `return(cat(...))`,
`set(..., cat(...))`, aggregate `set(...)`, and `push(array(...), cat(...))`, plus a focused deleted-spelling
scan over the touched Perl/test paths pass.

## 2026-07-09 — NONCURRENT-HELPER-CODE-PURGE.1 — split code purge task tree

**Scope:** Task-tree ownership, read-only inventory, live docs, and Knowledge Map setup before Perl/Rust code edits.

**Change:** Added `docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md` after the director clarified that non-current
helper spellings must be deleted from Perl and Rust code surfaces, not preserved as name-specific compatibility
or diagnostic logic. The inventory split the work into Perl source cleanup, Rust source cleanup, active
test/tool/spec fixture migration, and final no-drift verification. `docs/TASK_TREE.md`, `MEMORY.md`, live
status, and Knowledge Map facts now point to `NONCURRENT-HELPER-CODE-PURGE.2` as the next executable frontier.

**Validation:** Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and `specs` identify the
owner categories and show why context-aware cleanup is required. `git diff --check`, memory architecture,
Knowledge Map regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book`
pass.

## 2026-07-09 — DART-BACKEND-PARITY.3.2 — add Dart ActionIR contract resolver

**Scope:** Dart ActionIR contract resolution, shared current helper/control name validation, tests,
docs, mdBook, and Knowledge Map sync.

**Change:** Added `dart/lib/src/action/action_contracts.dart` and exported
`resolveActionBlockContracts(...)`, `resolveActionStatementContracts(...)`,
`resolveActionExpressionContracts(...)`, `canonicalActionHelperName(...)`, and
`isKnownActionIrCallName(...)`. The resolver walks typed ActionIR calls, receiver methods, structural
assignments, structured controls, nested arguments, block values, shapes, and access expressions, records
current canonical helper/control contracts, and reports non-current helper-looking calls as
`unknown_helper` without host-language fallback. `validateSpec(...)` now shares the same current
helper/control name table for function-name collision checks. Dart source carries no non-current helper
spelling tables or replacement maps. Added `test/action_contracts_test.dart` and cleaned Dart fixtures
that still used non-current helper spellings as variable names or source examples.

**Validation:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
`dart test`, `dart run bin/linkedspec_dart.dart --help`,
`dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
`dart run bin/corpus_runner.dart --help` pass. A Dart-tree non-current-spelling scan is clean. `git diff --check`,
memory architecture, Knowledge Map regeneration/check, task-tree metadata, doctrine gates, and
`mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — DART-BACKEND-PARITY.3.1 — add Dart ActionIR AST parser

**Scope:** Dart helper/action AST data model, source parser, tests, docs, and frontier advancement.

**Change:** Added `dart/lib/src/action/action_ast.dart` with typed ActionIR nodes for action blocks,
statements, expressions, arguments, access segments, calls, literals, array/hash shape literals,
assignments, receiver chains, block values, and structured controls. Added
`dart/lib/src/action/action_parser.dart` with `parseActionBlock(...)`, `parseActionStatement(...)`,
and `parseActionExpression(...)`. The parser covers calls, positional/keyword arguments, primitive and
regex literals, variables, indexed/nested access, scalar assignment, array append, hash-index assignment,
nested-access assignment, expression-valued blocks, attached `if`/`when`/`elseif`/`else`/`otherwise`,
`while`, `switch`/`case`/`default`, receiver-dot fluent chains, trailing block arguments, standalone
value-drop statements, and structural `raw_perl` fallback for unsupported expressions. Added
`test/action_ast_parser_test.dart` for those accepted node families.

**Validation:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
and `dart test` pass. Full repo gates are run during commit closeout.

## 2026-07-09 — DART-BACKEND-PARITY.2.4 — integrate Dart function shell projection

**Scope:** Dart spec-defined function-definition projection, staged sidecar preservation, tests, docs,
and frontier advancement.

**Change:** Added `dart/lib/src/parser/user_function_definition_shell.dart` and exported
`projectUserFunctionDefinitionAsts(...)` / `parseSpecWithUserFunctionDefinitionAsts(...)`.
The projection consumes the `function_definition` / `function_definition_error` nodes returned by
`specs/user_function_definition.spec`, validates source/body spans plus `body_payload` and
`body_parse_job`, normalizes source-order parent paths and deterministic parse-job ids, strips returned
definition spans while preserving line layout, and attaches ordered `FunctionDefinition` records before
rule parsing. `StagedParseJob` now preserves the function-body sidecar metadata fields emitted by the
spec (`version`, `function_name`, `params`, `arity`, `diagnostic_owner`). Added
`test/user_function_definition_shell_test.dart` for successful projection, malformed-node diagnostics,
sidecar drift rejection, and the no-raw-scanner boundary.

**Validation:** `dart test test/spec_ast_test.dart test/spec_parser_test.dart test/spec_validator_test.dart
test/user_function_definition_shell_test.dart` and `dart analyze --fatal-infos --fatal-warnings` pass.
Full Dart and repo gates are run during commit closeout.

## 2026-07-09 — DART-BACKEND-PARITY.2.3 — add Dart frontend validation

**Scope:** Dart frontend validation, strict-syntax checks, validation fixtures, docs, and frontier advancement.

**Change:** Added `dart/lib/src/validation/spec_validator.dart` and exported `validateSpec(...)`.
The validator checks top-rule presence, duplicate rule labels, duplicate/colliding function registry records,
invalid function parameters, malformed raw body lines, mixed action/blind edge families, grouped action targets
without a shared block, undefined targets, out-of-range regex slots, and lightweight regex structural errors.
`strictSyntax: true` adds unused-rule rejection. Added `test/spec_validator_test.dart` for these failures plus
non-strict validation over all checked-in `specs/*.spec` and rule-only corpus `input.spec` files.

**Validation:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
`dart test`, `dart run bin/linkedspec_dart.dart --help`,
`dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
`dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — DART-BACKEND-PARITY.2.2 — implement Dart spec parser

**Scope:** Dart core `.spec` rule parser, parser fixtures, shipped-spec/corpus parser coverage, docs,
and frontier advancement.

**Change:** Added `dart/lib/src/parser/spec_parser.dart` and exported `parseSpec(...)`. The parser
produces the existing source AST types for rule paragraphs, headers, mode suffixes, regex literals,
lifecycle blocks, action and blind-call edges, fluent continuations, split/conditional markers, comments,
raw fallback lines, and nested block boundaries. Added `test/spec_parser_test.dart` for Rust-compatible
parser seams, all checked-in `specs/*.spec`, and rule-only corpus `input.spec` files. Top-level `fn`
definition extraction remains deferred to `.2.4`, and strict validation remains deferred to `.2.3`.

**Validation:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
`dart test`, `dart run bin/linkedspec_dart.dart --help`,
`dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
`dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — DART-BACKEND-PARITY.2.1 — define Dart frontend AST data types

**Scope:** Dart source-level AST/data types, staged parse-job sidecars, JSON round-trip tests, docs,
and frontier advancement.

**Change:** Added `dart/lib/src/ast/spec_ast.dart` with data-only Dart types for `SpecFile`,
`FunctionDefinition`, `SourceSpan`, staged parse jobs, rules, rule headers, rule modes, body-element
variants, edge targets, and fluent calls. The JSON field names match the existing Rust parsed-AST and
staged parse-job contract (`functions`, `rules`, `source_span`, `body_parse_job`, `line_start`,
`parent_ast_path`, `result_policy`, etc.). Added `test/spec_ast_test.dart` for JSON round-trip coverage
and Rust-equivalent `RuleMode` helper behavior. No parser, compiler, runtime, or helper/action lowering
logic was added.

**Validation:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
`dart test`, `dart run bin/linkedspec_dart.dart --help`,
`dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
`dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — DART-BACKEND-PARITY.1.3 — add Dart corpus manifest IO scaffold

**Scope:** Dart corpus manifest IO scaffolding, corpus-runner CLI behavior, tests, task-tree frontier
closure, mdBook/README/live-doc sync, and Knowledge Map update.

**Change:** Added `dart/lib/src/corpus/manifest_runner.dart` to load and validate the manifest-backed
corpus without parser execution. The loader validates manifest format, case count, case names, duplicate
names, missing/stale fixture directories, required `input.spec` / `input.txt` / `expected.json` files,
and expected JSON syntax. Updated `bin/corpus_runner.dart` so `--corpus <path>` reports loaded fixture
count. Added `test/corpus_manifest_test.dart` for the checked-in 99-fixture corpus plus missing, stale,
case-count, and missing-file failures. Closed the `.1` foundation container and advanced the Dart frontier
to `.2.1` for frontend AST/data types.

**Validation:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
`dart test`, `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`,
`dart run bin/corpus_runner.dart --help`, and `dart run bin/linkedspec_dart.dart --help` pass.
`git diff --check`, memory architecture, Knowledge Map regeneration/check, task-tree metadata, doctrine
gates, and `mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — DART-BACKEND-PARITY.1.2 — create Dart scaffold smoke package

**Scope:** Dart package scaffold, smoke commands, root layout docs, mdBook sync, and Knowledge Map retrieval.

**Change:** Created the repo-owned `dart/` package with `pubspec.yaml`, committed `pubspec.lock`,
strict analyzer options, package README, public scaffold library, `bin/linkedspec_dart.dart`,
`bin/corpus_runner.dart`, and a `package:test` smoke test. Added Dart tool-state ignores for
`.dart_tool/`, `.packages`, and build output. The CLI entrypoints are scaffold-only and do not implement
parser, runtime, or corpus semantics yet; `.1.3` owns manifest IO scaffolding.

**Validation:** `dart pub get` passed with approved pub.dev network access; `dart format --set-exit-if-changed .`
is clean after formatting the new test once; `dart analyze --fatal-infos --fatal-warnings` passed with
approved analyzer state initialization under `~/.dartServer`; `dart test`,
`dart run bin/linkedspec_dart.dart --help`, and `dart run bin/corpus_runner.dart --help` pass.
`git diff --check`, memory architecture, Knowledge Map regeneration/check, task-tree metadata, doctrine
gates, and `mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — DART-BACKEND-PARITY.1.1 — record Dart toolchain and layout

**Scope:** Dart backend preflight, package layout, mdBook status sync, and task-tree frontier advancement.

**Change:** Verified local Dart SDK availability (`/opt/homebrew/bin/dart`, SDK 3.9.2 on macOS
arm64), recorded Flutter absence as non-blocking for the CLI/library backend path, and documented
the planned `dart/` package layout plus format/analyze/test/corpus-runner commands. Advanced the
Dart task frontier to `.1.2` for the minimal package scaffold and smoke test. Updated the mdBook status
and backend-handoff pages with the verified preflight state. No Dart package files were created.

**Validation:** Dart command probes passed after one approved `dart --disable-analytics` initialization
outside the workspace sandbox. `git diff --check`, `bash scripts/check_memory_architecture.sh`,
`bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_task_tree_metadata.sh`,
`bash scripts/check_doctrines.sh`, and `mdbook build docs/linkedspec-book` pass.

## 2026-07-09 — FUTURE-PARITY-BACKLOG.1.1 — scope Dart backend parity plan

**Scope:** Dart backend parity task-tree scoping, roadmap/book/live-doc alignment, Knowledge Map
retrieval.

**Change:** Created `docs/tasks/DART-BACKEND-PARITY.md` as the dedicated Dart backend plan.
The plan selects an interpreter-first path over typed `.spec` and helper/action AST plus compiled
state, with generated Dart source deferred to a later proof lane after corpus parity. Updated the
future backlog, central task-tree index, roadmaps, mdBook status/handoff pages, architecture/live
docs, and added a Knowledge Map fact for the Dart strategy.

**Validation:** `git diff --check`, `scripts/check_memory_architecture.sh`,
`knowledge-map/scripts/check_knowledge_map.sh`, `scripts/check_doctrines.sh`,
`scripts/check_task_tree_metadata.sh`, `mdbook build docs/linkedspec-book`, and
`tools/run_ci_local.sh` pass. Local CI includes phase0 `1..1028`.

## 2026-07-09 — FUTURE-PARITY-BACKLOG.0 — create future parity backlog

**Scope:** task-tree ownership, backend rollout decision, roadmap/book/KM/live-doc alignment.

**Change:** Created `docs/tasks/FUTURE-PARITY-BACKLOG.md` with seven deferred backlog lanes.
ADR `0021` accepts Lua as a future backend target and schedules future full-parity backend work
as Dart first, Julia second, and Lua third. Updated the task-tree index, roadmaps, mdBook backend
handoff/status pages, Knowledge Map backend facts, and live docs so Lua is no longer treated as
blocked.

**Validation:** `git diff --check`, `scripts/check_memory_architecture.sh`,
`knowledge-map/scripts/check_knowledge_map.sh`, `scripts/check_doctrines.sh`,
`scripts/check_task_tree_metadata.sh`, `mdbook build docs/linkedspec-book`, and
`tools/run_ci_local.sh` pass. Local CI includes phase0 `1..1028`.

## 2026-07-08 — SPEC-LANG-REFERENCE.8 — correct top-rule doctrine drift and close language reference

**Scope:** current-facing top-rule doctrine records, mdBook wording, Knowledge Map facts, and
language-reference closeout coordination.

**Change:** Reaffirmed ADR `0010` as current doctrine: `::` marks the rule entered first, and after
entry selection `::` and `:` rules share the same regex/mode/action feature surface. Rewrote the old
`spec-top-rule-no-regex-two-rule-minimum` card as a superseded historical redirect, tightened the
canonical top-rule and rule-mode cards, and corrected stale no-regex-as-law wording in the mdBook,
`TOOLBOX.md`, ADR `0010`, and task-tree records.

**Validation:** Focused `LinkedSpec::Get` probes compare regex-bearing `Entry::` and selected
regex-bearing `Body:` rules in default and `AND` modes; both pairs return the same outputs.
`mdbook build docs/linkedspec-book`, the Knowledge Map gate, memory check, task-tree metadata
check, doctrine driver, and `git diff --check` pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.7 — add spec-language Knowledge Map cards

**Scope:** Knowledge Map fact cards for durable `.spec` language reference subjects.

**Change:** Added canonical KM cards for the output/return-shape contract, regex backend feature
contract, rule-mode semantics map, lifecycle/`retv` order, and capture/mark family taxonomy.
Extended `spec-edge-syntax-contract` with action-vs-blind dispatch search keys and a dispatch
model summary. Regenerated `KNOWLEDGE_MAP.md`.

**Validation:** Required question spot-checks route to the expected fact cards, and
`knowledge-map/scripts/check_knowledge_map.sh` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.6 — add capture/mark marker cross-example

**Scope:** mdBook source-boundary and action/lifecycle placement examples.

**Change:** Added a verified marker-form capture/mark cross-example using `@capture_slice`,
`@mark(body_start)`, `mark_match_start(close_start)`, `capture_slice()`, `capture_from(...)`,
and `capture_between(...)`. Corrected placement-sensitive named-mark examples to use
`mark_here(...)` inside opener actions when exact action-local timing is needed. Added KM fact
`split-boundary-marker-action-timing`.

**Validation:** Focused `LinkedSpec::Get` probes verify the marker example output and the corrected
consume-mode named-mark examples. `mdbook build docs/linkedspec-book` and the memory, task-tree,
doctrine, whitespace, and Knowledge Map checks pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.5.5 — add remaining helper-family worked examples

**Scope:** mdBook helper catalog Declaration, Capture/Mark, Entry/Match, Input, and Call examples.

**Change:** Added verified examples for declaration replacements, anonymous and named capture/mark
helpers, entry-vs-local-match helpers, whole-input readers, and `call(child)`. Corrected stale
entry-vs-match examples in the source-boundary chapters to the verified ordered-child shape and
added KM fact `entry-match-divergence-verified-shape`. This closes helper-catalog sweep `.5`.

**Validation:** Focused `LinkedSpec::Get` probes generated every documented runtime output,
including the corrected entry-vs-local-match shape. `mdbook build docs/linkedspec-book` and the
memory, task-tree, doctrine, whitespace, and Knowledge Map checks pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.5.4 — add Hash and Control Flow worked examples

**Scope:** mdBook helper catalog Hash and Control Flow examples.

**Change:** Added verified Hash helper examples to `helper-contract-catalog.md`,
covering constructor/copy/splice forms, pure and mutating hash updates, sorted views,
receiver chains, block receivers, and hash-tree traversal. Added verified Control Flow
examples for inline/marker/attached branches, `switch`, `while`, `next`, `return`, and
`return_undef`; `exit_now(2)` is documented from descriptor metadata rather than run.
Added KM fact `hash-helper-odd-arity-current-behavior` for the direct odd-arity
`hash(...)` current-Perl caveat and deferred optional normalization to `.5.4.1`.

**Validation:** Focused `LinkedSpec::Get` probes generated every documented runtime output,
`call_spec_handler_subst` root-caused `hash("a", 1, "missing")` to an unsupported-helper
sentinel returning `undef`, and a descriptor probe verified `exit_now(2)` reports canonical
`EXIT` metadata. `mdbook build docs/linkedspec-book` and the memory, task-tree, doctrine,
whitespace, and Knowledge Map checks pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.5.3 — add Array helper worked examples

**Scope:** mdBook helper catalog Array-family examples.

**Change:** Added verified Array helper examples to `helper-contract-catalog.md`,
covering constructor/copy/splice helpers, count/selectors, edge slices, ordering,
membership, join/split, mutation and pipeline helpers, receiver chains, and array-tree
traversal. Added KM fact `array-helper-return-shape-caveats` for current Perl caveats
around compact `I.return(split(...))`, direct returns of array pipeline helpers, and
over-broad pipeline-to-pure receiver continuations.

**Validation:** Focused `LinkedSpec::Get` probes generated every documented output, plus
negative/caveat probes for compact split and direct pipeline returns. `mdbook build
docs/linkedspec-book` and the memory, task-tree, doctrine, whitespace, and Knowledge Map
checks pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.20 — document lifecycle drift policy

**Scope:** lifecycle return-channel documentation and durable policy record.

**Change:** Added ADR `0020` to record the lifecycle final-value/direct-`E` Perl
handler-shape drift as a documented current-reference caveat until a separately-owned
implementation/parity leaf authorizes engine changes. Tightened `runtime-semantics.md`
so portable rule values come from explicit `return(...)`, not lifecycle final-statement
leakage, and updated the lifecycle KM fact card to point at the ADR.

**Validation:** Focused Perl probes reproduce the caveat: the direct default-rule
`I`+regex+`E` shape returns `"not_a_return"` and generated source omits the `E`
hash-return path; a dispatched child without explicit `return(...)` returns
`["not_a_return"]`. `mdbook build docs/linkedspec-book` and the memory, task-tree,
doctrine, whitespace, and Knowledge Map checks pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.19 — finalize book scorch

**Scope:** mdBook whole-book scorch closeout.

**Change:** Ran the final regex-on-`::` sweep and fixed the remaining mdBook examples
that still violated the scorch doctrine: the recursive `sexpr` example in
`spec-files-and-rule-paragraphs.md`, two terse helper examples in `helper-contract-catalog.md`,
and the function-registry proof snippet in `compiler/pipeline-overview.md`. Corrected the
direct value-path output to the verified `"updated"` result.

**Validation:** Whole-book `rg` scans for same-line and next-line regex slots under `::`
headers return no matches. Focused `LinkedSpec::Get` probes verify the corrected `sexpr`,
direct value-path, array mutation, and function-registry outputs. `mdbook build
docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.18 — verify portmap walkthrough outputs

**Scope:** mdBook portmap walkthrough output verification.

**Change:** Rechecked the five documented `portmap.spec` output-shape examples against
the Perl reference backend. The current walkthrough already matches the live nested JSON
for bare, bit, slice, constant, and concatenation cases, so no mdBook source rewrite was
needed for this slice.

**Validation:** `LinkedSpec::get_parser('portmap')` probes verify `clk`, `bar[3]`,
`addr[7:0]`, `0x1f`, and `{sig_a sig_b[7:0] 0x1f}`. `mdbook build docs/linkedspec-book`
passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.17 — fix tablegrep walkthrough outputs

**Scope:** mdBook tablegrep walkthrough output correction.

**Change:** Replaced the tablegrep simple-term and grouped-expression output blocks with
verified JSON from `specs/tablegrep.spec`. The `sens` field is now documented as `"="`
for `=~` terms because the rule captures only `([!=])`; the grouped output now shows
the actual `GROUP` node with nested term/operator nodes. Also corrected the stale
descriptor helper list to match the live spec.

**Validation:** `LinkedSpec::get_parser('tablegrep')` probes verify both outputs.
Descriptor metadata reports five ready rules with zero blocked, compatibility, raw, or
unresolved counts. `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.16 — fix runtime semantics examples

**Scope:** mdBook runtime semantics appendix correction.

**Change:** Reworked `appendix/runtime-semantics.md` §5.5/§5.6 examples so the
top-level output examples and tagged-shape snippets use no-regex `Top::` wrappers
with normal regex-owning matcher rules. This folds the old `.10.4` Pair target:
the Pair example now reads captures with `entry_group(...)` inside the dispatched
`Pair:` rule and returns that value through `Top`.

**Validation:** Five focused `LinkedSpec::Get` probes verify scalar, proof-array,
pair, object, and manifest outputs. The page scan finds no regex slot under a `::`
header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.15 — fix formal grammar examples

**Scope:** mdBook formal grammar appendix correction.

**Change:** Reworked `appendix/formal-grammar.md` so the paragraph-model example and
the complete example use no-regex top rules with normal regex-owning matcher rules.
The complete example now defines the ordered-sequence dispatch targets (`First:` and
`Second:`) instead of referencing undefined `A`/`B` rules.

**Validation:** Focused `LinkedSpec::Get` probes verify the paragraph example plus
`DemoParser`, `SecondChild`, and `ThirdChild` top-rule outputs. The appendix scan finds
no regex slot under a `::` header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.14 — fix remaining DSL examples

**Scope:** mdBook DSL chapter scorch closeout for the remaining DSL pages.

**Change:** Reworked the Token practical pattern, the helper-surface Value example, and
the fluent/block Items worked example so regex-bearing work lives on normal matcher rules
instead of `::` / `::AND+` headers. Reduced the `Toplevel:AND+` structured-style sketch
to the lifecycle block fragment it was demonstrating. Audited `actionir-lowering-mental-model.md`
and left it unchanged because the in-scope blocks are helper-statement or lowering-pipeline fragments.

**Validation:** Focused `LinkedSpec::Get` probes verify Token, Value, and Items outputs
for singleton/pair/list cases. The four-page scan finds no regex slot under a `::` header;
`mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.13 — fix value-container flow examples

**Scope:** mdBook value/container/flow helper reference correction.

**Change:** Reworked `dsl/value-container-flow-helper-reference.md` so Token, FieldList,
Node, Sequence, and Kind worked examples no longer put regex slots under `::` / `::AND`
headers. Regex ownership now lives on normal `Token:`, `FieldList:`, `Child:`, `Item:`,
and `Kind:` matcher rules, while no-regex wrappers or entry rules keep the examples
focused on helper behavior.

**Validation:** Five focused `LinkedSpec::Get` probes verify the replacement snippets:
Token, FieldList, Kind, Node normalization, and Sequence head/tail. The page scan finds
no regex slot under a `::` header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.12 — fix source-boundary examples

**Scope:** mdBook source-boundary helper reference correction.

**Change:** Reworked `dsl/source-boundary-helper-reference.md` so the Tuple, Block, Paren,
Pair, Body, AtEnd, and entry-vs-match examples use no-regex `Top::AND` blind-call wrappers
plus regex-owning normal rules. Added a seek-mode note for delimiter-body examples and
reduced the Tuple/Body capture sequences to verified two-segment forms that still demonstrate
`capture_take()`, `capture_slice()`, and the anonymous/named boundary bridge.

**Validation:** Seven focused `LinkedSpec::Get` probes verify the replacement snippets:
Tuple, Block, Paren, Pair, Body, AtEnd, and entry-vs-match. The page scan finds no regex
slot under a `::` header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.11 — fix declaration helper examples

**Scope:** mdBook declaration-helper chapter correction.

**Change:** Reworked `dsl/declaration-helper-reference.md` so the accumulator and metadata
worked examples use no-regex `::` wrappers and regex-owning normal matcher rules. `List::`
now owns the array accumulator and calls `Item:`, while the token metadata example uses
`Top::` as the wrapper and `Token:` as the matcher.

**Validation:** Focused `LinkedSpec::Get` probes verify `alpha beta` returns
`{"kind":"list","items":[{"text":"alpha"},{"text":"beta"}],"item_count":2}` and `Alpha`
returns `[{"kind":"token","source":"Token","text":"alpha","text_length":5}]`. The page
scan finds no regex slot under a `::` header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.10 — fix capture and entry-match examples

**Scope:** mdBook capture/source-location chapter correction plus a narrow Knowledge Map fact.

**Change:** Reworked `dsl/capture-marks-and-source-locations.md` so the `capture_slice()`
worked example uses a no-regex `Top::` wrapper plus normal `Body:` delimiter rule. Replaced
the `Call::AND`/`Inner::AND` divergence sketch with a no-regex blind-call wrapper and normal
regex-owning `Call:`/`Inner:` rules. Added Knowledge fact `perl-capture-slice-delimiter-seek-boundary`
for the seek-vs-consume delimiter-capture caveat found during verification.

**Validation:** Focused `LinkedSpec::Get` probes verify `BEGIN body END` -> `[{"body":"body"}]`
under seek mode and `greet(world)` -> `[{"outer":"greet","outer_name":"greet","inner":"world","inner_name":"world"}]`.
The page scan finds no regex slot under a `::` header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.9 — fix action and lifecycle placement examples

**Scope:** mdBook action/lifecycle placement chapter correction plus a Knowledge Map caveat.

**Change:** Reworked `dsl/action-and-lifecycle-placement.md` so regex-bearing examples use normal
single-colon rules, entry-match transforms are taught through `I { ... }` + `entry_*`, and local-slot
action edges use `match_*`. Removed invalid bare child-rule lines from the Pair sketch, corrected
hash-storage initialization, and replaced the misleading direct `E { ... }` lifecycle example with
an explicit lifecycle `return(...)` warning.

**Validation:** Focused `LinkedSpec::Get` probes verify the corrected entry-match, later-slot action,
explicit lifecycle return, and Pair slot-flow examples. A page scan finds no regex slot under a `::`
header; `mdbook build docs/linkedspec-book`, `git diff --check`, and the Knowledge Map check pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.8 — fix blind-call orchestration examples

**Scope:** mdBook blind-call chapter correction for the active whole-book scorch.

**Change:** Reworked `user-model/blind-calls-and-parser-orchestration.md` so no-regex blind-call
`::` wrappers stay intact while regex-owning action-edge examples use single-colon labels. Clarified
that the mixed-edge negative example uses `BadRule:AND` because it owns a regex slot; the error is
mixing `->` and `=>`.

**Validation:** Focused scan finds no `::` header followed by a regex slot; a wrapped negative probe
logs the expected `Cannot mix ACTION (->) and BLIND CALL (=>) code blocks` validation error; `mdbook
build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.7 — fix regex chapter examples

**Scope:** mdBook regex chapter correction for the active whole-book scorch.

**Change:** Reworked `user-model/regex-in-spec.md` so the keyword, numbered-capture, named-capture,
and compaction examples use no-regex `Top::` wrappers plus single-colon regex-bearing rules. The
capture-indexing contract stays intact: groups are 0-based, captures-only, compacted when
non-participating, and named captures remain stable.

**Validation:** Representative `LinkedSpec::Get` probes confirm the documented keyword, pair, named
capture, numbered-compaction, and named-compaction outputs; the page scan finds no regex slot under a
`::` header; `mdbook build docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.6 — fix rule mode and parse mode examples

**Scope:** mdBook language-reference correction for rule-mode and parse-mode examples.

**Change:** Reworked `user-model/rule-modes-and-parse-modes.md` so regex-owning mode examples use
single-colon labels, `::` examples are framed as no-regex entry/dispatcher rules, and the old
`Top:: /foo/` seek/consume snippets use a verified `Top::` + `Word:` wrapper.

**Validation:** Representative `LinkedSpec::Get` probes match the documented outputs (`["foo","bar"]`,
`["foo"]`, `[]`, `["foo"]`); remaining `::` labels are no-regex entry/dispatcher examples; `mdbook build
docs/linkedspec-book` passes.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.5 — fix spec file paragraph examples

**Scope:** mdBook language-reference correction plus a narrow Knowledge Map fact.

**Change:** Reworked `user-model/spec-files-and-rule-paragraphs.md` so its minimal, block-boundary,
same-line, and multiline examples use the verified 2-rule idiom: `Top::` dispatches/returns its
accumulator, while normal matcher rules carry regexes and read `entry_text()`. Replaced the malformed
bare `label:` block example with valid quoted `"label:"` helper content and documented the actual
validation error. Added Knowledge fact `rule-starts-open-block-validation`.

**Validation:** Four replacement snippets compile/run through `LinkedSpec::Get`; the bad bare-`label:`
probe reports `Rule definition not allowed inside open block`; `mdbook build docs/linkedspec-book` and
the memory/Knowledge/doctrine/task-tree/whitespace gates pass.

## 2026-07-08 — SPEC-LANG-REFERENCE.10.5.4.1 — reactivate book scorch

**Scope:** Metadata-only activation of the paused language-reference book scorch.

**Change:** Resolved the 2026-06-18 `SPEC-LANG-REFERENCE` pause by user directive and set
`.10.5.5` as the next active frontier. Updated the task tree, central task-tree index, memory pointer, live status,
and development notes.

**Validation:** No parser/runtime/source/book behavior changed; this slice only changes durable coordination
records. Focused checks cover memory architecture, task-tree metadata, doctrine registry, and whitespace.

## 2026-07-08 — TASK-TREE-METADATA-HYGIENE.4 — reconcile closeout commit metadata

**Scope:** Metadata-only task-tree hygiene after startup review.

**Change:** Reconciled `docs/tasks/SPEC-SOURCE-TERSE-CLOSEOUT.md` so the completed `.1` leaf records its landed
commit instead of saying commit execution is pending. Updated the hygiene task tree, central index, memory pointer,
and live status notes for this metadata-only slice.

**Validation:** Focused scans showed the stale pending-commit wording was isolated to the just-closed closeout task
file. No parser/runtime/source/book behavior changed.

## 2026-07-08 — SPEC-SOURCE-TERSE-CLOSEOUT.1 — close root spec terse source

**Scope:** Exhaustive root `specs/*.spec` source-format closeout plus generated oracle/doc synchronization.

**Change:** Migrated remaining root-spec host-action residues in `hlink_substitution`, `pplugin`, `Lispish`,
`ebnf`, `simenv`, and `vhdl` to current helper/value forms. `hlink_substitution` bracket payloads now return
neutral strings, so `[abc]` and `foo[bar]{baz}` are active Rust oracle fixtures. `pplugin.spec` now returns
plugin body text; `perl/PPlugin.pm` wraps that text into legacy coderefs for `.plg` runtime callers.

**Validation:** Retired-helper and host-residue scans over root specs are clean; all 21 shipped descriptors report
`1.0000 0 0`; focused hlink and pplugin probes pass; oracle generation emits 99 fixtures; Rust
`oracle_corpus_matches_perl_reference` passes over the 99-fixture manifest.

## 2026-07-08 — RUST-STATUS-DRIFT-SYNC.1 — sync Rust status counts

**Scope:** Documentation-only synchronization for current-facing Rust variant status counts.

**Change:** Added a narrow task-tree owner for startup-discovered drift, then updated `ROADMAP.md`,
`rust/README.md`, and the mdBook shipped-corpora page so current status matches the checked-in manifest:
97 Rust oracle fixtures, 21 shipped `.spec` files, and phase0 `1..1028`. Historical task/log entries that were
accurate for earlier slices remain unchanged.

**Validation:** Focused stale-count scans over current-facing docs pass; the manifest records `case_count` 97 and
the `terse_13_3_array_tree_traversal_receiver_blocks` fixture; `specs/` contains 21 shipped `.spec` files.
`mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine driver, task-tree metadata, and
whitespace checks pass.

## 2026-07-08 — DOCTRINE-ENFORCEMENT-ADOPT.3.3 — close task-acceptance no-drift

**Scope:** Documentation, Knowledge Map, task-tree, and live-resume closeout for the shipped
`TASK-ACCEPTANCE` evidence gate.

**Change:** Closed `DOCTRINE-ENFORCEMENT-ADOPT` after reconciling the doctrine standard, `TOOLBOX.md`, mdBook
local-CI/task-tree ownership wording, ADR `0009`, the Knowledge fact card, central task-tree index, and live docs.
The false-positive escape path is now explicit: inspect `git diff --cached --name-only`, unstage unrelated governed
files, stage/update the owning task checklist, or split the work. The known limit is also explicit: the gate proves
staged evidence shape and ownership, not truthfulness or historical completeness.

**Validation:** No executable behavior changed. No-drift scans, Knowledge Map regeneration, doctrine driver,
memory architecture, task-tree metadata, mdBook build, and whitespace checks pass.

## 2026-07-08 — DOCTRINE-ENFORCEMENT-ADOPT.3.2 — implement task-acceptance evidence gate

**Scope:** Doctrine tooling, local gate registration, and documentation sync for staged task-acceptance evidence.

**Change:** Added executable `scripts/check_diagnosis_evidence.sh` and registered it as `TASK-ACCEPTANCE` in
`scripts/check_doctrines.sh`. The check inspects the staged set, passes when no governed code/spec/test/tooling
paths are staged, and otherwise requires a staged `docs/tasks/*.md` file with the `TOOLBOX.md` acceptance
checklist completed using LinkedSpec-tool, WHY/WHERE, and verification signatures. Synced the doctrine standard,
toolbox, local gate tracked-file audit, mdBook local-CI chapter, ADR `0009`, and Knowledge Map source facts.

**Validation:** `bash scripts/check_diagnosis_evidence.sh`, staged self-check, `bash scripts/check_doctrines.sh`,
`bash scripts/check_memory_architecture.sh`, `bash scripts/check_task_tree_metadata.sh`,
`mdbook build docs/linkedspec-book`, and `git diff --check` pass.

## 2026-07-08 — DOCTRINE-ENFORCEMENT-ADOPT.3.1 — split evidence gate before code

**Scope:** Task-tree and continuity split/design for the pending evidence/task-acceptance doctrine.

**Change:** Reactivated `DOCTRINE-ENFORCEMENT-ADOPT.3` by splitting it before code. The next executable leaf is
`.3.2`, which will implement/register a scope-aware staged `TASK-ACCEPTANCE` checker. The follow-up `.3.3` will
close docs, Knowledge Map, and no-drift state after the checker exists. The design keeps the checker narrow:
govern staged code/spec/test/tooling changes, require a staged owning task-file checklist with LinkedSpec-tool
evidence signatures, and leave arbitrary command re-execution to the local CI gate rather than the hook.

**Validation:** Bootstrap/read review, Knowledge Map search for existing evidence-gate facts, task-tree split
review, relevant enforcement owner paths read, memory architecture, doctrine, task-tree metadata, and whitespace
checks.

## 2026-07-08 — SPEC-FORMAT-TERSE.13.5 — close parent terse task tree

**Scope:** Metadata-only task-tree closeout for the parent terse-format tree.

**Change:** Reconciled `SPEC-FORMAT-TERSE` from `active` with an empty frontier to `done` / `closed` in the
central task-tree index and task-file metadata. Stale split-container rows inside the task file now use
historical done/closed wording, while deferred future-backend decisions remain non-current roadmap decisions.

**Validation:** Parent-status scans, mdBook build, Knowledge Map regeneration/check, memory architecture,
doctrine, task-tree metadata, and whitespace gates pass. No parser/runtime, corpus, or behavioral mdBook
semantics changed.

## 2026-07-08 — SPEC-FORMAT-TERSE.13.4 — close array-tree traversal drift

**Scope:** Documentation, Knowledge Map, oracle-count, task-tree, and live-doc closeout for shipped array-tree
traversal receiver blocks.

**Change:** Marked `SPEC-FORMAT-TERSE.13` exhausted after Perl reference support, Rust parser/runtime parity, and
the 97th generated oracle fixture landed. Current docs now describe array-tree traversal as a shipped Perl/Rust
surface using `walk_leaves() { ... }`, `map_leaves() { ... }`, and `reduce_leaves(initial) { ... }` on array-valued
receivers.

**Validation:** Drift scans covered stale `.13.4` frontier wording, pending Rust parity text, callback-binding
terms, `undef` vs JSON-null wording, and the 97-fixture corpus count. mdBook, Knowledge Map, memory architecture,
doctrine, task-tree metadata, and whitespace gates pass.

## 2026-07-08 — SPEC-FORMAT-TERSE.13.3 — implement Rust array-tree traversal

**Scope:** Rust parser/runtime parity plus a generated Perl-backed oracle fixture for array-tree traversal receiver
blocks.

**Change:** Generalized Rust receiver trailing-block traversal from hash-only to hash-or-array runtime dispatch.
Hash receivers keep the shipped `.12` sorted-key behavior. Array receivers traverse nested arrays depth-first by
zero-based index, treat hash values as leaves, bind scoped `value`, `index`, `path`, `depth`, and reduce-only
`acc`, return `undef` without callbacks for scalar receivers, and allow `walk_leaves` / `map_leaves` to feed
array-family continuations such as `.count()`.

**Validation:** Focused Rust parser tests for tree traversal receiver blocks pass; focused Rust `.13.3` runtime
tests pass; focused `.12.3` hash-tree runtime tests still pass; `perl -Iperl tools/gen_oracle_corpus.pl`
regenerated **97** fixtures including `terse_13_3_array_tree_traversal_receiver_blocks`; Rust
`oracle_corpus_matches_perl_reference` passes over the 97-fixture manifest.

## 2026-07-08 — SPEC-FORMAT-TERSE.13.2 — implement Perl array-tree traversal

**Scope:** Perl reference implementation for array-valued receiver block traversal methods.

**Change:** Extended the shared receiver traversal lowering so `walk_leaves() { ... }`,
`map_leaves() { ... }`, and `reduce_leaves(initial) { ... }` dispatch over hash or array receiver values at
runtime. Hash receivers preserve the shipped `.12` sorted-key traversal behavior. Array receivers traverse nested
arrays depth-first by zero-based index, treat hash values as leaves, bind scoped `value`, `index`, `path`, `depth`,
and reduce-only `acc`, and return `undef` without callbacks for scalar receivers.

**Validation:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`; focused lowering/runtime/source-residue
probes; `prove -q -Iperl t/actionir_ast_parser.t`; full `PERL5LIB= prove -q -Iperl t/phase0_regression.t`
(`Files=1, Tests=1028`, `Result: PASS`); mdBook/Knowledge/live-doc updates.

## 2026-07-08 — SPEC-FORMAT-TERSE.13.1 — split array-tree traversal

**Scope:** Spec-first task split for the remaining `SPEC-FORMAT-TERSE` array-tree traversal backlog item.

**Change:** Accepted array-tree traversal into the active terse-format roadmap and split it before parser/runtime
code. The planned surface reuses receiver block methods on array-valued receivers:
`walk_leaves() { ... }`, `map_leaves() { ... }`, and `reduce_leaves(initial) { ... }`. Array roots and nested
arrays are traversal nodes; scalar and hash values are leaves; traversal is depth-first in zero-based index order;
callbacks bind scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`.

**Validation:** Knowledge Map retrieval for the `.12` hash-tree contract; task-tree split review; Knowledge fact
creation and map regeneration; memory, doctrine, task-tree metadata, and whitespace checks. No parser/runtime
behavior changed.

## 2026-07-08 — SPEC-FORMAT-TERSE.10.1 — ratify dynamic hash-literal keys

**Scope:** Spec-ratification/no-engine-change closeout for direct hash-literal key semantics.

**Change:** Reactivated and closed `.10` by recording the current contract explicitly: direct hash literals use
`{ key_expr : value_expr }`, the key expression is evaluated and stringified at runtime, bare keys are scalar
reads, quoted keys are fixed fields, and computed helper expressions such as `cat(prefix,suffix)` are valid keys.
The mdBook wording and Knowledge Map fact now make that boundary durable.

**Validation:** `LinkedSpec::call_spec_handler_subst` probes for bare, computed, and quoted keys; direct
`LinkedSpec::Get` runtime probe; Rust parser/runtime code read for hash-literal key parsing/evaluation; mdBook,
Knowledge Map, memory, doctrine, task-tree metadata, and whitespace checks.

## 2026-07-08 — MEMORY-PUSH-POINTER-SYNC.1 — remove stale push threshold claim

**Scope:** Continuity-only correction for the layer-A resume pointer.

**Change:** Replaced the stale `MEMORY.md` statement that the branch was over the 300-commit push threshold with
policy-oriented guidance to check `git status -sb` for the live ahead count and avoid pushing mid-PNT unless
explicitly instructed or the threshold policy is deliberately invoked. Added and closed a narrow task-tree owner for
the correction.

**Validation:** Focused stale-threshold scan; `git status -sb`; `bash scripts/check_memory_architecture.sh`;
`bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check`.

## 2026-07-08 — ROADMAP-POST-12-DRIFT-SYNC.1 — sync long roadmap baseline

**Scope:** Documentation-only correction for startup-discovered current-state drift in the long-form roadmap.

**Change:** Added a narrow task-tree owner and refreshed `ROADMAP.md` current-state baseline references from
phase0 `1..1026` / 95 Rust oracle fixtures to phase0 `1..1027` / 96 fixtures after the `SPEC-FORMAT-TERSE.12.4`
hash-tree traversal closeout. The reviewed mdBook already carried the current status, helper contract, formal
grammar, backend handoff, and development workflow wording, so no book source edit was needed.

**Validation:** Focused stale-count scans over `ROADMAP.md`; `mdbook build docs/linkedspec-book`;
`bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`;
`bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check`.

## 2026-07-08 — SPEC-FORMAT-TERSE.12.4 — close hash-tree traversal drift

**Scope:** Final no-drift closeout for the shipped `.12` hash-tree traversal receiver surface.

**Change:** Closed the `.12` lane after verifying mdBook helper/reference/formal/backend-handoff coverage,
Knowledge Map retrieval, live docs, task-tree frontier state, and the 96-fixture oracle manifest all agree on
`walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` semantics. The closeout records that `.12.1` through
`.12.4` are done and that `SPEC-FORMAT-TERSE.10` / `.13` remained deferred at that closeout point. `.10` was
later closed by `.10.1`.

**Validation:** No parser/runtime behavior changed. No-drift scans covered hash-tree method names, callback
bindings, traversal semantics, trailing-block boundary wording, and the current 96-fixture oracle state.
`mdbook build docs/linkedspec-book`; `bash scripts/check_memory_architecture.sh`;
`bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`.

## 2026-07-08 — SPEC-FORMAT-TERSE.12.3 — implement Rust hash-tree traversal

**Scope:** Rust parser/runtime parity plus generated Perl-backed oracle coverage for hash-tree attached-block
receiver traversal.

**Change:** The Rust expression parser now accepts receiver trailing blocks for `walk_leaves`,
`map_leaves`, and `reduce_leaves(initial)` and preserves that syntax in fluent-chain display. The runtime routes
hash-tree receiver calls through the trailing-block execution path, diagnoses missing/malformed blocks with
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<method>`, walks hash-root/hash-interior value trees in sorted depth-first
order, treats arrays as leaves, binds scoped `value`, `key`, `path`, `depth`, and reduction-only `acc`, restores
outer bindings, returns `undef` for non-hash receivers without callbacks, and preserves hash-family continuations
after `walk_leaves` / `map_leaves`. The generated oracle corpus now includes
`terse_12_3_hash_tree_traversal_receiver_blocks`; the manifest is at 96 fixtures and the Rust corpus oracle passes.

**Boundary:** Public mdBook helper/reference examples and Knowledge Map facts were updated in this slice to avoid
post-commit drift. `.12.4` remains the final no-drift closeout and scan/verification leaf for the shipped `.12`
surface.

**Validation:** `cargo fmt --manifest-path rust/linkedspec-core/Cargo.toml`;
`cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml`;
`cargo test --manifest-path rust/linkedspec-core/Cargo.toml hash_tree_receiver -- --nocapture`;
`cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_12_3 -- --nocapture`;
`perl -Iperl -c tools/gen_oracle_corpus.pl`; direct Perl oracle probe for the new fixture;
`perl -Iperl tools/gen_oracle_corpus.pl` (Generated 96 oracle fixtures);
`cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference -- --nocapture`
(PASS, 96 fixtures); `mdbook build docs/linkedspec-book`; `bash scripts/check_memory_architecture.sh`;
`bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`.

## 2026-07-08 — SPEC-FORMAT-TERSE.12.2 — implement Perl hash-tree traversal

**Scope:** Perl reference parser/lowering support for hash-tree attached-block receiver traversal.

**Change:** The Perl ActionIR AST parser now accepts receiver trailing blocks on
`walk_leaves`, `map_leaves`, and `reduce_leaves(initial)`. Method lowering implements sorted
depth-first traversal over hash-root/hash-interior value trees, treats arrays as leaves, binds scoped
`value`, `key`, `path`, and `depth` callback variables plus `acc` for reductions, restores the outer
callback-name bindings after each immediate block, and rejects malformed arity or missing blocks with explicit
unsupported-helper diagnostics. `walk_leaves` returns the original tree after side-effect callbacks,
`map_leaves` returns a newly mapped tree, and `reduce_leaves(initial)` returns the final accumulator.

**Boundary:** This is the Perl reference slice only. Rust parser/runtime parity, generated oracle fixtures,
Knowledge Map facts, and full public helper documentation remain owned by `.12.3` and `.12.4`.
The mdBook current-status count was refreshed from phase0 `1..1026` to `1..1027`, but detailed hash-tree helper
examples wait for cross-backend parity.

**Validation:** `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm`;
`perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`; `prove -q -Iperl t/actionir_ast_parser.t`;
`PERL5LIB= prove -q -Iperl t/phase0_regression.t` (PASS, 1027 tests); `git diff --check`.

## 2026-07-08 — SPEC-FORMAT-TERSE.12.1 — activate hash-tree traversal split

**Scope:** Task-tree and live-doc activation for hash-tree traversal receiver methods.

**Change:** Reactivated deferred `SPEC-FORMAT-TERSE.12` by explicit user directive and split it before code. The
accepted MVP is receiver-only `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` with immediate attached
blocks, sorted depth-first hash traversal, scoped `value`/`key`/`path`/`depth` bindings plus `acc` for reduction,
array leaves, no delayed closures, and explicit Perl/Rust/docs/KM/oracle children.

**Boundary:** No parser/runtime behavior changed and no public mdBook content changed in this split slice.

**Validation:** Memory architecture, doctrine, task-tree metadata, and diff checks pass.

## 2026-07-08 — STAGED-LINKED-PARSING.6 — close staged linked parsing tree

**Scope:** Task-tree metadata closeout for the completed staged linked parsing prototype.

**Change:** Marked `STAGED-LINKED-PARSING` done, moved it from Active to Completed in the central task-tree index,
and replaced the stale PNT pointer to already-closed `TOP-RULE-AS-NORMAL.3.2` with a return to the active
task-tree index.

**Boundary:** No parser/runtime behavior changed and no public mdBook content changed.

**Validation:** Memory architecture, doctrine, task-tree metadata, and diff checks pass.

## 2026-07-08 — ROADMAP-DRIFT-RECONCILE.2 — refresh architecture status counts

**Scope:** Architecture-state and public-book status/count documentation sync.

**Change:** Refreshed `ARCHITECTURE_STATE.md` to `2026-07-08` and aligned its status block with the current
21-spec phase0 baseline (`1..1026`), 95-fixture Rust interpreter oracle, generated Rust-source subset boundary,
and noncore/plugin state. Synchronized the narrow mdBook pages that still carried stale current-state counts or
plugin-corpus wording, including project status, owner tree, local CI, plugin registry, shipped corpora, backend
handoff, formal grammar, and one convention-audit note. Closed `ROADMAP-DRIFT-RECONCILE` in the task-tree index.

**Boundary:** No parser/runtime behavior changed. Historical June 2026 audit counts remain historical where they
are explicitly labeled that way.

**Validation:** Focused stale-wording scans, mdBook build, `git diff --check`, memory/KM/doctrine checks, and
`bash tools/run_ci_local.sh` pass (including phase0 `1..1026`).

## 2026-07-08 — ROADMAP-DRIFT-RECONCILE.1 — reconcile long-form roadmap drift

**Scope:** Documentation-only long-form roadmap reconciliation.

**Change:** Updated `ROADMAP.md` so it reflects the current terse `.spec` direction, phase0 count, Rust oracle
count, plugin/noncore state, and backend-variant model. The roadmap now names `SPEC-FORMAT-TERSE` / ADR `0007`,
stops presenting `declare(...)` as current authoring, records `LEGACY-VHDL-RETIRE` and `NONCORE-QUARANTINE`, and
states the current `.spec` = universal contract / Perl = reference / Rust = implemented lockstep variant model.
The owning task tree and central index now advance the frontier to `ROADMAP-DRIFT-RECONCILE.2`.

**Boundary:** No parser/runtime behavior changed. No mdBook edit was needed because the public book already carries
the current status and 95-fixture oracle wording.

**Validation:** Filesystem/status checks for shipped specs, noncore `.plg` files, root `plugin/` absence, Perl core
modules, and the Rust corpus manifest; focused stale-wording scans; `git diff --check`, memory/KM/doctrine checks,
and `bash tools/run_ci_local.sh` pass (including phase0 `1..1026`).

## 2026-07-08 — RUST-README-DRIFT-SYNC.1 — sync Rust README oracle count

**Scope:** Narrow Rust README documentation sync.

**Change:** Updated `rust/README.md` so the generated-source overview names the full Rust interpreter oracle as the
current 95-fixture corpus, matching `rust/linkedspec-runtime/tests/corpus/manifest.json` and the mdBook. Closed
`RUST-README-DRIFT-SYNC` and moved it to Completed in the task-tree index.

**Boundary:** No parser/runtime behavior changed and no mdBook content changed.

**Validation:** Focused stale-count scans, memory-architecture check, doctrine driver, and diff checks pass.

## 2026-07-08 — RUST-README-DRIFT-SYNC.0 — own Rust README count drift

**Scope:** Tracking-only owner for one startup-discovered documentation drift.

**Change:** Added `docs/tasks/RUST-README-DRIFT-SYNC.md` and registered it in the active task-tree index. The
finding: `rust/README.md` still names the full Rust interpreter oracle as 93 fixtures, while the checked-in
manifest, mdBook status/handoff/corpora pages, live docs, and Knowledge Map point at 95 fixtures after
`terse_14_4_receiver_with_trailing_block`.

**Boundary:** No parser/runtime behavior changed and `rust/README.md` is not edited in this tracking slice.

**Validation:** Memory-architecture check, doctrine driver, and diff checks pass.

## 2026-07-08 — TASK-TREE-METADATA-HYGIENE.3 — gate completed-tree frontiers

**Scope:** Low-noise doctrine enforcement for task-tree metadata hygiene.

**Change:** Added `scripts/check_task_tree_metadata.sh` and registered it as `TASK-TREE-METADATA` in
`scripts/check_doctrines.sh`. The gate checks only task files whose top metadata says `done`, `completed`, or
`exhausted`, and only the status cell in their `Current Frontier` tables. It fails if a completed tree advertises a
live frontier status (`pending`, `active`, `in_progress`, or `blocked`). Documented the new doctrine in
`DOCTRINE_ENFORCEMENT.md`, added a Knowledge fact for the gate boundary, and closed `TASK-TREE-METADATA-HYGIENE`.

**Boundary:** No parser/runtime behavior changed and no public mdBook behavior changed. Historical prose and old
per-leaf commit backfill fields remain outside this gate to avoid legacy false positives.

**Validation:** New task-tree metadata check, full doctrine driver, Knowledge Map regeneration/check,
memory-architecture check, and diff checks pass.

## 2026-07-08 — TASK-TREE-METADATA-HYGIENE.2 — reconcile stale frontier rows

**Scope:** Metadata-only reconciliation for completed/completed-like task trees that still carried stale
`Current Frontier`, verification, or commit rows.

**Change:** Reconciled stale rows in `COMPAT-ALIAS-TEST-CLEANUP.md`, `LIFECYCLE-FAMILY-AUDIT.md`,
`LINKEDSPEC-LOW-EFFORT.md`, `RGX-BRANCH-TRACKING.md`, `PHASE8-MULTI-BACKEND-HANDOFF.md`, and
`COMPAT-ALIAS-RETIREMENT-V2.md`. `COMPAT-ALIAS-RETIREMENT.md` is explicitly classified as completed with deferred
medium-term leaves; `NONCORE-QUARANTINE.md` is classified as done with `.N` as an explicit deferred non-goal and
needed no edit. Added a Knowledge fact for the post-commit hook behavior after confirming it verifies/warns about
`MEMORY.md` drift but does not auto-regenerate the file.

**Boundary:** No parser/runtime behavior changed and no public mdBook behavior changed.

**Validation:** Focused stale-marker scans, Knowledge Map regeneration/check, memory/doctrine checks, and diff
checks pass.

## 2026-07-07 — TASK-TREE-METADATA-HYGIENE.1 — reconcile top task metadata

**Scope:** Metadata-only reconciliation for completed/exhausted task trees that still advertised `active` at the
top level.

**Change:** `FLUENT-BLOCK-EQUIVALENCE.md`, `MEDIUM-IMPACT.md`, and `PHASE0-BACKHALF-TRIAGE.md` now align their
top metadata with their own bodies. `MEDIUM-IMPACT` also closes the stale `.3.4` active status, and
`PHASE0-BACKHALF-TRIAGE` closes stale active current-frontier rows for completed child slices. The owning hygiene
tree and central task-tree index now advance the frontier to `.2`.

**Boundary:** No parser/runtime behavior changed and no public mdBook behavior changed.

**Validation:** Focused stale-active scans, memory/doctrine checks, and diff checks pass.

## 2026-07-07 — SPEC-FORMAT-TERSE.14.5 — close trailing block drift

**Scope:** Final no-drift closeout for the shipped trailing block-argument surface.

**Change:** Synchronized the execution roadmap, mdBook project-status wording, and Knowledge fact for the final
`.14` state: helper-function form `with(value) { ... }` / `with() { ... }` and receiver-method form `.with() { ... }` are shipped
on Perl and Rust, the Rust oracle corpus is at 95 fixtures after `terse_14_4_receiver_with_trailing_block`, and
`.14` is closed after the docs/KM/oracle sweep.

**Boundary:** No parser/runtime behavior changed. Bare `with { ... }`, explicit receiver `.with(value) { ... }`,
closures, delayed callbacks, assignable/returnable blocks, and arbitrary non-`with` trailing blocks remain
deferred behind future task-tree ownership.

**Validation:** Focused stale-wording scans, mdBook build, Knowledge Map regeneration/check, oracle regeneration,
Rust oracle pass, memory/doctrine checks, and diff checks pass.

## 2026-07-07 — SPEC-FORMAT-TERSE.14.4 — add receiver trailing blocks

**Scope:** Receiver-form trailing block arguments for `.with() { ... }` on Perl and Rust.

**Change:** Receiver chains now accept `.with() { ... }` as an immediate block-taking segment. The receiver value is
bound as scoped `value`, the block result can be the terminal expression value or feed later compatible
receiver-family links, and the surrounding `value` binding is restored afterward. The Rust oracle corpus now has
95 fixtures after adding `terse_14_4_receiver_with_trailing_block`.

**Boundary:** Explicit receiver `.with(value) { ... }`, bare `with { ... }`, closures, assignable/returnable
blocks, delayed callbacks, and arbitrary non-`with` receiver trailing blocks remain unshipped.

**Validation:** Focused Perl parser/lowering/runtime locks, full phase0 (1026 tests), focused Rust parser/runtime
tests, oracle generation, and the 95-fixture Rust oracle pass. Public mdBook, task-tree, live docs, and Knowledge
facts are updated to the shipped receiver surface.

## 2026-07-07 — REPO-HYGIENE.3 — remove generated artifacts

**Scope:** User-requested generated-artifact cleanup for disk-space recovery.

**Change:** Removed ignored, untracked, rebuildable generated outputs: `rust/target` (5.2G before deletion) and
`docs/linkedspec-book/book` (7.0M before deletion).

**Boundary:** No source, fixtures, checked-in docs, or submodule corpus content was deleted. `.log` and `.bin` hits
under `rgx/` were preserved because they live in submodule stimulus/fixture/issue-artifact trees and are not 100%
safe parent-repo cleanup targets.

**Validation:** Ignored/tracked checks confirm the deleted directories were ignored and untracked. Post-clean scans
show no remaining safe `.log`, `.bin`, `.tmp`, `.bak`, `.DS_Store`, or `.swp` artifacts in the main checkout
outside `.git`, ignored target trees, and `rgx`. `bash scripts/check_memory_architecture.sh`,
`bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`, and `git diff --check`
pass. Cargo/mdBook were intentionally not run for this cleanup slice because they would recreate the removed
generated artifacts.

## 2026-07-07 — SPEC-FORMAT-TERSE.14.3 — add Rust helper trailing blocks

**Scope:** Rust helper-function form parity for `with(value) { ... }` / `with() { ... }` trailing block arguments.

**Change:** Rust now parses helper-function form `with(...) { ... }` by appending a final `BlockValue` argument only for the
owned `with` helper form. Runtime dispatch treats `with` as lazy, evaluates the optional value argument, binds
scoped scalar `value` for immediate block execution, restores the previous same-name runtime state afterward, and
reuses expression-valued block semantics for block-local `return(expr)`. Public docs now state the lexical
execution context: the block runs in the caller's current action/runtime context, while only scalar `value` is the
portable scoped block parameter.

**Boundary:** Receiver `.with() { ... }`, bare `with { ... }`, closures, assignable/returnable blocks, delayed
callbacks, and non-`with` helper trailing blocks remain out of scope.

**Validation:** `cargo fmt --check`, `cargo test -p linkedspec-core trailing_block`,
`cargo test -p linkedspec-runtime terse_14_3`, `perl tools/gen_oracle_corpus.pl` (94 fixtures),
`cargo test -p linkedspec-runtime oracle_corpus_matches_perl_reference`, `mdbook build docs/linkedspec-book`,
`bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`bash scripts/check_doctrines.sh`, and `git diff --check` pass.

## 2026-07-07 — SPEC-FORMAT-TERSE.14.2 — add Perl helper trailing blocks

**Scope:** Perl reference support for helper-function form trailing block arguments under `SPEC-FORMAT-TERSE.14`.

**Change:** `with(value) { ... }` and `with() { ... }` now parse as helper calls with flagged final `block_value`
arguments. MethodLowering accepts the trailing block only for `with`, binds scoped lexical `value` during immediate
block execution, reuses expression-valued block lowering for block-local `return(expr)`, and emits the standard
unsupported-helper sentinel for unknown trailing-block callees. The mdBook and Knowledge fact now describe the
Perl-reference surface while leaving Rust parity and receiver `.with() { ... }` as follow-on leaves.

**Boundary:** Rust parity, receiver `.with() { ... }`, bare `with { ... }`, closures, assignable blocks, returnable
blocks, and delayed callbacks remain out of scope.

**Validation:** `perl -c -Iperl` on touched Perl modules/tests, `prove -q -Iperl t/actionir_ast_parser.t`,
`PERL5LIB= prove -q -Iperl t/phase0_regression.t` (1025 tests), `mdbook build docs/linkedspec-book`,
`bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`bash scripts/check_doctrines.sh`, and `git diff --check` pass.

## 2026-07-07 — SPEC-FORMAT-TERSE.14.1 — activate trailing block-argument plan

**Scope:** Task-tree and roadmap ownership for the user-reactivated trailing code-block / trailing block-argument
surface under `SPEC-FORMAT-TERSE.14`.

**Change:** Reactivated `.14`, split it into implementation children, selected `with(value) { ... }` /
`with() { ... }` as the first helper-function MVP, and recorded the no-closure semantics before any parser/runtime code
changes. Added a Knowledge fact so future sessions can find the owner, accepted contract, and next leaf without
redoing the scan.

**Boundary:** Tracking/specification only. No parser/runtime/source behavior changed and no public mdBook behavior
page changed, because the syntax is not shipped yet.

**Validation:** `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`bash scripts/check_doctrines.sh`, and `git diff --check` pass.

## 2026-07-07 — TASK-TREE-METADATA-HYGIENE.0 — own task-tree metadata audit

**Scope:** Tracking-only ownership for the user-requested audit of non-closed task trees and stale per-file task
metadata.

**Change:** Added `docs/tasks/TASK-TREE-METADATA-HYGIENE.md` and registered it in `docs/TASK_TREE.md`. The tree
records the authoritative live non-closed task-tree inventory and owns follow-up cleanup for stale top-level
metadata and stale frontier/verification rows in older task files.

**Boundary:** No parser/runtime/source behavior, public mdBook content, or old task-file cleanup changed in this
slice.

**Validation:** `bash scripts/check_memory_architecture.sh`, `bash scripts/check_doctrines.sh`, and
`git diff --check` pass.

## 2026-07-07 — PPLUGIN-WALKTHROUGH-DRIFT.1 — align pplugin walkthrough status

**Scope:** Narrow mdBook and Knowledge Map drift for the shipped `pplugin.spec` walkthrough.

**Change:** Updated `specs-and-corpora/pplugin-spec-walkthrough.md` so it reports the current `pplugin` descriptor
status (`language_agnostic_ready_ratio = 1.0000`, zero blocked rules, zero compatibility-surface rules) and
separates that parser readiness from legacy Perl `.plg` runtime behavior. Added
`docs/knowledge/pplugin-descriptor-ready-legacy-runtime-boundary.md` and regenerated `KNOWLEDGE_MAP.md`.

**Boundary:** No parser/runtime code, shipped spec source, `.plg` plugin execution behavior, or Rust oracle corpus
changed.

**Validation:** Descriptor probe reports `ratio=1.0000 blocked=0 compat=0`; focused stale-wording scan passes;
`mdbook build docs/linkedspec-book`, `bash scripts/check_memory_architecture.sh`,
`bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`, and `git diff --check`
pass.

## 2026-07-07 — PPLUGIN-WALKTHROUGH-DRIFT.0 — create pplugin walkthrough drift tree

**Scope:** Tracking-only ownership for pplugin mdBook drift found during the bootstrap/book/code alignment pass.

**Change:** Added `docs/tasks/PPLUGIN-WALKTHROUGH-DRIFT.md` and registered it in `docs/TASK_TREE.md` as the active
owner for the pplugin walkthrough correction. Updated live recovery docs so the next action is
`PPLUGIN-WALKTHROUGH-DRIFT.1`.

**Boundary:** No pplugin walkthrough content, parser/runtime code, shipped specs, or `.plg` runtime behavior changed
in this slice.

**Validation:** `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`bash scripts/check_doctrines.sh`, and `git diff --check` pass.

## 2026-07-07 — PUBLIC-STATUS-DRIFT-SYNC.2 — fix residual shipped corpus count drift

**Scope:** Residual public mdBook count drift found during the full book read.

**Change:** Updated `specs-and-corpora/shipped-specs-and-corpora.md` from the older 91-fixture Rust oracle wording
to the then-current manifest-backed 93-fixture corpus, and pointed readers at
`rust/linkedspec-runtime/tests/corpus/manifest.json` as the exact case-list source.

**Boundary:** No parser/runtime/code behavior changed. Long-form `ROADMAP.md`, `ROADMAP_V2.md`, and
`ARCHITECTURE_STATE.md` count/status drift remain outside this leaf unless the deferred
`ROADMAP-DRIFT-RECONCILE` leaves are activated.

**Validation:** `mdbook build docs/linkedspec-book` passes. Focused stale-count scan over the public
status/handoff/shipped-specs pages has no 91/88 hits. `bash scripts/check_memory_architecture.sh`,
`bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`, and `git diff --check`
pass.

## 2026-07-07 — BOOTSTRAP-RESUME-SYNC.1 — correct stale resume pointer

**Scope:** Continuity docs and task-tree state after the user-directed bootstrap pass.

**Change:** Added and completed `BOOTSTRAP-RESUME-SYNC` to own a stale layer-A resume-pointer finding before
editing continuity docs. `MEMORY.md` now reflects that `PUBLIC-STATUS-DRIFT-SYNC.1` was already committed at
`e1101e1a` and the repo was clean; live docs now point future sessions at the task-tree index instead of an
already-completed closeout.

**Boundary:** No parser/runtime/source behavior changed, and no public mdBook content changed.

**Validation:** `bash scripts/check_memory_architecture.sh`, `bash scripts/check_doctrines.sh`, and
`git diff --check` pass.

## 2026-07-07 — PUBLIC-STATUS-DRIFT-SYNC.1 — sync public Rust status docs

**Scope:** Public mdBook status/handoff drift and the matching Knowledge Map oracle facts.

**Change:** Updated `overview/project-status.md` so Phase 9 no longer calls Rust parity an ongoing follow-on, and
so the ongoing Rust item describes generated-source breadth rather than interpreter parity. Updated
`appendix/backend-handoff.md` to point at `rust/linkedspec-runtime/tests/corpus/manifest.json`, the
then-current 93-fixture Rust interpreter oracle, and the generated-source curated-subset boundary. Refreshed the related Rust
oracle/generated-source Knowledge cards and regenerated `KNOWLEDGE_MAP.md`.

**Boundary:** No parser/runtime/code behavior changed. Long-form `ROADMAP.md` and `ARCHITECTURE_STATE.md` drift
remain owned by `ROADMAP-DRIFT-RECONCILE`.

**Validation:** `mdbook build docs/linkedspec-book` passes. Focused stale-status scan over the touched book pages
is clean. `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`bash scripts/check_doctrines.sh`, and `git diff --check` pass.

## 2026-07-07 — PUBLIC-STATUS-DRIFT-SYNC.0 — create public status drift tree

**Scope:** Tracking-only ownership for public status/mdBook drift discovered during the bootstrap/context pass.

**Change:** Added `docs/tasks/PUBLIC-STATUS-DRIFT-SYNC.md` and registered it in the active task-tree index. The
tree owns the narrow public status surface where `overview/project-status.md` still describes Rust parity as an
ongoing follow-on and `appendix/backend-handoff.md` still names an older Rust oracle corpus count.

**Boundary:** No code, runtime behavior, roadmap content, or book content changed in this slice. The long-form
`ROADMAP.md` and `ARCHITECTURE_STATE.md` drift remains owned by `ROADMAP-DRIFT-RECONCILE`; this tree only owns the
public mdBook status/handoff drift found now.

**Validation:** `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`bash scripts/check_doctrines.sh`, and `git diff --check` pass.

## 2026-07-07 — SPEC-FORMAT-TERSE.9.6 — close hash literal colon drift

**Scope:** Final no-drift closeout for the direct hash-literal `{ key : value }` migration and old
`{ key => value }` retirement.

**Change:** No parser/runtime behavior changed. The closeout records that current specs, corpus inputs, generated
oracle inputs, active tests, docs/mdBook, current Knowledge facts, and implementation support sites are aligned on
`:` for direct hash-literal association.

**Boundary:** Remaining `=>` owners are classified as blind-call edge syntax, VHDL/source-language associations,
generated Perl host output, Perl metadata/test data, backend value-rendering examples, explicit retired-syntax
diagnostics/tests, or historical records. They are not current direct hash-literal source syntax.

**Validation:** Current `.spec` source scans are clean for direct hash-literal `=>`; mdBook proof scans show `:`
documented as current and old `{ key => value }` only as retired. `perl -Iperl tools/gen_oracle_corpus.pl`
regenerates **93** fixtures, `prove -q -Iperl t/actionir_ast_parser.t` passes, focused Rust core/runtime `.9`
filters pass, Rust `corpus_oracle` passes over the manifest-backed **93** fixtures, and full
`prove -q -Iperl t/phase0_regression.t` passes with plan `1..1024`. `.9` is closed with no PNT-eligible child
remaining.

## 2026-07-07 — SPEC-FORMAT-TERSE.9.5 — retire hash literal fat arrows

**Scope:** Perl and Rust hard retirement of old ActionIR hash-literal `{ key => value }` syntax.

**Change:** Direct ActionIR hash literals now use `{ key : value }` only. Perl marks top-level `=>` hash-literal
payloads as retired and lowers them to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` instead of
building a current `hash_literal` AST or falling through to raw/source fallback. Rust rejects `=>` in direct
hash-literal parsing with the same colon-migration diagnostic, and the Rust compiler now makes unsupported
ActionIR-helper parse diagnostics fatal so retired action code cannot be silently compiled as `code: None`.

**Boundary:** Blind-call edge `=> Rule` remains valid rule-body syntax. VHDL/source-language associations,
generated Perl host hashrefs, Perl metadata hashes, and historical records remain separate owners; this slice only
retires source-spelled ActionIR hash-literal association.

**Fix exposed by hard retirement:** Multi-argument AST `array(...)` lowering was re-feeding already-lowered Perl
host hashrefs like `{$key => $value}` through the source-level helper parser. Once old source `=>` became fatal,
that second parse misdiagnosed valid colon hash-literal arguments. The AST aggregate-call path now emits
multi-argument array constructors directly from already-lowered arguments and lowers call arguments such as
`hash(meta)` before direct emission.

**Validation:** Focused Perl syntax and AST tests pass, direct Perl lowering probes show retired `=>` diagnostics
with valid colon hash literals still lowering, focused Rust parser/compiler/runtime filters pass for both colon
success and retired fat-arrow rejection, and full `prove -q -Iperl t/phase0_regression.t` passes with plan
`1..1024`. mdBook, Knowledge Map, memory/doctrine checks, diff check, Rust formatting, and
`bash tools/run_ci_local.sh` pass. Frontier becomes `.9.6` for final no-drift scans.

## 2026-07-07 — SPEC-FORMAT-TERSE.9.4 — migrate hash literals to colon

**Scope:** Current source, generated oracle inputs, active tests, mdBook examples, root docs, and Knowledge facts
for the hash-literal `{ key : value }` migration.

**Change:** Current-facing `.spec` examples and oracle inputs now use `:` for direct hash-literal key/value
association. `specs/user_function_definition.spec`, `specs/tablegrep.spec`, `specs/tkgui.spec`, checked-in
corpus specs, generated Rust oracle inputs, phase0 strings, Rust integration strings, mdBook DSL/helper/runtime
chapters, root guide examples, and current Knowledge fact cards were migrated. `tkgui.spec` now returns a
direct hash accumulator keyed by sub-GUI name, avoiding the old flat-array hash reconstruction.

**Boundary:** Blind-call edge `=>`, VHDL/source-language associations, generated Perl host-output `=>`,
Perl metadata hashes, historical/changelog examples, and the explicit mixed old/new compatibility parser lock
remain intentionally classified. Hard retirement of old hash-literal `=>` remains `.9.5`.

**Fix exposed by migration:** A colon hash literal inside an expression-valued block receiver chain exposed a
Perl `MethodLowering.pm` source fallback that still scanned only for `=>`. The fallback now recognizes top-level
`:` as a hash-pair separator while skipping `::`, so
`{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")` lowers/runs as `"a,b"`.

**Validation:** `tools/gen_oracle_corpus.pl` regenerates **93** fixtures. Focused Perl syntax checks, focused
toolbox probes, `prove -q -Iperl t/actionir_ast_parser.t`, full
`prove -q -Iperl t/phase0_regression.t` with plan `1..1023`, focused Rust parser/runtime filters, Rust
`oracle_corpus_matches_perl_reference`, mdBook, Knowledge Map, memory, whitespace, doctrine gates, and
`bash tools/run_ci_local.sh` pass. Frontier becomes `.9.5` for hard retirement of old hash-literal `=>`.

## 2026-07-07 — SPEC-FORMAT-TERSE.9.3 — add Rust colon hash literals

**Scope:** Rust parser/runtime parity for the hash-literal `{ key : value }` migration window.

**Change:** The Rust ActionIR expression parser now treats top-level `:` as a direct hash-literal pair separator
alongside old `=>`, while explicitly excluding `::` and nested/string/regex separators from brace classification.
Colon hash literals parse in return payloads, direct assignment RHS values, hash-index mutation RHS values,
expression-valued `set(...)` / `=(...)`, array composition, direct hash receiver chains, and nested hash shapes.

**Boundary:** Old `{ key => value }` remains accepted only for the migration window until `.9.5`. Blind-call edge
`=> Rule` syntax is unchanged and remains owned by the rule-body parser, not the ActionIR hash-literal parser.
Current-source/corpus/doc migration to prefer `:` is deliberately left to `.9.4`.

**Validation:** Rust formatting passes. Focused parser tests and the broader
`cargo test --manifest-path rust/Cargo.toml -p linkedspec-core expr::tests::` suite pass for colon-only hashes,
mixed `=>`/`:` migration hashes, assignment/mutation/expression-valued slots, and scanner exclusion of
`::`/nested separators. The runtime integration test `terse_9_3_colon_hash_literals_parse_and_run` passes. mdBook,
Knowledge Map, memory, doctrine, and diff-whitespace gates pass. Frontier becomes `.9.4` for current-source/docs/corpus
migration.

## 2026-07-07 — SPEC-FORMAT-TERSE.9.2 — add Perl colon hash literals

**Scope:** Perl reference ActionIR AST parsing/lowering for the hash-literal `{ key : value }` migration window.

**Change:** The Perl parser now treats top-level `:` as a hash-literal pair separator alongside the old `=>`
separator. Colon hash literals compose in return payloads, scalar assignment RHS values, hash-index mutation RHS
values, expression-valued `set(...)` / `=(...)`, array shape values, and nested array/hash shapes. Bare key/value
slots still lower as scoped scalar reads; quoted keys remain fixed fields.

**Boundary:** Old `{ key => value }` remains accepted only for the migration window until `.9.5`. The scanner skips
double-colon tokens so non-pair brace values such as `{ JSON::PP }` remain expression-valued blocks. Generated Perl
host code still uses Perl fat arrows inside emitted hashrefs; this is not source `.spec` syntax.

**Validation:** `perl -c -Iperl` syntax checks pass for the touched parser/tests, focused
`t/actionir_ast_parser.t` passes, direct toolbox probes match the expected lowering/runtime behavior, and full
`env PERL5LIB= perl -Iperl t/phase0_regression.t` passes with plan `1..1023`. Frontier becomes `.9.3` for Rust
parser/runtime parity.

## 2026-07-07 — SPEC-FORMAT-TERSE.9.1 — split hash literal colon migration

**Scope:** Task-tree, Knowledge Map, and live-doc split/inventory for replacing direct hash-literal association
`{ key => value }` with `{ key : value }`.

**Change:** `.9` is now split into Perl support, Rust parity, source/docs/KM/corpus migration, hard-retirement, and
final no-drift leaves. The inventory classifies direct hash-literal `=>` candidates separately from blind-call edge
syntax, VHDL/source-language associations, historical notes, fixture strings, and parser/runtime support sites.

**Boundary:** No parser/runtime behavior changed. Blind-call `=> Rule` remains valid syntax; VHDL associations are
not part of the ActionIR hash-literal migration.

**Validation:** Knowledge Map regenerated and checked; mdBook builds; whitespace, memory, and doctrine gates pass
in commit closeout. Frontier becomes `.9.2` for Perl reference `{ key : value }` support.

## 2026-07-07 — SPEC-FORMAT-TERSE.8.6 — close helper retirement no-drift

**Scope:** Final helper-retirement drift scan across executable specs/corpora, public docs, tests/code, Knowledge
Map facts, and generated oracle fixtures after Perl/Rust hard retirement.

**Change:** The current authoring surface stays aligned on auto-existing variables, assignment/mutation,
`set(...)`, `push(...)`, `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and bare scalar reads. A stale root
guide sentence that still presented `concat(...)` as current syntax now teaches `cat(...)` and identifies
source-spelled `concat(...)` as retired. A Knowledge fact card records the scan buckets so future sessions do not
redo the same no-drift audit.

**Boundary:** No parser/runtime behavior changed. Remaining old helper names are diagnostics, regression locks,
historical notes, Knowledge facts, or explicit retired-helper reference material; executable current specs/corpora
do not use them as accepted syntax.

**Validation:** Retired-helper scans over `specs/`, root corpus, and Rust oracle corpus classify cleanly; oracle
corpus regeneration is byte-identical over **93** fixtures; Rust `corpus_oracle` passes **3** tests. mdBook,
Knowledge Map, whitespace, memory, and doctrine gates pass in commit closeout.

## 2026-07-07 — SPEC-FORMAT-TERSE.8.5 — reconcile helper retirement docs

**Scope:** User-facing docs, root reference guides, Rust README, Knowledge facts, and task/live docs after Perl and
Rust legacy helper hard retirement.

**Change:** Current-facing guidance now consistently teaches auto-existing variables, direct assignment/mutation,
`set(...)`, `push(...)`, `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and bare scalar reads. Retired helper
spellings (`declare(...)`, declaration aliases, `assign(...)`, scalar-slot wrappers, `array_copy(...)`,
`hash_copy(...)`, source-spelled `concat(...)`, `push_value(...)`, `push_nonempty(...)`, and short wrapper aliases)
are now framed as historical or retired-diagnostic material instead of current authoring. The Rust README now states
the 93-fixture oracle and the retired-helper diagnostic boundary.

**Boundary:** This is a documentation/Knowledge synchronization slice only. No parser/runtime behavior changed.
Historical logs keep dated `.6.4` compatibility policy evidence, but visible summaries now state that `.8` superseded
that policy with hard retirement.

**Validation:** `knowledge-map/scripts/gen_knowledge_map.sh`, `knowledge-map/scripts/check_knowledge_map.sh`,
`mdbook build docs/linkedspec-book`, and `git diff --check` pass. Broader memory/doctrine gates run in commit
closeout.

## 2026-07-07 — SPEC-FORMAT-TERSE.8.4 — hard-retire Rust legacy helpers

**Scope:** Rust parser/runtime retirement for old helper spellings, with Perl oracle fixes needed to keep current
spellings stable under generated corpus regeneration.

**Change:** Rust now diagnoses retired helper spellings instead of executing them successfully: `declare`,
`array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and wrapper aliases `a(...)` / `h(...)`.
Current replacements keep parity: `set(array(...), [])` / `set(hash(...), hash())`, direct shapes, `push(...)`,
`copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and hash receiver `.copy()`.

**Boundary:** Recursive TOP-RULE aggregate reset now records a rule-local binding before mutation, so
`set(array(items), [])` replaces the old Rust scoped `declare(array, items)` behavior. Oracle regeneration also fixed
Perl attached-control source reconstruction so source-spelled `cat(...)` is not rebuilt as retired `concat(...)`.

**Validation:** Perl syntax checks for touched modules, oracle regeneration with `ORACLE_TIMEOUT=45` over **93**
fixtures, focused Rust retirement/TOP-RULE/hash-receiver/corpus tests, full `linkedspec-core`, full
`linkedspec-runtime`, and full phase0 **1022** pass. mdBook/Knowledge Map/doctrine gates are run in the commit
closeout.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.3 — hard-retire Perl legacy helpers

**Scope:** Perl reference ActionIR parser/lowering behavior for the remaining successful legacy helper spellings.

**Change:** Perl now diagnoses declaration helpers and aliases, function-form `concat(...)`, `array_copy(...)`,
`hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)` with
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` instead of lowering them successfully. Current terse spellings keep
working: `cat(...)`, `copy(...)`, `push(...)`, assignments, typed aggregate wrappers, and current receiver methods.
The AST path now preserves source method spelling so current `cat(...)` is not mistaken for retired
parser-normalized `concat(...)`.

**Boundary:** Rust compatibility arms remain pending under `SPEC-FORMAT-TERSE.8.4`; explicit old-helper diagnostic
tests remain as retirement locks.

**Validation:** Focused direct Perl helper probe, syntax checks for touched Perl/test modules, focused
`t/actionir_ast_parser.t`, `t/trace_actionir_compact_lowerers.t`, and `t/phase0_validation_fuzz.t`, full phase0
with `PERL5LIB=` cleared (1022 tests), mdBook build, Knowledge Map regeneration/check, whitespace, memory, and
doctrine gates pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.4 — close helper migration no-drift gates

**Scope:** Final `.8.2` migration closeout scans and gates before hard-retiring legacy helper implementations.

**Change:** The `.8.2` migration parent is closed. Root `specs/` and `tests/corpus/` scan clean for the primary
retired helper spellings and wrapper aliases. Generated corpus and active-test residues are classified as
declaration compatibility, aggregate-copy compatibility, current `.hash_copy()` receiver-method surface, or pending
`.8.3`/`.8.4` hard-retirement locks.

**Boundary:** No parser/runtime behavior changed. This is a scan/gate closeout and frontier advance to `.8.3` for
Perl reference hard retirement.

**Validation:** `perl -c -Iperl tools/gen_oracle_corpus.pl`, `perl -Iperl tools/gen_oracle_corpus.pl` (93 fixtures,
no git drift), Rust `corpus_oracle` (3 tests), full phase0 with `PERL5LIB=` cleared (1022 tests), mdBook build,
whitespace check, and doctrine check pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.3 — migrate book and knowledge helper references

**Scope:** Current-facing mdBook helper guidance, Knowledge fact-card `reverify` commands, and the derived
Knowledge Map.

**Change:** Book examples now teach current helper spellings first: `cat(...)`, `copy(...)`, assignment/operator
forms, `push(...)`, and explicit `is_nonempty(...)` guards before `push(...)`. Old helper names remain in
compatibility/catalog, retired-diagnostic, or historical contexts instead of being presented as current authoring.
Knowledge fact-card `reverify` commands were updated away from legacy helper spellings unless the card explicitly
proves retirement/compatibility, and `KNOWLEDGE_MAP.md` was regenerated.

**Boundary:** No parser/runtime behavior changed. This closes the current-facing docs/KM cleanup before `.8.2.4`
runs the final migration scans/gates.

**Validation:** `mdbook build docs/linkedspec-book`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
`git diff --check`, `bash scripts/check_memory_architecture.sh`, and `bash scripts/check_doctrines.sh` pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.5 — close active test/corpus helper residue

**Scope:** Active Rust/Perl test fixtures, generated oracle inputs, generator source, shipped specs, and checked-in
corpus specs.

**Change:** Closeout scans now show the `.8.2.2` active-test/corpus lane is clean or explicitly classified. Rust
integration wrapper-alias residue now labels `a(...)` / `h(...)` as intentional `.8.4` retirement locks; root
`specs/` and `tests/corpus/` scan clean for the retired helper spellings; generated oracle inputs retain only the
known declaration, aggregate-copy, and current hash receiver-method cases; and the Perl phase0 terse block retains
only the categories classified by `.8.2.2.4`.

**Boundary:** No parser/runtime behavior changed. This is a scan/classification closeout before `.8.2.3` migrates
current-facing mdBook and Knowledge Map references.

**Validation:** Focused old-helper residue scans over Rust active tests, generated corpus inputs, generator source,
root corpus/specs, and the Perl phase0 terse block passed with only owned residual categories. Rust formatting,
whitespace, memory architecture, and doctrine checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.4 — migrate Perl phase0 helper strings

**Scope:** Perl phase0 embedded `.spec` strings in `t/phase0_regression.t`.

**Change:** Current-surface phase0 fixtures now use `cat(...)`, `push(...)`, and `copy(...)` where they are not
explicitly testing legacy compatibility. TOP-RULE recursion append/snapshot strings, user-function fixtures,
auto-existence append proofs, set-key/append/hash-index snapshots, primitive/call-spacing locks, array
end-mutation fixtures, and mutation-expression snapshots were migrated to current helper spellings.

**Boundary:** No runtime behavior or user-facing syntax changed. Retained old-helper hits are classified as
scoped-declaration compatibility, `push_nonempty(...)` semantic-filter compatibility, aggregate-copy compatibility,
explicit helper-renaming equivalence, canonical old-side equivalence, or current `.hash_copy()` receiver-method
surface. A failed candidate confirmed that all-bare `push(words, label)` still routes as child-call-shaped syntax,
so current append fixtures that need a bare RHS use `push(array(words), label)`.

**Validation:** `perl -c -Iperl t/phase0_regression.t` passes. Full phase0 with `PERL5LIB=` cleared passes
**1022** tests. The focused phase0 residue scan shows every remaining old-helper spelling under an explicit owner.
Rust formatting, whitespace, memory architecture, and doctrine checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.3 — migrate generated corpus helper fixtures

**Scope:** Generated oracle corpus fixture inputs and `tools/gen_oracle_corpus.pl`.

**Change:** The `autoexist_array_bare_arg` and TOP-RULE recursion generated inputs now use current
`push(...)`/`copy(...)` spellings for append and snapshot behavior. Incidental setup inside the aggregate-copy
compatibility fixture now uses `push(...)`, while the asserted `array_copy(...)` helper remains intentionally
retained as a generated-corpus compatibility lock.

**Boundary:** No runtime behavior or user-facing syntax changed. Generated oracle expected JSON and manifest output
did not drift. Remaining generated-corpus helper residue is classified as declaration compatibility,
aggregate-copy compatibility, or current hash receiver-method surface.

**Validation:** Generator syntax check passes; regeneration emits **93** fixtures with only expected
`input.spec` changes; Rust `corpus_oracle` passes **3** tests including the full Perl reference comparison.
Residue scans, Rust formatting, whitespace, memory architecture, and doctrine checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.2.5 — classify integration helper residue

**Scope:** Close the old-helper residue scan for `rust/linkedspec-runtime/tests/integration_test.rs` before moving
to generated oracle corpus fixtures.

**Change:** The last unclassified later-fixture hits are now labelled in place: hash receiver `.hash_copy()` calls
are documented as intentional receiver-method surface, and `h(...)` calls in the quoted wrapper-boundary test are
documented as a legacy wrapper-alias retirement lock. Earlier `declare(...)`, `push_nonempty(...)`,
`array_copy(...)`, `hash_copy(...)`, `concat(...)`, and `push_value(...)` hits were already owned by the recursive
or compatibility children.

**Boundary:** No runtime behavior or user-facing syntax changed. The Rust integration-test cleanup lane is closed;
generated oracle corpus fixture migration is next.

**Validation:** The focused residue scan shows every remaining helper spelling in `integration_test.rs` under an
explicit `.8.2.2.2.2`, `.8.2.2.2.3`, or `.8.2.2.2.5` classification comment. Rust formatting passes.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.2.4 — migrate later integration fixtures

**Scope:** Migrate later current-feature Rust integration fixture strings outside explicit compatibility blocks in
`rust/linkedspec-runtime/tests/integration_test.rs`.

**Change:** Later terse feature fixtures now use current helper spellings where the current surface supports them:
`push(...)`/`+=` for appends, `copy(...)` for aggregate snapshots, and explicit aggregate setters for setup. The
array append-operator equivalence test now compares against current `push(...)` rather than the legacy
`push_value(...)` helper.

**Boundary:** This slice does not change runtime behavior and does not hard-retire any helper. Hash receiver chains
still use the documented `.hash_copy()` receiver method, and wrapper-alias `h(...)` fixture strings remain for the
`.8.2.2.2.5` residue-classification leaf.

**Validation:** Focused Rust filters passed for `terse_1_`, `terse_2_3`, `rust_parity_7_3_4`,
`rust_parity_7_5_2`, `terse_11_3`, and `terse_3_3`. Full
`cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test` passed all **172**
tests. Rust formatting and whitespace checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.2.3 — annotate legacy helper compatibility tests

**Scope:** Migrate or annotate explicit legacy-helper compatibility/equivalence tests in
`rust/linkedspec-runtime/tests/integration_test.rs`.

**Change:** Incidental setup and current-side assertions in the early Rust integration compatibility block now use
current `push(...)`, `copy(...)`, and `hash(...)` spellings. The retained old-helper side of equivalence tests is
now explicitly labelled as a Rust `.8.4` hard-retirement lock for `declare(...)`, `push_nonempty(...)`,
`array_copy(...)`, `hash_copy(...)`, `concat(...)`, `push_value(...)`, and the `h(...)` wrapper alias.

**Boundary:** This slice does not remove Rust legacy-helper execution. It makes the remaining old spellings in the
explicit compatibility block intentional and leaves later current-feature fixture cleanup to `.8.2.2.2.4`.

**Validation:** Focused Rust filters passed for `terse_1_1_2`, `terse_1_2`, `terse_1_4_2`, and
`terse_1_3_2`. Full `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test`
passed all **172** tests. Rust formatting, memory architecture, doctrine, and whitespace checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.2.2 — classify recursive helper fixtures

**Scope:** Migrate or classify the legacy helper spellings in the TOP-RULE-AS-NORMAL recursive Rust integration
tests before touching explicit compatibility/equivalence blocks.

**Change:** Recursive `sexpr` fixtures now use current append/snapshot helper spellings (`push(...)`,
`copy(...)`, and `array(...)`) instead of `push_value(...)`, `array_copy(...)`, and `a(...)`.

**Boundary:** `declare(array, items)` remains intentionally in these recursive fixtures. A candidate
`set(array(items), [])` replacement preserves the matching Perl probe but fails Rust recursive value parity by
leaking/overwriting recursive frame state. The mdBook helper catalog and Knowledge Map now record that Rust
`declare(...)` hard retirement must first provide equivalent rule-invocation scoping or a diagnostic path.

**Validation:** Focused TOP-RULE filter and full Rust integration test pass after classification:
`cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test top_rule_as_normal -- --nocapture`
and `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test` (**172** tests).
`mdbook build docs/linkedspec-book`, Knowledge Map, memory architecture, doctrine, and whitespace checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.2.1 — migrate integration smoke helper fixtures

**Scope:** Migrate non-compatibility Rust integration-test smoke fixtures before touching recursive edge cases or
explicit legacy-helper compatibility blocks.

**Change:** `SIMPLE_GRAMMAR`, staged user-function helpers, corpus/lifecycle/edge smoke grammars, `retv_5_1`
fixtures, and `match_5_2` fixtures now use current helper spellings: explicit aggregate setters, `push(...)`,
`copy(...)`, `cat(...)`, and direct scalar assignment.

**Boundary:** Recursive TOP-RULE-AS-NORMAL fixtures and explicit legacy-helper equivalence tests remain unchanged
for later `.8.2.2.2` children.

**Validation:** The scoped helper-hit scan now starts at the later TOP-RULE-AS-NORMAL recursive block. Focused
`full_pipeline` and staged user-function filters passed, and full `cargo test --manifest-path rust/Cargo.toml -p
linkedspec-runtime --test integration_test` passed all **172** tests.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.2.1 — migrate source-emitter helper fixtures

**Scope:** Remove incidental legacy helper spellings from the Rust source-emitter smoke specs before hard-retiring
the old helper names.

**Change:** `rust/linkedspec-runtime/tests/source_emitter.rs` now uses current helper spellings in the embedded
`.spec` fixtures: explicit aggregate initialization through `set(array(...), [])`, `push(...)` appends,
`copy(...)` aggregate snapshots, and `cat(...)` string concatenation.

**Semantic guard:** Direct `name = []` is not a replacement for resetting the named aggregate later targeted by
`push(array(name), ...)`; the migrated fixtures use `set(array(name), [])` where the old `declare(array, name)`
was meant to clear aggregate storage.

**Validation:** A focused residue scan finds no `declare(...)`, `push_value(...)`, `array_copy(...)`,
`hash_copy(...)`, `concat(...)`, or `push_nonempty(...)` calls in `source_emitter.rs`. `cargo test
--manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter` passes all **3** tests, including the
generated Rust compile/run smoke suite.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.2.1 — migrate EBNF nonempty append flow

**Scope:** Remove the current live EBNF dependency on `push_nonempty(...)` before hard-retiring legacy helpers.

**Change:** `specs/ebnf.spec::logging_annotation` now evaluates `trim(capture_slice())` once into
`logging_annotation_part`, gates the append with `is_nonempty(logging_annotation_part)`, and uses
`push(array(logging_annotation), logging_annotation_part)` in both the comma and closing-edge branches.

**Docs/corpus:** The EBNF mdBook walkthrough now shows the explicit filter flow. Regenerated EBNF oracle
`input.spec` copies match the shipped spec; `expected.json` stayed unchanged.

**Validation:** `perl -Iperl tools/gen_oracle_corpus.pl` regenerated **93** fixtures; `LinkedSpec::get_parser("ebnf")`
preserves the `@log_rule("expr", "term")` payload; scoped `push_nonempty(...)` scan is clean for EBNF source/book
and generated EBNF inputs; Rust `corpus_oracle` passed **93** fixtures; `mdbook build docs/linkedspec-book` passed;
full phase0 passed **1022** tests after refreshing the stale source-inspection lock.

## 2026-07-06 — SPEC-FORMAT-TERSE.8.1 — split legacy helper retirement

**Scope:** Inventory and split the legacy helper-removal lane before parser/runtime behavior changes.

**Result:** `.8` now has child leaves for current-source migration, Perl hard retirement, Rust hard retirement,
docs/KM cleanup, and final no-drift closeout. The next active frontier is `.8.2`.

**Ground truth:** Perl already leaves `assign(...)` raw/unlowered and emits unsupported-helper diagnostics for
`scalar(...)` plus `s(...)`/`a(...)`/`h(...)`. Perl still successfully lowers declaration helpers,
`concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)`. Rust still has
successful runtime arms for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and
`array|a` / `hash|h` wrapper aliases.

**Risk owned:** `push_nonempty(...)` filters undef/empty values and has no plain `push(...)` equivalent. `.8.2`
must either migrate current uses with identical behavior through existing terse constructs or split/define a
replacement before support is removed.

**Validation:** `LinkedSpec::call_spec_handler_subst` probe over legacy helper spellings; Rust `engine.rs` /
`expr.rs` code reads; broad current-surface scans over specs/corpus/docs/tests/KM.

## 2026-07-06 — SPEC-FORMAT-TERSE.15.5 — close colon scalar-slot drift

**Scope:** Final no-drift closeout after `.15.2.4` migrated current sources to bare reads, `.15.3` retired Perl
colon scalar slots, and `.15.4` retired Rust `Expr::ScalarSlot`.

**Result:** Current shipped specs, generated corpus inputs, mdBook guidance, active tests, and non-historical
Knowledge Map facts no longer depend on successful `:name` scalar-slot syntax. Remaining colon hits are rule-mode
labels, regex syntax, public API wording, retired-diagnostic code/tests, or explicitly historical fact records.

**Drift fixed:** Two stale Knowledge fact-card examples were corrected to the current surface:
`terse-duck-typed-assignment-perl-reference` now reverifies with bare `items` / `meta`, and
`terse-string-method-surface-verified` now documents statement regex substitution as `substr(target, ...)` rather
than retired `substr(:target, ...)`.

**Validation:**
- Narrow current-surface `:name`/`Expr::ScalarSlot`/`scalar_slot_fallback` scans — PASS after classifying only
  retired-diagnostic and historical hits.
- Live probes for bare duck-typed assignment readback and `substr(target, ...)` mutation — PASS.
- `perl -c -Iperl tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl` — PASS, **93** fixtures.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture` — PASS
  over **93** fixtures.
- `mdbook build docs/linkedspec-book` — PASS.
- `env PERL5LIB= perl -Iperl t/phase0_regression.t` — PASS, plan `1..1022`.

**Frontier:** `.15` is closed. Next active terse frontier is `.8` for legacy helper-removal; `.9` remains pending
behind `.8`.

## 2026-07-06 — SPEC-FORMAT-TERSE.15.4 — retire Rust colon scalar slots

**Scope:** Hard-retire Rust `Expr::ScalarSlot` after `.15.2.4` migrated current sources to bare reads and `.15.3`
retired the Perl reference backend. No compatibility retention.

**Change:** `Expr::ScalarSlot` is removed from the Rust core AST. A leading `:name` value primary now fails at parse
time with `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` and explicit bare-read migration
guidance. Runtime evaluation, mutation-target resolution, child-call scans, and source-emitter fixtures no longer
carry a scalar-slot branch.

**Runtime parity preserved:** Action-edge blocks that call a child or read bare `retv` pre-dispatch the matched
edge child and expose its scoped return to `call(child)` / `retv` during the attached block. The EBNF shipped spec
now uses `rule_header` to avoid the old same-name scalar/array `rule` collision under bare reads, and regenerated
EBNF oracle input fixtures match the shipped spec. The stale generated oracle case
`terse_6_2_3_1_scalar_slot_shorthand` was renamed to `terse_15_4_bare_scalar_payload_readback`.

**Validation:**
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core expr::tests` — PASS.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core compiler::tests` — PASS.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib` — PASS.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test` — PASS.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter` — PASS.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls` — PASS.
- `perl -c -Iperl tools/gen_oracle_corpus.pl` and `perl -Iperl tools/gen_oracle_corpus.pl` — PASS, **93** fixtures.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture` — PASS over
  **93** fixtures.
- `env PERL5LIB= perl -Iperl t/phase0_regression.t` — PASS, plan `1..1022`; Phase0's stale EBNF source lock was
  updated from `rule` to `rule_header` to match the `.15.4` collision fix.

**Frontier:** -> `.15.5` for final colon scalar-slot no-drift closeout.

## 2026-07-06 — SPEC-FORMAT-TERSE.15.3 — retire Perl colon scalar slots

**Scope:** Hard-retire Perl reference `:name` scalar-slot parsing/lowering after `.15.2.4` migrated current
sources to bare value reads. No compatibility retention.

**Change:** `:name` now parses as a retired colon-scalar node and lowers to the unsupported helper sentinel
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` instead of a successful scalar read or
assignment target. `RuleIR::EmitContext` no longer auto-declares colon scalar slots or emits
`scalar_slot_fallback`; the rewrite pipeline handles exact retired forms through the same diagnostic sentinel.

**Bare-read seams kept intact:** Active tests and fixtures moved to bare reads. The removal also locked several
edge cases that `:name` compatibility had masked: bare inline `if`/`elseif`/`switch` conditions survive optional
scope parsing, `or(...)`/`and(...)` keep all operands, ordinary `entry_text()` / `match_text()` value helpers lower
directly while user-function bodies keep parser-state helpers unresolved, assignment-source passthrough delegates to
the value lowerer, flow RHS values can use flow lowering, and `count_keys(snapshot)` counts scalar-held hashrefs.

**Validation:**
- `prove -q -Iperl t/actionir_ast_parser.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t` — PASS.
- `env PERL5LIB= perl -Iperl t/phase0_regression.t` — PASS, reaches `1..1022`.

**Frontier:** -> `.15.4` for Rust `Expr::ScalarSlot` parser/runtime retirement.

## 2026-07-06 — SPEC-FORMAT-TERSE.15.2.4 — migrate current sources to bare reads

**Scope:** Complete the output-preserving source/corpus/docs migration away from `:name` scalar-slot reads now that
Perl and Rust both honor the value-position-is-variable policy. Hard parser/runtime removal remains owned by
`.15.3` and `.15.4`.

**Source migration:** Shipped `specs/*.spec`, root corpus inputs, generated Rust oracle input fixtures, and current
mdBook examples now use bare value reads. Expected Rust oracle JSON and the manifest stayed unchanged after
regeneration over **93** fixtures.

**Runtime/lowering fixes exposed by the migration:** parser-backed `set(...)` control-flow AST nodes are
reconstructed as `set(...)` instead of unsupported `assign(...)`; `split_tagged_records(...)` keeps its first bare
argument as the required source instead of optional scope; fluent `.return(array_copy/hash_copy/copy(...))` is a
general payload return; Perl declaration/type-memory collection recognizes initialized `declare(...)` and
single-bare `array(...)`/`hash(...)` wrappers; Rust action-edge `call(child)` publishes child `retv` only after the
attached block completes, and descriptor scalar bare reads can coexist with same-name aggregate accumulators.

**Validation:**
- `env PERL5LIB= perl -Iperl t/phase0_regression.t` — PASS, reaches `1..1022`.
- `env PERL5LIB= perl -Iperl tools/gen_oracle_corpus.pl` — regenerated **93** fixtures; no expected JSON/manifest
  diff.
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture` — PASS
  over **93** fixtures.
- `mdbook build docs/linkedspec-book`
- `git diff --check`
- Current-surface scalar-slot residue scan reports only expected rule-mode labels, regex syntax, and historical
  literal strings; no live `:name` scalar-slot example remains in the migrated surfaces.

**Frontier:** -> `.15.3` for Perl reference `:name` parser/lowering retirement.

## 2026-07-06 — REPO-HYGIENE.2 — ignore Claude project state and rgx local dirt

**Scope:** User-authorized repository hygiene cleanup for paths that should not be controlled by the parent
LinkedSpec repository.

**Change:** `.gitignore` now ignores `.claude/projects/`. `rgx` remains tracked as a submodule/gitlink, and
`.gitmodules` now records `ignore = dirty` for that submodule so local worktree dirt inside `rgx/` does not dirty
the parent repo status.

**Finding:** `rgx` was tracked as a `160000` gitlink/submodule, so `.gitignore` alone could not suppress its dirty
parent status and should not be used to hide it. The correct parent-repo cleanup is to keep `rgx` in `.gitmodules`
and set the submodule ignore policy for local dirt.

**Validation:** `git status --ignored` shows `.claude/projects/` ignored while `rgx` remains tracked as a `160000`
gitlink; memory/doctrine/diff checks pass.

## 2026-07-06 — SPEC-FORMAT-TERSE.15.2.3 — Rust bare-read parity and switch case-label alignment

**Scope:** Complete Rust parity for the `.15.2.2` value-position-is-variable policy while preserving the
case-label literal exemption. Keep `:name` accepted during the transition; source migration and hard removal remain
owned by later `.15` leaves.

**Rust runtime:** `rust/linkedspec-runtime/src/engine.rs` now routes statement/attached switch cases and inline
lazy `switch(...)` cases through one case-value helper. Bare case labels stringify to their literal tag name
(`case(foo)` matches `"foo"`), while quoted values and scalar-slot expressions still evaluate normally
(`case(:foo)` reads slot `foo`). Bare switch subjects and ordinary value positions continue to read variables, so
`switch(kind)`, `num_lt(n,5)`, and `if(c,...)` match the Perl reference.

**Perl reference alignment:** The new oracle exposed that inline value `switch(..., case(foo, ...))` still read
`$foo`, while statement/attached `case(foo)` was already literal. `MethodLowering` now has a dedicated inline
switch case-value lowering path so inline and attached case labels agree.

**Self-hosted spec source correction:** Regenerating the oracle exposed stale `spec_spec_*` expectations after the
`.11` duck-typed assignment model. `specs/spec.spec` now initializes `paragraphs` and `current` with explicit
aggregate targets (`set(array(...), array())`) so later `push(rule_header, current)` mutations operate on the
working arrays instead of scalar-held arrayrefs.

**Validation:**
- `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`
- `perl -c -Iperl tools/gen_oracle_corpus.pl`
- `env PERL5LIB= perl -Iperl tools/gen_oracle_corpus.pl`
- `cargo fmt --manifest-path rust/Cargo.toml --all --check`
- Focused Rust `.15.2.3` integration tests
- `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture` — PASS
  over **93** fixtures
- `env PERL5LIB= perl -Iperl t/phase0_regression.t` — reaches `ok 1022` / plan `1..1022`, **1021 pass**, only
  known baseline `not ok 796` (`emit_context_lowers_split_tagged_records_helper`)

**Frontier:** → `.15.2.4` for the output-preserving current source/docs/KM migration from `:name` to bare reads.

## 2026-07-05 — SPEC-FORMAT-TERSE.15.2.2 — Perl reference bare-read completion in value positions

**Scope:** Make bare identifiers read the bound typed value in every value position `.15.2.1` enumerated, on the
Perl reference engine, with `:name` still accepted (compat) during the transition. Reference-engine change,
authorized/owned (ADR `0007` sanctioned reference-touching for the terse migration; ADR `0019` engine-first order).

**Change 1 — `perl/LinkedSpec/ActionIR/FlowExpr.pm` (`_lower_flow_composite_expr`, `passthrough_no_call` site):**
a lone bare identifier (`/\A[A-Za-z_][A-Za-z0-9_]*\z/`) that reaches passthrough — provably not `true`/`false`, not
`:name`, not a primitive literal, not direct nested access, not a helper/method call — now lowers to `$name`
(a variable read, `decision => 'bare_variable_read'`), mirroring the `:name` scalar_slot branch. Multi-token
passthrough expressions stay verbatim. Because if/elseif/while + `num_*` + logical conditions all delegate to this
function (via `ControlFlow::_lower_control_flow_value_expr`) and the switch selector funnels through it too, this
ONE change closed all three enumerated gaps at once.

**Change 2 — `perl/LinkedSpec/ActionIR/ControlFlow.pm` (`_lower_switch_case_value_expr`):** a bare word in
switch-CASE-LABEL position stays a literal tag (a label/key position, analogous to the hash-literal-key exemption
in ADR `0019`) — Change 1 would otherwise turn `case(foo)` into `eq $foo`. The literal-tag decision is now made on
the source token (`/^\w+$/` and not `true`/`false`) rather than the pre-`.15.2.2` `$lowered eq $trimmed` probe that
relied on the composite lowerer returning bare words verbatim. Net semantics: `switch(kind)` reads variable `kind`;
`case(foo)` matches literal `"foo"`; use `case(:name)`/quoted for a non-literal case value.

**Validation:**
- Discriminating probes (`scratchpad/probe_15_2_1b.pl`): `switch(kind)`→`good`, `num_lt(n,5)`@n=10→`no`,
  `if(c)`@c=0→`F` — all now equal their `:name` forms; `:name` forms still work.
- Focused switch/case lowering via `call_spec_handler_subst`: selector `$__ls_switch_value = $kind`, case `eq "foo"`,
  default branch intact — matches the phase0 regex lock (test 377/10).
- FULL phase0 (`PERL5LIB= perl -Iperl t/phase0_regression.t`, 10-min timeout): reach `ok 1022` (plan `1..1022`),
  **1021 pass**, only failure `not ok 796` (`emit_context_lowers_split_tagged_records_helper`, pre-existing
  baseline). `comm` vs baseline `{796}` empty both ways — zero new failures, zero regressions.
- `perl -c` clean on both changed modules.
- ENV note: phase0 subprocess tests require `PERL5LIB=` cleared (stale `pgen/fx/perl` checkout otherwise poisons
  the pplugin lazy-load subtests — unrelated to this change).

**Frontier:** → `.15.2.3` (Rust parity). `:name` still compat; full removal is `.15.3`/`.15.4` after `.15.2.4`
source migration.

## 2026-07-05 — SPEC-FORMAT-TERSE.15.2.1 — bare-vs-`:name` value-position inventory + engine seams (design only)

**Scope:** Design/inventory leaf for engine-first `:name` removal. Enumerate every value position where a bare
identifier is NOT read as the bound variable today (while `:name` is), pin the exact Perl+Rust seams `.15.2.2`/
`.15.2.3` must change, and lock the value-position-is-variable policy. **No engine/source/mdBook behavior changed.**

**Evidence (LinkedSpec's own `LinkedSpec::Get` probe, discriminating values so a bare-fallback differs from a real
read):**
- `switch(...)` selector — `{ set(kind,"b"); switch(:kind){...case("b"){"good"}default{"def"}} }`: `:kind`→`good`
  (reads scalar), `kind`→`def` (bare NOT read).
- `num_*(...)` callee args — `{ set(n,10); switch(num_lt(:n,5)){...} }`: `:n`→`no` (10<5 false), `n`→`yes`
  (bare `n`→numeric 0, 0<5 true).
- `if(...)`/`while(...)`/logical conditions — `{ set(c,0); if(:c){"T"}else{"F"} }`: `:c`→`F` (0 falsy), `c`→`T`
  (bare truthy bareword).
- Already-correct (no gap): plain `return(name)`, assignment RHS, receiver — `return(:v)`==`return(v)`==`V`.
- Real shipped-spec hazard: rule-name collisions in `spec.spec`/`ebnf.spec` (a bare name matching a rule/token name
  resolves as a rule reference; `spec_spec_minimal_rule`→`[]`) — authoritative evidence in ADR `0019`. `switch(`
  appears in NO shipped spec, so the synthetic positions are fixtures; the collision class is the live risk.

**Seams identified (not touched):**
- Perl central: `ActionIR::FlowExpr::_lower_flow_composite_expr` (`perl/LinkedSpec/ActionIR/FlowExpr.pm:319`); the
  `:name`→`$name` branch at `:364` has no bare counterpart. Covers if/elseif/while/logical + `num_*` args (num
  names matched `:374`, args recursed `:422`).
- Perl switch selector/case: `ActionIR::ControlFlow::_control_ast_value_source_expr`
  (`perl/LinkedSpec/ActionIR/ControlFlow.pm:332`) + `_lower_switch_case_value_expr` (`:104`).
- Rust: bare→`Expr::Variable` (`rust/linkedspec-core/src/expr.rs:1350`, selector test `:1788`); `:name`→
  `Expr::ScalarSlot`→`ctx.get_scalar` (`rust/linkedspec-runtime/src/engine.rs:3287`).

**Policy locked (ADR `0019`):** in a value-expression position a bare identifier is a variable/parameter read; rule
references appear only in edge/dispatch positions (`-> Rule`, `call(Rule)`, `=> Rule`, all-bare
`push(RuleA, AccumB)`); scalar push uses `items += value` / `push(array(items), value)`. Composes with the `.11`
type-at-assignment duck-typed model (already captured under `.11`): a bare name's type is fixed by the RHS shape at
assignment (scalar←string/number, array←`[...]`, hash←`{ key: value }`, code-block←`{ ... }`), and a bare read
returns that bound runtime typed value.

**Validation:** design/inventory only — no code path changed, so no phase0 delta (baseline stays 1021 pass / 1
pre-existing unrelated fail, test 796). Probes: `scratchpad/probe_15_2_1.pl`, `probe_15_2_1b.pl`. Frontier →
`.15.2.2` (Perl bare-read completion).

## 2026-07-05 — SPEC-FORMAT-TERSE.15.2 — reorder .15 to engine-first (bare-read gap) + recovery

**Scope:** Recover a prior session's dirty working tree and re-sequence `:name` removal after proving the planned
source-first migration is not output-preserving. Planning + recovery only; no engine/source behavior changed.

**Recovery:** A prior session left the working tree dirty with uncommitted, intermingled `.15.2/.15.3/.15.4/.8/.9`
work (152 files, phase0 RED). It is preserved verbatim on branch `recovery/terse-15-uncommitted-20260705` (commit
`b1a2aefe`, reference-only — do not merge); `main` is reset clean to `104088e5`.

**Finding:** Executing the source-first `.15.2` migration (apply `:name`→bare to `specs/*.spec` + oracle sources,
regenerate the corpus, read the byte-identity gate) proved it is NOT output-preserving at `104088e5`. Bare
identifiers are not read as the bound variable value in `switch(...)`, numeric callees (`num_lt`/`num_gt`),
`if(...)` conditions, or the second arg of all-bare `push(A,B)`, and collide with rule names in
`spec.spec`/`ebnf.spec`. Direct reference-engine probe: `switch(:kind)` → `'good'` vs `switch(kind)` → `'def'`.
`:name` was disambiguating variable-read from rule-reference. Most shipped specs (`ds_vhistory`, `lib_reader`,
`pplugin`, `simenv`, `tablegrep`, `tkgui`, `vhdl`) were output-preserving.

**Decision (user directive: `:name` shall NOT be supported):** `.15` is re-sequenced ENGINE-FIRST. `.15.2` now
owns `.15.2.1` design/inventory, `.15.2.2` Perl bare-read completion, `.15.2.3` Rust parity, `.15.2.4` source
migration (output-preserving); then `.15.3`/`.15.4` remove `:name` entirely (no compat), `.15.5` closeout. Policy:
in value positions a bare identifier is a variable read; rule references appear only in edge/dispatch positions
(`-> Rule`, `call(Rule)`, `=> Rule`, all-bare `push(RuleA, AccumB)`); scalar push uses `items += value` or
`push(array(items), value)`.

**Artifacts:** ADR `0019`, KM card `terse-bare-read-value-position-gap`, task-tree `.15` re-sequence + `.15.2.*`
child leaves, `KNOWLEDGE_MAP.md` regenerated (201 facts).

**Verification:** Baseline phase0 = 1021 pass / 1 pre-existing unrelated fail (test 796
`emit_context_lowers_split_tagged_records_helper`). Memory-architecture, Knowledge Map, and doctrine gates pass.
No parser/runtime/source behavior changed.

## 2026-07-05 — SPEC-FORMAT-TERSE.15.1 — split colon scalar-slot removal

**Scope:** Audit and task-tree split for removing `:name` scalar-slot syntax from the future duck-typed surface.

**What changed:** `SPEC-FORMAT-TERSE.15` is now split into signoff-sized leaves. The audit found current `:name`
use across shipped specs, root corpus examples, generated Rust oracle fixtures, mdBook guidance, Knowledge Map
facts, active Perl/Rust tests, `tools/gen_oracle_corpus.pl`, and both parser/runtime implementations. Hard removal
is therefore not one safe slice. The frontier is `.15.2` for current authored spec/corpus/docs/KM migration to
bare value reads before Perl and Rust parser/runtime retirement work.

**Tests:** Audit scans and documentation gates only; no parser/runtime behavior changed.

**Status:** `.15.1` is complete; `.15.2` is active.

## 2026-07-05 — SPEC-FORMAT-TERSE.11.5 — close duck-typed assignment alignment

**Scope:** Roadmap/live-doc/Knowledge Map alignment for the completed duck-typed assignment lane.

**What changed:** Current-facing roadmap wording now describes direct RHS shape assignment as typed value binding,
not declaration or storage-class inference. Historical target-kind inference remains documented only as superseded
history. Knowledge Map fact cards that referenced the old inference as a dependency now point readers to the `.11`
supersession, and the generated `KNOWLEDGE_MAP.md` was refreshed.

**Tests:** Stale-wording scans across current-facing docs/facts, Knowledge Map regeneration/check, mdBook build,
memory/doctrine checks, and whitespace diff check.

**Status:** `.11.5` and the `.11` duck-typed assignment container are complete; the frontier moves to `.15`.

## 2026-07-05 — SPEC-FORMAT-TERSE.11.4 — implement nested value-path assignment

**Scope:** Perl/Rust nested direct-access assignment, focused phase0/Rust locks, generated oracle corpus, mdBook
semantics, and Knowledge Map coverage for duck-typed value-path writes.

**What changed:** Multi-segment lvalues such as `payload["items"][0]["name"] = value` now mutate scalar-held
array/hash payload trees on Perl and Rust. The implementation checks every intermediate segment explicitly rather
than relying on Perl autovivification: intermediate containers must already exist and have the required shape,
final hash keys may be created or replaced, final array indexes may replace existing elements or append exactly at
len, and missing/wrong/gap paths return `undef`/`null` without mutating the root. Expression-valued nested
assignment returns the updated root on success. Single-segment `payload[1] = value` now also mutates a scalar-held
array root consistently before falling back to named-hash storage when the bare name is not scalar-bound.

**Tests:** Perl syntax checks for the touched ActionIR/EmitContext modules; focused `LinkedSpec::call_spec_handler_subst`
and `LinkedSpec::Get` probes for nested statement/value assignment, scalar-held array roots, generated declarations,
and descriptor readiness; focused Rust `terse_11_4` tests; oracle corpus regeneration; Rust corpus oracle over
**92** fixtures. The generator's known `spec_spec_*` expected-output drift was restored to the existing AST
expectations before the passing oracle run.

**Status:** `.11.4` is complete; `.11.5` is active for final duck-typed assignment closeout alignment.

## 2026-07-05 — SPEC-FORMAT-TERSE.11.3 — implement Rust duck-typed assignment parity

**Scope:** Rust runtime assignment semantics, the oracle-exposed Perl scalar-held copy/receiver read gap, focused
integration locks, generated Perl/Rust oracle fixtures, mdBook alignment, and Knowledge Map facts for the current
duck-typed assignment contract.

**What changed:** Rust now matches the Perl `.11.2` reference: bare `name = value`, `set(name, value)`, and
`=(name, value)` bind the evaluated `RuntimeValue` directly to the scalar value slot, including array and hash RHS
values. The old direct RHS-shape retagging path was removed for bare targets, so `items = [value]` and
`set(items, [value])` store scalar-held typed values while explicit `set(array(items), [value])` and
`set(hash(meta), {...})` remain aggregate-storage mutations. Scalar-held `array(name)` / `hash(name)` views,
`copy(...)`, aggregate-consuming helper arguments, and receiver chains now read guarded typed snapshots. The final
oracle pass also closed the matching Perl reference gap where scalar-held `copy(items)` and bare array receiver
chains still preferred aggregate storage unless explicitly wrapped, and the Perl declaration collector now records
`my $name` rather than `my @name` / `my %name` for scalar-held `copy(name)` readback.

**Tests:** Perl syntax checks and focused `LinkedSpec::Get` probe for scalar-held `copy(...)` / receiver-chain
readback; focused Rust runtime tests for `terse_11_3`, `terse_6_2_3_1_scalar_slot_shorthand_runs`,
`terse_3_3_2_aggregate_assignment_expressions_run`, and `terse_3_3_4_assignment_expression_closure_run`; oracle
corpus regeneration; Rust corpus oracle; mdBook build; Knowledge Map, memory-architecture, doctrine, and diff
checks. Broad `prove -q -Iperl t/phase0_regression.t` completed with the `.11` locks clean and one known unrelated
failure: `emit_context_lowers_split_tagged_records_helper` still reports `unresolved_helper_count == 1`.

**Status:** `.11.3` is complete for Rust parity; `.11.4` owns nested mixed value paths.

## 2026-07-05 — SPEC-FORMAT-TERSE.11.2 — implement Perl duck-typed assignment binding

**Scope:** Perl reference assignment lowering, generated-source declaration collection, focused Perl locks, and
Knowledge Map facts for duck-typed bare assignment values.

**What changed:** Bare Perl assignment targets now bind the evaluated RHS through one scalar value slot. Direct
shape RHS values lower as scalar-held typed values (`name = []` -> `$name = []`, `set(name, [value])` ->
`$name = [$value]`, expression-valued `set`/`=` returns `$name`) instead of retagging the target as `@name` or
`%name`. Explicit `array(...)` / `hash(...)` assignment targets still use aggregate storage, and scalar-bound
`array(name)` / `hash(name)` views now read guarded snapshots from `$name`.

**Tests:** `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm`; `perl -c -Iperl t/phase0_regression.t`; `git diff --check -- perl/LinkedSpec/ActionIR/MethodLowering.pm perl/LinkedSpec/RuleIR/EmitContext.pm t/phase0_regression.t`; focused `LinkedSpec::call_spec_handler_subst`, generated-source declaration, and runtime probes for `.11.2` assignment/readback/closure semantics. A clean detached-worktree `prove -q -Iperl t/phase0_regression.t` rerun completed with the `.11.2` assignment locks green and one helper-readiness failure outside this slice: `emit_context_lowers_split_tagged_records_helper` reports `unresolved_helper_count == 1` and therefore is not language-agnostic ready.

**Status:** `.11.2` is complete for Perl; Rust parity moves to `.11.3`.

## 2026-07-05 — SPEC-FORMAT-TERSE.11.1 — split duck-typed assignment work

**Scope:** Task-tree split, code/book inventory, and toolbox probe record for the active duck-typed assignment
semantics lane.

**What changed:** Split `SPEC-FORMAT-TERSE.11` into child leaves after reading the active code paths and mdBook
drift. `.11.1` records the current ground truth: Perl still lowers direct RHS shape assignment into `@name` /
`%name` target-kind inference and Rust still has matching direct-shape assignment branches. The frontier now moves
to `.11.2` for the Perl reference value-binding implementation, followed by Rust parity, nested path semantics, and
docs/KM/corpus closeout.

**Tests:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`; `perl -Iperl -MLinkedSpec -e 'print $INC{"LinkedSpec.pm"},"\n"'`; focused `LinkedSpec::call_spec_handler_subst` probes for shape assignment lowering.

**Status:** `.11.1` is complete; no parser/runtime/mdBook behavior changed in this split slice.

## 2026-07-05 — SPEC-FORMAT-TERSE.15 — track colon scalar-reference removal

**Scope:** Task-tree/index/live-doc tracking for removing scalar-slot punctuation from the future duck-typed
surface.

**What changed:** Added pending `SPEC-FORMAT-TERSE.15` to own removal of `:name` scalar variable references. The
future duck-typed surface reads variables and parameters as bare names in value-expression positions. Bare names in
hash-literal key position remain stringified keys, so `.15` must preserve a clear key-position vs value-position
grammar/AST boundary when implemented.

**Tests:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

**Status:** `.15` is pending and owned; no parser/runtime behavior changed in this tracking slice.

## 2026-07-05 — SPEC-FORMAT-TERSE.14 — track trailing block arguments

**Scope:** Task-tree/index/live-doc tracking for a future block-argument type on helper and receiver-method calls.

**What changed:** Added deferred `SPEC-FORMAT-TERSE.14` for trailing code-block arguments. The future surface is
specified as a block-argument type, not closures: blocks may appear only as the final argument, preferred syntax is
`fn(args) { ... }`, zero-arg `fn { ... }` remains grammar-gated, and inline `fn(args, { ... })` stays deferred or
allowed only if it is unambiguous from hash literals. The leaf also requires an explicit callee-side invocation
surface: how helpers/methods call the block, pass context, consume returns, and diagnose missing/non-callable
blocks must be specified before code.

**Tests:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

**Status:** `.14` is deferred/spec backlog and not PNT-eligible unless explicitly activated.

## 2026-07-05 — SPEC-FORMAT-TERSE.12/.13 — track tree traversal backlog

**Scope:** Task-tree/index/live-doc tracking for future attached-block tree traversal receiver methods.

**What changed:** Added deferred `SPEC-FORMAT-TERSE.12` for hash-tree traversal methods with attached code blocks
and lower-priority backlog `SPEC-FORMAT-TERSE.13` for analogous array-tree traversal. The hash-tree backlog item
defines the intended tree shape as a hash root, hash interior nodes, and scalar or array leaves. Both leaves require
spec-first method names, block context, traversal order, return/mutation policy, diagnostics, mdBook examples,
tests, oracle fixtures, and Knowledge Map updates before implementation.

**Tests:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

**Status:** `.12` and `.13` are deferred/backlog and not PNT-eligible unless explicitly activated.

## 2026-07-05 — SPEC-FORMAT-TERSE.11 — track nested typed-value paths

**Scope:** Task-tree/index/live-doc refinement for the active duck-typed assignment semantics leaf.

**What changed:** Expanded `SPEC-FORMAT-TERSE.11` acceptance so deeply nested references and assignments through
mixed array/hash value trees are explicitly required in arbitrary combinations. The task now requires the
implementation to define and test intermediate-container behavior for nested writes instead of inheriting Perl
autovivification behavior accidentally.

**Tests:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

**Status:** Implementation remains pending under the active `.11` leaf.

## 2026-07-05 — SPEC-FORMAT-TERSE.11 — activate duck-typed assignment semantics

**Scope:** Task-tree ownership, top-level task index, and resume pointer for the new duck-typed assignment
semantics direction.

**What changed:** Added active leaf `SPEC-FORMAT-TERSE.11` to own the decision that `.spec` assignment should bind
runtime typed values instead of exposing Perl scalar/array/hash storage classes. The leaf specifies that
`name = [...]` binds an array value and `name = {...}` binds a hash value, with later rebinds allowed to change
shape. It also keeps delimiterless aggregate RHS sugar such as `name = a, b` and `name = k : v` out of the MVP
unless a future leaf explicitly owns its precedence and diagnostics.

**Tests:** `git diff --check -- docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md MEMORY.md`.

**Status:** `.11` is the active spec-first assignment-semantics owner. The broader in-flight `.8` helper-removal
work remains uncommitted and must align with `.11`; no runtime behavior changed in this tracking slice.

## 2026-07-04 — TRACE-OBSERVABILITY.4.5 — close trace parity proof

**Scope:** Cross-variant trace parity proof, future-variant checklist, Rust dump/log primitive coverage, mdBook/
TOOLBOX/live docs, task-tree closeout, and Knowledge Map.

