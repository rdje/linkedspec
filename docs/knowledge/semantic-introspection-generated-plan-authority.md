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
status: current corrected neutral authority boundary
tags: [semantic-introspection, generated-source, handler-family, oracle, mutations, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.3.3.0 compared exact LinkedSpec::Get(return_descriptor) selected_handler_variant and independently loaded emit_generated_source metadata with linkedspec-rule-local-cursor-v1 generated_source_v2 before adapter implementation. The calls fixture selects _default and emits default; and_acode is absent from the ten-family v2 vocabulary. The neutral model was corrected to default and the checker now rejects illegal or coordinated wrong-family drift."
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

This correction changes no compiler, runtime, generated source, query response, rollout, or backend admission.
It fixes the oracle before the Perl calls/staging projector consumes it.

Related facts: [[semantic-introspection-neutral-contract]], [[semantic-introspection-static-rule-authority]],
[[perl-semantic-introspection-authority-map]], [[perl-generated-source-contract-v2]].
