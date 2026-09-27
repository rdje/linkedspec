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

Only Perl native/fresh emitted execution is established here. `.1.1.3.2.2` owns all six public native adapters;
`.3-.6` own the other backend carriers, and `.7` owns canonical evidence/authoring reconciliation. The overall
context objective and structured-format campaign remain open. No comparison or recursive-state primitive is
selected for implementation on the strength of this single backend result.
