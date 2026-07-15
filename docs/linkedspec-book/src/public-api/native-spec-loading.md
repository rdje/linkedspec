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
failures, no hidden emitter creation, and traced/untraced descriptor/runtime identity. The backend currently
passes 155/155 focused tests on both runtimes with status `native-full-pipeline-trace-v1`.

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
permanent windows `.6.1.3-.4`.

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

The developer `lua/bin/corpus_runner.lua` intentionally remains validation-only in this slice; permanent ordered
core and capability windows are owned by `.6.1.3-.4`. Controlled scalar, nested aggregate, rule dispatch,
lifecycle, top-level function, boundary/trace, parse, validation, runtime, mismatch, no-match, and continuation
proof passes 160/160 on both PUC Lua and LuaJIT.
