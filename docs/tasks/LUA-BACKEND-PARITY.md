# LUA-BACKEND-PARITY: Lua LinkedSpec Backend Parity

## Metadata

- Tree ID: `LUA-BACKEND-PARITY`
- Status: `active`
- Roadmap lane: `Overall roadmap - future backend parity (Lua third)`
- Created: `2026-07-11`
- Last updated: `2026-07-13` (copied harray construction/splicing `.4.3.5.1` done; deterministic views `.4.3.5.2` active)
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
  Status: `done`
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
  Status: `done`
  Goal: Compile source AST into typed effective state and descriptors.
  Acceptance: Ordered effective rules/functions, modes, regex/dependency state, action/blind/lifecycle payloads,
    source identities, and outward descriptor JSON match the exact shared contract.
  Verification: **PASS 2026-07-11.** Added typed compiled-spec/rule/mode/dependency/action-edge/blind-edge/action-
    payload/dependency-regex/descriptor state and exception records. Public `compile_spec(...)` snapshots and
    validates typed source by default, carries the ordered function registry, records source definition order,
    derives deterministic last-definition rule order/redefinition metadata when validation is explicitly skipped,
    and compiles rule modes, regex slots, dependency refs, action/blind edges, lifecycle/plain blocks, source
    identity, parsed ActionIR, and registry-aware contracts. Child dependency slots resolve to copied parent regex
    rows with stable zero-based indexes; invalid slots/labels are typed. `to_descriptor_json(...)` matches the
    executable shared schema exactly: four top-level keys, three model identities, order/count metadata, canonical
    function records, Lua interpreter handler identity, and structured dependency-regex rows. The focused gate
    passes syntax/process/manifest checks and 55/55 tests on PUC Lua and LuaJIT; exact 239-name/105-fixture coverage
    remains green. Full local CI passes phase0 `1..1030`, CLI 61x2, census 60/0/0, and doctrines.
  Commit: `LUA-BACKEND-PARITY.3.4 - compile Lua spec state`

### `LUA-BACKEND-PARITY.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua had typed source, ActionIR/contracts, and registry records but no effective rule
  model, dependency-regex derivation, or outward descriptor for compiler/runtime/tooling consumers.
- [x] **ROOT CAUSE (WHY + WHERE)** — Runtime ownership cannot safely infer rule modes, regex indexes, body roles,
  or public descriptor fields from mutable source tables. The same typed compiler boundary used by Dart/Julia had
  to land before matching.
- [x] **FIX** — Added defensive source snapshots, ordered/last-definition compiled rule state, complete mode/edge/
  payload metadata, child-regex slot resolution, dependency-regex state, registry-aware ActionIR contracts, typed
  failures, neutral JSON, and the exact executable outward descriptor projection.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 55/55 on PUC Lua and 55/55 on LuaJIT. Tests lock
  public parsed-source compilation, source isolation, modes, regex/dependencies, action/blind/lifecycle/plain
  payload structure, registry contracts, redefinitions, typed failures, exact schema keys/models/functions, and
  canonical JSON round-trip.
- [x] **NO REGRESSION** — Source/function/ActionIR/registry/process/corpus-manifest/239-name proofs remain green;
  no regex engine, match execution, staged dispatch, primary CLI, corpus execution, capability, or generated-source
  claim is introduced. Full local CI passes phase0 `1..1030`, CLI 61x2, capability/generated-source/native-
  resolution, and doctrine checks.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README API, Knowledge Map, changes/development/live status,
  and bounded memory close compiler layer `.3` and activate regex/match-state adapter `.4.1`.

- ID: `LUA-BACKEND-PARITY.4`
  Status: `active`
  Goal: Implement matching and runtime execution.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`

- ID: `LUA-BACKEND-PARITY.4.1`
  Status: `done`
  Goal: Select and prove the regex/match-state adapter.
  Acceptance: Compare available Lua/LPeg/native-extension options against neutral regex fixtures; implement
    seek/consume, alternatives, captures/named captures, entry/local state, UTF-8 character offsets, line/column,
    zero progress, and invalid-pattern diagnostics without backend-specific regex semantics.
  Verification: **PASS 2026-07-11.** Direct probes confirmed LPeg on both runtimes but rejected it as the provider:
    LPeg constructs PEGs and does not parse the governed PCRE dialect. No `rex_*` binding is installed; system
    PCRE2 10.47, headers, `pkg-config`, and both Lua ABIs are available. Added a minimal repository-owned PCRE2 C
    binding plus a build script that compiles separate PUC/LuaJIT modules into one disposable caller-owned
    `/private/tmp/linkedspec-lua-native.*` tree; the local gate removes it on every exit, writes no repo/global
    binary/cache, and uses no LuaRocks/network/subprocess matching. Added typed alternatives, matches, line/column,
    immutable entry/local registers, errors, and JSON. Ordered seek chooses earliest start then source alternative;
    consume anchors at the byte cursor. Full/compacted/named captures, explicit zero-width presence, child-entry
    seeding, progress guards, strict-UTF-8 boundary validation, byte/code-unit and Unicode character positions, and
    compiled-rule inputs match the neutral model. Focused dialect proof covers inline flags, POSIX classes,
    possessive quantifiers, Python named captures, recursion, and `\K`. The gate passes 60/60 tests on both runtimes,
    exact 239-name/105-fixture coverage, and leaves no native artifact. Full local CI passes phase0 `1..1030`, CLI
    61x2, census 60/0/0, and doctrines.
  Commit: `LUA-BACKEND-PARITY.4.1 - add Lua runtime matching`

### `LUA-BACKEND-PARITY.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Compiled regex rows existed only as strings; Lua had no conforming regex provider,
  stable alternative selection, match records, character positions, or entry/local register state.
- [x] **ROOT CAUSE (WHY + WHERE)** — LPeg is not a PCRE parser and pure Lua patterns omit required syntax. Shelling
  out would violate native in-memory embedding, while one ABI-specific binary would violate PUC/LuaJIT parity.
- [x] **FIX** — Added a narrow PCRE2 binding built per runtime ABI into disposable owned storage, typed neutral
  matching/position/register/error records, seek/consume selection, capture projection, and compiled-rule input.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 60/60 on PUC Lua and 60/60 on LuaJIT. Tests lock
  advanced governed syntax, stable alternative identity, consume anchoring, compact/named captures, Unicode byte/
  character/line/column positions, entry/local separation, zero-width presence/progress, JSON, and typed failures.
- [x] **NO REGRESSION** — Frontend/ActionIR/registry/compiler/process/manifest/239-name proofs remain green. The gate
  creates and removes only its own native temp tree; no rule dispatch, helpers, staged execution, primary CLI,
  corpus execution, capability, or generated-source claim is introduced. Full local CI passes phase0 `1..1030`,
  CLI 61x2, capability/generated-source/native-resolution, and doctrine checks.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, mdBook/README build and API docs, Knowledge Map, changes/development/
  live status, and bounded memory close matching `.4.1` and activate compiled rule interpreter `.4.2`.

- ID: `LUA-BACKEND-PARITY.4.2`
  Status: `done`
  Goal: Execute rule modes, dispatch, lifecycles, recursion, and result channels.
  Acceptance: Default/OR/AND/repetition acode/bcode paths, bounds, cursor state, explicit return/next/exit, retv,
    local stores, lifecycle order, recursion/safety cutoffs, and direct output shape match the oracle.
  Verification: **PASS 2026-07-11.** Added a typed Lua runtime engine/result/event/error boundary over compiled
    state and the `.4.1` matcher. Default, Single, AND, OR, optional, star/plus, and bounded modes execute regex or
    blind paths with action-edge child dispatch, entry/local register transfer, `retv`, narrow accumulators,
    cursor state, and a direct one-value output wrapper. Applicable `I/LS/LE/IT/EX/LX/E` ordering is recorded.
    `return(...)`, `return_undef()`, iteration-correct `next()`, and immediate typed `exit_now(...)` execute;
    false is preserved separately from null. Child rule bindings are copied/restored, bounds and invalid helpers
    fail through typed errors, and same-rule/cursor recursion plus zero-progress terminate safely. The focused gate
    passes 66/66 on both PUC Lua and LuaJIT with all prior process/manifest/current-name proofs green.
  Commit: `LUA-BACKEND-PARITY.4.2 - add Lua runtime rule interpreter`

### `LUA-BACKEND-PARITY.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua could compile neutral rules and match patterns but had no owner for executable
  rule modes, edges, lifecycle actions, child results, repetition, or direct parse output.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.4.1` intentionally stopped at match/register primitives. Without a runtime
  owner, callers could not preserve rule-local scopes, distinguish false/null results, interpret `next()` as an
  iteration control, or apply recursion/progress fences consistently with Dart/Julia.
- [x] **FIX** — Added `interpreter.lua` with typed engine/result/event/errors, compiled-rule dispatch, narrow
  ActionIR execution, lifecycle flow, local store isolation, `retv`, accumulators, repetition/control semantics,
  recursion/progress guards, and JSON projection; exported the API from the native module.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 66/66 on PUC Lua and 66/66 on LuaJIT. Focused
  cases lock default seek/consume repetition, action/blind children, AND/OR, bounds, lifecycle order, local stores,
  `retv`, `return`/`next`/`exit_now`, false/null identity, cursors, output shape, recursion, zero progress, and typed
  unsupported-helper failures.
- [x] **NO REGRESSION** — Frontend/ActionIR/registry/compiler/matching/process/manifest/239-name proofs remain
  green. Runtime helper breadth, staged functions, corpus execution, primary CLI, capability, and generated source
  remain explicit later owners; the gate removes only its own inactive native temp tree. Full local CI passes
  phase0 `1..1030`, CLI 61x2, capability/generated-source/native-resolution, and all doctrines.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, Lua README/API, mdBook handoff/status, Knowledge Map, changes/
  development/live status, and bounded memory close `.4.2` and activate helper-family split `.4.3.0`.

- ID: `LUA-BACKEND-PARITY.4.3`
  Status: `active`
  Goal: Implement the complete helper/value/control/method surface in recursively split batches.
  Children: `.4.3.0`, `.4.3.1`, `.4.3.2`, `.4.3.3`, `.4.3.4`, `.4.3.5`, `.4.3.6`, `.4.3.7`, `.4.3.8`,
    `.4.3.9`
  Acceptance: Every current governed helper and method is behavior-tested, including scalar/string/number,
    array/harray mutation and pure operations, captures/positions/cursor/marks, controls, assignments, tree walks,
    diagnostic calls, and final-codeblock equivalence; split by mechanism before broad implementation.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.0`
  Status: `done`
  Goal: Split the complete Lua helper/value/control/method surface into mechanism-sized executable leaves.
  Acceptance: Every current family has one ordered owner with explicit dependencies, scope, verification, and
    no-drift closeout; no broad helper implementation starts before the split is durable.
  Verification: **PASS 2026-07-11.** The 239-name runtime surface and mdBook helper catalog are divided into nine
    ordered implementation/closeout leaves: core four-kind stores/access/entry-match; scalar/string; numeric;
    arrays; harrays; value/control/block/callbacks; capture/mark/input/cursor state; diagnostic output; and final
    exhaustive no-drift. Each leaf names its dependency and focused acceptance, may split again before code, and
    leaves `.4.3.1` as the sole executable frontier. No runtime behavior changed; committed `.4.2` remains 66/66
    on both runtimes and its full local CI proof remains authoritative. mdBook, memory architecture, Knowledge Map,
    task-tree metadata, doctrine, and whitespace gates pass.
  Commit: `LUA-BACKEND-PARITY.4.3.0 - split Lua runtime helper families`

### `LUA-BACKEND-PARITY.4.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3` named four value kinds, every governed helper/method, controls, callbacks,
  captures, cursor/marks, and diagnostic calls in one leaf; that is not a safe signoff-sized implementation unit.
- [x] **ROOT CAUSE (WHY + WHERE)** — The mdBook catalog and completed Dart/Julia rollouts show distinct store,
  scalar/string, numeric, array, harray, control/block, stateful cursor/capture, and diagnostic mechanisms. Lua also
  needs an explicit exhaustive closeout so recognizing 239 names cannot be mistaken for executing them.
- [x] **FIX** — Converted `.4.3` into a ten-child container (`.0` planning plus `.1`-`.9` execution/closeout),
  ordered by dependency and leaving recursively smaller splits available before any broad code leaf starts.
- [x] **ADDRESSED (verified)** — Every current helper/catalog family has one owner and `.4.3.1` is the only active
  code frontier; no implementation behavior or capability claim changed.
- [x] **NO REGRESSION** — The committed `.4.2` 66x2/full-CI proof remains green and unchanged. Planning checks
  cover mdBook, memory architecture, Knowledge Map, task metadata, doctrine, and whitespace.
- [x] **LOCKSTEP** — Task tree/index, roadmaps, Lua README, mdBook handoff/status, Knowledge Map, architecture/live
  docs, changes/development notes, and bounded memory record the same ordered split.

- ID: `LUA-BACKEND-PARITY.4.3.1`
  Status: `done`
  Goal: Centralize Lua's four-kind runtime stores, structural access/assignment, snapshots, and entry/match reads.
  Dependencies: `.4.2`
  Acceptance: Scalar/array/harray/codeblock/null/boolean/number values retain typed identity; named and bare store
    reads/writes, append/hash-index/nested assignment without autovivification, copy/array/hash snapshots, and all
    `entry_*` / `match_*` text/group/map/position helpers pass focused cross-backend examples.
  Verification: **PASS 2026-07-11.** Added public four-kind runtime classification and defensive codeblock
    snapshots; centralized scalar/array/harray stores with competing-slot replacement and per-rule copy/restore;
    implemented bare/typed snapshots, scalar/append/hash-index assignment, zero-based array and string-key harray
    reads, checked nested mixed access/assignment with no intermediate autovivification, and current-edge `retv`
    dispatch. Added all `entry_*` / `match_*` text, compact group, named/presence/map, Unicode length/span, and
    start/end line/column helpers with absent-match null/empty/origin distinctions. Focused gate passes 69/69 on
    PUC Lua and LuaJIT; positive/fixed-width negative lookbehind now have permanent dual-ABI proof, and Dart's real
    `spec_spec_minimal_rule` fixture passes 1/1. Prior source/ActionIR/compiler/matching/dispatch/process/manifest
    proofs remain green.
  Commit: `LUA-BACKEND-PARITY.4.3.1 - add Lua runtime value capture helpers`

