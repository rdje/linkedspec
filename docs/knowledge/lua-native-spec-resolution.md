---
id: lua-native-spec-resolution
title: Lua exposes typed deterministic named and exact-path spec resolution and strict loading
answers:
  - how does Lua load a named LinkedSpec spec file
  - where is Lua native spec resolution implemented
  - does Lua consume the shared native resolution fixture directly
  - does Lua native spec lookup recurse or use implicit roots
  - how does Lua distinguish regular files without a subprocess
  - does Lua preserve a UTF-8 BOM and newlines when loading specs
  - what does a Lua native spec loading error look like
  - what did LUA-BACKEND-PARITY 5.2.1 implement
date: 2026-07-15
status: current
tags: [lua, resolution, files, utf8, diagnostics, native-api, parity, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.2.1 exports typed Lua requests/options/resolved/loaded/errors, deterministic cwd/suffix/direct-root selection, a dual-ABI native stat inspector, in-process byte loading, strict UTF-8 preservation, direct 14/9/4 fixture proof at 149/149 on both ABIs, and canonical CLI 61x2 plus Phase 0 1031."
reverify: "perl tools/check_native_spec_resolution_contract.pl && bash tools/run_lua_local.sh"
---

`require("linkedspec")` exports `named_spec_request(...)`, `path_spec_request(...)`, `spec_load_options(...)`,
`validate_spec_request(...)`, `resolve_spec(...)`, and `load_spec(...)`. Requests, options, resolved values, loaded
values, and pipeline errors retain stable runtime identities through `linkedspec.spec_loader.node_type(...)`.

Named resolution checks cwd exact, cwd with one `.spec` suffix, then each declared direct root in order. Lexical
candidates are deduplicated without reordering; lookup never recurses or adds an implicit repository root. The
first regular file wins, while the first non-regular candidate is retained for a miss diagnostic. Exact path
requests use only the supplied absolute path or the same path relative to caller-owned cwd.

Lua owns all policy. A minimal `lua/native/filesystem_native.c` module contributes only `stat`-based
file/non-regular/missing/error classification because that fact is not portable in pure Lua without a subprocess.
`tools/build_lua_native.sh` compiles the inspector independently for PUC Lua and LuaJIT. `load_spec(...)` then reads
bytes in process and validates strict UTF-8 through the existing JSON text boundary. It does not remove BOM,
normalize Unicode, convert newlines, trim, replace malformed bytes, or transcode UTF-16/32.

`SpecPipelineError` values carry neutral type/stage/code/summary/request identity and optional path/detail.
`spec_pipeline_error_to_json(...)` provides deterministic outward projection. Direct tests consume all 14 name,
nine resolution/file-kind, and four text cases plus supplemental Unicode name and exact-path boundaries on both
ABIs. This leaf's status was `native-spec-resolution-loading-v1`; subsequent `.5.2.2` adds cached automatic
spec-owned function-shell parsing at 151/151. `.5.2.3` then adds typed loaded/compiled state, exact source-stage
errors, and source-identified engines at 153/153. `.5.2.4` closes exact source/API/test/public no-drift without a
behavior change; current status remains `native-spec-pipeline-v1` and descriptors/full trace `.5.3` is active.

Related facts: [[native-spec-resolution-contract]], [[lua-native-spec-loading-split]],
[[native-in-memory-backend-contract]], [[lua-function-definition-shell-projection]],
[[lua-spec-defined-function-parser]], [[lua-native-spec-pipeline]], [[lua-native-spec-loading-closeout]].
