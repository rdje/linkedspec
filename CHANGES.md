# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.5.3 — admit Julia recognition transactions

- Registered the unchanged 203-assertion final-path Julia consumer exactly once in ordinary package discovery and
  canonical CI. Removed both environment selectors and the conditional integration wrapper; all authority,
  ActionIR, effect/progress, native, reconstructed, generated-plan, and emitted-module assertions now always run.
- Retained the implementation boundary as private: the consumer explicitly reaches the source-local
  `LinkedSpecJulia.RecognitionTransaction` namespace, while the public facade still exports no transaction API.
- Promoted only Julia in the neutral rollout and synchronized the mutable status, availability, mutation, rollout,
  and later-RED assertions in the admitted Perl, Rust, Dart, and Julia consumers. PUC Lua and LuaJIT remain next.
- Advanced executable governance to 132 ActionIR rows / 246 calls / 44 semantic mutations and rollout 5/9. Exact
  Julia registration/privacy/dormancy proof rejects 14 mutations; public governance is 3/17/33 and the distinct
  capability guide is 1/8/12.
- Updated the capability guide and sole-facing book to teach that the four authored recognition forms are current
  on Perl, Rust, Dart, and Julia while both Lua runtimes, recurring composition, and final no-drift remain RED.
- Focused proof passes the neutral checker, Julia 203/203, Perl 51/51, Rust 12/12, Dart 10/10, and the complete
  Julia package/primary/105-fixture gate. The 79-file / 14,404-KiB book and all eight doctrines pass; definitive
  canonical proof passes repository containment/relocation, CLI 66x2, RAM 69%, Phase 0 1,031/1,031 in 738 seconds,
  and the exact `[ci] local CI gate passed` marker.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.5.2 — integrate Julia recognition transactions

- Added four dedicated Julia ActionIR nodes for checkpoint, non-eager static recognition, commit, and rollback.
  Exact forms normalize after ordinary argument parsing; `call(Rule)` is retained only as a static child label and
  never enters the ordinary callable-helper inventory or dispatch path.
- Extended the private authority with the neutral recursive effect fixed point, cursor-only progress validator,
  detached state access, and exact missing-token diagnostics. Six effect graphs and eight progress cases pass.
- Added one private frame adapter around every Julia rule invocation. It synchronizes the existing UTF-8 code-unit
  cursor, anonymous capture boundary, and fresh same-label mark bucket while retaining separate match/payload state.
- Routed native, reconstructed, generated-plan, and independently loaded emitted-module execution through the same
  effective engine. A successful child payload of `false` stays matched and survives commit on every carrier.
- The unchanged explicit integration consumer passes 203/203 and authority remains 155/155. The namespace stays
  unexported and the consumer stays outside ordinary/canonical discovery, so recognition remains 132/246/43 at
  rollout 4/9 with public 3/14/29 and guide 1/6/10 unchanged.
- Complete Julia passes package tests, typed source 127/127, storage 19/5, primary CLI, and corpus 105/105. The
  synchronized mdBook renders 79 files / 14,404 KiB and its reproducible output is removed.
- Definitive signoff passes all eight doctrines, canonical containment/relocation and CLI 66x2, RAM 65%, Phase 0
  1,031/1,031 in 731 seconds, and the exact `[ci] local CI gate passed` marker.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.5.1 — add private Julia transaction authority

- Added non-exported `LinkedSpecJulia.RecognitionTransaction` immediately behind the existing private source-
  location authority. One source-local owner allocates monotonic invocation, mark, and transaction generations and
  returns opaque frame/token handles over copied cursor, nullable boundary, and invocation-local mark state.
- Kept match presence separate from staged payload, so `false`, zero, empty string, and `nothing` remain successful
  values. Commit retains staged state; rollback, discard, escape, retry, cross-owner use, forbidden nesting, and
  unwind restore before monotonic terminal invalidation.
- Added detached frame snapshots and exact portable lifecycle diagnostics without adding a public export. The
  unchanged explicit authority consumer passes 155/155.
- Preserved the `.14.3.5.2` boundary: integration mode first observes zero dedicated transaction nodes; its missing
  effect/progress classifiers and unsupported runtime helper route remain untouched. The consumer remains outside
  ordinary and canonical discovery.
- Complete current Julia passes typed source 127/127, storage 19/5, primary CLI, and corpus 105/105. Recognition
  remains 132/246/43 at rollout 4/9, public 3/14/29, and guide 1/6/10; native UTF-8 code-unit registers/results,
  schemas, APIs, CLI, README, project storage, and every other backend remain unchanged.
