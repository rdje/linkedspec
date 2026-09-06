# SESSION-STARTUP-READING: Complete the Required Reading Before Implementation

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Session continuity prerequisite to RUST-MUTATION-TESTING.1`
- Created: `2026-09-06`
- Last updated: `2026-09-06`
- Owner: repo-local workflow
- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`

## Goal

Complete the director-required roadmap, first-party codebase, and mdBook reading with honest, recoverable
coverage, then resume `RUST-MUTATION-TESTING.1`. Reading supports signoff-quality execution; a saved reading
checkpoint is continuity work and is not feature completion, a code audit, or fresh runtime verification.

## Non-Goals

- Implement features, change behavior, run a mutation campaign, or adopt an unreviewed policy in this checkpoint.
- Count file enumeration, truncated output, historical test results, or unread material as completed reading.
- Include the `rgx` submodule or its nested dependencies in this startup reading pass.

## Acceptance Criteria

- All three required-reading answers become Yes only after their remaining material has actually been read.
- The exact baseline, exclusions, completed ranges, remaining work, and next action survive in committed state.
- Any discovered defect or policy gap receives an owning leaf and evidence before remediation.
- Roadmaps, live continuity, and task index agree; public book changes accompany material public understanding.
- Each completed reading/checkpoint leaf follows `COMMIT.md`; implementation remains gated until reading closes.

## Task Tree

- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Complete the required reading and restore the implementation frontier.
  Children: `SESSION-STARTUP-READING.1`, `SESSION-STARTUP-READING.2`, `SESSION-STARTUP-READING.3`, `SESSION-STARTUP-READING.4`, `SESSION-STARTUP-READING.5`, `SESSION-STARTUP-READING.6`, `SESSION-STARTUP-READING.7`, `SESSION-STARTUP-READING.8`, `SESSION-STARTUP-READING.9`, `SESSION-STARTUP-READING.10`, `SESSION-STARTUP-READING.11`, `SESSION-STARTUP-READING.12`, `SESSION-STARTUP-READING.13`, `SESSION-STARTUP-READING.14`, `SESSION-STARTUP-READING.15`

- ID: `SESSION-STARTUP-READING.1`
  Status: `done`
  Goal: Commit the authorized startup-reading checkpoint before continuing the reading pass.
  Acceptance: Baseline and coverage are explicit, required-reading answers remain honest, and continuity points to `.2`.
  Verification tier: `focused`
  Focused checks: `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `perl tools/roll_document_history.pl --surface change_history --check`; `perl tools/roll_document_history.pl --surface engineering_notes --check`; `git diff --check`; staged-path and coverage review.
  Canonical trigger: `none` — bounded continuity documentation; no policy, infrastructure, or public contract changes.
  Verification: Activated task-tree-first from the clean reading baseline; memory, nine doctrine checks, both history-pressure checks, and diff/scope review pass. README routing was rerun after refreshing the staged snapshot; pre-commit checks the final candidate again.
  Commit: `SESSION-STARTUP-READING.1 - preserve required reading progress`

- ID: `SESSION-STARTUP-READING.2`
  Status: `done`
  Goal: Finish ROADMAP_V2.md from baseline line 1341 and reconcile its current direction with the completed ROADMAP.md reading.
  Acceptance: Baseline lines 1341–1585 are read without truncation; roadmap understanding and any real alignment issue are recorded.
  Verification tier: `focused`
  Focused checks: `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `perl tools/roll_document_history.pl --surface change_history --check`; `perl tools/roll_document_history.pl --surface engineering_notes --check`; `git diff --check`; staged-scope and exact reading-range review.
  Canonical trigger: `none` — startup-reading continuity only; no public, policy, infrastructure, or runtime change.
  Verification: Baseline lines 1341–1585 read in five untruncated ranges; both roadmap diffs since baseline reviewed. Current direction agrees with the task index, mutation-testing tree, ADR 0039, and ADR 0073. Focused commit checks recorded below.
  Commit: `SESSION-STARTUP-READING.2 - complete roadmap reading`

- ID: `SESSION-STARTUP-READING.3`
  Status: `active`
  Goal: Read and understand the remaining first-party codebase, including its tests, specs, and repository tooling.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`, `.3.5`, `.3.6`, `.3.7`, `.3.8`, `.3.9`, `.3.10`, `.3.11`

- ID: `SESSION-STARTUP-READING.3.1`
  Status: `done`
  Goal: Classify the complete baseline tracked inventory and define exact bounded first-party reading children.
  Acceptance: Every baseline path has an explicit category/owner or the director's rgx exclusion; account for
    source, tests, specs, generated inputs, fixtures, tooling, and files outside language directories. Define
    deterministic file/range boundaries and review baseline-to-current changes before claiming any coverage.
  Verification tier: `focused`
  Focused checks: Git baseline/object and current-delta census; disjoint complete reading-category review; exact bounded next-child scope; managed `perl -Iperl -c perl/LinkedSpec.pm` and `perl -Iperl -c t/phase0_regression.t`; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — reading inventory and tracking only, with no source/tool/policy/public behavior change.
  Verification: Exact baseline Git object census accounts for 2,547 entries / 52,084,744 blob bytes with one
    excluded gitlink. The disjoint path rules below account for all entries; only four gzip blobs contain NULs.
    Source/test/tool inputs remain byte-identical to baseline. First reading child is exactly five files / 1,430
    lines / 56,706 bytes; inventory and decompression counts do not count as content reading.
  Commit: `SESSION-STARTUP-READING.3.1 - bound the codebase reading inventory`

- ID: `SESSION-STARTUP-READING.3.2`
  Status: `active`
  Goal: Read all 89 baseline Perl entries and their current deltas, starting with the facade invocation owners.
  Children: `.3.2.1`, `.3.2.2`, `.3.2.3`, `.3.2.4`, `.3.2.5`, `.3.2.6`, `.3.2.7`, `.3.2.8`, `.3.2.9`, `.3.2.10`, `.3.2.11`, `.3.2.12`, `.3.2.13`, `.3.2.14`, `.3.2.15`, `.3.2.16`, `.3.2.17`, `.3.2.18`, `.3.2.19`, `.3.2.20`, `.3.2.21`, `.3.2.22`, `.3.2.23`, `.3.2.24`, `.3.2.25`, `.3.2.26`, `.3.2.27`, `.3.2.28`, `.3.2.29`, `.3.2.30`, `.3.2.31`, `.3.2.32`, `.3.2.33`, `.3.2.34`, `.3.2.35`, `.3.2.36`, `.3.2.37`, `.3.2.38`, `.3.2.39`, `.3.2.40`, `.3.2.41`, `.3.2.42`, `.3.2.43`, `.3.2.44`, `.3.2.45`, `.3.2.46`, `.3.2.47`, `.3.2.48`, `.3.2.49`, `.3.2.50`, `.3.2.51`, `.3.2.52`, `.3.2.53`, `.3.2.54`

- ID: `SESSION-STARTUP-READING.3.2.1`
  Status: `done`
  Goal: Read the facade invocation and shared-context owners in full.
  Acceptance: Read `perl/LinkedSpec.pm` 1–296, `perl/LinkedSpec/OwnerDispatch.pm` 1–220,
    `perl/LinkedSpec/Runtime.pm` 1–154, `perl/LinkedSpec/ParserFactory.pm` 1–368, and
    `perl/LinkedSpec/RuntimeContext.pm` 1–392. Reconcile against the existing thin-facade Knowledge card;
    record exact comprehension and any tool-confirmed issue. No runtime-change or full-codebase claim.
  Verification tier: `focused`
  Focused checks: Full untruncated five-file reading and baseline identity/delta review; existing Knowledge-owner comparison; managed Perl facade/phase0 syntax; `bash scripts/check_memory_architecture.sh`; required pre-commit `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — bounded source-reading checkpoint, with no production or public behavior change.
  Verification: All five exact files read through EOF without truncation; Git proves baseline identity. Existing
    thin-facade and leading-trivia Knowledge cards reconcile the owner flow and public-wrapper boundary. Managed
    facade/phase0 syntax passes; no production change, new defect, or runtime/audit-completion claim.
  Commit: `SESSION-STARTUP-READING.3.2.1 - read facade invocation owners`

- ID: `SESSION-STARTUP-READING.3.2.2`
  Status: `done`
  Goal: Split the remaining 84 baseline Perl paths into exact bounded reading children before reading them.
  Acceptance: Subtract `.3.2.1` by exact path; use the inventory's byte/line boundary rule and retain every file.
    Prior supporting read coverage remains explicit and cannot silently remove an unread interval.
  Verification tier: `focused`
  Focused checks: Exact baseline path/range coverage and byte/line budgets; baseline-to-current Perl delta;
    `bash scripts/check_memory_architecture.sh`; required pre-commit `bash scripts/check_doctrines.sh`;
    both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — reading decomposition and continuity only; no source or policy change.
  Verification: Independent byte-interval audit passes: all 84 exact remaining paths / 2,076,984 bytes
    covered once by 52 bounded leaves; declared budgets match and Perl source remains baseline-identical.
  Commit: `SESSION-STARTUP-READING.3.2.2 - partition remaining Perl reading`

- ID: `SESSION-STARTUP-READING.3.2.3`
  Status: `done`
  Goal: Read baseline Perl group 1: 1,103 lines/fragments, 36,759 bytes.
  Scope: `perl/LinkedSpec/Resolver.pm` lines 1–223; `perl/LinkedSpec/SpecLoader.pm` lines 1–352; `perl/LinkedSpec/EntryRuleSelection.pm` lines 1–74; `perl/LinkedSpec/GeneratedSource.pm` lines 1–319; `perl/LinkedSpec/BootstrapSpec.pm` lines 1–135.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Investigate whether cached `spec_spec_result` survives a later unsuccessful diagnostic parse before
    interpreting it as current-invocation metadata; use Get/descriptor and bootstrap probes before source tracing.
  Verification tier: `focused`
  Focused checks: Exact scoped reading and baseline identity; existing Knowledge-owner reconciliation;
    managed Get/descriptor plus cached-bootstrap empty/positive comparison probes and consumer/source trace;
    `bash scripts/check_memory_architecture.sh`; required pre-commit `bash scripts/check_doctrines.sh`;
    both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — source-reading continuity only; no production or public behavior change.
  Verification: Five complete files / 1,103 lines / 36,759 bytes read without truncation; baseline identity
    preserved. Existing resolution/root-selection/generated-source/bootstrap contracts reconciled. Probes confirm
    stale diagnostic comparison state; public Get still rejects malformed source. Repair `.8` and Knowledge own
    the defect; no production repair or full-codebase claim.
  Commit: `SESSION-STARTUP-READING.3.2.3 - read resolution and bootstrap adapters`

- ID: `SESSION-STARTUP-READING.3.2.4`
  Status: `done`
  Goal: Read baseline Perl group 2: 1,196 lines/fragments, 39,291 bytes.
  Scope: `perl/LinkedSpec/BootstrapSpec/Core.pm` lines 1–1196.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Probe quoted-versus-regex delimiters in attached conditional tails before classifying the balanced scanner.
  Verification tier: `focused`
  Focused checks: Full untruncated core reading and baseline identity; existing bootstrap/grammar Knowledge;
    managed attached-tail, call_spec_handler_subst, descriptor, and public execution controls; exact source trace;
    `bash scripts/check_memory_architecture.sh`; required pre-commit `bash scripts/check_doctrines.sh`;
    both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — source-reading continuity only; no production or public behavior change.
  Verification: All 1,196 lines / 39,291 bytes read in four untruncated chunks; baseline identity passes.
    Direct scanner and public controls prove regex-delimiter truncation; quoted-pattern execution returns 1,
    regex form returns undef with exact handler-compile error. Knowledge and `.9` own repair after reading.
  Commit: `SESSION-STARTUP-READING.3.2.4 - read bootstrap grammar core`

- ID: `SESSION-STARTUP-READING.3.2.5`
  Status: `done`
  Goal: Read baseline Perl group 3: 590 lines/fragments, 23,054 bytes.
  Scope: `perl/LinkedSpec/CompilerState.pm` lines 1–590.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Apply the mandatory changelog rollover if this checkpoint crosses 90%; verify complete-record preservation.
    Any required finite history-member capacity admission follows README_POLICY and exact indexed-ADR proof,
    without changing product code, current-view ceilings, archive identity, or the required-reading boundary.
  Verification tier: `canonical`
  Focused checks: Two exact reading chunks and baseline identity; existing CompilerState/descriptor Knowledge;
    required rollover plus independent clean-source suffix/hash/count proof; document-history and README routing;
    `bash scripts/check_memory_architecture.sh`; both history-pressure checks; `git diff --check`.
  Canonical trigger: `infrastructure` — ADR 0102 admits one required history member and manifest line in the route registry.
  Verification: CompilerState fully read in 1–300 / 301–590 chunks, 590 lines / 23,054 bytes, baseline-identical.
    Required rollover archives exact source lines 242–459 as segment 4985; independent byte/hash proof passes.
    ADR 0102 records the exact finite 28-file/27-manifest-line admission. Final staged canonical receipt is required
    before landing; no production change or completed full-codebase claim.
  Commit: `SESSION-STARTUP-READING.3.2.5 - read compiler state and preserve history`

