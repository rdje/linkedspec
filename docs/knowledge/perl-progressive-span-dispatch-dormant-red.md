---
id: perl-progressive-span-dispatch-dormant-red
title: Perl progressive span dispatch reaches descriptors but stops at one missing dedicated ActionIR node
answers:
  - "where is the dormant Perl progressive span dispatch RED consumer"
  - "what is the first Perl dispatch_span RED failure"
  - "does Perl parse dispatch_span yet"
  - "why is Perl progressive span dispatch unavailable"
  - "which progressive span dispatch node is missing in Perl"
  - "does the staged Perl registry resolve expr-v1"
  - "how does generated Perl source currently lower dispatch_span"
  - "where will the private Perl progressive registry attach"
  - "does the Perl progressive consumer run in canonical CI"
  - "which leaf owns Perl progressive authority and carrier integration"
  - "does the Perl progressive RED change production behavior"
date: 2026-08-17
status: current dormant RED; Perl authority, integration, and admission pending
tags: [perl, progressive, dispatch, source-span, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.6.2.0 adds t/progressive_span_dispatch_perl_contract.t at its final path without ordinary or canonical registration. LinkedSpec::call_spec_handler_subst produces one dispatch_span marker inside one LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER sentinel. The exact authored assignment reaches return_descriptor, records ordinary ASSIGN/RETURN nodes, reports dispatch_span unresolved, and omits PROGRESSIVE_DISPATCH_SPAN. The consumer proves emit_generated_source produces independently loadable source with the same single sentinel and a null result. LinkedSpec::StagedParserRegistry rejects expr-v1 at resolve, proving the existing function-body adapter is not the progressive registry. The live and generated execution wrappers already accept one invocation-options hash immediately above descriptor execution; .14.6.2.2 can attach a private per-invocation progressive authority there without serializing parser coderefs, registry handles, source authority, or mutable execution state. Eighty-three assertions pass before the sole missing-node RED. Production parser/compiler/runtime/generated-source behavior and every ordinary/canonical route remain unchanged."
reverify: "perl -Iperl -c t/progressive_span_dispatch_perl_contract.t && ! prove -q -Iperl t/progressive_span_dispatch_perl_contract.t && prove -v -Iperl t/progressive_span_dispatch_perl_contract.t 2>&1 | rg -n 'missing node=\[PROGRESSIVE_DISPATCH_SPAN\]|Failed 1/|Result: FAIL' && ! rg -q 'progressive_span_dispatch_perl_contract[.]t' tools/run_ci_local.sh"
---

# Perl progressive span-dispatch dormant RED

The final-path consumer is t/progressive_span_dispatch_perl_contract.t. It is
tracked for the Perl lane but deliberately absent from the explicit commands
and tracked-file list in tools/run_ci_local.sh; `.14.6.2.3` owns admission.

This is not a grammar-parse failure. The exact reserved assignment constructs a
descriptor. Current Perl lowering records its span construction and assignment
as ordinary `ASSIGN` plus `RETURN`, replaces the nested `dispatch_span` call
with one unsupported-helper sentinel, reports that helper unresolved, omits
`PROGRESSIVE_DISPATCH_SPAN`, and keeps the rule language-agnostic blocked. The
separate `StagedParserRegistry` also rejects `expr-v1` at resolve; it remains the
narrow function-body adapter and grants no accidental progressive authority.

Everything before that boundary is green. The consumer derives the complete
two-entry registry, two-source/eight-view, six authority, six cancellation,
eight chain, four execution, twenty-six diagnostic, nine-leg rollout, and
eighty-six-mutation inventory from the neutral contract. Its sole failing
assertion requires the dedicated node with zero unresolved or raw dependencies.

The private carrier seam is the existing invocation-options hash accepted by
both the live wrapper and generated-v2 `Execute`. `.14.6.2.1` owns an immutable
registry plus bounded source-view, capability/policy/ceiling, cancellation,
budget, chain, isolation, detachment, and diagnostic authority independent of
ActionIR. `.14.6.2.2` owns the dedicated node and attaches a fresh per-invocation
authority at that wrapper seam across live, reconstructed, generated-plan, and
independently loaded emitted source. No generated artifact may serialize live
authority. `.14.6.2.3` alone registers the unchanged green consumer and promotes
the Perl rollout row.

## Links

- Neutral authority: [[progressive-span-dispatch-audit-plan]].
- Staged registry boundary: [[staged-parser-registry-current-boundary]].
- Typed source values: [[perl-typed-source-location-values]].
- Generated carrier: [[perl-generated-source-contract-v2]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.2.0`.
