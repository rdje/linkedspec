---
id: perl-boundary-phase0-existing-failures
title: TYPE37 historical failure comparison and current-only Phase0 recovery
answers:
  - "is Phase0 green after the emitted Perl boundary catalog repair"
  - "did the Perl boundary catalog change introduce the current Phase0 failures"
  - "who owns the 28 Phase0 failures retained with TYPE37"
date: 2026-10-30
status: current selected failures owned by TYPE-REFERENCE-BOOK.1.2.23.3.45
tags: [perl, phase0, regression, ownership]
evidence: "TYPE37 perl-emitted-boundary-catalog-intake.json.gz retains full primary run, exact selected28 names, actual baseline/candidate TAP/stderr, canonical snapshots, producer and comparison receipt."
reverify: "Recover replay_phase0_after_pick.py and probe_phase0_current_selected.pl from perl-phase0-after-pick-intake.json.gz; run bash tools/run_python_project_data.sh .linkedspec-data/verification/replay_phase0_after_pick.py. Never run the historical TYPE37 source-swap replay or --restore against current source."
---

The historical TYPE37 additional standard Phase0 run fails28/1035 groups. The exact28 failing groups
are replayed from the unchanged canonical test using Test::More subtest selection:
all nested assertions run for a selected group; other groups are skipped without
credit. Canonical Compiler.pm/ActionIR/Contracts.pm committed-baseline versus
candidate bytes produce byte-identical selected TAP/stderr and exit28. Candidate
files and the resume pointer are restored exactly. No full baseline rerun is
claimed. Initial lexical-local selector setup failed before tests and receives no
product failure credit; its bytes and diagnostics remain retained.

This separates these failures from the TYPE37 patch. It does not classify them
all as stale: source-shape expectations and wrong runtime results both occur.
P1 TYPE-REFERENCE-BOOK.1.2.23.3.45 owns every exact retained name after40/41,
before wider feature expansion/full23.4/push, with contract-led bounded repair
children and public source/context/debug proof. Historical evidence is immutable;
neither global expectation refresh nor silent null acceptance is authorized.
The focused boundary/generated/quoted consumers pass at that boundary; its full Phase0 is not green.

TYPE45.0 current-only recovery at clean d30a2f9cd37bd211b1e7c1c9faecc15c9579da8d
verifies the frozen names and decompressed primary diagnostics against the unchanged
TYPE37 packet. All28 groups still fail, with all nested assertions retained and the
shared discovery assertion passing; exit28 and the complete29-result TAP plan are
retained in perl-phase0-current-intake.json.gz. Hashes of528 named current inputs are
unchanged around execution. This is selected evidence, not a new full-suite run.
The historical comparison producer deliberately swaps old Compiler/Contracts and
MEMORY snapshots, so it is not a safe current-source replay or recovery command.
The replacement selector never installs those snapshots. Its initial lexical-local
setup error stops before tests; corrected producer evidence receives the result credit.
First bounded child45.1 owns the observed missing synthetic callback in the lazy-load
group; the remaining27 named groups stay with45 for contract-led children.

TYPE45.1 subsequently repairs only the lazy-owner synthetic callback fixture: its
unchanged40 assertions pass, alongside the native/fresh pipeline consumer6.
The other27 retained groups remain owned and are not rerun in that slice;45.2
next reconciles the helper-substitution endpoint assertions. No new full-suite
state or blanket stale-expectation conclusion follows.

TYPE45.2 subsequently reconciles13 exact source expectations in the helper-
substitution group against accepted40/47/49 presence/order/write contracts.
All90 assertions and46 direct endpoint runtime groups pass; production and
fixture values are unchanged. Other26 frozen groups remain owned, with the
immediate/local named-map group45.3 next; no blanket source-oracle conclusion.

TYPE45.3 repairs an actual shared producer defect: pick_keys retained an earlier
lowered key under conditional local initialization. The original map expectation
is unchanged and its five assertions now pass; raw capture maps were already
correct. New8/capture30/original-default13 normal groups pass51. See
[[perl-pick-keys-conditional-local-reuse]]. Current-only frozen28 assessment45.4
next establishes remaining failures after that shared change; no old count is
carried forward as current and no blanket stale-expectation classification follows.

TYPE45.4 current-only reassessment at e882945373fef4ea5b7fe390c1c72b2f5d609c7a
completes frozen28 with8 passing/20 failing groups, exit20 and530 input hashes
unchanged. Exact names and actual producer/TAP/diagnostics are retained in
perl-phase0-after-pick-intake.json.gz. The first remaining nested Array result
has child45.5; other19 exact names remain owned45. Prior boundaries remain dated;
this selected replay establishes no full-suite state or common cause for all20.

TYPE45.5 subsequently corrects one nested Array constructor expectation under
existing evaluated-value authority, distinguished by six native/fresh nested/direct/
explicit-flat/empty controls. Original12 and adjacent10 assertions pass22; all
production remains unchanged. Other19 last-selected failures remain owned;45.6
next assesses two collection pipeline groups, with no blanket expected-value refresh.

