---
id: punctuation-light-zero-argument-calls
title: "ADR 0033 and FUTURE-PARITY-BACKLOG.16 — zero-argument punctuation-light syntax is a narrow executable alias contract, not a general parenthesis-free call grammar."
answers:
  - "can else endif default endcase endswitch omit parentheses"
  - "can next be written without parentheses"
  - "can a final zero argument receiver method omit parentheses"
  - "can an intermediate receiver method omit parentheses"
  - "can if and while conditions omit parentheses"
  - "which backends already parse bare control markers"
  - "does Rust implement punctuation light zero argument calls"
  - "does Dart implement punctuation light zero argument calls"
  - "what owns punctuation light zero argument calls"
  - "where is the punctuation light zero argument neutral contract"
date: 2026-07-13
status: confirmed
tags: [dsl, actionir, calls, control-flow, syntax, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.16.0 read-only source audit and ADR 0033 establish the narrow decision. FUTURE-PARITY-BACKLOG.16.1 adds linkedspec-punctuation-light-zero-arg-v1: six standalone AST-equivalence cases, four terminal receiver cases, three retained identifiers, six negative syntax cases, two method-resolution cases, and a deterministic future fixture returning {result: yes, picked: a, count: 2}. Its independent checker proves bare/parenthesized normalization, final-only receiver recognition, condition/helper/trailing-block exclusions, ordinary-identifier retention, existing method-contract delegation, exact fixture rendering/evaluation, and three drift mutations. FUTURE-PARITY-BACKLOG.16.2.0 calibrates the required-argument method case to contains after proving drop_front permits zero authored receiver arguments. FUTURE-PARITY-BACKLOG.16.2.1 makes Perl consume the contract through equal typed statement/fluent ASTs, canonical bare next, and exact live/generated execution. FUTURE-PARITY-BACKLOG.16.3 makes Rust recognize only exact statement-boundary markers plus terminal generic receivers and proves equal typed ASTs, retained exclusions, and exact native/serialized/emitted/generated/CLI execution. FUTURE-PARITY-BACKLOG.16.4 adds Dart statement-only bare next plus terminal generic receivers and proves equal typed ASTs, retained exclusions, and exact native/generated-plan/emitted-state/CLI execution. Rust and Dart's pre-existing contains missing-argument outcomes are separately owned by helper backlog .5. Complete backend admission remains future under .16.5-.16.7."
reverify: "python3 tools/check_punctuation_light_zero_arg_contract.py && prove -Iperl t/punctuation_light_zero_arg_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test punctuation_light_zero_arg_contract && (cd dart && dart test test/punctuation_light_zero_arg_contract_test.dart) && perl tools/check_capability_conformance.pl"
---

# Punctuation-light zero-argument calls

Parentheses remain LinkedSpec's general call grammar. ADR 0033 adds only a bounded alias surface:

- `else`, `endif`, `default`, `endcase`, `endswitch`, and `next` are intended to equal their zero-argument
  statement calls wherever those calls are valid;
- a final ActionIR receiver segment may use `.method` in place of `.method()` and still goes through ordinary
  zero-argument contract/arity validation;
- existing parenthesized forms remain valid.

This does not authorize parenthesis-free `if`/`while` conditions, general helper or user-function calls,
argument-bearing calls, attached final-codeblock calls, or intermediate generic receiver segments. Existing named
control-marker fluent suffixes remain their own established exception.

Perl, Rust, and Dart implement the alias surface. Julia and Lua remain backend-owned work, so the target contract
must not be described as fully implemented until `FUTURE-PARITY-BACKLOG.16.5-.16.7` close. Rust and Dart's existing
`.contains()` missing-argument outcomes are helper drift owned by `.5`; `.contains` still behaves exactly like its
parenthesized twin on each backend.

`capability_conformance/punctuation_light_zero_arg_contract.json` is the versioned neutral source. It contains
both spellings, their canonical AST projection, exact excluded forms, and a future `.spec` fixture. The offline
checker is `tools/check_punctuation_light_zero_arg_contract.py` and is wired into canonical local CI.

## Links

- ADR: `docs/decisions/0033-punctuation-light-zero-argument-calls.md`
- Tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md`, design `.16.0`, contract `.16.1`, Perl `.16.2`, Rust `.16.3`, and Dart `.16.4`
- Related: [[terse-call-spacing-contract]]
- Arity calibration: [[punctuation-light-receiver-arity-calibration]]
