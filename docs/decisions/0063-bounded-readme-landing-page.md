# ADR 0063: README is a bounded stable landing page

- Date: 2026-07-29
- Status: accepted; original content/enforcement closed by `README-STABILITY-POLICY.2`; routing-pressure closure
  ratified by `.4.0` and signoff-complete under `.4.1`
- Tags: documentation, readme, doctrine, maintenance, navigation, local-ci, routing, pressure, lifecycle

## Context

The root `README.md` has accumulated project status, roadmap narrative, architecture inventories, gate details,
historical milestones, and session instructions alongside its landing-page role. It is 1,615 lines and 159,437
bytes. Most changing material already has a stronger canonical owner in the mdBook, roadmaps, task trees, decision
records, Knowledge Map, Toolbox, changelog, or continuity documents. Repeating it in README creates routine drift
and makes first-use navigation harder.

The director approved adopting a project-neutral policy that keeps README stable, routes changing detail before
removal, enforces deliberate line and byte budgets, and requires an explicit reviewed decision for any increase.
LinkedSpec must own its normative policy and checker; the external template is read-only guidance, not a
dependency.

A lossless landing-page prototype is 105 lines and 5,072 bytes. It retains purpose, audience, differentiating
cursor/capture/recursion semantics, one verified Perl quick start, the five-native-implementation architecture,
root-relocation and project-data invariants, canonical navigation, a concise repository map, contribution and
support pointers, and an accurate license notice. The repository has component/vendor licenses but no declared
project-level root license; choosing terms is a separate director decision.

## Decision

### 1. README has one stable role

The root `README.md` is the repository landing page. It may contain only:

- purpose, intended audience, and stable scope;
- prerequisites and one minimal verified quick start;
- stable top-level architecture and repository invariants;
- concise canonical documentation, contribution, and support navigation; and
- accurate license and essential notices.

Changing implementation status, roadmap/task detail, exhaustive inventories, gate composition, historical
milestones, troubleshooting, and deep reference material must be written to their canonical owners and linked,
not copied, from README. `README_POLICY.md` is the normative routing contract.

### 2. Initial budgets are 128 lines and 6,144 bytes

Leaf `README-STABILITY-POLICY.1` trims README to the reviewed 105-line / 5,072-byte prototype class. The
mechanical maximum is **128 lines and 6,144 bytes**, leaving 23 lines and 1,072 bytes of headroom (about 22% and
21%) for stable navigation maintenance without inviting status accretion.

Both limits are hard ceilings. Ordinary feature work must route detail elsewhere. Increasing either limit
requires a new accepted decision record that states the old and new values, why routing or editing cannot solve
the need, and what new stable landing-page responsibility justifies the increase.

Machine-auditable initial transition:

- Previous README line cap: `unbounded`
- New README line cap: `128`
- Previous README byte cap: `unbounded`
- New README byte cap: `6144`

### 3. README stability is a registered doctrine

Add a repository-rooted, read-only `scripts/check_readme_stability.sh` and register doctrine
`README-STABILITY` in `scripts/check_doctrines.sh` and `DOCTRINE_ENFORCEMENT.md`. Existing registry execution
provides pre-commit and canonical-local-CI enforcement.

The checker must parse the unique machine-readable limits from `README_POLICY.md`, enforce both limits, verify
required stable sections and canonical links, emit routing guidance on failure, and reject reintroduced
current-status/history/inventory sections. Its inline self-tests cover exact-limit acceptance plus line-only,
byte-only, and combined overflow rejection without creating off-repository temporary data.

When a staged policy raises a cap relative to `HEAD`, the checker must require a newly staged, indexed decision
record containing the old and new limits. The initial policy is admitted only with this ADR. A cap change that
edits the checker to bypass this rule is itself doctrine drift.

### 4. Unique information moves before duplication is removed

The adoption leaf uses the audited route map in `docs/tasks/README-STABILITY-POLICY.md`. No unique fact is
discarded. Public behavior and examples belong in the mdBook/user guide; direction and sequence in roadmaps/task
trees; current owner structure in `ARCHITECTURE_STATE.md`; operational proof in `TOOLBOX.md` and the mdBook local-
CI chapter; rationale in ADRs/Knowledge cards; history in `CHANGES.md`; and resume state in continuity documents.

Capability/public no-drift checkers must follow the same rule. They may scan README for forbidden syntax or stale
classes, but current capability markers, rollout counts, commands, and examples belong to the governed neutral
contract, guide, capability/backend documentation, mdBook, roadmap, ADR, or Knowledge owners—not README.

### 5. Routing is complete only at a controlled terminal

The 2026-08-09 director-priority policy revision closes a gap in the original adoption: moving content out of
README is not successful when its destination can grow as an unclassified neighboring sink. LinkedSpec therefore
distinguishes `reader_navigation` from `author_overflow`, inventories every actual path-shaped destination named
by README, this policy, and checker failure guidance, and follows each route until it reaches a controlled terminal.

