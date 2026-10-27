# Inline conditional result selection

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.6; family23.3.26.
Status: frozen ordinary target; prerequisite26.0 repaired, Perl26.1 bracket expansion next.

ADR0007 and the current inline-control contract make if/switch value expressions:
they evaluate the selected payload lazily and yield its actual kind. Existing
direct method chains already work on Perl. This target adds direct bracket reads
to their produced Array/Hash values, reusing the typed reader and result guards.
It adds no helper name, type, callback operation or serialized field.

## Bounded behavior

- Admit existing ordinary inline value if/switch calls as computed read sources,
  using their actual value-call role/signature. Preserve structural marker and
  attached forms, aliases, loops, parser/cursor controls and malformed diagnostics.
- An Array result accepts existing whole signed positions; quoted keys address a
  Hash result. Missing, out-of-range, unmatched/no-fallback and wrong-kind reads
  yield null without creating storage. Existing coercions/dynamic-key rules stay.
- Preserve Bool/Number/String/null/Array/Hash payload and selected-entry kinds.
  Compatible methods and repeated bracket/default/container transitions consume
  actual selected kinds; incompatible consumers reject before their operands.
- Preserve once-only condition/subject evaluation, ordered lazy elseif/case
  selection and only the reached payload. Capture that result before selector
  effects; visit selectors left-to-right, including later selectors on a missing
  path. Ordinary error propagation and already-completed effects remain.
- Eager block local returns, function-local bindings and caller restoration keep
  their owners. Explicit/registered contextual callbacks keep their existing
  vocabulary. Do not promote bound callables, all control names or runtime values
  into static helper ownership; named readers and unrelated legacy policies stay.
- Keep named-binding, write/mutation, list-splice, copy depth, source spans and
  generated format contracts. Independent backend children use focused checks;
  full source/domain/context/portable/generated admission stays23.4.

The authored conditional_selection_values.spec/json is the shared future target:
selected kinds, signed/nested reads, lazy condition/payload/selector/consumer order,
source snapshots, rejected operands, missing-path ordering and repeated bridges.

## Public intake at fcfb7dcdc

conditional-result-composition-intake.json retains six native/fresh observations.
Simple producers, equivalent named reads, direct container methods and direct
scalar methods agree with expected values, raw0/unresolved0/ready1. Direct
if/switch brackets fail compilation near }[, raw2/unresolved0/unready. Public
AST controls show existing producers are call nodes and their direct suffixes
remain raw; the ordinary computed-source classifier excludes these control names.
This is additive read-source composition, not a claim that method chaining is absent.

The separate eager-condition producer unexpectedly fails host compilation with
raw0/unresolved0/ready1. Public substitution shows _lower_inline_if_value_expr
feeding authored block DSL through lower_flow_composite_expr into truthy, while
branch blocks are lowered. Retained condition controls distinguish the mechanism:
the same condition evaluated into a binding succeeds (CT), branch-only blocks
succeed (T), and a switch subject block succeeds (ST). An elseif block condition
has the same compile failure/false-ready metadata as the initial condition.
Prerequisite26.0 owns this P1 producer repair before bracket expansion. Reuse the
existing value/block lowering while preserving typed truthiness and lazy order;
do not weaken readiness or change global statement/deferred control policy.


## Producer prerequisite repaired

26.0 routes initial/elseif conditions through the current value owner before typed
truth testing, fixing eager blocks and Bool literal predicates. Its inline child
operand wrapper clears only the inherited same-expression AST compatibility fence
on a dependency copy. This preserves typed block-local returns/terminal assignment
while leaving parent/sibling flags unchanged. Working native/fresh values now agree
with existing ready metadata. Predicate and two-site-candidate early-return packets
retain the distinct failures/counterfactuals; the candidate patch binds its epoch.
No conditional bracket syntax is admitted by this producer repair.
