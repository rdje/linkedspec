---
id: recognition-transaction-bound-commit-authoring
title: Portable recognition commit authoring binds its staged payload and bare commit is not a recognized Perl terminal
answers:
  - "why does bare recognition_commit get recognition_terminal_required in Perl"
  - "how should a progress fixture author recognition_commit portably"
date: 2026-10-28
status: frozen authored form confirmed during39.9.1
tags: [perl, recognition, commit, grammar, policy, fixture-qualification]
evidence: "perl-blind-falsey-intake.json.gz retains initial bare-commit source/Get/emitted structured diagnostic, frozen contract and corrected bound-commit baseline/GREEN typed progress control."
reverify: "Read capability_conformance/recognition_transaction_contract.json authored_surface.commit; bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/repeated_blind_falsey_group.t"
---

The canonical authored_surface.commit is payload = recognition_commit(tx).
The bound expression exposes staged payload after token invalidation. A bare
recognition_commit(tx) statement in a new Perl progress fixture is not recorded
as the required terminal: public Get rejects compilation and emitted-source
API reports detail recognition_terminal_required. RecognitionTransactionPolicy
_validate_transaction_shape requires a RECOGNITION_COMMIT/ROLLBACK event on
every path. The corrected bound form compiles and reaches the intended live
zero-progress error. Do not count the initial compile rejection as runtime RED,
infer a new policy, or copy other backend permissiveness into portable fixtures.
Other source/value/transaction behavior is unassessed by this qualification.
