# REPO-HYGIENE: Repository hygiene — .gitignore and untrack artifacts

## Metadata

- Tree ID: `REPO-HYGIENE`
- Status: `completed`
- Roadmap lane: `Overall roadmap — repository maintenance`
- Created: `2026-06-16`
- Last updated: `2026-07-17` (`REPO-HYGIENE.5` done: urgent recurring generated-artifact cleanup reclaimed 16G)
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
  Children: `REPO-HYGIENE.1`, `REPO-HYGIENE.2`, `REPO-HYGIENE.3`, `REPO-HYGIENE.4`, `REPO-HYGIENE.5`

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

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `REPO-HYGIENE.3` | `done` | User-requested urgent cleanup of safe generated artifacts, including Rust target directories and mdBook output |
| 2 | `REPO-HYGIENE.4` | `done` | Reclaimed about 20G from Rust/mdBook output, Julia compiled caches, and proven stale generation logs without deleting depot or unrelated temp content |
| 3 | `REPO-HYGIENE.5` | `done` | Reclaimed 16G from measured rebuildable caches and 15 provenance-checked stale generation logs. |

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
| `2026-07-17` | `REPO-HYGIENE.5` | Existing cleanup fact retrieval; `df -h`; exact `du`; ignored/tracked checks; main-checkout log/bin/temp scan; exact log header/process/`lsof` proof; removal of Rust/Dart build output, two Julia compiled caches, and 15 exact stale logs; post-absence/depot/unrelated-tree/status checks; memory/KM/task/doctrine/diff gates | PASS — immediate deletion baseline 55G/89% became 71G/85%, reclaiming 16G. Dedicated depot registries/logs, unrelated 18G `claude-501`, unknown temp trees, `rgx` fixtures, and all tracked content remain. The earlier 29G/94% session observation is retained separately because external cleanup occurred before deletion. |
| `2026-07-06` | `REPO-HYGIENE.2` | `.gitignore` update; `.gitmodules` `ignore = dirty`; `git status --ignored`; `git ls-files --stage rgx`; `git submodule status -- rgx`; memory/doctrine/Knowledge Map/diff checks | `.claude/projects/` is ignored; `rgx` remains a tracked submodule/gitlink at `8763a0e`; dirty submodule worktree state no longer dirties parent status. |
| `2026-07-07` | `REPO-HYGIENE.3` | `du -sh rust/target docs/linkedspec-book/book`; ignored/tracked checks; artifact scans for `.log`, `.bin`, `.tmp`, `.bak`, `.DS_Store`, and `.swp`; `rm -rf rust/target docs/linkedspec-book/book`; post-clean existence/status checks; memory/KM/doctrine/diff gates | PASS — removed ignored/untracked `rust/target` (5.2G) and `docs/linkedspec-book/book` (7.0M). Main checkout has no remaining safe log/bin/temp artifact hits outside `.git`, ignored targets, and `rgx`. Submodule `rgx` log/bin hits were preserved as fixture/stimulus/issue corpus material. Cargo/mdBook were not run because they would recreate the removed artifacts. |
| `2026-07-10` | `REPO-HYGIENE.4` | `df -h .`; `du -sh` over Rust target/mdBook output, Julia depot components, `/private/tmp`, and user temp; ignored/tracked checks; Julia `jl_*` scan; process/`lsof`/header provenance checks; removal of four generated cache targets plus twelve stale LinkedSpec/RGX generation logs; post-clean existence/depot/status checks; memory/KM/task/doctrine/diff gates | PASS — removed 1.7G Rust target, 7.8M mdBook output, 148M dedicated-depot Julia compiled cache, 261M user-depot Julia compiled cache, and about 18G of stale generation logs. Availability increased from 50G/90% to 68G/86%; Julia depot data, `claude-501`, unrelated cargo-mutants trees, and `rgx` corpus artifacts remain. |
| `2026-06-16` | `REPO-HYGIENE.1` | `scripts/check_memory_architecture.sh` exit 0; `perl -c perl/LinkedSpec.pm` OK; git status clean | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `REPO-HYGIENE.5` | `REPO-HYGIENE.5 - clean recurring generated artifacts` | Exact ignored caches and 15 stale generation logs removed; 16G reclaimed; depot and unrelated content preserved. |
| `REPO-HYGIENE.2` | `REPO-HYGIENE.2 - ignore Claude project state and rgx local dirt` | `.claude/projects/` ignore plus `rgx` submodule local-dirt ignore. |
| `REPO-HYGIENE.3` | `REPO-HYGIENE.3 - remove generated artifacts` | Removed ignored/untracked `rust/target` and mdBook build output; left `rgx` corpus artifacts intact. |
| `REPO-HYGIENE.4` | `REPO-HYGIENE.4 - clean Rust and Julia generated caches` | Depot-aware cache and provenance-checked temp-log cleanup; preserved package, registry, and unrelated temp data. |
| `REPO-HYGIENE.1` | `pending` | Populated after commit |

## Changelog

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
