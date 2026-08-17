---
id: perl-progressive-span-dispatch-authority
title: Perl progressive span dispatch has a private immutable invocation authority
answers:
  - "where is the Perl progressive span dispatch authority implemented"
  - "how does Perl progressive dispatch prevent registry mutation"
  - "can Perl progressive dispatch load a parser during execution"
  - "how are Perl progressive source views bounded"
  - "how do child positions and diagnostics rebase in Perl"
  - "how does Perl progressive dispatch share cancellation and budget"
  - "how are Perl progressive dispatch cycles bounded"
  - "can a progressive child mutate Perl parent parser state"
  - "can a progressive child return a live parser handle"
  - "does Perl progressive span dispatch have public syntax"
  - "is Perl progressive span dispatch admitted"
date: 2026-08-17
status: private authority current; ActionIR carriers and Perl admission pending
tags: [perl, progressive, dispatch, registry, source-span, authority, cancellation, isolation, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.6.2.1 adds perl/LinkedSpec/ProgressiveSpanDispatch.pm and its focused independent consumer t/progressive_span_dispatch_perl_authority.t. The registry deep-copies, validates, and recursively locks exact logical entries whose compiled authority is already a CODE reference; register and load always return the frozen mutation/implicit-load diagnostics. Each invocation owns copied decoded sources, one source identity, the shared cancellation token/callback, clock/deadline, remaining step budget, depth/call bounds, and active chain. A dispatch creates a callback-scoped SourceView, rebases local Unicode-scalar positions/spans/diagnostics to the original source, intersects capabilities/policies, takes ceiling minima, requires same cancellation authority and decreasing same-identity spans, spends the shared budget, invalidates the view, and deep-detaches the result while rejecting cycles, live-looking keys, and other references. The child receives no parent cursor/mark/capture/variable/transaction state. The consumer executes all 8 view, 6 authority, 6 cancellation, 8 chain, 4 execution, and 26 diagnostic rows, plus nested shared-authority, expired-view, rebased-diagnostic, cyclic-result, seed-mutation, and aggregate-detachment proofs. The dormant final-path consumer remains exactly 83 pass / one missing PROGRESSIVE_DISPATCH_SPAN failure and stays outside CI; no syntax, ActionIR, wrapper, generated-source, rollout, or outward behavior is enabled."
reverify:
  - "perl -Iperl -c perl/LinkedSpec/ProgressiveSpanDispatch.pm"
  - "PERL5LIB= prove -q -Iperl t/progressive_span_dispatch_perl_authority.t"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "! prove -q -Iperl t/progressive_span_dispatch_perl_contract.t"
  - "! rg -q 'progressive_span_dispatch_perl_contract[.]t' tools/run_ci_local.sh"
---

# Perl progressive span-dispatch authority

The private core is `LinkedSpec::ProgressiveSpanDispatch`. It deliberately has
no dependency on `.spec` syntax, ActionIR, execution wrappers, generated source,
or rollout metadata. A host constructs its immutable registry from already
compiled callbacks and starts a fresh invocation with caller-owned source,
cancellation, deadline, budget, depth, and total-call authority.

Authored execution can only select a normalized logical identity and allowed top
rule. It cannot register another entry or resolve a path. Effective capabilities
and policy modes are intersections; source-detail and numeric ceilings take the
stricter minimum. The child receives a bounded view of the caller-authorized
decoded source rather than a second copied-source identity.

The view is valid only during its child callback. It exposes bounded text and
local-to-global position, span, and diagnostic rebasing in Unicode-scalar
coordinates. Nested dispatch reuses the invocation authority. A repeated
parser/top-rule/source tuple must use a strictly smaller contained span, while
depth and total calls remain independently bounded.

The child callback receives no parent parser registers. Its return value is
deep-copied into plain detached data; false values remain valid, undefined means
child failure, cycles and reference-bearing values fail, and keys that claim a
live parser/registry/source/cancellation/transaction/host/path authority fail.
Transient source views are invalidated even when the callback fails.

Carrier leaf `.14.6.2.2` next attaches this private authority through the
existing invocation-options seam and adds the dedicated ActionIR node. Admission
leaf `.14.6.2.3` alone may route the final-path consumer and promote the Perl
rollout row.

## Links

- Neutral model: [[progressive-span-dispatch-audit-plan]].
- Dormant final-path RED: [[perl-progressive-span-dispatch-dormant-red]].
- Typed positions/spans: [[perl-typed-source-location-values]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.2.1`.