### `LUA-BACKEND-PARITY.4.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.2` could retain a few scalar locals and literal shapes but lacked one four-kind
  store/access owner, aggregate snapshot isolation, checked nested assignment, codeblock copying, and most governed
  entry/match reads.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` used truthy fallback and direct table paths around a narrow
  dispatcher. Lua tables do not identify arrays, harrays, codeblocks, absence, or storage intent without explicit
  typed routing, and current-edge `retv` had to dispatch its child before reading.
- [x] **FIX** — Added explicit four-kind classification/copy, scalar/array/harray binding helpers, typed target and
  access routing, checked copy-on-write mixed paths, named/compact capture projections, Unicode positions, and
  absent-match contracts; exported `runtime_value_kind(...)`.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 69/69 on both runtimes. New cases prove stored
  scalar/array/harray/codeblock values, false/null identity, named stores, append/hash/nested mutation, snapshot
  isolation, failed-path no-autovivification, current-edge `retv`, full entry/match families, Unicode lines/spans,
  and absent null/empty/origin behavior.
- [x] **NO REGRESSION** — Existing 66 interpreter tests plus frontend/registry/compiler/matcher/process/manifest/
  exact-name checks remain green. The director-raised `spec.spec` lookbehind concern is resolved by actual engine/
  corpus proof rather than host-language assumptions; scalar/string pure helpers and later families remain owners.
  Full local CI passes phase0 `1..1030`, CLI 61x2, capability/generated-source/native-resolution, and doctrines.
- [x] **LOCKSTEP** — Roadmaps, task index/tree, Lua API README, mdBook handoff/status, Knowledge Map, architecture/
  live docs, changes/development notes, and memory advance to scalar/string `.4.3.2`.

- ID: `LUA-BACKEND-PARITY.4.3.2`
  Status: `done`
  Goal: Implement scalar/string helpers and compatible receiver chains.
  Children: `.4.3.2.0`, `.4.3.2.1`, `.4.3.2.2`
  Dependencies: `.4.3.1`
  Acceptance: Definedness/emptiness/coalesce, `cat`, trim/case/length, substring/prefix/suffix/contains/replace,
    regex match/substitution flags, split bridges, lexical comparisons, scalar statement mutation, and receiver
    forms match catalog examples across the child leaves.
  Verification: **PASS 2026-07-12.** Pure scalar/string, exact Unicode 17 casing, six-variant scalar text, strict
    helper regex/matches, literal/regex/Unicode split, scalar substitution, explicit array split replacement, and
    focused public no-drift pass. Full PUC Lua/LuaJIT gates are 76/76; numeric helpers `.4.3.3` are next.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.2.0`
  Status: `done`
  Goal: Split pure scalar evaluation from regex-aware split/substitution and statement mutation before code.
  Acceptance: The two mechanisms have ordered owners and `.4.3.2.1` is the sole executable frontier.
  Verification: **PASS 2026-07-11.** Pure scalar/string value dispatch and compatible receivers are owned by
    `.4.3.2.1`; regex matching/replacement flags, split bridges, and statement-only named mutation are owned by
    `.4.3.2.2`. No code/capability changed. mdBook, memory, Knowledge Map, task metadata, doctrine, and whitespace
    checks pass; committed `.4.3.1` remains 69/69 on both Lua ABIs with full local CI green.
  Commit: `LUA-BACKEND-PARITY.4.3.2.0 - split Lua scalar string mechanisms`

### `LUA-BACKEND-PARITY.4.3.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.4.3.2` combined pure string values/receivers with PCRE replacement, split bridges,
  flag semantics, and statement-only mutation even though they have different dependencies and failure modes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Pure transformations need only scalar conversion/truth/null rules; regex and
  split mutation need the native matcher dialect, replacement expansion, named-store intent, and value-versus-
  statement boundaries. One implementation commit would obscure those contracts.
- [x] **FIX** — Converted `.4.3.2` into a three-child container: `.0` planning, `.1` pure scalar/string, `.2`
  regex/split/mutation, leaving the broader `.4.3.9` exhaustive closeout unchanged.
- [x] **ADDRESSED (verified)** — `.4.3.2.1` is the only active code frontier and every original acceptance item has
  one ordered owner; no runtime behavior changed.
- [x] **NO REGRESSION** — Committed `.4.3.1` remains 69/69 on both ABIs/full CI green; docs/governance gates pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, KM, architecture/live docs, changes/notes, and memory agree.

- ID: `LUA-BACKEND-PARITY.4.3.2.1`
  Status: `done`
  Goal: Implement pure scalar/string helpers, lexical comparisons, aliases, and compatible receiver chains.
  Children: `.4.3.2.1.0`, `.4.3.2.1.1`, `.4.3.2.1.2`, `.4.3.2.1.3`
  Dependencies: `.4.3.1`
  Acceptance: `concat`/`cat`, coalesce families, defined/undefined/empty predicates, trim/case/length, prefix/
    suffix/contains/remove, literal substring/replace, explicit `str_*` comparisons, stable scalar conversion,
    null propagation, and function/receiver composition match cross-backend examples.
  Verification: **PASS 2026-07-12.** Deterministic non-case strings, pinned Unicode 17 casing, and portable
    scalar-to-text coercion are complete through `.1.1`, `.1.2`, and `.1.3`.
  Commit: closed by `.4.3.2.1.3`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.0`
  Status: `done`
  Goal: Isolate deterministic pure-string execution from the newly measured cross-backend Unicode casing policy gap.
  Dependencies: `.4.3.1`
  Acceptance: Measure special-case lower/uppercase behavior through real Perl, Rust-source, Dart, and Julia paths;
    record the root cause and exact divergent examples; give non-casing helpers and canonical Unicode casing separate
    ordered owners before runtime code changes.
  Verification: **PASS 2026-07-11.** Direct Perl, Dart, and Julia probes plus Rust runtime-source inspection prove
    divergent special-case results. A Knowledge Map fact card and public warning preserve the exact evidence.
    Deterministic non-case helpers are isolated in `.1`; version/policy/neutral fixture/all-variant repair are `.2`.
    Knowledge Map generation/validation, mdBook build, memory/task/doctrine metadata, and whitespace checks pass.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.0 - split Unicode casing parity`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.1`
  Status: `done`
  Goal: Implement deterministic pure scalar/string helpers and compatible receiver chains except case conversion.
  Dependencies: `.4.3.2.1.0`
  Acceptance: `cat`, coalesce families, defined/undefined/empty predicates, trim/length, prefix/suffix/contains/remove,
    literal substring/replace, explicit `str_*` comparisons, stable scalar conversion, null propagation, lazy fallback,
    and function/receiver composition match cross-backend examples on both Lua ABIs.
  Verification: **PASS 2026-07-11.** Lua now executes lazy `coalesce`/`coalesce_nonempty`, `cat`, definedness/
    emptiness, Unicode-whitespace trim and codepoint length/substrings, literal prefix/suffix/contains/remove/replace,
    six `str_*` comparisons, reference-style stable scalar text, and compatible receiver chains. Null/false/empty
    remain distinct; terminal string results reject later string links. One focused test adds 40 assertions and the
    shared gate passes 70/70 on both PUC Lua and LuaJIT with owned native artifacts removed. Full CI passes phase0
    `1..1030`, CLI 61x2, capability 60/0/0, KM/book/governance, and cleanup.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.1 - add Lua pure string helpers`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.2`
  Status: `done`
  Goal: Define and implement one versioned Unicode lower/uppercase contract across every LinkedSpec variant.
  Children: `.4.3.2.1.2.0`, `.4.3.2.1.2.1`, `.4.3.2.1.2.2`, `.4.3.2.1.2.3`, `.4.3.2.1.2.4`
  Dependencies: `.4.3.2.1.1`
  Acceptance: Select a canonical Unicode version and simple/full/special-casing policy; add a neutral fixture covering
    ordinary non-ASCII and divergent special cases (`ß`, `İ`, and `ﬃ`); align Perl, Rust, Dart, Julia, PUC Lua, and
    LuaJIT values and receiver chains without confusing Unicode semantics with UTF-8/UTF-16 host representation.
  Verification: **PASS 2026-07-12.** Unicode 17 full-default behavior is generated from one checksum-locked contract
    and passes the same 12 fixtures on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.
  Commit: closed by `.4.3.2.1.2.4`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.2.0`
  Status: `done`
  Goal: Adopt the signoff Unicode casing policy and split its data/backend rollout before implementation.
  Dependencies: `.4.3.2.1.1`
  Acceptance: Record one versioned full-default locale-independent policy, normative data inputs, context behavior,
    normalization/encoding boundaries, generated-artifact drift gates, and bounded backend rollout owners.
  Verification: **PASS 2026-07-12.** Director authorized the expert signoff/SOTA route. ADR `0027` pins Unicode
    17.0.0 Default Case Conversion with full mappings, standard context rules, no locale tailoring, and no implicit
    normalization. `.1` owns official data/generator/contract; `.2` Perl/Rust; `.3` Dart/Julia; `.4` Lua and final
    admission. No runtime behavior changed. KM, mdBook, task/roadmap/live docs, memory, doctrines, and whitespace pass.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.2.0 - adopt Unicode casing contract`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.2.1`
  Status: `done`
  Goal: Add the reproducible Unicode 17.0.0 data, generator, neutral contract, fixtures, and drift checker.
  Dependencies: `.4.3.2.1.2.0`
  Acceptance: Verified official `UnicodeData.txt`, `SpecialCasing.txt`, and `DerivedCoreProperties.txt` inputs plus
    license/source hashes generate deterministic lower/upper maps and Cased/Case_Ignorable ranges; the executable
    neutral fixture covers identity, expansion, combining output, supplementary characters, and Final_Sigma context;
    regeneration and schema/count/hash checks fail closed without requiring network during ordinary gates.
  Verification: **PASS 2026-07-12.** Exact official bytes are stored as deterministic gzip under
    `unicode_case/upstream/17.0.0/` and verified after decompression against four pinned SHA-256 values. The neutral
    contract contains 1,563 lower mappings, 1,581 upper mappings, 158 Cased and 464 Case_Ignorable merged ranges,
    one Final_Sigma rule, and 12 exact fixtures. Generator/checker regeneration is byte-identical and independently
    executes all fixtures. Full local CI passes the new tracked contract step, CLI 61x2, phase0 `1..1030` in 495s,
    capability 60/0/0, generated/native contracts, doctrines, KM/book, whitespace, and owned cleanup.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.2.1 - add Unicode casing data contract`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.2.2`
  Status: `done`
  Goal: Align Perl and Rust casing helpers to the generated Unicode 17.0.0 contract.
  Dependencies: `.4.3.2.1.2.1`
  Acceptance: Function and receiver lower/uppercase paths consume generated tables/context rules, not host Unicode
    versions; neutral fixture and focused/full Perl/Rust gates pass without changing null/aggregate boundaries.
  Verification: **PASS 2026-07-12.** The generator now byte-deterministically emits
    `perl/LinkedSpec/UnicodeCaseMapping.pm` and `rust/linkedspec-runtime/src/unicode_case_mapping.rs` from the
    neutral contract. Perl ActionIR scalar, receiver, value-array, and mutating-array paths and all three Rust
    runtime casing seams use those modules; source audits find no host casing call left in the owned paths. All 12
    fixtures pass direct/helper/receiver/array execution in both backends. Focused Perl passes 52 tests; full Perl
    phase0 passes `1..1030` in 491s; the complete Rust runtime package passes 137 unit, 105-case oracle, full
    generated-source classifier, 196 integration, source-emitter/loader/diagnostic/trace, and Unicode tests. The
    authoritative local CI rerun passes CLI 61x2 and phase0 `1..1030` in 494s plus all contracts/doctrines/docs gates.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.2.2 - align Perl and Rust Unicode casing`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.2.3`
  Status: `done`
  Goal: Align Dart and Julia casing helpers to the generated Unicode 17.0.0 contract.
  Dependencies: `.4.3.2.1.2.2`
  Acceptance: Function and receiver lower/uppercase paths consume generated tables/context rules, not host Unicode
    versions; the same neutral fixture and focused/full Dart/Julia gates pass with exact strings.
  Verification: **PASS 2026-07-12.** The generator/checker byte-compare deterministic Dart and Julia modules.
    Scalar helper, receiver, value-array, and mutating-array execution uses the generated Unicode 17 evaluator in
    both backends. All 12 fixtures pass through every path (Dart focused 1 test; Julia 39 assertions). Full Dart
    local gate passes formatter/analyzer, 182 tests, CLI 61x2, and corpus 105/105. Full Julia local gate passes the
    package suite, primary CLI process conformance, and corpus 105/105.
    Authoritative full local CI also passes CLI 61x2 and phase0 `1..1030` in 493s plus every shared gate.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.2.3 - align Dart and Julia Unicode casing`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.2.4`
  Status: `done`
  Goal: Enable generated Unicode casing on PUC Lua/LuaJIT and admit exact six-variant parity.
  Dependencies: `.4.3.2.1.2.3`
  Acceptance: Lua function/receiver lower/uppercase paths use the same generated maps/context rules without native
    byte/locale casing; both ABIs pass, six-variant fixture outputs are byte-identical UTF-8, full gates/docs/KM pass,
    and `.4.3.2.1.2` closes before scalar-to-text `.1.3` begins.
  Verification: **PASS 2026-07-12.** Generated pure-Lua maps/properties plus strict UTF-8 scalar decode/encode pass
    all 12 fixtures through direct, helper, receiver, and array-value paths. PUC Lua and LuaJIT each pass 71/71;
    six-variant expected UTF-8 outputs are identical by the shared neutral fixture. Full local CI passes CLI 61x2
    and phase0 `1..1030` in 490s plus every shared gate.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.2.4 - admit six-variant Unicode casing`

- ID: `LUA-BACKEND-PARITY.4.3.2.1.3`
  Status: `done`
  Goal: Define one scalar-to-text coercion contract and align every LinkedSpec variant.
  Dependencies: `.4.3.2.1.2`
  Acceptance: A neutral fixture fixes `cat`/string-helper handling for null, array, harray, codeblock, booleans,
    integral-looking decimals, and nonintegral numbers; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT return identical
    values and nulls. Retired `concat` remains rejected rather than becoming an accidental alias.
  Verification: **PASS 2026-07-12.** ADR `0028` and `linkedspec-scalar-text-v1` define strings unchanged,
    booleans as `1`/`0`, stable finite decimal text, and null for non-text kinds. One neutral executable fixture
    passes on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; the Lua suite is 72/72 on both ABIs. Codeblock is
    normatively non-text without preempting the explicit final-codeblock syntax owner `.11.1`; `concat` remains
    retired. Full Rust, Dart, Julia, dual-ABI Lua, and canonical local CI gates pass.
  Commit: `LUA-BACKEND-PARITY.4.3.2.1.3 - align scalar text coercion`

- ID: `LUA-BACKEND-PARITY.4.3.2.2`
  Status: `done`
  Goal: Implement regex-aware scalar matching/substitution, split bridges, flags, and statement mutation.
  Children: `.4.3.2.2.0`, `.4.3.2.2.1`, `.4.3.2.2.2`, `.4.3.2.2.3`, `.4.3.2.2.4`, `.4.3.2.2.5`
  Dependencies: `.4.3.2.1`
  Acceptance: `matches`, regex/literal replacement, dual `substr`, scalar/array split bridges, governed flags and
    capture expansion, pure versus statement-only mutation, invalid-pattern boundaries, and receiver composition
    match the oracle on both Lua ABIs.
  Verification: **PASS 2026-07-12.** Ordered children close helper regex/matches, pure split, scalar regex mutation,
    explicit array split mutation, focused no-drift, and correct phase-6 routing for broader shipped fixtures.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.0`
  Status: `done`
  Goal: Measure and split Lua regex, split, and statement-mutation mechanisms before runtime code.
  Dependencies: `.4.3.2.1`
  Acceptance: LinkedSpec lowering/runtime probes and Lua ActionIR projections identify the distinct value,
    regex-compilation, receiver, scalar-store mutation, and array-store mutation seams; signoff-sized children own
    them in dependency order without changing runtime behavior.
  Verification: **PASS 2026-07-12.** `call_spec_handler_subst` proves the current Perl pure/mutation shapes; Lua
    ActionIR JSON proves regex pattern/flag and explicit target preservation. Source inspection locates the missing
    regex value evaluation and statement-context dispatch in `lua/src/linkedspec/interpreter.lua`; the PCRE2
    compiler seam already exists in `lua/src/linkedspec/matching.lua`. Knowledge and book contracts were checked
    before deriving the split.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.0 - split Lua regex string mechanisms`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.1`
  Status: `done`
  Goal: Add one strict Lua helper-regex value/flag adapter and execute `matches` in function/receiver form.
  Dependencies: `.4.3.2.2.0`, `.4.1`
  Acceptance: Lua ActionIR regex values compile through the existing in-process PCRE2 owner; `i/m/s/x` affect
    compilation, `g/o` are accepted no-ops for predicates, unknown flags and invalid patterns follow the documented
    fail-closed helper boundary, null/non-text inputs return false, and terminal receiver composition is exact on
    PUC Lua and LuaJIT. The pre-existing Perl invalid-literal generation boundary is recorded, not silently treated
    as Lua authorization to change the reference engine.
  Verification: **PASS 2026-07-12.** Lua evaluates regex ActionIR as an internal typed helper value, normalizes
    flags in stable `imsx` order, accepts `g/o` as predicate no-ops, caches successful and failed PCRE2 compilation,
    and executes `matches` identically in function and terminal receiver form. Null, non-regex, unknown-flag, and
    invalid-pattern inputs return false. The full PUC Lua/LuaJIT gate passes 73/73 on both ABIs.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.1 - add Lua helper regex matches`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.2`
  Status: `done`
  Goal: Implement pure literal/regex `split` values and the string receiver-to-array bridge.
  Dependencies: `.4.3.2.2.1`
  Acceptance: Function and receiver `split(value, delimiter)` preserve empty fields, distinguish literal and regex
    delimiters, split an empty literal delimiter by Unicode characters, apply the governed flag adapter, return an
    empty array on invalid regex input, and return a typed copied array from string receiver form without mutating
    sources. Downstream array-method continuation remains owned by `.4.3.4`, which depends on this bridge. Pure
    Unicode `substr` and literal `replace_substr` remain distinct and regression-locked.
  Verification: **PASS 2026-07-12.** Function and string-receiver `split` return copied typed arrays for literal
    and PCRE2 delimiters, preserve leading/trailing empty fields, split an empty literal delimiter by Unicode
    scalar bytes, handle zero-width regex delimiters with explicit progress, reuse strict helper flags, and return
    empty arrays for null/non-text/unknown/invalid inputs. Unicode `substr` and literal `replace_substr` remain
    distinct and pure. The full PUC Lua/LuaJIT gate passes 74/74 on both ABIs. Downstream array methods remain
    correctly owned by `.4.3.4`.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.2 - add Lua pure split bridge`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.3`
  Status: `done`
  Goal: Implement statement-context scalar regex substitution through `substr` and `regex_subst`.
  Dependencies: `.4.3.2.2.1`
  Acceptance: A dropped four-argument call with a bare scalar target mutates that target; `g` selects global
    replacement, `i/m/s/x` compile, `o` is a no-op, `$0`/`$n` replacement expansion is deterministic, invalid
    patterns diagnose with rule attribution, and pure character-slice `substr(value,start,width?)` stays a value
    helper even when its result is discarded.
  Verification: **PASS 2026-07-12.** Dropped four-argument `substr` and `regex_subst` calls now mutate bare scalar
    targets before pure helper evaluation. String and regex patterns share strict PCRE2 compilation; `g` controls
    global replacement, `i/m/s/x` compile, `o` is a no-op, and `$0`/`$n` expand per match. Zero-width global
    matches advance by a decoded Unicode scalar. Unknown flags and invalid patterns raise rule-attributed runtime
    diagnostics. Discarded numeric `substr` remains pure. The full PUC Lua/LuaJIT gate passes 75/75 on both ABIs.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.3 - add Lua scalar regex mutation`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.4`
  Status: `done`
  Goal: Implement explicit array-target split replacement without crossing pure value semantics.
  Dependencies: `.4.3.2.2.2`, `.4.3.2.2.3`
  Acceptance: Dropped `split(array(target), source, delimiter)` replaces the named aggregate store for literal and
    regex delimiters, respects rule-local reset/snapshot behavior, leaves pure split source values untouched, and
    preserves scalar-held versus explicit aggregate boundaries on both Lua ABIs.
  Verification: **PASS 2026-07-12.** Dropped `split(array(target), source, delimiter)` now replaces only the named
    explicit aggregate store, reusing pure literal/regex/Unicode split values and copying the result. Focused proof
    preserves literal empty fields, regex delimiters, source non-mutation, scalar-held pure split values, and pure
    value split. Existing rule-local store copy/restore remains the owner of invocation isolation. The full PUC
    Lua/LuaJIT gate passes 76/76 on both ABIs.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.4 - add Lua array split mutation`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.5`
  Status: `done`
  Goal: Close regex/split/mutation mechanism and public-documentation no-drift.
  Children: `.4.3.2.2.5.0`, `.4.3.2.2.5.1`
  Dependencies: `.4.3.2.2.2`, `.4.3.2.2.3`, `.4.3.2.2.4`
  Acceptance: Neutral focused fixtures cover the complete landed mechanism on both ABIs; catalog/book/README/task/
    KM/live state contain no retired `concat`, helper-flag, pure-versus-mutation, or frontier drift. Exact shipped
    execution stays owned by `.6.2`, after the later helper/control/output families and executable corpus runner.
  Verification: **PASS 2026-07-12.** Full dual-ABI gate passes 76/76. A non-host `concat(` call-shape scan is
    clean across current Lua/spec/capability/book/roadmap surfaces after correcting stale positive roadmap/catalog
    prose to canonical `cat`; historical retirement text remains non-executable. Task/KM/book/status state agrees.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.5.0`
  Status: `done`
  Goal: Diagnose and correctly route the premature shipped-corpus acceptance before closeout work.
  Verification: **PASS 2026-07-12.** A disposable native in-memory probe showed `portmap_constant` and both EBNF
    cases stop at later-owned `control_if`, `simenv_multiline_value` stops at later-owned `print`, and both
    `lib_reader` cases execute but remain empty behind later array/child-flow breadth. The official corpus runner
    deliberately rejects `--execute` until phase 6. Exact named-case proof is therefore routed to `.6.2` rather
    than weakening fixtures or blocking scalar/string closure on unrelated families.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.5.0 - route Lua string corpus proof`

