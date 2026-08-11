# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

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

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.3.1` — private Rust recognition-transaction authority): keep the
  authority behind the exact dormant consumer cfg until parser/ActionIR integration. A documentation-hidden public
  module gives the final-path integration test access without making ordinary crate builds or docs expose a
  premature runtime surface.
- Use authority-owned shared token/frame state for fail-safe misuse. Cross-source or cross-invocation calls may be
  presented through the wrong authority, but must still restore and invalidate the token's originating frame.
  Pointer identity for the immutable source authority plus authority-local monotonic ids distinguishes those cases;
  `Rc<RefCell<_>>` is sufficient and intentional for this cfg-only, single-thread state machine.
- Keep match acceptance independent from payload presence. A miss discards any supplied payload, while commit may
  return false, zero, empty text, null, or no payload after invalidating the token. Retry, nesting, escape, unwind,
  authority drop, and token drop restore before invalidation so failed control never leaks staged cursor or marks.
- A compile-time RED can mask defects behind its first boundary. Supplying the missing module revealed constructor
  shadowing, six stale abbreviated neutral-contract keys, and a nonexistent partial `syntax` object in the frozen
  consumer. Repair the dormant test only after recording the discovery in its owning leaf, retain every governed
  expectation, and strengthen lifecycle coverage so the next RED is demonstrably the intended integration seam.
- Verification must distinguish three cfg states: ordinary discovery runs zero tests; the outer authority cfg
  passes 7/7; outer plus integration cfg fails only on missing dedicated ActionIR variants/classifiers owned by
  `.14.3.3.2`. The complete Rust gate then proves the cfg-private work did not perturb ordinary behavior.
- Rust evaluates an unknown `cfg` predicate before an item-level lint allowance can take effect. Because this leaf
  deliberately forbids Cargo-manifest/build-script registration, keep the required crate-level allowance explicit
  and reason-annotated; exact source/no-registration checks retain the dormant boundary until the later admission.
- A partitioned task index must be regenerated after the final evidence append, not merely after implementation
  evidence. The first canonical attempt correctly rejected the stale `.14` digest before product tests; after the
  refresh, the complete gate passed CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 701 seconds.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.3.0` — dormant Rust recognition-transaction RED): use a file-level
  custom cfg so the final-path integration target is tracked and syntax-visible to Cargo while ordinary and
  canonical discovery execute zero tests. A second nested cfg can freeze later compiler/runtime/carrier behavior
  without competing with the first missing private-authority boundary.
- Derive the future Rust API from the neutral contract and the admitted Perl mechanism, not from host convenience:
  one source authority owns opaque monotonic invocation/frame/mark/token generations and detached snapshots;
  match presence is distinct from staged payload truthiness; terminal or unwind paths restore before invalidating.
- Freeze all carriers before implementation: dedicated non-eager AST lowering, recursive effect closure,
  cursor-only progress, native and reconstructed execution, generated-plan execution, and independently compiled
  emitted source. The explicit outer cfg must fail solely at missing
  `linkedspec_runtime::recognition_transaction`; any earlier syntax/fixture error invalidates the RED slice.
- Keep technical capability guidance outside the three-page mdBook public-sequence inventory as an explicit
  separate guard. Atomic 187 added current 2/9 prose without deleting its adjacent 1/9 predecessor; two required
  markers, two forbidden stale claims, and six mutations now catch path, marker, duplication, deletion, and both
  stale-text regressions while leaving semantic 41 and public 14 counts stable.
- Definitive signoff must run host-authorized when the canonical storage proof invokes its own macOS sandbox. An
  outer-sandbox run reached that proof but denied nested `sandbox-exec` with status 71; a complete authorized rerun
  passed repository-contained/moved-root IO, both CLI environments at 66/66, RAM 55%, and Phase 0 1,031/1,031 in
  700 seconds. Treat harness denial separately from a repository assertion failure and still rerun the full gate.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.3` — Perl recognition-transaction admission): admission is a
  registry/ledger/public-current slice, not another implementation seam. Require the exact final-path file once,
  syntax-check it once, and execute it once through ordinary `prove`; make all four occurrences omission- and
  duplication-sensitive in the independent checker without changing production Perl.
- A final-path consumer can contain admission-state assertions even when its behavioral proof is already GREEN.
  Advancing neutral-only status and all-backends-unavailable metadata changed exactly two assertions; the other 49
  still prove the integrated ActionIR, effects, tokens, marks, progress, compatibility, and generated-source routes.
- Preserve two distinct mutation domains. The semantic corpus advances 40→41 by retaining premature Rust promotion
  rejection and adding Perl complete→RED regression. The three-page public projection advances 13→14 by separately
  rejecting neutral regression, Perl regression, and premature next-backend promotion.
- Current support is runtime-scoped: Perl now admits the exact `recognition_*` forms, but this does not complete
  recurring or public-no-drift governance and does not make the forms portable to Rust, Dart, Julia, or Lua.
- Treat the full canonical result as the admission boundary: exact registration is insufficient until the same
  staged tree passes CLI 66/66 in both option environments, RAM policy, and Phase 0 1,031/1,031. This slice closes
  at 34% RAM and 733 wall-clock seconds with production implementation bytes unchanged.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.2` — integrated Perl recognition transactions): scan the four special
  forms before generic statement families, but preserve the established lowering-contract metadata order with
  `call` first. Dedicated event arguments are the only source of token/result/static-callee lowering; generic
  assignment and nested call scans must not duplicate or eagerly execute them.