- Definitive signoff passes the synchronized 79-file / 14,404-KiB book, all eight doctrines, complete canonical
  admission/containment/relocation and CLI 66x2 proof, RAM 68%, Phase 0 1,031/1,031 in 747 seconds, and the exact
  `[ci] local CI gate passed` marker.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.5.0 — freeze Julia transaction RED

- Added one dormant final-path Julia consumer for the complete neutral recognition-transaction contract: private
  invocation/frame authority, opaque linear tokens, detached cursor/boundary/mark state, falsey-safe payloads,
  portable diagnostics, four dedicated non-eager nodes, effect/progress policy, all required carriers, and ordinary
  cursor compatibility.
- Split the unchanged consumer into explicit `authority` and nested `integration` modes. Both parse completely and
  exit 1 only because private `LinkedSpecJulia.RecognitionTransaction` is absent; `.14.3.5.1` can make authority
  mode green before `.14.3.5.2` exposes and closes the integration seams.
- Kept the final-path file outside the explicit `julia/test/runtests.jl` include list and canonical registration.
  No production Julia, export, neutral contract/checker, schema, API, CLI, README, or other-backend source changed.
- Used an independently loaded `Base.include_string` host module for emitted-source proof, adding no temporary owner.
  The complete current Julia gate remains green at storage 19/5, primary CLI, and corpus 105/105.
- Preserved UTF-8 code-unit registers/results, recognition 132/246/43, rollout 4/9, public 3/14/29, guide 1/6/10,
  ordinary/canonical discovery, project-data topology, and current mdBook support claims. Clarified in the book
  that a neutral checker defines a contract while an admission consumer plus ordinary/canonical registration proves
  backend support; no support status changed.
- The first canonical run caught one exact semantic-status marker wording drift. After repair, the full rerun passed
  all eight doctrines, transaction/typed-source/MCP/semantic admissions, containment/relocation, CLI 66x2, RAM 60%,
  Phase 0 1,031/1,031 in 724 seconds, and `[ci] local CI gate passed`.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.4.3 — admit Dart recognition transactions

- Moved the unchanged 10-test consumer to `dart/test/recognition_transaction_contract_test.dart`, removed its
  environment/skip dormancy, and kept the private authority absent from the package facade.
- Canonical CI now requires, logs, and executes the exact project-data-routed Dart consumer once. Thirteen
  independent mutations reject marker omission/duplication, dormant path/switch/skip residue, missing private
  import, or accidental public export.
- Promoted only Dart to complete. Recognition is now 132 ActionIR rows / 246 calls / 43 semantic mutations with
  rollout neutral + Perl + Rust + Dart 4/9; Julia, PUC Lua, LuaJIT, recurring, and final public no-drift remain RED.
- Updated the admitted Perl and Rust consumers' contract metadata assertions to the same Dart-current status,
  availability, mutation count, rollout path, and later-RED boundary; their runtime behavior remains unchanged.
- Synchronized the three-page public projection to 14 forbidden claims / 29 mutations and the capability guide to
  1 document / 6 forbidden claims / 10 mutations. No later-runtime or complete-portability claim advances.
- Preserved UTF-16 registers/results, compatibility cursor behavior, schemas, public APIs, CLI, README, and
  project-storage ownership. The ordinary consumer preserves a successful `false` payload through native,
  reconstructed, generated-plan, and freshly analyzed emitted-source execution.
- Complete Dart passes format 100/0, fatal analysis, ordinary 393/393, storage 21/47, CLI 66x2, and corpus 105/105.
- The first canonical attempt caught the admitted-consumer metadata coupling by rejecting stale Perl/Rust snapshots;
  after aligning both, they pass 51/51 and 12/12. A full host-permitted rerun passes all eight doctrines,
  repository containment/relocation, CLI 66x2, RAM 60%, Phase 0 1,031/1,031 in 694 seconds, and the exact success marker.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.4.2 — integrate Dart recognition transactions

- Added four dedicated Dart ActionIR nodes for checkpoint, non-eager static recognition, commit, and rollback.
  Exact valid forms normalize after ordinary argument parsing; `call(Rule)` is retained as structure and never
  enters the ordinary callable-helper registry or aligned 246-name inventory.
- Extended the private authority with backend-state synchronization, recursive fixed-point effect classification,
  cursor-only repetition/recursion progress validation, detached state reads, and exact missing-token reporting.
- Added one invocation adapter around every Dart rule execution. It replaces/restores same-label mark buckets,
  synchronizes live UTF-16 cursor and anonymous boundary registers, retains staged falsey payloads, and restores
  unfinished checkpoints before terminal failure and cleanup.
- Routed native, serialized reconstruction, generated-plan, and freshly analyzed emitted-source execution through
  the same effective engine path. A successful child payload of `false` stays matched and returns `false` at commit.
