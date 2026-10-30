---
id: perl-empty-blind-return-duplicate-scalar
title: Empty Perl blind fluent return duplicates the parent scalar declaration in emitted source
answers:
  - "why does Perl empty blind return warn my Top masks earlier declaration"
  - "which task repairs the empty blind return duplicate scalar warning"
  - "how do Perl blind scalar declarations retain nested repetition scope"
  - "does the blind scalar warning repair change diagnostic JSON"
date: 2026-10-29
status: repaired40.1.2 with bounded declaration/source proof;45 exact failures next
evidence: "rust-blind-fluent-return-intake.json.gz retains public source, emitted Top declarations52/55, fresh-load warning and correct native/fresh empty array/cursor0."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/perl_blind_scalar_declarations.t t/perl_match_local_declarations.t"
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

## Repair40.1.2 (2026-10-30)

SpecEntry supplies its leading auto-variable declaration/I-code prefix through
private source_preamble context. HandlerVariantEmitter overlays a copied Perl
render IR; diagnostic backends and caller IR are unchanged. Prefix-only
_rule_scalar_declaration stops before authored I-code, so quoted declaration
text is not treated as a declaration. Four blind stems reuse only existing
scalars; nested OR/AND repetition copies clear outer context and keep locals.
No new serialized IR fields, public interfaces, global frame or runtime phase/variable policy.

Own24 sources7 warning RED17healthy ->all24 new modules load warning-free;
1 redundant outer declaration removed per affected source, first declaration
and3 nested bodies exact.17 healthy emissions/all metadata/values/cursors/errors
unchanged, including17 typed/general/scoped returns and explicit-target push.
New25 including context guard plus prior AND9 pass34 groups, empty stderr and
syntax clean. Independent nonempty JSON family/label and caller IR checks pass.
Old modules still execute but require regeneration to remove masks; samev2.

The first helper had no physical prefix context and retained7 masks. A shared
preamble prototype passed Perl; final private context protects diagnostic JSON.
All attempts/producers/normals/modules/results are retained in perl-blind-scalar-
intake.json.gz, without false completion credit. Exact canonical selection23.4.1,
full admission and ordinary/lifecycle/cross-rule authority remain separate;
45 exact selected failures is next.

Physical context is explicit: the built-in Perl renderer places source_preamble
in transient _source_preamble on its private render copy. Descriptive preamble
metadata alone does not suppress a declaration. The metadata-only compatibility
control exposed an uncommitted prototype regression, now fixed; diagnostic JSON
and original IR with nonempty metadata remain exact. Backend dispatch is a fixed
lexical table, not a runtime registration API. An incorrect registration test
assumption is retained and corrected; no nonexistent API or public IR addition
is claimed. Nested copies clear only the transient physical context.
