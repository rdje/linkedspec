# Backend Handoff

> **Accepted cursor/generated migration:** ADR `0044` requires every backend to
> derive cursor policy from authored family, preserve child ownership, remove
> public/global overrides with portable diagnostics, project per-rule
> `cursor_policy`, and emit/consume `linkedspec-generated-source-v2`. Version-2
> plan rows retain `{label, family}` and derive policy from family. Perl is
> admitted across the composed contract, as are Rust and Dart through their own
> topology-checked consumers. Julia is fully admitted with typed normalization,
> intrinsic execution, cursor descriptor v1, generated-source v2, and no public
> override. Lua now has typed normalization, intrinsic normal live/loaded/
> normalized/recursive/traced execution, cursor descriptor v1 with exact
> direct/normalized/loaded byte identity, and generated-source v2 with exact
> five-seek/five-consume derivation on both ABIs. Global-option removal is now
> complete too: high-level legacy keys fail with the portable removal diagnostic,
> and primary help/request trace no longer expose the retired flag. One exact
> 15-role consumer now admits the complete projection on both Lua ABIs;
> v1 generated artifacts must be regenerated.

This chapter is the **single entry point** for anyone building a LinkedSpec backend
in a new language (Rust, Dart, Julia, Lua, etc.). It links every specification, contract,
and test artifact you need — in reading order.

## What You're Building

A LinkedSpec backend compiles `.spec` grammar files into runnable parsers. It must:

1. Expose an idiomatic native library, module, package, or crate that applications can
   call in the host process.
2. Accept `.spec` source and parser input as in-memory host-language values, then return
   structured host-language results without requiring a CLI, subprocess, temporary file,
   or serialized inter-process handoff.
3. Parse `.spec` files according to the formal grammar.
4. Parse helper/action language text into typed AST/IR nodes before lowering,
   interpretation, or code emission.
5. Preserve staged linked parsing semantics: extracted text payloads can become
   source-provenance parse jobs routed to later `.spec` parsers.
6. Compile the parsed model into runtime handlers or an equivalent executable compiled
   model through the accepted backend-neutral seams.
7. Execute with identical semantics to the Perl reference.
8. Pass direct library-level tests plus the language-neutral test corpus.

Native in-memory embedding is the primary completion gate (ADR 0022). A backend CLI is a
secondary thin adapter over the same parser/compiler/runtime library and may not own
exclusive `.spec` or runtime semantics. Named/file-oriented convenience APIs are welcome,
but they cannot be the only complete data path. Interpreter versus generated-source
execution remains a backend choice and does not change this embedding requirement.
Distinct backend executable names must nevertheless expose one identical user-facing CLI
contract under ADR 0023: the same command structure, option names and meanings, positional
arguments, outputs/errors, and exit semantics.

### Exact Cross-Backend CLI Contract

The executable token identifies the backend. It is the only intended user-interface difference.
Host-language launch syntax may also differ in a source checkout, but the argument vector after
the executable is identical:

```text
<variant-command> --spec NAME --input TEXT [options]
<variant-command> --spec-file PATH --input-file PATH [options]
<variant-command> --inline-spec TEXT --input TEXT [options]
```

Source selection requires exactly one of `--spec`, `--spec-file`, or `--inline-spec`. Input
selection requires exactly one of `--input` or `--input-file`. Every primary command exposes
the same optional controls:

- `--top-rule NAME`
- `--trace LEVEL`
- `--trace-file PATH`
- `--trace-mode stdout|route|mirror`
- `--trace-reset`
- `--trace-emoji`
- `--help` / `-h`

The retired `--parse-mode` flag is recognized only as a usage error: exit `2`
with `--parse-mode has been removed; cursor policy is derived from each rule
(OR/default=seek, AND=consume)`. Perl, Rust, Dart, and Julia project those
shared fixture bytes. Lua ordinary runtime execution is already intrinsic, but
its CLI/help/request-trace removal remains `.9.1.7.5`.

There are no primary-CLI subcommands and no positional arguments. Corpus runners and backend
status probes are separate developer commands. Trace levels accept numeric values plus the
shared names/aliases `none`/`quiet`, `low`, `medium`/`med`, `high`, `full`, and
`debug`/`verbose`.

Help and successful parsing exit `0`; normalized spec/input/runtime failure exits `1`; usage
failure exits `2`. Successful parsing writes one canonical JSON value plus one newline to
stdout. CLI-controlled stdout, stderr, diagnostic structure, and trace routing are locked by
the same language-neutral fixtures for every backend.

Without an explicit CLI trace option, operational failures have empty stdout and exactly one
of these stderr records, each ending in one newline:

```text
linkedspec: parser compilation failed
linkedspec: input load failed
linkedspec: parser invocation failed
```

Each exits `1`. Compilation and source loading happen before deferred input-file loading, so
an invalid spec wins over a simultaneously missing input. Backend owner names, host paths,
OS error wording, exception source locations, and ambient backend-specific trace environment
variables are not part of the shared primary-command output.

ADR `0024` separates portable primary trace from rich native trace. Primary records
are deterministic UTF-8 lines shaped as `[linkedspec][LEVEL] EVENT`: low records
compile/input/invoke start and outcome, medium adds request controls, high adds byte
counts, full adds JSON byte length, and debug adds protocol version. `none`/`quiet`
are silent. Stdout/route/mirror, selected-file defaults, reset/persistence, emoji,
UTF-8 byte counts, percent-escaped user fields, and traced failures are exact shared
behavior. Native in-memory APIs retain their
backend-internal scope/decision/mark/dump streams.

The Rust rollout audit found that its libraries already owned full-source parsing, validation, compilation,
structured execution, and rich native tracing. `linkedspec-rust` now exists. Direct-result execution and optional
entry selection are library capabilities—not CLI-only mutations—so native callers retain the same observable
operation while cursor policy stays intrinsic to each entered rule:

```rust
use linkedspec_runtime::engine::{Engine, ExecutionOptions};

let options = ExecutionOptions::new().with_entry_rule("Alternate");
let value = engine.execute_value(input, &options)?;
```

`execute_value` returns the selected rule value directly and does not mutate the compiled spec. Its traced variants
accept the same options. The older `Engine::execute` remains compatible with existing Rust callers and returns the
engine accumulator wrapper; primary commands use `execute_value` and never guess by unwrapping arbitrary arrays.

ADR `0025` makes this a strict UTF-8 text command. Argument values, source, input,
canonical JSON, help/errors, and trace are Unicode scalar text encoded once as UTF-8.
Valid text is preserved without normalization, BOM removal, newline conversion, or
trimming. Invalid spec-file bytes produce the stable compilation failure; invalid
input-file bytes produce the stable input-load failure. Invalid-byte OS argv is
outside the portable text interface, and arbitrary binary parsing would require a
future explicit byte-stream contract. Perl implementation is exact through `.1.5.1.6.2`: strict argv/file
decoding, preserved BOM/code points/newlines, recursive canonical JSON, stable invalid-file phases, and exact
trace byte counts pass 61 shared cases. `.6.3` closes final reference no-drift; Rust `.1.5.2.4` combines its
exact boundary, historically reusable entry/mode/direct-result execution, and canonical trace projection to pass all 61
unchanged cases in default/POSIX environments and adds recurring local verification. The Rust primary-command
milestone is closed; Dart and Julia now also pass all 61 default/POSIX cases. `.1.5.4.3` owns recurring warmed
four-command integration and closed the original exact CLI lane; `LUA-BACKEND-PARITY.7.2` has since extended the
same driver to Lua and 5x2x61.

### Call-name coverage versus executable parity

The capability audit now derives the same 246 current ActionIR call names from Dart, Julia, and Lua. Every name
appears in this book and in the governed occurrence sources: the 105-fixture neutral corpus plus the exact
complete-named-mark fixture. The strict checker independently derives 122 public identifier-shaped calls from the
Perl ActionIR contract registry, requires every one in each backend inventory, and rejects nine classified
compatibility/legacy/internal names. This supersedes two historical blind spots: aligned lists first omitted
`mark_capture_slice(...)` and `start_capture_slice_from(...)` at 237 names, then all inventories omitted seven
documented complete-mark helpers at 239 names because the old reverse check began with corpus occurrences.

Vocabulary identity remains necessary but insufficient. A diagnostic 105-case run originally found Rust, Dart,
and Julia at 100/105 despite recognizing the provisional vocabulary. The backend repair leaves aligned exhaustive
pure values, empty-local-match positions, marker control, and anonymous/named capture marks. Final admission now
checks in all six governed sources from `capability_conformance/fixtures/`; Perl regenerates their exact values,
and Perl, Rust, Dart, and Julia all pass the complete 105/105 manifest unchanged. The named marks are rule-local,
host-safe internal offsets project public Unicode-character positions/lengths, and non-repeated `AND` blind-call
wrappers preserve ordered child-return values unless an explicit parent return overrides them.
All three runtimes preserve the crucial distinction between no local match and a present zero-width match at
offset zero.

For example, this portable action-edge grammar deliberately constructs object keys out of
order:

```text
Top::
 /x/ -> Done { return(hash("z", 0, "a", hash("d", 4, "b", 2))) }

Done::
 /x/
```

Given input `x`, every conforming primary command must write these exact bytes, including the
single line ending:

```text
{"a":{"b":2,"d":4},"z":0}
```

The neutral suite also returns an input file ending in `x` plus a newline through
`input_text()`. Its JSON bytes are `"x\n"` followed by the one record newline, which proves
file loading does not trim content and output framing does not add a second newline.

This contract now passes on every implemented executable through the recurring 5x2x61 matrix. The historical
gap census found implicit Perl option aliases and trace leakage, no Rust primary binary, a corpus-oriented Dart
primary, and Julia-local help/error/trace differences; the `.1.5.1` through `.1.5.4` repair lanes closed those
gaps without backend-specific fixture expectations. Julia's repair was split under
`JULIA-BACKEND-PARITY.7.3.2`; `.7.3.2.1` closes compile/parser/
    function-shell/staged trace coverage, `.7.3.2.2` closes exact argument/source/input handling, `.7.3.2.3`
    closes execution/direct canonical JSON, `.7.3.2.4` closes errors/exits/trace routing, and `.7.3.2.5` closes
    nine-family direct-command conformance. `.7.3.3` closes the local audit without claiming global identity.
    Global `.1.5.1.5` closed 53 exact Perl cases: two help, 20 usage, seven success, four operational failure, and
    20 trace families in default/POSIX environments. A signoff probe then exposed UTF-8 argv/JSON mojibake;
    `.1.5.1.6.2` fixes the adapter and adds eight exact Unicode/invalid families, bringing Perl to 61/61. `.6.3`
    closes final reference no-drift; Rust `.1.5.2.4` combines reusable direct-result/entry/mode execution with
canonical trace, passes 61/61 in both environments, and adds `tools/run_rust_local.sh`.
    Dart and Julia close their corresponding focused legs, and `tools/run_primary_cli_matrix.sh` is the global
    recurring identity owner. Complete capability census `.1.6` and generated-source `.3` remain separate.

A separate parked direction, `FUTURE-PARITY-BACKLOG.10.1`, will design deep semantic introspection. The intended
contract is one versioned, deterministic semantic query model exposed idiomatically from every native backend:
rules, edges, calls, regex/lifecycle meaning, source spans and provenance, inferred value/target shapes, helper and
function resolution, generated-source relationships, diagnostics, and explain-why paths. Stable ids and ordering,
bounded query costs, source/privacy controls, and exact cross-backend fixtures are mandatory. MCP is a thin
transport over that model; it must not own semantics or expose backend AST/IR layouts as the public contract.

The backend contract is implementation-language neutral. The same `.spec` source,
AST payloads, parse-job metadata, descriptors, diagnostics, and parser entry semantics
apply whether the implementation is Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a
future language.

The scheduled future full-parity rollout is Dart first, Julia second, and Lua third
(ADR 0021). That order affects task-tree sequencing only; the conformance contract is
the same for every backend. Lua and any later backend must define its native module API
before CLI productization can satisfy its backend plan.

Text-to-AST is a backend conformance rule, not an optional implementation style.
Do not build a backend by applying textual helper rewrites directly into host-language
source. The Perl reference now has an additive `LinkedSpec::ActionIR::AST` parser seam
for calls, literals, variables, direct access, shape literals, block values,
assignments, expression statements, and receiver-dot chains. Its `MethodLowering`
consumer has started using that AST for non-call value expressions: primitive literals,
scoped bare scalar reads, direct indexed/nested access, shape literals, and block
values. It also lowers value-only helper-call composition from AST `call` nodes for
scalar normalization, string predicate/composition, coalesce/concat, and scalar-argument
numeric helpers. It also lowers retained aggregate-constructor, collection/reducer, and hash helper
calls from AST `call` nodes while preserving their existing symbol/value slot policy.
Bare typed reads are the destination surface. Exact one-identifier aggregate selectors are retired and report
`aggregate_selector_removed` on Perl, Rust, Dart, Julia, and Lua before execution.
`tools/check_aggregate_selector_retirement.py` is the canonical cross-variant guard: it requires the shared six
invalid cases, portable fields, all five compiled-state admission boundaries, eight retained constructor/literal
classes, and zero known selector-only runtime dispatch.
Julia's boundary recursively inspects typed rule ActionIR, parses valid deferred function bodies and fluent calls,
and repeats validation for generated emission and plan execution, so unused or caller-constructed state cannot
bypass rejection. Selector-specific Julia runtime dispatch is gone.
Lua likewise inspects typed and valid deferred compiled state, repeats validation when a runtime engine accepts its
mutable compiled table, and has no selector-specific read, target, receiver, split, or transform dispatch.
Retired short aliases `s(...)`/`a(...)`/`h(...)` remain ordinary unresolved helpers rather than normalized.
Unsupported covered helper
forms now report unresolved-helper metadata instead of leaking as generated host-language
calls. Receiver-dot value chains now lower from AST `fluent_chain` nodes for the array,
hash, string, and number receiver families before the legacy receiver-dot text normalizers
run. Generalized return payloads now lower typed value/call/chain nodes through the same
AST traversal before raw fallback, while narrow untyped compatibility payloads still
remain migration debt. Assignment and mutation operator statements now consume typed AST
target/key/value fields before legacy fallback. Helper-call statements and returns now
consume typed AST `call` fields for `set`, `set_key`, `push`, `return`, and
`return_undef`, and array end-mutation receiver statements
consume typed AST `fluent_chain` fields. Expression-valued block side effects,
block-local returns, and final block expressions now consume typed block/statement AST
fields. Structured control-flow lowering now consumes typed AST fields for the if/when,
switch/case/default, and attached-while statement families. Standalone supported value
statements now produce canonical `VALUE_DROP` events: the backend computes the typed
value expression and intentionally discards the result. Unknown typed calls and
function-call receiver chains in return/value positions now use the unresolved-helper
diagnostic path instead of becoming generated host-language calls.
Top-level `fn name(args) { body }` definitions are now accepted and recorded in the Perl
reference descriptor registry. Each definition carries params, arity, source/body spans,
body source, and an ActionIR body AST. The registry rejects duplicate functions,
reserved names, built-in helper/control collisions, rule-label collisions, and invalid
or duplicate parameters before runtime. The Perl reference now resolves registered
exact-arity calls during value-expression lowering; wrong-arity registered calls remain
unresolved-helper diagnostics with zero raw fallback. Registered standalone calls and
receiver chains now lower as canonical `VALUE_DROP` statements on the Perl reference.
The Rust backend carries the same definitions through parsed and compiled registry
records and executes the MVP runtime surface: registered calls resolve before helper
fallback, run in fresh function-local stores, feed compatible receiver chains, and
discard standalone results.
The function surface is closed at that MVP boundary. New backends should implement
top-level `fn name(args) { ... }` with explicit parentheses and braced, value-oriented
bodies. Do not add alternate spellings (`function ... endfunction`, `fn ... endfn`),
optional zero-argument parentheses, brace-less bodies, caller-state-mutating functions,
recursive user functions, closures/lambdas/currying, or function namespaces unless a
future task-tree leaf and contract explicitly adopt them.

Staged linked parsing is also a backend conformance rule. A backend must be able to
represent an AST node that contains extracted text and a parse intent, then dispatch that
payload to a deterministic next parser while preserving source spans and parent-node
context. One stage can emit several different parse-job kinds; each kind may route to a
different next-stage `.spec`. This is different from spec imports: imports compose grammar
files, while staged dispatch parses runtime payload text already extracted by a parser.
For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar and
later `.spec` stages derive from its parsed payloads rather than a competing permanent
bootstrap grammar.

The accepted parse-job annotation design is `parse_job(text_expr, options)` once
implemented. It yields a marker value plus sidecar metadata: deterministic job id, parent
AST path, node kind, payload kind, exact text, source span, parser spec id, optional top
rule, result policy, and failure policy. Result policies are `replace_marker`,
`replace_field`, `sibling_field`, and `append_child`; failure policies are `fail`,
`keep_text`, and `diagnostic_node`. Backends must treat this as a neutral metadata
contract, not a host-language callback surface. Current shipped parsers do not yet accept
or execute `parse_job(...)`.

The accepted staged dispatch design is also neutral. Implement a registry with
`resolve`, `load`, `compile`, and `execute` operations. Resolution order is parent
import aliases/composed identities, declaring-spec-relative paths, configured search
roots, then explicit registry providers. Cache compiled parsers by normalized spec
identity, content digest, import/include graph fingerprint, selected top rule, `.spec`
language version, helper/action contract version, staged parsing contract version, and
backend capability set. Dispatch jobs in stable parent-AST-path/source-span/job-id order,
and diagnose active-chain cycles that repeat spec identity, top rule, payload digest, and
source span. Current shipped parsers implement only the first narrow function-body
provider; general staged registry/provider search and recursive dispatch queues remain
future work.

The first prototype target is user-function body payloads. A backend should treat that
as a narrow proof of the neutral staged contract: `specs/spec.spec` extracts a bounded
body payload, a parse job names the next parser/top rule, source provenance is preserved,
and the refined body AST is stitched back deterministically. Do not copy a Perl or Rust
bridge as the semantic model; host implementation details are adapters around the
`.spec`/AST contract.

