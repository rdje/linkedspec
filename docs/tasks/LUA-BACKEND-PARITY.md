# LUA-BACKEND-PARITY: Lua LinkedSpec Backend Parity

## Metadata

- Tree ID: `LUA-BACKEND-PARITY`
- Status: `active`
- Roadmap lane: `Overall roadmap - future backend parity (Lua third)`
- Created: `2026-07-11`
- Last updated: `2026-07-11` (function registry `.3.3` closed; compiled state `.3.4` active)
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
  Status: `done`
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
  Status: `done`
  Goal: Add strict manifest/fixture IO without parser execution.
  Acceptance: Validate the 105-case manifest, exact directory membership, required UTF-8 files, expected JSON, and
    stale/missing fixtures; keep execution disabled until runtime ownership exists.
  Verification: **PASS 2026-07-11.** Added the zero-dependency `linkedspec.json` codec with strict UTF-8
    validation, strict JSON grammar/Unicode escapes, explicit null/array/harray identity, duplicate-key rejection,
    ambiguous-plain-table rejection, finite numbers, cycles, and recursively canonical object ordering. Added
    `linkedspec.corpus` to validate format/count/names/duplicates, exact missing/stale directory membership, all
    required strict-UTF-8 files, and typed expected JSON for the exact 105-case checked-in manifest. The developer
    corpus command validates and reports 105 fixtures while explicitly refusing execution; the primary CLI remains
    an exit-2 parser stub. `tools/run_lua_local.sh` passes syntax, 10/10 PUC Lua tests, exact process checks, 105
    command validation, and 10/10 LuaJIT compatibility tests with no leftover temp directories.
  Commit: `LUA-BACKEND-PARITY.1.3 - add strict Lua corpus IO`

### `LUA-BACKEND-PARITY.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Knowledge Map/toolbox audit plus direct manifest inspection confirmed the exact
  105-case corpus and showed the Lua scaffold had no JSON decoder, typed JSON identities, UTF-8 validator, fixture
  loader, or drift guard.
- [x] **ROOT CAUSE (WHY + WHERE)** — No installed Lua JSON package can preserve the required null/array/harray
  distinction portably across PUC Lua and LuaJIT; Lua's standard library also has no directory iterator, so `.1.3`
  owned a repository codec and a safely quoted, NUL-delimited read-only fixture inventory adapter.
- [x] **FIX** — Added strict `linkedspec.json`, `linkedspec.corpus`, validation-only corpus runner behavior, public
  in-memory loading, focused malformed/drift/UTF-8 proofs, and exact command-gate accounting.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 10/10 on PUC Lua and 10/10 on LuaJIT, loads
  all 105 fixtures, validates exact process output, and rejects unsupported format, unsafe/duplicate names,
  count/directory drift, missing files, malformed JSON, invalid UTF-8, duplicate JSON keys, and ambiguous tables.
- [x] **NO REGRESSION** — Parser execution and `parse_spec` remain absent, the primary CLI retains its exact
  scaffold failure, the corpus runner rejects `--execute`, and capability/generated-source states stay 60/0/0.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook, Knowledge Map, README, changes/development/live status, and
  bounded memory all describe strict UTF-8 as this text boundary encoding—not as a synonym for Unicode—and point
  to source AST `.2.1` next.

