---
id: semantic-introspection-staged-artifact-schema
title: Semantic introspection represents staged payloads, parse jobs, and results as explicit neutral records
answers:
  - how does the semantic introspection model represent staged parse jobs
  - is a staged parse job a generated artifact in semantic introspection
  - what facts are on a semantic staged artifact record
  - how are staged payload job and result records related
  - why did ADR 0050 amend semantic model v1
  - what schema defect was found in FUTURE-PARITY-BACKLOG.10.2
date: 2026-07-20
status: current schema; private-projection narrative below is a dated milestone, with public rollout now complete at 9/9
tags: [introspection, semantic-api, staged-parsing, provenance, schema, FUTURE-PARITY-BACKLOG]
evidence: "The first executable staged function-body model under FUTURE-PARITY-BACKLOG.10.2 could not place parser spec, top rule, stitch/failure policy, parent path, or status on ADR 0049's record vocabulary without falsely calling the parse job a generated artifact. ADR 0050 added explicit staged_artifact payload/parse_job/result records and consumes/produces/staged_by/lowered_from relations before v1 implementation; the completed neutral model and checker enforce all three roles and reject their collapse, reversal, or misclassification. Perl .10.3.3.1.1, Rust .10.4.3, Dart .10.5.3.2, and Julia .10.6.4.2 each privately deep-equal the complete 22-record/25-relation calls target."
evidence_update_2026_09_13_reading: "CONFORMANCE-SOURCE-READING.1.11 reads the complete semantic contract and model lines 1-201. The original private-projection evidence remains historical; the current contract records 9/9 rollout and 6/6 admissions, governed by semantic-introspection-public-no-drift. No fresh native execution or changed schema is claimed."
reverify: "rg -n 'staged_artifact|consumes|produces|generated_artifact' docs/decisions/0050-semantic-introspection-staged-artifact-records.md capability_conformance/semantic_introspection_contract.json tools/check_semantic_introspection_contract.py"
---

# Semantic Introspection Staged-Artifact Schema

`linkedspec-semantic-model-v1` represents staged parsing through three explicit `staged_artifact` records:
`payload`, `parse_job`, and `result`. Their fixed facts include payload/node kind, parent path, parser spec and top
rule, result/failure policies, status, and value shape. The owner contains all three; the job consumes the payload
and produces the result; the result is staged by the job and lowered from the payload; the payload retains its
source provenance.

A staged parse job is not a `generated_artifact`. Generated artifacts are emitted/reconstructed backend products
and remain separate targets of `generated_as`. This distinction was made explicit by ADR `0050` after the first
executable schema model showed that ADR `0049` required staged provenance but had omitted a record to carry it.

**Historical implementation milestones (July 20):**

Perl leaf `.10.3.3.1.1` is the first native private projection of this chain. Rust `.10.4.3`, Dart `.10.5.3.2`,
and Julia `.10.6.4.2` now project the same schema from their typed staged authorities. Each compiled function produces separate payload,
parse-job, and result records with exact directed relations and plain-data policies; the generated handler plan
remains a separate record. Each backend's 22-record/25-relation equality proof rejects collapsing or reversing
those roles. Perl and Rust expose exact immutable queries and are admitted; Dart's projection remains private until
its later query/runtime/admission leaves. Julia likewise keeps the projection private while validating native
payload/job/body-result correlation before neutralization.

Current rollout is complete at 9/9 with 6/6 runtime admissions, as recorded in
[[semantic-introspection-public-no-drift]] and [[semantic-introspection-neutral-contract]].
The private/admission sequencing above preserves the implementation history.

Related facts: [[semantic-introspection-api-mcp-direction]],
[[outward-descriptor-is-not-semantic-wire-model]], [[staged-parser-registry-dispatch-contract]].
