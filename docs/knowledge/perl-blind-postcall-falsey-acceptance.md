---
id: perl-blind-postcall-falsey-acceptance
title: Perl repeated blind post-call falsey payload is incorrectly treated as a failed iteration
answers:
  - "why does Perl repeated blind post-call return zero or null stop after one child"
  - "what additionally blocks Perl repeated blind falsey result parity"
date: 2026-10-28
status: iteration/group39.9.1 and parent completion39.9.2 repaired/targeted-checked; owned Dart gaps/admission remain
tags: [perl, blind-call, repetition, falsey, acceptance, post-call, minimum]
evidence: "dart-blind-postcall-repair-intake.json.gz retains18 public reference sources27 inputs and exact source/emission/results, including OR zero/null and AND early-zero controls; existing binding39.2.5.1 is fixed."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/verification/probe_blind_postcall_repair.pl"
---

After latest-child retv binding39.2.5.1, OR{2} with =>Atom {return(0)} or
return(undef), and Atom anchored /a/ returning A, still yieldsnull at1 on aa
in public Perl native/fresh execution. AND{2} with first-child early return0
also yieldsnull at1. Same nonfalsey constant return controls accept two groups
at2. Actual emitted outer REP_BCODE/REP_AND_BCODE passes raw inner post-call
result to result_is_match; no independent local accepted-group outcome survives
a falsey payload. It is distinct from latest-child binding.

Accepted-vs-payload separation already owns falsey/null group values; see
[[repeated-and-falsey-group-acceptance]]. Existing P1 owner39.9 additionally owns
this per-iteration issue alongside missing completed blind-parent acceptance.
Its schedule is immediately after Dart39.2.5.2 before peer progression/admission.
Fix local acceptance/count/minimum and parent publication through bounded leaves,
preserve real misses/progress/errors/IT/lifecycle/retv/source metadata. Current
Dart repair cannot claim falsey cross-backend parity against broken reference
outputs. No peer defect or new policy is inferred.

39.9.1 now repairs REP_BCODE/REP_AND_BCODE with a fresh loop-local accepted
flag passed to the inner dispatch; only real no-child/required-child miss clears
it. Payload is independent, and flags are outside the authored closure lexical
scope. No global predicate/runtime change.15 valid normal native/fresh groups36
inputs5healthy10actualRED ->15pass; exact sources/v2 metadata, latest-child
retv10 groups11 inputs unchanged and plain emitted sources byte-identical.
Three previously qualified Dart aa rows now match current reference values/
kinds/cursors on exact sources; no full18-current replay claim. Typed live
progress/ordinary zero/custom IT/partial/minimum controls and syntax pass.
Initial bare commit probe is outside frozen bound-commit authoring and gets
no runtime RED credit; public recognition_terminal_required/corrected epochs
retained. Regenerate standalone Perl source; no schema/family/Dart change.
Packet perl-blind-falsey-intake.json.gz. Parent completion39.9.2 remains next.

39.9.2 now publishes completed repeated blind parent acceptance and distinguishes
failed observations from pure coordinators without fake selected spans. Current
mechanism/proof: [[perl-repeated-blind-parent-acceptance]].10 native/fresh groups
20inputs2healthy8RED ->10pass, falsey15 unchanged/observation7 and actual counted
traces pass. Next immediate work is Dart39.2.7.1-.2 null status gaps before peers.

2026-10-29 Julia39.3.5 public qualification replays all18 shared sources27
inputs on current Perl native and emitted execution: values/cursor/errors all
agree with the exact target, including all three formerly qualified falsey aa
rows. Actual producer/inputs/emission/context errors are retained in
julia-blind-postcall-intake.json.gz, linked through
[[julia-blind-postcall-iteration-outcomes]]. Original .9/.Dart proof packets
remain frozen; this is a new current replay, not retroactive census credit.
