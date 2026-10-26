# Count and length results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.2`; implementation family `.23.3.3`.
This freezes a bounded target before code. It is not a claim of current
cross-backend support or complete fluent-family admission.

## Existing authorities

- The public helper catalog supplies `count(array)`, `count_keys(harray)` and
  `length(scalar|array)` input/result and empty/missing policies.
- `capability_conformance/scalar_numeric_contract.json` and
  `capability_conformance/scalar_text_contract.json` retain numeric domains,
  scalar normalization, invalid-input and result semantics.
- `capability_conformance/uniform_binding_contract.json` retains value identity,
  mutation/copy and binding rules.
- `docs/checkpoints/type-operation-inventory/selected-values.md` supplies existing
  first/last actual-value continuation and ordinary pure-method boundaries.

## Bounded contract

The result of ordinary receiver `count()`, `count_keys()` or `length()` is the
current value for a following existing compatible pure scalar/number method.
Do not stop merely because the original receiver was an array, harray or string.
For example, `items.count().add(3)` means `num_add(count(items),3)`, and
`text.length().uppercase()` means `uppercase(length(text))`.

Each producer takes zero extra receiver operands. An extra operand is an invalid
shape: return undef/null before receiver or operand effects, as with existing
first/last/copy arity boundaries. Free-helper signatures are unchanged.

Evaluate the receiver once, compute its result once, then evaluate each required
continuation operand once in the helper's existing order. Later mutations must
not cause a count/length to be recomputed. Preserve the existing helper's
laziness, domain checks, null/error behavior and actual result kind. A following
string-producing method may feed the existing string/array/selected-value paths.

An invalid-domain continuation follows that helper's existing contract. There is
no universal new wrong-kind policy, no implicit revival of the original container,
and no new deep-copy promise. Keep the book's backend-specific copy boundaries.
Producer source-kind policies remain unchanged; this feature admits result flow,
not additional inputs to count, hash count or length.

## Required implementation examples

These are normative targets, not statements that all current backends pass.

| Expression | Expected |
| --- | --- |
| `[1,2].count().add(3)` | `5` |
| `"abcd".length().add(2)` | `6` |
| `{"a":1,"b":2}.count_keys().mul(2)` | `4` |
| `[].count().add(1)` | `1` |
| `"".length().add(1)` | `1` |
| `{}.count_keys().add(1)` | `1` |
| `[[1,2,3]].first().count().add(1)` | `4` |
| `["ab"].first().length().add(1)` | `3` |
| `[1,2].count().cat(" items").uppercase()` | `"2 ITEMS"` |
| `[].first().length().add(1)` | undef/null, by existing length/numeric rules |

Retain once-only source/operand controls and a source mutation in a later operand.
Check direct, selected-value and earlier container/string pipeline producers;
reuse existing compatible helper implementations and retain valid copy behavior.

## Previous boundaries and exclusions

The first/last-only contract left count and length terminal. Its ordinary
`[1].count().uppercase()` negative control is superseded by this contract: the
compatible scalar helper now receives numeric one and returns `"1"`. Update that
control with implementation, not before it, and do not misclassify the deliberate
contract advance as an unrelated regression.

Numeric aggregate reducers, membership/search/predicate outputs, control-flow
results, additional callback-method admission, callable/deferred contexts and
addressable mutation retain their existing boundaries. There is no new type,
regex value kind, helper name or serialized/generated format. Full signatures,
result-transition matrices and portable admission remain separately owned.

## Activation findings and implementation order

Public Perl Get returns `[null,5,null,6]` for count/length addition beside nested
helpers, without last_error; substitution emits `return undef` for the chains.
Isolated hash controls establish `meta.count_keys()` and `count_keys(meta)` both
return two, and nested numeric addition returns five. Only the chained hash-count
addition retains raw DSL and reaches an undefined host call. The combined probe's
initial free-helper attribution was rejected by those isolated controls.

MethodLowering classifies these results as terminal in the array, hash and string
return-family callbacks. Perl implementation is first; assess each other backend
individually and preserve correct existing behavior. Commit each bounded backend
slice after compilation and small direct checks. Broad admission remains `.23.4`.

## Current implementation

Perl `.23.3.3.1` implements the bounded result flow and zero-extra producer guard
through existing selected-value dispatch. A small native/fresh fixture covers
direct/selected/pipeline values, Unicode and array length, source/operand order,
later mutations, invalid shapes and unchanged deferred count behavior. Direct
selected-scalar/container regressions pass. Other backends remain individually
unassessed at that checkpoint; no complete family or portable admission is claimed.

Rust `.23.3.3.2` implements the same result flow on static and dynamic array/hash/
string paths. Array pipelines accept length without changing initial string/scalar
dispatch. Native/restored/generated-plan and direct selected-value checks pass;
zero-extra producer guards suppress effects. Existing callable vocabulary and
serialized/generated formats stay unchanged; no full context/portable admission.
