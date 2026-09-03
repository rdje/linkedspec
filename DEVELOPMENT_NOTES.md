# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`
- 2026-09-03 (`FUTURE-PARITY-BACKLOG.19.5.2` — Julia `map_leaves!`): keep bang syntax in one dedicated parser
  path. Do not allow `!` in ordinary identifiers or callees; typed receiver/mutation/callback/continuation state is
  required to preserve addressability, transaction ordering, and exact authored spans.
- A receiver guard must key a stable visible-binding identity. Ordinary rebinding retains identity, while callback
  frames and user-function parameters get fresh identities and restore any shadow afterward. Text equality is not
  enough to distinguish forbidden receiver writes from legal same-spelling locals.
- Reject at the write owner before evaluating any operand, selector, or RHS. Julia now applies that ordering to
  assignment, append, nested write/bang, explicit mutation helpers, array-end methods, regex substitution, and all
  binding-target array pipelines—including the three pipelines whose ordinary write-back remains separately owned.
- Traverse only a deep-copied original shape under its root kind. Copy callback `value` and `path`, detach callback
  results, never revisit replacement aggregates, publish the rebuilt binding once, and release the guard in
  `finally` before any ordinary continuation.
- Direct callback blocks are not generic delayed codeblock values. Execute their typed `ActionBlock` in fresh
  scoped bindings and catch callback-local `return` at that boundary so it cannot escape the traversal.
- Refactoring fluent continuation into a value-call owner keeps bang continuation post-commit and detached while
  preserving ordinary fluent semantics. Binding-mutating array-end methods remain addressability-dependent and
  yield no detached continuation mutation.
- Permanent proof passes 496 assertions across syntax, runtime, composition, malformed state, reconstruction,
  generated plan, emitted module, and CLI. Julia's 22nd temporary owner remains under managed repository-local
  `TMPDIR`; no off-volume path or generated-format change was introduced.
- Derive storage-oracle success cardinality from its already-compared expected-owner array; the substantive 22/22
  check was correct while a literal success string still said 21. The complete change record also triggers
  content-addressed history segment `4986`; ADR `0100` raises only finite collection/manifest routing to 27/26.
- A typed-carrier validator must not dispatch solely on the caller-controlled `kind` value it is validating.
  Recognize the receiver/mutation/continuation structure independently, then require the exact node kind; otherwise
  a programmatic malformed node can skip the intended fail-closed boundary.
- Pre-evaluation guards must not broaden an ordinary helper's mutation arity. Inspect a three-argument
  `substr`/`regex_subst` target early enough to reject the active receiver, then return to the existing pure or
  unsupported path unless the four-argument statement-mutation signature is present.
- The exact control remains `Top:: -> Done`: entering `Top` starts its loop, whose outgoing edge selects and
  matches `Done`'s regex. Adding a regex to `Top` would be inert here and would weaken this semantic proof.
- 2026-09-03 (`FUTURE-PARITY-BACKLOG.19.5.1` — Julia write vivification): one typed
  `ActionAssignNestedAccessExpr` must own authored one- and many-segment bracket assignment. Each
  `ActionWritePathSegment` retains its ordinary expression plus source/span; authored spelling must not preselect
  harray versus array before evaluation.
- Julia evaluation and publication are separate phases: evaluate every segment left-to-right and then the RHS,
  inspect binding presence afterward, deep-copy the post-evaluation root, validate/build the complete dense path,
  then publish exactly once. This preserves completed expression effects without exposing a partial path.
- Track absence separately from value. An absent root/intermediate may be created from the current/next evaluated
  selector; bound null and wrong kinds are conflicts. A string selects harray, a nonnegative integer other than
  `Bool` selects array, and arrays may replace or append at length but never invent gap fillers.
- Copy mutable boundaries deliberately: current root, aggregate RHS, stored tree, returned tree, and diagnostic
  path prefix. Expression failures keep their original exception identity; structural failures use the frozen
  typed fields and authored failing-segment span.
- Validate public typed carriers at compiler, direct-runtime, generated-plan, and source-emitter seams. Parser-only
  checks do not protect reconstructed or programmatically corrupted state.
