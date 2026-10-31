---
id: perl-constructor-result-guards
title: Perl retained constructor results guard consumers and lower computed Hash keys
answers:
  - "which Perl owner guards retained Array and Hash constructor result methods"
  - "why did a Hash key action block fail Perl handler compilation"
  - "can a computed Hash key call use typed helpers and local returns"
  - "do constructor guards skip later with bodies but retain empty inputs"
  - "does typed computed Hash key repair change bare tag key spelling"
date: 2026-10-31
status: bounded Perl61.1 targeted-checked; Rust61.2/peers/full admission separate
tags: [perl, constructors, hash, array, keys, source, guards, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.61.1; constructor-perl-intake.json.gz retains actual19/23/selected4/final25 epochs, public original/candidate module/source probes and nearest/syntax."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/constructor_result_composition.t t/free_default_result_composition.t t/uniform_binding_contract.t"
---

Original typed constructor payloads/direct reads work, but emitted-result source
admission omits constructors. Retained canonical ordinary Array/paired Hash calls
now use existing guards at each link and existing immediate-with rejection state.
Invalid operands/later bodies skip, empty/null inputs still enter with; source
effects, local returns, snapshots/functions/kinds and error causality stay.

Public substitution locates a separate producer defect: Hash constructor keys
sent computed block/call source through raw tag normalization, unlike values.
Typed computed keys now reuse the existing value lowerer; bare/literal key tags,
original pair/splice/odd/malformed/retired-selector/signature policies stay.
Original19 baseline14healthy5RED, candidate18PASS1RED; expanded23 baseline18PASS5RED
and selected4 baseline2PASS2RED precede key edit. Same final25 passes,23 values/
original13/candidate17/expanded17 healthy observations/inherited error exact,
eight excluded AST/lowerings unchanged. Nearest defaults/binding/syntax pass.
The first -I overlay was overridden by facade path insertion; only explicit
preload plus observed module identity/source bytes establishes original behavior.
Diagnostic stdout precedes JSON on compilation errors; actual bytes preserved,
final JSON decoded without replay. No setup RED/full25 baseline/lifecycle/peer
admission claim. Regenerate emitted Perl; registration23.4.1 remains separate.
