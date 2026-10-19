---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "why did historical Knowledge reverify routes disappear from the derived map"
  - "which task rejects orphan list entries after a scalar reverify field"
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
date: 2026-10-12
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
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/publish.py. Prior inputs:54bb5eb65."
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

The subsequent .3.2.1.9 guard repair preserves the complete .10 publication and
all422 original live bindings historically atde02b83a1, after an actual readonly
baseline passes. Its original namespace and observations remain unchanged. Current
verification routes move together when runtime/book inputs change; the historical
reader must receive its accepted logical inputs.


Mutation/write predicate boundaries now follow the current .3.2.1.6 readonly
publication route above. Native280 loaded/16 cold rows, exact unchanged-source
recurrence and the identical516/156/360 RED/GREEN proof retain single-FETCH
selection, the writable helper-local target slot, boolean1/0, actual CODE
identity and real guard/assignment consumers. Five original ingress sites remain
under .7-.8; complete helper and independent admissions remain open.


Formal trim .3.2.1.7 now binds the one brace and three dot invocation expressions.
Complete230 loaded/68 cold native rows repeat byte-exactly before assertions;
only20 actual-CODE authority and32 symbolic authority rows change afterward.
The identical507 checks retain144 original authority REDs/363 controls/all GREEN;
fourteen source faults and all75 supplied suites/243 inputs/17188 assertions
distinguish selection, local and substring aliases, call context and parsing.
Named/blessed/amp-callable dispatch and already-bound nesting retain native
behavior. One original named-helper dispatch ingress remains under .8; no
complete helper/private/parent/canonical or other-backend admission is claimed.


Historical header routes retained at accepted22132b2b:
- Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults.
- Historical .3.2.1.10 readonly commands require accepted de02b83a1 logical inputs/full original claim. Its original422 bindings/full97759-byte publication and actual baseline are preserved before .9 changes. Earlier .2 and trim commands retain their recorded accepted input boundaries; never run retired capture/freezer/fault writers as resume commands.
- Historical .3.2.1.3 readonly commands require accepted dd82f9cb logical inputs/full original claim. Original531 bindings/full125217-byte publication and actual baseline are preserved before .4 changes; original runtime/native/diagnostic producers and observations remain unchanged.
- Historical .3.2.1.4 readonly commands require accepted15197dfd logical inputs/full original claim. Original498 bindings/full114980 publication and actual baseline remain exact before .5; original producers/observations are unchanged.
- Historical .3.2.1.5 readonly commands require accepted99f2939ac logical inputs/full original claim. Original517 bindings/full119899 publication and actual baseline remain exact before .6; original producers/observations are unchanged.
- Historical .3.2.1.6 readonly commands require accepted b1133da42 logical inputs/full original claim. Original519 bindings/full119936 publication and actual baseline remain exact before .7; original producers/observations are unchanged.

Selected named-helper dispatch .3.2.1.8 binds only invocation694. Exact244-input
recurrence retains185 loaded/28 cold rows; only54 authority rows change afterward.
The identical487 checks retain132 original authority REDs/355 controls/all GREEN.
Twelve source faults and all76 supplied suites/246 inputs/17675 assertions pass.
Six literal helper references are selected before iteration. Mid-call name
replacement affects the next owner call; trimmed/deps helper-local scalar slots
remain writable and separate from caller slots. Mutating map contents remains
shared, while replacing the local deps scalar reaches later callbacks/fallback
without replacing the caller reference. Zero stays nonempty; native context,
reference/coercion/error/fatal/guard/fallback/cold behavior remains exact.
All17 sites from the original inventory now have their bounded repairs; full
named helper, FlowExpr/ControlFlow, private/parent/canonical admissions remain open.

The bounded six-card header census retains four orphan list entries after scalar
reverify fields in two cards. The portable generator clears its list key after
a scalar and ignores those entries. Current headers now use one scalar readonly
route; every original route is archived explicitly above. The original malformed
header RED and corrected review are retained under .3.2.1.8-headers*. No original
fact body is rewritten. Canonical gate hardening is owned by .3.2.1.11 immediately
after .8; this bounded repair does not admit the full Knowledge grammar/gate.

