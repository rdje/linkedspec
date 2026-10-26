# Aggregate operands and null Array keys

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.14; implementations23.3.14.1-.6; original
helper caveat coordination FUTURE-PARITY-BACKLOG.5.7.

README makes Perl the behavioral reference. The frozen uniform-binding read
policy evaluates a bare identifier to its current typed value. Pure helper value
operands capture that value before later operands; a later binding replacement
or mutation cannot replace an earlier input. Existing named wrong-kind/absent
empty-container fallback remains unchanged. Do not alter reference/lvalue target
resolvers, lazy control helpers, diagnostics, or unrelated invalid domains.
Rust get_bare_value already clones Array/Hash values; aggregate-consuming
adapters must use evaluated arguments rather than re-read current ctx names.

Ordinary has_key captures source, evaluates key once, then tests presence.
Move Perl’s key expression out of its defined(hash) ternary, including typed
and legacy value lowering. Null-source output remains0; key effects still run.
One-key preflight rejects malformed receiver arities before effects as before.

Perl contains/index_of explicitly distinguish an undefined needle/entry from
empty text; catalog uniq already promises the same distinction. Retain that
existing authority in contains/index_of/uniq: null matches only null and has a
distinct internal uniqueness key. Defined scalar conversion remains unchanged,
as do numeric flags/index kinds and first occurrence/value/kind/source order.
No new strict Boolean/number/container/callable equality, regex type, serialized
field or general conversion policy. New null-key controls must include empty,
mixed null/empty positions, numeric/string defined controls and nonmutation.
Complete scalar/container/domain/context admission remains23.4.

Retained operand-snapshot-membership.spec and public Perl/Rust probes expose the
pre-repair distinctions. Perl native/fresh membership is[1,0,0,1,1,1,0,1,1],
indexes[0,null,null,0,1,1,null,0,0], uniq[null,"",0]. Rust native/restored/plan
merges null/empty, picks index0 instead of1 and drops empty from uniq[null,0].
Other variants’ contains merging is confirmed; assess their index/uniq before
classification. Preserve defined-value coercion rather than broadening this
normalization into another equality policy.

Rust named index after needle rebinding isnull versus0, has_key0 versus1,
appended index1 versusnull, merged{z,b} versus{a,b}. Concat control already works.
Absent named Array/Hash sources become later values, contrary to initial literal
null controls. Perl has_key source-null returns0 but suppresses key assignment,
leaving finalnull. Public dump locates key inside defined ternary at typed
MethodLowering4501/4511 and legacy6840/6863. These are separate owned repairs,
not a reason to copy one host’s whole output as a universal expected object.

Run focused native/generated/direct checks and commit each bounded repair; no
exhaustive matrix or full backend gate in ordinary feature slices.

## Rust captured-source implementation

23.3.14.1 removes live ctx named reads from array_consuming_arg/hash_consuming_arg.
Use cached typed values; retain prior named wrong-kind/absent empty Array/Hash
fallback (flat_hash controls return Hash{}, not an assumed Array[]). Native/
restored/plan index/has_key/append/merge and absent-source results now follow
captured values; literal/concat/typed/default controls stay passing. Seven focused
snapshot/direct result/uniform tests and compilation/rustfmt pass after source
RED. Existing null-key equality and lazy/target resolvers are unchanged. Perl key
effects14.2 follows; no full domain/context/portable admission.

## Perl key evaluation implementation

23.3.14.2 moves key expressions into lexical temporaries after source capture,
before defined(source)/exists in both conditional typed/legacy value builders.
Source-null result remains0; native/fresh literal/bound/missing-source key effects
now run once, receiver order isSKC/source1/key1/result0!, valid/empty sources keep
captured results, malformed receiver arities still reject before effects. Eighteen
focused assertions with direct has_key/contains and source/test syntax pass after
key-suppression RED. Exhaustive legacy/context/domain admission remains separate;
Rust null comparison/uniqueness14.3 follows.

## Rust null-key implementation

23.3.14.3 uses a private Option<String> key: null=None, defined values retain
Some(to_str). contains/index_of compare keys and uniq retains first values/kinds
in source order, including standalone writeback. Explicit null and empty text
are distinct; missing free-helper needles keep their old empty-text default.
Native/restored/plan null/reference and direct contains/index/snapshot fixtures
pass six Rust tests after RED; independent Perl native/fresh reference passes six
assertions. Numeric/text/default/Array-to-count consumers and source/shape guards
remain correct. Current Rust contains/snapshot artifacts adopt the selected
reference. No global scalar conversion/arity/schema/source-policy change; Dart
index/uniq assessment14.4 follows, full admission remains23.4.
