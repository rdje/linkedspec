# LinkedSpec Lua Backend

This directory contains the native Lua backend. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg.

Current status: repository-owned module/test/command scaffold, strict corpus IO,
typed source/provenance AST data, permissive rule-level source parsing, a typed
structural ActionIR parser, current-name ActionIR contract resolution, and an
ordered user-function/body-job registry with fresh invocation frames. Typed
compiled rule/dependency/payload state and exact outward descriptors are also
available in memory. A minimal staged registry now executes the governed ActionIR
body jobs and immutably stitches `body_ast`. The runtime resolves registered fixed-v1
calls before helper fallback, evaluates caller arguments once in order, executes copied
function-local stores, restores callers, and returns ordinary composable values.
Native PCRE2 matching supplies stable seek/consume,
captures, Unicode positions, and entry/local match registers. The first
compiled-rule interpreter executes rule modes, edges, lifecycle blocks,
repetition, and direct result channels entirely in memory.
Runtime failures now carry typed neutral `RuntimeDiagnostic` payloads on the
`RuntimeInterpreterException.diagnostic` field. Optional `spec_name` / `spec_path`
engine identity, top and deepest-rule attribution, Lua handler identity, exact
top-selection/input/lookup/execution stages, deterministic JSON projection, and
unchanged successful results pass on PUC Lua and LuaJIT.

```lua
local engine = linkedspec.runtime_engine(compiled, {
  spec_name = "Example",
  spec_path = "specs/Example.spec",
})
local ok, value = pcall(linkedspec.runtime_parse, engine, input)
if not ok and linkedspec.is_runtime_interpreter_error(value) then
  local diagnostic = linkedspec.interpreter.to_json(value.diagnostic)
  io.stderr:write(diagnostic.summary, " [", diagnostic.handler_source_label, "]\n")
end
```

Native tracing is opt-in and caller-owned. Ordered levels use the exact
none/low/medium/high/full/debug thresholds; immutable configs can route typed
enter/exit/decision/mark/dump/log events to stdout, a resettable/appending file,
or both. `runtime_parse(...)` / `runtime_execute(...)` accept a `trace` emitter
in their options table, while the `_with_trace` entrypoints construct one from
config. Disabled or absent tracing stays quiet, and successful result JSON is
unchanged. The runtime emits balanced parse/rule scopes plus exact regex,
action/blind dispatch, recursion, lifecycle, cursor, source-boundary, and
governed mark/capture events. The later minimal staged registry validates and stable-sorts exact function-body jobs,
records the governed ActionIR-body provider/digest/cache identity, parses exact body text, and immutably stitches
`body_ast`. Fixed-v1 calls require that staged AST, fail closed on source/AST drift, and carry typed function-owned
arity, keyword, recursion, and staging diagnostics. The following variadic-state slice preserves the exact
fixed-v1/variadic-v2 signature union through shell, AST, staged jobs, registry, contracts, and compiled state;
minimum/unbounded resolution is active. Runtime then copies every evaluated argument, binds fixed prefixes normally,
and copies extras into one fresh typed rest array. The following metadata slice preserves final-only
`callback: codeblock` declarations through shell, typed AST, staged payload/job, registry, and compiled state.
Attached and parenthesized contextual forms normalize to the same zero-positional `codeblock_argument`; harrays
remain harrays. Runtime then executes the deferred block in the current isolated function frame, keeps registered
functions and governed helpers ahead of the contextual slot, restores the outer caller, and returns an ordinary
composable value. Missing/wrong-kind callbacks, nonzero contextual calls, and active recursion stay typed.
Portable native loading now exposes typed named/exact-path requests, load options, resolved/loaded values, and
structured pipeline errors. It checks cwd exact, cwd suffix, and direct declared roots in deterministic order,
selects the first regular file without recursion or implicit roots, reads bytes in process, and strictly preserves
UTF-8 text. Automatic function parsing now resolves repository-owned `user_function_definition.spec` by one exact
module-relative path, validates and compiles it once, executes it over caller source, and feeds its typed output
through the existing Unicode projector and body dispatcher. Both ABIs pass 151/151; public status is
`native-spec-defined-functions-v1`. Loaded-source composition now carries that path through explicit validation,
compilation, and source-identified engine construction. Both ABIs pass 153/153 with public status
`native-spec-pipeline-v1`; outward descriptors, full-pipeline trace, and generated source remain later owners.

```lua
local request = linkedspec.named_spec_request("Demo")
local options = linkedspec.spec_load_options({
  cwd = ".",
  search_roots = { "specs" },
})
local loaded = linkedspec.load_and_compile_spec(request, options)
assert(loaded.loaded.resolved.request.requested == "Demo")
assert(loaded.loaded.source_text ~= nil)

local engine = loaded:create_engine({ parse_mode = "seek" })
local result = linkedspec.runtime_parse(engine, "input")
```

Use `load_spec(...)` when only exact decoded text is required. `load_and_compile_spec(...)` additionally runs the
automatic spec-owned function parser, validates the composed source, compiles it, and returns a typed
`LoadedCompiledSpec`. Its `loaded` field retains the request, resolved path, origin, and exact source text; its
`compiled` field is ordinary backend-native compiled state. `create_loaded_spec_engine(loaded, options)` is the
function-form equivalent of `loaded:create_engine(options)`. Both copy the options table, attach `spec_name` only
for a named request, and attach the resolved `spec_path` for either request kind.

