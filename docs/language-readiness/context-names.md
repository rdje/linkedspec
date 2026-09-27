# Bounded context-dependent name matching

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1`, from clean `8ea0c1107889b02e68eeb874970ecdbb4bb41ab2`.
The source is `tests/language-readiness/context-names/grammar.spec`; `cases.json` contains independently authored
ASTs, Unicode scalar spans and rejection statuses. The original nesting fixture is unchanged.

## Language and composition

The document accepts zero or more tag-like elements, with ASCII whitespace between them. An opening or closing
name matches `[A-Za-z][A-Za-z0-9_-]*`. An element contains other elements or literal Unicode text excluding angle
brackets; spaces/newlines inside elements are preserved. Empty input is accepted. There are no attributes,
self-closing elements, comments, entity expansion or Unicode tag names. This is not XML conformance.

The `Element` entry action saves `entry_group(0)` as `name`, initializes `children` and saves its start position.
Its closing edge selects regex slot 1, reads `match_group(0)` and uses `str_ne` against the saved name. Rule recursion
must restore the enclosing name/children/start before that comparison and AST construction. Captures are indexed
from the first participating parenthesized group; bare `ne` is numeric, so lexical comparison is explicit.

The public `LinkedSpec::Get` probe returns all five rules ActionIR-ready, no blockers/compatibility-only rules.
`call_spec_handler_subst` lowers the closing comparison to the current captured text versus `$name`, using lexical
`ne` and the typed RuntimeDiagnosticOutput termination owner. This directly locates the intended mechanism.
No production change is needed to express the bounded objective.

## Independently authored cases

Eleven accepted cases cover empty input/element, distinct/repeated nested names, siblings restoring the parent,
three nested levels, multiple forms, CRLF, supplementary Unicode, case-sensitive names and literal entity text.
Seventeen rejected cases cover mismatched/crossed/case-different names, missing inner/outer closes, bare/trailing/
interstitial text, stray closes, attribute/self-closing/malformed/empty-name/markup syntax, a skipped hash-comment
prefix and non-ASCII names. Status 1 means invalid syntax; status 2 name mismatch; status 3 missing close in this
specific grammar. The proof does not claim message text, error coordinates or in-document repair.

The initial public probe passed 10 accepted/17 rejected cases. A later independently authored three-level control
adds chained restoration across two returns; existing expected values never change. The first expanded Perl
regression passes 406 top-level tests before that addition. Final proof passes 410 top-level tests in25 seconds, including all192 original nesting/entry assertions. Four direct-dependent files pass89 tests; managed storage retains27 owners. Exact commands and hashes are recorded in the owning checkpoint.

## Perl native and fresh emitted proof

`t/nested_tree_readiness.t` retains all original nesting/entry cases and adds the context grammar to the same
variant harness and managed temporary workspace. Each original context route executes 90 calls: two rounds of
11 accepts plus 17 rejection/immediate-success pairs. Every rejection requires LinkedSpec::RuntimeExitNow with the
exact authored status and no result. The following success reuses the same native closure or already-loaded
emitted module, proving 34 recovery transitions per route. Canonical JSON comparison preserves scalar/container
kinds and exact values/spans; a null-like return cannot count as rejection.

Three separately compiled mutations demonstrate oracle sensitivity:

| Mutation | Exact source change | Independent observable |
| --- | --- | --- |
| Comparison | Remove one closing-name guard | `<a></b>` wrongly returns the authored empty `a` element with span `[0,7]`. |
| State | Add `name = "lost"` after the one recursive child edge | Valid nested siblings wrongly exit with status 2. |
| Span | Replace the saved start expression by the final cursor | `<a>x<b>β</b>y</a>` wrongly reports outer span `[17,17]`, rather than `[0,17]`. |

The emitted runner is a fresh process; it loads each module once, checks v2 identity/metadata/plan and executes
its entire sequence. Actual child success and exact result counts are required. Context identities are
`context-names/original`, `comparison`, `state` and `span` under that prefix. The existing managed owner creates
all artifacts; no new File::Temp owner, global cache, package store or dependency is introduced.

Repeat from the repository root:

```sh
bash tools/project_data_run.sh prove -v -Iperl t/nested_tree_readiness.t
```

## Authoring assessment and remaining work

Existing captured values, lexical comparison, rule-local state and explicit AST construction express this
bounded context requirement. Strict acceptance still needs separate prefix/gap/end/missing-close guards.
Three statuses improve rejection classification but richer grammar-specific diagnostics remain unassessed.
The three-level control is not arbitrary-depth/resource proof; recognition rollback does not imply user-variable
or AST rollback. Do not generalize to indentation, XML or other standards.

All native and typed-carrier evidence is reconciled under `.1.1.3.2.7`. The bounded context-name objective
closes through that exact staged canonical milestone. Lossless segmentation/child parsing `.1.1.3.3` precedes
language-gap selection `.1.1.4`; the structured-format campaign remains gated. No new comparison or recursive-
state primitive is selected on the strength of this bounded result.

## Public native adapter proof

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2`, from clean `8b11f40705b31e9c83037602e67758c81a676bd7`.
The unchanged context grammar/cases pass each documented native text consumer:

