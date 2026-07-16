---
id: lua-primary-cli-recurring-admission
title: Lua primary CLI conformance is recurring locally and in the five-backend matrix
answers:
  - is Lua primary CLI conformance recurring
  - does the Lua local gate run all 61 CLI cases
  - does Lua primary CLI pass POSIXLY CORRECT
  - is Lua included in the shared primary CLI matrix
  - how many backends does the primary CLI matrix run
  - how does the CLI matrix build Lua native modules
  - what status follows Lua primary CLI admission
  - what did LUA BACKEND PARITY 7.2 implement
date: 2026-07-15
status: current
tags: [lua, cli, parity, matrix, regression, PUC-Lua, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.7.2 replaces focused Lua command smokes with the unchanged 61-case manifest under default and POSIX environments, adds one disposable PUC Lua native build to tools/run_primary_cli_matrix.sh, and passes 5 backends x 2 environments x 61 exact cases. PUC Lua and LuaJIT remain 169/169; corpus remains 105/105; canonical local CI passes Phase 0 1031/1031 in 607 seconds; status is runtime-corpus-primary-cli."
reverify: "bash tools/run_lua_local.sh && bash tools/run_primary_cli_matrix.sh"
---

`tools/run_lua_local.sh` is the recurring focused owner. After building the
primary PUC Lua native modules once in a unique temporary directory, it runs
the complete unchanged `cli_conformance/manifest.json` with
`POSIXLY_CORRECT` explicitly unset and then set. Both legs pass 61/61. The
same focused gate keeps the full 169-test PUC Lua and LuaJIT suites plus
complete 105/105 developer-corpus execution.

`tools/run_primary_cli_matrix.sh` now accepts `LINKEDSPEC_LUA_CMD`, builds
only the primary PUC Lua native adapters under `${TMPDIR:-/tmp}`, exports
their path only to the Lua command through `env LUA_CPATH=...`, and removes
the temporary tree on every exit. Perl, Rust, Dart, Julia, and Lua consume
one unchanged manifest under default and POSIX environments: 5 backends x 2
environments x 61 exact stdout/stderr/file/exit/display cases.

This admission changes no primary adapter semantics, corpus oracles,
generated source, or capability census. Public Lua status advances from
`runtime-corpus-full` to `runtime-corpus-primary-cli`; generated-source and
capability admission remain `.8.1-.8.4`. Final CLI/native/corpus documentation
no-drift `.7.3` has since closed parent `.7` and activated scaffold `.8.1`.

The canonical local CI gate independently exits 0 with its reference CLI
legs at 61/61 under default and POSIX environments and Phase 0 at
`1..1031` in 607 seconds.

Related facts: [[lua-primary-cli-adapter]], [[primary-cli-four-backend-matrix]],
[[neutral-cli-fixture-runner]], [[user-observable-backend-cli-parity-contract]],
[[lua-full-corpus-gate]], [[lua-backend-full-parity-plan]],
[[lua-primary-cli-no-drift-closeout]].