Failures after decoding retain the same `SpecPipelineError` type and add the neutral stages `parse_spec`,
`validate_spec`, and `compile_spec` with codes `spec_parse_failed`, `spec_validation_failed`, and
`spec_compile_failed`. Existing inline `parse_spec_with_staged_user_function_definitions(...)`, `compile_spec(...)`,
and `runtime_engine(...)` composition remains available and unchanged.

Top-level functions can now be parsed and staged directly from source without caller-supplied nodes:

```lua
local source = [[
fn normalize(value) { return(value.trim()) }

Top::
 /x/
]]

local spec = linkedspec.parse_spec_with_staged_user_function_definitions(source)
assert(spec.functions[1].name == "normalize")
assert(spec.functions[1].body_ast.kind == "action_block")

local metadata = linkedspec.user_function_definition_parser_metadata()
assert(metadata.spec_origin == "path_exact")
assert(metadata.build_count == 1)
```

`parse_user_function_definition_asts(source)` exposes the lower-level typed node batch. The bundled grammar is
cached after its first successful native parse/validation/compile; no caller search root and no raw `fn` scanner
participates. Parser construction/execution/output failures use `UserFunctionDefinitionParserError`, while
projection and staged-dispatch failures retain their existing typed owners.

```lua
local config = linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
  linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
  "linkedspec.trace.log"
))
local result = linkedspec.runtime_parse_with_trace(engine, input, config)
```

`trace_config_from_environment(...)` recognizes `LINKEDSPEC_TRACE_LEVEL`
(falling back to `LINKEDSPEC_DUMP_VERBOSITY`), `LINKEDSPEC_TRACE_FILE`,
`LINKEDSPEC_TRACE_MIRROR_STDOUT`, `LINKEDSPEC_TRACE_RESET_FILE`, and
`LINKEDSPEC_TRACE_EMOJI`.

The minimal staged function-body API consumes the typed definition nodes returned by
`specs/user_function_definition.spec`, projects them into the source AST, dispatches each exact
`body_parse_job`, and returns a new spec whose functions carry neutral `body_ast` JSON:

```lua
local spec = linkedspec.parse_spec_with_staged_user_function_definition_asts(
  source,
  definition_nodes
)
assert(spec.functions[1].body_ast.kind == "action_block")

local dispatch = linkedspec.dispatch_function_body_parse_jobs(pre_dispatch_spec)
local first = linkedspec.staged_parser_registry_to_json(dispatch.results[1])
assert(first.resolved_spec_id == "builtin:actionir-body.spec")
assert(first.cache_key.content_digest == linkedspec.ACTION_IR_BODY_ADAPTER_DIGEST)
```

`execute_staged_parse_job(...)` and `execute_staged_parse_jobs(...)` expose the lower-level provider queue;
`stitch_function_body_parse_jobs(...)` returns only the immutably stitched spec. This boundary intentionally
supports only `actionir-body.spec` / `action_block`; registered user-function execution is the next runtime layer.

