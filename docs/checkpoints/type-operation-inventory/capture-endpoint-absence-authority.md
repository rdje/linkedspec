# Capture endpoints before a local match

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.40.0; independent repairs40.1-.5.

This target applies existing ADR0056 sections1/2/4/9/19/21 and the admitted
local-match presence contract. It introduces no public helper, value, schema,
diagnostic or cursor policy. Compatibility preserves valid values; uninitialized
arithmetic and ambient package state do not establish a missing match endpoint.

- The anonymous rolling boundary is distinct from the current local-match left
  edge, incoming entry match and live cursor. Selecting the root supplies no match.
- capture_slice() and capture_slice_len(), plus their existing aliases, require
  an available current local-match left edge and a valid ordered same-source span.
  Missing endpoint yields undef without constructing an invalid typed span.
- capture_take()/capture_take_len() use that same span. Only a successful read
  advances the anonymous boundary to the live cursor; unavailable/invalid reads
  return undef and leave it unchanged. Other take families keep their endpoints.
- A real zero-width match is present. Empty text/zero width stay defined and skip
  coalesce defaults. A zero-width match after a prefix can capture that prefix.
- capture_slice_pos/line/col report the available rolling boundary independently.
  Through-cursor and rest readers use their own available endpoints, even before
  a match. Moving cursor/boundary does not manufacture local-match presence.
- Every register comes from the owning invocation. Arbitrary package globals,
  previous execution residue and a parent's incoming match cannot create a local
  match. No new exception is needed for ordinary missing state; host warnings are
  defects. Existing typed diagnostics retain their actual invalid-value owners.

tests/fixtures/capture_endpoint_absence.json freezes16 authored source controls:
initial blind/regex I, ordinary root execution resetting a seeded input pos,
incoming/direct/nested I, in-action cursor/boundary moves, real empty/zero/Unicode
matches and unavailable/successful text+length takes. Fourteen projections and
lazy default effects distinguish unavailable endpoints from valid zero values.
Public Perl native and a separate process loading generated code record clean and
poisoned package state. Six valid-match/take controls pass; ten absence groups are
actual RED before repairs. Full input/source/metadata/module/error/warning records
are retained. This is bounded diagnostic/authority proof, not repaired admission.

The typed-source neutral checker231 mutations and existing Perl structural
presence4 groups pass. Initial target setup incorrectly assumed public execution
preserved input pos, selected a Child marker as root and used a return edge that
never invoked its child. Those cases were corrected before qualified observations.
UTF8 artifact writes/loads, typed-error JSON normalization and known trace records
were corrected in the instrument. Initial epochs remain recoverable without
product failure credit. Broader SESSION17 host isolation and native child error41
remain separate;40.1 must fix the narrow verified capture/register mechanism.

No producer changes in40.0. Each40.1-.5 backend gets an independent current intake,
RED/GREEN, direct dependents and a commit before full23.4/push. Final canonical
selection must include each new regression; pressure/Phase0/declared-host and
other admission prerequisites retain their existing owners.

## Perl repair40.1 (2026-10-29)

Handler preambles now bind existing local registers before I/blind code; selected
branches keep their existing bindings. Seven anonymous text/width/take/alias
lowerings share defined-match/ordered-span guards and mutate takes only after a
successful read. Current16-source native/separate-process clean+seeded intake has
six healthy/ten RED ->16pass, preserving all six healthy outcomes and complete v2
metadata/minimal plans. Ordinary16/typed-source4/Number7 groups pass27 total.
Same16 old modules still reproduce exact values/cursors/structured errors/warnings/
metadata in32 calls; raw host-address strings are excluded only when exact typed
fields exist. Regenerate affected emitted parsers. Packet perl-capture-endpoint-intake.json.gz
retains closure. New normal/canonical registration23.4.1 and independent40.2-.5,
broader SESSION17/other prerequisites and full admission remain separate.

## Rust repair40.2 (2026-10-29)

Independent16-source native/reconstructed/plan/separate compiled emitted intake
has nine healthy/seven RED ->16pass. Four anonymous match-start helper guards use
existing match_present before span projection/take mutation. Real empty/zero and
Unicode controls, nine healthy observations and all parsed/compiled/serialized/
plan/emitted bytes/public metadata remain exact. Same16 baseline source modules
relinked against the repaired runtime pass: rebuild applications, no source
regeneration/format change. Endpoint1/Number6/alias1 integration groups and10
focused anonymous library tests pass. Fresh lock identities match native lock.
Cursor values are authored DSL observations, no direct native final-state API.
Packet rust-capture-endpoint-intake.json.gz retains actual proof. Temporary probe
is archived/removed; normal target is capture_endpoint_absence.rs with no allocator.
Independent40.3-.5/selection/other prerequisites/full admission remain separate.

## Dart repair40.3 (2026-10-29)

Four anonymous caller guards require nullable localMatch for match-start text/
width and zero-argument takes. Shared named/writer fallback remains47-owned after
two public named controls confirm manufacture/mark movement; no fresh named proof.
Core16-source SDK/restored/plan/separate VM6healthy10RED ->16pass, exact input/
emitted/metadata and six healthy full results/traces unchanged. Same baseline
modules run against updated runtime; no regeneration, rebuild AOT applications.
Four selected files46 tests/fatal changed-file analysis/format pass; whole-package
SDK deprecations2.25 stay separately owned. Packet dart-capture-endpoint-intake.json.gz
retains closure/adjacent discovery. Julia40.4/Lua40.5/41/47/45 and canonical selection/
other prerequisites/full admission remain separate.

## Julia compatibility40.4 (2026-10-29)

Independent current16-source native/restored/plan/separate-process emitted Module
baseline passes all16 without runtime edits. Existing nullable local_match endpoint
returns nothing before span/take mutation; cursor/rest/real zero remain distinct.
New registered normal112/Number75/aliases141/null390 assertions pass718 total with
depwarn=error. Rival empty-text expectation fails3 value routes,109 pass/0error;
this is an oracle control, not product RED. Runtime/compiler/emitter/shared fixture
are exact base bytes. Full results/Unicode cursor/trace/inputs/generated/metadata
retained in julia-capture-endpoint-intake.json.gz. No generation/dependency/schema/
policy change, isolated package, named/peer or full admission claim. Lua40.5 and
41/47/45/canonical selection/other admission prerequisites remain independently owned.
