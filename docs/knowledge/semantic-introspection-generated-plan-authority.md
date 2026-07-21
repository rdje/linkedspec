---
id: semantic-introspection-generated-plan-authority
title: Semantic generated-plan facts come from the actual generated-source-v2 family authority
answers:
  - what independently validates semantic introspection generated plan families
  - why did the semantic calls snapshot incorrectly say and_acode
  - what generated plan family does the calls and staging fixture use
  - is and_acode a valid LinkedSpec generated source v2 family
  - can semantic model and response hashes hide generated plan family drift
  - which task corrected the semantic generated plan oracle
date: 2026-07-21
status: current corrected neutral authority boundary; private Perl projector consumes shared owner
tags: [semantic-introspection, generated-source, handler-family, oracle, mutations, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.3.3.0 compared exact LinkedSpec::Get(return_descriptor) selected_handler_variant and independently loaded emit_generated_source metadata with linkedspec-rule-local-cursor-v1 generated_source_v2 before adapter implementation. The calls fixture selects _default and emits default; and_acode is absent from the ten-family v2 vocabulary. FUTURE-PARITY-BACKLOG.10.3.3.1.1 moves handler-variant classification and contract identity behind LinkedSpec::GeneratedSource owners shared by Compiler and the private semantic projector."
reverify: "python3 tools/check_semantic_introspection_contract.py && perl -Iperl -MLinkedSpec -e 'print q{use TOOLBOX emit_generated_source metadata probe for calls_and_staging.spec}'"
---

# Semantic Introspection Generated-Plan Authority

The semantic model describes a generated artifact; it does not get to invent that artifact's family. For
`calls_and_staging.spec`, the exact Perl descriptor selects `_default` for `Top`, and independently loaded
generated-source-v2 metadata reports the plan row family `default`. The admitted rule-local contract identifies
`default` as one of the five seek families in the exact ten-family v2 vocabulary.

The original neutral row said `and_acode`. That spelling is not a v2 family at all (`and_acode_seq` is the valid
sequential-AND family), and the default source header does not select an AND handler. The checker now reads the
external generated-source-v2 authority, requires the exact default entry header and artifact contract/format,
checks membership in the ten-family vocabulary, and rejects both the old illegal value and a coordinated valid-
but-wrong family even if response hashes are refreshed.

The private Perl calls/staging projector now consumes this correction without duplicating the family table:
`LinkedSpec::GeneratedSource` owns both contract identity and handler-variant classification, while `Compiler` and
`SemanticCallProjection` delegate to it. This refactor preserves emitted behavior and keeps implementation source
outside the semantic record. The later Perl query leaf exposes that record through the public immutable evaluator;
runtime observations, rollout, and backend admission remain pending.

Related facts: [[semantic-introspection-neutral-contract]], [[semantic-introspection-static-rule-authority]],
[[perl-semantic-introspection-authority-map]], [[perl-generated-source-contract-v2]].
