# LinkedSpec Lua Backend

This directory contains the native Lua backend. PUC Lua 5.4 is the primary
conformance runtime; LuaJIT is a secondary compatibility leg.

Current status: repository-owned module/test/command scaffold, strict corpus IO,
and typed source/provenance AST data. Source parsing, corpus execution, the
primary CLI contract, and generated source are deliberately not implemented yet.

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
table layout. These are data APIs only—there is no `parse_spec` function yet.
