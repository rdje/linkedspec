# SESSION-STARTUP-READING: Complete the Required Reading Before Implementation

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Session continuity prerequisite to RUST-MUTATION-TESTING.1`
- Created: `2026-09-06`
- Last updated: `2026-09-06`
- Owner: repo-local workflow
- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`

## Goal

Complete the director-required roadmap, first-party codebase, and mdBook reading with honest, recoverable
coverage, then resume `RUST-MUTATION-TESTING.1`. Reading supports signoff-quality execution; a saved reading
checkpoint is continuity work and is not feature completion, a code audit, or fresh runtime verification.

## Non-Goals

- Implement features, change behavior, run a mutation campaign, or adopt an unreviewed policy in this checkpoint.
- Count file enumeration, truncated output, historical test results, or unread material as completed reading.
- Include the `rgx` submodule or its nested dependencies in this startup reading pass.

## Acceptance Criteria

- All three required-reading answers become Yes only after their remaining material has actually been read.
- The exact baseline, exclusions, completed ranges, remaining work, and next action survive in committed state.
- Any discovered defect or policy gap receives an owning leaf and evidence before remediation.
- Roadmaps, live continuity, and task index agree; public book changes accompany material public understanding.
- Each completed reading/checkpoint leaf follows `COMMIT.md`; implementation remains gated until reading closes.

## Task Tree

- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Complete the required reading and restore the implementation frontier.
  Children: `SESSION-STARTUP-READING.1`, `SESSION-STARTUP-READING.2`, `SESSION-STARTUP-READING.3`, `SESSION-STARTUP-READING.4`, `SESSION-STARTUP-READING.5`, `SESSION-STARTUP-READING.6`, `SESSION-STARTUP-READING.7`

- ID: `SESSION-STARTUP-READING.1`
  Status: `done`
  Goal: Commit the authorized startup-reading checkpoint before continuing the reading pass.
  Acceptance: Baseline and coverage are explicit, required-reading answers remain honest, and continuity points to `.2`.
  Verification tier: `focused`
  Focused checks: `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `perl tools/roll_document_history.pl --surface change_history --check`; `perl tools/roll_document_history.pl --surface engineering_notes --check`; `git diff --check`; staged-path and coverage review.
  Canonical trigger: `none` — bounded continuity documentation; no policy, infrastructure, or public contract changes.
  Verification: Activated task-tree-first from the clean reading baseline; memory, nine doctrine checks, both history-pressure checks, and diff/scope review pass. README routing was rerun after refreshing the staged snapshot; pre-commit checks the final candidate again.
  Commit: `SESSION-STARTUP-READING.1 - preserve required reading progress`

- ID: `SESSION-STARTUP-READING.2`
  Status: `done`
  Goal: Finish ROADMAP_V2.md from baseline line 1341 and reconcile its current direction with the completed ROADMAP.md reading.
  Acceptance: Baseline lines 1341–1585 are read without truncation; roadmap understanding and any real alignment issue are recorded.
  Verification tier: `focused`
  Focused checks: `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `perl tools/roll_document_history.pl --surface change_history --check`; `perl tools/roll_document_history.pl --surface engineering_notes --check`; `git diff --check`; staged-scope and exact reading-range review.
  Canonical trigger: `none` — startup-reading continuity only; no public, policy, infrastructure, or runtime change.
  Verification: Baseline lines 1341–1585 read in five untruncated ranges; both roadmap diffs since baseline reviewed. Current direction agrees with the task index, mutation-testing tree, ADR 0039, and ADR 0073. Focused commit checks recorded below.
  Commit: `SESSION-STARTUP-READING.2 - complete roadmap reading`