- The unchanged enabled dormant consumer now passes 10/10; default explicit execution remains 6 pass / 4 skipped.
  The private module remains absent from the facade and the consumer remains outside ordinary/canonical discovery.
- Preserved neutral 132/246/42, rollout 3/9, public 3/11/25, guide 1/4/8, existing UTF-16/result behavior, schemas,
  APIs, CLI, README, and project-storage topology. Dart admission remains solely owned by `.14.3.4.3`.
- Complete Dart passes format 100/0, fatal analysis, ordinary 383/383, storage 21/47, CLI 66x2, and corpus 105/105.
  The synchronized book renders 79 files / 14,396 KiB with the private-integrated/not-admitted boundary, then its
  reproducible output is removed.
- Definitive CI exits 0 after all eight doctrines, capability 80/0/0, MCP complete/141, repository containment and
  relocation, both primary CLI environments at 66/66, RAM 64% below the 88% threshold, Phase 0 1,031/1,031, and
  the exact local-CI success marker.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.4.1 — add private Dart transaction authority

- Added unexported `dart/lib/src/runtime/recognition_transaction.dart` over the existing immutable source authority.
  Opaque frames and tokens retain monotonic invocation, mark, and transaction generations without a facade export.
- Implemented detached cursor/boundary/mark snapshots, recursive same-label isolation, strict match/payload state,
  exactly one attempt and terminal, commit retention, rollback restoration, and explicit token discard.
- Restored before invalidating on retry, escape, cross-source/invocation use, nesting, missing terminal, and discard;
  the frozen exception type returns exact detached neutral fields and portable error strings.
- Removed the temporary analyzer exclusion. The dormant target now passes 6 authority tests with exactly 4
  integration skips, and strict fatal analysis reports no issues.
- Added one explicit integration-RED environment switch. It exits 1 only at the four `.14.3.4.2` seams: missing
  dedicated nodes, effect/progress methods, native runtime dispatch, and emitted runtime dispatch.
- The first complete Dart gate exposed atomic 193's git-only temporary-owner census gap. Registered the dormant
  emitted-source test as owner 21 and made the oracle include non-ignored untracked Dart sources before first commit.
- Kept the module outside the public facade and the consumer outside ordinary/canonical discovery. Production
  parsing, UTF-16 registers/results, recognition 132/246/42, rollout 3/9, and all existing surfaces remain unchanged.
- Corrected Dart-local proof passes format 100/0, strict analysis, ordinary 383/383, storage 21/47, CLI 66x2, and
  corpus 105/105. The synchronized book renders 79 files / 14,392 KiB in separate current/future blocks and is removed.
- Definitive CI passes all eight doctrines, capability 80/0/0, semantic 128/9/9, MCP complete/141,
  repository containment/relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 697 seconds.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.4.0.1 — freeze Dart transaction RED

- Added one dormant final-path Dart consumer for the complete neutral recognition-transaction contract: authority
  generations and snapshots, falsey-safe match/payload state, token/mark/lifecycle diagnostics, dedicated
  non-eager ActionIR, effect/progress policy, all four execution carriers, and ordinary cursor compatibility.
- Froze the next boundary at one absent private package module and its three named authority/state/exception types.
  The explicitly routed test exits 1 only there; the exact analyzer exclusion remains warning-clean.
- Kept the consumer outside ordinary and canonical discovery. Fatal Dart analysis reports no issues, all 383
  ordinary tests pass, and neither canonical driver names the dormant file.
- Preserved all production Dart bytes, UTF-16 registers/results, recognition 132/246/42, rollout 3/9, public
  3/11/25, guide 1/4/8, schemas/APIs/CLI/README/storage, and current mdBook behavior.
- Dart-local passes format/analyze, 383 tests, storage, CLI 66x2, and corpus 105. The unchanged book renders 79
  files / 14,380 KiB and is removed after exact inspection. Definitive CI passes eight doctrines, Perl 51, Rust 12,
  all typed-source runtimes, capability 80/0/0, semantic 128/9/9, MCP complete/141, containment/relocation, CLI
  66x2, RAM 56%, and Phase 0 1,031/1,031 in 700 seconds before the exact success marker.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.4.0.0 — repair transaction boundary policy

- Dart RED retrieval found the neutral contract internally contradictory after Rust admission: status, authored
  availability, and rollout said neutral+Perl+Rust 3/9, while `policy.current_boundary` still called Rust unavailable.
- Blame and the `02c612f5` admission diff proved the policy field was omitted, and the checker duplicated the stale
  Perl-only literal; canonical validation therefore passed while positively enforcing the contradiction.
- Corrected the JSON to current Perl+Rust truth and made the checker derive that exact prose from `EXPECTED_ROLLOUT`,
  so later admission changes cannot leave an independent earlier boundary behind.
