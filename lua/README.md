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
Deterministic scalar/string helpers now include lazy fallback, definedness/
emptiness, Unicode trim/length/substrings, literal transforms/predicates,
lexical comparisons, Unicode 17.0.0 full default casing, portable scalar-to-
text coercion, strict PCRE2-backed `matches`, pure literal/regex/Unicode split,
statement scalar regex mutation, explicit array split replacement, and receiver chains. The Lua gate currently passes 76/76 on
both PUC Lua 5.4 and LuaJIT.
Source validation and optional strict-unused checks are also available.
Top-level function nodes returned by `specs/user_function_definition.spec` can
be projected and composed with rule parsing. Staged body dispatch, corpus
execution beyond the landed helper families, the primary CLI contract, and
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
supplies scalar substitution; `.2.2.4` supplies explicit array split replacement; active `.2.2.5` owns
regex/split corpus and public no-drift; `.3`
numeric; `.4` arrays; `.5` harrays; `.6` codeblocks/controls/trailing blocks/
tree callbacks; `.7` capture/mark/input/cursor state; `.8` diagnostic output;
and `.9` exhaustive no-drift. A broad leaf may split again before code if its
mechanism cannot remain signoff-sized.

Runtime values have exactly four public kinds: `scalar`, `array`, `harray`, and
`codeblock`. `runtime_value_kind(value)` reports those names; null, booleans,
numbers, and strings are scalar values. Aggregate and codeblock reads return
defensive snapshots. Bare assignment stores scalar-held typed values, while
`set(array(name), value)` and `set(hash(name), value)` select named aggregate
stores. Array indexes are zero-based at the DSL boundary and harray keys are
strings. Direct and nested access returns `json.null` for a missing or wrong-
kind path; nested assignment never creates missing intermediate containers.

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

Dropped `split(array(target), source, delimiter)` replaces the named explicit
aggregate with a copied typed split result. Literal and regex delimiters share
the pure split policy, including preserved empty fields. A non-wrapper split
statement is merely a discarded pure expression, and the source scalar is
never mutated.
