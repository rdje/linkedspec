<!-- README-POLICY-LOCAL-ADOPTION:BEGIN -->
## Local adoption note — LinkedSpec

- Authority: LinkedSpec maintainers, adopted 2026-07-29 and revised 2026-08-09 under decision `0063`.
- Authoritative copy: repository-root `README_POLICY.md`. Bootstrap files aid discovery but are not authority.
- Independence: the director-supplied FSMGen copy was a read-only template, not an upstream. Later changes require
  deliberate local review; there is no automatic synchronization.
- Landing-page ceilings: 128 lines and 6,144 bytes, derived from the reviewed 105-line / 5,072-byte survivor.
- Routing-pressure authority: the project-owned registry and checker below classify every route and enforce its
  terminal pressure control from the repository's resulting tree.

<!-- README-POLICY-ROUTES:BEGIN -->
| Local enforcement owner | Repository route |
| --- | --- |
| Routed-destination registry | `doctrine/readme_stability/routes.jsonl` |
| Routing-pressure checker | `scripts/check_readme_routing_pressure.pl` |
| Landing-page doctrine wrapper | `scripts/check_readme_stability.sh` |
| Doctrine registry | `scripts/check_doctrines.sh` |
| Canonical local gate | `tools/run_ci_local.sh` |
<!-- README-POLICY-ROUTES:END -->
<!-- README-POLICY-LOCAL-ADOPTION:END -->

---

# README Stability Policy

## Purpose and authority

The root `README.md` is LinkedSpec's stable landing page. It lets a first-time visitor understand the project,
verify one minimal use, and reach canonical documentation without becoming a second manual, roadmap, status ledger,
or change history.

This repository-owned file is normative. ADR `0063` records the adoption and reviewed controls. A user-home,
machine-global, vendor, agent, harness, or external template cannot replace this copy or change it automatically.

## Content contract

README may contain only stable entry material:

- project purpose, audience, and top-level scope;
- prerequisites and one minimal verified quick start;
- stable architecture at a glance and repository invariants;
- concise links to canonical documentation, support, contribution, and status owners; and
- project license state and essential repository-level notices.

Change README only when project purpose, first use, top-level architecture, repository invariants, or canonical
navigation changes. Ordinary feature and milestone work updates the canonical destination instead.

Before deleting or relocating apparent duplication, prove it against the intended canonical home with a phrase,
identity, or content probe. Delete-with-link only when that home is richer and maintained. Relocate information only
when it is unique and still belongs in maintained documentation.

## What belongs elsewhere

These are author-overflow routes. They are exact machine-checked destinations, not permission to append the same
material indiscriminately to every listed file.

