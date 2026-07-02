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
date: 2026-07-02
status: current
tags: [architecture, staged-parsing, parse-jobs, ast, diagnostics, language-neutral]
evidence: "ADR 0014 accepts the design-only staged parse-job annotation contract. The future portable authoring surface is parse_job(text_expr, hash(...)) producing a marker value plus sidecar metadata. Required fields include job_id, parent_ast_path, node_kind, payload_kind, text, source_span, parser_spec_id, optional top_rule, result_policy, and failure_policy. Result policies are replace_marker, replace_field, sibling_field, and append_child. Failure policies are fail, keep_text, and diagnostic_node. Current shipped parsers do not yet accept or execute parse_job(...)."
reverify: "rg -n 'parse_job\\(|result_policy|failure_policy|replace_marker|sibling_field|diagnostic_node|0014|STAGED-LINKED-PARSING.3' docs/decisions docs/tasks docs/linkedspec-book/src ROADMAP_V2.md"
---

Staged parse jobs are represented by a neutral marker plus sidecar metadata, not by
host-language callbacks.

The accepted future authoring shape is:

```text
parse_job(text_expr, hash(
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

This is an accepted design contract only. Current shipped parsers do not yet accept or
execute `parse_job(...)`.
