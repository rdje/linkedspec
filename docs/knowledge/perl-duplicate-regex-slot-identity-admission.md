---
id: perl-duplicate-regex-slot-identity-admission
title: "Perl ordered handlers match their required compiled regex slot directly"
answers:
  - "how did Perl fix duplicate regex slot identity"
  - "what is LinkedRE match_slot"
  - "why does generated source contain dependency_slot_map"
  - "how are duplicate regex slot selections traced in Perl"
  - "why did cross-target AND use the default handler"
  - "where are regex slot match captures snapshotted"
date: 2026-07-20
status: confirmed; Perl reference admitted by FUTURE-PARITY-BACKLOG.9.1.8.1.2
tags: [perl, regex, slot-identity, and, repetition, generated-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "LinkedRE::match_slot receives one compiled required row and returns that row's dispatch index, target_rule, and regex_index after matching under the rule cursor policy. HandlerVariantEmitter uses it for AND_SINGLE_ACODE and AND_ACODE sequence steps, asserts identity, and leaves LinkedRE::or choice behavior unchanged. Match text, positional captures, and named captures are snapshotted inside the successful regex branch because Perl match variables are dynamically scoped. SpecEntry builds cross-target AND action sequences from dependency-row count rather than local-regex count. Generated-source v2 embeds dependency_slot_map while plan rows remain exactly {label,family}. Trace serializes regex_slot_selected selection_role/target_rule/regex_index. The 12-role Perl consumer passes all five neutral fixtures plus loaded, descriptor, emitted/generated, trace, and both portable diagnostics."
reverify: "prove -Iperl t/duplicate_regex_slot_identity_perl_contract.t && python3 tools/check_duplicate_regex_slot_identity_contract.py"
---

The implementation keeps ordered execution and choice execution separate.
Ordered AND handlers already know the required structural row and call
`LinkedRE::match_slot` with only that compiled regex. OR/default handlers still
call the combined matcher so earliest-start and first-authored priority remain
unchanged.

Live descriptors resolve required rows through `dependency_refs` and the target
rule's regex array. Standalone generated source cannot carry those hashes inside
its callable `spec` table, so it embeds equivalent rows in
`dependency_slot_map`. That payload is execution state, not a public generated
plan field; v2 plan rows remain `{label, family}`.

Cross-target indexed action edges have zero local regexes on the enclosing rule.
Their compiled dependency rows are nevertheless the AND sequence. Counting
those rows when building handler variants aligns emitted behavior with the
already-selected `AND_ACODE` metadata.

Related: [[duplicate-regex-slot-identity-contract]],
[[duplicate-regex-slot-identity-cross-backend-audit]],
[[rule-local-cursor-and-bare-edge-contract]], and
[[FUTURE-PARITY-BACKLOG]].