| Material | Canonical owner |
| --- | --- |
| Public behavior, concepts, examples, and backend status | `docs/linkedspec-book/` and `USER_GUIDE.md` |
| Direction, sequencing, and active work | `ROADMAP.md`, `ROADMAP_V2.md`, and `docs/tasks/` |
| Current implementation ownership | `ARCHITECTURE_STATE.md` |
| Commands, diagnostics, gate composition, and troubleshooting | `TOOLBOX.md` and `docs/linkedspec-book/src/development/local-ci-and-regression.md` |
| Durable rationale and structural facts | `docs/decisions/` and `docs/knowledge/` |
| Change history | `CHANGES.md` and `git history` |
| Session state and handoff | `MEMORY.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `SESSION_BOOTSTRAP.md` |
| Contribution and commit mechanics | `AGENTS.md`, `docs/TASK_TREE.md`, and `COMMIT.md` |

Prefer one link to the canonical owner over copied detail. Never delete unique information merely to satisfy a
budget: establish the destination, verify it, then shorten README.

## Routing-pressure closure

Moving content out of README is insufficient when the destination can become an unbounded neighboring sink. The
data-only registry inventories every destination named by README, this policy, and the guard's emitted guidance.
Every route has an owner, lifecycle, pressure control, and controlled terminal; unclassified destinations, cycles,
undeclared hints, or chains that merely shift append pressure fail the doctrine.

Routes are classified independently:

- `reader_navigation` tells readers where maintained or immutable information lives;
- `author_overflow` tells authors where a content class is owned, subject to that destination's own control.

The sets may differ. A reader may query immutable history, while an author must not turn it into a new status sink.
The checker derives README and policy routes from the actual documents and author-overflow candidates from the
guidance it can actually emit, then requires exact registry coverage.

Controls follow lifecycle:

| Destination class | Required pressure control |
| --- | --- |
| Hot/live file | Independent line and byte ceilings plus overwrite, review, or staleness semantics |
| Partitioned manual/task collection | Bounded membership plus per-part, file-count, and aggregate ceilings |
| Generated index | Size ceilings plus a reproducible freshness verifier against canonical sources |
| Append-only or rolling history | Query-first access plus a separately owned shard, rotation, or archival threshold |
| External service | Named authority, lifecycle owner, and stable HTTPS query/link contract |
| Frozen legacy record | Content identity or an equivalent write prohibition; never an author-overflow destination |
| Repository or command path | Exact existence, non-symlink, and executable controls where applicable |

Legacy destinations already above a healthy size are debt, not reusable ideals. Their dated baseline is immutable;
further growth is rejected unless an exact finite transition owner is active and the change remains within both its
delta and hard ceiling. Warning begins at 80%; rollover pressure begins at 90% and requires the named migration
owner. The separate `LIVE-DOCUMENT-PRESSURE-CONTAINMENT` tree owns partitioning or compaction, never cap refresh.

## Mechanical budgets

- Machine line cap: `128`
- Machine byte cap: `6144`

Both are inclusive hard ceilings, including headings, fences, blank lines, and the final newline. Line and byte
checks remain independent because either vertical sprawl or dense prose can grow while the other axis appears safe.

Increasing either README cap or any routed-destination limit requires a newly added, accepted, indexed decision
record. It must identify the exact surface, old and new canonical limit objects, explain why routing/editing cannot
meet the need, and name the stable responsibility. An ordinary feature slice cannot raise a threshold.

The initial README admission markers remain:

- Previous README line cap: `unbounded`
- New README line cap: `128`
- Previous README byte cap: `unbounded`
- New README byte cap: `6144`

## Enforcement

The project-local check is deterministic, non-mutating, dependency-free beyond core Perl and Git, and rooted from
its own location. On every invocation it validates the resulting tree—never only a README changed-path subset—and:

- enforces the README and routed-surface limits;
- requires stable landing-page headings, navigation anchors, and valid retained targets;
- validates strict registry schema, exact route coverage, lifecycle/control compatibility, terminal existence,
  transitive acyclic closure, freshness, external authority, frozen identity, and debt transitions;
- rejects controlled staged/worktree disagreement and unauthorized cap, limit, lifecycle, or baseline changes; and
- runs the ratified 32-class in-memory mutation corpus, including a valid reviewed-increase acceptance case.

Doctrine `README-STABILITY` remains one registry entry in `scripts/check_doctrines.sh`. The pre-commit hook and
canonical local gate run the same doctrine registry. Hosted GitHub Actions remain disabled, so local CI is the
project's backstop.

Run the focused check from any working directory:

```sh
bash scripts/check_readme_stability.sh
```

## Adoption and revision checklist

1. Fence project owner/date, authority, independence, decisions, caps, and local enforcement routes above the
   neutral contract.
2. Prove apparent duplication before moving it, and preserve one verified canonical link.
3. Verify the retained quick start and every reader route.
4. Inventory reader and overflow routes through controlled terminals; reject cycles and unclassified sinks.
5. Apply lifecycle-specific line, byte, per-file, file-count, aggregate, freshness, identity, external, or path
   controls; record legacy measurements as immutable debt.
6. Wire the resulting-tree checker unconditionally through the doctrine registry, hook, and canonical local gate.
7. Require an explicit indexed decision before any README or routed-surface threshold increases.
8. Update public and continuity documentation under an owning task-tree leaf, run focused and canonical gates,
   commit atomically, clear the brief, and prove a clean handoff.
