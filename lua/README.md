# LinkedSpec Lua Backend

This directory contains the native Lua backend. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg.

Current status: repository-owned module/test/command scaffold, strict corpus IO,
typed source/provenance AST data, permissive rule-level source parsing, a typed
structural ActionIR parser, current-name ActionIR contract resolution, and an
ordered user-function/body-job registry with fresh invocation frames. Typed
compiled rule/dependency/payload state and exact outward descriptors are also
available in memory. Native PCRE2 matching supplies stable seek/consume,
captures, Unicode positions, and entry/local match registers. The first
compiled-rule interpreter executes rule modes, edges, lifecycle blocks,
repetition, and direct result channels entirely in memory.
Source validation and optional strict-unused checks are also available.
Top-level function nodes returned by `specs/user_function_definition.spec` can
be projected and composed with rule parsing. Staged body dispatch, corpus
execution, broad helper/value semantics, the primary CLI contract, and
generated source are deliberately not implemented yet.

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
text. `parse_spec` currently parses rule paragraphs
only; spec-returned top-level function projection follows separately.
`validate_spec(parsed, { strict_syntax = true })` adds the
portable strict unused-rule check; ordinary validation already checks tops,
duplicates, function/helper collisions, raw syntax, edge families/targets/
slots, and regex structure.

Function-shell semantics are not raw-scanned by Lua. Given the explicitly typed
node array returned by the owning definition spec, use:

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
undispatched and `body_ast` remains absent at this boundary.

Parse helper/action source without rewriting it to Lua:

```lua
local action = linkedspec.parse_action_block([[
set_key(meta, "b", 2)
set_key(meta, "a", 1)
set_key(hash(meta), "stmt_hash", 4)
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
the same exact 239-name source used by function validation. Resolution walks
nested arguments, shapes, blocks, access indexes, controls, assignments, and
receiver methods. Unknown calls produce `unknown_helper`; structural parser
fallback produces `raw_perl`. Neither path invokes a Lua global.

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
are typed registry errors. Staged body-job dispatch, body execution, and primary
CLI promotion remain later owned layers.

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
other PCRE2 syntax without a Lua-specific rewrite.

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

`runtime_parse(...)` and its `runtime_execute(...)` alias execute default,
AND, OR, single, optional, plus/star, and bounded families. Action and blind
edges dispatch children through `retv`; lifecycle payloads run in applicable
`I`, `LS`, `LE`, `IT`, `EX`, `LX`, `E` order. Repetition has explicit bounds,
zero-progress and recursion cutoffs, and `next()` advances to the next rule
iteration. Rule-local writes are restored when a child returns. `return(...)`
preserves false as distinct from `json.null`, while `exit_now(status)` raises a
typed immediate runtime error. The result exposes the direct value, neutral
one-element output wrapper, byte/code-unit and character cursors, and lifecycle
events. Helper/value breadth beyond the narrow dispatch-facing evaluator
remains owned by `.4.3`.