- Permanent Julia proof consumes the neutral fixture directly and passes 406 assertions across native,
  reconstructed, generated-plan, emitted-module, and CLI routes. The complete Julia package suite, primary CLI,
  corpus 105/105, neutral 105 mutations, and repository-local storage boundary pass.
- A passing checker can still print stale evidence: the storage script compared 21 expected paths with 21
  discovered paths but printed a hard-coded 20. Keep displayed cardinalities synchronized with their substantive
  inventories; the rerun reports 21 temporary owners and five locked package trees.
- Current task registries and adjacent book statements are live projections, not dated history. This slice repairs
  the stale pre-Dart task frontier and two Dart-bang sentences while leaving historical boundary claims intact.
- 2026-09-02 (`FUTURE-PARITY-BACKLOG.19.4.2` — Dart `map_leaves!`): parse this surface before ordinary fluent
  methods and retain a dedicated receiver/callback/continuation carrier through compiler, reconstruction,
  generated-plan, emitter, independent-caller, CLI, and runtime boundaries. Generic method lowering cannot
  preserve its addressability, atomicity, guard, and diagnostic contract.
- The receiver guard must key stable binding identity, not variable spelling. Ordinary writes retain a binding's
  identity; fresh function parameters and callback-local bindings receive distinct identities and restore any
  shadowed identity at scope exit.
- Traverse a deep copy of the original root under root-kind rules, copy every callback field, collect detached
  replacement results, and publish once. Always release the guard in `finally`; release it before continuations so
  a later continuation observes the committed root and cannot roll it back.
- Guard at the write owner before evaluating operands, path segments, or RHS expressions. The Dart coverage spans
  assignment, append, nested write/bang, `set`/`set_key`/`push`/`split`, array-end methods, regex substitution,
  and all binding-target array pipelines.
- Do not repair an adjacent behavior while instrumenting its guard. Dart still lacks ordinary statement write-
  back for `split_each`, `filter_match`, and `uniq`, owned by `FUTURE-PARITY-BACKLOG.5`; the guard recognizes those
  authored attempts only while the target identity is active.
- Rule selection and regex matching are different operations. `Top:: -> Done` enters `Top` and lets its loop
  select `Done`'s regex; a `/x/` owned by `Top` has no role in that edge. The composition fixture's stale parent
  regex masked this proof and was removed without changing expected observations or inventory cardinality.
- Complete Dart evidence is format 111/0, strict analysis, 461/461 tests, 25 managed temporary owners / 47 locked
  packages, CLI 66/66 in default and POSIX environments, and corpus 105/105. The neutral authorities retain 167
  base + 592 composition mutations and 105 write mutations.
- 2026-09-02 (`FUTURE-PARITY-BACKLOG.19.4.1` — Dart write vivification): authored one-segment and multi-segment
  writes must share the same typed carrier. Keeping `ActionAssignHashIndexExpr` only for programmatic/legacy input
  prevents authored spelling from deciding harray versus array before the selector evaluates.
- `ActionWritePathSegment` carries the ordinary typed expression plus exact segment source/span. Segment/RHS
  parsing uses Unicode-scalar offsets, including astral text, so Dart code-unit indexing cannot leak into the
  cross-backend diagnostic contract.
- Evaluation and structural publication are separate phases: evaluate all segments left-to-right once, evaluate
  RHS once, then inspect binding presence and clone the post-evaluation root. Build only on that clone and publish
  once. This retains same-binding expression effects while forbidding a partial structural path.
- Absence is not null. An absent root can be selected from the first string/nonnegative-integer segment; an
  explicitly bound null or wrong-kind value is a conflict. Missing intermediates use the next selector, and arrays
  replace or append exactly at length but never synthesize gap fillers.
- Every mutable ingress/egress is copied: initial aggregate, aggregate RHS, committed binding, returned root, and
  diagnostic path prefixes. Expression failures preserve their original exception identity; structural failures
  use the frozen typed fields and authored failing-segment span.
- Validate the typed carrier at each executable boundary, not only source parse. Dart rejects malformed segment
  records before direct runtime, generated-plan, or emitted-source execution, while `SpecFile` reconstruction
  preserves the same valid node.
