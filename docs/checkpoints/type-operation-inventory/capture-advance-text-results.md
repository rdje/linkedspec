# Anonymous advancing capture String result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.12; implementation family23.3.51.
Status: bounded Perl/Rust/Dart outcomes targeted-checked; Julia/safe Lua pending.

## Accepted sources and actual distinction

The source-boundary reference/typed source-location contract already own these
zero-argument String-or-null helpers and their effects:

| Source | Returned text | Successful new anonymous origin |
| --- | --- | --- |
| capture_take() | Old origin to current local-match start | Live cursor |
| capture_take_until_cursor() | Old origin through live cursor | Live cursor |
| capture_take_rest() | Old origin through end of input | End of input |

The parser's live cursor does not move. Missing/reversed source spans retain the
existing null/no-origin-advance policy; defined empty text stays defined. Preserve
each native helper/operation tag and source/rule identity. capture_take(name) is
the separate existing named-mark overload, not a new zero-argument alias.

At clean18e60a618, nine public Perl cases give six healthy primitive/bound
controls and three failed direct coalesce/cat chains. Primitive values are
":"/":cat"/":catTAIL" on αβ:catTAIL, with origin6/6/10 and live cursor6. Bound
methods work. Direct methods fail undefined host coalesce, despite raw0/fallback0/
unresolved0/ready1. Substitution inserts the native advancing do-block too late,
leaving authored method syntax. Early method-value source support currently
covers readonly captures, not these effectful sources.

The independent bound target returns
[[":!","CAT","CATTAIL",[6,6,10],null,"!","missing!",6,"A"]] native/fresh. The
exact direct-source twin fails compilation. Shared prospective fixture:
tests/fixtures/capture_advance_text_values.spec/.json. It is normative future
implementation input, not reported as already executing before51.1.

## Bounded behavior and preservation

- Existing three sources feed compatible ordinary default/String/Array/signed
  selected-String/Number methods, with their existing zero-argument signatures.
- Evaluate the source once and retain its returned String before consumers. The
  original advancing effect occurs once under the original validity guard;
  scalar snapshots and later source reads see the correct ordered state.
- Defined empty text skips lazy fallback effects. A failed match-start read uses
  the existing missing fallback without advancing. Preserve40/47/49 endpoint
  authority and the distinction between anonymous origin and live cursor.
- A normalized incompatible consumer rejects before its operands, retaining
  valid source/prefix effects. The shared invalid take-count BAD stays skipped
  after a successful advancing source; the later empty/missing controls expose
  the updated origin. Preserve backend direct first-consumer root policy.
- Keep existing invalid-shape/preflight/error-phase behavior, named overloads,
  static-helper/unknown-call precedence, function-state bans and callback/deferred
  vocabulary. No new advancing helper, alias, bracket source, name domain,
  mutation/copy depth, coordinate/AST/schema or generated-format policy.

Independent51.1 Perl/51.2 Rust/51.3 Dart/51.4 Julia/51.5 safe installed Lua
establish their own actual baseline before production. Preserve healthy results
and do not invent RED for compatible peers. Number-returning anonymous advancing
counterparts remain a separate useful next feature family. Full source/domain/
context/portable23.4, pressure20.1, Perl registration and declared Lua5.4 remain
separate; focused compile/quick checks/docs/commit per leaf continue.

Exact source/producer/native/fresh/substitution/metadata/diagnostics and bound/
direct target twins are retained in capture-advance-text-selection-intake.json.gz.
No production moves in this selection leaf.

## Bounded Perl51.1

Three original zero-argument native bodies now share one advancing-text factory
with narrow early value lowering after the existing function fence. All three
and the named capture_take(begin) printed bodies remain byte-identical. Initial
normal13 has7 RED/6 healthy; one additional Number bridge is separately RED, then
final14 pass with unchanged oracles/fixture. Native/fresh effects, distinct origin
and live cursor, empty/missing/once/snapshot/normalized-skip/String0/named/function
controls hold; readonly12/selected reset2 and module syntax pass. An old emitted
module still fails after the compiler repair: regenerate affected modules. Exact
inputs/actual producer/source epochs/results are retained in
capture-advance-text-perl-intake.json.gz. No new vocabulary/effect/preflight/
format policy or full23.4 claim. Normal registration23.4.1 and independent
Rust51.2 remain separate.

## Bounded Rust51.2

Rust already supports the unchanged target. New6/readonly6/reset3 pass native/
restored CompiledSpec/generated-plan routes, runtime unchanged/owned formatting
clean. Sources keep origin6/6/10 and live6, once/snapshots, normalized guards,
empty/missing/String0 and Number9. Named overload updates only its mark; literal
callback advances caller origin3 while live0 stays, and function/registered
callback source-specific errors hold. Existing input bytes remain exact. Actual
source/producer/outputs are retained in capture-advance-text-rust-intake.json.gz;
opaque dependency warnings remain upstream-owned. No independently compiled
emitted/full-context/portable admission. Dart51.3 independently follows.

## Bounded Dart51.3

Dart already supports the unchanged target. New6/readonly6/reset3 pass native/
restored SpecFile/generated-plan, fatal analysis/format, with runtime unchanged.
Effects/once/snapshots, separate origin and cursor, empty/missing/String0/Number9,
normalized guards and named overload hold. Literal callback updates caller
origin3/live0; pure-function/registered callback typed errors stay specific.
Actual JSON reporter accounts for every nonhidden/no-skip test and completion.
Exact source/producer/output/input bindings are in
capture-advance-text-dart-intake.json.gz. No isolated emitted/full-context/
portable admission. Julia51.4 independently follows.
