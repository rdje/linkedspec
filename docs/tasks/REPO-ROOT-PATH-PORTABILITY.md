# REPO-ROOT-PATH-PORTABILITY: checkout relocation must be harmless

## Metadata

- Tree ID: `REPO-ROOT-PATH-PORTABILITY`
- Status: `done`
- Roadmap lane: `Repository architecture / checkout relocation invariance`
- Created: `2026-07-25`
- Last updated: `2026-07-27` (tree complete; recurring structural and moved-process enforcement green)
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
  Status: `done` (2026-07-27; remediation plus structural/process enforcement complete)
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
  Status: `done` (2026-07-26; all admitted machine-coupled project paths are repaired)
  Goal: Replace every admitted checkout-specific or machine-coupled project path with portable resolution.
  Depends on: `.0`
  Children: `.1.1`, `.1.2`, `.1.3`

- ID: `REPO-ROOT-PATH-PORTABILITY.1.1`
  Status: `done`
  Goal: Remove the Rust primary CLI's compile-time checkout identity.
  Depends on: `.0`
  Acceptance: Replace `env!("CARGO_MANIFEST_DIR")` repository discovery in the shipped Rust primary command
    with deterministic upward discovery from the real cwd and current executable, using the checked-in bundled-
    spec marker and a defined no-marker fallback. Preserve explicit `run_with_context` behavior and native spec-
    resolution precedence. Add focused unit proof for cwd, executable, precedence, and fallback anchors; prove the
    previously failing copied-binary reproduction turns green; update docs/KM/live state; run focused and canonical
    gates; commit, clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.1.1 - derive Rust checkout at runtime`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — The `.0` copied-binary probe placed the current Rust command beneath a synthetic
    moved root with a unique adjacent spec, launched from outside, and reproduced exit 1
    `parser compilation failed` instead of the moved-root value.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `TOOLBOX.md`-guided source inspection localized the failure to
    `rust/linkedspec-runtime/src/primary_cli.rs::run`: production `env!("CARGO_MANIFEST_DIR")` preserved the
    compiler's checkout and bypassed both runtime anchors.
  - [x] **FIX** — `primary_cli::run` now searches current-executable ancestry first, then cwd ancestry, using the
    bundled user-function spec as the marker and cwd as the no-marker fallback; no production compile-time root
    identity remains.
  - [x] **ADDRESSED (verified)** — The exact copied-binary probe now exits 0 with `"relocated-root"`; focused unit
    coverage locks executable/cwd/fallback anchors, and all seven primary-CLI unit tests pass.
  - [x] **NO REGRESSION** — `run_with_context` and native exact/suffix/specs precedence remain unchanged; Rust local
    passes core/runtime/integration/corpus/generated/semantic suites plus CLI 66x2, and canonical CI is green.
  - [x] **LOCKSTEP** — ADR, Knowledge Map, README, roadmaps, mdBook, task/live/memory/change/development records,
    generated map, four doctrines, cleanup, commit/brief/clean-tree, 19/300 counter, and no-push state are aligned.

- ID: `REPO-ROOT-PATH-PORTABILITY.1.2`
  Status: `done` (2026-07-26; all eight frozen owners are machine-independent)
  Goal: Remove live developer-home and private-mount values from tracked legacy code/configuration.
  Depends on: `.1.1`
  Acceptance: Repair only the audited live/config owners: `conf/fv_check.conf`, `conf/lighttpd.conf`,
    `conf/network.conf`, `conf/pcsally_mem.conf`, `conf/tkgui.tk`, `noncore/EasyTk.pm`,
    `noncore/plugin/network.plg`, and `perl/env.conf`. Prefer repo-relative config paths, PATH-selected tools,
    explicit caller configuration, and existing config fields; do not reinterpret neutral absolute-path contract
    fixtures, temporary paths, URLs, or stable OS/tool paths. Run syntax/corpus/noncore-focused proof plus canonical
    gates; update docs/KM/live state; commit, clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.1.2 - remove machine-bound legacy paths`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Exact tracked-file scans confirmed the eight frozen owners contained developer-home,
    private-mount, or private-workspace defaults and comments that could not survive relocation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — The legacy configs persisted one developer's project/tool locations instead
    of using their existing configuration fields, repo-root-relative operands, or caller-selected `PATH`.
  - [x] **FIX** — Project inputs/defaults are relative to the caller-selected root, tools use `PATH`, EasyTk leaves
    Tcl/Tkx package discovery to caller configuration, and `network.plg` consumes `dc_load_cmd` plus `ddc` from
    `conf/network.conf`; only the eight frozen owners changed.
  - [x] **ADDRESSED (verified)** — The exact machine-bound scan is empty; 15 portable-config assertions pass;
    pplugin returns the expected hash registry with the configured network command; all five Lispish configs parse;
    and `PPlugin.pm`, `HTTP/FileAccess.pm`, and stubbed-external `EasyTk.pm` syntax pass.
  - [x] **NO REGRESSION** — Stable `/usr/bin/csplit`, temporary/URL/OS paths, caller exact paths, and neutral path
    fixtures remain untouched; the canonical gate and complete documentation/doctrine checks pass.
  - [x] **LOCKSTEP** — ADR, Knowledge Map, README, roadmaps, mdBook, task/live/memory/change/development records,
    commit/brief/clean-tree state, 20/300 counter, and no-push state are aligned; `.1.3` is the next clean frontier.

