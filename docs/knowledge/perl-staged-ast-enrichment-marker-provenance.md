---
id: perl-staged-ast-enrichment-marker-provenance
title: Perl has a private opaque staged-parse declaration carrier with typed provenance
answers:
  - "how does Perl lower general parse_job annotations"
  - "where is STAGED_PARSE_JOB_MARKER implemented in Perl"
  - "what does staged_parse_job_v2 contain in Perl"
  - "how does Perl preserve parse_job source provenance"
  - "does the Perl staged marker retain match or source authority"
  - "which parse_job options must be literal in Perl"
  - "how are derived parse_job text segments ordered in Perl"
  - "does Perl parse_job resolve or execute a parser yet"
  - "why does public parse_job stay outside the generic helper inventory"
  - "what is FUTURE-PARITY-BACKLOG 14.7.3.1"
date: 2026-08-26
status: current private carrier; exact assignment authoring is public through FUTURE-PARITY-BACKLOG.14.7.9
tags: [perl, staged-parsing, parse-job, ActionIR, source-provenance, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.1 adds ActionIR::StagedParseJob, StagedParseJob, and StagedParseJobPolicy; privately retains regex match/capture offsets in LinkedRE; composes one exclusive STAGED_PARSE_JOB_MARKER into Contracts/ScannerCore; validates before execution; and classifies its recognition effect as parser_registry_or_staged_dispatch. The dormant consumer passes 120 assertions over exact lowering, opaque/detached sidecars, Unicode-scalar direct and ordered-derived spans, all eight neutral provenance cases, malformed/dynamic/smuggled rejection, unchanged function-body v1, and transaction denial, then fails only on missing pre-registered resolution/cache/result/failure authority. The neutral checker, language 250/126, rollout, discovery, carriers, formats, and outward guards remain unchanged."
evidence_update_2026_08_26_current_depth: "FUTURE-PARITY-BACKLOG.14.7.3.2 consumes this unchanged inert carrier only after the complete AST returns. Private caller-prepared resolution/cache plus current-depth execution and all result/failure policies are now present; the same consumer advances to 133 GREEN top-level checks and one recursion/bounds/rebased-diagnostics RED. Declaration bytes, provenance rules, v1, discovery, carriers, rollout, generated format, and public/outward boundaries remain unchanged."
evidence_update_2026_08_26_recursive: "FUTURE-PARITY-BACKLOG.14.7.3.3 schedules newly returned copies of this unchanged opaque marker only at the next breadth-first depth. The same typed provenance becomes full active-chain and original-source rebasing authority; the carrier itself still owns no parser, callback, source authority, queue, resource state, or admission."
evidence_update_2026_08_26_admission: "FUTURE-PARITY-BACKLOG.14.7.3.4 preserves this logical-only marker across native, normalized-descriptor, generated-plan, and independently loaded emitted routes. Fresh host-only authority arrives per top-level execution; the exact 143-check consumer is admitted while public authoring remains pending."
evidence_update_2026_09_06_reading: "SESSION-STARTUP-READING.3.2.32 re-reads pipeline/recognition scanners, ScannerCore, staged marker lowering, and StatementSplit with exact baseline identity. The managed staged Perl consumer passes 143 checks; staged governance passes 9/9/123 plus public 6/17/10/129, recognition governance passes 138/250/58 with 9/9 rollout, and language coverage passes 250 names/126 public Perl contracts. This is bounded Perl/neutral proof; other runtime execution routes are not rerun."
last_verified: 2026-09-06
reverify:
  - "perl -Iperl -c perl/LinkedSpec/ActionIR/StagedParseJob.pm && perl -Iperl -c perl/LinkedSpec/StagedParseJob.pm && perl -Iperl -c perl/LinkedSpec/StagedParseJobPolicy.pm"
  - "PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py && perl tools/check_language_capability_coverage.pl"
---

# Perl staged-parse marker and provenance

Perl recognizes only the exact assignment annotation
`target = parse_job(text_expr, hash(literal options...))`. The contract is exclusive: a valid annotation becomes
one `STAGED_PARSE_JOB_MARKER`, not a generic `ASSIGN` plus helper call. Non-assignment calls remain unresolved and
cannot acquire the dedicated node.

The lowered runtime constructs an opaque marker whose private side table owns a detached
`staged_parse_job_v2` declaration record. Its data is limited to normalized node/payload/parser/top/result/failure/
capability options, exact materialized text, typed provenance, origin, and declaration state. It contains no source
authority, regex match, parser, registry, callback, path, queue, cancellation, deadline, or host handle. Returned
records are detached snapshots and cannot mutate marker state.

Text must be a direct `entry_text`, `entry_group(N)`, `match_text`, or `match_group(N)` plan, or a nonempty `cat(...)`
composition of those direct plans. Private match-info capture offsets are converted immediately through
`LinkedSpec::SourceLocation` into half-open Unicode-scalar direct spans or ordered direct segments under
`concatenate_in_order`. Literal copied text, transformations, dynamic capture indices, copied-text fields inside
provenance, reversed/out-of-range spans, and empty derived provenance fail closed.

This carrier itself still declares intent only. Private `LinkedSpec::StagedASTEnrichment` now consumes it after a
complete AST through caller-prepared resolution/cache, breadth-first complete depths, and all stitch/failure policies. The carrier still owns no parser or authority. Exact assignment-form authoring became public under
`.14.7.9`, while `parse_job` remains outside the generic helper-call inventory; its private runtime carrier
and host authority are not exported. The admitted runtime supplies fresh host authority after complete
parent execution. See [[portable-parse-job-public-authoring]] and
[[perl-staged-ast-enrichment-carriers-admission]].

Related: [[perl-staged-ast-enrichment-dormant-red]], [[perl-staged-ast-enrichment-current-depth-authority]], [[perl-staged-ast-enrichment-recursive-authority]],
[[general-staged-ast-enrichment-neutral-contract]],
[[typed-source-location-cursor-algebra-direction]], and ADR `0088`.