Deterministic scalar/string helpers include lazy fallback, definedness/
emptiness, Unicode trim/length/substrings, literal transforms/predicates,
lexical comparisons, Unicode 17.0.0 full default casing, portable scalar-to-
text coercion, strict PCRE2-backed `matches`, pure literal/regex/Unicode split,
statement scalar regex mutation, explicit array split replacement, and receiver chains. Bare typed bindings are
uniform, and retired aggregate selectors reject at compiled-state admission. Canonical scalar numeric helpers use
one strict finite-decimal evaluator for governed arity, invalid/null handling, rounding, signed modulo, and result
normalization. Numeric word aliases, arithmetic/comparison symbol callees, and integer/float/bare-scalar receiver
chains share that evaluator; number-returning links compose and comparisons terminate later links. Strict copied-
array sum/avg/median/range/min/max reducers work in explicit, bare-binding, and terminal array receiver forms.
`array(...)` and literals evaluate left-to-right; only explicit `flat`/`flat_array` calls or terminal receivers
splice into their parent, while ordinary arrays and `copy(...)` remain nested copied values. `concat_arrays`
returns a fresh concatenation. Copied `take`/`drop`/zero-based `slice`, lexical `sorted`, `reversed`, scalar-text
`contains`/`index_of`, and stable first-occurrence `uniq` work in function and receiver chains without mutating
their source. Delimiter-first `join_values`, literal/PCRE2 `split_each`, PCRE2 `filter_match`, trim/filter/case
pipelines, and all seven Perl-reference dropped transform rebindings share those copied values.
`split_tagged_records(source, delimiter, tag, fields...)` reuses literal/PCRE2 split policy, evaluates every input
once, and returns fresh `[tag, item, fields...]` records whose carried values are copied. Direct and receiver forms
compose with array terminals. Harray construction now makes generic `flat` preserve copied array/harray identity,
supports copied direct and receiver `flat_hash`, preserves ordinary nested map fields, and splices only explicit
direct or terminal flat ASTs. Explicit harray flattening into `array(...)` or `[...]` emits deterministic sorted
key/value pairs. `count_keys`, lexical `sorted_keys`, copied values in the same key order, and presence-based
`has_key` work through functions and receivers; sorted arrays continue through array helpers, while count and
membership are terminal. Wrong-kind/missing sources return `0` or `[]`, and null-valued fields remain present.
Copied `merge_hash`, value-form `set_key`, `rename_key`, `drop_keys`, and `pick_keys` preserve nested values,
support bare typed operands and compatible receivers, keep sources unchanged, and isolate saved results. Later
merge arguments override earlier keys. Lua deterministically lets the renamed old value replace an existing
destination, matching Perl/Julia; Dart/Rust differ, so portable specs avoid that collision until backlog `.5`.
Standalone `set_key(target, key, value)` and direct `target[key] = value` share a kind-checked mutation seam:
absent targets become harrays, incompatible existing values report neutral fields, and direct assignment returns
an independent updated snapshot. Assigned/function/receiver `set_key` remains pure. The Lua gate passes 112/112
on both PUC Lua 5.4 and LuaJIT, while all 55 scalar numeric v1 cases still match Perl,
Rust, Dart, and Julia exactly. All 34 non-callback array names and six numeric terminals are closed under `.4.3.4`;
all 13 ordinary harray names close at 103/103 through `.4.3.5.5`.
`walk_leaves`/`map_leaves`/`reduce_leaves` remain separately owned by active parent `.4.3.6`. Audit `.4.3.6.0`
splits eager expression blocks, inline and statement controls, current built-in final blocks/`with`, and tree
callbacks. `.4.3.6.1` now executes ordinary non-pair `{ ... }` values once, yields their final expression, catches
block-local `return`, preserves empty/keyed harray precedence, and continues yielded receivers. `.4.3.6.2` adds
lazy inline `if`/`switch`, selected block payloads, one-time switch subjects, literal bare case labels, generic
arity diagnostics, and assignment/fluent-return composition. `i`/`elif` remain marker aliases and
`when`/`otherwise` remain attached-block aliases rather than inline values. `.4.3.6.3.1` now executes exactly one
attached or marker if-family branch, preserves nested marker ranges, empty branches, and block-local return, and
reports orphaned/malformed chains with typed keyword/reason/rule fields. Broader alias/shape combinations accepted
by some backends are non-portable pending backlog `.5`. `.4.3.6.3.2` executes attached and marker switch chains:
the subject runs once, the first scalar-equal case or one default owns the selected range, bare labels stay
literal, nested markers remain bounded, and malformed/orphaned structures stay typed. Lua follows Perl switch
comparison for now: null equals empty text, booleans spell as `0/1`, and aggregates are not scalar-comparable.
Boolean/number and aggregate comparison drift in other backends is owned by backlog `.5`; portable specs avoid
those case boundaries. Portable marker switches also keep every executable statement inside a branch: Lua joins
Rust/Dart/Julia in skipping outside-range statements, while Perl executes them; backlog `.5` owns that boundary.
`.4.3.6.3.3` executes attached `while(condition) { ... }`: the condition re-evaluates before each body, body
mutations feed the next condition, false initially runs zero bodies, and return follows its containing action or
expression-block boundary. The configurable guard allows exactly `max_iterations` bodies, rechecks the condition,
then raises typed code/keyword/kind/limit/rule fields if it is still true. Lua follows Perl by treating `next()`
inside the body as inner-loop continue. Exact-limit and `next()` behavior differs elsewhere and remains backlog
`.5`. `.4.3.6.4` now executes metadata-governed helper/receiver `with` in both attached and parenthesized final-
block form. The optional value or receiver evaluates first; Lua copies it into the temporary uniform `value`
binding, copies the result, restores every prior/absent private store after success, block-local return, or error,
and continues compatible receiver chains. Tree callbacks are split by `.4.3.6.5.1.0`: the reproduced reference
append-RHS scope collision is repaired in `.4.3.6.5.1.1`; `.4.3.6.5.1.2` then adds one atomic copied/restored
`value`/`key`/`path`/`depth`/`acc` frame and sorted harray `walk_leaves`/`map_leaves`/`reduce_leaves`. Arrays remain
leaves, root depth is 1, walk/map keep hash-family continuation, reduce is terminal, and both ABIs pass 113/113
with the exact Perl callback result. `.4.3.6.5.2` then shares the dispatcher with array roots: Lua offsets become
zero-based `index`/`path` values, nested arrays recurse in source order, harrays stay leaves, and typed walk/map/
reduce behavior raises both ABIs to 114/114. No-drift/dependency handoff `.4.3.6.6` closes the parent.
`.4.3.7.1` adds `input_text`, `input_len`, `input_slice`, all three input-end coordinates, the five live-cursor
views, and explicit `save_cursor` / `restore_cursor` / entry/local rewind controls. Internal state remains a UTF-8
byte offset, while every public position, length, slice boundary, line, and column uses Unicode character units.
Cursor saves form one parse-scoped LIFO stack; an empty restore or a rewind without its corresponding match is a
no-op; rewinds preserve match snapshots and synchronize the live/register cursor so consume-mode continuation
starts at the new position. Exact arity errors remain typed. `.4.3.7.2` adds all 16 anonymous capture helpers over
the same byte-safe register state. Stable reads end at local-match start, the live cursor, or input end; advancing
forms update the rolling rule-local boundary only after a valid read. Public positions and lengths remain Unicode
character values, returned text and numbers continue through compatible receivers, and `start_capture_slice()` is
a void mutation. Both ABIs pass 116/116. `.4.3.7.5` now resolves bare/quoted usable boundary rules into a separate
compiled-alternation cache, always seeks regardless of surrounding parse mode, captures before the earliest match
without consuming it, falls back to EOF, and leaves the cursor unchanged when every rule is unresolved or
regex-free. PUC Lua and LuaJIT pass 117/117. Zero arguments are neutral pending cross-backend normalization under `.5`.
Complete named-mark `.17.4` adds parse-scoped rule-label buckets, byte-safe storage, Unicode public
positions/locations, symbolic names, and the exact seven helpers through native plus serialized execution at
119/119 on PUC Lua and LuaJIT. `.17.5` admits them into the aligned 246-name shared inventory and independently
checks all 122 public Perl contracts. `.4.3.7.3` extends the same store across current/input/anonymous/copy
writers, match-start/live-cursor/input-end/two-mark stable and valid-only advancing spans, and both anonymous/named
bridges. Public positions and lengths use Unicode characters; missing/reversed spans are neutral; anonymous
`capture_take()` and named `capture_take(name)` remain distinct overloads. Both supported runtimes pass 120/120.
`.4.3.7.4` now compiles `@capture_slice`, `@capture_from_here`, `@move_pos`, and `@mark(name)` into typed events
owned by the preceding regex slot. Events execute after that slot's action/child dispatch and before `LE`, through
the same anonymous boundary and named-mark store; same-slot action reads therefore see old state and later slots
see the update. Native and serialized-source Unicode timing, the checked-in EBNF `@move_pos`, and malformed-marker
diagnostics pass 121/121 on PUC Lua and LuaJIT. Exhaustive `.4.3.7.6` derives 62 unique current capture/mark/input/
cursor/control calls and proves exact agreement across contracts, interpreter dispatch, and focused execution
sources, plus four placement-marker spellings. Parent `.4.3.7` is closed. `.4.3.8` now evaluates diagnostic
`print`/`say`/`print_each` arguments once left-to-right and delivers ordered Unicode-safe typed events through an
optional per-parse caller sink. With no sink it stays quiet; events never alter parse values; `exit_now` remains
immediate typed control. Both ABIs pass 122/122. Exhaustive `.4.3.9.0` probing partitions all 246 names into 230
handled, thirteen intentional statement/receiver-only surfaces, and missing eager `and`/`or`/`not`; logical repair
`.4.3.9.1` first passes 123/123. Permanent `.4.3.9.2` now proves exact 233+13 ownership for all 246 names, direct
`call(rule)` result/`retv`/cursor behavior, and public status `runtime-helper-value-control`; both ABIs pass 125/125
and parent `.4.3` closes. Planning-only `.4.4.0` separates structured runtime failures, trace controls/sinks,
runtime events, and closeout; structured diagnostics `.4.4.1` pass 126/126, trace controls/sinks `.4.4.2`
pass 128/128, runtime instrumentation `.4.4.3` passes 129/129, and no-drift `.4.4.4` closes the scoped runtime
parent. Planning `.5.1.0` splits staged dispatch, fixed/variadic runtime, contextual-codeblock metadata/runtime,
and closeout. Minimal staged dispatch `.5.1.1` is complete at 130/130: `actionir-body.spec` resolves to the governed
built-in identity, jobs execute in stable order with neutral cache/compiled records, and `body_ast` is stitched
without mutating the source spec. Fixed-v1 runtime `.5.1.2` is complete at 133/133: registry-first calls use eager
ordered caller arguments, fresh copied local stores, final/local returns, standalone value drop, returned-value
receiver chains, and typed failure fences. Variadic-v2 state `.5.1.3.1` is complete at 136/136: fixed v1 retains
only params/arity, variadic v2 retains only its exact six-field signature, sidecars/staged copies stay identical,
and resolution accepts the fixed-prefix minimum through an unbounded maximum. Runtime rest binding and descriptor
projection remain separately owned. Fresh typed rest-array execution `.5.1.3.2` is complete at 139/139: arguments
evaluate once in caller order, fixed prefixes bind normally, extras are copied into an isolated array, the exact
neutral fixture passes, and minimum/keyword failures stay typed. Contextual final-codeblock metadata `.5.1.4.1` is
complete at 142/142: exact `parameter_kinds` survives shell/staged/registry/compiled state and both contextual
spellings normalize to one zero-positional typed argument without harray promotion. Runtime `.5.1.4.2` executes
that argument with current function-frame bindings, cleanup-safe outer restoration, static callable precedence,
chainable results, and typed callback failures at 146/146. No-drift `.5.1.5` closes parent `.5.1`; portable native
resolution/loading `.5.2.1` consumes all shared 14/9/4 cases. Automatic spec-defined function parsing `.5.2.2`
resolves and compiles the bundled grammar once, executes it in process, and composes the existing projector/body
dispatcher without a raw scanner; the dual-ABI gate is 151/151 with status
`native-spec-defined-functions-v1`. Loaded-source `.5.2.3` then adds typed compiled results, exact source identity,
neutral parse/validate/compile failures, and named/path runtime-engine attribution; the dual-ABI gate is 153/153
with status `native-spec-pipeline-v1`. Native-loading no-drift `.5.2.4` is active. Full frontend/compiler/function/
staged trace remains `.5.3` after general staged functions and native loading exist. Generated Lua
preservation/execution remains `.8.1-.8.4`. Cross-backend output routing/formatting is owned by
`FUTURE-PARITY-BACKLOG.5.1`; logical truthiness/arity and Perl keyword lowering are separately owned by `.5.2`.

