---
id: rust-staged-call-counter-saturation
title: Saturating Rust staged call admission permits a callback at an exhausted maximum counter
answers:
  - "can Rust staged enrichment run when total_calls and max_calls are u64 maximum"
  - "why does a saturated staged callback counter admit another call"
  - "which task repairs Rust staged call counter exhaustion"
date: 2026-09-07
status: native public authority boundary measured; repair pending under SESSION-STARTUP-READING.75
tags: [rust, staged-parsing, budgets, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.37 compares ordinary exhausted, maximum exhausted and one-remaining public recursive authority using an independent callback counter."
reverify:
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup96-staged-boundaries/probe .linkedspec-data/scratch/startup96-staged-boundaries/call-budget-control"
---

# Exhaustion at the representable maximum is not rejected

StagedRecursiveAuthority::new accepts the optional nonnegative total_calls and positive max_calls as u64.
A synthetic nested marker and ordinary prepared registry run these controls through enrich_recursively:

| total_calls | max_calls | Actual callbacks | Result |
| --- | --- | --- | --- |
| 1 | 1 | 0 | staged_call_limit_exceeded |
| u64::MAX - 1 | u64::MAX | 1 | success; returned total u64::MAX |
| u64::MAX | u64::MAX | 1 | success; returned total still u64::MAX |

dispatch_resource_check at staged_ast_enrichment.rs 1784 computes total_calls.saturating_add(1), then rejects
only if the candidate exceeds max_calls. At MAX/MAX the candidate is unchanged, so admission succeeds and
the independently observed callback is not reflected as an increment. This is a public host configuration
boundary; no enormous workload is needed to reach it. Current-depth entrypoints ignore recursive authority
and serve only as ordinary callback controls in the same harness.

Repair .75 must deny exhaustion before dispatch using checked accounting, preserve ordinary/one-remaining
behavior and cumulative depth semantics, and verify typed errors, exact counters and carriers.
No other backend or release-specific result is inferred. Each local run has exit 0 and empty stderr.
Artifacts, assertions and verified runtime/serde identities are indexed in `staged-target-preparation-gaps.md`.
