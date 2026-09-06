---
id: startup-public-teaching-checker-blind-spots
title: "Startup reading found concrete public teaching gaps behind passing checkers"
answers:
  - "which startup tasks own contradictory book prose missed by public checkers"
  - "why do public no-drift checks pass stale logical and mutation paragraphs"
  - "why does the book introduction still call parse_job unavailable"
  - "why do old semantic rollout counts pass the public checker"
  - "are definedness helpers condition only in Perl return contexts"
  - "does exit_now terminate the Perl host process"
  - "does cat treat a null argument as empty text"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","book","contracts","verification"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.28. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- tools/check_logical_helper_contract.py tools/check_mutation_public_surface.py tools/check_staged_ast_enrichment_contract.py tools/check_semantic_introspection_contract.py tools/check_diagnostic_output_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_mutation_public_surface.py"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_diagnostic_output_contract.py"
---

# Startup reading found concrete public teaching gaps behind passing checkers

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.28](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

Five public checkers passed while their governed teaching retained specific false current claims. The intake records each actual paragraph, the checker function or scope that accepts it, and independent authority or runtime controls.

- `.28.1`: stale string-zero/empty-container truthiness and pending rollout text; exact denial coverage misses it.
- `.28.2`: stale remaining-backends hash-selector interpretation; whitespace is already normalized, but the actual denial is missing.
- `.28.3`: the introduction calls portable parse_job unavailable; that page is absent from the staged public-authoring reader set.
- `.28.4`: an included semantic page says the ledgers are now 3/9 and 2/6; the actual checker accepts it despite current 9/9 and 6/6 authority.
- `.28.5`: returned and nested definedness work on Perl despite condition-only catalog entries. True/false results were 1/empty string; no portable encoding promise follows. cat with null or an array returns null; the empty-string twin produces concatenated text.
- `.28.6`: exit_now raises a typed parse-control object while the host can continue; the catalog's process-exit sentence passes diagnostic public checks.

Each child requires the real bad paragraph and controlled variants, honest historical scope, appropriate executable examples, and the necessary checker repair. Passing finite checks is recorded as their measured scope, not evidence that these paragraphs are correct.

Sources: `tools/check_logical_helper_contract.py`, `tools/check_mutation_public_surface.py`, `tools/check_staged_ast_enrichment_contract.py`, `tools/check_semantic_introspection_contract.py`, `tools/check_diagnostic_output_contract.py`.