- Run transaction policy only after ordinary final-descriptor construction/validation. The first broad Phase 0 run
  proved why: an earlier hook stole the established malformed-`dependency_refs` diagnostic owner, while placing
  transaction contracts first changed stable public metadata. Preserve both pre-existing contracts, fail closed on
  malformed policy input, then apply recursive effect closure.
- Invocation completion is an internal acceptance channel, not a second result API. Publish child completion only
  while a recognition scope is active, consume it at bcode edges, and keep payload truthiness irrelevant inside
  `recognize_once`. This avoids ordinary parses accumulating unused completion records.
- Progress is stricter only in an active recognition attempt. Accepted repeated edges and same-cursor direct/mutual
  re-entry require `end_offset > start_offset`; marks, bindings, transaction state, and backward movement never
  count. Existing ordinary recursion cutoff and repetition compatibility remain unchanged.
- Internal behavior and admission are separate commits. Production modules enter canonical tracked/syntax
  inventory in `.2`, while `t/recognition_transaction_perl_contract.t` remains undiscovered until `.3`. Public
  prose must describe the internal GREEN proof without promoting neutral rollout 1/9 or an authored capability.
- Identifier-shaped lowering diagnostics are not automatically ordinary helper calls. The canonical coverage gate
  caught the four transaction intrinsics after implementation; classify those exact grammar-owned dedicated nodes
  alongside the nine established non-public contracts, require their Perl presence and helper-inventory absence,
  and keep the shared inventory at 246 with all 122 ordinary public calls independently covered.
- Definitive composition after that repair passes all eight doctrines, repository-contained and relocated process
  proofs, both primary CLI environments at 66/66, RAM 58%, and Phase 0 at 1,031/1,031 in 727 seconds. Keep the
  GREEN final-path consumer absent from canonical discovery until the separate admission leaf.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.1` — private Perl transaction authority): follow the typed-source
  inside-out pattern for linear transaction state. Opaque scalar handles prevent caller-visible owner hashes while
  module-owned tables retain source authority, invocation/generation identity, snapshots, attempt state, staged
  payload presence/value, and terminal status. Detached frame snapshots clone marks before crossing the seam.
- Invocation frames must be distinct from current rule-label mark buckets before either is wired together. Fresh
  frame marks plus monotonic non-reused ids prove recursive same-label isolation privately; `.14.3.2.2` must route
  live marks and child entry/exit through that owner atomically rather than partially shadowing legacy buckets.
- Dynamic misuse is restore-before-report. Escape, retry, cross-authority use, missing terminal, token/frame drop,
  and nesting restore the owning snapshot and clear active-token ownership before a typed neutral diagnostic or
  destructor return. Commit alone retains candidate state, and it invalidates before exposing staged payload.
- Canonical execution of `t/recognition_transaction_perl_authority.t` is a private foundation proof, not backend
  admission. Keep the final-path `t/recognition_transaction_perl_contract.t` absent until `.14.3.2.3`; its unchanged
  four-node RED is the mechanical guard against confusing an internal module with authored/runtime support.
- Definitive signoff preserves that separation across all eight doctrines, repository-contained and relocated
  runtime proofs, both CLI environments at 66/66, RAM 71%, and Phase 0 at 1,031/1,031 in 688 seconds. Rendered
  documentation explicitly says private prerequisite rather than authored support, and generated book output is
  removed after inspection.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.2.0` — dormant Perl transaction RED): the accepted four-form specimen
  already passes bootstrap/descriptor construction, so do not describe the current boundary as missing grammar.
  Current scalar assignment lowering hides checkpoint, attempt, and commit behind three unsupported-helper
  sentinels, while statement-only rollback falls through as raw Perl. Require all four dedicated `RECOGNITION_*`
  nodes, zero unresolved helpers, zero raw dependencies, and language-agnostic readiness as one atomic RED seam.
