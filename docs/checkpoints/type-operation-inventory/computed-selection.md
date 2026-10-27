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
remains23.4 after feature coverage. The approved copy-domain rollout4.2.2 is complete in bounded backend children; complete admission remains23.4.

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

The director-approved scalar/null copy rollout4.2.2 is now complete in bounded
Perl/Rust/Dart/Julia/safe Lua children. Direct-call selection24.1.2 resumes with
its complete ordinary target and legacy constraints intact.

## Bounded ordinary data-helper call implementation

24.1.2.1 adds direct data-helper computed receivers through the known helper-name
resolver and semantic value-method/Numeric families, plus data constructors and
logical helpers. Unknown/bound and registered custom names stay on their existing
path; list splices and context/control/rule names are excluded. The deferred-body
fence remains first. Typed helper receivers reuse the existing value_access reader
and source/selector/result visitors, with no AST/format fields added. See
computed-helper-calls.md for the precise bounded source decision.

Native/fresh helper/scoped/ownership/AST/source-error/readiness checks pass43;
frozen callable controls pass5 top-level and noncall/deferred controls pass58.
A cold parser preserves its incoming error. Complete computed_selection_values
still fails native handler/fresh-load compilation at registered entries() indexing,
raw1/unresolved0/ready0;24.1.2.2 owns that required source class before Perl/Rust
handoff. No full-target oracle, callable value/marker or deferred boundary is weakened.

## Bounded registered-function implementation

24.1.2.2 resolves otherwise unknown call names only against the actual compilation
registry. EmitContext's existing scoped registry frame now also covers Parser's
declaration, lowering and raw-dependency parses, with restoration on every exit.
Function definitions retain their original staged AST/job/payload. A private
lowering view reparses the body at its original source span under that registry;
declarations, presence/mutation targets, emission and deferred-dispatch private-name
inventory consume this contextual view. Pure name lookup never parses bodies.

The prototype leaked selector writes from a previously raw function body and
promoted contextual deferred reads to value_access/raw0/ready1. Both are repaired:
function-local writes stay local and existing final-codeblock signatures/counts
fence new registered-name recognition in attached/parenthesized callback bodies.
Explicit literals retain their earlier fence. Ordinary argument/inline blocks
still compose; no deferred executor operation or AST/schema field is added.

Native/fresh full target, scoped snapshots/kinds/rest, static-name precedence,
registry/error restoration, private-name collision and source-span/unchanged-staged
controls pass. Existing signature/recursion diagnostics and four bound-callable
values1/2/0/0/raw1 remain. This completes the bounded Perl implementation children;
full source/context/portable admission and required Perl registration remain23.4.
Rust24.2 must be assessed independently before claiming its computed-source support.

## Bounded Rust implementation

24.2 extends the existing postfix reader to Array/Hash/eager-block literals and
completed fluent segments, resuming fluent parsing after a selected result. Call
and grouped postfix forms already existed; named reads retain their lookup order.
The existing ValueAccess evaluator snapshots the receiver before selectors and
still evaluates later selectors on a missing path. No AST/serialized fields change.

Ordinary computed-result continuations reuse the copied-result actual-kind guard,
including the with/traversal path. Static registered-function and semantic data-
helper ownership distinguishes direct unknown bound calls; their old read/result
policies remain. The first candidate changed bound missing-entry counts0 to null.
Exact pre-feature engine replay and candidate RED retain that distinction; no
runtime-value classification or oracle weakening is used to repair it.

Native/restored-CompiledSpec/generated-plan tests cover the unchanged full target,
strict kinds, signed positions, snapshots/SIC/IJ effects, repeated bridges, function
scopes, with guards, old bound-call results and Unicode regex-split/index/String
composition. Direct selected/copy/signed-reader controls pass; the independently
compiled emitted-crate test is excluded from this ordinary feature check. Complete
source/context/portable/generated-source admission remains23.4. Dart24.3 is next.

## Bounded Dart implementation

24.3 replaces the call-only postfix recognizer with the existing delimiter scanner
and access-segment owner for supported Call/fluent/Array/Hash/immediate-block
prefixes. Fluent parsing retains the maximal contiguous suffix in one chain and
recursively parses its computed receiver. Existing arity preflight, named/grouped
owners, ordinary raw receivers and source/span modes remain. An introduced empty-
suffix recursion is reproduced as Stack Overflow and repaired by rejecting that
suffix before recursively parsing a receiver.

The existing nested reader retains source snapshots and ordered selectors. Its
continuations reuse copied-result actual-kind guards through scoped with and
later bridges. Static canonical receiver-helper sets and registered function
ownership leave direct unknown bound-call policies unchanged; no return-value
classification, serialized field or evaluator operation is added.

Native/restored-SpecFile/generated-plan full target and finite kind/effect/scope/
regex/Unicode/with/bound-call/parser controls pass. Existing data-call wrong-kind
results [null,[1],KV] become [null,null,empty] before rejected operands. Direct
selected/copy/parser/signed-reader checks, format and fatal analysis pass. Julia24.4
follows; full source/context/portable/standalone emitted admission remains23.4.
