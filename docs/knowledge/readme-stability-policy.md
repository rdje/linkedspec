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
status: accepted plan; README content and checker admission pending
tags: [readme, documentation, doctrine, navigation, maintenance, license]
evidence: "README-STABILITY-POLICY.0 reads the approved 71-line policy template, measures the 1,615-line / 159,437-byte baseline, inventories every section, and validates a lossless 105-line / 5,072-byte landing-page prototype. ADR 0063 fixes hard maxima of 128 lines and 6,144 bytes, canonical routing, registered doctrine enforcement, and reviewed cap increases. The repository has nested/vendor licenses but no declared project-level root license; proposed leaf .3 tracks that separate director decision."
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

Leaf `README-STABILITY-POLICY.1` owns the repository policy, README trim, and the registered
`README-STABILITY` doctrine. The checker is read-only and repository-rooted, enforces both limits and stable
sections/links, rejects drift categories, and self-tests exact-boundary acceptance plus line, byte, and combined
overflow. Registry execution makes it part of pre-commit and canonical local CI.

The repository currently has licenses for nested/vendor components but no declared project-level root license.
Those component terms do not authorize an inferred LinkedSpec license. Proposed leaf
`README-STABILITY-POLICY.3` preserves the question for an explicit director decision while the landing page
states the present fact honestly.

Related: [[repository-root-path-portability]] and [[project-data-workflow-routing]].
