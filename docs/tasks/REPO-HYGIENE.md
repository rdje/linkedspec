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
  Verification tier: `focused`
  Focused checks: Retain the complete supplied index/LinkedSpec note before use; re-measure allocated sizes and free space; inspect exact tracked/ignored ownership, published retention obligations and permitted process/run liveness before any removal; retain actual commands/exits/channels and before/after per-item and parent/volume measurements. Inspect scratch per concluded experiment with recoverable inputs/results, never infer disposal permission from ignore status. Prefer native Cargo/Git tools; do not expire reflogs or unreachable objects merely because the old note suggests immediate pruning. Verify no current writer and any Git maintenance lease before compaction; preserve all active and retained proof consumers. Completed focused cleanup/reader/Rust/book checks, history pressure, Knowledge, memory/task-pointer and diff checks govern landing. The director explicitly defers broad suites and global registry scans until after feature coverage is complete.
  Canonical trigger: None for this commit after the director explicitly defers broader verification to feature implementation. Changed tracked paths are maintenance evidence/docs only; no shared storage policy, runtime, wrapper, hook, gate or dependency changes. Completed focused safety proof and fast manual continuity checks govern landing. The broad pre-commit registry scan is deferred explicitly under the director’s latest policy; post-commit pointer verification remains enabled. Full validation follows feature completion.
  Claim verification: `docs/claims/REPO-HYGIENE.23.json`
  Acceptance: Report actual bytes reclaimed per item, current parent total/free space and exact retained items/reasons. No blanket deletion, no dependency implementation inspection, no sibling-repository writes and no concurrent cleanup/build. If a candidate cannot be proved safe, retain it and finish the safe subset with its specific blocked disposition recorded.
  Commit: `REPO-HYGIENE.23 - reclaim verified Rust and history fixture artifacts`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.23`.

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
  Commit: `cf0df422097d55aaf2379cac8907319107406e6b` — `REPO-HYGIENE.2 - ignore Claude project state and rgx local dirt`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.2`.

- ID: `REPO-HYGIENE.3`
  Status: `done` (2026-07-07)
  Goal: `Remove safe generated artifacts to reclaim disk space`
  Acceptance: Scan for generated logs, macBinary `.bin` archives, common temp artifacts, mdBook output, and Rust
    target directories; delete only rebuildable generated artifacts that are safe to remove; record reclaimed-size
    evidence; keep source, fixtures, checked-in docs, and user-authored content intact; repo returns to a clean
    handoff state after commit.
  Commit: `REPO-HYGIENE.3 - remove generated artifacts`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.3`.

- ID: `REPO-HYGIENE.4`
  Status: `done` (2026-07-10)
  Goal: `Repeat safe artifact cleanup with Julia-specific cache coverage`
  Acceptance: Measure current disk pressure and generated-output sizes; delete only ignored/untracked Rust build
    output, mdBook output, Julia compiled/precompile caches, and stale temp logs proven to be regenerable; do not
    delete Julia packages, registries, environments, unrelated temp trees, source, fixtures, or user-authored data;
    record before/after evidence and return the repo to a clean committed handoff state.
  Commit: `REPO-HYGIENE.4 - clean Rust and Julia generated caches`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.4`.

- ID: `REPO-HYGIENE.5`
  Status: `done` (2026-07-17)
  Goal: `Repeat urgent safe artifact cleanup under measured low-disk pressure`
  Acceptance: Retrieve the established cleanup boundary before scanning; measure filesystem pressure and exact
    candidate sizes; prove repo outputs ignored/untracked and temp logs both provenance-identified and unwritten;
    delete only rebuildable Rust, mdBook, Dart, and Julia compiled output plus exact stale generation logs; preserve
    Julia depot data, `rgx` fixtures, unrelated temp trees, and all user-authored content; measure reclaimed space,
    synchronize durable evidence, and return the repo to a clean committed handoff state.
  Commit: `REPO-HYGIENE.5 - clean recurring generated artifacts`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.5`.

- ID: `REPO-HYGIENE.6`
  Status: `done`
  Goal: Record the due artifact review and a clean exit handoff after the lossless milestone.
  Acceptance: Census repository-owned stray artifacts and Rust target log/bin locations; delete only exact provably disposable files, preserve reusable caches and proof evidence, overwrite the cleanup date, and commit a bounded resume pointer with no required job outstanding.
  Verification tier: `focused`
  Focused checks: Read-only repository artifact census with nested repositories excluded; permitted process/run liveness inspection; memory/history/Knowledge/doctrine and diff checks; mdBook render for the clarified retention boundary.
  Canonical trigger: none; maintenance record and public clarification only, with no storage mechanism, runtime, contract or gate change.
  Commit: `REPO-HYGIENE.6 - record artifact review and exit handoff`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.6`.

