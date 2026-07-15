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

local request = linkedspec.named_spec_request("Demo")
local options = linkedspec.spec_load_options({
  cwd = "/work/project",
  search_roots = {
    "/work/project/specs",
    "/opt/shared/linkedspec",
  },
})

local resolved = linkedspec.resolve_spec(request, options)
print(resolved.path)    -- first matching regular file
print(resolved.origin)  -- cwd_exact, cwd_spec_suffix, or search_root:<zero-based-index>

local loaded = linkedspec.load_spec(request, options)
assert(loaded.resolved.path == resolved.path)
local source = loaded.source_text
```

Use `linkedspec.path_spec_request(path)` when the caller has already selected one exact file. A relative path is
resolved only against `options.cwd`; it does not gain `.spec` and does not fall back to search roots.

Requests, options, resolved values, loaded values, and pipeline errors have stable runtime identities. Advanced
callers can inspect one with `linkedspec.spec_loader.node_type(value)`, which returns `SpecRequest`,
`SpecLoadOptions`, `ResolvedSpec`, `LoadedSpec`, or `SpecPipelineError` as appropriate.

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

## Exact text boundary

Files are read as bytes in the Lua process, then accepted only if they are strict UTF-8. Loading does not perform
replacement decoding, UTF-16/UTF-32 transcoding, Unicode normalization, BOM removal, newline conversion, or
trimming. Consequently, `source_text` retains the original UTF-8 text exactly, including an initial U+FEFF,
normalization form, and leading/trailing newlines or spaces.

PUC Lua and LuaJIT consume the same executable contract directly: 14 name-validation cases, nine
resolution/file-kind cases, and four strict-UTF-8 preservation/rejection cases. The backend currently passes
149/149 focused tests on both runtimes with status `native-spec-resolution-loading-v1`.

This Lua milestone stops after resolution and loading. Automatic execution of the spec-owned top-level function
grammar is the next dependency; composed parse, validation, compilation, and identity-bearing engine creation
follow after it. `load_spec(...)` therefore does not yet claim to return an executable parser.
