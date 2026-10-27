# Copy-domain authority intake

Owner: TYPE-REFERENCE-BOOK.1.2.1.4.2.1; decision/repair owner1.2.1.4.2.2.
Status: historical behavior intake; director approved scalar/null value-copy extension on October27, implementation owner4.2.2.

## Authority

README and ADR0006 retain Perl as the behavioral reference. ADR0007 unifies the
former Array/Hash copy helpers; it does not explicitly admit scalar/null copying.
The book helper catalog's array_copy/hash_copy signatures describe containers and
qualify current backend scalar/null differences. Existing Perl copy repair proof
preserves scalar fallback[] and outer-only container copying; other backends
recursively copy containers. None of these authorities establishes generic scalar
value copying or one uniform invalid-input outcome across every source family.
Do not silently change Perl reference semantics or infer a target from a backend
majority. The director's comprehensive fluent-method objective motivates a decision,
but is not an existing scalar-copy signature.

## Independent public reference observations

At clean73735f4fb, probe_copy_domains.pl runs public Get and independently loaded
emitted source, retaining runtime errors and compilation/load outcomes. Exact
observations are in copy-domain-reference-observations.json. Eight authored cases
agree across these two routes; no observed compile/runtime errors.

| Source | Current Perl copy result |
| --- | --- |
| Function copy of Bool/Number/String/null/missing | [] |
| Named/literal scalar/null receiver copy | [] |
| Selected Number/String/missing receiver copy | [] |
| Free logical Bool result followed by copy | null |
| Existing with prefix, not(), then copy | null |
| Array/Hash, including empty containers and false/null members | same container kind/value |
| Valid scalar/null block source | [] after source effects exactly once (SR) |
| Extra receiver operand | null before source/operand effects |

Substitution reveals distinct mechanisms, rather than a lost Boolean value:
MethodLowering's logical-result chain marks incompatible copy terminal and emits
the valid producer followed by undef; ordinary aggregate copy dispatch explicitly
falls back to[]. Source paths are MethodLowering.pm's _lower_method_value_expr,
logical/emitted result chain around5175 and aggregate copy around7223/7259.
The with path is established through complete Get/emitted execution; isolated
call_spec_handler_subst is not authority for its surrounding scope lowering.

Dart23.3/Julia23.4/safe Lua23.5 independent real-Bool controls establish existing
value-preserving scalar copying. Rust retains its current reference-like scalar
fallback and logical-result rejection. These are historical compatibility facts,
not permission to rewrite expectations before choosing the public domain.

## Concrete decision and bounded follow-on

Recommended extension: copy(value) and value.copy() preserve Bool, Number, String
and null; container copying retains existing depth/detachment boundaries. Advance
Perl reference first, then Rust; independently retain/repair Dart/Julia/safe Lua
routes and result guards. No implicit Number/Bool conversion, callable invocation,
new copy-depth promise, grammar or serialized model change.

Alternative: keep the container-only contract and align unsupported scalar/null
function/receiver behavior with the existing Perl source-family boundaries. This
narrows Dart/Julia/Lua behavior and needs explicit compatibility updates; do not
pretend the reference currently has one uniform scalar failure value.

At this intake the decision was requested and neither option had been adopted.
On October27 the director selected the recommended scalar/null value-preserving
extension, retaining existing container-copy depth rules. This is the authority
for4.2.2; the historical reference observations above remain unchanged.
TYPE1.2.1.4.2.2 owns the response and bounded implementation children; parent4.2
stays open until the selected behavior is fixed/verified, not documentation-only.
Other ordinary feature work may proceed from a clean commit while this decision
is pending; do not change copy domains in another family.

ADR0138 now adopts the approved implementation target; copy-value-preservation.md
owns its exact value/shape/effect/context boundaries. Perl ordinary producer,
receiver and existing interpreted-copy checks are separate owned children, then
independent backend rollout. Current fallback observations are not refreshed to
match the target; actual implementation/current public support follows per leaf.
