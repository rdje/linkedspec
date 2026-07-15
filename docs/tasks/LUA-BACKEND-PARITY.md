# LUA-BACKEND-PARITY: Lua LinkedSpec Backend Parity

## Metadata

- Tree ID: `LUA-BACKEND-PARITY`
- Status: `active`
- Roadmap lane: `Overall roadmap - future backend parity (Lua third)`
- Created: `2026-07-11`
- Last updated: `2026-07-15` (`.6.1.4` permanently admits governed capability offsets 99-104 at 162/162 on both
  Lua ABIs, closes controlled/core parent `.6.1`, and activates advanced/shipped window `.6.2`)
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
  current 246-name public ActionIR surface checks.
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
  Status: `done`
  Goal: Implement the complete helper/value/control/method surface in recursively split batches.
  Children: `.4.3.0`, `.4.3.1`, `.4.3.2`, `.4.3.3`, `.4.3.4`, `.4.3.5`, `.4.3.6`, `.4.3.7`, `.4.3.8`,
    `.4.3.9`
  Acceptance: Every current governed helper and method is behavior-tested, including scalar/string/number,
    array/harray mutation and pure operations, captures/positions/cursor/marks, controls, assignments, tree walks,
    diagnostic calls, and final-codeblock equivalence; split by mechanism before broad implementation.
  Verification: **PASS 2026-07-15.** The recursively split runtime surface closes with exact execution or explicit
    non-function ownership for all 246 admitted names. PUC Lua and LuaJIT pass 125/125; shared coverage remains
    246/105+1/122 and capability remains 64/0/0. Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 608
    seconds. Generated-source, general-function, corpus-execution, primary-CLI, and diagnostic/trace obligations
    retain later owners.
  Commit: closed by `.4.3.9.2`

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
  Correction 2026-07-13: `.4.3.6.1` establishes that ordinary authored `{ statements }` values execute eagerly,
    including assignment RHS positions; the earlier codeblock-storage fixture was a Lua scaffold contradiction,
    not a portable authoring contract. Structural `block_value` copying/classification remains required for
    contextual final block arguments, registry frames, and future explicit callable values.
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
  scalar/array/harray values, structurally supplied codeblock classification/copying, false/null identity, named
  stores, append/hash/nested mutation, snapshot isolation, failed-path no-autovivification, current-edge `retv`,
  full entry/match families, Unicode lines/spans, and absent null/empty/origin behavior. `.4.3.6.1` later corrects
  ordinary authored brace assignment from inert scaffold behavior to eager evaluation.
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
  Status: `done`
  Goal: Implement harray construction, pure helpers, mutation, views, and receiver chains.
  Children: `.4.3.5.0`, `.4.3.5.1`, `.4.3.5.2`, `.4.3.5.3`, `.4.3.5.4`, `.4.3.5.5`
  Dependencies: `.4.3.1`, `.4.3.4`
  Acceptance: Typed hash/harray construction/copy/flatten, key/value views, merge/pick/drop/rename/set-key,
    hash-index assignment, scalar-held maps, deterministic ordering, receiver forms, and nested-map preservation
    match the catalog.
  Verification: **PASS 2026-07-13.** All 13 non-callback hash names are routed and focused across copied
    construction/splicing, deterministic views, pure transforms/receivers, and named/direct mutation. The three
    block-bearing tree names remain exclusively `.4.3.6`. Both Lua ABIs pass 103/103; public mutation-result and
    selector guards, mdBook, Knowledge Map, cleanup, memory, and doctrines pass. Cross-backend odd arity, flattened
    harray order, rename collision, and other helper caveats remain explicitly owned by `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.5.5 - close Lua harray helper parity`

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
  Status: `done`
  Goal: Implement copied deterministic harray views and membership terminals.
  Dependencies: `.4.3.5.1`
  Acceptance: `count_keys`, `sorted_keys`, `sorted_values`, and `has_key` return exact typed zero/array/boolean
    boundaries, sort values by key, preserve nested values, and compose through function and receiver forms.
  Verification: **PASS 2026-07-13.** Lua now returns exact lexical `sorted_keys`, key-ordered copied
    `sorted_values`, `count_keys`, and presence-based `has_key` results through function and receiver forms.
    Sorted array views continue through array receiver helpers; count/membership results are terminal. Null-valued
    fields remain present, nested values are copied, and wrong-kind/missing sources return `0` or `[]`. A Perl
    toolbox matrix confirms those invalid boundaries and exposed one stale mdBook catalog `undef` claim, now
    corrected to `0`. PUC Lua and LuaJIT pass 101/101 plus exact manifest/CLI scaffolding.
  Commit: `LUA-BACKEND-PARITY.4.3.5.2 - add Lua deterministic harray views`

- ID: `LUA-BACKEND-PARITY.4.3.5.3`
  Status: `done`
  Goal: Implement copied harray transforms and receiver chains.
  Children: `.4.3.5.3.0`, `.4.3.5.3.1`
  Dependencies: `.4.3.5.1`, `.4.3.5.2`
  Acceptance: `merge_hash`, value-form `set_key`, `rename_key`, `drop_keys`, and `pick_keys` copy inputs, preserve
    deterministic override/order semantics and nested values, accept governed bare typed operands, and continue
    through compatible harray or array-view receiver chains.
  Verification: **PASS 2026-07-13.** Contract revalidation `.0` and Lua implementation `.1` establish copied
    merge/set/rename/drop/pick values, bare typed operands, later-overlay override, deterministic Lua rename
    collision behavior, deep nested isolation, and harray/array-view receiver continuation at 102/102 on both
    ABIs. Cross-backend destination-collision drift remains explicitly owned by `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.5.3.1 - add Lua copied harray transforms`

- ID: `LUA-BACKEND-PARITY.4.3.5.3.0`
  Status: `done`
  Goal: Revalidate the harray-transform contract after uniform binding and aggregate-selector retirement.
  Dependencies: `.4.3.5.2`, `FUTURE-PARITY-BACKLOG.12.1`
  Acceptance: Toolbox and neutral-corpus probes establish current Perl/Rust/Dart/Julia behavior for bare-first
    `merge_hash(base, overlay)`, `copy(base)`, removed selector spelling, override/collision rules, pure transform
    boundaries, and compatible receiver chains; stale current-facing Knowledge Map/mdBook/runtime fact claims are
    corrected and the Lua implementation leaf receives one exact contract.
  Verification: **PASS 2026-07-13.** Current Perl returns `2` for both bare-first
    `merge_hash(base, overlay)` and `merge_hash(copy(base), overlay)`, and lowers the bare form to
    `{%base, %overlay}`; exact `hash(base)` now rejects as a removed selector. The checked-in neutral corpus already
    carries bare-first merge with expected `2`; its selected case passes Dart and Julia, and Rust passes the full
    105-case oracle including both merge fixtures. Current backend tests also lock later-argument override, copied
    pure value/receiver transforms, renamed-value preservation, source isolation, and harray-to-array receiver
    bridges. A later direct probe found rename-to-existing-destination policy differs and routed it to backlog `.5`.
    Corrected the obsolete July 4 merge card, composability/receiver/core runtime facts, and mdBook contract; the
    executable Lua leaf now owns the current bare typed binding contract.
  Commit: `LUA-BACKEND-PARITY.4.3.5.3.0 - revalidate harray transform contracts`

- ID: `LUA-BACKEND-PARITY.4.3.5.3.1`
  Status: `done`
  Goal: Implement the revalidated copied harray transforms and receiver chains in Lua.
  Dependencies: `.4.3.5.3.0`
  Acceptance: Implement and focus-test the parent transform contract on PUC Lua and LuaJIT without crossing the
    named-mutation boundary owned by `.4.3.5.4`.
  Verification: **PASS 2026-07-13.** Lua now executes deep-copied `merge_hash`, value-form `set_key`,
    `rename_key`, `drop_keys`, and `pick_keys` through function and receiver paths. Bare base/overlay values merge
    in argument order with later keys overriding; views continue into array receivers; saved nested results remain
    isolated after source mutation; pure set/rename do not alter their source. Lua deterministically lets the old
    value win a destination collision, matching Perl/Julia; Dart/Rust preserve the existing destination, so the
    mdBook warns against portable collision dependence and backlog `.5` owns normalization. PUC Lua and LuaJIT pass
    102/102 plus exact manifest/CLI scaffolding.
  Commit: `LUA-BACKEND-PARITY.4.3.5.3.1 - add Lua copied harray transforms`

- ID: `LUA-BACKEND-PARITY.4.3.5.4`
  Status: `done`
  Goal: Close named harray mutation and direct assignment through one binding seam.
  Dependencies: `.4.3.5.3`
  Acceptance: Standalone `set_key(target, key, value)` and direct `target[key] = value` mutate named typed harrays,
    return independent updated snapshots, create only permitted absent targets, reject wrong kinds with neutral
    fields, and leave pure function/receiver transforms non-mutating.
  Verification: **PASS 2026-07-13.** Statement-context `set_key(target, key, value)` and direct
    `target[key] = value` now share one kind-checked harray binding seam. Absent targets create harrays;
    scalar/array conflicts raise `binding_kind_mismatch` with stable identifier, expected-kind, and actual-kind
    fields; existing scalar-held harrays preserve their binding. Direct assignment yields an independent updated
    snapshot, later nested writes do not alias saved values, and assigned/function/receiver `set_key` remains a
    copied pure transform. PUC Lua and LuaJIT pass 103/103 plus exact manifest/CLI scaffolding.
  Commit: `LUA-BACKEND-PARITY.4.3.5.4 - add Lua named harray mutation`

- ID: `LUA-BACKEND-PARITY.4.3.5.5`
  Status: `done`
  Goal: Close complete Lua non-callback harray helper and public-surface no-drift.
  Dependencies: `.4.3.5.1`, `.4.3.5.2`, `.4.3.5.3`, `.4.3.5.4`
  Acceptance: Focused construction/view/transform/mutation/receiver/invalid proof passes both ABIs; Lua README,
    mdBook, task/index/roadmaps, Knowledge Map, architecture/live docs, cleanup, and doctrines agree before
    callbacks `.4.3.6`; cross-backend caveats stay explicitly owned rather than silently normalized.
  Verification: **PASS 2026-07-13.** Audited the exact ordinary inventory: `hash`, `copy`, and runtime-kind
    `flat` use constructor/generic routes; `flat_hash`, `count_keys`, `sorted_keys`, `sorted_values`, `has_key`,
    `merge_hash`, value `set_key`, `rename_key`, `drop_keys`, and `pick_keys` use the copied harray dispatcher;
    statement `set_key` and direct assignment use uniform binding. Existing focused cases cover every mechanism,
    receivers, invalid boundaries, deep isolation, and mutation results at 103/103 on PUC Lua and LuaJIT. Expanded
    the recurring public mutation-result guard for independent hash-index snapshots and pure receiver set-key.
  Commit: `LUA-BACKEND-PARITY.4.3.5.5 - close Lua harray helper parity`

- ID: `LUA-BACKEND-PARITY.4.3.6`
  Status: `done`
  Goal: Execute immediate codeblock values, structured controls, contextual built-in blocks, and tree callbacks.
  Children: `.4.3.6.0`, `.4.3.6.1`, `.4.3.6.2`, `.4.3.6.3`, `.4.3.6.4`, `.4.3.6.5`, `.4.3.6.6`
  Dependencies: `.4.3.1`-`.4.3.5`
  Acceptance: Immediate blocks return their last values and support block-local return; attached/marker/inline
    if/switch/while forms, signature-governed built-in final-codeblock equivalence, scoped `with`, and deterministic
    array/harray walk/map/reduce callbacks match the governed surface; unsupported built-in block arities fail
    generically. General user-function invocation and its contextual final-codeblock path remain owned by `.5.1`;
    explicit callable literals and dynamic codeblock-variable calls remain owned by `FUTURE-PARITY-BACKLOG.11.7`.
  Verification: **PASS 2026-07-13.** Eager ordinary blocks, lazy inline controls, attached/marker if and switch,
    attached while, metadata-governed helper/receiver `with`, and same-root-kind harray/array callbacks are exact
    through `.1-.5`. Typed missing/wrong codeblock and arity diagnostics remain generic. `tools/run_lua_local.sh`
    passes 114/114 on PUC Lua and LuaJIT plus syntax/corpus/process checks; callable-codeblock and punctuation-light
    neutral checkers pass, capability census is 64/0/0, and the immediately preceding mandatory full local gate
    passes both primary CLI environments at 61/61 plus phase0 `1..1031` in 987 seconds. `.6` aligns every public
    surface and routes general user-function final `callback: codeblock` execution to `.5.1`, explicit callable
    literals/dynamic calls to `FUTURE-PARITY-BACKLOG.11.7`, and generated preservation to `.8.1-.8.4`.
  Commit: closed by `LUA-BACKEND-PARITY.4.3.6.6 - close Lua block control callback parity`

- ID: `LUA-BACKEND-PARITY.4.3.6.0`
  Status: `done`
  Goal: Audit and split Lua block, control, contextual-callback, and traversal mechanisms before behavior code.
  Dependencies: `.4.3.1`-`.4.3.5`
  Acceptance: Current Knowledge Map contracts, ActionIR parser/resolver nodes, interpreter dispatch, backend tests,
    callable-codeblock decisions, and staged-function ownership identify each missing execution seam; executable
    leaves are dependency ordered, and no child claims general user-function execution before `.5.1` or explicit
    callable-codeblock v1 before `FUTURE-PARITY-BACKLOG.11.7`.
  Verification: **PASS 2026-07-13.** Lua already parses and resolves eager `block_value`, generic attached and
    parenthesized final blocks, inline and structured control nodes, but the interpreter preserves blocks as inert
    values and has no control/callback executor. `user_function_registry.prepare_invocation` is not connected to
    runtime dispatch, and `.5.1` owns that connection. The work is split into eager value blocks, inline controls,
    statement controls, contextual built-ins/`with`, tree callbacks, and a no-drift/dependency closeout.
  Commit: `LUA-BACKEND-PARITY.4.3.6.0 - split Lua block control callback mechanisms`

- ID: `LUA-BACKEND-PARITY.4.3.6.1`
  Status: `done`
  Goal: Execute immediate expression-valued blocks with block-local return.
  Dependencies: `.4.3.6.0`
  Acceptance: Eager no-pair brace blocks evaluate statements once in order, return the last expression or null for
    an empty/no-value path, and consume local `return` without leaking it to the enclosing rule. Harray literals
    remain pair-classified, and trailing contextual block arguments remain inert until their callable consumes them.
  Verification: **PASS 2026-07-13.** `evaluate_block_value` executes non-final statements through the existing
    dropped-statement mutation seam, evaluates the final expression as a value, and catches only local return flow.
    One end-to-end case covers scalar last values, early harray return, skipped writes, no-argument null, non-final
    mutation, block receiver dispatch, empty/keyed harray precedence, and inert trailing-block AST preservation.
    The prior `callback = { return("later") }` Lua-only scaffold expectation is corrected to the portable eager
    scalar result. PUC Lua and LuaJIT pass 104/104; Perl toolbox lowering and three focused Rust block tests agree.
  Commit: `LUA-BACKEND-PARITY.4.3.6.1 - execute Lua eager block values`

- ID: `LUA-BACKEND-PARITY.4.3.6.2`
  Status: `done`
  Goal: Execute lazy inline value controls over the expression-valued block seam.
  Dependencies: `.4.3.6.1`
  Acceptance: Inline `if` with `elseif`/`else` branches and inline `switch` with `case`/`default` branches
    evaluate only the selected value branch, preserve false/null distinctions, one-time switch subjects, literal
    bare case labels, and block-local return, diagnose malformed arity generically, and compose as helper,
    assignment, and fluent-return operands on both Lua ABIs. `i`/`elif` remain statement-marker aliases,
    `when`/`otherwise` remain attached-block aliases, and retired/non-surface `unless` remains unknown.
  Verification: **PASS 2026-07-13.** Lua now validates and lazily executes inline `if`/`elseif`/`else` and
    `switch`/`case`/`default`, evaluates only selected payloads, evaluates the switch subject once, preserves
    false/null results and block-local return, and distinguishes literal bare case labels from compound value
    expressions. Generic typed arity failures cover unambiguous malformed call shapes. Structural-only aliases
    are rejected as inline values. Assignment and action-edge fluent return composition pass 105/105 on PUC Lua
    and LuaJIT. Lua follows Perl-oracle condition truthiness; cross-backend scalar/aggregate truthiness drift is
    durably routed to `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.6.2 - execute Lua lazy inline controls`

- ID: `LUA-BACKEND-PARITY.4.3.6.3`
  Status: `done`
  Goal: Execute attached and marker-delimited statement controls.
  Children: `.4.3.6.3.1`, `.4.3.6.3.2`, `.4.3.6.3.3`
  Dependencies: `.4.3.6.1`
  Acceptance: If-family, switch-family, and while-family statements share the scoped block executor, preserve
    parser order and local return, and never evaluate unselected branches or an extra loop body.
  Verification: **PASS 2026-07-13.** Children `.1`-`.3` execute attached/marker if and switch plus attached while
    through one nesting-aware statement executor. PUC Lua and LuaJIT passed 108/108 before the independent
    punctuation-light syntax slice; callback-bearing built-ins remain owned by `.4` and `.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.6.3.1` through `.4.3.6.3.3` child commits

- ID: `LUA-BACKEND-PARITY.4.3.6.3.1`
  Status: `done`
  Goal: Execute attached and marker `if`/`elseif`/`else` plus `when`/`otherwise` statement forms.
  Dependencies: `.4.3.6.1`
  Acceptance: Exactly one selected branch executes, condition aliases and marker boundaries match ActionIR order,
    empty branches are neutral, and malformed/orphaned control nodes retain structured diagnostics.
  Verification: **PASS 2026-07-13.** One nesting-aware statement-range executor now selects exactly one attached
    or marker branch, skips later conditions and all unselected bodies, preserves empty branches and block-local
    return, and attributes malformed/orphaned chains with `malformed_statement_control`, authored keyword,
    reason, ActionIR kind, and rule. The portable alias matrix is explicit: attached `when/otherwise`, marker
    `i/elif`; broader Perl/Dart/Julia acceptance is non-portable and routed to `FUTURE-PARITY-BACKLOG.5`. One
    end-to-end case covers nested markers, both alias families, skipped fatal paths, empty branches, local returns,
    mixed forms, orphan markers, missing `endif`, duplicate `else`, and `elseif` after `else`. PUC Lua and LuaJIT
    pass 106/106.
  Commit: `LUA-BACKEND-PARITY.4.3.6.3.1 - execute Lua if statement controls`

- ID: `LUA-BACKEND-PARITY.4.3.6.3.2`
  Status: `done`
  Goal: Execute attached and marker `switch`/`case`/`default` statement forms.
  Dependencies: `.4.3.6.3.1`
  Acceptance: The switch subject evaluates once; the first matching case or one default executes; later cases are
    skipped; comparison and null behavior reuse governed scalar equality without host-table coercion.
  Verification: **PASS 2026-07-13.** Attached switch validates nested `case/default` bodies; marker switch scans
    nested `endswitch` depth and optional `endcase` boundaries before evaluating its subject once. Both select the
    first matching case or one default, execute through the shared statement range/block seam, preserve empty and
    local-return bodies, keep bare labels literal, and skip all later candidate/body side effects. Inline,
    attached, and marker forms now share Perl-oracle scalar comparison: null equals empty text, booleans use `0/1`,
    and aggregates are not scalar-comparable. Orphan/missing/duplicate/mixed controls retain typed diagnostics.
    One focused case plus expanded inline assertions pass 107/107 on PUC Lua and LuaJIT. Cross-backend boolean/
    aggregate switch-comparison and marker outside-branch execution drift is routed to
    `FUTURE-PARITY-BACKLOG.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.6.3.2 - execute Lua switch statement controls`

- ID: `LUA-BACKEND-PARITY.4.3.6.3.3`
  Status: `done`
  Goal: Execute attached `while` statements through a deterministic loop-control seam.
  Dependencies: `.4.3.6.3.2`
  Acceptance: Conditions re-evaluate before each body, false initially runs zero bodies, body state is visible to
    the next condition, local return exits only the current block contract, and the governed runaway guard fails
    deterministically with rule attribution.
  Verification: **PASS 2026-07-13.** The indexed statement executor now dispatches typed attached while nodes,
    validates the required body before spending the condition, re-evaluates the condition before every body,
    exposes body mutations to the next condition, preserves false-initial and empty-body behavior, treats
    Perl-reference `next()` as inner-loop continue, and propagates return through the action or expression-block
    boundary that owns it. The configurable guard permits exactly `max_iterations` bodies, rechecks once, and
    emits typed code/keyword/kind/limit/rule fields only if that next condition remains true. One focused case
    passes 108/108 on PUC Lua and LuaJIT. Exact-limit and `next()` drift is routed to backlog `.5`.
  Commit: `LUA-BACKEND-PARITY.4.3.6.3.3 - execute Lua attached while controls`

- ID: `LUA-BACKEND-PARITY.4.3.6.4`
  Status: `done`
  Goal: Execute signature-governed built-in final blocks and scoped `with`.
  Dependencies: `.4.3.6.1`
  Acceptance: For current built-ins declaring a final `codeblock` parameter, `call(args) { ... }` and
    `call(args, { ... })` are identical in helper and receiver form; `with` installs copied temporary bindings and
    restores all prior/absent bindings on success, local return, and error. This leaf does not claim general
    user-function dispatch, which remains `.5.1`.
  Verification: **PASS 2026-07-13.** One copied metadata registry declares helper/receiver `with` plus receiver
    walk/map/reduce final-codeblock signatures. Attached and parenthesized helper/receiver `with` execute the same
    raw final block without eager pre-execution, evaluate the optional value/receiver first, and restore the prior
    or absent uniform `value` binding across scalar/array/harray stores after normal completion, block-local
    return, callback/result-copy failure, or runtime error. Aggregate inputs/results are isolated, compatible
    receiver chains continue, harrays are not promoted, and malformed block type/arity stays typed. Tree
    callbacks reuse the registry but remain behavior-owned by `.5`. PUC Lua and LuaJIT pass 112/112.
  Commit: `LUA-BACKEND-PARITY.4.3.6.4 - execute Lua built-in final blocks`

- ID: `LUA-BACKEND-PARITY.4.3.6.5`
  Status: `done`
  Goal: Execute deterministic harray and array leaf callbacks.
  Children: `.4.3.6.5.1`, `.4.3.6.5.2`
  Dependencies: `.4.3.6.1`, `.4.3.6.4`
  Acceptance: `walk_leaves`, `map_leaves`, and `reduce_leaves` use one scoped callback frame, deterministic paths,
    copied inputs/results, exact continuation, and generic invalid-kind/block-arity boundaries.
  Verification: **PASS 2026-07-13.** `.5.1` establishes the copied/restored callback frame and sorted harray-root
    execution; `.5.2` generalizes one dispatcher by receiver root kind. Harray roots recurse only through nested
    harrays in lexical-key order, while array roots recurse only through nested arrays in zero-based index order;
    cross-kind aggregates remain leaves. Walk/map/reduce copying, scope, continuation, terminality, empty/invalid
    laziness, typed malformed calls, and exact Perl results are locked on both Lua ABIs at 114/114. The mandatory
    full local CI gate exits 0 with capability 64/0/0, both primary CLI environments at 61/61, and phase0
    `1..1031` green in 987 seconds.
  Commit: closed by `LUA-BACKEND-PARITY.4.3.6.5.2 - execute Lua array callbacks`

- ID: `LUA-BACKEND-PARITY.4.3.6.5.1`
  Status: `done`
  Goal: Implement the scoped callback frame and deterministic harray leaf traversal.
  Children: `.4.3.6.5.1.0`, `.4.3.6.5.1.1`, `.4.3.6.5.1.2`
  Dependencies: `.4.3.6.4`
  Acceptance: Lexically sorted harray keys produce stable path/value bindings; walk side effects, mapped copies,
    and typed reduce accumulation match the governed contract without leaking callback locals or aliasing sources.
  Verification: **PASS 2026-07-13.** `.1.0` localized and split the reference argument-loss defect, `.1.1`
    repaired authored-value precedence before optional-scope fallback, and `.1.2` executes deterministic Lua
    harray callbacks through one copied/restored frame. Both Lua ABIs pass 113/113 with an exact Perl-reference
    output lock. The mandatory full local CI gate exits 0 with capability 64/0/0, both primary CLI environments
    at 61/61, and phase0 `1..1031` green in 983 seconds. Array-root traversal was then independently owned and
    closed by `.4.3.6.5.2` without changing this hash-root contract.
  Commit: closed by `LUA-BACKEND-PARITY.4.3.6.5.1.2 - execute Lua harray callbacks`

- ID: `LUA-BACKEND-PARITY.4.3.6.5.1.0`
  Status: `done`
  Goal: Split the reproduced Perl callback append-RHS defect from Lua harray behavior before implementation.
  Dependencies: `.4.3.6.4`
  Acceptance: Use the toolbox and typed AST dump to locate the exact corruption boundary; give the reference repair
    and Lua traversal separate commit-sized owners; record the public depth contract from executable evidence.
  Verification: **PASS 2026-07-13.** The typed AST preserves `cat(key, "@", depth)` intact inside `seen += ...`,
    but `MethodLowering` passes the call through the legacy optional-scope normalizer. With three `cat` arguments,
    its first bare value is stripped as a supposed scope label; the same call in a two-argument return stays intact.
    Perl/Rust traversal source and direct execution also establish `depth == count(path)` (root leaf 1), contrary
    to the mdBook's stale "zero-based depth" wording. Reference repair `.1.1` precedes Lua implementation `.1.2`.
  Commit: `LUA-BACKEND-PARITY.4.3.6.5.1.0 - split callback append scope repair`

- ID: `LUA-BACKEND-PARITY.4.3.6.5.1.1`
  Status: `done`
  Goal: Stop callback append RHS values from being consumed as legacy optional scope labels.
  Dependencies: `.4.3.6.5.1.0`
  Acceptance: `cat(key, ...)` and comparable value helpers retain every authored bare first argument inside
    `+=` callback side effects; direct helper behavior stays unchanged, typed AST/lowering/runtime tests lock the
    exact source location, and accepted optional-scope forms outside the affected value-helper path do not change.
  Verification: **PASS 2026-07-13.** `MethodExpr` now accepts an explicit authored-value-precedence mode: if the
    raw list already satisfies helper arity it is copied intact, and legacy optional-scope stripping remains only
    the invalid-count fallback. `cat`, `num_add`, `num_mul`, scalar `num_min`/`num_max`, `coalesce`,
    `coalesce_nonempty`, optional-width `substr`, and coalesce family inference consume that mode; existing
    collection helpers share the same centralized rule. Typed AST/lowering tests lock every family plus the
    original append RHS. The executable hash-tree test now maps/reduces/walks with `key`/`depth` as first values
    and returns root depth 1/nested depth 2. Focused AST tests pass, and the mandatory full local CI gate exits 0
    with capability 64/0/0, both primary CLI environments at 61/61, and phase0 `1..1031` green.
  Commit: `LUA-BACKEND-PARITY.4.3.6.5.1.1 - preserve authored callback values`

- ID: `LUA-BACKEND-PARITY.4.3.6.5.1.2`
  Status: `done`
  Goal: Implement the shared scoped callback frame and deterministic Lua harray leaf traversal.
  Dependencies: `.4.3.6.5.1.1`
  Acceptance: Lexically sorted harray keys produce stable copied `value`/`key`/`path`/`depth` bindings; walk side
    effects, mapped copies, and typed reduce accumulation match the corrected reference contract without leaking
    callback locals or aliasing sources. Public docs define depth as `count(path)`, so a root leaf has depth 1.
  Verification: **PASS 2026-07-13.** `runtime_scoped_binding.run_frame` snapshots all three private stores for
    ordered `value`/`key`/`path`/`depth` and optional `acc` bindings, copies inputs/results, restores every prior
    or absent value in reverse frame order after success or error, and preserves the existing one-binding `with`
    API. Lua walks harray interiors by lexical key order, treats every non-harray value (including arrays) as a
    leaf, maps into new typed harrays, preserves walk side effects while returning a source copy, threads copied
    typed reduce results, defines depth as path length, keeps reduce terminal, and returns null for non-harray
    receivers without evaluating initial/callback expressions. Empty trees run no callbacks. Focused proof covers
    source/result isolation, exact outer binding restoration, missing/wrong block and arity diagnostics, and the
    exact Perl output `[{...},"a@1;arr@1;y@2;",3,["a@1","arr@1","y@2"]]`. PUC Lua and LuaJIT pass 113/113.
    The mandatory full local CI gate exits 0 with capability 64/0/0, both primary CLI environments at 61/61,
    and phase0 `1..1031` green in 983 seconds.
  Commit: `LUA-BACKEND-PARITY.4.3.6.5.1.2 - execute Lua harray callbacks`