- ID: `LUA-BACKEND-PARITY.4.3.2.2.5.1`
  Status: `done`
  Goal: Close focused regex/split/mutation and public-surface no-drift.
  Dependencies: `.4.3.2.2.5.0`
  Acceptance: Both Lua ABIs pass the complete focused gate; public docs explain pure versus statement mutation,
    strict flags, captures, empty fields, and the current explicit-target compatibility boundary; current authored
    surfaces contain no retired `concat`; task/roadmap/KM/book/status state agrees before numeric helpers.
  Verification: **PASS 2026-07-12.** PUC Lua and LuaJIT pass 76/76; strict flag, capture, empty-field, pure/value,
    statement-mutation, invalid-boundary, and explicit-target compatibility docs agree. Public active helper
    reference now leads with `cat`; stale positive `concat` roadmap prose is corrected. Numeric `.4.3.3` activates.
  Commit: `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.3`
  Status: `done`
  Goal: Implement numeric helpers, aliases, symbol callees, reducers, and number receiver chains.
  Children: `.4.3.3.0`, `.4.3.3.1`, `.4.3.3.2`, `.4.3.3.3`, `.4.3.3.4`
  Dependencies: `.4.3.1`
  Acceptance: Arithmetic/unary/clamp/comparison/range and aggregate min/max/sum/avg/median behavior, invalid-input
    null propagation, division/modulo fences, word aliases, symbol callees, and receiver forms match the oracle.
  Verification: **PASS 2026-07-12.** The strict 55-case scalar contract is exact across six runtime variants.
    Lua canonical calls, every word/symbol alias, numeric receiver composition/comparison terminality, strict
    copied-array reducers, and all six array receiver terminals pass 91/91 on PUC Lua and LuaJIT. Focused closeout
    proves every reducer canonical/alias spelling directly, aligns public/status surfaces, and preserves exact
    shipped-corpus execution under dependency-complete phase 6.
  Commit: `LUA-BACKEND-PARITY.4.3.3.4 - close Lua numeric helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.3.0`
  Status: `done`
  Goal: Audit the neutral numeric contract and split implementation by runtime mechanism before code.
  Verification: **PASS 2026-07-12.** Knowledge Map cards, the public helper catalog, Perl/Rust/Dart/Julia runtime
    seams and focused tests, Lua ActionIR contracts, and the current Lua evaluator were inspected. Canonical alias
    and symbol resolution already exists in `action_contracts.lua`; Lua still lacks numeric value dispatch,
    receiver injection/terminal handling, and aggregate reducer execution. Scalar evaluation, receiver admission,
    reducers, and closeout are independently verifiable and now have separate children. The full Lua local gate
    passes 76/76 on both PUC Lua and LuaJIT after the planning-only split.
  Commit: `LUA-BACKEND-PARITY.4.3.3.0 - split Lua numeric helper mechanisms`

- ID: `LUA-BACKEND-PARITY.4.3.3.1`
  Status: `done`
  Goal: Implement strict scalar numeric helper evaluation.
  Children: `.4.3.3.1.0`, `.4.3.3.1.1`, `.4.3.3.1.2`, `.4.3.3.1.3`, `.4.3.3.1.4`
  Dependencies: `.4.3.3.0`
  Acceptance: Canonical unary, variadic arithmetic, integer modulo, clamp, scalar min/max, and comparisons accept
    only portable finite decimal values; invalid/missing/aggregate/boolean inputs, zero divisors, non-integer
    modulo operands, inverted bounds, and non-finite results return null identically on PUC Lua and LuaJIT.

- ID: `LUA-BACKEND-PARITY.4.3.3.1.0`
  Status: `done`
  Goal: Measure cross-backend scalar numeric drift and split neutral policy from backend implementation.
  Dependencies: `.4.3.3.0`
  Verification: **PASS 2026-07-12.** LinkedSpec `Get` probes plus direct Perl/Rust/Dart/Julia runtime/test/source
    inspection found incompatible boolean, invalid-comparison, call-arity, numeric-string, and signed-modulo
    behavior. No backend is a complete accidental contract: the public book says invalid numeric inputs return
    null, while Perl remains the reference for fixed-versus-variadic lowering and modulo sign. Neutral policy/data,
    admitted-backend repair, and Lua implementation require separate signoff leaves before receiver work.
  Commit: `LUA-BACKEND-PARITY.4.3.3.1.0 - split scalar numeric contract alignment`

- ID: `LUA-BACKEND-PARITY.4.3.3.1.1`
  Status: `done`
  Goal: Adopt a versioned neutral scalar numeric helper contract and executable fixtures.
  Dependencies: `.4.3.3.1.0`
  Acceptance: An ADR and machine-readable contract define accepted finite decimal inputs, exact/variadic arities,
    invalid-to-null behavior, numeric comparison truth, half-away rounding, min/max, clamp, division, and signed
    integer modulo without host-language fallback; an offline checker validates schema/cases and tracked inputs.
  Verification: **PASS 2026-07-12.** ADR `0029` and `linkedspec-scalar-numeric-v1` define 18 canonical scalar
    helpers across 55 exact cases: strict finite decimal values, explicit arities, invalid-to-null, numeric
    comparisons, half-away rounding, variadic scalar min/max, clamp/division fences, and floor signed modulo.
    `tools/check_scalar_numeric_contract.py` independently evaluates every case, regenerates the complete `.spec`
    fixture, and runs in local CI. The checker, Knowledge Map, doctrine/memory gates, and mdBook build pass. The
    authoritative full local gate passes both 61-case CLI environments and phase0 `1..1030` in 559 seconds.
  Commit: `LUA-BACKEND-PARITY.4.3.3.1.1 - adopt scalar numeric helper contract`

- ID: `LUA-BACKEND-PARITY.4.3.3.1.2`
  Status: `done`
  Goal: Align Perl and Rust scalar numeric helpers with the neutral contract.
  Dependencies: `.4.3.3.1.1`
  Acceptance: Direct canonical helper execution in both backends consumes every contract case; booleans and invalid
    operands return null, arities are exact/variadic as governed, signed modulo and numeric strings match, and full
    Perl/Rust gates pass without weakening unrelated generic scalar coercion.
  Verification: **PASS 2026-07-12.** Perl generated actions now route canonical scalar-value paths through a
    dedicated strict adapter, with fixed-arity/aggregate overload fences remaining in the frontend; independently
    loadable generated source declares the dependency. Rust uses a
    helper-local strict finite-decimal adapter without changing generic `RuntimeValue::as_number`. Both execute the
    unchanged 55-case fixture exactly, including boolean/aggregate rejection, exact arities, invalid nulls,
    half-away rounding, strict strings, and floor signed modulo. Canonical local CI passes both Perl 61-case CLI
    environments and phase0 `1..1030` in 511 seconds. The Rust local gate passes the complete runtime package,
    formatting, and both 61-case CLI environments; library clippy passes with established unrelated warnings.
  Commit: `LUA-BACKEND-PARITY.4.3.3.1.2 - align Perl Rust scalar numeric helpers`

- ID: `LUA-BACKEND-PARITY.4.3.3.1.3`
  Status: `done`
  Goal: Align Dart and Julia scalar numeric helpers with the neutral contract.
  Dependencies: `.4.3.3.1.1`, `.4.3.3.1.2`
  Acceptance: Both native interpreters consume every unchanged contract case through direct canonical calls;
    numeric parsing, arity, invalid/null, signed modulo, and result normalization agree with Perl/Rust, and full
    package/CLI/corpus gates pass.
  Verification: **PASS 2026-07-12.** Dart and Julia now enforce the v1 strict finite-decimal grammar without
    trimming or host-only forms, exact fixed/variadic arities, invalid-to-null results, half-away rounding, and
    floor signed modulo. Each package reads the unchanged 55-case JSON/spec fixture and matches its exact expected
    value through direct native execution. Dart's authoritative gate passes format, analyzer, 184 package tests,
    61/61 CLI cases in default and POSIX environments, and 105/105 corpus fixtures. Julia's authoritative gate
    passes the complete package suite, primary CLI conformance, and 105/105 corpus fixtures. The one stale Julia
    folded-subtraction happy path was corrected to the governed exact-arity call.
  Commit: `LUA-BACKEND-PARITY.4.3.3.1.3 - align Dart Julia scalar numeric helpers`

- ID: `LUA-BACKEND-PARITY.4.3.3.1.4`
  Status: `done`
  Goal: Implement Lua scalar numeric helpers and admit exact six-runtime behavior.
  Dependencies: `.4.3.3.1.2`, `.4.3.3.1.3`
  Acceptance: One Lua evaluator consumes every neutral case for canonical helpers on PUC Lua and LuaJIT, never
    delegates syntax/rounding/modulo policy to host accident, full dual-ABI tests pass, and one six-runtime checker
    proves exact results before aliases/receivers `.4.3.3.2`.
  Verification: **PASS 2026-07-12.** Before the change, direct PUC Lua and LuaJIT execution reached
    `unsupported runtime helper 'num_add'`. One portable `scalar_numeric.lua` evaluator now owns strict decimal
    admission, governed arities, invalid/null fences, finite normalization, half-away rounding, floor signed
    modulo, scalar min/max/clamp, and numeric comparisons. Both Lua ABIs consume all 55 unchanged contract cases;
    the complete Lua gate passes 89/89 plus the exact 105-manifest/CLI scaffold. The composed admission checker
    proves the identical 55-case result through Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.
  Commit: `LUA-BACKEND-PARITY.4.3.3.1.4 - implement Lua scalar numeric helpers`

- ID: `LUA-BACKEND-PARITY.4.3.3.2`
  Status: `done`
  Goal: Admit numeric word aliases, symbol callees, and number receiver chains through the scalar evaluator.
  Dependencies: `.4.3.3.1`
  Acceptance: All governed word/symbol spellings canonicalize to the same evaluator; integer/float/bare-scalar
    receivers inject exactly one first argument; number-returning links compose; comparison links return numeric
    truth values and terminate later receiver continuation on both Lua ABIs.
  Verification: **PASS 2026-07-12.** All 18 governed word aliases and 11 arithmetic/comparison symbol callees
    execute through the existing scalar evaluator. Integer, float, and bare-scalar receivers inject their value;
    number-returning links compose; all six numeric comparison links are terminal. Baseline probes proved function
    aliases/symbols already returned canonical values while receivers returned null. The first full run exposed `/`
    callee versus regex-start ambiguity inside harray values; structural slash-call detection fixes it while grouped,
    character-class, zero-width, and invalid regex literals remain locked. PUC Lua and LuaJIT pass 90/90 plus the
    exact manifest/CLI scaffold; the unchanged 55-case six-runtime scalar contract passes.
  Commit: `LUA-BACKEND-PARITY.4.3.3.2 - add Lua numeric call and receiver forms`

