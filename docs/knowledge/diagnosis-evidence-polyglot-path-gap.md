---
id: diagnosis-evidence-polyglot-path-gap
title: "Diagnostic evidence path classification omits measured native and test peers"
answers:
  - "does the diagnostic evidence gate cover Dart Julia Lua and tests paths"
  - "which paths are omitted from TASK ACCEPTANCE diagnostic evidence classification"
  - "which task connects diagnosis path coverage with claim verification adoption"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","doctrine","verification","paths"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.29. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- scripts/check_diagnosis_evidence.sh"
  - "sed -n '1,48p' scripts/check_diagnosis_evidence.sh"
---

# Diagnostic evidence path classification omits measured native and test peers

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.29](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

Eight controls executed an extracted copy of the actual is_governed_path function. Perl, Rust, t, and tools examples are accepted; Dart, Julia, Lua, and tests peers are excluded. This is lexical predicate evidence, not a file-existence check or staged-hook mutation test.

The gate's prefix inventory at 21–29 explains the omissions. The owning repair requires actual tracked source/test/contract coverage, documented exclusions, and controlled staged-path RED/GREEN proof. It executes after the full reading and adoption review, before `.5` adoption closeout. The evidence gate must continue to validate recorded evidence without executing Markdown commands.

Sources: `scripts/check_diagnosis_evidence.sh`.
