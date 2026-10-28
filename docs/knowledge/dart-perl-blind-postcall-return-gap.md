---
id: dart-perl-blind-postcall-return-gap
title: Repeated blind post-call return scope and retv differ between Dart and the Perl reference
answers:
  - "does a repeated blind post-call return exit the Dart rule or one iteration"
  - "why does Perl repeated blind post-call retv return null while Dart returns a child value"
date: 2026-10-28
status: open P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.2.5 immediately after implicit collection before peers/admission
tags: [dart, perl, blind-call, repetition, return-scope, retv, authority-gap]
evidence: "dart-blind-collection-intake.json.gz retains postcall_return public Perl native/fresh/emitted and Dart native/restored/plan/fresh baseline; read_dart_blind_postcall.py retains exact generated owner locations."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/verification/probe_dart_blind_collection_postcall.pl; cd dart && bash ../tools/run_dart_project_data.sh test test/blind_repetition_collection_test.dart --name postcall_return"
---

For Top::OR{2} with =>First {return(["POST",retv,cursor_pos()])},
=>Second, anchored First /a/ returning A and Second /b/ returning B, input ab
returns[POST,A,1] at1 on Dart native/restored/plan/fresh. Perl public native and
fresh emitted execution both returnnull at1 without errors. This added probe
is a Dart compatibility control, not a cross-backend expected-value oracle.

Actual emitted Top defines an inner or_code closure. The explicit post-call
return leaves that closure; the outer REP_BCODE loop continues toward min2.
The second attempt returns an Array without consuming at1 and fails the minimum
via its no-progress branch. Emission assigns the child result to $Top, while
the declared $retv is unbound in the explicit returned Array. Dart instead
sets context.retv from the child, throws whole-rule _ActionReturn from
_executeBlindOnce and catches it in _executeRule before repeated accounting.
These are distinct control-flow and value-binding questions; no peer bug or
intended contract is inferred from the discrepancy alone.

P1 owner39.2.5 immediately follows bounded implicit collection39.2.4, before
Julia/safe Lua and portable admission. Reconcile published child-result/retv,
post-call/code/fluent and return contracts, then distinguish failed-child effects,
per-iteration/group outcomes, minimum/progress and lifecycle authority with public
probes. Fix established defects in separately owned bounded slices. Current
implicit collection preserves existing Dart post-call behavior only; neither
this output nor reference unbound retv is blessed as portable authority.