- ID: `LUA-BACKEND-PARITY.2`
  Status: `done`
  Goal: Implement the universal `.spec` frontend.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `LUA-BACKEND-PARITY.2.1`
  Status: `done`
  Goal: Define typed source AST and lossless JSON/provenance projection.
  Acceptance: Spec/rule/mode/body/edge/lifecycle/function/parse-job/source-span types match the neutral schema;
    explicit tagged representations preserve scalar/array/harray/codeblock identity.
  Verification: **PASS 2026-07-11.** Added `linkedspec.spec_ast` with private metatable identities and validated
    constructors for `SpecFile`, `FunctionDefinition`, ordinary/staged source spans, `StagedParseJob`, rules,
    headers, every simple/bounded mode, ten body-element variants, edge targets, and fluent calls. Neutral field
    projection/from-JSON follows the Rust/Dart/Julia contract, preserves typed JSON array/harray/scalars and explicit
    codeblock AST identity, clones optional function payload/AST values defensively, and rejects unknown variants,
    ambiguous payload tables, wrong node lists, and sparse arrays. The public module exposes the data API, top-rule
    and label lookup, and repetition/AND mode queries without exposing `parse_spec`. The local gate passes syntax,
    exact corpus/process legs, 13/13 PUC Lua tests, and 13/13 LuaJIT compatibility tests.
  Commit: `LUA-BACKEND-PARITY.2.1 - add typed Lua source AST`

### `LUA-BACKEND-PARITY.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Knowledge Map and canonical Dart/Julia/Rust AST inspection established the neutral
  node/field contract; direct Lua module inspection showed no typed source/provenance representation before this
  leaf.
- [x] **ROOT CAUSE (WHY + WHERE)** — Parser work cannot be safe over untyped Lua tables: array/harray layout and
  codeblock/body variant identity would otherwise be guessed, while staged function payload provenance could drift
  from existing `source_span`/`body_parse_job` fields.
- [x] **FIX** — Added validated metatable-typed AST nodes, complete neutral projection/reconstruction, defensive
  typed-JSON payload cloning, mode helpers, lookups, all ten body variants, and public in-memory exposure.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 13/13 on PUC Lua and 13/13 on LuaJIT; one
  representative function/staged-job/bounded-rule AST round-trips byte-canonical JSON, all body variants round-trip,
  and malformed modes/kinds/nodes/payloads/sparse lists are rejected.
- [x] **NO REGRESSION** — Exact 105-case corpus validation and process checks remain green; `parse_spec` remains
  absent and no source syntax, runtime, CLI, capability, or generated-source behavior is claimed early.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook with Lua construction example, README, Knowledge Map, and
  live continuity identify the completed data-only boundary and activate parser `.2.2`.

- ID: `LUA-BACKEND-PARITY.2.2`
  Status: `done`
  Goal: Parse rule paragraphs and universal source syntax.
  Acceptance: Headers/modes, regex slots, action/blind edges, lifecycle/plain blocks, markers, fluent continuations,
    comments, nested blocks, quote forms, and newline/semicolon statement boundaries have focused fixtures.
  Verification: **PASS 2026-07-11.** Added public `parse_spec(source)` and typed `SpecParseException` values. The
    permissive rule-level parser produces the `.2.1` AST for headers and every simple/bounded mode; header-rest and
    body regex slots; grouped/indexed action and blind edges; attached/multiline fluent continuations; lifecycle,
    plain, and receiver-when/otherwise blocks; split/conditional/lifecycle markers; raw fallback; comments; nested
    parentheses/braces; and braces inside double- or single-quoted text. Because Lua strings can carry arbitrary
    bytes, the public source seam rejects invalid UTF-8 before scanning while preserving valid Unicode text.
    Compact lifecycle fluent calls normalize
    into semicolon-separated same-line statements with no trailing semicolon; physical newlines remain statement
    separators without inserted semicolons. It parses all 21 shipped specs and 102/105 rule-only corpus sources;
    the three top-level-function sources remain intentionally routed to `.2.4`. The local gate passes syntax,
    exact process/105-manifest legs, 23/23 PUC Lua tests, and 23/23 LuaJIT compatibility tests. Primary CLI and
    corpus execution remain unavailable.
  Commit: `LUA-BACKEND-PARITY.2.2 - parse Lua rule source`

