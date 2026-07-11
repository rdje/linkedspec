# LinkedSpec Lua Backend

This directory contains the native Lua backend. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg.

Current status: repository-owned module/test/command scaffold only. Parsing,
corpus IO, the primary CLI contract, and generated source are deliberately not
implemented by this slice.

Run the local gate from the repository root:

```bash
bash tools/run_lua_local.sh
```

Load the native module directly:

```bash
LUA_PATH="$PWD/lua/src/?.lua;$PWD/lua/src/?/init.lua;;" \
  lua -e 'local linkedspec = require("linkedspec"); print(linkedspec.backend_name())'
```

The scaffold has no LuaRocks or global package dependency. The command files
are developer stubs and exit `2` until their owning implementation leaves land.