- ID: `LUA-BACKEND-PARITY.4.3.6.5.2`
  Status: `done`
  Goal: Extend leaf traversal to array roots and close root-kind callback continuation.
  Dependencies: `.4.3.6.5.1`
  Acceptance: Zero-based array path components preserve source order while traversal recurses only into nested
    arrays; harrays remain leaves, just as arrays remain leaves under a hash root. One root-kind dispatcher keeps
    harray lexical order intact. Walk/map/reduce return exact types, continuation is exact, callback frames restore
    atomically, and empty/invalid inputs stay lazy and neutral.
  Verification: **PASS 2026-07-13.** The Lua traversal dispatcher now selects the receiver root kind once, obtains
    deterministic children through lexical harray keys or one-based Lua offsets converted to zero-based indexes,
    recurses only when a child has that same runtime kind, and rebuilds typed containers through shared walk/map/
    reduce control. Array callbacks receive copied `value`/`index`/`path`/`depth` and reduce-only `acc`; map and
    walk continue through `.count()`, reduce remains terminal, invalid receivers skip initial/callback evaluation,
    empty arrays run no callbacks, and exact outer bindings restore. The focused fixture also proves a harray leaf
    stays opaque inside an array root and reproduces the checked-in Perl oracle result
    `[[\"0=a\",[\"1/0=b\",\"1/1=c\"],\"2={h}\"],\"0:a;1/0:b;1/1:c;2:{h};\",3,[\"0\",\"1/0\",\"1/1\",\"2\"],\"undef\"]`.
    PUC Lua and LuaJIT pass 114/114 plus syntax, corpus, and process checks; the prior harray proof remains green
    through the shared dispatcher. The mandatory full local CI gate exits 0 with capability 64/0/0, both primary
    CLI environments at 61/61, and phase0 `1..1031` green in 987 seconds.
  Commit: `LUA-BACKEND-PARITY.4.3.6.5.2 - execute Lua array callbacks`

- ID: `LUA-BACKEND-PARITY.4.3.6.6`
  Status: `done`
  Goal: Close Lua immediate-block/control/contextual-built-in/tree-callback no-drift and dependency routing.
  Dependencies: `.4.3.6.2`, `.4.3.6.3`, `.4.3.6.4`, `.4.3.6.5`
  Acceptance: Focused dual-ABI proof, catalog/README/mdBook/KM/task/live state, and unsupported-block diagnostics
    agree; general user-function contextual blocks are explicitly handed to `.5.1`, explicit callable literals and
    dynamic codeblock calls to `FUTURE-PARITY-BACKLOG.11.7`, with no premature parity claim.
  Verification: **PASS 2026-07-13.** The complete focused dual-ABI suite passes 114/114 and locks eager blocks,
    inline/statement controls, built-in final-codeblock contracts, cleanup-safe `with`, root-kind tree callbacks,
    typed unsupported final-kind/arity boundaries, and the punctuation-light exclusions. The independent callable-
    codeblock checker passes 7 literals, 11 calls, 9 invalid literals, 7 invalid calls, 4 invalid declarations,
    and 8 contextual forms; the punctuation-light checker passes 6 standalone, 4 receiver, and 6 excluded forms;
    capability census remains 64/0/0. Public/catalog/book/KM/task/live state agrees. `.5.1` now explicitly owns
    final `callback: codeblock` metadata and attached/parenthesized user-function execution; `.11.7` retains
    `{|params| ...}` literals and dynamic codeblock-variable calls. No parser/runtime code changes in this leaf.
  Commit: `LUA-BACKEND-PARITY.4.3.6.6 - close Lua block control callback parity`

- ID: `LUA-BACKEND-PARITY.4.3.7`
  Status: `done`
  Goal: Implement capture-slice, named-mark, input, and explicit cursor-state helper families.
  Children: `.4.3.7.0`, `.4.3.7.1`, `.4.3.7.2`, `.4.3.7.3`, `.4.3.7.4`, `.4.3.7.5`, `.4.3.7.6`
  Dependencies: `.4.3.1`, `.4.3.6`
  Acceptance: Capture anchors/slices/boundaries, rule-local named marks, Unicode character positions/lengths,
    input views, save/restore and entry/local rewinds, consume continuation, earliest boundary selection, and
    unresolved-rule behavior match the runtime contract.
  Verification: **PASS 2026-07-15.** The 62 unique current capture/mark/input/cursor/control call names agree
    exactly across Lua contracts, the 246-name admitted inventory, interpreter dispatch, and focused execution
    sources. Four placement spellings compile/execute through typed post-action slot events. Governed anonymous,
    named, complete-mark, cursor-control, and boundary fixtures remain exact; all public positions and widths use
    Unicode characters over byte-safe internal state. The dual-ABI gate passes 121/121, complete-mark and
    punctuation-light checkers pass, coverage is 246 names over 105+1 occurrence sources with all 122 public Perl
    contracts present, capability remains 64/0/0, and public selector admission remains 57/27/0. Public/API/book/
    KM/task/live state agrees. Helper caveats remain `.5`; generated preservation/execution remains `.8.1-.8.4`.
  Commit: closed by `LUA-BACKEND-PARITY.4.3.7.6 - close Lua capture cursor parity`

- ID: `LUA-BACKEND-PARITY.4.3.7.0`
  Status: `done`
  Goal: Audit the canonical capture/cursor state model and split it into mechanism-sized executable owners.
  Dependencies: `.4.3.1`, `.4.3.6`
  Acceptance: Contract sources, toolbox probes, Knowledge Map facts, governed fixtures, current Lua state seams,
    split-marker compilation, Unicode projections, and dependency order are inspected before behavior changes;
    every discovered obligation has one explicit child owner and the first executable leaf is dependency-ready.
  Verification: **PASS 2026-07-13.** Canonical Perl/Rust/Dart/Julia sources, four governed fixtures, Lua match
    registers/parser/compiler/interpreter seams, Knowledge Map facts, and shipped marker use were inspected. The
    parent is split into six dependency-ordered mechanisms plus no-drift. A new fact card records byte-offset/
    Unicode seams, unexecuted split-marker nodes, and the corpus-seeded 239-name checker blind spot that omits seven
    documented current mark helpers identically across backends. PUC Lua and LuaJIT remain 114/114; Knowledge Map,
    memory architecture, task metadata, all doctrines, mdBook build, and whitespace checks pass.
  Commit: `LUA-BACKEND-PARITY.4.3.7.0 - split Lua capture cursor mechanisms`

- ID: `LUA-BACKEND-PARITY.4.3.7.1`
  Status: `done`
  Goal: Implement absolute input/live-cursor views and explicit cursor save/restore/rewind controls.
  Dependencies: `.4.3.7.0`
  Acceptance: Input text/length/slice/end position/line/column and cursor position/line/column/rest/rest length use
    Unicode character units at the DSL boundary; cursor save/restore is LIFO and entry/local rewinds preserve
    register snapshots while changing only the live cursor; consume-mode continuation observes the restored cursor.
  Verification: **PASS 2026-07-13.** Lua now dispatches all six whole-input helpers, five live-cursor readers,
    and four explicit cursor controls through byte-safe runtime state with Unicode-character projection at the DSL
    boundary. The focused test locks multibyte input text/length/slice/end coordinates, cursor coordinates/rest,
    receiver continuation, invalid/past-end slices, nested LIFO save/restore, entry/local rewinds, empty restore,
    typed exact-arity failures, and consume continuation from a rewound cursor. `bash tools/run_lua_local.sh`
    passes 115/115 on separately built PUC Lua and LuaJIT adapters plus syntax, CLI-scaffold, and 105-fixture
    manifest checks. The authoritative `bash tools/run_ci_local.sh` passes capability 64/0/0, both primary CLI
    environments at 61/61, phase0 `1..1031` in 918 seconds, and every contract/doctrine/documentation gate.
  Commit: `LUA-BACKEND-PARITY.4.3.7.1 - add Lua input cursor controls`

- ID: `LUA-BACKEND-PARITY.4.3.7.2`
  Status: `done`
  Goal: Implement the anonymous capture-boundary helper family.
  Dependencies: `.4.3.7.1`
  Acceptance: Start/current position/line/column, match-start, live-cursor, and end-of-input stable/length/advancing
    reads share one byte-safe state seam and expose text widths/positions in Unicode characters; invalid spans are
    neutral, advancing forms mutate only after a valid read, and receiver continuation/terminality is exact.
    `start_capture_slice()` follows the governed void mutation contract shared by the helper catalog and the
    Rust/Dart/Julia runtimes; it must not copy Perl's incidental assignment-expression result into Lua.
  Verification: **PASS 2026-07-13.** Lua executes all 16 current anonymous capture calls through one register-
    backed byte-offset seam. The focused Unicode test covers local-match/live-cursor/input-end endpoints, start
    position/line/column, stable and advancing text/length reads, value continuation, valid-only mutation, a
    reversed-span neutral read, void setter semantics, and typed exact-arity diagnostics. `bash
    tools/run_lua_local.sh` passes 116/116 on separately built PUC Lua and LuaJIT adapters plus syntax,
    CLI-scaffold, and exact 105-fixture manifest checks. The authoritative `bash tools/run_ci_local.sh` passes
    capability 64/0/0, both primary CLI environments at 61/61, phase0 `1..1031` in 766 seconds, and every
    contract/doctrine/documentation gate.
  Commit: `LUA-BACKEND-PARITY.4.3.7.2 - add Lua anonymous capture helpers`

- ID: `LUA-BACKEND-PARITY.4.3.7.3`
  Status: `done`
  Goal: Implement the governed current rule-local named marks, named spans, and anonymous/named bridges.
  Dependencies: `.4.3.7.2`, `FUTURE-PARITY-BACKLOG.17.5`
  Acceptance: Current/input-boundary/anonymous mark writers, copy/existence/position readers, match-start/live-
    cursor/end-of-input/two-mark stable and advancing spans, and both bridge directions match the governed
    reference; bare mark identifiers remain symbolic, mark state is isolated by rule label for the parser
    execution, and the exact anonymous/named fixture passes unchanged. `FUTURE-PARITY-BACKLOG.17.4` already
    supplies the parse-scoped rule-label mark store plus `mark_entry_start/end`, `mark_match_start/end`,
    `mark_line`, `mark_col`, and `clear_mark`; this leaf extends that implementation for the remaining governed
    named writers, spans, and bridges rather than creating a Lua-only dialect or parallel mark frame. Final
    shared-inventory admission `.17.5` is complete before this leaf's complete-family parity claim.
  Verification: **PASS 2026-07-15.** Lua extends the admitted parse-scoped rule-label mark store rather than
    creating a second frame. The unchanged governed named-capture fixture returns its exact native value and the
    same value after public `SpecFile` serialization/reconstruction. A supplemental multibyte case locks current,
    input-start, anonymous, and copy/delete writers; stable and advancing current-edge reads; both bridge
    directions; missing/reversed neutral behavior; character-based public positions; valid-only mutation; and
    exact typed arity. `capture_take()` remains the anonymous zero-argument call while `capture_take(name)` uses
    the named-mark overload. `bash tools/run_lua_local.sh` passes 120/120 on separately built PUC Lua and LuaJIT
    adapters plus syntax, CLI-scaffold, and exact 105-fixture manifest checks. The authoritative
    `bash tools/run_ci_local.sh` passes capability 64/0/0, coverage 246/105+1/122, both primary CLI environments
    at 61/61, phase0 `1..1031` in 637 seconds, and every contract/doctrine/documentation gate.
  Commit: `LUA-BACKEND-PARITY.4.3.7.3 - execute Lua named mark spans`

- ID: `LUA-BACKEND-PARITY.4.3.7.4`
  Status: `done`
  Goal: Execute placement-sensitive split and named-mark rule members.
  Dependencies: `.4.3.7.2`, `.4.3.7.3`
  Acceptance: `@capture_slice`, compatibility capture-boundary aliases, and `@mark(name)` compile into explicit
    rule-slot events whose mutations become visible after that matched action site; helper calls remain available
    for in-block timing, malformed names stay typed, and the shipped `@move_pos` source has an executable owner.
  Verification: **PASS 2026-07-15.** Lua compiles preferred `@capture_slice`, compatibility
    `@capture_from_here` / `@move_pos`, and `@mark(name)` into typed `CompiledRuleSlotEvent` records attached to
    the preceding regex slot. The interpreter applies those events after that slot's action/child dispatch and
    before `LE`, through the existing anonymous capture boundary and parse-scoped rule-label mark store. One
    multibyte test locks same-slot invisibility, later-slot visibility, all three anonymous spellings, two named
    marks, Unicode positions, native and serialized-source execution, typed malformed names/fragments, and the
    exact checked-in EBNF `logging_annotation` line. `bash tools/run_lua_local.sh` passes 121/121 on separately
    built PUC Lua and LuaJIT adapters plus syntax, CLI-scaffold, and exact 105-fixture manifest checks. The
    authoritative `bash tools/run_ci_local.sh` passes capability 64/0/0, coverage 246/105+1/122, public-selector
    admission across 57 files with 27 classified references and zero current examples, both primary CLI
    environments at 61/61, phase0 `1..1031` in 633 seconds, and every contract/doctrine/documentation gate.
  Commit: `LUA-BACKEND-PARITY.4.3.7.4 - execute Lua rule slot markers`

- ID: `LUA-BACKEND-PARITY.4.3.7.5`
  Status: `done`
  Goal: Implement non-consuming earliest-boundary capture.
  Dependencies: `.4.3.7.1`
  Acceptance: `capture_until_boundary(rule[, ...])` seeks all usable compiled regex-bearing rules from the live
    cursor, selects the earliest match independent of surrounding parse mode, returns text before the boundary,
    leaves the boundary unconsumed, captures to end-of-input when usable rules have no later match, and returns
    null without cursor movement when every supplied rule is unresolved or unusable. Until helper-caveat owner
    `FUTURE-PARITY-BACKLOG.5` normalizes the public minimum arity, a zero-argument call follows Rust/Dart/Julia by
    returning null without movement rather than copying Perl's generated-handler undefined-subroutine failure.
  Verification: **PASS 2026-07-13.** Lua resolves bare and quoted rule names, ignores unresolved and regex-free
    rules, caches usable compiled alternations separately from ordinary rule matching, and always seeks from the
    live cursor regardless of parse mode. The focused Unicode test locks argument-order-independent earliest
    selection, consume-mode operation, unconsumed boundary rest, character cursor projection, returned-text
    receiver continuation, EOF fallback, all-unusable and zero-argument neutral no-op behavior. `bash
    tools/run_lua_local.sh` passes 117/117 on separately built PUC Lua and LuaJIT adapters plus syntax,
    CLI-scaffold, and exact 105-fixture manifest checks. Full local CI passes capability 64/0/0, CLI 61/61 in
    both option environments, phase0 `1..1031` in 862 seconds, and every contract/doctrine/documentation gate.
  Commit: `LUA-BACKEND-PARITY.4.3.7.5 - add Lua boundary capture`

- ID: `LUA-BACKEND-PARITY.4.3.7.6`
  Status: `done`
  Goal: Close exhaustive Lua capture/cursor helper and public-surface no-drift.
  Dependencies: `.4.3.7.1`-`.4.3.7.5`
  Acceptance: Helper inventory, governed fixtures, marker timing, dual-ABI runtime gates, API docs, mdBook,
    Knowledge Map, task/live state, and later capability routing agree with no premature generated-source or
    capability claim; the documented-mark inventory gap has an explicit cross-backend disposition; parent
    `.4.3.7` closes and diagnostic helper `.4.3.8` becomes the sole active frontier.
  Verification: **PASS 2026-07-15.** A source-derived audit proves 62/62 current calls in the contract family,
    62/62 interpreter dispatch, and 62/62 focused execution-source occurrence. The marker proof covers preferred
    `@capture_slice`, compatibility `@capture_from_here`/`@move_pos`, and `@mark(name)` with exact post-action/
    pre-`LE` timing. `bash tools/run_lua_local.sh` passes 121/121 on both separately built ABIs. The exact seven-
    helper mark checker, 246/105+1/122 coverage report, 57/27/0 public-selector guard, punctuation-light checker,
    and capability 64/0/0 all pass. The former documented-mark gap is resolved cross-backend by completed `.17`.
    API/book/KM/task/live surfaces close native capture/cursor parity without claiming generated Lua support;
    `.8.1-.8.4` retain preservation/execution/admission. No parser/runtime/fixture/capability behavior changed.
  Commit: `LUA-BACKEND-PARITY.4.3.7.6 - close Lua capture cursor parity`

- ID: `LUA-BACKEND-PARITY.4.3.8`
  Status: `done`
  Goal: Implement runtime diagnostic output helpers over a caller-owned event boundary.
  Dependencies: `.4.3.2`, `.4.3.4`, `.4.3.7`
  Acceptance: `print`, `say`, and `print_each` evaluate eagerly, stay out of parse-result values, are quiet without
    a sink, preserve message ordering/Unicode, and expose an event seam that `.4.4` can instrument without changing
    helper semantics; `exit_now` remains immediate typed control.
  Verification: **PASS 2026-07-15.** `runtime_parse(..., { diagnostic_sink = callback })` delivers typed
    `RuntimeDiagnosticOutputEvent` records with helper/rule/message fields. `print` concatenates one or more eager
    values, `say` appends one newline, and `print_each(array, prefix[, suffix])` emits one event per item in source
    order. Missing sinks stay quiet without skipping evaluation; output events never enter `RuntimeParseResult`.
    Focused coverage locks Unicode, null/boolean text, exact Perl-reference optional-suffix behavior, invalid sink/
    arity diagnostics, and immediate typed `exit_now`. `bash tools/run_lua_local.sh` passes 122/122 on PUC Lua and
    LuaJIT. Canonical CI passes capability 64/0/0, coverage 246/105+1/122, CLI 61x2, and Phase 0 `1..1031` in 611
    seconds. The audited cross-backend transport/format drift is routed to `FUTURE-PARITY-BACKLOG.5.1`.
  Commit: `LUA-BACKEND-PARITY.4.3.8 - add Lua diagnostic output events`

- ID: `LUA-BACKEND-PARITY.4.3.9`
  Status: `done`
  Goal: Close exhaustive Lua helper/value/control/method no-drift.
  Children: `.4.3.9.0`, `.4.3.9.1`, `.4.3.9.2`
  Dependencies: `.4.3.1`-`.4.3.8`
  Acceptance: Every governed current name is execution-covered or has a later explicit non-helper owner; exact
    246-name admission, mdBook examples, both runtime gates, statuses, API docs, task trees, Knowledge Map, and
    capability claims agree with zero hidden partial surface before `.4.4`.
  Verification: **PASS 2026-07-15.** The permanent probe executes a sorted view of every admitted call name through
    parse, compile, and runtime. Exactly 233 reach runtime owners and only the thirteen documented structural or
    receiver-only function forms report unsupported; direct `call(rule)` result/`retv`/cursor behavior is focused.
    The public status is `runtime-helper-value-control`. Both Lua ABIs pass 125/125.
  Commit: closed by `.4.3.9.2`

- ID: `LUA-BACKEND-PARITY.4.3.9.0`
  Status: `done`
  Goal: Audit and split exhaustive Lua runtime-call closure before behavior code.
  Dependencies: `.4.3.8`
  Acceptance: Probe all 246 admitted names through the Lua parser/compiler/interpreter; classify every unsupported
    result as a real missing value helper or an explicit statement/receiver-only surface; inspect status and focused
    evidence drift; split repair from final admission; route any cross-backend/reference contradiction durably.
  Verification: **PASS 2026-07-15.** A disposable PUC Lua PCRE2 adapter and generated minimal action per admitted
    name produce 230 handled names and 16 `unsupported runtime helper` results. Thirteen are intentional non-function
    owners: structural `case`/`elif`/`elseif`/`i`/`when`/`while`, receiver-only `walk_leaves`/`map_leaves`/
    `reduce_leaves`, and named-receiver-only `push_back`/`push_front`/`pop_back`/`pop_front`. The remaining exact
    gap is eager value helpers `and`/`or`/`not`. The audit also finds stale public status
    `runtime-numeric-reducers`, reports a duplicate source `or` inventory row, and finds no focused direct
    `call(rule)` execution assertion. `.4.3.9.2` later disproves the duplicate-row report against source history:
    every inspected revision contains exactly one row, so the durable record treats it as an audit-note error.
    Toolbox probes show Perl `return(and(...))` / `return(or(...))` lower through keyword-precedence
    forms and return null, while Rust/Dart/Julia implement eager boolean composition; normalization is routed to
    dependency-gated `FUTURE-PARITY-BACKLOG.5.2`. `.1` owns the Lua logical repair and `.2` the recurring exact
    ownership/status/direct-call admission.
  Commit: `LUA-BACKEND-PARITY.4.3.9.0 - split Lua exhaustive helper closeout`

- ID: `LUA-BACKEND-PARITY.4.3.9.1`
  Status: `done`
  Goal: Execute Lua eager logical value helpers.
  Dependencies: `.4.3.9.0`
  Acceptance: `and`, `or`, and `not` eagerly evaluate every authored argument once left-to-right, compose through
    Lua's already-governed runtime truthiness, return booleans including empty-call false/false/true behavior, work
    in value/receiver-compatible positions, and pass exact Unicode-neutral side-effect proof on PUC Lua and LuaJIT;
    no cross-backend truthiness or Perl-lowering normalization is claimed.
  Verification: **PASS 2026-07-15.** One shared evaluator materializes every authored argument once left-to-right
    before composing with `runtime_truthy`. `and` requires at least one truthful value and otherwise returns false;
    `or` returns true when any value is truthful and false for empty; `not` returns true for empty and negates the
    first value after eagerly evaluating any extras. Focused execution locks false-first `and`, true-first `or`,
    extra-argument `not`, exact side-effect order, false/false/true empty results, Lua's already-governed `"0"` and
    aggregate truthiness, boolean JSON identity, and receiver continuation through `with`.
    `bash tools/run_lua_local.sh` passes 123/123 on PUC Lua and LuaJIT. Cross-backend truthiness, arity, Dart short-
    circuit/empty-`and`, and Perl keyword-lowering normalization remain dependency-gated `.5.2`.
  Commit: `LUA-BACKEND-PARITY.4.3.9.1 - execute Lua eager logical helpers`

- ID: `LUA-BACKEND-PARITY.4.3.9.2`
  Status: `done`
  Goal: Admit exhaustive Lua runtime helper/value/control/method no-drift.
  Dependencies: `.4.3.9.1`
  Acceptance: A recurring exact 246-name probe reports only the thirteen documented non-function owners and zero
    unowned names; direct `call(rule)` execution is focused; the reported duplicate inventory row is resolved from
    source history; public backend status names the completed native helper/value/control boundary without implying
    trace, functions, corpus, CLI, or generated support; dual-ABI, 246/105+1/122, capability, API, book, Knowledge
    Map, task, and canonical gates agree; parent `.4.3` closes and `.4.4` activates.
  Verification: **PASS 2026-07-15.** `action_call_names.current_names()` exposes a defensive sorted internal view
    for the permanent test. Every one of 246 generated `name()` sources parses and compiles; runtime reports exactly
    233 owned function forms plus the thirteen governed structural/receiver-only forms, with no unowned residual.
    Focused `call(Child)` proof locks child result, refreshed `retv`, and cursor 2. `backend_status().parity` now says
    `runtime-helper-value-control`, deliberately short of later trace/functions/corpus/CLI/generated claims. Git
    source-history and current exact scans contain one `or` inventory row, correcting the unreproducible `.0`
    duplicate-note assertion without a fake code edit. PUC Lua and LuaJIT pass 125/125; coverage is 246/105+1/122
    and capability is 64/0/0. Canonical local CI passes CLI 61/61 in default and POSIX environments plus Phase 0
    `1..1031` in 608 seconds.
  Commit: `LUA-BACKEND-PARITY.4.3.9.2 - close Lua runtime helper no drift`

- ID: `LUA-BACKEND-PARITY.4.4`
  Status: `done`
  Goal: Implement structured runtime diagnostics and runtime trace controls.
  Children: `.4.4.0`, `.4.4.1`, `.4.4.2`, `.4.4.3`, `.4.4.4`
  Acceptance: Typed runtime diagnostics carry neutral stage/source/top/deepest-rule/handler identity; default-quiet
    caller-owned tracing exposes exact ordered levels, event primitives, sinks, and runtime interpreter events
    without changing parse results. Full frontend/compiler/function/staged propagation remains `.5.3`, after `.5.1`
    and `.5.2` provide the general staged-function and native-loading owners it must traverse.
  Verification: **PASS 2026-07-15.** Children `.0-.4` split, implement, instrument, and close the exact native
    runtime boundary: structured diagnostics, ordered controls, caller-owned sinks, event primitives, result-neutral
    runtime entrypoints, and interpreter events. PUC Lua and LuaJIT pass 129/129; canonical local CI passes CLI
    61x2 and Phase 0 `1..1031` in 608 seconds. Full native-pipeline trace remains `.5.3` after `.5.1/.5.2`.
  Commit: closed by `LUA-BACKEND-PARITY.4.4.4 - close Lua diagnostics trace no drift`

- ID: `LUA-BACKEND-PARITY.4.4.0`
  Status: `done`
  Goal: Split the broad Lua diagnostics/trace leaf into dependency-correct signoff-sized implementation leaves.
  Acceptance: Structured failure payloads, trace controls/sinks, runtime instrumentation, and no-drift closeout are
    separately owned; dependency-incomplete full-pipeline propagation is explicitly retained by `.5.3` rather than
    being claimed before general staged functions and native loading exist.
  Verification: **PASS 2026-07-15.** Knowledge Map-first comparison against the completed Dart and Julia rollout
    proves both backends implemented runtime diagnostics, controls/sinks, and runtime events before their later
    frontend/compiler/function/staged trace work. Current Lua already has the necessary rule stack, typed runtime
    exception seam, compiled action source, cursor/capture state, and per-parse caller-owned option boundary, but no
    neutral `RuntimeDiagnostic` or trace owner. The split creates `.4.4.1` structured runtime diagnostics, `.4.4.2`
    levels/config/events/sinks, `.4.4.3` runtime instrumentation, and `.4.4.4` no-drift closeout. No Lua behavior or
    capability claim changed; `.4.4.1` is active.
  Commit: `LUA-BACKEND-PARITY.4.4.0 - split Lua diagnostics trace controls`

- ID: `LUA-BACKEND-PARITY.4.4.1`
  Status: `done`
  Goal: Add Lua runtime structured diagnostic payloads and diagnostic-carrying runtime exceptions.
  Acceptance: Runtime failures expose stable `type`, `stage`, `owner_stage`, `summary`, `detail`, `top_rule`,
    `rule_label`, `handler_source_label`, and optional `spec_name` / `spec_path` fields; the deepest available rule
    and source attribution survive stack unwinding, richer inner diagnostics are preserved, textual errors remain
    useful, and successful parse results are unchanged on PUC Lua and LuaJIT.
  Verification: **PASS 2026-07-15.** Lua `RuntimeInterpreterException` tables now carry typed
    `RuntimeDiagnostic` payloads with exact neutral snake-case fields and deterministic JSON. Engine options accept
    optional `spec_name` / `spec_path`; specific `top_rule_selection`, `runtime_input`, `rule_lookup`, and
    `runtime_execution` stages preserve top/deepest-rule/`lua_runtime:rule:<label>` identity. Child and direct
    lookup payloads attach before unwind and survive parent/parse fallback wrapping. Existing message/tostring and
    successful result values are unchanged. PUC Lua and LuaJIT pass 126/126; coverage remains 246/105+1/122 and
    capability remains 64/0/0. Canonical local CI passes both primary CLI environments at 61/61 and Phase 0
    `1..1031` in 613 seconds. Public status is `runtime-structured-diagnostics`; `.4.4.2` is active.
  Commit: `LUA-BACKEND-PARITY.4.4.1 - add Lua runtime diagnostics`

- ID: `LUA-BACKEND-PARITY.4.4.2`
  Status: `done`
  Goal: Add Lua trace levels, controls, structured event primitives, and caller-owned sink routing.
  Acceptance: Ordered none/low/medium/high/full/debug levels, explicit and documented environment configuration,
    enter/exit/decision/mark/dump/log events, stdout/routed-file/mirror sinks, route reset/truncate behavior, and
    direct traced runtime entrypoints are default-quiet and preserve successful parse results on both Lua ABIs.
  Verification: **PASS 2026-07-15.** Lua now exports immutable typed trace levels/config/sink/event/scope records,
    exact named aliases plus numeric thresholds, environment configuration, structured JSON, and balanced event
    rendering. Caller-owned emitters record enter/exit/decision/mark/dump/log events and route bytes to stdout,
    resettable/appending files, or both, with optional level emoji. `runtime_parse` / `runtime_execute` accept a
    direct emitter; `runtime_parse_with_trace` / `runtime_execute_with_trace` construct one without mutating caller
    options. This controls slice deliberately emits only balanced `lua_runtime:parse` events; `.4.4.3` owns deeper
    interpreter events. Disabled/absent tracing is quiet and traced/untraced result JSON is exact. PUC Lua and
    LuaJIT pass 128/128; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
    both primary CLI environments at 61/61 and Phase 0 `1..1031` in 611 seconds. Public status is
    `runtime-trace-controls`; `.4.4.3` is active.
  Commit: `LUA-BACKEND-PARITY.4.4.2 - add Lua trace controls`

- ID: `LUA-BACKEND-PARITY.4.4.3`
  Status: `done`
  Goal: Instrument the Lua runtime interpreter with exact rule, branch, dispatch, lifecycle, cursor, and boundary events.
  Acceptance: The optional emitter covers parse/rule scopes, recursion cutoffs, regex match/no-match, action/blind
    child dispatch, lifecycle blocks, cursor controls, source-boundary capture, and governed mark/capture positions
    where applicable; disabled or absent tracing is a no-op and traced/untraced results are identical on both ABIs.
  Verification: **PASS 2026-07-15.** The optional emitter now spans balanced parse/rule scopes, recursion cutoffs,
    regex match/no-match with alternatives/spans, action/blind child dispatch with target/cursor identity,
    lifecycle source lines, all four cursor controls with stack transitions, successful/unusable source-boundary
    capture, governed helper mark/capture positions, and post-mutation rule-slot capture/named marks. Disabled or
    absent emitters remain no-ops. Focused success/no-match/action/blind/recursion paths preserve exact result JSON.
    PUC Lua and LuaJIT pass 129/129; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local
    CI passes both primary CLI environments at 61/61 and Phase 0 `1..1031` in 610 seconds. Public status is
    `runtime-trace-events`; `.4.4.4` is active. Full frontend/compiler/function/staged trace remains `.5.3`.
  Commit: `LUA-BACKEND-PARITY.4.4.3 - instrument Lua runtime trace`

