---
id: rust-rule-local-cursor-execution
title: "Rust live, loaded, and ordinary reconstructed rules derive cursor policy from each entered family"
answers:
  - "does Rust use rule local cursor policy"
  - "where does Rust derive seek versus consume"
  - "does Rust CompiledRule serialize parse mode"
  - "can a Rust parent override a child cursor policy"
  - "does Rust ExecutionOptions parse mode still change live execution"
  - "how does Rust rule local cursor work through recursion"
  - "does loaded Rust execution use rule local cursor policy"
  - "does reconstructed Rust CompiledSpec use rule local cursor policy"
  - "why does Rust still have legacy_artifact_parse_mode"
  - "is Rust descriptor v1 migrated to rule local cursor"
  - "is Rust generated source v1 migrated to rule local cursor"
  - "what tests prove Rust rule local cursor execution"
date: 2026-07-18
status: current normal Rust execution; descriptor/generated/public migrations remain FUTURE-PARITY-BACKLOG.9.1.4.4-.6
tags: [rust, cursor, runtime, serialization, loading, recursion, trace, generated-source, descriptor, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.4.3 removes independent CompiledRule.parse_mode state and derives live policy with CompiledRule::cursor_policy() at every rule entry: exact AND consumes and default/OR seeks. Engine blind orchestration also follows the exact entered family, so parent/global policy cannot propagate through action, blind, call, or recursion. Ordinary CompiledSpec JSON omits the old field and derives after reconstruction; loaded execution uses the same engine. Descriptor v1 and generated-source v1 retain a bounded legacy_artifact_parse_mode adapter and private v1 wire serializer for .4-.5, while the still-present public option/CLI projection is removal debt for .6 and cannot override normal live execution. Contract proof covers 36 family rows, eight parent/child mechanisms, two structural cases, loaded trace, JSON reconstruction, recursion, and staged artifacts."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test rule_local_cursor_execution; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test rule_local_cursor_normalization; cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test rule_local_cursor_normalization_test; python3 tools/check_rule_local_cursor_contract.py"
---

Normal Rust cursor execution has one semantic authority: the family on the rule
currently being entered. `CompiledRule::cursor_policy()` returns `consume` for the
exact AND family and `seek` for every default/OR family. `Engine::execute_rule`
consults that derived value for regex matching and exact `mode.is_and()` for blind
orchestration and implicit sequence results.

This matters at every composition boundary. A parent passes its current cursor to a
child, but does not pass a policy. The child then applies its own family through:

- action-edge entry;
- blind-call entry;
- explicit `call(...)`;
- recursive re-entry;
- file-loaded compiled state; and
- ordinary `CompiledSpec` JSON reconstruction.

The compiled rule no longer stores or normally serializes an independently mutable
cursor field. Old ordinary JSON may still decode because unknown fields are tolerated,
but such a field cannot change the derived policy.

Three staged surfaces remain explicit rather than implicit. Descriptor v1 projects
the old policy until `.9.1.4.4`; generated-plan/source v1 uses the same compatibility
policy until `.9.1.4.5`; and Rust's public option/CLI/request-trace surface remains
present until removal leaf `.9.1.4.6`. `legacy_artifact_parse_mode()` and the private
`GeneratedCompiledRuleV1` serializer exist only for those artifact boundaries. The
still-present option does not override normal live execution.

The contract test consumes all 36 family spellings, all eight neutral parent/child
mechanisms, and both structural replacements. Loaded trace proof shows the AND parent
consume at its entry cursor and the default child seek from the cursor it receives.
The same suite locks live/ordinary-serialized identity, recursive reachability, and
the deliberately unchanged descriptor/generated-v1 projections.

Related: [[rust-rule-local-cursor-normalization]],
[[rule-local-cursor-neutral-contract]], [[rule-local-cursor-and-bare-edge-contract]],
and [[rust-native-direct-value-execution]].
