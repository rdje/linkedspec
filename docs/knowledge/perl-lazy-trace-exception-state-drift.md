---
id: perl-lazy-trace-exception-state-drift
title: "Lazy Perl trace detail callbacks overwrite the caller's exception state"
answers:
  - "why does a Perl trace detail callback clear dollar at"
  - "does a throwing lazy trace callback replace an existing Perl exception"
  - "which task preserves Perl exception state across lazy trace details"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","trace","exceptions"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.24. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/Trace.pm"
  - "sed -n '398,439p' perl/LinkedSpec/Trace.pm"
---

# Lazy Perl trace detail callbacks overwrite the caller's exception state

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.24](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

An incoming $@ survives quiet trace and plain detail. A successful lazy detail callback changes it to empty; a throwing callback replaces it with its own detail error. Trace's callback eval at 423 is not localized.

The repair must preserve the incoming exception, including object identity, while retaining lazy/quiet behavior, callback failure handling, nested trace, and parser context. This is separate from JSON::PP displaying a retained blessed diagnostic as null; that display behavior does not establish exception loss.

Sources: `perl/LinkedSpec/Trace.pm`.
