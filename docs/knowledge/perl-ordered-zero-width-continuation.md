---
id: perl-ordered-zero-width-continuation
title: Perl global empty-match continuation leaks across independent ordered slots
answers:
  - "why does the second zero-width ordered regex slot miss at the same cursor"
  - "does Perl global empty match state affect LinkedRE match_slot"
  - "which task owns independent zero-width slots and repetition progress"
date: 2026-10-28
status: confirmed P2 owner39.8 before full39/23.4/push; broader progress authority unassessed
tags: [perl, regex, zero-width, slots, and, progress]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.39.7 direct public LinkedRE::match_slot probe; original and refined source/results retained with perl-and-falsey-intake.json.gz."
reverify: "Recover retained probe_perl_ordered_zero_width.pl and run through tools/project_data_run.sh env PERL5LIB= perl -Iperl."
---

Two calls to LinkedRE::match_slot on a at cursor0 with qr/(?=a)/ and indices0,1
yield true then false. Resetting pos(input) to that same position before each
call yields true/true at0. The public matcher uses /gcp and initializes pos only
when absent, so Perl's previous-empty-match continuation state suppresses the
next independent required slot. In AND{2} with two such slots, the action is
never reached; its value cannot diagnose falsey group returns.

P2 owner39.8, after bounded feature coverage and before full admission/push,
must reconcile independent required-slot matching with explicit ordinary loop
progress. Recognition scopes already reject zero-progress repetition. Clearing
the global matcher flag alone could permit an unbounded empty-match loop;
do not infer a new progress policy or silently advance the input. Other backend
behavior is unassessed. The39.7 acceptance test instead uses one zero-width slot
and a maximum of one group, isolating the falsey result without this extra defect.
Related: [[repeated-and-falsey-group-acceptance]], [[top-rule-recursion-forward-progress-guard]].