Lua now executes `and`, `or`, and `not` as eager boolean value helpers: all authored arguments evaluate once
left-to-right before `runtime_truthy` composition. Empty calls return false, false, and true respectively. Current
Lua truthiness still treats scalar `"0"` as false and empty arrays/harrays as true; portable specs should use
explicit predicates at disputed boundaries until `FUTURE-PARITY-BACKLOG.5.2` aligns all backends. The logical
proof first raised both ABI suites to 123/123; the complete helper closeout now passes 125/125 and diagnostics/
trace planning `.4.4.0` is complete. Structured runtime diagnostic `.4.4.1` raises the suite to 126/126; native
trace controls/sinks `.4.4.2` raise it to 128/128, runtime instrumentation `.4.4.3` raises it to 129/129, and the
minimal staged function-body registry `.5.1.1` raises it to 130/130.
Fixed-v1 registered-function execution `.5.1.2` raises it to 133/133.
Exact variadic-v2 signature-state preservation `.5.1.3.1` raises it to 136/136.
Fresh typed variadic-v2 execution `.5.1.3.2` raises it to 139/139.
Final contextual-codeblock metadata `.5.1.4.1` raises it to 142/142; dynamic contextual execution `.5.1.4.2`
raises it to 146/146, while
explicit callable codeblock values remain future `FUTURE-PARITY-BACKLOG.11.7`. Zero/variadic
flatten calls, negative selection counts, newer-backend dropped-transform omissions, invalid-join differences,
and implicit child-push expression-result drift remain explicitly owned by `FUTURE-PARITY-BACKLOG.5` rather than
hidden as settled parity.
Lua currently follows Perl-oracle condition truthiness, including false scalar `"0"` and truthful empty
array/harray reference values. Cross-backend truthiness normalization is explicitly owned by backlog `.5`.
Ordinary assignment is eager: `callback = { return("later") }` stores the scalar `"later"`, not an inert
codeblock. A trailing block remains structural until its signature-governed callable consumes it. For example,
`with("x") { return(value) }` and `with("x", { return(value) })` are the same built-in call, as are
`"x".with() { return(value) }` and `"x".with({ return(value) })`. Future explicit first-class codeblocks use
`{|params| ...}`.

