---
id: repo-generated-artifact-cleanup-boundary
title: Parent-repo artifact cleanup may delete ignored Rust target and mdBook output, but not rgx corpus logs/binaries
answers:
  - "which generated artifacts are safe to delete for disk cleanup"
  - "can I delete rust target to recover space"
  - "can I delete docs/linkedspec-book/book"
  - "should cleanup delete rgx log files"
  - "should cleanup delete rgx bin files"
  - "what did REPO-HYGIENE.3 remove"
date: 2026-07-07
status: accepted
tags: [repo-hygiene, artifacts, cleanup, rust, mdbook, rgx, task-tree]
evidence: "REPO-HYGIENE.3 scanned the parent checkout for logs, macBinary `.bin` archives, temp artifacts, mdBook output, and Rust target directories. `git check-ignore -v rust/target docs/linkedspec-book/book` showed both generated directories are ignored, `git ls-files` showed they are untracked, `du -sh` measured `rust/target` at 5.2G and `docs/linkedspec-book/book` at 7.0M, and both were removed. `.log`/`.bin` hits under `rgx/` were preserved because they live in submodule stimulus, fixture, or issue-artifact trees and are not 100% safe parent-repo cleanup targets."
reverify: "git check-ignore -v rust/target docs/linkedspec-book/book; git ls-files rust/target docs/linkedspec-book/book; find . -path './.git' -prune -o -path './rgx' -prune -o -type f \\( -name '*.log' -o -name '*.bin' -o -name '*.tmp' -o -name '*.bak' -o -name '.DS_Store' -o -name '*.swp' \\) -print"
---

# Repo Generated Artifact Cleanup Boundary

`rust/target` and `docs/linkedspec-book/book` are ignored, untracked, rebuildable generated outputs in the parent
checkout. They are safe cleanup targets when disk space matters.

Do not delete `.log` or `.bin` hits under `rgx/` as part of parent-repo cleanup. Those files are inside the tracked
`rgx` submodule's stimulus, fixture, or issue-artifact corpus. Any pruning there needs an explicit submodule-owned
task and its own status check.
