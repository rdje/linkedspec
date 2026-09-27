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

Perl native/fresh emitted proof above is supplemented by the all-six public-native result below.
Rust carrier proof is recorded below; `.1.1.3.2.4-.6` own the remaining backend carriers, and `.7` owns canonical evidence/authoring reconciliation. The overall
context objective and structured-format campaign remain open. No comparison or recursive-state primitive is
selected for implementation on the strength of these bounded results.

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

Perl's separate fresh emitted/recovery/mutation proof is unchanged. Dart/Julia/Lua carriers and typed recovery
remain .1.1.3.2.4-.6, followed by canonical reconciliation under .7. No XML or broader format admission follows.

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
checks cover leading trivia and the strict S-expression document. Dart, Julia and both Lua carrier proofs
remain separate leaves; canonical context reconciliation remains .7.