- ID: `LUA-BACKEND-PARITY.4.3.3.3`
  Status: `done`
  Goal: Implement aggregate numeric reducers and array receiver terminals.
  Dependencies: `.4.3.3.1`, `.4.3.3.2`
  Acceptance: `num_sum`/`avg`/`median`/`range` and one-array `min`/`max` preserve typed arrays, reject any
    non-numeric element, implement the governed empty-array results, leave source values unchanged, and execute
    equivalent explicit-array, bare-array, and terminal receiver forms on both Lua ABIs.
  Verification: **PASS 2026-07-12.** One strict copied-array evaluator implements sum/avg/odd-even median/range
    and one-array min/max through the scalar numeric admission grammar. Explicit arrays, bare typed arrays, word
    aliases, and six terminal receiver methods agree; sum(empty) is zero, other empty/invalid cases are null, and
    source values remain unchanged. PUC Lua and LuaJIT pass 91/91 plus exact manifest/CLI scaffolding; the unchanged
    six-runtime 55-case scalar contract remains exact.
  Commit: `LUA-BACKEND-PARITY.4.3.3.3 - add Lua numeric aggregate reducers`

- ID: `LUA-BACKEND-PARITY.4.3.3.4`
  Status: `done`
  Goal: Close focused numeric helper and public-surface no-drift.
  Dependencies: `.4.3.3.1`, `.4.3.3.2`, `.4.3.3.3`
  Acceptance: Focused canonical/alias/symbol/receiver/reducer/invalid-boundary proof passes the full dual-ABI gate;
    Lua README, mdBook, task/index/roadmaps, Knowledge Map, architecture/live docs, and runtime status agree before
    array helpers `.4.3.4`; exact shipped-corpus proof remains owned by dependency-complete phase 6.
  Verification: **PASS 2026-07-12.** The focused fixture now directly executes all reducer canonical and alias
    spellings in addition to the complete scalar canonical/word/symbol/receiver and invalid-boundary coverage.
    PUC Lua and LuaJIT pass 91/91; the unchanged six-runtime scalar contract remains 55/55. Lua README, mdBook,
    task/index/roadmaps, Knowledge Map, architecture/live docs, memory, and `runtime-numeric-reducers` agree.
  Commit: `LUA-BACKEND-PARITY.4.3.3.4 - close Lua numeric helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.4`
  Status: `done`
  Goal: Implement array construction, pure helpers, mutation, bridges, reducers, and receiver chains.
  Children: `.4.3.4.0`, `.4.3.4.1`, `.4.3.4.2`, `.4.3.4.3`, `.4.3.4.4`, `.4.3.4.5`, `.4.3.4.6`
  Dependencies: `.4.3.1`, `.4.3.2`, `.4.3.3`
  Acceptance: Typed construction/copy/flatten/concat, selection/order/membership/join/split/filter/map-style
    transforms, append/end mutations, child push/index reuse, numeric terminals, and snapshot isolation match the
    catalog without false/null or empty-array drift.
  Verification: **PASS 2026-07-12.** All 34 non-callback `ARRAY_HELPERS` names plus six strict numeric array
    terminals have direct runtime routes and focused dual-ABI proof. Construction/splicing, copied selection,
    joins/transforms, append/end/split and cached child flow, tagged records, receiver composition, invalid
    boundaries, updated-result semantics, and source isolation pass 99/99. Only the three explicitly delegated
    tree callback names remain for `.4.3.6`; cross-backend helper caveats, including the direct implicit child-push
    expression result, remain owned by `FUTURE-PARITY-BACKLOG.5`.
  Commit: closed by `LUA-BACKEND-PARITY.4.3.4.6 - close Lua array helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.4.0`
  Status: `done`
  Goal: Audit current Lua array mechanisms and split the family before behavior code.
  Acceptance: Inventory every governed array helper against Lua call admission, runtime dispatch, focused tests,
    earlier Dart/Julia rollouts, and current binding semantics; distinguish construction/splicing, copied
    selection, scalar/regex transforms, mutations/child flow, tagged records, and closeout; route any cross-cutting
    contract drift before implementation.
  Verification: **PASS 2026-07-12.** Lua already has array literals/constructors/copy, minimal copied
    count/first/sorted/filter/trim/case helpers, bare push/append/split/transform rebinding, end mutations, and
    receiver dispatch from earlier core/string/uniform-binding leaves. Missing breadth divides into six executable
    children. The audit also proves the later adopted `linkedspec-uniform-binding-v1` updated-value rule supersedes
    older statement-only array-end prose; `FUTURE-PARITY-BACKLOG.12.1.11` owns that public/KM repair before `.1`.
  Commit: `LUA-BACKEND-PARITY.4.3.4.0 - split Lua array helper mechanisms`

- ID: `LUA-BACKEND-PARITY.4.3.4.1`
  Status: `done`
  Goal: Implement copied array construction, explicit flatten splicing, concatenation, and copy boundaries.
  Dependencies: `.4.3.4.0`, `FUTURE-PARITY-BACKLOG.12.1.11`
  Acceptance: `array`, literals, `copy`, `flat`, `flat_array`, and `concat_arrays` evaluate in order, splice only
    explicit flat values in constructor context, preserve ordinary nested arrays, cover the empty/missing list
    boundaries already shared by Rust/Dart/Julia, route any Perl/catalog arity contradiction to an explicit owner,
    and never alias source containers on either Lua ABI.
  Verification: **PASS 2026-07-12.** Lua now evaluates `array(...)` and array literals left-to-right, recognizes
    only explicit `flat`/`flat_array` call or terminal receiver ASTs as constructor splices, and preserves ordinary
    array/copy values as nested elements. `flat`, variadic `flat_array`, and `concat_arrays` return fresh arrays;
    zero/variadic list boundaries match Rust/Dart/Julia while measured Perl direct-value drift is owned by
    `FUTURE-PARITY-BACKLOG.5`; nested values and later source updates do not alias saved results, and both PUC Lua
    and LuaJIT pass 92/92 plus manifest/CLI scaffolding.
  Commit: `LUA-BACKEND-PARITY.4.3.4.1 - add Lua array construction splicing`

- ID: `LUA-BACKEND-PARITY.4.3.4.2`
  Status: `done`
  Goal: Implement copied selection, slicing, ordering, membership, and uniqueness helpers plus receivers.
  Dependencies: `.4.3.4.1`
  Acceptance: `count`, `first`, `last`, `take`, `take_last`, `drop_front`, `drop_back`, `slice`, `sorted`,
    `reversed`, `contains`, `index_of`, and `uniq` match zero-based/default/empty/invalid policy, preserve sources,
    and compose through bare, literal, function, and receiver forms on both ABIs.
  Verification: **PASS 2026-07-12.** Lua now copies `last`, take/drop defaults and explicit counts, zero-based
    `slice`, `reversed`, scalar-text `contains`/`index_of`, and stable `uniq` through function and receiver forms;
    existing `count`/`first`/`sorted` share the same non-array/empty policy. Literal, bare-binding, chained,
    omitted/invalid count, past-end, missing membership/index, and source-isolation cases pass 93/93 on PUC Lua
    and LuaJIT plus manifest/CLI scaffolding. Cross-backend negative-count drift is routed to
    `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.4.2 - add Lua copied array selection`

- ID: `LUA-BACKEND-PARITY.4.3.4.3`
  Status: `done`
  Goal: Implement scalar/regex array transforms, joins, split pipelines, and standalone rebinding.
  Dependencies: `.4.3.2`, `.4.3.4.1`, `.4.3.4.2`
  Acceptance: Delimiter-first `join_values`, `split_each`, `trim_each`, `filter_nonempty`, `filter_match`,
    `lowercase_each`, and `uppercase_each` reuse governed scalar/PCRE2/Unicode policy; pure calls and receivers copy,
    dropped bare calls for all seven array-returning transforms, including `.4.3.4.2`'s `uniq`, rebind and return
    updated targets under uniform binding, and sources stay exact. Pre-existing Rust/Dart/Julia omission of dropped
    `split_each`/`filter_match`/`uniq` rebinding is explicitly routed to `FUTURE-PARITY-BACKLOG.5`, not copied into
    Lua.
  Verification: **PASS 2026-07-12.** Lua now shares copied direct/receiver evaluation for delimiter-first
    `join_values`, literal/PCRE2 `split_each`, PCRE2 `filter_match`, trim/filter/case transforms, and stable `uniq`;
    seven dropped bare transform calls rebind their named typed array, while value forms preserve sources and
    wrong-kind targets emit neutral fields. Direct, literal, receiver, chained, invalid, missing/null join,
    terminal join, Unicode, regex-flag, isolation, and rebinding cases pass 95/95 on PUC Lua and LuaJIT plus
    manifest/CLI scaffolding. Toolbox proof routes pre-existing Rust/Dart/Julia dropped-transform and invalid-join
    drift to `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.4.3 - add Lua array transform pipelines`

- ID: `LUA-BACKEND-PARITY.4.3.4.4`
  Status: `done`
  Goal: Close append, end-mutation, mutable split, and child-push/index execution through one binding seam.
  Dependencies: `.4.3.4.0`, `.4.3.4.2`, `FUTURE-PARITY-BACKLOG.12.1.11`
  Acceptance: `push`/`+=`, three-argument split, push/pop end methods, action-edge push, static-rule precedence,
    implicit/explicit accumulators, and zero-based child-result selection mutate or append exactly once, return
    independent updated values where governed, diagnose wrong kinds, and preserve pure two-argument split.
  Verification: **PASS 2026-07-12.** Lua now types per-rule accumulators, exposes current/absent compiled-rule
    arrays through the uniform lookup seam, reuses cached action-edge children, and supports whole or zero-based
    indexed push into implicit/explicit accumulators. Fluent `.push`/`.push(target)`, all four block forms,
    wrong-kind targets, static rule precedence, independent append/end updates, mutable three-argument versus pure
    two-argument split, and source isolation pass 98/98 on PUC Lua and LuaJIT plus manifest/CLI scaffolding. Perl
    toolbox proof matches the four lifecycle-returned child-push results exactly.
  Commit: `LUA-BACKEND-PARITY.4.3.4.4 - close Lua array mutation flow`

- ID: `LUA-BACKEND-PARITY.4.3.4.5`
  Status: `done`
  Goal: Implement tagged-record construction and remaining array-to-array/scalar bridges.
  Dependencies: `.4.3.4.1`, `.4.3.4.3`
  Acceptance: `split_tagged_records(source, delimiter, tag, fields...)` evaluates its source and carried fields
    once, preserves regex/literal split policy and typed record shapes, composes with array values/receivers, and
    matches shipped helper examples without beginning tree callbacks owned by `.4.3.6`.
  Verification: **PASS 2026-07-12.** Lua now evaluates the source, delimiter, tag, and every carried field once,
    reuses the governed literal/PCRE2 split evaluator, and emits fresh typed records shaped exactly as
    `[tag, item, fields...]`. Direct and scalar-receiver calls compose with array terminals; empty literal fields,
    regex delimiters, missing arity, invalid sources, carried-container isolation, and one-time side effects pass
    99/99 on PUC Lua and LuaJIT plus manifest/CLI scaffolding. Tree callbacks remain untouched for `.4.3.6`.
  Commit: `LUA-BACKEND-PARITY.4.3.4.5 - add Lua tagged record construction`

