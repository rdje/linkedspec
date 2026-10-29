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
