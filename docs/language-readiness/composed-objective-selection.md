# Bounded composed objective selection

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1`. Reviewed 2026-10-02 from clean
`2a8c368159a6c9b927bc6cd7fc524fe0de7319a6`. This selects requirements and oracles;
it changes no runtime, syntax, authority, admission, fixture or CI registration.
The closure definition is complete; these compositions remain pending execution.

## Retained foundation and eight dimensions

Keep the original nesting, context-name and lossless/actual-child corpora byte-exact.
Their source/checkpoint/log audit is `tests/language-readiness/verify_objectives.py`;
`objective-reconciliation.md` preserves actual carriers and historical recoveries.
Additional source variants are not extra independent formats or fresh reuse proof.

| Parent dimension | Retained or selected evidence | Required observation / boundary |
| --- | --- | --- |
| Natural recursion | Original nested-tree and context-name probes | Exact original positives/negatives and AST/spans; no user-function recursion. |
| Cursor algebra | Original prefix/end guards, capture lifecycle and lossless cases; D/P strict word guards | Unicode-scalar start/end checks; entry selection never matches its own regex. |
| Interval/boundary capture | Original lossless13 cases/39 segments and source-bound child4/15 cases | Preserve original slicing/adjacency/source identities; no expanded staged operands. |
| Nested state | Original context-state restoration; P original/mapped/published roots | Exact nested shapes and post-transformation metadata write; no arbitrary state rollback. |
| Callable composition | P pure registered function invoked by a deferred callback | Explicit arguments, live invocation-time prefix and restored temporary text parameter; no lexical capture. |
| Branching/iteration | D attached stop branch; P finite attached counter loop | Exact selected branch, local callback return and visit count. Mixed marker/attached value contexts remain unassessed/owned. |
| Structural transformation | P original-shape harray traversal followed by nested write | ASCII-key order, detached mapped result, unchanged original and later publication. No unrestricted mixed-tree traversal. |
| Typed result construction | D effects/word/boolean payload; P nested harray/string/number fields | Boolean false differs from numeric0/string; aggregate roots remain distinct. No new reducer/constructor generalization. |

## D: strict word diagnostics and caller-owned delivery

Recognize one ASCII lowercase word. Explicit source-start/end guards and a fallback
exit reject prefixes, suffixes and empty input. Immediate value blocks append
`left`, then `right`, before one grouped `print` event. `print_each` walks authored
fragments `["α", undef, [], "🙂"]`; null and array fragments are diagnostic-empty.
`say` supplies exactly one newline. The ordinary result is
`{ "word": word, "effects": ["left","right"], "payload": false }`.

For `go`, the ordered event triples are:

```json
[
  {"helper_name":"print","rule_label":"Top","message":"begin:go"},
  {"helper_name":"print_each","rule_label":"Top","message":"part:α!"},
  {"helper_name":"print_each","rule_label":"Top","message":"part:!"},
  {"helper_name":"print_each","rule_label":"Top","message":"part:!"},
  {"helper_name":"print_each","rule_label":"Top","message":"part:🙂!"},
  {"helper_name":"say","rule_label":"Top","message":"done\n"}
]
```

| Case | Independent oracle |
| --- | --- |
| `D_ordered_go` | Input `go`; exact value/kinds and six event triples above. |
| `D_ordered_wait` | Input `wait`; only word and first message change. |
| `D_quiet_go` | No caller sink; same value/effects, zero rich events and host diagnostic output. |
| `D_exit_stop` | Input `stop`; `begin:stop`, then `stop\n`; typed exit7; no later item/action or returned value. |
| `D_sink_failure_after2` | Caller throws its unique error on delivery2; retain those two observed events, identical caller error and no later delivery/value. This tests sink authority, not a grammar callback. |
| `D_prefix_bad` | Input `!go`; authored exit1 before effects/events. |
| `D_suffix_bad` | Input `go!`; authored exit1 before effects/events. |
| `D_empty` | Empty input; authored fallback exit1 and zero events. |
| `D_bad_arity` | Isolated Word-action variant has no preceding output: `print_each` receives four arguments containing nested diagnostic effects. Helper-arity rejection precedes all argument effects/delivery. Keep each producer's compile/runtime projection rather than inventing one global error wrapper. |

Portable observations separate parse value, matching/rejection, typed exit/helper
failure, caller error identity, rich events and native trace. A text adapter cannot
replace a typed producer or prove error-object identity. Quiet execution still
evaluates valid arguments. These are authored diagnostics and controlled stops,
not expected-token construction, general in-document recovery or richer errors.

## P: parsed pair normalization through functions, callbacks and mutation

Recognize exactly two ASCII alphabetic words separated by `-`, using the outgoing
match's text and explicit prefix/end/fallback guards. Split that text into two
strings, then construct `{ "a": first, "b": { "c": second } }` as `original` and
copy it into `tree`. Construct the deferred text callback while prefix is `old:`,
then change prefix to `new:`. Each callback appends its leaf to `seen` and calls
pure `decorate(text,prefix)`, which returns prefix plus ASCII-uppercase text.

Map harray leaves in paths `["a"]`, `["b","c"]`; preserve a detached `mapped`
result. A finite attached loop counts the two pieces, then
`tree["meta"]["count"] = visited` publishes a nested write after transformation.
The temporary callback parameter `text` must restore caller value `outside`.
For `ab-cd`, the independent expected value after required repair is:

```json
{
  "tree":{"a":"new:AB","b":{"c":"new:CD"},"meta":{"count":2}},
  "mapped":{"a":"new:AB","b":{"c":"new:CD"}},
  "original":{"a":"ab","b":{"c":"cd"}},
  "seen":["ab","cd"],"text":"outside","visits":2
}
```

With a sink, expect `print_each/Top/leaf:ab!`, then `leaf:cd!`, then
`say/Top/done:2\n`; no sink preserves the value/effects with zero delivery.
The oracle uses ordinary ASCII splitting/uppercase and explicit shape construction,
not the DSL parser, codeblock evaluator or runtime-derived expected data.

| Case | Independent oracle |
| --- | --- |
| `P_ab_cd` | Exact value/kinds and three ordered events above. |
| `P_mixed_case` | Input `AB-cd`; original/seen retain spelling, normalized output remains `new:AB` / `new:CD`. |
| `P_short` | Input `x-y`; normalized leaves `new:X` / `new:Y`, count2 and restored text. |
| `P_quiet` | Input `ab-cd`, no sink; same output/effects with zero rich events. |
| `P_prefix_bad` | Input `!ab-cd`; authored exit1 before callback/write/output. |
| `P_suffix_bad` | Input `ab-cd!`; authored exit1 before callback/write/output. |
| `P_empty` | Empty input; fallback exit1 and no work/delivery. |

After a successful typed invocation, mutate the actual returned `tree` object:
`mapped` and `original` must remain unchanged. A deliberately aliased observation
must falsify this assertion. JSON re-decoding or mutating a consumer-made copy is
not an actual-object alias proof. Aggregate callback-parameter copy, receiver-failure
state snapshots, arbitrary controls and mixed-root traversal are outside this new
case; their existing authorities/proofs and partial repairs remain separate.

## Mutations and evidence admission

`.1.3.2` freezes these sixteen cases, source identities and independent expectations
before runtime lanes. D mutations must distinguish operand/effect order, omitted
effects, item order, output leaking into results, boolean-as-number corruption,
work after exit, swallowed/wrapped caller failure and effects before arity rejection.
P mutations must distinguish frozen old prefix, skipped pure computation, lost
parameter restoration, receiver/result aliasing, original-copy aliasing, reversed
visits, wrong loop count and missing post-map metadata publication.

Neutral structural mutations prove schema/oracle/source integrity. Runtime lanes
execute controlled grammar/observation variants and require the intended oracle
failure after the healthy baseline passes. A preexisting `unknown_helper`, unrelated
compile error or rejected source hash cannot count as semantic execution proof.
Loops remain finite in mutants; there is no test requiring unbounded execution or
claiming regex preemption. Record actual carriers, recovery and alias controls.

Planned producers are public Perl Get/independently loaded emitted source, supported
Rust and Dart native/reconstructed/generated/emitted routes, and Julia/PUC Lua/
LuaJIT native and emitted routes. Each lane declares its actual routes/counts before
execution; no equivalence or extra reuse total is inferred. Caller code only supplies
input, options and observation sinks. Grammar, computation and mutation stay authored.

## Current feasibility and mandatory repair ownership

Perl pilots freshly establish D `go`, quiet execution, identical sink failure on delivery2,
`stop`, invalid prefix and empty input; broader
D cases and all other backend executions remain pending. Seven isolated callable
controls establish five successes and two failures: direct `push`, direct registered
function, ordinary callback `cat`/assignment, direct uppercase and uppercase function
work, while callback `push` and callback registered-function invocation fail with
typed `unknown_helper`. All seven descriptors report ready1/raw0/fallback0/unresolved0.
The P prototype therefore remains blocked, not a successful objective.

`CodeblockRuntime::_eval_call` has a small literal helper list and bound-codeblock
lookup, without the selected mutation/function routes. New
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0` (P1) owns repair before Perl execution;
`.1.3.3.1` then executes the unchanged neutral selection. Existing startup87.2/.3
retain regex/numeric dispatcher repairs and their separate acceptance/prerequisites.
No missing parsing primitive or syntax extension follows from this execution gap.