- ID: `SESSION-STARTUP-READING.3`
  Status: `active`
  Goal: Read and understand the remaining first-party codebase, including its tests, specs, and repository tooling.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`, `.3.5`, `.3.6`, `.3.7`, `.3.8`, `.3.9`, `.3.10`, `.3.11`

- ID: `SESSION-STARTUP-READING.3.1`
  Status: `done`
  Goal: Classify the complete baseline tracked inventory and define exact bounded first-party reading children.
  Acceptance: Every baseline path has an explicit category/owner or the director's rgx exclusion; account for
    source, tests, specs, generated inputs, fixtures, tooling, and files outside language directories. Define
    deterministic file/range boundaries and review baseline-to-current changes before claiming any coverage.
  Verification tier: `focused`
  Focused checks: Git baseline/object and current-delta census; disjoint complete reading-category review; exact bounded next-child scope; managed `perl -Iperl -c perl/LinkedSpec.pm` and `perl -Iperl -c t/phase0_regression.t`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — reading inventory and tracking only, with no source/tool/policy/public behavior change.
  Verification: Exact baseline Git object census accounts for 2,547 entries / 52,084,744 blob bytes with one
    excluded gitlink. The disjoint path rules below account for all entries; only four gzip blobs contain NULs.
    Source/test/tool inputs remain byte-identical to baseline. First reading child is exactly five files / 1,430
    lines / 56,706 bytes; inventory and decompression counts do not count as content reading.
  Commit: `SESSION-STARTUP-READING.3.1 - bound the codebase reading inventory`

- ID: `SESSION-STARTUP-READING.3.2`
  Status: `active`
  Goal: Read all 89 baseline Perl entries and their current deltas, starting with the facade invocation owners.
  Children: `.3.2.1`, `.3.2.2`

- ID: `SESSION-STARTUP-READING.3.2.1`
  Status: `done`
  Goal: Read the facade invocation and shared-context owners in full.
  Acceptance: Read `perl/LinkedSpec.pm` 1–296, `perl/LinkedSpec/OwnerDispatch.pm` 1–220,
    `perl/LinkedSpec/Runtime.pm` 1–154, `perl/LinkedSpec/ParserFactory.pm` 1–368, and
    `perl/LinkedSpec/RuntimeContext.pm` 1–392. Reconcile against the existing thin-facade Knowledge card;
    record exact comprehension and any tool-confirmed issue. No runtime-change or full-codebase claim.
  Verification tier: `focused`
  Focused checks: Full untruncated five-file reading and baseline identity/delta review; existing Knowledge-owner comparison; managed Perl facade/phase0 syntax; `bash scripts/check_memory_architecture.sh`; required pre-commit `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — bounded source-reading checkpoint, with no production or public behavior change.
  Verification: All five exact files read through EOF without truncation; Git proves baseline identity. Existing
    thin-facade and leading-trivia Knowledge cards reconcile the owner flow and public-wrapper boundary. Managed
    facade/phase0 syntax passes; no production change, new defect, or runtime/audit-completion claim.
  Commit: `SESSION-STARTUP-READING.3.2.1 - read facade invocation owners`

