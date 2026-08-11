# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.3` — dual-ABI Lua recognition admission): admission is a topology
  change, not another runtime layer. Remove the selector and RED diagnostics, keep the 243-assertion body and both
  private production modules unchanged, and execute the same Lua-5.1 source independently on both ABIs.
- Ordinary proof belongs in `tools/run_lua_local.sh`: one direct command under the PUC native path and one under
  the LuaJIT native path. Canonical proof separately requires the tracked consumer and uses one project-data-routed
  command per ABI. Governance counts exact marker multiplicity rather than merely searching for the filename.
- Treat PUC Lua and LuaJIT as independent rollout rows even though they share source. Promotion therefore adds two
  complete-to-RED semantic mutations and two exact rollout paths, moving 44 to 46 and 5/9 to 7/9. Recurring and
  public no-drift are still later responsibilities; do not collapse them into admission.
- Every admitted consumer snapshots mutable neutral metadata. Lua promotion changes no Perl/Rust/Dart/Julia runtime
  behavior, but their expected status, availability, mutation count, and later-row assertions must advance. Julia
  consequently moves from 203 to 205 current assertions solely through two new rollout-row checks.
- Current admission governance replaces, rather than pretends to execute, the historical RED oracle: 22 mutations
  lock canonical and ordinary omission/duplication, direct private lookup, stale selector/diagnostics, result
  identity, and facade privacy. Retain 22 authority and 19 integration suites as independent implementation locks.
- Public truth must move with admission. The mdBook now teaches the exact dual-ABI commands and private/public
  boundary; checker-governed sequence truth is 3/20/38 and capability-guide truth is 1/10/14.
- Canonical signoff caught and rejected two accidental documentation-projection omissions before acceptance: the
  retained `.24.2` capability-exclusion marker in `docs/TASK_TREE.md` and exact `128 mutations, rollout 9/9`
  semantic text in both roadmaps. Restoring those historical/current anchors made the independent guards pass;
  final locality, relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 758 seconds are green.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.2` — shared Lua recognition-transaction integration): parse the four
  exact authored forms after ordinary argument parsing, then replace them with dedicated nodes. In particular,
  retain only the token slot and static child label for `recognize_once`; never evaluate its `call(Rule)` operand as
  a generic helper and never add the four grammar-owned intrinsics to the 246-name call inventory.
- Keep effect closure and progress separate. Effects propagate through direct and mutual recursion to a fixed point
  over the neutral 9-allowed/11-rejected vocabulary; only accepted repetition and recursive-cycle edges require
  cursor movement. Binding, mark, boundary, or transaction changes do not count as progress.
- Bind live state through one private adapter. Every invocation gets a fresh same-label mark bucket and authority
  frame; checkpoint/attempt/terminal operations synchronize the UTF-8-byte cursor, nullable anonymous boundary,
  and marks. Attempt presence remains separate from payload so a successful `false` commits intact.
- `interpreter.lua` was already at Lua 5.1's 200-local main-chunk ceiling. A cohesive private
  `recognition_transaction_runtime.lua` module avoids crossing that structural limit and keeps one implementation
  shared by PUC Lua and LuaJIT instead of scattering adapter functions through the interpreter.
- Native, reconstructed, generated-plan, and emitted-module carriers all re-enter the effective compiler/runtime;
  no emitter-specific transaction fork or filesystem workspace is needed. Exact integration is 243/243 per ABI.
- Keep integration distinct from admission: facade and ordinary/canonical discovery stay unchanged, rollout remains
  5/9, and the checker adds 19 private-integration mutations beside 22 authority and 12 dormancy mutations.
- A supplemental apparent miss anomaly was an invalid probe assumption: `E { return(false) }` is a final lifecycle
  return and therefore accepts after a regex miss. The corrected `LE` probe proves hit=`false`/cursor 2 and
  rollback=`"miss"`/cursor 0 identically on both ABIs; existing lifecycle knowledge already owns that behavior.
- Final proof passes book 79/14,412 KiB, KM 817/6,781, all eight doctrines, every mandatory admission, containment/
  relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 736 seconds through exact canonical success. Land
  atomic 203 cleanly before `.14.3.6.3` changes discovery or rollout truth.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.1` — private shared Lua recognition-transaction authority): follow the
  existing private `source_location.lua` pattern: opaque tables backed by one module-local weak-key store and a
  non-exported direct module. This keeps handles unforgeable enough for the internal contract without public API.
