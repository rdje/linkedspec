  from `terse_2_2_6_2_attached_while_blocks` through `lib_reader_cattribute`, 59 passes, zero failures, and true
  status. Therefore no speculative repair child is warranted; `.6.2.6` can add the recurring relationship gate
  without behavior changes. The full Lua gate remains 165/165 per ABI; source/tests/oracles/status/census are
  unchanged. Mutation testing was not run. Canonical local CI exits 0 with CLI 61/61 in both environments and
  Phase 0 `1..1031` in 622 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.2.4` — public-entry initialization belongs before the top rule, not inside
  indexed reads): Perl's history result comes from its public parser wrapper skipping complete leading blank and
  comment lines; direct generated handlers deliberately bypass that seam, and `payload[1]` remains a valid read.
  Mirror the wrapper once after UTF-8 validation, using the existing live-cursor mutator so byte cursor and match
  registers change atomically while character positions remain derived from the original input. Recognize only a
  whole blank line or spaces/tabs plus `#` comment through newline/EOF; do not trim ordinary leading whitespace or
  content. Unicode offsets, EOF comments, the ordinary-content boundary, indexed reads, and the history shape pass
  165/165 on both Lua ABIs; unchanged `ds_vhistory_version_entry` ends at 62 and exact offsets 40-98 reach 59/59.
  Mutation testing was not run. Canonical local CI exits 0 with CLI 61/61 in both environments and Phase 0
  `1..1031` in 644 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.2.3` — list context is authored syntax, not an aggregate-shape guess): Hash
  construction must decide whether an array is a sequence of key/value tokens from the argument expression that
  produced it. Add `flat_array` to the same direct-call/terminal-receiver classifier as `flat` and `flat_hash`,
  then reuse the existing recursive copy path. Do not splice every runtime array: `hash("payload", pairs)` must
  retain `pairs` as one copied value. This one expression-shape correction makes empty `flat_array(defs)` add zero
  tokens instead of one table-address key, so unchanged `pplugin_empty` returns `[{}]`. Both Lua ABIs pass 164/164
  and exact offsets 40-98 reach 58/59 with only the pre-owned leading-trivia compare remaining. Mutation testing
  was not run. Canonical local CI exits 0 with CLI 61/61 in both environments and Phase 0 `1..1031` in 634
  seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.2.2` — receiver links must consume the carried value, not reconstruct a call):
  Fluent evaluation already spends receiver evaluation once and stores the result in `value`; each receiver-aware
  link must transform that value. Letting `.copy()` fall through to `evaluate_call(copy, no_args)` silently changes
  method semantics into function semantics and discards the receiver. Classify only zero-argument receiver copy,
  deep-copy the current typed value, and let subsequent helper-family dispatch use the preserved runtime kind.
  Prove nested isolation and one-time evaluation separately from the corpus result. Both Lua ABIs pass 164/164;
  exact offsets 40-98 reach 57/59 and only two pre-owned compares remain. Canonical local CI exits 0 with CLI
  61/61 in both environments and Phase 0 `1..1031` in 628 seconds. Mutation testing was not run.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.2.1` — an action edge owns one child result, including no-result terminals):
  Treat `call(target)` as a request against the current edge when its label matches; the edge state—not the helper
  spelling—owns dispatch count, target index, cached value, and `retv`. Keep unrelated calls direct. A passive
  terminal is structural: no lifecycle, action, blind, or plain payload. Its dependency regex was already consumed
  by the parent, so re-entering its default rule is not harmless—it can seek across later input. EBNF exposed this
  vividly when `whitespace` jumped from cursor 8 to 40 and erased every body token. Trace both rule entries and
  child-dispatch decisions; a null result still needs a separate dispatched boolean. PUC Lua and LuaJIT pass
  163/163, and exact offsets 40-98 move from 50/59 to 56/59 with six unchanged fixtures closed. Canonical local CI
  exits 0 with CLI 61/61 in both environments and Phase 0 `1..1031` in 634 seconds. Mutation testing was not run.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.2.0` — use cross-language disagreement as a mechanism detector): Exact
  offsets 40-98 are already 50/59 on both Lua ABIs; the value lies in the nine disagreements. Trace first: a child
  entered twice is stronger evidence than an output diff. Then compare the emitted canonical Perl handler: it
  distinguishes one selected-edge invocation from Lua's direct `call(child)` plus fallback dispatch. Keep the
  independent boundaries separate—receiver `.copy()` must carry its current value, `flat_array` must be an
  explicit hash splice, and public parse must mirror leading-trivia initialization. Repair those four mechanisms
  independently, then remeasure before assuming Julia's later statement-mutation residual also exists in Lua.
  No production/test/oracle/status/census change occurs in this planning slice. Both Lua ABIs remain 162/162;
  canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 629 seconds. Mutation testing was not run.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.1.4` — lock endpoints per governed fixture, not per window): Corpus windows
  can share pass/output semantics without sharing cursor length. The core prefix happens to end at endpoint 1 for
  every case, but the six governed capability fixtures end at `2,1,2,1,5,5`. Measure through the production
  executor and assert each manifest relationship explicitly; do not generalize the prior window's uniform value.
  Exact names, wrapped outputs, endpoints, public exports/status/CLI boundaries, coverage 246/105+1/122, and census
  64/0/0 now agree at 162/162 on both Lua ABIs. Parent `.6.1` closes and `.6.2` owns offsets 40-98. Mutation
  testing was not run. Canonical local CI exits 0 with CLI 61x2 and Phase 0 `1..1031` passing in 651 seconds;
  total gate time was 1,328.76 seconds under concurrent load.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.1.3` — make corpus admission a manifest relationship, not 40 copied values):
  Select exact offsets 0-39 through the production executor, assert the manifest's first/last/order, then compare
  each retained actual output structurally to one wrapping of that same result's copied expected JSON. This locks
  every fixture without duplicating large expected payloads in Lua test source. Endpoint measurement is uniform
  and semantic here: all 40 match at byte and character endpoint 1, so assert both fields for every record. The
  permanent proof raises each ABI suite to 161/161 and changes no runtime or corpus data; `.6.1.4` owns the separate
  governed capability window and no-drift closure. Canonical local CI exits 0 with CLI 61x2 and Phase 0
  `1..1031` passing in 640 seconds; total gate time was 1,316.33 seconds under concurrent build load, so future
  complete-gate invocations should allow at least 30 minutes even though Phase 0 itself retains its 20-minute
  timeout guidance. Mutation testing was not run.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.1.2` — make failure evidence a library value, not batch control flow): The
  corpus executor validates the whole persisted contract before selection, then owns exactly one native
  parse→validate→compile→identified-engine→runtime route. Expected output is structurally compared as one wrapped
  typed JSON value; encoding text is diagnostic presentation, never equality. Each fixture gets a fresh silent
  emitter when tracing is requested. Preserve actual value/output, match, byte/character endpoints, trace,
  diagnostic, and stage even when comparison fails, and catch fixture-local failures so a later case proves the
  batch did not abort. Manifest/selection failures still raise because there is no valid execution set. This
  separation lets `.6.1.3+` add permanent windows without duplicating pipeline orchestration or promoting the
  validation-only CLI early. Controlled proof passes 160/160 on PUC Lua and LuaJIT; mutation testing was not run.
  Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 623 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.1.1` — retain syntax kind and evaluation order at the runtime boundary):
  Evaluated path values do not contain enough information to choose a container. Preserve the parser's `key`/
  `index` tag until each transition: keys require harrays, indices require arrays, and normalized indices must be
  finite nonnegative integers. Assignment ordering is equally semantic: evaluate every segment expression, then
  the RHS, before root/path validation; mutate a deep copy and store it only on full success. Do not use Lua's
  `and`/`or` selection idiom when the valid value may be `false`, because it collapses stored false to the fallback.
  These rules close exact corpus offset 20 and both owned windows at 46/46 on PUC Lua and LuaJIT while focused
  suites pass 157/157. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 619 seconds. No oracle, parser,
  status, census, or corpus ownership changes; `.6.1.2` is active.

- 2026-07-15 (`LUA-BACKEND-PARITY.6.1.0` — preserve path syntax kinds through runtime mutation): A mixed nested
  lvalue is not just a list of evaluated keys. Its parsed segment kind carries the container requirement: `[0]`
  selects an array element, while `["name"]` selects a hash field. Lua's core read/write helpers intentionally
  accept both container kinds, but `assign_nested_access` cannot erase segment provenance before choosing them;
  doing so turns a wrong-shape numeric transition into a valid hash key `"0"`. The controlled/core probe exposes
  exactly that defect at manifest offset 20 and no other one: both Lua ABIs pass 45/46 across offsets 0-39 and
  99-104. Keep the oracle unchanged, repair segment-kind enforcement in `.6.1.1`, then add reusable executor
  composition `.6.1.2` and permanent core/capability windows `.6.1.3-.4`. This planning slice changes no runtime,
  fixture, public status, test count, or census row. Focused Lua remains 155/155 on both ABIs and canonical CI
  passes CLI 61x2 plus Phase 0 `1..1031` in 606 seconds; mutation testing was not run.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.3.3` — implementation proof and census admission are separate boundaries):
  Close descriptor/full-trace implementation when exact API/status/test/contract/book/KM surfaces agree, but do
  not add Lua rows to the executable capability census early. The manifest is an all-pass admission surface, not
  an incremental progress ledger; ADR `0041` therefore keeps its 16 capabilities at four-backend 64/0/0 until
  `.8.4` can admit Lua after native, corpus, primary CLI, generated-source, and generated-subset proof all pass.
  Current no-drift confirms caller-owned tracing and exact v1/v2/v3 descriptors at 155/155 on both Lua ABIs with
  no source/status/behavior/test/manifest change, closes parents `.5.3`/`.5`, and hands off to corpus `.6.1`.
  Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 611 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.3.2` — pass trace identity; do not retain trace state): The full native Lua
  pipeline uses one optional caller-created `LinkedSpecTraceEmitter` in existing options tables. Load options carry
  it through resolution and compile; inline parser/validator/compiler/function/staged APIs accept the same field;
  engine creation observes it but does not store it; runtime receives it explicitly again. This keeps sink lifetime
  and ownership visible and prevents compiled artifacts from acquiring mutable diagnostic state. High scopes own
  phase balance, medium decisions own candidate/cache/definition/rule/job choices, and existing debug runtime
  events remain unchanged. `trace_support.run` is the sole local success/failure balancing helper and rethrows the
  original error object after an error exit. Direct pre-change proof measured 0 events after load/compile and engine
  creation versus 5 beginning at runtime; post-change exact routed order, filters, typed error/result neutrality,
  and no hidden factory calls pass 155/155 on PUC Lua and LuaJIT. Status is
  `native-full-pipeline-trace-v1`; census expansion remains `.8.4`, not this implementation slice. Canonical local
  CI passes CLI 61x2 plus Phase 0 `1..1031` in 608 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.3.1` — project public function records from one checked union): Keep internal
  typed definition versions independent from outward record versions. Lua's registry decides outward v1/v2/v3
  from exact stored metadata: no signature/no parameter kind is fixed-v1, a callable signature is variadic-v2,
  and final-only `parameter_kinds` is fixed final-codeblock-v3. Construct the shared provenance/body suffix once,
  then add only the selected variant's parameter fields. The neutral checker owns field order, version, storage,
  and final-only codeblock policy, so backend tests consume the contract rather than duplicating Lua record lists.
  Perl already exposed the v3 fields; change only its outward projection label from 1 to 3. This leaves internal
  parsing/runtime records, generic callable-codeblock capability, and census membership unchanged. Both Lua ABIs
  pass 153/153; focused signature/codeblock checkers and 76 Perl tests pass. Full-pipeline trace `.5.3.2` is next.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.3.0.1` — evolve exact public records by version, not optional drift):
  Preserve fixed-v1 and variadic-v2 byte/schema identity. Represent a fixed function with final
  `name: codeblock` intent as outward version 3: the fixed `params`/`arity` pair followed by an exact one-entry
  `parameter_kinds` object for the final parameter. Make `.5.3.1` add this to the neutral executable
  contract/checker before changing Lua emission; do not use the Lua leaf to promote generic callable-codeblock
  capability or pull unrelated backend runtimes forward. Keep the capability census an admitted-backend surface,
  not a progress ledger: `.5.3.3` preserves its four all-pass backends and `.8.4` alone adds Lua all-pass. The
  decision changes no behavior or emitted record. Artifact cleanup used `cargo clean`, removed `dart/.dart_tool`,
  and deinitialized eight clean nested pgen stimulus submodule working trees; the latter are restorable with
  `git -C rgx/subs/pgen submodule update --init --recursive`. Preserve the unrelated pre-existing pgen source and
  generated-tree changes.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.3.0` — a backend may implement a contract only after the neutral record exists):
  The Lua descriptor code is straightforward for fixed-v1 and variadic-v2 because their outward record keys are
  exact. Final-codeblock definitions are different: `parameter_kinds` is preserved through every native state and
  ADR `0032` requires descriptor preservation, but no neutral outward record version says where that metadata
  belongs. A Lua-only extra field would be divergence disguised as progress, so retain the explicit fence until
  the shared policy is settled. The same audit found temporal policy drift: the initial `.5.3` immediate-census
  sentence predates `4a2adda9`, which made the census an admitted-full-backend surface and kept Lua outside until
  completion. Runtime trace mechanics are not blocked—the existing caller emitter is reusable—but all earlier
  parse/validate/compile/function/staged/loading APIs need explicit optional propagation. Split decision,
  descriptor, trace, and admission into `.5.3.0.1-.3`; change no behavior while the two policy choices await the
  director. Both Lua ABIs remain 153/153 and canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 605
  seconds. Mutation campaigns remain manual-only and no mutation command ran.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.2.4` — close composition by inventory, not another adapter): Treat native
  loading as the complete dependency chain from request policy through exact text, spec-owned function parsing,
  validation/compile, and source-identified engine construction. The closeout should prove exports, typed state,
  exact errors, runtime identity, focused tests, neutral fixtures, public docs, and later-owner fences agree; it
  should not add a second loading path. The inventory finds no missing seam. Both ABIs remain 153/153, native
  14/9/4, capability 64/0/0, coverage 246/105+1/122, and public 58/27/0 are green. Parent `.5.2` closes without a
  behavior/status/capability change and `.5.3` becomes the one owner for outward descriptors and full-pipeline
  trace. Canonical local CI passes both 61/61 CLI environments and Phase 0 `1..1031` in 607 seconds. Generated
  source, corpus execution, and the parser CLI remain later; mutation campaigns stay manual-only.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.2.3` — compose policy, do not duplicate the pipeline): Keep filesystem policy
  in `spec_loader.lua` and function syntax in the cached `user_function_definition.spec` adapter. The complete
  file path should simply call those owners, validate their composed typed AST once, compile with validation
  disabled, and retain both the original loaded record and native compiled state. Lazily require the function
  parser inside the operation because it already uses `spec_loader` for its bundled grammar; this avoids an eager
  module cycle without changing semantic dependencies. Engine creation copies options and makes resolved request
  identity authoritative—logical name for named requests only, resolved path always. Translate failures only at
  parse/validate/compile boundaries; do not flatten earlier loader errors or later runtime diagnostics. Both ABIs
  pass 153/153 with status `native-spec-pipeline-v1`; canonical local CI passes both 61/61 CLI environments and
  Phase 0 `1..1031` in 616 seconds. `.5.2.4` owns no-drift and mutation campaigns stay manual-only.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.21.0` — separate normative semantics from variant implementation guidance):
  Use one backend-neutral mdBook as the only portable contract and five optional implementation companions for
  host-specific how/operation material. Avoid both bad extremes: do not dilute the neutral book with every ABI,
  toolchain, cache, and deployment detail; do not clone the neutral manual five times. Start with a read-only
  retain/move/link/remove inventory, establish shared structure plus independent-build/link/canonical-owner/drift
  gates, then populate each backend. Dependency-gate implementation on full current parity so incomplete Lua state
  is not fossilized. ADR `0040` and `BACKEND-COMPANION-BOOKS` own the future work; no scaffold exists now.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.2.2` — make the spec-owned grammar executable infrastructure, not duplicated
  syntax): Resolve the internal function grammar from the Lua module location with an empty root list, then reuse
  the ordinary parse/validate/compile/runtime stack. Cache only a successful compiled parser; execute it anew over
  each caller source and pass only its normalized typed nodes into the already-verified Unicode projector and
  staged body dispatcher. This keeps `user_function_definition.spec` the sole syntax owner and makes the automatic
  path a thin composition layer. Preserve existing typed source/projection/staged errors rather than flattening
  them into the adapter error. PUC Lua and LuaJIT pass 151/151 with status
  `native-spec-defined-functions-v1`; `.5.2.3` owns loaded-source compile/engine identity, and mutation campaigns
  remain manual-only. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 631 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.2.1` — keep filesystem facts native and resolution policy in Lua): Represent
  portable name versus exact host path as typed Lua request values, and keep candidate construction/order,
  deduplication, error attribution, byte loading, and UTF-8 policy in the Lua module. Isolate only the one fact Lua
  cannot determine portably without shelling out—regular file versus non-regular versus missing/error—behind a
  tiny `stat`-based native module built separately for both ABIs. This preserves in-process behavior without
  letting platform APIs own product policy. Consume the shared 14/9/4 fixture directly, supplement Unicode/path
  boundaries, and stop before source parsing so automatic spec-owned function-shell execution remains one focused
  `.5.2.2` dependency. PUC Lua and LuaJIT pass 149/149; status is `native-spec-resolution-loading-v1`, capability
  remains 64/0/0, and mutation campaigns remain manual-only. Adding the public API chapter deliberately advances
  the discovered aggregate-selector no-drift inventory from 57 to 58 files without changing its 27 historical/0
  current selector counts. Canonical CI passes CLI 61x2 plus Phase 0 `1..1031` in 1,265 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.2.0` — filesystem policy, spec-language parsing, and compiled identity are
  separate mechanisms): Implement ADR `0026` through a narrow resolver/byte-loader first; it can consume all
  14/9/4 cases without parsing source. Then make Lua run the existing spec-owned function-shell grammar and feed
  only its typed output into the existing projector/body dispatcher. Only after both are green should the public
  loader compose parse, validation, compile, and identity-bearing engine creation. A direct native probe proves
  the current runtime can already execute `specs/user_function_definition.spec` and return the exact `fn zero()`
  node, so no raw scanner or host-language grammar is justified. Close public no-drift last. Full-pipeline trace
  remains `.5.3`; generated/corpus/CLI remain later. No behavior changes; both ABIs remain 146/146, the native
  checker passes 14/9/4, capability stays 64/0/0, and mutation campaigns remain manual-only.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.5` — close by ownership inventory, not another runtime path): Audit the
  staged-function surface as one dependency chain: spec-owned shell -> typed payload/job -> deterministic staged
  provider/stitching -> immutable registry/frame -> fixed/variadic/contextual execution -> public status/tests.
  Once every seam has a focused owner, correct narrative residue and close the parent without inventing another
  integration layer. Preserve the remaining boundaries precisely: `.5.2` loads portable names/paths into the
  existing in-memory pipeline; `.5.3` owns outward descriptors and full-pipeline trace; `.8` owns generated Lua;
  `.11.7` owns explicit literals/general dynamic calls. The audit changes no behavior; both ABIs remain 146/146
  with status `runtime-user-functions-contextual-codeblock-v1`. Mutation campaigns remain manual-only. Canonical
  local CI passes CLI 61x2 plus Phase 0 `1..1031` in 644 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.4.2` — contextual blocks are data until the declared slot invokes them):
  Normalize registered calls before ordinary argument evaluation so a contextual block is copied as an inert
  `codeblock_argument`, not eagerly collapsed to its result. Install the definition's exact `parameter_kinds`
  beside the isolated function stores; after registered functions and governed helpers have had static precedence,
  a call to that declared slot evaluates the stored block with the current function frame. This gives the block
  dynamic access to function parameters and lets nonparameter writes feed later statements without leaking either
  category back into the outer caller. Reuse the existing protected function boundary for cleanup, and keep a
  separate active callback stack for typed zero-arity and recursion diagnostics. Do not generalize this narrow
  metadata-governed path into explicit literals or arbitrary dynamic calls. Both ABIs pass 146/146; status is
  `runtime-user-functions-contextual-codeblock-v1`, capability stays 64/0/0, descriptors remain `.5.3`, generated
  source remains `.8`, and no-drift `.5.1.5` is next. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031`
  in 622 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.4.1` — preserve callable intent before callback execution): Treat the
  spec-owned codeblock definition shape as an input form, not a second runtime schema. Canonicalize its
  `fixed_params` and final `codeblock_param` once into ordinary ordered params plus an exact one-entry
  `parameter_kinds` object, then require identical metadata in the payload, parse job, typed AST, registry, and
  compiled snapshot. Derive contextual normalization from callable metadata: attached and parenthesized
  `block_value` arguments become copied `codeblock_argument` nodes with a zero-positional signature, while harray
  literals remain structurally unchanged. Keep execution out of this slice so `.5.1.4.2` can add dynamic-context
  invocation and cleanup as one focused runtime change. Both ABIs pass 142/142; status is
  `runtime-user-functions-contextual-codeblock-metadata-v1`, capability stays 64/0/0, descriptors remain `.5.3`,
  and generated source remains `.8`. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 605 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.3.2` — rest is a LinkedSpec value, never a Lua vararg): Preserve caller-side
  eager evaluation and the existing isolated function frame. Copy all evaluated values into `frame.arguments`,
  bind the fixed prefix through the ordinary scalar/array/harray mirrors, then build a new `json.array()` and copy
  each extra again before binding the rest name. That second boundary makes the rest value independent from caller
  inputs, the diagnostic frame, and every later invocation—including the empty case—without host `...`, closure,
  or splat semantics. The existing ActionIR body evaluator then handles return composition and receiver chains
  unchanged. Lock the exact neutral fixture plus supplemental ordered side effects, nested mutations, codeblock
  identity, minimum arity, and keyword failures. Both ABIs pass 139/139; status is
  `runtime-user-functions-variadic-v2`, capability stays 64/0/0, descriptors remain `.5.3`, and generated source
  remains `.8`. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 621 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.3.1` — preserve semantic variadicity before executing it): Keep the neutral
  version switch exact at every Lua boundary. Fixed-v1 JSON owns top-level `params`/`arity` and forbids a signature;
  variadic-v2 JSON owns only its six-field `callable_signature` and forbids legacy top-level or staged fields.
  Derive the typed runtime positional mirror from the signature, then require shell sidecars, staged copies, and
  compiled records to remain identical. Resolve v2 calls by their minimum and unbounded maximum and carry
  human-readable `at least N` expectations through call contracts. Do not fake partial runtime support: variadic
  execution and descriptor conversion fail closed until `.5.1.3.2` and `.5.3`; generated source remains `.8`.
  Both Lua ABIs pass 136/136, the neutral callable checker remains 3 definitions/9 calls/7 invalid definitions,
  status is `runtime-user-functions-variadic-v2-state`, and capability remains 64/0/0. Canonical local CI passes
  CLI 61x2 plus Phase 0 `1..1031` in 620 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.2` — make staged bodies executable without leaking caller state): Resolve
  raw registered names before helper canonicalization, but keep argument evaluation in the caller and frame
  preparation in `user_function_registry.lua`. Install only copied scalar/array/harray stores plus the active-name
  path, run the existing block-value evaluator with a fresh result accumulator, and restore all four context fields
  after one protected call. This naturally supports nested nonrecursive calls, final/local-return values, discard
  statements, and receiver continuation without a second function-body interpreter. Treat neutral `body_ast` as
  authority even though the evaluator needs typed nodes: reparse governed `body_source`, require exact canonical
  JSON equality, and cache only the verified pair. Reject registered keywords before evaluating any argument; keep
  arity and recursion in the registry so runtime failures preserve one portable owner. Both Lua ABIs pass 133/133;
  status is `runtime-user-functions-fixed-v1`, and `.5.1.3.1` owns the separate variadic-v2 schema change.
  Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 605 seconds.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.20.0` — mutation testing is a campaign, never commit ceremony): The
  list-only `cargo-mutants 27.0.0` census is 3,333 candidates across 19 files, including 1,343 in `engine.rs`, so
  even diff/file execution does not belong in per-commit, pre-commit, or ordinary local-CI paths. Preserve normal
  tests there. Build a future manual command that refuses accidental full execution, starts with small semantic
  files, records tool/config/scope/baseline/time/resources, separates survived/timeout/unviable outcomes, and uses
  sharding only for justified milestones or releases. Convert real survivors into behavior tests; record narrow
  equivalent/dead/unspecified/tool-limit dispositions. Exclude only the generated Unicode table initially because
  its generator and exact-byte/runtime contract are stronger owners. No mutant ran in this planning slice.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.18.3` — optimize only a measured derivative): Keep three distinct tiers:
  immediate dynamic construction, fingerprinted warm-state reuse, and an optional backend-native artifact. Feed
  the third tier normalized effective compiled state, never backend-specific grammar shortcuts. Generated-source
  v1 contributes identity/loadability/trace/equivalence foundations but is not evidence of specialization or
  speed. Select one realistic backend/format only after profiling; include build/load cost and break-even workload;
  retain the dynamic parser as oracle/fallback; and reject promotion on any AST/span/diagnostic/Unicode/recovery/
  limit/trace drift. Compilation and artifact loading are explicit trusted operations. Keep this separate horizon
  non-blocking for both the dynamic 91-format program and semantic backend parity; do not require Perl support.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.18.2` — make a dynamic parser explain both construction and execution): The
  existing level/sink/event contract is necessary but not enough for large generated parsers. Correlate spec-graph
  and cache identity through resolution, staging, validation, planning, compilation, and runtime. An exact ordered
  rule-label allowlist is an event filter, never an execution filter: keep global scopes, keep dispatch decisions
  owned by selected rules, reject unknown labels before work, and prove identical compiled state/results/ASTs/
  diagnostics/caches with and without tracing. Bound/redact debug payloads. Keep Lua `.5.3` as the current parity
  owner; implement the stronger neutral format-readiness contract only after parity in `.2.7`.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.1` — keep the first staged provider narrow and observable): Reuse the
  accepted resolve/load/compile/execute record shapes rather than hiding ActionIR parsing behind one convenience
  call. Normalize each typed job defensively, decorate equal sort keys with input order because Lua's `table.sort`
  is not stable, and retain the fixed adapter digest/cache fingerprint so all backends describe the same parser
  identity. Validate function sidecars before execution, reject duplicate job ids before stitching, and rebuild
  `SpecFile`/`FunctionDefinition` values through existing constructors so result mutation cannot alter the stitched
  tree. Do not pull registered-call runtime, native loading, descriptors/full trace, or recursive public staged
  authoring into this provider. Both ABIs pass 130/130 and status becomes `runtime-staged-registry`.
  Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 622 seconds.

- 2026-07-15 (`LUA-BACKEND-PARITY.5.1.0` — split at typed data and execution boundaries): The current Lua shell/
  registry/state foundation is not one missing function-call switch. First dispatch exact body jobs into immutable
  `body_ast`; then execute fixed-v1 calls over that staged body. Variadic-v2 changes the authoritative definition,
  sidecar, registry-resolution, and frame schemas before it changes execution, so give metadata and runtime separate
  leaves. Final `callback: codeblock` likewise requires typed declaration/normalization before contextual execution.
  Keep `{|params| ...}` construction and bound-codeblock invocation in `.11.7`; they require a different runtime
  model. This produces reviewable dependency-ordered commits and activates only staged provider `.5.1.1`.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.4.4` — close exactly the runtime boundary that exists): Reuse the completed
  Dart/Julia runtime checklists to audit controls, sinks, event kinds, traced entrypoints, rule/branch/lifecycle/
  cursor/boundary coverage, default quietness, and result identity. Then compare exported Lua API names, source
  topics, focused assertions, status, public book, task/index, roadmaps, and Knowledge Map. The inventory is exact;
  Lua additionally traces its governed helper and rule-slot mark/capture mechanisms. Do not call this full pipeline
  trace: loading, frontend, validation, compiler, function-shell, and staged owners remain `.5.3` after `.5.1/.5.2`.
  No source change is needed; both ABIs remain 129/129, canonical local CI passes CLI 61x2 plus Phase 0 `1..1031`
  in 608 seconds, and `.5.1` becomes active.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.4.3` — instrument the one runtime, not a traced duplicate): Thread the optional
  emitter through the parse context, then place events at the existing mechanism boundaries: rule scope entry/
  cleanup, regex decision, cached action-child or blind-child return, lifecycle execution, recursion cutoff,
  cursor mutation, boundary capture, and governed helper/rule-slot mark mutation. High owns structural scopes and
  lifecycle; debug owns detailed decisions and positions. Keep byte offsets in internal trace details while public
  result positions remain Unicode characters. Focused dual-ABI tests compare full result JSON for success,
  no-match, action/blind dispatch, and recursion, then assert exact mechanism topics/details. PUC Lua and LuaJIT
  pass 129/129; canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 610 seconds. Status is
  `runtime-trace-events`, and `.4.4.4` owns no-drift.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.4.2` — trace controls stay caller-owned and mechanism-neutral): Lua follows
  the admitted Dart/Julia split: one immutable config and one caller-owned emitter own ordered thresholds, events,
  rendering, and stdout/route/mirror delivery. Runtime entrypoints accept the emitter directly or construct it from
  config; they do not read ambient environment themselves, mutate caller options, or change result data. The
  controls slice emits only balanced parse enter/exit records, keeping exact rule/regex/branch/lifecycle/cursor/
  boundary instrumentation reviewable under `.4.4.3`. Weak-key private storage gives Lua typed immutable proxy
  records across both ABIs; accessors must return stored `false` explicitly rather than collapsing it to `nil`.
  Both PUC Lua and LuaJIT pass 128/128; canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in 611 seconds;
  status is `runtime-trace-controls`.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.4.1` — attach diagnostics at the deepest typed boundary, then preserve them):
  Build one neutral payload constructor over caller-owned engine identity. Give rule lookup, empty-state selection,
  strict input, and ordinary execution distinct stages. Wrap each typed rule failure before discarding its frame;
  parent and parse fallbacks add context only when no payload exists. This preserves `Top` plus deepest `Child`
  attribution without a parallel failure stack. Keep `message`/`tostring` unchanged, omit unavailable JSON fields,
  and prove successful result identity separately. Both ABIs pass 126/126; canonical local CI passes both primary
  CLI environments at 61/61 and Phase 0 `1..1031` in 613 seconds. Status is `runtime-structured-diagnostics` and
  trace controls/sinks `.4.4.2` is next.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.4.0` — trace owners must exist before propagation can be proved): Split
  observability by dependency epoch. The current runtime already has typed exceptions, a parse-scoped rule stack,
  compiled source records, cursor/capture/mark state, and a caller-owned parse option boundary, so structured
  failures, controls/sinks, and runtime events are safe `.4.4.1-.3` units. General function/staged and native-load
  owners do not exist until `.5.1/.5.2`; keep full-pipeline propagation in dependent `.5.3`. This mirrors the
  completed Dart and Julia sequence and prevents a runtime slice from making a false full-pipeline claim. The
  planning-only split changes no behavior; `.4.4.1` is next.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.9.2` — make the negative space executable, and correct audit prose from
  source history): Export a defensive sorted internal inventory view so the dual-ABI suite, not a disposable probe,
  owns the exact all-name assertion. Parse and compile every generated call before classifying runtime outcomes;
  only the thirteen governed structural/receiver-only function forms may remain unsupported. Focus `call(rule)`
  separately because a generic owner error cannot prove result/`retv`/cursor semantics. When an audit note says a
  duplicate exists but current and historical exact scans each show one row, correct the durable note instead of
  manufacturing a no-op source edit. The final partition is 233+13=246, both ABIs pass 125/125, public status is
  `runtime-helper-value-control`, parent `.4.3` closes, and `.4.4` is next.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.9.1` — eager first, compose second): Do not implement logical helpers with
  host-language short-circuit operators around expression evaluation. Evaluate and retain every authored value in
  source order, then apply `runtime_truthy`; this preserves side effects even after a decisive `and`/`or` operand
  and after `not`'s first operand. Keep empty calls false/false/true to match the established Rust/Julia boundary.
  Lua's current `"0"`/empty-aggregate truthiness stays unchanged pending `.5.2`. Both ABIs pass 123/123 and exact
  admission/status `.4.3.9.2` is next.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.9.0` — probe the negative space, not only the green inventory): Generate one
  minimal call per exact admitted source name and distinguish runtime-owned calls from an `unsupported runtime
  helper` result. The 246-name Lua boundary is 230 handled, thirteen intentionally non-function (structural or
  named-receiver-only), and three genuinely missing (`and`/`or`/`not`). A corpus occurrence and equal inventory
  cannot prove execution. Keep the Lua repair separate from the toolbox-discovered Perl keyword-precedence defect:
  `return and(...)` / `return or(...)` returns host undef, so `FUTURE-PARITY-BACKLOG.5.2` must repair the reference
  and normalize truthiness/arity after current Lua parity. `.1` implements eager Lua logic; `.2` owns the permanent
  partition, direct `call(rule)` proof, reported-duplicate resolution, status correction, and parent closure.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.8` — diagnostic output is an event, never parser data): Evaluate every
  valid helper argument once left-to-right before emission, then synchronously deliver typed helper/rule/message
  events through a per-parse caller callback. A missing sink suppresses delivery, not evaluation. Keep messages
  out of accumulators and parse-result values; preserve Unicode bytes and call/item order; leave `exit_now` as
  immediate typed control. Lua follows the current Perl reference arity and prefix/optional-suffix formatting so
  this backend slice does not invent a sixth contract. The source audit nevertheless found a real four-existing-
  backend disagreement: Rust bypasses prefix/suffix through stderr lines, Dart discards after evaluation, and
  Julia's omitted suffix adds a newline while Perl writes through host output. Route the neutral transport/
  formatting decision to `FUTURE-PARITY-BACKLOG.5.1`; do not mislabel Lua closure as five-backend parity. Both Lua
  ABIs pass 122/122, and exhaustive helper no-drift `.4.3.9` is next.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.7.6` — close families from exact sources, not a green count alone): The
  capture/cursor parent has 62 unique current call names across capture/mark, input/cursor, and explicit cursor
  control families. Compare contract classification to runtime dispatch and focused execution sources; all three
  must be 62/62 with no missing or extra. Keep placement markers separate because they are grammar/timing events,
  not calls. Historical inventory prose must distinguish the former 237/239 blind spots from the current 246-name
  inventory, 105+1 occurrence sources, and independent 122-public-contract check. Native interpreter closure does
  not imply generated-source support; preserve that boundary under `.8.1-.8.4`.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.19.0` — borrow the useful ideas, not host-language accidents): Portable
  autovivification belongs only on writes. Determine a missing container from the next evaluated segment (integer
  array, string harray), never overwrite an existing wrong-kind value, keep arrays dense, and commit an isolated
  updated root only after full validation. This preserves the existing expression evaluation order without Perl
  reference aliasing or sparse filler artifacts. For Ruby-style mutation, admit `!` only when it communicates a
  real receiver update. `map_leaves!` has a coherent pure twin and replacement result; `walk_leaves!` and
  `reduce_leaves!` do not. V1 uses a bare named binding, original-shape/root-kind traversal, stable copied paths,
  callback-result replacement, and atomic rebind/return. `value` remains scoped data, never a secret writable
  alias. Current method parsers are identifier/word based and all need an explicit typed bang seam. ADR `0036`
  and `.19.1-.19.7` own the future contract/rollout after current parity; Lua `.4.3.7.6` was then next.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.18.1` — terseness removes redundancy, not information): Evaluate future
  `.spec` proposals against terseness, readability, and expressiveness together. Prefer one canonical abstraction,
  orthogonal composition, inferred information only when unambiguous, and precise typed failures. Do not optimize
  character count by erasing recursive/shallow distinctions or hiding behavior in format-specific/host escapes.
  Uniform binding is the precedent: one scalar/array/harray/codeblock value slot plus runtime-kind dispatch and
  `binding_kind_mismatch` is both shorter and clearer than selector namespaces or implicit coercion. Keep
  `walk_leaves`/`map_leaves`/`reduce_leaves`: `_leaves` is semantic, not ceremony. Future format-driven features
  must include realistic `.spec` excerpts and invalid/ambiguous boundaries. ADR `0035` governs this; no behavior
  changed, and Lua `.4.3.7.6` was the then-active frontier.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.7.4` — placement belongs in compiled state, timing belongs after action
  dispatch): Split markers are grammar-slot events, not helper calls. Preserve a typed event on the preceding
  regex index, carry it through compiled/public state, dispatch all actions and children first, then mutate the
  existing anonymous boundary or rule-local named-mark store before `LE`. This makes same-slot invisibility and
  later-slot visibility explicit and avoids a second marker frame. Parser recovery must preserve any unparsed
  same-line remainder as typed raw syntax; otherwise a valid prefix can silently swallow a malformed marker
  suffix. The multibyte native/reconstructed proof covers all anonymous aliases, named marks, Unicode positions,
  the shipped EBNF `@move_pos`, and malformed names/fragments at 121/121 on both Lua ABIs. The first canonical CI
  run found only a stale exact public-file count: `.18.0` added one discovered mdBook page, so selector admission
  intentionally moves from 56 to 57 files while retaining 27 classified references and zero current examples.
  Exhaustive capture/cursor no-drift `.4.3.7.6` is next.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.18.0` — use formats as requirements evidence, not host-parser wrappers): The
  91 eligible catalog rows are valuable because they expose general parser mechanisms the current `.spec` language
  may still lack. The safe evolution loop is format conformance failure -> reusable mechanism classification ->
  neutral contract -> Perl/Rust/Dart/Julia/Lua implementation and proof -> resume the format. Never conceal the
  hard part in a host callback or duplicate JSON/XML/YAML syntax across derived vocabularies. The composed format
  `.spec` graph is the sole parser implementation and is dynamically compiled for immediate document use;
  generated host source or compiled caches are fingerprinted derivatives, never co-authoritative grammar. Accuracy includes a
  pinned spec/corpus, source-aware AST/trivia policy, typed errors/recovery, adversarial Unicode, and differential
  proof; speed separately measures cold construction, warm reuse, and document parsing. HTML is an independent WHATWG tokenizer/
  tree-builder stress test, while XHTML reuses XML. CUE/Dhall/Jsonnet/Nickel/Pkl/Nix text-to-AST does not silently
  include evaluation. The entire program remains dormant until current backend parity is complete.

- 2026-07-15 (`LUA-BACKEND-PARITY.4.3.7.3` — overload at dispatch, share state and span validation): The admitted
  named-mark family did not need another frame: every writer, reader, two-mark span, and bridge extends the
  existing parse-scoped `rule label -> name -> UTF-8 byte offset` store. One guarded byte-span seam validates both
  endpoints before slicing or mutating; public positions and widths convert to Unicode characters only at the DSL
  boundary. Advancing forms therefore change a mark only after a valid read, so absent or reversed spans are
  neutral. The only name collision is semantic rather than lexical: zero-argument `capture_take()` is anonymous,
  while one-argument `capture_take(name)` is named. Route that overload before anonymous dispatch and retain the
  existing arity-specific diagnostics. The unchanged governed fixture plus a supplemental multibyte bridge/edge
  case pass native and reconstructed execution; the full Lua gate is 120/120 on PUC Lua and LuaJIT. No inventory
  or fixture changed. Placement-sensitive marker execution remains a distinct timing mechanism under `.4.3.7.4`.

- 2026-07-15 (`FUTURE-PARITY-BACKLOG.17.5` — equality is not completeness): Exact equality between backend
  inventories prevents one-sided drift but cannot detect a name omitted everywhere. The former reverse check also
  discovered Perl calls only from the same corpus used as occurrence evidence, so a symmetric corpus omission
  stayed invisible. The hardened gate separates those concerns: 105 corpus fixtures plus the exact named-mark
  fixture prove governed source occurrence, while all identifier-shaped Perl contracts independently define a
  122-name public set after subtracting nine explicit compatibility/legacy/internal exclusions. Exact seven-name
  family views remain alongside the now-246-name shared inventories because focused semantic ownership is useful
  even after staging ends. A three-backend `clear_mark` deletion proves both independent guards fail correctly.
  All complete backend gates pass; Lua `.4.3.7.3` consumes the admitted store and dispatcher next.

- 2026-07-14 (`FUTURE-PARITY-BACKLOG.17.4` — stage names separately, but do not stage state twice): Lua's match
  registers and cursor already use UTF-8 byte offsets, so the complete named-mark contract belongs in one new
  parse-scoped `rule label -> mark name -> byte offset` store. Entry/local writers reuse the immutable match
  snapshots, location readers reuse `line_column_at_byte_offset`, and public positions convert only at the DSL
  boundary. Rule-label scope—not a transient child-call snapshot—is the established five-backend contract, so a
  child can reuse a name without overwriting its parent's bucket while later calls in the same rule still see the
  checkpoint. Inventory staging stays orthogonal: seven names join known-call and capture/mark resolution through
  a private exact set but do not change the shared 239-name count before `.17.5`. The focused fixture passes native
  and serialized `SpecFile` reconstruction on PUC Lua and LuaJIT at 119/119; its pre-existing-inventory
  `mark_input_end`, `mark_pos`, and `mark_exists` calls are the necessary observation bridges into the new store.
  Lua `.4.3.7.3` must extend this same store and dispatcher for the remaining governed named spans/bridges rather
  than introduce a parallel frame. Canonical CI preserves capability 64/0/0 and shared coverage 239/105, passes
  CLI 61x2 and Phase 0 `1..1031` in 627 seconds, and clears every doctrine/documentation gate.

- 2026-07-14 (`FUTURE-PARITY-BACKLOG.17.3` — preserve one mark store and one eventual admission point): Julia's
  existing architecture already matches the neutral storage model: `rule label -> mark name -> code-unit offset`,
  with Unicode-character conversion only at the `.spec` boundary. The complete helpers therefore reuse that
  store and the existing entry/local match registers; location reads reuse `line_column_at_codeunit_offset`, and
  clear deletes only from the current rule bucket. As with Dart, adding the names directly to Julia's private
  `_SUPPORTED_ACTION_IR_CALL_NAMES` would prematurely break the exact legacy 239-name Dart/Julia/Lua comparison.
  The public `COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES` set is folded into known-call resolution while remaining
  disjoint from the shared set; `.17.5` admits once after Lua alignment. A 13-assertion exact contract covers
  staged inventory plus native/generated-plan/emitted-state/CLI behavior. The full Julia gate passes 1,414 package
  assertions, shared CLI 61x2, and corpus 105/105. Canonical CI additionally proves capability 64/0/0, unchanged
  shared coverage 239/105, CLI 61x2, and Phase 0 `1..1031` in 614 seconds; Lua `.17.4` is the next clean-pivot
  consumer.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.17.2` — stage backend rollout names without weakening the shared gate):
  Dart already had the correct hard part: marks were stored as `rule label -> name -> code-unit offset`, with
  character projection at the public boundary. The seven-helper implementation therefore belongs in that seam,
  not in a second mark store: entry/local writers read the existing match registers, location readers reuse
  `lineColumnAtCodeUnitOffset`, and clear removes from the current rule bucket. The fixture also corrected the
  prior absent-`mark_pos` fallback from character position zero to `undef`. Inventory rollout needs different
  discipline. Adding the seven names directly to Dart's legacy `supportedActionIrCallNames` would break the
  intentionally exact 239-name Dart/Julia/Lua comparison before the other two backends implement the behavior.
  `completeNamedMarkActionIrCallNames` is therefore a public staged set folded into Dart's known-call boundary but
  kept disjoint from the legacy shared set; `.17.5` remains the single admission point after Julia/Lua alignment.
  Native, generated-plan, emitted-state reconstruction, and primary-CLI routes return the unchanged neutral value.
  Strict analysis, 68 focused compatibility tests, all 214 package tests, CLI 61x2, and corpus 105/105 pass.
  Canonical CI additionally proves capability 64/0/0, unchanged shared coverage 239/105, CLI 61x2, and Phase 0
  `1..1031` in 1,061 seconds. Julia `.17.3` is the next clean-pivot consumer.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.17.1` — mark scope and generated ownership must be tested together): The
  seven omitted helpers looked like dispatcher additions, but the unchanged parent/child fixture exposed three
  deeper seams. (1) A named checkpoint is keyed by both rule label and mark name. Rust's former global name map
  made a child's `shared` overwrite its parent's; one nested same-name case now protects every mark-based capture
  helper because all reads/writes go through the rule bucket. (2) Missing positions are data absence, not position
  zero. `mark_pos`, `mark_line`, and `mark_col` therefore return undef when absent, while `mark_exists` alone
  returns numeric zero. (3) Standalone emitted code cannot call a compiler-private trace subroutine. Generated
  source now owns a safe delegate, and its trace arguments are valid even when an `I` preamble runs before any
  local match: the trace left edge falls back to the live cursor. Arguments are evaluated before a no-op trace
  call, so guarding only inside the trace handler would still warn. The first canonical gate proved the resulting
  Phase-0 delta was exactly two top-level source-lock subtests; migrating their 19 expected strings and rerunning
  produced `1..1031` PASS in 983 seconds. Neutral, Perl live/generated, Rust native/serialized/emitted/generated,
  complete Rust package, capability 64/0/0, CLI 61x2, doctrine, KM, and book gates pass. Dart `.17.2` is next.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.7.5` — structural lookahead is not ordinary rule execution): A boundary
  helper must ignore surrounding consume mode, inspect every usable target without dispatching it, choose the
  earliest left edge, and move only to that edge. Reusing the ordinary rule cache/execution path would couple
  lookahead to rule repetition, actions, or mode. Lua therefore owns a separate label-keyed compiled-alternation
  cache and calls `seek_match` directly, then uses the shared cursor synchronization seam. The multibyte test
  locks non-consumption, EOF fallback, and unusable no-op behavior at 117/117 on both ABIs. A toolbox probe also
  found zero-argument drift: Perl leaves a raw undefined helper in generated execution while typed backends return
  null; `.5` owns the language-level minimum-arity decision. The full local gate passes capability 64/0/0, both
  61-case CLI environments, and phase0 `1..1031` in 862 seconds. Named-mark `.17.1` is the next dependency frontier.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.7.2` — classify the right edge before reading or mutating): Anonymous
  capture helpers share one rolling left edge but not one right edge. Plain slice/take ends at the current local
  match start, until-cursor ends at the live cursor, and rest ends at input end. Lua keeps every endpoint in UTF-8
  bytes and converts only public positions/widths, so multibyte text does not split state ownership. Stable and
  advancing forms share one validated span function; mutation happens only after a non-null result. The setter is
  intentionally void, as in the catalog and Rust/Dart/Julia. Perl's position result is an assignment-expression
  leak, now durably routed to `FUTURE-PARITY-BACKLOG.5` instead of copied into Lua. Both Lua ABIs pass 116/116;
  named marks still wait on `.17`, so `.4.3.7.5` can independently add earliest-boundary lookahead next. Full
  local CI passes capability 64/0/0, CLI 61/61 twice, phase0 `1..1031` in 766 seconds, and all gates.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.7.1` — keep one internal offset unit and convert only at the DSL boundary):
  Lua's regex engine, match records, and immutable registers already use zero-based UTF-8 byte offsets. Adding a
  second character-offset cursor would create synchronization risk. The runtime therefore keeps one byte cursor
  and uses `matching.byte_offset_to_char_offset`, `char_offset_to_byte_offset`, and
  `line_column_at_byte_offset` only for public projections and whole-input slices. One `set_live_cursor` seam
  updates both `ctx.cursor_byte` and the register cursor while preserving the entry/local/capture snapshots.
  Cursor saves store byte offsets on one parse-scoped LIFO stack; empty pop and absent-anchor rewinds are no-ops.
  The focused Unicode probe also locks a subtle execution consequence: consume-mode matching must read the
  changed live cursor, not a stale register field. Both Lua ABIs pass 115/115; anonymous capture `.4.3.7.2` can
  reuse the same conversion/state seam without changing cursor-control semantics. The full local CI gate passes
  capability 64/0/0, CLI 61/61 twice, phase0 `1..1031` in 918 seconds, and all doctrine/contract/book checks.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.17.0` — compare semantics before turning a set difference into inventory):
  Sixteen identifier-shaped, non-compatibility Perl contract diagnostic names are outside the aligned 239-name
  inventories, but only seven are missing public current calls. Two are documented compatibility aliases, two are
  legacy capture surfaces, and five are internal assignment/append/drop operations. Requiring all 16 as user calls
  would be as wrong as ignoring all 16. The new lane therefore starts with an exact seven-helper neutral contract,
  rolls it through Perl/Rust/Dart/Julia/Lua, and only then hardens coverage against symmetric omission using an
  independent public-current source. This keeps the public book authoritative without treating prose extraction
  or internal `diag_name` fields as an untyped registry generator. Lua `.4.3.7.1` can proceed independently;
  named-mark `.4.3.7.3` waits for the shared resolution.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.7.0` — inventory agreement can preserve the same omission): The exact
  239-name gate proves that Dart, Julia, and Lua share one governed inventory, that every inventoried name appears
  in the book/corpus, and that neutral-corpus calls matching current Perl contracts occur in the inventories. Its
  reverse direction starts from the corpus, however; it does not enumerate every non-compatibility Perl contract
  or every public helper in the book. Consequently all aligned inventories omit the same seven documented current
  mark helpers (`mark_entry_start/end`, `mark_match_start/end`, `mark_line`, `mark_col`, `clear_mark`) and still
  pass. Lua must not paper over that structural gap locally. The capture/cursor parent is now split by mechanism,
  and its named-mark leaf requires a clean-pivot cross-backend resolution before claiming full parity. Separately,
  typed parsing of `@capture_slice`, `@capture_from_here`, `@move_pos`, and `@mark(name)` does not imply runtime
  marker support: Lua's compiler/interpreter currently ignore split-marker nodes, while shipped EBNF source still
  uses `@move_pos`. Marker timing therefore has its own leaf after helper state exists.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.6.6` — a dependency handoff is incomplete until the destination acceptance
  names the obligation): `.4.3.6` already said general user-function contextual blocks belonged to `.5.1`, but
  `.5.1` described fixed/rest runtime calls without naming final `callback: codeblock` metadata or equivalent
  attached/parenthesized execution. The closeout now records that requirement at `.5.1` itself, while keeping
  explicit `{|params| ...}` literals and dynamic codeblock-variable calls under `.11.7`; this prevents a future
  session from closing general function dispatch while silently omitting its contextual final block. Current
  built-in scope is unchanged: eager blocks, controls, signature-governed `with`, and root-kind callbacks pass
  114/114 on PUC Lua and LuaJIT. Callable and punctuation-light neutral checkers pass, capability census stays
  64/0/0, and the preceding mandatory full gate passes CLI 61/61 twice plus phase0 `1..1031` in 987 seconds.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.6.5.2` — dispatch traversal by root kind, not by a synthetic mixed tree):
  The canonical array and harray methods share names and callback mechanics but do not share interior-node kinds.
  A hash root recurses only through hashes; an array root recurses only through arrays. Cross-kind aggregates are
  leaf values. Encoding that rule as one `tree_kind` selected from the receiver avoids duplicating walk/map/reduce
  control while keeping child enumeration and result construction explicit: lexical keys for harrays, source-order
  Lua offsets translated to zero-based indexes for arrays. The callback frame stays one transaction and chooses
  only its selector binding (`key` or `index`). This also makes regression proof stronger: the old harray fixture
  exercises the same dispatcher as the new array fixture. Both Lua ABIs pass 114/114 with the exact checked-in Perl
  result. The mandatory full local CI gate exits 0 with capability 64/0/0, both primary CLI environments at 61/61,
  and phase0 `1..1031` green in 987 seconds.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.6.5.1.2` — scope the callback frame atomically): Nested one-name scope
  calls could have restored callback names correctly, but each layer would also copy the callback result and hide
  the one logical frame. `runtime_scoped_binding.run_frame` instead validates all distinct names, snapshots all
  scalar/array/harray stores before any mutation, installs copied uniform scalar-held values, copies the result
  once, and restores in reverse frame order through one protected boundary. The original `run` delegates to this
  seam, keeping `with` behavior unchanged. Harray traversal builds a fresh path per edge, recurses only when the
  runtime kind is harray, and keeps arrays as leaf values; this preserves the separate zero-based array-root owner
  `.4.3.6.5.2`, which later closes without cross-kind recursion. Receiver-kind validation precedes reduce-initial evaluation, matching Perl's invalid-receiver
  short circuit. Direct Perl and Lua outputs agree; both Lua ABIs pass 113/113. The mandatory full local CI gate
  exits 0 with capability 64/0/0, both primary CLI environments at 61/61, and phase0 `1..1031` green in 983
  seconds.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.6.5.1.1` — resolve optional metadata only after value arity): Bare working
  values make a purely lexical "first identifier means scope" rule ambiguous. The safe precedence is mechanical:
  first validate the raw authored list against the current value helper's min/max arity; if valid, preserve it
  byte-for-slot; only if invalid may legacy scope removal be attempted. `MethodExpr` owns the opt-in mode, while
  `MethodLowering` and `FlowExpr` select it for the affected variadic/range and family-inference paths. Existing
  collection normalization already followed this rule and now uses the same central implementation. A fixed-
  arity test proves compatibility fallback still works when the unstripped list is invalid. Runtime callback proof
  deliberately puts bare `key`/`acc` first in multi-argument helpers, so future regressions cannot hide behind
  literal or nested-call first operands. Focused AST tests pass; the mandatory full local CI gate exits 0 with
  capability 64/0/0, both primary CLI environments at 61/61, and phase0 `1..1031` green.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.6.5.1.0` — a callback-looking loss can be a generic arity normalizer):
  `parse_action_expr` proves `seen += cat(key, "@", depth)` retains `key` in the nested call AST. The later `cat`
  lowerer invokes `_normalize_method_args_with_optional_scope(..., 2, undef)`, whose count-based rule strips any
  first bare identifier when the remainder is still valid. Thus three-argument `cat` loses `key`, while two-
  argument `cat(key, "!")` does not. The callback frame is correct and append only reveals the generic collision.
  Repair the reference value-helper boundary before copying behavior into Lua; preserve unrelated accepted scope
  forms. The same source/runtime audit shows tree callback `depth` is path length (root 1), despite stale zero-based
  mdBook prose. Separate owners `.4.3.6.5.1.1` and `.4.3.6.5.1.2` keep repair and Lua execution independently
  verifiable.

- 2026-07-13 (`LUA-BACKEND-PARITY.4.3.6.4` — context decides whether braces execute eagerly): Lua's parser uses
  the same structural `block_value` for an ordinary expression block and a contextual final argument. The runtime
  must therefore consult callable signature metadata before generic argument evaluation: helper/receiver `with`
  consumes the raw final block, while ordinary braces keep the eager `.4.3.6.1` semantics. One copied registry
  also records the later tree callback signatures without prematurely executing them. Scoped cleanup is isolated
  in a small protected module: snapshot every private store before mutation, copy the temporary uniform `value`
  and callback result inside `pcall`, restore snapshots unconditionally, then rethrow the original failure. This
  ordering covers callback and result-copy errors and preserves false values as present bindings. PUC Lua and
  LuaJIT pass 112/112; `.4.3.6.5.1` can now reuse the same scope/metadata seam for callback frames.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.7` — admit current syntax without overstating the Lua product): The
  capability census intentionally covers the four established full backends, while Lua's syntax proof is already
  real at typed AST, serialized `SpecFile`, and native dual-ABI boundaries. Admission therefore adds one 4-pass
  census row and removes the syntax's future exclusion, while the recurring composed command separately runs all
  five implementations and both Lua ABIs. This keeps capability at 64/0/0 without inventing generated Lua. Public
  example migration is selective: prefer bare markers and terminal receiver methods in current teaching examples,
  retain parenthesized twins as valid documentation, and preserve literal walkthrough spellings when describing a
  checked-in spec. The neutral invalid/mutation cases remain the grammar-broadening guard. Admission also exposed
  a hard-coded `60/0/0` status string in the generated-source checker; it now derives all census totals from the
  manifest so later capability additions cannot silently stale the gate output again.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.6` — narrow Lua's parser-ahead fallback at its existing context): Lua's
  fluent parser already accepted any identifier-only receiver segment, so the safe change was to pass segment
  terminality into that fallback and reject both intermediate omissions and attached blocks. Exact trimmed `next`
  is synthesized only by the shared statement constructor; expression parsing still produces a variable. Existing
  control-head normalization was extended for the three missing structural markers. The public `SpecFile` JSON
  reconstruction test proves serialized ActionIR and native execution consume the same nodes on PUC Lua and
  LuaJIT. Preflight also corrected the task's preservation claim: Lua has no emitter today, so generated-source
  proof remains with `LUA-BACKEND-PARITY.8.1-.8.4`, not this syntax leaf. Lua `contains` independently returns `0`
  for an absent needle; syntax parity preserves the twin and leaves semantic normalization to `.5`.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.5` — reuse Julia's existing statement and terminal-chain contexts): Julia
  already normalized five structural control heads, so adding a grammar-wide bare-call production would have
  broadened the language unnecessarily. Exact trimmed `next` is synthesized as the existing zero-argument call
  only by statement parsing; expression/value parsing still yields a variable. Fluent-chain iteration already
  knows which segment is final, so only that segment may synthesize an empty argument list from a bare identifier.
  This preserves all six excluded classes and makes native, generated-plan, emitted-state, and CLI paths consume
  the same typed AST. Julia `_call_runtime_array_contains` separately returns `0` when the needle argument is
  absent; syntax parity preserves the parenthesized outcome and leaves helper normalization to `.5`.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.4` — reuse Dart's existing statement and terminal-chain contexts): Dart
  already normalized five structural control heads, so adding a grammar-wide bare-call production would have
  broadened the language unnecessarily. Exact trimmed `next` is synthesized as the existing zero-argument call
  only by statement parsing; expression/value parsing still yields a variable. Fluent-chain iteration already
  knows which segment is final, so only that segment may synthesize an empty argument list from a bare identifier.
  This preserves all six excluded classes and makes native, generated-plan, emitted-state, and CLI paths consume
  the same typed AST. Dart `_callArrayContains` separately returns `0` when the needle argument is absent; syntax
  parity preserves the parenthesized outcome and leaves helper normalization to `.5`.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.3` — preserve newline evidence before generic expression parsing): Rust's
  generic variable parser permits whitespace before call/index lookahead, so post-normalizing a parsed bare marker
  is too late: it has already consumed the newline needed by statement-separator accounting. The narrow parser
  seam is an exact statement-boundary recognizer before generic expressions. It consumes only the marker name and
  synthesizes the existing empty-argument call; value-position names remain variables. Terminal receiver omission
  is independently local to `parse_fluent_chain` and stops after adding the empty-argument segment. This leaves
  `if(condition)` / `while(condition)` and every excluded grammar class unchanged. Native, serialized, emitted,
  generated, and rebuilt-CLI paths all consume that same typed AST. A separate preflight found Rust `contains`
  defaults an absent needle instead of enforcing Perl's arity; preserving that parenthesized outcome is correct
  for this syntax leaf, while helper owner `.5` holds the semantic normalization.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.2.1` — syntax aliases normalize at existing typed seams): The narrow
  Perl implementation required no new runtime operation. Exact standalone bare `next` is normalized to the
  existing zero-argument call only in statement position, then routed through canonical `next_stmt`; this keeps
  value-position `next` a variable and preserves labeled `next LABEL` compatibility. Generic bare receiver
  parsing is similarly contextual: only the terminal identifier-only segment synthesizes the existing empty
  argument list, so ordinary method-contract/arity lowering remains authoritative. The six excluded grammar
  classes retain their prior raw/invalid reasons. This seam-local normalization is what keeps `if(condition)` /
  `while(condition)` and the general parenthesized call language untouched.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.2.0` — receiver arity must exclude the implicit receiver): The neutral
  contract initially used `.drop_front()` as a required-argument rejection example. A required toolbox preflight
  disproved that assumption: `call_spec_handler_subst` lowers it as the established default-one operation.
  `MethodLowering.pm` records function-form `drop_front` arity `[1,2]`, which becomes authored receiver arity
  `[0,1]` after subtracting the value left of the dot. `contains` is function-form `[2,2]`, hence receiver arity
  `[1,1]`, and `.contains()` follows the existing unsupported-helper rejection. The v1 contract now uses
  `contains`; no syntax rule, fixture, helper behavior, or backend code changed. This is why executable neutral
  examples must be calibrated against the reference contract table before a backend consumes them.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.1` — neutral contract before parser edits): A punctuation-light spelling
  is safest when its boundary is executable independently of every backend. The v1 contract treats only the six
  named standalone markers as governed aliases and permits a bare generic receiver call only in the final segment.
  The latter supplies zero authored arguments; it does not bypass the existing method arity resolver. Thus
  `values.count` matches `values.count()`, while `values.contains` receives the same existing rejection as
  `values.contains()`. Ordinary bare identifiers remain value reads. Parenthesis-free condition headers,
  general calls, argument-bearing calls, intermediate bare receiver segments, and receiver trailing blocks remain
  separate invalid classes. The future fixture exercises all six markers without depending on unresolved `next`
  runtime drift: `next` is parsed in an unentered `while(false)` body. Three checker mutations prove that marker
  membership, final-only receiver position, and condition-header parentheses cannot silently broaden.

- 2026-07-13 (`FUTURE-PARITY-BACKLOG.16.0` — punctuation-light zero-argument audit): The director clarified that
  removing `()` applies to zero-argument markers such as `else`, `endif`, `default`, `endcase`, `endswitch`, and
  `next`, not to condition-bearing `if`/`while` headers. Source audit shows two distinct parser surfaces: every
  rule/lifecycle dotted-suffix parser already treats missing parentheses as zero arguments, while typed ActionIR
  parsers differ. Perl/Dart/Julia normalize the existing five control markers, Rust does not outside synthetic
  attached controls, Lua recognizes only `else`/`otherwise`/`default`, and none recognizes bare `next`. Generic
  bare receiver segments are rejected by Perl/Rust/Dart/Julia but accepted in every Lua segment. ADR `0033`
  therefore admits only the six standalone aliases and a generic final receiver segment; existing arity checking
  remains authoritative. Calls with arguments, intermediate generic segments, final-codeblock calls, general
  helpers/user functions, and parenthesis-free `if`/`while` headers remain excluded. `.16.1` owns a neutral
  positive/negative contract before backend code; Lua `.4.3.6.4` is cleanly queued.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.6.3.3 — a bounded while must recheck before declaring runaway): Reuse the
  indexed statement executor, but keep one loop-specific boundary around the body. Validate the attached body
  first; evaluate the condition; if true beyond the configured completed-body count, fail before another body;
  otherwise execute and repeat. This matches generated Perl and Rust: a loop that becomes false exactly after the
  final allowed body succeeds. Dart/Julia currently throw without that recheck. The same boundary must intercept
  Lua's rule-level `next` flow so it continues the inner loop, matching generated Perl; Rust makes `next` a no-op
  and Dart/Julia propagate it to rule repetition. Those are explicit backlog `.5` decisions, not hidden parity.
  Return is not intercepted, so the surrounding action or expression-block boundary remains its owner. Typed
  rule-attributed guard failures and bodyless pre-evaluation rejection pass 108/108 on both Lua ABIs.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.6.3.2 — validate switch ranges before spending the subject): Attached
  switch stores branches inside one typed body, while marker switch stores them as sibling statement ranges with
  optional `endcase` and nested `endswitch` boundaries. Reusing the if leaf's indexed executor keeps those two
  carriers separate without duplicating body execution. Validate the whole chain first so a malformed structure
  cannot spend subject or case side effects; then evaluate the subject once, stop at the first scalar-equal case,
  and execute only its bounded range. One shared equality seam now governs inline, attached, and marker switch.
  Perl toolbox probes establish the current Lua target: null equals empty, false equals numeric zero, and
  aggregate values do not enter scalar comparison. Source audits show this is not yet a six-backend contract:
  Rust collapses aggregates to empty text, while Dart/Julia retain host boolean/container spellings. Backlog `.5`
  owns the typed equality decision. A final Perl lowering probe exposed a second marker boundary: Perl executes
  ordinary statements before the first case and after `endcase`, while Rust's inactive frame and Dart/Julia/Lua
  range selectors skip them. Lock the four-backend skip in Lua, require portable authoring to keep statements
  inside branches, and route the final decision to `.5`. Both Lua ABIs pass 107/107; attached while `.4.3.6.3.3`
  is next.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.6.3.1 — statement control owns statement ranges, not individual nodes):
  Attached branches arrive as consecutive ActionIR nodes with nested bodies, while marker branches delimit ranges
  in the surrounding block and require nested `endif` accounting. One indexed executor now owns both shapes and
  reuses the same block/dropped-statement seam, so selected `return` propagates to a rule block but remains local
  when the enclosing expression block catches it. Structural validation precedes marker condition evaluation;
  authored keyword/reason/rule fields survive malformed paths. A toolbox/source audit also found that Perl,
  Dart, and Julia admit more alias/shape pairings than Rust. Lua deliberately implements the documented portable
  intersection and backlog `.5` owns any future enlargement or aligned rejection.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.6.2 — structural control aliases must not leak into value dispatch): Lua's
  contract canonicalizer maps `i`/`when` to `if` and `elif`/`otherwise` to later branch names because all are
  governed calls, but that map alone does not grant identical semantics. `i`/`elif` belong to marker statement
  control and `when`/`otherwise` to attached blocks. Inline evaluation must therefore inspect authored names
  before canonical eager dispatch, validate branch AST shapes without evaluating payloads, and consume only exact
  `if`/`elseif`/`else` or `switch`/`case`/`default` forms. The same audit exposed an ungoverned truthiness split:
  Perl/Rust make scalar `"0"` false, Dart/Julia make it true; Perl makes empty reference aggregates true while
  Rust/Dart/Julia make them false. Lua follows the Perl oracle and backlog `.5` owns the language-level decision.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.6.1 — brace syntax needs evaluation context, not one AST meaning): Lua uses
  `block_value` structurally for both ordinary expression blocks and contextual final arguments. Ordinary value
  evaluation must execute it; a consuming block-taking callable must instead receive the raw final AST. The eager
  evaluator shares dropped-statement mutation for every non-final statement, evaluates the last statement in
  value context, and catches only `FLOW_MT` return so `next`/errors still propagate. The `.4.3.1` inert assignment
  fixture was scaffold drift: explicit deferred values are `{|params| ...}`, while contextual trailing blocks are
  inert only until their signature-governed callable executes them.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.6.0 — parser support is not runtime ownership): Lua already emits and
  resolves `block_value` and control nodes, including callable-name-agnostic attached final blocks, but its
  interpreter only copies block records. Eager block execution, value controls, statement controls, scoped
  built-ins, and traversal callbacks therefore need separate runtime leaves. Connecting `prepare_invocation` is
  general function work under `.5.1`; explicit `{|params| ...}` values and dynamic calls remain future `.11.7`.
  Keeping these owners distinct prevents a local built-in callback implementation from becoming a false claim of
  complete user-function or first-class callable parity.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.5.5 — closeout must inventory routes, not just names): The 13 ordinary
  harray calls do not live in one dispatcher: `hash`, `copy`, and runtime-kind `flat` use constructor/generic
  paths; ten names use `PURE_HASH_HELPERS`; statement `set_key` and direct assignment add a mutation context.
  Exact route inventory plus existing mechanism tests closes the family without pretending the three callback
  names already execute. Public no-drift now guards the subtle statement/value distinction and independent direct
  snapshots, while odd arity, map-list order, and rename collision remain explicit backlog decisions.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.5.4 — statement context is the mutation discriminator): A three-argument
  `set_key` call cannot be classified as mutating from its arguments alone because assigned/nested and receiver
  forms are deliberately pure copied transforms. Lua now intercepts only a dropped top-level call with a bare
  first target, then uses the same harray lookup/store seam as direct assignment. The seam preserves the private
  storage class, auto-creates only absent harrays, and reports stable wrong-kind fields. Direct bracket assignment
  retains its pre-existing numeric array path, and every returned mutation snapshot is copied before later writes.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.5.3.1 — copy transforms can share dispatch without sharing mutation):
  Ordered operand evaluation and receiver injection already existed; the missing seam was the harray transform
  evaluator. Sorting source keys makes Lua traversal deterministic, while argument order alone governs merge
  override. Every selected nested value is copied before return, so later source writes cannot alter saved views.
  A direct collision probe found an ungoverned edge: Perl/Julia let the renamed old value win, Dart/Rust keep the
  destination. Lua follows the reference locally; public guidance forbids collision dependence and backlog `.5`
  owns the cross-backend decision. Named statement mutation stays separate in `.4.3.5.4`.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.5.3.0 — dated facts must be reverified after language migrations): The
  July 4 bare-merge boundary was correct when recorded, but July 12 uniform binding changed the underlying value
  path and selector retirement invalidated its recommended `copy(hash(base))` spelling. Current Perl lowering is
  `{%base, %overlay}`; `merge_hash(base, overlay)` and `merge_hash(copy(base), overlay)` both return the expected
  result, while `hash(base)` rejects. The neutral corpus had already advanced and all three later runtimes pass its
  bare-first case. Runtime work must therefore reverify dated KM facts at their `reverify` seam after foundational
  migrations, and facts must record supersession instead of preserving obsolete current guidance.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.5.2 — one sorted key list must own both public views): Computing
  `sorted_values` independently from host iteration can detach values from their documented key order. Lua now
  derives one lexical key list and uses it for both views, copying each selected nested value. `has_key` checks
  table entry presence rather than value definedness, so a stored JSON null is present. A direct Perl toolbox
  matrix is necessary at invalid boundaries: it proved `count_keys` returns zero—not the stale catalog `undef`—
  and that both sorted views return empty arrays for missing/wrong-kind sources.

- 2026-07-13 (LUA-BACKEND-PARITY.4.3.5.1 — flattening needs both syntax and runtime-kind evidence): A returned
  harray alone cannot tell whether its parent should preserve it as one nested field or splice its entries. Lua
  therefore evaluates arguments once, dispatches `flat` by the resulting array/harray kind, but uses only the
  authored direct/terminal `flat` or `flat_hash` AST to authorize constructor splicing. Array list context sorts
  harray keys before emitting alternating key/value values because Lua tables do not preserve portable insertion
  order. Other hosts do not yet share that sequence, so portable ordering remains backlog `.5`. The constructor
  rewrite also explicitly retains Lua's prior odd-arity result instead of leaking normalization into this slice.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.5.0 — harray parity crosses syntax and runtime-kind seams): `hash(...)`
  constructor splicing must inspect the authored AST, while `flat(...)` must dispatch by the evaluated value kind;
  treating either as only a generic hash call loses ordinary nested maps or sends harrays through the array path.
  Deterministic views bridge into array receivers, copied transforms preserve nested values, named `set_key`
  needs a separate mutation seam, and block callbacks belong later. Those boundaries require separate commits.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.6 — closeout must compare duplicate public summaries): The detailed
  helper-catalog end-mutation section was correct, but a later canonical table on the same page still said
  statement-level only; punctuation let it evade the original prose guard. Array closeout now inventories all 37
  admitted names, routes the 34 non-callback names and six numeric terminals, and compares repeated result
  summaries. The guard forbids the exact residual shape and requires the corrected table anchor. The same audit
  aligned `count`/`take` invalid inputs and ordinary/explicit-target `push` results. A direct toolbox probe also
  proved implicit child-push expression drift: Perl returns the host push count while Lua returns the updated
  accumulator. That result must remain non-portable under `.5`; statement side effects are the current contract.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.5 — tagged records are a split-to-array bridge, not a new parser):
  `split_tagged_records` should reuse the governed pure split evaluator rather than duplicate literal/PCRE2 rules.
  The generic call path already evaluates arguments once; construction then copies every carried value into each
  fresh typed record. The exact shape is one outer result array containing one `[tag, item, fields...]` array per
  split item—there is no extra record wrapper. Receiver injection naturally supplies the source and preserves
  downstream array chaining; tree callbacks remain a separate later family.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.4 — implicit accumulators are typed bindings, not host scratch lists):
  Action-edge `.push` and block child-push forms must reuse `edge_state.child_result`; re-running the child after
  the parent edge consumed its token is both duplicate work and semantically wrong. The current rule accumulator
  therefore enters `lookup_binding` as a typed array, child rule names take static precedence, literal nonnegative
  indexes disambiguate before target names, and selected values use the ordinary append seam. The first test exposed
  the causal host leak directly: a plain Lua table could accumulate values but failed runtime kind checks once read.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.3 — array value and dropped-statement forms need one explicit boundary):
  Lua can share copied transform evaluation across functions and receivers, but `join_values` needs delimiter-first
  receiver injection and dropped bare transforms need a separate kind-checked write-back seam. Reference probes
  establish seven rebinding helpers: split/trim/filter/case plus `uniq`. Rust, Dart, and Julia currently intercept
  only four, silently dropping three updated results; they also stringify invalid join sources differently.
  `FUTURE-PARITY-BACKLOG.5` owns that cross-backend drift rather than letting Lua inherit it.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.2 — copied selection needs an explicit index/count policy): Lua uses one
  nonnegative integer adapter for take/drop and zero-based slice, copies every returned container, compares
  membership through the portable scalar-text boundary, and preserves first occurrence order in `uniq`. The
  focused proof exposed pre-existing negative-count drift: Lua and Dart clamp to zero, Julia falls back to a
  default, and Rust can turn a signed negative into an oversized count. That is a cross-backend contract decision
  for `FUTURE-PARITY-BACKLOG.5`, not a reason to import one host accident into this bounded Lua slice.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.1 — splicing is syntax context, not an array runtime tag): A computed array
  alone cannot say whether its parent should retain it as one nested value or insert its members. Lua therefore
  classifies only the authored argument/item AST—a direct `flat`/`flat_array` call or fluent chain ending in one—
  as a splice, then copies the evaluated value. Evaluation remains exactly once in source order. Toolbox follow-up
  found a separate pre-existing boundary: Perl rejects direct zero/variadic flat/concat forms that Rust, Dart,
  Julia, and Lua currently return as copied lists. `FUTURE-PARITY-BACKLOG.5` owns normalization; this Lua slice does
  not conceal the divergence or reinterpret ordinary arrays as implicit splices.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.11 — a runtime contract is not proven by statement-only tests): Perl's
  array-end runtime primitive already returned an independent updated array, but value-position ActionIR still
  excluded the four method names. That mismatch survived because earlier proof exercised dropped statements and
  general mutation results without executing all four saved results plus a receiver continuation in generated
  Perl. Mutation-result parity must therefore lock the full route: named receiver lowering, assignment/rebinding,
  returned snapshot, later-update isolation, continuation family, invalid temporary receiver, and backend docs.
  The recurring surface checker separately preserves dated slice history while rejecting it as current guidance.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.4.0 — later neutral contracts supersede earlier slice boundaries): The
  original array-end method slice was deliberately statement-only, but `linkedspec-uniform-binding-v1` later
  adopted updated typed values for every mutation unless explicitly overridden. Perl, Rust, Dart, Julia, and Lua
  now support end-mutation continuation and independent saved snapshots. Public/KM text that still presents the
  earlier result boundary as current is contract drift, not an implementation choice; `.12.1.11` owns repair and
  a recurring guard before Lua array breadth uses the result rule.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.4 — closeout proof must enumerate overload spellings): Aggregate reducer
  behavior was complete, but the first focused fixture paired canonical and alias coverage across the family
  instead of invoking every spelling directly. Closeout now locks all six canonical reducer calls, all six word
  aliases, all six terminal array receiver methods, exact-one-array arity, invalid elements/kinds, empty policy,
  source preservation, and terminal continuation without beginning general array helper behavior.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.3): One-array min/max must dispatch before scalar variadic min/max without
  weakening scalar v1 arity. Reducers parse elements through the same strict numeric admission, copy before median
  sorting, normalize results, and make every array receiver reducer terminal.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.2 — canonical call support does not imply receiver or nested symbol
  support): Alias resolution already made direct word/symbol calls work, but the generic fluent fallback evaluated
  method arguments without injecting the receiver. Numeric chains need an explicit evaluator branch and comparison
  terminal fence. Separately, a slash callee inside an harray follows `:`, which is also a legal regex-start context;
  scanner disambiguation must recognize the complete parenthesized `/` call without classifying `/pattern/flags`,
  zero-width lookarounds, character classes containing `)`, or deliberately invalid regex fixtures as calls.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.10 — public inventories must discover component documentation): A
  hand-curated root/capability/mdBook list can report zero current examples while backend README files still teach
  removed syntax. Public no-drift therefore discovers all immediate component READMEs, locks the resulting file
  count, and requires backend-specific current anchors in addition to scanning negative historical references.
  This turns adding a new component README into a deliberate inventory update and prevents runtime/source
  retirement from being declared publicly complete while a backend's own entry document contradicts it.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.1.4 — numeric policy must be helper-local and host-independent): Lua's
  `tonumber`, arithmetic, and comparison operators are useful only after LinkedSpec has enforced its own decimal
  grammar, value kinds, and arities. Signed modulo must use `a - floor(a / b) * b`, rounding must be explicitly
  half-away from zero, and every result must be finite and normalize negative zero. Keeping those decisions in one
  `scalar_numeric.lua` evaluator prevents generic scalar conversion from broadening numeric calls and keeps both
  Lua ABIs on the same contract. A composed checker is necessary because six separately green tests would not by
  themselves prove that every runtime consumed the same 55 cases and exact expected value.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.9 — executable retirement does not automatically retire public prose):
  Runtime/source gates were complete, yet public status still called exact selectors “future-invalid,” referred to
  remaining backend recognizers, preserved old positive examples without historical qualification, and retained a
  future capability exclusion. Final admission therefore needs its own composed gate: scan every root/capability/
  mdBook public file, require explicit removed/rejected/migrated context for exact mentions, require current bare
  examples, forbid stale rollout status, prove the future exclusion absent, then compose runtime/source and
  capability checks. This preserves legitimate boundary/history evidence without teaching removed syntax.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.6 — cross-variant retirement needs a composed recurring guard): Five
  strong backend rejection suites do not by themselves prevent shared-contract drift or the return of a runtime
  compatibility branch. The canonical checker therefore owns the invariant as a composition: exact neutral case
  and field consumption, backend-specific compiled-state admission anchors, eight retained constructor/literal
  classes, a denylist of removed runtime mechanisms, and the executable-source classifier. This catches both
  admission drift and implementation resurrection. The closing audit found only one stale compatibility comment;
  runtime compatibility remains zero across all five backends.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.5 — Lua needs validation at both compile and runtime-engine admission):
  Lua compiled state is mutable by host code and contains typed rule ActionIR beside deferred function/fluent source.
  Compile-time inspection must therefore cover typed nodes and every valid deferred source, while engine construction
  must repeat the check so a caller cannot mutate a compiled payload after compilation. Once those two admission
  points own portable rejection, wrapper-aware target descriptors and special array/hash read/set/push/receiver/
  split/transform branches can be deleted without leaving a bypass. Both PUC Lua and LuaJIT pass 88/88 plus exact
  105-manifest/CLI-scaffold checks.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.4 — Julia selector rejection must validate both typed and deferred
  executable state): Julia compiles rule action blocks to typed ActionIR, but user-function bodies and raw fluent
  arguments retain deferred source until runtime. Recursive typed inspection alone would therefore leave unused
  functions and some edge fluents as bypasses. Whole-compiled-state validation parses and inspects valid deferred
  sources while deliberately preserving the historical timing of unrelated parse failures; generated emission and
  plan entry repeat the validator for caller-constructed compiled state. After this boundary is authoritative, all
  runtime selector read/target/receiver/split/transform recognition can be deleted. Focused proof is 59/59 and the
  complete 1,339-assertion/61x2/105 Julia gate passes.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.3.2 — a bounded regex bridge must preserve capture shape, not only
  recognize the new pattern): Adding `blkVFN` to the detector is insufficient. The variadic function regex has a
  different prefix and four consumed captures—name, optional fixed parameters, rest parameter, and body—versus
  three for fixed `blkFN`. Because runtime capture lists omit null groups, materialize an empty optional-parameter
  placeholder so later rest/body indices remain stable. Select the prefix and capture list from the named-block
  family, preserve the matching
  named capture, and lock both paths together. The resulting adapter restores all four `spec_spec_*` cases and the
  complete 205-test/61x2/105 Dart gate without pretending Dart RegExp gained general recursion.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.3.1 — validate deferred Dart ActionIR without changing unrelated
  parse timing): Dart rule payloads are typed during compilation, but unused user-function bodies and edge fluent
  arguments remain source strings until runtime. Whole-compiled-state retirement must parse those valid deferred
  surfaces solely for structural selector detection and preserve existing runtime timing for unrelated parse
  failures. Repeat validation at generated emission and plan-validation boundaries because public constructors can
  assemble a `CompiledSpec`. Once that boundary rejects the exact shape, delete runtime wrapper reads/targets/
  receivers/split branches; retained one-argument quoted/computed constructors remain values.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.3.1 full-gate finding — exact bounded regex bridges must evolve with
  their shipped pattern owners): Dart's structural PCRE bridge intentionally recognizes exact shipped families.
  The complete test leg reached 203 passes but four `spec_spec_*` executions aggregated into two failures because
  fixed function definitions use `blkFN` while the later variadic pattern uses `blkVFN`. This is not a general
  recursive-regex gap and not caused by selector retirement. Pending `.12.1.8.3.2` must add the exact variadic
  prefix/capture shape, lock both fixed and variadic forms, and rerun the complete Dart gate.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.2 finding — time parser construction separately from parsing): Two
  complete oracle regenerations died at `vhdl_library_use` under the generator's default 15-second process bound.
  A direct split measurement showed healthy `get_parser('vhdl')` construction at 19.627 seconds and fixture parsing
  at 0.001 seconds. Use `ORACLE_TIMEOUT=30 perl -Iperl tools/gen_oracle_corpus.pl` for current complete
  regeneration. Pending `.7.0` owns a measured default adjustment while retaining the per-case fork/`SIGKILL`
  boundary and `ORACLE_TIMEOUT=0` kill proof; do not misclassify parser-build budget as a regex/parse hang.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.2 — validate complete compiled state, not only parser entry): Rust
  lifecycle code is typed during compilation, but action/blind-edge fluent arguments remain serialized strings
  until runtime. Hard language retirement therefore needs a recursive `Expr`/`CodeBlock` detector plus one
  whole-`CompiledSpec` validator that reparses those deferred arguments. Run it after every function and rule is
  compiled, and again at generated-source serialization/deserialization boundaries so dead code, unused functions,
  and untrusted compiled JSON cannot bypass the rule. Once validation owns compatibility failure, delete selector-
  specific runtime read/target/assignment/receiver branches; bare typed bindings are the only public authority.
  Keep rejection shape-exact so zero/multi/quoted/computed constructors and direct literals remain values.
  Source migration can leave test names and two-sided assertions describing wrappers after both sides became the
  same bare source. Rename the identifiers and replace identical comparisons with direct mixed-kind binding proof;
  otherwise internal terminology continues teaching a language surface that no longer exists.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.1 — reject authored selectors at the canonical AST boundary): A
  generated-code sentinel such as `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:*` is not a hard compiler error; it can
  compile and silently yield `undef`. Exact aggregate selectors therefore need structural validation immediately
  after canonical ActionIR parsing and before lowering. Walk the AST rather than searching raw text so whitespace,
  nesting, dead branches, and method continuations are covered without rejecting quoted/computed/multi-argument
  constructors. Validate user-function bodies while building the registry as well, because an unused function is
  otherwise never lowered. Preserve the neutral surface/identifier/replacement fields through live compilation and
  generated-source failure. Keep generated Perl `$name`/`@name`/`%name` out of the public-language analysis.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.8.1 — executable-source scans must accept layout whitespace): The first
  full Phase 0 rejection run found `array (items)` / `hash (meta)` embedded residues missed by a scanner that
  allowed whitespace inside parentheses but required `array(` / `hash(` to be adjacent. Source classifiers for
  optional-call-spacing languages must include `\s*` before `(`. The corrected scan found and migrated the Perl
  call-spacing fixture, its Rust mirror, and the oracle generator; it now reports zero positives/19 classified
  recognition sites. Regenerating the oracle also refreshed five already-stale source-backed input fixtures; always
  compare generated inputs to their canonical `specs/*.spec` owner rather than discarding such drift as noise.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.14.0 — distinguish structural, progressive, and staged composition): The
  authoring model has three separable layers. Small regexes identify lexical leaves or entry/exit boundaries;
  linked action-edge OR and blind-call AND rules own deep recursive structure. Progressive parsing is active-parse
  composition: capture an awkward region relative to reliable cursor anchors and invoke the appropriate loaded
  spec parser over the extracted text. Staged parsing is post-AST composition: preserve bounded raw fields with
  provenance, then let later spec parsers refine selected fields into a richer AST level. ADR 0012 remains the
  umbrella parse-graph architecture, but the current function-body `body_parse_job` proves only one narrow family.
  General public parse jobs, arbitrary in-parse composition, multiple parser families, and recursive queues must
  not be documented as shipped until `.14.2-.14.4` prove them. The current EBNF walkthrough explicitly uses
  recursive regex definitions and the portmap walkthrough praises one complex regex; `.14.1/.14.4` must reconcile
  those examples with the target idiom rather than letting exceptions silently define authoring guidance.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.7.3 finding — a thin facade can turn a missing internal method into a
  misleading plugin error): `tools/inspect_spec_codegen.pl` still invokes
  `LinkedSpec::_rewrite_action_code_with_diagnostics` and `LinkedSpec::_render_method_call_chain`, but Phase 1A
  moved those implementations to `RuleIR::EmitContext` and `BootstrapSpec::Core`. Facade AUTOLOAD then routes the
  missing names through `PPlugin`, yielding `Unknown plugin` rather than a missing-method diagnostic. Git history
  ties the inspector to `2984fb50` and the uncoordinated facade removal to `e964d9a4`. Keep the repair out of the
  dirty selector leaf; `FUTURE-PARITY-BACKLOG.13.1` owns explicit-owner routing plus a recurring four-form smoke
  test after selector retirement.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.7.3 — preserve spec-level binding names until aggregate ownership is
  known): Embedded-source migration exposed two opposite mistakes hidden by the same old array-first fallback. A
  user-function local is a scalar-held runtime typed value, so the aggregate AST bridge must pass bare `items` to
  `copy(items)` instead of prematurely manufacturing the Perl-only `copy($items)` spelling. A rule label, however,
  owns a real private implicit array accumulator unless the rule explicitly rebinds that same identifier. Seed that
  ownership in type memory so `copy(rule_label)` snapshots `@rule_label`; let an authored scalar binding override
  it. This is explicit ownership, not revival of a public aggregate namespace.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.7.3 — helper arity precedes optional legacy scope stripping): Once
  embedded sources use bare collection arguments, a canonical first argument may look exactly like the old
  injected scope token. For helpers whose supplied argument count already satisfies the current contract, keep the
  entire list; consult optional-scope normalization only when canonical arity does not fit. Otherwise `take(items,
  count)`, `pick_keys(meta, key)`, and similar calls silently lose their actual target. The same rule applies to
  three-argument mutable split and scoped fluent push recognition.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.7.2 — migrate complete file-backed behavior, not just syntax): Moving all
  390 remaining selectors out of 67 file-backed specs showed where wrappers had hidden runtime assumptions. An
  `I { name = [] }` assignment is rule-invocation-local just like the prior explicit reset; a bare compiled rule
  name may supply its empty implicit accumulator when otherwise unbound; static rule dispatch still precedes an
  ambiguous bare `push`; and an explicit non-undef typed binding must not be overwritten by a descriptor alias.
  Rust action-edge fluent mutation must use the same typed binding as ordinary mutation. Keep recursive fixtures
  canonical with bare initializers and shape literals, avoid binding/rule name collisions, and use value-level
  composition rather than resurrecting a selector to branch on a value kind.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.7.1 — pure reads must follow uniform mutation storage): Shipped-source
  migration proved that enabling bare mutations is insufficient if read-only helper fast paths still select host
  aggregates. In generated Perl, `$name` is the scalar-held typed binding; `@name`/`%name` are private legacy
  machinery, not a second `.spec` namespace. Bare helper inputs with remembered uniform-binding ownership must
  therefore bypass aggregate-symbol fast paths and lower through `$name`; flow emptiness must inspect scalar,
  ARRAY, and HASH values, and `print_each` must avoid treating its first bare argument as an optional scope token.
  Exact inventory regexes must also require a left identifier boundary: without it, `flat_array(name)` falsely
  contributes an `array(name)` suffix (51 overall, 17 shipped).

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.6 — static names precede typed binding mutation): Lua's existing
  `lookup_binding` already provided the correct read seam, but `push` was still accumulator/rule-only and mutable
  split required a wrapper. Resolve a registered rule first; otherwise mutate the bare target's runtime array kind.
  The same array seam must serve `+=`, split, array-end methods, and standalone transforms, return copied updates,
  and reject incompatible values. The first full gate correctly identified the old bare-split no-op lock.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.5 — mutation authority follows `_read_runtime_store`): Julia's
  `variables`, `arrays`, and `hashes` maps remain private migration machinery, but mutation must resolve the same
  value as a bare read before validating its kind. Central array/harray mutation and bare-store seams eliminate
  silent retagging, return copied post-operation values, and let array-end results continue through fluent methods.
  Full-package locks again showed why wrapper/bare mixing must expose one value: value-position mutation and bare
  hash merge previously encoded the obsolete namespace split.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.4 — migration stores must converge at every read and mutation): Dart's
  `variables`, `arrays`, and `hashes` maps may remain private compatibility machinery, but `ActionVariableExpr`
  cannot read only one map and mutations cannot silently create another. Central typed read/array/harray mutation
  seams make absent creation, kind mismatch, copy-return, and wrapper bridging consistent. Statement interception
  must delegate to the same value-returning array-end operation used by expression chains. Static rule lookup stays
  before bare push. A full-gate bare `merge_hash` lock proved that wrapper/bare mixing must alias one current value
  until selectors are migrated, not merely make the new syntax work in isolation.


- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.3 — centralize typed mutation, not private storage): Rust can retain
  separate scalar/array/hash maps internally while exposing one `.spec` binding only if every bare mutation first
  reads `get_bare_value`, checks the actual `RuntimeValue` kind, and writes back through one kind-preserving seam.
  Updating only expression evaluation is insufficient: statement dispatch may intercept the same AST first. The
  full oracle caught exactly that split for `items += value`; both statement and value forms now delegate to
  `eval_array_append_expression`. Static rule lookup must happen before ordinary bare push dispatch, and generated
  execution must consume the same `Engine`, so neither path invents a second binding model. Temporary selector
  compatibility remains a migration input, not authority for future behavior or a reason to expose host maps.
  Historical tests that explicitly assert statement-only mutation results are contract locks, not incidental test
  text; migrate them to the adopted expression result instead of weakening the new implementation around them.
Engineering notes for LinkedSpec refactoring and stabilization.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.2 — return a new typed value from mutable operations): Perl references
  make an apparently returned array/hash value alias later in-place changes unless the mutation boundary copies.
  Uniform binding mutations therefore copy the current array/harray, apply the update, bind the copy, and return
  it. This preserves the neutral contract's saved intermediate results and makes chaining predictable. Keep
  backend host storage private: wrapper-era source probes may still lower through host aggregates when no rule type
  memory exists, but generated rules with a known typed binding must harmonize reads and mutations. For ambiguous
  two-bare push, inspect the registered descriptor entry at runtime and accept either direct CODE or handler record;
  static rule purpose wins, otherwise mutate the first binding. Array reducers and receiver helpers must consult
  the remembered scalar-held kind before taking `@name`/`%name` fast paths.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.1 — callable purpose resolves bare-target ambiguity): Do not replace
  aggregate selectors with a new target wrapper. A bare identifier is always the binding; helper arity and purpose
  determine whether it is read or mutated. For ambiguous `push(name, target)`, a statically registered rule keeps
  precedence, otherwise `name` is the array binding. Two-argument split is pure; three-argument split mutates the
  first bare binding. Both `set` and mutable operations yield typed post-operation values for chaining. Reject an
  exact one-bare `array(name)` even when construction was intended; `[name]` is unambiguous. Keep non-selector
  constructors in contract v1 so selector removal does not silently expand into a different language change.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.1.0 — remove the public namespace before refactoring host storage): One
  `.spec` identifier must expose one typed value, but that does not require every backend to collapse its internal
  maps in the same slice. Make bare reads and mutations semantically complete, migrate sources, then delete exact
  `array(IDENTIFIER)` / `hash(IDENTIFIER)` recognition so no alternate namespace remains observable. Preserve
  static child-rule precedence when `push(name, value)` is ambiguous and define three-argument `split` as the
  mutable bare-target form. `set(target, value)` must return the target's post-assignment typed value. Exact scans
  find 600 selector calls/82 specs after requiring a left identifier boundary; the earlier 651 count included 51
  `flat_array(name)` suffixes. Backend enablement must precede source migration and hard rejection.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.3.4 — structural parsing and semantic admission remain distinct): The
  closeout confirms the parser may recognize receiver attached-block structure generically while callable metadata
  remains the sole semantic gate. Exact attached/parenthesized lowering, typed descriptors, zero migration
  telemetry, and closure-free source scans leave no Perl residue to repair. The next public-language correction is
  settled: spec-facing `array(IDENTIFIER)` / `hash(IDENTIFIER)` must disappear as namespace selectors, typed reads,
  mutation targets, and mutation authority. `.12.1` must inventory and migrate them, split backend/diagnostic/hard-
  retirement work, and treat ordinary non-selector constructor classification as a separate question.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.3.3.2 — parse broadly, grant semantics from metadata): Receiver attached
  syntax should produce a structural call candidate without deciding which method accepts it. A shared callable
  contract then validates the final slot and arity and converts contextual `{ ... }` into one zero-positional
  `codeblock_argument`. Keep explicit `{|params| ...}` records unchanged and reject harrays at the typed call
  boundary. User-function grammar, staged records, helper contracts, and receiver contracts must carry the same
  final kind; reconstructing or inferring it from names/body text would create a second authority. Director
  clarification also reaffirms that `set(target, value)` evaluates to the target's post-assignment typed value, so
  later methods should chain from that value. The remaining `.spec`-facing `array(name)` / `hash(name)` namespace
  and mutation forms are scheduled for removal under `.12.1`; that public-surface migration is not part of this slice.
  Until that retirement lands, grammar-owned declaration components stay ordinary typed data and are canonicalized
  at the registry boundary rather than using `array(name)` to gain mutation authority.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.3.3.1 — a receiving type is not a duplicate function signature): Declare
  only `name: codeblock`. An explicit `{|params| ...}` value owns its fixed/rest signature; a contextual `{ ... }`
  value has zero positional params and reads dynamic context. Reject `name: codeblock(params)` rather than adding
  static higher-order typing to a duck-typed language.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.3.3.0 — arity is not a contextual-callback declaration): A callable record
  needs one additional fact before attached block sugar is safe: which final call parameter has kind `codeblock`.
  Do not infer it from an untyped final parameter, body calls, parser callee-name lists, or brace contents. The audit
  initially overreached by asking the slot to duplicate callback params; `.1` corrects that design.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.3.2 — dynamic context should be explicit dataflow, not a host closure):
  Keep the codeblock record pure data. At generated call sites, pass references to the rule's known scalar working
  slots into a narrow typed ActionIR evaluator; this makes caller visibility reviewable and lets temporary fixed/
  rest bindings restore deterministically on every exit. Resolve governed helpers and registered functions first,
  then treat a bound scalar call as the dynamic fallback. Use typed path access for a call result before receiver
  continuation—Perl's `->[index]` syntax cannot guess harray versus array from a DSL `[...]` suffix.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.3.1 — source-bearing data must survive later source rewriting):
  Recognize `{|` before harray/eager-block classification and keep codeblock body variables out of construction-
  time declaration traversal. Do not serialize source-bearing ActionIR records as visible Perl string literals:
  later compatibility passes can rewrite their contents, and double-quoted dumps can interpolate caller variables.
  Canonical UTF-8 JSON encoded as ASCII hex keeps generated state inert, deterministic, and closure-free. Decode
  only at runtime into ordinary data; defer all call resolution/execution to `.11.3.2`.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.2 — model scope explicitly before choosing host machinery):
  Keep the neutral codeblock record as signature/body/source/spans with no captured environment field. Verify
  dynamic caller reads, persistent nonparameter mutation, temporary parameter restoration, block-local return,
  recursion fences, and static name precedence in a small independent evaluator before any backend can encode a
  host closure shortcut. Classify exact `{|` first; keep harray and eager-block classification separately locked.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.11.1 — distinguish deferred callable data at the first brace token):
  Parse exact `{|` before the existing harray/eager-block classifier; do not infer callable intent from colons,
  statements, assignment target, or host closure types. Store typed signature/body/source only. At `cb(args)`,
  evaluate values first, install copied temporary params/rest, and execute against current nonparameter stores;
  construction captures nothing. Keep static helper/control/user-function resolution stable and preserve `with`
  as a signature-governed ordinary helper. Lexical capture requires a later explicit contract if genuine use
  appears.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.4 — route semantics to the first executable dependency boundary):
  Lua's completed shell/registry/frame/compiled-state seams are structural, not runtime claims. Route the adopted
  v2 signature to `.5.1`, where staged body dispatch, ordered argument evaluation, and isolated execution first
  coexist after helper/value/control dependencies. Keep descriptor admission in `.5.3` and make generated `.8`
  preserve and independently execute the same typed union. A capability future row should name the remaining
  backend owner, not a closed umbrella task or already-complete backend rollout; owner validation must discover
  every task tree whose leaf IDs are valid capability owners.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.3.2 — generated Julia should reconstruct the ordinary typed AST):
  Carry one `CallableSignature` through Julia's ordinary `SpecFile` JSON union so normalized source emission and
  generated execution reuse the native compiler/runtime. Keep derived prefix params/minimum arity internally but
  expose only `signature` in v2 staged/public records and validate every copy. Resolve registered keywords before
  arity to prevent host keyword dispatch from entering `.spec`. Bind extras after eager ordered evaluation into a
  new recursively copied vector in both scalar and typed-array local views, so returns and aggregate mutation see
  one fresh LinkedSpec array without Julia splat semantics.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.3.1 — generated source should reuse normalized native state):
  Carry one typed signature through Dart's ordinary `SpecFile.toJson`/`fromJson` union so source emission needs no
  variadic-only code path: emitted Base64 state reconstructs the same registry and executor. Keep derived prefix
  params/minimum arity internally for the existing runtime, but expose only `signature` in v2 staged/public records
  and validate the two views agree. Resolve registered keywords before arity so Dart's parser-level keyword nodes
  diagnose as positional-only rather than silently becoming host-style named arguments. Bind extras with the same
  deep-copying function-parameter helper to guarantee a fresh typed list per invocation.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.2.2 — normalize internally, preserve the public union):
  Rust can retain derived fixed-prefix `params` and minimum `arity` inside its AST/compiled structs to reuse the
  established executor, while public and staged v2 records must expose only the authoritative `signature`. Validate
  the derived fields against that signature before compilation, serialize the typed signature into generated
  source, and make the runtime read `min_arity` from it. Bind rest values into both scalar and array views of the
  fresh function-local store so ordinary value returns and aggregate mutation share one typed array. A neutral
  result-chain fixture is also a useful semantic probe: it caught Rust's generic `length` treating arrays as text;
  correct that shared boundary and retain scalar Unicode length rather than special-casing user functions.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.2.1 — lower arguments before binding any parameter):
  A rest parameter is not host splat syntax. Lower every authored argument to a source-ordered temporary first,
  then bind fixed names and allocate a new array from the remaining temporaries. This makes once-only left-to-right
  evaluation visible and keeps the callee from affecting caller evaluation. Version-2 records must carry only
  `signature`, including staged payload/job copies; keeping `params`/`arity` too would create two authorities.
  Contract fixtures that return a new value kind through a receiver chain can expose older helper drift: the array
  `.length()` case found Perl stringifying array refs despite the book's string-or-array promise. Correct the shared
  semantic lowerer and lock both scalar preservation and array cardinality rather than special-casing the fixture.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.1 — version the new case instead of weakening the old one):
  Preserve fixed-function version 1 and its exact `params`/`arity` forever. A variadic definition is version 2 and
  carries one nested signature, so tools never guess whether `arity` means exactly or at least. `...rest` is final
  and positional-only; bind extras as an ordinary typed array so existing value/method dispatch works without a
  host rest-parameter object. Keep current capability green and list the feature as owned future until every
  admitted backend consumes the same fixture.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.4.0 — variadicity is a versioned signature, not a loose call check):
  Built-ins already distinguish exact, bounded, and open upper arities by purpose. User-function `arity` is public
  staged/compiler data repeated through every backend, so do not reinterpret it locally as a minimum or merely
  relax a runtime check. Adopt one explicit final rest binding, preserve fixed positional params separately, bind
  extras as a fresh typed array, and evolve descriptor/payload/job diagnostics and generated execution together.
  Unique function names mean this is not overload resolution; host splat/named/default semantics stay out.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.1.3 — arity belongs to the callable contract):
  Do not infer variadicity by folding arbitrary extra operands. Add/multiply/min/max are purposefully unbounded;
  subtraction/division/modulo, unary operations, clamp, and comparisons have exact arities. Apply those decisions
  at the helper boundary and keep aggregate overloads explicit. User-defined functions need a grammar-owned final
  rest-parameter form and minimum-arity runtime binding; audit descriptors, staged jobs, generated source, methods,
  and every backend before selecting syntax from a host language.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.1.2 — narrow adapters prevent global coercion regressions):
  Numeric helper admission is stricter than general scalar conversion, so implement it at the helper boundary.
  Perl generated actions share one `LinkedSpec::Numeric` evaluator; Rust uses helper-local conversion instead of
  changing `RuntimeValue::as_number`. This aligns booleans, strict decimal text, arity, invalid results, rounding,
  and signed modulo without silently changing unrelated string, truthiness, or runtime APIs. Executable neutral
  fixtures that need a direct returned value should use an action edge plus child rule, not top-rule lifecycle `E`;
  the latter has a separately governed final-value boundary and can hide the helper result on Perl.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.1.1 — contract source and expected values must derive together):
  A neutral runtime fixture should not duplicate hand-maintained calls and results. Store structured cases, render
  the complete `.spec` deterministically, and independently evaluate expected values in the gate. This catches
  policy/schema/source/result drift before any backend consumes the fixture and keeps host adapters accountable to
  one exact boundary. Separate numeric acceptance from ADR 0028 scalar-to-text conversion.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.1.0 — never copy host numeric coercion):
  Canonical helper names are insufficient when each backend delegates numeric parsing, booleans, arity, remainder,
  or invalid defaults to its host. A reference backend can itself contradict the public invalid-to-null rule.
  Measure the whole admitted set, write one executable neutral contract, repair existing variants in bounded pairs,
  and only then add a new backend. Keep generic scalar-to-text conversion separate from numeric input acceptance.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.3.0 — canonical names are not runtime semantics):
  The Lua frontend already maps numeric words and symbols onto `num_*`, but the evaluator still needs an explicit
  finite-decimal boundary, invalid arithmetic fences, receiver injection, comparison terminal handling, and typed
  aggregate reducers. Keep scalar number composition separate from array-consuming terminals so later array helper
  breadth does not become an accidental dependency. Route full shipped proof to phase 6, not the focused family.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.5.1 — scan executable-looking historical prose):
  A retired helper can survive no-drift as positive roadmap history or a catalog heading even when code/spec scans
  are clean. Current public references should lead with the canonical name; historical names remain plain
  retirement prose so examples cannot be copied as apparently supported calls.

- 2026-07-12 (FUTURE-PARITY-BACKLOG.12.0 — compatibility needs an exit condition):
  Duck typing means the value, not wrapper syntax or backend storage namespace, selects helper/method behavior.
  Compatibility scaffolding may bridge a migration but must never silently become the permanent language model;
  record its removal condition before relying on it. Statement syntax is value-drop context over expressions, not
  a second semantic universe.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.5.0 — route proof by first missing mechanism):
  A shipped fixture containing a string mutation is not necessarily a string-family acceptance test. Probe the
  whole fixture and record its first missing mechanism; if control, output, array, or child-flow execution blocks
  the oracle, preserve the exact fixture under the later dependency-complete corpus owner and close the focused
  family with direct mechanism tests. Never weaken expected results to manufacture early green corpus counts.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.4 — wrapper shape spends mutation authority):
  Statement context and the explicit `array(target)` wrapper jointly authorize replacement; a dropped ordinary
  split call stays a harmless discarded pure expression. Reusing the pure split dispatcher prevents literal,
  regex, Unicode, empty-field, or invalid-input policy from diverging between value and mutation forms. Binding
  through the typed array store deliberately removes a prior scalar-held value at the same name.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.3 — spend dropped-statement context explicitly):
  Arity alone cannot distinguish overloaded `substr`: mutation requires a dropped call, four arguments, and a
  bare target. Regex replacement needs separate output/search cursors for global zero-width matches, just like
  regex split, while `$n` must index the native full capture-group vector rather than the compact capture list.
  In Lua, scalar lookup must test `nil` explicitly so a stored boolean `false` is not mistaken for absence.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.2 — separate split segment and search cursors):
  A zero-width regex delimiter cannot use one cursor for both output boundaries and match progress. Retain the
  segment start, advance only the search cursor by one decoded UTF-8 scalar, and emit the pending segment when the
  zero-width boundary is after it. Literal empty delimiters are a separate direct Unicode-scalar path. Returning a
  typed array from string `.split()` establishes the bridge without prematurely implementing the array method family.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.1 — adapt flags at the helper boundary):
  Rule regex compilation and helper regex policy share PCRE2 but not operation semantics. Normalize helper compile
  flags in deterministic order, ignore `g/o` only where the operation defines them as no-ops, and cache failed
  compilation as deliberately as successful compilation. Keep the regex value internal: it transports parsed
  pattern/flag identity into `matches` without becoming a fifth public LinkedSpec value kind.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.2.0 — split regex values from statement mutation):
  Preserving a regex literal in ActionIR is not the same mechanism as executing it. Route helper patterns through
  the existing PCRE2 owner, but keep helper flag policy in a strict adapter. Do not teach ordinary value evaluation
  to infer mutation from a call name: statement context plus arity and target shape distinguish pure `substr`/
  `split` values from scalar substitution and explicit array replacement. Scalar and aggregate mutation remain
  separate leaves because they cross different stores and snapshot rules.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.1.3 — keep value kinds distinct at text boundaries):
  Host interpolation is not a language contract. Give scalar conversion one explicit nullable result: strings,
  booleans, and finite numbers have canonical text; null and aggregate/codeblock values do not. Make `cat`
  propagate the non-text result instead of erasing it to an empty fragment. Preserve explicit expression-block
  evaluation and leave generic final-codeblock call syntax under its existing owner; value-kind policy does not
  authorize a syntax pivot. Keep retired helper names outside the repair.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.1.2.4 — keep Lua casing scalar-safe and host-independent):
  Standard Lua casing is byte/locale oriented. Decode strict UTF-8 into Unicode scalars, apply generated mappings and
  contextual properties, and encode scalars explicitly; run the identical code on PUC Lua and LuaJIT.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.1.2.3 — adapt generated scalar semantics to host string models):
  Dart `runes` and Julia character iteration both expose Unicode scalars, so the shared mapping/context algorithm can
  remain encoding-neutral. Generate native constant tables, preserve one scalar evaluator per backend, and make array
  forms reuse it. Keep trace/CLI protocol casing separate: those operate on fixed ASCII option/hex tokens, not DSL text.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.1.2.2 — load generated semantics at both emission boundaries):
  Generate backend tables from the already-validated neutral object so mapping/property policy has one source.
  Route scalar and array forms through one backend evaluator; otherwise `lowercase_each` silently remains a second
  authority. Fully qualified emitted calls are insufficient unless ordinary in-process compilation loads the module;
  load it from both ActionIR owners and declare it in independently emitted parser preambles. A fresh-process probe
  is the regression test for that dependency boundary. Keep generated backend files in byte-comparison CI.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.1.2.1 — preserve upstream bytes and gate logical data separately):
  Store exact Unicode inputs with deterministic gzip headers so upstream trailing whitespace survives while the repo
  whitespace gate stays meaningful. Hash decompressed bytes, record compressed sizes only as provenance, and derive a
  separate logical-data digest over sorted mappings/properties/rules. Make the checker independently parse and execute
  the generated JSON rather than trusting the generator's evaluator. Guard the conditional-rule inventory so a future
  Unicode release cannot silently add a default context or turn locale tailoring into universal behavior.

- 2026-07-12 (LUA-BACKEND-PARITY.4.3.2.1.2.0 — own Unicode casing as generated language data):
  Signoff parity cannot depend on a host runtime's Unicode release. Pin Unicode 17.0.0 full Default Case Conversion,
  generate every backend table from checksum-locked UnicodeData/SpecialCasing/DerivedCoreProperties inputs, and
  byte-compare regeneration offline. Include default context rules such as Final_Sigma, exclude locale tailoring,
  and never normalize implicitly. This gives expansions and combining outputs one durable meaning across UTF-8,
  UTF-16, and host-native string layouts without adding ICU/utf8proc runtime dependencies.

- 2026-07-11 (LUA-BACKEND-PARITY.4.3.2.1.1 — keep pure text dispatch explicit and lazy):
  Lua needs an explicit scalar-to-text boundary because `nil` cannot represent a stored null, tables have four
  semantic roles, LuaJIT/PUC number rendering can differ, and byte-oriented `string` functions are not Unicode
  semantics. Evaluate coalesce candidates one at a time, never with a pre-evaluated argument list. Implement literal
  transforms with plain search, and derive length/substrings from validated UTF-8 codepoint offsets. Receiver calls
  inject the receiver into the same pure dispatcher; terminal predicate/length results stop the string chain.
  Treat host coercion agreement as a separate neutral contract: current Perl/Rust and Dart/Julia seams disagree.

- 2026-07-11 (LUA-BACKEND-PARITY.4.3.2.1.0 — specify Unicode casing before copying host APIs):
  Unicode text identity and Unicode case mapping are separate from UTF-8/UTF-16 storage. Host convenience methods
  are not automatically a portable DSL contract: Perl/Rust full mappings, Dart simple mappings, and Julia mappings
  already disagree for sharp-s, dotted-I, and ligatures. Standard Lua's byte-oriented case functions are not an
  acceptable fallback. Pick and version one neutral case policy, lock it with cross-backend fixtures, then adapt all
  hosts to it; keep unrelated deterministic scalar/string execution independently shippable.

- 2026-07-11 (LUA-BACKEND-PARITY.4.3.2.0 — separate pure strings from regex mutation):
  Pure scalar conversion and string functions are deterministic value dispatch over `.4.3.1` stores. Regex-aware
  substitution and split mutation additionally depend on dialect flags, replacement expansion, native engine
  errors, syntactic target identity, and statement context. Keep them in ordered commits so false/null/coalesce and
  receiver rules can be signed off independently from mutation. The global `.4.3.9` reverse coverage gate remains
  the final defense against a name being recognized but never executed.

- 2026-07-11 (LUA-BACKEND-PARITY.4.3.1 — make host table intent and absence explicit):
  Lua tables cannot distinguish array, harray, codeblock, or incidental objects by shape. Route every runtime value
  through typed identity and copy helpers; use separate scalar/array/harray stores and restore them per rule. Treat
  DSL array indexes as zero-based, never autovivify missing nested intermediates, and return copied updated roots
  from assignment expressions. Do not use Lua `and/or` fallback where false is a legitimate value. Capture helpers
  must distinguish absent match, present zero-width match, empty collections, and the `(1,1)` no-match line/column
  origin. A regex portability claim must name the actual backend engine: both Lua ABIs use PCRE2, and Dart uses
  ECMAScript `RegExp`; their real fixed-width lookbehind paths pass even though native Lua patterns do not provide
  the same dialect. Current Rust uses RGX—the roughly 98% PCRE2-compatible engine—not its historical basic
  `regex`-crate path.

- 2026-07-11 (LUA-BACKEND-PARITY.4.3.0 — split by runtime mechanism, not catalog page count):
  A 239-name recognized surface is not an executable surface. Sequence Lua helper work from value/store identity
  into pure scalar and numeric evaluation, then aggregate mechanisms, then codeblock/control callbacks, then
  stateful cursor/capture behavior and diagnostic events. Keep diagnostic output separate because eager evaluation,
  parse-result neutrality, and sink routing are different from pure values. End with an exhaustive reverse check
  so every admitted current name has executable evidence or a deliberate later owner. Preserve recursive splitting
  as a requirement whenever a leaf grows beyond a signoff-sized mechanism.

- 2026-07-11 (LUA-BACKEND-PARITY.4.2 — catch control at the iteration boundary):
  `next()` is not a rule return. Catch it around one regex/blind attempt, count the consumed iteration, preserve
  cursor progress, and continue without running the skipped remainder. Keep fatal `exit_now(...)` as an immediate
  typed runtime failure, not a value. Lua's `and/or` idiom is unsafe for DSL values because valid `false` returns
  collapse into fallback values; branch explicitly wherever null and false must remain distinct. Child rules may
  read caller bindings but must restore the caller's scalar/array/harray state when they return, so clone rule-local
  stores at entry and restore the original references on every success/error/flow path. Keep this interpreter
  dispatch-facing; split helper breadth before implementation rather than hiding partial families in one evaluator.

- 2026-07-11 (LUA-BACKEND-PARITY.4.1 — bind the dialect, not merely a pattern library):
  Engine presence is not semantic compatibility. LPeg cannot serve as an arbitrary PCRE parser; shelling out would
  break native in-memory embedding, and a single C module cannot safely cross PUC Lua/LuaJIT ABIs. Keep the binding
  minimal—compile/match/captures only—then own neutral alternative selection, Unicode projection, entry/local
  registers, presence, and progress in shared Lua. Build each ABI into a unique workflow-owned temp directory,
  inject only its `LUA_CPATH`, and remove the root on every exit. Preserve byte/code-unit offsets internally because
  PCRE2 consumes UTF-8 bytes, but explicitly project Unicode character positions and reject mid-character cursors.
  Match presence must be an object/nil distinction: `[0, 0)` is a valid present zero-width match, never an absence
  sentinel.

- 2026-07-11 (LUA-BACKEND-PARITY.3.4 — compile to data before matching):
  Snapshot the typed source tree at the compiler boundary so effective state cannot drift under caller mutation.
  Preserve source definition order separately from deterministic last-definition order; even when normal validation
  rejects duplicates, the diagnostic/compiler model should remain explicit when validation is deliberately skipped.
  Resolve child regex slots into indexed pattern rows and retain structured refs/combined metadata without compiling
  a host regex prematurely. Parse every action-bearing role through the same ActionIR parser and concrete function
  registry so lifecycle, plain, action, and blind payloads cannot fork. Keep internal effective-state JSON separate
  from the exact outward descriptor schema, and mark future handlers as compiled-state-only until runtime exists.

- 2026-07-11 (LUA-BACKEND-PARITY.3.3 — preserve functions as data before execution):
  Snapshot typed definitions when building a registry so later caller mutation cannot silently rewrite compiled
  identity or staged work. Keep body jobs ordered and immutable stitching explicit; never let `body_ast` insertion
  mutate the source spec. Let ActionIR resolution depend on the tiny exact-call interface rather than registry
  internals. Invocation preparation should receive already-evaluated values, copy all mutable four-kind values into
  fresh stores, and accept neither caller state nor host functions. That boundary makes evaluation order a later
  runtime responsibility while structurally preventing implicit mutation and Lua closure capture. Recursion is an
  expected semantic rejection, so preserve rule, function, handler-source, stage, and cycle identity in its typed
  diagnostic. Under disk pressure, cleanup remains limited to unused artifacts owned by this repository/workflow;
  active or external project trees are observed but not deleted.

- 2026-07-11 (LUA-BACKEND-PARITY.3.2 — share admission, classify before execution):
  Action parsing and behavior admission are separate seams. Make the resolver consume typed nodes recursively and
  reuse validation's single current-name inventory; a second copied allow-list will drift. Keep alias canonical
  names, families, surfaces, source spans, and argument counts explicit so compilers do not infer contracts from
  Lua functions. Structural controls/assignments deserve contracts even though they are not host calls. Unknown
  and raw expressions become generic typed diagnostics and never global lookup. Reserve one registry interface
  ahead of its concrete owner so `.3.3` can supply ordered exact-arity resolution without changing traversal.
  Cross-check every governed symbol alias against parser reachability: that audit caught the missing current
  `=(target, value)` callee immediately.

- 2026-07-11 (LUA-BACKEND-PARITY.3.1 — parse structure before resolving behavior):
  Keep universal action text as typed AST, never Lua source. A shared byte scanner is safe only after strict UTF-8
  validation and must project every stored span through byte-boundary-to-Unicode-character indexes. Track quote,
  regex, parenthesis, bracket, and brace state together so physical newlines and semicolons split only at depth
  zero; recognize LF, CRLF, and bare CR, and keep semicolons as separators between same-line statements rather than
  terminators that examples append mechanically.
  Treat decimal dots separately from receiver-chain dots. Lua patterns have neither regex alternation nor
  non-capturing groups, so use explicit keyword sets and literal scanners. Preserve unsupported expressions as
  nodes for `.3.2` diagnostics. Parse generic trailing blocks as the final positional `block_value` independently
  of a callable name; contract resolution later decides whether that callable accepts the argument. This keeps
  `call(args) { ... }` structurally equivalent to `call(args, { ... })` across helper, function, and method forms.

- 2026-07-11 (LUA-BACKEND-PARITY.2.4 — consume spec-owned shells using character spans):
  Preserve the semantic owner boundary: a backend projector validates nodes returned by the definition spec; it
  must not recreate `fn` syntax with a raw scanner. Lua needs an explicit UTF-8 byte-boundary map because neutral
  spans count Unicode characters while Lua strings index bytes. Validate exact source/body slices before copying
  sidecars, normalize paths and deterministic IDs only after drift checks, and replace each stripped non-newline
  character with one space so line and character coordinates stay stable. Keep `body_parse_job` intact and
  `body_ast` absent until staged dispatch. Empty owning-node input is a valuable no-fallback proof.

- 2026-07-11 (LUA-BACKEND-PARITY.2.3 — make permissive parsing feed explicit acceptance):
  Keep parser recovery/raw nodes inspectable, then reject them in a separate validator. Validation order should
  stabilize the first actionable diagnostic: top/duplicates/function registry before raw/edge/regex/strict checks.
  A user-function collision check needs the complete current call surface, not a convenient subset; store one
  private Lua set and extend the existing cross-language checker so it cannot drift before later ActionIR reuses
  it. Exercise validation across all broad source inventories because it reveals parser classification errors that
  permissive parse-only tests miss—here, an empty `Child:` header exposed exactly that defect.

- 2026-07-11 (LUA-BACKEND-PARITY.2.2 — scan structure, preserve action text):
  Use byte positions for ASCII `.spec` delimiters over already-valid UTF-8 strings; substrings then preserve
  Unicode bytes without conflating Unicode with an encoding. Quote-aware brace/parenthesis scanners must treat both
  single and double quotes as delimiters and honor escapes. Keep the parser permissive and typed, leaving semantic
  rejection to validation. For compact lifecycle fluent syntax, normalize calls into multiple same-line statements
  with semicolons only between calls; preserve newline-delimited block text without adding semicolons. Prove all
  shipped sources and every rule-only corpus source on both runtime language baselines, while routing function
  shells only through their spec-owned later projection.

- 2026-07-11 (LUA-BACKEND-PARITY.2.1 — give Lua AST records identities before parsing):
  Do not let Lua table shape stand in for a semantic type. Use private metatables for source node variants and the
  typed JSON layer for scalar/array/harray payloads; represent codeblocks as an explicit body-kind node with exact
  lifecycle/code text. Validate dense one-based constructor lists and child node types, defensively clone arbitrary
  JSON sidecars, and project only through neutral field names. This gives the parser a typed target while keeping
  source recognition, validation, ActionIR, and runtime ownership separate. Round-trip optional staged provenance
  and every body variant on both the Lua 5.4 and Lua 5.1 language baselines before parser work begins.

- 2026-07-11 (LUA-BACKEND-PARITY.1.3 — type JSON tables and declare byte boundaries):
  Lua tables cannot reveal whether `{}` means an array or harray, and `nil` cannot occupy an array slot, so decoded
  JSON needs private metatable tags plus a non-nil null sentinel. Reject plain tables on encoding instead of
  guessing from keys. Validate strict UTF-8 before JSON scanning, decode surrogate pairs deliberately, reject
  duplicate object keys, and recursively sort object keys for canonical output. Unicode remains the character
  model; UTF-8 is only the selected corpus byte encoding. Since standard Lua lacks directory iteration, isolate a
  read-only adapter using safely shell-quoted paths and NUL-delimited `find` output, then prove exact stale/missing
  membership and leave parser execution unavailable.

- 2026-07-11 (LUA-BACKEND-PARITY.1.2 — make unavailable behavior explicit at a new backend boundary):
  A useful native scaffold proves module discovery, runtime compatibility, command identity, and deterministic
  process failure without pretending that parsing exists. Return fresh status tables so caller mutation cannot
  alter later observations; keep command-stub messages in the module so tests and executables share one source.
  A repo-owned shell gate can syntax-check the shared Lua 5.1/5.4 subset and exercise PUC Lua plus LuaJIT without
  LuaRocks or global paths. Add typed JSON and manifest IO only in their owning leaf, then replace the corpus stub.

- 2026-07-11 (LUA-BACKEND-PARITY.1.1 — lock reproducibility before scaffolding):
  Separate runtime availability from dependency policy. PUC 5.4 and LuaJIT can share most source but have different
  language baselines, so make 5.4 normative and isolate compatibility adapters. Global LPeg modules prove only that
  a candidate exists; foundation code must remain independent until regex fixtures choose a mechanism. With no
  installed JSON/test/package tools, a repo-owned assertion driver and later pure-Lua typed JSON codec are safer
  than accidental home/global state. Always inject exact `LUA_PATH`; reserve temporary caller-owned trees for any
  future rock/cache proof and clean them recursively.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.3 — a new backend inherits the completed contract, not an old milestone):
  Lua planning starts after the four-backend census reaches 60/0/0, so its task tree must include every admitted
  native API, exact CLI, capability, staged/runtime/corpus, value-kind/block-syntax, and generated-source role from
  the beginning. Treat PUC Lua 5.4 as primary and LuaJIT as compatibility because their language semantics differ.
  Installed LPeg is only a candidate mechanism; prove regex behavior against neutral match fixtures. With no
  LuaRocks/Busted/lint/formatter installed, lock repository-owned package/test/cache policy before writing code.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.5 — close capabilities from executable evidence, then activate successors):
  Final admission should not invent another implementation layer. Recheck the executable 60/0/0 contract/census,
  every backend's focused proof, and the immediately adjacent complete gates; then align public/durable status in
  one no-behavior commit. Only after `.3` is closed may Lua planning activate, inheriting the complete contract
  instead of an obsolete interpreter-only milestone. Expensive cross-language proof regenerates large caches, so
  record sizes and delete only known reproducible target/depot/tool directories after results are consumed.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.4.3 — generated admission must remain interpreter-first and contract-owned):
  Read the eight names from contract v1 instead of duplicating a Julia list, retain exact manifest membership, and
  compare checked-in expected values through the ordinary/staged native frontend before emitting anything. Julia's
  fixed generated module name can still share one host process by including each source under a separate parent
  module; Julia 1.12 world-age rules require fetching/calling those freshly defined bindings through
  `invokelatest`. Checker-lock count, contract access, comparison order, v1 emission, independent namespaced load,
  trace/source identity, recursive cleanup, and no skip before promoting. Promotion is an explicit manifest and
  contract state change only after focused and complete package/CLI/corpus gates pass.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.4.2 — generated plans must be executable control state):
  Julia's compiled rule carries the same neutral classifier inputs as Dart/Rust: mode, repetition/AND flags,
  regex/action-edge counts, and blind edges. Validate arbitrary string rows before converting them into a trusted
  map so unknown-family and known-but-wrong-family errors stay distinct. Carry that map through the existing single
  recursive rule-entry seam and choose acode/regex versus bcode/blind dispatch there; nested calls then cannot evade
  the plan. Native calls omit the map and remain unchanged. A single combined emitted module is a compact isolated
  proof: ten selectable roots cover all families while child rows verify nested-plan propagation, and one host
  process can compare all results and portable trace identity without multiplying depot/package artifacts.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.4.1 — separate Unicode semantics from boundary encoding):
  Reconstruct a normalized effective AST from compiled order instead of serializing host caches or inventing a
  second compiler. Canonically sort JSON object keys, encode the Unicode payload and identity to strict UTF-8, then
  render those bytes as ASCII hex; this makes emitted Julia deterministic and immune to host interpolation while
  retaining the explicit fact that UTF-8/UTF-16/UTF-32 are encodings, not definitions of Unicode. A credible
  isolation proof needs a caller-owned project and writable depot, fresh processes, compiled modules disabled,
  offline resolution from an already-instantiated read layer, valid and corrupt module loads, and owned recursive
  cleanup. Keep family-plan/direct routing in the next leaf so a green scaffold does not prematurely promote the
  generated-source capability.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.3.3 — admission must consume the contract list, not copy it):
  Make the executable contract the only accepted-subset owner and have the backend test read it directly; then
  checker-lock the test path, exact count, contract access, interpreter-before-emission comparison, independent
  host compile/run, trace/source identity, cleanup, and no-skip property. This prevents a green backend-local list
  from drifting away from neutral admission. Include the staged user-function case so normalized compiled-state
  emission is exercised, not just rule-only fixtures. Promotion is an explicit final act after the focused host
  proof and complete backend gates pass together; update both contract state and capability census atomically.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.3.2 — a generated plan must control execution, not annotate it):
  Dart compiled state already carries the Rust-equivalent classifier inputs: exact mode, regex/action-edge counts,
  and blind edges. Derive the same ten neutral families from those fields and validate arbitrary string rows before
  converting them to a typed map, so unknown family remains testable and distinct from known-but-wrong family.
  Pass that map into the runtime context and select acode/regex versus bcode/blind dispatch on every rule entry;
  merely validating then calling the ordinary interpreter would make the table decorative. Emit portable trace
  roles around the existing native rule scope and preserve the richer trace. Prove the classifier and executor as
  one isolated multi-library host package so all ten families compile and run through emitted source, while keeping
  corpus admission separate and preventing an implementation-green result from silently promoting the census.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.3.1 — serialize effective semantics, not host build state):
  A first source-emitter scaffold can remain deterministic and caller-owned without inventing a second Dart
  compiled-state decoder. Reconstruct a normalized `SpecFile` from the effective ordered `CompiledSpec` functions
  and last-definition rules, serialize that neutral structure, and let the generated library compile it through the
  ordinary native compiler. Encode the payload as strict UTF-8 plus Base64: Unicode is the character model, while
  UTF-8/UTF-16/UTF-32 are encodings, and this contract deliberately selects strict UTF-8 at persistence boundaries.
  Base64 also prevents `$` interpolation from corrupting an embedded Dart literal. Prove independence with a
  caller-owned temporary package and private `PUB_CACHE`, offline resolution, analysis, direct execution, typed
  failure projection, and recursive cleanup. Do not promote Dart from gap until the separate family-plan/direct
  execution and manifest-admission leaves pass.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.2.2 — make breadth proof mechanically recurring before promotion):
  A green diagnostic does not become a capability guarantee merely by documentation. Remove ignore and opt-in
  strictness, let the normal backend package gate execute it, and have the neutral contract checker lock the exact
  test path, corpus count, ordinary execution, and unconditional failure predicate. Only then promote the census.
  Keep the compact eight-case/all-family tests too: they give faster focused localization while the full-manifest
  test supplies exhaustive recurring breadth. The resulting Rust pass means Dart/Julia are the only remaining
  generated-source gaps; do not reopen already-admitted Rust roles during their emitter work.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.2.1 — an empty classification is an actionable result):
  Recursive splitting doctrine does not require inventing repair work. When a complete classifier reports zero
  failures, enumerate every requested mechanism category, record each as empty, close the repair leaf without
  behavior code, and preserve admission as a separate act. This keeps implementation evidence distinct from a
  recurring capability guarantee while preventing speculative changes to already-correct code.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.2.0 — classify breadth without multiplying dependency builds):
  A per-case isolated Cargo project gives perfect attribution but scales poorly even when dependencies share a
  target: the measured prototype took about ten seconds per fixture. Preserve per-case source/test identity while
  batching host work: prepare every case independently through interpreter-first emission, write each generated
  module to its own file in one temporary crate, compile once, then run named serial tests once. Emit a success
  marker only after direct result, plan validation, and compatibility result all pass; terminal accounting must
  equal the manifest count. Keep the classifier explicit until recurring admission. The 105/105 result means the
  existing 8-case limitation was proof breadth, not an emitter semantic defect; do not invent repair work.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.3.3 — make capability promotion an explicit verified act):
  Green implementation tests do not silently change census status. Admission must rerun the contract fixture and
  complete backend gates, then update the executable contract, capability manifest, checker expectations, public
  book, and continuity state together. A backend may pass the neutral baseline while remaining partial for a
  separately quantified breadth obligation: Rust is now partial for exactly 8/105 generated fixtures, not for
  identity, errors, plans, results, tracing, families, or isolated compilation. State the residual mechanism in the
  manifest note so future work cannot reopen already-admitted roles or promote from implementation belief alone.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.3.2 — make result projection part of generated-source parity):
  Structural execution equality can still hide an API result-shape mismatch. Rust already separates legacy
  accumulator-returning `Engine::execute` from portable direct-value `Engine::execute_value`; source generation
  must mirror that split rather than invent a third convention. Keep two generated tables: the legacy typed enum
  table for exact adapters and a neutral string table for mutable contract validation. Validate unknown names before
  expected-family comparison so unknown and known-but-wrong families remain distinct. Add portable trace role marks
  within rule recursion while retaining native scopes/decisions. When one shared traced helper serves both APIs,
  select result projection explicitly; identity presence is the v1 route, not permission to alter legacy output.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.3.1 — add a contract surface beside compatibility):
  A typed public API can be added without silently changing an established string API. Make the legacy emitter a
  thin adapter with a stable default identity, but keep generated legacy entrypoints routed through their original
  raw-string execution functions so exact diagnostic text remains compatible. New generated entrypoints may expose
  typed stage/code/source/rule/family attribution. The host compiler lives outside the emitted module, so publish a
  constructor that lets the caller project compile/load detail into the same error contract. Box optional strings
  in a broad error record to keep `Result<_, Error>` below Clippy's large-error threshold without suppressing it.
  Metadata/error alignment does not imply plan/trace alignment: retain that explicit next-leaf boundary.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.3.0 — align a pre-contract implementation before admitting it):
  A green source-emitter test does not prove a later neutral contract unless every role is projected explicitly.
  Rust's scaffold correctly proves independent native compilation, all-family execution, and the accepted subset,
  but its original type boundary made identity absent, errors raw, unknown family unrepresentable, and trace names
  backend-native. Preserve that working compatibility API and rich trace; add a typed v1 request/error surface and
  neutral projections beside them. Keep metadata/errors separate from plan/trace because compile/load attribution
  and mutable malformed-plan testing have different ownership and failure modes. Capability promotion belongs only
  after both mechanisms and complete Perl/Rust gates pass; do not confuse the later 105-case breadth leaf with this
  baseline contract alignment.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.2 — reconstruct, do not stringify compiled regex state):
  `Regexp` stringification is not a serialization format when embedded code depends on dynamic lexical composition.
  Emit reconstruction from canonical dependency refs: quote each referenced compiled regex as data, compile it at
  generated-module load, and call `LinkedRE::oredRE(...)` so its alternative markers regain the relationship with
  `LinkedRE::or`. Prove indexes beyond zero and delimiter-bearing patterns. Keep public application emission separate
  from low-level debug flags, but require byte identity so two source paths cannot drift. Generated packages should
  validate immutable expected plan semantics before dispatch, wrap execution errors with source/rule/family identity,
  and emit trace roles outside handler-specific branch spellings. Source-shape locks must follow the public wrapper,
  not freeze a bypass around validation.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.1 — specify roles, not host spelling):
  A multi-backend source-emitter contract must not compare Perl/Rust/Dart/Julia source bytes or force one host's
  API names. Fix the semantic pipeline and observations instead: compiled state plus identity in, deterministic
  native source out, independent load, direct/traced execution, validated ordered family rows, stable attributed
  failures, and interpreter-first exact results. Keep structural coverage and corpus breadth separate. The strict
  checker cross-validates the accepted subset against the live manifest and current capability states, so fixture,
  census, and task drift fail the canonical gate before backend implementation begins.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.1.0 — generated text must be independently executed):
  A compiler that generates source internally does not necessarily expose a standalone source-emitter capability.
  Always compile/load captured text in isolation and compare it with the normal parser. Perl's dump preserved
  syntactically valid handlers but serialized a compiled regex whose embedded `$pos` index markers depend on the
  dynamic regex composition inside `LinkedRE::or`; stringification discarded that binding. Matching still advanced
  the cursor, making superficial compile/match checks pass while action dispatch silently skipped. Capability
  evidence therefore needs exact generated results and trace indexes, not source presence or successful `eval`.
  Correct the census immediately, define the executable contract, then repair the serialization mechanism.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.3.0 — contract first, then classify breadth):
  Generated source is one user capability implemented in different host languages, so parity cannot mean
  byte-identical source. Under ADR `0023`, fix equivalent emission, compile/load, direct execution, results,
  diagnostics, trace, identity, family-plan validation, and manifest proof while letting APIs/source syntax remain
  idiomatic. Keep structural-family proof distinct from corpus breadth: Rust's synthetic matrix covers all current
  families, yet only eight named fixtures compile/run through generated source versus 105 on the interpreter path.
  Add a scalable full-manifest classifier before fixes, recursively split any failure mechanisms, and never replace
  or weaken the interpreter oracle. Dart and Julia each need scaffold/harness, family-plan execution, and corpus
  admission as separate commits; final capability promotion belongs to one later four-backend closeout.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.6 — close a capability class, not complete parity):
  A 57/1/2 census can close non-codegen work only after direct enumeration proves every non-pass state belongs to
  generated source and carries the same durable owner. Keep the distinction explicit: current interpreter/runtime/
  API/CLI parity across four implemented variants is complete, but generated source remains user-observable and
  blocks the complete-backend claim. Activate `.3` without mutating status values in a documentation-only closeout;
  its first action must split Rust proof breadth from Dart/Julia emitter implementation before code.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.5.3 — caller owns emitter lifecycle across compilation and runtime):
  The native loader should accept and forward the emitter, but the compiled result should not retain it. Explicitly
  passing the same object to final engine execution preserves one ordering/sink/indent stream without coupling an
  immutable compiled artifact to mutable IO state. Wrap the loader once outside its existing stage-specific error
  projections, then rethrow unchanged so rich trace cannot alter structured API errors. Admission requires a routed
  all-phase test, a disabled identity test, a failure identity test, the complete backend gate, and census promotion
  together—not merely presence of optional parameters in inner owners.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.5.2 — nested trace must not broaden diagnostic catches):
  Thread the same emitter through parser-spec compilation, its runtime execution, projection, and staged jobs so
  event ordering and sink state remain genuinely caller-owned. Cache hits need decisions because a warmed default
  parser legitimately omits construction events. When adding outer scopes, preserve original catch boundaries:
  projection happens before the narrow stripped-rule `SpecParseException` translation, otherwise a function-shell
  diagnostic is silently relabeled as a rule-parse failure. A focused equality test now locks that distinction.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.5.1 — preserve source compatibility and exception identity):
  Optional named `trace:` parameters let the existing Dart operations participate in one pipeline without creating
  a parallel API family. Enter the owner scope once, nest downstream owners with the same object, and exit on every
  success/failure path before `rethrow`; callers therefore retain the original exception type/object semantics.
  Compiler validation must receive the emitter rather than merely logging around `validateSpec`, and registry
  construction belongs inside compilation so event indentation mirrors ownership. Do not promote a partial core-
  compiler path while function extraction, staged dispatch, and native loader composition remain untraced.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.5.0 — propagate one object, do not create traced variants):
  Dart already has the correct emitter abstraction and traced runtime entrypoint. Full-pipeline parity should add
  optional named emitter parameters to the existing parser, validator, compiler, function shell, staged registry,
  and loader APIs, preserving source compatibility and one sink/indent state. Separate traced entrypoints or fresh
  emitters per phase would fragment ordering, scopes, and routing. Implement frontend/compiler first, then the
  nested function/staged pipeline, and promote only after the public loader composes the same caller-owned object
  through compilation and runtime execution with traced/untraced identity proof.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.4.5 — separate portable policy from reference compatibility):
  Do not retrofit explicit request kinds and roots into `get_parser`, because its implicit `PathSearch` fallback is
  an accepted legacy extension. A separate `LinkedSpec::SpecLoader` makes the portable contract reviewable while
  reusing `Get` for compilation. Perl's compiler validates raw source before bootstrap parsing, so the facade owns
  a narrow public-stage projection: the “must start with a rule” guard maps to parse failure, other validation
  guards map to validation, and later failures map to compile. This preserves the neutral API without reordering
  mature compiler internals. Direct shared-fixture proof belongs in canonical CI, not only the schema checker.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.4.4 — remove discovery that the contract cannot explain):
  Julia's sorted recursive fallback was deterministic but still backend-only implicit discovery. Delegating both
  the public API and primary adapter to cwd/suffix/declared direct roots removes that semantic fork. The CLI keeps
  its existing request record and stable phase projection, but native name/file preparation now retains the full
  compiled result and avoids a second parse/compile path. Inline text remains on the traced in-memory path, and
  input files remain deferred until compilation succeeds. Julia `String(read(path))` can carry malformed bytes,
  so validity must still be checked explicitly before any parser sees the text.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.4.3 — keep CLI phase projection outside the native loader):
  The Dart native API owns precise resolution/read/decode/parse/validate/compile exceptions and retained source
  identity. The primary CLI deliberately catches those exceptions at its existing compile boundary and continues
  emitting the canonical one-line phase failure, so richer embedding semantics do not alter process bytes. Native
  named/file requests use the complete result directly; inline text stays on the prior in-memory route. Candidate
  construction splits portable named components on `/`, while explicit paths retain host syntax. A compatibility
  `resolvePrimaryCliNamedSpec` wrapper delegates to the native resolver, preventing a second policy from regrowing.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.4.2 — make the complete native result carry provenance):
  Resolution, loading, and compilation are useful independently, so expose progressive typed stages rather than
  one opaque convenience function. The complete result keeps the request, winning origin/path, exact decoded text,
  and compiled state; consuming it into an `Engine` is the single point that attaches diagnostic identity. The CLI
  can therefore delegate file work without owning richer semantics or changing its canonical failure projection.
  Candidate metadata errors remain resolution-stage structured detail, malformed bytes are decode-stage errors,
  and parser/validation/compiler failures keep distinct stages. A portable name also has to reject `C:/...` even
  on Unix—the neutral validator cannot depend on the current host's definition of absolute. Strict Clippy confirms
  no new findings; the known 14 are all outside the new loader/adapter code.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.4.1 — separate logical identity from host path):
  One overloaded string cannot safely mean both a portable named spec and an arbitrary filesystem path. Named
  identities use forward-slash components and reject absolute/traversal/host-separator forms; exact paths retain
  host syntax but never gain suffix or root fallback. Ordered roots are direct and caller-visible. Resolution skips
  an earlier directory when a later regular file exists, then reports the first non-file only if no file wins.
  Also keep the layers precise: Unicode is the logical scalar-text model, while strict UTF-8 is the selected file
  encoding. UTF-16/UTF-32 are not invalid Unicode; they simply require explicit transcoding at this API boundary.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.4.0 — make discovery policy caller-visible):
  A shared local-candidate prefix does not make resolvers equivalent when their fallback policy differs. Perl's
  `PathSearch` recursively caches process/repository directories and then destroys precedence through hash-key
  iteration; Julia has a deterministic but backend-only recursive fallback; Rust/Dart stop. Do not clone any of
  those accidents into new native APIs. The portable contract will accept explicit ordered search roots and test
  precedence directly, while Perl's implicit recursive search remains a clearly bounded compatibility extension.
  File-kind and strict-decoding errors must also belong to the native load pipeline rather than a CLI adapter.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.3.2 — admit a capability only after adapter no-drift):
  Typed native proof alone did not promote the census row. The recurring gate also re-proved generated source,
  tracing, and both exact CLI environments, confirming that richer library errors do not leak into the canonical
  process projection. Structured diagnostics now pass on all four variants; the census is 53/1/6 and native
  named/file resolution is next.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.3.1 — enrich errors once, adapt outward for compatibility):
  Existing string methods now call the typed diagnostic path and consume only `RuntimeExecutionError.message`, so
  success/error semantics cannot drift between two implementations. The context records first failure rather than
  last: child wrappers run first during unwinding, preserving deepest attribution automatically. Source name/path
  stays caller-owned engine metadata. Boxing the nested diagnostic keeps the typed `Result` error compact without
  changing its JSON object or accessor API.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.3.0 — repair the type users receive, not a similarly named enum):
  `linkedspec-runtime` does not use `linkedspec-core::LinkedSpecError::Runtime`; all active engine failures are raw
  strings. The singular interpreted attribution seam is `Engine::execute_rule`, where a child error is visible
  before rule-local/recursion unwind. Typed methods can therefore capture the deepest diagnostic there, retain it
  through parents, and leave current string methods as compatibility adapters. Optional spec identity belongs on
  the engine because compiled state does not retain filesystem provenance.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.2.3 — project public records separately from internal AST JSON):
  Descriptor parity is an exact user-facing schema, not permission to force every backend's internal AST
  serialization into one shape. `outward_descriptor_contract.json` is the singular neutral contract; Perl adds
  source-order `index`, while Dart/Julia use descriptor-specific projections to add `kind`, `version`, and
  `source_text` without changing their internal `toJson`/`to_json` consumers. All four focused tests read the same
  schema, so extra as well as missing public fields fail. The census is 52 pass / one partial / seven gap and Rust
  structured diagnostics `.1.6.3` is next.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.2.2 — project public state without making it runtime state):
  Keep the engine's `CompiledSpec` as execution truth and implement introspection as an owned typed projection.
  Preserve only information that cannot be reconstructed reliably—dependency refs in source order—on compiled
  rules; derive maps, combined patterns, and deterministic orders at the public boundary. A serde-defaulted field
  plus dispatch fallback keeps older serialized state readable. Also compare complete function records, not only
  nested staged payloads: semantic alignment can coexist with user-visible outer field drift.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.2.1 — name composed and nested models independently):
  One metadata field cannot accurately identify both an outward composed object and one of its components. Keep
  `descriptor_model` for the public composition, then expose `compiled_spec_model` and
  `compiled_dependency_regex_model` for nested identities. This removes ambiguity without renaming internal data
  structures or forcing tools to infer ownership from implementation history.

- 2026-07-11 (FUTURE-PARITY-BACKLOG.1.6.2.0 — probe the reference, but canonicalize by field meaning):
  A reference backend can preserve an obsolete metadata label even when its internal architecture has moved on.
  `descriptor_model` describes the public object being projected, so the composing `compiled_descriptor_state`
  owner is the canonical identity; `compiled_spec_state_v1` names only one nested component. Before implementing a
  missing backend API, compare the executable reference, current book, and already-implemented variants. Otherwise
  a new backend can faithfully reproduce drift instead of the agreed contract.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 — prove coverage bidirectionally):
  Comparing backend-derived inventories proves agreement, not completeness: two backends can omit the same
  reference contract and still match exactly. A durable capability gate must check inventory → documentation and
  neutral source, then independently check current reference-contract calls in that source → every backend
  inventory. Pair that structural proof with exact execution; recognizing all 239 names still does not establish
  their value, mutation, control, or capture semantics. Admit governed fixtures only after all variants pass the
  same generated values, so the mandatory corpus stays green at every commit.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3 — make semantic units explicit at API boundaries):
  Julia, like Dart, cannot safely slice multibyte input using public character offsets as raw host indices. Store
  marks in the host slicing unit, validate spans before extraction or advancement, and convert only public
  positions/lengths to characters. Keep named marks under the rule label rather than in one global name table;
  otherwise two independent rules using the same readable mark name silently share state. Finally, exercise the
  real blind-call wrapper as well as leaf helpers, because exact child values can still disappear at parent result
  composition.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2 — separate host offsets from public units):
  Dart strings require code-unit indices for safe `substring`, while LinkedSpec positions and lengths count
  characters. Store marks in the host's slicing unit, centralize span validation, and convert only at public
  position/length boundaries. Keep advancing operations transactional: mutate an anchor only after its span is
  valid. The governed source audit also caught a proof-system blind spot: a backend-derived call-name inventory can
  omit current reference contracts used by its own neutral fixtures. Final admission must compare inventories to
  the reference contract registry and fixture calls, not merely compare Dart and Julia to each other.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.1 — preserve symbolic slots and parent result ownership):
  A bare mark argument such as `mark_here(origin)` is a symbolic identifier, not a scalar read; evaluating it first
  aliases every undefined name to the same empty key and lets later marks overwrite earlier anchors. Resolve these
  slots from the raw typed argument while retaining evaluated quoted/dynamic forms. Also test governed fixtures
  through their real wrapper: exact leaf helpers can be correct while a blind-call parent silently discards the
  child value. Interpreted and generated execution must share the same implicit `AND` collection contract.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3 — share the sibling-chain semantic model):
  Julia confirmed the Dart lesson: typed marker nodes require a range owner. Select across siblings with nesting
  depth, evaluate the switch subject once, and execute one bounded branch. Keep attached and lazy inline switch
  paths separate; they already own structured bodies and must not be routed through marker scanning.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2 — typed nodes still need chain ownership):
  Parsing each marker control into the right AST type is insufficient when semantics span several sibling
  statements. Marker switch must claim the whole range, evaluate its subject once, track first-match state, and
  execute one bounded branch; otherwise typed case/default markers are skipped while their ordinary body
  statements all run. Use nesting depth while selecting ranges so an inner switch cannot terminate or select an
  outer chain.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1 — close aliases at discovery and execution):
  A statement-control alias needs two aligned seams: known-call validation prevents false unknown-helper
  diagnostics, and the statement-control matcher must canonicalize its behavior before generic helper dispatch.
  Rust's switch frame already had correct first-match/default exclusion, so the exact combined fixture required no
  speculative switch change. Verify each failed mechanism independently before editing adjacent green behavior.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3 — align semantics, not host value types):
  Julia and Dart both already modeled local-match absence with a nullable match object, but both leaked host
  booleans and null diagnostic locations through helper projection. Backend parity belongs at the helper contract:
  numeric presence and 1-based absent diagnostics coexist with nullable capture/position values and typed source
  booleans. Reuse the native nullable register instead of adding a parallel presence flag; always prove a present
  zero-width match so absence cannot later be inferred from offsets.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.2 — project absence at the helper boundary):
  Dart's nullable match object already preserves the semantic distinction that Rust needed explicit state to add.
  The defect was projection: diagnostic line/column helpers leaked null and named-presence helpers leaked host
  booleans. Keep absence in the runtime state model, then map each helper according to the language contract—null
  values, empty collections, numeric presence, or 1-based diagnostic defaults. Lock a real zero-width match at
  offset zero so future cleanup cannot replace the nullable state with offset inference.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.1 — absence is state, not a sentinel value):
  A `[0,0)` span is both a valid zero-width match and a tempting initialization sentinel. Inferring presence from
  offsets or empty capture collections necessarily collapses those states. Carry explicit presence through the
  same saved frame as groups/named captures/spans, and let each helper decide how absence projects: nullable
  capture/length/position values, empty containers, numeric presence, and stable 1-based diagnostic defaults.
  Always lock the opposite case—a real zero-width match at zero—when repairing an absence bug.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.3 — share splice classification, not fixture branches):
  Julia's `array(...)` evaluator already distinguished explicit splice expressions, while literal evaluation used
  a comprehension that necessarily nested every result. Route both through one append helper so AST identity—not
  returned host shape—controls splicing. Likewise, route only dropped-value calls with an explicit `array(name)`
  through the statement transform seam. This preserves typed source booleans and receiver/value purity while
  matching the reference's numeric predicate serialization and mutation boundary.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.2 — reuse typed splice and target seams across backends):
  Dart already had explicit array-splice recognition and named-array target extraction, but direct literal and
  statement dispatch did not route through them. Reuse those semantic seams instead of special-casing the fixture:
  literal evaluation splices only explicit `flat` calls, and statement dispatch mutates only an explicit
  `array(name)` target. Numeric predicate projection belongs at the helper boundary, leaving source booleans and
  other boolean-valued families unchanged.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1 — preserve value kind and call context separately):
  A typed source boolean and a predicate's historical Perl truth value are both truthy but serialize differently;
  keep literals as booleans and return numeric `1`/`0` from the exact predicate family. Likewise, an array helper
  can be pure in value/receiver context yet mutate an explicit `array(name)` when used as a standalone statement.
  Detect that statement shape before generic expression evaluation, and make direct literals honor explicit flat
  splice nodes instead of nesting their returned array.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.2.0 — vocabulary identity is not semantic parity):
  A current-call inventory proves discovery/contract-table breadth only. Pair it with exact-value execution or a
  backend can recognize a helper while returning the wrong value kind, treating a mutation as pure, selecting the
  wrong branch, synthesizing different empty state, or rejecting the runtime operation. Keep diagnostic fixtures
  governed outside the mandatory manifest until they pass everywhere; then admit them atomically so main stays
  green. Split by semantic mechanism and backend because superficially identical failures have different causes.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.1 — use canonical identity at ambiguous host boundaries):
  A lowered string beginning with `}` does not reveal whether it is a statement block closure or the end of an
  expression-shaped host wrapper. Preserve the canonical contract ID alongside pending source spans and lowered
  bytes, then make the narrow semantic exception before generic shape rules. This fixes `endswitch_flow` without
  broad semicolon insertion or changes to `if`/`while` continuations.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.2.0 — statement splitting and host termination are separate seams):
  Once a source newline produces independent canonical events, still inspect the emitted host boundary. Marker
  `switch` is expression-shaped Perl (`do { ... }`), unlike ordinary statement block closures, so a following
  statement needs an implicit terminator even though the lowered close begins with `}`. Carry the canonical
  contract into the decision instead of inferring all semantics from one leading character. Validate capture
  helpers only at action slots where the intended start and end cursors have actually been reached.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.1 — statement boundaries belong to lexical depth, not statement shape):
  When the language says every physical top-level newline separates statements, do not gate the split on whether
  the accumulated source already parses as one particular call form. Quote/nesting/comment modes determine whether
  a newline is top-level; the next lowering owner determines statement meaning. This removes cross-family blind
  spots while preserving multiline payloads and narrow same-line continuation rules. Treat manifest-guard failures
  from empty generated directories as artifact drift, remove them safely, and rerun the unchanged backend proof.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.1.0 — a green representative separator test is not universal proof):
  Derive capability inventories from independent backend contract tables, then audit documentation and executable
  corpus coverage separately. The existing `set(...)`/`return(...)` newline lock proved its path but not every
  lowering owner. Bounded capture, cursor, and marker fixtures exposed missing generated terminators and raw next
  targets at cross-owner boundaries. Keep the language contract authoritative, document the temporary reference
  limitation, split the common mechanism before repair, and do not admit incomplete fixtures into the frozen
  cross-backend corpus merely to improve a coverage count.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.6.0 — green subsets are not a complete capability proof):
  Keep CLI identity, interpreter corpus identity, and public capability identity as separate evidence layers. A
  machine-readable census must point each backend state to canonical docs/source/tests and require a task owner for
  both known behavior gaps and missing proof. Treat idiomatic host APIs as equivalent only when they preserve the
  documented role: separate parse/compile functions satisfy parse-only composition, but process-only named
  resolution, an internal compiled type without the outward descriptor, string-only runtime errors, or
  interpreter-only trace coverage do not satisfy the corresponding public contract.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.4.3 — one matrix must own cross-backend identity):
  Individual backend gates prove necessary native/package behavior, but exact interface parity needs one driver
  that substitutes only each command token into the unchanged fixture suite. Build/prepare toolchains and warm
  Dart/Julia before byte comparison so compiler/precompile chatter is not mistaken for application output. Keep
  the matrix opt-in from the core gate because external toolchains remain optional, while tracking and
  syntax-checking the driver and every focused backend script as governed CI inputs.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.4.2 — canonical trace wraps native phases, not native events):
  Keep the primary recorder entirely in the adapter and call native parse/compile/execute without its rich emitter.
  Count Julia UTF-8 text with `ncodeunits`, escape field `codeunits` bytewise, and model numeric thresholds from
  optional-minus ASCII digits using arbitrary precision rather than host `Int` limits. Emit phase outcomes around
  native calls; trace IO failure is a stable compilation failure. This preserves rich embedding trace while making
  all 61 process cases byte-identical.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.4.1 — validate bytes before trusting a host string):
  Julia `String(read(path))` preserves file bytes but can represent invalid UTF-8, so strict text boundaries must
  call `isvalid` before parsing or execution. This preserves valid BOM/newline/normalization data without guessing
  UTF-16/UTF-32. Keep portable process errors phase-only and retain causal detail in native structured exceptions;
  exact shared help plus this boundary split advances Julia from 13 to 42/61 with only trace projection left.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.4.0 — local process proof is not global byte identity):
  Julia's nine-family checker proves useful local behavior but permits a shorter help template, detailed backend
  stderr, and rich trace. Always run the unchanged shared manifest before declaring cross-variant identity. Julia
  `String` can contain invalid UTF-8, so `read(path, String)` needs explicit `isvalid` enforcement at a strict text
  boundary. Warm the Julia project before process-byte comparison to separate toolchain precompile chatter from
  application output, while keeping native rich diagnostics/trace available below the portable adapter.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.3.4 — backend completion needs a recurring exact gate):
  A manual 61/61 result is not the closeout boundary. The focused backend gate must own both option environments,
  native package tests, and its independent corpus runner so future Dart changes cannot silently regress either
  interface. Keep this gate optional in the toolchain-independent core CI, but make its opt-in path one command.
  Close the backend parent only after public/task/live/KM surfaces and the broader core gate agree.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.3.3 — portable trace remains an adapter protocol in Dart too):
  Do not route rich `LinkedSpecTraceEmitter` events through the byte-identical primary command. Project only the
  deterministic compile/input/invoke protocol, count UTF-8 bytes after encoding, escape fields bytewise, and keep
  file mode/reset/error handling in the adapter. Reset must run even for silent levels; route/mirror must append
  identically; trace IO failure is a compilation-boundary failure because the requested diagnostic channel failed.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.3.2 — serialize the native direct value, not a compatibility shape):
  Dart's runtime already exposes both `value` and legacy corpus `output == [value]`. The primary CLI must consume
  `value` directly; unwrapping `output` would make a legitimate one-element array ambiguous. Apply global mode in
  the engine constructor and entry rule per call, then recursively key-sort maps before compact UTF-8 JSON. This
  keeps source/input/runtime semantics native and leaves only deterministic trace projection in the adapter.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.3.1 — extraction no-match can be a valid empty result):
  A staged extractor is not necessarily a whole-document recognizer. For the function-definition shell, no `fn`
  match means an empty definition list, after which the ordinary `.spec` parser still validates the full source.
  Keep malformed source ownership in that parser. At the CLI boundary, decode raw UTF-8 before compilation and
  defer input bytes; explicitly guard preserved leading U+FEFF because Dart `String.trim()` otherwise erases it.
  Exact partial conformance is useful: 29/61 proves the entire process/loading phase while 11 result and 21 trace
  residuals stay mechanically assigned to the next leaves.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.3.0 — replace adapters without discarding developer tools):
  Dart's 0/61 primary-command result is interface drift, not evidence that its parser/runtime is absent. Preserve
  the corpus command under `bin/corpus_runner.dart`, replace only the public primary boundary, and compose the
  existing staged parser, validator/compiler, direct-value execution, top-rule/global-mode controls, and native
  trace infrastructure. Keep portable trace as a separate adapter projection. For strict UTF-8, load raw bytes
  explicitly so a leading U+FEFF remains data and malformed input is classified inside the correct command phase.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.2.4 — backend gates should be explicit and composable):
  Give each non-reference backend one repo-owned end-to-end gate, then make the canonical Perl/core gate opt into
  it via an explicit environment flag. This preserves reproducible full backend proof without making a Rust,
  Dart, or Julia toolchain an implicit prerequisite for routine core work. A primary-command gate must run the
  same unchanged manifest under both default and POSIX option environments, not a backend-local approximation.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.2.3 — portable CLI trace is an adapter protocol):
  Keep rich native trace scopes/events for embedding, but make each primary command project the same small,
  deterministic phase protocol. The adapter owns thresholds, UTF-8 byte accounting, one-line field escaping,
  emoji, and sink/reset semantics; it must not route backend-internal trace through the portable command. Trace
  setup/write failures are compilation-boundary failures because the requested diagnostic channel could not be
  established reliably.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.2.2 — direct result is an execution operation, not JSON postprocessing):
  Preserve legacy accumulator-returning APIs, but expose the backend-neutral top-rule value as a first-class native
  operation with per-invocation entry/mode options. This keeps engines reusable and avoids compiled-state mutation
  or unsafe one-element-array unwrapping. Exact nested JSON also tests helper semantics: hash constructors preserve
  ordinary nested hashes and splice only explicit `flat`/`flat_hash` values.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.2.1 — a shared process suite cleanly partitions backend work):
  An exact CLI boundary can land before result/trace completion without obscuring scope. Rust's 29/61 baseline
  proves argument grammar, help bytes, source/input phase order, strict UTF-8 failures, and operational headings.
  Every residual maps to an already-owned mechanism: 11 direct results expose `Engine::execute`'s documented
  accumulator wrapper and 21 need canonical trace. Fix direct top-value behavior through a reusable native API;
  never guess that an arbitrary one-element JSON array should be unwrapped in the CLI.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.2.0 — CLI controls must expose reusable native capability):
  A thin CLI may own portable option grammar, loading policy, stable diagnostics, and trace projection, but it
  must not gain exclusive semantic controls. Rust already owns parsing/compilation/execution in libraries, yet its
  engine selects only compiled `Top` and per-rule parse modes. Add reusable entry/global-mode execution controls
  before projecting them through the binary; keep canonical trace separate from rich native trace.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.6.3 — close reference status before backend consumption):
  A reference adapter is not ready merely when its code passes. The exact manifest count, help contract, task
  parents, public book, roadmap, and retrieval facts must all stop describing the repaired boundary as active.
  Preserve dated failure evidence for causality, but distinguish it from live status. Only then activate the next
  backend against an unchanged contract; otherwise the candidate can accidentally implement a moving reference.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.6.2 — Unicode text needs one explicit wire encoding):
  Unicode defines characters/code points; UTF-8, UTF-16, and UTF-32 are encodings. A portable CLI must choose one
  boundary encoding rather than treating raw bytes as characters or guessing from BOMs. Decode argv and file bytes
  once into host text, preserve normalization/BOM/newlines, then encode JSON/trace once back to UTF-8. Strict
  decoding must occur inside the owning compile/input phase so host decoder text never leaks into the shared API.
  Recursive Unicode JSON and exact byte-count fixtures are necessary because a top-level ASCII result can conceal
  mojibake in nested data or input state.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.11.0 — model trailing braces as syntax, not helper semantics):
  A parser-level special case for `with` conflates two layers. Codeblock is a language value kind; a callable
  signature decides whether it accepts that kind as its final argument, while trailing braces are only alternate
  syntax for the same argument. Canonicalize `call(args) { block }` and `call(args, { block })` before contract
  validation so helpers, user functions, receiver methods, and every backend share one AST/IR and diagnostic path.
  The current named `with` and traversal implementations remain factual compatibility surfaces until `.11.1`
  decides migration/removal; do not delete `with` from a planning clarification alone.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.6.1 — represent invalid text as explicit data):
  A byte-exact cross-backend fixture should not depend on an opaque repository binary. Add a validated hex source
  beside ordinary checked-in files, keep the two mutually exclusive, materialize through the same raw workspace
  writer, and reject case/length/character errors before launching a backend. This keeps malformed UTF-8 readable,
  reviewable, deterministic, and reusable by every implementation.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.6.0 — separate logical text from wire bytes):
  A byte-exact CLI still needs a declared text model. Treat source/input/options/results as Unicode scalar text and
  UTF-8 only at boundaries; otherwise Perl byte strings silently diverge from `String`/`str` backends. Prove the
  native engine with decoded non-ASCII before changing it, preserve normalization/BOM/newlines, project decoder
  failures by command phase, and extend neutral fixtures with explicit hex bytes instead of opaque binary blobs.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.10.0 — semantic introspection belongs below MCP):
  Deep introspection is strategically aligned with a parser/compiler/runtime system, but transport must not define
  meaning. Design a versioned semantic projection over deliberate concepts—rules, edges, calls, spans, provenance,
  inferred shapes, resolution and explanations—then expose it idiomatically from every in-memory backend. MCP,
  CLIs, IDEs, and agents should consume that same projection. Stable ids/order, bounded query cost, privacy/source
  controls, and exact cross-backend fixtures prevent internal AST/IR layouts from becoming accidental public APIs.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.5 — portable CLI trace is an adapter protocol, not an internal dump):
  A backend-native trace can be correct yet unsuitable for an identical CLI when it exposes timestamps, source
  locations, recursive compiler internals, megabytes per token, or host encoding warnings. Preserve that richness
  in native embedding, but project the CLI onto deterministic portable phases with raw UTF-8 sink semantics. Test
  routing by exact stdout/file bytes, persistence/reset, silent levels, mirror identity, and traced failures; run
  the one shared manifest from the canonical local gate rather than duplicating assertions. A signoff matrix must
  cover every declared level/alias, numeric thresholds, append/default routing, every error phase, non-ASCII byte
  counts, and control-byte field escaping; ASCII-only trace success can conceal both underlocked protocol behavior
  and a separate argv-to-JSON mojibake boundary, now owned by `.1.5.1.6` before Rust consumes the reference.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.4 — the CLI adapter owns stable failure projection):
  Keep rich backend diagnostics in the native runtime context and native in-memory trace channel; do not serialize host
  paths, `$!`, exception source lines, or owner-stage names into an identical cross-backend CLI. A below-`none`
  discard configuration preserves `LinkedSpec::Trace`'s embedding contract while making untraced stdout pure.
  Clear backend-specific trace environment inputs when no primary CLI trace option exists, and regression-lock
  that this neither creates nor resets an ambient trace file.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.3 — success fixtures must expose bytes, not merely accept options):
  Pair each selector/control with an observable invariant: run named resolution from an isolated cwd, return a
  deliberately unsorted nested hash for recursive canonicalization, and return `input_text()` from a newline-ended
  file to prove exact loading. Use toolbox probes and existing ADRs before inventing a grammar; ADR `0020` already
  explains direct-default-rule `E` drift, so portable action-edge returns are the correct neutral fixture surface.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.2 — public argument syntax must not inherit a host option library):
  Exact cross-backend syntax is clearest as one small explicit parser: case-sensitive option table, deterministic
  equals/separate value handling, ordered lexical errors, then selector/value validation. This removes ambient
  `POSIXLY_CORRECT`, auto-abbreviation, case-folding, negatable aliases, residual-positionals, and library warning
  text as observable inputs. Deduplicate large exact usage snapshots with manifest-owned channel variables, but
  prohibit overriding reserved runner placeholders so template reuse cannot become backend-specific normalization.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.1 — neutral fixture data must outlive every backend adapter):
  Keep the cross-backend contract in a strict manifest, not in one backend's test code. An arbitrary launch array
  plus explicit `COMMAND`/runner-input placeholders preserves the permitted executable-wrapper difference without
  normalizing arbitrary output. Canonical private workspaces and raw concurrent channel capture prevent cwd aliases,
  pipe deadlocks, newline loss, or Unicode/emoji decoding from weakening exactness. Include generated workspace
  files in schema version 1 now so routed trace proof later reuses the same runner rather than forking the contract.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.5.1.0 — CLI exactness starts by pinning option-parser policy and channels):
  A parser-oriented command is not a byte-testable reference merely because its happy path works. Ambient
  `Getopt::Long` defaults can create undocumented case/abbreviation/negation aliases and make behavior depend on
  `POSIXLY_CORRECT`; residual positionals need an explicit rejection, and library-generated option warnings need
  one owned formatter. Likewise, a library's visible level-zero diagnostic events cannot leak onto primary-CLI
  stdout during failure. Separate harness, argument, success, failure, and trace leaves so each observable channel
  becomes deterministic before other backends consume the fixture contract.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.3 — close a local milestone without erasing global obligations):
  A no-drift closeout must audit adjacent limitation prose, not only status tables: the Julia handoff simultaneously
  claimed and denied the exact primary CLI because a `.7.3.2.1` sentence survived later implementation leaves.
  Preserve scoped proof with a precise status label, mark the audit leaf done, and keep the backend root active/
  delegated to explicit global CLI, capability-census, and generated-source owners. This lets PNT advance without
  turning a locally complete adapter into a false full-parity claim.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.2.5 — exact CLI bytes require process proof, not captured functions):
  Unit tests over an injectable IO adapter are necessary but cannot prove launch-wrapper exit status, actual stdout/
  stderr separation, or a trailing newline. One standalone checker should own temp isolation and exact byte
  comparisons, then be called by the focused gate instead of duplicating partial smokes. A backend-local status can
  name that completed surface (`runtime-corpus-primary-cli`) only while docs state explicitly that global fixtures,
  capability census, and public generated-source parity remain separate completion gates.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.2.4 — CLI parity includes failure phase order and dormant controls):
  A correct option list is insufficient if input IO happens before compilation or a stored trace flag never affects
  output. Defer input-file reads until a parser exists, centralize fixed operational headings and ordered structured
  fields, and preserve fatal host errors. Trace configuration must cover the full state matrix: a file implies route,
  stdout can still reset but not append that file, mirror duplicates trace only, no-file route discards, and emoji
  belongs in the shared renderer so CLI and native traced entrypoints cannot drift.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.2.3 — serialize the public value, not the corpus adapter shape):
  A primary CLI should be a thin native-library composition. Julia can reuse rule-first parsing with precise
  spec-driven function fallback, compile once, construct the runtime with source identity and parser controls, and
  pass one trace emitter through every phase. The user-visible value is `RuntimeParseResult.value`; its `output`
  field is intentionally wrapped for corpus comparison and would add a false array layer. Canonical JSON requires
  recursive object sorting—host dictionary iteration and a plain JSON encoder are insufficient for nested maps.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.2.2 — CLI preparation is a typed boundary, not execution glue):
  Strict argument parsing and IO resolution are independently testable before parser execution. One preparation
  record preserves the original controls plus exact source/input text and identities, so the next leaf can compose
  the native pipeline without reparsing arguments. Named resolution must be deterministic: exact current path,
  current extension, repository `specs`, then sorted authored fallback; explicit names never silently fall through.
  Keeping corpus/status utilities outside the primary module prevents backend rollout tooling from becoming API.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.2.1 — propagate one trace emitter, do not build traced variants):
  Parser/compiler observability stays output-safe when normal APIs accept an optional caller-owned emitter and
  nested phases propagate it. A second traced parser/compiler would inevitably drift. Loading the existing trace
  owner before frontend definitions lets Julia type those keywords directly; balanced scopes plus medium phase
  decisions then compose through the already-tested sink routing. The same pattern carries from rule parsing into
  spec-driven function-shell runtime execution and staged body jobs without introducing a CLI-only mechanism.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.2.0 — CLI adapters reveal missing library-observable mechanisms):
  Argument parsing is the small part of the Julia CLI gap. Correct `--trace` meaning first requires compile/parser/
  staged instrumentation; correct `--spec` needs stable resolver ownership; canonical JSON needs deterministic key
  order; errors need a normalized stage boundary. Splitting by those mechanisms prevents an option-compatible but
  behavior-incompatible façade.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.1 — parity claims need a capability matrix, not a corpus count):
  The 99-fixture oracle is strong interpreter evidence, but it cannot prove an exported feature is present when no
  fixture invokes that public API. Rust's `pub mod source_emitter` is the concrete counterexample. ADR `0023`
  therefore keeps the corpus as the correctness oracle while requiring a separate public-capability matrix and
  exact CLI fixture suite before “complete parity” is accurate.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.3.0 — a backend-local CLI is not CLI parity):
  “Each variant has a CLI” only proves entrypoint ownership. It does not prove that users see the same product.
  Without a shared interface contract, scaffolds diverged by purpose: Perl parses arbitrary specs/inputs, Dart and
  Julia manage the regression corpus, and Rust has no command. Cross-variant CLI proof must compare commands,
  options/meanings, positional arguments, serialized output/errors, and exit semantics—not merely `--help` success.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.2 — generated source is an independent proof architecture):
  Code generation does not become trustworthy merely because an interpreter is green. The Rust precedent needed
  a compile/run harness, explicit generated-family plan, direct structural tests, and corpus evidence; omitting
  those would create a second execution surface with a weaker contract. Julia has no correctness or embedding gap
  that justifies that risk now. Deferral preserves the native 99/99 gate while routing a properly split future
  proof alongside Dart and Rust generated-source breadth.

- 2026-07-10 (JULIA-BACKEND-PARITY.7.1 — document product boundaries, not chronology):
  A backend handoff page should lead with what users can rely on now, not retain the lifecycle label from when the
  directory was first scaffolded. Julia's public story is native source → parse/stage → compile → runtime value,
  with CLI/corpus as adapters and 99/99 as the accepted interpreter proof. Mechanism status labels remain useful
  only when dated to their boundary. Generated-source and broader trace claims are independent axes, so naming
  them as non-claims is more accurate than letting “parity” imply them silently.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.4 — optional SDK verification boundary):
  Backend gates should be canonical without making every core checkout install every SDK. Julia now mirrors the
  Dart pattern: one focused repo-owned script is authoritative for backend changes, and the shared local gate opts
  in through an explicit environment flag. The executable and depot are inputs because Julia installations and
  writable precompile locations vary by host. The default temp-root depot keeps generated artifacts out of the
  repository and leaves cleanup safely scoped to one `compiled/` directory.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.3 — atomic full-corpus gate):
  Green disjoint windows are necessary diagnostics but not an aggregate parity proof: manifest insertion, ordering,
  or cross-window composition could drift while each historical subset still passes. The permanent 99-result test
  therefore locks the validation boundary, complete order, endpoints, empty failure ledger, and every exact output
  in one execution. CLI unbounded mode is enabled only after that atomic gate is green. Selection remains a
  debugging facility, while validation always covers the entire manifest before a subset runs.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.5 — spec-driven function-shell composition):
  The failure was an entrypoint composition gap, not missing grammar or runtime semantics. Rule-only
  `parse_spec(...)` correctly rejected the first `fn`, while direct execution of
  `specs/user_function_definition.spec` already consumed the source and returned the expected neutral nodes. A
  cached source-driven parser now joins that spec output to the existing projection, staged ActionIR body parser,
  function registry, compiler, and runtime. Keeping direct parsing first avoids burdening ordinary specs; falling
  back only on `SpecParseException` makes the broadened path precise. The three routed fixtures pass with no raw
  Julia scanner, and the separate `.6.3` gate remains responsible for the aggregate 99/99 claim.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.6 — complete shipped-window no-drift):
  Mechanism-specific regressions proved why individual failures closed, but they did not make the full 31-case
  claim atomic. The final regression reuses the same offset/limit boundary as the initial diagnosis and locks both
  manifest topology and output equality, so insertion/reordering or a cross-mechanism regression cannot silently
  preserve scattered green subsets. `runtime-corpus-shipped` names the completed product boundary rather than the
  last fix. The remaining three top-level function fixtures are deliberately outside this window and stay owned by
  `.6.2.5`; no 99/99 full-manifest claim is made yet.

- 2026-07-10 (FUTURE-PARITY-BACKLOG.1.4 — native in-memory backend contract):
  Backend plurality exists for native host-language embedding, not for duplicating command-line programs. The
  stable architecture is `.spec` source value → native parse/compile state → in-process execution → structured
  host value. File resolution is a convenience layer; CLI, corpus, Wasm, web, mobile, FFI, and service surfaces
  are adapters. This boundary stays independent of interpreter versus generated-source strategy. Current
  Perl/Rust/Dart/Julia surfaces already satisfy the structural embedding requirement, while their behavior claims
  remain governed by existing parity gates. Lua and later backends must begin from a native module/library plan.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.5.3 — public-parser leading trivia):
  The history mismatch was an entrypoint boundary, not an indexed-read defect. Perl's public wrapper skips only
  leading blank and `#` comment lines before the top handler; direct handlers bypass that wrapper, explaining why
  they see `\nobject:` and return `/proj/foo` while the public oracle returns `null`. Julia now initializes its
  existing cursor/register seam at the same public start offset. A focused `payload[1]` proof prevents accidental
  weakening of ordinary direct access. History passes, the shipped window is 31/31, and full tests pass at 810.

- 2026-07-10 (REPO-HYGIENE.4 — Julia-aware generated cache cleanup):
  Julia build artifacts require depot-aware cleanup. Safe precompile targets are the active depot's `compiled/`
  directory—here both `/private/tmp/linkedspec-julia-depot/compiled` and `~/.julia/compiled`—not the whole depot.
  Packages, registries, environments, logs, scratchspaces, and artifacts are separate state and were preserved.
  Combined with ignored `rust/target` and mdBook output, that first pass reclaimed about 2.1G. The apparent free-
  space rebound exposed the real pressure source: `/private/tmp` was 46G, including twelve stale LinkedSpec/RGX
  generation logs totaling about 18G. Header provenance plus process/`lsof` checks made those exact logs safe to
  delete; blanket temp deletion remained forbidden. The complete leaf reclaimed about 20G and moved the filesystem
  from 50G/90% to 68G/86%, while preserving the unrelated 29G `claude-501` and cargo-mutants temp trees.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.5.2 — statement regex mutation):
  The overload boundary is statement context plus a bare scalar target and four arguments. That discriminator
  keeps numeric `substr(value, start, width)` pure—even when its result is discarded—while enabling the historical
  regex-substitution spelling without a fixture shortcut. Julia reuses one strict regex flag compiler, expands
  `$n` per match, and keeps explicit split-target replacement separate. This composition closes EBNF quote text,
  lib_reader quote/list cleanup, and simenv's pre-exit block-name cleanup with one portable mechanism. The clearer
  single-quoted pattern is not a Julia convenience: Perl, Rust, Dart, and Julia already recognize both string
  delimiters, so equivalent single/double-quoted action strings are a required contract for every backend.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.5.1 — terminating exit control):
  `exit_now(...)` is fatal parser flow, not a value-returning helper. Julia evaluates its optional first argument,
  uses Rust-compatible numeric status `1` when absent or nonnumeric, and throws immediately through the established
  structured runtime-diagnostic path. The simenv result is intentionally still a failure: its earlier statement-
  form `substr(...)` has not mutated the block name, so the now-supported fatal mismatch branch executes. That
  causally separate mutation belongs to `.6.2.4.5.2`; this leaf locks control semantics without masking it.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.4 — action-edge child push):
  Parent action-edge regex matching already consumes the token and establishes a scoped child result. All-bare
  `push(child, target)` and literal `push(child, index)` therefore need child-call precedence and must reuse that
  result rather than evaluate the arguments as an ordinary append or re-search. Julia now covers all four
  implicit/explicit whole/indexed forms. EBNF's newly visible quote-only difference is independent statement
  mutation and is routed with lib_reader, not hidden inside structural dispatch.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.3 — recursive rule-local reset scope):
  Rule calls must not isolate every working variable: ordinary child mutations are intentionally caller-visible.
  The portable boundary is the first explicit aggregate reset in a rule invocation. Julia now snapshots all typed
  representations of that name, restores them on exit, and applies the seam to array/hash `set(...)` plus explicit
  split replacement. User functions skip tracking because their established path already swaps whole stores. This
  narrow model fixes nested and top-LX recursion without weakening shared working-state semantics.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.2.2 — diagnostic output helpers):
  Diagnostic helpers are side-effect statements, not parser values. Julia evaluates arguments normally, then
  routes human-facing output through its existing low-level trace sink and returns `nothing`; default untraced
  execution stays quiet and parse output stays structural. Corpus advancement is intentionally distinct from
  corpus closure: simenv now exposes `exit_now`, while history exposes the public-parser leading-trivia boundary.
  The permanent regression asserts those exact successor mechanisms and guards against unsupported `print`
  returning. Multiline examples use newlines alone; semicolons remain same-line statement separators only.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.2.3 — helper regex flag normalization):
  Regex literals carry both compile flags and operation flags. Julia's helper regex seam now deliberately filters
  them: `imsx` reach `Regex`, `g`/`o` remain accepted operation/compatibility no-ops at compile time, and unknown
  flags still fail closed. Centralizing this for predicate and split paths prevents per-helper drift and preserves
  the invalid-pattern false/empty contract.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.2.1 — eager logical helpers; Perl comparison corrected 2026-07-16):
  Julia and Rust evaluate every `and`/`or`/`not` argument before boolean composition. Julia does so through
  `_runtime_truthy`; lazy branches remain the responsibility of `if`/`switch`. The later `.5.2.0` audit corrected
  this note's former Perl comparison by recording the pre-`.5.2.2` split: conditions used lazy host operators and
  direct logical values remained raw/broken. Perl `.5.2.2` has since replaced both paths with typed eager logical
  values and a shared truthiness seam. The portmap constant residual exposed a separate compatibility seam:
  helper regex compilers must ignore Perl's compile-once `o` flag while retaining meaningful portable flags.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.1 — anonymous capture boundaries):
  Julia already carried the correct rule-local capture origin in `RuntimeMatchRegisters`; the gap was execution
  dispatch, not state architecture. One family dispatcher now derives all endpoints from that register and keeps
  text slicing code-unit safe while exposing character lengths/positions. The EBNF logging case proves why helper
  availability and downstream structural semantics must be claimed separately.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.4.0 — Julia shipped-smoke split at 10/31):
  The Julia window reaches substantially farther than Dart's initial shipped-smoke boundary, so Dart's historical
  leaf order is reference evidence rather than a template to copy blindly. Julia already passes Tclite, Lispish,
  raw hlink, portmap slice, regdef, VHDL, and empty plugin/library smokes. Explicit unsupported-helper failures can
  be removed before investigating the already-executing recursion, structural-output, and quote-normalization gaps.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.3 — Julia middle corpus 25/25):
  The non-function middle window also required no implementation correction. Three disjoint bounded runs keep the
  known top-level function offsets out of the claim while proving every surrounding helper/control/receiver/tree
  fixture. The permanent regression locks both the passing windows and the exact routed names, so later manifest
  edits cannot accidentally make the 25/25 claim absorb or lose a function-shell case.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.2 — Julia starter corpus 40/40):
  The first shipped window needed no implementation correction: Julia's already-landed value/store/mutation,
  blocks, and attached-control semantics match all expected JSON from `proof_edge_array_literal` through
  `terse_2_2_5_2_attached_switch_blocks`. The durable change is therefore a bounded regression test, not speculative
  runtime work. Its endpoint assertions make manifest reordering visible, while the failure ledger preserves names
  and details if later changes regress any case.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.1 — Julia bounded corpus selection/reporting):
  Selection happens after complete manifest validation, so a bounded execution cannot hide manifest drift. Named
  selection preserves caller order and rejects duplicates/missing cases; offset/limit windows use zero-based
  manifest positions and cap oversized limits at the end. The CLI deliberately requires `--case` or `--limit`
  while parity is incomplete—offset alone is not a safe upper bound—while library callers may still execute a
  complete controlled corpus. Per-fixture failures stay ordinary results, yielding runner exit `1`; malformed
  selection is a usage/manifest error and yields `2`. This distinction keeps later diagnostic batches scriptable.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.2.0 — Julia corpus rollout split):
  The shipped manifest is divided by recoverable mechanism boundaries rather than treated as one 99-case fix
  batch. Bounded selection/reporting lands first so every later window is reproducible. The first 40 fixtures own
  proof-edge/autoexist/core terse behavior; 40–67 own non-function helper/control/receiver/tree breadth; 68–98 own
  shipped-spec/parser-smoke behavior; and top-level function fixtures have a separate spec-defined shell owner.
  The ranges mirror the proven Dart rollout only as workload boundaries—Julia must diagnose its own results, retain
  shared oracle evidence, and never inherit Dart-specific fixes without a Julia failure mechanism.

- 2026-07-10 (JULIA-BACKEND-PARITY.6.1 — Julia controlled corpus execution):
  Corpus execution is a composition layer, not another parser/runtime path. The harness first reuses strict
  manifest validation, then records one immutable-style result per manifest fixture while continuing after
  failures. Success compares `RuntimeParseResult.output` to the expected JSON wrapped exactly once; failures retain
  any partial parse result, captured trace lines, and the deepest structured runtime diagnostic. `spec_name` and
  `spec_path` come from the fixture for actionable attribution. The optional `spec_parser` seam proves already-
  projected staged function shells without inventing a Julia raw function scanner; the default remains the honest
  rule-only `parse_spec(...)` path until shipped-corpus expansion owns source-driven shell execution. Multiline
  fixture statements are newline-separated and never carry trailing semicolons.

- 2026-07-10 (JULIA-BACKEND-PARITY.5.3 — Julia staged function descriptor shapes):
  The existing Julia projection was already neutral; the missing piece was a single proof spanning every layer.
  The focused fixture therefore starts at spec-returned definition nodes rather than handcrafted
  `FunctionDefinition` values, dispatches the staged jobs, compiles the stitched spec, inspects the public
  descriptor, and executes that exact compiled state. This catches loss or renaming of payload provenance, job
  normalization/policies, AST stitching, or function metadata without introducing a second descriptor code path.
  Status remains `runtime-user-functions` because this is a no-drift proof, not a new runtime capability.

- 2026-07-10 (JULIA-BACKEND-PARITY.5.2 — Julia user-function runtime execution):
  Registered calls resolve before helper fallback and evaluate arguments before replacing any store, preserving
  caller-side assignment effects while preventing caller-variable capture inside the function. Function params
  bind into a fresh scalar store and, for aggregate values, matching fresh typed array/hash stores. Body parsing is
  cached per runtime execution context; value-block flow supplies final-expression/local-return semantics. A
  `finally` boundary restores caller stores and active-call state across success or failure. Standalone calls reuse
  the existing dropped-value statement path, and active-name cycles produce structured recursion diagnostics.
  Multiline `.spec` fixtures use newlines alone; no line-ending semicolons were introduced.

- 2026-07-10 (JULIA-BACKEND-PARITY.5.1 — Julia staged function-body registry):
  Julia keeps the staged boundary neutral by parsing function text through its typed ActionIR parser and stitching
  JSON, not Julia objects, into `body_ast`. Stable ordering is structural (parent path, span, job id), and provider
  identity/cache fields match the accepted cross-backend contract exactly. Function/job contract validation occurs
  before dispatch, the original spec remains immutable, and general provider search/recursive queues are not
  inferred from this deliberately narrow built-in adapter. `.5.2` can now execute bodies from one proven shape.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.5.4 — Julia diagnostics/trace no-drift):
  The accurate closeout status is `runtime-trace-events`: Julia has structured runtime diagnostics, complete
  control/sink/event primitives, and instrumented runtime ownership boundaries, while compile/parser tracing and
  later staged/corpus execution are not silently claimed. No source correction was needed. Closing `.4.5` on this
  scoped boundary keeps product status honest and makes `.5.1` staged registry execution the next mechanism.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.5.3 — Julia runtime trace instrumentation):
  Instrumentation follows existing mechanism owners rather than branching into a trace-specific interpreter.
  Rule and lifecycle events use `high` for readable execution structure; match/dispatch/recursion/cursor/boundary
  detail uses `debug`. Small no-op helpers centralize emitter absence, scope cleanup occurs in the rule `finally`
  path, and tests compare complete traced/untraced results across action, blind, and recursive execution. This
  keeps tracing observational while `.4.5.4` closes the public parity/no-drift claim.

- 2026-07-10 (STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1 — separator-only fixture style):
  The `.spec` semicolon is an infix separator, never a line terminator. Multiline fixtures should use the newline
  alone; compact same-line fixtures use `;` only between adjacent statements, including no semicolon after the
  last statement. The corrected Dart hash-helper fixture is executable proof that removing redundant line-ending
  semicolons preserves behavior.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.5.2 — Julia trace controls/events/sinks):
  The trace owner is independent from the interpreter: immutable config selects levels and routing, while a
  mutable emitter owns event/line history, indentation, and output. File sinks append per event, with eager reset
  and parent-directory creation at emitter construction, avoiding long-lived file handles. Ordinary runtime
  entrypoints accept an optional emitter; convenience wrappers construct one from config. This leaf intentionally
  emits only the parse scope, keeping control/sink/output-preservation proof separate from `.4.5.3` mechanism
  instrumentation.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.5.1 — Julia structured runtime diagnostics):
  Julia attaches structured data to the existing exception channel rather than changing success results or
  textual display. Direct lookup failures create specific diagnostics; rule boundaries add current-rule
  attribution before their register/context cleanup; parent and parse wrappers only add a fallback when no richer
  child payload exists. This ordering preserves the deepest useful rule/handler identity. Optional spec identity
  lives on the engine and is copied into failures, while ordinary in-memory callers omit those fields naturally.
  `.4.5.2` can now add optional tracing without becoming a prerequisite for usable failure data.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.5.0 — split Julia diagnostics/trace controls):
  Structured diagnostics and optional tracing share runtime attribution but not an implementation owner.
  Diagnostics must remain available on failures without any trace setup; trace levels/events/sinks form a reusable
  control layer; interpreter instrumentation consumes that layer; and parity/no-drift is only meaningful after all
  mechanisms land. Julia therefore mirrors the proven Dart four-leaf split while keeping Julia-native exception,
  configuration, and I/O types. `.4.5.1` owns diagnostic payloads before any trace plumbing.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.4 — Julia runtime cursor controls and boundary capture):
  Julia keeps its efficient internal cursor as a zero-based UTF-8 code-unit offset, but every public cursor/input
  position, length, and slice is character-based. One `_set_runtime_cursor!` path updates the mutable execution
  cursor and immutable match-register cursor together while deliberately preserving entry/local match objects and
  all semantic stores. The explicit save stack is independent from direct match/entry anchor rewinds.
  `capture_until_boundary(...)` always seeks structural boundaries regardless of the surrounding parse mode,
  then leaves the winning boundary unconsumed; normal matching after any cursor move still uses the engine's
  configured seek/consume mode. `.4.5` can layer diagnostics and trace events over this centralized cursor path.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.6 — Julia helper/value no-drift):
  The final `.4.3` audit found no runtime semantic correction: Julia `.4.3.1` already implemented the
  no-autovivification updated-root/failed-`nothing` assignment contract that Dart needed to repair during its own
  closeout, and `.4.3.2` through `.4.3.5` align with the scoped helper catalog. Package status deliberately stays
  `runtime-value-control-tree` so later cursor, trace, staged-function, and corpus work is not overclaimed. The
  only drift was durable presentation state: stale `.3`/`.4.3` parent statuses and redundant end-of-line
  semicolons in central helper-catalog `.spec` examples. `.4.4` now owns cursor controls and boundary capture.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.5 — Julia runtime value/control/tree helpers):
  Julia now keeps value-block flow distinct from the rule return exception channel, so local returns can short
  circuit immediate blocks without escaping the enclosing action. Structured statement controls share indexed
  block execution for attached and marker chains; inline value controls stay lazy. Immediate callbacks snapshot
  all three same-name store categories before binding `value`, `key`/`index`, `path`, `depth`, or `acc`, then
  restore them in reverse order while preserving unrelated caller mutations. Tree reduction evaluates its initial
  expression only after confirming a hash or array receiver, matching the non-aggregate lazy-failure contract.
  `.4.3.6` can now audit helper/value no-drift over one complete execution boundary.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.4 — Julia runtime hash helpers):
  Hash calls now route through a copied-value dispatcher shared by function and receiver forms. Statement-form
  `set_key` is the only new named-storage mutation path; value and receiver forms return changed copies. The
  `merge_hash` base remains an ordinary expression slot, while later overlays use maybe-hash lookup, preserving
  the established bare-aggregate boundary. `hash(...)` recognizes splicing from explicit `flat` / `flat_hash`
  syntax rather than guessing from map-shaped values, so ordinary nested maps remain nested. The focused fixture
  deliberately uses newline separators without redundant semicolons, matching the durable DSL separator contract.
  `.4.3.5` can add blocks, controls, and callbacks over this stable copied/mutating boundary.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.3 — Julia runtime array helpers):
  Array calls now operate on copied snapshots through a dedicated dispatcher, with `join_values` explicitly
  rewriting receiver form to the delimiter-first canonical function contract. `array(...)` splices only values
  marked structurally by `flat(...)` / `flat_array(...)`; `copy(array(...))` remains nested, so value shape does
  not depend on runtime guessing. Destructive end methods are intercepted only for a single fluent call in
  statement context and can update either named typed storage or scalar-held arrays. Generic value evaluation
  returns `nothing` before evaluating mutation arguments, guaranteeing no hidden mutation or side effect.
  `.4.3.4` can add hash behavior without weakening that statement/value boundary.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.2 — Julia runtime string/scalar/numeric helpers):
  Julia now canonicalizes helper function names and fluent methods through the same pure-helper dispatcher, so
  word aliases, symbol callees, and receiver chains cannot acquire separate arithmetic/string semantics. Regex
  ActionIR values retain pattern flags only as an internal runtime carrier; string helpers compile them through
  native PCRE and JSON output never depends on a host regex object. Numeric conversion admits finite numbers and
  numeric-looking strings, rejects booleans/aggregates, normalizes integral results to `Int`, and returns `nothing`
  at invalid arithmetic or conversion boundaries. Lazy `coalesce` evaluation remains outside eager pure-argument
  evaluation so skipped branches keep the portable side-effect contract. Array-aware receiver and mutation
  behavior remains isolated in `.4.3.3`.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.1 — Julia runtime core values/stores/captures):
  `julia/src/runtime/Interpreter.jl` now has one portable core value model shared by later helper families: scalar,
  array, and hash stores; copied bare/typed snapshots; structural literal/assignment/access execution; and capture
  map/position reads. Nested value-path assignment implements the final cross-backend contract immediately:
  segment expressions precede the RHS, roots mutate only after full validation, missing/wrong intermediates do not
  autovivify, successful writes return the updated root, and failed writes return `nothing` without mutation.
  This avoids reproducing the transient Dart nested-write drift already corrected by its no-drift leaf. `.4.3.2`
  can build pure string/numeric helpers and receiver chains over this stable copied-value boundary.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.3.0 — split Julia runtime helper families):
  The Julia helper/value rollout now mirrors the proven Dart mechanism order instead of treating the complete
  helper catalog as one implementation unit. Core JSON-shaped stores/captures land first, then string/numeric
  helpers, array-aware behavior, hash-aware behavior, value/control/block/callback execution, and final no-drift.
  This planning slice changes no runtime code and makes `.4.3.1` the single active code boundary.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.2 — Julia runtime rule interpreter):
  Julia now consumes `CompiledSpec` through its first executable rule-dispatch layer.
  `julia/src/runtime/Interpreter.jl` owns default/AND/OR/repetition mode execution, action and blind-call child
  dispatch, entry/local register handoff, `retv`, lifecycle order/events, explicit return flow, narrow array/rule
  accumulators and capture reads, output projection, bounds, zero-progress termination, and recursion cutoff state.
  The embedded evaluator deliberately rejects general variable/store/helper/control/block/callback behavior so the
  broad `.4.3` helper/value container has since been split by `.4.3.0`; `.4.3.1` owns the first core
  value/store/capture batch.

- 2026-07-10 (JULIA-BACKEND-PARITY.4.1 — Julia runtime matching state):
  Julia now has the regex/match-state foundation required by executable rule dispatch.
  `julia/src/runtime/Matching.jl` compiles stable zero-based regex alternatives, implements earliest seek and
  cursor-anchored consume modes, records full/compact/named captures, projects Julia code-unit spans to public
  character and line/column positions, and keeps cursor/capture anchors plus entry/local matches in immutable
  `RuntimeMatchRegisters`. Direct native-PCRE probes established that Python/angle named captures, POSIX classes,
  inline/scoped flags, possessive quantifiers, and recursive `(?R)` need no Julia dialect bridge. `.4.2` has since
  added first executable rule dispatch; `.4.1` itself does not interpret ActionIR or compiled rule modes.

- 2026-07-10 (JULIA-BACKEND-PARITY.3.4 — Julia compiled-spec state):
  Julia now has a compiled-state model before runtime matching. `julia/src/compiler/CompiledSpec.jl` exposes
  `compile_spec(...)`, `CompiledSpec`, `CompiledRule`, `CompiledDependencyRegexState`, `CompiledDescriptorState`,
  `compiled_rule(...)`, `action_payloads(...)`, and `to_descriptor_json(...)`. The compiler reuses
  `validate_spec(...)` by default, carries ordered rule state and function registry projection, derives
  dependency-regex rows, parses lifecycle/action payloads into `ActionBlock` ASTs, resolves those payload contracts
  with the function registry, and projects descriptor-shaped JSON with `julia_interpreter_rule` handlers marked
  `compiled_state_only`. Runtime regex matching and match registers have since landed in `.4.1`.

- 2026-07-10 (JULIA-BACKEND-PARITY.3.3 — Julia user-function registry):
  Julia now has the data-layer user-function registry seam before compiled-state/runtime work.
  `julia/src/action/FunctionRegistry.jl` builds ordered `UserFunctionRegistry` entries from `SpecFile.functions`
  or direct `FunctionDefinition` records, exposes staged `body_parse_job` values, preserves `body_payload` and
  optional `body_ast`, rejects duplicate names, and provides `stitch_function_body_ast(...)` for immutable staged
  body-AST replacement. `resolve_action_*_contracts(...; function_registry=registry)` now classifies exact-arity
  registered calls as `user_function` before helper fallback, while wrong-arity registered calls report
  `user_function_arity_mismatch`. Function bodies are still not executed; `.3.4` owns compiled-state construction.

- 2026-07-10 (JULIA-BACKEND-PARITY.3.2 — Julia ActionIR contract resolver):
  Julia now resolves typed ActionIR nodes against the current canonical helper/control contract table before
  compiled-state or runtime work. `julia/src/action/ActionContracts.jl` exposes
  `resolve_action_block_contracts(...)`, `resolve_action_statement_contracts(...)`,
  `resolve_action_expression_contracts(...)`, `canonical_action_helper_name(...)`, and
  `is_known_action_ir_call_name(...)`. The resolver walks calls, receiver methods, structural assignments,
  structured controls, nested arguments, block values, shape literals, and access expressions, recording
  JSON-shaped contract/diagnostic records. Unknown helper-looking calls produce generic `unknown_helper`
  diagnostics, and `raw_perl` fallback nodes remain explicit diagnostics. The validator now shares the resolver's
  current helper-name predicate for user-function collisions. Function-registry-aware exact-arity user-call
  classification is still owned by `.3.3`.

- 2026-07-10 (JULIA-BACKEND-PARITY.3.1 — Julia ActionIR AST parser):
  Julia now parses helper/action source into typed ActionIR nodes before helper-contract resolution or runtime
  execution. `julia/src/action/ActionAst.jl` defines the neutral JSON-shaped node model for action blocks,
  value-drop statements, calls, arguments, literals, variables, direct/nested access, shape literals, assignments,
  receiver chains, trailing block arguments, block values, structured controls, and raw fallback expressions.
  `julia/src/action/ActionParser.jl` exposes `parse_action_block(...)`, `parse_action_statement(...)`, and
  `parse_action_expression(...)`. The parser intentionally mirrors the Dart `.3.1` boundary: it is structural only,
  keeps unsupported expressions as `raw_perl`, and leaves canonical helper contracts, user-function registry
  resolution, compilation, and execution to later leaves.

- 2026-07-10 (JULIA-BACKEND-PARITY.2.4 — Julia function-definition shell projection):
  Julia now consumes the spec-defined top-level user-function shell node shape without adding a Julia raw scanner.
  `julia/src/spec/UserFunctionDefinitionShell.jl` projects `function_definition` nodes returned by
  `specs/user_function_definition.spec` into `FunctionDefinition` records, validates source/body spans and staged
  sidecars, normalizes `functions.<index>.body_source` paths and body-parse job IDs, strips function-definition
  spans before rule parsing, and rejects `function_definition_error` nodes as `SpecParseException`s. `parse_spec(...)`
  remains rule-only; callers that have spec-returned function nodes use
  `parse_spec_with_user_function_definition_asts(...)`. Next leaf is `.3.1` for typed helper/action AST parsing.

- 2026-07-10 (JULIA-BACKEND-PARITY.2.3 — Julia frontend validation):
  Julia now validates parsed source ASTs before helper/action lowering or runtime behavior. `validate_spec(...)`
  lives in `julia/src/spec/Validator.jl` and checks top-rule presence, duplicate rules/functions, user-function
  registry collisions and reserved params, raw body fallback lines, mixed action/blind edge families, grouped
  action-edge block requirements, undefined references, regex-slot bounds, regex structure, and strict unused
  rules. The testset mirrors the Dart frontend validator cases and validates all checked-in specs plus rule-only
  corpus specs. Top-level `fn` shell projection has since landed in `.2.4`.

- 2026-07-10 (JULIA-BACKEND-PARITY.2.2 — Julia source parser):
  Julia now parses core `.spec` rule paragraphs into the `.2.1` source AST types. `parse_spec(source)` lives in
  `julia/src/spec/Parser.jl` and covers headers/modes, regex slots, lifecycle blocks, action/blind-call edges,
  fluent continuations, markers, comments, and block boundaries. The focused parser tests also parse all 21
  checked-in `specs/*.spec` files plus rule-only corpus specs, while top-level `fn` shells stay deferred to `.2.4`.
  Frontend validation has since landed in `.2.3`.

- 2026-07-10 (JULIA-BACKEND-PARITY.2.1 — Julia source AST data types):
  Julia now has the data-only source AST contract before parser behavior. `julia/src/spec/Ast.jl` defines
  `SpecFile`, `FunctionDefinition`, source spans, staged parse jobs, rule headers/modes, body element variants,
  edge targets, and fluent calls, with JSON field names matching the Rust/Dart/mdBook contract. `Pkg.test()` now
  includes a JSON round-trip fixture over functions, parse jobs, bounded rule modes, regex/action/code elements,
  edge targets, and spec files. Next leaf is `.2.2` for parsing `.spec` rule paragraphs into these types.

- 2026-07-10 (JULIA-BACKEND-PARITY.1.3 — Julia corpus manifest IO):
  Julia now has manifest-backed corpus IO before parser/runtime semantics. `load_corpus_fixtures(path)` validates
  manifest format/count/names, duplicate names, missing/stale fixture directories, required fixture files, and
  expected JSON syntax over the checked-in 99-fixture corpus. The package now has a committed `JSON3` dependency for
  manifest/expected JSON parsing. `julia/bin/linkedspec_julia.jl corpus` and `julia/bin/corpus_runner.jl --corpus`
  report the validated fixture count; `--execute` remains rejected. Next leaf is `.2.1` for source AST/data types.

- 2026-07-10 (JULIA-BACKEND-PARITY.1.2 — Julia package scaffold):
  The `julia/` backend scaffold now exists as package `LinkedSpecJulia` with `Project.toml`, committed
  `Manifest.toml`, module status helpers, CLI/corpus modules, `bin/linkedspec_julia.jl`, `bin/corpus_runner.jl`,
  README commands, and a Julia `Test` smoke suite. It is intentionally command/package surface only: no `.spec`
  parser, manifest IO, runtime interpreter, or corpus execution semantics exist yet. `Pkg.instantiate()`,
  `Pkg.test()`, CLI help/status, and corpus-runner scaffold commands pass with `JULIA_DEPOT_PATH` set to the
  writable depot. Next leaf is `.1.3` for manifest-backed corpus IO and drift detection.

- 2026-07-10 (JULIA-BACKEND-PARITY.1.1 — Julia toolchain/package preflight):
  The local Julia toolchain is usable for the Julia backend lane: `/opt/homebrew/bin/julia` is Homebrew-managed,
  reports Julia 1.12.6, and matches the official current stable release. `Pkg` and `Test` import successfully when
  Julia runs with a writable depot such as `/private/tmp/linkedspec-julia-depot`; plain imports can fail under the
  managed harness if they try to precompile into `~/.julia`. The intended `julia/` layout is now recorded with
  `Project.toml`, `src/LinkedSpecJulia.jl`, package subtrees for CLI/corpus/spec/action/compiler/runtime, distinct
  `bin/linkedspec_julia.jl` and `bin/corpus_runner.jl` entrypoints, and `test/runtests.jl`. `JuliaFormatter` and
  `JET` are not installed globally, so formatter/linter commands are optional until a scaffold or verification leaf
  commits them as dev dependencies. `.1.2` has since created the minimal package scaffold; current next work is
  `.1.3` corpus manifest IO, with no parser semantics yet.

- 2026-07-09 (FUTURE-PARITY-BACKLOG.1.2 — Julia backend plan):
  Julia parity is now a dedicated task tree at `docs/tasks/JULIA-BACKEND-PARITY.md`. The plan deliberately follows
  the Dart lessons: verify toolchain/package layout first, start interpreter-first over typed `.spec` and
  helper/action AST, require a Julia-specific LinkedSpec CLI from the package-planning leaf, and defer generated
  Julia source to a later proof decision. The next PNT leaf is `JULIA-BACKEND-PARITY.1.1`; it should record real
  local Julia toolchain availability and intended `julia/` layout before any source scaffold is created.

- 2026-07-09 (DART-BACKEND-PARITY.7.5 — Dart scoped milestone closeout):
  The Dart backend parity task tree is closed at the interpreter-first milestone. The durable claim is intentionally
  scoped: Dart executes the current 99-fixture manifest through parser/compiler/runtime, has focused local
  verification, exposes a variant-specific CLI, and has mdBook/live-doc/Knowledge Map alignment. Generated Dart
  source is still future proof work, not part of this conformance claim. That handoff has since completed:
  `FUTURE-PARITY-BACKLOG.1.2` split/scaffolded Julia planning without implementation code, and active executable
  Julia work now starts at `JULIA-BACKEND-PARITY.1.1`.

- 2026-07-09 (DART-BACKEND-PARITY.7.4 — Dart-specific CLI productization):
  `dart/bin/linkedspec_dart.dart` is now the Dart-specific LinkedSpec CLI rather than a scaffold status printer.
  It supports `--help` plus `corpus --corpus <path> [--execute] [--case ...] [--offset ...] [--limit ...]`,
  routing execution through the same manifest-backed parser/compiler/runtime harness used by
  `executeCorpusFixtures(...)`. `dart/bin/corpus_runner.dart` remains available as a corpus-focused compatibility
  wrapper, but both entrypoints share `lib/src/cli/linkedspec_dart_cli.dart` so their argument parsing and reporting
  do not drift. CLI smoke tests now cover help text and selected fixture execution through the Dart-specific
  command; the focused Dart local gate now also runs a bounded Dart-specific CLI corpus smoke and remains green over
  140 tests plus the 99-fixture corpus.

- 2026-07-09 (DART-BACKEND-PARITY.7.2 — Dart generated-source deferral):
  Generated Dart source is deferred instead of being implemented as a one-slice add-on. The Rust source-emitter
  proof took a split lane with an emitter scaffold, generated family-plan metadata, direct execution by structural
  family, and a curated manifest-backed corpus subset; Dart should follow that shape in a future dedicated
  source-emitter lane if needed. The current Dart conformance claim remains the interpreter-first 99/99 corpus
  gate. PNT advances to `.7.4` for Dart-specific CLI productization.

- 2026-07-09 (DART-BACKEND-PARITY.7.1 — Dart mdBook usage/status closeout):
  The Dart backend docs now have a single reader-facing command path in the mdBook: `bash tools/run_dart_local.sh`
  for the focused Dart gate, `LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh` for opt-in local-CI inclusion, and
  direct `dart test` / full corpus-runner commands under `dart/`. The docs state the current parity boundary as
  interpreter-first, 99/99 corpus-green, with generated Dart source and Dart-specific CLI productization remaining
  follow-up lanes rather than prerequisites for the current conformance claim.

- 2026-07-09 (DART-BACKEND-PARITY.6.4 — Dart local verification gate):
  Dart parity now has a focused repo-owned local gate at `tools/run_dart_local.sh`. The script runs Dart format,
  analyzer, full tests, CLI help checks, and the 99-fixture corpus execution. `tools/run_ci_local.sh` deliberately
  remains core-only by default so the canonical Perl gate does not fail in checkouts without a Dart SDK; setting
  `LINKEDSPEC_RUN_DART=1` includes the Dart gate. This closes the `.6` verification-story leaf without making Dart
  SDK availability a hidden precondition for the existing local CI contract.

- 2026-07-09 (DART-BACKEND-PARITY.6.3 — full Dart corpus gate):
  The Dart corpus runner is now promoted from bounded execution batches to the full checked-in manifest gate.
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute` runs all 99 fixtures
  in manifest order and passes 99/99. Named and bounded selection remain available for diagnostics, but the CLI no
  longer requires a selector for `--execute`. `corpus_manifest_test.dart` now locks the full checked-in corpus gate,
  CLI full-run behavior, unsupported manifest format rejection, invalid and duplicate manifest case-name rejection,
  existing count/drift/missing-file guards, and mismatch reporting. The next Dart parity leaf is verification-story
  wiring rather than more corpus runtime implementation unless a future manifest update adds new fixtures.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.5 — Dart top-level fn corpus shell routing):
  Dart now has an executable bridge for `specs/user_function_definition.spec`.
  `parseUserFunctionDefinitionAsts(...)` compiles that checked-in spec through the Dart runtime and returns the
  shell-owned AST nodes; `parseSpecWithStagedUserFunctionDefinitions(...)` feeds them through the existing staged
  projection so function bodies receive `body_ast`. `executeCorpusFixtures(...)` deliberately keeps direct
  `parseSpec(...)` for rule-only fixtures and invokes the shell only when rule-only parsing rejects top-level
  function source. That preserves the no-raw-scanner boundary for `fn` semantics without forcing the shell to be a
  universal pre-parser for every existing rule-only spec. The shell execution also closed two runtime helper gaps:
  statement-form `next()` now continues the enclosing rule loop, while expression-form `next()` still yields null;
  `entry_end_line` / `entry_end_col` and `match_start_*` / `match_end_*` line/column aliases now share the existing
  match-register offsets. The three routed terse user-function corpus fixtures pass.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.6 — Dart structural PCRE smoke parity):
  This is a deliberately bounded bridge, not a general PCRE engine. `compileRuntimeRegex(...)` recognizes only the
  exact shipped structural pattern families that blocked the parser-smoke window: Lispish recursive square
  brackets, EBNF return scalar/array/object forms using `\K`, `(?&name)`, and `(?(DEFINE)...)`, and spec.spec
  recursive action/blind/lifecycle/function block forms. Those patterns run through small structural scanners that
  preserve the match/capture/named-group surfaces the Dart runtime already consumes. The same slice also adds
  action-edge `push(child, index)` payload extraction; `push(quoted_string, 1)` now appends the child return's
  second element to the current rule accumulator, preserving `ebnf_logging_annotation` args. The shipped-spec/
  parser-smoke window is now 31/31 green. Next frontier is `.6.2.5` for routed top-level `fn` corpus fixtures.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.5 — parser-smoke no-drift closeout):
  This is a docs/verification closeout, not a Dart runtime change. After the public-parser leading-trivia bridge,
  the shipped-spec/parser-smoke diagnostic window is 24/31 green. The seven remaining failures are all PCRE
  structural regex constructs already routed to `.6.2.4.6`: Lispish recursive `(?R)`, EBNF `\K` /
  `(?&name)` / `(?(DEFINE)...)`, and spec.spec recursive block regexes. Treat the non-PCRE residual group as
  closed; do not reopen hlink, portmap, helper mutation/text normalization, regdef, or ds_vhistory unless a fresh
  regression changes the measured boundary.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.6 — Dart public-parser leading trivia):
  The `ds_vhistory` boundary came from Perl's public parser wrapper, not from indexed access. `Runtime.pm` resets
  `pos()` and skips leading blank/comment lines before invoking the generated top handler; direct descriptor
  handlers bypass that wrapper. Dart now mirrors the public wrapper in `LinkedSpecRuntimeEngine.parse(...)`, so the
  leading `\nobject:` line in `ds_vhistory_version_entry` is skipped before the top dispatch loop begins, matching
  the checked null object-name oracle. Focused tests also lock that ordinary scalar-held `payload[1]` still returns
  the indexed item. The shipped-smoke window is 24/31 green; only the routed PCRE structural regex blockers remain.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.5 — ds_vhistory oracle boundary split):
  The remaining `ds_vhistory_version_entry` mismatch is narrower and stranger than the earlier direct-access
  shorthand suggested. Public `LinkedSpec::get_parser("ds_vhistory")` returns a null object name for the checked
  leading-newline fixture, and Rust's oracle corpus matches that. Directly invoking the generated `vhistory`
  descriptor handler on the same source prints and returns `/proj/foo`. A minimal public parser still returns
  `"name"` for a normal scalar-held `payload[1]`, while a minimal grammar with a leading-newline object regex
  reproduces the null. Conclusion for this slice: do not weaken Dart indexed-variable reads globally. The next
  owned leaf is `.6.2.4.4.6`, which must resolve the leading-newline public-parser/oracle boundary explicitly.

- 2026-07-09 (FUTURE-PARITY-BACKLOG.9.0 — AND/OR edge-default correction captured):
  The director corrected the earlier optional-edge-marker brainstorm. The future design direction is now
  mode-sensitive: AND rules should be the low-ceremony sequence surface, so a bare `entry { ... }` line in an AND
  rule should mean blind-call `=> entry { ... }`; OR/default rules should stay regex-dispatch surfaces, so a bare
  `entry { ... }` line there should mean action-edge `-> entry { ... }`. Explicit `=>` remains the blind-call
  marker and explicit `-> entry[k]` remains regex-slot action-edge dispatch. Important boundary: blind-call means
  the parent does not preselect by the child regex; a normal child call still runs the child rule's own parser
  semantics unless a future design intentionally defines a separate bypass. First-rule-as-top and OR pipe sugar are
  related future design questions, not current behavior.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.4 — Dart legacy structural accumulator parity):
  Dart now implements the documented `push(Child)` convention in action-edge blocks: when the sole argument names
  a rule, the runtime executes that child, refreshes `retv`, and appends the child result to the current rule's
  implicit accumulator. This fixes `regdef.spec`, where `regdef_top` uses `push(reg_def)` and `reg_def` uses
  `push(reg_fld)` before returning snapshots of their own accumulators. `regdef_nested_register_fields` now
  passes, moving the shipped-spec/parser-smoke window to 23/31 green. `ds_vhistory_version_entry` remains routed:
  the fixture expects `null` for the object name, while the live spec assigns `cur_object = call(object)` and then
  reads `cur_object[1]`. Dart follows the current scalar-held direct-access surface and returns `/proj/foo`; Rust's
  current `IndexedVar` path reads aggregate arrays only and yields `undef`/`null`. That mismatch needs an explicit
  residual oracle/contract decision rather than a hidden Dart semantic regression.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.3 — Dart helper mutation/text-normalization parity):
  Dart now treats statement-form `substr(target, pattern, replacement, flags)` and
  `regex_subst(target, pattern, replacement, flags)` as scalar mutations, matching the Rust/Perl contract used by
  shipped specs such as `lib_reader.spec`. Replacement strings expand `$n` capture placeholders, helper flags
  drive the shared runtime regex compiler, and `split(array(target), source, delimiter)` replaces the explicit
  aggregate target rather than merely returning a list. Dart also exposes entry/local regex start line/column
  helpers for `simenv.spec` diagnostic paths. The focused runtime fixture intentionally uses newline-separated
  statements without semicolons, reflecting the current separator contract: semicolons are only needed to separate
  multiple statements on the same line. `simenv_multiline_value`, `lib_reader_sattribute`, and
  `lib_reader_cattribute` pass; the shipped-spec/parser-smoke window is now 22/31 green.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.2 — Dart hlink delimiter/capture parity):
  Hlink exposed a Dart store-channel mismatch rather than a capture-boundary bug: `word_items = []` creates a
  scalar-held list, `push(array(word_items), retv)` was appending to aggregate storage, and `array(word_items)`
  correctly preferred the still-empty scalar-held list. Dart now routes `push(...)` and `items += value` through
  one append helper that mutates the scalar-held list when it is the current owner, while explicit
  `set(array(name), ...)` aggregate resets keep their existing aggregate-storage behavior. `call(...)` also
  refreshes the runtime `retv` channel after child execution, so hlink's `retv = call(child)` plus lifecycle
  collection path matches the Rust/Perl oracle. All five hlink fixtures pass; the shipped-spec/parser-smoke window
  is now 19/31 green, with `tablegrep_simple_term` also passing from the scalar-held append fix.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.1 — Dart array flat list-context splice):
  Dart now mirrors the Rust/Perl list-context rule for `array(...)`: explicit `flat(...)`, `flat_array(...)`, and
  `flat_hash(...)` call or fluent arguments splice their returned aggregate into the constructed array, while
  `copy(...)` and ordinary array-valued expressions remain one nested argument. This closes the portmap result
  shape mismatch where tagged payloads such as `["foo"]` were emitted as `[["foo"]]`. The five portmap corpus
  fixtures pass, and `vhdl_library_use` also passes because it used the same splice mechanism. The final
  shipped-spec/parser-smoke diagnostic window moves to 13/31 green; the next residual leaf is hlink
  delimiter/capture parity.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.4.0 — Dart residual parser-smoke split):
  The residual shipped-spec/parser-smoke window is now split after the `.6.2.4.3` recursive/default-mode bridge.
  The diagnostic boundary is 7/31 green. PCRE structural regex blockers stay in `.6.2.4.6`, while `.6.2.4.4`
  now has narrow non-PCRE leaves: `.6.2.4.4.1` for portmap/action-edge child result shape parity, `.6.2.4.4.2`
  for hlink delimiter/capture parity, `.6.2.4.4.3` for helper mutation and text normalization, `.6.2.4.4.4` for
  legacy structural smoke outputs, and `.6.2.4.4.5` for residual closeout. No Dart runtime behavior changed in
  this split; it exists to keep the next implementation slice recoverable.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.3 — Dart recursive/default-mode dispatch semantics):
  Dart now carries Rust-style action-edge dispatch metadata through compiled state: each edge records the regex
  alternative that triggers it, the target child regex index, and whether it was anchored to a same-line parent
  regex. Edge-only child regexes are resolved into the parent alternation before runtime execution, and runtime
  dispatch executes all edges for the selected regex index. This closes the tclite empty-child-output gap and
  avoids guessing from action-edge list positions. Dart also now treats `set(array(name), ...)` and
  `set(hash(name), ...)` as rule-local aggregate resets: the first reset in a rule invocation snapshots the prior
  binding and restores it on rule exit, while ordinary undeclared child mutations remain caller-visible. The
  recursive `sexpr` corpus cases now match the Rust/Perl oracle. The shipped-spec/parser-smoke window is 7/31
  green; remaining Lispish failure is recursive PCRE `(?R)` routed to `.6.2.4.6`, while residual hlink/output/helper
  parity stays in `.6.2.4.4`.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.2 — Dart helper/action surface bridge):
  Dart now executes the helper/action surfaces that were blocking the final shipped-spec/parser-smoke window after
  the regex bridge: direct anonymous capture-slice helpers (`start_capture_slice`, `capture_slice`,
  `capture_slice_len`, `capture_slice_until_cursor`, `capture_slice_until_cursor_len`, `capture_slice_pos`,
  `capture_slice_line`, `capture_slice_col`), logical `and`/`or`/`not`, diagnostic output helpers
  `print`/`print_each`/`say`, and Rust-style terminating `exit_now(...)`. The action parser delimiter matcher now
  enters quote/regex scan modes while finding a callee's matching `)`, so literal delimiters inside quoted helper
  arguments (for example `print("begin_end_blocks: BEGIN   (", ...)`) no longer turn the call into raw fallback.
  The diagnostic corpus window remains 2/31 green, but helper/action gaps now route onward as measured
  recursion/default-mode/output mismatches, explicit `exit_now(...)` diagnostic branches, and the `.6.2.4.6` PCRE
  structural regex blockers.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.1 — Dart shipped regex dialect bridge):
  Dart rule regexes and helper regex values now share `compileRuntimeRegex(...)`. The bridge normalizes the
  shipped dialect subset that Dart `RegExp` does not accept directly: POSIX character classes such as
  `[[:alpha:]]`, inline `(?i)` / `(?m)` / `(?s)` flag groups, scoped forms such as `(?s:...)` by lifting those
  options to the compiled Dart `RegExp`, possessive
  quantifier markers (`++`, `*+`, `?+`, `{m,n}+`), lower-bound `{,n}` quantifiers, and Python-style named capture
  syntax. The final corpus window is still 2/31 green, but the previous portmap/EBNF/spec/regdef/VHDL/library
  FormatExceptions caused by those basic dialect forms are gone. Remaining regex FormatExceptions are deeper PCRE
  structural features (`\K`, `(?&name)`, `(?(DEFINE)...)`) and are split to `DART-BACKEND-PARITY.6.2.4.6`.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.4.0 — Dart shipped corpus smoke split):
  The final Dart shipped-spec/parser-smoke corpus window is intentionally split before implementation. The
  diagnostic run `--execute --offset 68 --limit 31` is 2/31 green (`pplugin_empty`, `tkgui_empty`). The failure
  taxonomy is clear enough to slice: regex dialect translation blocks the portmap, EBNF, spec.spec, regdef, VHDL,
  history, and library fixtures before runtime semantics can be measured; helper/action gaps cover
  `capture_slice`, diagnostic `print`, logical `not`, and raw `print(...)` expression parsing; tclite/Lispish/top
  recursion need their own output-semantics leaf; residual hlink/portmap/EBNF/spec/tablegrep/simenv/library
  parity follows after those lower blockers. `.6.2.4.1` is next and owns the Dart regex-dialect bridge.

- 2026-07-09 (FUTURE-PARITY-BACKLOG.8.0 — spec-derived parser/stimuli roundtrip idea):
  The director's `foo.spec` closed-loop validation idea is now parked under `FUTURE-PARITY-BACKLOG.8`. The useful
  core is strong: if `foo.spec` can drive both parser construction and stimuli generation, then `.spec` becomes the
  sole semantic source for parse/roundtrip checks. The guardrail is equally important: the future generator must be
  derived from the normalized `.spec` contract and associated semantic metadata, not from a second hand-written
  grammar that can drift. `.8.1` owns the design pass for bounded generation, progress/termination, expected-output
  oracles, shrinking, negative cases, staged parser composition, and cross-backend parity checks. No implementation
  code changed in the capture slice.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.3 — Dart middle corpus batch):
  The middle helper/control/receiver corpus window is now 25/28 green on Dart. The runtime fixes were deliberately
  contract-shaped: `if(false, then, fallback)` now treats a plain third argument as the else value while preserving
  `elseif(...)` / `else(...)` branch forms; single-argument numeric aggregate helpers such as `min(scores)` and
  `max(scores)` use the aggregate-aware argument path; `array(name)`, `hash(name)`, and `copy(name)` prefer
  scalar-held list/map values before aggregate fallback to match the current duck-typed assignment contract; and
  explicit aggregate writes clear stale scalar-held values. The parser fix is equally important: call arguments
  like `items = [value]` must remain `ActionAssignScalarExpr` positional arguments, not keyword arguments with the
  side effect stripped. The three remaining middle-window failures are top-level `fn` corpus fixtures; routing them
  through Dart requires spec-produced `function_definition` nodes from the owning function shell, so they are split
  to `DART-BACKEND-PARITY.6.2.5` instead of adding a Dart raw scanner.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.2 — Dart starter corpus batch):
  The first 40 shipped manifest fixtures now execute green on Dart through `bin/corpus_runner.dart --execute
  --limit 40`. Two runtime semantics were missing from the interpreter: rule return success cannot be based on
  output truthiness because `[]` and `{}` are valid successful outputs, and marker-form `if(false); ... else();
  ... endif()` must execute as one branch chain rather than as independent statements. `_returned(...)` now marks
  any non-null return value as matched while `return_undef` / null remains a non-match, blind child dispatch uses
  the child rule's `matched` bit, and the action/value block runners select marker-form `if` / `elseif` / `else`
  ranges with nesting-depth tracking before executing the selected branch. Focused runtime tests lock empty
  aggregate returns and marker-form branch execution; the bounded shipped-corpus proof covers starter proof-edge,
  autoexist, mutation, and core terse cases.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.1 — Dart executable corpus selection):
  Added the safe selection surface for the executable Dart corpus harness. `executeCorpusFixtures(...)` now
  accepts `caseNames`, `offset`, and `limit` so callers can run named cases or bounded manifest slices without
  executing all 99 fixtures. `bin/corpus_runner.dart` keeps its default command as a manifest-loader smoke, adds
  opt-in `--execute` mode, and initially required `--case` or `--limit` in CLI execution mode until `.6.3`
  enabled full-manifest execution. Execute mode prints each selected fixture as `PASS` or `FAIL`, reports a
  pass/fail summary, exits `1` for
  selected fixture failures, and exits `64` for invalid selection flags. This is the reporting substrate for
  `.6.2.2` and later corpus batches.

- 2026-07-09 (DART-BACKEND-PARITY.6.2.0 — Dart corpus expansion split):
  Split the broad Dart shipped-corpus expansion into recoverable child leaves before changing runner behavior or
  fixture coverage. `.6.2.1` owns opt-in executable corpus selection/reporting while preserving the default
  manifest-loader smoke. `.6.2.2` owns the starter proof-edge, autoexist, and core terse runtime batch. `.6.2.3`
  owns helper/control/receiver/user-function/tree traversal fixtures. `.6.2.4` owns shipped-spec and parser-smoke
  fixtures. Each implementation batch must either pass on Dart or open a narrowly owned root-cause leaf with
  Perl/Rust oracle evidence; no fixture gets weakened to match Dart.

- 2026-07-09 (DART-BACKEND-PARITY.6.1 — Dart controlled corpus execution):
  Added the first executable Dart corpus harness while keeping the default 99-fixture corpus runner command as a
  manifest-loader smoke. `executeCorpusFixtures(...)` reuses `loadCorpusFixtures(...)`, then runs each fixture
  through the current Dart source parser, compiler, and `LinkedSpecRuntimeEngine`. The comparison uses the same
  backend-neutral output contract as the Rust oracle runner: `expected.json` is the top-rule reference value, and
  the engine output must equal `[expected]`. It reports every fixture failure in the returned result set instead
  of aborting on the first parse/validate/compile/execute/output mismatch. The focused temporary corpus fixtures
  cover scalar output, nested arrays/hashes/null/boolean output, blind rule dispatch, lifecycle output shape, and
  mismatch reporting. `.6.2` remains the shipped 99-fixture expansion/batching leaf.

- 2026-07-09 (DART-BACKEND-PARITY.5.3 — Dart staged descriptor-shape proof):
  Closed the Dart `.5` staged/user-function container with a descriptor-shape proof in `test/compiled_spec_test.dart`.
  The proof starts from spec-returned `function_definition` nodes, runs
  `parseSpecWithStagedUserFunctionDefinitionAsts(...)`, compiles the stitched spec, and asserts the neutral staged
  fields through parsed functions, compiled `UserFunctionRegistry.bodyParseJobs`, descriptor `functions`,
  `meta.function_order`, and runtime output. This is deliberately a shape-preservation layer before `.6` corpus
  parity; it does not widen staged parsing into public `parse_job(...)` authoring.

- 2026-07-09 (DART-BACKEND-PARITY.5.2 — Dart user-function runtime execution):
  `LinkedSpecRuntimeEngine` now resolves exact-arity `UserFunctionRegistry` calls before ordinary helper
  fallback. The runtime evaluates arguments eagerly in the caller, parses/caches each function `body_source` as an
  ActionIR value block, snapshots and clears caller scalar/array/hash stores, binds params into fresh local stores
  with aggregate mirrors for list/map values, executes the body through the existing final-expression/local-return
  value-block evaluator, restores caller stores, and returns copied values so receiver chains can continue.
  Standalone registered calls need no special lowering in Dart because `ActionStatement.dropsValue` already drives
  discarded statement evaluation. Active-call tracking rejects direct and mutual recursion with a structured
  `user_function_call` diagnostic. `.5.3` remains for descriptor/corpus-shape assertions around staged parse jobs
  and function registry records.

- 2026-07-09 (DART-BACKEND-PARITY.5.1 — Dart staged function-body registry):
  Added the Dart equivalent of the narrow function-body staged registry provider. `executeStagedParseJobs(...)`
  now validates and stable-sorts jobs by parent AST path, source span, and job id; resolves `actionir-body.spec`
  to `builtin:actionir-body.spec`; records the fixed adapter digest and cache-key fields for top rule
  `action_block`; executes body text with the Dart ActionIR block parser; and returns staged result records.
  `dispatchFunctionBodyParseJobs(...)` and `parseSpecWithStagedUserFunctionDefinitionAsts(...)` stitch returned
  `action_block` JSON into function `body_ast` without widening the public staged-parsing contract. General
  `parse_job(...)` authoring, provider search, and recursive staged queues remain future work; user-function
  runtime execution has since landed in `.5.2`.

- 2026-07-09 (DART-BACKEND-PARITY.4.5.4 — Dart diagnostics/trace no-drift):
  Closed the Dart diagnostics/trace container. The agreed boundary is now: structured runtime diagnostics,
  `LinkedSpecTrace*` controls/sinks/events, traced runtime entrypoints, and runtime interpreter trace events are
  implemented; staged registry execution, user-function runtime parity, corpus output parity, and Dart-specific CLI
  productization remain later leaves. The active frontier is `.5.1`, the minimal staged registry provider.

- 2026-07-09 (DART-BACKEND-PARITY.4.5.3 — Dart runtime trace events):
  Added runtime interpreter instrumentation on top of the `.4.5.2` Dart trace controls. `LinkedSpecRuntimeEngine`
  now emits parse/rule scopes, recursion-cutoff decisions, regex match/no-match decisions, action-edge and
  blind-call child-dispatch decisions, lifecycle block marks, cursor-control helper marks, and
  `capture_until_boundary(...)` source-boundary marks through the optional `LinkedSpecTraceEmitter`. These are
  trace-only side effects: no emitter keeps the runtime quiet, and focused tests compare traced and untraced
  parse-result JSON to lock output preservation. `.4.5.4` remains the no-drift closeout before staged runtime work.

- 2026-07-09 (DART-BACKEND-PARITY.4.5.2 — Dart trace controls):
  Added the Dart trace control layer under `dart/lib/src/trace/trace.dart`. It mirrors the documented external
  contract: ordered `none`/`low`/`medium`/`high`/`full`/`debug` levels, `LINKEDSPEC_TRACE_*` environment controls,
  stdout/route/mirror sinks, routed-file reset/truncate, structured event/scope/decision/log/dump primitives, and
  default quiet behavior. `LinkedSpecRuntimeEngine` now accepts an optional trace emitter and exposes
  `parseWithTrace(...)` / `executeWithTrace(...)`. This leaf emits only parse-scope enter/exit events so output
  preservation and sink behavior are locked before `.4.5.3` adds runtime branch/lifecycle/source-boundary events.

- 2026-07-09 (DART-BACKEND-PARITY.4.5.1 — Dart runtime diagnostics):
  Added the first Dart runtime structured diagnostic surface. `RuntimeDiagnostic` is public and is carried by
  `RuntimeInterpreterException.diagnostic`; it uses the neutral diagnostic fields from the mdBook contract rather
  than a Dart-only shape. `LinkedSpecRuntimeEngine` accepts optional `specName` / `specPath` for callers that have
  file identity. The parse boundary wraps otherwise-plain runtime exceptions with top-rule/current-rule
  attribution, while missing compiled-rule lookup emits a more specific `rule_lookup` diagnostic. Successful
  `RuntimeParseResult` JSON is intentionally unchanged. Trace levels, event classes, and sinks remain `.4.5.2`.

- 2026-07-09 (DART-BACKEND-PARITY.4.5.0 — Dart diagnostics/trace split):
  Split the broad Dart runtime diagnostics/trace-controls leaf before implementation. `.4.5.1` now owns
  structured runtime diagnostics and diagnostic-carrying exceptions/result metadata; `.4.5.2` owns trace levels,
  controls, event classes, and stdout/routed-file/mirror sinks; `.4.5.3` owns runtime interpreter instrumentation
  for rule dispatch, regex/blind branches, lifecycle blocks, and source-boundary/cursor helpers where implemented;
  `.4.5.4` owns the no-drift closeout across Dart README/CLI status, mdBook, live docs, task-tree index, and
  Knowledge Map. This is a planning split only; the next executable frontier is `.4.5.1`.

- 2026-07-09 (BACKTRACK-SURFACE-RUST-ALIGNMENT.2 — non-consuming boundary capture):
  Added the zero-width/lookahead member of the explicit cursor-control split:
  `capture_until_boundary(rule[, ...])`. The helper is cursor-based, not
  anonymous-capture-cursor based: from the live cursor it probes the named
  boundary rules, captures the text before the earliest boundary match, and
  leaves that boundary unconsumed for the ordinary rule path. This is the right
  primitive for open-ended payloads such as EBNF semantic annotations. Do not try
  to model this with `save_cursor()` / `restore_cursor()` or by consuming a
  structural token and then using `rewind_match_start()`; those are still useful
  controls, but boundary lookahead avoids consuming the token in the first place.
  Deferred design direction surfaced during review: repeated identical child
  slots in `AND` rules are legal but visually weak. If this is pursued, reserve
  a target-side child-edge quantifier such as `-> Annotation{2}` or
  `-> Annotation{1,3}` for `AND` rules only; keep `[N]` as regex-index syntax
  and do not apply `{N,M}` to default/OR dispatch. A broader AND-only compact
  sequence syntax is also plausible, for example `Foo:AND` followed by ordered
  entries like `ruleA`, `ruleB { ... }`, or `ruleA[Q]{3} { ... }`; in that
  model `-> ruleA` should remain the explicit action-edge spelling and should
  still mean just `ruleA` in an AND sequence. A further refinement is to allow a
  bare `ruleA` entry to mean the ordinary action-edge child parse in AND only,
  making `->` optional there, while keeping `=>` mandatory for blind-call entries
  because they have different result-channel semantics.

- 2026-07-09 (BACKTRACK-SURFACE-RUST-ALIGNMENT.1 — explicit cursor controls):
  Replaced the ambiguous current backtrack helper surface with explicit names across Perl, Rust, and Dart.
  `save_cursor()` / `restore_cursor()` are the stack-based cursor primitive; `rewind_match_start()` /
  `rewind_entry_start()` are direct lifecycle-anchor rewinds. The old `BACKTRACK()` / `IBACKTRACK()` and
  lowercase `backtrack(label)` / `ibacktrack(label)` forms are not current portable API. `specs/ebnf.spec`
  currently uses `rewind_match_start()` as the semantic-preserving replacement for its former consume-then-rewind
  annotation boundary; `BACKTRACK-SURFACE-RUST-ALIGNMENT.2` owns the better zero-width/lookahead boundary
  primitive so that case can detect the next structural token without consuming it.

- 2026-07-09 (DART-BACKEND-PARITY.4.4 — Dart BACKTRACK cursor rewinds):
  Extended `LinkedSpecRuntimeEngine` with cursor/input helper execution and cursor-only rewind operations.
  `BACKTRACK()` rewinds to the current local match start, and `IBACKTRACK()` rewinds to the initial/entry match
  start for the current context. The director clarified that the `I` in `IBACKTRACK` is the Initial/`I` lifecycle
  context, not case-insensitivity. Rewinds update the live cursor/register cursor only; they do not roll back match
  records, stores, accumulators, lifecycle effects, or branch decisions. The runtime now also returns char-based
  `cursor_*` and `input_*` helper values while preserving Dart's internal code-unit offsets. A later
  Rust-reference cleanup removes the short-lived Dart lowercase backtrack compatibility aliases before they become
  a durable public surface. Next frontier is `.4.5`, runtime diagnostics and trace controls.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.6 — Dart helper/value no-drift closeout):
  Fixed Dart nested value-path assignment in `LinkedSpecRuntimeEngine` to match the documented Perl/Rust contract.
  Successful nested writes now return the updated root aggregate; missing roots, missing or wrong intermediate
  containers, array gaps, and string-literal keys on scalar-held arrays return `null` without mutation; final hash
  keys may be created and final array indexes may replace or append exactly at `len`. The direct hash-index
  assignment path now preserves scalar-held map/list root ownership before falling back to named hash storage, and
  nested assignment evaluates segment index expressions before the RHS value expression to match Rust/Perl.
  This closes the `.4.3` helper/value container. Next frontier is `.4.4`, BACKTRACK and local cursor rewind
  behavior.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.5 — Dart runtime controls and tree callbacks):
  Extended `LinkedSpecRuntimeEngine` with expression-valued block execution, block-local `return(...)` /
  `return_undef()`, attached `if` / `elseif` / `else` and `when` / `otherwise` branch chains, attached
  `switch` / `case` / `default`, attached `while` with the deterministic iteration guard, inline lazy
  `if(...)` / `switch(...)`, helper-form `with(value) { ... }` / `with() { ... }`, receiver `.with() { ... }`,
  and hash/array `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver callbacks. Callback frames
  scope and restore `value`, `path`, `depth`, hash `key`, array `index`, and reduce-only `acc`; hash traversal is
  sorted-key depth-first and array traversal is zero-based depth-first. At completion, the next frontier was
  `.4.3.6` helper/value no-drift closeout; that closeout has since landed.

- 2026-07-09 (DART-BACKEND-PARITY.7.3 — variant-specific CLI requirement):
  Recorded the director directive that each LinkedSpec backend variant should have a distinct CLI. This is a
  planning/documentation slice only: no source behavior changed. The Dart tree now owns future Dart-specific CLI
  productization as `DART-BACKEND-PARITY.7.4`, and final Dart no-drift closeout shifts to `.7.5`. The
  `FUTURE-PARITY-BACKLOG` tree records that Julia and Lua planning must include equivalent variant-specific CLI
  ownership when those lanes activate. The implementation frontier later advanced through `.4.3.5`.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.4 — Dart runtime hash helpers):
  Extended `LinkedSpecRuntimeEngine` with hash-aware helper dispatch. Function helper calls now consume bare hash
  working variables in the documented hash slots, while receiver chains such as
  `meta.set_key("stage", "normalized").sorted_keys().join_values(",")` read a hash snapshot and remain pure.
  The runtime now covers key/value views, sorted key/value arrays, key predicates, `merge_hash`, `set_key`,
  `rename_key`, `drop_keys`, `pick_keys`, `flat_hash`, direct hash-index assignment values, and explicit
  `flat(...)`/`flat_hash(...)` splicing inside `hash(...)`. The merge boundary remains intentional:
  `merge_hash(copy(hash(base)), overlay)` consumes the later bare overlay, while a bare first argument is not
  treated as the base hash. Next frontier is `.4.3.5`, value blocks, structured action controls, and tree
  traversal callback helpers.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.3 — Dart runtime array helpers):
  Extended `LinkedSpecRuntimeEngine` with array-aware helper dispatch. Function helper calls now evaluate bare
  array working variables as array snapshots in array-consuming slots, while receiver chains such as
  `items.sorted().drop_front(2).first()` read the aggregate store without mutating it. The runtime now covers
  array ordering/selection/membership helpers, transform/filter pipelines, delimiter-first receiver
  `join_values`, regex split/filter bridges, `flat_array`, `concat_arrays`, `split_tagged_records`, and terminal
  array numeric reducers. Top-level statement receiver methods `push_back`, `push_front`, `pop_back`, and
  `pop_front` mutate named working arrays; the same calls in value positions return `null` and do not mutate.
  Adjacent split delimiters preserve empty fields, leaving `filter_nonempty` as the explicit cleanup step. Next
  frontier is `.4.3.4`, hash helper family and hash receiver/mutation behavior.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.2 — Dart runtime string/numeric helpers):
  Extended Dart pure helper execution in `dart/lib/src/runtime/interpreter.dart`. Helper names are now
  canonicalized through the ActionIR contract table before runtime dispatch, so current aliases and symbol callees
  share the same implementation path. The runtime now evaluates `cat`, trim/case/substring/prefix/suffix/search
  helpers, regex `matches`, `split`, `coalesce`, definition/empty predicates, explicit `str_*` lexical
  comparisons, numeric arithmetic/reducers/comparisons, numeric word aliases such as `avg` and `gt`,
  arithmetic/comparison symbol callees such as `+(...)` and `<=(...)`, and compatible string/number receiver
  chains such as `raw.trim().lowercase()` and `17.mod(5)`. Focused interpreter tests cover successful helper
  values and invalid numeric inputs returning `null`. Next frontier is `.4.3.3`, array helper family and array
  receiver/mutation behavior.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.1 — Dart runtime value/capture helpers):
  Extended the Dart interpreter's core ActionIR evaluator in `dart/lib/src/runtime/interpreter.dart`. The runtime
  now keeps separate scalar, array, and hash working stores while preserving typed JSON shapes for scalar
  assignment, array append, hash-index mutation, direct shape literals, and wrapper snapshots. `set(hash(name), ...)`
  and `hash(name)` read/write hash stores, `array(name)` / `hash(name)` also snapshot variable-held list/map
  values, `copy(name)` snapshots aggregate stores when the bare name is type-implying, and indexed/nested reads
  support string-key map access. The capture helper surface now includes `entry_named`, `match_named`,
  `entry_has`, `match_has`, `entry_map`, `match_map`, `entry_len`, `match_len`, `entry_start_pos`,
  `entry_end_pos`, `match_start_pos`, and `match_end_pos`; bare capture-name arguments such as
  `entry_named(name)` are interpreted as capture keys, not scalar variable reads. Focused runtime interpreter tests
  cover these value/store/capture seams. Next frontier is `.4.3.2`, string/scalar and numeric helper families.

- 2026-07-09 (DART-BACKEND-PARITY.4.3.0 — split Dart runtime helper families):
  Split the broad Dart runtime value/helper work before implementation. `.4.3.1` owns core runtime
  value/store behavior and capture helper reads; `.4.3.2` owns string/scalar and numeric helpers; `.4.3.3`
  owns array helpers and array receiver/mutation behavior; `.4.3.4` owns hash helpers and hash receiver/mutation
  behavior; `.4.3.5` owns value blocks, structured action controls, and tree traversal callback helpers; `.4.3.6`
  owns helper/value no-drift closeout before BACKTRACK work starts.

- 2026-07-09 (DART-BACKEND-PARITY.4.2 — Dart runtime rule interpreter):
  Added Dart's first executable runtime interpreter in `dart/lib/src/runtime/interpreter.dart`.
  `LinkedSpecRuntimeEngine` runs `CompiledSpec` rules over the `.4.1` regex/match-state layer and returns
  `RuntimeParseResult` with the top rule value, Rust-style one-element output wrapper, cursor offsets, and
  lifecycle events. The interpreter now covers rule dispatch, default/AND/OR/repetition modes, action-edge and
  blind-call child dispatch, entry/local match handoff, explicit returns, `retv`, accumulator collection, bounded
  repetition, zero-progress cutoffs, and recursion cutoffs. The embedded ActionIR evaluator is intentionally
  narrow and dispatch-facing (`return`, `return_undef`, `set`, `push`, `array`, `copy`, `cat`, `call`,
  `entry_*`, `match_*`); `.4.3` owns the broader helper/value model. Focused runtime interpreter tests cover
  regex repetition collection, action-edge fluent `.push`, blind AND/OR dispatch, bounded OR repetition,
  zero-progress repetition, and lifecycle ordering.

- 2026-07-09 (DART-BACKEND-PARITY.4.1 — Dart runtime matching state):
  Added Dart runtime matching primitives in `dart/lib/src/runtime/matching.dart`. `RuntimeRegexAlternation`
  compiles ordered regex lists from compiled rules and supports `seek` and `consume` matching with stable
  alternative identity. `RuntimeRegexMatch` records code-unit spans, compact capture-only groups, named captures,
  char offsets, line/column projection, and zero-width/progress helpers. `RuntimeMatchRegisters` keeps entry and
  local match registers separate for later child dispatch, tracks cursor position, and exposes zero-progress
  detection. Focused runtime matching tests prove seek/consume behavior, compiled-rule regex-list use, capture
  shape, UTF-16/code-point offset projection, entry/local separation, and zero-progress candidates. Next frontier
  is `DART-BACKEND-PARITY.4.2` rule dispatch, rule modes, recursion guards, repetition bounds, and lifecycle order.

- 2026-07-09 (DART-BACKEND-PARITY.3.4 — Dart compiled spec state):
  Added Dart's backend-neutral compiled state in `dart/lib/src/compiler/compiled_spec.dart`. `compileSpec(...)`
  validates `SpecFile` inputs by default, builds deterministic `definition_order` / `compiled_rule_order`,
  preserves redefinition metadata for deliberate validation-skipped builds, carries the `UserFunctionRegistry`,
  records per-rule regexes, dependency refs, mode metadata, action/blind edges, and lifecycle/plain/edge
  `ActionBlock` payloads with registry-aware ActionIR contract resolution. `CompiledDependencyRegexState` derives
  structured child-regex dispatch data, and `CompiledDescriptorState` projects the mdBook descriptor shape:
  `spec`, `functions`, `dependency_regex_map`, and `meta`. Focused compiled-state tests, Dart analyze, and the
  full Dart suite pass before the full slice gate. Next frontier is `DART-BACKEND-PARITY.4.1` runtime matching
  and match-state tracking.

- 2026-07-09 (DART-BACKEND-PARITY.3.3 — Dart function registry):
  Added Dart's first user-function registry seam in `dart/lib/src/action/function_registry.dart`. The registry
  builds ordered entries from `FunctionDefinition`, preserves params, arity, source/body spans, `body_payload`,
  `body_parse_job`, optional stitched `body_ast`, and exposes staged function-body parse jobs for the next
  compiled-state leaf. The ActionIR contract resolver now accepts an optional `UserFunctionRegistry`: exact-arity
  registered calls classify as `user_function` before helper fallback, while wrong-arity registered calls diagnose
  as `user_function_arity_mismatch`. Focused registry/contract tests, Dart format/analyze/full tests, corpus
  runner, CLI help, and mdBook build pass. Next frontier is `DART-BACKEND-PARITY.3.4` compiled-spec/interpreter
  state.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.5 — final helper purge no-drift closeout):
  Closed the Perl/Rust non-current helper code purge. Final exact retired-helper call-shape, label/tag, and
  `?concat:` scans over active source/test/tool/spec/book surfaces are clean. The closeout found one remaining Rust
  runtime unit-test fixture that used retired helper strings only as generic unknown-helper examples; it now uses
  invented unknown helper names and still proves unknown helpers return `undef` without mutating aggregates. The
  short-wrapper `s/a/h` spec-surface scan only hits parser input text `(a(b)c)`, not helper calls. Rust formatting
  and the focused runtime unknown-helper unit test pass. The next PNT frontier returns to
  `DART-BACKEND-PARITY.3.3`.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.4 — active fixture/spec spelling migration):
  Migrated the remaining active tests, tooling examples, generated corpus inputs, and checked-in `.spec` labels away
  from retired helper spellings after the Perl/Rust source recognition paths were closed. Generic unknown-helper
  tests now use invented helper names, inspection examples use current `return(...)` syntax, and the validation fuzz
  deep-nesting case uses current assignment syntax. EBNF return annotation rules/output tags now use
  `return_scalar_value` / `return_array_value`; portmap concatenation output now uses `?concatenation:` across
  source spec, corpus input/expected output, Perl/Rust tests, and the mdBook walkthrough. Focused scans are clean for
  retired call shapes, retired label/tag collisions, and exact `?concat:` over active surfaces. Syntax checks,
  focused tests, full phase0 (`1027` tests, `PERL5LIB=` cleared), regenerated 99-fixture Rust oracle corpus, full
  `linkedspec-runtime`, and mdBook build pass. Final no-drift closeout remains queued under `.5`.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.3 — Rust helper diagnostic purge):
  Removed Rust source recognition and name-specific diagnostic paths for the retired `SPEC-FORMAT-TERSE.8`
  helper spelling set. `linkedspec-core` no longer treats retired helper names as known ActionIR calls, the
  expression parser no longer preserves `declare(...)` keyword-argument syntax just to reach a retired-helper
  diagnostic, and `linkedspec-runtime` no longer has a `retired_helper_error(...)` branch ahead of generic helper
  dispatch. Internal runtime context append/snapshot methods now use neutral names (`push_array_value`,
  `array_snapshot`, `hash_snapshot`) rather than public-looking retired helper names. The explicit regression for
  retired helper-looking calls now expects generic unknown-helper behavior, and a stale positive Rust fixture was
  migrated from retired `=>` hash-literal syntax to current `{ key : value }`. Full `linkedspec-core` and
  `linkedspec-runtime` package tests pass; active test/tool/spec fixture migration remains queued under `.4`.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.2.4 — Perl source purge closeout):
  Closed the Perl source purge container with focused scans and behavior probes rather than new source edits.
  Exact retired helper call-shape scans over `perl/LinkedSpec.pm` and `perl/LinkedSpec` are clean for the
  `SPEC-FORMAT-TERSE.8` spelling set; remaining exact-name hits are raw-compat comments or implementation words,
  not helper-call recognition branches. `call_spec_handler_subst` probes confirm current `cat(...)`, `copy(...)`,
  `set(...)`, and `push(...)` still lower, while retired value-position helper-looking calls such as `concat(...)`,
  `a(...)`, and `scalaref(...)` use the same generic unsupported-helper sentinel as an invented unknown helper.
  Standalone unregistered function-shaped statements remain the existing raw compatibility debt documented in
  the mdBook; this leaf closes Perl source recognition/diagnostic paths and advances to Rust source cleanup.
  Focused syntax/ActionIR tests and full phase0 (`1027` tests, `PERL5LIB=` cleared) pass.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.2.3 — Perl helper metadata name purge):
  Perl ActionIR raw-Perl passthrough contracts no longer publish exact retired helper names as diagnostic labels:
  raw lexical declarations and raw assignment compatibility events now report neutral `raw_*` labels instead of
  `declare` / `assign`. Added `t/noncurrent_helper_metadata.t` to lock contract IDs, diagnostic names,
  rewrite-contract metadata, canonical events, and unsupported-helper events against the `SPEC-FORMAT-TERSE.8`
  retired helper set. The focused metadata test, ActionIR AST/compact-lowerer tests, exact metadata scan, and full
  phase0 regression (`1027` tests, `PERL5LIB=` cleared) pass. Next Perl leaf `.2.4` closes broader Perl source
  purge scans and current/unknown-helper behavior probes before Rust source cleanup.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.2.2 — Perl declaration/return helper path purge):
  Removed the dedicated Perl source-owner paths for removed declaration helper spellings, old return-family
  helper spellings, and old short-wrapper spellings. `DeclareMethod`, `RuleIR::EmitContext`, method lowering,
  contracts, scanner metadata, canonical events, rewrite-pipeline classification, and control-flow lookahead now
  rely on current `return(...)`, `return_undef(...)`, `set(...)`, assignment/reset, auto-existing working
  variables, `array(...)`, `hash(...)`, and bare-read behavior instead of helper-specific removal/compatibility
  branches. Active focused tests were rewritten to current helper spellings or generic invented helper names.
  Syntax checks, the AST parser suite, compact-lowerer trace test, full phase0 regression (`1027` tests),
  scoped exact Perl/test scans, and mdBook helper/status scans pass. Remaining Perl cleanup is deliberately
  confined to `NONCURRENT-HELPER-CODE-PURGE.2.3`: metadata/owner-name cleanup before Rust source work.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.2.1 — Perl current helper compatibility purge):
  Perl ActionIR current helper lowering no longer normalizes through removed string/copy/assignment helper names,
  and explicit append lowering is now named and contracted as current `push`. The removed append-helper scanner,
  contract, source lowerer, AST-test fixture, flow lookahead, rewrite-pipeline, and preamble collection paths are
  gone from the touched owners rather than retained as diagnostic-only branches. AST parser tests now preserve
  current `set` method names and expect current `__ls_cat_*` temporary names. `DeclareMethod` now handles current
  `set(...)` with slash-regex payloads through a current-only top-level argument splitter instead of the removed
  normalized-name route, and the bootstrap helper classifier no longer accepts deleted current-helper-family
  names as general return payloads. Focused syntax checks, the AST parser suite, compact-lowerer trace test,
  full phase0 regression (`1..1028`), direct current-helper probes, and the deleted-spelling scan pass.
  Remaining Perl purge work is deliberately not closed: declaration/return/wrapper source-owner paths and
  contract metadata remnants stay queued under `NONCURRENT-HELPER-CODE-PURGE.2.2` / `.2.3`.

- 2026-07-09 (NONCURRENT-HELPER-CODE-PURGE.1 — code purge inventory/split):
  Created `docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md` after the director clarified that non-current helper
  spellings must not remain as name-specific recognition or diagnostic surfaces in the Perl and Rust codebases.
  Read-only scans show owner categories across Perl ActionIR source, Rust runtime source, active tests, tooling,
  generated corpus input production, and checked-in `.spec` labels/strings. The broad string scan also produces
  false positives from ordinary implementation words, so the implementation leaves must be context-aware and
  cannot use blind replacement. The first executable frontier is `.2`, Perl source recognition/diagnostic path
  removal, before Rust source and fixture/tool/spec cleanup.

- 2026-07-09 (DART-BACKEND-PARITY.3.2 — Dart ActionIR contract resolver):
  Added `dart/lib/src/action/action_contracts.dart` and exported the resolver APIs from the public Dart
  library. Dart now resolves typed ActionIR calls, receiver methods, structural assignments, structured
  controls, nested arguments, block values, shape literals, and access expressions into current canonical
  helper/control contracts. Non-current helper-looking calls produce a generic `unknown_helper` diagnostic;
  unsupported parser expressions remain `raw_perl` diagnostics. `spec_validator.dart` now imports the
  shared current helper/control name table through `isKnownActionIrCallName(...)`, so user function names
  collide with active built-ins without maintaining a second validator list. The Dart variant intentionally
  carries no non-current helper spelling table or replacement map. `test/action_contracts_test.dart` covers
  canonicalization, structural assignment contracts, unknown/raw diagnostics, and function-registry collisions.
  `.3.3` owns the staged function-body registry and exact-arity resolution work.

- 2026-07-09 (DART-BACKEND-PARITY.3.1 — Dart ActionIR AST parser):
  Added `dart/lib/src/action/action_ast.dart` and `dart/lib/src/action/action_parser.dart`, exported from the
  public Dart library. Dart now parses helper/action source into typed ActionIR nodes for action blocks,
  value-drop statements, calls, positional/keyword args, literals, variables, indexed/nested access, array/hash
  shape literals, scalar/array/hash/nested assignments, expression-valued blocks, receiver-dot fluent chains,
  trailing block arguments, and attached structured controls (`if`/`when`, `elseif`/`else`/`otherwise`,
  `while`, `switch`/`case`/`default`). Unsupported expressions remain structural `raw_perl` nodes for later
  validation/diagnostics; no helper-family resolution or runtime behavior landed. `test/action_ast_parser_test.dart`
  covers the accepted node families. `.3.2` owns mapping typed nodes to canonical helper contracts and
  diagnostics.

- 2026-07-09 (DART-BACKEND-PARITY.2.4 — Dart function-definition shell projection):
  Added `dart/lib/src/parser/user_function_definition_shell.dart` with
  `projectUserFunctionDefinitionAsts(...)` and `parseSpecWithUserFunctionDefinitionAsts(...)`.
  Dart now consumes the spec-defined `function_definition` / `function_definition_error` node shape from
  `specs/user_function_definition.spec`, validates source/body spans, preserves and normalizes `body_payload`
  plus `body_parse_job` sidecars, strips returned definition spans before rule parsing, and attaches ordered
  `FunctionDefinition` records. The implementation intentionally does not raw-scan `fn` source; until Dart
  has an executable `.spec` engine, the semantic input is the AST node list returned by the owning spec.
  `StagedParseJob` now round-trips function-body metadata fields (`version`, `function_name`, `params`,
  `arity`, `diagnostic_owner`). `test/user_function_definition_shell_test.dart` covers projection,
  malformed-node diagnostics, sidecar drift rejection, and the no-raw-scanner boundary. The `.2` frontend
  container is closed; `.3.1` starts typed helper/action AST parsing.

- 2026-07-09 (DART-BACKEND-PARITY.2.3 — Dart frontend validation):
  Added `dart/lib/src/validation/spec_validator.dart` with `validateSpec(...)`. The validator mirrors the
  Rust/source-AST validation boundary: top-rule presence, duplicate rule/function names, function registry
  collisions and parameter checks, raw malformed body lines, mixed action/blind edges, grouped action edges
  without a shared block, undefined targets, regex-slot index range checks, and lightweight regex structural
  checks. `strictSyntax: true` adds unused-rule rejection. `test/spec_validator_test.dart` covers focused
  negative cases plus non-strict validation over all shipped `specs/*.spec` and rule-only corpus specs.
  Top-level `fn` shell extraction remains `.2.4`; runtime semantics remain later lanes.

- 2026-07-09 (DART-BACKEND-PARITY.2.2 — Dart `.spec` parser):
  Added `dart/lib/src/parser/spec_parser.dart` and exported `parseSpec(...)` from the public Dart library.
  The parser mirrors the current Rust core parser boundary: it parses rule paragraphs into source AST types,
  recognizes headers/modes/header-rest bodies, regex literals, lifecycle blocks, action and blind-call edges,
  action-edge fluent continuations, receiver-fluent `when/otherwise` blocks, split/conditional markers, comments,
  raw fallback lines, and nested block boundaries. `test/spec_parser_test.dart` covers the tricky Rust parity
  seams, all shipped `specs/*.spec`, and corpus `input.spec` files that do not start with top-level `fn`
  definitions. Strict validation is still `.2.3`; function-shell extraction/staging is still `.2.4`.

- 2026-07-09 (DART-BACKEND-PARITY.2.1 — Dart frontend AST data types):
  Added `dart/lib/src/ast/spec_ast.dart` with source-level data types matching the Rust parsed AST and
  staged parse-job JSON shape: `SpecFile`, `FunctionDefinition`, `SourceSpan`, `StagedParseJob`,
  `Rule`, `RuleHeader`, `RuleMode`, body-element variants, `EdgeTarget`, and `FluentCall`.
  `test/spec_ast_test.dart` proves JSON round-trips and `RuleMode` repetition helper parity. This is
  deliberately data-only; no parser, compiler, runtime, or helper/action lowering code landed. `.2.2`
  owns the actual `.spec` parser.

- 2026-07-09 (DART-BACKEND-PARITY.1.3 — Dart corpus manifest IO scaffold):
  Added `dart/lib/src/corpus/manifest_runner.dart` and `test/corpus_manifest_test.dart`. Dart now loads
  the Rust-owned language-neutral corpus manifest, validates format `1`, `case_count`, case names,
  duplicate names, missing/stale fixture directories, required `input.spec` / `input.txt` /
  `expected.json`, and expected JSON syntax. `bin/corpus_runner.dart --corpus ...` reports the loaded
  fixture count but still does not parse or execute `.spec` semantics. The checked-in corpus currently
  loads as 99 fixtures. This closes the `.1` toolchain/workspace/foundation container; `.2.1` starts the
  frontend AST/data-type layer.

- 2026-07-09 (DART-BACKEND-PARITY.1.2 — Dart scaffold package):
  Created the first repo-owned Dart package under `dart/`. It is deliberately scaffold-only:
  `pubspec.yaml` + committed `pubspec.lock`, strict analyzer options, package README, public library
  entrypoint, `bin/linkedspec_dart.dart`, `bin/corpus_runner.dart`, and a `package:test` smoke test.
  The only dependency is the hosted `test` dev dependency; `.dart_tool/` and build outputs are ignored.
  `dart pub get` needed approved network access to pub.dev, and `dart analyze` needed approved analyzer
  state initialization under `~/.dartServer`. Next leaf `DART-BACKEND-PARITY.1.3` adds manifest/corpus
  IO scaffolding without parser semantics.

- 2026-07-09 (DART-BACKEND-PARITY.1.1 — Dart toolchain/layout preflight):
  `/opt/homebrew/bin/dart` is available and reports Dart SDK `3.9.2 (stable)` on `macos_arm64`.
  Flutter is not installed, which is non-blocking because the backend starts as a Dart CLI/library package.
  The SDK tried to initialize analytics under `~/.dart-tool`; running `dart --disable-analytics` once with
  approved out-of-sandbox access resolved the sandbox-only write failure. The planned package root is
  `dart/`, package name `linkedspec_dart`, with `bin/linkedspec_dart.dart` and `bin/corpus_runner.dart`
  entrypoints and source split across AST, parser, compiler, runtime, corpus, and trace owners. Next leaf:
  `DART-BACKEND-PARITY.1.2` creates the minimal package scaffold and smoke test.

- 2026-07-09 (FUTURE-PARITY-BACKLOG.1.1 — Dart parity plan scoped):
  Created `docs/tasks/DART-BACKEND-PARITY.md` as the dedicated Dart backend task tree. The Dart lane
  starts interpreter-first: `.spec` parser, typed helper/action AST, compiled-spec state, Dart runtime
  interpreter, and manifest-backed corpus runner. Generated Dart source is deliberately a later proof lane
  after interpreter/corpus parity, matching the current Rust boundary where interpreter parity is the full
  99-fixture gate and generated source is a structural/curated-subset proof. The first Dart leaf is
  `DART-BACKEND-PARITY.1.1`, which verifies local Dart SDK/tool commands and package layout before code.

- 2026-07-09 (FUTURE-PARITY-BACKLOG.0 — future parity backlog created; Lua accepted):
  Created `docs/tasks/FUTURE-PARITY-BACKLOG.md` as the active owner for deferred/future parity work after
  the language-reference closeout. The seven backlog lanes are now durable task-tree rows: future backend
  parity, staged parsing generalization, Rust generated-source breadth, user-function extensions, helper
  caveats, Perl legacy plugin machinery fate, and richer Rust oracle candidates. ADR `0021` supersedes the
  old Lua-decision gap: Lua is accepted as a future backend target and the scheduled rollout is Dart first,
  Julia second, Lua third. All three future backends must reach full parity with Perl5 and Rust under the
  same universal `.spec`, text-to-AST, staged parsing, runtime, diagnostics, and corpus contracts. This slice
  is tracking/decision/docs only; `FUTURE-PARITY-BACKLOG.1.1` has since scoped Dart into
  `DART-BACKEND-PARITY`, whose first executable frontier verifies the Dart SDK/tool commands and package
  layout before implementation code.

- 2026-07-08 (SPEC-LANG-REFERENCE.8 — top-rule doctrine drift correction):
  The current doctrine is the June 23 ADR `0010` model, not the older June 17 no-regex correction.
  `::` marks the rule entered first; once selected, a `::` rule has the same regex slots, rule modes,
  action/blind-call edges, lifecycle blocks, and recursion model as a `:` rule. A `.spec` still needs
  an entry marker for the default start rule, but regex-bearing `::` bodies are valid. The no-regex
  top wrapper remains a good stream-of-records teaching idiom, not a validity minimum. Focused
  `LinkedSpec::Get` probes compared `Entry::` and selected `Body:` forms in default and `AND` modes
  and got matching outputs; the stale no-regex card is now a superseded redirect.

- 2026-07-08 (SPEC-LANG-REFERENCE.7 — spec-language Knowledge Map cards):
  The audit-required durable `.spec` language subjects now have canonical Knowledge Map retrieval cards:
  `spec-output-return-shape-contract`, `spec-regex-feature-contract`, `spec-rule-mode-semantics-map`,
  `spec-lifecycle-retv-order`, and `spec-capture-mark-family-taxonomy`. The existing
  `spec-edge-syntax-contract` card now also routes action-vs-blind dispatch questions. Backend/parity
  cards such as `rust-perl-output-oracle`, `rust-anonymous-capture-slice-family`, and
  `rust-mark-based-capture-family` remain related evidence, but they are no longer the first stop for
  language-reference retrieval.

- 2026-07-08 (SPEC-LANG-REFERENCE.6 — capture/mark marker cross-example):
  `source-boundary-helper-reference.md` and `action-and-lifecycle-placement.md` now share a verified
  marker-form example that exercises `@capture_slice`, `@mark(body_start)`, `mark_match_start(close_start)`,
  `capture_slice()`, `capture_from(...)`, and `capture_between(...)` in one rule. The verification pass
  found the useful authoring rule: marker effects are visible from a later action, while same-block precision
  belongs to helper calls such as `start_capture_slice()` and `mark_here(...)`. The action-placement page now
  uses `mark_here(...)` for opener actions that need exact block-local timing. KM fact
  `split-boundary-marker-action-timing` records the generated-source/root-cause evidence.

- 2026-07-08 (SPEC-LANG-REFERENCE.5.5 — remaining helper-family worked examples):
  `helper-contract-catalog.md` now has verified examples for Declaration, Capture/Mark, Entry/Match,
  Input, and Call helper families, closing the `.5` helper-catalog sweep. The verification pass caught
  stale entry-vs-match snippets that used a parent action with `return(call(Inner/Child))` while claiming
  a child local-match output. The stable teaching shape is a no-regex top dispatcher (`Top:: -> Name .push`)
  into an ordered child (`Name:AND`): the first slot is the entry match (`entry_*` reads `name`), and a later
  slot action is the local match (`match_*` reads `Alpha`). The helper catalog and source-boundary chapters
  now use that shape; KM fact `entry-match-divergence-verified-shape` records the reverify command.

- 2026-07-08 (SPEC-LANG-REFERENCE.5.4 — Hash and Control Flow helper worked examples):
  `helper-contract-catalog.md` now has verified Hash examples for constructor/copy/splice forms,
  pure and mutating update forms, sorted views, receiver chains, block receivers, and hash-tree
  traversal, plus Control Flow examples for inline/marker/attached branch forms, `switch`, `while`,
  `next`, `return`, and `return_undef`. `exit_now(2)` is documented through descriptor metadata
  (`EXIT`, no raw/fallback/unresolved) because running it deliberately terminates the parser process.
  The verification pass caught a stale Hash edge-case claim: direct `hash("a", 1, "missing")` does
  not fill the trailing key with `undef` on current Perl; it lowers to an unsupported-helper sentinel
  and returns `undef`. The stable spellings are explicit `hash("a", 1, "missing", undef)` or a
  deliberate list-context splice. KM fact `hash-helper-odd-arity-current-behavior` records the
  reverify command; optional behavior normalization is deferred to `.5.4.1`.

- 2026-07-08 (SPEC-LANG-REFERENCE.5.3 — Array helper worked examples):
  `helper-contract-catalog.md` now has verified Array-family examples for pure value helpers,
  statement/mutation pipelines, receiver chains, and array-tree traversal. The verification pass found
  three caveats worth preserving: compact `I.return(split(...))` takes an old tagged shorthand path,
  while `I { return(split(...)) }` and receiver `.split(...)` return the plain array; direct
  `return(split_each(array(items), ...))` returns a count-shaped value in the standard demo wrapper,
  while receiver/assignment/mutation-plus-copy forms return arrays; and current Perl receiver chains
  support verified pure chains and pipeline-to-terminal chains, not every pipeline-to-pure combination
  (`items.uniq().sorted()` is not documented as portable). KM fact
  `array-helper-return-shape-caveats` records the reverify command.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.20 — lifecycle drift policy):
  The lifecycle final-value/direct-`E` drift from `.10.5.9` is now explicitly a documented
  current Perl-reference caveat, not a hidden authorization to change the engine. Focused probes
  still show the direct default-rule `I`+regex+`E` shape returning `"not_a_return"` and generated
  source omitting the `E` hash-return path; a dispatched child with no explicit return surfaces
  `["not_a_return"]`. ADR `0020` owns the policy boundary. Public examples and
  `appendix/runtime-semantics.md` now teach explicit `return(...)` as the portable action/lifecycle
  return channel. The `.10.5` scorch is complete; the next language-reference leaf is `.5.3`
  for Array helper worked examples.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.19 — whole-book scorch closeout):
  The final mdBook re-grep found three residual regex-on-`::` examples after the per-file leaves:
  `spec-files-and-rule-paragraphs.md`'s recursive `sexpr::` example, two helper-catalog terse examples
  (`Top:: /x/` plus `Done:: /[a-z]+/`), and `compiler/pipeline-overview.md`'s function-registry proof
  snippet. They now use no-regex `Top::` wrappers with normal regex-owning rules. The helper examples
  also restore semicolon-separated terse statements per the existing `terse-statement-separator-contract`
  Knowledge card; the direct value-path example's verified result is `"updated"`, not `["two"]`.
  Whole-book regex-on-`::` scans now return no matches. The next scorch leaf is `.10.5.20` for the
  lifecycle handler-shape drift already recorded during `.10.5.9`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.18 — portmap walkthrough outputs):
  `specs-and-corpora/portmap-spec-walkthrough.md` already matched the live Perl reference output
  when this leaf was executed. `LinkedSpec::get_parser('portmap')` returns nested tagged arrays for
  the five documented cases: `clk` -> `["?bare:",["clk"]]`, `bar[3]` ->
  `["?bit:",["bar","3"]]`, `addr[7:0]` -> `["?slice:",["addr","7","0"]]`, `0x1f` ->
  `["?constant:",["0x1f"]]`, and `{sig_a sig_b[7:0] 0x1f}` -> `?concat` with bare/slice/constant
  children. The next scorch leaf is `.10.5.19` for the planned whole-book closeout sweep.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.17 — tablegrep walkthrough outputs):
  `specs-and-corpora/tablegrep-spec-walkthrough.md` now shows parser-output JSON from
  `LinkedSpec::get_parser('tablegrep')`. The `re_term` rule captures `([!=])`, so `field1 =~ /foo/`
  returns `"sens":"="`, not `"=~"`; the grouped example returns a `GROUP` hash whose `group`
  array contains the nested term/operator nodes. The descriptor-readiness helper list was also
  refreshed from the live spec (`return_undef`, `copy`, `is_empty`, `not`, `and`, `matches`,
  `print`, `exit_now`, `push`, `hash`, `substr`, `entry_group`, `I.return(...)`). The next scorch
  leaf is `.10.5.18` for `portmap-spec-walkthrough.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.16 — runtime semantics examples):
  `appendix/runtime-semantics.md` §5.5 now teaches top-level output through no-regex `Top::`
  wrappers that explicitly call regex-owning body rules. The scalar/proof examples use `Done:`;
  the folded `.10.4` Pair example uses `Pair:` with `entry_group(0/1)` and returns that value
  through `Top`. §5.6 wraps the `object:` and `manifest:` tagged-array examples with complete
  `Top::` dispatchers so the documented outputs are parser outputs, not isolated fragments.
  The next scorch leaf is `.10.5.17` for `tablegrep-spec-walkthrough.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.15 — formal grammar examples):
  `appendix/formal-grammar.md` now keeps the formal examples aligned with the book's current
  authoring doctrine. The §1 paragraph-model example uses a no-regex `Top::` entry rule with
  `LX` return and a normal `Next:` matcher. The §12 complete example uses `DemoParser::` as the
  only top entry, moves `Child` to a normal matcher rule, gives `SecondChild:OR+` a verified local
  regex/action shape, and defines `First:` / `Second:` for the `ThirdChild:AND` dispatch edges.
  The next scorch leaf is `.10.5.16` for `appendix/runtime-semantics.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.14 — remaining DSL examples):
  `dsl/values-containers-and-flow-helpers.md` and `dsl/action-model-and-helper-surface.md` now use
  no-regex `Top::` wrappers plus normal regex-owning `Token:` / `Value:` rules for their compact
  examples. `dsl/fluent-and-block-forms.md` now treats the introductory structured-style example as
  a lifecycle-block fragment instead of a standalone `Toplevel:AND+` rule, and its all-forms worked
  example is a verified `Items::` entry rule that dispatches to `Item:` and returns singleton/pair/list
  shapes from `LX`. `dsl/actionir-lowering-mental-model.md` was audited and left unchanged because its
  relevant code fences are helper-statement or lowering-pipeline fragments, not runnable regex-owning
  spec examples. The next scorch leaf is `.10.5.15` for `appendix/formal-grammar.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.13 — value-container flow examples):
  `dsl/value-container-flow-helper-reference.md` no longer uses regex-bearing `Token::AND`,
  `FieldList::AND`, `Node::AND`, `Sequence::AND`, or `Kind::AND` worked examples. Token,
  FieldList, and Kind now use a no-regex `Top::` wrapper plus normal regex-owning matcher rules.
  Node and Sequence remain entry-rule examples, but dispatch to explicit `Child:` / `Item:`
  matchers for the regex-bearing work. The Sequence example keeps the multiline control-flow
  form that the ActionIR parser accepts; compacting the `if`/`return` shape into a single line
  produced a Perl syntax error during probing. The next scorch leaf is `.10.5.14` for the
  remaining DSL pages.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.12 — source-boundary examples):
  `dsl/source-boundary-helper-reference.md` no longer uses regex-bearing `Tuple::AND`, `Block::AND`,
  `Paren::AND`, `Pair::AND`, `Body::AND`, `AtEnd::AND`, or `Top::AND`/`Child::AND` examples. The page
  now wraps each example with a no-regex `Top::AND => Rule` blind-call wrapper and puts regex slots on
  normal `Rule:AND` / `Call:` / `Child:` rules. Delimiter-body examples are explicitly seek-shaped.
  The old three-segment Tuple/Body sketches were reduced to verified two-segment forms; the same helper
  mechanics remain covered without relying on unverified `null`-shaped output. The next scorch leaf is
  `.10.5.13` for `dsl/value-container-flow-helper-reference.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.11 — declaration helper examples):
  `dsl/declaration-helper-reference.md` now keeps declaration-helper replacement examples on the
  standard no-regex wrapper shape. The accumulator example uses `List::` only for state ownership
  (`set(array(items), [])`, scratch `retv`, final `LX` return) and puts matching in `Item:`;
  `Item: /\s*[A-Za-z_]+/` trims `entry_text()` so consume-mode streams can cross whitespace.
  The metadata example uses `Top::` as the wrapper and `Token:` as the regex owner. The next scorch
  leaf is `.10.5.12` for `dsl/source-boundary-helper-reference.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.10 — capture/source-location examples):
  `dsl/capture-marks-and-source-locations.md` no longer teaches `Top::AND` / `Call::AND` regex-bearing
  examples. The `capture_slice()` example is now a no-regex `Top::` wrapper dispatching to a normal
  `Body:` delimiter rule and is verified in seek mode (`BEGIN body END` -> `[{"body":"body"}]`).
  Consume mode returns `[null]` for the same minimal opener/body/closer shape because the child close
  regex is checked at the cursor after the opener and cannot skip body text; Knowledge fact
  `perl-capture-slice-delimiter-seek-boundary` records that authoring boundary. The entry-vs-match
  example now uses a no-regex blind-call wrapper with normal `Call:`/`Inner:` rules and verifies
  `entry_*` reading `greet` while `match_*` reads `world`. The next scorch leaf is `.10.5.11` for
  `dsl/declaration-helper-reference.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.9 — action/lifecycle placement examples):
  `dsl/action-and-lifecycle-placement.md` now separates entry-match handling from later local-slot actions.
  A dispatched normal rule reads the match that caused entry with `entry_text()` / `entry_group(...)` in
  `I { ... }`; indexed action edges such as `-> Name[2]` operate on local slots and should read
  `match_text()` / `match_group(...)`. The leaf also corrected examples that mixed scalar shape assignment
  (`meta = { ... }`) with aggregate hash reads (`hash(meta)`): examples that mutate `hash(meta)` now seed it
  with `set(hash(meta), { ... })`.
  While verifying the lifecycle section, TOOLBOX probes showed current Perl generated handlers can leak a
  lifecycle block's final host statement value when no explicit `return(...)` is present, and a direct
  `Top:: I ... /x/ E { ... }` shape can omit the regex/E path in generated source. The page now warns authors
  to use explicit lifecycle `return(...)`; Knowledge fact `perl-lifecycle-final-value-e-drift` records the drift.
  The next scorch leaf is `.10.5.10` for `dsl/capture-marks-and-source-locations.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.8 — blind-call orchestration examples):
  `user-model/blind-calls-and-parser-orchestration.md` was mostly clean because its `::` blind-call
  wrappers carry no regex slots. The remaining regex-on-`::` drift was in action-edge examples:
  `Parent`, `BadRule`, `HeaderRule`, and `Field` now use single-colon `:AND`. The mixed-edge negative
  example explicitly says the single-colon label is deliberate; validation reports the expected
  `Cannot mix ACTION (->) and BLIND CALL (=>) code blocks`. The next scorch leaf is `.10.5.9` for
  `dsl/action-and-lifecycle-placement.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.7 — regex chapter examples):
  `user-model/regex-in-spec.md` no longer uses regex-on-`::` examples. Complete snippets use a
  no-regex `Top::` wrapper, and regex-bearing examples are normal `:` child rules. The capture
  teaching now uses `entry_group` / `entry_named` for the dispatched-child shape while preserving the
  zero-based, captures-only, compacted numbered-group contract and the named-group stability guidance.
  The next scorch leaf is `.10.5.8` for `user-model/blind-calls-and-parser-orchestration.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.6 — rule modes and parse modes):
  `user-model/rule-modes-and-parse-modes.md` now follows the book scorch doctrine without erasing the
  top-rule runtime nuance: runnable regex-owning mode examples use normal `:` labels, while `::` remains
  a no-regex entry/dispatcher spelling. The page no longer teaches "both valid shapes" as a runnable
  regex-on-`::` pattern, and the parse-mode examples use a verified `Top::` + `Word:` wrapper. Runtime
  probes confirmed token-stream output plus `seek`/`consume` behavior. The next scorch leaf is `.10.5.7`
  for `user-model/regex-in-spec.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.5 — spec file paragraph examples):
  `user-model/spec-files-and-rule-paragraphs.md` is now back on the verified 2-rule authoring idiom.
  The page no longer teaches runnable `Top::AND` stream examples or uses `match_text()` in dispatched
  matcher rules. The minimal, block-boundary, compact, and multiline examples all use `Top::` as a
  no-regex dispatcher/accumulator and normal matcher rules with regexes plus `entry_text()`. The old
  bare `label:` example was not a valid helper block; the compiler reports `Rule definition not
  allowed inside open block`. The page now uses a valid quoted `"label:"` helper value and the exact
  failure mode is durable in Knowledge fact `rule-starts-open-block-validation`. The next scorch leaf
  is `.10.5.6` for `user-model/rule-modes-and-parse-modes.md`.

- 2026-07-08 (SPEC-LANG-REFERENCE.10.5.4.1 — reactivate language-reference scorch):
  The user explicitly reactivated `SPEC-LANG-REFERENCE` after the 2026-06-18 pause for
  `SPEC-FORMAT-TERSE`. This slice is metadata-only: it resolves the pause in the task tree and central index,
  updates live docs, and makes `.10.5.5` the next active leaf. The next actual book-content work remains
  `user-model/spec-files-and-rule-paragraphs.md`: fix the malformed label-in-block example and the `Top::AND`
  regex-on-top sketches, then re-verify and build the book.

- 2026-07-08 (TASK-TREE-METADATA-HYGIENE.4 — closeout commit metadata):
  Startup review after `SPEC-SOURCE-TERSE-CLOSEOUT.1` confirmed HEAD was already
  `SPEC-SOURCE-TERSE-CLOSEOUT.1 - close root spec terse source`, but the closeout task file still said commit
  execution was pending. This is not broad historical backfill; it is a newly-created handoff contradiction in the
  just-closed task. The fix records the landed commit in `docs/tasks/SPEC-SOURCE-TERSE-CLOSEOUT.md` and updates the
  hygiene ledger/live docs so future sessions do not waste time re-deriving whether the closeout was committed.

- 2026-07-08 (SPEC-SOURCE-TERSE-CLOSEOUT.1 — root spec terse source closeout):
  The root shipped specs are now source-format closed against the current accepted terse surface, not merely
  descriptor-clean. Strict scans across `specs/*.spec` found no retired helper spellings or raw host-action
  residues after migrating the remaining spots in `hlink_substitution`, `pplugin`, `Lispish`, `ebnf`, `simenv`,
  and `vhdl`. The important behavior changes are deliberate: `hlink_substitution` bracket payloads now return
  neutral strings, which promotes `hlink_bracket_body` and `hlink_mixed_bracket_brace` into the Rust oracle; and
  `pplugin.spec` now returns plugin body text, with legacy coderef execution preserved by `perl/PPlugin.pm`.
  The checked-in Rust oracle is now 99 fixtures. Some valid current spellings remain non-maximal by style, but
  they are not compatibility debt.

- 2026-07-08 (RUST-STATUS-DRIFT-SYNC.1 — Rust status count drift):
  Startup review after `SPEC-FORMAT-TERSE.13.5` found current-facing status drift outside the already-correct
  main status pages: `ROADMAP.md` still advertised the Phase 9 oracle as 96 fixtures, `rust/README.md` still said
  the full corpus was 96 fixtures and the Rust parser covered 20 shipped specs, and the mdBook shipped-corpora
  page still named the core phase0 gate as `1..1027`. The Knowledge Map fact card and checked-in manifest agree on
  the current state: `case_count` 97, including `terse_13_3_array_tree_traversal_receiver_blocks`, and `specs/`
  contains 21 shipped `.spec` files. This slice corrected only current-facing status text; older log/task entries
  that describe earlier 20-spec, 96-fixture, or `1..1027` baselines remain historical records.

- 2026-07-08 (DOCTRINE-ENFORCEMENT-ADOPT.3.3 — task-acceptance no-drift closeout):
  The doctrine-enforcement adoption tree is closed. The shipped `TASK-ACCEPTANCE` boundary is now consistent
  across `DOCTRINE_ENFORCEMENT.md`, `TOOLBOX.md`, the mdBook local-CI chapter, ADR `0009`, the Knowledge fact card,
  task-tree index, and live docs. The gate's operational escape path is deliberately mundane: inspect
  `git diff --cached --name-only`, then unstage unrelated governed files, stage/update the real owning task
  checklist, or split the work. Its known limit is explicit: it proves staged evidence shape and ownership only;
  focused validation and `tools/run_ci_local.sh` remain the truth test.

- 2026-07-08 (DOCTRINE-ENFORCEMENT-ADOPT.3.2 — task-acceptance evidence gate):
  `scripts/check_diagnosis_evidence.sh` is now the `TASK-ACCEPTANCE` doctrine. It uses `git diff --cached` and
  governs staged `.github/workflows/`, `.githooks/`, `bin/`, `perl/`, `rust/`, `specs/`, `t/`, `tools/`, and
  `scripts/` paths. When it fires, it requires a staged `docs/tasks/*.md` file with the six `TOOLBOX.md`
  checklist labels checked and with conservative tool, WHY/WHERE, and verification signatures. This is a
  shape/presence gate; it intentionally does not run arbitrary commands copied into task Markdown. The driver
  meta-check now makes the script executable/tracked presence part of doctrine enforcement, and
  `tools/run_ci_local.sh` also audits the script as a tracked file.

- 2026-07-08 (DOCTRINE-ENFORCEMENT-ADOPT.3.1 — evidence gate split before code):
  The deferred evidence/task-acceptance doctrine is now split before implementation. The key design boundary is
  false-positive control: the first checker should inspect the staged set, govern only code/spec/test/tooling-style
  changes, require a staged owning task-file checklist, and look for conservative LinkedSpec-tool/output
  signatures from `TOOLBOX.md`. It should not become a broad historical task-tree audit, and it should not execute
  arbitrary commands pasted into Markdown from a pre-commit hook. Re-execution remains the role of the broader
  local CI gate and focused validation commands recorded in the task leaf.

- 2026-07-08 (SPEC-FORMAT-TERSE.13.5 — parent tree status closeout):
  `SPEC-FORMAT-TERSE` is now a closed parent task-tree, not an active tree with an empty frontier. The correction
  is metadata-only: central index, task-file top metadata, current-frontier rows, live docs, roadmap state, and
  Knowledge Map facts now agree there is no current PNT-eligible terse-format leaf. No parser/runtime, corpus, or
  behavioral mdBook semantics changed.

- 2026-07-08 (SPEC-FORMAT-TERSE.13.4 — array-tree traversal closeout):
  `.13` is closed/exhausted after `.13.2` landed the Perl reference implementation and `.13.3` landed Rust
  parser/runtime parity plus the 97th oracle fixture. The shipped surface is receiver-only and immediate:
  `walk_leaves() { ... }`, `map_leaves() { ... }`, and `reduce_leaves(initial) { ... }` on array-valued receivers.
  Array traversal recurses only through nested arrays, treats hashes as leaves, scopes `value`, `index`, `path`,
  `depth`, and reduce-only `acc`, and returns `undef` without callbacks for scalar receivers. No runtime or corpus
  semantics changed in this closeout slice.

- 2026-07-08 (SPEC-FORMAT-TERSE.13.3 — Rust array-tree traversal):
  Rust now uses one receiver trailing-block traversal dispatch for hash and array values. The hash path preserves
  the `.12` sorted-key traversal contract; the new array path recurses only through nested arrays, treats hashes as
  leaves, and scopes callback variables as scalar `RuntimeValue`s (`value`, `index`, `path`, `depth`, and
  reduce-only `acc`). Because Rust scalar-held arrays feed existing array receiver/helper paths, callback examples
  should use receiver links such as `mapped.first()` or `array(path)` rather than assuming aggregate-array storage
  for duck-typed assignment results. The Perl-backed oracle corpus now has 97 fixtures after
  `terse_13_3_array_tree_traversal_receiver_blocks`.

- 2026-07-08 (SPEC-FORMAT-TERSE.13.2 — Perl array-tree traversal):
  `MethodLowering.pm` now uses one tree-traversal receiver path for `walk_leaves`, `map_leaves`, and
  `reduce_leaves(initial)`, with runtime dispatch for hash vs array receiver values. Hash receivers preserve the
  `.12` sorted-key traversal contract. Array receivers traverse nested arrays by zero-based index and treat hashes
  as leaves; callback blocks get scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`. Array
  `walk_leaves` / `map_leaves` can feed compatible array receiver methods such as `.count()`. Rust parser/runtime
  parity and the generated oracle fixture were owned by `.13.3` and are now complete; `.13.4` closed the public
  docs/Knowledge Map/no-drift state.

- 2026-07-08 (SPEC-FORMAT-TERSE.13.1 — array-tree traversal split):
  `.13` is active and split before parser/runtime code. The accepted MVP reuses the `.12` immediate receiver
  block method names on array-valued receivers: `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)`.
  Array roots and nested arrays are traversal nodes; scalar and hash values are leaves, so hashes are not
  recursively traversed inside array trees. Traversal order is depth-first by zero-based array index. Callback
  blocks get scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`. The implementation sequence was
  `.13.2` for Perl reference support, `.13.3` for Rust/oracle parity, and `.13.4` for closeout.

- 2026-07-08 (SPEC-FORMAT-TERSE.10.1 — dynamic hash-literal keys ratified):
  `.10` is closed without parser/runtime changes. The existing direct hash-literal contract is expression-keyed:
  `{ key_expr : value_expr }` evaluates the key expression and stringifies it for the runtime hash key. Bare keys
  such as `{ key : value }` read scalar `key`; fixed fields must be quoted (`{ "kind" : value }`); computed helper
  keys such as `{ cat(prefix,suffix) : value }` are accepted. This records the behavior already present after the
  `.9` colon-hash migration and `.15` bare-read policy, and prevents future sessions from treating dynamic keys as
  an accidental parser broadening.

- 2026-07-08 (MEMORY-PUSH-POINTER-SYNC.1 — push threshold state is live, not durable):
  `MEMORY.md` should not fossilize a branch ahead-count as if it were a durable fact. A final clean-status check
  showed `git status -sb` at ahead 27 while the resume pointer still said the branch was over the documented
  300-commit push threshold. The durable guidance now says to check `git status -sb` for the live ahead count and
  not push mid-PNT unless explicitly instructed or deliberately invoking the threshold policy. The post-commit
  `latest_commit` hash warning remains the known soft hook boundary; this slice did not rework that mechanism.

- 2026-07-08 (ROADMAP-POST-12-DRIFT-SYNC.1 — long roadmap count drift):
  Startup review after `SPEC-FORMAT-TERSE.12.4` found only the long-form `ROADMAP.md` still carrying the previous
  current-state counts (`1..1026` and 95 Rust oracle fixtures). The mdBook status/helper/backend chapters already
  reflected `1..1027`, 96 fixtures, and the hash-tree traversal receiver-block surface, so this slice corrected the
  long roadmap and recorded a narrow completed owner instead of reopening the broader `ROADMAP-DRIFT-RECONCILE`
  tree. Treat this as count/status sync only; no parser/runtime, corpus, or book behavior changed.

- 2026-07-08 (SPEC-FORMAT-TERSE.12.4 — hash-tree traversal no-drift closeout):
  The `.12` hash-tree traversal lane is closed after `.12.1` split the contract, `.12.2` landed the Perl
  reference, `.12.3` landed Rust/oracle parity, and `.12.4` verified docs/KM/live-doc/oracle/task-tree alignment.
  No parser/runtime behavior changed in `.12.4`. The shipped surface remains receiver-only
  `walk_leaves() { ... }`, `map_leaves() { ... }`, and `reduce_leaves(initial) { ... }` with immediate callbacks;
  `SPEC-FORMAT-TERSE.10` dynamic/computed hash-literal keys and `.13` array-tree traversal stayed deferred/backlog
  at that closeout point; `.10` was later closed by `.10.1`, and `.13` is the remaining terse-format frontier
  under the 2026-07-08 exhaustion directive.

- 2026-07-08 (SPEC-FORMAT-TERSE.12.3 — Rust hash-tree traversal receiver blocks):
  Rust now shares the Perl `.12` surface for `hash_value.walk_leaves() { ... }`,
  `hash_value.map_leaves() { ... }`, and `hash_value.reduce_leaves(initial) { ... }`. The parser appends trailing
  `BlockValue` arguments for those receiver methods, with `reduce_leaves` retaining its explicit initial
  accumulator argument. Runtime execution reuses the receiver trailing-block chain path instead of adding plain
  helpers, so missing blocks diagnose explicitly and successful `walk_leaves` / `map_leaves` results continue into
  existing hash-family methods such as `count_keys`. Callback variables are scoped scalar `RuntimeValue`s; unlike
  Perl, Rust does not need aggregate mirror lexicals because `array(path)` / `array(value)` can read scalar-held
  array values directly. The generated Rust oracle corpus is now 96 fixtures after
  `terse_12_3_hash_tree_traversal_receiver_blocks`; public helper docs and Knowledge Map facts were updated in
  this slice, leaving `.12.4` as the final no-drift closeout leaf.

- 2026-07-08 (SPEC-FORMAT-TERSE.12.2 — Perl hash-tree traversal receiver blocks):
  The Perl reference now lowers `hash_value.walk_leaves() { ... }`,
  `hash_value.map_leaves() { ... }`, and `hash_value.reduce_leaves(initial) { ... }` as immediate receiver
  trailing-block calls. The traversal helpers walk hash-root/hash-interior value trees in sorted depth-first key
  order, treat arrays as leaves, return `undef` without callbacks for non-hash receivers, and preserve the `.12`
  callback contract with scoped `value`, `key`, `path`, `depth`, and reduction-only `acc`. Because Perl's existing
  block lowering can resolve `array(value)` / `hash(value)` through aggregate lexicals, the generated callback
  frame mirrors array/hash views for `value` and `acc` while keeping the portable contract scalar-valued. Rust
  parity and generated oracle fixtures remain `.12.3`; full mdBook helper examples remain `.12.4`.

- 2026-07-08 (SPEC-FORMAT-TERSE.12.1 — hash-tree traversal split before code):
  `SPEC-FORMAT-TERSE.12` is now active by explicit user directive. The accepted MVP is deliberately receiver-only
  and immediate: `hash_value.walk_leaves() { ... }`, `hash_value.map_leaves() { ... }`, and
  `hash_value.reduce_leaves(initial) { ... }`. Traversal is sorted depth-first over hash keys; arrays are leaves,
  not nested traversal nodes; callbacks get scoped `value`, `key`, `path`, and `depth`, with `acc` only for
  reduction. The implementation starts with Perl reference `.12.2`, then Rust/oracle parity `.12.3`, then
  docs/KM/no-drift `.12.4`.

- 2026-07-08 (STAGED-LINKED-PARSING.6 — close exhausted staged tree):
  `STAGED-LINKED-PARSING` is now closed rather than left active with an empty frontier. The earlier
  function-body staged prototype remains the implemented proof point; this slice only reconciles the task tree and
  index, and removes the stale PNT pointer to `TOP-RULE-AS-NORMAL.3.2`, which is already closed.

- 2026-07-08 (ROADMAP-DRIFT-RECONCILE.2 — architecture/book status-count refresh):
  `ARCHITECTURE_STATE.md` now names the current status snapshot: 21 shipped specs, phase0 `PASS 1..1026`, a
  95-fixture Rust interpreter oracle, generated Rust-source proof over current structural families plus a curated
  subset, and root `plugin/` removed with 13 surviving `.plg` files parked under `noncore/plugin/`. The public
  book's current-state status/count lines were swept at the same time; historical June 2026 audit counts stay in
  place only where they are explicitly framed as historical. `ROADMAP-DRIFT-RECONCILE` is complete.

- 2026-07-08 (ROADMAP-DRIFT-RECONCILE.1 — long-form roadmap drift):
  `ROADMAP.md` now reflects the current core status instead of the June drift snapshot: `SPEC-FORMAT-TERSE` /
  ADR `0007` is the current `.spec` evolution track, `declare(...)` is historical/retired authoring rather than
  the permanent required form, phase0 is `PASS 1..1026`, the Rust interpreter oracle is 95 fixtures, root
  `plugin/` is gone, 13 legacy `.plg` files live under `noncore/plugin/`, and `perl/` is core-only except for
  the `PPlugin.pm` compatibility adapter. The next owned reconciliation is
  `ROADMAP-DRIFT-RECONCILE.2` for `ARCHITECTURE_STATE.md`.

- 2026-07-08 (RUST-README-DRIFT-SYNC.1 — Rust README count sync):
  `rust/README.md` now names the full Rust interpreter oracle gate as 95 fixtures, matching the checked-in manifest
  and current mdBook status/handoff/corpora pages. This was a docs-only correction; no corpus regeneration or
  runtime behavior changed. The drift tree is complete.

- 2026-07-08 (RUST-README-DRIFT-SYNC.0 — Rust README count drift owner):
  Startup review found a narrow docs drift outside the mdBook: `rust/README.md` still says the full interpreter
  oracle is 93 fixtures, but the manifest and current public book/live/KM state are at 95 fixtures. The new
  `RUST-README-DRIFT-SYNC` tree owns that isolated correction so the README edit is not made opportunistically
  during bootstrap. No parser/runtime behavior changes in `.0`; `.1` is the README update.

- 2026-07-08 (TASK-TREE-METADATA-HYGIENE.3 — completed-tree frontier gate):
  Added `scripts/check_task_tree_metadata.sh` as the `TASK-TREE-METADATA` doctrine. The check is intentionally
  narrow: for task files whose top metadata status is `done`, `completed`, or `exhausted`, it parses only the
  `Current Frontier` table status cell and fails on live statuses (`pending`, `active`, `in_progress`, `blocked`).
  It does not scan changelog prose or force old per-leaf `Commit: pending` fields to be backfilled. Exploratory
  scans showed that broad leaf-level commit/verification enforcement would trip substantial legacy metadata debt
  unrelated to the current frontier invariant, so future broadening needs its own cleanup owner.

- 2026-07-08 (TASK-TREE-METADATA-HYGIENE.2 — stale frontier rows and hook behavior):
  Reconciled stale current-frontier, verification, and commit rows in completed/completed-like task trees. The
  stable rule observed so far: completed task files should not retain `pending` frontier/verification/commit rows,
  but explicitly deferred leaves remain visible as `deferred` when they are true non-goals or future strategy
  decisions. `COMPAT-ALIAS-RETIREMENT` is the completed-with-deferred-medium-term-leaves case;
  `NONCORE-QUARANTINE.N` is an explicit non-goal deferral and was left intact. While checking
  `LINKEDSPEC-LOW-EFFORT.2`, verified that `.githooks/post-commit` is verification-only: it warns when
  `MEMORY.md` lacks a parseable `latest_commit` hash or drifts from HEAD, but it does not rewrite `MEMORY.md`.
  Any future `.3` doctrine/check must account for intentional deferred rows and the current soft-warning hook
  boundary.

- 2026-07-07 (TASK-TREE-METADATA-HYGIENE.1 — top metadata reconciliation):
  Reconciled stale active top metadata in `docs/tasks/FLUENT-BLOCK-EQUIVALENCE.md`,
  `docs/tasks/MEDIUM-IMPACT.md`, and `docs/tasks/PHASE0-BACKHALF-TRIAGE.md`. This was metadata-only: no
  parser/runtime or public-book behavior changed. The key rule applied here is that a task file whose own body says
  the tree is done/exhausted must not keep advertising `Status: active` unless it also names a live frontier or an
  explicit deferral. The hygiene frontier moves to `.2` for noisier stale frontier/verification rows.

- 2026-07-07 (SPEC-FORMAT-TERSE.14.5 — trailing block no-drift closeout boundary):
  The shipped trailing block-argument surface is closed for `.14`: helper-function form `with(value) { ... }` / `with() { ... }`
  and receiver-method form `.with() { ... }` are documented as immediate non-closure callbacks on Perl/Rust, with a
  95-fixture Rust oracle after `terse_14_4_receiver_with_trailing_block`. The closeout fixed `ROADMAP_V2.md` drift
  that still named `.14.4` and 94 fixtures, refreshed the durable Knowledge fact, and tightened the mdBook project
  status sentence so it no longer says `.3.3.4` owns the current closure state. Broader `ROADMAP.md` and
  `ARCHITECTURE_STATE.md` count/status drift remains intentionally owned by deferred `ROADMAP-DRIFT-RECONCILE`
  leaves and was not activated during this `.14` closeout.

- 2026-07-07 (SPEC-FORMAT-TERSE.14.4 — receiver `.with() { ... }` normalizes through the `with` block model):
  Receiver-form trailing blocks are not a separate closure mechanism. Perl normalizes `receiver.with() { ... }`
  into the same scoped `with(receiver) { ... }` execution shape before continuing the compatible receiver chain,
  while Rust detects chains containing receiver `with` and dispatches later links by the block result's runtime
  family. The receiver form takes no parenthesized value arguments; `.with(value) { ... }` is intentionally rejected
  so the receiver remains the sole block input. The Rust oracle corpus is now 95 fixtures after
  `terse_14_4_receiver_with_trailing_block`.
  Side finding from fixture design: `has_key(...)` is an unrelated Perl/Rust output-shape edge. Perl currently
  lowers it to numeric `1`/`0`, while Rust returns `RuntimeValue::Bool`; do not use `has_key` as incidental proof in
  focused oracle fixtures unless that parity edge is being worked explicitly.

- 2026-07-07 (REPO-HYGIENE.3 — generated artifact cleanup boundary):
  Safe disk-space cleanup in the parent checkout is limited to ignored/untracked generated outputs unless a later
  task proves a broader boundary. This slice removed `rust/target` (5.2G) and `docs/linkedspec-book/book` (7.0M).
  Do not delete `.log` or `.bin` hits under `rgx/` from the parent repo cleanup path: they are inside a tracked
  submodule's stimulus, fixture, or issue-artifact corpus and are not 100% safe to remove here. Any future `rgx`
  artifact pruning needs its own submodule-owned task and status check.

- 2026-07-07 (SPEC-FORMAT-TERSE.14.3 — Rust `with(value) { ... }` helper-function form parity):
  Rust now mirrors the Perl helper-function form trailing block surface. The expression parser appends a final `BlockValue`
  only for `with(...) { ... }`, validation recognizes `with`, and runtime dispatch is lazy so the block is not
  evaluated before the scoped `value` binding exists. The lexical model is call-site execution, not a closure or
  function frame: captures, `retv`, cursor state, helper/function visibility, and ordinary working-variable side
  effects are shared with the surrounding action/runtime context. Only scalar `value` is the portable scoped block
  parameter in this MVP; mutations to other variable names persist. The Rust oracle corpus is now 94 fixtures after
  `terse_14_3_with_helper_trailing_block`.

- 2026-07-07 (SPEC-FORMAT-TERSE.14.2 — Perl `with(value) { ... }` is a flagged trailing block call):
  The ActionIR AST parser now represents helper-function form trailing blocks as normal `call` nodes with
  `trailing_block_arg => 1` and a final `block_value` argument. MethodLowering must treat that flag as a dispatch
  boundary: only `with` is accepted in this leaf; other trailing-block callees intentionally return
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<callee>` instead of becoming ordinary helper arguments. The accepted
  lowering evaluates the optional value argument before introducing `my $value`, then executes the existing
  expression-valued block lowerer inside the scoped lexical binding. This preserves outer `value` bindings and
  keeps `return(expr)` block-local. Rust parity landed under `.14.3`; receiver `.with() { ... }` is `.14.4`.

- 2026-07-07 (SPEC-FORMAT-TERSE.14.1 — trailing block args are immediate non-closure callbacks):
  `SPEC-FORMAT-TERSE.14` is the owner for trailing code blocks used as helper/receiver arguments. The first MVP is
  helper-function form `with(value) { ... }` / `with() { ... }`: evaluate the explicit value or `undef`, bind scoped scalar
  `value` during immediate block execution, restore the previous binding afterward, and return the block result.
  This does not introduce closures, assignable block values, returnable block values, or delayed invocation. Bare
  `with { ... }` stays deferred because word-plus-brace overlaps existing lifecycle/code-block body syntax.
  Implementation starts at `.14.2` on the Perl reference helper-function form path; Rust parity and receiver
  `.with() { ... }` are separate leaves.

- 2026-07-07 (TASK-TREE-METADATA-HYGIENE.0 — central index is authoritative for live task state):
  When auditing open task trees, use `docs/TASK_TREE.md` plus `MEMORY.md` as the live-state authority before trusting
  stale rows inside old task files. The 2026-07-07 audit found live central rows for `SPEC-FORMAT-TERSE`,
  `STAGED-LINKED-PARSING`, `DOCTRINE-ENFORCEMENT-ADOPT`, `SPEC-LANG-REFERENCE`, and
  `ROADMAP-DRIFT-RECONCILE`; at that moment their frontiers were empty, deferred, or paused. The user then
  reactivated `SPEC-FORMAT-TERSE.14`, so hygiene cleanup waits behind the `.14` lane. Older per-file metadata drift
  remains owned by `TASK-TREE-METADATA-HYGIENE.1`/`.2` instead of being edited during bootstrap.

- 2026-07-07 (PPLUGIN-WALKTHROUGH-DRIFT.1 — descriptor readiness is not .plg runtime portability):
  `LinkedSpec::get_parser("pplugin", return_descriptor => 1)` currently reports
  `language_agnostic_ready_ratio = 1.0000`, `language_agnostic_blocked_rule_count = 0`, and
  `compatibility_surface_rule_count = 0`. That only describes the `.spec` parser's ActionIR migration status.
  The parser can still return Perl coderefs for `.plg` bodies because `perl/PPlugin.pm` is a legacy Perl runtime
  adapter and `specs/pplugin.spec` returns a `sub { eval substr(...) }` callback for plugin execution. Do not use
  descriptor readiness to claim that `.plg` execution is backend-neutral.

- 2026-07-07 (PPLUGIN-WALKTHROUGH-DRIFT.0 — pplugin walkthrough drift needs a narrow owner):
  The pplugin walkthrough has to distinguish two facts that are easy to conflate: `pplugin.spec` is a current
  shipped `.spec` parser whose descriptor reports `language_agnostic_ready_ratio = 1.0000`,
  `language_agnostic_blocked_rule_count = 0`, and `compatibility_surface_rule_count = 0`, while `.plg` plugin
  execution remains legacy Perl runtime behavior that returns coderefs and is not a backend-neutral runtime target.
  Keep the actual book wording for `PPLUGIN-WALKTHROUGH-DRIFT.1`; this tracking-only slice only creates the owner.

- 2026-07-07 (PUBLIC-STATUS-DRIFT-SYNC.2 — public count fixes need whole-book scans):
  Public Rust oracle count drift can survive outside the main status/handoff pages. When reconciling corpus counts,
  scan the whole public book surface that mentions fixture counts, not only `overview/project-status.md` and
  `appendix/backend-handoff.md`. The exact Rust interpreter oracle count comes from
  `rust/linkedspec-runtime/tests/corpus/manifest.json` (then-current `case_count` 93 at that slice; use the
  manifest for today's count); book prose should point to that manifest for the complete case list instead of
  hand-maintaining a long exact enumeration. Stale roadmap and
  architecture-state count references remain owned by deferred `ROADMAP-DRIFT-RECONCILE` leaves.

- 2026-07-07 (BOOTSTRAP-RESUME-SYNC.1 — stale layer-A state must be task-owned before correction):
  If `MEMORY.md` names an already-committed leaf as in-flight while `git status --short` is clean, treat that as a
  continuity defect and open a narrow task-tree owner before editing the pointer. The correct source of truth is
  the combination of `git log -1 --oneline`, `git status --short`, the owning task tree, and `docs/TASK_TREE.md`;
  do not pivot to an unrelated tree while the resume pointer is known stale.

- 2026-07-07 (PUBLIC-STATUS-DRIFT-SYNC.1 — public status uses the Rust manifest, not stale parity wording):
  The current Rust interpreter oracle count comes from
  `rust/linkedspec-runtime/tests/corpus/manifest.json` (then-current `case_count` 93 at that slice). Public docs should describe interpreter
  parity as the current manifest-backed gate and generated Rust source as a structural-family plus curated-subset
  proof. Do not revive the older "Rust backend parity is ongoing" wording unless a new task defines a concrete
  parity gap; if broadening generated-source validation to every manifest case becomes desirable, split a new
  generated-source corpus-expansion leaf rather than folding it into status docs.

- 2026-07-07 (PUBLIC-STATUS-DRIFT-SYNC.0 — task-own public status/book drift before edits):
  Treat `ROADMAP_V2.md`, `MEMORY.md`, the active task-tree ledger, and
  `rust/linkedspec-runtime/tests/corpus/manifest.json` as the current status sources for public status sync. The
  Rust oracle manifest is under `rust/linkedspec-runtime/tests/corpus/manifest.json` and recorded 93 cases at that
  slice; the root `tests/corpus/` directory is the older three-case public corpus and is not the Rust parity count.
  Any mdBook status edit must be task-owned first by `PUBLIC-STATUS-DRIFT-SYNC.1`, and the older
  `ROADMAP-DRIFT-RECONCILE` leaves still own the long-form roadmap and architecture-state refresh separately.

- 2026-07-07 (SPEC-FORMAT-TERSE.9.6 — final colon hash-literal scans classify by owner):
  Do not treat every `=>` hit as current `.spec` hash-literal syntax. After `.9.6`, current authored `.spec`
  inputs are clean for direct `{ key => value }` hash literals; the current source form is `{ key : value }`, and
  mdBook documents old `{ key => value }` only as retired. Remaining `=>` owners are blind-call edge grammar,
  VHDL/source-language association syntax, generated Perl host hashrefs, Perl metadata/test data hashes, backend
  value-rendering examples, explicit retired-syntax diagnostics/tests, and historical records. Re-run owner-bucket
  scans before changing any of those surfaces; a global `=>` replacement would be wrong.

- 2026-07-07 (SPEC-FORMAT-TERSE.9.5 — retired hash-literal `=>` must be fatal, not fallback):
  Source-spelled ActionIR hash literals now use `:` only. A top-level `=>` inside a direct hash literal must route
  to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon`; it must not rebuild a current hash literal,
  become an expression-valued block, or compile away as an empty action. Perl AST/source reconstruction should
  serialize current hash literals with `:`; generated Perl host hashrefs may still use Perl `=>` after lowering.
  Rust scanners may still detect top-level `=>` only to classify the retired syntax and emit the diagnostic; the
  compiler must treat unsupported-ActionIR-helper parser diagnostics as fatal so rejected action code cannot fall
  through to `code: None`. Blind-call `=> Rule` remains rule-body syntax, not ActionIR hash-literal syntax.
  Do not feed already-lowered Perl host snippets back through the source parser: multi-argument AST `array(...)`
  constructors must emit `[...]` directly from lowered args, because a valid lowered hashref like
  `{$key => $value}` contains Perl host `=>` even though the source DSL form was `{ key : value }`.

- 2026-07-07 (SPEC-FORMAT-TERSE.9.4 — current source now prefers colon hash pairs):
  Current `.spec` authoring examples, generated oracle inputs, tests, mdBook examples, and current Knowledge facts
  should use `{ key : value }` for direct hash-literal association. Do not globally replace `=>`: blind-call edges,
  VHDL/source-language associations, generated Perl host hashrefs, Perl metadata hashes, historical records, and
  explicit old/new migration-window tests remain valid owners. The `.9.4` migration also exposed a Perl
  `MethodLowering.pm` source fallback that still detected only `=>` inside expression-valued block receiver chains;
  keep that scanner aligned with the ActionIR AST parser by accepting top-level `:` and old `=>` while skipping
  `::`. Hard retirement of source-spelled hash-literal `=>` is still `.9.5`, not part of the migration sweep.

- 2026-07-07 (SPEC-FORMAT-TERSE.9.3 — Rust colon hash literals reuse the same brace-classification boundary):
  Rust `linkedspec-core/src/expr.rs` now mirrors the Perl `.9.2` migration window: direct hash literals accept
  top-level `:` and old `=>` pair separators, while the scanner skips `::`, nested braces, brackets, parentheses,
  strings, and regex literals. Keep this in the ActionIR expression parser only. Blind-call edge `=> Rule` remains
  rule-body syntax, source-language associations such as VHDL remain out of scope, and broad current-source/corpus
  migration belongs to `.9.4`. Runtime `Expr::HashLiteral` evaluation was already separator-agnostic once the AST
  exists, so the behavior change is parser plus focused Rust locks, not a runtime data-model rewrite.

- 2026-07-07 (SPEC-FORMAT-TERSE.9.2 — Perl colon hash literals share the pair scanner with old `=>`):
  During the hash-literal migration window, the Perl ActionIR AST parser accepts both top-level `:` and `=>` as
  hash-literal pair separators. Keep this scoped to direct hash literals: skip `::` while scanning so block values
  containing package-like names do not become hashes, and remember that generated Perl hashrefs still use Perl
  `=>` internally. Do not migrate blind-call edge `=> Rule` syntax or VHDL/source-language associations under this
  leaf. Rust parity is still `.9.3`; broad source/docs/KM/corpus migration is `.9.4`.

- 2026-07-07 (SPEC-FORMAT-TERSE.9.1 — `=>` migration must preserve non-hash owners):
  The hash-literal colon migration is not a global `=>` replacement. Treat direct hash-literal association
  candidates separately from blind-call edge syntax (`=> Rule`), VHDL/source-language associations, historical
  evidence, and tests that intentionally mention old syntax. Parser implementation seams are Perl
  `ActionIR/AST/Parser.pm` (`_parse_hash_literal_expr`, `_find_top_level_fat_arrow`) and Rust
  `linkedspec-core/src/expr.rs::parse_hash_literal` plus runtime `Expr::HashLiteral` evaluation. The source DSL
  moves to `{ key : value }`, but generated Perl host code may still legitimately use Perl's own `=>` operator.

- 2026-07-07 (SPEC-FORMAT-TERSE.8.6 — no-drift scans must classify by executable surface):
  For helper-retirement closeout, treat current specs/corpora differently from docs/tests/code. Executable current
  specs and oracle inputs should be clean for retired helper calls; false positives such as regex colons,
  `JSON::PP`, comments, strings, and literal input text are not helper syntax. In code/tests/docs, old names may
  remain only as unsupported-helper diagnostics, regression locks, historical evidence, or explicitly retired
  reference material. If a current-facing guide says an old helper such as `concat(...)` is live syntax, fix it
  immediately to the current spelling (`cat(...)`) and record the audit conclusion in a Knowledge fact.

- 2026-07-07 (SPEC-FORMAT-TERSE.8.5 — post-retirement docs must not teach old spellings):
  After `.8.3`/`.8.4`, root guides and Knowledge cards may keep old helper names only as historical lowering
  evidence or retired-diagnostic guidance. Current-facing examples should use auto-existing variables, bare scalar
  reads, direct assignment/mutation, `set(...)`, `push(...)`, `copy(...)`, `cat(...)`, `array(...)`, and `hash(...)`.
  When an older policy record such as `.6.4` remains in a task/history file, explicitly mark it as superseded by
  `.8` hard retirement so it is not mistaken for live compatibility.

- 2026-07-07 (SPEC-FORMAT-TERSE.8.4 — retired helper diagnostics must stay explicit on Rust):
  Rust validation may still recognize retired helper names only to let the runtime return
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>`; it must not dispatch them successfully. Current aggregate reset
  forms such as `set(array(items), [])` must record a rule-local binding before mutation so recursive rule re-entry
  gets the same snapshot/restore boundary old `declare(array, items)` provided. On the Perl oracle side, any source
  reconstruction from ActionIR AST must preserve `source_method`; normalized implementation names such as `concat`
  are not enough once old source spellings are retired.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.3 — retiring old helpers needs source spelling, not normalized names):
  The Perl AST/parser path normalizes `cat(...)` to the historical lowering helper `concat`, so hard retirement
  cannot key only on the normalized method name. Carry the original source spelling through call/fluent nodes and
  synthesized receiver expressions, then retire only source-spelled legacy function forms (`concat(...)`,
  `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, `push_nonempty(...)`, declaration helpers/aliases).
  Current `cat(...)`, `copy(...)`, `push(...)`, typed wrappers, assignments, and current receiver methods should
  remain the success path while old spellings produce explicit unsupported-helper diagnostics.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.4 — closeout scans need stable buckets before hard retirement):
  Before removing a legacy helper implementation, first prove current authored specs/corpus/docs are clean and
  classify every remaining generated/test hit by owner. For this lane, root `specs/` and `tests/corpus/` are clean;
  generated corpus/test residues are declaration compatibility, aggregate-copy compatibility, current
  `.hash_copy()` receiver-method surface, or pending `.8.3`/`.8.4` retirement locks. Full phase0, corpus oracle,
  oracle regeneration, mdBook, and doctrine gates are the handoff proof.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.3 — docs/KM cleanup must distinguish current guidance from compatibility
  cataloging): Current-facing examples should not mention legacy helper spellings as the recommended route. Keep old
  helper names only where the section is explicitly compatibility, retired-diagnostic, or historical. For
  `push_nonempty(...)` migrations, write the value to a temporary once, guard with `is_nonempty(...)`, then append
  with `push(array(target), value)` so filter semantics stay visible and no one invents a replacement helper.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.5 — closeout scans need separate alias and false-positive buckets):
  Do not treat single-letter wrapper-alias scans as the same thing as primary helper scans. `a(...)` / `h(...)`
  must be classified where they are real fixture strings, while regex/input text such as `(a(b)c)` is only a false
  positive. The active-test/corpus closeout keeps root `specs/` and `tests/corpus/` clean, generated oracle inputs
  limited to declaration/aggregate-copy/hash-receiver compatibility categories, and phase0 residue scoped to the
  `.8.2.2.4` terse block classifications.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.4 — phase0 cleanup must preserve all-bare `push(...)` routing):
  In Perl phase0 fixture strings, do not replace `push_value(name, value)` with all-bare `push(name, value)` when
  both arguments are bare identifiers. That spelling keeps the child-call convention. Use `push(array(name), value)`
  or `name += value` for current append semantics when the RHS is a bare scalar read. The `.8.2.2.4` migration kept
  retained helper hits only when they are explicit compatibility/equivalence locks (`declare(...)`,
  `push_nonempty(...)`, aggregate-copy helpers, helper-renaming old sides, or current `.hash_copy()` receiver
  methods).

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.3 — generated corpus cleanup starts at the generator):
  Do not hand-edit generated oracle corpus fixtures as the source of truth. Migrate helper spellings in
  `tools/gen_oracle_corpus.pl`, regenerate, and expect `expected.json`/`manifest.json` to stay stable for
  output-preserving fixture-string cleanup. A compatibility fixture can still migrate incidental setup helpers
  (`push_value(...)` -> `push(...)`) while retaining the specific legacy helper under test (`array_copy(...)` or
  `hash_copy(...)`) as an explicit compatibility lock.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.2.5 — residue scans need ownership categories, not only string counts):
  For Rust integration-test helper cleanup, a raw `rg` hit is not automatically incidental debt. Classify by owner:
  recursive declaration scope (`.8.2.2.2.2`), explicit legacy-helper compatibility (`.8.2.2.2.3` / `.8.4`),
  current documented receiver-method surface (`meta.hash_copy()`), or legacy wrapper-alias boundary (`h(...)`).
  Only unowned fixture strings should be migrated in the scan leaf.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.2.4 — fixture cleanup must not conflate function helpers with receiver
  methods): In Rust integration fixtures, migrate function-form setup/snapshot helpers to current spellings
  (`push(...)`, `copy(...)`, explicit aggregate setters) where the current surface supports them. Do not rewrite
  hash receiver chains to `.copy()` as part of this cleanup: the documented current hash receiver method is still
  `.hash_copy()` today. A candidate `meta.copy()` change returned `Null` in
  `terse_2_3_5_2_hash_receiver_value_chains_run`, while `meta.hash_copy()` preserved the expected values. Leave
  hash receiver and wrapper-alias residue for the dedicated `.8.2.2.2.5` classification leaf.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.2.3 — compatibility tests need labelled old sides): In Rust integration
  tests, migrate the current side of helper-equivalence assertions to current spellings first, then leave the old
  side only when it is deliberately proving legacy compatibility for `.8.4`. `push_nonempty(...)` is kept as a
  labelled compatibility lock because it has filtering semantics, not because it is a plain `push(...)` alias.
  Later current-feature fixtures still carrying incidental old helper spellings are separate cleanup work owned by
  `.8.2.2.2.4`.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.2.2 — recursive Rust declaration scope is not an aggregate reset): In
  recursive Rust rules, `declare(array, items)` is not replaceable by `set(array(items), [])` today. The latter
  resets aggregate storage but does not create the rule-invocation snapshot/restore boundary that Rust declaration
  tracking provides. The focused TOP-RULE-AS-NORMAL candidate failed the two recursive value-parity tests by losing
  the outer `"a"` and duplicating nested payloads, while the Perl reference returned the same value for both forms.
  Migrate surrounding helpers (`push_value` -> `push`, `array_copy` -> `copy`, `a` -> `array`), but leave
  `declare(...)` as an intentional compatibility lock until the Rust hard-retirement leaf supplies equivalent
  current-surface scoping or a diagnostic.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.2.1 — integration-test helper cleanup needs category boundaries): Do not
  bulk-replace every old helper spelling in `integration_test.rs`. Ordinary smoke fixtures can move directly to
  current spellings, but recursive TOP-RULE-AS-NORMAL fixtures and explicit legacy-helper equivalence blocks carry
  separate semantic/compatibility ownership. Keep those categories split so a cleanup slice does not accidentally
  erase a compatibility lock or a scoped recursion fact.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.2.1 — migrate helper spellings without changing aggregate storage): When
  replacing old declaration/helper spellings in active fixtures, preserve storage intent, not just output shape.
  `name = []` binds a scalar-held array value under the current duck-typed assignment contract; it is not the same
  as clearing the named aggregate read or mutated by `array(name)` / `push(array(name), ...)`. For fixtures that
  previously used `declare(array, name)` to prepare aggregate storage, use `set(array(name), [])`. The
  source-emitter repetition snapshots caught this immediately: `pair = []` / `group = []` let the next iteration
  append onto the old named array, while `set(array(pair), [])` and `set(array(group), [])` preserved the original
  per-iteration snapshots.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.2.1 — `push_nonempty(...)` can be removed from live EBNF without inventing a
  replacement helper): For scalar capture-slice cleanup, the behavior-preserving expansion is simple and explicit:
  assign `trim(capture_slice())` once to a scalar temporary, gate on `is_nonempty(temp)`, then `push(...)` the
  temporary. This preserves the old helper's empty-string filtering for the EBNF logging-annotation path and keeps
  `"0"` meaningful because `is_nonempty(...)` already has the same truth boundary. The first full phase0 rerun
  caught a stale source-inspection lock that still expected `push_nonempty(...)`; update source locks when live
  examples migrate, not only runtime expectations. Generated EBNF corpus inputs changed with the shipped spec, but
  `expected.json` did not drift.

- 2026-07-06 (SPEC-FORMAT-TERSE.8.1 — legacy helper retirement needs a migration slice before engine removal):
  Do not remove legacy helper arms directly. The current successful surface is uneven: Perl already treats
  `assign(...)`, `scalar(...)`, and `s(...)`/`a(...)`/`h(...)` as raw/diagnostic, but still lowers declaration
  helpers, `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)`. Rust
  still executes `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and `array|a` /
  `hash|h`. `push_nonempty(...)` is not a plain alias: it skips undef, empty strings, empty arrays, and empty
  hashes while preserving `"0"`. Migrate or split that semantic replacement before hard-retiring helper support.

- 2026-07-06 (SPEC-FORMAT-TERSE.15.5 — no-drift closeout must scan retrieval facts too):
  Closing a syntax-removal lane is not just a code/spec scan. The final `:name` sweep found no current shipped-spec,
  generated-corpus, or mdBook live examples, but it did find stale Knowledge fact-card text: a duck-typed
  assignment reverify command still used `:items` / `:meta`, and the string-method note still described
  `substr(:target, ...)` as the mutation form. After `.15.3`/`.15.4`, both must use the current bare surface
  (`items`, `meta`, `substr(target, ...)`). Treat Knowledge cards as executable retrieval surface: historical cards
  may mention retired syntax, but `status: current` cards and their `reverify` commands must use syntax that still
  works unless the fact is explicitly about a retired diagnostic.

- 2026-07-06 (SPEC-FORMAT-TERSE.15.4 — Rust colon-slot removal needs action-edge `retv` awareness):
  Rust no longer has an `Expr::ScalarSlot` compatibility branch. `:name` fails in the core parser with the same
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` sentinel family used by Perl, and all
  runtime/source-emitter fixtures use bare value reads. The subtle Rust-only boundary is action-edge execution:
  after removing `:retv` fixtures, blocks that read bare `retv` still need the matched edge child's scoped return
  available before block evaluation. Treat `block_reads_retv(...)` like an explicit `call(child)` for
  pre-dispatch/scoped-result purposes. The EBNF oracle is a good regression target here: the shipped spec must use
  a distinct scalar header (`rule_header`) plus aggregate body array (`rule`) so bare reads do not rely on the old
  same-name scalar/array collision. The generated corpus case now named `terse_15_4_bare_scalar_payload_readback`
  is the current bare-read lock for the former scalar-slot payload example. Phase0 also has a source lock for this
  EBNF seam; keep it keyed to `rule_header`, not the old same-name `rule` scalar.

- 2026-07-06 (SPEC-FORMAT-TERSE.15.3 — removing `:name` also tests the bare-read grammar boundaries):
  Perl `:name` is now hard-retired, not compat-retained: parsing/lowering emits
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`, and `scalar_slot_fallback` is gone.
  The removal exposed places where the old colon spelling had hidden real bare-read ownership boundaries. Inline
  `if(on, action...)` / `elseif(mid, action...)` and `switch(name, case(...), default(...))` must classify the
  following argument before treating a leading bare word as optional scope. Logical `or(...)` / `and(...)` operands
  are value conditions, not optional-scope payloads, so keep every operand. `entry_text()` / `match_text()` can lower
  directly in ordinary value positions, but user-function bodies must continue to leave parser-state helpers
  unresolved until staged body parsing owns that environment. For assignments, an unchanged `_lower_method_value_expr`
  result is not proof that a source token is already handled; delegate unchanged/reserved tokens to the assignment
  source lowerer. Finally, scalar-held container values must stay visible to receiver/helper fast paths:
  `count_keys(snapshot)` should count a scalar-held hashref before falling back to named hash storage.

- 2026-07-06 (SPEC-FORMAT-TERSE.15.2.4 — source migration stress-tested the bare-read seams):
  The current `:name` to bare-read migration was output-preserving, but only after preserving several boundaries
  that are easy to collapse accidentally. Parser-backed `set(...)` can surface as an internal `assign(...)` AST
  call; when reconstructing control-flow value sources, normalize that internal name back to `set(...)` unless the
  user source was explicitly `assign(...)`. Do not route `split_tagged_records(source, ...)` through optional-scope
  normalization: its first bare argument is the data source, not a scope label. Fluent
