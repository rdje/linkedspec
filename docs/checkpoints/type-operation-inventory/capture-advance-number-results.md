# Anonymous advancing capture Number result composition

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.13; implementation family23.3.52.
Status: Perl52.1 repaired/targeted-checked; independent peers pending.

## Existing authority and actual gap

The source-boundary reference and typed source-location contract already own
these zero-argument Number-or-null helpers. They read Unicode character widths
and update the anonymous capture origin after a valid read:

| Source | Width endpoint | Successful new origin |
| --- | --- | --- |
| capture_take_len() | Current local-match start | Live cursor |
| capture_take_until_cursor_len() | Live cursor | Live cursor |
| capture_take_rest_len() | End of input | End of input |

The live parser cursor does not move. Missing/reversed spans return null without
advancing; a real empty span has defined zero width and skips a defined-only
fallback. Preserve local-match presence and every operation/diagnostic tag.
Named *_from helpers and internal scanner ids remain separately governed.

At cleanff4f74b849, nine public Perl controls distinguish six healthy native/
bound cases from three failed direct coalesce/add/cat chains. On αβ:catTAIL at
origin2/live6, widths are1/4/8 and new origins6/6/10. Bound results are2!/5!/9!.
Direct chains fail undefined host coalesce despite raw0/fallback0/unresolved0/
ready1. Public substitution leaves authored methods after late native do-blocks;
early ordinary value lowering covers readonly Number33 and advancing String51,
but not the advancing Number sources. No primitive arithmetic defect is inferred.

## Frozen ordinary flow

- Existing three zero-argument sources compose through compatible defined-only
  default/arithmetic/Number-to-String/String-to-Array/signed selected-String links.
  No new helper, alias, parameter, type, coercion or mutation is introduced.
- Read each source once, perform its guarded origin update once, and retain the
  resulting Number before later consumer effects. Later origin reads/reset see
  ordered state; the completed Number/String snapshot remains stable.
- Preserve defined zero/lazy fallback suppression and missing/reversed no-advance.
  Normalized incompatible consumers skip operands while retaining valid source/
  prefix effects. Existing direct first-consumer/root behavior stays qualified.
- Keep invalid-shape/preflight/error-phase, named-source/overload, pure-function,
  callback/deferred vocabulary, unknown-call, copy/AST/schema/generated-format
  policies. Do not broaden helper allowlists or infer peer implementation gaps.

Shared prospective fixture tests/fixtures/capture_advance_number_values.spec/.json
uses the proven explicit Value[2] carrier on ten decoded characters αβ:catTAIL.
Its independent bound twin passes native/fresh with eleven coordinates:
[["2!","TAIL",9,[6,6,10],null,1,"99!","8!",6,6,"A"]].
The exact direct twin fails compilation. The target distinguishes three native
endpoints, ordered A effect, normalized BAD skip, defined-zero F skip, reversed
local-start fallback, and retained width8 before a later reset changes origin10
back to live6 inside cat. The fixture is future implementation input, not proof
of direct execution before52.1.

For currently working Perl authoring, bind the primitive first:
`n=capture_take_rest_len(); return(n.coalesce(0).add(1))` gives9 from origin2 on
that input. `n=capture_take_until_cursor_len(); return(n.cat(":tail").split(":")[-1].uppercase())`
givesTAIL, with origin6/live6. Full worked implementation examples follow the
same frozen fixture after the direct-chain repair.

Independent52.1 Perl/52.2 Rust/52.3 Dart/52.4 Julia/52.5 safe installed Lua
establish their own baseline before production. Preserve compatible peers
without invented RED. Exact public producer/inputs/native/fresh/metadata/
substitution/target twins are retained in capture-advance-number-selection-intake.json.gz.
No production change in selection. Full source/domain/context/portable23.4,
pressure20.1, Perl canonical registration and declared Lua5.4 remain separate.

## Bounded Perl52.1

One advancing-Number factory now shares three original guarded native bodies
with exact-zero-argument early ordinary value lowering after the function fence.
Three primitives and named capture_take_len_from(begin) printed bodies stay
byte-identical. Initial13 has6 RED/7 healthy, then13 GREEN with unchanged normal/
fixture. The standalone snapshot already worked and remains a healthy control.
Native/fresh shared11/direct/bound/zero/missing/effects/normalized guards/
snapshots/named-source/function checks are warning-free; selected String2/
readonly Number2/reset2 and both module syntax checks pass. Old emitted Number
module still fails host coalesce after repair: regenerate affected modules.
Actual epochs/producers/results/inputs retained in capture-advance-number-perl-intake.json.gz.
No effect/preflight/format/vocabulary or full23.4 movement. Explicit normal
registration23.4.1 and independent Rust52.2 remain separate.