- ID: `LUA-BACKEND-PARITY.4.3.4.6`
  Status: `done`
  Goal: Close complete Lua array helper, receiver, mutation, and public-surface no-drift.
  Dependencies: `.4.3.4.1`, `.4.3.4.2`, `.4.3.4.3`, `.4.3.4.4`, `.4.3.4.5`
  Acceptance: Focused construction/selection/transform/mutation/tagged/receiver/invalid proof passes both Lua
    ABIs; numeric terminals remain exact; Lua README, mdBook, task/index/roadmaps, Knowledge Map, architecture/live
    docs, runtime status, cleanup, and doctrines agree before hash helpers `.4.3.5`; tree callbacks stay `.4.3.6`.
  Verification: **PASS 2026-07-12.** Audited the 37-name ActionIR array set: 34 ordinary names are implemented
    through copied array dispatch, constructor/copy, shared typed predicates/casing, pure/mutable split, and five
    uniform-binding mutations; `walk_leaves`/`map_leaves`/`reduce_leaves` remain exactly `.4.3.6`. Six strict
    numeric terminals remain exact. The audit caught and repaired residual public catalog drift: `count` invalid
    input is `0`, `take` invalid input is `[]`, ordinary/explicit-target push returns updated snapshots, and a
    punctuation-shaped stale statement-only end-mutation row is now forbidden by the recurring checker. A toolbox
    probe found direct implicit `push(Child)` returns Perl's host count but Lua's updated accumulator; value use is
    now documented non-portable and routed to `FUTURE-PARITY-BACKLOG.5`. Four `array (statement)` prose false
    positives were removed from the selector scan, correcting its inventory from 31 to 27 genuine history entries.
    PUC Lua and LuaJIT pass 99/99; mdBook, public selector/mutation checks, Knowledge Map, cleanup, memory, and
    doctrines pass.
  Commit: `LUA-BACKEND-PARITY.4.3.4.6 - close Lua array helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.5`
  Status: `active`
  Goal: Implement harray construction, pure helpers, mutation, views, and receiver chains.
  Children: `.4.3.5.0`, `.4.3.5.1`, `.4.3.5.2`, `.4.3.5.3`, `.4.3.5.4`, `.4.3.5.5`
  Dependencies: `.4.3.1`, `.4.3.4`
  Acceptance: Typed hash/harray construction/copy/flatten, key/value views, merge/pick/drop/rename/set-key,
    hash-index assignment, scalar-held maps, deterministic ordering, receiver forms, and nested-map preservation
    match the catalog.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.5.0`
  Status: `done`
  Goal: Audit current Lua harray mechanisms and split the family before behavior code.
  Dependencies: `.4.3.1`, `.4.3.4`
  Acceptance: Inventory all 16 ActionIR hash names against Lua runtime dispatch, typed stores/access, focused
    tests, current Perl/catalog behavior, later Dart/Julia implementations, receiver routing, constructor splice
    classification, deterministic ordering, mutations, callbacks, and existing caveat owners; create executable
    children before changing runtime behavior.
  Verification: **PASS 2026-07-12.** The 16-name `HASH_HELPERS` set contains 13 ordinary names plus three tree
    callbacks already owned by `.4.3.6`. Lua currently has typed harray literals/`hash(...)`, defensive `copy`,
    direct hash-index/nested assignment, and uniform bare storage, but no copied hash-helper dispatcher or receiver
    family. `flat` currently always enters array dispatch, so harray identity and constructor splicing need one
    syntax-plus-runtime mechanism; count/sorted views/membership are deterministic terminals/bridges; merge/
    set/rename/drop/pick are copied transforms; named `set_key` and direct assignment need one mutation boundary;
    public no-drift is separate. Direct odd-arity `hash(...)` divergence is already owned by
    `FUTURE-PARITY-BACKLOG.5`; callbacks stay untouched.
  Commit: `LUA-BACKEND-PARITY.4.3.5.0 - split Lua harray helper mechanisms`

- ID: `LUA-BACKEND-PARITY.4.3.5.1`
  Status: `done`
  Goal: Implement copied harray construction, explicit flat splicing, and identity boundaries.
  Dependencies: `.4.3.5.0`
  Acceptance: `hash(...)`, harray literals, `copy`, `flat`, and `flat_hash` evaluate once, preserve ordinary nested
    harray values, splice only explicit direct/terminal flat ASTs in hash-constructor context, never alias sources,
    and leave odd-arity normalization with `FUTURE-PARITY-BACKLOG.5`.
  Verification: **PASS 2026-07-13.** Lua now dispatches `flat(...)` by runtime kind, returns copied harray values
    from direct/receiver `flat_hash(...)`, and recognizes only explicit direct or terminal `flat`/`flat_hash` ASTs
    as harray-constructor splices. Ordinary harray values remain nested copied fields. Explicit harray flattening
    into `array(...)` or `[...]` emits deterministic sorted key/value pairs. A focused end-to-end case proves
    left-to-right one-time evaluation, direct and receiver forms, nested-map preservation, copied isolation after
    deep source mutation, and unchanged Lua odd-arity behavior. PUC Lua and LuaJIT pass 100/100 plus exact
    manifest/CLI scaffolding; cross-backend odd-arity normalization remains `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.5.1 - add Lua harray construction splicing`

- ID: `LUA-BACKEND-PARITY.4.3.5.2`
  Status: `active`
  Goal: Implement copied deterministic harray views and membership terminals.
  Dependencies: `.4.3.5.1`
  Acceptance: `count_keys`, `sorted_keys`, `sorted_values`, and `has_key` return exact typed zero/array/boolean
    boundaries, sort values by key, preserve nested values, and compose through function and receiver forms.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.5.3`
  Status: `pending`
  Goal: Implement copied harray transforms and receiver chains.
  Dependencies: `.4.3.5.1`, `.4.3.5.2`
  Acceptance: `merge_hash`, value-form `set_key`, `rename_key`, `drop_keys`, and `pick_keys` copy inputs, preserve
    deterministic override/order semantics and nested values, accept governed bare typed operands, and continue
    through compatible harray or array-view receiver chains.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.5.4`
  Status: `pending`
  Goal: Close named harray mutation and direct assignment through one binding seam.
  Dependencies: `.4.3.5.3`
  Acceptance: Standalone `set_key(target, key, value)` and direct `target[key] = value` mutate named typed harrays,
    return independent updated snapshots, create only permitted absent targets, reject wrong kinds with neutral
    fields, and leave pure function/receiver transforms non-mutating.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.5.5`
  Status: `pending`
  Goal: Close complete Lua non-callback harray helper and public-surface no-drift.
  Dependencies: `.4.3.5.1`, `.4.3.5.2`, `.4.3.5.3`, `.4.3.5.4`
  Acceptance: Focused construction/view/transform/mutation/receiver/invalid proof passes both ABIs; Lua README,
    mdBook, task/index/roadmaps, Knowledge Map, architecture/live docs, cleanup, and doctrines agree before
    callbacks `.4.3.6`; cross-backend caveats stay explicitly owned rather than silently normalized.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.6`
  Status: `pending`
  Goal: Execute codeblock values, structured controls, generic trailing blocks, and tree callbacks.
  Dependencies: `.4.3.1`-`.4.3.5`
  Acceptance: Codeblock last values and local return, attached/marker/inline if/switch/while, helper/function/method
    final-codeblock equivalence, scoped `with`, and deterministic array/harray walk/map/reduce callbacks match the
    governed surface; unsupported block arities fail generically.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.7`
  Status: `pending`
  Goal: Implement capture-slice, named-mark, input, and explicit cursor-state helper families.
  Dependencies: `.4.3.1`, `.4.3.6`
  Acceptance: Capture anchors/slices/boundaries, rule-local named marks, Unicode character positions/lengths,
    input views, save/restore and entry/local rewinds, consume continuation, earliest boundary selection, and
    unresolved-rule behavior match the runtime contract.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.8`
  Status: `pending`
  Goal: Implement runtime diagnostic output helpers over a caller-owned event boundary.
  Dependencies: `.4.3.2`, `.4.3.4`, `.4.3.7`
  Acceptance: `print`, `say`, and `print_each` evaluate eagerly, stay out of parse-result values, are quiet without
    a sink, preserve message ordering/Unicode, and expose an event seam that `.4.4` can instrument without changing
    helper semantics; `exit_now` remains immediate typed control.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.4.3.9`
  Status: `pending`
  Goal: Close exhaustive Lua helper/value/control/method no-drift.
  Dependencies: `.4.3.1`-`.4.3.8`
  Acceptance: Every governed current name is execution-covered or has a later explicit non-helper owner; exact
    239-name admission, mdBook examples, both runtime gates, statuses, API docs, task trees, Knowledge Map, and
    capability claims agree with zero hidden partial surface before `.4.4`.
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
  Goal: Add staged parser registry/function-body dispatch and fixed-v1/variadic-v2 runtime calls.
  Acceptance: Provider identity, ordered jobs, parse/normalize/stitch phases, failures, and trace match the admitted
    variants without Lua-only queues or cache behavior. Consume `linkedspec-callable-signature-v1` through the
    spec-owned shell, typed function/job records, registry-first ActionIR resolution, and isolated invocation
    frames: fixed v1 calls remain exact; final-rest v2 calls are positional-only, require `min_arity`, evaluate once
    left-to-right, and bind extras as one fresh typed array without Lua vararg/closure dispatch. The unchanged
    neutral fixture, seven invalid definitions, keyword rejection, exact/minimum diagnostics, receiver continuation,
    mixed/empty/fresh rest values, and recursion fence pass on PUC Lua and LuaJIT.
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
  Acceptance: Consume shared fixtures/checkers directly, including the exact fixed-v1/variadic-v2 outward function
    descriptor union and identical staged signature copies, and expand the capability census without changing
    existing backend rows; no partial/gap state lacks a concrete next owner.
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
    backend-local expected files. This includes exact `portmap_constant`, `simenv_multiline_value`,
    `ebnf_expression_rules`, `ebnf_logging_annotation`, `lib_reader_sattribute`, and `lib_reader_cattribute` proof
    after the helper/control/output owners on which those cases depend.
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
  Acceptance: Effective compiled state, including exact fixed-v1/variadic-v2 callable signatures, stable
    identity/metadata/errors, Unicode/strict-UTF-8 payload boundary, direct/traced entrypoints, caller-owned
    isolation, and cleanup pass without altering native interpreter/CLI.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8.2`
  Status: `pending`
  Goal: Add exact ten-family plan and authoritative direct generated execution.
  Acceptance: Ordered public rows, four rejections, per-root/nested family dispatch, portable trace/source identity,
    one isolated all-family matrix, and the unchanged variadic callable fixture execute independently with values
    equal to the native interpreter; generated Lua uses reconstructed typed rest arrays, not host vararg dispatch.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8.3`
  Status: `pending`
  Goal: Admit the exact contract-sourced generated 8/105 subset.
  Acceptance: Interpreter-first values, independent generated load, metadata/plans/trace identity, callable-
    signature preservation/execution, checker-owned path/order/no-skip/cleanup, and complete Lua package/CLI/corpus
    gates pass before capability promotion.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.8.4`
  Status: `pending`
  Goal: Close Lua capability parity and backend handoff.
  Acceptance: Expanded capability manifest is all-pass and retires the Lua-owned
    `future.variadic_user_functions` entry only after native and generated callable proofs pass; PUC Lua primary and
    LuaJIT compatibility policies are honest; roadmap/book/KM/live docs/local CI/cleanup pass; no outstanding Lua
    behavior is hidden as a limitation.
  Verification: `pending`
  Commit: `pending`

## Current frontier

Global delegation note: selector-free uniform bindings and exact selector rejection remain part of the Lua gate.
Numeric helper parent `.4.3.3` and complete non-callback array parent `.4.3.4` pass 99/99 on PUC Lua and LuaJIT.
All 34 ordinary array helper names and six numeric terminals are routed; only the three callback methods remain
under `.4.3.6`. Cross-cutting caveats remain `FUTURE-PARITY-BACKLOG.5`; harray audit `.4.3.5.0` split five
mechanisms plus closeout. Copied construction/splicing/identity `.4.3.5.1` passes 100/100 on both Lua ABIs, and
deterministic views/membership `.4.3.5.2` is active.

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
| 11 | `LUA-BACKEND-PARITY.3.4` | `done` | Typed effective rules/dependencies/payloads and exact outward descriptors pass both runtimes. |
| 12 | `LUA-BACKEND-PARITY.4.1` | `done` | Dual-ABI PCRE2 matching and neutral registers pass 60/60 on both runtimes. |
| 13 | `LUA-BACKEND-PARITY.4.2` | `done` | First compiled-rule interpreter passes 66/66 on both runtimes. |
| 14 | `LUA-BACKEND-PARITY.4.3.0` | `done` | Nine implementation/closeout owners cover the full helper surface. |
| 15 | `LUA-BACKEND-PARITY.4.3.1` | `done` | Four-kind stores/access/capture reads pass 69/69 on both runtimes. |
| 16 | `LUA-BACKEND-PARITY.4.3.2.0` | `done` | Pure scalar and regex/mutation mechanisms have separate owners. |
| 17 | `LUA-BACKEND-PARITY.4.3.2.1` | `done` | Deterministic and Unicode pure string helpers are complete. |
| 18 | `LUA-BACKEND-PARITY.4.3.2.1.0` | `done` | Measured three host policies and split deterministic helpers from casing. |
| 19 | `LUA-BACKEND-PARITY.4.3.2.1.1` | `done` | Deterministic non-case strings pass 70/70 on both Lua ABIs. |
| 20 | `LUA-BACKEND-PARITY.4.3.2.1.2` | `done` | Unicode 17 casing is exact across all six runtime variants. |
| 21 | `LUA-BACKEND-PARITY.4.3.2.1.2.0` | `done` | Unicode 17 full-default policy and rollout owners adopted. |
| 22 | `LUA-BACKEND-PARITY.4.3.2.1.2.1` | `done` | Verified Unicode contract and 12 fixtures pass the full gate. |
| 23 | `LUA-BACKEND-PARITY.4.3.2.1.2.2` | `done` | Perl/Rust direct, helper, receiver, and array casing use generated Unicode 17 data. |
| 24 | `LUA-BACKEND-PARITY.4.3.2.1.2.3` | `done` | Dart/Julia direct, helper, receiver, and array casing use generated Unicode 17 data. |
| 25 | `LUA-BACKEND-PARITY.4.3.2.1.2.4` | `done` | PUC Lua/LuaJIT pass 71/71 and six-variant casing is admitted. |
| 26 | `LUA-BACKEND-PARITY.4.3.2.1.3` | `done` | One typed scalar-to-text contract passes all six runtime variants. |
| 27 | `LUA-BACKEND-PARITY.4.3.2.2` | `done` | Regex/split/scalar/array mutation mechanisms close at 76/76. |
| 28 | `LUA-BACKEND-PARITY.4.3.2.2.0` | `done` | Split helper regex, pure split, scalar mutation, array mutation, and no-drift. |
| 29 | `LUA-BACKEND-PARITY.4.3.2.2.1` | `done` | Strict PCRE2 helper regex and `matches` pass 73/73 on both ABIs. |
| 30 | `LUA-BACKEND-PARITY.4.3.2.2.2` | `done` | Pure literal/regex/Unicode split passes 74/74 on both ABIs. |
| 31 | `LUA-BACKEND-PARITY.4.3.2.2.3` | `done` | Scalar regex mutation and capture expansion pass 75/75 on both ABIs. |
| 32 | `LUA-BACKEND-PARITY.4.3.2.2.4` | `done` | Explicit array-target split replacement passes 76/76 on both ABIs. |
| 33 | `LUA-BACKEND-PARITY.4.3.2.2.5` | `done` | Focused mechanism/public no-drift closed; shipped proof belongs to phase 6. |
| 34 | `LUA-BACKEND-PARITY.4.3.2.2.5.0` | `done` | Route premature shipped cases to their dependency-complete phase-6 owner. |
| 35 | `LUA-BACKEND-PARITY.4.3.2.2.5.1` | `done` | Focused string mechanisms/public surfaces close at 76/76. |
| 36 | `LUA-BACKEND-PARITY.4.3.3.0` | `done` | Audit and split scalar evaluation, receiver/alias admission, reducers, and closeout. |
| 37 | `LUA-BACKEND-PARITY.4.3.3.1.0` | `done` | Measure scalar numeric drift and split neutral policy from backend alignment. |
| 38 | `LUA-BACKEND-PARITY.4.3.3.1.1` | `done` | Adopt 55-case strict scalar numeric v1 contract and offline checker. |
| 39 | `LUA-BACKEND-PARITY.4.3.3.1.2` | `done` | Perl/Rust consume all 55 scalar numeric v1 cases without generic coercion drift. |
| 40 | `LUA-BACKEND-PARITY.4.3.3.1.3` | `done` | Dart and Julia consume all 55 scalar numeric v1 cases; full backend gates pass. |
| 41 | `LUA-BACKEND-PARITY.4.3.3.1.4` | `done` | All six runtime variants match scalar numeric v1 across all 55 cases. |
| 42 | `LUA-BACKEND-PARITY.4.3.3.2` | `done` | All numeric word/symbol calls and scalar number receiver chains pass both ABIs. |
| 43 | `LUA-BACKEND-PARITY.4.3.3.3` | `done` | Strict array reducers and six terminal receiver forms pass both ABIs. |
| 44 | `LUA-BACKEND-PARITY.4.3.3.4` | `done` | Numeric proof/public no-drift closed at 91/91 on both ABIs. |
| 45 | `LUA-BACKEND-PARITY.4.3.4.0` | `done` | Split six array mechanisms and route superseded mutation-result prose. |
| 46 | `LUA-BACKEND-PARITY.4.3.4.1` | `done` | Ordered copied construction, explicit splicing, concat, and isolation pass 92/92. |
| 47 | `LUA-BACKEND-PARITY.4.3.4.2` | `done` | Copied selection/order/membership/uniq pass 93/93 on both ABIs. |
| 48 | `LUA-BACKEND-PARITY.4.3.4.3` | `done` | Copied transforms, joins, PCRE2 pipelines, and seven rebindings pass 95/95. |
| 49 | `LUA-BACKEND-PARITY.4.3.4.4` | `done` | Typed accumulators and complete cached child-push flow pass 98/98. |
| 50 | `LUA-BACKEND-PARITY.4.3.4.5` | `done` | Typed tagged records, one-time carried fields, governed splits, and receiver composition pass 99/99. |
| 51 | `LUA-BACKEND-PARITY.4.3.4.6` | `done` | Complete 34-name non-callback array/public surface closes at 99/99. |
| 52 | `LUA-BACKEND-PARITY.4.3.5.0` | `done` | Split construction, views, transforms, mutation, and no-drift before behavior code. |
| 53 | `LUA-BACKEND-PARITY.4.3.5.1` | `done` | Copied construction, explicit flat splicing, nested identity, and isolation pass 100/100. |
| 54 | `LUA-BACKEND-PARITY.4.3.5.2` | `active` | Implement deterministic copied key/value views and membership terminals. |

### `LUA-BACKEND-PARITY.4.3.3.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.1.0` proved five scalar numeric semantic drift classes without a neutral owner.
- [x] **ROOT CAUSE (WHY + WHERE)** — Helper examples and call-name coverage documented happy paths but no strict
  input grammar, arity table, invalid result, signed modulo, or backend-independent executable data.
- [x] **FIX** — ADR `0029` adopts `linkedspec-scalar-numeric-v1`; one 55-case JSON contract stores policy, calls,
  deterministic `.spec` source, and exact expected results; an independent Python evaluator checks all four.
- [x] **ADDRESSED (verified)** — The checker reports 55 cases/18 canonical helpers and byte-matches rendered source;
  README/capability docs/mdBook/TOOLBOX explain the contract and local CI requires/runs both tracked inputs.
- [x] **NO REGRESSION** — No backend runtime changed; mdBook, Knowledge Map, memory, doctrine, and whitespace pass.
  Full local CI passes both 61-case CLI environments and phase0 `1..1030` in 559 seconds.
- [x] **LOCKSTEP** — ADR/index, task/index/roadmaps, architecture/live docs, changes/notes, memory, README, catalog,
  capability README, checker, and CI agree; Perl/Rust alignment `.2` is the sole executable frontier.

### `LUA-BACKEND-PARITY.4.3.3.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The unchanged 55-case fixture exposed boolean coercion, invalid defaults, loose Rust
  arities, host remainder sign, and host numeric-string acceptance in direct Perl/Rust execution.
- [x] **ROOT CAUSE (WHY + WHERE)** — Perl inlined repeated regex/host arithmetic in generated actions; Rust reused
  generic `RuntimeValue::as_number` and host operators. Neither seam implemented ADR `0029` as one contract.
