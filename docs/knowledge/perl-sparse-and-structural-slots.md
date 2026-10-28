---
id: perl-sparse-and-structural-slots
title: Perl AND handlers traverse every authored structural regex slot even when action edges are sparse
answers:
  - "does an AND rule consume regex slots that have no action edge"
  - "how do sparse action slots work in Perl AND rules"
  - "why did capability capture fixtures return null after rule-local cursor migration"
  - "why did and_acode_seq skip an edge-less middle regex"
  - "how does a generated Perl AND handler map sparse actions to structural slots"
  - "why must generated dependency slot maps include edge-less local regexes"
  - "does repeated AND support one sparse action after edge-less regex slots"
  - "why did plain AND with one sparse action skip required local regex slots"
date: 2026-10-28
status: current
tags: [perl, AND, generated-source, regex-slots, actions, cursor, corpus]
evidence: "FUTURE-PARITY-BACKLOG.10.5.0.1.2.0; perl/LinkedSpec/SpecEntry.pm classifies same-owner strictly increasing sparse action refs; perl/LinkedSpec/HandlerVariantEmitter.pm traverses the complete local structural sequence and dispatches only authored action indices; perl/LinkedSpec/Compiler.pm embeds every required local regex in standalone generated source; t/sparse_and_action_slots_perl_regression.t proves live/generated ordinary and repeated AND routes."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/sparse_and_single_action.t t/sparse_and_action_slots_perl_regression.t t/duplicate_regex_slot_identity_perl_contract.t"
---

An authored `AND` or repeated-`AND` rule has two distinct ordered sequences: all
of its regex slots form the structural match sequence, while action edges form a
possibly sparse dispatch sequence. An edge-less regex is still required and is
consumed in its authored position; it simply runs no action.

Perl's consuming handler may use the local structural route only when every
compiled action dependency names the same owner, has a valid strictly increasing
slot index, and the rule has more regex slots than actions. It then matches every
local regex in order and dispatches code only at the authored indices. Cross-rule
dependency sequences retain the ordinary compiled-dependency route. Standalone
generated source must embed every local structural regex needed by that route,
including the one-action repeated case.

The full semantics and author example live in
`docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md`; the generated
implementation boundary lives in
`docs/linkedspec-book/src/compiler/generated-handlers-and-dispatch.md`.

Related: [[perl-rule-local-cursor-rollout-boundaries]],
[[duplicate-regex-slot-identity-contract]], [[rust-perl-output-oracle]].

39.5 repairs the plain multi-regex/one-action eligibility gap using the existing
local_structural_sequence predicate. The public derived family changes from
fallback default to existing and_acode_seq; regenerate old affected standalone
parsers. Compiler already embeds all required local slots; emitter already maps
only authored action indices, so neither changes. Final unchanged15 groups/22
inputs9RED/final15pass, nearest protected15 and syntax pass; exact source/epochs
are retained in sparse-and-single-action-intake.json.gz. Incoming/indexed entry
does not skip child0; cross-owner/reversed/duplicate sequences keep dependency
order.39.6 blind .push fresh recursion and startup27 plain E omission remain
separate. Full portable admission and20.1 historical-ID lookup audit stay open.
