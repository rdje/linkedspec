# Emptiness results in ordinary receiver chains

Owner: `TYPE-REFERENCE-BOOK.1.2.23.2.8`; implementation family `.23.3.9`.
Bounded existing-helper targets; full domain/fluent/portable admission stays23.4.

## Existing authority and preservation

The catalog/value-container-flow reference defines is_empty as true for undef,
empty String, empty Array and empty Hash; is_nonempty is its inverse. String"0"
is data. Use actual yielded values, including expression-valued blocks, rather
than host reference truthiness or source spelling. Preserve actual producer kinds
and other established domains/copy behavior; no numeric-Boolean normalization,
new logical methods or contains missing-needle calibration change is introduced.

Ordinary receiver forms take no operands, under existing fluent shape policy.
The result feeds compatible Scalar/String methods; container-only consumers
return null until an explicit helper produces a container. Evaluate source once,
compute the predicate once, then consumer operands in existing order. Later source
mutation cannot recompute the predicate; no new deep-copy guarantee is made.

Implementation targets, not portable support claims:

| Expression | Result |
| --- | --- |
| `[].is_empty().cat("!")` | `"1!"` |
| `["a"].is_nonempty().cat("!")` | `"1!"` |
| `{}.is_nonempty().coalesce_nonempty("late").cat("!")` | `"0!"` |
| `["a"].is_empty().cat(",x").split(",").last().uppercase()` | `"X"` |
| `[].is_empty().sorted()` | undef/null |
| `is_nonempty("0")` | true; same value as a binding holding"0" |

## Public Perl findings and existing owner

probe_emptiness_results.pl retains public Get/substitution and fresh emitted
comparisons. Native/fresh basic Array/Hash producers return[1,0,0,1,1,1]. Fluent
empty/nonempty cat stops at null; nested counterparts give1!. Hash/selected/
pipeline forms stop too. array_chain_return_family defaults them to terminal.

The existing SESSION-STARTUP-READING16.1/.16.2 producer defect also reproduces:
literal"0" and its binding yield nonempty text0!/1!; a block yielding empty Array
gives wrong0!/SA after a consumer appends x. Native/fresh agree. Substitution
shows MethodLowering's general fallback testing !($value), so a reference counts
as host true even when its actual Array is empty. This is not a passing snapshot
oracle. Ordinary extra-argument fluent control currently returns[null,""] without
effects. Numeric/keyword host-slot and conditional surfaces remain with16 owners;
a bounded modern value repair must not claim their full closeout.

## Sequence

Commit assessment. Perl23.3.9.1.1 repairs bounded ordinary value producer kinds/
expression equivalence and establishes once-only snapshots;1.2 repairs result
handoff. Rust2/Dart3/Julia4/Lua5 each independently assess before changing code.
Use compile/small native/generated/direct checks/docs/commit. Preserve published
source/empty/null/String0 rules, track existing16 overlap explicitly, and keep
broader condition/selector/domain/admission work separate.

## Bounded Perl value producer repair

23.3.9.1.1 registers existing emptiness helpers on typed value calls, completing
their operand before once-only actual-kind emptiness emission. Native/fresh
producer tests pass after raw function-host-call RED and the retained block/String0
failures: literal/bound/nested/function/block values, inverse helpers, empty String/
Array/Hash/undef, String0/numeric0/false as data, two host-program-name states and
1!/SA/one-call snapshots. Direct has_key producer compatibility passes. FlowExpr/
global scalar recognition remain with SESSION16; receiver/result flow1.2 follows.