- [x] **FIX** — Added `LinkedSpec::Numeric` for generated Perl actions and helper-local Rust adapters for strict
  finite decimal admission, result normalization, exact arities, half-away rounding, and floor signed modulo.
- [x] **ADDRESSED (verified)** — Perl and Rust consume every unchanged case through direct canonical helper calls;
  generated Perl source declares its dependency and the Rust test consumes the same checked-in JSON/source.
- [x] **NO REGRESSION** — Canonical local CI passes Perl CLI 61x2 plus phase0 `1..1030`; the Rust local gate passes
  its complete package and CLI 61x2; rustfmt/library clippy pass. Generic coercion paths remain unchanged.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, Knowledge Map, architecture/live docs, changes/notes, memory,
  checker fixture, generated-source expectations, and recurring CI inputs agree; Dart/Julia `.3` is next.

### `LUA-BACKEND-PARITY.4.3.3.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The unchanged 55-case fixture exposed trimmed/broad numeric strings, folded extra
  fixed-arity operands, host remainder sign, and host result-normalization differences in Dart and Julia.
- [x] **ROOT CAUSE (WHY + WHERE)** — Both native interpreters delegated numeric admission and arithmetic edges to
  permissive host primitives, while their existing tests covered only happy paths.
- [x] **FIX** — Added strict decimal matching, exact governed arity checks, finite result normalization, and floor
  signed modulo at each numeric-helper boundary; preserved the separate one-array min/max reducer overload.
- [x] **ADDRESSED (verified)** — Dart and Julia package tests load and execute all 55 unchanged contract calls and
  compare the complete returned object to the shared exact expectation.
- [x] **NO REGRESSION** — Dart passes format/analyzer/184 tests/61x2 CLI/105 corpus; Julia passes its complete
  package suite, primary CLI conformance, and 105 corpus fixtures.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, Knowledge Map, architecture/live docs, changes/notes, and
  memory agree that Perl/Rust/Dart/Julia are aligned and Lua exact six-runtime admission `.4` is active.

### `LUA-BACKEND-PARITY.4.3.3.1.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the unchanged 55-case scalar numeric fixture through Lua and prove canonical
  numeric calls currently fall through to the unsupported-runtime-helper boundary on both ABIs.
- [x] **ROOT CAUSE (WHY + WHERE)** — Trace canonical name resolution into `interpreter.lua` and show that Lua has
  no strict finite-decimal, governed-arity, rounding, modulo, comparison, or result-normalization owner.
- [x] **FIX** — Add one portable Lua scalar-numeric evaluator and route canonical scalar helper calls through it;
  consume the unchanged contract in runtime tests and add one six-runtime admission checker.
- [x] **ADDRESSED (verified)** — All 55 cases match exactly on PUC Lua and LuaJIT, including strict strings,
  invalid/null inputs, exact/variadic arity, half-away rounding, floor signed modulo, and negative-zero handling.
- [x] **NO REGRESSION** — Dual-ABI Lua local gate, six-runtime checker, canonical contracts/CI where warranted,
  docs/KM/doctrines/mdBook/cleanup/whitespace all pass without beginning aliases/receivers or aggregate reducers.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, Knowledge Map, changes/notes/live, capability status, and
  memory close scalar evaluator `.1` and activate alias/symbol/number-receiver admission `.4.3.3.2`.

### `LUA-BACKEND-PARITY.4.3.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run governed word aliases, arithmetic/comparison symbol callees, integer/float/bare-
  scalar receivers, composed number-returning links, and terminal comparison continuations on both Lua ABIs.
- [x] **ROOT CAUSE (WHY + WHERE)** — Distinguish already-present call-name canonicalization from missing receiver
  injection and terminal-result policy; locate the exact generic fluent-chain boundary before behavior code.
- [x] **FIX** — Route every governed alias/symbol spelling through the existing scalar evaluator and add numeric
  receiver injection/composition/terminal handling without changing scalar policy or aggregate reducers.
- [x] **ADDRESSED (verified)** — Function aliases/symbols and integer/float/bare-scalar receiver cases produce the
  same exact values as canonical calls; number links compose and comparison links terminate later continuations.
- [x] **NO REGRESSION** — Focused numeric proof, unchanged 55-case six-runtime contract, complete 90/90 dual-ABI
  Lua gate, exact manifest/CLI scaffold, docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, Lua README/book, Knowledge Map, changes/notes/live, and memory activate
  aggregate numeric reducers/array receiver terminals `.4.3.3.3` without claiming them early.

### `LUA-BACKEND-PARITY.4.3.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run canonical/alias reducers over explicit arrays, bare typed bindings, and array
  receivers; cover empty, odd/even median, strict decimal strings, invalid elements/kinds, and later continuations.
- [x] **ROOT CAUSE (WHY + WHERE)** — Prove scalar `min`/`max` ownership cannot accept one array without weakening
  v1 arity, and locate the absent aggregate reducer plus array-terminal dispatch seams.
- [x] **FIX** — Add one strict copied-array reducer evaluator for sum/avg/median/range/array min/max and route
  function aliases plus terminal array receivers through it without mutating sources or changing scalar helpers.
- [x] **ADDRESSED (verified)** — Explicit, bare, and receiver forms agree; sum(empty) is zero; other empty/invalid
  cases are null; even median averages middle values; all reducer receiver continuations terminate.
- [x] **NO REGRESSION** — Focused reducer proof, unchanged 55-case six-runtime scalar contract, complete 91/91
  dual-ABI Lua gate, exact manifest/CLI scaffold, docs/KM/doctrines/mdBook/cleanup/whitespace all pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, Lua README/book, Knowledge Map, changes/notes/live, and memory activate
  focused numeric/public no-drift `.4.3.3.4` without beginning general array helpers `.4.3.4`.

### `LUA-BACKEND-PARITY.4.3.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Inventory every canonical helper, word alias, symbol callee, number receiver,
  aggregate reducer, array receiver terminal, and invalid boundary against the focused dual-ABI tests.
- [x] **ROOT CAUSE (WHY + WHERE)** — Identify any gap between runtime admission, focused proof, runtime status,
  Lua README, mdBook, task/index/roadmaps, Knowledge Map, architecture/live docs, and phase-6 corpus ownership.
- [x] **FIX** — Close only numeric proof or public-state drift; do not begin general array helper behavior.
- [x] **ADDRESSED (verified)** — Every numeric spelling/mechanism is directly covered and all current public/status
  surfaces agree on the 91/91 milestone, strict reducer boundaries, and next array-helper frontier.
- [x] **NO REGRESSION** — Complete PUC Lua/LuaJIT gate, unchanged 55-case six-runtime contract, docs/KM/doctrines/
  mdBook/cleanup/whitespace, and focused public scans pass.
- [x] **LOCKSTEP** — Numeric parent `.4.3.3` closes and the single frontier advances to array helpers `.4.3.4`;
  exact shipped-corpus execution remains correctly routed to dependency-complete phase 6.

### `LUA-BACKEND-PARITY.4.3.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Inventory the full array catalog against Lua call admission, runtime branches,
  focused tests, prior Dart/Julia rollout facts, and uniform-binding behavior before broad code changes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Separate six runtime mechanisms and prove older statement-only array-end
  result prose was superseded by the later admitted updated-mutation-value contract across all five backends.
- [x] **FIX** — Create construction/splicing, copied selection, scalar/regex transform, mutation/child-flow,
  tagged-record, and closeout children; route cross-cutting result-doc drift to `FUTURE-PARITY-BACKLOG.12.1.11`.
- [x] **ADDRESSED (verified)** — Every governed helper and existing collateral Lua mechanism has exactly one child
  owner; tree callbacks remain under `.4.3.6`, and the external documentation repair blocks array behavior `.1`.
- [x] **NO REGRESSION** — Planning only: both Lua ABIs remain 91/91; task metadata, Knowledge Map, doctrines,
  mdBook, cleanup, and whitespace pass without new array runtime behavior.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/book, KM, architecture/live docs, and memory activate `.12.1.11`
  while preserving `.4.3.4.1` as the next Lua array implementation leaf after that repair.

### `LUA-BACKEND-PARITY.4.3.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove Lua admits constructor/flat/concat names but lacks `flat`, `flat_array`, and
  `concat_arrays` dispatch and cannot distinguish explicit splices from ordinary nested array values.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` evaluated every `array(...)`/literal slot into a copied
  element and the minimal array helper registry omitted all three flatten/concat mechanisms.
- [x] **FIX** — Add copied helper dispatch plus AST-context splice classification for direct calls and terminal
  receivers; preserve ordinary arrays/copies as nested elements and evaluate every slot once in source order.
- [x] **ADDRESSED (verified)** — Function, literal, receiver, nested, concat, variadic scalar/array, empty/null,
  ordered side-effect, and later-source-update isolation cases match admitted Dart/Julia/Rust behavior.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 92/92 plus exact manifest/CLI scaffolding; governance, Knowledge
  Map, mdBook, cleanup, and whitespace gates pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook, Knowledge Map, architecture/live docs, and
  memory close `.4.3.4.1` and activate copied selection/order/membership `.4.3.4.2`.

### `LUA-BACKEND-PARITY.4.3.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit the minimal `count`/`first`/`sorted` branch and prove ten additional selection/
  order/membership helpers, including `uniq`, still fall through as unsupported runtime calls.
- [x] **ROOT CAUSE (WHY + WHERE)** — `PURE_ARRAY_HELPERS` and `evaluate_array_helper` contained only the earlier
  minimal transform slice; no shared nonnegative count, zero-based slice, membership, or stable uniqueness path.
- [x] **FIX** — Add copied last/take/drop/slice/reverse/membership/index/uniq dispatch with safe default counts,
  zero-based results, scalar-text comparison, stable first occurrence, and function/receiver composition.
- [x] **ADDRESSED (verified)** — Bare, literal, function, receiver, chained, default/invalid count, empty/wrong-kind,
  past-end, missing index/membership, stable uniqueness, and source preservation cases all execute.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 93/93 plus exact manifest/CLI scaffolding; negative-count
  cross-backend drift is routed to `.5`; governance, Knowledge Map, mdBook, cleanup, and whitespace pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook, Knowledge Map, architecture/live docs, and
  memory close `.4.3.4.2` and activate scalar/regex transforms and joins `.4.3.4.3`.

### `LUA-BACKEND-PARITY.4.3.4.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove Lua's minimal array dispatcher rejects `join_values`, `split_each`, and
  `filter_match`, cannot chain joins, and rebinds only four of the seven Perl-reference dropped transforms.
- [x] **ROOT CAUSE (WHY + WHERE)** — `PURE_ARRAY_HELPERS`, `evaluate_array_helper`, receiver injection, and the
  dropped-statement allowlist lacked join ordering, governed split/regex dispatch, terminality, and complete
  `BindingRuntime::array_transform` parity.
- [x] **FIX** — Add delimiter-first join injection, copied literal/PCRE2 split/filter paths, terminal receiver join,
  and kind-checked rebinding for split/trim/filter/case/uniq while reusing established scalar, PCRE2, and Unicode
  evaluators.
- [x] **ADDRESSED (verified)** — Direct, literal, receiver, chained, invalid, missing/null, regex-flag, Unicode,
  source-isolation, all-seven-rebinding, and wrong-kind cases execute on both Lua ABIs.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 95/95 plus manifest/CLI scaffolding; Perl toolbox proof routes
  Rust/Dart/Julia dropped-transform and invalid-join drift to `.5`; KM, mdBook, doctrines, cleanup, and whitespace
  pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, helper reference and backend mdBook, Knowledge Map,
  architecture/live docs, and memory close `.4.3.4.3` and activate mutation/child flow `.4.3.4.4`.

### `LUA-BACKEND-PARITY.4.3.4.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove ordinary append/end/split paths exist, while action-edge push re-executes named
  children, lacks numeric/three-argument selection, treats `.push(target)` as a value append, and cannot expose a
  typed current-rule accumulator.
- [x] **ROOT CAUSE (WHY + WHERE)** — `evaluate_call(push)` had separate partial branches instead of one cached-child/
  target/index classifier, and `execute_rule` created its accumulator as an untyped host table invisible to
  `lookup_binding` and kind-checked storage.
- [x] **FIX** — Type rule accumulators, add scoped implicit/compiled-rule reads and in-place storage, give compiled
  child names static precedence, reuse `dispatch_edge_child`, classify literal nonnegative indexes first, and
  route every selected result through `append_array_binding`.
- [x] **ADDRESSED (verified)** — Four block child-push forms, fluent implicit/explicit push, absent compiled-rule
  arrays, wrong-kind targets, saved updates, static precedence, and mutable/pure split boundaries all execute.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 98/98 plus manifest/CLI scaffolding; Perl reference lifecycle
  proof matches exact implicit/explicit whole/indexed results; KM, mdBook, doctrines, cleanup, and whitespace pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook/backend status, Knowledge Map, architecture/live
  docs, and memory close `.4.3.4.4` and activate tagged records/remaining bridges `.4.3.4.5`.

### `LUA-BACKEND-PARITY.4.3.4.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prove the governed call is admitted by ActionIR but Lua's pure-array dispatcher has
  no `split_tagged_records` branch, so direct and receiver forms reach the unsupported-helper boundary.
- [x] **ROOT CAUSE (WHY + WHERE)** — The existing array split evaluator already owns literal/PCRE2 semantics, but
  `PURE_ARRAY_HELPERS` and `evaluate_array_helper` lacked the small bridge that wraps each item with a tag and
  copied carried fields.
- [x] **FIX** — Evaluate arguments once through the generic array call path, reuse pure split, coerce the tag
  through the portable scalar-text seam, and construct fresh typed `[tag, item, fields...]` arrays.
- [x] **ADDRESSED (verified)** — Direct literal and regex calls, empty items, receiver chaining, missing arity,
  invalid sources, one-time source/field side effects, and carried-array isolation execute on both Lua ABIs.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 99/99 plus exact manifest/CLI scaffolding; scalar numeric remains
  55/55 across six runtime variants, and no tree callback owned by `.4.3.6` changed.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook, Knowledge Map, architecture/live docs, and
  memory close `.4.3.4.5` and activate complete array helper/public no-drift `.4.3.4.6`.

### `LUA-BACKEND-PARITY.4.3.4.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Inventory all 37 ActionIR array names, runtime routes, focused fixtures, public
  catalog semantics, receiver terminals, and the three explicitly deferred callback names before parent closure.
- [x] **ROOT CAUSE (WHY + WHERE)** — Implementation breadth was complete across `.1-.5`, but the public catalog
  still had invalid `count`/`take` results, three push sections returning void, and one punctuation-shaped
  statement-only end-mutation row that evaded the existing recurring checker; direct implicit child-push value
  results also differ between Perl's host count and Lua's updated accumulator.
- [x] **FIX** — Record the exact 34-name non-callback runtime routing, align count/take/ordinary and explicit-target
  push/end-mutation prose and formal grammar with proved values, mark implicit child-push value use non-portable
  under `.5`, and extend the recurring mutation-result check with a forbidden pattern and corrected anchor.
- [x] **ADDRESSED (verified)** — Construction, selection, transforms, joins, mutation/child flow, tagged records,
  receivers, invalid boundaries, selectors, six numeric terminals, and public examples/checks all agree; only
  `walk_leaves`/`map_leaves`/`reduce_leaves` remain under `.4.3.6`.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 99/99 plus manifest/CLI scaffolding; capability remains 60/0/0,
  scalar numeric remains 55/55, the measured implicit child-push difference is explicitly routed, and public
  uniform-binding/selector gates, KM, mdBook, doctrines, and whitespace pass.
- [x] **LOCKSTEP** — Array parent `.4.3.4`, task/index, roadmaps, root/Lua README, mdBook, Knowledge Map,
  architecture/live docs, and memory close together and activate harray helpers `.4.3.5`.

### `LUA-BACKEND-PARITY.4.3.5.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Inventory all 16 hash-family ActionIR names against Lua dispatch/tests, current
  typed stores/access, Perl/catalog behavior, Dart/Julia rollout seams, receiver families, and callback ownership.
