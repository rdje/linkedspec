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

## Rust blind parent push48.2.4 (2026-10-29)

Blind push now parses args, injects parent as typed variable and delegates to
the existing statement owner. Own8 pipe controls1healthy7RED ->8pass on native,
reconstructed, plan and separate compiled routes; no-tail unchanged. Parent
String/0/false/null/Array values, explicit target and same-position guard retain
their existing meanings. Eight selected tests pass; source/compiled/serialized/
full metadata/plan exact and original8 modules reused. Rebuild, no regeneration.
Initial Default9 hypotheses mixed repeated grouping/minimum and push. Existing
reference or_code closure returns collect per iteration;48.2.5 owns independent
Rust qualification/repair. Unicode Ω compiles/selects but fails recognition at0
under ASCII _required_name, despite pinned XID membershiptrue;48.2.6 owns that
before48.3. Neither excluded population gains passing credit here.
Refined9 reference producer now isolates fresh-load masks only; exact original
empty-return source confirms40.1.2 attribution that earlier combined capture did
not isolate.40.1.1 owns LMATCH masks,40.1.2 parent scalar masks. Kind-strict
current8/prior17 emitted-result artifact checks pass; no runtime rerun claim.
Packet rust-blind-parent-push-intake.json.gz retains actual initial/refined
inputs/producers/source/errors/warning phases/RED+GREEN/modules/patch/receipts.
