---
id: dart-perl-blind-postcall-return-gap
title: Repeated blind post-call return scope and retv differ between Dart and the Perl reference
answers:
  - "what isolated post-call defects were found in Dart and Perl at39.2.5"
date: 2026-10-28
status: original binding/scope/progress repairs complete39.2.5.1-.2; reference falsey acceptance39.9 remains
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

12-source18-input public intake now distinguishes two defects. Published
latest-child retv applies in attached blind code and IT: Perl post_effect
collects[null,null], Dart[A,A]; plain/IT retv is null in Perl while E control
returns A. Constant block/fluent OR{2}/AND{2} returns two[C,position] values
in Perl on aa, but Dart exits at first. Actual recognize_once post-call zero
returns[true,C,0] on Dart and typed recognition_zero_progress_repetition in
Perl. Same12 raw sources, each backend native/fresh routes agree internally;
no peer inference. No new contract is needed: reference retv binding.5.1 then
Dart repeated return/count/minimum/progress.5.2 are immediate P1 repairs.
Packet blind-postcall-intake.json.gz retains exact producers/emission/results/
modules/receipt. Earlier gap packet remains frozen.

39.2.5.1 now fixes reference latest-child binding; current mechanism/proof:
[[perl-blind-latest-child-retv-binding]]. Original intake remains frozen, not
current reference behavior. Dart repeated return/count/minimum/progress.5.2
remains immediate P1; retv is no longer a prerequisite blocker.

39.2.5.2 now repairs Dart repeated blind post-call return/count/minimum/progress:
[[dart-blind-postcall-iteration-outcomes]].18 sources27 inputs5healthy13RED
->18pass, combined122pass no skips.24 fixed-reference pairs agree;3 falsey aa
reference results expose separately owned39.9 accepted-vs-value predicate defect.
It is immediate before peers/admission; original two defects are repaired,
without blessing the remaining reference falsey outputs.