The proof must include an AST-shape oracle for the returned function-definition node.
Runtime equality alone is not enough: a backend must be able to predict and then assert
the `function_definition` AST shape, including the refined body payload and provenance
fields that staged dispatch is responsible for. That oracle should be fed by a large
variation suite for the spec rule returning the AST: whitespace forms, arity forms,
nested blocks, quoted strings, regex-looking payloads, adjacency to rules or other
definitions, and invalid definitions with expected diagnostics. Use a dedicated small
spec file/top rule for those focused AST-shape tests when that gives a tighter harness.

For backend implementers, the expected harness is a wrapper top rule that dispatches to
a normal `function_definition` rule and returns collected nodes. The function rule must
not rely on compacted numbered captures for optional fields. The neutral returned node
uses parsed parameter arrays, exact inner body text, neutral source/body spans, a
function-body parse-job field, and a stitched body AST after dispatch.

The current provenance seam is the neutral `body_payload` plus `body_parse_job` returned
by `specs/user_function_definition.spec`. Neither field is a backend callback.
`body_payload` contains exact function-body text,
half-open source span, source-slice provenance, source-order parent path, function name,
params, arity, `node_kind = function_definition`, and `payload_kind = function_body`.
`body_parse_job` is the parse-intent sidecar for that payload: deterministic job id,
parent AST path, parser spec identity, top rule, result/failure policies, exact text,
source span, and diagnostic ownership. The Perl reference plus Rust, Dart, Julia, and Lua runtimes consume
that spec-returned AST today and normalize the source-order path/job id once the function
ordinal is known. They dispatch that job through the minimal staged parser registry:
`resolve` maps `actionir-body.spec` to a built-in provider identity, `load` records the
adapter contract digest, `compile` selects top rule `action_block`, and `execute` returns
the body `action_block` AST stitched into `body_ast`. General provider search roots,
imports, and recursive staged queues remain future work. The spec's body shell is a
linked opener/closer parse: `body_brace`
handles nested brace islands, quoted strings, comments, and regex literals are protected
before brace dispatch, and the outer close is matched by `function_definition[1]`.
Backends must converge on this same spec-defined AST contract instead of maintaining
host-language definition grammars as the staged dispatch queue becomes portable.

Lua's `.5.1.1` implementation lives in `lua/src/linkedspec/staged_parser_registry.lua`.
It defensively copies exact typed jobs, decorates equal sort keys with input order to make
Lua sorting stable, exposes the governed digest/cache/compiled/result records, rejects
unsupported providers and sidecar/duplicate-job drift, and rebuilds immutable function/spec
records during stitching. `parse_spec_with_staged_user_function_definition_asts(...)`
composes an explicit node batch and dispatch directly. `.5.2.2` adds
`parse_spec_with_staged_user_function_definitions(source)`, which resolves and compiles the bundled owning grammar
once and supplies that node batch automatically without a raw scanner. `.5.1.2` adds registry-first fixed-v1
execution: eager ordered caller arguments, copied fresh scalar/array/harray stores,
staged-AST integrity checks, local final/early returns, nested nonrecursive calls,
standalone value drop, returned-value receiver continuation, cleanup-safe caller
restoration, and typed arity/keyword/recursion/staging failures. `.5.1.3.1` then preserves the exact v1/v2
signature union through every native state boundary, validates sidecar identity and all seven invalid definitions,
and resolves variadic calls from the fixed-prefix minimum through an unbounded maximum. `.5.1.3.2` then copies all
evaluated frame arguments and binds extras as a fresh typed rest array; the unchanged neutral fixture, mixed/empty
identity, receiver chains, and typed failures pass. `.5.1.4.1` then preserves final-only `callback: codeblock`
metadata across every native state boundary and normalizes attached/parenthesized calls to one zero-positional
typed argument without promoting harrays. `.5.1.4.2` executes that argument against the current isolated function
frame, preserves static callable precedence, restores outer stores, returns chainable values, and reports typed
callback failures. Portable native resolution/loading `.5.2.1` then adds typed requests/options/results/errors,
deterministic direct candidate order, in-process byte reads, and strict UTF-8 preservation. PUC Lua and LuaJIT
consume the complete 14/9/4 contract. Automatic spec-defined function parsing `.5.2.2` resolves the bundled
grammar module-relatively, validates/compiles it once, executes it in process, and composes typed nodes through the
existing Unicode projector/body dispatcher without a raw scanner. Both ABIs pass 151/151 with status
`native-spec-defined-functions-v1`. Loaded-source `.5.2.3` retains exact identity/source/compiled state, maps the
three neutral source stages, and creates named/path-attributed engines at 153/153 with status
`native-spec-pipeline-v1`; no-drift `.5.2.4` closes parent `.5.2`. Planning `.5.3.0` separates exact outward
descriptor admission, one-emitter native-pipeline trace, and capability closeout. Decision `.5.3.0.1` adopts
final-codeblock descriptor v3 plus completion-time census admission; `.5.3.1` emits the exact three-variant union.
`.5.3.2` passes one caller-owned emitter across native IO, frontend/compiler/function/staged owners, engine
creation, and runtime without retained or hidden emitter state. Ordered sinks/filters/errors and result identity
pass 155/155 on both ABIs with status `native-full-pipeline-trace-v1`; `.5.3.3` closes exact no-drift and parents
`.5.3`/`.5`. Controlled/core planning `.6.1.0` measured offsets 0-39 and 99-104 at 45/46 on both ABIs. Typed
nested-path repair `.6.1.1` closes unchanged offset 20 and both windows at 46/46 with focused suites at 157/157.
Reusable executor `.6.1.2` validates before selection and retains every controlled result/failure at 160/160 per
ABI. Permanent core window `.6.1.3` then locks exact offsets 0-39 at 40/40 with endpoint 1/1 and raises both suites
to 161/161. Governed `.6.1.4` locks offsets 99-104 at 6/6 with endpoints `2,1,2,1,5,5`, raises both suites to
162/162, closes `.6.1`, and activates offsets 40-98 under `.6.2`. Planning `.6.2.0` measures that window at 50/59.
Action-edge `.6.2.1` then caches matching current-edge calls, skips passive-terminal re-search after the parent
dependency match, and preserves ordinary unrelated rule calls. Three HLink, two EBNF, and SimEnv cases pass
unchanged; both suites pass 163/163 and the window reaches 56/59. Receiver-copy `.6.2.2` then carries the one
evaluated fluent value through zero-argument `.copy()`, retains its runtime kind for later links, and closes the
hash-receiver fixture. Both suites pass 164/164 and the window reaches 57/59; flat-array hash splicing `.6.2.3` is
now complete. Direct and receiver `flat_array(...)` results splice ordered alternating tokens into `hash(...)` and
`harray(...)`, empty input yields an empty harray, and ordinary arrays remain one copied value. The unchanged
`pplugin_empty` returns `[{}]`; both ABIs reach 58/59. Public leading-trivia `.6.2.4` then moves cursor/register
state past only complete leading blank or `#` comment lines, preserves ordinary indexed reads, and closes unchanged
history. Both ABIs pass 165/165 and the window reaches 59/59. Successor remeasurement `.6.2.5` independently
validates all 105 fixtures, selects exact offsets 40-98, and confirms stable first/last order plus 59 passes and
zero failures on both ABIs. Permanent `.6.2.6` locks all 59 literal names, unchanged wrapped outputs, matches, and
exact byte/character endpoints at 166/166 per ABI. Final `.6.3` executes the complete ordered 105-case manifest
through both the production library and separate developer runner, preserves validation-only default use, and
locks success/fixture/manifest exits 0/1/2. Both ABI suites pass 167/167 with status `runtime-corpus-full`; parent
`.6` closes. Primary parser adapter `.7.1` now implements exact ADR `0023` options, strict UTF-8, native execution,
canonical JSON, stable phases/exits, and the independent canonical phase trace at 169/169 per ABI plus diagnostic
shared CLI 61x2. Admission `.7.2` now makes both process legs recurring and extends the matrix to 5x2x61. Status is
`runtime-corpus-primary-cli`; no-drift `.7.3` closes parent `.7`. Planning `.8.1.0` corrects the pre-descriptor-v3
scaffold scope, and `.8.1.1` now emits deterministic native Lua from exact fixed-v1/variadic-v2/
final-codeblock-v3 effective state. It exposes contract/version/identity metadata, portable errors, and direct/
traced value roles with canonical strict-UTF-8 JSON rendered as ASCII hex. `.8.1.2` now persists valid/corrupt
modules and proves exact fresh-process PUC Lua/LuaJIT load, result, trace, failure, and cleanup behavior;
`.8.2` adds exact ten-family plans, four rejections, authoritative root/nested dispatch, portable generated trace,
one isolated all-family module, and emitted variadic execution at 176/176 per ABI. Contract-sourced `.8.3` proves
the exact ordered interpreter-first 8/105 modules with metadata/plans/trace identity and cleanup in fresh PUC Lua
and LuaJIT hosts at 177/177 per ABI. Sole admission `.8.4` now expands the census to five-backend 80/0/0.

Rust is interpreted rather than generated Perl source, so the inspectable artifact is
the compiled rule table plus lifecycle/action expression AST rather than emitted handler
code. The Rust adapter still follows the same contract: it executes
`specs/user_function_definition.spec`, validates the returned nodes, strips definition
spans, dispatches normalized body parse jobs through the staged registry adapter, and
only then passes rule-only source to the core parser.

Spec import/composition is a separate backend conformance target once implemented. The
accepted design uses file-scope `import "path.spec" as alias` and
`include "path.spec"` directives. `import` creates a qualified namespace such as
`alias.Rule`; `include` performs a structured merge into the current unqualified
namespace. Implement this as parsed `.spec` composition, not raw text concatenation.
Backends must agree on resolution order, normalized spec identities, duplicate-name
diagnostics, import-cycle diagnostics, source provenance, and descriptor fingerprints.
Current shipped parsers do not yet accept these directives, so do not treat them as a
runtime requirement until the implementation leaf lands.

The remaining fallback boundary is not a backend pattern to copy. Malformed helper forms
already covered by the typed AST path report unresolved-helper metadata rather than host
calls. Retired helpers, non-DSL host-shaped statements, and a few narrow return payload
compatibility shapes remain fenced migration debt. Unknown typed calls and receiver
chains are reserved for user-defined function resolution and diagnostics, not broad
host-language fallback. In the Perl reference, return/value-position unknown calls
currently diagnose. Standalone registered calls/chains lower as `VALUE_DROP`, while
unregistered call-shaped statements remain raw compatibility debt. New backends should
follow the typed-AST model used by the Rust implementation from the start, including a
validated function registry before runtime resolution.

You do **not** need to read the Perl source code. Every behavioral contract is
specified in the documents below.

## Reading Order

### Step 1: Understand the Big Picture
Read the [ADR 0006](../../../docs/decisions/0006-multi-backend-vision.md) — the multi-backend
decision record. It defines the lockstep contract: same `.spec` files, same semantics,
same test corpus across all backends. Then read
[ADR 0022](../../../docs/decisions/0022-native-in-memory-backend-embedding.md), which makes
native host-process parse/compile/execute APIs primary and CLIs secondary adapters.

### Step 2: Learn the `.spec` Language
Read the [Formal `.spec` Grammar](formal-grammar.md). This is the definitive syntax
reference. A valid backend must accept exactly this language. No Perl bootstrap parser
knowledge is needed.

### Step 3: Understand Runtime Behavior
Read the [Runtime Semantics](runtime-semantics.md). This defines how `.spec` rules
execute: parse modes, lifecycles, explicit cursor controls, accumulators, edge dispatch, repetition
bounds, and determinism guarantees. Two independent implementations of this document
must produce identical parser behavior.

### Step 4: Implement the Helper Surface
Read the [Helper Contract Catalog](helper-contract-catalog.md). Every helper function
(100+ across 10 families) is documented with its signature, type contract, behavioral
semantics, and edge cases. Implement these helpers in your target language — they
are the building blocks users write in `.spec` lifecycle blocks.

### Step 5: Implement HandlerIR
Read the [HandlerIR Specification](../../../docs/knowledge/handler-ir-design.md). The
HandlerIR is the structured AST between the compiler and code generation. Your backend
writes an **emitter** that consumes HandlerIR nodes and produces runnable code in
your language. The JSON diagnostic backend (`_emit_handler_json`) proves the pattern.

The Rust backend currently executes an interpreted structural model
(`CompiledSpec`/`CompiledRule`) rather than direct generated Rust handlers. Its
generated-source path is tracked separately under `RUST-PARITY.8`: `.8.1`
split the work, `.8.2` added the minimal scaffold/compile-run proof, and
`.8.3.1` added a generated rule-family plan. `.8.3.2` made default/OR acode
families run directly, `.8.3.3` made AND single/sequential acode families run
directly while enforcing ordered non-repetition AND regex/acode sequence
semantics, and `.8.3.4` made AND/OR bcode families run directly with shared
blind-edge tail execution. `.8.3.5` closed the non-repetition matrix by making
generated-plan routing exhaustive for all six non-REP generated families and by
asserting that family coverage in the source-emitter matrix. `.8.4` added direct
generated execution for the four explicit REP subfamilies (`RepAcode`,
`RepBcode`, `RepAndAcode`, and `RepAndBcode`), including bounded repetition,
zero-progress termination, and same-position recursive-call guard coverage.
`.8.5` integrated the generated-source proof with the oracle corpus: the
source-emitter test still compiles and runs an all-family generated matrix, and
it now also compiles/runs a curated subset selected from the checked-in
`rust/linkedspec-runtime/tests/corpus/manifest.json`. That generated-source corpus subset includes
authored proof fixtures, terse helper/control/user-function fixtures, and
shipped `tclite`/`portmap` smokes. This is deliberately a subset proof; the
full 105-fixture corpus remains the Rust interpreter oracle gate unless a later
leaf explicitly broadens generated-source corpus coverage.
`RUST-PARITY.9` closed the Rust follow-on documentation state around that
boundary: interpreter parity is the 105-fixture corpus contract, while generated
source currently proves direct structural-family execution plus the curated
manifest subset.

