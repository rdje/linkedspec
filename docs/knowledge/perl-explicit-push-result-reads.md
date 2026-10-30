---
id: perl-explicit-push-result-reads
title: Unambiguous Perl push snapshots feed existing typed bracket reads
answers:
  - "can Perl push items tail be indexed directly"
  - "which push source forms support direct bracket reads"
  - "does a push result snapshot survive selector rebinding"
  - "why are bare and numeric push result sources excluded"
  - "does push read composition grant computed writes or deferred execution"
date: 2026-10-31
status: bounded Perl58.1.1 reads and58.1.2 fluent targeted-checked; peers separate
tags: [perl, push, array, selection, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.58.1.1; push-read-perl-intake.json.gz retains unchanged6groups4RED/2healthy to6GREEN, callable5/deferred22 TAP items/syntax, five runtime sources/eight AST-error controls and actual producers/inputs."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/push_result_selection.t t/computed_selection_callable_compat.t t/computed_selection_deferred_boundary.t"
---

At24c27ab72 ordinary aggregate push production works, but direct computed-call
sources remain excluded. _ordinary_explicit_push_result_source now requires
canonical two-argument/plain named target/no-trailing/original-source calls and
recognized value AST kinds. Bare variables/numeric literals/raw invalid values
stay excluded, retaining child/all-bare/indexed dispatch authority. The existing
computed-call predicate admits this role; value_access reuses complete original
_lower_push_statement before ordered typed read/selected dispatch. Push bodies,
aggregate producer58.0/parser/deferred/read/selected/mutation/copy/schema and all
remaining owner bytes stay exact. No new helper/mutation method or execution right.

Same6groups4RED/2healthy to6GREEN native/fresh/metadata. Five runtime sources
retain ten-output read-only shared subset, existing completed-bound positive,
selected guards/empty defaults/String noncontainer recovery, function-local
source/selector/caller scopes and inherited unmasked wrong-target error. Eight
AST/error-only exclusions stay exact; no unsupported program execution. Initial
freezer255 was uncaught expected computed-write rejection, corrected via guarded
resume before baseline with original files retained, no product RED credit.
Callable5/deferred22 TAP items and syntax pass. Final only moves existing four-
line comment next to its owner; runtime-tested source/exact other-byte identity
and final syntax proof retained. No redundant runtime rerun for that comment.

Full12 fixture remains unchanged; subset removes only fluent init/call/two fields.
Regenerate affected emitted Perl parsers; canonical new normal/fixtures remain
queued23.4.1. Fluent58.1.2 and independent peers/full23.4 remain separate.

Bounded Perl fluent58.1.2 is now targeted-checked; [[perl-explicit-push-result-fluent]] owns initialization and preserved healthy paths. Independent peers and full23.4 remain separate.