- ID: `SESSION-STARTUP-READING.3.2.6`
  Status: `done`
  Goal: Read baseline Perl group 4: 1,041 lines/fragments, 41,073 bytes.
  Scope: `perl/LinkedSpec/Compiler.pm` lines 1–1041.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Preserve the preceding canonical result and dated loader observations in the existing Knowledge owner.
    Link the historical duplicate-slot risk card to its already-admitted resolution without rewriting its evidence.
  Verification tier: `focused`
  Focused checks: Exact scoped reading and baseline identity; existing compiler ownership reconciliation;
    prior canonical receipt and measured loader evidence; memory/doctrine/Knowledge/history checks;
    `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading and measured startup continuity only; no infrastructure or public change.
  Verification: Four untruncated chunks cover baseline-identical lines 1–1041 / 41,073 bytes. Existing state,
    generated-v2, function-registry, and duplicate-slot owners reconcile. Prior exact canonical proof passed;
    dated samples are preserved in Knowledge and their two consumed files were hash-verified/deleted/checked absent.
    The historical duplicate-slot card links its existing resolution; focused commit checks are recorded below.
  Commit: `SESSION-STARTUP-READING.3.2.6 - read compiler generation and state assembly`

- ID: `SESSION-STARTUP-READING.3.2.7`
  Status: `done`
  Goal: Read baseline Perl group 5: 961 lines/fragments, 43,851 bytes.
  Scope: `perl/LinkedSpec/Compiler.pm` lines 1042–2002.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Index source-level pipeline phase/return-mode boundaries without duplicating the existing state/root owners.
  Verification tier: `focused`
  Focused checks: Four exact reading chunks and baseline identity; existing pipeline/context/diagnostic Knowledge;
    memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Four untruncated chunks cover baseline-identical lines 1042–2002 / 43,851 bytes, completing
    Compiler.pm at 2,002 lines / 84,924 bytes. Existing architecture/Knowledge owners reconcile; a bounded
    source-level card indexes phase and mode boundaries. No new runtime defect or public change.
  Commit: `SESSION-STARTUP-READING.3.2.7 - complete compiler pipeline reading`

- ID: `SESSION-STARTUP-READING.3.2.8`
  Status: `done`
  Goal: Read baseline Perl group 6: 600 lines/fragments, 23,171 bytes.
  Scope: `perl/LinkedSpec/SpecEntry.pm` lines 1–600.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile the older SpecEntry coupling cards against current owners; preserve historical evidence explicitly.
  Verification tier: `focused`
  Focused checks: Exact reading chunks and baseline identity; Knowledge owner reconciliation and isolated handoff probes;
    memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Three untruncated chunks cover all 600 lines / 23,171 bytes, including EOF; baseline identity
    passes. Existing owners reconcile and two older coupling cards now explicitly preserve historical scope.
    Isolated HandlerIR probes confirm unbound AND_BCODE inputs; public descriptor/source control bounds the
    finding without claiming a result failure. Repair `.10` is owned; focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.8 - read SpecEntry and own unbound input repair`

- ID: `SESSION-STARTUP-READING.3.2.9`
  Status: `done`
  Goal: Read baseline Perl group 7: 1,320 lines/fragments, 43,290 bytes.
  Scope: `perl/LinkedSpec/Validation.pm` lines 1–1320.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Normalize the prior coupling card's multiline retrieval fields observed as literal pipes in the derived map;
    reconcile the open-block card's retired-option reverify command against the current validator boundary.
  Verification tier: `focused`
  Focused checks: Exact reading chunks and baseline identity; existing validation/root Knowledge and focused
    diagnostic reverify; memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity and retrieval repair only; no production or public change.
  Verification: Six untruncated chunks cover baseline-identical lines 1–1320 / 43,290 bytes. Existing
    envelope/root/open-block/gap owners reconcile. Context, callback, and public Get probes confirm diagnostic
    source drift; `.11.1`–`.11.3` own bounded repair. Prior retrieval fields and the removed-option command
    are corrected; focused continuity/Knowledge checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.9 - read validation and own diagnostic repairs`

- ID: `SESSION-STARTUP-READING.3.2.10`
  Status: `done`
  Goal: Read baseline Perl group 8: 584 lines/fragments, 18,639 bytes.
  Scope: `perl/LinkedSpec/Validation.pm` lines 1321–1904.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile the relevant historical edge card with already-admitted bare-edge and gap owners.
  Verification tier: `focused`
  Focused checks: Exact suffix chunks/full-file baseline identity; existing edge/slash/diagnostic Knowledge;
    memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Three untruncated chunks cover 584 lines / 18,639 bytes, completing baseline-identical
    Validation.pm at 1,904 lines / 61,929 bytes. Existing edge/slash/gap and diagnostic owners reconcile;
    the edge card now links admitted owners and clarifies optional blind-return blocks. No new runtime defect.
  Commit: `SESSION-STARTUP-READING.3.2.10 - complete validation reading`

- ID: `SESSION-STARTUP-READING.3.2.11`
  Status: `done`
  Goal: Read baseline Perl group 9: 987 lines/fragments, 31,462 bytes.
  Scope: `perl/LinkedSpec/RuleIR.pm` lines 1–987.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact reading chunks/baseline identity; current rule-local/root/slot/trace Knowledge and direct/public ordering probes;
    memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Five untruncated chunks cover all 987 lines / 31,462 bytes; baseline identity passes.
    Existing collection/normalization/planning owners reconcile. Public OR/AND and spelling controls plus
    direct collect/normalize probes confirm bare/explicit execution-order drift; repair `.12` is owned.
    Focused continuity/Knowledge checks precede landing; no runtime source change.
  Commit: `SESSION-STARTUP-READING.3.2.11 - read RuleIR and own edge-order repair`

- ID: `SESSION-STARTUP-READING.3.2.12`
  Status: `done`
  Goal: Read baseline Perl group 10: 1,489 lines/fragments, 49,396 bytes.
  Scope: `perl/LinkedSpec/RuleIR/EmitContext.pm` lines 1–1489.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile the owner-registry card's stated cardinality and keys with the current explicit registry.
  Verification tier: `focused`
  Focused checks: Exact reading chunks/baseline identity; existing EmitContext/ActionIR owner and trace Knowledge;
    exact registry-key extraction; memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Seven untruncated ranges cover lines 1–1489 / 49,396 bytes; baseline identity passes.
    Existing owner/trace contracts reconcile; exact registry extraction confirms fourteen keys, thirteen
    ActionIR owners plus Trace, correcting two existing cards. Focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.12 - read EmitContext bridge and reconcile registry`

- ID: `SESSION-STARTUP-READING.3.2.13`
  Status: `done`
  Goal: Read baseline Perl group 11: 1,094 lines/fragments, 46,079 bytes.
  Scope: `perl/LinkedSpec/RuleIR/EmitContext.pm` lines 1490–2583.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Probe repeated blind-target attached-code identity through public Get/descriptor/source controls before classification.
  Verification tier: `focused`
  Focused checks: Exact suffix reading/full-file baseline identity; existing EmitContext/type-memory/working-variable Knowledge;
    public repeated-target controls and source/owner probes; memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Six untruncated ranges complete 1490–2583 / 46,079 bytes; full-file baseline identity passes.
    Public AND/OR controls, descriptor/source capture, and direct rewrite prove repeated blind targets lose
    attached-code identity. Repair `.13` and Knowledge preserve the causal evidence; focused checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.13 - complete EmitContext reading and own blind-edge repair`

- ID: `SESSION-STARTUP-READING.3.2.14`
  Status: `done`
  Goal: Read baseline Perl group 12: 1,403 lines/fragments, 53,304 bytes.
  Scope: `perl/LinkedSpec/HandlerVariantEmitter.pm` lines 1–1403.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile the dated HandlerIR card and probe literal preservation in per-regex I-block return rewriting.
  Verification tier: `focused`
  Focused checks: Exact prefix reading/full-file baseline identity; existing HandlerIR/emitter/trace/slot Knowledge;
    direct builder/emitter, public literal/package-state controls, and historical return reverify; memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Seven untruncated ranges cover 1–1403 / 53,304 bytes; full-file baseline identity passes.
    Builder/dispatch probes reconcile HandlerIR; indexed return control remains fixed. Public/source/seed
    controls prove per-regex I-block literal and state corruption; `.14.1`/`.14.2` own repair. Focused checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.14 - read emitter prefix and own I-block repairs`

- ID: `SESSION-STARTUP-READING.3.2.15`
  Status: `done`
  Goal: Read baseline Perl group 13: 736 lines/fragments, 24,430 bytes.
  Scope: `perl/LinkedSpec/HandlerVariantEmitter.pm` lines 1404–1920; `perl/LinkedRE.pm` lines 1–148; `perl/LinkedSpec/ActionIR/AST.pm` lines 1–71.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile the remaining repetition return rewrite with the owned literal-preservation repair before classification.
  Verification tier: `focused`
  Focused checks: Exact scoped reading/baseline identity; existing emitter/repetition/LinkedRE/AST Knowledge and relevant return controls;
    bounded REP literal/source/package controls and JSON projection; memory/doctrine/Knowledge/history checks; `git diff --check` and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production, infrastructure, or public change.
  Verification: Three emitter suffix ranges plus complete LinkedRE/AST cover 736 lines / 24,430 bytes; baseline identity passes.
    Native bounded REP controls confirm literal corruption and package writes; `.14.1`/`.14.2` extend to this
    same causal family. JSON subset projection and existing slot/AST owners reconcile; focused checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.15 - finish emitter adapters and extend return repairs`

- ID: `SESSION-STARTUP-READING.3.2.16`
  Status: `done`
  Goal: Read baseline Perl group 14: 1,498 lines/fragments, 47,935 bytes.
  Scope: `perl/LinkedSpec/ActionIR/AST/Parser.pm` lines 1–1498.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact scoped reading and baseline identity; existing AST/parser Knowledge reconciliation;
    ASCII/Unicode AST and public Get controls; `t/actionir_ast_parser.t` and `t/punctuation_light_zero_arg_contract.t`;
    memory/doctrine/Knowledge/history checks and final staged review.
  Canonical trigger: `none` — bounded source-reading continuity; no production or public change.
  Verification: Seven untruncated ranges cover 1,498 lines / 47,935 bytes; full-file baseline identity passes.
    Seven ASCII and two Unicode AST controls isolate nested offset loss; public Get preserves the typed
    diagnostic in last_error.detail. Two focused suites pass 30 top-level tests; repair `.15` owns the gap.
  Commit: `SESSION-STARTUP-READING.3.2.16 - read AST parser and own nested span repair`

- ID: `SESSION-STARTUP-READING.3.2.17`
  Status: `done`
  Goal: Read baseline Perl group 15: 1,195 lines/fragments, 47,612 bytes.
  Scope: `perl/LinkedSpec/ActionIR/AST/Parser.pm` lines 1499–1686; `perl/LinkedSpec/ActionIR/ArrayPipeline.pm` lines 1–491; `perl/LinkedSpec/ActionIR/CanonicalEvents.pm` lines 1–297; `perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm` lines 1–219.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact scoped reading and baseline identity; existing AST, pipeline, and canonical-event
    Knowledge reconciliation; memory/doctrine/Knowledge/history checks and final staged review.
  Canonical trigger: `none` — bounded source-reading continuity; no production or public change.
  Verification: Parser suffix and three complete adapters cover 1,195 lines / 47,612 bytes; all four full-file
    baseline identities pass. Existing AST, binding, mutation, and trace/event Knowledge reconciles; no new
    behavior or defect claim. Twenty-four whole Perl files are read; focused checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.17 - finish AST parser and read pipeline adapters`

- ID: `SESSION-STARTUP-READING.3.2.18`
  Status: `done`
  Goal: Read baseline Perl group 16: 1,396 lines/fragments, 65,503 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Contracts.pm` lines 1–1396.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact prefix reading and baseline identity; existing lowering, binding, transaction, and
    typed-source Knowledge reconciliation; direct catalog count/detachment probe; memory/doctrine/Knowledge/history checks and final staged review.
  Canonical trigger: `none` — bounded source-reading continuity; no production or public change.
  Verification: Seven untruncated prefix ranges cover 1,396 lines / 65,503 bytes; full-file baseline identity
    passes. Catalog recheck gives 47/30/11/4 detached rows, total 92. Existing ownership and historical status
    reconcile; no new runtime/admission claim. Focused checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.18 - read contract prefix and reconcile projection status`

- ID: `SESSION-STARTUP-READING.3.2.19`
  Status: `done`
  Goal: Read baseline Perl group 17: 1,117 lines/fragments, 48,433 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Contracts.pm` lines 1397–2513.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact suffix reading and baseline identity; existing lowering Knowledge reconciliation;
    ordered contract-builder source extraction; memory/doctrine/Knowledge/history checks and staged review.
  Canonical trigger: `none` — source-reading continuity only; no production or public change.
  Verification: Six untruncated suffix ranges cover 1,117 lines / 48,433 bytes and complete Contracts.pm;
    full-file baseline identity passes. Exact source extraction confirms fourteen ordered builder groups.
    Existing Knowledge owns the bounded structural fact; focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.19 - finish contract catalog reading`

