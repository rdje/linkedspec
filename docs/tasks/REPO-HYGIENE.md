# REPO-HYGIENE: Repository hygiene — .gitignore and untrack artifacts

## Metadata

- Tree ID: `REPO-HYGIENE`
- Status: `active` / .24 backlog after signed-selector feature admission17.7
- Roadmap lane: `Overall roadmap — repository maintenance`
- Created: `2026-06-16`
- Last updated: `2026-10-25` (`REPO-HYGIENE.23`: safe cleanup verified; .24 prevents recurring growth)
- Owner: repo-local workflow

## Goal

Keep tool/local artifacts out of version control, safely reclaim generated build/cache space when needed, and keep
the durable handoff state current.

## Non-Goals

- Does not change product code, tests, or documented language behavior; maintenance docs may record the cleanup
  boundary and evidence.
- Does not delete source, fixtures, checked-in docs, or any user-authored working-tree content.
- Does not remove the `rgx/` submodule.

## Acceptance Criteria

- `.gitignore` has entries for `*.swp`, `.DS_Store`, `git_message_brief.txt`, and `.claude/projects/`.
- `perl/.PPlugin.pm.swp` and `git_message_brief.txt` are removed from the index (`--cached`).
- `rgx` remains tracked as a submodule/gitlink, and `.gitmodules` carries the intended local-dirt ignore policy so
  nested submodule worktree dirt does not dirty the parent status.
- Historical `.1` acceptance: `MEMORY.md latest_commit` was updated under the then-current convention. ADR `0065`
  / `MEMORY-COMMIT-POINTER-ENFORCEMENT.0-.1` supersede that self-referential name/comparison with
  `activation_commit == HEAD` before commit and `HEAD^1` afterward; Git owns current identity.
- Focused validation passes (memory-arch self-check, perl -c).
- Live docs updated.
- Generated build/book artifacts are deleted only when they are rebuildable and safe to remove.
- Committed per `COMMIT.md`.

## Task Tree

- ID: `REPO-HYGIENE`
  Status: `in_progress`
  Goal: `Repository hygiene — ignore local artifacts and safely reclaim generated caches`
  Children: `REPO-HYGIENE.1`, `REPO-HYGIENE.2`, `REPO-HYGIENE.3`, `REPO-HYGIENE.4`, `REPO-HYGIENE.5`, `REPO-HYGIENE.6`, `REPO-HYGIENE.7`, `REPO-HYGIENE.8`, `REPO-HYGIENE.9`, `REPO-HYGIENE.10`, `REPO-HYGIENE.11`, `REPO-HYGIENE.12`, `REPO-HYGIENE.13`, `REPO-HYGIENE.14`, `REPO-HYGIENE.15`, `REPO-HYGIENE.16`, `REPO-HYGIENE.17`, `REPO-HYGIENE.18`, `REPO-HYGIENE.19`, `REPO-HYGIENE.20`, `REPO-HYGIENE.21`, `REPO-HYGIENE.22`, `REPO-HYGIENE.23`, `REPO-HYGIENE.24`

- ID: `REPO-HYGIENE.23`
  Status: `done` (2026-10-25)
  Goal: Re-measure the director-supplied disk notes and reclaim only proven disposable LinkedSpec artifacts.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Priority / scheduling: Director-requested maintenance immediately after clean Dart17.4 and before Julia17.5. Planning and read-only source intake do not pivot the active dirty leaf. Activate only from clean Git with all prior jobs joined.
  Owned paths: Parent-owned cleanup producers/evidence under docs/checkpoints/REPO-HYGIENE.23/, exact individually approved generated outputs, docs/ARTIFACT_CLEANUP.md, relevant existing Knowledge/book maintenance guidance, and normal task/live continuity. Other repositories, submodules, source, sealed checkpoints and unresolved run evidence remain excluded.
  Activation: Clean c2c4ab05de1e08de56bee77fd6671724720728c8 after Dart17.4 canonical PASS (Phase0 1035; both CLI66), all10 normal hooks, post-memory PASS, brief0 and exact committed receipt check. All previous jobs are joined. The post-commit hook already promoted the receipt; a redundant manual promotion correctly refused and the exact-HEAD check then passed. No receipt or runtime defect is inferred. User reiterates priority for unused .linkedspec-data artifacts and rust/target before further feature work; supplied size estimates remain unverified until this leaf's census.
  Verification tier: `focused`
  Focused checks: Retain the complete supplied index/LinkedSpec note before use; re-measure allocated sizes and free space; inspect exact tracked/ignored ownership, published retention obligations and permitted process/run liveness before any removal; retain actual commands/exits/channels and before/after per-item and parent/volume measurements. Inspect scratch per concluded experiment with recoverable inputs/results, never infer disposal permission from ignore status. Prefer native Cargo/Git tools; do not expire reflogs or unreachable objects merely because the old note suggests immediate pruning. Verify no current writer and any Git maintenance lease before compaction; preserve all active and retained proof consumers. Completed focused cleanup/reader/Rust/book checks, history pressure, Knowledge, memory/task-pointer and diff checks govern landing. The director explicitly defers broad suites and global registry scans until after feature coverage is complete.
  Canonical trigger: None for this commit after the director explicitly defers broader verification to feature implementation. Changed tracked paths are maintenance evidence/docs only; no shared storage policy, runtime, wrapper, hook, gate or dependency changes. Completed focused safety proof and fast manual continuity checks govern landing. The broad pre-commit registry scan is deferred explicitly under the director’s latest policy; post-commit pointer verification remains enabled. Full validation follows feature completion.
  Claim verification: `docs/claims/REPO-HYGIENE.23.json`
  Intake: Read the user-authorized external Desktop disk-notes index and LinkedSpec note in full on 2026-10-25, read-only. Exact source packets are retained in docs/checkpoints/REPO-HYGIENE.23/input-notes.json.gz; intake.py verifies the copy before removing only duplicate untracked project copies. External originals are unchanged. Those 2026-10-21 estimates are historical inputs, not current measurements. The latest cleanup record .22 retains artifacts, with no disposal authorization. Known process-inspection restrictions require permitted evidence, not guessed quiescence.
  Acceptance: Report actual bytes reclaimed per item, current parent total/free space and exact retained items/reasons. No blanket deletion, no dependency implementation inspection, no sibling-repository writes and no concurrent cleanup/build. If a candidate cannot be proved safe, retain it and finish the safe subset with its specific blocked disposition recorded.
  Safety boundary: Read current cleanup and descendant/permission-denied Knowledge authorities before census. Do not invoke managed --recover/--purge-failed: startup7 still owns denied/unknown liveness and group-establishment repair. Independent permitted process/cwd/open-file checks must establish candidate quiescence. Skip nested repositories/submodules before metadata traversal and never follow symlinks or cross filesystem boundaries. Retain every candidate whose provenance, liveness or evidence obligations are unresolved; complete proved-safe removals within this leaf.
  Verified progress: Original target114886914048 allocated bytes was quarantined reversibly, then locked/offline primary rebuild and all four typed public examples passed. Whole actual executable/source inputs survive. Native Cargo clean removes only the old quarantine after permitted empty lsof rechecks; fresh target1917575168 bytes remains, yielding112969338880 allocated bytes reduction. The history source1702740 entries/1533599 files/163401 directories/5740 symlinks occupies119213043712 allocated bytes; its whole deduplicated archive55259061 bytes passes full payload/metadata verification and both actual restored public readers preserve original stdout. Complete source metadata/population and permitted open files are rechecked before descriptor-based removal; both leases are closed, source/quarantine absent. Redundant ignored archive staging copies are also removed after hash/use proof. Independent decoding and six reason-sensitive actual reviewer denials reject corrupt/missing/mode/totals/value/denied-liveness variants; healthy/restored pass. The initial reviewer nested-field error is retained as an instrument correction, not product RED. Complete supplied book rendering passes. After-census passes: parent scoped482253152256 ->250070880256 allocated bytes (remaining data236752314368), retaining archive55263232 allocated bytes. After-volume available2639087056 KiB is observed separately. Knowledge/diff/history and complete book checks pass; the first pressure check rejects50003/50000 book lines, then wrapping-only correction preserves all words and restores49999. Both renders and the original refusal survive. The completed focused proof and fast manual checks govern landing; broad CI/global registry verification are deferred under the latest director instruction.
  Retained disposition: LS004 scratch contains a protected nested repository; do not delete its ancestor or inspect its implementation. Remaining unique/unassessed experiment evidence, project package stores, dependency outputs, Git objects/reflogs and sealed checkpoints stay retained. No managed recovery/purge, Git pruning, dependency bootstrap or other-repository write. Scope qualification: global scans exclude Git/protected repositories and fixed proof/verification prefixes but include observer wrapper metadata. They are non-atomic aggregates without independent global per-file custody; volume delta includes other projects and is not causal reclaim.
  Owned growth finding: tools/test_document_history_rollover.py creates original-/repaired- views with tempfile.mkdtemp beneath the fixed history-rollover-eof scratch root and has no successful-run removal before returning. These views use this project's read-only Git metadata through GIT_DIR/GIT_WORK_TREE; the source explicitly says they are ordinary files, not new repositories. The successful ordinary regression prints its report but retains each generated view. Historical book capture writers similarly leave book- render trees after archiving source/selected outputs. Inventory and per-experiment custody/liveness proof must determine safe current disposal; recurring producer repair remains owned under P2 hygiene24 after signed feature admission17.7, per the director’s latest feature-first instruction. Do not replay or edit retired capture writers.

  Director steering / gate lifecycle: The director requests feature implementation directly after cleanup and explicitly permits broader verification afterward. Candidate1/session35723 is deliberately stopped143 to correct its handoff; candidate2/session56587 is stopped143 to defer broader CI as instructed. Neither has an accepted receipt or product/test failure. All measured proof bytes remain fixed. This evidence/docs-only leaf is focused-eligible under the registry. Normal commit attempt/session3033 is deliberately stopped1 during the broad registry scan, under the director’s subsequent explicit lightweight policy. Completed full claim-check PASS187/246 and targeted cleanup proof remain valid; the retry uses --no-verify after fast manual pointer/memory/cadence/diff checks. Post-commit pointer verification remains enabled; hook code is unchanged. Julia17.5 resumes after clean23;24 remains scheduled after17.7.
  Commit: `REPO-HYGIENE.23 - reclaim verified Rust and history fixture artifacts`.

- ID: `REPO-HYGIENE.24`
  Status: `pending`
  Goal: Prevent the recurring document-history regression from accumulating completed disposable fixture views.
  Dependencies: `REPO-HYGIENE.23`, `TYPE-REFERENCE-BOOK.1.2.17.7`
  Priority / scheduling: P2 after signed-selector feature admission17.7, before complete operation inventory1.2.1. Director explicitly requests focus on feature implementation; the verified cleanup leaves ample capacity. Keep this repair owned, with no maintenance detour before Julia/Lua/admission17.5–7.
  Reproduce / root cause: The current tools/test_document_history_rollover.py source creates run_tree using tempfile.mkdtemp at the fixed history-rollover-eof root, then reaches report/return with no cleanup. Run the public successful regression under its existing managed wrapper and compare named fixture directories before/after; retain actual proof before changing it. No claim that every historical tree is disposable follows from source alone.
  Impact: Routine canonical/doctrine invocations accumulate completed fixture copies outside the normal per-run automatic cleanup. Confirm the exact created byte population with actual commands; do not infer sizes from old notes.
  Owned paths: tools/test_document_history_rollover.py and its direct lifecycle/retention consumers, required exact historical source-evolution admission if affected, new bounded proof under docs/checkpoints/REPO-HYGIENE.24/, and normal Knowledge/book/live/task continuity. Preserve all original immutable evidence and retired capture producers.
  Planned tier: `canonical`
  Planned checks: Actual public before/after creation/removal and explicit report preservation; distinguishing cleanup inverse and exact restoration; normal/injected-failure behavior and source/destination/symlink/other-repository guards; document-history/doctrine/direct dependent proof and exact staged canonical acceptance. Keep necessary failure diagnosis under an explicit bounded retention policy rather than deleting unknown data.
  Planned canonical trigger: Recurring proof producer and runtime-created fixture storage lifecycle change.
  Claim verification: none: Source-established growth intake and scheduled ownership only; declare actual measurements before activation.
  Acceptance: A normal successful invocation preserves required durable reports and leaves no disposable fixture root, historical results remain unchanged, failure/retention semantics are explicit and verified, and the independent current cleanup23 disposition stays immutable.