### `LUA-BACKEND-PARITY.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Knowledge Map plus Dart/Julia parser/toolbox inspection established the admitted
  permissive rule-parser boundary; Lua had typed target nodes but no public source-to-AST producer.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.2.1` deliberately stopped at data types. Without a dedicated scanner,
  nested blocks/parentheses, both quote delimiters, header-line regexes, multiline fluent chains, and newline versus
  semicolon statement separation could not be represented reliably.
- [x] **FIX** — Added a shared Lua 5.1/5.4 scanner/parser for headers, modes, body families, quote-aware nesting,
  fluent/attached blocks, comments/raw fallback, strict-UTF-8 source admission, exact line attribution, and typed
  parse errors; exported the native
  `parse_spec` API while keeping command/runtime surfaces unavailable.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 23/23 on PUC Lua and 23/23 on LuaJIT, all 21
  shipped specs, 102 rule-only corpus specs, three intentional function-shell exclusions, and focused shapes.
- [x] **NO REGRESSION** — Exact 105-case manifest/process checks remain green; no compiler, runtime, corpus execute,
  primary CLI, validation, ActionIR, capability, or generated-source behavior is claimed by parsing alone.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README examples, Knowledge Map, and live continuity document
  the native parser, both quote forms, exact newline/semicolon rule, rule-only boundary, and active validation `.2.3`.

- ID: `LUA-BACKEND-PARITY.2.3`
  Status: `done`
  Goal: Add exact source validation and strict-syntax behavior.
  Acceptance: Top rule, duplicates, edge families/targets/indexes, raw fallback, helper/function collisions, regex
    structure, and strict unused rules match the admitted variants with typed diagnostics.
  Verification: **PASS 2026-07-11.** Added public `validate_spec(spec, {strict_syntax=...})` and typed validation
    exceptions. Checks cover a top rule, duplicate rules/functions, exact 239-name helper/control and runtime/
    lifecycle/function collisions, identifier/parameter shape, duplicate params, arity, raw fallback, mixed edge
    families, grouped action targets without shared code, undefined targets, regex-slot bounds, regex structure,
    and strict unused rules. Added a private current-call inventory module and extended
    `tools/check_language_capability_coverage.pl` so Lua must exactly equal Dart/Julia and the neutral Perl/corpus/
    mdBook surface; count is 239. Focused validation exposed and fixed empty-body headers (`Child:`) being collected
    as raw text. The local gate passes syntax/process/manifest, 31/31 PUC Lua, all 21 shipped specs, 102 rule-only
    corpus sources, exact call-name coverage, and 31/31 LuaJIT. No ActionIR/runtime/CLI execution is claimed.
  Commit: `LUA-BACKEND-PARITY.2.3 - validate Lua source AST`

### `LUA-BACKEND-PARITY.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct permissive-parser probes accepted missing tops, duplicates, raw lines, bad
  targets/slots, mixed edges, malformed regex structure, and unused rules; no Lua validator or complete helper-name
  collision inventory existed.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.2.2` deliberately separates recognition from acceptance, while `.3.2` had
  not yet materialized Lua contracts. Validation therefore needed its own reusable exact 239-name reservation data
  and stable AST checks before compiler/runtime work.
- [x] **FIX** — Added typed validation, complete registry/edge/regex/strict checks, the reusable call-name module,
  cross-language checker equality, focused failures, and the empty-body header parser correction found by validation.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 31/31 on PUC Lua and 31/31 on LuaJIT, all 21
  shipped specs and 102 rule-only corpus specs; `perl tools/check_language_capability_coverage.pl` proves exact 239.
- [x] **NO REGRESSION** — Parser/corpus/process proofs remain green; permissive parsing is still distinct from
  validation; no ActionIR lowering, arbitrary Lua global fallback, runtime, corpus execute, primary CLI, or codegen
  is exposed.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README, Knowledge Map, call-name checker, and live continuity
  document the validator/strict boundary and activate spec-produced function-shell projection `.2.4`.

- ID: `LUA-BACKEND-PARITY.2.4`
  Status: `done`
  Goal: Consume spec-driven top-level user-function shells.
  Acceptance: `specs/user_function_definition.spec` owns shell parsing/projection; Lua has no competing raw scanner;
    body payload/jobs/AST and provenance remain ordered and exact.
  Verification: **PASS 2026-07-11.** Added `user_function_definition_shell.lua` and public normalization,
    projection, and composed-parse APIs over explicitly typed JSON nodes returned by
    `specs/user_function_definition.spec`. The projector validates definition/error node types, identifiers,
    params/arity, exact Unicode character-index source/body spans, body containment, staged payload/job identity,
    parser/top/result/failure/diagnostic fields, and parent paths. It defensively copies sidecars, normalizes
    `functions.<index>.body_source` and deterministic job IDs, strips spans with spaces while retaining CR/LF and
    all non-function Unicode text, then composes the ordinary rule parser. `body_ast` remains undispatched. Empty
    node input over leading `fn` source yields a typed rule parse error, proving no raw scanner. Focused output-shape,
    error-node, drift, overlap, Unicode, composition, and validation proofs pass. The local gate passes
    syntax/process/manifest/coverage, 35/35 PUC Lua, and 35/35 LuaJIT. Source frontend `.2` closes; `.3.1` follows.
  Commit: `LUA-BACKEND-PARITY.2.4 - project Lua function shells`

### `LUA-BACKEND-PARITY.2.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct rule parsing rejects leading top-level `fn` source, while Knowledge Map and
  Dart/Julia reference inspection show the owning spec returns typed definition/error nodes plus staged sidecars;
  Lua had no consumer for those nodes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Function-shell syntax belongs to `specs/user_function_definition.spec`, not a
  backend raw scanner. Lua needed a neutral projection boundary capable of interpreting Unicode character spans and
  preserving staged parse intent before the registry exists.
