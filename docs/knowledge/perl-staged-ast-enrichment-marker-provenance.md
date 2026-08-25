---
id: perl-staged-ast-enrichment-marker-provenance
title: Perl has a dormant opaque staged-parse declaration carrier with typed provenance
answers:
  - "how does Perl lower general parse_job annotations"
  - "where is STAGED_PARSE_JOB_MARKER implemented in Perl"
  - "what does staged_parse_job_v2 contain in Perl"
  - "how does Perl preserve parse_job source provenance"
  - "does the Perl staged marker retain match or source authority"
  - "which parse_job options must be literal in Perl"
  - "how are derived parse_job text segments ordered in Perl"
  - "does Perl parse_job resolve or execute a parser yet"
  - "why is parse_job absent from the public language inventory"
  - "what is FUTURE-PARITY-BACKLOG 14.7.3.1"
date: 2026-08-26
status: current private dormant carrier; resolution/cache/policies pending FUTURE-PARITY-BACKLOG.14.7.3.2
tags: [perl, staged-parsing, parse-job, ActionIR, source-provenance, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.1 adds ActionIR::StagedParseJob, StagedParseJob, and StagedParseJobPolicy; privately retains regex match/capture offsets in LinkedRE; composes one exclusive STAGED_PARSE_JOB_MARKER into Contracts/ScannerCore; validates before execution; and classifies its recognition effect as parser_registry_or_staged_dispatch. The dormant consumer passes 120 assertions over exact lowering, opaque/detached sidecars, Unicode-scalar direct and ordered-derived spans, all eight neutral provenance cases, malformed/dynamic/smuggled rejection, unchanged function-body v1, and transaction denial, then fails only on missing pre-registered resolution/cache/result/failure authority. The neutral checker, language 250/126, rollout, discovery, carriers, formats, and outward guards remain unchanged."
reverify:
  - "perl -Iperl -c perl/LinkedSpec/ActionIR/StagedParseJob.pm && perl -Iperl -c perl/LinkedSpec/StagedParseJob.pm && perl -Iperl -c perl/LinkedSpec/StagedParseJobPolicy.pm"
  - "test \"$(PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t 2>&1 | rg -c 'Failed 1/121 subtests|expected RED: missing authority=\\[pre_registered_resolution,immutable_cache,result_failure_policies\\]')\" -eq 2"
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

This carrier declares intent only. It does not resolve `expr-v1`, prepare immutable entries, cache, execute, stitch,
or schedule recursively. It remains absent from ordinary/canonical discovery and explicitly non-public in the
language inventory. Those next authorities belong to `.14.7.3.2-.4`.

Related: [[perl-staged-ast-enrichment-dormant-red]], [[general-staged-ast-enrichment-neutral-contract]],
[[typed-source-location-cursor-algebra-direction]], and ADR `0088`.
