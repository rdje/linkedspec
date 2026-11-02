---
id: punctuation-light-receiver-arity-calibration
title: "A terminal bare receiver supplies zero authored arguments; arity examples must subtract the implicit receiver from function-form helper arity."
answers:
  - "why does the punctuation light contract use contains instead of drop_front"
  - "does drop_front require an authored receiver argument"
  - "how is receiver method authored arity derived from helper arity"
  - "which receiver method demonstrates missing argument rejection"
  - "why does Perl punctuation light contains fixture fail"
  - "does Rust reject contains with no receiver argument"
  - "why does Rust contains without a needle return zero"
  - "why does Dart contains without a needle return zero"
  - "why does Julia contains without a needle return zero"
  - "why does Lua contains without a needle return zero"
date: 2026-11-02
status: five ordinary one-needle guards targeted-checked; full admission open
tags: [dsl, actionir, receiver, arity, contract, perl-reference, FUTURE-PARITY-BACKLOG]
evidence: "July13 canonical function arity and alias calibration; exact prior multi-backend and September reading records at Git39d8f85ebe9f954bc716d083083850604624e86f for this path. TYPE23.2.13 activates FUTURE5.6 normalization. November2 restoration component TYPE20.1.12 reproduces the stale Perl unsupported-marker assertion, confirms native/fresh null-before-effects with a valid membership control and corrects the recurring fixture; original helper arity and runtime source remain unchanged."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_contains_results.pl missing"
---

A final .method supplies zero authored arguments, exactly like .method(). Subtract the implicit receiver from function arity: drop_front[1,2] allows0/1 authored arguments; contains[2,2] requires1. The punctuation-light contract never changes helper arity.

July calibration found direct Perl contains missing rejection (undef) versus numeric0 on Rust/Dart/Julia/Lua; both spellings preserved each host’s existing result. Those historical observations, test/reconstruction limits and exact commands remain at the Git pointer above; they are not a new type/arity policy.

TYPE23.2.13 now explicitly activates original owner FUTURE-PARITY-BACKLOG.5.6: ordinary receiver contains missing/extra operands return null before effects, both missing aliases identical. TYPE23.3.13.1-.5 implement independently and update each backend’s actual named calibration expectation. Free helper signatures and membership equality/kinds stay unchanged. Perl23.3.13.1 now uniformly rejects missing/extra before effects, including both nested Array aliases, fixing their raw host-call fallthrough; direct rejection was already present. Rust23.3.13.2 now enforces null/no-effects too, with its exact named alias calibration updated from numeric0; Dart23.3.13.3 is targeted-checked too with its named expectation updated0->null; Julia23.3.13.4 is targeted-checked too with its actual calibration0->nothing; Lua23.3.13.5 is targeted-checked too: actual named calibration now null and both aliases agree on PUC5.5.1/LuaJIT.

Authorities: capability_conformance/punctuation_light_zero_arg_contract.json; perl/LinkedSpec/ActionIR/MethodLowering.pm; [[array-contains-result-handoff]]. Full portable admission remains TYPE23.4.

## Current Perl recurring assertion

Restoration component `TYPE-REFERENCE-BOOK.1.2.20.1.12` finds that the punctuation consumer still required
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER`, although the existing typed shape guard at
`perl/LinkedSpec/ActionIR/MethodLowering.pm` rejects a contains receiver with other than one authored operand
as `undef` before lowering receiver or operand effects. Public substitution dumps `return undef` for both
missing aliases. Native and independently loaded emitted probes return `[null,null,"",1]`: both missing forms
skip effects and the supplied needle still matches. Admitting the missing operand and removing the valid
needle are distinguishing changed-program controls. The recurring fixture now asserts canonical null rather
than an obsolete unsupported marker and checks native/fresh outcomes plus zero fallback/raw/unresolved metadata.
No runtime implementation, helper signature or syntax boundary changes. Exact RED/GREEN and producer/input
epochs are retained in `docs/checkpoints/document-pressure-restoration/punctuation-intake.json.gz`.

The initial intake's limits text named TYPE23.4.3 for input custody in error. The actual deferred fixture-input
custody owner is `TYPE-REFERENCE-BOOK.1.2.23.4.2`;23.4.3 owns backend acceptance-gate path coverage.
`docs/checkpoints/document-pressure-restoration/custody-owner-correction.json` preserves the original limits
and producer bytes and records the corrected route. No complete transitive input-custody credit is added.
