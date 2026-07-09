# LIVE ACHIEVEMENT STATUS
Current execution status for interruption-safe batch workflow recovery.

## Active Batch
- BWFSC target: PNT cycle started 2026-05-16 after PHASE2-DSL-FRONTEND completion and PHASE1A-CLOSE-OUT close-out.
- Push policy: **push every 300 commits** (per 2026-06-16 user directive; raised from 200). Otherwise do not push mid-batch. Currently tracking via `git status -sb` ahead-count.
- Stop policy: stop early only for a real blocker such as unresolved failing tests, ambiguous roadmap direction, conflict with user changes, or a slice expanding beyond a safe boundary.

## Latest Completed Slice
- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.4.3 — close Dart helper mutation surfaces**
  (DONE — helper mutation and text-normalization parser-smoke fixtures now pass on Dart).

  **Change:** Dart now executes statement-context `substr(...)` / `regex_subst(...)` scalar mutations, expands
  regex replacement captures, replaces explicit `split(array(target), ...)` targets, and exposes entry/local regex
  start line/column helpers.

  **Boundary:** `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass. The
  shipped-spec/parser-smoke diagnostic window is now 22/31 green. Active implementation work advances to
  `DART-BACKEND-PARITY.6.2.4.4.4` for the remaining legacy structural smoke outputs:
  `regdef_nested_register_fields` and `ds_vhistory_version_entry`.

  **Verification:** Dart format/analyze/full tests, focused runtime/corpus tests, focused helper/text-normalizing
  corpus run, CLI/help corpus-loader smokes, mdBook, memory architecture, Knowledge Map, task-tree metadata,
  doctrine, and `git diff --check` pass. The diagnostic parser-smoke corpus run measures the expected 22/31
  boundary with remaining failures routed.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.4.2 — close Dart hlink delimiter captures**
  (DONE — hlink delimiter/capture fixtures now pass on Dart).

  **Change:** Dart `call(...)` refreshes the runtime `retv` channel with child results, and append-style mutations
  now update scalar-held lists created by assignments such as `items = []`. That makes
  `push(array(word_items), retv)` visible through `array(word_items)` in `hlink_substitution.spec`.

  **Boundary:** All five hlink fixtures pass. The shipped-spec/parser-smoke diagnostic window is now 19/31 green;
  `tablegrep_simple_term` is also green from the same scalar-held append behavior. Active implementation work
  advances to `DART-BACKEND-PARITY.6.2.4.4.3` for helper mutation and text-normalization parity.

  **Verification:** Dart format/analyze/full tests, focused runtime/corpus tests, focused hlink corpus run,
  diagnostic corpus run, CLI/help corpus-loader smokes, mdBook, memory architecture, Knowledge Map, task-tree
  metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.4.1 — close Dart portmap result shapes**
  (DONE — explicit `flat*` arguments splice correctly inside Dart `array(...)`).

  **Change:** Dart `array(...)` now splices explicit `flat(...)`, `flat_array(...)`, and `flat_hash(...)` call or
  fluent arguments into the constructed array, while `copy(...)` remains nested. This fixes the extra array layer
  in the five portmap corpus fixtures and also turns `vhdl_library_use` green.

  **Boundary:** The shipped-spec/parser-smoke diagnostic window is now 13/31 green. Active implementation work
  advances to `DART-BACKEND-PARITY.6.2.4.4.2` for hlink delimiter/capture parity. PCRE structural regex blockers
  remain routed to `.6.2.4.6`.

  **Verification:** Dart format/analyze/full tests, focused runtime/corpus tests, focused portmap corpus run,
  diagnostic corpus run, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.4.0 — split Dart residual parser-smoke parity**
  (DONE — residual shipped-spec parser-smoke work is split into narrow non-PCRE implementation leaves).

  **Change:** The 7/31 parser-smoke boundary after `.6.2.4.3` is now classified into portmap/action-edge child
  result shape, hlink delimiter/capture, helper mutation and text normalization, legacy structural smoke outputs,
  residual closeout, and the already separate PCRE structural-regex follow-up.

  **Boundary:** Planning split only. No implementation code changed. Active implementation work advances to
  `DART-BACKEND-PARITY.6.2.4.4.1` for portmap/action-edge child result shape parity.

  **Verification:** mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.3 — close Dart recursive dispatch semantics**
  (DONE — tclite/default-mode and recursive top-rule parser-smoke fixtures now pass on Dart).

  **Change:** Dart compiled action edges now carry resolved regex-dispatch metadata, edge-only child regexes are
  folded into the parent alternation, and runtime dispatch executes all edges for the matched regex index. Explicit
  aggregate resets through `set(array(name), ...)` / `set(hash(name), ...)` now scope those bindings to the current
  rule invocation, preserving recursive `sexpr` value parity without hiding ordinary undeclared child mutations.

  **Boundary:** The final shipped-spec/parser-smoke window is now 7/31 green. Lispish still hits recursive PCRE
  `(?R)` and is routed to `.6.2.4.6`; residual hlink/output/helper mismatches advance to
  `DART-BACKEND-PARITY.6.2.4.4`.

  **Verification:** Focused compiler/runtime tests, Dart format/analyze, full Dart tests, selected tclite/top-rule
  corpus cases, diagnostic corpus run, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine,
  and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.2 — bridge Dart helper action surfaces**
  (DONE — missing helper/action surfaces no longer block Dart).

  **Change:** Dart now executes direct capture-slice helpers, diagnostic `print`/`print_each`/`say`, logical
  `and`/`or`/`not`, and Rust-style terminating `exit_now(...)`. The action parser now keeps literal delimiters
  inside quoted helper arguments while matching call parentheses, so shipped `print("...", "\n")` calls no longer
  become raw fallback expressions.

  **Boundary:** The final shipped-spec/parser-smoke window remains 2/31 green, but missing helper/action blockers
  now move to explicit recursion/default-mode/output mismatches, deliberate `exit_now(...)` diagnostic branches,
  and already-routed PCRE structural regex blockers. Active implementation work advances to
  `DART-BACKEND-PARITY.6.2.4.3`.

  **Verification:** Focused action parser/runtime interpreter tests, Dart format/analyze, full Dart tests,
  diagnostic corpus run, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.1 — bridge Dart shipped regex dialect**
  (DONE — basic shipped regex dialect incompatibilities no longer block Dart).

  **Change:** Dart now normalizes POSIX character classes, inline/scoped `i`/`m`/`s` flag groups, possessive
  quantifier markers, lower-bound `{,n}` quantifiers, and Python-style named captures through a shared runtime
  regex compiler used by both rule matching and helper regex values.

  **Boundary:** The final shipped-spec/parser-smoke window remains 2/31 green, but the earlier
  POSIX/inline-flag/possessive FormatExceptions now move to narrower runtime/helper/output failures. Remaining
  PCRE structural constructs (`\K`, `(?&name)`, `(?(DEFINE)...)`) are routed to `DART-BACKEND-PARITY.6.2.4.6`.
  Active implementation work advances to `DART-BACKEND-PARITY.6.2.4.2`.

  **Verification:** Focused runtime matching/interpreter tests, Dart format/analyze, diagnostic corpus run,
  mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.4.0 — split Dart shipped corpus smoke batch**
  (DONE — final shipped-spec/parser-smoke window measured and split).

  **Change:** The bounded window `--execute --offset 68 --limit 31` is 2/31 green on Dart: `pplugin_empty` and
  `tkgui_empty` pass. The 29 failures are now grouped into regex-dialect translation, missing helper/action
  surfaces, recursive/default-mode output semantics, and residual shipped-spec smoke parity.

  **Boundary:** Planning split only. No implementation code changed. Active implementation work advances to
  `DART-BACKEND-PARITY.6.2.4.1` for the Dart regex-dialect bridge.

  **Verification:** Diagnostic corpus run, mdBook, memory architecture, Knowledge Map, task-tree metadata,
  doctrine, and `git diff --check` pass.

- 2026-07-09: **FUTURE-PARITY-BACKLOG.8.0 — capture spec-derived roundtrip idea**
  (DONE — director's single-source `.spec` parser/stimuli arc is parked for later design).

  **Change:** Added `FUTURE-PARITY-BACKLOG.8` with completed capture leaf `.8.0` and pending design leaf `.8.1`.
  The idea is to derive both a parser and a stimuli generator from the same `foo.spec`, making `.spec` the sole
  source of truth for future closed-loop roundtrip validation.

  **Boundary:** Planning capture only. No implementation code changed, no generator grammar was introduced, and
  active implementation work remains on `DART-BACKEND-PARITY.6.2.4`.

  **Verification:** mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.3 — close Dart middle corpus batch**
  (DONE — non-`fn` helper/control/receiver middle fixtures pass; `fn` corpus fixtures routed).

  **Change:** Dart now preserves assignment expressions inside helper argument lists, supports plain fallback
  values in inline `if(...)`, evaluates numeric aggregate reducer aliases such as `min(scores)` through
  aggregate-aware reads, and follows the duck-typed scalar-held list/map readback contract through `array(name)`,
  `hash(name)`, and `copy(name)`. Explicit aggregate writes clear stale scalar-held values.

  **Boundary:** The owned middle corpus window is 25/28 green. The three top-level `fn` fixtures remain routed to
  `DART-BACKEND-PARITY.6.2.5` because the corpus runner needs spec-produced `function_definition` nodes rather
  than a Dart raw scanner. Active implementation work advances to `DART-BACKEND-PARITY.6.2.4`.

  **Verification:** Focused parser/runtime tests, Dart format/analyze/full tests, split execute-mode corpus smokes
  over the 25 passing middle fixtures, default corpus loader/help, CLI help, mdBook, memory architecture,
  Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.6.2.2 — close Dart starter corpus batch**
  (DONE — first 40 shipped manifest fixtures execute green on Dart).

  **Change:** Dart now treats non-null empty array/hash returns as successful rule matches, uses the child
  rule's `matched` bit for blind dispatch instead of output truthiness, and executes marker-form
  `if(...)` / `elseif(...)` / `else()` / `endif()` statement chains as grouped branches in action and value
  blocks. The starter shipped-corpus batch now passes with
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40`.

  **Boundary:** This is a bounded starter corpus proof, not full 99-fixture Dart corpus parity. Active
  implementation work advances to `DART-BACKEND-PARITY.6.2.3` for helper/control/receiver/user-function/tree
  traversal fixtures.

  **Verification:** Dart format/analyze/full tests, default corpus loader/help, bounded 40-fixture execute
  smoke, CLI help, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.5.3 — preserve Dart staged descriptor shapes**
  (DONE — staged parse-job/function-registry descriptor-shape proof).

  **Change:** Dart now has a focused descriptor proof for staged user functions. The compiled-state test starts
  from spec-returned `function_definition` nodes, dispatches `body_parse_job` records through the staged registry,
  compiles the stitched `SpecFile`, asserts neutral `body_payload`, normalized `body_parse_job`, stitched
  `body_ast`, function-order metadata, and verifies runtime output from the same compiled state.

  **Boundary:** This closes the `.5` staged/user-function container. It does not claim full corpus output parity;
  active implementation work advances to `DART-BACKEND-PARITY.6`.

  **Verification:** Focused compiled-state tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.5.2 — execute Dart user functions**
  (DONE — registered exact-arity user-function runtime execution).

  **Change:** Dart now resolves registered exact-arity user-function calls before ordinary runtime helper
  fallback. Arguments evaluate eagerly in the caller, params bind into fresh function-local scalar/array/hash
  stores, function bodies return the final expression or local `return(...)` payload, returned values continue
  through compatible receiver chains, standalone calls execute with discarded results, and direct/mutual recursion
  produces structured `user_function_call` diagnostics.

  **Boundary:** This executes registered functions in the interpreter; it does not yet close descriptor/corpus
  shape preservation or full corpus output parity. Active implementation work advances to
  `DART-BACKEND-PARITY.5.3`.

  **Verification:** Focused runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook, memory
  architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.5.1 — add Dart staged function-body registry**
  (DONE — minimal staged registry provider for function-body parse jobs).

  **Change:** Dart now exports the narrow staged registry path for function-body parse jobs. The registry resolves
  `actionir-body.spec` to `builtin:actionir-body.spec`, records the fixed adapter digest/cache key and compiled
  parser shape for top rule `action_block`, executes jobs in stable queue order, and stitches returned
  `action_block` JSON into `body_ast` through `dispatchFunctionBodyParseJobs(...)` and
  `parseSpecWithStagedUserFunctionDefinitionAsts(...)`.

  **Boundary:** This is not general staged parsing. Public `parse_job(...)` authoring, provider search roots, and
  recursive staged queues remain future work. Runtime function-call execution has since landed in
  `DART-BACKEND-PARITY.5.2`.

  **Verification:** Focused staged-registry tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.5.4 — close Dart diagnostics trace no drift**
  (DONE — diagnostics/trace status closeout; `.4.5` container closed).

  **Change:** Dart README, CLI/scaffold status, mdBook trace/status/handoff pages, live docs, roadmap, task-tree
  index, MEMORY, and Knowledge Map now agree on the diagnostics/trace boundary: structured runtime diagnostics,
  trace controls/sinks/events, traced runtime entrypoints, and runtime interpreter trace events are implemented.

  **Boundary:** This is a no-runtime-source closeout. Dart does not claim full backend parity yet; staged registry
  execution, user-function runtime parity, corpus output parity, Dart-specific CLI productization, and final Dart
  parity closeout remain later leaves. Active implementation work advances to `DART-BACKEND-PARITY.5.1`.

  **Verification:** CLI help, focused drift scans, mdBook, memory architecture, Knowledge Map, task-tree metadata,
  doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.5.3 — add Dart runtime trace events**
  (DONE — branch/lifecycle/source-boundary runtime trace instrumentation).

  **Change:** Dart runtime tracing now emits rule scopes, recursion-cutoff decisions, regex match/no-match
  decisions, action-edge and blind-call child-dispatch decisions, lifecycle block marks, cursor-control helper
  marks, and `capture_until_boundary(...)` source-boundary marks through the optional `LinkedSpecTraceEmitter`.
  Traced and untraced parse-result JSON remain identical.

  **Boundary:** This lands runtime instrumentation on top of the existing trace controls. Diagnostics/trace
  no-drift remains `.4.5.4`; staged runtime execution and corpus output parity remain later leaves. Active
  implementation work advances to `DART-BACKEND-PARITY.4.5.4`.

  **Verification:** Focused trace tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook, memory
  architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.5.2 — add Dart trace controls**
  (DONE — trace levels, controls, event primitives, and sinks).

  **Change:** Dart now exports trace levels/config/emitter/event primitives, parses the documented
  `LINKEDSPEC_TRACE_*` environment controls, supports stdout/routed-file/mirror sinks with reset/truncate behavior,
  and exposes traced runtime entrypoints that preserve parse output while emitting parse-scope events.

  **Boundary:** This lands trace controls only. Runtime branch/lifecycle/source-boundary trace instrumentation
  remains `.4.5.3`; staged runtime execution and corpus output parity remain later leaves. Active implementation
  work advances to `DART-BACKEND-PARITY.4.5.3`.

  **Verification:** Focused trace tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook, memory
  architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.5.1 — add Dart runtime diagnostics**
  (DONE — structured diagnostics on Dart runtime exceptions).

  **Change:** Dart now exports `RuntimeDiagnostic` and attaches it to
  `RuntimeInterpreterException.diagnostic`. Runtime failures preserve stable neutral fields for type, stage,
  owner stage, summary, detail, top rule, rule label, handler/source attribution, and optional spec identity.
  Successful `RuntimeParseResult` output remains unchanged.

  **Boundary:** This lands diagnostics only. Trace levels, event classes, stdout/routed-file/mirror sinks, and
  runtime trace instrumentation remain later `.4.5` leaves. Active implementation work advances to
  `DART-BACKEND-PARITY.4.5.2`.

  **Verification:** Focused runtime interpreter tests, Dart format/analyze/full tests, corpus runner, CLI help,
  mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.5.0 — split Dart diagnostics trace controls**
  (DONE — task-tree split before code).

  **Change:** The broad Dart runtime diagnostics/trace-controls leaf is now a container. `.4.5.1` owns structured
  runtime diagnostics, `.4.5.2` owns trace levels/controls/event classes and stdout/routed-file/mirror sinks,
  `.4.5.3` owns runtime branch/lifecycle/source-boundary trace instrumentation, and `.4.5.4` owns no-drift
  closeout.

  **Boundary:** No Dart runtime behavior changed. Active implementation work advances to
  `DART-BACKEND-PARITY.4.5.1` for structured runtime diagnostics.

  **Verification:** Memory architecture, Knowledge Map generation/check, task-tree metadata, doctrine, and
  `git diff --check` pass.

- 2026-07-09: **BACKTRACK-SURFACE-RUST-ALIGNMENT.2 — add boundary lookahead helper**
  (DONE — non-consuming structural boundary capture across current variants).

  **Change:** Perl, Rust, and Dart now support `capture_until_boundary(rule[, ...])`. The helper starts from the
  live cursor, probes named structural rules, captures the text before the earliest boundary, and leaves that
  boundary unconsumed for the normal rule path. `specs/ebnf.spec` and Rust corpus copies now use it for
  `semantic_annotation`, so annotation bodies stop before the next `semantic_annotation` or `grammar_rule`
  without consume-then-rewind behavior.

  **Boundary:** This closes the Rust-reference backtrack-surface alignment tree. The current portable cursor
  surface is now `save_cursor()` / `restore_cursor()`, `rewind_match_start()` / `rewind_entry_start()`, and
  `capture_until_boundary(rule[, ...])`; old broad backtrack spellings are not current user-facing API. The
  AND-only compact child-sequence / quantifier idea is recorded as deferred design direction, not active work.

  **Verification:** Focused Perl/Rust/Dart boundary tests, standalone phase0 `1..1028`, Rust format/core/runtime
  package tests, Dart format/analyze/full tests, mdBook, Knowledge Map, memory architecture, doctrine, local CI,
  and `git diff --check` pass.

- 2026-07-09: **BACKTRACK-SURFACE-RUST-ALIGNMENT.1 — explicit cursor controls**
  (DONE — replacing broad backtrack names with precise cursor controls across current variants).

  **Change:** Perl, Rust, and Dart now target `save_cursor()` / `restore_cursor()` for explicit cursor-stack
  semantics and `rewind_match_start()` / `rewind_entry_start()` for lifecycle-anchor rewinds. The old
  `BACKTRACK()` / `IBACKTRACK()` and lowercase `backtrack(label)` / `ibacktrack(label)` forms are not current
  portable API. `specs/ebnf.spec` and Rust corpus copies use `rewind_match_start()` as the semantic-preserving
  replacement for the former annotation consume-then-rewind pattern.

  **Boundary:** This closes the cross-variant cursor-stack and anchor-rewind rename. Active implementation work
  advances to `BACKTRACK-SURFACE-RUST-ALIGNMENT.2`, which owns the preferred zero-width/lookahead boundary
  primitive so annotation bodies can stop at the next structural token without consuming it.

  **Verification:** Perl syntax checks, standalone phase0 `1..1027`, local CI, Rust format/core/runtime tests,
  Dart format/analyze/full tests/CLI/corpus runner, mdBook, Knowledge Map, memory architecture, doctrine,
  active old-helper scan, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.4 — add Dart backtrack cursor rewinds**
  (DONE BACKTRACK/IBACKTRACK cursor rewinds and cursor/input helpers).

  **Change:** Dart runtime execution now supports `BACKTRACK()` as a cursor-only rewind to the current local match
  start and `IBACKTRACK()` as a cursor-only rewind to the initial/entry match start for the current context. The
  `I` in `IBACKTRACK` is the Initial/`I` lifecycle context. The runtime also exposes char-based cursor/input
  helpers such as `cursor_pos`, `cursor_rest`, `input_slice`, and `input_end_pos`, while preserving Dart's
  internal code-unit cursor state. A later Rust-reference cleanup removes the short-lived Dart lowercase backtrack
  compatibility aliases before they become a durable public surface.

  **Boundary:** This closes the BACKTRACK/cursor-helper slice. Runtime diagnostics/tracing, staged runtime
  execution, corpus output parity, Dart-specific CLI productization, and final parity closeout remain later
  leaves. Active implementation work advances to `DART-BACKEND-PARITY.4.5`.

  **Verification:** Focused runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.6 — close Dart helper value no drift**
  (DONE helper/value no-drift; `.4.3` container closed).

  **Change:** Dart nested value-path assignment now matches the Perl/Rust contract. Successful writes return the
  updated root aggregate, missing or wrong intermediate paths return `null` without mutation, final hash keys may
  be created, final array writes only replace or append exactly at `len`, and intermediate containers are not
  autovivified. Direct hash-index assignment also preserves scalar-held map/list root ownership before named hash
  fallback.

  **Boundary:** This closes the Dart helper/value runtime container. BACKTRACK and local cursor rewind behavior,
  tracing, staged runtime execution, corpus output parity, Dart-specific CLI productization, and final parity
  closeout remain later leaves. Active implementation work advances to `DART-BACKEND-PARITY.4.4`.

  **Verification:** Focused parser/runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.5 — add Dart runtime controls and tree callbacks**
  (DONE value blocks, structured controls, with-blocks, and tree traversal receiver callbacks).

  **Change:** Dart runtime execution now supports expression-valued blocks with block-local `return(...)` /
  `return_undef()`, final-expression yields, attached `if` / `elseif` / `else` and `when` / `otherwise`, attached
  `switch` / `case` / `default`, attached `while` with the deterministic iteration guard, inline lazy `if(...)` /
  `switch(...)`, helper-form `with(value) { ... }` / `with() { ... }`, receiver `.with() { ... }`, and hash/array
  `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver callbacks. Callback frames scope and restore
  `value`, `path`, `depth`, hash `key`, array `index`, and reduce-only `acc`.

  **Boundary:** This closes the helper/control/tree runtime execution slice. BACKTRACK, tracing, staged runtime
  execution, corpus output parity, Dart-specific CLI productization, and final no-drift closeout remain later
  leaves. Active implementation work advances to `DART-BACKEND-PARITY.4.3.6`.

  **Verification:** Focused parser/runtime tests, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.7.3 — record variant-specific CLI requirement**
  (DONE docs-only planning split for per-variant LinkedSpec CLI ownership).

  **Change:** Recorded the directive that each LinkedSpec backend variant should have a distinct CLI. Dart-specific
  CLI productization is now owned by `DART-BACKEND-PARITY.7.4`; final Dart no-drift closeout shifts to `.7.5`.
  The future-backlog tree records that Julia and Lua planning must include equivalent CLI ownership when activated.

  **Boundary:** No CLI behavior changed in this slice. It recorded future CLI ownership before the runtime frontier
  advanced through `DART-BACKEND-PARITY.4.3.5`.

  **Verification:** mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine checks, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.4 — add Dart runtime hash helpers**
  (DONE hash helper family, hash receiver chains, and statement/value mutation boundaries).

  **Change:** Dart runtime helper execution now covers `count_keys`, `sorted_keys`, `sorted_values`, `has_key`,
  `merge_hash`, pure/value `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `flat_hash`, bare hash
  working-variable receiver chains, statement-form `set_key(...)` mutation, direct hash-index assignment values,
  and explicit flat-style hash splicing inside `hash(...)`.

  **Boundary:** This closed hash helper breadth only. Value-block/control/tree traversal helpers landed later in
  `.4.3.5`; BACKTRACK, tracing, staged function execution, full corpus output parity, and per-variant CLI
  productization remain later leaves.

  **Verification:** Focused runtime interpreter and ActionIR contract tests, Dart format/analyze/full tests,
  corpus runner, CLI help, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis
  evidence, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.3 — add Dart runtime array helpers**
  (DONE array helper family, array receiver chains, split bridges, reducers, and statement-only end mutations).

  **Change:** Dart runtime helper execution now covers array count/select/order/membership helpers, transform and
  filter pipelines, delimiter-first `join_values`, regex split/filter bridges, `flat_array`, `concat_arrays`,
  `split_tagged_records`, array numeric reducers, bare array working-variable receiver chains, and statement-only
  `push_back` / `push_front` / `pop_back` / `pop_front` mutation forms.

  **Boundary:** This closes array helper breadth only. Hash helper breadth, value-block/control/tree traversal
  helpers, BACKTRACK, tracing, staged function execution, and full corpus output parity remain later leaves.

  **Verification:** Focused runtime interpreter and ActionIR contract tests, Dart format/analyze/full tests,
  corpus runner, CLI help, mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis
  evidence, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.2 — add Dart runtime string numeric helpers**
  (DONE string/scalar helper family, numeric helper family, aliases/symbol callees, and scalar receiver chains).

  **Change:** Dart runtime helper execution now canonicalizes ActionIR helper names and evaluates current
  string/scalar helpers, explicit `str_*` lexical comparisons, numeric arithmetic/reducer/comparison helpers,
  numeric word aliases, arithmetic/comparison symbol callees, and compatible string/number receiver chains.

  **Boundary:** This closes the string/scalar and numeric helper slice only. Broader array helper breadth, hash
  helper breadth, value-block/control/tree traversal helpers, BACKTRACK, tracing, staged function execution, and
  full corpus output parity remain later leaves.

  **Verification:** Focused runtime interpreter tests, Dart format/analyze/full tests, corpus runner, CLI help,
  mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, diagnosis evidence, and
  `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.1 — add Dart runtime value capture helpers**
  (DONE core runtime value/store and capture-reader subset).

  **Change:** Dart runtime execution now preserves scalar/array/hash/null/boolean/number shapes through
  assignment and wrapper snapshots; supports `hash(...)`, `set(hash(...), ...)`, hash-index mutation, nested
  access reads, non-numeric map indexing, aggregate `copy(...)`, and the named/map/length/start/end
  `entry_*` / `match_*` capture helper family.

  **Boundary:** This is still the core value/capture subset. String/scalar helpers, numeric helpers, array helper
  family breadth, hash helper breadth, value-block/control/tree traversal helpers, BACKTRACK, tracing, staged
  function execution, and full corpus output parity remain later leaves.

  **Verification:** Focused runtime interpreter test, Dart format/analyze/full tests, corpus runner, CLI help,
  mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.3.0 — split Dart runtime helper families**
  (DONE task-tree split before broad helper/value implementation).

  **Change:** Split `.4.3` into focused runtime helper/value leaves: core value/store/capture helpers,
  string/number helpers, array helpers, hash helpers, value-block/control/tree traversal helpers, and final
  helper/value no-drift closeout.

  **Boundary:** No runtime code changed in this planning slice. The next executable frontier is `.4.3.1`.

  **Verification:** Memory architecture, task-tree metadata, doctrine checks, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.2 — add Dart runtime rule interpreter**
  (DONE first executable rule-dispatch interpreter; broader helper families are next).

  **Change:** Added `LinkedSpecRuntimeEngine` and `RuntimeParseResult` over `CompiledSpec`, with
  default/AND/OR/repetition dispatch, action-edge and blind-call child execution, lifecycle blocks, explicit
  returns, `retv`, accumulator collection, bounded repetition, zero-progress cutoffs, and recursion cutoffs.

  **Boundary:** The embedded ActionIR evaluator is intentionally dispatch-facing only. Full helper/value
  families, BACKTRACK, runtime diagnostics/tracing, staged function execution, and corpus output parity remain
  later leaves.

  **Verification:** Focused runtime interpreter test, Dart format/analyze/full tests, corpus runner, CLI help,
  mdBook, memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.4.1 — add Dart runtime matching state**
  (DONE regex matching and match-state primitives; rule dispatch is next).

  **Change:** Added Dart seek/consume regex alternation, stable alternative identity, capture and named-capture
  records, char-offset/line-column projection, entry/local match registers, cursor state, and zero-progress
  helpers over compiled rule regex lists.

  **Boundary:** This is still below rule dispatch. Lifecycle order, rule modes, recursion guards, helper/action
  execution, tracing, and corpus output comparison remain later leaves.

  **Verification:** Focused runtime matching test, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.3.4 — add Dart compiled spec state**
  (DONE compiled rule/dependency/descriptor state; runtime matching is next).

  **Change:** Added `compileSpec(...)` and the Dart compiled-state model: ordered rules, rule metadata,
  dependency refs, structured dependency-regex entries, lifecycle/action `ActionBlock` payloads, registry-aware
  ActionIR contract resolution, user-function registry carry-through, and descriptor-shaped JSON projection.

  **Boundary:** This is still non-executing compiler/interpreter state. Dart runtime matching, rule dispatch,
  helper execution, tracing, and corpus output comparison remain later leaves.

  **Verification:** Focused compiled-state test, Dart format/analyze/full tests, corpus runner, CLI help, mdBook,
  memory architecture, Knowledge Map, task-tree metadata, doctrine, and `git diff --check` pass.

- 2026-07-09: **DART-BACKEND-PARITY.3.3 — add Dart function registry**
  (DONE user-function registry and staged function-body parse-job records; compiled state is next).

  **Change:** Added `UserFunctionRegistry`, `UserFunctionEntry`, and exact-arity call resolution over Dart
  `FunctionDefinition` records. ActionIR contract resolution can now classify exact-arity user calls before helper
  fallback and reports wrong-arity registered calls as user-function arity diagnostics.

  **Boundary:** This is still non-executing frontend/contract infrastructure. Dart compiled-spec state, runtime
  interpreter execution, and corpus output comparison remain later leaves.

  **Verification:** Focused registry/contract tests, Dart format/analyze/full tests, corpus runner, CLI help, and
  mdBook build pass.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.5 — close helper purge no-drift**
  (DONE final no-drift scan and documentation closeout; tree complete).

  **Change:** Migrated the last active Rust runtime unit-test fixture that still used retired helper-call strings
  for generic fallback coverage to invented unknown helper names. Closed the task tree, Knowledge facts, roadmap
  row, and resume pointer. PNT returns to `DART-BACKEND-PARITY.3.3` after the clean commit.

  **Boundary:** Historical migration notes and retired-helper reference documentation remain allowed, but active
  source/test/tool/spec helper-call examples and colliding labels are closed for this purge.

  **Verification:** Final exact retired-helper call-shape scans, label/tag scans, exact `?concat:` scans,
  scalar-wrapper scans, short-wrapper spec-surface scan classification, Rust formatting, and the focused runtime
  generic unknown-helper unit test pass.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.4 — migrate retired helper fixtures**
  (DONE active test/tool/generated fixture and checked-in `.spec` spelling migration; final no-drift closeout is
  next).

  **Change:** Replaced active retired-helper call examples with current syntax or invented unknown-helper names,
  renamed EBNF return annotation labels/output tags to `return_scalar_value` / `return_array_value`, and renamed
  portmap concatenation output from `?concat:` to `?concatenation:` across source spec, generated corpus inputs,
  expected output, Perl/Rust tests, and mdBook examples.

  **Boundary:** This closes active fixture/tool/spec migration. Historical retirement documentation and explicit
  retired-helper reference sections remain allowed; `NONCURRENT-HELPER-CODE-PURGE.5` owns the final no-drift scan
  and closeout.

  **Verification:** Exact retired-helper call-shape scans, retired label/tag scans, exact `?concat:` scan, touched
  Perl syntax checks, focused Perl tests, full phase0 (`1027` tests), regenerated 99-fixture oracle corpus,
  full `linkedspec-runtime` package tests, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.3 — purge Rust helper diagnostics**
  (DONE Rust source recognition/diagnostic cleanup; active fixture/tool/spec migration is next).

  **Change:** Rust known-call validation no longer lists retired helper spellings, the expression parser no longer
  special-cases `declare(...)` keyword arguments, and runtime helper dispatch no longer returns name-specific
  retired-helper diagnostics. Retired helper-looking calls now follow the generic unknown-helper fallback. Runtime
  context internals were renamed away from public-looking retired helper names, and stale positive Rust fixtures now
  use current colon hash-literal syntax.

  **Boundary:** This closes Rust source recognition/diagnostic paths. It deliberately leaves broader active
  test/tool/generated fixture and checked-in `.spec` spelling migration for `NONCURRENT-HELPER-CODE-PURGE.4`.

  **Verification:** Rust focused retired-helper scans, `cargo fmt --manifest-path rust/Cargo.toml --all --check`,
  `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core`,
  `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime`, and focused runtime
  `helpers_5_1_retired_terse_8_4_spellings_use_generic_unknown_helper_path` / `scalaref_retirement_4` runs pass.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.2.4 — close Perl source purge scans**
  (DONE Perl source purge verification; Rust source cleanup is next).

  **Change:** Focused source scans over `perl/LinkedSpec.pm` and `perl/LinkedSpec` are clean for exact retired
  helper call-shape recognition paths from the `SPEC-FORMAT-TERSE.8` spelling set. Direct lowering probes confirm
  current `cat(...)`, `copy(...)`, `set(...)`, and `push(...)` still lower through current helper names, while
  retired value-position helper-looking calls such as `concat(...)`, `a(...)`, and `scalaref(...)` use the same
  generic unsupported-helper sentinel path as an invented unknown helper.

  **Boundary:** This is the Perl source closeout leaf. Standalone unregistered function-shaped statements remain
  the existing raw compatibility debt documented in the mdBook; active test/tool/spec fixture migration remains
  owned by `.4`. The next frontier is `NONCURRENT-HELPER-CODE-PURGE.3` for Rust source recognition/diagnostic
  path cleanup.

  **Verification:** Exact retired-helper call-shape scans over Perl source, direct current-helper and retired-helper
  behavior probes, `perl -c perl/LinkedSpec.pm`, `perl -c -Iperl t/noncurrent_helper_metadata.t`,
  `prove -q -Iperl t/noncurrent_helper_metadata.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t
  t/trace_actionir_pipeline.t`, and `PERL5LIB= prove -q -Iperl t/phase0_regression.t` (`1027` tests) pass.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.2.3 — purge Perl helper metadata names**
  (DONE Perl contract/canonical metadata name cleanup; broader Perl source purge scans still active).

  **Change:** Raw-Perl passthrough ActionIR contracts no longer publish exact retired helper names through
  diagnostic metadata. Lexical declaration and raw assignment compatibility events now use neutral `raw_*`
  diagnostic labels instead of `declare` / `assign`, and `t/noncurrent_helper_metadata.t` locks contract IDs,
  diagnostic names, rewrite metadata, canonical events, and unsupported-helper events against the
  `SPEC-FORMAT-TERSE.8` retired helper set.

  **Boundary:** This slice is metadata-only. It preserves raw-Perl compatibility behavior and does not claim the
  entire Perl purge is closed. The next frontier is `NONCURRENT-HELPER-CODE-PURGE.2.4` for broader Perl source
  purge scans and current/unknown-helper behavior probes before Rust source work.

  **Verification:** `perl -c -Iperl perl/LinkedSpec/ActionIR/Contracts.pm`, `perl -c -Iperl
  t/noncurrent_helper_metadata.t`, `prove -q -Iperl t/noncurrent_helper_metadata.t`, focused exact metadata scan,
  `prove -q -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t
  t/noncurrent_helper_metadata.t`, and `PERL5LIB= prove -q -Iperl t/phase0_regression.t` (`1027` tests) pass.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.2.1 — purge Perl current helper compatibility**
  (DONE Perl current-helper/source-owner cleanup; broader Perl metadata/source purge still active).

  **Change:** Perl current `cat(...)`, `copy(...)`, `set(...)`, and `push(...)` lowering now stays on current
  method/contract names. Removed the old normalization/compatibility paths in the current string/copy/assignment
  family, deleted the removed append-helper scanner/contract/lowerer branches, and renamed the current explicit
  append lowerer/dependency to `push` terminology. AST tests now fabricate current helper AST nodes and expect the
  current `__ls_cat_*` generated local names. The current `set(...)` owner also handles slash-regex payloads
  without routing through an old normalized method name, and the bootstrap classifier no longer whitelists deleted
  current-helper-family spellings.

  **Boundary:** This slice does not claim the whole Perl purge is done. Declaration, return-family, short-wrapper,
  capture/named-map, Rust, active fixture/tool/spec, and historical doc cleanup remain in
  `NONCURRENT-HELPER-CODE-PURGE`. The next frontier is `NONCURRENT-HELPER-CODE-PURGE.2.2`.

  **Verification:** Syntax checks passed for touched Perl ActionIR/RuleIR owners. `prove -q -Iperl
  t/actionir_ast_parser.t`, `prove -q -Iperl t/trace_actionir_compact_lowerers.t`, direct current-helper lowering
  probes, `PERL5LIB= prove -q -Iperl t/phase0_regression.t` (`1..1028`), and a focused deleted-spelling scan over
  touched Perl/test paths passed.

- 2026-07-09: **NONCURRENT-HELPER-CODE-PURGE.1 — split code purge task tree**
  (DONE ownership/inventory split; no parser/runtime code edited in this slice).

  **Change:** Added `docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md` to own the director directive that
  non-current helper spellings must be deleted from Perl/Rust code surfaces rather than preserved as
  name-specific compatibility or diagnostic paths. Read-only scans split the work into Perl source cleanup,
  Rust source cleanup, active test/tool/spec fixture migration, and final no-drift verification.

  **Boundary:** This is task ownership and inventory only. It does not yet remove Perl or Rust source paths.
  The next frontier is `NONCURRENT-HELPER-CODE-PURGE.2` for Perl source recognition/diagnostic path removal.

  **Verification:** Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and `specs` identified
  the owner categories and false-positive classes. `git diff --check`, memory architecture, Knowledge Map,
  task-tree metadata, doctrine gates, and mdBook build pass.

- 2026-07-09: **DART-BACKEND-PARITY.3.2 — add Dart ActionIR contract resolver**
  (DONE current helper/control contract resolution; function registry compilation still deferred).

  **Change:** Added Dart ActionIR contract resolver APIs over typed helper/action AST nodes. The resolver
  records current canonical helper/control contracts for calls, receiver methods, structural assignments,
  controls, nested arguments, block values, shapes, and access expressions. Function registry validation now
  shares the same current helper/control name table, and non-current helper-looking calls diagnose
  generically instead of falling through to host-language calls.

  **Boundary:** This is still frontend/contract resolution. It does not build the staged function-body
  registry, compile specs into runtime state, execute helper/action semantics, or compare corpus outputs.
  The Dart frontier is `DART-BACKEND-PARITY.3.3`; the director also requested a separately owned Perl/Rust
  source purge after this dirty Dart leaf is committed clean.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  `dart test`, `dart run bin/linkedspec_dart.dart --help`,
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`,
  `dart run bin/corpus_runner.dart --help`, Dart-tree non-current-spelling scan, `git diff --check`, memory
  architecture, Knowledge Map, task-tree metadata, doctrine gates, and mdBook build pass.

- 2026-07-09: **DART-BACKEND-PARITY.3.1 — add Dart ActionIR AST parser**
  (DONE typed helper/action AST parser; helper-contract mapping and runtime behavior still deferred).

  **Change:** Added Dart ActionIR AST node classes and parser entrypoints. `parseActionBlock(...)`,
  `parseActionStatement(...)`, and `parseActionExpression(...)` now produce typed nodes for calls,
  literals, variables, indexed/nested access, shape literals, scalar/array/hash/nested assignments,
  expression-valued blocks, attached control flow, receiver chains, trailing block arguments, and standalone
  value-drop statements. Unsupported expressions remain structural `raw_perl` nodes for later diagnostics.

  **Boundary:** This is parsing only. It does not map helper families to canonical contracts, emit
  current-contract diagnostics, build compiled-spec state, execute helper/action semantics, or compare corpus
  outputs. The next frontier is `DART-BACKEND-PARITY.3.2`.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  and `dart test` pass. Full repo gates are run during commit closeout.

- 2026-07-09: **DART-BACKEND-PARITY.2.4 — integrate Dart function shell projection**
  (DONE spec-returned function-definition projection; helper/action AST and runtime behavior still deferred).

  **Change:** Added `projectUserFunctionDefinitionAsts(...)` and
  `parseSpecWithUserFunctionDefinitionAsts(...)` in Dart. The projection consumes
  `function_definition` / `function_definition_error` nodes returned by
  `specs/user_function_definition.spec`, validates source/body spans and staged sidecars, normalizes
  source-order `parent_ast_path` plus deterministic `body_parse_job` ids, strips returned definition
  spans while preserving line layout, and attaches ordered `FunctionDefinition` records before rule parsing.
  `StagedParseJob` now round-trips function-body metadata fields.

  **Boundary:** Dart still does not execute `specs/user_function_definition.spec` itself and does not
  raw-scan top-level `fn` source as a fallback. Until the Dart runtime can execute `.spec` grammars, the
  semantic input is the owning spec's returned AST node list. The next frontier is `DART-BACKEND-PARITY.3.1`
  for typed helper/action AST parsing.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  `dart test`, `dart run bin/linkedspec_dart.dart --help`,
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
  `dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
  regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **DART-BACKEND-PARITY.2.3 — add Dart frontend validation**
  (DONE AST validation; top-level function-shell extraction and runtime behavior still deferred).

  **Change:** Added `validateSpec(...)` for Dart source ASTs. It rejects missing top rules, duplicate labels,
  duplicate/colliding function records, invalid function parameters, raw malformed body lines, mixed action/blind
  edge families, grouped action targets without a shared block, undefined targets, out-of-range regex slots, and
  lightweight regex structural errors. Strict mode adds unused-rule rejection.

  **Boundary:** This validates parsed source ASTs only. It does not parse top-level `fn` shells from source,
  compile helper/action AST, execute runtime semantics, or compare corpus outputs. The next frontier is
  `DART-BACKEND-PARITY.2.4`.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  `dart test`, `dart run bin/linkedspec_dart.dart --help`,
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
  `dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
  regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **DART-BACKEND-PARITY.2.2 — implement Dart spec parser**
  (DONE core rule parser; validation/function-shell/runtime behavior still deferred).

  **Change:** Added the Dart `parseSpec(...)` source parser for rule paragraphs, headers/modes, header-rest
  body elements, regex slots, lifecycle blocks, action/blind-call edges, action-edge fluent continuations,
  receiver-fluent `when/otherwise` blocks, split/conditional markers, comments, raw fallback lines, and nested
  block boundaries. Parser tests cover focused Rust-compatible seams, all shipped `specs/*.spec`, and rule-only
  corpus `input.spec` files.

  **Boundary:** Strict frontend validation remains `DART-BACKEND-PARITY.2.3`; top-level `fn` definition
  extraction/staging remains `DART-BACKEND-PARITY.2.4`; no compiler/runtime/corpus output comparison was added.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  `dart test`, `dart run bin/linkedspec_dart.dart --help`,
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
  `dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
  regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **DART-BACKEND-PARITY.2.1 — define Dart frontend AST data types**
  (DONE source-level AST/data contracts; parser still deferred).

  **Change:** Added Dart data types for `.spec` files, function definitions, source spans, staged parse
  jobs, rules, rule headers, rule modes, body-element variants, edge targets, and fluent calls. Added JSON
  round-trip tests and `RuleMode` helper parity tests.

  **Boundary:** No parser, compiler, runtime, corpus output comparison, or helper/action lowering logic was
  added. The next frontier is `DART-BACKEND-PARITY.2.2` for `.spec` parsing.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  `dart test`, `dart run bin/linkedspec_dart.dart --help`,
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`, and
  `dart run bin/corpus_runner.dart --help` pass. `git diff --check`, memory architecture, Knowledge Map
  regeneration/check, task-tree metadata, doctrine gates, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **DART-BACKEND-PARITY.1.3 — add Dart corpus manifest IO scaffold**
  (DONE corpus manifest loading/drift guard; no parser/runtime execution yet).

  **Change:** Added Dart manifest/corpus IO scaffolding and tests. The loader validates manifest shape,
  duplicate/invalid case names, missing and stale fixture directories, required fixture files, and
  `expected.json` syntax. The corpus runner now accepts `--corpus <path>` and reports the loaded fixture
  count for the 99-fixture checked-in corpus.

  **Boundary:** This is IO validation only. It does not parse `.spec`, compile, execute, compare expected
  output, or claim corpus parity. The next frontier is `DART-BACKEND-PARITY.2.1` for frontend AST/data
  types.

  **Verification:** `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos --fatal-warnings`,
  `dart test`, `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus`,
  `dart run bin/corpus_runner.dart --help`, and `dart run bin/linkedspec_dart.dart --help` pass.
  `git diff --check`, memory architecture, Knowledge Map regeneration/check, task-tree metadata, doctrine
  gates, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **DART-BACKEND-PARITY.1.2 — create Dart scaffold smoke package**
  (DONE minimal Dart package scaffold; parser/runtime/corpus semantics still deferred).

  **Change:** Added the repo-owned `dart/` package with metadata, committed lockfile, analyzer options,
  package README, public scaffold API, CLI smoke entrypoint, corpus-runner entrypoint, and a
  `package:test` smoke test. Added Dart tool-state ignores for `.dart_tool/`, `.packages`, and build output.

  **Boundary:** The CLI and corpus-runner are scaffold-only. Manifest IO starts in
  `DART-BACKEND-PARITY.1.3`; parser/compiler/runtime work starts in later leaves.

  **Verification:** `dart pub get`, `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos
  --fatal-warnings`, `dart test`, `dart run bin/linkedspec_dart.dart --help`, and
  `dart run bin/corpus_runner.dart --help` pass. Pub dependency download and analyzer state initialization
  required approved access outside the workspace sandbox. `git diff --check`, memory architecture,
  Knowledge Map regeneration/check, task-tree metadata, doctrine gates, and
  `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **DART-BACKEND-PARITY.1.1 — record Dart toolchain and layout**
  (DONE toolchain/package-layout preflight; no Dart package files created).

  **Change:** Verified `/opt/homebrew/bin/dart` with Dart SDK `3.9.2` on macOS arm64. Flutter is absent
  and non-blocking for the CLI/library backend path. Recorded the planned `dart/` package layout and
  commands for scaffold creation, formatting, analysis, tests, corpus runner, and CLI smoke entrypoint.

  **Boundary:** No source scaffold yet. The next leaf, `DART-BACKEND-PARITY.1.2`, creates the minimal
  package and smoke test.

  **Verification:** Dart command probes passed after one approved `dart --disable-analytics` initialization
  outside the sandbox. `git diff --check`, memory architecture, Knowledge Map, task-tree metadata,
  doctrine gates, and `mdbook build docs/linkedspec-book` pass.

- 2026-07-09: **FUTURE-PARITY-BACKLOG.1.1 — scope Dart backend parity plan**
  (DONE scoping/task-tree/docs ownership; no Dart/backend implementation code change).

  **Change:** Created `docs/tasks/DART-BACKEND-PARITY.md` as the dedicated Dart backend plan.
  The Dart lane starts interpreter-first over typed `.spec` and helper/action AST plus compiled state,
  then runtime/corpus parity. Generated Dart source is deferred to a later proof lane after interpreter
  parity.

  **Boundary:** Planning, roadmap, mdBook, Knowledge Map, and live-doc alignment only. Actual Dart
  code starts under `DART-BACKEND-PARITY.1.1` after SDK/toolchain and package-layout preflight.

  **Verification:** `git diff --check`, memory architecture, Knowledge Map, doctrine,
  task-tree metadata, mdBook build, and `tools/run_ci_local.sh` pass. Local CI includes
  phase0 `1..1028`.

- 2026-07-09: **FUTURE-PARITY-BACKLOG.0 — create future parity backlog**
  (DONE task-tree/decision/docs ownership; no parser/runtime/backend code change).

  **Change:** Created `docs/tasks/FUTURE-PARITY-BACKLOG.md` with seven owned lanes for the
  deferred backlog. ADR `0021` accepts Lua and fixes future backend rollout order as Dart first,
  Julia second, Lua third, each targeting full parity with Perl5 and Rust.

  **Boundary:** Tracking, decision, roadmap, mdBook, Knowledge Map, and live-doc alignment only.
  Actual Dart implementation is now delegated to `DART-BACKEND-PARITY`.

  **Verification:** `git diff --check`, memory architecture, Knowledge Map, doctrine,
  task-tree metadata, mdBook build, and `tools/run_ci_local.sh` pass. Local CI includes
  phase0 `1..1028`.

- 2026-07-08: **SPEC-LANG-REFERENCE.8 — correct top-rule doctrine drift and close language reference**
  (DONE final consistency/closeout; `SPEC-LANG-REFERENCE` closed).

  **Change:** ADR `0010` is the current doctrine: `::` marks the rule entered first, and after entry
  selection `::` and `:` share the same regex/mode/action feature surface. The old no-regex/two-rule
  minimum card is now a superseded historical redirect; mdBook/toolbox/task-tree wording is being
  aligned so the no-regex wrapper reads as a stream-parser idiom only. The language-reference tree is
  closed.

  **Boundary:** Documentation, Knowledge Map, and coordination-state correction only; no parser/runtime
  behavior change.

  **Verification:** Focused Perl probes confirm regex-bearing `Entry::` and selected regex-bearing
  `Body:` forms produce matching default-mode and `AND`-mode outputs. mdBook, Knowledge Map, memory,
  task-tree metadata, doctrine, and whitespace gates pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.7 — add spec-language Knowledge Map cards**
  (DONE KM fact-card coverage; frontier `.8` next).

  **Change:** Added canonical `.spec` language KM cards for output/return shape, regex backend
  features, rule-mode semantics, lifecycle/`retv`, and capture/mark taxonomy. Extended
  `spec-edge-syntax-contract` with action-vs-blind dispatch retrieval keys and summary.

  **Boundary:** No parser/runtime/source or mdBook behavior changed. This is a durable retrieval
  closeout for subjects already documented in the book.

  **Verification:** Required question spot-checks route to the expected fact cards; Knowledge Map
  regeneration and gate pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.6 — add capture/mark marker cross-example**
  (DONE mdBook capture/mark cross-example + thin-spot fixes; frontier `.7` next).

  **Change:** Added a verified marker-form example to `source-boundary-helper-reference.md`
  and `action-and-lifecycle-placement.md`, exercising `@capture_slice`, `@mark(body_start)`,
  `mark_match_start(close_start)`, `capture_slice()`, `capture_from(...)`, and
  `capture_between(...)` together. Corrected placement-sensitive named-mark examples to use
  `mark_here(...)` where exact action-local timing is needed. Added KM fact
  `split-boundary-marker-action-timing`.

  **Boundary:** No parser/runtime/source behavior changed. The slice documents the current
  marker visibility rule and fixes stale documentation examples only.

  **Verification:** Focused `LinkedSpec::Get` probes verify the marker example and corrected
  consume-mode helper-call examples; mdBook, doctrine, task-tree, memory, Knowledge Map, and
  whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.5.5 — add remaining helper-family worked examples**
  (DONE mdBook helper catalog examples; helper-catalog sweep `.5` closed; frontier `.6` next).

  **Change:** Added verified Declaration, Capture/Mark, Entry/Match, Input, and Call examples to
  `helper-contract-catalog.md`. Corrected stale entry-vs-match examples in
  `capture-marks-and-source-locations.md` and `source-boundary-helper-reference.md` to the verified
  ordered-child shape, and added KM fact `entry-match-divergence-verified-shape`.

  **Boundary:** No parser/runtime/source behavior changed. The stale example correction is a documentation
  alignment fix discovered while verifying `.5.5`.

  **Verification:** Focused `LinkedSpec::Get` probes generated the documented outputs for the five
  remaining helper families and the corrected entry-vs-match shape; mdBook, doctrine, task-tree, memory,
  Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.5.4 — add Hash and Control Flow worked examples**
  (DONE mdBook helper catalog examples; frontier `.5.5` next).

  **Change:** Added verified Hash examples to `helper-contract-catalog.md`, covering
  constructor/copy/splice forms, pure and mutating hash updates, sorted views, receiver chains,
  block receivers, and hash-tree traversal. Added verified Control Flow examples for
  inline/marker/attached branches, `switch`, `while`, `next`, `return`, and `return_undef`;
  `exit_now(2)` is descriptor-verified without running the terminating path. Added KM fact
  `hash-helper-odd-arity-current-behavior`.

  **Boundary:** No parser/runtime/source behavior changed. Direct odd-arity `hash(...)`
  behavior normalization is deferred to `.5.4.1` and is not PNT-active unless explicitly
  activated.

  **Verification:** Focused `LinkedSpec::Get` probes generated the documented outputs,
  `call_spec_handler_subst` root-caused the direct odd-arity constructor caveat, and the
  descriptor probe verified `exit_now(2)` metadata; mdBook, doctrine, task-tree, memory,
  Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.5.3 — add Array helper worked examples**
  (DONE mdBook helper catalog examples; frontier `.5.4` next).

  **Change:** Added verified Array helper examples to `helper-contract-catalog.md`, covering
  constructor/copy/splice, count/selectors, edge slices, ordering, membership, split, pipelines,
  mutations, receiver chains, and array-tree traversal. Added KM fact
  `array-helper-return-shape-caveats` for shape-sensitive current Perl forms.

  **Boundary:** No parser/runtime/source behavior changed. Optional behavior normalization for compact
  split/pipeline return caveats is deferred to `.5.3.1` and is not PNT-active unless explicitly
  activated.

  **Verification:** Focused `LinkedSpec::Get` probes generated the documented outputs and confirmed
  the caveats; mdBook, doctrine, task-tree, memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.20 — document lifecycle drift policy**
  (DONE policy/documentation closeout; frontier `.5.3` next).

  **Change:** Recorded ADR `0020`, updated `appendix/runtime-semantics.md`, and refreshed the
  lifecycle drift KM fact so lifecycle final-value/direct-`E` handler-shape drift is a documented
  current Perl-reference caveat until a separately-owned implementation/parity leaf authorizes
  behavior changes.

  **Boundary:** No parser/runtime/source behavior changed. This closes the `.10.5` whole-book
  scorch follow-up and returns the language-reference frontier to helper-catalog Array examples.

  **Verification:** Focused Perl probes reproduce the direct default-rule `I`+regex+`E` drift,
  dispatched child no-return drift, and generated-source omission; mdBook, doctrine, task-tree,
  memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.19 — finalize book scorch**
  (DONE mdBook closeout; frontier `.10.5.20` next).

  **Change:** Fixed the final residual regex-on-`::` mdBook examples in
  `spec-files-and-rule-paragraphs.md`, `helper-contract-catalog.md`, and
  `compiler/pipeline-overview.md`, and corrected the helper-catalog direct value-path output.

  **Boundary:** No parser/runtime/source behavior changed. This closes the planned page-scorch
  sweep and leaves the previously tracked lifecycle handler-shape drift as `.10.5.20`.

  **Verification:** Whole-book regex-on-`::` scans return no matches; focused `LinkedSpec::Get`
  probes cover the corrected recursion, direct value-path, array mutation, and function-registry
  examples; mdBook, doctrine, task-tree, memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.18 — verify portmap walkthrough outputs**
  (DONE mdBook verification; frontier `.10.5.19` next).

  **Change:** Rechecked the five `portmap.spec` output-shape examples against the Perl
  reference backend. The current walkthrough already shows the live nested JSON shapes, so
  no mdBook source rewrite was needed.

  **Boundary:** No parser/runtime/source behavior changed. This is a shipped-spec walkthrough
  verification closeout for the whole-book scorch.

  **Verification:** `LinkedSpec::get_parser('portmap')` probes cover bare, bit, slice,
  constant, and concatenation cases; mdBook, doctrine, task-tree, memory, Knowledge Map,
  and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.17 — fix tablegrep walkthrough outputs**
  (DONE mdBook correction; frontier `.10.5.18` next).

  **Change:** Replaced tablegrep simple-term and grouped-expression output examples with
  verified JSON from `specs/tablegrep.spec`, and refreshed the descriptor helper list.

  **Boundary:** No parser/runtime/source behavior changed. This is a shipped-spec walkthrough
  documentation correction for the whole-book scorch.

  **Verification:** `LinkedSpec::get_parser('tablegrep')` probes cover both outputs; descriptor
  metadata reports five ready rules and zero blocked/compat/raw/unresolved counts; mdBook,
  doctrine, task-tree, memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.16 — fix runtime semantics examples**
  (DONE mdBook correction; frontier `.10.5.17` next).

  **Change:** Reworked `appendix/runtime-semantics.md` §5.5/§5.6 examples to use
  no-regex `Top::` wrappers plus normal regex-owning body rules, folding the `.10.4`
  Pair target into this leaf.

  **Boundary:** No parser/runtime/source behavior changed. This is a runtime semantics
  documentation correction for the whole-book scorch.

  **Verification:** Focused `LinkedSpec::Get` probes cover scalar, proof-array, Pair,
  object, and manifest outputs; page scan finds no regex under `::`; mdBook, doctrine,
  task-tree, memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.15 — fix formal grammar examples**
  (DONE mdBook correction; frontier `.10.5.16` next).

  **Change:** Reworked `appendix/formal-grammar.md` §1 and §12 examples so no top `::`
  rule owns regex slots, and the complete example defines all ordered-sequence child targets.

  **Boundary:** No parser/runtime/source behavior changed. This is a formal grammar appendix
  documentation correction for the whole-book scorch.

  **Verification:** Focused `LinkedSpec::Get` probes cover the paragraph example plus
  `DemoParser`, `SecondChild`, and `ThirdChild`; appendix scan finds no regex under `::`;
  mdBook, doctrine, task-tree, memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.14 — fix remaining DSL examples**
  (DONE mdBook correction/audit; frontier `.10.5.15` next).

  **Change:** Reworked the remaining DSL-page examples so Token, Value, and Items use
  no-regex entry/wrapper rules plus normal regex-owning matcher rules. Reduced the
  `Toplevel:AND+` structured-style sketch to the lifecycle block fragment it demonstrates.

  **Boundary:** No parser/runtime/source behavior changed. `actionir-lowering-mental-model.md`
  was audited and left unchanged because the relevant blocks are helper/pipeline fragments.

  **Verification:** Focused `LinkedSpec::Get` probes cover Token, Value, and Items singleton/pair/list
  outputs; the four-page scan finds no regex under `::`; mdBook, doctrine, task-tree, memory,
  Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.13 — fix value-container flow examples**
  (DONE mdBook correction; frontier `.10.5.14` next).

  **Change:** Reworked `dsl/value-container-flow-helper-reference.md` so Token, FieldList,
  Node, Sequence, and Kind examples use no-regex wrappers or entry rules with explicit normal
  matcher rules for regex-bearing work.

  **Boundary:** No parser/runtime/source behavior changed. This is a documentation correction
  for the active whole-book scorch.

  **Verification:** Five focused `LinkedSpec::Get` probes cover the replacement snippets; page
  scan finds no regex under `::`; mdBook, doctrine, task-tree, memory, Knowledge Map, and
  whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.12 — fix source-boundary examples**
  (DONE mdBook correction; frontier `.10.5.13` next).

  **Change:** Reworked `dsl/source-boundary-helper-reference.md` so the source-boundary examples use
  no-regex `Top::AND` blind-call wrappers plus normal regex-owning rules for Tuple, Block, Paren,
  Pair, Body, AtEnd, and entry-vs-match examples.

  **Boundary:** No parser/runtime/source behavior changed. Delimiter-body examples are now explicitly
  seek-shaped, matching the previously recorded capture-slice caveat.

  **Verification:** Seven focused `LinkedSpec::Get` probes cover the replacement snippets; page scan
  finds no regex under `::`; mdBook, doctrine, task-tree, memory, Knowledge Map, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.11 — fix declaration helper examples**
  (DONE mdBook correction; frontier `.10.5.12` next).

  **Change:** Reworked `dsl/declaration-helper-reference.md` so the accumulator and metadata
  examples use no-regex `::` wrappers with regex-owning normal rules. `List::` owns state and
  calls `Item:`, while `Top::` dispatches to `Token:` for the metadata example.

  **Boundary:** No parser/runtime/source behavior changed. This is a documentation correction for
  the active whole-book scorch.

  **Verification:** Focused `LinkedSpec::Get` probes cover the documented list and token outputs;
  page scan finds no regex under `::`; mdBook, doctrine, task-tree, memory, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.10 — fix capture and entry-match examples**
  (DONE mdBook + Knowledge fact correction; frontier `.10.5.11` next).

  **Change:** Reworked `dsl/capture-marks-and-source-locations.md` so the capture example uses a
  no-regex `Top::` wrapper plus normal `Body:` delimiter rule, and the entry-vs-match example uses
  a no-regex blind-call wrapper plus normal `Call:`/`Inner:` matcher rules.

  **Boundary:** No parser/runtime/source behavior changed. The slice records the Perl seek-vs-consume
  delimiter-capture authoring boundary in Knowledge fact `perl-capture-slice-delimiter-seek-boundary`.

  **Verification:** Focused `LinkedSpec::Get` probes cover the seek-mode capture output and the
  `greet`/`world` entry-vs-match split; page scan finds no regex under `::`; mdBook, Knowledge Map,
  doctrine, task-tree, memory, and whitespace checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.9 — fix action and lifecycle placement examples**
  (DONE mdBook + Knowledge fact correction; frontier `.10.5.10` next).

  **Change:** Reworked `dsl/action-and-lifecycle-placement.md` so regex-bearing examples use normal
  `:` rules, entry-match transforms use `I { ... }` plus `entry_*`, local-slot action edges use `match_*`,
  and lifecycle examples use explicit `return(...)` instead of implying direct `E` finalization.

  **Boundary:** No parser/runtime/source behavior changed. The slice documents an observed current Perl
  lifecycle handler-shape caveat in Knowledge fact `perl-lifecycle-final-value-e-drift`.

  **Verification:** Focused `LinkedSpec::Get` probes cover entry-match, later-slot action, explicit lifecycle
  return, and Pair slot-flow examples; page scan finds no regex under `::`; mdBook, Knowledge Map, and whitespace
  checks pass.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.8 — fix blind-call orchestration examples**
  (DONE mdBook correction; frontier `.10.5.9` next).

  **Change:** Kept no-regex blind-call `::` wrapper examples intact in
  `user-model/blind-calls-and-parser-orchestration.md`, converted regex-owning action-edge examples
  to single-colon labels, and clarified the mixed-edge negative example.

  **Boundary:** No parser/runtime/source behavior changed. This is a documentation correction.

  **Verification:** Focused scan finds no regex slot under a `::` header; the wrapped mixed-edge probe
  logs the expected validation error; mdBook build passes.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.7 — fix regex chapter examples**
  (DONE mdBook correction; frontier `.10.5.8` next).

  **Change:** Reworked `user-model/regex-in-spec.md` so keyword, numbered-capture, named-capture, and
  compaction examples use no-regex `Top::` wrappers plus single-colon regex-bearing rules.

  **Boundary:** No parser/runtime/source behavior changed. Capture-indexing facts remain the same:
  numbered groups are 0-based, captures-only, and compacted; named groups remain stable.

  **Verification:** `LinkedSpec::Get` probes confirm keyword, pair, named capture, numbered-compaction,
  and named-compaction outputs; remaining `::` labels on the page are no-regex wrappers; mdBook build passes.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.6 — fix rule mode and parse mode examples**
  (DONE mdBook correction; frontier `.10.5.7` next).

  **Change:** Reworked `user-model/rule-modes-and-parse-modes.md` so regex-owning mode examples use
  single-colon labels, `::` examples are no-regex entry/dispatcher shapes, and the parse-mode
  `Top:: /foo/` snippets are now a verified `Top::` + `Word:` wrapper.

  **Boundary:** No parser/runtime/source behavior changed. This is a documentation correction for the
  active whole-book scorch.

  **Verification:** `LinkedSpec::Get` probes confirm the documented token-stream and `seek`/`consume`
  outputs; remaining `::` labels on the page are no-regex entry/dispatcher examples; mdBook build passes.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.5 — fix spec file paragraph examples**
  (DONE mdBook + Knowledge fact; frontier `.10.5.6` next).

  **Change:** Rewrote `user-model/spec-files-and-rule-paragraphs.md` examples to the verified 2-rule
  idiom and replaced the malformed bare `label:` block with valid quoted `"label:"` helper content plus
  the exact validation-error note.

  **Boundary:** No parser/runtime/source behavior changed. This is a documentation correction plus the
  narrow Knowledge fact `rule-starts-open-block-validation`.

  **Verification:** Four replacement snippets compile/run through `LinkedSpec::Get`; the bad bare-label
  probe reports `Rule definition not allowed inside open block`; mdBook, memory, Knowledge, doctrine,
  task-tree, and whitespace gates cover the final committed slice.

- 2026-07-08: **SPEC-LANG-REFERENCE.10.5.4.1 — reactivate book scorch**
  (DONE metadata-only activation; frontier `.10.5.5` next).

  **Change:** Resolved the old `SPEC-LANG-REFERENCE` scorch pause by user directive and pointed the durable
  frontier at `.10.5.5`.

  **Boundary:** No parser/runtime/source/book behavior changed. The next book-content work is still pending:
  `user-model/spec-files-and-rule-paragraphs.md` malformed label-in-block plus `Top::AND` sketches.

  **Verification:** Memory architecture, task-tree metadata, doctrine registry, and whitespace gates cover this
  coordination-only slice.

- 2026-07-08: **TASK-TREE-METADATA-HYGIENE.4 — reconcile closeout commit metadata**
  (DONE metadata-only task-tree handoff cleanup; tree CLOSED).

  **Change:** Reconciled `docs/tasks/SPEC-SOURCE-TERSE-CLOSEOUT.md` so the completed `.1` leaf records its landed
  commit instead of saying commit execution is pending.

  **Boundary:** No parser/runtime/source/book behavior changed. This is a continuity cleanup for the just-closed
  root-spec closeout, not a broad historical task-file backfill.

  **Verification:** Focused stale pending-commit scan found the contradiction in the closeout task file; memory,
  task-tree, doctrine, and whitespace gates cover the final committed slice.

- 2026-07-08: **SPEC-SOURCE-TERSE-CLOSEOUT.1 — close root spec terse source**
  (DONE source-format closeout; tree CLOSED).

  **Change:** Completed the all-root `specs/*.spec` terse source closeout. Remaining root-spec host-action residues
  were migrated in `hlink_substitution`, `pplugin`, `Lispish`, `ebnf`, `simenv`, and `vhdl`. Hlink bracket payloads
  are now neutral strings, and `pplugin.spec` now returns plugin body text while `perl/PPlugin.pm` preserves legacy
  coderef execution for `.plg` callers.

  **Boundary:** This closes source-format doubt for shipped specs. It does not make dynamic `.plg` execution a
  backend-neutral target, and it does not churn valid current syntax merely to use every newer terse feature.

  **Verification:** Retired-helper/host-residue scans are clean; all 21 shipped descriptors report `1.0000 0 0`;
  focused hlink/pplugin probes pass; oracle generation emits 99 fixtures; Rust
  `oracle_corpus_matches_perl_reference` passes over the 99-fixture manifest.

- 2026-07-08: **RUST-STATUS-DRIFT-SYNC.1 — sync Rust status counts**
  (DONE docs-only drift correction; tree CLOSED).

  **Change:** Registered a narrow owner for startup-discovered Rust status drift, then synchronized current-facing
  `ROADMAP.md`, `rust/README.md`, and mdBook shipped-corpora wording to the current 97-fixture Rust oracle, 21
  shipped specs, and phase0 `1..1028`.

  **Boundary:** No parser/runtime behavior or corpus data changed. Historical earlier-count task/log entries remain
  unchanged when they describe the baseline at the time of their slice.

  **Verification:** Focused current-facing stale-count scans, manifest `case_count` check, shipped-spec count check,
  mdBook build, memory architecture, Knowledge Map, doctrine, task-tree metadata, and whitespace gates pass.

- 2026-07-08: **DOCTRINE-ENFORCEMENT-ADOPT.3.3 — close task-acceptance no-drift**
  (DONE docs/KM/no-drift closeout; `DOCTRINE-ENFORCEMENT-ADOPT` CLOSED).

  **Change:** Reconciled the shipped `TASK-ACCEPTANCE` boundary across `DOCTRINE_ENFORCEMENT.md`, `TOOLBOX.md`,
  mdBook local-CI/task-tree ownership wording, ADR `0009`, Knowledge Map source facts, task-tree index, and live
  docs.

  **Boundary:** No executable behavior changed. The gate remains a staged evidence-shape check. The docs now spell
  out the false-positive path (`git diff --cached --name-only`, then unstage, update the real owning task leaf, or
  split the work) and the known limit (ownership/evidence shape, not truthfulness or historical completeness).

  **Verification:** No-drift scans, Knowledge Map regeneration, doctrine driver, memory architecture, task-tree
  metadata, mdBook build, and whitespace checks pass.

- 2026-07-08: **DOCTRINE-ENFORCEMENT-ADOPT.3.2 — implement task-acceptance evidence gate**
  (DONE `TASK-ACCEPTANCE` staged evidence-shape gate; frontier `.3.3` closeout next).

  **Change:** Added executable `scripts/check_diagnosis_evidence.sh`, registered it in
  `scripts/check_doctrines.sh`, and synced the doctrine standard, `TOOLBOX.md`, local gate audit, mdBook local-CI
  chapter, ADR `0009`, Knowledge Map source facts, task tree, and live docs.

  **Boundary:** The check is staged-set scoped. It governs code/spec/test/tooling paths and checks for a completed
  task-file acceptance checklist with LinkedSpec-tool signatures; it does not execute arbitrary Markdown commands.

  **Verification:** Direct script check, staged self-check, doctrine driver, memory architecture, task-tree
  metadata, mdBook build, and whitespace checks pass.

- 2026-07-08: **DOCTRINE-ENFORCEMENT-ADOPT.3.1 — split evidence gate before code**
  (DONE scope/signature design split; frontier `.3.2` implementation next).

  **Change:** Reactivated the deferred evidence/task-acceptance doctrine by splitting `.3` into a narrow staged
  implementation sequence. `.3.2` now owns `scripts/check_diagnosis_evidence.sh` plus `TASK-ACCEPTANCE`
  registration; `.3.3` owns docs/KM/no-drift closeout after the checker exists.

  **Boundary:** No parser/runtime, corpus, mdBook behavior, or gate behavior changed in this slice. The planned
  checker is intentionally staged-set/checklist-shape scoped to avoid broad historical false positives.

  **Verification:** Bootstrap/read review, Knowledge Map search for existing evidence-gate facts, relevant
  enforcement owner paths read, task-tree split review, memory architecture, doctrine, task-tree metadata, and
  whitespace checks pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.13.5 — close parent terse task tree**
  (DONE metadata-only parent task-tree status reconciliation; `SPEC-FORMAT-TERSE` CLOSED).

  **Change:** Reconciled the parent `SPEC-FORMAT-TERSE` task tree from `active` with an empty frontier to
  `done` / `closed`. Stale internal split-container rows that still looked active now read as historical
  done/closed rows.

  **Boundary:** No parser/runtime, corpus, or behavioral mdBook semantics changed.

  **Verification:** Parent-status scans, mdBook build, Knowledge Map regeneration/check, memory architecture,
  doctrine, task-tree metadata, and whitespace gates pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.13.4 — close array-tree traversal drift**
  (DONE docs/KM/oracle/no-drift closeout; `.13` CLOSED/exhausted).

  **Change:** Closed the array-tree traversal activity after `.13.2` Perl reference support and `.13.3` Rust/oracle
  parity. Live docs, task-tree rows, roadmap state, mdBook status/helper/formal/backend pages, Knowledge Map facts,
  and the generated oracle manifest now agree on the shipped 97-fixture array-tree traversal surface.

  **Boundary:** No parser/runtime or corpus semantics changed in this closeout slice.

  **Verification:** Stale frontier/pending-parity scans, mdBook build, Knowledge Map regeneration/check, memory
  architecture, doctrine, task-tree metadata, and whitespace gates pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.13.3 — implement Rust array-tree traversal**
  (DONE Rust parser/runtime parity plus generated oracle fixture; `.13.4` closeout is now complete above).

  **Change:** Rust now accepts and executes array-valued receiver `walk_leaves`, `map_leaves`, and
  `reduce_leaves(initial)` attached-block traversal through the same receiver trailing-block chain used for
  hash-tree traversal. Hash receivers keep `.12` sorted-key traversal; array receivers recurse through nested
  arrays by index, treat hashes as leaves, bind scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`,
  and return `undef` without callbacks for scalar receivers.

  **Oracle:** `tools/gen_oracle_corpus.pl` regenerated the corpus to **97** fixtures, adding
  `terse_13_3_array_tree_traversal_receiver_blocks`; Rust `oracle_corpus_matches_perl_reference` passes.

  **Verification:** Focused Rust parser tree traversal tests, focused `.13.3` runtime tests, focused `.12.3`
  hash-tree runtime regressions, oracle regeneration, and the 97-fixture Rust corpus oracle all pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.13.2 — implement Perl array-tree traversal**
  (DONE Perl reference implementation; `.13.3` Rust/oracle parity is now complete above).

  **Change:** Perl now lowers receiver `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` through shared
  tree traversal dispatch. Hash receivers keep the `.12` sorted-key semantics; array receivers traverse nested
  arrays depth-first by zero-based index, treat hashes as leaves, bind scoped `value`, `index`, `path`, `depth`,
  and reduce-only `acc`, and return `undef` without callbacks for scalar receivers.

  **Boundary:** Rust runtime parity and the generated oracle fixture were split to `.13.3`, and final
  docs/KM/no-drift closeout was split to `.13.4`; both are now complete.

  **Verification:** `MethodLowering.pm` syntax check, focused lowering/runtime/source-residue probes, parser AST
  test, and full Perl phase0 pass (`Files=1, Tests=1028`, `Result: PASS`), plus Knowledge/live-doc sync.

- 2026-07-08: **SPEC-FORMAT-TERSE.13.1 — split array-tree traversal**
  (DONE spec-first split; frontier `.13.2` Perl reference implementation).

  **Change:** Reactivated and split the array-tree traversal backlog item before parser/runtime code. The accepted
  surface is receiver-only `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` on array-valued receivers,
  with nested arrays as interior nodes, scalar/hash leaves, index-order traversal, and scoped callback bindings
  `value`, `index`, `path`, `depth`, and reduce-only `acc`.

  **Boundary:** No parser/runtime behavior changed. Perl implementation was `.13.2`; Rust/oracle parity was
  `.13.3`; docs/KM/no-drift closeout was `.13.4`. All are now complete.

  **Verification:** Knowledge Map retrieval, task-tree split review, Knowledge fact creation/regeneration,
  memory architecture, doctrine, task-tree metadata, and whitespace checks pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.10.1 — ratify dynamic hash-literal keys**
  (DONE spec-ratification/no-engine-change closeout; `.10` CLOSED).

  **Change:** The direct hash-literal key contract is now explicit in the task tree, mdBook, and Knowledge Map:
  `{ key_expr : value_expr }` evaluates the key expression at runtime. Bare keys are scalar reads, quoted keys are
  fixed fields, computed helper expressions can supply keys, and old `=>` remains retired.

  **Boundary:** No parser/runtime behavior changed. This slice records current Perl/Rust behavior and moves the
  remaining `SPEC-FORMAT-TERSE` frontier to `.13` under the user's exhaustion directive.

  **Verification:** LinkedSpec lowering/runtime probes, Rust parser/runtime code read, mdBook, Knowledge Map,
  memory architecture, doctrine, task-tree metadata, and whitespace checks pass.

- 2026-07-08: **MEMORY-PUSH-POINTER-SYNC.1 — remove stale push threshold claim**
  (DONE continuity-only correction; tree CLOSED).

  **Change:** Replaced the stale `MEMORY.md` claim that the branch was over the 300-commit push threshold with
  policy-oriented guidance to check `git status -sb` for the live ahead count and avoid pushing mid-PNT unless
  explicitly instructed or deliberately invoking the threshold policy.

  **Boundary:** No parser/runtime behavior, corpus data, roadmap status, or mdBook source changed. The known
  post-commit `latest_commit` hash warning remains soft and unchanged.

  **Verification:** Focused stale-threshold scan, live branch-status check, memory architecture, doctrine,
  task-tree metadata, and whitespace checks pass.

- 2026-07-08: **ROADMAP-POST-12-DRIFT-SYNC.1 — sync long roadmap baseline**
  (DONE docs-only drift correction; tree CLOSED).

  **Change:** Registered a narrow owner for startup-discovered `ROADMAP.md` drift, then synchronized current-state
  roadmap references to the post-`SPEC-FORMAT-TERSE.12.4` baseline: phase0 `PASS 1..1027` and the 96-fixture Rust
  interpreter oracle.

  **Boundary:** No parser/runtime behavior, corpus data, or mdBook source changed. The mdBook was reviewed and was
  already current for the `1..1027` / 96-fixture hash-tree traversal state.

  **Verification:** Focused stale-count scans, mdBook build, memory architecture, Knowledge Map, doctrine,
  task-tree metadata, and whitespace checks pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.12.4 — close hash-tree traversal drift**
  (DONE final no-drift closeout; `SPEC-FORMAT-TERSE.12` exhausted).

  **Change:** Closed the hash-tree traversal lane after verifying mdBook helper/reference/formal/backend-handoff
  coverage, Knowledge Map retrieval, live docs, task-tree state, and the 96-fixture oracle manifest agree on
  `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` semantics. No parser/runtime behavior changed.

  **Boundary:** No current PNT-eligible `.12` leaf remains. `SPEC-FORMAT-TERSE.10` and `.13` remain deferred
  unless explicitly activated.

  **Verification:** No-drift scans covered method names, callback bindings, traversal semantics, trailing-block
  boundary wording, historical 95-fixture references, and the current 96-fixture oracle state. mdBook build,
  memory architecture, Knowledge Map, doctrine, and whitespace gates pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.12.3 — implement Rust hash-tree traversal**
  (DONE Rust parser/runtime parity and 96th generated oracle fixture; frontier `.12.4` final no-drift next).

  **Change:** Rust now parses and executes receiver attached-block hash-tree traversal methods:
  `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)`. Runtime traversal is sorted depth-first over hash
  keys, arrays are leaves, callbacks get scoped `value`/`key`/`path`/`depth` plus reduction `acc`, non-hash
  receivers return `undef` without callbacks, malformed calls diagnose explicitly, and hash-family continuations
  after `walk_leaves` / `map_leaves` work through the existing receiver dispatcher.

  **Boundary:** Public helper examples, Knowledge Map facts, and current status/count docs now name the shipped
  hash-tree traversal surface and 96-fixture Rust oracle boundary. `.12.4` remains the final no-drift
  scan/closeout leaf.

  **Verification:** Focused Rust parser/runtime tests pass; the generated oracle corpus has 96 fixtures; the full
  Rust corpus oracle passes over all 96 fixtures. mdBook build, memory architecture, Knowledge Map, doctrine, and
  whitespace gates pass.

- 2026-07-08: **SPEC-FORMAT-TERSE.12.2 — implement Perl hash-tree traversal**
  (DONE Perl reference implementation; frontier `.12.3` Rust parity and oracle next).

  **Change:** Perl now accepts and lowers receiver attached-block hash-tree traversal methods:
  `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)`. Traversal is sorted depth-first over hash keys,
  arrays are leaves, callbacks get scoped `value`/`key`/`path`/`depth` plus reduction `acc`, non-hash receivers
  return `undef` without callbacks, and malformed calls produce explicit unsupported-helper diagnostics.

  **Boundary:** Rust parser/runtime parity and generated oracle fixtures remain next in `.12.3`. Full public
  helper examples and Knowledge Map closeout remain `.12.4`; current mdBook status counts only were refreshed to
  phase0 `1..1027`.

  **Verification:** Perl syntax checks pass; `t/actionir_ast_parser.t` passes; full phase0 passes 1027 tests.

- 2026-07-08: **SPEC-FORMAT-TERSE.12.1 — activate hash-tree traversal split**
  (DONE tracking/spec split; frontier `.12.2` Perl reference implementation next).

  **Change:** Reactivated `SPEC-FORMAT-TERSE.12` and split the hash-tree attached-block traversal lane before code.
  The MVP is receiver-only `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` with immediate attached
  blocks, sorted depth-first hash traversal, scoped callback bindings, array leaves, and explicit Perl/Rust/docs
  child leaves.

  **Boundary:** No parser/runtime behavior changed and no public mdBook content changed.

  **Verification:** Memory architecture, doctrine, task-tree metadata, and diff checks pass.

- 2026-07-08: **STAGED-LINKED-PARSING.6 — close staged linked parsing tree**
  (DONE metadata closeout; tree CLOSED).

  **Change:** `STAGED-LINKED-PARSING` is now marked done and moved from Active to Completed in the central
  task-tree index. Its stale PNT pointer to already-closed `TOP-RULE-AS-NORMAL.3.2` now routes back to the active
  task-tree index.

  **Boundary:** No parser/runtime behavior changed and no public mdBook content changed.

  **Verification:** Memory architecture, doctrine, task-tree metadata, and diff checks pass.

- 2026-07-08: **RUST-README-DRIFT-SYNC.1 — sync Rust README oracle count**
  (DONE docs-only correction; tree CLOSED).

  **Change:** `rust/README.md` now names the current full Rust interpreter oracle as **95** fixtures, matching the
  checked-in manifest and current mdBook status/handoff/corpora pages. The owner tree is complete and moved to
  Completed.

  **Boundary:** No parser/runtime behavior changed and no mdBook content changed.

  **Verification:** Focused stale-count scans, memory-architecture check, doctrine driver, and diff checks pass.

- 2026-07-08: **RUST-README-DRIFT-SYNC.0 — own Rust README count drift**
  (DONE tracking-only owner; frontier `.1` README correction next).

  **Change:** Registered a narrow task tree for the startup-discovered drift where `rust/README.md` still says the
  full Rust interpreter oracle has 93 fixtures while the manifest, mdBook, live docs, and Knowledge Map are at
  **95** fixtures.

  **Boundary:** No parser/runtime behavior changed and the README itself is intentionally untouched in this owner
  slice.

  **Verification:** Memory-architecture check, doctrine driver, and diff checks pass.

- 2026-07-08: **TASK-TREE-METADATA-HYGIENE.3 — gate completed-tree frontiers**
  (DONE doctrine gate; tree CLOSED).

  **Change:** Added `scripts/check_task_tree_metadata.sh` and registered `TASK-TREE-METADATA` in the doctrine
  driver. Completed task files are now gated against live `Current Frontier` status cells while historical prose
  and old commit-backfill fields stay outside the check.

  **Boundary:** No parser/runtime behavior changed and no public mdBook behavior changed.

  **Verification:** New task-tree metadata check, doctrine driver, Knowledge Map regeneration/check, memory
  architecture, and diff checks pass.

- 2026-07-08: **TASK-TREE-METADATA-HYGIENE.2 — reconcile stale frontier rows**
  (DONE metadata-only cleanup; frontier `.3` doctrine/check decision next).

  **Change:** Completed/completed-like task files no longer carry stale live `pending` frontier/verification/commit
  rows. `COMPAT-ALIAS-RETIREMENT` and `NONCORE-QUARANTINE` are explicitly classified as deferred/non-goal cases
  where their surviving deferred rows are intentional. `LINKEDSPEC-LOW-EFFORT.2` now correctly says the
  post-commit hook verifies/warns about `MEMORY.md` drift but does not auto-regenerate it.

  **Boundary:** No parser/runtime behavior changed and no public mdBook behavior changed.

  **Verification:** Focused stale-marker scans, Knowledge Map regeneration/check, memory/doctrine checks, and diff
  checks pass.

- 2026-07-07: **TASK-TREE-METADATA-HYGIENE.1 — reconcile top task metadata**
  (DONE metadata-only cleanup; frontier `.2` stale frontier/verification rows next).

  **Change:** Completed/exhausted task trees no longer advertise stale top-level `active` metadata in
  `FLUENT-BLOCK-EQUIVALENCE.md`, `MEDIUM-IMPACT.md`, or `PHASE0-BACKHALF-TRIAGE.md`. The owning hygiene tree and
  central index now point to `.2`.

  **Boundary:** No parser/runtime behavior changed and no public mdBook behavior changed.

  **Verification:** Focused stale-active scans, memory/doctrine checks, and diff checks pass.

- 2026-07-07: **SPEC-FORMAT-TERSE.14.5 — close trailing block drift**
  (DONE no-drift closeout; `SPEC-FORMAT-TERSE.14` closed).

  **Change:** The trailing block-argument lane is synchronized across roadmap, mdBook status, Knowledge Map, oracle
  corpus, task-tree, and live docs. The shipped surface remains helper-function `with(value) { ... }` / `with() { ... }` and
  receiver-method `.with() { ... }` on Perl/Rust, with the Rust oracle corpus at **95** fixtures.

  **Boundary:** No parser/runtime behavior changed. Bare `with { ... }`, explicit receiver `.with(value) { ... }`,
  closures, delayed callbacks, assignable/returnable blocks, and arbitrary non-`with` trailing blocks remain
  deferred.

  **Verification:** Focused stale-wording scans, mdBook build, Knowledge Map regeneration/check, oracle
  regeneration, Rust oracle pass, memory/doctrine checks, and diff checks pass.

- 2026-07-07: **SPEC-FORMAT-TERSE.14.4 — add receiver trailing blocks**
  (DONE implementation; frontier `.14.5` final trailing block no-drift closeout next).

  **Change:** Perl and Rust now support receiver `.with() { ... }` as an immediate trailing block argument. The
  receiver value is scoped as `value`, block-local `return(expr)` yields the `.with` result, and that result can be
  terminal or feed later compatible receiver-family links.

  **Boundary:** Explicit receiver `.with(value) { ... }`, bare `with { ... }`, closures, assignable/returnable
  blocks, delayed callbacks, and arbitrary non-`with` receiver trailing blocks remain unshipped.

  **Verification:** Focused Perl and Rust parser/runtime checks pass; full phase0 passes 1026 tests; oracle
  generation emits **95** fixtures; Rust `oracle_corpus_matches_perl_reference` passes over the full
  manifest-backed corpus.

- 2026-07-07: **REPO-HYGIENE.3 — remove generated artifacts**
  (DONE urgent cleanup; return to `SPEC-FORMAT-TERSE.14.4` next).

  **Change:** Removed ignored/untracked generated outputs `rust/target` (5.2G) and `docs/linkedspec-book/book`
  (7.0M). This reclaims the large Rust build output and mdBook HTML output; both are rebuildable.

  **Boundary:** No source, fixtures, checked-in docs, or submodule corpus content was deleted. `.log` and `.bin`
  hits under `rgx/` were preserved as submodule stimulus/fixture/issue artifacts.

  **Verification:** Ignored/tracked checks passed before deletion; post-clean checks confirm both generated
  directories are removed and no safe log/bin/temp artifacts remain in the main checkout outside ignored/submodule
  boundaries.

- 2026-07-07: **SPEC-FORMAT-TERSE.14.3 — add Rust helper trailing blocks**
  (DONE implementation; next at that time was `.14.4` receiver `.with() { ... }`).

  **Change:** Rust parser/runtime parity now supports helper-function form `with(value) { ... }` / `with() { ... }` as an
  immediate trailing block argument. The block runs in the caller's current action/runtime context; only scalar
  `value` is the portable scoped block parameter. Runtime restores the prior `value` binding after the block, and
  block-local `return(expr)` yields the `with` result.

  **Boundary:** Receiver `.with() { ... }`, bare `with { ... }`, closures, assignable/returnable blocks, delayed
  callbacks, and non-`with` helper trailing blocks remain unshipped.

  **Verification:** Focused Rust parser/runtime checks pass; oracle generation emits **94** fixtures; Rust
  `oracle_corpus_matches_perl_reference` passes over the full manifest-backed corpus.

- 2026-07-07: **SPEC-FORMAT-TERSE.14.2 — add Perl helper trailing blocks**
  (DONE implementation; frontier `.14.3` Rust helper-function form parity next).

  **Change:** The Perl reference now parses and lowers `with(value) { ... }` / `with() { ... }` as immediate
  trailing block arguments. The block gets scoped lexical `value`, block-local `return(expr)` behavior, hash-literal
  separation, and unsupported-helper diagnostics for unknown trailing-block callees.

  **Boundary:** Rust parity, receiver `.with() { ... }`, bare `with { ... }`, closures, assignable/returnable block
  values, and delayed callbacks remain unshipped.

  **Verification:** Focused parser/lowering probes pass; `t/actionir_ast_parser.t` passes; full phase0 passes
  1025 tests; mdBook, memory, Knowledge Map, doctrine, and whitespace checks pass.

- 2026-07-07: **SPEC-FORMAT-TERSE.14.1 — activate trailing block-argument plan**
  (DONE tracking/specification; frontier `.14.2` Perl helper-function form implementation next).

  **Change:** Reactivated the non-closed `SPEC-FORMAT-TERSE.14` trailing code-block owner and split it before code.
  The first MVP is `with(value) { ... }` / `with() { ... }` as an immediate, final-only block argument with scoped
  `value` binding and no closure/assignable/returnable block semantics.

  **Boundary:** Documentation/tracking only. No parser/runtime behavior changed and the public mdBook remains
  unchanged until the user-facing syntax ships.

  **Verification:** Memory architecture, Knowledge Map, doctrine driver, and whitespace diff checks pass.

- 2026-07-07: **TASK-TREE-METADATA-HYGIENE.0 — own task-tree metadata audit**
  (DONE tracking-only; frontier `.1` top-level metadata reconciliation next).

  **Change:** Added `TASK-TREE-METADATA-HYGIENE` to own the user-requested audit of non-closed task trees and stale
  per-file task metadata. The authoritative live non-closed trees are recorded; stale old task-file metadata is now
  split into cleanup leaves before any edits.

  **Boundary:** Documentation/tracking only. No parser/runtime behavior changed, no public mdBook behavior changed,
  and no old task files were cleaned up in this slice.

  **Verification:** Memory architecture, doctrine driver, and whitespace diff checks pass.

- 2026-07-07: **PUBLIC-STATUS-DRIFT-SYNC.2 — fix residual shipped corpus count drift**
  (DONE; tree CLOSED).

  **Change:** Updated the shipped-specs/corpora mdBook page to use the then-current manifest-backed 93-fixture Rust
  oracle and to point at `rust/linkedspec-runtime/tests/corpus/manifest.json` for the exact case list.

  **Boundary:** Documentation/status only. No parser/runtime behavior changed. Long-form roadmap and architecture
  count drift remain owned by deferred `ROADMAP-DRIFT-RECONCILE` leaves.

  **Verification:** mdBook build, focused stale-count scan, memory architecture, Knowledge Map, doctrine driver,
  and whitespace diff checks pass.

- 2026-07-07: **BOOTSTRAP-RESUME-SYNC.1 — correct stale resume pointer**
  (DONE; continuity-only tree CLOSED).

  **Change:** Added and completed a narrow task tree for the bootstrap finding that `MEMORY.md` still treated
  `PUBLIC-STATUS-DRIFT-SYNC.1` as in-flight after commit `e1101e1a` was already present and `git status --short`
  was clean. `MEMORY.md` now records the clean handoff state and the absence of an in-flight work unit.

  **Boundary:** No parser/runtime behavior changed, and no public mdBook content changed.

  **Verification:** Memory architecture, doctrine driver, and whitespace diff checks pass.

- 2026-07-07: **PUBLIC-STATUS-DRIFT-SYNC.1 — sync public Rust status docs**
  (DONE; tree CLOSED).

  **Change:** Updated the mdBook public project status and backend handoff pages to the then-current Rust state:
  interpreter parity was the then-current manifest-backed 93-fixture oracle gate, and generated Rust source remains a
  direct structural-family proof plus curated corpus subset. The related Rust oracle/generated-source Knowledge
  cards and derived `KNOWLEDGE_MAP.md` were refreshed.

  **Boundary:** Documentation/status only. No parser/runtime behavior changed. Long-form `ROADMAP.md` and
  `ARCHITECTURE_STATE.md` drift remain owned by `ROADMAP-DRIFT-RECONCILE`.

  **Verification:** mdBook build, focused stale-status scan, memory architecture, Knowledge Map, doctrine driver,
  and whitespace diff checks pass.

- 2026-07-07: **PUBLIC-STATUS-DRIFT-SYNC.0 — create public status drift tree**
  (DONE tracking-only; frontier `.1` public mdBook status/handoff sync next).

  **Change:** Added an active task tree to own the public status drift found during the bootstrap/context pass before
  any book edits. The concrete drift is narrow: `overview/project-status.md` still presents Rust parity as ongoing,
  and `appendix/backend-handoff.md` still carries an older Rust oracle corpus count.

  **Boundary:** No code, runtime behavior, roadmap content, or mdBook content changed. `ROADMAP-DRIFT-RECONCILE`
  continues to own long-form `ROADMAP.md` and `ARCHITECTURE_STATE.md` drift.

  **Verification:** Memory architecture, Knowledge Map, doctrine driver, and whitespace diff checks pass.

- 2026-07-07: **SPEC-FORMAT-TERSE.9.6 — close hash literal colon drift**
  (DONE; `.9` CLOSED; no concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf remains unless a deferred leaf is
  explicitly activated).

  **Change:** Final no-drift closeout for the `{ key : value }` hash-literal migration. No parser/runtime
  behavior changed; the closeout records that current specs, corpus inputs, generated oracle inputs, active tests,
  docs/mdBook, current Knowledge facts, and implementation support sites are aligned on colon hash-literal
  association.

  **Boundary:** Remaining `=>` owners are blind-call edge syntax, VHDL/source-language associations, generated
  Perl host output, Perl metadata/test data, backend value-rendering examples, explicit retired-syntax
  diagnostics/tests, or historical records. They are not current direct hash-literal source syntax.

  **Verification:** Current `.spec` source scans are clean for direct hash-literal `=>`; mdBook documents `:` as
  current and old `{ key => value }` only as retired. Oracle generation remains **93** fixtures, focused Perl and
  Rust `.9` checks pass, Rust `corpus_oracle` passes, and full phase0 passes `1..1024`.

- 2026-07-07: **SPEC-FORMAT-TERSE.9.5 — retire hash literal fat arrows**
  (DONE; superseded by `.9.6` final no-drift closeout).

  **Change:** Old `{ key => value }` no longer succeeds as current ActionIR hash-literal syntax. Perl routes
  retired direct hash-literal fat arrows to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon`, valid
  colon hash literals still lower, and Rust rejects the retired form during ActionIR parsing/compilation instead
  of accepting a rule with dropped action code. Perl multi-argument `array(...)` AST lowering now emits the
  already-lowered constructor directly, so generated Perl host hashrefs are not reparsed as retired source fat
  arrows.

  **Boundary:** Blind-call edge `=> Rule` remains valid. Generated Perl host hashrefs, Perl metadata hashes,
  VHDL/source-language associations, and historical notes remain separate `=>` owners.

  **Verification:** Focused Perl AST/lowering checks, focused Rust parser/compiler/runtime checks, full phase0
  `1..1024`, mdBook, Knowledge Map, memory, doctrine, Rust format, diff, and local CI gates pass.

- 2026-07-07: **SPEC-FORMAT-TERSE.9.4 — migrate hash literals to colon**
  (DONE; superseded by `.9.5` hard retirement and `.9.6` no-drift closeout).

  **Change:** Current-facing specs, checked-in corpus specs, generated Rust oracle inputs, active Perl/Rust tests,
  mdBook examples, root docs, and Knowledge facts now prefer `{ key : value }` for direct hash-literal
  association. `tkgui.spec` now returns a named hash accumulator directly instead of reconstructing one through
  flat-array pairs.

  **Boundary:** Blind-call edge `=>`, VHDL/source-language associations, generated Perl host hashrefs, Perl
  metadata hashes, historical records, and explicit migration-window compatibility locks remained intentionally
  classified at this leaf. Old hash-literal `=>` acceptance was removed by `.9.5`.

  **Verification:** Oracle generation over **93** fixtures, focused Perl/Rust checks, full phase0 `1..1023`,
  Rust oracle corpus, mdBook, Knowledge Map, memory, whitespace, doctrine gates, and `tools/run_ci_local.sh` pass.

- 2026-07-07: **SPEC-FORMAT-TERSE.9.3 — add Rust colon hash literals**
  (DONE; FRONTIER `.9.4` CURRENT-SOURCE/DOCS/CORPUS COLON MIGRATION NEXT).

  **Change:** The Rust ActionIR expression parser now accepts `{ key : value }` direct hash-literal association
  during the migration window, matching the Perl `.9.2` reference behavior. Colon pairs compose in nested hash
  shapes, direct assignment RHS values, hash-index mutation RHS values, expression-valued `set(...)` / `=(...)`,
  array composition, direct hash receiver chains, and block-vs-hash precedence.

  **Boundary:** At this migration-window leaf, old hash-literal `{ key => value }` remained accepted only until
  `.9.5`; blind-call edge `=> Rule` remained separate rule-body syntax. `.9.5` has since retired the old
  hash-literal spelling.

  **Verification:** Rust formatting passes; focused Rust parser and runtime integration tests pass. Knowledge Map,
  mdBook, memory, whitespace, and doctrine gates pass in commit closeout.

- 2026-07-07: **SPEC-FORMAT-TERSE.9.2 — add Perl colon hash literals**
  (DONE; FRONTIER `.9.3` RUST COLON HASH-LITERAL PARITY NEXT).

  **Change:** The Perl reference ActionIR AST parser now accepts `{ key : value }` as hash-literal association
  syntax during the migration window. Colon pairs work for bare and quoted keys, nested array/hash shapes, direct
  assignment RHS values, hash-index mutation RHS values, expression-valued `set(...)` / `=(...)`, and array shape
  composition. The old `{ key => value }` spelling remained accepted only until the hard-retirement leaf, which is
  now done.

  **Boundary:** Blind-call edge `=> Rule` syntax is untouched. Generated Perl host code still legitimately emits
  Perl fat arrows inside hashrefs, and double-colon payloads such as `{ JSON::PP }` still parse as block values
  instead of hash literals.

  **Verification:** Focused AST tests pass; full phase0 passes with `PERL5LIB=` cleared and plan `1..1023`.
  Knowledge Map, mdBook, memory, whitespace, and doctrine gates pass in commit closeout.

- 2026-07-07: **SPEC-FORMAT-TERSE.9.1 — split hash literal colon migration**
  (DONE; FRONTIER `.9.2` PERL REFERENCE COLON HASH-LITERAL SUPPORT NEXT).

  **Change:** `.9` is split before implementation. Direct hash-literal `=>` migration candidates are classified
  apart from blind-call edge syntax, VHDL/source-language associations, historical material, active fixture strings,
  and parser/runtime support sites. A Knowledge fact records the split so future sessions can start from the owner
  buckets instead of redoing the scan.

  **Boundary:** No parser/runtime behavior changed. Blind-call `=> Rule` remains valid, and source-language
  association syntax such as VHDL `=>` is outside the ActionIR hash-literal migration.

  **Verification:** Knowledge Map regenerated and checked; mdBook builds; memory, whitespace, and doctrine gates
  pass in commit closeout.

- 2026-07-07: **SPEC-FORMAT-TERSE.8.6 — close helper retirement no-drift**
  (DONE; FRONTIER `.9` HASH-LITERAL COLON ASSOCIATION NEXT AFTER CLEAN COMMIT).

  **Change:** Final helper-retirement scans classify current specs/corpora as clean for retired helper calls, keep
  remaining old names in diagnostics/regression/historical/reference buckets only, and correct the root guide so
  current scalar assembly is `cat(...)`; source-spelled `concat(...)` is retired. A Knowledge fact card records the
  no-drift audit result.

  **Boundary:** No parser/runtime behavior changed. This is a closeout/documentation/Knowledge slice after Perl and
  Rust hard retirement.

  **Verification:** Oracle generation is byte-identical over **93** fixtures; Rust `corpus_oracle` passes **3**
  tests. mdBook, Knowledge Map, memory, whitespace, and doctrine gates pass in commit closeout.

- 2026-07-07: **SPEC-FORMAT-TERSE.8.5 — reconcile helper retirement docs**
  (DONE; FRONTIER `.8.6` FINAL HELPER-RETIREMENT NO-DRIFT CLOSEOUT NEXT).

  **Change:** Current-facing docs, root guides, Rust README, and Knowledge cards now agree on the post-retirement
  helper surface: auto-existing variables, direct assignment/mutation, `set(...)`, `push(...)`, `copy(...)`,
  `cat(...)`, `array(...)`, `hash(...)`, and bare scalar reads. Old helper names are kept only as historical
  lowering evidence or retired-diagnostic guidance.

  **Boundary:** No parser/runtime behavior changed. Historical `.6.4` compatibility policy records remain as dated
  history, but visible summaries now say `.8` superseded that policy with hard retirement.

  **Verification:** Knowledge Map regenerated and checked; mdBook builds; `git diff --check` passes. Commit closeout
  runs memory/doctrine gates.

- 2026-07-07: **SPEC-FORMAT-TERSE.8.4 — hard-retire Rust legacy helpers**
  (DONE; FRONTIER `.8.5`/`.8.6` HELPER-RETIREMENT CLEANUP NEXT).

  **Change:** Rust no longer executes retired helper spellings successfully. `declare`, `array_copy`, `hash_copy`,
  `concat`, `push_value`, `push_nonempty`, and wrapper aliases `a(...)` / `h(...)` now return explicit
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics; current `set(...)`/assignment, `push(...)`,
  `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and receiver `.copy()` spellings keep corpus parity.

  **Boundary:** Recursive aggregate reset now uses current syntax: `set(array(items), [])` records a rule-local
  binding before mutation, replacing the old Rust `declare(array, items)` scoped boundary. Perl oracle source
  reconstruction now preserves `source_method` so current `cat(...)` inside attached control flow is not rebuilt as
  retired `concat(...)`.

  **Verification:** Oracle regeneration over **93** fixtures, focused Rust retirement/TOP-RULE/hash-receiver/corpus
  tests, full `linkedspec-core`, full `linkedspec-runtime`, and full phase0 **1022** pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.3 — hard-retire Perl legacy helpers**
  (DONE; FRONTIER `.8.4` RUST HARD RETIREMENT NEXT).

  **Change:** Perl reference lowering now treats the remaining old helper spellings as retired. Declaration helpers
  and aliases, function-form `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and
  `push_nonempty(...)` emit explicit unsupported-helper diagnostics instead of successful lowering. Current
  `cat(...)`, `copy(...)`, `push(...)`, assignments, typed wrappers, and receiver methods still lower.

  **Boundary:** Rust compatibility remains for the next owned leaf, `.8.4`; explicit diagnostic/compatibility test
  fixtures stay in place to lock the retirement boundary.

  **Verification:** Focused Perl helper probe, syntax checks for touched Perl/test modules, focused
  `t/actionir_ast_parser.t`, `t/trace_actionir_compact_lowerers.t`, and `t/phase0_validation_fuzz.t`, full phase0
  with `PERL5LIB=` cleared (**1022** tests), mdBook, Knowledge Map, memory, whitespace, and doctrine gates pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.4 — close helper migration no-drift gates**
  (DONE; FRONTIER `.8.3` PERL REFERENCE HARD RETIREMENT NEXT).

  **Change:** `.8.2` migration closeout is complete. Root authored specs and checked-in corpus specs are clean for
  retired helper spellings; generated corpus/test residues are classified as compatibility/retirement locks; and
  the active frontier advances to Perl hard retirement.

  **Boundary:** No parser/runtime behavior changed. This slice only proved no drift after the source/test/corpus/book
  and Knowledge Map migrations.

  **Verification:** Oracle generator syntax and regeneration pass with **93** fixtures and no git drift; Rust
  `corpus_oracle` passes **3** tests; full phase0 passes **1022** tests with `PERL5LIB=` cleared; mdBook,
  whitespace, and doctrine checks pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.3 — migrate book and knowledge helper references**
  (DONE; FRONTIER `.8.2.4` NO-DRIFT SCAN/GATE CLOSEOUT NEXT).

  **Change:** Current-facing mdBook helper examples now teach current terse spellings first: `cat(...)`,
  `copy(...)`, assignment/operator forms, `push(...)`, and explicit `is_nonempty(...)` guards before `push(...)`.
  Knowledge fact-card `reverify` commands were migrated away from legacy helper spellings unless they explicitly
  prove retirement/compatibility, and `KNOWLEDGE_MAP.md` was regenerated.

  **Boundary:** No parser/runtime behavior changed. Legacy helper names remain only in compatibility/catalog,
  retired-diagnostic, or historical contexts.

  **Verification:** mdBook build, Knowledge Map check, whitespace check, memory architecture check, and doctrine
  check pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.5 — close active test/corpus helper residue**
  (DONE; FRONTIER `.8.2.3` MDBOOK/KM HELPER-REFERENCE MIGRATION NEXT).

  **Change:** Active-test/corpus closeout scans classify or clear the remaining helper residue before current-facing
  docs/KM cleanup. Rust integration comments now explicitly classify the remaining `a(...)` / `h(...)`
  wrapper-alias fixture strings as `.8.4` retirement locks.

  **Boundary:** No parser/runtime behavior changed. Root `specs/` and `tests/corpus/` scan clean for retired helper
  spellings; generated oracle inputs retain only declaration, aggregate-copy, and current hash receiver-method
  cases; phase0 retains only the `.8.2.2.4` compatibility/equivalence categories.

  **Verification:** Focused residue scans over Rust active tests, generated corpus inputs, generator source, root
  corpus/specs, and the Perl phase0 terse block passed with only owned residual categories. Rust formatting,
  whitespace, memory architecture, and doctrine checks pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.4 — migrate Perl phase0 helper strings**
  (DONE; FRONTIER `.8.2.2.5` ACTIVE-TEST/CORPUS RESIDUE SCANS NEXT).

  **Change:** Perl phase0 embedded specs now use current `cat(...)`, `push(...)`, and `copy(...)` spellings where
  the fixture is not an explicit legacy compatibility lock. TOP-RULE recursion append/snapshot paths,
  user-function helpers, auto-existence append proofs, current-feature snapshot returns, array method fixtures, and
  mutation-expression snapshots were migrated.

  **Boundary:** No runtime behavior changed. Remaining old-helper strings are classified under declaration scope,
  `push_nonempty(...)` semantic filtering, aggregate-copy compatibility, helper-renaming equivalence, canonical
  old-side equivalence, or current `.hash_copy()` receiver-method surface. The all-bare
  `push(words, label)` candidate failed as expected because that spelling remains child-call-shaped; the accepted
  current form is `push(array(words), label)` where the RHS is a bare scalar read.

  **Verification:** `perl -c -Iperl t/phase0_regression.t` passes. Full phase0 with `PERL5LIB=` cleared passes
  **1022** tests. Focused phase0 residue scan shows every retained old-helper spelling under an explicit owner.
  Rust formatting, whitespace, memory architecture, and doctrine checks pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.3 — migrate generated corpus helper fixtures**
  (DONE; FRONTIER `.8.2.2.4` PERL PHASE0 OLD-HELPER STRING MIGRATION NEXT).

  **Change:** Generated oracle corpus sources now use current `push(...)` and `copy(...)` spellings where the
  fixture behavior is current-surface. `autoexist_array_bare_arg` and TOP-RULE recursion fixture inputs were
  migrated, and incidental setup in the aggregate-copy compatibility fixture now uses `push(...)`.

  **Boundary:** No runtime behavior changed and no oracle expected-output or manifest drift occurred. Remaining
  generated-corpus helper residue is intentionally classified as declaration compatibility, aggregate-copy
  compatibility, or current hash receiver-method surface.

  **Verification:** `perl -c -Iperl tools/gen_oracle_corpus.pl`, `perl -Iperl tools/gen_oracle_corpus.pl`, and Rust
  `corpus_oracle` pass over **93** generated fixtures. Focused residue scans, formatting, whitespace, memory
  architecture, and doctrine checks pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.2.5 — classify integration helper residue**
  (DONE; `.8.2.2.3` GENERATED ORACLE CORPUS HELPER-FIXTURE MIGRATION HAS SINCE CLOSED).

  **Change:** The remaining Rust integration-test helper-string residue is classified in place. Recursive
  `declare(...)` usage remains owned by `.8.2.2.2.2`; explicit helper compatibility strings remain owned by
  `.8.2.2.2.3`/`.8.4`; receiver-dot `.hash_copy()` is documented current hash receiver surface; and `h(...)` in
  the quoted wrapper-boundary test is a legacy wrapper-alias retirement lock.

  **Boundary:** No runtime behavior or user-facing syntax changed. The Rust integration-test helper cleanup lane is
  closed, so the next active cleanup surface is generated oracle corpus fixture inputs.

  **Verification:** Focused residue scan over `integration_test.rs` shows every remaining old-helper spelling under
  an explicit `.8.2.2.2.2`, `.8.2.2.2.3`, or `.8.2.2.2.5` classification. Rust formatting passes.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.2.4 — migrate later integration fixtures**
  (DONE; `.8.2.2.2.5` RUST INTEGRATION-TEST RESIDUE CLASSIFICATION HAS SINCE CLOSED).

  **Change:** Later current-feature Rust integration fixtures outside explicit compatibility blocks now use current
  `push(...)`, `copy(...)`, and explicit aggregate-setter spellings where supported. The array append-operator
  equivalence test now compares against current `push(...)`.

  **Boundary:** No runtime behavior changed. Hash receiver chains intentionally keep documented `.hash_copy()`
  receiver spelling today, and wrapper-alias `h(...)` fixture residue remains for `.8.2.2.2.5` classification.

  **Verification:** Focused Rust filters for `terse_1_`, `terse_2_3`, `rust_parity_7_3_4`,
  `rust_parity_7_5_2`, `terse_11_3`, and `terse_3_3` pass. Full Rust `integration_test` passes **172** tests,
  and Rust formatting plus whitespace checks pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.2.3 — annotate legacy helper compatibility tests**
  (DONE; `.8.2.2.2.4` LATER CURRENT-FEATURE RUST INTEGRATION FIXTURE CLEANUP HAS SINCE CLOSED).

  **Change:** The early Rust integration compatibility block now uses current `push(...)`, `copy(...)`, and
  `hash(...)` spellings on current-side assertions. Retained old-helper sides are labelled as `.8.4` hard-retirement
  locks.

  **Boundary:** Rust still executes the legacy helpers for compatibility. This slice only classifies explicit
  compatibility/equivalence tests; later incidental Rust integration fixture strings remain owned by `.8.2.2.2.4`.

  **Verification:** Focused Rust filters for `terse_1_1_2`, `terse_1_2`, `terse_1_4_2`, and `terse_1_3_2` pass.
  Full Rust `integration_test` passes **172** tests, and Rust formatting, memory/doctrine, and whitespace checks
  pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.2.2 — classify recursive helper fixtures**
  (DONE; `.8.2.2.2.3` EXPLICIT LEGACY-HELPER COMPATIBILITY/EQUIVALENCE TESTS HAVE SINCE CLOSED).

  **Change:** TOP-RULE-AS-NORMAL recursive Rust integration fixtures now use current `push(...)`, `copy(...)`,
  and `array(...)` spellings for append/snapshot behavior.

  **Boundary:** `declare(array, items)` remains intentionally retained as a Rust scoped-declaration compatibility
  lock. The current-surface `set(array(items), [])` candidate preserves the matching Perl probe but fails Rust
  recursive value parity, so `.8.4` must resolve that before declaration-helper removal.

  **Verification:** Focused TOP-RULE Rust integration filter passes, full Rust `integration_test` passes **172**
  tests, and mdBook/Knowledge Map/memory/doctrine/whitespace checks pass.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.2.1 — migrate integration smoke helper fixtures**
  (DONE; `.8.2.2.2.2` TOP-RULE-AS-NORMAL RECURSIVE HELPER CLASSIFICATION HAS SINCE CLOSED).

  **Change:** Non-compatibility Rust integration smoke fixtures before the recursive and explicit compatibility
  blocks now use current helper spellings: explicit aggregate setters, `push(...)`, `copy(...)`, `cat(...)`, and
  direct scalar assignment.

  **Boundary:** TOP-RULE-AS-NORMAL recursive fixtures and explicit legacy-helper equivalence blocks remain
  untouched and owned by later `.8.2.2.2` children.

  **Verification:** Scoped old-helper scan now starts at the TOP-RULE-AS-NORMAL block, outside this child. Focused
  `full_pipeline` and staged user-function filters pass. Full Rust `integration_test` passes **172** tests.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.2.1 — migrate source-emitter helper fixtures**
  (DONE; `.8.2.2.2.1` INTEGRATION SMOKE HELPER-FIXTURE MIGRATION HAS SINCE CLOSED).

  **Change:** Rust source-emitter smoke specs no longer use incidental `declare(...)`, `push_value(...)`,
  `array_copy(...)`, or `concat(...)` helper spellings. They now use explicit aggregate setters,
  `push(...)`, `copy(...)`, and `cat(...)`.

  **Guard:** Repetition snapshot fixtures need `set(array(name), [])` when resetting named aggregate storage.
  Direct `name = []` binds a scalar-held array value and does not clear the aggregate later targeted by
  `push(array(name), ...)`.

  **Verification:** Source-emitter old-helper residue scan is clean. `cargo test --manifest-path rust/Cargo.toml
  -p linkedspec-runtime --test source_emitter` passes all **3** tests, including generated Rust parser compile/run
  proofs.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.2.1 — migrate EBNF nonempty append flow**
  (DONE; `.8.2.2.1` SOURCE-EMITTER HELPER-FIXTURE MIGRATION HAS SINCE CLOSED).

  **Change:** `specs/ebnf.spec::logging_annotation` no longer uses `push_nonempty(...)`. The optional capture span
  is now trimmed once into `logging_annotation_part`, checked with `is_nonempty(...)`, and appended with
  `push(array(logging_annotation), logging_annotation_part)`.

  **Sync:** Generated EBNF oracle `input.spec` copies and the EBNF mdBook walkthrough match the shipped spec. The
  oracle `expected.json` files did not drift.

  **Verification:** `perl -Iperl tools/gen_oracle_corpus.pl` regenerated **93** fixtures; `LinkedSpec::get_parser("ebnf")`
  preserves the `@log_rule("expr", "term")` payload; Rust `corpus_oracle` passes **93** fixtures; `mdbook build`
  passes; full phase0 passes **1022** tests after refreshing the stale source-inspection lock.

- 2026-07-06: **SPEC-FORMAT-TERSE.8.1 — split legacy helper retirement**
  (DONE; `.8.2.1` EBNF NONEMPTY APPEND MIGRATION HAS SINCE CLOSED).

  **Inventory:** Perl already leaves `assign(...)` raw/unlowered and emits unsupported-helper diagnostics for
  `scalar(...)` plus `s(...)`/`a(...)`/`h(...)`. Perl still lowers declaration helpers, `concat(...)`,
  `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)`. Rust still executes
  `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and `array|a` / `hash|h`.

  **Next:** `.8.2` owns current-source/test/corpus/doc migration before engine retirement, including a
  behavior-preserving `push_nonempty(...)` replacement decision.

- 2026-07-06: **SPEC-FORMAT-TERSE.15.5 — close colon scalar-slot drift**
  (DONE; `.8.1` HAS SINCE SPLIT LEGACY HELPER REMOVAL).

  **Closeout:** Current shipped specs, generated corpus inputs, mdBook guidance, active tests, and non-historical
  Knowledge Map facts no longer depend on successful `:name` scalar-slot syntax. Remaining colon hits are retired
  diagnostic code/tests, rule-mode/regex/public-API colon syntax, or explicitly historical records.

  **Drift fixed:** Two stale current Knowledge fact-card examples were corrected: duck-typed assignment now
  reverifies with bare `items` / `meta`, and statement regex substitution is documented as `substr(target, ...)`
  instead of retired `substr(:target, ...)`.

  **Verification:** Live probes for the corrected examples pass; oracle generation keeps **93** fixtures; Rust
  `corpus_oracle` passes over all **93** fixtures; mdBook builds; Knowledge Map, memory/doctrine, diff, and full
  phase0 checks pass (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan `1..1022`).

- 2026-07-06: **SPEC-FORMAT-TERSE.15.4 — retire Rust colon scalar slots**
  (DONE; `.15.5` FINAL NO-DRIFT CLOSEOUT HAS SINCE CLOSED).

  **Change:** Rust `Expr::ScalarSlot` was removed from the core AST and runtime/source-emitter paths. A retired
  `:name` value primary now emits
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` with bare-read migration guidance.

  **Semantics preserved:** Runtime fixtures use bare reads. Action-edge blocks that call a child or read bare
  `retv` pre-dispatch the matched edge child and expose the scoped child return to the attached block. `specs/ebnf.spec`
  now uses `rule_header` for the scalar rule header and `rule` for the aggregate body, avoiding the old same-name
  scalar/array collision under bare reads. The generated corpus case formerly named
  `terse_6_2_3_1_scalar_slot_shorthand` is now `terse_15_4_bare_scalar_payload_readback`.

  **Verification:** Focused Rust core/runtime/source-emitter/trace suites pass; `perl -Iperl
  tools/gen_oracle_corpus.pl` regenerates **93** fixtures; Rust `corpus_oracle` passes over all **93** fixtures;
  full Phase0 with `PERL5LIB=` cleared passes (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan `1..1022`)
  after refreshing the EBNF source-lock assertion to `rule_header`.

- 2026-07-06: **SPEC-FORMAT-TERSE.15.3 — retire Perl colon scalar slots**
  (DONE; `.15.4` RUST `Expr::ScalarSlot` REMOVAL HAS SINCE CLOSED).

  **Change:** Perl reference `:name` scalar-slot syntax no longer parses/lowers as a successful read or target.
  Retired colon scalar slots now emit
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`, and the former
  `scalar_slot_fallback` trace/declaration path is gone.

  **Semantics preserved:** Active Perl fixtures now use bare value reads. The retirement also locks bare-read
  boundaries for inline `if`/`elseif`/`switch` conditions, logical `or(...)` / `and(...)`, ordinary
  `entry_text()` / `match_text()` value helpers, assignment-source passthrough, flow RHS values, and scalar-held
  hash `count_keys(...)`.

  **Verification:** Focused ActionIR/trace tests pass; full phase0 passes with `PERL5LIB=` cleared and reaches
  `1..1022`. mdBook/KM/live docs updated.

- 2026-07-06: **SPEC-FORMAT-TERSE.15.2.4 — migrate current sources to bare reads**
  (DONE; `.15.3` PERL `:name` REMOVAL HAS SINCE CLOSED).

  **Change:** Current shipped specs, root corpus examples, generated Rust oracle inputs, and mdBook examples now use
  bare value reads instead of `:name` scalar-slot reads. The migration preserved the **93** fixture oracle expected
  JSON and manifest.

  **Engine boundaries locked:** Perl lowering now keeps parser-backed `set(...)` reconstruction, variadic
  `split_tagged_records(...)` source arguments, copy-return payloads, and declaration/type-memory tracking aligned
  with the migrated source surface. Rust action-edge `call(child)` blocks publish child `retv` after the block
  completes, and descriptor scalar bare reads can coexist with same-name aggregate accumulators.

  **Verification:** Full phase0 passes (`1..1022`); oracle regeneration preserves expected JSON; Rust
  `corpus_oracle` passes over **93** fixtures; mdBook build, whitespace diff check, and scalar-slot residue scan
  pass with only rule-mode/regex/historical-string exclusions.

- 2026-07-06: **REPO-HYGIENE.2 — ignore Claude project state and rgx local dirt**
  (DONE; REPO HANDOFF CLEANUP).

  **Change:** `.claude/projects/` is ignored local agent state. `rgx` remains a tracked gitlink/submodule, and
  `.gitmodules` now records `ignore = dirty` so local dirt inside `rgx/` does not dirty the parent repo status.

  **Finding:** `rgx` was a tracked gitlink, so `.gitignore` alone could not suppress its dirty parent status.
  Keeping the submodule and setting its submodule ignore policy is the correct cleanup.

- 2026-07-06: **SPEC-FORMAT-TERSE.15.2.3 — Rust bare-read parity and switch case-label alignment**
  (DONE; FRONTIER `.15.2.4` SOURCE MIGRATION NEXT, NOT STARTED).

  **Change:** Rust statement/attached switch and inline lazy `switch(...)` now share one case-value path: bare case
  labels are literal tags (`case(foo)` matches `"foo"`), while `case(:foo)` and quoted/helper expressions still
  evaluate normally during the transition. Bare switch subjects, numeric/comparison helper args, and `if(...)`
  conditions read bound scalar values. The Perl inline switch lowering was aligned after the new oracle exposed
  that inline `case(foo, body)` still read `$foo` while attached `case(foo)` was already literal.

  **Source alignment:** `specs/spec.spec` now initializes `paragraphs` and `current` with explicit aggregate
  `array(...)` targets. Under `.11` duck-typed assignment, `paragraphs = []` / `current = []` create scalar-held
  array values, which do not feed later aggregate `push(rule_header, current)` mutations.

  **Verification:** Focused Rust `.15.2.3` tests pass; regenerated Rust oracle corpus passes over **93** fixtures;
  `perl -c` and `cargo fmt --check` pass; full phase0 reaches `ok 1022` / plan `1..1022` with **1021 pass** and
  only known baseline `not ok 796`. mdBook/KM/live docs updated.

- 2026-07-05: **SPEC-FORMAT-TERSE.15.2.2 — Perl reference bare-read completion in value positions**
  (DONE; `.15.2.3` RUST PARITY HAS SINCE CLOSED; FRONTIER `.15.2.4` NEXT).

  **Change:** One guarded branch in `ActionIR::FlowExpr::_lower_flow_composite_expr` (bare identifier at the
  `passthrough_no_call` site → `$name` variable read, mirroring the `:name` branch) closed all three enumerated
  value-position gaps at once — if/elseif/while + `num_*` + logical conditions delegate to it and the switch
  selector funnels through it. A second change in `ActionIR::ControlFlow::_lower_switch_case_value_expr` keeps a bare
  switch CASE LABEL a literal tag (hash-key-analogous exemption, ADR `0019`): `switch(kind)` reads variable `kind`,
  `case(foo)` matches literal `"foo"`. `:name` stays accepted (compat) during the transition.

  **Verification:** Discriminating probes show `switch(kind)`→`good`, `num_lt(n,5)`@n=10→`no`, `if(c)`@c=0→`F`, all
  == their `:name` forms. FULL phase0 (`PERL5LIB=` cleared, 10-min timeout): reach `ok 1022`, **1021 pass**, only
  the pre-existing `not ok 796`; zero regressions (`comm` vs baseline `{796}` empty both ways). `perl -c` clean on
  both changed modules. Memory/KM/doctrine gates pass.

  **Env:** phase0 needs `PERL5LIB=` cleared (stale `pgen/fx/perl` poisons the pplugin subprocess subtests) and the
  10-min foreground timeout (else it caps mid-run at exit 144/143 — always check the REACH first).

- 2026-07-05: **SPEC-FORMAT-TERSE.15.2.1 — bare-vs-`:name` value-position inventory + engine seams**
  (DESIGN/INVENTORY DONE; PERL `.15.2.2` NOW DONE).

  **Inventory (discriminating reference-engine probes):** bare identifiers are NOT read as the bound variable in
  exactly three value positions — `switch(...)` selector (`switch(:kind)`→`good` vs `switch(kind)`→`def`),
  `num_*(...)` callee args (`num_lt(:n,5)`@n=10→`no` vs bare→`yes`), and `if(...)`/`while(...)`/logical conditions
  (`if(:c)`@c=0→`F` vs bare→`T`). Plain `return(name)`/assign-RHS/receiver already read bare. Real shipped-spec
  hazard is rule-name collisions in `spec.spec`/`ebnf.spec` (ADR `0019`); `switch(` appears in no shipped spec.

  **Seams pinned for `.15.2.2`/`.15.2.3`:** Perl `ActionIR::FlowExpr::_lower_flow_composite_expr`
  (`perl/LinkedSpec/ActionIR/FlowExpr.pm:319`; `:name`→`$name` at `:364`, no bare arm) covers if/elseif/while/
  logical + `num_*` args; switch selector via `ActionIR::ControlFlow._control_ast_value_source_expr:332`. Rust
  `Expr::Variable` (`rust/linkedspec-core/src/expr.rs:1350`) vs `Expr::ScalarSlot`→`ctx.get_scalar`
  (`rust/linkedspec-runtime/src/engine.rs:3287`). Policy locked (value-position-is-variable, ADR `0019`); composes
  with the `.11` type-at-assignment duck-typed model.

  **Verification:** design/inventory only — no code path changed; baseline phase0 stays 1021 pass / 1 pre-existing
  unrelated fail (test 796). Memory/KM/doctrine gates pass. No engine/source/mdBook behavior changed.

- 2026-07-05: **SPEC-FORMAT-TERSE.15.2 re-scope — reorder .15 to engine-first (bare-read gap) + recovery**
  (PLANNING/RECOVERY DONE; ENGINE-FIRST `.15.2.1` DESIGN NOW DONE).

  **Recovery:** A prior session left the working tree dirty with uncommitted, intermingled `.15.2/.15.3/.15.4/.8/.9`
  work (152 files, phase0 RED). Preserved verbatim on branch `recovery/terse-15-uncommitted-20260705`
  (`b1a2aefe`, reference-only); `main` reset clean to `104088e5`.

  **Finding:** Source-first `.15.2` migration is NOT output-preserving at `104088e5` — bare identifiers are not
  read as the bound variable in `switch(...)`, numeric callees, `if(...)` conditions, or all-bare `push(A,B)`
  second args, and collide with rule names in `spec.spec`/`ebnf.spec` (`switch(:kind)`→`good` vs
  `switch(kind)`→`def`). Per user directive (`:name` shall NOT be supported), `.15` re-sequenced engine-first:
  `.15.2.1` design → `.15.2.2` Perl → `.15.2.3` Rust → `.15.2.4` migration → `.15.3`/`.15.4` remove → `.15.5`
  closeout. ADR `0019`, KM `terse-bare-read-value-position-gap`.

  **Verification:** Baseline phase0 = 1021 pass / 1 pre-existing unrelated fail (test 796). Memory/KM/doctrine
  gates pass. No engine/source behavior changed.

- 2026-07-05: **SPEC-FORMAT-TERSE.15.1 — split colon scalar-slot removal**
  (AUDIT/SPLIT DONE; CURRENT-SURFACE MIGRATION FRONTIER ACTIVE).

  **Fix:** Audited `:name` scalar-slot usage before implementation and split the removal lane. Current usage spans
  shipped/root specs, root corpus examples, generated oracle fixtures, mdBook guidance, Knowledge Map facts,
  trace/phase0 tests, oracle-generation sources, and Perl/Rust parser/runtime support, so hard removal is not one
  safe slice.

  **Verification:** Audit scans recorded in `docs/tasks/SPEC-FORMAT-TERSE.md`; Knowledge Map, memory, doctrine,
  whitespace, and mdBook checks pass. No parser/runtime behavior changed.

  **Frontier:** `SPEC-FORMAT-TERSE.15.2` is active for migrating current specs/corpus/docs/KM away from `:name`
  while compatibility remains. `.15.3` and `.15.4` own Perl and Rust retirement; `.15.5` owns final no-drift.

- 2026-07-05: **SPEC-FORMAT-TERSE.11.5 — close duck-typed assignment alignment**
  (DUCK-TYPED ASSIGNMENT LANE CLOSED; COLON-SLOT REMOVAL FRONTIER NEXT).

  **Fix:** Current roadmap and Knowledge Map retrieval now describe direct RHS shape assignment as typed value
  binding. Target-kind inference remains documented only as superseded history. The mdBook assignment/container
  guidance already matched `.11` semantics, including explicit aggregate targets and nested no-autovivification
  value-path writes.

  **Verification:** Current-facing stale-wording scans passed after targeted roadmap/fact-card edits.
  `KNOWLEDGE_MAP.md` was regenerated over 199 facts / 1418 question keys; mdBook, Knowledge Map, memory,
  doctrine, and whitespace checks pass.

  **Historical frontier:** At this slice, `SPEC-FORMAT-TERSE.15` was next for removing `:name` scalar-slot syntax.
  That lane, `.8`, `.9`, and `.14` have since closed; the current active terse frontier is `.12.2`.

- 2026-07-05: **SPEC-FORMAT-TERSE.11.4 — implement nested value-path assignment**
  (NESTED VALUE-PATH DONE; DUCK-TYPED CLOSEOUT FRONTIER ACTIVE).

  **Fix:** Perl and Rust now support nested direct-access assignment through scalar-held array/hash payloads, such
  as `payload["items"][0]["name"] = value`. Writes use explicit path checks instead of Perl autovivification:
  intermediates must exist and match shape; final hash keys may be created/replaced; final array indexes may
  replace or append exactly at len; missing/wrong/gap paths return `undef`/`null` and leave the root unchanged.
  Single-segment scalar-held array roots such as `payload[1] = value` now mutate the array value consistently.

  **Verification:** Focused Perl syntax/probe checks pass for nested lowering, scalar-held array root mutation,
  generated declarations, and descriptor readiness. Focused Rust `.11.4` tests pass. The oracle corpus was
  regenerated to **92** fixtures with `terse_11_4_nested_mixed_value_path_assignment`, known `spec_spec_*`
  generator drift restored, and the Rust corpus oracle passes.

  **Frontier:** This was closed by `SPEC-FORMAT-TERSE.11.5`; current frontier is `.15`, followed by `.8` and `.9`.

- 2026-07-05: **SPEC-FORMAT-TERSE.11.3 — implement Rust duck-typed assignment parity**
  (RUST PARITY DONE; NESTED VALUE-PATH FRONTIER ACTIVE).

  **Fix:** Rust bare assignment now binds the evaluated typed RHS value instead of retagging direct array/hash RHS
  shapes into aggregate storage. `name = [value]`, `set(name, [value])`, and `=(name, [value])` store scalar-held
  array values and yield them in value positions; `set(array(items), [value])` and `set(hash(meta), {...})` remain
  explicit aggregate mutations. Scalar-held `array(name)` / `hash(name)` reads, `copy(...)`, aggregate-consuming
  helper slots, and receiver chains now use guarded snapshots. The oracle pass also closed the narrow Perl
  reference fallback where scalar-held `copy(name)` and bare array receiver chains still preferred aggregate
  storage unless explicitly wrapped, including the generated-source declaration collector.

  **Verification:** Perl syntax/probe checks for scalar-held copy/receiver readback and declaration collection
  passed. Focused Rust runtime tests for `.11.3`, scalar-slot shorthand, aggregate assignment values, and
  assignment-expression closure passed. The oracle corpus was regenerated to 91 fixtures with `.11.3` cases; Rust
  corpus oracle, mdBook build, Knowledge Map, memory, doctrine, and diff checks pass. Broad phase0 completed with
  the `.11` locks clean and one known unrelated failure in `emit_context_lowers_split_tagged_records_helper`.

  **Frontier:** `SPEC-FORMAT-TERSE.11.4` is active for nested mixed array/hash value-path reads and writes.
  `.11.5` remains behind it for final docs/KM/corpus closeout.

- 2026-07-05: **SPEC-FORMAT-TERSE.11.2 — implement Perl duck-typed assignment binding**
  (PERL REFERENCE DONE; RUST PARITY FRONTIER ACTIVE).

  **Fix:** Bare Perl assignment and `set` targets now bind typed RHS values through `$name`; direct shape RHS no
  longer emits `@name`/`%name` or matching aggregate declarations solely from RHS shape. Explicit
  `array(...)`/`hash(...)` targets remain aggregate mutation storage, and scalar-bound typed views read guarded
  snapshots from `$name`.

  **Verification:** Perl module/test syntax checks, `git diff --check` for touched Perl/test files, focused
  lowering/generated-source/runtime probes, and assignment-expression closure probe passed. A broad
  `prove -q -Iperl t/phase0_regression.t` run was interrupted after surfacing unrelated dirty-work failures and
  stale assignment expectations updated in this slice.

  **Frontier:** `SPEC-FORMAT-TERSE.11.3` is active for Rust parity. Nested mixed value paths and docs/KM/corpus
  closeout remain split behind `.11.3`.

- 2026-07-05: **SPEC-FORMAT-TERSE.11.1 — split duck-typed assignment work**
  (TASK-TREE SPLIT/PROBE DONE; IMPLEMENTATION FRONTIER ADVANCED).

  **Fix:** Split the active duck-typed assignment leaf into signoff-sized children after codebase, mdBook, Knowledge
  Map, and toolbox inspection. Current ground truth is recorded: Perl still infers `@name`/`%name` from direct RHS
  shape assignment, and Rust still has matching direct-shape assignment branches.

  **Verification:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`; `perl -Iperl -MLinkedSpec` module-path check; focused `call_spec_handler_subst` probes.

  **Frontier:** `SPEC-FORMAT-TERSE.11.2` is active for the Perl reference duck-typed value-binding implementation.
  Rust parity, nested mixed value paths, and docs/KM/corpus closeout are split behind it.

- 2026-07-05: **SPEC-FORMAT-TERSE.15 — track colon scalar-reference removal**
  (TASK-TREE OWNERSHIP TRACKED; IMPLEMENTATION NOT ACTIVE).

  **Fix:** Added pending ownership for removing `:name` scalar variable references from the future duck-typed
  surface. Variables and parameters should be read as bare names in value positions, while bare names in
  hash-literal key position remain stringified keys.

  **Verification:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

  **Frontier:** `.15` is owned and pending behind the active `.11` duck-typed semantics work. Implementation has
  not started.

- 2026-07-05: **SPEC-FORMAT-TERSE.14 — track trailing block arguments**
  (TASK-TREE BACKLOG TRACKED; IMPLEMENTATION NOT ACTIVE).

  **Fix:** Added deferred ownership for a future block-argument type on helper and receiver-method calls. Blocks
  are final arguments only, with preferred trailing syntax such as `fn(args) { ... }`; zero-arg `fn { ... }` is
  grammar-gated, inline `fn(args, { ... })` is deferred or allowed only if unambiguous from hash literals, and
  closures/assignable blocks/returnable blocks remain out of scope. The leaf also requires a defined callee-side
  block invocation surface before code.

  **Verification:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

  **Frontier:** `.14` is not PNT-eligible unless explicitly reactivated. `SPEC-FORMAT-TERSE.11` remains active.

- 2026-07-05: **SPEC-FORMAT-TERSE.12/.13 — track tree traversal backlog**
  (TASK-TREE BACKLOG TRACKED; IMPLEMENTATION NOT ACTIVE).

  **Fix:** Added deferred hash-tree traversal ownership and a lower-priority array-tree traversal backlog item.
  Hash-tree traversal is defined for future spec work as a hash root with hash interior nodes and scalar or array
  leaves, with attached-block traversal method names, callback context, traversal order, and return/mutation policy
  still to be specified before code.

  **Verification:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

  **Frontier:** `.12` and `.13` are not PNT-eligible unless explicitly reactivated. `SPEC-FORMAT-TERSE.11`
  remains the active spec-first assignment-semantics owner.

- 2026-07-05: **SPEC-FORMAT-TERSE.11 — track nested typed-value paths**
  (TASK-TREE ACCEPTANCE REFINED; IMPLEMENTATION PENDING).

  **Fix:** Expanded the active duck-typed assignment leaf to require deeply nested references and assignments
  through mixed array/hash value trees in arbitrary combinations. The implementation must define intermediate
  container behavior explicitly instead of inheriting Perl autovivification behavior by accident.

  **Verification:** `git diff --check -- CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md MEMORY.md docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md`.

  **Frontier:** `SPEC-FORMAT-TERSE.11` remains active.

- 2026-07-05: **SPEC-FORMAT-TERSE.11 — activate duck-typed assignment semantics**
  (TASK-TREE OWNERSHIP ACTIVE; IMPLEMENTATION PENDING).

  **Fix:** Added active task-tree ownership for duck-typed `.spec` assignment semantics. The accepted direction is
  that `name = value` binds a runtime typed value rather than exposing Perl `$/@/%` storage classes. Explicit
  aggregate RHS forms `name = [...]` and `name = {...}` are the MVP; delimiterless aggregate RHS sugar remains out
  of scope unless a later leaf owns it.

  **Verification:** `git diff --check -- docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md MEMORY.md`.

  **Frontier:** `SPEC-FORMAT-TERSE.11` is active and spec-first. In-flight `SPEC-FORMAT-TERSE.8` helper-removal
  work remains owned and must align with `.11`; `.9` colon hash-literal syntax follows; `.10` dynamic/computed
  hash keys remains deferred/potential.

- 2026-07-04: **TRACE-OBSERVABILITY.4.5 — close trace parity proof**
  (TRACE PARITY PROOF DONE; TRACE-OBSERVABILITY TREE CLOSED).

  **Fix:** Proved the mdBook-documented external trace capability contract across Perl and Rust, updated the common
  book with the future-variant checklist, and added Rust unit coverage for structured dump/log trace primitives.
  Rust can now claim trace parity for the behavioral contract: ordered levels, normal-entrypoint controls,
  stdout/routed-file/mirror sinks, routed-file reset, default-quiet behavior, structured scope and branch events,
  mark/capture/source-boundary events where implemented, and dump/log diagnostics.

  **Verification:** Perl CLI/help plus the nine-file Perl trace suite pass; Rust core trace tests and runtime trace
  controls pass; mdBook, Knowledge Map, memory/doctrine, whitespace, and full local CI are part of the `.4.5`
  commit workflow.

  **Frontier:** no `TRACE-OBSERVABILITY` leaf remains. Return to the active task-tree index; listed remaining
  frontiers are paused or deferred unless explicitly reactivated.

- 2026-07-04: **TRACE-OBSERVABILITY.4.4 — add Rust runtime trace events**
  (RUST INTERPRETED/GENERATED-PLAN RUNTIME TRACE EVENTS DONE; TRACE TREE CLOSED AFTER .4.5).

  **Fix:** Wired Rust traced runtime execution through the shared `linkedspec-core::trace` model without changing
  default quiet entrypoints. Interpreted traces now report `rust_runtime:engine:*` top-rule, rule entry/exit,
  recursion-cutoff, child/passive-terminal dispatch, regex match/no-match, acode/bcode dispatch, lifecycle block,
  statement-form `if`/`switch`, helper `call(child)`, and mark/capture helper events. Generated-plan traces now
  report `rust_runtime:generated_plan:*` top-rule, family/direct-rule, recursion, child, regex, acode/bcode, and
  AND-sequence decisions.

  **Verification:** Focused Rust trace controls/runtime tests, source-emitter tests, core trace tests, formatting,
  mdBook, Knowledge Map, memory/doctrine, whitespace, and full local CI gates are part of the `.4.4` commit workflow.
  A diagnostic full Rust runtime `integration_test` still has the known residual 9 failures and is not the `.4.4`
  acceptance gate.

  **Frontier:** `TRACE-OBSERVABILITY.4.5`; `.4.5` has since closed and the trace tree is done.

- 2026-07-04: **TRACE-OBSERVABILITY.4.3 — add Rust compile/spec-parser trace events**
  (RUST COMPILE/SPEC-PARSER/STAGED-DISPATCH EVENTS DONE; `.4.4` HAS SINCE CLOSED; TRACE TREE CLOSED AFTER .4.5).

  **Fix:** Wired the shared Rust trace emitter through core parse, validation, compile, dependency-regex mapping,
  full-spec user-function parsing, and staged parse-job dispatch. Routed debug traces now include
  `rust_core:parse_spec`, validation pass decisions, `rust_core:compile` rule/function decisions,
  `rust_core:compile:dependency_regex_map`, user-function-definition parser phases, full-spec function projection,
  and staged dispatcher normalize/queue/resolve/load/compile/execute decisions.

  **Verification:** Focused Rust trace controls, core trace unit tests, and source-emitter tests pass. mdBook,
  Knowledge Map, memory/doctrine, whitespace, and full local CI gates are part of the `.4.3` commit workflow.
  `.4.4` has since added runtime branch/mark/capture events, and `.4.5` has since closed the documented contract
  proof.

  **Frontier at completion:** `TRACE-OBSERVABILITY.4.4`; `.4.4` and `.4.5` have since closed and the trace tree is
  done.

- 2026-07-04: **TRACE-OBSERVABILITY.4.2 — add Rust trace controls**
  (RUST TRACE CONTROLS/SINKS DONE; `.4.3`/`.4.4` HAVE SINCE CLOSED; TRACE TREE CLOSED AFTER .4.5).

  **Fix:** Added the shared Rust trace control layer in `linkedspec-core::trace`: ordered levels and `DUMP_*`
  constants, `TraceConfig`, `TraceSinkMode`, `TraceEmitter`, environment-derived configuration, stdout/routed-file/
  mirror sinks, routed-file reset, and structured event primitives. `linkedspec-runtime::trace` re-exports the same
  surface, and opt-in traced entrypoints now exist beside core parse/validate/compile, full-spec user-function
  parsing, staged parse jobs, interpreter execution, generated-plan execution, generated parser execution, and
  emitted generated module `parse_with_trace(...)`.

  **Verification:** `cargo test -p linkedspec-core trace`; `cargo test -p linkedspec-runtime --test trace_controls`;
  `cargo test -p linkedspec-runtime --test source_emitter`; `cargo fmt`; mdBook; Knowledge Map; memory/doctrine;
  whitespace; full local CI. Full local CI includes phase0 at 1021 green. `.4.3` has since added compile/
  spec-parser/staged-dispatch events, `.4.4` has since added runtime branch/mark/capture events, and `.4.5` has
  since closed the parity proof.

  **Frontier at completion:** `TRACE-OBSERVABILITY.4.3`; `.4.3` through `.4.5` have since closed and the trace tree
  is done.

- 2026-07-04: **TRACE-OBSERVABILITY.4.1 — map Rust trace parity design**
  (RUST TRACE PARITY DESIGN INVENTORY DONE; `.4.2`/`.4.3`/`.4.4` HAVE SINCE CLOSED; TRACE TREE CLOSED AFTER .4.5).

  **Fix:** Mapped the mdBook trace contract onto Rust's real entrypoints and owner boundaries before code.
  `linkedspec-core` must own or expose the shared Rust trace levels/configuration/sink/event primitives because it
  owns parsing, validation, compilation, dependency-regex resolution, and compiled contract types.
  `linkedspec-runtime` then reuses the same model for full-spec user-function parsing, staged parser dispatch, interpreter
  execution, generated-plan execution, lifecycle blocks, rule dispatch, statement controls, repetition/AND/OR
  branch choices, and mark/capture helper operations.

  **Verification:** Targeted Rust inventory covered the core parser/compiler/type surfaces, runtime spec parser,
  engine, runtime context, source emitter, and public Rust harnesses. mdBook, Knowledge Map, memory/doctrine,
  whitespace, and local CI pass. An over-broad `cargo test` attempt failed in existing runtime integration tests
  with no Rust source diff, so `.4.1` uses the repo local CI gate for this docs/design slice.

  **Frontier at completion:** `TRACE-OBSERVABILITY.4.2`; `.4.2` through `.4.5` have since closed and the trace tree
  is done.

- 2026-07-04: **TRACE-OBSERVABILITY.3.5 — close trace contract and split parity**
  (TRACE CONTRACT CLOSEOUT DONE; `.4.1`/`.4.2`/`.4.3`/`.4.4` HAVE SINCE CLOSED; TRACE TREE CLOSED AFTER .4.5).

  **Fix:** Closed the overall trace no-drift/contract leaf. The mdBook now presents trace as a variant-neutral
  external contract: ordered levels, normal-entrypoint controls, stdout/routed-file/mirror sink behavior, file reset,
  enter/exit scope events, decision/branch events, mark/capture events where applicable, dump/log events, and
  unchanged default output. The required backend parity lane is split into `.4.*` leaves before Rust trace code.

  **Verification:** `perl bin/linkedspec --help` shows the trace controls; the nine-file Perl trace regression suite
  passes across CLI, generated-handler helper, non-REP dispatch, REP dispatch, RuleIR, EmitContext, ActionIR
  pipeline, compact lowerers, and MethodLowering; and `rg` over `rust/` excluding corpus fixtures finds no
  trace-control/API surface yet, confirming `.4.*` is required.

  **Frontier at completion:** `TRACE-OBSERVABILITY.4.1`; `.4.1` through `.4.5` have since closed and the trace tree
  is done.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4.6 — close compile ActionIR trace coverage**
  (COMPILE/ACTIONIR TRACE COVERAGE CLOSED; `.3.5` HAS SINCE CLOSED).

  **Fix:** Closed the compile/ActionIR trace lane after the planned Perl reference owner namespaces were covered:
  RuleIR planning, EmitContext owner bridge/rewrite orchestration, ActionIR scanner/canonical/diagnostic/rewrite
  pipeline, compact lowerers, and MethodLowering. A representative descriptor compile now shows those namespaces
  together and keeps the descriptor language-agnostic ready.

  **Verification:** A routed debug `LinkedSpec::Get(... return_descriptor => 1, trace_level => 'debug')` probe over
  return/set/receiver/control paths emitted `rule_ir`, `emit_context`, `actionir:scanner`,
  `actionir:rewrite_pipeline`, `actionir:control_flow`, and `actionir:method_lowering` decisions with
  `ready=1 raw=0 unresolved=0`. mdBook, Knowledge Map, memory/doctrine, whitespace, and full local CI pass. Full
  local CI includes phase0 at 1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.5`; `.3.5` has since closed and current frontier is
  `TRACE-OBSERVABILITY.4.2`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4.5 — trace MethodLowering decisions**
  (METHODLOWERING TRACE CLOSED; `.3.4.6` HAS SINCE CLOSED).

  **Fix:** `perl/LinkedSpec/ActionIR/MethodLowering.pm` now emits debug-level
  `DECISION actionir:method_lowering:<phase>:<label>:<decision>` events for helper-family selection,
  AST-vs-string fallback/bypass choices, unsupported helper exits, receiver-chain family transitions,
  assignment/mutation operators, mutation-slot value classification, return-payload fallback choices, and the
  `_lower_assign_statement` enter/exit boundary. The hooks use the shared lazy ActionIR trace seam, so require-only
  MethodLowering consumers and untraced owner calls still do not load `LinkedSpec::Trace`.

  **Verification:** `perl -c` coverage for `MethodLowering.pm` and `t/trace_actionir_method_lowering.t`, focused
  MethodLowering trace `prove`, adjacent RuleIR/EmitContext/ActionIR trace suites, ActionIR AST focused suite,
  mdBook, Knowledge Map, memory/doctrine, whitespace, and full local CI pass. Full local CI includes phase0 at
  1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4.6`; `.3.4.6` has since closed and current frontier is
  `TRACE-OBSERVABILITY.3.5`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4.4 — trace compact ActionIR lowerers**
  (COMPACT ACTIONIR LOWERER TRACE CLOSED; `.3.4.5` HAS SINCE CLOSED).

  **Fix:** `FlowExpr`, `ValueExpr`, `ArrayPipeline`, `DeclareMethod`, and `ControlFlow` now emit debug-level
  `DECISION actionir:<owner>:<phase>:<label>:<decision>` events and matching owner scopes for the compact lowering
  decisions outside `MethodLowering`. The trace reports flow-expression families, value direct access and
  assignment-source choices, array-pipeline plan/op construction, declaration initializer and set routing, and
  attached/inline/marker if/switch control paths. The book/task-tree now also state the trace capability contract
  as variant-agnostic: Perl reference mechanics are not enough for Rust/future trace parity unless the user-visible
  controls, levels, event classes, and sink behavior are equivalent. `MethodLowering.pm` remains owned by `.3.4.5`.

  **Verification:** `perl -c` coverage for the touched compact ActionIR owners and
  `t/trace_actionir_compact_lowerers.t`, focused compact-lowerer trace `prove`, adjacent RuleIR/EmitContext/
  ActionIR pipeline trace suites, ActionIR AST focused suite, mdBook, Knowledge Map, memory/doctrine, whitespace,
  and full local CI pass. Full local CI includes phase0 at 1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4.5`; `.3.4.5` and `.3.4.6` have since closed and current
  frontier is `TRACE-OBSERVABILITY.4.3`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4.3 — trace ActionIR pipeline decisions**
  (ACTIONIR PIPELINE TRACE CLOSED; `.3.4.4` HAS SINCE CLOSED).

  **Fix:** `perl/LinkedSpec/ActionIR/Trace.pm` now provides the shared lazy formatting seam for ActionIR owner
  internals, and the scanner, scanner-core, canonical-events, diagnostics, and rewrite-pipeline owners emit
  debug-level `DECISION actionir:<owner>:<phase>:<label>:<decision>` events plus matching owner scopes. The trace
  reports helper-event discovery, canonical queue/fallback decisions, unresolved helper diagnostics, RAW_PERL and
  unmatched-event fallback handling, source-span/contract skips, and implicit attached-if closure insertion or
  append decisions without loading `LinkedSpec::Trace` for require-only consumers.

  **Verification:** `perl -c` coverage for the touched ActionIR owners and `t/trace_actionir_pipeline.t`, focused
  `prove` for the new ActionIR pipeline trace regression, adjacent RuleIR/EmitContext/generated-handler trace
  suites, mdBook, Knowledge Map, memory/doctrine, whitespace, and full local CI pass. Full local CI includes phase0
  at 1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4.4`; `.3.4.4` through `.3.5` have since closed and current
  frontier is `TRACE-OBSERVABILITY.4.3`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4.2 — trace EmitContext owner bridge**
  (EMITCONTEXT OWNER-BRIDGE TRACE CLOSED; `.3.4.3` HAS SINCE CLOSED).

  **Fix:** `perl/LinkedSpec/RuleIR/EmitContext.pm` now emits debug-level
  `DECISION emit_context:<phase>:<label>:<decision>` events and matching owner/rewrite scopes for ActionIR owner
  package resolution, callback lookup, default dependency bundles, current function-registry injection,
  bare-symbol-kind injection, compatibility fallback paths, canonical rewrite-pipeline use, and rule emit-context
  build boundaries. Trace remains lazy for require-only EmitContext consumers and preserves delegated return
  context.

  **Verification:** `perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm`,
  `perl -c -Iperl t/trace_emit_context_bridge.t`, focused `prove`, paired RuleIR/EmitContext trace `prove`,
  mdBook, Knowledge Map, memory/doctrine, whitespace, and full local CI pass. Full local CI includes phase0 at
  1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4.3`; `.3.4.3` has since closed and current frontier is
  `TRACE-OBSERVABILITY.3.5`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4.1 — trace RuleIR planning decisions**
  (RULEIR PLANNING TRACE CLOSED; EMITCONTEXT FRONTIER HAS SINCE CLOSED).

  **Fix:** `perl/LinkedSpec/RuleIR.pm` now emits debug-level
  `DECISION rule_ir:<phase>:<rule>:<decision>` events for collection routing, explicit ACODE/BCODE edges,
  per-regex lifecycle routing, `MOVE_POS`/`MARK_POS` LECODE lowering, handler-variant selection, action-mode/
  execution-shape planning, and mixed-action validation. Normal descriptor compilation with
  `trace_level => 'debug'` exposes those decisions without changing parser metadata or generated behavior.

  **Verification:** `perl -c -Iperl perl/LinkedSpec/RuleIR.pm`,
  `perl -c -Iperl t/trace_ruleir_planning.t`, focused `prove`, mdBook, Knowledge Map, memory/doctrine,
  whitespace, and full local CI pass.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4.2`; `.3.4.2` through `.3.5` have since closed and current
  frontier is `TRACE-OBSERVABILITY.4.3`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.4 — split compile action trace coverage**
  (COMPILE/ACTIONIR TRACE COVERAGE SPLIT; RULEIR FRONTIER HAS SINCE CLOSED).

  **Split:** A read-only owner audit showed the compile/ActionIR trace leaf spans `RuleIR.pm`,
  `RuleIR/EmitContext.pm`, the scanner/canonical/diagnostic/rewrite owners, compact value/flow/control/declaration/
  array lowering owners, and the large `ActionIR::MethodLowering` owner. The parent `.3.4` is now split into
  signoff-sized children: `.3.4.1` RuleIR planning, `.3.4.2` EmitContext bridge, `.3.4.3` scanner/canonical/
  diagnostics/rewrite, `.3.4.4` compact lowering owners, `.3.4.5` MethodLowering, and `.3.4.6` closeout.

  **Verification:** Read-only `rg` trace call-site inventory, owner sizing with `wc -l`, targeted reads of RuleIR
  and EmitContext, and ActionIR owner inventory. No runtime/code behavior changed in the split.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4.1`; `.3.4.1` through `.3.5` have since closed and current
  frontier is `TRACE-OBSERVABILITY.4.3`.

- 2026-07-04: **TRACE-OBSERVABILITY.3.3 — trace repetition generated paths**
  (REP GENERATED HANDLER BRANCH TRACE CLOSED; TRACE-OBSERVABILITY.3.4 HAS SINCE SPLIT).

  **Fix:** Perl generated handlers for repetition runtime paths now wrap REP loop branch conditions with
  `LinkedSpec::Trace::trace_generated_handler_branch(...)`. Debug trace now reports REP loop entry,
  per-iteration success/failure, min-satisfied stop decisions, max-bound continuation/cutoff decisions, `REP_ACODE`
  match/acode-index dispatch, and bcode REP zero-progress cutoffs. Nested non-REP bcode helper calls stay quiet
  inside REP coderefs so REP trace lines remain loop-owned.

  **Verification:** `perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm`,
  `perl -c -Iperl t/trace_generated_rep_dispatch.t`, focused REP and non-REP `prove` runs, mdBook, Knowledge Map,
  memory/doctrine, whitespace, and full local CI pass. The REP regression locks runtime traces for `REP_ACODE` and
  `REP_AND_ACODE` and source-locks all four REP template families.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.4`; `.3.4` has since split, `.3.4.1` through `.3.4.6` have
  since closed, and `TRACE-OBSERVABILITY` has since closed.

- 2026-07-04: **TRACE-OBSERVABILITY.3.2 — trace non-repetition generated dispatch**
  (NON-REP GENERATED HANDLER BRANCH TRACE CLOSED; TRACE-OBSERVABILITY.3.3 HAS SINCE CLOSED).

  **Fix:** Perl generated handlers for non-repetition runtime paths now wrap emitted branch conditions with
  `LinkedSpec::Trace::trace_generated_handler_branch(...)`. Debug trace now reports match/miss, `LX` no-match,
  acode index dispatch, AND sequence index checks, bcode child-call dispatch, and bcode child-result decisions
  inside generated handler bodies. Repetition loop min/max/zero-progress branches have since closed under `.3.3`.

  **Verification:** `perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm`,
  `perl -c -Iperl t/trace_generated_nonrep_dispatch.t`, and focused `prove` pass. The regression isolates runtime
  trace from compile-time bootstrap trace and source-inspects a REP handler; the REP assertion has since been
  updated under `.3.3` to expect REP instrumentation. `tools/run_ci_local.sh` passes with phase0 at 1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.3`; `.3.3` has since closed, `.3.4` has since split, `.3.4.1`
  through `.4.1` have since closed, and `TRACE-OBSERVABILITY` has since closed.

- 2026-07-04: **TRACE-OBSERVABILITY.3.1 — add generated-handler trace helper seam**
  (HELPER CONTRACT CLOSED; TRACE-OBSERVABILITY.3.2 HAS SINCE CLOSED).

  **Fix:** Added `LinkedSpec::Trace::trace_generated_handler_branch(%args)`, the reusable Perl reference helper
  that generated handler templates can use for branch decisions. It returns the original branch boolean, emits a
  `generated_handler_branch:<handler_kind>:<rule_label>:<branch>` decision when tracing is enabled, skips lazy
  detail builders when trace is disabled, and captures detail-builder errors without perturbing parser behavior.

  **Verification:** `perl -c -Iperl perl/LinkedSpec/Trace.pm`, `perl -c -Iperl t/trace_generated_handler_branch.t`,
  focused `prove`, mdBook, Knowledge Map, memory/doctrine, whitespace, and `tools/run_ci_local.sh` pass. Full local
  CI includes phase0 at 1021 green. Template call-site wiring was left to `.3.2` and `.3.3`; `.3.2` has since
  closed non-repetition template wiring.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.2`; `.3.2` and `.3.3` have since closed, `.3.4` has since
  split, `.3.4.1` through `.4.1` have since closed, and `TRACE-OBSERVABILITY` has since closed.

- 2026-07-04: **TRACE-OBSERVABILITY.3 — split trace coverage extension**
  (DOCS-ONLY SPLIT CLOSED; TRACE-OBSERVABILITY.3.1 HAS SINCE CLOSED).

  **Split:** The broad "see everything" coverage leaf is now a sequence of executable children: `.3.1` generated
  handler trace helper seam, `.3.2` non-repetition generated dispatch decisions, `.3.3` repetition/min/max/
  zero-progress paths, `.3.4` compile/ActionIR owner scopes, and `.3.5` coverage closeout plus backend-parity
  split decision.

  **Verification:** Task-tree/frontier review plus memory/doctrine/Knowledge Map/whitespace gates. No runtime or
  CLI behavior changed in this split.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3.1`; `.3.1` through `.4.5` have since closed and the trace tree
  is done.

- 2026-07-04: **TRACE-OBSERVABILITY.2 — add trace CLI control**
  (DISCOVERABLE TRACE CONTROL CLOSED; TRACE-OBSERVABILITY.3 HAS SINCE SPLIT).

  **Fix:** Added `bin/linkedspec`, a Perl reference compile/run CLI that exposes existing trace controls through
  `--trace`, `--trace-file`, `--trace-mode`, `--trace-reset`, and `--trace-emoji`. The runner supports named specs,
  spec files, or inline spec source plus inline/file input, and prints parser results as canonical JSON. Routed
  trace mode keeps human trace output out of machine-readable stdout.

  **Verification:** `perl -c bin/linkedspec`, `perl -c -Iperl t/trace_cli.t`, `prove -v -Iperl t/trace_cli.t`,
  mdBook, Knowledge Map, memory/doctrine, whitespace, and `tools/run_ci_local.sh` pass. The focused regression
  proves CLI help exposes the trace flags and a routed high-level trace writes a non-empty trace log while stdout
  remains `["alpha","beta"]`; full local CI includes phase0 at 1021 green.

  **Frontier at completion:** `TRACE-OBSERVABILITY.3`; `.3` has since split, `.3.1` through `.4.5` have since
  closed, and the trace tree is done.

- 2026-07-04: **TRACE-OBSERVABILITY.1 — audit trace coverage gaps**
  (READ-ONLY AUDIT CLOSED; TRACE-OBSERVABILITY.2 HAS SINCE CLOSED).

  **Audit:** The Perl reference trace framework exists and works through env vars, per-call options, and
  `configure_trace(...)`, but coverage is not exhaustive. Current trace spans broad `Get`/parser invocation
  scopes, per-rule handler wrappers, selected compiler/resolver/validation decisions, dumps, and mark/capture
  events. At audit time generated handler bodies still contained untraced `while`/`foreach`/`if`/`unless` dispatch
  and repetition branches; `.3.2` and `.3.3` have since wired Perl reference generated templates. Most ActionIR
  owner branches still lack enter/exit or decision trace, and the Rust runtime has no equivalent trace API yet. The
  discoverable CLI flag gap has since closed under `TRACE-OBSERVABILITY.2`.

  **Verification:** `rg` call-site inventory, `dump_parser_source` probe, routed debug trace probe to
  `/tmp/linkedspec_trace_audit.log`, direct facade/owner trace-state probes, Rust trace search, mdBook build, and
  doctrine/memory gates.

  **Frontier at completion:** `TRACE-OBSERVABILITY.2`; `.2` has since closed, `.3` has since split, `.3.1`
  through `.4.5` have since closed, and the trace tree is done.

- 2026-07-04: **TOP-RULE-AS-NORMAL.3.2 — lock Rust recursive top-rule values**
  (TOP-RULE-AS-NORMAL TREE CLOSED; FRONTIER AT COMPLETION TRACE-OBSERVABILITY.1, NOW CLOSED).

  **Fix:** Rust `declare(...)` now resolves a raw first bare argument as the declaration type token, so
  `declare(array, items)` actually declares an array instead of evaluating `array` as an undefined variable.
  Declared working variables are scoped per rule invocation around interpreted and generated-plan direct rule
  execution; undeclared child mutations remain caller-visible. This fixes recursive `sexpr` parent/child
  accumulator leakage while preserving existing shared-state behavior for rules that do not declare locals.

  **Verification:** Focused top-rule integration passes (4 tests), Rust `corpus_oracle` passes 3 tests over 91
  fixtures, source-emitter tests pass, runtime lib tests pass, Rust formatting check passes, and
  `tools/gen_oracle_corpus.pl` syntax-checks. The three new corpus fixtures cover body recursion, nested top-rule
  `LX` recursion, and top-rule sequence recursion.

  **Frontier at completion:** `TRACE-OBSERVABILITY.1` — coverage audit before CLI/docs/coverage implementation;
  `.1` and `.2` have since closed, `.3` has since split, `.3.1` through `.3.5` have since closed, and the current
  frontier is `TRACE-OBSERVABILITY.4.3`.

- 2026-07-04: **RUST-PARITY.9 — finalize Rust parity documentation**
  (RUST-PARITY TREE CLOSED; TOP-RULE-AS-NORMAL.3.2 UNBLOCKED).

  **Fix:** Synchronized the roadmap, task-tree index, `ARCHITECTURE_STATE.md`, mdBook backend handoff, Rust README,
  and live recovery docs after the generated-source closeout. The project state now records the Rust interpreter
  oracle as green over 88 manifest fixtures plus drift guards, generated source as direct for every current
  structural family, and generated-source corpus proof as curated rather than exhaustive.

  **Verification:** mdBook, memory architecture, doctrine, whitespace, and full local CI gates pass. Full CI
  includes the 1021-test phase0 regression suite.

  **Frontier:** `TOP-RULE-AS-NORMAL.3.2` — recursive top-rule value parity now that the Rust recursive-grammar
  blocker has cleared.

- 2026-07-04: **RUST-PARITY.8.5 — integrate generated source with oracle corpus**
  (GENERATED SOURCE NOW HAS MANIFEST-BACKED CORPUS-SUBSET PROOF).

  **Fix:** The `source_emitter` integration test now loads the real oracle `manifest.json`, verifies the selected
  corpus case names are present, parses each case with the full user-function-aware parser, confirms interpreter
  output against `[expected.json]`, emits generated Rust modules for those compiled specs, and compiles/runs them in
  an isolated temp crate.

  **Verification:** Focused generated-source testing passes with three tests: all-family matrix, legacy
  `Repetition` compatibility, and the new manifest-backed subset. The subset covers authored oracle proofs,
  auto-existing arrays, primitive literals, attached if blocks, user-function runtime, shipped `tclite`, and shipped
  `portmap`. Limitation is explicit: this is generated-source proof on a curated subset, while the full 88-fixture
  corpus remains the interpreter oracle gate.

  **Frontier at completion:** `RUST-PARITY.9` — documentation sync/finalization; `.9` has since closed the tree.

- 2026-07-04: **RUST-PARITY.8.4 — emit REP generated families**
  (GENERATED SOURCE NOW DIRECTLY RUNS EXPLICIT REP SUBFAMILIES).

  **Fix:** `source_emitter` now classifies repetition rules as `RepAcode`, `RepBcode`, `RepAndAcode`, or
  `RepAndBcode`, and `GeneratedPlanExecutor` routes those families directly. The shared Rust runtime now handles
  repeated blind-call OR choice and AND sequence loops with min/max bounds and zero-progress termination. REP-AND
  acode execution counts complete ordered regex groups, so `IT` fires once per group rather than once per slot.

  **Verification:** Focused Rust formatting, generated-source matrix, runtime library tests, and clippy pass. The
  source-emitter matrix covers every non-REP and REP generated family, plus zero-progress and same-position
  recursive-call termination, and builds/runs all generated modules in an isolated temp crate; a compatibility lock
  proves legacy `Repetition` plan rows still run through direct REP specialization. mdBook, Knowledge Map, memory,
  doctrine, whitespace, and full local CI pass; full CI includes 1021 phase0 regression tests.

  **Frontier at completion:** `RUST-PARITY.8.5` — integrate generated-source validation with the oracle/corpus
  contract; `.9` has since closed the tree.

- 2026-07-04: **RUST-PARITY.8.3.5 — close non-REP generated matrix**
  (GENERATED SOURCE NOW ROUTES EVERY NON-REP FAMILY DIRECTLY).

  **Fix:** `GeneratedPlanExecutor` now dispatches exhaustively by `GeneratedRuleFamily`. The six non-repetition
  families (`Default`, `OrAcode`, `AndSingleAcode`, `AndAcodeSeq`, `AndBcode`, and `OrBcode`) run through direct
  generated execution. At `.8.3.5` completion, `Repetition` was the only remaining fallback family; `.8.4` has
  since replaced it with explicit direct REP families.

  **Verification:** Focused Rust formatting, generated-source matrix, runtime library tests, and focused clippy
  pass. The source-emitter matrix asserts complete coverage of the non-REP family set before REP work starts.

  **Frontier at completion:** `.8.4` emitted repetition handler families and termination guards; `.8.5` and `.9`
  have since closed the tree.

- 2026-07-04: **RUST-PARITY.8.3.4 — emit direct bcode execution**
  (GENERATED SOURCE NOW DIRECTLY RUNS AND/OR BCODE FAMILIES).

  **Fix:** `GeneratedPlanExecutor` now treats `AndBcode` and `OrBcode` as direct generated families. Blind-call
  tail execution is shared with the interpreter, so child returns become parent `retv`, attached blind-edge code and
  fluent calls run in order, and the parent `E` block sees the resulting `retv`. Explicit OR bcode dispatch stops
  after the first truthy child return and fires `LX` on no child match.

  **Verification:** Focused Rust formatting, generated-source matrix, runtime library tests, focused clippy,
  mdBook, Knowledge Map, memory, doctrine, whitespace, and full local CI pass. The matrix proves AND bcode ordered
  child-return collection (`A`, `B`), OR bcode first-match behavior on `a b` (`or-bcode:A`), and OR bcode no-match
  `LX` behavior on `c` (`or-miss`). The full local CI gate includes 1021 phase0 regression tests.

  **Frontier at completion:** `RUST-PARITY.8.3.5` closed the non-repetition generated-family matrix; `.8.4` is now
  the current frontier.

- 2026-07-04: **RUST-PARITY.8.3.3 — emit direct AND acode execution**
  (GENERATED SOURCE NOW DIRECTLY RUNS AND ACODE FAMILIES).

  **Fix:** `GeneratedPlanExecutor` now treats `AndSingleAcode` and `AndAcodeSeq` as direct acode families. The
  shared Rust regex/acode loop now enforces ordered non-repetition AND sequence: slot 0, then slot 1, and so on;
  out-of-order or incomplete sequence returns `undef` before the rule exit block. This keeps generated execution,
  interpreted Rust execution, and the Perl HandlerIR ordered-consume contract aligned for the covered cases.

  **Verification:** Focused Rust formatting, generated-source matrix, runtime library tests, and focused clippy
  pass. The matrix includes an AND sequential-acode case that only returns from the second ordered slot
  (`a b` -> `and-seq`), proving the direct path does not stop after the first regex.

  **Frontier at completion:** `RUST-PARITY.8.3.3` emitted direct AND acode generated execution; `.8.3.3`
  completed with the frontier advanced to `.8.3.4`; `.8.3.4` and `.8.3.5` are now done and the current frontier is
  `.8.4`.

- 2026-07-04: **RUST-PARITY.8.3.2 — emit direct default-or acode execution**
  (GENERATED SOURCE NOW DIRECTLY RUNS THE FIRST ACODE FAMILIES).

  **Fix:** Generated `parse(input)` still validates `GENERATED_RULES`, but now calls the plan-aware generated
  executor instead of `Engine::execute(...)`. `Default` and `OrAcode` rules run directly with interpreter-equivalent
  lifecycle semantics: recursion guard, entry/local match scoping, lifecycle blocks, action-edge child-return
  scoping, default repetition, and zero-progress termination. At `.8.3.2` completion, later-family paths remained
  owned by later leaves; `.8.3.3` and `.8.3.4` have since closed the AND acode and AND/OR bcode parts, leaving REP
  for `.8.4`.

  **Verification:** Focused Rust formatting and `source_emitter` integration test pass. The generated-source matrix
  now proves a repeated default case and an OR acode action-edge block that reads the dispatched child return, then
  builds/runs the generated modules in an isolated temp crate.

  **Frontier:** `RUST-PARITY.8.3.3` — emit direct AND acode generated execution.

- 2026-07-04: **RUST-PARITY.8.3.1 — emit generated family plan**
  (GENERATED SOURCE NOW CARRIES VALIDATED RULE-FAMILY METADATA).

  **Fix:** `CompiledRule` preserves parsed `RuleMode`, and generated Rust source now embeds a `GENERATED_RULES`
  family plan. `source_emitter` classifies default, OR acode, AND single-acode, AND sequential-acode, AND bcode,
  OR bcode, and repetition markers, then validates generated plan rows against the embedded compiled spec before
  delegating through the existing `Engine`.

  **Verification:** Focused Rust formatting, `types_test`, `source_emitter`, and clippy checks pass. The generated
  source test builds one isolated temp crate containing generated modules for the non-REP family-plan matrix and
  verifies each generated `parse(...)` path still matches interpreter output.

  **Frontier at completion:** `RUST-PARITY.8.3.2` emitted direct default/OR acode generated execution; `.8.3.2`
  completed with the frontier advanced to `.8.3.3`; `.8.3.3` and `.8.3.4` are now done and the current frontier is
  `.8.3.5`.

- 2026-07-04: **RUST-PARITY.8.3 — split non-repetition emitter lane**
  (NON-REP GENERATED-SOURCE WORK IS NOW DECOMPOSED BEFORE CODE).

  **Fix:** No Rust source behavior changed. The broad `.8.3` leaf is now a split container because it still
  bundled rule-mode/family metadata, generated family-plan emission, direct acode execution, direct bcode
  execution, and final matrix closeout.

  **Verification:** Task/KM/code context read. The split records the concrete metadata gap: current
  `CompiledRule` shape does not carry enough parsed mode/family data for generated source to distinguish OR-bcode
  from AND-bcode robustly.

  **Frontier at completion:** `RUST-PARITY.8.3.1` carried rule-mode/family metadata and generated non-REP
  family-plan emission; `.8.3.1`–`.8.3.5` are done, `.8.4` added direct REP families, and current frontier is
  `.8.5`.

- 2026-07-04: **RUST-PARITY.8.2 — add Rust source emitter scaffold**
  (GENERATED RUST-SOURCE API AND ISOLATED COMPILE/RUN HARNESS ARE NOW IN PLACE).

  **Fix:** `linkedspec-runtime` now exports `source_emitter::emit_rust_source(&CompiledSpec)`. The emitted module
  embeds the serialized compiled spec, exposes a source-format marker, and provides a generated `parse(input)`
  entry point that delegates through the existing interpreter `Engine`.

  **Verification:** Focused Rust formatting/checks pass; the new `source_emitter` integration test confirms the
  interpreter result, builds the emitted module in an isolated temporary crate with offline Cargo, and executes the
  generated parser on a simple non-recursive case.

  **Frontier:** `RUST-PARITY.8.3.2` has since become current after `.8.3` split the non-repetition emitter lane.

- 2026-07-04: **RUST-PARITY.8.1 — split Rust source emitter lane**
  (CODE-GENERATION EMITTER WORK IS OWNED BY CHILD LEAVES BEFORE IMPLEMENTATION).

  **Fix:** No parser/runtime behavior changed. The broad `.8` leaf is now a parent lane for the generated
  Rust-source path. The split records the durable boundary: Perl HandlerIR has 10 structural variants and
  Perl/JSON emitters, while Rust currently executes an interpreted `CompiledSpec`/`CompiledRule` contract with
  parsed lifecycle `CodeBlock`s and action/blind dispatch tables.

  **Verification:** Source audit covered the HandlerIR fact card, `perl/LinkedSpec/HandlerVariantEmitter.pm`,
  Rust compiled/runtime structures, `rust/README.md`, and mdBook backend handoff. Child leaves now own the
  minimal emitter scaffold/compile-run harness, non-REP families, REP families, and all-variant/oracle
  integration.

  **Frontier:** `RUST-PARITY.8.3.2` has since become current after `.8.2` landed the generated-source
  scaffold/compile-run harness and `.8.3` split the non-REP lane.

- 2026-07-04: **RUST-PARITY.7.4 — finalize oracle corpus manifest guard**
  (ORACLE CORPUS NOW HAS MANIFEST-BACKED MISSING/STALE FIXTURE DRIFT DETECTION).

  **Fix:** `tools/gen_oracle_corpus.pl` now rejects duplicate case names and writes root
  `rust/linkedspec-runtime/tests/corpus/manifest.json` with `format`, `generated_by`, `case_count`, and ordered
  `cases`. The Rust oracle runner loads that manifest, validates format/count/name shape, rejects missing fixture
  directories, rejects stale extra fixture directories, and executes fixtures in manifest order.

  **Verification:** `perl -c -Iperl tools/gen_oracle_corpus.pl` passes; oracle regeneration emits **88 fixtures
  plus manifest**; `cargo fmt --manifest-path rust/Cargo.toml --all` passes; Rust `corpus_oracle` passes **3
  tests**, including missing/stale drift guards and all **88** manifest-listed fixtures. `.7` is closed.

  **Frontier at completion:** `RUST-PARITY.8.4` later closed direct REP generated-family execution; `.8.5` and
  `.9` have since closed the tree.

- 2026-07-04: **RUST-PARITY.7.3.6 — land legacy shipped-spec safety smokes**
  (SEVEN RTL/PLUGIN/LEGACY SMOKES ARE ORACLE-GREEN; RICHER MISMATCHES ROUTED FOR FOLLOW-UP).

  **Fix:** No Rust runtime behavior changed. The remaining shipped-spec candidates were audited before fixture
  promotion. Seven measured green smokes are active: `regdef_nested_register_fields`, `tablegrep_simple_term`,
  `simenv_multiline_value`, `vhdl_library_use`, `ds_vhistory_version_entry`, `pplugin_empty`, and `tkgui_empty`.
  Richer `pplugin`, `tkgui`, `sdce`, recursive `tablegrep`, `simenv`, VHDL, `ds_vhistory`, and `verilog`
  candidates remain explicit follow-up blockers instead of unsafe oracle additions.

  **Verification:** Perl reference JSON probes and temporary Rust candidate probes identified the green/mismatch
  boundary; temporary probe files were removed. `perl -c -Iperl tools/gen_oracle_corpus.pl` passes; oracle
  regeneration emits **88 fixtures**; Rust `corpus_oracle` passes all 88; `parse_all_shipped_specs` parses all 21
  shipped specs successfully with only known non-target action-code warnings; full local CI passes, including
  phase0 **1021** tests.

  **Frontier at completion:** `RUST-PARITY.7.4` has since completed, `.8.1` split the code-generation lane, `.8.2` landed the
  generated-source scaffold, and `.8.3.1`–`.8.3.5` closed the non-REP family-plan, acode, bcode
  direct-execution slices, matrix closeout, and REP direct execution; `.8.5` and `.9` have since closed the tree.

- 2026-07-04: **RUST-PARITY.7.3.5 — close null-output and spec smoke triage**
  (`spec.spec` SMOKES ARE ORACLE-GREEN; DEBUG-ONLY NULL CANDIDATES NOT PROMOTED).

  **Fix:** Rust's `.spec` code-block brace scanner now ignores braces inside single- and double-quoted strings,
  including escaped characters. This removes the `operators_try` action-parser warnings caused by debug strings
  such as `"{start-group"` being misread as block delimiters. The triage also records that `BNF`, `DT`, `ifelse`,
  and `operators_try` produce Perl `null` for the representative inputs, so they are not useful semantic-output
  oracle fixtures today.

  **Verification:** Perl reference probes separated null-output candidates from real parser warnings; focused Rust
  parser tests pass; `parse_all_shipped_specs` passes with the `operators_try` quoted-brace warnings gone; `perl -c
  -Iperl tools/gen_oracle_corpus.pl` passes; oracle regeneration emits **81 fixtures** including
  `spec_spec_minimal_rule`, `spec_spec_action_edge`, `spec_spec_user_function_definition`, and
  `spec_spec_comment_skip`; Rust `corpus_oracle` passes all 81.

  **Frontier:** `RUST-PARITY.7.3.6` — audit RTL/plugin/legacy shipped-spec candidates under the hardened timeout
  guard.

- 2026-07-04: **RUST-PARITY.7.3.4.3 — land action-edge child aggregation parity**
  (EBNF PAYLOADS AND PORTMAP CONCATENATION NOW ORACLE-GREEN).

  **Fix:** Rust action-edge block/fluent execution now reuses the already matched edge child return for
  `call(child)`, `push(child)`, `push(child,target)`, and child-index push forms. Passive terminal children are not
  re-searched after the parent edge consumes their regex. Runtime assignment/helper boundaries were tightened so
  scalar non-shape assignment does not overwrite aggregate slots and helper-context bare aggregate arguments read
  the aggregate store when needed.

  **Verification:** Focused `.7.3.4.3` Rust integration tests pass, the Perl-style `{,N}` regex normalization unit
  test passes, `perl -c -Iperl tools/gen_oracle_corpus.pl` passes, oracle regeneration emits **77 fixtures**, and
  Rust `corpus_oracle` passes all 77. Full local CI passes, including phase0 **1021** tests. The mdBook surface
  was already aligned for these user-facing helper forms; this slice verifies the Rust backend now conforms.

  **Frontier:** `RUST-PARITY.7.3.5` — triage `.7.2` null/action-parser candidates (`BNF`, `DT`, `ifelse`,
  `operators_try`, and `spec.spec` smokes).

- 2026-07-04: **SPEC-FORMAT-TERSE.7.4 — close type-method no-drift sweep**
  (TYPE-METHOD LANE CLOSED; SPEC-FORMAT-TERSE FRONTIER EMPTY).

  **Fix:** Reconciled current roadmap, task-tree index, mdBook helper/reference summaries, and Knowledge Map facts
  after the `.7.3` array reducer receiver backfill. Current-facing docs now agree that supported receiver families
  are string/scalar, array/list, hash, and number; array numeric reducers are terminal array/list receiver methods,
  not scalar number receiver links; and mutation/lifecycle/control/child-dispatch/parser-state/declaration/
  compatibility helpers remain explicit unless a future leaf defines safe receiver semantics.

  **Verification:** Focused drift scans covered stale `.7` frontier text, 73/74 fixture wording, receiver-family
  summaries, numeric reducer statements, tests, corpus, mdBook, and Knowledge Map facts. `mdbook build
  docs/linkedspec-book`, Knowledge Map regeneration/check, memory/doctrine checks, and `git diff --check` pass.

  **Frontier at that time:** no `SPEC-FORMAT-TERSE` leaf was pending. Later `.15` colon scalar-slot retirement
  reactivated the terse frontier.

- 2026-07-04: **SPEC-FORMAT-TERSE.7.3 — backfill array numeric reducer receiver methods**
  (ARRAY/LIST NUMERIC REDUCERS ARE TERMINAL RECEIVER METHODS).
  Array/list receivers now support `sum`, `avg`, `median`, `range`, `min`, and `max` as pure terminal methods.

  **Fix:** Perl receiver chains lower those reducer methods through the existing aggregate helper family,
  including array-returning links such as `scores.sorted().take(3).avg()` and pure internal array-pipeline links
  such as `scores.uniq().sum()`. Invalid reducer continuations such as `scores.sum().drop_front(1)` return
  `undef`/`null`. Rust mirrors the receiver surface, treats array terminal methods as chain-ending, and supports
  documented single-array `num_min(array_expr)` / `num_max(array_expr)` and `min(array_expr)` / `max(array_expr)`.
  Hash receiver methods from `.7.1` already covered the useful pure hash surface; mutating and ambiguous helpers
  remain explicit statement/function forms.

  **Verification:** Perl phase0 passes with **1021** tests; focused Rust `terse_7_3` tests pass; oracle
  regeneration emits **74** fixtures and Rust `corpus_oracle` passes all 74; `mdbook build docs/linkedspec-book`
  and `cargo fmt --manifest-path rust/Cargo.toml --all --check` pass.

  **Frontier:** `SPEC-FORMAT-TERSE.7.4` — final type-method no-drift sweep across codebase, mdBook, helper
  catalog, examples, tests, and Knowledge Map.

- 2026-07-04: **SPEC-FORMAT-TERSE.7.2 — verify string method surface**
  (STRING/SCALAR RECEIVER BACKFILL CLOSED; NO CODE CHANGE).
  `substr()` and the other useful pure string/scalar receiver methods are already implemented and documented on
  Perl/Rust.

  **Fix:** task-tree, roadmap, live docs, and Knowledge Map now record that `.7.2` was a verification slice. The
  string/scalar receiver family already covers `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`,
  `rm_suffix`, `substr`, `concat`/`cat`, `coalesce_nonempty`, `split` as the array bridge, and terminal
  `length`/predicate helpers. Statement regex substitution through `substr(:target, pattern, replacement, flags)`
  remains an explicit mutation boundary.

  **Verification:** focused Perl runtime probe returns `["BCD", "BCD", 2]` for receiver `substr`, helper
  `substr`, and split bridge evidence; descriptor metadata is `ready=1`, `fallback=0`, `raw=0`, `unresolved=0`;
  focused Rust `terse_2_3_5_3` tests pass. Existing mdBook pages already demonstrate method/helper equivalence.

  **Frontier:** `SPEC-FORMAT-TERSE.7.3` — audit/backfill useful array/list, hash, and number receiver methods
  while keeping mutation or ambiguous helpers explicit.

- 2026-07-04: **SPEC-FORMAT-TERSE.7.1 — inventory type method surface**
  (PRE-CODE TYPE/METHOD AUDIT; STRING `substr()` VERIFIED AS EXISTING RECEIVER METHOD).
  The supported receiver/value families are now recorded before any implementation backfill.

  **Fix:** the task tree, roadmap, mdBook helper catalog, Knowledge Map, and live docs now agree that
  string/scalar, array/list, hash, and number are the existing receiver families; booleans/flow results are
  terminal; block-yielded values and user-function returns dispatch by yielded runtime type; and mutation,
  lifecycle/control, child-dispatch, parser-state reader, declaration, and compatibility helpers stay
  function/statement/lifecycle-only unless a future leaf designs safe receiver semantics. The audit records that
  `substr()` is already accepted as a string/scalar receiver method.

  **Verification:** focused Perl/Rust classifier scans pass; mdBook builds; Knowledge Map regenerates/checks;
  memory/doctrine/diff gates pass; Rust `corpus_oracle` passes all **73** fixtures; and full local CI passes.

  **Frontier:** `SPEC-FORMAT-TERSE.7.2` — verify/backfill string/scalar receiver methods and lock method/helper
  equivalence docs/tests, starting from the existing `substr()` method evidence.

- 2026-07-04: **SPEC-FORMAT-TERSE.6.4 — lock declare compatibility policy**
  (DECLARATION RETIREMENT CLOSED; LEGACY COMPATIBILITY POLICY RECORDED).
  At this historical leaf, declaration helpers were kept as compatibility syntax for existing specs, but they were
  no longer current authoring syntax. `SPEC-FORMAT-TERSE.8` later superseded that retention policy and hard-retired
  the helpers.

  **Fix:** ADR `0018`, the mdBook declaration reference, helper catalog, project status page, Knowledge Map, task
  tree, and roadmap stated the same policy for that slice: new shipped specs, public examples, and current corpus
  examples used auto-existing variables plus terse assignment/mutation forms.

  **Verification:** shipped-spec declaration scans remain clean; current-facing doc scans classify residual hits as
  legacy/reference/status material; mdBook builds; Knowledge Map regenerates/checks; memory/doctrine/diff gates
  pass; Rust `corpus_oracle` passes all **73** fixtures; phase0 remains **1020** green; and full local CI passes.

  **Frontier:** `SPEC-FORMAT-TERSE.7.1` — audit supported types and helper families before adding/backfilling
  methods such as string `substr()`.

- 2026-07-04: **SPEC-FORMAT-TERSE.6.3 — sweep docs and corpus declare examples**
  (PUBLIC DOCS/CORPUS TERSE-SURFACE SWEEP; COMPATIBILITY HOLDOUTS CLASSIFIED).
  Current-facing mdBook examples and root checked-in corpus specs now teach terse working-variable
  initialization/mutation and canonical helpers instead of active `declare(...)` or older helper names.

  **Fix:** root `tests/corpus/simple_grammar`, `tests/corpus/tablegrep`, and `tests/corpus/lispish` moved to
  auto-existing variables, assignments, direct shapes, `push(...)`, `copy(...)`, and `cat(...)`. Generated Rust
  oracle inputs now use canonical helper spellings where old spellings were incidental, while compatibility
  fixtures keep their old spellings deliberately. A new Knowledge Map card records that
  `merge_hash(base, overlay)` is not equivalent to `merge_hash(copy(hash(base)), overlay)` today.

  **Verification:** focused current-facing doc/corpus scans pass; root corpus probes preserve existing outputs;
  oracle regeneration remains **73 fixtures** with no `expected.json` drift; Rust `corpus_oracle` passes all 73;
  `mdbook build docs/linkedspec-book` passes; phase0 passes with **1020** tests; and full local CI passes.

  **Frontier:** `SPEC-FORMAT-TERSE.6.4` — decide post-migration compatibility support for declaration helpers.

- 2026-07-04: **SPEC-FORMAT-TERSE.6.2.4 — verify shipped-spec terse surface**
  (FINAL SHIPPED-SPEC NO-DRIFT CHECK; DOCS/CORPUS SWEEP HANDOFF).
  Final shipped-spec verification is complete before the broader `.6.3` public docs/corpus sweep.

  **Verification:** all 21 shipped `specs/*.spec` files descriptor-compile from this checkout with `perl -Iperl`;
  shipped-spec scans are clean for `scalar(...)`, `assign(...)`, `declare(...)`, `.declare(...)`, and old helper
  spellings; phase0 passes with **1020** tests; oracle regeneration stays stable at **73 fixtures** with no
  tracked corpus diff; Rust `corpus_oracle` passes all 73 fixtures; and `mdbook build docs/linkedspec-book`
  passes with no `scalar(...)` / `assign(...)` book hits. Full local CI (`bash tools/run_ci_local.sh`) passes.

  **Inventory:** checked-in corpus/test specs and public-book reference/walkthrough chapters still contain
  `declare(...)` and older helper references outside shipped `specs/*.spec`. Those are explicitly owned by
  `SPEC-FORMAT-TERSE.6.3`, not left as hidden drift.

  **Frontier:** `SPEC-FORMAT-TERSE.6.3` — sweep public docs, checked-in corpus/test specs, and current-facing
  examples after shipped specs are clean.

- 2026-07-04: **SPEC-FORMAT-TERSE.6.2.3.2 — retire `scalar(...)` and `assign(...)` from authored specs**
  (TERSE SPEC SURFACE HARD RETIREMENT; PERL/RUST TYPE MEMORY).
  Authored/current `.spec` files now use `:name` for scalar slots and `LHS = RHS` or `set(...)` for
  assignment. `scalar(...)` is no longer a supported scalar-slot wrapper in the DSL, and `assign(...)` is no
  longer an assignment alias; backend Perl built-ins such as `scalar(@...)` remain implementation details.

  **Fix:** Perl lowers `:name` directly and records initialized bare identifier kind from direct assignment,
  parser-normalized `set(...)`, and aggregate mutation positions, so later bare reads/copies reuse scalar/array/hash
  kind without wrappers. Rust records the same bare kind in `RuntimeContext`, evaluates bare variables through that
  remembered kind, and keeps explicit `Expr::ScalarSlot` for `:name`.

  **Verification:** active authored spec/corpus scan for `scalar(` / `assign(` is clean; mdBook scan is clean;
  phase0 passes with **1020** tests; focused ActionIR parser tests pass; focused Rust core/runtime tests for
  scalar-slot shorthand and remembered bare kind pass.

  **Frontier:** `SPEC-FORMAT-TERSE.6.2.4` — final shipped-spec terse-surface verification and no-drift inventory.

- 2026-07-03: **SPEC-FORMAT-TERSE.6.2.3.1 — scalar-slot shorthand `:name`**
  (TERSE SCALAR READ/TARGET SYNTAX; PERL/RUST LOCKSTEP).
  LinkedSpec now accepts `:name` as the terse spelling for the scalar slot named `name`. In value positions,
  `:name` reads the same scalar value as `scalar(name)`. In assignment-like target positions,
  `set(:payload, [value])` and `assign(:payload, [value])` keep the scalar payload boundary, while bare
  `set(payload, [value])` still infers array assignment.

  **Fix:** Perl lowering recognizes `:name` in scalar source slots, direct shape literals, legacy constructors,
  scalar assignment targets, and the autodeclare collector. Rust adds a dedicated `Expr::ScalarSlot` parser/runtime
  node and resolves it through scalar evaluation/target paths without changing direct-shape aggregate inference.

  **Verification:** Perl syntax checks for the edited modules pass; focused lowering probes pass; phase0 passes
  with **1019** tests; Rust core/runtime focused tests pass; oracle regeneration produces **73 fixtures** including
  `terse_6_2_3_1_scalar_slot_shorthand`; Rust `corpus_oracle` passes over all 73 fixtures. mdBook and Knowledge
  Map were updated.

  **Frontier:** `SPEC-FORMAT-TERSE.6.2.3.2` — migrate shipped-spec typed-wrapper usage to `:name`, bare aggregate
  reads, and direct shape literals where unambiguous; split or annotate remaining compatibility holdouts.

- 2026-07-03: **RUST-PARITY.7.3.4.2 — portmap scalar helper parity**
  (RUST RUNTIME HELPER/DISPATCH FIX + FOUR ORACLE FIXTURES).
  Rust now reproduces the Perl reference for representative `specs/portmap.spec` scalar classifications:
  `foo` -> `["?bare:",["foo"]]`, `bar[3]` -> `["?bit:",["bar","3"]]`,
  `baz[7:0]` -> `["?slice:",["baz","7","0"]]`, and `0x1f` -> `["?constant:",["0x1f"]]`.

  **Fix:** Rust validation/runtime now recognize `or`, `and`, and `not`; `array(...)` now splices explicit
  flattening helper arguments (`flat`, `flat_array`, `flat_hash`) in Perl list context while keeping
  `array_copy(...)` nested; and the regex dispatcher wraps each rule regex before joining alternatives so an
  internal `|` branch cannot steal a sibling action-edge dispatch index.

  **Verification:** focused `.7.3.4.2` integration tests pass; the regex-engine internal-alternation regression
  passes; `perl -c -Iperl tools/gen_oracle_corpus.pl` passes; oracle regeneration produces **72 fixtures**
  including `portmap_bare`, `portmap_bit`, `portmap_slice`, and `portmap_constant`; Rust `corpus_oracle` passes
  over all 72 fixtures; clippy, mdBook, Knowledge Map, memory architecture, doctrine, and whitespace gates pass.

  **Then-frontier:** `RUST-PARITY.7.3.4.3` — fix action-edge fluent child/target aggregation for `ebnf` payloads and
  `portmap` concatenation.

- 2026-07-03: **RUST-PARITY.7.3.4.4 — lib_reader action-helper parity**
  (RUST RUNTIME HELPER FIX + TWO ORACLE FIXTURES).
  Rust now executes the statement-form helper mutations used by `specs/lib_reader.spec`: scalar regex substitution
  through `substr(scalar(target), pattern, replacement, flags)` / `regex_subst(...)`, and array target replacement
  through `split(array(target), scalar(source), delimiter)`.

  **Clarification:** the dependency-resolved edge-only child-regex capture path is now locked by a focused
  regression and was not the remaining failure. The representative `lib_reader` null/quoted fields were caused by
  the missing statement-form mutation helpers after `.7.3.4.1` made the top dispatch reachable.

  **Verification:** focused `.7.3.4.4` integration tests pass; `perl -c -Iperl tools/gen_oracle_corpus.pl` passes;
  oracle regeneration produces **68 fixtures** including `lib_reader_sattribute` and `lib_reader_cattribute`;
  Rust `corpus_oracle` passes over all 68 fixtures; mdBook, Knowledge Map, memory architecture, doctrine, and
  whitespace gates pass. Broad `linkedspec-runtime` package testing passes 124 unit tests and the 68-fixture corpus
  oracle, then reproduces the known 9 unrelated integration failures (141 passed / 9 failed).

  **Frontier:** `RUST-PARITY.7.3.4.2` — fix runtime boolean/list-context parity exposed by `portmap` scalar
  classification.

- 2026-07-03: **SPEC-FORMAT-TERSE.6.2.2 — shipped specs use canonical terse helper spellings**
  (SHIPPED-SPEC MIGRATION; OLD HELPER ALIASES REMAIN COMPATIBILITY SUPPORT).
  Migrated active shipped-spec `assign(...)`, `push_value(...)`, `array_copy(...)`, `hash_copy(...)`, and
  `concat(...)` spellings to `set(...)`, `push(...)`, `copy(...)`, and `cat(...)` where the terse equivalent
  already ships. `portmap.spec` also now omits redundant standalone flow-marker separators after `if(...)`,
  `elseif(...)`, and `else()`.

  **Verification:** old-helper scan over `specs/` is clean; the `portmap.spec` standalone flow-marker separator
  scan is clean; registered descriptor compilation passes for all 21 shipped specs; phase0 passes with **1018**
  tests; Rust `corpus_oracle` passes over **66 fixtures**.

  **Frontier:** `SPEC-FORMAT-TERSE.6.2.3` — migrate typed wrappers/constructors toward bare reads and direct
  shape literals where accepted terse inference makes the replacement unambiguous.

- 2026-07-03: **SPEC-FORMAT-TERSE.6.2.1 — shipped specs no longer use `declare(...)`**
  (SHIPPED-SPEC MIGRATION; NO RUNTIME DECLARE EXPANSION).
  Removed active `declare(...)` and fluent `.declare(...)` use from the 13 shipped specs inventoried by `.6.1`.
  Replacement forms use the landed terse surface: `name = value`, `name = undef`, `items = []`, and structured
  lifecycle blocks where old fluent declaration chains needed ordered follow-up statements.

  **Verification:** `rg -n 'declare\(|\.declare\(' specs` is clean; focused descriptor compilation passes for all
  edited shipped specs; phase0 passes with **1018** tests; Rust `corpus_oracle` passes over **66 fixtures**;
  mdBook builds; full local CI passes.

  **Frontier:** `SPEC-FORMAT-TERSE.6.2.2` — migrate old helper spellings (`assign`, `push_value`,
  `array_copy`/`hash_copy`, `concat`, etc.) after the declaration-only slice is committed.

  **Backlog captured:** the supported-type method audit, including the user's explicit string `substr()` method
  directive, is tracked as `SPEC-FORMAT-TERSE.7.1` after the `.6` migration lane unless explicitly reprioritized.

- 2026-07-03: **SPEC-FORMAT-TERSE.6.1 — declaration retirement migration owned**
  (TRACKING/PUBLIC-GUIDANCE SLICE; NO `.spec` FILE CHANGED).
  The directive that `declare(...)` shall not be used in spec files is now owned under the existing terse-format
  task tree. This implements ADR `0007`'s gradual migration path rather than expanding runtime `declare` behavior.

  **Inventory:** 70 active `declare(...)` hits across 13 shipped specs under `specs/`.

  **Frontier:** `SPEC-FORMAT-TERSE.6.2` — migrate shipped specs to auto-existing variables, assignments, direct
  shape literals, and type-implying terse positions. `RUST-PARITY.7.3.4.4` has since closed; see the current top
  entry for the active Rust frontier.

- 2026-07-03: **RUST-PARITY.7.3.4.1 — header-rest action-edge parsing**
  (RUST PARSER/COMPILER FIX; NO ORACLE FIXTURE LANDED).
  Rust now keeps compact header-rest body syntax instead of consuming it as an invalid mode suffix. This repairs
  regex-less top rules such as `lib_file:: -> group .push` and compact forms such as `Top::->Child.push`.

  **Spacing contract:** The project grammar does not require a space after `->` or `=>`; `specs/spec.spec` uses
  `->[ \t]*` and `=>[ \t]*`. The Rust parser now follows that optional-whitespace contract.

  **Verification:** Focused parser/compiler/runtime tests cover spaced and compact header-rest action edges,
  compact blind-call edges, compiled dependency-resolved `.push` dispatch, and compact runtime dispatch. A real
  `lib_reader` compiled-rule dump now includes the top `group` action dispatch; representative probes no longer
  collapse to `[[]]`.

  **Then-frontier:** `RUST-PARITY.7.3.4.4`; that follow-up has since closed by implementing the statement-form
  mutation helpers used by `lib_reader`.

- 2026-07-03: **RUST-PARITY.7.3.4 — triage structural oracle mismatches**
  (NO RUST RUNTIME/PARSER/CORPUS CODE CHANGE).
  Reproduced the recorded `portmap`, `lib_reader`, and `ebnf` structural mismatches with the Perl reference and
  the Rust `corpus_oracle` execution path, then split narrower implementation owners before any code change.

  **Findings:** `portmap` needs Rust runtime boolean/list-context parity (`or` is missing; `array(flat_array(...))`
  nests too deeply) plus action-edge fluent recursive aggregation before concat fixtures are safe. `lib_reader`
  first needs a parser/compiler fix: Rust drops the regex-less top-rule header-rest edge
  `lib_file:: -> group .push`, so representative group inputs collapse to `[[]]`. `ebnf` compiles its fluent
  chains but runtime execution duplicates rule headers and drops token payloads, so it is owned by action-edge
  fluent child/target aggregation.

  **Verification:** Perl `LinkedSpec::get_parser`/`JSON::PP` probes for representative `portmap`, `lib_reader`,
  and `ebnf` inputs; temporary Rust probe using parse/validate/compile/execute; Rust compiled-rule dumps;
  `LinkedSpec::call_spec_handler_subst` lowering probe for child-target `push(...)`.

  **Frontier:** `RUST-PARITY.7.3.4.1` — fix parser/compiler handling for header-rest action edges on regex-less
  top rules, starting with `lib_reader`.

- 2026-07-03: **RUST-PARITY.7.3.7 — oracle timeout covers parser build and parse**
  (GENERATOR SAFETY FIX; NO CORPUS FIXTURE VALUE CHANGE).
  The user-directed timeout re-debug found the remaining live issue in the oracle guard boundary. A shipped-spec
  fork+SIGKILL census made `BNF` exceed a 5s build+parse child wrapper; focused probes showed parser construction
  took about 6.4s while parsing empty input after construction took about 0.03s, and `LINKEDSPEC_TRACE_LEVEL=debug`
  trace reached successful parser generation.

  **Fix:** `tools/gen_oracle_corpus.pl` now builds the Perl reference parser and executes the parse inside the
  same forked child. The parent `ORACLE_TIMEOUT`/`SIGKILL` guard therefore covers parser construction and parser
  execution, including future pathological shipped specs.

  **Verification:** `perl -c -Iperl tools/gen_oracle_corpus.pl` PASS; forced `ORACLE_TIMEOUT=0` reports
  `hard kill during parser build/parse`; normal regeneration writes **66** fixtures byte-identically; Rust
  `corpus_oracle` PASS over the 66-fixture corpus; Knowledge Map, memory architecture, doctrine, and whitespace
  gates PASS; full local CI PASS with phase0 **1018** tests. Knowledge Map and corpus README updated.

  **Frontier:** `RUST-PARITY.7.3.4` — triage `.7.2` structural mismatches for `portmap`, `lib_reader`, and
  `ebnf`.

- 2026-07-03: **RUST-PARITY.7.3.3.3 — hlink scalar-ref fixtures deferred**
  (NO GENERATOR/CORPUS/RUNTIME CODE CHANGE).
  Bracket/mixed `hlink_substitution` fixture candidates remain out of the JSON oracle. Perl returns scalar refs
  for `[abc]` / mixed bracket payloads and `JSON::PP` cannot encode them; Rust also lacks a scalar-ref
  `RuntimeValue` and currently cannot execute the shipped scalar-ref action branch (`return(\(my $capt =
  capture_slice()))` fails parsing before `[abc]` exits via unmatched closing bracket).

  **Verification:** direct Perl `Data::Dumper`/`JSON::PP` probe recorded scalar-ref outputs and JSON failure;
  Rust source audit plus a temporary focused Rust execution probe recorded the unsupported action branch; temporary
  probe removed and `git diff -- rust/linkedspec-runtime/tests/integration_test.rs` was empty. Knowledge Map,
  memory architecture, doctrine, and whitespace gates PASS; Rust `corpus_oracle` PASS; full local CI PASS with
  phase0 **1018** tests.

  **Frontier:** `RUST-PARITY.7.3.4` — triage `.7.2` structural mismatches for `portmap`, `lib_reader`, and
  `ebnf`.

- 2026-07-03: **RUST-PARITY.7.3.3.2 — hlink curly-brace oracle fixture**
  (GENERATOR/CORPUS FIXTURE ADDITION; NO RUST RUNTIME/PARSER CHANGE).
  Added `hlink_curly_brace` to `tools/gen_oracle_corpus.pl` for `hlink_substitution` input `{abc}`. The fixture
  stores the Perl reference value `["{abc}"]`, matching the JSON-safe curly delimiter path split out by
  `.7.3.3.1`.

  **Verification:** direct Perl `JSON::PP` probe encoded `{abc}` as `["{abc}"]`; `perl -c -Iperl
  tools/gen_oracle_corpus.pl` PASS; `perl -Iperl tools/gen_oracle_corpus.pl` generated **66** fixtures; Rust
  `corpus_oracle` PASS over the 66-fixture corpus; mdBook PASS; Knowledge Map, memory, doctrine, whitespace, and
  full local CI gates PASS (phase0 **1018** tests).

  **Frontier:** `RUST-PARITY.7.3.3.3` — decide or explicitly defer scalar-ref oracle representation for `[abc]`
  and mixed `foo[bar]{baz}` hlink fixtures.

- 2026-07-03: **RUST-PARITY.7.3.3.1 — hlink delimiter fixtures split**
  (NO GENERATOR/CORPUS/RUNTIME CODE CHANGE).
  Read the shipped `hlink_substitution.spec`, existing hlink corpus fixtures, and the phase0
  `hlink_substitution_parser_smoke` cases. The delimiter candidates split cleanly by JSON representability:
  `{abc}` returns a plain string payload and can be added as a normal fixture, while `[abc]` and mixed
  `foo[bar]{baz}` return Perl scalar references that `JSON::PP` cannot encode.

  **Verification:** direct `JSON::PP` scalar-ref probe fails with `cannot encode reference to scalar`; new KM fact
  card records the blocker. No generator/corpus/runtime code changed.

  **Frontier:** `RUST-PARITY.7.3.3.2` — add the JSON-safe `{abc}` hlink curly-brace fixture.

- 2026-07-03: **RUST-PARITY.7.3.2 — oracle timeout guard hardened**
  (GENERATOR SAFETY FIX; NO CORPUS FIXTURE VALUE CHANGE).
  The historical `RTLUtils` timeout was verified retired from the active core tree: `perl/RTLUtils.pm`,
  `perl/FSMGen.pm`, and `perl/VHDL/ConstantEval.pm` are absent, and the current core/spec/corpus scan finds only
  retirement comments/docs. The actual fix was the oracle generator's guard: `alarm()` cannot interrupt a
  catastrophic regex, so `tools/gen_oracle_corpus.pl` now forks one child per parser run, serializes the result to
  JSON, and has the parent enforce `ORACLE_TIMEOUT` with wall-clock wait plus `SIGKILL`.

  **Verification:** KM/toolbox context read; `perl -Iperl` module path confirmed; no current core RTLUtils files;
  fork+SIGKILL census around the current generator completed 65 fixtures; `perl -c -Iperl
  tools/gen_oracle_corpus.pl` PASS; normal generator run regenerated **65** fixtures byte-identically;
  `ORACLE_TIMEOUT=0` proves the hard-kill branch; Rust `corpus_oracle` PASS; Knowledge Map, memory, doctrine,
  whitespace, and full local CI gates PASS (phase0 **1018** tests). Corpus README and KM wording updated.

  **Frontier:** `RUST-PARITY.7.3.3` — try remaining `hlink_substitution` delimiter/link-path fixtures with the
  hardened timeout guard in place.

- 2026-07-03: **RUST-PARITY.7.3.1 — batch-2 shipped-spec oracle lanes split and timeout owner assigned**
  (NO RUNTIME/CORPUS CODE CHANGE; TASK-TREE OWNERSHIP BEFORE THE NEXT ORACLE BATCH).
  The broad `RUST-PARITY.7.3` leaf is now split into narrower executable lanes before any generator, corpus, or
  Rust behavior change. The split preserves `.7.2`'s recorded divergence evidence and makes timeout/hang debugging
  the immediate owned frontier: `.7.3.2` verifies whether the referenced `RTLUtils`/oracle timeout is live or stale
  with LinkedSpec's toolbox and trace surfaces, `.7.3.3` tries remaining `hlink_substitution` delimiter/link-path
  fixtures, `.7.3.4` handles `portmap` / `lib_reader` / `ebnf` structural mismatches, `.7.3.5` handles `BNF` /
  `DT` / `ifelse` / `operators_try` / `spec.spec` null-output or action-parser-warning candidates, and `.7.3.6`
  covers RTL/plugin/legacy shipped-spec smokes after the timeout concern is resolved or retired.

  **Verification:** task-tree/KM context read; oracle generator, corpus README, and corpus runner audited;
  `TOOLBOX.md` hang protocol re-read; Knowledge Map, memory, doctrine, and whitespace gates PASS. No
  parser/runtime/corpus code changed.

  **Frontier:** `RUST-PARITY.7.3.2` — debug the timeout/hang risk first with fork+SIGKILL census plus trace on a
  live reproducer, then fix or retire stale timeout wording before broad corpus expansion.

- 2026-07-03: **STAGED-LINKED-PARSING.5.6 — function-body staged prototype proved**
  (END-TO-END AST SHAPE + PROVENANCE DIAGNOSTICS + PERL/RUST PARITY + MDBOOK).
  The first staged linked parsing prototype is now proven end to end. Perl phase0 locks a multi-function sample
  whose descriptor exposes source-ordered user functions, exact `body_payload` text/spans, normalized
  `body_parse_job` records, deterministic source-span-based job ids, and stitched `body_ast` action blocks.
  Runtime behavior remains stable (`["x", "ab", 2, "v"]` for the proof sample), and unsupported body-parser
  dispatch diagnostics preserve registry phase, parent AST path, source span, and failure policy.

  **Rust parity:** Rust integration coverage now proves the same neutral contract through raw
  `specs/user_function_definition.spec` AST output, normalized parsed `SpecFile.functions`, compiled
  `CompiledUserFunction` preservation, runtime output, and dispatch diagnostics.

  **Verification:** standalone Perl proof PASS; Perl syntax checks PASS; focused Rust staged prototype,
  staged-registry, and spec-defined user-function tests PASS; direct Perl phase0 TAP run PASS with **1018**
  top-level tests; mdBook, Knowledge Map, memory, doctrine, whitespace, and full local CI gates PASS.

  **Frontier:** staged prototype tree frontier is empty; PNT returns to `TOP-RULE-AS-NORMAL.3.2` unless a new staged linked
  parsing leaf is explicitly split.

- 2026-07-03: **STAGED-LINKED-PARSING.5.5 — function-body parse jobs dispatched**
  (MINIMAL STAGED REGISTRY + PERL/RUST BODY AST STITCHING + TESTS + MDBOOK).
  Function-body `body_parse_job` records now execute through the first staged parser registry path. The neutral
  `actionir-body.spec` / `action_block` identity resolves to a built-in provider, records a fixed adapter
  contract digest, compiles a cache-keyed parser adapter, executes jobs in stable parent-path/source-span/job-id
  order, and stitches the returned `action_block` AST into `body_ast`.

  **Backend handling:** Perl routes body AST construction through `LinkedSpec::StagedParserRegistry`. Rust adds
  `linkedspec-runtime::staged_parser_registry`, stores stitched `body_ast` on parsed and compiled function
  records, and still executes registered user functions through the compiled ActionIR body.

  **Verification:** Perl syntax checks PASS; focused Rust staged-registry test PASS; focused Rust
  `spec_defined_user_function_parser_*` tests PASS; focused Rust core `user_function` tests PASS; full Perl
  phase0 PASS with 1017 top-level tests; mdBook, Knowledge Map, memory, doctrine, whitespace, and full local CI
  gates PASS.

  **Frontier:** `STAGED-LINKED-PARSING.5.6` — prove the function-body staged prototype end to end.

- 2026-07-03: **STAGED-LINKED-PARSING.5.4 — function-body parse-job sidecar added**
  (SPEC AST + PERL/RUST SIDECARE PRESERVATION + TESTS + MDBOOK).
  `specs/user_function_definition.spec` now returns `body_parse_job` beside `body_payload` for each
  `function_definition` AST node. The sidecar is neutral metadata only: deterministic job id, parent AST path,
  parser spec identity (`actionir-body.spec`), top rule (`action_block`), result policy (`replace_field` into
  `body_ast`), failure policy (`fail`), exact text, source span, and diagnostic owner.

  **Backend handling:** Perl descriptor state and Rust parsed/compiled function state preserve the sidecar after
  validating and normalizing the source-order parent path/job id. Runtime user-function execution still uses the
  existing parsed ActionIR body AST; no staged registry/dispatch queue was implemented in this slice.

  **Verification:** direct spec AST probe PASS; Perl descriptor `body_parse_job` probe PASS; focused Rust
  `spec_defined_user_function_parser_*` tests PASS; focused Rust core `user_function` tests PASS; full Perl
  phase0 PASS with 1016 top-level tests.

  **Frontier:** `STAGED-LINKED-PARSING.5.5` — add the minimal registry/dispatch path for one next-stage spec.

- 2026-07-02: **STAGED-LINKED-PARSING.5.3.2 — Rust raw function-definition parser retired**
  (SPEC PARSER + RUST ADAPTER + RUNTIME HELPER PARITY + TESTS).
  Rust now consumes the same `specs/user_function_definition.spec` returned AST contract as the Perl reference.
  The core Rust rule parser no longer owns top-level `fn name(params) { body }` grammar; the runtime
  `spec_parser` executes the spec parser first, validates the neutral `function_definition` /
  `function_definition_error` nodes, strips the exact definition spans, then parses the remaining rule-only
  source.

  **Runtime support:** Rust now preserves the returned `body_payload` into `CompiledUserFunction`, handles
  PCRE-style named captures and leading inline flag toggles inside composed RGX alternations, supports regex
  literal delimiters in `split`/`split_each`, resolves bare named-capture helper keys, collects multiline compact
  lifecycle fluent arguments such as `I.return({ ... })`, starts child-rule capture slices after the entry match,
  and runs self-recursive finalizer edges without seeking a later close.

  **Verification:** focused `spec_defined_user_function_parser_*` tests PASS with concrete input strings and exact
  AST-shape assertions; regex split, inline flag, named capture, edge-only scanner, edge-only child `I.return`,
  `terse_2_3_2_`, core parser, core user-function, shipped-spec parse/compile, and Rust corpus oracle checks PASS.

  **Frontier:** `STAGED-LINKED-PARSING.5.4` — add the minimal neutral parse-job marker/sidecar prototype.

- 2026-07-02: **STAGED-LINKED-PARSING.5.3.1 — spec-defined function-definition AST consumed by Perl**
  (SPEC PARSER + PERL REGISTRY BRIDGE + TESTS + MDBOOK + KNOWLEDGE MAP; runtime behavior unchanged).
  `specs/user_function_definition.spec` is now the executable grammar owner for the `fn name(params) { body }`
  shell. It returns source-ordered `function_definition` AST nodes with parsed params, arity, exact source/body
  text, half-open source/body spans, source-slice provenance, and a neutral `body_payload`.

  **Spec surface:** The new spec uses direct `[...]` / `{ ... }` shapes and receiver/bare-variable forms. It does
  not use `declare(...)`, `array(...)`, `scalar(...)`, `hash(...)`, or `scalaref(...)`.

  **Perl bridge:** `LinkedSpec::UserFunctionRegistry` now loads the spec parser, consumes the returned AST,
  validates the shape, post-annotates the source-order parent path, and strips definitions before bootstrap
  parsing. The previous raw Perl function-definition scanner is removed.

  **Parser shape:** The first monolithic-body regex draft was replaced before commit. The focused spec now uses a
  linked opener/closer shell plus body-island rules for nested braces, strings, comments, and regex literals.
  Generated-handler debug and focused tests show adjacent `body_brace` matches do not consume the outer
  `function_definition[1]` close edge; unbalanced nested bodies return a diagnostic AST instead of `null`.

  **Verification:** direct spec-parser AST probe PASS; focused Perl descriptor payload probe PASS; mdBook,
  Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS.

  **Frontier:** `STAGED-LINKED-PARSING.5.3.2` — retire remaining host-language definition parser bridges,
  starting with Rust, in favor of the same spec-owned AST contract.

- 2026-07-02: **STAGED-LINKED-PARSING.5.2 — function-definition AST-shape audit completed**
  (READ-ONLY AUDIT + ADR + MDBOOK + KNOWLEDGE MAP; **no runtime code change**).
  The next staged prototype seam is now specified before code.

  **Harness:** focused AST-shape tests must use a dedicated small spec/top rule: a wrapper top rule dispatches
  into a normal `function_definition` rule and returns collected nodes from `LX`. Direct top regex rules cannot
  read their own captures through `entry_group(...)`.

  **Findings:** the current numbered-capture `specs/spec.spec` rule mis-shapes zero-argument functions because
  optional captures are compacted. It also fails/truncates regex literals containing braces in function bodies.
  Current Perl/Rust bridges differ on exact body text and span storage, so staged provenance must be neutral.

  **Contract:** ADR `0017` defines the target returned node with `type`, `name`, `params`, `arity`,
  `source_text`, `source_span`, exact inner `body_source`, `body_span`, `body_parse_job`, and stitched `body_ast`
  after dispatch.

  **Verification:** mdBook build PASS; Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS
  with phase0 1015 green.

  **Frontier:** `STAGED-LINKED-PARSING.5.3` — preserve source provenance for function-body payload parse jobs.

- 2026-07-02: **STAGED-LINKED-PARSING.5.1 — staged prototype payload selected and split**
  (TASK TREE + ADR + MDBOOK + KNOWLEDGE MAP; **no runtime code change**).
  The first prototype payload family is user-defined function body text. `specs/spec.spec` already extracts
  `fn name(args) { body }` as a bounded text island, and the current Perl/Rust user-function bridges provide
  behavior to preserve while staged parsing replaces that bridge debt.

  **Neutrality gate:** ADR `0016` now makes staged parsing artifacts 100% implementation-language neutral.
  Syntax, AST metadata, source provenance, parse-job scheduling, registry/cache identity, diagnostics, fixtures,
  and docs are `.spec`/AST contracts. Backend mechanics are adapters, not semantics.

  **Split:** `.5` is now `.5.1` payload selection, `.5.2` seam audit, `.5.3` provenance, `.5.4` parse-job
  sidecar, `.5.5` minimal registry/dispatch, and `.5.6` end-to-end function-body proof. The seam audit must
  predict the returned `function_definition` AST shape and a broad function-definition variation matrix; the proof
  must assert that shape directly across those variations using a dedicated small spec file/top rule for focused
  AST-shape tests.

  **Verification:** mdBook build PASS; Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS
  with phase0 1015 green.

  **Frontier:** `STAGED-LINKED-PARSING.5.2` — audit the function-body staged-prototype seams before code.

- 2026-07-02: **STAGED-LINKED-PARSING.4 — staged parser registry dispatch specified**
  (ARCHITECTURE + MDBOOK + TASK TREE + KNOWLEDGE MAP; **no runtime code change**).
  ADR `0015` now reserves deterministic parser registry and dispatch queue semantics before implementation.

  **Contract:** the registry exposes neutral `resolve`, `load`, `compile`, and `execute` operations. Resolution
  checks parent import aliases/composed identities, declaring-spec-relative paths, configured search roots, and
  registry providers in declared order.

  **Queue/cache:** jobs run in parent-AST-path/source-span/job-id order. Cache keys include normalized spec
  identity, content digest, import/include graph fingerprint, selected top rule, `.spec` language version,
  helper/action contract version, staged parsing contract version, and backend capability set. Active-chain cycles
  repeat spec identity, top rule, payload digest, and source span.

  **Verification:** mdBook build PASS; Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS
  with phase0 1015 green.

  **Frontier:** `STAGED-LINKED-PARSING.5` — implement the first narrow staged-parsing prototype.

- 2026-07-02: **STAGED-LINKED-PARSING.3 — staged parse-job annotations specified**
  (ARCHITECTURE + MDBOOK + TASK TREE + KNOWLEDGE MAP; **no runtime code change**).
  ADR `0014` now reserves future `parse_job(text_expr, options)` markers for runtime payload refinement before
  implementation.

  **Contract:** the marker produces a stage-N AST value plus neutral sidecar metadata: deterministic job id,
  parent AST path, node kind, payload kind, exact text, source span/provenance, parser spec id, optional top rule,
  result policy, and failure policy.

  **Policies:** result policies are `replace_marker`, `replace_field`, `sibling_field`, and `append_child`.
  Failure policies are `fail`, `keep_text`, and `diagnostic_node`. Current shipped parsers do not yet accept or
  execute `parse_job(...)`.

  **Verification:** mdBook build PASS; Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS
  with phase0 1015 green.

  **Frontier:** `STAGED-LINKED-PARSING.4` — design parser registry and dynamic next-stage dispatch.

- 2026-07-02: **STAGED-LINKED-PARSING.2 — spec import/composition contract specified**
  (ARCHITECTURE + MDBOOK + TASK TREE + KNOWLEDGE MAP; **no runtime code change**).
  ADR `0013` now reserves future file-scope `import "path.spec" as alias` and
  `include "path.spec"` directives for grammar composition before implementation.

  **Contract:** `import` creates qualified references such as `alias.Rule`; `include` performs a structured merge
  into the current unqualified namespace. Both compose parsed grammar material only. They are not staged parse
  jobs and do not parse runtime payload text.

  **Diagnostics/neutrality:** resolution order, duplicate alias/rule diagnostics, ambiguous reference diagnostics,
  import-cycle reporting, source provenance, and descriptor fingerprints are language-neutral across Perl5, Raku,
  Rust, Julia, Lua, Dart, Zig, Go, and future implementations. Current shipped parsers do not yet accept the
  directives.

  **Verification:** mdBook build PASS; Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS
  with phase0 1015 green.

  **Frontier:** `STAGED-LINKED-PARSING.3` — design staged parse-job annotations and AST payload metadata.

- 2026-07-02: **STAGED-LINKED-PARSING.1 — staged linked parsing doctrine adopted**
  (ARCHITECTURE + MDBOOK + TASK TREE + KNOWLEDGE MAP; **no runtime code change**).
  ADR `0012` now defines LinkedSpec as a staged linked parsing architecture: a stage may parse only the easy
  anchored surface, emit source-provenance text islands, and route each payload to one or more later `.spec`
  parsers through deterministic parse jobs.

  **Contract:** spec imports/composition and staged parse dispatch are separate. Imports compose grammar material;
  parse jobs refine runtime payload text and carry parser identity, optional top rule, source span, parent AST path,
  result insertion policy, and failure/diagnostic policy.

  **Language neutrality:** the staged parse graph is specified over `.spec`, AST payloads, descriptors, parse jobs,
  diagnostics, and parser entry semantics, not host-language mechanics. Perl5, Raku, Rust, Julia, Lua, Dart, Zig,
  Go, and future implementations inherit the same contract.

  **Verification:** mdBook build PASS; Knowledge Map, memory, doctrine, and diff gates PASS; full local CI PASS
  with phase0 1015 green.

  **Frontier:** `STAGED-LINKED-PARSING.2` — design spec imports/composition when this architecture track resumes.

- 2026-07-02: **RUST-PARITY.7.2 — first shipped-spec oracle batch landed**
  (RUST PARSER + CAPTURE INDEXING + ORACLE CORPUS).
  Rust header-rest parsing now shares the normal body-element parser, so compact header-line lifecycle chains and
  multiline header-rest lifecycle blocks are parsed and consumed correctly. Rust `entry_group`/`match_group`
  helpers now expose captures-only, compacted capture lists with `0` as the first participating capture; whole
  matches stay on `entry_text`/`match_text`.

  **Corpus:** `hlink_substitution` raw-string paths are active through `hlink_raw_string` and
  `hlink_raw_escaped_brackets`; oracle regeneration now produces **65 fixtures** and the Rust corpus oracle passes
  over all 65. Broader attempted shipped-spec candidates remain deferred with structural divergence evidence in
  `docs/tasks/RUST-PARITY.md`.

  **Verification:** focused parser/runtime checks PASS; oracle generation PASS; Rust corpus oracle PASS (65);
  mdBook already aligned with the capture contract and builds PASS; Knowledge Map, memory, doctrine, diff, and full
  local CI gates pass in commit workflow.

  **Frontier:** `RUST-PARITY.7.3` — expand the remaining/harder shipped-spec corpus batch with the recorded
  divergence ledger.

- 2026-07-02: **SCALAREF-RETIREMENT.5 — scalaref retirement tree closed**
  (FINAL DRIFT SWEEP + ROOT CORPUS + LIVE DOCS/KM/TASK INDEX).
  Root language-neutral corpus fixtures now use direct nested access instead of `scalaref(...)`; current-facing
  roadmap, architecture, method-like DSL, Rust parity, and Knowledge Map wording now labels legacy support as
  retired/historical; `SCALAREF-RETIREMENT` moved to the completed task-tree index.

  **Verification:** active `scalaref(` / `.scalaref(` scan over shipped specs, root/Rust corpus fixtures, mdBook,
  user guide, generator, sources, and tests shows only intentional negative locks; root Lispish/tablegrep corpus
  specs compile through `LinkedSpec::Get`; `tools/run_ci_local.sh` passes with phase0 1015 green; Knowledge Map,
  mdBook, memory, doctrine, and diff gates pass in commit workflow.

  **Frontier:** `RUST-PARITY.7.2` — expand the structurally simple oracle corpus batch.

- 2026-07-02: **SCALAREF-RETIREMENT.4 — scalaref implementation support removed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + REJECTION LOCKS).
  Perl no longer lowers function-form `scalaref(...)` or receiver-dot `.scalaref(...)`, and Rust no longer parses
  or evaluates the legacy `ScalarRefPath` form. The surviving direct-access internals now use neutral nested
  access names, while direct `retv["content"]` / `retv[0]` payload reads and named working-hash reads through
  `scalar(hash(name), key)` remain supported.

  **Rejection contract:** focused Perl lowering reports the existing
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:scalaref` sentinel; Rust unknown-helper evaluation returns
  `undef`/JSON `null`. Focused negative tests lock both function-form and receiver-dot spellings.

  **Verification:** Perl syntax checks PASS; `prove -q -Iperl t/phase0_regression.t` PASS (1015); Rust
  direct-access and `scalaref_retirement_3`/`.4` focused tests PASS; `cargo fmt --all -- --check` PASS;
  `cargo check` for `linkedspec-core` and `linkedspec-runtime` PASS; Rust corpus oracle PASS; implementation
  removal and public-surface scans PASS; `mdbook build docs/linkedspec-book` PASS; Knowledge Map check PASS;
  memory/doctrine/diff final gates PASS in commit workflow.

  **Frontier:** `SCALAREF-RETIREMENT.5` — final no-drift sweep and tree close-out (now complete).

- 2026-07-02: **SCALAREF-RETIREMENT.3 — scalaref live surface migrated**
  (SHIPPED SPECS + TESTS + CORPUS + PUBLIC DOCS; **implementation support still present until `.4`**).
  Shipped specs, checked-in Rust oracle fixtures, focused tests, public mdBook chapters, and user guides no longer
  use `scalaref(...)` or receiver-dot `.scalaref(...)` as active examples. Lispish now reads child-return payloads
  with `retv["content"]`; other migrated specs use direct array/hash payload access such as `retv[0]`,
  `first_capt[0]`, `cur_object[1]`, and `retv["type"]`.

  **Replacement contract in active docs:** scalar hashref/array payloads use direct nested access; named working
  hash field reads use `scalar(hash(name), key)`; direct bracket reads are not working-hash value reads. Rust now
  supports `scalar(hash_expr, key)` over runtime hash values, and Perl flow expressions lower direct nested access
  before flow fallback.

  **Verification:** active `scalaref(` / `.scalaref(` scans clean across shipped specs, checked-in corpus, public
  docs, tests, and generator; `prove -q -Iperl t/phase0_regression.t` PASS (1015); Rust corpus oracle PASS (63);
  `mdbook build docs/linkedspec-book` PASS; `cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml --check`
  PASS; `git diff --check` PASS.

  **Frontier:** `SCALAREF-RETIREMENT.4` — remove Perl/Rust recognition/execution for `scalaref(...)` and add
  rejection coverage.

- 2026-07-02: **SCALAREF-RETIREMENT.2 — scalaref retirement inventory contract locked**
  (INVENTORY + REPLACEMENT CONTRACT + KM; **no runtime behavior change**).
  The retirement inventory now covers shipped specs, checked-in oracle fixtures, Perl/Rust implementation support,
  tests/tools, public mdBook pages, user guides, historical task-tree records, and Knowledge Map cards. Shipped
  specs currently contain 16 function-form `scalaref(...)` calls. Public mdBook/user-guide examples contain 332
  function-form references. Receiver-dot `.scalaref(...)` appears in hash receiver-chain examples/tests and is in
  scope because it is the same public field-read helper name.

  **Replacement contract:** migrate `scalaref(base, {field})` to `base["field"]`, `scalaref(base, [0])` to
  `base[0]`, and mixed paths such as `{children}[0]{name}` to `["children"][0]["name"]`. For receiver-dot
  `.scalaref(key)`, named working hashes use `scalar(hash(meta), key)`; direct bracket reads are for scalar
  hashref payloads, not working-hash value reads.

  **Verification:** `rg` inventory PASS; Perl `call_spec_handler_subst` direct-access probes PASS; focused Rust
  direct-access parser/runtime tests PASS; Knowledge Map/memory/doctrine/diff checks PASS.

  **Frontier:** `SCALAREF-RETIREMENT.3` — migrate shipped specs, tests, oracle fixtures, and public docs away
  from `scalaref(...)` before implementation removal.

- 2026-07-02: **SCALAREF-RETIREMENT.1 — scalaref retirement track owned**
  (TASK TREE + ROADMAP/LIVE DOCS + KM; **no runtime behavior change**).
  The user directive that `scalaref(...)` shall be retired and removed is now tracked in
  `docs/tasks/SCALAREF-RETIREMENT.md`. The tree deliberately separates current shipped-surface parity from
  retirement work: `.2` inventories all live uses and selects the canonical replacement, `.3` migrates shipped
  specs/tests/docs, `.4` removes Perl/Rust recognition/execution, and `.5` performs the final drift sweep.

  `RUST-PARITY.7.5.2` remains the committed parity slice for existing Lispish behavior. No parser, compiler,
  runtime, corpus, shipped-spec, or public-book behavior changed in this ownership slice.

  **Verification:** Knowledge Map regeneration/check PASS; memory architecture PASS; doctrine registry PASS;
  mdBook build PASS; `git diff --check` PASS.

  **Frontier:** `SCALAREF-RETIREMENT.2` — inventory every `scalaref(...)` use and select the replacement contract
  before migrating specs/docs or removing implementation support.

- 2026-07-02: **RUST-PARITY.7.5.2 — Lispish scalaref parity landed**
  (RUST CORE + RUST RUNTIME + ORACLE + BOOK/KM/LIVE DOCS).
  Rust now parses Lispish's legacy `scalaref(retv, {content})` path only in `scalaref`'s second positional
  argument and evaluates mixed key/index paths against hashes and arrays. Child-return accumulator pushes are
  contained at child invocation boundaries, attached action blocks that explicitly call their child avoid duplicate
  dispatch, and explicit aggregate-wrapper assignment replaces array/hash working stores.

  The `lispish_x_y` shipped-spec fixture is active again and expects `["x",["y"]]`; the Rust corpus oracle now
  passes over **63 fixtures**. `scalaref(...)` and the existing Perl-shaped hash literal spelling are legacy
  compatibility surfaces restored here only for parity; retirement/removal is a separate owned migration leaf.

  **Verification:** focused Rust parser/runtime `.7.5.2` checks PASS; `retv_5_1` checks PASS; oracle generator
  syntax/regeneration PASS; Rust corpus oracle PASS over 63 fixtures; mdBook, Knowledge Map, memory/doctrine/diff
  checks, and full local CI PASS.

  **Frontier:** `RUST-PARITY.7.2` — expand the structurally simple oracle corpus batch.

- 2026-07-02: **RUST-PARITY.7.5.3 — action-edge fluent closure reconciled**
  (TASK TREE + CORPUS README + ROADMAP/LIVE DOCS + KM; **no runtime behavior change**).
  The stale Rust parity frontier is now closed against committed evidence: `SPEC-FORMAT-TERSE.2.3.3.1` added
  action-edge fluent metadata plus no-arg `.push` / `.return(...)` / `.return_undef`; `.2.3.3.3.2` completed
  explicit-target and flow-control action-edge continuations; and `.2.3.3.3.3.1` fixed the separate `tclite`
  default-mode repetition / child-preamble-return gap and restored the two shipped `tclite` oracle fixtures.

  **Verification:** source/corpus audit confirms `execute_action_edge_fluent_chain`, active
  `tclite_command_subst` / `tclite_double_quote`, and `RUST-PARITY.7.5.3` task evidence; Rust corpus oracle PASS
  over **62 fixtures**; mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Frontier:** `RUST-PARITY.7.5.2` — Lispish `scalaref(retv, {content})` hash-field accessor support. `.7.2`
  and `.7.3` remain blocked until `.7.5.2` closes.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.3.4 — assignment-expression closure and legacy spelling cleanup landed**
  (PHASE0 + RUST RUNTIME + ORACLE + BOOK/KM + STATUS DRIFT REPAIR).
  The parent `.3.3` assignment-expression contract is now locked across scalar assignment values, direct-shape
  aggregate assignment values, array append snapshot values, hash-index mutation snapshot values,
  user-function body assignment, `=(target,value)`, canonical `set(...)`, compatible receiver-chain terminals,
  and retained legacy `assign(...)` compatibility.

  Public mdBook examples now prefer `set(...)` or operator assignment. `assign(...)` remains supported and is
  documented as a legacy alias with current value semantics, not promoted as new syntax.

  **Verification:** phase0 closure lock PASS with **1015 tests**; focused Rust runtime `.3.3.4` PASS; oracle
  regeneration produced **62 fixtures** including `terse_3_3_4_assignment_expression_closure`; Rust corpus oracle
  PASS; mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** no concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf remained immediately after this closure.
  Future backend leaves were deferred or blocked by explicit roadmap decisions at that point.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.3.3 — mutation assignment expression values landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Array append and hash-index mutation operators are now value expressions on Perl and Rust. `items += value`
  mutates the named working array and returns the updated array snapshot; `meta[key] = value` mutates the named
  working hash and returns the updated hash snapshot. These snapshot values compose in `return(...)`, helper
  arguments, expression-valued blocks, and compatible receiver chains such as `(items += value).count()` and
  `(meta[key] = value).count_keys()`.

  The compatibility boundary is locked: statement behavior is preserved and array end-mutation methods such as
  `items.push_back(value)` remain statement-level. Full assignment-expression closure / legacy `assign(...)`
  example cleanup later landed in `.3.3.4`.

  **Verification:** Perl syntax checks PASS; focused `t/actionir_ast_parser.t` PASS; focused Rust parser/runtime
  `.3.3.3` PASS; oracle regeneration produced **61 fixtures** including
  `terse_3_3_3_mutation_assignment_expressions`; Rust corpus oracle PASS; phase0 PASS with **1014 tests**;
  mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.3.4` (now done; no concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf
  remains).

- 2026-07-02: **SPEC-FORMAT-TERSE.3.3.2 — aggregate assignment expression values landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Direct RHS shape assignments are now value expressions on Perl and Rust. `items = [value]`,
  `set(items, [value])`, `=(items, [value])`, and matching `array(items)` targets store the array working variable
  and return the assigned array value; `meta = { key => value }`, `set(meta, { key => value })`, and matching
  `hash(meta)` targets store the hash working variable and return the assigned hash value.

  The compatibility boundary is locked: explicit `scalar(payload)` targets keep scalar-held shape payloads;
  statement behavior is preserved; array append and hash-index mutation expression values later landed in
  `.3.3.3`.

  **Verification:** Perl syntax checks PASS; focused `t/actionir_ast_parser.t` PASS; generated-source declaration
  probes PASS; focused Rust parser/runtime `.3.3.2` PASS; oracle regeneration produced **60 fixtures** including
  `terse_3_3_2_aggregate_assignment_expressions`; Rust corpus oracle PASS; phase0 PASS with **1013 tests**;
  mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.3.3` (now done; `.3.3.4` also completed that sublane, and no concrete
  `SPEC-FORMAT-TERSE` PNT-eligible leaf remained immediately after that closure).

- 2026-07-02: **SPEC-FORMAT-TERSE.3.3.1 — scalar assignment expression values landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Scalar non-shape assignment is now a value expression on Perl and Rust. `name = value`, `=(name,value)`,
  scalar `set(name,value)`, and scalar `assign(name,value)` store the scalar and return the stored value in
  return payloads, helper arguments, expression-valued blocks, exact-arity user-function bodies, and compatible
  scalar receiver chains.

  The compatibility boundary is locked: statement behavior is preserved; direct RHS shape assignment values
  later landed in `.3.3.2`; and array append/hash-index mutation expression values later landed in `.3.3.3`. Perl aggregate-call
  lowering keeps nested aggregate wrapper calls such as `count(array(items))` source-shaped while direct
  multi-argument `array(name, other)` scalar payloads read scalars.

  **Verification:** Perl syntax checks PASS; focused `t/actionir_ast_parser.t` PASS; focused Perl
  runtime/source probes PASS; focused Rust parser/runtime `.3.3.1` PASS; oracle regeneration produced **59
  fixtures** including `terse_3_3_1_scalar_assignment_expressions`; Rust corpus oracle PASS; phase0 PASS with
  **1012 tests**; mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.3.2` (now done; `.3.3.4` also completed that sublane, and no concrete
  `SPEC-FORMAT-TERSE` PNT-eligible leaf remained immediately after that closure).

- 2026-07-02: **SPEC-FORMAT-TERSE.3.3 — expression-valued assignment split before code**
  (TASK TREE + BOOK/KM + LIVE DOCS; NO PARSER/COMPILER/RUNTIME CHANGE).
  The assignment-expression destination contract is now owned and split: `target = value` remains canonical,
  `=(target,value)` is the planned ordinary operator-call equivalent, and legacy `assign(target,value)` stays
  migration debt rather than preferred new syntax. Assignment expressions will evaluate to the value stored
  after assignment and target-kind inference.

  Current shipped behavior is unchanged and still statement-only for scalar assignment, array append, and
  hash-index assignment. Probes confirm `name = "ok"; return(name)` works today, while `return(name = "ok")`,
  `return(=(name,"ok"))`, `return(set(name,"ok"))`, and nested assignment in helper arguments do not yet yield
  expression values. Rust expression evaluation still diagnoses those assignment/mutation nodes as
  statement-only.

  **Verification:** KM retrieval PASS; TOOLBOX assignment lowering/runtime probes PASS; Rust source/test audit
  PASS; mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Frontier:** `SPEC-FORMAT-TERSE.3.3.1` (scalar assignment expression values and scalar `=(target,value)`
  equivalence).

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.4 — numeric comparison symbol callees landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Comparison symbol callees are now portable numeric helper calls: `==(a,b)`, `!=(a,b)`, `>(a,b)`,
  `>=(a,b)`, `<(a,b)`, and `<=(a,b)` parse as ordinary `callee(args)` forms and dispatch to
  `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust.

  The compatibility boundaries are locked: slash regex literals and arithmetic slash calls keep the `.3.2.2`
  behavior; lexical string comparisons stay on `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le`; raw
  `=(target,value)` assignment operator calls remain `.3.3`; and `=>` remains the blind-call edge operator.

  **Verification:** Perl syntax checks PASS; focused Perl lowering/runtime/source probes PASS; focused Rust
  parser/runtime `.3.2.3.4` PASS; oracle regeneration produced **58 fixtures** including
  `terse_3_2_3_4_numeric_comparison_symbol_callees`; Rust corpus oracle PASS; phase0 PASS with **1011 tests**;
  mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.3` (now split/done; current frontier is `.3.3.1`).

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.3 — numeric comparison word aliases landed**
  (PERL ACTIONIR + RUST RUNTIME + SHIPPED SPEC MIGRATION + PHASE0 + ORACLE + BOOK/KM).
  Bare value-call comparison words now use numeric semantics: `eq`, `ne`, `gt`, `ge`, `lt`, and `le` map to
  `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Explicit `num_*` calls and
  number receiver terminals such as `score.gt(3)` remain accepted numeric comparisons.

  Lexical string comparisons are now the explicit `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and
  `str_le` family. Repo-owned specs and phase0 examples that relied on bare word string comparison were
  migrated to `str_*`, including `portmap`, `spec`, `ds_vhistory`, and `simenv` sites. Comparison symbol
  callees remain `.3.2.3.4`.

  **Verification:** Perl syntax checks PASS; focused Perl lowering/runtime/source probes PASS; focused Rust
  runtime `.3.2.3.3` PASS; oracle regeneration produced **57 fixtures** including
  `terse_3_2_3_3_numeric_comparison_word_aliases`; Rust corpus oracle PASS; phase0 PASS with **1010 tests**;
  mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Frontier:** `SPEC-FORMAT-TERSE.3.2.3.4` (numeric comparison symbol callees), then `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.2 — explicit string comparison helpers landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  The explicit string-comparison bridge is now runnable: `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and
  `str_le` lower/dispatch as lexical string predicates on Perl and Rust. These names are now preferred for new
  text comparisons.

  Bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and `le(...)` remain runnable string-comparison
  compatibility aliases until `.3.2.3.3` flips ordinary comparison word calls to numeric `num_*` aliases.
  Comparison symbol callees remain `.3.2.3.4`.

  **Verification:** Perl syntax checks PASS; focused Rust runtime `.3.2.3.2` PASS; oracle regeneration produced
  **56 fixtures** including `terse_3_2_3_2_string_comparison_helpers`; Rust corpus oracle PASS; phase0 PASS with
  **1009 tests**; mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3.3` (now done), then `.3.2.3.4` and `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.1 — string comparison bridge contract locked**
  (TASK TREE + ROADMAP + BOOK/KM + LIVE DOCS; **no parser/compiler/runtime code change**).
  The explicit string-comparison bridge names are now contract-locked before implementation:
  `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`. They preserve today's lexical string
  comparison semantics and are intentionally not numeric helpers, receiver-dot links, or symbol callees.

  Current shipped behavior remains unchanged. Bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and
  `le(...)` are still the runnable string comparison helpers. The book names `str_*` as the accepted bridge but
  states that those names are not shipped until `.3.2.3.2` implements them.

  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` PASS; Knowledge Map regenerate/check
  PASS; memory/doctrine/diff checks PASS; mdBook build PASS; full local CI PASS with phase0 **1008 tests**.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3.2` (now done), then `.3.2.3.3`, `.3.2.3.4`, and `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3 — comparison call surface split/owned**
  (TASK TREE + ROADMAP + BOOK/KM + LIVE DOCS; **no parser/compiler/runtime code change**).
  The comparison operator-call migration is now split before implementation. Current shipped behavior remains:
  numeric comparisons use `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/`num_le` or receiver terminals such as
  `score.gt(3)`, while bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and `le(...)` remain string
  comparisons in documented flow/helper contexts.

  The future canonical numeric comparison call surface is ordinary `callee(args)` form with word/symbol pairs:
  `eq`/`==`, `ne`/`!=`, `gt`/`>`, `ge`/`>=`, `lt`/`<`, and `le`/`<=`, all mapping to the existing `num_*`
  comparison helpers. Because of the string-compatibility conflict, the implementation frontier is split:
  `.3.2.3.1` string bridge contract, `.3.2.3.2` explicit `str_*` helpers, `.3.2.3.3` numeric comparison word
  aliases, and `.3.2.3.4` comparison symbol callees.

  **Verification:** focused KM/TOOLBOX/source/mdBook audit complete; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS; mdBook build PASS; full local CI PASS with phase0 **1008 tests**.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3.1` (explicit string-comparison bridge contract; now done),
  then `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`, and `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.2 — arithmetic symbol callees landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Arithmetic symbol calls are now portable helper calls: `+(a,b)`, `-(a,b)`, `*(a,b)`, `/(a,b)`, and `%(a,b)`
  parse as ordinary `callee(args)` forms and dispatch to `num_add`, `num_sub`, `num_mul`, `num_div`, and
  `num_mod` on both Perl and Rust. Nested symbol calls compose through the same numeric helper family.

  Slash-call recognition is intentionally narrow. The scanner accepts `/(` as division only with a balanced
  parenthesized argument list and a safe call boundary, while preserving slash regex literals such as `/(\))/`
  and `/(?<!\\)}/`.

  **Verification:** Perl syntax checks PASS; focused Perl lowering/runtime/source probes PASS; full phase0 PASS
  with **1008 tests**; oracle regeneration produced **55 fixtures** including
  `terse_3_2_2_arithmetic_symbol_callees`; Rust corpus oracle PASS; Rust core PASS; focused Rust runtime `.3.2.2`
  PASS; mdBook, memory/Knowledge Map/doctrine/diff checks, and full local CI PASS. A broader full Rust runtime
  integration run also shows the new `.3.2.2` test passing but still contains unrelated stale `s(...)`/`a(...)`/`h(...)`
  short-wrapper tests from the prior alias-retirement baseline.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3` (later split through `.3.2.3.4` before `.3.3`), then `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.4.4 — user-function surface finalized**
  (BOOK + TASK TREE + KNOWLEDGE MAP + LIVE DOCS).
  The public contract now closes the portable user-function MVP after Perl/Rust parity: top-level
  `fn name(args) { ... }`, explicit parentheses for every arity including `fn name() { ... }`, braced
  value-oriented bodies, exact arity, fresh function-local stores, final-expression or `return(expr)` results,
  ordinary value-call composition, compatible receiver-chain continuation, and standalone result discard.

  The deferred ledger is explicit: `function ... endfunction`, `fn ... endfn`, optional zero-arg parentheses,
  brace-less bodies, caller-state/parser-state/persistent side-effect functions, recursive user functions,
  closures, lambdas, currying/partial application, and namespace/module features require future task-tree
  ownership before any implementation.

  **Verification:** mdBook build, memory/doctrine/Knowledge Map checks, diff check, and full local CI all pass.
  No parser/compiler/runtime code changed.

  **Frontier:** `SPEC-FORMAT-TERSE.3.2.2` (arithmetic symbol callees), then `.3.2.3`, `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.4.3.2 — Rust user-function runtime parity landed**
  (RUST RUNTIME + ORACLE CORPUS + BOOK/KM/LIVE DOCS).
  Rust registered user-function calls now resolve before ordinary helper fallback, check exact arity, evaluate
  arguments eagerly in the caller context, bind params into fresh function-local scalar/array/hash stores, and
  evaluate compiled function `CodeBlock` bodies for final-expression or `return(expr)` results.

  Returned values feed compatible receiver-dot chains by runtime type, so user functions can return arrays,
  hashes, strings, and numbers into the existing fluent value-chain surface. Standalone registered calls execute
  through the same value path and discard their result. Function-local variables are restored away after return,
  and direct/mutual recursion diagnoses deterministically.

  **Verification:** focused Rust runtime `.4.3.2` locks PASS; oracle generation PASS; Rust corpus oracle PASS
  with **54 fixtures** including `terse_4_3_2_user_function_runtime`; Rust runtime lib and Rust core suites PASS;
  mdBook build, memory/doctrine/Knowledge Map checks, diff check, and full local CI all pass.

  **Frontier:** `SPEC-FORMAT-TERSE.4.4` (function surface finalization and deferred extension ledger), then
  `.3.2.2`, `.3.2.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.4.3.1 — Rust user-function registry parity landed**
  (RUST AST/PARSER/VALIDATION/COMPILER + BOOK/KM/LIVE DOCS).
  Rust `.spec` parsing now extracts top-level `fn name(args) { ... }` declarations before or between rule
  paragraphs into `SpecFile.functions`, preserving ordered params, exact arity, source/body spans, original
  source, and body source. Rule parsing is preserved, and function definitions do not become raw rule body text.

  Rust validation rejects duplicate functions, rule-label collisions, helper/control-name collisions including
  numeric word aliases, lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, and
  reserved params before runtime. Rust compilation now projects definitions into `CompiledSpec.functions` as `CompiledUserFunction`
  records with parsed `CodeBlock` bodies and source metadata. Runtime user-call execution remains explicitly
  unclaimed until `.4.3.2`.

  **Verification:** Rust format check, `linkedspec-core`, `linkedspec-runtime --lib`, Rust corpus oracle, mdBook
  build, memory/doctrine/Knowledge Map checks, diff check, and full local CI all pass.

  **Frontier:** `SPEC-FORMAT-TERSE.4.3.2` (Rust user-function runtime parity and oracle fixtures), then
  `.3.2.2`, `.3.2.3`.

- 2026-07-01: **SPEC-FORMAT-TERSE.4.2.3 — Perl user-function standalone discard/hardening landed**
  (ACTIONIR CANONICAL EVENTS + VALUE_DROP + METHOD LOWERING + PHASE0 + BOOK/KM/LIVE DOCS).
  Registered standalone `fn name(...)` calls and receiver chains now compute their value through the same
  user-function lowering path as value-position calls, then discard it as canonical `VALUE_DROP` with zero raw
  fallback. The classifier is registry-aware, so unknown unregistered standalone calls remain raw compatibility
  debt instead of being swept into the user-function path.

  Phase0 also locks nested user-function parameter passing, direct and mutual recursion diagnostics,
  parser-state helper bodies, host-code-shaped bodies, and nested function syntax as unresolved-helper metadata
  with zero raw fallback. Focused AST suite, full phase0 (**1007 tests**), mdBook build, memory/doctrine/Knowledge
  Map checks, diff check, and full local CI all pass.

  **Frontier:** `SPEC-FORMAT-TERSE.4.3.1` (Rust function-definition AST/compiler registry parity), then
  `.4.3.2`, `.3.2.2`, `.3.2.3`.

- 2026-07-01: **SPEC-FORMAT-TERSE.4.2.2 — Perl user-function value-call execution landed**
  (COMPILER REGISTRY THREADING + ACTIONIR METHOD LOWERING + PHASE0 + BOOK/KM/LIVE DOCS).
  Registered exact-arity `fn name(args) { ... }` calls now execute in Perl value positions instead of remaining
  unresolved-helper diagnostics. Calls evaluate args eagerly in the caller, bind positional params into fresh
  function-local lexicals, lower body AST statements inside a value-producing `do { ... }`, and return either a
  final expression or function-local `return(expr)` payload.

  Phase0 locks composition through `return(...)`, assignment RHS, array append RHS, hash mutation value, helper
  arguments, returned-value receiver chains, final-expression bodies, non-final function-local returns, and
  local/caller shadowing. Wrong-arity registered calls remain unresolved-helper metadata with zero raw fallback.
  Standalone result discard, recursion/purity hardening, and unsupported body-effect diagnostics landed in
  `.4.2.3`; Rust parity remains tracked under `.4.3`.

  **Frontier after this historical leaf:** `.4.2.3`, then `.4.3.1`, `.4.3.2`, `.3.2.2`, `.3.2.3`.

- 2026-07-01: **SPEC-FORMAT-TERSE.4.2.1 — Perl user-function registry seam landed**
  (SPEC.SPEC + PERL COMPILER STATE/DESCRIPTOR + PHASE0 + BOOK/KM/LIVE DOCS; registry-only leaf).
  `specs/spec.spec` now has an active `function_definition` part for top-level `fn name(args) { body }` and
  dispatches it from `spec_file`. The Perl reference uses a documented temporary pre-bootstrap registry bridge:
  it extracts top-level function definitions, strips them from the source passed to ordinary validation/bootstrap
  while preserving newlines, parses bodies through the ActionIR AST block parser, and attaches the registry to
  compiled state.
  **Descriptor:** public descriptors now expose `functions`, `meta.function_order`, and `meta.function_count`.
  Each definition records ordered params, arity, source/body spans, body source, and `body_ast`. Diagnostics reject
  duplicate functions, invalid/duplicate params, reserved runtime/lifecycle/function symbols, built-in helper or
  control-name collisions, and rule-label collisions before runtime.
  **Boundary:** registered value-position calls still diagnose as unresolved helpers with zero raw fallback and
  remain not ActionIR-ready until `.4.2.2`; standalone discard and purity hardening remain `.4.2.3`.
  **Verification:** Perl syntax checks PASS for registry/compiler/compiler-state/phase0; focused descriptor probes
  PASS; `specs/spec.spec` descriptor compile ratio **1.0000**; focused AST suite PASS; `mdbook build
  docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry, and `git diff --check` PASS;
  `bash tools/run_ci_local.sh` PASS with phase0 **1005 tests**.
  **Frontier:** `SPEC-FORMAT-TERSE.4.2.2` (Perl user-function value-call execution), then `.4.2.3`, `.4.3.1`,
  `.4.3.2`, and `.3.2.2`.
- 2026-07-01: **SPEC-FORMAT-TERSE.4.1 — user-function contract/inventory locked**
  (TASK TREE + ROADMAP + BOOK/KM/LIVE DOCS; **no parser/compiler/runtime code change**). The function MVP is
  now exact before implementation: top-level `fn name(args) { ... }`, exact arity, eager argument evaluation,
  fresh function-local parameter/work-variable scope, pure value/block body, final-expression or `return(expr)`
  result, receiver-chain composition from returned values, and silent discard for standalone user-function call
  statements. Collision boundaries are explicit: function names must not collide with built-in helpers,
  control/lifecycle keywords, rule labels, reserved runtime symbols, or another function definition; parameters
  must be unique valid non-reserved identifiers.
  **Inventory:** `specs/spec.spec` owns final function grammar but has no active `function_definition` rule yet.
  Bootstrap has no first-class `fn` support. Perl ActionIR already parses user-call shapes and diagnoses
  value-position unknown calls through unresolved-helper metadata; standalone unknown calls remain raw until the
  registry owns discard. Rust already parses call/fluent expression shapes, but unknown names fall through
  `Engine::call_helper` to warning+`undef`; Rust needs a registry resolver before helper fallback.
  **Verification:** focused TOOLBOX probes PASS; source/book inventory complete; Knowledge Map regenerate/check,
  memory architecture, doctrine registry, `mdbook build docs/linkedspec-book`, `git diff --check`, and
  `bash tools/run_ci_local.sh` PASS. Full local CI included phase0 **1004 tests**.
  **Frontier:** `SPEC-FORMAT-TERSE.4.2.1` (Perl function-definition grammar/registry seam), then `.4.2.2`,
  `.4.2.3`, `.4.3.1`, `.4.3.2`, and `.3.2.2`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.4 — `fn` grammar ownership locked**
  (SPEC.SPEC POLICY + PHASE0 LOCK + BOOK/KM/LIVE DOCS). `specs/spec.spec` now states that permanent
  `fn name(args) { ... }` grammar belongs to the self-hosted grammar surface, not to lasting hardcoded bootstrap
  support. Phase0 locks prove `BootstrapSpec.pm` and `BootstrapSpec/Core.pm` have no `fn name(...)` grammar
  pattern or named function-definition node support; current bootstrap parsing of `fn`-shaped text yields only
  generic unsupported paragraph content, not a structured function node/payload.
  **Verification:** `perl -Iperl -c t/phase0_regression.t` PASS; direct bootstrap parse probe PASS; targeted
  source `rg` PASS; `prove -Iperl t/phase0_regression.t` PASS with phase0 **1004 tests**; `mdbook build
  docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry, `git diff --check`, and
  `bash tools/run_ci_local.sh` PASS.
  **Frontier:** Perl ActionIR text-to-AST migration is closed by this leaf; PNT returns to
  `SPEC-FORMAT-TERSE.4.1` for user-defined function contract/inventory.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.3.2 — unknown AST value calls diagnose**
  (PERL ACTIONIR + FOCUSED TEST + PHASE0 + BOOK/KM/LIVE DOCS). Unknown typed calls in return/value positions
  now diagnose through `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` instead of leaking generated host calls.
  `return(user_fn("x"))` and `return(user_fn("x").trim())` no longer emit host `user_fn(...)`; descriptor
  metadata records unresolved helper `user_fn` and blocks language-agnostic readiness. Existing DSL and
  compatibility helper names are fenced as known so declaration aliases, retired return helpers, source-boundary
  helpers, internal trace calls, and statement-only array mutation methods are not mistaken for future user
  functions. Standalone unknown function-shaped statements remain raw until the function registry owns discard
  semantics.
  **Verification:** syntax checks PASS for touched ActionIR modules and `t/actionir_ast_parser.t`; focused
  probes PASS for unknown return calls/chains, supported `call(...)`/`input_text()` payloads, flow helper
  composition, declaration aliases, and unsupported array mutation value chains; `prove -Iperl
  t/actionir_ast_parser.t` PASS with **20 subtests**; `prove -Iperl t/phase0_regression.t` PASS with phase0
  **1003 tests**; `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry,
  `git diff --check`, and `bash tools/run_ci_local.sh` PASS.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.4`, now complete.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.3.1 — short wrapper aliases retired**
  (PERL ACTIONIR + RUST CORE/RUNTIME + SPECS/FIXTURES + PHASE0 + BOOK/KM/LIVE DOCS). `s(...)`, `a(...)`, and
  `h(...)` are no longer canonical wrapper spellings. Repo-owned specs, corpus fixtures, tests, root guides, and
  mdBook examples now use `scalar(...)`, `array(...)`, and `hash(...)`. Perl lowering no longer normalizes the
  short names into long wrappers; residual calls diagnose as `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:s|a|h`
  with zero raw-Perl fallback. Rust core/runtime wrapper examples and dispatch paths now use the canonical names.
  **Verification:** residual shorthand scan over specs/corpora clean; syntax checks PASS for touched ActionIR
  modules/tests; `prove -Iperl t/actionir_ast_parser.t` PASS; `prove -Iperl t/phase0_regression.t` PASS with
  phase0 **1003 tests**; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --lib` PASS with **140
  tests**; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib` PASS with **117 tests**;
  `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry, `git diff --check`,
  and `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.3.2` user-function AST call handoff.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.3 — short wrapper alias retirement split**
  (TASK TREE + LIVE DOCS + KM; **no parser/compiler/runtime code change**). User clarified that `s(...)`,
  `a(...)`, and `h(...)` should be retired too. Read-only discovery found active use in shipped specs, phase0
  locks, and book examples, so the former `.5.3` user-function handoff leaf was split: `.5.3.1` retired the
  shorthand wrapper aliases and `.5.3.2` completed the value-position user-function AST diagnostic handoff.
  **Verification:** usage discovery completed; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.3.1` retire `s(...)`, `a(...)`, and `h(...)`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.2 — dropped value statement lowering**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). Supported standalone value statements that already parse
  into typed ActionIR AST value nodes now lower as discarded values through a `VALUE_DROP` contract. `trim(" x ")`,
  `concat("a","b")`, and simple receiver chains such as `" x ".trim()` no longer remain raw host-call text; they
  lower through the existing value-expression dispatcher and then discard the result. Malformed covered standalone
  helpers still report unresolved-helper metadata with zero raw fallback, compatibility `s(...)`/`a(...)`/`h(...)`
  substitution still returns value expressions, and unknown user-function-shaped calls/chains stay raw for `.5.3`.
  **Verification:** syntax checks PASS for touched ActionIR modules and `t/actionir_ast_parser.t`; focused
  `t/actionir_ast_parser.t` PASS with **20 subtests**; `prove -q -Iperl t/phase0_regression.t` PASS with phase0
  **1002 tests**; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.3` prepare user-function calls to resolve through AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.1 — fallback-boundary audit**
  (TASK TREE + BOOK/KM/LIVE DOCS; **no parser/compiler/runtime code change**). The remaining Perl ActionIR
  fallback boundary is now classified before code. Malformed AST-covered helper forms already use
  unresolved-helper diagnostics with zero raw fallback; retired helpers and non-DSL host-shaped statements stay
  explicit compatibility debt; narrow return payload compatibility remains fenced; all-bare `push(A,B)` remains
  the child-call ambiguity contract. Unknown typed calls/chains such as `return(user_fn("x"))` and
  `return(user_fn("x").trim())` were the real handoff risk because they lowered as generated host calls
  and reported ready at the time; `.5.3.2` has since resolved value-position cases as diagnostics. Targeted search found no current
  lasting `fn <name>(...) { ... }` grammar in bootstrap or `specs/spec.spec`; `.5.4` still owns the grammar/proof
  lock.
  **Verification:** TOOLBOX `call_spec_handler_subst`, descriptor, and AST parser probes PASS; code reads
  completed for the lowering/metadata seams. `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge
  Map gates PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS with focused AST suite and phase0
  **1002 tests**.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.2` retire AST-covered supported-surface fallback leakage without
  disturbing the fenced compatibility debt.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5 — fallback retirement and function handoff split**
  (TASK TREE + LIVE DOCS; **no parser/compiler/runtime code change**). The final Perl ActionIR AST migration
  parent is now split before code into `.5.1` fallback-boundary audit, `.5.2` AST-covered supported-surface
  fallback leakage retirement, `.5.3` user-function AST call handoff, and `.5.4` `specs/spec.spec` function
  grammar plus bootstrap-parser retirement lock. The split preserves the user decision that lasting
  `fn <name>(...) { ... }` grammar belongs in `specs/spec.spec`, while bootstrap parser support is temporary
  migration debt to remove or prove absent after the AST path can carry the surface.
  **Verification:** `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.1` audit the remaining supported-surface text fallback boundary
  before code.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.4 — while control lowering from AST**
  (PERL ACTIONIR CONTROLFLOW + FOCUSED TEST + BOOK/KM/LIVE DOCS). `LinkedSpec::ActionIR::ControlFlow` now
  parses attached `while(cond) { ... }` statements through the ActionIR AST parser before reusing the existing
  while lowerer. Loop conditions and attached body statements materialize from typed AST fields, not original
  statement text or AST `source` strings. Generated loop shape, condition re-evaluation, body lowering, and the
  deterministic 10000-iteration safety guard stay stable. Bodyless `while(...)` marker nodes remain parser
  shape only because the current DSL has no `endwhile` product syntax.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **19
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5` retire supported-surface text fallback and unblock
  user-defined functions on the AST path; split before code if needed.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.3 — switch-family control lowering from AST**
  (PERL ACTIONIR CONTROLFLOW + FOCUSED TEST + BOOK/KM/LIVE DOCS). `LinkedSpec::ActionIR::ControlFlow` now
  parses `switch`, `case`, `default`, `endcase`, and `endswitch` statements through the ActionIR AST parser
  before reusing the existing switch stack lowering engine. Switch source expressions, case match values,
  attached case/default bodies, parsed switch branch lists, and end markers materialize from typed AST fields,
  not original statement text, fake fallback bodies, or AST `source` strings. Generated switch shape,
  switch-source single evaluation, case ordering, default-once behavior, attached-switch body handling, and
  marker `endcase`/`endswitch` stack closure stay stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **18
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.4` lower `while` statement forms from typed condition/body
  nodes while preserving the iteration-safety guard.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.2 — if-family control lowering from AST**
  (PERL ACTIONIR CONTROLFLOW + FOCUSED TEST + BOOK/KM/LIVE DOCS). `LinkedSpec::ActionIR::ControlFlow` now
  parses `if`/`i`/`when`, `elseif`/`elif`, `else`/`otherwise`, and `endif` statements through the ActionIR AST
  parser before reusing the existing branch lowering engine. Conditions and attached bodies materialize from
  typed AST fields, not original statement text or AST `source` strings; generated branch shape, implicit-close
  behavior, marker `endif`, and when/otherwise alias semantics stay stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **17
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.3` lower `switch`/`case`/`default` statement forms from typed
  source/match/body/default nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.1 — structured control AST parser nodes**
  (PERL ACTIONIR AST PARSER + FOCUSED TEST + BOOK/KM/LIVE DOCS; **production lowering unchanged**).
  `LinkedSpec::ActionIR::AST::Parser` now parses attached-block and marker control-flow forms into typed
  `control_if`, `control_else`, `control_endif`, `control_while`, `control_switch`, `control_case`,
  `control_default`, `control_endcase`, and `control_endswitch` nodes. Conditions, switch source expressions,
  case match expressions, attached bodies, body source spans, and switch case/default branches are typed where
  applicable. Inline value-form `if(...)` / `switch(...)` helpers still parse as generic `call` nodes.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **16
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS; direct
  `perl -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build docs/linkedspec-book`
  PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.2` lower `if`/`when`/`otherwise` statement forms from typed
  condition/body nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4 — structured-control AST lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). The broad structured-control migration is
  now split before code into `.4.4.1` typed control-flow AST parser nodes and node-shape locks, `.4.4.2`
  `if`/`when`/`otherwise` lowering from AST, `.4.4.3` `switch`/`case`/`default` lowering from AST, and `.4.4.4`
  `while` lowering from AST while preserving iteration-safety behavior.
  **Verification:** memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.1` add typed control-flow AST parser nodes and focused parser
  locks before switching lowering consumers.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.3 — block-value side effects and block-local returns from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering` now routes parsed `block_value` nodes
  into the AST value path before legacy block splitting. Inside AST block values, non-final side-effect
  statements lower from typed `action_stmt.expr` nodes, block-local `return(...)` payloads lower from typed call
  arguments, and final expressions lower from typed statement expressions while the existing guarded early-return
  wrapper stays stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/actionir_ast_parser.t` PASS with **15
  focused subtests**; `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4` split structured control-flow statement AST lowering.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.2 — helper-call statements and returns from AST**
  (PERL ACTIONIR + SCANNER DIAGNOSTIC + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering` now consumes typed
  AST `call` nodes for `return`, `return_undef`, `set_key`, `push`, `push_value`, and `push_nonempty`, and
  typed `fluent_chain` nodes for array end-mutation statements. `DeclareMethod` bridges top-level `set`/`assign`
  through the same AST materialization while preserving the synthetic dependency-builder contract.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm` PASS; `perl -Iperl -c
  perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm` PASS; `perl -Iperl -c
  t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl
  t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build docs/linkedspec-book` PASS;
  memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.3` lower block-value side-effect statements and block-local
  returns from AST block/statement nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.1 — assignment/mutation statement operators from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering` now consumes typed AST
  `assign_scalar`, `assign_array_append`, and `assign_hash_index` nodes before the legacy statement-regex
  paths. The implementation materializes trusted helper/action expression text from typed AST fields, then
  enters the existing scalar assignment, array append, and hash-index mutation policies so target-kind
  inference, source-slot scalar reads, mutation value-slot reads, and hash-key lowering stay stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `perl -Iperl -c perl/LinkedSpec.pm` PASS;
  `prove -v -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/phase0_regression.t` PASS with phase0
  **1002 tests**; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.2` lower helper-call statements and returns from AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4 — statement/control AST lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). The broad statement/control migration is
  now split before code into `.4.1` assignment/mutation operator AST nodes, `.4.2` helper-call statements and
  returns, `.4.3` block-value side-effect traversal and block-local returns, and `.4.4` structured
  control-flow forms. This keeps assignment operators, helper calls, expression-valued blocks, and control
  syntax on separate verification surfaces.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.1` lower parsed assignment/mutation operator statement nodes
  from AST.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.4 — return-payload AST traversal landed**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_return_payload_expr(...)` now
  parses generalized return payloads through `LinkedSpec::ActionIR::AST` and returns AST-lowered typed values
  before the legacy helper-substitution loop. Direct shapes, nested helper calls, direct/nested access, block
  values, receiver chains, primitive literals, and bare scalar reads now share the typed value traversal used by
  `_lower_method_value_expr(...)`. AST `variable` payloads still route through scalar source-slot reads, so
  `return(count)` stays `return $count`; raw compatibility payloads such as `\(my $capt = capture_slice())`
  keep the narrow legacy fallback.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `perl -Iperl -c perl/LinkedSpec.pm` PASS;
  `prove -v -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/phase0_regression.t` PASS with phase0
  **1002 tests**; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4` replace statement/control lowering with AST lowering.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.3 — receiver-dot `fluent_chain` AST lowering landed**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  consumes AST `fluent_chain` nodes for receiver-dot value chains before the legacy receiver-dot text
  normalizers. The dispatcher traverses typed receiver/call/argument nodes for array, hash, string, and number
  receiver families, then reuses the existing Perl helper catalog through the compatibility bridge. Existing
  behavior is preserved for bare scalar/hash receiver wrapping, array pipeline helper names, block-valued
  receivers, string/hash bridges to array terminals, `join_values` delimiter-first mapping, numeric arity
  checks, and numeric terminal continuation behavior.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS; targeted
  public lowering probes PASS; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates
  PASS; `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `bash tools/run_ci_local.sh`
  PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.4` replace return-payload helper substitution with AST
  traversal/diagnostics, then `.4` statement/control AST lowering.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2.3 — covered-call diagnostics landed**
  (PERL ACTIONIR + DIAGNOSTICS + FOCUSED TEST + BOOK/KM/LIVE DOCS). Unsupported AST call forms for helper
  families already owned by `.3.2.1`/`.3.2.2` no longer lower into generated host-language calls. Known helper
  calls that fail covered AST arity or argument materialization now become a harmless
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` sentinel expression, and `ActionIR::Diagnostics` reports that
  sentinel through the existing unresolved-helper metadata while keeping `raw_perl_dependency_count == 0`.
  Unknown calls remain reserved for the future user-function path.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm` PASS; `perl -Iperl -c t/actionir_ast_parser.t`
  PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS; targeted public lowering probes PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.3` replace receiver-dot `fluent_chain` lowering with AST
  traversal, then `.3.4` return-payload AST traversal.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2.2 — aggregate helper calls from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  dispatches deprecated wrapper aliases plus aggregate-wrapper, collection, reducer, and hash helper families
  from AST `call` nodes before the legacy text cascade. Covered calls rebuild helper surfaces from typed AST
  fields, preserving aggregate symbol slots, quoted-wrapper literal boundaries, and nested value-only payloads
  before reusing the existing Perl helper catalog through the compatibility bridge.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -Iperl t/actionir_ast_parser.t` PASS; targeted public
  lowering probes PASS; `mdbook build docs/linkedspec-book` PASS; `bash tools/run_ci_local.sh` PASS with
  phase0 **1002 tests**.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2.3` (now completed above), then `.3.3`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2.1 — value-only helper calls from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  dispatches supported AST `call` nodes for scalar normalization, string predicate/composition,
  coalesce/concat, scalar-argument numeric helpers, and explicit `num_*` comparisons. Covered calls
  recursively materialize argument AST nodes before reusing the existing Perl helper catalog through the
  compatibility bridge. At that leaf, deprecated wrapper aliases such as `scalar(...)`/`array(...)`/
  `hash(...)`, aggregate-wrapper, collection, reducer, hash, symbol-slot, and receiver-chain helpers stayed
  queued and were not the canonical destination syntax; `.3.2.2` above now covers the aggregate/helper subset.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -Iperl t/actionir_ast_parser.t` PASS; targeted public
  lowering probes PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2.2` lower aggregate-wrapper and collection helper calls from
  AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2 — AST helper-call lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). Helper-call AST lowering is now split by
  argument-slot risk: `.3.2.1` value-only helper families, `.3.2.2` aggregate wrappers and collection/hash
  helpers with explicit symbol/value slot policy, and `.3.2.3` diagnostics for covered calls that would
  otherwise leak as generated host-language calls.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2.1` lower value-only helper-call composition from AST call
  nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.1 — non-call value AST lowering dispatcher landed**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  parses through `LinkedSpec::ActionIR::AST` and lowers primitive literals, scoped bare scalar reads, direct
  indexed/nested access, array/hash shape literals, and block values from typed nodes. Direct-access reserved
  path atoms such as `true` and `CAPTURE` still preserve the legacy fallback behavior. Helper calls and
  statement-level block side effects use an explicit compatibility bridge until later children replace those
  surfaces.
  **Verification:** `prove -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/phase0_regression.t` PASS
  with **1002 tests**.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2` lower helper-call value composition from AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3 — value/receiver AST lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). The broad `.3` parent is now divided into
  four executable children: `.3.1` non-call value AST dispatcher, `.3.2` AST helper-call composition, `.3.3`
  AST receiver-dot value chains, and `.3.4` AST return-payload traversal plus diagnostics. This keeps
  user-defined functions blocked until function calls can enter the Perl reference as typed AST `Call` nodes
  and act as ordinary receiver-chain-capable value expressions.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.1` introduce the AST value-lowering dispatcher for non-call
  value nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.2 — Perl ActionIR AST parser seam added**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS; **existing lowering unchanged**). Added
  `LinkedSpec::ActionIR::AST` and `LinkedSpec::ActionIR::AST::Parser` as an additive typed parser seam behind
  the current ActionIR rewrite pipeline. The parser covers action blocks/statements, calls, standalone
  expression-value drops, receiver chains, variables, direct access, shape literals, block values, primitive
  literals, and scalar/array/hash assignment nodes with source spans. Focused tests lock function-call,
  numeric-literal, and block-valued receivers; current `call_spec_handler_subst` lowering remains authoritative.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3` replace value-expression and receiver-chain lowering with AST
  lowering before user-defined functions proceed.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.1 — Perl ActionIR text-lowering inventory locked**
  (TASK TREE + KM + LIVE DOCS; **no runtime behavior change**). The current Perl text-to-text boundaries are
  now explicitly mapped: raw statement splitting in `StatementSplit`, method-call text parsing in `MethodExpr`,
  raw contract scanners, contract lower callbacks, canonical `RAW_PERL` fallback, source-span replacement in
  `RewritePipeline`, recursive raw expression/receiver lowering in `MethodLowering`, and the
  `RuleIR::EmitContext` bridge/auto-working-var scanners. The replacement model is Rust-aligned
  `ActionBlock`/`ActionStmt` plus typed `Call`, `FluentChain`, value, mutation, and control nodes with source
  spans. Standalone expression statements silently drop their values, so future user-function calls remain
  ordinary expressions.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.2` (now completed above), then `.3`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.0 — text-to-AST doctrine adopted**
  (ADR + TASK TREE + BOOK/KM/LIVE DOCS; **no runtime behavior change**). The Rust-style text-to-AST path is now
  the cross-variant doctrine: helper/action language must parse into typed AST/IR before lowering, execution, or
  code emission. Perl ActionIR text-to-text lowering is migration debt; future Dart, Julia, and Lua backends
  must start with AST. User-defined functions must be implemented through
  AST call/function nodes, not textual macros.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.1` (now completed above), then `.2`.
- 2026-07-01: **SPEC-FORMAT-TERSE.4 — user-defined function surface owned**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). User-defined pure functions are now the
  active Round 4 terse-language surface. The MVP contract starts with top-level `fn name(args) { ... }`,
  explicit parentheses for zero and nonzero arities, pure value/block bodies, explicit positional parameters,
  and no recursion/closures/lambdas/currying/implicit caller-state capture. Function calls are ordinary value
  expressions: their results can feed helpers, assignments, returns, mutations, and receiver-dot chains; if a
  call is used as a standalone statement, its value is silently dropped. The durable grammar decision is that
  function syntax belongs in `specs/spec.spec`; any bootstrap-parser `fn <name>(...) { ... }` support is
  temporary migration debt to remove after the text-to-AST path can carry the surface.
  **Then-frontier:** `SPEC-FORMAT-TERSE.4.1` contract/inventory before code (now complete; current frontier is
  `.4.2.1`), then `.3.2.2` arithmetic symbol callees.
- 2026-07-01: **SPEC-FORMAT-TERSE.3.2.1 — numeric word aliases landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM). Function-form aliases `add`, `sub`, `mul`,
  `div`, `mod`, `abs`, `floor`, `ceil`, `round`, `min`, `max`, `clamp`, `sum`, `avg`, `median`, and `range`
  now dispatch to the existing `num_*` helper family on Perl and Rust. Existing `num_*` spellings remain
  accepted.
  **Boundary:** arithmetic symbol callees such as `+(a,b)` remain `.3.2.2`; comparison words remain
  `.3.2.3`. `gt(10, 2)` is still the existing string comparison helper, not a numeric alias.
  **Verification:** Perl syntax checks PASS; focused Perl probes PASS, including receiver-chain preservation;
  phase0 PASS with **1002 tests**; oracle regeneration produced **53 fixtures**; Rust `corpus_oracle` PASS
  over 53 fixtures; focused Rust integration PASS; mdBook build PASS.
  **Frontier:** `SPEC-FORMAT-TERSE.3.2.2`, then `.3.2.3`, then `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.3.2 — arithmetic/comparison call surface split**
  (TASK TREE + KM + LIVE DOCS; **no runtime behavior change**). Round 3 arithmetic/comparison calls are now
  split before code. At split time, ground truth showed the implemented numeric family was `num_*`; bare
  `add(...)`/`sum(...)` did not yet lower as numeric helpers; symbol callees such as `+(...)` were not portable
  parser inputs and raw Perl could misinterpret them if they fell through; and bare
  `eq`/`ne`/`gt`/`ge`/`lt`/`le` are current string comparisons in the book/lowering path.
  **Decision:** keep one `callee(args)` grammar; do not add the `(op a, b)` Lisp-prefix form. Split children:
  `.3.2.1` numeric word aliases, `.3.2.2` arithmetic symbol callees, `.3.2.3` comparison spelling policy.
  **Frontier:** `SPEC-FORMAT-TERSE.3.2.1`, then `.3.2.2`, `.3.2.3`, `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.3.1 — edge syntax contract locked**
  (TASK TREE + BOOK + KM + LIVE DOCS; **no runtime behavior change**). Round 3 keeps the existing edge split:
  `->` is the action-edge surface and `=>` is the blind-call surface. Grouped action-edge targets remain valid
  only as shared-block factoring (`-> RuleA | RuleB { ... }`); the block-less grouped form `-> RuleA | RuleB`
  stays invalid with the existing "Grouped action-edge targets require a shared code block" diagnostic.
  **Verification:** audited existing phase0 locks for shared-block parse expansion, validation acceptance,
  missing-block rejection, and three-target grouping; focused `perl -Iperl` probes confirmed shared-block
  acceptance, two-target `ACODE` expansion, and block-less rejection; full phase0 passed (`prove -q -Iperl
  t/phase0_regression.t`, 1001 tests); local CI passed; mdBook formal/action chapters and KM fact card
  updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2` (now split above), then `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.5.0 — future variant parity ownership/inventory landed**
  (TASK TREE + KM + BOOK STATUS + LIVE DOCS; **no runtime behavior change**). The active terse tree now has a
  concrete ownership container for future backend parity before any non-Rust variant code. Current implemented
  backends are the Perl reference and the Rust interpreter under `rust/`. Julia and Dart remain the accepted
  future backend targets from ADR `0006` and Phase 8, but are deferred to dedicated backend implementation
  task trees before code. ADR `0021` now accepts Lua too and moves the scheduled Dart, Julia, and Lua rollout
  to `FUTURE-PARITY-BACKLOG`.
  **Verification:** full bootstrap/roadmap/mdBook/codebase read completed; source inventory found no tracked
  Julia/Dart/Lua implementation paths outside the unrelated nested `rgx` checkout; Knowledge Map backend fact
  corrected from the stale pre-Phase-9 "Perl only" wording; backend handoff chapter status updated to the
  current 52-fixture Rust corpus state; no parser/compiler/runtime code changed.
  **Then-frontier:** `SPEC-FORMAT-TERSE.3.1` (now completed above), then `.3.2`, then `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.5 — block-valued receiver-dot chains landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM). Expression-valued blocks can now be
  receivers for the existing compatible array/string/hash/number value-chain families. The block evaluates
  first; its yielded value feeds the helper family selected by the first receiver method. Locked examples:
  `{ [3, 1, 2] }.sorted().join_values(",")`, `{ return(["x", "y"]); ["bad"] }.join_values("|")`,
  `{ set(raw, " a-b "); raw }.trim().split("-").count()`,
  `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`.
  **Verification:** Perl syntax checks PASS; focused Perl probes PASS; focused Rust `.2.3.5.5` parser/runtime
  locks PASS; oracle regeneration produced **52 fixtures**; Rust `corpus_oracle` PASS over 52 fixtures;
  phase0 PASS with **1001 tests**; mdBook/KM/live docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.5.0` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.6 — aggregate wrapper quoted-name boundaries landed**
  (PERL ACTIONIR + RUST LOCKS + PHASE0 + ORACLE + BOOK/KM). Bare aggregate wrappers remain explicit typed
  working-variable reads: `array(foo)` / `a(foo)` read `@foo`, and `hash(bar)` / `h(bar)` read `%bar`.
  Quoted wrapper arguments are not aliases and are not scalar-indirect lookups: `array("foo")` /
  `array('foo')` are literal array-constructor payloads, and quoted hash constructor arguments are fixed-key
  payloads under the existing arity rules. Direct `[...]` / `{...}` shapes are now the preferred terse
  array/hash constructor examples in the variant-neutral mdBook; `foo.array()`-style postfix typed views stay
  out of scope.
  **Verification:** Perl syntax checks PASS; focused lowering/runtime/source probes PASS; phase0 PASS with
  **1000 tests**; focused Rust `.2.3.5.6` locks PASS; oracle regeneration produced **51 fixtures**; Rust
  `corpus_oracle` PASS over 51 fixtures; mdBook/KM/live docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.5` (now completed above), then `SPEC-FORMAT-TERSE.5.0` (now
  completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.4 — number receiver-dot value chains landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure numeric helper chains now work from
  scalar, integer-literal, and decimal-literal receivers on Perl and Rust:
  `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`,
  `5.mod(2)`, `3.5.floor().add(1)`, and `3.5.round()` are locked. Comparison receiver methods (`eq`, `ne`,
  `gt`, `ge`, `lt`, `le`) are terminal values; invalid continuations return `undef`/`null`. Numeric array
  reducers remain explicit array-consuming helpers, and statement/lifecycle calls such as `declare(...)` are
  not terse receiver methods.
  **Verification:** Rustfmt PASS on touched Rust files; Perl syntax checks PASS; focused Rust parser/runtime
  locks PASS; oracle regeneration produced **50 fixtures**; Rust `corpus_oracle` PASS over 50 fixtures;
  phase0 PASS with **999 tests**; mdBook/KM/live docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.5` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.3 — string receiver-dot value chains landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure string/scalar helper chains now
  work from scalar and string-literal receivers on Perl and Rust:
  `raw.trim().lowercase().replace_substr("-", "_")`, `raw.trim().split("-").trim_each().join_values("|")`,
  and `"abcdef".substr(1, 3).uppercase()` are locked. String-returning links compose; `split(delim)` bridges
  explicitly into the array receiver family; terminal methods (`length`, `starts_with`, `ends_with`,
  `contains_substr`, `matches`) end the chain and invalid continuations return `undef`/`null`. Value-form
  `split(...)` and `substr(...)` now lower as portable helper payloads.
  **Verification:** Perl syntax checks PASS; phase0 PASS with **998 tests**; focused Rust parser/runtime locks
  PASS; oracle regeneration produced **49 fixtures**; Rust `corpus_oracle` PASS over 49 fixtures; mdBook/KM/live
  docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.4` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.2 — hash receiver-dot value chains landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure hash helper chains now work from a hash
  receiver on Perl and Rust: `meta.set_key("stage", "normalized").count_keys()`,
  `meta.merge_hash(hash(extra)).scalaref("a")`, and
  `meta.sorted_keys().join_values(",")` are locked. Hash-returning links feed later hash helpers, while
  `sorted_keys()` / `sorted_values()` bridge into array receiver chains. Statement-level `set_key(meta, ...)`
  and `meta[key] = value` remain the mutating forms; receiver-dot `meta.set_key(...)` is pure unless assigned
  back. Rust `merge_hash` now matches the documented later-argument override contract.
  **Verification:** Perl syntax checks PASS; phase0 PASS with **997 tests**; focused Rust parser/runtime locks
  PASS; oracle regeneration produced **48 fixtures**; Rust `corpus_oracle` PASS over 48 fixtures; mdBook/KM/live
  docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.3` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.1 — array receiver-dot value chains landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure array helper chains now work from an array
  receiver on Perl and Rust: `items.sorted().drop_front(2).first()`, `items.uniq().join_values(",")`,
  `items.filter_match(/^a$/).count()`, and `phrases.split_each("-").filter_match(/^aa$/).count()` are locked.
  Receiver-dot `join_values` preserves the delimiter-first helper contract. Public function-style pipeline
  lowering keeps its legacy source shape; the new pure array-value path is scoped to receiver-dot chains. The
  `.1.6` end mutations remain statement-only and return `undef` without mutating in value slots.
  **Verification:** Perl syntax checks PASS; phase0 PASS with **996 tests**; focused Rust parser/runtime locks
  PASS; oracle regeneration produced **47 fixtures**; Rust `corpus_oracle` PASS over 47 fixtures; mdBook/KM/live
  docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.2` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5 — return-type method chaining split**
  (TASK TREE + BOOK/KM/LIVE DOCS; **no runtime behavior change**). The receiver-dot value-chain model is now
  specified before implementation and split by return family. `.2.3.5.1` owns array receiver-dot value chains;
  `.2.3.5.2`, `.2.3.5.3`, and `.2.3.5.4` own hash, string, and number families. Current `.1.6`
  receiver-dot array end mutations remain statement-only: `push_back`/`push_front` mutate, `pop_back`/
  `pop_front` discard the removed value, and value-position/chained forms stay out of contract until a child
  leaf defines them explicitly. The mdBook inline-control wording is now aligned with `.2.3.4.2`: inline
  `if(...)` and `switch(...)` are portable lazy value helpers in `return(...)`, assignment RHS, and fluent
  `.return(...)` slots.
  **Verification:** LinkedSpec TOOLBOX probes recorded the Perl receiver-chain boundary; Rust source read
  confirmed the parser/runtime split; mdBook build, Knowledge Map, memory, doctrine, and diff checks PASS.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.1` (now completed above).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.4.2 — Perl inline-composite value control lowering landed**
  (PERL ACTIONIR + PHASE0 + ORACLE + BOOK/KM). Inline `if(...)` and `switch(...)` now produce selected branch
  values on the Perl reference in supported value-consuming slots: `return(...)`, assignment RHS, and fluent
  `.return(...)`. The implementation keeps statement-control forms separate, lowers flow literal
  `true`/`false` to host `1`/`0`, supports `elseif(...)`, `else(...)`, and the Rust-compatible plain third
  `if` fallback, evaluates `switch` sources once, and recurses auto-working-variable discovery through inline
  control payloads and expression-valued branch blocks. `tools/gen_oracle_corpus.pl` added
  `terse_2_3_4_2_inline_if_value_control` and
  `terse_2_3_4_2_inline_switch_value_control`; Rust `corpus_oracle` now passes with **46 fixtures**. The
  asserted portable contract is the selected payload value, not any specific legacy/action-edge `?...:` tag
  string.
  **Verification:** changed Perl module syntax checks PASS; phase0 PASS with **995 tests**; oracle
  regeneration PASS; Rust `corpus_oracle` PASS over 46 fixtures. Full gates are recorded in the commit
  workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.5`** (return-type method chaining design and first implementation split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.4.1 — Rust helper-context bare aggregate argument parity landed**
  (RUST RUNTIME + ORACLE + BOOK/KM). Rust now treats bare working-variable names as typed aggregate snapshots
  only in helper argument slots whose callee contract already implies a hash or array, closing the audited
  `merge_hash(hash_copy(base), overlay)` mismatch and the matching array-helper surface without changing
  ordinary bare-variable scalar reads. Focused runtime locks cover the merge case, the broader hash/object
  helper family (`set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `has_key`, `scalaref`,
  `flat_hash`), and the array helper family (`sorted`, `reversed`, `first`, `last`, `take`, `drop_front`,
  `contains`, `index_of`, `num_sum`, `flat_array`). `tools/gen_oracle_corpus.pl` added
  `terse_2_3_4_1_bare_hash_helper_arg_composition` and
  `terse_2_3_4_1_bare_array_helper_arg_composition`; Rust `corpus_oracle` now passes with **44 fixtures**.
  **Verification:** focused Rust runtime `terse_2_3_4_1` PASS; oracle regeneration PASS; Rust
  `corpus_oracle` PASS over 44 fixtures. Full gates are recorded in the commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.4.2`** (Perl inline-composite value-control lowering).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.4 — full composability audit split**
  (AUDIT/TREE/BOOK/KM + ORACLE FIXTURE; **no runtime behavior change**). Pure value-helper nesting is now
  locked by the new `terse_2_3_4_deep_pure_helper_composition` oracle fixture:
  `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))`; the Rust corpus passes with
  **42 fixtures**. The unsupported sites were split before code: `.2.3.4.1` owns Rust helper-context aggregate
  bare reads after diagnostic `merge_hash(hash_copy(base), overlay)` returned Perl `2` but Rust `1`, and
  `.2.3.4.2` owns Perl inline-composite value-control lowering after generated-source probes showed
  `return(if(...))` / `return(switch(...))` do not reliably return selected branch values. Receiver-dot
  value/chaining remains `.2.3.5`.
  **Verification:** TOOLBOX probes; diagnostic Rust corpus mismatch; final oracle regeneration; Rust
  `corpus_oracle` PASS over 42 fixtures; mdBook/KM/memory/doctrine/diff and local CI are recorded in commit
  workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.4.1`** (Rust helper-context aggregate bare reads).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.3.1 — Rust `tclite` default-mode repetition parity landed**
  (RUST CORE/RUNTIME + ORACLE + BOOK/KM). Rust now treats bare default rules as zero-min repeated-choice loops
  and honors `I`/preamble `return(expr)` as an immediate child-invocation return before local entry-regex
  matching. That matches the Perl dispatch model used by shipped `tclite` bracket and quote children.
  `tools/gen_oracle_corpus.pl` restored `tclite_command_subst` (`[]`) and `tclite_double_quote` (`""`); the
  regenerated corpus now has **41 fixtures** and both cases pass with the tagged Perl-reference `tcl_script`
  values. **Verification:** focused Rust core/runtime/default-mode and lifecycle locks PASS; oracle generator
  syntax/regeneration PASS; Rust `corpus_oracle` PASS over 41 fixtures; mdBook/KM/memory/doctrine/diff and full
  local CI are recorded in commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.4`** (full composability audit and follow-on split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.3 — Rust `tclite` oracle retry split**
  (AUDIT/TREE/KM/BOOK STATUS; **no runtime behavior change**). After Rust compact lifecycle/body receiver
  chains and action-edge explicit/flow fluent chains landed, the deferred `tclite` oracle cases were retried.
  Perl returns `["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
  `["?tcl_script:",[["?double_quote:",[]]]]` for `""`; temporarily re-enabled Rust fixtures still produced
  actual `[]` for both, while the other 39 corpus fixtures passed. The failing fixtures remain out of the
  committed green corpus. **Verification:** Perl reference probes complete; diagnostic Rust corpus oracle
  exposed exactly the two `tclite` failures; final green-corpus regeneration/oracle, mdBook, KM, memory/
  doctrine/diff checks, and full local CI are recorded in commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.3.1`** (Rust default-mode recursive repetition parity for `tclite`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.2 — Rust action-edge explicit/flow fluent chains landed**
  (RUST PARSER + COMPILER/RUNTIME LOCKS + BOOK/KM). Rust now preserves multiline dotted continuations after an
  action edge on the preceding `ActionEdge` and executes the explicit/flow subset: `.push(target)`,
  `.push(child,target)`, `.if/.else/.endif` gating, helper calls such as `.say(...)`, and
  `.return_undef()`/`.return(expr)` continuations. Explicit pushes dispatch the child and append the captured
  child return value to the named target accumulator without leaking the child's accumulator events.
  **Verification:** focused Rust core action-edge flow-chain locks PASS; focused Rust runtime
  `terse_2_3_3_3_2` PASS; existing no-arg action-edge regression PASS; full Rust core/runtime package tests,
  mdBook build, oracle generator syntax, KM regenerate/check, memory/doctrine/diff checks, and full local CI
  PASS in commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.3`** (Rust `tclite` oracle re-enable / default-mode repetition audit).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.1 — Rust compact lifecycle fluent chains landed**
  (RUST PARSER + COMPILER/RUNTIME LOCKS + BOOK/KM). Rust now normalizes compact lifecycle/body receiver chains
  such as `I.return(...)`, `E.return(...)`, and `I.declare(...).set(...).return(...)` into executable lifecycle
  `CodeBlock` statements instead of leaving a standalone `FluentChain` for the compiler to drop. Focused locks
  cover multiline body placement, regex-first header-line inline placement, compiler lifecycle-slot population,
  return-channel behavior, and ordered declaration/mutation chains.
  **Verification:** focused Rust core `lifecycle_compact` PASS; focused Rust runtime `terse_2_3_3_3_1` PASS;
  full Rust core/runtime package tests PASS; mdBook build PASS; oracle generator syntax PASS; KM
  regenerate/check PASS; memory/doctrine/diff checks PASS; full local CI PASS. Rustfmt ran on touched Rust
  files.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.2`** (Rust action-edge explicit/flow fluent chains).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3 — remaining Rust fluent continuations split**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). The remaining Rust fluent parity work is now split:
  `.2.3.3.3.1` owns compact lifecycle/body receiver chains such as `I.return(...)` and
  `I.declare(...).return(...)`; `.2.3.3.3.2` owns action-edge explicit/flow chains such as
  `.push(child,target)` and `.if(...).push(...).else().return_undef().endif()`; `.2.3.3.3.3` owns `tclite`
  re-enable/default-mode repetition audit after fluent parity lands.
  **Verification:** KM retrieval; Perl reference probes; shipped-spec/code search; Rust parser/compiler/runtime
  code-read; focused Rust `.2.3.3.2` regression test PASS; KM/memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.1`** (Rust compact lifecycle/body receiver chains).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.2 — Rust attached fluent block payloads landed**
  (RUST PARSER + RUNTIME LOCKS + BOOK/KM). Rust now parses action-edge and lifecycle-marker
  `.when(cond) { ... }` receiver-fluent block chains by normalizing them to existing attached
  `when/otherwise` statement blocks. Dotted `.otherwise { ... }` and no-dot `otherwise { ... }` fallback tails
  execute on both surfaces, including multiline `}.otherwise {` placement.
  **Verification:** focused Rust core `attached_fluent` PASS; focused Rust runtime `terse_2_3_3_2` PASS;
  full Rust core/runtime package tests PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS
  (`Files=1, Tests=994`). Compact lifecycle/body fluent chains such as `I.return(...)` remain the next Rust
  fluent-parity surface.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3`** (Rust remaining body/standalone fluent continuation audit and
  implementation split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.1 — Rust action-edge fluent continuations landed**
  (RUST PARSER + COMPILER + RUNTIME + BOOK/KM LOCKS). Rust now preserves fluent chains on `->` action edges
  through AST and compiled `AcodeEntry` metadata. No-arg `.push` dispatches the matched child, captures its
  rule return, suppresses child return-event leakage from the shared accumulator, and appends the value to the
  current rule accumulator. `.return(expr)` and `.return_undef` return through the current rule/action channel
  without recursively dispatching the close-edge child.
  **Verification:** focused Rust core `fluent_chain` PASS; focused Rust runtime `terse_2_3_3_1` PASS; full Rust
  core/runtime packages PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS
  (`Files=1, Tests=994`). The `tclite` oracle remains deferred behind compact lifecycle/body fluent forms
  (`I.return(...)`) and default-mode repetition parity, both tracked as follow-on work.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.2`** (Rust attached fluent block payloads for
  `.when(cond) { ... }.otherwise { ... }`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.2 — lifecycle value/drop return-channel lock landed**
  (PHASE0 + RUST RUNTIME + BOOK/KM LOCKS). Lifecycle blocks are now documented and regression-locked as
  statement blocks, not expression-valued blocks. Final ordinary statement values are discarded; top-level
  lifecycle/action `return(expr)` writes the surrounding return channel; expression-valued block
  `return(expr)` remains block-local. Perl phase0 source-locks all seven lifecycle markers and runtime-locks
  the three-way distinction. Rust focused tests lock value discard, top-level lifecycle return-event recording,
  and expression-block local return contrast.
  **Verification:** Perl syntax check PASS; phase0 PASS (`Files=1, Tests=994`); focused Rust runtime
  `terse_2_3_2` PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3`** (Rust fluent block-chain/action-edge parity, coordinated with
  `RUST-PARITY.7.5.3`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.1 — Perl fluent `when/otherwise` block chains landed**
  (PERL BOOTSTRAP + PHASE0 + BOOK/KM LOCKS). Perl now preserves attached fallback tails after fluent
  `.when(cond) { ... }` chains. Both `.otherwise { ... }` and no-dot `otherwise { ... }` continuations execute
  on action-edge and lifecycle surfaces. The new locks use false `when` conditions so fallback execution is
  actually proven, not hidden by a selected first branch.
  **Verification:** Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=993`); mdBook/KM/memory/doctrine/
  diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.2`** (lifecycle block value-drop and explicit `return(expr)` channel
  semantics lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3 — fluent/lifecycle/composability surface split/owned**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). `.2.3` was too broad for one signoff slice. KM +
  TOOLBOX probes show the Perl reference already accepts exact action/lifecycle
  `.when(cond) { ... }.otherwise { ... }` fluent block chains with `ready=1 raw=0 fallback=0 unresolved=0`,
  while Rust still lacks fluent attached-block/action-edge parity. Lifecycle block syntax is present, but final
  expression value dropping versus explicit `return(expr)` rule-channel behavior needs a focused semantic lock.
  Full nested composability and return-type method chaining are also separate surfaces; Round 1 receiver-dot
  array methods remain statement-only.
  **Verification:** KM retrieval; TOOLBOX descriptor/runtime probes; Perl/Rust code-read; mdBook/KM/memory/
  doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.1`** (Perl reference fluent block-chain contract lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.6.2 — Rust attached `while(cond) { ... }` parity landed**
  (RUST PARSER + RUNTIME LOOP + ORACLE/BOOK/KM LOCKS). Rust now parses attached `while(cond) { ... }` as a
  lazy statement loop, re-evaluates the condition before each iteration, executes body statements while true,
  and composes with existing attached `if`/`switch` bodies. The same deterministic safety diagnostic is used
  after 10000 iterations, and expression-valued block bodies keep block-local `return(expr)` semantics.
  Rust also gained the documented numeric comparison helper family needed by the portable counter-loop pattern.
  **Verification:** focused Rust parser `attached_while` PASS; focused Rust runtime `terse_2_2_6_2` PASS;
  full Rust core/runtime package tests PASS; oracle corpus regenerated to **39 fixtures** with
  `terse_2_2_6_2_attached_while_blocks`; Rust corpus oracle PASS; mdBook/KM/memory/doctrine/diff checks PASS;
  full local CI PASS (`Files=1, Tests=992`).
  **Frontier: `SPEC-FORMAT-TERSE.2.3`** (fluent control-flow/lifecycle-block/full composability discovery and split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.6.1 — Perl attached `while(cond) { ... }` loop/safety landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Perl now lowers attached `while(cond) { ... }` through ActionIR
  with no raw fallback or unresolved helper residue. Conditions are evaluated before each iteration; body
  statements run while true; `return(expr)` inside the loop returns from the surrounding rule/action. Each loop
  gets a deterministic local guard (`LinkedSpec while iteration safety limit exceeded after 10000 iterations`)
  so non-terminating loops return control to the parser instead of hanging. Same-line statement separator rules
  remain unchanged: a following ordinary statement still needs `;`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/descriptor/runtime/source probes PASS; phase0
  PASS (`Files=1, Tests=992`); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.6.2`** (Rust attached-while parser/runtime parity).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.6 — attached `while(cond) { ... }` split/owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). KM + TOOLBOX probes show current Perl lowers
  `while(false) { return("bad") }` as raw host code (`ready=0 raw=1 fallback=1 unresolved=0`), while Rust has
  no attached statement-loop parser/runtime. The leaf is split into `.2.2.6.1` for the Perl reference
  loop/safety contract and `.2.2.6.2` for Rust parity. The safety rule is now explicit: non-terminating loops
  must trip a deterministic iteration guard instead of hanging generated parsers.
  **Verification:** KM retrieval; TOOLBOX lowering/descriptor probes; Perl/Rust code-read.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.6.1`** (Perl reference attached `while` loop with iteration safety).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.5.2 — Rust attached `switch/case/default` parity landed**
  (RUST PARSER + RUNTIME STACK + ORACLE/BOOK/KM LOCKS). Rust now parses attached switch blocks:
  `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }` and normalizes them to
  `switch` / `case` / `default` / `endswitch` statement controls. The runtime now gates statement switch
  branches with first-match/default semantics beside the existing if stack, so inactive branch side effects do
  not run. The existing lazy value-form `switch(expr, case(...), default(...))` remains unchanged.
  **Verification:** Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=991`); focused Rust parser
  `attached_switch` PASS; focused Rust runtime `terse_2_2_5_2` PASS; lazy value-form `cond_switch` PASS; Rust
  corpus oracle PASS with **38 fixtures** including `terse_2_2_5_2_attached_switch_blocks`; mdBook/KM/memory/
  doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.6`** (`while(cond) { ... }` statement loop with progress safety).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.5.1 — Perl attached `switch/case/default` separator/source lock landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Compact attached switch bodies now split adjacent branch blocks:
  `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }` lowers through ActionIR with no host-shaped
  `case(...)` / `default { ... }` residue, no raw fallback, and no unresolved helper residue. Runtime locks cover
  first-match, later-case, and default selection. The existing separator contract is unchanged: an ordinary
  same-line statement after the final attached switch still requires `;`.
  **Verification:** Perl syntax checks PASS; TOOLBOX descriptor/lowering/runtime/source probes PASS; phase0 PASS
  (`Files=1, Tests=991`); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.5.2`** (Rust attached-switch parser/runtime parity).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.5 — attached `switch/case/default` split/owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). KM and TOOLBOX probes show the broad attached-switch
  surface needs two implementation leaves: Perl first, Rust second. Perl has partial attached-switch lowering,
  but adjacent `case/default` branch blocks can leave unresolved `case(...) { ... }` residue or host-like
  `default { ... }` labels in generated source. Rust has lazy value-form `switch(...)` runtime tests, but no
  attached `switch/case/default` parser in `CodeBlock::parse`.
  **Verification:** KM retrieval; TOOLBOX descriptor/lowering/runtime probes; Perl/Rust code-read; focused Rust
  value-form switch tests PASS with existing warning baseline; memory/doctrine/diff checks.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.5.1`** (Perl reference attached-switch separator/source lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.4 — `when/otherwise` aliases landed**
  (PERL ACTIONIR + RUST PARSER + ORACLE/KM/BOOK). Attached `when(cond) { ... } otherwise { ... }` now lowers as
  the portable alias form for attached `if(cond) { ... } else { ... }`. Perl recognizes the aliases in the
  statement splitter, scanner/contract patterns, and `ControlFlow`, so generated handlers avoid host Perl
  `when`. Rust normalizes the attached aliases in `CodeBlock::parse` to existing `if`/`else`/`endif` statements
  and reuses `handle_statement_if_control`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/descriptor/runtime/source probe PASS; focused
  Rust core `when_otherwise` PASS; focused Rust runtime `terse_2_2_4` PASS; Rust oracle corpus PASS; oracle
  corpus regenerated to **37 fixtures**; phase0 PASS (`Files=1, Tests=991`); mdBook/KM/memory/doctrine/diff
  checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.5`** (attached-block `switch/case/default` parity and separator lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.4 — `when/otherwise` owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). TOOLBOX probes show current `when/otherwise` is not DSL
  control flow: the combined attached form stays raw, descriptor metadata is `ready=0 raw=1 unresolved=2`,
  generated handlers emit Perl's experimental-`when` warning, and the runtime probe returns the `otherwise`
  branch for `when(true)`. The leaf is now scoped as alias normalization over the landed attached-if model:
  `when(cond) { ... }` maps to attached `if(cond) { ... }`, and `otherwise { ... }` maps to attached
  `else { ... }`. Rust should normalize in `CodeBlock::parse` and reuse the existing marker runtime.
  **Verification:** KM retrieval; TOOLBOX lowering/descriptor/runtime/generated-source probes; Perl/Rust
  code-read.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.4`** (implementation of `when/otherwise` aliases).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.3 — Rust attached-block if landed**
  (RUST PARSER + RUNTIME LOCKS + ORACLE/KM/BOOK). Rust now accepts portable attached-block `if/elseif/else`
  chains: `if(cond) { ... } elseif(cond2) { ... } else { ... }`. `CodeBlock::parse` normalizes attached
  branch bodies into the existing marker-control sequence with an implicit `endif`, and the runtime reuses
  `Engine::handle_statement_if_control` instead of adding a second branch engine. Marker-form and
  inline-composite `if` behavior remain unchanged, and a same-line statement after the final attached branch
  still requires `;`.
  **Verification:** focused Rust core parser `attached_if` PASS; focused Rust runtime `terse_2_2_3` PASS;
  oracle corpus regenerated to **36 fixtures** and corpus oracle PASS; mdBook/KM/live docs updated.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.4`** (`when/otherwise` conditional aliases; own before code).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.3 — Rust attached-block if owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). Rust parity for the Perl `.2.2.2` attached-if contract is
  now scoped. `CodeBlock::parse` lacks attached branch parsing, while runtime already has marker-form branch
  gating through `handle_statement_if_control`. The implementation should parse attached branch bodies into the
  existing statement-control model and preserve inline-composite `if` plus marker-form `if(...); ... endif()`.
  **Verification:** Rust code-read; focused Rust parser smoke PASS (`parse_lifecycle_block_content`, known
  nested `rgx` warning noise); Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.3`** (implementation of Rust attached-block `if/elseif/else` parity).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.2 — Perl attached-block if landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Compact attached-block `if/elseif/else` now works on the Perl
  reference without explicit `endif`: `if(cond) { ... } elseif(cond2) { ... } else { ... }` splits into branch
  statements, lowers without raw fallback, and executes only the selected branch. Marker-form and
  inline-composite `if` behavior remains unchanged. The mdBook documents this as Perl-reference support, not
  yet the portable cross-backend contract.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/metadata/runtime probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.3`** (Rust parity for attached-block `if/elseif/else`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.2 — Perl attached-block if owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). TOOLBOX probes narrowed the Perl implementation boundary:
  newline-separated attached branches already lower through ActionIR, but compact same-line chains such as
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` still fall back to raw Perl. Code-read points the
  implementation at `StatementSplit::Core`; scanner/lowering/rewrite support for individual attached branch
  statements already exists.
  **Verification:** TOOLBOX lowering/metadata probes; Perl code-read; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.2`** (implementation of the same-line attached-branch split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.1 — control-flow keyword surface split**
  (DOCS/TREE/KM/BOOK ALIGNMENT; **no engine behavior change**). Round 2 control flow is now decomposed into
  signoff-sized leaves. Current portable support is statement-marker `if(cond); ... elseif(cond); else();
  ... endif()` plus inline-composite lazy `if`/`switch`. Attached-block `if`, `when`/`otherwise`,
  statement-level `switch` blocks, and `while` remain separate implementation work. The mdBook now calls out
  this boundary instead of presenting attached-block control flow as fully portable.
  **Verification:** TOOLBOX lowering/runtime/metadata probes; Perl/Rust code-read; focused Rust parser check
  PASS; mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.2`** (Perl reference attached-block `if/elseif/else`; own before code).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.1.4 — expression-valued block early return landed**
  (PERL ACTIONIR + RUST RUNTIME + ORACLE/KM/BOOK LOCKS). Expression-valued blocks now support block-local
  early `return(expr)` on both variants. `return({ return("a"); "b" })` yields `"a"`; assignment-source block
  values skip later statements after the return payload; nested block values preserve hash-literal payloads.
  `{}` and `{ key => value }` still remain hash shape literals, and the block-local return does not leak into
  the surrounding rule return channel.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime probes PASS; focused Rust `.2.1.4`
  runtime locks PASS; oracle corpus regenerated to **35 fixtures** and corpus oracle PASS; phase0 PASS
  (`t/phase0_regression.t`, **991 tests**); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2`** (Round 2 control-flow keyword surface; own before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity landed**
  (RUST PARSER/RUNTIME + ORACLE/KM/BOOK LOCKS). Rust now matches the Perl-reference core block-value subset:
  non-empty brace payloads without a top-level `=>` parse as `Expr::BlockValue`, `{}` and `{ key => value }`
  remain hash literals, side-effect statements run in order, and the final expression or final `return(expr)`
  yields the block value. True mid-block early return remains `.2.1.4`; Rust rejects non-final `return(expr)`
  inside block values instead of leaking a rule return.
  **Verification:** focused Rust core parser locks PASS; focused Rust runtime `.2.1.3` locks PASS; oracle
  corpus regenerated to **34 fixtures** and corpus oracle PASS; full Rust core package PASS; full Rust runtime
  package PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS (`tools/run_ci_local.sh`,
  phase0 **991** tests).
  **Frontier: `SPEC-FORMAT-TERSE.2.1.4`** (true block-local early-return follow-through, if still needed).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity owned before code**
  (DOCS/TREE/KM ONLY; **no Rust engine, oracle, fixture, mdBook behavior, or Perl behavior change**). Rust
  parity is now scoped to the accepted Perl-reference core: non-empty brace payloads without a top-level `=>`
  should become block-value expressions, while `{}` and `{ key => value }` remain hash literals. Code-read
  identified the implementation seams as `Expr`/brace parsing in `rust/linkedspec-core/src/expr.rs` and a
  value-returning block evaluator in `rust/linkedspec-runtime/src/engine.rs`; true mid-block early return stays
  `.2.1.4`.
  **Verification:** Rust code-read; mdBook build PASS; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.1.3`** (implementation of Rust parser/runtime parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.2 — Perl-reference core expression-valued blocks landed**
  (PERL ACTIONIR + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). The Perl reference now accepts non-empty brace
  payloads without a top-level `=>` as value blocks in value-consuming sites. Blocks evaluate their statements
  and return the final expression; a final `return(expr)` is treated as block-local for this core subset. `{}` and
  `{ key => value }` remain hash shape literals, and nested final hash literals are preserved as hashrefs.
  Full block-local early return remains split to `.2.1.4`; Rust parity remains `.2.1.3`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.1.3`** (Rust parity for core expression-valued blocks).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.1 — expression-valued block split completed**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM retrieval, TOOLBOX probes, and
  code-read showed expression-valued blocks cross too many seams for one implementation leaf. `{}` and
  `{ key => value }` remain hash shape literals. Non-empty brace payloads without a top-level `=>` currently
  fail as value blocks: Perl emits invalid generated Perl for forms like `return({ set(x,"a"); x })`, and Rust
  has no block-expression AST/runtime path. The split children are `.2.1.2` Perl reference core,
  `.2.1.3` Rust parity, and `.2.1.4` full block-local explicit-return follow-through if needed.
  **Verification:** KM retrieval; TOOLBOX lowering/runtime/source probes; Perl/Rust code-read; KM/memory/doctrine/diff checks.
  **Frontier: `SPEC-FORMAT-TERSE.2.1.2`** (Perl reference core expression-valued blocks; owned before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.6 — array end-mutation methods landed**
  (PERL ACTIONIR + RUST RUNTIME + ORACLE/KM/BOOK LOCKS). Statement-level receiver-dot methods now mutate named
  working arrays on both variants: `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`,
  and `items.pop_front()`. Receivers may be bare or explicit `array(items)` / `a(items)`; push values use the
  settled mutation-slot value rules, so bare push values read scalar working variables; pop methods discard the
  removed value. Perl reports canonical `ARRAY_MUTATE` with zero fallback and auto-supplies one `my @items`
  plus push-value scalar declarations as needed. Rust executes the same statement forms in
  `Engine::execute_block`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; focused Rust
  parser/runtime `.1.6` locks PASS; oracle corpus regenerated to **33 fixtures** and corpus oracle PASS;
  phase0 PASS (`t/phase0_regression.t`, **990 tests**).
  **Frontier: `SPEC-FORMAT-TERSE.2.1`** (Round 2 expression-valued blocks; ground-truth/split before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.4 — Rust RHS shape target-kind inference parity landed**
  (RUST RUNTIME + ORACLE/KM). Rust now matches the Perl target-kind rule accepted in `.1.2.3.5.2`: direct RHS
  shape literals infer aggregate working-variable targets when the assignment target is bare or explicitly
  aggregate-typed. `items = [value]`, `set(items, [])`, and `set(array(items), [value])` replace the runtime
  array working variable; `meta = { key => value }`, `assign(meta, {})`, and `set(hash(meta), { key => value })`
  replace the runtime hash working variable. Explicit scalar targets remain scalar payload assignments:
  `set(scalar(payload), [value])` stores the array payload in scalar `payload`.
  **Verification:** focused Rust runtime `.1.2.3.5.4` locks PASS; oracle corpus regenerated to **32 fixtures**
  and corpus oracle PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.6`** (own before code: array end-mutation methods).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.3 — Rust shape-literal value parity landed**
  (RUST AST/PARSER + RUNTIME + ORACLE). Rust now accepts direct `[]` / `{}` shape literals as value
  expressions in the same accepted value slots as Perl `.1.2.3.5.1`: return payloads, scalar assignment
  sources, array append RHS values, hash-index assignment RHS values, and nested payloads. Shape members reuse
  normal Rust expression evaluation, so `[value, cat("a","b"), true, []]` and
  `{ key => value, "fixed" => [value] }` preserve typed nested payloads and scalar bare reads. Rust target-kind
  inference is intentionally still deferred: `name = [value]` remains a scalar-held array payload until
  `.1.2.3.5.4`.
  **Verification:** focused Rust parser locks PASS; focused Rust runtime `.1.2.3.5.3` locks PASS; oracle corpus
  regenerated to **30 fixtures** and corpus oracle PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.4`** (Rust RHS target-kind inference parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.2 — Perl RHS shape target-kind inference landed**
  (PERL ACTIONIR + DECLARE INIT + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). Direct RHS shape literals now infer the
  aggregate kind of a bare assignment target on the Perl reference: `items = [value]` / `set(items, [])` assign
  array working variable `@items`, and `meta = { key => value }` / `assign(meta, {})` assign hash working
  variable `%meta`. Non-shape RHS values remain scalar assignment, and explicit `scalar(name)` targets keep
  scalar-held payload behavior (`set(scalar(payload), [value])` -> `$payload = [$value]`). Typed array/hash
  declaration initializers now unwrap lowered direct shapes, so `declare(array, items=[value, cat("a","b")])`
  and `declare(hash, meta={ key => value, "fixed" => [value] })` compose with scalar bare reads and helper
  values.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **989 tests**); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.3`** (Rust shape-literal value parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.1 — Perl shape-literal value expressions landed**
  (PERL ACTIONIR + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). Direct `[]` / `{}` shapes are now DSL value
  expressions on the Perl reference instead of raw Perl passthrough. Empty shapes still lower as `[]` / `{}`;
  non-empty shapes lower their elements, keys, and values through the accepted value-expression rules, so
  `[value]` and `{ key => value }` read scalar working variables and auto-supply `my $value` / `my $key` when
  needed. Fixed hash field names must be quoted (`{ "kind" => value }`). Target-kind inference is unchanged:
  `name = [value]` still assigns scalar `name` to an array payload and does not infer `@name`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **988 tests**); mdBook updated.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.2`** (Perl RHS target-kind inference).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5 — RHS-shape/type-inference split completed**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM + TOOLBOX/source/runtime/code-read
  probes showed the remaining Channel 2 shape work is too broad for one implementation leaf. Perl already
  accepted empty `[]`/`{}` as raw scalar value expressions at split time, but `name = []` / `name = {}` assign
  scalar `$name` / `$meta`-style slots rather than initializing aggregate working variables. Non-empty shapes such as
  `[value]` and `{ key => value }` passed through raw Perl at split time, so bare identifiers became
  barewords/strings rather than the settled scalar working-variable reads before `.1.2.3.5.1`. Rust currently
  has no bracket/brace value-expression parser. The split children are `.1.2.3.5.1` Perl shape-literal values,
  `.1.2.3.5.2` Perl RHS target-kind inference, `.1.2.3.5.3` Rust shape-literal parity, and `.1.2.3.5.4`
  Rust target-inference parity.
  **Verification:** KM/TOOLBOX/source/runtime/code-read probes completed; KM/memory/doctrine/diff checks run for
  the slice.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.1`** (Perl shape-literal value expressions).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.4 — Rust scalar bare-read parity landed**
  (RUST PARSER + RUNTIME LOCKS + ORACLE/KM). Rust now accepts the scalar bare-read contract already landed on
  the Perl reference: `return(value)`, `set(out, value)`, `name = value`, `items += value`,
  `set_key(meta, key, value)`, `meta[key] = value`, and direct-access path indexes such as `foo["a"][idx]`
  all evaluate bare identifiers through the existing scalar working-variable read path. The runtime already
  evaluated `Expr::Variable` as `ctx.get_scalar(name)`; this slice removed obsolete parser reservations and
  added parser/runtime/oracle locks. RHS-shape `[]`/`{}` inference and expression-valued blocks remain later,
  all-bare `push(A,B)` remains child-call syntax, and the remaining Channel 2 shape work is now tracked as
  `SPEC-FORMAT-TERSE.1.2.3.5`.
  **Verification:** focused Rust parser tests PASS; focused Rust runtime `.1.2.3.4` tests PASS; oracle corpus
  regenerated to **28 fixtures** and corpus oracle PASS; mdBook build PASS; KM/memory/doctrine/diff checks
  PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5`** (RHS-shape/type-inference split before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3.3 — Perl direct-access bare path atoms landed**
  (PERL ACTIONIR + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). Non-reserved bare atoms inside direct-access bracket
  paths now read scalar working variables as array indexes: `foo["a"][z]` lowers/runs like
  `foo["a"][scalar(z)]` (`$foo->{"a"}->[$z]`) and auto-supplies one per-invocation `my $z` when needed.
  Quoted path segments remain hash keys, numeric/helper segments remain array indexes, primitive literals and
  engine locals are not claimed, `scalaref(...)` keeps its historical path semantics, RHS-shape inference is
  still later, and all-bare `push(A,B)` remains child-call syntax.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; phase0 PASS (`1..987`);
  mdBook build PASS; KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.4`** (Rust scalar bare-read parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3.2 — Perl scalar mutation-slot bare reads landed**
  (PERL ACTIONIR + SCANNER + PHASE0 + BOOK/KM LOCKS). `items += VALUE`,
  `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` now read non-reserved bare key/RHS identifiers as scalar
  working variables and auto-supply one per-invocation `my $NAME` when needed. Target inference is unchanged
  (`@items` / `%meta`), primitive literals stay exact, reserved engine locals are not claimed, direct path atoms
  remain deferred, and all-bare `push(A,B)` remains child-call syntax.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; phase0 PASS (`1..986`);
  mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3.3`** (Perl direct-access bare path atoms).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3.1 — Perl scalar source-slot bare reads landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and
  scalar operator `out = NAME` now read scalar working variable `NAME` and auto-supply one per-invocation
  `my $NAME` when needed. Primitive literals remain exact (`true`/`false`/`undef`), while prefix identifiers
  such as `trueword` are scalar identifiers in these source slots. This does **not** advance array append RHS,
  hash mutation key/RHS slots, direct path atoms, generic helper arguments, or all-bare child-call `push(A,B)`.
  **Verification:** Perl syntax checks PASS; TOOLBOX/source/runtime probes PASS; phase0 PASS (`1..985`);
  mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3.2`** (Perl mutation key/RHS scalar slots).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3 — Perl scalar bare reads split by lowering seam**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). TOOLBOX probes showed the remaining
  scalar Channel 2 work is not one implementation seam. Return/assignment source slots still emit raw barewords
  (`return(count)`, `set(out,count)`, `name = value`); named hash mutation already lowers a bare key through
  `$key` but not a bare value; array append and hash-index operator forms reject bare RHS/key tokens before
  lowering; direct `foo["a"][z]` remains raw while explicit `[scalar(z)]` works. `.1.2.3.3` is now a container:
  `.1.2.3.3.1` return/assignment source slots, `.1.2.3.3.2` mutation key/RHS slots, and `.1.2.3.3.3`
  direct-access bare path atoms. **Verification:** TOOLBOX lowering probes PASS; KM/memory/doctrine/diff checks
  green.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3.1`** (Perl scalar source-slot bare reads).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.2 — Rust aggregate bare value-read parity landed**
  (RUST ENGINE + ORACLE + INTEGRATION LOCKS; **no mdBook prose change needed because `.1.2.3.1` already taught
  the variant-neutral contract**). Rust aggregate snapshot helpers now resolve bare working-variable reads like
  the Perl reference: `array_copy(items)` and array-first `copy(items)` read array `items`, while
  `hash_copy(meta)` reads hash `meta`; `copy(hash(meta))` remains the explicit hash-copy spelling. The change is
  scoped to aggregate resolver call sites and does **not** advance scalar bare reads, bare hash-index key/RHS
  forms, or bare direct-access path atoms. **Verification:** focused Rust `.1.2.3.2` tests PASS; focused Rust
  bare direct-access rejection PASS; oracle corpus regenerated to **25 fixtures** and corpus oracle PASS; full
  Rust runtime suite PASS (116 unit tests, 25 oracle fixtures, 54 integration tests); clippy EXIT 0 with the
  existing warning baseline; phase0/mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3`** (Perl scalar bare value reads).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.1 — Perl aggregate bare value-read auto-existence landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Aggregate bare reads that already lower to sigiled Perl aggregates
  now get safe per-invocation declarations: `array_copy(items)` and array-first `copy(items)` auto-supply
  `my @items`, while `hash_copy(meta)` auto-supplies `my %meta`. Wrapped/declared paths dedup unchanged; reserved
  literals such as `undef` are still skipped. Same-parser array/hash reruns prove the targets do not leak across
  parses. This does **not** advance scalar bare reads (`return(count)`), bare RHS/key forms, or bare direct-access
  atoms. **Verification:** Perl syntax checks PASS; focused generated-source/runtime/no-leak probe PASS; phase0
  PASS (`1..984`); mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.2`** (Rust parity for aggregate bare value reads).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3 — Channel 2 value reads split by aggregate/scalar surfaces**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM + TOOLBOX/code-read ground truth
  showed Channel 2 is not one implementation seam. Perl aggregate bare value reads already lower
  (`array_copy(items)` -> `[@items]`, `hash_copy(meta)` -> `{%meta}`, `copy(items)` -> `[@items]`) but do not
  get safe preamble declarations, so they still risk non-strict package globals. Rust keeps bare aggregate
  value reads out of aggregate-copy resolvers. Scalar-like value reads remain separate: Perl still emits
  bareword/raw forms for `return(count)`, `set(out,count)`, `items += value`, `meta[key] = value`, and
  `foo["a"][z]`, while Rust already evaluates plain variables as scalar reads. **Verification:** TOOLBOX
  lowering/source probes PASS; KM/memory/doctrine/diff checks green.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.1`** (Perl aggregate bare value-read auto-existence).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.5.2 — bare direct-access coordination merged into Channel 2**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM retrieval plus TOOLBOX reverify
  showed the post-`.1.5.5.1` boundary is unchanged: `foo["a"][9]["b"][scalar(z)]` lowers through the canonical
  dereference path, but `foo["a"][9]["b"][z]` remains raw and `return(z)` remains a bareword. Rust keeps the
  parser rejection lock for bare direct-access segments. Therefore the full brainstorm spelling cannot be
  implemented as a direct-access-local rule without pre-empting global Channel 2 semantics. `.1.5.5.2` is
  superseded/merged into new `.1.2.3`, which owns value-position bare-word reads, bare RHS/key expressions,
  bare direct-access path atoms, and RHS-shape/type inference. **Verification:** TOOLBOX reverify PASS; focused
  Rust parser rejection lock PASS; KM/memory/doctrine/diff checks green.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3`** (Channel 2 design/split).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.5.1 — direct nested access with explicit segments landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + ORACLE + BOOK/KM LOCKS). Direct mixed access such as
  `foo["a"][9]["b"][scalar(z)]` now works on both variants. Perl lowers it to
  `$foo->{"a"}->[9]->{"b"}->[$z]`, matching the existing explicit `scalaref(...)` path; Rust parses it as
  `NestedAccess` and walks the scalar-held base payload through hash-key and array-index segments. Quoted
  string segments are hash keys; numeric/helper segments are array indexes. Bare path atoms such as `[z]`
  remain deferred to `.1.5.5.2` / Channel 2, and `scalaref(base,path)` remains accepted. **Verification:**
  phase0 PASS, Rust focused parser/runtime tests PASS, Rust corpus oracle PASS over 21 fixtures, full Rust
  runtime PASS, mdBook/KM/memory/doctrine/local gates green.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.5.2`** (bare path-segment / Channel 2 coordination).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.5 — direct nested access split by Channel 2 boundary**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). Split-time KM + TOOLBOX probes showed
  direct `foo["a"][9]["b"][scalar(z)]` was not yet a valid lowered value expression: it passed through as
  `foo["a"][9]["b"][$z]` and generated handler compilation failed near `][`. The existing
  `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` path remains the working explicit syntax and lowers to
  `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare segment `z` remains Channel 2 value-position-read work. `.1.5.5` is
  now a container: `.1.5.5.1` explicit path segments first, `.1.5.5.2` bare-segment/Channel-2 coordination.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.5.1`** (direct nested access with explicit path segments).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.4 — statement separator contract landed**
  (PERL ACTIONIR + BOOTSTRAP NORMALIZATION + RUST PARSER/RUNTIME + ORACLE + BOOK/KM LOCKS). Newlines now
  separate top-level canonical DSL statements, and semicolons remain accepted and required for multiple
  statements on one physical line. Perl lowering emits valid generated Perl for newline-separated statements
  such as `set(name,"a")` followed by `return(scalar(name))`; same-line adjacent helpers without `;` stay
  explicit non-canonical blockers, matching Rust parser rejection. Nested semicolons inside expression payloads
  remain protected. Bootstrap normalizes captured fluent attached-control tails with internal newlines so
  `Top.if(...) { ... } elseif(...) { ... } else { ... }` remains supported without weakening the same-line
  rule. **Verification:** phase0 PASS (`1..982`), oracle corpus regenerated with 20 fixtures, focused Rust
  parser/runtime `.1.5.4` tests PASS, Rust corpus oracle PASS over 20 fixtures, full Rust runtime PASS,
  mdBook/KM/memory/doctrine/local gates green.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.5`** (direct nested access surface).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.3 — call spacing and mandatory-call-parentheses locks landed**
  (PERL PHASE0 + RUST PARSER/RUNTIME + ORACLE + BOOK/KM LOCKS). Helper calls keep the uniform
  `callee(args)` shape, while optional whitespace before the opening parenthesis is accepted at supported
  statement and value-expression sites: `return (value)`, `set (name, value)`, nested `cat ("a","b")` /
  `scalar (name)`, array-append RHS calls, and hash-index key/RHS calls. No-parenthesis helper spellings
  remain out of scope: `set name,"v"`, `return scalar name`, and `return(cat "a","b")` are not claimed as
  helper calls. **Verification:** phase0 PASS (`1..981`), oracle corpus regenerated with 19 fixtures, focused
  Rust parser/runtime `.1.5.3` tests PASS, Rust corpus oracle PASS over 19 fixtures, mdBook/KM/memory/doctrine
  gates green. **Frontier: `SPEC-FORMAT-TERSE.1.5.4`** (statement separator contract).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.2 — primitive literal parity landed**
  (PERL ACTIONIR + RUST RUNTIME FLOW + BOOK + PHASE0/RUST/ORACLE LOCKS). Primitive literals are now typed
  value expressions across return payloads, assignments, appends, hash-index keys/values, and flow predicates:
  quoted strings stay strings, numbers stay numeric, `undef` becomes null, and `true`/`false` become JSON
  booleans. Perl lowers booleans through `JSON::PP`, with exact matching so `trueword`/`undefine` remain
  identifiers; scanner/legacy disambiguation now treats `push(items,false)` as a value append while preserving
  all-bare child-call behavior for non-literal identifiers. Rust gained statement-form `if/elseif/else/endif`
  gating so `if(false)` skips the then branch; value-form `if(cond,then,else)` is unchanged. **Verification:**
  phase0 PASS (`1..980`), oracle corpus regenerated with 18 fixtures, focused Rust `.1.5.2` tests PASS, Rust
  corpus oracle PASS over 18 fixtures, mdBook/KM/memory/doctrine/local gates green. **Frontier:
  `SPEC-FORMAT-TERSE.1.5.3`** (function-call spacing and mandatory-parentheses locks).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5 — literal/nested-access/call/semicolon surface split before code**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). PNT selected `.1.5` and ran KM +
  TOOLBOX/code-read first. Ground truth: Perl strings/numbers/`undef` already run, but `true`/`false` return
  strings while Rust has typed booleans; optional whitespace before `(` works at supported helper/value sites;
  newline-separated adjacent lowered statements still fail on Perl without `;`, while Rust accepts broader
  whitespace-separated statements; direct `foo["a"][9]['b'][z]` is not lowered on Perl and Rust only has
  single array-index access. `.1.5` is now an active container: `.1.5.1` audit/split done, `.1.5.2` primitive
  literal parity, `.1.5.3` call-spacing locks, `.1.5.4` separator semantics, `.1.5.5` direct nested access.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.2`**.
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4.3 — hash-index assignment operator `name[key] = value` landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + BOOK + PHASE0/RUST/ORACLE LOCKS). Top-level `NAME[KEY] = VALUE`
  now lowers/runs identically to the settled named-hash mutation form `set_key(NAME, KEY, VALUE)` when the key
  and value are explicit expressions. Perl recognizes it through an ASSIGN contract/scanner/lowering path and
  auto-supplies one `my %NAME` preamble for a bare hash target; Rust parses it as statement-only
  `AssignHashIndex`, evaluates the key to a string, and mutates the per-parse hash map. Boundaries remain
  explicit: `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and
  `meta[scalar(key)] = scalar(value)` work, while bare key/RHS forms such as `meta[key] = "v"` and
  `meta["stage"] = value` stay deferred to Channel 2. **Verification:** TOOLBOX parity probes; phase0 PASS
  (`1..979`); oracle corpus regenerated with 16 fixtures; focused Rust core/runtime tests PASS; Rust corpus
  oracle PASS; mdBook + KM + memory/doctrine + local CI gates green. **Frontier:
  `SPEC-FORMAT-TERSE.1.5`** (literal/nested-access/call/semicolon surface; scope/split first).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4.2 — array append operator `items += value` landed** (PERL
  ACTIONIR + RUST PARSER/RUNTIME + BOOK + PHASE0/RUST/ORACLE LOCKS). Top-level `NAME += RHS` now lowers/runs
  identically to the settled explicit append forms for explicit RHS expressions. Perl recognizes it through a
  PUSH contract/scanner/lowering path and auto-supplies one `my @NAME` preamble for a bare array target; Rust
  parses it as statement-only `AssignArrayAppend`, evaluates the RHS, and appends through the per-parse array
  map. Boundaries remain explicit: `items += scalar(value)` works, while bare `items += value` stays deferred
  to Channel 2; child-call `push(A,B)`, increment-like `items ++`, scalar assignment, and hash-index
  assignment are not conflated. **Verification:** TOOLBOX parity probes; descriptor/source/runtime probes
  (`PUSH,RETURN`, fallback 0, one array declaration); phase0 PASS (`1..978`); oracle corpus regenerated with
  15 fixtures; focused Rust core/runtime tests PASS; Rust corpus oracle PASS; mdBook + KM + memory/doctrine +
  local CI gates green. **Frontier: `SPEC-FORMAT-TERSE.1.3.4.3`** (hash-index assignment operator).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4.1 — scalar assignment operator `name = value` landed** (PERL
  ACTIONIR + RUST PARSER/RUNTIME + BOOK + PHASE0/RUST/ORACLE LOCKS). Top-level `NAME = RHS` now lowers/runs
  identically to `set(NAME,RHS)` / `assign(NAME,RHS)`. Perl recognizes it through an ASSIGN
  contract/scanner/lowering path and auto-supplies one `my $NAME` preamble for a bare scalar target; Rust parses
  it as statement-only `AssignScalar`, executes it with `RuntimeContext::set_scalar`, and rejects nested
  assignment expressions. Boundaries remain explicit: equality, array append, hash-index assignment, helper
  keyword args, nested assignment expressions, and Channel 2 bare value-position reads are still separate
  pending work. **Verification:** TOOLBOX parity probes; descriptor/source/runtime probes (`ASSIGN,RETURN`,
  fallback 0, one scalar declaration); phase0 PASS (`1..977`); oracle corpus regenerated with 14 fixtures;
  focused Rust core/runtime tests PASS; full Rust runtime suite PASS (116 unit + corpus-oracle harness + 41
  integration tests); mdBook + KM + memory/doctrine + local CI gates green. **Frontier:
  `SPEC-FORMAT-TERSE.1.3.4.2`** (array append operator).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4 — operator syntax family split into scalar, array, and hash leaves**
  (DOCS/TREE/KM ONLY; **no engine, test, fixture, or mdBook behavior change**). PNT selected the next frontier
  after `.1.3.3` and ran the required KM + TOOLBOX recon before code. Ground truth: `name = "ok"`,
  `items += "a"`, and `name["k"] = "v"` still pass through unchanged as RAW_PERL blockers on Perl; the settled
  function forms `set(...)`, `push(...)` for unambiguous value expressions, and `set_key(...)` lower correctly.
  A descriptor probe over all three operator forms reports three `RAW_PERL` fallback events and three
  language-agnostic blocker statements. Rust code-read shows lifecycle code is expression-statement-only
  (`Stmt { expr }`) and has no assignment/append/hash-set statement variants. `.1.3.4` is now a container:
  `.1.3.4.1` scalar `name = value`, `.1.3.4.2` array `items += value`, `.1.3.4.3` hash `name[key] = value`.
  **Frontier: `SPEC-FORMAT-TERSE.1.3.4.1`** (scalar assignment operator).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.3 — hash function mutation `set_key(name,key,value)` landed while
  preserving pure `set_key(hash_expr,key,value)`** (PERL ACTIONIR + RUST ENGINE + BOOK + PHASE0/RUST/ORACLE
  LOCKS). Top-level `set_key(name,key,value)` is now a statement-level named-hash mutation: Perl lowers it to
  direct `$name{key} = value` assignment and auto-supplies one preamble `my %name` for a bare target; Rust
  handles top-level `set_key(...)` before generic expression evaluation and mutates the named runtime hash.
  Nested/value-form `set_key(hash(meta), key, value)` remains a pure copy helper and is locked not to mutate the
  source hash. Added the `set_key_statement` ASSIGN contract/scanner/lowering path, EmitContext bare-hash
  collector coverage, Rust `execute_set_key_statement`, +1 phase0 subtest, 2 Rust integration tests, oracle
  fixture `terse_1_3_3_set_key_statement_hash`, book updates, and KM updates. **Verification:** TOOLBOX
  lowerings distinguish mutation vs pure value form; descriptor/source/runtime probes show ASSIGN recognition,
  one `my %meta`, same-parser stability, and non-mutating nested pure behavior; phase0 PASS (976); focused Rust
  `terse_1_3_3` PASS; corpus oracle PASS over 13 fixtures; mdBook build EXIT 0; Knowledge Map +
  memory-architecture + doctrine checks OK; full local gate EXIT 0. **Frontier:
  `SPEC-FORMAT-TERSE.1.3.4`** (operator syntax family).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.2 — array function spelling `push(target,value)` landed while preserving
  child-call `push(...)`** (PERL ACTIONIR + BOOK + PHASE0 LOCKS + RUST ORACLE/INTEGRATION LOCKS; **no Rust
  engine change**). Selected conservative disambiguation: `push(target,value)` lowers/runs like
  `push_value(target,value)` only for unambiguous/non-all-bare value expressions (`"literal"`,
  `scalar(value)`, helper values such as `cat(...)`, or `call(Child)`). All-bare `push(A,B)` keeps the
  child-call meaning (`A` rule into `B` accumulator); appending a working-variable value remains
  `push(items, scalar(value))` or `push_value(items, scalar(value))` until Channel 2 bare value-position reads land.
  Perl recognition now accepts the alias in the `push_value` contract/scanner/lowering path, and the auto-array
  collector uses a balanced parser-backed scan so nested comma values such as `cat("a","b")` declare exactly
  one `my @items`. Rust already accepted `"push_value" | "push"`; this slice locks it with a Perl-oracle fixture
  and integration test. **Verification:** TOOLBOX lowerings prove explicit append vs child-call precedence;
  descriptor/runtime probe returns `["a","b"]` with zero fallback/unresolved; source dump for nested/comma value
  has one `my @items`; phase0 PASS (975); focused Rust test PASS; corpus oracle PASS over 12 fixtures; mdBook
  build EXIT 0; Knowledge Map + memory-architecture checks OK; full local gate EXIT 0. **Frontier:
  `SPEC-FORMAT-TERSE.1.3.3`** (hash function mutation semantics).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3 — split mutation surface by mechanism; record push/operator ground truth** (DOCS/TREE/KM only; **no engine, test, fixture, or mdBook behavior change**). TOOLBOX-first probes showed `.1.3` is too broad for one signoff implementation slice: `set(name, "ok")` is already satisfied by `.1.4.1`/`.1.4.2` (`set` lowers/runs like `assign`); `push_value(items, "a")` worked while requested `push(items, "a")` still needed a child-call-preserving disambiguation; `set_key(name, "k", "v")` is currently a pure hash-valued expression, not a standalone mutation statement across variants; and operator forms (`name = v`, `items += v`, `name["k"] = v`) are raw/invalid Perl today while Rust has no assignment/plus-equals statement AST. Split `.1.3` into `.1.3.1` scalar function-form audit (DONE by `.1.4` evidence), `.1.3.2` array function spelling, `.1.3.3` hash mutation semantics, and `.1.3.4` operator syntax. Added KM card [[terse-mutation-surface-ground-truth]] and regenerated the map. `.1.3.2` is now done in the slice above.
- 2026-06-29: **SPEC-FORMAT-TERSE.1.4.2 — Rust lockstep parity for terse helper renames** (RUST ENGINE + 2 oracle fixtures + 3 integration locks; **no book change, Perl untouched**). Closed the `.1.4` helper-rename container on the Rust variant (ADR 0006). `Engine::call_helper()` now recognizes `set` through the `assign` arm and `cat` through the `concat` arm, and adds a dedicated unified `copy` arm that clones materialized arrays/hashes or resolves wrapped array/hash targets by kind. Added `resolve_hash_target` plus one-bare-variable `hash`/`h` target reads so `copy(h(m))` matches `hash_copy(h(m))`; deferred Channel 2 bare value-position reads remain out of scope. **Locked:** Perl-oracle fixtures `terse_1_4_2_set_cat_copy_array` and `terse_1_4_2_copy_hash_symbol_empty`; Rust integration tests for `set`+`cat`+`copy(array)`, hash target/hash value copy, and per-parse bare `set` target semantics. **Verification:** generator syntax OK; oracle regeneration OK; focused `terse_1_4_2` tests PASS; corpus oracle PASS over 11 fixtures; full Rust runtime suite PASS (116 unit + 36 integration + oracle harness); `cargo clippy` EXIT 0 with existing 13-warning baseline only; phase0 **975 green** (Perl untouched); `bash tools/run_ci_local.sh` EXIT 0. `.1.4.1` is now landed against the universal contract on both variants; **`.1.4` container done. Next: `SPEC-FORMAT-TERSE.1.3`** (mutation surface — scope/split before code).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.4.1 — Perl reference: terse renames `set`/`cat`/`copy` lower byte-identically to `assign`/`concat`/`array_copy`+`hash_copy`** (ENGINE: 8 modules + BOOK: 3 pages + 4 phase0 locks). First `.1.4` child, in the user-directed PNT loop. **TOOLBOX-first** `call_spec_handler_subst` ground truth (dump-don't-guess; `perl -Iperl`→`perl/LinkedSpec.pm`) re-verified the gap, then recognized the aliases at **every** site each canonical name is recognized (the headline probe passing was a false "done" — composed positions like `set(x, cat(a,b))` / `assign(x, copy(a(y)))` still emitted raw un-lowered helpers until every recognizer learned the alias): (i) `cat`→`concat`+`set`→`assign` in `_normalize_method_name` (`ActionIR/MethodExpr.pm`); (ii) `set` raw-text statement recognition extended `\b(?:assign|set)\s*\(` at the `assign_value` contract (`Contracts.pm`), its IR-event scanner (`Scanner/PrimitivePipelineRules.pm` — so `set`==`assign` ASSIGN node), and the bare-arg auto-`my` collector (`RuleIR/EmitContext.pm` — bare `set` auto-exists, `.1.2.1` parity); (iii) a dedicated array-then-hash `copy` dispatch in `MethodLowering._lower_method_value_expr` + `copy` at `DeclareMethod` 136/163, the return-payload guard+rewriter lists (`MethodLowering` 1650/1658), `FlowExpr.pm:270` (assignment-source path), `BootstrapSpec/Core.pm` (`cat`), and the four `looks_like_{array,hash}_value_expr` recognizers (`MethodLowering`+`FlowExpr`) — `copy`'s kind resolved array-first so it stays first-class in numeric-reducer/`coalesce` type inference (`copy` is type-ambiguous, so it could NOT be added to a flat method-set — it had to RESOLVE kind, else `coalesce`'s array-vs-hash disambiguation breaks). **Proof:** `call_spec_handler_subst` byte-equal for 4 headline + 11 composed forms; `return_descriptor` `set`==`assign` ASSIGN node; a real terse spec (`set`+`cat`+`copy`) runs **byte-identical** to its canonical twin end-to-end (`["a!","b!","c!"]`, stable on re-run = per-invocation lexicals); generated source for **all 20 shipped specs byte-identical (0 diff)** (every alias add is guarded by the new spelling, which no shipped spec uses — so the broad `looks_like` edits carry zero corpus risk by construction). **+4 phase0 subtests / 31 assertions** (`spec_format_terse_1_4_1_*`) → **phase0 971→975 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 975); ratio 1.0000; `perl -c` clean on all 8 modules; `mdbook build` EXIT 0; doctrine driver 2/2. **Book (3):** `appendix/helper-contract-catalog.md` (per-helper Terse-spelling lines + a "Terse Helper Renames" subsection), `dsl/value-container-flow-helper-reference.md`, `dsl/declaration-helper-reference.md` — renames canonical, old names deprecated (not-yet-retired). KM card [[terse-helper-rename-lowering-sites]] updated (landed; full site list; reverify proves parity). **Next: `SPEC-FORMAT-TERSE.1.4.2`** (Rust `Engine::call_helper()` lockstep parity — pipe `set`/`cat`, add a value-type-dispatching `copy` arm; oracle + integration locks mirroring `.1.2.2`).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.4 — SPLIT into `.1.4.1` (Perl reference) + `.1.4.2` (Rust parity)** (DOCS/TREE/KM only; **no engine/book change**). PNT (user-directed loop, fresh session) picked `.1.4` (helper renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`) and split it after a TOOLBOX-first `call_spec_handler_subst` ground-truth pass — too broad for one signoff slice. Ground truth (dump-don't-guess; `perl -Iperl`→`perl/LinkedSpec.pm`): the three terse spellings are all currently **UNRECOGNIZED** — `set(scalar(x),1)`→`set(scalar(x), 1)` (vs `assign`→`$x = 1`), `cat("a","b")`→`cat("a","b")` (vs `concat`→the concat do-block), `copy(a(items))`→`copy([items])` partial / `copy(h(m))`→`copy(h(m))` (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). **Three implementation shapes:** `cat`→`concat` = pure rename via `_normalize_method_name` (`ActionIR/MethodExpr.pm:19-26`); `set`→`assign` = STATEMENT-level (`ActionIR/Contracts.pm:1749/1753` `\bassign\s*\(` + `DeclareMethod` + `MethodLowering._lower_assign_statement`) — NOT reached by normalization; `copy` = unified array-vs-hash dispatch in `MethodLowering._lower_method_value_expr` (array sym then hash sym). **Rust:** all four canonical helpers in one `Engine::call_helper()` match (`engine.rs`: `assign`@711, `array_copy`@735, `concat`@820, `hash_copy`@1833; pipe-arm aliases); `.1.4.2` pipes `set`/`cat` + adds a separate value-type-dispatching `"copy"` arm. Split Perl-first by variant (Perl reference + lockstep Rust parity separable, ADR 0006 — mirroring `.1.1`→`.1.1.1`/`.1.1.2` and `.1.2`→`.1.2.1`/`.1.2.2`): `.1.4.1` (Perl) + `.1.4.2` (Rust parity). Direction (ADR 0007): new terse names canonical, old names deprecated aliases that lower identically (retirement later); the 20 shipped specs (old names) must stay byte-identical. KM card [[terse-helper-rename-lowering-sites]] (map regenerated, 49 facts); `scripts/check_doctrines.sh` (MEMORY-ARCH + KNOWLEDGE-MAP) EXIT 0; no engine/book change (phase0 stays 971, N/A to a split slice; cargo 252). Frontier → `.1.4.1`. **Next:** implement `.1.4.1` (Perl reference — recognize `set`/`cat`/`copy`; signoff-critical codegen; all-20-specs byte-identical proof).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence** (RUST ENGINE + 2 oracle fixtures + 4 integration locks; **no book change, Perl untouched**). The lockstep-parity follow-on to `.1.2.1` (ADR 0006), in the user-directed single-leaf PNT cadence. **REQUIRED a Rust engine change (unlike `.1.1.2`).** TOOLBOX-first throwaway Rust probe (bare-vs-wrapped, dump-don't-guess): the interpreter's HashMaps auto-vivify (the `.1.1.2` finding), but a **bare** arg-position target was not reaching the working var — `resolve_scalar_target`/`resolve_array_target` (`rust/linkedspec-runtime/src/engine.rs`) only un-wrapped `scalar(VAR)`/`array(VAR)` Calls; a bare `Expr::Variable` fell through to `val.to_str()` (→`""`). Probe BEFORE: bare scalar `[null]`, bare array `[[]]` vs wrapped `["ok"]`/`[["a","b"]]` (divergence from Perl). **Fix:** both resolvers now also accept a bare `Expr::Variable` target and return its name (mirroring Perl's `^(\w+)$` fallback); per-parse HashMap auto-vivifies (no declare, fresh ctx per execute ⇒ no leak). Scoped to Channel-1 positions via an `allow_bare` flag (true for push_value/push_nonempty; false for value-reads array_copy/hash_copy = Channel 2). Probe AFTER: bare == wrapped (`["ok"]`/`[["a","b"]]`). **Locked:** 2 oracle fixtures `autoexist_{scalar,array}_bare_arg` (regenerated; existing 7 byte-identical; `corpus_oracle` checks Rust == Perl reference) + 4 `terse_1_2_2_*` integration tests (value anchors, bare==wrapped==declare convergence, per-parse no-leak). **cargo 248→252 green**, 9/9 oracle PASS, clippy zero-new (engine.rs 11 baseline; flattened the `if allow_bare` nest to a tuple `if let`), `perl -c gen_oracle_corpus.pl` OK; **phase0 971 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**. KM card [[terse-bare-working-vars-engine-gaps]] updated (Rust parity + engine-change contrast with `.1.1.2`). **Channel 1 complete on BOTH variants; `.1.2.1` landed against the universal contract.** `.1.2` stays `active` (Channel 2 `.1.2.3`+ pending). **Next: `SPEC-FORMAT-TERSE.1.4`** (helper renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`; old names aliased).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1)** (ENGINE + BOOK + 3 phase0 locks). First implementation child of the `.1.2` split, executed in the user-directed PNT loop (single-leaf PNT). Extended the `.1.1.1` collector `RuleIR::EmitContext::_collect_auto_working_var_decls` with a bare arg-position pass (shared `$record` dedup closure): alongside the WRAPPED typed-wrapper refs it now also collects a **bare** working var in a type-implying *first-arg* helper position with the **position-implied** sigil — `assign(NAME,…)`→`my $NAME` (scalar; the assign target always lowers scalar-first), `push_value`/`push_nonempty(NAME,…)`→`my @NAME` (array) — closing the leaky-package-global gap for bare arg-position forms. The `\s*,` after the bare name keeps a WRAPPED target on the `.1.1.1` wrapped path (no double-collection); both dedup to one `my`. **TOOLBOX-first** (`dump_parser_source`, `probe_terse_1_2_1.pl`, isolated bare forms): before, bare `assign(count,…)`/`push_value(items,…)` lowered to `$count`/`push @items` with NO `my` (leaky); after, each gets one preamble `my`; `assign(pair, set_key(hash(pair),…))` now declares both `my %pair` (wrapped) and `my $pair` (bare assign target). **Proof:** all-20-specs generated-source diff (mine vs git-stashed) = **0 diff** (corpus wraps every arg-position target — cleaner than `.1.1.1`'s 19/20). **+3 phase0 subtests / 17 assertions** (`spec_format_terse_1_2_1_*`: bare scalar+array+push_nonempty auto-exist with the `my` before `while(1)`; sigil-follows-lowering; only-the-target declared; deferred `.push` boundary; dedup vs wrapped/declare = single `my`; integrated per-invocation no-leak run-twice) → **phase0 968→971 green**; `bash tools/run_ci_local.sh` **EXIT 0** (971); ratio 1.0000; `mdbook build` EXIT 0. Book (3 pages) taught wrapper-optional-in-arg-position + corrected the outdated "argument position is a later step" note (variant-agnostic). **Scope (signoff):** Channel 1 = unambiguous first-arg value-helper positions only; child-append `push(Rule[,target])`/`.push(target)` target (rule-name first arg — ambiguous) + bare hash (value-position read) deferred to Channel 2. KM card [[terse-bare-working-vars-engine-gaps]] updated (Channel 1 closed). **Next: `SPEC-FORMAT-TERSE.1.2.2`** (Rust lockstep parity for `.1.2.1` — likely holds by architecture; assess + lock).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.2 — SPLIT into `.1.2.1` (Perl, Channel 1) + `.1.2.2` (Rust parity)** (DOCS/TREE/KM only; **no engine/book change**). PNT (user-directed loop, fresh session) picked `.1.2` (remove container wrappers + type inference) and split it after a TOOLBOX-first `dump_parser_source` ground-truth pass — too broad for one signoff slice. Ground truth (dump-don't-guess): a **bare** (un-wrapped) working var has two inference channels — (1) **arg position** already lowers to the correctly-sigil'd variable (`assign(count,v)`→`$count=v`; `push_value(items,..)`→`push @items`) BUT gets **no auto-`my`** (the `.1.1.1` collector matches only WRAPPED forms) → leaky package global; (2) **value position** is NOT a variable read (`return(count)`→ bareword `return count ;`, not `$count`) + RHS-shape `[]`/`{}` inference. Split Perl-first by channel (Perl reference + lockstep Rust parity separable, ADR 0006 — mirroring `.1.1`→`.1.1.1`/`.1.1.2`): `.1.2.1` (Perl, arg-position bare working-var auto-existence — closes the leaky-global gap, extends the `.1.1.1` collector) + `.1.2.2` (Rust parity). Channel 2 (`.1.2.3`+, value-position reads + RHS-shape) added once `.1.2.1` lands + `.1.5` literal syntax designed (not pre-published — no vague placeholders). Wrappers stay accepted aliases (gradual, ADR 0007); shipped corpus uses them pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash 36) → must stay byte-identical. KM card [[terse-bare-working-vars-engine-gaps]] (map regenerated); memory-arch + doctrine + KM gates EXIT 0; `perl -c` clean on the landing modules; phase0 stays 968 (untouched, N/A to a docs slice). Frontier → `.1.2.1` (signoff-critical Perl codegen — a fresh session is reasonable). **Next:** implement `.1.2.1`.
- 2026-06-24: **SPEC-FORMAT-TERSE.1.1.2 — Rust lockstep parity for auto-existing working variables** (ORACLE + INTEGRATION locks; **NO engine change**). The lockstep-parity follow-on to `.1.1.1` (ADR `0006`), executed in the user-directed PNT loop on a fresh session. **Assessed blocked-vs-doable = DOABLE, no engine change** (TOOLBOX-first: throwaway Rust + `perl -Iperl` `LinkedSpec::Get` probes on the same minimal grammars; read `rust/linkedspec-runtime/src/{runtime,engine}.rs`, dump-don't-guess): the Rust variant is an **interpreter** (no codegen/`eval`), so working variables live in per-parse `RuntimeContext` HashMaps (`scalars`/`arrays`/`hashes`) that **auto-vivify** on write (`set_scalar`=`insert`, `push_value`=`entry().or_default().push`) and read as `Undef`/empty when absent, and `Engine::execute` builds a **fresh `RuntimeContext` per call** — so working variables **already auto-exist** with no `declare(...)` and a value never leaks across parses (the Rust analogue of Perl's per-invocation `my`). The Perl `.1.1.1` change was a codegen fix for a non-strict leaky-package-global hazard the Rust interpreter does not have, so parity holds **by architecture**; the leaf lands as lockstep regression tests + docs (not an engine change — adding a dead "collector" to mirror a non-existent hazard would be ceremony, not parity). **Cross-variant proof** (divergence-free edge-action form = the `.7.1` oracle proof class; recursive/REP forms are blocked by the separate `RUST-PARITY` recursive-grammar/REP-lifecycle gap, verified `[null]`/`[[]]`): scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl `["a","b"]`/Rust `[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` — Rust == Perl reference wrapped one level. **Locked:** 5 oracle corpus fixtures `autoexist_{scalar,array}_{no_declare,declare}` + `autoexist_undef_literal` (`tools/gen_oracle_corpus.pl`, regenerated — existing 2 byte-identical; `corpus_oracle.rs` checks each vs the Perl reference) + 4 `terse_1_1_2_*` integration tests (value anchors, declare/no-declare convergence, per-parse no-leak via same-engine re-run). **cargo test 244→248 green**; all **7 oracle fixtures PASS**; `cargo clippy` zero-new source/test warnings; `perl -c tools/gen_oracle_corpus.pl` OK; **phase0 968 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**; `mdbook build` EXIT 0 (no book change — variant-agnostic; `.1.1.1` already taught the contract, Rust now conforms). KM card [[rust-working-vars-auto-vivify]] (map regenerated, 47 facts). **`.1.1` container done; `.1.1.1` is now landed against the universal contract. Next: `SPEC-FORMAT-TERSE.1.2`** (remove `scalar()/array()/hash()` wrappers + type inference).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables** (ENGINE + BOOK + 3 phase0 locks). First terse-format (ADR `0007`) *implementation* leaf, executed in the user-directed PNT loop. The engine now auto-supplies one preamble `my $NAME`/`@NAME`/`%NAME` for any working variable referenced through a typed wrapper (`scalar(NAME)`/`array(NAME)`/`hash(NAME)` + `s/a/h`) so `declare(...)` is optional — making the variable a per-invocation lexical instead of a leaky package global (non-strict handlers; KM [[working-vars-no-strict-need-my-lexical]]). **TOOLBOX-first** (`dump_parser_source` ground truth). New rule-level collector `RuleIR::EmitContext::_collect_auto_working_var_decls` (+ literal-masker `_mask_action_code_literals`): scans RAW pre-lowering blocks (NOT regex slots) for single-bare-identifier wrapper refs, sigil-from-wrapper, dedup vs `@<label>` accumulator + same-sigil `my` already in the lowered code (declare/raw-my), excludes DSL literals (`undef`/`true`/`false`) + engine handler locals; injected into the preamble by `SpecEntry::compile_spec_entry` (empty ⇒ byte-identical). **Proof:** generated source for all 20 shipped specs (mine vs git-stashed) = **19/20 byte-identical** — only `tkgui` differs (+1 legit `my $subgui_name;` for its genuinely undeclared working scalar; parse output identical before/after incl. a 2nd same-process parse = no leak); a Lispish `a(undef)`→`my @undef` false positive was caught by the diff + fixed (reserved-literal exclusion). **+3 phase0 locks** (no-declare scalar+array work + no cross-parse leak; declare-path single-`my`; reserved-literal excluded) → **phase0 965→968 green**; `bash tools/run_ci_local.sh` **EXIT 0** (968); ratio 1.0000; `mdbook build` EXIT 0. Book taught auto-existence (declare optional) in `dsl/declaration-helper-reference.md`, `appendix/helper-contract-catalog.md` §1 (+ corrected `assign` contract), `dsl/value-container-flow-helper-reference.md`; examples not re-authored. **Next: `SPEC-FORMAT-TERSE.1.1.2`** (Rust lockstep parity — now PNT-eligible to assess).
- 2026-06-23: **ROADMAP-DRIFT-RECONCILE.0 — own the deferred ROADMAP.md / ARCHITECTURE_STATE.md drift** (TRACKING-ONLY; no code/book/roadmap-content/KM change). Fresh-session bootstrap (full README→MEMORY_ARCHITECTURE→SESSION_BOOTSTRAP→MEMORY→COMMIT→TASK_TREE→ROADMAP_V2 read + delegated `LinkedSpec.pm`-import-tree, mdBook, and full-`ROADMAP.md` analyses) confirmed readiness and surfaced a drift finding: long-form `ROADMAP.md` has diverged from `ROADMAP_V2.md` + the tree ledger (no `SPEC-FORMAT-TERSE`/terse mention; `declare(...)` shown as permanently required; still lists `RTLUtils`+36-`.plg` as live — misses `LEGACY-VHDL-RETIRE` deletion + `NONCORE-QUARANTINE` → `noncore/` + `perl/` core-only + the phase0 count; Rust-only multi-backend framing). `ARCHITECTURE_STATE.md` mildly stale (dated 2026-06-14; model still broadly accurate). Per the user's **PNT-loop start + "Defer — track as a new leaf"** decisions (AskUserQuestion 2026-06-23), created the `ROADMAP-DRIFT-RECONCILE` tree (`active`; leaves `.1` ROADMAP.md / `.2` ARCHITECTURE_STATE.md, `pending`-deferred behind the active terse track) + indexed it, so the drift is owned without interrupting the signoff-critical `.1.1.1` engine change. **Verification:** tracking-only — self-check + doctrine driver + KM gate green via the pre-commit hook; phase0 965 unaffected. **Next: implement `SPEC-FORMAT-TERSE.1.1.1`** (Perl auto-existing variables) per the recorded design.
- 2026-06-23: **SPEC-FORMAT-TERSE.1.1 — split into `.1.1.1` (Perl) + `.1.1.2` (Rust parity); record the auto-existing-variable design + KM card** (DOCS/TREE/KM only; no engine/book change). Bootstrap-then-PNT on a fresh session (full README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE→ROADMAP_V2 read + ARCHITECTURE_STATE/TOOLBOX + delegated `LinkedSpec.pm`-import-tree & mdBook surveys) landed on the next action: PNT into the terse-format track (`SPEC-FORMAT-TERSE`, ADR `0007`), first leaf `.1.1` (auto-existing variables). **TOOLBOX-first ground truth** (`dump_parser_source` probes, scratchpad `probe_autovar*.pl`, dump-don't-transcribe) established: a rule's `I`+edges+`LX` = ONE lexical scope (`declare` emits its `my` ONCE in the preamble before the `while(1)` loop); generated handlers run with **NO `use strict`** (`SpecEntry.pm` has neither), so a working var without `declare` silently becomes a **leaky package global** (state-leaks across invocations/recursion), not a loud error — which is exactly what auto-existence fixes (make first-used working vars per-invocation `my` lexicals). That makes `.1.1` too broad for one signoff slice (multi-module Perl engine change + lockstep Rust parity, ADR `0006`), so per the PNT splitting rule **split `.1.1`** → `.1.1.1` (Perl reference: rule-level wrapper-reference collection → preamble `my`-injection, sigil from wrapper, dedup vs `@<label>`+explicit-declares, ratio 1.0000) + `.1.1.2` (Rust lockstep parity, follow-on); `.1.1` is now a container; frontier → `.1.1.1`. Recorded the verified design in the tree Decisions + KM card [[working-vars-no-strict-need-my-lexical]] (map regenerated); synced `docs/TASK_TREE.md` (SPEC-FORMAT-TERSE is now the current focus; TOP-RULE-AS-NORMAL acceptance MET). **Verification:** `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` (2/2) + KM gate all green; phase0 baseline 965 unchanged (no engine/test/book touched). **Next: implement `SPEC-FORMAT-TERSE.1.1.1`** (Perl auto-existing variables) per the recorded design, then `.1.1.2` (Rust parity).
- 2026-06-23: **TOP-RULE-AS-NORMAL.4 — book reconciliation to the top-rule-as-ordinary model; closes the tree's last executable leaf** (BOOK+TEST+DOC; no engine/spec change). Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the `TOP-RULE-AS-NORMAL` tree + ADR `0010` + the KM cards) landed on the next action `.4`. Per ADR `0010`, reconciled the mdBook to "the top (`::`) rule is an ordinary rule entered first": demoted the law claims ("Body rule only", "regex never on the `::` entry rule", "needs at least two rules", "normal shape of every `.spec`") to **recommended idiom** across **6 book files** (`spec-files-and-rule-paragraphs.md`, `formal-grammar.md`, `rule-modes-and-parse-modes.md`, `worked-spec-walkthrough.md`, `what-is-linkedspec.md`, `helper-contract-catalog.md` — the last found by a whole-book grep sweep, not the `.4` named list). Added the canonical model section + the `entry_*` (entering match) vs `match_*` (own match, post-match edge) rule + the consume-before-recurse termination rule (`formal-grammar.md` **§5.4**, phrased as a backend MUST — cross-variant-confirmed by `.3.1`) + the recursive-top-rule-needs-`LX` model. **De-footgunned** the `Pair::AND` regex-on-top example: it read `entry_text()` (→`{name:null,value:null}` — a top rule has no entering match) → fixed to a post-match edge + `match_group(0)`, folding the bare `\s*=\s*` separator into the name slot (→`{name:"name",value:"value"}`). **Fixed a correctness bug**: the worked-walkthrough's `'a = 1, b = 2'`→two-pair output was a `seek` result shown in the `consume` context (under `consume` only the first pair matches) — reframed as the consume-vs-seek distinction. **Every example verified via `LinkedSpec::Get`** (dump-don't-transcribe, `verify4*.pl`); `mdbook build` EXIT 0 (cross-ref anchor verified from generated HTML); book variant-agnostic. **+1 phase0 lock** `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family` (3 assertions): **phase0 964→965 green**; KM card [[top-rule-reads-own-match-with-match-family]] (map regenerated). Discovered (tracked, out of scope): a bare edge-less `AND` middle slot is a positional anchor that is not separately consumed (illustrative sketches only). `bash tools/run_ci_local.sh` EXIT 0; doctrine driver 2/2 PASS. **Marked `.4` `done`; `TOP-RULE-AS-NORMAL` acceptance MET — tree stays `active` only because `.3.2` (value parity) is `blocked` on `RUST-PARITY`; frontier EMPTY. Next PNT: the next active tree (`SPEC-FORMAT-TERSE.1.x`).**
- 2026-06-23: **TOP-RULE-AS-NORMAL.3.1 — Rust forward-progress / consume-before-recurse termination guard (mirror of `.2.1`); split `.3`** (RUST variant only; no Perl/spec change). Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the `TOP-RULE-AS-NORMAL` tree + ADR 0010 + the KM card) landed on the next action `.3`. **Reproduce-first (TOOLBOX, dump-don't-transcribe):** drove the four Perl phase0 top-rule grammars through the Rust pipeline (`parse_spec`→`validate`→`compile`→`Engine::execute`; baseline `cargo build` clean, 242 tests green). The cross-variant gap is **two independent layers**: **(a) termination** — `top:: /a/ I{return(call(top))}` on `aaa` made Rust recurse natively through `Engine::execute_rule` (the `call(rule)` helper, NO guard) → **stack overflow → SIGABRT**, vs Perl's clean `undef`; **(b) value** — Rust returns nulls for ALL recursive S-expression cases, *including the standard body idiom* (`top:: -> sexpr` wrapper → `[[null],[null]]`), so (b) is the **general recursive-grammar parse gap** owned by `RUST-PARITY` (Lispish already deferred per `tests/corpus_oracle.rs`), NOT a top-rule-as-ordinary issue. **Split `.3` → `.3.1`** (termination, this slice) **+ `.3.2`** (value, `blocked` on `RUST-PARITY`). **Fix (`.3.1`):** the Rust mirror of the `.2.1` `(rule,pos)` cutoff — `recursion_active: HashSet<(String,usize)>` on `RuntimeContext` (`enter_recursion`/`exit_recursion`) + a thin `Engine::execute_rule` guard wrapper around the renamed `execute_rule_inner` (re-entry at an active `(label,pos)` ⇒ return `undef`; removed on both Ok+Err exit paths). A no-consume cycle now terminates cleanly and returns `[null]` = Perl's `undef` wrapped one level by the documented Perl↔Rust accumulator output-shape rule; legitimate consume-before-recurse recursion (advances `ctx.pos` first) untouched. **Verification:** 2 new self-protecting integration locks (`top_rule_as_normal_3_1_no_consume_recursion_terminates` ⇒ `[null]`; `..._consume_before_recurse_is_not_cut` ⇒ array); **full Rust suite 242→244 green** (core/unit/corpus unchanged); changed-lib clippy clean (pre-existing `clippy --tests` debt untouched); **phase0 964/964** + `bash tools/run_ci_local.sh` **EXIT 0** (Perl untouched). KM card [[top-rule-recursion-forward-progress-guard]] updated with the Rust parity. **Next: `.4`** (book reconciliation — termination guarantee + recursive-top-rule-needs-`LX`); `.3.2` re-enters the frontier when `RUST-PARITY` lands recursive-grammar parse parity.
- 2026-06-23: **TOP-RULE-AS-NORMAL.2.2 — confirmed top re-entry recursion already works with the `LX` accumulator idiom (NO engine defect; engine frozen) + 1 phase0 lock; closed `.2`** (TEST+DOC only). Resumed `.2.2` after a transient sandbox-classifier outage cleared. **TOOLBOX `probe9.pl` (dump-don't-transcribe)** confirmed the `.2.1`-discovered "gap" is NOT an engine defect: a recursive rule used directly AS the top rule parses with an `LX` accumulator-return — `(a)`→`[["a"]]`, `(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`. **Root cause of the earlier `null`:** the default-handler `while(1)`'s no-match branch uses the default `lxcode = return undef`, so a bare accumulating top rule's outermost frame discards its accumulator at EOF — the **missing-`LX` authoring case** (the documented `top:: -> x .push` + `LX{...}` idiom applies to recursive top rules too). The decisive `(a) (b)` case shows TOP and BODY are **different grammars (different arity)**: TOP accumulates the SEQUENCE of top-level forms, BODY (`top:: -> sexpr {return(call(sexpr))}`) returns ONE form (`["a"]`). So ADR `0010`'s authorized engine change was **NOT needed** for the value (only `.2.1`'s termination guard was) — the engine already treats the top rule as ordinary. **Added phase0 lock** `top_rule_as_normal_recursion_with_lx_parses_sequence`; **phase0 963→964 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 964); zero regression; engine untouched. Marked `.2`+`.2.2` `done`; updated KM card [[top-rule-recursion-forward-progress-guard]] with the resolution. The recursive-top-rule-needs-`LX` book doc is deferred to `.4`. **Next (user's call): `TOP-RULE-AS-NORMAL.3`** (Rust cross-variant parity for the `.2.1` termination guard + top-recursion-with-`LX`) or `.4` (book).
- 2026-06-23: **TOP-RULE-AS-NORMAL.2.1 — forward-progress / consume-before-recurse termination guard (ENGINE: `perl/LinkedSpec/SpecEntry.pm`) + 3 phase0 locks; split `.2`; discovered the `.2.2` top-recursion value gap**. Bootstrap-then-implement on a fresh session (the user chose "implement the engine slice now, then stop for review before `.3`/`.4`"). **TOOLBOX ground-truth first** (scratchpad probes 1–7): `call_spec_handler_subst` pinned the REAL recursion seam — `call(rule)`/`-> rule` lower to `&{$$descr{spec}{$rule}{handler}}(...)` (`Contracts.pm:134`/`MethodLowering.pm:332`), and `{handler}` is the `SpecEntry::_build_runtime_handler` closure (`SpecEntry.pm:438`), so **every cross-rule call + recursion** flows through ONE real-Perl closure (the `dump_parser_source` `&{…{$rule}}` form is a simplified artifact, NOT the runtime). A fork+SIGKILL battery showed the per-handler `while(1)` + `LinkedRE::or` `/gc` matching is **already** forward-progress-safe (no zero-width grammar hangs); the ONE reproduced engine hang was an unconditional no-consume self-tail-call (`top:: /a/ I{return(call(top))}` → OOM). **Fix:** a precise **(rule, pos) active-stack non-progress cutoff** in that closure (file-lexical `%__ls_recursion_active`) — re-entry at a position already active for the rule ⇒ `return undef`; legitimate consume-before-recurse recursion advances `pos()` first so it never fires. **Verification:** `perl -c` clean; E4 hang→`null`; consume-recursion unchanged; **phase0 960→963** (3 new locks: no-consume terminates+undef, body S-expr parses `(a(b)c)`→`["a",["b"],"c"]`, top-recursion terminates); `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS"); zero regression. KM card [[top-rule-recursion-forward-progress-guard]]. **Discovered + split `.2`→`.2.1` (done) + `.2.2` (pending):** a recursive rule AS the top rule returns `null` while the identical body rule parses — an entry-alignment divergence; the `.2.1` top lock pins TERMINATION only. **Next (PAUSED for user review): `TOP-RULE-AS-NORMAL.2.2`** (top re-entry VALUE correctness — trace the runtime `{handler}` to root-cause the leading-token off-by-one, then a minimal regression-locked engine change), then `.3` (Rust parity), `.4` (book).
- 2026-06-23: **TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 authorizes touching the Perl engine to treat the top rule as an ordinary rule entered first; PHASE0-BACKHALF-TRIAGE.6 superseded + that tree CLOSED (DOC-ONLY)**. A design discussion off the `PHASE0-BACKHALF-TRIAGE.6` book `:AND` reconciliation escalated: the user reframed the top rule as an ordinary rule merely entered first (`::` = entry marker; no-regex dispatch loop = idiom not law; recursion allowed w/ consume-before-recurse termination) and **authorized touching the Perl variant** — captured in **ADR 0010** (scoped engine-frozen exception, cross-variant parity required). **Read-only investigation** (TOOLBOX: `LinkedSpec::Get`, `generate_only`+`dump_parser_source`, codegen grep) corrected the model: the top rule is just `&{$descr->{spec}{$top_rule}}(...)` (`Compiler.pm:1006`); `while(1)` is mode-driven; `Pair::AND`+regex already compiles as a normal AND handler (the `.3` fix) — so the OPEN gap is **top re-entry recursion + termination** (naive top-recursion hangs; Lispish body-recursion is green). **No engine/spec/test/book code touched.** Created the active `TOP-RULE-AS-NORMAL` tree (`.1` done; `.2` Perl impl, `.3` parity, `.4` book), wrote + indexed ADR 0010, wrote a new KM card [[top-rule-is-ordinary-rule-entered-first]] + corrected the stale `[]` claim in [[spec-top-rule-no-regex-two-rule-minimum]], superseded `PHASE0-BACKHALF-TRIAGE.6` and flipped that tree to `done` (moved to Completed). **Verification:** `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` green; KM map regenerates clean; phase0 unaffected (960/960). **Next: `TOP-RULE-AS-NORMAL.2`** (Perl engine — confirm matrix + enable top re-entry recursion + forward-progress guard + phase0 locks; **recommended for a fresh session** — signoff-critical codegen), then `.3` (cross-variant parity), `.4` (book).
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.3.2.2 — narrative-doc + book drift sync (DOC-ONLY): the product/architecture surfaces now reflect the deleted (RTLUtils/FSMGen/VHDL::ConstantEval) vs relocated-to-`noncore/` module reality; `LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE` both CLOSED**. Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the downstream trees + a delegated `LinkedSpec.pm`-import-tree analysis) landed on the active frontier leaf `.5.3.2.2`, the deferred `LEGACY-VHDL-RETIRE.5` body. **No engine/spec/test/book-behavior change** — only `ROADMAP_V2.md`, `ARCHITECTURE_STATE.md`, the two named mdBook files, the 3 downstream task trees, the index, and the live docs. Ground-truth from `git`/filesystem (+ Explore agent): 3 modules + 6 `.plg` deleted (`06496b4`), 12 owners + 13 `.plg` relocated to `noncore/` (`336bded`/`2baddbd`), `generic_fake_memory_module.plg`/`wrapgen.plg` deleted earlier (`cffac62`). Guarded content-anchored transforms replaced: the ARCHITECTURE_STATE owner-tree block + owner-migration bullets + legacy-plugin-branch prose; the 16 stale ROADMAP_V2 "Plugin modernization note" bullets (+ a dated Update on the historical tracker cell); the book's `## plugin/`→`## noncore/plugin/` section + corpus/CI-input mentions; the book owner-tree migration narrative. **Verification:** `mdbook build docs/linkedspec-book` EXIT 0; `git grep` confirms no deleted/relocated module presented as a live `perl/` owner; book variant-agnostic; phase0 960/960 unaffected; `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` green. **Flipped `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → `done` — both trees CLOSED** (`NONCORE-QUARANTINE.N` deferred as an explicit Non-Goal); moved both to the Completed index; containers `.5.3.2`/`.5.3`/`.5` → `done`. **Next: `.6`** (book `:AND` reconciliation — the now-fixed `::AND`+regex+return form vs the book's "Body rule only"/"no regex on top" idiom; **likely needs a short user policy check**), or PNT into `SPEC-FORMAT-TERSE.1.x`.
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.3.2.1 — status & continuity reconciliation: flip the downstream gates now both phase0 (960/960) and the full local gate (`tools/run_ci_local.sh` EXIT 0) are green (DOC-ONLY)**. Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the 5 downstream trees + delegated `LinkedSpec.pm`-import-tree & mdBook analysis) landed on the active frontier leaf `.5.3.2`. **No engine/spec/test/book code touched** — only task-tree ledgers, `docs/TASK_TREE.md`, one KM card, and the live continuity docs. **Split** `.5.3.2` (too broad — 3 trees + index + KM + ~4 narrative/product docs incl. 2 mdBook files + live docs; the book/architecture drift is a distinct pre-existing concern = deferred `LEGACY-VHDL-RETIRE.5` body) → `.5.3.2.1` (this, status & continuity) + `.5.3.2.2` (narrative-doc + book drift, next). **Flips:** `NONCORE-QUARANTINE.V` blocker (the ~173) CLEARED → `pending`; `LEGACY-VHDL-RETIRE.4` `blocked`→`done` (RTLUtils hang cleared + full gate green; the subtest-131 `HTML::PathLinks` hang moot — its smoke was excised by `NONCORE-QUARANTINE.3`) + `.5` cleared→`pending`; `SPEC-FORMAT-TERSE` implementation-gate CLEARED (`.1.x`+ now PNT-eligible, NOT started — migration policy already gradual-alias, ADR `0007`); synced the `docs/TASK_TREE.md` index (4 trees) + gave the `rtlutils-regex-hang` KM card a "Resolution" section + refreshed evidence/reverify. **Verification:** doc-only — `scripts/check_memory_architecture.sh` + the doctrine driver `scripts/check_doctrines.sh` (2/2) green; KM map regenerated/staged by the pre-commit hook; `grep` confirms no residual "blocked by phase0 / by the 173 / not green" in the ledgers. Book unaffected. **Next: `.5.3.2.2`** (narrative-doc + book drift sync: `ROADMAP_V2`/`ARCHITECTURE_STATE` owner-tree + 2 mdBook files + the `generic_fake_memory_module.plg`/`wrapgen.plg`/`ceil_log2` drift; then flip `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → `done`), then `.6` (book `:AND`).
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.3.1 — drop the stale `plugin/` reference in `tools/run_ci_local.sh`; the full local gate now passes green end-to-end**. CI tooling only — **no engine/spec/production code touched** (only `tools/run_ci_local.sh` + task-tree/live docs). Scoping `.5.3` (flip the downstream gates) surfaced that the "full local gate green" acceptance was itself RED: `tools/run_ci_local.sh` (the E4 source-of-truth gate since hosted CI is disabled, ADR `0004`) died at `require_tracked_tree plugin` → "required directory missing: plugin", EXIT 1, *before phase0 ran* — `NONCORE-QUARANTINE.3` rmdir'd `plugin/` (the 13 `.plg` moved to `noncore/plugin/`) but left `plugin` in two of the gate's pathspec lists (the **same leftover class as `.5.1`/`.5.4`**). Split `.5.3` → `.5.3.1` (this, full-gate-green) + `.5.3.2` (status/doc/KM reconciliation, pending) since the remaining gate-flips span 3 trees + a doc/book/KM sync. **Fix:** removed `plugin` from both pathspec lists (rationale comment); core gate stays core-only — dropped, NOT retargeted to `noncore/`, per the `.5.1` precedent. **Verification:** `bash -n` OK; **`bash tools/run_ci_local.sh` → EXIT 0 end-to-end** (doctrine 2/2 PASS, tracked-input + machine-path audits pass, `perl -c` clean, RAM guard ok, `prove -v -Iperl t/phase0_regression.t` = `1..960` / `All tests successful` / `Result: PASS` ~198s, "[ci] local CI gate passed"). Book unaffected. Advances `NONCORE-QUARANTINE.V`'s "full local gate green". **phase0 + the full local gate are now green together for the first time. Next: `.5.3.2`** (flip the downstream blocked statuses + doc/KM sync across `NONCORE-QUARANTINE.V`, `LEGACY-VHDL-RETIRE.4/.5`, `SPEC-FORMAT-TERSE` impl-gate), then `.6` (book `:AND`).
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.4 — re-bless the 3 dark-tail failures (TEST-ONLY); `t/phase0_regression.t` is now fully GREEN end-to-end (960/960) for the first time**. Bootstrap-then-PNT: a thorough fresh-session resume (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + delegated codebase/mdBook analysis) landed on the active frontier leaf and executed it. **No engine/spec/production code touched** — only `t/phase0_regression.t` (3 re-blesses) + task-tree/live docs. Ground-truth-first per `TOOLBOX.md` Protocol A — dumped every got-value via `LinkedSpec::Get`, not transcribed. **952/953** (`parse_mode_default_and_explicit_seek_preserve_progressive_matching` @43355 / `parse_mode_consume_requires_contiguous_match` @43383): both use `Top:: /a/ -> Top { return(1) }`; dumps → `CODE\n$VAR1 = 1;\n` (seek/consume accept) and `__AST_UNDEF__` (consume reject, unchanged). `return(1)` now resolves to scalar `1` (cluster-A/G class), so the retired tagged `?Top:` shape is gone — re-blessed `like(…, qr/\?Top:/)` → `qr/\$VAR1 = 1;/` (952's message clarified: the seek-forward proof is now the defined matched value vs consume's `__AST_UNDEF__`). **960** (`plugin_bridge_dispatch_calls_mechanically_gated_in_plg_corpus`): another stale `opendir '../plugin'` die (the 13 `.plg` moved to `noncore/plugin/`; **same class as `.5.1`**) — per the `.5.1` core-only precedent, dropped the 4 `noncore/`-dependent `.plg`-corpus asserts (the `opendir` census + the `get_plugin`/`run_plugin`/`dispatch_plugin_autoload_name` source scans), kept the core `PluginBridge.pm` `qr/Compatibility bridge/i` check (plan 5→1, rationale comment). **Verification:** `perl -c` OK; before-run 957 ok / 3 not-ok (failing = exactly {952,953,960}, reach `not ok 960` exit-255) → after-run **960 ok / 0 not-ok, EXIT 0, reach `ok 960`, `1..960` reached**; `comm` set-diff = **exactly the 3 cleared, new-failure set empty**. self-check + KM gate pass. **Book unaffected** (parse_mode behavior unchanged — only the non-idiomatic regression-test's expected AST shape; 960 is internal test infra). **Closes the green-phase0 goal of `.5`; unblocks the `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` / `NONCORE-QUARANTINE.V` chain. Next: `.5.3` (flip the downstream gates, now PNT-eligible — may hand off to `NONCORE-QUARANTINE.V`), then `.6` (book `:AND`).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.2 — fix the Lispish corpus_regression hang (root cause CORRECTED: not a regex — the parser never returns undef + the multi-parse loop lacked a progress guard); TEST-ONLY; corpus_regression GREEN, suite reaches subtest 960**. User chose "investigate + fix". **No engine/spec/production code touched** — only `t/phase0_regression.t` (one guard line) + the corrected KM card. **Root cause (measured, dogfooding TOOLBOX.md):** a single parse of the full 392B conf file = 0.03s (no backtracking); loop instrumentation showed the **Lispish parser never returns `undef`** — on a no-progress/EOF call it re-returns the prior form's AST with `pos()` unchanged (iter1 0→350 def, iter2.. 350→350 +0 def; general on single-form-EOF + `(R rise)\n\n`). `parse_with_lispish_multi`'s `while(1){…last unless defined}` therefore spun to its 100000 cap (~3 min/file × 76 files). **Fix:** a forward-progress guard (`last if pos_after<=pos_before`) — the missing streaming-loop invariant. **Measured: 76/76 conf+tablescript files ok, 0 hang; `ok 941 - corpus_regression`; full foreground run reaches subtest 960** (vs old death at 941). Corrected the KM card (was "catastrophic regex"). Deeper parser-contract (never-undef) + grammar gap (no top-level whitespace skip) = engine/spec follow-ons (cross-variant). **Running past corpus revealed 3 TEST-ONLY dark-tail failures → `.5.4`:** 960 (stale plugin-dir `opendir`, same as `.5.1`) + 952/953 (`parse_mode` assert `?Top:`; `return(1)`→scalar `1`, cluster-A/G class). NOTE: run phase0 FOREGROUND with `timeout:600000` (`run_in_background` is killed at ~120s). **Next: `.5.4` re-bless the 3 → green phase0, then `.5.3` gate flips.**
- 2026-06-22: **DOCTRINE-ENFORCEMENT-ADOPT.1+.2 — adopt the portable Doctrine-Enforcement architecture (driver+registry+gates) + a LinkedSpec TOOLBOX.md of its own debug tools**. User directive; landed `.1`+`.2` atomically (mutually referential). No engine/spec/production code touched — tooling + docs only. **`TOOLBOX.md`** catalogs LinkedSpec's **own** debug tools (per the user's "should contain LinkedSpec own debug tools"): facade probes (`Get`/`return_descriptor`/`call_spec_handler_subst`/`dump_parser_source`/`parse_only`/`generate_only`/`return_state`/`runtime_ctx_ref`), the `LINKEDSPEC_TRACE_LEVEL` trace framework, the `tools/*` scripts, the gates; generic techniques demoted to §6; every name verified against `perl/`. **`scripts/check_doctrines.sh`** = the registry driver (runs every `check_*.sh`, meta-checks each exists; registry = `MEMORY-ARCH` + `KNOWLEDGE-MAP`, **2/2 PASS**). **`.githooks/pre-commit`** + **`tools/run_ci_local.sh`** now call the driver (E3/E4). **`DOCTRINE_ENFORCEMENT.md`** (standard; §10 = LinkedSpec instance; honest hosted-CI-disabled note per ADR 0004). Discovery: README/AGENTS/CLAUDE point at both. **ADR `0009`** + INDEX. **Verification:** driver exit 0 (2/2); `bash -n` clean on hook + CI; KM in sync; the commit exercised the rewired hook green. `.3` (evidence/task-acceptance hard-gate) **deferred** (project-specific signature design). **Next: the directive is done (except deferred `.3`); the remaining open item is the user's `PHASE0-BACKHALF-TRIAGE.5.2` direction decision (quarantine vs fix vs guard the Lispish corpus hang).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.1 — remove stale corpus_regression plugin dataset (TEST-ONLY); determined subtest-941 = real stale ref (not a natural stop); EXPOSED .5.2 (Lispish corpus catastrophic backtracking)**. **No engine/spec/production code touched** — only `t/phase0_regression.t` (one dataset removed) + docs/KM. `.5` split → `.5.1` (done) + `.5.2` (blocked) + `.5.3` (blocked). **Determination:** subtest-941 `corpus_regression` "No tests run"/exit-255 is a **real stale reference, NOT a natural stop** — `NONCORE-QUARANTINE.3` rmdir'd `plugin/` but left the `plugin_plg_via_pplugin_spec` dataset, whose `opendir ../plugin or die` aborts the run at 941 (so 942-959 never ran). Removed that non-core `.plg` dataset (core gate stays core-only; `plan` 8→6, rationale comment). Baseline confirmed subtests **1-940 GREEN**. **Exposed `.5.2` (green-phase0 blocker):** re-running advanced into `corpus_regression` and **hung** — a full run = **374 CPU-min** on one 392-byte conf file; fork+SIGKILL census killed **~21/22 conf files (≈100%)**; the **Lispish** parse of conf/tablescript **catastrophically backtracks** (`alarm()` can't interrupt it); the ebnf dataset is healthy (7/7). ReDoS-style regex in the Lispish spec. KM card `lispish-corpus-catastrophic-backtracking.md`. Also found a stale `PERL5LIB=…/pgen/fx/perl` (bare `use LinkedSpec` loads the wrong checkout; use `-Iperl`). **Verification:** `perl -c -Iperl t/phase0_regression.t` OK; phase0 **NOT green** (blocked by `.5.2`); self-check + KM gate pass; book unaffected. **`.5.2` blocked on a user direction decision** (quarantine the Lispish corpus datasets vs fix the regex vs hard-timeout guard). **Next: surface the `.5.2` decision; new directive pending (adopt `pgen/DOCTRINE_ENFORCEMENT.md` + maintain `TOOLBOX.md`).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.2.4 — re-bless cluster F+G ×5 (TEST-ONLY); 5 phase0 failures cleared, zero regressions (cluster .2 complete; front 940 subtests green)**. **No engine/spec/production code touched** — only `t/phase0_regression.t`. Ground-truth-first probe of all 5 before editing. **G ×2:** `return(1)`→plain resolved `return 1`, so a single-top-rule parser returns scalar `1` — re-blessed `ok(ref($ast) eq 'ARRAY')` → `is($ast, 1, …)`. **F ×3** (migration-summary corpus aggregates): two used `return(1)` to stand in for unresolved-helper-blocked rules (now resolved/ready, cascading counts/ratios/lists/breakdown) → **restored** the corpus to genuinely-unresolved forms (`return(Leaf, $x)`; mixed = `return(Leaf, $x); my $tmp = 2`) so the original category coverage + assertions hold (2 spec + 1 payload edit total, 0 other assertion changes); the third (`compatibility_surface_metadata_includes_legacy_helper_wrappers`) had an **obsolete premise** (retired `return_m`/`return_a` are now RAW_PERL, not ready compat) → **adapted** to live compat helpers (`Top` → `return(a("?Top:"))` keeping `assign_call_my`+`capture_if`; `Leaf` → bare `return 1` = `return_bare`), re-blessing the contract-id lists/statement-count/descriptions. **Verification:** `perl -c` OK; load-independent focused Test::More harness 5/5; full `perl -Iperl t/phase0_regression.t` + `comm` set-diff = **exactly the 5 F/G cleared (phase0 6→1)**, new-failure set empty — only the `corpus_regression` natural-stop tail remains (owned by `.5`). self-check + KM gate pass. Book unaffected. **Next: `.5` (green-phase0 verification incl. the corpus tail + flip the downstream gates: SPEC-FORMAT-TERSE, LEGACY-VHDL-RETIRE.4/.5, NONCORE-QUARANTINE.V).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.2.3 — re-bless/rewrite cluster C `emit_context` ×20 (TEST-ONLY); 20 phase0 failures cleared, zero regressions**. **No engine/spec/production code touched** — only `t/phase0_regression.t`. All 20 traced to the retired `return_a`/`return_imatch`/`return_array` helpers + `return(1)` now lowering to a plain resolved `return 1` (node `RETURN`, contract `return_general`, language-agnostic-ready). Driven ground-truth-first: one comprehensive probe dumped every changed assertion's current value before editing. Changes: deps-builder `return ['?Top:', \@Top]`/`RETURN_A` → `return 1`/`RETURN`; facade `return_imatch`/`return_array` → passthrough; `a(IMATCH)` → `[IMATCH]`; two stale plan off-by-ones (89→88, 80→79); dropped the genuinely-removed `_lower_return_array_statement` probe (plan 8→6); `_find_unresolved_action_helpers` inputs `return(1)`→`return_a(1)` (counter still finds 2); `_parse_method_function_expr('return(1)')` args `'Top'`→`'1'`; descriptor-meta `RETURN_A`→`RETURN` + `return_a` contract → `return_general`/`return`, with **three subtests' spec return forms RESTORED** (`return(Top, $x + 1)`, `return(do { my $x = 1; $x })`, `return(Leaf, $x)`) so each keeps its original label/expression/nested-semicolon coverage rather than degrading it. Decision: kept the harmless dead `LinkedSpec::Deps::*` traps (Deps-unloaded covered by `emit_context_require_avoids_linkedspec_deps_load`); deferred a consistent dead-trap sweep of all 13 deps-builder siblings as optional hygiene. **Verification:** `perl -c` OK; after-run cleared the 11 cluster-C subtests ≤803 (0 regressions in 1–803) + a load-independent focused Test::More harness ran the 9 late meta/nested subtests (804–857) = 9/9 pass; authoritative low-load full `comm` set-diff = **exactly the 20 cleared (phase0 26→6)**, new-failure set empty. Two earlier full runs were SIGALRM-killed at the corpus tail by a transient external `rustc`/`nexsim_core` build (load ~29 → the documented truncated-TAP false-cleared hazard); a clean low-load re-run gave the diff. self-check + KM gate pass. Book unaffected. **Next: `.2.4` (cluster F ×3 + G STALE ×2: `return(1)` migration-summary + AST-shape re-bless).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2.2 — re-bless cluster B1-accumulator (4 `return_a`/`return_m`, TEST-ONLY); 4 phase0 failures cleared, zero regressions (closes cluster B1)**. The recon's highest-risk leaf, driven ground-truth-first. **No engine/spec/production code touched** — only `t/phase0_regression.t`. A pre-flight probe replicated **every assertion of all 4 subtests** via `LinkedSpec::Get` → all PASS before any edit. Rewrote `.return_a().return_m()` → `.return(1).return(array("?Top:", entry_groups()))` (×3, replace_all — exactly 3, all targets); block `return_m(Top)` → `return(array("?Top:", entry_groups()))` (×2, **line-scoped** — @39745 is a passing non-target, excluded); blind-call `.return_a()` → `.return(1)` (@6342); subtest-1's two retired `RETURN_A`/`RETURN_M` node greps re-blessed to `grep RETURN` + `is(hits{RETURN}, 2)` (distinct-variant feature retired into a single `RETURN`). `perl -c` OK; full phase0 **30 → 26 failing** (complete TAP to corpus tail); `comm` name set-diff = **exactly the 4 cleared, new-failure set empty**. The gate was briefly blocked by **external** CPU contention (an unrelated `cargo`/`rustc` build at system-load 32 → SIGALRM-kill, which also produced a misleading truncated-TAP false set-diff); a fresh low-load run gave the clean diff. self-check + KM gate pass. Book unaffected. **Next: `.2.3` (cluster C `emit_context` ×20 — white-box, delete/rewrite removed-`Deps::*` monkeypatch seams).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2.1 — re-bless cluster B1-array (33 `return_array`→`return(array("semantic_annotation",…))`, TEST-ONLY); 17 phase0 failures cleared, zero regressions**. Executed the recorded plan. **No engine/spec/production code touched** — only `t/phase0_regression.t`. A guarded **matching-paren-aware, line-scoped** transform rewrote 33 in-range `return_array(<Top,> semantic_annotation, X)` → `return(array("semantic_annotation", X))` (drops the `Top` label only on the L16601 subst-arg, quotes the bareword, +1 close paren), applied identically to fluent+block across 4 forms; it asserts `rewrites == in-range count` (**33**, not the recon's "34") + file-wide `return_array(` delta, dies-before-write on drift — **necessary because `return_array` is 74× file-wide and byte-identical across the 17 failing + ~20 passing switch-case subtests** (global replace would corrupt the passing ones); the full dry-run diff was inspected before apply. **Recon correction:** the 2 BOTH subtests (@17289, @20105) do **not** "pin no literal output" — each pins a literal `canonical_action_ir_hits` with stale `RETURN_A => 1`; re-blessed `RETURN 2→3` + dropped `RETURN_A`, **empirically dumped** (`{…RETURN=>3…}`, fallback=0, ready=1, I==LX) before writing. `perl -c` OK; full phase0 **47 → 30 failing**; `comm` name set-diff = **exactly the 17 cleared (incl. both BOTH), new-failure set empty**. self-check + KM gate pass. Book unaffected. **Next: `.2.2.2.2` (4 `return_a`/`return_m` accumulator, re-dump + re-bless, highest risk).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2.1 (recon) — scope + verified rewrite rule for the B1-array leaf; read-only, no test change**. Pre-implementation recon recorded so the implementation runs mechanically. **Critical scope hazard:** `return_array` = 74× in the file (**34 in failing / 40 in PASSING** subtests, byte-identical spec-body strings) → the rewrite **must be line-scoped to the 17 B1-array subtests, never a global replace**; one "failing" site is a cluster-C `emit_context` (`.2.3`), excluded. Classified the 33 spec-body occurrences into 4 forms + 1 subst-arg. **Empirically verified** `return_array(semantic_annotation, X)` → `return(array("semantic_annotation", X))` → `fallback=0`/`ready`, fluent==block; the failing subtests pin no literal output, so the rewrite is shape-agnostic. Full plan in the `.2.2.2.1` node. `perl -c` OK; phase0 unchanged at 47; self-check + KM gate pass. **Recommending a fresh session for the multi-form paren-level surgery. Next: `.2.2.2.1` (execute the recorded plan).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2 — split cluster B1 (21 subtests) into `.2.2.2.1` (return_array) + `.2.2.2.2` (return_a/return_m); decomposition slice, no test change**. Read-only recon mapped the 21 failing B1 subtests by retired helper (**17 `return_array`** incl. 2 BOTH @17289/@20105; **4 `return_a`/`return_m`** incl. the 3rd BOTH + `blind_call_fluent…`). An **archaeology** pass recovered all six retired helpers' original lowering from the COMPAT-ALIAS-RETIREMENT-V2.2 diff (`4e92503`) and **empirically verified** each canonical rewrite via `call_spec_handler_subst` probes — correcting the agent's simplified mapping (`return_array(L,e1,e2)` actually **drops the label `L`** and auto-quotes barewords → `return(array(e1,e2))`, a pure alias). The two families differ in blast radius: `return_array` = input-rewrite (expected usually already canonical); `return_a`/`return_m` add `"?L:"` + `array_copy`/`entry_groups` (re-dump + re-bless). New KM card `retired-return-helpers-canonical-rewrite.md`. No code change → phase0 stays 47; `perl -c` OK; self-check + KM gate pass. **Next: `.2.2.2.1` (17 `return_array` rewrites, mechanical-ish).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.1 — re-bless cluster B2 (55 `method_like` `RETURN_A`→`RETURN`, TEST-ONLY); 55 phase0 failures cleared, zero regressions**. Second `.2.2.x` re-bless leaf. **No engine/spec/production code touched** — only `t/phase0_regression.t`. The B2 subtests hard-coded the *retired* canonical action-IR node `RETURN_A`, which the engine renamed to `RETURN` (COMPAT-ALIAS-RETIREMENT-V2; KM `actionir-return-node-retired-to-return`). A **guarded one-pass transform** applied **52 Form-A membership-grep flips** (`grep {$_ eq 'RETURN_A'} …canonical_action_ir_nodes` → `'RETURN'`) + **19 Form-B hit-hash merges** (`RETURN += 1`, adjacent `RETURN_A => 1` deleted — the retired node renames *into* `RETURN`, so the two counts collapse into one key, never colliding) + **2 stale description fixes**; the script asserts each target's exact shape (Form-A count == 52; each Form-B `RETURN_A` adjacent to a `RETURN => N`) and aborts before writing on any drift. **Excluded (17 `RETURN_A` remain):** 14 cluster-C `emit_context` sites incl. the **passing** `helper_action_ir_events {kind}`/`helper_action_ir_nodes` sites (`.2.3`) + the 3 BOTH subtests (`.2.2.2`). **`perl -c` OK; full phase0 102 → 47 failing across two runs; `comm` set-diff = exactly the 55 cleared, new-failure set empty.** One after-only name on the first run (`parser_invalid_input_fails_at_runtime_parser_boundary`, a `Lispish` `open3` subprocess test at line 4163 — before every edit, engine byte-identical) was a CPU-contention flake, disproven by the clean re-run (`ok 137`). Remaining 47 = 20 `method_like` (B1+BOTH → `.2.2.2`) + 20 `emit_context` (`.2.3`) + 7 other (`.2.4`/`.5`). self-check + KM gate pass. **Book unaffected** (internal IR-node name, not a user surface). **Next: `.2.2.2` (B1 retired-helper spec rewrites, judgment-heavy).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2 — split cluster B (76 subtests) into `.2.2.1` (B2 token re-bless) + `.2.2.2` (B1 helper rewrites); decomposition slice, no test change**. Cluster B was too broad + partly judgment-heavy for one signoff slice. **Read-only recon** classified all 76 (B1=18 retired-helper-in-body / B2=55 retired-`RETURN_A`-token / BOTH=3) with a per-subtest line map. **Empirical probe** pinned the engine facts: canonical return node is now `RETURN` (not `RETURN_A`/`RETURN_M`); retired `return_a/return_m/return_ma/return_imatch/return_im/return_array` → `RAW_PERL` passthrough. **Scope hazard:** `RETURN_A` appears 90× across cluster B + cluster C (`emit_context`) + apparently-passing helper-event tests → NOT a global replace; each edit scoped to a failing cluster-B subtest. `.2.2.1` = re-bless `RETURN_A`→`RETURN` in 55 pure-B2 subtests (scoped; merge RETURN+RETURN_A hit hashes); `.2.2.2` = rewrite 18+3 retired-helper spec bodies to canonical helpers + re-bless dependent assertions (judgment-heavy). New KM card `actionir-return-node-retired-to-return.md`; task tree carries the full work-list. No code change → phase0 stays 102; `perl -c` OK; self-check + KM gate pass. **Next: `.2.2.1` (B2 token re-bless).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.1 — re-bless cluster A (7 parser-collection-shape subtests, TEST-ONLY); 7 phase0 failures cleared, zero regressions**. First `.2.x` re-bless leaf. **No engine/spec/production code touched** — only 13 stale `is_deeply` expecteds in `t/phase0_regression.t`. These subtests asserted the *retired* auto-tag accumulator shape `['?Rule:',[]]` for blind-call `:AND`/`:OR`/`:+`/`AND+`/`AND{N,M}` rules whose children carry `… { return(1) }`; the current engine correctly surfaces each child's own `return(1)`, so a collection is `[1,1]`, a single dispatch is scalar `1`, a repeated AND group is `[[1,1],…]`. Re-blessed against **empirically-dumped** engine output (not the triage prose). Subtests 144/149/152/153/156/163/166. **Triage correction:** cluster A = 7, not the triaged 8 — the 8th (`blind_call_fluent_post_call_chain_matches_block_form`, 206) is a retired-`return_a` failure → re-bucketed to cluster B (`.2.2`); STALE total unchanged (108). **`perl -c` OK; full phase0 109 → 102 failing; `comm` full set-diff = exactly the 7 cleared, new-failure set empty.** Remaining 102 = 101 STALE (`.2.2`–`.2.4`) + 1 `corpus_regression` tail (`.5`). (Gate SIGALRM-killed at the corpus tail under external `bin/fsmgen` CPU contention — same stop point as the baseline; not a regression.) self-check + KM gate pass. **Next: `.2.2` re-bless cluster B `method_like` ×76 (retired `return_*`/`RETURN_A`).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.4 — engine fix: input-boundary-validation regression (#2); 2 phase0 failures cleared, zero regressions**. Authorized by ADR `0008`. **Fix (one file, `perl/LinkedSpec/Runtime.pm`):** the `MEDIUM-IMPACT.3.2` comment-skip wrapper ran `pos($$input_ref)=0` (unguarded deref) before the documented input-boundary guard (`Compiler.pm validate_input_ref`, `ref ne 'SCALAR'`), so non-SCALAR-ref input died with a raw `Not a SCALAR reference at … Runtime.pm line 126` and empty `last_error`. Now gates the `pos()`+comment/blank-skip block behind `if (ref($input_ref) eq 'SCALAR')` (mirrors the inner guard exactly) and always delegates to `$original_parser`, so invalid input yields the friendly `Top-level parser expects a SCALAR reference input; got ARRAY` + populated `last_error` (`type=runtime_parser`); valid scalar-ref input keeps the comment-skip path. **`perl -c` clean; full phase0 111→109 failing — set-diff vs post-`.3` = exactly the 2 Defect #2 subtests cleared, zero other changes.** Both reference-engine defects (#1, #2) now fixed. Remaining 109 = 108 STALE (`.2.x`) + 1 `corpus_regression` tail (`.5`). KM card `runtime-input-boundary-validation-regression.md` → `resolved`. self-check + KM gate pass. **Next: `.2.x` re-bless the 108 STALE (TEST-ONLY), then `.5` green-phase0 (+ corpus tail), then `.6` book `:AND` reconciliation.**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.3 — engine fix: AND-rule action-codegen defect (#1); 62 phase0 failures cleared, zero regressions**. User **authorized both engine fixes** (sanctioned scoped exception to the engine-frozen doctrine — ADR `0008`); a fresh session first re-verified BOTH defects objectively read-only (incl. the book's OWN `Pair::AND` example breaking). **Fix (one file, `perl/LinkedSpec/HandlerVariantEmitter.pm`):** both AND-acode emitters (`_emit_and_acode_seq_handler` multi-regex + `_emit_and_single_acode_handler` single-regex) rewrote an edge `return(...)` via `s/\breturn\s*/\$" . $label . " = "/eg` — the bare `\$"` is a *reference to* the list-separator `$"` (stringifies `SCALAR(0x…)`) where the correct literal `"\$"` is used at lines 524/594/928, so the emitter produced invalid `SCALAR(0x…)<label> = …` (top→compile-fail→`undef`; child→dropped→`[]`); the single-acode handler also never `push`ed its transformed acode. **Now emits edge acodes verbatim** (already lowered to `return [...]`), so an AND edge `return(X)` surfaces the raw author payload directly (correct in both direct-AND and the `sub{}`-wrapped REP-AND iteration). Verified against all 21 cataloged AND-rule tests (`call(Child)` always wrapped as `return(call(Child))`). **`perl -c` clean; full phase0 173→111 failing (62 cleared — all 60 cluster-D capture/mark/cursor/entry/whole-input/current-match + named-G AND + `push_nonempty` C-t13 now pass).** Remaining 111 = 108 known-STALE (`.2.x`) + 2 Defect #2 (`.4`) + 1 newly-reached `corpus_regression` tail (`.5`). Only `:AND` emitters touched. KM card `and-return-edge-codegen-defect.md` → `resolved`. self-check + KM gate pass. **Next: `.4` (Runtime.pm input-boundary guard, Defect #2).**
- 2026-06-19: **PHASE0-BACKHALF-TRIAGE.1 — read-only triage COMPLETE: 173 failing phase0 subtests → 108 STALE (re-bless) / 65 REAL (engine-fix), 2 distinct engine defects**. No engine/spec/test code changed (triage report + `.2`–`.5` decomposition + 2 KM cards). Authoritative run = 173 fail/707 pass (reached 880/959 before the bg run was terminated, exit 144 mid-881). **STALE (108):** A parser-collection-shape (8, retired auto-tag `[1,1]` vs `['?Rule:',[]]`), B `method_like` (75, retired `return_*` helpers/`RETURN_A` nodes — branch-block lowering itself works/is documented), C `emit_context` (20, removed `Deps::*` seams + stale plan + retired-helper passthrough), F migration-summary (3, `return(1)` resolved not blocked), G singles (2, `return(1)` AST = scalar `1`). **REAL (65):** Defect #1 **AND-rule action-codegen** (63 — multi-edge AND + `return` edge emits `SCALAR(0x…)Rule` ⇒ compile-fail `near ")Top"` top / dropped `[]` child; bisected; likely `HandlerVariantEmitter`/`SpecEntry`); Defect #2 **input-boundary regression** (2 — `Runtime.pm:~126` wrapper derefs before the SCALAR-ref guard, commit `d7294d0`). KM cards `and-return-edge-codegen-defect.md` + `runtime-input-boundary-validation-regression.md`. self-check + KM gate pass; `perl -c` OK. **`.3`/`.4` engine fixes BLOCKED on user OK to touch the reference engine; `.2.x` re-bless is independent. Read-only triage vindicated — re-blessing cluster D would have masked a real codegen bug. Next: surface the engine-touch decision + fix order to the user.**
- 2026-06-19: **Triage WIP + trace directive owned (PHASE0-BACKHALF-TRIAGE.1 in progress; TRACE-OBSERVABILITY created)**. Ownership/read-only checkpoint (no engine/spec/test code changed). **Trace driver established:** `LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>` (existing env control; ~22k lines ENTER/DECISION/dump to stdout). **Root-caused Cluster A (parser collection-shape, ~10+) = STALE tests** (engine returns `[1,1]` per child `return(1)`; tests expect retired `['?Rule:',[]]` tagged shape → re-bless). Clusters B–E (`method_like`×75, `emit_context`×21, capture/mark/entry) pending root-cause. **TRACE-OBSERVABILITY** owns the user's trace directives (discoverable CLI control + comprehensive "see everything" trace): framework already EXISTS in `Trace.pm` (enter/exit/decision/levels/sinks; env `LINKEDSPEC_TRACE_LEVEL` works) — gaps are discoverability (no `--trace`/bin/docs) + coverage (esp. generated runtime parser). self-check + KM gate pass. **Session very long → fresh session advisable; repo handoff-ready (relocation at `2baddbd`). Next: continue Cluster B–E root-cause with trace; and TRACE-OBSERVABILITY `.2` (CLI+docs, quick win).**
- 2026-06-19: **NONCORE-QUARANTINE.3+.4 — relocate ALL remaining non-core `.pm`/`.plg` to `noncore/` + excise their phase0 subtests; DISCOVERED ~173 pre-existing back-half core failures**. `git mv` the 23 remaining domain `.pm` + 13 `.plg` → `noncore/` (layout preserved); `perl/` is now **core-only** (LinkedSpec.pm + LinkedSpec/** + LinkedRE/PathSearch/PPlugin); emptied `perl/` subdirs + `plugin/` rmdir'd. Excised the 37-subtest legacy-migration block from `t/phase0_regression.t` (source lines 3312–5378, guarded anchor-splice; 996→959 subtests); `perl -c` core+test OK; `git grep`=0 island refs. **DISCOVERY (not from this work):** phase0 now runs the long-dark back half (subtests 111+) and reveals **~173 real, deterministic core-engine test failures** — structural/shape mismatches (0 timeouts, 0 missing-module), clustered `method_like`×75/`named_mark`×25/`emit_context`×21/capture-mark families. Engine bytes unchanged by this work → PRE-EXISTING, masked by the original hang (subtest 110). Likely **stale tests** (evolved ActionIR/HandlerIR behavior, never re-run) vs real regressions. **Green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V` now blocked on triaging the 173 (separate tree).** Also: external `bin/fsmgen` 100%-CPU contention (another session, not killed) slows runs, not the cause. self-check + KM gate pass; phase0 NOT green (pre-existing failures). **Next: surface the 173 to the user; decide stale-vs-real + own a triage tree.**
- 2026-06-19: **NONCORE-QUARANTINE.1+.2 — dependency-tree inventory + relocate 12 zero-ref modules to `noncore/`** (new tree; repurposed from `DEADCODE-PRUNE` per the user's "move, don't delete" direction). Extracted `LinkedSpec.pm`'s full dependency tree (static + dynamic `get_parser`/`get_plugin`/AUTOLOAD/`.plg`→`.pm` edges) from roots = `LinkedSpec.pm` ∪ shipped specs ∪ conf/ebnf/tablescript. **41 KEEP / 36 non-core `.pm`; all 13 `.plg` non-core** (shipped specs reference 0 plugins/cross-specs → the legacy domain island is unreachable; zero core→domain edges; tools/bin clean). **Relocate (`git mv`) to `noncore/`, NOT delete** — preserve refactor/port/publish/delete options; `noncore/README.md` = parked fate ledger (hints: revive-candidate Lispish/LispML/LibReader; replaceable HUtils/Table*/HTML/HTTP/Text/Global; likely-rm vendor-timing/Timing/QC/Tk/MSOffice + 13 `.plg`). `.2`: created `noncore/` + ledger + `git mv` the 12 zero-ref modules (AmbiTiming/EasyTk/EncounTiming/HDisplay/LibReader/MagmaTiming/PTiming/Reportiming/rvp/TkGui/XLSreader/PluginUtils) — 100% safe (0 refs anywhere; no code/spec/test touched). perl/ top-level `.pm` 28→16; `perl -c perl/LinkedSpec.pm` OK. The phase0 back-half hangs live in the non-core island → removing its subtests (later batches) greens phase0. Plugin machinery stays in core for now (POSTPONE `.N`). self-check + KM gate pass. **Next: `.3` relocate the 24 domain `.pm` per cluster + remove their phase0 subtests → `.4` 13 `.plg` → `.V` verify green phase0.**
- 2026-06-18: **LEGACY-VHDL-RETIRE.2+.3 — retire the Perl-only legacy VHDL/RTL/FSM subsystem (RTLUtils hang cleared; a SECOND pre-existing back-half hang discovered)**. User confirmed "Full subsystem closure". `git rm` 3 modules (`RTLUtils.pm`/`FSMGen.pm`/`VHDL/ConstantEval.pm`) + 6 dependent `.plg` (≈6,495 lines); surgically cleaned `t/phase0_regression.t` (8 module-smoke subtests deleted + 7 mixed subtests cleaned, plan counts adjusted, ≈206 lines) + the two stale comments. `git grep`=0 refs; `perl -c` core+phase0 OK; edited subtests PASS live. **RTLUtils hang CLEARED — proven** via a pristine-HEAD worktree (original hangs at subtest 110 `add_header_n_context_clause`/`RTLUtils.pm:104`; post-retirement runs past to 130+; **corrects `.1`'s wrong line-746 claim**). **DISCOVERY:** removing it unmasked a SECOND pre-existing, unrelated hang — `HTML::PathLinks::link_path_tokens` (subtest 131) — + back-half failures (everything after subtest 110 had been dark). So **phase0 is still not green and the `SPEC-FORMAT-TERSE` gate stays blocked — now by the back-half, not RTLUtils.** Not caused by the retirement (proven). self-check + KM gate pass; full phase0 NOT green (not run to completion). **Next: surface the back-half fix-track decision to the user (new tree? scope?); `.4`/`.5` reblocked on it.**
- 2026-06-18: **LEGACY-VHDL-RETIRE.1 — own retirement tree + read-only inventory of the Perl-only legacy VHDL/RTL/FSM subsystem**. New tree `LEGACY-VHDL-RETIRE` (created this commit, ownership-first); completed its read-only feasibility/inventory leaf `.1` (the recorded `MEMORY.md` next action). Verified (`git grep` sweep + `wc -l`, no deletion): **zero functional dependency** on the subsystem from the active `.spec` core (only a comment at `perl/LinkedSpec.pm:246`); subsystem = `RTLUtils.pm`(877)+`FSMGen.pm`(3,549)+`VHDL/ConstantEval.pm`(90)=**4,516** lines; **6 dependent `.plg`** (fsmgen/lte_digital_rf/mbist/msword/regtest/rtl)=**1,979** lines; ≈**206** lines of phase0 migration-smoke; footprint ≈**6,701** lines. Catastrophic regex confirmed at **`RTLUtils.pm:746`** (corrected from the prior `add_header_n_context_clause` attribution). Caught stale doc drift: `generic_fake_memory_module.plg`/`wrapgen.plg` no longer exist yet `ROADMAP_V2:157`/`ARCHITECTURE_STATE:588` still cite them. KM card `rtlutils-regex-hang.md` written; `SPEC-FORMAT-TERSE` blocker updated to point at this tree. **Removal leaves `.2`–`.5` BLOCKED pending user removal-scope confirmation** (deletions). self-check + KM gate pass; no engine/spec/test code changed (phase0 still hangs until `.2`–`.4`). **Next: surface the removal-scope decision to the user; on confirmation, execute `.2`→`.5` to clear `RTLUTILS-REGEX-HANG` and unblock `SPEC-FORMAT-TERSE.1.1`.**
- 2026-06-18: **SPEC-FORMAT-TERSE.0 — activate + ratify the terse `.spec` format direction (ADR 0007)**. User activated the previously-`proposed` terse-format tree and reinforced the semantics (`assign`→`=`/`set`; no-sigil typed bare identifiers; type inference at init / by arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have methods; everything-is-an-expression). Wrote ADR `0007` ratifying Rounds 1–3 + **gradual-alias migration** (canonical-new + deprecated-old-alias, then explicit retirement) + lockstep-all-variants (ADR 0006) + a user-sanctioned reference-touching exception + the regression-gate requirement; indexed it. `SPEC-FORMAT-TERSE` `proposed`→`active` (current focus); `SPEC-LANG-REFERENCE` scorch paused. **Two execution decisions surfaced to the user** (migration-policy confirmation; `RTLUTILS-REGEX-HANG`-first sequencing) before any implementation leaf. self-check + KM gate pass. No engine/book change.
- 2026-06-18: **SPEC-LANG-REFERENCE.10.5.4 — book: fix `worked-spec-walkthrough.md` → verified 2-rule idiom; re-derive whole-chapter outputs; drop declare/assign**. Rewrote the book's central walkthrough from the broken single-rule `Pair::AND /…/ -> Pair[0]` (returns `[]`, claimed a single hash) to a `Top::` entry rule (no regex; `-> Pair .push` + `LX{return(array_copy(a(Top)))}`) + a `Pair:` matcher (`I{return(hash("kind","pair","name",entry_group(0),"value",trim(entry_group(1))))}`). **Re-derived every claimed I/O** via a mode-aware `LinkedSpec::Get` driver: `answer = 42` (default/consume)→`[{"kind":"pair","name":"answer","value":"42"}]`; `junk answer = 42` consume→`[]`, seek→the pair; `a = 1, b = 2`→2-element list. Output reframed single-hash→one-element **list**; `match_group`→`entry_group` (+trap); `ctx{top_rule}` Pair→Top. **`declare()`/`assign()` removed** from the advanced sketch per the user's terse-format pivot (verified still live in the engine; removal owned by `SPEC-FORMAT-TERSE`). `mdbook build` exit 0; self-check exit 0. No Perl change. **Whole-book scorch PAUSED — user activated `SPEC-FORMAT-TERSE`; next: `SPEC-FORMAT-TERSE.0` (ratify + ADR).**
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5.3 — book: fix `get-and-get-parser.md` minimal `Get` example → verified 2-rule idiom**. Replaced the inline `Get(...)` heredoc spec `Top::AND /foo/ -> Top[0] {…match_text()…}` (regex-on-top + `::AND -> Top[0]` → `[]`) with `top:: -> word .push` / `LX{return(array_copy(a(top)))}` + `word: /foo/ I{return(hash("kind","top","text",entry_text()))}` + an output comment + a structure-teaching sentence. **Verified by extracting the heredoc from the book file** + `LinkedSpec::Get`: `foo` → `[{"kind":"top","text":"foo"}]`. Caught `match_text()`→`null` vs `entry_text()`→`"foo"`. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.10.5.4`** (`worked-spec-walkthrough.md`). PNT loop continues.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5.2 — book: fix `what-is-linkedspec.md` minimal kv example → verified 2-rule idiom**. First fix slice of the whole-book scorch. Replaced the overview chapter's single-rule `Top::AND+ /(\w+)=(\w+)/ -> Top[0] {…}` example (regex on top rule + `::AND -> Top[0]` self-edge → handler compile-fail → `null`, while prose claimed "returns a hash per match") with the verified 2-rule idiom (`top:: -> pair .push` / `LX{return(array_copy(a(top)))}` + `pair: /(\w+)=(\w+)/ I{return(hash("key",entry_group(0),"val",entry_group(1)))}`) + accurate structure-teaching prose + cross-links. **Verified by extracting the exact block from the book file** and running `LinkedSpec::Get`: `foo=bar baz=qux` → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`. Idiom note: bare `{return}` without `I` → `[0,0]`. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.10.5.3`** (`public-api/get-and-get-parser.md`). PNT loop continues.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5.1 — whole-book `.spec`-snippet scorch AUDIT (findings + decomposition)**. Ran the fresh exhaustive hunt: **8 read-only `Explore` agents** over chapter groups, then **personally ground-truthed every load-bearing finding** through a private `LinkedSpec::Get` driver (an audit agent clobbered the shared scratch driver mid-run → all agent ACTUAL_OUTPUT treated as hypotheses, per the `.10.6` lesson). **Engine facts (probed):** `::`≡`:` on a non-first rule (`child::AND /re/` ≡ `child:AND /re/` = `[0]`); only the first rule is the entry; `Top:: /foo/ -> Top` → `null` — so `::`-no-regex is a STYLE doctrine, not an engine error. **Headline:** the `Rule::AND /regex/ -> Rule[N] {return}` idiom is **pervasive (~105 `::`-mode headers / ~20 files)** and is doctrine-divergent (regex on `::`) **and** the `[]`-shaped form. **User decision (AskUserQuestion): FULL BOOK-WIDE SCORCH** — rewrite every worked example (incl. isolated DSL fragments) to the 2-rule idiom + correct all outputs. Verified drifts: `tablegrep` `sens` = `=` not `=~`; `portmap` outputs nested (`["?bare:",["clk"]]`) not flat. **2 preliminary hypotheses overturned:** ebnf "richer example" compiles+parses (CLEAN); §5.5 forms run+return. Findings table + engine facts + scope Decision recorded in the tree; decomposed into per-file fix leaves `.10.5.2`–`.10.5.19` (`.10.4` superseded by `.10.5.16`). self-check exit 0. No book/Perl change (audit only). **Frontier → `SPEC-LANG-REFERENCE.10.5.2`** (`what-is-linkedspec.md` minimal example). PNT loop continues.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5 (scope) — broaden to a whole-book example scorch (user directive)**. Per the user directive ("scorch the book to hunt down book examples; the book shall not mislead, only truthful + valid code"), broadened `.10.5` into a **whole-book** exhaustive audit of every `.spec` snippet (doctrine-validity: no regex on a top `::` rule, ≥2 rules; + output-correctness via `LinkedSpec::Get`) → remediation. Audit-as-decomposition → fix sub-leaves `.10.5.1…`; subsumes `.10.4`. Frontier → `.10.5`. **Preliminary fan-out hunt** (4/5 read-only verifying agents reported before session exit; re-run fresh) confirms violations are WIDESPREAD (rule-modes, regex-in-spec, dsl helper refs; `worked-spec-walkthrough` §kind=pair claims a hash but returns `[]`; `get-and-get-parser` minimal example single-rule regex-on-top; §5.5 all three regex-on-top). `.10.3` catalog examples re-verified CLEAN. Read-only record/plan update — no book/Perl change. **Frontier → `SPEC-LANG-REFERENCE.10.5`.** Handoff-ready for a fresh session.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.6 — record: retract the inaccurate "regex-on-top → []" premise; reframe the .10 rationale as the 2-rule authoring doctrine**. Ground-truth via `LinkedSpec::Get`: the OR self-ref / cross-rule action-edge regex-on-`::`-rule forms (old `.5.2`/`.9` examples + the §5.5 frozen oracle fixtures) **run and return their value**; only `::AND … -> Rule[N] { return }` returns `[]` (the `.10.1` finding). Rewrote the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first; retracted the false "`[]`" mechanism claim. **Doctrine + `.10.3` unchanged** — only the remediation rationale is corrected (the examples violated the 2-rule doctrine, not that they returned `[]`); there is no rationale for putting a regex on a top rule. KM gate regenerates `KNOWLEDGE_MAP.md`; self-check passes. No Perl, no book-example change. **Frontier → `SPEC-LANG-REFERENCE.10.4`.** PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.3 — book: redo Scalar+Numeric helper examples + preambles with the valid 2-rule idiom**. Remediation of the `.10`-flagged structurally-invalid examples. Rewrote the §2 (Scalar) + §5 (Numeric) "Worked examples" preambles and **all 33 helper examples** (17 Scalar + 16 Numeric) in `appendix/helper-contract-catalog.md` from the invalid `Demo:: /re/ -> Demo { return(<expr>) }` (regex on top rule → `[]`) to the **verified 2-rule idiom**: top `demo::` entry rule (no regex) `-> value .push` + `LX { return(array_copy(a(demo))) }`, normal `value : /<re>/  I.return(<expr>)` reading **`entry_group(N)`**. **Every example build-AND-run re-verified through `LinkedSpec::Get`** (scratch harness builds each spec from the exact book scaffold, JSON-encodes with `JSON::PP->canonical`, sanity-checked vs the frozen `["hello-world"]` idiom); all 33 produce the documented outputs, now the top rule's **one-element accumulator snapshot** (`["hello-world"]`, `[5]`, `[3.5]`, `[null]`, `[1]`/`[0]`). **Do-not-guess fix:** `is_defined` regex `/(\w*)(\S*)/`→`/(\w+)/` (empty-matchable → double dispatch-loop match → `["present","present"]`). Only remaining catalog `match_group` is the §8 Entry/Match *reference* (correct). `mdbook build` exit 0 (HTML verified: full blocks stay single code blocks); self-check + KM gate pass. No Perl change. **Frontier → `SPEC-LANG-REFERENCE.10.4`** (redo `.9` §5.5 Pair example). PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.10 (CORRECTION) — top rule has no regex; `.5.2`/`.9` examples are structurally invalid (NOT an engine bug); retract `.10.1`, plan remediation**. User established the `.spec` structural invariant: a **top (`::`) rule has NO regex** — it is the `_INITIAL` entry/`while(1)` dispatch loop matching the regexes of the **non-top (`:`) rules**; a valid spec needs **≥2 rules** (top + ≥1 normal rule carrying the regex). Verified vs `BootstrapSpec/Core.pm:414,417` + `RuleIR.pm:193-195` + an audit of all 20 specs (every top rule `regex_on_top=no`). **Consequences:** the `.10.1` "AND_SINGLE_ACODE engine regression" verdict was **WRONG** (the `[]` was invalid spec structure, not an engine bug — Perl reference untouched, authoritative); `.5.2`'s 35 examples + catalog preamble and `.9`'s §5.5 example used the invalid `Demo:: /re/ -> Demo {…}` form and **must be redone**. Deleted the bad KM card; wrote `spec-top-rule-no-regex-two-rule-minimum.md` with the **verified 2-rule idiom** (`demo_top:: -> word_pair .push; LX{return(array_copy(a(demo_top)))}` + `word_pair : /(\w+) (\w+)/ I.return(concat(entry_group(0),"-",entry_group(1)))` → `["hello-world"]`; child reads `entry_group`, not `match_group`). Superseded `.10.1` verdict + `.10.2` fork; added remediation leaves `.10.3` (redo `.5.2`+preamble), `.10.4` (redo `.9` §5.5), `.10.5` (audit other chapters). Records/correction only — no Perl, no example rewrites in this slice. self-check exit 0. **FRESH SESSION recommended; repo handoff-ready. Frontier → `SPEC-LANG-REFERENCE.10.3`.**
- 2026-06-17: **SPEC-LANG-REFERENCE.10.1 — investigation: single-slot AND edge-return drop is a Perl-reference regression (not intended)**. Read-only root-cause investigation (the user chose "investigate first, recommend before any change," and to HOLD the PNT loop). **VERDICT: accidental regression, NOT intended.** `_emit_and_single_acode_handler` (`perl/LinkedSpec/HandlerVariantEmitter.pm:564-630`) builds the transformed edge acode in the loop at 575-582 but **never `push`es it** → empty dispatch → `return \@collect` ([]). Provenance: MEDIUM-IMPACT.3.4.x rework (`148c746`/`7fec186`); sibling `_emit_and_acode_seq_handler` got the same edit WITH its push (oversight). Pre-documented gap in `specentry-perl-coupling-inventory.md:234`; no test pins `[]`. Triple-verified vs source/git/card; behavioral matrix via `LinkedSpec::Get` (single-slot AND `LX`/`E`/edge return all → `[]`; OR self-ref + multi-slot-closing-slot + REP all surface values). KM card `and-single-acode-edge-return-dropped.md` written. `.10` split: `.10.1` done, `.10.2` (fix) **BLOCKED on a user DIRECTION decision** (engine-fix vs doc-rewrite vs both; recommend engine-fix or both — engine-fix → dedicated engine tree). No code/book change. **PNT loop HELD by user** until `.10` decided; next selectable `.5.3`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.9 — book: fix drifted §5.5 Pair example output (+ surface a systemic variant)**. Corrected the `runtime-semantics.md` §5.5 third example: `Pair::AND … -> Pair[0] { return(array("?pair:", …)) }` documented output `["?pair:","key","val"]` but actually returns `[]` (re-verified under default/`consume`/`seek` — parse mode is not the variable). Swapped to the **verified** OR self-ref form `Pair:: … -> Pair { return(array(…)) }` (→ `["?pair:","key","val"]`) + a §5.7 cross-ref note. §5.5/§5.6 swept (frozen Top→Done fixtures correct; §5.6 `I.return`-on-`:`-rule snippets are a different shipped-spec-grounded construct, untouched). **SYSTEMIC finding → new leaf `.10`, BLOCKED on a user decision:** the same single-slot `::AND -> Rule[0] { return }` form is used in several chapters that assert concrete outputs (notably the canonical `worked-spec-walkthrough.md`, claiming `{kind=>"pair",…}` for `answer = 42`; actually `[]`). Shipped specs use `-> Rule[N] { return }` self-edges only on **multi-slot** rules (closing-slot accumulator snapshot), so the construct is valid — the drift is single-slot `::AND` self-edge output claims. **Fork (surfaced to user):** engine-bug-fix (Perl reference + Rust + oracle) vs doc-rewrite (multi-chapter). `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.5.3`** (next unblocked); `.10` blocked. PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.5.2 — book: compile-verified worked examples for all Scalar + Numeric helpers**. Filled the example-density gap for `helper-contract-catalog.md` §2 (Scalar) + §5 (Numeric): a shared **Worked examples** preamble (runnable scaffold `Demo:: /<re>/ -> Demo { return(<expr>) }`; output = parser's top-level value; booleans → `1`/`0`, undef → `null`) plus an `Example` on **all 35 helpers** (17 Scalar + 18 Numeric), full `.spec` blocks for `concat`/`trim`/`num_add`/`num_sum`. **Every example build-AND-run verified through `LinkedSpec::Get`** with a scratch oracle-style driver sanity-checked against the frozen `proof_edge_{scalar,array}_literal` fixtures (reproduced exactly → outputs are reference behavior, not guesses); all 35 produce the documented outputs. **Two do-not-guess traps caught:** (1) `is_defined`/`is_undefined` lower only on the control-flow path (`ActionIR/FlowExpr.pm`) so `return(is_defined(x))` dies → documented condition-only via `if (...)`; the value-predicates `matches`/`starts_with`/`ends_with`/`contains_substr` ARE returnable (`1`/`0`); (2) `num_sum(split(...))` → `null` so array-form reducers use explicit `array(...)` (split deferred to Array `.5.3`). **Discovered defect (owned separately, not bundled): the §5.5 `runtime-semantics.md` Pair example outputs `[]`, not its documented `["?pair:","key","val"]`** (the AND-`[0]` self-edge form; the tagged array needs the OR self-ref `-> Pair` form) → new leaf `.9` (no-drift priority). `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.9`** (fix §5.5 drift) **then `.5.3`**. PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.5.1 — helper-catalog audit + variant-neutrality fixes + decomposition** (`.5` split, surface large). Delegated read-only audit of `Contracts.pm` ids vs `helper-contract-catalog.md`: **0 public-API completeness gaps** (158 ids = ~130 public + 17 internal IR variants + ~11 deprecated `compatibility_surface`); **2 Perl-sigil variant-neutrality leaks fixed** (`$name`→`name` line 13, `$rule_label`→"named after the rule label" line 159; whole-catalog re-sweep found no others); **0 `.spec` examples across all 10 families / ~140 helpers** → decomposed into per-family example sub-leaves `.5.2` (Scalar+Numeric), `.5.3` (Array), `.5.4` (Hash+Control Flow), `.5.5` (Decl/Capture-Mark/Entry-Match/Input/Call), each ≥1 compile-verified example. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.5.2`**. PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.4 — book: worked examples for grouped targets + entry-vs-match divergence**. Closes audit gaps C (grouped `-> A | B { ... }` had no example) and D (entry-vs-match lacked a divergence example). (1) *Grouped action-edge targets* section in `dsl/action-and-lifecycle-placement.md` (one shared block bound to multiple targets), grounded in `ebnf.spec` + formal grammar §3.2; compiles. (2) *When `entry_*` and `match_*` diverge* section in `dsl/capture-marks-and-source-locations.md` — a dispatched-child example (`Call`→`Inner` over `greet(world)`: `entry_text()`=`greet(`, `match_text()`=`world`), cross-linked to the source-boundary example; compiles. **Verified, not guessed**: both examples compiled through `LinkedSpec::Get`; divergence semantics grounded in `.2`'s verified source wiring + the existing book example. **Honest scope note**: a clean top-level runtime I/O for the divergence was NOT fabricated — ~9 minimal accumulator/dispatch shapes all collapsed to `[]`/`undef`/`0` (documented hard accumulator axes), so it's documented at the verified reader-wiring level. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.5`** (helper-catalog completeness + variant-neutrality sweep). PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.3 — book: the output/return-value shape contract (`runtime-semantics.md §5`)**. Closes CRITICAL gap B (output shape was reverse-engineered from `tests/corpus/`). Expanded §5 (renamed *Accumulator Convention* → *Accumulator and Output Shape*): §5.5 *What a Parser Returns* (top rule's value, returned directly, no envelope — 3 verified input→output pairs); §5.6 *The Output Shape Is the Author's Choice* (engine imposes **no output schema**; the `["?<rule>:", …]` tagged array is an **optional, older convention** with no engine meaning — authors may use any shape or none); §5.7 *`return(...)` versus the accumulator* (value channel vs implicit accumulator; child return consumed explicitly, not auto-appended); §5.8 *Backend Output Reconciliation* (the one-level wrap; reference value canonical, oracle compares a wrapping backend against `[reference]`). **Verified, not guessed**: literal examples are frozen oracle-corpus fixtures; the tagged `["?pair:","key","val"]` example was produced by **running the Perl reference** (re-confirming `.2`'s `match_group(0)`=first-capture); the convention confirmed by grepping shipped specs; wrap/return contract grounded in `docs/knowledge/rust-perl-output-oracle.md`. A hand-built accumulator example (`[undef,undef,undef]`) was **discarded** — only verified material documented. **User feedback mid-leaf**: tagged shape is non-mandatory → reframed §5.6/§5.7 (saved as durable feedback memory). `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.4`** (grouped-target + entry-vs-local-match worked examples). PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.2 — book: regex as a first-class concept + fix capture-indexing drift**. New chapter `docs/linkedspec-book/src/user-model/regex-in-spec.md` (registered in `SUMMARY.md`): `/pattern/` literal + `\/` escaping + inline `(?flags)`; regex slots/clusters → ordered-sequence (AND) vs alternatives (OR) + which-alternative branch tracking; `seek`/`consume` anchoring; numbered groups (**0-based, captures-only, compacted**) + the compaction gotcha + named-group remedy; entry-vs-match; and a verified **"regex feature set a backend must support"** section. Expanded `appendix/formal-grammar.md §3.1` with the capture-group contract + inline-flags clarification. **Every engine fact verified** read-only against `perl/LinkedRE.pm` (`oredRE`/`_build_match_info`), the ActionIR lowering (`Contracts.pm` `entry_group`→`$IMATCH_LIST[N]`, `match_group`→`$LMATCH_LIST[N]`), the `/pattern/` recognizer (`BootstrapSpec/Core.pm`), the Rust `rgx` runtime (`helpers.rs` `CompiledAlternation` + `matched_branch_number`), and cross-checked vs shipped specs (`lib_reader`/`tablegrep`/`spec.spec` → `entry_group(0)` = first capture) — never guessed. **Found + fixed a real capture-indexing contradiction**: `helper-contract-catalog.md` claimed "index 0 is the full match" (wrong) vs the walkthrough's correct "0 = first capture group"; corrected the catalog, two buggy examples (`overview/what-is-linkedspec.md`, the `formal-grammar.md` Child rule) using the wrong 1-based convention, and `source-boundary-helper-reference.md`. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.3`** (output/return-shape contract). `RUST-PARITY` (frontier `.7.5.3`) remains active, resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.1 — audit + decomposition for complete variant-agnostic `.spec` book coverage** (new tree `SPEC-LANG-REFERENCE`, created this commit, ownership-first; audit-only). Owns the user request to fully + variant-agnostically document the ENTIRE `.spec` surface with abundant examples + KM cards (next backend needs no archaeology). Two read-only agents (authoritative surface inventory from `Core.pm`/`Validation.pm`/`Contracts.pm`(158)/`spec.spec`/shipped specs ∥ book coverage map over all `user-model`/`dsl`/`compiler`/`appendix` chapters) synthesized in the tree's "Audit Findings". **8/10 surface areas already WELL-COVERED**; binding gaps: (A→`.2`) regex-as-first-class (syntax-only in `formal-grammar.md:111-127`; no mental model/examples/required-feature-set); (B→`.3`) output/return-shape contract undocumented (backends reverse-engineer from corpus). Minor: grouped targets + entry-vs-local-match examples (`.4`), helper-catalog completeness+neutrality (`.5`), capture/mark cross-example (`.6`); KM cards (`.7`); finalize (`.8`). Rejected an unverified "E/IT deprecated" inventory claim (contradicts `LIFECYCLE-FAMILY-AUDIT`). self-check exit 0; KM green; no book change. **Frontier → `SPEC-LANG-REFERENCE.2`** (regex-first-class; verify engine feature set vs `LinkedRE.pm`/rgx before asserting). `RUST-PARITY` (frontier `.7.5.3`) remains active, resumes after this doc tree.
- 2026-06-17: **DOC-DRIFT-SYNC.2 — fix transposed :& / :| rule-mode cells in formal-grammar.md (TREE COMPLETE)** (book-only). The `:&`/`:|` description cells in `docs/linkedspec-book/src/appendix/formal-grammar.md:68-69` were transposed (AND/OR sense inverted vs `Core.pm:347-348` `&`→AND/`|`→OR + the dedicated `user-model/rule-modes-and-parse-modes.md`). Fixed: `:&` → "Ordered sequence (equivalent to `:AND`)."; `:|` → "Single choice — one successful alternative wins (`:OR{1}`)." Grep confirmed no other stale `:&`/`:|` ref in the file; §2.2 Semantics note already correct. `mdbook build` exit 0; self-check exit 0; KM green; no code change. **`DOC-DRIFT-SYNC` tree COMPLETE** (both leaves) → moved to Completed in `docs/TASK_TREE.md`. **Next: NEW user request (2026-06-17) — comprehensive variant-agnostic `.spec` syntax/semantics book coverage + KM cards (own tree).** `RUST-PARITY` (frontier `.7.5.3`) is again the sole active tree, resumes after the doc work.
- 2026-06-17: **DOC-DRIFT-SYNC.1 — sync ROADMAP.md to ROADMAP_V2.md (Phase 8/9 + Overall done)** (docs-only; new tree `DOC-DRIFT-SYNC`, created this commit, ownership-first). Zero-drift fix (doctrine `docs/decisions/0001` §4) for a bootstrap-session audit finding: `ROADMAP.md` lagged `ROADMAP_V2.md` — Overall `mostly done` vs `done`, **no Phase 8 / Phase 9 rows or long-form sections** (V2:56,66-67 marks both `done`). Added `## Phase 8` (multi-backend handoff) + `## Phase 9` (Rust variant; points at the active `RUST-PARITY` parity follow-on so it doesn't over-claim) long-form sections after Phase 7; inserted Phase 8/9 Status-table rows; flipped Overall `mostly done`→`done` (covers/remaining aligned to V2:56). `ROADMAP_V2.md` is canonical (per `docs/TASK_TREE.md`), unchanged. Dismissed non-drift (Non-Goal): "158 vs 146 helper contracts" — the book's 158 is reproducible. `scripts/check_memory_architecture.sh` exit 0; KM green; no code/book change. **DOC-DRIFT-SYNC frontier → `.2`** (formal-grammar.md `:&`/`:|` fix); `RUST-PARITY` stays active, resumes at `.7.5.3` after.
- 2026-06-17: **RUST-PARITY.7.5.1 — fix the header-line-regex → 0-regex parser bug in the Rust variant** (Rust parser code + tests). `rust/linkedspec-core/src/parser.rs:86` `(\S*)`→`([^\s/]*)`: a `/…/` regex on a rule's header line was swallowed by the mode-suffix group (`parse_mode_suffix("/;/")`→`Default`, regex dropped), so single-regex header rules registered 0 regexes (bracket pairs registered 1) and `-> child[N]` edges "never fired"; narrowing the class lets the regex fall through to `rest` where `parse_inline_body` registers it. **Bracket pairs repaired:** `command_subst : /open/ /close/` now registers `[open, close]` (entry idx 0 = open; self-recursive `-> command_subst[1]` → idx 1 = close). 4 new unit tests (3 `parser.rs` + 1 `compiler.rs`). `cargo test --manifest-path rust/Cargo.toml` = **242 passed / 0 failed** (238 baseline + 4; `linkedspec_core` 90→94; corpus_oracle 1 green proof). `cargo clippy -p linkedspec-core -p linkedspec-runtime --tests` warning multiset = baseline (core 10 / runtime 13 / validation.rs 4, zero-new; pre-existing `approx_constant` exit-101 in untouched `expr.rs:687`/`types_test.rs:143` recorded, not in scope). **PNT split — necessary but NOT sufficient for tclite:** with regexes registering, the oracle still showed tclite `[]` → `[]` because tclite accumulates via fluent continuations on ACTION edges (`-> command_subst .push`, `-> command_subst[1] .return(...)`) and the parser attaches `.method` chains only to BLIND edges (`=>`), so the compiler discards them after a `->` edge (`compiler.rs:171`). That independent gap → new leaf **`.7.5.3`** (action-edge fluent lowering, greens tclite); tclite oracle cases re-deferred there (corpus back to 2 green proofs). Lispish unaffected by `.7.5.3` (uses `{ code }` blocks) — needs `.7.5.2` (scalaref). Self-check exit 0. Knowledge card `docs/knowledge/rust-perl-output-oracle.md` corrected. **Active frontier → `RUST-PARITY.7.5.3`.**
- 2026-06-17: **RUST-PARITY.7.5 — SPLIT** (PNT rule 5; tree structuring, no code). A read-only investigation (+ a direct read of `parser.rs:86`) located the two **independent** root causes of the `.7.1` oracle's shipped-spec divergence and confirmed they are separable. Split into `.7.5.1` — fix the **header-line-regex → 0-regex parser bug** (`rust/linkedspec-core/src/parser.rs:86`: the header regex's `(\S*)` mode-suffix group eats a `/…/` regex on the header line, so `parse_mode_suffix("/;/")`→Default and the regex is discarded → `-> child[0]` edges never fire; fix `(\S*)`→`([^\s/]*)`; the shared root cause for tclite/Lispish/most specs; **foundational** — every rule header — so the open/close-pair semantics + full suite + oracle must be verified) — and `.7.5.2` — add `{…}` hash-literal/field-accessor to the action-code expression parser (`rust/linkedspec-core/src/expr.rs:299`) for Lispish's `scalaref(retv, {content})` (larger; depends on `.7.5.1`). Self-check exit 0; no code touched. **Recommend a FRESH SESSION to implement `.7.5.1`** — a foundational parser change deserves fresh focus after a long session; repo is handoff-ready. **Active frontier → `RUST-PARITY.7.5.1`.**
- 2026-06-17: **RUST-PARITY.7.1 — Perl↔Rust output-oracle mechanism + green first proof** (Rust + Perl tooling; first child of the `.7` split). Built the cross-variant output oracle (ADR 0006 §Phase 8.6): a timeout-guarded Perl generator `tools/gen_oracle_corpus.pl` (`alarm` per parse, `JSON::PP->canonical(1)`) emits `rust/linkedspec-runtime/tests/corpus/<case>/{input.spec,input.txt,expected.json}` (the book `backend-handoff.md` corpus format — zero added drift); a Rust runner `tests/corpus_oracle.rs` enumerates the corpus and asserts `engine.execute(input) == [reference]` (the documented one-level wrap: Perl returns the top value directly, Rust wraps the accumulator). **The oracle's first run DISPROVED the `.7`-split premise** that tclite/Lispish match "modulo wrap": tclite `[]` → Rust `[]` (Perl `["?tcl_script:",[["?command_subst:",[]]]]`), Lispish → `exit_now(1)`. Shared root cause — a single-regex rule written `name : /re/` (single colon) compiles in Rust as **0-regex**, so `-> child[0]` edges never fire (`::` single-regex rules are fine). Engine fix deferred to NEW leaf **`.7.5`** (now first in frontier, blocking `.7.2`/`.7.3`). Mechanism proven green on 2 controlled authored grammars (scalar `"scalar-ok"`→`["scalar-ok"]`; nested array `["?proof:","ok"]`→`[["?proof:","ok"]]`) that avoid every divergence source (no retv, no group-indexing, no single-colon rule, action-less child). `perl -c` OK; `cargo test` = **238 passed / 0 failed** (237 baseline + 1); `cargo clippy -p linkedspec-core -p linkedspec-runtime --tests` = core 10 / runtime 13 / validation.rs 4 = baseline (zero-new); self-check exit 0. No book change (format already matched; wrap-rule note → `.7.4`/`.9`). New knowledge card `docs/knowledge/rust-perl-output-oracle.md`. **Active frontier → `RUST-PARITY.7.5`** (Rust engine output-parity fix).
- 2026-06-16: **RUST-PARITY.7 — SPLIT** (PNT rule 5; tree structuring, no code). A two-agent read-only investigation (Rust test/corpus infra + Perl reference output path) confirmed the broad `.7` leaf must be split: there is **no oracle mechanism / canonical cross-variant output form yet**, an **output-shape reconciliation** is needed (the Perl reference returns the top rule's value directly — `tclite` `[]` → `["?tcl_script:",[["?command_subst:",[]]]]`, `Lispish` `(x y)` → `["x",["y"]]` — while the Rust engine wraps it one level in the accumulator, `[<value>]`), **~16/20 specs lack input fixtures** (authored inputs required), and the **`RTLUtils` hang needs a hard-timeout guard**. Split into `.7.1` (oracle mechanism + canonical form + first proof on tclite/Lispish), `.7.2` (corpus batch 1 — simple specs), `.7.3` (corpus batch 2 — remaining/harder, RTLUtils-guarded), `.7.4` (drift guard + finalize). **Architecture decision:** a timeout-guarded Perl fixture generator (`tools/`) emits canonical-JSON fixtures into `rust/linkedspec-runtime/tests/corpus/`; a Rust fixture-runner test compares `engine.execute(input)` against them (Perl-free `cargo test`; realizes ADR 0006 §Phase 8.6 language-neutral corpus). Self-check exit 0; no code touched. **Active frontier → `RUST-PARITY.7.1`.**
- 2026-06-16: **RUST-PARITY.6 — strict_syntax validation mode in the Rust variant** (Rust code; closes audit Gap 4). Added `validate_with_options(spec, strict_syntax: bool)` to `rust/linkedspec-core/src/validation.rs`; `validate(spec)` is now a non-strict wrapper (all ~70 call sites unchanged). Strict mode adds `check_unused_rules` (`unused = defined − used`), promoting the Perl reference's unused-rule **warning** to a hard error — parity with `Validation.pm validate_dsl_syntax(..., strict_syntax => 1)`. **Verified the reference semantics empirically** (timeout-guarded direct `validate_dsl_syntax` calls): `Top:: -> Child` strict → FAIL "Unused rule(s): Top" (top rule **not** exempt); `Top:: -> Ghost` strict → FAIL "Undefined rule reference(s): Ghost" (reported first). Undefined refs are already fatal here in every mode (`check_edge_targets`, runs first — preserving the reference's undefined-before-unused order), a pre-existing default-stricter-than-Perl divergence left as-is, so strict's observable addition is the unused-rule rejection. 4 new tests (`validate_strict_rejects_unreferenced_top_rule`, `validate_nonstrict_allows_unreferenced_rules`, `validate_strict_still_rejects_undefined_reference`, `validate_strict_accepts_fully_referenced_spec`). `cargo test` = **237 passed / 0 failed** (233 baseline + 4); `cargo clippy -p linkedspec-core --tests` validation.rs 4 = baseline 4 (zero new), `-p linkedspec-runtime --tests` 13 = baseline 13. No book change (strict contract already in `compiler/pipeline-overview.md`; book sync `.9`). Self-check exit 0. New knowledge card `docs/knowledge/rust-strict-syntax-validation.md`. **Active frontier → `RUST-PARITY.7`** (expand Rust runtime test corpus to the 20 shipped specs — Perl↔Rust output oracle).
- 2026-06-16: **RUST-PARITY.5.5.4 — anonymous capture-slice family in the Rust engine (+ catalog §7 entries)** (Rust engine code + book; fourth/final child of the `.5.5` split — **closes `.5.5` and `.5`**). Implemented the **anonymous** capture-slice family (counterpart of the `.5.5.3` named-mark family; reads the anonymous capture cursor `ctx.capture_start` = Perl `$IPOS`, set by `start_capture_slice()`). Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm` ~366–656. **Fixed** `capture_slice`/`capture_slice_len` to end at `ctx.match_start_byte` (match-start, Perl `$LSPOS - length $LMATCH`), was `ctx.pos` — the anonymous analog of the `.5.5.3` `capture_from` fix; this closes the book↔Rust gap `.5.5.3` handed off (catalog already stated match-start). **Added** 10 `call_helper` arms (reusing `span_text`/`span_char_len`): `capture_slice_until_cursor`(+`_len`)→cursor; `capture_take`(+`_len`)→match-start then advance `capture_start` to cursor; `capture_take_until_cursor`(+`_len`)→cursor then advance; `capture_rest`(+`_len`)→end-of-input; `capture_take_rest`(+`_len`)→end then advance. Text → raw slice, `_len` → char count (`.5.3`); reversed span → `undef`; `_take_*` mutate only on a valid span. **Scope:** folded in the inventory-missing-but-same-family `capture_rest`/`capture_rest_len`/`capture_take` so the anonymous family lands complete (the `.5.5.3`-discovered mark/match/entry-anchored helpers stay a deferred follow-up). **Book catalog §7:** added the 10 anonymous entries + refined the intro endpoint list and the destructive-`_take_` note (the take readers advance to the cursor, not the read endpoint); variant-agnostic, no-drift. Updated the two landed `helpers_5_2_capture_slice_*` tests (`"hello"`→`""`, `>0`→`0`). `cargo test` = **233 passed / 0 failed** (223 baseline + 10 new `helpers_5_5_4_*`); `cargo clippy -p linkedspec-runtime --tests` source warnings **13 = baseline 13** (zero new; vendored pgen/rgx-core ignored). `mdbook build` exit 0; self-check exit 0. New knowledge card `docs/knowledge/rust-anonymous-capture-slice-family.md`. **Active frontier → `RUST-PARITY.6`** (strict_syntax validation mode).
- 2026-06-16: **RUST-PARITY.5.5.3 — mark-based capture family in the Rust engine (+ catalog §7 fix)** (Rust engine code + book; third child of the `.5.5` split). Implemented the audit Gap-5 mark-based readers + setters and **fixed `capture_from` to Perl match-start parity** (Open Question RESOLVED as option (a), user-confirmed). Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm` ~690–1047. New `call_helper` arms (`rust/linkedspec-runtime/src/engine.rs`): `capture_from` (fixed: now ends at `ctx.match_start_byte`, was `ctx.pos`), `capture_len_from`, `capture_until_cursor_from`(+`_len`), `capture_take_until_cursor_from`(+`_len`), `capture_take_len_from`, `capture_rest_from`(+`_len`), `capture_take_rest_from`(+`_len`), `capture_between`, `capture_len_between`, `mark_input_start`(→0), `mark_input_end`(→byte len), `mark_copy(target, source)` (**2-arg** copy/delete). `_take_*` advance the mark to the read's endpoint (cursor, or end-of-input for `_rest_`); text → slice, `_len_*` → char count; missing mark / reversed span → `undef` (guarded `span_text`/`span_char_len`). **Book catalog §7 corrected** to the authoritative contract (user-requested): `capture_from` endpoint, 2-arg `mark_copy`, `_until_cursor_`/`_take_` + anonymous `capture_slice` wording, and the missing `_len_` companions. Updated the landed test `helpers_5_2_mark_and_capture_from` `"hello"`→`""`. `cargo test` = **223 passed / 0 failed** (207 baseline + 16 new `helpers_5_5_3_*`); `cargo clippy -p linkedspec-runtime --tests` source warnings **13 = baseline 13** (zero new; vendored pgen/rgx-core ignored). `mdbook build` exit 0; self-check exit 0. New knowledge card `docs/knowledge/rust-mark-based-capture-family.md`. **Discovered (recorded for `.5.5.4`/follow-up):** anonymous `capture_slice`/`_len` Rust arms still read to cursor; `mark_match_start/end`, `mark_entry_start/end`, `capture_take(mark)`, `capture_take_between(_len)` are absent from both Rust and the `.1` inventory. **Active frontier → `RUST-PARITY.5.5.4`** (anonymous capture-slice variants).
- 2026-06-16: **ALIAS-RETIREMENT-DOC-SYNC.1 — retire array-edge alias claims across book + roadmaps** (docs-only; new 1-leaf tree, completed). Zero-drift correction driven by RUST-PARITY.5.5.2's resolution + user direction that the variant-agnostic book/docs must be correct (not deferred as "Perl-side"). The array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` are retired (Perl reference doesn't recognize them; 0 spec uses; 0 `t/` locks; "Retired" in the book catalog). Corrected 16 stale "remains/preserving … compatibility alias/syntax" claims → retirement (`COMPAT-ALIAS-RETIREMENT.1`), preserving historical "Landed …" records: book `appendix/formal-grammar.md:357`; `ROADMAP_V2.md` (182 ×3 + 256/257/260/262); `ROADMAP.md` (735/736/993/994/997/999/1189/1190/1191/1242). The book is now internally consistent with its own Helper Contract Catalog. Capture / named-map aliases caught by the same grep left out of scope (separate audit). `mdbook build` exit 0; gates pass; no code change. **Active Rust frontier unchanged → `RUST-PARITY.5.5.3`.**
- 2026-06-16: **RUST-PARITY.5.5.2 — input-boundary helpers + flat splice** (Rust engine code; second child of the `.5.5` helper-gap split). Added 3 `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs`: `input_end_line()` (= `1 + whole-input newline count`, parity with Perl `Contracts.pm` `INPUT_END_LINE_READ`), `input_end_col()` (char distance past the last newline `+1`-when-none, parity with `_build_column_read_expr(length($$STRING))`, modeled on `cursor_col`, multibyte-correct), and generic `flat(container)` (Array→Array / Hash→Hash / scalar→single-element; Perl `MethodLowering.pm:199`). **Resolved the parked alias-retirement Open Question against the Perl reference:** `tail`/`drop_last`/`flatten`/`array_values` are NOT recognized by the reference (absent from all helper-recognition regexes, unused in 20 specs, 0 phase0 locks, retired in `COMPAT-ALIAS-RETIREMENT.1`, "Retired" in the book catalog) → deliberately NOT added to Rust (parity = match the reference's recognized surface; adding them would diverge). Only canonical `flat` was missing and is added. 3 new tests (`helpers_5_5_2_*`, end-to-end incl. multibyte + trailing-newline + flat-into-parent-hash). `cargo test` = **207 passed / 0 failed** (204 baseline + 3); `cargo clippy -p linkedspec-runtime --tests` `linkedspec-runtime` lib 13 = baseline 13 (zero new; integration_test `len_zero` :199 pre-existing; vendored pgen/rgx-core ignored). No book change (catalog §9 + §Compatibility-Aliases already conform; book sync `.9`). New knowledge card `docs/knowledge/rust-retired-array-aliases-not-added.md`. Flagged stale `ROADMAP_V2` 256–262 alias text for a separate Perl-side doc-sync slice. **Active frontier → `RUST-PARITY.5.5.3`** (mark-based capture family `capture_*_from`/`_between`, `mark_*`).
- 2026-06-16: **RUST-PARITY.5.5.1 — named-group reader helpers** (Rust engine code; first child of the `.5.5` helper-gap split). Added the 8 named-capture readers from the audit's Gap 5 to Helper Contract Catalog §8 parity, as new `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs`: `entry_named(name)`→string/undef, `entry_has(name)`→bool, `entry_map()`/`entry_named_map()`→hash, plus the four `match_*` equivalents (`entry_named_map`/`match_named_map` are retired aliases implemented as combined arms). The entry readers read `ctx.entry_named`, the match readers `ctx.match_named` — both already populate from `MatchResult.named` (engine.rs:280/291) and save/restore in `SavedMatchState`, so this is a purely additive 8-arm change (no struct/population changes). New free helper `named_map_to_hash` sorts keys so `entry_map`/`match_map` are deterministic (matching `sorted_keys`/`sorted_values`). 6 new tests (`helpers_5_5_1_*`, end-to-end via `(?P<name>…)` regexes, covering present/absent and alias forms). `cargo test` = **204 passed / 0 failed** (198 baseline + 6); `cargo clippy -p linkedspec-runtime --tests` lint multiset byte-identical to stashed HEAD baseline (13 = 13; zero new). No book change (catalog §8 already documents these; Rust now conforms — book sync is `.9`). No knowledge card (localized additive change reading existing infra). **Active frontier → `RUST-PARITY.5.5.2`** (input-boundary helpers + real compat aliases; resolve the parked alias-retirement Open Question there).
- 2026-06-16: **RUST-PARITY.5.5 — SPLIT** (PNT rule 5; tree structuring, no code). PNT reached `RUST-PARITY.5.5` and an engine.rs audit confirmed it too broad (~28 missing helpers across ~7 families; only `drop_front`/`drop_back`/`array_copy`/`flat_array` of the family exist). Split into `.5.5.1` named-group readers (entry/match `_named`/`_has`/`_map`), `.5.5.2` input-boundary helpers + real compat aliases (`tail`/`drop_last`/`flatten`), `.5.5.3` mark-based capture family (`capture_*_from`/`_between`, `mark_*`), `.5.5.4` anonymous capture-slice variants. Parked an alias-policy Open Question (book catalog says `tail`/`drop_last`/`entry_named_map` are "retired aliases"; `ROADMAP_V2` says they "remain compatibility syntax" — resolve against the Perl reference in `.5.5.2`). Frontier → `.5.5.1`. **`.5.5` is detailed per-family helper work; recommending a FRESH SESSION to implement `.5.5.1`–`.5.5.4` at signoff quality after four engine leaves this session — repo is handoff-ready.**
- 2026-06-16: **RUST-PARITY.5.4 — dedup shadowed arms + REP zero-progress guard** (Rust engine code). Removed three shadowing duplicate `call_helper` arms (`print`, `hash`/`h`, `hash_copy`) so the better later arms win (Hash-arg merge for `hash`, `resolve_array_target` for `hash_copy`, consolidated `say|print|print_each`) — clearing 3 `unreachable_patterns` warnings. Fixed the REP loop's zero-progress guard: it now snapshots `pos_before` each iteration and breaks when `ctx.pos == pos_before` (Perl `loop_end_pos == loop_start_pos`) instead of a `matches > 100` iteration cap, so a zero-width REP match terminates after one no-progress iteration. 2 new tests. `cargo test` = **198 passed / 0 failed** (196 baseline + 2); `cargo clippy -p linkedspec-runtime --tests` touched-file warnings 15 → 12 (zero new). No knowledge card (localized fix). No book change (internal correctness; matches the documented Perl REP model — book sync is `.9`). **Active frontier → `RUST-PARITY.5.5`** (~30 missing capture/mark/entry/match/input helpers + real `tail`/`drop_last`/`flatten` aliases).
- 2026-06-16: **RUST-PARITY.5.3 — char-based offsets/slicing** (Rust engine code). Closed the audit's byte-indexing MAJOR: `substr`/`input_slice` byte-sliced DSL char-offset args (panicking on a multibyte boundary), cursor/capture lengths+columns were byte counts, and `entry_start_pos`/`match_start_pos` were hardcoded `0.0`. Internal positions stay byte-based (the regex engine is byte-based); the DSL boundary is now char-based for Perl parity via new `byte_to_char_offset`/`char_substr` helpers. `substr`/`input_slice`/`cursor_*`/`input_*`/`capture_slice_*`/`mark_pos`/`entry_*`/`match_*`/`length` all char-based; `RuntimeContext` gained `entry/match_*_byte` span fields (part of `SavedMatchState`, recorded from `m.start`/`m.end`) so `entry/match_start_pos` report real char offsets. 7 new multibyte tests (`chars_5_3_*`). `cargo test` = **196 passed / 0 failed** (189 baseline + 7); `cargo clippy -p linkedspec-runtime --tests` touched-file warning count identical to baseline (zero new). New knowledge card `docs/knowledge/rust-char-based-offsets.md`. No book change (positions/lengths/`substr` are char-based in the `.spec` contract; Rust now conforms — book sync is `.9`). **Active frontier → `RUST-PARITY.5.4`** (dedupe match arms + REP zero-progress guard).
- 2026-06-16: **RUST-PARITY.5.2 — entry_*/match_* separation** (Rust engine code). Closed the audit's match/entry-unification MAJOR: the single match-set site set the rule's own regex match into BOTH the entry registers (`entry_groups`/`entry_named`) and the local registers (`match_groups`/`match_named`), so `entry_*` and `match_*` were always identical and a child clobbered the parent's match. `execute_rule` now emulates Perl's per-handler `IMATCH`/`LMATCH` lexicals via a `SavedMatchState` save/restore: the entry match = the dispatcher's local match (Perl `$info = $minfo`, `MethodLowering.pm:332` + preamble `IMATCH=$$info{match}`); the rule's own match updates only the local registers; entry is seeded from the first own match only for the dispatcher-less top rule; both registers restore on exit (blind-call + normal returns) so a child's matching is transparent to the parent. 3 new integration tests (`match_5_2_*`: child entry/local divergence, parent match survives child dispatch, top-rule entry==local). `cargo test` = **189 passed / 0 failed** (186 baseline + 3); `cargo clippy -p linkedspec-runtime --tests` touched-file warning set identical to baseline (zero new). New knowledge card `docs/knowledge/rust-entry-match-separation.md`. No book change (the `.spec` `entry_*`/`match_*` contract is already documented; Rust now conforms — book sync is `.9`). **Active frontier → `RUST-PARITY.5.3`** (char-based indexing + cursor line/col).
- 2026-06-16: **RUST-PARITY.5.1 — retv-propagation BLOCKER fixed** (Rust engine code; done in a fresh session as the prior handoff recommended). After `->`/`=>`/REP child dispatch, the child's `return(expr)` value is now readable as `scalar(retv)` in the parent's attached code / `LE` / `E` (was undef → null/wrong output for nearly every grammar). `execute_rule` now returns the rule's own value via a per-invocation save/restore channel in `RuntimeContext`; both dispatch sites call `set_retv(child_retv)`; `return(...)` feeds the channel while still pushing the accumulator (baseline contract untouched); the dead `set_retv` is wired in. Latent `call(child)` rule-name-resolution bug also fixed (enables `assign(s(retv), call(child))`). 4 new integration tests (acode/OR, blind-call/AND, REP, `call`). `cargo test` = **186 passed / 0 failed** (182 baseline + 4); `cargo clippy` adds zero new `linkedspec-runtime` warnings. No book change (the `.spec` contract already specifies retv — Rust now conforms; Rust-parity book sync is `.9`). **Active frontier → `RUST-PARITY.5.2`** (separate `match_*` from `entry_*`).
- 2026-06-16: **RUST-PARITY.5 — SPLIT** (PNT rule 5; tree structuring, no code). PNT reached `RUST-PARITY.5`, found it too broad (six audit findings bundled), and split it into `.5.1` retv-propagation BLOCKER fix, `.5.2` match/entry split, `.5.3` char-based indexing, `.5.4` dedupe match arms + REP zero-progress guard, `.5.5` ~30 missing helpers. Sequenced retv-first. Confirmed Rust baseline green (`cargo test` = 182 tests, 0 failed) before splitting. Frontier → `.5.1`. **`.5.1` is correctness-critical engine surgery (engine.rs `execute_rule` + runtime.rs) — recommending a FRESH SESSION to implement it at signoff quality; repo is handoff-ready.**
- 2026-06-16: **SPEC-SPEC-SELFHOST.4 — TREE COMPLETE** — docs-sync finalization for the `specs/spec.spec` self-hosting rewrite (`.2`/`.3`, commit `4c667b7`). DEVELOPMENT_NOTES gained a status note superseding the MEDIUM-IMPACT.3.x "2/20" dual-path entries (rewrite = faithful 13-rule description of BootstrapSpec::Core; ratio 1.0000; cross-check harness now full 20/20 paragraph-count parity; self-hosts 13==13); mdBook `pipeline-overview` dual-path note now states the parity; extension-surface policy confirmed preserved verbatim in the new spec.spec header. Bootstrap stays oracle/primary; spec.spec = diagnostic side channel (Non-Goals). `mdbook build` exit 0; self-check exit 0. Tree moved to Completed. **Only `RUST-PARITY` (`.5`, retv BLOCKER) remains active.**
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.7 — TREE COMPLETE** — final whole-book cross-chapter consistency sweep over all 41 `src/**.md` pages: every page with Perl-API blocks carries a backend frame (`get-and-get-parser` uses one chapter-top frame per `.4` Option A); zero "Perl as the only backend" statements remain. One light touch: ebnf descriptor lead → "ask the reference (Perl) backend". `mdbook build` exit 0; self-check exit 0. The MDBOOK-VARIANT-AGNOSTIC tree (7 leaves) is complete and moved to Completed in `docs/TASK_TREE.md`; `ROADMAP_V2.md` Overall-roadmap row notes the milestone. The mdBook now documents the `.spec` file as the one universal contract with Perl as the reference backend across all sections. Active trees remaining: `SPEC-SPEC-SELFHOST.4`, `RUST-PARITY.5` (retv BLOCKER). **No documentation/book-sync tree active — PNT would next pick from `SPEC-SPEC-SELFHOST` or `RUST-PARITY`.**
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.6** — reframed the mdBook appendix (3 pages), the 6 corpus walkthroughs, and the development CI chapter as variant-agnostic (2 pages confirmed CLEAN). Appendix: `formal-grammar`/`runtime-semantics` cursor terminology (demoted `pos($input)`; relabeled `LinkedRE::or` + `generated_handler`), `backend-handoff` diagram `hashref AST`→`structured AST`. Corpus: one shared "`.spec` is the contract; the reference (Perl) backend runs it by spec name" driver frame; Perl-reference banners on the `plugin/` migration narrative and `pplugin`'s `.plg`/`PPlugin` subject. **Caught + fixed a drift:** the `ebnf` walkthrough showed a stale raw-Perl `semantic_annotation` action that no longer matched the migrated shipped helper-DSL rule (`specs/ebnf.spec:187`). `git diff --check` clean; `mdbook build` exit 0; self-check exit 0. Frontier → `.7` (final build + cross-chapter consistency + docs sync). Next: `MDBOOK-VARIANT-AGNOSTIC.7`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.5** — reframed the mdBook DSL + compiler/architecture chapters as variant-agnostic. Re-grepped all 14 in-scope pages (did NOT trust the `.1` CLEAN tags) and caught 3 leaks the audit mis-tagged CLEAN (`fluent-and-block-forms` `ControlFlow.pm`/`do { … }`, `source-boundary-helper-reference` BACKTRACK `pos($$STRING)=…`, `action-model-and-helper-surface` "byte offset"). Compiler 4 (`pipeline-overview`, `compiled-state-model`, `generated-handlers-and-dispatch`, `diagnostics`) + DSL 4 got backend-neutral frames demoting concrete Perl behind a "Perl reference backend" label; `architecture/owner-tree` got a "Perl reference implementation" banner; 5 pages confirmed CLEAN. Also reconciled the stale `docs/TASK_TREE.md` index row (`.2`→`.6`). `mdbook build` exit 0; self-check exit 0. Frontier → `.6` (appendix + 6 corpus walkthroughs). Next: `MDBOOK-VARIANT-AGNOSTIC.6`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.4** — reframed the 4 mdBook public-api chapters (`get-and-get-parser`, `descriptor-introspection`, `trace-api`, `plugin-registry`) with per-chapter backend frames (Option A — resolved the tree's Open Question): entry points/options, descriptor shape/fields, and the trace model are backend-neutral contracts while concrete signatures/encodings/constants/state vars are the Perl reference surface; `plugin-registry` got a deprecated/Perl-reference banner. `mdbook build` exit 0; self-check exit 0. Frontier → `.5` (DSL + compiler/architecture). Next: `MDBOOK-VARIANT-AGNOSTIC.5`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.3** — reframed the mdBook user-model chapters (`worked-spec-walkthrough`, `runtime-context-and-tracing`, `spec-files-and-rule-paragraphs`, `rule-modes-and-parse-modes`) to lead with the `.spec` contract and label runnable blocks as the Perl reference backend's surface; replaced the lone raw-host-language payload with helper DSL. Refined the `.1` audit: `rule-modes-and-parse-modes` was NOT fully CLEAN (real Perl-API "Public option shape" block) — remediated; `blind-calls-and-parser-orchestration` confirmed CLEAN. `mdbook build` exit 0; self-check exit 0. Frontier → `.4` (public-api chapters). Next: `MDBOOK-VARIANT-AGNOSTIC.4`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.2** — reframed all 5 mdBook overview pages (`index`, `what-is-linkedspec`, `design-rationale`, `documentation-layers`, `project-status`) so the `.spec` file is the **one universal contract** and Perl is the **reference backend** (Rust = second backend), aligned with `appendix/backend-handoff.md` + ADR 0006. Also fixed a phase drift in `project-status` (0–7 → 0–9; added Phase 8 multi-backend handoff + Phase 9 Rust variant). `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0. Frontier → `.3` (user-model chapters). Next: `MDBOOK-VARIANT-AGNOSTIC.3`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.1** — completed the variant-agnostic audit of the mdBook: deterministic Perl-leakage scan over all 41 `src/**.md` pages + targeted reads → full per-file catalog with a 3-way classification (CLEAN / REMEDIATE / LABEL) recorded in the task file. Found ~18 CLEAN, ~19 REMEDIATE, ~5 LABEL; the DSL `::`/`:AND` "hits" are `.spec` rule-labels, not Perl. Audit only — no book edits (remediation is `.2`–`.6`). Frontier → `.2` (overview chapters). Next: `MDBOOK-VARIANT-AGNOSTIC.2`.
- 2026-06-16: **TASK-TREE-INDEX-SYNC.1** — reconciled the stale `Active Task Trees` frontier column in `docs/TASK_TREE.md` against the authoritative per-tree `## Current Frontier` sections: `SPEC-SPEC-SELFHOST` `.2`→`.4`, `RUST-PARITY` `.1`→`.5` (`.4` superseded). One-leaf owning tree created+completed in the slice. Doc/tracker only — no code. Next: `MDBOOK-VARIANT-AGNOSTIC.1` (variant-agnostic audit).
- 2026-06-16: **SPEC-SPEC-SELFHOST.2+.3** — rewrote `specs/spec.spec` as a faithful self-hosting grammar. The old file returned `[[]]` (unusable); the new one mirrors the bootstrap `SPEC_ROOT` driver: `spec_file::` owns paragraph accumulators, dispatches to 12 per-token part rules, and starts a new paragraph at every `rule_header`. Compiles at ratio 1.0000 (blocked 0, compat 0). 19/19 shipped specs match the bootstrap oracle's exact rule count; `tools/cross_check_spec_parsers.pl` reports "ALL 20 specs match" (was 2/20); self-parses (13 paragraphs == 13 rules). New active tree `SPEC-SPEC-SELFHOST`; frontier: `.4` (docs sync). Stale Rust in-flight work left uncommitted (RUST-PARITY follow-on).
- 2026-06-16: **RUST-PARITY.3** — BACKTRACK/IBACKTRACK cursor save/restore in Rust runtime. `backtrack_stack` in RuntimeContext with push/pop. 4 new tests. 181/181 PASS. Active frontier: RUST-PARITY.4 (self-hosting).

- 2026-06-16: **RUST-PARITY.2** — Conditional flow in Rust runtime. if/elseif/else/endif, switch/case/default/endswitch with lazy evaluation. 12 new tests. 177/177 PASS.

- 2026-06-16: **RUST-PARITY.1** — Gap inventory complete. Rust vs Perl audit across `engine.rs` (1984 lines), `helpers.rs` (470 lines), compiler, parser, validation. 6 gap categories: (1) conditional flow, (2) BACKTRACK/IBACKTRACK, (3) self-hosting, (4) strict_syntax, (5) ~27 remaining helpers, (6) code-gen emitter. RUST-PARITY tree created (9 leaves). MDBOOK-VARIANT-AGNOSTIC tree created (7 leaves).
- 2026-06-15: **RUST-EDGE-SEMANTICS.4** — Tree COMPLETE (4 leaves). All 20 shipped specs compile. 166/166 PASS. RUST-EDGE-SEMANTICS tree closed and moved to Completed. **No active task trees — PNT idle.**
- 2026-06-15: **RUST-EDGE-SEMANTICS.3** — 7 new integration regression tests: edge-only dispatch end-to-end, mixed regex+edge, self-recursive compiler output, grouped targets, Child[N] entrypoint, lifecycle with edge-only, self-recursive edge-only. 166/166 PASS. Active PNT frontier: RUST-EDGE-SEMANTICS.4 (finalization).
- 2026-06-15: **RUST-EDGE-SEMANTICS.2** — Two-phase compiler rewrite. Phase 1: same-line regex→edge adjacency tracking via `element.line`. Phase 2: `build_dependency_regex_map` post-processing resolves edge-only entries from child rule regexes. `has_parent_regex` field on `AcodeEntry`. 8 new tests. Self-recursive rules resolved. Missing/OOB child regexes warn and skip. 159/159 PASS. clippy clean. Active PNT frontier: RUST-EDGE-SEMANTICS.3 (regression tests).
- 2026-06-15: **RUST-EDGE-SEMANTICS.1** — Full audit of Rust `->` edge dispatch vs Perl `dependency_regex_map` semantics. Documented: (a) compiler.rs lines 52-55 building regex_patterns from only explicit /regex/ entries, (b) compiler.rs lines 57-91 building AcodeEntry with `regex_idx = current_regex_idx - 1` (preceding parent regex), (c) engine.rs lines 77-81 building empty alternation for edge-only rules and lines 169-190 dispatching on parent-regex index, (d) 6-step Perl pipeline trace (BootstrapSpec→RuleIR→EmitContext→Compiler→HandlerVariantEmitter) + 5-row delta table. Root cause confirmed: Rust's "preceding regex" model vs Perl's child-regex alternation model. No code changes — audit/documentation only. Active PNT frontier: RUST-EDGE-SEMANTICS.2 (compiler rewrite).
- 2026-06-15: RGX-ADOPTION.1/.2 — rgx-core adopted as Rust regex engine. `regex` crate fully replaced. All 126 tests PASS with rgx backend. PCRE2-level regex features now available (look-around, backreferences, subroutine calls). Active PNT frontier: RGX-ADOPTION.3 (finalization).
- 2026-06-15: RGX-BUILD-REPRO.1 — rgx submodule pin bumped b771c7b→8763a0e. Upstream build fixes (BUILD-FLOW.1–.4) verified — cold-clone `make` succeeds. Tree COMPLETE and moved to Completed. No active task trees — PNT idle.
- 2026-06-15: RUST-FUNCTIONAL-PARITY.7–.10 — Tree COMPLETE (15 leaves). 80+ helpers. 126/126 PASS. Tree moved to Completed.
- 2026-06-15: Created RGX-BUILD-REPRO task tree — self-contained rgx build reproduction report for upstream. Active but blocked (`.1` pending upstream response). [RESOLVED — see above]
- 2026-06-15: RUST-FUNCTIONAL-PARITY.5.1 — Regex engine signoff-quality. Named capture extraction via Regex::capture_names(). 21 new tests. 117/117 PASS, zero warnings. Frontier → `.5.2` (lifecycle loop).
- 2026-06-15: RUST-FUNCTIONAL-PARITY.4.1 — Compiler signoff-quality. Added AcodeEntry/BcodeEntry structs (replaced opaque tuples). Fixed regex_idx tracking bug (was incorrectly incremented for action edges). Separated child_regex_idx from current-rule regex association. Fluent chains on blind edges stored as structured data. 6 new compiler tests. All 20 specs compile + serde roundtrip. 99/99 PASS, zero warnings. Frontier → `.5.1` (regex engine).
- 2026-06-15: RUST-FUNCTIONAL-PARITY.3.1 — Expression parser signoff-quality. Added Expr::FluentChain variant + FluentCall struct. Replaced broken fluent chain placeholder with recursive parse_fluent_chain(). Added boolean literal parsing (true/false with prefix-match guards). Added FluentChain interpreter support in engine.rs. Extended tests 9→51 (18 roundtrip, 5 error, 4 fluent chain, 5-level nesting). 93/93 PASS, zero warnings. Frontier → `.4.1` (compiler).
- 2026-06-15: RUST-FUNCTIONAL-PARITY.2.3 — rgx evaluation complete: API audit PASS, decision DEFER (rgx not on crates.io; cold-clone bootstrap needed). `.1.1`–`.2.3` all done. Frontier → `.3.1` (expression parser).
- 2026-06-14: PHASE9-RUST-VARIANT.10 — Finalization: tree COMPLETE (17 leaves). No active task trees — PNT idle.
- 2026-06-14: PHASE8-MULTI-BACKEND-HANDOFF.8 — Finalization: tree COMPLETE (8 leaves). Multi-backend specification surface complete.
- 2026-06-14: PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1 — Fixed 10 stale references. Tree COMPLETE (1 leaf).
- 2026-06-14: DOC-BOOK-SYNC.1 — Full mdBook + live docs audit complete. 19 gaps found (6 critical, 8 medium, 5 low) across 13 files.
- 2026-06-14: DOC-BOOK-SYNC.0 — Task tree creation for documentation/book sync. New active tree with 4 leaves.
- 2026-06-14: Completed LIFECYCLE-FAMILY-AUDIT.4 — Finalization: tree COMPLETE (4 leaves). All 7 lifecycle markers verified. No gaps found.
- 2026-06-14: Completed LIFECYCLE-FAMILY-AUDIT.1/.2 — inventory and gap analysis complete.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.5 — Finalization: tree COMPLETE (5 leaves). Roadmap, codebase, mdBook now synchronized. Tree moved to Completed. No active task trees remain — PNT idle.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.4 — audited and fixed mdBook drift. 7 stale claims fixed across 5 chapters. Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.5.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.3 — updated all 4 live docs after tracker sync. Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.4.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.2 — updated ROADMAP_V2.md and ROADMAP.md trackers. Method-like DSL migration track: mostly_done→done (COMPAT-ALIAS-RETIREMENT-V2, COMPAT-ALIAS-TEST-CLEANUP, FLUENT-BLOCK-EQUIVALENCE all completed). Overall roadmap: in_progress→mostly_done. Removed stale compat-alias and PLUGIN-ACTION-MIGRATION "remaining open" references. Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.3.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.1 — audited current empirical state. All 20 specs compile at zero compatibility-surface rules. Identified 2 stale ROADMAP_V2.md tracker rows (Overall roadmap, Method-like DSL migration track). Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.2.
- 2026-06-14: Completed COMPAT-ALIAS-RETIREMENT-V2.3 — tree COMPLETE (3 leaves). All 8 retirement-candidate aliases now removed from implementation. Short-term aliases already clean; medium-term legacy return helpers removed from all 7 files (~220 lines). No active task trees remain — PNT idle.
- 2026-06-14: Completed COMPAT-ALIAS-RETIREMENT-V2.1 — audit short-term aliases: implementation already clean across all 7 layers; USER_GUIDE.md updated (7 stale compatibility claims removed). Active PNT frontier: COMPAT-ALIAS-RETIREMENT-V2.2 (retire medium-term legacy return helpers).
- 2026-06-14: Completed FLUENT-BLOCK-EQUIVALENCE.2 — book documentation + regression verification. FLUENT-BLOCK-EQUIVALENCE tree COMPLETE (2 leaves). No active task trees remain — PNT idle.
- 2026-06-13: Completed MEDIUM-IMPACT.3.6 — MEDIUM-IMPACT tree closed out. Full regression verification.
- 2026-06-12: Completed MEDIUM-IMPACT.3.4.3 — cross-check re-run after AND ICODE routing fix. Cross-check: 1/20 match (was 10/20 before fix). AND fix correctly makes edges fire, but exposed MIXED_ACTIONS conflict: RuleIR routes AND I-block to acode_entries (acode_count=1) alongside bcode edge (bcode_count=1) → RuleIR returns MIXED_ACTIONS (invalid) → handler falls back to _default → empty @collect. New leaf .3.4.4 created to resolve MIXED_ACTIONS by keeping AND I-block separate from acode_entries and extending AND_BCODE handler. Frontier: MEDIUM-IMPACT.3.4.4.
- 2026-06-12: Completed MEDIUM-IMPACT.1.5 — JSON/AST diagnostic backend. `_emit_handler_json` serializes HandlerIR to valid JSON via JSON::PP. Backend threaded through SpecEntry.pm via `$BACKEND` package variable + `$deps->{backend}`. When `backend => 'json'`, `compile_spec_entry` stores JSON in `$info{handler_json}`; default `perl` path unchanged. 3/3 specs compile through default path. Active PNT frontier: `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending). No remaining eligible leaves in `.1` container — `.1` container is done.
- 2026-06-12: Completed MEDIUM-IMPACT.1.4 — Backend emitter interface. `%BACKEND_EMITTERS` dispatch table with `perl` default backend. `_emit_handler($ir, %opts)` dispatches by backend name. All 10 SpecEntry.pm call sites use `_emit_handler`. 20/20 specs compile through backend dispatch pipeline. Active PNT frontier: `MEDIUM-IMPACT.1.5` (JSON/AST diagnostic backend), `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending).
- 2026-06-12: Completed MEDIUM-IMPACT.1.3 — HandlerIR defined. 10 variant builders return IR hashrefs; `_emit_handler_perl()` dispatches 10 templates. SpecEntry.pm two-step flow. 452 lines dead code removed. 19/19 specs compile. Knowledge card `language-agnostic-backend-vision.md` captures future backend direction (Rust/Julia/Dart). Active PNT frontier: `MEDIUM-IMPACT.1.4` (backend emitter interface), `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending).
- 2026-06-12: Completed MEDIUM-IMPACT.1.2 — HandlerVariantEmitter extraction (commit `d53578a`). All 10 variant builders extracted to `perl/LinkedSpec/HandlerVariantEmitter.pm` (554 lines). SpecEntry.pm delegates variant building. Zero behavior change. Old dead code remains in SpecEntry.pm (follow-up cleanup leaf). MEDIUM-IMPACT.2 container complete (4/4 fuzzing leaves, commits `764c2f3`–`7425c8f`). MEDIUM-IMPACT.3.3 cross-check complete (commit `e2ea174`). MEDIUM-IMPACT.3.4 blocked (commit `29b4d38`). Active PNT frontier: `MEDIUM-IMPACT.1.3` (define HandlerIR), `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending).
- 2026-06-12 (hygiene): Backfilled commit hashes for 8 completed leaves, added 7 missing CHANGES.md entries, updated MEMORY.md latest_commit → d53578a, refreshed task-tree verification/commit log tables.
- 2026-06-12: Completed MEDIUM-IMPACT.3.3 — dual-path cross-check. Cross-check harness at `tools/cross_check_spec_parsers.pl`. 10/20 specs match (BNF, DT, Lispish, hlink_substitution, lib_reader, operators_try, pplugin, sdce, tkgui, verilog). 10/20 inflated candidate counts (ds_vhistory, ebnf, ifelse, portmap, regdef, simenv, spec.spec, tablegrep, tclite, vhdl). Root cause: AND handler lacks E-block, body_element:* over-matches. Zero hangs/crashes. Active PNT frontier: `MEDIUM-IMPACT.3.4` (fix cross-check gaps).
- 2026-06-12: Session bootstrap — task-tree restructure. MEDIUM-IMPACT.3 expanded 4→6 leaves: inserted dual-path cross-check (.3.3 compare, .3.4 fix gaps) before wiring primary (.3.5). Renumbered former .3.3/.3.4 → .3.5/.3.6. COMPAT-ALIAS-RETIREMENT tree completed and moved to Completed. MEMORY.md latest_commit fixed (d7294d0→4112374). Active PNT frontier: `MEDIUM-IMPACT.3.3` (dual-path cross-check: compare BootstrapSpec oracle vs spec.spec candidate across 20 specs).
- 2026-06-12: Completed MEDIUM-IMPACT.3.1 (post-commit bookkeeping). Task-tree administrative close-out: frontier updated (.3.2 now first eligible), commit log backfilled with `2526f2b` + hash-fix chain. Regression baseline: 1005 PASS. Active PNT frontier: `MEDIUM-IMPACT.3.2` (comment/blank-line skipping gap).
- 2026-06-12: Completed MEDIUM-IMPACT.3.1 — spec.spec accuracy audit. RuleIR.pm fix: per-regex ICODE→ACODE conversion for REP/OR rules ensures acode_count > 0. SpecEntry.pm fix: return→assignment transform for REP handlers so body_element loops correctly. spec.spec body_element made self-contained (9 inline alternatives, no bare helper calls). body_element now correctly returns array of matched body ASTs. Regression: 1005 PASS, spec.spec compile ratio 1.0000. Remaining gaps: body collection in rule_paragraph (AND handler lacks E-block support), comment/blank-line skipping (.3.2).
- 2026-06-11: Completed ACCUMULATOR-CONVENTION-AUDIT.3 and the ACCUMULATOR-CONVENTION-AUDIT tree (3/3 leaves) — synthesis + 6 recommendations. Key conclusion: the implicit-target `push(Child)` convention is healthy and serves a clear purpose. 95.5% of accumulator ops already use explicit targets; the 4 remaining convention-based uses are idiomatic. Recommendations: keep convention as-is, document in mdBook, teach `push_value` as preferred form. Tree moved to Completed. **No active task trees remain — PNT idle.**
- 2026-06-11: Completed ACCUMULATOR-CONVENTION-AUDIT.2 — per-spec accumulator usage categorization. 88 total accumulator ops across 19 specs: only 4 convention-based (4.5%) across 3 specs (regdef, tkgui, ebnf). 84 explicit-target (95.5%): 63 `push_value`, 19 fluent `.push()`, 2 `push_nonempty`. 10 specs use zero accumulators. Convention-based `push(Child)` is nearly extinct in practice. No code changes; phase0 1004 PASS baseline holds. Active PNT frontier: `ACCUMULATOR-CONVENTION-AUDIT.3` (synthesis + recommendations).
- 2026-06-11: Completed ACCUMULATOR-CONVENTION-AUDIT.1 — full ActionIR accumulator contract inventory. Audited all 9 accumulator-related contracts across `Contracts.pm` (call+dispatch + assignment+regex), `Scanner/PrimitiveBasicRules.pm` (push_child_call* scan rules), and `MethodLowering.pm` (push_value/push_nonempty lowering). Identified exactly 2 convention-based (implicit-target) helpers: `push(Child)` and `push(Child, idx)`. The other 7 require explicit target naming. Documented the `push(Child, arg)` integer-vs-word disambiguation edge case. Created `PLUGIN-ACTION-MIGRATION` task tree (proposed, parked per user request). No code changes; phase0 1004 PASS baseline holds. Active PNT frontier: `ACCUMULATOR-CONVENTION-AUDIT.2` (per-spec usage categorization).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.4 and the KNOWLEDGE-MAP-DOC tree (4/4 leaves) — verified end-to-end with `bash tools/run_ci_local.sh` (exit 0): memory-arch self-check → Knowledge Map check (facts valid, ids unique, map in sync) → `perl -c` → phase0 **`Files=1, Tests=1004, Result: PASS`** → "local CI gate passed". The Knowledge Map retrieval layer is now adopted, seeded (6 fact cards), and gated. LinkedSpec's full memory+retrieval stack: layers A–D (`MEMORY_ARCHITECTURE.md`) + the question-keyed `KNOWLEDGE_MAP.md` over `docs/knowledge/` cards, enforced by the dual pre-commit gate + the local CI gate. `docs/TASK_TREE.md` Active table is now empty (tree moved to Completed). **No active task trees remain — PNT idle** (proposed `PLUGIN-ACTION-MIGRATION` stays `proposed`).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.3 — wired the Knowledge Map gate. `.githooks/pre-commit` rewritten from `exec` (which would block any appended gate) into a dual gate: memory-arch self-check + KM regenerate/stage/`check_knowledge_map.sh`. `tools/run_ci_local.sh` now runs the KM check after the memory-arch check (+ `require_tracked_file` for the map + KM scripts). Reconciled the bootstrap pointers (AGENTS + CLAUDE/.cursorrules/copilot) to route to `KNOWLEDGE_MAP.md` and reverse the "not adopted" note; added `docs/decisions/0005` (adoption + archaeology boundary). Proved the gate bites (invalid card → exit 1; tampered map → exit 1; clean → 0). `perl -c` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `KNOWLEDGE-MAP-DOC.4` (full local-gate run + close).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.2 — seeded 6 verified durable-fact cards under `docs/knowledge/` (ActionRewriter-removed, thin-façade, phase0 ActionIR-ready invariant, hosted-CI-disabled, spec.spec self-hosting, AND++LX hang gotcha). Each fact verified true against the repo before its `reverify` was written. Regenerated `KNOWLEDGE_MAP.md` → 6 facts / 29 question keys; `check_knowledge_map.sh` OK (fields valid, ids unique, map in sync). `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `KNOWLEDGE-MAP-DOC.3` (wire the KM gate into pre-commit + run_ci_local, reconcile bootstrap pointers, add ADR 0005).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.1 — began adopting the Knowledge Map retrieval layer. Vendored the `knowledge-map/` bundle verbatim at the repo root (`diff -r` identical to source), ran `knowledge-map/install.sh` (created `docs/knowledge/`, generated the derived `KNOWLEDGE_MAP.md`; check reports in-sync). Wired README discovery (Knowledge Map bullet + path map) and reconciled the `MEMORY_ARCHITECTURE.md` §5 note from "not adopted" to "adopted". New active tree `KNOWLEDGE-MAP-DOC` (4 leaves). `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `KNOWLEDGE-MAP-DOC.2` (seed durable-fact cards).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.5 and the MEMORY-ARCHITECTURE-DOC tree (5/5 leaves) — verified end-to-end with `bash tools/run_ci_local.sh` (exit 0): the memory-architecture self-check runs **first** (all invariants hold), then `perl -c`, then phase0 **`Files=1, Tests=1004, Result: PASS`**, then "local CI gate passed". The durable, harness-agnostic agent-memory architecture is now adopted and enforced: layer A (`MEMORY.md` bounded resume pointer) / B (`docs/tasks/` task-trees) / C (`docs/decisions/` records) / D (git), reachable from `AGENTS.md` + `README.md` + `MEMORY_ARCHITECTURE.md`, with E1–E4 gates (`scripts/check_memory_architecture.sh`, `.githooks/` via `core.hooksPath`, and the local CI gate). `docs/TASK_TREE.md` Active table is now empty (tree moved to Completed). **No active task trees remain — PNT idle** (proposed `PLUGIN-ACTION-MIGRATION` stays `proposed`).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.4 — installed the `MEMORY_ARCHITECTURE.md` §9 enforcement: `scripts/check_memory_architecture.sh` (E2), `.githooks/pre-commit` + `.githooks/commit-msg` (E3, activated via `git config core.hooksPath .githooks`, with a linkedspec-adapted subject regex), the four bootstrap pointers `AGENTS.md`/`CLAUDE.md`/`.cursorrules`/`.github/copilot-instructions.md` (E1), and the self-check wired as the first gate in `tools/run_ci_local.sh` (E4). Proved all four gates bite (self-check fails over-cap; commit-msg rejects non-compliant subjects, accepts unit-id/Docs:/Merge/body-line-id) after fixing a POSIX-ERE `\b` bug. `bash -n` clean on all shell files; self-check exit 0; `perl -c` OK; phase0 1004 PASS baseline holds. Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.5` (full local-gate run + close).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.3 — demoted `MEMORY.md` from a 5204-line cumulative log to the 25-line bounded overwrite-only resume pointer (memory layer A, `MEMORY_ARCHITECTURE.md` §6 template); the prior history stays in git (`git show HEAD:MEMORY.md` confirms 5204 lines preserved). Reconciled `COMMIT.md` (the `### 4) MEMORY.md` section + workflow step 2 now define MEMORY.md as overwrite-only/capped, not cumulative) and the README ramp-up entry. `wc -l MEMORY.md` = 25 (≤ cap 60); `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.4` (install the enforcement kit: self-check + hooks + CI wiring + bootstrap pointers).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.2 — created `docs/decisions/` (memory layer C) with `INDEX.md` and 4 dated ADR records: 0001 task-tree/commit/zero-drift doctrine (migrated out of harness-home-directory memory into the tracked repo so it survives a harness/model switch), 0002 all-target ActionIR-ready phase-0 invariant, 0003 raw-Perl-free `.spec` policy, 0004 hosted-CI-disabled / local-gate-is-source-of-truth. INDEX matches the 4 files. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.3` (demote MEMORY.md to the bounded resume pointer + reconcile COMMIT.md).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.1 — added the harness-agnostic durable-memory standard `MEMORY_ARCHITECTURE.md` at the repo root (verbatim from the cross-project source; the optional Knowledge Map layer is explicitly not adopted here) and wired discovery via `README.md` (Documentation Layers + ramp-up + path map) and `SESSION_BOOTSTRAP.md`. New active tree `MEMORY-ARCHITECTURE-DOC` (5 leaves) registered in `docs/TASK_TREE.md`. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.2` (create `docs/decisions/` layer C + seed records).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.5 and the DOC-CODEBASE-ALIGNMENT tree (5/5 leaves) — synced `ROADMAP.md`'s live-status tracker with `ROADMAP_V2.md`/reality. 13 stale rows flipped (Phases 1/1A/2/3/4/5/6/7 → `done`, Backbone refactor track + Item 3 → `done`, Method-like track → `mostly done`, Plugin track → `done`; Overall stays `in progress` with a refreshed focus note), each "Remaining focus" cell trimmed to a concise task-tree-referenced note. Annotated the Phase 1A planning section that `ActionRewriter.pm` was deleted in Phase 1. All 15 shared phase/track statuses now match `ROADMAP_V2.md`; every ROADMAP.md ActionRewriter mention is historical. `docs/TASK_TREE.md` Active table is now empty (tree moved to Completed). `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). **No active task trees remain — PNT idle** (proposed `PLUGIN-ACTION-MIGRATION` stays `proposed`, not PNT-eligible).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.4 — reconciled `ROADMAP_V2.md`'s Phase 1A row so the deleted `ActionRewriter.pm` reads as historical (later deleted in Phase 1) rather than a live `LinkedSpec::OwnerDispatch` seam participant; the Phase 1 row's deletion record is untouched. While doing this, discovered `ROADMAP.md`'s status-tracker table is frozen at an early state (Phases 1, 1A, 2, 3, 4, 5, 6, 7, Backbone all stale vs `ROADMAP_V2.md`/reality) and split that broader reconciliation into new leaf `DOC-CODEBASE-ALIGNMENT.5`. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.5` (sync ROADMAP.md tracker).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.3 — scrubbed deleted-`ActionRewriter.pm` live claims from `USER_GUIDE.md` (7 references across two clusters). It had presented ActionRewriter as a retained compatibility-wrapper module; now framed as a forwarding shim deleted in `PHASE1-PARSER-CORE-ISOLATION.2`, with `RuleIR::EmitContext::rewrite_action_code_for_compat(...)` as the focused entrypoint. Dropped two misleading "ActionRewriter-facing" labels and corrected the `LinkedSpec::Deps`-removed note. `docs/linkedspec-book/` was already clean. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.4` (reconcile ROADMAP.md / ROADMAP_V2.md).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.2 — refreshed `ARCHITECTURE_STATE.md` so the deleted `perl/LinkedSpec/ActionRewriter.pm` is no longer presented as a live owner-dispatch participant (deleted in `PHASE1-PARSER-CORE-ISOLATION.2`; compat entrypoint now `RuleIR::EmitContext::rewrite_action_code_for_compat(...)`). Updated Last-refreshed date + refresh note, rewrote the "thinner now" bullet to "deleted entirely", dropped it from the seam-sharing list. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.3` (USER_GUIDE.md + book scrub of the same stale claim).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.1 — reconciled `docs/TASK_TREE.md` index with the real `docs/tasks/*.md` statuses found during session bootstrap. New active tree `DOC-CODEBASE-ALIGNMENT` registered (frontier `.1`); stale `PHASE7-SELF-HOSTED-SPEC` "active" row removed (file is `done`); Completed table gained `PHASE7-SELF-HOSTED-SPEC`, `PHASE1-PARSER-CORE-ISOLATION`, `METHOD-LIKE-DSL-MIGRATION`, `BOOK-DOCUMENTATION-SYNC`. Sub-drift fixed: `PHASE3/4/5` metadata `Status` `active`→`completed` to match their top nodes. All 13 trees now indexed under a status-matching table. Baseline (no code changed): phase0 Files=1, Tests=1004, PASS. Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.2` (refresh `ARCHITECTURE_STATE.md` — remove deleted-`ActionRewriter.pm` live references).
- 2026-05-18: Updated ROADMAP_V2.md stale statuses — Phase 1 `mostly done` → `done` (PHASE1-PARSER-CORE-ISOLATION complete, 3/3 leaves). Backbone refactor track `mostly done` → `done` (all 3 items done). Removed stale Phase 1 reference from Method-like DSL migration track remaining-open list.
- 2026-05-18: Completed PHASE1-PARSER-CORE-ISOLATION.3 — evaluated rewrite_action_code_for_compat fallback in EmitContext.pm. Canonical pipeline handles s()/a()/h() correctly inside recognized contracts. The fallback only triggers for bare standalone s/a/h (malformed action code — no shipped .spec hits this path, no test exercises it). Fallback retained with inline documentation as a 20-line defensive compatibility measure. PHASE1-PARSER-CORE-ISOLATION tree COMPLETE (3 leaves). Full suite: 1004 PASS.
- 2026-05-18: Completed PHASE1-PARSER-CORE-ISOLATION.2 — removed ActionRewriter.pm forwarding shim. 118-line file deleted (59 generated forwarders + call_spec_handler_subst). 451 test references updated: 217 LinkedSpec::ActionRewriter:: → LinkedSpec::RuleIR::EmitContext::, 13 call_spec_handler_subst → rewrite_action_code_for_compat, 6 ActionRewriter-specific subtests removed. 10 broken require_avoids assertions fixed (EmitContext self-checks, plan mismatches, Deps check). Zero ActionRewriter references remain in codebase. Full suite: 1004 PASS. Active PNT frontier: PHASE1-PARSER-CORE-ISOLATION.3.
- 2026-05-17: Completed PHASE1-PARSER-CORE-ISOLATION.1 — full compile-path compatibility seam inventory. 4 seams identified: ActionRewriter.pm (118 lines, 59 forwarders, 0 non-test callers → REMOVABLE), rewrite_action_code_for_compat (s/h/a fallback → NEEDS EVALUATION), output format conversions (intentional adapters → KEEP), PluginBridge legacy functions (runtime, not compile path → OUT OF SCOPE). Active PNT frontier: PHASE1-PARSER-CORE-ISOLATION.2.
- 2026-05-17: Completed BOOK-DOCUMENTATION-SYNC (3 leaves) — synced book chapters with current codebase state. Updated plugin-registry.md stale deprecation status note ("may be narrowed or deprecated in a future phase" → DEPRECATED with PLUGIN-MODERNIZATION reference and retirement path). Updated owner-tree.md legacy plugin branch with individual DEPRECATED annotations on all 7 facade methods. Verified pplugin-spec-walkthrough.md ready_ratio note accurate, full 33-chapter book sweep found no additional stale references, USER_GUIDE files (10) clean. BOOK-DOCUMENTATION-SYNC tree COMPLETE (3 leaves).
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.5 — defined extension-surface policy. spec.spec is the required change surface for .spec language evolution. Bootstrap grammar changes are exception-only with explicit justification. Policy documented in spec.spec header (extension-surface policy section, exception criteria, known bootstrapping gaps) and DEVELOPMENT_NOTES.md (formal policy section with rationale, exception path, and gap inventory). PHASE7-SELF-HOSTED-SPEC tree COMPLETE (5 leaves). Full suite: 1010 PASS.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.4 — fixed AND++LX parser hang and added regression coverage. The generated spec.spec parser hung on AND++LX: LX fires after AND+ loop completion but its execution triggers loop re-entry. Replaced `LX {return(...)}` with `E {return(...)}` in spec_file (E fires after rule completion without late-exit re-entry). Added 3 regression subtests (15 assertions): no-hang parse of 6 shipped .spec files, structural element recognition (minimal input + self-parse + lifecycle/blind-edge specs), and language_agnostic_ready_ratio lock at 1.0000. Known bootstrapping gap: no top-level comment/blank-line skip rule — workaround strips leading comments in tests. Full suite: 1010 PASS. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.5`.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.3 — extended body_element:* from 5 to 9 regex-anchored alternatives covering all 12 body element recognition patterns from .1 inventory. Added: conditional markers (`-? word`), lifecycle markers (`(?:I|LS|LE|LX|E|EX|IT)\b`), fluent chains (`\.[ \t]*\w+`), word-based catch-all (`\w+[ \t]*[\(\{\.]`). 9 alternatives: regex, action edge, blind edge, split marker, conditional marker, lifecycle marker, fluent chain, word-based body code, plain code block. language_agnostic_ready_ratio 1.0000. Full suite: 1007 PASS. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.4`.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.2 — authored spec.spec structural/syntactic rule paragraphs. 3 rules: spec_file::AND+ (top-level, edge-delegates to rule_paragraph), rule_paragraph:AND (own header regex /(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)/ + delegates to body_element), body_element:* (5 regex-anchored alternatives for regex tokens, action edges, blind edges, code blocks, split markers + 2 subdefs: body_edge_ast, body_blind_edge_ast). Compiles with language_agnostic_ready_ratio 1.0000. Full suite: 1007 PASS. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.3`.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.1 — surveyed .spec language surface. 37 syntax categories across 9 sections: rule label forms (body/top), 11 rule mode variants (AND/OR/&/\|/+/*/? with bounded/unbounded/shorthand), 12 body element patterns, 7 lifecycle markers, 4 split/capture markers, ~40+ ActionIR helper functions, block structure, and authoring styles. Created leaves .2–.5. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.2`.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.5 — evaluated PPlugin/PluginBridge retirement feasibility. 36 .plg files with ~1,200+ actions remain — cannot retire yet. Documented 5-step retirement path: (1) migrate .plg actions to package owners, (2) retire PPlugin, (3) reduce/delete PluginBridge, (4) remove deprecated facade methods, (5) migrate FSMGen::AUTOLOAD. PluginRegistry can survive independently. PLUGIN-MODERNIZATION tree COMPLETE (5 leaves). Proposed follow-on: `PLUGIN-ACTION-MIGRATION`. No active trees — PNT idle.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.4 — deprecated all 7 legacy plugin facade methods in LinkedSpec.pm (register_plugin, register_plugins, clear_registered_plugins, run_plugin, get_plugin, dispatch_plugin_autoload_name, AUTOLOAD). All marked DEPRECATED with retirement timeline tied to PLUGIN-MODERNIZATION.5. None removable yet: FSMGen::AUTOLOAD still depends on dispatch_plugin_autoload_name, test regression locks still exercise plugin infrastructure. Full suite: 1007 PASS. Active PNT frontier: `PLUGIN-MODERNIZATION.5`.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.3 — de-scoped FSMGen.pm from LinkedSpec::get_plugin dependency. Replaced `\&LinkedSpec::get_plugin` default with `sub {}` no-op in getop_plugin_list (FSMGen.pm:68). Internal caller at line 3054 passes no explicit get_plugin but no .fsm files exist in repo to trigger +type=plugin syntax. Tests always pass explicit get_plugin. Updated 2 regression assertions. Full suite: 1007 PASS. Active PNT frontier: `PLUGIN-MODERNIZATION.4`.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.2 — removed 2 dead .plg files: hutils.plg (thin HUtils:: passthroughs, zero references) and quick_sdf_hack.plg (dead qsdf_hack action, zero external callers). 36 .plg files remain. Full suite: 1007 PASS. Active PNT frontier: `PLUGIN-MODERNIZATION.3`.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.5 — bridged book and USER_GUIDE cross-linking.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.3 — documented Validation.pm (1,368-line DSL validation module). Expanded ARCHITECTURE_STATE.md section from 4 bullets to 30-line entry covering all 5 public entry points with error reporting path, context helpers, strict_syntax mode, and debugging guidance. Expanded book pipeline-overview.md Stage 2 from 4 lines to 16-line structured description of three validation layers. Active PNT frontier: `PHASE6-DOCUMENTATION.4`.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.2 — documented LinkedRE.pm (56-line core regex utility). Added 11-line section to ARCHITECTURE_STATE.md covering or/oredRE API, position-tracking, seek vs consume, three consumers, and OwnerDispatch loading. Added 3-line explanatory note to book's generated-handlers-and-dispatch.md. Active PNT frontier: `PHASE6-DOCUMENTATION.3`.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.1 — documentation surface inventory. Audited 30 mdBook chapters (all substantive, zero stubs), 10 USER_GUIDE files (14,611 lines of ActionIR lowering detail), 6 live docs, ARCHITECTURE_STATE.md, README.md. Found 7 doc gaps: LinkedRE.pm zero docs, Validation.pm thin (1 paragraph for 1,368 lines), public API incomplete (2/4 bands), book/USER_GUIDE silos, overview chapters thin, ActionIR lowering thin, per-spec walkthroughs incomplete. Created 7 follow-on leaves (.2–.8). Active PNT frontier: `PHASE6-DOCUMENTATION.2`.
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.4 — verified BACKTRACK+parse_mode interaction already covered by .2 and cross-referenced in .3. PHASE3-EXECUTION-SEMANTICS tree COMPLETE (4 leaves). ROADMAP_V2.md Phase 3 → `done` (2026-05-17).
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.3 — added "Forward-moving, non-backtracking model" subsection to rule-modes-and-parse-modes.md. States parser engine is forward-moving, no search tree, no partial-match unwind, no systemic backtracking. BACKTRACK/IBACKTRACK are sole rewind. 18-line prose addition.
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.2 — added "BACKTRACK and IBACKTRACK: local cursor rewind" subsection (22 lines) to source-boundary-helper-reference.md. Covers concrete pos() rewinds, parent vs inner match distinction, local rewind vs systemic backtracking distinction, parse_mode interaction after rewind, and label-argument compatibility.
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.1 — full parse-mode surface inventory. Audited 8 implementation components (LinkedRE.pm, Compiler.pm, SpecEntry.pm, CompilerState.pm, Runtime.pm, ActionIR/Contracts.pm, Scanner/LegacyRules.pm, CanonicalEvents/Core.pm), reviewed 5 book chapters, analyzed test coverage. Found 3 documentation gaps (BACKTRACK local-rewind contract, non-backtracking model statement, BACKTRACK+parse_mode interaction). Created follow-on leaves .2/.3/.4. Full suite: Files=1, Tests=1007, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.3 — added `strict_syntax` option to `validate_dsl_syntax` (Validation.pm lines 719-741). When set, undefined rule references and unused rules are promoted from warnings to hard errors. Default off (backwards compatible). Added 3 regression subtests (14 assertions). All 19 shipped specs fail strict mode as expected (every top rule is unreferenced by convention). PHASE2-DSL-FRONTEND tree now COMPLETE — all 6 leaves done. Full suite: Files=1, Tests=1007, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.5 — expanded extra-colon rule-label rejection regression coverage. The existing `_parse_rule_label_line` `invalid_mode` flag already rejected all extra-colon patterns; expanded regression test from 1 case to 14 edge cases (triple/quadruple colons, colon-space-colon variants, mode-suffix+colon, bounded-OR+colon, tab separators). Full suite: Files=1, Tests=1004, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.4 — closed the inside-block rule-start detection gap. Added explicit rejection in `validate_dsl_syntax` (Validation.pm lines 611-620): when `edge_scan_depth > 0`, a line matching the rule-label pattern triggers "Rule definition not allowed inside open block." Updated 2 existing tests, added 5 new regression subtests (bare rule label, top-rule label, mode-suffix labels, non-rule-label content acceptance, nested blocks). Verified zero shipped specs affected. Full suite: Files=1, Tests=1004, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.6 — verified and regression-locked full fluent-continuation surface recognition. Added 4 regression subtests (20 assertions) to `t/phase0_regression.t`: all 7 lifecycle markers with fluent chains (I/LS/LE/E/EX/IT/LX), deeply nested 5+ call chains with parens, quoted args with nested function calls, and empty-args fluent chain method calls. Full suite: Files=1, Tests=999, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.2 — closed the `validate_dsl_syntax` / `bootstrap_parse` construct-recognition drift gap. Compared `_looks_like_supported_rule_paragraph_member_line` acceptance patterns against all 14 bootstrap grammar start-token regexes. Added 6 regression subtests (20 assertions) to `t/phase0_regression.t`: zero-arg flow markers with blocks, method-empty blind-code-block fluent chains, lifecycle fluent-chains with attached if/elseif/else, three-target grouped action-edges, action-edges with regex-slot index plus fluent chain, and a full 19-shipped-specs validation regression lock. Full suite: Files=1, Tests=995, PASS.
- 2026-05-11: Broadened the shipped `.plg` source lock to reject direct `LinkedSpec::get_plugin(...)`, `LinkedSpec::run_plugin(...)`, and `LinkedSpec::dispatch_plugin_autoload_name(...)` plugin-bridge dispatch calls; renamed the plugin-corpus regression to name the package-owner destination.

## Recent Completed Slices
- Plugin/resource-resolution modernization: Broaden shipped `.plg` source lock against direct plugin-bridge dispatch helpers.
- Plugin/resource-resolution modernization: Lock shipped `.plg` files off direct `LinkedSpec::get_plugin(...)` lookups.
- Phase 1A / Backbone Item 3: Remove unused final descriptor projection helper from `Compiler.pm`.

## Doctrine
- 2026-05-17: Task-tree-ownership doctrine codified. All code changes must be task-tree tracked or task-tree owned before implementation. Recorded in book chapter `development/local-ci-and-regression.md`. Non-negotiable.

## Next Slice Direction
- Active PNT frontier: `SPEC-FORMAT-TERSE.1.3.2` — array function spelling disambiguation for terse mutation (`push(name,value)` vs existing child-call `push(...)`) before any engine code.
- ROADMAP_V2.md statuses synchronized with completed task trees. Phase 1, Backbone refactor track now `done`.
- PHASE1-PARSER-CORE-ISOLATION tree COMPLETE (3 leaves). ActionRewriter.pm removed, rewrite_action_code_for_compat evaluated and documented.
- PLUGIN-ACTION-MIGRATION tree **retired** — all 5 leaves done; 17 dead files deleted; 19 kept as legacy corpus. Plugin migration workstream closed.
- BOOK-DOCUMENTATION-SYNC tree COMPLETE (3 leaves).
- METHOD-LIKE-DSL-MIGRATION tree COMPLETE (5 leaves). All 19 shipped specs at zero compat. Cross-nesting parity deferred. Open items: compat alias retirement (policy defined). PLUGIN-ACTION-MIGRATION retired.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.5 — cross-nesting parity formally deferred, tree COMPLETE (5/5 leaves).
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.4 — missing DSL features inventory. No concrete gaps in shipped corpus.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.3 — convention-based accumulator audit. 4 conventions audited, zero helpers needed.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.2 — legacy return-helper cleanup. 4 categories audited, zero migrations needed.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.1 — compatibility alias retirement policy audit. 11 aliases inventoried, policy in DEVELOPMENT_NOTES.md.
- PHASE7-SELF-HOSTED-SPEC tree COMPLETE (5 leaves).
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.5 — defined extension-surface policy.
- 2026-05-17: Activated METHOD-LIKE-DSL-MIGRATION task tree — Method-like DSL migration track was `in progress` without task-tree ownership. Created tree with 5 leaves.
- 2026-05-16: Completed PHASE1A-CLOSE-OUT.1 — audited Phase 1A modularization. LinkedSpec.pm is a 286-line thin facade; 18 extracted modules use uniform OwnerDispatch; no monolith-era patterns remain.
- PHASE2-DSL-FRONTEND tree COMPLETE (all 6 leaves).