A user function declares the same contextual intent explicitly:

```text
fn apply(value, callback: codeblock) {
  return(callback())
}

attached = apply("hello") { return(value.uppercase()) }
parenthesized = apply("hello", { return(value.uppercase()) })
```

Both results are `"HELLO"`. The contextual block takes no positional arguments and reads the function's current
dynamic frame, so `value` above is the copied function parameter. Writes to other bindings remain visible to
later statements in that function invocation; all function-frame stores restore when it returns. A keyed brace
value remains a harray and fails the declared slot rather than being promoted. Registered functions and governed
helpers retain static precedence over a colliding callback-parameter name. Explicit `{|params| ...}` values and
general bound codeblock calls are not part of this Lua milestone.
Typed current-rule accumulators and otherwise-absent compiled-rule arrays share the bare binding seam. Action-edge
`.push`/`.push(target)` and block `push(Child[, target][, index])` reuse the cached child result, select zero-based
items when requested, and retain neutral wrong-kind diagnostics.
Source validation and optional strict-unused checks are also available.
Top-level function nodes returned by `specs/user_function_definition.spec` can
be projected and composed with rule parsing. The staged registry now dispatches and stitches their bodies, and
fixed-v1, variadic-v2, and contextual-final-block calls execute through the native runtime. Portable named/path
loading, corpus execution beyond the landed helper families, the primary parser CLI contract, outward function
descriptors/full-pipeline trace, and generated source retain their later owners.

Run the local gate from the repository root:

```bash
bash tools/run_lua_local.sh
```

The gate builds separate PUC Lua and LuaJIT PCRE2 modules into one disposable
`/private/tmp/linkedspec-lua-native.*` directory and removes it on exit. To load
the native module manually for PUC Lua, build into caller-owned storage and
provide both module paths:

```bash
native_dir=$(mktemp -d /private/tmp/linkedspec-lua-native.XXXXXX)
bash tools/build_lua_native.sh puc "$native_dir"
LUA_PATH="$PWD/lua/src/?.lua;$PWD/lua/src/?/init.lua;;" \
LUA_CPATH="$native_dir/?.so;;" \
  lua -e 'local linkedspec = require("linkedspec"); print(linkedspec.backend_name())'
rm -rf "$native_dir"
```

The backend has no LuaRocks or global Lua package dependency. Runtime matching
requires a C compiler, `pkg-config`, PCRE2 headers/library, and Lua development
headers for the selected ABI. Validate the checked-in corpus without executing
it:

```bash
lua lua/bin/corpus_runner.lua --corpus rust/linkedspec-runtime/tests/corpus
```

The primary CLI remains a developer stub and exits `2`. The corpus runner loads
strict UTF-8 source/input/JSON and explicitly reports that execution is not yet
implemented.

Construct and project a typed source node in memory:

```lua
local linkedspec = require("linkedspec")
local ast = linkedspec.spec_ast

local span = ast.source_span({ line_start = 1, line_end = 1 })
local mode = ast.and_bounded_rule_mode({ min = 1, max = 2 })
local header = ast.rule_header({
  label = "Top",
  is_top = true,
  mode = mode,
  rest = "/x/",
  line = 1,
})
```

`ast.to_json(node)` returns explicitly typed JSON tables suitable for
`linkedspec.json.encode(...)`; `ast.from_json("SpecFile", value)` reconstructs
the typed tree. Codeblocks are explicit AST variants, never inferred from Lua
table layout.

Parse universal rule source directly in memory:

```lua
local parsed = linkedspec.parse_spec([[
Top::
 /x/
 E {
   set_key(meta, "a", 1)
   return(meta)
 }
]])

assert(ast.top_rule(parsed).header.label == "Top")
assert(linkedspec.validate_spec(parsed) == nil)
```

Physical newlines separate statements. A semicolon separates multiple
statements on one physical line; the final statement on that line needs no
trailing semicolon. Both single- and double-quoted strings are preserved while
the parser scans nested blocks. Lua strings may contain arbitrary bytes, so
`parse_spec` requires strict UTF-8 as the host representation of Unicode source
text. `parse_spec` parses rule paragraphs only; the automatic composed API executes the spec-owned top-level
function grammar before delegating the stripped rule source to `parse_spec`.
`validate_spec(parsed, { strict_syntax = true })` adds the
portable strict unused-rule check; ordinary validation already checks tops,
duplicates, function/helper collisions, raw syntax, edge families/targets/
slots, and regex structure.

