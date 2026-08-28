---
id: portable-parse-job-public-authoring
title: Portable parse_job authoring is one exact assignment annotation, not a generic helper or loader
answers:
  - "is parse_job public"
  - "how do I author a parse_job in a spec file"
  - "which parse_job text expressions are allowed"
  - "is parse_job a generic helper call"
  - "can parse_job load a parser path"
  - "can parse_job query a provider"
  - "which parse_job options are required"
  - "which parse_job result and failure policies are public"
  - "which task removed future general parse job authoring from the exclusion ledger"
  - "what does FUTURE-PARITY-BACKLOG 14.7.9 complete"
  - "which corpus fixtures mirror specs spec exactly"
  - "why did parse_job comments look like generic calls to language coverage"
date: 2026-08-28
status: current portable authored surface on five backend sources and six runtime routes
tags: [staged-parsing, parse-job, public-authoring, grammar, capability, diagnostics, no-drift]
evidence: "FUTURE-PARITY-BACKLOG.14.7.9 promotes only the already-implemented exact scalar assignment target = parse_job(source_bound_text, hash(literal options)). specs/spec.spec declares the dedicated extension; the four exact canonical spec_spec_* corpus copies mirror that comment-only declaration under the existing Unicode rule-label contract. tools/check_language_capability_coverage.pl keeps parse_job outside the 250-name generic helper inventory and subtracts every explicitly classified non-generic form from its raw-corpus reverse scan, so the canonical comments cannot masquerade as ordinary calls. capability_conformance/staged_ast_enrichment_contract.json is 9/9 at 123 neutral mutations; its checker binds six documents, 17 stale-claim denials, ten outward paths, the complete 37-code diagnostic guide, and 129 reason-checked public mutations. The manifest row is language.staged_ast_enrichment at 85/0/0 and the satisfied future.general_parse_job_authoring exclusion is absent. Typed projection governance is 13/1/189 while combined public no-drift remains owned by .14.8. No parser/compiler/runtime/carrier behavior or unrelated facade/schema/semantic/MCP/CLI/root-README surface changes."
evidence_update_2026_08_28_final_recomposition: "FUTURE-PARITY-BACKLOG.14.7.10 independently reruns all six committed runtime routes and support ledgers, preserving this exact public surface, 129 public mutations, one legacy exclusion, and typed 13/1/189. Parent .14.7 closes without public or executable movement."
last_verified: 2026-08-28
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "perl tools/check_language_capability_coverage.pl"
  - "perl tools/check_capability_conformance.pl"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "rg -n 'DEDICATED ACTION-EXPRESSION EXTENSION|target = parse_job|ordinary generic helper-call inventory' specs/spec.spec"
  - "for case in spec_spec_minimal_rule spec_spec_action_edge spec_spec_user_function_definition spec_spec_comment_skip; do cmp specs/spec.spec rust/linkedspec-runtime/tests/corpus/$case/input.spec; done"
---

# Portable `parse_job(...)` authoring

The public surface is exactly one complete scalar assignment:

```text
target = parse_job(source_bound_text, hash(literal options))
```

`source_bound_text` is `entry_text()`, `entry_group(nonnegative_literal)`, `match_text()`,
`match_group(nonnegative_literal)`, or a nonempty `cat(...)` composed only from those forms. Required options are
`node_kind`, `payload_kind`, `spec`, `result_policy`, and `on_error`; optional options are `top`, `into`, and
`required_capabilities`. Keys and values are statically validated literals.

The four result policies are `replace_marker`, `replace_field`, `sibling_field`, and `append_child`. The three
failure policies are `fail`, `keep_text`, and `diagnostic_node`. The result-policy/`into` pairing is exact:
`replace_marker` forbids `into`; every other result policy requires a valid literal field name.

The annotation lowers to `STAGED_PARSE_JOB_MARKER` plus `staged_parse_job_v2`. It does not become an ordinary
helper call and does not execute immediately. After the complete parent AST returns, the scheduler can select only
from the caller's immutable already-compiled registry snapshot. Authored text, parser identities, provenance, or
markers grant no filesystem, URI, network, environment, import enumeration, provider query, compilation, registry
mutation, callback, or other host authority.

Direct return, nested, receiver, append, indexed, dynamic-index, copied/transformed-text, malformed-option, and
recognition-reachable forms fail closed. Public authoring does not export the internal carrier through a facade,
descriptor/result schema, semantic/MCP field, CLI option, or root README.

The four `rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec` cases governed by the Unicode rule-label
contract are exact canonical copies of `specs/spec.spec`; their comment-only declarations move in lockstep and
change no corpus input behavior.

The language-coverage reverse scan reads raw corpus text. It therefore subtracts the exact classified non-generic
set after finding identifier-shaped tokens: comments that document `parse_job(` cannot make this dedicated
annotation look like a shared generic helper. A separate staged mutation removes that subtraction and must fail.

Related: [[staged-parse-job-annotation-contract]], [[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-enrichment-recomposition]],
[[staged-ast-enrichment-recurring-gate]], [[capability-exclusion-freshness-model]], and ADR `0088`.