The completed scoped Dart milestone follows the same parity ordering. `DART-BACKEND-PARITY`
landed interpreter-first: `.spec` parser, typed helper/action AST, compiled-spec
state, Dart runtime interpreter, then the manifest-backed corpus runner.
Generated Dart source was originally deferred until after interpreter/corpus parity. The split future lane is now
active: `.3.3.1` landed deterministic v1 emission/isolation and `.3.3.2` landed exact ten-family plan/direct
execution, four rejection codes, and portable trace roles. `.3.3.3` now admits the contract-sourced eight-case
interpreter-first host proof. The repo has a Dart backend package under
`dart/`, including package metadata, committed lockfile, public library entrypoint,
Dart-specific CLI entrypoint, compatibility corpus-runner entrypoint, and smoke tests. Its corpus layer loads the
manifest-backed corpus, rejects manifest drift, checks required fixture files and
expected JSON syntax, and the Dart library exposes `executeCorpusFixtures(...)`
for controlled manifest fixtures. That executable harness runs fixtures through
the Dart parser, compiler, and runtime engine, then compares engine output to the
backend-neutral expected value wrapped one level with structural JSON equality.
It supports named and bounded fixture selection through the library and opt-in
CLI `--execute` mode; without a selector, the corpus runner executes the full manifest in
order. `bin/corpus_runner.dart` is now the sole corpus-focused command; the primary
`bin/linkedspec_dart.dart` rejects corpus subcommands/options and follows the shared parser interface.
The checked-in 105-fixture manifest passes through Dart execute mode,
covering the starter proof-edge, autoexist, mutation, core terse runtime,
middle helper/control/receiver, shipped-spec/parser-smoke, and top-level
function groups. The top-level `fn` corpus fixtures route through the spec-defined function shell: Dart obtains
spec-produced `function_definition` nodes, feeds them through staged body
projection, and does not raw-scan `fn` source in the corpus runner. The final shipped-spec/parser-smoke window started
at 2/31 green, reached 7/31 green after the regex-dialect, helper/action, and
recursive/default-mode bridges, reached 13/31 green after the portmap result-shape bridge, reached 19/31 green
after the hlink delimiter/capture bridge, reached 22/31 green after the helper mutation/text-normalization bridge,
reached 24/31 green after the legacy accumulator, public-parser leading-trivia, and final no-drift closeout
leaves, and is now 31/31 green after the structural regex closeout. The parser-smoke group is closed. The
portmap/action-edge result-shape leaf is
done: Dart `array(...)` splices explicit `flat*` arguments, all five portmap fixtures pass, and `vhdl_library_use`
also passes. The hlink leaf is also done: Dart `call(...)` refreshes `retv`, append-style mutations update
scalar-held lists, all five hlink fixtures pass, and `tablegrep_simple_term` also passes. The helper mutation leaf
is also done: statement-form `substr(...)` / `regex_subst(...)`, explicit split replacement, and entry/local line
helpers make `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass. The basic
legacy accumulator leaf is also done: Dart `push(Child)` now appends child returns to the current rule accumulator,
so `regdef_nested_register_fields` passes. The `ds_vhistory` public-parser bridge is done too: Dart now mirrors
Perl's leading blank/comment-line skip before the top rule, so `ds_vhistory_version_entry` passes without
weakening ordinary scalar-held indexed reads. The regex-dialect
bridge is now in place for POSIX classes, inline/scoped flags, possessive
markers, lower-bound quantifiers, and Python-style named captures. Scoped flag
groups are accepted by lifting their options to the Dart `RegExp`. The missing
helper/action bridge is also in place for direct capture-slice helpers,
diagnostic output helpers, logical helpers, `exit_now`, and quoted helper-call
delimiter parsing. The recursive/default-mode bridge is in place too: compiled
action edges carry resolved regex-dispatch metadata, edge-only child regexes are
folded into the parent alternation, and explicit aggregate resets are scoped to
the current rule invocation. The structural regex leaf is now closed too:
bounded Dart matchers handle the exact shipped Lispish `(?R)`, EBNF `\K` /
`(?&name)` / `(?(DEFINE)...)`, and spec.spec recursive block forms. Fixed `blkFN` and variadic `blkVFN`
function-definition capture shapes are both preserved; this is a bounded shipped-pattern bridge, not a claim of
general recursive-PCRE support. Action-edge `push(child, index)` preserves indexed child payloads. The Dart-specific
corpus CLI implementation is done, and `DART-BACKEND-PARITY.7.5` closed the scoped
interpreter-first milestone. A later strict-interface audit has shown that this
corpus-oriented command is not yet equivalent to the Perl parser CLI; it is not the
final cross-variant user CLI contract.
`FUTURE-PARITY-BACKLOG.1.2` creates the dedicated `JULIA-BACKEND-PARITY`
plan. `JULIA-BACKEND-PARITY.1.1` has completed Julia toolchain/package-layout preflight, `.1.2` has created the
minimal Julia package scaffold, `.1.3` has added manifest-backed corpus IO and drift detection, `.2.1` has
added source AST/data types with neutral JSON projection, `.2.2` has added the source parser, `.2.3` has added
frontend validation and strict syntax behavior, `.2.4` has added spec-shaped top-level `fn` shell projection, and
`.3.1` has added typed helper/action AST parsing, `.3.2` has added ActionIR contract resolution, `.3.3` has added
the user-function registry seam, `.3.4` has added compiled-spec state, and `.4.1` has added runtime regex matching
and match-state tracking. `.4.2` has added first compiled-rule dispatch, and `.4.3.0` has split helper/value work by
runtime mechanism. `.4.3.1` has added core scalar/array/hash stores, typed snapshots, assignments/access, checked
nested writes, and capture maps/positions. `.4.3.2` has added string/scalar and numeric helpers, regex flags,
aliases/symbol callees, invalid-input boundaries, and compatible receiver chains. `.4.3.3` has added copied array
pipelines, split/flatten/reducer bridges, and updated-value end mutations. `.4.3.4` has added copied hash views
and transformations, statement-only named set-key mutation, direct hash-index assignment, merge-slot resolution,
and explicit flat-style splicing. `.4.3.5` has added expression-valued blocks, attached/marker/inline controls,
deterministic while guards, immediate helper/receiver with-blocks, and scoped hash/array tree callbacks. The
`.4.3.6` closeout confirms helper/value no-drift at 567 assertions without a runtime correction. `.4.4` adds an
explicit LIFO cursor stack, entry/local anchor rewinds, synchronized live/register cursor updates,
character-based cursor/input helpers, and earliest usable non-consuming named-rule boundary capture. Full Julia
tests pass with 581 assertions and package status `runtime-cursor-boundary`. `.4.5.0` splits diagnostics/trace
before code; `.4.5.1` now adds structured runtime diagnostics with spec/top/rule/handler attribution and
successful-output preservation. Full tests pass with 588 assertions, status is `runtime-diagnostics`, and
`.4.5.2` now adds ordered levels, environment/config controls, structured events/scopes/decisions/logs/dumps,
stdout/route/mirror sinks with reset, and output-preserving traced entrypoints. Full tests pass with 617
assertions at that controls boundary. `.4.5.3` now adds rule/regex/dispatch/lifecycle/recursion/cursor/boundary
events with traced/untraced identity. Full tests pass with 631 assertions, status is `runtime-trace-events`, and
`.4.5.4` closes final diagnostics/trace no-drift without a source correction. `.5.1` then
resolves/compiles/executes the built-in ActionIR body adapter in stable queue
order, stitches neutral JSON `body_ast`, and passes 662 assertions with status `runtime-staged-registry`; `.5.2`
then resolves registered exact-arity calls before helper fallback with eager caller arguments, fresh typed local
stores, final/local returns, receiver continuation, standalone result drop, and structured recursion cycles. Full
tests pass with 671 assertions and status `runtime-user-functions`. `.5.3` preserves two spec-returned functions
through normalized payload/jobs, stitched bodies, compiled
registry order, public descriptor metadata, and runtime output. Full tests pass with 691 assertions; status remains
`runtime-user-functions` at that boundary. `.6.1` adds controlled library corpus execution with public result
records, manifest-to-runtime composition, one-level wrapped structural comparison, optional trace lines,
structured diagnostic retention, and all-fixture reporting. Full tests pass with 715 assertions; status is
`runtime-controlled-corpus`. `.6.2.0` splits the 99-fixture rollout into bounded selection/reporting, starter
0–39, middle non-function 40–67, shipped-spec/parser-smoke 68–98, and spec-defined function-shell owners;
`.6.2.1` then adds bounded selection/reporting at 745 assertions and status `runtime-corpus-selection`.
`.6.2.2` proves starter fixtures 0–39 green at 40/40 without a production correction. `.6.2.3` proves non-function
windows 40–56, 58–59, and 62–67 green at 25/25 unchanged while routing three top-level function cases. Full tests
pass with 757 assertions and status `runtime-corpus-middle` at that boundary. `.6.2.4.0` measures and splits the
shipped-spec/parser-smoke window at 10/31. `.6.2.4.1` adds the complete direct anonymous capture family, closes
three hlink delimiter cases, and routes EBNF logging to structural output. `.6.2.4.2.1` adds eager logical helpers,
closes three portmap cases plus tablegrep. `.6.2.4.2.3` centralizes helper regex flags and closes portmap constant.
`.6.2.4.2.2` adds trace-routed, parse-result-neutral diagnostic output and advances simenv/history beyond
unsupported `print`. `.6.2.4.3` scopes explicit aggregate resets per recursive rule invocation and closes all
three recursive top-rule cases. `.6.2.4.4` adds action-edge child-push result reuse/indexing, closes all four
spec.spec smokes, and routes EBNF quote-only statement mutation. `.6.2.4.5.1` adds immediate `exit_now(...)`
termination with explicit numeric status, default status `1`, and structured runtime attribution. Simenv now
executes its fatal branch instead of reporting an unsupported helper, exposing the earlier scalar-mutation
prerequisite under `.6.2.4.5.2`. Full tests pass with 801 assertions, status is `runtime-corpus-exit-now`, the
window remains 25/31 at that boundary. `.6.2.4.5.2` adds statement-context four-argument scalar regex mutation
with strict flags and `$n` expansion while preserving pure numeric slicing. Both EBNF, both lib_reader, and simenv
fixtures pass. Full tests pass with 808 assertions, status is `runtime-corpus-statement-mutation`, the window is
30/31 at that boundary. `.6.2.4.5.3` mirrors the public parser's leading blank/comment-line skip through Julia's
in-memory runtime cursor seam. History passes without weakening indexed reads. `.6.2.4.6` now locks the complete
offset-68/limit-31 window in one permanent test: stable endpoints, 31/31 exact outputs, and zero failures.
`.6.2.5` then compiles and caches `specs/user_function_definition.spec`, executes it over caller-provided source,
normalizes its neutral nodes, and composes the existing staged body parser and runtime registry. The corpus path
tries rule-only parsing first and falls back only after a source parse error. All three routed fixtures pass.
`.6.3` then locks complete manifest validation plus ordered execution at 99/99 exact outputs and enables unbounded
CLI execution. Full tests pass with 840 assertions and status `runtime-corpus-full`; `.6.4` has since added focused
optional-SDK verification, and `.7.1` owns public documentation closeout.

### Lua Backend Commands, Embedding, and Status

Lua's current native boundary is `runtime-corpus-primary-cli`: PUC Lua 5.4 is
the primary runtime, LuaJIT is the secondary ABI, both pass 177/177 native
tests, the focused primary command passes 61/61 under default and POSIX option
environments, and the complete corpus passes 105/105. The warmed shared matrix
passes the same command contract at 5 backends x 2 environments x 61 cases.

From the repository root, run the complete checkout-local proof with:

```bash
bash tools/run_lua_local.sh
```

For direct embedding, primary-command, and corpus examples, first build the
PUC native PCRE2/filesystem adapters into caller-owned temporary storage and
export `LUA_PATH` plus `LUA_CPATH` for the entire shell session. The complete,
copyable setup and cleanup sequence is in
[Native Spec Loading](../public-api/native-spec-loading.md#lua-primary-parser-command).
There is no LuaRocks or system-wide installation dependency; the tracked
checkout commands are executable, and native modules are never installed
globally.

The primary command has no corpus/status subcommands or backend-only options;
the developer corpus runner remains separate. Planning `.8.1.0` corrects the original
v1/v2-only scope against descriptor v3; deterministic exact-v1/v2/v3 source
construction `.8.1.1` and fresh-process PUC Lua/LuaJIT proof `.8.1.2` are closed.
Exact ten-family execution `.8.2` and contract-sourced interpreter-first 8/105 fresh-host proof `.8.3` are also
closed. Final `.8.4` admits all 16 Lua capability rows at 80/0/0 and closes the backend handoff.

The Lua backend now has a dedicated full-parity plan. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg. The rollout began
by locking package/test/cache policy before code. The plan owns a native
in-process module, `linkedspec-lua` with the exact shared command interface,
typed source/ActionIR/compiled state, four value kinds, generic final-codeblock
equivalence, regex/match-state proof, staged functions, diagnostics/trace,
105/105 corpus, capability expansion, and generated-source v1. Installed LPeg
is evidence, not automatic proof that Lua regex behavior satisfies the neutral
contract.

The foundation policy uses `lua/src/linkedspec/`, a dependency-free
`lua/test/run.lua`, `lua/bin/linkedspec-lua`, and
`lua/bin/corpus_runner.lua`. Local commands prepend those source paths through
`LUA_PATH` and never write global package locations. No JSON package is
required: corpus IO now uses a small pure-Lua codec with explicit null,
array, and harray identity plus canonical object ordering. LPeg remains outside
the scaffold dependency set. Any future LuaRocks tree must be caller-owned
under temporary storage and recursively removed. At the historical foundation
boundary, `require("linkedspec")` returned exact backend/status/entrypoint
identity, the still-unimplemented primary scaffold intentionally exited `2`,
and the developer corpus command only validated the 105-fixture manifest. That
10/10-per-ABI boundary did not claim parser execution; the current command,
corpus, and 173/173 proof above supersede it. Unicode is the character/code-point
model; strict UTF-8 is the selected byte encoding, and UTF-16/UTF-32 are not
auto-detected. The next historical layer added data-only source
ASTs for specs, functions, ordinary/staged spans, staged parse jobs, rules,
simple/bounded modes, all ten body variants, targets, and fluent calls. Private
node identities and typed JSON projection prevent arrays, harrays, and
codeblocks from being inferred from incidental table layout. Representative
provenance and every body variant round-trip on both runtimes. The public
`parse_spec(source)` producer now parses rule paragraphs into those nodes: all
21 shipped specs and 102 rule-only corpus sources pass on PUC Lua and LuaJIT.
The other three corpus sources begin with top-level functions and remain owned
by spec-returned projection `.2.4`. Source validation is now also public:
`validate_spec(spec)` checks tops, duplicates, function registry collisions,
raw syntax, edge families/targets/slots, and regex structure;
`validate_spec(spec, { strict_syntax = true })` adds unused-rule rejection. All
21 shipped and 102 rule-only corpus sources validate on both runtimes. The
helper/control reservation inventory is exactly the current 246 public names and is
checked equal to Dart/Julia. Function-shell projection now consumes explicitly
typed `function_definition` / `function_definition_error` nodes returned by
`specs/user_function_definition.spec`; Lua does not raw-scan `fn` source.

The next Lua runtime layer consumes that compiled state directly in memory.
`runtime_engine(compiled, options)` plus `runtime_parse(engine, input)` (or the
`runtime_execute` alias) executes default, AND, OR, single, optional,
plus/star, and bounded rule families over the native PCRE2 matcher. Action and
blind edges transfer child results through `retv`; lifecycle payloads run in
applicable `I`, `LS`, `LE`, `IT`, `EX`, `LX`, `E` order. Rule-local bindings
are restored across child calls, recursion and zero-progress paths terminate,
`next()` advances the current rule iteration, and `exit_now(status)` stops with
a typed runtime error. Parse results retain the direct value, neutral
one-element output wrapper, byte/code-unit and character cursors, and lifecycle
events. PUC Lua and LuaJIT pass the same 66-test gate. This is the narrow
dispatch-facing boundary; broad helper/value behavior, staged function
execution, corpus execution, the primary CLI, and generated source remain
later owned work.

Helper/value breadth is deliberately ordered into separate Lua leaves before
implementation: four-kind stores/access plus entry/match reads; scalar/string;
numeric; arrays; harrays; codeblocks/controls/generic trailing blocks/tree
callbacks; capture/mark/input/cursor state; diagnostic output; then exhaustive
246-name and documentation no-drift. Each leaf depends only on earlier value
mechanisms and may split again before code. This keeps recognition of a helper
name distinct from executable parity. `.4.3.1` has since closed core values.
Scalar/string is recursively split: pure value transforms/comparisons/receivers
under active `.4.3.2.1`, then regex/split/statement mutation under `.4.3.2.2`.

Do not infer regex support from the host language name. Lua's native patterns
do not support lookbehind, but LinkedSpec's PUC Lua and LuaJIT modules both use
PCRE2 and permanently pass positive and fixed-width negative lookbehind. The
`spec.spec` form is the one-character assertion `(?<!\\)`. Dart's `RegExp`
implements ECMAScript semantics, and the real `spec_spec_minimal_rule` fixture
containing that pattern passes through Dart parse/compile/runtime. Rust's basic
`regex` crate needed a compatibility path only at an earlier milestone. The
current Rust parser, validator, and runtime use RGX, the project's roughly 98%
PCRE2-compatible engine with lookaround/backreference/subroutine support; the
historical basic-crate limitation does not describe current Rust behavior and
does not imply a Dart or Lua gap.

The first helper leaf now makes Lua's four value kinds explicit through
`runtime_value_kind(...)`: null/boolean/number/string scalars, arrays, harrays,
and codeblocks. Stores and reads copy mutable values. Bare assignment retains a
typed value in one observable binding; `set(name, value)` binds the evaluated scalar, array, harray, or codeblock
value. Zero-based array and
string-key harray access, append/hash-index assignment, and copy-on-write mixed
nested assignment are implemented without intermediate autovivification.
Current-edge `retv` dispatches its child before returning.

Lua also implements the complete entry/local match read family: text,
zero-based compact groups, named values/presence/maps, Unicode character
length/start/end, and 1-based start/end line/column helpers. Absent text/group/
length/span reads are null; absent group/map collections are typed empty
containers; named presence is zero; missing line/column uses origin `(1, 1)`.
The same 69-test suite passes PUC Lua and LuaJIT. The following non-case pure
scalar/string leaf adds lazy coalescing, definedness/emptiness, Unicode trim/
length/substrings, literal transforms/predicates, lexical comparisons, and
receiver chains. Its expanded suite passes 70/70 on both runtimes. The next two
closed leaves replace host-dependent Unicode casing and scalar-to-text behavior
with versioned, all-variant contracts.

ADR `0027` now pins that casing surface to Unicode 17.0.0 full Default Case Conversion. Exact official
UnicodeData/SpecialCasing/DerivedCoreProperties inputs generate a neutral contract with 1,563 lower and 1,581 upper
mappings, merged Cased/Case_Ignorable ranges, Final_Sigma context, and 12 fixtures. The offline checker is part of
the canonical local CI gate. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consume generated modules and pass the same
12 fixtures. Host case APIs are not the semantic authority.

The following scalar-to-text slice adds `linkedspec-scalar-text-v1`. `cat` now preserves strings, spells booleans
as `1`/`0`, uses stable finite decimal text (`-0.0` → `0`, `1.0` → `1`), and returns null when any argument is null,
array, harray, or codeblock. One neutral executable fixture covers the currently portable value surfaces on Perl,
Rust, Dart, Julia, PUC Lua, and LuaJIT; the contract also fixes codeblock as non-text without claiming that the
separately deferred explicit final-codeblock call syntax is already portable. Lua advances to 72/72 on both ABIs.

Scalar numeric rollout uses a separate `linkedspec-scalar-numeric-v1` boundary. Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT use dedicated strict helper adapters and pass the same 55 direct canonical calls: finite decimal
numbers/strings, exact fixed or variadic arities, invalid-to-null results, numeric comparison truth, half-away
rounding, division/clamp fences, and floor signed modulo. General-purpose scalar conversion paths remain unchanged.
One composed checker proves the exact expected fixture value on all six runtime variants. Lua word aliases,
arithmetic/comparison symbol callees, and integer/float/bare-scalar receiver chains now share the evaluator;
number-returning links compose and comparison links are terminal. The focused gate is 90/90 on both ABIs.
Strict copied-array sum/avg/median/range/min/max now work through explicit, bare-binding, and terminal receiver
forms on both Lua ABIs. Ordered `array(...)`/literal construction, explicit `flat`/`flat_array` call or terminal-
receiver splicing, ordinary nested array preservation, copied concatenation, and saved-source isolation raise the
focused gate to 92/92. Copied take/drop/zero-based slice/order/membership/stable uniqueness in direct and receiver
chains raise it to 93/93 without mutating their source. Copied selection `.4.3.4.2` is closed and scalar/regex
transform pipelines add delimiter-first terminal joins, literal/PCRE2 split, PCRE2 filtering, Unicode transforms,
and seven dropped-call rebindings at 95/95. `.4.3.4.3` is closed.
Typed rule accumulators, cached action-edge child reuse, whole/indexed implicit/explicit push, and uniform
append/end/split flow raise the dual-ABI gate to 98/98. Exact tagged-record construction reuses governed split,
evaluates carried fields once, copies nested values, returns `[tag, item, fields...]`, and raises the gate to 99/99.
All 34 non-callback array names and six numeric terminals are closed under `.4.3.4`. Copied harray construction
`.4.3.5.1` makes generic `flat` preserve runtime array/harray kind, adds direct/receiver `flat_hash`, keeps ordinary
nested maps intact, and splices only explicit flat ASTs; explicit harray-to-array list context uses deterministic
sorted key/value pairs. Lexical keys, copied values ordered by key, count, and null-aware membership compose through
function/receiver/array-chain forms and return `0`/`[]` for missing or wrong-kind sources. Both Lua ABIs pass
All 13 ordinary harray names close at 103/103 through `.4.3.5.5`: bare merge operands, later override, copied
set/rename/drop/pick values, deep source isolation, harray/array-view receiver chains, and named `set_key`/direct
harray mutation are implemented and public-result guarded. Codeblock/control/tree-callback parent `.4.3.6` is
now split: `.1` eager expression blocks, `.2` inline controls, `.3` statement controls, `.4` current built-in
contextual blocks/`with`, `.5` deterministic callbacks, and `.6` closeout. General user-function final blocks
remain `.5.1`; explicit callable codeblock values remain future `.11.7`.
Eager blocks plus lazy inline controls pass 105/105: ordinary no-pair braces yield their last/local-return
value, non-final statement mutation is preserved, harray braces retain precedence, and yielded values enter
receiver dispatch. Inline `if`/`switch` evaluates only selected payloads, keeps false/null, evaluates switch
subjects once, treats bare case labels literally, and composes in assignment and fluent return slots. Structural
`i`/`elif` and `when`/`otherwise` aliases do not become inline values. Attached/marker if-family statements then
raise the gate to 106/106: one selected branch executes, nested marker boundaries and empty branches remain exact,
block-local return is preserved, and malformed/orphaned controls expose typed keyword/reason/rule fields. Portable
authoring keeps `i`/`elif` marker-only and `when`/`otherwise` attached-only; extra alias-shape acceptance in
Perl/Dart/Julia versus Rust is backlog `.5`. Attached and marker switch statements then raise the gate to 107/107:
complete structure validates before one-time subject evaluation; first matching case/default ranges execute;
bare labels, nested boundaries, empty bodies, and local return remain exact; malformed/orphaned controls stay
typed. Inline and statement switch share Perl-reference scalar equality: null equals empty text, booleans use
`0/1`, and aggregates are noncomparable. Rust/Dart/Julia boolean or aggregate drift joins backlog `.5`. Perl also
executes marker statements outside every branch while Rust/Dart/Julia/Lua skip them; `.5` owns that range boundary.
Attached while raises the gate to 108/108: its condition sees body mutation, false initial runs no body,
return remains owned by its action/expression block, Perl-reference `next` continues the loop, and a typed
rule-attributed guard fails only when the condition remains true after the configured body limit. Dart/Julia guard
timing and Rust/Dart/Julia `next` drift join backlog `.5`. Built-in final blocks/scoped `with` then raise both Lua
ABIs to 112/112: copied signature metadata admits attached and parenthesized helper/receiver forms; the optional
value or receiver evaluates first; copied results continue through compatible receiver chains; and exact prior or
absent uniform bindings restore after success, local return, and error. Callback work is split at
`.4.3.6.5.1.0`: reference authored-value repair `.1.1` is done; `.1.2` adds atomic copied/restored callback frames
and sorted harray walk/map/reduce at 113/113. `.5.2` shares the dispatcher with zero-based array-root traversal,
recurse-only-same-kind semantics, and exact Perl-oracle behavior at 114/114 on both Lua ABIs. Tree callbacks are
closed; no-drift/dependency routing `.4.3.6.6` closes the parent and advances capture-slice/mark/input/cursor
helpers `.4.3.7`. Audit `.4.3.7.0` splits input/cursor controls, anonymous capture, governed named marks/bridges,
placement-sensitive marker members, earliest-boundary lookahead, and no-drift. It also finds seven helpers in the
public mark reference outside the governed 239-name backend inventories; named-mark closure must resolve that
cross-backend inventory gap instead of creating a Lua-only extension. `FUTURE-PARITY-BACKLOG.17` now owns the
neutral contract, five-backend rollout, and independent gate hardening. Input/live-cursor `.4.3.7.1` now executes
all character-unit input and cursor projections plus parse-scoped LIFO save/restore and entry/local anchor rewinds;
consume-mode matching observes the synchronized rewound cursor. Anonymous capture `.4.3.7.2` adds all 16 stable,
location, and advancing reads over the same byte-safe registers, with character-unit results, valid-only mutation,
and a void setter. Independent earliest-boundary `.4.3.7.5` then adds cached compiled-rule seek, earliest
selection, non-consumption, EOF fallback, and unresolved/regex-free no-op behavior. PUC Lua and LuaJIT pass
117/117. Named-mark `.17.1` adopts the exact seven-helper contract and aligns Perl live/generated plus Rust
native/serialized/emitted/generated execution; Dart `.17.2` now consumes the same fixture through native,
generated-plan, emitted-state, and primary-CLI routes, with an exact seven-name family view and complete 214-test,
61x2-CLI, 105-corpus proof. Julia `.17.3` consumes that same artifact through native, generated-plan,
emitted-state, and primary-CLI routes with an exact seven-name family view, 1,414-assertion, 61x2-CLI, and
105-corpus proof.
Lua `.17.4` now uses one parse-scoped rule-label/byte-offset store and returns the unchanged native/serialized
result at 119/119 on PUC Lua and LuaJIT. `.17.5` admits the seven calls into the aligned 246-name shared inventory,
combines 105 corpus fixtures with the exact named-mark fixture, independently requires all 122 public Perl
contracts, and locks nine non-public exclusions. Parent `.17` closes. Lua `.4.3.7.3` extends the same store across
governed current/input/anonymous/copy writers, stable and valid-only advancing named spans, two-mark reads, and
both anonymous/named bridges at 120/120. Placement-sensitive `.4.3.7.4` then compiles preferred/compatibility
anonymous markers and named marks into typed preceding-slot events, executes them after slot actions and before
`LE`, preserves them through public source reconstruction, and passes 121/121 on PUC Lua and LuaJIT. Exhaustive
capture/cursor no-drift `.4.3.7.6` derives 62 unique capture/mark/input/cursor/control calls and finds exact 62/62
agreement across contracts, interpreter dispatch, and focused execution sources. Together with the four exact
placement-marker spellings, the parent closes at 121/121 on PUC Lua and LuaJIT. Native capture/cursor parity does
not imply generated Lua support: compiled-state preservation, direct generated execution, subset admission, and
capability closeout remain `.8.1-.8.4`. Diagnostic output `.4.3.8` now adds a per-parse `diagnostic_sink` callback
and typed `RuntimeDiagnosticOutputEvent` records carrying helper, rule, and exact message text. `print`, `say`, and
`print_each` evaluate once left-to-right, preserve Unicode/order, stay out of parse values, and remain quiet
without a sink; immediate typed `exit_now` is unchanged. PUC Lua and LuaJIT pass 122/122. Exhaustive `.4.3.9.0`
then probes every admitted name: 230 reach an owner, thirteen are intentional statement/receiver-only forms, and
eager `and`/`or`/`not` are the exact missing value family. `.4.3.9.1` now executes all three eagerly over established
Lua truthiness. Permanent `.4.3.9.2` drives all 246 names through parse/compile/runtime: 233 reach function-form
owners and the exact thirteen documented structural/receiver-only forms remain intentionally unsupported as
functions. Direct `call(rule)` result/`retv`/cursor behavior is focused, public status is
`runtime-helper-value-control`, both ABIs pass 125/125, and parent `.4.3` is closed. A source-history recheck also
corrects the audit's unreproducible duplicate-`or` note: every inspected revision has one inventory row. The audit
also records
pre-existing diagnostic transport/format differences under `FUTURE-PARITY-BACKLOG.5.1`, while Perl
`and`/`or` keyword lowering and five-backend logical truthiness/arity remain separately owned by `.5.2`; Lua
`.8.4` has satisfied their backend-parity prerequisite, but neither Lua-local closure is a false five-backend
normalization claim. Planning audit `.5.2.0` proved this was not one simple mismatch. At that audit boundary Perl
conditions used lazy host `&&`/`||` while direct logical values remained raw/broken; Dart short-circuited; Rust,
Julia, and Lua were eager. Truthiness had three profiles: Perl/Lua (`"0"` false, empty aggregates true),
Dart/Julia (all nonempty strings true, empty aggregates false), and Rust (`"0"` plus `"false"` false, empty
aggregates false). Native/generated execution agreed within each backend. Neutral/backend/generated/gate/public leaves `.5.2.1-.9` are
therefore dependency-ordered before any behavior claim changes. Neutral `.5.2.1` now adopts ADR `0043` and the
executable `linkedspec-logical-helper-v1` contract: valid `and`/`or` take one or more operands, `not` takes exactly
one, all valid operands evaluate once left-to-right,
all results are booleans, and invalid arity fails before effects. Typed truth makes only null, false, numeric zero,
empty strings, and empty aggregates false; codeblocks are true without invocation. The executable contract checks
17 truth rows, ten helper cases, three eager-effect scenarios, receiver/lazy-control contrast, four invalid calls,
deterministic fixtures, and 22 semantic/topology mutations. Its ledger began deliberately at 0 complete / 8 pending before Perl,
Rust, Dart, Julia, Lua, generated/primary, recurring, and public leaves `.5.2.2-.9`. Perl `.5.2.2` consumes that
policy through typed ActionIR/runtime lowering across native/live/standalone-emitted execution. Rust `.5.2.3`
now routes helpers and lazy conditions through one `RuntimeValue::as_bool` seam, rejects arity before operands,
and proves native, serialized, generated-plan, direct-value, and compiled emitted roles. Dart `.5.2.4` now routes
helpers and lazy controls through `runtimeLogicalTruth`, rejects call shape before effects, evaluates every valid
operand once left-to-right, and proves native, normalized, generated-plan, compiled emitted, and primary roles.
Julia `.5.2.5` preserves its typed eager `_runtime_truthy` seam, rejects all four invalid arities before effects,
and proves native, normalized, generated-plan, compiled emitted, and primary roles with optional exact diagnostic
fields. Lua `.5.2.6` aligns `runtime_truthy` and pre-effect arity across native, reconstructed, generated-plan,
loaded emitted-module, and primary roles on PUC Lua and LuaJIT. Its expanded consumer passes 359/359 per ABI and
the complete Lua gate at that boundary was 177/177 per ABI plus CLI 63x2 and corpus 105/105. Generated/primary `.5.2.7` proves
every available direct/traced role across Perl, Rust, Dart, Julia, and Lua with exact values, eager effects,
failure/source metadata, and trace identity. Rust retains the intentional typed direct-value versus compatibility-
output-array signature. Shared case `success_logical_helpers_eager` passes all five commands in default and POSIX
environments. Recurring `.5.2.8` now locks one strict driver over that neutral checker, all six runtime consumers
and their exact native/generated roles, selected 5x2x1 primary case, and generated-source/capability/coverage
ledgers. Canonical local CI registers the same all-toolchain proof behind `LINKEDSPEC_RUN_LOGICAL_MATRIX=1`.
Public no-drift `.5.2.9` locks the authoritative guide/backend/status surface; the ledger is 8 complete / 0
pending and parent `.5.2` is closed. Explicit codeblock literals remain
separately owned by `.11`; the logical contract's
typed codeblock row does not activate that syntax.
Planning `.5.1.0` split diagnostic parity before behavior changes. Its historical probes found three important
reference hazards in the pre-repair transport: Perl evaluated `print_each` prefix/suffix inside its host loop,
host output bypassed the primary command's strict UTF-8 encoder, and lowered host `exit` bypassed canonical
invocation failure framing. Neutral contract `.5.1.1` then adopted ADR `0042` and the strict
`linkedspec-diagnostic-output-v1` fixture: one-plus/two-or-three arities before evaluation, once-only arguments,
typed scalar rendering, per-call/item Unicode events, quiet caller sinks, unchanged sink failure, immediate exit,
generated propagation, and an ADR `0024`-separate quiet primary projection. Its eight rollout rows deliberately
began pending. Perl `.2`, Rust `.3`, Dart `.4`, and Julia `.5` now consume the exact native contract through typed
invocation-local events, quiet defaults, preserved sink failure, and typed immediate exit. Dart and Julia both
use private carriers through their action/runtime wrappers so even a caller-thrown interpreter exception retains
its exact identity; Julia additionally removes rich helper text from low trace. Lua `.6` consumes all 109
neutral assertions on PUC Lua and LuaJIT, using the same private-carrier pattern for exact caller identity and a
distinct `RuntimeExitNow`. Generated/CLI `.7` propagated the same sink through every available emitted role and
locked the quiet primary projection. The topology-checked recurring six-consumer/native+generated/quiet-primary
gate `.8` prevents silent omission. Public no-drift `.9` aligns and checks the normative document set, closing the
diagnostic-output parent at 8 complete / 0 pending while capability remains 80/0/0.
Planning-only `.4.4.0` follows the completed Dart/Julia dependency order: `.4.4.1-.4` separately own neutral
structured runtime failures, ordered trace controls and caller-owned sinks, interpreter events, and runtime
no-drift. Full native loading, frontend, validation, compiler, function-shell, staged-dispatch, and runtime
propagation stays `.5.3`, after general staged functions `.5.1` and native loading `.5.2` create those owners.
Structured runtime diagnostic `.4.4.1` now exposes the same neutral fields on typed Lua exceptions. Optional
engine source identity, top-selection/input/lookup/execution stages, deepest child rule and handler preservation,
deterministic JSON, unchanged text, and successful-result identity pass 126/126 on both ABIs. `.4.4.2` now adds
typed ordered levels/config/events, documented environment controls, caller-owned stdout/route/mirror sinks,
reset/append, and result-neutral direct/config-wrapper parse scopes at 128/128. `.4.4.3` adds exact runtime
rule/regex/dispatch/recursion/lifecycle/cursor/boundary/mark-capture events at 129/129. No-drift `.4.4.4` closes
parent `.4.4`. Planning `.5.1.0` separates staged dispatch, fixed/variadic runtime, contextual-codeblock metadata/
runtime, and closeout. Minimal staged dispatch `.5.1.1` passes 130/130; fixed-v1 runtime `.5.1.2` passes 133/133.
Variadic-v2 state `.5.1.3.1` preserves the exact signature union and minimum/unbounded resolution at 136/136.
Fresh rest-array execution `.5.1.3.2` passes the exact neutral fixture and copied mixed/empty runtime proof at
139/139. Contextual final-codeblock metadata `.5.1.4.1` preserves exact shell/staged/registry state and contextual
normalization at 142/142 with public status `runtime-user-functions-contextual-codeblock-metadata-v1`.
Contextual execution `.5.1.4.2` then runs in the current function frame with cleanup-safe restoration, static
callable precedence, chainable results, and typed failures at 146/146; public status is
`runtime-user-functions-contextual-codeblock-v1`, parent `.5.1` is closed, native-loading split `.5.2.0` is done,
 portable resolve/load `.5.2.1` and cached automatic spec-defined parsing `.5.2.2` pass 151/151. Typed loaded-source
composition `.5.2.3` then passes 153/153 with status `native-spec-pipeline-v1`; `.5.2.4` closes parent `.5.2`,
exact descriptors `.5.3.1` and caller-owned full-pipeline trace `.5.3.2` then pass 155/155 with status
`native-full-pipeline-trace-v1`. No-drift `.5.3.3` closes parents `.5.3`/`.5`; controlled/core planning `.6.1.0`
and typed nested-path repair `.6.1.1` are complete at 46/46 across offsets 0-39 and 99-104. Reusable executor
`.6.1.2` passes controlled typed records at 160/160 per ABI; ordered core window `.6.1.3` permanently passes 40/40
at endpoint 1/1 and raises both suites to 161/161. Governed `.6.1.4` permanently passes 6/6 at endpoints
`2,1,2,1,5,5`, raises both suites to 162/162, closes `.6.1`, and activates `.6.2`; capability remains 64/0/0.
Explicit
`{|params| ...}` literals and
dynamic codeblock-variable calls remain `.11.7`.
ADR `0033` and
`FUTURE-PARITY-BACKLOG.16` separately close narrow zero-argument aliases. Neutral
contract `.16.1`, all five backend implementations through Lua `.16.6`, and public/capability admission `.16.7`
are complete at 64/0/0 with one recurring five-backend/two-Lua-ABI command. Rust, Dart, Julia, and Lua's pre-existing `.contains()` missing-argument outcomes are
separately owned by helper backlog `.5`. Lua proves public SpecFile JSON reconstruction on both ABIs, and emitter
core `.8.1.1` now serializes that exact fixed-v1/variadic-v2/final-codeblock-v3 state into deterministic native
Lua with metadata, errors, and direct/traced roles. Isolated PUC Lua/LuaJIT valid/corrupt load/run/cleanup proof
is closed under `.8.1.2`; `.8.2` adds authoritative ten-family root/nested dispatch, exact rejections, portable
trace, an isolated all-family host, and emitted variadic proof. `.8.3` adds exact contract-ordered interpreter-first
8/105 fresh-host values/metadata/plans/trace identity and cleanup. Capability ownership remains `.8.4`.
This also corrects the earlier Lua-only inert assignment scaffold expectation.
Perl's direct-value/arity boundary for zero or variadic flat/concat calls, negative
selection counts, Rust/Dart/Julia's three missing dropped-transform rebindings, invalid join sources, and implicit
child-push expression results, rename-to-existing-key policy, scalar/aggregate condition truthiness,
boolean/number or aggregate switch equality, and while guard/`next` behavior differ;
`FUTURE-PARITY-BACKLOG.5` owns those explicit normalization decisions. Callable arity is semantic: add/multiply/min/max are
purposefully unbounded, while subtraction/division/modulo and comparisons remain exact-arity. ADR 0030 now adopts
`fn name(fixed, ...rest) { ... }`: version-1 fixed functions stay exact; version-2 variadic definitions preserve a
neutral fixed-prefix/rest/min/max signature through staged records and descriptors, bind extras as a fresh typed
array, and reject keyword/overload/host-splat semantics. Perl, Rust, Dart, and Julia now consume the unchanged
fixture through grammar/spec projection, staged/outward records, native and generated execution, diagnostics, and
exact results. Lua `.5.1.3.1/.2` preserves and executes the native signature/rest contract, and `.5.3.1` now emits
the exact shared fixed-v1/variadic-v2/final-codeblock-v3 outward descriptor union. Generated preservation,
execution, and final census admission close under `.8.1-.4`; the callable signature is now admitted across all
six runtime variants.

The next Lua leaf reuses its in-process PCRE2 owner for helper regex values. Function and terminal-receiver
`matches` apply `i/m/s/x`, accept `g/o` as predicate no-ops, and return false for null/non-text input, non-regex
patterns, unknown flags, or invalid patterns. PUC Lua and LuaJIT pass 73/73; pure split remains separately owned.

The pure-split leaf then adds fresh typed arrays for literal and PCRE2 delimiters, preserves leading/trailing empty
fields, treats an empty literal delimiter as Unicode-scalar splitting, and advances safely around zero-width regex
matches. Function and string-receiver forms are equivalent and non-mutating. Both Lua ABIs pass 74/74; scalar
statement substitution remains a separate next mechanism.

The scalar-mutation leaf then spends dropped-statement context: four-argument `substr`/`regex_subst` with a bare
target mutates that scalar, while numeric `substr` remains pure. String and regex patterns share strict PCRE2
flags; `g` controls global replacement, `o` is a no-op, and `$0`/`$n` expand per match. Invalid pattern/flag
diagnostics carry the rule label, and zero-width global replacement advances by Unicode scalar. Both Lua ABIs pass
75/75; explicit array-target split replacement remains separately owned.

The explicit-array leaf then recognizes dropped `split(target, source, delimiter)` before pure evaluation.
It evaluates source and delimiter once, reuses the exact pure split policy, and replaces only the named typed array
store with a copy. Ordinary split calls remain harmless discarded expressions and source scalars stay unchanged.
Both Lua ABIs pass 76/76; shipped-corpus and public-surface no-drift remains the closing string-runtime leaf.

```lua
local source = [[
Top::
 /a/ -> Child
 E { return(retv) }

Child:
 /b/
 E { return("child") }
]]

