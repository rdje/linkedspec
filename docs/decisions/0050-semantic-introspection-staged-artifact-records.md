# 0050 - Semantic introspection names staged payloads, jobs, and results explicitly

- Date: 2026-07-20
- Status: accepted correction; neutral contract executable; backend rollout pending
- Tags: architecture, introspection, semantic-api, staged-parsing, provenance, schema, portability, parity

## Context

ADR `0049` requires semantic queries over staged payload/job/result provenance and includes a `staged_by` relation,
but its exact v1 record vocabulary names only source, compiled semantic entities, and generated artifacts. While
building the executable neutral model in `FUTURE-PARITY-BACKLOG.10.2`, the first staged function-body fixture had
no honest record on which to place `parser_spec_id`, `top_rule`, result/failure policy, parent path, or job status.

Treating a parse job as a `generated_artifact` would be false: a staged payload/job/result is neutral compiler and
scheduler metadata, while a generated artifact is an emitted/reconstructed backend product. Leaving the data only
on an untyped relation would also violate ADR `0049`'s exact fact-vocabulary and explainability goals. This defect
was found before the model/query ids had an executable contract or implementation.

## Decision

Amend ADR `0049` before implementation without changing its model/query ids:

1. Add `staged_artifact` to the record-kind order between `call` and `generated_artifact`.
2. Add the id family `staged:<artifact-kind>:<owner-id>:<zero-based-owner-order>`.
3. A staged-artifact record has exactly these fact keys, all present with null where inapplicable:
   `artifact_kind`, `payload_kind`, `node_kind`, `parent_path`, `parser_spec_id`, `top_rule`, `result_policy`,
   `failure_policy`, `status`, and `value_shape`.
4. `artifact_kind` is exactly `payload`, `parse_job`, or `result`. `status` is exactly `pending`, `succeeded`,
   `failed`, or `not_run`.
5. Add `consumes` and `produces` to the relation-kind order immediately after `writes`.
6. Add `staged_artifact` to the target-shape kind order immediately before `generated_artifact`.
7. The normalized staged chain is:
   - its owner `contains` the payload, parse job, and result records;
   - the payload is `lowered_from` its exact source record/span;
   - the parse job `consumes` the payload and `produces` the result;
   - the result is `staged_by` the parse job and `lowered_from` the payload; and
   - any emitted/reconstructed artifact remains a separate `generated_artifact` reached through `generated_as`.
8. Source policies apply independently to staged records. Identity and policy fields remain semantic; exact text,
   excerpts, paths, and digests follow ADR `0049`'s ceiling/redaction rules.
9. A failed or not-run job remains queryable and may relate to a portable diagnostic; no dummy result value or
   generated artifact is invented.

The executable contract must reject omission of any staged role, collapsing payload/job/result into one record,
using `generated_artifact` for a parse job, reversing consumes/produces direction, losing source provenance, or
diverging across backends.

This is the only pre-contract correction admitted in `.10.2`. Once the executable v1 contract lands, adding or
changing a required kind, fact, or relation follows ADR `0049`'s new-version rule.

## Consequences

- The already-shipped function-body payload/job/AST chain has a direct neutral representation.
- Future general staged parsing can add instances without changing the semantic schema or exposing scheduler
  objects.
- Generated-source relationships remain truthful and separate from staged parsing.
- Explain queries can point to the exact payload, job, result, policy, source evidence, and diagnostic.
- This correction changes no parser, compiler, scheduler, runtime, descriptor, generated artifact, CLI, trace, or
  MCP behavior.

Perl implementation note (2026-07-21): `.10.3.3.1.1` is the first native private projection of this decision.
The exact calls model retains three separate function-body records and the required directed chain while the
handler plan remains a distinct `generated_artifact`. Public query and backend admission remain pending.

## Links

- Amends: ADR `0049`
- Staged architecture: ADRs `0012`, `0014`, `0015`, `0016`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.2`)
- Current staged function descriptor contract: `capability_conformance/outward_descriptor_contract.json`
- Executable semantic contract: `capability_conformance/semantic_introspection_contract.json`
- Exact neutral model/checker: `capability_conformance/semantic_introspection_model.json`,
  `tools/check_semantic_introspection_contract.py`
