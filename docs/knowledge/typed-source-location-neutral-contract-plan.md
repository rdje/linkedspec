---
id: typed-source-location-neutral-contract-plan
title: The typed source-location neutral contract is executable and the Perl, Rust, Dart, and Julia runtimes are admitted
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
  - "how many typed source location rollout legs and mutations are current after Perl admission"
  - "how many typed source location rollout legs and mutations are current after Rust admission"
  - "how many typed source location rollout legs and mutations are current after Dart admission"
  - "how many typed source location rollout legs and mutations are current after Julia admission"
date: 2026-08-01
status: neutral artifact, public teaching/recomposition, and Perl/Rust/Dart/Julia runtimes complete; 7 of 14 rollout legs complete
tags: [architecture, source-location, spans, cursor, helpers, recursion, conformance, mdbook, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.1.0 retrieved ADR 0056 and adjacent contracts before using LinkedSpec::Get, return_descriptor, and call_spec_handler_subst. Live decoded Unicode input é\\n🙂x is four scalar positions over eight UTF-8 bytes; direct/mutual non-progress recursion returns undef through the current guard without structured last_error. The modern helper inventory is 47 capture/mark + 30 entry/match + 11 input/cursor + 4 cursor-control = 92 canonical calls. Executable .14.1.1 proof corrects the preliminary alias classification to seven callable compatibility aliases plus two internal contract/scanner ids whose recognized spellings are canonical capture_take and capture_take_len. The task tree freezes the exact v1 contract/checker paths, fixture/diagnostic/mutation counts, CI routing, rollout order, and public page set."
evidence_update_2026_08_01_public_rollout: "Public structure .14.1.2 and unchanged recomposition .14.1.3 are complete. Correction .14.2.0.1 promotes both live rows, advances current truth to 3 complete / 11 pending, and protects each with an independent completed-to-pending regression among 37 mutations. Runtime values remain future."
evidence_update_2026_08_01_perl_admission: "Perl runtime .14.2.1.3 is canonically admitted without a public authored-value surface. Both committed consumers are required, syntax-checked, and unconditionally executed; together they pass 10 tests over exact values, 92 helper projections plus seven aliases, and live plus independently emitted/loaded generated routes. Only perl_runtime moves to complete, so current truth is 4/10 with 38 mutations. Rust, Dart, Julia, PUC Lua, LuaJIT, public typed values, and transactions remain future."
evidence_update_2026_08_07_alias_targets: "Rust prerequisite correction .14.2.2.0.1 fixes two mislabeled neutral alias targets without changing the seven-alias inventory, rollout 4/10, or 38-mutation total: capture_from_rule_start maps to zero-argument capture_slice, and capture_len_from_rule_start maps to capture_slice_len. The checker compares exact Perl diagnostic, IR, and runtime-lowering identity and rejects regression to the arity-wrong named-mark target capture_from."
evidence_update_2026_08_07_rust_admission: "Rust admission .14.2.2.3 is already committed and canonically executed as four ordinary tests over immutable values plus exact 92+7 projections. Only rust_runtime moved to complete, advancing the artifact/checker to 5 complete / 9 pending / 39 mutations with its own completed-to-pending regression. FUTURE-PARITY-BACKLOG.14.2.3.0.2 corrects this card's previously stale Perl-only/4-of-14 summary without changing the neutral artifact or rollout state."
evidence_update_2026_08_07_dart_admission: "Dart admission .14.2.3.3 moves its unchanged four-test consumer into ordinary and canonical discovery and promotes only dart_runtime. The independent checker locks that path and command, rejects retained dormancy and Dart complete-to-pending regression, and advances current truth to 6 complete / 8 pending / 40 mutations without a production or public-value change."
evidence_update_2026_08_07_julia_admission: "Julia admission .14.2.4.3 moves the unchanged 127-assertion consumer into ordinary package discovery, runs it unconditionally through the exact repository-routed Julia command in canonical CI, and promotes only julia_runtime. The checker locks the tracked path, exact command, one ordinary include, absence of stale dormancy, and an independent Julia completed-to-pending regression. Current truth is 7 complete / 7 pending / 41 mutations without a production-runtime, helper-result, register, carrier, schema, semantic/MCP, DSL, README, other-backend, or public authored-value change."
evidence_update_2026_08_07_julia_admission_signoff: "Julia admission signoff keeps the sole-facing mdBook synchronized across five pages; its repository-routed build is 79 files/14172 KiB and direct HTML inspection proves separate status, command, rollout, and limitation blocks. Knowledge Map is 787/6467 and all seven doctrines pass. Definitive canonical CI proves capability 80/0/0, typed source 7/7/41 with Perl 10, Rust/Dart 4/4, and Julia 127/127, byte-fresh MCP bindings, every composed semantic/MCP admission, six-family containment, relocated/moved/outside-CWD execution, CLI 66x2, RAM 79%, and Phase 0 1031/1031 in 716 seconds before the exact local-CI pass marker."
reverify: "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && (cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart) && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/typed_source_location_contract_test.jl\")' && perl -Iperl -MLinkedSpec -e 'for my $h (qw(capture_take capture_take_len capture_take_slice capture_take_slice_len)) { print qq{$h => }, LinkedSpec::call_spec_handler_subst(q{Top}, qq{return($h())}), qq{\\n} }' && rg -n 'complex regex|Single regex|recursive regex|single-regex multi-classification' docs/linkedspec-book/src/specs-and-corpora"
---

The first executable artifact is
`capability_conformance/typed_source_location_contract.json`, identified as
`linkedspec-typed-source-location-v1`. Its independent validator is
`tools/check_typed_source_location_contract.py`; canonical execution must route that checker through
`tools/run_python_project_data.sh` without a new driver or off-volume scratch path.

The frozen neutral envelope has three decoded sources, seven position conversions, six direct spans, three derived
text/provenance cases, eight invocation-state transitions, eight transaction transitions, six recursive-observation
cases, four structural-authoring cases, 92 canonical helper projections, seven callable compatibility aliases,
two internal contract ids, 31 exact diagnostic/negative fixtures, 14 rollout legs, and 41 independent mutations.
This defines target semantics without selecting DSL spelling or claiming non-admitted backend implementation.

The 92 modern current helpers divide into 47 capture/mark, 30 entry/match, 11 input/cursor, and four explicit cursor
controls. Perl retains seven callable aliases: `capture_from_rule_start`, `capture_len_from_rule_start`,
`capture_rest_length`, `capture_slice_here`, `capture_slice_length`, `entry_named_map`, and `match_named_map`.
The first two are zero-argument compatibility names for anonymous `capture_slice` and `capture_slice_len`, not
one-argument named-mark `capture_from` and `capture_len_from` helpers.
`capture_take_slice` and `capture_take_slice_len` are internal record ids, not callable aliases; their records
recognize canonical `capture_take()` and `capture_take_len()`. Legacy capture macros remain a separate compatibility
surface. Perl, Rust, Dart, and Julia helpers now project through internal typed values while preserving those public
results; public authored typed values and the PUC Lua and LuaJIT runtimes remain future.

Current rule behavior supports the public teaching direction: zero-regex coordinators, one-regex leaves,
two-regex start/end nodes, regex-bearing entry rules, and recursive linked graphs all execute. Same-position direct
or mutual recursion is already cut, but today that path yields `undef` plus a trace decision rather than the future
portable structured diagnostic.

Public alignment is complete under `FUTURE-PARITY-BACKLOG.14.1.2`, and unchanged neutral/public recomposition is
complete under `.14.1.3`. The rule-paragraph and regex chapters teach the structural roles. The portmap
walkthrough's three complex-regex passages, the EBNF walkthrough's recursive-regex passage, and the shipped-spec
reading-order phrase describe current compatibility material rather than preferred general authoring. Perl runtime
admission `.14.2.1.3`, Rust admission `.14.2.2.3`, Dart admission `.14.2.3.3`, and Julia admission `.14.2.4.3`
advance the current ledger to 7 complete / 7 pending with 41 mutations. Internal Perl/Rust/Dart/Julia values and
projections are current; public authored values, transactions, and the PUC Lua and LuaJIT runtimes remain future.