- ID: `SESSION-STARTUP-READING.3.2.2`
  Status: `pending`
  Goal: Split the remaining 84 baseline Perl paths into exact bounded reading children before reading them.
  Acceptance: Subtract `.3.2.1` by exact path; use the inventory's byte/line boundary rule and retain every file.
    Prior supporting read coverage remains explicit and cannot silently remove an unread interval.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.3`
  Status: `pending`
  Goal: Split and read all 412 baseline Rust entries, including source, tests, corpus, generated files, and manifests.
  Acceptance: Define bounded file/range children before reading; `rgx` is excluded but first-party Rust is not.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.4`
  Status: `pending`
  Goal: Split and read all 115 baseline Dart entries, including compiler/runtime, tests, commands, and package inputs.
  Acceptance: Define bounded file/range children before reading and account for every path plus current deltas.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.5`
  Status: `pending`
  Goal: Split and read all 95 baseline Julia entries, including compiler/runtime, tests, commands, and package inputs.
  Acceptance: Define bounded file/range children before reading and account for every path plus current deltas.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.6`
  Status: `pending`
  Goal: Split and read all 99 baseline Lua entries, including native adapters, both-ABI tests, runtime, and commands.
  Acceptance: Define bounded file/range children before reading; generated tables and the large test runner stay in scope.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.7`
  Status: `pending`
  Goal: Split and read all 158 entries under specs, ebnf, noncore, conf, and tablescript.
  Acceptance: Account for legacy adapters, plugins, authored grammars, configuration, and non-TypeScript `.ts` data;
    use LinkedSpec probes before investigating a spec's behavior, and do not infer defects from historical syntax alone.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.8`
  Status: `pending`
  Goal: Split and read all 160 entries under capability_conformance, cli_conformance, t, tests, and unicode_case.
  Acceptance: Include phase0, neutral contracts, fixtures, generators, and four explicitly decoded pinned Unicode
    inputs. Keep generated/fixture bytes in scope; count neither a hash nor enumeration as full reading.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.9`
  Status: `pending`
  Goal: Split and read all 143 remaining repository-tooling entries from the exhaustive complement rule below.
  Acceptance: Include hooks, shell/Python/Perl tools, root configuration, command entrypoint, doctrine registry data,
    and the vendored Knowledge Map bundle. Reuse exact completed supporting ranges and read every remaining range.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.10`
  Status: `pending`
  Goal: Review root guidance and relevant durable owners using their prescribed reading or indexed-query lifecycle.
  Acceptance: Bind all 28 baseline root Markdown paths to their owners: complete remaining maintained architecture/
    user-guide text in bounded children; retain completed roadmap/bootstrap/Toolbox coverage; query generated
    Knowledge Map and immutable chronology instead of loading them wholesale. Memory records are not source-code coverage.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.11`
  Status: `pending`
  Goal: Reconcile complete source-reading coverage against baseline and final HEAD before closing codebase reading.
  Acceptance: Lanes `.3.2` through `.3.10` are complete; review all changed/new paths since baseline and resolve every unexplained
    omission or overlapping credit. The book's configuration/source remains `.4`-owned. All unverified findings
    have exact owners; read coverage is not runtime signoff.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.4`
  Status: `pending`
  Goal: Read the complete mdBook and check its explanations against the roadmap and codebase.
  Acceptance: Split by SUMMARY.md chapters and bounded ranges before execution; read every chapter and own any verified drift.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.5`
  Status: `pending`
  Goal: Complete supplied-policy adoption/update comparisons and the startup alignment review before implementation.
  Acceptance: Record local adoption evidence and applicable donor updates; own any required changes; confirm all three reading answers Yes, then route to cleanup repair `.7` before restoring RUST-MUTATION-TESTING.1.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.6`
  Status: `done`
  Goal: Reconcile managed-run liveness reporting across restricted and permitted process inspection.
  Acceptance: Use one known live controlled run and compare same-run read-only `--list`, PID/group probes, and
    permitted process inspection; record exact mechanism and locations. Any confirmed false-dead cleanup boundary
    receives a repair leaf and a non-destructive regression plan before recovery is used. No ambiguous deletion.
  Verification tier: `focused`
  Focused checks: Controlled repository-managed live-process probe; read-only restricted/permitted run and process inspection; exact liveness-owner source review; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — diagnostic evidence and startup tracking only; any repair requires a separate infrastructure leaf.
  Verification: Controlled 45-second managed run confirms restricted PID/group probes return errno 1 / EPERM
    while permitted probes return success for the same live PIDs. Restricted `--list` says abandoned; permitted
    `--list` says live. Exact source routes all failed kill-zero checks into false-dead recovery authorization.
    No recovery/deletion probe executed; the wrapper exited 0 and permitted census then found zero leftovers.
    Evidence and source locations: `docs/knowledge/project-data-liveness-permission-denial.md`.
  Commit: `SESSION-STARTUP-READING.6 - diagnose denied liveness probes`

