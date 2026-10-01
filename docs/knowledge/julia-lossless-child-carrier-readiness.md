---
id: julia-lossless-child-carrier-readiness
title: Julia lossless actual-child proof covers five carriers and mutates actual returned results
answers:
  - "does Julia preserve lossless extraction and actual bounded child parsing"
  - "which Julia lossless child carriers retain parent and child engines"
  - "how does Julia lossless readiness falsify its returned-result isolation test"
  - "do fresh emitted Julia children execute the unchanged lossless oracles"
date: 2026-09-28
status: bounded evidence preserved; cross-runtime milestone reconciled under .3.5
tags: [julia, language-readiness, lossless, staged-parsing, provenance, isolation]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3 passes new69 plus existing emitter65/nesting30/context30 assertions (194 total). Five matched routes preserve original/enriched13 twice, child4/15, seven mutants and exact typed failures. Actual returned text/span mutation leaves a second result and the next parse exact; a deliberately aliased pair fails the same oracle. The fresh host executes ten modules and returns the exact required completion report."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/source_emitter_test.jl\")'"
---

# Actual child recognition and returned-result isolation

The canonical ledger is `docs/language-readiness/lossless-child-parsing.md`; `.3.4.3` pins sources and successful
logs. Original `.spec` grammars and JSON cases stay unchanged. The host invokes the actual precompiled child and
rebases its returned span; it does not recognize digits or construct its semantic AST.

Native compiled and SpecFile-JSON reconstructed engine pairs are retained across typed child failure and subsequent
success. Generated v2 on both compiled forms and the fresh emitted host rebuild per invocation. All five compare
exact segment records, independent scalar slices, reconstruction, child input/result/provenance, sidecars and selected
accounting. The four in-process pairs also compare complete successful enriched records.

The isolation oracle changes the actual first result's child text and source-span start, then compares the second
result to its prior snapshot. A deliberately aliased pair must raise exactly `actual child results alias`; a normal
subsequent parse still matches the original oracle. This avoids the known ineffective copy-mutating pattern while
leaving the separate general staged consumer repair under JULIA-STARTUP-READING `.2.26`.

The existing emitter test owns temporary allocation and the private-depot fresh launcher. Ten emitted modules
validate metadata/plans and execute all cases/mutants; successful process status and exact report parsing are both
required, followed by verified scratch removal. Registry-pattern `.2.13` and diagnostic-byte `.2.14` defects remain
owned and unclosed; valid identities/plain child results/small counters do not exercise their adversarial boundaries.

[[lossless-child-readiness-reconciliation]] records the completed bounded matrix and authoring costs; historical leaf evidence and open defect limits remain unchanged.