local compiled = linkedspec.compile_spec(linkedspec.parse_spec(source))
local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "ab")
assert(result.value == "child")
assert(result.output[1] == "child")
```

Lua embedding code can construct the neutral data model directly:

```lua
local linkedspec = require("linkedspec")
local ast = linkedspec.spec_ast

local spec = ast.spec_file({
  rules = {
    ast.rule({
      header = ast.rule_header({
        label = "Top",
        is_top = true,
        mode = ast.default_rule_mode(),
        rest = "/x/",
        line = 1,
      }),
      body = {
        ast.body_element({
          kind = ast.regex_body_kind({ pattern = "x" }),
          source = "/x/",
          line = 1,
        }),
      },
    }),
  },
})

local encoded = linkedspec.json.encode(ast.to_json(spec))
local restored = ast.from_json("SpecFile", linkedspec.json.decode(encoded))
assert(ast.top_rule(restored).header.label == "Top")
assert(linkedspec.validate_spec(restored) == nil)
```

The projection uses the same field names as the other variants, including
`functions`, `source_span`, `body_span`, `body_parse_job`, `parent_ast_path`,
`result_policy`, and `failure_policy`. Constructor lists must be dense and
one-based. Optional function payloads must already be typed JSON values; plain
Lua tables are rejected rather than guessed.

The rule parser recognizes simple/bounded modes, header-line regexes, action
and blind edges, grouped/indexed targets, lifecycle/plain blocks, markers,
multiline fluent continuations, receiver `when`/`otherwise` blocks, comments,
and permissive raw fallback. Nested scanning preserves braces inside both
single- and double-quoted strings. Because Lua strings may contain arbitrary
bytes, the public source seam rejects invalid UTF-8 before scanning; Unicode is
still the logical character model. Statement separation follows the universal
rule exactly:

```text
E {
  set_key(meta, "a", 1)
  set_key(meta, 'b', 2)
  return(meta)
}

