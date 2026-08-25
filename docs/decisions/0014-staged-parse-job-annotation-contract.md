# 0014 — Staged parse jobs use neutral annotations and source-aware metadata

- Date: 2026-07-02
- Status: accepted
- Tags: architecture, staged-parsing, parser-composition, ast, diagnostics, language-neutral

## Context

ADR `0012` adopts staged linked parsing, and ADR `0013` separates grammar
composition from runtime payload parsing. The next design boundary is how a `.spec`
author marks extracted text as a parse job without relying on Perl hashes, Rust structs,
or host-language callbacks.

The annotation must be precise enough for a scheduler to run later parser stages,
diagnose failures against original source spans, and stitch the result back into the
parent AST. It must also stay neutral enough for Perl5, Raku, Rust, Julia, Lua, Dart,
Zig, Go, or future backends to implement the same behavior.

## Decision

Adopt this design contract before implementation:

1. The future portable authoring surface is a value helper:

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

2. `parse_job(...)` produces a marker value in the stage-N AST plus a neutral metadata
   sidecar entry. The marker is not host-language code and is not immediately executed by
   the action helper itself.
3. Required metadata fields are:
   - `job_id`: deterministic id derived from parent AST path, payload kind, parser spec
     id, top rule, and source span.
   - `parent_ast_path`: path to the AST node or field that owns the marker.
   - `node_kind`: semantic kind of the parent AST node.
   - `payload_kind`: semantic kind of the text payload.
   - `text`: exact source text to refine.
   - `source_span`: original source identity plus byte and line/column span.
   - `parser_spec_id`: spec identity to run next.
   - `top_rule`: optional top rule; omitted means the next spec's default top rule.
   - `result_policy`: how the later AST result is stitched back.
   - `failure_policy`: how stage-N+1 diagnostics affect the parent AST.
4. Source provenance is mandatory. If `text_expr` comes from `entry_text()`,
   `entry_group(N)`, `match_text()`, or `match_group(N)`, the backend must carry the
   corresponding span. If `text_expr` is constructed from several pieces, the job carries
   a provenance list plus a derived-text span policy; it cannot silently lose source
   attribution.
5. Result policies are:
   - `replace_marker`: replace the marker value with the later parser's return value.
   - `replace_field`: replace the named parent field in `into`.
   - `sibling_field`: keep the original text field and write the AST result into `into`.
   - `append_child`: append the AST result to the parent node's child collection named
     by `into`.
6. Failure policies are:
   - `fail`: fail the composed parse and report the staged diagnostic. This is the
     default.
   - `keep_text`: preserve the original text/marker and attach diagnostic metadata.
   - `diagnostic_node`: replace the marker or target field with a structured diagnostic
     AST node.
7. Diagnostics must name the stage chain, `job_id`, parent AST path, node kind,
   payload kind, parser spec id, top rule, source span, result policy, and failure
   policy.
8. Parse-job metadata is a sidecar contract, not user payload. A user AST field may hold
   a marker value, but backend-internal scheduling state must not collide with user data
   keys.
9. Current shipped parsers do not yet accept or execute `parse_job(...)`. This ADR
   reserves the neutral annotation and metadata contract for the implementation leaves.

## Consequences

- `specs/spec.spec` must eventually recognize parse-job helper/annotation syntax as part
  of the portable `.spec` language if it becomes public authoring surface.
- The parser registry/dispatch leaf can consume a concrete job schema instead of
  inventing one.
- Backend handoff documentation must describe parse-job annotations as metadata and
  not as host-language callbacks.
- Future implementation must add source-span plumbing for group/text helper results
  before parse jobs can be signoff-level.

## Current implementation note (2026-08-25)

Clause 9 remains true for the general authored `parse_job(...)` helper. The shipped
function-definition grammar does, however, return one narrow neutral `body_parse_job`
sidecar that all five backend sources/six runtimes execute. That v1 record carries copied
exact body text plus legacy offset/line span and is restricted to
`actionir-body.spec` / `action_block` / `replace_field` / `body_ast` / `fail`.

ADR `0056` subsequently requires direct source spans to carry source identity and
Unicode-scalar coordinates, and derived text to carry ordered provenance. General
implementation under `FUTURE-PARITY-BACKLOG.14.7` must ratify the compatibility/version
boundary between that typed authority and the existing v1 function sidecar before public
authoring. Merely transporting another policy string in a raw registry record does not
count as implementing its stitch or failure semantics.

## Links

- Task tree: `docs/tasks/STAGED-LINKED-PARSING.md`
- Related: ADR `0015` staged parser registry/dispatch contract, ADR `0012`
  staged linked parsing architecture, ADR `0013` spec import/composition contract,
  ADR `0011` text-to-AST backend doctrine
