# Native Spec Loading

LinkedSpec distinguishes a portable **named spec identity** from an exact **host path**. This distinction keeps
library callers in control of filesystem policy while giving every backend the same deterministic resolution and
text boundary.

- A named request is a portable relative identity such as `Demo`, `Demo.spec`, or `nested/Demo`.
- A path request is one exact absolute or current-directory-relative host path.
- Load options contain the caller's current directory and an ordered list of explicit search roots.

Named lookup checks candidates in this exact order:

1. the name exactly under the current directory;
2. the name with one `.spec` suffix under the current directory;
3. the suffixed name directly under each declared search root, in declared order.

Duplicate lexical candidates are checked once. Lookup never recurses, never consults an implicit repository root,
and selects the first regular file. If no regular file matches but a candidate exists as a directory or another
non-file kind, the first such candidate is reported as `spec_path_not_file`.

## Lua API

The Lua backend exposes the file-oriented stages directly from `require("linkedspec")`:
When running from a repository checkout, first prepare the caller-owned
`LUA_PATH`/`LUA_CPATH` session shown under
[Lua primary parser command](#lua-primary-parser-command); the native modules
are not installed globally.

```lua
local linkedspec = require("linkedspec")

local emitter = linkedspec.trace_emitter(
  linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG)
)

local request = linkedspec.named_spec_request("Demo")
local options = linkedspec.spec_load_options({
  cwd = "/work/project",
  search_roots = {
    "/work/project/specs",
    "/opt/shared/linkedspec",
  },
  trace = emitter,
})

local resolved = linkedspec.resolve_spec(request, options)
print(resolved.path)    -- first matching regular file
print(resolved.origin)  -- cwd_exact, cwd_spec_suffix, or search_root:<zero-based-index>

local loaded = linkedspec.load_spec(request, options)
assert(loaded.resolved.path == resolved.path)
local source = loaded.source_text

local complete = linkedspec.load_and_compile_spec(request, options)
assert(complete.loaded.source_text == source)
local engine = complete:create_engine({ parse_mode = "seek", trace = emitter })
local result = linkedspec.runtime_parse(engine, "input", { trace = emitter })
```

`runtime_parse(...)` mirrors the reference public-parser entry boundary before it invokes the top rule. It skips
only complete leading lines that are blank (spaces/tabs followed by `\n`) or comments (spaces/tabs, `#`, then
text through `\n` or end of input). It does not trim ordinary leading spaces, nonleading comments, or other
content. Result byte/code-unit and character cursors remain absolute offsets in the original input, including
when a skipped comment contains Unicode text.

Use `linkedspec.path_spec_request(path)` when the caller has already selected one exact file. A relative path is
resolved only against `options.cwd`; it does not gain `.spec` and does not fall back to search roots.

Requests, options, resolved values, loaded values, and pipeline errors have stable runtime identities. Advanced
callers can inspect one with `linkedspec.spec_loader.node_type(value)`, which returns `SpecRequest`,
`SpecLoadOptions`, `ResolvedSpec`, `LoadedSpec`, `LoadedCompiledSpec`, or `SpecPipelineError` as appropriate.

`load_and_compile_spec(...)` continues from exact decoded text through automatic spec-owned top-level-function
parsing, staged body dispatch, explicit source validation, and compilation. The returned `LoadedCompiledSpec`
keeps the full `LoadedSpec` under `loaded` and ordinary backend-native compiled state under `compiled`. Use either
`complete:create_engine(options)` or `linkedspec.create_loaded_spec_engine(complete, options)` to create a runtime
engine. Both forms copy the caller's options. A named request attaches its exact requested identity as `spec_name`;
an exact-path request attaches no logical name; both attach the winning `resolved.path` as `spec_path`.

The optional `trace` field in `SpecLoadOptions` is a caller-created `LinkedSpecTraceEmitter`. The same emitter may
be passed through engine creation and then runtime execution, producing one ordered stream across `lua_io:*`,
`lua_frontend:*`, `lua_compiler:*`, `lua_staged:*`, and `lua_runtime:*` topics. This covers resolution and content
loading; function-parser cache/construction/execution; shell projection and rule parsing; validation and function/
rule compilation; staged resolve/load/compile/execute/stitch; engine construction; and runtime rule behavior.
Compiled specs and engines do not retain the emitter: caller ownership, sink lifetime, and explicit runtime
injection remain visible. Omitting it is the ordinary quiet path, and disabled emitters record and write nothing.

## Validation and errors

Portable names must be valid UTF-8 relative forward-slash identities. Empty or whitespace-only names,
leading/trailing Unicode whitespace, Unicode control characters, absolute names, backslashes, empty path
components, `.` components, and `..` components are rejected. Exact path requests must be nonempty valid UTF-8
and may not contain NUL bytes.

Operational failures are raised as typed `SpecPipelineError` values, so `pcall` can distinguish them from API
misuse:

```lua
local ok, result = pcall(linkedspec.load_spec, request, options)
if not ok and linkedspec.is_spec_pipeline_error(result) then
  local payload = linkedspec.spec_pipeline_error_to_json(result)
  io.stderr:write(linkedspec.json.encode(payload), "\n")
end
```

The neutral payload always includes `type`, `stage`, `code`, `summary`, `request_kind`, and `requested`. It adds
`resolved_path` and `detail` only when available. Resolution/loading currently emits these stage/code families:

| Stage | Codes |
| --- | --- |
| `validate_spec_name` | `invalid_spec_name` |
| `validate_spec_path` | `invalid_spec_path` |
| `resolve_spec_path` | `spec_path_not_found`, `spec_path_not_file`, `spec_read_failed` |
| `load_spec_content` | `spec_read_failed` |
| `decode_spec_content` | `invalid_utf8` |
| `parse_spec` | `spec_parse_failed` |
| `validate_spec` | `spec_validation_failed` |
| `compile_spec` | `spec_compile_failed` |

## Exact text boundary

Files are read as bytes in the Lua process, then accepted only if they are strict UTF-8. Loading does not perform
replacement decoding, UTF-16/UTF-32 transcoding, Unicode normalization, BOM removal, newline conversion, or
trimming. Consequently, `source_text` retains the original UTF-8 text exactly, including an initial U+FEFF,
normalization form, and leading/trailing newlines or spaces.

PUC Lua and LuaJIT consume the same executable contract directly: 14 name-validation cases, nine
resolution/file-kind cases, and four strict-UTF-8 preservation/rejection cases. Full composition also proves
loaded top-level-function execution, named versus exact-path engine identity, runtime diagnostic identity, exact
missing-name JSON, and separate parse/validation/compile failure ownership. Full trace composition additionally
proves one emitter identity, exact ordered phase/rule topics, routed sinks, level filtering, balanced attributed
failures, no hidden emitter creation, and traced/untraced descriptor/runtime identity. That trace milestone passes
155/155. Complete interpreter-corpus admission raised the suite to 167/167 on both runtimes with status
`runtime-corpus-full` at the `.6.3` boundary; primary CLI work raised the suite to 169/169 and status
`runtime-corpus-primary-cli`. Generated-source core `.8.1.1` raised the suite to 172/172, and isolated-host proof
`.8.1.2` now raises the current suite to 173/173 without changing that status.

## Lua primary parser command

`lua/bin/linkedspec-lua` is now a thin adapter over the same native loading, staged compilation, engine, runtime,
and typed JSON APIs documented above. It accepts exactly ADR `0023`'s source/input/parser/trace/help options, with
no subcommands or positional arguments:

```bash
# Run from the repository root. Keep this caller-owned native directory alive
# for every module, primary-command, and corpus command in the shell.
native_dir=$(mktemp -d /private/tmp/linkedspec-lua-native.XXXXXX)
trap 'rm -rf "$native_dir"' EXIT
bash tools/build_lua_native.sh puc "$native_dir"
export LUA_PATH="$PWD/lua/src/?.lua;$PWD/lua/src/?/init.lua;;"
export LUA_CPATH="$native_dir/?.so;;"

lua/bin/linkedspec-lua --spec Lispish --input '(hello world)'
lua/bin/linkedspec-lua \
  --spec-file demo.spec --input-file demo.txt --top-rule Top
```

The checkout commands are tracked executables and locate `lua/src` themselves;
`LUA_PATH` also enables direct `require("linkedspec")` embedding. Native PCRE2
and filesystem modules are not installed globally, so every command needs the
caller-built `LUA_CPATH` above. There is no LuaRocks installation dependency.
Cursor policy is derived from each entered rule family. The retired `--parse-mode`
flag is absent from help and returns its targeted usage migration error if supplied.

Source, input, arguments, JSON, help/errors, and canonical trace are strict preserved UTF-8. Success emits one
recursively key-sorted JSON value plus one newline and exits 0; compilation/input/invocation failures emit one
stable phase heading and exit 1; usage exits 2. CLI trace is ADR `0024`'s portable phase protocol, not the rich
native emitter stream. Relative paths use the actual process cwd queried through the narrow filesystem adapter,
so no shell, subprocess, or environment option parser owns semantics. PUC Lua and LuaJIT pass 169/169, and the
unchanged shared process manifest now passes recurring 61/61 runs in default and POSIX environments. The warmed
cross-backend matrix passes 5x2x61; public status is `runtime-corpus-primary-cli`, no-drift `.7.3` closes parent
`.7`. Planning leaf `.8.1.0` corrected the older v1/v2-only generated-source scope against current outward
descriptor v3. Emitter core `.8.1.1` supplies deterministic exact-v1/v2/v3 source construction, and `.8.1.2`
proves persisted valid and corrupt modules in fresh PUC Lua/LuaJIT hosts with complete caller-owned cleanup.
Exact generated family execution closes under `.8.2`, contract-sourced accepted-subset `.8.3` is closed, and
final capability admission/handoff `.8.4` is complete at five-backend 80/0/0.

## Lua generated-source API

The public Lua module now exposes two source emitters:

- `emit_lua_source_v2(compiled, source_identity)` emits contract-v2/format-2 source with the caller's nonempty strict-UTF-8
  identity;
- `emit_lua_source(compiled)` is the current-version convenience form and uses identity `<inline>`.

Both return native Lua source text. For equivalent effective compiled state and identity, the returned bytes are
identical. The emitter reconstructs an effective typed `SpecFile` from source-ordered callable definitions and
last-definition rule order. Fixed-v1 params/arity, variadic-v2 signature/rest metadata, and final-codeblock-v3
parameter kinds survive that reconstruction exactly. Canonical sorted-key strict-UTF-8 JSON and the source
identity are rendered as lowercase ASCII hex, so Lua literal escaping, interpolation, locale, and normalization
cannot alter the payload.

```lua
local linkedspec = require("linkedspec")

local parsed = linkedspec.parse_spec([[
Top::
 I { return("generated") }
 /x/
]])
local compiled = linkedspec.compile_spec(parsed)
local source = linkedspec.emit_lua_source_v2(
  compiled,
  "generated/example.spec"
)

local loader = loadstring or load -- Lua 5.1/LuaJIT or modern PUC Lua
local chunk = assert(loader(source, "@generated_example.lua"))
local generated = chunk()

local metadata = linkedspec.generated_source_metadata_to_json(
  generated.metadata()
)
assert(metadata.contract_id == "linkedspec-generated-source-v2")
assert(metadata.format_version == 2)
assert(metadata.source_identity == "generated/example.spec")
local plan = generated.plan()
generated.validate_plan(plan)
assert(plan[1].label == "Top")
assert(plan[1].family == "default")
assert(generated.execute("x", { top_rule = "Top" }) == "generated")
```

The emitted module exports:

- `LINKEDSPEC_GENERATED_SOURCE_CONTRACT`, `LINKEDSPEC_GENERATED_SOURCE_FORMAT`, and
  `LINKEDSPEC_GENERATED_SOURCE_IDENTITY` markers;
- `metadata()` for typed contract/version/identity metadata;
- `plan()` for a fresh source-ordered list of typed `{ label, family }` rows;
- `validate_plan(actual)` for exact pre-execution validation against the compiled state;
- `execute(input[, options])` for the direct result value;
- `execute_with_trace(input, trace_config[, options])` for the same result while using the native caller-owned
  trace configuration and writers in `options`.

The module imports `linkedspec` when loaded and delegates execution to the current compiled runtime. It is a
deterministic generated artifact and independent module boundary, not a bundled runtime or a performance claim.
Its failures use typed `GeneratedSourceError` values. `generated_source_error_to_json(error)` projects stable
`type`, `stage`, `code`, `summary`, and `source_identity` fields plus optional `rule_label`, `handler_family`,
`detail`, `expected_contract`, and `actual_contract`. Stage/code constants are exported for callers that need exact
classification. V1 identities fail at `validate_generated_plan` with
`generated_source_contract_version_mismatch` before embedded spec-payload decoding and direct callers must
regenerate the artifact from its `.spec` source.

The ten family names are `default`, `or_acode`, `and_single_acode`, `and_acode_seq`, `and_bcode`, `or_bcode`,
`rep_acode`, `rep_bcode`, `rep_and_acode`, and `rep_and_bcode`. Validation distinguishes row-count, ordered-label,
known-family mismatch, and unknown-family drift. Unknown names are rejected before expected-family comparison.
The validated per-label map is authoritative: every generated root and nested rule reads it to select regex or
blind dispatch and to derive seek for the five default/OR families or consume for the five AND families. No cursor
field is serialized. Ordinary native execution has no map and retains compiled-structure selection.

Generated traced execution retains the native trace and adds `generated_rule_enter`,
`generated_family_decision`, and `generated_rule_exit` at low level with source identity, rule, and family. The
focused proof compares all ten root values with the native interpreter, observes nested-family events, attributes
generated execution failures, runs one combined emitted all-family module in fresh PUC Lua and LuaJIT hosts, and
reconstructs the neutral variadic callable fixture through typed rest arrays rather than host varargs.

Fresh-process PUC Lua/LuaJIT persistence is recurring proof under `.8.1.2`. The focused host test writes a valid
module, an invalid-payload variant, and a runner into one unique caller-owned temporary directory; launches the
exact ABI runtime and native module paths used by the gate; captures stdout and stderr separately; and locks exact
Unicode metadata/result, direct/traced results, native trace, missing-rule attribution, corrupt-payload stage/code,
and source identity. The directory must be absent after normal completion and after an injected host failure.

Contract-sourced `.8.3` validates the complete 105-fixture manifest before consuming the exact eight neutral names
in contract order. It proves each interpreter value before emission, then independently loads all eight modules in
the exact selected PUC Lua or LuaJIT host. Exact result, metadata, plan, fixed user-function execution, portable
trace identity, stdout/stderr, and cleanup observations pass at 177/177 on both ABIs. The executable contract
checker owns this test path and its order/proof/load/trace/cleanup/no-skip properties. `.8.4` now adds Lua to the
capability census after that proof, not before it.

## Lua automatic function parsing

Lua can now execute the repository-owned function-definition grammar automatically:

```lua
local source = [[
fn normalize(value) { return(value.trim()) }

Top::
 /x/
]]

local nodes = linkedspec.parse_user_function_definition_asts(source)
assert(nodes[1].name == "normalize")

local spec = linkedspec.parse_spec_with_staged_user_function_definitions(source)
assert(spec.functions[1].body_ast.kind == "action_block")
```

The backend resolves `specs/user_function_definition.spec` through one exact module-relative bundled path with an
empty search-root list. On first use it runs the ordinary native source parser, validator, and compiler; the
successful compiled parser is then reused. Each call executes top rule `user_function_definitions` in process,
normalizes only the typed result batch, and passes those nodes to the existing Unicode-character-index projector
and deterministic `actionir-body.spec` dispatcher. There is no fallback or competing raw `fn` scanner.

`user_function_definition_parser_metadata()` reports the resolved identity, top rule, and successful build count.
Parser-spec parse/validation/compile, parser execution, and unsupported output failures are typed
`UserFunctionDefinitionParserError` values with a `stage` field. Function error nodes remain ordinary typed source
parse errors, and staged-dispatch errors retain their staged-registry owner.

`load_spec(...)` deliberately remains a text-loading stage and does not execute anything. Callers choose
`load_and_compile_spec(...)` when they want the complete typed file-to-engine composition. Inline callers continue
to use `parse_spec_with_staged_user_function_definitions(...)`, `validate_spec(...)`, `compile_spec(...)`, and
`runtime_engine(...)` directly; no CLI, subprocess, temporary file, or serialized handoff participates in either
path. Exact fixed-v1, variadic-v2, and final-codeblock-v3 outward descriptors are now current; one-emitter
full-pipeline trace is current; census-preserving no-drift `.5.3.3` closes parents `.5.3`/`.5`. Controlled/core
planning `.6.1.0` measured offsets 0-39 and 99-104 at 45/46 on both ABIs; typed nested-path repair `.6.1.1`
closes unchanged offset 20 and both windows at 46/46. Reusable corpus execution `.6.1.2` is complete before
permanent windows `.6.1.3-.4`; both windows are now admitted and parent `.6.1` is closed.

## Lua library corpus execution

`execute_corpus_fixtures(root[, options])` is the in-process corpus boundary. It first applies the complete strict
manifest, directory-membership, UTF-8, and expected-JSON validation contract. Selection happens only afterward,
either by ordered `case_names` or by zero-based `offset` plus optional positive `limit`; named and bounded
selection cannot be combined.

```lua
local linkedspec = require("linkedspec")

local execution = linkedspec.execute_corpus_fixtures(
  "rust/linkedspec-runtime/tests/corpus",
  {
    offset = 0,
    limit = 1,
    trace_config = linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
  }
)

assert(linkedspec.corpus_execution_passed(execution))
local result = execution.results[1]
print(result.name, result.cursor_code_unit, result.cursor_char_offset)
```

Each selected source uses the automatic spec-defined function parser, explicit validation, compilation with that
validation result, a runtime engine identified by fixture name and exact `input.spec` path, and native runtime
execution. The reference value is wrapped exactly once—`[expected_json]`—and compared structurally with typed
array/harray/null identity. A fresh silent emitter is created per fixture when `trace_config` is supplied; its
formatted lines remain in that fixture's result instead of leaking to stdout.

`CorpusFixtureExecutionResult` retains the fixture name, copied expected JSON, copied actual value/output,
match flag, byte and character endpoints, trace lines, typed runtime diagnostic when present, `failure_stage`, and
failure text. Stable stages are `parse`, `validate`, `compile`, `execute`, `match`, `compare`, and `unexpected`.
Fixture failures are data: every selected fixture is attempted even after an earlier failure. Selection/manifest
errors remain caller errors because no valid execution set exists. Query with `corpus_fixture_passed(...)`,
`corpus_execution_passed(...)`, `corpus_passed_count(...)`, `corpus_failures(...)`, and
`corpus_fixture_result(...)`.

The developer `lua/bin/corpus_runner.lua` validates only by default:

```bash
lua/bin/corpus_runner.lua --corpus rust/linkedspec-runtime/tests/corpus
```

Bare `--execute` runs the complete validated manifest through the same native in-memory API, prints each ordered
PASS/FAIL result and an exact pass/fail summary, and returns 0 for all-pass, 1 for fixture failures, or 2 for
arguments and manifest drift:

```bash
lua/bin/corpus_runner.lua \
  --corpus rust/linkedspec-runtime/tests/corpus --execute
```

This remains a separate developer adapter; `.7.1` has since implemented the parser-oriented primary command,
without adding corpus or status extensions to it.
Permanent ordered core offsets
0-39 are admitted by `.6.1.3`; `.6.1.4` admits the six governed capability fixtures at offsets 99-104 in this
exact order: `capability_cursor_control_surface`, `capability_pure_helper_surface`,
`capability_position_helper_surface`, `capability_control_marker_surface`,
`capability_capture_anonymous_surface`, and `capability_capture_named_surface`. Their exact byte/character
endpoints are `2,1,2,1,5,5`, and every actual output remains exactly `[expected_json]`. Controlled scalar,
nested aggregate, rule dispatch,
lifecycle, top-level function, boundary/trace, parse, validation, runtime, mismatch, no-match, and continuation
proof passes 160/160 on both PUC Lua and LuaJIT. The recurring core test additionally locks 40/40 manifest-ordered
results from `proof_edge_array_literal` through `terse_2_2_5_2_attached_switch_blocks`: every actual output is
exactly `[expected_json]` and every case matches at byte/character endpoint 1. The governed test locks 6/6 with
the per-fixture endpoints above. Advanced/shipped offsets 40-98 are likewise permanently 59/59. Final `.6.3`
executes all 105 fixtures as one ordered library/runner gate with zero failures; both ABI suites pass 167/167 and
status is `runtime-corpus-full`.
