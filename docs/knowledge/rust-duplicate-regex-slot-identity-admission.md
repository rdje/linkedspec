---
id: rust-duplicate-regex-slot-identity-admission
title: "Rust ordered execution matches the required compiled regex slot directly"
answers:
  - "how did Rust fix duplicate regex slot identity"
  - "what are consume_slot_match and seek_slot_match"
  - "how does Rust preserve duplicate regex slots in generated execution"
  - "where does Rust validate compiled regex slot identity"
  - "what Rust diagnostics report regex slot identity corruption"
  - "how are duplicate regex slot selections traced in Rust"
  - "does Rust duplicate slot identity widen generated source v2 plans"
date: 2026-09-07
status: confirmed; Rust admitted by FUTURE-PARITY-BACKLOG.9.1.8.1.3
tags: [rust, regex, slot-identity, and, repetition, generated-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "CompiledAlternation retains the already-compiled individual Regex values beside its combined choice matcher. Engine and GeneratedPlanExecutor call consume_slot_match/seek_slot_match for known AND sequence steps, while OR/default choice keeps combined earliest-start/first-authored behavior. Both routes assert structural target/index identity, emit regex_slot_selected, and preserve captures. Compilation, ordinary reconstructed execution, emitted-source validation, and generated-plan decoding reject malformed action slots with regex_slot_identity_invalid/validate_compiled_rule. Rust descriptors and emitted source publish linkedspec-duplicate-regex-slot-identity-v1; generated v2 plans remain exactly {label,family}. The contract-declared 15-role consumer passes all five fixtures plus loaded/reconstructed, descriptor, emitted/generated, native/generated trace, primary, and diagnostic routes."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test duplicate_regex_slot_identity_contract && bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
---

Rust keeps two matching mechanisms because ordered execution and choice answer
different questions. `CompiledAlternation` retains each individually compiled
regex for a known sequence step and the combined alternation for genuine
choice. A required AND step therefore matches one slot and returns that exact
authored parent index; structural action-edge metadata maps it to the target
rule and target regex index. Repeated AND restarts the required sequence on each
accepted iteration.

Ordinary and generated-plan execution use the same invariant and trace shape.
`regex_slot_selected` reports `rule_label`, `selection_role`, `target_rule`, and
`regex_index`. The generated artifact embeds serialized `CompiledSpec` state and
publishes `LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT`; its public v2 plan remains
minimal `{label, family}` data.

Malformed serialized state cannot degrade into an ordinary miss. The compiler,
runtime entrypoints, source emitter, and generated decoder all call the shared
compiled-slot validator. Native structured failures and generated-source typed
failures retain the portable target rule/index fields.

Related: [[duplicate-regex-slot-identity-contract]],
[[duplicate-regex-slot-identity-cross-backend-audit]],
[[perl-duplicate-regex-slot-identity-admission]],
[[dart-duplicate-regex-slot-identity-admission]], and
[[FUTURE-PARITY-BACKLOG]].

## September 7 wrapper reading and context qualification

`SESSION-STARTUP-READING.3.3.23` reads all 850 helpers.rs lines. Each pattern is normalized and
compiled separately, retaining capture offsets/names and the required-slot regex; the combined matcher
wraps each authored pattern in a noncapturing group. Required-slot matching reports the supplied slot
index, while choice reads the regex branch number. The duplicate test explicitly checks slot 1 at
byte 1 and preserves whole text, numbered and named captures. Current neutral proof passes five
fixtures/two diagnostics/59 mutations, without a fresh native run.

This identity guarantee is separate from preceding-input context. Both combined matching methods
and the shared required-slot implementation slice `input[pos..]` before invoking the regex provider.
Six ordinary choice probes expose five anchor/lookbehind/word-boundary discrepancies after consuming
a prefix; [[rust-regex-input-context-drift]] records them. Repair `SESSION-STARTUP-READING.63.2`
owns fresh consume/required-slot proof and correction; those routes are structurally implicated but
were not behaviorally exercised by the current six controls.