- ID: `REPO-HYGIENE.1`
  Status: `done`
  Goal: `Add .gitignore entries, untrack tool artifacts, update MEMORY.md, commit`
  Acceptance: `.gitignore` updated; `git_message_brief.txt` and `.swp` untracked; MEMORY.md current; committed`
  Verification: `memory-arch self-check exit 0; perl -c perl/LinkedSpec.pm OK; git status clean`
  Commit: `REPO-HYGIENE.1 — .gitignore: untrack tool artifacts + MEMORY.md update`

- ID: `REPO-HYGIENE.2`
  Status: `done` (2026-07-06)
  Goal: `Make local .claude/projects/ and rgx submodule dirt disappear from parent git status`
  Acceptance: `.claude/projects/` is ignored; `rgx` remains a tracked submodule/gitlink; `.gitmodules` keeps the
    `rgx` submodule and records `ignore = dirty`; local `rgx/` content is not deleted; parent `git status` no
    longer reports either local agent state or dirty submodule worktree state.
  Surfaced finding: `2026-07-06`: `rgx` is tracked as a `160000` gitlink/submodule, so `.gitignore` alone cannot
    suppress dirty status for it. The correct cleanup is to keep `rgx` in `.gitmodules` and set the submodule
    ignore policy for local dirt, while ignoring only `.claude/projects/`.
  Verification: `git status --ignored` shows `.claude/projects/` ignored; `git ls-files --stage rgx` shows
    `160000 8763a0e... rgx`; `git submodule status -- rgx` reports the pinned submodule; parent `git status`
    does not report dirty `rgx`; memory/doctrine/Knowledge Map/diff checks pass.
  Commit: `cf0df422097d55aaf2379cac8907319107406e6b` — `REPO-HYGIENE.2 - ignore Claude project state and rgx local dirt`

- ID: `REPO-HYGIENE.3`
  Status: `done` (2026-07-07)
  Goal: `Remove safe generated artifacts to reclaim disk space`
  Acceptance: Scan for generated logs, macBinary `.bin` archives, common temp artifacts, mdBook output, and Rust
    target directories; delete only rebuildable generated artifacts that are safe to remove; record reclaimed-size
    evidence; keep source, fixtures, checked-in docs, and user-authored content intact; repo returns to a clean
    handoff state after commit.
  Verification: `done` — read-only scans found no `.log`, `.bin`, `.tmp`, `.bak`, `.DS_Store`, or `.swp` artifacts
    in the main checkout outside `.git`, ignored `rust/target`, and the `rgx` submodule. The only main-checkout
    rebuildable artifacts were ignored/untracked `rust/target` (5.2G) and `docs/linkedspec-book/book` (7.0M);
    both were removed. `.log`/`.bin` hits under `rgx/` were left intact because they live in submodule fixture,
    stimulus, or issue-artifact trees and are not 100% safe parent-repo cleanup targets.
  Commit: `REPO-HYGIENE.3 - remove generated artifacts`

- ID: `REPO-HYGIENE.4`
  Status: `done` (2026-07-10)
  Goal: `Repeat safe artifact cleanup with Julia-specific cache coverage`
  Acceptance: Measure current disk pressure and generated-output sizes; delete only ignored/untracked Rust build
    output, mdBook output, Julia compiled/precompile caches, and stale temp logs proven to be regenerable; do not
    delete Julia packages, registries, environments, unrelated temp trees, source, fixtures, or user-authored data;
    record before/after evidence and return the repo to a clean committed handoff state.
  Surfaced finding: `/private/tmp` held 46G after the first cache pass. Twelve closed LinkedSpec/RGX parser-
    generation logs dated July 6–9 accounted for about 18G, including three 5.1G SystemVerilog logs. Their headers
    identify repo generation commands and `lsof`/process checks found no writers. The unrelated 29G `claude-501`
    directory and two unrelated `cargo-mutants-nexsim` trees were deliberately preserved.
  Verification: `PASS` — the filesystem started at 50G available / 90% used. `git check-ignore` and
    `git ls-files` confirmed `rust/target` (1.7G) and `docs/linkedspec-book/book` (7.8M) were ignored, untracked,
    and rebuildable. Julia depot measurement isolated compiled/precompile caches at 148M in the dedicated
    `/private/tmp/linkedspec-julia-depot/compiled` and 261M in `~/.julia/compiled`; packages, registries,
    environments, logs, and scratchspaces were measured separately and preserved. Removing only those four
    generated targets reclaimed about 2.1G. Root-cause follow-up then removed only twelve proven stale
    LinkedSpec/RGX generation logs (about 18G) from `/private/tmp`. The complete leaf reclaimed about 20G and
    raised availability from 50G / 90% used to 68G / 86% used. All targets are absent, both Julia depots retain
    their noncompiled content, unrelated temp trees remain, and the tracked tree contains only this leaf's docs.
  Commit: `REPO-HYGIENE.4 - clean Rust and Julia generated caches`

- ID: `REPO-HYGIENE.5`
  Status: `done` (2026-07-17)
  Goal: `Repeat urgent safe artifact cleanup under measured low-disk pressure`
  Acceptance: Retrieve the established cleanup boundary before scanning; measure filesystem pressure and exact
    candidate sizes; prove repo outputs ignored/untracked and temp logs both provenance-identified and unwritten;
    delete only rebuildable Rust, mdBook, Dart, and Julia compiled output plus exact stale generation logs; preserve
    Julia depot data, `rgx` fixtures, unrelated temp trees, and all user-authored content; measure reclaimed space,
    synchronize durable evidence, and return the repo to a clean committed handoff state.
  Checklist:
  - [x] **RETRIEVE / MEASURE** — Read the existing generated-artifact Knowledge Map card; measure the filesystem,
    repo build outputs, Julia depot components, `/private/tmp`, and the largest exact candidate files.
  - [x] **PROVE OWNERSHIP / SAFETY** — Confirm repo targets are ignored and untracked; inspect exact log headers;
    verify no open handles or matching active generation process; exclude the unrelated `claude-501` tree, whole
    Julia depots, `rgx` log/bin fixtures, and every unknown temp target.
  - [x] **DELETE EXACT TARGETS** — Remove only `rust/target`, mdBook `book`, Dart `.dart_tool`, the two dedicated
    Julia `compiled/` directories, and the exact fifteen closed generation logs recorded in verification evidence.
  - [x] **POST-MEASURE / PRESERVATION** — Prove targets absent, measure available space gained, and confirm depot
    noncompiled content, unrelated temp trees, tracked source, and worktree ownership remain intact.
  - [x] **LOCKSTEP / COMMIT** — Refresh the existing Knowledge Map fact and live continuity docs with exact evidence;
    run memory/KM/task/doctrine/whitespace checks and commit this leaf before resuming the roadmap frontier.
  Verification: **PASS.** The session first observed 29G available / 94% used; unrelated external cleanup raised
    the immediate deletion baseline to 55G / 89%. `git check-ignore` and `git ls-files` prove `rust/target` (2.6G),
    Dart `.dart_tool` (30M), and mdBook `book` are ignored/untracked; the mdBook output was already absent after
    the preceding closeout gate cleanup. Exact depot measurement isolates 142M and 125M `compiled/` directories.
    Fifteen July 15-16 pgen/RGX generation logs total about 13.6GB decimal (about 12.7GiB); headers identify the
    completed commands, `lsof` finds no writer, and process inspection finds no active matching generation job.
    Removing only those exact targets raises availability from the immediate 55G / 89% baseline to 71G / 85%, a
    measured 16G gain. Every target is absent; dedicated depots retain registries/logs; the unrelated 18G
    `claude-501` tree, unknown temp trees, `rgx` corpus artifacts, source, and tracked fixtures remain untouched.
    Memory, Knowledge Map, task metadata, doctrines, and whitespace pass; build/test/mdBook commands are not rerun
    because they would recreate the artifacts and no product behavior changed.
  Commit: `REPO-HYGIENE.5 - clean recurring generated artifacts`

- ID: `REPO-HYGIENE.6`
  Status: `done`
  Goal: Record the due artifact review and a clean exit handoff after the lossless milestone.
  Activation: Clean 2aeed31ff571025cff1040593015683400caa7c0; milestone hooks and promoted canonical receipt pass, brief0 and clean status confirmed before this maintenance leaf.
  Acceptance: Census repository-owned stray artifacts and Rust target log/bin locations; delete only exact provably disposable files, preserve reusable caches and proof evidence, overwrite the cleanup date, and commit a bounded resume pointer with no required job outstanding.
  Verification tier: `focused`
  Focused checks: Read-only repository artifact census with nested repositories excluded; permitted process/run liveness inspection; memory/history/Knowledge/doctrine and diff checks; mdBook render for the clarified retention boundary.
  Canonical trigger: none; maintenance record and public clarification only, with no storage mechanism, runtime, contract or gate change.
  Verification: PASS; read-only census retains4092 artifact candidates/8548757149 bytes, including3040 logs/1049 bins/three Finder metadata files. Explicit Rust release is absent, incremental retains483 bins/2386016452 bytes, and debug/deps has zero log/bin hits. Nine nested Git repositories, RGX, managed runs and canonical caches are excluded. No exact deletion target was proved disposable; zero removed. Permitted process inspection shows no earlier LinkedSpec CI/test job; managed list found0/removed0/skipped0 before this leaf's book build. mdBook render succeeds; memory/history/Knowledge/diff checks and mandatory commit doctrines verify the final docs.
  Evidence: docs/checkpoints/REPO-HYGIENE.6-artifact-review.json; .linkedspec-data/scratch/handoff-mdbook-20261001.log. Existing startup .7 still prohibits recovery/purge; no liveness-derived deletion was attempted.
  Commit: `REPO-HYGIENE.6 - record artifact review and exit handoff`.

### `REPO-HYGIENE.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The latest cleanup record is September27 and is over24 hours old at October1 resume. The director requests a handoff for /exit after the staged milestone.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: the session date advanced during interruption; WHERE: docs/ARTIFACT_CLEANUP.md. The existing retention boundary and startup .7 liveness defect require conservative exact-target handling, not an age-based purge.
- [x] **FIX** — Complete the receipt-bound milestone first, then own this read-only census, overwrite the latest cleanup record and preserve the single unstarted feature frontier in MEMORY.md.
- [x] **ADDRESSED (verified)** — Census checkpoint records4092 parent artifacts and explicit Rust locations with zero deletions. Permitted managed-run census reports found0; mdbook build completes and the final memory/history/Knowledge/diff checks pass.
- [x] **NO REGRESSION** — No runtime, fixture, dependency, storage mechanism or gate changes. Retained logs, compiled outputs and caches remain; scripts/check_memory_architecture.sh and mandatory doctrine hooks verify the documentation-only slice.
- [x] **LOCKSTEP** — Cleanup record, checkpoint, task/index, book retention guidance and bounded live/change/note/resume docs agree; SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4 remains unstarted for the next session.

- ID: `REPO-HYGIENE.7`
  Status: `done`
  Goal: Complete the due daily artifact review while retaining proof inputs and correcting the current submodule cleanup boundary.
  Activation: Clean e3ed7cc824c9e55416bea9c74dd39e9f5b83fb68; recovery hooks/post-pointer pass, brief0 and clean Git confirmed.
  Owned paths: docs/ARTIFACT_CLEANUP.md; new docs/checkpoints/REPO-HYGIENE.7-artifact-review.json; current cleanup Knowledge card and development/documentation-workflow.md; this tree/index, bounded change/notes/live/resume and derived Knowledge. Census/review instruments and scratch use .linkedspec-data/scratch/hygiene7; archive instrument bodies in the checkpoint.
  Verification tier: `focused`
  Focused checks: Non-following parent-checkout artifact census and explicit Rust release/incremental/deps log/bin locations; exclude nested repositories, all submodules, retained caches and managed runs; record every retained candidate and derive aggregate counts from those rows; fresh census plus direct per-file OS metadata oracle, corrupt-count and balanced-size controls; no deletion; book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none; recurring maintenance snapshot and existing read-only policy clarification only, with no storage, gate, runtime or dependency change.
  Reproduce: Latest review October1 15:01:05 UTC is over24 hours old. Current cleanup card still suggests a submodule-owned task can authorize pruning; September27 director authority makes all other repositories read-only to this agent.
  Acceptance: Advance the latest review only after a scoped census, preserve all proof/cache artifacts, archive the actual census instrument, correct the maintained permission statement, and commit a clean resume to SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1. No liveness/recovery/purge inference or other-repository write.

  Verification: PASS; 4341 parent candidates/8985768888 bytes retained, 9 nested repositories excluded, explicit Rust rows/counts preserved in the checkpoint. Fresh scope census and direct per-file OS metadata match; corrupt aggregate count and balanced size redistribution reject, and fixed inclusion/exclusion fixtures pass. Census/review source bodies and hashes are archived. Zero removals; no liveness/recovery/purge operation. Book/Knowledge/history/memory/doctrine/diff govern focused landing.
  Commit: `REPO-HYGIENE.7 - review artifacts and correct read-only boundary`.

