---
id: perl-emitted-boundary-regex-catalog-gap
title: Independently emitted Perl omits the catalog required by boundary lookahead
answers:
  - "why does emitted Perl capture_until_boundary return null while native returns text"
  - "does emitted Perl preserve regex catalogs for named boundary helpers"
  - "which task owns generated Perl boundary descriptor reconstruction"
date: 2026-10-28
status: P1 owned37 after bounded33/35/34 and before full23.4 admission or push
tags: [perl, generated-source, boundary, regex, descriptor]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.0 retained active-edge-body-authority.json.gz public producers, native/fresh channels and emitted bytes; 31f81708e."
reverify: "Recover and run probe_active_edge_boundary.pl from active-edge-body-authority.json.gz through tools/project_data_run.sh env PERL5LIB= perl -Iperl; do not assume repair before37."
---

Exact source: Top:: I returns capture_until_boundary("Landmark"); Landmark declares
/END/. Input bodyEND. Public Get returns String body; independently loaded emitted
Execute returns null without a reported error. The emitted metadata remains v2
with minimal Top/Landmark label/family rows. Its descriptor stores spec.Landmark
as a CODE handler, whereas the emitted helper requires a HASH with re Array and
skips the unusable rule. The live descriptor retains the needed regex metadata.

This is separate from Rust's outgoing-edge eligibility defect and from boundary
helper semantics. Do not truncate complete catalogs or grant false generated
coverage. P1 owner37 must freeze a narrow reconstruction target, add native/fresh
RED/GREEN and direct-dependent controls, repair and commit before full23.4/push.
No unprobed backend failure, wider helper failure or public format bump follows.

The first source-dump diagnostic used the wrong context field and exited25 after
printing source; refined parser_source_ref diagnostics completed successfully.
That instrument error is not product RED; exact raw channels and final producer
are retained in the authority packet. The first producer bytes were not retained,
so no historical input hash is asserted for that setup attempt.