Function-shell semantics are not raw-scanned by Lua. The automatic path executes the cached owning grammar and
stages body ASTs directly:

```lua
local staged = linkedspec.parse_spec_with_staged_user_function_definitions(source)
```

Given an explicitly typed node array returned by another owning-grammar invocation, the lower-level seam remains:

```lua
local parsed = linkedspec.parse_spec_with_user_function_definition_asts(
  source,
  definition_nodes
)
```

`project_user_function_definition_asts(...)` exposes the pre-parse projection,
and `definition_nodes_from_user_function_definition_output(...)` normalizes the
owning spec's nested output shapes. Character-index spans, source/body text,
staged payloads, and body parse jobs are checked and normalized. The jobs remain
undispatched and `body_ast` remains absent only at this explicit projection boundary; the automatic staged API
dispatches and stitches them.

Parse helper/action source without rewriting it to Lua:

```lua
local action = linkedspec.parse_action_block([[
set_key(meta, "b", 2)
set_key(meta, "a", 1)
set_key(meta, "stmt_hash", 4)
value_set = set_key(meta, "value_only", 9)
receiver_set = meta.set_key("receiver_only", 5)
]])

assert(action.kind == "action_block")
assert(#action.statements == 5)
assert(action.statements[4].expr.kind == "assign_scalar")
```

`parse_action_block`, `parse_action_statement`, and
`parse_action_expression` return metatable-typed structural records. Their
typed JSON form is available through
`linkedspec.action_ast.to_json(node)`. Calls, literals, regexes, arrays,
harrays, codeblocks, access, assignments, attached controls, and receiver
chains remain language-neutral AST nodes; unsupported expressions remain
explicit `raw_perl` nodes for the next diagnostic layer.

Single quotes are universal DSL syntax, so this form is accepted directly:

```lua
local call = linkedspec.parse_action_expression([[substr(value, '"|\s', "", go)]])
assert(call.args[2].value.value == '"|\\s')
```

For every callable that accepts a final codeblock, the attached and explicit
forms have the same final `block_value` argument:

```text
func_helper_method(value) { return(value) }
func_helper_method(value, { return(value) })

value.func_helper_method() { return(value) }
value.func_helper_method({ return(value) })
```

Resolve the typed tree against the exact governed current helper/control surface:

```lua
local resolution = linkedspec.resolve_action_block_contracts(action)
assert(resolution.ok)

local alias = linkedspec.resolve_action_expression_contracts(
  linkedspec.parse_action_expression("gt(value, 0)")
)
assert(alias.contracts[1].canonical_name == "num_gt")
assert(alias.contracts[1].family == "numeric")
```

The statement and expression resolver entrypoints are
`resolve_action_statement_contracts` and
`resolve_action_expression_contracts`. `canonical_action_helper_name(name)`
canonicalizes current aliases, and `is_known_action_ir_call_name(name)` shares
the same exact 246-name source used by function validation. Resolution walks
nested arguments, shapes, blocks, access indexes, controls, assignments, and
receiver methods. Unknown calls produce `unknown_helper`; structural parser
fallback produces `raw_perl`. Neither path invokes a Lua global.

That 246-name table is the governed public-current cross-backend inventory; it is intentionally narrower than
every historical Perl diagnostic contract mentioned by the public helper reference. Lua resolves the seven
documented complete-mark helpers—`mark_entry_start/end`, `mark_match_start/end`, `mark_line`, `mark_col`, and
`clear_mark`—through the shared inventory while retaining a separate exact family view, as Dart and Julia do.
Coverage independently checks all 122 public Perl contracts and rejects nine classified non-public names.
The closed native capture/cursor family comprises 62 unique call names; all 62 are classified, dispatched, and
present in focused execution sources. Placement-sensitive markers remain a separate four-spelling grammar surface.

Build the concrete registry directly from a typed spec or function list:

```lua
local registry = linkedspec.user_function_registry_from_spec(parsed)
local resolution = registry:resolve_call("normalize", 1)

assert(resolution.matched)
assert(registry:body_parse_jobs()[1].function_name == "normalize")
```

The registry snapshots ordered definitions and preserves body source, payload,
parse job, and optional stitched ActionIR AST. Pass it as
`{ function_registry = registry }` so exact-arity user functions resolve before
helper fallback. `stitch_function_body_ast(spec, job_id, body_ast)` returns a
new typed spec and never mutates the source tree.

`prepare_user_function_invocation(registry, name, evaluated_values, active_names,
options)` accepts already-evaluated scalar, array, harray, or codeblock values.
It creates a fresh data-only frame, defensively copies aggregate/codeblock
arguments, and never captures caller stores or Lua closures. Exact arity is
mandatory; unknown names, arity drift, ambiguous/cyclic values, and recursion
are typed registry errors.

After `dispatch_function_body_parse_jobs(...)` stitches each governed `body_ast`,
compiled fixed-v1 functions execute directly through the normal runtime:

```text
fn pair(left, right) { [left, right] }
fn normalize(value) { return(value.trim()) }

Top::
 /x/ E {
   pair("a", "b").join_values("|").return()
 }
```

The result is `"a|b"`. Function calls are expression values: their result may feed
array, harray, string, or numeric receiver families, while a standalone call still
executes its arguments/body and discards only the final value. Positional arguments
evaluate once left-to-right in caller scope. Parameters and locals live in fresh copied
scalar/array/harray stores, so aggregate mutation inside a function cannot mutate the
caller and undeclared caller bindings are not captured. The body result is its final
expression or a function-local `return(expr)` payload; nested nonrecursive calls work.

