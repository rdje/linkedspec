# LinkedSpec Lua Backend

This directory contains the native Lua backend. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg.

Current status: repository-owned module/test/command scaffold, strict corpus IO,
typed source/provenance AST data, permissive rule-level source parsing, a typed
structural ActionIR parser, current-name ActionIR contract resolution, and an
ordered user-function/body-job registry with fresh invocation frames.
Source validation and optional strict-unused checks are also available.
Top-level function nodes returned by `specs/user_function_definition.spec` can
be projected and composed with rule parsing. Staged body dispatch, corpus
execution, the primary CLI
contract, and generated source are deliberately not implemented yet.

Run the local gate from the repository root:

```bash
bash tools/run_lua_local.sh
```

Load the native module directly:

```bash
LUA_PATH="$PWD/lua/src/?.lua;$PWD/lua/src/?/init.lua;;" \
  lua -e 'local linkedspec = require("linkedspec"); print(linkedspec.backend_name())'
```

The backend has no LuaRocks or global package dependency. Validate the checked-in
corpus without executing it:

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
