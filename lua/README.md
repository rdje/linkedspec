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
with the exact Perl callback result. Array-root and mixed-tree recursion remain active `.4.3.6.5.2`.
General user-function final blocks remain `.5.1`, while
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
Typed current-rule accumulators and otherwise-absent compiled-rule arrays share the bare binding seam. Action-edge
`.push`/`.push(target)` and block `push(Child[, target][, index])` reuse the cached child result, select zero-based
items when requested, and retain neutral wrong-kind diagnostics.
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
supplies scalar substitution; `.2.2.4` supplies explicit array split replacement; `.2.2.5` closes focused/public
no-drift and routes broader shipped proof to phase 6; `.3`
numeric; `.4` arrays; `.5` harrays; `.6` eager codeblocks/controls/contextual built-in blocks/
tree callbacks (split into `.0` audit, `.1` eager values, `.2` inline controls, `.3` statement controls, completed
`.4` current built-ins/`with`, active `.5` callbacks, and `.6` closeout); `.7` capture/mark/input/cursor state; `.8` diagnostic output;
and `.9` exhaustive no-drift. A broad leaf may split again before code if its
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