- Keep the module within Lua 5.1 syntax and behavior. One source must run unchanged on PUC Lua and LuaJIT; the
  authority owns no parser/runtime carrier until `.14.3.6.2` integrates it.
- Separate matched presence from payload at every boundary. Lua's `condition and payload or fallback` idiom loses
  `false`; explicit branches are mandatory for staged values and diagnostic projections. Use `json.null` for an
  encodable miss and `json.array()` for empty ordered diagnostic fields rather than ambiguous `{}`.
- Restore snapshots before invalidating tokens on rollback, discard, misuse, and invocation unwind. Monotonic ids
  plus private ownership checks make cross-source, cross-invocation, wrong-generation, nesting, retry, reuse, and
  escape failures deterministic and prevent a failed operation from leaving staged state live.
- Authority proof is 187/187 on both ABIs. Integration compiles the real authored source and then stops at one
  stable missing-dedicated-ActionIR diagnostic; do not add effects, progress policy, runtime adapters, or carriers
  to this authority-only slice.
- Keep dormant topology and private-authority governance separate: 12 mutations prove absence from ordinary/
  canonical/facade routes; 22 prove the authority surface and next RED. Neutral 132/246/44 and rollout 5/9 stay exact.
- Final proof passes book 79/14,412 KiB, KM 816/6,772, all eight doctrines, every mandatory admission, containment/
  relocation, CLI 66x2, RAM 82%, and Phase 0 1,031/1,031 in 753 seconds through the exact canonical success marker.
  Land atomic 202 cleanly before `.14.3.6.2` adds any ActionIR/effect/progress/runtime/carrier integration.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.6.0` — shared Lua recognition-transaction RED): use one source for both
  PUC Lua and LuaJIT. The existing interpreter, typed source authority, byte registers, mark/cursor stores,
  generated plan, and in-memory source loader are shared; an ABI-specific transaction implementation would be drift.
- Freeze `authority` and `integration` modes as an ordered handoff. Both modes load the future private direct module
  first, yielding one stable failure today; `.14.3.6.1` can close authority before `.14.3.6.2` closes compiler/runtime
  integration without weakening the final-path consumer.
- Preserve Lua's explicit null sentinel when match presence and payload are separated. A successful `false`, zero,
  empty string, or `json.null` is staged independently from the strict match boolean and reaches commit unchanged.
- Load emitted Lua in memory with `loadstring or load`; the RED creates no filesystem workspace or project-data owner.
  Ordinary and canonical command lists must remain path-free until admission `.14.3.6.3` removes dormancy.
- Keep RED topology governance separate from semantic rollout. Twelve mutations lock the dual-ABI dormant boundary,
  while the neutral artifact remains 132/246/44 at 5/9 and all public/guide claims remain Julia-current/Lua-future.
- Cross-check frozen future branches against the real current serialization API even when the missing authority
  prevents execution today: Lua compiled specs expose `rules_by_label`, not a positional `rules` array.
- Final proof passes book 79/14,412 KiB, all eight doctrines, every mandatory contract/admission, containment and
  relocation, CLI 66x2, RAM 60%, and Phase 0 1,031/1,031 in 740 seconds through the exact canonical success marker.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.5.3` — Julia recognition-transaction admission): treat admission as an
  exact discovery/governance operation over the already-green private implementation. Include the final-path
  consumer once in `julia/test/runtests.jl`, require its exact canonical marker/command, and remove both selector
  environment variables plus the conditional testset rather than retaining a hidden alternate execution mode.
- Keep the authority deliberately private. Ordinary test code reaches the unexported source-local namespace for
  proof, while mutation governance separately rejects facade export and loss of the private lookup.
- Synchronize every admitted consumer's neutral metadata snapshot on rollout movement. Perl, Rust, Dart, and Julia
  now agree on status, availability, mutation 44, rollout paths, and the Lua-next boundary without runtime changes
  to the first three backends.
- Separate semantic, public-sequence, guide, and registration mutation domains. Julia complete-to-RED plus
  premature Lua promotion produce semantic 44; three superseded Dart-era public claims yield 3/17/33; two guide
  claims yield 1/8/12; fourteen Julia mutations own exact discovery, dormancy removal, privacy, and facade denial.
- Keep native UTF-8 code-unit registers/results and the shared carrier implementation unchanged. The admitted
  consumer always executes all 203 assertions, and the complete Julia gate proves package, primary CLI, and all
  105 corpus fixtures without a new project-data owner.
