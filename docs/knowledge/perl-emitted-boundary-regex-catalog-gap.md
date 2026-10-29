---
id: perl-emitted-boundary-regex-catalog-gap
title: Emitted Perl boundary helpers retain complete private regex catalogs
answers:
  - "why does emitted Perl capture_until_boundary return null while native returns text"
  - "does emitted Perl preserve regex catalogs for named boundary helpers"
  - "which task owns generated Perl boundary descriptor reconstruction"
date: 2026-10-29
status: bounded37 fixed/targeted-checked; old emitted parsers require regeneration, registration/full admission separate
tags: [perl, generated-source, boundary, regex, descriptor]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.37 retained perl-emitted-boundary-catalog-intake.json.gz actual native/separate-process emitted RED/GREEN, old/new modules, exact catalogs/metadata and stale replay; historical36.0 intake remains in active-edge-body-authority.json.gz."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/emitted_boundary_catalog.t t/generated_source_contract.t"
---

## Pre-repair diagnosis (2026-10-28)

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

## Repaired behavior (2026-10-29)

37 retains the existing full recognition_regex_map in every generated descriptor;
the boundary reader uses it for CODE rule entries while native HASH catalogs keep
priority. The map is private, reconstructed from complete compiled regex arrays
with flags, independent of active edges. Handler dispatch/recognition and public
v2 six-field metadata/minimal label-family plans remain unchanged.

Independent13sources18inputs: native all healthy, emitted four healthy/nine RED
before repair, regenerated all pass. Native outcomes/catalogs/full public metadata,
four healthy emitted observations and recognition-only source remain unchanged.
Old13modules replayed after repair retain exact old outcomes, including nine
failures despite accepted v2 metadata: affected emitted parsers need regeneration.
Multiple/earliest/EOF/unknown/empty-rule/quoted/Unicode/flags/nonzero/repeated and
recognition/dispatch controls, actual producers/raw epochs/modules/receipts are
retained in docs/checkpoints/type-operation-inventory/perl-emitted-boundary-catalog-intake.json.gz.
The ordinary test is t/emitted_boundary_catalog.t; exact normal/canonical
registration23.4.1 remains before admission/push. Separate-process emitted proof
preloads LinkedSpec, not a fully cold dependency bootstrap. No public format bump,
new syntax, performance or unprobed backend/context coverage follows.