- ID: `LUA-BACKEND-PARITY.4.4.4`
  Status: `done`
  Goal: Close Lua runtime diagnostics/trace no-drift.
  Acceptance: Focused dual-ABI proofs, public API/status, README/mdBook, Knowledge Map, task/index/roadmaps, live
    docs, and canonical gates agree on the implemented runtime boundary without claiming dependency-incomplete
    full-pipeline tracing; parent `.4.4` closes and staged-function/native-loading `.5.1` becomes active.
  Verification: **PASS 2026-07-15.** Knowledge Map-first comparison with completed Dart/Julia runtime boundaries
    plus exact Lua API/source/test inventory confirms all six ordered levels, immutable environment-aware controls,
    enter/exit/decision/mark/dump/log primitives, stdout/route/mirror sinks, reset/append, result-neutral runtime
    entrypoints, typed runtime diagnostics, and parse/rule/regex/dispatch/recursion/lifecycle/cursor/boundary/
    governed mark-capture events are implemented and documented. No runtime source change is needed. PUC Lua and
    LuaJIT pass 129/129; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
    CLI 61x2 and Phase 0 `1..1031` in 608 seconds. Public status remains `runtime-trace-events`; parent `.4.4`
    closes, `.5.1` activates, and dependency-incomplete full-pipeline trace remains `.5.3`.
  Commit: `LUA-BACKEND-PARITY.4.4.4 - close Lua diagnostics trace no drift`

- ID: `LUA-BACKEND-PARITY.5`
  Status: `done`
  Goal: Implement general current staged-function execution and native loading.
  Children: `.5.1`, `.5.2`, `.5.3`
  Verification: **PASS 2026-07-15.** Staged function dispatch plus fixed/variadic/contextual execution, portable
    native loading/composition, exact v1/v2/v3 outward descriptors, and caller-owned construction/runtime trace
    close through `.5.1-.5.3`. PUC Lua and LuaJIT pass 155/155; all neutral callable/loading/capability/coverage/
    public checks remain green; the census stays four-backend 64/0/0 until all-pass `.8.4`.
  Commit: `LUA-BACKEND-PARITY.5.3.3 - close Lua descriptor trace no drift`

- ID: `LUA-BACKEND-PARITY.5.1`
  Status: `done`
  Goal: Add staged parser registry/function-body dispatch and fixed-v1/variadic-v2 runtime calls.
  Children: `.5.1.0`, `.5.1.1`, `.5.1.2`, `.5.1.3`, `.5.1.4`, `.5.1.5`
  Acceptance: Provider identity, ordered jobs, parse/normalize/stitch phases, failures, and trace match the admitted
    variants without Lua-only queues or cache behavior. Consume `linkedspec-callable-signature-v1` through the
    spec-owned shell, typed function/job records, registry-first ActionIR resolution, and isolated invocation
    frames: fixed v1 calls remain exact; final-rest v2 calls are positional-only, require `min_arity`, evaluate once
    left-to-right, and bind extras as one fresh typed array without Lua vararg/closure dispatch. The unchanged
    neutral fixture, seven invalid definitions, keyword rejection, exact/minimum diagnostics, receiver continuation,
    mixed/empty/fresh rest values, and recursion fence pass on PUC Lua and LuaJIT. Preserve a final
    `callback: codeblock` declaration in spec-owned function signatures/registries and execute attached
    and parenthesized contextual final blocks equivalently in the caller's dynamic context, with copied/restored
    bindings and no harray promotion. Explicit `{|params| ...}` literals and dynamic codeblock-variable calls remain
    routed through `FUTURE-PARITY-BACKLOG.11.7` to dependency-complete Lua owners.
  Verification: **PASS 2026-07-15.** Deterministic staged body dispatch, fixed-v1 execution, exact variadic-v2
    state/runtime, and final contextual-codeblock metadata/runtime are complete through `.5.1.1-.5`; PUC Lua and
    LuaJIT pass 146/146, both neutral callable checkers and unchanged fixtures pass, public/native API/status agree,
    capability remains 64/0/0, and every later boundary retains an explicit owner.
  Commit: `LUA-BACKEND-PARITY.5.1.5 - close Lua staged functions no drift`

- ID: `LUA-BACKEND-PARITY.5.1.0`
  Status: `done`
  Goal: Split staged-function and contextual-codeblock work into dependency-correct signoff-sized leaves.
  Acceptance: Existing Lua shell/registry/compiled/runtime seams and neutral staged/callable contracts are audited
    before code; staged dispatch, fixed execution, variadic metadata/runtime, contextual-codeblock metadata/runtime,
    and no-drift each receive an exact owner without pulling dynamic callable literals out of `.11.7`.
  Verification: **PASS 2026-07-15.** Knowledge Map-first inspection confirms Lua already projects exact-v1 function
    nodes, preserves parse-job/body payloads, owns registry-first contract resolution and isolated pre-execution
    frames, compiles function records, parses generic trailing block arguments, and executes built-in contextual
    blocks—but it does not dispatch body jobs or call registered functions. The neutral staged provider is one
    independent mechanism; fixed runtime execution depends on it; variadic-v2 requires typed shell/state evolution
    before runtime; final `callback: codeblock` requires declaration/normalization before contextual execution.
    Explicit `{|params| ...}` literals and bound codeblock calls remain dependency-gated `.11.7`. No behavior,
    status, capability, or test count changes. PUC Lua and LuaJIT pass the unchanged 129/129; callable-signature
    and callable-codeblock checkers pass 3/9/7 and 7/11/9/7/4/8 inventories; capability remains 64/0/0; mdBook,
    memory, Knowledge Map, task metadata, doctrines, and whitespace gates pass. `.5.1.1` is active.
  Commit: `LUA-BACKEND-PARITY.5.1.0 - split Lua staged function execution`

- ID: `LUA-BACKEND-PARITY.5.1.1`
  Status: `done`
  Goal: Add the minimal Lua staged action-body provider, deterministic job execution, and immutable body stitching.
  Acceptance: Validate and stable-sort exact `StagedParseJob` values by parent path/span/job id; resolve only
    `actionir-body.spec` to `builtin:actionir-body.spec`; record the governed digest/cache/compiled identity; parse
    exact body text through `parse_action_block(...)`; stitch `body_ast` under replace-field policy; expose composed
    shell+dispatch APIs; reject unsupported providers and sidecar drift on PUC Lua and LuaJIT.
  Verification: **PASS 2026-07-15.** `linkedspec.staged_parser_registry` defensively round-trips exact
    `StagedParseJob` values and stable-sorts by parent path, source span, job id, then input order. The sole
    provider resolves `actionir-body.spec` to `builtin:actionir-body.spec`, records the exact governed digest and
    neutral cache/compiled/result identity, and parses body text through `parse_action_block(...)`. Function
    dispatch validates fixed-v1 path/name/params/arity/text/provider/top/result/failure fields, rejects duplicate
    job ids, and rebuilds definitions/specs so source and stitched result remain isolated. Public one/many-job,
    dispatch, stitch-only, and composed shell APIs are exported with typed contextual errors. PUC Lua and LuaJIT
    pass 130/130; coverage remains 246/105+1/122, capability remains 64/0/0, status is
    `runtime-staged-registry`, and `.5.1.2` is active.
    Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 622 seconds.
  Commit: `LUA-BACKEND-PARITY.5.1.1 - add Lua staged body dispatch`

- ID: `LUA-BACKEND-PARITY.5.1.2`
  Status: `done`
  Goal: Execute registered fixed-v1 user functions through the Lua runtime.
  Dependencies: `.5.1.1`
  Acceptance: Registry-first calls evaluate positional arguments once left-to-right in caller scope, execute staged
    `body_ast` in fresh scalar/array/harray stores, return local final/early-return values, restore caller stores on
    success/failure, feed receiver chains, execute-and-discard standalone calls, and diagnose arity/keyword/
    direct-mutual recursion without helper fallback on both ABIs.
  Verification: **PASS 2026-07-15.** `interpreter.lua` resolves registered raw call names before canonical helper
    dispatch, rejects keyword AST arguments before evaluation, evaluates positional arguments exactly once in
    source order, and uses `prepare_invocation(...)` to copy values into fresh scalar/array/harray stores. Each
    function executes a cached typed ActionIR block only after its canonical JSON exactly matches the governed
    staged `body_ast`; missing or drifting staged bodies fail closed. Protected execution restores caller stores
    and the active-function path on success/failure. Final expressions, local early returns, nested calls,
    standalone value drop, array/string/number/harray result chains, caller isolation, exact arity, and direct/
    mutual recursion cycles are locked. Registered keyword contracts use the portable
    `user_function_keyword_arguments_unsupported` diagnostic instead of helper fallback. PUC Lua and LuaJIT pass
    133/133; coverage remains 246/105+1/122, capability remains 64/0/0, public status is
    `runtime-user-functions-fixed-v1`, and `.5.1.3.1` is active. Canonical local CI passes CLI 61x2 plus Phase 0
    `1..1031` in 605 seconds.
  Commit: `LUA-BACKEND-PARITY.5.1.2 - execute Lua fixed user functions`

- ID: `LUA-BACKEND-PARITY.5.1.3`
  Status: `done`
  Goal: Consume the fixed-v1/variadic-v2 callable-signature union natively.
  Children: `.5.1.3.1`, `.5.1.3.2`
  Dependencies: `.5.1.2`
  Acceptance: The spec-owned shell, typed state, registry resolution, and runtime consume the unchanged neutral
    signature contract; descriptor admission remains `.5.3` and generated preservation/execution remains `.8`.
  Verification: **PASS 2026-07-15.** `.5.1.3.1` preserves the exact fixed-v1/variadic-v2 signature union through
    every native state boundary and resolves minimum/unbounded arity at 136/136. `.5.1.3.2` evaluates caller
    arguments once left-to-right, copies the complete frame, binds fixed prefixes normally, and copies all extras
    into one fresh typed rest array. The unchanged neutral fixture plus empty/nonempty/mixed/codeblock/freshness,
    receiver-chain, minimum-arity, and keyword proof pass at 139/139 on both Lua ABIs. Descriptors remain `.5.3`,
    generated source remains `.8`, status is `runtime-user-functions-variadic-v2`, and `.5.1.4.1` is active.
  Commit: children `.5.1.3.1`, `.5.1.3.2`

- ID: `LUA-BACKEND-PARITY.5.1.3.1`
  Status: `done`
  Goal: Preserve variadic-v2 callable signatures through Lua shell, AST, staged records, registry, and compiled state.
  Dependencies: `.5.1.2`
  Acceptance: Fixed v1 retains exact params/arity; variadic v2 uses only the typed callable signature with final
    rest, minimum/unbounded maximum arity, positional-only resolution, identical staged copies, and all seven exact
    invalid-definition diagnostics without prematurely changing outward descriptor or generated-source contracts.
  Verification: **PASS 2026-07-15.** Lua's typed `CallableSignature` preserves exactly kind/version/positional
    parameters/final rest/minimum/unbounded maximum. Fixed-v1 shell, AST, staged jobs, registry, and compiled JSON
    retain only top-level params/arity; variadic-v2 serialized state retains only `callable_signature`, with its
    internal positional mirror derived from and checked against that signature. Exact shell-sidecar/staged identity,
    mixed-version fences, all seven governed invalid definitions, duplicate/reserved identifiers, and malformed
    rest/signature forms are locked through typed diagnostics. Registry resolution accepts every arity at or above
    the fixed-prefix minimum, carries `at least N` expectations through call contracts, and preserves an unbounded
    maximum. Runtime execution and outward descriptor conversion fail closed for `.5.1.3.2` and `.5.3`; generated
    source remains `.8`. PUC Lua and LuaJIT pass 136/136; callable signature/codeblock checkers pass 3/9/7 and
    7/11/9/7/4/8 inventories; coverage remains 246/105+1/122; capability remains 64/0/0; status is
    `runtime-user-functions-variadic-v2-state`; and `.5.1.3.2` is active. Canonical local CI passes CLI 61x2 plus
    Phase 0 `1..1031` in 620 seconds.
  Commit: `LUA-BACKEND-PARITY.5.1.3.1 - preserve Lua variadic signatures`

- ID: `LUA-BACKEND-PARITY.5.1.3.2`
  Status: `done`
  Goal: Execute Lua variadic-v2 user functions through fresh typed rest arrays.
  Dependencies: `.5.1.3.1`
  Acceptance: Arguments evaluate once left-to-right; fixed prefixes bind normally; extras bind as one fresh copied
    typed array including the empty case and nested/null/boolean/codeblock identities; minimum-arity and keyword
    failures are typed; results chain; the unchanged neutral fixture passes on PUC Lua and LuaJIT.
  Verification: **PASS 2026-07-15.** `prepare_invocation(...)` retains every evaluated argument as an isolated
    copy, binds fixed-prefix parameters through the established four-kind stores, and copies extras again into one
    fresh `json.array()` bound through the final rest name. Empty/repeated calls do not alias; nested array/harray,
    null, boolean, and structural codeblock identities survive; caller inputs and the separate typed-store mirror
    remain isolated. The native interpreter executes the unchanged shared callable-signature fixture exactly,
    including fixed/empty/nonempty/mixed/prefix-object/result-chain cases. Supplemental proof locks eager ordered
    side effects, rest mutation, codeblock count, `at least N` runtime diagnostics, and keyword rejection. PUC Lua
    and LuaJIT pass 139/139; callable signature/codeblock checkers pass 3/9/7 and 7/11/9/7/4/8; coverage remains
    246/105+1/122; capability remains 64/0/0; public status is `runtime-user-functions-variadic-v2`; and
    `.5.1.4.1` is active. Descriptor admission remains `.5.3`; generated source remains `.8`.
    Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 621 seconds.
  Commit: `LUA-BACKEND-PARITY.5.1.3.2 - execute Lua variadic functions`

- ID: `LUA-BACKEND-PARITY.5.1.4`
  Status: `done`
  Goal: Consume final contextual `name: codeblock` parameters for Lua user functions.
  Children: `.5.1.4.1`, `.5.1.4.2`
  Dependencies: `.5.1.3`
  Acceptance: Declaration metadata and attached/parenthesized contextual execution match the neutral final-codeblock
    contract without implementing explicit callable literals or bound codeblock-variable invocation.
  Verification: **PASS 2026-07-15.** Metadata and normalization pass 142/142 through `.5.1.4.1`; dynamic
    contextual execution, restoration, precedence, result composition, and typed failures pass 146/146 through
    `.5.1.4.2`. Explicit literals/general dynamic calls remain `.11.7`.
  Commit: `LUA-BACKEND-PARITY.5.1.4.2 - execute Lua contextual codeblocks`

- ID: `LUA-BACKEND-PARITY.5.1.4.1`
  Status: `done`
  Goal: Preserve final codeblock parameter kind through Lua shell, staged records, registry, and call normalization.
  Dependencies: `.5.1.3.2`
  Acceptance: Final-only `callback: codeblock` carries exact typed metadata; attached and parenthesized contextual
    blocks normalize equivalently; invalid non-final/argument-list/missing-name/unknown-type forms reject; harray
    literals are never promoted; built-in contracts remain unchanged.
  Verification: **PASS 2026-07-15.** Lua canonicalizes spec-produced `fixed_params` plus final `codeblock_param`
    into ordered fixed-v1 `params`/`arity` and an exact one-entry `parameter_kinds` harray, then preserves identical
    metadata through the body payload, staged parse job, typed AST round-trip, immutable registry, stitching, and
    compiled JSON. Sidecar drift and the governed non-final, nested-argument-list, missing-name, and unknown-type
    declarations reject. Callable metadata—not callee-name logic—normalizes attached and parenthesized user-function
    blocks to the same zero-positional typed `codeblock_argument` without mutating source ActionIR; harray literals
    remain harrays, and built-in contracts remain exact. Descriptor conversion fails closed for `.5.3`; callback
    execution remains exclusively `.5.1.4.2`. PUC Lua and LuaJIT pass 142/142; signature/codeblock checkers pass
    3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122; capability remains 64/0/0; public status is
    `runtime-user-functions-contextual-codeblock-metadata-v1`; and `.5.1.4.2` is active. Canonical local CI passes
    CLI 61x2 plus Phase 0 `1..1031` in 605 seconds.
  Commit: `LUA-BACKEND-PARITY.5.1.4.1 - preserve Lua final codeblock metadata`

- ID: `LUA-BACKEND-PARITY.5.1.4.2`
  Status: `done`
  Goal: Execute Lua user-function contextual final blocks in the caller's dynamic context.
  Dependencies: `.5.1.4.1`
  Acceptance: Attached and parenthesized zero-positional contextual blocks execute equivalently through the declared
    final slot, see current dynamic bindings, preserve copied/restored parameter stores, keep nonparameter effects
    visible where governed, return ordinary chainable values, and reject wrong-kind/missing callbacks on both ABIs.
  Verification: **PASS 2026-07-15.** Runtime normalization keeps the contextual block inert until the registered
    function frame is prepared, then the declared slot invokes it with zero positional arguments against current
    copied function bindings. Nonparameter writes remain visible to later function statements; the entire frame
    restores before returning to the outer caller; returned values feed receiver chains; and registered functions
    plus governed helpers keep static precedence. Missing and harray callbacks, nonzero contextual calls, and
    active self-invocation produce typed diagnostics. PUC Lua and LuaJIT pass 146/146; signature/codeblock checkers
    pass 3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122; capability remains 64/0/0; public status is
    `runtime-user-functions-contextual-codeblock-v1`; and `.5.1.5` is active. Descriptors remain `.5.3`, generated
    source remains `.8`, and explicit literals/general dynamic calls remain `.11.7`. Canonical local CI passes
    CLI 61x2 plus Phase 0 `1..1031` in 622 seconds.
  Commit: `LUA-BACKEND-PARITY.5.1.4.2 - execute Lua contextual codeblocks`

- ID: `LUA-BACKEND-PARITY.5.1.5`
  Status: `done`
  Goal: Close Lua staged-function/variadic/contextual-codeblock execution no-drift.
  Dependencies: `.5.1.1`, `.5.1.2`, `.5.1.3`, `.5.1.4`
  Acceptance: Focused dual-ABI proof, neutral contract checkers/fixtures, public API/status, docs/book, task/index/
    roadmaps/live/KM, and canonical gates agree; parent `.5.1` closes and native loading `.5.2` activates without
    claiming descriptors/full-pipeline trace `.5.3`, generated execution `.8`, or dynamic callable literals `.11.7`.
  Verification: **PASS 2026-07-15.** Source/API/test/public-doc/KM inventory finds no unowned staged-function
    seam. The only live residue was stale Lua README prose claiming staged dispatch was absent; it now describes
    the implemented registry/runtime and the correct later owners. PUC Lua and LuaJIT remain 146/146; callable
    signature/codeblock checkers pass 3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122; capability remains
    64/0/0; status remains `runtime-user-functions-contextual-codeblock-v1`; parent `.5.1` closes; and `.5.2`
    activates. Descriptor/full trace `.5.3`, generated source `.8`, corpus/CLI later lanes, and explicit/dynamic
    codeblocks `.11.7` remain explicit without partial claims. Canonical local CI passes CLI 61x2 plus Phase 0
    `1..1031` in 644 seconds; mutation testing remains manual-only and was not run.
  Commit: `LUA-BACKEND-PARITY.5.1.5 - close Lua staged functions no drift`

- ID: `LUA-BACKEND-PARITY.5.2`
  Status: `done`
  Goal: Add portable native named/path resolution and in-memory composition.
  Children: `.5.2.0`, `.5.2.1`, `.5.2.2`, `.5.2.3`, `.5.2.4`
  Acceptance: Consume exact name/path/root/UTF-8/stage contract; expose load/compile/create-engine conveniences as
    adapters over native in-memory APIs; remove any backend-local fallback or implicit transcoding.
  Verification: **PASS 2026-07-15.** Typed deterministic resolve/load, cached spec-owned function parsing,
    validation/compile composition, source-identified engines, exact neutral errors, direct 14/9/4 fixture use,
    public APIs/status, and later-owner fences agree through `.5.2.1-.4`. PUC Lua and LuaJIT remain 153/153;
    capability remains 64/0/0 and no host fallback, transcoding, or second loading path exists.
  Commit: `LUA-BACKEND-PARITY.5.2.4 - close Lua native loading no drift`

- ID: `LUA-BACKEND-PARITY.5.2.0`
  Status: `done`
  Goal: Split portable native loading into dependency-correct signoff-sized leaves before code.
  Acceptance: Audit ADR `0026`, the executable 14/9/4 fixture, completed Rust/Dart/Julia public loaders, current
    Lua filesystem/UTF-8/parser/function-shell/staged/compiler/engine seams, and exact later trace/descriptor owners;
    prove whether the current Lua runtime can execute `specs/user_function_definition.spec`; separately own
    resolution/loading, automatic function-shell parsing, full pipeline/engine composition, and no-drift.
  Verification: **PASS 2026-07-15.** Knowledge Map-first inspection confirms the portable contract separates
    `name` from exact `path`, uses cwd exact/cwd suffix/declared direct roots in order, selects the first regular
    file without recursive search, preserves strict UTF-8 text exactly, and exposes typed stage/code failures.
    Lua already owns strict UTF-8 validation, rule-only parse/validate/compile, deterministic staged body dispatch,
    full fixed-v1/variadic-v2/contextual execution, and runtime engine source identity. A direct native probe parses,
    validates, and compiles `specs/user_function_definition.spec`, executes top rule `user_function_definitions`
    against a real `fn zero()` source, and returns one exact `function_definition` node named `zero` with its exact
    body text. The remaining work is therefore ordered as `.5.2.1` portable request/resolution/load plus 14/9/4
    direct fixture consumption, `.5.2.2` automatic spec-defined function-shell parsing with no raw scanner,
    `.5.2.3` parse/validate/compile/create-engine composition and identity/error proof, then `.5.2.4` no-drift.
    No behavior, public status, capability, or test count changes; PUC Lua and LuaJIT remain 146/146, the native
    contract checker passes 14/9/4, capability remains 64/0/0, and `.5.2.1` is active.
  Commit: `LUA-BACKEND-PARITY.5.2.0 - split Lua native spec loading`

- ID: `LUA-BACKEND-PARITY.5.2.1`
  Status: `done`
  Goal: Add portable native spec requests, deterministic resolution, byte loading, and strict UTF-8 decoding.
  Dependencies: `.5.2.0`
  Acceptance: Export typed/identifiable named and exact-path requests, load options, resolved/loaded values, and
    structured pipeline errors; validate all portable name/path boundaries; check cwd exact, cwd suffix, and direct
    roots in declared order with first-candidate deduplication and first-regular-file selection; never recurse or
    use implicit roots; preserve exact caller path identity; read bytes in process; strictly decode UTF-8 without
    BOM removal, normalization, newline conversion, trimming, replacement, or implicit UTF-16/32 transcoding; and
    consume every shared 14 name, 9 resolution, and 4 text case directly on PUC Lua and LuaJIT.
  Verification: `bash tools/run_lua_local.sh` passes PUC Lua 149/149 and LuaJIT 149/149; every shared 14/9/4 case
    is consumed directly; supplemental Unicode-whitespace/control and exact-path boundaries pass; contract,
    capability, coverage, 58-file public admission, mdBook, Knowledge Map, doctrines, and memory checks pass;
    canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 1,265 seconds.
  Commit: `LUA-BACKEND-PARITY.5.2.1 - add Lua native spec loading`

- ID: `LUA-BACKEND-PARITY.5.2.2`
  Status: `done`
  Goal: Add automatic spec-defined top-level function-shell parsing for loaded and inline source.
  Dependencies: `.5.2.1`
  Acceptance: Resolve the repository-owned `specs/user_function_definition.spec` through one deterministic
    bundled/module-relative owner rather than user search roots or recursive fallback; parse/validate/compile it
    once through current native APIs; execute it in process over caller source; normalize only its typed output;
    feed those nodes through the existing Unicode-exact shell projector and deterministic body-job dispatcher;
    expose a composed `parse_spec_with_staged_user_function_definitions(...)` API; and reject parser execution,
    output-shape, projection, or staged failures without introducing a raw `fn` scanner.
  Verification: `bash tools/run_lua_local.sh` passes PUC Lua 151/151 and LuaJIT 151/151. The public parser resolves
    the bundled grammar by exact module-relative path with no search roots, validates/compiles it once, reuses the
    compiled state across direct and composed calls, returns fixed-v1/variadic-v2/final-codeblock nodes in source
    order with Unicode character spans, and dispatches all body jobs. Focused injected parsers prove typed parser-
    spec parse/validation, execution, output-shape, projection, and staged-error ownership. Capability remains
    64/0/0; the parser CLI, corpus execution, loaded-source compile/engine composition, descriptors, generated
    source, and full-pipeline trace remain unclaimed. Native 14/9/4, coverage 246/105+1/122, public 58/27/0,
    mdBook/KM/governance checks pass; canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 631 seconds.
  Commit: `LUA-BACKEND-PARITY.5.2.2 - automate Lua function parsing`

- ID: `LUA-BACKEND-PARITY.5.2.3`
  Status: `done`
  Goal: Compose native loaded text through parse, validation, compilation, and identity-bearing engine creation.
  Dependencies: `.5.2.2`
  Acceptance: Export `load_and_compile_spec(...)` plus a loaded-compiled result that retains request kind/value,
    resolved path, exact source text, and backend-native compiled state; map parse/validation/compile failures to
    the exact neutral stages/codes; create a runtime engine with named identity only for name requests and resolved
    path for both request kinds; prove top-level function compilation/execution, parse-versus-validation ownership,
    runtime diagnostic identity, exact missing-name JSON, and unchanged inline in-memory APIs without CLI,
    subprocess, temporary-file, serialized-handoff, descriptor, or full-pipeline-trace claims.
  Verification: **PASS 2026-07-15.** Public `load_and_compile_spec(...)` returns typed `LoadedCompiledSpec` with
    exact nested request kind/value, resolved path, byte-identical decoded source, and backend-native compiled
    state. It invokes the cached spec-owned function parser, validates once at the explicit boundary, compiles
    without repeating validation, and exposes both `loaded:create_engine(...)` and
    `create_loaded_spec_engine(...)`. Engine options are copied; named requests attach only the requested logical
    name, exact-path requests attach no name, and both attach the resolved path. Fixed top-level function execution,
    inline no-drift, runtime diagnostic identity, exact missing-name JSON, and distinct parse/validation/compile
    stage/code failures pass. `bash tools/run_lua_local.sh` passes PUC Lua 153/153 and LuaJIT 153/153; native
    14/9/4, capability 64/0/0, coverage 246/105+1/122, and public 58/27/0 checks pass. Canonical local CI passes
    both 61/61 CLI environments and Phase 0 `1..1031` in 616 seconds. CLI, subprocess, temporary-file handoff,
    descriptor, full-pipeline trace, generated source, and corpus execution remain unclaimed.
  Commit: `LUA-BACKEND-PARITY.5.2.3 - compose Lua native spec pipeline`

- ID: `LUA-BACKEND-PARITY.5.2.4`
  Status: `done`
  Goal: Close Lua portable native loading no-drift.
  Dependencies: `.5.2.1`, `.5.2.2`, `.5.2.3`
  Acceptance: Focused dual-ABI proof, direct neutral fixture consumption, public APIs/status, docs/book, task/index/
    roadmaps/live/KM, and canonical gates agree; parent `.5.2` closes and descriptor/full-pipeline trace `.5.3`
    activates without claiming generated source, corpus execution, or the parser CLI.
  Verification: **PASS 2026-07-15.** Exact `init.lua` exports, loader composition, status, the two native-pipeline
    tests, 14/9/4 fixture consumption, root/Lua docs, roadmaps/architecture/live state, mdBook API/status/handoff/
    trace pages, task/index, and Knowledge Map agree. No unowned loading seam or stale current-behavior claim was
    found. PUC Lua and LuaJIT remain 153/153; native 14/9/4, capability 64/0/0, coverage 246/105+1/122, and public
    58/27/0 checks pass. No Lua source, behavior, status, capability, or test count changes. Parent `.5.2` closes
    and `.5.3` activates; generated source, corpus execution, and parser CLI remain later owners. Mutation testing
    remains manual-only and was not run. Canonical local CI passes both 61/61 CLI environments and Phase 0
    `1..1031` in 607 seconds.
  Commit: `LUA-BACKEND-PARITY.5.2.4 - close Lua native loading no drift`

- ID: `LUA-BACKEND-PARITY.5.3`
  Status: `done`
  Goal: Admit exact outward descriptors, runtime diagnostics, and full-pipeline trace.
  Children: `.5.3.0`, `.5.3.0.1`, `.5.3.1`, `.5.3.2`, `.5.3.3`
  Dependencies: `.4.4`, `.5.1`, `.5.2`
  Acceptance: Consume shared fixtures/checkers directly, including the exact fixed-v1/variadic-v2 outward function
    descriptor union plus neutral final-codeblock-v3 records and identical staged metadata copies; propagate one
    caller-owned emitter through native loading, frontend, validation, compilation, function-shell, staged dispatch,
    and runtime phases; preserve the four-backend census until all-pass Lua admission `.8.4`; no partial/gap state
    lacks a concrete next owner.
  Verification: **PASS 2026-07-15.** Planning and ADR `0041` establish the exact descriptor/census policy;
    `.5.3.1` implements the governed fixed-v1/variadic-v2/final-codeblock-v3 union; `.5.3.2` passes one caller
    emitter through native IO, frontend/compiler/function/staged phases, engine construction, and runtime; and
    `.5.3.3` confirms exact API/status/test/contract/book/KM no-drift. Both Lua ABIs pass 155/155 with status
    `native-full-pipeline-trace-v1`; the capability census deliberately remains four-backend 64/0/0 until `.8.4`.
  Commit: `LUA-BACKEND-PARITY.5.3.3 - close Lua descriptor trace no drift`

