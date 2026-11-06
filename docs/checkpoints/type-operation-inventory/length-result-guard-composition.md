# Ordinary Length result guards

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.35; implementation family23.3.74.
Existing count-length-results.md3, catalog Length and typed result/copy/eager-logical
contracts retain authority. Status: all bounded Perl/Rust/Dart/Julia/installed Lua implementations focused-checked; full admission pending.

Canonical ordinary length(value), one positional recognized value, and receiver.length()
with zero extra operands keep current Number/null results. Length of a scalar is its
existing character length; Length of an Array is its cardinality. Preserve null, empty
String0, Number0, Bool/text conversion domains and existing source-kind policies per backend.
Do not normalize producer domains, add methods/signatures/aliases or change parsers/schema.

Actual Number/null results compose through compatible numeric/scalar methods, direct reads
and explicit String/Array bridges. Wrong-kind Array/Hash consumers reject with null before
their operands; later copy/logical/default/with links must not turn rejection into a valid
null value. Legitimate null/zero still feed current copy/eager-logical/with semantics.
Preserve source once, ordered snapshots, local return/function scope, needed source errors,
preflight arity and explicit bridge admission. Keep existing copy depths and eager truthiness.

```text
length("tail").add(1)                         # 5
"tail".length().add(1)                        # 5
length("").coalesce(7).add(1)                  # 1
length(undef).with(){return("recovered")}      # recovered
length("tail").take(1).copy().with(){return(9)} # null, body skipped
length("tail").set_key("k",1)                 # null; never consult host Hash4
length("tail").cat(",tail").split(",").last() # tail
```

Frozen tests/fixtures/length_result_guard_cases.json has16 authored programs: nine healthy
Perl preservation controls/seven target gaps on native/fresh routes. The scalar_array_sources
row is explicitly Perl-domain observation; each peer freezes its own current source-domain
profile before any repair. No failure is inferred for a peer. Malformed receiver preflight
skips source/operand/body; needed source errors cannot be masked by coalesce. Count([]) and
compatible Length prefixes distinguish missing source admission from a generic consumer bug.

Perl74.1 repairs actual-kind source roles and persistent rejection through copy/logical links,
including exact emitted main::4 empty/seeded host controls. Rust74.2, Dart74.3, Julia74.4,
safe installed Lua74.5 independently assess, preserve producer domains and repair only actual
gaps. No new Lua chunk locals/unsafe runner/formatter/declared5.4 inference. Actual inputs
must precede compiled proofs; full native/transitive custody23.4.2 remains separate.

Initial key-count source guard defects are owned P1 family75 assessment75.0 after74.5,
before unrelated selection/full admission. Length does not silently absorb count_keys.
Actual observations, source snapshots, recovery qualifications and seed root cause:
docs/checkpoints/length-selection-2026-11-05/REVIEW.md. No complete-family/admission claim.

## Bounded Perl74.1 repair

The unchanged new normal has19 groups: nine original healthy programs and ten failing
groups (seven authored target gaps/three explicit host seeds). All19 now pass native/fresh;
the nine healthy observations remain exact. Canonical free-one/zero-extra receiver Length
sources join current emitted actual-kind/with dispatch. Ordinary copy and eager logical
links retain the existing rejection flag; rename the shared Count/Length logical role for
clarity. Existing Length producer, Count fallback, domains/signatures/copy depths and
function/parser/schema policies stay. Empty/outer/main::4 seeds all reject with null,
no warning/error and unchanged host Hashes. Actual normal modules persist before fresh eval.
Direct Count/length/source/logical preservation and syntax pass; original/source/normal/
fixture identities, modules, raw phases and readonly corruptions survive under
length-guard-perl-2026-11-06. Regenerate emitted Perl. Rust74.2 independently next; no peer,
complete native/transitive custody, general isolation, registration or full admission claim.

## P1 Perl74.6 produced-Length ownership

A remaining free Length-to-Count edge used Count's initial-source zero fallback:
length("tail").count().with ran its body. The public emitted source contains a
constant-true guard; Count fallback is decided before Length ownership is added.
Move Length into emitted-result ownership before that decision. Only independent
initial Count sources retain non-array zero; produced Length Number/null values
now reject Count, including through copy/logical/with. Receiver Length, initial
Count, explicit Array bridges and needed source errors stay. Unchanged8 groups
4PASS4RED become8PASS; existing Length19 preservation stays required. Actual raw
probe/new-normal modules/declared phase inputs survive in
length-count-owner-perl-2026-11-06. This remaining gap does not invalidate the
original bounded19 outcomes or establish when the old behavior was introduced.
Independent Rust74.2 follows this P1; no peer failure or full admission claim.