- The independently emitted-source test uses a repository-managed caller package and analyzes/executes that fresh
  package. This proves emitted Dart as a consumer rather than merely comparing source text.
- The first complete Dart gate correctly detected a project-data inventory change: the new permanent test is the
  24th `Directory.systemTemp` owner. Registering that exact owner restored the 24-owner / 47-package storage gate;
  no off-volume default or unmanaged temporary path was added.
- Full Dart proof is format 110/0, strict analysis, 450/450 tests, CLI 66/66 twice, and corpus 105/105. The neutral
  contract remains 5/7/11/16/3/3 plus 105 rejected mutations. Dart `map_leaves!` stays owned by `.19.4.2`; Julia,
  Lua, recurring cross-backend proof, and portable/public admission remain later leaves.
- Exact staged canonical attempt one passes every preceding cross-backend admission through punctuation-light
  behavior, then catches `check_public_aggregate_selector_surface.py` at 62 discovered files versus a stale 61.
  Clean commit `1247316d` had added the macOS Rust launch-latency mdBook page without advancing that unrelated
  cardinality guard. The checker, current mdBook status, and both selector-public Knowledge owners now lock 62
  while the semantic inventories remain 32 classified removed/history references and zero current examples; the
  final staged candidate restarts canonical proof from the beginning for a matching receipt.
- 2026-09-02 (`FUTURE-PARITY-BACKLOG.19.3.4.0` — macOS Rust launch classification): always time compile/link,
  first inventory launch, and test execution separately. `BINARY --list` removes test bodies from the question;
  process census then distinguishes an unstarted program from slow runtime work.
- Two older distinct `trace_controls` hashes reproduced 45.32/51.75-second first inventory launches and immediate
  0.00/0.00-second warm launches. The Rust process was not visible while `syspolicyd` consumed CPU, consistently
  with the prior `_dyld_start` sample: macOS policy assessment delayed process entry before Rust `main`.
- Provenance and ad-hoc linker signing are observations, not causes by themselves. Two unique isolated builds
  retained both conditions and completed in 37.18/23.17 seconds. The first hash's signed-copy/original comparison
  ran in 0.44/0.45 seconds; the second wholly unmanipulated hash ran in 0.41 seconds. High `syspolicyd` CPU alone
  was likewise insufficient to reproduce the long delay.
- The original canonical interval also contained independently observed target deletion plus `cargo sweep` from
  another process. Do not treat that contaminated cold-build duration as compiler/cache evidence, and never
  delete another owner's target while a gate is running.
- The controlled result classifies external per-artifact macOS policy/cache state without a persistent
  repository-controlled defect. Re-signing, clearing provenance, weakening Gatekeeper, prelaunching binaries,
  moving caches, or reducing tests would be speculative; `.19.3.4.1` is correctly not required.
- 2026-09-01 (`FUTURE-PARITY-BACKLOG.19.3.3` — oracle/root dispatch repair): never rebase a committed oracle
  expectation until live reference execution and the frozen consumer have been compared at the source/projection
  seam. Here Rust preserved the rich record while Perl returned null only because a typed helper diagnostic caused
  the child entry to be skipped; selector/dispatch semantics were not the cause.
- Local-match typed projections must distinguish absence from zero width. Structural length/start/end values are
  null when `$LMATCH` or `$LSPOS` is absent, display lines/columns retain the one-based default `1`, and a defined
  empty match at offset zero remains concrete. Guarding on defined state rather than truth preserves that split.
- Exact generated-lowering assertions are part of the repair surface. Canonical Phase 0 retained three pre-repair
  expected strings for `match_start_pos()`, `match_len()`, and `match_end_pos()`; align them only after direct
  substitution proves the emitted two-register guard. The corrected complete file passes 1,032/1,032.
- Output-equivalent fixtures can hide an executor defect. The old `Top:: /x/ -> Done` controls could succeed by
  matching the inert parent `/x/` even though the language says the parent loop selects `Done`'s regex. Removing
  the parent regex while keeping every expected byte unchanged turns the corpus into a real semantic proof.
- Keep both trace directions. Direct entry is lifecycle-positive and regex-negative; zero-regex parent dispatch is
  target-slot-positive, child-entry-positive, and has exactly one successful regex match. The compiled authored
  slot inventory plus `target_rule` trace prevents a coincidental final value from satisfying the test.
