---
id: lua-primary-cli-adapter
title: Lua has the exact thin native primary parser CLI adapter
answers:
  - is the Lua primary LinkedSpec CLI implemented
  - what options does linkedspec lua accept
  - does the Lua CLI have subcommands or positional arguments
  - how does the Lua CLI load named file and inline specs
  - does the Lua CLI preserve strict UTF-8
  - does the Lua CLI emit canonical JSON
  - what are the Lua primary CLI exit codes
  - does the Lua CLI use canonical phase trace
  - why did Lua add a native current directory query
  - what did LUA BACKEND PARITY 7.1 implement
  - does Lua pass the shared 61 case CLI suite
date: 2026-07-15
status: current
tags: [lua, cli, native-api, utf8, json, trace, parity, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.7.1 adds lua/src/linkedspec/primary_cli.lua and replaces the exit-2 command scaffold. Direct/process tests pass 169/169 on PUC Lua and LuaJIT; the unchanged shared process manifest passes diagnostic 61/61 in default and POSIX environments. Canonical local CI reaches phase0 1..1031 in 606 seconds. Public status remains runtime-corpus-full until .7.2 makes the two process legs recurring."
evidence_update_2026_07_15_recurring_admission: "LUA-BACKEND-PARITY.7.2 makes both 61-case process environments recurring in the focused gate, extends the warmed matrix to 5x2x61, and advances status to runtime-corpus-primary-cli without changing primary_cli.lua semantics."
reverify: "bash tools/run_lua_local.sh && rg -n 'primary_cli|current_directory|run_primary_cli' lua/bin/linkedspec-lua lua/native/filesystem_native.c lua/src/linkedspec lua/test/run.lua tools/run_lua_local.sh"
---

`LUA-BACKEND-PARITY.7.1` replaces Lua's primary exit-2 scaffold with a thin
adapter over existing in-memory APIs. `linkedspec-lua` accepts exactly one of
`--spec`, `--spec-file`, or `--inline-spec`, exactly one of `--input` or
`--input-file`, the shared parser/trace controls, and `--help`/`-h`. Options
are case-sensitive and exact; subcommands, positionals, abbreviations,
negations, and backend-specific extensions are rejected.

Named and exact-path source selection delegates to Lua's typed native loader;
inline source uses the staged function-aware parser and compiler. Both paths
construct the normal native runtime engine and serialize `RuntimeParseResult`
`value` through Lua's typed, recursive, key-sorted JSON encoder. Compilation
precedes deferred input-file loading. Source/input files are strict preserved
UTF-8: no replacement decoding, normalization, BOM removal, newline conversion,
or trimming occurs.

Success/help exits 0; compilation, input-load, and invocation failures emit one
stable heading and exit 1; usage exits 2. The command emits ADR `0024`'s
portable compile/input/invoke phase trace, including exact numeric/named levels,
UTF-8 byte counts, field escaping, emoji, reset/append, and stdout/route/mirror
sinks. This projection is independent of Lua's richer caller-owned native trace.

Standard Lua has no portable current-working-directory API. The existing narrow
filesystem native module therefore adds only `current_directory()`, allowing
relative CLI file resolution to use the actual process cwd without a shell,
subprocess, or `PWD` environment assumption. Parser semantics remain wholly in
the library.

Both ABI suites pass 169/169. The unchanged 61-case process manifest is already
green under default and `POSIXLY_CORRECT=1`; `.7.2` has since made both legs
recurring and extended the shared matrix to 5x2x61. Current status is
`runtime-corpus-primary-cli`. The `.7.1` canonical local CI baseline exits 0
with Phase 0 true reach `1..1031` in 606 seconds.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[primary-cli-strict-utf8-text-contract]], [[canonical-primary-cli-trace-protocol]],
[[native-in-memory-backend-contract]], [[lua-native-spec-loading-closeout]],
[[lua-full-corpus-gate]], [[lua-backend-full-parity-plan]],
[[lua-primary-cli-recurring-admission]].