- ID: `LUA-BACKEND-PARITY.5.3.0`
  Status: `done`
  Goal: Audit and dependency-split Lua descriptor, full-pipeline trace, and capability-admission work before code.
  Dependencies: `.4.4`, `.5.1`, `.5.2`
  Acceptance: Inspect the exact neutral fixed-v1/variadic-v2 outward contracts, contextual-codeblock metadata,
    current Lua descriptor fences, every emitter propagation seam, completed Dart/Julia trace precedent, current
    capability-manifest admission policy, and the history of any contradictory owner text; record foundational
    contract conflicts durably; split decision, descriptor, trace, and admission work so no behavior leaf starts
    before its exact source of truth and dependency are settled.
  Verification: **PASS 2026-07-15.** Exact executable-contract, Lua fence, completed-backend precedent, API seam,
    capability policy, and git-history inspection finds two neutral-policy dependencies before behavior code. The
    fixed-v1 and variadic-v2 outward schemas are exact, but no neutral outward function-record schema places the
    final-codeblock `parameter_kinds` metadata that ADR `0032` requires descriptors to preserve. Separately, the
    original `.5.3` immediate-census wording predates commit `4a2adda9`, whose current four-backend census policy
    keeps Lua outside until the dedicated parity tree completes. Runtime alone accepts a caller emitter; every
    loading/frontend/validation/compiler/function/staged seam is now inventoried. `.5.3.0.1` owns the two director
    decisions; `.5.3.1-.3` separately own descriptor implementation, one-emitter propagation, and no-drift/
    selected admission. No source, behavior, status, capability, descriptor, or test expectation changes. PUC Lua
    and LuaJIT remain 153/153; callable-signature/codeblock checkers remain 3/9/7 and 7/11/9/7/4/8; capability
    remains 64/0/0; canonical local CI passes both 61/61 CLI environments and Phase 0 `1..1031` in 605 seconds.
  Commit: `LUA-BACKEND-PARITY.5.3.0 - split Lua descriptor trace admission`

- ID: `LUA-BACKEND-PARITY.5.3.0.1`
  Status: `done`
  Goal: Resolve the outward final-codeblock descriptor schema and Lua capability-census admission timing.
  Dependencies: `.5.3.0`
  Acceptance: Adopt one backend-neutral outward descriptor policy for final-codeblock metadata or retain the
    explicit Lua fence under its exact future cross-backend owner; reconcile `.5.3` census wording with the newer
    full-backend admission policy; update the governing contract/decision/task/docs consistently before descriptor
    or census code changes.
  Verification: **PASS 2026-07-15.** The director accepted both audit recommendations. ADR `0041` defines an exact
    final-codeblock outward descriptor version 3 over fixed `params`/`arity` plus a sole final
    `parameter_kinds[name] = "codeblock"` entry; executable schema/checker and Lua emission are ordered first in
    `.5.3.1`, without generic callable-codeblock capability promotion or unrelated backend runtime work. Lua stays
    outside the four-backend all-pass census through `.5.3-.7`; `.8.4` alone expands it after native, corpus, CLI,
    generated, and generated-subset proof is complete. No source, descriptor, capability, status, or test
    expectation changed. Artifact review safely removed reproducible Rust/Dart caches while preserving tracked
    corpus/Git data and pre-existing nested-submodule work. Focused post-decision verification passes Lua 153/153
    on PUC Lua and LuaJIT, callable-signature 3/9/7, callable-codeblock 7/11/9/7/4/8, capability 64/0/0, mdBook,
    Knowledge Map, memory/doctrines, and whitespace. The immediately preceding `.5.3.0` canonical baseline remains
    CLI 61x2 plus Phase 0 `1..1031`; a decision-only slice does not rebuild the cleaned Rust target.
  Commit: `LUA-BACKEND-PARITY.5.3.0.1 - settle descriptor and census policy`

- ID: `LUA-BACKEND-PARITY.5.3.1`
  Status: `done`
  Goal: Admit exact Lua outward user-function descriptors.
  Dependencies: `.5.3.0.1`
  Acceptance: Extend the executable neutral contract/checker with exact final-codeblock-v3 fields before emitter
    code; consume the shared fixed-v1/variadic-v2/v3 descriptor union directly; preserve identical callable
    signatures/parameter kinds through staged and outward copies; remove the Lua fence without a Lua-only record
    shape; reject schema drift; and keep compiled descriptor metadata/order exact on both Lua ABIs. Do not promote
    generic callable-codeblock capability or force unrelated backend runtime work into this leaf.
  Verification: **PASS 2026-07-15.** The neutral outward contract now owns exact fixed-v1, variadic-v2, and
    final-codeblock-v3 record sequences, versions, parameter storage, compatibility aliases, and the sole-final-
    parameter codeblock policy; the portable checker rejects drift before emitter code. Lua removes both fences,
    selects the exact outward variant from typed registry state, preserves identical signature/parameter-kind
    staged copies, and retains exact source order/count/JSON round-trip. Perl's already-existing final-codeblock
    field set is outward v3 without internal/runtime change. PUC Lua and LuaJIT pass 153/153; signature/codeblock
    checkers pass 3/9/7 and 7/11/9/7/4/8; focused Perl suites pass 76; mdBook, Knowledge Map, memory/doctrines, and
    whitespace pass. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 616 seconds. Capability stays
    four-backend 64/0/0; generic callable codeblocks remain future; mutation testing was not run.
  Commit: `LUA-BACKEND-PARITY.5.3.1 - admit Lua function descriptors`

- ID: `LUA-BACKEND-PARITY.5.3.2`
  Status: `done`
  Goal: Propagate one caller-owned trace emitter through the complete native Lua parser pipeline.
  Dependencies: `.5.3.0.1`, `.5.3.1`
  Acceptance: One emitter identity crosses native resolution/loading, source frontend, validation, compilation,
    spec-owned function parser, function-shell projection, staged body resolve/load/compile/execute/stitch, engine
    creation, and runtime execution; ordered phase/rule events, quiet-default behavior, level filtering, sinks,
    error attribution, result neutrality, and no hidden emitter creation match the shared trace precedent.
  Verification: **PASS 2026-07-15.** A pre-change direct native TOOLBOX-style probe showed the caller emitter at
    zero events after load/compile and engine creation, with its first five events appearing only at runtime.
    `SpecLoadOptions.trace` now carries that same typed identity through balanced IO/frontend/compiler/function/
    staged/engine scopes and medium decisions; compiled/engine state retains nothing and no hidden factory runs.
    Exact ordered topics, route output, disabled/low/medium filtering, balanced attributed validation failure,
    descriptor/runtime neutrality, and invalid-emitter rejection pass. PUC Lua and LuaJIT pass 155/155 with status
    `native-full-pipeline-trace-v1`; capability remains four-backend 64/0/0. Canonical local CI passes both 61/61
    CLI environments and Phase 0 reaches true stop `1..1031` in 608 seconds. Mutation testing is not run.
  Commit: `LUA-BACKEND-PARITY.5.3.2 - propagate Lua full-pipeline trace`

- ID: `LUA-BACKEND-PARITY.5.3.3`
  Status: `done`
  Goal: Close Lua descriptor/full-pipeline-trace no-drift while preserving completion-time census admission.
  Dependencies: `.5.3.1`, `.5.3.2`
  Acceptance: Focused dual-ABI proof, neutral descriptor/trace fixtures and checkers, public API/status, docs/book,
    task/index/roadmaps/live/KM, and canonical gates agree; the census remains the exact four-backend all-pass
    surface and `.8.4` remains its sole Lua expansion owner; parent `.5.3` closes without claiming generated source,
    corpus execution, or the primary parser CLI.
  Verification: **PASS 2026-07-15.** Exact exports/options/status, the three-variant descriptor contract, both
    neutral trace capability definitions, focused descriptor and full-pipeline trace tests, root/Lua docs,
    mdBook API/status/handoff/compiler pages, task/index/roadmaps/live state, and Knowledge Map agree. No unowned
    seam or stale current-behavior claim remains. PUC Lua and LuaJIT pass 155/155; callable-signature/codeblock
    checks pass 3/9/7 and 7/11/9/7/4/8; native loading passes 14/9/4; coverage is 246/105+1/122; public aggregate
    surface is 58/27/0; capability remains 64/0/0. No Lua source, status, behavior, manifest row, or test count
    changes. Parent `.5.3` and `.5` close; corpus window `.6.1` activates; generated source, primary CLI, and census
    expansion remain `.8.1-.8.4`. Canonical local CI passes both 61/61 CLI environments and Phase 0 reaches true
    stop `1..1031` in 611 seconds. Mutation testing remains manual-only and was not run.
  Commit: `LUA-BACKEND-PARITY.5.3.3 - close Lua descriptor trace no drift`

- ID: `LUA-BACKEND-PARITY.6`
  Status: `active`
  Goal: Reach complete interpreter-corpus parity.
  Children: `.6.1`, `.6.2`, `.6.3`

- ID: `LUA-BACKEND-PARITY.6.1`
  Status: `done`
  Goal: Admit controlled/core and governed capability fixture windows.
  Children: `.6.1.0`, `.6.1.1`, `.6.1.2`, `.6.1.3`, `.6.1.4`
  Acceptance: Run ordered subsets, classify failures by mechanism, split repairs before code, and preserve exact
    expected values/endpoints rather than weakening fixtures.
  Verification: **PASS 2026-07-15.** Typed segment-kind repair closes the sole measured residual without changing
    its oracle; one reusable non-aborting executor then owns strict validation, selection, automatic native
    execution, and typed proof records. Permanent tests admit exact core offsets 0-39 at 40/40 and governed
    capability offsets 99-104 at 6/6 on both Lua ABIs. All outputs equal one wrapping of unchanged expected JSON;
    exact byte/character endpoints are 1 for the core prefix and `2,1,2,1,5,5` for the governed window. PUC Lua
    and LuaJIT pass 162/162. Public exports/status, CLI boundary, corpus data, coverage 246/105+1/122, and the
    four-backend 64/0/0 capability census do not change. Canonical local CI exits 0 with CLI 61x2 and Phase 0
    `1..1031` passing in 651 seconds (1,328.76 seconds total under concurrent load). `.6.2` owns offsets 40-98.
  Commit: `LUA-BACKEND-PARITY.6.1.4 - admit Lua capability corpus window`

- ID: `LUA-BACKEND-PARITY.6.1.0`
  Status: `done`
  Goal: Measure and dependency-split controlled/core and governed-capability corpus admission before code.
  Dependencies: `.5.3.3`
  Acceptance: Identify the exact ordered manifest windows owned by `.6.1`; execute them through the existing native
    parse/validate/compile/runtime APIs without changing source or fixtures; classify every failure by stage and
    mechanism; retrieve the canonical semantic contract for each residual; and create narrowly owned repair,
    executor, permanent-window, and closeout leaves before behavior work.
  Verification: **PASS 2026-07-15.** The owned windows are the 40-case core prefix at offsets 0-39 and the six
    governed capability fixtures at offsets 99-104; `.6.2` retains offsets 40-98 for advanced helpers, functions,
    recursion, and shipped specs. Disposable manifest-ordered native probes pass the same 45/46 exact cases on PUC
    Lua and LuaJIT. All six capability fixtures and 39/40 core fixtures pass; the sole residual is offset 20
    `terse_11_4_nested_mixed_value_path_assignment`, an output mismatch after successful parse, validation,
    compilation, match, and endpoint execution. Canonical `terse-nested-value-path-assignment` semantics require a
    numeric index segment into a hash to fail without mutation and return null. Lua currently discards the parsed
    segment kind at `assign_nested_access`, lets generic harray `write_index(...)` stringify numeric key `0`, and
    therefore adds an invalid `"0":"bad"` field and returns the mutated root. `.6.1.1` owns only that repair;
    `.6.1.2` owns the reusable library executor/result boundary; `.6.1.3` permanently admits offsets 0-39; and
    `.6.1.4` admits offsets 99-104 and closes no-drift. No Lua source, fixture, expected value, public status,
    capability row, or test count changes in this planning slice. Focused PUC Lua and LuaJIT suites remain
    155/155; mdBook, Knowledge Map, memory/task/doctrine, and whitespace checks pass; canonical local CI passes
    both 61/61 CLI environments and Phase 0 reaches true stop `1..1031` in 606 seconds. Mutation testing remains
    manual-only and was not run.
  Commit: `LUA-BACKEND-PARITY.6.1.0 - split Lua controlled corpus admission`

- ID: `LUA-BACKEND-PARITY.6.1.1`
  Status: `done`
  Goal: Preserve nested assignment segment kinds and reject wrong-shape transitions.
  Dependencies: `.6.1.0`
  Acceptance: Evaluate path segments and RHS in the governed order, require numeric index segments to traverse or
    write arrays and key segments to traverse or write hashes, preserve copy-on-write/no-autovivification behavior,
    return null without root mutation for missing/wrong-kind/gap paths, and pass the exact offset-20 oracle case on
    both Lua ABIs without weakening its expected JSON.
  Verification: **PASS 2026-07-15.** Lua now normalizes index-expression values to finite nonnegative integer
    positions, preserves key versus index segment identity for nested reads and writes, and rejects every
    wrong-container transition instead of routing numeric indices through harray stringification. Nested assignment
    evaluates all segment expressions in order, then the RHS, before root/path validation; it mutates only a deep
    copied root and stores that root only after the complete path succeeds. Focused proof locks valid dynamic
    numeric-string indices, hash/array traversal, append-at-length, wrong-kind reads/writes, missing intermediates,
    expression side effects on rejected paths, unchanged roots, null results, and stored false preservation. The
    exact manifest offset-20 source passes with unchanged wrapped expected JSON and byte/character cursor 1. PUC
    Lua and LuaJIT pass 157/157; disposable ordered offsets 0-39 plus 99-104 pass 46/46 on both ABIs. No fixture,
    expected value, parser grammar, public status, capability row, or later corpus boundary changes. Canonical
    local CI passes CLI 61x2 plus Phase 0 `1..1031` in 619 seconds. Mutation testing was not run.
  Commit: `LUA-BACKEND-PARITY.6.1.1 - preserve Lua nested path segment kinds`

- ID: `LUA-BACKEND-PARITY.6.1.2`
  Status: `done`
  Goal: Add reusable native library corpus execution and controlled proof records.
  Dependencies: `.6.1.1`
  Acceptance: Validate the strict manifest, execute selected fixtures through automatic spec-defined parsing,
    validation, compilation, source-identified engine construction, and runtime; compare exact one-level wrapped
    output structurally; retain actual value/output/match/endpoints/trace/diagnostic/failure stage; report every
    selected fixture without aborting; and prove controlled scalar/aggregate/dispatch/lifecycle/function/boundary/
    failure cases while keeping the validation-only corpus CLI unchanged.
  Verification: **PASS 2026-07-15.** Lua now validates the complete strict manifest before named or zero-based
    offset/limit selection, then automatically parses spec-defined functions, explicitly validates and compiles,
    constructs fixture-name/exact-path-identified engines, executes native runtime, and compares exact one-level
    wrapped typed JSON structurally. Typed fixture records retain copied expected/actual value/output, match,
    byte/character endpoints, per-fixture trace lines, typed runtime diagnostics, stable failure stage, and failure
    text. Parse/validate/compile/execute/match/compare/unexpected failures remain records so every selected fixture
    runs. Controlled scalar, nested aggregate, action/blind dispatch, lifecycle shape, top-level function,
    boundary/trace, parse/validation/runtime/mismatch/no-match, post-failure continuation, and strict selection
    proof passes 160/160 on PUC Lua and LuaJIT. The developer corpus CLI remains validation-only; public status,
    capability census, manifest/fixtures/expected JSON, and permanent corpus windows are unchanged. Canonical
    local CI passes CLI 61x2 plus Phase 0 `1..1031` in 623 seconds. Mutation testing was not run.
  Commit: `LUA-BACKEND-PARITY.6.1.2 - add Lua library corpus execution`

- ID: `LUA-BACKEND-PARITY.6.1.3`
  Status: `done`
  Goal: Permanently admit the ordered 40-case core corpus prefix.
  Dependencies: `.6.1.2`
  Acceptance: The exact manifest offsets 0-39 pass in order on PUC Lua and LuaJIT through the library executor;
    permanent assertions lock count, first/last names, zero failures, exact expected outputs, and unchanged
    endpoints without parser/runtime or fixture work outside routed failures.
  Verification: **PASS 2026-07-15.** One permanent library-executor test validates the full unchanged 105-case
    manifest, selects exact zero-based offsets 0-39, and locks 40 results in manifest order from
    `proof_edge_array_literal` through `terse_2_2_5_2_attached_switch_blocks`. Every result passes, matches, has
    byte and character endpoint 1, has no failure stage/text, and structurally equals exactly one wrapping of its
    own unchanged expected JSON. PUC Lua and LuaJIT pass 161/161 with 40/40 core, zero failures. No production
    source, manifest/fixture/expected JSON, public status, capability census, CLI, or offsets 40-104 changed.
    Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` passing in 640 seconds (1,316.33 seconds total
    under concurrent load). Mutation testing was not run.
  Commit: `LUA-BACKEND-PARITY.6.1.3 - admit Lua core corpus prefix`

- ID: `LUA-BACKEND-PARITY.6.1.4`
  Status: `done`
  Goal: Admit the six governed capability fixtures and close controlled/core no-drift.
  Dependencies: `.6.1.3`
  Acceptance: Exact manifest offsets 99-104 pass in order on both Lua ABIs; permanent assertions lock the six
    governed names, endpoints, and outputs; API/status/tests/root and Lua docs/mdBook/KM/task/live state agree;
    parent `.6.1` closes without changing capability-census membership; and `.6.2` activates for offsets 40-98.
  Verification: **PASS 2026-07-15.** One permanent library-executor test validates the complete unchanged
    105-case manifest and selects exact zero-based offsets 99-104. It locks these six ordered names:
    `capability_cursor_control_surface`, `capability_pure_helper_surface`,
    `capability_position_helper_surface`, `capability_control_marker_surface`,
    `capability_capture_anonymous_surface`, and `capability_capture_named_surface`. All six pass, match, retain no
    failure, and structurally equal exactly one wrapping of their unchanged expected JSON. Their exact byte and
    character endpoints are `2,1,2,1,5,5`. PUC Lua and LuaJIT pass 162/162. `init.lua` retains the exact corpus
    load/execute/result/query exports and public status `native-full-pipeline-trace-v1`; the primary CLI remains an
    explicit scaffold and the developer corpus CLI remains validation-only. Coverage is 246/105+1/122 with zero
    omissions, and ADR `0041` keeps capability at four-backend 64/0/0 until sole Lua admission `.8.4`. No
    production source, manifest/fixture/expected JSON, public status, CLI behavior, or census row changed.
    Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` passing in 651 seconds (1,328.76 seconds total
    under concurrent load). Mutation testing was not run.
  Commit: `LUA-BACKEND-PARITY.6.1.4 - admit Lua capability corpus window`

- ID: `LUA-BACKEND-PARITY.6.2`
  Status: `active`
  Goal: Admit shipped-spec, recursion, function, and advanced helper windows.
  Children: `.6.2.0`, `.6.2.1`, `.6.2.2`, `.6.2.3`, `.6.2.4`, `.6.2.5`, `.6.2.6`
  Acceptance: Expand monotonically through all named manifest families with exact failure inventories and no
    backend-local expected files. This includes exact `portmap_constant`, `simenv_multiline_value`,
    `ebnf_expression_rules`, `ebnf_logging_annotation`, `lib_reader_sattribute`, and `lib_reader_cattribute` proof
    after the helper/control/output owners on which those cases depend.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2.0`
  Status: `done`
  Goal: Measure and dependency-split exact advanced/shipped offsets 40-98 before behavior changes.
  Dependencies: `.6.1.4`
  Acceptance: Execute the exact 59-case window through the production library executor on PUC Lua and LuaJIT;
    retain exact names, stages, outputs, endpoints, trace evidence, and canonical Perl generated-source evidence;
    retrieve existing Knowledge Map mechanisms before diagnosis; and create narrowly owned repair, residual-
    measurement, permanent-admission, and no-drift leaves before changing runtime behavior or expected values.
  Verification: **PASS 2026-07-15.** Both Lua ABIs produce the same 50/59 exact result. The nine residuals are
    `terse_2_3_5_2_hash_receiver_value_chains` (compare), three HLink cases (execute), two EBNF cases (compare),
    `simenv_multiline_value` (execute), `ds_vhistory_version_entry` (compare), and `pplugin_empty` (compare).
    Production debug trace plus canonical generated Perl prove four current mechanisms: action-edge `call(child)`
    executes the already-selected child without marking/reusing the edge result and the fallback executes it a
    second time (all three HLink, both EBNF, and SimEnv); receiver-form `.copy()` discards its evaluated harray
    receiver (hash receiver fixture); `hash(flat_array(defs))` does not classify `flat_array` as a hash splice
    (PPlugin); and public `runtime_parse(...)` starts at byte zero instead of mirroring the Perl wrapper's leading
    blank/comment-line skip (history). `.6.2.1-.4` own those repairs, `.6.2.5` remeasures and splits any newly
    exposed residual before further behavior, and `.6.2.6` owns permanent exact 59/59 admission/no-drift. This
    planning slice changes no production source, test, corpus data, expected JSON, public status/CLI, or capability
    census. PUC Lua and LuaJIT remain 162/162; mdBook, Knowledge Map, memory/doctrine, and canonical local CI pass.
    The canonical gate includes CLI 61/61 in default and POSIX environments plus Phase 0 true reach `1..1031` in
    629 seconds. Mutation testing remains manual-only and was not run.
  Commit: `LUA-BACKEND-PARITY.6.2.0 - split Lua advanced corpus residuals`

- ID: `LUA-BACKEND-PARITY.6.2.1`
  Status: `active`
  Goal: Reuse the current action-edge child result for `call(child)` exactly once.
  Dependencies: `.6.2.0`
  Acceptance: When `call(target)` names the current action edge's compiled target, dispatch through that edge state,
    cache one child result, refresh `retv`, and prevent fallback re-execution for self-recursive and non-self edges;
    unrelated named calls retain normal execution. Focused tests lock call count, cursor, value, recursion, and
    passive-child behavior on both Lua ABIs; the six currently affected corpus cases are re-executed unchanged and
    the full offsets 40-98 window is remeasured to route any successor mechanism.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2.2`
  Status: `pending`
  Goal: Preserve evaluated values through receiver-form `.copy()` continuation.
  Dependencies: `.6.2.1`
  Acceptance: Generic receiver `copy()` deep-copies its current value exactly once, while function-form
    `copy(value)`, missing/undefined values, nested isolation, and subsequent array/harray/string-compatible
    continuations retain their governed behavior. The unchanged hash-receiver corpus fixture returns its expected
    sixth value `2` on both Lua ABIs.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2.3`
  Status: `pending`
  Goal: Splice `flat_array(...)` key/value tokens into hash construction.
  Dependencies: `.6.2.2`
  Acceptance: `hash(flat_array(values))` / equivalent harray construction consumes the flattened array as ordered
    key/value tokens rather than stringifying the Lua table as one key; empty input yields an empty harray, nested
    values remain copied, and ordinary non-splice arguments retain their existing boundaries. The unchanged
    `pplugin_empty` fixture returns `[{}]` on both Lua ABIs.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2.4`
  Status: `pending`
  Goal: Mirror the Perl public parser's leading blank/comment-line cursor initialization.
  Dependencies: `.6.2.3`
  Acceptance: Public in-memory `runtime_parse(...)` initializes the top-rule cursor after leading blank and comment
    lines exactly as the Perl wrapper does, while ordinary indexed-variable reads and nonleading content remain
    unchanged. Focused entry-boundary tests and the unchanged `ds_vhistory_version_entry` oracle pass on both Lua
    ABIs without weakening expected output.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2.5`
  Status: `pending`
  Goal: Remeasure offsets 40-98 and dependency-split every successor residual before further behavior work.
  Dependencies: `.6.2.4`
  Acceptance: Execute the exact 59-case window on both Lua ABIs after the four measured repairs; classify every
    remaining failure with production trace, Knowledge Map retrieval, and canonical toolbox/generated-source
    evidence; create mechanism-sized child leaves before changing behavior; or record a zero-residual boundary and
    activate permanent admission when all 59 pass unchanged.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-BACKEND-PARITY.6.2.6`
  Status: `pending`
  Goal: Permanently admit exact advanced/shipped offsets 40-98 and close parent no-drift.
  Dependencies: `.6.2.5`
  Acceptance: One recurring production-library test locks all 59 names in manifest order, exact one-level wrapped
    expected outputs, match/endpoints, 59 passes, and zero failures on PUC Lua and LuaJIT; docs/KM/task/roadmap/
    architecture/live state agree; parent `.6.2` closes and full-manifest `.6.3` activates without premature CLI,
    generated-source, public-status, or capability-census promotion.
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
  Acceptance: As the sole Lua census-admission owner under ADR `0041`, expand the capability manifest all-pass and
    retire the Lua-owned
    `future.variadic_user_functions` entry only after native and generated callable proofs pass; PUC Lua primary and
    LuaJIT compatibility policies are honest; roadmap/book/KM/live docs/local CI/cleanup pass; no outstanding Lua
    behavior is hidden as a limitation.
  Verification: `pending`
  Commit: `pending`

## Current frontier

