# Ordinary computed-value bracket selection

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.4; implementation family23.3.24.
Status: additive ordinary feature target, not portable implementation admission.

## Why this feature

ADR0007's typed expression/composition direction and the director's comprehensive
fluent-method journey require using a produced Array/Hash without an otherwise
unnecessary working binding. Existing first/last methods cover the endpoints;
brackets select an arbitrary entry or nested field. The existing non-Perl
value_access representation already carries an expression receiver and access
segments. Perl has a special callable-result bridge, not general typed value access.
Use those existing read semantics instead of adding a new public helper/type.

This is intentional additive syntax/composition work. A failing unsupported source
does not prove that every grouping or selector spelling is already admitted.
README/ADR0006 retain Perl-first reference evolution followed by independent
backend work. No new runtime capability or generated-format admission is claimed.

## Frozen bounded target

- A supported ordinary pure helper call, fluent result, Array/Hash literal,
  immediate value block or existing typed function result can feed bracket reads.
  Read results can feed another bracket or existing compatible fluent method.
- String split -> indexed entry -> String method is the motivating path:
  `" a , b , c ".split(",")[-2].trim().uppercase()` gives `"B"`.
  `split("a,b,c",",")[1].uppercase()` also gives `"B"`.
- Preserve Number/String/Bool/null/Array/Hash entry kinds. Dispatch continuations
  by the selected value, not the original source kind. Array/Hash results continue
  into their compatible helpers; actual scalar results keep existing consumer
  guards, and explicit defaults can produce containers again.
- Reuse valid zero-based and signed Array read positions: [-n] means length-n
  when in range. Missing keys, out-of-range positions and wrong receiver kinds
  return null/undef as existing pure reads, without creating or mutating storage.
- Quoted String selectors address Hash keys; numeric selector expressions address
  Array entries. Existing static key/index classification and backend-qualified
  coercions outside the admitted subset are not normalized here. This does not
  admit dynamic Hash-key expressions or new fractional/String/Bool/null selectors.
- Evaluate a computed receiver once, then selector expressions left-to-right once,
  then a compatible consumer's operands. Capture the computed receiver before
  later selector rebinding. All authored selector expressions still run on a
  missing path; expression failures propagate and stop later work normally.
  Preserve existing copying/aliasing bounds; no new deep-copy promise.
- Existing bare-binding readers retain their lookup order, signed policies and
  side effects. Do not route them through a different snapshot path accidentally.
- This is read-only rvalue composition. Assignment/mutation targets remain named
  bindings; computed writes and borrowed references are not admitted. Parentheses/
  grouping reconciliation remains SESSION87.4. Callable/deferred/context/mutation
  and scalar-copy domains remain separately owned; preserve callable provenance.
- Reuse existing value_access fields and access-segment forms in typed owners.
  Preserve authored sources/spans; lower from AST fields rather than reconstructing
  host code from a bracket substring. Any actual schema/format movement requires
  explicit ownership before implementation, not an incidental serialization edit.

## Public Perl intake and controls

probe_computed_selection.pl at d98e139d7 retains public Get/runtime context,
substitution and independently loaded emitted execution. Named tail selection and
typed selected continuations agree (B and [true,1,"0!","missing","B"]). Five
computed-source forms (pure call, fluent call, Array literal, Hash literal, block)
fail on both routes. Native error owner is runtime_handler:rule_handler_compile;
fresh compilation reports the corresponding raw bracket/DSL host syntax error.
Exact observations are in computed-selection-intake.json. These failures precede
new production; do not call a non-executing result a successful null read.

Perl AST parse order only recognizes binding-based access and fluent call segments;
computed bracket suffixes remain raw/invalid. MethodLowering has a special raw
callable-result path through CodeblockRuntime::read_path, not a general typed
receiver. Rust/Dart/Julia/Lua already define value_access but support different
postfix source shapes; assess independently before claiming a backend defect.

## Schedule and proof boundary

24.1 owns Perl typed postfix parsing/lowering/result continuations using existing
read machinery, preserving construction/provenance contracts. Split further if
that grows beyond a safe slice. Then24.2 Rust,24.3 Dart,24.4 Julia,24.5 safe Lua
independently assess source/literal/block/interleaving support and repair bounded
gaps. Strict native/generated routes and direct selected/signed controls suffice
per ordinary child; complete source-domain/context/portable/canonical admission
remains23.4 after feature coverage. Existing copy-domain decision4.2.2 stays pending.

## Bounded Perl noncall implementation and direct-call prerequisite

24.1.1 adds typed postfix selection from fluent/literal/immediate-block sources,
shared guarded rvalue emission and actual-result/visitor routing. Bounded noncall
native/fresh regression PASS36; parser PASS24 and direct selected/indexed PASS36.
Function-local source/selector writes, source snapshots, ordered missing-path
selectors, result guards, AST/spans and quote/regex boundaries pass. A representative
noncall descriptor remains ready with zero raw/unresolved/compatibility fallback.
The complete fixture stays unchanged in its required call/function source cases;
computed_selection_noncall_values is the explicit subset for this first child.

The initial broader candidate passes its new value fixture but changes existing
frozen callable result_path_float0 to2, result_path_string0 to null and raw1 to0.
General guarded Array reads bypass the prior CodeblockRuntime::read_path coercion
boundary; actual-kind guards also change count-on-missing. Recognition alone would
promote raw status. Excluding direct Call receivers restores all four frozen
values1/2/0/0 and raw1, with permanent native/fresh/descriptor compatibility tests.
computed-callable-compat-intake.json retains actual RED/restored observations and
the original producer/frozen input selection. Parent24.1 stays open;24.1.2 must
distinguish statically owned pure/functions from legacy callable paths without
changing their values, lookup, reader or metadata. Full Perl fixture/Rust handoff
requires that second child; no reduced full-target or callback admission claim.

Three parser assertions also remained stale after scalar String19.1. Exact base
producers reproduce their old trim-layout/substr-sentinel failures; ea6f82c2a and
the current String contract justify executed semantic oracles. Retained public
probe_parser_expectation_baseline.pl/JSON reconstructs the three original modules.
The first -I-only overlay was rejected when bootstrap selected working modules;
explicit require/standard %INC aliases establish the historical baseline.

## Explicit deferred-body repair and next activity

24.1.2.0 finds global recognition also changes explicit deferred literal AST,
readiness and error kind, although its executor does not support value_access.
The pre-feature/current packet and exact source are computed-deferred-boundary.json.
Only the three recorded baseline producers are preloaded; no full-checkout claim.
The original launcher's false require return is disclosed; corrected explicit
replay exits0. A scoped body-parse fence restores original deferred grammar,
raw1/ready0 and unsupported_codeblock_actionir/raw_perl. Regression PASS22 and
direct callable compatibility PASS5 preserve ordinary/inline/named controls and
success/error scope restoration. No new deferred execution or waiver is added.

The director now approves scalar/null value-copy extension4.2.2, retaining current
container-copy depths. It follows this repair's clean commit; direct-call24.1.2
remains queued with its complete ordinary target and legacy constraints intact.