- ID: `REPO-ROOT-PATH-PORTABILITY.1.3`
  Status: `done` (2026-07-26; all 12 durable Julia commands are machine-independent)
  Goal: Make durable Knowledge Map verification commands machine-independent.
  Depends on: `.1.2`
  Acceptance: Normalize the 12 audited Julia fact-card commands so they select `julia` through `PATH`, use
    repo-relative `--project=julia`/test paths, and compose caller-writable depot storage without a developer home
    or private macOS session directory. Regenerate, never hand-edit, `KNOWLEDGE_MAP.md`; pass every affected
    reverify command or the strongest exact grouped equivalent, plus Knowledge Map/book/canonical gates; commit,
    clear the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.1.3 - normalize durable reverify paths`

  #### Acceptance Checklist

  - [x] **EXACT OWNERSHIP** — Changed only the 12 audited Julia fact-card commands plus their mechanically derived
    `KNOWLEDGE_MAP.md`; valid caller paths, OS/tool paths, and unrelated fact cards remain unchanged.
  - [x] **PORTABLE COMMANDS** — Every command selects `julia` through `PATH`, uses root-relative `--project=julia`
    and test paths, and places its writable depot below caller `TMPDIR` (or the external `/tmp` fallback).
  - [x] **COMPLETE DEPOT STACK** — Commands append Julia's runtime `Base.DEPOT_PATH` explicitly. A trailing empty
    depot entry was rejected because Julia expands it to system depots only, omitting the user package depot and
    forcing an offline registry download; no concrete expanded path is persisted.
  - [x] **DIRECT HARNESS CONTEXT** — The three semantic-query commands define root-relative `REPO_ROOT=pwd()`
    before including tests whose shared fixtures require that harness constant.
  - [x] **ADDRESSED / NO REGRESSION** — Exact scan finds zero former Julia binary, developer-home, or private-
    session paths. The complete Julia local gate, 1,337-assertion direct semantic bundle, semantic/cursor/root
    contract checks, Knowledge Map, mdBook, doctrines, and canonical gate pass.
  - [x] **LOCKSTEP** — ADR, Knowledge Map, README, roadmaps, mdBook, task/live/memory/change/development records,
    commit/brief/clean-tree state, 21/300 counter, and no-push state align; `.2.1` is the next clean frontier.

- ID: `REPO-ROOT-PATH-PORTABILITY.2`
  Status: `done` (2026-07-27; both structural and recurring process gates complete)
  Goal: Mechanically prevent checkout-specific repository paths from returning.
  Depends on: `.1.3`
  Children: `.2.1`, `.2.2`

- ID: `REPO-ROOT-PATH-PORTABILITY.2.1`
  Status: `done` (2026-07-26; tracked paths and five runtime anchors are mechanically gated)
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

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — ADR `0052` and the `.0` audit proved the relocation rule was prose-only after
    remediation: no registered structural check rejected a newly staged checkout identity or anchor regression.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `scripts/check_doctrines.sh` had four registered doctrines and no path
    classifier; `rust/linkedspec-runtime/src/primary_cli.rs` plus the four other primary entrypoints had correct
    runtime anchors, but the registry did not mechanically retain them.
  - [x] **FIX** — Added one executable, read-only `scripts/check_repo_root_path_portability.sh`, one
    `REPO-ROOT-PATHS` driver entry, and one matching `DOCTRINE_ENFORCEMENT.md` row. It derives its own root, scans
    tracked parent text only, locks Perl/Rust/Dart/Julia/Lua anchors, and is recognized by the staged tool-evidence
    signature gate.
  - [x] **ADDRESSED (verified)** — `bash scripts/check_repo_root_path_portability.sh` passes its always-run seven
    rejection plus seven legal self-tests, finds tracked parent text clean, rejects compile-time Rust primary root
    discovery, and finds all five anchor families exact.
  - [x] **NO REGRESSION** — `bash -n`, the staged checker self-scan, all five registered doctrines, mdBook,
    Knowledge Map, memory/whitespace, and canonical `bash tools/run_ci_local.sh` pass; legal URLs, `/usr`/`/opt`,
    caller `/tmp`, relative operands, `C:/Demo`, and path-denial needles stay accepted.
  - [x] **LOCKSTEP** — ADR, Toolbox, Knowledge Map, README, roadmaps, mdBook, task/live/memory/change/development
    records, registry/documentation rows, commit/brief/clean-tree state, 22/300 counter, and no-push state align;
    `.2.2` is the next clean frontier.

- ID: `REPO-ROOT-PATH-PORTABILITY.2.2`
  Status: `done` (2026-07-27; moved-root behavior and all five runtime anchors recur in canonical CI)
  Goal: Close the invariant with a recurring relocated-checkout process oracle.
  Depends on: `.2.1`
  Acceptance: Add one Rust integration test that copies the freshly built primary executable beneath a synthetic
    moved repository, supplies only that tree's unique named spec plus root marker, launches from outside it, and
    requires exact successful output. Lock the four already-correct Perl/Dart/Julia/Lua entrypoint anchors in the
    structural checker and repeat their outside-cwd primary smoke proof. Synchronize README/roadmaps/book/KM/live
    state, close the task tree, pass the complete canonical gate, remove only explicit task scratch, commit, clear
    the brief, verify clean, and do not push.
  Commit: `REPO-ROOT-PATH-PORTABILITY.2.2 - prove relocated checkout execution`

  #### Acceptance Checklist

  - [x] **CLEAN PIVOT / TASK FIRST** — Began from clean `PROJECT-DATA-SSD-ROOTING.5` commit `0319e698`, empty
    commit brief, zero managed runs, and 38/300 local commits with no push; activated this leaf before changing any
    relocation implementation, test, or public documentation.
  - [x] **CURRENT PROOF INVENTORY / RED** — Existing Knowledge/Toolbox authority shows `.1.1` made the exact
    copied-binary/named-spec reproduction green only as a manual run. The Rust storage oracle copies below the real
    checkout and uses an inline spec, while `.4.2` relocates a checkout but also uses inline specs. Structural RED
    confirms no integration owner or canonical invocation exists; the synthetic storage path's ancestry reaches
    the real marker. Production root discovery stays unchanged; this leaf owns only recurring composition.
  - [x] **RECURRING RUST RELOCATION ORACLE** — Copy the freshly built primary executable beneath a synthetic moved
    repository containing only its own unique named spec and required root marker, launch from outside it under the
    final repository-filesystem storage environment, and require exact successful output from that moved tree.
    Make wrong-root selection and incomplete moved-root topology deterministic failures; keep all generated state
    on the repository filesystem and clean it exactly.
  - [x] **FOUR EXISTING RUNTIME ANCHORS** — Retain the structural Perl `FindBin`, Dart script/cwd ascent, Julia
    `@__DIR__`, and Lua `debug.getinfo` locks; repeat their outside-cwd named-primary smoke proof through supported
    storage wrappers with exact output and no project data on the caller filesystem.
  - [x] **RECURRING / CANONICAL GATES** — Register the smallest recurring process boundary in the established
    doctrine/local-CI topology without duplicate execution; pass focused mutation-sensitive proof, all six
    doctrines, Knowledge Map, mdBook, complete canonical CI, whitespace, memory, task metadata, and zero runs.
  - [x] **LOCKSTEP / CLEAN CLOSE** — Synchronize ADR/roadmaps/task/live/change/development/memory/Knowledge facts and
    public book with exact results; close this tree, resume the recorded semantic frontier, commit at 39/300, clear
    the brief, verify a clean tree, and do not push.

## Current Frontier

| Leaf | Status | Next action |
| --- | --- | --- |
| — | — | Tree complete; resume `FUTURE-PARITY-BACKLOG.10.7.3.2.1` only after the clean `.2.2` commit. |

## Decisions

- Repository relocation is a correctness property, not an installation convenience.
- Persisted references to repository content are repo-root-relative.
- Runtime code discovers the current root from its own stable location or an explicit caller root, never from a
  baked-in checkout path; reliance on an arbitrary caller cwd must be classified and repaired.
- A dynamically derived absolute runtime path is an implementation detail, not durable project identity.
- The audit must not misclassify unrelated external OS/tool/temp paths as repository-path violations.
- ADR `0052` is the durable contract. Caller-supplied exact paths stay legal data; they never become an implicit
  project root or durable checkout identity.
- Director-ordered `PROJECT-DATA-SSD-ROOTING` took clean-pivot precedence before `.2.2`; commit `0319e698` closes
  it, so relocation process proof now exercises the final repo-filesystem storage environment rather than
  superseded OS-temp defaults.
- The recurring closeout composes existing production behavior rather than adding a second root-discovery owner:
  Rust owns moved-root selection in one integration test; one self-rooted shell boundary repeats the other four
  runtime anchors and is invoked exactly once by canonical CI.
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
- `.1.1` repairs that defect without changing caller-controlled `run_with_context`: `run` now searches upward from
  the current executable first, then from cwd, for `specs/user_function_definition.spec`, and falls back to cwd
  when neither anchor belongs to a checkout. Executable precedence keeps a bundled command attached to its own
  moved tree; cwd discovery still supports a separately installed command invoked within a checkout.
- `.1.3` makes all 12 durable Julia reverify commands machine-independent. Each selects `julia` from `PATH`, keeps
  project/test operands relative to the repository root, and composes writable temporary depot storage with the
  runtime default depot list without persisting any expanded machine path.
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
| 2026-07-25 | `.1.1` | `cargo fmt --check`; `primary_cli::tests`; Rust CLI conformance default + POSIX | PASS; 7/7 unit tests and 66/66 twice |
| 2026-07-25 | `.1.1` | copied current Rust binary below synthetic moved root, unique adjacent spec, outside cwd | GREEN: exit 0, exact `"relocated-root"` |
| 2026-07-25 | `.1.1` | `bash tools/run_rust_local.sh` | PASS; core/runtime unit, integration, corpus, emitted-source, semantic admission, and CLI 66x2 |
| 2026-07-25 | `.1.1` | mdBook; Knowledge Map; memory architecture; doctrine driver | PASS; KM 706 facts / 5,504 questions; all four doctrines PASS |
| 2026-07-25 | `.1.1` | canonical `env PERL5LIB= bash tools/run_ci_local.sh` | PASS; Rust semantic 1/1 in 81.72s, Dart 1/1, Julia 416/416 in 29.3s, Perl primary 66x2, Phase 0 1,031/1,031 in 640s |
| 2026-07-26 | `.1.2` | exact eight-owner scan; 15 assertions; pplugin hash/body; five wrapped Lispish parses; three Perl syntax checks | PASS; 0 machine-bound matches and every configured/relative/PATH contract exact |
| 2026-07-26 | `.1.2` | mdBook; Knowledge Map; memory architecture; doctrine driver; whitespace | PASS; KM 706 facts / 5,506 questions; all four doctrines PASS |
| 2026-07-26 | `.1.2` | canonical `env PERL5LIB= bash tools/run_ci_local.sh` | PASS; Rust semantic 1/1 in 79.39s, Dart 1/1, Julia 416/416 in 28.1s, Perl primary 66x2, Phase 0 1,031/1,031 in 637s |
| 2026-07-26 | `.1.3` | exact 12-card machine-path scan; generated Knowledge Map | PASS; 0 former binary/home/private-session matches; KM 706 facts / 5,509 questions |
| 2026-07-26 | `.1.3` | full Julia local gate; direct 12-suite semantic bundle; semantic/cursor/root governance | PASS; package/primary/corpus complete; direct 1,337 assertions; semantic 6/20/89, cursor 8/0/60, root 7/0/54 |
| 2026-07-26 | `.1.3` | mdBook; Knowledge Map; memory architecture; doctrine driver; whitespace | PASS; all four doctrines PASS |
| 2026-07-26 | `.1.3` | canonical `env PERL5LIB= bash tools/run_ci_local.sh` | PASS; Rust semantic 1/1 in 79.65s, Dart 1/1, Julia 416/416 in 29.5s, Perl primary 66x2, Phase 0 1,031/1,031 in 647s |
| 2026-07-26 | `.2.1` | `bash -n scripts/check_repo_root_path_portability.sh`; direct checker; staged checker self-scan | PASS; 14 reject/accept classifier cases, clean tracked parent text, all five primary anchor families exact |
| 2026-07-26 | `.2.1` | `bash scripts/check_doctrines.sh`; mdBook; Knowledge Map; memory; whitespace | PASS; all five registered doctrines; KM 706/5,513; 43-line memory; aligned documentation |
| 2026-07-26 | `.2.1` | canonical `env PERL5LIB= bash tools/run_ci_local.sh` | PASS; Rust semantic 1/1 in 80.26s, Dart 1/1, Julia 416/416 in 28.6s, Perl primary 66x2, Phase 0 1,031/1,031 in 657s |
| 2026-07-27 | `.2.2` | Knowledge/Toolbox proof inventory; integration/canonical owner absence; storage-oracle ancestry probe; structural doctrine; zero runs | RED: `.1.1` named-spec relocation is manual-only; existing copied binary is below the real checkout and both current process oracles use inline specs; no recurring named-spec moved-root owner exists; 14/5 structural checker remains green |
| 2026-07-27 | `.2.2` | focused composed oracle; workflow routing; structural path/storage checks; six-family process containment | PASS: moved Rust exact output plus marker-removal failure; Perl/Dart/Julia/Lua exact outside-cwd output; 39 routes; 1,655 files / 366,911 lines; zero containment denial |
| 2026-07-27 | `.2.2` | complete `bash tools/run_rust_local.sh` | PASS: core 193, runtime 149, integration 197, corpus/classifier 105 each, semantic 1/1 in 80.77s, storage, primary 66x2; relocation integration included |
| 2026-07-27 | `.2.2` | canonical `env PERL5LIB= bash tools/run_ci_local.sh` | PASS: all six doctrines; Rust semantic 1/1 in 80.60s, Dart 1/1, Julia 416/416 in 28.5s, primary 66x2, both relocated process oracles, Phase 0 1,031/1,031 in 653s |
| 2026-07-27 | `.2.2` | fresh complete Dart, Julia, PUC Lua/LuaJIT local gates; primary and Unicode matrices; all maintained focused parity matrices | PASS: Dart format/analyze/337, Julia complete package + semantic 416/416, both Lua ABIs 177 each; primary 660/660; Unicode 10/10; diagnostic/logical/root/cursor/duplicate/repeated/punctuation green; scalar numeric 55/55 across six runtimes |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `9f3e59c2` — `REPO-ROOT-PATH-PORTABILITY.0 - freeze relocation invariant` | Behavior-free ADR/audit/split; no repair or checker behavior. |
| `.1.1` | `80cc3383` — `REPO-ROOT-PATH-PORTABILITY.1.1 - derive Rust checkout at runtime` | Rust runtime-anchor repair; copied-binary RED is green. |
| `.1.2` | `507fc72e` — `REPO-ROOT-PATH-PORTABILITY.1.2 - remove machine-bound legacy paths` | Eight frozen config/source owners now use relative roots, existing fields, or PATH tools. |
| `.1.3` | `6648d3bf` — `REPO-ROOT-PATH-PORTABILITY.1.3 - normalize durable reverify paths` | Twelve Julia fact-card commands now use runtime-composed portable roots and depots. |
| `.2.1` | `6edf5c8a` — `REPO-ROOT-PATH-PORTABILITY.2.1 - gate repository path portability` | One read-only doctrine scans tracked parent text and locks all five runtime anchors. |
| `.2.2` | `(this commit)` — `REPO-ROOT-PATH-PORTABILITY.2.2 - prove relocated checkout execution` | Rust moved-root integration plus five-runtime recurring process composition closes the tree. |

## Changelog

- `2026-07-25`: Created the critical relocation-invariance tree after clean semantic commit `99a3df5b`; audit
  `.0` precedes any remediation or doctrine change.
- `2026-07-25`: Completed `.0`; ADR `0052`, exact inventories, three repair leaves, structural doctrine, and
  recurring relocation oracle are frozen. `.1.1` is active from the clean audit commit.
- `2026-07-25`: Completed `.1.1`; Rust primary discovery is runtime-rooted, the exact relocation reproduction is
  green, and full Rust/canonical signoff passes. `.1.2` is active from this clean commit.
- `2026-07-26`: Completed `.1.2`; the eight frozen legacy owners contain no developer-home/private-mount values,
  focused parser/syntax/config proof and the canonical gate pass, and `.1.3` becomes the clean frontier.
- `2026-07-26`: Completed `.1.3`; all 12 Julia fact-card commands are machine-independent, their complete grouped
  proof passes, the derived map is synchronized, remediation `.1` closes, and `.2.1` becomes the clean frontier.
- `2026-07-26`: Completed `.2.1`; `REPO-ROOT-PATHS` is registered once through E3/E4, its 14-case classifier and
  five primary anchor families pass, and `.2.2` becomes the clean frontier.
- `2026-07-27`: Completed `.2.2`; a Rust moved-root integration test and one SSD-routed five-runtime process oracle
  recur in canonical CI, routing is 39 entrypoints, the complete Rust/canonical gates pass, and the relocation tree
  closes without production root-discovery changes. The paused Lua semantic frontier resumes after this clean
  commit.
