---
id: punctuation-light-receiver-arity-calibration
title: "A terminal bare receiver supplies zero authored arguments; arity examples must subtract the implicit receiver from function-form helper arity."
answers:
  - "why does the punctuation light contract use contains instead of drop_front"
  - "does drop_front require an authored receiver argument"
  - "how is receiver method authored arity derived from helper arity"
  - "which receiver method demonstrates missing argument rejection"
  - "does Rust reject contains with no receiver argument"
  - "why does Rust contains without a needle return zero"
  - "why does Dart contains without a needle return zero"
  - "why does Julia contains without a needle return zero"
  - "why does Lua contains without a needle return zero"
date: 2026-10-26
status: Perl/Rust/Dart one-needle guards checked; Julia/Lua normalization active
tags: [dsl, actionir, receiver, arity, contract, perl-reference, FUTURE-PARITY-BACKLOG]
evidence: "July13 canonical function arity and alias calibration; exact prior multi-backend and September reading records at Git39d8f85ebe9f954bc716d083083850604624e86f for this path. TYPE23.2.13 activates FUTURE5.6 normalization."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_contains_results.pl missing"
---

A final .method supplies zero authored arguments, exactly like .method(). Subtract the implicit receiver from function arity: drop_front[1,2] allows0/1 authored arguments; contains[2,2] requires1. The punctuation-light contract never changes helper arity.

July calibration found direct Perl contains missing rejection (undef) versus numeric0 on Rust/Dart/Julia/Lua; both spellings preserved each host’s existing result. Those historical observations, test/reconstruction limits and exact commands remain at the Git pointer above; they are not a new type/arity policy.

TYPE23.2.13 now explicitly activates original owner FUTURE-PARITY-BACKLOG.5.6: ordinary receiver contains missing/extra operands return null before effects, both missing aliases identical. TYPE23.3.13.1-.5 implement independently and update each backend’s actual named calibration expectation. Free helper signatures and membership equality/kinds stay unchanged. Perl23.3.13.1 now uniformly rejects missing/extra before effects, including both nested Array aliases, fixing their raw host-call fallthrough; direct rejection was already present. Rust23.3.13.2 now enforces null/no-effects too, with its exact named alias calibration updated from numeric0; Dart23.3.13.3 is targeted-checked too with its named expectation updated0->null; Julia/Lua remain pending.

Authorities: capability_conformance/punctuation_light_zero_arg_contract.json; perl/LinkedSpec/ActionIR/MethodLowering.pm; [[array-contains-result-handoff]]. Full portable admission remains TYPE23.4.
