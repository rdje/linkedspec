---
id: perl-semantic-introspection-authority-map
title: Perl semantic introspection composes decoded source with several existing authorities
answers:
  - "which Perl authorities build the semantic index"
  - "does LinkedSpec Get accept raw UTF-8 bytes for Unicode rule labels"
  - "why did the semantic privacy fixture fail on raw bytes"
  - "where do Perl semantic source spans come from"
  - "does Perl RuntimeContext capture semantic execution events"
  - "can generated metadata reconstruct a semantic index"
  - "how should the Perl failed-compilation diagnostic be normalized"
  - "what authority may the Perl semantic query evaluator consume"
date: 2026-07-21
status: current
tags: [perl, semantic-introspection, utf8, descriptor, actionir, provenance, diagnostics]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.3.0; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/linkedspec-book/src/public-api/semantic-introspection.md
reverify: rg -n "return_descriptor|runtime_ctx_ref|parse_action_block|LinkedSpecGeneratedMetadata|FB_CROAK" perl/LinkedSpec.pm perl/LinkedSpec
---

Perl's semantic index must compose existing authorities rather than serialize one host object: strict decoded
source plus canonical UTF-8 bytes; the outward descriptor's deterministic graph/function facts; typed ActionIR
for nested call/binding spans; function staged payload/job/result records; runtime-context compile diagnostics;
and generated-v2 plan metadata. The descriptor contains coderefs/compiled regexes, generated metadata is not a
semantic snapshot, and `RuntimeContext`/text trace has no typed invocation-local semantic-event sink.

`LinkedSpec::Get` is character-oriented: passing the privacy fixture's raw UTF-8 bytes makes the Unicode rule
label fail validation, while strict `Encode::decode(..., FB_CROAK)` compiles the exact `Töp` label. Public loaders
already enforce that strict boundary. The native constructor must therefore accept decoded text or strict UTF-8
bytes, retain canonical bytes for spans/digests, reject malformed UTF-8, and use only a caller logical name.
Rule/edge/lifecycle coordinates require a source mapper over accepted text because no descriptor owns them. Static
leaf `.10.3.2.1` now performs that private correlation and normalizes internal `bare_edge_target_undefined` /
`normalize_edges` to the v1 portable compile diagnostic. Call leaf `.10.3.3.1.1` now composes function/helper/call/
binding facts from descriptor plus typed ActionIR, explicit staged payload/job/result provenance from the function
sidecars, and generated-plan identity from shared generated-v2 owners. Descriptor function and ActionIR spans are
character offsets; only `SemanticSourceMap` converts the final references to bytes and scalar columns. Query leaf
`.10.3.4` consumes only the cloned plain projection and exposes exact static capabilities/query without reopening
any authority. Observations and admission remain `.10.3.5-.10.3.6`. See [[perl-semantic-static-projection]],
[[perl-semantic-call-staged-projection]], [[perl-semantic-query-evaluator]],
[[outward-descriptor-is-not-semantic-wire-model]], [[semantic-introspection-neutral-contract]], and
[[perl-generated-source-contract-v2]].
