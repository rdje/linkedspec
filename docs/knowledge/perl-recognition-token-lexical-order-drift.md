---
id: perl-recognition-token-lexical-order-drift
title: "Perl recognition escape checks depend on literals and the first compiled token name"
answers:
  - "why does quoted recognition token text report an escape"
  - "why does a warmed Perl compiler accept a later bare recognition token escape"
  - "which task removes token-name regex caching"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","recognition","validation"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.21. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/RecognitionTransactionPolicy.pm"
  - "sed -n '160,205p' perl/LinkedSpec/RecognitionTransactionPolicy.pm"
---

# Perl recognition escape checks depend on literals and the first compiled token name

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.21](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

Quoted token-name text is falsely classified as escape. Separately, compiling token ticket before a bare tx escape makes that later source accept with INVALIDATED/error-null state; the fresh tx case rejects.

The raw token search is not lexical, and the variable-interpolated /o regex at 186–190 caches its first token name. The two repair children cover compilation-order independence and literal/comment exclusion. The probe did not demonstrate runtime escape of active authority.

Sources: `perl/LinkedSpec/RecognitionTransactionPolicy.pm`.
