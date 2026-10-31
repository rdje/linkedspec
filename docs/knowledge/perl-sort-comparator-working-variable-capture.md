---
id: perl-sort-comparator-working-variable-capture
title: Perl emitted sorted comparator captures DSL a and b lexical bindings
answers:
  - "why does sorted change when a and b working variables exist"
  - "why does array 3 1 sorted last add 4 return 5"
  - "do function parameters a and b shadow Perl sort comparator inputs"
  - "which task owns Perl sort comparator magic isolation"
date: 2026-10-31
status: confirmed P1;61.0 immediately before constructor61.1
tags: [perl, sorting, scope, variables, comparator, emission]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.22; constructor-result-selection-intake.json.gz retains exact native/fresh a/b-to-left/right and function-parameter falsifiers, public substitution and all source inputs."
reverify: "Recover shadow/layers public cases and observer from constructor-result-selection-intake.json.gz into new project-local outputs. Historical writers are one-shot; current repair owner61.0."
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
