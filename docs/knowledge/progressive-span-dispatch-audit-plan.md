---
id: progressive-span-dispatch-audit-plan
title: Progressive span dispatch requires a pre-registered parser and a rebased source view
answers:
  - "what is progressive span dispatch"
  - "is progressive parser composition implemented"
  - "what is the difference between progressive dispatch and staged parse jobs"
  - "can progressive dispatch load a spec path"
  - "how does a child parser preserve parent source coordinates"
  - "what parser registry authority may an active parse use"
  - "how do capability and policy ceilings compose across progressive dispatch"
  - "how is cancellation inherited by a progressively invoked parser"
  - "how are progressive dispatch cycles and progress checked"
  - "can progressive dispatch run inside recognition transactions"
  - "what leaves implement FUTURE-PARITY-BACKLOG.14.6"
  - "what is the accepted dispatch_span syntax"
  - "is the neutral progressive span dispatch contract executable"
  - "how does typed transaction safety compose with progressive dispatch"
date: 2026-08-17
status: executable neutral authority and private Perl/Rust admissions current; other backends and typed progressive admission pending
tags: [progressive-parsing, source-location, span, registry, authority, cancellation, diagnostics, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.0 retrieves ADRs 0012-0016 and 0056, the typed/staged/loader authorities, and the five backend registries before probing. LinkedSpec::call_spec_handler_subst lowers both parse_job(...) and dispatch_span(...) to LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER. The Perl registry executes only actionir-body.spec/action_block through builtin:actionir-body.spec and rejects specs/json.spec at resolve; Rust, Dart, Julia, and Lua have the same narrow identity. Their job spans are legacy start/end/line shells rather than typed source-authority spans, and none carries cancellation or a policy ceiling. Native spec loaders resolve/read/compile filesystem inputs before execution and therefore are not safe in-parse registry authority. The typed checker is 10 complete / 4 pending / 126 while the independently closed recognition transaction contract is 9/9; git history proves owner .14.3 never promoted typed transaction_safety, so corrective prerequisite .14.6.0.1 owns that missed composition and stale-current governance before progressive behavior."
evidence_update_2026_08_17_neutral: "Corrective .14.6.0.1 landed at 27f9c87f with typed transaction safety current at 11/3/152. FUTURE-PARITY-BACKLOG.14.6.1 selects value = dispatch_span(\"expr-v1\", \"Expr\", span) and adds linkedspec-progressive-span-dispatch-v1 plus its independent checker: 2 immutable registry entries, 2 sources/8 views, 6 authority, 6 cancellation, 8 chain, 4 execution cases, 5 backend guard groups/17 paths plus 10 outward guards, 26 diagnostics, rollout 1/9, and 86 mutations. Canonical registration is current while every backend and the typed progressive row remain pending; the recognition effect has no current node/call rows, guarded backend paths omit both future tokens, ten facade/schema/semantic/MCP/CLI/README paths deny premature exposure, and the Perl lowering probe retains the unsupported-helper sentinel."
evidence_update_2026_08_17_perl_carriers: "Perl .14.6.2.1 adds the immutable private core; .14.6.2.2 adds one exclusive PROGRESSIVE_DISPATCH_SPAN assignment and live/reconstructed/generated-plan/independently-loaded emitted carriers through fresh invocation options. The 125-assertion consumer is green but remains outside CI; neutral/typed/outward rollout and Perl admission stay pending for .14.6.2.3."
evidence_update_2026_08_17_perl_admission: "FUTURE-PARITY-BACKLOG.14.6.2.3 requires, syntax-checks, and executes the unchanged 125-assertion consumer exactly once in canonical CI; promotes only Perl to make rollout neutral + Perl 2/9; removes the obsolete Perl absence group while retaining four pending-backend groups/14 paths and ten outward guards; and recomposes recognition to 134 current + 4 dedicated node rows with PROGRESSIVE_DISPATCH_SPAN as the sole parser_registry_or_staged_dispatch node and no call row. Typed progressive, Rust/Dart/Julia/Lua, recurring, public no-drift, generated format, shared helper inventory, and outward surfaces remain pending or unchanged."
evidence_update_2026_08_17_rust_red: "FUTURE-PARITY-BACKLOG.14.6.3.0 adds one outer-cfg Rust consumer that derives the exact neutral inventories and proves the existing staged registry rejects expr-v1 at resolve. The exact authored assignment stays a generic Expr::Call through serialized, native, reconstructed, generated-plan, and independently compiled emitted-source routes; every execution returns null through generic unknown-helper fallback, and neither serialized carrier contains progressive_dispatch_span or PROGRESSIVE_DISPATCH_SPAN. The opt-in test passes every earlier assertion and fails only at the dedicated-node boundary; ordinary discovery runs zero tests and canonical CI omits it. Rust authority/core, carriers, and admission are exclusively assigned to .14.6.3.1-.3."
evidence_update_2026_08_17_rust_authority: "FUTURE-PARITY-BACKLOG.14.6.3.1 adds a doc-hidden Rust authority independent of ActionIR and Engine: immutable host-seeded already-compiled callbacks, SourceAuthority-backed bounded views/global scalar rebasing, narrowing grants/ceilings, Arc-identity cancellation plus deadline/shared steps, decreasing-span/depth/call bounds, callback containment, expiry, deep detached results, and all 26 diagnostics. Its separate outer-cfg focused consumer executes the complete neutral matrix plus nesting/rebase/expiry/mutation/detachment adversaries; ordinary and canonical discovery remain inert. The original four-carrier final-path RED stays exact because .3.2 alone owns the dedicated node and carriers; rollout stays 2/9 until .3.3."
evidence_update_2026_08_17_rust_carriers: "FUTURE-PARITY-BACKLOG.14.6.3.2 adds one exclusive logical-only Rust node, exact static operand and residual-generic denials, recognition graph effect rejection plus live-token defense, an opaque per-execution host seed, and native/reconstructed/generated-plan/independently compiled emitted-source delegation. The exact historical consumer is GREEN but retains its cfg and ordinary/canonical absence. Governance becomes 9 Rust carrier paths + 3 pending-backend groups/11 paths + 10 outward guards, 26 diagnostics, rollout 2/9, and 91 mutations; .3.3 alone owns Rust admission."
evidence_update_2026_08_17_rust_admission: "FUTURE-PARITY-BACKLOG.14.6.3.3 preserves the historical consumer identity/cfg, exact fixture, and four carrier behaviors while requiring it as a tracked canonical input and executing its cfg-enabled target exactly once. Only Rust rollout advances: governance is 3/9 complete, 3 pending-backend groups/11 paths, 9 governed Rust carrier paths, 10 outward guards, 26 diagnostics, and 95 mutations. Ordinary Rust discovery still executes zero tests; Dart/Julia/Lua, typed recurrence, generated format, public inventory, facades, schemas, MCP, CLI, README, and outward surfaces remain pending or unchanged."
evidence_update_2026_08_17_dart_red: "FUTURE-PARITY-BACKLOG.14.6.4.0 freezes dart/test_dormant/progressive_span_dispatch_contract_test.dart. The exact consumer derives neutral 3/9/95 truth, rejects expr-v1 through the separate staged function-body registry, and proves native, SpecFile-JSON reconstructed, generated-plan, and independently analyzed/executed emitted-source routes preserve one generic ActionCallExpr and the same structured unknown_helper dispatch_span failure. Four groups pass and only the missing progressive_dispatch_span / PROGRESSIVE_DISPATCH_SPAN assertion fails. Ordinary/canonical discovery, production, rollout, generated format, typed recurrence, and outward surfaces do not move; .4.1-.3 exclusively own Dart authority, carriers, and admission."
reverify:
  - "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{return(parse_job(\"child.spec\", \"payload\"));})'"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "rg -n 'ACTION.?IR.?BODY.?SPEC|unsupported parser spec id|source_span|capability_set' perl/LinkedSpec/StagedParserRegistry.pm rust/linkedspec-runtime/src/staged_parser_registry.rs dart/lib/src/parser/staged_parser_registry.dart julia/src/parser/StagedParserRegistry.jl lua/src/linkedspec/staged_parser_registry.lua"
---

# Progressive span-dispatch audit and implementation plan

## Current code proves a narrower staged prototype

Progressive dispatch is synchronous child-parser invocation while a parent parser is active. Staged dispatch is
post-AST work: collect parse jobs, order them, run later parsers, and stitch results. They share provenance and
registry principles but not execution state or scheduling.

Private Perl and Rust progressive behavior is current, while Dart, Julia, and Lua remain pending. Both admitted
backends recognize
`dispatch_span(...)` as one dedicated intrinsic, while `parse_job(...)` and every other progressive path remain
unsupported. The five backend staged registries still implement only one function-body
adapter only: `actionir-body.spec` resolves to `builtin:actionir-body.spec`, compiles top rule `action_block`, and
parses ActionIR body text. Passing an ordinary `.spec` path fails at resolve. The existing `source_span` is an
offset/line shell copied beside text; it is not the typed same-source span plus source authority required by ADR
`0056`. Existing capability lists affect only the adapter cache key, and the registries carry no caller policy
ceiling or cancellation authority.

Native `load_and_compile_spec` APIs are useful pre-parse authorities, but they resolve and read paths. Progressive
execution must never call them from authored recognition. A host or already-authorized outer pipeline loads and
compiles first, then registers an opaque logical identity. Authored code may look up that identity only; a span is
data and provenance, never loader authority.

Rust's exact historical final-path RED is now GREEN under the same explicit outer cfg. The consumer derives the
neutral contract, rejects `expr-v1` through the unrelated staged registry, then proves native, reconstructed,
generated-plan, and independently compiled emitted-source routes against one dedicated logical-only node. Without
the cfg, Cargo discovers zero tests; the target is not routed by canonical CI. This is implemented but dormant
private behavior, not admitted Rust rollout.

The separate Rust `.14.6.3.1` authority is now executable behind its own outer cfg. It mirrors the immutable
registry, bounded view, narrowing authority, shared safe-point, decreasing-chain, detached-result, and typed
diagnostic model. `.14.6.3.2` now attaches the four carriers through a fresh opaque execution seed. Neither focused
target promotes Rust rollout; `.14.6.3.3` remains the admission owner.

## Frozen authority and source-view model

The selected private spelling is `value = dispatch_span("expr-v1", "Expr", span)`. The first two operands are
static normalized literals and the third is one bare local exact four-field span binding. The dedicated node is
`PROGRESSIVE_DISPATCH_SPAN`, its effect is `parser_registry_or_staged_dispatch`, and v1 propagation is fail-only.
Derived multi-span text and AST stitching remain staged `.14.7` work. The returned child payload is detached;
parent cursor, boundaries, marks, variables, transactions, and
capture state remain isolated and unchanged except for the explicit result binding performed by ordinary action
semantics.

Each registry entry is immutable during execution and contains a normalized logical identity, already compiled
parser authority, content/import fingerprint, allowed top rules, capabilities, and policy ceilings. It contains no
authored path-resolution permission. Effective capabilities are the intersection of caller and entry grants;
effective resource/source-detail policies are the stricter minima. A child cannot elevate either ceiling.

A direct parent span becomes a bounded source view over the same caller-authorized source. Child matching uses
view-local registers, while typed positions/spans and diagnostics add the view base and retain the original source
identity. Thus the child's input start/end positions are the parent span boundaries in global Unicode-scalar
coordinates, and no copied string becomes a second provenance authority. Diagnostics never expose source text
above the effective source-detail ceiling.

## Frozen execution-safety model

The parent invocation supplies one cancellation/deadline/budget authority. The child receives only the remaining,
stricter budget and cannot replace, reset, extend, or ignore it. Checks occur at dispatch entry and child execution
safe points. Existing per-engine iteration limits become one subordinate ceiling rather than a substitute for
shared cancellation.

The synchronous active chain records normalized parser identity, top rule, source identity, and global span.
Repeating an identity/top/source requires a strictly smaller nested span; an exact repeat or non-decreasing cycle
is rejected. Dispatch depth and total-call budgets remain bounded even across distinct identities. The parent
cursor does not advance merely because a child parse ran, so dispatch itself cannot satisfy the parent's
recognition progress obligation.

Progressive dispatch is classified as `parser_registry_or_staged_dispatch`. It is forbidden inside an uncommitted
`recognize_once` effect graph because lookup/execution/diagnostics cannot be rolled back. Parser lookup, source,
top-rule, capability, policy, cancellation, cycle/progress, and child failure diagnostics are typed and
source-text-safe.

## Dependency order

`.14.6.0.1` repaired the missed typed transaction-safety composition and stale-current guard. `.14.6.1` owns the
executable neutral contract/checker; Perl `.2` and Rust `.3` are now admitted at rollout 3/9. `.4-.6` admit Dart, Julia, and
one shared Lua implementation independently on PUC Lua and LuaJIT; each backend parent must split RED, authority/core,
carrier integration, and admission before behavior. `.7` binds five source groups to six runtime routes and alone
promotes typed `progressive_span_dispatch`. `.8` closes public projection/no-drift without exporting a facade or
consuming combined final row `.14.8`.

Accepted architecture: ADR `0080`. Related: [[staged-linked-parsing-architecture]], [[staged-parser-registry-dispatch-contract]],
[[typed-source-location-cursor-algebra-direction]], and [[recognition-transaction-public-closeout]].
