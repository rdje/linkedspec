---
id: perl-sort-comparator-working-variable-capture
title: Perl emitted sorted comparator captures DSL a and b lexical bindings
answers:
  - "why does sorted change when a and b working variables exist"
  - "why does array 3 1 sorted last add 4 return 5"
  - "do function parameters a and b shadow Perl sort comparator inputs"
  - "which task owns Perl sort comparator magic isolation"
date: 2026-10-31
status: bounded P1 repair61.0 targeted-checked; constructor61.1 next
tags: [perl, sorting, scope, variables, comparator, emission]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.22; constructor-result-selection-intake.json.gz retains exact native/fresh a/b-to-left/right and function-parameter falsifiers, public substitution and all source inputs."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/perl_sort_scope.t t/sorted_values_scalar_isolation.t"
---

At69cc32fd3 sorted comparator copies unqualified $a/$b inside the handler/function
lexical scope. Legal DSL working/parameter a/b bindings shadow Perl magic. Seeded
a=b="same" returns unsorted [3,1] for free/literal/constructor sources on native/
fresh; changing only names to left/right restores [1,3]. Function parameters
reproduce all three failures, caller values stay. Numeric/string layers without
a/b sort correctly; arithmetic output5 instead7 is caller-scope-dependent.

Shared MethodLowering sorted sort_comparison produces both bare/computed forms.
P1 owner61.0 isolates actual host comparator inputs in the compilation package,
preserving scalar-copy flags/kinds and caller bindings; no name reservation or
constructor producer/arity/domain change. perl-sort-comparator-scope.md owns
current acceptance, verified repair immediately before constructor61.1. No fix
or peer failure is inferred from the pre-implementation freeze.

Repair61.0 binds our ($a,$b) inside the emitted comparator block, selecting host
sort inputs in the actual compilation package and preserving scalar-copy cmp.
Same11 groups5healthy6RED to11PASS native/fresh/metadata. Original expected7,
four healthy observations/error row/caller values/kinds/indexes/source effects
stay. Eight nearest sort-kind programs/15 sorted_values groups and syntax pass.
Actual inputs/epochs/failed smoke cursor-assumption correction retained in
perl-sort-scope-intake.json.gz. Regenerate emitted Perl. New11/shared7 canonical
registration23.4.1 and constructor61.1 remain separate; no domain expansion.