Global delegation note: selector-free uniform bindings and exact selector rejection remain part of the Lua gate.
Numeric helper parent `.4.3.3` and complete non-callback array parent `.4.3.4` pass 99/99 on PUC Lua and LuaJIT.
All 34 ordinary array helper names and six numeric terminals are routed. Cross-cutting caveats remain
`FUTURE-PARITY-BACKLOG.5`; harray audit `.4.3.5.0` split five
mechanisms plus closeout. Construction/splicing, deterministic views/membership, and copied transforms/receiver
chains and named mutation/direct assignment close all 13 ordinary harray names at 103/103 on PUC Lua and LuaJIT.
Codeblock/control/tree-callback parent `.4.3.6` closes at 114/114 with later function/callable obligations routed
explicitly. Unicode input/live-cursor views and controls `.4.3.7.1` pass 115/115, all 16 anonymous capture calls
`.4.3.7.2` pass 116/116, and non-consuming earliest-boundary `.4.3.7.5` passes 117/117 on PUC Lua and LuaJIT. Complete
named marks now have an exact neutral contract and aligned Perl/Rust execution through `.17.1`; Dart `.17.2` and
Julia `.17.3` match it through native/generated/CLI routes with complete backend and canonical proof. Lua `.17.4`
now consumes the unchanged contract through native/serialized routes at 119/119 on PUC Lua and LuaJIT. Final admission
`.17.5` closes at 246 shared names with all 122 public Perl contracts independently checked. `.4.3.7.3` now
extends that same store and dispatcher across the governed named-span and bridge family at 120/120 on PUC Lua and
LuaJIT. Placement-sensitive split/mark rule members execute at their owning slots at 121/121. Exact source-derived
closeout finds 62/62 current calls in contracts, runtime dispatch, and focused execution sources, plus four exact
marker spellings. Parent `.4.3.7` is closed. Caller-owned diagnostic events now pass 122/122 on both Lua ABIs.
The exact `.4.3.9.0` audit partitions the pre-repair 246 names into 230 handled, thirteen intentional non-function
owners, and missing `and`/`or`/`not`; `.1` repairs those logical values. Permanent `.4.3.9.2` now measures 233
runtime-owned plus the same thirteen non-function forms, focuses direct `call(rule)`, publishes
`runtime-helper-value-control`, and closes parent `.4.3` at 125/125 on both ABIs. Planning-only `.4.4.0` separates structured runtime failures, trace controls/sinks, runtime
instrumentation, and closeout; it retains full frontend/compiler/function/staged propagation under `.5.3` after
general staged-function and native-loading prerequisites. Structured runtime diagnostics pass 126/126; native
trace controls/sinks pass 128/128 and runtime instrumentation `.4.4.3` passes 129/129 on both ABIs. No-drift
`.4.4.4` closes the scoped parent without behavior changes. Staged-function parent `.5.1` is now closed and native
loading `.5.2` is active; full native-pipeline trace remains `.5.3`. Planning `.5.1.0` separates staged body dispatch, fixed-v1 execution,
variadic metadata/runtime, contextual-codeblock metadata/runtime, and closeout. Minimal staged dispatch `.5.1.1`
passes 130/130. Fixed-v1 runtime `.5.1.2` passes 133/133. Exact variadic-v2 state `.5.1.3.1` passes 136/136, and
fresh rest-array runtime `.5.1.3.2` passes 139/139. Final-only contextual metadata `.5.1.4.1` then preserves the
exact declaration/staged/registry contract and normalizes both contextual spellings at 142/142 with status
`runtime-user-functions-contextual-codeblock-metadata-v1`. Contextual execution `.5.1.4.2` runs zero-positional
blocks in the current isolated function frame with restoration, static precedence, chainable results, and typed
failures at 146/146 with status `runtime-user-functions-contextual-codeblock-v1`. No-drift `.5.1.5` then confirms
the public API/status/tests/docs/KM and all later fences, closes parent `.5.1`
without behavior change, and activates native loading `.5.2`. Planning-only `.5.2.0` audits ADR `0026`, the
14/9/4 executable contract, all current Lua seams, and the completed backend loaders. A direct native probe proves
the current Lua runtime already parses, validates, compiles, and executes `specs/user_function_definition.spec`
to produce the exact typed node for real `fn` source. The dependency order is therefore portable resolve/load
`.5.2.1`, automatic spec-defined function-shell parsing `.5.2.2`, full compile/engine composition `.5.2.3`, and
no-drift `.5.2.4`. Portable resolution/loading `.5.2.1` exposes typed request/options/resolved/loaded/error values,
uses a narrow native filesystem inspector for deterministic regular-file classification, reads bytes in process,
and preserves strict UTF-8 text. Automatic function parsing `.5.2.2` now resolves the bundled owning grammar by
one exact module-relative path, compiles it once, executes it in process, and feeds only typed output through the
existing Unicode projector/body dispatcher. Both Lua ABIs pass 151/151 with status
`native-spec-defined-functions-v1`. Full composition `.5.2.3` now returns typed loaded/compiled state, maps the
three source stages, creates name/path-identified engines, and executes loaded top-level functions at 153/153 on
both ABIs with status `native-spec-pipeline-v1`. Native-loading no-drift `.5.2.4` confirms exact source/API/test/
public-doc/KM agreement, closes parent `.5.2` without behavior change, and activates descriptors/full trace `.5.3`.
Planning `.5.3.0` audits the exact fixed-v1/variadic-v2 schemas, final-codeblock metadata/fence, trace seams,
completed Dart/Julia precedent, capability policy, and history before code. Decision `.5.3.0.1` adopts ADR `0041`:
an exact neutral final-codeblock-v3 outward record extends fixed `params`/`arity` with final-only
`parameter_kinds`, while Lua remains outside the all-pass census until sole admission owner `.8.4`. Descriptor
contract/emission `.5.3.1` now locks and emits all three variants on both Lua ABIs, aligns Perl's existing v3
projection, and leaves the census unchanged. One-emitter propagation `.5.3.2` now passes ordered, balanced
construction/runtime trace at 155/155 on both ABIs with no emitter retained in compiled or engine state;
census-preserving no-drift `.5.3.3` confirms exact source/API/test/contract/book/KM agreement, closes parents
`.5.3`/`.5`, and activates corpus window `.6.1` without changing the four-backend census.

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
| 54 | `LUA-BACKEND-PARITY.4.3.5.2` | `done` | Lexical keys, key-ordered copied values, count, membership, and receiver bridges pass 101/101. |
| 55 | `LUA-BACKEND-PARITY.4.3.5.3` | `done` | Revalidated copied transforms and receiver chains pass 102/102. |
| 56 | `LUA-BACKEND-PARITY.4.3.5.3.0` | `done` | Bare base/overlay and pure transform contracts revalidated after uniform binding. |
| 57 | `LUA-BACKEND-PARITY.4.3.5.3.1` | `done` | Copied merge/set/rename/drop/pick and receiver flow pass 102/102. |
| 58 | `LUA-BACKEND-PARITY.4.3.5.4` | `done` | Named set-key/direct mutation share one binding seam and pass 103/103. |
| 59 | `LUA-BACKEND-PARITY.4.3.5.5` | `done` | Complete 13-name ordinary harray/public surface closes at 103/103. |
| 60 | `LUA-BACKEND-PARITY.4.3.6.0` | `done` | Parser-ahead block/control/callback work is split from user-function and callable-value owners. |
| 61 | `LUA-BACKEND-PARITY.4.3.6.1` | `done` | Eager last values, local return, mutation, harray precedence, and receivers pass 104/104. |
| 62 | `LUA-BACKEND-PARITY.4.3.6.2` | `done` | Lazy selected payloads, one-time switch subjects, literal labels, and fluent returns pass 105/105. |
| 63 | `LUA-BACKEND-PARITY.4.3.6.3.1` | `done` | Nested attached/marker if-family controls and typed malformed diagnostics pass 106/106. |
| 64 | `LUA-BACKEND-PARITY.4.3.6.3.2` | `done` | One-time attached/marker switch selection and typed malformed diagnostics pass 107/107. |
| 65 | `LUA-BACKEND-PARITY.4.3.6.3.3` | `done` | State-visible loops, local/action return, next, and typed exact-limit safety pass 108/108. |
| 66 | `LUA-BACKEND-PARITY.4.3.6.4` | `done` | Metadata-governed helper/receiver `with`, copied scope, restoration, chaining, and typed failures pass 112/112. |
| 67 | `LUA-BACKEND-PARITY.4.3.6.5.1.0` | `done` | Root-cause and split callback append scope repair from Lua harray traversal. |
| 68 | `LUA-BACKEND-PARITY.4.3.6.5.1.1` | `done` | Valid authored value lists outrank optional-scope fallback; phase0 1,031 passes. |
| 69 | `LUA-BACKEND-PARITY.4.3.6.5.1.2` | `done` | Sorted scoped copied Lua harray walk/map/reduce pass 113/113 on both ABIs. |
| 70 | `LUA-BACKEND-PARITY.4.3.6.5.2` | `done` | Root-kind array traversal and zero-based scoped callbacks pass 114/114 on both ABIs. |
| 71 | `LUA-BACKEND-PARITY.4.3.6.6` | `done` | Closed block/control/callback no-drift and routed later function/callable obligations exactly. |
| 72 | `LUA-BACKEND-PARITY.4.3.7` | `done` | Complete capture/mark/input/cursor family closes at exact 62-call/four-marker no-drift. |
| 73 | `LUA-BACKEND-PARITY.4.3.7.0` | `done` | Split six runtime mechanisms plus no-drift and exposed the symmetric documented-mark inventory gap. |
| 74 | `LUA-BACKEND-PARITY.4.3.7.1` | `done` | Unicode input/live-cursor views and explicit save/restore/rewind controls pass 115/115 on both ABIs. |
| 75 | `LUA-BACKEND-PARITY.4.3.7.2` | `done` | All 16 anonymous capture calls share byte-safe state and pass 116/116 on both ABIs. |
| 76 | `LUA-BACKEND-PARITY.4.3.7.5` | `done` | Non-consuming earliest usable boundary and EOF/no-op cases pass 117/117 on both ABIs. |
| 77 | `LUA-BACKEND-PARITY.4.3.7.3` | `done` | Governed named writers, spans, bridges, overloads, and valid-only mutation pass 120/120 on PUC Lua and LuaJIT. |
| 78 | `LUA-BACKEND-PARITY.4.3.7.4` | `done` | Typed split/named-mark slot events execute after their matched actions at 121/121 on both ABIs. |
| 79 | `LUA-BACKEND-PARITY.4.3.7.6` | `done` | Closed exact 62-call/four-marker native capture/cursor no-drift at 121/121 on both ABIs. |
| 80 | `LUA-BACKEND-PARITY.4.3.8` | `done` | Typed caller-owned diagnostic events, quiet default, Unicode/order, parse neutrality, and immediate exit pass 122/122. |
| 81 | `LUA-BACKEND-PARITY.4.3.9.0` | `done` | Exact 230 handled / 16 unsupported audit isolates thirteen intentional owners and three logical gaps. |
| 82 | `LUA-BACKEND-PARITY.4.3.9.1` | `done` | Eager ordered logical values and false/false/true empty calls pass 123/123 on both ABIs. |
| 83 | `LUA-BACKEND-PARITY.4.3.9.2` | `done` | Exact 233+13 ownership, direct-call proof, corrected status/audit note, and parent closure pass 125/125. |
| 84 | `LUA-BACKEND-PARITY.4.4` | `done` | Structured diagnostics, controls/sinks, runtime events, and no-drift close at 129/129. |
| 85 | `LUA-BACKEND-PARITY.4.4.0` | `done` | Split diagnostics, controls/sinks, runtime events, closeout, and later full-pipeline ownership by dependency. |
| 86 | `LUA-BACKEND-PARITY.4.4.1` | `done` | Neutral typed diagnostics, deepest-rule/source attribution, JSON, and success preservation pass 126/126. |
| 87 | `LUA-BACKEND-PARITY.4.4.2` | `done` | Typed levels/config/events, environment controls, three sinks, reset/append, and parse-scope neutrality pass 128/128. |
| 88 | `LUA-BACKEND-PARITY.4.4.3` | `done` | Exact runtime rule/regex/dispatch/recursion/lifecycle/cursor/boundary/mark-capture events pass 129/129. |
| 89 | `LUA-BACKEND-PARITY.4.4.4` | `done` | Exact API/source/test/public-doc no-drift closes parent `.4.4`; full pipeline stays `.5.3`. |
| 90 | `LUA-BACKEND-PARITY.5` | `done` | Staged functions, native loading, exact descriptors, and full-pipeline trace close at 155/155. |
| 91 | `LUA-BACKEND-PARITY.5.1` | `done` | Staged registry plus fixed-v1/variadic-v2/contextual codeblock runtime closes at 146/146. |
| 92 | `LUA-BACKEND-PARITY.5.1.0` | `done` | Split staged dispatch, fixed execution, variadic metadata/runtime, contextual-codeblock metadata/runtime, and no-drift. |
| 93 | `LUA-BACKEND-PARITY.5.1.1` | `done` | Deterministic `actionir-body.spec` provider, stable queue, governed identity, and immutable stitching pass 130/130. |
| 94 | `LUA-BACKEND-PARITY.5.1.2` | `done` | Registry-first fixed-v1 calls, fresh stores, local returns, composition, and typed fences pass 133/133. |
| 95 | `LUA-BACKEND-PARITY.5.1.3.1` | `done` | Exact fixed-v1/variadic-v2 state and minimum/unbounded resolution pass 136/136. |
| 96 | `LUA-BACKEND-PARITY.5.1.3.2` | `done` | Fresh typed rest arrays and the unchanged neutral fixture pass 139/139. |
| 97 | `LUA-BACKEND-PARITY.5.1.4.1` | `done` | Exact final metadata and contextual normalization pass 142/142 on both Lua ABIs. |
| 98 | `LUA-BACKEND-PARITY.5.1.4.2` | `done` | Dynamic contextual execution, restoration, precedence, chainable values, and typed failures pass 146/146. |
| 99 | `LUA-BACKEND-PARITY.5.1.5` | `done` | Public/API/test/docs/KM no-drift closes parent `.5.1` without behavior change. |
| 100 | `LUA-BACKEND-PARITY.5.2` | `done` | Portable native named/path resolution and in-memory composition close at 153/153. |
| 101 | `LUA-BACKEND-PARITY.5.2.0` | `done` | Split portable resolve/load, spec-defined function parsing, full composition, and no-drift by dependency. |
| 102 | `LUA-BACKEND-PARITY.5.2.1` | `done` | Typed deterministic resolve/load consumes all 14/9/4 cases at 149/149 on both ABIs. |
| 103 | `LUA-BACKEND-PARITY.5.2.2` | `done` | Cached spec-owned function parsing composes Unicode projection/body dispatch at 151/151 with no raw scanner. |
| 104 | `LUA-BACKEND-PARITY.5.2.3` | `done` | Typed full composition and source-identified runtime engines pass 153/153 on both ABIs. |
| 105 | `LUA-BACKEND-PARITY.5.2.4` | `done` | Exact source/API/test/public-doc/KM no-drift closes parent `.5.2`. |
| 106 | `LUA-BACKEND-PARITY.5.3` | `done` | Exact outward descriptors and one-emitter full-pipeline trace close without early census admission. |
| 107 | `LUA-BACKEND-PARITY.5.3.0` | `done` | Audit finds two neutral-policy dependencies and splits decision/descriptor/trace/admission work. |
| 108 | `LUA-BACKEND-PARITY.5.3.0.1` | `done` | ADR `0041` adopts final-codeblock-v3 descriptors and completion-time Lua census admission. |
| 109 | `LUA-BACKEND-PARITY.5.3.1` | `done` | Exact shared v1/v2/v3 descriptors pass both Lua ABIs; existing Perl final-codeblock projection is v3. |
| 110 | `LUA-BACKEND-PARITY.5.3.2` | `done` | One caller-owned emitter crosses IO/frontend/compiler/function/staged/engine/runtime at 155/155 on both ABIs. |
| 111 | `LUA-BACKEND-PARITY.5.3.3` | `done` | Exact no-drift closes parents `.5.3`/`.5`; `.8.4` remains sole census admission. |
| 112 | `LUA-BACKEND-PARITY.6` | `active` | Reach complete interpreter-corpus parity. |
| 113 | `LUA-BACKEND-PARITY.6.1` | `done` | Exact core 40/40 and capability 6/6 windows pass permanently on both ABIs. |
| 114 | `LUA-BACKEND-PARITY.6.1.0` | `done` | Both ABIs measure 45/46 and split the sole nested-assignment residual before code. |
| 115 | `LUA-BACKEND-PARITY.6.1.1` | `done` | Typed nested paths close offset 20 and both owned windows at 46/46 per ABI. |
| 116 | `LUA-BACKEND-PARITY.6.1.2` | `done` | Typed selected execution/result records and controlled continuation proof pass 160/160 per ABI. |
| 117 | `LUA-BACKEND-PARITY.6.1.3` | `done` | Permanent ordered core offsets 0-39 pass 40/40 at endpoint 1 on both ABIs. |
| 118 | `LUA-BACKEND-PARITY.6.1.4` | `done` | Permanent offsets 99-104 pass 6/6 with exact names, outputs, and endpoints on both ABIs. |
| 119 | `LUA-BACKEND-PARITY.6.2` | `active` | Measure offsets 40-98 and split every residual by stage and mechanism before behavior work. |

### `LUA-BACKEND-PARITY.5.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Parent `.5.3` combines descriptor, full-pipeline trace, and capability admission,
  but its exact neutral descriptor variants, emitter seams, and census timing had not been re-audited after the
  later callable-codeblock and four-backend census decisions.
- [x] **ROOT CAUSE (WHY + WHERE)** — Fixed-v1 and variadic-v2 have exact outward schemas; final-codeblock
  `parameter_kinds` has no neutral outward record shape despite ADR `0032` preservation intent. Separately, the
  original `.5.3` immediate-census sentence predates README commit `4a2adda9`, which keeps Lua outside until its
  dedicated parity tree completes. Runtime accepts an emitter, while every preceding native phase currently does
  not.
- [x] **FIX** — Record the facts in the Knowledge Map and split director decision `.5.3.0.1`, descriptor
  implementation `.5.3.1`, one-emitter propagation `.5.3.2`, and no-drift/selected admission `.5.3.3` before
  changing behavior.
- [x] **ADDRESSED (verified)** — Every descriptor/schema/fence, API propagation seam, completed-backend precedent,
  capability owner, and conflicting-history source has one durable pointer; no implementation leaf can silently
  invent a Lua-only contract or supersede census policy.
- [x] **NO REGRESSION** — Planning changes no source, behavior, public status, capability row, descriptor shape,
  test expectation, or mutation policy. Focused Lua and neutral contract gates, canonical local CI, mdBook,
  Knowledge Map, memory, doctrines, and cleanup pass. PUC Lua/LuaJIT remain 153/153; signature/codeblock checkers
  remain 3/9/7 and 7/11/9/7/4/8; capability remains 64/0/0; canonical CI includes CLI 61x2 and Phase 0 `1..1031`
  in 605 seconds. Mutation testing was not run.
- [x] **LOCKSTEP** — Roadmaps, architecture/live state, root/Lua docs, mdBook trace/handoff/status pages, task/index,
  Knowledge Map, changes/notes, and bounded memory identify `.5.3.0.1` as the exact resume point.

### `LUA-BACKEND-PARITY.5.3.0.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.5.3.0` proved the outward union lacked a final-codeblock record and that early Lua
  census expansion conflicted with the later full-backend admission policy.
- [x] **ROOT CAUSE (WHY + WHERE)** — Optional `parameter_kinds` on fixed-v1 would weaken its exact schema, while
  partial Lua census rows would turn an admitted-backend conformance surface into a progress ledger.
- [x] **FIX** — ADR `0041` adds an exact version-3 record over fixed `params`/`arity` plus final-only
  `parameter_kinds`, and reserves census expansion exclusively for all-pass handoff `.8.4`.
- [x] **ADDRESSED (verified)** — `.5.3.1` must update the neutral executable schema/checker before Lua emission;
  `.5.3.3` preserves current census membership; `.8.4` alone expands it after every later Lua dependency passes.
- [x] **NO REGRESSION** — No source, descriptor, capability manifest, status, or test expectation changes. Safe
  artifact cleanup removes only reproducible `rust/target` and `dart/.dart_tool`; tracked corpus/Git data and
  pre-existing nested-submodule work remain untouched.
- [x] **LOCKSTEP** — ADR/index, task/index, roadmaps, architecture/live docs, root/Lua docs, mdBook, Knowledge Map,
  changes/notes, and bounded memory record the accepted choices and point to descriptor contract/emission `.5.3.1`.

### `LUA-BACKEND-PARITY.5.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — A direct `LinkedSpec::Get(..., return_descriptor => 1)` TOOLBOX probe against
  `fn apply(value, callback: codeblock)` reported `got_version=1 expected_version=3`; Lua's registry emitter at
  `lua/src/linkedspec/user_function_registry.lua` separately rejected variadic and final-codeblock records behind
  typed `*_descriptor_pending` fences.
- [x] **ROOT CAUSE (WHY + WHERE)** — `outward_descriptor_contract.json` exposed only a fixed-v1 field list while
  `callable_signature_contract.json` duplicated variadic-v2 fields and neither executable source defined v3.
  Perl already projected the complete v3 field set but inherited internal fixed version 1; Lua had exact typed
  v2/v3 metadata but no shared record shape it could emit.
- [x] **FIX** — Add one checked `function_record_variants` union, source callable-signature record placement from
  it, project Lua v1/v2/v3 by typed metadata, and relabel only Perl's outward final-codeblock projection as v3.
- [x] **ADDRESSED (verified)** — `python3 tools/check_callable_signature_contract.py` passes 3/9/7 and rejects
  schema/order/version/storage/policy drift; Lua exact-field/version/staged-copy/order/count tests pass 153/153 on
  PUC Lua and LuaJIT; the same Perl TOOLBOX probe now reports version 3 and exact v3 fields.
- [x] **NO REGRESSION** — `python3 tools/check_callable_codeblock_contract.py` passes 7/11/9/7/4/8; focused Perl
  callable suites pass 76; capability remains 64/0/0; canonical `PERL5LIB= bash tools/run_ci_local.sh` passes both
  61/61 CLI environments and Phase 0 reaches true stop `1..1031` in 616 seconds with no failures. Mutation testing
  was not run because it remains milestone/manual-only.
- [x] **LOCKSTEP** — Contract/readme, root/Lua docs, roadmaps, architecture/live/change/notes, task/index, mdBook
  descriptor/status/loading/handoff/grammar chapters, Knowledge Map facts, and bounded memory all identify exact
  descriptor v1/v2/v3 behavior and activate one-emitter trace `.5.3.2` without changing census membership.

### `LUA-BACKEND-PARITY.5.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — A direct public native probe created one debug emitter, put it in
  `spec_load_options(...)`, then loaded/compiled and created an engine. The emitter had exactly zero events after
  both construction boundaries; only explicit `runtime_parse(..., { trace = emitter })` produced five events,
  beginning at `lua_runtime:parse`.
- [x] **ROOT CAUSE (WHY + WHERE)** — `spec_loader`, `spec_parser`, `spec_validator`, `compiled_spec`, the
  spec-owned function parser/shell, user-function registry, staged registry, and engine construction accepted no
  optional emitter and therefore could neither propagate caller identity nor report their phase boundaries.
- [x] **FIX** — Add optional typed `trace` injection to the existing APIs, one internal balanced scope runner that
  rethrows original errors, high `lua_io`/`lua_frontend`/`lua_compiler`/`lua_staged`/engine scopes, and medium
  candidate/cache/definition/rule/job/stitch decisions. Pass the same emitter explicitly; never retain it in
  compiled or engine state and never construct a hidden one.
- [x] **ADDRESSED (verified)** — One routed emitter records the exact ordered path from load/resolve through
  function-parser execution, shell/staged phases, validation/compile/registry, engine creation, and final runtime
  rule events. A patched factory counter stays zero; all emitted success and validation-failure scopes balance.
- [x] **NO REGRESSION** — Disabled and low emitters remain empty, medium admits decisions but filters high scopes,
  traced/untraced compiled descriptor and runtime JSON are exact, and typed `SpecPipelineError` JSON/stage remain
  unchanged. `bash tools/run_lua_local.sh` passes PUC Lua 155/155 and LuaJIT 155/155; capability remains 64/0/0.
  Canonical local CI passes both 61/61 CLI environments and Phase 0 reaches true stop `1..1031` in 608 seconds.
  Mutation testing remains manual-only and was not run.
- [x] **LOCKSTEP** — Lua/root API and status docs, native-loading/trace/status/handoff mdBook pages, task/index,
  roadmaps, architecture/live/change/notes, Knowledge Map, and bounded memory record
  `native-full-pipeline-trace-v1`, keep `.8.4` as sole census expansion owner, and activate `.5.3.3`.

### `LUA-BACKEND-PARITY.5.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Descriptor and full-pipeline trace behavior was complete, but parent `.5.3` could
  not close until exact exports/status, focused dual-ABI tests, neutral contracts, public docs, and the deliberately
  unchanged capability census were inventoried together.
- [x] **ROOT CAUSE (WHY + WHERE)** — This boundary crosses `init.lua`, every trace-aware pipeline owner, the
  three-variant outward descriptor contract/checker, two neutral trace capability definitions, focused Lua tests,
  public API/book surfaces, and ADR `0041` census policy; any stale surface could overstate or hide admission.
- [x] **FIX** — Inventory those exact owners, align only current frontier/closure text, record the durable no-drift
  conclusion, close parents `.5.3`/`.5`, and activate corpus window `.6.1` without changing source or the manifest.
- [x] **ADDRESSED (verified)** — Public exports/options and status, exact v1/v2/v3 descriptors, one-emitter
  construction/runtime topics, sinks/filters/failures/results, and every public task/book/KM surface agree. No
  hidden emitter construction, retained compiled/engine trace state, unowned seam, or stale current claim remains.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 155/155; signature/codeblock checks pass 3/9/7 and
  7/11/9/7/4/8; native loading is 14/9/4; coverage is 246/105+1/122; public aggregate surface is 58/27/0; capability
  remains four-backend 64/0/0. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 611 seconds. No Lua
  source/status/behavior/test/manifest change; mutation testing was not run.
- [x] **LOCKSTEP** — Root/Lua docs, both roadmaps, architecture/live/change/notes, task/index, mdBook API/trace/
  status/handoff/compiler pages, Knowledge Map, and bounded memory close `.5.3`/`.5`, activate `.6.1`, and retain
  generated source, primary CLI, and census expansion under `.8.1-.8.4`.

### `LUA-BACKEND-PARITY.6.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Disposable ordered execution of the 40-case core prefix and six governed capability
  fixtures passes 45/46 identically on PUC Lua and LuaJIT. Offset 20 alone returns a mutated hash with numeric key
  `"0"` where the oracle requires unchanged state and null.
- [x] **ROOT CAUSE (WHY + WHERE)** — The parser preserves `key` versus `index` path segments, but
  `interpreter.lua`'s `assign_nested_access` evaluates each to a bare value and delegates to kind-generic
  `read_index(...)` / `write_index(...)`. A numeric final segment against a harray is therefore stringified rather
  than rejected as a wrong-kind transition.
- [x] **FIX** — Change no behavior in planning. Split segment-kind repair `.6.1.1`, library executor/result records
  `.6.1.2`, exact core offsets 0-39 `.6.1.3`, and governed capability offsets 99-104 plus no-drift `.6.1.4`.
- [x] **ADDRESSED (verified)** — Every owned fixture is accounted for by exact offset/name/stage; `.6.2` retains
  offsets 40-98; the sole residual points to the already-governed nested-write contract and one source mechanism;
  no implementation leaf can weaken expected JSON or silently absorb unrelated advanced/shipped work.
- [x] **NO REGRESSION** — Planning changes only task/docs/Knowledge Map state. Both disposable ABI probes reproduce
  45/46 with the same sole output mismatch; focused Lua remains 155/155 on each ABI; canonical CI passes CLI 61x2
  plus Phase 0 `1..1031` in 606 seconds. No source, public status, test count, fixture, expected value, capability
  row, or mutation policy changes; mutation testing was not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmaps, architecture/live/change/notes, task/index, mdBook status/API/handoff,
  Knowledge Map, and bounded memory record the exact windows, 45/46 boundary, mechanism, ordered owners, and active
  segment-kind repair `.6.1.1`.

### `LUA-BACKEND-PARITY.6.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Exact offset 20 returned a hash with an invalid stringified numeric key `"0"`, and
  the owned offsets 0-39 plus 99-104 passed only 45/46 on both PUC Lua and LuaJIT.
- [x] **ROOT CAUSE (WHY + WHERE)** — Parsing retained `key` versus `index`, but nested access reduced both to bare
  values before kind-generic reads/writes. Assignment also validated the root/path before completing the governed
  evaluation order, so a repair had to preserve both segment provenance and side-effect ordering.
- [x] **FIX** — `runtime_access_index(...)` normalizes finite nonnegative indices; typed segment checks require keys
  to traverse harrays and indices to traverse arrays. Nested assignments evaluate all segments, then RHS, mutate a
  deep copy, and replace the root only after the whole path succeeds.
- [x] **ADDRESSED (verified)** — Focused tests lock dynamic numeric-string indices, valid hash/array paths,
  append-at-length, wrong-kind reads/writes, missing intermediates, rejected-path expression side effects,
  unchanged roots, null results, false preservation, and the exact offset-20 source/cursor/wrapped output.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 157/157; disposable ordered windows pass 46/46 on both ABIs. No
  fixture, expected value, parser grammar, public status, capability row, or corpus ownership changes. Canonical
  local CI passes CLI 61x2 plus Phase 0 `1..1031` in 619 seconds; mutation testing was not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmaps, architecture/live/change/notes, task/index, mdBook status/API/handoff,
  Knowledge Map, and bounded memory record repair closure and activate reusable library executor `.6.1.2`.

### `LUA-BACKEND-PARITY.6.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Strict Lua corpus IO existed, but callers had no reusable manifest-to-runtime
  executor, selection boundary, structural comparison, or durable per-fixture evidence; the developer command was
  intentionally validation-only.
- [x] **ROOT CAUSE (WHY + WHERE)** — `corpus.lua` stopped after loading fixtures even though automatic function
  parsing, validation, compilation, source identity, runtime diagnostics, and trace were already independent
  native APIs. Without one library owner, permanent corpus windows would duplicate orchestration and abort on the
  first fixture error.
- [x] **FIX** — Add typed execution/fixture records, full-validation-before-selection, named or offset/limit
  selection, automatic parse→validate→compile→identified-engine→runtime composition, exact wrapped typed-JSON
  comparison, copied observations, per-fixture trace/diagnostic capture, stable failure stages, and query helpers.
- [x] **ADDRESSED (verified)** — Controlled scalar, nested aggregate, dispatch, lifecycle, function, boundary,
  trace, parse, validation, runtime, mismatch, no-match, later-pass continuation, record identity/query, and strict
  selection cases prove every accepted field and branch.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 160/160. The existing validation-only corpus process test and
  exact gate boundary remain green; no manifest/fixture/expected value, public parity status, capability row, or
  permanent ordered corpus-window assertion changes in this leaf. Canonical local CI passes CLI 61x2 plus Phase 0
  `1..1031` in 623 seconds. Mutation testing was not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmap/task/live/architecture/change/notes, mdBook API/status/local-gate
  chapters, Knowledge Map, and bounded memory describe the executor, preserve CLI ownership, and activate ordered
  core admission `.6.1.3`.

### `LUA-BACKEND-PARITY.6.1.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Disposable probes proved the 40-case core prefix passed, but no permanent test used
  the reusable executor to lock its exact manifest order, boundaries, outputs, and endpoints on both Lua ABIs.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.6.1.2` intentionally proved executor mechanics with controlled temporary
  fixtures; `lua/test/run.lua` still had no recurring manifest-backed assertion for offsets 0-39, so a later drift
  could regress the measured core window without failing the focused gate.
- [x] **FIX** — Execute `{ offset = 0, limit = 40 }` through the production library API and assert the full
  manifest count, exact selected count/order/first/last names, 40 passes, zero failures, exact one-level wrapped
  expected output, matched state, endpoint 1/1, and absent failure fields for every result.
- [x] **ADDRESSED (verified)** — Exact offsets 0-39 pass 40/40 from `proof_edge_array_literal` through
  `terse_2_2_5_2_attached_switch_blocks`; all per-case wrapped outputs and endpoints are permanently checked.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 161/161. This leaf changes only the permanent test and aligned
  docs; production source, corpus data, public status, capability census, CLI behavior, and offsets 40-104 remain
  unchanged. Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` passing in 640 seconds (1,316.33
  seconds total under concurrent load). Mutation testing was not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmaps, task/index/live/architecture/change/notes, mdBook, Knowledge Map, and
  bounded memory record exact 40/40 admission and activate governed capability/no-drift `.6.1.4`.

### `LUA-BACKEND-PARITY.6.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Exact manifest offsets 40-98 pass 50/59 identically on PUC Lua and LuaJIT. The nine
  residuals are one hash-receiver compare mismatch, three HLink execute failures, two EBNF compare mismatches,
  one SimEnv execute failure, one history compare mismatch, and one PPlugin compare mismatch.
