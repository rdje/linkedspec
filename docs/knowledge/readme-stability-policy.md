---
id: readme-stability-policy
title: README is a bounded stable landing page with routed detail
answers:
  - what belongs in README.md
  - why is the LinkedSpec README bounded
  - what are the README line and byte caps
  - where should changing README status detail go
  - may a feature increase the README cap
  - how is README growth enforced
  - which doctrine checks README stability
  - does LinkedSpec currently have a project level license
  - where is the README policy task tracked
  - are README routed destinations pressure controlled
  - what revision adds README routing pressure closure
date: 2026-07-29
status: original adoption closed; routing-pressure revision accepted with implementation pending
tags: [readme, documentation, doctrine, navigation, maintenance, license, routing, pressure, lifecycle]
evidence: "README-STABILITY-POLICY.0-.2 adopt and close the 105-line / 5,072-byte landing page, root policy, hard 128-line / 6,144-byte budgets, and registered read-only checker. Director-priority revision .4.0 reads the supplied 185-line revision and closes the original policy's unchecked-neighbor gap: exactly 62 routes over 20 surfaces are planned for one strict project-owned registry and unconditional checker. Clean 7c2ff407 measurements identify four debt families and open LIVE-DOCUMENT-PRESSURE-CONTAINMENT before enforcement; baselines cannot auto-refresh. ADR 0063 now ratifies lifecycle-specific controls, 80/90 warning/rollover milestones, reviewed threshold increases, and correction of ca846e7a's nonexistent root test_input route. Project licensing remains independent proposed .3."
last_verified: 2026-08-09
reverify:
  - "wc -l -c README.md"
  - "bash scripts/check_readme_stability.sh"
  - "rg -n 'README-STABILITY|README_POLICY.md' scripts/check_doctrines.sh DOCTRINE_ENFORCEMENT.md AGENTS.md docs/linkedspec-book/src/development/documentation-workflow.md"
  - "rg -n 'README-STABILITY-POLICY\\.4|LIVE-DOCUMENT-PRESSURE-CONTAINMENT' docs/tasks docs/TASK_TREE.md"
---

# README stability policy

The root README is a stable landing page, not a status ledger or compact copy of every project document. It owns
purpose and audience, one verified first-use path, stable top-level architecture, concise navigation,
contribution/support entry points, and accurate license or essential notices. Changing detail is routed to the
mdBook/user guide, roadmaps/task trees, architecture state, Toolbox/local-CI chapter, ADRs/Knowledge cards,
changelog, or continuity documents before duplicate README prose is removed.

ADR `0063` fixes initial hard ceilings of 128 lines and 6,144 bytes from a reviewed 105-line / 5,072-byte
lossless prototype. That leaves roughly 22% line and 21% byte headroom. Ordinary feature detail must use a
canonical destination. Raising either cap requires a new accepted, indexed decision that records old/new values
and explains the new stable landing-page responsibility.

Leaf `README-STABILITY-POLICY.1` implements the repository policy, README trim, and the registered
`README-STABILITY` doctrine. The checker is read-only and repository-rooted, enforces both limits and stable
sections/links, rejects drift categories, and self-tests exact-boundary acceptance plus line, byte, and combined
overflow. Registry execution makes it part of pre-commit and canonical local CI.

Closeout `README-STABILITY-POLICY.2` recomposes commit `ca846e7a` without changing README, policy, checker, caps,
or canonical routes. All 27 local links, the quick start, seven doctrines, eight affected public owners, Knowledge
Map, mdBook, containment/moved-root proof, CLI 66x2, and Phase 0 1,031/1,031 pass. The adoption critical path is
closed; project-level licensing remains the independent proposed `.3` director decision.

Its staged-snapshot canonical admission passes all seven doctrines, MCP 5/5 implementations + 6/6 runtimes,
semantic and cursor consumers, repository-volume containment, moved-root execution, primary CLI 66x2, and Phase
0 at 1,031/1,031. This proves that removing volatile README markers changed documentation ownership, not
language or runtime behavior.

Capability governance no longer requires changing status, counts, driver switches, or examples from root README.
Six neutral public-contract checkers use their guide, capability, backend, roadmap, mdBook, ADR, and Knowledge
owners instead. The aggregate-selector and uniform-binding public scanners still include README in broad
forbidden-syntax discovery, but their required current anchors live elsewhere. Removing the routed tokens changes
only exact documentation inventories: cursor is 74 files / 8 complete + 0 pending / 60 mutations and aggregate
selector public proof is 59 files / 25 classified historical references / zero current examples.

The repository currently has licenses for nested/vendor components but no declared project-level root license.
Those component terms do not authorize an inferred LinkedSpec license. Proposed leaf
`README-STABILITY-POLICY.3` preserves the question for an explicit director decision while the landing page
states the present fact honestly.

Revision `.4.0` accepts transitive routing-pressure closure without changing the current policy or checker yet.
The planned registry separates reader navigation from author overflow, classifies lifecycle-specific controls,
checks the resulting tree unconditionally, and makes every threshold increase decision-owned. The clean audit
records oversized neighboring surfaces as immutable debt and opens `LIVE-DOCUMENT-PRESSURE-CONTAINMENT`; it does
not bless their current size or allow ordinary work to refresh their baselines.

Related: [[repository-root-path-portability]] and [[project-data-workflow-routing]].
