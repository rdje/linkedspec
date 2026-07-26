# REPO-ROOT-PATH-PORTABILITY: checkout relocation must be harmless

## Metadata

- Tree ID: `REPO-ROOT-PATH-PORTABILITY`
- Status: `active`
- Roadmap lane: `Repository architecture / checkout relocation invariance`
- Created: `2026-07-25`
- Last updated: `2026-07-25` (audit `.0` complete; Rust runtime repair `.1.1` is next)
- Owner: repo-local workflow

## Goal

Guarantee that moving or renaming the repository root cannot break source, tooling, tests, fixtures, documentation,
generated artifacts, or durable continuity. Every checked-in reference to repository-owned content must be
repo-root-relative, or be joined to a repository root discovered dynamically from the executing script/module.
No tracked value may bake in a developer home, volume, mount point, or concrete checkout directory.

External operating-system paths that are not repository content (for example an interpreter selected through
`/usr/bin/env`, a device, or a caller-owned temporary directory) are a separate portability concern. They may not
be confused with or used to reconstruct a checkout-specific project path. Dynamically resolved absolute paths are
allowed only as ephemeral runtime values derived from the current checkout, never as persisted project identity.

## Director Directive

On 2026-07-25 the director marked this invariant critical: all project paths shall be relative to the repository
root because the root may move for many reasons and relocation must not affect the project in any way.

## Task Tree

- ID: `REPO-ROOT-PATH-PORTABILITY`
  Status: `active`
  Goal: Make repository relocation an explicit, mechanically enforced architecture invariant.
  Children: `.0`, `.1`, `.2`

- ID: `REPO-ROOT-PATH-PORTABILITY.0`
  Status: `done`
  Goal: Audit and freeze the exact repository-path portability contract before remediation.
  Acceptance: Start from clean commit `99a3df5b`. Retrieve existing Knowledge Map, decision, bootstrap, commit,
    tooling, and gate authorities before re-deriving. Inventory every tracked checkout-specific absolute path and
    every code/config path that assumes the caller's current directory rather than resolving the repository root.
    Classify repository-content references separately from legitimate external OS/tool/temp paths and dated
    historical evidence. Define false-positive-safe checker boundaries, a relocation proof, exact repair owners,
    and `.1`/`.2` dependency order. Add no path repair or checker behavior in this leaf. Synchronize roadmap,
    mdBook, Knowledge Map, memory/live/task docs, run focused audits plus canonical gates, commit, clear the brief,
    verify clean, and do not push before cadence 300.
  Commit: `REPO-ROOT-PATH-PORTABILITY.0 - freeze relocation invariant`

  #### Acceptance Checklist

  - [x] **CLEAN / RETRIEVAL-FIRST BASE** — Began from clean `99a3df5b`; consulted Knowledge Map/Toolbox/decisions
    before source archaeology and recorded the new durable structural fact.
  - [x] **EXACT TRACKED INVENTORY** — Enumerated checkout-specific literals and cwd-coupled repository references
    across code, scripts, configs, tests, fixtures, generated artifacts, docs, and continuity layers.
  - [x] **PRECISE PORTABILITY CONTRACT** — Distinguished repo-owned paths from legitimate external paths and allowed
    only root-relative persisted references or runtime paths derived dynamically from the current repo root.
  - [x] **DEPENDENCY-COMPLETE SPLIT** — Froze exact remediation `.1`, mechanical enforcement/relocation proof
    `.2`, checker registration, false-positive fixtures, documentation, and gate requirements before behavior.
  - [x] **NO BEHAVIOR CHANGE / DURABLE COMMIT** — Changed no production/tool/checker behavior; audit, book,
    Knowledge Map, memory/task/four doctrines, canonical CI, cleanup, and diff; commit cleanly without pushing.

- ID: `REPO-ROOT-PATH-PORTABILITY.1`
  Status: `active`
  Goal: Replace every admitted checkout-specific or machine-coupled project path with portable resolution.
  Depends on: `.0`
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `REPO-ROOT-PATH-PORTABILITY.1.1`
  Status: `active`
  Goal: Remove the Rust primary CLI's compile-time checkout identity.
  Depends on: `.0`
  Acceptance: Replace `env!("CARGO_MANIFEST_DIR")` repository discovery in the shipped Rust primary command
    with deterministic upward discovery from the real cwd and current executable, using the checked-in bundled-
    spec marker and a defined no-marker fallback. Preserve explicit `run_with_context` behavior and native spec-
    resolution precedence. Add focused unit proof for cwd, executable, precedence, and fallback anchors; prove the
    previously failing copied-binary reproduction turns green; update docs/KM/live state; run focused and canonical
    gates; commit, clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.1.1 - derive Rust checkout at runtime`

- ID: `REPO-ROOT-PATH-PORTABILITY.1.2`
  Status: `pending`
  Goal: Remove live developer-home and private-mount values from tracked legacy code/configuration.
  Depends on: `.1.1`
  Acceptance: Repair only the audited live/config owners: `conf/fv_check.conf`, `conf/lighttpd.conf`,
    `conf/network.conf`, `conf/pcsally_mem.conf`, `conf/tkgui.tk`, `noncore/EasyTk.pm`,
    `noncore/plugin/network.plg`, and `perl/env.conf`. Prefer repo-relative config paths, PATH-selected tools,
    explicit caller configuration, and existing config fields; do not reinterpret neutral absolute-path contract
    fixtures, temporary paths, URLs, or stable OS/tool paths. Run syntax/corpus/noncore-focused proof plus canonical
    gates; update docs/KM/live state; commit, clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.1.2 - remove machine-bound legacy paths`

