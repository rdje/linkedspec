---
id: perl-and-single-acode-duplicate-match-locals
title: Perl emitted single action AND handlers duplicate preamble match lexicals
answers:
  - "why does emitted Perl warn LMATCH masks earlier declaration"
  - "which leaf owns duplicate local match variables in and_single_acode"
  - "do duplicate match lexical warnings occur at native build or emitted load"
date: 2026-10-29
status: confirmed warning defect; P1 repair40.1.1 pending before admission
evidence: "perl-referenced-intermediate-intake.json.gz retains actual normal/probe/source/channels/receipts."
reverify: "Restore retained public producer under an owning leaf; run through project_data_run.sh env PERL5LIB= perl -Iperl, preserving warning channels."
---

The public source Top::| => Atom {return(retv)} / Atom:AND /a/ -> Atom[0] {return("A")} is retained verbatim with its emitted source. Native build, emission, native run and fresh run have empty warning arrays; warning-enabled fresh eval reports five masks: LMATCH, LMATCH_LIST, LMATCH_HASH, LINDEX and LSPOS. Both executions return A/cursor1. SpecEntry::_build_handler_preamble declares invocation-local registers; HandlerVariantEmitter::_build_lmatch_extraction emits my declarations again at the same subroutine scope in _emit_and_single_acode_handler. This is a generated-source warning defect, not evidence of wrong callback scope or values. P1 TYPE-REFERENCE-BOOK.1.2.23.3.40.1.1 owns repair after48.5 before45/wider features/admission/push, preserving I/L phase, per-regex bridges and nested matching branches. SESSION10 unbound handoff is separate. Actual source/channels/owner snapshots and producer are retained in perl-referenced-intermediate-intake.json.gz.