- The neutral corpus-source guard owns fixture shape independently of a backend. Runtime confidence then comes
  from executing the same 105 files through Rust, Dart, Julia, PUC Lua, and LuaJIT after two byte-stable Perl
  generations.
- Full cross-backend execution must not be reduced to only the changed fixtures. It exposed two unrelated but
  release-blocking standalone-lifecycle gaps: Dart/Julia checked for a fluent argument `(` before skipping legal
  whitespace, and Dart's bounded self-host regex bridge had never gained the complete-line `blkLBL`/`blkSLB`
  families added later to `spec.spec`.
- Keep such regex bridges exact. Dart now recognizes only those two shipped recursive named-block patterns,
  preserves their capture identities and physical-line boundary, and rejects suffix text; it does not claim a
  general recursive-PCRE engine. With the whitespace repair, full Dart and Julia corpus routes return to 105/105
  without rebasing a single expectation.
- The complete Julia component gate also passes its package suite, project-data containment, primary CLI process
  conformance, and the final 105/105 corpus route after the bounded fluent-whitespace repair.
- Bounded Knowledge cards are hard destinations, not append sinks. The typed-source rollout card began at
  65,530/65,536 bytes, so this leaf's 825-byte absent-match record belongs in the new focused
  [[perl-absent-local-match-projection-repair]] card. The original card remains byte-identical to clean `HEAD`;
  after the separate launch-latency card, Knowledge regenerates at 927 facts / 7,878 keys and routed-destination
  closure passes without a cap increase.
- A cold repository-local Rust trace build took 55m44s, then its 112-KiB test process produced no output for over
  three minutes. Process census showed macOS `syspolicyd` consuming substantial CPU; a one-second stack sample was
  entirely `_dyld_start`, so Rust test code—including the new semantic fixture—had not begun. The exact `/tmp`
  sample report was consumed/deleted and residue-checked. Queued `.19.3.4.0-.1` will reproduce/classify before any
  safe project-local repair; global trust bypasses and speculative workflow changes are forbidden. The initiating
  plain-Cargo route read the user-home registry, so its eventual 12/12 is diagnostic only; `.19.3.3` requires the
  same trace target through LinkedSpec's managed repository-local Cargo wrapper before signoff.
- The complete Dart gate exposed the exact analogue of the Lua `.15.3` stale control fixture. `/skip/ { next() }`
  is a regex item followed by standalone lifecycle `I`, so correct entry execution exits before iteration. The
  test now assigns the block to `-> Skip { next() }`, keeps `/skip/` on child `Skip`, and locks `keep` at cursor
  eight. Production parser and interpreter behavior do not move. The corrected complete Dart gate passes format,
  analysis, all 441 tests, project-data containment, both 66/66 CLI matrices, and all 105 corpus fixtures.
- The exact managed root-selection driver proves the semantic invariant through Rust 1/1, Dart 1/1, Julia
  137/137, PUC Lua 139, LuaJIT 139, and the 5×2×6 CLI projection; recursive observation passes all six routes.
  The final managed trace command must include `--manifest-path rust/Cargo.toml` when invoked from repository root
  and passes 12/12 in 2.23s. A wrapper call without that manifest fails at Cargo discovery and is not evidence.
- Managed timing strengthens the queued latency audit: the root-selection Rust test build took 117m57s, while a
  later trace rebuild took 2m07s but its binary was silent for about 98 seconds before 2.23s of tests. Preserve
  compilation, process-launch, and test-execution timings separately; do not infer a runtime loop from pre-main
  silence or use the disparity to justify a global trust bypass.
- Canonical signoff adds a second confounder that controlled latency work must exclude: a separate Claude-owned
  process deleted four repository-local Rust target/cache directories and ran `cargo sweep --time 7` while the
  receipt-bound gate was active. No tracked bytes moved, but incremental evidence from that interval is invalid.
- A canonical MCP binary independently remained at 112 KiB in `_dyld_start` for over five minutes and then ran
  3/3 tests in 2.43 seconds. The diagnostic sample's exact `/tmp` report was consumed, deleted, and residue-
  checked. `.19.3.4.0` must reproduce serially before attributing delay to Gatekeeper, cache topology, or storage.
