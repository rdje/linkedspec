# ADR 0063: README is a bounded stable landing page

- Date: 2026-07-29
- Status: accepted; content and enforcement implemented by `README-STABILITY-POLICY.1`
- Tags: documentation, readme, doctrine, maintenance, navigation, local-ci

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

## Consequences

- README becomes fast to scan and mechanically resistant to unbounded growth.
- Public and operational detail gains one canonical owner instead of drifting copies.
- Stable navigation can evolve within measured headroom; a larger responsibility requires explicit review.
- README edits become uncommon and are justified by changes to purpose, first use, top-level architecture, or
  navigation rather than by every implementation slice.
- Licensing remains truthful but unresolved until the director chooses project-level terms.

Implementation signoff passes the staged-snapshot checker and the complete canonical local gate, including all
seven doctrines, repository-volume containment, moved-root execution, primary CLI 66x2, and Phase 0
1,031/1,031. Capability behavior is unchanged; only canonical documentation ownership and derived public-file
inventories move.

## Links

- Task owner: `docs/tasks/README-STABILITY-POLICY.md`
- Documentation routing: `docs/linkedspec-book/src/development/documentation-workflow.md`
- Doctrine architecture: ADR `0009` and `DOCTRINE_ENFORCEMENT.md`
- Root path and storage invariants: ADRs `0052` and `0053`