The project-owned registry implemented by `.4.1` is `doctrine/readme_stability/routes.jsonl`. It contains strict,
typed JSON Lines records for surfaces and routes. Surface records name a stable id, root-relative target patterns,
owner, lifecycle, verifier, line/byte/file/aggregate limits where applicable, 80% warning and 90% rollover
milestones, route targets, and any immutable baseline/debt transition. Route records name exact source path,
marker, route kind, and target surface. Unknown fields, unsafe paths, duplicate ids, absent markers or targets,
cycles, and lifecycle/control contradictions fail closed.

Controls are lifecycle-specific:

- bounded current files have independent line/byte ceilings plus overwrite, review, or staleness semantics;
- partitioned manuals/tasks have a bounded index, per-part, file-count, line-total, and byte-total ceilings;
- generated projections have size ceilings and an executable freshness verifier over canonical inputs;
- append-only history is query-first and has a finite shard/rotation threshold;
- external services have an exact HTTPS authority plus named lifecycle owner;
- frozen records require a pinned identity and cannot receive author overflow; and
- source/executable repository components used only for reader navigation must exist at their exact root-relative
  location but are not misclassified as prose sinks.

The checker now runs unconditionally as part of existing doctrine `README-STABILITY`; it does not depend on README
being changed. It derives local Markdown/code-path route candidates and all emitted `route_hint` author guidance,
requires exact registry coverage, evaluates transitive closure, measures the staged resulting tree, and rejects
undeclared threshold increases. Any pressure-limit increase requires a new accepted and indexed ADR with exact
surface id and old/new canonical limits.

Initial-registry authority markers:

- Initial README pressure registry: `doctrine/readme_stability/routes.jsonl`
- Initial README pressure registry version: `1`
- Initial README pressure warning percent: `80`
- Initial README pressure rollover percent: `90`
- Initial README pressure authority: `README-STABILITY-POLICY.4.0`

The clean `7c2ff407` audit measures four debt families: `LIVE_ACHIEVEMENT_STATUS.md` at 14,769 lines /
1,262,969 bytes; `docs/tasks/` at 85 files / 64,378 lines / 6,204,304 bytes with
`docs/tasks/FUTURE-PARITY-BACKLOG.md` at 26,979 lines / 2,720,175 bytes; `CHANGES.md` at 44,128 lines /
3,091,199 bytes; and `DEVELOPMENT_NOTES.md` at 21,169 lines / 2,277,541 bytes. These immutable baselines are debt,
not healthy defaults. Registry transition allowance is finite and owned only by README `.4` adoption/closeout or
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT`; ordinary feature commits cannot refresh the baseline or spend the allowance.

The same audit finds one original-adoption navigation defect: commit `ca846e7a` introduced a README layout entry
for absent root `test_input/`. Git proves neither its parent nor current tree contains that directory; the actual
fixture roots are `t/` and `tests/`, with nested Pgen inputs under `rgx/subs/pgen/tests/`. `.4.1` removes the stale
root path and makes reader-route existence mutation-tested.

Implementation result 2026-08-09: `README_POLICY.md` is a 158-line / 9,102-byte fenced local authority under its
256-line / 24,576-byte surface control; README remains 105 lines and shrinks to 5,057 bytes after only the stale
marker is removed. The 83-line registry declares the 20 ratified ids and 62 exact routes (39 README reader, five
policy/enforcement reader, 18 author-overflow). The core-Perl checker extracts those routes from the resulting
documents and its actual `route_hint` lines, rejects staged/worktree disagreement, measures every declared member,
executes the task-index and Knowledge freshness verifiers, checks exact path/command/external/query terminals, and
governs immutable debt plus future contract/limit changes against `HEAD`. Its in-memory oracle independently
exercises all 32 named mutation classes on every run.

## Consequences

- README becomes fast to scan and mechanically resistant to unbounded growth.
- Public and operational detail gains one canonical owner instead of drifting copies.
- Stable navigation can evolve within measured headroom; a larger responsibility requires explicit review.
- README edits become uncommon and are justified by changes to purpose, first use, top-level architecture, or
  navigation rather than by every implementation slice.
- README routing can no longer claim success while silently shifting append pressure to an unclassified live file.
- Large existing destinations are explicit debt with immutable measurements, finite transition owners, and a
  queued containment task; their size is not normalized into a reusable policy default.
- Licensing remains truthful but unresolved until the director chooses project-level terms.

Original adoption signoff passes the staged-snapshot checker and the complete canonical local gate, including all
seven doctrines, repository-volume containment, moved-root execution, primary CLI 66x2, and Phase 0
1,031/1,031. Revision `.4.0` changed planning truth only; `.4.1` focused proof now passes 20 surfaces, 62 routes,
32/32 mutation classes, and README 105/128 lines plus 5,057/6,144 bytes. Canonical implementation signoff remains
the final acceptance oracle. Capability behavior remains unchanged.

## Links

- Task owner: `docs/tasks/README-STABILITY-POLICY.md`
- Documentation routing: `docs/linkedspec-book/src/development/documentation-workflow.md`
- Doctrine architecture: ADR `0009` and `DOCTRINE_ENFORCEMENT.md`
- Root path and storage invariants: ADRs `0052` and `0053`