- ID: `REPO-HYGIENE.8`
  Status: `done`
  Goal: Complete the due daily artifact review before the selected compiler repair while preserving all proof/cache data and repository boundaries.
  Activation: Cleanbf1e4edd04371eeddf33f8445239348e12f887f2; diagnosis all ten doctrines/post-pointer PASS, brief0 and Git clean confirmed before pivot.
  Reproduce: Latest cleanup October2 15:55:46 UTC is over24 hours old during the October3 post-diagnosis review. No cleanup/purge ran during the dirty diagnosis.
  Owned paths: docs/ARTIFACT_CLEANUP.md; new docs/checkpoints/REPO-HYGIENE.8-census.py, review.py, artifact-review.json and verification.json; new docs/claims/REPO-HYGIENE.8.json; .8-book-check.py/json for rendered retention teaching; cleanup Knowledge card and development/documentation-workflow.md; this tree/index, current ROADMAP.md/ROADMAP_V2.md cleanup-to-feature routing, bounded history/live/resume and derived map. Scratch .linkedspec-data/scratch/hygiene8. Read archived .7 instruments, preserve their exact historical bytes.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent artifact census plus explicit Rust release/incremental/deps log/bin locations; exclude all submodules/nested repositories, managed runs, caches and generated book/Dart outputs. Retain each candidate; derive totals from per-file rows; fresh census and independent lstat validate; reject corrupt totals/balanced sizes, prove included/excluded fixture scope. No age-based deletion, process recovery/purge or cross-repository write. Update latest-only cleanup record, book/Knowledge/history/memory/diff and all mandatory doctrines.
  Canonical trigger: none; dated maintenance snapshot under unchanged storage/CI/runtime/dependency mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.8.json`
  Capture sequencing correction: The first review was launched while census output was still in flight and rejected its empty JSON. No result was published; wait for successful census completion before running the dependent reviewer.
  Acceptance: Exact retained census and producer/result/controls are recoverable; remove only provably safe exact targets if any, overwrite latest cleanup timestamp/disposition after verification, and commit a clean handoff to SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1. No runtime/performance/liveness or fullCI claim.

  Verification: PASS;5661 parent candidates/10108187384 bytes retained, nine nested repositories excluded, explicit Rust release absent/deps0/incremental483 rows/2390805202 bytes. Fresh census/lstat agree; inflated count/balanced wrong-size controls reject and inclusion/exclusion fixture passes. Full producers/snapshot/results are tracked; zero removals and no liveness/purge operation. Rendered retention teaching PASS; focused doctrine/history/memory/diff landing governs completion.
  Commit: `REPO-HYGIENE.8 - retain daily artifact census` (Git owns identity).
  Handoff: Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1 from clean HEAD; no required background job remains.

- ID: `REPO-HYGIENE.9`
  Status: `done`
  Goal: Complete the due daily artifact census after committed private splitter frames, preserving evidence, caches and repository boundaries.
  Activation: Clean abe6756ae638ce68d6219c4794142b02c5450f3e; all ten doctrines/post-pointer passed, brief0, no jobs and clean Git confirmed before pivot.
  Reproduce: Latest cleanup October3 16:37:49 UTC is over24 hours old on October4. No cleanup or dirty-tree pivot occurred during the frame slice.
  Owned paths: docs/ARTIFACT_CLEANUP.md; new docs/checkpoints/REPO-HYGIENE.9-* census/reviewer/actual capture/book/claim producers and results; docs/claims/REPO-HYGIENE.9.json; cleanup Knowledge and public documentation-workflow.md; this tree/index, ROADMAP.md/ROADMAP_V2.md, bounded history/live/resume and derived map. Scratch .linkedspec-data/scratch/hygiene9. Prior frame claim historical freeze at exact abe6756ae before complete-publication inputs change; retain its original 37 input identities. All previous proof inputs remain immutable.
  Verification tier: `focused`
  Focused checks: Same-volume non-following parent metadata census and three explicit Rust log/bin locations; all submodules/nested repositories, symlinks, other volumes, managed runs, caches and generated book/Dart outputs excluded. Fresh census and independent per-file lstat; aggregate/balanced-size corruptions and inclusion/exclusion fixture. Retain all candidates unless exact disposability is proved. Capture actual producer/status/full channels, render public retention teaching, and run memory/history/Knowledge/claims/diff/all doctrines.
  Canonical trigger: none; recurring metadata record under unchanged storage/CI/runtime/dependency mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.9.json`
  Acceptance: Verify dated exact candidate rows and exclusions before overwriting latest cleanup record. No age/size-based deletion, process recovery/purge or other-repository write. Resume self-containment .1.1.1.2 from a clean committed handoff.
  Owned documentation drift: ROADMAP_V2 still names statement framing as next after .1 completed private frames. Correct that stale route with this handoff to eleven producer hooks; do not close their task or alter measured prior proof.

  Verification: PASS; Dated 2026-10-04T20:15:09.584501+00:00 census retains 7741 parent candidates/11634211060 bytes and excludes nine nested repositories. Rust release is absent, deps has zero log/bin files, and incremental retains483 rows/2390943383 bytes. Fresh scoped census and independent per-file lstat agree; aggregate inflation and balanced wrong sizes reject, inclusion/exclusion fixture passes, and actual exit0/full channels/input guards pass four controls. Zero files removed; all proof/cache data retained. Complete58-input book renders one retained-review example with five controls. Prior frame claim freezes at exact abe6756ae after all37 input hashes verify; eleven producer hooks .1.1.1.2 are next.
  Commit: `REPO-HYGIENE.9 - retain daily artifact census` (Git owns identity).
  Handoff: Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2 from clean HEAD; no required job remains.

- ID: `REPO-HYGIENE.10`
  Status: `done`
  Goal: Complete the due daily metadata census after clean Legacy diagnosis; retain evidence, caches and every repository boundary.
  Activation: Clean f3a49dd82794c494625e33fe83ccf6cf01b4df8e; empty brief, clean Git and no required background jobs confirmed before pivot.
  Reproduce: Latest cleanup October4 20:15 UTC is over24 hours old on October6 local time.
  Owned paths: docs/ARTIFACT_CLEANUP.md; new docs/checkpoints/REPO-HYGIENE.10-* census/review/capture/freeze/book/claim instruments and results; docs/claims/REPO-HYGIENE.10.json; historical durability boundary of the two Legacy .1.4.0 claims; cleanup Knowledge and public documentation-workflow.md; this tree/index, ROADMAP.md, bounded history/live/resume and derived map. Scratch .linkedspec-data/scratch/hygiene10. Previous proof artifacts remain immutable.
  Verification tier: `focused`
  Focused checks: Non-following parent metadata census and explicit Rust release/deps/incremental log-bin locations; fresh scoped census and independent per-file lstat, aggregate inflation/balanced wrong-size rejection and inclusion/exclusion fixture. Retain actual commands/exits/full channels/input guards; verify all original Legacy claim hashes before freezing; render complete book inputs and verify retention teaching. Run memory/history/Knowledge/claims/diff/all doctrines.
  Canonical trigger: none; recurring metadata record under unchanged storage/runtime/dependency/verification mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.10.json`
  Acceptance: Retain all artifacts unless exact disposal is proved. Exclude submodules/nested repositories, symlinks, other volumes, managed runs and retained caches/generated outputs; inspect three Rust metadata locations separately. No deletion based on age/size, no process recovery/purge or other-repository writes. Commit before returning to Legacy .1.4.1.

  Verification: PASS; Dated 2026-10-05T23:43:45.934735+00:00 census retains 8931 parent candidates/12619808609 bytes and excludes nine nested repositories. Rust release is absent, deps has zero log/bin files, incremental retains 483 rows/2390808555 bytes. Fresh scoped census and independent lstat agree; two metadata/four actual-channel/five render controls reject. Zero removals; complete58-input book renders one example. Two Legacy claims freeze at clean f3a49dd with224 original bindings/112 unique hashes. Initial uncommitted change-note insertion matched inline Markdown rather than a heading; bounded-history check rejected it. Anchored insertion restores the exact preamble and both chronology checks pass. An early isolated claim check overlapped staging and exited1 with the documented mixed-index missing-declaration diagnostic (Knowledge card claim-verification-index-snapshot); its original cached blob table was not retained. Staging now precedes verification; the subsequent doctrine driver reports all10 PASS, including the claim check. No checker or policy was changed. All doctrines/memory/Knowledge/claims/diff pass before landing.
  Commit: `REPO-HYGIENE.10 - retain daily artifact census`

- ID: `REPO-HYGIENE.11`
  Status: `done`
  Goal: Complete the due daily artifact review after clean compiler membership, preserving all proof inputs/caches and correcting stale maintenance pointers.
  Activation: Clean af5d19971a1682f6895901fb769ff41b69842672; all ten normal doctrines/post-commit pointer PASS, brief0, clean Git and no required jobs confirmed before pivot.
  Reproduce: Latest review 2026-10-05T23:43:45.934735+00:00 is over24h old. docs/TASK_TREE.md's Latest maintenance still names .8 and its .10 completed row still routes to Legacy .1.4.1; actual feature frontier is immutable membership .0.2.2.
  Owned paths: docs/ARTIFACT_CLEANUP.md; new docs/checkpoints/REPO-HYGIENE.11-* census/review/capture/freeze/book/claim producers and retained results; docs/claims/REPO-HYGIENE.11.json; mode/revision-only preservation of the committed .0.2.1 compiler claim at activation; cleanup Knowledge card and public documentation-workflow.md; this tree/index/roadmaps/live/resume/change/notes and derived Knowledge. Scratch .linkedspec-data/scratch/hygiene11. Previous proof/input/result bytes stay immutable.
  Verification tier: `focused`
  Focused checks: Same-volume non-following parent metadata census and explicit Rust release/incremental/deps log-bin locations. Exclude submodules/other repositories, symlinks, other volumes, managed runs, caches and generated Dart/book/Rust outputs before traversal; retain all candidates unless exact disposal is proved. Fresh scoped census and independent per-path lstat, aggregate inflation/balanced wrong-size controls and inclusion/exclusion fixture. Retain actual producer commands/exits/full channels/byte guards and four effective evidence controls. Verify every original compiler claim input at exact Git activation before historical freeze; render all final book inputs and verify review example/five controls. Run memory/Knowledge/history/claims/diff/all doctrines.
  Canonical trigger: None; dated metadata review and documentation pointers under unchanged storage/runtime/dependency/gate mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.11.json`
  Acceptance: Advance the latest-only cleanup date only after the exact dated rows and source/metadata/channel/publication controls pass. No age/size-based deletion, recovery/purge or other-repository write. Own and resolve both stale index pointers, commit this bounded maintenance unit, then resume canonical membership .0.2.2 from clean HEAD.

  Verification: PASS; Dated 2026-10-07T13:28:24.094691+00:00 census retains10838 parent candidates/13805895079 bytes and excludes9 nested repositories. Rust release is absent, deps has0 log/bin rows, incremental retains483 rows/2390808595 bytes. Fresh scoped metadata and independent lstat agree; two metadata/four actual-channel/five render controls reject. Zero removals; evidence/caches retained. Book58 inputs/one review example passes; original133 compiler claim hashes freeze mode/revision only at clean af5d19971. Both stale maintenance pointers are corrected; canonical membership .0.2.2 follows.
  Commit: `REPO-HYGIENE.11 - retain daily artifact census` (Git owns identity).
  Handoff: Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2 from clean committed HEAD. Recur original membership/value/source oracles and direct consumers without overlays; exact staged canonical proof precedes membership parent closeout.