- [x] **FIX** — Added typed output normalization, exact node/span/sidecar validation, defensive copying,
  path/job normalization, line-preserving stripping, composed rule parsing, and typed error/no-scanner behavior.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 35/35 on PUC Lua and 35/35 on LuaJIT, including
  Unicode offsets, two ordered functions, staged provenance, composed validation, spec errors, drift, wrappers,
  overlap rejection, and explicit empty-node no-raw-scan proof.
- [x] **NO REGRESSION** — All parser/validator/105-manifest/process/239-name proofs remain green; body staged jobs
  are preserved but not dispatched, and no ActionIR, runtime, corpus execute, primary CLI, or codegen is claimed.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README API examples, Knowledge Map, and live continuity close
  source frontend `.2` and activate typed ActionIR parsing `.3.1`.

- ID: `LUA-BACKEND-PARITY.3`
  Status: `active`
  Goal: Implement typed ActionIR, contracts, function registry, and compiled state.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

- ID: `LUA-BACKEND-PARITY.3.1`
  Status: `done`
  Goal: Parse action/helper text into typed AST nodes.
  Acceptance: Calls/args, four value kinds, access, assignments, controls, block values, receiver chains, generic
    final-codeblock syntax, and value-drop statements are structural nodes rather than Lua code rewrites.
  Verification: **PASS 2026-07-11.** Added private-metatable typed `ActionBlock`, `ActionStatement`, `ActionExpr`,
    `ActionArgument`, access-segment, hash-entry, fluent-call, and Unicode character-span records plus typed JSON
    projection. Public block/statement/expression parsing covers value-drop statements, physical-newline and
    same-line-semicolon separation, calls/nested args, assignment-valued args, both quote forms, primitive/regex
    literals, all four value kinds, direct/nested access, scalar/append/hash/nested assignments, attached controls,
    switch branches, receiver chains, generic final codeblocks, and structural `raw_perl` fallback. Arbitrary
    helper and receiver-method names accept `call(args) { ... }`; its final block-value argument matches explicit
    `call(args, { ... })`. Spans count Unicode characters over strict-UTF-8 host strings. The local gate passes
    syntax/process/manifest checks and 41/41 tests on both PUC Lua and LuaJIT. The complete local CI gate also
    passes phase0 `1..1030`, both 61-case Perl CLI environments, and the 60/0/0 admitted-backend census.
  Commit: `LUA-BACKEND-PARITY.3.1 - parse typed Lua ActionIR`

