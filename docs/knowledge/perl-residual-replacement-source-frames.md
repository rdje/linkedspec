---
id: perl-residual-replacement-source-frames
title: Perl replacement loses selected occurrence authority across original and rewritten frames
answers:
  - "why can current Perl replacement still corrupt an identical quoted helper twin"
  - "does selecting an executable helper origin locate its rewritten occurrence"
  - "where are scanner source origins lost before canonical replacement"
  - "why are original and rewritten replacement coordinates different"
  - "does a direct diagnostic owner have the callable binding context of the compatibility facade"
  - "which task owns the selected residual replacement repair"
date: 2026-10-08
status: bounded diagnosis at fa9b7608e; replacement repair .0.3.1 pending
tags: [perl, actionir, replacement, source-provenance, occurrence, quoted-data]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0 retains original/corrected Toolbox source, AST, private scanner references/origins, actual copy identities and reached lookup frames, descriptors, dump/emitted/native/fresh errors and independent literal/value/interval oracles. Production is unchanged fa9b7608ed9e49712129bb5456d75d118e7207a0."
reverify:
  - "At the owning committed diagnosis boundary, run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-review.py. Later production repair requires its own retained before/after proof; do not refresh these historical captures."
---

# Selection does not locate the rewritten occurrence

For `quoted='out=matches("x", /x/)'; out=matches("x", /x/); return([quoted,out])`,
the typed assignment and actual selected scanner origin identify the executable
assignment at Unicode scalar interval32–53. RewritePipeline's original-source
lookup reaches32. After the preceding declaration becomes `$quoted = ...`, the
real assignment begins35, while the identical quoted payload begins11. The
actual rewritten-source lookup starts from zero and returns11. The resulting
literal contains an assignment expression and the real host call stays unlowered;
both native and independently emitted handler compilation fail. The reverse
order preserves the independently authored literal and result1.

Scanner's compiler-only branch returns selected event objects after private
membership, but does not forward the source-origin sidecar. Diagnostics constructs
a new helper event while retaining its argument object. CanonicalEvents::Core
constructs a new canonical event and argument hash. The observed reference
identities distinguish both copies from the real scanner event; public packets
have no origin fields. RewritePipeline then searches equal raw text in the
original and rewritten actions instead of retaining that occurrence authority.
The two reached calls are separate obligations; a correct original lookup does
not make the later replacement correct.

Interleaved and distinct equal spellings, both quote forms, Unicode/CRLF and a
valid two-argument `cat` expression retain the same distinguishing replacement
gap. Real `set` after a quoted twin instead reaches an unlowered host-call runtime
failure. Nested `if`, deferred body, repeated/distinct real assignments, quoted
data alone and reverse-order controls remain healthy in this bounded population.
Successful values do not establish readiness; unresolved literal/marker origin
still belongs to .7.2.2.1, and source comments to .7.3.

The initial generated-data control incorrectly used one-argument `cat`. Its
unsupported marker and null result are retained, then an explicit new population
uses `cat(value, "")`. No arity repair or new syntax follows. The initial deferred
probe also compared the compatibility facade with a direct diagnostic-owner call.
The facade establishes bare-type/write-target binding context; the direct call
does not infer that context and emits an unsupported `cb` marker. Corrected
instrumentation compares observed and unobserved calls through the same facade
and retains the direct-owner channel separately. Its original early rejection
does not establish a deferred runtime defect.

Replacement .0.3.1 must preserve real event-bound origins through these copies
and translate original intervals across actual edits. Equal-raw pairing, a global
source sort and rescanning generated literal contents cannot establish occurrence
identity. Keep existing contract-family order, consumed/exclusive ownership,
genuine raw spans, original arguments, callbacks and caller error state. Any
broader recursive or grammar boundary requires its own task before widening the
repair. Committed recurrence and canonical acceptance remain .0.3.2-owned.