- The exact staged canonical boundary passes all nine doctrines, cross-backend recurring composition, repository
  process-locality and relocation, CLI 66x2, and Phase 0 1,032/1,032 in 1,000 seconds.
- The complete record triggers the official engineering-notes rollover at 465/512 lines. Segment `4986` archives
  218 clean-HEAD lines; ADR `0099` advances only finite collection capacity 21→22 and manifest lines 20→21 while
  every byte, segment, aggregate, route, lifecycle, verifier, and storage control stays fixed.
- 2026-09-01 (`FUTURE-PARITY-BACKLOG.19.3.2` — Rust `map_leaves!`): reserving `!` only in the dedicated
  receiver-mutation parser keeps ordinary identifiers, functions, methods, and continuations unchanged. One typed
  carrier retains the callback ActionIR and authored Unicode-scalar source/spans through every Rust route.
- Receiver safety requires identity, not spelling. `RuntimeContext` now preserves an identity across ordinary
  writes, allocates a fresh identity for scoped/function-local bindings, and restores the caller identity on exit;
  an explicit parameter named `tree` is therefore legal without weakening the outer receiver guard.
- Guard checks run at the common expression/statement seams before target operands, nested-write segments/RHS, or
  pipeline evaluation. This makes `receiver_mutation_reentrant` deterministic and prevents hidden side effects
  from a forbidden write attempt.
- Mapping uses an isolated original snapshot and only recurses through the starting root kind. Callback results
  are detached replacements and are never revisited; all callbacks must complete before one receiver publication.
- Callback/re-entrant failure releases the guard and leaves the receiver unchanged while ordinary completed
  effects on other identities persist. Successful publication releases the guard before continuation, so a later
  continuation failure cannot roll the commit back.
- Permanent proof must include carrier compilation, not merely emitted text inspection. The integration test
  creates a repository-volume workspace, independently compiles the emitted module offline, executes it, and
  removes the workspace through its drop guard.
- The frozen neutral mutation oracle remains unchanged at 167 base + 592 composition mutations. Rust-specific
  proof executes callback-value/unrelated/shadow writes, pre-evaluation same-receiver precedence, later callback
  failure, unrelated write failure effects, post-commit continuation failure, non-bang isolation, and detachment.
- The complete Rust gate caught a stale trace-test assumption rather than a runtime regression. Selecting `Top`
  enters its handler and executes its lifecycle/loop; entry is not an implicit edge back to `Top`, so the inert
  `/x/` on that fixture cannot produce `regex_match`. Replacing the positive regex assertion with an explicit
  lifecycle-positive/regex-negative lock makes the target pass 11/11 and preserves production dispatch bytes.
- The positive twin remains topology-driven: an outgoing edge selects its target rule's regex. `.19.3.3` owns a
  controlled fixture/oracle inventory and cross-backend proof of both halves rather than allowing individual
  backend tests to encode a different entry interpretation.
- 2026-09-01 (`FUTURE-PARITY-BACKLOG.19.3.1` — Rust write vivification): the old Rust AST encoded quoted
  segments as keys and every computed segment as an index, so it could not honor the frozen evaluated-kind rule.
  `WritePathSegment` now retains source/span/expression and one `AssignNestedAccess` owns every path length.
- Assignment pre-scan must stop both at a top-level comma and when an outer scalar assignment occurs before the
  first bracket. Without the latter, `result = document[...]=value` is misclassified as a malformed root instead
  of an ordinary scalar assignment whose RHS is a nested write.
- Runtime evaluation stores all segment values left-to-right and then the RHS before inspecting binding state.
  Structural work clones that post-evaluation snapshot, which composes same-binding expression effects correctly
  and isolates only the path publication—not already completed ordinary expression side effects.
- Rust `RuntimeValue` already distinguishes absent binding lookup from an explicitly stored `Undef`; retaining
  `has_bare_binding` through rule and function frames gives the same absent-versus-bound-null contract as Perl
  without a separate presence map. Fresh function locals are absent per invocation and parameters are present.