### `LUA-BACKEND-PARITY.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The function-shell frontend preserved action/body text and staged parse jobs but had
  no typed action block, statement, expression, argument, access, control, or receiver-chain parser to consume it.
- [x] **ROOT CAUSE (WHY + WHERE)** — Lua cannot safely execute or text-rewrite universal helper source: table
  shape cannot identify values, byte indexes are not Unicode character spans, and host globals cannot define the
  portable call surface. A typed structural seam had to precede contract resolution and runtime dispatch.
- [x] **FIX** — Added typed ActionIR data/projection and public recursive parsing with quote/regex/delimiter-aware
  scanners, exact statement separators, all four value forms, assignments/controls/access/chains, generic final
  codeblock arguments, and explicit unsupported-expression nodes.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 41/41 on PUC Lua and 41/41 on LuaJIT. Focused
  checks lock the single-quoted `substr(value, '"|\\s', "", go)` form, Unicode spans, compact/newline statements,
  generic helper/receiver final blocks, explicit-block equivalence, attached controls, typed JSON, and invalid UTF-8.
- [x] **NO REGRESSION** — Exact primary-command stub, validation-only 105-fixture command, source frontend,
  function projection, and 239-name inventory remain green; no contract resolution, Lua-global fallback, staged
  dispatch, runtime execution, CLI promotion, capability claim, or generated source is introduced. Full local CI
  passes phase0 `1..1030`, both 61-case CLI environments, capability/generated-source, and doctrine gates.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README examples, Knowledge Map, changes/development/live
  status, and bounded memory close typed parsing and activate current ActionIR contract resolution `.3.2`.

- ID: `LUA-BACKEND-PARITY.3.2`
  Status: `done`
  Goal: Resolve current ActionIR contracts and generic diagnostics.
  Acceptance: The governed current-name inventory drives helpers/controls/methods; aliases canonicalize; registered
    functions resolve first; unknown/non-current calls never fall through to arbitrary Lua globals.
  Verification: **PASS 2026-07-11.** Added typed resolution/contract/diagnostic records and public block,
    statement, and expression resolvers over the `.3.1` AST. The resolver reuses the exact 239-name
    `action_call_names` source shared with function validation, canonicalizes numeric/symbol/current aliases,
    assigns stable helper families/surfaces/counts, walks nested arguments/shapes/access/block values/controls,
    records all structural assignments, and emits only generic `unknown_helper` / `raw_perl` diagnostics. An
    optional registry interface resolves exact-arity function calls before helper fallback and reports stable
    arity mismatches; `.3.3` owns the concrete ordered registry. The prerequisite audit repaired the governed
    current `=(target, value)` alias missing from `.3.1`'s symbol scanner. Typed JSON matches Dart/Julia fields.
    The local gate passes syntax/process/manifest checks and 46/46 tests on both PUC Lua and LuaJIT; exact
    239-name cross-language coverage remains green. Full local CI also passes phase0 `1..1030`, both 61-case
    Perl CLI environments, the 60/0/0 admitted-backend census, and all doctrine gates.
  Commit: `LUA-BACKEND-PARITY.3.2 - resolve Lua ActionIR contracts`

### `LUA-BACKEND-PARITY.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.3.1` produced typed calls, controls, assignments, chains, and raw fallback but did
  not classify current behavior or distinguish canonical, unknown, and future registered-function calls.
- [x] **ROOT CAUSE (WHY + WHERE)** — Direct execution or Lua-global lookup would fork semantics. Resolution must
  share validation's governed 239-name source and traverse typed nodes before compiler/runtime ownership begins.
  Canonical-table comparison also found `=(...)` reserved but unreachable in the completed parser.
- [x] **FIX** — Added typed recursive contracts/diagnostics/JSON, exact alias/family classification, structural
  assignment/control records, current-name sharing, generic unknown/raw errors, registry-first resolution seam,
  and restored the governed `=` symbol callee.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 46/46 on PUC Lua and 46/46 on LuaJIT. Tests
  lock nested helpers, numeric aliases, `=(...)`, all assignment forms, controls/methods, typed JSON, unknown/raw
  ordering, exact known-name behavior, and generic final-codeblock arity through a registry stub.
