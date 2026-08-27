---
id: perl-staged-ast-enrichment-carriers-admission
title: Perl staged-AST enrichment is privately admitted through four fresh-authority carriers
answers:
  - "is Perl staged AST enrichment admitted"
  - "where does Perl staged AST enrichment attach to top-level execution"
  - "which Perl carriers execute staged AST enrichment"
  - "how does Perl staged AST enrichment get fresh authority per run"
  - "does Perl generated source serialize staged parser callbacks"
  - "does Perl generated source serialize the staged registry snapshot"
  - "does Perl staged AST enrichment preserve generated source v2"
  - "does Perl staged AST enrichment preserve function body v1"
  - "where is the Perl staged AST consumer registered"
  - "how many Perl staged AST enrichment checks pass"
  - "what staged AST enrichment backend is next after Perl"
date: 2026-08-26
status: current private Perl admission; Rust and Dart are also admitted; Julia, Lua, recurrence, and public authoring pending
tags: [perl, staged-parsing, carriers, generated-source, admission, ci, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.4 adds private LinkedSpec::StagedASTEnrichmentRuntime and attaches begin/complete invocation to live and generated-v2 top-level execution. A host-only staged_ast_enrichment option supplies the caller-prepared snapshot and recursive authority; every call constructs a new StagedASTEnrichment scheduler/cache and enriches only after the complete parent AST returns. Native, normalized-descriptor, validated generated-plan, and independently loaded emitted packages return equal detached AST/sidecar/diagnostic/cache/resource records. The oracle retains four distinct snapshots, sixteen distinct compiled callback entries, four cancellation identities/callbacks, four clocks, and four independent zero-hit/one-miss caches. Normalized ActionIR args, generated plans, and emitted source contain no callback, compiled parser, registry snapshot, source authority, cancellation/deadline/budget state, mutable queue, path, or host handle. The exact consumer passes 143 top-level checks, appears once in phase-0 and once in canonical CI, and advances only Perl plus neutral governance to 78 mutations. Function-body v1, generated-source v2, language/public/outward surfaces, later backends, recurrence, and combined no-drift remain unchanged or pending."
evidence_update_2026_08_26_rust_dormant_snapshot: "FUTURE-PARITY-BACKLOG.14.7.4.0 commit e37a8b77 advances the neutral mutation inventory from 78 to 79 and the Rust backend consumer from pending_absent to dormant_red while keeping Rust ordinary/canonical discovery and rollout pending. TRACE-OBSERVABILITY.5.4 aligns the already-admitted Perl consumer's immutable topology snapshot with those two neutral truth changes; no Perl carrier, production behavior, registry, format, rollout, public surface, or other backend changes."
evidence_update_2026_08_26_rust_admission: "FUTURE-PARITY-BACKLOG.14.7.4.4 admits Rust's fresh four-route carrier without changing the Perl path. Neutral governance now reports 84 mutations with Perl and Rust complete; Dart FUTURE-PARITY-BACKLOG.14.7.5.0 is next."
evidence_update_2026_08_27_dart_admission: "FUTURE-PARITY-BACKLOG.14.7.5.4 admits Dart's fresh four-route carrier without changing the Perl path. Neutral governance now reports 90 mutations with Perl, Rust, and Dart complete; Julia FUTURE-PARITY-BACKLOG.14.7.6.0 is next."
reverify:
  - "PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c 't/staged_ast_enrichment_perl_contract[.]t' t/phase0_regression.t)\" -eq 1"
  - "test \"$(rg -c 'require_tracked_file t/staged_ast_enrichment_perl_contract[.]t|^perl -c -Iperl t/staged_ast_enrichment_perl_contract[.]t$|^PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract[.]t$' tools/run_ci_local.sh)\" -eq 3"
---

# Perl staged-AST carrier admission

`LinkedSpec::StagedASTEnrichmentRuntime` is a private post-AST orchestration seam. A top-level invocation may pass
one host-only `staged_ast_enrichment` configuration containing the pre-resolved snapshot, caller capability/policy/
resource ceilings, cancellation identity and callback, clock/deadline, and recursive limits. The runtime constructs
a new `LinkedSpec::StagedASTEnrichment` object, so its registry copy and execution-plan cache are invocation-local.
It completes the parent parse first, derives live recognition-transaction state from the descriptor/input, and then
runs bounded breadth-first enrichment inside the existing typed runtime-error boundary.

The same seam serves native live execution, an independently compiled normalized descriptor handler, a validated
generated-v2 plan, and a second independently loaded emitted package. Every route returns equal detached AST,
sidecar, diagnostic, cache, and resource state. Logical normalized/generated/emitted data carries only the inert
marker declaration and ordinary `{label, family}` plan; live callbacks and resource authority arrive exclusively
through host invocation options.

The exact consumer is admitted once through ordinary phase-0 and once through canonical CI. The Perl backend and
rollout row remain complete; Rust and Dart have since reached the same private admission boundary. This is private
implementation evidence, not public `parse_job(...)` authoring. Public closeout remains `.14.7.9`, and Julia
`.14.7.6.0` is the next backend leaf.

## Links

- Neutral authority: [[general-staged-ast-enrichment-neutral-contract]].
- Marker/provenance: [[perl-staged-ast-enrichment-marker-provenance]].
- Recursive authority: [[perl-staged-ast-enrichment-recursive-authority]].
- Historical RED: [[perl-staged-ast-enrichment-dormant-red]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.7.3.4`.
