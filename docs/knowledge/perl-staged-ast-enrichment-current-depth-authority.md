---
id: perl-staged-ast-enrichment-current-depth-authority
title: Perl has private pre-registered current-depth staged-AST authority and all stitch policies
answers:
  - "where is Perl staged AST resolution implemented"
  - "how does Perl resolve parse_job parser identities"
  - "can Perl parse_job load a path or call a provider"
  - "how does Perl normalize the parse_job default top rule"
  - "how does Perl compute staged parse job ids"
  - "what fields are in the Perl staged parser cache key"
  - "does the Perl staged cache retain child results or failures"
  - "which staged result policies work privately in Perl"
  - "which staged failure policies work privately in Perl"
  - "how are current-depth Perl staged jobs ordered"
  - "do sibling staged parsers share Perl runtime state"
  - "how are Perl staged child results detached"
  - "does Perl recursively schedule staged AST markers yet"
  - "what is FUTURE-PARITY-BACKLOG 14.7.3.2"
date: 2026-08-26
status: current private current-depth building block; recursive carriers and Perl admission complete
tags: [perl, staged-parsing, registry, cache, result-policy, failure-policy, detachment, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.2 adds unexported LinkedSpec::StagedASTEnrichment over a caller-prepared immutable snapshot whose entries contain already-compiled CODE authority. Pure post-AST selection implements alias, declaring-relative, ordered-root, and ordered-provider priority plus exact missing/ambiguity/collision denial; top/version/capability/policy/source-detail authority narrows; default top precedes canonical v2 job identity; cache identity covers normalized parser/content/import/top/version/sorted-effective-capability fields and stores only immutable execution plans. One complete discovered depth sorts typed paths numerically, gives every callback fresh runtime state, and implements replace_marker, replace_field, sibling_field, append_child, fail, keep_text, and diagnostic_node over an unpublished AST copy. Results are node-bounded and detached, failures/results never enter the cache, stale/missing/colliding/wrong-kind targets reject, and nested inert markers remain untouched. The dormant consumer has 133 GREEN top-level checks and one RED for FUTURE-PARITY-BACKLOG.14.7.3.3 recursion, decreasing-chain/cancellation/resource bounds, and source-rebased diagnostics. V1, discovery, rollout, carriers, format, language/public/outward surfaces, and other backends do not move."
evidence_update_2026_08_26_recursive: "FUTURE-PARITY-BACKLOG.14.7.3.3 preserves enrich_ast's exact one-depth behavior and adds enrich_recursively over the same preparation/cache/policy engine. The consumer advances to 141 GREEN top-level checks and one carriers/admission RED."
evidence_update_2026_08_26_admission: "FUTURE-PARITY-BACKLOG.14.7.3.4 constructs a fresh instance of this authority for each of four top-level carrier routes. The consumer is 143/143 and admitted; function-body v1 and public authoring remain unchanged."
reverify:
  - "perl -Iperl -c perl/LinkedSpec/StagedASTEnrichment.pm"
  - "PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c 'PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract[.]t' tools/run_ci_local.sh)\" -eq 1"
---

# Perl current-depth staged-AST authority

`LinkedSpec::StagedASTEnrichment` is a private, ActionIR-independent post-AST authority. Its constructor accepts
only a frozen snapshot of caller-completed candidate outcomes and logical entries whose compiled authority is
already a Perl `CODE` reference. Seed mutation cannot change its copy. `register` and `load` are typed denials,
and the module contains no filesystem, provider, import, environment, network, loading, or compilation operation.

After a complete parent AST returns, `enrich_ast` discovers only the markers already present at that depth. It
resolves every job and validates every target before executing callbacks. Alias, declaring-relative, ordered-root,
and ordered-provider selection is pure. Default top normalization precedes the canonical v2 job digest. The cache
stores one locked callback execution plan under the neutral content/import/top/version/effective-capability key;
text-dependent child results and failures are always executed fresh and never cached.

Jobs run by typed parent path, typed provenance, and job id. Array index `2` precedes `10`. Each callback receives
fresh cursor, mark, capture, variable, and request aggregates, with no parent AST or registry/loader authority.
Success results are detached and node-bounded before one of the four exact target policies changes an unpublished
AST copy. `fail` publishes nothing; `keep_text` and `diagnostic_node` retain the same detached diagnostic in the
scheduler sidecar. Marker mismatch, missing replacement, sibling collision, invalid append target, live/cyclic
result, and result-node overflow fail with their portable codes.

`enrich_ast` intentionally remains one depth: a child result may contain another inert marker, which this entrypoint
leaves intact. `.14.7.3.3` adds the separate `enrich_recursively` entrypoint over the same preparation engine with
breadth-first recurrence, active-chain guards, shared limits, and source rebasing. `.14.7.3.4` now supplies fresh
native/reconstructed/generated/emitted carriers plus admission; `.14.7.9` owns public authoring.

Related: [[perl-staged-ast-enrichment-marker-provenance]], [[perl-staged-ast-enrichment-recursive-authority]],
[[general-staged-ast-enrichment-neutral-contract]], [[general-staged-ast-current-boundary]], and ADR `0088`.

## September 6 complete-depth source reading

Startup .3.2.46 reads StagedASTEnrichment 1–1498 / 49,952 bytes at unchanged baseline baeb984e.
Pure candidate resolution, normalized top/job/cache identity, policy narrowing, complete target
reservation, fresh callbacks, and one-depth settlement remain distinct from recursive scheduling.
The remaining validators/stitch/detachment suffix stays separately checkpointed. Current unchanged
Perl proof is 143 tests; neutral staged proof is 9/9/123 plus public 6/17/10/129 from the preceding
canonical run. The recursive identity-lifetime risk is separately .44-owned, not a one-depth failure.