Historical .8 header route retained at accepted328b11c5ed1d5ffbc870f6785448e3a8249fe882:

reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-publish-claim.py; review.py, native-review.py, book-review.py, headers-review.py and evidence.py under the same wrapper/prefix have readonly defaults. Historical routes below require their accepted Git inputs; capture writers are retired."

Knowledge header list association is enforced by knowledge-map/scripts/check_knowledge_map.sh. Only an empty-value key owns following block-list items; scalar and inline values close that association. Orphan lines reject even when the generated map is synchronized. Malformed scalar answers plus detached items remain visible to validation. The public t/knowledge_map_header_lists.t fixture covers the original affected headers, valid forms and precise denial reasons; canonical CI runs it. The generator remains a metadata projection, and this repair does not admit a complete YAML grammar or field-type validator. The prior .8 runtime publication and original fact bodies remain recoverable at328b11c5.

Valid block-evidence and block-reverify inputs are accepted by the original checker but omitted from generated metadata. Two exact public generator reproductions and their original acceptance channels are retained in docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-metadata-lists.json. P3 .3.2.1.12 owns the field/projection contract and current affected-population census after the factory/pipeline activity, before TYPE-REFERENCE-BOOK. No full population count or remedy is inferred from these two named cases.


# First uncommitted Knowledge gate candidate

The complete first 136-input/35,512-byte publication and this original header are retained in the supplied-byte capsule. It is not an accepted Git revision. The current readonly publication verifies its isolated replay; original observations are unchanged.

---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "why did historical Knowledge reverify routes disappear from the derived map"
  - "which task rejects orphan list entries after a scalar reverify field"
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
date: 2026-10-12
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
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-publish-claim.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


The Knowledge gate fixture is a managed Perl temporary allocator. Its CI registration is admitted by an exact anchored inverse in tests/language-readiness/verify_objectives.py, and tools/test_perl_project_data_storage.sh registers 29 allocators including t/knowledge_map_header_lists.t. The inverse recovers the complete historical source, and omission, duplication, changed commands or unrelated source edits remain rejected. Original canonical and storage failures, two original-source REDs, twelve registration denials, complete isolated historical recovery and managed-storage GREEN are retained under the current publication. These are registration compatibility checks; historical runtime observations are not refreshed.


# Second uncommitted Knowledge gate candidate

The complete second337-input/full79329 publication and every input byte are frozen before this header route changes. Its actual supplied-byte replay and two corruption controls remain separate from the current documentation repair. This is not an accepted Git revision. The original header follows verbatim.

---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "why did historical Knowledge reverify routes disappear from the derived map"
  - "which task rejects orphan list entries after a scalar reverify field"
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
date: 2026-10-12
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
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Third uncommitted Knowledge gate candidate

The whole177-input/full44317 publication retains its original logical inputs through unchanged files and ten complete supplied byte overlays. Only the two failure reports change diagnostic representation; decoded bytes are exact. The original header follows verbatim.

---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "why did historical Knowledge reverify routes disappear from the derived map"
  - "which task rejects orphan list entries after a scalar reverify field"
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
date: 2026-10-12
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
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Fourth uncommitted Knowledge gate candidate

The whole198-input/full51535 publication and eight complete original route/card/map overlays preserve its original logical inputs. The current claim binds the published RGX README through an exact parent-owned snapshot; the submodule and pin are unchanged. The original header follows verbatim.

---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "why did historical Knowledge reverify routes disappear from the derived map"
  - "which task rejects orphan list entries after a scalar reverify field"
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
date: 2026-10-12
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
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


Historical header archive: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/knowledge-headers.md` (repo-generated-artifact-cleanup-boundary). The complete original fact body and runtime observations are retained; the first uncommitted FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.
