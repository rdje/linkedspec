---
id: general-staged-ast-current-boundary
title: Current staged dispatch is a one-depth function-body path, not the general staged-AST contract
answers:
  - "what staged parsing behavior is implemented today"
  - "is general parse_job authoring implemented"
  - "which staged result policies work today"
  - "which staged failure policies work today"
  - "does the staged registry apply result policies"
  - "does the staged registry recursively enqueue jobs"
  - "does staged dispatch use typed source spans"
  - "which staged diagnostics lose job context"
  - "why does compile phase show unknown staged job fields"
  - "do all backends preserve staged compile diagnostic context"
  - "what did FUTURE-PARITY-BACKLOG.14.7.0 audit"
  - "what must happen before general staged AST enrichment"
date: 2026-08-25
status: current runtime audit; neutral authority complete; Perl private marker/provenance complete at .14.7.3.1; resolution through public implementation remains .14.7.3.2-.10
tags: [staged-parsing, parse-job, diagnostics, registry, policies, recursive-queue, source-location, backend-parity]
evidence: "Toolbox-first source/runtime proof establishes the shipped boundary: five source backends/six runtimes implement only actionir-body.spec/action_block, one-depth ordering, fixed cache identity, and function-specific replace_field/body_ast/fail. FUTURE-PARITY-BACKLOG.14.7.1 repairs wrong-top diagnostic parity. FUTURE-PARITY-BACKLOG.14.7.2 adds the separate executable neutral v2 authority. Perl .14.7.3.1 now adds only a dormant private marker/provenance declaration carrier; it performs no resolution, cache, policy stitch, scheduling, admission, or public authoring. Those remain .14.7.3.2-.10-owned."
root_cause: "The first prototype deliberately separated a generic-looking registry record from a narrow trusted function-body integration. Compile helpers in Perl, Rust, and Dart were shaped around loaded parser identity plus top rule, so they synthesized a placeholder diagnostic record; Julia and Lua were implemented later with the complete job parameter but their formatter omitted payload_kind. Success-path and resolve-phase tests covered real context, but no cross-backend compile-phase assertion locked the ADR 0015 fields. Leaf .14.7.1 passes the normalized job through the three compile boundaries, adds payload_kind to the two later formatters, and locks all five source routes/six runtimes without expanding staged behavior."
last_verified: 2026-08-25
reverify:
  - "rg -n 'execute_parse_jobs|executeParseJobs|compile|_compile|result_policy|failure_policy|unsupported top rule|payload_kind' perl/LinkedSpec/StagedParserRegistry.pm rust/linkedspec-runtime/src/staged_parser_registry.rs dart/lib/src/parser/staged_parser_registry.dart julia/src/parser/StagedParserRegistry.jl lua/src/linkedspec/staged_parser_registry.lua"
  - "rg -n 'body_parse_job.*result_policy|body_parse_job.*failure_policy|result_policy must|failure_policy must' perl rust dart julia lua --glob '!**/generated*'"
  - "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.7"
---

# General staged-AST current boundary

The current product implements one narrow staged family on five backend sources and six runtime routes:

| Boundary | Current behavior |
| --- | --- |
| Payload/job | Spec-returned `body_payload` plus `body_parse_job` for `function_definition` |
| Parser identity | `actionir-body.spec` -> `builtin:actionir-body.spec` only |
| Top rule | `action_block` only |
| Queue | One collected depth, stable parent-path/source-span/job-id order |
| Cache | Fixed adapter digest plus spec/top/version/capability fingerprint |
| Stitch | Function-specific `replace_field` into `body_ast` |
| Failure | Function-specific fail-fast behavior |
| Provenance | Copied exact text plus legacy numeric offset/line span |
| Runtimes | Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT |

The raw registry boundary normalizes and transports `result_policy`, `result_field`, and `failure_policy`; it does
not implement alternate policy behavior. Direct registry execution can therefore return records containing
`replace_marker`, `sibling_field`, `append_child`, `keep_text`, or `diagnostic_node`, but that is metadata transport,
not working stitch/failure semantics. The trusted function-body integration separately rejects anything other than
`replace_field` / `body_ast` / `fail` before it stitches the returned ActionIR body. General policy implementation
must not claim these inert strings as current behavior.

The current registry also does not scan stitched results for new jobs, advance stage depth, resolve several parser
families, enforce active-chain cycle/depth/call/resource bounds, or carry ADR `0056` typed source authority. Those
are the general `.14.7` program, not defects in the deliberately narrow success path.

One defect was independent of that feature boundary. A wrong `top_rule` failed in `compile` on every backend, but
Perl, Rust, and Dart constructed placeholder jobs while Julia and shared Lua omitted `payload_kind` from otherwise
real job context. `.14.7.1` now makes all five source backends/six runtimes report `phase=compile`, original
`job_id`, parent path, parser and resolved identities, rejected top rule, payload kind, source span, and failure
policy. This is diagnostic parity only. `.14.7.2` subsequently completes the separate executable neutral contract;
runtime behavior still begins with the backend-owned `.14.7.3+` leaves. Perl `.14.7.3.0` froze the exact original
missing-marker boundary. Perl `.14.7.3.1` now advances that same dormant test to 120 GREEN assertions and one
missing-authority RED: the private exclusive marker, opaque sidecar, literal-option normalization, typed direct/
ordered-derived provenance, detachment, malformed/smuggling rejection, and transaction closure exist, but no
general parser is resolved, cached, run, or stitched. The consumer remains absent from ordinary and canonical
discovery, so this is not admitted public `parse_job(...)` behavior.

The dependency plan then separates neutral contract, each backend, exact five-source/six-runtime recurrence,
public `parse_job(...)` authoring, and independent recomposition. General staged dispatch reuses the typed source
algebra and authority-narrowing principles already established for progressive dispatch. ADR `0088` now fixes it
as a post-AST breadth-first deterministic queue: it does not reuse progressive `dispatch_span` syntax, expose host
callbacks, or interpret an authored parser id as permission to read a filesystem path.

The audit freezes 37 new stable staged owners, moving the authoritative partition-checker census from 557 to 594.
The existing part remains only 221 lines / 73,822 bytes under unchanged 5,000-line / 786,432-byte member limits;
no capacity or partition architecture changes. A raw grep also sees the root tree record; stable-ID claims must use
`scripts/check_task_tree_partitions.pl`, which deliberately counts the task leaves governed by the partition.

Related: [[function-body-staged-registry-dispatch]], [[staged-parser-registry-dispatch-contract]],
[[staged-parse-job-annotation-contract]], [[general-staged-ast-enrichment-neutral-contract]],
[[progressive-span-dispatch-audit-plan]], and ADRs `0012`, `0014`, `0015`, `0016`, `0056`, and `0088`.
