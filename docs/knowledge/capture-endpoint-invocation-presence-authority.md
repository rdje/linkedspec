---
id: capture-endpoint-invocation-presence-authority
title: Missing capture endpoints stay unavailable and failed takes preserve the boundary
answers:
  - "what is the accepted capture_slice_len target before a local match"
  - "may a capture endpoint use the live cursor when local match is absent"
  - "does an unavailable capture_take advance the anonymous boundary"
  - "can package LMATCH LSPOS values establish local match presence"
date: 2026-10-29
status: target40.0 and Perl40.1/Rust40.2 focused repairs verified; independent40.3-.5/full admission pending
tags: [capture, source-location, absence, presence, invocation, portability]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.40.0 capture-endpoint-absence-authority-intake.json.gz retains16-source native/clean+seeded emitted controls, six healthy/ten RED, current presence4 groups and neutral typed231 mutations."
reverify: "Recover probe_capture_endpoint_authority.pl and read_capture_endpoint_authority.py from the retained packet; use project_data_run.sh env PERL5LIB= perl -Iperl and the Python project runner. Baseline counts are dated, not repaired backend admission."
---

ADR0056 sections1/2/4/9/19/21 keep positions/spans and mutable state invocation-local,
make missing selected matches explicit, and separate entry, local match and cursor.
The admitted structural-match contract distinguishes absence from a real zero-width
match. Capture readers require their named endpoint; valid-only takes mutate only
after a successful read. No warning/coercion or ambient package value supplies a
missing endpoint. See the canonical target capture-endpoint-absence-authority.md
under docs/checkpoints/type-operation-inventory/ and the shared16-source fixture
tests/fixtures/capture_endpoint_absence.json.

Missing local-match endpoint returns undef for text/width/aliases and leaves a
failed take's boundary unchanged. Present empty text/zero width remain defined;
empty-after-prefix may capture the prefix. Through-cursor/rest/boundary coordinates
remain usable without a local match. This composes existing contracts; no new
helper, schema, typed diagnostic, cursor policy or backend admission is introduced.

Public generated Perl source shows pre-local I/blind handlers can read LMATCH and
LSPOS as package globals. Clean state warns/manufactures empty/0; seeded state can
manufacture text/spans, and failed takes advance the boundary. Narrow Perl40.1 owns
the actual register/presence repair, with wider SESSION17 host isolation separate.
Six valid controls and ten absence RED are independently retained before production;
initial incorrect target/carrier/serialization instruments receive no defect credit.

2026-10-29 Perl40.1 binds local registers before I/blind code and shares guarded
anonymous match-endpoint/take lowerings. Current16-source native/separate-process
clean+seeded6healthy10RED ->16pass; six healthy outcomes and complete metadata
unchanged. Normal16/typed-source4/Number7 groups pass27. Old16 modules retain exact
semantic outcomes/errors/warnings/metadata in32 calls, so regeneration is required.
[[perl-capture-endpoint-local-register-repair]] retains current cause/closure;
independent40.2-.5/broader SESSION17/full admission remain separately owned.

2026-10-29 independent Rust40.2 has9healthy7RED ->16pass on native/reconstructed/
plan/separate emitted routes using existing match_present guards. Exact input/
emitted/metadata and nine healthy outcomes stay unchanged; same baseline modules
relinked against new runtime pass without source regeneration. Endpoint1/Number6/
alias1 integration groups and10 anonymous library tests pass. See
[[rust-capture-endpoint-match-presence-repair]]. Independent40.3-.5/full admission
and broader prerequisites remain separate.