- Capability/book/live/Knowledge Map truth, direct rendered inspection, and all eight doctrines agree. Definitive
  canonical proof passes containment/relocation, CLI 66x2, RAM 69%, and Phase 0 1,031/1,031 in 738 seconds through
  the exact success marker; land atomic 200/300 cleanly before activating shared Lua RED `.14.3.6.0`.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.5.2` — private Julia recognition-transaction integration): normalize
  transaction calls only after ordinary argument parsing, then replace the complete call shape with a dedicated
  node. The attempt node stores a token-slot name plus static child label, so `call(Rule)` is never eagerly resolved.
- Keep grammar-owned transaction nodes outside callable-contract and final-codeblock normalization. Semantic call
  projection consequently retains the shared 246-name current inventory without a recognition-specific exception.
- Evaluate effect graphs to a monotone set-union fixed point so direct/mutual recursion cannot hide a forbidden
  transitive effect. Validate progress separately and accept only cursor advance on repetition/recursive edges;
  binding, mark, or transaction state changes never substitute for progress.
- Enter one transaction frame for every rule invocation. Remove and later restore only the same-label mark bucket,
  leaving different-label parent marks live while recursive same-label calls receive fresh isolated state.
- Synchronize the authority from the live code-unit cursor, anonymous boundary, and invocation marks at checkpoint,
  attempt, and terminal operations. Rollback rebuilds current registers; commit retains them; rule exit restores
  caller registers and same-label marks while leaving the resulting cursor intact.
- Reuse existing carrier convergence. Reconstructed and emitted modules recompile the same source; generated plans
  already call the effective runtime. No emitter-specific transaction fork or filesystem workspace is required.
- Treat matched presence independently from payload truthiness. Julia's `_RuntimeRuleResult` already owns `matched`,
  so the adapter stages it directly and preserves a committed `false` through all four carriers at 203/203.
- Keep admission separate: the module is unexported, discovery is unchanged, neutral rollout stays 4/9, and only
  `.14.3.5.3` may register the exact final-path consumer and promote Julia.
- Close integration only after the complete canonical gate repeats all current admissions and repository-locality
  proof unchanged. The definitive run passed all eight doctrines, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in
  731 seconds through the exact local-CI success marker; `.3` remains a clean-tree admission activation.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.5.1` — private Julia recognition-transaction authority): include one
  non-exported sibling module immediately after `SourceLocation`; reuse the exact authority object as the first
  cross-source discriminator while keeping artifact `source_identity` independent from its decoded-source key.
- Represent frame state as an immutable tuple of copied mark pairs rather than retaining a caller-owned `Dict`.
  Every constructor, snapshot, state read, and JSON projection detaches again, so observation cannot mutate live
  cursor/boundary/mark state.
- Return opaque private frame/token wrappers around module-owned mutable lifecycle records. Authority-local UInt64
  counters allocate non-reused invocation, mark, and transaction generations; a frame owns at most one active token.
- Keep staged match presence and payload in separate fields. This makes a matched `false`, zero, empty string, or
  `nothing` distinguishable from a miss until commit, which invalidates before returning the captured payload.
- Restore through the token's owning frame before invalidation on escape, retry, nesting, cross-owner use, discard,
  rollback, and unwind. In particular, a child-frame nesting rejection restores its parent's snapshot without
  aliasing a recursive same-label mark table.
- Keep integration rigorously out of this leaf. The authority selector passes 155/155, while the unchanged nested
  selector first finds zero dedicated nodes and later confirms absent effect/progress functions plus unsupported
  runtime dispatch. Ordinary discovery never includes the dormant consumer.
- Complete Julia remains green across package tests, typed source 127/127, storage 19/5, primary CLI, and corpus
  105/105. The private namespace changes architecture, not authored availability or rollout.