- Preserved transaction 132 ActionIR / 246 calls / 42 mutations, rollout 3/9, public 3/11/25, guide 1/4/8, Rust
  admission 8, every runtime, production behavior, schema/API/CLI/storage surface, and sole-facing support claim.
- Two pre-definitive canonical attempts rejected public markers dropped during task/roadmap compaction; restoring
  the exact capability `.24`/`.24.2` and semantic `128 mutations, rollout 9/9` projections kept their checkers
  strict. The uninterrupted definitive rerun passes all eight doctrines, Perl transaction 51/51, Rust 12/12,
  every typed-source runtime, capability 80/0/0, semantic 128/9/9, MCP complete/141, containment/relocation, CLI
  66/66 twice, RAM 45%, and Phase 0 1,031/1,031 in 721 seconds before exact `[ci] local CI gate passed`.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.3.3 — admit Rust recognition transactions

- Activated task-tree-first from clean Rust-integration commit `1cf2923a` as intended atomic 191/300.
- Removed both dormant recognition-transaction custom cfgs from the exact nine-source Rust inventory. The private
  authority remains documentation-hidden, while the already integrated nodes, policy, runtime, and emitted carrier
  now compile and execute in ordinary builds.
- Made the unchanged final-path consumer ordinary at 12/12 and added one exact canonical require/log/Cargo command.
  Eight independent mutations reject missing or duplicate registration and either stale outer/nested cfg.
- Promoted only Rust to complete. Recognition is now 132/246/42 with rollout neutral + Perl + Rust 3/9; Dart,
  Julia, PUC Lua, LuaJIT, recurring composition, and final public no-drift remain RED.
- Updated the three governed mdBook pages to current Perl/Rust behavior. Review found three adjacent Perl-only
  claims outside the previous guard; the exhaustive public inventory is now 3 documents / 11 forbidden claims /
  25 mutations. The separate capability guide advances to 1/4/8.
- Preserved helper results/registers, schemas, semantic/MCP/capability/CLI surfaces, README, all later backends,
  and the documentation-hidden Rust authority API boundary.
- Focused proof passes the neutral checker, ordinary Rust consumer 12/12, formatting, strict changed-crate Clippy,
  and the complete Rust-local gate including core 195, runtime 166, recognition 12, project-data locality, and CLI
  66/66 in both option environments.
- The first canonical pass caught two stale rollout/availability expectations in the exact Perl consumer; after
  synchronizing them, the full authorized rerun passes Perl 51/51, Rust 12/12, containment, relocation, CLI 66x2,
  RAM 77%, and Phase 0 1,031/1,031 in 739 seconds before exact `[ci] local CI gate passed`.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.3.2 — integrate Rust recognition transactions

- Activated task-tree-first from clean private-authority commit `fd8a1934` as intended atomic 190/300.
- Added four cfg-private, dedicated, non-eager expression nodes with exact authored-form normalization, recursive
  structural discovery, stable serialization/reconstruction, and neutral-derived recursive-effect/cursor-progress
  classifiers.
- Bound native and generated-plan execution to the existing source-local private authority over real cursor,
  anonymous boundary, recursive same-label invocation marks, linear tokens, explicit child acceptance, and falsey-
  safe staged payloads. Invocation exit restores unfinished snapshots on both success and error paths.
- Kept generated source on its ordinary compatibility route unless structural AST inspection finds a transaction;
  transaction-bearing source reuses the direct effective engine and passes an independently compiled repository-
  local emitted project. Added the missing empty workspace declaration to that transient project manifest.
- Made the nested final-path contract GREEN at 12/12 across native, serialized reconstruction, generated plan,
  emitted source, static policy, and compatibility proof. The outer authority contract remains 7/7; ordinary Cargo
  remains zero-test and warning-clean.
- Preserved all manifests/canonical registrations, Perl and every other backend, recognition 132/246/41, rollout
  2/9, public 3/8/14, guide 1/2/6, schemas, helper results/registers, APIs, CLI, README, and current Perl-only public
  support. Rust admission remains exclusively owned by `.14.3.3.3`.
- Formatting, strict changed-crate Clippy, the complete Rust local gate, repository-local storage/relocation, and
  rendered mdBook proof pass. Rust-local coverage includes 195 core, 166 runtime, 105/105 corpus, 197 integration,
  every focused group, ordinary transaction discovery at zero tests, and CLI 66/66 twice.
- Definitive canonical signoff passes all eight doctrines, every mandatory neutral/cross-runtime/storage/relocation
  proof, CLI 66/66 in both option environments, RAM 45%, and Phase 0 1,031/1,031 in 735 wall-clock seconds before
  exact `[ci] local CI gate passed`.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.3.1 — add private Rust transaction authority

