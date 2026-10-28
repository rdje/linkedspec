# Ordinary recursion progress parity for blind post-call execution

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.39.6; reconciliation39.6.0.
Status: semantics reconciled and shared native guard39.6.1 extracted/targeted-checked; emitted wiring39.6.2 is now targeted-checked.

Published push(rule) calls that rule and appends to the current rule accumulator.
Blind fluent rendering injects the parent label into helper-style post-call
code. Thus Top =>Value .push first calls Value through the Core-owned bridge,
then executes push(Top), a recursive Top call. Preserve that existing meaning;
do not silently redefine it as appending Value's already computed result.
The public substitution probe and actual native/emitted source prove the two
calls. A suffix-free blind call already collects child results normally.

At clean92a6eeb95 the three process-bounded authored controls all build/load and
finish native execution. Blind push returns[BODY]/cursor4, direct no-progress
self-call returnsnull/cursor0, and no-tail blind returns[BODY]/cursor4. The first
two standalone paths hard-time out in fresh_execute after5s; the control agrees.
These are two incomplete fresh executions, not values or parity credit. Exact
producers, cases, native/emitted source, descriptors, phase logs and known trace
pairs are retained in blind-postcall-progress-authority-intake.json.gz.

SpecEntry::_build_runtime_handler currently owns an ordinary active-entry set
keyed by descriptor, rule label and cursor (undefined cursor sentinel-1).
Re-entry at an already-active key cuts ordinary recursion; recognition and
recursive-observation scopes instead reject through their existing typed owners
before a child invocation is entered. Native eval cleanup releases the active
key before forwarding errors. Compiler emits raw CODE handlers and never
installs this ordinary wrapper in the standalone table. Existing invocation
guards reject typed scoped cycles but do not cut unscoped ordinary recursion.
No new termination policy or helper overload is needed to close this gap.

39.6.1 extracts that same guard into RecognitionTransactionRuntime, the existing
live/generated progress owner. Keep one implementation of key/check/rejection/
cleanup, retain the trace topic and early rejection before invocation frames.
Use an idempotent scope token with explicit native eval release and exception-
safe destruction; preserve caller error/control identity and cleanup after any
return or throw. No package-state migration or new source/frame/format policy.

39.6.2 installs shared guarded wrappers once over emitted rule CODE entries at
descriptor construction, before any Execute call; every recursive table call
then passes the guard. Preserve the original handlers, argument/result context,
post-call work, errors, metadata/plan, ten-family vocabulary and v2 format. No
product timeout, call removal, consuming-recursion cutoff or blanket same-label
ban. Validate direct/mutual cycles, consume-before-recurse, repeated parser use,
distinct descriptor identity, early returns and exception/control cleanup, plus
existing typed recognition/observation dependents and the retained blind cases.
Keep existing native child-error delivery41 separate. Full39/23.4/final clean
push gates remain after focused repairs and admission prerequisites.

39.6.1 now centralizes the existing key and typed rejects in runtime scope
entry/release. Native8 public controls preserve behavior; new shared4 bring
final12 groups/no skips, syntax2 passes. Actual native handoff, idempotent token,
descriptor/rule/cursor distinctions and caller/thrown error cleanup are covered.
Debug trace topic stays; emitting file follows the shared owner. Packet:
shared-rule-progress-intake.json.gz. Standalone ordinary wiring is still open.

39.6.2 installs the shared wrapper once over all emitted CODE table entries.
Unchanged13 groups5 fresh timeout RED/final13pass; nearest15 and syntax2 pass.
All12 actual emitted source pairs differ only by registration, metadata stays
identical, native SpecEntry unchanged. Context/aliases/opaque error identity and
cleanup are covered separately. Old standalone sources need regeneration;
runtime update alone cannot add registration. Exact packet:
emitted-rule-progress-intake.json.gz. Full portable admission remains separate.