- ID: `REPO-HYGIENE.12`
  Status: `done`
  Priority: P2 — qualify a dated testing fact that still claims current counts and runtime.
  Goal: Preserve the June12 Phase0 observations as dated history and route current reach/runtime to current proof.
  Reproduce: Read docs/knowledge/phase0-regression-structure.md: status current,1004 subtests and approximately3 minutes. The completed .0.2.2.2.2 canonical receipt retains1035 tests/1185 wallclock seconds for its exact run; that single run is not a universal performance estimate.
  Impact: Startup retrieval can mistake historical measurements for current suite size and execution expectations.
  Schedule: After the clean selected-replacement diagnosis .0.3.0 and before its production repair .0.3.1; no dirty pivot.
  Acceptance: Qualify the original dated observations without refreshing them or inferring a new universal duration. Preserve source/test/CI bytes and actual prior evidence; update Knowledge, task/live/resume/history and run focused documentation checks/normal hooks. Resume replacement repair from a clean commit.
  Activation: Clean 11f6a87d136ce213899ca6a0cd98cf3f0833f720; diagnosis normal hooks/post-commit pointer pass, brief empty and no required background job. Original card, current book regression description, COMMIT/history controls and retained canonical acceptance reviewed.
  Verification tier: `focused`
  Focused checks: Review the original June12 card against its qualified version and the book's count-free regression description; preserve all original numerical observations as dated record text, leave production/tests/CI and the book unchanged, regenerate Knowledge Map, run memory/history/diff checks and all normal doctrines.
  Canonical trigger: None; dated documentation qualification only, with no test/runtime/contract or mechanical owner change.
  Claim verification: none: This slice qualifies the lifecycle of an existing dated record; it publishes no new measurement or performance estimate.
  Verification: Qualified the original June12 Phase0 card as historical without refreshing its line, subtest, spec or timing observations. Replaced the misleading line-count-only reverification with original-record retrieval and complete-TAP guidance. Existing book coverage is count-free and stays unchanged; no production, tests, CI, contract or runtime behavior changes. Focused memory/Knowledge/history/diff checks and all normal doctrines govern landing. The original card is recoverable from clean11f6a87d1; no new duration or completeness claim is inferred.
  Commit: `REPO-HYGIENE.12 - qualify historical Phase0 measurements` (Git owns identity).
  Handoff: Check bounded-history capacity from this clean commit, then activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0 for private original-origin handoff. Freeze the210-input diagnosis at its original committed boundary before changing any bound producer or book input; preserve original hashes. Mapped replacement .1.1 and independent canonical .2 remain required.

- ID: `REPO-HYGIENE.13`
  Status: `done`
  Priority: P2 — due daily metadata review before residual-producer diagnosis.
  Goal: Review the due artifact population without deleting retained proof data or reusable caches.
  Activation: Clean 60e8ef2ab571bab5d951e0d6f701daf1752df36e; capacity canonical gate and commit completed, post-commit pointer PASS, brief0 and clean Git confirmed.
  Reproduce: The latest record is 2026-10-07T13:28:24.094691+00:00; it became over24h old during the capacity canonical run.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.13-* metadata/review/capture producers and retained results; docs/claims/REPO-HYGIENE.13.json; latest cleanup record; cleanup Knowledge card; task/index/live/resume/change/notes; mode/revision-only preservation of intersecting original live claims. Scratch remains repository-relative under .linkedspec-data/scratch/hygiene13.
  Verification tier: `focused`
  Focused checks: Read-only same-volume parent metadata census and three explicit Rust release/incremental/deps log-bin locations; exclude submodules, nested repositories, symlinks, foreign volumes, managed runs and caches before traversal. Independently verify each observed path/type/size, test aggregate and balanced-size corruption plus traversal boundary fixtures, and retain actual commands/exits/full channels with source guards. Preserve original claim hashes at exact activation; review unchanged public retention guidance; run memory/Knowledge/history/claim/diff and normal doctrines.
  Canonical trigger: None; dated retention review with no storage/runtime/contract/gate mechanism change.
  Claim verification: `docs/claims/REPO-HYGIENE.13.json`
  Acceptance: Publish exact dated metadata and effective independent controls before overwriting the latest-only date. Delete only a proved exact disposable target; otherwise zero deletion. Never traverse another repository or run recovery/purge. Commit before resuming SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1.

  Preparation corrections: The initial preservation helper indexed a missing legacy durability mode; exact initial source, actual error channels and75 original loaded claim inputs remain retained. The corrected selector admits only explicitly live records. The initial publisher matched an inline `##` example before the real CHANGES heading; the actual history check rejected its missing manifest preamble. Exact rejected chronology outputs/source/channels remain retained. Heading-only matching and reconstruction from clean activation restore the complete original preambles and records; an independent publication check verifies the correction. Neither rejected preparation is acceptance.

  Verification: PASS; Dated 2026-10-08T15:03:20.586063+00:00 census retains 12225 parent candidates/14790774770 bytes; three Rust log/bin locations are observed separately. Fresh metadata and independent lstat agree; size/boundary fixtures and four actual-channel RED controls pass. Zero removals; proof data and caches remain retained. The capacity claim preserves all198 original hashes at clean60e8ef2ab; the original legacy-mode preparation failure is retained. Public retention guidance is unchanged; focused checks and normal doctrines govern landing.
  Commit: `REPO-HYGIENE.13 - retain due artifact review` (Git owns identity).
  Handoff: Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1 from clean committed HEAD.

- ID: `REPO-HYGIENE.14`
  Status: `done`
  Priority: P2 — due daily review at the clean foundation boundary.
  Goal: Review the due artifact population while retaining proof data and reusable caches.
  Activation: Clean 85691a26603ffd5c2453c39237fb4de407861d7f; foundation and Knowledge correction hooks/post-commit pointers pass; brief0 and no modified/untracked files confirmed.
  Reproduce: Latest cleanup record 2026-10-08T15:03:20.586063+00:00 is over24h old.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.14-* census/review/capture/claim producers and retained actual channels; docs/claims/REPO-HYGIENE.14.json; latest-only cleanup record; existing cleanup Knowledge card; task/index/live/resume/change/notes; mode/revision-only preservation of any intersecting live claims. All fixtures stay in repository-local .linkedspec-data/scratch/hygiene14.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent census and three explicit Rust release/incremental/deps log-bin locations; exclude submodules/nested repositories/symlinks/other volumes/managed runs/caches before traversal. Fresh census plus independent per-file OS lstat, aggregate/balanced-size controls and traversal fixtures; actual guarded producer/exits/full-channel review and evidence controls; preserve original claim bindings; review unchanged public retention guidance; memory/Knowledge/history/claims/diff and normal hooks.
  Canonical trigger: none; dated retention review changes no storage/runtime/contract/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.14.json`
  Acceptance: Retain dated exact rows and independent controls before overwriting the latest date. Delete only an exactly proved disposable target; otherwise zero removal. Recovery/purge remains prohibited under SESSION-STARTUP-READING.7. Commit before activating actual producer/input authority SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.

  Verification: PASS; Dated 2026-10-09T17:03:50.457281+00:00 parent census retains 12244 candidate rows/14790891057 bytes; three explicit Rust paths are recorded separately. Fresh census, independent per-file OS metadata, size/traversal fixtures and four actual-channel corruption controls pass. Zero removals; verification evidence and reusable caches remain retained. This is a dated metadata observation, not disposal safety, content ownership, liveness or recovery/purge acceptance. Original live-claim selector found no intersecting live records; historical claims remain unchanged. Existing public retention guidance was read and remains accurate; no book edit/render required. Memory/Knowledge/history/claim/diff and normal hooks govern landing.
  Commit: `REPO-HYGIENE.14 - retain due artifact review` (Git owns identity).
  Handoff: Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1 only from the ensuing clean boundary.

- ID: `REPO-HYGIENE.15`
  Status: `done`
  Priority: P2 — daily review due at the clean generalized-return boundary.
  Goal: Retain a fresh exact parent/Rust artifact metadata snapshot without removing proof data or caches.
  Activation: Clean edc9165a4559ef8f0e3c34e2b6cc3623f2893feb; all10 generalized-return doctrines, post-pointer/brief0 and clean Git verified. No required job remains.
  Reproduce: Latest cleanup record 2026-10-09T17:03:50.457281+00:00 is over24h old.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.15-* producers/retained channels and docs/claims/REPO-HYGIENE.15.json; latest-only cleanup record and existing cleanup Knowledge card; this tree/index, both current roadmap maintenance pointers, bounded live/resume/history and derived map. Preserve mode/revision-only any intersecting prior live claim before bound writes. All fixture outputs use .linkedspec-data/scratch/hygiene15.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent census and separate Rust release/incremental/deps log-bin metadata; exclude submodules/nested repositories, symlinks, other volumes, managed runs, reusable caches and every prior hygiene fixture before traversal. Fresh scoped census/independent per-file OS lstat, aggregate/balanced-size and traversal fixtures, guarded actual commands/exits/full channels and four reason-sensitive evidence controls; exact old claim preservation if applicable; review unchanged public retention guidance; Knowledge/memory/history/claim/diff and normal hooks.
  Canonical trigger: none; dated retention evidence changes no storage/runtime/public/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.15.json`
  Acceptance: Retain exact dated rows/channels before overwriting the latest date. Remove only an exactly proved disposable target, otherwise zero removal. SESSION-STARTUP-READING.7 continues to prohibit recovery/purge. Capture/freezer and --capture publication are one-shot writers; final reviewer/publisher defaults readonly. Bind actual measurement/producer inputs without gratuitous mutable continuity bindings. Commit before returning to assignment required PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2; generalized-return306-input proof remains live if no bound input changes.

  Instrument ordering: An independent review was invoked before the actual capture session completed; actual.json was absent and FileNotFoundError rejected before any verification record write. This is a tool-call ordering error, not failed census evidence. Wait for capture exit0 before invoking the reviewer; the final actual-channel controls still reject incomplete evidence. No measurement is admitted from that attempt.

  Owned issue (P3; resolved below): REPO-HYGIENE.2 is marked done with verified July6 behavior but its Commit field remains pending. Reproduce by reading that node; stale historical attribution can mislead recovery. Audit the relevant Git subjects/diffs and repair only the commit projection, preserving dated behavior/pin evidence.

  Resolved historical projections (P3): Targeted Git subject/stat/parent metadata and task diffs identify .1 admission d07ee79ea073823c06711b0cc2cf3516d0f172b6 and .2 admission cf0df422097d55aaf2379cac8907319107406e6b. Original commits themselves introduced the pending commit placeholders. Repair only .1 Commit Log and .2 Commit fields; original behavior, dates, pin observations and verification statements remain unchanged. The later .1 hash-sync commits were pointer refreshes, not the ignore/untracking admission; their self-referential convention is already superseded by ADR0065. No historical runtime recurrence is claimed.

  Verification: PASS — Dated 2026-10-10T17:39:44.064947+00:00 parent census retains13433 rows/15594802423 bytes; Rust release is absent, debug/deps has0 matching files, debug/incremental has483 matching files/2390808592 bytes, recorded separately. Fresh metadata and independent per-file lstat, aggregate/balanced-size/traversal fixtures and four reason-sensitive actual-channel controls pass. Zero removals, no intersecting prior live claims, and readonly19-input7303-byte publication passes. Knowledge1339/10272, memory/history/claims/diff and normal hooks govern landing. Existing public retention guidance was reviewed and remains accurate; no book edit/render is required for this metadata-only maintenance.
  Commit: `REPO-HYGIENE.15 - retain due artifact review and repair commit pointers`
  Handoff: Resume assignment required PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 from clean HEAD; preserve306 generalized-return inputs before bound writes. Current generalized-return live claim stays unchanged throughout hygiene.