- Activated task-tree-first from clean dormant-RED commit `cb9420b1` as intended atomic 189/300.
- Added one documentation-hidden Rust module behind the existing outer custom cfg. Its source-local authority owns
  opaque monotonic invocation/frame/mark/token generations, detached cursor/boundary/mark snapshots, exactly-once
  attempt state, falsey-safe payload staging, commit/rollback, and restore-before-invalidate terminal cleanup.
- Made the outer dormant consumer GREEN at 7/7 while ordinary Cargo still runs zero tests. The nested two-cfg
  consumer now stops only at `.14.3.3.2` missing dedicated ActionIR variants and effect/progress classifiers.
- Repaired test-only defects masked by the prior missing-module compiler stop: two constructor-shadow sites, six
  stale abbreviated neutral JSON keys, and one incomplete stale authored-surface assertion. Added explicit nesting
  and token-drop restoration proof without changing the frozen semantic contract.
- Preserved every ordinary Rust parser/compiler/runtime/emitter route, Cargo manifest and canonical registration,
  other backends, recognition 132/246/41, rollout 2/9, public 3/8/14, guide 1/2/6, schemas, APIs, CLI, and README.
- Formatting, strict new-module Clippy, exact cfg/next-RED proofs, and the complete Rust local gate pass, including
  195 core and 166 runtime unit tests, 105/105 corpus cases, 197 integration cases, storage containment, binary
  build, and CLI 66/66 in both option environments.
- Definitive canonical signoff passes all eight doctrines, every mandatory cross-runtime/storage/relocation proof,
  CLI 66/66 in both option environments, RAM 65%, and Phase 0 1,031/1,031 in 701 seconds before exact
  `[ci] local CI gate passed`.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.3.0 — freeze Rust transaction RED

- Activated task-tree-first from clean Perl-admission commit `a0595411` as intended atomic 188/300.
- Added one final-path Rust consumer behind outer private-authority and nested integration custom cfgs. Ordinary
  Cargo discovers the target and runs zero tests; no manifest or canonical-driver registration activates it.
- Froze neutral-derived invocation/frame/token/snapshot ownership, falsey-safe payloads, mark restoration,
  lifecycle/authority diagnostics, four dedicated ActionIR forms, effect/progress policy, and native,
  reconstructed, generated-plan, independently compiled emitted-source, and compatibility carriers.
- Explicit outer-cfg execution reaches one deterministic first compiler boundary only: `E0432` for missing
  `linkedspec_runtime::recognition_transaction`, the private authority owned by `.14.3.3.1`.
- Preserved production Rust and every other backend, neutral 132/246/41, rollout 2/9, public sequence 3/8/14,
  language coverage 246/105+1/122, README, mdBook current claims, schemas, APIs, storage, and workflow state.
- Repaired a contradictory capability-guide paragraph left by atomic 187: current neutral+Perl 2/9 guidance had
  been appended above stale neutral-only 1/9/all-backends-unavailable text. A separate 1-document/2-forbidden/
  6-mutation checker guard now prevents recurrence without changing semantic or mdBook-public mutation domains.
- Focused Rust, explicit RED-shape, language, task, Knowledge, memory, doctrine, storage, and rendered-book proof
  pass. The host-authorized definitive gate passes repository containment and moved-root proof, CLI 66/66 in both
  option environments, RAM 55%, Phase 0 1,031/1,031 in 700 seconds, and exact `[ci] local CI gate passed`.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.2.3 — admit Perl recognition transactions

- Activated task-tree-first from clean integration commit `e173bbcb` as intended atomic 187/300.
- Promoted only the `perl` recognition-transaction rollout row and bound its exact final-path consumer. The neutral
  checker now rejects 41 semantic mutations, including independent Perl complete-to-RED regression, while Rust,
  Dart, Julia, PUC Lua, LuaJIT, recurring, and public-no-drift remain RED at rollout 2/9.
- Canonical CI now requires, syntax-checks, and executes `t/recognition_transaction_perl_contract.t` exactly once.
  Its 51 tests remain behaviorally identical; only the neutral-only status and all-backends-unavailable metadata
  assertions advance to the admitted state.
- Advanced the three governed mdBook pages from implemented-but-unadmitted Perl to current Perl support without
  implying cross-runtime portability. Public sequence proof is now 3 documents / 8 forbidden claims / 14
  mutations, with separate neutral, Perl-regression, and premature-next-backend guards. The rendered book is 79
  files / 14,368 KiB with distinct status/command/limitation blocks and is removed after inspection.
- Preserved all production compiler/runtime/generated-source modules, exact 132 ActionIR / 246 call inventories,
  fixtures, helper results/registers, schemas, semantic/MCP/capability/CLI surfaces, README, and project-data roots.