Registered keyword arguments diagnose as
`user_function_keyword_arguments_unsupported`; exact-arity drift uses
`user_function_arity_mismatch`; direct and mutual recursion use
`user_function_recursion` with the full cycle. Missing or mismatched staged bodies fail
closed before body execution. Variadic signatures, declared contextual final codeblocks,
descriptor/full-pipeline trace admission, generated Lua, and primary CLI promotion remain
their separately owned later layers.

Compile a typed spec and inspect either effective state or the exact shared
outward descriptor without invoking a runtime:

```lua
local compiled = linkedspec.compile_spec(parsed)
local top = compiled:rule("Top")
local descriptor = compiled:to_descriptor_json()

assert(top.mode_metadata.is_repetition)
assert(descriptor.meta.descriptor_model == "compiled_descriptor_state")
assert(descriptor.spec.Top.handler.kind == "lua_interpreter_rule")
```

`compile_spec(spec[, options])` validates by default, snapshots caller-owned
source, preserves source definition order, and derives deterministic effective
rule order. Each compiled rule carries mode metadata, regex patterns,
dependency refs, action/blind edges, lifecycle/plain payloads, parsed ActionIR,
and registry-aware contracts. Child regex slots are resolved into structured
`CompiledDependencyRegexState`; no regex is executed at this boundary.

`compiled:to_json()` projects the internal effective state.
`compiled:to_descriptor_json()` and `linkedspec.to_descriptor_json(compiled)`
project the executable shared contract with exactly `spec`, `functions`,
`dependency_regex_map`, and `meta`. The descriptor retains the
`lua_interpreter_rule` / `compiled_state_only` compiled-handler boundary;
callers execute that state through the separate runtime engine.

Compile ordered rule patterns and match directly in memory:

```lua
local alternatives = linkedspec.compile_runtime_regex_alternation(top)
local match = alternatives:match("prefix évalue", 0, "seek")

if match then
  print(match.alternative_index, match:text(), match:char_start())
end
```

The adapter is a narrow repository-owned PCRE2 binding, built separately for
PUC Lua and LuaJIT. LPeg is deliberately not used: it constructs PEG patterns
but does not parse the governed PCRE dialect. The matcher accepts inline/scoped
flags, POSIX classes, named captures, possessive quantifiers, recursion, and
fixed-width positive/negative lookbehind (including `spec.spec`'s `(?<!\\)`),
plus other PCRE2 syntax without a Lua-specific rewrite. Both PUC Lua and LuaJIT
load ABI-specific bindings to that same PCRE2 semantic provider.

`seek` selects the earliest match at or after the UTF-8 byte cursor, breaking
same-position ties by the lower source alternative. `consume` anchors at the
cursor. Match records retain full group slots, compact participating captures,
named captures, byte/code-unit and Unicode-character spans, 1-based line/
column, and explicit zero-width state. `runtime_match_registers(input)` creates
immutable cursor/capture state; `with_local_match(...)` and `enter_child()` keep
entry and local matches separate. Invalid patterns, input bytes, offsets, and
modes are typed runtime-regex failures.

Execute compiled rules directly in the host process:

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
local engine = linkedspec.runtime_engine(compiled, { parse_mode = "seek" })
local result = linkedspec.runtime_parse(engine, "ab")

assert(result.matched)
assert(result.value == "child")
assert(result.output[1] == "child")
assert(result.cursor_code_unit == 2)
```

Diagnostic helpers are opt-in at the embedding boundary:

```lua
local events = {}
local result = linkedspec.runtime_parse(engine, "ab", {
  diagnostic_sink = function(event)
    events[#events + 1] = event
  end,
})

-- RuntimeDiagnosticOutputEvent fields are helper_name, rule_label, and message.
assert(linkedspec.interpreter.node_type(events[1]) == "RuntimeDiagnosticOutputEvent")
```

`print(value, ...)` concatenates eager scalar-text values; `say(value, ...)` adds one newline;
`print_each(array, prefix[, suffix])` emits one event per item, with an empty default suffix. The callback runs
synchronously in message order. Omit `diagnostic_sink` for quiet execution; helper arguments still evaluate and
`result.value` / `result.output` stay structural. A non-function sink is a typed runtime boundary error.

`runtime_parse(...)` and its `runtime_execute(...)` alias execute default,
AND, OR, single, optional, plus/star, and bounded families. Action and blind
edges dispatch children through `retv`; lifecycle payloads run in applicable
`I`, `LS`, `LE`, `IT`, `EX`, `LX`, `E` order. Repetition has explicit bounds,
zero-progress and recursion cutoffs, and `next()` advances to the next rule
iteration. Rule-local writes are restored when a child returns. `return(...)`
preserves false as distinct from `json.null`, while `exit_now(status)` raises a
typed immediate runtime error. The result exposes the direct value, neutral
one-element output wrapper, byte/code-unit and character cursors, and lifecycle
events. Helper/value breadth beyond the landed families remains owned by
`.4.3`. That breadth is split before implementation: `.4.3.1` supplies
four-kind stores/access and entry/match reads; `.2.1.1` supplies non-case pure
scalar/string helpers, `.2.1.2` supplies Unicode casing, and `.2.1.3` supplies exact
cross-variant scalar-to-text coercion. Regex/split/mutation `.2.2` is split by
mechanism; `.2.2.1` supplies helper-regex values, flags, and `matches`; `.2.2.2` supplies pure split; `.2.2.3`
supplies scalar substitution; `.2.2.4` supplies explicit array split replacement; `.2.2.5` closes focused/public
no-drift and routes broader shipped proof to phase 6; `.3`
numeric; `.4` arrays; `.5` harrays; `.6` eager codeblocks/controls/contextual built-in blocks/
tree callbacks; `.7` capture/mark/input/cursor state; and `.8` diagnostic output are complete; `.9` exhaustive
no-drift is active. A broad leaf may split again before code if its
mechanism cannot remain signoff-sized.

Runtime values have exactly four public kinds: `scalar`, `array`, `harray`, and
`codeblock`. `runtime_value_kind(value)` reports those names; null, booleans,
numbers, and strings are scalar values. Aggregate and codeblock reads return
defensive snapshots. Bare typed bindings carry every value kind: `set(items, [])`
rebinds `items` as an array, `set(meta, {})` rebinds `meta` as an harray, and
runtime value type governs later reads and mutations. Retired aggregate selectors
reject at compiled-state admission. Array indexes are zero-based at the DSL
boundary and harray keys are strings. Direct and nested access returns `json.null`
for a missing or wrong-kind path; nested assignment never creates missing
intermediate containers.

```lua
local result = linkedspec.runtime_parse(linkedspec.runtime_engine(
  linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /(?<name>\w+)=(\d+)/
 I {
   items = [{ "name" : "old" }]
   items[0]["name"] = "new"
 }
 E {
   return({
     "item" : items[0]["name"],
     "captures" : entry_groups(),
     "named" : match_map(),
     "start" : entry_start_pos()
   })
 }
]]))), "key=42")

