# Perl sorted comparator scope isolation

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.61.0, P1 before constructor61.1.
Existing contract: ascending lexicographic nonmutating sorted(Array), preserving
scalar-copy kind/flags. a and b remain ordinary legal DSL working/parameter names.

Public source emits sort { my (sort_left,sort_right)=($a,$b); ...cmp... } inside
the handler/function lexical scope. DSL my $a/$b shadow Perl comparator magic.
With a=b="same", free/literal/constructor [3,1] sorting all returns [3,1];
changing only names to left/right yields [1,3]. Function a/b params reproduce
all three wrong outputs, caller values stay. A constructor numeric chain gives5
instead7; numeric/string layers without those variables sort correctly.

MethodLowering sorted branch shared sort_comparison emits both direct bare-array
and computed receiver forms. Isolate actual comparator inputs in the correct
compilation package, retaining scalar copies and caller bindings. Qualify helper/
receiver/named/literal/computed/constructor/function and native/fresh package
contexts, empty/single/repeated/nonmutation/kind/order/error controls before
minimal repair. No caller-name reservation/renaming or new sort-domain/arity/
deferred/schema authority. Shared7/falsifiers/full source/outputs/actual producers
are retained in constructor-result-selection-intake.json.gz. No production fix
claimed at freeze; next61.0 owns a verified repair before any constructor work.

## Bounded repair61.0

The shared comparator now declares package sort inputs inside its own block,
preventing capture of same-named DSL lexicals while retaining scalar-copy cmp.
Both direct bare-array and computed paths use it; no package name is hardcoded.
Same11 groups5healthy/6RED to11PASS on native/fresh packages/metadata. Ten values,
four healthy observations and original needed-error row are canonically exact.
Expected7 stays. Named/literal/helper/receiver/constructor/function/completed
forms, caller values/source once/local return/empty/single/nonmutation/kinds and
numeric indexes stay. Eight selected existing sort-kind cases and15 sorted_values
isolation groups pass;24 TAP groups includes a selection-count scaffold. Owner/
normal syntax0. Added smoke cursor oracle corrected1-to0 because entry I returns
precede matching; original fixture values unchanged, failed producer retained,
no engine RED credit. Actual producer/all inputs/epochs: perl-sort-scope-intake.json.gz.
Regenerate emitted Perl. Canonical new11/shared7 registration stays23.4.1-owned;
constructor61.1 follows, no sort-domain/arity/deferred/schema/peer/full admission.
