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
  Children: `SESSION-STARTUP-READING.1`, `SESSION-STARTUP-READING.2`, `SESSION-STARTUP-READING.3`, `SESSION-STARTUP-READING.4`, `SESSION-STARTUP-READING.5`, `SESSION-STARTUP-READING.6`, `SESSION-STARTUP-READING.7`, `SESSION-STARTUP-READING.8`, `SESSION-STARTUP-READING.9`, `SESSION-STARTUP-READING.10`

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
  Status: `pending`
  Goal: Read baseline Perl group 7: 1,320 lines/fragments, 43,290 bytes.
  Scope: `perl/LinkedSpec/Validation.pm` lines 1–1320.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.10`
  Status: `pending`
  Goal: Read baseline Perl group 8: 584 lines/fragments, 18,639 bytes.
  Scope: `perl/LinkedSpec/Validation.pm` lines 1321–1904.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.11`
  Status: `pending`
  Goal: Read baseline Perl group 9: 987 lines/fragments, 31,462 bytes.
  Scope: `perl/LinkedSpec/RuleIR.pm` lines 1–987.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.12`
  Status: `pending`
  Goal: Read baseline Perl group 10: 1,489 lines/fragments, 49,396 bytes.
  Scope: `perl/LinkedSpec/RuleIR/EmitContext.pm` lines 1–1489.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.13`
  Status: `pending`
  Goal: Read baseline Perl group 11: 1,094 lines/fragments, 46,079 bytes.
  Scope: `perl/LinkedSpec/RuleIR/EmitContext.pm` lines 1490–2583.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.14`
  Status: `pending`
  Goal: Read baseline Perl group 12: 1,403 lines/fragments, 53,304 bytes.
  Scope: `perl/LinkedSpec/HandlerVariantEmitter.pm` lines 1–1403.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.15`
  Status: `pending`
  Goal: Read baseline Perl group 13: 736 lines/fragments, 24,430 bytes.
  Scope: `perl/LinkedSpec/HandlerVariantEmitter.pm` lines 1404–1920; `perl/LinkedRE.pm` lines 1–148; `perl/LinkedSpec/ActionIR/AST.pm` lines 1–71.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.16`
  Status: `pending`
  Goal: Read baseline Perl group 14: 1,498 lines/fragments, 47,935 bytes.
  Scope: `perl/LinkedSpec/ActionIR/AST/Parser.pm` lines 1–1498.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.17`
  Status: `pending`
  Goal: Read baseline Perl group 15: 1,195 lines/fragments, 47,612 bytes.
  Scope: `perl/LinkedSpec/ActionIR/AST/Parser.pm` lines 1499–1686; `perl/LinkedSpec/ActionIR/ArrayPipeline.pm` lines 1–491; `perl/LinkedSpec/ActionIR/CanonicalEvents.pm` lines 1–297; `perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm` lines 1–219.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.18`
  Status: `pending`
  Goal: Read baseline Perl group 16: 1,396 lines/fragments, 65,503 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Contracts.pm` lines 1–1396.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.19`
  Status: `pending`
  Goal: Read baseline Perl group 17: 1,117 lines/fragments, 48,433 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Contracts.pm` lines 1397–2513.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.2.20`
  Status: `pending`
  Goal: Read baseline Perl group 18: 1,485 lines/fragments, 56,984 bytes.
  Scope: `perl/LinkedSpec/ActionIR/ControlFlow.pm` lines 1–1485.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification: `pending`
  Commit: `pending`

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
  Acceptance: Record local adoption evidence and applicable donor updates; own any required changes; confirm all three reading answers Yes, then route to repairs `.7`–`.10` before restoring RUST-MUTATION-TESTING.1.
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

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SESSION-STARTUP-READING.3.2.9` | `pending` | Read Validation.pm baseline lines 1–1320 in bounded chunks. |

## Reading Ledger

All line ranges below refer to the **reading baseline**, not later shifted working-file line numbers. Files
modified by this checkpoint must also be reviewed in the final diff. Unlisted source files and unlisted ranges
remain unread; running a command that prints a file does not establish comprehension if its output was truncated.

| Required surface | Fully read and understood? | Completed at checkpoint | Remaining |
| --- | --- | --- | --- |
| Roadmap | **Yes** | `ROADMAP.md` 1–2564; `ROADMAP_V2.md` 1–1585. `.2` read 1341–1380, 1381–1420, 1421–1470, 1471–1530, and 1531–1585 without truncation and reviewed both current roadmap diffs. | Review later changes as they land; codebase/book alignment remains gated on their reading. |
| Codebase | **No** | Fourteen Perl files in full under `.3.2.1` and `.3.2.3`–`.3.2.8`; checkpoint-relevant scripts listed below. | Remaining 75 Perl paths and all other first-party inputs not explicitly listed as read. |
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
  `f864f881`; `.3.2.7` is item 10/100 at `dc7f5f09`; `.3.2.8` is item 11/100 once committed. `.1` belongs to the
  prior checkpoint. This intermediate boundary does not trigger a push.

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