- ID: `REPO-HYGIENE.16`
  Status: `done`
  Priority: P2 — daily retained review due before the owned container-cache repair.
  Goal: Retain a fresh exact parent/Rust artifact metadata snapshot; remove only exactly proved disposable files and preserve proof data/caches.
  Activation: Clean fc96936fb64d27e692e66377b2e332641c2674fd; optional-kind .2 actual commit/all10 doctrines/post-pointer/post-memory/brief0 and clean Git verified. No required job remains. Cleanup Knowledge card, original .15 tools/contract, current latest-only record and public documentation-workflow retention section reviewed.
  Reproduce: Latest cleanup 2026-10-10T17:39:44.064947+00:00 is over24h old.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.16-* instruments/retained channels and docs/claims/REPO-HYGIENE.16.json; latest-only cleanup record and existing cleanup Knowledge card; this tree/index, private factory current frontier and discovered readonly-reviewer repair planning only, current roadmap maintenance/callback projections, bounded live/resume/history and derived map. Preserve every intersecting original live claim/full record before bound writes. Fixtures remain in .linkedspec-data/scratch/hygiene16; exclude all prior hygiene fixtures.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent census plus separate Rust release/incremental/deps log-bin metadata. Exclude every submodule/nested repository, symlink, other volume, managed run/cache, book/Dart output and prior hygiene fixture before traversal. Retain actual guarded commands/exits/full channels, fresh scoped census/independent per-file lstat, aggregate/balanced-size/traversal fixtures and four reason-sensitive channel controls; original intersecting claim preservation if any; unchanged public retention teaching review; Knowledge/history/memory/claim/diff and normal doctrines.
  Canonical trigger: none; dated retention evidence changes no storage/runtime/public/toolchain/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.16.json`
  Acceptance: Keep original snapshots immutable; advance latest date only after actual census/review completes. Zero removals is valid if no exact disposable target is proved. SESSION-STARTUP-READING.7 prohibits recovery/purge. Capture/freezer/--capture publication are one-shot writers; default final reviewer/publication are readonly. Existing book retention guidance remains accurate; no new public behavior or book prose is needed for this metadata review. Commit before readonly accepted-claim census repair .3.2.1.10, then container-cache .9. The .2 publication byte bindings stay unchanged here; .10 owns the current-namespace/fixed-baseline review defect exposed by a new unrelated claim.

  Owned preflight finding: .2-review.py enumerates current claim files before git-show at fixed61cca1ccc. Actual git cat-file confirms the new hygiene16 claim absent there; once published, this unrelated path is expected to refuse the readonly review. Retain the actual .2 readonly publication baseline before publishing the unrelated new claim. P2 private proof-routing .3.2.1.10 now owns the exact first runtime reproduction and verified repair immediately after this clean hygiene commit, before cache .9. No retired producer or native evidence is changed here.

  Verification: PASS — Dated2026-10-11T18:33:20.336100+00:00 parent14888 rows/16643190359 bytes. Rust release absent; debug/deps0; debug/incremental483 rows/2390809875 bytes, separate from parent. Fresh census/independent per-file lstat, aggregate/balanced-size/traversal and four reason-sensitive full-channel controls pass. Zero removals; original live intersections0. Actual preceding optional-kind readonly366/85779 baseline PASS before new claim publication. Readonly24-input9306-byte retention publication passes. Existing book retention guidance remains accurate; no public prose change/render needed. Knowledge1349/10390 and both histories/memory/claims/diff/normal hooks govern landing. .10 owns current-namespace/fixed-baseline proof routing before cache .9; no product or full-private admission.
  Commit: `REPO-HYGIENE.16 - retain due artifact metadata review`.
  Handoff: Activate PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10 from clean HEAD; retain the actual new-claim refusal and original .2 publication before a new readonly repair. Then cache .9 and giant kind .3. Existing .2 byte bindings/observations remain unchanged here.

- ID: `REPO-HYGIENE.17`
  Status: `done`
  Priority: P2 — overdue daily retained review after the clean branch-expansion handoff.
  Goal: Retain a fresh exact parent/Rust artifact metadata snapshot; delete only exactly proved disposable files and preserve evidence/caches.
  Activation: Clean d432a955ca7a976ccbc3fa047f97bc5e3103ea76 after expansion .5.1.0/26148/0/all10; post-pointer/post-memory0, brief0 and clean Git verified. Existing cleanup Knowledge boundary, .16 complete census/reviewer/capture/claim contracts, latest-only date, roadmap maintenance owner and unchanged public retention guidance reviewed. This dated observation adds no storage/runtime/public mechanism.
  Reproduce: Latest cleanup 2026-10-11T18:33:20.336100+00:00 is over24 hours old on October16.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.17-* instruments/full actual channels and docs/claims/REPO-HYGIENE.17.json; latest-only docs/ARTIFACT_CLEANUP.md; this task/index, current callback handoff/roadmap maintenance projections, bounded resume/live/change history. Existing Knowledge, book and all456 current callback claim bindings remain unchanged. Fixtures remain under .linkedspec-data/scratch/hygiene17; exclude every prior hygiene fixture. No writes to other repositories or submodules.
  Verification tier: `focused`
  Focused checks: Fixed accepted Git claim namespace and original-input census before bound writes; actual current456/full108786 readonly baseline; non-following same-volume parent census and separate Rust release/incremental/deps log-bin metadata; fresh comparison and independent per-file lstat; aggregate/balanced-size/traversal fixtures; full guarded commands/exits/channels and four reason-sensitive evidence RED controls. Review unchanged book retention teaching; Knowledge/memory/history/claim/diff and all normal doctrines. Recheck current callback publication after adding this unrelated claim.
  Canonical trigger: none for dated retained metadata; no public, runtime, storage/toolchain/gate mechanism changes.
  Claim verification: `docs/claims/REPO-HYGIENE.17.json`
  Acceptance: Preserve all original dated snapshots. Update the latest-only cleanup date only after actual census and live reviewer complete. Zero removals is valid when no exact disposable target is proved. SESSION-STARTUP-READING.7 prohibits recovery/purge; no liveness or deletion work is authorized by this review. Capture/freezer and --capture publication are one-shot; final reviewers/publication default readonly. No new structural fact or public behavior is introduced; existing Knowledge/book teaching stays accurate. Commit before resuming attached parser .5.1.1. No independent helper/private/parent/canonical admission.
  Activation preparation: A first inline frontier sorter rejected the Markdown ruler before any file write. The corrected numeric-row selector sorts the existing13/14 display rows and creates this ownership record; no repository work or measured capture was lost or refreshed.

  Verification: PASS — Freeze76729/0 proves zero live intersections; current callback baseline19017/0 retains456/full108786. Actual capture55582/0 and review59475/0/readonly35387/0 verify full census/live review and four channel controls. Dated snapshot 2026-10-16T21:30:30.876883+00:00 records16045/17237976411 parent, separate incremental483/2390810574, deps0, release absent; zero removals. Claim capture/readonly0 retains22/full9417. Existing callback readonly21211/0 still passes after new claim publication. All456 original bindings and current Knowledge/book bytes stay unchanged. Both history checks, memory/diff and normal all10 doctrines govern landing. No new engineering-notes record is needed: this repeats the established metadata/retention procedure without a new structural or causal conclusion.
  Commit: `REPO-HYGIENE.17 - retain due artifact metadata review`; derive accepted hash from Git.
  Handoff: Activate PERL-PRIVATE-FACTORY-CAPTURE.5.1.1 from the ensuing clean boundary; current callback456/full108786 and this22/full9417 claim retain their separate live input sets. Preserve every intersecting live claim before later book/Knowledge writes.

- ID: `REPO-HYGIENE.18`
  Status: `done`
  Priority: P2 — due daily retained metadata review at the clean finite-history boundary.
  Goal: Retain current parent/Rust artifact metadata and verify the existing retention boundary; delete only exactly proved disposable files.
  Activation: Clean e2ec1e96bc47633599f0935ed6828c1a0b99e40a after finite-history .5.1.3, approved-host canonical PASS/1035 Phase0, all10 doctrines, promoted receipt, brief0 and explicit post-pointer/post-memory0. October16T21:30:30UTC cleanup is over24 hours old. The .17 census/review/capture contracts, current cleanup Knowledge boundary and book retention teaching are reviewed. Other repositories/submodules remain excluded and read-only. SESSION-STARTUP-READING.7 prohibits recovery/purge.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.18-* producers/full channels and docs/claims/REPO-HYGIENE.18.json; latest-only docs/ARTIFACT_CLEANUP.md; this tree/index, callback handoff and roadmap/current continuity/CHANGES.md; mode/revision-only projection of every intersecting accepted live claim; eleven current Knowledge reverify headers/derived map and the book workflow entrypoint. Preserve complete507-input/117862-byte .5.1.3 publication and actual readonly baseline before all bound writes. No runtime, gate, dependency, pin or budget change; previous snapshots/producers stay immutable.
  Verification tier: `focused`
  Focused checks: Fixed accepted claim namespace/all original bindings and actual readonly baseline before shared writes; non-following same-volume parent census plus separate Rust release/incremental/deps log-bin metadata; fresh comparison, independent lstat, size/traversal fixtures and four full-channel evidence controls. Verify historical publication/projection, exact Knowledge header-only overlays/full population, current book source/includes/rendered route, both chronology checks, memory/claim/diff and all normal doctrines.
  Canonical trigger: none; a dated retention observation and current proof routes change no public/runtime/storage/toolchain/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.18.json`
  Acceptance: Keep all dated evidence/caches; update the latest date only after actual census and live review. Zero removals is valid without an exactly proved disposable target. No liveness/recovery/purge or new callback/private/parent admission. Retire one-shot capture writers and provide a readonly current review. The retained mode-reader correction adds one complete dated engineering record; no other engineering chronology changes. Commit before if/while .5.2; no dirty pivot.
  Next action: If/while .5.2 follows the clean focused landing; its first action preserves the current155/full40701 publication and actual readonly baseline before bound writes.
  History insertion defect (P2, owned here): Focused history check catches the own new CHANGES record inserted at the inline ## example rather than a line-start heading, truncating its manifest preamble. Actual history-refusal e28ace/0 retains child255, both full channels and complete malformed root without rewriting it. Restore the exact accepted preamble and insert at an anchored multiline heading; the still-unexecuted final publisher uses the independent same boundary plus the unchanged public history gate. No archived history is modified.
  Final mode repair scope: Existing canonical mode card is extended with the dated full1486-row census; one complete dated engineering record preserves the re-derived rule. Its original card has zero live intersections, and the entire .3 publication (including original engineering notes) was preserved before these writes. First route/book captures remain immutable; distinct final routes retain twelve overlays (eleven header-only and the mode card), with original/current mode representations separate. First/final book readers verify separate complete89-input epochs.
  Publication reader defect (P2, owned here): First publication1a8108/1 falsely equated tar archive permissions with checkout permissions. Actual census ca0861 finds all1486 archive0664 versus Git100644/current0644 and zero current/Git drift. Existing project-root-evidence-filesystem-modes already separates these representations; preserve actual captured modes instead. Retain first publisher/full failure and all first Knowledge/book captures; distinct final publisher/current route/book captures must verify the correction. Additional owned card project-root-evidence-filesystem-modes has zero accepted live intersections (10531d/78533 census); record this re-derived representation rule there with exact source census. No chmod, project/runtime/toolchain change or budget increase.
  Reader defect (P2, owned here): First actual-review d5c447/1 accessed inputs before filtering a disclosed gap leg. Accepted claim .3.1.1.0 claim1 has status gap/reason/repair_owner; tools/check_claim_verification.py:79-85 deliberately permits no inputs. Full original source/channel and exact guard correction remain in REPO-HYGIENE.18-review-failure.json. Distinct review-actual-final.py filters non-live legs first and writes a separate final verification; all original live507 custody checks remain. Verify this correction before closure; original capture is not rerun.
  Orchestration refusal: Reviewer67d322/1 was launched before capture89220 completed; actual.json did not yet exist and no verification record was written. Full actual combined channel/source identity is retained in REPO-HYGIENE.18-review-premature.json. Own the ordering correction: await capture completion, then retry the identical reader; no producer or observation is changed.

  Verification: PASS — freeze65397/0 preserves whole507/full117862 and actual baseline before all bound writes. Capture89220/0 retains dated16310/17449713515 parent, separate Rust483/2390810648/deps0/release absent; no files removed. Corrected actual reader63227/0 passes four channel/three preservation controls; first failures stay frozen. Mode census5513/0 retains all1486 archive0664/Git100644/filesystem0644 and zero additional live intersections; no chmod. First/final complete book89/four controls pass with distinct readers. Final routes58920/0 retain full1486/twelve overlays/8387213 bytes; final publication37924/0 owns155/full40701. History refusal e28ace/0 retains actual255 and entire malformed root; accepted preamble restored, both current pressure checks pass. Normal doctrines, explicit memory/diff and final readonly recurrence govern focused landing.
  Commit: `REPO-HYGIENE.18 - retain due artifact review and input custody`; Git owns accepted identity.
  Handoff: Commit, clear brief0 and verify clean/post-pointer state before activating if/while .5.2. No push; current155/full40701 remains the only intersecting live publication, with original507/full117862 historical at e2ec1e96b.

