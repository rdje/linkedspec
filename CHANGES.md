# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

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