- A dormant consumer should execute stable neutral facts before its implementation boundary. Here 49 assertions
  independently lock the authored strings, 8/17 token fixtures, six effect graphs, six mark cases, eight progress
  cases, 9/11 effects, fifteen codes/fields, and exact counts before one RED assertion. The later live/generated
  behavior stays behind one skip, so current canonical CI remains green without weakening future coverage.
- Keep admission mechanically distinct from final-path tracking. Explicit commands in `tools/run_ci_local.sh`
  define ordinary/canonical Perl discovery; a tracked `t/*.t` file is dormant when those registries contain zero
  references. Stage it before canonical signoff so the tracked-input audit sees the final repository shape, but
  do not register or execute it until `.14.3.2.3`.
- Definitive signoff proves that staging a dormant final-path consumer does not silently admit it: all eight
  doctrines, repository-contained six-family process I/O, moved-root/outside-CWD execution, both CLI environments
  at 66/66, RAM 69%, and Phase 0 1,031/1,031 in 672 seconds pass while the consumer still has zero registry
  references and retains its exact intended RED result.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.1.2.0` — public sequence governance): derive documentation status from
  the semantic artifact's rollout instead of duplicating it as an independent claim. The guard requires neutral
  complete and every non-neutral leg RED before checking exact page markers, so public prose cannot move ahead of
  or lag behind rollout without one deterministic failure.
- Keep semantic and public mutation accounting separate. The JSON still owns forty syntax/token/effect/inventory/
  rollout mutations; the checker owns thirteen additional in-memory public inventory/marker/claim/text/rollout
  mutations. This preserves contract identity while making the three-page milestone order fail closed.
- `git ls-files --error-unmatch` is the right tracked-source proof here: all public inputs remain root-relative,
  exact, and canonical without introducing a new tool entrypoint or widening project-storage topology.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.1.2` — rendered milestone-order repair): status statements can each be
  historically correct yet become contradictory when a later slice inserts new truth without retiring old
  sequencing prose. Commit `7c2ff407` said the neutral checker was next; `e0cc7182` inserted its executable status
  two paragraphs earlier but missed the original sentence. Source-only searches did not expose the juxtaposition;
  rendered paragraph inspection did.
- The neutral checker's `current_boundary` mutation protects artifact policy and false current-capability claims,
  not mdBook milestone ordering. Do not widen the semantic artifact's exact 40-mutation boundary during a public-
  text repair. Correct the sentence narrowly, preserve the cause, and let `.14.3.1.2.0` add a separate governed
  public-sequence projection with its own mutation proof before backend work.
- Definitive recomposition signoff passes all eight doctrines, exact repository-contained process and moved-root
  proofs, primary CLI 66x2, RAM 59%, and Phase 0 1,031/1,031 in 695 seconds without changing an executable owner.

- 2026-08-10 (`FUTURE-PARITY-BACKLOG.14.3.1.1` — executable neutral recognition transactions): distinguish
  inventory domains before freezing counts. Perl currently exposes 128 unique canonical ActionIR node kinds, while
  the language coverage checker reports 122 public identifier-shaped Perl call contracts and 246 aligned
  cross-backend call names. Treating 122 as the node count would silently omit six node kinds; the new Knowledge
  card and checker preserve the distinction.
- A single base-effect row must be conservative across overloaded call spellings. `split`, `set_key`, and array-end
  mutation calls therefore classify as aggregate writes even where a value-only form can return a copy; `with`
  and tree traversal classify as dynamic callables; compatibility save/restore/rewind never masquerade as
  transaction state. Readable rows live in the artifact, while independent canonical digests reject reclassification.
- Falsey-safe recognition requires two channels. `recognize_once` returns only a strict accepted bit, while commit
  retrieves the separately staged payload; `false`, `0`, empty string, and `undef` are four successful payloads.
  Ordinary `CALL` results cannot be reinterpreted by truthiness and compatibility cursor helpers have no token,
  invocation generation, staged result, effect barrier, or progress authority.
- Recursive effect analysis is a monotone set-union fixed point over named rules, not depth-first sampling. This
  terminates for direct and mutual SCCs and ensures a forbidden transitive callee remains visible. Progress is a
  separate cursor-edge obligation: effect, variable, mark, or transaction-state changes never substitute for
  `end_offset > start_offset` on accepted repetition or recursive-cycle edges.