## Bounded Rust74.2

Independent native/restored/plan/compiled emitted shared24 controls12PASS12RED
become24PASS; all twelve healthy observations are exact. Its actual initial
source-domain profile [1,1,1,2,2,null] is frozen before normal execution. Canonical
positional free-one/zero-extra Length role joins direct/trailing-with kind guards
before Count initial-source exception selection. Preserve both producers/domains/
signatures/copy depths/function/parser/schema; valid null/zero, eager copy/logical/
with/source snapshots/errors and bridges stay. Actual24 emitted module bodies
are unchanged; rebuild Rust applications/runtime. Final unused-import-only cleanup,
Length24/Count-length1/Count guards19=44, scoped rustfmt and five readonly corruptions
pass. Actual declared source/manifests/locks/modules/full raw phases and inspector
wrapper qualification survive in length-guard-rust-2026-11-06. Dependency warnings
stay public upstream-owned; broader native/transitive custody, canonical selection,
isolation and full admission remain open. Independent Dart74.3 next.

## Bounded Dart74.3

Independent native/restored/plan/emitted authored24 controls12PASS12RED become24PASS;
twelve healthy observations and independently frozen [1,1,1,2,2,null] domain stay
exact. Canonical positional free-one/zero-extra Length role joins kindGuardedSource
before Count initial-source permission. ScalarResult initialization/assignments,
common guards/Count permission/producers/domains/signatures/copy depths/function/
parser/schema stay. Actual24 module bodies unchanged; rebuild Dart apps/runtime.
Final Length24/Count-length2/Count guard19=45, full-owner/probe/normal format,
targeted fatal root/fresh analysis and five readonly corruptions pass. Actual
source/pub/lock/config/modules/parsed input archives/full raw channels survive
losslessly in length-guard-dart-2026-11-06. Outside helper/admission bytes and
normal/oracles exact. Full custody/selection/isolation/admission remain separate.
Independently baseline Julia74.4 next; no peer failure inferred.

## Bounded Julia74.4

Independent native/restored/plan/fresh Module24 programs12PASS12RED become24PASS;
twelve healthy observations stay exact. Its own [1,1,1,2,2,null] domain and full
per-route error profiles freeze before unchanged normal execution. Canonical
Length role joins kind_guarded_result before Count initial-source permission.
Keep scalar_result, one-step Count permission and enumerate/call_index Array-end
mutation restriction exact. Both producers/domains/signatures/copy depths/function/
parser/schema stay. Actual24 module texts/parsed inputs unchanged: rebuild Julia
apps/runtime. New normal122/Count-length6/Count guard92=220 assertions/strict
depwarn pass. Actual declared first inputs/full raw channels recover losslessly
with five corruptions in length-guard-julia-2026-11-06. Fresh Modules share process/
runtime; full custody/isolation/discovery/admission separate. Installed Lua74.5
next; P1 key-count75.0 afterward before unrelated selection.

## Bounded installed Lua74.5

PUC5.5.1/LuaJIT2.1.1788460057 independently capture native/restored/plan/fresh24
programs12PASS12RED becoming24PASS; twelve healthy observations exact per host.
Actual domain [1,1,1,2,2,null] and error fields agree before choosing shared fences.
Canonical Length member/admission joins kind_guarded_result before Count initial
permission; no new chunk locals. Scalar state, Count one-step permission, loop-
index mutation rights and producers/domains/signatures/copy depths/function/
parser/schema stay exact. Actual24 emitted/parsed bodies per host unchanged;
rebuild Lua apps/runtime. Final new122/nearest Count92 plus two Count-length
programs/native-plan-fresh, version and source/runner loadfile pass per host.
No unsafe full runner/formatter/declared5.4/full CI. Actual declared first inputs/
full raw phases recover with five corruptions in length-guard-lua-2026-11-06.
Fresh modules share process/runtime; full native/transitive custody/isolation/
discovery/declared5.4/admission remain separate. Length bounded implementations
are complete; P1 key-count75.0 next before unrelated selection.
