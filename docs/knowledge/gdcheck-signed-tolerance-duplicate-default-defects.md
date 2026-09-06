---
id: gdcheck-signed-tolerance-duplicate-default-defects
title: "gdcheck mishandles negative tolerance intervals, duplicate rows, and DEFAULT cardinality"
answers:
  - "why does gdcheck mark equal negative numbers outside tolerance"
  - "why does gdcheck skip duplicate added or removed rows"
  - "why does gdcheck accept zero or two DEFAULT patterns"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","utility","comparison"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.25. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/gdcheck.pl"
  - "rg -n 'tol|DEFAULT|length\\(@EVAL\\)|\\[0\\]' perl/gdcheck.pl"
---

# gdcheck mishandles negative tolerance intervals, duplicate rows, and DEFAULT cardinality

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.25](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

With tolerance 10, equal -100 values are marked below, and -100 to -95 is marked above; the positive twins are unmarked. The margin multiplies the signed baseline and reverses the intended interval.

Duplicate additions/removals use only each key's first indexed row. Two removed rows receive only the first removal mask, and adding two rows preserves only one. DEFAULT accepts zero and two patterns because length(@EVAL) measures the decimal string length of the count.

The three owned repairs separately cover signed/zero boundaries, every duplicate row and stable correspondence, and exactly-one DEFAULT cardinality. None is recorded as fixed by the diagnostic intake.

Sources: `perl/gdcheck.pl`.
