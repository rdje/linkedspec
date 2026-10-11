---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "why can a new maintenance claim break an older readonly review"
  - "which task owns the fixed baseline claim namespace repair"
  - "which commits admitted initial repository artifact ignores and local dirt policy"
  - "why did old hygiene task commit fields still say pending"
  - "which generated artifacts are safe to delete for disk cleanup"
  - "can I delete rust target to recover space"
  - "can I delete docs/linkedspec-book/book"
  - "should cleanup delete rgx log files"
  - "should cleanup delete rgx bin files"
  - "which Julia generated artifacts are safe to delete"
  - "can I delete Julia compiled caches"
  - "can I delete the Julia depot"
  - "where are Julia precompile artifacts stored"
  - "can stale LinkedSpec logs under private tmp be deleted"
  - "should cleanup delete all of private tmp"
  - "why was private tmp using 46 gigabytes"
  - "what did REPO-HYGIENE.3 remove"
  - "what did REPO-HYGIENE.4 remove"
  - "what did REPO-HYGIENE.5 remove"
  - "is Dart dot dart tool safe to delete"
  - "how much space did the July 17 artifact cleanup reclaim"
  - "which live claims must be preserved before changing a shared book chapter"
  - "why was the October10 hygiene claim preserved during ADR0133"
  - "do historical checked claims need a tracked producer input"
date: 2026-10-11
status: accepted
tags: [repo-hygiene, artifacts, cleanup, rust, julia, depot, precompile, mdbook, rgx, task-tree]
evidence: "REPO-HYGIENE.3-.5 established the historical rebuildable-output boundary. PROJECT-DATA-SSD-ROOTING.2.0-.2.6 supersede routine space-recovery behavior: the repository now resides on a 4 TB SSD; supported workflows retain reusable language caches under .linkedspec-data/cache, use runtime-derived same-filesystem scratch, and reject project-owned output on another filesystem. tools/test_tool_project_data_storage.sh proves exact output boundaries without broad temporary-root scans."
evidence_update_2026_10_02: "REPO-HYGIENE.7 corrects the maintained submodule-task permission statement against the newer director boundary. The archived census/review instruments and exact retained enumeration live in docs/checkpoints/REPO-HYGIENE.7-artifact-review.json; no deletion or liveness/purge operation occurred."
evidence_update_2026_10_03: "REPO-HYGIENE.8 retains the dated parent/Rust enumeration and tracked stdout-only census/read-only reviewer. Fresh metadata and per-file lstat controls pass; zero removals. Current metadata is time-dependent: default review checks the retained snapshot, --live records a new observation."
evidence_update_2026_10_04: "REPO-HYGIENE.9 retains the October4 exact parent/Rust rows and actual full census/review channels with producer guards. Fresh scoped metadata and independent lstat agree, two metadata/four channel controls reject, zero removals. Original snapshots remain immutable; caches/proof data remain retained."
evidence_update_2026_10_07: "REPO-HYGIENE.11 retains the October7 exact parent/Rust metadata snapshot and actual full census/review channels with producer guards. Fresh scoped census and independent per-file lstat, metadata/channel/render controls verify the dated observation; zero removals. Previous snapshots remain immutable, and all evidence/caches remain retained."
evidence_update_2026_10_08: "REPO-HYGIENE.13 retains the dated October8 parent/Rust snapshot and complete actual producer channels. Fresh metadata, independent lstat and effective size/traversal/evidence controls pass. All artifacts remain retained; current start-path guards reject symlink ancestors, nested repositories, mock submodules and outside-root starts before traversal. Earlier snapshots are immutable; no concurrent adversarial filesystem guarantee is inferred."
evidence_update_2026_10_09: "REPO-HYGIENE.14 retains the dated October9 parent/Rust metadata snapshot and actual guarded command channels. Fresh per-file OS metadata, size/traversal fixtures and four evidence controls pass. Zero removals; all proof inputs and reusable caches stay retained. No liveness, recovery/purge or concurrent adversarial traversal guarantee is inferred."
evidence_update_2026_10_10: "REPO-HYGIENE.15 retains the October10 dated parent/Rust metadata and guarded actual channels: 13433 parent candidate rows/15594802423 bytes; zero removals. Fresh census, independent per-file lstat, size/traversal fixtures and four reason-sensitive evidence controls pass. Every prior hygiene fixture stays excluded. Dated proof is retained; default review-actual.py/claim.py are readonly. Historical commit placeholders are repaired to original .1 d07ee79ea073823c06711b0cc2cf3516d0f172b6 and .2 cf0df422097d55aaf2379cac8907319107406e6b after targeted Git subject/stat/parent metadata/task-diff audit; no old runtime recurrence or pin change. Original commits introduced those placeholders, and later .1 hash-sync commits were pointer refreshes superseded by ADR0065."
evidence_update_2026_10_11: "REPO-HYGIENE.16 retains the October11 parent/Rust metadata and guarded actual channels:14888 parent candidates/16643190359 bytes; zero removals. Fresh scoped census, independent per-file lstat, aggregate/balanced-size/traversal fixtures and four reason-sensitive actual-channel controls pass. All prior hygiene fixtures stay excluded. The actual predecessor optional-kind readonly publication baseline is retained before introducing the new maintenance claim. The new claim also exposes a source-established current-namespace/fixed-baseline review risk, owned by .3.2.1.10 before cache .9. No product regression is inferred."
reverify: "Current composed recovery: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-publish-claim.py. accepted-review.py, historical.py and book-review.py under that prefix are readonly defaults. Original hygiene16 claim/review requires accepted16c70eaab inputs, including the original live predecessor claim; current recovery retains actual25-input replay/RED/restoration. Original optional-kind publication requires acceptedfc96936fb namespace and33 additional published historical inputs. Capture/preservation/replay/--capture writers are retired; no original observation is refreshed."

