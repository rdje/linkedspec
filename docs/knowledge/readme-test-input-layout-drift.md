---
id: readme-test-input-layout-drift
title: README test_input root was introduced without a matching repository path
answers:
  - does LinkedSpec have a root test_input directory
  - why does README mention test_input
  - which commit introduced the stale README test_input path
  - where are LinkedSpec test fixtures actually stored
  - what task owns correcting the stale README layout route
date: 2026-08-09
status: corrected and canonically verified by README-STABILITY-POLICY.4.1
tags: [readme, navigation, repository-layout, fixtures, drift]
evidence: "Route-existence audit at clean 7c2ff407 finds README.md advertises root test_input/ although neither current HEAD nor ca846e7a^ contains it. git blame and git log -S assign the line only to original bounded-README adoption ca846e7a; no Git deletion/rename exists. README-STABILITY-POLICY.4.1 removes only that marker, leaving t/ and tests/, and its resulting-tree checker rejects missing or symlinked local route targets as part of the 32/32 mutation corpus."
last_verified: 2026-08-09
reverify:
  - "test ! -e test_input && test -d t && test -d tests"
  - "git log --all --oneline -S'test_input/' -- README.md"
  - "rg -n 'test_input/' README.md docs/tasks/README-STABILITY-POLICY.md"
---

# Stale README fixture path

Root `test_input/` was not removed or renamed: it never existed at the parent of the original bounded-README
adoption and does not exist now. Commit `ca846e7a` synthesized it while compacting the repository layout table.
The real top-level fixture/test roots are `t/` and `tests/`; specialized Pgen input material is nested within its
own subsystem. The route-closure implementation has removed the stale marker and makes all local reader routes
prove existence, non-symlink identity, and target-surface ownership so this class cannot recur.