- ID: `SESSION-STARTUP-READING.3.2.20`
  Status: `done`
  Goal: Read baseline Perl group 18: 1,485 lines/fragments, 56,984 bytes.
  Scope: `perl/LinkedSpec/ActionIR/ControlFlow.pm` lines 1–1485.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact prefix reading and baseline identity; control AST/trace Knowledge reconciliation;
    managed branch-context isolation probe and compact-lowerer trace suite; memory/doctrine/Knowledge/history
    checks and final staged review.
  Canonical trigger: `none` — source-reading continuity only; no production or public change.
  Verification: Seven untruncated prefix ranges cover 1,485 lines / 56,984 bytes; full-file baseline identity
    passes. Controlled candidate-context rejection/acceptance passes, and compact-lowerer trace passes four
    top-level tests. Existing AST/trace/caveat owners reconcile; focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.20 - read control flow prefix and verify candidate isolation`

- ID: `SESSION-STARTUP-READING.3.2.21`
  Status: `pending`
  Goal: Read baseline Perl group 19: 1,439 lines/fragments, 59,142 bytes.
  Scope: `perl/LinkedSpec/ActionIR/ControlFlow.pm` lines 1486–1796; `perl/LinkedSpec/ActionIR/DeclareMethod.pm` lines 1–328; `perl/LinkedSpec/ActionIR/Diagnostics.pm` lines 1–269; `perl/LinkedSpec/ActionIR/FlowExpr.pm` lines 1–531.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.22`
  Status: `pending`
  Goal: Read baseline Perl group 20: 298 lines/fragments, 7,800 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodExpr.pm` lines 1–298.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.23`
  Status: `pending`
  Goal: Read baseline Perl group 21: 1,495 lines/fragments, 61,967 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 1–1495.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.24`
  Status: `pending`
  Goal: Read baseline Perl group 22: 883 lines/fragments, 33,969 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 1496–2378.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.25`
  Status: `pending`
  Goal: Read baseline Perl group 23: 1,365 lines/fragments, 65,506 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 2379–3743.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.26`
  Status: `pending`
  Goal: Read baseline Perl group 24: 1,168 lines/fragments, 58,949 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 3744–4911.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.27`
  Status: `pending`
  Goal: Read baseline Perl group 25: 1,031 lines/fragments, 64,411 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 4912–5942.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.28`
  Status: `pending`
  Goal: Read baseline Perl group 26: 1,303 lines/fragments, 64,878 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 5943–7245.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.29`
  Status: `pending`
  Goal: Read baseline Perl group 27: 977 lines/fragments, 36,165 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 7246–8057; `perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm` lines 1–165.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.30`
  Status: `pending`
  Goal: Read baseline Perl group 28: 1,173 lines/fragments, 41,839 bytes.
  Scope: `perl/LinkedSpec/ActionIR/RewritePipeline.pm` lines 1–745; `perl/LinkedSpec/ActionIR/Scanner.pm` lines 1–90; `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm` lines 1–338.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.31`
  Status: `pending`
  Goal: Read baseline Perl group 29: 1,433 lines/fragments, 41,163 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm` lines 1–1179; `perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm` lines 1–254.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.32`
  Status: `pending`
  Goal: Read baseline Perl group 30: 1,355 lines/fragments, 48,756 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm` lines 1–571; `perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm` lines 1–124; `perl/LinkedSpec/ActionIR/ScannerCore.pm` lines 1–223; `perl/LinkedSpec/ActionIR/StagedParseJob.pm` lines 1–393; `perl/LinkedSpec/ActionIR/StatementSplit.pm` lines 1–44.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.33`
  Status: `pending`
  Goal: Read baseline Perl group 31: 1,423 lines/fragments, 47,678 bytes.
  Scope: `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm` lines 1–419; `perl/LinkedSpec/ActionIR/StatementSplit/Mode.pm` lines 1–214; `perl/LinkedSpec/ActionIR/Trace.pm` lines 1–124; `perl/LinkedSpec/ActionIR/ValueExpr.pm` lines 1–666.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.34`
  Status: `pending`
  Goal: Read baseline Perl group 32: 1,264 lines/fragments, 39,889 bytes.
  Scope: `perl/LinkedSpec/BindingRuntime.pm` lines 1–422; `perl/LinkedSpec/CallableContract.pm` lines 1–135; `perl/LinkedSpec/CodeblockRuntime.pm` lines 1–403; `perl/LinkedSpec/InterMatchGapRuntime.pm` lines 1–291; `perl/LinkedSpec/MCPContract.pm` lines 1–12; `perl/LinkedSpec/MCPContract.pm` lines 13–13.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.35`
  Status: `pending`
  Goal: Read baseline Perl group 33: 1 lines/fragments, 32,768 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` bytes 391–33158.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.36`
  Status: `pending`
  Goal: Read baseline Perl group 34: 1 lines/fragments, 32,768 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` bytes 33159–65926.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.37`
  Status: `pending`
  Goal: Read baseline Perl group 35: 1 lines/fragments, 17,347 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` bytes 65927–83273.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.38`
  Status: `pending`
  Goal: Read baseline Perl group 36: 1,484 lines/fragments, 51,303 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` lines 15–21; `perl/LinkedSpec/MCPContractRuntime.pm` lines 1–300; `perl/LinkedSpec/MCPServer.pm` lines 1–648; `perl/LinkedSpec/MCPWire.pm` lines 1–419; `perl/LinkedSpec/Numeric.pm` lines 1–110.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.39`
  Status: `pending`
  Goal: Read baseline Perl group 37: 1,496 lines/fragments, 52,208 bytes.
  Scope: `perl/LinkedSpec/PluginBridge.pm` lines 1–199; `perl/LinkedSpec/PluginRegistry.pm` lines 1–130; `perl/LinkedSpec/ProgressiveSpanDispatch.pm` lines 1–937; `perl/LinkedSpec/ProgressiveSpanDispatchPolicy.pm` lines 1–58; `perl/LinkedSpec/ProgressiveSpanDispatchRuntime.pm` lines 1–172.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.40`
  Status: `pending`
  Goal: Read baseline Perl group 38: 924 lines/fragments, 33,632 bytes.
  Scope: `perl/LinkedSpec/RecognitionTransaction.pm` lines 1–655; `perl/LinkedSpec/RecognitionTransactionPolicy.pm` lines 1–269.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.41`
  Status: `pending`
  Goal: Read baseline Perl group 39: 1,269 lines/fragments, 39,210 bytes.
  Scope: `perl/LinkedSpec/RecognitionTransactionRuntime.pm` lines 1–681; `perl/LinkedSpec/RecursiveObservationPolicy.pm` lines 1–71; `perl/LinkedSpec/RuntimeDiagnosticOutput.pm` lines 1–247; `perl/LinkedSpec/RuntimeLogical.pm` lines 1–96; `perl/LinkedSpec/RuntimeSemanticObservation.pm` lines 1–174.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.42`
  Status: `pending`
  Goal: Read baseline Perl group 40: 1,148 lines/fragments, 37,003 bytes.
  Scope: `perl/LinkedSpec/SemanticCallProjection.pm` lines 1–753; `perl/LinkedSpec/SemanticIndex.pm` lines 1–395.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.43`
  Status: `pending`
  Goal: Read baseline Perl group 41: 982 lines/fragments, 35,427 bytes.
  Scope: `perl/LinkedSpec/SemanticQuery.pm` lines 1–596; `perl/LinkedSpec/SemanticRuntimeProjection.pm` lines 1–214; `perl/LinkedSpec/SemanticSourceMap.pm` lines 1–172.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.44`
  Status: `pending`
  Goal: Read baseline Perl group 42: 1,067 lines/fragments, 34,029 bytes.
  Scope: `perl/LinkedSpec/SemanticStaticProjection.pm` lines 1–1067.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.45`
  Status: `pending`
  Goal: Read baseline Perl group 43: 700 lines/fragments, 21,209 bytes.
  Scope: `perl/LinkedSpec/SourceLocation.pm` lines 1–700.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.46`
  Status: `pending`
  Goal: Read baseline Perl group 44: 1,498 lines/fragments, 49,952 bytes.
  Scope: `perl/LinkedSpec/StagedASTEnrichment.pm` lines 1–1498.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.47`
  Status: `pending`
  Goal: Read baseline Perl group 45: 1,374 lines/fragments, 43,289 bytes.
  Scope: `perl/LinkedSpec/StagedASTEnrichment.pm` lines 1499–2013; `perl/LinkedSpec/StagedASTEnrichmentRuntime.pm` lines 1–120; `perl/LinkedSpec/StagedParseJob.pm` lines 1–352; `perl/LinkedSpec/StagedParseJobPolicy.pm` lines 1–59; `perl/LinkedSpec/StagedParserRegistry.pm` lines 1–328.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.48`
  Status: `pending`
  Goal: Read baseline Perl group 46: 521 lines/fragments, 16,259 bytes.
  Scope: `perl/LinkedSpec/Trace.pm` lines 1–521.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.49`
  Status: `pending`
  Goal: Read baseline Perl group 47: 1,500 lines/fragments, 32,073 bytes.
  Scope: `perl/LinkedSpec/UnicodeCaseMapping.pm` lines 1–1500.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.50`
  Status: `pending`
  Goal: Read baseline Perl group 48: 1,500 lines/fragments, 32,854 bytes.
  Scope: `perl/LinkedSpec/UnicodeCaseMapping.pm` lines 1501–3000.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.51`
  Status: `pending`
  Goal: Read baseline Perl group 49: 835 lines/fragments, 17,404 bytes.
  Scope: `perl/LinkedSpec/UnicodeCaseMapping.pm` lines 3001–3835.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.52`
  Status: `pending`
  Goal: Read baseline Perl group 50: 855 lines/fragments, 17,340 bytes.
  Scope: `perl/LinkedSpec/UnicodeXIDContinue.pm` lines 1–855.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.53`
  Status: `pending`
  Goal: Read baseline Perl group 51: 1,202 lines/fragments, 45,829 bytes.
  Scope: `perl/LinkedSpec/UserFunctionRegistry.pm` lines 1–773; `perl/PPlugin.pm` lines 1–331; `perl/PathSearch.pm` lines 1–47; `perl/env.conf` lines 1–51.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.54`
  Status: `pending`
  Goal: Read baseline Perl group 52: 839 lines/fragments, 22,702 bytes.
  Scope: `perl/gdcheck.pl` lines 1–431; `perl/htmlcss_driver.pl` lines 1–166; `perl/ptchange.pl` lines 1–242.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.3`
  Status: `pending`
  Goal: Split and read all 412 baseline Rust entries, including source, tests, corpus, generated files, and manifests.
  Acceptance: Define bounded file/range children before reading; `rgx` is excluded but first-party Rust is not.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.4`
  Status: `pending`
  Goal: Split and read all 115 baseline Dart entries, including compiler/runtime, tests, commands, and package inputs.
  Acceptance: Define bounded file/range children before reading and account for every path plus current deltas.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.5`
  Status: `pending`
  Goal: Split and read all 95 baseline Julia entries, including compiler/runtime, tests, commands, and package inputs.
  Acceptance: Define bounded file/range children before reading and account for every path plus current deltas.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.6`
  Status: `pending`
  Goal: Split and read all 99 baseline Lua entries, including native adapters, both-ABI tests, runtime, and commands.
  Acceptance: Define bounded file/range children before reading; generated tables and the large test runner stay in scope.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.7`
  Status: `pending`
  Goal: Split and read all 158 entries under specs, ebnf, noncore, conf, and tablescript.
  Acceptance: Account for legacy adapters, plugins, authored grammars, configuration, and non-TypeScript `.ts` data;
    use LinkedSpec probes before investigating a spec's behavior, and do not infer defects from historical syntax alone.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.8`
  Status: `pending`
  Goal: Split and read all 160 entries under capability_conformance, cli_conformance, t, tests, and unicode_case.
  Acceptance: Include phase0, neutral contracts, fixtures, generators, and four explicitly decoded pinned Unicode
    inputs. Keep generated/fixture bytes in scope; count neither a hash nor enumeration as full reading.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.9`
  Status: `pending`
  Goal: Split and read all 143 remaining repository-tooling entries from the exhaustive complement rule below.
  Acceptance: Include hooks, shell/Python/Perl tools, root configuration, command entrypoint, doctrine registry data,
    and the vendored Knowledge Map bundle. Reuse exact completed supporting ranges and read every remaining range.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.10`
  Status: `pending`
  Goal: Review root guidance and relevant durable owners using their prescribed reading or indexed-query lifecycle.
  Acceptance: Bind all 28 baseline root Markdown paths to their owners: complete remaining maintained architecture/
    user-guide text in bounded children; retain completed roadmap/bootstrap/Toolbox coverage; query generated
    Knowledge Map and immutable chronology instead of loading them wholesale. Memory records are not source-code coverage.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.11`
  Status: `pending`
  Goal: Reconcile complete source-reading coverage against baseline and final HEAD before closing codebase reading.
  Acceptance: Lanes `.3.2` through `.3.10` are complete; review all changed/new paths since baseline and resolve every unexplained
    omission or overlapping credit. The book's configuration/source remains `.4`-owned. All unverified findings
    have exact owners; read coverage is not runtime signoff.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.4`
  Status: `pending`
  Goal: Read the complete mdBook and check its explanations against the roadmap and codebase.
  Acceptance: Split by SUMMARY.md chapters and bounded ranges before execution; read every chapter and own any verified drift.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.5`
  Status: `pending`
  Goal: Complete supplied-policy adoption/update comparisons and the startup alignment review before implementation.
  Acceptance: Record local adoption evidence and applicable donor updates; own any required changes; confirm all three reading answers Yes, then route to repairs `.7`–`.14` before restoring RUST-MUTATION-TESTING.1.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.6`
  Status: `done`
  Goal: Reconcile managed-run liveness reporting across restricted and permitted process inspection.
  Acceptance: Use one known live controlled run and compare same-run read-only `--list`, PID/group probes, and
    permitted process inspection; record exact mechanism and locations. Any confirmed false-dead cleanup boundary
    receives a repair leaf and a non-destructive regression plan before recovery is used. No ambiguous deletion.
  Verification tier: `focused`
  Focused checks: Controlled repository-managed live-process probe; read-only restricted/permitted run and process inspection; exact liveness-owner source review; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — diagnostic evidence and startup tracking only; any repair requires a separate infrastructure leaf.
  Verification: Controlled 45-second managed run confirms restricted PID/group probes return errno 1 / EPERM
    while permitted probes return success for the same live PIDs. Restricted `--list` says abandoned; permitted
    `--list` says live. Exact source routes all failed kill-zero checks into false-dead recovery authorization.
    No recovery/deletion probe executed; the wrapper exited 0 and permitted census then found zero leftovers.
    Evidence and source locations: `docs/knowledge/project-data-liveness-permission-denial.md`.
  Commit: `SESSION-STARTUP-READING.6 - diagnose denied liveness probes`

- ID: `SESSION-STARTUP-READING.7`
  Status: `pending`
  Goal: Repair permission-denied liveness handling before any managed recovery or mutation workspace workflow.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; `.6` causal evidence.
  Acceptance: Distinguish confirmed absence from denied/unknown PID and group inspection; denied or unknown
    results must retain scratch. Cover wrapper, child, group, normal drain, recovery, and retained-failure purge
    with non-destructive deterministic EPERM/ESRCH tests and a live restricted-process control. Preserve positive
    dead-run cleanup, signal forwarding, PID-reuse conservatism, same-volume storage, and valid marker ownership.
    Update Toolbox/book/KM claims, run focused lifecycle/storage/dependent checks and exact canonical proof.
    Split into bounded children before implementation if needed; reading prerequisites remain mandatory.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.8`
  Status: `pending`
  Goal: Make bootstrap diagnostic comparison state describe the current invocation.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; `.7` cleanup safety repair precedes this repair.
  Acceptance: Reproduce successful comparison followed by unsuccessful comparison with the shared cache and
    an injected state. Clear stale comparison output on every attempt, including empty/undefined/throwing or
    unavailable comparison paths; preserve primary bootstrap behavior, recursion protection, and successful
    comparison capture. Add focused regression proof, review actual metadata consumers and public explanation,
    update Knowledge and continuity, and commit before returning to Rust mutation setup.
  Verification: `pending` — `.3.2.3` owns the non-destructive diagnostic evidence, not this repair.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.9`
  Status: `pending`
  Goal: Preserve regex-literal delimiters when reading attached conditional tails.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; repairs `.7` then `.8` precede this repair.
  Acceptance: Lock the observed truncated brace/parenthesis tails and public `matches("}", /}/)` failure with
    quoted-pattern controls. Repair lexical recognition using the established regex-versus-division contract;
    cover escaped slashes, character classes, nested delimiters, quoted text, and action/blind/lifecycle callers.
    Preserve full tail/source positions and exact diagnostics for malformed inputs. Check self-hosted grammar
    alignment, run focused direct/dependent proof, update book/Knowledge/continuity, and commit before mutation setup.
  Verification: `pending` — `.3.2.4` owns diagnosis; no repair is claimed before mandatory reading.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.10`
  Status: `pending`
  Goal: Eliminate unbound package-variable inputs from the AND_BCODE variant handoff.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; repairs `.7`–`.9` precede this repair.
  Acceptance: Reproduce the isolated argument/global differential from `.3.2.8`; the builder must depend only
    on explicit current inputs. Trace whether the legacy regex/I-block extension has any supported caller and
    either remove its dead handoff or wire supported data at the correct semantic boundary. Preserve ADR 0010
    entry-without-self-match and current blind-call/cursor ownership; do not enable parent regex matching merely
    by forwarding the missing fields. Lock private-state independence and relevant live/generated AND controls,
    reconcile accepted attached I-block behavior, update book/Knowledge as warranted, and commit before mutation
    setup. Split scope before implementation if cross-backend/public contract work is required.
  Verification: `pending` — `.3.2.8` proves the private handoff defect; no public result defect is yet claimed.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.11`
  Status: `pending`
  Goal: Correct validation diagnostic source context and rule attribution.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; repair `.10` precedes this activity.
  Children: `.11.1`, `.11.2`, `.11.3`