- ID: `SESSION-STARTUP-READING.7`
  Status: `pending`
  Goal: Repair permission-denied liveness handling before any managed recovery or mutation workspace workflow.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; `.6` causal evidence.
  Acceptance: Distinguish confirmed absence from denied/unknown PID and group inspection; denied or unknown
    results must retain scratch. Cover wrapper, child, group, normal drain, recovery, and retained-failure purge
    with non-destructive deterministic EPERM/ESRCH tests and a live restricted-process control. Preserve positive
    dead-run cleanup, signal forwarding, PID-reuse conservatism, same-volume storage, and valid marker ownership.
    Update Toolbox/book/KM claims, run focused lifecycle/storage/dependent checks and exact canonical proof.
    Split into bounded children before implementation if needed; reading prerequisites remain mandatory.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SESSION-STARTUP-READING.3.2.2` | `pending` | Split the remaining 84 baseline Perl paths into exact bounded reading children. |

## Reading Ledger

All line ranges below refer to the **reading baseline**, not later shifted working-file line numbers. Files
modified by this checkpoint must also be reviewed in the final diff. Unlisted source files and unlisted ranges
remain unread; running a command that prints a file does not establish comprehension if its output was truncated.

| Required surface | Fully read and understood? | Completed at checkpoint | Remaining |
| --- | --- | --- | --- |
| Roadmap | **Yes** | `ROADMAP.md` 1–2564; `ROADMAP_V2.md` 1–1585. `.2` read 1341–1380, 1381–1420, 1421–1470, 1471–1530, and 1531–1585 without truncation and reviewed both current roadmap diffs. | Review later changes as they land; codebase/book alignment remains gated on their reading. |
| Codebase | **No** | Five facade/invocation/context files in full under `.3.2.1`; checkpoint-relevant scripts listed below. | Remaining 84 Perl paths and other first-party source/test/spec/fixture/tool inputs not explicitly listed as read. |
| mdBook | **No** | `docs/linkedspec-book/src/SUMMARY.md`; `docs/linkedspec-book/src/development/local-ci-and-regression.md` 1897–1943 and 1988–2004. | All other chapter text, including the unread portions of that development chapter. |

The exact tracked file population and object identities are recoverable without an independently maintained
manifest or an absolute checkout path:

```bash
git ls-tree -r --full-tree baeb984e36a94a15951cd23d4c52def5064cdaca
git ls-tree -r --name-only baeb984e36a94a15951cd23d4c52def5064cdaca -- docs/linkedspec-book/src
git show baeb984e36a94a15951cd23d4c52def5064cdaca:ROADMAP_V2.md | sed -n '1341,1400p'
```

The recursive tree command does not descend into the `rgx` gitlink. During `.3`, classify the whole first-party
inventory, including files outside the obvious language directories; a language-directory census alone is not
complete codebase coverage. Generated source and fixtures are not silently excluded by a file-extension filter.
After a later commit, use `git diff --name-only` against this baseline to identify changed reading inputs; review
the changed portions as well as remaining baseline text. Immutable historical task parts use their indexed
retrieval contract rather than an indiscriminate chronology scan.

### Bootstrap and focused supporting material already read

- `README.md`, `MEMORY_ARCHITECTURE.md`, `MEMORY.md`, `SESSION_BOOTSTRAP.md`, `COMMIT.md`, and local `README_POLICY.md`.
- The supplied `AGENTS.md` instructions and `docs/TASK_TREE_README.md` in full; task-index purpose, active-frontier
  context, and operating rules at `docs/TASK_TREE.md` 3269–3525. The large embedded historical marker section has
  not been read in full.
- `docs/tasks/TEMPLATE.md`, `docs/tasks/RUST-MUTATION-TESTING.md`, and `docs/decisions/0039-rust-mutation-testing-cadence.md`.
- Knowledge cards `rust-mutation-testing-policy`, `bounded-live-document-store-contract`, and
  `verification-cadence-policy` in `docs/knowledge/`. Knowledge Map searches are retrieval, not a full-map read.
- `.githooks/pre-commit`, `.githooks/post-commit`, `.githooks/commit-msg`, `scripts/check_memory_architecture.sh`,
  `scripts/check_verification_cadence.sh`, `scripts/check_task_tree_metadata.sh`,
  `scripts/check_doctrines.sh`, `scripts/check_diagnosis_evidence.sh`, and `tools/check_memory_handoff_state.py`.
- Current `LIVE_ACHIEVEMENT_STATUS.md` in full; `CHANGES.md` and `DEVELOPMENT_NOTES.md` baseline lines 1–100.
  Their older chronology is not fully read; use the indexed history query when historical evidence is needed.
- The director-supplied fsmgen README policy, pgen claim-verification policy, and fsmgen live-document containment
  adoption guide were read in full through explicitly authorized read-only access. Their local adoption/update
  comparisons remain `.5`; reading a donor document does not establish local compliance.
- `TOOLBOX.md`, `ARCHITECTURE_STATE.md`, remaining owner modules, and the full book have not been read in full.
- `.2` additionally read `TOOLBOX.md` 1–125, 605–682, and 1703–1792; `tools/project_data_env.sh` 1–100;
  `tools/project_data_run.sh` 1–190; ADRs `0001`/`0073`; and knowledge card `project-data-descendant-liveness-gap`.
- During the `.2` commit and `.6` diagnosis, additional reading completed `TOOLBOX.md` 126–604 and 683–825,
  plus `tools/project_data_run.sh` 191–355 (EOF). Thus Toolbox coverage is 1–825 and 1703–1792, and the
  managed-run wrapper is fully read. Its new causal finding is recorded separately; other code remains unread.
- `.6` also read `tools/test_project_data_lifecycle.sh` 1–441 (EOF): existing live/dead/recovery/marker tests
  run with ordinary permitted liveness and do not inject denied PID/group inspection. This is source review,
  not a fresh run of that destructive fixture suite.
- `.3.1` completed `TOOLBOX.md` in full through baseline EOF 1864, and read `unicode_case/README.md` in full.
  Four gzip payloads were decompressed only for counts; their contents remain unread. Reviewed the existing
  `linkedspec-pm-is-thin-facade` fact card to select the first code-reading boundary without re-deriving its facts.

### Complete baseline classification at `.3.1`

Baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`. `git ls-tree -r --full-tree` plus
`git cat-file --batch` measured the exact stored objects, not changing worktree bytes. Apply these ordered
path rules; the final complement explicitly owns every otherwise unmatched path.