- ID: `REPO-HYGIENE.7`
  Status: `done`
  Goal: Complete the due daily artifact review while retaining proof inputs and correcting the current submodule cleanup boundary.
  Verification tier: `focused`
  Focused checks: Non-following parent-checkout artifact census and explicit Rust release/incremental/deps log/bin locations; exclude nested repositories, all submodules, retained caches and managed runs; record every retained candidate and derive aggregate counts from those rows; fresh census plus direct per-file OS metadata oracle, corrupt-count and balanced-size controls; no deletion; book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none; recurring maintenance snapshot and existing read-only policy clarification only, with no storage, gate, runtime or dependency change.
  Acceptance: Advance the latest review only after a scoped census, preserve all proof/cache artifacts, archive the actual census instrument, correct the maintained permission statement, and commit a clean resume to SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1. No liveness/recovery/purge inference or other-repository write.
  Commit: `REPO-HYGIENE.7 - review artifacts and correct read-only boundary`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.7`.

- ID: `REPO-HYGIENE.8`
  Status: `done`
  Goal: Complete the due daily artifact review before the selected compiler repair while preserving all proof/cache data and repository boundaries.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent artifact census plus explicit Rust release/incremental/deps log/bin locations; exclude all submodules/nested repositories, managed runs, caches and generated book/Dart outputs. Retain each candidate; derive totals from per-file rows; fresh census and independent lstat validate; reject corrupt totals/balanced sizes, prove included/excluded fixture scope. No age-based deletion, process recovery/purge or cross-repository write. Update latest-only cleanup record, book/Knowledge/history/memory/diff and all mandatory doctrines.
  Canonical trigger: none; dated maintenance snapshot under unchanged storage/CI/runtime/dependency mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.8.json`
  Acceptance: Exact retained census and producer/result/controls are recoverable; remove only provably safe exact targets if any, overwrite latest cleanup timestamp/disposition after verification, and commit a clean handoff to SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1. No runtime/performance/liveness or fullCI claim.
  Commit: `REPO-HYGIENE.8 - retain daily artifact census` (Git owns identity).
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.8`.

- ID: `REPO-HYGIENE.9`
  Status: `done`
  Goal: Complete the due daily artifact census after committed private splitter frames, preserving evidence, caches and repository boundaries.
  Verification tier: `focused`
  Focused checks: Same-volume non-following parent metadata census and three explicit Rust log/bin locations; all submodules/nested repositories, symlinks, other volumes, managed runs, caches and generated book/Dart outputs excluded. Fresh census and independent per-file lstat; aggregate/balanced-size corruptions and inclusion/exclusion fixture. Retain all candidates unless exact disposability is proved. Capture actual producer/status/full channels, render public retention teaching, and run memory/history/Knowledge/claims/diff/all doctrines.
  Canonical trigger: none; recurring metadata record under unchanged storage/CI/runtime/dependency mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.9.json`
  Acceptance: Verify dated exact candidate rows and exclusions before overwriting latest cleanup record. No age/size-based deletion, process recovery/purge or other-repository write. Resume self-containment .1.1.1.2 from a clean committed handoff.
  Commit: `REPO-HYGIENE.9 - retain daily artifact census` (Git owns identity).
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.9`.

- ID: `REPO-HYGIENE.10`
  Status: `done`
  Goal: Complete the due daily metadata census after clean Legacy diagnosis; retain evidence, caches and every repository boundary.
  Verification tier: `focused`
  Focused checks: Non-following parent metadata census and explicit Rust release/deps/incremental log-bin locations; fresh scoped census and independent per-file lstat, aggregate inflation/balanced wrong-size rejection and inclusion/exclusion fixture. Retain actual commands/exits/full channels/input guards; verify all original Legacy claim hashes before freezing; render complete book inputs and verify retention teaching. Run memory/history/Knowledge/claims/diff/all doctrines.
  Canonical trigger: none; recurring metadata record under unchanged storage/runtime/dependency/verification mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.10.json`
  Acceptance: Retain all artifacts unless exact disposal is proved. Exclude submodules/nested repositories, symlinks, other volumes, managed runs and retained caches/generated outputs; inspect three Rust metadata locations separately. No deletion based on age/size, no process recovery/purge or other-repository writes. Commit before returning to Legacy .1.4.1.
  Commit: `REPO-HYGIENE.10 - retain daily artifact census`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.10`.

- ID: `REPO-HYGIENE.11`
  Status: `done`
  Goal: Complete the due daily artifact review after clean compiler membership, preserving all proof inputs/caches and correcting stale maintenance pointers.
  Verification tier: `focused`
  Focused checks: Same-volume non-following parent metadata census and explicit Rust release/incremental/deps log-bin locations. Exclude submodules/other repositories, symlinks, other volumes, managed runs, caches and generated Dart/book/Rust outputs before traversal; retain all candidates unless exact disposal is proved. Fresh scoped census and independent per-path lstat, aggregate inflation/balanced wrong-size controls and inclusion/exclusion fixture. Retain actual producer commands/exits/full channels/byte guards and four effective evidence controls. Verify every original compiler claim input at exact Git activation before historical freeze; render all final book inputs and verify review example/five controls. Run memory/Knowledge/history/claims/diff/all doctrines.
  Canonical trigger: None; dated metadata review and documentation pointers under unchanged storage/runtime/dependency/gate mechanisms.
  Claim verification: `docs/claims/REPO-HYGIENE.11.json`
  Acceptance: Advance the latest-only cleanup date only after the exact dated rows and source/metadata/channel/publication controls pass. No age/size-based deletion, recovery/purge or other-repository write. Own and resolve both stale index pointers, commit this bounded maintenance unit, then resume canonical membership .0.2.2 from clean HEAD.
  Commit: `REPO-HYGIENE.11 - retain daily artifact census` (Git owns identity).
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.11`.

