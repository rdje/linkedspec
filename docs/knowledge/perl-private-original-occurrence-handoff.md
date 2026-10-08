---
id: perl-private-original-occurrence-handoff
title: Perl compiler copies retain original occurrence authority within one rewrite invocation
answers:
  - "how do selected scanner origins reach canonical replacement events"
  - "does SourceOrigins add public source fields to ActionIR events"
  - "how do synthetic canonical events get original statement coordinates"
  - "can a matching helper queue borrow missing source authority"
  - "why does private source authority retain actual event references strongly"
  - "does private origin handoff fix the quoted first replacement failure"
date: 2026-10-08
status: private handoff verified under .0.3.1.0; mapped replacement remains .1.1-owned
tags: [perl, actionir, source-provenance, occurrence, canonical-events]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0 retains complete original/current source-bound captures, corrected original RED7/GREEN10,42 public pairs,144 unchanged consumers per epoch,11 effective source inverse controls and eight evidence/history RED. Independent recovery verifies all5185 original regular Git inputs and81 prior guard hashes."
reverify:
  - "At the owning committed private-handoff boundary run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-review.py. Later replacement changes require their own proof; never refresh original captures."
---

# Actual references carry original occurrence authority

RewritePipeline creates a private SourceOrigins scope for one action invocation.
The compiler scanner records only selected real event references from the existing
provenance sidecar. Diagnostics copies that authority to its actual helper object
while retaining the original arguments; CanonicalEvents::Core transfers it to the
actual canonical copy while retaining existing normalized argument construction.
No public event/diagnostic fields, callback arguments or family order change.

Entries keep the original source, validated half-open Unicode scalar coordinates,
raw spelling and actual event reference. Strong retention prevents address reuse
inside the invocation. Equal-valued copies have no authority until the actual copy
seam transfers it. Queries return detached coordinates. Conflicting coordinates for
one reference stay ambiguous; invalid, foreign or mismatched authority is declined.
Nested invocations isolate their maps and restore the enclosing scope on errors;
the finished scope retains no global cache.

Canonical raw fallbacks and the existing receiver/registered/bound value-drop
producers use the canonical splitter's actual returned-array/index frames.
Unchanged entries can retain their own original frame; unknown or copied arrays,
changed entries and foreign source cannot borrow another occurrence. A helper
queue match with missing scanner authority remains opaque even when statement text
matches. The frame collector's caller-error restoration is compensated at the
canonical seam so the actual dependency's successful error effect remains visible.
Scalar callback context, arguments, once-only invocation and authored exceptions
remain unchanged in the measured controls.

The original replacement search/edit body is byte-exact after removing the new
invocation/import wrapper. The quoted-first failure remains present. Private
handoff supplies original authority for .1.1's subsequent interval/edit translation;
it does not repair replacement or unresolved-helper/readiness classification.
Public comparison retains complete raw channels and normalizes only dated trace
prefixes, the exact supplied-tree owner locator and a source-validated one-line
import offset at the two unchanged lookup sites. No broad error/value masking.

One authored copied-array expectation initially had the wrong cardinality. Its
original source and complete RED survive; only [0] becomes [0,0] before the corrected
original RED. The new Core import exposes one extra parent step in its existing
standalone path bootstrap. Exact initial source/no-I syntax RED and corrected GREEN
survive; the interrupted initial after capture is explicitly incomplete. The fresh
final after capture governs acceptance. No submodule implementation or other
repository is inspected or changed for these corrections.
