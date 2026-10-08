# REPO-HYGIENE: Repository hygiene — .gitignore and untrack artifacts

## Metadata

- Tree ID: `REPO-HYGIENE`
- Status: `completed`
- Roadmap lane: `Overall roadmap — repository maintenance`
- Created: `2026-06-16`
- Last updated: `2026-10-08` (`REPO-HYGIENE.12`: historical Phase0 record qualified)
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
  Status: `completed`
  Goal: `Repository hygiene — ignore local artifacts and safely reclaim generated caches`
  Children: `REPO-HYGIENE.1`, `REPO-HYGIENE.2`, `REPO-HYGIENE.3`, `REPO-HYGIENE.4`, `REPO-HYGIENE.5`, `REPO-HYGIENE.6`, `REPO-HYGIENE.7`, `REPO-HYGIENE.8`, `REPO-HYGIENE.9`, `REPO-HYGIENE.10`, `REPO-HYGIENE.11`, `REPO-HYGIENE.12`

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
  Commit: `pending`

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

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `REPO-HYGIENE.3` | `done` | User-requested urgent cleanup of safe generated artifacts, including Rust target directories and mdBook output |
| 2 | `REPO-HYGIENE.4` | `done` | Reclaimed about 20G from Rust/mdBook output, Julia compiled caches, and proven stale generation logs without deleting depot or unrelated temp content |
| 3 | `REPO-HYGIENE.5` | `done` | Reclaimed 16G from measured rebuildable caches and 15 provenance-checked stale generation logs. |
| 4 | `REPO-HYGIENE.6` | `done` | Due October1 census retains proof/cache artifacts and records the requested exit handoff. |
| 5 | `REPO-HYGIENE.7` | `done` | Due October2 review after clean instrument recovery; retain proof/cache data and enforce other-repository exclusion. |
| 6 | `REPO-HYGIENE.8` | `done` | Due October3 review after clean diagnosis; preserve proof inputs/cache and return to compiler .6.1. |
| 7 | `REPO-HYGIENE.9` | `done` | Due October4 review after clean private frames; preserve evidence and resume eleven producer hooks. |
| 8 | `REPO-HYGIENE.10` | `done` | Due October6 review after clean Legacy diagnosis; preserve evidence and resume eight call/return/push producers. |
| 9 | `REPO-HYGIENE.11` | `done` | Due October7 review after clean compiler membership; retain proof/cache data and fix maintenance pointers before canonical .0.2.2. |
| 10 | `REPO-HYGIENE.12` | `done` | Historical observations qualified; check history capacity before private handoff. |

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

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
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
| `REPO-HYGIENE.1` | `pending` | Populated after commit |

## Changelog

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