- ID: `REPO-HYGIENE.12`
  Status: `done`
  Goal: Preserve the June12 Phase0 observations as dated history and route current reach/runtime to current proof.
  Acceptance: Qualify the original dated observations without refreshing them or inferring a new universal duration. Preserve source/test/CI bytes and actual prior evidence; update Knowledge, task/live/resume/history and run focused documentation checks/normal hooks. Resume replacement repair from a clean commit.
  Verification tier: `focused`
  Focused checks: Review the original June12 card against its qualified version and the book's count-free regression description; preserve all original numerical observations as dated record text, leave production/tests/CI and the book unchanged, regenerate Knowledge Map, run memory/history/diff checks and all normal doctrines.
  Canonical trigger: None; dated documentation qualification only, with no test/runtime/contract or mechanical owner change.
  Claim verification: none: This slice qualifies the lifecycle of an existing dated record; it publishes no new measurement or performance estimate.
  Commit: `REPO-HYGIENE.12 - qualify historical Phase0 measurements` (Git owns identity).
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.12`.

- ID: `REPO-HYGIENE.13`
  Status: `done`
  Goal: Review the due artifact population without deleting retained proof data or reusable caches.
  Verification tier: `focused`
  Focused checks: Read-only same-volume parent metadata census and three explicit Rust release/incremental/deps log-bin locations; exclude submodules, nested repositories, symlinks, foreign volumes, managed runs and caches before traversal. Independently verify each observed path/type/size, test aggregate and balanced-size corruption plus traversal boundary fixtures, and retain actual commands/exits/full channels with source guards. Preserve original claim hashes at exact activation; review unchanged public retention guidance; run memory/Knowledge/history/claim/diff and normal doctrines.
  Canonical trigger: None; dated retention review with no storage/runtime/contract/gate mechanism change.
  Claim verification: `docs/claims/REPO-HYGIENE.13.json`
  Acceptance: Publish exact dated metadata and effective independent controls before overwriting the latest-only date. Delete only a proved exact disposable target; otherwise zero deletion. Never traverse another repository or run recovery/purge. Commit before resuming SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1.
  Commit: `REPO-HYGIENE.13 - retain due artifact review` (Git owns identity).
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.13`.

