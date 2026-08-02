---
id: typed-source-location-neutral-contract-plan
title: The typed source-location neutral contract is executable while runtime values remain future
answers:
  - "what exact contract implements the typed source location algebra"
  - "where will the typed position and span neutral fixtures live"
  - "what does FUTURE-PARITY-BACKLOG 14.1.1 create"
  - "how many typed source location fixtures and mutations are planned"
  - "which current source boundary helpers project over the typed algebra"
  - "how many canonical capture mark entry match input cursor helpers exist"
  - "which source boundary compatibility aliases remain"
  - "are capture_take_slice and capture_take_slice_len callable aliases"
  - "does Perl currently return typed source location values"
  - "are non progressing recursion diagnostics current behavior"
  - "how does the typed source location checker run in local CI"
  - "which mdBook pages teach zero one two regex rule structure"
  - "which mdBook passages still praise complex or recursive regexes"
  - "how should portmap and EBNF walkthroughs describe complex regexes"
  - "what is the rollout order after the typed source location contract"
date: 2026-08-01
status: neutral artifact, public teaching, and recomposition complete; 3 of 14 rollout legs complete; runtime values pending
tags: [architecture, source-location, spans, cursor, helpers, recursion, conformance, mdbook, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.1.0 retrieved ADR 0056 and adjacent contracts before using LinkedSpec::Get, return_descriptor, and call_spec_handler_subst. Live decoded Unicode input é\\n🙂x is four scalar positions over eight UTF-8 bytes; direct/mutual non-progress recursion returns undef through the current guard without structured last_error. The modern helper inventory is 47 capture/mark + 30 entry/match + 11 input/cursor + 4 cursor-control = 92 canonical calls. Executable .14.1.1 proof corrects the preliminary alias classification to seven callable compatibility aliases plus two internal contract/scanner ids whose recognized spellings are canonical capture_take and capture_take_len. The task tree freezes the exact v1 contract/checker paths, fixture/diagnostic/mutation counts, CI routing, rollout order, and public page set."
evidence_update_2026_08_01_public_rollout: "Public structure .14.1.2 and unchanged recomposition .14.1.3 are complete. Correction .14.2.0.1 promotes both live rows, advances current truth to 3 complete / 11 pending, and protects each with an independent completed-to-pending regression among 37 mutations. Runtime values remain future."
reverify: "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && perl -Iperl -MLinkedSpec -e 'for my $h (qw(capture_take capture_take_len capture_take_slice capture_take_slice_len)) { print qq{$h => }, LinkedSpec::call_spec_handler_subst(q{Top}, qq{return($h())}), qq{\\n} }' && rg -n 'complex regex|Single regex|recursive regex|single-regex multi-classification' docs/linkedspec-book/src/specs-and-corpora"
---

The first executable artifact is
`capability_conformance/typed_source_location_contract.json`, identified as
`linkedspec-typed-source-location-v1`. Its independent validator is
`tools/check_typed_source_location_contract.py`; canonical execution must route that checker through
`tools/run_python_project_data.sh` without a new driver or off-volume scratch path.

The frozen neutral envelope has three decoded sources, seven position conversions, six direct spans, three derived
text/provenance cases, eight invocation-state transitions, eight transaction transitions, six recursive-observation
cases, four structural-authoring cases, 92 canonical helper projections, seven callable compatibility aliases,
two internal contract ids, 31 exact diagnostic/negative fixtures, 14 rollout legs, and 37 independent mutations.
This defines target semantics without selecting DSL spelling or claiming backend implementation.

The 92 modern current helpers divide into 47 capture/mark, 30 entry/match, 11 input/cursor, and four explicit cursor
controls. Perl retains seven callable aliases: `capture_from_rule_start`, `capture_len_from_rule_start`,
`capture_rest_length`, `capture_slice_here`, `capture_slice_length`, `entry_named_map`, and `match_named_map`.
`capture_take_slice` and `capture_take_slice_len` are internal record ids, not callable aliases; their records
recognize canonical `capture_take()` and `capture_take_len()`. Legacy capture macros remain a separate compatibility
surface. Current Perl helpers still lower to host cursor/string operations; typed values are future.

Current rule behavior supports the public teaching direction: zero-regex coordinators, one-regex leaves,
two-regex start/end nodes, regex-bearing entry rules, and recursive linked graphs all execute. Same-position direct
or mutual recursion is already cut, but today that path yields `undef` plus a trace decision rather than the future
portable structured diagnostic.

Public alignment is complete under `FUTURE-PARITY-BACKLOG.14.1.2`, and unchanged neutral/public recomposition is
complete under `.14.1.3`. The rule-paragraph and regex chapters teach the structural roles. The portmap
walkthrough's three complex-regex passages, the EBNF walkthrough's recursive-regex passage, and the shipped-spec
reading-order phrase describe current compatibility material rather than preferred general authoring. The current
ledger is therefore 3 complete / 11 pending; typed runtime values remain future.