| Runtime | Accepted cases | Rejected cases | Accepted parses on one engine | Rejection projection |
| --- | ---: | ---: | ---: | --- |
| Perl | 11 | 17 | 22 | typed JSON runtime_exit_now with exact grammar status |
| Rust | 11 | 17 | 22 | published Display text exit_now(status) |
| Dart | 11 | 17 | 22 | typed JSON runtime_exit_now with exact grammar status |
| Julia | 11 | 17 | 22 | typed JSON runtime_exit_now with exact grammar status |
| PUC Lua | 11 | 17 | 22 | typed JSON runtime_exit_now with exact grammar status |
| LuaJIT | 11 | 17 | 22 | typed JSON runtime_exit_now with exact grammar status |

The application adapters all choose process exit1 for rejected input; the grammar's1/2/3 status remains separate.
Accepted cases run forward then reversed through one compiled engine. Each rejected input gets a separate
process, must produce no value/stdout, and must report the exact authored status. This establishes positive
reuse and exact rejection, not retained-engine recovery after failure. Rust Display text is not typed-error proof.

The existing `tests/language-readiness/nested-tree/verify_native.py` adds only two fixed fixture choices; its
unchanged default remains the original6/7/12 nesting trial. The rejection check now reads each authored status,
with1 as the original fixture's default. Canonical JSON preserves scalar/container kinds, and all grammar/case/
adapter/product hashes are checked before and after execution. Unknown fixture choices fail before file access.

```sh
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --fixture context-names --runtime rust
```

Repeat for perl, dart, julia, puc and luajit. The Rust consumer is rebuilt with the published locked offline
integration command; the existing project-local Dart/Julia/Lua stores are reused. The source adapters, runtime,
dependency pins and both grammar/oracle pairs stay unchanged. Both fixtures are verified on all six routes;
exact reports, product/source/log hashes and option controls are in this leaf's checkpoint.

Perl's separate fresh emitted/recovery/mutation proof is unchanged. All backend carrier proofs below reconcile under milestone .7. No XML or broader format admission follows.

## Rust typed carriers and retained recovery

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3`, from clean `c4e1534da918ace02cc03aba28c021e581df54f0`.
The existing Rust readiness harness adds the unchanged context fixture and a shared typed checker. All six
routes execute 90 original calls and three comparison/state/span mutations, with exact authored JSON values,
Unicode spans and rejection statuses 1, 2 and 3:

| Route | Lifetime | Immediate rejection-to-success transitions |
| --- | --- | ---: |
| Compiled native engine | Retained | 34 |
| JSON-reconstructed native engine | Retained | 34 |
| Compiled engine with generated plan | Retained | 34 |
| JSON-reconstructed engine with generated plan | Retained | 34 |
| Public serialized v2 entry | Engine created per call | Isolation only |
| Independently compiled emitted v2 module | Engine created per call | Isolation only |

The checker matches only the public typed Exit variants and compares their exact status. Successful null
remains an Ok value and cannot satisfy a rejection. Four retained routes establish 136 recovery transitions;
per-call entries establish isolation. Five authored rule labels, generated plan validity and every fresh
module's v2 metadata/source identity are checked. Both original nesting and context fixtures run through real
child Cargo processes, each requiring exit success and exactly four executed tests. The original nesting
oracles/checker remain unchanged, with 40 calls and three original mutations per route.

The first combined run exposed a test-only naming race: PID plus clock nanoseconds can collide between threads.
The existing exclusively owned scratch helper now adds a process-local atomic sequence, without reusing or
removing another directory. Both fixtures keep the same local dependency store and emitted target. No runtime,
fixture, root lockfile, generated contract or storage policy changes.

```sh
bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml \
  -p linkedspec-runtime --test nested_tree_readiness --test leading_input_trivia \
  --test sexpr_document_v1 -- --nocapture