- [x] **ROOT CAUSE (WHY + WHERE)** — Production debug traces show child rules entered twice before the HLink/
  EBNF/SimEnv failure paths. Canonical generated Perl invokes each selected action-edge child once. Lua
  `evaluate_call(...)` executes `call(child)` directly instead of using `dispatch_edge_child(...)`, leaving the
  edge fallback to execute it again. Separate ActionIR/toolbox probes prove receiver `.copy()` loses the receiver,
  `hash(flat_array(...))` misses a hash-splice classification, and public parse starts before the Perl wrapper's
  leading-trivia boundary.
- [x] **FIX** — No behavior changes in this planning leaf. Split action-edge call reuse `.6.2.1`, receiver copy
  `.6.2.2`, flat-array hash splicing `.6.2.3`, leading-trivia initialization `.6.2.4`, successor measurement/split
  `.6.2.5`, and exact permanent 59-case admission/no-drift `.6.2.6` in dependency order.
- [x] **ADDRESSED (verified)** — Both ABIs expose the same names, failure stages, values, endpoints, and trace
  mechanisms; 50 passing cases and nine residuals are durably routed without changing any oracle.
- [x] **NO REGRESSION** — Planning changes only task/live/book/KM state. Production source, tests, corpus data,
  expected JSON, public status `native-full-pipeline-trace-v1`, primary/developer CLI boundaries, coverage
  246/105+1/122, and four-backend capability 64/0/0 remain unchanged. PUC Lua and LuaJIT pass 162/162; mdBook,
  Knowledge Map, memory/doctrine, and canonical local CI pass. The canonical gate includes CLI 61/61 in both
  environments and Phase 0 true reach `1..1031` in 629 seconds. Mutation testing remains manual-only and is not
  run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmap, architecture, task/index/live state, mdBook, Knowledge Map, and bounded
  memory record exact 50/59 measurement and activate only action-edge repair `.6.2.1`.

### `LUA-BACKEND-PARITY.6.1.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The six governed capability fixtures passed disposable probes, but offsets 99-104
  had no recurring executor proof and parent `.6.1` still lacked exact public/status/census closeout.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.6.1.3` deliberately admitted only the core prefix. The six final manifest
  entries exercise distinct cursor, helper, marker, anonymous-capture, and named-capture surfaces whose endpoints
  are not uniformly 1, so they require their own ordered names and per-fixture endpoint contract.
- [x] **FIX** — Execute `{ offset = 99, limit = 6 }` through the production library API; lock all six names,
  manifest order, 6/6 pass state, exact one-level wrapped output, match, endpoint pairs `2,1,2,1,5,5`, and absent
  failure fields. Inventory exact public corpus exports/status/CLI/tests/docs/KM and retain ADR `0041` census timing.
- [x] **ADDRESSED (verified)** — Exact offsets 99-104 pass 6/6 on PUC Lua and LuaJIT, every unchanged output and
  endpoint is permanent, and the combined owned windows close at 46/46.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 162/162. Coverage is 246/105+1/122 with zero omissions and
  capability remains four-backend 64/0/0. Production source, manifest/fixtures/expected JSON, public status,
  primary/developer CLI behavior, and census rows are unchanged. Canonical local CI exits 0 with CLI 61x2 and
  Phase 0 `1..1031` passing in 651 seconds (1,328.76 seconds total under concurrent load). Mutation testing was
  not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmaps, task/index/live/architecture/change/notes, mdBook API/status/local-gate/
  handoff/trace surfaces, Knowledge Map, and bounded memory close parent `.6.1` and activate `.6.2` for offsets
  40-98.

### `LUA-BACKEND-PARITY.5.2.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Resolve/load, automatic spec-owned function parsing, and compile/engine composition
  are implemented, but their parent cannot close until every public/source/test/doc/KM surface and later fence
  agrees.
- [x] **ROOT CAUSE (WHY + WHERE)** — The native-loading contract spans `init.lua`, `spec_loader.lua`, the cached
  function parser, compiler/runtime identity, focused tests, neutral fixtures, and public/status documentation;
  any stale or missing surface would make a green implementation an incomplete product boundary.
- [x] **FIX** — Inventory those exact surfaces, align current frontier text, close parent `.5.2`, and activate only
  descriptor/full-pipeline trace `.5.3`; add no duplicate adapter or behavior.
- [x] **ADDRESSED (verified)** — Typed exports/state/errors and named/path runtime identity are exercised and
  documented consistently; no unowned seam or stale current-behavior claim remains.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT remain 153/153; native 14/9/4, capability 64/0/0, coverage
  246/105+1/122, public 58/27/0, mdBook, Knowledge Map, doctrine, memory, and canonical gates pass; canonical CI
  includes both 61/61 CLI environments and Phase 0 `1..1031` in 607 seconds. No Lua source, behavior, status,
  capability, or test count changes; mutation testing is not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmaps/architecture/live state, mdBook, task/index, and Knowledge Map close
  `.5.2`, activate `.5.3`, and retain generated source, corpus execution, and parser CLI as later owners.

### `LUA-BACKEND-PARITY.5.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua can resolve/load exact UTF-8 source and automatically parse/stage top-level
  functions, but callers must still manually compose validation, compilation, and source-identified engine setup.
- [x] **ROOT CAUSE (WHY + WHERE)** — `spec_loader.lua` stops at `LoadedSpec`; no typed result or adapter owns the
  dependency-ordered loaded-text → automatic parse/stage → validate → compile → identified-engine path.
- [x] **FIX** — Add typed `LoadedCompiledSpec`, `load_and_compile_spec(...)`, and loaded-result engine creation;
  retain exact nested identity/source/compiled state, copy caller engine options, and translate only the three
  source-pipeline failure boundaries to the neutral stage/code contract.
- [x] **ADDRESSED (verified)** — Named and exact-path requests preserve their exact identities; top-level functions
  compile and execute; only named requests attach `spec_name`; both attach the resolved `spec_path`; runtime
  diagnostics retain those fields; parse/validation/compile errors and exact missing-name JSON stay distinct.
- [x] **NO REGRESSION** — Both Lua ABIs, direct 14/9/4 fixture proof, capability/coverage/public checks, mdBook,
  Knowledge Map, doctrines, memory architecture, and canonical local CI pass; the canonical gate includes both
  61/61 CLI environments and Phase 0 `1..1031` in 616 seconds. Inline APIs and all explicit later CLI/corpus/
  descriptor/full-trace/generated boundaries remain unchanged. Mutation testing is not run.
- [x] **LOCKSTEP** — Root/Lua docs, roadmap/architecture/live state, mdBook API/status/handoff pages, task/index,
  Knowledge Map, and public status expose loaded-source composition while reserving parent no-drift for `.5.2.4`.

### `LUA-BACKEND-PARITY.5.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua could project caller-supplied function-definition nodes and could execute the
  owning grammar in a probe, but no production API connected those mechanisms automatically.
- [x] **ROOT CAUSE (WHY + WHERE)** — `user_function_definition_shell.lua` deliberately owned typed projection,
  while no adapter owned bundled grammar resolution, one-time compilation, in-process execution, or composition.
- [x] **FIX** — Add a typed cached parser that resolves only the module-relative bundled grammar, runs the native
  parse/validate/compile APIs once, executes top rule `user_function_definitions`, normalizes typed output, and
  delegates to the existing Unicode projector and deterministic staged body dispatcher.
- [x] **ADDRESSED (verified)** — Fixed, variadic, and final-codeblock definitions preserve source order and Unicode
  character spans; composed rules validate; parser build count stays one; parse/validation/execution/output/
  projection/staged failures retain their typed owner; no raw `fn` scanner was introduced.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes PUC Lua 151/151 and LuaJIT 151/151; native 14/9/4,
  capability 64/0/0, coverage 246/105+1/122, public inventory, mdBook, Knowledge Map, doctrine, memory, and
  canonical CI pass; the canonical gate includes CLI 61x2 and Phase 0 `1..1031` in 631 seconds. Mutation testing
  remains manual-only and is not run.
- [x] **LOCKSTEP** — Public status is `native-spec-defined-functions-v1`; root/Lua docs, roadmap/architecture/live
  state, mdBook API/status/handoff pages, task/index, and Knowledge Map activate only loaded-source compile/engine
  composition `.5.2.3`, without claiming descriptors, full trace, generated source, corpus execution, or CLI.

### `LUA-BACKEND-PARITY.5.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua had only in-memory source APIs: no typed portable name versus exact-path intent,
  deterministic caller-owned filesystem policy, byte-loading boundary, or neutral file-pipeline errors.
- [x] **ROOT CAUSE (WHY + WHERE)** — `lua/src/linkedspec/` had no file-oriented owner, and pure Lua cannot portably
  distinguish every regular-file/non-regular/missing/error case without either a subprocess or a narrow native
  filesystem seam.
- [x] **FIX** — Add typed `SpecRequest`, `SpecLoadOptions`, `ResolvedSpec`, `LoadedSpec`, and `SpecPipelineError`
  identities; deterministic lexical candidates; a minimal native regular-file inspector built separately for both
  Lua ABIs; in-process byte reads; strict UTF-8 validation; and deterministic JSON projection.
- [x] **ADDRESSED (verified)** — Direct tests consume all 14 name, nine resolution/file-kind, and four text cases;
  supplemental Unicode whitespace/control plus empty/NUL/invalid-UTF-8 path boundaries also reject exactly.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes PUC Lua 149/149 and LuaJIT 149/149; the explicit
  parser CLI remains unavailable, corpus validation remains non-executing, and no parse/compile behavior entered
  this leaf. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 1,265 seconds.
- [x] **LOCKSTEP** — Public status is `native-spec-resolution-loading-v1`; root/Lua docs, roadmap/architecture/live
  state, mdBook API/status/handoff pages, task/index, and Knowledge Map route automatic spec-owned function parsing
  to active `.5.2.2` without claiming composition, descriptor, generated-source, corpus-execution, or CLI parity.

### `LUA-BACKEND-PARITY.5.2.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Broad `.5.2` combined filesystem resolution, byte/text boundaries, automatic
  spec-defined function parsing, pipeline error attribution, compilation, engine identity, and no-drift.
- [x] **ROOT CAUSE (WHY + WHERE)** — ADR `0026` makes resolve/load independent of source parsing, while Lua's full
  parser still consumes externally supplied function-definition nodes even though its runtime can execute the
  owning grammar. Compile/engine composition depends on both mechanisms and must not be implemented in parallel.
- [x] **FIX** — Split `.5.2.1` resolve/load, `.5.2.2` automatic spec-defined function parsing, `.5.2.3` full
  composition, and `.5.2.4` no-drift; retain descriptors/full trace in `.5.3` and generated/CLI/corpus elsewhere.
- [x] **ADDRESSED (verified)** — A direct native probe compiles and executes `specs/user_function_definition.spec`
  against `fn zero() { return("zero") }`, returning one `function_definition` named `zero` with exact body text.
- [x] **NO REGRESSION** — No source, behavior, status, capability, or test-count change. PUC Lua and LuaJIT remain
  146/146; `perl tools/check_native_spec_resolution_contract.pl` passes 14/9/4; capability remains 64/0/0.
- [x] **LOCKSTEP** — Task/index/roadmaps/live docs, mdBook, and Knowledge Map record one dependency order and the
  exact current `.5.2.1` frontier without claiming descriptor, trace, generated, corpus, or CLI completion.

### `LUA-BACKEND-PARITY.5.1.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The implementation leaves were green, but parent `.5.1` still advertised an active
  frontier and Lua's README still said staged body dispatch was unimplemented.
- [x] **ROOT CAUSE (WHY + WHERE)** — Each implementation slice updated its own mechanism and handoff, while the
  parent closeout and an older bottom-of-README capability paragraph deliberately remained owned by `.5.1.5`.
- [x] **FIX** — Audit exports, provider/runtime seams, focused tests, status, later fences, public docs, task/index/
  roadmaps/live state, and Knowledge Map; correct the stale dispatch statement; close `.5.1`; activate only `.5.2`.
- [x] **ADDRESSED (verified)** — Public APIs expose deterministic staged execution/stitching and function-frame
  preparation; runtime covers fixed, variadic, and contextual calls; descriptors/full trace, loading, generated
  source, corpus/CLI, and explicit dynamic codeblocks retain distinct owners with no premature capability claim.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` remains 146/146 on PUC Lua and LuaJIT; callable signature/
  codeblock checkers remain 3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122; capability remains 64/0/0;
  canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 644 seconds. Mutation testing is manual-only and
  was not run.
- [x] **LOCKSTEP** — Status remains precise; Lua/root READMEs, task/index/roadmaps, architecture/live/changes/notes/
  memory, mdBook, and Knowledge Map close `.5.1`, activate `.5.2`, and retain every later boundary.

### `LUA-BACKEND-PARITY.5.1.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Metadata-governed contextual calls normalized to `codeblock_argument`, but the
  function runtime either eagerly executed a structural block while evaluating arguments or had no callable-slot
  dispatch once the inert value reached the isolated frame.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` installed only stores and active function names; the registry
  frame did not expose exact parameter kinds, and call dispatch had no bounded current-frame contextual owner.
- [x] **FIX** — Normalize before caller-side argument evaluation, copy the inert contextual node through frame
  preparation, install exact `parameter_kinds`, and invoke only the declared current slot after static registered
  functions/governed helpers. Evaluate its block through the existing ActionIR boundary with zero arity, a guarded
  active-callback path, protected cleanup, and ordinary copied return values.
- [x] **ADDRESSED (verified)** — Attached/parenthesized forms agree; blocks see/mutate current function-frame
  bindings; nonparameter effects reach later function statements; outer scalar/private stores restore; returned
  strings chain; static callables win collisions; and missing/harray/arity/recursion failures carry typed fields.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 146/146 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Callable signature/codeblock checkers pass
  3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 622 seconds.
- [x] **LOCKSTEP** — Public status, Lua/root READMEs, task/index/roadmaps, architecture/live/changes/notes/memory,
  mdBook pipeline/status/handoff/trace pages, and Knowledge Map close `.5.1.4` and activate only `.5.1.5` while
  retaining descriptors `.5.3`, generated source `.8`, and explicit/dynamic codeblock values `.11.7`.

### `LUA-BACKEND-PARITY.5.1.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The shared definition spec already emitted `fixed_params`, `codeblock_param`, and
  `parameter_kinds`, but Lua's shell and typed records accepted only untyped fixed-v1 or variadic-v2 state and
  generic ActionIR retained contextual blocks only as `block_value`.
- [x] **ROOT CAUSE (WHY + WHERE)** — `spec_ast.lua`, the function shell, validator, staged/registry copies, and
  action contracts had no final-parameter-kind field or metadata-derived contextual normalization seam.
- [x] **FIX** — Canonicalize the spec-produced codeblock shape into fixed-v1 params/arity plus exact final
  `parameter_kinds`; enforce sidecar equality across AST/staged/registry/compiled state; map four invalid source
  forms; and construct one typed zero-positional `codeblock_argument` for both contextual spellings.
- [x] **ADDRESSED (verified)** — Exact declaration metadata round-trips and compiles; drift rejects; attached and
  parenthesized calls normalize equivalently without source-AST mutation; harrays remain `hash_literal`; existing
  built-in metadata is unchanged; descriptors and runtime invocation remain explicitly fenced for later owners.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 142/142 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Callable signature/codeblock checkers pass
  3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 605 seconds.
- [x] **LOCKSTEP** — Public status, Lua/root READMEs, task/index/live/changes/notes/memory, mdBook pipeline/status/
  handoff pages, and Knowledge Map close `.5.1.4.1` and activate only `.5.1.4.2`.

### `LUA-BACKEND-PARITY.5.1.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Variadic definitions resolved by minimum arity, but invocation deliberately failed
  with `variadic_user_function_runtime_pending` before any rest value could bind or a staged body could execute.
- [x] **ROOT CAUSE (WHY + WHERE)** — `user_function_registry.prepare_invocation(...)` copied only fixed-prefix
  arguments into the isolated frame and had no backend-neutral typed-array binding for the signature's rest name.
- [x] **FIX** — Retain isolated copies of every evaluated argument, bind the fixed prefix normally, and copy all
  extras again into one fresh `json.array()` exposed through the rest scalar/typed-array stores; reuse the existing
  staged ActionIR body evaluator with no Lua vararg, host splat, or second function interpreter.
- [x] **ADDRESSED (verified)** — The unchanged neutral callable fixture passes exact fixed, empty/nonempty rest,
  mixed value, prefix/object, and receiver-chain results. Supplemental tests lock eager order, empty/repeated
  freshness, nested array/harray/null/boolean/codeblock identity, caller/store isolation, minimum arity, and keyword
  diagnostics.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 139/139 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Callable signature/codeblock checkers pass
  3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 621 seconds.
- [x] **LOCKSTEP** — Public status, Lua/root READMEs, task/index/roadmaps, live/changes/notes/memory, mdBook
  pipeline/status/handoff/trace pages, and Knowledge Map close `.5.1.3` and activate only `.5.1.4.1`.

### `LUA-BACKEND-PARITY.5.1.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua's function/job/registry records hard-coded fixed-v1 `params`/`arity`, so a
  variadic-v2 signature would be rejected, erased, or collapsed into an incorrect exact-arity definition.
- [x] **ROOT CAUSE (WHY + WHERE)** — `spec_ast.lua`, the definition shell, staged registry, user-function registry,
  compiled state, and call contracts lacked a typed versioned signature union and minimum/unbounded resolution.
- [x] **FIX** — Add the exact six-field signature, enforce exclusive v1/v2 serialized storage and sidecar identity,
  preserve it through every native state boundary, resolve v2 at or above its minimum, and retain explicit
  fail-closed fences for later runtime and descriptor owners.
- [x] **ADDRESSED (verified)** — Focused tests prove unchanged fixed-v1 JSON, exact v2 shell/AST/job/staged/compiled
  round trips, mixed storage and signature/sidecar drift rejection, duplicate/reserved/rest diagnostics, minimum
  and unbounded resolution, portable positional contracts, and deliberate runtime/descriptor pending boundaries.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 136/136 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Callable signature/codeblock checkers pass
  3/9/7 and 7/11/9/7/4/8; coverage remains 246/105+1/122 and capability remains 64/0/0. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 620 seconds.
- [x] **LOCKSTEP** — Public status, Lua/root READMEs, task/index/roadmaps, live/changes/notes/memory, mdBook
  pipeline/status/handoff/trace pages, and Knowledge Map close `.5.1.3.1` and activate only `.5.1.3.2`.

### `LUA-BACKEND-PARITY.5.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Staged function definitions and isolated invocation frames existed, but every
  registered runtime call still canonicalized into built-in helper dispatch and ended as unsupported.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` never consulted the compiled function registry, had no
  active-function recursion path, and had no cleanup-safe body executor tied to staged `body_ast` authority.
- [x] **FIX** — Resolve registered names first; reject keyword AST arguments; evaluate positional arguments once
  left-to-right; prepare copied local frames; integrity-check/cache typed bodies against staged JSON; execute with
  local final/early-return semantics; and restore all caller stores/active paths through one protected boundary.
- [x] **ADDRESSED (verified)** — Focused execution proves nested fixed calls, eager side-effect order, standalone
  result drop, scalar/array/harray isolation, absent caller capture, four receiver-result families, exact arity,
  keyword ownership, direct/mutual recursion cycles, and missing/mismatched staged-body rejection.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 133/133 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Coverage remains 246/105+1/122 and
  capability remains 64/0/0. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 605 seconds.
- [x] **LOCKSTEP** — Public status, Lua/root READMEs, task/index/roadmaps, live/changes/notes/memory, mdBook
  pipeline/status/handoff pages, and Knowledge Map close `.5.1.2` and activate only `.5.1.3.1`.

### `LUA-BACKEND-PARITY.5.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua preserved spec-produced function-body jobs and exposed one manual stitch helper,
  but no provider registry normalized, ordered, resolved, loaded, compiled, executed, and stitched those jobs.
- [x] **ROOT CAUSE (WHY + WHERE)** — `user_function_definition_shell.lua` stopped at typed sidecar projection;
  `user_function_registry.lua` could stitch a caller-supplied AST but had no governed `actionir-body.spec` owner,
  stable work queue, cache/compiled identity, or composed shell-dispatch API.
- [x] **FIX** — Added `staged_parser_registry.lua` with exact typed normalization, stable decorated sorting, the sole
  built-in ActionIR-body provider/digest/cache/compiled identity, contextual phase errors, fixed-v1 sidecar and
  duplicate-job fences, immutable stitching, result JSON, and public composed entrypoints.
- [x] **ADDRESSED (verified)** — Focused proof reverses input order, checks exact provider/digest/fingerprint/result
  shape, dispatches two functions without mutating the source, proves stitched-result isolation, composes the
  spec-owned function shell, and rejects unsupported providers, result-field drift, and duplicate job ids.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 130/130 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Coverage remains 246/105+1/122,
  capability remains 64/0/0, and status advances precisely to `runtime-staged-registry`. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 622 seconds.
- [x] **LOCKSTEP** — Public exports/status, README/Lua README, task/index/roadmaps, architecture/live/changes/notes/
  memory, mdBook staged/status/handoff/trace pages, and Knowledge Map record the provider and activate `.5.1.2`.

### `LUA-BACKEND-PARITY.5.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Parent `.5.1` combined staged parser dispatch, fixed and variadic execution, signature
  evolution, contextual final-codeblock declarations/execution, and closeout in one implementation leaf.
- [x] **ROOT CAUSE (WHY + WHERE)** — Lua's current seams are intentionally uneven: the shell and registry preserve
  exact-v1 sidecars/frames, compiled state resolves contracts, ActionIR parses generic trailing blocks, and built-in
  contextual blocks execute, but no staged provider or registered-call runtime exists. Variadic and codeblock
  declaration records have different neutral schemas and each requires metadata before execution.
- [x] **FIX** — Split `.5.1` by dependency into `.1` staged dispatch, `.2` fixed execution, `.3.1/.3.2` variadic
  state/runtime, `.4.1/.4.2` contextual-codeblock state/runtime, and `.5` no-drift. Retain descriptors/full trace in
  `.5.3`, generated source in `.8`, and explicit callable literals/bound calls in `.11.7`.
- [x] **ADDRESSED (verified)** — Knowledge Map and source inspection identify exact current owners in
  `user_function_definition_shell.lua`, `user_function_registry.lua`, `compiled_spec.lua`, `action_contracts.lua`,
  `action_parser.lua`, and `interpreter.lua`; completed Dart/Julia staged and runtime sequences confirm the order.
- [x] **NO REGRESSION** — Planning changes no source, status, capability, fixtures, or test count. The committed
  baseline remains PUC Lua/LuaJIT 129/129, coverage 246/105+1/122, and capability 64/0/0. Both neutral callable
  checkers plus mdBook, memory, Knowledge Map, task metadata, doctrines, and whitespace pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, README/Lua README, architecture/live/changes/notes/memory, mdBook, and
  Knowledge Map record the split and activate only `.5.1.1`.

### `LUA-BACKEND-PARITY.4.4.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Runtime diagnostics, controls/sinks, and interpreter events were implemented across
  `.4.4.1-.3`, but parent `.4.4` could not close until API/status/public/durable records proved the exact scoped
  boundary and excluded dependency-incomplete full-pipeline trace.
- [x] **ROOT CAUSE (WHY + WHERE)** — The mechanisms already passed focused tests; remaining risk was narrative and
  ownership drift across `lua/src/linkedspec/init.lua`, `lua/src/linkedspec/trace.lua`, interpreter topics, tests,
  public docs, task/index/roadmaps, and Knowledge Map. Dart/Julia evidence shows frontend/compiler/staged trace
  must remain later when those runtime-independent owners do not yet exist.
- [x] **FIX** — Audited exact exported controls/primitives/entrypoints and nine runtime topic families against
  focused assertions and the variant-neutral trace contract, then aligned every public and durable status surface.
  No runtime source change or parallel trace path was needed.
- [x] **ADDRESSED (verified)** — The audit proves six ordered levels; immutable environment-aware controls;
  enter/exit/decision/mark/dump/log events; stdout/route/mirror/reset/append; result-neutral direct/config-wrapper
  runtime entrypoints; typed diagnostics; and parse/rule/regex/dispatch/recursion/lifecycle/cursor/boundary/
  governed mark-capture events. Status remains the precise `runtime-trace-events`.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 129/129 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture validation. Coverage stays 246/105+1/122, capability
  stays 64/0/0, mdBook builds, and canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 608 seconds.
- [x] **LOCKSTEP** — README/Lua README, roadmaps, architecture/live/changes/notes/memory, task/index, trace/runtime
  mdBook pages, and Knowledge Map close `.4.4`, activate `.5.1`, and retain full native-pipeline trace under `.5.3`.

### `LUA-BACKEND-PARITY.4.4.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua `.4.4.2` exposed typed controls, sinks, and balanced parse scopes but emitted no
  event from the rule interpreter itself, leaving regex branches, recursion cutoffs, dispatch, lifecycle, cursor,
  boundary, and governed mark/capture mechanisms invisible.
- [x] **ROOT CAUSE (WHY + WHERE)** — `runtime_parse(...)` passed its emitter only around `execute_rule(...)`.
  The execution context did not retain it, and the existing rule/regex/edge/lifecycle/helper mutation seams had
  no trace calls even though they already carried exact rule, target, cursor, match, stack, and source identity.
- [x] **FIX** — Threaded the optional emitter through the one runtime context and instrumented balanced rule scopes,
  recursion cutoffs, regex match/no-match, action/blind child dispatch, lifecycle blocks, all four cursor controls,
  source-boundary outcomes, governed mark/capture helper positions, and post-mutation rule-slot marks. No parallel
  traced interpreter or ambient global state was added.
- [x] **ADDRESSED (verified)** — One focused trace test asserts exact topics/details, balanced scopes, successful
  and no-match regex decisions, action and blind dispatch, recursion cutoff, all cursor helpers, found boundary
  span, helper mark positions, and capture/named-mark rule slots. Success, no-match, and recursion parse-result JSON
  remains byte-identical with and without tracing.
- [x] **NO REGRESSION** — Focused `bash tools/run_lua_local.sh` passes 129/129 on separately built PUC Lua and
  LuaJIT adapters plus syntax, CLI scaffold, and exact 105-fixture manifest validation. Shared coverage remains
  246/105+1/122 and capability remains 64/0/0. Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in
  610 seconds; later full-pipeline trace remains `.5.3`.
- [x] **LOCKSTEP** — Lua status/README, runtime and trace mdBook pages, task/index/roadmaps, Knowledge Map,
  architecture/live docs, changes/notes, and memory record `runtime-trace-events` and activate `.4.4.4`.

### `LUA-BACKEND-PARITY.4.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua had structured failure payloads but no typed trace level/config/event owner, no
  caller-controlled sink, and no result-neutral traced runtime entrypoint equivalent to admitted backends.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.runtime_parse(...)` exposed diagnostic output only and
  `init.lua` exported no tracing module. There was no immutable config, ordered threshold gate, structured event
  recorder/renderer, or resettable route/mirror boundary to inject per call.
- [x] **FIX** — Added zero-dependency `linkedspec.trace` with exact levels/aliases/numeric thresholds, immutable
  configs and updates, documented environment controls, typed event/scope/emitter values, structured JSON,
  stdout/route/mirror sinks, reset/append, emoji, and enter/exit/decision/mark/log/dump primitives. Added direct
  emitter injection and config-wrapper runtime entrypoints, exporting the complete native surface from `init.lua`.
- [x] **ADDRESSED (verified)** — Exact rendering/indentation/order, level gates, environment fallback/precedence,
  config immutability, event/line snapshot isolation, route suppression/reset/append, mirror byte identity, emoji,
  quiet-disabled behavior, caller-option isolation, and balanced success parse scopes all pass on both Lua ABIs.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 128/128 on separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI scaffold, and exact 105-fixture manifest validation. Traced and untraced result JSON is
  identical; shared coverage remains 246/105+1/122 and capability remains 64/0/0. Deeper runtime events remain
  exclusively owned by `.4.4.3`; full frontend/compiler/function/staged propagation remains `.5.3`. Canonical
  local CI passes CLI 61x2 and Phase 0 `1..1031` in 611 seconds.
- [x] **LOCKSTEP** — Lua public API/status/README, runtime and trace mdBook pages, task/index/roadmaps, Knowledge
  Map, architecture/live docs, changes/notes, and memory record `runtime-trace-controls` and activate `.4.4.3`.

### `LUA-BACKEND-PARITY.4.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua `RuntimeInterpreterException` values exposed only free-form `message` plus
  mechanism-specific ad hoc fields. Callers had no neutral stage/owner/spec/top/deepest-rule/handler payload or
  deterministic error projection equivalent to the admitted backends.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua::fail` created one typed table, but `execute_rule` discarded
  its rule-stack frame before rethrow and `runtime_parse` had no fallback wrapper. `runtime_engine` did not retain
  caller-owned spec identity, and `interpreter.to_json` accepted successful/event values only.
- [x] **FIX** — Added typed `RuntimeDiagnostic`, optional engine `spec_name` / `spec_path`, specific top-selection/
  strict-input/rule-lookup/execution payload builders, child-before-parent fallback wrapping, diagnostic-preserving
  parse fallback, typed error/diagnostic JSON, public diagnostic recognition, and precise public status.
- [x] **ADDRESSED (verified)** — Exact missing-rule JSON contains all ten neutral fields; nested child helper failure
  retains top `Top`, deepest `Child`, and `lua_runtime:rule:Child`; nested lookup keeps its richer `rule_lookup`
  stage; empty compiled state and invalid UTF-8 use specific stages; absent identity keys are omitted; success
  result type/value/output/cursor and textual error content remain unchanged.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 126/126 on separately built PUC Lua and LuaJIT
  adapters, including syntax, CLI scaffold, and exact 105-fixture manifest validation. Shared coverage remains
  246/105+1/122 and capability remains 64/0/0. `bash tools/run_ci_local.sh` exits 0 with both primary CLI
  environments at 61/61 and Phase 0 `1..1031` in 613 seconds; later trace/function/corpus/CLI/generated claims
  stay absent.
- [x] **LOCKSTEP** — Lua public API/status/README, diagnostics and runtime mdBook pages, task/index/roadmaps,
  Knowledge Map, architecture/live docs, changes/notes, and memory record `runtime-structured-diagnostics` and
  activate trace controls/sinks `.4.4.2`.

### `LUA-BACKEND-PARITY.4.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Parent `.4.4` bundled runtime diagnostics, trace controls, interpreter events, and
  frontend/compiler/function/staged propagation even though general function/staged execution `.5.1` and native
  loading `.5.2` do not exist yet; `.5.3` independently owned full-pipeline trace admission.
