# LUA-BACKEND-PARITY: Lua LinkedSpec Backend Parity

## Metadata

- Tree ID: `LUA-BACKEND-PARITY`
- Status: `active`
- Roadmap lane: `Overall roadmap - future backend parity (Lua third)`
- Created: `2026-07-11`
- Last updated: `2026-07-11` (zero-dependency native scaffold `.1.2` closed; corpus IO `.1.3` active)
- Owner: repo-local workflow

## Goal

Implement a native Lua LinkedSpec backend that consumes the same universal `.spec` language and exposes the same
observable features and behavior as Perl, Rust, Dart, and Julia. The primary product is an idiomatic in-process Lua
module; `linkedspec-lua` is a thin distinct executable implementing the exact shared primary CLI contract.

## Fixed constraints

- PUC Lua 5.4 is the primary conformance runtime. LuaJIT is a secondary compatibility leg and may not weaken or
  fork semantics because it implements Lua 5.1 language behavior.
- The backend may not create Lua-only `.spec` syntax, helper names, value kinds, diagnostics, regex behavior,
  result shapes, trace roles, CLI options, or corpus fixtures.
- Lua tables must project the four LinkedSpec value kinds without ambiguity: scalar, array, harray, and codeblock.
  Array versus harray identity may not be guessed from incidental key layout at public boundaries.
- Physical newlines separate statements. Semicolons only separate multiple statements on one physical line; the
  last statement on that line needs no trailing semicolon.
- For callables accepting a final codeblock, `call(args) { ... }` and `call(args, { ... })` are one AST/behavior
  contract across helper, user-function, and receiver-method surfaces.
- Single- and double-quoted DSL strings remain universal source syntax. Host Lua literal rules may not leak into
  `.spec` parsing or generated-source payloads.
- Lua patterns and LPeg are not presumed regex-compatible. The selected matching adapter must prove seek/consume,
  alternatives, captures, named captures, Unicode character projection, and the 105-fixture corpus contract.
- No Perl plugin machinery is part of the backend-neutral product contract.
- No implementation change occurs until its exact leaf is active and task-owned.

## Acceptance criteria

- `lua/` contains a repository-owned module/test/CLI layout that runs without untracked global state.
- Native APIs accept `.spec` source and input as in-memory Lua values, parse/validate/compile/execute in the current
  process, and return structured Lua results/diagnostics without a required CLI, subprocess, or temporary file.
- The source frontend, typed ActionIR, compiled state, runtime, staged parser registry, user functions, diagnostics,
  trace, native named/file loading, descriptors, and generated source implement the same contracts as the four
  admitted backends.
- The runtime passes the complete checked-in 105-case interpreter manifest with exact expected JSON values and the
  current 239-name non-legacy ActionIR surface checks.
- `linkedspec-lua` passes the same 61 primary CLI cases under default and POSIX option environments: identical
  options/meanings, zero positionals/subcommands, canonical output/error/trace bytes, and exit codes.
- Generated Lua source implements contract v1: deterministic compiled-state-plus-identity emission, Unicode text
  persisted as strict UTF-8, metadata/errors, exact ten-family authoritative plans, four rejections, portable trace,
  isolated host load, all-family proof, and the exact contract-sourced accepted 8/105 subset.
- The executable capability census expands deliberately for Lua and reaches all-pass before the backend is called
  complete. Existing 60/0/0 Perl/Rust/Dart/Julia states may not regress.
- mdBook, roadmap, Knowledge Map, live docs, task state, and artifact cleanup stay aligned after every leaf.
- Every leaf commits through `COMMIT.md` with its leaf id.

## Task tree

