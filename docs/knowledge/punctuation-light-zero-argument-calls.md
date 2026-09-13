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
  - "does Julia implement punctuation light zero argument calls"
  - "does Lua implement punctuation light zero argument calls"
  - "what owns punctuation light zero argument calls"
  - "where is the punctuation light zero argument neutral contract"
date: 2026-09-13
status: confirmed
tags: [dsl, actionir, calls, control-flow, syntax, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.16.0 read-only source audit and ADR 0033 establish the narrow decision. FUTURE-PARITY-BACKLOG.16.1 adds linkedspec-punctuation-light-zero-arg-v1: six standalone AST-equivalence cases, four terminal receiver cases, three retained identifiers, six negative syntax cases, two method-resolution cases, and a deterministic fixture returning {result: yes, picked: a, count: 2}. Its independent checker proves bare/parenthesized normalization, final-only receiver recognition, condition/helper/trailing-block exclusions, ordinary-identifier retention, existing method-contract delegation, exact fixture rendering/evaluation, and three drift mutations. FUTURE-PARITY-BACKLOG.16.2.0 calibrates the required-argument method case to contains after proving drop_front permits zero authored receiver arguments. FUTURE-PARITY-BACKLOG.16.2.1 makes Perl consume the contract through equal typed statement/fluent ASTs, canonical bare next, and exact live/generated execution. FUTURE-PARITY-BACKLOG.16.3 makes Rust recognize only exact statement-boundary markers plus terminal generic receivers and proves equal typed ASTs, retained exclusions, and exact native/serialized/emitted/generated/CLI execution. FUTURE-PARITY-BACKLOG.16.4 adds Dart statement-only bare next plus terminal generic receivers and proves equal typed ASTs, retained exclusions, and exact native/generated-plan/emitted-state/CLI execution. FUTURE-PARITY-BACKLOG.16.5 adds the same contextual normalization and native/generated-plan/emitted-state/CLI proof on Julia. FUTURE-PARITY-BACKLOG.16.6 normalizes statement-only next and terminal non-block receivers on Lua, narrows the earlier every-segment fallback, and proves typed/serialized/native parity at 109/109 on PUC Lua and LuaJIT. FUTURE-PARITY-BACKLOG.16.7 admits one explicit capability at 64/0/0 and adds a composed recurring proof: Perl 7, Rust 5, Dart 5, Julia 55, PUC Lua 109, and LuaJIT 109. Rust, Dart, Julia, and Lua's pre-existing contains missing-argument outcomes are separately owned by helper backlog .5. Lua generated-source preservation remains .8.1-.8.4 because no emitter exists."
reverify: "bash tools/check_punctuation_light_five_backend.sh && perl tools/check_capability_conformance.pl"
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

Perl, Rust, Dart, Julia, and Lua implement the alias surface, and `FUTURE-PARITY-BACKLOG.16.7` admits it as
`language.punctuation_light_zero_argument_aliases` at capability census 64/0/0. Rust, Dart, Julia, and Lua's existing `.contains()` missing-argument outcomes are
helper drift owned by `.5`; `.contains` still behaves exactly like its parenthesized twin on each backend. Lua
proved native/serialized state on both ABIs at that admission. Its then-pending generated-source
work subsequently completed under `LUA-BACKEND-PARITY.8.4`; see the dated qualification below.

`capability_conformance/punctuation_light_zero_arg_contract.json` is the versioned neutral source. It contains
both spellings, their canonical AST projection, exact excluded forms, and a portable `.spec` fixture. The offline
checker is `tools/check_punctuation_light_zero_arg_contract.py` and is wired into canonical local CI. The composed
cross-backend command is `tools/check_punctuation_light_five_backend.sh`.

## Links

- ADR: `docs/decisions/0033-punctuation-light-zero-argument-calls.md`
- Tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md`, complete parent `.16` through admission `.16.7`
- Related: [[terse-call-spacing-contract]]
- Arity calibration: [[punctuation-light-receiver-arity-calibration]]


## September 13 source-reading qualification

`CONFORMANCE-SOURCE-READING.1.8` reads the complete67-line neutral contract and
reruns its offline checker: six standalone, four receiver and six invalid forms
plus exact fixture output pass. The contract's `future_fixture` key is retained
as its established fixture identity; it does not classify current implementation.

The original July13 evidence above predates Lua's emitter. Its statement that no
emitter exists is historical: [[lua-generated-source-accepted-subset]] records
`.8.3` proof and `.8.4` admission, and the current generated contract was checked
during conformance `.1.3`. This reading does not rerun Lua or infer a fresh
punctuation-specific emitted matrix. Historical census and test counts remain
dated milestones; current capability truth lives in [[backend-capability-census]].