- [x] **ROOT CAUSE (WHY + WHERE)** — Lua has harray values, constructors/copy, and checked assignment but no
  general hash helper/receiver dispatcher; shared `flat` currently enters array dispatch regardless of runtime
  kind, while views, copied transforms, mutations, and callbacks have distinct result/control boundaries.
- [x] **FIX** — Split `.4.3.5` into audit `.0`, construction/splicing `.1`, deterministic views `.2`, copied
  transforms/receivers `.3`, named mutation `.4`, and public no-drift `.5`; keep callbacks in `.4.3.6`.
- [x] **ADDRESSED (verified)** — Every ordinary hash name has one future owner, dependencies preserve reusable
  seams, odd-arity hash drift remains backlog `.5`, and no runtime behavior changed during the split.
- [x] **NO REGRESSION** — The unchanged PUC Lua/LuaJIT gate passes 99/99 plus manifest/CLI scaffolding; capability,
  uniform-binding, selector, Knowledge Map, mdBook, doctrine, cleanup, and whitespace gates pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook/backend status, Knowledge Map, architecture/live
  docs, and memory close `.4.3.5.0` and activate construction/splicing/identity `.4.3.5.1`.

### `LUA-BACKEND-PARITY.4.3.5.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Execute harray `flat`/`flat_hash`, receiver forms, ordinary nested constructor
  fields, explicit constructor splices, array list-context splices, ordered side effects, and later source updates.
- [x] **ROOT CAUSE (WHY + WHERE)** — `flat` was routed unconditionally through the array evaluator, Lua had no
  copied hash-helper dispatcher, `hash(...)` paired every argument without inspecting authored splice syntax, and
  array splicing only expanded array values.
- [x] **FIX** — Dispatch generic `flat` by evaluated array/harray kind, add copied `flat_hash` function/receiver
  evaluation, classify direct/terminal flat ASTs for hash context, preserve ordinary nested values, and emit
  deterministic sorted key/value pairs when an explicit harray flatten feeds array context.
- [x] **ADDRESSED (verified)** — One end-to-end fixture proves direct/receiver construction, generic/hash splices,
  deterministic call/literal list splices, nested map preservation, exact one-time evaluation, and deep isolation.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 100/100 plus exact manifest/CLI scaffolding; the pre-existing Lua
  odd-arity result remains unchanged, and cross-backend arity/list-order normalization stays owned by
  `FUTURE-PARITY-BACKLOG.5`.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook/backend status, Knowledge Map, architecture/live
  docs, changes/notes, and memory close construction `.4.3.5.1` and activate deterministic views `.4.3.5.2`.

### `LUA-BACKEND-PARITY.4.3.3.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — A direct Perl `Get` matrix and admitted-backend source/tests disagree on booleans,
  invalid comparisons/unary calls, extra subtraction/division operands, numeric strings, and signed modulo.
- [x] **ROOT CAUSE (WHY + WHERE)** — Numeric semantics were copied from host coercion/arithmetic APIs without one
  executable neutral contract; call-name identity and happy-path examples never exercised the divergent edges.
- [x] **FIX** — Split neutral policy/data `.1`, Perl/Rust alignment `.2`, Dart/Julia alignment `.3`, and Lua plus
  six-runtime admission `.4` before aliases/receiver work.
- [x] **ADDRESSED (verified)** — The measured matrix and exact source seams are durable in Knowledge Map card
  `cross-backend-scalar-numeric-drift`; each repair family has an explicit acceptance owner.
- [x] **NO REGRESSION** — Read-only probes and planning/docs only; the committed Lua 76/76 dual-ABI gate is clean.
- [x] **LOCKSTEP** — Task/index/roadmaps, Knowledge Map, changes/notes/live status, and memory advance to neutral
  contract `.1`; no backend behavior or mdBook claim changed during discovery.

### `LUA-BACKEND-PARITY.4.3.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua contracts already canonicalize numeric names, but runtime calls still reach the
  generic unsupported-helper boundary and receiver chains do not inject numeric or array receiver values.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` has only string-specific pure dispatch. Scalar numeric
  coercion/fences, terminal comparison handling, and aggregate reducers cross different evaluator/type seams.
- [x] **FIX** — Split `.4.3.3` into scalar evaluation `.1`, alias/symbol/number-receiver admission `.2`, aggregate
  reducers/array terminals `.3`, and focused public no-drift `.4` before touching runtime code.
- [x] **ADDRESSED (verified)** — Public catalog plus Perl/Rust/Dart/Julia implementations/tests define exact
  unary/arithmetic/comparison/reducer/receiver behavior; Lua parser/contracts already preserve every call shape.
- [x] **NO REGRESSION** — Planning/KM/docs only; the full Lua local gate passes 76/76 on PUC Lua and LuaJIT.
- [x] **LOCKSTEP** — Task/index/roadmaps, Knowledge Map, changes/notes/live status, and memory identify `.1` as the
  sole executable numeric frontier; no premature runtime or mdBook capability claim is made.

### `LUA-BACKEND-PARITY.4.3.2.2.5.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Runtime mechanisms were green, but public roadmap/catalog prose still positively
  presented the retired `concat` spelling and the string parent/frontier remained open.
- [x] **ROOT CAUSE (WHY + WHERE)** — Historical follow-up prose escaped the prior helper-retirement migration;
  the public catalog led with the old name despite correctly calling `cat` canonical below it.
- [x] **FIX** — Lead the catalog and roadmap history with canonical `cat`, keep retirement history non-executable,
  close regex/split/string parents, and advance the runtime status/frontier to numeric helpers.
- [x] **ADDRESSED (verified)** — Non-host retired call-shape scan is clean; flags/captures/empty fields/pure versus
  mutation/explicit-target boundaries remain documented and focused tests pass.
- [x] **NO REGRESSION** — Full PUC Lua and LuaJIT gates pass 76/76; exact shipped cases remain unchanged in `.6.2`.
- [x] **LOCKSTEP** — Runtime status, task/index/roadmaps, README, mdBook, KM, changes/notes/live, and memory agree.

### `LUA-BACKEND-PARITY.4.3.2.2.5.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.2.2.5` required six shipped cases before the official corpus runner or their
  control/output/array/child-flow dependencies existed.
- [x] **ROOT CAUSE (WHY + WHERE)** — The string-family split accidentally retained full-corpus acceptance that
  canonically belongs to phase 6; direct in-memory execution identified each first unrelated blocker.
- [x] **FIX** — Keep focused mechanism/public no-drift in `.2.2.5.1` and route the exact unchanged named fixtures
  to `.6.2`, after dependency-complete helper/control/output and corpus-runner work.
- [x] **ADDRESSED (verified)** — Disposable PCRE2 execution reports `control_if`, `print`, or later flow/array
  boundaries rather than a regex/split regression; the probe artifact was removed.
- [x] **NO REGRESSION** — Planning/routing only: no runtime behavior or fixture expectation changes.
- [x] **LOCKSTEP** — Task/index/roadmap/KM/memory record the corrected owner before closeout proceeds.

### `LUA-BACKEND-PARITY.4.3.2.2.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Pure `split` returned arrays, but a dropped `split(array(target), source, delimiter)`
  evaluated the wrapper as a non-text value and never replaced the explicit aggregate target.
- [x] **ROOT CAUSE (WHY + WHERE)** — Statement dispatch recognized scalar regex mutation only. The existing target
  descriptor, pure split dispatcher, and typed `bind_array` store transition supplied all required seams.
- [x] **FIX** — Detect dropped split calls whose first argument is an explicit `array(target)` wrapper, evaluate
  source/delimiter once, reuse pure split semantics, and bind a copied typed array to the named aggregate store.
- [x] **ADDRESSED (verified)** — Focused proof covers regex and literal delimiters, leading/trailing empty fields,
  source preservation, replacement of stale target contents, scalar-held non-wrapper isolation, and pure values.
- [x] **NO REGRESSION** — The complete dual-ABI Lua gate passes 76/76 on PUC Lua and LuaJIT and cleans the native
  adapter tree. Existing rule invocation store copy/restore continues to isolate local aggregate mutation.
- [x] **LOCKSTEP** — Runtime status, task/index/roadmaps, Lua README, architecture/live docs, mdBook, Knowledge Map,
  changes/notes, and memory advance together to regex/split/mutation no-drift `.2.2.5`.

### `LUA-BACKEND-PARITY.4.3.2.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua parsed scalar-target `substr`/`regex_subst` calls but executed every dropped
  call as a pure value expression, so four-argument substitution either sliced incorrectly or was unsupported.
- [x] **ROOT CAUSE (WHY + WHERE)** — `execute_block` had no statement-context dispatch. The typed helper-regex
  adapter and PCRE2 match spans already supplied the correct compile and replacement iteration seams.
- [x] **FIX** — Detect dropped four-argument calls with bare scalar targets before pure evaluation; normalize
  operation flags, expand `$0`/`$n`, mutate the scalar store, and make global zero-width matches progress by one
  decoded UTF-8 scalar.
- [x] **ADDRESSED (verified)** — Focused proof covers string/regex patterns, `g/i/o`, first-only replacement,
  `$0`/`$1`, Unicode zero-width progress, invalid pattern/flag rule attribution, and pure discarded/value substr.
- [x] **NO REGRESSION** — The complete dual-ABI Lua gate passes 75/75 on PUC Lua and LuaJIT and cleans the native
  adapter tree. Explicit array-target split remains isolated under `.2.2.4`.
- [x] **LOCKSTEP** — Runtime status, task/index/roadmaps, Lua README, architecture/live docs, mdBook, Knowledge Map,
  changes/notes, and memory advance together to explicit array split replacement `.2.2.4`.

### `LUA-BACKEND-PARITY.4.3.2.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua recognized `split` as a current helper but the runtime had no value dispatcher;
  string receiver chains could not cross from a scalar to a typed array result.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` lacked literal splitting, PCRE2 delimiter iteration, and
  Unicode empty-delimiter handling. The existing helper-regex adapter supplied the correct strict compile seam.
- [x] **FIX** — Add copied literal, Unicode-character, and regex split paths; preserve empty fields; make zero-width
  matches advance by a decoded UTF-8 scalar; expose `split` through function and string receiver evaluation.
- [x] **ADDRESSED (verified)** — Focused proof covers literal/regex/case-insensitive/empty-delimiter/zero-width,
  receiver form, invalid/unknown/null/non-text boundaries, source non-mutation, Unicode substr, and literal replace.
- [x] **NO REGRESSION** — The complete dual-ABI Lua gate passes 74/74 on PUC Lua and LuaJIT and cleans the native
  adapter tree. Array-method continuation stays under dependent `.4.3.4` rather than leaking array scope here.
- [x] **LOCKSTEP** — Runtime status, task/index/roadmaps, Lua README, architecture/live docs, mdBook, Knowledge Map,
  changes/notes, and memory advance together to scalar regex mutation `.2.2.3`.

### `LUA-BACKEND-PARITY.4.3.2.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua parsed `matches("AbC", /^abc$/igo)` with exact regex pattern/flags but
  `evaluate_expr` rejected regex values and the pure helper dispatcher omitted `matches`.
- [x] **ROOT CAUSE (WHY + WHERE)** — Rule matching already had the correct PCRE2 owner in `matching.lua`; the
  missing seam was an internal helper-regex value plus operation-specific flag policy in `interpreter.lua`.
- [x] **FIX** — Add typed helper-regex evaluation, deterministic `imsx` prefix normalization, `g/o` no-ops,
  unknown/invalid fail-closed compilation caching, and function/terminal receiver `matches` dispatch.
- [x] **ADDRESSED (verified)** — Focused runtime coverage proves plain search, `i/m/s/x`, no-op `g/o`, null,
  non-regex, unknown flag, invalid pattern, receiver equivalence, and terminal-chain rejection.
- [x] **NO REGRESSION** — The complete dual-ABI Lua gate passes 73/73 on PUC Lua and LuaJIT and removes its
  disposable native adapter tree on exit.
- [x] **LOCKSTEP** — Runtime status, task/index/roadmaps, Lua README, architecture/live docs, mdBook, Knowledge Map,
  changes/notes, and memory advance together to pure split `.2.2.2`.

### `LUA-BACKEND-PARITY.4.3.2.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `matches`, pure `split`, statement `substr`/`regex_subst`, and explicit array split
  all parse in Lua but currently reach unsupported evaluator paths; one broad commit would mix value evaluation,
  PCRE2 policy, receiver typing, and two distinct mutable stores.
- [x] **ROOT CAUSE (WHY + WHERE)** — `action_parser.lua` preserves regex pattern/flags and target wrappers, while
  `interpreter.lua` neither evaluates `ActionExpr(kind="regex")` nor distinguishes dropped statement calls from
  value calls. `matching.lua` already owns compiled PCRE2 patterns but has no helper-flag adapter.
- [x] **FIX** — Adopt ordered children `.1` helper regex/`matches`, `.2` pure split/receiver, `.3` scalar regex
  mutation, `.4` array split mutation, and `.5` corpus/public no-drift.
- [x] **ADDRESSED (verified)** — Lua AST JSON and Perl lowering/runtime probes cover valid flags, pure split,
  Unicode substring, literal replacement, scalar capture substitution, and explicit array-target source shapes.
- [x] **NO REGRESSION** — Planning-only: no runtime source changed. Memory/doctrine/Knowledge Map/mdBook build and
  diff checks are the commit gate.
- [x] **LOCKSTEP** — Task frontier/index, roadmap summaries, architecture/live docs, Knowledge Map, changes/notes,
  memory, Lua README, and the stale retired-`concat` catalog link are synchronized.

### `LUA-BACKEND-PARITY.4.3.2.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The Knowledge Map fact and `LinkedSpec::Get`/`call_spec_handler_subst` probes showed
  Perl rejecting booleans/references while Rust/Dart/Julia/Lua erased null and containers; host boolean and decimal
  spellings also diverged.
- [x] **ROOT CAUSE (WHY + WHERE)** — Perl `MethodLowering` used a ref rejection loop, Rust `RuntimeValue::to_str`
  used empty fallback, Dart `_scalarString`, Julia `_runtime_scalar_string`, and Lua `scalar_string` inherited three
  host policies instead of one language-owned conversion boundary.
- [x] **FIX** — ADR `0028` plus the neutral contract define typed scalar text; every backend now converts booleans
  and finite numbers identically, and `cat` propagates null for null/array/harray values. Codeblock is non-text but
  its explicit portable call syntax remains correctly owned by `.11.1`; `concat` remains retired.
- [x] **ADDRESSED (verified)** — The same contract source/expected object passes Perl, Rust, Dart, Julia, PUC Lua,
  and LuaJIT function/receiver paths; direct Rust value tests cover every representable kind and numeric boundary.
- [x] **NO REGRESSION** — Full Rust, Dart, Julia, and dual-ABI Lua gates pass. Rust/Dart each pass CLI 61x2 and
  corpus 105/105; Lua passes 72/72 on both ABIs; canonical local CI passes both CLI matrices, Phase 0 `1..1030` in
  553s, and every shared governance/contract gate.
- [x] **LOCKSTEP** — ADR/index, neutral contract, runtime tests, task/index/roadmaps, mdBook/guide, Knowledge Map,
  live docs, changes/notes, memory, and CI input/run wiring are aligned.

### `LUA-BACKEND-PARITY.4.3.2.1.2.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Standard Lua has no portable Unicode casing API and the runtime deliberately rejected
  the casing helpers rather than falling back to byte/locale `string.lower`/`string.upper`.
- [x] **ROOT CAUSE (WHY + WHERE)** — The pure dispatcher omitted casing and Lua lacked generated tables plus a
  Unicode-scalar UTF-8 boundary implementation.
- [x] **FIX** — Generation/checking now includes a pure-Lua module with strict UTF-8 decode/encode, full mappings,
  merged contextual properties, and Final Sigma; helper/receiver/array-value paths reuse it.
