---
id: ptchange-spaced-input-shell-read-defect
title: "ptchange silently emits empty output for a valid spaced input filename"
answers:
  - "why does ptchange emit empty output for a filename with spaces"
  - "where does ptchange split input paths through a shell"
  - "which task owns ptchange portable and safe file IO"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","utility","paths"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.26. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/ptchange.pl"
  - "sed -n '1,38p' perl/ptchange.pl"
  - "sed -n '125,160p' perl/ptchange.pl"
---

# ptchange silently emits empty output for a valid spaced input filename

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.26](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

An Open3 argv-list caller supplied two identical inputs containing preserved comment text. The plain filename was copied correctly; the spaced filename produced empty output with cat path-splitting errors. Both script invocations exited 0. The caller did not use a shell, and its exact managed fixtures were cleaned.

The script reads with qx(cat $ARGV[0]), uses two-argument output opens, and has a machine-specific shebang. The repair owns shell-free IO, valid path characters, safe failure behavior, compatible transformations, and repository-derived defaults under the reviewed storage policy. Arbitrary command execution was not tested.

Sources: `perl/ptchange.pl`.
