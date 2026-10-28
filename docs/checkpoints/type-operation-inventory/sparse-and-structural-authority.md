# Sparse AND structural slots and reference repair target

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.39; reconciliation39.0.
Status: existing authority reconciled; Perl39.5/39.6 repairs precede independent peer intake39.1-.4. No production edit or new contract here.

## Existing authority

ADR0044 gives AND its consuming ordered algorithm; ADR0047 preserves required
slot identity, including duplicates and resetting the first required slot at
each accepted repetition. The canonical sparse-slot fact, normal
`t/sparse_and_action_slots_perl_regression.t`, and both book chapters distinguish
the full local structural sequence from sparse action dispatch. For same-owner,
valid strictly increasing sparse references, consume every authored local regex
in order, including edge-less delimiters, and execute only the declared actions.
Cross-owner, reversed, or duplicate action references keep their compiled
dependency sequence; do not sort/deduplicate them or filter the regex catalog.
The incoming edge's match belongs to the caller. Entering a child does not
silently skip the child's structural slot0; direct and indexed incoming paths
must honor that distinction. Full entry/boundary catalogs remain available.

ADR0048 covers repeated CHOICE action-return collection. It does not define a
new repeated-AND return policy. Preserve existing AND I/LS/action/IT/E ordering,
whole structural group counts, failed minimum behavior, return/unwind and live
cursor/capture effects; use non-returning actions and IT/E collection to
distinguish them. Early-return/cursor38 and no-edge lifecycle27 stay separate.
A constant BODY result cannot establish the complete algorithm. The extra
reversed/duplicate probes consume two slots but return[] rather than their E
value: public source shows the plain ordered builder drops ecode and the emitter
hardcodes its collection return. This is an additional concrete shape of the
existing lifecycle divergence owned SESSION-STARTUP-READING.27. Reconcile/repair
it there before full admission; do not bless these E outputs as portable policy
or fold lifecycle normalization into39.5. Use explicit final action returns for
healthy order/effect controls while that owner remains open.

## Required reference repairs

39.5: Plain same-owner multi-regex AND with one sparse action must select the
existing ordered structural family. Current Perl eligibility selects
`_default` / v2 `default`, unlike protected two-action and repeated sparse cases.
For `Value::AND` with `/H/`, `/cat/` and only `->Value[1] return("BODY")`, direct
`Hcat` must return BODY at4 and direct `cat` must miss. A parent consuming H first
requires `HHcat`; parent `Hcat` is not a successful full child parse. Indexed
parent entry consuming cat similarly requires `catHcat`. Preserve exact empty
String, Number0 and null returns rather than deriving matching from truthiness.
Retain non-returning effects and E results, missing structural tail/prefix,
three-regex/one-action, repeated complete-group and minimum controls, one-regex
compatibility, cross-owner/indexed/reversed/duplicate dependency order, and
normal protected sparse/duplicate identity fixtures.

Explicitly record corrected derived v2 row `default` -> existing
`and_acode_seq` for this formerly misclassified shape. Existing minimal
`{label,family}` rows, ten-family vocabulary, format2, validator and structural
authority are unchanged. Do not conceal that output change. Regenerate affected
standalone artifacts to obtain a repaired handler. New fields/family meaning
or authority need a separately owned canonical contract decision; full39/23.4
and final clean push admission remain mandatory.

39.6: Three blind `.push` controls finish native execution, compile and load
standalone source, then fresh execution recurses without progress. Emitted
post-call code already calls Value and then calls Top again inside push; native
Top's guard suppresses re-entry, while fresh execution times out. Reconcile the
published child-result/post-call/fluent overload and recursion contracts before
changing lowering. Native termination does not prove its collected value right.
Test actual child result, call/effect counts, cursor, legal consuming recursion,
and non-progress termination in bounded processes. Do not add a product timeout
or conflate this with the separately owned AND_BCODE unbound-input handoff bug.

## Evidence and limits

`sparse-and-structural-authority-intake.json.gz` retains exact producers, authored
inputs, emitted/native code, descriptors, metadata, logs and phase statuses.
First17 cases yield17 native prepared observations,14 completed native/fresh
pairs and3 fresh-only exit124 timeouts. All10 additional entry/dependency/shape
controls complete; protected normal3 groups pass. An earlier unbounded producer
hung with deep recursion and was interrupted130; retained, not completed parity.
The extra cross-dependency direct case initially hit the producer's30s build
deadline; an identical source/phase-bound retry completed. Both epochs are
retained; no product failure or performance cause is inferred from that cutoff.
The first strict summary reader rejected this incomplete build as expected;
its source/error are retained before replay against the completed retry.
The refined reader validates/retains known forward-progress trace pairs and
rejects unknown stdout. No Rust/Dart/Julia defect or Lua repair is inferred.
Initial Lua-null/Hcat versus Perl-BODY was a real discrepancy but an invalid
basis for outgoing-only semantics: the Perl reference is broken.

Independent39.1 Rust/39.2 Dart/39.3 Julia/39.4 safe installed Lua intake follows
39.5/.6, selecting actual defects against existing structural authority. Keep
installed host limits and unsafe-pattern exclusions. Full admission,
registration, document-pressure and declared-host owners stay open. Failed
historical stable-ID lookup is scheduled under20.1 before admission; its cause
is unassessed and does not establish lost history. Preserve immutable history.