- ID: `LUA-BACKEND-PARITY`
  Status: `active`
  Goal: Implement Lua as the third full-parity future backend.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`

- ID: `LUA-BACKEND-PARITY.1`
  Status: `active`
  Goal: Establish toolchain, package layout, test harness, and corpus IO before parser behavior.
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `LUA-BACKEND-PARITY.1.1`
  Status: `done`
  Goal: Lock Lua runtime/tooling and repository layout choices.
  Acceptance: Reverify PUC Lua/LuaJIT/LPeg availability; record the absence or adoption of LuaRocks, Busted,
    Luacheck, and StyLua; choose dependency/test strategy, module search paths, `lua/` layout, `linkedspec-lua`,
    corpus runner, writable cache boundaries, and primary-versus-secondary runtime gates before source code.
  Verification: **PASS 2026-07-11.** PUC Lua 5.4.8 is the primary runtime; LuaJIT 2.1/5.1 is secondary. Core
    modules use their shared language subset, with runtime-specific code isolated. Repository layout is
    `lua/src/linkedspec/`, `lua/test/`, and `lua/bin/`; the distinct executable is `lua/bin/linkedspec-lua`, the
    corpus adapter is `lua/bin/corpus_runner.lua`, and `tools/run_lua_local.sh` owns gates. Commands prepend exact
    repo paths to `LUA_PATH` and retain `;;`; they never write global module paths. Initial scaffold/test driver has
    zero external dependencies. No JSON module is installed, so `.1.3` owns a pure-Lua typed JSON codec with an
    explicit null sentinel and array/harray tags. LPeg exists as separate Homebrew C modules for 5.4/5.1 but is not
    a foundation dependency or regex decision. Future optional LuaRocks state, if adopted, must live under a
    caller-owned `/private/tmp/linkedspec-lua-rocks*` tree and be deleted; current gates use no cache. No code changed.
  Commit: `LUA-BACKEND-PARITY.1.1 - lock Lua toolchain and package policy`

- ID: `LUA-BACKEND-PARITY.1.2`
  Status: `done`
  Goal: Add the minimal native Lua module, CLI/corpus-runner stubs, and repo-owned test driver.
  Acceptance: In-memory module load, backend status, exact entrypoint identities, primary PUC Lua smoke, optional
    LuaJIT compatibility smoke, and cleanup work without network/global package installation.
  Verification: **PASS 2026-07-11.** Added `lua/src/linkedspec/init.lua` with immutable-call status copies and
    exact backend/CLI/corpus entrypoint identities; dependency-free TAP-like `lua/test/run.lua`; executable
    developer stubs `lua/bin/linkedspec-lua` and `lua/bin/corpus_runner.lua`; README; and
    `tools/run_lua_local.sh`. The gate injects repo `LUA_PATH`, syntax-checks every source, passes 4/4 native module
    tests on PUC Lua and 4/4 on LuaJIT, and byte-checks both explicit exit-2 stub failures. No parser/corpus API,
    JSON/LPeg dependency, package/cache write, or public CLI behavior is faked. Corpus IO `.1.3` is next.
  Commit: `LUA-BACKEND-PARITY.1.2 - scaffold native Lua backend`

### `LUA-BACKEND-PARITY.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Repository/toolbox inventory (`rg --files`, runtime probes, and the `.1.1` policy)
  established that no task-owned native Lua module, test driver, command path, or local gate existed.
- [x] **ROOT CAUSE (WHY + WHERE)** — Lua was only a future backend intention; the complete parity plan deliberately
  assigned the first implementation boundary to `.1.2`, so no earlier source path could truthfully expose it.
