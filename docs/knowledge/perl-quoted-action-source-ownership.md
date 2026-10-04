---
id: perl-quoted-action-source-ownership
title: Quoted action data needs executable occurrence and diagnostic origin ownership
answers:
  - "why does quoted if true return correctly while ActionIR readiness is false"
  - "does current Perl lowering still corrupt quoted set text"
  - "why does an authored unsupported helper marker string create a false blocker"
  - "can unresolved diagnostics ignore every quoted string"
  - "where is quoted helper source ownership diagnosed"
date: 2026-10-04
status: current diagnosis; implementation remains pending
tags: [perl, actionir, quoted-data, canonical-events, source-ownership, diagnostics]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1 owns current public AST/substitution/descriptor/native/fresh probes, complete trace/TAP streams and independent source/value oracles. Production activation is012038a637e727a57fe8ac387b27d7267f76f465. Pending .7.2.2 owns repair, .7.2.3 independent acceptance; SESSION-STARTUP-READING.18 retains broader ownership. PERL-TRACE-UNICODE-SINK.1 separately owns the exact Unicode trace warning."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py trace"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-review.py"
---

# Quoted action data needs executable occurrence and diagnostic origin ownership

The quoted control `return("return(inner); if(true)")` has a typed string argument.
Its actual lowering trace reaches a residual `if_flow` replacement, then
`unbalanced_flow_stack`; `RewritePipeline.pm` returns the original action text.
The healthy literal value is therefore a fallback result, not evidence that the
phantom helper was excluded. False canonical/control/unresolved metadata survives.
For accepted nested `cat` and `matches` fixtures, that same fallback leaves an
unlowered host call and fails execution on both routes. Native context names
`runtime_handler:rule_handler_eval`; independent emitted execution names
`generated_execution_failed`. Full original error details, stdout traces and warnings
remain in the captures. Their runtime fix belongs to .7.2.2.0.

The primitive witness `return("set(counter, 2)")` instead retains the rewritten
literal contents `$counter = 2`. `Scanner/PrimitivePipelineRules.pm::_scan_contract_set_value`
and `Scanner/FlowRules.pm::_scan_contract_if_flow` match unmasked action text.
`ScannerCore::scan_contract_ir_events` dispatches that original text; Diagnostics collects
the returned events by contract. `CanonicalEvents` queues them, consumes top-level
matches, then retains residual occurrences. It is not a second assignment lexer.
`RewritePipeline::_find_source_stmt_span` checks text/identifier boundaries but lacks
quoted-occurrence ownership; residual lowering can replace a substring inside data.

`MethodExpr::_helper_pattern_view` masks recognized helper slash-pattern ranges, not
general authored string contents. `EmitContext::_mask_action_code_literals` protects
working-variable discovery and is not the helper/diagnostic authority. Existing lexical
and slash-call contracts must be respected when selecting the bounded repair.

An authored literal `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr` and actual
unsupported `substr("abc")` both reach Diagnostics' `unsupported_ast_helper_call`
text scan. The first marker is data. MethodLowering deliberately emits the second
inside a generated quoted expression returning `undef`; it represents a real blocker.
Blanket quote masking of lowered text would hide genuine unsupported calls. Repair
needs diagnostic origin as well as executable source membership.

The dated September6 primitive fact is recovered from its actual recording commit
3e8b05cd343dafa0b67c536bfe0c9e6b52f074c7, which names reading baseline
baeb984e36a94a15951cd23d4c52def5064cdaca. It contains a qualitative Toolbox report,
not a complete raw capture suitable for a source-identical before/after claim. Current
source-bound captures re-establish the behavior; they do not manufacture missing
historical streams or close the broader startup reading/carrier task.

Current raw `i+1`, genuine helper/control calls, mixed real/quoted assignments,
accepted quote/escape/Unicode/CRLF/regex/nested/deferred data and comments are separate
controls. Runtime source presence and desired literal values are different oracles;
host raw results do not admit portable arithmetic. The source-comment classification
repair remains .7.3.

The Unicode trace capture retains the actual Trace.pm:199 warnings and complete raw
trace bytes. Its preserving command exits1; this is not quiet trace acceptance or a
quote grammar failure. The separately scheduled sink repair must not suppress warnings.
