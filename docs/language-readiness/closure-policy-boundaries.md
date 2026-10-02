# Scoped language closure policies

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3`. Reviewed 2026-10-02 from clean
`e4f9dcb8d6ee825119863d076d5a32be42ab9ef6`. This review completes the policy
stage of `linkedspec-language-closure-v1` without changing a runtime or admission.
The operation/scope freeze's original sixteen source files and 66 semantic digests
remain exact; 24 additional anchors bind inherited resource, loading and failure
rules. The definition now has 90 anchors over the same sixteen authorities.

The source-located plan is `docs/language-readiness/closure-contract-matrix.md`;
`capability_conformance/language_closure_contract.json` is the neutral authority.
Its independent validator checks structure and source drift. It executes no grammar
and does not establish general termination, performance, error recovery or security.

## Deterministic inputs and order

The claim fixes the canonical program and contract versions, decoded input and
source identity, explicit entry/options/typed values, initial authorized working
state, frozen registry and effective grants. Observed cancellation, deadline,
remaining budget and sink behavior are operational inputs. A run cancelled at a
different safe point need not have the same outcome as an uninterrupted run.
Caller deadline observation supplies no authored clock access.

Existing owners define authored rule/alternative order, once-only expression
evaluation, original-shape root-kind leaf traversal, and staged breadth-first
depth / typed AST path / provenance / job-id order. Field names use Unicode scalar
order and array indices use numeric order; this is not host hash iteration.
Matching remains within governed contracts and authorized substrates.
Dart lexical helper supplementary-character ordering retains its existing
DART-STARTUP-READING.2.13.1–.3 repair and reading/policy prerequisites; no new
callback-order result is inferred. sorted_values follows sorted keys, rather than
sorting values independently (see docs/knowledge/dart-helper-unicode-order-gap.md). No arbitrary
host-regex equivalence, hard wall-clock bound or timing-independent outcome follows.

## Progress is scoped

| Context | Existing policy / current evidence | Limit of the claim |
| --- | --- | --- |
| Typed-source target | Advance the cursor or prove a well-founded decreasing measure. | A design target does not prove every ordinary loop terminates. |
| Active recognition or observation | Accepted repetitions and recursive edges require strictly greater end offset. | Rolled-back candidates and state changes are not accepted cursor progress. |
| One-shot zero-width recognition | Legal success is distinct from repetition/cycle progress. | Empty matches do not license repeated accepted non-progress. |
| Ordinary recursion | The documented same-rule/same-position cutoff terminates the selected no-consume cycle. | This compatibility guard has its own result/trace behavior, rather than one universal typed progress diagnostic. |
| Ordinary iteration | Dated zero-width controls and selected current suites establish their covered termination behavior. | No configurable 100–1000 threshold is admitted across all repetition modes. |
| Child dispatch | Private dispatch leaves the parent cursor unchanged; staged work follows the completed parent AST. | Child work cannot supply parent repetition or recursion progress. |

The October 2 public `LinkedSpec::Get` scalar-reference probe for
`Top:: I { return(call(Top)) }` on `a` returns null, emits
`rule_handler_forward_progress:Top` and leaves `last_error` null. This reproduces
the dated ordinary-guard fact; it is not a new cross-backend diagnostic admission.
The probe's source, observed result and trace are retained in project-local proof.
Its Knowledge home is `docs/knowledge/top-rule-recursion-forward-progress-guard.md`.

## Inherited resources, current exceptions

Progressive/staged authority uses capability and policy intersections and stricter
numeric/source-detail minima. Shared cancellation, absolute deadline, work and call
authority cannot reset or expand. Repeated progressive parser/top/source spans must
be contained and strictly smaller; staged lineage has its own contained-extent
rule. Depth/calls and selected shared steps, result nodes and diagnostic bytes are
checked at each owner's dispatch entry and safe points.

These are inherited policies, with separately recorded partial enforcement.
Calculated effective metadata alone is not proof that actual callback cost,
detached node count or outward diagnostic bytes honor every limit.
`docs/knowledge/perl-progressive-resource-ceiling-enforcement-gap.md` retains the
September 6 controls: correct one-step/one-node/eight-byte metadata, but accepted
cost-two and three-node results and a 57-byte child error. Shared remaining-budget
rejection passed. These dated observations retain startup 37.1–37.3 ownership.
Authorized input visibility versus outward source detail remains 37.2-owned;
the accepted neutral wording is preserved until that review resolves it.

Staged destination/returned-marker/counter repairs remain startup 73–75-owned.
Dart 2.17/2.18, Julia 2.14 and Lua 2.26/2.8.15/2.8.16 retain their own adversarial
diagnostic/arithmetic/counter obligations and prerequisites. Other finite-ledger
repairs remain unchanged. No dependent guarantee advances before its relevant repair
and recurrence. There is no selected global depth, step, call or repetition number.
Safe-point checks do not establish regex preemption. Performance requires explicit
representative measurements and an envelope; unrestricted resources are unassessed.

## Failure and publication

| Operation / channel | Required distinction |
| --- | --- |
| Recognition miss, payload and misuse | A strict match boolean is independent of falsey payloads; commit after a miss returns null. Rollback restores cursor/boundary/marks only. Token/abort/kind exceptions remain owned. |
| Nested write | Structural failure uses the post-expression snapshot. Completed segment/RHS effects persist; evaluation errors propagate. |
| Leaf callback | Failed receiver publication preserves that receiver while completed unrelated effects persist. |
| Leaf continuation | Runs after commit; its later failure cannot undo the committed receiver. |
| Private progressive dispatch | Fail-only, without retry/fallback or parent progress. |
| Staged `fail` | Abort the composed parse without a settled composed result. |
| Staged `keep_text` | Materialize original exact text and record a scheduler-sidecar diagnostic. |
| Staged `diagnostic_node` | Apply the selected target policy with a detached portable diagnostic node. |
| Diagnostic sink / typed exit | Sink failure propagates unchanged and stops later work. Typed exit follows earlier delivered events and stops later actions. |
| Public error projection | Owner-specific `last_error`, typed exception or diagnostic-aware result; legacy adapters may return strings. Rust native text projection is Display-only. |

No universal transaction or universal error payload follows. Ordinary miss/cutoff,
recognition misuse, authored diagnostics, sink failure and transport/loader errors
must not be identified solely from null results or trace. Runtime appendix 9–11 now
uses these narrower distinctions; startup 41.2 retains the broader teaching review.

## Ambient policy and proof needs

ADR0064 excludes authored filesystem, process, network, environment, clock,
randomness, package-loading and FFI authority from the preferred portable closure
claim. Explicit caller input transfer, compilation, registry preparation, transports
and diagnostic routing remain host responsibilities. An identity, path-like parsed
string, span, marker or result supplies no implicit loading authority.
Raw host fallback, plugins and compatibility aliases remain excluded. That design
boundary and finite portable proof are not default ambient-isolation evidence or
an execution sandbox/confinement guarantee.

Before dependent runtime admission, independently exercise invalid selectors,
elevation and registry mutation; one-shot versus active non-progress; child versus
parent progress; joint effective limits against actual costs, node/byte counts,
cycles and counter extremes; and each failure/publication channel. Source-detail
oracles must distinguish authorized parser input from outward projection.
Fixed-input order needs independent value-kind/effect oracles. Definition mutations
are structural evidence; selected objectives and exact six-runtime recurrence
remain .1.3-owned after relevant repairs. New primitives require .1.4 evidence.
Independent definition reconciliation remains .1.2.4-owned.