- ID: `REPO-ROOT-PATH-PORTABILITY.1.3`
  Status: `pending`
  Goal: Make durable Knowledge Map verification commands machine-independent.
  Depends on: `.1.2`
  Acceptance: Normalize the 12 audited Julia fact-card commands so they select `julia` through `PATH`, use
    repo-relative `--project=julia`/test paths, and compose caller-writable depot storage without a developer home
    or private macOS session directory. Regenerate, never hand-edit, `KNOWLEDGE_MAP.md`; pass every affected
    reverify command or the strongest exact grouped equivalent, plus Knowledge Map/book/canonical gates; commit,
    clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.1.3 - normalize durable reverify paths`

- ID: `REPO-ROOT-PATH-PORTABILITY.2`
  Status: `pending`
  Goal: Mechanically prevent checkout-specific repository paths from returning.
  Depends on: `.1.3`
  Children: `.2.1`, `.2.2`

- ID: `REPO-ROOT-PATH-PORTABILITY.2.1`
  Status: `pending`
  Goal: Add the fast structural repository-path portability doctrine.
  Depends on: `.1.3`
  Acceptance: Add one deterministic, read-only `scripts/check_repo_root_path_portability.sh` which derives its own
    root, scans tracked parent-repository text (not the `rgx` gitlink or ignored/generated caches), rejects current
    or former concrete checkout identities, developer homes/private session roots, and compile-time Rust primary-
    CLI root discovery, and locks all five primary-command dynamic anchors. Its self-test must prove rejection of
    current-root, Unix-home, macOS-volume/private-session, Windows-home/checkout, and compile-time-root mutations
    while accepting repo-relative content, URLs, `/usr`/`/opt` tools, caller `/tmp` paths, and neutral absolute-path
    contract fixtures. Register exactly one row in `scripts/check_doctrines.sh` and `DOCTRINE_ENFORCEMENT.md`; the
    existing registry calls already supply E3/E4. Pass focused self-tests/four doctrines and canonical gates;
    commit, clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.2.1 - gate repository path portability`

