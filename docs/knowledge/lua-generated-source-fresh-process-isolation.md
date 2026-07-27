---
id: lua-generated-source-fresh-process-isolation
title: Generated Lua source is isolated in exact fresh PUC Lua and LuaJIT hosts
answers:
  - how is generated Lua source tested in a fresh process
  - does generated Lua source load in both PUC Lua and LuaJIT
  - how are corrupt generated Lua payloads classified
  - how does the generated Lua isolation test clean temporary files
  - which Lua runtime does the generated source host test launch
  - does generated Lua source preserve Unicode across processes
date: 2026-07-19
status: current for generated-source v2
tags: [lua, generated-source, isolation, subprocess, cleanup, PUC-Lua, LuaJIT]
evidence: "LUA-BACKEND-PARITY.8.1.2 adds one recurring test in lua/test/run.lua and passes the selected ABI runtime through LINKEDSPEC_LUA_TEST_RUNTIME from tools/run_lua_local.sh. PROJECT-DATA-SSD-ROOTING.2.5 routes its valid generated module, payload-corrupt variant, host runner, stdout, and stderr through one unique directory below managed repository TMPDIR. Fresh PUC Lua and LuaJIT children use the exact gate LUA_PATH/LUA_CPATH; normal and injected-failure paths both require the owned root to be absent. The storage oracle independently locks generated v2 and trace device identity."
reverify: "bash tools/run_lua_local.sh && bash tools/test_lua_project_data_storage.sh && rg -n 'LINKEDSPEC_LUA_TEST_RUNTIME|generated Lua source loads and fails|compile_or_load_generated_source' tools/run_lua_local.sh lua/test/run.lua"
---

`tools/run_lua_local.sh` passes the exact runtime selected for each ABI into
the native test suite. The generated-source host test therefore launches PUC
Lua for the primary leg and LuaJIT for the compatibility leg instead of
rediscovering a possibly different executable from `PATH`.

Each invocation creates one unique managed repository temporary root containing a valid
generated module, a variant whose embedded JSON payload is invalid, and a
small host runner. The child is launched with explicit `LUA_PATH` and
`LUA_CPATH`, so it imports the checkout source and the same disposable native
adapters as the enclosing gate. Stdout and stderr are captured independently.

The valid host proves exact contract metadata, Unicode source identity and
result, direct and traced values, native trace observations, and attributed
missing-rule failure. The corrupt host proves the portable
`compile_or_load_generated_source` stage and
`generated_source_compile_failed` code with the original identity. These are
persisted-module observations; they do not add generated family-plan semantics.

Cursor leaf `.9.1.7.4` adds a focused fresh-host matrix for v2: it proves direct/traced choice, exact v2 metadata,
and stale-v1 contract rejection before an independently corrupt payload. The older accepted-subset fresh-host
proof now emits v2 as well.

Cleanup is part of the contract. The ordinary path must remove the entire
root, and an intentionally raised operation must also clean before propagating
its error. The helper checks root absence after removal, preventing a passing
test from silently leaking host artifacts.

Parent scaffold `.8.1` is closed. Exact ten-family plan, rejection, direct
execution, and portable generated trace roles are current under `.8.2`, raising
the suite to 176/176 per ABI. Contract-sourced subset `.8.3` adds its own exact
fresh-host boundary and raises both ABIs to 177/177; census `.8.4` is now closed at 80/0/0.

Related facts: [[lua-generated-source-v2-rule-local-cursor]], [[lua-generated-source-emitter-core]],
[[lua-generated-source-scaffold-split]], [[generated-source-contract-v1]],
[[lua-generated-source-family-plan]], [[lua-generated-source-accepted-subset]],
[[lua-five-backend-capability-admission]], [[lua-project-data-ssd-storage]],
[[lua-toolchain-package-policy]].