- Close the authority leaf only after the complete host-permitted gate proves every existing admission and routing
  boundary unchanged. Canonical signoff passed CLI 66x2, RAM 68%, and Phase 0 1,031/1,031 in 747 seconds through
  the exact local-CI success marker; integration remains a separate clean-tree activation.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.5.0` — froze dormant Julia transaction RED): Julia ordinary test
  discovery is an explicit include list, so keep the final-path consumer in `julia/test/` without adding its include
  until admission. No analyzer exclusion, custom build flag, or second directory is needed.
- Order one explicit `authority|integration` selector behind neutral-contract loading and before all test execution.
  Both modes now fail solely at absent private `LinkedSpecJulia.RecognitionTransaction`; after `.1` supplies that
  namespace, authority mode can prove lifecycle semantics while integration mode advances in the unchanged file.
- Reuse the admitted private `SourceLocation.SourceAuthority` for source identity without exposing either private
  namespace. Freeze Julia-idiomatic free functions over opaque frame/token values, detached `to_json` records, and
  a portable exception whose `showerror` result is the neutral diagnostic marker.
- Load emitted source into a fresh host with `Base.include_string`. This is an independently loaded emitted module
  but owns no filesystem scratch, so Julia storage remains 19 temporary owners / five locked package trees.
- Current Julia authored syntax compiles as four generic calls and runtime stops at unsupported
  `recognition_checkpoint`; dedicated parsing must replace the complete forms only in integration `.2`.
- Define `admission consumer` at the first typed-source book boundary: the neutral checker freezes semantics, the
  backend consumer executes them, and ordinary plus canonical registration makes the backend support claim.
- Treat an exact public-status marker failure as real drift. The first canonical run rejected altered ROADMAP
  wording; after restoring the governed marker, the complete rerun passed CLI 66x2, RAM 60%, and Phase 0 1,031/1,031
  in 724 seconds through the final local-CI marker.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.4.3` — admitted Dart recognition transactions): admission is a
  discovery/governance slice over the already-green private integration. Move the exact consumer into `dart/test/`,
  remove only the environment-backed skip authority, and retain its source-local authority import.
- Keep the private runtime boundary explicit. The checker requires that import exactly once, denies any facade
  export, and mutation-tests dormant path, switch, skip, registration, log, and invocation residue independently.
- Derive rollout policy from the same ordered authority used by `policy.current_boundary`: Dart becomes complete,
  Julia becomes the sole next-backend premature-promotion mutation, and semantic mutations advance 42 to 43.
- Every admitted backend consumer snapshots mutable neutral status/availability metadata in addition to its own
  runtime proof. A new admission must update those assertions in all earlier consumers; canonical Perl/Rust targets
  are the executable no-drift backstop for that cross-consumer coupling.
- Treat public milestone governance as a separate domain. Adding Dart regression plus three superseded Rust-era
  claims yields 3 documents / 14 forbidden / 29 mutations; the guide separately becomes 1/6/10.
- Canonical Dart execution must use `tools/run_dart_project_data.sh`, because the emitted-source test owns scratch
  and package-cache data. The storage owner remains one of 21; only its sorted path changes from dormant to final.
- Complete backend proof passes format 100/0, strict analysis, ordinary 393, storage 21/47, CLI 66x2, and corpus 105.
- Close admission only after every earlier consumer agrees with mutable neutral metadata. The first canonical run
  rejected stale Perl/Rust snapshots; after their status/availability/count/rollout assertions were synchronized,
  one full host-permitted run passed all eight doctrines, containment/relocation, CLI 66x2, RAM 60%, and Phase 0
  1,031/1,031 in 694 seconds before the exact local-CI success marker.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.4.2` — integrated Dart recognition transactions): normalize the four
  static transaction forms only after ordinary arguments parse, then replace the entire call shape with a dedicated
  node. The attempt node stores a token slot and rule name, so its `call(Rule)` operand cannot be resolved or run as
  an eager helper and does not perturb the callable inventory.
- Reuse the existing effective runtime for all carriers. Reconstructed specs recompile the same parsed action text;
  generated plans select structural rule execution inside `LinkedSpecRuntimeEngine`; emitted source reconstructs
  the compiled spec and calls that engine. One runtime integration therefore proves four carriers without creating
  backend-specific transaction interpreters.
- Wrap every rule invocation with the private authority, even while admission is dormant. Entry replaces the
  same-label mark bucket and saves its predecessor; exit applies current or unfinished-token state before restoring
  the caller bucket. This gives recursive same-label isolation while leaving different-label parent marks live.
- Keep match acceptance separate from the payload. Dart's `_RuleResult` already owns an explicit `matched` bit, so
  `recognize_once` stages that bit plus `value` directly; `_returned(false)` is matched because only null denotes
  absence, and commit can therefore expose `false` without misclassifying the child as a miss.
- Synchronize cursor from the context's live UTF-16 register, boundary from `RuntimeMatchRegisters`, and marks from
  the current invocation bucket before checkpoint/attempt/terminal operations. Rollback rebuilds registers while
  preserving entry/local match objects, then restores cursor, nullable boundary, and marks as one state.
- Effect policy mirrors the neutral/Rust monotone set-union fixed point exactly; progress is independent and accepts
  only `end > start` on repetition/recursive edges (with one-shot zero width allowed). State or mark mutation never
  substitutes for cursor progress.
- Dormancy and integration are orthogonal. The environment-enabled consumer passes 10/10, but default remains
  6/4 skipped, the module stays unexported, canonical discovery remains absent, and rollout stays 3/9 until `.3`.
- Complete verification passes Dart format 100/0, fatal analysis, ordinary 383, storage 21/47, CLI 66x2, corpus 105,
  and a rendered 79-file / 14,396-KiB book inspection; generated book output is then safely removed and rebuildable.
- Close only after one uninterrupted definitive gate. Atomic 195 signoff passes all eight doctrines, capability
  80/0/0, MCP complete/141, containment/relocation, canonical CLI 66x2, RAM 64%, Phase 0 1,031/1,031, and the exact
  local-CI success marker before the frozen commit workflow begins.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.4.1` — added private Dart transaction authority): return opaque
  frame/token handles as `Object` from the unexported module so the public method surface does not expose private
  implementation types. Keep snapshots and exception records detached at every observation boundary.