- [x] **NO REGRESSION** — `perl tools/check_language_capability_coverage.pl` remains exact at 239 current names and
  105 fixtures. Parser/function/source/corpus/process proofs remain green; no concrete registry, arbitrary globals,
  runtime behavior, primary CLI, capability promotion, or generated source is introduced. Full local CI passes
  phase0 `1..1030`, CLI 61x2, capability/generated-source/native-resolution, and doctrine checks.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README API, Knowledge Map, changes/development/live status,
  and bounded memory close contract resolution and activate concrete ordered function registry `.3.3`.

- ID: `LUA-BACKEND-PARITY.3.3`
  Status: `done`
  Goal: Add ordered user-function and staged body-job registries.
  Acceptance: Exact arity, eager values, fresh frames, body source/payload/job/AST, and recursion diagnostics match
    neutral semantics; no implicit caller mutation or Lua closure leakage.
  Verification: **PASS 2026-07-11.** Added typed registry, entry, call-resolution, invocation-frame, and registry-
    exception records. Registry construction snapshots ordered `FunctionDefinition` values, rejects duplicate
    names, preserves body source/payload/parse-job/optional AST, exposes the staged job queue and neutral descriptor/
    JSON projections, and supplies the concrete exact-arity interface consumed by `.3.2`. Body-AST stitching
    returns a new typed `SpecFile` and validates the job's `replace_field` / `body_ast` policy. Invocation framing
    accepts already-evaluated scalar/array/harray/codeblock values, copies mutable values into fresh data-only
    variable/array/harray stores, reparses copied codeblock source, never accepts caller stores or Lua functions,
    and rejects ambiguous tables and cycles. Unknown/arity/recursion failures are typed; recursion carries stable
    stage, rule, helper, handler-source, and cycle identity. The focused gate passes syntax/process/manifest checks
    and 50/50 tests on both PUC Lua and LuaJIT; exact 239-name/105-fixture coverage remains green. Full local CI
    passes phase0 `1..1030`, both 61-case CLI environments, the 60/0/0 admitted-backend census, and doctrines.
  Commit: `LUA-BACKEND-PARITY.3.3 - add Lua function registry`

  Artifact observation 2026-07-11: disk free space fell from about 51 GB to 42 GB while LinkedSpec gates ran, but
    `du` showed the LinkedSpec Claude scratch subtree at 0 bytes and repository build output at 8 KB. The pressure
    is external: active Nexsim `cargo-mutants` scratch is about 8.2 GB and Pgen Claude scratch is about 16 GB,
    including old multi-gigabyte logs while a current release/PGO build is also running. Live PIDs confirmed both
    projects have active producers, so deleting either tree is not 100% safe. No external artifact was removed;
    the director clarified that this workflow sweeps only unused artifacts it owns. External cleanup remains with
    those projects/agents; LinkedSpec-owned scratch/build output is clean at this observation boundary.

### `LUA-BACKEND-PARITY.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.3.2` could query only an abstract registry interface; there was no ordered concrete
  owner for definitions, body jobs, body-AST stitching, exact function identity, or isolated invocation input.
- [x] **ROOT CAUSE (WHY + WHERE)** — Letting compiler/runtime tables or Lua closures stand in for the registry would
  lose neutral staged provenance and leak host state. The typed function shell needed a dedicated immutable bridge
  before compiled state and execution.
- [x] **FIX** — Added defensive registry snapshots, stable entries/resolutions/descriptors, exact-arity lookup,
  staged job enumeration, immutable body-AST stitching, four-kind deep copies into fresh frames, and source-labeled
  typed recursion diagnostics.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 50/50 on PUC Lua and 50/50 on LuaJIT. Tests lock
  ordering, definition snapshot isolation, staged jobs, duplicate/unknown/arity outcomes, concrete resolver
  precedence, immutable AST stitching, eager input framing, caller isolation, fresh stores, and recursion identity.
