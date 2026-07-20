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
date: 2026-07-20
status: accepted neutral contract; backend rollout pending
tags: [regex, slot-identity, and, or, repetition, descriptor, generated-source, diagnostics, parity, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0047 and linkedspec-duplicate-regex-slot-identity-v1 adopt duplicate pattern legality and typed {target_rule,regex_index} identity. Ordered execution matches its already-required slot; repeated sequences reset that requirement each iteration. Choice evaluates eligible slots and resolves equal starts by lowest authored order. Numeric compatibility and future ADR 0045 names resolve to the same typed identity; regex text, adjacency, captures, and alternation guesses are forbidden recovery mechanisms. Descriptors retain distinct edge rows; generated-source v2 stays format 2 because compiled payload identity already survives. The neutral checker independently evaluates five exact fixtures and freezes diagnostics, trace, six-runtime inventory, migration, rollout, and canonical registration without changing backend behavior."
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
and `regex_index`. Generated source remains v2/format 2: its compiled payload
already retains those rows, and only execution had aliased them.

Related: [[duplicate-regex-slot-identity-cross-backend-audit]],
[[rule-local-cursor-and-bare-edge-contract]],
[[inter-match-gap-and-named-slot-contract]], and
[[FUTURE-PARITY-BACKLOG]].