E { set_key(meta, "a", 1); set_key(meta, 'b', 2); return(meta) }
```

The first block uses physical newlines. The second uses semicolons only between
multiple statements on one line; its last statement has no trailing semicolon.
Parsing remains permissive; callers opt into the separate validator. Validation
still does not imply compilation, runtime, corpus execution, or primary CLI
readiness.

The function-shell APIs are:

```lua
local nodes = linkedspec.definition_nodes_from_user_function_definition_output(output)
local projection = linkedspec.project_user_function_definition_asts(source, nodes)
local parsed = linkedspec.parse_spec_with_user_function_definition_asts(source, nodes)
local staged = linkedspec.parse_spec_with_staged_user_function_definitions(source)
```

Projection validates identifiers, params/arity, Unicode character-index spans,
exact source/body slices, staged payload and parse-job metadata, parser/top-rule
identity, result/failure policy, and diagnostic ownership. It normalizes paths
to `functions.<index>.body_source`, derives deterministic body-job IDs, replaces
function-span characters with spaces while preserving CR/LF, then parses the
remaining rules. The explicit projection API leaves `body_ast` absent; the automatic staged API executes and
stitches it. Empty node input never falls back to a raw function scanner, and the automatic API obtains nodes only
by executing the spec-owned grammar.

Lua now also exposes the typed ActionIR parser seam:

```lua
local block = linkedspec.parse_action_block([[
set_key(meta, "b", 2)
set_key(meta, "a", 1)
set_key(meta, "drop", 0)
set_key(meta, "stmt_hash", 4)
set_key(overlay, "a", 10)
set_key(overlay, "c", 3)
value_set = set_key(meta, "value_only", 9)
receiver_set = meta.set_key("receiver_only", 5)
]])