- [x] **NO REGRESSION** — Exact 239-name and 105-fixture coverage, parser/validator/function-shell/ActionIR/process
  proofs remain green. No function body executes, no staged job dispatches, and no caller store, Lua closure,
  primary CLI, corpus execution, capability, or generated-source claim is introduced. Full local CI passes phase0
  `1..1030`, CLI 61x2, capability/generated-source/native-resolution, and doctrine checks.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README API, Knowledge Map, changes/development/live status,
  and bounded memory close registry ownership and activate typed compiled state `.3.4`.

- ID: `LUA-BACKEND-PARITY.3.4`
  Status: `active`
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
| 3 | `LUA-BACKEND-PARITY.1.3` | `done` | Strict typed JSON and exact 105-case manifest/fixture IO pass both runtimes. |
| 4 | `LUA-BACKEND-PARITY.2.1` | `done` | Typed neutral source/provenance AST round-trips all node/body variants. |
| 5 | `LUA-BACKEND-PARITY.2.2` | `done` | Core source parser accepts 21 shipped and 102 rule-only corpus specs. |
| 6 | `LUA-BACKEND-PARITY.2.3` | `done` | Validator/strict syntax and exact 239-name collision inventory pass. |
| 7 | `LUA-BACKEND-PARITY.2.4` | `done` | Spec-produced function nodes/projected provenance compose without a raw scanner. |
| 8 | `LUA-BACKEND-PARITY.3.1` | `done` | Typed ActionIR parsing passes 41/41 on PUC Lua and LuaJIT. |
| 9 | `LUA-BACKEND-PARITY.3.2` | `done` | Typed current-name contracts and generic diagnostics pass both runtimes. |
| 10 | `LUA-BACKEND-PARITY.3.3` | `done` | Ordered registry/jobs, exact calls, immutable stitching, and isolated frames pass both runtimes. |
| 11 | `LUA-BACKEND-PARITY.3.4` | `active` | Compile source AST into typed effective state and descriptors. |

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
| `LUA-BACKEND-PARITY.1.3` | `LUA-BACKEND-PARITY.1.3 - add strict Lua corpus IO` | Pure-Lua typed JSON, strict UTF-8, exact 105-fixture drift validation, and source-AST handoff. |
| `LUA-BACKEND-PARITY.2.1` | `LUA-BACKEND-PARITY.2.1 - add typed Lua source AST` | Neutral nodes/provenance, complete body variants, lossless JSON, and parser handoff. |
| `LUA-BACKEND-PARITY.2.2` | `LUA-BACKEND-PARITY.2.2 - parse Lua rule source` | Public typed rule parser, quote/nesting/separator proofs, and validator handoff. |
| `LUA-BACKEND-PARITY.2.3` | `LUA-BACKEND-PARITY.2.3 - validate Lua source AST` | Stable source/registry/edge/regex/strict checks, exact call-name inventory, and function projection handoff. |
| `LUA-BACKEND-PARITY.2.4` | `LUA-BACKEND-PARITY.2.4 - project Lua function shells` | Spec-owned nodes, Unicode spans, staged sidecars, no raw scanner, and ActionIR handoff. |
| `LUA-BACKEND-PARITY.3.1` | `LUA-BACKEND-PARITY.3.1 - parse typed Lua ActionIR` | Structural actions, four values, access/assign/control/chains, generic final blocks, and contract-resolution handoff. |
| `LUA-BACKEND-PARITY.3.2` | `LUA-BACKEND-PARITY.3.2 - resolve Lua ActionIR contracts` | Exact current-name contracts, aliases/families, generic diagnostics, registry-first seam, and registry handoff. |
| `LUA-BACKEND-PARITY.3.3` | `LUA-BACKEND-PARITY.3.3 - add Lua function registry` | Ordered definitions/jobs, exact resolution, immutable stitching, isolated frames, and compiled-state handoff. |