| Class / path rule | Entries | Stored blob bytes | Reading owner |
| --- | ---: | ---: | --- |
| Exact `rgx` gitlink | 1 | 0 | Director-excluded, including nested dependencies |
| Prefix `docs/linkedspec-book/` | 50 | 1,956,582 | `.4`, including book configuration and all chapter text |
| Remaining prefix `docs/` | 1,197 | 20,123,040 | Durable memory; retrieve relevant owners and indexed history, not codebase reading |
| Root `*.md` (no slash) | 28 | 7,672,599 | `.3.10`, roadmap `.2`, and prescribed memory lifecycles |
| Prefix `perl/` | 89 | 2,133,690 | `.3.2` |
| Prefix `rust/` | 412 | 3,533,382 | `.3.3` |
| Prefix `dart/` | 115 | 2,471,305 | `.3.4` |
| Prefix `julia/` | 95 | 2,693,170 | `.3.5` |
| Prefix `lua/` | 99 | 2,732,450 | `.3.6` |
| Prefix `specs/`, `ebnf/`, `noncore/`, `conf/`, or `tablescript/` | 158 | 964,256 | `.3.7` |
| Prefix `capability_conformance/`, `cli_conformance/`, `t/`, `tests/`, or `unicode_case/` | 160 | 5,422,313 | `.3.8` |
| Every remaining baseline path | 143 | 2,381,957 | `.3.9`: `.claude`, `.github`, `.githooks`, five root dotfiles, `bin`, `doctrine`, `knowledge-map`, `scripts`, `tools` |
| **Total** | **2,547** | **52,084,744** | Every entry accounted for once |

The eight source/tool/fixture lanes contain 1,271 entries / 22,332,523 stored bytes. Of these, 1,267 are text
with 565,122 newline delimiters. Four pinned Unicode gzip inputs are the only NUL-containing blobs; they add
54,500 decoded newline delimiters / 3,352,036 decoded bytes and remain explicitly in `.3.8`. This count is an
inventory, not evidence that any of those lines was understood. Generated Unicode modules, generated MCP
bindings, corpus JSON, and large phase0/runtime files are not silently excluded.

Each future reading leaf names exact paths and inclusive ranges **before** execution, totals at most 1,500
decoded text lines and 65,536 bytes, and uses smaller output chunks to avoid truncation. Oversized files split
at coherent declaration/test boundaries within those limits; a single over-limit line uses explicit byte
ranges. Record all unread suffixes before advancing. Do not duplicate the full immutable inventory into a new
manifest; recover membership from baseline plus these disjoint selectors and recover identities from Git.

`.3.2.1` is exactly 1,430 lines / 56,706 bytes across five files. Its `LinkedSpec.pm` reread checks owner
relationships despite prior facade coverage. Other inputs remain unread unless listed above. At clean
`03d692c13bbc49590f318dd4c8536008d9f979f5`, the ten changed/new paths since baseline are continuity/Knowledge/task
records; all source/test/spec/tool inputs and all book files remain unchanged. Every checkpoint's own final diff
is reviewed separately.