- Compare `SourceAuthority` by object identity before authority/invocation generations. This matches the admitted
  Rust authority: cross-source misuse restores the token owner first, while a same-source wrong invocation reports
  the narrower invocation diagnostic.
- Treat the active token as invocation-stack state, not a truthy payload. `matched` and `payload` remain separate,
  so `false`, zero, empty string, and null all survive a successful commit without turning into a miss.
- Restore before invalidating on every misuse path. Nesting rejection may occur from a child frame while the active
  token belongs to its parent; restoring through the token's owning frame preserves recursive state exactly.
- Use one dormant environment switch only for the four integration tests. Default explicit execution proves the
  private authority at 6 pass / 4 skipped; the enabled mode exposes four independent `.14.3.4.2` failures without
  changing ordinary discovery or canonical registration.
- Remove the analyzer exclusion as soon as the private module exists. Strict analysis then proves the future
  consumer and private API together while the `test_dormant/` path alone preserves admission ownership.
- Exact owner manifests must census non-ignored untracked sources as well as the Git index. Atomic 193's new dormant
  temp owner was invisible to `git ls-files` before its first commit; cached+others with C-locale sorting closes that
  timing gap while continuing to exclude ignored package/build output.
- Rerun the complete backend gate from its first step after repairing a late storage failure. The corrected run
  proves format 100/0, analyzer, ordinary 383, storage 21/47, CLI 66x2, corpus 105, and the exact Dart success marker.
- Close the slice only on one uninterrupted definitive run after that backend repair. Atomic 194 signoff passes all
  eight doctrines, containment/relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 697 seconds.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.4.0.1` — froze dormant Dart transaction RED): use an unregistered
  `test_dormant/` consumer plus one exact analyzer exclusion to preserve a final-path test without asserting an
  unavailable private package boundary. Ordinary discovery and fatal analysis must remain independently green.
- Freeze the whole later implementation seam in the first RED: authority and detached frame state, falsey-safe
  token lifecycle, recursive marks, all portable diagnostics, four non-eager nodes, effect/progress policy, native
  and reconstructed runtime, generated plan, independently compiled emitted source, and compatibility behavior.
- Keep only three future types statically named. The explicit compiler then proves the intended missing-module seam
  without cascading through speculative integration members; later private-authority work can make this outer
  contract GREEN before integration advances the same unchanged file to its next failure.
- Route even the test's `Directory.systemTemp` through `run_dart_project_data.sh`: the wrapper supplies a
  repository-volume temp root, and the emitted child package gives its own repository-local `PUB_CACHE`.
- The definitive unchanged-runtime composition passes all eight doctrines, both transaction admissions, every
  typed-source runtime, containment/relocation, CLI 66x2, RAM 56%, and Phase 0 1,031/1,031 in 700 seconds.

- 2026-08-11 (`FUTURE-PARITY-BACKLOG.14.3.4.0.0` — repaired transaction current-boundary policy): rollout-bearing
  prose inside an executable contract must not be validated against a second hand-maintained prose literal. Rust
  admission updated status, availability, rollout, and mutation projections but omitted `policy.current_boundary`;
  because the checker repeated the old text, the canonical gate enforced rather than detected the contradiction.
- Generate the exact boundary from `EXPECTED_ROLLOUT` while retaining explicit backend display names and the existing
  mutation. A future admission now changes the checker expectation at the same rollout edit point and must update the
  JSON or fail. This preserves all semantic/public/admission counts and avoids inventing a new governance domain.
- Preserve exact machine-owned prose when compacting live task and roadmap projections. Two canonical attempts
  rejected dropped capability `.24`/`.24.2` and semantic `128 mutations, rollout 9/9` markers; restoring their full
  governed rows made focused checks pass without weakening a guard. Definitive proof then passes all eight doctrines,
  CLI 66x2, RAM 45%, and Phase 0 1,031/1,031 in 721 seconds.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.3.3` — admitted Rust recognition transactions): admission removes
  dormancy, not behavior. Delete both custom cfgs across the complete source inventory, leave the private authority
  documentation-hidden, and run the already GREEN consumer ordinarily before changing rollout.
