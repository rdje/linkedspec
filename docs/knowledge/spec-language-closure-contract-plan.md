---
id: spec-language-closure-contract-plan
title: Language closure distinguishes authored operations, scopes, caller authority and proof limits
answers:
  - "what may a self contained spec compute observe mutate and return"
  - "where is the language closure matrix and freeze plan"
  - "do rules pure functions and deferred codeblocks share the same scope"
  - "does recognition rollback restore arbitrary user state or AST"
  - "does child parsing satisfy parent cursor progress"
  - "does language closure select a global depth or step limit"
  - "does diagnostic output grant authored stdout filesystem or network access"
  - "which boolean and dynamic callback repairs qualify language closure"
date: 2026-10-01
status: source-located design; normative freeze and composed admission remain pending
tags: [language-readiness, closure, scopes, authority, progress, failure, resources]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1 reviews sixteen existing authority identities/semantic anchors and supplemental startup19/21/35/39 ownership. docs/language-readiness/closure-contract-matrix.md separates target, finite current evidence, partial exceptions and unassessed requirements; no runtime, contract, admission or numerical limit changes."
reverify:
  - "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
  - "bash tools/run_mdbook_local.sh"
---

The canonical design is `docs/language-readiness/closure-contract-matrix.md`.
Its sixteen-row register locates existing JSON identities and semantic fields.
The two inventories and [[three-objective-language-readiness]] supply dated finite
evidence, while [[finite-language-readiness-gap-selection]] retains repair owners
and unassessed objectives. Listing an admitted family does not erase a narrower defect.

Rule invocation, fresh pure-function scope and invocation-time deferred-codeblock
scope differ. Recognition tokens restore cursor/boundary/marks under a closed
effect policy; they do not roll back arbitrary AST or user state. Nested writes
publish from a post-expression snapshot, leaf callbacks preserve completed unrelated
effects, and continuations follow commit. Staged publication has its own failure policies.

Diagnostic helpers deliver typed events to an optional caller sink and are quiet
without it. Their events are separate from parse results and trace; authored code
does not choose a host destination. Caller-authorized input, precompiled registries
and operational grants remain host responsibilities. Private progressive admission
does not establish an outward API or parent cursor progress.

Recognition/observation progress is stricter while those scopes are active.
Ordinary recursion/iteration, regex resources and general failure projections need
their own review; historical threshold prose is not a newly admitted global limit.
Caller cancellation/deadline/sink behavior belongs in the deterministic input model.
Source-detail interpretation remains startup37.2-owned. Ambient non-authority is
an accepted design boundary, without a sandbox-security claim.

Already-owned dynamic receiver writes, token lexical order, codeblock boolean
literals and recognition-commit boolean kinds supplement the finite ledger's
exceptions under startup19/21/35/39. Their reading/policy prerequisites remain.
No new runtime defect or missing primitive is selected by this synthesis.
ADR0042's stale pending header/index now routes current rollout to its executable
neutral authority; its decisions and admitted8/0 state stay unchanged. Historical
ordinary-recursion probes likewise retain their dates and separate current scopes.

Next `.1.2.2` freezes operation/scope/reference structure with independent
mutation-sensitive governance; `.1.2.3` owns deterministic/resource/failure policies,
and `.1.2.4` independently reconciles the parent through canonical proof.
[[spec-language-self-containment-and-ebnf-profile]] retains the later optional frontend.
