---
id: terse-string-comparison-bridge-contract
title: "SPEC-FORMAT-TERSE.3.2.3.2 ships the explicit str_* string comparison bridge."
answers:
  - "why do str_eq str_ne str_gt str_ge str_lt str_le receiver chains stay raw DSL"
  - "does Perl str_eq coerce undef to empty text"
  - "what is str_eq"
  - "are str_eq and str_gt implemented"
  - "what is the string comparison bridge contract"
  - "when can bare gt become numeric"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.1"
  - "should docs use str_eq now"
date: 2026-10-26
status: free bridge current; ordinary receiver counterparts frozen, implementation pending
tags: [spec-format-terse, comparisons, string-helpers, helper-aliases, task-tree, mdbook]
evidence: "Historical bridge3.2.3.1/.2 and numeric migration3.2.3.3/.4; new receiver assessment TYPE23.2.11. Full prior implementation/replay/assignment chronology at Gitd9d81fa9a491380ca6d7b2a24cca727c581399ba for this path."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_string_comparison_results.pl"
---

The July bridge ships str_eq/str_ne/str_gt/str_ge/str_lt/str_le as two-argument lexical helpers. Bare eq/ne/gt/ge/lt/le and comparison symbols are numeric aliases, not String compatibility forms. Historical free-only scope and migration chronology remain at the Git pointer above.

TYPE23.2.11 freezes ordinary receiver counterparts under the director's comprehensive fluent directive; implementation23.3.12.1-.5 follows. Public Get/substitution/native/fresh probes confirm six true/six false producers1/0 and stopped raw receiver chains; MethodLowering's String return-family map omits these free-only methods. Nested results work and false0! survives coalesce_nonempty. No source/producer repair inferred: nested blocks retain1!/SOC/final-null and eager null-source SO order.

Perl's existing lexical operators coerce undef to empty text: str_eq(undef,"") and its reverse return1. Preserve actual kinds/scalar/null/Unicode domains; no new portable undefined-domain promise. New ordinary methods take one operand before effects and hand their scalar result to compatible consumers/explicit bridges, with no numeric-alias changes. Contract/probe: string-comparison-results.md/probe_string_comparison_results.pl. Other backends need independent assessment; full domain/context/admission23.4 and Dart Unicode-order2.13 remain separate.