assert(linkedspec.runtime_value_kind(result.value) == "harray")
assert(result.value.item == "new")
assert(result.value.captures[1] == "key")
assert(result.value.named.name == "key")
```

The `entry_*` and `match_*` families expose text, zero-based compact capture
groups, named captures and presence, copied maps, Unicode character lengths/
spans, and 1-based start/end line and column values. With no match, text/group/
length/span reads are `json.null`, groups/maps are typed empty containers,
presence is `0`, and line/column reads use the `(1, 1)` origin.

Pure string helpers execute through the same evaluator in function and receiver
form. Coalescing is lazy, preserves `false` and zero, and `coalesce_nonempty`
skips only null and the empty string. `trim` recognizes Unicode White_Space;
`length` and `substr` count Unicode codepoints rather than UTF-8 bytes. Prefix,
suffix, containment, removal, and `replace_substr` are literal operations;
`str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` are lexical comparisons.

```lua
local result = linkedspec.runtime_parse(linkedspec.runtime_engine(
  linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 E {
   return(" node-name_end ".trim()
     .replace_substr("-", "_")
     .rm_prefix("node_")
     .rm_suffix("_end")
     .cat("!"))
 }
]]))), "x")

assert(result.value == "name!")
```

Lowercase/uppercase use repository-generated Unicode 17.0.0 full Default Case
Conversion data rather than Lua's byte/locale-sensitive case functions. `cat`
also has one portable typed contract across all five backends: strings remain
unchanged, booleans become `"1"`/`"0"`, finite numbers use stable shortest
decimal text with zero normalized to `"0"`, and null/aggregate/codeblock
arguments make the expression return null. The executable neutral fixture
covers function and receiver form; explicit codeblock-call syntax remains in
the future-parity backlog.

`matches(value, /pattern/flags)` and receiver `.matches(...)` reuse the native
PCRE2 owner in seek mode. `i`, `m`, `s`, and `x` affect compilation; `g` and
`o` are accepted predicate no-ops. Null/non-text inputs, non-regex patterns,
unknown flags, and invalid patterns return false. `matches` is terminal in a
string receiver chain.

`split(value, delimiter)` and string receiver `.split(delimiter)` return fresh
typed arrays. Literal delimiters preserve leading/trailing empty fields; an
empty literal delimiter splits Unicode scalars; regex delimiters reuse the
strict helper flag adapter and make explicit progress for zero-width matches.
Invalid/non-text inputs return an empty array. Downstream array receiver methods
remain owned by the later array-helper family.

Dropped four-argument `substr(target, pattern, replacement, flags)` and
`regex_subst(...)` calls mutate a bare scalar target. String and regex patterns
share strict PCRE2 compilation: `g` selects global replacement, `i/m/s/x`
compile, and `o` is a no-op. `$0` and `$n` expand per match, including
Unicode-safe zero-width global replacement. Unknown flags and invalid patterns
raise rule-attributed runtime diagnostics. Numeric `substr(value,start,width?)`
remains a pure value even when discarded.

Dropped `split(target, source, delimiter)` replaces the bare typed array target
with a copied split result. Literal and regex delimiters share the pure split
policy, including preserved empty fields. Two-argument split remains a pure
value expression, and the source scalar is never mutated.

Array constructors and literals evaluate each element once from left to right.
Ordinary array values remain nested; only explicit `flat(...)` / `flat_array(...)`
calls, including a receiver chain ending in `.flat()`, splice one level into the
surrounding constructor. `copy(...)`, `flat_array(...)`, and `concat_arrays(...)`
all return fresh values, so later binding updates do not change saved results.

```text
items = ["a", ["b"]]
nested = ["tag", copy(items)]
spliced = array("tag", flat_array(items), "tail")
receiver_spliced = ["tag", items.flat(), "tail"]
joined = concat_arrays(["x"], ["y", "z"])
```

Here `nested` is `["tag", ["a", ["b"]]]`, both spliced values are
`["tag", "a", ["b"], "tail"]`, and `joined` is `["x", "y", "z"]`.