- ID: `REPO-HYGIENE.19`
  Status: `done` / focused-signoff-complete
  Priority: P2 — overdue daily retained review at the clean finite-continuity boundary, before fixture admission .7.
  Goal: Retain current parent/Rust artifact metadata and complete public compiler-summary evidence from the warranted canonical run; preserve all evidence/caches and update the latest review date.
  Activation: Clean e953f69a9934c4ab48e643e69c9efaba0cb1d534 after finite continuity .5.8; canonical CI/Phase01035 and all10 normal hooks pass, receipt promoted/check-head, post-pointer/memory pass, brief0 and clean Git verified. October17T22:08:22UTC cleanup is over24h old. Existing census/review/retention and mode-representation cards are reviewed. Additional read-only accepted live-claim census finds no binding to this tree, warning tree/card or cleanup date; full planned-surface preservation precedes every bound write.
  Owned paths: New docs/checkpoints/REPO-HYGIENE.19/ producers/metadata/full channels/public-log evidence and docs/claims/REPO-HYGIENE.19.json; latest-only docs/ARTIFACT_CLEANUP.md; this tree and current warning-census .1 observation/schedule, private-factory handoff, roadmaps/index/current continuity and complete change/note records; mode/revision-only preservation of intersecting live claims; thirteen existing current reverify routes plus rust-dependency-warning-baseline, derived map and book workflow entrypoint. Other repositories/submodules remain read-only black boxes; no runtime, test/gate mechanism, dependency pin or budget change.
  Verification tier: `focused`
  Focused checks: Preserve whole550-input/128458-byte accepted capacity publication and actual readonly baseline against the fixed accepted claim namespace before shared writes. Actual non-following same-volume parent and separate Rust release/incremental/deps metadata, fresh census, independent lstat, size/traversal fixtures and full-channel controls. Retain the complete successful canonical log, original staged receipt and partial/final observation records; independently verify per-line compiler-summary identity/phase/count with effective omissions, swapped crate/count, forged receipt/log and exact restorations. Complete original/current Knowledge and header/body custody, book/includes/rendered current route, both histories, memory/claim/whitespace and all normal doctrines.
  Canonical trigger: none — this dated retention/public-output observation changes no public/runtime/storage/toolchain/gate mechanism. The accepted .5.8 canonical receipt is retained as observed evidence; this leaf grants no new canonical/private/parent admission.
  Claim verification: `docs/claims/REPO-HYGIENE.19.json`
  Acceptance: Keep every dated proof and reusable cache; zero removals is valid without a proven disposable target. No liveness/recovery/purge or concurrent adversarial guarantee. Preserve separate partial/final log observations and old1870/26 baseline as dated evidence. New7093 compiler-reported PGEN summaries are output observations, not distinct bugs, comparable configurations or an internal cause. Existing RUST-DEPENDENCY-WARNING-ZERO.1 owns the fuller public census and .2 owns upstream reporting/evaluation behind active residual repair; no dependency implementation inspection or source-changing cargo suggestion. Record/schedule this finding durably here without closing that program. Commit before .7; no dirty pivot.
  Verified result: REPO-HYGIENE.19 retains dated16443 parent artifact rows/17576851726 bytes and separate Rust incremental483/2390810573; zero removals. Whole550-input/128458-byte capacity publication and actual baseline stay historical at e953f69a9. Four metadata-channel, eight warning-artifact and four custody/rendered-count denials restore exact PASS. Complete warranted canonical output retains24 public compiler-summary occurrences:12 pgen reports7093 and12 rgx-core reports26, with actual raw-line/phase/receipt reconstruction. These are output counts, not distinct defects, comparable configurations or causes; old1870/26 stays preserved. RUST-DEPENDENCY-WARNING-ZERO.1/.2 keep fuller public census/upstream ownership non-blocking and open. Full Knowledge1487 Markdown/1349 facts/fourteen routes/one body/8388524 bytes and book89/four controls pass; thirteen card bodies and native teaching stay exact. Original prewrite budget refusal and reader line-count failure remain retained with precise corrections. Focused normal-hook landing precedes fixture .7, pipeline .6, metadata .12 and TYPE-REFERENCE-BOOK; startup.7 restrictions and broader admissions remain open.
  Owned review defect / P2: The first independent reader required equal physical line counts for a four-line expression condensed to one. Original source/full actual refusal remain unchanged; distinct final reader compares exact expression boundaries/prefix/suffix and actual repair reconstruction passes. Original Knowledge proposal8388673 is refused before any writes; concise evidence expression alone gives8388524 under unchanged8MiB.
  Verification: Complete dated metadata/live/source/channel and public-summary/receipt review PASS; controls4+8+4 preserve full counterfactual bytes/modes/channels and exact restoration. Complete1487 Knowledge and book89/four controls PASS. Both history checks, explicit memory/syntax/whitespace and all normal doctrines govern focused landing. No new canonical/private/parent admission.
  Commit: `REPO-HYGIENE.19 - retain artifact and compiler-summary evidence`; Git owns accepted identity.
  Next action: Verify normal-hook commit, clear brief0/post-pointer/memory and clean Git, then activate fixture .7; no push or dirty pivot.

- ID: `REPO-HYGIENE.20`
  Status: `done` / focused proof; normal landing required
  Priority: P2 — overdue daily artifact review, before registered pipeline11.
  Goal: Inspect dated parent/Rust artifact metadata and retained toolchain conventions; preserve evidence/caches unless an exact disposable target is proved safe; refresh the latest-only record.
  Activation: Clean79c68715 after count/first10 canonical CI, private91/32246, Phase01035, all10 normal hooks, receipt promotion, explicit post-pointer/memory, brief0 and clean Git. Actual clean readonly publication4 and11129 physical inputs/11132 independently Git-verified full-mode images plus older logical aliases precede this first tracked write. Complete checked-live census finds no direct planned-surface intersections; accepted10 additionally binds its whole physical manifest and is preserved/retired only at79c68715.
  Owned paths: docs/checkpoints/REPO-HYGIENE.20/; this task tree, latest-only docs/ARTIFACT_CLEANUP.md, normal live continuity/roadmap/index/history, artifact, helper and mode reverify headers/derived map and maintenance book guidance; mode/revision-only retirement of claim10 and its checkpoint boundary note. No runtime, permanent test, dependency, cache policy, storage/gate mechanism or budget change.
  Verification tier: `focused`
  Focused checks: Whole accepted10 custody and actual readonly baseline before tracked writes; non-following parent and explicit Rust log/bin census, fresh comparison and independent per-file lstat; retained Dart/Julia/Lua conventions; actual metadata/channel falsifiers and restoration; current source/claim binding, complete affected book render with effective marker control, core scalar numeric consumer, Knowledge, both bounded histories, memory/whitespace and all normal doctrines.
  Canonical trigger: none — ordinary dated maintenance; the accepted10 canonical receipt is retained, with no new public/runtime/infrastructure admission.
  Claim verification: `docs/claims/REPO-HYGIENE.20.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Latest record2026-10-20T19:45:58.736082+00:00 is over24h old; committed count/first10 is clean and admitted.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Scheduled maintenance is due; established non-following census excludes all other repositories, managed runs, retained caches and old fixtures. Metadata alone never authorizes deletion.
  - [x] **FIX** — Complete the owned review and latest-only date/disposition without deleting proof or reusable data.
  - [x] **ADDRESSED (verified)** — Retained full actual channels, independent metadata oracle and effective denials.
  - [x] **NO REGRESSION** — Focused core/book/provenance/doctrines pass; accepted10 stays independently recoverable at its real revision.
  - [x] **LOCKSTEP** — Current book/Knowledge/task/roadmap/handoff describe this maintenance scope and resume11.
  Owned proof defect: Initial custody healthy/restored checks wrongly equate full filesystem permissions with Git mode. The existing canonical mode card already distinguishes them. All36 recorded differences (35x0640/100644,1x0750/100755) and original source/channels remain whole. The first repair preflight also overgeneralized the displayed subset and stops before source writes; its exact source/log remain retained. Correct with separate Git identity and captured full-mode checks, without chmod; test executable and other permission corruption in a distinct epoch.
  Custody correction verified: real Git checks blob/mode identity separately; full filesystem permissions match the original manifest or three complete owned packets. Distinct healthy/restored checks and four actual missing-image/executable/other-permission/baseline denials pass. Original failed reviewer/preparation/data remain whole; no chmod. Complete89-input book and actual missing-marker RED pass. Focused scalar/Knowledge/history/doctrines and normal landing remain required.
  Limits: Dated metadata, not content ownership/disposability or concurrent-adversarial/liveness/recovery/purge evidence. Zero removals is valid. Other repositories/submodules remain strictly read-only; reusable cache/package/compiler outputs remain retained by default. No push until PNT is exhausted.
  Commit subject: `REPO-HYGIENE.20 - review retained project artifacts`.

  Verified disposition: dated22234 parent candidates/21703659874 bytes;483 Rust incremental candidates/2390835179 bytes, with the other five explicit root/crate locations empty or absent. Retain every artifact/cache: zero removals. Actual two-census/fresh/per-file OS and six traversal controls pass; aggregate, coherent balanced-file, producer-channel and source-identity faults reject for their named reasons. Whole accepted10 and actual clean readonly0 remain bound to real79c68715. Complete book/core/Knowledge/history/doctrines and normal focused landing govern admission; no new runtime feature or dependency classification.

- ID: `REPO-HYGIENE.21`
  Status: `done` / focused proof; normal landing required
  Priority: P2 — due daily artifact review before signed-selector17.
  Goal: Perform the dated non-following parent/Rust artifact review; retain proof and caches unless an exact target is proved disposable; refresh the latest-only record.
  Activation: Clean 1e6096435e0ea14a8414a263939bbb75cb2b1310; deferred-write12 canonical receipt promoted, all10 normal hooks/post-pointer pass, brief0 and clean Git. Whole accepted12 publication4 and actual readonly baseline precede this first tracked write; all regular images are independently Git-verified with separate full filesystem modes.
  Owned paths: docs/checkpoints/REPO-HYGIENE.21/; latest-only cleanup record, this tree and normal live continuity/index/roadmap; artifact and two deferred-write Knowledge reverify headers/derived map; maintenance book example; mode/revision-only historical12 claim boundary and its checkpoint note. No runtime, permanent test, cache/storage/gate policy or budget changes.
  Verification tier: `focused`
  Focused checks: Whole accepted12/source custody and live-claim intersection census; two non-following metadata censuses, independent per-file lstat, six Rust locations and toolchain conventions; effective metadata/custody/input controls; complete supplied book render and missing-marker control; unchanged core scalar consumer; Knowledge/history/memory/whitespace and all normal doctrines.
  Canonical trigger: none — ordinary dated maintenance, preserving the accepted12 receipt without new runtime/public contract/infrastructure admission.
  Claim verification: `docs/claims/REPO-HYGIENE.21.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Latest cleanup record October22 01:46 UTC is over24h old; admitted12 is clean.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Scheduled metadata review is due; existing non-following census excludes other repositories and retained caches/managed runs.
  - [x] **FIX** — Retain all artifacts unless exact disposability is established; advance the latest date only after proof completes.
  - [x] **ADDRESSED (verified)** — Actual channels, independent per-file oracle and named controls required.
  - [x] **NO REGRESSION** — Focused core/book/provenance/doctrines; original12 remains recoverable at its real accepted revision.
  - [x] **LOCKSTEP** — Latest record, book/Knowledge/current pointers agree and resume signed17 from clean Git.
  Authoring refusal: The first inline activation proposal reused triple-single quotes for its outer controller and nested task text. Python refused parsing before any code or file mutation (exit1, invalid character U+2014). The exact original whole stdin was not separately retained; this syntax refusal earns no product/control evidence. A distinct double-quoted controller performs the actual clean baseline and first owner write.
  Limits: Dated metadata does not establish content ownership/disposability, liveness/recovery/purge or concurrent-adversarial safety. Zero removals is valid; other repositories remain read-only.

  Verified disposition: Dated 2026-10-23T16:47:31.468358+00:00 parent 22830 candidates/22207314907 bytes; Rust incremental 483/2390835129, with all six locations recorded separately; zero removals. Fresh/lstat/traversal proof, four metadata/four custody/three input controls and actual book-marker RED pass. Whole accepted12 and actual clean readonly0 precede writes; complete book89 and unchanged scalar core pass. Normal focused doctrines/hooks govern landing; signed17 follows clean Git.
  Engineering notes: unchanged; this repeats the established dated metadata/retention procedure without a new structural or causal conclusion.
  Commit subject: `REPO-HYGIENE.21 - review retained project artifacts`.

