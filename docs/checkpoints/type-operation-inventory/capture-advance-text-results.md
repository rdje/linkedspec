# Anonymous advancing capture String result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.12; implementation family23.3.51.
Status: bounded target frozen; independent implementations pending.

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