```

The checkpoint records the initial failure and final combined verification separately. Bounded direct-dependent
checks cover leading trivia and the strict S-expression document. Both Lua carrier proofs are recorded below; milestone .7 reconciles the complete bounded result.

## Dart typed carriers and emitted package

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4`, from clean `2cf465ae780013af4153e4129b31ad9db227b7d1`.
Six Dart routes pass the same 90 original calls and comparison/state/span mutations: native and SpecFile-JSON
reconstructed engines, each with native and generated-plan execution; the public v2 entry; and a fresh emitted
module. The first four retain an engine for 34 rejection/immediate-success pairs each (136 transitions). The
last two create an engine per call and prove isolation. Only RuntimeExitNow with the authored status satisfies
a rejected case; returned null, a different exception or a wrong status fails. Exact JSON comparison preserves
container/scalar kinds as well as values and spans.

The existing harness now takes explicit fixture inventory, recovery-case and span settings. Its original
nesting defaults remain 6/7 cases, 40 calls and the original three mutants. Both grammar/oracle pairs stay
unchanged. Each emitted package contains four modules and must complete offline resolution, fatal analysis
and actual execution successfully; its JSON report must say exactly four modules, the configured original
execution count and three mutations. V2 metadata, source identity and plan checks remain mandatory.

```sh
cd dart
bash ../tools/run_dart_project_data.sh test --reporter expanded \
  test/nested_tree_readiness_test.dart test/source_emitter_test.dart test/sexpr_document_v1_test.dart
bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test/nested_tree_readiness_test.dart
```

The combined suite passes 62 tests (four readiness plus 58 existing emitter/document checks). Changed-file
formatting and package-context analysis pass. Directly analyzing the shared helper outside a Dart package
cannot resolve its package import; both real emitted packages analyze the copied helper with fatal diagnostics
and pass. This invocation limitation is recorded separately from runtime proof. No whole-package gate claim:
the known SDK deprecations remain owned by DART-STARTUP-READING.2.25. Existing managed temporary-package cleanup,
local stores, root lockfile and production code are unchanged. Lua proof is recorded below; milestone .7 reconciles the complete bounded result.

## Julia typed carriers and fresh emitted host

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5`, from clean `8e2ac09679ddd0a4a361fdfc1e42e72c66bd700d`.
Five public Julia routes pass 90 original calls and three context mutations each. Native and SpecFile-JSON
reconstructed engines each retain their instance across 34 typed rejection/immediate-success pairs, giving
68 recovery transitions. Public v2 execution on both compiled forms and the fresh emitted module create an
engine per invocation; those three routes establish isolation. Rejection requires RuntimeExitNow with the
exact authored status; successful nothing, another exception or a different status cannot satisfy it. Strict
JSON checks distinguish Bool from Number and preserve exact keys, values and Unicode spans.

The existing emitter test and shared checker take explicit fixture options while preserving nesting defaults.
The fresh host reads the selected cases and options as data, loads each of four emitted modules, checks v2
metadata/identity/plan, retrieves bindings through the existing latest-world helper and then invokes them.
Actual process success and exact JSON output remain mandatory; merged warnings cannot be discarded. Both
fixture hosts verify cleanup, and the original source/oracle pairs and Julia manifests remain unchanged.

```sh
bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/source_emitter_test.jl"); include("julia/test/sexpr_document_v1_test.jl")'
```

All 253 assertions pass: 30 context, 30 nesting, 65 existing emitter and 128 strict-document. The storage check
still passes 22 temporary owners/five locked package trees. No private generated-family keyword, runtime,
dependency or schema change is introduced. Both Lua ABIs are verified below; milestone .7 reconciles the complete bounded result.

## PUC Lua and LuaJIT typed carriers

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6`, from clean `2a5b9c859d725c2cc6ece83c50d16ab69cc36766`.
Each ABI independently passes five routes with 90 original calls and three context mutations per route.
Native and SpecFile-JSON reconstructed engines each retain their instance across 34 typed rejection/immediate-
success pairs (68 transitions per ABI). Public v2 on both compiled forms and the independently loaded emitted
module create an engine per invocation. Only those two native routes establish retained recovery.

