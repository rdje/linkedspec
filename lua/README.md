# LinkedSpec Lua Backend

This directory contains the native Lua backend. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg.

Current status: repository-owned module/test/command scaffold plus strict corpus
manifest/fixture IO. Parsing, corpus execution, the primary CLI contract, and
generated source are deliberately not implemented yet.

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
