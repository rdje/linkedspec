---
id: rule-local-cursor-and-bare-edge-contract
title: "Rule family derives cursor policy and mode-sensitive bare edge ownership"
answers:
  - "what did ADR 0044 decide"
  - "what does a bare Child line mean in an AND rule"
  - "what does a bare Child line mean in an OR rule"
  - "is explicit action edge legal in an AND rule"
  - "is explicit blind call legal in an OR rule"
  - "what replaces the public parse_mode option"
  - "what descriptor field reports cursor policy"
  - "how does generated source derive cursor policy"
  - "how do I express AND seek or OR consume without parse_mode"
date: 2026-07-17
status: accepted; neutral contract complete, backend implementation pending
tags: [dsl, grammar, cursor, parse-mode, and-rule, or-rule, edges, descriptor, generated-source, parity]
evidence: "ADR 0044 and FUTURE-PARITY-BACKLOG.9.1.1.1 ratify intrinsic AND=consume and OR/default=seek, mode-sensitive bare edge normalization, explicit cross-family edges, removal diagnostics, per-rule descriptor facts, generated-source v2 family derivation, and dependency-ordered rollout. FUTURE-PARITY-BACKLOG.9.1.2 makes that target executable over 36 family spellings, 18 edge cases, eight parent/child cases, 91 migration files, and 27 mutations at 1 complete / 7 pending without changing backend behavior."
reverify: "python3 tools/check_rule_local_cursor_contract.py; rg -n '0044|linkedspec-rule-local-cursor-v1|parse_mode_override_removed|bare_edge_group_requires_action|linkedspec-generated-source-v2' docs/decisions/0044-rule-local-cursor-and-mode-sensitive-bare-edges.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src"
---

ADR `0044` fixes the future contract before implementation:

- AND-family rules (`&`, `AND`, `AND+`, `AND{...}`) intrinsically consume.
- OR/default-family rules (bare/default, `|`, `+`, `*`, `?`, `OR`, `OR+`,
  `OR{...}`) intrinsically seek.
- Parent mode never propagates to a child. Edge kind does not change either
  rule's cursor policy.
- A complete bare `Child`, `Child { ... }`, or `Child.method(...)` paragraph
  member resolves to `=>` in an AND-family rule and `->` in an OR/default rule.
- Lifecycle markers remain reserved and win lexical recognition. Other bare
  targets must name a declared rule.
- Explicit `->` remains legal in AND rules and explicit `=>` remains legal in
  OR/default rules. After bare normalization, one rule still cannot mix action
  and blind ownership.
- Indexed bare syntax in AND is invalid because blind calls cannot index.
  Grouped bare syntax is valid only in OR/default rules and retains the
  mandatory shared action block.
- Ordered landmarks are expressed as AND over seek-owning OR/default children.
  Anchored choice is expressed as OR over consume-owning one-anchor AND
  children.

The public/global `parse_mode` option is removed during rollout rather than
ignored. Dynamic option boundaries use `parse_mode_override_removed`; primary
commands remove the help entry and return usage exit 2 for `--parse-mode`.
Descriptors remove root `meta.parse_mode`, add
`meta.cursor_contract = "linkedspec-rule-local-cursor-v1"`, and expose each
rule's derived `meta.cursor_policy`.

Generated source moves to `linkedspec-generated-source-v2`. Its plan remains
`{label, family}` and derives cursor policy from the ten admitted handler
families, so no second mutable policy field can drift. Version-1 artifacts must
be regenerated for v2 admission.

Neutral contract/inventory `.9.1.2` is executable at 1 complete / 7 pending;
backend and public rollout remains `.9.1.3-.9`. Current parser/runtime/API/CLI
behavior remains unchanged until those leaves land.

Related: [[and-or-cursor-ownership-audit]],
[[rule-local-cursor-ownership-decision]], [[spec-edge-syntax-contract]], and
[[rule-local-cursor-neutral-contract]], [[FUTURE-PARITY-BACKLOG]].
