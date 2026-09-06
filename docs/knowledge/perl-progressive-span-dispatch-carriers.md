---
id: perl-progressive-span-dispatch-carriers
title: Perl privately carries progressive span dispatch through four execution routes
answers:
  - "does Perl progressive span dispatch parse privately"
  - "where is PROGRESSIVE_DISPATCH_SPAN recognized in Perl"
  - "how does a Perl parser receive a progressive registry"
  - "which Perl carriers execute progressive span dispatch"
  - "does generated Perl source serialize the progressive registry"
  - "are progressive parser identity and top rule static in Perl"
  - "can Perl progressive dispatch execute inside a recognition transaction"
  - "what happens when the Perl progressive registry invocation option is missing"
  - "why is a progressive assignment not also an ASSIGN ActionIR event"
  - "is Perl progressive span dispatch admitted in CI"
  - "does requiring the Perl Compiler for progressive dispatch eagerly load LinkedRE"
date: 2026-08-17
status: private ActionIR, four carriers, and canonical Perl admission current
tags: [perl, progressive, dispatch, ActionIR, generated-source, invocation-options, transaction, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.6.2.2 adds the exclusive progressive_span_dispatch ActionIR contract/scanner and exactly one PROGRESSIVE_DISPATCH_SPAN event for value = dispatch_span(\"expr-v1\", \"Expr\", span). Static policy requires normalized string-literal parser/top identities and one bare span binding. Runtime wrappers create a fresh invocation from the host-only progressive_span_dispatch option, localize it on the descriptor, and preserve typed failures. Live, reconstructed descriptor, validated generated-plan, and independently eval-loaded generated-v2 source all return the same detached child payload. Generated source contains logical operands/origin only and no registry callback, cancellation token, or compiled authority. RecognitionTransactionPolicy classifies the node as rejected parser_registry_or_staged_dispatch, while runtime transaction visibility supplies a defensive rejection. The runtime resolves RecognitionTransactionRuntime only on an actual dispatch, preserving Compiler require-time LinkedRE laziness. Exclusive statement ownership removes the generic ASSIGN duplicate. The language gate classifies dispatch_span as the fifteenth exact non-public Perl diagnostic, preserving 250 shared names / 126 public Perl calls. The focused consumer passes 125 assertions but remains absent from ordinary/canonical CI; neutral rollout, typed rollout, public/outward surfaces, and Perl admission remain pending for .14.6.2.3."
evidence_update_2026_08_17_admission: "FUTURE-PARITY-BACKLOG.14.6.2.3 requires, syntax-checks, and runs the exact unchanged 125-assertion consumer once in canonical CI and promotes only Perl. Progressive governance is 2/9/86 with four pending-backend guard groups/14 paths plus ten outward guards. Recognition is 134 current + 4 dedicated nodes / 250 calls / 58 mutations. dispatch_span remains the fifteenth non-public classification because Perl-only intrinsic admission does not establish Dart/Julia/Lua shared-helper support."
evidence_update_2026_09_06_reading: "SESSION-STARTUP-READING.3.2.29 re-reads the complete private ActionIR scanner/lowerer and the MethodLowering suffix, with exact baseline identity. The unchanged managed Perl carrier consumer passes 129 assertions; the neutral checker passes 9/9/116 plus public 6/12/10/60. Current prose now follows completed six-runtime recurrence and private public-no-drift closeout; historical admission evidence remains dated. This checkpoint does not rerun the other five runtime routes."
last_verified: 2026-09-06
reverify:
  - "prove -q -Iperl t/progressive_span_dispatch_perl_authority.t t/progressive_span_dispatch_perl_contract.t"
  - "prove -q -Iperl t/recognition_transaction_perl_authority.t t/recognition_transaction_perl_contract.t t/generated_source_contract.t"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "test \"$(rg -c 'PERL5LIB= prove -Iperl t/progressive_span_dispatch_perl_contract[.]t' tools/run_ci_local.sh)\" -eq 1"
---

# Perl progressive span-dispatch carriers

The private authored assignment is recognized by
`LinkedSpec::ActionIR::ProgressiveSpanDispatch`. Its contract exclusively owns
the complete statement, so canonical ActionIR records one progressive node and
does not append a second generic assignment event. The first two operands are
decoded and validated at compile time; the third remains a bare local binding.

`LinkedSpec::ProgressiveSpanDispatchRuntime` accepts authority only through the
host's invocation-options hash. Every top-level invocation starts a fresh core
invocation over a copy of the current decoded input and localizes it in a private
descriptor slot. Missing authority fails with `progressive_registry_missing`.
Generated artifacts import the runtime and serialize the logical parser id, top
rule, span binding, and origin, but never a callback, registry, source handle,
cancellation token, fingerprint authority, or mutable budget.

The same seam serves four tested routes: the live parser closure, a reconstructed
descriptor handler wrapped with `with_invocation`, generated-v2 plan validation
plus execution, and a second independently loaded generated-v2 package. The
result remains the core's deep-detached child payload in every route.

The node is statically classified as the rejected recognition effect
`parser_registry_or_staged_dispatch`; runtime transaction visibility is a second
defense. Recognition-transaction runtime loading is deferred until that dispatch
path, so a require-only Compiler process does not load `LinkedRE`. The final-path
consumer is canonically routed once and the Perl row is complete. The public-call inventory still excludes `dispatch_span`. It is a private dedicated
intrinsic across all six admitted runtimes; private parity does not publish a shared
helper or outward API. [[progressive-span-dispatch-public-no-drift]] owns the completed
9/9 closeout; the dated evidence above preserves the earlier Perl-only admission.

## Links

- Core authority: [[perl-progressive-span-dispatch-authority]].
- Historical RED: [[perl-progressive-span-dispatch-dormant-red]].
- Neutral model: [[progressive-span-dispatch-audit-plan]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.2.2`.