- ID: `REPO-HYGIENE.14`
  Status: `done`
  Goal: Review the due artifact population while retaining proof data and reusable caches.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent census and three explicit Rust release/incremental/deps log-bin locations; exclude submodules/nested repositories/symlinks/other volumes/managed runs/caches before traversal. Fresh census plus independent per-file OS lstat, aggregate/balanced-size controls and traversal fixtures; actual guarded producer/exits/full-channel review and evidence controls; preserve original claim bindings; review unchanged public retention guidance; memory/Knowledge/history/claims/diff and normal hooks.
  Canonical trigger: none; dated retention review changes no storage/runtime/contract/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.14.json`
  Acceptance: Retain dated exact rows and independent controls before overwriting the latest date. Delete only an exactly proved disposable target; otherwise zero removal. Recovery/purge remains prohibited under SESSION-STARTUP-READING.7. Commit before activating actual producer/input authority SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.
  Commit: `REPO-HYGIENE.14 - retain due artifact review` (Git owns identity).
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.14`.

- ID: `REPO-HYGIENE.15`
  Status: `done`
  Goal: Retain a fresh exact parent/Rust artifact metadata snapshot without removing proof data or caches.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent census and separate Rust release/incremental/deps log-bin metadata; exclude submodules/nested repositories, symlinks, other volumes, managed runs, reusable caches and every prior hygiene fixture before traversal. Fresh scoped census/independent per-file OS lstat, aggregate/balanced-size and traversal fixtures, guarded actual commands/exits/full channels and four reason-sensitive evidence controls; exact old claim preservation if applicable; review unchanged public retention guidance; Knowledge/memory/history/claim/diff and normal hooks.
  Canonical trigger: none; dated retention evidence changes no storage/runtime/public/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.15.json`
  Acceptance: Retain exact dated rows/channels before overwriting the latest date. Remove only an exactly proved disposable target, otherwise zero removal. SESSION-STARTUP-READING.7 continues to prohibit recovery/purge. Capture/freezer and --capture publication are one-shot writers; final reviewer/publisher defaults readonly. Bind actual measurement/producer inputs without gratuitous mutable continuity bindings. Commit before returning to assignment required PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2; generalized-return306-input proof remains live if no bound input changes.
  Commit: `REPO-HYGIENE.15 - retain due artifact review and repair commit pointers`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.15`.

- ID: `REPO-HYGIENE.16`
  Status: `done`
  Goal: Retain a fresh exact parent/Rust artifact metadata snapshot; remove only exactly proved disposable files and preserve proof data/caches.
  Verification tier: `focused`
  Focused checks: Non-following same-volume parent census plus separate Rust release/incremental/deps log-bin metadata. Exclude every submodule/nested repository, symlink, other volume, managed run/cache, book/Dart output and prior hygiene fixture before traversal. Retain actual guarded commands/exits/full channels, fresh scoped census/independent per-file lstat, aggregate/balanced-size/traversal fixtures and four reason-sensitive channel controls; original intersecting claim preservation if any; unchanged public retention teaching review; Knowledge/history/memory/claim/diff and normal doctrines.
  Canonical trigger: none; dated retention evidence changes no storage/runtime/public/toolchain/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.16.json`
  Acceptance: Keep original snapshots immutable; advance latest date only after actual census/review completes. Zero removals is valid if no exact disposable target is proved. SESSION-STARTUP-READING.7 prohibits recovery/purge. Capture/freezer/--capture publication are one-shot writers; default final reviewer/publication are readonly. Existing book retention guidance remains accurate; no new public behavior or book prose is needed for this metadata review. Commit before readonly accepted-claim census repair .3.2.1.10, then container-cache .9. The .2 publication byte bindings stay unchanged here; .10 owns the current-namespace/fixed-baseline review defect exposed by a new unrelated claim.
  Commit: `REPO-HYGIENE.16 - retain due artifact metadata review`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.16`.