### Facade invocation reading at `.3.2.1`

- Completed `perl/LinkedSpec.pm` 1–296, `perl/LinkedSpec/OwnerDispatch.pm` 1–220,
  `perl/LinkedSpec/Runtime.pm` 1–154, `perl/LinkedSpec/ParserFactory.pm` 1–368, and
  `perl/LinkedSpec/RuntimeContext.pm` 1–392, each through EOF without truncation. All five remain byte-identical
  to the baseline; this is five unique Perl files, not five newly unread files plus the earlier facade credit.
- Understanding agrees with `docs/knowledge/linkedspec-pm-is-thin-facade.md`: public wrappers normalize and
  delegate; `OwnerDispatch` resolves lazy callbacks/bundles and preserves successful caller error/context;
  `ParserFactory` resolves/loads named source through injected owners; `Runtime` delegates compiler work;
  `RuntimeContext` owns identity, source capture, and structured diagnostics/fallback precedence.
- The public runtime wrapper resets the input position and skips leading blank/comment lines. Retrieved
  `docs/knowledge/ds-vhistory-leading-newline-oracle-boundary.md` before interpreting that behavior: it is an
  already-owned cross-backend public-versus-direct-handler boundary, not a new defect from this reading.
- Descriptor, parser, and mode-only return shapes are deliberately distinct; early factory errors and deeper
  compiler errors retain their intended attribution. This reading does not validate every dependency's behavior;
  those remaining owners stay in subsequent bounded leaves.
- Source identity and both managed syntax checks pass. No new causal fact beyond the retrieved owners, no
  production/public change, and no fresh behavioral-conformance claim results from this reading checkpoint.

### Roadmap reconciliation at `.2`

- Activation: clean `a5d5dcd2955aaaa41166bd87de6bdc39a4502bc4`; `.githooks` is configured and no background job remained.
- Both roadmaps changed since the reading baseline only by the same four-line startup-prerequisite pointer.
  Those additions were read, and this checkpoint's final diff is part of review.
- The final roadmap sections explain compiler-state/error ownership, completed helper/control-flow migration,
  deferred frontend/validation work, and label-driven rule execution. Dated earlier migration spellings are
  historical evidence, not authority to restore retired helpers or restart closed work.
- Current direction remains startup reading, then `RUST-MUTATION-TESTING.1` under backlog `.20`. Its configuration
  precedes the separately owned pilot. ADR `0039` forbids per-commit mutation execution; ADR `0073` selects focused
  ordinary proof and canonical designated/push proof. No competing executable roadmap direction was found.
- No runtime behavior was verified by reading. No new public explanation is warranted by this checkpoint;
  substantive codebase/book drift, if found during `.3`/`.4`, must receive an owning leaf before remediation.
- Batch history: `.2` is resumed item 1/100 at `d6d3c890`; `.6` is item 2/100 at `03d692c1`; `.3.1` is item 3/100
  at `942c6138`; `.3.2.1` is item 4/100 once committed. `.1` belongs
  to the prior checkpoint. This intermediate boundary does not trigger a push.

## Decisions

- `2026-09-06`: The director explicitly excluded `rgx` from this reading pass; the exclusion includes its nested
  dependencies and does not remove first-party Rust code or tests from scope.
- `2026-09-06`: After being asked to choose between a reading checkpoint and keeping every file unchanged, the
  director authorized proceeding and delegated the choice. This permits the narrow startup-tracking commit
  before full reading, resolving the session's no-document-edits prerequisite for startup tracking only.
  Implementation and unrelated documentation changes remain gated.
- `2026-09-06`: Keep detailed progress here and a short pointer in layer A; preserve the existing implementation
  destination. The checkpoint does not alter repository doctrine or make reading a substitute for production work.

## Open Questions

- None requiring director input. `.6` resolved the liveness discrepancy as a real false-dead defect; `.7` owns
  repair after required reading. Do not use `--recover` or `--purge-failed` while that boundary remains unfixed.

## Blockers

- None. At activation, Git was clean and no background job was pending. Required reading is unfinished work,
  not a test failure or an external blocker.