- [x] **ROOT CAUSE (WHY + WHERE)** — The original planning sentence combined two dependency epochs. Completed Dart
  and Julia task trees prove the safe order: structured runtime failures, controls/sinks, and runtime events land
  before staged work; one-emitter frontend/compiler/function/staged propagation lands only after those owners exist.
- [x] **FIX** — Split `.4.4` into `.1` neutral runtime diagnostics, `.2` levels/config/events/sinks, `.3` runtime
  instrumentation, and `.4` no-drift closeout. Narrowed the parent to that executable runtime boundary and made
  `.5.3` explicitly depend on `.4.4`, `.5.1`, and `.5.2` for full native-pipeline propagation.
- [x] **ADDRESSED (verified)** — Current Lua seams are sufficient for the ordered plan: typed runtime errors and a
  rule stack support `.1`; the per-parse option boundary supports caller-owned `.2`; compiled rule/action source,
  recursion, lifecycle, cursor, boundary, capture, and mark state support `.3`. Missing staged/native owners no
  longer sit inside the active implementation leaf.
- [x] **NO REGRESSION** — Planning-only task/KM/book/live-doc changes alter no Lua source, test expectation, public
  parity status, capability row, or runtime result. The committed 125/125 dual-ABI and 64/0/0 capability baseline
  remains the executable proof.
- [x] **LOCKSTEP** — Task/index/roadmaps, README/Lua README, mdBook status/handoff, Knowledge Map, architecture/live
  docs, changes/notes, and memory record the same dependency-correct split and activate `.4.4.1`.

### `LUA-BACKEND-PARITY.4.3.9.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Inventory membership and corpus occurrence did not permanently prove that every one
  of the 246 admitted names reached a Lua runtime owner; direct `call(rule)` lacked a focused execution assertion,
  and the public status still named the much earlier numeric-reducer milestone.
- [x] **ROOT CAUSE (WHY + WHERE)** — `action_call_names.lua` exposed only membership/count operations, so the
  exhaustive `.0` probe was disposable. `init.lua` retained `runtime-numeric-reducers`. Rechecking current and
  historical source also proves the `.0` duplicate-`or` note was unreproducible: every inspected revision has one
  exact row, making the note—not the inventory—the defect.
- [x] **FIX** — Added a defensive sorted current-name view and a permanent parse/compile/runtime probe with an exact
  thirteen-name negative-space allowlist; added direct child-call result/`retv`/cursor proof; promoted status to
  `runtime-helper-value-control`; corrected the false duplicate-row record in durable docs and the Knowledge Map.
- [x] **ADDRESSED (verified)** — The post-logical partition is exactly 233 runtime-owned + 13 documented structural
  or receiver-only function forms = 246, with zero unowned residual. `call(Child)` returns the child payload,
  refreshes `retv`, and leaves the Unicode-character cursor at 2.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 125/125 under separately built PUC Lua and LuaJIT
  adapters, including syntax, CLI-scaffold, and exact 105-fixture manifest validation. Shared coverage stays
  246/105+1/122 and capability stays 64/0/0. `bash tools/run_ci_local.sh` passes CLI 61x2 and Phase 0 `1..1031` in
  608 seconds; later trace/functions/corpus/CLI/generated claims remain absent.
- [x] **LOCKSTEP** — Lua API/README, public book, task/index/roadmaps, Knowledge Map, architecture/live docs,
  changes/notes, and memory close `.4.3.9`/`.4.3` and activate diagnostics/trace `.4.4`.

### `LUA-BACKEND-PARITY.4.3.9.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The `.0` generated runtime probe reports exact admitted calls `and`, `or`, and
  `not` as unsupported while the mdBook and Rust/Dart/Julia runtimes expose logical value helpers.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua::evaluate_call` had no logical-family branch. Existing
  `runtime_truthy` already owns Lua's current condition policy, so a new coercion or host Lua `and`/`or` path would
  create drift. Cross-backend source inspection also confirms Dart currently short-circuits and gives empty
  `and()` true, reinforcing that global normalization belongs to `.5.2` rather than this Lua repair.
- [x] **FIX** — Added one `LOGICAL_HELPERS` dispatcher and eager evaluator that collects all argument values first,
  then computes booleans through `runtime_truthy`, including governed empty-call false/false/true behavior.
- [x] **ADDRESSED (verified)** — Focused runtime proof locks false-first `and`, true-first `or`, extra-argument
  `not`, exact six-event order, empty calls, scalar zero text, empty aggregate truthiness, boolean identity, and
  result continuation through receiver `.with()`.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 123/123 under separately built PUC Lua and LuaJIT
  adapters, plus syntax, CLI-scaffold, and exact 105-fixture manifest validation. Inventory/capability stay 246 and
  64/0/0; no Perl/Rust/Dart/Julia behavior changed.
- [x] **LOCKSTEP** — Lua README/API, helper reference, backend handoff/status, task/index/roadmaps, Knowledge Map,
  architecture/live docs, changes/notes, and memory agree that `.1` is complete, `.2` is active, and global
  normalization remains `.5.2`.

### `LUA-BACKEND-PARITY.4.3.9.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — A generated `name()` action for every exact admitted call reports 230 handled names
  and 16 `unsupported runtime helper` names instead of silently treating the green 246-name occurrence gate as
  execution parity.
- [x] **ROOT CAUSE (WHY + WHERE)** — Thirteen unsupported function shapes belong to explicit structural or
  named-receiver-only syntax. `interpreter.lua` has no branch for the remaining `and`/`or`/`not`; `init.lua` still
  publishes the much earlier `runtime-numeric-reducers` status. Toolbox lowering proves Perl `and`/`or` also have
  a separate keyword-precedence defect even though Rust/Dart/Julia and the mdBook specify eager boolean helpers.
- [x] **FIX** — Split logical behavior `.1` from exact recurring ownership/status admission `.2`, and add
  dependency-gated `FUTURE-PARITY-BACKLOG.5.2` for the neutral truthiness/arity/reference-lowering contract.
- [x] **ADDRESSED (verified)** — The source-derived partition is exactly 230 handled + 13 intentional non-function
  owners + 3 missing logical helpers = 246, with no ambiguous residual name. Direct `call(rule)`, the reported
  duplicate `or`, and stale status are explicitly owned by `.2`; `.2` later confirms the duplicate report was an
  audit-note error rather than a source row.
- [x] **NO REGRESSION** — This split changes no parser/compiler/runtime/inventory/status behavior or capability
  claim; the committed `.4.3.8` Lua 122/122 and canonical 64/0/0 proof remains the executable baseline.
- [x] **LOCKSTEP** — Task/index/roadmaps, README/Lua README, public book status/handoff, Knowledge Map, architecture/
  live docs, changes/notes, and memory record the exact partition, active `.1`, closeout `.2`, and future `.5.2`.

### `LUA-BACKEND-PARITY.4.3.8` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua recognized `print`, `say`, and `print_each` in its exact 246-name ActionIR
  surface but the interpreter fell through to `unsupported runtime helper`; `exit_now` already terminated through
  a typed runtime error.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` had no output-family dispatcher or per-parse sink. A
  backend audit also found that Perl, Rust, Dart, and Julia agree on recognition but currently disagree on output
  transport and parts of `print_each` formatting; no existing normalization leaf named that drift.
- [x] **FIX** — Added one eager output-family evaluator, a per-parse `diagnostic_sink`, and typed
  `RuntimeDiagnosticOutputEvent` records. Lua follows the Perl reference for arity/formatting, keeps all output
  outside structural parse values, and exposes a seam that `.4.4` can adapt to tracing without changing helpers.
  Added `FUTURE-PARITY-BACKLOG.5.1` for the five-backend contract decision.
- [x] **ADDRESSED (verified)** — One focused rule proves left-to-right one-time argument evaluation, exact
  `pré🙂`/Greek/emoji delivery, boolean/null scalar text, ordered per-item events, optional empty suffix, typed JSON
  projection, no-sink evaluation, invalid sink/arity boundaries, and pre-/post-`exit_now` ordering.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 122/122 under separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI-scaffold, and exact 105-fixture manifest checks. `RuntimeParseResult.value` and
  one-value `output` remain unchanged; `exit_now(23)` retains immediate typed status and suppresses later output.
- [x] **LOCKSTEP** — Lua README/API guidance, helper reference/catalog, mdBook handoff/status, task trees,
  roadmaps, Knowledge Map, architecture/live docs, changes/notes, and memory agree that `.4.3.8` is closed and
  exhaustive helper no-drift `.4.3.9` is next. Cross-backend diagnostic semantics remain explicitly pending `.5.1`.

### `LUA-BACKEND-PARITY.4.3.7.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Every mechanism child was complete, but the parent and public surfaces still
  advertised active capture/cursor work, and the mdBook handoff retained the superseded 239/237-name inventory
  account from before complete named-mark admission.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.4.3.7.6` intentionally owns the exhaustive source/public closeout after all
  behavior leaves. The older handoff prose described the former corpus-seeded reverse check and had not consumed
  `.17.5`'s 246-name inventory plus independent 122-public-contract proof.
- [x] **FIX** — Derived one exact 62-name family from Lua capture/mark, input/cursor, and cursor-control contracts;
  matched it against runtime dispatch and focused execution sources; retained four placement-marker spellings;
  corrected the public inventory account; closed `.4.3.7`; and activated only `.4.3.8`. Generated preservation,
  direct generated execution, subset admission, and capability closeout remain `.8.1-.8.4`.
- [x] **ADDRESSED (verified)** — Contract/runtime/execution-source comparison is 62/62 with zero missing or extra;
  `bash tools/run_lua_local.sh` passes 121/121 on PUC Lua and LuaJIT. The complete-mark checker passes seven calls
  and three mutations; coverage reports 246 names, 105+1 occurrence sources, 0/122 public-contract omissions, and
  zero admitted exclusions; the public selector guard remains 57/27/0.
- [x] **NO REGRESSION** — Punctuation-light proof remains 6 standalone/4 receiver/6 invalid and capability census
  remains 64/0/0. This leaf changes no parser, compiler, runtime, fixture, helper, inventory, generated-source, or
  capability behavior.
- [x] **LOCKSTEP** — Lua API README, mdBook, Knowledge Map, task trees, roadmaps, architecture/live docs, changes,
  development notes, and bounded memory agree that native capture/cursor parity is closed and `.4.3.8` is next.

### `LUA-BACKEND-PARITY.4.3.7.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua's source parser preserved valid split-marker AST nodes, but compiled rules
  exposed no slot events; the first focused run kept all 120 existing tests green while the new test alone failed
  because `rule_slot_events` was absent.
- [x] **ROOT CAUSE (WHY + WHERE)** — `compiled_spec.lua` ignored `SplitMarkerBodyElementKind`, and
  `interpreter.lua` had no post-action slot-event phase. A narrower parser defect also discarded malformed text
  remaining after a valid same-line element, allowing invalid marker fragments to disappear before validation.
- [x] **FIX** — Compile canonical typed capture-boundary/named-mark events against the preceding regex slot,
  preserve them through dependency resolution and public serialization, execute them after action/child dispatch
  and before `LE`, and route writes through the existing anonymous and named stores. Preserve unparsed body
  remainder as a typed raw element so validation rejects malformed authored markers.
- [x] **ADDRESSED (verified)** — One `é(α🙂,βγ)` case proves same-slot reads see old state, later slots see the
  updates, all three anonymous spellings share one event kind, named marks keep Unicode character positions, and
  native/public-source reconstruction agree. Empty, digit-leading, hyphenated, trailing-fragment, and prefix-
  typo markers fail through typed validation; a validation-bypassed malformed AST fails with rule/line/marker
  fields. The exact shipped `rgx/subs/pgen/specs/ebnf.spec::logging_annotation` line owns one executable
  `@move_pos` event at its expected slot.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 121/121 under separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI-scaffold, and 105 manifest checks. Full local CI passes capability 64/0/0, coverage
  246/105+1/122, selector admission 57/27/0, CLI 61/61 twice, phase0 `1..1031` in 633 seconds, and every
  contract/doctrine/documentation gate. The only first-run failure was the selector checker's stale exact public-
  file count after `.18.0` added one mdBook page; raising 56 to the measured 57 restored the existing guard.
- [x] **LOCKSTEP** — No helper, fixture, inventory, generated-source, or capability claim changes. The Lua API,
  mdBook, Knowledge Map, roadmaps, live docs, and both task trees advance only exhaustive capture/cursor no-drift
  `.4.3.7.6`.

### `LUA-BACKEND-PARITY.4.3.7.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua already admitted the full named capture/mark call surface and owned the exact
  seven complete-mark helpers, but the remaining governed named writers, spans, and bridges still fell through.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` restricted its named-mark dispatcher to the staged seven-
  helper family and a few fixture bridges; it lacked shared endpoint classification, two-mark reads, copy/delete,
  anonymous bridges, and the one-argument `capture_take(name)` overload.
- [x] **FIX** — Extended that same rule-label/name/byte-offset store and dispatcher across every governed named
  writer and span. All slices use one guarded byte-span seam, public widths/positions project to Unicode
  characters, and advancing forms mutate only after a valid read.
- [x] **ADDRESSED (verified)** — The unchanged exact named fixture passes native and reconstructed execution. A
  supplemental multibyte case locks both bridges, copy-from-absent deletion, stable reads, valid advancing reads,
  reversed/missing no-op behavior, void writers, overload separation, and typed one-/two-argument diagnostics.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 120/120 under separately built PUC Lua and LuaJIT
  adapters plus syntax, CLI-scaffold, and 105 manifest checks. Full local CI passes capability 64/0/0, coverage
  246/105+1/122, CLI 61/61 twice, phase0 `1..1031` in 637 seconds, and every contract/doctrine/documentation gate.
- [x] **LOCKSTEP** — No helper, fixture, inventory, or capability surface changed. Lua consumes the governed
  shared contract over the `.17.4` store; the mdBook, Knowledge Map, roadmaps, live docs, and task trees advance
  only placement-sensitive marker execution `.4.3.7.4`.

### `LUA-BACKEND-PARITY.4.3.7.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua admitted `capture_until_boundary(...)` and compiled all target rule patterns,
  but its interpreter had no path from symbolic rule arguments to independent lookahead or synchronized movement.
- [x] **ROOT CAUSE (WHY + WHERE)** — Ordinary matching obeys the engine's seek/consume mode and consumes through
  a match; structural boundary capture instead needs a dedicated compiled-alternation cache and unconditional seek
  from the current cursor, followed by movement only to the selected left edge.
- [x] **FIX** — Resolve bare/quoted names, skip unresolved and regex-free targets, cache usable alternations,
  choose the earliest candidate, capture to that edge or EOF, and synchronize live/register cursor state without
  consuming the boundary.
- [x] **ADDRESSED (verified)** — One multibyte test covers consume-mode independence, reversed argument order,
  unresolved interleaving, character cursor values, unconsumed rest, quoted-name receiver continuation, EOF
  fallback, regex-free/all-unresolved no-op, and the tracked zero-argument neutral edge.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 117/117 under separately built PUC Lua and LuaJIT
  PCRE2 adapters plus syntax, CLI-scaffold, and exact 105-fixture manifest checks. Full local CI passes capability
  64/0/0, CLI 61/61 twice, phase0 `1..1031` in 862 seconds, and every contract/doctrine/documentation gate.
- [x] **LOCKSTEP** — Public/KM/live state adds Lua to the existing portable boundary contract without changing
  helper inventory, corpus, generated-source, or capability claims; zero-argument Perl/typed-backend drift is
  routed to `.5`, and the shared named-mark `.17` rollout precedes Lua `.4.3.7.3`.

### `LUA-BACKEND-PARITY.4.3.7.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua admitted all 16 anonymous capture names but dispatched none, despite already
  carrying a rule-local `capture_start_byte` in its immutable match registers.
- [x] **ROOT CAUSE (WHY + WHERE)** — `interpreter.lua` lacked endpoint classification, Unicode projection, and
  valid-only boundary mutation over the existing byte-safe register seam.
- [x] **FIX** — Added exact zero-argument dispatch for the setter, location reads, and stable/length/advancing
  reads to local-match start, live cursor, or input end; invalid spans return null before any mutation.
- [x] **ADDRESSED (verified)** — One multibyte test exercises every name, all three endpoints, Unicode location/
  width values, text/numeric receiver continuation, void setter behavior, six advancing forms, reversed-span
  non-mutation, and typed arity fields.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 116/116 under separately built PUC Lua and LuaJIT
  PCRE2 adapters plus syntax, CLI-scaffold, and exact 105-fixture manifest checks. Full local CI passes capability
  64/0/0, CLI 61/61 twice, phase0 `1..1031` in 766 seconds, and every contract/doctrine/documentation gate.
- [x] **LOCKSTEP** — Public docs now call `start_capture_slice()` void, record the Perl-only result leak under
  `FUTURE-PARITY-BACKLOG.5`, make no named-mark/marker/generated/capability claim, and advance only dependency-
  ready earliest-boundary `.4.3.7.5` while `.17` owns complete named marks.

### `LUA-BACKEND-PARITY.4.3.7.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua admitted all current input/live-cursor and explicit cursor-control names but
  dispatched none of them, and its runtime context had no cursor save stack.
- [x] **ROOT CAUSE (WHY + WHERE)** — `matching.lua` already owned byte-safe immutable registers and Unicode
  conversion, but `interpreter.lua` lacked helper routing plus one synchronized live/register cursor mutation seam.
- [x] **FIX** — Added exact-arity input/cursor dispatch, character-unit whole-input slices and projections, a
  parse-scoped LIFO cursor stack, and synchronized save/restore plus entry/local anchor rewinds.
- [x] **ADDRESSED (verified)** — One focused multibyte test covers all 15 calls, receiver chaining, invalid and
  past-end slices, nested/empty restores, distinct entry/local anchors, typed arity diagnostics, and consume-mode
  continuation after rewind.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes 115/115 under separately built PUC Lua and LuaJIT
  PCRE2 adapters, plus syntax, CLI-scaffold, and exact 105-fixture manifest checks. Full local CI passes capability
  64/0/0, CLI 61/61 twice, phase0 `1..1031` in 918 seconds, and all contract/doctrine/documentation gates.
- [x] **LOCKSTEP** — Lua API/status prose, public backend handoff/status, roadmap/task/index, Knowledge Map fact,
  live docs, changes/notes, and memory advance only anonymous capture-boundary `.4.3.7.2`; no named-mark,
  split-marker, generated-source, or capability claim is made.

### `LUA-BACKEND-PARITY.4.3.7.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The parent combines input/cursor reads, mutable cursor controls, anonymous capture,
  rule-local named marks, placement-sensitive marker members, and compiled-rule boundary lookahead while Lua only
  admits their names and parses marker nodes.
- [x] **ROOT CAUSE (WHY + WHERE)** — These families share byte-offset storage but differ in ownership, mutation
  timing, right-edge selection, Unicode projection, and compiled-rule dependencies, so one implementation leaf
  would hide distinct failure modes and make placement markers look like ordinary helper calls.
- [x] **FIX** — Record the canonical state taxonomy and split cursor/input, anonymous capture, named marks/bridges,
  rule-slot markers, earliest-boundary lookahead, and final no-drift into ordered child leaves `.1` through `.6`.
- [x] **ADDRESSED (verified)** — Contract lowering/runtime sources, governed neutral fixtures, Knowledge Map cards,
  Lua parser/compiler/interpreter seams, and shipped marker usage are all cited in one durable audit fact card.
- [x] **NO REGRESSION** — Planning changes no parser/runtime behavior; memory architecture, task-tree, Knowledge Map,
  book, and focused Lua baseline checks remain green.
- [x] **LOCKSTEP** — Roadmap/task/live/book/KM state agrees that `.4.3.7.1` is next and later capability/generated
  admission remains outside this native helper implementation parent.

### `LUA-BACKEND-PARITY.4.3.6.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Every executable child of `.4.3.6` was complete at 114/114, but the parent and public
  surfaces still advertised an active closeout; `.5.1` was named as the user-function contextual-block handoff
  without carrying that obligation in its own acceptance text.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.4.3.6.6` intentionally owned final no-drift and dependency routing after
  runtime work, so parent/task/live/book status could not close earlier. The broad `.5.1` staged-function wording
  covered calls generally but omitted the final `callback: codeblock` declaration/execution detail.
- [x] **FIX** — Closed `.4.3.6`, made `.5.1` explicitly own spec-owned final codeblock metadata plus equivalent
  attached/parenthesized contextual execution, retained explicit literals/dynamic calls under `.11.7`, preserved
  generated obligations under `.8.1-.8.4`, and advanced only the dependency-ready `.4.3.7` frontier.
- [x] **ADDRESSED (verified)** — `bash tools/run_lua_local.sh` passes 114/114 on PUC Lua and LuaJIT; the callable-
  codeblock checker passes 7 literals, 11 calls, 9 invalid literals, 7 invalid calls, 4 invalid declarations, and
  8 contextual forms; the punctuation-light checker passes 6 standalone, 4 receiver, and 6 excluded forms.
- [x] **NO REGRESSION** — Capability census remains 64/0/0. The immediately preceding mandatory full local CI gate
  passes both primary CLI environments at 61/61 and phase0 `1..1031` in 987 seconds; this leaf changes no parser,
  runtime, fixture, capability, or generated-source behavior.
- [x] **LOCKSTEP** — Catalog/README/mdBook/KM/task/live/roadmap/memory surfaces agree that current built-in blocks
  and callbacks are closed, user-function contextual final blocks remain `.5.1`, explicit callable values remain
  `.11.7`, parenthesis-free condition headers remain excluded, and `.4.3.7` is next.

### `LUA-BACKEND-PARITY.4.3.6.5.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua executed harray-root callbacks but still rejected the same three methods on an
  array receiver; the existing walker was hard-coded to string keys and harray result construction.
- [x] **ROOT CAUSE (WHY + WHERE)** — `evaluate_hash_tree_receiver_block` selected only `json.kind == \"harray\"`,
  bound only `key`, and recursed only through harrays. Array traversal needs ordered Lua offsets translated to
  zero-based `index`, but it does not need cross-kind recursion.
- [x] **FIX** — Generalized the traversal into one receiver-root-kind dispatcher with kind-specific child
  enumeration and result containers, same-kind-only recursion, and a selector binding chosen as `key` or `index`.
- [x] **ADDRESSED (verified)** — The focused array fixture locks zero-based depth-first paths, hashes as leaves,
  copied map/walk/reduce values, outer-frame restoration, empty/invalid laziness, continuation/terminality, and the
  exact checked-in Perl oracle result.
- [x] **NO REGRESSION** — `luac -p` and LuaJIT bytecode compilation pass. `bash tools/run_lua_local.sh` passes
  syntax, corpus/process checks, and 114/114 on both ABIs; the existing sorted harray callback case remains green
  under the shared dispatcher. The mandatory full local CI gate exits 0 with capability 64/0/0, both primary CLI
  environments at 61/61, and phase0 `1..1031` green in 987 seconds.
- [x] **LOCKSTEP** — Public array/hash traversal docs, Lua README/handoff/status, Knowledge Map, task/index/
  roadmaps, live docs, and memory record the root-kind contract and advance to no-drift leaf `.4.3.6.6`.

### `LUA-BACKEND-PARITY.4.3.6.5.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Built-in callback signatures were admitted, but all three traversal receivers still
  failed as unsupported at runtime and the one-name scope helper could not install one atomic callback frame.
- [x] **ROOT CAUSE (WHY + WHERE)** — Fluent dispatch recognized final codeblocks but routed every non-`with`
  contract to the unsupported path. `runtime_scoped_binding.run` only scoped `value`; no deterministic harray
  walker installed copied `value`/`key`/`path`/`depth`/`acc` bindings or consumed callback results.
- [x] **FIX** — Added atomic multi-binding frames and sorted recursive harray walk/map/reduce execution, preserving
  arrays as leaves, root depth 1, mapped/source isolation, walk continuation, and reduce terminality.
- [x] **ADDRESSED (verified)** — The Lua case locks sorted nested and empty trees, typed accumulator flow, copied
  paths/results, persistent non-frame side effects, exact restoration, neutral invalid receivers, typed malformed
  calls, and the exact Perl reference result from a direct `LinkedSpec::Get` probe.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` passes syntax, corpus/process checks, and 113/113 on both
  PUC Lua and LuaJIT; the existing scoped `with` proof still consumes the preserved one-binding API. The mandatory
  full local CI gate exits 0 with capability 64/0/0, both primary CLI environments at 61/61, and phase0
  `1..1031` green in 983 seconds.
- [x] **LOCKSTEP** — Public hash-tree docs, Lua README/handoff/status, Knowledge Map, task/index/roadmaps, live docs,
  and memory record harray closure and the subsequently closed array-root successor `.4.3.6.5.2`.

### `LUA-BACKEND-PARITY.4.3.6.5.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Variadic/current value helpers silently removed a first bare value whenever the
  remainder still met minimum arity; callback `seen += cat(key, "@", depth)` exposed the generic collision.
- [x] **ROOT CAUSE (WHY + WHERE)** — `MethodExpr::_normalize_method_args_with_optional_scope` spent its legacy
  scope heuristic before asking whether the raw authored value list was already valid. The AST and callback frame
  were correct.
- [x] **FIX** — Added opt-in authored-value precedence to the shared normalizer and routed all affected variadic
  scalar helpers, optional-width `substr`, coalesce family inference, and existing collection-value normalization
  through it. Scope stripping remains a fallback for invalid raw counts.
- [x] **ADDRESSED (verified)** — Focused tests cover `cat`, arithmetic folds/min/max, coalescing, substring, the
  original append RHS, and fixed-arity fallback. Hash-tree runtime proof consumes `key`/`depth` in map/reduce/walk.
- [x] **NO REGRESSION** — Module/test syntax and `t/actionir_ast_parser.t` pass. The mandatory full local CI gate
  exits 0 with capability 64/0/0, both primary CLI environments at 61/61, and phase0 `1..1031` green; doctrine,
  book, memory, Knowledge Map, task metadata, and whitespace closeout gates pass before commit.
- [x] **LOCKSTEP** — The helper catalog teaches authored-value precedence and callback examples exercise root 1 /
  nested 2 depth. Lua implementation `.4.3.6.5.1.2` is next.

### `LUA-BACKEND-PARITY.4.3.6.5.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — A direct Perl traversal probe returned correct callback `key` values except when
  `cat(key, ...)` appeared inside an append RHS, where the first value vanished.
- [x] **ROOT CAUSE (WHY + WHERE)** — The typed AST keeps all arguments. `MethodLowering` then sends variadic `cat`
  through `MethodExpr::_normalize_method_args_with_optional_scope`, which strips a first bare identifier whenever
  the remaining count is still valid. Three arguments trigger the collision; two do not.
- [x] **FIX** — Split reference repair `.4.3.6.5.1.1` from Lua scoped harray execution `.4.3.6.5.1.2` before either
  behavior change. Record the exact cause and the executable `depth == count(path)` contract durably.
- [x] **ADDRESSED (verified)** — AST dumps, generated Perl lowering, direct runtime output, and current Perl/Rust
  traversal sources agree on the two findings; task/roadmap/book/KM/live surfaces point at the two new owners.
- [x] **NO REGRESSION** — No runtime, parser, test, fixture, capability, or generated-source behavior changed;
  task metadata, memory, Knowledge Map, doctrines, mdBook build, and whitespace checks pass.
- [x] **LOCKSTEP** — Public depth prose now says root 1/path length; reference repair `.1.1` is the clean frontier
  before Lua implementation `.1.2`.

### `LUA-BACKEND-PARITY.4.3.5.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The current Knowledge Map claimed bare-first `merge_hash(base, overlay)` returned an
  empty result and recommended `copy(hash(base))`; today the exact probe returns `2`, while `hash(base)` rejects.
- [x] **ROOT CAUSE (WHY + WHERE)** — The July 4 fact predated July 12 uniform binding and aggregate-selector
  retirement. Perl now lowers bare merge to `{%base, %overlay}`; the neutral corpus and later backend tests already
  consume bare typed base and overlay values.
- [x] **FIX** — Split this contract leaf before Lua behavior code; replace current merge/composition/receiver/core
  facts and mdBook guidance with bare typed operands, optional `copy(base)`, later-argument override, and removed-
  selector rejection.
- [x] **ADDRESSED (verified)** — Perl toolbox probes, Dart/Julia selected neutral-corpus runs, Rust's 105-case oracle,
  and current focused backend test sources agree on pure transforms, receiver composition, and source isolation.
