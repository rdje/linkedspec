---
id: perl-capture-endpoint-local-register-repair
title: Perl capture endpoints use local match presence and successful-only take movement
answers:
  - "why did generated Perl capture_slice_len read package match variables"
  - "how are unavailable Perl capture endpoints guarded"
  - "why did an absent Perl capture_take advance its boundary"
  - "must emitted Perl parsers be regenerated for the capture endpoint repair"
date: 2026-10-29
status: Perl40.1 focused repair verified; registration/independent peers/broader isolation/admission separate
tags: [perl, capture, match, source-location, invocation, generated-source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.40.1 perl-capture-endpoint-intake.json.gz retains current16-source native/separate-process clean+seeded6healthy10RED ->16pass, unchanged controls/metadata, stale32 calls and ordinary27 groups."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/capture_endpoint_absence.t t/typed_source_location_perl_contract.t t/capture_boundary_number_results.t"
---

SpecEntry::_build_handler_preamble previously declared incoming entry registers,
while HandlerVariantEmitter::_build_lmatch_extraction declared local registers
only inside successful matching branches. Pre-local I/blind readers resolved
LMATCH/LSPOS to ambient package globals. Uninitialized subtraction manufactured
empty/0; a seeded host could manufacture text/spans. Both-defined ambient values
cannot establish invocation-local presence. Anonymous takes also advanced after
manufactured reads; moved boundaries could cause typed reversed-span errors.

40.1 binds all five existing local registers in the handler preamble. Selected
branches keep their existing bindings and matcher timing. Contracts' shared
_anonymous_local_match_capture_value_expr guards available local text/end/boundary
and ordered span before typed text/width projection. Seven canonical/alias
lowerings use it; takes move the boundary only after successful reads. No new
register authority, frame, helper, schema, cursor policy or diagnostic is added.

All16 current sources pass native/separate-process clean+seeded execution, keeping
six healthy empty/zero/Unicode/successful-take controls and complete public v2
metadata/minimal plans unchanged. Normal16/typed-source4/Number7 groups pass27.
Same16 old modules retain exact semantic values/cursors/error fields/warnings/
metadata in32 calls despite accepted v2: regenerate affected emitted parsers.
Nondeterministic raw host-address strings are excluded only where exact structured
error fields are present. Broader SESSION17 host isolation, independent40.2-.5,
new canonical test registration23.4.1 and full admission remain separate.