- [x] **FIX** — Added the dependency-free module/test/bin/README layout and `tools/run_lua_local.sh`, while keeping
  parser and corpus behavior explicit exit-2 unavailable boundaries.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` syntax-checks every Lua source, passes PUC Lua 4/4,
  passes LuaJIT 4/4, and verifies exact process stderr/status for both command stubs.
- [x] **NO REGRESSION** — Capability, generated-source, language-coverage, doctrine, Knowledge Map, memory, and
  mdBook gates pass; the four admitted backends remain 60/0/0 and the scaffold claims no new capability.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook, Knowledge Map, changes/development/live status, and bounded
  memory all name the verified scaffold boundary and active strict corpus-IO successor `.1.3`.

- ID: `LUA-BACKEND-PARITY.1.3`
  Status: `active`
  Goal: Add strict manifest/fixture IO without parser execution.
  Acceptance: Validate the 105-case manifest, exact directory membership, required UTF-8 files, expected JSON, and
    stale/missing fixtures; keep execution disabled until runtime ownership exists.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.2`
  Status: `pending`
  Goal: Implement the universal `.spec` frontend.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `LUA-BACKEND-PARITY.2.1`
  Status: `pending`
  Goal: Define typed source AST and lossless JSON/provenance projection.
  Acceptance: Spec/rule/mode/body/edge/lifecycle/function/parse-job/source-span types match the neutral schema;
    explicit tagged representations preserve scalar/array/harray/codeblock identity.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.2.2`
  Status: `pending`
  Goal: Parse rule paragraphs and universal source syntax.
  Acceptance: Headers/modes, regex slots, action/blind edges, lifecycle/plain blocks, markers, fluent continuations,
    comments, nested blocks, quote forms, and newline/semicolon statement boundaries have focused fixtures.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.2.3`
  Status: `pending`
  Goal: Add exact source validation and strict-syntax behavior.
  Acceptance: Top rule, duplicates, edge families/targets/indexes, raw fallback, helper/function collisions, regex
    structure, and strict unused rules match the admitted variants with typed diagnostics.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.2.4`
  Status: `pending`
  Goal: Consume spec-driven top-level user-function shells.
  Acceptance: `specs/user_function_definition.spec` owns shell parsing/projection; Lua has no competing raw scanner;
    body payload/jobs/AST and provenance remain ordered and exact.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.3`
  Status: `pending`
  Goal: Implement typed ActionIR, contracts, function registry, and compiled state.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

- ID: `LUA-BACKEND-PARITY.3.1`
  Status: `pending`
  Goal: Parse action/helper text into typed AST nodes.
  Acceptance: Calls/args, four value kinds, access, assignments, controls, block values, receiver chains, generic
    final-codeblock syntax, and value-drop statements are structural nodes rather than Lua code rewrites.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.3.2`
  Status: `pending`
  Goal: Resolve current ActionIR contracts and generic diagnostics.
  Acceptance: The governed current-name inventory drives helpers/controls/methods; aliases canonicalize; registered
    functions resolve first; unknown/non-current calls never fall through to arbitrary Lua globals.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.3.3`
  Status: `pending`
  Goal: Add ordered user-function and staged body-job registries.
  Acceptance: Exact arity, eager values, fresh frames, body source/payload/job/AST, and recursion diagnostics match
    neutral semantics; no implicit caller mutation or Lua closure leakage.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.3.4`
  Status: `pending`
  Goal: Compile source AST into typed effective state and descriptors.
  Acceptance: Ordered effective rules/functions, modes, regex/dependency state, action/blind/lifecycle payloads,
    source identities, and outward descriptor JSON match the exact shared contract.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4`
  Status: `pending`
  Goal: Implement matching and runtime execution.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`

- ID: `LUA-BACKEND-PARITY.4.1`
  Status: `pending`
  Goal: Select and prove the regex/match-state adapter.
  Acceptance: Compare available Lua/LPeg/native-extension options against neutral regex fixtures; implement
    seek/consume, alternatives, captures/named captures, entry/local state, UTF-8 character offsets, line/column,
    zero progress, and invalid-pattern diagnostics without backend-specific regex semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.2`
  Status: `pending`
  Goal: Execute rule modes, dispatch, lifecycles, recursion, and result channels.
  Acceptance: Default/OR/AND/repetition acode/bcode paths, bounds, cursor state, explicit return/next/exit, retv,
    local stores, lifecycle order, recursion/safety cutoffs, and direct output shape match the oracle.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3`
  Status: `pending`
  Goal: Implement the complete helper/value/control/method surface in recursively split batches.
  Acceptance: Every current governed helper and method is behavior-tested, including scalar/string/number,
    array/harray mutation and pure operations, captures/positions/cursor/marks, controls, assignments, tree walks,
    diagnostic calls, and final-codeblock equivalence; split by mechanism before broad implementation.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.4`
  Status: `pending`
  Goal: Close runtime diagnostics and native trace propagation.
  Acceptance: Typed diagnostics carry stage/source/top/deepest rule/handler identity; caller-owned trace propagates
    through frontend/compiler/function/staged/runtime phases with exact levels/events/sinks and default quietness.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.5`
  Status: `pending`
  Goal: Implement general current staged-function execution and native loading.
  Children: `.5.1`, `.5.2`, `.5.3`

- ID: `LUA-BACKEND-PARITY.5.1`
  Status: `pending`
  Goal: Add staged parser registry/function-body dispatch and runtime calls.
  Acceptance: Provider identity, ordered jobs, parse/normalize/stitch phases, exact function calls, failures, and
    trace match the admitted variants without Lua-only queues or cache behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.5.2`
  Status: `pending`
  Goal: Add portable native named/path resolution and in-memory composition.
  Acceptance: Consume exact name/path/root/UTF-8/stage contract; expose load/compile/create-engine conveniences as
    adapters over native in-memory APIs; remove any backend-local fallback or implicit transcoding.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.5.3`
  Status: `pending`
  Goal: Admit exact outward descriptors, runtime diagnostics, and full-pipeline trace.
  Acceptance: Consume shared fixtures/checkers directly and expand the capability census without changing existing
    backend rows; no partial/gap state lacks a concrete next owner.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6`
  Status: `pending`
  Goal: Reach complete interpreter-corpus parity.
  Children: `.6.1`, `.6.2`, `.6.3`