- ID: `REPO-ROOT-PATH-PORTABILITY.2.2`
  Status: `pending`
  Goal: Close the invariant with a recurring relocated-checkout process oracle.
  Depends on: `.2.1`
  Acceptance: Add one Rust integration test that copies the freshly built primary executable beneath a synthetic
    moved repository, supplies only that tree's unique named spec plus root marker, launches from outside it, and
    requires exact successful output. Lock the four already-correct Perl/Dart/Julia/Lua entrypoint anchors in the
    structural checker and repeat their outside-cwd primary smoke proof. Synchronize README/roadmaps/book/KM/live
    state, close the task tree, pass the complete canonical gate, remove only explicit task scratch, commit, clear
    the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.2.2 - prove relocated checkout execution`

## Current Frontier

| Leaf | Status | Next action |
| --- | --- | --- |
| `REPO-ROOT-PATH-PORTABILITY.1.1` | `active` | From the clean `.0` commit, replace only Rust compile-time checkout discovery and prove the copied-binary RED becomes green. |

## Decisions

- Repository relocation is a correctness property, not an installation convenience.
- Persisted references to repository content are repo-root-relative.
- Runtime code discovers the current root from its own stable location or an explicit caller root, never from a
  baked-in checkout path; reliance on an arbitrary caller cwd must be classified and repaired.
- A dynamically derived absolute runtime path is an implementation detail, not durable project identity.
- The audit must not misclassify unrelated external OS/tool/temp paths as repository-path violations.
- ADR `0052` is the durable contract. Caller-supplied exact paths stay legal data; they never become an implicit
  project root or durable checkout identity.
- `rgx` is a gitlink with its own repository and task/commit boundary. The parent checker verifies only the tracked
  parent tree; changing the submodule requires a separately owned submodule task and commit.

## Audit Freeze (`.0`)

### Retrieval and tracked-tree inventory

- Existing authorities retrieved before source inspection: `COMMIT.md:114`, ADR `0026`, the native-resolution and
  CLI Knowledge Map cards, `TOOLBOX.md` path diagnostics, all bootstrap/root scripts, and the existing Phase-0
  Markdown leak test. ADR `0026` governs caller file requests; it does not govern checkout discovery.
- Exact tracked scans find **zero** occurrences of the current SSD checkout, the former `Documents/github`
  checkout shape, or another concrete `linkedspec` checkout identity; **zero** tracked symlinks; and no parent-
  repository content path stored as a file URI. Repository URLs and the mdBook `git-repository-url` are URLs, not
  filesystem paths.
- Of 27 tracked shell/hook files, 25 derive the checkout from `BASH_SOURCE`, their own file, or
  `git rev-parse`. `.githooks/commit-msg` needs no repo content; `tools/ram_guard.sh` is a generic command wrapper.
  Neither is cwd-coupled repository access.
- Perl (`FindBin`), Dart (`Directory.current` plus `Platform.script` ascent), Julia (`@__DIR__`), and Lua
  (`debug.getinfo` script/module paths) resolve shipped content from their current files. Exact named-Lispish
  process probes launched from `/private/tmp` returned `["hello",["world"]]` on all four; Julia required only a
  writable layered depot, which is tool cache configuration rather than checkout identity.
- Rust is the one shipped-runtime defect. `rust/linkedspec-runtime/src/primary_cli.rs` derives `repo_root` from
  `env!("CARGO_MANIFEST_DIR")`, so the compiler's checkout survives in the binary. A copied current binary under
  a synthetic moved tree, with a unique adjacent named spec and cwd outside both checkouts, exited 1 with
  `linkedspec: parser compilation failed`; it searched the original build checkout. Other production Rust source
  has no such root lookup: the second `CARGO_MANIFEST_DIR` under `rust/*/src` is test-only compiler code, while
  integration-test occurrences legitimately address test fixtures.
- Sixteen source files contain 42 developer-home/private-session command or configuration lines: 12 Julia
  Knowledge Map fact cards plus `conf/lighttpd.conf`, `conf/tkgui.tk`, `noncore/EasyTk.pm`, and `perl/env.conf`.
  `KNOWLEDGE_MAP.md` repeats these mechanically and is not a separate repair owner. Four legacy config/plugin files
  contain six `/vobs/` mount references, and `conf/pcsally_mem.conf` contains one `/dsync/` private-workspace path.
  The eight live/config owners go to `.1.2`; the 12 fact cards go to `.1.3`.
- Absolute paths that are explicit contract data (`C:/Demo`, path-leak denial needles), caller-owned temporary
  paths, or external OS/tool resources (`/usr`, `/opt`, `/tmp`) do not identify repository content and remain
  legal. Ignored Dart/Julia/Rust/Lua caches may contain tool-generated absolute metadata; they are regenerated after
  relocation and cannot be treated as durable project identity. Binary string scans are not a proof because debug
  information legitimately records build sources; the `.2.2` process oracle tests behavior instead.

### Frozen dependency order

1. `.1.1`: repair only the confirmed shipped Rust runtime defect and prove root-anchor semantics.
2. `.1.2`: remove the exact legacy developer-home/private-mount values, preserving external-input configuration.
3. `.1.3`: normalize the exact Julia fact-card commands and regenerate the derived map.
4. `.2.1`: install the fast structural doctrine with mutation-sensitive self-tests and one registry row.
5. `.2.2`: add the copied-binary relocation oracle, repeat the four correct process anchors, close docs/tree.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| 2026-07-25 | `.0` | tracked current/former checkout grep; tracked mode/symlink census; 27-file shell/hook root audit | 0 checkout literals; 0 symlinks; 25 self-rooted + 2 root-independent |
| 2026-07-25 | `.0` | Perl/Dart/Julia/Lua named-Lispish command from `/private/tmp` | exact `["hello",["world"]]`, exit 0 on all four |
| 2026-07-25 | `.0` | copied Rust binary + unique synthetic moved-root spec, invoked from outside | RED reproduced: exit 1, `parser compilation failed`; compile-time original root confirmed |
| 2026-07-25 | `.0` | tracked host/private-mount source census excluding derived map and `rgx` gitlink | 42 home/private-session lines in 16 files; 6 `/vobs/` in 4; 1 `/dsync/` in 1 |
| 2026-07-25 | `.0` | mdBook; Knowledge Map; memory architecture; doctrine driver | PASS; KM 706 facts / 5,502 questions; all four doctrines PASS |
| 2026-07-25 | `.0` | canonical `env PERL5LIB= bash tools/run_ci_local.sh` | PASS; Rust semantic 1/1 in 80.16s, Dart 1/1, Julia 416/416 in 28.3s, Perl primary 66x2, Phase 0 1,031/1,031 in 653s |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `REPO-ROOT-PATH-PORTABILITY.0 - freeze relocation invariant` (this commit) | Behavior-free ADR/audit/split; no repair or checker behavior. |

## Changelog

- `2026-07-25`: Created the critical relocation-invariance tree after clean semantic commit `99a3df5b`; audit
  `.0` precedes any remediation or doctrine change.
- `2026-07-25`: Completed `.0`; ADR `0052`, exact inventories, three repair leaves, structural doctrine, and
  recurring relocation oracle are frozen. `.1.1` is active from the clean audit commit.