- Definitive canonical CI passes all eight doctrines, the exact Perl consumer, every mandatory cross-runtime and
  storage/relocation proof, CLI 66/66 twice, RAM 34%, and Phase 0 1,031/1,031 in 733 wall-clock seconds before the
  exact local-gate pass marker. Perl parent `.14.3.2` is composition-complete; Rust RED `.14.3.3.0` is next.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.2.2 — integrate Perl recognition transactions

- Activated task-tree-first from clean private-authority closeout `8138bea5` as intended atomic 186/300.
- Added four dedicated ActionIR scanner/lowering contracts with exact token/result/static-callee arguments and no
  duplicate generic assignment or eager nested-call lowering. A closed 132-node policy runs after established
  descriptor validation, checks linear source/path shape, and computes transitive named-rule effects to a recursive
  fixed point before rejecting dynamic, forbidden, or unknown recognition.
- Bound every live/emitted handler invocation to source-local private frames, real cursor/anonymous-boundary/marks,
  recursive same-label mark replacement/restoration, and a child-completion acceptance channel independent of
  false, zero, empty, or undef payloads. Commit retains synchronized candidate state; rollback/unwind restore.
- Added transaction-scoped cursor-only progress enforcement for accepted repetition and direct/mutual recursive
  cycles while preserving one-shot zero-width recognition and ordinary compatibility behavior.
- Extended the dormant final-path consumer first, recorded its deterministic 49-pass/one-fail/one-skip RED, then
  made it GREEN at 51 outer tests including independently loaded generated source. It remains deliberately absent
  from ordinary/canonical execution until admission `.14.3.2.3`.
- The first canonical-gate attempt reached exhaustive language coverage and exposed the four new identifier-shaped
  diagnostics as unclassified. Classified them exactly as grammar-owned dedicated intrinsics, kept them out of the
  246-name ordinary helper inventories, and restored the independent result to 122/122 public Perl calls.
- Kept neutral rollout 1/9 and public-current claims RED. Canonical CI tracks/syntax-checks only the production
  integration modules and passes both CLI environments at 66/66, RAM 58%, and Phase 0 1,031/1,031 in 727 seconds;
  the final-path consumer stays unregistered until `.14.3.2.3`.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.2.1 — add private Perl transaction authority

- Activated task-tree-first from clean dormant-RED closeout `59306f37` as intended atomic 185/300.
- Added private inside-out `LinkedSpec::RecognitionTransaction` authority with opaque scalar authority/frame/token
  handles, monotonic non-reused invocation/mark/transaction generations, fresh same-label recursive mark tables,
  detached cursor/boundary/mark snapshots, strict match/payload separation, and terminal invalidation.
- Restored owning snapshots before reporting token escape, retry, missing terminal, nesting, cross-invocation/source,
  and strict-boolean violations. Commit invalidates before returning falsey-safe staged payload; rollback, unwind,
  frame/token destruction, and dynamic misuse discard payload and fail safe without aliasing compatibility state.
- Added a neutral-derived private test with 293 nested TAP assertions over all eight positive cases, all eight
  explicit escape classes, recursive generation isolation, lifecycle/authority misuse, exact diagnostic fields,
  and compatibility cursor-stack/rule-label-mark independence.
- Registered only that private unit proof for canonical tracking, syntax, and execution. The final-path Perl
  consumer remains unregistered and byte-exact at 49 pass / one four-node failure / one skip; neutral stays
  132/246, token 8/17, graphs 6, marks 6, progress 8, diagnostics 15, mutations 40, rollout 1/9, public 3/8/13.
- Updated architecture, Knowledge, roadmaps, task/index, continuity, and the sole-facing book to distinguish private
  foundation from current authored support. Changed no public facade, grammar, compiler, ActionIR, SpecEntry,
  RuntimeContext, generated source, capability/semantic/MCP/CLI/schema, README, storage, workflow, or current result.
- Definitive local CI passes all eight doctrines, repository-contained six-family process proof, moved-root and
  outside-CWD execution, both CLI environments at 66/66, RAM 71%, and Phase 0 1,031/1,031 in 688 seconds. The
  rendered book is 79 files / 14,356 KiB and is removed after exact boundary inspection.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.2.0 — freeze Perl transaction RED

- Activated task-tree-first from clean public-sequence closeout `77872bfe` as intended atomic 184/300.
- Added final-path `t/recognition_transaction_perl_contract.t` without ordinary/canonical registration. It derives
  the four authored forms, exact 8 positive / 17 negative token cases, six effect graphs, six mark cases, eight
  progress cases, 9 allowed / 11 rejected effects, and all fifteen diagnostics from the neutral artifact.