- ID: `REPO-HYGIENE.17`
  Status: `done`
  Goal: Retain a fresh exact parent/Rust artifact metadata snapshot; delete only exactly proved disposable files and preserve evidence/caches.
  Verification tier: `focused`
  Focused checks: Fixed accepted Git claim namespace and original-input census before bound writes; actual current456/full108786 readonly baseline; non-following same-volume parent census and separate Rust release/incremental/deps log-bin metadata; fresh comparison and independent per-file lstat; aggregate/balanced-size/traversal fixtures; full guarded commands/exits/channels and four reason-sensitive evidence RED controls. Review unchanged book retention teaching; Knowledge/memory/history/claim/diff and all normal doctrines. Recheck current callback publication after adding this unrelated claim.
  Canonical trigger: none for dated retained metadata; no public, runtime, storage/toolchain/gate mechanism changes.
  Claim verification: `docs/claims/REPO-HYGIENE.17.json`
  Acceptance: Preserve all original dated snapshots. Update the latest-only cleanup date only after actual census and live reviewer complete. Zero removals is valid when no exact disposable target is proved. SESSION-STARTUP-READING.7 prohibits recovery/purge; no liveness or deletion work is authorized by this review. Capture/freezer and --capture publication are one-shot; final reviewers/publication default readonly. No new structural fact or public behavior is introduced; existing Knowledge/book teaching stays accurate. Commit before resuming attached parser .5.1.1. No independent helper/private/parent/canonical admission.
  Commit: `REPO-HYGIENE.17 - retain due artifact metadata review`; derive accepted hash from Git.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.17`.

- ID: `REPO-HYGIENE.18`
  Status: `done`
  Goal: Retain current parent/Rust artifact metadata and verify the existing retention boundary; delete only exactly proved disposable files.
  Verification tier: `focused`
  Focused checks: Fixed accepted claim namespace/all original bindings and actual readonly baseline before shared writes; non-following same-volume parent census plus separate Rust release/incremental/deps log-bin metadata; fresh comparison, independent lstat, size/traversal fixtures and four full-channel evidence controls. Verify historical publication/projection, exact Knowledge header-only overlays/full population, current book source/includes/rendered route, both chronology checks, memory/claim/diff and all normal doctrines.
  Canonical trigger: none; a dated retention observation and current proof routes change no public/runtime/storage/toolchain/gate mechanism.
  Claim verification: `docs/claims/REPO-HYGIENE.18.json`
  Acceptance: Keep all dated evidence/caches; update the latest date only after actual census and live review. Zero removals is valid without an exactly proved disposable target. No liveness/recovery/purge or new callback/private/parent admission. Retire one-shot capture writers and provide a readonly current review. The retained mode-reader correction adds one complete dated engineering record; no other engineering chronology changes. Commit before if/while .5.2; no dirty pivot.
  Commit: `REPO-HYGIENE.18 - retain due artifact review and input custody`; Git owns accepted identity.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.18`.

