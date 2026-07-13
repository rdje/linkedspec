---
id: punctuation-light-receiver-arity-calibration
title: "A terminal bare receiver supplies zero authored arguments; arity examples must subtract the implicit receiver from function-form helper arity."
answers:
  - "why does the punctuation light contract use contains instead of drop_front"
  - "does drop_front require an authored receiver argument"
  - "how is receiver method authored arity derived from helper arity"
  - "which receiver method demonstrates missing argument rejection"
date: 2026-07-13
status: confirmed
tags: [dsl, actionir, receiver, arity, contract, perl-reference, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.16.2.0 used LinkedSpec::call_spec_handler_subst plus perl/LinkedSpec/ActionIR/MethodLowering.pm's canonical %ast_aggregate_call_arity table. Function-form drop_front is [1,2], so its implicit receiver leaves zero or one authored arguments and values.drop_front() validly drops one. Function-form contains is [2,2], so its implicit receiver leaves exactly one authored argument and values.contains() takes the established unsupported-helper rejection path. The neutral contract therefore uses values.contains / values.contains() for same-rejection proof without changing syntax policy or backend behavior."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $s (q{return(values.drop_front())},q{return(values.contains())}) { print LinkedSpec::call_spec_handler_subst(\"Top\",$s),qq{\\n} }' && python3 tools/check_punctuation_light_zero_arg_contract.py"
---

# Receiver arity calibration

Receiver methods consume the value to the left of the dot as an implicit first helper argument. Therefore the
authored receiver arity is the canonical function-form arity minus that receiver slot.

- `drop_front(array_expr[, count])` has function arity `[1,2]`, so `.drop_front()` is valid and defaults to one.
- `contains(array_expr, value)` has function arity `[2,2]`, so `.contains()` is missing one authored argument.

The punctuation-light rule remains unchanged: a final `.method` supplies zero authored arguments and must behave
exactly like `.method()`. The neutral contract uses `contains` only because it is a truthful required-argument
example; it does not add or remove a helper.

## Links

- Contract: `capability_conformance/punctuation_light_zero_arg_contract.json`
- Perl arity owner: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md`, leaf `.16.2.0`
- Related: [[punctuation-light-zero-argument-calls]]
