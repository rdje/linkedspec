---
id: lua-project-data-ssd-storage
title: Lua native modules, test workspaces, generated output, and traces stay on repository storage
answers:
  - where does LinkedSpec build Lua native modules
  - how do I run a targeted Lua command with repository local storage
  - how do I verify Lua project data stays on the repository filesystem
  - how many Lua files allocate temporary data
  - do PUC Lua and LuaJIT use separate native modules
  - do Lua generated source workspaces and traces stay on the SSD
  - can the Lua native builder write to another filesystem
  - were old Lua temporary workspaces deleted
  - does LinkedSpec need cross volume Lua toolchain reads
  - how are spaces in Lua temporary paths tested
  - why does the macOS Lua native builder invoke clang directly
  - does the Apple cc shim write xcrun metadata outside the repository
date: 2026-07-28
status: current
tags: [lua, native, storage, filesystem, ssd, temporary-data, generated-source, trace, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.2.5 adds tools/run_lua_project_data.sh and tools/test_lua_project_data_storage.sh, makes tools/build_lua_native.sh self-rooted and same-filesystem guarded, and initially routes all 13 tracked Lua-family allocation owners through managed TMPDIR. Later semantic/runtime and MCP owners advance the exact manifest to 16. FUTURE-PARITY-BACKLOG.10.9.6.1 adds the common mcp_system.c build, so the oracle now builds three native modules for PUC Lua and LuaJIT in a path containing a space, checks actual filesystem devices and non-symlink module identity, runs native parsing, writes generated v2 source and trace output, rejects an other-filesystem builder destination before creation, and cleans its owned state. The exact initial and final old-root linkedspec-lua-* censuses are zero. Process proof .4.2 caught the Apple /usr/bin/cc shim attempting an xcrun_db temporary write; the Darwin default now invokes the active developer clang with the active macOS SDK explicitly, and the final contained build has no denied or xcrun_db diagnostic."
reverify: "bash tools/test_lua_project_data_storage.sh && bash tools/run_lua_local.sh"
---

Supported Lua workflows create native modules, test workspaces, generated source, and trace output only below the
repository-derived managed temporary root. Use the targeted wrapper when a single PUC Lua or LuaJIT command should
run with the same storage contract as the complete gate:

```console
$ bash tools/run_lua_project_data.sh puc -e 'local l = require("linkedspec"); print(l.backend_name())'
$ bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_descriptor_test.lua
```

The wrapper derives the checkout from its own file, enters a managed run, creates a unique native directory below
`TMPDIR`, builds the selected ABI's PCRE2 and filesystem modules, supplies repository `LUA_PATH` and disposable
`LUA_CPATH`, runs the child from the repository root, and removes the native directory. The complete
`tools/run_lua_local.sh` gate follows the same contract while building both ABIs once for its full package,
primary-command, corpus, and integrated storage proof.

`tools/test_lua_project_data_storage.sh` freezes the 16 executable Lua-family allocation owners: 15 Lua tests and
the complete local runner. Every Lua owner reads routed `TMPDIR`; no owner retains a hard-coded operating-system
temporary template or anonymous `io.tmpfile()`. The oracle builds both two-module ABI sets below a path containing
a space, rejects symlinks or device drift, requires the PCRE2/filesystem/MCP-system module trio, performs a real native parse, writes generated-source v2 and trace
files, and verifies exact cleanup. `tools/build_lua_native.sh` independently checks the nearest existing output
ancestor before `mkdir` and the resolved output after creation, so an explicit other-filesystem destination fails
without creating the rejected path.

The exact initial census found no retained `linkedspec-lua-*` directory in either old operating-system temporary
root, and the complete proof leaves that census at zero. There was therefore no exact Lua-owned payload to copy or
delete. The externally installed PUC Lua/LuaJIT interpreters, C compiler, `pkg-config`, ABI headers, PCRE2 headers/
library, and operating-system libraries remain strictly necessary read-only toolchain inputs; they are not project
storage. One composite Knowledge Map command that still allocates Python/Rust scratch is deliberately owned by
`PROJECT-DATA-SSD-ROOTING.2.6`, not by the Lua allocator leaf.

On macOS, `/usr/bin/cc` is a stateful Apple tool-selection shim rather than the final compiler. The process oracle
observed it attempting to refresh `xcrun_db-*` beneath the per-user operating-system temporary root even though the
native output itself was correctly routed. When the caller keeps the default `cc`, `tools/build_lua_native.sh` now
uses `xcode-select -p` to locate the active developer tree, invokes its real `clang`, and supplies the active SDK by
`-isysroot`. An explicit `LINKEDSPEC_CC_CMD` remains caller-owned. This removes the hidden external write while
retaining necessary read-only compiler, SDK, header, library, and `pkg-config` access.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-workflow-routing]],
[[repository-root-path-portability]], [[lua-toolchain-package-policy]], [[lua-local-verification-gate]],
[[lua-generated-source-fresh-process-isolation]], [[project-data-process-locality-proof]].