- Proved the accepted source reaches descriptor construction. Forty-nine assertions pass; one exact assertion
  fails because all four dedicated transaction nodes are absent, checkpoint/attempt/commit remain three
  unsupported helpers, and rollback remains one raw dependency. The future live/generated-source body skips.
- Froze falsey/miss/commit/rollback, compatibility cursor-stack independence, and emitted/loaded execution behind
  that boundary. Recorded the mechanism in a new Knowledge card and regenerated the map at 803 facts / 6,643 keys.
- Kept the neutral oracle green at 132 ActionIR rows, 246 calls, 40 semantic mutations, and rollout 1/9 plus the
  separate three-page/eight-forbidden/thirteen-mutation public sequence. Current source-location, mark, and
  generated-source consumers pass; production and mdBook source remain unchanged.
- Definitive local CI passes all eight doctrines, repository-contained six-family process proof, moved-root and
  outside-CWD execution, both CLI environments at 66/66, RAM 69%, and Phase 0 1,031/1,031 in 672 seconds.
- Changed no grammar, compiler, runtime, backend, generated carrier, neutral artifact/checker, canonical driver,
  capability/semantic/MCP/CLI/schema, README, storage root, hosted workflow, or current public transaction behavior.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.1.2.0 — govern transaction public sequence

- Activated task-tree-first from clean public-boundary repair `774516fa` as intended atomic 183/300.
- Extended the existing recognition-transaction checker with an exact three-document public marker inventory,
  rollout-derived neutral-complete/every-backend-RED state, tracked-file proof, and eight forbidden stale/current
  claims. Thirteen independent in-memory mutations reject inventory, marker, claim, text, and rollout drift.
- Kept `recognition_transaction_contract.json` and its forty semantic mutations byte-exact; reused the existing
  unconditional canonical/project-data route without adding an entrypoint or changing storage topology.
- Updated ADR `0056`, Knowledge, capability/toolbox guidance, roadmaps, architecture, task/index, continuity, and
  the sole-facing book. The rendered guard paragraph is distinct while every authored/runtime/public leg stays RED.
- Definitive local CI passes all eight doctrines, repository-contained six-family process proof, moved-root and
  outside-CWD execution, both CLI environments at 66/66, RAM 68%, and Phase 0 1,031/1,031 in 672 seconds.
- Changed no grammar, compiler, runtime, backend, generated carrier, fixture, `.spec`/corpus, CLI, schema,
  capability/semantic/MCP surface, README, storage root, hosted workflow, or current authored transaction behavior.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.1.2 — repair neutral transaction status boundary

- Activated task-tree-first from clean neutral-authority commit `e0cc7182` as intended atomic 182/300.
- Re-ran the committed independent contract at 132 ActionIR rows, 246 call rows, token 8/17, six effect graphs,
  six mark cases, eight progress cases, fifteen diagnostics, 40 mutations, and neutral rollout 1/9 unchanged.
- Proved byte identity for the artifact, checker, canonical/storage routes, ADR, Knowledge owners, and three public
  book owners before rendering. Language coverage remains exact at 246 current calls / 105+1 fixtures / 122 public
  Perl contracts; project-local tool storage passes.
- Rendered review caught one contradictory milestone sentence: the page said both that the neutral authority was
  executable and still next. Blame traces the old sentence to `7c2ff407`; `e0cc7182` added the executable paragraph
  without updating it. Corrected only that sentence and preserved the causal fact in Knowledge/task evidence.
- Opened `.14.3.1.2.0` for fail-closed public milestone-sequence governance before Perl RED. No neutral artifact,
  checker, fixture, mutation, runtime, backend, grammar, CLI, schema, capability, README, or public capability changed.
- Definitive signoff passes all eight doctrines, repository-contained process/moved-root proofs, both primary CLI
  matrices at 66/66, RAM 59% below the 88% threshold, and Phase 0 1,031/1,031 in 695 wall-clock seconds.

## 2026-08-10 — FUTURE-PARITY-BACKLOG.14.3.1.1 — add neutral recognition transaction contract

- Activated task-tree-first from clean bounded-document closeout commit `c26a9556` as intended atomic 181/300.
- Added `linkedspec-recognition-transaction-v1` and an independently implemented checker over the exact future
  authored forms, five-state linear token lifecycle, falsey-safe match/payload channels, invocation-mark snapshots,
  cursor-only repetition/recursion progress, fifteen diagnostics, and neutral/backend/public rollout ownership.
- Classified all 128 live ActionIR node kinds plus four dedicated future transaction nodes and all 246 current
  cross-backend call contracts exactly once under a closed nine-allowed/eleven-rejected base-effect vocabulary.
  Six named-rule graphs compute transitive effects to a recursive fixed point and fail closed on unknown effects.
