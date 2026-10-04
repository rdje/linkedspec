---
id: perl-helper-scan-occurrence-provenance
title: Raw helper spelling cannot recover exact scanner occurrence identity
answers:
  - "can helper events be mapped to source by raw text alone"
  - "why can skipping quoted helper positions reorder genuine calls"
  - "why does earliest raw matching drop a genuine return"
  - "where is the scanner family source provenance inventory"
date: 2026-10-04
status: measured diagnosis; producer provenance repair pending
tags: [perl, actionir, scanner, source-ownership, event-order]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0 owns two seed0 public AST/substitution/diagnostic probes, independent source occurrence positions and two actually executed candidate mapper failures at unchanged production ea45d933d. Parent .7.2.2.0 owns the decomposed repair."
reverify:
  - "At diagnosis production ea45d933d, run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-mapping.py. After implementation use the committed frozen captures and the historical claim rather than rerun changed scanners as the old baseline."
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-review.py"
---

# Raw helper spelling cannot recover exact scanner occurrence identity

For `return('return("x")'); return("x")`, the current public helper array contains
two return_general events. LegacyRules consumes the first entire outer call;
there is no separate scanner event for its quoted inner return. Earliest per-raw
matching maps the second real event to quoted position8 and discards it, instead
of retaining the real call at scalar position23. The typed AST independently
retains both real call spans and the first string argument.

For `text="set(counter,1)"; set(counter,2); set(counter,1); return(counter)`, the
current set_value array contains three events: quoted A, real B, real A. A per-raw
mapper that skips quoted positions assigns the first A event to real position39,
retains B at23, then drops the last A because no equal source remains. The result
is A/B, while the independent real occurrence list is B/A. These are measured
candidate simulations on unchanged production events, not production mutants.

The existing CanonicalEvents occurrence-order repair preserves its input stream;
it cannot repair occurrence identity lost before that stream is assembled. Sorting
all events globally by source position would also change existing contract-family
precedence and composed traversal. Keep scanner match provenance and original
argument/literal bytes, with explicit translations for recursive source frames.

The source-bound inventory covers the seven exact ScannerCore families and counts
literal construction sites, not runtime reachability or all language contracts.
FlowRules includes six nested/composed calls: inline switch cases/defaults recurse
into argument expressions, marker scanners recurse into blocks, and case/default
dispatch combines those scans. Ordinary if/else scans do not recurse through the
same helper mechanism. A generic cursor over whole raw events cannot infer all
of these source frames. Producer provenance, lexical membership, exact replacement
and recurring/canonical acceptance therefore have separate task-tree owners.
