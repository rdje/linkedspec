---
id: julia-progressive-span-dispatch-authority
title: Julia progressive span dispatch has a private immutable authority core
answers:
  - "where is the Julia progressive span dispatch authority"
  - "how does Julia progressive dispatch register child parsers"
  - "can Julia progressive dispatch load a parser path"
  - "how does Julia progressive dispatch rebase source locations"
  - "how does Julia progressive dispatch share cancellation and budgets"
  - "how does Julia progressive dispatch prevent cycles"
  - "how are Julia progressive child results detached"
  - "can a Julia child retain nested dispatch authority"
  - "does the Julia progressive authority have ActionIR carriers"
  - "does the Julia progressive authority test run in CI"
date: 2026-08-24
status: private authority/core current; carriers and Julia admission pending
tags: [julia, progressive-parsing, registry, source-location, cancellation, diagnostics, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.5.1 adds julia/src/runtime/BoundedChildParseAuthority.jl, includes it immediately after SourceLocation, and does not export it or connect it to ActionIR, Interpreter, generated plans/source, ordinary tests, canonical CI, or rollout. ProgressiveRegistry owns validated logical ids, sha256 fingerprints, allowed top rules, capability/policy/resource ceilings, and already-compiled synchronous callbacks; register! and load produce typed denials, and entries contain no path/provider/source/compiler fields. Each fresh ProgressiveInvocation constructs the existing SourceAuthority over copied decoded snapshots and owns one source id, identity-bearing cancellation token, caller clock/absolute deadline, shared steps, active global-span chain, maximum depth, and total-call limit. Dispatch intersects capabilities/policies, takes ceiling minima, validates the exact four-field same-source span, charges before child work, checks cancellation/deadline before and after, and permits repeated identity/top/source only for contained strictly smaller spans. ProgressiveSourceView materializes the typed direct span, maps local Unicode-scalar boundaries to original global offsets, rebases typed positions/spans/diagnostics through the original authority, and expires after callback return or failure. ProgressiveDispatchRequest.dispatch_nested checks that same view first, so a retained request cannot preserve live authority. Results are deeply copied and node-bounded; null/throwing children, cycles, live-looking fields, unsupported/nonfinite values, and over-ceiling structures fail closed. The dormant consumer passes 210 assertions covering all 8 view, 6 authority, 6 cancellation, 8 chain, 4 execution rows and all 26 diagnostic contexts plus nesting, rebasing, expiry, immutable inputs, callback containment, UTF-8 diagnostic bounds, and detachment adversaries. The separate final-path consumer remains exactly 55-pass/one-RED, leaving carriers exclusively to .14.6.5.2."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using Test; include(\"julia/test_dormant/progressive_span_dispatch_authority_test.jl\")'"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using Test; include(\"julia/test_dormant/progressive_span_dispatch_contract_test.jl\")' 2>&1 | rg '55 +1 +56'"
  - "! rg -q 'progressive_span_dispatch_authority_test[.]jl' julia/test/runtests.jl tools/run_ci_local.sh"
---

# Private Julia progressive authority

This core is executable trusted-host authority, not authored Julia progressive behavior. A host supplies only
already-compiled callbacks and decoded source snapshots. Authored execution will eventually select a logical
parser identity, one allowed top rule, and an exact direct span; it never receives registry mutation, path
resolution, loading, compilation, source-authority, or parent-register access.

Julia objects are retainable, so the callback receives a scoped request rather than the mutable invocation. Its
nested-dispatch function first checks the same view validity bit used by text and rebasing operations. The view is
invalidated in a `finally` block after every callback outcome, closing both retained-view and retained-request
authority seams.

The existing typed `SourceLocation.SourceAuthority` remains the sole source identity/provenance authority.
Child offsets are view-local Unicode-scalar boundaries; typed positions, spans, and diagnostic offsets rebase to
the original source identity and global scalar coordinates. Parent cursor, boundary, marks, variables,
transactions, and captures never enter the invocation.

The focused dormant consumer proves the core independently. The final-path consumer deliberately remains RED,
because `.14.6.5.2` alone owns the dedicated node, opaque execution seed, and native/reconstructed/generated-plan/
independently included emitted-module carriers.

Related facts: [[progressive-span-dispatch-audit-plan]],
[[julia-progressive-span-dispatch-dormant-red]], [[typed-source-location-cursor-algebra-direction]], and
[[julia-recognition-transaction-private-authority]].