- ID: `SESSION-STARTUP-READING.11.1`
  Status: `pending`
  Goal: Return the actual next source line and preserve zero-valued text in DSL error context.
  Acceptance: Lock first/middle/last/empty/trailing-newline controls and the literal line `0`; correct
    get_dsl_context and its formatter without changing diagnostic position units or validation acceptance.
    Cover direct context, callback detail, and public Get runtime context; update book/Knowledge and commit.
  Verification: `pending` — `.3.2.9` proves current-line repetition and loss of literal `0`.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.11.2`
  Status: `pending`
  Goal: Report the actual physical occurrence of repeated source lines in validation failures.
  Dependencies: `.11.1`
  Acceptance: Replace content-based first-occurrence lookup with the current line's source offset across
    affected validator/reporting callers. Repeated identical headers must report the second definition;
    repeated text in comments/strings/body members must not steal an error position. Preserve Unicode/CRLF,
    same-line offsets, stable codes, and strict-mode behavior; run direct/public controls, update docs, and commit.
  Verification: `pending` — `.3.2.9` proves a line-4 duplicate reported at line 1.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.11.3`
  Status: `pending`
  Goal: Attribute invalid regex diagnostics to the containing rule during the regex-validation pass.
  Dependencies: `.11.2`
  Acceptance: Track the current regex-pass owner instead of retaining the final paragraph-pass rule.
    Cover first/middle/last rules, inline and following-line regexes, named/anonymous slots, callbacks,
    and public runtime context. Preserve rejection and codes; reconcile book/Knowledge, verify, and commit.
  Verification: `pending` — `.3.2.9` proves Top's invalid regex is attributed to Next.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.12`
  Status: `pending`
  Goal: Preserve authored execution order when bare and explicit edges share one ownership family.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; diagnostic repair activity `.11` precedes this repair.
  Acceptance: Lock the bare-before-explicit OR priority and AND child-order failures with all-bare,
    all-explicit, and explicit-before-bare controls. Normalize through one authored sequence so execution,
    dependencies, descriptor edges, and supported generated carriers agree. Preserve lifecycle-generated
    actions, grouped/indexed/named selectors, duplicate slots, repeated families, and mixed-ownership rejection.
    Verify native and emitted/loaded/trace routes plus direct-dependent conformance and backend comparison;
    update book/Knowledge and commit before mutation setup. Split bounded children before implementation if
    carrier/public work exceeds one safe slice. Do not change the existing authored-order contract.
  Verification: `pending` — `.3.2.11` proves native OR/AND failures and isolates the collection/normalization split.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.13`
  Status: `pending`
  Goal: Preserve attached code by blind-edge occurrence when a rule calls the same target more than once.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; authored-order repair `.12` precedes this repair.
  Acceptance: Lock repeated-target versus equivalent-distinct-target OR/AND controls. Preserve each occurrence's
    code and no-code identity through RuleIR, EmitContext, HandlerIR, dispatch, trace, and supported generated
    carriers; target names alone cannot select an occurrence. Cover different blocks, side effects, no-block
    entries, repeated families, first-match short-circuiting, cursor/recognition state, lifecycle code, and order.
    Verify native and emitted/loaded routes plus direct-dependent conformance and backend comparison; update
    book/Knowledge and commit before mutation setup. Split bounded children before implementation if carrier/
    public work exceeds one safe slice. Repeated targets must remain accepted with their own attached behavior.
  Verification: `pending` — `.3.2.13` proves native AND/OR failures and isolates hash overwrite plus name dispatch.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.14`
  Status: `pending`
  Goal: Preserve literal data and invocation-local result state in I-block and repeated-action emission.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; blind occurrence repair `.13` precedes this activity.
  Children: `.14.1`, `.14.2`

- ID: `SESSION-STARTUP-READING.14.1`
  Status: `pending`
  Goal: Rewrite executable I-block/repeated-action returns without modifying literals, identifiers, or nested return scopes.
  Acceptance: Lock selected per-regex I-block plain/return/returning payloads and explicit-edge controls, plus
    bounded REP plain/return/return-value cases. Cover all retained return-to-assignment emitter sites.
    Replace whole-string substitution with an appropriate structured or token-aware lowering boundary;
    preserve quote/regex/comment contents, escaped forms, identifiers, nested blocks/functions, actual return
    semantics, and capture bridges. Reconcile every retained AND I-block rewrite site with `.10` handoff
    decisions; prove native and emitted/loaded behavior plus direct-dependent conformance and backend comparison.
    Update book/Knowledge and commit. Split safe children first if the shared lowering change exceeds this slice.
  Verification: `pending` — `.3.2.14` captures I-block literal corruption; `.3.2.15` proves bounded REP corruption too.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.14.2`
  Status: `pending`
  Goal: Make generated single-acode AND I-block and repeated-acode result storage invocation-local.
  Dependencies: `.14.1`
  Acceptance: Give each invocation its own internal result slot without changing the rule accumulator or
    authored variable identity. Prove package-state independence, no writes to the SpecEntry package slot,
    repeated same-parser and cross-parser calls, recursion, Unicode labels, I-plus-edge collection, and all
    retained handler variants. Verify native/emitted-loaded routes and direct-dependent matrices, update
    book/Knowledge, and commit before mutation setup. Preserve recognition/cursor and return-shape contracts.
  Verification: `pending` — `.3.2.14` proves I-block package dependency; `.3.2.15` also proves REP package writes on plain literals.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.15`
  Status: `pending`
  Goal: Preserve the containing ActionIR coordinate space through every nested block parser call.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; return/scope repairs `.14` precede this repair.
  Acceptance: Lock eager-brace, attached function-call, and attached control-body offsets with nonzero bases,
    nested levels, leading whitespace, duplicate statement text, Unicode scalars, and CRLF. Preserve correct
    callable-literal, receiver trailing-block, and map_leaves! callback paths. Assert successful AST child spans
    and exact typed syntax/runtime diagnostic spans against authored substrings; verify direct AST, public Get,
    supported generated carriers, and direct-dependent conformance. Preserve rejection, statement semantics,
    diagnostic object payloads, and source-coordinate contracts. Update book/Knowledge and commit before
    mutation setup; split safe children before implementation if public/carrier work exceeds one slice.
  Verification: `pending` — `.3.2.16` proves three omitted base_start handoffs and passing adjacent controls.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SESSION-STARTUP-READING.3.2.21` | `pending` | Finish ControlFlow and read DeclareMethod, Diagnostics, and FlowExpr. |

## Reading Ledger

All line ranges below refer to the **reading baseline**, not later shifted working-file line numbers. Files
modified by this checkpoint must also be reviewed in the final diff. Unlisted source files and unlisted ranges
remain unread; running a command that prints a file does not establish comprehension if its output was truncated.

| Required surface | Fully read and understood? | Completed at checkpoint | Remaining |
| --- | --- | --- | --- |
| Roadmap | **Yes** | `ROADMAP.md` 1–2564; `ROADMAP_V2.md` 1–1585. `.2` read 1341–1380, 1381–1420, 1421–1470, 1471–1530, and 1531–1585 without truncation and reviewed both current roadmap diffs. | Review later changes as they land; codebase/book alignment remains gated on their reading. |
| Codebase | **No** | Twenty-five Perl files in full plus ControlFlow.pm 1–1485 under `.3.2.20`; supporting reads below. | ControlFlow suffix, the other 63 Perl paths, and all other first-party inputs not explicitly listed as read. |
| mdBook | **No** | `docs/linkedspec-book/src/SUMMARY.md`; `docs/linkedspec-book/src/development/local-ci-and-regression.md` 1897–1943 and 1988–2004. | All other chapter text, including the unread portions of that development chapter. |

The exact tracked file population and object identities are recoverable without an independently maintained
manifest or an absolute checkout path:

```bash
git ls-tree -r --full-tree baeb984e36a94a15951cd23d4c52def5064cdaca
git ls-tree -r --name-only baeb984e36a94a15951cd23d4c52def5064cdaca -- docs/linkedspec-book/src
git show baeb984e36a94a15951cd23d4c52def5064cdaca:ROADMAP_V2.md | sed -n '1341,1400p'
```

The recursive tree command does not descend into the `rgx` gitlink. During `.3`, classify the whole first-party
inventory, including files outside the obvious language directories; a language-directory census alone is not
complete codebase coverage. Generated source and fixtures are not silently excluded by a file-extension filter.
After a later commit, use `git diff --name-only` against this baseline to identify changed reading inputs; review
the changed portions as well as remaining baseline text. Immutable historical task parts use their indexed
retrieval contract rather than an indiscriminate chronology scan.

### Bootstrap and focused supporting material already read

- `README.md`, `MEMORY_ARCHITECTURE.md`, `MEMORY.md`, `SESSION_BOOTSTRAP.md`, `COMMIT.md`, and local `README_POLICY.md`.
- The supplied `AGENTS.md` instructions and `docs/TASK_TREE_README.md` in full; task-index purpose, active-frontier
  context, and operating rules at `docs/TASK_TREE.md` 3269–3525. The large embedded historical marker section has
  not been read in full.
- `docs/tasks/TEMPLATE.md`, `docs/tasks/RUST-MUTATION-TESTING.md`, and `docs/decisions/0039-rust-mutation-testing-cadence.md`.
- Knowledge cards `rust-mutation-testing-policy`, `bounded-live-document-store-contract`, and
  `verification-cadence-policy` in `docs/knowledge/`. Knowledge Map searches are retrieval, not a full-map read.
- `.githooks/pre-commit`, `.githooks/post-commit`, `.githooks/commit-msg`, `scripts/check_memory_architecture.sh`,
  `scripts/check_verification_cadence.sh`, `scripts/check_task_tree_metadata.sh`,
  `scripts/check_doctrines.sh`, `scripts/check_diagnosis_evidence.sh`, and `tools/check_memory_handoff_state.py`.
- Current `LIVE_ACHIEVEMENT_STATUS.md` in full; `CHANGES.md` and `DEVELOPMENT_NOTES.md` baseline lines 1–100.
  Their older chronology is not fully read; use the indexed history query when historical evidence is needed.
- The director-supplied fsmgen README policy, pgen claim-verification policy, and fsmgen live-document containment
  adoption guide were read in full through explicitly authorized read-only access. Their local adoption/update
  comparisons remain `.5`; reading a donor document does not establish local compliance.
- `TOOLBOX.md`, `ARCHITECTURE_STATE.md`, remaining owner modules, and the full book have not been read in full.
- `.2` additionally read `TOOLBOX.md` 1–125, 605–682, and 1703–1792; `tools/project_data_env.sh` 1–100;
  `tools/project_data_run.sh` 1–190; ADRs `0001`/`0073`; and knowledge card `project-data-descendant-liveness-gap`.
- During the `.2` commit and `.6` diagnosis, additional reading completed `TOOLBOX.md` 126–604 and 683–825,
  plus `tools/project_data_run.sh` 191–355 (EOF). Thus Toolbox coverage is 1–825 and 1703–1792, and the
  managed-run wrapper is fully read. Its new causal finding is recorded separately; other code remains unread.
- `.6` also read `tools/test_project_data_lifecycle.sh` 1–441 (EOF): existing live/dead/recovery/marker tests
  run with ordinary permitted liveness and do not inject denied PID/group inspection. This is source review,
  not a fresh run of that destructive fixture suite.
- `.3.1` completed `TOOLBOX.md` in full through baseline EOF 1864, and read `unicode_case/README.md` in full.
  Four gzip payloads were decompressed only for counts; their contents remain unread. Reviewed the existing
  `linkedspec-pm-is-thin-facade` fact card to select the first code-reading boundary without re-deriving its facts.

### Complete baseline classification at `.3.1`

Baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`. `git ls-tree -r --full-tree` plus
`git cat-file --batch` measured the exact stored objects, not changing worktree bytes. Apply these ordered
path rules; the final complement explicitly owns every otherwise unmatched path.

| Class / path rule | Entries | Stored blob bytes | Reading owner |
| --- | ---: | ---: | --- |
| Exact `rgx` gitlink | 1 | 0 | Director-excluded, including nested dependencies |
| Prefix `docs/linkedspec-book/` | 50 | 1,956,582 | `.4`, including book configuration and all chapter text |
| Remaining prefix `docs/` | 1,197 | 20,123,040 | Durable memory; retrieve relevant owners and indexed history, not codebase reading |
| Root `*.md` (no slash) | 28 | 7,672,599 | `.3.10`, roadmap `.2`, and prescribed memory lifecycles |
| Prefix `perl/` | 89 | 2,133,690 | `.3.2` |
| Prefix `rust/` | 412 | 3,533,382 | `.3.3` |
| Prefix `dart/` | 115 | 2,471,305 | `.3.4` |
| Prefix `julia/` | 95 | 2,693,170 | `.3.5` |
| Prefix `lua/` | 99 | 2,732,450 | `.3.6` |
| Prefix `specs/`, `ebnf/`, `noncore/`, `conf/`, or `tablescript/` | 158 | 964,256 | `.3.7` |
| Prefix `capability_conformance/`, `cli_conformance/`, `t/`, `tests/`, or `unicode_case/` | 160 | 5,422,313 | `.3.8` |
| Every remaining baseline path | 143 | 2,381,957 | `.3.9`: `.claude`, `.github`, `.githooks`, five root dotfiles, `bin`, `doctrine`, `knowledge-map`, `scripts`, `tools` |
| **Total** | **2,547** | **52,084,744** | Every entry accounted for once |

The eight source/tool/fixture lanes contain 1,271 entries / 22,332,523 stored bytes. Of these, 1,267 are text
with 565,122 newline delimiters. Four pinned Unicode gzip inputs are the only NUL-containing blobs; they add
54,500 decoded newline delimiters / 3,352,036 decoded bytes and remain explicitly in `.3.8`. This count is an
inventory, not evidence that any of those lines was understood. Generated Unicode modules, generated MCP
bindings, corpus JSON, and large phase0/runtime files are not silently excluded.

