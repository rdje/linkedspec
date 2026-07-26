---
id: julia-rule-local-cursor-preflight
title: "Julia cursor migration begins from global seek, raw bare edges, descriptor v0, and generated v1"
answers:
  - "what is the Julia rule local cursor boundary before implementation"
  - "does Julia parse all 36 cursor family spellings"
  - "does Julia classify compact pipe as OR"
  - "why does Julia compact pipe have the wrong cursor family"
  - "does Julia normalize bare rule edges"
  - "does Julia reject an indexed blind call"
  - "how many Julia parent child cursor cases currently agree"
  - "does Julia use a global parse mode"
  - "does Julia descriptor publish cursor contract v1"
  - "what generated source cursor version does Julia emit"
  - "how many Julia primary cursor cases fail"
  - "what is the safe Julia cursor implementation order"
  - "which Julia files own rule local cursor migration"
date: 2026-07-18
status: verified historical preflight; implementation superseded through .9.1.6.5
tags: [julia, cursor, parse-mode, rule-family, bare-edge, descriptor, generated-source, cli, preflight, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.6.0 reads ADR 0044, the neutral/admitted authorities, Julia architecture/root-route facts, toolbox, and complete drivers before source inspection. Contract-driven API probes parse all 36 headers, but current `is_and` agrees on only 34 because `RuleMode(\"Pipe\")` is classified AND even though `|` is the accepted compact OR spelling. All 36 engines hold global seek, so only the 22 seek families agree intrinsically. Of 18 edge rows, Julia parses 3 action, 3 blind, 1 lifecycle, and 11 raw; only five of thirteen expected-success rows compile, none of the seven edge/edge-set error cases has its portable code, and `=> Child[0]` is silently accepted after prefix parsing. Exact admitted parent/child fixtures agree on 5/8 definedness rows; OR-to-AND blind/action/call are false positives, while recursive agreement is accidental. Structural replacements agree 1/2 because anchored choice also false-positively seeks. Descriptor metadata retains `parse_mode=seek` and lacks cursor contract/policy. Generated source is v1/format 1, and an AND generated plan accepts leading junk. Normalized and loaded engines default seek; engine and loaded factories accept consume overrides. Shared primary passes exactly 32/65 in default and POSIX: 22 help/usage plus 11 medium-or-higher request-trace failures. Package execution reaches the frozen 56/57 help mismatch; standalone corpus is 105/105; neutral governance is 67 files, 4 complete / 4 pending, and 39 mutations. No executable, contract, fixture, rollout, or public semantic behavior changes in the preflight."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 supersedes the measured generated v1 boundary with current v2/format 2 family-derived execution and contract-before-payload validation. Public option removal and admission remain .9.1.6.5-.6."
evidence_update_2026_07_18_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 supersedes the measured public/global seam: engine, loaded-engine, corpus, help, execution, and request trace carry no override; legacy API/CLI spellings fail with the targeted diagnostic. At that slice, composed admission alone remained .9.1.6.6."
evidence_update_2026_07_18_admission: "FUTURE-PARITY-BACKLOG.9.1.6.6 supersedes the final staged boundary with one exact 15-role Julia consumer. Neutral governance is now 67 files / 5 complete + 3 pending / 44 mutations."
reverify: "python3 tools/check_rule_local_cursor_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using Test, LinkedSpecJulia; const REPO_ROOT=pwd(); include(\"julia/test/rule_local_cursor_option_removal_test.jl\")'"
---

# Julia rule-local cursor preflight

This card preserves the measured pre-implementation boundary. Typed family and
edge normalization has since landed under `.9.1.6.1`; see
[[julia-rule-local-cursor-normalization]], [[julia-rule-local-cursor-execution]],
[[julia-rule-local-cursor-descriptor]], [[julia-generated-source-v2-rule-local-cursor]], and
[[julia-global-cursor-option-removal]]. Generated-v1 and public-option measurements below are historical;
composed admission is closed by `.9.1.6.6`; the preflight measurements remain historical evidence of the repaired
boundary.

Julia's parser already recognizes every neutral header spelling, but recognition is not yet the accepted semantic
classification. `julia/src/spec/Ast.jl` includes `Pipe` in `is_and(...)`; ADR 0044 instead assigns `|` to the
OR/default family. `julia/src/spec/Parser.jl` has explicit action/blind/lifecycle parsers but leaves complete bare
rule-label members as `RawBodyElementKind`. The validator therefore emits legacy malformed/mixed/group messages
rather than the portable normalization and validation diagnostics. Its explicit blind parser also consumes only
the `=> Child` prefix of `=> Child[0]`, so the forbidden index is currently lost rather than rejected.

The global runtime seam is direct. `LinkedSpecRuntimeEngine` stores one `parse_mode`; both ordinary alternation and
specific-index matching read it, and every blind/action/call/recursive child reuses the same engine. Low-level
`runtime_match`, `seek_match`, and `consume_match` are legitimate primitives and remain. High-level engine,
loader, corpus, and primary-command ownership must be removed.

The gate-safe implementation order is:

1. `.9.1.6.1` normalizes typed family/edge state and portable diagnostics in AST/parser/validator/compiler state,
   including the compact-`|` correction and forward/reserved/index/group/mixed cases.
2. `.9.1.6.2` derives normal live, loaded-default, normalized, recursive, and traced execution at every rule entry.
   Existing generated v1 and outer CLI/corpus explicit overrides remain deliberately isolated legacy seams so a
   v1 artifact never silently changes meaning before the version bump.
3. `.9.1.6.3` replaces descriptor-wide mode with cursor-contract v1 and per-rule resolved facts.
4. `.9.1.6.4` moves generated direct/traced/emitted reconstruction to v2, rejects v1 at the v2 boundary, and then
   removes the temporary v1 semantic isolation.
5. `.9.1.6.5` removes high-level engine/loader/corpus/primary options with the targeted diagnostic, migrates Julia
   callers and the Julia primary checker, and passes the already-reference-owned 65x2 bytes plus corpus 105.
6. `.9.1.6.6` adds one 15-role omission-sensitive Julia consumer, locks backend/canonical topology, advances only
   Julia, and closes the parent before Julia root admission.

The preflight's governed token inventory named nine Julia production/test paths. After `.5` makes the loader and
corpus owners token-free and adds the removal test, the current Julia group contains eight paths. Non-token semantic owners are
`julia/src/spec/Ast.jl`, `julia/src/spec/Validator.jl`, and `julia/src/source/SourceEmitter.jl`; focused source-
emitter, loader, root-route, and new cursor tests consume those seams. `tools/check_julia_primary_cli.sh` is the
neutral-group driver path whose legacy token is now only the exact retired-flag rejection fixture.
`tools/run_julia_local.sh` and
the optional Julia registration in `tools/run_ci_local.sh` are the backend/canonical topology owners.

Related: [[rule-local-cursor-neutral-contract]], [[julia-root-rule-selection-routes]],
[[julia-runtime-rule-interpreter]], [[julia-runtime-matching-state]], [[julia-generated-source-scaffold]], and
[[dart-rule-local-cursor-admission]].
