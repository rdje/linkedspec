---
id: perl-quoted-primitive-rewrite-event-drift
title: "Quoted set text can be rewritten and counted as an assignment"
answers:
  - "why does quoted set text change during Perl primitive rewriting"
  - "why does quoted helper-looking text contribute a canonical ASSIGN event"
  - "which task owns lexical primitive rewrite and event repair"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","actionir","lexical"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.18. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm perl/LinkedSpec/ActionIR/RewritePipeline.pm perl/LinkedSpec/ActionIR/CanonicalEvents.pm"
  - "sed -n '132,150p' perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm"
  - "sed -n '249,267p' perl/LinkedSpec/ActionIR/CanonicalEvents.pm"
---

# Quoted set text can be rewritten and counted as an assignment

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.18](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

A quoted value containing set(counter, 2) was modified even though no executable set call was present. It also contributed a false ASSIGN event. These are distinct observable failures in source rewriting and canonical metadata.

The primitive matcher operates on unmasked text and the rewrite performs raw substitution. CanonicalEvents independently scans the same quoted spelling. The repair must use lexical/source ownership, retaining literal, regex, comment, nested-call, and genuine-assignment controls.

Sources: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`, `perl/LinkedSpec/ActionIR/RewritePipeline.pm`, `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`.
