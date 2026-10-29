---
id: perl-empty-blind-return-duplicate-scalar
title: Empty Perl blind fluent return duplicates the parent scalar declaration in emitted source
answers:
  - "why does Perl empty blind return warn my Top masks earlier declaration"
  - "which task repairs the empty blind return duplicate scalar warning"
date: 2026-10-29
status: confirmed warning defect; P2 repair40.1.2 after40.1.1 before45/admission
evidence: "rust-blind-fluent-return-intake.json.gz retains public source, emitted Top declarations52/55, fresh-load warning and correct native/fresh empty array/cursor0."
reverify: "Restore probe_reference_blind_fluent_return.pl and candidate inputs; run project-routed Perl -Iperl under repair40.1.2, retaining warning channels."
---

Top::AND =>Child.return() with Child I{return("CHILD")} returns[]/cursor0
on native and emitted execution. The emitted parent declares my $Top twice
in the same scope, at retained lines52 and55, producing one fresh load mask
warning. Runtime values remain correct.40.1.2 owns the declaration-owner repair
after40.1.1 before45/admission; no warning suppression or callback/value defect
is inferred.40.1.1 concerns different LMATCH registers. Exact source/producer/
channels are retained with Rust48.2.1.
