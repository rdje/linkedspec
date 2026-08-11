# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.6.2 — integrate shared Lua recognition transactions

- Added four exact non-eager Lua ActionIR nodes for checkpoint, one static child attempt, commit, and rollback.
  `recognize_once(token, call(Rule))` retains the token slot and child label without entering ordinary helper dispatch.
- Extended the private authority with the neutral recursive effect fixed point, cursor-only progress policy, detached
  frame accessors, and missing-token rejection while preserving its opaque weak-store state and falsey-safe payloads.
- Added one private Lua-5.1-compatible runtime adapter shared unchanged by PUC Lua and LuaJIT. Every rule invocation
  synchronizes the real UTF-8-byte cursor, nullable anonymous boundary, and isolated same-label mark bucket through
  the authority; rollback/unwind restore snapshots and commit retains staged state.
- Reused the same interpreter path for native, reconstructed AST, generated-plan, and independently loaded emitted
  execution. The exact dormant integration consumer passes 243/243 on each ABI and retains successful `false`.
- Kept the authority and adapter absent from the public facade and kept the consumer outside ordinary/canonical
  discovery. Neutral 132/246/44, rollout 5/9, and all current public claims remain unchanged until admission `.3`.
- Extended the independent checker with 19 integration mutations, separate from 22 authority, 12 dormancy, and 44
  neutral semantic mutations. The complete Lua gate passes 177/177 per ABI, CLI 66x2, corpus 105, and storage 18/3.
- Signoff passes the 79-file / 14,412-KiB book, Knowledge Map 817/6,781, all eight doctrines, every mandatory
  admission, repository containment/relocation, both CLI matrices at 66/66, RAM 65%, and Phase 0 1,031/1,031 in
  736 seconds before exact `[ci] local CI gate passed`.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.6.1 — add private shared Lua transaction authority

- Added one package-private Lua-5.1-compatible transaction module shared unchanged by PUC Lua and LuaJIT. Its
  weak-key private store owns opaque authorities, invocation frames, detached snapshots, linear tokens, and typed
  diagnostic handles without adding a facade export or ABI-specific implementation.
- Implemented monotonic invocation/mark/transaction generations, checkpoint/attempt/commit/rollback, mark access,
  discard, escape rejection, and terminal-required unwind. Restore happens before token invalidation; successful
  `false`, zero, empty-string, and JSON-null payloads remain distinct from recognition misses.
- Advanced explicit authority mode to 187/187 assertions on each ABI. Explicit integration mode now exits 1 only
  with `Lua recognition transaction integration RED: missing dedicated ActionIR nodes`, the exact `.14.3.6.2` seam.
- Strengthened the dormant final-path consumer to use explicit payload branches and typed empty JSON arrays, closing
  truthiness and empty-table ambiguities exposed by the implemented authority.
- Extended the independent checker with exact private-module markers and 22 authority mutations. The earlier 12
  dormant-RED mutations and neutral 132/246/44 at rollout 5/9 remain unchanged.
- Kept ordinary/canonical discovery and the public facade unchanged. The complete Lua gate remains green at 177/177
  per ABI, primary CLI 66x2, corpus 105/105, and storage 18/3.
- Signoff passes the 79-file / 14,412-KiB book, Knowledge Map 816/6,772, all eight doctrines, every mandatory
  contract/admission, repository containment/relocation, both CLI matrices at 66/66, RAM 82%, and Phase 0
  1,031/1,031 in 753 seconds before exact `[ci] local CI gate passed`.

## 2026-08-11 — FUTURE-PARITY-BACKLOG.14.3.6.0 — freeze shared Lua transaction RED

- Added one shared final-path Lua transaction consumer with explicit `authority` and `integration` modes. The same
  source parses on PUC Lua and LuaJIT and freezes opaque authority/token/mark/lifecycle semantics plus ActionIR,
  recursive effect/progress, native, reconstructed, generated-plan, and in-memory emitted-module expectations.
- Kept the consumer outside `tools/run_lua_local.sh` ordinary discovery and `tools/run_ci_local.sh` canonical CI.
  All four explicit dual-ABI/mode runs exit 1 with the sole stable missing-private-module diagnostic; no production
  module or facade export exists, so no current behavior or support status changes.
- Extended the neutral oracle with twelve separate Lua RED mutations covering selector/private lookup/diagnostic/
  integration/current-status omission, consumer omission, premature ordinary/canonical registration, facade export,
  and ABI command collapse. Neutral truth stays 132/246/44 at rollout 5/9; public 3/17/33 and guide 1/8/12 stay exact.
- Complete ordinary Lua remains green at 177/177 on each ABI, primary CLI 66x2, corpus 105/105, and storage 18/3.
  The sole-facing book and Knowledge Map now distinguish executable dormant RED from current backend support.
- Signoff passes the 79-file / 14,412-KiB book, all eight doctrines, every maintained mandatory contract/admission,
  repository containment/relocation, both CLI environments at 66/66, RAM 60%, and Phase 0 1,031/1,031 in 740
  wall-clock seconds before exact `[ci] local CI gate passed`.

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