Each future reading leaf names exact paths and inclusive ranges **before** execution, totals at most 1,500
decoded text lines and 65,536 bytes, and uses smaller output chunks to avoid truncation. Oversized files split
at coherent declaration/test boundaries within those limits; a single over-limit line uses explicit byte
ranges. Record all unread suffixes before advancing. Do not duplicate the full immutable inventory into a new
manifest; recover membership from baseline plus these disjoint selectors and recover identities from Git.

`.3.2.1` is exactly 1,430 lines / 56,706 bytes across five files. Its `LinkedSpec.pm` reread checks owner
relationships despite prior facade coverage. Other inputs remain unread unless listed above. At clean
`03d692c13bbc49590f318dd4c8536008d9f979f5`, the ten changed/new paths since baseline are continuity/Knowledge/task
records; all source/test/spec/tool inputs and all book files remain unchanged. Every checkpoint's own final diff
is reviewed separately.

### Shared Perl-reading acceptance and decomposition at `.3.2.2`

The 52 pending siblings `.3.2.3`–`.3.2.54` own all 84 remaining baseline Perl paths / 2,076,984 bytes exactly
once. Each Scope uses inclusive, one-based baseline line or byte ranges; byte offsets start at the beginning
of the named blob. The five `.3.2.1` paths are excluded by exact name. The first group follows the facade's
resolution/loading dependencies. Large modules split at declarations or blank statement boundaries where
possible; generated table rows remain complete records. Every suffix is owned, and every leaf fits the
1,500-line / 65,536-byte limit. Reading uses smaller untruncated output chunks within that scope.

`MCPContract.pm` line 14 is an 82,883-byte generated payload: `.3.2.35`–`.3.2.37` own its three byte fragments.
The preceding 13 lines and following seven lines remain explicitly owned. These byte fragments intersect the
same logical line, so summing per-leaf line/fragments is not a distinct-line total. No generated JSON is omitted.

For every reading child: activate its existing task owner first; retrieve the relevant Knowledge owner before
interpreting code; read every scoped byte without truncation; reconcile comprehension and record exact
coverage; diagnose surprising behavior with Toolbox probes and own any repair; review baseline/current deltas;
record focused changed-surface checks and required memory/doctrine/history proof; update continuity and commit
before advancing. Reading alone is not runtime signoff. Public/book changes remain conditional on material
public findings and the startup authorization boundary. No code or book reading credit comes from this plan.

Independent verification converts all declared line ranges to baseline byte intervals and requires contiguous,
non-overlapping coverage from byte 1 through EOF for all 84 paths, no extra path, and each declared leaf budget.
This plan adds no second manifest: the owned task Scope fields are the reading plan; Git remains the file/object
inventory. Final `.3.11` still reconciles all first-party lanes and current deltas.

### Facade invocation reading at `.3.2.1`

- Completed `perl/LinkedSpec.pm` 1–296, `perl/LinkedSpec/OwnerDispatch.pm` 1–220,
  `perl/LinkedSpec/Runtime.pm` 1–154, `perl/LinkedSpec/ParserFactory.pm` 1–368, and
  `perl/LinkedSpec/RuntimeContext.pm` 1–392, each through EOF without truncation. All five remain byte-identical
  to the baseline; this is five unique Perl files, not five newly unread files plus the earlier facade credit.
- Understanding agrees with `docs/knowledge/linkedspec-pm-is-thin-facade.md`: public wrappers normalize and
  delegate; `OwnerDispatch` resolves lazy callbacks/bundles and preserves successful caller error/context;
  `ParserFactory` resolves/loads named source through injected owners; `Runtime` delegates compiler work;
  `RuntimeContext` owns identity, source capture, and structured diagnostics/fallback precedence.
- The public runtime wrapper resets the input position and skips leading blank/comment lines. Retrieved
  `docs/knowledge/ds-vhistory-leading-newline-oracle-boundary.md` before interpreting that behavior: it is an
  already-owned cross-backend public-versus-direct-handler boundary, not a new defect from this reading.
- Descriptor, parser, and mode-only return shapes are deliberately distinct; early factory errors and deeper
  compiler errors retain their intended attribution. This reading does not validate every dependency's behavior;
  those remaining owners stay in subsequent bounded leaves.
- Source identity and both managed syntax checks pass. No new causal fact beyond the retrieved owners, no
  production/public change, and no fresh behavioral-conformance claim results from this reading checkpoint.

### Resolution and bootstrap adapter reading at `.3.2.3`

- Read `Resolver.pm` 1–223, `SpecLoader.pm` 1–352, `EntryRuleSelection.pm` 1–74, `GeneratedSource.pm` 1–319,
  and `BootstrapSpec.pm` 1–135, all under `perl/LinkedSpec/`, through EOF without truncation. The five files
  total 1,103 lines / 36,759 bytes and remain baseline-identical. Ten unique Perl files are now fully read.
- Retrieved the existing portable/legacy resolution, root selection, generated-v2, self-hosted grammar, and
  dual-path bootstrap cards before interpreting those boundaries. Resolver retains legacy local/PathSearch
  discovery; SpecLoader uses explicit ordered candidates, strict preserved UTF-8, typed results/errors, and
  compiler identity. Entry selection preserves authored order/markers. GeneratedSource derives cursor policy
  from ten families and validates contract then rows. Bootstrap primary output remains authoritative.
- The shared bootstrap comparison result survives an empty later comparison. Exact managed probes establish
  one initial row, zero negative rows, retained old array identity, and replacement on a later positive control.
  Public Get separately rejects malformed source at validation. No primary parser or public exposure defect is
  claimed. `docs/knowledge/bootstrap-comparison-stale-result.md` records mechanism/evidence; `.8` owns repair.
- No additional source-reading credit is inferred from the consumer grep or runtime probes. Remaining reading
  starts at `.3.2.4`; source repairs `.7` then `.8` follow `.3`/`.4`/`.5` and precede Rust mutation setup.

### Bootstrap grammar core reading at `.3.2.4`

- Read `perl/LinkedSpec/BootstrapSpec/Core.pm` through EOF in exact chunks 1–300, 301–600, 601–900, and
  901–1196: 1,196 lines / 39,291 bytes, baseline-identical. Eleven unique Perl files are now fully read.
- Reconciled the primary bootstrap/secondary self-hosted boundary with existing Knowledge. The core builds
  ordered token handlers, rule/brace dispatch, authored selectors, mode bounds, lifecycle/action/blind/bare-edge
  payloads, and method-chain rendering. It does not replace the permanent self-hosted language owner.
- Investigated the suspect slash-quote branch instead of classifying it without tools. Direct attached-tail
  probes show quoted braces preserved and regex closing braces/parentheses truncated; helper lowering confirms
  the regex match expression itself is supported. Public descriptor creation succeeds for both pattern forms,
  but execution returns 1 for the quoted twin and undef with `rule_handler_compile` for `/}/`.
- The prefix includes the opening delimiter, making the empty-prefix slash-quote condition unreachable. Exact
  offsets, source locations, public control, and limited scope are in
  `docs/knowledge/bootstrap-conditional-regex-delimiters.md`; `.9` owns repair after `.7`/`.8` and required reading.
- An initial inline probe used the wrong Perl quote delimiter and failed to parse; the corrected `q~...~`
  harness completed successfully. This harness error is not a repository defect. All probe jobs are consumed.
- No production or book change; remaining reading starts at `.3.2.5`. The source-reading gate remains No.

### Compiler state and required history rollover at `.3.2.5`

- Read `perl/LinkedSpec/CompilerState.pm` through EOF in 1–300 and 301–590 chunks: 590 lines / 23,054 bytes,
  baseline-identical. Twelve unique Perl files are fully read; 77 baseline Perl files remain unread.
- Existing `compilerstate-internal-model`, resolved descriptor-model-tag, and outward-versus-semantic-wire cards
  reconcile state construction, definition/compiled ordering, function projection, migration-summary shaping,
  dependency maps, validation views, and the four-key outward projection. Host regex/callable values remain an
  intentional native boundary. This reading establishes no additional defect or runtime-completion claim.
- The complete six-line changelog record takes the root to 465/512 lines; the required rollover archives 218
  clean-HEAD suffix lines / 20,348 bytes as segment `4985` and leaves 247 lines / 21,550 bytes. Independent
  byte comparison and SHA-256 prove exact activation source lines 242–459 with no prior segment edits.
- Normalized the current view's trailing blank line for `git diff --check`; the candidate root is 246 lines /
  21,549 bytes. The immutable suffix remains byte-identical; only current-view EOF whitespace changed afterward.
- The resulting history needs 28 files and 27 manifest lines. ADR `0102` admits exactly those two finite counts
  under existing README/history policy, preserving all byte/current-view/aggregate ceilings and authority. This
  required checkpoint-storage maintenance stays within startup continuity; donor-policy adoption and product
  changes remain gated. The registry movement makes this leaf canonical, with an exact staged receipt before commit.

### Compiler generation/state prefix and preceding canonical evidence at `.3.2.6`

- Activated from clean `6c1234cc0fd3cb194c6d75314d86bfe05da104a0` with the prior canonical receipt promoted,
  all nine commit doctrines PASS, empty message file, and no remaining job. Read Compiler.pm 1–260, 261–520,
  521–780, and 781–1041 without truncation: 1,041 lines / 41,073 bytes, baseline-identical. Its 1042–2002
  suffix remains `.3.2.7`; twelve whole Perl files and this partial thirteenth file are covered.
- Reconciled generated-v2 plan/entry serialization, execution-only dependency-slot rows, invocation-local sinks,
  enrichment and typed error forwarding, callback/parsed-entry diagnostics, CompilerState assembly/projection,
  dependency validation, and parsed label/slot/root metadata with existing Knowledge. No new runtime defect.
- The older identical-regex risk card still described an open finding despite its linked family's 2026-07-20
  Perl admission and complete portable rollout. Its title/status and explicit resolution pointer now mark the
  retained diagnosis as historical; the original evidence remains intact. The prior canonical run freshly
  passed the 12-role Perl duplicate-slot consumer. Public semantics and book teaching did not change.
- Preceding `.3.2.5` default canonical CI passed, including the mandatory backend admission consumers,
  relocation/process containment, primary CLI 66/66 in both option environments, and Phase 0 1,032/1,032 in
  1,121 wall seconds. Separately opt-in local gates and recurring matrices were not enabled. The staged receipt
  bound base `4f311a9e` to SHA-256 `775ebdf60905a47393731db24c50de74c1037d77fe32d6eca8abc3e8b5d9a12a`
  and was promoted to `6c1234cc`. No tracked candidate changed while that run was active.
- Existing macOS launch-latency Knowledge now preserves the 2026-09-06 / macOS 26.6.2 compiler `dlopen`/`fcntl`
  and test `_dyld_start` samples, eventual passing execution, and the older controlled conclusion's OS-specific
  boundary. Exact sample hashes were verified before deleting only the two consumed reports; both paths are
  absent. No recovery/purge, target cleanup, re-signing, or trust bypass was used.
- Supporting reading additionally covers tools/verification_receipt.sh 1–150 (EOF) and the two Cargo-child
  call sites in rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs 2072–2115 and 2217–2252.
  These bounded supporting reads do not mark the remaining Rust file or tool lane complete.

### Compiler pipeline suffix at `.3.2.7`

- Activated from clean `f864f881f5210a99d68602166e8720a741f84795`; prior Knowledge/all nine doctrines,
  post-commit pointer, empty brief, and clean status passed. Read Compiler.pm 1042–1280, 1281–1520,
  1521–1760, and 1761–2002 without truncation: 961 lines / 43,851 bytes. The complete module is now read
  at 2,002 lines / 84,924 bytes; thirteen whole Perl files are covered and 76 remain.
- Reconciled runtime-context preparation, function stripping/registry attachment, envelope/DSL/bootstrap stages,
  descriptor-state/reference validation, policy passes, source flush, return-mode precedence, root attribution,
  and invocation error preservation with existing Knowledge and ARCHITECTURE_STATE.md 4571–4623.
- The new `perl-compiler-pipeline-stage-and-mode-boundaries` card indexes the precise phase/stop/return
  boundaries absent from the question map. It links existing state/root/generated/runtime owners and explicitly
  records source-level evidence without a new runtime signoff claim. No new defect or public-book change.
- Next exact reading is SpecEntry.pm 1–600 under `.3.2.8`. Required codebase/book reading remains incomplete.

### SpecEntry reading and explicit handoff defect at `.3.2.8`

- Activated from clean `dc7f5f090c078d0d3d05886eec371db89bfae625`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, clean status, and derived-map review passed. Read SpecEntry.pm
  1–200, 201–400, and 401–600 without truncation: complete 600 lines / 23,171 bytes. Baseline identity
  passes; fourteen whole Perl files are covered and 75 remain. No product source changed.
- Reconciled RuleIR/EmitContext orchestration, HandlerIR selection/emission, preamble authority/recognition/gaps,
  lexical working variables, labeled compile/runtime diagnostics, balanced recursion keys, and typed/control
  exception routes. The two older SpecEntry coupling cards explicitly retain their original evidence as history
  and point to current owners. This does not reopen already completed native backend rollout.
- Isolated emitter interception proves the AND_BCODE branch reads package `REs`/`and_icode`, not caller lexicals
  or explicit arguments. With normal package state both optional fields are absent; localized package state
  injects both. The single-acode node retains its supplied argument. A public descriptor/source control selects
  AND_BCODE and emits the blind child loop without the legacy match section. No public result failure is claimed.
  `specentry-and-bcode-unbound-inputs` preserves exact controls and causal locations; `.10` owns repair after
  reading and `.7`–`.9`, with entry-without-self-match and blind-call semantics required to remain correct.
- Supporting HandlerVariantEmitter.pm reads are exactly 100–176 and 804–880 (baseline-identical); all other
  emitter text remains unread under its existing children. Probe processes exited zero; no background job remains.
- Next reading: Validation.pm 1–1320 under `.3.2.9`; codebase and book answers remain No. Public-book review
  of the diagnosed handoff follows complete reading and repair; no behavioral change is made in this checkpoint.

### Validation prefix and diagnostic source repairs at `.3.2.9`

- Activated from clean `e4b1f296910e73205f2ea8a2498a14040b1ff381`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, and clean status passed. Read Validation.pm 1–220, 221–440,
  441–660, 661–880, 881–1100, and 1101–1320 without truncation: 1,320 lines / 43,290 bytes,
  baseline-identical. Fourteen full Perl files plus this prefix are covered; suffix 1321–1904 remains unread.
