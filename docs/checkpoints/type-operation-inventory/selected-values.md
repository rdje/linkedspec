# Selected array values and fluent continuations

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.1`; implementation children `.23.3.1`.
This freezes one bounded feature contract before implementation. It is not a
current cross-backend admission or the complete per-type transition matrix.

## Existing authorities

- `capability_conformance/uniform_binding_contract.json`: current typed values,
  copied value/mutation boundaries and one binding namespace.
- `capability_conformance/scalar_text_contract.json` and
  `capability_conformance/scalar_numeric_contract.json`: unchanged scalar
  normalization, null/invalid domains and numeric argument/result semantics.
- `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`: existing
  first/last, string, array, harray and numeric helper signatures.
- `docs/checkpoints/type-operation-inventory/syntax.md` and `helpers.md`:
  syntax/callable roles and spelling recognition are separate from methods.

## Normative behavior

`array_expr.first()` and `array_expr.last()` take no method arguments. They
select the first/last entry, or return null for an empty array, using the existing
helper contract. Selection returns the entry's actual kind; it is not always a
string, an array, or the kind of the chain's initial receiver.

A following compatible **ordinary pure value method** consumes that selected
value. Its behavior is the existing helper behavior applied to the result, in
the same order as nested helper calls. For example,
`parts.first().trim().uppercase()` means `uppercase(trim(first(parts)))`.
The chain must not silently stop at extraction and return null merely because
another compatible value method follows.

| Transition | Required continuation behavior |
| --- | --- |
| string -> split -> array -> first/last -> string method | Operate on the selected string, including after intervening pure array methods. Preserve split's existing regex/literal, Unicode and trailing-field policy. |
| array<array> -> first/last -> array method | Operate on the selected nested array; a subsequent extraction again yields its own actual value kind. |
| array<harray> -> first/last -> harray method | Apply the existing pure harray operation; key/value array results may continue through compatible array methods. |
| array<number> -> first/last -> numeric method | Apply existing numeric normalization, arity and invalid-domain rules to the selected value. Do not stringify it because the original source was an array. |
| empty array -> first/last -> method | Pass null to the next method's existing null/invalid-input rule. For example trim/uppercase propagate null. There is no blanket new error or empty-container coercion rule. |

The receiver expression evaluates once. Each continuation receives the prior
step's value once; its arguments retain the existing helper's order, laziness,
arity rejection and side-effect rules. Do not reevaluate the source to infer a
kind or retain a stale earlier binding value. Pure continuations preserve the
existing copy/alias semantics of their nested-helper equivalents; this feature
does not introduce a new deep-copy boundary.

Incompatible operands follow the chosen method's existing contract (null,
empty result or typed diagnostic as already governed). No universal wrong-kind
policy is introduced. This contract adds neither methods to codeblocks nor a
new regex type, binding namespace, callable execution context or mutation form.
Bang/addressable mutation methods and additional callback-method admission are
outside this bounded feature; their existing contracts remain authoritative.

## Required examples (implementation targets)

These are normative targets, not claims that every current backend passes.

```text
" a : b ".split(/:/).first().trim().uppercase()       # "A"
[" A ", " B "].last().trim().lowercase()             # "b"
[[3,1],[2]].first().sorted().last().add(4)             # 7
[{"b":2,"a":1}].first().sorted_keys().last().uppercase() # "B"
[2,3].last().mul(4)                                  # 12
[].first().trim()                                    # undef
```

A focused implementation check must also retain a saved source/snapshot and an
observable once-only source or argument effect. A correct nested-helper result
is an independent distinguishing oracle for the equivalent fluent journey.
Do not replace broad admission with a sample count.

## Observed starting gap and schedule

At clean `122da1d88acae6fc4412f2a31fef5d8314776ef3`, public Perl Get returns
`[null,"A",null]` for the first/last string journeys beside their nested helper
control. call_spec_handler_subst emits `undef` for the fluent journeys; no
runtime error is reported. MethodLowering's array return-family callback calls
first/last terminal, and subsequent chain loops stop before the next family.
Other backends are not classified from this Perl observation.

Freeze this contract, then implement/confirm Perl, Rust, Dart, Julia and Lua in
separate focused leaves. Each runs compilation and a small targeted regression;
complete family matrices, source-fault campaigns and portable admission remain
with `.23.4` after feature coverage. The full signature/effect inventory remains
open and resumes after this concrete requested transition is implemented.

Current implementation: Perl ordinary scalar/container subsets
`.23.3.1.1.1` and `.23.3.1.1.2` support the selected-value journeys with existing
pure helper semantics, generic runtime-kind copy, repeated extraction, earlier
pipeline/hash bridges, function/computed sources, empty values and once-only
effects. Focused native/fresh checks cover the named examples. This is bounded
implementation, not complete fluent families, other-backend or `.23.4` admission.

Rust `.23.3.1.2` implements the same bounded transitions via its existing dynamic
receiver dispatcher and retains actual selected kinds/copy. Native/restored/
generated-plan focused controls pass; trim null propagation is repaired as a
blocking helper case. Other known scalar-null gaps retain61.1/.61.2 ownership
and prevent complete scalar/fluent admission. Dart/Julia/Lua remain next.