- Lock canonical registration as three distinct exact-once markers: tracked file, human-readable log, and the full
  Cargo test command. Mutation-test omission and duplication of each, plus reintroduction of either historical cfg.
- Keep backend movement one row at a time. Rust complete-to-RED and premature Dart promotion are independent
  semantic mutations; later runtime, recurring, and final public-no-drift rows stay RED.
- A public stale-claim guard must enumerate every superseded sentence, not just representative examples. Rust
  admission review found three adjacent Perl-only claims that the previous eight-item inventory missed. Injecting
  each of all eleven forbidden claims as a mutation raises the public proof to 25 and closes that latent gap.
- Treat Rust contract metadata assertions as part of admission. The first ordinary post-promotion run correctly
  failed one stale 41-mutation/RED-rollout assertion while the other 11 tests passed; update it to governed 42 and
  the exact Rust path, then require 12/12 before broader signoff.
- Preserve the distinction between four mutation domains: semantic 42, mdBook public sequence 3/11/25,
  capability guide 1/4/8, and Rust registration/dormancy 8.
- Reverify commands are part of Knowledge authority. Two Perl historical cards still asserted the final-path
  consumer was absent after Perl admission; retain frozen-commit reconstruction but make current verification
  require the exact three canonical registration markers.
- Run every already-admitted consumer after a rollout promotion. Canonical CI correctly caught two stale Perl
  self-assertions after Rust moved to complete; the 51-test consumer now expects neutral+Perl+Rust and remains an
  independent cross-backend drift lock. The outer Codex sandbox separately denied the nested macOS containment
  profile; its isolated proof and one uninterrupted authorized canonical rerun passed, including CLI 66x2, RAM
  77%, and Phase 0 1,031/1,031 in 739 seconds.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.3.2` — integrated Rust recognition transactions): normalize the four
  special forms only after the ordinary expression parser has built their arguments, then replace the complete
  static shape with dedicated nodes. This preserves syntax handling while ensuring `call(Rule)` is never evaluated
  eagerly or retained as a generic helper invocation.
- Carry recognition acceptance through an internal completion channel rather than `RuntimeValue::as_bool`.
  Invocation exit publishes the child's actual match state, while commit separately converts the staged JSON value
  back to a runtime value; successful `false`, zero, empty, and undefined payloads therefore remain distinguishable
  from a miss.
- Treat cursor, anonymous boundary, and the current invocation's same-label mark bucket as one synchronized frame.
  Recursive entry temporarily replaces that mark bucket and restores the caller's bucket on exit; unfinished
  tokens restore their checkpoint before terminal failure is returned to the engine.
- Select emitted-source behavior structurally. Only a compiled tree containing one of the four dedicated nodes may
  replace the legacy compatibility `parse` adapter with the direct effective-engine route; ordinary emitted source
  retains byte-for-byte route selection. The independent child project also needs an empty `[workspace]` section
  because its repository-local location is beneath the parent workspace but it is intentionally not a member.
- Custom-cfg integration must be warning-clean in all three states. Cfg-bound accessors and mutable result rebinding
  belong under the nested predicate; otherwise the outer authority-only build reports dead code and unnecessary
  mutability even though the integration build uses both.
- Run strict Clippy over both changed crates with only enumerated pre-existing categories allowed. That separation
  caught one integration-owned needless `return` after the ordinary compiler had accepted it; fixing the source
  rather than broadening the allowance leaves the nested integration warning-clean.
- Treat the complete gate as signoff over the synchronized integration tree, not as a substitute for focused cfg
  proof. Here the nested 12/12, outer 7/7, ordinary zero-test, complete Rust-local gate, and rendered-book inspection
  precede canonical proof; the latter then passes CLI 66x2, RAM 45%, and Phase 0 1,031/1,031 in 735 seconds.