- Added 8 positive / 17 negative token cases, six mark cases, eight progress cases, and 40 exact schema/syntax/
  token/effect/inventory/graph/mark/progress/diagnostic/rollout/registration/freshness mutations. The checker
  re-derives live inventories and locks the full classifications independently.
- Registered the tracked neutral authority unconditionally in canonical CI through repository-local Python project
  data and advanced the exact rollout to neutral 1/9 complete. Perl, Rust, Dart, Julia, PUC Lua, LuaJIT,
  recurring, and public legs remain RED; authored transaction syntax remains unavailable.
- Aligned ADR `0056`, Knowledge, both roadmaps, architecture, capability guide, toolbox, task/index, continuity,
  and the sole-facing book. A real 79-file mdBook build renders the future/current boundary correctly.
- No grammar, compiler, runtime, backend, generated carrier, `.spec`/corpus, CLI, capability ledger, semantic/MCP,
  README, project-data root, hosted workflow, or current public behavior changes.
- Definitive signoff passes all eight doctrines, repository-contained process/moved-root proofs, both primary CLI
  matrices at 66/66, RAM 55% below the 88% threshold, and Phase 0 1,031/1,031 in 675 wall-clock seconds.

## 2026-08-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4 — close bounded document store program

- Activated task-tree-first from clean changes/notes migration commit `921f0507` at cadence 179/300.
- Independently recomposed exact history at 34/34 mutations over three surfaces / 21 segments, task evidence at
  26/26 mutations over seven semantic parts / one immutable history part / 510 stable IDs, and rollover recovery
  at 12/12 without replacing any migration owner.
- Re-ran all nine executable plus two JSON task-consumer projections at their accepted cardinalities. Outside-CWD
  retrieval reproduced exact live/change/note source hashes, resolved all three literal queries plus active leaf
  `.14.3.1.1`, and reported both author roots below rollover pressure.
- Preserved the accepted registry unchanged at 20 surfaces / 62 routes / 32/32 mutations; all four stores are
  current/bounded with empty debt metadata. Aligned ADR, Knowledge, task/frontier, architecture, roadmaps,
  continuity, and sole-facing book status to composition-closed.
- The first canonical pass rejected a compacted task-index row that retained parent `.24` closure but dropped the
  checker-owned `.24.2` public-closeout marker; its focused rerun then rejected synonymous parent status prose.
  Restored both exact governed projections; no checker, expected marker, or mutation boundary was weakened.
- The corrected definitive repository-volume gate exits 0 after all eight doctrines, capability 80/0/0, MCP
  complete/141, Rust semantic 1/1 in 85.71 seconds, Julia semantic 416/416 in 29.9 seconds, cursor 288, containment
  and moved-root proof, CLI 66/66 twice, RAM 49%, and Phase 0 1,031/1,031 in 673 seconds.
- No parser, compiler, runtime, backend, MCP, CLI, fixture, protocol, schema, `.spec` language, README, route
  contract, or project-data root behavior changes.

## 2026-08-10 — LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 — bound changes and engineering notes

- Activated task-tree-first from clean future-task partition commit `61a52dbd` at cadence 178/300.
- Bound the exact clean `CHANGES.md` source (44,270 lines / 3,104,131 bytes, Git blob `2e951cab...b971`, SHA-256
  `c8ba1b7...c14e42`) into eleven immutable reverse-chronological archive segments starting at reserved ID `5000`.
- Bound the exact clean `DEVELOPMENT_NOTES.md` source (21,308 lines / 2,291,424 bytes, Git blob
  `0522cdf5...7508`, SHA-256 `ca9ad5c3...9443c`) into six equivalent archive segments.
- Extended the shared builder/checker protocol for bounded hot roots and added complete-record rollover tooling
  with 80%-warn / 90%-roll / <=50%-retained thresholds. Pre-signoff review repaired a root-before-manifest crash
  window through recoverable segment/manifest/root publication and exact idempotent rerun behavior.
- Focused syntax, rollover 12/12, history mutation 34/34 over three surfaces / 21 segments, exact query hashes,
  staged routing 20 surfaces / 62 routes / 32/32 mutations, Knowledge 800/6,616, and rendered-book proof pass.
- One uninterrupted repository-volume canonical gate exits 0 after all eight doctrines, containment, moved-root
  execution, CLI 66/66 in both option environments, RAM 51%, and Phase 0 1,031/1,031 in 716 seconds; only the
  atomic commit workflow remains.
- No parser, compiler, runtime, backend, MCP, CLI, fixture, protocol, schema, `.spec` language, README, or
  project-data root behavior changes.
