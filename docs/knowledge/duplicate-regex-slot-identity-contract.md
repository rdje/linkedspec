---
id: duplicate-regex-slot-identity-contract
title: "Ordered matching preserves required structural slot identity; choice ties use authored order"
answers:
  - "what is the duplicate regex slot identity contract"
  - "are duplicate regex patterns legal in LinkedSpec"
  - "how does ordered AND select identical regex slots"
  - "how does OR choose between identical regex slots"
  - "does duplicate regex slot identity require generated source v3"
  - "what diagnostics report regex slot identity corruption"
  - "how do numeric and named regex slot selectors relate"
  - "is Perl duplicate regex slot identity implemented"
  - "how does Perl generated source preserve duplicate regex slots"
  - "is Rust duplicate regex slot identity implemented"
  - "how does Rust generated source preserve duplicate regex slots"
  - "is Dart duplicate regex slot identity implemented"
  - "how does Dart generated source preserve duplicate regex slots"
  - "is Julia duplicate regex slot identity implemented"
  - "how does Julia generated source preserve duplicate regex slots"
  - "is Lua duplicate regex slot identity implemented"
  - "is LuaJIT duplicate regex slot identity implemented"
  - "how does generated Lua preserve duplicate regex slots"
date: 2026-07-20
status: accepted contract; all seven rollout legs complete
tags: [regex, slot-identity, and, or, repetition, descriptor, generated-source, diagnostics, perl, rust, dart, julia, lua, luajit, parity, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0047 and linkedspec-duplicate-regex-slot-identity-v1 adopt duplicate pattern legality and typed {target_rule,regex_index} identity. Ordered execution matches its already-required slot; repeated sequences reset that requirement each iteration. Choice evaluates eligible slots and resolves equal starts by lowest authored order. Numeric compatibility and Perl-staged ADR 0045 names resolve to the same typed identity; regex text, adjacency, captures, and alternation guesses are forbidden recovery mechanisms. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT match the required compiled/authored slot directly, assert its returned identity, publish descriptor/generated-source metadata and exact slot trace, and preserve generated-source v2 without widening its {label,family} plan. Perl embeds dependency_slot_map; Rust embeds serialized CompiledSpec; Dart, Julia, and Lua embed normalized SpecFile JSON and reconstruct compiled identity. Their composed consumers cover 12/15/15/15/15 roles, with the Lua consumer running unchanged on both ABIs. All seven rollout legs complete at 7 complete / 0 pending with 59 rejected mutations; tools/check_duplicate_regex_slot_identity_five_backend.sh composes the six runtime legs, selected primary case, and support ledgers."
reverify: "bash tools/check_duplicate_regex_slot_identity_five_backend.sh"
---

Duplicate regex text never makes two authored action slots the same slot. Current
numeric selectors identify `{target_rule, regex_index}`. Perl-staged named selectors
from ADR `0045` resolve to the same structural identity and add a stable
`target_slot_id`; they do not recover identity from pattern text.

Ordered and choice execution answer different questions:

- an ordered AND step already knows which slot is required, so it matches only
  that slot and reports that identity;
- an OR/default choice considers all eligible slots, prefers the earliest start,
  and breaks equal-start ties by lowest authored order.

Repeated AND starts the required sequence again for every accepted iteration.
Duplicate text does not alter lifecycle, cursor, or progress behavior.

Descriptor metadata adopts
`linkedspec-duplicate-regex-slot-identity-v1`, while action edges retain target
and `regex_index`. Generated source remains v2/format 2. Perl embeds the
compiled `dependency_slot_map`; Rust embeds serialized `CompiledSpec`; Dart,
Julia, and Lua embed normalized `SpecFile` JSON and recompile it through the ordinary
validator. All publish an emitted contract constant and keep the unchanged
`{label, family}` plan. All six runtime legs are admitted, and all seven rollout
legs complete through `tools/check_duplicate_regex_slot_identity_five_backend.sh`.

Related: [[duplicate-regex-slot-identity-cross-backend-audit]],
[[rule-local-cursor-and-bare-edge-contract]],
[[rust-duplicate-regex-slot-identity-admission]],
[[dart-duplicate-regex-slot-identity-admission]],
[[julia-duplicate-regex-slot-identity-admission]],
[[lua-duplicate-regex-slot-identity-admission]],
[[duplicate-regex-slot-identity-five-backend-admission]],
[[inter-match-gap-and-named-slot-contract]], and
[[FUTURE-PARITY-BACKLOG]].