- The neutral artifact is deliberately executable before any parser understands its syntax. Canonical CI proves
  132 node rows, 246 call rows, token 8/17, graphs 6, marks 6, progress 8, diagnostics 15, and 40 mutations while
  rollout remains 1/9. This isolates target-contract mistakes from six later backend implementations and prevents
  neutral proof from being misreported as current authored capability.
- Definitive signoff must run where the gate can apply its own `sandbox-exec` profile. An outer sandbox correctly
  blocked nested profile application with `Operation not permitted`; the unchanged host-authorized rerun passed
  repository-contained process I/O, moved-root execution, CLI 66x2, RAM 55%, and Phase 0 1,031/1,031 in 675
  seconds. Treat that first result as an execution-context denial, never as permission to weaken containment.

- 2026-08-10 (`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4` — unchanged four-store recomposition): the four routed
  records already have their final normal shape: `state=current`, bounded controls, executable verifiers, and
  empty `baseline`/`transition` objects. Closeout therefore must not invent another transition ADR, rewrite the
  migration owners, or refresh old debt facts. It independently composes the committed history/task/consumer/
  rollover/route checks and updates only durable status/frontier owners. This preserves the exact contracts while
  proving they work together and returns product work to `FUTURE-PARITY-BACKLOG.14.3.1.1` after the clean commit.
- The first closeout canonical run rejects a shortened `docs/TASK_TREE.md` future-backlog row because it dropped
  the capability checker-owned marker “exclusion public closeout `.24.2` remains closed”. The parent `.24`
  statement is not an equivalent projection. The focused rerun then rejects “remains public-closed” in place of
  the exact parent “is public-closed” marker. Restore both exact projections and rerun the focused consumer plus
  the complete canonical gate; do not weaken the checker or classify either failure away.
- Corrected closeout signoff passes capability 80/0/0 and one uninterrupted definitive repository-volume gate:
  all eight doctrines, MCP complete/141, Rust semantic 1/1 in 85.71 seconds, Julia semantic 416/416 in 29.9
  seconds, cursor 288, process containment, moved-root execution, CLI 66x2, RAM 49%, and Phase 0 1,031/1,031 in
  673 seconds. The two failures therefore remain useful exact-projection regression evidence, not open blockers.

- 2026-08-10 (`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3` — bounded chronology hot stores): reverse-chronological
  roots need insertion headroom that immutable legacy segment IDs cannot provide after landing. Changes and notes
  therefore reserve initial archive IDs from `5000` upward. Each later rollover removes only an exact suffix of
  complete records already present at clean HEAD, assigns the next lower ID, and prepends that content-addressed
  segment to the manifest. IDs remain ascending in manifest/read order while later rollover generations naturally
  sort before older history; the reserve supports 4,999 rollovers without renaming an immutable target.
- Initial legacy records may split at any line because their only rendering contract is exact reconstruction.
  Once the bounded roots exist, `CHANGES.md` rolls only at `^## ` and engineering notes at a dated-entry or `^## `
  boundary. The rollover tool rejects rewritten/reordered HEAD records and refuses to archive uncommitted entries,
  so every new segment is an exact Git-addressable source suffix rather than conversational or working-tree state.
- Warning, action, and completion are distinct: 80% reports pressure without failing; 90% requires rollover; the
  resulting root must be at or below both 256 lines and 32,768 bytes. The doctrine independently rejects a root at
  the action boundary, so the author workflow cannot defer rollover into the next slice.
- Exact legacy notes include historical trailing spaces. Archive reconstruction forbids normalization, so the
  existing raw-segment attribute exempts only `docs/history/**/segment-*.md` from blank-at-EOL/EOF reporting.
  Current hot roots and every non-archive path remain under the ordinary whitespace gate.
- Pre-signoff review found the first rollover draft published the bounded root before its manifest. An
  interruption in that window could remove current records before the query index named their already-written
  segment. The corrected transaction publishes segment, then manifest, then root. A rerun accepts an exact orphan
  segment or recognizes the exact pending first manifest record and completes the retained-root installation;
  mismatched existing bytes fail closed. Thus every interruption point retains either the unchanged author root or
  a fully queryable archive generation, and recovery is deterministic.
- Definitive signoff uses one uninterrupted approved repository-volume gate: all eight doctrines, six-family
  containment, moved-root/outside-CWD execution, both 66-case CLI option environments, the 51% RAM checkpoint,
  and Phase 0 at 1,031/1,031 in 716 seconds pass before the atomic commit workflow begins.