- Reconciled envelope/markerless acceptance, rule-definition/dependency validation views, named-slot and gap
  metadata checks, paragraph/block/edge validation, regex pass, strict authored-edge graph, and lifecycle/header
  scanners with existing compiler-state, root, open-block, and gap owners. Reading is not broader runtime signoff.
- Direct context/formatter probes show current-line repetition as Next and literal `0` erased as current text.
  Validator callbacks and public Get context show a line-4 duplicate attributed to line 1 and Top's invalid regex
  attributed to Next. Invalid inputs still reject. The causal card `perl-validation-diagnostic-source-drift`
  and `.11.1`–`.11.3` own separate context/occurrence/regex-owner repairs after reading and `.7`–`.10`.
- The preceding derived-map review exposed literal block-scalar pipes in the old coupling card's evidence and
  reverify fields. Scalar metadata now exposes the actual current owner command while preserving historical body
  evidence. The open-block card's reverify no longer supplies removed parse_mode; its direct-validator command
  passes and reaches the documented line-3 failure. These are retrieval corrections, not a new syntax contract.
- All diagnostic processes exited zero. Next reading is Validation.pm 1321–1904 under `.3.2.10`; codebase/book
  remain incomplete, product source is unchanged, and public-book changes remain with the owned repairs.

### Validation suffix at `.3.2.10`

- Activated from clean `96a1c2426ce68cf5f7b9281dbeb3005d3d876fd9`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, clean status, and derived-map review passed. The prior retrieval fixes
  now appear as actual commands/evidence in the derived map. Read Validation.pm 1321–1520, 1521–1720, and
  1721–1904 without truncation: 584 lines / 18,639 bytes. The full baseline-identical module is now read
  at 1,904 lines / 61,929 bytes; fifteen whole Perl files covered and 74 remain.
- Reconciled quote/slash skipping, cross-line depth, static edge/selector/group/fluent parsing, slash-call
  delegation, substitute/translate segments, and targeted diagnostic payloads with existing edge, arithmetic,
  rule-local, and gap owners. The earlier diagnostic defects remain owned under `.11`; no new runtime defect
  is established by this suffix. This source reading does not claim fresh backend or parser signoff.
- The edge Knowledge card clarifies the already-supported blind-return block and points its dated bare-edge/gap
  staging notes to the existing admitted owners. Legacy split-marker divergence remains the explicit
  compatibility boundary in the gap closeout card, not an unowned new finding or a capture_gaps alias.
- Next exact reading is RuleIR.pm 1–987 under `.3.2.11`; required codebase/book reading remains incomplete.

### RuleIR reading and authored execution-order defect at `.3.2.11`

- Activated from clean `ff6c228c7804270916b64a7c9332be92a5df1f76`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, and clean status passed. Read RuleIR.pm 1–200, 201–400, 401–600,
  601–800, and 801–987 without truncation: complete 987 lines / 31,462 bytes, including EOF and unchanged
  from baseline. Sixteen whole Perl files are covered and 73 remain.
- Reconciled handler-family selection, trace decisions, authored top/regex/slot/lifecycle collection, legacy
  marks, bare normalization, selector authority, resolved metadata, gap eligibility, and mixed-ownership
  rejection with existing root, rule-local, gap, SpecEntry, and trace owners.
- Public OR spelling controls prove that bare First before explicit Second reverses dependency order and
  returns second, while explicit/bare, all-bare, and all-explicit return first. Every metadata edge sequence
  still says First, Second. AND bare First before explicit Second returns second, first. A direct RuleIR
  probe isolates explicit collection followed by bare append during normalization, independent of later
  emission. `perl-bare-explicit-edge-order-drift` preserves exact probes and causal boundaries; `.12` owns
  repair after reading and `.7`–`.11`, preserving authored order, lifecycle actions, and native/carrier parity.
- These are native/public and direct-owner results; generated/other-backend failure was not measured here.
  All probe processes exited zero. Next reading is RuleIR/EmitContext.pm 1–1489 under `.3.2.12`;
  codebase/book remain incomplete and source remains unchanged until the required-reading boundary closes.

### EmitContext bridge prefix at `.3.2.12`

- Activated from clean `3ab399d034f34029ac136a31a7b252a7dd8d31cc`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, clean status, and derived-map review passed at 948 facts / 8,018 keys.
  Read EmitContext.pm 1–220, 221–435, 436–680, 681–915, 916–1155, 1156–1375, and 1376–1489
  without truncation: 1,489 lines / 49,396 bytes. Full-file baseline identity passes; sixteen whole Perl
  files remain covered, with EmitContext's 1,094-line suffix still owned by `.3.2.13`.
- Reconciled lazy owner/callback loading, caller-context dispatch, dependency injection, type-memory and
  write-target collection, lowering wrappers, trace decisions, compatibility fallback, and code-chunk joining
  against existing EmitContext/ActionIR cards. Source comprehension is not fresh runtime signoff.
- Exact bounded registry extraction returns fourteen keys: thirteen ActionIR packages plus Trace. The original
  registry card already listed fourteen names but said thirteen; its count and ineffective mention-counting
  reverify are corrected, and the adjacent lowering card distinguishes the thirteen-owner subset. No production
  defect or public contract change is established here; existing repairs `.7`–`.12` remain gated on reading.
- Next exact scope is EmitContext.pm 1490–2583 under `.3.2.13`; codebase/book reading remain incomplete.

### EmitContext suffix and repeated blind-target identity at `.3.2.13`

- Activated from clean `5e2cf75632f1fd16c3e94fac0f610ee572ea3e26`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, clean status, and complete derived-map review passed (948 facts /
  8,018 keys). Read 1490–1699, 1700–1910, 1911–2110, 2111–2300, 2301–2495, and 2496–2583
  without truncation: 1,094 lines / 46,079 bytes. EmitContext is fully read at 2,583 lines / 95,475 bytes;
  seventeen whole Perl files are covered and 72 remain. Full EmitContext/emitter baseline identity passes.
- Reconciled action/dependency projection, lifecycle rewriting, readiness/compatibility telemetry, literal
  masking, AST/text working-variable discovery, declaration deduplication, child-push binding harmonization,
  write-presence state, and final context assembly with existing owner/AST/non-strict-scope cards. Historical
  declaration examples are not treated as current syntax or a fresh audit of unread ActionIR modules.
- Repeated-target probes confirm a distinct occurrence-identity defect: regex-consuming OR Child/Child yields
  [second], while equivalent Child/Other yields [first]. Immediate-return AND controls yield scalar second
  versus first. The descriptor keeps both explicit blind edges; emitted source repeats the last code in both
  name-based branches. Direct `_rewrite_bcode_entries` returns two Child calls but one final code value.
- Supporting HandlerVariantEmitter.pm 515–590 was read without truncation; prior 100–176 and 804–880 coverage
  remains valid, while other emitter ranges remain unread. `_build_bcodes_dispatch_block` independently keys
  retrieval and branch conditions by target name. Repair `.13` therefore owns storage and occurrence dispatch,
  native/carrier/direct-dependent/backend proof, and book reconciliation after reading and `.12`.
- Initial diagnostic outputs were not retained to completion and are excluded from evidence. A permitted
  process census found no remaining task-owned probes before the retained rerun; all retained direct/public
  probes subsequently completed with exit zero. OR with I-only children returned null in both variants, so it
  was replaced by a regex-consuming positive control rather than counted as an OR identity result. No liveness
  recovery or purge was used, and no background job remains at this checkpoint.
- `perl-repeated-blind-target-code-collision` preserves exact native results and causal boundaries. Emitted
  source was inspected but not independently loaded here; other-backend failures remain unmeasured. Next
  exact reading is HandlerVariantEmitter.pm 1–1403 under `.3.2.14`; codebase/book remain incomplete.

### HandlerVariantEmitter prefix and I-block corruption at `.3.2.14`

- Activated from clean `a7d17e6fcb4e6deafc8b3b2c46c957fa8f09e8b0`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, clean status, and derived-map review passed (949 facts / 8,022 keys).
  Read 1–215, 216–420, 421–645, 646–840, 841–1035, 1036–1235, and 1236–1403 without truncation:
  1,403 lines / 53,304 bytes. A truncated combined initial output was replaced by the exact 1–215 reread;
  full emitter baseline identity passes. Seventeen whole Perl files remain covered; the suffix is `.3.2.15`.
- Reconciled ten variant builders, bounds, slot identity/observation, acode/bcode dispatch, trace helpers,
  backend/kind dispatch, default/AND/OR templates, and repeated-blind choice with existing HandlerIR, root,
  slot, trace, and earlier defect owners. Direct builder proof retains Perl strings and cursor_policy;
  unknown private backend/kind returns undef. The old HandlerIR card now distinguishes its historical catalog
  from current field/dispatch/payload boundaries. Source header/comment reconciliation follows the final read
  alignment in `.5`; no new backend route or changed public contract is claimed.
- Public selected I-block source `Top::AND /x/ I { value = "return"; return(value) }` followed by an explicit
  `-> Top { return(value) }` edge corrupts literal data. Plain/return/returning cases in one process yield
  plain, `plain = `, and `plain =  = ing`. Source capture shows `$value = "$Top = "; $Top = $value`.
  Both textual I-block return-rewrite sites ignore literal and trailing token boundaries.
- A retained same-parser/input seed control localizes only `LinkedSpec::SpecEntry::Top`: seed_one and seed_two
  produce and overwrite the package slot with `seed_one = ` and `seed_two = `. Captured source has one
  array Top declaration and zero scalar Top declarations. The single-acode internal I-result is a package
  variable; `.14.1` owns literal-safe lowering and `.14.2` owns invocation-local state with independent proof.
- I-only probes had no outgoing selector, selected no executable handler, and returned zero; they do not
  activate the per-regex match path and are excluded from literal-preservation evidence. This agrees with
  the existing no-self-match entry invariant. The explicit-edge literal control returns return unchanged.
  The old indexed two-edge AND reverify returns 1 after removing retired parse_mode, so that fix stays closed.
- Retained processes all exited zero and no diagnostic job remains. New Knowledge preserves exact result/
  source/seed boundaries. Emitted source was inspected, not independently loaded; no other-backend failure
  is claimed. Next `.3.2.15` reads emitter 1404–1920 plus LinkedRE/ActionIR AST; codebase/book remain incomplete.

### Emitter suffix, LinkedRE, and AST facade at `.3.2.15`

- Activated from clean `e421887d7c4ccf5a3a7714bd9a9b74b2fc7e40c1`; prior Knowledge/all nine doctrines,
  post-commit pointer, zero-byte brief, clean status, and complete derived-map review passed (950 facts /
  8,026 keys). Read emitter 1404–1585, 1586–1760, 1761–1920, plus LinkedRE.pm 1–148 and
  ActionIR/AST.pm 1–71 without truncation: 736 lines / 24,430 bytes. All three full-file identities match
  baseline. Twenty whole Perl files are now read and 69 remain.
- Reconciled repeated AND/blind/action loops, bounds/progress/recognition/capture-gap placement, JSON field
  projection, seek/consume matching, capture snapshots, ordered-slot validation, alternation, source-span/node
  constructors, and lazy AST-parser dispatch with existing emitter, duplicate-slot, and AST owners. The old
  identical-regex defect stays resolved through match_slot; AST implementation remains unread after its facade.
- Bounded `Top::OR{2,2} /x/ -> Top { return("return value") }` on xx confirms the same literal/state
  mechanisms as `.14`. With package Top seeded to seed_one, results are [seed_one = value, seed_one = value
  = value]; seed_two analogously changes both outputs. Source captures `$Top = "$Top = value"` with no scalar
  lexical. Plain and unspaced return controls preserve both data items but overwrite package Top, independently
  proving ambient writes. All six result cases complete two matches; no unbounded-loop claim is made.
- Existing `.14.1`/`.14.2` and the same fact card now cover repetition as well as selected I-blocks. The REP
  substitution requires trailing whitespace; unlike the I-block substitution, an unspaced return literal is
  not changed. Native/source/seed evidence does not claim independent generated loading or backend failure.
- Direct diagnostic JSON projection keeps kind/label/cursor_policy/acodes but omits supplied and_icode,
  capture_gaps, and required_slot_count; the HandlerIR card now explicitly describes a selected-field
  diagnostic, not lossless roundtripping. Every retained probe exited zero; no job remains. Next exact reading
  is ActionIR/AST/Parser.pm 1–1498 under `.3.2.16`; required codebase/book reading remains incomplete.

### AST parser prefix and nested source offsets at `.3.2.16`

- Activation checkpoint is clean `762bef64659f48ccada872ec76ac150a0b6714ed`; prior slice's nine doctrines,
  post-pointer, zero-byte brief, clean status, and full derived-map review passed (950 facts / 8,028 keys).
  Read 1–200, 201–420, 421–640, 641–860, 861–1080, 1081–1300, and 1301–1498 without truncation:
  1,498 lines / 47,935 bytes. Full-file baseline identity passes. Early read-only ranges were consumed while
  the prior commit finished; no next-leaf mutation occurred until its clean boundary. Twenty whole Perl files
  remain complete; AST parser suffix 1499–1686 belongs to `.3.2.17` with three further adapter files.
- Existing AST, newline-split, callable-literal, source-map, and nested-write cards precede reconciliation.
  Read node/raw fallback, trimming, statement offsets, literals, calls/attached controls, shape/codeblock forms,
  signature validation, access, unified writes, bang mutation, fluent chains, and opening-brace scan ownership.
  Historical migration aliases do not establish current admission. No full-codebase or mdBook completion claim.
- Seven ASCII direct AST controls with base_start 100 isolate eager braces, attached controls, and attached
  function calls resetting nested offsets, while root/callable/receiver/bang controls retain them. Two Unicode
  controls preserve scalar units but show the same missing outer offset. Exact values and source sites are in
  `docs/knowledge/perl-actionir-nested-block-span-loss.md`; `.15` owns repair after reading and `.14`.
- Public Get rejects the malformed write and logs the same local-body span. Correct HASH context capture
  retains the blessed typed diagnostic in last_error.detail. A preliminary scalar-context invocation was
  invalid for the API, and allow_blessed JSON rendered the retained object as null; explicit field projection
  proves retention. Do not infer erased diagnostics. Compiler 710–750/1415–1473 and RuntimeContext 337–377
  source traces reuse already-read files. No generated loading or other-backend failure is claimed.