- Typed structural errors are serialized JSON through the existing string error API. The stable code/field shape
  is therefore portable without changing the public Rust error type in this backend-only leaf.
- Validation belongs at every carrier boundary, not only source parsing: compiler and callable visitors,
  source emission, decoded generated plans, and direct Engine entry reject corrupt node kind/source/span state.
- Fixture review reconfirmed dispatch semantics: entering a parent runs its loop, but `-> Done` selects `Done`'s
  regex. A regex on the parent is irrelevant to that edge unless the edge targets the parent itself. New tests use
  a zero-regex `Top`; systematic legacy fixture correction is reserved under `.19.3.3`.
- A complete 105-case Perl oracle regeneration reproducibly changes the unrelated
  `capability_position_helper_surface` expected value to null. Source-selector migration postdates that expected
  file, while current Rust/committed corpus still passes. The unrelated output is restored rather than blessed;
  `.19.3.3` owns root cause, two-pass reproducibility, and cross-backend cleanup.
- 2026-08-31 (`FUTURE-PARITY-BACKLOG.19.2.2` — canonical checker repair): canonical attempt one passes every
  stage through punctuation-light zero-argument behavior, then exposes two stale literal anchors in
  `check_uniform_binding_mutation_result_surface.py`. The prior `.19.2.1` typed-path work correctly changed public
  prose from an updated hash snapshot to an updated typed root because integer selectors can update arrays; the
  checker still required the superseded hash-only phrases.
- Keep the book accurate and move the recurring anchors to the existing root-generic sentences. The corrected
  checker passes 53 public files / 12 current anchors / 9 classified historical cards and Python syntax. The
  final exact staged candidate restarts canonical proof because the checker and continuity state changed after
  attempt one, passes from the beginning, and produces the matching receipt required for the atomic commit.
- 2026-08-31 (`FUTURE-PARITY-BACKLOG.19.2.2` — Perl `map_leaves!`): parser ownership must precede generic fluent
  parsing because `!` is deliberately not an identifier character. The dedicated node admits only a bare binding
  receiver and carries its callback plus ordinary continuation; invalid receiver/function/bang variants therefore
  fail at one typed syntax boundary instead of leaking into host Perl residue.
- Receiver protection is identity-based. `Scalar::Util::refaddr` over the actual scalar slot distinguishes a
  same-spelling function parameter from the guarded outer binding. A dynamically scoped guard is installed before
  snapshot/traversal and released on both success and exception; nested same-receiver bang detects the guard before
  absent/kind checks, giving re-entrancy the required diagnostic precedence.
- Runtime mapping clones the root before walking it, recurses only through containers matching the starting root
  kind, and constructs a complete replacement before one scalar-slot publication. Callback inputs and outputs are
  cloned independently. This makes callback failure atomic for the receiver without rolling back ordinary effects
  on unrelated bindings; continuation begins only after the guard is gone and the root is committed.
- The write-surface audit found one non-obvious bypass after the obvious assignment/helper routes were guarded:
  binding-target array pipelines such as `trim_each(items)` and `uniq(trim_each(items))` mutate their source by
  assignment. `ArrayPipeline` now checks the active receiver before any pipeline operation/source/delimiter
  evaluation and retains the authored source span. Its final tracked result uses a real private assignment so
  fatal-warning execution has no void-context private-variable warning.
- Expanded signoff then exposed a routing distinction inside that family: three-argument
  `split(items, source, delimiter)` parsed as an AST call whose value-helper arity intentionally stops at two, so
  callback statement lowering emitted unsupported-helper residue before reaching `ArrayPipeline`. The repair
  sends recognized pipeline statements to their existing owner before generic AST value lowering. Exact live
  tests now cover `split`, `split_each`, `trim_each`, `filter_nonempty`, `filter_match`, `lowercase_each`,
  `uppercase_each`, `uniq`, a composed pipeline, and all four array-end methods; every receiver attempt reports
  its authored span and leaves the receiver unchanged.
- The frozen helper carriers could not reach caller bindings because user functions are intentionally pure/fresh-
  local. The director-selected correction uses inline `set(tree, {})` and a caller-scoped trailing `.with()`;
  intended guard and post-commit observations stay intact, implicit capture stays deferred, and the mechanically
  generated current composition count becomes 592 rather than the historical pre-correction 593.