TYPE45.6 subsequently reconciles two collection-pipeline groups:8 obsolete
source/value/instrument assertions are corrected under existing pure/nested
authority and supplied DSL type context. All26 assertions and direct6 pass, with
six native/fresh and three compatibility-harness controls, no production change.
Other17 last-selected failures remain owned; nonempty-default45.7 is next.

TYPE45.7 subsequently reconciles two obsolete nonempty-default source assertions
with exact normalized first-value/source and fallback comparison checks. Original
Hash assertion unchanged; all3/direct native-fresh6 pass, production unchanged.
Other16 last-selected failures remain owned; scalar boundary-transform45.8 next.

TYPE45.8 subsequently reconciles scalar boundary source assertions: actual4RED
then6GREEN, final2 semantic assertions unchanged, direct native/fresh String7
passes. Initial cold private-owner failure runs no assertions and is separately
retained/fixed by local require. All production unchanged. Other15 last-selected
failures remain owned; exact cat45.9 next.

TYPE45.9 subsequently reconciles one cat composed-fallback source assertion:
1RED/3healthy then4GREEN, other3 assertions byte-exact; neutral scalar-text
consumer7 passes, production/neutral contract unchanged. Initial3/1 count
assumption is rejected; both actual diagnostic epochs are1/3 and overbroad
transient changes are restored. Other14 last-selected failures stay owned;45.10
next prioritizes the runtime Hash-chain null/copy distinction against authority.

TYPE45.10 subsequently reconciles two Hash-chain assertions under explicit
ADR0138 null-copy authority:2RED/12healthy ->14GREEN, with six public native/fresh
controls distinguishing copied null from direct count0/empty Hash/default recovery.
Original runtime source/other12 assertions/production unchanged; no new depth or
isolation claim. Other13 last-selected failures remain owned; String returned-type
continuation45.11 next.

TYPE45.11.1 fixes actual scalar-host sorted_values reads (8RED/7healthy ->15GREEN,
Hash14/String6/old-new5); affected old modules require regeneration. TYPE45.11.2
then reconciles only original String3/18 assertions under implemented result
authority, retaining15 healthy assertions/two original sources;18 now pass.
Twelve last-selected groups remain owned; emptiness45.12 follows. No new combined
frozen28/full-suite status is inferred.

TYPE45.12 subsequently reconciles the value-layer emptiness group3 source
expectations/1 healthy ->4 GREEN, retaining original expressions/healthy Hash
payload and unchanged production. Public native/fresh5/direct expression11
pass. Eleven last-selected groups remain owned; has_key45.13 next. No new
combined frozen28/full-suite result is inferred.

TYPE45.13 reconciles only has_key2 source assertions/2 healthy ->4 GREEN, with
public native/fresh3/direct producer6 and unchanged production. Retained45.4
independently records those same two failures. Ten last-selected groups remain
owned; Hash snapshot45.14 follows. No combined28/full-suite status is inferred.

TYPE45.14 subsequently reconciles Hash-snapshot1 old owner regex/3 healthy ->
4 GREEN, retaining original assignment DSL/other3 assertions and production.
Public native/fresh5 verify values/source/once-only/default behavior; no new
copy-depth or alias inference. Nine last-selected groups remain owned; set_key
45.15 follows. No combined28/full-suite status is inferred.

TYPE45.15 reconciles set_key2 old source assertions/2 healthy ->4 GREEN with
public native/fresh2/direct eager-key3, original expressions/healthy checks and
production unchanged. Eight last-selected groups remain owned; rename_key45.16
follows. No new combined28/full-suite status is inferred.

TYPE45.16 reconciles rename_key1 nested-presence source assertion/3 healthy ->
4 GREEN with public native/fresh3, original expression/healthy controls and
production unchanged. Existing Perl collision stays backend-qualified under
FUTURE5, not portable parity. Seven last-selected groups remain owned; drop_keys
45.17 follows. No combined28/full-suite status is inferred.

TYPE45.17 reconciles drop_keys1 nested-presence source assertion/5 healthy ->
6 GREEN, retaining the embedded permanent18 and original expression/controls.
Public native/fresh2 and unchanged production hold. Six last-selected groups
remain owned; pick_keys45.18 follows. No combined28/full-suite status is inferred.

TYPE45.18 reconciles pick_keys1 nested-presence source assertion/3 healthy ->
4 GREEN, with public native/fresh2/per-key8 and production unchanged. Diagnostic
prefix repair restores earlier local inputs and verifies three no-overwrite
controls. Five last-selected groups remain owned; tagged-record helper45.19
follows. No combined28/full-suite status is inferred.

TYPE45.19 reconciles tagged-record1 obsolete map/split source assertion/6 healthy
->7 GREEN, retaining original helper/initializer/metadata controls. Public native/
fresh2/direct producer36 pass with production unchanged. Four last-selected
groups remain owned; aggregate bare-read45.20 follows. No combined28/full-suite
status is inferred.
