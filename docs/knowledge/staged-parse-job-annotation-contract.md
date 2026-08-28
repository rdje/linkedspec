---
id: staged-parse-job-annotation-contract
title: Staged parse jobs are marked by neutral annotations with source-aware sidecar metadata
answers:
  - "how does a rule mark extracted text as a parse job"
  - "what metadata does a staged parse job need"
  - "what is parse_job"
  - "how are staged parse results inserted back into the AST"
  - "what are parse job failure policies"
  - "how should parse job source spans work"
  - "is parse_job implemented"
  - "are parse job annotations language neutral"
  - "what dispatch registry consumes parse jobs"
date: 2026-07-02
status: exact assignment-form public authoring and executable neutral v2 are current on all six runtime routes
tags: [architecture, staged-parsing, parse-jobs, ast, diagnostics, language-neutral]
evidence: "ADR 0014 accepts parse_job(text_expr, hash(...)) as a marker plus sidecar. FUTURE-PARITY-BACKLOG.14.7.2 and ADR 0088 make its v2 neutral target executable at capability_conformance/staged_ast_enrichment_contract.json: STAGED_PARSE_JOB_MARKER plus staged_parse_job_v2, typed direct/ordered-derived provenance, deterministic ids, replace_marker/replace_field/sibling_field/append_child, fail/keep_text/diagnostic_node, explicit v1 compatibility, five pending backend consumers/six routes, and no public admission. Current shipped parsers still do not accept general parse_job(...)."
evidence_update_2026_08_28_public_authoring: "FUTURE-PARITY-BACKLOG.14.7.3-.8 admit and recompose all five backend sources/six runtime routes, then .14.7.9 makes only exact scalar assignment-form target = parse_job(source_bound_text, hash(literal options)) public. The dedicated marker and caller-frozen already-compiled registry remain the authority boundary; specs/spec.spec declares the extension, parse_job stays outside the 250-name generic helper inventory, rollout is 9/9 at 123 neutral plus 129 public mutations, and the satisfied future exclusion is removed."
reverify: "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

Staged parse jobs are represented by a neutral marker plus sidecar metadata, not by
host-language callbacks.

The current public authoring shape is one complete scalar assignment:

```text
target = parse_job(entry_text(), hash(
  "node_kind", "function_definition",
  "payload_kind", "function_body",
  "spec", "specs/action-body.spec",
  "top", "action_block",
  "into", "body_ast",
  "on_error", "fail"
))
```

The metadata sidecar records `job_id`, `parent_ast_path`, `node_kind`, `payload_kind`,
`text`, `source_span`, `parser_spec_id`, optional `top_rule`, `result_policy`, and
`failure_policy`.

Result policies are `replace_marker`, `replace_field`, `sibling_field`, and
`append_child`. Failure policies are `fail`, `keep_text`, and `diagnostic_node`.
Diagnostics must report the stage chain, selected parser, original source span, parent
path, payload kind, and policy choices.

ADR `0015` defines the registry and queue that later consumes this metadata. ADR `0088` and the executable neutral
artifact now fix v2 marker/sidecar, provenance, policy, compatibility, and ownership semantics before a backend
implements them.

All five backend sources and six runtime routes accept this exact dedicated assignment form. Residual, nested,
dynamic, callback, path-loading, and provider-query interpretations fail closed; `parse_job` is not an ordinary
generic helper and authored text cannot widen the caller-frozen already-compiled registry snapshot.
