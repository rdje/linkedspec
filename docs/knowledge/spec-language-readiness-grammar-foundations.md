---
id: spec-language-readiness-grammar-foundations
title: Grammar readiness separates admitted foundations from composed format objectives
answers:
  - "what must spec gain before the structured format parsing campaign"
  - "where is the source located language readiness inventory"
  - "does a green capability census prove structured format readiness"
  - "why does the capability manifest still advertise parse mode controls"
  - "which task repairs the stale parse mode capability description"
date: 2026-09-27
status: first four capability dimensions inventoried; composed objectives remain unassessed
tags: [dsl, readiness, grammar, recursion, cursor, capture, conformance]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1 from clean30b2cc3a0 runs seven existing neutral/structural checks: capability100/0/0, language250/105+1/126, root7/0/54, cursor8/0/60, recognition138/250/58, typed14/0/231 and gaps9/0/63. No new backend execution or format support is claimed. The manifest parse-mode description contradicts the specific cursor policy and passes a checker that only requires a general contract string; .1.1.5 owns repair before closure authority."
reverify: "env PERL5LIB= bash tools/project_data_run.sh perl tools/check_capability_conformance.pl && bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py"
---

The canonical finite ledger is `docs/language-readiness/grammar-cursor-capture.md`. It maps grammar entry,
recursion/progress, cursor control, spans/observation and gaps to exact contracts and all five backend consumers.
Neutral checks validate their admitted records; they do not execute every backend or certify composed objectives.
Existing startup .38/.40 recognition defects remain separate from the historical admission status.

The director's September27 north star selects ordinary .spec capabilities before the broad structured-format
campaign. State/callables/control/transformation/results follow under .1.1.2, then natural nesting,
context-dependent syntax and lossless staged extraction probes under .1.1.3. Unassessed objectives are neither
missing-language claims nor supported-format claims. The optional EBNF-like frontend remains later.

The manifest `runtime.top_rule_and_parse_mode_controls.contract` still advertises parse-mode controls.
`rule_local_cursor_contract.json` policy.global_override explicitly removes public overrides. The general checker
requires a nonempty string at validate_manifest; its exact contract guards cover only two mutation rows.
Both current checkers pass. This is a confirmed description/guard gap, not evidence that removed runtime options
work. `.1.1.5` has priority P2 after inventory reconciliation and before `.1.2`, with reason-sensitive regression
and canonical admission required. The specific cursor contract remains authoritative.

Related: [[spec-language-self-containment-and-ebnf-profile]], [[post-parity-structured-text-program]],
[[perl-recognition-unwind-actual-state-gap]], [[current-call-name-inventory-does-not-prove-runtime-semantics]].
