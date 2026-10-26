# Ordinary logical Boolean result continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.17; implementation23.3.17.1-.5.
Authority: ADR0043 and capability_conformance/logical_helper_contract.json.
and/or/not remain ordinary eager free helpers, returning real Boolean values.
No .and/.or/.not counterpart, new truthiness, numeric Bool conversion or lazy
logical method is introduced. Existing receiver and typed-error promises stay
in force; full domain/context/portable admission is separately owned23.4.

## Frozen bounded flow

Actual Boolean results feed compatible existing scalar/text/generic methods.
and(true).cat("!")->1!,and(false).cat("!")->0!; or and not follow the same rule.
False stays selected by coalesce_nonempty and renders0!, not a late fallback.
Typed truthiness keeps nonempty "0"/"false" true, empty aggregates false and
nonempty aggregates true; testing callable values must not invoke them.
Numeric helpers still reject Bool: or(false).add(1) is null and may explicitly
recover to a Number or container with existing defaults. Example:
or(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase()->B.
Container-only consumers reject until an explicit bridge/default returns a
container. and(true).cat(",x").split(",").last().uppercase()->X;
not(false).sorted() and and(true).cat("x").sorted_values() should be null
without evaluating incompatible consumer operands or raising an accidental
container-binding error; this bounded scalar-result rule matches other result
families, and does not change free container-helper policies.
Preserve named/selected/Hash/block/function/literal Boolean source kinds and
captured values. No implicit numeric conversion or Boolean Array-index claim.

Valid logical operands run once, left to right, including decisive and-false
and or-true operands; consumer operands follow the computed Boolean. With
order markers L/R/C, a false-and chain yields0!/LRC with both inputs evaluated.
Lazy controls and lazy defaults keep their separate existing behavior.
Invalid logical source arity reports helper_arity_mismatch before its operands,
even when an operand contains an unknown helper and the result has a compatible
consumer. Do not replace that typed error with an unsupported-helper/null
sentinel. Known consumer-shape policies remain unchanged; no blanket error
precedence for unknown later consumers or new receiver vocabulary is frozen.

## Independent public Perl intake

Retained probe_logical_results.pl uses Get/substitution/dump/native and fresh
emitted routes. Raw producers retain[true,false,true,false,true,false]; direct
fluent/nested text yield[1!,0!,1!,0!,1!,0!]. Named/first/named-Hash/block/literal
sources all produce correct text. False/true defaults retain0!/1!, numeric-null
Array recovery givesB and definedness gives1!. Valid direct/nested eager effects
yield[0!,LRC,2,false]; truthiness String/aggregate controls pass.

The longer text->split->last bridge instead returnsnull. AST preserves the
logical call and four links; substitution emits unsupported-helper:cat where
the captured logical input should be. Fully nested equivalent returnsX. String
chain composition chooses its first consumer family and rebuilds aggregate DSL
without a typed logical-result boundary; explicit actual scalar dispatch is the
repair seam, not a change to RuntimeLogical producers.

Logical->text->Hash-only boundary leaves raw and(true).cat syntax: the
standalone form silently returnsnull, while the compound form fails handler
compilation. Direct not(false).sorted() returnsnull with binding_kind_mismatch
instead of clean scalar rejection; native context and fresh error identify
BindingRuntime::array_transform on the emitted Boolean. Malformed not(two).cat with
unknown fail operands returnsnull/unsupported-helper:fail; direct/nested forms
raise the typed arity error. Known valid-helper effect operands still raise the
correct error. MethodLowering's first_unknown_value_call_name scans source
operands before lower_ast_logical_call_node validates the source arity. Preserve
that typed validation before traversing invalid operands. No normalization of
existing valid eager input/producer/default behavior is needed.

Direct logical contract fixture passes eight top-level subtests, including
existing neutral values/effects/with receiver/lazy contrast and typed errors.
Backend implementations must assess their own public producers before changing
confirmed result/scalar/diagnostic gaps; no backend failure inferred from Perl.
