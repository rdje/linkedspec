---
id: aggregate-selector-backend-readme-coverage
title: Backend READMEs are part of aggregate-selector public no-drift
answers:
  - "why did removed aggregate selectors remain in backend READMEs"
  - "which backend READMEs taught stale selector forms"
  - "how does the public selector checker discover component READMEs"
  - "how many public files does aggregate selector admission check"
date: 2026-07-12
status: current
tags: [language, bindings, retirement, documentation, readme, no-drift, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.10 found 14 current positive exact selector forms in rust/README.md, dart/README.md, julia/README.md, and lua/README.md after .12.1.9 had reported zero examples across a curated 47-file root/capability/mdBook list. The four READMEs now use bare typed bindings. tools/check_public_aggregate_selector_surface.py discovers every immediate component README, asserts 56 files and 31 classified removed/history references, requires four backend bare-binding anchors, and reports zero current examples."
reverify: "python3 tools/check_public_aggregate_selector_surface.py"
---

The `.12.1.9` public checker was correct for every file it enumerated, but its inventory was incomplete: it fixed
root project documents, capability documentation, and every mdBook source file without scanning backend entry
documents. That allowed runtime and executable-source retirement to be complete while four public backend READMEs
still described retired selector reads and mutations as current.

Follow-up `.12.1.10` migrates all 14 exact forms to bare typed reads, `set`, `copy`, `push`, `set_key`, and mutable
three-argument `split`. The checker now discovers `*/README.md` at the repository component level, deduplicates the
already-fixed capability README, and scans those files beside root documents and mdBook sources. Exact file and
classified-reference counts make inventory growth deliberate; backend-specific bare-binding anchors ensure the
entry documents teach the replacement, not merely avoid the removed spelling.
