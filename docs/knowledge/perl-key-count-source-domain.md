---
id: perl-key-count-source-domain
title: Perl CountKeys initial sources require Hash references or valid binding names
answers:
  - "does Perl count_keys false or an Array return zero"
  - "why does count_keys numeric4 no longer read main Hash4"
  - "how does CountKeys preserve named Hash source counts"
  - "which regression protects initial CountKeys zero and source order"
  - "is the Perl CountKeys source-domain repair fully admitted"
date: 2026-11-06
status: P1 domain75.0.2 implemented with focused checks; consumer75.1 next
tags: [perl, count_keys, source, domain, hash, host, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.75.0.2; docs/checkpoints/key-count-domain-perl-2026-11-06/REVIEW.md retains actual first inputs/modules/full raw channels. Unchanged23 groups10PASS13RED to23PASS, ten healthy exact, twelve localized seed rows zero/host unchanged, final37/syntax/six recovery corruptions pass."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/key_count_source_domain.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/key-count-domain-perl-2026-11-06/review.py"
---

CountKeys' computed-source producer uses ref eq HASH before dereference, giving
zero for initial Boolean/Array/missing/Number/text values. Its named working-Hash
shortcut requires the existing ASCII identifier grammar, so literal4 is data
rather than a Hash name. Exactly those two producer clauses change. Valid named
Hash counts stay2,2; source-once/order/compatible-prefix controls complete and
needed typed binding errors remain errors. Regenerate emitted Perl.

Unchanged23 native/fresh groups move10PASS13RED to23PASS; all ten healthy complete
observations remain exact. Literal4 free/receiver public and emitted carriers
independently distinguish empty/outer/main::4 seeds before repair (0,0,1); all
twelve rows become0 without warnings/errors or host mutation. This is limited
to those exact localized carriers, not native seeded or general isolation.
Final domain23/typed-source9/Count-length5=37 focused groups and owner syntax pass.

The original aborted assessment profile remains historical. Consumer75.1 must
capture its own valid current domain aggregate before result-guard changes;
computed Number2/main::2 consumer handling is still pending:
[[key-count-source-and-guard-gaps]]. Full source/context/transitive custody,
legacy bare/absent SESSION17, general isolation/discovery/full23.4 remain separate.
Readonly recovery checks historical inputs, not latest-runtime source freshness.
