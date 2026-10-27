# Inline conditional result selection

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.6; family23.3.26.
Status: frozen ordinary target; prerequisite26.0 and all five bounded backend children implemented/targeted-checked; full admission23.4 separate.

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


## Bounded Perl selection

26.1 passes the parsed Call to the existing static computed-source classifier.
Only canonical inline if/switch spellings, value-call arity and no attached block
join the existing read path. Single-operand control_if/control_switch headers,
marker aliases and unrelated control names stay excluded. The shared fixture and
finite function-local/missing/Unicode/error/deferred/native/fresh/metadata controls
pass43 after12/43 RED. No new read builder/getter/schema/executor operation.


## Bounded Rust selection

Rust26.2 already parses/read-selects conditional calls and preserves lazy payloads.
Its existing static result guard now recognizes only if/switch Calls with payload
operands. One-operand headers retain their old count policy. Four new cases and
six direct computed cases pass native/restored CompiledSpec/generated plan;
with/kind/missing guards are repaired without parser/read/serde/equality changes.


## Bounded Dart selection

Dart26.3 enables the existing computed-result guard only for canonical if/switch
Call/sourceMethod names with payload arity and no attached block. Its existing
parser and lazy/read owners remain; i/when normalization does not broaden this
source role. Four execution cases pass native/restoredSpec/plan with unchanged legacy counts;
a native parser group checks header/alias/attached fields, and seven direct
computed cases also pass. Format/fatal analyze pass; no parser/reader/codec movement.


## Bounded Julia selection

Julia26.4 independently repairs the same static role boundary using existing
name/source_method/arity/trailing_block_arg fields. Four execution cases pass
native/plan/fresh modules and six native parser assertions retain role metadata;
strict equality keeps Bool separate from Number. New18 and direct computed25 pass
with --depwarn=error and normal registration. No parser/read/compiled format change.


## Bounded safe Lua selection

Lua26.5 extends its existing private classifier table with canonical name/source_method,
payload arity and no trailing block. PUC5.5.1 and LuaJIT2.1.1788460057 pass four
execution groups on native/plan/fresh, six native parser-role assertions and two
source-error groups across those routes; six direct computed groups also pass.
A one-operand switch retains count0, a one-operand if retains typed arity failure,
and i retains unsupported-helper failure. These are existing Lua policies, not
normalized to other backends. luac/loadfile pass with no new chunk locals or
parser/read/format changes. Declared5.4/full admission remain separately owned.
