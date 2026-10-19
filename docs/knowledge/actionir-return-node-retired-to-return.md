---
id: actionir-return-node-retired-to-return
title: The canonical action-IR return node is RETURN; RETURN_A/RETURN_M and the return_a/return_m/return_array helpers are retired (→ RAW_PERL fallback)
answers:
  - "what canonical action-IR node does a return lower to in linkedspec"
  - "is there still a RETURN_A or RETURN_M canonical action-IR node"
  - "what happened to return_a / return_m / return_ma / return_imatch / return_im / return_array"
  - "why do method_like phase0 tests asserting RETURN_A fail"
  - "what is the canonical replacement for the retired return_* helpers"
date: 2026-10-19
status: current
tags: [actionir, canonical-nodes, return, compat-alias-retirement, regression, phase0]
evidence: "TYPE-REFERENCE-BOOK.1.1 public lowering/descriptor/value/generated-source observations retain current RETURN versus retired RAW_PERL and removed-selector controls. June triage descriptions remain dated history; current public descriptors do not prove code-slot equivalence."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/type-reference-migrations/publish.py. Prior:1a8b20201."
---

Current `return(...)` and `return_undef()` contribute the canonical ActionIR
node `RETURN`. The demonstrated retired `return_a`, `return_m`, `return_ma`,
`return_imatch`, `return_im` and `return_array` calls pass through the public
lowering probe unchanged and contribute `RAW_PERL` fallback metadata. Their names
are not supported modern return helpers.

Use `return(value)` or `return(array(...))`, then verify both the exact payload
and the actual descriptor. See [[retired-return-helpers-canonical-rewrite]] for
current constructor/copy recipes and the corrected historical flat-group shape.
Removed `array(IDENTIFIER)` selectors are compile errors; a recipe containing one
cannot establish a canonical return-node result.

```perl
my $s = "Top: /x/\n I { return(1) }\n";
my $d = LinkedSpec::Get(\$s, return_descriptor => 1);
my $nodes = $d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes};
```

The October19 proof checks current replacement nodes, zero fallbacks, parser
values and independently loaded generated parsers. It does not infer emitted code
from absent uppercase descriptor slots. Use `parser_source_ref => \$source` to
capture source; [[phase0-code-slot-equivalence-observation-gap]] explains the
older vacuous slot comparisons and their separate repair owner.

## Dated triage context

The June21 card described PHASE0-BACKHALF-TRIAGE cluster B (76 subtests), its
B2 node-token assertions (~55+3), and B1 helper rewrites (~18+3). These remain
historical triage descriptions, not a current population or automatic re-blessing
recipe. Retired syntax must be rewritten first; merge expected RETURN hit counts
only after observing the actual descriptor and distinguishable output.

The older warning about cluster-C emit_context tests and helper-event kinds
remains a scope limit: `RETURN_A` in an old helper-event record is not evidence
that the canonical node is still admitted. Never perform a global token swap.
Original dated bytes are retained at accepted `1a8b20201` and in this leaf's
before-image. Related: [[blind-call-collection-shape]], [[actionir-lowering-stack]],
[[method-like-dsl-migration-status]].
