---
id: perl-and-single-acode-duplicate-match-locals
title: Perl emitted single action AND handlers duplicate preamble match lexicals
answers:
  - "why does emitted Perl warn LMATCH masks earlier declaration"
  - "which leaf owns duplicate local match variables in and_single_acode"
  - "do duplicate match lexical warnings occur at native build or emitted load"
  - "which Perl handler still masks match locals after the single-action AND fix"
date: 2026-10-29
status: single-action AND40.1.1 and OR action40.1.1.1 repaired; scalar40.1.2 next
evidence: "perl-referenced-intermediate-intake.json.gz retains actual normal/probe/source/channels/receipts."
reverify: "Restore retained public producer under an owning leaf; run through project_data_run.sh env PERL5LIB= perl -Iperl, preserving warning channels."
---

The public source Top::| => Atom {return(retv)} / Atom:AND /a/ -> Atom[0] {return("A")} is retained verbatim with its emitted source. Native build, emission, native run and fresh run have empty warning arrays; warning-enabled fresh eval reports five masks: LMATCH, LMATCH_LIST, LMATCH_HASH, LINDEX and LSPOS. Both executions return A/cursor1. SpecEntry::_build_handler_preamble declares invocation-local registers; HandlerVariantEmitter::_build_lmatch_extraction emits my declarations again at the same subroutine scope in _emit_and_single_acode_handler. This is a generated-source warning defect, not evidence of wrong callback scope or values. P1 TYPE-REFERENCE-BOOK.1.2.23.3.40.1.1 owns repair after48.5 before45/wider features/admission/push, preserving I/L phase, per-regex bridges and nested matching branches. SESSION10 unbound handoff is separate. Actual source/channels/owner snapshots and producer are retained in perl-referenced-intermediate-intake.json.gz.

## Repair40.1.1 (2026-10-30)

Common extraction defaults stay declaring; single-action AND opts into reuse of
SpecEntry preamble registers. Nine actual warning RED groups become green:8
loads have0 warnings and entry/local retains5 OR masks under immediately next
40.1.1.1. Full emitted source differs only by5 my tokens per AND extraction;
metadata/results/cursors/typed errors exact, old modules still execute but need
regeneration to remove warnings. New9/retv10/anonymous16/named15 pass50 groups.
Separate old/new processes retain all warning phases, empty run/build/emission
channels and exact output. Packet perl-match-locals-intake.json.gz retains the
actual9-source producer/frozen oracle/normal/source epochs/modules/results.

OR collision is independently observed in public emitted Top or_acode, where
common extraction also shares handler scope with preamble declarations. Preserve
its explicit5 masks until40.1.1.1 repairs that owner; never indiscriminately alter
nested callers. The initial entry source used explicit child slot identity, so
its unrelated parent H regex was not the selected slot; refined H|a dependency
source gives entry H/local a. Unsupported entry_text inside callable is a typed
unknown_helper control per existing body envelope; valid callback reads the
match in its caller and passes text explicitly. No environment capture or helper
vocabulary extension, blanket phase or all-emitter warning-free claim.

## OR follow-up40.1.1.1 (2026-10-30)

Only _emit_or_acode_handler now opts into preamble-local extraction too. Own10
controls7actual warning RED/3 healthy ->all10 new modules load warning-free;
Default/repeated/fixed-AND controls remain byte-identical and full metadata/
results/cursors exact. Seven OR emissions change only5 my tokens each. Both
ordinary declaration normals now reject every load warning; the old entry/local
allowance and fixture field are removed. OR10/AND9/anonymous16 pass35 groups,
empty focused/probe/fresh stderr, same old/new runtime behavior. Regenerate old
OR modules to remove warnings; public format remains v2.

An initial generic patch hit Default rather than OR. Diff inspection and failing
normal controls rejected it, then exact function-bounded correction restores
Default and fixed AND bodies to activation HEAD and selects OR. Wrong source/
output/failed tests/correction retained in perl-or-match-locals-intake.json.gz,
without product RED credit from that mistake. Existing nested extraction owners
stay declaring, no broader phase/variable policy or all-emitter proof. Separate
empty-blind scalar40.1.2 remains before admission.