---

# Shared publication inputs and historical provenance

Before changing a shared book chapter, enumerate intersections across every live claim; the immediate predecessor is insufficient. ADR0133 changed the documentation-workflow chapter before noticing REPO-HYGIENE.15 also bound it. All19 original hashes and claim fields were subsequently verified against clean d8418423e and preserved with only mode/revision changes. The late timing is disclosed; original dated observations are unchanged.

Every checked durability record, including a historical one, needs a tracked producer input. The actual claim validator rejects the two original producer-free historical entries and accepts exact provenance repairs without refreshing hashes. The original362-input draft, publisher and actual failed CI report remain retained. Logs needed after command exit belong outside automatically cleaned managed scratch, or require explicit failed-run retention.

The original hygiene body below is dated evidence. Its readonly publication commands require its accepted Git input state; current closure and exact preservation review are named above. No recovery, purge or artifact removal is authorized here.

# Repo Generated Artifact Cleanup Boundary

`rust/target` and `docs/linkedspec-book/book` are ignored, untracked, rebuildable generated outputs in the parent
checkout. Dart's ignored/untracked `dart/.dart_tool` is the same class of rebuildable package/build metadata. That
classification permits an explicitly owned cleanup when one is genuinely needed; it is not a standing instruction
to purge caches. The repository now has ample SSD capacity, so normal work retains reusable build and package data.

Julia places compiled/precompile output under the active depot's `compiled/` directory rather than under a Rust-
style project target. Supported LinkedSpec workflows use the ignored repository-relative retained Julia depot.
Its compiled cache is regenerable, but it remains retained by default alongside package sources and registries so
offline operation and fast reruns do not depend on a developer-home cache.

Do not broaden that permission to the whole depot. Preserve `packages/`, `registries/`, `environments/`,
`scratchspaces/`, `artifacts/`, and any source or project manifests unless a separately owned audit proves a
specific target safe. The generated Julia `manifest_usage.toml` is one proven exception: supported wrappers remove
it because it is disposable garbage-collection metadata containing runtime absolute paths.