- Permanent proof runs under fatal warnings and covers exact AST/diagnostics/spans, harray/array traversal,
  callback bindings, replacement non-revisit, detachment, atomic rollback, identity shadows, every executable
  receiver-write route, guard release, nested composition, and post-commit continuation. Five focused files pass
  58 tests; the neutral checkers pass 105 write and 167 base + 592 composition mutations; broad Phase 0 passes all
  1,032 tests in 1,016 seconds.
- The required complete change record crossed rollover pressure at 474/512 lines. The governed tool archives 221
  complete lines as immutable segment `4987`, leaving the final root at 259/512. ADR `0098` advances only the
  finite change-history collection/manifest controls to 26/25; exact totals remain 47,493/55,000 lines and
  3,412,036/4,194,304 bytes. This infrastructure movement requires canonical proof before commit.
- 2026-08-31 (`FUTURE-PARITY-BACKLOG.19.2.2` — implementation blocker): Knowledge retrieval exposed a real
  incompatibility before bang code. The neutral helper-mediated and post-commit examples label unparameterized
  function `tree`/`audit` names as caller identities, while the admitted function MVP makes all working variables
  fresh locals and explicitly defers implicit caller capture/mutation.
- Exact Perl execution returns outer `[{"a":"A"},[]]` unchanged and helper-local `[{},["entered"]]`, proving this
  is runtime scope rather than wording. Separate controls show `set(tree, ...)` in an inline traversal callback
  reaches the outer binding and a trailing `.with()` block can reach it after the preceding chain result.
- Recommended option A corrects only those future carriers and preserves pure functions. Option B requires a
  separately ratified five-backend implicit-capture program. Implementation stops before behavior/fixture changes.
- 2026-08-31 (`FUTURE-PARITY-BACKLOG.19.2.1` — Perl write vivification): one `assign_nested_access` path now owns
  one and many bracket segments. Keeping each segment as a typed expression plus authored span avoids the former
  quoted-key/computed-index parser guess and lets a runtime string or integer select harray or array correctly.
- Perl needs explicit presence state: lexical `undef` means either absent or bound null, but the neutral contract
  distinguishes them. Rule-local and user-function-local `%__ls_binding_presence` maps exist only when a nested
  write target is present; tracked scalar assignment marks it, function parameters initialize as present, and
  fresh locals begin absent per invocation.
- Signoff review caught the statement-helper twin before commit: `root = undef` marked presence, while
  `set(root, undef)` initially bypassed that seam and would have vivified. Routing all scalar statement spellings
  through the same tracked-assignment helper restores the documented alias; the live contract now tests both.
- Lowering stores segment values left-to-right, then RHS, before it reads the root/presence and calls the runtime.
  This makes once-only order inspectable and ensures a same-binding segment/RHS assignment settles before the
  outer snapshot. Expression failures never enter structural work; later structural failure preserves completed
  expression state but never a partial path.
- `BindingRuntime::nested_write` validates all selectors first, clones the post-evaluation root, creates only
  selector-determined missing containers, and clones both commit and result. `B` scalar flags preserve dynamic
  integer versus numeric-string identity; JSON booleans are diagnosed before numeric coercion.
- The frozen fixture drives exact Perl AST, parser-diagnostic, runtime-success, runtime-failure, and source-span
  projections. Dedicated live cases catch bound-null presence and repeated zero-argument user-function calls;
  tied scalars prove segment/RHS order and unchanged expression-error propagation.
- The first full 1,032-subtest Phase 0 pass had exactly 12 failures, all generated-source assertions on the changed
  lowering. After correcting only those expectations (including authored-span normalization for spacing twins),
  an exact focused replay of the 12 passes; all other 1,020 had already passed. Permanent focused suites pass 50
  tests. After the final presence/type refinements, a fresh exact-tree Phase 0 passes all 1,032 in 963 seconds;
  both frozen neutral checkers remain unchanged at 105 write / 167+593 map/composition mutations.