- [x] **ADDRESSED (verified)** — All 12 fixtures pass direct/helper/receiver/array paths on PUC Lua and LuaJIT.
- [x] **NO REGRESSION** — The dual-ABI Lua gate passes 71/71 and removes its disposable native adapters.
- [x] **LOCKSTEP** — One neutral fixture and byte-checked generated modules establish exact six-variant behavior;
  task/roadmap/live docs/KM/book close casing before `.1.3` becomes active.

### `LUA-BACKEND-PARITY.4.3.2.1.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The durable host-gap fact identified Dart/Julia simple/special-case divergence; source
  inspection located host casing in each runtime's scalar and array dispatcher.
- [x] **ROOT CAUSE (WHY + WHERE)** — DSL casing still delegated to Dart/Julia host releases instead of the pinned
  neutral contract, while standalone array mutation delegated through those same unpinned array helpers.
- [x] **FIX** — The shared generator/checker now emits and byte-compares Dart/Julia mapping/property/context modules;
  every scalar, receiver, value-array, and mutating-array DSL path routes through them.
- [x] **ADDRESSED (verified)** — All 12 fixtures pass direct/helper/receiver/array paths in both backends, including
  expansion, combining output, supplementary scalars, Final Sigma context, and no normalization.
- [x] **NO REGRESSION** — Full Dart gate passes 182 tests, CLI 61x2, corpus 105/105, format/analyze; full Julia gate
  passes its package suite, primary CLI conformance, and corpus 105/105; full local CI passes CLI 61x2 and phase0
  `1..1030` plus every shared contract/doctrine/documentation gate.
- [x] **LOCKSTEP** — Generator/checker/CI tracked files, task/index/roadmaps, live docs, KM, and mdBook identify four
  aligned implementation variants and PUC Lua/LuaJIT as the active final admission leaf.

### `LUA-BACKEND-PARITY.4.3.2.1.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec introspection showed Perl emitted `lc`/`uc`; source inspection showed Rust
  called host `to_lowercase`/`to_uppercase` in scalar and both array execution seams.
- [x] **ROOT CAUSE (WHY + WHERE)** — Neither backend consumed the pinned neutral contract, so behavior and future
  drift remained controlled by the installed Perl/Rust Unicode tables rather than LinkedSpec language data.
- [x] **FIX** — One generator now emits deterministic Perl/Rust modules with full mappings, merged properties,
  Final_Sigma evaluation, pinned version/digest metadata, and drift comparison. Every owned casing path calls them.
- [x] **ADDRESSED (verified)** — All 12 fixtures pass direct, function, receiver, value-array, and mutating-array
  paths in both backends; fresh-process Perl proves ordinary compilation loads the module, and generated source
  declares its dependency explicitly.
- [x] **NO REGRESSION** — Focused Perl 52/52, direct phase0 `1..1030`, the complete Rust runtime package, and
  authoritative full local CI (CLI 61x2; phase0 `1..1030`) pass. The first phase0 run exposed a missing in-process
  module load; root-cause correction and both full reruns are green.
- [x] **LOCKSTEP** — Generator/checker/CI tracked files, task/index/roadmaps, live docs, Knowledge Map, and mdBook all
  identify Perl/Rust as complete and Dart/Julia as the active next rollout leaf.

### `LUA-BACKEND-PARITY.4.3.2.1.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Host case libraries do not expose one pinned mapping/version, and the repository had
  no authoritative data artifact from which every backend could be generated.
- [x] **ROOT CAUSE (WHY + WHERE)** — Case semantics lived implicitly in backend host calls; no checksum-locked UCD
  inputs, neutral map/property schema, context evaluator, or generated-artifact checker existed.
- [x] **FIX** — Added exact gzip-preserved Unicode 17 inputs, deterministic neutral generation, full lower/upper maps,
  merged Cased/Case_Ignorable ranges, explicit Final_Sigma, 12 fixtures, and the offline CI drift checker.
- [x] **ADDRESSED (verified)** — `python3 tools/check_unicode_case_contract.py` passes with 1,563 lower, 1,581 upper,
  158/464 property ranges, one context rule, 12 independently executed fixtures, and byte-identical regeneration.
- [x] **NO REGRESSION** — No backend runtime path changed; `bash tools/run_ci_local.sh` passes phase0 `1..1030`,
  CLI 61x2, capability 60/0/0, every adjacent contract, and the new pinned Unicode check.
- [x] **LOCKSTEP** — ADR `0027`, the task owner, Unicode data README, contract metadata, and CI tracked-input audit
  share the exact version, source hashes, policy, generator path, and fixture count.

### `LUA-BACKEND-PARITY.4.3.2.1.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Existing host APIs produce three different results for `ß`, `İ`, and `ﬃ`, and do
  not expose a common Unicode-version guarantee.
- [x] **ROOT CAUSE (WHY + WHERE)** — The language contract named lower/uppercase but delegated version, full/simple,
  contextual, locale, and normalization choices to Perl/Rust/Dart/Julia hosts; standard Lua has no Unicode mapper.
- [x] **FIX** — ADR `0027` adopts Unicode 17.0.0 full Default Case Conversion and a generated, checksum-locked,
  offline-gated data path shared semantically by every backend.
- [x] **ADDRESSED (verified)** — Contract/data, Perl+Rust, Dart+Julia, and Lua+six-variant admission have ordered,
  commit-sized child owners with no host-fallback loophole.
- [x] **NO REGRESSION** — No runtime or fixture behavior changed; committed Lua 70x2/full-CI proof remains valid.
- [x] **LOCKSTEP** — ADR/index, task/index, roadmaps, book, KM, live docs, changes/notes, and memory agree.

### `LUA-BACKEND-PARITY.4.3.2.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The Lua runtime recognized pure string calls but raised `unsupported runtime helper`
  for all of them, and receiver calls failed because the receiver was not injected as the first helper value.
- [x] **ROOT CAUSE (WHY + WHERE)** — `lua/src/linkedspec/interpreter.lua` dispatched only narrow control/store/
  capture calls. It had no pure-helper classifier, lazy fallback evaluator, stable scalar conversion, Unicode
  codepoint slicing/trim, literal rewrite layer, or receiver-aware dispatch.
- [x] **FIX** — Added canonical pure-string dispatch with lazy coalescing, false/null-safe coercion, explicit Unicode
  whitespace and codepoint offsets, literal operations, lexical comparisons, and receiver/terminal-chain handling.
- [x] **ADDRESSED (verified)** — The new runtime test covers every owned family, Unicode values, lazy skipped failure,
  function/receiver equivalence, terminal continuation, null propagation, and Lua 5.1/5.4 identity.
- [x] **NO REGRESSION** — 70/70 tests pass under separately built PUC Lua and LuaJIT PCRE2 modules; full CI passes.
- [x] **LOCKSTEP** — Lua README, mdBook/status, task/index/roadmaps, KM, live docs, changes/notes, and memory agree.

### `LUA-BACKEND-PARITY.4.3.2.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Real host probes show `uppercase("ß")` yields `SS` in Perl, `ß` in Dart, and `ẞ`
  in Julia; `lowercase("İ")` and `uppercase("ﬃ")` also diverge.
- [x] **ROOT CAUSE (WHY + WHERE)** — Existing backends delegate `lowercase`/`uppercase` to host libraries, while
  the DSL/book selects no Unicode version or simple/full/special-casing policy. PUC Lua and LuaJIT have no portable
  built-in Unicode case mapper, so implementing this as `string.lower`/`string.upper` would add ASCII-only drift.
- [x] **FIX** — Split deterministic non-casing helpers into `.4.3.2.1.1` and a versioned neutral all-variant casing
  contract/fixture/repair into `.4.3.2.1.2` before behavior code.
- [x] **ADDRESSED (verified)** — Exact divergent examples, backend mechanisms, encoding distinction, and owner are
  durable in `docs/knowledge/unicode-case-mapping-cross-backend-gap.md` and visible in the mdBook.
- [x] **NO REGRESSION** — No runtime behavior changed; the committed Lua 69x2/full-CI proof remains authoritative.
- [x] **LOCKSTEP** — Task/index, roadmaps, mdBook, Knowledge Map, live docs, changes/notes, and memory agree.

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
| `LUA-BACKEND-PARITY.3.4` | `LUA-BACKEND-PARITY.3.4 - compile Lua spec state` | Ordered effective state, dependency regexes, ActionIR payloads, exact descriptor, and matching handoff. |
| `LUA-BACKEND-PARITY.4.1` | `LUA-BACKEND-PARITY.4.1 - add Lua runtime matching` | Disposable dual-ABI PCRE2 adapter, neutral matches/registers, and rule-runtime handoff. |
| `LUA-BACKEND-PARITY.4.2` | `LUA-BACKEND-PARITY.4.2 - add Lua runtime rule interpreter` | First compiled-rule interpreter, lifecycle/edge dispatch, local results/control, and helper-family split handoff. |
| `LUA-BACKEND-PARITY.4.3.0` | `LUA-BACKEND-PARITY.4.3.0 - split Lua runtime helper families` | Planning-only ordered split into core values, scalar/string, numeric, array, harray, controls/blocks, stateful capture/cursor, diagnostics, and no-drift. |
| `LUA-BACKEND-PARITY.4.3.1` | `LUA-BACKEND-PARITY.4.3.1 - add Lua runtime value capture helpers` | Four-kind stores/snapshots, checked access/assignment, complete entry/match reads, and scalar/string handoff. |
| `LUA-BACKEND-PARITY.4.3.2.0` | `LUA-BACKEND-PARITY.4.3.2.0 - split Lua scalar string mechanisms` | Planning-only split of pure scalar evaluation from regex/split/statement mutation. |
| `LUA-BACKEND-PARITY.4.3.2.1.3` | `LUA-BACKEND-PARITY.4.3.2.1.3 - align scalar text coercion` | Typed neutral coercion contract, exact six-variant fixture, and regex/split/mutation handoff. |
| `LUA-BACKEND-PARITY.4.3.2.2.0` | `LUA-BACKEND-PARITY.4.3.2.2.0 - split Lua regex string mechanisms` | Planning-only split into helper regex, pure split, scalar mutation, array mutation, and no-drift. |
| `LUA-BACKEND-PARITY.4.3.2.2.1` | `LUA-BACKEND-PARITY.4.3.2.2.1 - add Lua helper regex matches` | Strict helper flags, fail-closed PCRE2 compilation, function/receiver `matches`, and pure-split handoff. |
| `LUA-BACKEND-PARITY.4.3.2.2.2` | `LUA-BACKEND-PARITY.4.3.2.2.2 - add Lua pure split bridge` | Literal/regex/Unicode pure split values, receiver bridge, zero-width progress, and scalar-mutation handoff. |
| `LUA-BACKEND-PARITY.4.3.2.2.3` | `LUA-BACKEND-PARITY.4.3.2.2.3 - add Lua scalar regex mutation` | Statement-context scalar substitution, strict flags, capture expansion, diagnostics, and array-mutation handoff. |
| `LUA-BACKEND-PARITY.4.3.2.2.4` | `LUA-BACKEND-PARITY.4.3.2.2.4 - add Lua array split mutation` | Explicit aggregate replacement through pure split semantics, store-boundary proof, and no-drift handoff. |
| `LUA-BACKEND-PARITY.4.3.2.2.5.0` | `LUA-BACKEND-PARITY.4.3.2.2.5.0 - route Lua string corpus proof` | Direct blocker inventory, phase-6 shipped-case routing, and focused no-drift handoff. |
| `LUA-BACKEND-PARITY.4.3.2.2.5.1` | `LUA-BACKEND-PARITY.4.3.2.2.5.1 - close Lua string helper parity` | Dual-ABI 76/76, canonical `cat` public surfaces, parent closure, and numeric handoff. |
| `LUA-BACKEND-PARITY.4.3.3.0` | `LUA-BACKEND-PARITY.4.3.3.0 - split Lua numeric helper mechanisms` | Read-only contract/runtime audit and four mechanism-sized implementation/closeout owners. |
| `LUA-BACKEND-PARITY.4.3.3.1.0` | `LUA-BACKEND-PARITY.4.3.3.1.0 - split scalar numeric contract alignment` | Measured five semantic drift classes and split neutral policy plus three backend rollout leaves. |
| `LUA-BACKEND-PARITY.4.3.3.1.1` | `LUA-BACKEND-PARITY.4.3.3.1.1 - adopt scalar numeric helper contract` | ADR 0029, 55-case v1 fixture, independent evaluator/source renderer, and recurring local-CI gate. |
| `LUA-BACKEND-PARITY.4.3.3.1.2` | `LUA-BACKEND-PARITY.4.3.3.1.2 - align Perl Rust scalar numeric helpers` | Dedicated Perl/Rust strict numeric adapters, unchanged 55-case direct proof, and Dart/Julia handoff. |
| `LUA-BACKEND-PARITY.4.3.3.1.3` | `LUA-BACKEND-PARITY.4.3.3.1.3 - align Dart Julia scalar numeric helpers` | Strict native Dart/Julia adapters, unchanged 55-case direct proof, and Lua six-runtime handoff. |
| `LUA-BACKEND-PARITY.4.3.3.1.4` | `LUA-BACKEND-PARITY.4.3.3.1.4 - implement Lua scalar numeric helpers` | Portable Lua evaluator, dual-ABI 55-case proof, and exact six-runtime admission. |
| `LUA-BACKEND-PARITY.4.3.3.2` | `LUA-BACKEND-PARITY.4.3.3.2 - add Lua numeric call and receiver forms` | Exact word/symbol calls, scalar receiver composition/terminality, and slash/regex disambiguation. |
| `LUA-BACKEND-PARITY.4.3.3.3` | `LUA-BACKEND-PARITY.4.3.3.3 - add Lua numeric aggregate reducers` | Strict copied-array reducers, empty/invalid boundaries, and six terminal receiver forms. |
| `LUA-BACKEND-PARITY.4.3.3.4` | `LUA-BACKEND-PARITY.4.3.3.4 - close Lua numeric helper parity` | Complete canonical/alias/mechanism proof, public no-drift, parent closure, and array handoff. |
| `LUA-BACKEND-PARITY.4.3.4.0` | `LUA-BACKEND-PARITY.4.3.4.0 - split Lua array helper mechanisms` | Existing-seam audit, six executable children, mutation-result supersession finding, and external repair routing. |
| `LUA-BACKEND-PARITY.4.3.4.1` | `LUA-BACKEND-PARITY.4.3.4.1 - add Lua array construction splicing` | Ordered constructors/literals, explicit AST-context splices, copied flat/concat values, and dual-ABI isolation proof. |
| `LUA-BACKEND-PARITY.4.3.4.2` | `LUA-BACKEND-PARITY.4.3.4.2 - add Lua copied array selection` | Copied take/drop/slice/order/membership/uniq, receiver chains, invalid boundaries, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.4.3` | `LUA-BACKEND-PARITY.4.3.4.3 - add Lua array transform pipelines` | Delimiter-first joins, PCRE2 split/filter, Unicode transforms, seven rebindings, isolation, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.4.4` | `LUA-BACKEND-PARITY.4.3.4.4 - close Lua array mutation flow` | Typed implicit accumulators, cached child push, zero-based selection, binding reuse, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.4.5` | `LUA-BACKEND-PARITY.4.3.4.5 - add Lua tagged record construction` | Governed split reuse, exact typed record shapes, copied carried fields, one-time evaluation, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.4.6` | `LUA-BACKEND-PARITY.4.3.4.6 - close Lua array helper parity` | Exact 34-name ordinary array inventory, public result repair/guard, parent closure, and harray handoff. |
| `LUA-BACKEND-PARITY.4.3.5.0` | `LUA-BACKEND-PARITY.4.3.5.0 - split Lua harray helper mechanisms` | Read-only 16-name audit and six executable construction/view/transform/mutation/closeout owners. |
| `LUA-BACKEND-PARITY.4.3.5.1` | `LUA-BACKEND-PARITY.4.3.5.1 - add Lua harray construction splicing` | Runtime-kind flat, copied flat_hash, explicit hash/list splices, nested preservation, and isolation. |