- ID: `LUA-BACKEND-PARITY.6.1`
  Status: `pending`
  Goal: Admit controlled/core and governed capability fixture windows.
  Acceptance: Run ordered subsets, classify failures by mechanism, split repairs before code, and preserve exact
    expected values/endpoints rather than weakening fixtures.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2`
  Status: `pending`
  Goal: Admit shipped-spec, recursion, function, and advanced helper windows.
  Acceptance: Expand monotonically through all named manifest families with exact failure inventories and no
    backend-local expected files.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.3`
  Status: `pending`
  Goal: Make 105/105 exact interpreter execution recurring.
  Acceptance: One strict manifest-driven library gate and corpus runner pass all fixtures, reject manifest drift,
    and run through native in-memory APIs before CLI work is admitted.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.7`
  Status: `pending`
  Goal: Implement and admit the exact primary CLI.
  Children: `.7.1`, `.7.2`, `.7.3`

- ID: `LUA-BACKEND-PARITY.7.1`
  Status: `pending`
  Goal: Add `linkedspec-lua` as a thin native-library adapter.
  Acceptance: Implement the exact ADR `0023` option/argument schema, strict UTF-8 source/input boundaries,
    canonical JSON, failures/exits, and trace without subcommands, positionals, environment-dependent parsing, or
    semantics unavailable to in-memory callers.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.7.2`
  Status: `pending`
  Goal: Pass the shared 61-case process suite in default and POSIX environments.
  Acceptance: Add Lua as a first-class backend to the recurring neutral CLI matrix; stdout/stderr/files/exit bytes
    and executable-display substitution are exact.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.7.3`
  Status: `pending`
  Goal: Close CLI/native/corpus no-drift and public usage docs.
  Acceptance: Direct process families, package/corpus gates, executable installation guidance, limitations, mdBook,
    KM, and local CI agree; primary CLI contains no corpus/status extensions.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8`
  Status: `pending`
  Goal: Implement generated Lua source and complete capability admission.
  Children: `.8.1`, `.8.2`, `.8.3`, `.8.4`