- Managed `PERL5LIB= prove -q -Iperl t/actionir_ast_parser.t t/punctuation_light_zero_arg_contract.t` passes
  two files / 30 top-level tests in 24 seconds. All retained probe jobs exited zero. Production/book are
  unchanged; codebase/book remain No. Next `.3.2.17` reads the exact parser suffix and adapter group.

### AST parser completion and pipeline/event adapters at `.3.2.17`

- Activated from clean `9a88116001b7f5c8c550155aedfe7dcd4c55ea71`; prior nine doctrines, post-pointer,
  zero-byte brief, clean status, and full derived-map review passed (951 facts / 8,032 keys). Read parser
  1499–1686, ArrayPipeline 1–165/166–335/336–491, CanonicalEvents 1–150/151–297, and its Core 1–219
  without truncation: 1,195 lines / 47,612 bytes; every full-file baseline identity passes. These read-only
  ranges were consumed while the prior hook finished; no checkpoint edit preceded that clean boundary.
  Twenty-four whole Perl files are complete and 65 remain.
- Parser suffix completes delimiter, quote/escape/slash-symbol, hash-pair, assignment-token, and scan-depth
  ownership plus Diagnostic stringification. Existing nested-offset repair `.15` remains pending; this suffix
  does not change or close it. ArrayPipeline uses recursive ordered plans, typed scalar-held binding updates,
  guarded active-receiver writes, and a separate internal-array path. CanonicalEvents consumes helper queues
  in statement order, supports typed value drops, records RAW_PERL and unmatched scan fallbacks, and delegates
  contract-kind/argument normalization to Core. No stable hash-key order is claimed for unmatched leftovers.
- Read existing compact-lowerer/pipeline trace, Perl uniform-binding, and map-leaves neutral/implementation
  records before reconciling these paths. Added question keys and dated owner notes to the two existing trace
  cards instead of duplicating facts. Internal contract IDs are not public authoring admission. This is source
  evidence only; no new behavioral test, defect, generated-carrier, or backend signoff claim.
- Production/book remain unchanged. Exact identity, Knowledge reconciliation, memory/doctrine/history, and
  staged review are the focused proof for this reading leaf. Next `.3.2.18` reads Contracts.pm 1–1396;
  required codebase/mdBook reading is still incomplete.

### Contracts prefix and typed-source catalog at `.3.2.18`

- Activated from clean `34958c8f4d3399bee3b5cf01f72466a8c51df59a`; prior nine doctrines, post-pointer,
  zero-byte brief, clean status, and full derived-map review passed (951 facts / 8,036 keys). Read Contracts
  1–180, 181–385, 386–600, 601–810, 811–1000, 1001–1200, and 1201–1396 without truncation:
  1,396 lines / 65,503 bytes; full-file baseline identity passes. Read-only ranges preceded activation while
  the prior commit hooks completed; checkpoint edits followed its clean boundary. Twenty-four whole Perl files
  remain read; suffix 1397–2513 belongs to `.3.2.19`.
- Read primitive/push target classification, static observation/transaction lowering, required dependency
  callbacks and dropped-value fallback, mark trace construction, typed source projection families, dispatch,
  returns, capture/cursor boundaries, named-mark capture/take, and mark-copy construction. Unread suffix still
  owns final catalog assembly; no complete registry-order claim is made from this prefix.
- Existing uniform-binding, transaction integration, typed-source rollout, and final authoring closeout records
  precede reconciliation. Typed-source record's relevant Perl/current sections 161–225 and 276–290 were read
  untruncated; an earlier combined 1–130 output was truncated and supplies no full-card coverage claim.
  Direct `typed_source_projection_rows` gives capture_mark 47, entry_match 30, input_cursor 11, cursor_control 4;
  modifying the returned nested row does not change a fresh call. Total 92 and detachment pass.
- Existing projection and transaction cards now label their old pending-status passages as historical and
  point to the already-closed final authoring model. This ledger records the bounded catalog recheck;
  no new admission, result-shape, generated-source, or other-backend test claim. Private compatibility IDs and
  canonical authored helper names remain distinct; no retired syntax is restored.
- First pre-commit attempt passed eight doctrines but rejected the typed-source card at 65,952/65,536 bytes.
  Shortened its historical-status correction and kept detailed catalog recheck evidence here; no cap increase,
  archive edit, or hook bypass. Final resulting-tree checks must pass before landing.
- Production/book remain unchanged. Focused reading/identity/catalog/Knowledge plus memory/doctrine/history
  and staged review own this checkpoint. No new defect or background job remains; `.3.2.19` reads the suffix.

### Contracts suffix and ordered builder at `.3.2.19`

- Activated from clean `54e1a487dd797396d8bb5ed847e90380015e3a40`; prior nine doctrines, post-pointer,
  zero-byte brief, and clean status passed. Prior Knowledge body-only edits left the derived map unchanged.
  Read Contracts 1397–1585, 1586–1785, 1786–1985, 1986–2185, 2186–2375, and 2376–2513 without
  truncation: 1,117 lines / 48,433 bytes. Read-only ranges preceded activation during prior commit hooks;
  checkpoint edits followed the clean boundary. Full-file baseline identity passes; twenty-five Perl files read.
- Read mark operations/positions, entry/match/input projection lowering, cursor save/restore/rewind,
  compatibility passthrough contracts, assignments and mutations, array pipelines, dropped values, flow control,
  output/declarations, and final assembly. Contracts.pm is complete at 2,513 lines / 113,936 bytes.
- Exact final-builder extraction returns fourteen groups in source order, after required dependency resolution.
  Existing `actionir-lowering-stack` now owns that dated fact and two retrieval keys; staged/progressive groups
  retain their dedicated owners. No new runtime, backend admission, or defect claim follows from this reading.
- Focused identity/source extraction, Knowledge, memory/doctrines/history pressure, and final staged review own
  this checkpoint. Production/book remain unchanged; `.3.2.20` reads ControlFlow.pm 1–1485 next.

### ControlFlow prefix and candidate isolation at `.3.2.20`

- Activated from clean `8db085f26c288063bc2d52f13d2ad697254fa608`; prior nine doctrines, post-pointer,
  zero-byte brief, clean status, and complete derived-map diff review passed (951 facts / 8,038 keys).
  Read ControlFlow 1–205, 206–415, 416–625, 626–835, 836–1050, 1051–1265, and 1266–1485 without
  truncation: 1,485 lines / 56,984 bytes. Read-only ranges preceded activation during prior hooks; checkpoint
  edits followed the clean boundary. Full-file baseline identity passes; suffix 1486–1796 remains unread.
- Read typed truth/diagnostic generation, AST reconstruction and source-method retention, branch-context
  construction/copying, attached/inline/marker if handling, implicit closures, candidate rewrite selection,
  switch assembly and case lowering, and attached-while condition/guard emission.
- Existing AST if/switch/while, source-method preservation, compact trace, marker-switch caveat, and while
  boundary cards were read and reconciled. Indexed stable `FUTURE-PARITY-BACKLOG.5` remains active and explicitly
  owns marker-switch outside-branch placement and while limit/next normalization. No duplicate repair or new
  other-backend verification claim; the first unbounded partition output was truncated and does not count as
  full-part reading. A subsequent bounded exact-node extraction supplied the owning acceptance.
- Controlled branch-rule probe: rejected candidate changes switch_counter 3 to 99 and pushes a stack entry;
  the next candidate still sees 3/empty stack. Accepted candidate changes while_counter 5 to 6 and commits.
  Existing trace card owns this bounded state-isolation fact; it does not promise general deep-copy rollback.
  Managed `PERL5LIB= prove -q -Iperl t/trace_actionir_compact_lowerers.t` passes one file/four top-level tests.
- Twenty-five whole Perl files plus this prefix are read. Production/book remain unchanged; focused identity,
  probe/trace, Knowledge, memory/doctrines/history pressure, and final staged review own this checkpoint.
  Next `.3.2.21` finishes ControlFlow and reads DeclareMethod, Diagnostics, and FlowExpr.

### Roadmap reconciliation at `.2`

- Activation: clean `a5d5dcd2955aaaa41166bd87de6bdc39a4502bc4`; `.githooks` is configured and no background job remained.
- Both roadmaps changed since the reading baseline only by the same four-line startup-prerequisite pointer.
  Those additions were read, and this checkpoint's final diff is part of review.
- The final roadmap sections explain compiler-state/error ownership, completed helper/control-flow migration,
  deferred frontend/validation work, and label-driven rule execution. Dated earlier migration spellings are
  historical evidence, not authority to restore retired helpers or restart closed work.
- Current direction remains startup reading, then `RUST-MUTATION-TESTING.1` under backlog `.20`. Its configuration
  precedes the separately owned pilot. ADR `0039` forbids per-commit mutation execution; ADR `0073` selects focused
  ordinary proof and canonical designated/push proof. No competing executable roadmap direction was found.
- No runtime behavior was verified by reading. No new public explanation is warranted by this checkpoint;
  substantive codebase/book drift, if found during `.3`/`.4`, must receive an owning leaf before remediation.
- Batch history: `.2` is resumed item 1/100 at `d6d3c890`; `.6` is item 2/100 at `03d692c1`; `.3.1` is item 3/100 at
  `942c6138`; `.3.2.1` is item 4/100 at `c0eb1acf`; `.3.2.2` is item 5/100 at `094e05bc`; `.3.2.3` is item 6/100 at
  `27fd160f`; `.3.2.4` is item 7/100 at `4f311a9e`; `.3.2.5` is item 8/100 at `6c1234cc`; `.3.2.6` is item 9/100 at
  `f864f881`; `.3.2.7` is item 10/100 at `dc7f5f09`; `.3.2.8` is item 11/100 at `e4b1f296`;
  `.3.2.9` is item 12/100 at `96a1c242`; `.3.2.10` is item 13/100 at `ff6c228c`;
  `.3.2.11` is item 14/100 at `3ab399d0`; `.3.2.12` is item 15/100 at `5e2cf756`;
  `.3.2.13` is item 16/100 at `a7d17e6f`; `.3.2.14` is item 17/100 at `e421887d`;
  `.3.2.15` is item 18/100 at `762bef64`; `.3.2.16` is item 19/100 at `9a881160`; `.3.2.17` is item 20/100 at `34958c8f`; `.3.2.18` is item 21/100 at `54e1a487`;
  `.3.2.19` is item 22/100 at `8db085f2`; `.3.2.20` is item 23/100 once committed. `.1` belongs to the prior checkpoint. This intermediate boundary does not trigger a push.

## Decisions

- `2026-09-06`: The director explicitly excluded `rgx` from this reading pass; the exclusion includes its nested
  dependencies and does not remove first-party Rust code or tests from scope.
- `2026-09-06`: After being asked to choose between a reading checkpoint and keeping every file unchanged, the
  director authorized proceeding and delegated the choice. This permits the narrow startup-tracking commit
  before full reading, resolving the session's no-document-edits prerequisite for startup tracking only.
  Implementation and unrelated documentation changes remain gated.
- `2026-09-06`: Keep detailed progress here and a short pointer in layer A; preserve the existing implementation
  destination. The checkpoint does not alter repository doctrine or make reading a substitute for production work.

## Open Questions

- None requiring director input. `.6` resolved the liveness discrepancy as a real false-dead defect; `.7` owns
  repair after required reading. Do not use `--recover` or `--purge-failed` while that boundary remains unfixed.

## Blockers

- None. At activation, Git was clean and no background job was pending. Required reading is unfinished work,
  not a test failure or an external blocker.
- `.7` blocks managed recovery/purge and later mutation-workspace setup until denied/unknown liveness is safe.
  Read-only reading can continue; no source repair is authorized by the narrow startup-tracking exception.
