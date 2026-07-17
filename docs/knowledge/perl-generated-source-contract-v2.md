---
id: perl-generated-source-contract-v2
title: Perl generated-source v2 derives cursor policy from its ten-family plan and rejects v1 reconstruction
answers:
  - "how do I emit standalone Perl source from LinkedSpec now"
  - "what generated source version does Perl emit"
  - "how does Perl generated source derive cursor policy"
  - "which generated families seek and which consume"
  - "why must a Perl generated-source v1 artifact be regenerated"
  - "what is generated_source_contract_version_mismatch"
  - "does parse_mode change Perl generated source bytes"
  - "what functions does generated Perl source expose"
date: 2026-07-17
status: current
supersedes: perl-generated-source-contract-v1
tags: [perl, generated-source, cursor, public-api, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.3.4 advances Compiler/GeneratedSource emission to linkedspec-generated-source-v2 format 2, removes SpecEntry's second legacy caller-mode handler, keeps exact label/family plan rows, derives five seek plus five consume policies, and rejects explicit or legacy-caller v1 reconstruction with validate_generated_plan/generated_source_contract_version_mismatch plus expected_contract/actual_contract and .spec regeneration. t/generated_source_contract.t proves option-independent deterministic bytes, fresh load, direct/traced execution, identity, plan drift, and both version-boundary paths."
reverify: "PERL5LIB= prove -Iperl t/generated_source_contract.t t/rule_local_cursor_perl_execution.t t/rule_local_cursor_perl_descriptor.t; python3 tools/check_rule_local_cursor_contract.py; perl -Iperl -c perl/LinkedSpec/GeneratedSource.pm; perl -Iperl -c perl/LinkedSpec/Compiler.pm; perl -Iperl -c perl/LinkedSpec/SpecEntry.pm"
---

# Perl Generated-Source v2

`LinkedSpec::emit_generated_source(...)` emits deterministic, independently
loadable Perl source with contract `linkedspec-generated-source-v2` and format
version 2. The older generate/dump/capture seam remains byte-identical for the
same specification, identity, and options.

The ordered plan remains deliberately minimal: each row contains only `label`
and `family`. Cursor policy is derived, never serialized independently:

- seek: `default`, `or_acode`, `or_bcode`, `rep_acode`, `rep_bcode`;
- consume: `and_single_acode`, `and_acode_seq`, `and_bcode`,
  `rep_and_acode`, `rep_and_bcode`.

The transitional Perl `parse_mode` option is still accepted until
`.9.1.3.5`, but it cannot change new source bytes or generated behavior.
Loaded v2 packages expose `Execute`, `ExecuteWithTrace`, metadata/plan readers,
and `ValidateGeneratedPlan`. Plan row/label/family checks remain unchanged.

A v1 contract presented to the v2 validator fails before row validation with
`generated_source_contract_version_mismatch` at `validate_generated_plan`.
The error includes `expected_contract=linkedspec-generated-source-v2` and
`actual_contract=linkedspec-generated-source-v1`; the supported policy is to
regenerate from the original `.spec` source. Caller-package inference makes
that rejection work for old self-contained v1 wrappers that cannot pass the
new explicit contract argument.

The shared five-backend [[generated-source-contract-v1]] remains the
convergence baseline for Rust, Dart, Julia, and Lua until their dependency-
ordered rule-local cursor migrations.

Related facts: [[perl-rule-local-cursor-rollout-boundaries]],
[[rule-local-cursor-neutral-contract]], and
[[perl-generated-source-contract-v1]].
