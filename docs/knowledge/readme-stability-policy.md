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
date: 2026-07-29
status: accepted, implemented, and canonical-signoff-complete; recurring closeout pending
tags: [readme, documentation, doctrine, navigation, maintenance, license]
evidence: "README-STABILITY-POLICY.0 reads the approved 71-line policy template, measures the 1,615-line / 159,437-byte baseline, inventories every section, and validates a lossless prototype. README-STABILITY-POLICY.1 adopts that exact 105-line / 5,072-byte landing page, root README_POLICY.md, and registered read-only checker. Canonical E4 exposed six capability contract/checker pairs and two public-surface checks that still used root README status/examples as machine inputs; .1 routes those requirements to the already-governed guide/capability/mdBook owners while retaining broad forbidden-syntax scans. Current derived inventories are cursor 74/8+0/60 and selector public surface 59/25/0. The staged-snapshot canonical rerun passes all seven doctrines, MCP 5/5 + 6/6 pending/114, semantic/cursor/storage/relocation proof, CLI 66x2, and Phase 0 1,031/1,031. ADR 0063 fixes hard maxima of 128 lines and 6,144 bytes, canonical routing, and reviewed cap increases. The repository has nested/vendor licenses but no declared project-level root license; proposed leaf .3 tracks that separate director decision."
last_verified: 2026-07-29
reverify:
  - "wc -l -c README.md"
  - "bash scripts/check_readme_stability.sh"
  - "rg -n 'README-STABILITY|README_POLICY.md' scripts/check_doctrines.sh DOCTRINE_ENFORCEMENT.md AGENTS.md docs/linkedspec-book/src/development/documentation-workflow.md"
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

Related: [[repository-root-path-portability]] and [[project-data-workflow-routing]].