- ID: `LUA-BACKEND-PARITY.8.1`
  Status: `pending`
  Goal: Add deterministic contract-v1 Lua emitter scaffold and isolated load/run.
  Acceptance: Effective compiled state, stable identity/metadata/errors, Unicode/strict-UTF-8 payload boundary,
    direct/traced entrypoints, caller-owned isolation, and cleanup pass without altering native interpreter/CLI.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8.2`
  Status: `pending`
  Goal: Add exact ten-family plan and authoritative direct generated execution.
  Acceptance: Ordered public rows, four rejections, per-root/nested family dispatch, portable trace/source identity,
    and one isolated all-family matrix equal native values.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8.3`
  Status: `pending`
  Goal: Admit the exact contract-sourced generated 8/105 subset.
  Acceptance: Interpreter-first values, independent generated load, metadata/plans/trace identity, checker-owned
    path/order/no-skip/cleanup, and complete Lua package/CLI/corpus gates pass before capability promotion.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8.4`
  Status: `pending`
  Goal: Close Lua capability parity and backend handoff.
  Acceptance: Expanded capability manifest is all-pass; PUC Lua primary and LuaJIT compatibility policies are
    honest; roadmap/book/KM/live docs/local CI/cleanup pass; no outstanding Lua behavior is hidden as a limitation.
  Verification: `pending`
  Commit: `pending`

## Current frontier

| Order | Leaf | Status | Next action |
| ---: | --- | --- | --- |
| 1 | `LUA-BACKEND-PARITY.1.1` | `done` | PUC/LuaJIT, layout, zero-dependency tests, JSON, regex, and cache policy locked. |
| 2 | `LUA-BACKEND-PARITY.1.2` | `done` | Native module/test/bin/local-gate scaffold passes PUC Lua and LuaJIT. |
| 3 | `LUA-BACKEND-PARITY.1.3` | `active` | Add strict 105-case corpus IO and typed JSON. |

## Initial toolchain evidence (read-only planning audit)

- `/opt/homebrew/bin/lua` and `lua5.4` report PUC Lua `5.4.8`.
- `/opt/homebrew/bin/luajit` reports LuaJIT `2.1.1753364724` over Lua `5.1` language semantics.
- `require("lpeg")` succeeds on both runtimes.
- LuaRocks, Busted, Luacheck, and StyLua are not installed.
- No repository-owned `lua/` backend or `.lua` implementation files exist; `rgx/rgx-core/src/lua.rs` is Rust-side
  Lua integration evidence, not a LinkedSpec Lua backend.

These observations guided `.1.1`. The locked policy below deliberately leaves the regex provider to `.4.1` and
does not claim that LuaJIT already passes the later complete secondary compatibility gate.

## Locked foundation policy

- Module tree: `lua/src/linkedspec/init.lua` plus mechanism modules below `lua/src/linkedspec/`.
- Test tree: `lua/test/run.lua` is a dependency-free repository-owned TAP-like assertion driver; focused test files
  are required explicitly and cannot depend on Busted/global modules.
- Module command: `LUA_PATH="$REPO/lua/src/?.lua;$REPO/lua/src/?/init.lua;;" lua ...`; the same path is used with
  `luajit` for secondary compatibility. `;;` retains standard paths without making them semantic dependencies.
- Public commands: `lua/bin/linkedspec-lua` and `lua/bin/corpus_runner.lua`; both load the native module. The first
  eventually joins the exact primary CLI matrix, while the corpus runner remains a developer adapter.
- Local gate: `tools/run_lua_local.sh` runs primary module/tests/CLI/corpus legs and the explicitly scoped LuaJIT
  compatibility leg. It must reject missing PUC Lua; LuaJIT handling follows the recorded secondary policy.
- Dependency/cache policy: no LuaRocks/global write and no network for the scaffold. Any future rock tree is
  caller-owned under `/private/tmp/linkedspec-lua-rocks*`, never under the repository or home directory, and is
  recursively removed after proof.
- JSON policy: installed `cjson`, `dkjson`, and `lunajson` are absent. `.1.3` owns a small pure-Lua strict JSON codec
  with explicit null, array, and harray identity, recursive canonical object-key ordering, and strict UTF-8 checks.
- Regex policy: installed LPeg is candidate evidence only. `.4.1` owns comparison/adoption and any native extension;
  foundation/frontend/compiler code may not depend on it.
- Compatibility syntax: shared production modules prefer the Lua 5.1/5.4 intersection. Version adapters are
  isolated and tested; LuaJIT compatibility cannot change `.spec`, API, result, diagnostic, or CLI behavior.

## Commit log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FUTURE-PARITY-BACKLOG.1.3` | `FUTURE-PARITY-BACKLOG.1.3 - scope Lua backend parity plan` | Creates this full-parity plan; no Lua implementation code. |
| `LUA-BACKEND-PARITY.1.1` | `LUA-BACKEND-PARITY.1.1 - lock Lua toolchain and package policy` | Locks runtimes, layout, zero-dependency harness, JSON/regex ownership, and cache boundaries; no code. |
| `LUA-BACKEND-PARITY.1.2` | `LUA-BACKEND-PARITY.1.2 - scaffold native Lua backend` | Native module identity, dependency-free dual-runtime tests, explicit command stubs, and `.1.3` handoff. |
