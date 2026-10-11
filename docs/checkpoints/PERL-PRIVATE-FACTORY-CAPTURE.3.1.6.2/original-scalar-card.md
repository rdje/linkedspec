---
id: perl-scalar-receiver-required-capture
title: Required number and string callbacks preserve parser-returned object annotations
answers:
  - "which required callbacks do number and string receiver normalizers acquire"
  - "does the string receiver normalizer mutate the parser returned call"
  - "can parser argument mutation change __source_expr"
  - "are shared parser returned call references preserved"
  - "can trim replace the selected number or string parser"
  - "where is required number and string callback isolation verified"
date: 2026-10-11
status: bounded focused proof verified; supplemental public compatibility passed; canonical integration remains separately owned
tags: [perl, actionir, receivers, callbacks, aliases, publication]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2 retains immutable193-input native16 callback outcomes/73 branches/8 actual authority rows/4 public source/4 cold rows. Identical436 TAP has12 original authority REDs/424 controls/all436 current GREEN. Five separate syntax-valid source faults for each owner fail6/2/4/3/4 for number and6/2/6/3/4 for string. Supplied63 suites/195 inputs/12315 assertions, seven actual evidence RED/restorations and full book89/three controls pass. Original314 predecessor bindings remain historical at5bf068c92."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-review.py"
  - "Use the accepted leaf's Git inputs after later source/book changes. Capture/freezer/fault/evidence writers are one-shot; no native instruments or observations may be refreshed."
---

Both normalizers eagerly require trim and method parsing before their input
guards. The two resolver returns now bind each selected actual callback to a
separate private capture. Opaque callbacks cannot donate equal-text publication
to the enclosing owner; actual known callbacks retain their eligibility.
Public maps, ordinary values, contexts, successful error states, fatal-object
identity and require-only lazy loading stay native. Optional/direct capture and
other private families retain separate owners.

Trim receives local scalar copies and actual substring arguments from the shared
splitter. Returning the incoming text and then appending `!` through the argument
changes the later split and declines normalization, while the caller's original
`score.abs()` or `raw.trim()` stays intact. Clear readonly flags alone cannot
distinguish these actual aliases from copied arguments.

The string owner annotates the actual parser-returned hash with `__source_expr`.
A controlled parser that recognizes `trim()` and then appends `!` through its
argument returns the same call object annotated with `trim()!`. Copying arguments
loses this native effect. A controlled parser returning one shared call hash for
`raw.trim().lowercase()` leaves both retained references pointing at that hash,
with its final `lowercase()` annotation and actual `trim(trim(raw))` result.
The number owner also preserves shared returned references and native results.
These are injection controls, not new DSL methods or public runtime admission.

Parser selection precedes trim. Replacing the map entry during trim does not
replace the callback already retained. Both owners preserve source/splitter,
method, arity, family-transition and terminal guards. Missing/non-CODE dependency
comparisons normalize only supplied-root diagnostic locations in shallow copies;
exact diagnostic stems and original source lines7521/7604 stay checked, and raw
channels retain their complete locations.

The first independent reviewer used an overbroad `-missing-` label match, which
also selected `parser-missing-args` with no error. It exited1 before a review
report existed. A prematurely started dependent evidence writer then exited1 at
that absent report, before copying inputs or writing results. The exact draft
reviewer and explicit observed-boundary transcriptions remain in
`PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-review-draft.py` and `-review-correction.json`
under `docs/checkpoints/`. Anchoring the selector to actual required-role labels
repairs only reconstruction; no native/runtime instrument or observation changed.
Neither failed attempt is claimed as a partial success.

The current consumer producer checks every ordered actual command path/header,
all63 complete TAP plans and the success summary, including the accepted suite
under `docs/checkpoints/`. Its diagnostic stream exactly matches the predecessor.
The predecessor's refused t-only census remains historical, without refresh.

Seven actual evidence corruptions reject and exact restoration passes. Separate
controls distinguish artifact-hash failure from a missing semantic reason beyond
the updated immediate inverse binding, and checkpoint omission beyond the updated
immediate consumer-review binding. Full healthy/RED/restored channels, changed
bytes and exact supplied populations are retained before each assertion.

Complete producers, supplied input identities, full mutant sources and channels
are retained under `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-`.
Supplemental standard checks pass both Perl syntax commands and public Phase0
with1035 assertions, retaining complete channels. This additional live-worktree
compatibility record has no full transitive input capsule, benchmark or broader
private/canonical admission.
Canonical focused-fixture registration stays scheduled under `.7`, before pipeline
activation `.6`; this proof establishes no independent canonical coverage.
