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