- ID: `REPO-HYGIENE.19`
  Status: `done` / focused-signoff-complete
  Goal: Retain current parent/Rust artifact metadata and complete public compiler-summary evidence from the warranted canonical run; preserve all evidence/caches and update the latest review date.
  Verification tier: `focused`
  Focused checks: Preserve whole550-input/128458-byte accepted capacity publication and actual readonly baseline against the fixed accepted claim namespace before shared writes. Actual non-following same-volume parent and separate Rust release/incremental/deps metadata, fresh census, independent lstat, size/traversal fixtures and full-channel controls. Retain the complete successful canonical log, original staged receipt and partial/final observation records; independently verify per-line compiler-summary identity/phase/count with effective omissions, swapped crate/count, forged receipt/log and exact restorations. Complete original/current Knowledge and header/body custody, book/includes/rendered current route, both histories, memory/claim/whitespace and all normal doctrines.
  Canonical trigger: none — this dated retention/public-output observation changes no public/runtime/storage/toolchain/gate mechanism. The accepted .5.8 canonical receipt is retained as observed evidence; this leaf grants no new canonical/private/parent admission.
  Claim verification: `docs/claims/REPO-HYGIENE.19.json`
  Acceptance: Keep every dated proof and reusable cache; zero removals is valid without a proven disposable target. No liveness/recovery/purge or concurrent adversarial guarantee. Preserve separate partial/final log observations and old1870/26 baseline as dated evidence. New7093 compiler-reported PGEN summaries are output observations, not distinct bugs, comparable configurations or an internal cause. Existing RUST-DEPENDENCY-WARNING-ZERO.1 owns the fuller public census and .2 owns upstream reporting/evaluation behind active residual repair; no dependency implementation inspection or source-changing cargo suggestion. Record/schedule this finding durably here without closing that program. Commit before .7; no dirty pivot.
  Commit: `REPO-HYGIENE.19 - retain artifact and compiler-summary evidence`; Git owns accepted identity.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.19`.

- ID: `REPO-HYGIENE.20`
  Status: `done` / focused proof; normal landing required
  Goal: Inspect dated parent/Rust artifact metadata and retained toolchain conventions; preserve evidence/caches unless an exact disposable target is proved safe; refresh the latest-only record.
  Verification tier: `focused`
  Focused checks: Whole accepted10 custody and actual readonly baseline before tracked writes; non-following parent and explicit Rust log/bin census, fresh comparison and independent per-file lstat; retained Dart/Julia/Lua conventions; actual metadata/channel falsifiers and restoration; current source/claim binding, complete affected book render with effective marker control, core scalar numeric consumer, Knowledge, both bounded histories, memory/whitespace and all normal doctrines.
  Canonical trigger: none — ordinary dated maintenance; the accepted10 canonical receipt is retained, with no new public/runtime/infrastructure admission.
  Claim verification: `docs/claims/REPO-HYGIENE.20.json`
  Commit subject: `REPO-HYGIENE.20 - review retained project artifacts`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.20`.

- ID: `REPO-HYGIENE.21`
  Status: `done` / focused proof; normal landing required
  Goal: Perform the dated non-following parent/Rust artifact review; retain proof and caches unless an exact target is proved disposable; refresh the latest-only record.
  Verification tier: `focused`
  Focused checks: Whole accepted12/source custody and live-claim intersection census; two non-following metadata censuses, independent per-file lstat, six Rust locations and toolchain conventions; effective metadata/custody/input controls; complete supplied book render and missing-marker control; unchanged core scalar consumer; Knowledge/history/memory/whitespace and all normal doctrines.
  Canonical trigger: none — ordinary dated maintenance, preserving the accepted12 receipt without new runtime/public contract/infrastructure admission.
  Claim verification: `docs/claims/REPO-HYGIENE.21.json`
  Commit subject: `REPO-HYGIENE.21 - review retained project artifacts`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.21`.

- ID: `REPO-HYGIENE.22`
  Status: `done`
  Goal: Perform the next due same-volume artifact review after API planning1, then resume Rust signed-selector17.3.
  Verification tier: `focused`
  Focused checks: Non-following parent/six-location Rust census, repeated actual channels and independent per-file/population metadata; traversal and corrupted-record RED controls; retained producer/input identities; book rendering and focused Perl syntax; history, memory, whitespace and all normal doctrine hooks.
  Canonical trigger: none: Dated maintenance and retention only; no runtime, public contract, dependency, storage policy or gate change.
  Claim verification: `docs/claims/REPO-HYGIENE.22.json`
  Acceptance: Read existing hygiene/knowledge authorities; guard every other Git repository/submodule, symlink, volume and active process boundary. Review parent artifacts and documented Rust/Dart/Julia/Lua locations. Delete only exact proved-disposable project-owned targets, preserving every proof, required log and useful cache otherwise. Capture actual disposition and independent controls before claims; overwrite the latest-only cleanup record after completion. Update book/live pointers and commit before Rust17.3. No recovery/purge or global-cache deletion is authorized by this queue entry.
  Commit: `REPO-HYGIENE.22 - review retained artifacts with independent population checks`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.29`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree REPO-HYGIENE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.29 --id REPO-HYGIENE.22`.

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