- ID: `REPO-HYGIENE.22`
  Status: `done`
  Goal: Perform the next due same-volume artifact review after API planning1, then resume Rust signed-selector17.3.
  Schedule: At activation the prior cleanup record was dated2026-10-23T16:47:31Z; the24-hour boundary passed during literal-kind22 verification. Activation followed the clean API planning commit.
  Activation: Clean `d6446ce991c6141838a9fa80396e3890bce274e0`; API planning1 passed all10 normal hooks and post-pointer checks, brief0 and clean Git verified. No required job remains from the preceding leaf.
  Owned paths: docs/checkpoints/REPO-HYGIENE.22/; docs/claims/REPO-HYGIENE.22.json; latest cleanup record; this tree, index, roadmaps and live continuity; current artifact Knowledge header and maintenance book example. Previous sealed proofs and all runtime/gate/storage policy stay unchanged.
  Verification tier: `focused`
  Focused checks: Non-following parent/six-location Rust census, repeated actual channels and independent per-file/population metadata; traversal and corrupted-record RED controls; retained producer/input identities; book rendering and focused Perl syntax; history, memory, whitespace and all normal doctrine hooks.
  Canonical trigger: none: Dated maintenance and retention only; no runtime, public contract, dependency, storage policy or gate change.
  Claim verification: `docs/claims/REPO-HYGIENE.22.json`
  Acceptance Checklist
  - [x] REPRODUCE / ISSUE — The latest October23 cleanup record is over24h old.
  - [x] ROOT CAUSE (WHY + WHERE) — Daily review is due; inspect metadata through the admitted non-following census boundary.
  - [x] FIX — Complete the dated review and retain every unproved deletion target.
  - [x] ADDRESSED (verified) — Preserve actual channels, independent metadata and effective RED controls with complete bounded producer inputs.
  - [x] NO REGRESSION — Focused book/syntax/provenance and normal doctrines; prior sealed proofs remain unchanged.
  - [x] LOCKSTEP — Latest record, book, current pointers and clean commit workflow agree before Rust17.3.
  Acceptance: Read existing hygiene/knowledge authorities; guard every other Git repository/submodule, symlink, volume and active process boundary. Review parent artifacts and documented Rust/Dart/Julia/Lua locations. Delete only exact proved-disposable project-owned targets, preserving every proof, required log and useful cache otherwise. Capture actual disposition and independent controls before claims; overwrite the latest-only cleanup record after completion. Update book/live pointers and commit before Rust17.3. No recovery/purge or global-cache deletion is authorized by this queue entry.
  Verification: Dated 2026-10-24T20:34:23.372982+00:00 review retains 23966 parent candidates/23129277530 bytes and six explicit Rust locations; zero artifact removals. Independent population/lstat, traversal controls and five metadata denials pass; book95/actual missing-marker RED and three actual input denials/bypass/restoration pass. Actual final reader channels and exact34-input control epoch are retained; current book render and Perl syntax PASS. History/memory/whitespace and normal doctrine hooks govern the focused landing. Prior sealed proofs remain unchanged.
  Commit: `REPO-HYGIENE.22 - review retained artifacts with independent population checks`.
  Tracking repair: API planning1 inserted an archival frontier row with order1 already used by .20. Reproduce in the prior committed Current Frontier table; impact is ambiguous display ordering only. Renumber the existing rows in place; statuses and original evidence stay unchanged.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 0 | `REPO-HYGIENE.24` | `pending` | Owned P2 after feature admission17.7; current PNT returns directly to Julia17.5. |
| 1 | `REPO-HYGIENE.23` | `done` | Verified allocated Rust105.2GiB/history111.0GiB removal, lossless archive52.7MiB; protected evidence retained. |
| 2 | `REPO-HYGIENE.22` | `done` | Dated retention review verified; Rust17.3 follows clean landing. |
| 3 | `REPO-HYGIENE.21` | `done` | Previous dated retained review; original proof remains unchanged. |
| 4 | `REPO-HYGIENE.20` | `done` | Due retained review at clean79c68715; resume pipeline11 after normal landing. |
| 5 | `REPO-HYGIENE.19` | `done` | Retained metadata/public-output review; fixture .7 follows clean landing. |
| 6 | `REPO-HYGIENE.3` | `done` | User-requested urgent cleanup of safe generated artifacts, including Rust target directories and mdBook output |
| 7 | `REPO-HYGIENE.4` | `done` | Reclaimed about 20G from Rust/mdBook output, Julia compiled caches, and proven stale generation logs without deleting depot or unrelated temp content |
| 8 | `REPO-HYGIENE.5` | `done` | Reclaimed 16G from measured rebuildable caches and 15 provenance-checked stale generation logs. |
| 9 | `REPO-HYGIENE.6` | `done` | Due October1 census retains proof/cache artifacts and records the requested exit handoff. |
| 10 | `REPO-HYGIENE.7` | `done` | Due October2 review after clean instrument recovery; retain proof/cache data and enforce other-repository exclusion. |
| 11 | `REPO-HYGIENE.8` | `done` | Due October3 review after clean diagnosis; preserve proof inputs/cache and return to compiler .6.1. |
| 12 | `REPO-HYGIENE.9` | `done` | Due October4 review after clean private frames; preserve evidence and resume eleven producer hooks. |
| 13 | `REPO-HYGIENE.10` | `done` | Due October6 review after clean Legacy diagnosis; preserve evidence and resume eight call/return/push producers. |
| 14 | `REPO-HYGIENE.11` | `done` | Due October7 review after clean compiler membership; retain proof/cache data and fix maintenance pointers before canonical .0.2.2. |
| 15 | `REPO-HYGIENE.12` | `done` | Historical observations qualified; check history capacity before private handoff. |
| 16 | `REPO-HYGIENE.13` | `done` | Due dated metadata review; preserve proof data and resume residual-producer diagnosis. |
| 17 | `REPO-HYGIENE.14` | `done` | Due dated retained review at the clean foundation boundary. |
| 18 | `REPO-HYGIENE.15` | `done` | Due October10 metadata review retains evidence/caches and repairs historical commit pointers; resume assignment required .5.2. |
| 19 | `REPO-HYGIENE.16` | `done` | Due October11 retained review verified; readonly claim-census .3.2.1.10 precedes cache .9 and giant kind .3. |
| 20 | `REPO-HYGIENE.17` | `done` | October16 metadata/full channels/zero removals verified; attached parser .5.1.1 follows. |
| 21 | `REPO-HYGIENE.18` | `done` | Dated metadata and full historical custody verified; readonly155/full40701 passes; resume if/while .5.2 after clean commit. |

## Decisions

- `2026-06-16`: `.gitignore` entries for `*.swp`, `.DS_Store`, `git_message_brief.txt`. These are tool artifacts that should never be tracked.
- `2026-07-06`: `.claude/projects/` is local agent state. `rgx/` is a real submodule; because it is tracked as a
  gitlink, it should not be `.gitignore`d or untracked. Local dirt inside it is handled by `.gitmodules`
  `ignore = dirty`.
- `2026-07-07`: Rust `target/` trees and mdBook `book/` output are generated/rebuildable artifacts and may be
  deleted for disk-space recovery when the repo is otherwise handoff-ready.
- `2026-07-10`: Julia's generated compiled/precompile output lives under depot `compiled/` directories, including
  the dedicated test depot and the user depot. Those `compiled/` directories are regenerable cleanup targets;
  packages, registries, environments, logs, scratchspaces, and artifacts are distinct and remain preserved.
- `2026-07-10`: Large `/private/tmp` logs may be deleted only after their headers identify a completed repo
  generation run and process/`lsof` checks show no writer. Do not blanket-delete `/private/tmp`; unrelated agent,
  application, and other-project temp trees remain outside this cleanup boundary.

## Open Questions

- None.

## Blockers

- None.

## Acceptance Checklist — REPO-HYGIENE.15

- [x] **REPRODUCE / ISSUE** — Latest October9 date is over24h old at the clean generalized-return boundary. Two old completed hygiene records still contain pending commit placeholders.
- [x] **ROOT CAUSE (WHY + WHERE)** — Daily metadata changes independently of prior retained snapshots. Git task diffs show .1/.2 original commits introduced those placeholders; targeted subject/stat/parent metadata audit identifies the admissions, distinct from later .1 hash-sync refreshes.
- [x] **FIX** — Retain the exact parent/Rust census and actual channels, refresh only latest date/current pointers, exclude every prior fixture and retain all proof/caches. Correct only two historical commit projections; no source/pin/public behavior change.
- [x] **ADDRESSED (verified)** — Dated13433 parent rows/15594802423 bytes; separate three Rust metadata populations; fresh census/independent per-file lstat/size/traversal and four reason-sensitive evidence controls PASS. Readonly19-input7303-byte claim reconstructs; no original live claim intersects the changed surfaces.
- [x] **NO REGRESSION** — Zero files removed. Submodules/other repositories, symlinks, other volumes, managed runs/caches and prior fixtures are excluded. Existing public retention teaching remains accurate; no runtime/generated/toolchain/contract change requires broader CI.
- [x] **LOCKSTEP** — Cleanup record, Knowledge1339/10272, current roadmap/index/live/history/resume and historical commit projections align. Memory/claim/history/whitespace and normal all-doctrine hooks govern landing before the clean assignment handoff. Recovery/purge remains prohibited.

## Acceptance Checklist — REPO-HYGIENE.16

