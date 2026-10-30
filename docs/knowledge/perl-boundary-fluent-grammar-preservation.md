---
id: perl-boundary-fluent-grammar-preservation
title: Early boundary values must preserve missing-slot fallback before AST assignment serialization
answers:
  - "why did early capture_until_boundary methods accept malformed empty argument slots"
  - "how are boundary grammar rejection and error phase preserved after fluent lowering"
  - "why does a compiled-function baseline require CV origin rather than GV origin"
  - "which boundary candidate and final test epochs actually passed"
date: 2026-10-30
status: bounded Perl53.1 grammar regression repaired; original oracles unchanged
tags: [perl, boundary, fluent, grammar, source, fallback, provenance]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.53.1; boundary-capture-string-perl-intake.json.gz retains8RED/3healthy→initial11GREEN, candidate quoted25/3, intermediate source/results and final selected feature3/quoted28 plus exact origin-bound old/current3 slot comparisons."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/nested_boundary_quoted_labels.t; run t/boundary_capture_fluent_results.t through the same wrapper for the normal."
---

Generic AST assignment serialization canonically drops empty boundary argument
slots. Before53.1 its emitted raw capture_until_boundary(end) fallback still
failed during handler evaluation. New early source admission initially made
three malformed calls succeed. The preserved native body alone cannot guard
lexical source membership: the original AST must be checked before serializing.

The final per-RHS private compiler context recognizes unaccepted lexical boundary
calls and retains their existing canonical raw fallback at the binding-source
boundary. Re-entering the bound assignment callback would lose that source
guard. The pure serializer and all old quoted-case oracles stay unchanged.
Actual activation and final substitutions for all three slots are byte-identical;
each fails at rule_handler_eval. Zero arguments remain separately governed.

An @INC hook was not consulted by actual owner loading and gets no baseline
credit. GV FILE identifies the existing glob declaration, so its initial origin
check refused. Final fresh-process read-only loading of exact activation modules
checks B CV FILE code origins before/after Get, module byte hashes, primitive
success and the distinguishing old direct coalesce failure. Working-tree code
is never swapped. These are exact diagnostic controls, not full historical or
portable admission. Initial feature11 passed; after grammar repair final selected
feature3 and complete quoted28 pass. No final11 combined rerun is claimed.