assert(block.kind == "action_block")
assert(#block.statements == 8)
assert(block.statements[7].expr.kind == "assign_scalar")
```

No semicolon is needed there because every statement occupies its own physical
line. Semicolons only separate multiple statements on one physical line, and
the last statement on that line has no following semicolon:

```text
set_key(meta, "b", 2); set_key(meta, "a", 1); return(meta)
```

`parse_action_block(source)`, `parse_action_statement(source)`, and
`parse_action_expression(source)` return structural records for value-drop
statements, calls and arguments, scalar/array/harray/codeblock values, regexes,
direct and nested access, scalar/append/hash/nested assignments, attached
controls, switch branches, and receiver chains. The nodes retain source text
and zero-based Unicode character spans; strict UTF-8 is only the Lua host
encoding at this boundary. `linkedspec.action_ast.to_json(node)` projects them
through typed JSON values. Unsupported expressions stay explicit `raw_perl`
nodes so the diagnostic layer can reject them without arbitrary Lua-global or
host-code fallback.

Single-quoted strings have the same universal DSL status as double-quoted
strings. For example, the second argument below is the literal `"|\\s`:

```text
substr(value, '"|\s', "", go)
```

Final codeblocks are parsed generically for helper calls, user-function-shaped
calls, and receiver methods. The attached form is the same call shape as an
explicit last `block_value` argument:

```text
func_helper_method(value) { return(value) }
func_helper_method(value, { return(value) })

value.func_helper_method() { return(value) }
value.func_helper_method({ return(value) })
```

The `.3.1` boundary parses structure only. Lua now layers typed ActionIR
contract resolution over those nodes:

```lua
local resolution = linkedspec.resolve_action_block_contracts(block)
assert(resolution.ok)

local alias = linkedspec.resolve_action_expression_contracts(
  linkedspec.parse_action_expression("gt(value, 0)")
)
assert(alias.contracts[1].source_name == "gt")
assert(alias.contracts[1].canonical_name == "num_gt")
assert(alias.contracts[1].family == "numeric")
```

`resolve_action_block_contracts`, `resolve_action_statement_contracts`, and
`resolve_action_expression_contracts` walk calls, receiver methods,
assignments, controls, nested arguments, block values, shapes, and access
indexes. Contracts record source/canonical name, family, surface, source span,
and positional/keyword counts. `action_contracts.to_json(value)` projects the
same fields as Dart and Julia.

`canonical_action_helper_name(name)` covers the current numeric, symbol, and
control aliases, including `=(target, value)` to `set`. The resolver and source
validator share the exact 246-name `action_call_names` inventory. Unknown or
non-current calls produce generic `unknown_helper`; structural fallback
produces `raw_perl`. Neither can fall through to a Lua global.

The optional `{ function_registry = registry }` resolver input checks
`registry:resolve_call(name, arity)` before helper fallback for ordinary
function-call surfaces. Exact matches become `family = "user_function"`;
registered wrong-arity calls produce `user_function_arity_mismatch`. This is
the stable `.3.3` integration seam, not a hidden Lua closure registry.

The concrete registry is now available:

```lua
local registry = linkedspec.user_function_registry_from_spec(spec)
local call = registry:resolve_call("normalize", 1)

assert(call.matched)
assert(registry:body_parse_jobs()[1].function_name == "normalize")
```

Registry construction snapshots ordered typed definitions, rejects duplicate
names, and preserves body source, payload, parse job, and optional ActionIR AST.
`stitch_function_body_ast(spec, job_id, body_ast)` validates the staged
`replace_field` / `body_ast` insertion contract and returns a new typed spec;
neither the source spec nor caller-owned AST is mutated.

Invocation preparation is intentionally data-only. Callers first evaluate each
argument, then pass the resulting scalar, array, harray, or codeblock values to
`prepare_user_function_invocation(...)`. It creates fresh local stores and
defensively copies aggregates and codeblock ASTs. It accepts neither a caller
store nor a Lua function, so host closures and implicit caller mutation cannot
cross this boundary. Unknown names, arity drift, ambiguous/cyclic values, and
recursion are typed failures; recursion reports stable rule and handler-source
identity. Function-body execution and staged dispatch remain later layers. The
dual-runtime gate now passes 50/50 on PUC Lua and 50/50 on LuaJIT.

Lua's compiler layer is now data-complete before matching. `compile_spec(spec)`
validates and snapshots the typed source by default, then produces ordered
effective rule/function state:

```lua
local compiled = linkedspec.compile_spec(spec)
local top = compiled:rule("Top")
local descriptor = compiled:to_descriptor_json()

assert(top.mode_metadata.is_repetition)
assert(descriptor.meta.descriptor_model == "compiled_descriptor_state")
assert(descriptor.spec.Top.handler.kind == "lua_interpreter_rule")
```

Each `CompiledRule` carries its source header, neutral mode metadata, regex
patterns, dependency refs, action/blind edges, lifecycle/plain payloads,
original body elements, parsed ActionIR, and registry-aware contract results.
Child regex slots are validated and resolved into structured
`CompiledDependencyRegexState` rows with zero-based indexes and combined-pattern
metadata. The compiler does not execute or host-compile those patterns yet.

`compiled:to_json()` exposes the typed internal effective state.
`compiled:to_descriptor_json()` exposes exactly the shared outward contract's
four keys: `spec`, `functions`, `dependency_regex_map`, and `meta`. Its model
identities are `compiled_descriptor_state`, `compiled_spec_state`, and
`compiled_dependency_regex_state`; ordered function records retain staged
payload/job/body-AST fields. Lua rule handlers are explicitly
`lua_interpreter_rule` / `compiled_state_only`, making the non-runtime boundary
visible rather than fabricating callable handlers. Source mutations after
compilation cannot alter the compiled snapshot. The dual-runtime gate passes
55/55 on PUC Lua and 55/55 on LuaJIT; regex/match-state work begins in `.4.1`.

Lua runtime matching now uses a narrow repository-owned PCRE2 C binding. LPeg
was evaluated and rejected for this role: it constructs PEG patterns but does
not parse LinkedSpec's governed PCRE syntax. No `rex_*` module is installed.
`tools/build_lua_native.sh` compiles the binding separately against the PUC Lua
and LuaJIT ABIs. `tools/run_lua_local.sh` places both builds under one unique
caller-owned `/private/tmp/linkedspec-lua-native.*` tree and removes the tree on
every exit, so no binary/cache enters the repository or global Lua paths.
Matching remains in-process; it never shells out to `pcre2grep` or Perl.

Given a compiled rule, matching is direct:

```lua
local alternatives = linkedspec.compile_runtime_regex_alternation(
  compiled:rule("Top")
)
local match = alternatives:match("prefix évalue", 0, "seek")

if match then
  print(match.alternative_index, match:text(), match:char_start())
end
```

`seek` selects the earliest candidate at or after the strict-UTF-8 byte cursor
and breaks equal-position ties by source alternative index. `consume` anchors
the attempt at that cursor. PCRE2 consumes inline/scoped flags, POSIX classes,
Python/angle named captures, possessive quantifiers, recursion, and `\K`
directly; there is no Lua dialect normalization.

Typed match records preserve the stable zero-based alternative, full group
slots, compact participating captures, named captures, byte/code-unit spans,
Unicode character spans, 1-based line/column, and explicit zero-width state.
Typed immutable registers keep entry and local matches separate, seed a child's
entry from the caller's local match, track cursor/capture anchors, and detect
zero progress without confusing an absent match with `[0, 0)`. Invalid PCRE,
UTF-8 input, non-boundary offsets, and parse modes are typed failures. The gate
passes 60/60 on PUC Lua and 60/60 on LuaJIT and leaves no native artifact;
compiled rule dispatch remains `.4.2`.

Required-slot execution now addresses the authored alternative directly:

```lua
local required = linkedspec.match_runtime_regex_slot(
  alternatives,
  1,
  "aa",
  1,
  "consume"
)
assert(required.alternative_index == 1)
```

This operation is distinct from choice matching. Ordered and repeated-AND
execution supply the required index; OR/default continues to evaluate the full
alternation. `validate_compiled_regex_slot_identities` checks target-rule/child-
index identity at compiler, runtime-engine, emitted-source, and generated-plan
boundaries. Descriptor metadata and emitted v2 modules publish
`linkedspec-duplicate-regex-slot-identity-v1`; generated plans remain exactly
label/family rows. High trace emits `lua_runtime:regex_slot_selected` with rule,
selection role, target rule, and regex index. The same 15-role admission source
passes 112 assertions on PUC Lua and LuaJIT; the complete driver retains 177
package tests per ABI, primary 65/65 in both environments, and corpus 105/105.

The duplicate-slot recurring gate is
`tools/check_duplicate_regex_slot_identity_five_backend.sh`. It runs this shared
consumer on both Lua ABIs and composes the Perl, Rust, Dart, and Julia admissions,
selected primary case, and support ledgers in one omission-sensitive proof.

### Julia Backend Commands, Embedding, and Status

Julia is green at the accepted interpreter-first boundary: the complete validated corpus executes 105/105 with
exact checked-in output, full package tests pass with 1,040 assertions, and package/CLI status is
`runtime-corpus-primary-cli`. The primary product surface is the native `LinkedSpecJulia` module; the Julia CLI and corpus
runner are thin adapters over the same in-process parser/compiler/runtime path.

The Julia primary command now exposes ADR `0023`'s parser-oriented help and accepts only its exact source/input/
parser/trace flags. It rejects `status`, `corpus`, and all positional arguments with usage exit `2`; corpus work
remains in the separate runner. Named specs resolve through exact current path, current `NAME.spec`, repository
`specs/NAME.spec`, then deterministic authored fallback. File and inline content is loaded exactly. Rule-only and
spec-driven top-level-function source now execute through the native compiler/runtime with top-rule, parse-mode,
and trace controls. Success prints the direct top-rule value with recursively sorted object keys and one newline.
Source compilation precedes input-file loading. Compilation, input-load, and invocation failures use stable stderr
headings and exit `1`; usage errors exit `2`. Native trace retains stdout/route/mirror, reset, quiet, and emoji
controls; the primary command now uses a separate canonical phase recorder. `.7.3.2.5` locks nine process families with
exact stdout/stderr/newline/file bytes and exit 0/1/2. `.7.3.3` closes honest local no-drift; global cross-backend
fixture identity has since closed under `FUTURE-PARITY-BACKLOG.1.5.4.3`.

The global unchanged-suite audit in `FUTURE-PARITY-BACKLOG.1.5.4.0` measured warmed Julia at 13/61. `.1.5.4.1`
now renders exact shared help, rejects malformed source/input bytes as UTF-8 without converting valid text, and
emits only the stable phase heading on primary stderr. Native structured exceptions retain diagnostic detail.
That boundary reached 42/61. `.1.5.4.2` now projects exact levels, UTF-8 counts, escaping, emoji, sinks, file
lifecycle, failures, and result framing independently of rich native trace, closing 61/61 default/POSIX.
`.1.5.4.3` now owns project warmup and closes the recurring four-backend matrix. The native rich diagnostics/trace
APIs remain available.

The boundary plus global matrix claim exact four-backend fixture identity, but not complete public capability
parity or generated Julia source. `.7.2` deliberately defers generated Julia source to the split
future source-emitter lane under `FUTURE-PARITY-BACKLOG.3`; Julia currently guarantees the interpreter and local
primary-command paths. A credible later emitter must own its scaffold/compile-run harness,
typed generated-family plan, direct structural-family execution, and curated corpus proof. Runtime diagnostics/
tracing now span frontend, compiler, function-shell, staged, and interpreter phases through one optional emitter;
the trace chapter documents the event families and examples. `JuliaFormatter` and `JET` are
optional local tools rather than parity prerequisites.

## Machine-readable capability census

Exact CLI identity and 105/105 interpreter output do not alone prove every public API and mdBook capability. The
broader current census lives in `capability_conformance/manifest.json` and is checked by:

```bash
perl tools/check_capability_conformance.pl
```

The current audit contains 16 capabilities x five admitted backends. All 80 states pass. Earlier non-pass
boundaries remain below as rollout history, not as live gaps:

| Residual mechanism | Current classification | Owner |
| --- | --- | --- |
| Native named/file resolution | ADR `0026` and the 14/9/4 fixture fix portable names, exact paths, ordered roots, strict UTF-8, and typed stages. Perl, Rust, Dart, and Julia consume the contract directly; exact admission is closed. | closed `.1.6.4` |
| Full native pipeline trace | Perl, Rust, Dart, and Julia propagate a caller-owned emitter through frontend/compiler/function/staged/runtime phases. Dart's direct routed/quiet/failure proof and recurring gates are admitted. | closed `.1.6.5` |
| Generated parser source | Perl, Rust, Dart, Julia, and Lua pass contract v1. Rust compiles/runs 105/105. Dart, Julia, and Lua pass deterministic emission, ten-family direct dispatch/four rejections/trace roles, and exact contract-sourced interpreter-first 8/105 host admission; Lua uses fresh PUC Lua/LuaJIT hosts and exact v1/v2/v3 callable state. | closed `.3.5`; Lua admission `.8.4` |
| Punctuation-light zero-argument aliases | Six standalone markers and a terminal zero-argument receiver segment preserve their parenthesized typed twins without widening conditions or general calls. | closed `.16.7`; live census 80/0/0 after Lua `.8.4` |

Deprecated Perl plugins, general future `parse_job(...)` authoring, semantic introspection/MCP, and generic
first-class/dynamic callable-codeblock equivalence are explicit exclusions/future owners rather than
silent gaps. No backend is called complete while a current matrix state remains partial or gap.

During the historical rollout, `FUTURE-PARITY-BACKLOG.1.6.6` closed the non-codegen census without claiming
complete backend parity. Its 57/1/2 boundary first advanced to 58/0/2 through strict recurring Rust generated-
source admission, when Dart and Julia were the two gaps; Dart admission then advanced it to 59/0/1.

That 57/1/2 statement was the source-audit boundary. `.3.1.0` added the missing independent Perl compile/run probe:
the captured text compiles, but stringifying/recompiling `LinkedRE::oredRE` detaches its `(?{$pos=N})` alternative
markers from `LinkedRE::or`'s lexical index. A match can consume input while generated action selection is skipped.
Perl was therefore corrected to partial. `.3.1.2` now reconstructs those alternations from canonical refs and passes
independent result/trace/identity/plan/error proof. `.3.1.3.0` then audited Rust against the now-concrete v1 roles:
its pre-contract scaffold was green for all families and eight fixtures. `.3.1.3.1` now supplies typed source
identity, contract/version metadata, structured emission/compile-load/validation/execution errors, and compatible
legacy adapters. `.3.1.3.2` now adds exact neutral plan strings and four rejections, direct v1 result projection,
and the three portable trace roles while preserving legacy accumulator/trace behavior. `.3.1.3.3` reruns complete
Perl/Rust gates and admits that baseline: census is 57/1/2, with Perl pass. `.3.2.0` subsequently adds a staged
full-manifest classifier that prepares every fixture through interpreter-first emission, writes 105 separate
generated modules/tests into one isolated Cargo crate, and passes host compile/run 105/105. Zero-failure closeout
`.3.2.1` finds no repair mechanism. `.3.2.2` makes the proof a strict recurring gate, passes
the complete Rust package and CLI gates, and promotes Rust generated source at census 58/0/2. Dart `.3.3.1` then
adds public compatibility/v1 emitters, stable metadata/errors, strict-UTF-8/Base64 payload embedding, and an
isolated temporary-package analyze/run proof. `.3.3.2` adds exact ten-family direct dispatch, four plan rejections,
portable trace roles, and an isolated all-family matrix. `.3.3.3` adds exact accepted-subset admission and promotes
Dart; the census is 59/0/1 with Julia the sole gap. `.3.4.1` then adds Julia's public compatibility/v1 emitters,
canonical effective-AST serialization, strict-UTF-8/ASCII-hex payload and identity embedding, typed portable
metadata/errors, direct/traced generated entrypoints, and an 18-assertion isolated include/run/corrupt-load proof.
`.3.4.2` then adds exact typed ten-family classification, four plan rejections, family-authoritative per-rule
dispatch, portable trace roles, and one isolated emitted all-family module. `.3.4.3` consumes the exact contract
subset, proves all eight interpreter values before emission, independently loads eight namespaced modules with
exact metadata/plans/trace identity, and promotes Julia. The then-live census was 60/0/0; punctuation-light
admission `.16.7` later advanced it to 64/0/0, and Lua `.8.4` now advances the live census to 80/0/0.

`FUTURE-PARITY-BACKLOG.3.0` turns that broad owner into an executable order. `.3.1.1` first fixes a versioned neutral
contract for emission, host compile/load, direct generated execution, exact result/error/source identity, trace,
family-plan validation, and manifest proof; `.3.1.2` repairs Perl and `.3.1.3.3` admits the aligned Perl/Rust
baseline. `.3.2.0` classifies Rust's full manifest 105/105 green, `.3.2.1` closes the empty repair inventory, and
`.3.2.2` completes strict recurring admission. Dart scaffold `.3.3.1` and exact family/direct execution `.3.3.2`
are closed; `.3.3.3` admits Dart and closes `.3.3`. Julia scaffold `.3.4.1` and family/direct `.3.4.2` are closed;
`.3.4.3` admits the contract-sourced corpus proof. `.3.5` rechecks all four focused proofs and adjacent complete
backend gates, closes `.3` at 60/0/0, and activates Lua planning. Because
the artifacts are host-language source, byte identity is not required; ADR `0023` requires equivalent operations
and observable behavior through idiomatic host APIs.

Contract v1 is checked by `perl tools/check_generated_source_contract.pl` and the canonical local gate. It names
ten family roles, four pre-execution plan-rejection cases, stable generated-source errors, one direct result/trace/
identity fixture, the accepted eight-case subset, and the 105-case primary oracle. Backend-native APIs and source
syntax are expected; semantic roles and observations are not allowed to drift.

Outward compiled descriptors are closed: all four variants expose the exact `spec` / `functions` /
`dependency_regex_map` / `meta` projection, aligned model identities, and the canonical outer function record
defined by `capability_conformance/outward_descriptor_contract.json`.

Structured runtime diagnostics are also closed: every native variant exposes stable stage/detail plus available
spec/top/rule/handler attribution without string scraping; Rust retains its original string methods as adapters.

ADR `0023` sharpens that limitation: Rust exports `source_emitter` publicly, so equivalent source-emission
capability is required before Julia can claim complete user-visible feature parity. Deferral remains valid
scheduling and does not weaken the 105/105 interpreter correctness gate; it does keep the full-parity claim open.

`JULIA-BACKEND-PARITY.1.1` through `.4.2` are complete. The local Julia toolchain is Homebrew-managed:
`/opt/homebrew/bin/julia` reports Julia `1.12.6`, and the official Julia downloads page lists `v1.12.6` as the
current stable release. `Pkg` and `Test` work when Julia has a writable depot; under the managed harness, commands
can set `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot` to avoid writing precompile artifacts into
`~/.julia`. The Julia package now depends on `JSON3` for manifest and expected-JSON parsing. Global
`JuliaFormatter` and `JET` packages are not installed today, so formatter/linter commands are optional until a
scaffold or verification leaf commits them as dev dependencies.

Run the complete focused Julia gate from the repository root:

```bash
bash tools/run_julia_local.sh
```

It covers package tests, primary CLI help and retired-subcommand rejection, corpus-runner help, and full 105/105
corpus execution. The shared
core gate remains SDK-independent unless explicitly opted in:

```bash
LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

`LINKEDSPEC_JULIA_CMD` and `LINKEDSPEC_JULIA_DEPOT_PATH` select a non-default executable and writable depot.

The current Julia package layout is:

```text
julia/
  Project.toml
  Manifest.toml
  README.md
  src/LinkedSpecJulia.jl
  src/cli/LinkedSpecJuliaCli.jl
  src/corpus/CorpusManifest.jl
  src/spec/Ast.jl
  src/spec/Parser.jl
  src/spec/UserFunctionDefinitionShell.jl
  src/spec/Validator.jl
  src/action/ActionAst.jl
  src/action/ActionParser.jl
  src/action/ActionContracts.jl
  src/action/FunctionRegistry.jl
  src/compiler/CompiledSpec.jl
  src/parser/StagedParserRegistry.jl
  src/parser/UserFunctionDefinitionParser.jl
  src/runtime/Matching.jl
  src/runtime/Interpreter.jl
  src/trace/Trace.jl
  bin/linkedspec_julia.jl
  bin/corpus_runner.jl
  test/runtests.jl
```

The direct command surface is:

```bash
julia --project=julia -e 'import Pkg; Pkg.instantiate()'
julia --project=julia -e 'import Pkg; Pkg.test()'
julia --project=julia julia/bin/linkedspec_julia.jl --help
julia --project=julia julia/bin/linkedspec_julia.jl \
  --inline-spec $'Top::\n /x/\n E { return(hash("b", 2, "a", 1)) }\n' \
  --input x
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute
bash tools/check_julia_primary_cli.sh
```

The shown primary parse invocation prints `{"a":1,"b":2}` followed by one newline. Object keys are sorted at
every nesting level, independent of Julia `Dict` insertion order, and the serialized value is the direct top-rule
result rather than the corpus runner's one-level comparison wrapper. Newlines separate the example's statements;
semicolon is needed only between multiple statements on one physical line.

Operational failures have one of these first lines and exit `1`:

```text
linkedspec: parser compilation failed
linkedspec: input load failed
linkedspec: parser invocation failed
```

When a runtime failure carries structured context, stderr continues in stable order with the available
`owner_stage`, `summary`, `detail`, `spec_name`, `spec_path`, `top_rule`, and `rule_label` fields, then an `error:`
line. Compilation completes before `--input-file` is read, so an invalid spec is reported before a simultaneously
missing input file. Argument/selector/mode errors remain usage failures with exit `2` and the usage text.

Trace routing is independent of canonical result generation:

| Controls | stdout | trace file |
| --- | --- | --- |
| `--trace high` | trace, then JSON | none |
| `--trace high --trace-file run.log` | JSON only | trace (implicit `route`) |
| add `--trace-mode mirror` | trace, then JSON | the same trace bytes |
| add `--trace-mode stdout` | trace, then JSON | unchanged; truncated first only with `--trace-reset` |
| `--trace-mode route` without a file | JSON only | none; trace is discarded |

`--trace-reset` truncates a selected file before compilation even when the selected mode is `stdout` or the trace
level is `none`. `--trace-emoji` adds level-specific `🛑` / `ℹ️` / `🔎` / `🧭` / `🐞` / `🔥` prefixes to emitted
events; it does not cause a quiet trace level to emit.

The corpus commands validate `manifest.json`, case-count/name shape, missing/stale fixture directories, required
`input.spec` / `input.txt` / `expected.json` files, and expected JSON syntax over the checked-in 105-fixture corpus.
Bare `--execute` runs the complete manifest; named, offset, and limit selections remain available for diagnostics.
`julia/src/spec/Ast.jl` defines data records and JSON projection for
spec files, function definitions, source spans, staged parse jobs, rule headers/modes, body element variants, edge
targets, and fluent calls. `julia/src/spec/Parser.jl` exposes `parse_spec(...)`, which parses core `.spec` rule
paragraphs into those source AST types: headers/modes, regex slots, lifecycle blocks, action/blind-call edges,
fluent continuations, markers, comments, and block boundaries. `julia/src/spec/Validator.jl` exposes
`validate_spec(...)`, which validates parsed source ASTs for top-rule presence, duplicate labels/functions,
function registry collisions and reserved params, raw fallback lines, mixed edge families, grouped action blocks,
undefined references, regex-slot bounds, regex structure, and strict unused-rule behavior.
`julia/src/spec/UserFunctionDefinitionShell.jl` consumes the `function_definition` / `function_definition_error`
node shape produced by `specs/user_function_definition.spec`, validates source/body spans and staged sidecars,
normalizes `functions.<index>.body_source` parse-job paths, and strips function spans before rule parsing.
`julia/src/parser/UserFunctionDefinitionParser.jl` now exposes `parse_user_function_definition_asts(...)` and
`parse_spec_with_staged_user_function_definitions(...)`; these execute the checked-in definition spec over source
in memory, then reuse that projection. Direct `parse_spec(...)` remains rule-only rather than a Julia raw scanner.
`julia/src/action/ActionAst.jl` and
`julia/src/action/ActionParser.jl` expose `parse_action_block(...)`, `parse_action_statement(...)`, and
`parse_action_expression(...)` for typed helper/action structures: blocks, value-drop statements, calls, literals,
variables, direct/nested access, shape literals, assignments, receiver chains, trailing block arguments, block
values, structured controls, and raw fallback nodes. `julia/src/action/ActionContracts.jl` exposes
`resolve_action_block_contracts(...)`, `resolve_action_statement_contracts(...)`,
`resolve_action_expression_contracts(...)`, `canonical_action_helper_name(...)`, and
`is_known_action_ir_call_name(...)` for canonical helper/control contract records and generic
unknown-helper/raw diagnostics over those typed nodes. `julia/src/action/FunctionRegistry.jl` exposes ordered
`UserFunctionRegistry` entries, staged function-body parse-job queues, exact-arity user-call resolution, duplicate
name diagnostics, JSON projection, and immutable `body_ast` stitching; `ActionContracts.jl` can use that registry to
classify exact-arity user calls before helper fallback and diagnose wrong registered arities.
`julia/src/compiler/CompiledSpec.jl` exposes `compile_spec(...)`, `CompiledSpec`, `CompiledRule`,
`CompiledDependencyRegexState`, and `CompiledDescriptorState` for ordered compiled-rule state, dependency refs,
dependency-regex rows, mode metadata, lifecycle/action payload ASTs with registry-aware contracts, function registry
projection, and descriptor-shaped JSON with `julia_interpreter_rule` handlers marked `compiled_state_only`.
`parse_spec(...)`, `validate_spec(...)`, `compile_spec(...)`, function-shell projection/parsing, staged job
execution/stitching, and runtime execution accept the same optional caller-owned `LinkedSpecTraceEmitter`. Omitted
or disabled tracing is quiet; enabled low/medium events report balanced operation scopes and phase decisions through
the existing stdout/route/mirror/reset sink controls without changing spec, descriptor, or parse results.
`julia/src/runtime/Matching.jl` compiles stable zero-based regex alternatives and supports seek/consume selection,
full and compact capture vectors, named captures, zero-based code-unit spans, public character offsets,
line/column projection, cursor/capture anchors, separate entry/local match registers, and zero-progress detection.
Julia's native PCRE engine accepts the required named-capture, POSIX, flag, possessive, and recursive constructs
without a dialect-rewrite layer. `julia/src/runtime/Interpreter.jl` exposes `LinkedSpecRuntimeEngine`,
`runtime_parse(...)`, `runtime_execute(...)`, result/lifecycle/error records, and first execution over compiled
default/AND/OR/repetition families. It runs lifecycle order, action/blind children, `retv`, explicit returns,
narrow array/rule accumulators and capture reads, output projection, repetition bounds, zero-progress cutoffs, and
recursion guards in seek or consume mode. `.4.3.0` splits the broader evaluator into `.4.3.1` core
stores/captures, `.4.3.2` string/numeric,
`.4.3.3` array, `.4.3.4` hash, `.4.3.5` value/control/block/callback, and `.4.3.6` no-drift leaves. `.4.3.1` is now
implemented: scalar/array/hash stores, bare and typed snapshots, structural assignments/access, checked
no-autovivification nested writes, and entry/local capture maps/positions pass focused tests. `.4.3.2` is now
implemented too: current string/scalar and numeric helpers share canonical function/receiver dispatch, retain
regex flags, normalize JSON numbers, and return `nothing` for invalid arithmetic. `.4.3.3` is now implemented as
well: copied array helper/receiver pipelines, regex and split bridges, explicit flatten splicing, numeric reducer
terminals, typed split replacement, and updated-value end mutations pass focused tests. `.4.3.4` is now
implemented too: copied hash views and pure transformations, compatible receiver chains, statement-only named
set-key mutation, direct hash-index assignment, merge-slot resolution, explicit flat-style splicing, and nested-map
preservation pass focused tests. `.4.3.5` is now implemented too: expression-valued blocks with local returns,
attached/marker/inline controls, deterministic while guards, immediate helper/receiver with-blocks, scoped binding
restoration, and hash/array walk/map/reduce callbacks pass focused tests. `.4.3.6` owns final helper/value no-drift.
The closeout confirms runtime tests/status, mdBook contracts, live docs, and fact cards agree at 567
assertions; package status remains `runtime-value-control-tree`, and no runtime correction was required. `.4.4`
adds explicit LIFO cursor save/restore, entry/local anchor rewinds, character-based cursor/input helpers, and
earliest usable non-consuming boundary capture. Full tests pass with 581 assertions and status
`runtime-cursor-boundary`. `.4.5.0` splits diagnostics/trace into structured diagnostics, trace
controls/events/sinks, runtime instrumentation, and no-drift. `.4.5.1` implements exported neutral-field
diagnostic payloads on runtime exceptions while preserving successful output and richer child attribution.
`.4.5.2` implements trace levels/environment/config, event primitives, stdout/route/mirror sinks, parse-scope
routing, and traced entrypoints with default-quiet output preservation. `.4.5.3` implements internal rule, regex,
dispatch, lifecycle, recursion, cursor, and boundary events; `.4.5.4` closes final no-drift without a source
correction. `.5.1` is implemented through `julia/src/parser/StagedParserRegistry.jl`; `.5.2` now executes
registered user functions through `julia/src/runtime/Interpreter.jl`. It evaluates args before entering a fresh
scalar/array/hash store set, restores caller stores in `finally`, returns the final expression or first local
`return(...)`, composes compatible receiver chains, drops standalone results, and diagnoses exact-arity and
direct/mutual recursion failures. `.5.3` locks the neutral descriptor shape through runtime without a production
projection correction. `.6.1` adds the controlled corpus library surface described below; package status is now
`runtime-controlled-corpus`, and the full suite passes with 715 assertions. `.6.2.0` splits the manifest rollout
before behavior changes; `.6.2.1` bounded library/runner selection and reporting is active.

### Julia Controlled Corpus Execution

`execute_corpus_fixtures(...)` is the first executable Julia corpus surface. It deliberately composes existing
owners instead of creating a second parser or runtime:

1. `load_corpus_fixtures(...)` validates the format-1 manifest and loads every named fixture.
2. Each `input.spec` is parsed, validated/compiled, and executed by `LinkedSpecRuntimeEngine`.
3. Runtime `output` is compared structurally with the expected JSON wrapped exactly once.
4. Every fixture produces a result, even when earlier fixtures fail.

The one-level wrapper is important. If `expected.json` contains:

```json
{"body":" text ","cursor":10}
```

the required engine output is:

```json
[{"body":" text ","cursor":10}]
```

This matches the backend-neutral convention that the top-rule value occupies one output item. The fixture result
still exposes both `actual_value` (the object itself) and `actual_output` (the wrapped list).

A minimal controlled fixture directory looks like this:

```text
controlled-corpus/
  manifest.json
  boundary/
    input.spec
    input.txt
    expected.json
```

For example, `input.spec` can capture text up to a structural boundary:

```text
Top::
 /BEGIN/
 E {
   body = capture_until_boundary(Boundary)
   return(hash("body", body, "cursor", cursor_pos()))
 }

Boundary: /END/
```

The two statements in the multiline `E` block are separated by the newline. No line-ending semicolon is used:
semicolon is only an infix separator between adjacent statements on the same physical line.

Execute the corpus from Julia code:

```julia
using LinkedSpecJulia

execution = execute_corpus_fixtures("controlled-corpus")
println("passed: ", corpus_passed_count(execution), "/", length(execution.results))

for failure in corpus_failures(execution)
    println(failure.name, ": ", failure.failure)
end
```

For a traced controlled run:

```julia
execution = execute_corpus_fixtures(
    "controlled-corpus";
    trace_config = trace_config_enabled(LinkedSpecTraceDebug),
)

boundary = corpus_fixture_result(execution, "boundary")
for line in boundary.trace_lines
    print(line)
end
```

`CorpusFixtureExecutionResult` retains:

- fixture name and decoded expected JSON;
- actual value and wrapped output when runtime reached a result;
- match state and zero-based code-unit cursor;
- captured rendered trace lines when tracing was enabled;
- the structured `RuntimeDiagnostic` when execution produced one;
- failure text, or `nothing` on success.

Failure records distinguish parse, validation, compile, execute, no-match, output-mismatch, and unexpected
boundaries. `corpus_execution_passed(...)`, `corpus_passed_count(...)`, `corpus_failures(...)`,
`corpus_fixture_passed(...)`, and `corpus_fixture_result(...)` provide the common queries.

The optional `spec_parser` keyword remains a controlled parser-override seam. Ordinary calls try direct rule-only
`parse_spec(...)` first. If source parsing fails, the default path executes the checked-in user-function definition
spec and feeds its neutral nodes through staged body parsing. The three routed top-level function fixtures pass,
and the complete checked-in corpus is now 105/105 green after final exhaustive capability admission.

Native callers can use the source-driven composition directly:

```julia
using LinkedSpecJulia

spec_source = raw"""
fn normalize(value) { return(trim(value)) }

Top::
 /x/
 E {
   return(normalize(" ok "))
 }
"""

spec = parse_spec_with_staged_user_function_definitions(spec_source)
compiled = compile_spec(spec)
result = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x")

println(result.output)
```

`parser_spec_source = ...` may be supplied when an embedding application keeps an alternate compatible definition
spec in memory. The default resolves the repository-owned `specs/user_function_definition.spec`; neither path
requires a subprocess or a raw Julia function scanner.

#### Selecting bounded Julia corpus runs

Library callers can execute named fixtures in caller-supplied order:

```julia
execution = execute_corpus_fixtures(
    "rust/linkedspec-runtime/tests/corpus";
    case_names = ["proof_edge_array_literal", "proof_edge_hash_literal"],
)
```

Or select a zero-based manifest window:

```julia
execution = execute_corpus_fixtures(
    "rust/linkedspec-runtime/tests/corpus";
    offset = 0,
    limit = 10,
)
```

Named selection rejects missing and duplicate names and cannot be mixed with a window. Windows reject negative or
non-integer offsets, non-positive or non-integer limits, and offsets outside the manifest. A limit larger than the
remaining fixture count stops at the manifest end.

The corpus runner exposes the same bounded surface:

```bash
julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus \
  --execute --case proof_edge_array_literal

julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus \
  --execute --offset 0 --limit 10
```

Each selected fixture prints `PASS <name>` or `FAIL <name>: <detail>`, followed by a summary. Exit status `0` means
all selected fixtures passed, `1` means at least one selected fixture failed, and `2` means argument, manifest, or
selection validation failed. Options also accept `--flag=value` form, and `--case` may be repeated.

Omitting `--execute` validates the complete manifest. Bare `--execute` runs all 105 fixtures; offset-only execution
runs from that offset through the manifest end. Selecting a subset never bypasses complete manifest drift checks.

The rollout is explicitly recoverable. `.6.2.1` has landed named and bounded selection/reporting; `.6.2.2` proves
starter fixtures 0–39 green at 40/40; `.6.2.3` proves the surrounding non-function helper/control fixtures 40–67
green at 25/25 while routing three top-level function fixtures; `.6.2.4.0` measures shipped-spec/parser-smoke
fixtures 68–98 at 10/31 and splits their mechanism owners; `.6.2.4.1` then closes anonymous capture execution and
moves the window to 13/31. `.6.2.4.2.1` then adds eager logical helpers and moves it to 17/31 while routing one
helper-regex flag residual; `.6.2.4.2.3` then closes it and moves the window to 18/31. `.6.2.5` has since closed
the spec-defined top-level function shells, and final capability admission has expanded the full-manifest gate to 105/105.
Those are workload boundaries, not an assumption that Julia shares Dart's historical failure causes.

#### Julia starter corpus proof

The first shipped window is a permanent package regression:

```bash
julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus \
  --execute --offset 0 --limit 40
```

It reports 40 passes and zero failures, from `proof_edge_array_literal` through
`terse_2_2_5_2_attached_switch_blocks`. This proves the early proof-edge, autoexist, bare read/copy, assignment/
mutation, primitive, shape, block, and attached-control families against the checked-in expected JSON. No Julia
runtime correction and no fixture change was required. The package test locks the manifest count, both endpoints,
selected count, passed count, and empty failure ledger so later changes cannot silently lose that coverage.

The 40/40 result does not imply that later windows pass. The next proof closes the surrounding middle window.

#### Julia middle corpus proof

The middle non-function fixtures are permanent package regressions across three disjoint windows:

```bash
julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 40 --limit 17
julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 58 --limit 2
julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 62 --limit 6
```

The windows report 17/17, 2/2, and 6/6, for 25 passes and zero failures across helper, control, receiver,
assignment, with-block, and tree traversal behavior. No Julia runtime correction and no fixture change was
required. Manifest offsets 57, 60, and 61 are explicitly routed as
`terse_3_3_1_scalar_assignment_expressions`, `terse_3_3_4_assignment_expression_closure`, and
`terse_4_3_2_user_function_runtime`; their top-level `fn` source is now executed by `.6.2.5` through
`specs/user_function_definition.spec` and the existing staged body parser. The package regression locks all three
windows, their endpoints and counts, the empty failure ledger, and those exact routes; a separate three-case
regression now locks their exact outputs too.

#### Julia shipped-spec/parser-smoke split

The full final non-function window is measured before implementation:

```bash
julia --project=julia julia/bin/corpus_runner.jl \
  --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31
```

The initial result is 10 passes and 21 failures. Julia already passes both tclite cases, Lispish, both raw hlink
cases, portmap slice, regdef, VHDL library use, and the empty plugin/library smokes. The failures are split before
source changes:

- `.6.2.4.1` adds anonymous capture-boundary helpers and closes all three hlink delimiter cases. EBNF logging
  advances to the structural-output group under `.6.2.4.4`.
- `.6.2.4.2.1` owns logical helpers blocking four portmap cases and tablegrep; `.6.2.4.2.2` owns diagnostic-output
  helpers blocking simenv and history.
- `.6.2.4.3` owns three already-executing recursive top-rule output mismatches.
- `.6.2.4.4` owns EBNF/spec.spec structural outputs and must split again if independent mechanisms emerge.
- `.6.2.4.5` owns two lib_reader quote-normalization mismatches; `.6.2.4.6` later owns and closes final 31/31
  no-drift.

The checked-in expected JSON remains the Perl/Rust oracle. Dart's completed shipped-smoke facts are useful
mechanism references, but Julia leaves establish their own root causes rather than copying Dart's historical path.

The direct anonymous capture family now uses Julia's existing rule-local match register. `start_capture_slice()`
sets the origin; `capture_slice*` reads to the current match start, `*_until_cursor*` reads to the live cursor, and
`*_rest*` reads to input end. Location readers are character-based, and `capture_take*` advances the origin only
after a valid read. Focused Unicode/newline tests lock endpoint, length, position, line/column, and destructive
behavior. All three hlink delimiter fixtures pass; a permanent corpus regression preserves them and ensures EBNF
logging is routed as an output mismatch rather than an unsupported helper. At that boundary, the window is 13/31
and package status is `runtime-corpus-capture-boundaries`.

Julia logical `and`/`or`/`not` are eager value helpers: all arguments evaluate before truthiness composition. They
are not lazy branch constructs in this backend; use `if`/`switch` when skipped branches must remain unevaluated.
Julia applies its existing scalar/number/string/aggregate truthiness and Rust-compatible
empty arities (false/false/true). Three portmap cases plus tablegrep pass. `portmap_constant` reaches output
comparison but remains `?bare:` because helper `matches(..., /^\d/io)` passes Perl's no-op `o` flag to Julia
`Regex`; `.6.2.4.2.3` owns that precise compatibility bridge.

Helper regex literals now spend one strict compiler seam: `i`, `m`, `s`, and `x` reach Julia `Regex`; execution-
only `g` and Perl compile-once `o` are compile-time no-ops; unknown flags and invalid patterns still fail closed.
Both `matches(...)` and regex-delimiter `split(...)` use the seam. Portmap constant passes exact checked-in output,
and the window is 18/31 at that boundary.

At the historical `.6.2.4.2.2` boundary, diagnostic `print(...)` and `say(...)` concatenated evaluated values,
with `say(...)` adding a newline; `print_each(...)` walked an array with optional prefix and suffix text. Julia
then emitted these messages through a configured low-level trace sink, returned no parse value, and remained
quiet when tracing was absent or disabled. `simenv_multiline_value` reached unsupported `exit_now`, and
`ds_vhistory_version_entry` reached the known leading-trivia output mismatch. The permanent regression rejects
renewed unsupported-`print` failures. The full window remained 18/31, full tests passed with 780 assertions, and
status was `runtime-corpus-diagnostic-output`; later leaves closed both residuals. Current Julia diagnostic output
uses ADR `0042`'s separate caller-owned typed event sink and never low trace.

Recursive rule calls now carry a first-reset binding snapshot for explicit `set(array(...), ...)`,
`set(hash(...), ...)`, and explicit split-target replacement. Child exit restores the caller's prior typed binding,
while ordinary undeclared `push(...)`/append mutations remain caller-visible; registered user functions retain
their separate whole-store isolation. This closes the body-recursive, nested top-LX, and top-LX sequence fixtures.
The full window is 21/31, full tests pass with 785 assertions, status is
`runtime-corpus-recursive-rule-scope` at that boundary.

Action-edge child-push forms now give a compiled-rule first argument child-call precedence and reuse the current
edge's cached child result. `push(Child)`, `push(Child, target)`, `push(Child, index)`, and
`push(Child, target, index)` append whole or zero-based indexed values without re-searching the consumed token.
All four spec.spec smokes pass. Both EBNF cases now retain complete structures and are locked at quote-only
statement-mutation residuals under `.6.2.4.5.2`. The full window is 25/31, full tests pass with 793 assertions,
status is `runtime-corpus-action-edge-child-push` at that boundary.

`exit_now(...)` now terminates Julia parser flow immediately. Its optional first argument is evaluated as a
numeric status, with absent or nonnumeric status defaulting to `1`; the thrown runtime exception includes the
current rule and retains the established structured top/rule/spec diagnostic attribution. Simenv now executes
`exit_now(1)` in `begin_end_blocks`, proving the control helper while exposing its earlier statement-form
`substr(...)` mutation prerequisite. The full window remains 25/31, full tests pass with 801 assertions, status is
`runtime-corpus-exit-now` at that boundary.

Statement-context four-argument `substr(...)` / `regex_subst(...)` now mutates a bare Julia scalar target before
pure helper fallback. The strict helper compiler preserves `i`/`m`/`s`/`x`, applies global `g`, accepts no-op `o`,
and replacement text expands `$n` captures. Numeric `substr(value, start, width)` remains pure even when discarded.
Both EBNF, both lib_reader, and simenv fixtures now pass exact oracle output. The full window is 30/31, full tests
pass with 808 assertions, and status is `runtime-corpus-statement-mutation` at that boundary.

Julia's public in-memory `runtime_parse(...)` entrypoint now begins after only leading blank lines and leading `#`
comment lines, matching the Perl wrapper and Dart backend. A focused minimal proves the history boundary while an
ordinary scalar-held `payload[1]` still returns its indexed item. `ds_vhistory_version_entry` passes. The final
no-drift leaf adds one permanent complete-window test; the complete shipped-spec window is 31/31. Spec-driven
function-definition parsing then closes the three routed top-level function fixtures without a raw Julia scanner.
The full-manifest gate now executes all 105 fixtures in order with exact output and zero failures. Full tests pass
with 1,040 assertions and status is `runtime-corpus-primary-cli`.

### Dart Backend Commands

Run the focused Dart gate from the repository root:

```bash
bash tools/run_dart_local.sh
```

That command runs Dart formatting, analyzer checks, all 160 Dart tests,
shared Dart primary-CLI help, a bounded corpus-runner smoke, 61/61 default, 61/61 POSIX, and full 105-fixture corpus
execution. To include Dart in
the canonical local gate on a machine with a Dart SDK, opt in explicitly:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

Direct Dart commands live under `dart/`:

```bash
dart test
dart run bin/linkedspec_dart.dart --help
dart run bin/linkedspec_dart.dart --spec Lispish --input '(hello world)'
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute
```

Current Dart parity is interpreter-first and corpus-green. `DART-BACKEND-PARITY.7.2`
deliberately defers generated Dart source to a future source-emitter lane with its
own scaffold, generated family plan, direct structural-family execution proof, and
curated corpus subset. Dart's backend-local corpus CLI implementation closed in
`DART-BACKEND-PARITY.7.4`, and `DART-BACKEND-PARITY.7.5` closed the scoped
Dart milestone. The later strict-interface audit recorded the old primary command at 0/61.
`FUTURE-PARITY-BACKLOG.1.5.3.1` now passes the exact 29-case argument/loading/failure subset in both
default and POSIX environments while preserving `bin/corpus_runner.dart`. The new boundary is case-sensitive,
non-abbreviating, positional-free, strict UTF-8, deterministic for named/file/inline source resolution, and
compile-before-input phase ordered. `.1.5.3.2` now composes the existing staged parser, validator/compiler,
direct-value runtime, top-rule/global-mode controls, and recursively canonical JSON. `.1.5.3.3` adds the portable
CLI trace independently of rich Dart tracing and reaches 61/61 in both environments; `.1.5.3.4` makes both legs
recurring, proves the broader gate, and closes the Dart primary-command parent.

Dart
also has source-level AST/data types and staged parse-job sidecars that round-trip
through JSON with the Rust/mdBook field names. The Dart core `parseSpec(...)`
parser now produces those source AST types for rule paragraphs, headers/modes,
regex literals, lifecycle blocks, action/blind-call edges, fluent continuations,
markers, comments, and nested block boundaries, with tests over all checked-in
`specs/*.spec` files and rule-only corpus specs. Dart `validateSpec(...)` then
checks top-rule presence, duplicates, source-AST edge consistency, target
references/indexes, regex structure, malformed raw body lines, and strict-mode
unused rules. Dart also has the first function-shell projection layer:
`parseSpecWithUserFunctionDefinitionAsts(...)` consumes the
`function_definition` / `function_definition_error` nodes returned by
`specs/user_function_definition.spec`, validates source/body spans and staged
`body_payload` / `body_parse_job` sidecars, normalizes source-order parent paths
and parse-job ids, strips returned definition spans before rule parsing, and
attaches ordered `FunctionDefinition` records. This is not a Dart raw scanner for
`fn` source. The corpus runner now obtains the semantic node list by executing
`specs/user_function_definition.spec` through Dart runtime shell code and then
feeds those nodes through staged function-body projection.

Dart now also has a typed ActionIR parser seam. `parseActionBlock(...)`,
`parseActionStatement(...)`, and `parseActionExpression(...)` produce structural
nodes for helper/action code: action blocks, value-drop statements, calls,
positional and keyword arguments, primitive and regex literals, variables,
indexed/nested access, array/hash shape literals, scalar/array/hash/nested
assignments, expression-valued blocks, attached `if`/`when`/`elseif`/`else` /
`otherwise`, `while`, `switch`/`case`/`default`, receiver-dot fluent chains, and
trailing block arguments. Unsupported expressions remain explicit `raw_perl`
nodes for diagnostics. Dart also has ActionIR contract resolution:
`resolveActionBlockContracts(...)`, `resolveActionStatementContracts(...)`, and
`resolveActionExpressionContracts(...)` walk the typed nodes and record current
canonical helper/control contracts for calls, receiver methods, structural
assignments, controls, nested arguments, block values, shapes, and access
expressions. Non-current helper-looking calls produce generic diagnostics rather
than host-language fallback. Dart also has the first user-function registry seam:
`UserFunctionRegistry.fromSpec(...)` / `fromFunctions(...)` preserve ordered
`FunctionDefinition` records, expose their staged function-body parse jobs, keep
`body_payload`, `body_parse_job`, and any stitched `body_ast`, and let the ActionIR
contract resolver classify exact-arity user-function calls before helper fallback.
Wrong-arity registered calls diagnose as user-function arity errors.

Dart now also has the minimal staged parser registry in
`dart/lib/src/parser/staged_parser_registry.dart`. `executeStagedParseJobs(...)`
normalizes and stable-sorts jobs by parent AST path, source span, and job id,
resolves `actionir-body.spec` to `builtin:actionir-body.spec`, loads the fixed
built-in adapter digest, compiles top rule `action_block`, and executes the body
text through Dart's ActionIR block parser. `dispatchFunctionBodyParseJobs(...)`
and `parseSpecWithStagedUserFunctionDefinitionAsts(...)` stitch the returned
`action_block` JSON into each function definition's `body_ast`. This is still
the narrow function-body provider, not general public `parse_job(...)` authoring
or recursive staged queues.

Dart now also has a compiled-state model in `dart/lib/src/compiler/compiled_spec.dart`.
`compileSpec(...)` validates source ASTs by default and returns `CompiledSpec`
state with `definition_order`, `compiled_rule_order`, `rules_by_label`,
`redefined_rule_labels`, carried user-function registry data, per-rule regexes,
dependency refs, mode metadata, action/blind edges, lifecycle/plain/edge
`ActionBlock` payloads, and registry-aware ActionIR contract results. Its
`CompiledDependencyRegexState` derives structured child-regex dispatch data, and
`CompiledDescriptorState` projects the public descriptor shape with `spec`,
`functions`, `dependency_regex_map`, and `meta`.

Dart now has the first runtime matching layer in `dart/lib/src/runtime/matching.dart`.
`RuntimeRegexAlternation` consumes ordered compiled-rule regex lists and supports
`seek` versus `consume` matching while preserving stable alternative indexes.
`RuntimeRegexMatch` records capture-only groups, named captures, code-unit spans,
char-offset and line/column projections, and zero-width/progress checks.
`RuntimeMatchRegisters` keeps entry and local match state separate for child
dispatch and tracks the parser cursor.

Dart also has the first runtime rule interpreter in `dart/lib/src/runtime/interpreter.dart`.
`LinkedSpecRuntimeEngine` consumes `CompiledSpec` state and executes default,
AND, OR, and repetition rule families with action-edge and blind-call child
dispatch, entry/local match handoff, lifecycle blocks, explicit returns, `retv`,
accumulator collection, bounded repetition, zero-progress cutoffs, and recursion
cutoffs. Normal runtime entry now derives cursor discipline and structural
composition directly from the entered rule: AND consumes and sequences, while
OR/default seeks and chooses. A nested action edge, blind edge, direct call, or
recursive call re-enters through the child rule and therefore cannot inherit the
parent's cursor policy. The same derivation is used by in-memory, loaded, and
normalized-`SpecFile`-JSON execution, and rule trace scopes expose the policy
spent at each entry. Generated-source v1 remains behind its explicit global/
compact-pipe compatibility adapter until Dart generated-source v2 migration.
Its core ActionIR evaluator now also preserves scalar, array, hash,
null, boolean, and number shapes through assignment and wrapper snapshots;
supports `array(...)`, `hash(...)`, `copy(...)`, `set(hash(...), ...)`,
hash-index mutation, nested reads, non-numeric map keys, regex literals as
values, and nested value-path assignment with no-autovivification failure
behavior; and exposes the named/map/length/start/end `entry_*` / `match_*`
capture helper family. It now also executes current string/scalar helpers,
explicit `str_*` lexical comparisons, numeric arithmetic/reducer/comparison
helpers, numeric word aliases, arithmetic/comparison symbol callees, and
compatible string/number receiver chains. It also executes array helper family
breadth, bare array working-variable receiver chains, regex split/filter
bridges, delimiter-first `join_values`, array numeric reducers, and
updated-value array end mutations. It also executes hash helper family breadth,
bare hash working-variable receiver chains, statement/value mutation boundaries,
direct hash-index assignment values, bare typed base/overlay `merge_hash`, and explicit
flat-style hash splicing inside `hash(...)`. It also executes expression-valued
blocks with block-local `return(...)`, attached and inline structured controls,
helper/receiver `with` trailing blocks, and hash/array tree traversal receiver
callbacks with scoped callback bindings. It also treats empty array/hash returns
as successful non-null rule matches, uses child-rule match bits for blind
dispatch, and executes marker-form `if(...)` / `elseif(...)` / `else()` /
`endif()` statement chains as grouped branches. It also preserves assignment
expressions inside helper arguments, supports plain fallback values in inline
`if(...)`, evaluates single-argument numeric aggregate reducers through
aggregate-aware reads, and follows scalar-held list/map readback for
bare `name` and `copy(name)` through that same typed value. It now also executes explicit cursor
controls: `save_cursor()` / `restore_cursor()` for stack-based cursor restore,
`rewind_match_start()` / `rewind_entry_start()` for lifecycle-anchor rewinds,
`capture_until_boundary(rule[, ...])` for non-consuming structural boundary
capture, and char-based cursor/input helpers such as `cursor_pos`,
`cursor_rest`, `input_slice`, and `input_end_pos`. Dart runtime failures now
carry a structured `RuntimeDiagnostic` on `RuntimeInterpreterException`, with
the neutral diagnostic fields `type`, `stage`, `owner_stage`, `summary`,
`detail`, `top_rule`, `rule_label`, `handler_source_label`, and optional
`spec_name` / `spec_path`. Successful parse output remains unchanged.
Dart now also has the trace-control layer: ordered trace levels,
`LinkedSpecTraceConfig`, structured event/scope primitives, stdout/routed-file/
mirror sinks with reset/truncate behavior, and `parseWithTrace(...)` /
`executeWithTrace(...)` entrypoints that preserve parse output while emitting a
parse-scope event. Dart runtime tracing now also emits rule scopes, regex
match/no-match decisions, action/blind child-dispatch decisions, lifecycle block
marks, cursor-control marks, recursion-cutoff decisions, and
`capture_until_boundary(...)` source-boundary marks while keeping untraced
execution output-compatible. The diagnostics/trace no-drift sweep is closed.
Dart also executes registered exact-arity user-function calls before helper
fallback: arguments are eager in the caller, params bind into fresh
function-local scalar/array/hash stores, results come from the final expression
or local `return(...)`, receiver chains can continue from returned values,
standalone calls discard their results, and direct/mutual recursion is
diagnosed. Dart also preserves staged user-function descriptor shapes across
parsed functions, compiled registry jobs, descriptor records, and runtime output.
Dart cursor descriptor v1 is also current: root metadata identifies
`linkedspec-rule-local-cursor-v1`, and each rule projects authored family,
derived cursor policy, normalized ownership, and exact ordered semantic edge
rows from compiled state. Direct, normalized `SpecFile`-JSON, and file-loaded
projections agree; the descriptor carries no independent cursor field and has
no decoder that could override runtime behavior. Generated-source v2 is now
current too: fresh emitted modules retain only ordered label/family rows, derive
all ten cursor/structure policies, and reject v1 before payload reconstruction
with exact contract identities and `.spec` regeneration guidance.
Dart's public execution boundary is now rule-local too. `LinkedSpecRuntimeEngine(compiled)`,
`loaded.createEngine()`, corpus execution, and the staged function parser expose no caller-global mode. The
primary command omits the option and request-trace field, while retired `--parse-mode` invocations return the
exact structural-migration usage error. One exact 15-role consumer now composes native, normalized, loaded,
descriptor, emitted/generated, trace, mixed/recursive, structural, removal, primary, and all portable diagnostic
roles once. Complete Dart cursor proof is 271 package tests, the current 65-case primary manifest in both
environments, and 105/105 corpus fixtures. Neutral governance was 67 files, 4 complete / 4 pending, and 39
mutations at Dart admission; parent `.9.1.5` is closed.

Julia's first cursor-convergence slice is now current at the typed frontend/compiler boundary. `RuleMode("Pipe")`
is OR/default rather than AND, while compact `&` remains AND; `rule_family(...)` and `cursor_policy(...)` expose
the immutable derivation. The parser retains complete-line or header-rest bare references as
`BareEdgeBodyElementKind`, including nullable authored indices, target groups, blocks, fluent chains, source text,
and forward declarations. Lifecycle tokens keep lexical priority, and indexed explicit blind calls retain their
index long enough to fail validation instead of silently losing the suffix. Whole-spec validation derives blind
ownership for bare AND members and action ownership for bare OR/default members, rejects the six governed invalid
forms with exact portable stage/code/fields, and compiled state lowers valid bare members into its existing typed
blind/action tables. The contract-driven Julia suite passes 353 assertions over all 36 family rows, all 18 edge
rows, all six ownership sets, JSON roundtrips, and physical-line boundaries. Runtime `.9.1.6.2` now adds 104
execution assertions across all 36 families on live/normalized routes, all eight parent-child mechanisms, both
structural replacements, loaded-default execution, recursion, and trace attribution. Normal AND consumes and
sequences; OR/default seeks and chooses; every child entry rederives. Descriptor `.9.1.6.3` is cursor v1: root metadata
has no global mode, and each rule projects normalized family, derived policy, ownership, and exact ordered
ownership/target/child-index/block/fluent rows. Direct, normalized `SpecFile`-JSON, and loaded descriptor bytes
agree across a focused 809-assertion suite, including all valid and invalid neutral edge cases. Generated-source
`.9.1.6.4` now emits v2/format 2 with the same minimal label/family plan, derives all five seek/five consume
policies, rejects v1 before payload reconstruction, and removes the private v1 adapter. Public option removal
`.9.1.6.5` now removes engine state plus engine/loader/corpus/primary overrides. Legacy dynamic API spellings fail
before input/user code with `prepare_options/parse_mode_override_removed`; the primary flag fails at usage exit 2,
help and request trace omit the field, and `--top-rule` remains independent. Low-level seek/consume matcher
primitives remain. One exact 15-role consumer now composes native, normalized, loaded, descriptor, emitted/
generated, trace, mixed/recursive, structural, removal, primary, and diagnostic roles once. Complete Julia passes
3,291 package assertions, the ten-family real-process checker, the shared 65-case primary manifest twice, and
105/105 corpus fixtures. Neutral governance is 67 files, 5 complete / 3 pending, and 44 mutations. Cursor parent
`.9.1.6` is closed.
Dart corpus parity has started with controlled manifest fixtures and now has safe
named/bounded execution selection for shipped-corpus batching. The first 40
manifest fixtures, the non-`fn` middle fixtures, and the three top-level `fn`
fixtures pass in bounded execute mode.
The remaining shipped-spec/parser-smoke window is split after a diagnostic run
and is now 31/31 green. The basic regex-dialect bridge, helper/action bridge,
recursive/default-mode parser-smoke bridge, portmap result-shape bridge, and
hlink delimiter/capture bridge are done; the helper mutation/text-normalization
bridge is also done, the legacy accumulator bridge closes `regdef_nested_register_fields`, and the public-parser
leading-trivia bridge closes `ds_vhistory_version_entry`. Final parser-smoke no-drift closeout, bounded
structural regex work, routed top-level `fn` corpus-shell execution, and the full shipped 105-fixture Dart corpus
gate are done; the next Dart leaf wires that green gate into the local verification story.

### Step 6: Validate Against the Test Corpus
Run your backend against the manifest-backed corpus under
`rust/linkedspec-runtime/tests/corpus/`. The corpus root has a `manifest.json`
with `case_count` and the ordered `cases` list; every manifest entry has an
`input.spec`, `input.txt`, and `expected.json`. Your backend is compliant with
the current corpus gate when it produces structurally equivalent output for
every manifest entry, and its runner rejects missing fixture directories or
stale extra fixture directories.

For the Dart backend, the focused local gate is:

```bash
bash tools/run_dart_local.sh
```

The core local CI gate remains independent of Dart SDK availability by default; set
`LINKEDSPEC_RUN_DART=1` when invoking `tools/run_ci_local.sh` to include the Dart gate.

The checked-in Rust corpus is kept green while parity work lands incrementally. It now has
105 fixtures, including the `with(...) { ... }` helper, `.with() { ... }` receiver trailing block case, hash-tree traversal receiver block case, array-tree traversal receiver block case, and six exhaustive capability cases; the two minimal shipped `tclite.spec` cases restored by the
default-mode repetition parity work; the shipped `Lispish.spec` `lispish_x_y` case now
migrated to direct nested access; the first `hlink_substitution` raw-string cases plus the
JSON-safe `{abc}` curly-brace delimiter case and the neutral bracket/mixed delimiter cases;
`lib_reader.spec` scalar-attribute and
comma-list attribute cases; `portmap.spec` bare, bit, slice, constant, and concatenation
cases; `ebnf.spec` expression-rule and logging-annotation payload cases; four `spec.spec`
smokes for minimal rules, action edges, user-function definitions, and comments; seven
RTL/plugin/legacy safety smokes covering `regdef`, `tablegrep`, `simenv`, `vhdl`,
`ds_vhistory`, empty `pplugin`, and empty `tkgui`; terse receiver-chain fixtures for
arrays, hashes, strings, numbers, aggregate wrapper quoting, block-valued receivers, and array-tree traversal;
numeric word aliases; arithmetic/comparison symbol callees; the terse bare-read `name`
fixture for scalar reads, scalar mutation targets, and scalar-held shape payloads;
explicit string comparisons; assignment-expression fixtures; and the shared Perl/Rust
user-function runtime fixture; plus recursive top-rule/body value fixtures for wrapper-body
recursion, nested top-rule `LX` recursion, and top-rule sequence recursion.
`RUST-PARITY.7.4` finalized the corpus guard: the generator writes
`manifest.json`, and the Rust runner fails malformed manifests, duplicate case
names, missing manifest entries, or stale extra fixture directories. The richer
legacy/plugin mismatches above remain follow-up blockers until a narrower parity
owner promotes them safely.

## Architecture Overview

```
.spec file
    │
    ▼
┌─────────────────────────┐
│  Compiler (language-     │
│  specific but spec-      │
│  driven — see spec.spec) │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Parsed .spec +          │  ← typed AST/IR, never raw textual helper rewrites
│  helper/action AST       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  ActionIR Lowering       │  ← Backend-neutral (helpers → canonical events)
│  (100+ helpers, 10       │
│   families)              │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  HandlerIR               │  ← The decoupling seam
│  (10 variant kinds,      │
│   structured AST)        │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Backend Emitter         │  ← YOUR CODE HERE
│  (Rust / Dart / Julia /  │
│   Lua)                   │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Runtime                 │  ← Language-specific runtime
│  (regex engine, memory   │
│   model, I/O)            │
└─────────────────────────┘
```

## What the Perl Reference Provides

The Perl implementation is the **reference** — the canonical behavioral oracle.
It provides:

- A working compiler pipeline you can study for architecture understanding.
- `spec.spec` — a self-hosted grammar that can bootstrap a new compiler.
- An active `fn name(args) { ... }` definition surface owned by `spec.spec` and projected
  through the descriptor `functions` registry. The Perl reference currently uses a
  temporary pre-bootstrap extraction bridge; do not copy that bridge as the language
  contract. The accepted MVP is exact-arity, pure value/block functions with fresh
  function-local scope, no implicit caller capture, and registry resolution before
  unknown-helper fallback. Calls execute in value positions and compatible receiver
  chains; registered standalone calls compute and discard through `VALUE_DROP`. Recursion
  and unsupported function-body forms are diagnostics, not raw fallback.
- The Rust backend's parsed and compiled state records the same top-level function
  registry shape with parsed body `CodeBlock` values, and its runtime resolves registered
  calls before helper fallback with fresh function-local stores, receiver-chain
  continuation, standalone discard, and recursion diagnostics. The accepted MVP stops at
  explicit-paren, braced `fn` definitions; alternate spellings, omitted zero-arg parens,
  brace-less forms, statementful/caller-mutating functions, recursion support,
  closures/lambdas/currying, and namespaces remain deferred.
- `t/phase0_regression.t` — comprehensive regression tests.
- Phase 0 baseline showing all 21 shipped specs compile at `language_agnostic_ready_ratio == 1.0000`.

## What You Must Build

1. **`.spec` parser** — reads `.spec` files and produces parsed rule entries.
   Can be bootstrap-driven (hardcoded grammar) or self-hosted (parse spec.spec
   with itself, once bootstrapped).

2. **Staged parse-job model** — records source-provenance payload text, parser spec id,
   optional top rule, parent AST path, payload kind, result insertion policy, and failure
   behavior. Parser resolution must be deterministic and diagnostics must report both the
   selected next-stage parser and the original parent source span.

   Once implemented, the portable authoring marker is `parse_job(text_expr, options)`.
   It creates a marker value plus sidecar metadata rather than executing the next parser
   inline.

3. **Staged parser registry and queue** — resolves parser spec ids deterministically,
   caches compiled next-stage parsers by content/version/capability fingerprints,
   dispatches jobs in stable queue order, isolates runtime contexts, stitches results,
   and diagnoses cycles.

4. **Spec import/composition graph** — once implemented, loads file-scope `import` and
   `include` directives as parsed `.spec` dependencies with aliases, structured namespace
   merges, cycle diagnostics, source provenance, and descriptor fingerprints.

5. **Helper/action AST parser** — parses lifecycle/action helper code into typed
   expression and statement nodes. Calls, literals, variables, blocks, direct
   access, assignments, and receiver-dot chains must be represented structurally.
   Text-to-text helper rewriting is not a conforming design for new backends.

6. **User-function registry and resolver** — records top-level `fn name(args) { body }`
   definitions as validated AST-backed records before runtime. The registry must preserve
   definition order, expose definitions by name, reject helper/rule/reserved-name
   collisions, and resolve exact-arity value calls before unknown-helper fallback.

7. **Compiler** — transforms parsed entries and helper/action AST nodes into
   HandlerIR nodes. You can reuse the ActionIR lowering approach, but the input to
   lowering is structured AST/IR rather than raw helper source text.

8. **HandlerIR emitter** — consumes HandlerIR nodes and produces runnable code
   in your target language. Must handle all 10 variant kinds.

9. **Runtime** — the execution engine:
   - Regex engine with position tracking (equivalent to `//gcp` and `\G` anchoring).
   - Accumulator model (arrays, hashes, scalars).
   - Lifecycle execution engine (I/LS/LE/E/EX/IT/LX ordering).
   - Explicit cursor controls: `save_cursor()` / `restore_cursor()` stack
     semantics plus `rewind_match_start()` / `rewind_entry_start()` anchor
     rewinds.
   - Zero-width/lookahead boundary support through
     `capture_until_boundary(rule[, ...])` for non-consuming structural boundary
     detection and capture.
   - Zero-progress guard.

10. **Test harness** — runs `tests/corpus/` entries and compares output to
   `expected.json`.

## Practical Notes

### Regex Engine
The biggest implementation dependency. LinkedSpec requires:
- Position-tracked matching (set/query current match position).
- Ungrounded matching (match anywhere) and anchored matching (match at position).
- Identification of **which** alternative matched in a group.
- Capture groups (indexed and named).

If your target language's regex engine doesn't support embedded code position
tracking, you may need to iterate alternatives individually rather than
compiling a combined alternation.

### Memory Model
LinkedSpec uses mutable working variables (scalars, arrays, hashes) within
rule scope. These are assignment-backed, not functional. Your runtime needs
a variable store per rule invocation.

### Determinism
All operations must be deterministic. Specifically:
- No random number generation.
- Hash key iteration must be sorted (not insertion-order or random).
- First-match-wins for OR dispatch.

## Specification Index

| Document | Location | What it defines |
|---|---|---|
| Multi-backend ADR | `docs/decisions/0006-multi-backend-vision.md` | Vision, lockstep contract, reach matrix |
| Formal `.spec` Grammar | `docs/linkedspec-book/src/appendix/formal-grammar.md` | Accepted `.spec` syntax |
| HandlerIR Spec | `docs/knowledge/handler-ir-design.md` | HandlerIR node structure and emitter contract |
| Helper Contract Catalog | `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` | Every helper's behavioral contract |
| Runtime Semantics | `docs/linkedspec-book/src/appendix/runtime-semantics.md` | Parse modes, lifecycles, dispatch |
| Test Corpus | `rust/linkedspec-runtime/tests/corpus/` | Manifest-backed language-neutral compliance tests |

## Handoff Checklist

Before starting a new backend, verify:
- [ ] You've read all six specification documents above.
- [ ] You understand the `.spec` language syntax (formal grammar).
- [ ] You understand the runtime execution model (runtime semantics).
- [ ] You can implement all 100+ helpers (helper catalog).
- [ ] You can implement a HandlerIR emitter for all 10 variant kinds.
- [ ] You have a regex engine capable of position-tracked alternation matching.
- [ ] You've studied the test corpus format and know how compliance is measured.
- [ ] You understand that `.spec` files are the universal contract — no
      per-backend dialects.