- `.8` owns confirmed stale bootstrap diagnostic state after `.7`; no primary parser corruption was demonstrated.
- `.9` owns confirmed attached-tail regex truncation and public handler-compile failure; repair follows `.8`.
- `.10` owns confirmed unbound AND_BCODE package-variable inputs; repair follows `.9` without inventing self-match semantics.
- `.11.1`–`.11.3` own diagnostic context/occurrence/rule-attribution repairs after `.10`; invalid inputs still reject.
- `.12` owns confirmed native bare/explicit edge-order drift after `.11`; metadata and execution currently disagree.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Exact HEAD, empty activation Git status, `.githooks` configured, scoped read coverage | PASS; all remaining reading stays explicit. |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Memory architecture, doctrine driver, history pressure, diff/scope review | Memory and both history limits PASS; eight doctrines PASS initially. README routing rejected two review edits absent from the staged snapshot. |
| `2026-09-06` | `SESSION-STARTUP-READING.1` | Restage reviewed files; `bash scripts/check_readme_stability.sh` | PASS: 20 surfaces, 62 routes, 32/32 mutations; all nine doctrine checks now pass. Final exact-candidate proof also runs in pre-commit. |
| `2026-09-06` | `SESSION-STARTUP-READING.2` | Untruncated ranges, baseline diffs, current direction, staged scope | PASS; roadmap Yes, codebase/book No. |
| `2026-09-06` | `SESSION-STARTUP-READING.2` | Memory, nine doctrines, Knowledge Map, both history-pressure checks, staged diff | PASS; all nine doctrines complete successfully, both histories below rollover, no trailing-space errors. Final evidence edits are checked again by pre-commit. |
| `2026-09-06` | `SESSION-STARTUP-READING.6` | Managed 45-second process; paired restricted/permitted run-list and kill-zero probes; exact source trace; final wrapper/census | CONFIRMED DEFECT; EPERM was false-dead. Probe exits 0; no recovery used; zero leftovers. Repair `.7` is required, not claimed complete. |
| `2026-09-06` | `SESSION-STARTUP-READING.6` | Focused memory/history/diff plus required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `03d692c1`; diagnostic checkpoint complete, repair remains pending. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Exact baseline object/class census, binary/decoded inventory, whole-source delta, bounded first-child accounting | PASS; 2,547 disjoint entries and no source/test/tool/book delta; inventory is not reading credit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Managed Perl facade/phase0 syntax; both history-pressure checks; diff review | PASS; both syntax checks OK, change-history warns below rollover, engineering notes OK. Required pre-commit supplies final doctrine/Knowledge proof. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.1` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `942c6138`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.1` | Exact five-file full reading, baseline identity, existing owner/trivia Knowledge, managed facade/phase0 syntax | PASS; 1,430 lines / 56,706 bytes covered, no production delta. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.1` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `c0eb1acf`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.2` | Independent byte-interval coverage/budget audit and baseline Perl diff | PASS: 52 leaves, 84 exact paths, 2,076,984 bytes, no gaps/overlaps/source delta. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.2` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `094e05bc`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.3` | Five-file full reading/baseline identity; existing Knowledge; managed comparison/public-error controls | PASS reading; CONFIRMED stale diagnostic defect, repair `.8` pending. All probe jobs completed. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.3` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `27fd160f`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.4` | Four exact core chunks/baseline identity; existing Knowledge; scanner/helper/descriptor/public controls | PASS reading; CONFIRMED regex-tail defect, repair `.9` pending; all probes consumed. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.4` | Required pre-commit Knowledge and all nine doctrines; post-commit pointer; clean status/empty brief | PASS at `4f311a9e`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.5` | Exact full reading/baseline identity; required rollover; independent suffix/count/SHA-256 proof | PASS; final canonical proof required before landing ADR 0102 capacity step. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.5` | Exact default canonical gate; staged receipt; all nine commit doctrines; promoted receipt; empty brief/clean status | PASS at `6c1234cc`; Phase 0 1,032/1,032 and primary CLI 66/66 twice. No pending job. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.6` | Four exact compiler chunks/baseline identity; Knowledge reconciliation; prior receipt and dated sample review; exact two-file cleanup | PASS reading/evidence; final focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.6` | Required Knowledge/all nine doctrines; post-commit pointer; empty brief/clean status; derived-map review | PASS at `f864f881`; 944 facts / 7,996 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.7` | Four suffix chunks/full-file identity; existing owner reconciliation; source-level Knowledge card | PASS reading; final focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.7` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `dc7f5f09`; 945 facts / 8,003 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.8` | Three complete-file reading chunks; baseline identity; isolated HandlerIR differential; public descriptor/source control; historical Knowledge reconciliation | PASS reading/probes; final focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.8` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `e4b1f296`; 946 facts / 8,008 keys. Literal old metadata pipes are corrected in `.3.2.9`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.9` | Six prefix chunks/baseline identity; direct context/formatter and callback/Get controls; corrected open-block reverify | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.9` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `96a1c242`; 947 facts / 8,013 keys. Retrieval commands and evidence render correctly. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.10` | Three suffix chunks/full-file identity; existing edge/slash/gap/diagnostic reconciliation | PASS reading; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.10` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status | PASS at `ff6c228c`; derived-map count unchanged at 947 facts / 8,013 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.11` | Five complete-file chunks/baseline identity; OR spelling and AND public controls; direct RuleIR normalization | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.11` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `3ab399d0`; 948 facts / 8,018 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.12` | Seven prefix chunks/full-file identity; exact registry extraction and existing Knowledge reconciliation | PASS reading/card reverify; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.12` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `5e2cf756`; 948 facts / 8,018 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.13` | Six suffix chunks/full-file identity; public AND/OR equivalent-target controls; descriptor/source and direct rewrite | PASS reading/retained probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.13` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `a7d17e6f`; 949 facts / 8,022 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.14` | Seven prefix chunks/full-file identity; direct builders; public selected-I literal/source/package controls; historical return reverify | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.14` | Required Knowledge/all nine doctrines; post-commit pointer; zero-byte brief/clean status; derived-map review | PASS at `e421887d`; 950 facts / 8,026 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.15` | Exact three-file completion/identity; bounded REP literal/source/package controls; diagnostic JSON projection | PASS reading/probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.15` | Required Knowledge/all nine doctrines; post-pointer; zero-byte brief/clean status; derived-map review | PASS at `762bef64`; 950 facts / 8,028 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.16` | Exact prefix identity/reading; AST and public offset controls; two parser suites | PASS 30 top-level tests and retained probes; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.16` | Required Knowledge/all nine doctrines; post-pointer; empty brief/clean status; derived-map review | PASS at `9a881160`; 951 facts / 8,032 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.17` | Exact four-file baseline identity/ranges; Knowledge owner reconciliation | PASS reading; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.17` | Required Knowledge/all nine doctrines; post-pointer; empty brief/clean status; derived-map review | PASS at `34958c8f`; 951 facts / 8,036 keys. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.18` | Exact prefix identity/ranges; catalog count/detachment; historical status reconciliation | PASS reading/catalog; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.19` | Exact suffix reading/identity; fourteen-group source extraction; owner reconciliation | PASS reading/structure; focused memory/doctrine/Knowledge/history and staged checks precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.20` | Exact prefix reading/identity; candidate-context probe; compact trace suite | PASS probe and one file/four top-level tests; focused continuity/staged checks precede landing. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SESSION-STARTUP-READING.1` | `SESSION-STARTUP-READING.1 - preserve required reading progress` | Startup-tracking-only exception; reading remains incomplete. |
| `SESSION-STARTUP-READING.2` | `SESSION-STARTUP-READING.2 - complete roadmap reading` | Completed roadmap reading; exact coverage and focused checks, remaining reading and liveness discrepancy owned. |
| `SESSION-STARTUP-READING.6` | `SESSION-STARTUP-READING.6 - diagnose denied liveness probes` | Exact causal evidence and owned repair; no production change or deletion test. |
| `SESSION-STARTUP-READING.3.1` | `SESSION-STARTUP-READING.3.1 - bound the codebase reading inventory` | Complete baseline accounting and bounded next child; source/book reading still incomplete. |
| `SESSION-STARTUP-READING.3.2.1` | `SESSION-STARTUP-READING.3.2.1 - read facade invocation owners` | Five unique Perl files complete; remaining 84 Perl entries and other lanes remain unread. |
| `SESSION-STARTUP-READING.3.2.2` | `SESSION-STARTUP-READING.3.2.2 - partition remaining Perl reading` | All unread Perl bytes owned before reading; no new reading credit. |
| `SESSION-STARTUP-READING.3.2.3` | `SESSION-STARTUP-READING.3.2.3 - read resolution and bootstrap adapters` | Ten unique Perl files read; stale diagnostic defect proved and repair `.8` owned. |
| `SESSION-STARTUP-READING.3.2.4` | `SESSION-STARTUP-READING.3.2.4 - read bootstrap grammar core` | Eleven unique Perl files read; attached-tail regex defect proved and `.9` owned. |
| `SESSION-STARTUP-READING.3.2.5` | `SESSION-STARTUP-READING.3.2.5 - read compiler state and preserve history` | Twelve Perl files read; required complete-record rollover and finite capacity ADR 0102. |
| `SESSION-STARTUP-READING.3.2.6` | `SESSION-STARTUP-READING.3.2.6 - read compiler generation and state assembly` | Compiler prefix read; prior canonical/loader evidence and historical duplicate-slot resolution preserved. |
| `SESSION-STARTUP-READING.3.2.7` | `SESSION-STARTUP-READING.3.2.7 - complete compiler pipeline reading` | Thirteen whole Perl files read; source-level phase/mode boundaries indexed. |
| `SESSION-STARTUP-READING.3.2.8` | `SESSION-STARTUP-READING.3.2.8 - read SpecEntry and own unbound input repair` | Fourteen whole Perl files read; historical coupling reconciled; explicit repair `.10` owns the private handoff defect. |
| `SESSION-STARTUP-READING.3.2.9` | `SESSION-STARTUP-READING.3.2.9 - read validation and own diagnostic repairs` | Validation prefix read; diagnostic repair children and retrieval corrections preserved. |
| `SESSION-STARTUP-READING.3.2.10` | `SESSION-STARTUP-READING.3.2.10 - complete validation reading` | Fifteen full Perl files read; current edge/capture owners reconciled. |
| `SESSION-STARTUP-READING.3.2.11` | `SESSION-STARTUP-READING.3.2.11 - read RuleIR and own edge-order repair` | Sixteen full Perl files read; native/public order defect and repair `.12` preserved. |
| `SESSION-STARTUP-READING.3.2.12` | `SESSION-STARTUP-READING.3.2.12 - read EmitContext bridge and reconcile registry` | EmitContext prefix read; owner cardinality and retrieval corrected; suffix remains unread. |
| `SESSION-STARTUP-READING.3.2.13` | `SESSION-STARTUP-READING.3.2.13 - complete EmitContext reading and own blind-edge repair` | Seventeen full Perl files read; blind occurrence-identity defect and repair `.13` preserved. |
| `SESSION-STARTUP-READING.3.2.14` | `SESSION-STARTUP-READING.3.2.14 - read emitter prefix and own I-block repairs` | Emitter prefix read; literal/scope defects and `.14` repair children preserved; historical contracts reconciled. |
| `SESSION-STARTUP-READING.3.2.15` | `SESSION-STARTUP-READING.3.2.15 - finish emitter adapters and extend return repairs` | Twenty full Perl files read; existing return/scope repairs extend to repetition; diagnostic projection bounded. |
| `SESSION-STARTUP-READING.3.2.16` | `SESSION-STARTUP-READING.3.2.16 - read AST parser and own nested span repair` | Parser prefix read; nested-offset repair `.15` owns three recursive handoffs and adjacent controls. |
| `SESSION-STARTUP-READING.3.2.17` | `SESSION-STARTUP-READING.3.2.17 - finish AST parser and read pipeline adapters` | Twenty-four whole Perl files read; existing pipeline/event owners indexed; Contracts prefix follows. |
| `SESSION-STARTUP-READING.3.2.18` | `SESSION-STARTUP-READING.3.2.18 - read contract prefix and reconcile projection status` | Contracts prefix read; 92-row detached catalog rechecked; stale-current card wording bounded. |
| `SESSION-STARTUP-READING.3.2.19` | `SESSION-STARTUP-READING.3.2.19 - finish contract catalog reading` | Contracts fully read; ordered builder fact indexed; twenty-five Perl files complete. |
| `SESSION-STARTUP-READING.3.2.20` | `SESSION-STARTUP-READING.3.2.20 - read control flow prefix and verify candidate isolation` | ControlFlow prefix read; bounded candidate-state isolation verified; existing caveat owners retained. |

## Changelog

- `2026-09-06`: Created the owning leaf before any checkpoint edits; recorded baseline coverage and the remaining reading sequence.
- `2026-09-06`: Completed the focused checkpoint and synchronized continuity; remaining reading starts at `.2`.
- `2026-09-06`: `.2` completes the remaining roadmap ranges and current-direction reconciliation; codebase and
  mdBook reading remain No, and `.3` owns the next inventory/decomposition.
- `2026-09-06`: `.6` proves the surprising liveness report, records a fact card, and owns the repair as `.7`.
  Required reading resumes at `.3`; managed recovery/purge remains unused until repaired.
- `2026-09-06`: `.3.1` classifies every baseline entry, owns all source lanes, completes Toolbox reading, and
  defines exact `.3.2.1` coverage before source reading. No production or public-book change.
- `2026-09-06`: `.3.2.1` completes the five-file invocation boundary and reconciles it with existing Knowledge;
  `.3.2.2` owns decomposition of the remaining 84 Perl paths.
- `2026-09-06`: `.3.2.2` owns 52 exact remaining Perl groups, including byte fragments for generated MCP JSON;
  independent interval proof passes, and `.3.2.3` is the next reading leaf.
- `2026-09-06`: `.3.2.3` completes five dependency adapters, diagnoses stale comparison state, and owns repair
  `.8`; the next exact reading leaf is `.3.2.4`, with both repairs gated on required reading.
- `2026-09-06`: `.3.2.4` completes bootstrap core reading and diagnoses attached-tail regex truncation;
  `.9` owns repair and `.3.2.5` is the next required reading leaf.
- `2026-09-06`: `.3.2.5` completes compiler-state reading and required history rollover; ADR 0102 admits
  exactly one history member/manifest row under canonical verification. Next reading is `.3.2.6`.
- `2026-09-06`: `.3.2.6` reads Compiler.pm 1–1041, records prior canonical/loader evidence, and links the
  historical duplicate-slot card to its existing fix. Next reading is `.3.2.7`; codebase/book remain incomplete.
- `2026-09-06`: `.3.2.7` completes compiler reading and indexes its existing phase/mode boundaries.
  Thirteen Perl files are read; `.3.2.8` reads SpecEntry.pm next.
- `2026-09-06`: `.3.2.8` completes SpecEntry reading, reconciles old coupling records, and owns unbound
  AND_BCODE input repair `.10`; next reading is Validation.pm 1–1320 under `.3.2.9`.
- `2026-09-06`: `.3.2.9` reads Validation.pm 1–1320, owns diagnostic repairs `.11.1`–`.11.3`, and repairs
  stale Knowledge retrieval. `.3.2.10` reads the validation suffix next.
- `2026-09-06`: `.3.2.10` completes Validation.pm reading and reconciles the historical edge card.
  Fifteen Perl files are read; `.3.2.11` reads RuleIR.pm next.
- `2026-09-06`: `.3.2.11` completes RuleIR reading and proves bare/explicit execution-order drift.
  Repair `.12` is owned; `.3.2.12` reads EmitContext.pm next.
- `2026-09-06`: `.3.2.12` reads EmitContext 1–1489 and reconciles fourteen registry keys with the existing cards.
  `.3.2.13` reads the suffix next; codebase/book remain incomplete.
- `2026-09-06`: `.3.2.13` completes EmitContext reading and owns repeated blind-target repair `.13`.
  `.3.2.14` reads HandlerVariantEmitter next; codebase/book remain incomplete.
- `2026-09-06`: `.3.2.14` reads the emitter prefix, reconciles historical cards, and owns I-block literal/scope
  repairs `.14.1`/`.14.2`. `.3.2.15` reads the emitter suffix plus LinkedRE and ActionIR AST.
- `2026-09-06`: `.3.2.15` completes emitter/LinkedRE/AST reading, extends `.14` repairs to REP, and bounds
  JSON projection claims. `.3.2.16` reads ActionIR/AST/Parser.pm 1–1498 next.
- `2026-09-06`: `.3.2.16` reads the AST parser prefix, proves nested span loss, and owns repair `.15`;
  `.3.2.17` completes the parser and reads ArrayPipeline/CanonicalEvents adapters.
- `2026-09-06`: `.3.2.17` completes AST parser and pipeline/event adapters; twenty-four Perl files read.
  Existing Knowledge owners gain direct retrieval keys; `.3.2.18` reads the Contracts prefix.
- `2026-09-06`: `.3.2.18` reads Contracts 1–1396 and rechecks the detached typed-source catalog;
  historical status wording is reconciled, and `.3.2.19` finishes Contracts.
- `2026-09-06`: `.3.2.19` finishes Contracts and indexes its fourteen-group builder;
  twenty-five Perl files are fully read, and `.3.2.20` starts ControlFlow.
- `2026-09-06`: `.3.2.20` reads ControlFlow 1–1485, verifies candidate state isolation and compact trace,
  and retains existing caveat repair ownership; `.3.2.21` completes ControlFlow and the next adapters.