- [x] **REPRODUCE / ISSUE** — October10 cleanup is over24h old at clean fc96936fb; retain a new dated parent/Rust metadata review. Current-namespace/fixed-baseline proof-routing risk has a separate next repair owner .3.2.1.10.
- [x] **ROOT CAUSE (WHY + WHERE)** — Filesystem metadata changes independently of old snapshots. Guarded census excludes all prior hygiene fixtures and non-owned/reusable boundaries before traversal; independent per-file OS lstat tests each retained size. Readonly census defect source location is .2-review.py:291-295, with actual absent-path Git confirmation.
- [x] **FIX** — Retain the exact dated snapshot/actual channels and refresh only current maintenance records/pointers. Zero removals. Retain preceding readonly publication baseline before adding the unrelated new claim; .10 owns the actual refusal and bounded new-reviewer repair.
- [x] **ADDRESSED (verified)** — Parent14888/16643190359; separate incremental483/2390809875, release absent/deps0. Fresh metadata, balanced-size/traversal/four channel controls and readonly24/9306 publication PASS. No prior live byte-binding intersection.
- [x] **NO REGRESSION** — Zero files removed; submodules/other repositories, symlinks/other volumes, managed runs/cache/book/Dart outputs and every prior hygiene fixture excluded. Existing book teaching reviewed unchanged. No runtime/toolchain/storage/public change; no full CI trigger.
- [x] **LOCKSTEP** — Latest-only cleanup record, reused Knowledge1349/10390, current roadmap/index/live/history/MEMORY and owned next repair align. Both history pressure checks, scripts/check_memory_architecture.sh, git diff --check and normal all-doctrine hooks govern landing; recovery/purge remains prohibited.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-10-24` | `REPO-HYGIENE.22` | Dated 2026-10-24T20:34:23.372982+00:00 review retains 23966 parent candidates/23129277530 bytes and six explicit Rust locations; zero artifact removals. Independent population/lstat, traversal controls and five metadata denials pass; book95/actual missing-marker RED and three actual input denials/bypass/restoration pass. | PASS — current book/Perl syntax and final readers; normal focused hooks govern landing. |
| `2026-10-11` | `REPO-HYGIENE.16` | Guarded actual census/fresh lstat, size/traversal/four channel controls, preceding readonly baseline; histories/Knowledge/memory/claims/diff/hooks | PASS — dated retained snapshot/zero removals; source-established proof-routing repair .10 next. |
| `2026-10-10` | `REPO-HYGIENE.15` | Guarded actual parent/Rust census, fresh per-file lstat, size/traversal/four channel controls, Git attribution audit; memory/Knowledge/history/claims/diff/hooks | PASS — dated retained snapshot; zero removals; two commit projections repaired. |
| `2026-10-09` | `REPO-HYGIENE.14` | Guarded actual census/review, independent metadata and size/boundary/channel controls; memory/Knowledge/history/claims/diff/hooks | PASS — dated retained snapshot; zero removals. |
| `2026-10-08` | `REPO-HYGIENE.13` | Actual census/live lstat/source guards/boundary fixtures/claim preservation; memory/Knowledge/history/diff and normal doctrines | PASS — dated retained snapshot; zero removals. |
| `2026-10-08` | `REPO-HYGIENE.12` | Original/qualified card and current book review; unchanged production/test/CI paths; memory/Knowledge/history/diff and normal doctrines | Historical lifecycle qualification only; no new measurement. |
| `2026-10-07` | `REPO-HYGIENE.11` | Actual census/live lstat/full channels/book/freeze; memory/Knowledge/history/claims/doctrines/diff | PASS — 10838 parent rows/13805895079 bytes; zero removals. |
| `2026-10-06` | `REPO-HYGIENE.10` | Actual census/live reviewer; original Legacy claim freeze; complete book/render controls; retained-claim replay; memory/history/Knowledge/claims/doctrines/diff | PASS — 8931 parent candidates/12619808609 bytes;483 incremental rows/2390808555 bytes; nine nested repositories excluded; zero removals;224 original bindings/112 unique hashes. |
| `2026-10-04` | `REPO-HYGIENE.9` | Actual census/live lstat/fresh metadata, two metadata/four channel/five book controls; claim/Knowledge/history/memory/doctrine/diff | PASS — zero removals; retained exact snapshot; producer hooks .1.1.1.2 next. |
| `2026-10-03` | `REPO-HYGIENE.8` | Tracked census/live lstat/fresh metadata and corruption/fixture controls; book/history/memory/Knowledge/doctrine/diff | PASS — zero removals; exact snapshot retained; compiler .6.1 next. |
| `2026-10-02` | `REPO-HYGIENE.7` | Archived census/review; actual per-path and fixture/corrupt-count controls; book/memory/history/Knowledge/doctrine/diff | PASS — zero removals; exact dated scope/enumeration in checkpoint. Resume claim-policy .0.2.1.4.1. |
| `2026-10-01` | `REPO-HYGIENE.6` | Parent artifact and explicit Rust log/bin census; permitted process/run inspection; mdBook render; memory/history/Knowledge/doctrine/diff gates | PASS — zero removals; exact counts and exclusions in the checkpoint. Milestone2aeed31ff preserves canonical signoff; .1.1.3.4 remains unstarted. |
| `2026-07-17` | `REPO-HYGIENE.5` | Existing cleanup fact retrieval; `df -h`; exact `du`; ignored/tracked checks; main-checkout log/bin/temp scan; exact log header/process/`lsof` proof; removal of Rust/Dart build output, two Julia compiled caches, and 15 exact stale logs; post-absence/depot/unrelated-tree/status checks; memory/KM/task/doctrine/diff gates | PASS — immediate deletion baseline 55G/89% became 71G/85%, reclaiming 16G. Dedicated depot registries/logs, unrelated 18G `claude-501`, unknown temp trees, `rgx` fixtures, and all tracked content remain. The earlier 29G/94% session observation is retained separately because external cleanup occurred before deletion. |
| `2026-07-06` | `REPO-HYGIENE.2` | `.gitignore` update; `.gitmodules` `ignore = dirty`; `git status --ignored`; `git ls-files --stage rgx`; `git submodule status -- rgx`; memory/doctrine/Knowledge Map/diff checks | `.claude/projects/` is ignored; `rgx` remains a tracked submodule/gitlink at `8763a0e`; dirty submodule worktree state no longer dirties parent status. |
| `2026-07-07` | `REPO-HYGIENE.3` | `du -sh rust/target docs/linkedspec-book/book`; ignored/tracked checks; artifact scans for `.log`, `.bin`, `.tmp`, `.bak`, `.DS_Store`, and `.swp`; `rm -rf rust/target docs/linkedspec-book/book`; post-clean existence/status checks; memory/KM/doctrine/diff gates | PASS — removed ignored/untracked `rust/target` (5.2G) and `docs/linkedspec-book/book` (7.0M). Main checkout has no remaining safe log/bin/temp artifact hits outside `.git`, ignored targets, and `rgx`. Submodule `rgx` log/bin hits were preserved as fixture/stimulus/issue corpus material. Cargo/mdBook were not run because they would recreate the removed artifacts. |
| `2026-07-10` | `REPO-HYGIENE.4` | `df -h .`; `du -sh` over Rust target/mdBook output, Julia depot components, `/private/tmp`, and user temp; ignored/tracked checks; Julia `jl_*` scan; process/`lsof`/header provenance checks; removal of four generated cache targets plus twelve stale LinkedSpec/RGX generation logs; post-clean existence/depot/status checks; memory/KM/task/doctrine/diff gates | PASS — removed 1.7G Rust target, 7.8M mdBook output, 148M dedicated-depot Julia compiled cache, 261M user-depot Julia compiled cache, and about 18G of stale generation logs. Availability increased from 50G/90% to 68G/86%; Julia depot data, `claude-501`, unrelated cargo-mutants trees, and `rgx` corpus artifacts remain. |
| `2026-06-16` | `REPO-HYGIENE.1` | `scripts/check_memory_architecture.sh` exit 0; `perl -c perl/LinkedSpec.pm` OK; git status clean | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `REPO-HYGIENE.22` | `REPO-HYGIENE.22 - review retained artifacts with independent population checks` | Dated retention only; Rust17.3 follows clean landing. |
| `REPO-HYGIENE.16` | `REPO-HYGIENE.16 - retain due artifact metadata review` | Dated actual metadata/zero removals and preceding readonly baseline; .10 before cache .9. |
| `REPO-HYGIENE.15` | `REPO-HYGIENE.15 - retain due artifact review and repair commit pointers` | Dated metadata/full channels, zero removals, old attribution repaired; resume assignment required .5.2. |
| `REPO-HYGIENE.12` | `REPO-HYGIENE.12 - qualify historical Phase0 measurements` | Dated observations preserved; private replacement handoff resumes after capacity check. |
| `REPO-HYGIENE.11` | `REPO-HYGIENE.11 - retain daily artifact census` | Exact dated metadata/full channels; zero removals, resume canonical membership .0.2.2. |
| `REPO-HYGIENE.10` | `REPO-HYGIENE.10 - retain daily artifact census` | Exact metadata/actual-channel/book proof; zero removals, resume Legacy call/return/push. |
| `REPO-HYGIENE.9` | `REPO-HYGIENE.9 - retain daily artifact census` | Actual full channels and independent metadata; preserve evidence/cache and return to eleven statement hooks. |
| `REPO-HYGIENE.8` | `REPO-HYGIENE.8 - retain daily artifact census` | Dated snapshot/current OS metadata proof; preserve artifacts and return to .6.1. |
| `REPO-HYGIENE.7` | `REPO-HYGIENE.7 - review artifacts and correct read-only boundary` | Due review preserves all proof/cache data and excludes every other repository. |
| `REPO-HYGIENE.6` | `REPO-HYGIENE.6 - record artifact review and exit handoff` | Due review preserves evidence and caches; clean resume continues .1.1.3.4. |
| `REPO-HYGIENE.5` | `REPO-HYGIENE.5 - clean recurring generated artifacts` | Exact ignored caches and 15 stale generation logs removed; 16G reclaimed; depot and unrelated content preserved. |
| `REPO-HYGIENE.2` | `REPO-HYGIENE.2 - ignore Claude project state and rgx local dirt` | `.claude/projects/` ignore plus `rgx` submodule local-dirt ignore. |
| `REPO-HYGIENE.3` | `REPO-HYGIENE.3 - remove generated artifacts` | Removed ignored/untracked `rust/target` and mdBook build output; left `rgx` corpus artifacts intact. |
| `REPO-HYGIENE.4` | `REPO-HYGIENE.4 - clean Rust and Julia generated caches` | Depot-aware cache and provenance-checked temp-log cleanup; preserved package, registry, and unrelated temp data. |
| `REPO-HYGIENE.1` | `d07ee79ea073823c06711b0cc2cf3516d0f172b6` | Original ignore/untracking admission; later hash-sync commits are historical pointer refreshes, superseded by ADR0065. |

## Changelog

- `2026-10-24`: .22 completes the due retained metadata review with independent population checks; zero removals. The current book/Knowledge and latest-only date agree; Rust17.3 follows clean Git.

- `2026-10-23`: .21 completes the due retained review, accepted12 custody and current book example; no removals. Resume director-priority signed17.

- `2026-10-11`: .16 completes the due retained review with zero removals, exact metadata/full channels/readonly24/9306 and preceding optional-kind baseline. Own fixed-baseline namespace repair .3.2.1.10 immediately after clean landing, before cache .9.

- 2026-10-09: `.14` completes the due retained metadata review at the clean foundation boundary; producer/input authority .2.1 follows.

- 2026-10-08: `.13` completes the due retained metadata review and resumes private residual-producer diagnosis.

- 2026-10-08: `.12` qualifies the historical Phase0 card without a new census or timing claim; resumes private replacement work after history-capacity review.

- 2026-10-07: `.11` verifies the due retained census with zero removals, corrects stale maintenance pointers and resumes canonical membership .0.2.2 after clean commit.

- 2026-10-06: `.10` verifies the due retained census with zero removals and returns to Legacy .1.4.1 after a clean commit.

- 2026-10-04: `.9` verifies due metadata/actual-channel/book proof with zero removals, preserves all inputs/caches and resumes eleven statement event hooks.

- 2026-10-03: `.8` completes the due source-bound census/live metadata controls with zero removals, retains proof/cache data and returns to residual event repair.

- `2026-10-02`: Complete REPO-HYGIENE.7 after clean e3ed7cc824; retain the dated census and archived instruments, correct the current read-only boundary, then resume claim-policy adoption.

- `2026-10-01`: Complete REPO-HYGIENE.6 after clean2aeed31ff; record a conservative zero-deletion census and the director-requested exit handoff.

- `2026-06-16`: Created task tree. Completed REPO-HYGIENE.1 — .gitignore updated, tool artifacts untracked, MEMORY.md current.
- `2026-07-06`: Completed REPO-HYGIENE.2 — `.claude/projects/` ignored and `rgx` kept as a submodule with
  `ignore = dirty` for local worktree noise.
- `2026-07-07`: Completed REPO-HYGIENE.3 — removed ignored/untracked `rust/target` and mdBook build output,
  reclaiming roughly 5.2G plus 7.0M; preserved `rgx` submodule `.log`/`.bin` corpus artifacts.
- `2026-07-10`: Completed REPO-HYGIENE.4 — reclaimed roughly 20G from regenerated Rust/mdBook output, Julia
  compiled/precompile caches, and twelve stale repo generation logs; preserved Julia depot content, unrelated temp
  trees, and all source data.
- `2026-07-17`: Completed REPO-HYGIENE.5 — reclaimed 16G from ignored Rust/Dart output, two Julia compiled
  caches, and fifteen provenance/liveness-checked stale generation logs; preserved depot content, the unrelated
  18G `claude-501` tree, unknown temp trees, `rgx` corpus artifacts, and all tracked content.

- `2026-10-10`: Due retained .15 metadata review passes with13433 parent rows/15594802423 bytes and three separate Rust locations; zero removals. Fresh per-file metadata, traversal and four channel controls pass; readonly19-input7303-byte claim/Knowledge1339/10272 align. A premature review rejected a missing capture before any verification write; final review follows capture completion. Targeted Git audit repairs .1/.2 original pending commit projections without changing dated proof. Normal hooks govern clean landing before assignment required .5.2.

## Acceptance Checklist — REPO-HYGIENE.17

- [x] Original fixed Git claim namespace reviewed before bound writes; zero live intersections.
- [x] Actual predecessor readonly456/full108786 baseline retained; it still passes after adding the new claim.
- [x] Full parent/Rust census, fresh comparison and independent lstat retained with guarded command exits and both channels.
- [x] Size/traversal fixtures and four reason-sensitive actual-channel RED controls pass; zero removals and latest-only date updated.
- [x] Book/Knowledge teaching reviewed and unchanged; existing evidence/caches and every repository boundary preserved.
- [x] Readonly22/full9417 claim, chronology/memory/diff and normal doctrine hooks govern focused clean landing.

## Acceptance Checklist — REPO-HYGIENE.18

- [x] **REPRODUCE / ISSUE** — October16 cleanup is over24h old at clean e2ec1e96b; complete original507/full117862 and actual readonly baseline are retained before shared writes.
- [x] **ROOT CAUSE (WHY + WHERE)** — Dated metadata needs a new observation. New readers exposed premature ordering, unfiltered gap inputs, archive/filesystem mode equality and an inline heading insertion; exact original sources/full reached channels and malformed root remain retained.
- [x] **FIX** — Retain all artifacts/caches and latest-only date; filter non-live legs, keep mode fields separate and restore exact accepted preamble with anchored headings. One existing mode card and one complete dated engineering note preserve the re-derived rule; all original bytes remain recoverable.
- [x] **ADDRESSED (verified)** — Actual capture/live metadata/independent lstat/traversal and four channel/three preservation controls PASS; full1486-mode census, corrected readers and readonly155/full40701 PASS.
- [x] **NO REGRESSION** — Runtime/dependencies/gates/budgets remain exact. Both complete book89/four-control epochs pass; knowledge-map/scripts/check_knowledge_map.sh and both public history pressure checks PASS. No chmod, deletion or recovery/purge.
- [x] **LOCKSTEP** — Current Knowledge twelve overlays, book entrypoint, cleanup record, roads/task frontiers, bounded live/current pointer and git diff --check align; if/while .5.2 follows the clean focused boundary.