- `.7` blocks managed recovery/purge and later mutation-workspace setup until denied/unknown liveness is safe.
  Read-only reading can continue; no source repair is authorized by the narrow startup-tracking exception.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Exact HEAD, empty activation Git status, `.githooks` configured, scoped read coverage | PASS; all remaining reading stays explicit. |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Memory architecture, doctrine driver, history pressure, diff/scope review | Memory and both history limits PASS; eight doctrines PASS initially. README routing rejected two review edits absent from the staged snapshot. |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Restage reviewed files; `bash scripts/check_readme_stability.sh` | PASS: 20 surfaces, 62 routes, 32/32 mutations; all nine doctrine checks now pass. Final exact-candidate proof also runs in pre-commit. |
| `2026-09-06` | `SESSION-STARTUP-READING.2` | Untruncated ranges, baseline diffs, current direction, staged scope | PASS; roadmap Yes, codebase/book No. |
| `2026-09-06` | `SESSION-STARTUP-READING.2` | Memory, nine doctrines, Knowledge Map, both history-pressure checks, staged diff | PASS; all nine doctrines complete successfully, both histories below rollover, no trailing-space errors. Final evidence edits are checked again by pre-commit. |
| `2026-09-06` | `SESSION-STARTUP-READING.6` | Managed 45-second process; paired restricted/permitted run-list and kill-zero probes; exact source trace; final wrapper/census | CONFIRMED DEFECT; EPERM was false-dead. Probe exits 0; no recovery used; zero leftovers. Repair `.7` is required, not claimed complete. |
| `2026-09-06` | `SESSION-STARTUP-READING.6` | Focused memory/history/diff plus required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `03d692c1`; diagnostic checkpoint complete, repair remains pending. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Exact baseline object/class census, binary/decoded inventory, whole-source delta, bounded first-child accounting | PASS; 2,547 disjoint entries and no source/test/tool/book delta; inventory is not reading credit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Managed Perl facade/phase0 syntax; both history-pressure checks; diff review | PASS; both syntax checks OK, change-history warns below rollover, engineering notes OK. Required pre-commit supplies final doctrine/Knowledge proof. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `942c6138`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.1` | Exact five-file full reading, baseline identity, existing owner/trivia Knowledge, managed facade/phase0 syntax | PASS; 1,430 lines / 56,706 bytes covered, no production delta. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SESSION-STARTUP-READING.1` | `SESSION-STARTUP-READING.1 - preserve required reading progress` | Startup-tracking-only exception; reading remains incomplete. |
| `SESSION-STARTUP-READING.2` | `SESSION-STARTUP-READING.2 - complete roadmap reading` | Completed roadmap reading; exact coverage and focused checks, remaining reading and liveness discrepancy owned. |
| `SESSION-STARTUP-READING.6` | `SESSION-STARTUP-READING.6 - diagnose denied liveness probes` | Exact causal evidence and owned repair; no production change or deletion test. |
| `SESSION-STARTUP-READING.3.1` | `SESSION-STARTUP-READING.3.1 - bound the codebase reading inventory` | Complete baseline accounting and bounded next child; source/book reading still incomplete. |
| `SESSION-STARTUP-READING.3.2.1` | `SESSION-STARTUP-READING.3.2.1 - read facade invocation owners` | Five unique Perl files complete; remaining 84 Perl entries and other lanes remain unread. |

## Changelog

- `2026-09-06`: Created the owning leaf before any checkpoint edits; recorded baseline coverage and the remaining reading sequence.
- `2026-09-06`: Completed the focused checkpoint and synchronized continuity; remaining reading starts at `.2`.
- `2026-09-06`: `.2` completes the remaining roadmap ranges and current-direction reconciliation; codebase and
  mdBook reading remain No, and `.3` owns the next inventory/decomposition.
- `2026-09-06`: `.6` proves the surprising liveness report, records a fact card, and owns the repair as `.7`.
  Required reading resumes at `.3`; managed recovery/purge remains unused until repaired.
- `2026-09-06`: `.3.1` classifies every baseline entry, owns all source lanes, completes Toolbox reading, and
  defines exact `.3.2.1` coverage before source reading. No production or public-book change.
- `2026-09-06`: `.3.2.1` completes the five-file invocation boundary and reconciles it with existing Knowledge;
  `.3.2.2` owns decomposition of the remaining 84 Perl paths.
