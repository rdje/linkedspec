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
date: 2026-07-20
status: accepted contract; Perl reference admitted; remaining backend rollout pending
tags: [regex, slot-identity, and, or, repetition, descriptor, generated-source, diagnostics, perl, parity, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0047 and linkedspec-duplicate-regex-slot-identity-v1 adopt duplicate pattern legality and typed {target_rule,regex_index} identity. Ordered execution matches its already-required slot; repeated sequences reset that requirement each iteration. Choice evaluates eligible slots and resolves equal starts by lowest authored order. Numeric compatibility and future ADR 0045 names resolve to the same typed identity; regex text, adjacency, captures, and alternation guesses are forbidden recovery mechanisms. Perl now matches the required compiled slot directly, asserts its returned identity, publishes descriptor metadata and exact slot trace, and embeds dependency_slot_map in generated-source v2 without widening its {label,family} plan. The composed Perl consumer covers 12 live/loaded/descriptor/emitted/generated/trace/repeated/control/cross-target/choice/diagnostic roles. Governance is 2 complete + 5 pending with 26 rejected mutations."
reverify: "python3 tools/check_duplicate_regex_slot_identity_contract.py"
---

Duplicate regex text never makes two authored action slots the same slot. Current
numeric selectors identify `{target_rule, regex_index}`. Future named selectors
from ADR `0045` resolve to the same structural identity and may add a stable
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
compiled `dependency_slot_map` beside the unchanged `{label, family}` plan;
live descriptors retain the same rows in `dependency_refs` plus target regex
arrays. The Perl reference is admitted. Rust repair and the Dart/Julia/Lua
locks remain dependency-ordered rollout work.

Related: [[duplicate-regex-slot-identity-cross-backend-audit]],
[[rule-local-cursor-and-bare-edge-contract]],
[[inter-match-gap-and-named-slot-contract]], and
[[FUTURE-PARITY-BACKLOG]].