Supported workflows no longer store LinkedSpec logs or scratch under an operating-system temporary root. A targeted
old-root census is justified only for a named migration or residue proof. If one exact legacy file is found there,
require repository ownership and liveness evidence before deleting that exact path. Never inventory or delete an
entire shared temporary root merely to recover space; it can contain agent state, application IPC, and other projects.

Do not delete or modify anything under `rgx/` or any other Git repository. The September27 director
instruction permits this agent to write LinkedSpec only; a task or notification does not authorize crossing
that boundary. Parent cleanup excludes every submodule and nested repository before traversal. Report
upstream artifact issues through the public integration boundary; its owner applies any repair. The older
submodule-owned-task pruning suggestion is superseded. No dependency implementation classification is
needed to enforce this exclusion.

`REPO-HYGIENE.5` repeated the boundary on 2026-07-17. It removed 2.6G of Rust output, 30M of Dart output, 267M of
dedicated Julia compiled caches, and fifteen exact stale generation logs totaling about 13.6GB decimal. Available
space increased by 16G at the deletion boundary (55G/89% to 71G/85%). The two Julia depots retained noncompiled
content, and the unrelated 18G `claude-501` tree remained untouched.


Current dated retention proof: `bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.15-review-actual.py`,
then separately `REPO-HYGIENE.15-claim.py` under that wrapper. Defaults are readonly; capture/freezer and
`--capture` publication are one-shot writers. Prior snapshots keep their original immutable inputs. Mutable
continuity prose does not produce this metadata measurement and is not included as gratuitous live bindings.

Historical commit attribution uses `git show --format=fuller --stat d07ee79ea073823c06711b0cc2cf3516d0f172b6`
and `git show --format=fuller --stat cf0df422097d55aaf2379cac8907319107406e6b`, then their parent-owned
`.gitignore`, `.gitmodules` and task-tree diffs. The former admits ignore/untracking; the latter admits the local
dirt policy. Neither attribution is a fresh execution of the dated verification commands. The original pending
placeholders are corrected in the task tree; historical behavior/pin observations remain exact.

A new maintenance claim must not change the original claim population reviewed at
an older accepted Git boundary. The optional-kind .3.2.1.2 reviewer currently
lists present docs/claims/*.json but reads those paths with git show at61cca1ccc.
Its sole original-census self exclusion covers its own .2 claim, so a later
unrelated REPO-HYGIENE.16 claim is absent at that fixed boundary. Source location:
docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-review.py:291-295. Actual
Git cat-file confirms that absence; the pre-maintenance readonly publication
baseline is separately retained. This is a source-established proof-routing risk,
not an observed runtime/native product failure. P2 .3.2.1.10 owns the complete
first rejection, fixed-Git population repair and effective unrelated-claim controls
immediately after hygiene16, before container-cache .9. Original retired producers
and native observations remain immutable; the repair needs a new readonly owner.

The first actual post-maintenance refusal confirms the namespace mechanism above.
The corrected reader uses git ls-tree at the same fixed61cca1ccc boundary used
for Git file reads. Actual accepted532-input publication replay passes; adding the
new hygiene claim gives533 inputs and rejects the original reader. The corrected
reader passes; stale namespace, omitted original intersecting claim and added new
claim faults reject, then exact restoration passes. The accepted maintenance
publication has its separate25-input replay, bound-predecessor change RED and
restoration. Every original390 declared binding/full publication remains preserved.

The first preservation parent expected does not exist in, while actual Git says
exists on disk, but not in. Its raw child refusal, exact failed matcher and available
merged parent failure remain retained. A distinct preservation writer uses the
actual saved reason. The first499-file supplied replay omits the predecessor's
consumer seed and fails. That seed is already bound by the published historical339
predecessor inputs; a distinct complete replay adds the33 absent published inputs.
This repairs an incomplete replay instrument, not an original durability leg.
Original observations/hashes/producers remain unchanged. Historical reports keep
their actual capture-producer identity, while executed corrected source has its
own retained hash and command. No runtime product or broader admission is inferred.
