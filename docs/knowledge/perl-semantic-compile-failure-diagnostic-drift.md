---
id: perl-semantic-compile-failure-diagnostic-drift
title: "Perl static semantic projection can replace the actual compile failure with a blank dependency error"
answers:
  - "why does recognition_token_escape appear as dependency_target_missing in Perl semantics"
  - "why is a failed Perl semantic dependency diagnostic target blank"
  - "which task preserves actual compilation failures in semantic projection"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","semantic","diagnostics"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.23. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/SemanticStaticProjection.pm"
  - "sed -n '314,345p' perl/LinkedSpec/SemanticStaticProjection.pm"
  - "sed -n '392,432p' perl/LinkedSpec/SemanticStaticProjection.pm"
---

# Perl static semantic projection can replace the actual compile failure with a blank dependency error

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.23](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

Get correctly rejects a bare recognition-token escape, but SemanticStaticProjection produces dependency_target_missing with a blank target and an uninitialized warning. A genuinely missing-rule control produces the correct dependency diagnosis.

The failed-compilation path assumes dependency failure regardless of the recorded cause. The repair must retain the actual failure class and source evidence, or use an honest unclassified fallback; it must preserve the valid unknown-rule case and supported generated/MCP projections.

Sources: `perl/LinkedSpec/SemanticStaticProjection.pm`.