- [x] **NO REGRESSION** — No runtime code changed; public selector/mutation/capability checks, Knowledge Map,
  mdBook, memory/doctrine, task metadata, and whitespace gates pass.
- [x] **LOCKSTEP** — Task/index/roadmaps, README/book, Knowledge Map facts, architecture/live docs, changes/notes,
  and memory agree that Lua implementation `.4.3.5.3.1` is the sole next leaf.

### `LUA-BACKEND-PARITY.4.3.5.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Revalidated merge/set/rename/drop/pick calls reached Lua's unsupported-helper path;
  no copied transform implementation or hash-returning receiver continuation existed.
- [x] **ROOT CAUSE (WHY + WHERE)** — `PURE_HASH_HELPERS` and `evaluate_hash_helper` contained only flat/views/
  membership. The generic function/receiver evaluator already supplied ordered typed operands and continuation.
- [x] **FIX** — Add copied transform dispatch with sorted deterministic source traversal, later-merge override,
  pure key update/rename/filtering, deep copies, exact wrong-kind/missing boundaries, and receiver reuse.
- [x] **ADDRESSED (verified)** — One end-to-end case covers bare and receiver merge, overlay override, null/nested
  values, pure set/rename/drop/pick, array-view chains, invalid/missing calls, source non-mutation, and deep isolation.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 102/102 plus manifest/CLI scaffolding; selector/mutation/
  capability, Knowledge Map, mdBook, memory/doctrine, cleanup, and whitespace gates pass.
- [x] **LOCKSTEP** — Task/index/roadmaps, root/Lua README, mdBook, Knowledge Map, architecture/live docs,
  changes/notes, and memory close `.4.3.5.3` and activate named mutation `.4.3.5.4`; rename collision drift is
  durably owned by backlog `.5`.

### `LUA-BACKEND-PARITY.4.3.5.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — A dropped standalone `set_key(target, key, value)` reached the pure harray helper,
  returned a copied value that was discarded, and left the named binding unchanged; direct assignment had a
  separate update path.
- [x] **ROOT CAUSE (WHY + WHERE)** — `execute_block` had statement-context handlers for mutable split, regex
  substitution, and dropped array transforms, but no named harray handler or shared harray mutation functions.
- [x] **FIX** — Add kind-checked harray lookup/store helpers, route direct harray assignment through them while
  preserving numeric array-index assignment, and intercept only dropped three-argument `set_key` calls whose
  first argument is a bare target.
- [x] **ADDRESSED (verified)** — One end-to-end case covers existing and absent targets, standalone and direct
  mutation, nested saved-result isolation, pure assigned/function/receiver forms, and scalar/array wrong-kind
  diagnostics with neutral fields.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 103/103 plus manifest/CLI scaffolding; selector/mutation/
  capability, Knowledge Map, mdBook, memory/doctrine, cleanup, and whitespace gates pass.
- [x] **LOCKSTEP** — Task/index/roadmaps, root/Lua README, mdBook, Knowledge Map, architecture/live docs,
  changes/notes, and memory close named mutation `.4.3.5.4` and activate non-callback closeout `.4.3.5.5`.

### `LUA-BACKEND-PARITY.4.3.5.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Construction, views, transforms, and mutation passed in separate slices, but no
  exact ordinary-name inventory or recurring public harray mutation-result guard closed the parent family.
- [x] **ROOT CAUSE (WHY + WHERE)** — `HASH_HELPERS` admits 16 names across constructor, generic typed-value,
  pure harray-dispatch, statement-mutation, and callback mechanisms; behavior tests alone do not prove the public
  summaries or callback delegation remain aligned.
- [x] **FIX** — Inventory the 13 ordinary routes, keep `walk_leaves`/`map_leaves`/`reduce_leaves` delegated, audit
  catalog/reference/README prose, and expand the existing uniform-binding public guard for updated harray
  snapshots and pure receiver `set_key`.
- [x] **ADDRESSED (verified)** — Existing focused cases cover construction/splicing, views, transforms,
  receivers, invalid inputs, nested isolation, absent/wrong-kind mutation, and returned snapshots; the exact
  ordinary/callback split is recorded in the Knowledge Map closeout fact.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 103/103 plus manifest/CLI scaffolding; selector/mutation/
  capability, Knowledge Map, mdBook, memory/doctrine, cleanup, and whitespace gates pass.
- [x] **LOCKSTEP** — Parent `.4.3.5`, task/index/roadmaps, root/Lua README, mdBook, Knowledge Map,
  architecture/live docs, changes/notes, and memory close together; `.4.3.6` is the sole next runtime parent.

### `LUA-BACKEND-PARITY.4.3.6.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Parent `.4.3.6` combined eager values, two control families, contextual calls,
  scoped binding, callbacks, and general user-function wording in one unsafe implementation slice.
- [x] **ROOT CAUSE (WHY + WHERE)** — `action_parser.lua` and the resolver already preserve block/control structure,
  but `interpreter.lua` returns inert block copies and has no control/callback dispatch; function invocation is
  separately absent behind `.5.1`.
- [x] **FIX** — Split eager blocks, inline controls, statement controls, contextual built-ins/`with`, tree
  callbacks, and no-drift; route user-function blocks to `.5.1` and explicit callable values to future `.11.7`.
- [x] **ADDRESSED (verified)** — Source and Knowledge Map audit identifies every parser, resolver, interpreter,
  registry, backend-reference, and callable-contract seam without changing behavior.
- [x] **NO REGRESSION** — Planning only: the dual-ABI runtime remains 103/103 and existing harray/callback
  delegation is unchanged; task/KM/docs/memory/doctrine gates pass.
- [x] **LOCKSTEP** — Task/index/roadmaps, README/book, Knowledge Map, architecture/live docs, changes/notes, and
  memory agree that expression-valued blocks `.4.3.6.1` are the sole next leaf.

### `LUA-BACKEND-PARITY.4.3.6.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua returned inert `block_value` records from ordinary authored braces and even
  expected `callback = { return("later") }` to store one, contradicting the eager block contract.
- [x] **ROOT CAUSE (WHY + WHERE)** — `.4.3.1` added structural four-kind copying before block execution existed;
  `evaluate_expr` therefore used `copy_value(expr)` for every block without distinguishing eager value use from a
  contextual final argument that its callable will later consume.
- [x] **FIX** — Add one eager block evaluator, reuse dropped-statement mutation for non-final statements, evaluate
  the final statement in value context, catch only local return flow, and retain structural parser arguments.
- [x] **ADDRESSED (verified)** — Last values, early aggregate/null returns, skipped writes, mutation, receiver
  chaining, and harray precedence pass; the prior Lua-only assignment expectation is corrected and annotated.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 104/104; Perl toolbox output and focused Rust expression-block
  tests agree; parser, registry, compiler, matching, process, manifest, Knowledge Map, mdBook, and doctrines pass.
- [x] **LOCKSTEP** — Task/index/roadmaps, README/book, Knowledge Map, architecture/live docs, changes/notes, and
  memory close eager blocks and activate lazy inline controls `.4.3.6.2`.

### `LUA-BACKEND-PARITY.4.3.6.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua recognized inline control names but routed them to unsupported eager helper
  dispatch. A Perl toolbox probe also showed that treating `i`/`when` as ordinary value aliases shifts arguments
  through structural-control parsing instead of producing inline `if` semantics.
- [x] **ROOT CAUSE (WHY + WHERE)** — The parser intentionally shares governed names across inline calls,
  marker controls, and attached controls, while `action_contracts.lua` canonicalizes their aliases without
  conferring runtime surface equivalence. `interpreter.lua` had no raw-AST lazy branch seam.
- [x] **FIX** — Validate exact authored inline branch forms before eager dispatch; evaluate conditions/subjects
  once and only selected payloads; preserve literal bare case labels, compound dynamic labels, block-local
  return, false/null, assignment, and fluent-return results; reject structural-only aliases as inline values.
- [x] **ADDRESSED (verified)** — One end-to-end test locks skipped fatal branches, `elseif` and plain fallback,
  reference truthiness, selected blocks, one-time switch side effects, literal/dynamic labels, null fallthrough,
  fluent return, generic arity diagnostics, and alias rejection.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 105/105 plus CLI/corpus scaffolding. The truthiness audit found
  real Perl/Rust/Dart/Julia drift; Lua follows the Perl oracle and `FUTURE-PARITY-BACKLOG.5` owns normalization.
- [x] **LOCKSTEP** — Runtime/tests, task/index/roadmaps, root/Lua README, mdBook, Knowledge Map, live docs,
  changes/notes, and memory close inline controls and activate `.4.3.6.3.1`.

### `LUA-BACKEND-PARITY.4.3.6.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Attached and marker if-family nodes parsed and resolved, but Lua evaluated each as an
  unsupported ActionIR kind; no branch selection, nesting boundary, or orphan diagnostic owner existed.
- [x] **ROOT CAUSE (WHY + WHERE)** — `execute_block` iterated statements independently, while marker chains need a
  nesting-aware range selector and attached chains need consecutive-branch consumption. Perl toolbox probes also
  exposed broader alias-shape acceptance than Rust's portable parser surface.
- [x] **FIX** — Add one shared indexed statement executor for attached and marker branches, lazy ordered condition
  selection, nested `endif` scanning, empty/local-return preservation, the portable alias matrix, and typed
  malformed/orphaned diagnostics before generic expression dispatch.
- [x] **ADDRESSED (verified)** — One end-to-end case covers canonical and portable alias forms, skipped fatal
  conditions/bodies, empty branches, nested marker chains, attached/marker local return, orphan branches/markers,
  missing closure, duplicate/following branches, and attached/marker mixing.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 106/106 plus parser CLI/corpus scaffolding. Perl probes and
  Rust/Dart/Julia source seams establish the extra alias-shape drift; backlog `.5` owns normalization.
- [x] **LOCKSTEP** — Runtime/tests, task/index/roadmaps, root/Lua README, architecture/live docs, mdBook, Knowledge
  Map, changes/notes, and memory close if-family statements and activate switch-family `.4.3.6.3.2`.

### `LUA-BACKEND-PARITY.4.3.6.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua preserved typed attached/marker switch nodes but routed them to unsupported
  ActionIR kinds. Inline switch also collapsed aggregate values to empty text, unlike the Perl reference.
- [x] **ROOT CAUSE (WHY + WHERE)** — Attached branches are nested control bodies; marker branches are sibling
  ranges with optional `endcase` and nested `endswitch` boundaries. The inline evaluator owned its comparison
  locally and used null-as-empty coercion for host tables as well as scalar values.
- [x] **FIX** — Share one literal-label evaluator and scalar switch equality across all three switch forms; add
  attached branch validation plus nesting-aware marker range selection over the indexed statement executor;
  retain typed orphan/missing/duplicate/order/mixed diagnostics.
- [x] **ADDRESSED (verified)** — Focused coverage locks subject-once, bare/dynamic labels, first-match/default,
  skipped fatal candidates/bodies, null/boolean/aggregate comparison, empty branches, nested marker switches,
  local return, skipped marker statements outside branches, and thirteen malformed/orphaned structures; inline
  comparison assertions share the same seam.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 107/107 plus parser CLI/corpus scaffolding. Perl attached/marker
  toolbox probes confirm null/empty, false/zero, and aggregate/non-scalar behavior. Dart/Julia and Rust source
  inspection exposes remaining boolean/aggregate drift, now owned by backlog `.5`.
- [x] **LOCKSTEP** — Runtime/tests, task/index/roadmaps, root/Lua README, architecture/live docs, mdBook, Knowledge
  Map, changes/notes, and memory close switch-family statements and activate attached while `.4.3.6.3.3`.

### `LUA-BACKEND-PARITY.4.3.6.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua preserved typed `control_while` condition/body nodes but routed them to the
  unsupported ActionIR path; bodyless parser-shape nodes could otherwise spend condition side effects.
- [x] **ROOT CAUSE (WHY + WHERE)** — The indexed statement executor did not dispatch `control_while`, and rule
  repetition's `next` flow must be intercepted at the inner loop boundary to reproduce generated Perl semantics.
  Existing `engine.max_iterations` provided the threshold but not the attached-loop check or typed attribution.
- [x] **FIX** — Add one attached while executor that validates first, evaluates condition/body lazily, catches only
  `next` as loop continue, propagates return/error flows, and checks the guard after each condition but before a
  body beyond the limit with typed rule-attributed diagnostics.
- [x] **ADDRESSED (verified)** — Focused coverage locks condition/body order, state visibility, false initial,
  action and expression-block return boundaries, `next` continuation, exact-limit success, next-truthful failure,
  configurable diagnostic fields, and bodyless pre-evaluation rejection.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 108/108 plus parser CLI/corpus scaffolding. Perl lowering and Rust
  source confirm exact-limit recheck; Dart/Julia throw after the final allowed body. Perl continues inner-loop
  `next`, while Rust/Dart/Julia differ; backlog `.5` owns both normalizations.
- [x] **LOCKSTEP** — Runtime/tests, task/index/roadmaps, root/Lua README, architecture/live docs, mdBook, Knowledge
  Map, changes/notes, and memory close statement controls and activate built-in final blocks/scoped with `.4.3.6.4`.

### `LUA-BACKEND-PARITY.4.3.6.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Lua parsed attached and parenthesized final blocks generically, but ordinary
  expression evaluation executed `block_value` eagerly and `with` remained an unsupported runtime helper.
- [x] **ROOT CAUSE (WHY + WHERE)** — `action_contracts.lua` had only a name/family inventory, while
  `interpreter.lua` had no final-parameter metadata or cleanup-safe temporary-binding seam. Runtime dispatch could
  not distinguish a contextual final block from an ordinary eager brace expression.
- [x] **FIX** — Add copied helper/receiver final-codeblock contracts, consume the final raw block only through that
  metadata, execute helper/receiver `with` through one protected scoped-binding module, and reserve the same
  metadata for behavior-owned tree callbacks.
- [x] **ADDRESSED (verified)** — Focused coverage locks attached/parenthesized helper and receiver equivalence,
  zero/one-value forms, evaluation order, nested scope, aggregate copy isolation, result chaining, block-local
  return, absent/prior scalar/array/harray restoration, callback-error cleanup, harray non-promotion, and generic
  malformed arity/type fields.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 112/112 plus parser CLI/corpus scaffolding. Perl toolbox lowering
  and execution probes agree for all six helper/receiver spellings and scoped restoration.
- [x] **LOCKSTEP** — Runtime/tests, task/index/roadmaps, root/Lua README, capability wording, mdBook, Knowledge Map,
  changes/notes, and memory close built-in final blocks/scoped `with` and activate callback-frame/harray traversal
  `.4.3.6.5.1`.

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

### `LUA-BACKEND-PARITY.4.3.5.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Execute count, lexical key order, values-by-key order, null-valued membership,
  wrong-kind/missing inputs, copied nested values, function forms, receiver forms, array continuations, and scalar
  terminal continuations; probe the same invalid boundaries through the Perl toolbox.
- [x] **ROOT CAUSE (WHY + WHERE)** — Lua's copied hash dispatcher admitted only `flat_hash`; no view helpers were
  routed, and one mdBook catalog row still said non-harray `count_keys` returned undef despite the detailed guide,
  Perl reference, Rust, Dart, and Julia all using zero.
- [x] **FIX** — Reuse sorted harray keys for deterministic keys and copied values, add exact count/presence paths,
  bridge returned arrays into array receivers, fence count/membership terminal results, and repair the catalog.
- [x] **ADDRESSED (verified)** — One end-to-end fixture returns `a,b,c`, values in the same key order, counts three
  fields, recognizes a present null field, rejects absent/wrong-kind membership, and preserves pre-mutation copies.
- [x] **NO REGRESSION** — PUC Lua and LuaJIT pass 101/101 plus exact manifest/CLI scaffolding; selector/public,
  capability, Knowledge Map, mdBook, memory, doctrine, cleanup, and whitespace gates pass.
- [x] **LOCKSTEP** — Task/index, roadmaps, root/Lua README, mdBook, Knowledge Map, architecture/live docs,
  changes/notes, and memory close deterministic views `.4.3.5.2` and activate copied transforms `.4.3.5.3`.

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
| `LUA-BACKEND-PARITY.4.3.5.2` | `LUA-BACKEND-PARITY.4.3.5.2 - add Lua deterministic harray views` | Lexical keys, values-by-key, count/membership terminals, copied isolation, and receiver bridges. |
| `LUA-BACKEND-PARITY.4.3.5.3.0` | `LUA-BACKEND-PARITY.4.3.5.3.0 - revalidate harray transform contracts` | Corrects pre-uniform-binding bare-merge guidance and locks the current cross-backend transform contract. |
| `LUA-BACKEND-PARITY.4.3.5.3.1` | `LUA-BACKEND-PARITY.4.3.5.3.1 - add Lua copied harray transforms` | Deep-copied merge/set/rename/drop/pick values, receiver chains, collision routing, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.5.4` | `LUA-BACKEND-PARITY.4.3.5.4 - add Lua named harray mutation` | Shared named set-key/direct harray mutation, copied snapshots, pure-form separation, and neutral wrong-kind proof. |
| `LUA-BACKEND-PARITY.4.3.5.5` | `LUA-BACKEND-PARITY.4.3.5.5 - close Lua harray helper parity` | Exact 13-name ordinary harray inventory, public result guard, parent closure, and callback handoff. |
| `LUA-BACKEND-PARITY.4.3.6.0` | `LUA-BACKEND-PARITY.4.3.6.0 - split Lua block control callback mechanisms` | Parser-ahead runtime work split from general function and callable-value owners. |
| `LUA-BACKEND-PARITY.4.3.6.1` | `LUA-BACKEND-PARITY.4.3.6.1 - execute Lua eager block values` | Last/local-return values, mutation, harray precedence, receiver dispatch, and contextual-block separation. |
| `LUA-BACKEND-PARITY.4.3.6.2` | `LUA-BACKEND-PARITY.4.3.6.2 - execute Lua lazy inline controls` | Selected-only if/switch values, one-time subjects, literal labels, diagnostics, truthiness routing, and fluent return. |
| `LUA-BACKEND-PARITY.4.3.6.5.1.0` | `LUA-BACKEND-PARITY.4.3.6.5.1.0 - split callback append scope repair` | Root cause, separate reference/Lua owners, corrected path-length depth contract, and no behavior change. |
| `LUA-BACKEND-PARITY.4.3.6.5.1.1` | `LUA-BACKEND-PARITY.4.3.6.5.1.1 - preserve authored callback values` | Central authored-value precedence, affected helper repair, callback runtime proof, and Lua handoff. |
| `LUA-BACKEND-PARITY.4.3.6.5.1.2` | `LUA-BACKEND-PARITY.4.3.6.5.1.2 - execute Lua harray callbacks` | Atomic callback frames, sorted copied harray walk/map/reduce, exact Perl result, and array-root handoff. |
| `LUA-BACKEND-PARITY.4.3.6.5.2` | `LUA-BACKEND-PARITY.4.3.6.5.2 - execute Lua array callbacks` | Shared root-kind traversal, zero-based array callbacks, exact Perl result, and no-drift handoff. |
| `LUA-BACKEND-PARITY.4.3.6.6` | `LUA-BACKEND-PARITY.4.3.6.6 - close Lua block control callback parity` | Dual-ABI no-drift, explicit user-function/callable/generated routing, parent closure, and capture/cursor handoff. |
| `LUA-BACKEND-PARITY.4.3.7.0` | `LUA-BACKEND-PARITY.4.3.7.0 - split Lua capture cursor mechanisms` | Source-backed state/timing split, symmetric documented-mark inventory finding, and input/cursor handoff. |
| `LUA-BACKEND-PARITY.4.3.7.1` | `LUA-BACKEND-PARITY.4.3.7.1 - add Lua input cursor controls` | Unicode input/cursor projections, LIFO save/restore, entry/local rewinds, consume continuation, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.7.2` | `LUA-BACKEND-PARITY.4.3.7.2 - add Lua anonymous capture helpers` | Sixteen byte-safe stable/location/advancing calls, Unicode values, valid-only mutation, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.7.5` | `LUA-BACKEND-PARITY.4.3.7.5 - add Lua boundary capture` | Earliest usable rule lookahead, non-consumption, EOF/no-op edges, caching, and dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.7.3` | `LUA-BACKEND-PARITY.4.3.7.3 - execute Lua named mark spans` | Governed rule-local writers/spans/bridges, Unicode projection, valid-only mutation, overload separation, and PUC Lua/LuaJIT proof. |
| `LUA-BACKEND-PARITY.4.3.7.4` | `LUA-BACKEND-PARITY.4.3.7.4 - execute Lua rule slot markers` | Typed post-action split/named-mark events, serialized state, shipped EBNF owner, malformed rejection, and 121/121 dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.7.6` | `LUA-BACKEND-PARITY.4.3.7.6 - close Lua capture cursor parity` | Exact 62-call/four-marker no-drift, 246/105+1/122 admission proof, generated routing, parent closure, and diagnostic-helper handoff. |
| `LUA-BACKEND-PARITY.4.3.8` | `LUA-BACKEND-PARITY.4.3.8 - add Lua diagnostic output events` | Eager typed caller-owned events, quiet default, Unicode/order, parse-result neutrality, exit retention, and 122/122 dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.9.0` | `LUA-BACKEND-PARITY.4.3.9.0 - split Lua exhaustive helper closeout` | Exact 230/16/13/3 probe partition, logical repair/admission split, and Perl-lowering future owner. |
| `LUA-BACKEND-PARITY.4.3.9.1` | `LUA-BACKEND-PARITY.4.3.9.1 - execute Lua eager logical helpers` | Eager ordered boolean composition, empty false/false/true, governed truthiness, and 123/123 dual-ABI proof. |
| `LUA-BACKEND-PARITY.4.3.9.2` | `LUA-BACKEND-PARITY.4.3.9.2 - close Lua runtime helper no drift` | Permanent exact 233+13 partition, direct-call proof, public-status correction, audit-note correction, and parent closure. |
| `LUA-BACKEND-PARITY.4.4.0` | `LUA-BACKEND-PARITY.4.4.0 - split Lua diagnostics trace controls` | Dependency-correct structured-diagnostic, controls/sinks, runtime-event, closeout, and later full-pipeline split. |
| `LUA-BACKEND-PARITY.4.4.1` | `LUA-BACKEND-PARITY.4.4.1 - add Lua runtime diagnostics` | Neutral typed payloads, optional source identity, deepest-rule preservation, deterministic JSON, and 126/126 proof. |
| `LUA-BACKEND-PARITY.4.4.2` | `LUA-BACKEND-PARITY.4.4.2 - add Lua trace controls` | Typed levels/config/events, documented environment controls, caller-owned sinks, reset/append, and 128/128 result-neutral proof. |
| `LUA-BACKEND-PARITY.4.4.3` | `LUA-BACKEND-PARITY.4.4.3 - instrument Lua runtime trace` | Balanced rule scopes plus exact regex/dispatch/recursion/lifecycle/cursor/boundary/mark-capture events and 129/129 dual-ABI identity proof. |
| `LUA-BACKEND-PARITY.4.4.4` | `LUA-BACKEND-PARITY.4.4.4 - close Lua diagnostics trace no drift` | Exact API/source/test/public-doc inventory, parent `.4.4` closure, 129/129 dual-ABI proof, and `.5.1` handoff. |
| `LUA-BACKEND-PARITY.5.1.0` | `LUA-BACKEND-PARITY.5.1.0 - split Lua staged function execution` | Dependency-correct staged/fixed/variadic/contextual-codeblock/no-drift leaves with explicit later boundaries retained. |
| `LUA-BACKEND-PARITY.5.1.1` | `LUA-BACKEND-PARITY.5.1.1 - add Lua staged body dispatch` | Stable typed job queue, governed ActionIR provider/cache identity, immutable body stitching, typed fences, and 130/130 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.1.2` | `LUA-BACKEND-PARITY.5.1.2 - execute Lua fixed user functions` | Registry-first calls, staged-AST authority, isolated local execution, value composition, typed fences, and 133/133 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.1.3.1` | `LUA-BACKEND-PARITY.5.1.3.1 - preserve Lua variadic signatures` | Exact v1/v2 union, signature identity, minimum/unbounded registry resolution, later-boundary fences, and 136/136 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.1.3.2` | `LUA-BACKEND-PARITY.5.1.3.2 - execute Lua variadic functions` | Eager ordered arguments, fresh copied mixed/empty rest arrays, exact neutral fixture, typed failures, and 139/139 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.1.4.1` | `LUA-BACKEND-PARITY.5.1.4.1 - preserve Lua final codeblock metadata` | Exact final-only metadata, four invalid declarations, contextual normalization, harray non-promotion, and 142/142 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.1.4.2` | `LUA-BACKEND-PARITY.5.1.4.2 - execute Lua contextual codeblocks` | Dynamic current-frame invocation, restoration, static precedence, chainable values, typed failures, and 146/146 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.1.5` | `LUA-BACKEND-PARITY.5.1.5 - close Lua staged functions no drift` | Exact API/status/test/public-doc/KM audit, stale README correction, parent `.5.1` closure, and `.5.2` activation. |
| `LUA-BACKEND-PARITY.5.2.0` | `LUA-BACKEND-PARITY.5.2.0 - split Lua native spec loading` | ADR/fixture/backend/Lua audit, successful spec-owned definition-parser probe, and dependency-correct four-leaf implementation split. |
| `LUA-BACKEND-PARITY.5.2.1` | `LUA-BACKEND-PARITY.5.2.1 - add Lua native spec loading` | Typed requests/options/results/errors, native file-kind inspection, deterministic candidates, strict UTF-8, direct 14/9/4 dual-ABI proof, and automatic-function-parser handoff. |
| `LUA-BACKEND-PARITY.5.2.2` | `LUA-BACKEND-PARITY.5.2.2 - automate Lua function parsing` | Module-relative bundled grammar, one-time native compile, typed in-process execution, Unicode projection/body dispatch, typed failure ownership, and no raw scanner. |
| `LUA-BACKEND-PARITY.5.2.3` | `LUA-BACKEND-PARITY.5.2.3 - compose Lua native spec pipeline` | Typed loaded/compiled result, exact source identity, neutral parse/validate/compile errors, identified engines, and loaded function execution. |
| `LUA-BACKEND-PARITY.5.2.4` | `LUA-BACKEND-PARITY.5.2.4 - close Lua native loading no drift` | Exact source/export/test/public-doc/Knowledge-Map inventory, parent `.5.2` closure, and descriptor/full-trace `.5.3` handoff. |
| `LUA-BACKEND-PARITY.5.3.0` | `LUA-BACKEND-PARITY.5.3.0 - split Lua descriptor trace admission` | Exact schema/fence/trace/census/history audit, durable conflict record, and decision/descriptor/trace/admission split. |
| `LUA-BACKEND-PARITY.5.3.0.1` | `LUA-BACKEND-PARITY.5.3.0.1 - settle descriptor and census policy` | ADR `0041` exact final-codeblock-v3 record plus completion-time all-pass Lua census admission. |
| `LUA-BACKEND-PARITY.5.3.1` | `LUA-BACKEND-PARITY.5.3.1 - admit Lua function descriptors` | Checked exact fixed-v1/variadic-v2/final-codeblock-v3 union, dual-ABI Lua emission, and Perl outward-v3 alignment. |
| `LUA-BACKEND-PARITY.5.3.2` | `LUA-BACKEND-PARITY.5.3.2 - propagate Lua full-pipeline trace` | One caller-owned emitter across IO/frontend/compiler/function/staged/engine/runtime, exact filters/sinks/errors/identity, and 155/155 dual-ABI proof. |
| `LUA-BACKEND-PARITY.5.3.3` | `LUA-BACKEND-PARITY.5.3.3 - close Lua descriptor trace no drift` | Exact API/status/test/contract/book/KM inventory, parent `.5.3`/`.5` closure, unchanged 64/0/0 census, and corpus `.6.1` handoff. |
| `LUA-BACKEND-PARITY.6.1.0` | `LUA-BACKEND-PARITY.6.1.0 - split Lua controlled corpus admission` | Exact 0-39/99-104 dual-ABI measurement, sole nested-segment mismatch classification, and dependency-ordered repair/executor/window split. |
| `LUA-BACKEND-PARITY.6.1.1` | `LUA-BACKEND-PARITY.6.1.1 - preserve Lua nested path segment kinds` | Typed key/index traversal, governed evaluation order, atomic failed writes, exact offset 20, and dual-ABI 46/46 handoff. |
| `LUA-BACKEND-PARITY.6.1.2` | `LUA-BACKEND-PARITY.6.1.2 - add Lua library corpus execution` | Full validation before selection, automatic native pipeline, wrapped structural comparison, typed non-aborting records, and 160/160 dual-ABI controlled proof. |
| `LUA-BACKEND-PARITY.6.1.3` | `LUA-BACKEND-PARITY.6.1.3 - admit Lua core corpus prefix` | Permanent exact offsets 0-39, 40/40 ordered wrapped outputs, endpoint 1/1, and 161/161 dual-ABI proof. |
| `LUA-BACKEND-PARITY.6.1.4` | `LUA-BACKEND-PARITY.6.1.4 - admit Lua capability corpus window` | Permanent exact offsets 99-104, six governed names/wrapped outputs/endpoints, 162/162 dual-ABI proof, parent `.6.1` closure, and `.6.2` handoff. |
| `LUA-BACKEND-PARITY.6.2.0` | `LUA-BACKEND-PARITY.6.2.0 - split Lua advanced corpus residuals` | Exact dual-ABI 50/59 measurement, nine routed residuals, four toolbox-proven current mechanisms, and dependency-ordered repair/remeasure/admission split. |