- 2026-08-31 (`FUTURE-PARITY-BACKLOG.19.1.3` — neutral mutation composition): the two atomicity domains are
  intentionally different. `map_leaves!` protects and atomically commits only its receiver rebuild; a nested write
  to another identity retains normal success/failure and completed-expression semantics. A later callback failure
  therefore preserves earlier unrelated writes while leaving the receiver unchanged.
- Guard lookup must precede every attempted same-receiver nested-write segment and RHS evaluation. The composed
  fixture makes a latent failing selector and RHS observable only if this ordering regresses; the correct result is
  immediate `receiver_mutation_reentrant` with zero write effects. Same spelling is insufficient—a helper parameter
  with a distinct identity may vivify normally.
- Commit releases the receiver guard before continuation. The continuation fixture reaches `tree` again, performs
  an ordinary structurally failing nested write, and proves the failed path is discarded while the already-mapped
  receiver commit remains.
- Extending both existing checkers avoids a third tool/storage owner. Eight write surfaces, six callback cases, one
  continuation, 105 write mutations, 167 map mutations, and 593 composition scalar/container-shape mutations pass.
- Primary-command probes use the exact JSON-owned source. The non-bang twin returns `{"leaf":[]}` on all six
  routes; the bang form stops before callback lowering with null on Perl/Rust (Rust warning) and exit-1 generic
  parser invocation on Dart/Julia/PUC Lua/LuaJIT. Disposable same-volume Lua native outputs were removed.
- 2026-08-31 (`FUTURE-PARITY-BACKLOG.19.1.2` — future `map_leaves!` contract): a checked-in action-edge fixture is
  the trustworthy parser control. Its non-bang form returns the same nested value on Perl/Rust/Dart/Julia/Lua;
  replacing only the method spelling yields null on Perl/Rust (Rust warns) and generic invocation failure on the
  other three. The earlier lifecycle-style probe was discarded because its non-bang twin also returned null.
- Perl ActionIR classifies the bang chain as `raw_perl` / `invalid_fluent_chain`; Rust's `parse_name` stops before
  `!`; Dart/Julia/Lua callee recognizers require identifiers. The gap is therefore syntax/AST ownership before
  runtime dispatch, and the neutral contract supplies one future typed boundary without blessing current errors.
- The receiver guard is keyed to the resolved binding identity, not its spelling. This rejects every direct or
  helper-mediated same-binding write during callbacks while allowing unrelated bindings and scoped shadows. The
  guard releases after both success and failure, preventing a failed call from poisoning later invocations.
- Mapping consumes an isolated original-shape snapshot. Callback frames and aggregate results are copied; root-kind
  replacements are not revisited. Complete callback success commits once and returns another detached copy.
  Ordinary fluent continuation runs only after commit, so its later failure cannot retroactively roll back the
  completed bang operation.
- The independent checker freezes 4/14/5 syntax cases, 10 success and 8 pre-commit failure cases, five special
  state boundaries, and 167 mutations. Adding it through `tools/run_python_project_data.sh` advances the exact
  tool-entrypoint inventory 36→37 with no new temporary allocator, firing canonical storage proof for this leaf.
- 2026-08-30 (`FUTURE-PARITY-BACKLOG.15.3` — stale Lua `next()` fixture repair): `.19.1.1` boundary proof made
  `lua/test/run.lua` fail only test 115 on PUC Lua. The fixture's `/skip/ { next() }` now correctly parses as two
  rule items: a regex plus a bare lifecycle-`I` block. Entry lifecycle throws `next` before iteration, yielding
  matched/null at cursor zero; before `.15.2` the inert bare block made the test pass without exercising control.
- Direct replacement proof uses `-> Skip { next() }` plus `Skip: /skip/`, assigning the block to the action edge.
  It returns `keep` at cursor 8. Complete 178-test PUC Lua and LuaJIT harnesses pass, as do the neutral 14-mutation
  standalone contract and 109-assertion admission on each ABI. No production, contract, or public behavior moves.
- Exact canonical attempt one passes through the Perl project-data oracle, then the tool-storage census reports
  36 Python entrypoints against its exact expected 35. The delta is committed `.19.1.1`
  `tools/check_write_vivification_contract.py`: it already runs through the repository-routed wrapper, uses no
  Python temporary allocator, and changes no shell allocator ownership. The repaired census is therefore 36/3/15.