The shared checker requires failed pcall plus the public RuntimeExitNow predicate and exact authored status.
Successful nil cannot pass as rejection. Canonical JSON checks preserve array/harray tags, empty containers,
scalar kinds, exact values and Unicode spans. Explicit fixture options preserve nesting defaults and original
40-call/three-mutant proof. The unchanged context and nesting source/oracle pairs remain independent authority.

Each fixture's four emitted modules run in a fresh process using the explicitly selected ABI and current
source/native module paths. Metadata, identity and plan checks precede execution. The parent requires actual
process success, empty stderr, an exact completion report and removal of the owned workspace. No process
output is normalized to hide warnings or failures.

```sh
bash tools/run_lua_project_data.sh puc -e 'dofile("lua/test/rule_local_cursor_generated_source_test.lua"); dofile("lua/test/sexpr_document_v1_test.lua")'
bash tools/run_lua_project_data.sh luajit -e 'dofile("lua/test/rule_local_cursor_generated_source_test.lua"); dofile("lua/test/sexpr_document_v1_test.lua")'
```

Both final runs pass 160 generated-v2 assertions plus 51 strict-document cases, 27 round trips and 24 retained
recovery checks. The real storage gate passes 19 owners, three dual-ABI modules and all 30 census controls.
No runtime, dependency, fixture, schema or storage-policy change. Known malformed-regex handling remains
separately owned; this is no unfiltered full Lua gate or format admission. Canonical context .7 closes only this bounded objective.

## Reconciled bounded result

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7`, from clean `c20c123dd0573b1d831a0b4910a67091fa5572f2`.
The six public native text adapters each pass 11 accepted/17 rejected cases and 22 forward/reverse accepted
parses. Their process-exit behavior remains distinct from the typed carrier evidence:

| Runtime | Typed routes | Retained parsers | Immediate recovery transitions |
| --- | ---: | ---: | ---: |
| Perl | 2 | 2 | 68 |
| Rust | 6 | 4 | 136 |
| Dart | 6 | 4 | 136 |
| Julia | 5 | 2 | 68 |
| PUC Lua | 5 | 2 | 68 |
| LuaJIT | 5 | 2 | 68 |

Each typed route runs 90 original calls and three grammar mutations. These are repeated executions of the same
28 independently authored cases, not 90 different cases or a format corpus. Each retained parser performs
34 immediate rejection-to-success transitions. Per-call generated entries prove isolation; they do not add
retained-parser transitions. No routes are inferred beyond each backend's explicitly exercised public APIs.

The 37-line/five-rule source uses opening capture state, lexical closing comparison and recursive rule-local
restoration without a new primitive or host parsing escape. Authoring still includes four strictness guard
locations: initial prefix, invalid gaps, final cursor and missing close. Grammar-specific statuses improve
failure classification; expected-name messages, precise error locations, in-document repair and resource
bounds remain unassessed. Names, Unicode text and three nested levels do not establish XML, indentation,
arbitrary-depth behavior or speculative user-variable/AST rollback.

The evidence audit matches all 40 source references (20 distinct files) and 39 retained logs from the six
checkpoint leaves. Rust's observed test allocator collision is repaired and its combined child proof is green;
Dart's shared helper is analyzed in real package context. Known unrelated SDK and malformed-regex owners remain
separate. Ordinary focused proof is retained exactly; milestone landing additionally requires canonical CI on
the exact staged candidate. The promoted receipt and commit body carry its actual result without changing the
candidate after verification. Optional unfiltered backend suites are not inferred from canonical admission.