Preserve all owners in `finite-gap-list.md` and the closure authority: host slots,
receiver identity/substitution, recognition booleans/abort, deferred boolean literals,
numeric constructors/reducers, Dart mixed controls/Unicode order, backend detachment,
registry/provenance/cycles and resource/source-detail repairs. Selected positive
cases cannot close these exceptions. New push dispatch must preserve real binding
identity/guards and once-only arguments; registered functions must keep fresh locals,
static precedence, recursion diagnostics and explicit caller context without capture.

Indentation width/tabs/dedent policy, quoted-string escaping, comments in versus
outside strings, realistic whole formats, richer diagnostics/recovery, general
resources/performance and supplementary-character key ordering remain unassessed by
D/P. `.1.4` records requirements and evidence-backed gaps; later format catalog/trials
provide complete-language requirements. Named arguments remain parked under
`PARSER-AUTHORING-APIS.4`. No ambient filesystem/process/network/clock/RNG authority,
new global limit, sandbox guarantee or optional frontend is selected.

## Explicit source correction after diagnosis

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0` establishes that the initial pipeline
uses unsupported infix condition/increments; direct `count` and admitted call loops
work. `.0.4.1` selects `normalization-calls.spec` with only that loop changed to
`num_lt`/`num_add`. The original source and immutable selection checkpoint remain
exact. Explicit correction provenance binds both source identities; all sixteen case
oracles, dimensions, mutation roles and foundation inputs retain their meanings.
Seven P cases now pass native/fresh Perl value/event/exit/quiet/actual-object controls;
full D/P semantic mutation execution and other backends remain separately owned.
