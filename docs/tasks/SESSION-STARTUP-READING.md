# SESSION-STARTUP-READING: Complete the Required Reading Before Implementation

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Session continuity prerequisite to RUST-MUTATION-TESTING.1`
- Created: `2026-09-06`
- Last updated: `2026-09-13`
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
  Director exception (2026-09-08): containment `.7.2-.7.4` may implement and verify ADR 0108/0109 capacity infrastructure before remaining reading; all parser/repair gates remain in force.

## Task Tree

- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Complete the required reading and restore the implementation frontier.
  Children: `SESSION-STARTUP-READING.1`, `SESSION-STARTUP-READING.2`, `SESSION-STARTUP-READING.3`, `SESSION-STARTUP-READING.4`, `SESSION-STARTUP-READING.5`, `SESSION-STARTUP-READING.6`, `SESSION-STARTUP-READING.7`, `SESSION-STARTUP-READING.8`, `SESSION-STARTUP-READING.9`, `SESSION-STARTUP-READING.10`, `SESSION-STARTUP-READING.11`, `SESSION-STARTUP-READING.12`, `SESSION-STARTUP-READING.13`, `SESSION-STARTUP-READING.14`, `SESSION-STARTUP-READING.15`, `SESSION-STARTUP-READING.16`, `SESSION-STARTUP-READING.17`, `SESSION-STARTUP-READING.18`, `SESSION-STARTUP-READING.19`, `SESSION-STARTUP-READING.20`, `SESSION-STARTUP-READING.21`, `SESSION-STARTUP-READING.22`, `SESSION-STARTUP-READING.23`, `SESSION-STARTUP-READING.24`, `SESSION-STARTUP-READING.25`, `SESSION-STARTUP-READING.26`, `SESSION-STARTUP-READING.27`, `SESSION-STARTUP-READING.28`, `SESSION-STARTUP-READING.29`, `SESSION-STARTUP-READING.30`, `SESSION-STARTUP-READING.31`, `SESSION-STARTUP-READING.32`, `SESSION-STARTUP-READING.33`, `SESSION-STARTUP-READING.34`, `SESSION-STARTUP-READING.35`, `SESSION-STARTUP-READING.36`, `SESSION-STARTUP-READING.37`, `SESSION-STARTUP-READING.38`, `SESSION-STARTUP-READING.39`, `SESSION-STARTUP-READING.40`, `SESSION-STARTUP-READING.41`, `SESSION-STARTUP-READING.42`, `SESSION-STARTUP-READING.43`, `SESSION-STARTUP-READING.44`, `SESSION-STARTUP-READING.45`, `SESSION-STARTUP-READING.46`, `SESSION-STARTUP-READING.47`, `SESSION-STARTUP-READING.49`, `SESSION-STARTUP-READING.50`, `SESSION-STARTUP-READING.51`, `SESSION-STARTUP-READING.52`, `SESSION-STARTUP-READING.53`, `SESSION-STARTUP-READING.54`, `SESSION-STARTUP-READING.55`, `SESSION-STARTUP-READING.56`, `SESSION-STARTUP-READING.57`, `SESSION-STARTUP-READING.58`, `SESSION-STARTUP-READING.59`, `SESSION-STARTUP-READING.60`, `SESSION-STARTUP-READING.61`, `SESSION-STARTUP-READING.62`, `SESSION-STARTUP-READING.63`, `SESSION-STARTUP-READING.64`, `SESSION-STARTUP-READING.65`, `SESSION-STARTUP-READING.66`, `SESSION-STARTUP-READING.67`, `SESSION-STARTUP-READING.68`, `SESSION-STARTUP-READING.69`, `SESSION-STARTUP-READING.70`, `SESSION-STARTUP-READING.71`, `SESSION-STARTUP-READING.72`, `SESSION-STARTUP-READING.73`, `SESSION-STARTUP-READING.74`, `SESSION-STARTUP-READING.75`, `SESSION-STARTUP-READING.76`, `SESSION-STARTUP-READING.77`, `SESSION-STARTUP-READING.78`, `SESSION-STARTUP-READING.79`, `SESSION-STARTUP-READING.80`, `SESSION-STARTUP-READING.81`, `SESSION-STARTUP-READING.82`, `SESSION-STARTUP-READING.83`

- ID: `SESSION-STARTUP-READING.1`
  Status: `done`
  Goal: Commit the authorized startup-reading checkpoint before continuing the reading pass.
  Acceptance: Baseline and coverage are explicit, required-reading answers remain honest, and continuity points to `.2`.
  Verification tier: `focused`
  Focused checks: `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `perl tools/roll_document_history.pl --surface change_history --check`; `perl tools/roll_document_history.pl --surface engineering_notes --check`; `git diff --check`; staged-path and coverage review.
  Canonical trigger: `none` — bounded continuity documentation; no policy, infrastructure, or public contract changes.
  Verification: Activated task-tree-first from the clean reading baseline; memory, nine doctrine checks, both history-pressure checks, and diff/scope review pass. README routing was rerun after refreshing the staged snapshot; pre-commit checks the final candidate again.
  Commit: `SESSION-STARTUP-READING.1 - preserve required reading progress` — Startup-tracking-only exception; reading remains incomplete.

- ID: `SESSION-STARTUP-READING.2`
  Status: `done`
  Goal: Finish ROADMAP_V2.md from baseline line 1341 and reconcile its current direction with the completed ROADMAP.md reading.
  Acceptance: Baseline lines 1341–1585 are read without truncation; roadmap understanding and any real alignment issue are recorded.
  Verification tier: `focused`
  Focused checks: `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `perl tools/roll_document_history.pl --surface change_history --check`; `perl tools/roll_document_history.pl --surface engineering_notes --check`; `git diff --check`; staged-scope and exact reading-range review.
  Canonical trigger: `none` — startup-reading continuity only; no public, policy, infrastructure, or runtime change.
  Verification: Baseline lines 1341–1585 read in five untruncated ranges; both roadmap diffs since baseline reviewed. Current direction agrees with the task index, mutation-testing tree, ADR 0039, and ADR 0073. Focused commit checks recorded below.
  Commit: `SESSION-STARTUP-READING.2 - complete roadmap reading` — Completed roadmap reading; exact coverage and focused checks, remaining reading and liveness discrepancy owned.

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
  Commit: `SESSION-STARTUP-READING.3.1 - bound the codebase reading inventory` — Complete baseline accounting and bounded next child; source/book reading still incomplete.

- ID: `SESSION-STARTUP-READING.3.2`
  Status: `done`
  Goal: Read all 89 baseline Perl entries and their current deltas, starting with the facade invocation owners.
  Children: `.3.2.1`, `.3.2.2`, `.3.2.3`, `.3.2.4`, `.3.2.5`, `.3.2.6`, `.3.2.7`, `.3.2.8`, `.3.2.9`, `.3.2.10`, `.3.2.11`, `.3.2.12`, `.3.2.13`, `.3.2.14`, `.3.2.15`, `.3.2.16`, `.3.2.17`, `.3.2.18`, `.3.2.19`, `.3.2.20`, `.3.2.21`, `.3.2.22`, `.3.2.23`, `.3.2.24`, `.3.2.25`, `.3.2.26`, `.3.2.27`, `.3.2.28`, `.3.2.29`, `.3.2.30`, `.3.2.31`, `.3.2.32`, `.3.2.33`, `.3.2.34`, `.3.2.35`, `.3.2.36`, `.3.2.37`, `.3.2.38`, `.3.2.39`, `.3.2.40`, `.3.2.41`, `.3.2.42`, `.3.2.43`, `.3.2.44`, `.3.2.45`, `.3.2.46`, `.3.2.47`, `.3.2.48`, `.3.2.49`, `.3.2.50`, `.3.2.51`, `.3.2.52`, `.3.2.53`, `.3.2.54`, `.3.2.55`

  Verification: All 89 baseline files / 2,133,690 bytes are physically read and comprehension-reconciled;
    .3.2.55 independently verifies exact coverage, current identity, durable commits, and canonical closeout.
    Pending repairs are unchanged; this status certifies reading completion only.
  Commit: `SESSION-STARTUP-READING.3.2.55 - close Perl reading and own bounded Rust scopes`

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
  Commit: `SESSION-STARTUP-READING.3.2.1 - read facade invocation owners` — Five unique Perl files complete; remaining 84 Perl entries and other lanes remain unread.

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
  Commit: `SESSION-STARTUP-READING.3.2.2 - partition remaining Perl reading` — All unread Perl bytes owned before reading; no new reading credit.

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
  Commit: `SESSION-STARTUP-READING.3.2.3 - read resolution and bootstrap adapters` — Ten unique Perl files read; stale diagnostic defect proved and repair `.8` owned.

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
  Commit: `SESSION-STARTUP-READING.3.2.4 - read bootstrap grammar core` — Eleven unique Perl files read; attached-tail regex defect proved and `.9` owned.

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
  Commit: `SESSION-STARTUP-READING.3.2.5 - read compiler state and preserve history` — Twelve Perl files read; required complete-record rollover and finite capacity ADR 0102.

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
  Commit: `SESSION-STARTUP-READING.3.2.6 - read compiler generation and state assembly` — Compiler prefix read; prior canonical/loader evidence and historical duplicate-slot resolution preserved.

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
  Commit: `SESSION-STARTUP-READING.3.2.7 - complete compiler pipeline reading` — Thirteen whole Perl files read; source-level phase/mode boundaries indexed.

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
  Commit: `SESSION-STARTUP-READING.3.2.8 - read SpecEntry and own unbound input repair` — Fourteen whole Perl files read; historical coupling reconciled; explicit repair `.10` owns the private handoff defect.

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
  Commit: `SESSION-STARTUP-READING.3.2.9 - read validation and own diagnostic repairs` — Validation prefix read; diagnostic repair children and retrieval corrections preserved.

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
  Commit: `SESSION-STARTUP-READING.3.2.10 - complete validation reading` — Fifteen full Perl files read; current edge/capture owners reconciled.

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
  Commit: `SESSION-STARTUP-READING.3.2.11 - read RuleIR and own edge-order repair` — Sixteen full Perl files read; native/public order defect and repair `.12` preserved.

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
  Commit: `SESSION-STARTUP-READING.3.2.12 - read EmitContext bridge and reconcile registry` — EmitContext prefix read; owner cardinality and retrieval corrected; suffix remains unread.

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
  Commit: `SESSION-STARTUP-READING.3.2.13 - complete EmitContext reading and own blind-edge repair` — Seventeen full Perl files read; blind occurrence-identity defect and repair `.13` preserved.

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
  Commit: `SESSION-STARTUP-READING.3.2.14 - read emitter prefix and own I-block repairs` — Emitter prefix read; literal/scope defects and `.14` repair children preserved; historical contracts reconciled.

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
  Commit: `SESSION-STARTUP-READING.3.2.15 - finish emitter adapters and extend return repairs` — Twenty full Perl files read; existing return/scope repairs extend to repetition; diagnostic projection bounded.

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
  Commit: `SESSION-STARTUP-READING.3.2.16 - read AST parser and own nested span repair` — Parser prefix read; nested-offset repair `.15` owns three recursive handoffs and adjacent controls.

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
  Commit: `SESSION-STARTUP-READING.3.2.17 - finish AST parser and read pipeline adapters` — Twenty-four whole Perl files read; existing pipeline/event owners indexed; Contracts prefix follows.

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
  Commit: `SESSION-STARTUP-READING.3.2.18 - read contract prefix and reconcile projection status` — Contracts prefix read; 92-row detached catalog rechecked; stale-current card wording bounded.

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
  Commit: `SESSION-STARTUP-READING.3.2.19 - finish contract catalog reading` — Contracts fully read; ordered builder fact indexed; twenty-five Perl files complete.

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
  Commit: `SESSION-STARTUP-READING.3.2.20 - read control flow prefix and verify candidate isolation` — ControlFlow prefix read; bounded candidate-state isolation verified; existing caveat owners retained.

- ID: `SESSION-STARTUP-READING.3.2.21`
  Status: `done`
  Goal: Read baseline Perl group 19: 1,439 lines/fragments, 59,142 bytes.
  Scope: `perl/LinkedSpec/ActionIR/ControlFlow.pm` lines 1486–1796; `perl/LinkedSpec/ActionIR/DeclareMethod.pm` lines 1–328; `perl/LinkedSpec/ActionIR/Diagnostics.pm` lines 1–269; `perl/LinkedSpec/ActionIR/FlowExpr.pm` lines 1–531.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Perform the required engineering-notes rollover and admit only the exact finite history capacity it needs,
    with indexed ADR evidence; preserve every immutable byte and current-view/aggregate ceiling.
  Verification tier: `canonical`
  Focused checks: Exact four-file reading/identity; existing diagnostics/flow/declaration Knowledge;
    focused diagnostic/flow controls; required rollover and independent clean-source byte/hash proof;
    memory/Knowledge/history/routing checks, final staged review, and exact staged canonical receipt.
  Canonical trigger: `infrastructure` — required finite engineering-notes history capacity in the route registry.
  Verification: Nine exact ranges cover 1,439 lines / 59,142 bytes; four full-file identities pass.
    Pipeline trace passes five top-level tests. Public/generated/host-seed controls prove emptiness defects,
    owned by `.16.1`/`.16.2`. Exact required rollover and ADR 0103 admit one member/manifest record;
    the first canonical attempt encounters denied nested sandbox initialization. A no-op control isolates the
    restriction, and permitted execution passes the unchanged full process-locality oracle. Knowledge preserves
    this prerequisite; rerun full canonical CI for the final staged receipt. No production repair or full-reading claim.
  Commit: `SESSION-STARTUP-READING.3.2.21 - read flow adapters and preserve required history` — Twenty-nine Perl files read; emptiness repairs owned; exact notes rollover and finite capacity recorded.

- ID: `SESSION-STARTUP-READING.3.2.22`
  Status: `done`
  Goal: Read baseline Perl group 20: 298 lines/fragments, 7,800 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodExpr.pm` lines 1–298.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile authored-value versus legacy scope ownership using the forward coverage preserved in `.31`.
  Verification tier: `focused`
  Focused checks: Exact full-file reading and baseline identity; existing optional-scope and migration Knowledge;
    bounded normalizer controls; memory/doctrine/Knowledge/history checks; final diff and staged-scope review.
  Canonical trigger: `none` — reading continuity only; no runtime, public, or infrastructure change.
  Verification: Full 298-line / 7,800-byte source reading and baseline identity pass. Bounded controls preserve
    three authored values in a distinct list, allow explicit legacy/fixed-arity fallback, keep input unchanged,
    and reject missing minimum arity. Existing Knowledge reconciles; focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.22 - read method expression normalization` — MethodExpr comprehension and scope precedence recorded; next MethodLowering prefix.

- ID: `SESSION-STARTUP-READING.3.2.23`
  Status: `done`
  Goal: Read baseline Perl group 21: 1,495 lines/fragments, 61,967 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 1–1495.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile the older value-dispatcher record with its completed statement/block migration successors.
  Verification tier: `focused`
  Focused checks: Exact prefix/full-file identity and reading; existing AST, block, binding, and trace owners;
    managed `prove -Iperl t/trace_actionir_method_lowering.t`; memory/doctrine/Knowledge/history and staged review.
  Canonical trigger: `none` — bounded source-reading and Knowledge continuity only.
  Verification: Full-file baseline identity and 1–1495 / 61,967-byte prefix coverage pass. Four MethodLowering trace
    tests pass. Existing AST/block/binding/callable records reconcile; dated later-migration notes are qualified.
    Focused memory/history/diff review and all required commit hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.23 - read method lowering prefix and reconcile milestones` — Prefix comprehension and dated AST/binding/callable milestone ownership reconciled; no source/book change.

- ID: `SESSION-STARTUP-READING.3.2.24`
  Status: `done`
  Goal: Read baseline Perl group 22: 883 lines/fragments, 33,969 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 1496–2378.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Reconcile related fixed/variadic signature chronology and retired direct-read/aggregate-selector wording.
  Verification tier: `focused`
  Focused checks: Exact range/full-file baseline identity; function signature, binding, statement, and retirement
    Knowledge; managed `prove -Iperl t/variadic_user_function_contract.t`; memory/doctrine/Knowledge/history and staged review.
  Canonical trigger: `none` — source-reading and existing Knowledge continuity only.
  Verification: Full-file baseline identity and exact 883-line / 33,969-byte range pass. The variadic function
    suite passes 66 tests; a public mixed-path read returns one with no context error. Existing signature and
    retirement records reconcile; focused memory/history/scope checks and required commit hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.24 - read function signatures and statement lowering` — Function signatures and guarded statement bridges read; four historical Knowledge records reconciled.

- ID: `SESSION-STARTUP-READING.3.2.25`
  Status: `done`
  Goal: Read baseline Perl group 23: 1,365 lines/fragments, 65,506 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 2379–3743.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Verify caller argument scope against the existing function-execution contract with public engine probes.
  Verification tier: `focused`
  Focused checks: Exact range/full-file baseline identity; value/callable/function Knowledge;
    public Get and generated-source caller-scope controls; memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source-reading and diagnostic continuity only; repairs remain separately owned.
  Verification: Exact baseline identity and 1,365-line / 65,506-byte coverage pass. Eight public Get/source/descriptor
    controls establish caller-local shadowing in scalar, aggregate, and nested calls with passing controls;
    `.32` owns repair. Memory/history/staged review and required commit hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.25 - read value calls and own caller shadowing repair` — Value and function-call dispatch read; eight controls root-cause caller-local shadowing and own repair .32.

- ID: `SESSION-STARTUP-READING.3.2.26`
  Status: `done`
  Goal: Read baseline Perl group 24: 1,168 lines/fragments, 58,949 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 3744–4911.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; AST fluent/block and hash/array traversal Knowledge;
    managed AST parser suite and public traversal controls; memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source-reading and existing Knowledge chronology only.
  Verification: Exact full-file baseline identity and 1,168-line / 58,949-byte coverage pass. The AST parser suite
    passes 23 tests; public hash/array/scalar root controls match their documented traversal branches.
    Three existing Knowledge records reconcile; memory/history/review and required commit hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.26 - read receiver chains and reconcile tree dispatch` — Block and receiver dispatch read; three traversal records distinguish original milestones from current shared dispatch.

- ID: `SESSION-STARTUP-READING.3.2.27`
  Status: `done`
  Goal: Read baseline Perl group 25: 1,031 lines/fragments, 64,411 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 4912–5942.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; existing AST/fallback/retirement and numeric Knowledge;
    managed scalar numeric suite and public descriptor controls; observed group-setup warning/source and
    child PID/PGID control; memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source-reading and existing Knowledge reconciliation only.
  Verification: Exact baseline identity and 1,031-line / 64,411-byte coverage pass. The scalar numeric suite
    passes nine top-level tests; four public descriptors distinguish malformed/unknown and registered calls
    with zero raw dependency. Seven Knowledge records reconcile, including `.7` group-establishment evidence;
    required focused checks/hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.27 - read helper fallback and qualify numeric evidence` — Helper fallback and numeric/string/collection prefix read; four AST/numeric Knowledge records qualified.

- ID: `SESSION-STARTUP-READING.3.2.28`
  Status: `done`
  Goal: Read baseline Perl group 26: 1,303 lines/fragments, 64,878 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 5943–7245.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; collection/hash/constructor and mutation Knowledge;
    selected public value controls plus paired Perl Get/source and PUC Lua tagged-record controls;
    memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source-reading and Knowledge continuity only.
  Verification: Exact baseline identity and 1,303-line / 64,878-byte coverage pass. Three public constructor/copy/
    collection controls pass; two Perl Get and two fresh PUC Lua controls expose tagged-field and split drift.
    `.33.1`/`.33.2` own review/repair; focused memory/history/scope checks and required hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.28 - read collection helpers and own tagged-record repair` — Collection and constructor paths read; selector history reconciled and paired tagged-record divergence owned by .33.

- ID: `SESSION-STARTUP-READING.3.2.29`
  Status: `done`
  Goal: Read baseline Perl group 27: 977 lines/fragments, 36,165 bytes.
  Scope: `perl/LinkedSpec/ActionIR/MethodLowering.pm` lines 7246–8057; `perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm` lines 1–165.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; receiver normalization and progressive carrier Knowledge;
    selected managed progressive dispatch proof; memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and 977-line / 36,165-byte coverage pass. Managed Perl progressive
    carrier consumer passes 129 assertions; neutral progressive proof passes 9/9/116 plus public 6/12/10/60.
    Three Knowledge records reconcile; focused memory/history/scope checks and required hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.29 - read lowering suffix and reconcile progressive admission` — MethodLowering suffix and ProgressiveSpanDispatch read; three progressive admission records follow completed private closeout.

- ID: `SESSION-STARTUP-READING.3.2.30`
  Status: `done`
  Goal: Read baseline Perl group 28: 1,173 lines/fragments, 41,839 bytes.
  Scope: `perl/LinkedSpec/ActionIR/RewritePipeline.pm` lines 1–745; `perl/LinkedSpec/ActionIR/Scanner.pm` lines 1–90; `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm` lines 1–338.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; AST migration, scanner registry, and trace Knowledge;
    managed pipeline trace suite and registry census; memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and 1,173-line / 41,839-byte coverage pass. Managed pipeline
    trace proof passes five top-level tests; callable registry census confirms seven ordered dispatchers.
    Four Knowledge records reconcile; focused memory/history/scope checks and required hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.30 - read rewrite orchestration and reconcile scanner ownership` — RewritePipeline, Scanner, and FlowRules read; scanner registry and AST migration Knowledge reconciled.

- ID: `SESSION-STARTUP-READING.3.2.31`
  Status: `done`
  Goal: Read baseline Perl group 29: 1,433 lines/fragments, 41,163 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm` lines 1–1179; `perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm` lines 1–254.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; legacy/scanner and bare-read Knowledge;
    public Get value controls and child-push lowering probe; memory/Knowledge/history and staged review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and 1,433-line / 41,163-byte coverage pass. Five public Get
    controls pass, and generated child-push source confirms handler-first dispatch with binding fallback.
    Three Knowledge records reconcile; focused memory/history/scope checks and required hooks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.31 - read legacy scanners and reconcile bare push precedence` — Legacy/basic scanners read; historical scalar-slot and unconditional child-push claims reconciled with uniform binding.

- ID: `SESSION-STARTUP-READING.3.2.32`
  Status: `done`
  Goal: Read baseline Perl group 30: 1,355 lines/fragments, 48,756 bytes.
  Scope: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm` lines 1–571; `perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm` lines 1–124; `perl/LinkedSpec/ActionIR/ScannerCore.pm` lines 1–223; `perl/LinkedSpec/ActionIR/StagedParseJob.pm` lines 1–393; `perl/LinkedSpec/ActionIR/StatementSplit.pm` lines 1–44.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; staged/recognition and pipeline Knowledge;
    managed staged Perl consumer, neutral staged/recognition and language checks; memory/Knowledge/history and review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and 1,355-line / 48,756-byte coverage pass. Managed staged Perl
    consumer passes 143 checks; staged 9/9/123/public 6/17/10/129, recognition 138/250/58, and language
    250/126 proof pass. Two Knowledge records reconcile; required focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.32 - read staged scanners and reconcile authoring boundaries` — Pipeline, recognition, staged marker, and splitting owners read; two Knowledge records follow current public/neutral boundaries.

- ID: `SESSION-STARTUP-READING.3.2.33`
  Status: `done`
  Goal: Read baseline Perl group 31: 1,423 lines/fragments, 47,678 bytes.
  Scope: `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm` lines 1–419; `perl/LinkedSpec/ActionIR/StatementSplit/Mode.pm` lines 1–214; `perl/LinkedSpec/ActionIR/Trace.pm` lines 1–124; `perl/LinkedSpec/ActionIR/ValueExpr.pm` lines 1–666.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact range/full-file identity; separator/trace/value-access Knowledge;
    public splitter and parser controls, focused compact trace suite; memory/Knowledge/history and review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and 1,423-line / 47,678-byte coverage pass; four compact trace tests pass.
    Twelve distinct public comment/newline combinations isolate LF/CRLF terminator loss and CR comment loss;
    three inline cases repeat with dumped source confirmation. Repairs `.34.1`/`.34.2` own failures;
    one new and three qualified Knowledge records preserve evidence. Required focused gates precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.33 - read separator and value owners and track comment failures` — Splitter/trace/value owners read; comment failures rooted and repair-owned, universal coverage claims qualified.

- ID: `SESSION-STARTUP-READING.3.2.34`
  Status: `done`
  Goal: Read baseline Perl group 32: 1,264 lines/fragments, 39,889 bytes.
  Scope: `perl/LinkedSpec/BindingRuntime.pm` lines 1–422; `perl/LinkedSpec/CallableContract.pm` lines 1–135; `perl/LinkedSpec/CodeblockRuntime.pm` lines 1–403; `perl/LinkedSpec/InterMatchGapRuntime.pm` lines 1–291; `perl/LinkedSpec/MCPContract.pm` lines 1–12; `perl/LinkedSpec/MCPContract.pm` lines 13–13.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact baseline ranges; binding/callable/codeblock/gap Knowledge; managed callable
    and gap contracts, neutral gap proof; memory/Knowledge/history and diff review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact baseline identity and 1,264-line / 39,889-byte coverage pass. Managed callable/gap suites
    pass 134 top-level tests; neutral gap passes 9/0/63 plus public 8/15/10/34. Six public controls and
    emitted-record decoding root boolean-literal kind loss in CodeblockRuntime; `.35` owns repair.
    One new and three qualified Knowledge records preserve evidence; required focused gates precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.34 - read runtime owners and track codeblock boolean drift` — Runtime owners read; dynamic boolean result drift repair-owned and historical gap admission prose qualified.

- ID: `SESSION-STARTUP-READING.3.2.35`
  Status: `done`
  Goal: Read baseline Perl group 33: 1 lines/fragments, 32,768 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` bytes 391–33158.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact embedded-data byte range and baseline identity; MCP generated-binding and
    admission Knowledge; managed binding freshness/test and admission checker; focused continuity review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and bytes 391–33158 (32,768 bytes) pass. Managed generator
    reports the 83,411-byte Perl binding fresh; five binding tests, six artifact frame controls, and
    admission 5/5 implementations / 6/6 runtimes / complete / 141 mutations pass. One Knowledge record
    reconciles historical topology and response layers; required focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.35 - read MCP frame data and reconcile current admission` — MCP frame/schema prefix read; generated binding fresh, response examples and current admission qualified.

- ID: `SESSION-STARTUP-READING.3.2.36`
  Status: `done`
  Goal: Read baseline Perl group 34: 1 lines/fragments, 32,768 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` bytes 33159–65926.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact embedded-data range/baseline identity; MCP contract and repaired-boundary
    Knowledge; managed materializer/independent validator and artifact controls; focused continuity review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact full-file baseline identity and bytes 33159–65926 (32,768 bytes) pass. Embedded contract,
    schema, and corpus equal their neutral owners; 72 fact keys, bounded query-contract strings, and
    explicit-component-only policy controls pass. Managed materializer then independent validator pass
    35/10/10/76. Two Knowledge records reconcile; `.5` owns ADR policy clarification; focused gates precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.36 - read MCP contract policy and reconcile historical claims` — MCP policy/corpus/schema fragment read; exact neutral identity and already-repaired component policy documented.

- ID: `SESSION-STARTUP-READING.3.2.37`
  Status: `done`
  Goal: Read baseline Perl group 35: 1 lines/fragments, 17,347 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` bytes 65927–83273.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact embedded-data suffix/baseline identity; MCP payload and binding Knowledge;
    neutral payload equality, canonical bundle digest, and byte-fresh binding proof; focused continuity.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact baseline identity and bytes 65927–83273 (17,347 bytes) pass. Embedded canonical JSON
    matches its header digest and neutral payload collection; all four response and seven source-artifact
    hashes match. The complete 83,411-byte binding is byte-fresh. One Knowledge record indexes bounded
    payload/digest ownership; required focused continuity checks precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.37 - read MCP payload suffix and verify embedded digests` — MCP embedded JSON completed; four payload and seven source digests verified without runtime or protocol changes.

- ID: `SESSION-STARTUP-READING.3.2.38`
  Status: `done`
  Goal: Read baseline Perl group 36: 1,484 lines/fragments, 51,303 bytes.
  Scope: `perl/LinkedSpec/MCPContract.pm` lines 15–21; `perl/LinkedSpec/MCPContractRuntime.pm` lines 1–300; `perl/LinkedSpec/MCPServer.pm` lines 1–648; `perl/LinkedSpec/MCPWire.pm` lines 1–419; `perl/LinkedSpec/Numeric.pm` lines 1–110.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact baseline ranges; MCP runtime/wire and numeric Knowledge; managed Perl MCP
    dispatch/stdio/admission and scalar-numeric proof; focused continuity and diff review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact baseline identity and 1,484-line / 51,303-byte coverage pass. Managed MCP dispatch/
    stdio/admission suites pass 31 top-level tests; Perl numeric passes nine and neutral numeric 55/18.
    Six competing-error cases agree through decoded/stdio routes and expose ADR ordering drift, owned by
    `.36.1`–`.36.3`. One new and three updated Knowledge records preserve evidence; focused gates precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.38 - read MCP runtime and track validation order drift` — MCP/numeric owners read; validation-order discrepancy repair-owned and projection-field wording corrected.

- ID: `SESSION-STARTUP-READING.3.2.39`
  Status: `done`
  Goal: Read baseline Perl group 37: 1,496 lines/fragments, 52,208 bytes.
  Scope: `perl/LinkedSpec/PluginBridge.pm` lines 1–199; `perl/LinkedSpec/PluginRegistry.pm` lines 1–130; `perl/LinkedSpec/ProgressiveSpanDispatch.pm` lines 1–937; `perl/LinkedSpec/ProgressiveSpanDispatchPolicy.pm` lines 1–58; `perl/LinkedSpec/ProgressiveSpanDispatchRuntime.pm` lines 1–172.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact baseline ranges; plugin and progressive Knowledge; managed progressive authority/
    carrier tests and neutral contract; focused plugin boundary controls; continuity and diff review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact baseline identity and 1,496-line / 52,208-byte coverage pass. Managed progressive authority/
    carrier suites pass 138 tests; neutral proof is 9/9/116 plus public 6/12/10/60. Public plugin controls
    preserve registration/dispatch/lookup/replacement/clear/error-state and avoid legacy loading. Six progressive
    ceiling controls root resource/diagnostic gaps under `.37`; one new/four updated Knowledge records preserve
    evidence. Focused continuity gates precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.39 - read progressive authority and own ceiling enforcement gaps` — Plugin and progressive owners read; measured ceiling enforcement gaps repair-owned with exact controls.

- ID: `SESSION-STARTUP-READING.3.2.40`
  Status: `done`
  Goal: Read baseline Perl group 38: 924 lines/fragments, 33,632 bytes.
  Scope: `perl/LinkedSpec/RecognitionTransaction.pm` lines 1–655; `perl/LinkedSpec/RecognitionTransactionPolicy.pm` lines 1–269.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact baseline ranges; recognition authority/integration and known lexical defect Knowledge;
    managed authority/carrier and neutral proof; terminal-state controls; continuity and diff review.
  Canonical trigger: `none` — source reading and Knowledge continuity only.
  Verification: Exact baseline identity and 924-line / 33,632-byte coverage pass. Managed recognition authority/
    carrier suites pass 59 top-level tests; neutral proof passes 138/250/58 at 9/9 with public and admission
    guards. Six post-terminal private controls root obsolete snapshot restoration under `.38`; one new/three
    updated Knowledge records preserve the finite proof boundary. Known lexical defects remain `.21`-owned.
    Focused continuity gates precede landing.
  Commit: `SESSION-STARTUP-READING.3.2.40 - read recognition core and own post-terminal restoration defect` — Recognition core/static owners read; post-terminal cross-owner snapshot restoration repair-owned.

- ID: `SESSION-STARTUP-READING.3.2.41`
  Status: `done`
  Goal: Read baseline Perl group 39: 1,269 lines/fragments, 39,210 bytes.
  Scope: `perl/LinkedSpec/RecognitionTransactionRuntime.pm` lines 1–681; `perl/LinkedSpec/RecursiveObservationPolicy.pm` lines 1–71; `perl/LinkedSpec/RuntimeDiagnosticOutput.pm` lines 1–247; `perl/LinkedSpec/RuntimeLogical.pm` lines 1–96; `perl/LinkedSpec/RuntimeSemanticObservation.pm` lines 1–174.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Apply the mandatory change-history rollover at this checkpoint and independently verify exact clean-source
    suffix bytes, counts, hashes, and prior manifest preservation. Review only the finite member/manifest
    capacity needed through README_POLICY and a newly indexed exact-limit ADR; retain all other ceilings.
  Verification tier: `canonical`
  Focused checks: Exact source baseline; relevant runtime Knowledge and managed tests/neutral proof;
    complete-record history rollover with independent source/blob/hash proof; memory/history/routing review.
  Canonical trigger: `infrastructure` — required finite change-history capacity in the route registry.
  Verification: Exact baseline identity and 1,269-line / 39,210-byte coverage pass. Four managed Perl runtime suites
    pass 137 tests; typed, semantic, diagnostic, and logical neutral checks pass their current inventories.
    Eight value and four exit controls root `.39`/`.40` repairs. Required complete-record change-history rollover
    and independent clean-source/hash/manifest proof accompany the exact finite capacity decision ADR 0104.
    Receipt-bound canonical verification is required for the final staged infrastructure checkpoint before landing.
  Commit: `SESSION-STARTUP-READING.3.2.41 - read runtime observers and preserve bounded change history` — Runtime owners read; boolean/unwind repairs owned; exact change-history suffix and finite routing capacity preserved.

- ID: `SESSION-STARTUP-READING.3.2.42`
  Status: `done`
  Goal: Read baseline Perl group 40: 1,148 lines/fragments, 37,003 bytes.
  Scope: `perl/LinkedSpec/SemanticCallProjection.pm` lines 1–753; `perl/LinkedSpec/SemanticIndex.pm` lines 1–395.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Preserve complete forward mdBook coverage and exact current-baseline verification; own confirmed
    book drift, combined compiler-mode validation, and forward inline-lifecycle findings before Knowledge.
  Verification tier: `focused`
  Focused checks: Exact source/book baseline identity; complete forward reading evidence; managed semantic
    foundation/calls/query tests; neutral semantic/generated-source proof; public input/direct and complete
    compiler/factory mode controls; Knowledge/memory/doctrines/history pressure and final staged diff review.
  Canonical trigger: `none` — reading evidence and repair ownership only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Exact source identity and 1,148-line / 37,003-byte scoped reading pass. Three managed semantic
    suites pass 20 tests; current neutral semantic/generated-source proof is reused from the unchanged
    preceding canonical inputs. All 50 book files / 1,956,582 bytes are physically read and baseline-identical,
    with complete nonoverlapping interval/digest proof. Four public/direct input controls, nine public compiler
    controls, and eight isolated factory controls establish bounded teaching and .42 validator findings.
    .41 owns eight book-repair lanes. Four forward inline-lifecycle query controls plus two descriptors
    reproduce .43 source-member loss; no runtime/public-book repair or codebase-wide completion is claimed.
  Commit: `SESSION-STARTUP-READING.3.2.42 - read semantic projection and preserve complete book coverage` — Semantic call/index comprehension, complete book coverage, and measured book/compiler/inline-semantic repair ownership preserved.

- ID: `SESSION-STARTUP-READING.3.2.43`
  Status: `done`
  Goal: Read baseline Perl group 41: 982 lines/fragments, 35,427 bytes.
  Scope: `perl/LinkedSpec/SemanticQuery.pm` lines 1–596; `perl/LinkedSpec/SemanticRuntimeProjection.pm` lines 1–214; `perl/LinkedSpec/SemanticSourceMap.pm` lines 1–172.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact source/test/neutral baseline identity; prior passing query/runtime/foundation and neutral proof;
    full owner comprehension and existing Knowledge reconciliation; memory/doctrines/Knowledge, both history
    pressure checks, exact cleanup evidence, and staged diff review.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete 982-line / 35,427-byte reading and exact baseline identity pass. Prior canonical query (9),
    runtime-observation (106), and foundation (5) tests plus neutral 6/20/128 at 9/9 rollout and 6/6 admission
    are retained against unchanged test/source/contract inputs. Four Knowledge owners distinguish dated
    rollout from current evidence. No runtime change or whole-codebase completion is claimed.
  Commit: `SESSION-STARTUP-READING.3.2.43 - read semantic queries and source mapping` — Query/source-map and derived-observation owners read; current versus historical evidence reconciled.

- ID: `SESSION-STARTUP-READING.3.2.44`
  Status: `done`
  Goal: Read baseline Perl group 42: 1,067 lines/fragments, 34,029 bytes.
  Scope: `perl/LinkedSpec/SemanticStaticProjection.pm` lines 1–1067.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact source/static-test identity and retained canonical static proof; public Get/semantic failure controls;
    existing inline-lifecycle evidence and standalone public-checker census; precise Knowledge/repair ownership;
    memory/Knowledge/doctrines, both history pressure checks, and staged diff review.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete 1,067-line / 34,029-byte source reading and baseline identity pass; the 155-line static test
    is fully read and unchanged from the preceding five-test canonical PASS. Two exact public Get/query
    controls distinguish retained diagnostics from fabricated dependency evidence; initial controls expose
    the same classification gap for other failures. Standalone neutral proof passes 15 public documents /
    seven denials / fourteen mutations while omitting TOOLBOX. Existing .23/.41.6/.43 retain repair ownership.
  Commit: `SESSION-STARTUP-READING.3.2.44 - read static semantics and refine failure evidence` — Static projection read; failure claim narrowed to actual decision/explanation defect; omitted Toolbox guidance is repair-owned.

- ID: `SESSION-STARTUP-READING.3.2.45`
  Status: `done`
  Goal: Read baseline Perl group 43: 700 lines/fragments, 21,209 bytes.
  Scope: `perl/LinkedSpec/SourceLocation.pm` lines 1–700.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
    Keep the existing near-capacity Knowledge home bounded; route scoped compatibility detail to a
    focused linked card before edits. Preserve existing limits and record the rejected oversized candidate.
  Verification tier: `focused`
  Focused checks: Exact source/test/neutral baseline identity; retained typed-value/projection/recursive tests and neutral
    proof; full owner reading and relevant Knowledge reconciliation; memory/Knowledge/doctrines, both history
    pressure checks, and staged diff review.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete 700-line / 21,209-byte source reading and exact baseline identity pass. Prior canonical
    value/projection/recursive suites pass 18 tests across three files; typed neutral proof is 14/0/231.
    Current source/test/checker/contract inputs remain unchanged. Existing Knowledge preserves authority,
    detached values, and compatibility boundaries in bounded linked cards; no new runtime or public contract is claimed.
  Commit: `SESSION-STARTUP-READING.3.2.45 - read typed source-location authority` — Complete typed source-location owner reading and scoped existing Knowledge reconciliation.

- ID: `SESSION-STARTUP-READING.3.2.46`
  Status: `done`
  Goal: Read baseline Perl group 44: 1,498 lines/fragments, 49,952 bytes.
  Scope: `perl/LinkedSpec/StagedASTEnrichment.pm` lines 1–1498.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact bounded source and retained staged-consumer/neutral proof identities; Knowledge/contract
    reconciliation and controlled recursive-marker lifetime probes; memory/Knowledge/doctrines, both history
    pressure checks, and staged diff review.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete first-fragment reading and exact baseline identity pass: 1,498 lines / 49,952 bytes.
    Retained unchanged Perl staged proof is 143 tests; neutral/public proof is 9/9/123 and 6/17/10/129.
    All 24 native ordinary/weak/pool trials complete 24 calls without address reuse. The isolated recycling
    substitute stops two unretained trials at three calls; two retained controls finish 24. .44 owns this
    latent identity assumption; no native allocator failure or installed runtime repair is claimed.
  Commit: `SESSION-STARTUP-READING.3.2.46 - read staged authority and own marker identity risk` — Staged authority read; native lifetime proof and isolated retired-identity counterexample preserved under .44.

- ID: `SESSION-STARTUP-READING.3.2.47`
  Status: `done`
  Goal: Read baseline Perl group 45: 1,374 lines/fragments, 43,289 bytes.
  Scope: `perl/LinkedSpec/StagedASTEnrichment.pm` lines 1499–2013; `perl/LinkedSpec/StagedASTEnrichmentRuntime.pm` lines 1–120; `perl/LinkedSpec/StagedParseJob.pm` lines 1–352; `perl/LinkedSpec/StagedParseJobPolicy.pm` lines 1–59; `perl/LinkedSpec/StagedParserRegistry.pm` lines 1–328.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Complete owned staged suffix/runtime/job/policy/registry reading; exact baseline and unchanged consumer/checker/contract identity; reconcile canonical Knowledge owners and existing .44 risk; memory, history, derived Knowledge and fast commit doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: All five owned ranges read completely: 1,374 lines / 43,289 bytes; exact baseline identity passes.
    Source, Perl consumers, neutral checker and contract remain identical to the consumed canonical proof:
    Perl 143, neutral 9/9/123 and public 6/17/10/129. Knowledge distinguishes legacy cache-key metadata
    from the general scheduler and records fresh invocation/private marker ownership; .44 remains pending.
  Commit: `SESSION-STARTUP-READING.3.2.47 - read staged runtime and legacy registry boundaries` — Staged suffix/runtime/marker/policy/legacy registry read; exact unchanged proof and v1/v2 separation preserved.

- ID: `SESSION-STARTUP-READING.3.2.48`
  Status: `done`
  Goal: Read baseline Perl group 46: 521 lines/fragments, 16,259 bytes.
  Scope: `perl/LinkedSpec/Trace.pm` lines 1–521.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Full Trace reading and exact baseline identity; direct/OwnerDispatch string-and-object lazy-detail controls; retained unchanged trace/CLI proof; reconcile .24 repair and trace Knowledge; memory, history and fast doctrine checks.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Full 521-line / 16,259-byte Trace reading and exact baseline identity pass. Twenty direct/wrapped
    string/object controls isolate .24: direct quiet/plain preserve state, direct lazy cases overwrite it,
    all OwnerDispatch cases preserve it. Three generated trace suites pass 11 tests in 23 seconds.
    Existing CLI bytes/proof remain unchanged; four Knowledge owners and focused continuity reconcile.
  Commit: `SESSION-STARTUP-READING.3.2.48 - read Trace and qualify lazy exception-state evidence` — Trace read; 20 diagnostic controls and 11 passing tests qualify .24 without claiming repair.

- ID: `SESSION-STARTUP-READING.3.2.49`
  Status: `done`
  Goal: Read baseline Perl group 47: 1,500 lines/fragments, 32,073 bytes.
  Scope: `perl/LinkedSpec/UnicodeCaseMapping.pm` lines 1–1500.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Reconcile complete .31-owned first 1,500 Unicode table lines with exact baseline; read canonical data/checker/consumer authority; managed offline Unicode regeneration and Perl casing consumer; Knowledge/live continuity, memory and fast doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete prior .31 physical reading reconciled for 1,500 lines / 32,073 bytes; exact baseline
    fragment identity passes. Current offline checker regenerates all five modules and neutral JSON:
    1,563/1,581 mappings, 158/464 property ranges, 12 fixtures. Managed Perl consumer passes 52 tests
    in 13 seconds. No duplicate reading credit, generated edits, or other-backend execution claim.
  Commit: `SESSION-STARTUP-READING.3.2.49 - reconcile first generated Unicode case range` — First Unicode range reconciled; five-module regeneration and 52 Perl tests preserve pinned authority.

- ID: `SESSION-STARTUP-READING.3.2.50`
  Status: `done`
  Goal: Read baseline Perl group 48: 1,500 lines/fragments, 32,854 bytes.
  Scope: `perl/LinkedSpec/UnicodeCaseMapping.pm` lines 1501–3000.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Reconcile .31's complete 1,500-line Unicode middle-range reading and current exact baseline; retain just-consumed unchanged five-module regeneration and Perl52 proof; canonical Knowledge and reading-status consistency; memory/history/fast doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete .31-owned reading of 1,500 lines / 32,854 bytes reconciled; exact baseline fragment
    SHA-256 and unchanged table/generator/contract/checker/consumer identity pass. Retain .3.2.49's
    five-module regeneration, 12 neutral fixtures and 52 Perl tests without rerunning unchanged suites.
    Inventory Knowledge now separates completed physical mdBook reading from pending formal alignment.
  Commit: `SESSION-STARTUP-READING.3.2.50 - reconcile middle Unicode table range and reading status` — Unicode lower/upper table transition reconciled; current reading status and retained proof preserved.

- ID: `SESSION-STARTUP-READING.3.2.51`
  Status: `done`
  Goal: Read baseline Perl group 49: 835 lines/fragments, 17,404 bytes.
  Scope: `perl/LinkedSpec/UnicodeCaseMapping.pm` lines 3001–3835.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Reconcile complete .31 final Unicode range and exact baseline; contextual-property/evaluator and all 12 fixture semantics; retain unchanged regeneration/Perl52 proof; reading-capacity census and Knowledge; memory/history/fast doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete .31-owned final 835 lines / 17,404 bytes reconciled with exact baseline identity.
    All 12 fixture records match the understood evaluator, including six sigma-context controls.
    Table/generator/contract/checker/consumer bytes remain unchanged from .3.2.49's regeneration/Perl52
    proof. All three case-table checkpoints cover 3,835 lines / 82,331 bytes; codebase remains No.
  Commit: `SESSION-STARTUP-READING.3.2.51 - reconcile Unicode evaluator and contextual casing` — Final case-table range reconciled; contextual evaluator, retained proof and native-planning pressure recorded.

- ID: `SESSION-STARTUP-READING.3.2.52`
  Status: `done`
  Goal: Read baseline Perl group 50: 855 lines/fragments, 17,340 bytes.
  Scope: `perl/LinkedSpec/UnicodeXIDContinue.pm` lines 1–855.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Reconcile complete .31 XID table reading with exact baseline; ADR0051 and direct named-slot consumers; managed Unicode rule-label regeneration and direct classifier fixture/range controls; retain prior gap/CLI proof; Knowledge, memory/history and fast doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete .31-owned 855 lines / 17,340 bytes reconciled; exact baseline identity passes.
    Current Unicode regeneration: 806 ranges, 9 positive/8 negative fixtures, 2 distinct pairs.
    Direct Perl classifier: 3,224 endpoint/gap checks, 17 fixtures, 2 identity pairs PASS without warnings.
    Current gap neutral/public proof is 9/0/63 and 8/15/10/34; prior unchanged Perl124 is retained.
  Commit: `SESSION-STARTUP-READING.3.2.52 - reconcile XID classifier and current named-slot admission` — XID range and direct classifier proof recorded; stale gap Knowledge admission corrected without runtime movement.

- ID: `SESSION-STARTUP-READING.3.2.53`
  Status: `done`
  Goal: Read baseline Perl group 51: 1,202 lines/fragments, 45,829 bytes.
  Scope: `perl/LinkedSpec/UserFunctionRegistry.pm` lines 1–773; `perl/PPlugin.pm` lines 1–331; `perl/PathSearch.pm` lines 1–47; `perl/env.conf` lines 1–51.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Full prior/current function registry and legacy plugin/path/config reading; exact baseline identity; canonical spec-owned function/signature Knowledge and registered plugin controls; bounded current proof with no legacy recursive discovery; memory/history/fast doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: All four owned files reread completely: 1,202 lines / 45,829 bytes; exact baseline identity passes.
    Two managed callable suites pass 76 top-level tests in 29 seconds. Neutral signature 3/9/7 and
    codeblock 7/11/9/7/4/8/23 pass. Git census is 13 parked .plg files. Knowledge reconciles spec-owned
    parsing, versioned metadata, and legacy discovery without runtime/grammar or public-book changes.
  Commit: `SESSION-STARTUP-READING.3.2.53 - reconcile function registry and legacy discovery` — Function registry and legacy files read; 76 tests and neutral proof recorded; 13-file corpus count corrected.

- ID: `SESSION-STARTUP-READING.3.2.54`
  Status: `done`
  Goal: Read baseline Perl group 52: 839 lines/fragments, 22,702 bytes.
  Scope: `perl/gdcheck.pl` lines 1–431; `perl/htmlcss_driver.pl` lines 1–166; `perl/ptchange.pl` lines 1–242.
  Acceptance: Read every owned byte and apply the shared Perl-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Complete utility source reading and exact baseline identities; existing .25/.26 diagnostic Knowledge; managed syntax checks without executing legacy driver outputs; memory, bounded history, and all fast doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: All three utility files reread through EOF: 839 lines / 22,702 bytes, baseline-identical.
    Managed syntax checks pass for each file; nine targeted gdcheck assertions reproduce the already owned
    signed-tolerance, duplicate-row, and DEFAULT defects. Prior ptchange spaced-path evidence is retained.
    No repair or public-book change. .3.2.55 owns canonical parent closeout and complete Rust decomposition.
  Commit: `SESSION-STARTUP-READING.3.2.54 - reconcile legacy utility reading and repair evidence` — 839 utility lines reread; exact diagnostic control retained; .55 owns canonical closeout.

- ID: `SESSION-STARTUP-READING.3.2.55`
  Status: `done`
  Goal: Close the fully read Perl lane and own the complete bounded Rust reading plan.
  Acceptance: Independently reconcile all 89 baseline Perl paths and current deltas with the 53 completed
    reading leaves plus their decomposition checkpoint and .31's physical ledger. Preserve every pending repair and distinguish reading
    completion from runtime signoff. Verify exact disjoint Rust scope/budgets for all 412 baseline entries,
    review semantic boundaries and current deltas, and create reading children before reading new Rust code.
    Measure resulting task-collection pressure and reserve room for evidence; no capacity change is implied.
    Update canonical Knowledge and bounded continuity; run exact staged canonical CI for the parent closeout.
  Verification tier: `canonical`
  Focused checks: Independent Perl interval/commit/delta proof; complete bounded Rust range/corpus and empty-file coverage; resulting task pressure; Knowledge, memory, both history checks, exact staged diff and canonical tools/run_ci_local.sh.
  Canonical trigger: `parent closeout` — formal Perl reading parent closeout; exact staged canonical receipt required.
  Verification: Independent byte-interval and commit audit passes: all 89 Perl files / 2,133,690 bytes,
    53 reading leaves plus one decomposition checkpoint, exact EOF coverage and no source delta.
    Rust plan and task Scope round-trip pass: 66 groups / 412 paths / 3,533,382 bytes, two empty inputs,
    1,500-line and 65,536-byte maxima. No new Rust reading credit or repair closure. Final staged canonical
    receipt is mandatory before this parent closeout lands; the committed hook/receipt establishes its result.
  Commit: `SESSION-STARTUP-READING.3.2.55 - close Perl reading and own bounded Rust scopes` — Close 89-file Perl reading; own all 412 Rust paths in 66 bounded leaves plus closeout; exact canonical boundary.

- ID: `SESSION-STARTUP-READING.3.3`
  Status: `done`
  Goal: Split and read all 412 baseline Rust entries, including source, tests, corpus, generated files, and manifests.
  Acceptance: Define bounded file/range children before reading; `rgx` is excluded but first-party Rust is not.
  Children: `.3.3.1`, `.3.3.2`, `.3.3.3`, `.3.3.4`, `.3.3.5`, `.3.3.6`, `.3.3.7`, `.3.3.8`, `.3.3.9`, `.3.3.10`, `.3.3.11`, `.3.3.12`, `.3.3.13`, `.3.3.14`, `.3.3.15`, `.3.3.16`, `.3.3.17`, `.3.3.18`, `.3.3.19`, `.3.3.20`, `.3.3.21`, `.3.3.22`, `.3.3.23`, `.3.3.24`, `.3.3.25`, `.3.3.26`, `.3.3.27`, `.3.3.28`, `.3.3.29`, `.3.3.30`, `.3.3.31`, `.3.3.32`, `.3.3.33`, `.3.3.34`, `.3.3.35`, `.3.3.36`, `.3.3.37`, `.3.3.38`, `.3.3.39`, `.3.3.40`, `.3.3.41`, `.3.3.42`, `.3.3.43`, `.3.3.44`, `.3.3.45`, `.3.3.46`, `.3.3.47`, `.3.3.48`, `.3.3.49`, `.3.3.50`, `.3.3.51`, `.3.3.52`, `.3.3.53`, `.3.3.54`, `.3.3.55`, `.3.3.56`, `.3.3.57`, `.3.3.58`, `.3.3.59`, `.3.3.60`, `.3.3.61`, `.3.3.62`, `.3.3.63`, `.3.3.64`, `.3.3.65`, `.3.3.66`, `.3.3.67`
  Verification: All 412 baseline paths / 3,533,382 bytes are physically read and comprehension-reconciled across 66 committed bounded children. .3.3.67 independently verifies exact byte coverage, current mode/blob identity, durable subjects, Knowledge continuity and pending repair ownership; receipt-bound canonical proof is required for parent landing. This status certifies reading completion only. Containment .7 precedes Dart decomposition/reading.
  Commit: `SESSION-STARTUP-READING.3.3.67 - close Rust reading with exact coverage and durable repair ownership`


- ID: `SESSION-STARTUP-READING.3.3.1`
  Status: `done`
  Goal: Read Rust group 1: 1,496 lines/fragments, 37,995 bytes.
  Scope: `rust/.gitignore` lines 1–3;
    `rust/Cargo.lock` lines 1–1493.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact ignore/lockfile-range identity and 199-package TOML census; retained CLI/core and four regex-boundary controls; task-first .45–.47 and .49 ownership; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Complete ignore file and lockfile prefix read: 1,496 lines / 37,995 bytes, baseline-identical.
    Locked TOML census: v4, 199 unique package identities, 195 registry checksums, four local records.
    Retain preceding exact canonical parent closeout; ordinary checkpoint needs focused proof only.
    Forward evidence is owned by .45–.47 and .49: eleven earlier CLI controls, the isolated core program,
    and four new regex-boundary controls. No repair closes.
  Commit: `SESSION-STARTUP-READING.3.3.1 - read Rust lockfile prefix and own parser boundary repairs` — Read 1,496 lock/ignore lines; own malformed-block, Unicode diagnostic, mutation-argument, and regex-newline repairs; retain prior canonical milestone.

- ID: `SESSION-STARTUP-READING.3.3.2`
  Status: `done`
  Goal: Read Rust group 2: 1,483 lines/fragments, 59,455 bytes.
  Scope: `rust/Cargo.lock` lines 1494–1850;
    `rust/Cargo.toml` lines 1–18;
    `rust/README.md` lines 1–484;
    `rust/linkedspec-core/Cargo.toml` lines 1–14;
    `rust/linkedspec-core/src/ast.rs` lines 1–360;
    `rust/linkedspec-core/src/callable_contract.rs` lines 1–250.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact six-scope baseline/budget proof; locked offline Cargo metadata and manifest comparison; neutral cursor contract; existing cursor/callable Knowledge; scoped README/comment repair ownership; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: All six scopes read: 1,483 lines / 59,455 bytes; exact range hashes and complete current files match baseline.
    Locked offline metadata resolves 199 packages and declares Rust 1.95 for rgx-core/pgen, contradicting
    README 1.85+; no old-toolchain run or earliest working compiler is claimed. Neutral cursor contract
    passes 36 family/18 edge/8 parent-child cases and 60 drift mutations. Documentation repairs stay pending.
  Commit: `SESSION-STARTUP-READING.3.3.2 - read Rust manifests AST and callable prefix` — Read 1,483 manifest/AST/callable lines; own exact README minimum-version and mode-comment evidence.

- ID: `SESSION-STARTUP-READING.3.3.3`
  Status: `done`
  Goal: Read Rust group 3: 1,499 lines/fragments, 56,169 bytes.
  Scope: `rust/linkedspec-core/src/callable_contract.rs` lines 251–394;
    `rust/linkedspec-core/src/compiler.rs` lines 1–1355.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Two exact reading ranges/current-baseline proof; existing callable/compiler Knowledge; neutral callable and aggregate-selector checks; pending .45/.47 boundary evidence; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Both scopes read: 1,499 lines / 56,169 bytes; exact range hashes and complete current files match baseline.
    Reconcile callable normalization, validation order, recognition effects, typed write/mutation checks, and
    lifecycle/edge lowering against existing Knowledge. Prior .45/.47 observations remain diagnostic evidence,
    not completed repairs. Neutral callable checks pass 7/11 literals/calls, 9/7 invalid cases, four invalid declarations, eight
    contextual forms and 23 mutations; selector scan reports zero positive / 20 classified occurrences.
    Required continuity checks pass before commit.
  Commit: `SESSION-STARTUP-READING.3.3.3 - read callable normalization and compiler validation prefix` — Read 1,499 callable/compiler lines; preserve validation order and exact pending repair boundaries.

- ID: `SESSION-STARTUP-READING.3.3.4`
  Status: `done`
  Goal: Read Rust group 4: 1,481 lines/fragments, 57,687 bytes.
  Scope: `rust/linkedspec-core/src/compiler.rs` lines 1356–2153;
    `rust/linkedspec-core/src/descriptor.rs` lines 1–465;
    `rust/linkedspec-core/src/entry_rule.rs` lines 1–113;
    `rust/linkedspec-core/src/error.rs` lines 1–105.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Four exact reading ranges/current-baseline proof; existing descriptor/entry/slot Knowledge; neutral slot identity and entry-selection contracts; .41.2 source-comment ownership and retained native duplicate-label rejection; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: All four scopes read: 1,481 lines / 57,687 bytes; exact range hashes and complete current files match baseline.
    Reconcile selector resolution, self-edge slot reuse, pure descriptor projection, entry precedence, and
    sorted portable diagnostics with existing Knowledge. Confirm source-comment repair ownership and retain
    native duplicate-label rejection evidence. Neutral slot checks pass 5 fixtures / 2 diagnostics / 59 mutations; entry checks pass 8 selection /
    3 failure / 3 strict cases / 54 mutations. Required continuity checks pass before commit.
  Commit: `SESSION-STARTUP-READING.3.3.4 - read Rust regex resolution descriptors and entry diagnostics` — Read 1,481 compiler/descriptor/entry/error lines; separate projection determinism from native validation.

- ID: `SESSION-STARTUP-READING.3.3.5`
  Status: `done`
  Goal: Read Rust group 5: 1,496 lines/fragments, 57,175 bytes.
  Scope: `rust/linkedspec-core/src/expr.rs` lines 1–1496.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact expression prefix/current-baseline proof; existing callable/staged/write/control-flow Knowledge; neutral staged-enrichment and write-vivification contracts; retained .45–.47/.49 repair ownership; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Owned expr.rs lines 1–1496 fully read: 1,496 lines / 57,175 bytes; exact range hash and complete
    current file match baseline. Reconcile typed callable/write/mutation/staged carriers, source coordinates,
    recursive scans, literal options and statement normalization with existing Knowledge. Neutral staged checks pass 123 core / 129 public mutations; write checks pass 5 valid / 7 invalid /
    11 success / 16 structural / 3 evaluation / 3 exclusion / 8 composed cases and 105 mutations.
    Required continuity checks pass before commit; no fresh native-suite execution is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.5 - read Rust expression carriers and statement parser prefix` — Read 1,496 expression/statement lines; separate byte cursors, character spans and debug formatting.

- ID: `SESSION-STARTUP-READING.3.3.6`
  Status: `done`
  Goal: Read Rust group 6: 1,461 lines/fragments, 54,270 bytes.
  Scope: `rust/linkedspec-core/src/expr.rs` lines 1497–2957.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact expression continuation/current-baseline proof; existing callable/write/mutation/hash Knowledge; neutral map-leaves mutation contract; unchanged bounded .45/.46/.47 diagnostics; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Owned expr.rs lines 1497–2957 fully read: 1,461 lines / 54,270 bytes; exact range hash and complete
    current file match baseline. Reconcile attached controls, source-preserving nested writes/mutations,
    scalar staged intrinsics, expression dispatch and brace classification. Existing .45/.46/.47 diagnostic
    controls retain their exact limits. Neutral mutation checks pass 4 valid / 14 invalid / 5 excluded syntax cases, 10 successes,
    8 pre-commit failures, 6 callback / 1 continuation compositions, and 167 + 592 mutations.
    Required continuity checks pass before commit.
  Commit: `SESSION-STARTUP-READING.3.3.6 - read Rust expression parsing and retain boundary repair evidence` — Read 1,461 expression-parser lines; retain exact Unicode and mutation-whitespace repair evidence.

- ID: `SESSION-STARTUP-READING.3.3.7`
  Status: `done`
  Goal: Read Rust group 7: 1,497 lines/fragments, 56,871 bytes.
  Scope: `rust/linkedspec-core/src/expr.rs` lines 2958–4454.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact lexical/test range/current-baseline proof; existing arithmetic/hash/callable and .49 Knowledge; neutral callable contract; historical assignment-closure pointer; six asserted Rust CLI/Perl lowering hash controls; three paired native cat controls; task-first .50/.51 ownership; Knowledge/memory/all doctrines/history and final scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Owned expr.rs lines 2958–4454 fully read: 1,497 lines / 56,871 bytes; exact range hash and complete
    current file match baseline. Neutral callable checks pass 7/11 literals/calls, 9/7 invalid cases,
    four invalid declarations, eight contextual forms and 23 mutations. Six asserted Rust CLI/Perl lowering
    hash controls establish adjacent-colon loss; three paired explicit-edge Rust CLI/Perl Get controls
    establish one-argument cat divergence. .50/.51 own repairs before Knowledge. Prior .49 evidence retains
    its limits. Required continuity checks pass before commit; no runtime repair is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.7 - read Rust lexical boundaries and own hash and cat repairs` — Read 1,497 lexical/test lines; own adjacent hash-colon loss and cat arity divergence as .50/.51.

- ID: `SESSION-STARTUP-READING.3.3.8`
  Status: `done`
  Goal: Read Rust group 8: 1,470 lines/fragments, 57,396 bytes.
  Scope: `rust/linkedspec-core/src/expr.rs` lines 4455–5819;
    `rust/linkedspec-core/src/lib.rs` lines 1–27;
    `rust/linkedspec-core/src/parser.rs` lines 1–78.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read all three exact ranges without truncation; current-baseline and range-digest proof; existing AST/expression/entry Knowledge reconciliation; selected neutral write/callable/uniform-binding contracts; historical assignment/rollout Knowledge correction; .41.6 stale test-name ownership; Knowledge/memory/all doctrines/history and scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: All three exact ranges read without truncation: 1,470 lines / 57,396 bytes; current files and
    range digests match baseline. Fresh neutral write checks pass 5/7/11/16/3/3/8/105; callable checks
    pass 7/11/9/7/4/8/23; uniform binding passes 11/7/6/8. Historical rollout/storage guidance and test
    assertion limits are reconciled in Knowledge; .41.6 owns stale test naming. Required continuity
    checks pass before commit. No native suite, runtime repair or complete-codebase claim.
  Commit: `SESSION-STARTUP-READING.3.3.8 - read remaining Rust expression tests and core parser entry` — Complete expr.rs reading and core entry prefix; reconcile test assertion limits and historical binding/rollout prose.

- ID: `SESSION-STARTUP-READING.3.3.9`
  Status: `done`
  Goal: Read Rust group 9: 1,496 lines/fragments, 49,733 bytes.
  Scope: `rust/linkedspec-core/src/parser.rs` lines 79–1574.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read the exact parser continuation without truncation; current-baseline and range-digest proof; existing rule-header/grouped-edge/body-parser Knowledge reconciliation and Toolbox-first controls for surprises; neutral standalone/cursor/Unicode contracts; ten paired native body controls, three paired matches controls, direct Perl lowering/bootstrap controls; .52-.54 task-first ownership; Knowledge/memory/all doctrines/history and scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Read parser.rs 79–1574 completely: 1,496 lines / 49,733 bytes; range digest and complete file
    match baseline. Neutral standalone 9/4/6/3/6/15/7/14, cursor 36/18/8/60 and Unicode 806/9/8/2
    checks pass. Ten paired native body cases, three paired matches cases, four Perl lowering controls and
    three direct bootstrap dumps isolate compact fluent, header suffix and regex-brace defects. .52-.54
    own bounded repairs before Knowledge. All diagnostic processes completed; required continuity proof
    passes before commit. No runtime, public-book, full-native or whole-codebase signoff.
  Commit: `SESSION-STARTUP-READING.3.3.9 - read Rust rule-body parsing and own lexical boundary repairs` — Read rule-body parser; own compact fluent, invalid header suffix and Perl/Rust regex-brace repairs .52-.54.

- ID: `SESSION-STARTUP-READING.3.3.10`
  Status: `done`
  Goal: Read Rust group 10: 1,466 lines/fragments, 47,137 bytes.
  Scope: `rust/linkedspec-core/src/parser.rs` lines 1575–2084;
    `rust/linkedspec-core/src/trace.rs` lines 1–715;
    `rust/linkedspec-core/src/types.rs` lines 1–241.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read every scoped parser/trace/type byte without truncation; range/current-baseline proof; existing trace/cursor/compiled-state Knowledge reconciliation; managed seven-test core trace target; neutral cursor/numeric contracts; four paired native large-number controls and source projection path; .55 task-first ownership; Knowledge/memory/all doctrines/history and scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Read parser.rs 1575–2084, trace.rs 1–715 and types.rs 1–241 completely: 1,466 lines / 47,137
    bytes; exact ranges and complete files match baseline. Managed core trace 7/7; neutral numeric
    55/18 and cursor 36/18/8/60 pass. Four paired native number controls prove signed large-value saturation
    and distinct text spelling; .55 owns repairs before Knowledge. All jobs completed; focused continuity
    passes before commit. No runtime/public-book change or fresh cross-backend trace signoff.
  Commit: `SESSION-STARTUP-READING.3.3.10 - read core trace and types and own large-number conversion repairs` — Read parser tests/core trace/types; own finite-value saturation and large-number text repairs .55.

- ID: `SESSION-STARTUP-READING.3.3.11`
  Status: `done`
  Goal: Read Rust group 11: 1,499 lines/fragments, 45,494 bytes.
  Scope: `rust/linkedspec-core/src/types.rs` lines 242–538;
    `rust/linkedspec-core/src/unicode_rule_label.rs` lines 1–850;
    `rust/linkedspec-core/src/validation.rs` lines 1–352.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read every scoped compiled-type, Unicode table/function and validation byte without truncation; exact range/current-baseline proof; retrieve compiled-slot/cursor/Unicode Knowledge first; neutral Unicode label, rule-local cursor and duplicate-slot contracts; reconcile source-only limits and any task-owned findings; Knowledge/memory/all doctrines/history and scope/diff.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: Read types.rs 242–538, unicode_rule_label.rs 1–850 and validation.rs 1–352 completely:
    1,499 lines / 45,494 bytes; exact ranges and complete files match baseline. Neutral Unicode 806/9/8/2,
    cursor 36/18/8/60 and duplicate-slot 5/2/59 pass. Reconcile derived cursor/serde state, UTF-8 prefix
    boundaries and ordinary/traced AST pass order; .41.2 owns stale validation comments. Focused continuity
    passes before commit. No fresh native matrix, runtime, public-book, or whole-codebase signoff.
  Commit: `SESSION-STARTUP-READING.3.3.11 - read compiled types Unicode labels and validation entrypoints` — Read compiled types and pinned Unicode through EOF plus AST-validation entrypoints; reconcile historical/current claims.

- ID: `SESSION-STARTUP-READING.3.3.12`
  Status: `done`
  Goal: Read Rust group 12: 1,490 lines/fragments, 54,844 bytes.
  Scope: `rust/linkedspec-core/src/validation.rs` lines 353–1541;
    `rust/linkedspec-core/tests/descriptor_test.rs` lines 1–286;
    `rust/linkedspec-core/tests/rule_local_cursor_normalization_test.rs` lines 1–15.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
    Complete the required engineering-notes rollover from exact clean HEAD records; independently verify
    source/blob/hash and unchanged prior manifest. Measure resulting root/collection pressure and own one
    finite member/manifest slot through indexed ADR 0105 before changing route limits. Preserve all other
    ceilings and immutable history. Run exact staged canonical CI for the necessary routing-infrastructure step.
  Verification tier: `canonical`
  Focused checks: Read every remaining validator, descriptor-test and cursor-test-prefix byte; exact range/current-baseline proof; retrieve strict/slot/named-selector/gap/root/cursor Knowledge before diagnosis; managed locked/offline core validation tests and neutral named-slot/root/cursor contracts; four paired registry controls, five paired AND selector controls and four Perl descriptor projections; .56/.57 ownership; task-own any confirmed gaps before Knowledge; independent lossless rollover/pressure proof, ADR 0105 exact-count authorization, memory/all doctrines/history, exact staged canonical receipt and scope/diff.
  Canonical trigger: `routing capacity infrastructure` — required engineering-notes rollover crosses
    the existing finite member/manifest counts; exact indexed limit authorization and staged canonical receipt.
  Verification: Read validation.rs 353–1541, descriptor_test.rs 1–286 and cursor test 1–15 completely:
    1,490 lines / 54,844 bytes; exact ranges and complete files match baseline. Managed core validation
    passes 21/21 (180 filtered); neutral gap 9/0/63 plus public34, root 8/3/3/54 and cursor 36/18/8/60
    pass. Four paired registry controls, five paired AND selector controls and four Perl descriptor
    projections prove .56/.57 repairs. Lossless segment 4983 proof passes for 206 lines / 17,316 bytes;
    indexed ADR 0105 admits only files 24→25 and manifest lines 23→24. Exact staged canonical proof is
    required before this candidate can land; the receipt and commit hooks enforce that boundary.
    No runtime/public-book change or fresh descriptor/generated/backend-wide signoff.
  Commit: `SESSION-STARTUP-READING.3.3.12 - read static validation and preserve bounded engineering history` — Complete validator/descriptor reading; own .56/.57; preserve segment 4983 with finite ADR 0105 capacity and canonical proof.

- ID: `SESSION-STARTUP-READING.3.3.13`
  Status: `done`
  Goal: Read Rust group 13: 1,495 lines/fragments, 52,012 bytes.
  Scope: `rust/linkedspec-core/tests/rule_local_cursor_normalization_test.rs` lines 16–314;
    `rust/linkedspec-core/tests/types_test.rs` lines 1–222;
    `rust/linkedspec-core/tests/unicode_rule_label_contract.rs` lines 1–155;
    `rust/linkedspec-runtime/Cargo.toml` lines 1–20;
    `rust/linkedspec-runtime/src/bin/linkedspec-rust.rs` lines 1–21;
    `rust/linkedspec-runtime/src/bounded_child_parse_authority.rs` lines 1–778.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read every owned cursor/value/Unicode-test, runtime-manifest/CLI entry, and bounded-child-authority byte; exact range/current-baseline proof; retrieve cursor, scalar/value, Unicode and bounded-child/transaction authority Knowledge first; select managed locked/offline core integration tests and neutral directly dependent contracts; preserve finalized slice71 canonical and dated diagnostic evidence, remove only consumed exact sample reports after durable intake, and annotate existing .41.7 current-count debt; memory/all doctrines/history and scope/diff. No runtime or public-book repair before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: exact six-range/baseline identity; managed locked/offline core cursor 5/5, types 8/8 and Unicode 5/5; four neutral contract checks; completed prior canonical/sample intake; Knowledge, history, memory, all nine doctrines and diff.
  Commit: `SESSION-STARTUP-READING.3.3.13 - read core tests and bounded child authority` — Read six Rust ranges, preserve exact verification limits and prior canonical evidence, and remove only consumed captures.

- ID: `SESSION-STARTUP-READING.3.3.14`
  Status: `done`
  Goal: Read Rust group 14: 1,494 lines/fragments, 50,413 bytes.
  Scope: `rust/linkedspec-runtime/src/bounded_child_parse_authority.rs` lines 779–1639;
    `rust/linkedspec-runtime/src/diagnostic.rs` lines 1–127;
    `rust/linkedspec-runtime/src/diagnostic_output.rs` lines 1–112;
    `rust/linkedspec-runtime/src/engine.rs` lines 1–394.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read all four owned ranges and reconcile boundary context; exact range/current-baseline identity; retrieve bounded-child, runtime diagnostic and engine authority Knowledge first; focused progressive/source/diagnostic contract checks and dated unchanged-source canonical consumer evidence; diagnose any newly observed mismatch with LinkedSpec tools before owning repair; Knowledge, both history pressure checks, memory/all doctrines and scope/diff. No runtime or public-book repair before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: four exact baseline-identical ranges; progressive 9/9/116/public60, typed source 14/0/231, diagnostic output 3/11/6/8/20, scalar numeric 55/18; bounded ceiling-constructor/test-source review; Knowledge/history/memory/all nine doctrines and diff.
  Commit: `SESSION-STARTUP-READING.3.3.14 - read child authority diagnostics and engine definitions` — Finish authority and diagnostic-type reading; reconcile current options/diagnostic Knowledge and resource-boundary limits.

- ID: `SESSION-STARTUP-READING.3.3.15`
  Status: `done`
  Goal: Read Rust group 15: 1,500 lines/fragments, 56,911 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 395–1894.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 395–1894 in untruncated chunks with preceding context and exact suffix ownership; current/full-file baseline and range identity; Knowledge-first nested-write, receiver-mutation and invocation/diagnostic authorities; selected managed direct-dependent neutral contracts, bounded source/claim review, paired managed Rust/Perl pure-split boundary controls under existing .33, and dated native evidence; both history checks, explicit memory, derived Knowledge, staged diff and all nine pre-commit doctrines. No runtime/public/policy repair before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: exact engine range/baseline identity; seven managed neutral checks; managed CLI build; seven paired Rust/Perl split controls with five differences/two equal controls; .33 ownership and exact evidence; Knowledge/history/explicit memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.15 - read generated engine loops and audit split boundaries` — Read generated action/blind loops, preserve exact scope, and annotate measured split boundaries under existing .33.

- ID: `SESSION-STARTUP-READING.3.3.16`
  Status: `done`
  Goal: Read Rust group 16: 1,500 lines/fragments, 60,181 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 1895–3394.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 1895–3394 completely with exact current/baseline range identity; retrieve existing Knowledge authorities before analyzing invocation and entry dispatch; selected direct-dependent neutral checks and bounded claim reconciliation; both history checks, explicit memory, derived Knowledge, staged diff and all nine pre-commit doctrines. Preserve dated native evidence and later runtime/public/policy repair ownership.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete range/current-baseline identity; root, semantic, diagnostic-output and staged-AST neutral checks; bounded generated-validation support; Knowledge/history/explicit memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.16 - read engine invocation routes and entry dispatch` — Reconcile execution projections, diagnostic stages and precedence, generated validation ownership and parent-result ordering.

- ID: `SESSION-STARTUP-READING.3.3.17`
  Status: `done`
  Goal: Read Rust group 17: 1,493 lines/fragments, 60,008 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 3395–4887.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 3395–4887 fully with preceding context, exact current/baseline identity and suffix ownership; retrieve Knowledge before analyzing native regex loops and action handling; run selected direct-dependent neutral contracts, both history checks, explicit memory, derived Knowledge, staged diff and all nine pre-commit doctrines. Preserve dated native evidence and startup repair prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete range/current-baseline identity; six managed neutral contracts; four native diagnostic controls and independent result-field assertions; .55.1 repair ownership; Knowledge/history/explicit memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.17 - read native action loops and nested-write coordination` — Read native loops/control and nested-write evaluation order; preserve exact diagnostic evidence and following traversal scope.

- ID: `SESSION-STARTUP-READING.3.3.18`
  Status: `done`
  Goal: Read Rust group 18: 1,498 lines/fragments, 58,503 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 4888–6385.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 4888–6385 completely with prior coordinator context, current/baseline identity and suffix ownership; retrieve Knowledge for nested writes, receiver mutation and expression execution; selected managed direct-dependent neutral contracts and bounded claim verification; both history checks, explicit memory, derived Knowledge, staged diff and all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete range/current-baseline identity; four managed neutral contracts; bounded Knowledge claim review; history/explicit memory/derived Knowledge/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.18 - read recursive writes and expression invocation scopes` — Complete recursive-write and expression/callable invocation reading with separate function/codeblock scope boundaries.

- ID: `SESSION-STARTUP-READING.3.3.19`
  Status: `done`
  Goal: Read Rust group 19: 1,493 lines/fragments, 55,743 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 6386–7878.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 6386–7878 completely with preceding trailing-block context and exact suffix ownership; current/baseline identity; Knowledge-first traversal, receiver mutation and value-chain reconciliation; selected managed direct-dependent neutral contracts; both history checks, explicit memory, derived Knowledge, staged diff and all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete range/current-baseline identity; four managed neutral contracts; six paired Rust CLI/Perl Get cases plus six direct native diagnostics and independent field/value assertions; .58 repair ownership; compiler sample consumed; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.19 - read receiver traversal and diagnose final-assignment guard` — Complete traversal/value-block reading; own confirmed final-assignment guard gap and preserve exact native/reference evidence.

- ID: `SESSION-STARTUP-READING.3.3.20`
  Status: `done`
  Goal: Read Rust group 20: 1,400 lines/fragments, 65,528 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 7879–9278.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 7879–9278 completely with preceding scalar-target context and precise helper suffix ownership; current/baseline identity; Knowledge-first target/binding/helper reconciliation; selected managed direct-dependent neutral contracts and bounded diagnosis if needed; both history checks, explicit memory, derived Knowledge, staged diff and all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete range/current-baseline identity; four managed neutral contracts; ten paired Rust primary/Perl Get cases with exact values/error fields; ten lowerings/generated captures and six callback descriptor controls; .59 repair ownership; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.20 - read helper dispatch and own substitution composition repairs` — Complete helper-prefix reading; own substitution flags, callback lowering and receiver protection with exact paired evidence.

- ID: `SESSION-STARTUP-READING.3.3.21`
  Status: `done`
  Goal: Read Rust group 21: 1,499 lines/fragments, 59,677 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 9279–10777.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine lines 9279–10777 completely with match_end_line prefix context and exact suffix ownership; current/baseline identity; Knowledge-first helper/capture/collection/logical reconciliation; selected managed direct-dependent neutral contracts and bounded diagnosis when needed; history/memory/derived Knowledge/staged diff and all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete range/current-baseline identity; three managed neutral contracts; eleven paired Rust primary/Perl Get cases plus one Rust-only overflow control; twelve ready descriptors/lowered/generated captures; exact values/kinds/panic-site assertions; .60/.61 ownership; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.21 - complete helper reading and own slice and scalar boundary repairs` — Complete helper implementation and test-prefix reading; own array slicing and scalar null/empty repair with bounded exact evidence.

- ID: `SESSION-STARTUP-READING.3.3.22`
  Status: `done`
  Goal: Read Rust group 22: 1,469 lines/fragments, 52,089 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 10778–12246.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read engine test lines 10778–12246 completely and distinguish exact assertions from names/comments; current/baseline identity; Knowledge-first helper/capture/control/guard reconciliation; selected managed direct-dependent neutral checks and bounded diagnostics only where new evidence requires them; history/memory/derived Knowledge/staged diff and all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: full 1,469-line source read/current-baseline identity; five paired primary Rust/live Perl exact value/effect/JSON-kind controls; five ready descriptors/lowered/generated captures; three managed neutral contracts; .62 ownership and four Knowledge corrections; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.22 - read capture and control tests and own coalesce evaluation repair` — Read capture/control assertions, qualify weak smoke coverage, and own coalesce definedness/laziness with corrected Boolean observations.

- ID: `SESSION-STARTUP-READING.3.3.23`
  Status: `done`
  Goal: Read Rust group 23: 1,364 lines/fragments, 53,265 bytes.
  Scope: `rust/linkedspec-runtime/src/engine.rs` lines 12247–12694;
    `rust/linkedspec-runtime/src/helpers.rs` lines 1–850;
    `rust/linkedspec-runtime/src/lib.rs` lines 1–66.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read the complete engine test suffix, regex helpers and runtime export surface; exact baseline identity and Knowledge-first reconciliation; selected managed write/capture/regex direct-dependent checks and bounded probes only for newly established gaps; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines. No runtime/public/policy repairs before prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: complete 1,364-line/53,265-byte source read/current-baseline identity; three managed write/mutation/slot neutral contracts; six informative paired primary Rust/live Perl choice probes plus six retained inconclusive controls; six three-rule descriptors/generated captures; exact sequence/error assertions; .63 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.23 - complete engine and regex helper reading and own input-context repair` — Complete engine tests and regex wrappers; own five assertion discrepancies with exact collected-rule controls.

- ID: `SESSION-STARTUP-READING.3.3.24`
  Status: `done`
  Goal: Read Rust group 24: 7 lines/fragments, 65,536 bytes.
  Scope: `rust/linkedspec-runtime/src/mcp_contract.rs` lines 1–6;
    `rust/linkedspec-runtime/src/mcp_contract.rs` bytes 298–65536.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read every owned byte of the embedded MCP contract prefix, using untruncated raw segments and decoded structural cross-checks; exact baseline/authority identity; Knowledge-first contract/provider/generated snapshot reconciliation; selected managed MCP direct-dependent checks; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: all 65,536 owned bytes read without truncation and baseline-identical; both managed generated bindings byte-fresh; transport 35/10/10/76 and admission complete 5/5+6/6/141; decoded bundle/frame/schema assertions; shared builder/renderer source identity; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.24 - read embedded MCP contract prefix and reconcile generated identity` — Preserve exact generated-prefix coverage and identity, update old sizes, distinguish artifact/governance proof from runtime execution.

- ID: `SESSION-STARTUP-READING.3.3.25`
  Status: `done`
  Goal: Read Rust group 25: 1,352 lines/fragments, 65,134 bytes.
  Scope: `rust/linkedspec-runtime/src/mcp_contract.rs` bytes 65537–83225;
    `rust/linkedspec-runtime/src/mcp_contract_runtime.rs` lines 1–582;
    `rust/linkedspec-runtime/src/mcp_server.rs` lines 1–769.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read all remaining embedded contract bytes, the complete frozen MCP runtime and server lines 1–769; exact baseline/authority identity; Knowledge-first schema/dispatch/registry/policy reconciliation; selected managed MCP direct-dependent checks and bounded diagnostic probes where evidence requires; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/proof: all 1,352 lines/fragments/65,134 bytes baseline-identical; generated binding byte-fresh; transport 35/10/10/76, admission complete/141; existing native test 1/1 and captured-output gap independently confirmed/owned .64; Knowledge/history/memory/staged diff/all nine pre-commit doctrines. Runtime repair remains pending.
  Commit: `SESSION-STARTUP-READING.3.3.25 - read frozen MCP runtime and own caught-panic output repair` — Preserve frozen-runtime/registry coverage and separate response sanitation from captured process output; own .64 repair and qualify native reachability.

- ID: `SESSION-STARTUP-READING.3.3.26`
  Status: `done`
  Goal: Read Rust group 26: 1,500 lines/fragments, 51,296 bytes.
  Scope: `rust/linkedspec-runtime/src/mcp_server.rs` lines 770–1342;
    `rust/linkedspec-runtime/src/mcp_wire.rs` lines 1–759;
    `rust/linkedspec-runtime/src/primary_cli.rs` lines 1–168.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read server 770–1342, all strict MCP wire code and primary CLI 1–168; exact baseline identity; Knowledge-first policy/wire/CLI reconciliation; selected managed MCP wire tests and neutral/direct-dependent checks; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/proof: all 1,500 lines/51,296 bytes baseline-identical; six existing native wire tests; twelve paired public delimiter/size controls and canonical Rust output; EOF maximum+1 defect owned .65; transport 35/10/10/76 and admission complete/141; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.26 - complete MCP wire reading and own final EOF byte-limit repair` — Complete MCP server/wire coverage, qualify existing unit boundaries, and own the independently reproduced EOF limit repair.

- ID: `SESSION-STARTUP-READING.3.3.27`
  Status: `done`
  Goal: Read Rust group 27: 1,500 lines/fragments, 50,300 bytes.
  Scope: `rust/linkedspec-runtime/src/primary_cli.rs` lines 169–796;
    `rust/linkedspec-runtime/src/recognition_transaction.rs` lines 1–872.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read primary CLI 169–796 and recognition transaction 1–872; exact baseline identity; Knowledge-first CLI/recognition authority reconciliation; selected neutral recognition/CLI direct-dependent proof and bounded diagnostics when evidence requires; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: all 1,500 owned lines/50,300 bytes and 68 supporting helper lines baseline-identical; shared Rust CLI 66/66 default with empty stderr; neutral recognition 138/250/58, 9/9 and public/admission guards; .38 source comparison; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.27 - complete primary CLI and read recognition authority guards` — Complete primary CLI coverage, distinguish current neutral proof from historical native counts, and preserve Rust's early invalidation guard.

- ID: `SESSION-STARTUP-READING.3.3.28`
  Status: `done`
  Goal: Read Rust group 28: 1,496 lines/fragments, 56,822 bytes.
  Scope: `rust/linkedspec-runtime/src/recognition_transaction.rs` lines 873–1547;
    `rust/linkedspec-runtime/src/runtime.rs` lines 1–821.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read recognition_transaction 873–1547 and runtime 1–821; exact baseline identity; Knowledge-first recognition/gap/value representation and copy semantics reconciliation; selected neutral direct-dependent checks and bounded diagnostic controls where evidence requires; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines. No runtime/public/policy repairs before startup prerequisites.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: all 1,496 lines/56,822 bytes baseline-identical; recognition 138/250/58 at 9/9, gap 9/0/63/public34, typed source 14/0/231; exact 92 helper/seven alias catalogs; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.28 - complete recognition adapters and read RuntimeContext source connections` — Complete recognition runtime and record source-authority, gap rollback and exact helper/alias boundaries.

- ID: `SESSION-STARTUP-READING.3.3.29`
  Status: `done`
  Goal: Read Rust group 29: 1,497 lines/fragments, 49,031 bytes.
  Scope: `rust/linkedspec-runtime/src/runtime.rs` lines 822–2318.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read runtime.rs 822–2318 with exact baseline identity; Knowledge-first binding identity, scope restoration, mutation guard and typed projection reconciliation; selected write/map/typed neutral checks and bounded diagnostic controls where required; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: 1,497 lines/49,031 bytes baseline-identical; typed source 14/0/231, binding 11/7/6/8, write105, map167/592, diagnostic3/11/6/8/20; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.29 - read context observations projections and typed binding stores` — Record completion routing, typed projection and stable binding identity with exact remaining restoration scope.

- ID: `SESSION-STARTUP-READING.3.3.30`
  Status: `done`
  Goal: Read Rust group 30: 1,494 lines/fragments, 53,412 bytes.
  Scope: `rust/linkedspec-runtime/src/runtime.rs` lines 2319–2737;
    `rust/linkedspec-runtime/src/semantic_index.rs` lines 1–692;
    `rust/linkedspec-runtime/src/semantic_index/call_projection.rs` lines 1–383.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read runtime.rs 2319–2737, semantic_index.rs 1–692 and call_projection.rs 1–383 with exact baseline identity; Knowledge-first store restoration, semantic source/index and call projection reconciliation; selected binding/callable/semantic neutral checks and bounded source controls; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/diagnosis: 1,494 lines/53,412 bytes baseline-identical; six paired public queries with independent ID/excerpt assertions; semantic6/20/128 at9/0 and6/0, callable23, binding11/7/6/8; .22/.66 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.30 - complete context and semantic foundation reading and own binding identity repair` — Complete context/foundation reading and own the independently measured repeated-binding query repair.

- ID: `SESSION-STARTUP-READING.3.3.31`
  Status: `done`
  Goal: Read Rust group 31: 1,494 lines/fragments, 50,420 bytes.
  Scope: `rust/linkedspec-runtime/src/semantic_index/call_projection.rs` lines 384–1288;
    `rust/linkedspec-runtime/src/semantic_index/query.rs` lines 1–589.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read call_projection.rs 384–1288 and query.rs 1–589 with exact baseline identity; Knowledge-first semantic call/shape/source/query validation reconciliation and existing .22/.66 boundary checks; selected semantic neutral proof plus bounded native controls if required; Knowledge/history/memory/staged diff/all nine pre-commit doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/diagnosis: 1,494 lines/50,420 bytes baseline-identical; six paired public queries, six Perl Get controls and independent signature/source assertions; semantic6/20/128 at9/0 and6/0; .67 ownership; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.31 - complete semantic call reading and own signature and container projection repairs` — Complete call projection and distinguish matching query payloads from independently valid semantic evidence.

- ID: `SESSION-STARTUP-READING.3.3.32`
  Status: `done`
  Goal: Read Rust group 32: 1,495 lines/fragments, 50,145 bytes.
  Scope: `rust/linkedspec-runtime/src/semantic_index/query.rs` lines 590–1003;
    `rust/linkedspec-runtime/src/semantic_index/runtime_projection.rs` lines 1–273;
    `rust/linkedspec-runtime/src/semantic_index/static_projection.rs` lines 1–808.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read query.rs 590–1003, runtime_projection.rs 1–273 and static_projection.rs 1–808 with exact baseline identity; Knowledge-first query validation/budgets, observation topology, static/failure source correlation and existing repair reconciliation; selected semantic neutral proof and bounded diagnostic controls where required; Knowledge/history/memory/staged diff/all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/diagnosis: 1,495 lines/50,145 bytes baseline-identical; eight native constructor/query controls, four paired Get/CLI controls, independent assertions; semantic6/20/128, diagnostic3/11/6/8/20, recognition138/250/58; .68/.69 ownership; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.32 - complete semantic query reading and own token use and newline repairs` — Complete query/runtime projection and separate actual token-use/parser gaps from a ruled-out failure-mapping concern.

- ID: `SESSION-STARTUP-READING.3.3.33`
  Status: `done`
  Goal: Read Rust group 33: 1,482 lines/fragments, 50,376 bytes.
  Scope: `rust/linkedspec-runtime/src/semantic_index/static_projection.rs` lines 809–1720;
    `rust/linkedspec-runtime/src/semantic_observation.rs` lines 1–133;
    `rust/linkedspec-runtime/src/source_emitter.rs` lines 1–437.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read static_projection.rs 809–1720, semantic_observation.rs 1–133 and source_emitter.rs 1–437 with exact baseline identity; Knowledge-first static scanning/shapes, typed observation and generated family/header authority reconciliation; selected semantic and generated-source neutral proof, bounded native controls only for unresolved evidence; Knowledge/history/memory/staged diff/all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/diagnosis: 1,482 lines/50,376 bytes baseline-identical; five paired public queries, three paired Get/CLI controls and independent assertions; semantic6/20/128, cursor36/18/8/60, generated10families/strictRust105; .70 ownership; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.33 - complete static semantic reading and own grouped edge correlation repairs` — Complete static/event reading and distinguish correct grouped execution from incomplete semantic source/index records.

- ID: `SESSION-STARTUP-READING.3.3.34`
  Status: `done`
  Goal: Read Rust group 34: 1,493 lines/fragments, 53,383 bytes.
  Scope: `rust/linkedspec-runtime/src/source_emitter.rs` lines 438–1466;
    `rust/linkedspec-runtime/src/source_location.rs` lines 1–464.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read source_emitter.rs 438–1466 and source_location.rs 1–464 with exact baseline identity; Knowledge-first generated module roles, reconstruction/plan validation and typed source coordinate/error/projection authority; selected generated/cursor/typed-source neutral proof and bounded controls only for unresolved evidence; Knowledge/history/memory/staged diff/all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading/diagnosis: 1,493 lines/53,383 bytes baseline-identical; eight identity emissions/seven module compiles and two executable modules/ten results, independent assertions; generated10/strictRust105, cursor36/18/8/60, typed14/0/231; .71/.72 owned; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.34 - complete emitter reading and own literal and recognition adapter repairs` — Complete emitter reading and preserve independently measured generated identity/projection gaps.

- ID: `SESSION-STARTUP-READING.3.3.35`
  Status: `done`
  Goal: Read Rust group 35: 1,497 lines/fragments, 51,223 bytes.
  Scope: `rust/linkedspec-runtime/src/source_location.rs` lines 465–561;
    `rust/linkedspec-runtime/src/spec_loader.rs` lines 1–564;
    `rust/linkedspec-runtime/src/spec_parser.rs` lines 1–836.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read source_location.rs 465–561, spec_loader.rs 1–564 and spec_parser.rs 1–836 with exact baseline identity; Knowledge-first materialization, load/search/validation and staged spec-parser rules; selected typed-source, diagnostic and staged neutral checks; bounded tool controls for unresolved evidence; Knowledge/history/memory/staged diff/all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading: 1,497 lines/51,223 bytes baseline-identical; ADR0026 and one new/four existing Knowledge owners reconciled; native resolution14/9/4, typed14/0/231, diagnostic3/11/6/8/20, staged9legs/123+129mutations; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.35 - complete source authority and loader reading and reconcile function projection` — Complete source authority/loader and retain exact staged function projection and scalar-source boundaries.

- ID: `SESSION-STARTUP-READING.3.3.36`
  Status: `done`
  Goal: Read Rust group 36: 1,453 lines/fragments, 51,063 bytes.
  Scope: `rust/linkedspec-runtime/src/spec_parser.rs` lines 837–1022;
    `rust/linkedspec-runtime/src/staged_ast_enrichment.rs` lines 1–1267.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read spec_parser.rs 837–1022 and staged_ast_enrichment.rs 1–1267 with exact baseline identity; Knowledge-first signature/span/error helpers and staged provenance/registry/cache/dispatch validation; selected staged and typed-source neutral proof, bounded tools for unresolved mechanisms; Knowledge/history/memory/staged diff/all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading: 1,453 lines/51,063 bytes baseline-identical; five Knowledge owners and .55.1 source inventory reconciled; staged9legs/123+129mutations, typed14/0/231 and scalar55/18; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.36 - complete spec parser reading and trace staged registry and invocation authority` — Complete spec parser and preserve frozen registry, fresh seed and queue coordinator boundaries.

- ID: `SESSION-STARTUP-READING.3.3.37`
  Status: `done`
  Goal: Read Rust group 37: 1,499 lines/fragments, 53,102 bytes.
  Scope: `rust/linkedspec-runtime/src/staged_ast_enrichment.rs` lines 1268–2766.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Read staged_ast_enrichment.rs 1268–2766 with exact baseline identity; Knowledge-first recursive execution, safe points, source rebasing, marker/plan validation and result settlement; selected staged/typed-source neutral proof and bounded tools for unresolved evidence; Knowledge/history/memory/staged diff/all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading: 1,499 lines/53,102 baseline-identical bytes; 28 paired target, 12 returned-marker and six budget records independently asserted; .73/.74/.75 own measured gaps; staged123+129 and typed14/0/231; Knowledge/history/memory/staged diff/all nine doctrines.
  Commit: `SESSION-STARTUP-READING.3.3.37 - trace staged execution and own target validation and counter repairs` — Preserve exact staged execution evidence and own destination, marker/provenance and call-counter repairs.

- ID: `SESSION-STARTUP-READING.3.3.38`
  Status: `done`
  Goal: Read Rust group 38: 1,500 lines/fragments, 50,788 bytes.
  Scope: `rust/linkedspec-runtime/src/staged_ast_enrichment.rs` lines 2767–3058;
    `rust/linkedspec-runtime/src/staged_parse_job.rs` lines 1–290;
    `rust/linkedspec-runtime/src/staged_parser_registry.rs` lines 1–712;
    `rust/linkedspec-runtime/src/unicode_case_mapping.rs` lines 1–206.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
    Own mandatory change-history rollover and its exact finite capacity admission under README_POLICY; verify source/blob/hash/prior-manifest preservation and indexed ADR 0106 before the exact staged canonical gate.
  Verification tier: `canonical`
  Focused checks: Read all four owned staged-enrichment/job/registry and Unicode-prefix ranges with exact baseline identity; Knowledge-first source reconciliation; staged, typed-source and Unicode generation/fixture checks; Knowledge/history/memory/staged diff/all nine doctrines; independent archive preservation and exact routing proof.
  Canonical trigger: `infrastructure` — mandatory change-history rollover requires exact ADR 0106 file/manifest capacity admission;
    receipt-bound canonical verification is required before landing, with runtime/public-book reading gates unchanged.
  Verification: PASS focused reading: 1,500 lines/50,788 baseline-identical bytes across four ranges; six existing Knowledge cards/.55.1 source inventory reconciled; Unicode1563/1581/158/464/12, staged123+129, typed14/0/231; Archive source/blob/hash/prior-manifest proof passes; final exact staged canonical receipt is required before landing.
  Commit: `SESSION-STARTUP-READING.3.3.38 - complete staged source reading and preserve bounded change history` — Complete staged source comprehension and separate declaration authority, returned records and legacy adapter metadata.

- ID: `SESSION-STARTUP-READING.3.3.39`
  Status: `done`
  Goal: Read Rust group 39: 1,500 lines/fragments, 38,103 bytes.
  Scope: `rust/linkedspec-runtime/src/unicode_case_mapping.rs` lines 207–1706.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact scoped Unicode reading/baseline identity; existing Knowledge reconciliation; completed .3.3.38 canonical receipt/log and two consumed sample identities; Unicode regeneration/neutral fixtures; memory, both history-pressure checks, staged diff and all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS reading: all 1,500 lines/38,103 baseline-identical bytes; lower map complete, upper prefix reconciled; Unicode1563/1581/158/464/12; prior exact canonical receipt/log and both sample identities consumed; five Knowledge cards, memory/history/diff and required nine-doctrine commit checks.
  Commit: `SESSION-STARTUP-READING.3.3.39 - finish Unicode lower-map reading and preserve canonical evidence` — Preserve completed Unicode lower-map comprehension and exact prior canonical/sample evidence.

- ID: `SESSION-STARTUP-READING.3.3.40`
  Status: `done`
  Goal: Read Rust group 40: 1,450 lines/fragments, 37,746 bytes.
  Scope: `rust/linkedspec-runtime/src/unicode_case_mapping.rs` lines 1707–3156.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: All owned Unicode upper-table bytes read without truncation and full-file/range baseline identity; reconcile pinned generation authority and retained .3.3.39 proof; memory, both history-pressure checks, Knowledge synchronization, staged diff and all nine doctrines.
  Canonical trigger: `none` — bounded reading/Knowledge/continuity only; no runtime, public-book,
    policy, contract, or infrastructure change.
  Verification: PASS: all 1,450 lines / 37,746 bytes read untruncated and baseline-identical; complete upper-map comprehension reconciled; unchanged generation inputs preserve .3.3.39 Unicode proof; Knowledge, memory, both histories, diff and required nine-doctrine commit checks.
  Commit: `SESSION-STARTUP-READING.3.3.40 - complete Unicode upper-map reading` — Complete upper-map physical reading with exact range identity and retained generation proof.

- ID: `SESSION-STARTUP-READING.3.3.41`
  Status: `done`
  Goal: Read Rust group 41: 1,494 lines/fragments, 43,943 bytes.
  Scope: `rust/linkedspec-runtime/src/unicode_case_mapping.rs` lines 3157–3859;
    `rust/linkedspec-runtime/tests/callable_codeblock_literal_contract.rs` lines 1–791.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `canonical`
  Focused checks: Exact Unicode suffix and callable contract prefix reading/baseline identity; Knowledge-first reconciliation; Unicode and callable neutral checks; memory, both history-pressure checks, Knowledge synchronization and staged diff; exact staged canonical local CI before final batch commit/push.
  Canonical trigger: `batch/push` — item 100 closes the accepted default batch; exact staged canonical CI
    must pass before the final leaf commit and clean push.
  Verification: PASS focused: all 1,494 lines / 43,943 baseline-identical bytes; complete Unicode module and bounded callable assertion scope; Unicode 1563/1581/158/464/12 and callable 7/11/9/7/4/8/23; four Knowledge cards; exact 99-commit batch census. Final exact staged canonical receipt is required before landing; its completed result is recorded in the commit body.
  Commit: `SESSION-STARTUP-READING.3.3.41 - complete Unicode reading and checkpoint callable contracts at the batch boundary` — Close the accepted 100-item batch after exact canonical proof; resume required reading at .3.3.42.

- ID: `SESSION-STARTUP-READING.3.3.42`
  Status: `done`
  Goal: Read Rust group 42: 1,500 lines/fragments, 45,529 bytes.
  Scope: `rust/linkedspec-runtime/tests/callable_codeblock_literal_contract.rs` lines 792–958;
    `rust/linkedspec-runtime/tests/complete_named_mark_contract.rs` lines 1–90;
    `rust/linkedspec-runtime/tests/corpus/README.md` lines 1–116;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_bare_arg/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_bare_arg/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_bare_arg/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_declare/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_declare/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_declare/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_no_declare/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_no_declare/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_array_no_declare/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_bare_arg/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_bare_arg/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_bare_arg/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_declare/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_declare/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_declare/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_no_declare/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_no_declare/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_scalar_no_declare/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/autoexist_undef_literal/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/autoexist_undef_literal/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/autoexist_undef_literal/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/capability_capture_anonymous_surface/expected.json` lines 1–19;
    `rust/linkedspec-runtime/tests/corpus/capability_capture_anonymous_surface/input.spec` lines 1–51;
    `rust/linkedspec-runtime/tests/corpus/capability_capture_anonymous_surface/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/capability_capture_named_surface/expected.json` lines 1–23;
    `rust/linkedspec-runtime/tests/corpus/capability_capture_named_surface/input.spec` lines 1–61;
    `rust/linkedspec-runtime/tests/corpus/capability_capture_named_surface/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/capability_control_marker_surface/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/capability_control_marker_surface/input.spec` lines 1–26;
    `rust/linkedspec-runtime/tests/corpus/capability_control_marker_surface/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/capability_cursor_control_surface/expected.json` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/capability_cursor_control_surface/input.spec` lines 1–24;
    `rust/linkedspec-runtime/tests/corpus/capability_cursor_control_surface/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/capability_position_helper_surface/expected.json` lines 1–37;
    `rust/linkedspec-runtime/tests/corpus/capability_position_helper_surface/input.spec` lines 1–41;
    `rust/linkedspec-runtime/tests/corpus/capability_position_helper_surface/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/capability_pure_helper_surface/expected.json` lines 1–47;
    `rust/linkedspec-runtime/tests/corpus/capability_pure_helper_surface/input.spec` lines 1–38;
    `rust/linkedspec-runtime/tests/corpus/capability_pure_helper_surface/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/ds_vhistory_version_entry/expected.json` lines 1–24;
    `rust/linkedspec-runtime/tests/corpus/ds_vhistory_version_entry/input.spec` lines 1–95;
    `rust/linkedspec-runtime/tests/corpus/ds_vhistory_version_entry/input.txt` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/ebnf_expression_rules/expected.json` lines 1–42;
    `rust/linkedspec-runtime/tests/corpus/ebnf_expression_rules/input.spec` lines 1–214;
    `rust/linkedspec-runtime/tests/corpus/ebnf_expression_rules/input.txt` lines 1–2;
    `rust/linkedspec-runtime/tests/corpus/ebnf_logging_annotation/expected.json` lines 1–22;
    `rust/linkedspec-runtime/tests/corpus/ebnf_logging_annotation/input.spec` lines 1–214;
    `rust/linkedspec-runtime/tests/corpus/ebnf_logging_annotation/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/hlink_bracket_body/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/hlink_bracket_body/input.spec` lines 1–29;
    `rust/linkedspec-runtime/tests/corpus/hlink_bracket_body/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/hlink_curly_brace/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/hlink_curly_brace/input.spec` lines 1–28.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact scoped reading and baseline byte identity; callable and named-mark neutral checks;
    Knowledge reconciliation; task pressure census; memory, doctrines, Knowledge, both histories and staged diff.
  Canonical trigger: `none` — reading and continuity only; no runtime, public contract or infrastructure change.
  Verification: PASS: all 56 scopes / 1,500 lines / 45,529 bytes read untruncated and baseline-identical;
    callable 7/11/9/7/4/8/23 and named-mark 7 helpers/3 mutations pass; focused continuity proof precedes landing.
  Commit: `SESSION-STARTUP-READING.3.3.42 - complete callable and named-mark reading with corpus prefix` — Complete callable/named-mark reading and owned corpus prefix.

- ID: `SESSION-STARTUP-READING.3.3.43`
  Status: `done`
  Goal: Read Rust group 43: 1,106 lines/fragments, 59,355 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/hlink_curly_brace/input.spec` lines 29–29;
    `rust/linkedspec-runtime/tests/corpus/hlink_curly_brace/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/hlink_mixed_bracket_brace/expected.json` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/hlink_mixed_bracket_brace/input.spec` lines 1–29;
    `rust/linkedspec-runtime/tests/corpus/hlink_mixed_bracket_brace/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/hlink_raw_escaped_brackets/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/hlink_raw_escaped_brackets/input.spec` lines 1–29;
    `rust/linkedspec-runtime/tests/corpus/hlink_raw_escaped_brackets/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/hlink_raw_string/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/hlink_raw_string/input.spec` lines 1–29;
    `rust/linkedspec-runtime/tests/corpus/hlink_raw_string/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/lib_reader_cattribute/expected.json` lines 1–17;
    `rust/linkedspec-runtime/tests/corpus/lib_reader_cattribute/input.spec` lines 1–15;
    `rust/linkedspec-runtime/tests/corpus/lib_reader_cattribute/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/lib_reader_sattribute/expected.json` lines 1–14;
    `rust/linkedspec-runtime/tests/corpus/lib_reader_sattribute/input.spec` lines 1–15;
    `rust/linkedspec-runtime/tests/corpus/lib_reader_sattribute/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/lispish_x_y/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/lispish_x_y/input.spec` lines 1–86;
    `rust/linkedspec-runtime/tests/corpus/lispish_x_y/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/manifest.json` lines 1–112;
    `rust/linkedspec-runtime/tests/corpus/portmap_bare/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/portmap_bare/input.spec` lines 1–33;
    `rust/linkedspec-runtime/tests/corpus/portmap_bare/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/portmap_bit/expected.json` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/portmap_bit/input.spec` lines 1–33;
    `rust/linkedspec-runtime/tests/corpus/portmap_bit/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/portmap_concatenation/expected.json` lines 1–18;
    `rust/linkedspec-runtime/tests/corpus/portmap_concatenation/input.spec` lines 1–33;
    `rust/linkedspec-runtime/tests/corpus/portmap_concatenation/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/portmap_constant/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/portmap_constant/input.spec` lines 1–33;
    `rust/linkedspec-runtime/tests/corpus/portmap_constant/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/portmap_slice/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/portmap_slice/input.spec` lines 1–33;
    `rust/linkedspec-runtime/tests/corpus/portmap_slice/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/pplugin_empty/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/pplugin_empty/input.spec` lines 1–33;
    `rust/linkedspec-runtime/tests/corpus/pplugin_empty/input.txt` empty file (0 bytes);
    `rust/linkedspec-runtime/tests/corpus/proof_edge_array_literal/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/proof_edge_array_literal/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/proof_edge_array_literal/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/proof_edge_scalar_literal/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/proof_edge_scalar_literal/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/proof_edge_scalar_literal/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/regdef_nested_register_fields/expected.json` lines 1–21;
    `rust/linkedspec-runtime/tests/corpus/regdef_nested_register_fields/input.spec` lines 1–23;
    `rust/linkedspec-runtime/tests/corpus/regdef_nested_register_fields/input.txt` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/simenv_multiline_value/expected.json` lines 1–17;
    `rust/linkedspec-runtime/tests/corpus/simenv_multiline_value/input.spec` lines 1–225;
    `rust/linkedspec-runtime/tests/corpus/simenv_multiline_value/input.txt` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_action_edge/expected.json` lines 1–31;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_action_edge/input.spec` lines 1–145.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline and corpus-manifest/JSON checks; preserve the completed Toolbox
    SimEnv dispatch probe and repair ownership; Knowledge, memory, all doctrines, both histories and diff.
  Canonical trigger: `none` — bounded reading and proposed/repair intake; no production or public contract change.
  Verification: All 53 scopes (52 nonempty), 1,106 lines / 59,355 bytes read and baseline-identical;
    18 JSON files decode, manifest has 105 unique cases. Twelve paired Perl probes and exact lowered callee
    confirm .76; PARSER-AUTHORING-APIS preserves three proposed DBINP investigations. Focused continuity governs landing.
  Commit: `SESSION-STARTUP-READING.3.3.43 - reconcile corpus reading and own SimEnv dispatch repair`

- ID: `SESSION-STARTUP-READING.3.3.44`
  Status: `done`
  Goal: Read Rust group 44: 225 lines/fragments, 65,141 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/spec_spec_action_edge/input.spec` lines 146–226;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_action_edge/input.txt` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_comment_skip/expected.json` lines 1–14;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_comment_skip/input.spec` lines 1–125.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline audit; four grammar-mirror identities and Unicode rule-label contract; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; grammar and runtime unchanged.
  Verification: All four scopes reconcile with the baseline: 225 lines / 65,141 bytes; ordered audit SHA-256 `e2f195398076abb7f885a1dc307122b7f391aee92d7d04d19c488c6e37353444`. The action-edge grammar is read through EOF; comment-skip grammar is read through paragraph dispatch. Fluent/bare/blind edges retain distinct node fields, complete-line lifecycle precedes bare edges, standalone blocks normalize to I, and variadic functions emit a versioned signature. JSON decodes; all four 83,452-byte / 226-line mirrors equal canonical SHA-256 `03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004`; Unicode 17.0.0 / 806 ranges / 9 positive / 8 negative / 2 distinct pairs pass. Stored oracle inspection is not a fresh parser execution.
  Commit: `SESSION-STARTUP-READING.3.3.44 - reconcile self-hosted grammar reading and mirror freshness`

- ID: `SESSION-STARTUP-READING.3.3.45`
  Status: `done`
  Goal: Read Rust group 45: 44 lines/fragments, 60,931 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/spec_spec_comment_skip/input.spec` lines 126–169.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline audit and current mirror identity against the .44 Unicode freshness proof; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; grammar and runtime unchanged.
  Verification: All 44 lines / 60,931 bytes match the baseline; range SHA-256 `70dc693993fb724cfca8d8a3394b285210fdb20740f23b605e80da414dcb68d6`. Header labels preserve frozen Unicode membership plus physical-line/colon boundaries; mode and top are separate fields. Named slots preserve slot_name, anonymous anchors preserve pattern, and action/blind/bare block or fluent forms retain their distinct target/code/raw fields. Complete mirror identity remains `03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004`, so .44 freshness/Unicode proof applies unchanged. Existing self-hosted-rule-label-physical-boundaries Knowledge owns causal interpretation; no new runtime result is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.45 - reconcile self-hosted labels and edge grammar reading`

- ID: `SESSION-STARTUP-READING.3.3.46`
  Status: `done`
  Goal: Read Rust group 46: 231 lines/fragments, 59,566 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/spec_spec_comment_skip/input.spec` lines 170–226;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_comment_skip/input.txt` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_minimal_rule/expected.json` lines 1–14;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_minimal_rule/input.spec` lines 1–157.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Four exact owned-range/baseline identities, fixture JSON and unchanged canonical mirrors; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; grammar and runtime unchanged.
  Verification: All four owned scopes match the baseline: 231 lines / 59,566 bytes; ordered audit SHA-256 `f6593863e1e3914a4a4a52b06bd4c99f8e0d7b24d8ddfe7d5a4d57310894c67f`. Comment-skip grammar is complete through EOF; minimal-rule grammar is read through blind-block dispatch. Comment input and decoded minimal-rule oracle preserve Top plus anonymous x-regex nodes; the leading comment is skipped by spec_file dispatch. The suffix preserves bare/lifecycle precedence, standalone-I normalization, variadic signatures and marker/directive nodes. Both complete grammar mirrors retain .44 canonical identity and its Unicode proof. Stored oracle inspection is not a fresh parser execution.
  Commit: `SESSION-STARTUP-READING.3.3.46 - reconcile comment-skip and minimal-rule grammar reading`

- ID: `SESSION-STARTUP-READING.3.3.47`
  Status: `done`
  Goal: Read Rust group 47: 249 lines/fragments, 53,907 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/spec_spec_minimal_rule/input.spec` lines 158–226;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_minimal_rule/input.txt` lines 1–2;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_user_function_definition/expected.json` lines 1–37;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_user_function_definition/input.spec` lines 1–141.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Four exact owned-range/baseline identities, fixture JSON and unchanged canonical mirrors; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; grammar and runtime unchanged.
  Verification: All four owned scopes match the baseline: 249 lines / 53,907 bytes; ordered audit SHA-256 `63aa28ce7e9c2e3f4130788a8fb8aeda2d568483fe7efd6059dab3d905d75d21`. Minimal-rule grammar is complete through EOF; user-function grammar is read through anonymous regex-anchor dispatch. The decoded function oracle preserves norm(value) body text before Top in the first paragraph, the action code calling norm, and a separate Done paragraph. This describes syntax capture, not executed function semantics. The suffix preserves bare/lifecycle/fixed/variadic/split/gap/comment forms. Both complete grammar mirrors retain .44 canonical identity and Unicode proof; existing self-hosted grammar Knowledge owns interpretation.
  Commit: `SESSION-STARTUP-READING.3.3.47 - reconcile minimal-rule and user-function grammar reading`

- ID: `SESSION-STARTUP-READING.3.3.48`
  Status: `done`
  Goal: Read Rust group 48: 32 lines/fragments, 60,575 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/spec_spec_user_function_definition/input.spec` lines 142–173.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline and complete mirror identities against unchanged .44 Unicode proof; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; grammar and runtime unchanged.
  Verification: All 32 owned lines / 60,575 bytes match the baseline; range SHA-256 `f2f565823d9c0222fd4e21eab5c58e23b22c418012c79d37de68d6f50d5666ec`. Action block/fluent/bare, blind block/fluent/bare, grouped bare-block and bare-fluent tokens retain explicit target/index/source_form or raw fields and balanced recursive blocks. The complete mirror retains canonical SHA-256 `03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004` and .44 Unicode proof. The grammar suffix remains .49-owned; no fresh corpus execution is claimed. Existing self-hosted grammar and physical-boundary Knowledge apply unchanged.
  Commit: `SESSION-STARTUP-READING.3.3.48 - reconcile user-function edge grammar reading`

- ID: `SESSION-STARTUP-READING.3.3.49`
  Status: `done`
  Goal: Read Rust group 49: 1,500 lines/fragments, 46,200 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/spec_spec_user_function_definition/input.spec` lines 174–226;
    `rust/linkedspec-runtime/tests/corpus/spec_spec_user_function_definition/input.txt` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/tablegrep_simple_term/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/tablegrep_simple_term/input.spec` lines 1–86;
    `rust/linkedspec-runtime/tests/corpus/tablegrep_simple_term/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/tclite_command_subst/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/tclite_command_subst/input.spec` lines 1–35;
    `rust/linkedspec-runtime/tests/corpus/tclite_command_subst/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/tclite_double_quote/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/tclite_double_quote/input.spec` lines 1–35;
    `rust/linkedspec-runtime/tests/corpus/tclite_double_quote/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_11_3_assignment_replacement_and_explicit_targets/expected.json` lines 1–18;
    `rust/linkedspec-runtime/tests/corpus/terse_11_3_assignment_replacement_and_explicit_targets/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_11_3_assignment_replacement_and_explicit_targets/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_11_3_shape_assignment_value_binding/expected.json` lines 1–24;
    `rust/linkedspec-runtime/tests/corpus/terse_11_3_shape_assignment_value_binding/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_11_3_shape_assignment_value_binding/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_11_4_nested_mixed_value_path_assignment/expected.json` lines 1–38;
    `rust/linkedspec-runtime/tests/corpus/terse_11_4_nested_mixed_value_path_assignment/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_11_4_nested_mixed_value_path_assignment/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_12_3_hash_tree_traversal_receiver_blocks/expected.json` lines 1–17;
    `rust/linkedspec-runtime/tests/corpus/terse_12_3_hash_tree_traversal_receiver_blocks/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_12_3_hash_tree_traversal_receiver_blocks/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_13_3_array_tree_traversal_receiver_blocks/expected.json` lines 1–19;
    `rust/linkedspec-runtime/tests/corpus/terse_13_3_array_tree_traversal_receiver_blocks/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_13_3_array_tree_traversal_receiver_blocks/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_14_4_receiver_with_trailing_block/expected.json` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/terse_14_4_receiver_with_trailing_block/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_14_4_receiver_with_trailing_block/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_15_2_3_bare_value_reads_and_case_labels/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_15_2_3_bare_value_reads_and_case_labels/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_15_2_3_bare_value_reads_and_case_labels/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_15_4_bare_scalar_payload_readback/expected.json` lines 1–12;
    `rust/linkedspec-runtime/tests/corpus/terse_15_4_bare_scalar_payload_readback/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_15_4_bare_scalar_payload_readback/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_array_copy_bare_read/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_array_copy_bare_read/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_array_copy_bare_read/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_copy_bare_array_first/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_copy_bare_array_first/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_copy_bare_array_first/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_copy_bare_hash/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_copy_bare_hash/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_copy_bare_hash/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_hash_copy_bare_read/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_hash_copy_bare_read/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_2_hash_copy_bare_read/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_assignment_source_bare_reads/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_assignment_source_bare_reads/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_assignment_source_bare_reads/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_mutation_direct_bare_reads/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_mutation_direct_bare_reads/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_mutation_direct_bare_reads/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_return_bare_scalar/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_return_bare_scalar/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_4_return_bare_scalar/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_5_3_shape_literal_mutation_rhs/expected.json` lines 1–12;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_5_3_shape_literal_mutation_rhs/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_5_3_shape_literal_mutation_rhs/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_5_3_shape_literal_return_values/expected.json` lines 1–14;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_5_3_shape_literal_return_values/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_2_3_5_3_shape_literal_return_values/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_2_push_alias_array/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_2_push_alias_array/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_2_push_alias_array/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_3_set_key_statement_hash/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_3_set_key_statement_hash/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_3_set_key_statement_hash/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_1_scalar_assignment_operator/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_1_scalar_assignment_operator/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_1_scalar_assignment_operator/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_2_array_append_operator/expected.json` lines 1–4;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_2_array_append_operator/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_2_array_append_operator/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_3_hash_index_assignment_operator/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_3_hash_index_assignment_operator/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_3_4_3_hash_index_assignment_operator/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_4_2_copy_hash_symbol_empty/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_4_2_copy_hash_symbol_empty/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_4_2_copy_hash_symbol_empty/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_4_2_set_cat_copy_array/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_4_2_set_cat_copy_array/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_4_2_set_cat_copy_array/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_2_boolean_mutation_flow/expected.json` lines 1–10;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_2_boolean_mutation_flow/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_2_boolean_mutation_flow/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_2_primitive_literals/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_2_primitive_literals/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_2_primitive_literals/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_3_call_spacing/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_3_call_spacing/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_3_call_spacing/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_4_newline_statements/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_4_newline_statements/input.spec` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_4_newline_statements/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_5_1_direct_nested_access/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_5_1_direct_nested_access/input.spec` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/terse_1_5_5_1_direct_nested_access/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_1_6_array_end_mutation_methods/expected.json` lines 1–3;
    `rust/linkedspec-runtime/tests/corpus/terse_1_6_array_end_mutation_methods/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_1_6_array_end_mutation_methods/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_1_3_expression_valued_blocks/expected.json` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/terse_2_1_3_expression_valued_blocks/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_1_3_expression_valued_blocks/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_1_4_expression_valued_block_early_return/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_2_1_4_expression_valued_block_early_return/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_1_4_expression_valued_block_early_return/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_3_attached_if_blocks/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_3_attached_if_blocks/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_3_attached_if_blocks/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_4_when_otherwise_aliases/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_4_when_otherwise_aliases/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_4_when_otherwise_aliases/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_5_2_attached_switch_blocks/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_5_2_attached_switch_blocks/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_5_2_attached_switch_blocks/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_6_2_attached_while_blocks/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_6_2_attached_while_blocks/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_2_6_2_attached_while_blocks/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_1_bare_array_helper_arg_composition/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_1_bare_array_helper_arg_composition/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_1_bare_array_helper_arg_composition/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_1_bare_hash_helper_arg_composition/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_1_bare_hash_helper_arg_composition/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_1_bare_hash_helper_arg_composition/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_2_inline_if_value_control/expected.json` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_2_inline_if_value_control/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_2_inline_if_value_control/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_2_inline_switch_value_control/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_2_inline_switch_value_control/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_2_inline_switch_value_control/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_deep_pure_helper_composition/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_deep_pure_helper_composition/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_4_deep_pure_helper_composition/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_1_array_receiver_value_chains/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_1_array_receiver_value_chains/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_1_array_receiver_value_chains/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_2_hash_receiver_value_chains/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_2_hash_receiver_value_chains/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_2_hash_receiver_value_chains/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_3_string_receiver_value_chains/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_3_string_receiver_value_chains/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_3_string_receiver_value_chains/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_4_number_receiver_value_chains/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_4_number_receiver_value_chains/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_4_number_receiver_value_chains/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_5_block_valued_receiver_chains/expected.json` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_5_block_valued_receiver_chains/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_5_block_valued_receiver_chains/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_6_typed_wrapper_quoted_names/expected.json` lines 1–15;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_6_typed_wrapper_quoted_names/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_2_3_5_6_typed_wrapper_quoted_names/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_1_numeric_word_aliases/expected.json` lines 1–18;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_1_numeric_word_aliases/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_1_numeric_word_aliases/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_2_arithmetic_symbol_callees/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_2_arithmetic_symbol_callees/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_2_arithmetic_symbol_callees/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_2_string_comparison_helpers/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_2_string_comparison_helpers/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_2_string_comparison_helpers/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_3_numeric_comparison_word_aliases/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_3_numeric_comparison_word_aliases/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_3_numeric_comparison_word_aliases/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_4_numeric_comparison_symbol_callees/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_4_numeric_comparison_symbol_callees/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_2_3_4_numeric_comparison_symbol_callees/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_1_scalar_assignment_expressions/expected.json` lines 1–10;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_1_scalar_assignment_expressions/input.spec` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_1_scalar_assignment_expressions/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_2_aggregate_assignment_expressions/expected.json` lines 1–21;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_2_aggregate_assignment_expressions/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_2_aggregate_assignment_expressions/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_3_mutation_assignment_expressions/expected.json` lines 1–16;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_3_mutation_assignment_expressions/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_3_mutation_assignment_expressions/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_4_assignment_expression_closure/expected.json` lines 1–46;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_4_assignment_expression_closure/input.spec` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_3_3_4_assignment_expression_closure/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_4_3_2_user_function_runtime/expected.json` lines 1–6;
    `rust/linkedspec-runtime/tests/corpus/terse_4_3_2_user_function_runtime/input.spec` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/terse_4_3_2_user_function_runtime/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/terse_7_3_array_numeric_reducer_receiver_methods/expected.json` lines 1–14;
    `rust/linkedspec-runtime/tests/corpus/terse_7_3_array_numeric_reducer_receiver_methods/input.spec` lines 1–5;
    `rust/linkedspec-runtime/tests/corpus/terse_7_3_array_numeric_reducer_receiver_methods/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/tkgui_empty/expected.json` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/tkgui_empty/input.spec` lines 1–22;
    `rust/linkedspec-runtime/tests/corpus/tkgui_empty/input.txt` empty file (0 bytes);
    `rust/linkedspec-runtime/tests/corpus/top_rule_body_recursion_sexpr/expected.json` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/top_rule_body_recursion_sexpr/input.spec` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/top_rule_body_recursion_sexpr/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/top_rule_lx_recursion_nested/expected.json` lines 1–9;
    `rust/linkedspec-runtime/tests/corpus/top_rule_lx_recursion_nested/input.spec` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/top_rule_lx_recursion_nested/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/top_rule_lx_recursion_sequence/expected.json` lines 1–8;
    `rust/linkedspec-runtime/tests/corpus/top_rule_lx_recursion_sequence/input.spec` lines 1–7;
    `rust/linkedspec-runtime/tests/corpus/top_rule_lx_recursion_sequence/input.txt` lines 1–1;
    `rust/linkedspec-runtime/tests/corpus/vhdl_library_use/expected.json` lines 1–12;
    `rust/linkedspec-runtime/tests/corpus/vhdl_library_use/input.spec` lines 1–335.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline audit, JSON decoding, manifest membership and unchanged grammar mirror; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; fixture and runtime behavior unchanged.
  Verification: All 202 scopes reconcile: 201 nonempty plus explicit empty TkGui input, 1,500 lines / 46,200 baseline-identical bytes. Ordered path/kind/range/byte/SHA audit is `8bc8ce563d4ccfe4a620b0ae6f4d0de28f28351d01678fe0b869491eec800baf`; 67 JSON files decode and all 68 case directories belong to the 105-case manifest. The final user-function grammar suffix completes all four mirror checkpoints with unchanged .44 identity. Reading covers tablegrep TERM fields, tagged Tclite quote/command structures, 59 Terse fixtures for literals/read/copy/assignment/receiver/control/helper/function behavior, empty TkGui, direct versus LX-root recursion and VHDL library/use tags plus grammar through line 335. Legacy-smoke Knowledge retains its historical richer-case limits; stored fixture evidence is not fresh runtime parity.
  Commit: `SESSION-STARTUP-READING.3.3.49 - reconcile Terse and legacy corpus reading`

- ID: `SESSION-STARTUP-READING.3.3.50`
  Status: `done`
  Goal: Read Rust group 50: 1,494 lines/fragments, 55,681 bytes.
  Scope: `rust/linkedspec-runtime/tests/corpus/vhdl_library_use/input.spec` lines 336–384;
    `rust/linkedspec-runtime/tests/corpus/vhdl_library_use/input.txt` lines 1–2;
    `rust/linkedspec-runtime/tests/corpus_oracle.rs` lines 1–234;
    `rust/linkedspec-runtime/tests/diagnostic_output_contract.rs` lines 1–483;
    `rust/linkedspec-runtime/tests/duplicate_regex_slot_identity_contract.rs` lines 1–473;
    `rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs` lines 1–253.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Six exact owned-range/baseline identities and canonical Knowledge/test-boundary reconciliation; memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; test and runtime behavior unchanged.
  Verification: All six owned scopes match the baseline: 1,494 lines / 55,681 bytes; ordered path/kind/range/byte/SHA audit `ee7b4b1b146504e7eb0f4e2e7c416091c2ea2058ac30fcc53863baf749c319fc`. VHDL grammar is complete through EOF. The corpus runner checks manifest format/count/unique valid names and exact directory sets, then compares compatibility output with the wrapped reference. Diagnostic consumers assert quiet/default, direct/compatibility/generated-v2 events, early arity rejection, concrete sink identity and typed exit. Duplicate-slot consumer covers its 15 declared roles across required versus choice, reconstructed/source/trace/CLI and invalid identity paths. Classifier prefix prepares 105 strict-UTF-8 cases with direct/compatibility oracles and minimal plans for one child Cargo workspace; suffix and process result handling remain .51-owned. Existing Knowledge is reconciled; no native execution or emitted compilation is newly claimed.
  Commit: `SESSION-STARTUP-READING.3.3.50 - reconcile corpus and diagnostic test-consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.51`
  Status: `done`
  Goal: Read Rust group 51: 1,487 lines/fragments, 51,804 bytes.
  Scope: `rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs` lines 254–358;
    `rust/linkedspec-runtime/tests/integration_test.rs` lines 1–1382.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact scope/source identities, retained classifier counterexample and causal evidence, Knowledge reconciliation, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — reading and repair intake; verifier implementation remains unchanged.
  Verification: Both scopes match the baseline: 1,487 lines / 51,804 bytes. Classifier source SHA-256 `25f37479a76a3022758cc09aeb4b162d3086d7d069be267ef7cd1f565eaa9dc7` and extracted tail without the test attribute `f1848092d5c6d0b3f6ec9d52627f8f13d39aa189d9da31f28afcefe8afce1261` match retained evidence. Six freshly replayed controls confirm failed child plus all 105 markers incorrectly passes; the in-memory status guard rejects it, while success/all and missing-marker controls behave as recorded. Scratch is removed; .77 owns repair and its Knowledge card preserves the executable probe. Integration prefix covers structural pipeline limits, staged function/parse-job identity, invalid definitions, edge metadata, retv/entry-match and body recursion through line 1382. Existing return-channel Knowledge is qualified against selective rule-variable scope. No real Cargo failure, parser defect or new integration run is inferred.
  Commit: `SESSION-STARTUP-READING.3.3.51 - reconcile classifier reading and own failed-child verification repair`

- ID: `SESSION-STARTUP-READING.3.3.52`
  Status: `done`
  Goal: Read Rust group 52: 1,408 lines/fragments, 65,108 bytes.
  Scope: `rust/linkedspec-runtime/tests/integration_test.rs` lines 1383–2790.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline identity and retained test-boundary comprehension; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; integration tests and runtime unchanged.
  Verification: All 1,408 owned lines / 65,108 bytes match the baseline; SHA-256 `2186798cafd76926b8e4f8a0f8a5d9fecdc80c641b4eb130d38171873a19c378`. Reading covers LX-root nesting, scalar-text policy, per-parse working state, binding/copy/mutation distinctions, colon hashes and retired fat-arrow rejection, nested updated-root writes, local value-block versus rule return, attached/lazy controls, first-case selection, literal bare labels and the 10,000-iteration guard. With/traversal callbacks preserve kind-specific empty/wrong-kind and restoration cases; lifecycle return/drop and fluent child-result containment remain distinct. The range ends at the regex_subst fixture prefix; its suffix remains .53-owned. Historical source comments do not override current assertions or scoped-binding Knowledge. No fresh native execution is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.52 - reconcile integration control and traversal reading`

- ID: `SESSION-STARTUP-READING.3.3.53`
  Status: `done`
  Goal: Read Rust group 53: 1,500 lines/fragments, 55,337 bytes.
  Scope: `rust/linkedspec-runtime/tests/integration_test.rs` lines 2791–3910;
    `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs` lines 1–380.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact owned-range/baseline identities and test-route/Knowledge reconciliation; memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; tests and runtime unchanged.
  Verification: Both scopes match the baseline: 1,500 lines / 55,337 bytes; ordered path/kind/range/byte/SHA audit `ead4b09249a3ecba074b27145e5169eaff3944d4f00ca72e803387487e7a0dfc`. Integration is complete through line 3910 across .51–.53. The suffix covers bounded shipped-spec outputs, edge/capture identity, fluent block/lifecycle controls, pure/mutating families, assignment results, closed function scope/arity/recursion and six rich capability fixtures including absent versus zero-width matches. Gap prefix covers role accounting, native/generated adapters, heterogeneous-separator primary proof and emitted Unicode/empty/lifecycle/child-extension/nesting/rollback fixture setup through line 380. Existing gap Knowledge separates historical admission and current behavior; the remaining consumer and emitted execution are not credited here. No fresh integration or emitted run is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.53 - complete integration reading and checkpoint gap-capture consumer`

- ID: `SESSION-STARTUP-READING.3.3.54`
  Status: `done`
  Goal: Read Rust group 54: 1,449 lines/fragments, 54,955 bytes.
  Scope: `rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs` lines 381–1225;
    `rust/linkedspec-runtime/tests/logical_helper_contract.rs` lines 1–496;
    `rust/linkedspec-runtime/tests/map_leaves_mutation_contract.rs` lines 1–108.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Three exact owned-range/baseline identities, emitted status-guard and logical-row evidence; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; tests and runtime unchanged.
  Verification: Three exact scopes total 1,449 lines / 54,955 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `9a1cbc848d1a482f98d1b4c67a51e45a56cf1a71dae4bf125a1c3d89a8c5ac3f`. Gap consumer completes all nine role paths, fifteen emitted value/error modules, slot metadata/diagnostics, serde defaults, candidate/commit/tail visibility and rollback. Logical consumer covers eager effects versus lazy controls, arity diagnostics, serialized/direct/compatibility routes and four emitted modules. Both emitted harnesses explicitly assert child-process success. Its truth adapter still skips only the codeblock row; later callable proof remains separate. The mutation prefix records zero-regex parent dispatch and typed inventory of 4 valid/14 invalid/5 excluded forms; its suffix remains .55-owned. Source inspection supplies no fresh native/emitted execution.
  Commit: `SESSION-STARTUP-READING.3.3.54 - complete gap and logical consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.55`
  Status: `done`
  Goal: Read Rust group 55: 1,500 lines/fragments, 53,737 bytes.
  Scope: `rust/linkedspec-runtime/tests/map_leaves_mutation_contract.rs` lines 109–732;
    `rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs` lines 1–876.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact two-scope/baseline audit, mutation/MCP assertion-boundary and Knowledge reconciliation; memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; runtime, MCP and test behavior unchanged.
  Verification: Two exact scopes total 1,500 lines / 53,737 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `04ef81d60c4c2b92f2cb119c8bf5dee5c4ade65b14a2aa6196b7518b60af06a6`. Mutation consumer completes typed Unicode syntax, original-shape traversal, detached callback/output values, unrelated effects, scoped identities, composition, typed receiver failures and serde/generated/emitted routes. Its protected statements precede return(value); known final-assignment/substitution exceptions .58/.59 remain outside those controls. The emitted workspace uses a relative dependency and checks child status. MCP prefix correlates six native snapshots/twenty query identities, 35 canonical frames, ten raw/lifecycle inventories, private handle states, capacity/expiry, lowering-only policy and prepared-cancellation fences. Hosts build native indexes before registration; no MCP authoring is present. Suffix privacy/shutdown/fences remain .56-owned; no fresh native run is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.55 - complete mutation consumer and checkpoint MCP admission reading`

- ID: `SESSION-STARTUP-READING.3.3.56`
  Status: `done`
  Goal: Read Rust group 56: 1,474 lines/fragments, 50,699 bytes.
  Scope: `rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs` lines 877–1058;
    `rust/linkedspec-runtime/tests/mcp_server_rust_dispatch.rs` lines 1–326;
    `rust/linkedspec-runtime/tests/mcp_server_rust_stdio.rs` lines 1–411;
    `rust/linkedspec-runtime/tests/progressive_span_dispatch_authority.rs` lines 1–555.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Four exact owned-range/baseline identities, MCP/progressive test-boundary reconciliation; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; transport and runtime unchanged.
  Verification: Four exact scopes total 1,474 lines / 50,699 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `063139bea5da82cfa8fe131ad67eae9c84d4298652f869456dc6c6a7cca81637`. MCP admission suffix checks prepared-response finality, ordinary I/O sanitization, Arc release, private-owner/source fences and twelve-role order. Public dispatch/stdio consumers cover clone isolation, native/policy identities, authorization/lifetime, canonical raw/ordered streams, EOF, ordinary I/O errors and invalid authority before input consumption. Existing .36/.64/.65 validation-order/panic-output/final-EOF gaps remain separately owned. Progressive prefix is opt-in cfg authority proof for source views, narrowing, cancellation/budget, chain/execution and 26 diagnostic contexts; the admitted four-carrier consumer is separate. Its suffix remains .57-owned. Existing completion records correct stale pending wording in the Rust admission card; no new native run is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.56 - complete MCP tests and reconcile progressive authority reading`

- ID: `SESSION-STARTUP-READING.3.3.57`
  Status: `done`
  Goal: Read Rust group 57: 1,476 lines/fragments, 52,176 bytes.
  Scope: `rust/linkedspec-runtime/tests/progressive_span_dispatch_authority.rs` lines 556–818;
    `rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs` lines 1–610;
    `rust/linkedspec-runtime/tests/punctuation_light_zero_arg_contract.rs` lines 1–226;
    `rust/linkedspec-runtime/tests/recognition_transaction_contract.rs` lines 1–377.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Four exact owned-range/baseline identities, carrier/arity/recognition proof-boundary reconciliation; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — bounded reading checkpoint; tests and runtime unchanged.
  Verification: Four exact scopes total 1,476 lines / 52,176 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `9f55a70cc97d378ab04bc24c0dea43b656a22cefc558517e2d6af1d3f716d882`. Progressive authority completes smaller rebased spans, shared budgets, detached registry/results and bounded diagnostics; its separate carrier consumer covers typed effects, host callback reconstruction and independent emitted child status/results. Punctuation-light tests cover six standalone spellings and final receivers through native/reconstructed/generated-plan/source assertions, explicitly preserving both zero-argument contains spellings returning numeric zero under the existing FUTURE-PARITY-BACKLOG.5 drift owner. Recognition prefix records neutral inventories/admission, monotonic isolated invocation/mark identity, match state independent of falsey payload and commit/rollback frame state. Recognition suffix remains .58-owned. No new native or emitted execution is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.57 - complete progressive and punctuation consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.58`
  Status: `done`
  Goal: Read Rust group 58: 1,471 lines/fragments, 49,296 bytes.
  Scope: `rust/linkedspec-runtime/tests/recognition_transaction_contract.rs` lines 378–932;
    `rust/linkedspec-runtime/tests/recursive_observation_contract.rs` lines 1–444;
    `rust/linkedspec-runtime/tests/repeated_action_result_contract.rs` lines 1–472.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact reading/source identities, emitted-manifest construction controls and existing policy boundary; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — reading and repair intake; manifest writers and policy implementation unchanged.
  Verification: Three exact scopes total 1,471 lines / 49,296 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `28a622601f3fe03251870fdfc8448469beab0bca1ac3da3c118e792788bd506e`. Recognition suffix distinguishes private escape rejection from authored .68, preserves terminal/ownership/unwind/drop diagnostics, typed nodes and false payload carriers. Observation covers static non-eager binding, detached Unicode and falsey results, failed/zero-regex/child-edge outcomes, ordinary recursion versus observed nonprogress and original abort diagnostics. Repeated-result prefix covers modes, scalar pipe, bounds, per-hit arrays/null, lifecycle/selected-slot traces and loaded/reconstructed/descriptor/primary/corpus/source-plan consumers; source inspection is not independent compilation. Two exact-source Rust construction probes reproduce absolute emitted Cargo dependencies, same-target relative controls and exact cleanup; nine source-confirmed writers are repair .78-owned with runnable Knowledge evidence. No fresh parser execution is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.58 - complete recognition and observation consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.59`
  Status: `done`
  Goal: Read Rust group 59: 1,487 lines/fragments, 48,937 bytes.
  Scope: `rust/linkedspec-runtime/tests/repeated_action_result_contract.rs` lines 473–516;
    `rust/linkedspec-runtime/tests/repository_root_relocation.rs` lines 1–95;
    `rust/linkedspec-runtime/tests/root_rule_selection_admission.rs` lines 1–610;
    `rust/linkedspec-runtime/tests/root_rule_selection_core.rs` lines 1–301;
    `rust/linkedspec-runtime/tests/root_rule_selection_routes.rs` lines 1–437.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact baseline/scope identities, root-selection governance and historical/current proof reconciliation; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — reading and factual continuity; source, contract and public behavior unchanged.
  Verification: Five exact scopes total 1,487 lines / 48,937 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `47aa1b4f635ba583721b93b0aebcc06d5e5574686370eea1bc41995f750e7fc6`. Repeated-result suffix pins fifteen exact roles and once-only completion. Relocation source copies the fresh primary into a managed synthetic root, distinguishes conflicting ambient identity and requires failure after the moved marker is removed. Root consumers preserve explicit/first-marker/first-rule selection without authored identity mutation, structure-before-selection-before-user-code, authored-edge strict-unused, direct/compatibility options, loaded/reconstructed/descriptor stability and effective/request trace attribution. Emitted-labelled admission roles inspect source; generated roles invoke generated-plan adapters. Independent compilation remains source_emitter-owned. Fresh root governance passes 8 selections / 3 failures / 3 strict cases / 5 backends / 7 complete / 0 pending / 24 public documents / 18 stale-current denials / 54 mutations. Historical Rust-only/65-case Knowledge claims are qualified and three Cargo reverify commands are managed. No fresh native/CLI/relocated/emitted execution is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.59 - complete Rust root-selection consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.60`
  Status: `done`
  Goal: Read Rust group 60: 1,472 lines/fragments, 49,181 bytes.
  Scope: `rust/linkedspec-runtime/tests/root_rule_selection_routes.rs` lines 438–472;
    `rust/linkedspec-runtime/tests/rule_local_cursor_contract.rs` lines 1–572;
    `rust/linkedspec-runtime/tests/rule_local_cursor_execution.rs` lines 1–465;
    `rust/linkedspec-runtime/tests/rule_local_cursor_normalization.rs` lines 1–50;
    `rust/linkedspec-runtime/tests/runtime_diagnostics.rs` lines 1–176;
    `rust/linkedspec-runtime/tests/scalar_numeric_contract.rs` lines 1–32;
    `rust/linkedspec-runtime/tests/semantic_index_foundation.rs` lines 1–142.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact baseline/scope identities, cursor governance and consumer proof-boundary reconciliation; Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: `none` — reading and factual continuity; source, contract and public behavior unchanged.
  Verification: Seven exact scopes total 1,472 lines / 49,181 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `410b4ae6ee1c9a0af971137008c6f0ab6f73122f7fc9fc2ad6c8b743e80e2b28`. Root-route suffix preserves effective failure attribution and authored descriptor identity. Cursor consumers cover 15 exact roles / 8 diagnostic-removal identities, 36 family forms / 8 child-boundary cases / 2 structural replacements, native/serde/loaded traces, minimal generated family plan and retired override absence; existing nonnumeric AND-selector repair .57 remains outside numeric exclusions. Historical normalization test naming is qualified. Runtime diagnostics cover structured/source/deep-child identity, unknown versus zero-rule contexts, omitted absent fields and legacy compatibility. Scalar numeric source pins 55 neutral cases. Semantic-foundation prefix covers source ownership/digest, detached plan, UTF-8/scalar mapping and mid-scalar rejection; suffix .61 remains. Fresh cursor governance passes 8 complete / 0 pending, 6 runtime legs, 74 migration files, 30 public documents, 28 denials and 60 mutations. No fresh native or emitted execution is claimed.
  Commit: `SESSION-STARTUP-READING.3.3.60 - complete Rust cursor and diagnostic consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.61`
  Status: `done`
  Goal: Read Rust group 61: 1,461 lines/fragments, 52,200 bytes.
  Scope: `rust/linkedspec-runtime/tests/semantic_index_foundation.rs` lines 143–269;
    `rust/linkedspec-runtime/tests/semantic_index_query.rs` lines 1–478;
    `rust/linkedspec-runtime/tests/semantic_index_runtime_observation.rs` lines 1–636;
    `rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs` lines 1–220.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Continuity work: Own the next required engineering-notes rollover, projected at this checkpoint from .55 at 439 lines plus six ordinary four-line records = 463 lines. Recheck actual pressure; preserve exact clean-source history and prior manifest rows. ADR 0105 current capacity is 25 collection files / 24 manifest lines, so any required count admission needs a new indexed exact-limit ADR and canonical staged proof; preserve other ceilings. Follow COMMIT.md if actual pressure triggers earlier.
  Verification tier: `canonical`
  Focused checks: Exact reading identities and semantic proof boundaries; immutable rollover/source/manifest reconstruction, exact routing-limit admission, Knowledge, memory, all doctrines, histories and diff.
  Canonical trigger: Required engineering-notes rollover and finite routing-registry capacity admission; exact staged-candidate receipt before landing.
  Verification: Four exact scopes total 1,461 lines / 52,200 baseline-identical bytes; ordered path/kind/range/byte/SHA audit `f378dd38e628f46477f1f4fdf2db59ba99fc84863aff46dc383265bfbfa92fe7`. Foundation suffix separates constructor policy from failed-language snapshots, immutable ceilings and cloned diagnostics. Query tests cover 19 static typed/raw-neutral digests, 26 malformed boundaries, privacy and no-execution isolation; .66/.67 remain outside those fixtures. Runtime tests compare eight routes' typed events and separately derive the twentieth query digest, reject malformed/rederived observations, preserve exact panic identity and trace/diagnostic/Unicode neutrality. Independent emitted proof checks value, count, positions and first/last kinds rather than a complete query digest; Knowledge is corrected and its manifest remains .78-owned. Admission prefix freezes 12 roles, six snapshots and exact event/digest helpers. Fresh neutral semantic proof passes 6 groups / 20 queries / 128 mutations / rollout 9/0 / admission 6/0. Mandatory engineering-notes rollover is part of this canonical leaf; exact storage evidence follows below and receipt-bound CI is required before landing.
  Storage proof: Exact clean 165b74dc lines 213–459 become segment 4982 (247 lines / 25,964 bytes; SHA-256 0cca6b887182b2d3abbd731a906726d05df4ab9916262d29dcef754f5d895b16). Prior manifest rows stay byte-identical; root is 215 lines / 32,427 bytes. ADR 0107 admits only files 25→26 and manifest lines 24→25; all other ceilings remain unchanged. Evidence: docs/knowledge/engineering-notes-twenty-sixth-member-capacity.md.
  Commit: `SESSION-STARTUP-READING.3.3.61 - complete semantic consumer reading and roll engineering notes`

- ID: `SESSION-STARTUP-READING.3.3.62`
  Status: `done`
  Goal: Read Rust group 62: 1,483 lines/fragments, 48,632 bytes.
  Scope: `rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs` lines 221–629;
    `rust/linkedspec-runtime/tests/source_boundary_compatibility_aliases.rs` lines 1–216;
    `rust/linkedspec-runtime/tests/source_emitter.rs` lines 1–858.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact source-range identities; semantic neutral contract; pinned routing and history child-status controls; Knowledge, memory, doctrines, history pressure and diff/scope review.
  Canonical trigger: `none` — reading and factual intake only; no public, runtime or enforcement implementation changes.
  Verification: Three scopes total 1,483 lines / 48,632 baseline-identical bytes; ordered path/kind/range/byte/SHA audit 9300b19ca3a98d513b9e7fdd43a53a35840ad52778cd7ecfc9e726847bbe8537. Admission suffix executes all 12 fixture roles and all 20 query digests; emitted-labelled routes call generated-plan helpers, with text tracing disabled at traced wrappers. Alias compatibility has five tests and four independently compiled modules with checked child status and relative Cargo paths. Emitter prefix covers eight corpus cases, sixteen entry points, typed construction failures and the fourteen-family fixture prefix; .63 owns its suffix. Reconcile historical admission/gate counts and retain the completed .61 native evidence; current neutral semantic proof is 6/20/128, rollout 9/0 and admission 6/0. Source-pinned routing controls reproduce signal-status loss and the guard control rejects it; nine document-history sibling controls reject failures. Actual repair .79 and its executable fact card are owned; public .41.3/.41.7 and repairs .71/.77/.78 remain pending. Record bounded September 8 loader samples without a new OS-cause claim. Focused continuity checks are recorded in the commit evidence.
  Commit: `SESSION-STARTUP-READING.3.3.62 - complete semantic admission and emitter boundary reading`

- ID: `SESSION-STARTUP-READING.3.3.63`
  Status: `done`
  Goal: Read Rust group 63: 1,492 lines/fragments, 58,940 bytes.
  Scope: `rust/linkedspec-runtime/tests/source_emitter.rs` lines 859–1166;
    `rust/linkedspec-runtime/tests/spec_loader.rs` lines 1–264;
    `rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs` lines 1–920.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact source-range identities; native resolution and staged-AST neutral contracts; source-to-Knowledge proof boundaries; memory, Knowledge, doctrines, histories and diff/scope review.
  Canonical trigger: `none` — bounded reading and factual reconciliation only; no production, public or infrastructure change.
  Verification: Three scopes total 1,492 lines / 58,940 baseline-identical bytes; ordered path/kind/range/byte/SHA audit 0fca63d946bf637732e40a6b44d9363dce564e62d131c10facb44072cac2d4ca. Emitter suffix completes fourteen fixtures across ten neutral families, v1 rejection and eight manifest-selected native/emitted oracle cases with checked child success; JSON literal and authored manifest repairs .71/.78 remain pending. Correct the older subset Knowledge card's unqualified all-105 classifier claim against actual repair .77 without invalidating a particular historical result. Loader tests cover 14/9/4 fixture cases plus function execution, identity and parse/validation JSON; directory construction is the non-regular surrogate, not every OS special-file type. Staged prefix covers frozen authority, cache/queue, all four result and three failure policies, sibling isolation, target checks, unpublished failure, resources and callback panic under a replaced hook; recursive suffix remains .64-owned and .73–.75 remain open. Fresh neutral resolution 14/9/4 and staged 9 rollout legs / 123 base / 129 public mutations pass. The earlier .61 canonical native result remains dated, fixture-bound evidence. Required focused continuity proof is retained with the commit.
  Commit: `SESSION-STARTUP-READING.3.3.63 - complete emitter, loader and staged consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.64`
  Status: `done`
  Goal: Read Rust group 64: 1,491 lines/fragments, 55,771 bytes.
  Scope: `rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs` lines 921–2268;
    `rust/linkedspec-runtime/tests/standalone_lifecycle_block_contract.rs` lines 1–143.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact source-range identities; staged-AST neutral contract and source-backed carrier/recursive proof boundaries; Knowledge, memory, doctrines, bounded histories and diff/scope review.
  Canonical trigger: `none` — bounded reading and factual reconciliation only; no production, public or infrastructure change.
  Verification: Two scopes total 1,491 lines / 55,771 baseline-identical bytes; ordered path/kind/range/byte/SHA audit 0d05f033e4e54ee1cb681c12b5f293e91bd98fa415b3afdfef26d0a16b1ab236. Complete staged consumer: breadth-first chain/cycle/decrease, shared resource and callback liveness, cancellation/deadline, detachment and direct/derived diagnostic controls; frozen snapshot pins 37 diagnostics, nine rollout legs and 123 mutations. Native/reconstructed/generated-plan/independently compiled emitted carriers each execute twice through fresh authority; both emitted Cargo children require success before JSON decoding. Existing .73–.75 runtime gaps and .78 authored absolute dependency remain open. Reconcile dated admission history and retain .61's native 1/1 in 802.08 test seconds without claiming another run. Standalone-lifecycle prefix defines native execution and AST/provenance helpers and starts placement twins; .65 owns the suffix. Fresh staged neutral governance passes 9 legs / 123 base / 129 public mutations; exact CI requirement/command registrations remain one each. Focused continuity proof is retained with the commit.
  Commit: `SESSION-STARTUP-READING.3.3.64 - complete staged recursive and carrier consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.65`
  Status: `done`
  Goal: Read Rust group 65: 1,500 lines/fragments, 51,021 bytes.
  Scope: `rust/linkedspec-runtime/tests/standalone_lifecycle_block_contract.rs` lines 144–470;
    `rust/linkedspec-runtime/tests/trace_controls.rs` lines 1–477;
    `rust/linkedspec-runtime/tests/typed_source_location_contract.rs` lines 1–546;
    `rust/linkedspec-runtime/tests/unicode_case_mapping.rs` lines 1–91;
    `rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs` lines 1–59.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact source-range identities; typed-source, Unicode-case and standalone neutral contracts; native/generated/emitted proof boundaries; Knowledge, memory, doctrines, histories and diff/scope review.
  Canonical trigger: `none` — bounded reading and factual reconciliation only; no production, public or infrastructure change.
  Verification: Five scopes total 1,500 lines / 51,021 baseline-identical bytes; ordered path/kind/range/byte/SHA audit d20f95e1727063d5d58c526759b549405f6820b8f45f14999c500fbc484f9ce7. Complete lifecycle tests: native/reconstructed duplicate execution, typed placement/provenance and malformed/owner/plain-node controls, generated-plan execution and emitted-text inspection without independent emitted compilation. Trace target has twelve tests; its historical eleven-test record is qualified, and emitted trace proof is also text inspection. Typed consumer covers 3/7/6/3 values, four private errors, exact detached 92+7 catalogs and three native/reconstructed/generated-helper fixtures; catalog equality is not execution of every helper. Casing consumer pins identity and checks direct/helper/receiver/array paths for twelve fixtures; label prefix retains distinct precomposed/decomposed/case identities with .66 owning its suffix. Fresh neutral typed 14/0/231, Unicode five-module byte regeneration/twelve fixtures and lifecycle fourteen mutations pass. Knowledge retains .61's dated typed four-test result and existing .52–.54 boundaries; this checkpoint adds no native target or optional-matrix rerun. Focused continuity proof is retained with the commit.
  Commit: `SESSION-STARTUP-READING.3.3.65 - complete lifecycle trace and typed-source consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.66`
  Status: `done`
  Goal: Read Rust group 66: 1,468 lines/fragments, 48,324 bytes.
  Scope: `rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs` lines 60–196;
    `rust/linkedspec-runtime/tests/uniform_binding_contract.rs` lines 1–525;
    `rust/linkedspec-runtime/tests/variadic_user_function_contract.rs` lines 1–214;
    `rust/linkedspec-runtime/tests/write_vivification_contract.rs` lines 1–592.
  Acceptance: Read every owned byte and apply the shared native-reading acceptance below.
  Verification tier: `focused`
  Focused checks: Exact four-scope baseline identities; Unicode-label, uniform-binding, callable-signature and write-vivification neutral contracts; precise native/generated/emitted consumer boundaries; Knowledge, memory, doctrines, histories and diff/scope review.
  Canonical trigger: `none` — bounded reading and factual reconciliation only; no production, public or infrastructure change.
  Verification: Four scopes total 1,468 lines / 48,324 baseline-identical bytes; ordered path/kind/range/byte/SHA audit c917155b39652776984df2a0ff341ef71799394032fce55c8f5bcb9e048fe576. Unicode labels: three native/trace/generated-helper and strict-loader tests; emitted identity is text inspection, and loader checks compilation without loaded-parser execution. Uniform binding: sixteen tests cover selector rejection, retained constructors, detached mutations, precedence, wrong-kind fields and native/generated helpers. Variadic: seven tests preserve exact unions, argument order, fresh rest arrays, arity/invalid-definition diagnostics and reconstructed/generated helpers; emitted signatures are inspected, not independently compiled. Write vivification: five parent tests cover frozen syntax/success/failure/local presence and one carrier fixture with an independently compiled emitted child, relative Cargo dependency and checked exit status. Four existing Knowledge cards retain these boundaries and historical runtime counts; no native or child Cargo target is freshly rerun. Fresh neutral Unicode806/9/8/2, binding11/7/6/8, signature3/9/7 and write5/7/11/16/3/3/8/105 pass. Focused continuity proof is retained with the commit.
  Commit: `SESSION-STARTUP-READING.3.3.66 - complete final Rust contract consumer reading`

- ID: `SESSION-STARTUP-READING.3.3.67`
  Status: `done`
  Goal: Close the Rust reading lane after every bounded child and final delta review.
  Acceptance: Verify all 412 baseline paths, current additions/deltas, complete comprehension, exact
    repair ownership, and Knowledge reconciliation. Reading is not runtime signoff. Require canonical
    proof for parent closeout and own the next language decomposition before new source reading.
  Verification tier: `canonical`
  Focused checks: Existing exact Rust scope reverify; independent committed-child, mode/blob/current-delta and pending-repair ownership audits; Knowledge reconciliation; memory, histories, staged diff/scope and all doctrines.
  Canonical trigger: `milestone` — Rust reading parent closeout; require receipt-bound canonical CI on the exact staged candidate.
  Verification: PASS: the existing scope audit covers all 412 baseline paths / 3,533,382 bytes exactly once, including two empty files and 89,242 per-window lines/fragments across 66 bounded children. All 66 done subjects resolve to unique commits; verification metadata, current mode/blob/byte identity and zero Rust additions/deletions/uncommitted inputs are independently checked. Reading-commit audit 312b1b4c03b2ad3897765e283c9772a7536122b39ee6d5740dff90874b860815; Rust tree-record audit 53e7795d9405342897bd3990e8fd55ee3a8cfdddb6e67dc977fefcb72dd3b68b. All 141 Knowledge paths changed by reading commits remain present. The 34 post-Perl repair owners preserve 90 pending nodes / 73 pending leaves, with exact body digest 3664cc76bff42040631d688fee5fa75bd4410f6588e1fd9eb45a882532ea967b. Existing earlier/cross-cutting repairs remain open. Reading is complete, not defect remediation or exhaustive runtime signoff. Final canonical outcome and exact staged receipt are required before landing and retained in the commit.
  Commit: `SESSION-STARTUP-READING.3.3.67 - close Rust reading with exact coverage and durable repair ownership`

- ID: `SESSION-STARTUP-READING.3.4`
  Status: `done`
  Goal: Split and read all 115 baseline Dart entries, including compiler/runtime, tests, commands, and package inputs.
  Reading owner: `docs/tasks/DART-STARTUP-READING.md` owns .0 decomposition, .1 reading, .2 new repair intake and .3 reading closeout; this startup node remains the prerequisite/closeout owner.
  Acceptance: Define bounded file/range children before reading and account for every path plus current deltas. DART-STARTUP-READING.3 may complete this reading node only after exact coverage/comprehension and child-commit proof; pending repairs remain owned separately.
  Verification: Dart physical reading is complete at 55/55 children, 80,297 fragments / 2,471,305 bytes. Dart reading closes under .3.2 / ADR0114, exercising the director's explicit delegated decision for this reading-only boundary. Independent proof covers all 55 commits, 115 baseline-identical files, 80,297 fragments and 2,471,305 bytes. All 25 repair roots / 69 pending nodes remain open. Committed diagnostics pass 461 tests, storage25/47, CLI66 twice and corpus105; the full Dart gate remains failed on formatting and two SDK warnings. No canonical CI or PGEN/RGX build ran. Next is startup .3.5 Julia decomposition. Capacities .4/.5/.6 remain committed under containment .8/.9/.10 and ADR0110/0111/0112. Startup .3/.4/.5 still gate repairs; .7 is approved and implemented by containment .11 / ADR0113 with exact history preservation; the director granted a one-time focused/receipt exception on 2026-09-11; Containment .11 is committed at ad64f76f; Dart .3.2 / ADR0114 now close only this reading prerequisite; next .3.5 Julia decomposition.
  Commit: `DART-STARTUP-READING.3.2 - close verified Dart reading under delegated decision` (cross-tree reading closeout)

- ID: `SESSION-STARTUP-READING.3.5`
  Status: `done`
  Goal: Split and read all 95 baseline Julia entries, including compiler/runtime, tests, commands, and package inputs.
  Acceptance: Define bounded file/range children before reading and account for every path plus current deltas.
  Children: `.3.5.0` owns decomposition; JULIA-STARTUP-READING.1 owns 52 reading children and .3 owns closeout.
  Reading owner: `docs/tasks/JULIA-STARTUP-READING.md` retains exact scope/digest, comprehension and repair evidence. This startup node remains the prerequisite owner.
  Verification: Julia .3.2 closes all 52 reading groups under explicit ADR0117 approval. Audit d62999c12 and its fresh replay verify 95 baseline-identical files (75,984 lines / 2,693,170 bytes), 52 committed scopes and activations, 122 fact cards and 80 pending repair nodes. Recorded component proof passes 12,903 assertions, storage checks for 22 owners and five package trees, primary CLI conformance and 105 corpus fixtures. All repairs and later verification requirements remain open. Lua startup .3.6 decomposition is next; full-codebase reading, formal book reconciliation and policy review remain incomplete. Exact plan and all source identities remain frozen in the Julia owner.
  Commit: `JULIA-STARTUP-READING.3.2 - close verified Julia reading under approved exception` (Julia reading prerequisite closure)

- ID: `SESSION-STARTUP-READING.3.5.0`
  Status: `done`
  Goal: Inventory and plan exact bounded Julia source reading within governed evidence capacity.
  Dependencies: Dart reading .3.2 committed under ADR0114; root clean, empty brief and all jobs consumed.
  Activation: Clean `a2788b95369964880534d4d7b1d0e31b106bc023`.
  Scope: The 95 Git-baseline Julia entries at baeb984e36a94a15951cd23d4c52def5064cdaca, every current membership/mode/blob delta, and task/Knowledge/history capacity needed for bounded reading.
  Acceptance: Reconstruct exact inventory and a disjoint complete range plan under1500 fragments/65536 bytes per child, with UTF-8-safe oversized-line handling. Measure current and projected evidence limits before adding reading children. Freeze navigable ownership if the plan fits; otherwise preserve a concrete bounded capacity proposal and its unblock conditions without raising limits or discarding evidence. Grant no physical source-reading credit; preserve all prior startup/Dart repairs and parked activities.
  Verification tier: `focused`
  Focused checks: Independent Git inventory/mode/blob/current-delta and range-coverage/digest audits; actual routing-pressure and projection census; both histories, all doctrines, Knowledge, rendered book and prior-evidence preservation.
  Canonical trigger: `none` — bounded source-reading inventory/decomposition or capacity proposal only; no source, runtime, dependency, infrastructure or control change. A capacity implementation or later milestone retains its own required boundary.
  Verification: All 95 Julia baseline modes/blobs/current bytes remain exact;52 groups /146 inclusive ranges independently reconstruct 75984 lines/2693170 bytes exactly once, with all child bounds/digests. No empty entry or oversized-line split. New 639-line/48991-byte Julia member preserves startup member space and stays within unchanged aggregate/member controls. Compared 55 Dart reading commits forecast 1144 task lines/245095 bytes,5490 Knowledge lines/377493 bytes and 387 map lines/77475 bytes; current resulting controls and history checks pass, but future history rollovers have no free member slots and remain explicitly owned by Julia .4. All prior task/Knowledge/ADR/history evidence and source bytes remain; book and pointers distinguish plan 0/52 from physical reading. No runtime/component gate, canonical CI or dependency build is claimed.
  Commit: `SESSION-STARTUP-READING.3.5.0 - freeze exact bounded Julia reading plan`

- ID: `SESSION-STARTUP-READING.3.6`
  Status: `done`
  Goal: Split and read all 99 baseline Lua entries, including native adapters, both-ABI tests, runtime, and commands.
  Children: `.3.6.0` owns decomposition; LUA-STARTUP-READING.1 owns 51 reading children and .3 owns independent closeout.
  Reading owner: `docs/tasks/LUA-STARTUP-READING.md`; .4/.4.2 close under ADR0118 and containment .14; exact reading is 51/51; .3.1 audit and .3.2 closeout are complete under ADR0119; .2.1-.2.35 own thirty-five concrete repair roots, with installed5.5 nil-error failures under .2.2 and shared Lua budget repair under .82.3.1; .28.7 owns the baseline public-check failure.
  Acceptance: Define bounded file/range children before reading; generated tables and the large test runner stay in scope.
  Verification: Lua reading closes under the director-authorized ADR0119 disposition. Both exact .3.1 recipes pass again: 51 unique reading commits/activations, 149 ranges, 99 baseline-identical files, 71,269 fragments /2,732,450 bytes and 51 unchanged comprehension cards. All 35 repair roots/145 pending nodes remain exact. Known PUC5.5 native120/121 and generated79/80 failures, four native-error exclusions, absent full Lua/PUC5.4 proof and startup .28.7 remain explicit. Close only Lua .1/.3/.3.2 and startup .3.6; no canonical CI/receipt or dependency build. The requirement is reuse of compatible unchanged RGX/PGEN products, not a restriction on reading. Next startup .3.7 inventories and bounds remaining supporting ranges; all repairs, later verification, formal book/policy and parked features remain.
  Commit: `LUA-STARTUP-READING.3.2 - close authorized Lua reading and resume supporting inventory` (Lua reading container)

- ID: `SESSION-STARTUP-READING.3.6.0`
  Status: `done`
  Goal: Inventory all Lua inputs and freeze bounded reading ownership with a measured evidence-capacity plan.
  Activation commit: `9824c097148235268964acbdf47984d9933753a8`.
  Dependencies: Julia reading closeout committed under ADR0117; clean tree, zero-byte brief and no unconsumed jobs.
  Scope: All 99 Lua entries at baseline baeb984e36a94a15951cd23d4c52def5064cdaca, current membership/mode/blob deltas and required task/Knowledge/history capacity.
  Acceptance: Independently reconstruct every baseline byte through disjoint ranges bounded by 1500 fragments and 65536 bytes per child. Preserve generated data and UTF-8 boundaries. Freeze concrete children if the resulting plan fits; otherwise retain exact inventory, a concrete proposal and unblock conditions. Measure future evidence using actual comparable commits. Grant no physical reading credit, repair closure, capacity increase or later verification exception.
  Verification tier: `focused`
  Focused checks: Exact inventory/current-delta and independent range/digest audits; current and forecast routing capacity; old task/card/source/history preservation; Knowledge, memory, both histories, book rendering and all normal doctrines.
  Canonical trigger: `none` — source-reading inventory/decomposition and capacity proposal only. Any later infrastructure implementation or reading closeout retains its own required verification boundary.
  Verification: Lua decomposition freezes 51 pending reading children across 99 baseline-identical files: 71,268 physical lines, 71,269 fragments and 2,732,450 bytes. The independent 149-range audit includes two UTF-8-safe byte windows for an oversized generated MCP line. No source comprehension is claimed. The current plan fits unchanged limits; comparable Julia reading growth exceeds remaining Knowledge capacity. LUA-STARTUP-READING.4.1 prepares a coherent capacity disposition before reading. All previous reading, repairs and verification requirements remain intact. Independent replay preserves exact inventory/range/child-summary digests, all bounds, complete EOF coverage and zero reading credit. Comparable 52-commit audit reproduces Knowledge 6615 lines / 402364 bytes / 27 files and complete new history records (364 change lines / 365 note lines), excluding rollover subtraction. Preservation passes 2371 prior task nodes and 2205 source/card/decision/history/control files, exact history suffixes, four current Lua frontiers and all 27 rendered limitations. Knowledge generation (1084 facts / 8729 keys), explicit memory, both histories, book build and diff checks pass. Resulting Knowledge is 1085 files / 73927 lines / 5854640 bytes; tasks 104 files / 85296 lines / 8953769 bytes before this same-line result update. All collection/member limits remain unchanged and pass; normal doctrine hooks govern landing.
  Commit: `SESSION-STARTUP-READING.3.6.0 - freeze exact Lua reading ownership and capacity intake`

- ID: `SESSION-STARTUP-READING.3.7`
  Status: `done`
  Goal: Account for all 158 original supporting entries and read the current language/runtime dependencies required by the director’s clarified scope.
  Children: `.3.7.0` completes decomposition; SUPPORTING-SOURCE-READING.1 owns 21 reading groups, .2 new repair intake, .3 independent closeout.
  Reading owner: `docs/tasks/SUPPORTING-SOURCE-READING.md`; required .1 reading and independent .3 audit close under explicit ADR0120 grant after checker .2.6 commits clean. Six grammar/literal repair roots and all historical exclusions remain separate.
  Acceptance: Account for legacy adapters, plugins, authored grammars, configuration, and non-TypeScript `.ts` data;
    use LinkedSpec probes before investigating a spec's behavior, and do not infer defects from historical syntax alone.
  Verification: Supporting .1 closes with exact158-source/174-range baseline and current identity; required629/96781, historical1500/61165 and explicit omissions23484/806310 fragments/bytes. All21 reading nodes, three reading commits/five ranges/nineteen windows and nine pending repair nodes reconcile; focused normal doctrines/book/preservation replace this one full-CI closeout under ADR0120. No remaining reading or runtime signoff is implied.
  Commit: `SUPPORTING-SOURCE-READING.1 - close audited supporting reading under explicit focused grant`

- ID: `SESSION-STARTUP-READING.3.7.0`
  Status: `done`
  Activation commit: `735f0337883baef5ac4422976879d09725e0e8ea`.
  Goal: Inventory supporting sources, reconcile exact prior reading and own every unread range before execution.
  Scope: All 158 baseline entries under specs, ebnf, noncore, conf and tablescript; current mode/blob/membership deltas; explicit prior coverage; bounded reading and evidence capacity within existing limits.
  Dependencies: Lua reading closeout .3.2 committed under ADR0119; clean handoff, empty brief, all jobs consumed.
  Acceptance: Account for every baseline/current byte without reading credit from enumeration. Preserve proven earlier ranges and all repairs; define coherent children within 1500 fragments/65536 bytes before source reading. Measure the actual decomposition against current controls without unapproved increases. Keep book, roadmaps and continuity aligned; no parser, runtime, dependency or gate change.
  Verification tier: `focused`
  Focused checks: Independent Git/current-delta inventory, disjoint full-range reconstruction and prior-evidence reconciliation; actual capacity, task/source/Knowledge/history preservation, memory, both histories, book and normal doctrines.
  Canonical trigger: None for this read-only inventory and documentation decomposition; no milestone closeout or infrastructure implementation. ADR0119 and the director authorize continuing reading; preserve later verification and compatible dependency reuse.
  Verification: Supporting-source inventory .3.7.0 reconciles all 158 baseline-identical files under conf, tablescript, noncore, specs and ebnf: 25,612 LF delimiters, 25,613 fragments and 964,256 bytes. SUPPORTING-SOURCE-READING owns 21 pending groups/174 disjoint ranges; independent Git, current-delta and published-task reconstruction pass with every group within 1,500 fragments /65,536 bytes. No exact earlier startup Scope coverage is credited; physical reading is 0/21. The resulting decomposition uses existing controls, preserves all repairs and changes no source. Lua reading remains closed under ADR0119; next supporting .1.1 reads configuration. No dependency compilation or canonical gate is run; full codebase/book/policy prerequisites and later verification remain. Exact replay and ownership: docs/knowledge/supporting-source-reading-coverage.md; docs/tasks/SUPPORTING-SOURCE-READING.md.
  Candidate verification: All three exact published recipes pass; preservation retains 1589 prior source/card/decision/history files and 2589/2590 prior task nodes, changing only startup .3.7 and adding exactly 26 owned nodes. All 92 Known headings, historical chronology and three published payloads remain exact; no reading credit is added. Knowledge generation is 1139 facts/9091 keys; memory 60 lines; histories 375/305 lines, 68 segments and 34 mutation controls pass without rollover. Book rendering/content and all 20 resulting pressure surfaces/62 routes/32 mutation classes pass; normal doctrine hooks govern landing.
  Commit: `SESSION-STARTUP-READING.3.7.0 - own exact supporting-source reading ranges`.

- ID: `SESSION-STARTUP-READING.3.8`
  Status: `active`
  Goal: Split and read all 160 entries under capability_conformance, cli_conformance, t, tests, and unicode_case.
  Children: `.3.8.0` owns exact decomposition; `CONFORMANCE-SOURCE-READING.1` owns all143 reading groups; .2 findings and .3 independent closeout stay separate.
  Reading owner: `docs/tasks/CONFORMANCE-SOURCE-READING.md`; 143 groups/302 baseline ranges over160 inputs. Physical reading61/143:77,753 fragments/3,067,280 baseline bytes and97 complete files; Phase0 through28258. Approved113-byte inventory delta stays separate. Retained eleven-subtest proof has107 direct assertions including42 nested results/364 inner assertions. Structured branch code-output-labelled slot comparisons retain existing .2.10 observation limits; .2.5–.2.11 and all prerequisites remain. .1.62 continues the deep-marker action pair metadata assertions. ADR0122/containment .15 are canonically admitted at ec10be6b.
  Acceptance: Include phase0, neutral contracts, fixtures, generators, and four explicitly decoded pinned Unicode
    inputs. Keep generated/fixture bytes in scope; count neither a hash nor enumeration as full reading.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.3.8.0`
  Status: `done`
  Activation commit: `9833430954c3999769045abbcaa4d20389a7af4c`.
  Verification tier: `focused`
  Focused checks: Exact baseline/current Git mode/blob/path and decoded-source inventory; all143 groups/302 disjoint ranges and per-group budgets; four pinned Unicode inputs; source/task/history preservation, memory, Knowledge, histories, rendered book and normal doctrine hooks.
  Canonical trigger: Ordinary source-reading decomposition; no source/runtime/dependency/registry change or parent closeout. Earlier ADR0120 exceptions are consumed and are not extended.
  Goal: Own every conformance/test/Unicode reading range before reading, preserving exact baseline identity and continuity.
  Dependencies: Supporting reading .1/startup .3.7 close at983343095 with all doctrines, zero-byte brief and clean handoff.
  Acceptance: Account for all160 baseline paths and current deltas, including four explicitly decoded pinned Unicode inputs; create exact bounded reading tasks and reproducible independent coverage proof. Preserve generated fixtures, original sources, existing repairs and capacity limits; inventory/decompression/hashes receive no physical-reading credit.
  Verification: Independent baseline/current Git mode/blob/path and present-byte equality PASS for160 files/5422313 stored bytes; four gzip sources decode to8257059 total bytes/167606 fragments. Exact Scope-driven audit validates143 groups/302 disjoint ranges, all1500/65536 budgets and four decoded hashes. Unicode casing1563/1581 mappings,158/464 property ranges/12 fixtures and rule labels806/9/8/2 PASS. No physical-reading credit, source change or new limit. Canonical evidence and current replay: conformance-source-reading-coverage. Preservation, memory, Knowledge, histories, rendered book and all normal doctrines govern focused planning landing.
  Candidate proof: Preserve2486 prior files byte-exact, all earlier recipe blocks,2627/2628 prior nodes and all94 book limitation headings. Only startup .3.8 changes; new .3.8.0 plus147 conformance-tree nodes own the plan. Metadata PASS at105 files/89554 lines/9507983 bytes before this annotation;2776 current IDs are unique. Memory60; histories439/45244 and369/44107 lines/bytes; rendered book PASS. Normal doctrine hooks govern landing.
  Commit: `SESSION-STARTUP-READING.3.8.0 - own exact conformance test and decoded Unicode reading ranges`

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
  Verification: Physical source reading is complete under .31/.3.2.42: 50 files / 1,956,582 bytes,
    exact baseline identity and nonoverlapping interval/hash proof. Formal codebase/roadmap reconciliation,
    subsequent deltas, and rendered inspection remain pending; .41 owns the additional verified book drift.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.5`
  Status: `pending`
  Goal: Complete supplied-policy adoption/update comparisons and the startup alignment review before implementation.
  Acceptance: Record local adoption evidence and applicable donor updates; own any required changes; confirm all
    three reading answers Yes. Review and complete `.29` as part of adoption before this closeout, then route to
    the remaining tracked startup repairs before restoring RUST-MUTATION-TESTING.1. During alignment, qualify
    ADR 0055 section 5 against the later all-twenty repair: only explicit overlay components enforce transport
    pre-dispatch denial; unsupplied components stay with native diagnostics. `.3.2.36` records matching neutral/
    embedded policy evidence; preserve historical decision evidence while making its current boundary explicit.
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
  Commit: `SESSION-STARTUP-READING.6 - diagnose denied liveness probes` — Exact causal evidence and owned repair; no production change or deletion test.

- ID: `SESSION-STARTUP-READING.7`
  Status: `pending`
  Goal: Repair permission-denied liveness handling before any managed recovery or mutation workspace workflow.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; `.6` causal evidence.
  Acceptance: Distinguish confirmed absence from denied/unknown PID and group inspection; denied or unknown
    results must retain scratch. Cover wrapper, child, group, normal drain, recovery, and retained-failure purge
    with non-destructive deterministic EPERM/ESRCH tests and a live restricted-process control. Preserve positive
    dead-run cleanup, signal forwarding, PID-reuse conservatism, same-volume storage, and valid marker ownership.
    Verify child process-group establishment before trusting the recorded group identity: `.3.2.27` observed
    a child setpgid EPERM warning followed by successful generation. Its original PGID was not captured;
    a subsequent PID/PGID control matches. Distinguish benign parent/child setup races from failed group
    establishment with controlled evidence, and retain scratch if the group identity cannot be established.
    Update Toolbox/book/KM claims, run focused lifecycle/storage/dependent checks and exact canonical proof.
    Split into bounded children before implementation if needed; reading prerequisites remain mandatory.
  Reading Lua .1.21 recurrence: The managed PUC descriptor run emits child setpgid EPERM for child47639 then passes 912 assertions and exits0. Its original PGID was not captured. A separate control has matching PID/PGID50782 and read-only listing finds zero runs; neither retroactively proves the original group. Existing establishment/failure repair and recovery/purge restrictions remain. Evidence: docs/knowledge/lua-spec-ast-loader-reading-and-validation-gaps.md.
  Integration .5.3 recurrence (September20): Exact concurrent consumer replay captures a clean LuaJIT command with correct values/status0 plus the wrapper's child setpgid EPERM diagnostic for child571. A separate1000-command PID/PGID probe captures a warning for child29222 with actual PID=PGID29222 and parent28526; all1000 commands exit0 with expected groups. This is measured successful establishment in a warned invocation, not proof of its kernel/timing cause or all lifecycle paths. The earlier PUC stream was lost and is not retroactively identified. Preserve this actual warned-group control in the eventual repair; do not filter warnings or waive denied/unknown handling. Source and all .3/.4/.5 prerequisites remain unchanged. Canonical evidence: docs/knowledge/project-data-liveness-permission-denial.md; raw evidence: .linkedspec-data/scratch/backend-integration53.
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

- ID: `SESSION-STARTUP-READING.16`
  Status: `pending`
  Goal: Make emptiness depend on the evaluated DSL value and keep literals out of host symbol lookup.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; nested-span repair `.15` precedes this activity.
  Children: `.16.1`, `.16.2`

- ID: `SESSION-STARTUP-READING.16.1`
  Status: `pending`
  Goal: Apply one typed emptiness rule to literals, bindings, nested reads, and computed values.
  Acceptance: Lock the public literal `"0"` versus bound `"0"` discrepancy, empty-string controls, and
    is_nonempty inversion. Evaluate each expression once and preserve documented undefined/empty scalar,
    array, and hash semantics across conditions, assignments, return values, fluent and attached forms.
    Cover booleans/numeric zero, computed zero text, nested containers, and side effects; compare direct and
    generated/loaded routes plus the direct-dependent backend contract. Update mdBook/Knowledge and commit.
  Verification: `pending` — `.3.2.21` public Get returns empty for literal `"0"`, nonempty for its bound twin.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.16.2`
  Status: `pending`
  Goal: Prevent numeric and keyword literal tokens from becoming generated host scalar references.
  Dependencies: `.16.1`
  Acceptance: Tighten scalar-symbol recognition or classify typed literal values before lookup, with an audit
    of direct consumers. Lock is_empty numeric/boolean/undef forms, program-name and regex-capture independence,
    valid identifiers, Unicode/name exclusions, and compound-expression boundaries. Preserve binding identity,
    generated diagnostics, and supported emitted/loaded behavior; run direct-dependent proof and update book.
  Verification: `pending` — `.3.2.21` lowering emits `$0` for literal 0 through the permissive scalar extractor.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.17`
  Status: `pending`
  Goal: Make wrong-kind collection helpers independent of same-named Perl host slots.
  Dependencies: Required reading `.3`/`.4` and policy `.5`; emptiness/literal repair `.16`.
  Children: `.17.1`, `.17.2`

- ID: `SESSION-STARTUP-READING.17.1`
  Status: `pending`
  Goal: Guard array helpers by the evaluated DSL value kind before host-slot fallback.
  Acceptance: Lock count/first/last on wrong-kind values against isolated empty/nonempty same-named host arrays.
    Audit direct array-helper consumers, evaluate operands once, preserve valid binding/array behavior and
    supported generated/loaded routes, and update the book and Knowledge with focused direct-dependent proof.
  Verification: `pending` — intake `.31` records six parser/host-seed controls; no repair has landed.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.17.2`
  Status: `pending`
  Goal: Apply the same evaluated-value boundary to hash counts, key views, and membership.
  Acceptance: Lock count_keys/sorted_keys/has_key against unrelated host hashes; cover wrong kinds, present null,
    missing keys, evaluated key order, detached views and snapshots, side effects, and supported carriers.
    Reconcile the governed wrong-kind contract before changing results; preserve valid aggregate bindings.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.18`
  Status: `pending`
  Goal: Preserve quoted source data through primitive rewriting and canonical-event scanning.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.18.1`, `.18.2`

- ID: `SESSION-STARTUP-READING.18.1`
  Status: `pending`
  Goal: Prevent primitive set rewriting from modifying text inside a quoted value.
  Acceptance: Turn the recorded quoted set(counter, 2) corruption into a regression; cover both quote forms,
    escaped delimiters, comments, regex literals, nested calls, and genuine executable set operations.
    Use actual lexical/source spans rather than blind substring substitution; preserve downstream source identity.
  Verification: `pending` — PrimitivePipelineRules' unmasked matcher and raw replacement are localized in `.31`.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.18.2`
  Status: `pending`
  Goal: Emit canonical assignment events only for executable assignment syntax.
  Acceptance: Reject the false ASSIGN event contributed by quoted helper-looking text while retaining real,
    nested, and repeated assignment events, stable order, exact spans, and once-only event production.
    Cover descriptor, generated, and direct-dependent scanner consumers; synchronize public teaching as needed.
  Verification: `pending` — CanonicalEvents independently scans the unmasked quoted spelling.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.19`
  Status: `pending`
  Goal: Enforce the active map_leaves! receiver guard for dynamic codeblock assignment.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Lock the dynamic-callback bypass alongside the already-rejected direct write. Route nonparameter
    binding writes through resolved receiver identity checks; preserve parameter shadowing, pure function scope,
    atomic traversal/rebind, exception unwinding, detached results, and post-commit continuation.
    Audit all CodeblockRuntime write paths and supported carriers; run direct-dependent mutation/callable proof.
  Verification: `pending` — `.31` records guarded direct assignment versus unguarded dynamic callback writes.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.20`
  Status: `pending`
  Goal: Remove Unicode-digit truncation and warning-producing scalar numeric coercion.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.20.1`, `.20.2`

- ID: `SESSION-STARTUP-READING.20.1`
  Status: `pending`
  Goal: Resolve the numeric-string digit language against the normative grammar and independent model.
  Acceptance: Compare Arabic-Indic and mixed-digit strings with ASCII controls across the neutral oracle and
    native routes. Distinguish accepted-digit conversion from unsupported-digit rejection; do not assume ASCII
    rejection or silently bless host truncation. If the governed intent remains ambiguous, ask the director
    before changing it. Own the exact bounded implementation and fixture movement before editing consumers.
  Verification: `pending` — Perl and the neutral Python oracle currently disagree on two recorded strings.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.20.2`
  Status: `pending`
  Goal: Implement the resolved numeric boundary consistently and without host conversion warnings.
  Dependencies: `.20.1`.
  Acceptance: Apply the resolved rule to all affected numeric consumers and carriers; preserve the governed
    55-case / 18-helper contract, finite-value rules, ASCII controls, and independent expected results.
    Include non-ASCII/mixed-digit negative or positive locks, generated execution, and accurate book examples.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.21`
  Status: `pending`
  Goal: Make recognition-token escape validation lexical and independent of compilation order.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.21.1`, `.21.2`

- ID: `SESSION-STARTUP-READING.21.1`
  Status: `pending`
  Goal: Remove first-token-name caching from recognition-token validation.
  Acceptance: Lock fresh and warmed compiler orders for multiple token names, repeated compilation, Unicode
    identifiers, rejected bare escapes, and valid nonescaping use. Preserve exact diagnostics and authority
    boundaries; a missing compile rejection is not evidence that active authority escaped at runtime.
  Verification: `pending` — the variable-interpolated /o matcher caches the first token name.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.21.2`
  Status: `pending`
  Goal: Exclude literal/comment occurrences from recognition-token escape detection.
  Acceptance: Preserve quoted token-name text while rejecting actual bare escapes; cover nested value syntax,
    comments, regexes, escaped delimiters, source spans, and supported serialized/generated consumers.
    Run the recognition contract and direct-dependent lifecycle/error controls; update book and Knowledge.
  Verification: `pending` — quoted token-name text is currently misclassified by the raw search.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.22`
  Status: `pending`
  Goal: Project rule helpers, bindings, and calls independently of an unrelated user-function definition.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.22.1`, `.22.2`, `.22.3`

- ID: `SESSION-STARTUP-READING.22.1`
  Status: `pending`
  Goal: Bound the native and frozen-model impact of the empty-function early return.
  Acceptance: Reproduce the same valid rule on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; retain the
    zero-versus-five record evidence now measured on all five backends/six runtime routes: .3.3.30 adds
    fresh Rust/Perl pairs; the other runtime measurements remain the dated September 6 intake evidence.
    Inventory affected frozen models, digests, bindings, admissions, and public examples. Define a safe
    coordinated repair boundary before changing exact expected data; do not silently adapt an oracle.
  Verification: `pending`
  Commit: `pending`
  Lua .1.19: Fresh public raw queries on both installed hosts reproduce zero helper/binding/call records without a function versus five with an unused function; both independently execute x. The guard still precedes action-owner traversal. Preserve the earlier six-runtime census as dated evidence; these two new host observations do not refresh all backends.

- ID: `SESSION-STARTUP-READING.22.2`
  Status: `pending`
  Goal: Repair the affected projection owners with independently justified shared expectations.
  Dependencies: `.22.1`.
  Acceptance: Include helper-only rules, unused-function twins, actual user functions, binding/call order,
    exact source IDs/spans, and existing function vocabulary. Coordinate inseparable native/model changes
    in the boundary approved by the impact audit; split further before editing if it exceeds a safe slice.
    Preserve query limits, immutable snapshots, compile failures, and unsupported-source exclusions.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.22.3`
  Status: `pending`
  Goal: Close supported semantic carriers, MCP projection, and public teaching for the corrected rule records.
  Acceptance: Recompose exact native, serialized/reconstructed, generated/emitted, and MCP behavior where
    supported. Preserve unchanged transport/security contracts and reject stale missing-record expectations.
    Update governed book examples and ownership facts; complete the required canonical closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.23`
  Status: `pending`
  Goal: Preserve honest compilation-failure decision and explanation evidence.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Retain the already-correct recognition_token_escape diagnostic code and message while
    replacing its fabricated dependency_resolution decision/dependency_target_missing explanation.
    Keep genuine unknown-rule diagnostics correct, avoid uninitialized blank-target warnings, use honest
    fallback for unclassified failures, and preserve exact source evidence across native/generated/MCP routes.
    Extend the actual failure-class matrix and synchronize the book and existing authority records.
  Verification: `pending` — `.3.2.44` refines .31 with two exact public Get/query controls: the original
    diagnostic code/message survive, but unrelated failure gets a false dependency decision/explanation
    and an undefined-target warning. The bare missing-rule control retains correct code, span, and explanation.
    .3.3.32 Rust missing-rule and out-of-range-slot controls retain correct distinct diagnostics; the
    latter is caught by resolve_selector before slot-failure normalization. Token-use acceptance is .68.
  Julia .1.28 controls: bare Missing preserves native bare_edge_target_undefined and truthful unknown_rule_reference/source/dependency evidence; Child[9] preserves regex_slot_index_out_of_range/resolve_selector and exact authored source without a fabricated decision. The selector guard precedes failure normalization. Exact67-assertion controls live in docs/knowledge/julia-semantic-static-correlation-gaps.md; no Perl repair or full failure-class closure is claimed.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.24`
  Status: `pending`
  Goal: Preserve the caller's Perl exception state while evaluating lazy trace detail callbacks.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Lock quiet, plain-detail, successful-callback, and throwing-callback cases against the same
    incoming exception. Preserve exception object identity, laziness, nested/reentrant trace calls, parser
    context, and existing callback/sink failure contracts. Audit the direct callback evaluation paths and
    validate supported generated/CLI trace consumers without enabling callbacks at quiet levels.
    Distinguish direct owner/generated calls from dispatch_owner_call: the latter already preserves
    successful-call exception state, including object identity. Do not describe the wrapper as defective.
  Verification: `pending` — direct Trace lazy eval replaces incoming $@ on success/failure/nested detail;
    .3.2.48's 20 controls preserve quiet/plain direct state and all OwnerDispatch-wrapped cases.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.25`
  Status: `pending`
  Goal: Correct gdcheck tolerance, duplicate-row, and DEFAULT cardinality behavior.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.25.1`, `.25.2`, `.25.3`

- ID: `SESSION-STARTUP-READING.25.1`
  Status: `pending`
  Goal: Compare signed values using the intended nonnegative tolerance magnitude.
  Acceptance: Lock equal negative values and values within tolerance beside positive twins; cover zero,
    tolerance boundaries, rejected invalid configuration, exact masks, and existing comparison operators.
    Preserve the configured meaning of tolerance and document the resolved signed-value examples.
  Verification: `pending` — signed baseline multiplication reverses the interval for negative values.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.25.2`
  Status: `pending`
  Goal: Process every duplicate-key row when data is added or removed.
  Acceptance: Lock zero-to-two and two-to-zero duplicate transitions, unequal duplicate counts, stable row
    correspondence/order, every add/remove mask, and unaffected columns. Preserve existing keyed comparison
    semantics rather than dropping all but index zero; add focused utility-level regression examples.
  Verification: `pending` — addition/removal currently uses only each key's first indexed row.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.25.3`
  Status: `pending`
  Goal: Require exactly one DEFAULT pattern by actual array cardinality.
  Acceptance: Cover zero, one, two, and more-than-nine authored patterns, consistent diagnostics, and valid
    non-DEFAULT entries. Replace the decimal-string length test without broadening the configuration grammar.
  Verification: `pending` — zero and two patterns are accepted because length(@EVAL) tests digit length.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.26`
  Status: `pending`
  Goal: Make ptchange file IO preserve valid caller filenames and diagnose failed reads/writes.
  Dependencies: `.3`/`.4` and storage-policy review `.5`.
  Acceptance: Replace shell-split input reading and ambiguous output opens; lock plain, spaced, Unicode, and
    metacharacter filenames, unchanged transformation/clock output, and safe read/write failure behavior.
    Resolve the machine-specific shebang and repository-derived default outputs under the reviewed locality
    policy. Use exact owned fixtures and prevent silent empty output or unintended clobbering.
  Verification: `pending` — identical plain/spaced inputs produce preserved text versus empty output, both exit 0.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.27`
  Status: `pending`
  Goal: Resolve and repair the known Perl lifecycle final-value/E-handler divergence.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.27.1`, `.27.2`, `.27.3`

- ID: `SESSION-STARTUP-READING.27.1`
  Status: `pending`
  Goal: Reconcile lifecycle return and mode execution against ADR 0020 and exact cross-backend evidence.
  Acceptance: Compare no-edge own-regex, explicit self-edge, I/E, constant-return, final-statement, and traced
    controls. Keep rule entry distinct from mode-driven matching. Do not label Julia wrong or impose a blanket
    own-regex prohibition from the existing Perl failure; ask the director if normative intent remains unresolved.
    Define the required handler/return cases and bounded implementation children before changing behavior.
  Verification: `pending` — the existing lifecycle drift card records the debt; `.31` reverified it. Julia .1.7 adds the no-edge Child:AND E-only case: generated source has no authored E write/return; exact reference controls live in docs/knowledge/julia-recognition-effect-integration-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.27.2`
  Status: `pending`
  Goal: Preserve the lifecycle handlers and final values required by the resolved contract.
  Dependencies: `.27.1`.
  Acceptance: Correct the demonstrated handler omission/return path while preserving rule-entry invariants,
    authored edge order, explicit returns, repetitions, and typed diagnostics. Include direct-dependent
    emitter/SpecEntry and runtime regression proof; split further if the reviewed repair exceeds a safe slice.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.27.3`
  Status: `pending`
  Goal: Close supported lifecycle carriers and make the book's lifecycle claims exact.
  Acceptance: Recompose native, generated/loaded, and trace examples on the required backends; reconcile
    action-and-lifecycle-placement, trace API, helper-catalog final-statement claims, and the existing Knowledge
    caveat. Preserve dated evidence and remove a current caveat only when its actual cases pass.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28`
  Status: `pending`
  Goal: Correct demonstrated public teaching drift and cover the real claims in the relevant checkers.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.28.1`, `.28.2`, `.28.3`, `.28.4`, `.28.5`, `.28.6`, `.28.7`

- ID: `SESSION-STARTUP-READING.28.1`
  Status: `pending`
  Goal: Remove stale logical truthiness/rollout teaching and reject its actual bad paragraphs.
  Acceptance: Align governed current prose with the admitted truth table, including string zero and empty
    aggregates. Add actual-document and wrapped-claim mutations, preserve legitimate historical evidence,
    and reconcile the dated drift card. Keep the already-correct runtime contract unchanged.
  Verification: `pending` — fresh native truth controls pass while the public checker accepts contradictory prose.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.2`
  Status: `pending`
  Goal: Remove the stale remaining-backends hash-selector claim and cover it in mutation public checks.
  Acceptance: Correct the measured paragraph and equivalent current wording; add its actual text and controlled
    variants to the bounded public audit. Preserve all admitted mutation semantics and historical records.
    The checker already normalizes whitespace; fix its missing semantic denial rather than inventing that bug.
  Verification: `pending` — the 63-file public checker passes the observed false remaining-backends claim.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.3`
  Status: `pending`
  Goal: Teach current portable parse_job authoring in the introduction and include that surface in checking.
  Acceptance: Replace the false future/unavailable introduction with the admitted assignment-annotation form.
    Cover reachable public teaching and actual bad-paragraph mutations while retaining reserved import/provider
    and no-outward-authority boundaries. Do not promote parse_job to an arbitrary generic helper.
  Verification: `pending` — the current introduction is absent from the staged public-authoring reader set.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.4`
  Status: `pending`
  Goal: Qualify obsolete semantic rollout/admission counts and check the actual current fields.
  Acceptance: Replace or explicitly date the false current 3/9 and 2/6 sentence against canonical 9/9 and 6/6.
    Cover actual and wrapped wrong-value mutations while preserving historical evidence and all query/MCP
    semantics. Apply the reviewed field-ownership policy rather than guessing that every number is a live count.
  Verification: `pending` — the page is included, but the real public checker returns no error for that sentence.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.5`
  Status: `pending`
  Goal: Correct definedness return-context and cat null-fragment teaching in the helper catalog.
  Acceptance: Replace condition-only claims with precisely supported expression contexts and executable true/
    false examples. Verify return representation before promising portable encoding. Teach cat's null and
    wrong-kind boundary beside the empty-string control; add bounded public regression coverage.
    Preserve current scope/arity and scalar-to-text contracts; no runtime defect is established by these probes.
  Verification: `pending` — returned/nested definedness works; cat with null returns null, not concatenated text.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.6`
  Status: `pending`
  Goal: Replace the host-process termination claim with the actual typed exit_now control contract.
  Acceptance: Show native/generated typed parse unwinding and caller handling at each supported API boundary.
    Cover the actual false process-exit paragraph and controlled variants in diagnostic public checks;
    preserve immediate parse termination, event ordering, host continuation, and exception identity.
  Verification: `pending` — Perl throws RuntimeExitNow and the host continues; the current public checker passes.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.7`
  Status: `pending`
  Goal: Restore precise public aggregate-selector checking for documented negative examples and the actual reference census.
  Dependencies: `.3`/`.4`/`.5`; retain `.28.2` as the distinct false-current-prose repair.
  Children: `.28.7.1`, `.28.7.2`
  Evidence: Lua reading .1.8 confirms the production checker fails unchanged f80a2bde inputs: 62 public files, 35 exact references against expected32, and one unclassified fenced Julia invalid example at project-status.md:857. All public bytes match that HEAD or its rgx gitlink; no source repair is made. See docs/knowledge/lua-interpreter-helper-reading-and-false-delimiter-gap.md.

- ID: `SESSION-STARTUP-READING.28.7.1`
  Status: `pending`
  Goal: Reconcile every current selector reference and teach/check negative example context without weakening authoring rejection.
  Acceptance: Audit all 35 observed references and any subsequent delta, distinguish rejected examples from positive authoring, and repair the bounded context/census contract with explicit evidence. Preserve the Julia callable-body defect example and its repair owner; do not delete evidence or merely raise a counter. Keep executable selector rejection, migration contrasts and source scanner behavior intact.
  Verification: `pending` — sentence_at stops at blank lines around the fenced example; a second baseline census mismatch would remain after only correcting its context.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.7.2`
  Status: `pending`
  Goal: Independently verify public selector examples, census and rejection behavior after the bounded repair.
  Dependencies: `.28.7.1`.
  Acceptance: Exercise actual fenced and inline historical/rejected examples, blank-line/wrapped context variants, added/removed reference census mutations and genuine positive authoring mutations. Run the unmodified production check, its direct dependents and canonical admission at the appropriate boundary; synchronize current book/Knowledge claims while retaining dated failed evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.29`
  Status: `pending`
  Goal: Align diagnostic-evidence path coverage with the actual polyglot source and verification surfaces.
  Dependencies: Complete `.3`/`.4` and review adoption scope under `.5`; execute before `.5` adoption closeout.
  Acceptance: Inventory actual governed source/test/contract paths and explicit exclusions; include the omitted
    Dart, Julia, Lua, and tests controls. Add a deterministic path matrix and controlled staged-path RED/GREEN
    proof. Keep documentation-only scope proportional; the evidence gate must not execute recorded Markdown commands.
    Integrate the fix with the reviewed CLAIM verification adoption and required infrastructure proof.
  Verification: `pending` — the actual gate predicate accepts Perl/Rust/t/tools twins but excludes four recorded peers.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.30`
  Status: `pending`
  Goal: Correct the grouped-edge book example's unproduced child return value.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Teach a valid shared matched-text block or explicit per-edge child calls with complete examples
    for both alternatives. Preserve authored action-block dispatch semantics; do not invent implicit child
    execution or a dynamic-callee API to rescue the prose. Add appropriate example regression coverage,
    reconcile the existing edge ownership fact, and render the corrected book.
  Verification: `pending` — both alternatives return null text in the book form; explicit calls and match_text controls pass.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.31`
  Status: `done`
  Goal: Persist read-only forward reading, confirmed findings, and repair ownership from the canonical wait.
  Scope: Startup task ownership and evidence, Knowledge retrieval, bounded continuity, and supplied-policy provenance.
  Acceptance: Create exact owners `.17`–`.30` before any remediation; preserve reproduced outcomes, source
    mechanisms, existing-debt links, full/partial reading ranges, and explicit unprobed boundaries.
    Record earlier read-only preparation without marking pending per-leaf checkpoint commits complete.
    Preserve the preceding exact canonical result and route back to `.3.2.22`. No implementation or public-book edits.
  Verification tier: `focused`
  Focused checks: Recorded Toolbox/native controls and source locations; baseline/current identity and interval
    audits; existing Knowledge reconciliation; memory/doctrine/Knowledge/history checks; final scope/diff review.
  Canonical trigger: `none` — startup tracking only; policy, runtime, public, and infrastructure repairs remain separately owned.
  Verification: Recorded Toolbox/native controls, exact source locations, disjoint reading audits, donor
    comparisons, and preceding canonical completion are preserved below. Fourteen Knowledge cards plus the
    existing lifecycle owner distinguish confirmed gaps, unprobed boundaries, and the JSON display artifact.
    All nine doctrines, Knowledge synchronization, memory, both history limits, and staged scope/diff pass.
    Queued checkpoint statuses stay pending; pre-commit rechecks the final candidate.
  Commit: `SESSION-STARTUP-READING.31 - preserve forward reading and own confirmed repairs` — Forward coverage and confirmed findings durably owned; prior canonical success; queued checkpoints remain pending.

- ID: `SESSION-STARTUP-READING.32`
  Status: `pending`
  Goal: Preserve caller-context argument evaluation before any user-function local declaration becomes visible.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reproduce the scalar local-name collision through Get and emitted source, with literal and
    distinct-name controls; cover aggregate inputs, parameter names, nested calls, rest arguments, and eager
    evaluation order. Separate caller argument evaluation from body-local binding without exposing compiler
    temporary collisions. Add focused RED/GREEN runtime/generated-source proof and direct-dependent callable
    coverage; reconcile the function-execution Knowledge and public contract with the verified implementation.
    Measure other backends before claiming cross-runtime impact or parity.
  Verification: `pending` — Get returns null for `f(temp)` when the body declares local `temp`; literal and
    distinct-name controls return outer. Dumped Perl declares `my $temp` before the argument temporary.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.33`
  Status: `pending`
  Goal: Reconcile tagged-record argument evaluation and split behavior with the public contract and runtime evidence.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.33.1`, `.33.2`

- ID: `SESSION-STARTUP-READING.33.1`
  Status: `pending`
  Goal: Bound tagged-record divergence across native/generated runtimes and determine the authoritative contract.
  Acceptance: Replay the exact Perl Get/source controls across all six runtimes. Cover source/delimiter/tag/
    carried-field evaluation count and order, empty/trailing/consecutive items, literal/regex delimiters,
    variable delimiters, scalar receivers, and nested carried-value independence. Reconcile book once-only
    teaching, Lua implementation evidence, Perl-reference policy, and existing corpus expectations before repair.
    Explicitly include empty literal and zero-width regex delimiters, distinguishing leading/trailing empty
    items from empty-source behavior and pure helper results from tagged-record construction.
    Assign separate implementation leaves if the coordinated correction exceeds one safe slice.
  Verification: `pending` — Perl carried field increments twice for a,b, and zero times for empty input;
    tagged splitting drops the trailing empty item retained by ordinary split. See `.3.2.28` evidence.
    `.3.3.15` adds seven paired current Rust/Perl pure-split controls: five empty-source/empty-delimiter
    differences and two equal ordinary controls. Rust adds initial empty fields for empty literal/regex
    delimiters and differs on empty sources; all fourteen compared commands exit zero without stderr.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.33.2`
  Status: `pending`
  Goal: Implement the reviewed tagged-record and pure-split contract and prevent recurrence in runtime and public examples.
  Dependencies: `.33.1`.
  Acceptance: Add independently justified failing controls, correct affected lowerers/interpreters, and cover
    direct/generated/helper/receiver forms without silently re-blessing oracle data. Include the measured
    Rust/Perl empty-source, empty literal/regex delimiter, Unicode and ordinary control pairs from .3.3.15.
    Preserve non-scope source
    argument ownership and exact record shape. Synchronize the helper reference and Knowledge, add real public
    claim coverage, and run focused direct-dependent plus required cross-runtime admission proof.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.34`
  Status: `pending`
  Goal: Preserve executable statements across line comments and every supported newline spelling.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.34.1`, `.34.2`

- ID: `SESSION-STARTUP-READING.34.1`
  Status: `pending`
  Goal: Insert generated statement terminators outside inline comments.
  Acceptance: Reproduce LF/CRLF assignment-comment-return failure through public Get, ActionIR diagnostics,
    and emitted source; compare no-comment, explicit-semicolon, comment-only, quoted-hash, and nested cases.
    Preserve lexical ownership and source locations when choosing the generated separator position; an inserted
    semicolon must not become comment text. Cover live and generated routes, update separator teaching and
    Knowledge with exact behavior, and run focused direct-dependent proof before required public signoff.
    Measure other backends before claiming cross-runtime impact; keep the oracle correction independently justified.
  Verification: `pending` — generated $name = "ok" # note; followed by return fails handler compilation for LF/CRLF.
    Public Get returns a wrapper but invocation records an error and no result; see `.3.2.33` evidence.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.34.2`
  Status: `pending`
  Goal: Terminate CR-only line comments without losing the following authored statement.
  Acceptance: Reproduce the CR-only splitter and public Get loss, with LF/CRLF and explicit-separator controls.
    Correct comment state and generated-host newline handling together; changing only the splitter must not
    leave Perl treating the following statement as comment text. Preserve decoded source locations, quoted/
    regex payloads, EOF comments, and nested/comment-only forms. Add live/generated and direct splitter
    regressions, reconcile all universal-newline claims, render the book, and verify relevant runtime parity.
    Coordinate with `.34.1` without combining independently reviewable repairs.
  Verification: `pending` — Mode clears line-comment state only on LF; CR keeps return in the same statement
    and generated host comment. Public invocation returns no result with no context error.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.35`
  Status: `pending`
  Goal: Preserve typed boolean literals during dynamic Perl codeblock evaluation.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reproduce public direct versus dynamic true/false results and inspect the typed AST and
    CodeblockRuntime boolean branch. Preserve JSON boolean identity for returned, assigned, nested-container,
    fixed/rest-argument, and contextual-final-block literals without changing numeric 0/1 or string values.
    Add independently justified neutral and focused live/generated regression evidence; measure other runtimes
    before claiming parity. Reconcile primitive-literal/codeblock teaching and Knowledge, render the book, and
    run direct-dependent callable/logical/value checks plus required public signoff. Keep `.19` receiver-guard
    repair separate; neither defect is closed by the existing callable suite passing.
  Verification: `pending` — `.3.2.34` public controls return true/false directly but 1/0 through cb() literals;
    a true argument stays typed while a dynamic literal array returns [1,0], all without context errors.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.36`
  Status: `pending`
  Goal: Reconcile MCP validation-error precedence with its accepted ordering and executable proof.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.36.1`, `.36.2`, `.36.3`

- ID: `SESSION-STARTUP-READING.36.1`
  Status: `pending`
  Goal: Audit competing MCP validation failures against the current normative order.
  Acceptance: Use ADR 0055 section 6, later decisions, neutral artifacts, and public decoded/stdio controls.
    Cover invalid envelope/id, special initialize, missing/malformed metadata, unsupported version, unknown
    method, and invalid tool arguments in combinations. Measure all six runtimes; preserve independent expected
    outcomes and identify exact source branches and missing fixture coverage before changing an oracle.
    Ask for direction only if current normative authorities cannot resolve an actual conflict.
  Verification: `pending` — `.3.2.38` proves Perl checks unknown methods and unsupported version before full
    metadata validation; six cases agree across decoded and stdio routes despite the documented earlier metadata step.
    .3.3.25 also reads the same method/version-before-full-schema branches in Rust mcp_server.rs;
    ADR 0058 still references ADR 0055 ordering. No fresh six-case Rust execution is claimed.
  Reading update: Julia .1.10 adds six exact decoded/stdio controls (12 assertions), matching the recorded Perl sequence while preserving separate pattern-repair ownership. Replay and source mechanism are in docs/knowledge/perl-mcp-validation-error-order-drift.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.36.2`
  Status: `pending`
  Goal: Repair affected MCP dispatch paths with independently justified precedence regressions.
  Dependencies: `.36.1`.
  Acceptance: Decompose affected implementations into bounded owned repair leaves before editing them.
    Preserve the special legacy diagnostic, validated-id handling, silent notifications, error sanitation,
    prepared cancellation/flush cleanup, and native semantic authority. Add mixed-failure neutral and public
    decoded/stdio regressions; run focused direct-dependent proof plus canonical verification for contract changes.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.36.3`
  Status: `pending`
  Goal: Close MCP validation-order documentation and recurring proof without drift.
  Dependencies: `.36.2`.
  Acceptance: Reconcile the accepted decision, current book/examples, Knowledge, and exact neutral/runtime
    error-order behavior; render the book and run required six-runtime/contract/canonical proof. Qualify
    historical evidence honestly and close `.36` only after every owned repair and claim agrees.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.37`
  Status: `pending`
  Goal: Enforce progressive child resource and diagnostic ceilings with independent cross-runtime proof.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.37.1`, `.37.2`, `.37.3`

- ID: `SESSION-STARTUP-READING.37.1`
  Status: `pending`
  Goal: Repair progressive effective step and detached-result resource enforcement.
  Acceptance: Reconcile ADR 0080 and the neutral ceiling contract, then census all six runtimes with exact
    boundary controls. Perl currently accepts cost 2 with effective max_steps 1 and returns [1,2,3] with
    max_result_nodes 1. Decompose affected runtime/neutral repairs before editing; independently justify node
    accounting and nested budget inheritance, preserve shared cancellation/deadline/call/depth authority, and
    add adversarial regressions beyond effective-metadata equality. Run required canonical contract proof.
  Verification: `pending` — `.3.2.39` reproduces both cases through the existing Perl private authority;
    the combined authority/carrier suite passes 138 tests and does not establish these enforced boundaries.
  Reading update: Dart .1.15 adds ten private-authority controls in docs/knowledge/dart-progressive-nested-authority-gap.md. Direct cost/result bounds reject, but a nested call runs after the parent callback reports zero remaining steps; widened caller inputs regain extra capability and max_steps/result_nodes 100. Own inherited effective grants and per-child remaining budget, with independent cross-runtime expectations and bounded repair children before implementation.
  Julia reading update: Julia .1.12 adds30 nested and14 direct-limit assertions: direct cost/result caps reject, but nested dispatch runs with parent remaining_steps zero and widened inputs regain extra capability plus100 step/result ceilings. Exact mechanism and replay: docs/knowledge/julia-progressive-authority-boundary-gaps.md; existing .37.1 owns repair decomposition.
  Lua reading update: Lua .1.5 compares unchanged one-step/two-step callback limits on PUC5.5.1 and LuaJIT. A nested callback runs at parent remaining_steps zero; the one-step-left control succeeds and both shared counters charge correctly. dispatch_nested forwards the shared invocation without the parent remaining snapshot. Exact replay and source locations: docs/knowledge/lua-authority-compiled-reading-and-nested-step-gap.md. Existing cross-runtime repair decomposition remains pending.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.37.2`
  Status: `pending`
  Goal: Repair progressive child diagnostic size and source-detail containment.
  Acceptance: Audit exact current authority for callback input visibility versus outward diagnostics and
    define independently justified expectations. Perl preserves a 57-byte child diagnostic, including caller
    source text, with effective max_diagnostic_bytes 8 and source_detail none. Census all six runtimes;
    decompose affected repairs and add bounded UTF-8/source-safe failure regressions. Preserve typed error
    context and view/chain cleanup. Do not silently rewrite the neutral promise to match current behavior.
  Verification: `pending` — `.3.2.39` roots the unbounded raw child-error copy in dispatch and records the
    separate callback-view observation without assuming it alone establishes an exposure defect.
  Reading update: Dart .1.15 confirms the eight-byte diagnostic limit while a raw callback failure retains source prefix owned-pr at detail none. The callback can read its supplied input. Preserve these separate observations and resolve input-versus-outward detail authority; no exposure conclusion is inferred from input access alone. Exact ten-case replay is in docs/knowledge/dart-progressive-nested-authority-gap.md.
  Julia reading update: Julia .1.12 confirms the eight-byte diagnostic cap and supplied-input visibility. Throwing a source string renders with an opening quote before truncation; the exact retained prefix is a quote plus owned-p. Preserve source-detail interpretation as pending; replay is in docs/knowledge/julia-progressive-authority-boundary-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.37.3`
  Status: `pending`
  Goal: Close progressive ceiling documentation and recurring proof after all owned repairs.
  Dependencies: `.37.1`/`.37.2`.
  Acceptance: Reconcile the decision, book, neutral artifact/checker, runtime consumers, and Knowledge
    against actual enforced limits; render the book and run required six-runtime and canonical proof.
    Qualify historical admission evidence and close `.37` only after the boundaries agree.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.38`
  Status: `pending`
  Goal: Prevent invalidated recognition tokens from restoring obsolete snapshots.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.38.1`, `.38.2`

- ID: `SESSION-STARTUP-READING.38.1`
  Status: `pending`
  Goal: Repair post-terminal transaction misuse without changing already committed or later frame state.
  Acceptance: Preserve restore-before-report for live token misuse and permanent invalidation after commit/
    rollback. Audit every token operation and source/invocation/generation path, plus all six runtimes; decompose
    affected repairs before editing. Perl currently restores an obsolete snapshot when a committed or rolled-back
    token is reused from another frame/source. Add independent controls that first advance the owner after
    terminal invalidation, assert exact cursor/boundary/mark preservation on rejection, and preserve diagnostic
    precedence under the accepted contract. Check authored/carrier reachability separately from private-host misuse.
  Verification: `pending` — `.3.2.40` reproduces six private-authority controls: both same-frame cases retain
    current state, while four cross-frame/source cases restore cursor/boundary/marks to the old checkpoint.
    .3.3.27 Rust source comparison finds an early invalidated-status return before snapshot restoration;
    this excludes the exact Perl mechanism in that helper, not the pending behavioral/runtime census.
    Julia .1.19 reads RecognitionTransaction633-648: _restore_and_invalidate! returns immediately for invalidated tokens before changing frame/gap snapshots, likewise excluding the exact Perl helper mechanism. This source comparison does not close the separate all-runtime behavioral or authored/carrier census.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.38.2`
  Status: `pending`
  Goal: Close transaction invalidation claims and recurring proof after the repair.
  Dependencies: `.38.1`.
  Acceptance: Reconcile neutral fixtures, all affected runtime consumers, book/Knowledge, and task history;
    qualify finite historical evidence without claiming an authored token escape from a private API probe.
    Run required six-runtime/canonical proof and render the book before closing `.38`.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.39`
  Status: `pending`
  Goal: Preserve the semantic boolean kind through recognition commit.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reconcile the neutral staged-payload contract and typed primitive authority; census all six
    runtimes and supported carriers with true/false versus numeric one/zero. Perl finish_commit currently
    converts JSON::PP booleans to native numbers. Decompose affected repairs before editing; add type-sensitive
    independent regressions and correct consumer expectations without weakening falsey acceptance. Reconcile
    the book/Knowledge and run required six-runtime/canonical proof. Keep the dynamic-codeblock defect .35 distinct.
  Verification: `pending` — `.3.2.41` runs eight public Get controls: direct true/false serialize as booleans,
    transaction true/false as 1/0; numeric controls agree and every context reports zero errors.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.40`
  Status: `pending`
  Goal: Restore actual parser state when a live recognition transaction unwinds.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.40.1`, `.40.2`

- ID: `SESSION-STARTUP-READING.40.1`
  Status: `pending`
  Goal: Repair recognition guard unwind synchronization while preserving the original control error.
  Acceptance: Trace private snapshot restoration through actual cursor/boundary/mark/gap state on every abort
    and missing-terminal path. Public exit_now(7) after a successful attempt leaves Perl input at cursor two,
    although the checkpoint was zero; explicit rollback before exit restores zero. Audit all six runtimes,
    decompose affected repairs, and add exact state plus exception-identity regressions. Preserve committed
    state, falsey payloads, recursive mark isolation, and existing gap transaction semantics.
  Verification: `pending` — `.3.2.41` reproduces four public exit controls with exact status seven and no
    runtime-context errors. _finish_guard restores the private authority during leave but does not apply the
    restored snapshot to actual parser registers before discarding the context.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.40.2`
  Status: `pending`
  Goal: Close recognition unwind documentation and recurring proof after repair.
  Dependencies: `.40.1`.
  Acceptance: Reconcile neutral/runtime tests, diagnostic control-error behavior, book/Knowledge, and tracked
    claims against actual parser state; render the book and run required six-runtime/canonical proof.
    Preserve the separate post-terminal obsolete-snapshot defect under .38.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41`
  Status: `pending`
  Goal: Reconcile the completely read mdBook with current executable contracts and prevent the measured claim gaps.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.41.1`, `.41.2`, `.41.3`, `.41.4`, `.41.5`, `.41.6`, `.41.7`, `.41.8`, `.41.9`
  Acceptance: Preserve dated historical evidence while correcting claims presented as current. Every child
    owns bounded authoring and executable claim checks; split implementation before editing if it exceeds
    one safe slice. Coordinate existing .28/.29/.30 and runtime repair owners without double-closing them.

- ID: `SESSION-STARTUP-READING.41.1`
  Status: `pending`
  Goal: Correct staged parse-job authoring, recursive dispatch, and provider-boundary teaching.
  Acceptance: Reconcile design rationale, pipeline overview, EBNF walkthrough, and backend handoff with
    the current assignment-only parse_job contract and all-six-runtime admission. Qualify the historical
    function-body-v1 limitations; preserve current prohibition of ambient loading/provider lookup and the
    separate unimplemented import model. Coordinate .28.3's introduction repair. Exercise the actual
    contradictory paragraphs and all affected chapter paths through meaningful public-checker mutations;
    exact markers alone must not certify surrounding false current prose. Render and run required public proof.
  Verification: `pending` — .3.2.42 records fully read pages and passing neutral/public controls despite
    explicit current unsupported/future claims; fixed path sets and exact denials explain the gap.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.2`
  Status: `pending`
  Goal: Align cursor dispatch, generated routes, and named capture-selector status.
  Acceptance: Reconcile regex/blind-call/generated-handler guides and formal/runtime/backend appendices
    against current rule-local cursor-v2 and admitted named gap capture. Distinguish authored mode policy,
    dispatch-edge matching, public entry, and direct handler execution; remove only false current migration
    claims. Cover affected pages beyond the existing regex link markers and omitted guides. Coordinate .30
    grouped-edge and .27 lifecycle semantics; add independently justified examples, recurrence checks, and render.
    Reconcile rust/README.md subset wording with the unconditional 105-fixture generated classifier,
    retaining its distinction from default canonical execution. Correct ast.rs comments claiming Default
    equals OR+ and Single (&) is choice: rep_min gives 0 versus 1 and is_and includes Single. Preserve
    runtime policy, verify neutral authority, and cover source comments as well as the book prose.
    Correct compiler.rs documentation saying self-recursive edges duplicate parent regexes: the current
    branch and inline tests reuse their existing slots. Qualify its warning/skip commentary against the
    later compiled-slot validator, which rejects missing or out-of-range action targets. Keep standalone
    helper behavior distinct from the complete compilation pipeline; do not change runtime semantics here.
    Correct validation.rs module documentation's obsolete numbered pass reference (check 5 is no longer
    edge-target validation) and incomplete pass inventory against ordinary/traced order; retain strict
    unused-rule behavior and the deliberate default undefined-reference boundary.
    Qualify the ProgressiveDispatchArguments comment in bounded_child_parse_authority.rs that still
    describes a time before static carriers existed; the current host-argument role composes with
    admitted carriers owned by their separate syntax, engine, and generated-source modules.
    Correct engine.rs entry/local-match comments that still describe a rule testing its own regex;
    current selection is over outgoing dispatch patterns, with entry alone independent of that match.
    Include engine test comments claiming top-rule entry and local matches always coincide (chars_5_3_
    entry-start and helpers_5_5_1_match_named); fixture-specific assertions do not establish that identity.
    Preserve the actual first-selected-match fallback and caller match-state restoration boundaries.
    Reconcile runtime lib.rs module prose claiming no code generation with its current source_emitter API;
    preserve the distinction between interpreted host execution and emitted standalone Rust modules.
    Correct engine.rs target-resolver comments at 7892 and rule-label argument comments at 8002 against
    current uniform bare-value reads; these comments must not describe future or always-undef behavior.
    Qualify semantic_index.rs comments that call source-detail queries future work or assign source
    filtering/query to later leaves; the same file now exposes capabilities/query/observation derivation.
    Julia .1.1 additionally identifies julia/README.md lines 474–475 claiming root topology awaits .4.3 despite its admitted top summary. Qualify this current-tense residue with the original milestones intact.
  Verification: `pending` — current guides still describe Julia/Lua v1 adapters and future named selectors;
    the cursor contract's current reader/marker coverage does not enforce those paragraphs.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.3`
  Status: `pending`
  Goal: Reconcile semantic API and MCP backend status across descriptor and handoff teaching.
  Acceptance: Replace descriptor-reference future-native-API claims and qualify historical handoff ledger
    snapshots against current all-six semantic/MCP admission. Coordinate .28.4, .36, and semantic repairs .22/.23/.43; do not imply that
    passing admission closes separately owned call projection or error-order defects. Test actual stale
    paragraphs and current backend status claims, retain dated milestones, and render the book.
    Qualify the Rust .10.4.5 twentieth-response claim in public-api/semantic-introspection.md lines
    1354–1357 against exact consumer evidence: eight routes compare typed events; direct derivation
    checks the query digest; independent emitted compilation checks only value/count/positions/first-last
    kinds. Preserve the canonical expected digest without claiming an unexecuted full emitted query.
    Evidence: docs/knowledge/rust-semantic-runtime-observation.md, startup .3.3.61.
    Also distinguish the composed admission consumer's two emitted-labelled helper routes from independent
    compiled modules; its traced wrappers disable text tracing. Evidence: rust-semantic-introspection-admission Knowledge, .3.3.62.
    Julia .1.1 adds julia/README.md lines 169–207, 243–250 and 311–338: separate historical query/runtime/emitted-boundary snapshots from current complete APIs. Seven exact README examples pass while the finite marker/denial checker accepts those surrounding statements. See julia-package-readme-reading Knowledge.
  Verification: `pending` — descriptor reference lines 96–99 contradict current semantic admission while
    existing public marker/denial checks pass; full handoff reading finds mixed historical/current wording.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.4`
  Status: `pending`
  Goal: Reconcile gap-capture and typed-source current status without erasing historical measurements.
  Acceptance: Correct descriptor-reference Dart pending and diagnostics Lua dormant claims; reconcile
    capture guide current gap and typed-source counts with canonical owners. Keep the public typed-span
    API exclusion and genuinely historical counts explicit. Extend the gap public inventory beyond its
    omitted descriptor/diagnostic chapters and test the observed false-current claims. Run focused neutral
    plus required public proof, render, and coordinate current typed/gap repair owners.
  Verification: `pending` — current gap 9 complete/0 pending and typed 14 complete/0 pending coexist
    with stale current paragraphs; the exact eight-document gap reader omits two affected chapters.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.5`
  Status: `pending`
  Goal: Correct compiler mode, document-input, and leading-trivia API boundaries.
  Dependencies: `.42` for final combined-option contract claims.
  Acceptance: Teach parse_only as an undef stop before compiled-state generation and generate_only as
    source parsing/validation plus generation ending in undef; document source capture separately.
    Distinguish specification-envelope validation from document input. Public entry skips leading trivia
    once; direct descriptor handlers bypass that wrapper. Preserve four input/direct controls and the
    nine-case option/invalid-source matrix, add copyable examples, cover the actual false prose, and render.
    Reverify the separate dual-bootstrap-equivalence claim before changing its scope.
  Verification: `pending` — public empty and ordinary non-spec document input succeed; leading
    blank/comment input starts at cursor 8 publicly and 0 directly. Compiler/API prose conflates those
    boundaries; .42 owns the independent combined-mode false diagnostic.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.6`
  Status: `pending`
  Goal: Resolve remaining lifecycle, helper, authoring, and representation assertions with exact controls.
  Acceptance: Assess the contradictory E/EX/LX ordering tables against family-specific emitted behavior;
    coordinate .27 rather than infer a single global order. Check bare push dispatch, mutation-result
    expressions, num_mod noninteger behavior, zero-progress thresholds, inline comments, fluent child-value
    examples, entry-versus-match captures, and tablegrep precedence statements against existing Knowledge
    and public tools. Check HandlerIR host-code versus language-neutral guidance against adopted decisions.
    These are assessment candidates, not newly established runtime defects. Also correct the confirmed
    stale TOOLBOX section 1 instruction that current Perl must reject bare rule-item blocks: .3.2.42
    public twins and the current standalone contract prove acceptance. Its 15-document reader omits
    TOOLBOX; cover the actual false guidance and controlled variants with the repair. Root any surprise,
    create a bounded repair child before changes, and close each candidate with evidence, public examples, and render.
    Reconcile expr.rs test name parse_shape_literal_rhs_keeps_scalar_assignment_ast_until_target_inference_leaf
    with completed duck-typed assignment and later uniform-binding retirement; retain its AST assertions while
    removing the misleading pending target-inference implication. This is naming debt, not a failed AST check.
    Conformance .1.1 confirms capability_conformance/README.md lines347-348 still calls generic callable-codeblock future, with similar “until” first-class-literal wording at741-742, although current five-backend admission removes that exclusion. The unchanged callable checker passes while checking other required markers and exact denials. Qualify the historical final-codeblock-v3 admission boundary without presenting generic callables as currently future, and test this actual paragraph plus controlled variants; conformance-capability-guide-reading owns exact evidence.
  Verification: `pending` — full-book reading identifies the listed assessment candidates. The additional
    TOOLBOX guidance defect is confirmed at .3.2.44: standalone neutral proof passes 15 documents /
    seven denials / fourteen mutations while omitting that file. No unmeasured runtime failure is claimed.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.7`
  Status: `pending`
  Goal: Align public development commands and verification cadence with adopted workflow and locality.
  Acceptance: Coordinate .29 and policy adoption .5 for actual gate-family/default decisions. Correct
    full-CI-per-behavior-change wording to ADR 0073's focused default and canonical boundaries. Ensure
    every copyable project command runs from the repository root with managed data routing; review direct
    Julia/Dart/Cargo examples and retain documented toolchain dependencies. Make existing task ownership
    explicit for small doc fixes. Replace moving capacity/capability-count duplication with canonical
    pointers or qualified dated evidence; cover actual workflow claims and render without inventing policy.
    Integration .8.5 corrects the Rust README requirement using RGX's published Rust1.95 contract and
    converts its Building block to managed root commands. Native consumer/canonical proof uses1.95.0
    on macOS arm64; no earlier compiler or broader platform floor is established. Retain other command
    and verification-cadence repairs here, and recheck the public contract for future releases. Qualify the
    stale 63-case CLI claim against the 66-case authority and replace direct Cargo examples with root-managed commands.
    Replace TOOLBOX section 4.10's two current 68-mutation claims with the canonical MCP transport
    authority or dated evidence: the unchanged September 7 canonical checker reports 76. Preserve
    genuinely historical 68-count milestones and do not infer an optional matrix rerun from that check.
    Julia .1.1 adds exact bare corpus commands in julia/README.md lines 515 and 963; route them through tools/run_julia_project_data.sh. No unmanaged execution or off-volume write was performed or inferred by this reading. Preserve dated counts while repairing copyable current guidance.
    Julia .1.2 completes README reading and adds the same bare-command defect at lines 964–965; both managed help paths pass. See julia-facade-action-model-reading Knowledge.
    Conformance .1.1 adds capability_conformance/README.md lines330-336: current17/85 contradicts the same guide and exact20/100 manifest; its24 semantic-mutation claim contradicts the current19 exclusion mutations. The same prefix also says current72 cursor migration files versus actual74, repeated-action44 mutations versus54, and logical20 documents/13 denials versus19/14; retain explicitly historical milestones while correcting these present-tense mismatches. The unchanged capability checker passes both paragraphs because public validation checks selected markers/denials only. Correct or explicitly date these actual claims and add meaningful recurrence; exact evidence belongs to conformance-capability-guide-reading.
    Conformance .1.2 finishes the guide and adds lines803-804 current-seventeenth wording and896-897 current80/0/0 wording to the same count repair and actual-paragraph recurrence. Preserve the explicitly dated16/80 callable-admission milestone. Reconcile the named-mark paragraph with its different-rule-label fixture and distinguish generated-plan execution from independently compiled emitted source using complete-named-mark-perl-rust-parity; do not infer a fresh runtime failure.
  Verification: `pending` — local-CI prose says full gate for every behavior change and default toolchain
    independence; current canonical gate runs mandatory backend admissions and reports 20 capabilities/100 states.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.8`
  Status: `pending`
  Goal: Close whole-book alignment and recurrence after the bounded repairs.
  Dependencies: `.41.1`–`.41.7`; related `.28`/`.30` repairs.
  Acceptance: Reconcile all 50 baseline book paths and intervening changes with code, roadmap, task owners,
    decisions, examples, and actual checker coverage. Preserve historical counts as dated observations.
    Render and inspect the book, run exact public/cross-runtime and canonical proof, and close .41 only
    when every child and every confirmed public claim defect has its completed repair evidence.
  Verification: `pending`
  Commit: `pending`
  Additional dependency (Julia .1.34): .41.9 owns the measured mdBook search-index warning; whole-book closure includes its bounded repair and search-usability proof.

- ID: `SESSION-STARTUP-READING.41.9`
  Status: `pending`
  Goal: Resolve measured mdBook search-index growth while preserving useful public search and complete documentation.
  Dependencies: `.3`/`.4`/`.5`; coordinate .41.8 and existing document-containment owners.
  Evidence: Julia .1.34 book build succeeds but warns at10001369 decoded search bytes;913 section records,7830230 inverted-index bytes and2109423 document-store bytes. Largest bodies include Project Status Ongoing91038 and Documentation pressure containment76931 bytes. No search latency or functional failure is yet measured.
  Acceptance: Establish representative query correctness, payload/transfer and browser parse/search measurements using repository-local artifacts. Decompose before implementation if needed; select a bounded content/search strategy that preserves navigable historical evidence and current teaching. Verify relevant queries and rendered links, document before/after measurements and recurrence ownership, and run the warranted canonical boundary for any public/configuration/mechanical change. Do not merely suppress the warning or infer a speedup from bytes alone.
  Knowledge: docs/knowledge/julia-contract-consumer-reading.md contains dated measurement and replay.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.42`
  Status: `pending`
  Goal: Preserve successful mode-only compilation when return_descriptor is also requested.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reconcile existing compiler option precedence with facade and factory validation. Cover all
    eight parse_only/generate_only/return_descriptor combinations through public Get and get_parser, exact
    source capture, and preservation of genuine compile failures. The compiler's successful undef stop
    must not acquire runtime_owner or parser_factory failure merely because descriptor output is also
    requested. Preserve malformed defined-result rejection and trace classification. Add independently
    justified failing regressions, repair both validators, update API/book/Knowledge under .41.5, and run
    focused direct-dependent plus required public proof. Ask only if a newer normative authority actually
    conflicts with the established option contract.
  Verification: `pending` — the nine-case public Get control finds false runtime_owner/run_get_pipeline
    errors for all three descriptor-plus-mode combinations; the five other combinations and invalid-source
    attribution behave as recorded. Runtime's descriptor-first predicate was introduced by 86d6511c7,
    while Compiler checks parse_only, then generate_only, then return_descriptor. ParserFactory has the
    same descriptor-first result check: eight isolated callback controls independently reproduce its three
    false errors and failed trace classification. The named-source public get_parser matrix remains to be measured.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.43`
  Status: `pending`
  Goal: Preserve explicit inline lifecycle members in semantic introspection.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reproduce equivalent header-inline and following-line I blocks through public Get,
    descriptor/source tools, and semantic queries. Both execute return(7), but only the multiline form
    currently produces lifecycle:rule:Top:I:0. The scanner recognizes the header then skips its remaining
    text, leaving no member for lifecycle projection. Reconcile lifecycle/source-span authority, census
    supported inline members and all six runtimes, and decompose affected repairs before editing. Preserve
    authored member order, exact Unicode/newline/header/member spans, function masking, and multiline
    nesting; bare action blocks must not gain an invented explicit I marker. Add independent regressions,
    update semantic teaching/Knowledge, and run focused plus required public/cross-runtime proof.
  Verification: `pending` — four public controls return seven without errors and query successfully;
    explicit inline I has zero lifecycle records, explicit multiline I has one, and both bare controls have
    none. SemanticStaticProjection _scan_source 589–601 ignores _parse_header's tail before member capture.
    This is separate from .22's function-registry gate and .23's fabricated failure explanation.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.44`
  Status: `pending`
  Goal: Make recursive staged-marker identity safe across retired host-address reuse.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Preserve the distinction between a live previously processed marker and a newly allocated
    marker that could occupy its retired host address. Native ordinary/weak/pool controls currently finish
    all 24 calls without reuse; they do not demonstrate a native failure. An isolated scheduler-refaddr
    substitute that preserves every live identity and recycles only dead weak-reference slots stops after
    three calls and returns an unprocessed marker without error; retained-marker controls finish all 24.
    Audit marker identity lifetime and existing processed/lineage semantics, verify supported host behavior,
    and implement a bounded stable identity strategy with independent recycling/lifetime regressions.
    Preserve intentional same-marker handling, authored path order, failure/stitch policies, source lineage,
    resource ceilings, detached output, and fresh native/generated/reconstructed/emitted invocation state.
    Census the other backends before claiming parity; split bounded repair children before implementation.
    Update Knowledge and relevant book/recurrence evidence; do not relabel the isolated model as observed
    native allocator reuse or close the risk merely because the original fixture suite passes.
  Verification: `pending` — .3.2.46 records native controls and weak-reference lifetime proof, then the
    isolated recycling counterexample. StagedASTEnrichment 156–187 and 793–806 key durable processed/lineage
    state by refaddr after obsolete markers can be released; no installed runtime source was altered.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.45`
  Status: `pending`
  Goal: Reject malformed Rust rule code instead of accepting a warning and dropping the block.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: After prerequisite reading, split bounded parser/compiler, carrier-regression, and public alignment leaves before implementation. Make malformed lifecycle/action/blind blocks return precise
    compilation errors; retain valid block behavior and typed diagnostics. Cover all rule-code call sites
    and native/reconstructed/generated routes, census shipped malformed examples, and preserve function-body rejection. Do not broaden accepted syntax or suppress errors to obtain passing tests.
  Verification: `pending` — Eleven managed CLI controls establish five malformed rule blocks accepted with
    warning, compile:ok/invoke:ok, and null or fallback 42. Three valid controls and three rejecting
    controls pass their diagnostic assertions. compiler.rs parse_rule_code_block returns Ok(None) outside
    five governed error prefixes, and compile_rule drops that absent block. Nested-write and mutation
    argument errors also take this path.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.46`
  Status: `pending`
  Goal: Make Rust malformed-expression diagnostics safe at every UTF-8 boundary.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Replace raw byte-window slicing with a UTF-8-safe diagnostic excerpt while preserving scalar
    source positions and meaningful bounded context. Cover ASCII, multibyte boundaries, valid Unicode, and
    malformed inputs through direct core and relevant public routes. Separately resolve the earlier whole-spec ASCII timeout before claiming its cause; a caught core panic does not establish a CLI panic.
    Preserve precise error propagation and update relevant public teaching after prerequisites.
  Verification: `pending` — An isolated core program observes CodeBlock::parse returning errors for ASCII
    and aligned Unicode, parsing valid Unicode, but panicking for @ followed by twenty e-acute characters.
    expr.rs unexpected_character_error slices at pos+40 inside a scalar. Harness catch_unwind only
    observes the failure. The earlier whole-spec ASCII probe timed out before any Unicode case; its cause
    remains unresolved.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.47`
  Status: `pending`
  Goal: Align Rust parser and compiled validation for whitespace-only mutation argument lists.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Accept the same semantically empty parentheses through parser and compiler validation while
    preserving exact authored source and character spans. Keep nonempty arguments rejected. Add
    independent empty/space/tab/multiline and invalid controls across native and supported
    serialized/reconstructed/generated carriers; reconcile the canonical contract and public examples
    without silently normalizing away source evidence.
  Verification: `pending` — The isolated core program parses empty, space-only, and tab-only map_leaves!
    argument lists. Compilation accepts only (). Space/tab produce
    receiver_mutation_serialized_state_invalid with reason mutation_call_invalid. The parser uses
    trim().is_empty(), while compiler source-projection validation requires the exact string ().
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.49`
  Status: `pending`
  Goal: Preserve Rust statement boundaries after unflagged regex literals.
  Dependencies: `.3`/`.4`/`.5`; coordinate error propagation with `.45`.
  Acceptance: Keep regex suffix flags adjacent to their closing slash and preserve following
    newline/semicolon statement separators. Compare unflagged and flagged regex assignments, ordinary
    string assignments, CRLF and whitespace boundaries, and arithmetic slash-call controls. Retain
    subsequent assignment AST/source spans through native and supported serialized/reconstructed/generated
    routes. Coordinate with .45 so malformed blocks reject, while this valid newline form compiles and
    returns seven. Do not silently expand or redefine regex flag semantics; split wider changes before
    implementation.
  Verification: `pending` — Four managed native CLI controls all exit zero. Semicolon-separated regex
    assignment, adjacent-flag regex plus newline, and string plus newline return seven without warnings.
    Unflagged regex plus newline returns null with a parse-I-block warning at byte 13 and
    compile:ok/invoke:ok. expr.rs parse_regex skips whitespace before scanning ASCII suffix letters,
    consuming the newline and following out identifier; .45's compiler path then drops the invalidated
    block. The separate core harness timed out during rustc compilation and never ran; its exact scratch
    absence was verified.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.50`
  Status: `pending`
  Goal: Preserve adjacent colon separators after dynamic bare Rust hash keys.
  Dependencies: `.3`/`.4`/`.5`; coordinate malformed-block propagation with `.45`.
  Acceptance: Distinguish the single hash-pair colon from supported identifier/namespace syntax without
    requiring whitespace before the separator. Preserve evaluated dynamic keys and literal quoted keys;
    cover spaced/compact, parenthesized/computed, nested and Unicode key expressions, namespace and keyword
    negative controls, and exact AST/source spans. Verify parser/native and supported reconstructed/generated
    routes, with independent Perl lowering/portable authority. Add recurrence and accurate book examples.
    Coordinate .45 so invalid source rejects while these valid key forms retain their initializer.
  Verification: `pending` repair — six asserted managed Rust CLI/Perl Toolbox lowering controls show
    spaced and left-space bare keys, compact quoted keys, and compact two-argument computed keys returning
    {"a":7} on Rust. Bare key:7 and key: 7 instead return null with expected-colon warnings at positions
    23/24, despite compile:ok/invoke:ok. Perl lowers all six without an unsupported marker. parse_name
    consumes the colon as an identifier character before parse_hash_literal expects its separator.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.51`
  Status: `pending`
  Goal: Reconcile and repair Rust cat minimum-arity divergence against the supported helper contract.
  Dependencies: `.3`/`.4`/`.5`; coordinate public cat teaching with `.28.5`.
  Acceptance: Establish the portable minimum-arity and invalid-call result/diagnostic boundary from current
    authority, then align Rust without silently widening the public helper. Cover zero, one, two and
    variadic scalar arguments, null/aggregate failures, evaluated-argument effects and helper-name shadowing;
    verify native and supported reconstructed/generated/emitted routes plus public recurrence. Preserve
    accepted two-or-more concatenation behavior and existing source provenance. Split implementation and
    cross-backend admission if needed; ask only if normative authority remains ambiguous after reconciliation.
  Verification: `pending` repair — a constant control and two-argument cat both return their expected
    text through Rust primary CLI and Perl public Get on an explicit action-edge spec. cat("a") returns
    "a" on Rust and null on Perl, with no exceptions, recorded last_error, or stderr. Perl lowering requires
    at least two arguments (MethodLowering.pm 5330–5332); Rust engine.rs 8213–8222 concatenates converted
    arguments without an arity guard. The public helper table spells cat(value, value, ...). Earlier no-edge
    E probes returned zero for both Perl cases and are excluded as arity evidence under known .27 debt.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.52`
  Status: `pending`
  Goal: Preserve compact Rust fluent argument whitespace and literal delimiters.
  Dependencies: `.3`/`.4`/`.5`; coordinate standalone teaching with `.41.6`.
  Children: `.52.1`, `.52.2`
  Acceptance: Repair both independently confirmed lexical boundaries without changing helper semantics or
    widening accepted calls. Reconcile supported lifecycle/edge/continuation carriers and public examples.

- ID: `SESSION-STARTUP-READING.52.1`
  Status: `pending`
  Goal: Accept horizontal whitespace before compact Rust fluent argument parentheses.
  Acceptance: Preserve arguments for I.return ("ok") and the tab twin, retaining no-space and braced controls.
    Reconcile scanner/completeness behavior for lifecycle, action, blind, bare and continuation routes;
    preserve named arguments, missing-parenthesis errors, source provenance and typed diagnostics.
    Run native and supported reconstructed/generated controls, update teaching and recurrence.
  Verification: `pending` repair — paired primary Rust CLI/Perl Get controls return "ok" for compact no-space
    and braced-space calls; Rust rejects compact space/tab while Perl returns "ok". The fluent scanner checks
    starts_with('(') before skipping whitespace; I raw-suffix validation then rejects its leftover arguments.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.52.2`
  Status: `pending`
  Goal: Keep quoted and regex parentheses out of compact fluent argument depth.
  Acceptance: Replace delimiter-only extraction with the established lexical argument boundary rules.
    Lock I.return(")") against the braced twin, then quotes, escaped quotes, regex delimiters, nested calls,
    multiline calls, attached conditions and malformed endings across every actual caller. Preserve exact
    source/diagnostics and valid helper behavior; verify native/generated carriers and public recurrence.
  Verification: `pending` repair — compact I.return(")") fails Rust compilation while its braced twin returns
    ")" on both Rust and Perl; Perl accepts the compact form. extract_paren_content_with_end counts every
    parenthesis without quote/regex state, unlike the separate completeness scanner.
  Additional evidence: Julia .1.31 confirms quoted closing-parenthesis truncation and opening-parenthesis empty-call substitution. JULIA-STARTUP-READING.2.20.1/.2 owns its distinct implementation and supported-route proof; exact controls are in docs/knowledge/julia-spec-lexical-boundary-defects.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.53`
  Status: `pending`
  Goal: Preserve unsupported Rust header-rest suffixes for the same validation as body-line twins.
  Dependencies: `.3`/`.4`/`.5`; coordinate malformed-block propagation with `.45` and public examples with `.41.6`.
  Acceptance: Lock Top:: I { return("ok") } @unexpected against the body-line twin and valid compact/multiline
    controls. Preserve unconsumed invalid text instead of discarding it in parse_inline_body; reconcile
    intentional legacy Raw compatibility without silently widening it. Cover explicit/bare I, recognized
    successors, comments, multiline continuation origin and exact diagnostic positions through supported
    parsed/reconstructed/generated routes. Review the neighboring body loop's unreachable advanced &&
    !consumed_line branch, whose consumed_line is assigned true immediately beforehand; retain correct line
    advancement and split mechanical cleanup if needed. Add recurrence and accurate book coverage.
  Verification: `pending` repair — Rust rejects the body-line invalid suffix but compiles/invokes the header
    form successfully with "ok"; Perl rejects both with Unsupported lifecycle block remainder. Inline parsing
    breaks on None without Raw retention; ordinary body parsing retains an I suffix and validation rejects it.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.54`
  Status: `pending`
  Goal: Preserve regex-literal braces through Perl and Rust rule-block scanners.
  Dependencies: `.3`/`.4`/`.5`; coordinate existing attached-tail `.9`, rule-block `.45`, and `.41.6` teaching.
  Children: `.54.1`, `.54.2`, `.54.3`
  Acceptance: Keep regex delimiters lexical while preserving existing regex-versus-division distinctions,
    quoted text, nesting, source provenance and malformed-source diagnostics. Do not infer other backend
    outcomes from the two measured routes.

- ID: `SESSION-STARTUP-READING.54.1`
  Status: `pending`
  Goal: Repair Perl bootstrap rule-block regex-brace truncation.
  Acceptance: Lock I { return(matches("}", /}/)) } against quoted-pattern and /x/ controls through the
    bootstrap owner and public Get. Reconcile CURLY_BRACE lexical alternatives and all explicit, bare,
    action, blind and nested callers; keep attached-tail .9 distinct until shared behavior is proven.
    Preserve complete payload/source and opening line, slash escapes/classes/quantifiers, and malformed
    diagnostics. Verify emitted source independently and add recurrence/book coverage.
  Verification: `pending` repair — direct run_bootstrap_parse returns ICODE ending at return(matches("}", /
    with source ending inside /}; both controls retain full payloads. Public Get produces a coderef but
    execution returns null with rule_handler_compile for Top/_default. CURLY_BRACE has brace and quoted-string
    alternatives only; NON_ACTION_CODE_BLOCK stops at its first closing-brace match. Control matches values are
    Perl 1 and Rust true, not a newly investigated boolean representation issue.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.54.2`
  Status: `pending`
  Goal: Repair Rust rule-block collection and validation for regex-literal braces.
  Acceptance: Align scan_line_for_braces_chars and brace_depth_delta with the accepted literal boundary,
    retaining complete source, line origins and malformed balance diagnostics. Lock matches("}", /}/) against
    quoted-pattern and /x/ controls; cover explicit/bare lifecycle and attached edge bodies, nested literals,
    escapes/classes/quantifiers, multiline quote state and supported serialized/generated carriers.
    Preserve source expression semantics and avoid accepting genuinely unbalanced blocks.
  Verification: `pending` repair — Rust primary CLI rejects the regex-brace lifecycle source at compilation
    while quoted-pattern and ordinary-regex controls execute true. The outer collector and balance validator
    track quotes/braces but no regex state. Complete expression parsing is a separate inner boundary.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.54.3`
  Status: `pending`
  Goal: Close regex-brace public teaching and recurring parity after the concrete scanner repairs.
  Dependencies: `.54.1`, `.54.2`, `DART-STARTUP-READING.2.2`, and Lua .2.24.3/.2.24.4; reconcile `.9` without treating its distinct scanner as already repaired.
  Acceptance: Reverify portable authority and every supported backend/carrier, own any further gaps before
    admitting broader parity, publish worked regex-brace examples and negatives, and run required canonical
    boundary proof. Preserve dated pre-repair controls and exact recurrence ownership.
  Verification: `pending`; Dart reading .1.5 confirms separate grouped-regex action scanning and lifecycle balance failures. DART-STARTUP-READING.2.2.1/.2.2.2 own their fixes; exact public AST/programmatic controls are in docs/knowledge/dart-regex-brace-scanner-defects.md. No other-backend or emitted outcome is inferred.
  Additional evidence: Julia .1.31 confirms outer source closes at a regex brace before ordinary compilation. JULIA-STARTUP-READING.2.21.1/.2 owns outer scanner repair, downstream balance audit and public recurrence. Explicit/shorthand unterminated controls still reject; exact evidence is docs/knowledge/julia-spec-lexical-boundary-defects.md.
  Commit: `pending`
  Additional evidence: Julia .1.32 isolates three compact regex-brace inputs with full retained action source and identical quiet/traced balance rejection. JULIA-STARTUP-READING.2.21.3 owns downstream Validator437-460 repair; existing .2.21.2 now requires it as well as .2.21.1. Exact evidence: docs/knowledge/julia-function-projection-metadata-gaps.md.
  Additional evidence: Lua .1.22 confirms plain/grouped regex outer truncation and a complete compact regex expression rejected by quote-only lifecycle balancing. LUA-STARTUP-READING.2.24.3/.4 own separate parser/validator repairs and .2.24.6 carrier proof. Compact quoted parentheses/spaces succeed; a quoted string passed as matches pattern correctly returns false under Lua's typed-regex contract. Exact evidence: docs/knowledge/lua-spec-parser-validator-reading-and-lexical-gaps.md.

- ID: `SESSION-STARTUP-READING.55`
  Status: `pending`
  Goal: Preserve large finite numeric values and reconcile their portable text spelling.
  Dependencies: `.3`/`.4`/`.5`; coordinate scalar authority `.20`, cat arity `.51` and public teaching `.28.5`.
  Children: `.55.1`, `.55.2`, `.55.3`
  Acceptance: Keep numeric value preservation distinct from number-to-text spelling. Do not silently clamp
    finite values at a host integer boundary or declare portable spelling from a small fixture alone.

- ID: `SESSION-STARTUP-READING.55.1`
  Status: `pending`
  Goal: Remove Rust finite integral-number saturation at JSON and related conversion boundaries.
  Acceptance: Lock direct positive/negative 1e20 output against 42 and independent native value controls.
    Avoid unchecked f64-to-i64 conversion outside its exact supported range; review to_json, to_str, len, Display,
    nested values, helper/key uses and every actual outward/generated consumer before selecting one coherent
    numeric representation. Include runtime_value_from_json and its progressive/typed-record consumers in
    the round-trip inventory; .3.3.28 adds source evidence only, with no new measured conversion failure.
    Include spec_parser.rs usize_field integer/floating branches and their actual definition-AST producers; .3.3.36 inventories this boundary without claiming a reachable new large-field failure. .3.3.38 adds staged_parser_registry.rs source-span/line integer conversion and its public v1 callers to this same audit.
    Preserve finite-number value, existing small integer output, nonfinite policy
    and signed zero. Cover i64-adjacent representable values, fractions and serialization round trips,
    native/generated/primary CLI routes and portable recurrence; do not promise arbitrary-precision integers.
    Include the nested-write classifier's f64-to-usize boundary: compare the first out-of-range power of two
    and adjacent representable values with ordinary dense append/gap controls; reject or preserve their
    identity explicitly instead of silently saturating the diagnostic path/index through a rounded maximum.
  Verification: `pending` repair — Rust CLI returns 9223372036854775807 for 100000000000000000000 and
    -9223372036854775808 for its negative, with compile:ok/invoke:ok and no stderr. Perl public Get preserves
    positive/negative 1e20; both return 42 for the control. Engine direct execution calls RuntimeValue::to_json,
    whose finite integral branch casts to i64 before serde JSON construction.
    `.3.3.17` adds four native diagnostic controls: append at 0 succeeds; index 1 reports an ordinary gap;
    exact f64 value 18446744073709551616 reports a gap at changed index 18446744073709551615; the next
    representable larger value rejects as an invalid selector. The probe exits 0 with empty stderr;
    existing CLI controls expose only generic invocation failure. Exact artifacts and cause are in the numeric Knowledge card.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.55.2`
  Status: `pending`
  Goal: Reconcile scalar-text scientific/decimal spelling outside the existing small numeric fixture.
  Acceptance: Apply the reference-owned finite-number text contract to positive/negative magnitudes, small
    fractions, exponents, signed zero and shortest stable spelling. Resolve any remaining normative ambiguity
    before changing the frozen authority; then repair actual divergent consumers without widening cat arity
    or changing null/aggregate rejection. Keep numeric JSON value preservation under .55.1 separate.
  Verification: `pending` repair — cat(100000000000000000000,"") returns the full decimal string on Rust and
    "1e+20" on Perl, with successful execution and no errors. The scalar-text fixture says shortest stable
    decimal text but its numeric examples are only -0.0, 1.0 and 1.25; it does not establish this magnitude.
    Current Rust to_scalar_text formats finite f64 directly, while Perl cat lowering stringifies the host value.
    Julia .1.17 adds decimal-literal cat(100000000000000000000.0, "") as full decimal versus Perl scientific text; exact paired controls remain in docs/knowledge/julia-large-number-and-slice-boundaries.md. Julia .2.9 separately owns numeric value preservation.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.55.3`
  Status: `pending`
  Goal: Close large-number public guidance and recurring parity after value/spelling repairs.
  Dependencies: `.55.1`, `.55.2`.
  Acceptance: Document the actual finite precision/range and canonical text behavior with worked examples;
    verify exact supported backend and reconstructed/generated/emitted routes before renewing broad parity
    claims. Own any additional gaps, retain dated pre-repair evidence, and run canonical closeout proof.
  Verification: `pending`
  Commit: `pending`


- ID: `SESSION-STARTUP-READING.56`
  Status: `pending`
  Goal: Restore complete Rust built-in function-name reservation without accidental helper shadowing.
  Dependencies: prerequisite .3/.4/.5; coordinate current helper authority and callable/typed-source/gap owners.
  Children: `.56.1`, `.56.2`, `.56.3`
  Acceptance: Reference-owned built-in names must not become user-defined functions through a stale copied list.
    Preserve ordinary custom functions and deliberate callable precedence; do not widen names or hide failures.

- ID: `SESSION-STARTUP-READING.56.1`
  Status: `pending`
  Goal: Freeze current callable-name reservation authority and exact missing-name diagnostics.
  Acceptance: Compare the actual Perl registry resolver and current contract owners with Rust's manual list.
    Lock gap_text and entry_slot rejection beside custom_value success and existing trim rejection; audit
    other current helper/control names, numeric aliases, private/public helper distinctions and intentional
    parameter-name rules. Keep namespace reservation separate from helper arity, invocation and method syntax.
    Establish any wider missing-name population with evidence before expanding the repair.
  Verification: `pending` repair — four paired public native controls at clean activation 75ce8db8 prove
    custom_value() returns "sentinel" on both runtimes and trim definitions are rejected by both.
    Rust accepts gap_text/entry_slot definitions and returns "sentinel"; Perl rejects each at function_registry
    with the exact built-in helper/control collision detail. No timeout; completed native subprocesses.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.56.2`
  Status: `pending`
  Goal: Repair Rust registry validation and prevent recurrence as helper authority evolves.
  Dependencies: .56.1.
  Acceptance: Reject every authority-bound collision before function body/runtime execution on source and
    reconstructed/programmatic definition routes, ordinary/traced validation and supported compilation paths.
    Replace or mechanically govern the stale is_known_actionir_call_name inventory without admitting retired
    names or blocking valid custom functions. Preserve numeric aliases, lifecycle/runtime reservations, arity,
    parameter rules and callable semantics. Verify exact RED/GREEN and direct dependents.
  Verification: `pending` — validation.rs manual helper-name list omits the two observed gap helpers; Engine
    resolves registered functions before ordinary eager-helper fallback, making the admitted name executable.
    Perl UserFunctionRegistry delegates to MethodLowering's current known-value-call resolver.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.56.3`
  Status: `pending`
  Goal: Close registry-reservation public teaching and recurring supported-route proof.
  Dependencies: .56.2.
  Acceptance: Reverify supported backends and native/reconstructed/generated/emitted routes, own additional
    gaps, update public namespace examples and negative diagnostics, retain dated pre-repair controls,
    and run the canonical public/cross-backend closeout. No broad registry parity claim before recurrence.
  Verification: `pending`
  Commit: `pending`


- ID: `SESSION-STARTUP-READING.57`
  Status: `pending`
  Goal: Reject discarded named and malformed selectors on AND bare edges.
  Dependencies: prerequisite .3/.4/.5; coordinate rule-local cursor and inter-match gap authored-slot authority.
  Children: `.57.1`, `.57.2`, `.57.3`, `.57.4`
  Acceptance: Blind ownership must not silently discard authored selector syntax. Preserve unselected bare
    calls and valid explicit action selectors; keep this defect separate from existing Perl return-path .27.

- ID: `SESSION-STARTUP-READING.57.1`
  Status: `pending`
  Goal: Freeze complete selector-bearing blind-edge rejection across the two composed contracts.
  Acceptance: Lock plain Child success and numeric Child[0] rejection against named Child[word],
    unknown Child[missing] and malformed Child[!] in AND bare syntax. Align exact portable diagnostics,
    authored selector/source evidence and rejection order with ADR 0044 and current named-slot authority.
    Include explicit blind twins, valid action twins, malformed/unclosed/empty selectors and reconstructed
    AST provenance; resolve genuine contract ambiguity before changing the frozen authority.
  Verification: `pending` repair — five paired native controls accept plain/named/unknown/malformed forms
    on Rust and Perl while numeric [0] is rejected by both. Rust returns ["selected"] for each accepted
    form; Perl returns null even for plain Child, so this does not establish a new Perl return-path defect.
    Four Perl descriptor probes erase every accepted selector into the identical blind Child row with
    regex_index null and no resolved_slot_edges.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.57.2`
  Status: `pending`
  Goal: Repair Rust AND bare selector validation before blind lowering loses the typed selector.
  Dependencies: .57.1.
  Acceptance: Check typed RegexSelector provenance instead of only legacy numeric target.index; retain
    exact numeric diagnostic compatibility and reject other forbidden authored selector states before
    bcode construction. Cover source/programmatic/serde ASTs, ordinary/traced validation and supported
    complete compile routes; preserve plain blind and numeric/named explicit action controls.
  Verification: `pending` — parse_bare_target_list_prefix sets index only for Numeric. The slot metadata
    pass skips AND bare targets, check_edge_structure tests only index.is_some, and compile_rule lowers
    the first target into a blind entry without its typed selector.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.57.3`
  Status: `pending`
  Goal: Repair Perl bare-edge normalization without losing authored named/malformed selector evidence.
  Dependencies: .57.1.
  Acceptance: Reject every forbidden selector before creating bcode_entries/normalized_edges, using the
    complete retained selector record rather than only numeric index. Lock exact descriptor rejection,
    structured diagnostics and native/source-generated controls; keep unrelated child-return .27 separate.
  Verification: `pending` — RuleIR blind normalization checks defined(index) only, then stores child/code
    and normalized label/index fields without named-selector provenance. Public Get and descriptor
    controls independently confirm acceptance and projection loss for named/unknown/malformed brackets.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.57.4`
  Status: `pending`
  Goal: Close selector-rejection public teaching and supported backend/carrier recurrence.
  Dependencies: .57.2, .57.3.
  Acceptance: Audit remaining backends, own/fix additional gaps, verify complete supported reconstructed/
    generated/emitted routes, document explicit action selector examples and forbidden blind forms, and
    run canonical public/cross-backend closeout without renewing broader parity from narrow fixtures.
  Verification: `pending`
  Commit: `pending`


- ID: `SESSION-STARTUP-READING.58`
  Status: `pending`
  Goal: Enforce the active receiver-write guard on final value-block assignments in Rust.
  Dependencies: prerequisite .3/.4/.5; coordinate existing mutation and write-vivification authority.
  Children: `.58.1`, `.58.2`, `.58.3`
  Acceptance: Final and nonfinal placement must not alter same-receiver rejection or pre-evaluation ordering.
    Preserve unrelated bindings, scoped callback values, detached results and post-commit continuation.

- ID: `SESSION-STARTUP-READING.58.1`
  Status: `pending`
  Goal: Repair final-assignment guard dispatch through the shared Rust value-block evaluator.
  Acceptance: Reproduce final scalar/nested assignments beside nonfinal and explicit-return twins; require
    receiver_mutation_reentrant before segment/RHS effects, then route final assignments through the same
    guarded evaluation authority without changing their returned values. Audit scalar/append/hash/nested
    assignment branches and callers, including nested value blocks and callable bodies. Prove exact diagnostics,
    receiver rollback, guard release, unrelated effects and legal same-spelling parameter/local controls.
  Verification: `pending` repair — six paired primary Rust CLI/Perl Get fixtures at acbadc0f show Rust succeeds
    for final tree = {} and tree["x"] = value while Perl rejects both with receiver_mutation_reentrant.
    Nonfinal and explicit-return controls reject on both; unrelated final assignment agrees. eval_block_value
    sends the last statement to eval_block_final_expr, whose direct scalar/nested branches bypass eval_expr's
    assert_receiver_write_expr; the nested-write coordinator and set_scalar do not replace that guard.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.58.2`
  Status: `pending`
  Goal: Close final-write guard coverage across supported carriers and related callback routes.
  Dependencies: .58.1.
  Acceptance: Run the repaired cases through native/serde/generated-plan/emitted/independently compiled Rust;
    verify source spans and expression-effect ordering rather than accepting generic CLI failure as proof.
    Inspect remaining backends with equivalent bounded controls; own and repair additional measured gaps.
    Preserve declared neutral authority and strengthen recurrence without weakening its rejection contract.
  Verification: `pending` — the six-case September probe establishes Rust direct/primary and Perl public scope
    only; other backends and generated carriers require fresh proof at repair time.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.58.3`
  Status: `pending`
  Goal: Close public guard examples and recurring proof after final-write repairs.
  Dependencies: .58.1, .58.2.
  Acceptance: Teach final/nonfinal receiver rejection and legal detached callback writes with exact examples;
    update all current guard claims, retain dated pre-repair evidence, and run canonical public/cross-backend
    closeout. Do not equate the currently passing neutral mutations with complete runtime path coverage.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.59`
  Status: `pending`
  Goal: Restore consistent statement regex substitution and active-receiver protection.
  Dependencies: prerequisite .3/.4/.5; coordinate .58 shared receiver-guard repair.
  Children: `.59.1`, `.59.2`, `.59.3`, `.59.4`
  Acceptance: Preserve documented ordinary substitution, resolve flag-form and callback lowering discrepancies,
    reject active-receiver writes before effects, and retain pure substr slicing. Exact September evidence is
    in regex-substitution-callback-and-flag-discrepancies; no backend is credited with unmeasured coverage.

- ID: `SESSION-STARTUP-READING.59.1`
  Status: `pending`
  Goal: Repair Perl statement substitution across ordinary and callback lowering.
  Acceptance: Reconcile the public scalar-flags signature with bare-token examples and quoted flag controls.
    Route valid substr/regex_subst statements through their mutation owner inside callbacks and ordinary actions;
    preserve aliases, literal patterns/replacements and flag semantics. Do not silently replace supported
    statements with unsupported-helper markers. Guard active targets before operand effects and preserve legal
    unrelated callback writes. Explicitly diagnose rejected forms without leaking host calls.
  Verification: `pending` repair — ten paired CLI/Get probes show ordinary bare-g substitutions agree, but
    Perl quoted regex_subst leaks a host call, quoted substr yields a marker, and both callback spellings yield
    markers even for unrelated scalar targets. Six callback descriptors record one unresolved helper and ready=0.
    MethodLowering block statement dispatch omits this mutation family; Contracts' ordinary matcher accepts
    bare-word flags only. Retained lowered/generated source proves the actual paths.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.59.2`
  Status: `pending`
  Goal: Guard Rust regex-substitution targets through the shared receiver identity authority.
  Dependencies: .58.1; coordinate .59.1.
  Acceptance: Recognize every admitted target/signature without intercepting pure substr slicing; reject an
    active receiver before evaluating pattern/replacement/flags. Test scalar/hash/array receiver identity,
    unrelated and same-spelling scoped bindings, final/nonfinal placement, rollback, guard release and
    continuation. Avoid a string-name-only guard or a second competing mutation authority.
  Verification: `pending` repair — Rust primary accepts all four active-receiver controls and returns two
    roots with empty-string leaves. receiver_write_attempt omits substr/regex_subst, while call_helper reads
    the private scalar slot, performs replacement, and calls unguarded set_scalar. Unrelated scalar controls
    correctly produce X. Fresh direct structured diagnostics and effect/rollback proofs remain repair work.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.59.3`
  Status: `pending`
  Goal: Close substitution composition through supported carriers and remaining backends.
  Dependencies: .59.1, .59.2.
  Acceptance: Add independent permanent regressions for exact values, descriptor readiness, diagnostics,
    target spans and pre-evaluation effects; exercise reconstructed/generated/emitted/standalone routes.
    Probe Dart, Julia, PUC Lua and LuaJIT and fix or explicitly task-own every measured discrepancy.
    Keep the existing neutral contract's receiver-identity invariant and strengthen runtime recurrence.
  Verification: `pending` — September evidence covers primary Rust and live Perl plus diagnostic source
    capture only; captured generated source was inspected, not independently executed.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.59.4`
  Status: `pending`
  Goal: Align substitution and receiver-write public teaching after repaired recurrence.
  Dependencies: .59.1-.59.3.
  Acceptance: Document exact flags and statement/value boundaries, working unrelated callback substitution,
    active-receiver rejection and invalid-form diagnostics with substantial examples. Reconcile all broad
    helper-guard claims; retain dated defect evidence and run rendered-book plus canonical no-drift closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.60`
  Status: `pending`
  Goal: Make Rust array slicing obey documented bounds without panics.
  Dependencies: prerequisite .3/.4/.5; coordinate .55 integer-conversion boundaries.
  Children: `.60.1`, `.60.2`, `.60.3`
  Acceptance: Out-of-range starts return empty arrays; large counts cannot overflow host arithmetic.

- ID: `SESSION-STARTUP-READING.60.1`
  Status: `pending`
  Goal: Repair array slice start/count normalization and safe range construction.
  Acceptance: Reproduce valid, exact-end, beyond-end, empty-array, omitted-count and receiver-form controls.
    Normalize or bound start/count before addition/indexing, preserve nonmutation and ordinary values, and
    cover zero/negative/fractional and host-boundary inputs according to the existing public contract.
  Verification: `pending` repair — .3.3.21 finds four small out-of-range forms panic at engine.rs:9776:49;
    valid and exact-end controls agree with Perl, which returns [] for every out-of-range control.
    Rust-only count 18446744073709551616 at start 1 panics in start+n at 9775:31.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.60.2`
  Status: `pending`
  Goal: Prove slice safety through supported Rust carriers and equivalent backend boundaries.
  Dependencies: .60.1.
  Acceptance: Add independent exact-value regressions for helper and receiver forms, exercise direct,
    serialized/generated/emitted/standalone consumers, and inspect adjacent take/drop slicing arithmetic.
    Probe remaining backends with bounded inputs; fix or task-own every measured discrepancy.
  Verification: `pending` — the original .60 intake measured primary Rust and public Perl; its captured
    diagnostic source alone did not credit large-count Perl execution or structured carriers.
    Julia .1.17 adds native/reconstructed and executed Perl large-count controls: drop_front throws and slice/substr truncate incorrectly in Julia while the paired Perl controls succeed. Julia .2.10 owns repair; exact replay and carrier limitations live in docs/knowledge/julia-large-number-and-slice-boundaries.md.
    Julia .1.18 confirms safe typed clipping at Int maximum but conversion failure for Float64 1e20. Perl falls back to host substr and returns ab for input_slice(1,1e20) on xabc; its drop_front instead treats scientific spelling as invalid and leaves [1,2]. This owner must reconcile accepted count kinds/ranges and repair or explicitly reject unsafe fallback behavior; exact causal replay is in docs/knowledge/julia-input-slice-arity-and-count-boundaries.md. Julia .2.9 owns conversion, .2.11 arity.
    Lua .1.20 repeats six fresh Perl facade/lowering/source controls: integral max-width clips correctly but floating 1e20 still yields ab; both Lua hosts yield abc for that floating case. Lua .2.13.3/.4 separately own PUC typed-slice integer overflow. Preserve this owner for accepted count policy and Perl fallback repair; no reference result is automatically normative. Exact replay: docs/knowledge/lua-emitter-source-location-reading-and-boundary-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.60.3`
  Status: `pending`
  Goal: Close slice examples and canonical recurrence after bounds repair.
  Dependencies: .60.1, .60.2.
  Acceptance: Teach exact-end/beyond-end/empty/omitted/large-count behavior with helper/receiver examples;
    keep README bounded and synchronize current Knowledge, public book and recurrence with canonical proof.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.61`
  Status: `pending`
  Goal: Preserve scalar helper null and empty-input semantics across runtime dispatch.
  Dependencies: prerequisite .3/.4/.5; retain scalar-text/numeric authority boundaries.
  Children: `.61.1`, `.61.2`, `.61.3`
  Acceptance: Scalar transformations must not convert documented undef results to empty text or zero.

- ID: `SESSION-STARTUP-READING.61.1`
  Status: `pending`
  Goal: Repair Rust null propagation for the seven measured scalar transformations.
  Acceptance: Cover length, trim, lowercase, uppercase, replace_substr, rm_prefix and rm_suffix in helper
    and receiver forms; preserve empty-string/zero/false distinctions, Unicode mapping and array cardinality.
    Guard null before text coercion without broad changes to unrelated dynamic conversion semantics.
  Verification: `pending` repair — exact seven-value controls using literal undef and unbound name null
    both return seven nulls on Perl but [0,"","","","","",""] on Rust. Empty-string controls agree.
    engine.rs 9371 onward converts undef through to_str before producing values; the current helper catalog
    explicitly promises undef for these inputs. null is not the authored undefined literal; undef is.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.61.2`
  Status: `pending`
  Goal: Audit and repair adjacent scalar predicate and empty-pattern boundaries.
  Dependencies: .61.1.
  Acceptance: Compare documented null predicates and empty old/prefix/suffix behavior against public Perl,
    retaining exact boolean/numeric result kinds and failure/argument policies. Own bounded corrections
    before implementation; do not bless all values merely because a host string conversion accepts them.
  Verification: `pending` repair — literal-undef and unbound-name twins return ["XaXbX",1,1,1,true] on Rust
    versus ["ab",0,0,0,0] on Perl for empty-old replace_substr plus starts_with, ends_with, contains_substr
    and matches against empty boundaries. Generated Perl retains defined guards and the empty-needle branch;
    Rust coerces undef to empty text and delegates empty-old replacement directly to str::replace.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.61.3`
  Status: `pending`
  Goal: Close scalar-helper carrier recurrence and public no-drift.
  Dependencies: .61.1, .61.2.
  Acceptance: Prove repaired semantics through supported serialized/generated/emitted consumers and bounded
    remaining-backend probes; add independently justified permanent cases and accurate null/empty examples.
    Retain dated evidence, own additional measured gaps, and run rendered-book and canonical closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.62`
  Status: `pending`
  Goal: Restore coalesce defined-value selection and short-circuit evaluation.
  Dependencies: prerequisite .3/.4/.5; coordinate scalar value and callable/receiver authorities.
  Children: `.62.1`, `.62.2`, `.62.3`, `.62.4`
  Acceptance: A selected defined value prevents later operand effects; preserve zero/false/empty distinctions.

- ID: `SESSION-STARTUP-READING.62.1`
  Status: `pending`
  Goal: Repair Rust coalesce definedness and lazy operand dispatch.
  Acceptance: Preserve defined empty strings, evaluate operands once left-to-right until selection, and skip
    later writes/errors. Cover undef fallthrough, all-undef, zero/false, selected values and nested calls.
    Reconcile aggregate acceptance explicitly against reference behavior and the public scalar signature;
    do not silently widen that signature or conflate coalesce with coalesce_nonempty.
  Verification: `pending` repair — .3.3.22 probes show Rust replaces defined empty text with fallback and
    executes a later audit assignment after either the first or fallback operand is selected. Perl returns
    the empty string and skips those writes. Rust's lazy-call selector omits coalesce; the helper also tests
    nonempty text. Perl emits nested defined-value ternaries. Existing short_circuits test checks value only.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.62.2`
  Status: `pending`
  Goal: Reconcile coalesce_nonempty and receiver/value-block dispatch with the reference.
  Dependencies: .62.1.
  Acceptance: Probe and repair later-operand effects for coalesce_nonempty and documented receiver forms;
    distinguish empty-string skipping from truthiness and aggregate coercion. Preserve callback binding
    identity, ordinary helpers, scalar flags and exact argument diagnostics through every admitted route.
  Verification: `pending` repair — two fresh coalesce_nonempty pairs also show Rust executes the late
    audit assignment after first/fallback selection; Perl preserves unset/selected respectively. Both use
    eager Rust operand collection versus nested Perl conditionals. Receiver/value-block proof remains open.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.62.3`
  Status: `pending`
  Goal: Add permanent default-selection and effect-order recurrence across supported carriers.
  Dependencies: .62.1, .62.2.
  Acceptance: Independently assert selected values, exact effect counts/order and skipped failures in
    native/reconstructed/generated/emitted/standalone consumers; probe remaining backends and repair or
    task-own every measured gap. Preserve typed booleans in diagnostic collectors.
  Verification: `pending` — current primary Rust/live Perl observations and inspected generated source
    do not establish independently executed generated or other-backend behavior.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.62.4`
  Status: `pending`
  Goal: Close coalesce public examples and canonical no-drift after recurrence.
  Dependencies: .62.1-.62.3.
  Acceptance: Teach defined versus nonempty selection, skipped operand effects, zero/false and argument
    boundaries with accurate helper/receiver examples; reconcile claims and run rendered canonical closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.63`
  Status: `pending`
  Goal: Preserve whole-input regex context when matching from a nonzero cursor.
  Dependencies: prerequisite .3/.4/.5; coordinate slot identity, typed source and regex contract owners.
  Children: `.63.1`, `.63.2`, `.63.3`, `.63.4`
  Acceptance: Advancing the cursor must not redefine input-start, line/word boundary or preceding context.

- ID: `SESSION-STARTUP-READING.63.1`
  Status: `pending`
  Goal: Repair Rust combined seek matching without discarding preceding input.
  Acceptance: Match from the current offset against whole input; preserve earliest-start/first-authored
    choice, absolute captures/spans and named group projection. Cover ^, \A, multiline starts, \b/\B,
    positive/negative fixed lookbehind, plain controls, Unicode prefixes and cursor-at-end boundaries.
  Verification: `pending` repair — .3.3.23 six paired collected-rule probes on xhello show five assertion
    discrepancies and plain agreement. helpers.rs seek_match slices input[pos..] before matching;
    Perl LinkedRE matches the original scalar at pos. Exact evidence belongs to the regex-context card.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.63.2`
  Status: `pending`
  Goal: Reconcile consume and required-slot matching with the same context authority.
  Dependencies: .63.1.
  Acceptance: Apply the corrected offset mechanism consistently to consume_match, seek_slot_match and
    consume_slot_match. Preserve required authored slot identity, duplicate patterns and zero-width
    progress policy; validate low-level cursor bounds without conflating them with normal DSL inputs.
  Verification: `pending` — source shows the same input suffix slicing in consume_match and match_slot;
    the current six behavioral controls exercise ordinary choice seek only. Fresh route proof is required.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.63.3`
  Status: `pending`
  Goal: Add exact nonzero-cursor assertion recurrence across supported regex carriers and backends.
  Dependencies: .63.1, .63.2.
  Acceptance: Independently assert selected rule sequences and absolute match/capture spans in native,
    reconstructed/generated/emitted/standalone execution; cover other backends and task-own measured
    differences. Prevent suffix-copy regressions and retain valid unanchored/duplicate-slot controls.
  Verification: `pending` — current primary Rust/live Perl results and source inspection are bounded;
    no native/generated independent execution or other-backend signoff is inferred.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.63.4`
  Status: `pending`
  Goal: Close regex-context public examples and canonical parity after recurrence.
  Dependencies: .63.1-.63.3.
  Acceptance: Explain cursor versus input boundaries and fixed lookbehind with collected examples;
    reconcile regex/current backend claims, render the book, and pass exact canonical closure.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.64`
  Status: `pending`
  Goal: Reconcile Rust MCP caught-panic response and process-output guarantees.
  Dependencies: prerequisite .3/.4/.5; coordinate ADR 0055/0058 and native embedding owners.
  Children: `.64.1`, `.64.2`, `.64.3`, `.64.4`

- ID: `SESSION-STARTUP-READING.64.1`
  Status: `pending`
  Goal: Establish library, host panic-hook and output ownership for caught native failures.
  Acceptance: Audit registration, decoded/prepared response and wire catch boundaries; distinguish
    synthetic injection from reachable native failures and response bytes from process stderr.
    Resolve existing embedding/host obligations without silently rewriting the accepted logging contract.
  Verification: `pending` repair — .3.3.25 exact existing panic test passes 1/1 with --nocapture,
    while captured stderr prints its synthetic message and source location; no external reachability claimed.
    .3.3.26 completes the wire source: its catch surrounds dispatch after decoding; Read/Write calls
    are outside it. Ordinary I/O errors and injected panics require distinct proof boundaries.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.64.2`
  Status: `pending`
  Goal: Repair the owned caught-panic output boundary without changing host-global policy implicitly.
  Dependencies: .64.1.
  Acceptance: Decompose the justified mechanism before implementation; preserve fixed responses,
    silent default/explicit sanitized logging, host hooks, concurrent callers, unwind and shutdown cleanup.
    Do not install or replace a process-global panic hook merely to make the current unit assertion pass.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.64.3`
  Status: `pending`
  Goal: Add isolated-process recurrence that independently checks responses and both output streams.
  Dependencies: .64.2.
  Acceptance: Cover synthetic caught failures at each owned boundary, default/explicit logging,
    existing host hooks, repeated/concurrent calls and unaffected success controls. Assert absence of
    raw fixture text/source locations separately from fixed response values; retain abort exclusions.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.64.4`
  Status: `pending`
  Goal: Close Rust MCP panic/logging claims with public examples and canonical proof.
  Dependencies: .64.1-.64.3.
  Acceptance: Reconcile ADR 0055/0058, public book, Knowledge and recurring ownership; explain
    host/library boundaries accurately, render the book and pass exact canonical closure.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.65`
  Status: `pending`
  Goal: Enforce the MCP payload-byte ceiling equally at EOF, LF and CRLF boundaries.
  Dependencies: prerequisite .3/.4/.5; preserve the current neutral request-limit authority.
  Children: `.65.1`, `.65.2`, `.65.3`

- ID: `SESSION-STARTUP-READING.65.1`
  Status: `pending`
  Goal: Repair Rust final-EOF payload validation before decoding or dispatch.
  Acceptance: Reject every payload above 1,048,576 bytes irrespective of delimiter; preserve exact
    maximum LF/CRLF/EOF acceptance, bounded CR allowance, final frame semantics and fixed parse error.
    Use independently valid padded JSON controls so malformed content cannot mask a missing size check.
  Verification: `pending` repair — .3.3.26 twelve public Rust/Perl controls isolate EOF at maximum+1:
    Rust returns discovery success, Perl -32700. All other eleven pairs agree. Rust EOF sends its
    retained maximum+1 buffer directly to a decoder without the Perl decoder's independent length check.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.65.2`
  Status: `pending`
  Goal: Add exact delimiter/length recurrence and census other MCP runtime boundaries.
  Dependencies: .65.1.
  Acceptance: Cover maximum-1/maximum/maximum+1/maximum+2, EOF/LF/CRLF, lone CR, chunk-split CRLF,
    valid padded UTF-8 frames, overlong draining followed by valid frames and shutdown/log discipline.
    Independently measure all six runtimes and task-own any further discrepancy; preserve current limits.
  Verification: `pending` — six existing Rust wire unit tests pass while the exact public EOF
    maximum+1 control differs; ordinary EOF and maximum CRLF controls alone do not prove their combination.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.65.3`
  Status: `pending`
  Goal: Close MCP size-boundary public teaching and recurring canonical evidence.
  Dependencies: .65.1-.65.2.
  Acceptance: Reconcile decision/book/Knowledge and neutral/native proof without changing the ceiling
    to match a defect; render the book and run required exact canonical closure.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.66`
  Status: `pending`
  Goal: Preserve unique Rust semantic binding occurrences and their exact source references.
  Dependencies: prerequisite .3/.4/.5; coordinate .22 without silently adapting frozen expectations.
  Children: `.66.1`, `.66.2`, `.66.3`

- ID: `SESSION-STARTUP-READING.66.1`
  Status: `pending`
  Goal: Repair repeated binding occurrence allocation and source-reference identity.
  Acceptance: Preserve each same-owner/name assignment as a distinct ordered binding and retain its
    exact source span/excerpt; keep latest-binding resolution separate from occurrence counting.
    Lock one/two/three/four writes, interleaved names, different owners and function/edge scopes with
    independent native expectations. Preserve the no-function gate's separate .22 repair boundary.
  Verification: `pending` repair — .3.3.30 six paired public Rust/Perl queries prove suffixes
    0/1/1/1 versus 0/1/2/3 for four same-name writes. Rust source references for suffix 1 all show the
    final RHS. Counting keys in a latest-binding map saturates at one; repeated source-ref keys overwrite.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.66.2`
  Status: `pending`
  Goal: Prove semantic query identity, source correlation and recurrence for repeated writes.
  Dependencies: .66.1.
  Acceptance: Check unique IDs, per-occurrence order/excerpts, latest reads and every write relation;
    exercise list/get/page-after/explanation at applicable source ceilings and immutable clone boundaries.
    Add meaningful native recurrence beyond the one-write frozen fixture; inventory shared model/digest
    impact before changing it. Census supported other backends and task-own any discrepancy.
  Verification: `pending` — frozen semantic 6/20/128 and 9/0 rollout, 6/0 admission remain green
    despite the new native duplicate-ID cases. Paging/get/relations are not yet measured here.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.66.3`
  Status: `pending`
  Goal: Close supported semantic carriers, MCP projection and public binding-identity teaching.
  Dependencies: .66.1-.66.2.
  Acceptance: Cover supported native/reconstruction/generated/MCP consumers, update book/Knowledge
    with exact source and occurrence examples, render and complete required canonical closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.67`
  Status: `pending`
  Goal: Make semantic call evidence truthful and preserve calls/source through composite expressions.
  Dependencies: prerequisite .3/.4/.5; coordinate .22 and .66 without merging their distinct causes.
  Children: `.67.1`, `.67.2`, `.67.3`, `.67.4`

- ID: `SESSION-STARTUP-READING.67.1`
  Status: `pending`
  Goal: Derive signature-acceptance evidence from actual compiled callable compatibility.
  Acceptance: Retain the declared signature and supplied argument facts; emit acceptance only when
    justified. Cover zero/exact/excess arguments, fixed/rest/final-codeblock/keyword boundaries and
    unavailable static facts with an honest outcome. Audit model/code/digest impact before changing
    exact expected evidence; preserve target non-execution and unchanged callable runtime semantics.
  Verification: `pending` repair — .3.3.31 paired Rust/Perl queries emit call_signature_accepts for
    zero/two supplied arguments while the same function record requires exactly one. The builders
    unconditionally format acceptance from parameter names/count, independently of compatibility.
  Dart .1.30 control: zero/two arguments fail semantic construction at unresolved typed contracts and separately fail runtime arity checks; exact one argument succeeds. These controls do not reproduce the Perl/Rust false-acceptance response.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.67.2`
  Status: `pending`
  Goal: Preserve nested call traversal and binding source evidence through supported expression containers.
  Acceptance: Visit typed children in authored preorder for array and other supported composite nodes;
    preserve exact per-call source and binding RHS source independently of whether the RHS is a call.
    Keep dynamic/unsupported call resolution honest; census edge/function/lifecycle ownership and nested
    arguments, chains, conditionals and mixed source shapes. Split before editing if this exceeds a safe slice.
  Verification: `pending` repair — .3.3.31 direct trim and nested trim calls are projected on both
    backends, but [trim(" x ")] loses its active trim call; Perl Get returns ["x"]. Rust also returns null
    binding source where Perl retains the exact array RHS. Both walkers stop on non-call container nodes.
  Dart .1.30 recurrence: public query also omits trim inside [trim(" x ")] and returns null binding source, while typed ActionIR contains the call and direct runtime returns ["x"]. Direct/nested/string controls retain exact source; separate regex-decoy miscorrelation is owned by DART-STARTUP-READING.2.20.
  Julia .1.26 recurrence: public query retains trim inside [trim(" x ")] and separate runtime returns ["x"], but the binding source is null. Preserve binding RHS source independently of outer emitted calls. Exact92-assertion controls in docs/knowledge/julia-semantic-regex-call-source-gap.md do not reproduce wrong-arity acceptance or repeated-binding identity; distinct regex miscorrelation belongs to Julia .2.15.
  Commit: `pending`
  Lua .1.19 recurrence: Public raw queries retain trim inside [trim(" x ")] and runtime returns ["x"], but the binding source is null; literal RHS 1 also has null binding source. The direct trim binding retains its exact RHS. call_emit_statement derives source only from an emitted outer call, while container/literal traversal returns no outer call. Own Lua RHS source independently of child-call emission; wrong regex source stays Lua .2.17-owned.

- ID: `SESSION-STARTUP-READING.67.3`
  Status: `pending`
  Goal: Lock independent call-evidence recurrence and census supported backends/carriers.
  Dependencies: .67.1-.67.2.
  Acceptance: Cross-check signatures/call facts against independent compile/runtime authorities;
    require unique source-correlated call IDs, correct graph/evidence direction and unchanged source
    ceilings. Census all six runtime variants and supported reconstructed/generated/MCP routes; own
    every discrepancy and review any frozen-model/version impact before updating expectations.
  Verification: `pending` — neutral 6/20/128, rollout9/0/admission6/0 pass despite the paired cases.
  Dart .1.30 census: nine public-query/typed-runtime controls add the container recurrence with seven valid/arity-rejection controls. Four same-name assignments retain suffixes 0,1,2,3 and distinct sources, so the Rust .66 identity failure is not reproduced on this Dart route. Other backends/carriers/MCP remain scoped acceptance work.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.67.4`
  Status: `pending`
  Goal: Close public semantic call teaching and canonical evidence after the corrected projections.
  Dependencies: .67.1-.67.3.
  Acceptance: Reconcile ADR/book/Knowledge with accurate signature and composite-call examples, render
    and pass required exact canonical proof; retain earlier fixture counts as dated scoped evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.68`
  Status: `pending`
  Goal: Reject forbidden authored recognition-token uses through the real Rust execution pipeline.
  Dependencies: .3/.4/.5; coordinate .23 and .45 without conflating their separate failure mechanisms.
  Children: `.68.1`, `.68.2`, `.68.3`

- ID: `SESSION-STARTUP-READING.68.1`
  Status: `pending`
  Goal: Preserve token binding identity and enforce actual authored use restrictions.
  Acceptance: Reject copy/return and every contract-forbidden token use with truthful portable fields,
    including active and consumed token cases, while legal recognize/commit/rollback/value returns work.
    Cover assignments, containers, comparisons, functions/codeblocks and serialization without exposing
    opaque tokens or converting their uses to ordinary undefined values; preserve source and rule scope.
  Verification: `pending` repair — .3.3.32 Rust public query/CLI accept return(tx) and active copied=tx;
    CLI returns null without stderr; Perl Get rejects recognition_token_escape. Legal return("ok") agrees.
    Rust stores an Undef scalar beside the private token; ordinary reads never invoke reject_escape.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.68.2`
  Status: `pending`
  Goal: Prove token-use rejection through authored carriers, not only private authority calls.
  Acceptance: Add independent source-level negative/positive recurrence across native, reconstructed,
    generated-plan and emitted routes; census all six runtime variants and semantic/MCP construction.
    Preserve compile/runtime failure ownership and unchanged linearity, restoration and effect contracts.
  Verification: `pending` — existing Rust negative-token test directly calls the private rejection helper.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.68.3`
  Status: `pending`
  Goal: Reconcile public token teaching, admission evidence and canonical proof after integration repair.
  Dependencies: .68.1-.68.2.
  Acceptance: Update book/Knowledge with accurate forbidden-use examples and run exact canonical proof.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.69`
  Status: `pending`
  Goal: Preserve newline statement boundaries after Rust bare-variable expression lookahead.
  Dependencies: .3/.4/.5; .45 owns warning/drop, .49 owns the distinct regex suffix scanner.
  Acceptance: Lock non-token assignment/read controls; preserve newline/CRLF/semicolon/space/comment
    boundaries while recognizing calls, indexes and fluent continuations with exact source spans.
    Cover native and supported reconstructed/generated routes; synchronize book and recurrence.
  Verification: `pending` repair — .3.3.32 copied=tx newline control warns at byte84 and drops its I block;
    its semicolon twin has no warning. parse_var_or_call consumes whitespace before checking suffixes
    and does not restore it on the plain-variable path. No intended-body execution is inferred from null.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.70`
  Status: `pending`
  Goal: Preserve complete grouped-edge parsing and exact semantic selector/source correlation.
  Dependencies: .3/.4/.5; coordinate .22/.53/.67 without merging their distinct mechanisms.
  Children: `.70.1`, `.70.2`, `.70.3`

- ID: `SESSION-STARTUP-READING.70.1`
  Status: `pending`
  Goal: Correlate each expanded grouped edge by target identity and authored occurrence.
  Acceptance: Preserve exact resolved selector, shared-block source/span and relation evidence for every
    expanded target. Cover prefix/substring labels, repeated labels, shared selectors, direct/indexed/bare
    groups and separate-member controls; avoid substring or flattened-index joins to physical members.
  Verification: `pending` repair — .3.3.33 paired query controls lose Child[1] evidence after ChildLong;
    Perl's second group edge also loses its source. Three paired Get/CLI controls still return b correctly.
  Dart .1.33: Both ChildLong | Child[1] and Other | Child[1] compile as two shared-selector index-1 edges and execute b, but public semantic index construction throws semantic_static_correlation_failed. The helper expects a bracket immediately after each target and loses the first target selector even without prefix overlap. Separate indexed members succeed. Existing grouped repair owns this Dart recurrence; regex-arrow variants are separately Dart .2.22.
  Commit: `pending`
  Lua .1.18: Both installed hosts compile ChildLong | Child[1] and Other | Child[1] into two index-1 edges and execute b, but semantic construction fails the action-edge identity guard. explicit_target_index scans label occurrences for an adjacent bracket and cannot recover the first target's inherited shared selector. Separate indexed members and the tested regex-arrow control succeed. Preserve this exact Lua cause under the existing shared repair.

- ID: `SESSION-STARTUP-READING.70.2`
  Status: `pending`
  Goal: Consume the complete accepted explicit grouped-selector syntax or reject its unsupported remainder.
  Acceptance: Reconcile authoritative grammar and existing Perl/Rust forms before selecting a correction;
    preserve complete targets and their shared block, retain exact unsupported-tail diagnostics and source,
    and keep legacy Raw compatibility bounded. Cover header/body, grouped/bare and per-target/shared
    selector controls without silently adopting new syntax or accepting only the first target.
  Verification: `pending` repair — .3.3.33 per-target-index controls yield one blockless Rust edge versus
    two Perl edges. Rust scans a final group selector only, then drops the unrecognized action remainder.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.70.3`
  Status: `pending`
  Goal: Close grouped-edge semantic recurrence and public evidence across supported carriers.
  Dependencies: .70.1-.70.2.
  Acceptance: Independently compare parsed/compiled/runtime selectors, exact graph IDs/source/relations
    and observation topology; census all six runtimes and reconstructed/generated/MCP routes. Own every
    discrepancy, split implementation leaves where needed, update book/Knowledge and run canonical proof.
  Verification: `pending` — current neutral fixtures pass despite these additional grouped controls.
  Dart .1.33 recurrence: Preserve eight public native compiled/index/runtime controls: two grouped failures, two regex-arrow failures under Dart .2.22, and four successful controls. All eight execute expected inputs; do not infer emitted, reconstructed, other-backend or MCP reproduction from this checkpoint.
  Commit: `pending`
  Lua .1.18 recurrence: Retain both complete grouped construction failures, successful separate-member and regex-arrow controls, typed compiled selectors and independent runtime values on both installed hosts. Further supported-PUC, reconstructed/generated, observation and MCP census remains pending; existing .2.2 owns primary identity.

- ID: `SESSION-STARTUP-READING.71`
  Status: `pending`
  Goal: Emit Rust-correct string literals that preserve every accepted source identity.
  Dependencies: .3/.4/.5.
  Acceptance: Replace JSON-as-Rust escaping at the typed literal boundary; cover every helper caller, quote/backslash/LF/TAB/Unicode/NUL/backspace/formfeed/U+0001 and literal backslash-u controls. Compile and execute emitted modules to verify exact identity round trips; preserve typed errors, serialized payloads and ten-family plans; update public examples/Knowledge and recurring native generated proof.
  Verification: `pending` repair — .3.3.34 emits all seven nonempty identity controls successfully; ASCII/quoted-whitespace/Unicode compile, four control-character modules fail at the identity literal. See docs/knowledge/rust-generated-source-literal-encoding-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.72`
  Status: `pending`
  Goal: Make generated recognition parse adapters preserve a coherent result contract.
  Dependencies: .3/.4/.5; preserve the established typed-value versus legacy-accumulator distinction.
  Acceptance: Reconcile recognition's plain-parse exception with all options/trace/sink siblings using actual emitted modules, default options/disabled trace/no-sink controls, entry selectors and unused intrinsics. Preserve direct arrays without unwrap heuristics, correct emitted imports, independent native recurrence and book/Knowledge accuracy.
  Verification: `pending` repair — .3.3.34 recognition parse returns "ok", while three inert-option siblings return ["ok"]; non-recognition parse roles all return ["ok"]. The plain-parse rewrite also leaves an unused generated import. See docs/knowledge/rust-generated-recognition-parse-adapter-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.73`
  Status: `pending`
  Goal: Reserve every staged result destination for a complete depth before callback execution.
  Dependencies: .3/.4/.5; preserve deterministic shared append and unpublished-AST failure behavior.
  Acceptance: Reject duplicate non-append destinations, mixed append/replacement claims and queued-marker overlap before callback one; preserve distinct sibling writes and ordered shared appends. Reconcile existing Dart/Julia reservations, implement each missing backend, verify one-depth/recursive/carrier routes with independent callback counts and final AST assertions, and update book/Knowledge plus canonical recurrence.
  Verification: `pending` repair — .3.3.37 Paired Perl/Rust controls in both modes call once before sibling collision/queued-marker rejection and silently overwrite a shared replace target after two calls. Exact evidence belongs in docs/knowledge/staged-target-preparation-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.74`
  Status: `pending`
  Goal: Validate returned Rust staged markers deeply and reject invalid provenance without arithmetic panic.
  Dependencies: .3/.4/.5; preserve atomic marker node accounting and typed failure policies.
  Acceptance: Reject forbidden nested result keys within markers just as ordinary results; validate text/provenance bounds before queueing, use checked extent/rebase arithmetic, and return typed diagnostics without panic. Cover direct/derived, large extents, nested malformed markers, valid recursive controls and supported carriers; reconcile Julia precedent, public book and canonical recurrence.
  Verification: `pending` repair — .3.3.37 native returned host-key marker succeeds in both modes while an ordinary host-key record rejects; two u64::MAX extents pass one-depth and panic at strictly_decreases:2121 during recursive preparation. Backtrace and controls: docs/knowledge/rust-staged-returned-marker-validation-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.75`
  Status: `pending`
  Goal: Reject exhausted Rust staged callback authority at the maximum representable call counter.
  Dependencies: .3/.4/.5; preserve cumulative counters across depths and typed admission failure.
  Acceptance: Replace saturating candidate admission with overflow-safe exhaustion logic; cover zero/one remaining call, ordinary exhausted and u64::MAX exhausted authority, no callback on rejection, exact result counters, recursion and carriers. Audit related arithmetic without assuming every saturation is erroneous; align book/Knowledge and canonical recurrence.
  Verification: `pending` repair — .3.3.37 native authority total_calls=max_calls=u64::MAX runs one callback and returns unchanged total; total=max=1 rejects before callback and MAX-1/MAX succeeds once. Source dispatch_resource_check:1784–1793. Evidence: docs/knowledge/rust-staged-call-counter-saturation.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.76`
  Status: `pending`
  Goal: Correct the three SimEnv bare-variable edges that dispatch to the braced-variable handler.
  Dependencies: `.3`, `.4`, `.5`; preserve braced substitution and existing quoting/command behavior.
  Acceptance: Fix the authored dquotes/perl_dquotes/command_substitution targets and governed corpus generation;
    prove bare/braced controls, exact results and diagnostics across current backends, and update public examples.
  Verification: Pending repair; `.3.3.43` preserves twelve paired Perl observations and generated-handler evidence
    in `docs/knowledge/simenv-variable-dispatch-mismatch.md`; only in-memory probe substitutions were made.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.77`
  Status: `pending`
  Goal: Make the generated-source classifier reject failed child execution independently of pass markers.
  Dependencies: `.3`, `.4`, `.5`; preserve exact full-manifest accounting and useful per-case diagnostics.
  Acceptance: Require host-run process success plus exact marker/accounting evidence; cover success, nonzero,
    signal termination, missing/duplicate/unknown markers and actual emitted Cargo execution. Keep all 105 cases
    unconditional, update governed verifier checks and Knowledge, and finish with canonical proof.
  Verification: Pending repair; `.3.3.51` binds the retained six source-extracted controls in `d6f37492` to
    current classifier source: exit 101 with all 105 markers incorrectly reports 105 passes and exits zero.
    The fresh in-memory status-guard control rejects it; executable proof: docs/knowledge/rust-generated-classifier-child-status-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.78`
  Status: `pending`
  Goal: Keep authored emitted-test Cargo dependencies relative to repository-derived workspaces.
  Dependencies: `.3`, `.4`, `.5`; distinguish generated dependency inputs from ADR 0052.6 tool-cache metadata.
  Acceptance: Audit analogous first-party manifest writers, replace persisted absolute runtime-crate dependencies
    with correct relative paths, and verify actual emitted builds plus moved-workspace dependency resolution.
    Preserve exact parser results, workspace cleanup, same-volume storage and legitimate tool metadata;
    update focused storage/portability regression proof and complete canonical verification.
  Verification: Pending repair; `.3.3.58` binds retained recognition/recursive-observation construction probes
    to their unchanged sources. Both write absolute dependencies; relative controls resolve the same crate.
    Nine source-confirmed writers and five relative controls are inventoried in docs/knowledge/rust-emitted-cargo-manifest-path-portability-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.79`
  Status: `pending`
  Goal: Reject signal-terminated captured Git and verifier children in routing-pressure enforcement.
  Dependencies: `.3`, `.4`, `.5`; preserve ordinary exit diagnostics and captured output.
  Acceptance: Require a valid wait result and successful normal termination before accepting a child.
    Audit sibling captured-process helpers; retain success/nonzero/signal controls, stdout/stderr evidence,
    exact verifier integration and canonical proof without weakening route or pressure enforcement.
  Verification: Pending repair; frozen .3.3.61 source-extracted controls show both routing helpers discard
    signal bits with $? >> 8: SIGTERM is accepted as status zero. An in-memory guard rejects it while
    preserving ordinary success/exit7 behavior. Nine document-history sibling controls correctly reject
    nonzero/signal termination. Evidence: docs/knowledge/routing-verifier-child-signal-status-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.80`
  Status: `pending`
  Goal: Reuse compatible PGEN and RGX build artifacts while preserving every real-input invalidation and test.
  Children: `.80.0`, `.80.1`, `.80.2`, `.80.3`, `.80.4`
  Acceptance: Measure documented public build behavior and LinkedSpec-owned target retention. Report
    dependency issues upstream without implementation inspection or modification. Preserve source/pins,
    compatible artifacts and ordinary correct builds. Startup latency is separately owned by .81.
  Director boundary (2026-09-20): RGX/PGEN are black boxes; only published interfaces/contracts and observable results may guide this work. No internal inspection, causal reconstruction, patches or pin changes. Older implementation-derived notes are removed and cannot authorize future work.
  Earlier build permission (2026-09-13): The prior September10 build-on-update-only/no-rebuild requirement is cancelled. Resume normal Cargo builds, including RGX/PGEN compilation whenever Cargo requests it. Retain caches, preserve nested source/pin work and measure observable build behavior. This performance repair is no longer an integration-guide prerequisite; .80.1-.4 retain correctness and optimization work without a mandatory zero-build lifecycle.


- ID: `SESSION-STARTUP-READING.80.0`
  Status: `done; focused-signoff-complete`
  Goal: Preserve the CI build-reuse and newer-OS launch findings from the preceding capacity verification.
  Scope: Read-only evidence intake, pending repair ownership, Knowledge retrieval, book understanding and continuity.
  Activation: Clean `bef5dafd928ca723b79eda524351a9fb5c1cf66a`; zero-byte brief; promoted canonical receipt;
    containment .10 and every diagnostic job are complete and consumed before this task-tree-first change.
  Acceptance: Preserve the public build-stage baseline and its limits, observed sample outcomes and
    separately gated .80/.81 ownership. Dependency-internal conclusions are removed by director instruction.
    Preserve all earlier task/Knowledge/history evidence, reading coverage, dependency work and source bytes;
    return to DART-STARTUP-READING.1.37 after the focused commit and clean proof.
  Verification tier: `focused`
  Focused checks: Exact source/snapshot/log identities and bounded observation reconciliation; prior-node,
    reading and no-source-change scope review; Knowledge generation/check, all nine doctrines, explicit memory,
    both history-pressure checks, mdBook render/content review, staged scope and whitespace.
  Canonical trigger: `none` — tracking and observed-understanding update only; no runtime, dependency,
    CI, cache, policy, storage, capability or generated-contract implementation changes.
  Checklist: [x] clean activation/task ownership [x] evidence and pending owners [x] Knowledge/book/live lockstep
    [x] focused verification [x] commit/brief/clean handoff.
  Verification: Historical build/sample/receipt intake and Knowledge 1048/8543; implementation-derived
    dependency details removed on September20. Original documentation checks included
    rendered book, memory, both history-pressure checks, all nine doctrines and final scope/whitespace pass.
    The preceding capacity commit passes all nine doctrines, required
    consumers, storage/relocation, CLI 66x2 and Phase 0 1,032/1,032 in 1,163 seconds (Phase 0 only);
    its 25 optional gates/matrices remain skipped. This intake grants no startup reading credit.
  Commit: `SESSION-STARTUP-READING.80.0 - own CI build and startup findings` — Evidence and pending repair ownership only; resume Dart .1.37.

- ID: `SESSION-STARTUP-READING.80.1`
  Status: `pending`
  Goal: Measure cold/repeated public builds and supported consumer configurations.
  Dependencies: `.3`, `.4`, `.5`, `.80.0`.
  Acceptance: Run documented interfaces under managed storage, preserving inputs and caches. Record
    commands, toolchain, pins, exit status and build/test durations separately. Observe outputs without
    inspecting dependency implementation or inferring private freshness mechanisms. No zero-build promise.

- ID: `SESSION-STARTUP-READING.80.2`
  Status: `pending`
  Goal: Track upstream reports and published resolutions for measured dependency build costs.
  Dependencies: `.80.1`.
  Acceptance: Supply a self-contained public-command reproduction and observable result. The upstream
    maintainer owns diagnosis and repair. Verify a supplied resolution through published interfaces;
    do not inspect internals, patch dependency source, reconstruct build steps or change pins.

- ID: `SESSION-STARTUP-READING.80.3`
  Status: `pending`
  Goal: Assess compatible dependency-target retention in recurring drivers that currently discard fresh targets.
  Dependencies: `.80.1`.
  Acceptance: Measure the exact semantic, MCP and duplicate-slot driver lifecycles and their direct dependents.
    If beneficial, retain compatible repository-derived dependency artifacts while keeping fresh caller fixtures
    and deliberate isolation/relocation proof exact. Preserve same-volume storage, ownership and cleanup safety.
    Close not-required only with evidence; do not attribute the main gate's rebuilds to these optional drivers.
  Direction update (2026-09-13): Assess retention as a performance improvement while preserving intentional isolation, preparation and ownership. Normal dependency rebuilds, including recovery from a missing compatible cache, are authorized; no negative compiler guard is required.


- ID: `SESSION-STARTUP-READING.80.4`
  Status: `pending`
  Goal: Admit measured dependency-build reuse with unchanged verification coverage.
  Dependencies: `.80.2`, `.80.3`.
  Acceptance: Run repeated unchanged warm commands and controlled valid-invalidation cases, then the exact
    staged canonical gate. Account for remaining compile/startup/test costs, all flags and intentional cold
    proofs; update book and operational guidance with measured results. Parent .80 closes only after its
    implementation and verification are complete; the independent .81 investigation keeps its own status.
  Direction update (2026-09-13): Report measured cold/warm and valid-invalidation behavior with unchanged correctness coverage. The mandatory proof of zero RGX/PGEN compilation and build-on-update-only enforcement is cancelled. Ordinary Cargo rebuilds are authorized; do not claim reuse when compilation actually occurred.


- ID: `SESSION-STARTUP-READING.81`
  Status: `pending`
  Goal: Diagnose prolonged Rust startup on macOS 26.6.2 and resolve any demonstrated repository-controlled cause.
  Children: `.81.1`, `.81.2`
  Acceptance: Distinguish newer-OS evidence from the controlled macOS 26.5.2 closeout under
    FUTURE-PARITY-BACKLOG.19.3.4. A sampled pre-main location is not an OS/kernel causal diagnosis or a repair.
    Preserve exact tests, project-local storage and operating-system trust.

- ID: `SESSION-STARTUP-READING.81.1`
  Status: `pending`
  Goal: Establish controlled newer-OS launch and compiler/loader evidence independently of build invalidation.
  Dependencies: `.3`, `.4`, `.5`, `.80.0`.
  Acceptance: Use exact immutable-artifact warm twins and fresh serial repository-local controls, recording
    toolchain/OS, hashes, launch/build/test timing and concurrent artifact activity. Keep uninstrumented
    measurements separate from stack samples; temporal order does not establish sampling as a remedy.
    Reconcile the recognition and relocation samples plus the failed compiler-sample attempt. Determine
    whether any remaining cause is repository-controlled before selecting a remedy or external limitation.
  Related Lua observation: .1.2 samples both ABI probes on September 12 inside require/dlopen/mapSegments/fcntl while mapping project-local PCRE2 modules. Exact stacks and runtime identities live in docs/knowledge/lua-native-readme-and-action-ast-reading.md. Retain this cross-language comparison in the controlled newer-OS diagnosis; a loader location alone is not a cause or remedy.

- ID: `SESSION-STARTUP-READING.81.2`
  Status: `pending; conditional on causal evidence`
  Goal: Implement and verify only an evidence-backed newer-OS startup remedy when one is required.
  Dependencies: `.81.1`.
  Acceptance: Own the concrete repair before changes, preserve all tests and storage/portability guarantees,
    and prove cold/warm behavior without weakening trust, stripping provenance, speculative re-signing,
    shared-cache deletion or coverage reduction. If controlled current-OS evidence supports no repository
    repair, record that bounded conclusion explicitly; the older-OS closeout alone cannot close this leaf.
    Any necessary action outside project authority requires a concrete reviewable proposal for the director.


- ID: `SESSION-STARTUP-READING.82`
  Status: `pending`
  Goal: Make semantic query budget enforcement and diagnostics agree with the declared logical-cost contract.
  Dependencies: Startup .3/.4/.5; Julia .1.27 intake; preserve ADR0049 and all existing exact query evidence.
  Evidence: Julia and the neutral evaluator return identical six-control responses. Explain emits two relations under max_relations1 and depth1 under max_depth0, complete with no diagnostic. A list page of one record reports max_records reached despite a budget of two and emitted cost1. Exact mechanisms and replay belong to docs/knowledge/semantic-query-budget-contract-gaps.md.
  Children: `.82.1` contract and independent expectations; `.82.2` neutral evaluator repair; `.82.3` bounded backend repair decomposition; `.82.4` transport/carrier/public closeout.
  Acceptance: Resolve the conflict between reported logical costs, request maxima and page-only boundaries explicitly. Keep all source evidence and canonical hashes until an owned contract migration justifies changes. Every confirmed backend gets implementation ownership; no expectation refresh may merely ratify current wrong results.
  Lua reading .1.17 extension: Both installed Lua hosts return the same six complete budget responses as the neutral evaluator and the prior Julia controls. semantic_query.lua page_stream computes budget limitation from the unpaged remaining stream; explain applies only max_records before reporting relation/depth costs. New .82.3.1 owns bounded Lua implementation/proof after the shared contract/neutral decisions.


- ID: `SESSION-STARTUP-READING.82.1`
  Status: `pending`
  Goal: Freeze exact applicable budgets and page-versus-budget precedence for every semantic query operation.
  Dependencies: Startup prerequisites and Julia .1.27 committed.
  Acceptance: Reconcile ADR0049, neutral operation/cost/page policies, public teaching and MCP effective ceilings. Define independently checkable explain record/relation/depth bounds, decision reservation, zero-depth behavior and limits reached before/at/after a page boundary. Preserve the six intake responses; document any deliberate contract decision and migration impact before changing expected hashes.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.82.2`
  Status: `pending`
  Goal: Repair neutral semantic budget selection and diagnostics under the accepted contract.
  Dependencies: .82.1 and startup prerequisites.
  Acceptance: Add independent RED/GREEN expectations for explain secondary relations/depth, zero remaining step allowance, page smaller/equal/larger than budget, after-id continuation, combined ceilings and actual logical cost. Mutation proof must reject coordinated evaluator/fixture drift. Preserve unrelated exact responses and use canonical contract-change verification.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.82.3`
  Status: `pending`
  Goal: Census all five native semantic evaluators and create bounded backend implementation children.
  Dependencies: .82.1; source implementations additionally depend on .82.2 and startup prerequisites.
  Acceptance: Reproduce each boundary through Perl, Rust, Dart, Julia, PUC Lua and LuaJIT without assuming parity. Before editing, create one safe implementation child per confirmed backend cause, with independent request/cost/selection evidence and direct-dependent proof. Julia source mechanisms are SemanticQuery906-961 and1049-1066; retain separate source-correlation owners.
  Children: `.82.3.1` owns confirmed Lua implementation/proof; remaining native census and bounded child creation stay pending.
  Verification: `pending`
  Commit: `pending`
  Lua reading .1.17 extension: Both installed Lua hosts return the same six complete budget responses as the neutral evaluator and the prior Julia controls. semantic_query.lua page_stream computes budget limitation from the unpaged remaining stream; explain applies only max_records before reporting relation/depth costs. New .82.3.1 owns bounded Lua implementation/proof after the shared contract/neutral decisions.


- ID: `SESSION-STARTUP-READING.82.3.1`
  Status: `pending`
  Goal: Align Lua semantic budget enforcement and diagnostics with the resolved shared contract.
  Children: `.82.3.1.1` implementation; `.82.3.1.2` independent proof.
  Dependencies: .82.1/.82.2 and startup .3/.4/.5; supported Lua primary identity remains LUA-STARTUP-READING.2.2-owned.
  Evidence: Lua .1.17 independently compares six full raw-neutral graph responses on PUC and LuaJIT to the neutral evaluator; relation/depth overruns and the premature record-budget warning match the existing shared finding.
  Acceptance: Preserve canonical ordering, source ceilings, paging identity and typed/raw-neutral convergence while implementing the resolved applicable cost/budget boundaries. Keep query-evidence false preservation under LUA-STARTUP-READING.2.15 and all source-correlation repairs distinct.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.82.3.1.1`
  Status: `pending`
  Goal: Repair Lua explain limits and page-versus-budget boundary selection.
  Dependencies: Parent .82.3.1 prerequisites and independently frozen expectations.
  Acceptance: Apply each contract-required record/relation/depth bound to explain and select deterministic budget/page diagnostics from the boundary actually reached. Preserve after_id, decision/step/relation consistency, all unaffected query hashes and agreed logical costs across both supported host routes.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.82.3.1.2`
  Status: `pending`
  Goal: Independently verify Lua query budgets through public entrypoints and composed carriers.
  Dependencies: .82.3.1.1 committed cleanly.
  Acceptance: Cover simultaneous page/record/relation/depth limits, zero-depth explanations, cursor continuations and deterministic complete/incomplete response bodies against independent expectations on supported PUC and LuaJIT. Recompose typed/raw-neutral and applicable MCP proof; preserve source privacy and update book/Knowledge before closing the Lua container.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.82.4`
  Status: `pending`
  Goal: Close semantic budget recurrence across supported carriers, MCP and public teaching.
  Dependencies: .82.2 and every .82.3 implementation child; startup prerequisites.
  Acceptance: Prove typed/raw-neutral and supported reconstructed/generated/observed queries, native and SDK MCP effective ceilings, pages and logical costs with unchanged caller state and no target execution. Update public examples/Knowledge/rollout evidence, run designated canonical admission/public proof and close only the verified scope.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.83`
  Status: `pending`
  Goal: Resolve the historical Lispish document-validation and malformed-token limitations before claiming strict s-expression parsing.
  Children: `.83.1`, `.83.2`, `.83.3`
  Dependencies: Startup .3/.4/.5 and a clean integration-documentation handoff; no implementation pivot during BACKEND-INTEGRATION-GUIDES.2.2.
  Evidence: Integration .2.2 runs34 native Rust cases and independently matches nine complete Perl values. Leading/trailing text and a second form are ignored, an unterminated quote can become an atom, empty square brackets disappear, and a semicolon comment without newline can become content. Get descriptors show seek/default-scan policy, and generated source proves first-child return and no-match null paths. Exact quoted-string codepoints are preserved; no Rust-specific escaping defect was found.
  Historical ownership: PHASE0-BACKHALF-TRIAGE.5.2 fixed the old corpus driver's non-progress loop and described deeper parser/grammar follow-ons without implementing them. This node gives the document/token contract follow-on explicit contract, implementation and verification owners. Its current evidence does not reverify or reopen the dated same-buffer never-undef claim.
  September20 consumer intake: BACKEND-INTEGRATION-GUIDES.8.1 attaches ARCHOGEN/LS-002 complete-input/all-form requirements, ARCHOGEN/LS-003 and SEMULITH/LS-002 token-kind requirements, and SEMULITH/LS-001 reported multiline-string tree corruption with its unverified candidate patch. Exact source-qualified states, snapshots and local-versus-supplied evidence live in docs/knowledge/archogen-rust-lispish-integration.md. Contract .83.1 must resolve compatibility; .83.2 owns actual fixes and .83.3 their independent proof. No report is closed by a documentation warning or this intake, and startup prerequisites remain.
  Acceptance: Establish an explicit complete-document contract, implement the accepted strict path and independently prove it. Preserve existing historical behavior unless a reviewed migration deliberately changes it; a documentation warning alone cannot close this repair.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.83.1`
  Status: `pending`
  Goal: Define strict Lispish document consumption, token validity and compatibility boundaries.
  Dependencies: Parent .83 prerequisites.
  Acceptance: Specify one versus multiple top-level forms, leading/trailing text, empty input, missing/extra delimiters, unterminated quotes, bracket/brace forms, newline and EOF comments, and exact escape/token-kind semantics. Reconcile these with the current first-form extraction grammar and decide whether strict behavior is a separate/versioned grammar or a deliberate migration. Record the decision and independent expected values/errors before implementation.
  Consumer acceptance: Include quoted LF versus tab/CR controls, multiline strings followed by sibling forms, parentheses within such strings, numeric-looking quoted versus bare atoms and the four-form eADL case. Specify how skipped leading/interstitial/trailing text is rejected rather than relying only on a final cursor. Preserve the withdrawn hex-underscore and documented adjacency controls; distinguish grammar validation from consumer domain validation.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.83.2`
  Status: `pending`
  Goal: Implement the accepted strict document and token-validation path with bounded ownership.
  Dependencies: .83.1 committed; startup prerequisites.
  Acceptance: Decompose concrete grammar, API and any necessary backend work into safe children before edits. Add RED/GREEN proof that omitted text and malformed tokens cannot silently yield an accepted document. Preserve documented historical extraction, native in-process execution, exact strings and agreed head/tail or versioned domain shape; no host-side guess may masquerade as grammar validation.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.83.3`
  Status: `pending`
  Goal: Independently verify and admit the strict Lispish path across supported native backends.
  Dependencies: .83.2 and all its implementation children committed.
  Acceptance: Replay exact valid/invalid documents, file/UTF-8/error handling, complete consumption and compiled-engine reuse on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT under their admitted toolchains. Preserve relevant existing corpus coverage without reviving retired applications. Update integration guides, the Lispish walkthrough, Knowledge and task evidence; run canonical admission proof and close only verified scope.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

Perl, Rust, Dart and Julia source reading are complete; ADR0117 closes Julia reading
from the independent .3.1 audit and passing unchanged component proof. All repairs,
startup implementation prerequisites and the rgx reading exclusion remain intact.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `CONFORMANCE-SOURCE-READING.1.62` | `pending` | Read Phase0 lines 28259–29758 (1,500 fragments / 60,456 baseline bytes), continuing the metadata assertions of the marker-outer composite-if deep-marker action pair. Repairs .2.5–.2.11 and earlier repairs retain required reading prerequisites. |

## Reading Ledger

All line ranges below refer to the **reading baseline**, not later shifted working-file line numbers. Files
modified by this checkpoint must also be reviewed in the final diff. Unlisted source files and unlisted ranges
remain unread; running a command that prints a file does not establish comprehension if its output was truncated.

| Required surface | Fully read and understood? | Completed at checkpoint | Remaining |
| --- | --- | --- | --- |
| Roadmap | **Yes** | `ROADMAP.md` 1–2564; `ROADMAP_V2.md` 1–1585. `.2` read 1341–1380, 1381–1420, 1421–1470, 1471–1530, and 1531–1585 without truncation and reviewed both current roadmap diffs. | Review later changes as they land; codebase/book alignment remains gated on their reading. |
| Codebase | **No** | All 89 baseline Perl entries physically read; `.31` preserves forward coverage. Perl reading is complete; Rust reading is complete: all 412 baseline paths / 3,533,382 bytes; `.3.3.67` closes exact coverage, current deltas and durable repair/Knowledge reconciliation. Dart closes under ADR0114; Julia closes 95 entries/75984 lines/2693170 bytes under ADR0117 with 52 committed reading groups and independent audit. | All other first-party inputs not explicitly listed as read; final cross-lane delta reconciliation. |
| mdBook | **Yes — physical source reading** | All 50 tracked book files / 1,956,582 bytes, including configuration and SUMMARY, are fully read at baseline; .3.2.42 preserves coverage, and c8759242 reviews/renders the approved parked-coverage delta. | Formal roadmap/codebase alignment, current deltas, and rendered review remain .4-owned; .41 owns additional verified repairs. |

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


### Shared native-reading acceptance and Rust decomposition at `.3.2.55`

The 66 reading children `.3.3.1`–`.3.3.66` own all 412 baseline Rust paths / 3,533,382 bytes once;
`.3.3.67` owns parent closeout. Inclusive one-based lines and bytes use the same baseline as Perl.
Both empty corpus files have explicit zero-byte owners. The oversized MCP binding line is split across
`.3.3.24`–`.3.3.25`; its six-line header remains with the first payload window. Generated Unicode rows,
embedded contract JSON, full corpus grammars and expected data, manifests, lockfile, and backend README stay in scope.

Each child fits 1,500 lines/fragments and 65,536 bytes. Boundary inspection distinguishes declaration/test
boundaries from continuations inside larger methods, fluent expressions, embedded grammars, or generated data.
A window is not a claim that an enclosing method is complete: reconcile its preceding context and explicitly
retain its suffix owner. Planning inspected boundary context only; no whole Rust file is credited by this plan.
Read each window in smaller untruncated chunks. Retrieve Knowledge first, diagnose surprises with Toolbox,
create repair ownership before changes, review current deltas, record concise comprehension and exact coverage,
run focused direct-dependent and continuity proof, and commit before the next implementation/checkpoint.
Public/runtime/policy repairs remain gated on `.3`/`.4`/`.5`; full codebase reading remains No.

The independent audit converts the task's Scope records to byte intervals and requires exact contiguous,
disjoint coverage through EOF plus explicit empty-file ownership, per-child budgets, and current Git identity.
No separate manifest is created. Recheck collection pressure before later evidence or decomposition grows it;
the 8,000-line general member limit and 80,000-line aggregate remain unchanged.

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

### ControlFlow completion, adapters, emptiness defects, and notes rollover at `.3.2.21`

- Activated from clean `ba9a494caa79fdd6fca7833d5bfc1fbce727fc9d`; prior nine doctrines, post-pointer,
  zero-byte brief, clean status, and complete derived-map review passed (951 facts / 8,040 keys).
  Read ControlFlow 1486–1650 / 1651–1796, DeclareMethod 1–165 / 166–328, Diagnostics 1–145 / 146–269,
  and FlowExpr 1–180 / 181–360 / 361–531 without truncation. FlowExpr's final range was repeated separately
  after an oversized combined query; only the complete final output counts. Scoped total is 1,439 lines /
  59,142 bytes: respectively 311/12,965, 328/14,185, 269/8,970, and 531/23,022. All four full-file
  baseline identities pass; twenty-nine whole Perl files are read. Read-only ranges preceded activation while
  prior hooks completed; checkpoint edits followed its clean boundary.
- Read switch closure/default/output/termination, declaration initializer shapes and AST-set fallback,
  unresolved-helper/node/canonical diagnostic aggregation, value-family inference, emptiness/definedness,
  composite logical/comparison lowering, and raw fallback boundaries. Existing AST/trace/readiness facts reconcile.
  Managed pipeline trace passes one file/five top-level tests; prior compact trace remains recorded at `.3.2.20`.
- Fishy emptiness fallback received public tooling before source diagnosis. On input x, otherwise identical
  Get parsers return empty for is_empty("0"), nonempty for a binding holding "0", and empty for empty string;
  all construct and run without last_error. Generated literal zero reads $0. The same compiled parser returns
  empty with process-local program name '' and nonempty with 'program'. Additional generated-source-only
  controls map 1/true/undef to $1/$true/$undef and invert the faulty quoted-zero result for is_nonempty.
- Root cause: FlowExpr's general expression fallback uses host falsehood; its scalar fast path instead checks
  explicit emptiness. ValueExpr's scalar extractor accepts any word token before literal classification.
  Supporting ValueExpr 115–175 was read after the tooling. Existing public reference explicitly preserves "0";
  read value-container-flow-helper-reference.md 489–511 and 1034–1063, plus helper-contract-catalog.md 770–787.
  These bounded supporting ranges do not complete either chapter. Repair `.16.1` owns value equivalence and
  `.16.2` literal/host-slot isolation, after required reading; Knowledge stores reproducer and proof boundaries.
- Engineering notes reached 468 lines / 42,587 bytes and required rollover. Governed tool archives clean source
  lines 238–460 into segment 4984: 223 lines / 22,371 bytes, SHA-256
  dd7eba212246efd893dbff32143a2c821576c7a704e1a697265213dc728d1f9a. Independent source/blob/hash and
  unchanged prior-manifest checks pass. Current root is 245 lines / 20,216 bytes; manifest 23 lines / 13,782 bytes.
  Collection is 24 files / 25,194 lines / 2,691,497 bytes. ADR 0103 admits exactly max_files 23→24 and manifest
  max_lines 22→23; all current-root, byte, segment, aggregate, ownership, and immutable contracts remain fixed.
- Production/book remain unchanged. Exact reading/probes, Knowledge/history/routing/memory, staged diff review,
  and receipt-bound canonical CI own this infrastructure checkpoint. No push at this intermediate boundary;
  `.3.2.22` reads MethodExpr.pm 1–298 after the canonical checkpoint lands.
- The first canonical attempt passes the preceding contracts/runtime consumers, Perl storage, and Python/tool
  storage, then stops at the process-locality driver: sandbox_apply is denied and the driver exits 71. A no-op
  sandbox-exec control reproduces 71 inside the restricted harness and passes outside it. Approved execution of
  the unchanged full process-locality test passes the relocated six-family driver and containment assertions.
  Existing `project-data-process-locality-proof` now owns this causal requirement. No profile/test is weakened;
  the failed attempt grants no receipt, and the final staged candidate requires a complete permitted rerun.


### Forward reading and confirmed findings preserved by `.31`

The exact `.3.2.21` canonical candidate stayed frozen while read-only preparation continued. This intake
preserves that preparation before its queued reading checkpoints are committed. It grants no runtime repair,
policy adoption, public-book change, or codebase-wide signoff. The existing `.3.2.22`–`.3.2.54` owners still
require their individual comprehension/Knowledge/live-document checkpoints and commits; none is bulk-closed.

#### Exact forward Perl reading

All 89 baseline Perl entries have now been read in full, including generated material. All current Perl bytes
remain identical to `baeb984e36a94a15951cd23d4c52def5064cdaca`. The committed checkpoint before this intake credits
29 whole files through `.3.2.21`. The following actual read-only coverage is durable; each named leaf's existing
Scope remains the exact path/range owner. MCP byte fragments are inclusive, one-based offsets within its blob.

| Queued checkpoint | Untruncated reading chunks within its existing Scope | Scoped lines/fragments; bytes |
| --- | --- | ---: |
| `.3.2.22` | MethodExpr 1–150 / 151–298 | 298; 7,800 |
| `.3.2.23` | MethodLowering 1–195 / 196–405 / 406–605 / 606–815 / 816–1010 / 1011–1210 / 1211–1405 / 1406–1495 | 1,495; 61,967 |
| `.3.2.24` | MethodLowering 1496–1700 / 1701–1905 / 1906–2110 / 2111–2290 / 2291–2378 | 883; 33,969 |
| `.3.2.25` | MethodLowering 2379–2585 / 2586–2795 / 2796–3005 / 3006–3210 / 3211–3410 / 3411–3580 / 3581–3743 | 1,365; 65,506 |
| `.3.2.26` | MethodLowering 3744–3940 / 3941–4135 / 4136–4325 / 4326–4520 / 4521–4715 / 4716–4911; the second range was repeated without truncation | 1,168; 58,949 |
| `.3.2.27` | MethodLowering 4912–5065 / 5066–5230 / 5231–5390 / 5391–5535 / 5536–5680 / 5681–5810 / 5811–5942 | 1,031; 64,411 |
| `.3.2.28` | MethodLowering 5943–6110 / 6111–6280 / 6281–6445 / 6446–6610 / 6611–6810 / 6811–7010 / 7011–7245 | 1,303; 64,878 |
| `.3.2.29` | MethodLowering 7246–7450 / 7451–7655 / 7656–7855 / 7856–8057; ProgressiveSpanDispatch 1–165 | 977; 36,165 |
| `.3.2.30` | RewritePipeline 1–185 / 186–370 / 371–555 / 556–745; Scanner 1–90; FlowRules 1–175 / 176–338 | 1,173; 41,839 |
| `.3.2.31` | LegacyRules 1–195 / 196–390 / 391–585 / 586–780 / 781–980 / 981–1179; PrimitiveBasicRules 1–135 / 136–254 | 1,433; 41,163 |
| `.3.2.32` | PrimitivePipelineRules 1–190 / 191–380 / 381–571; RecognitionTransactionRules 1–124; ScannerCore 1–223; StagedParseJob 1–195 / 196–393; StatementSplit 1–44 | 1,355; 48,756 |
| `.3.2.33` | StatementSplit Core 1–210 / 211–419, Mode 1–214, ActionIR Trace 1–124; ValueExpr 1–175 / 176–350 / 351–520 / 521–666 | 1,423; 47,678 |
| `.3.2.34` | BindingRuntime 1–210 / 211–422; CallableContract 1–135; CodeblockRuntime 1–200 / 201–403; InterMatchGapRuntime 1–150 / 151–291; MCPContract 1–13 | 1,264; 39,889 |
| `.3.2.35` | MCPContract bytes 391–16774 / 16775–33158 | 1; 32,768 |
| `.3.2.36` | MCPContract bytes 33159–65926, consumed in bounded byte output | 1; 32,768 |
| `.3.2.37` | MCPContract bytes 65927–83273 | 1; 17,347 |
| `.3.2.38` | MCPContract 15–21; MCPContractRuntime 1–160 / 161–300; MCPServer 1–160 / 161–325 / 326–490 / 491–648; MCPWire 1–210 / 211–419; Numeric 1–110 | 1,484; 51,303 |
| `.3.2.39` | PluginBridge 1–199; PluginRegistry 1–130; ProgressiveSpanDispatch 1–225 / 226–455 / 456–685 / 686–937; ProgressiveSpanDispatchPolicy 1–58 and ProgressiveSpanDispatchRuntime 1–172 | 1,496; 52,208 |
| `.3.2.40` | RecognitionTransaction 1–220 / 221–440 / 441–655; its Policy 1–140 / 141–269 | 924; 33,632 |
| `.3.2.41` | RecognitionTransactionRuntime 1–230 / 231–460 / 461–681; RecursiveObservationPolicy 1–71; RuntimeDiagnosticOutput 1–145 / 146–247; RuntimeLogical 1–96; RuntimeSemanticObservation 1–174 | 1,269; 39,210 |
| `.3.2.42` | SemanticCallProjection 1–195 / 196–385 / 386–570 / 571–753; SemanticIndex 1–190 / 191–395 | 1,148; 37,003 |
| `.3.2.43` | SemanticQuery 1–200 / 201–400 / 401–596; SemanticRuntimeProjection 1–214; SemanticSourceMap 1–172 | 982; 35,427 |
| `.3.2.44` | SemanticStaticProjection 1–225 / 226–455 / 456–685 / 686–890 / 891–1067 | 1,067; 34,029 |
| `.3.2.45` | SourceLocation 1–230 / 231–465 / 466–700 | 700; 21,209 |
| `.3.2.46` | StagedASTEnrichment 1–220 / 221–440 / 441–670 / 671–900 / 901–1130 / 1131–1355 / 1356–1498 | 1,498; 49,952 |
| `.3.2.47` | StagedASTEnrichment 1499–1720 / 1721–1940 / 1941–2013; StagedASTEnrichmentRuntime 1–120; StagedParseJob 1–180 / 181–352; StagedParseJobPolicy 1–59; StagedParserRegistry 1–170 / 171–328 | 1,374; 43,289 |
| `.3.2.48` | Trace 1–185 / 186–365 / 366–521 | 521; 16,259 |
| `.3.2.49` | UnicodeCaseMapping 1–1500, consumed in smaller complete table ranges | 1,500; 32,073 |
| `.3.2.50` | UnicodeCaseMapping 1501–3000, consumed in smaller complete table ranges | 1,500; 32,854 |
| `.3.2.51` | UnicodeCaseMapping 3001–3835, consumed in smaller complete table ranges | 835; 17,404 |
| `.3.2.52` | UnicodeXIDContinue 1–855, complete generated range records | 855; 17,340 |
| `.3.2.53` | UserFunctionRegistry 1–205 / 206–410 / 411–605 / 606–773; PPlugin 1–175 / 176–331; PathSearch 1–47; env.conf 1–51 | 1,202; 45,829 |
| `.3.2.54` | gdcheck 1–225 / 226–431; htmlcss_driver 1–166; ptchange 1–125 / 126–242 | 839; 22,702 |

The 82,883-byte MCP payload on logical line 14 was also decoded and reconciled with its 35-frame material.
Its three fragment SHA-256 values are 7846664315f28f00563a9dac88632f47f5c8fbf531ff10215724620764f2df19,
5b77ebfcc05b4bf50d90ad0891f87665cc3709c45579df37452a5e76e280dc10, and
0c3751e106207329bacee0b2b0dfde9916242054364fcac63f493df47670c616.
UnicodeCaseMapping's complete file is 3,835 lines / 82,331 bytes. UnicodeXIDContinue contains the existing
806 generated ranges; its existing digest is d1b00bda47306e61ee20a7f63db783f98b15d8d15b876c7506bc4b79ecebc0bb.
The exact-byte encoding audit found only gdcheck comment lines 164/165/167 with raw 0xb5; those bytes were
read through escaped byte representations. No source conversion or runtime encoding defect is claimed.

#### Confirmed runtime and tooling findings

- `.17`: Six public Get parsers were each compiled once with proper runtime context and run against isolated
  empty/populated host slots. Wrong-kind count/first/last changed from 0/null/null to 2/first/last;
  count_keys/sorted_keys/has_key changed from 0/[]/0 to 1/[k]/1. Context errors stayed null and local seeds
  were restored. MethodLowering's array fallback around 5793–5860 and hash/view/member paths around 6115–6400
  use helper-looking names as host slot candidates before enforcing the evaluated value kind.
- `.18`: A quoted value containing set(counter, 2) is rewritten even without an executable set call, and
  contributes a false ASSIGN event. Toolbox output localizes the unmasked PrimitivePipelineRules matcher
  (132–150), raw RewritePipeline replacement, and independent CanonicalEvents search (249–267). Lexical repair
  and canonical-event repair are separately owned; source data must remain source data.
- `.19`: Direct receiver assignment inside map_leaves! hits the typed guard; public Get returns a runtime_handler
  failure with null result and a retained typed detail object. A dynamic codeblock
  assignment bypasses it: the traversal can produce [a:X,a:X] or return a detached shadow with a changed
  tree while the original path remains unchanged. CodeblockRuntime's write_binding/eval-assignment paths
  (96/238) bypass the resolved guard enforced by BindingRuntime (76/96). Parameter shadowing remains
  distinct from nonparameter writes; no arbitrary caller-capture feature is authorized.
- `.20`: num_add on the string containing U+0661 and 1 returns 1 with a host warning in Perl; the neutral
  Python oracle returns 2. Mixed ASCII 1 plus U+0662 yields 2 with a warning versus the model's 13.
  Numeric's Unicode \d acceptance followed by host 0+ conversion (23–25) explains truncation. The intended
  digit language must be resolved from authority; this intake does not assume that ASCII rejection is correct.
- `.21`: Quoted transaction-token text is falsely diagnosed as escape. Separately, warming the compiler
  with token ticket before compiling a bare tx escape makes the latter accept with INVALIDATED/error-null
  state; a fresh bare tx case rejects. RecognitionTransactionPolicy 186–190 interpolates a token name into
  a /o regex, caching the first name. No runtime escape of active authority was demonstrated.
- `.22`: On the same Top rule whose self-edge assigns trim(" x ") then returns the binding, Perl, Dart,
  Julia, PUC Lua, and LuaJIT compile/query successfully but return no helper/binding/call records. Prepending
  an unused function produces exactly helper:trim, helper:return, binding:edge:rule:Top:0:value:0, and calls
  call:edge:rule:Top:0:0 / :1, in order. Empty-function early returns precede rule projection in Perl
  SemanticCallProjection 94, Dart semantic_call_projection.dart 113, Julia SemanticCallProjection.jl 87, and Lua
  semantic_static_projection.lua 1828. Rust remains unprobed. The earlier Julia I-block control returned []
  in both cases and is not proof of this guard; its edge-only action-owner scope was read explicitly.
- `.23`: Get correctly rejects recognition_token_escape, but static semantic projection fabricates
  dependency_target_missing with a blank target and an uninitialized warning. A genuine missing-rule
  control is correct. SemanticStaticProjection's unconditional dependency-failure path (314 onward; 402/416/418)
  loses the actual failure class; it must preserve evidence or use an honest fallback.
- `.24`: A seeded $@ survives quiet trace and plain detail. A successful lazy detail callback replaces it
  with an empty value; a throwing callback replaces it with its own error. Trace 398–439, especially the
  unlocalized eval at 423, is the cause. Exception identity, nested trace, and parser context are repair criteria.
- `.25`: gdcheck marks equal -100 values as below tolerance and -100 to -95 as above at tolerance 10;
  positive twins are unmarked. Its signed margin reverses the interval. Adding/removing two duplicate-key
  rows processes only index zero. DEFAULT with zero or two patterns is accepted because length(@EVAL)
  measures the count's decimal digit length rather than requiring one element.
- `.26`: A managed Open3 argv-list caller supplied identical plain.txt and "with space.txt" inputs.
  ptchange preserved the plain input but emitted empty output for the spaced path, both exit 0; cat's
  stderr shows path splitting. The script uses qx(cat $ARGV[0]) at 30, two-argument output opens at 132/155,
  and a machine-specific shebang. This is a valid-filename failure; arbitrary command execution was not tested.
- `.27`: The existing perl-lifecycle-final-value-e-drift card and ADR 0020 were read before probing.
  Top's no-edge /x/ with E return(match_text()) gives Perl 0 and Julia "x", including Julia trace.
  Explicit self-edge return controls produce "x" on both. Perl's no-edge E constant gives 0; its I constant
  works; E after edge assignment gives null. Full generated source omits regex/E handling: the default
  HandlerVariantEmitter builder (100–115) returns undef without action code, while SpecEntry passes E code
  without a usable handler (143–186/287–295). Julia's mode execution keeps its own regex. Reconcile intent;
  do not infer that Julia is wrong or erase the existing accurately scoped Perl caveat.
- `.29`: An extracted copy of the actual diagnostic gate predicate was executed on eight lexical path
  controls, without changing the index. Perl/Rust/t/tools paths are governed; Dart/Julia/Lua/tests peers are
  excluded by scripts/check_diagnosis_evidence.sh 21–29. These are path-classification controls, not file
  existence claims or full staged-hook proof. The existing evidence-shape-only limitation remains explicit.
- `.30`: Public Get and complete generated-source inspection show the book's grouped edge returns
  {kind:token,text:null} for both bare and quoted alternatives. Explicit per-edge retv=call(target) returns
  bare-child/quoted-child; a shared match_text block returns the corresponding raw text. All contexts are
  error-free. HandlerVariantEmitter's action dispatcher (489–519) emits authored blocks and does not
  synthesize the missing child call. The documentation fix must preserve that semantic boundary.

#### Measured public-checker gaps

- `.28.1`: The full value/container helper reference still calls string zero false, empty aggregates true,
  and the five-backend rollout pending at 1431–1436, with a stale pending heading at 1273. Five public Perl
  truth controls match the admitted contract. The actual logical checker passes 17 truth cases / 10 helpers /
  3 effect cases / 8 complete and its 19-document / 14-denial / 26-mutation public checks. Its required markers
  and exact denial strings omit the real contradictory paragraph (source 256–399 and 815–829).
- `.28.2`: The values/containers guide's 76–77 paragraph retains the prior-backends hash-selector claim,
  although the same chapter records all-five-backend closure. The actual mutation public checker passes
  63 files / 14 documents / 11 example classes / 10 denials / 50 mutations. It already normalizes whitespace
  (257–281); its denial inventory (154–172) lacks the observed claim.
- `.28.3`: What LinkedSpec Is 32–43 says parse_job is future/unavailable. The existing portable authoring
  owner proves the current assignment-annotation form. The staged contract checker passes 123 neutral
  mutations and public 6/17/10/129; its actual public reader excludes that introduction
  (412 onward, 1438–1448, 1557–1567). Reserved import/provider boundaries remain unchanged.
- `.28.4`: Semantic Introspection near 984 says the global ledgers are "now 3/9 and 2/6" instead of 9/9 and
  6/6. The real public_contract_text_errors function receives the page with that sentence and returns [].
  All 28 declared pages are present; the gap is denial coverage, not a missing page. The checker passes
  6 groups / 20 queries / 128 mutations and current 9/0 plus 6/0 ledgers.
- `.28.5`: Helper Catalog 298/313 says definedness is condition-only despite its own current expression
  support note. Four true and four false returned/nested-with controls all compile/run without error;
  Perl represents those observed results as 1 and empty string. MethodLowering 4114/4116 emits defined/
  !defined for values, while FlowExpr 474–487 handles conditions. The catalog's cat entry says undef
  fragments become empty text, but cat("a",undef,"b") and its array twin return null, whereas the empty-string
  twin returns "ab". Full emitted once-only part-list/null-guard code and MethodLowering 5330 onward agree
  with the existing scalar-to-text contract. No portable return-encoding promise follows from these Perl probes.
- `.28.6`: Helper Catalog near 1281 claims exit_now terminates the parser process. The host demonstrably
  continues after catching LinkedSpec::RuntimeExitNow with kind runtime_exit_now, rule Top, status 2;
  context error stays null and the following return is not executed. RuntimeDiagnosticOutput 180–191
  constructs, marks, and throws the typed object. The actual diagnostic checker passes 3 helpers / 11
  render rows / 6 scenarios / 8 complete / 20 mutations; its catalog markers and single old-suffix denial
  do not cover the false process-exit paragraph (190–310/639–649).


#### Supporting book and tool reading

The following complete book sources are baseline-identical. Existing partial reads inside them are not added
twice. Full source reading is distinct from a rendered-book inspection, and `.4` still owns formal chapter
decomposition, remaining reading, and alignment.

| Book path below `docs/linkedspec-book/` | Full lines; bytes |
| --- | ---: |
| `.gitignore` | 1; 6 |
| `book.toml` | 15; 347 |
| `src/SUMMARY.md` | 76; 3,354 |
| `src/index.md` | 40; 2,133 |
| `src/overview/what-is-linkedspec.md` | 99; 6,691 |
| `src/overview/documentation-layers.md` | 63; 3,020 |
| `src/dsl/action-and-lifecycle-placement.md` | 658; 24,890 |
| `src/public-api/native-spec-loading.md` | 375; 22,275 |
| `src/public-api/plugin-registry.md` | 63; 3,278 |
| `src/public-api/trace-api.md` | 636; 39,386 |
| `src/public-api/semantic-introspection.md` | 4,282; 290,387 |
| `src/dsl/value-container-flow-helper-reference.md` | 1,831; 87,584 |
| `src/dsl/values-containers-and-flow-helpers.md` | 662; 32,595 |
| `src/appendix/helper-contract-catalog.md` | 1,943; 120,603 |

The previous partial `development/local-ci-and-regression.md` ranges 1897–1943 and 1988–2004 remain covered.
Together these are 16 disjoint completed ranges / 640,041 bytes; all remaining book source is 1,316,541 bytes.
Independent LF-byte interval and hash accounting covers all 50 baseline paths / 1,956,582 bytes exactly once.
Semantic Introspection's full SHA-256 is 1d7f3db65618c8169f8e49c9532024b95300a0d09beea8004a42e381fccf6fd5;
Helper Catalog's is 36874564ee5bc3a2bef85cc05560dedf1d251c3a4052b2c71abb2ecceb6cb1c7.
All large chapters were consumed in smaller untruncated chunks; preloaded but unreturned tool output was not
counted until it was emitted and read.

Supporting tooling now also includes complete `tools/project_data_env.sh` 1–288,
`tools/test_project_data_process_locality.sh` 1–329, and the Dart/Lua/Julia project-data wrappers.
The diagnostic evidence gate was reread in full. Supporting native source ranges for `.22` were Dart's
semantic call projection 92–180, Julia's call projection 73–155 and action-owner helper 1009–1078,
and Lua's static projection 1820–1935; these do not complete the native files or their reading lanes.

#### Resolved questions and remaining ownership

- `array.length` in the variadic-function example is already supported; the existing variadic-function fact
  resolves the question. Semantic explain budgets are operation-specific under ADR 0049. Neither becomes a defect.
- Managed startup-only Julia controls for ordinary, one-interior-empty, and two-interior-empty depot fields
  yield local depots with optional system depots, always with user_depot_present false. Startup/history and
  package loading were disabled; exact temporary inputs were cleaned. No home-depot access defect is established.
- Both baseline and current Git contain exactly thirteen parked `noncore/plugin/*.plg` paths. The existing
  PPlugin transition card's nineteen-file count is dated June evidence; `.3.2.53` will qualify it and record
  the current census in that owner. The book's thirteen-file count is correct; enumeration is not plugin reading.
- Existing lifecycle debt remains linked to ADR 0020 and its original card. No duplicated lifecycle discovery,
  speculative Julia failure, or new implicit grouped-edge child-call behavior is claimed.
- MethodExpr's focused control independently confirms three authored values in a distinct returned array,
  two values through legacy/fixed-arity fallback, an unchanged original list, and rejection below minimum arity.


#### Supplied-policy comparison evidence

All donor reads were explicitly authorized, read-only, and scoped to the supplied files. Each donor's scoped
Git status was clean when compared. These records preserve provenance; `.5` still owns adoption decisions,
mechanical changes, and final alignment after required reading.

- fsmgen `README_POLICY.md`: 187 lines / 9,849 bytes; SHA-256
  882682fa1ace703ae68726b8532a4ad24fe2c8a271bae4e07b859bd197a621c9.
  Latest file change is `1f0443b3a4e654f8460ba6eda272c53e1d8b642d` (August 20).
  The complete latest diff changes only fsmgen's local adoption note from a pinned capacity to a derived
  downward ratchet; the neutral body is unchanged. LinkedSpec already adopted its own independent
  128-line / 6,144-byte README boundary under ADR 0063 and subsequent routing closure. Do not copy donor caps.
- fsmgen `docs/LIVE_DOCUMENT_SIZE_CONTAINMENT_ADOPTION_GUIDE.md`: 431 lines / 21,327 bytes; SHA-256
  8f77fa39c9bcb9cfc43166259a627a6ced64682030088400b727dccc5d674a53.
  Latest file change is `727e0d0861efeb8288b23ccd75e6b751c2fdc771` (September 5).
  Its latest seven-line update distinguishes stable delegated checker success from duplicated changing
  registry cardinality; exact counts remain valid for fixed synthetic fixtures. The complete guide also
  classifies derived-on-read, verified copies, authored intent, and immutable evidence, with explicit field
  ownership and lossless migration. LinkedSpec's README/memory/history systems implement parts of these
  principles; this is not evidence that the whole donor package is adopted. Review actual fields/consumers in `.5`.
- pgen `docs/CLAIM_VERIFICATION.md`: 285 lines / 18,166 bytes; SHA-256
  9f99df25209c43afb74d77e348dd2d0cdb68ce96cf17a4f272ede8328f6046bd.
  Latest file change is `178251cceeae72173db20db3f409db4abc7e517c` (August 30).
  The added section 4.1 distinguishes prose, numbers, and named-instance claims; contract numbers require
  exact gated evidence, while deterministic populations and explicit patterns are the authoring standard.
  The complete policy requires independent rederivation, revert/reapply RED proof, and independent falsification,
  with durable inputs and bidirectional history coverage. No explicit local adoption filename/phrase was found;
  that does not imply all principles are absent. Existing TASK-ACCEPTANCE checks evidence shape and deliberately
  do not execute Markdown commands. `.29` owns its measured path gap and runs before `.5` adoption closeout.

September 11 group .1.6 recheck: all three supplied files were fully reread, read-only; their
SHA-256 identities above are unchanged. No donor revision or local adoption is claimed by this check.

#### Remaining reading preparation

Read-only decomposition drafts are preparation and carry no source-reading credit. Git plus the existing
disjoint class selectors remain the inventory authority; no additional tracked manifest was introduced.
Independent validators checked object identities, LF/decoded-byte intervals, exact-once coverage, empty files,
and the 1,500-line / 65,536-byte budgets. Formal child creation and manual boundary review still precede reading.

| Pending lane | Baseline paths | Stored bytes | Draft reading groups |
| --- | ---: | ---: | ---: |
| Rust | 412 | 3,533,382 | 67 |
| Dart | 115 | 2,471,305 | 57 |
| Julia | 95 | 2,693,170 | 53 |
| Lua | 99 | 2,732,450 | 51 |
| Specs/configuration/noncore | 158 | 964,256 | 19 |
| Shared verification/Unicode inputs | 160 | 5,422,313 | 144 |
| Repository tools | 143 | 2,381,957 | 38 |

The native drafts preserve two empty Rust fixtures and two oversized generated-line fragments each for
Rust/Dart/Lua. Shared verification includes all four pinned gzip objects and their 3,352,036 decoded bytes;
its total reading representation is 8,257,059 bytes. The sole current tooling delta is the owned
`doctrine/readme_stability/routes.jsonl` history-capacity change; it is explicitly accounted for.
The book draft follows SUMMARY order and leaves 48 pending ranges; one project-status boundary still needs
manual review. Root guidance classifies all 28 paths: nine recorded full reads, five prescribed memory/history
retrieval surfaces, and fourteen pending maintained documents (1,354,206 bytes). Pending root text is
baseline-identical. These draft counts do not imply that their content was read or that their future leaves exist.

#### Preceding canonical completion

The unchanged staged candidate for `.3.2.21` completed canonical CI with exit 0 at 2026-09-06 13:58:18 UTC.
The receipt binds base `ba9a494caa79fdd6fca7833d5bfc1fbce727fc9d` and candidate SHA-256
`d3dd218a7cbce4742b9bb857f67a54bdaba85ef6c01510ffeb9f1725e83064af`.
Mandatory checks passed, including both 66/66 CLI environments, Phase 0 1,032 tests, and the complete six-family
process-locality oracle. Optional environment-selected matrices were unset and skipped normally; no broader
optional-coverage claim follows. The commit hooks passed all nine doctrines, the post-commit activation pointer
passed, and the receipt was promoted to `17d3e919118430d4fad0e31d6c1a4a8e2d9dc333`. The brief was cleared to
zero bytes and Git was clean before activating `.31`; no background job remains.

### Method expression parsing and scope precedence at `.3.2.22`

- Activated from clean `3e8b05cd343dafa0b67c536bfe0c9e6b52f074c7` after intake `.31` committed, its post-commit pointer passed,
  and the brief/status cleanup completed. The preceding canonical result remains recorded in that intake.
- MethodExpr.pm was fully consumed at 1–150 and 151–298 during forward reading, then reviewed in full for
  this checkpoint: 298 lines / 7,800 bytes, baseline-identical. This closes the next individual checkpoint;
  all 89 Perl files remain physically read, with later comprehension/Knowledge checkpoints still pending.
- The module preserves method names, distinguishes slash-symbol calls from regex quoting, splits CSV values
  with nesting/quote/escape state, parses nested function calls, and normalizes optional scope against arity.
  Opt-in authored-value precedence clones an already-valid argument list before any legacy scope removal.
  Fixed-arity compatibility can remove a leading scope only when the remaining arity is valid.
- Existing `hash-tree-callback-append-scope-collision` and
  `terse-source-migration-runtime-boundaries` cards were read in full and reconciled with the retirement
  closeout. Older spellings remain historical evidence; two new retrieval questions point to the normalizer.
- The bounded normalizer control preserves key / quoted-at / depth as three values with precedence, returns
  two values through legacy and fixed-arity fallback, keeps a distinct authored list and unchanged input,
  and rejects an empty list below minimum arity. This checks the source-owner boundary, not full runtime parity.
- Source/book remain unchanged; codebase/book are No. Next `.3.2.23` covers MethodLowering 1–1495.

### MethodLowering prefix and dated migration ownership at `.3.2.23`

- Activated from clean `27ff841afdfb276f520d4988a5807df5e364e7f5` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- The prefix was read in eight untruncated forward ranges preserved by `.31`; checkpoint review additionally
  consumed 1–405, 406–815, 816–1210, and 1211–1495. Full-file baseline identity and the 61,967-byte prefix agree.
- Read trace/family adapters, typed logical evaluation, dependency assembly, direct-container inference,
  inline if/switch values, AST-first block side effects/returns, and the guarded compatibility block path.
  Source reconstruction, typed spans, nested-write evaluation/presence updates, binding mutation adapters,
  helper classification, and contextual/dynamic codeblock binding setup complete this prefix.
- Existing AST value/operator/call/block/fallback, trace, uniform-binding, write-vivification, and callable
  Knowledge records were read and reconciled. The early value-dispatcher card now points to completed
  `.4.1`–`.4.3`; intermediate write/callable rollout notes identify their historical milestone scope.
- Managed `PERL5LIB= prove -Iperl t/trace_actionir_method_lowering.t` passes one file / four top-level tests.
  No runtime repair or whole-helper audit is claimed. Existing `.19` still owns the dynamic receiver-guard gap.
- All Perl source remains physically read; subsequent comprehension checkpoints remain pending. Codebase/book
  stay No, and the next owned range is MethodLowering 1496–2378.

### Function signatures, local bindings, and statement lowering at `.3.2.24`

- Activated from clean `2c398b922192172310bfd733bdcecaef0ee6750a` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Forward reading consumed 1496–1700, 1701–1905, 1906–2110, 2111–2290, and 2291–2378; this checkpoint
  reviewed 1496–1910 and 1911–2378 in full. The 883 lines / 33,969 bytes and full baseline identity agree.
- Read version-1 fixed and version-2 rest-signature validation, copied call-stack state, local declaration
  discovery, nested-write presence and receiver-target inventories, and unknown-call traversal. The remainder
  covers VALUE_DROP, typed return/set/push/array-end dispatch, and guarded assignment operators.
  Actual user-function body/value dispatch follows in the next range; it is not attributed to this prefix.
- Existing function execution, variadic implementation/signature, scalar retirement, direct access, selector
  rejection, and RHS-shape chronology cards were read in full. Four existing records now distinguish the
  initial fixed-function and rollout milestones from current signatures and retired authored syntax.
- Managed `PERL5LIB= prove -Iperl t/variadic_user_function_contract.t` passes 66 top-level tests. A public Get
  control builds a mixed hash/array value and reads it with a bare index; it returns `one` and no context error.
  The exact successful control follows. Source/book remain unchanged; no whole-backend signoff is claimed.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict; use warnings;
my $spec=qq{Top::\n /x/ -> Top { foo = hash("a", array(hash("b", array("zero", "one")))); z = 1; return(foo["a"][0]["b"][z]) }\n};
my %ctx;my $parser=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx);die 'compile failed' unless ref($parser) eq 'CODE';
my $input='x';my $result=$parser->(\$input);die 'unexpected result' unless defined($result) && $result eq 'one' && !defined($ctx{last_error});
print JSON::PP->new->canonical->encode({result=>$result,context_error=>undef}),"\n";
PERL
```

- Later checkpoints remain pending; codebase/book stay No. `.3.2.25` owns MethodLowering 2379–3743.

### Value dispatch and function caller-scope evidence at `.3.2.25`

- Activated from clean `d392ad2bee69a7fa2b5090c40589ca5f77d011f9` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- This checkpoint re-reviewed 2379–2795, 2796–3210, 3211–3500, and 3501–3743 in full, following `.31`'s
  physical forward reading. Exact whole-file baseline identity and 1,365 lines / 65,506 bytes agree.
- Read authored collection normalization, scalar/container ownership, quote-aware shape construction,
  array pipeline/reducer dispatch, AST/source compatibility, eager logical calls, fixed/rest user-function
  execution, dynamic codeblock invocation, source reconstruction, and the receiver-aware assignment bridge.
  Previously recorded wrong-kind, numeric, and dynamic-receiver gaps remain with `.17`, `.20`, and `.19`.
- Existing function/callable/AST Knowledge was checked before diagnosis. Public Get, captured generated source,
  and descriptors show body locals shadowing caller arguments: scalar, array-valued, and nested-call cases
  return null, while literal/distinct-name/parameter-only controls preserve their inputs. All eight compile
  and report no context error, raw dependency, or unresolved helper. MethodLowering 3293 emits local
  declarations before argument temporaries at 3294–3295; this explains the observed lexical capture.
- The first aggregate probe expected an empty host array and stopped when the actual result was null.
  The dump shows a uniform scalar binding; the final eight-case observation records null accurately.
  No test fixture was re-blessed. The exact successful command and result table are committed in
  `docs/knowledge/perl-user-function-caller-shadowing.md`; the older execution card now qualifies its claim.
- New repair `.32` owns caller-scope separation and scalar/aggregate/nested/rest/order/temporary-name
  regression controls after required reading and policy review. Other backends remain unprobed; no
  implementation, public-book change, or standalone generated-parser execution is claimed.
- Global codebase/book answers remain No. `.3.2.26` continues the same source at 3744–4911.

### Block values, receiver chains, and root-dependent traversal at `.3.2.26`

- Activated from clean `85167df3ae9883636ec00ea5c8259aa581b238b5` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed 3744–4025, 4026–4330, 4331–4630, and 4631–4911 in full after `.31`'s physical forward pass.
  Exact whole-file baseline identity and 1,168 lines / 58,949 bytes agree.
- Read the assignment-bridge tail, direct path reads, block-local early/final returns, contextual `with`,
  typed value/helper/aggregate dispatch, receiver-family continuation, immediate hash/array traversal
  callback frames, array-end value mutation, and guarded `map_leaves!` continuation construction.
- Existing fluent-chain, block-value, hash/array traversal, array contract, and uniform-binding mutation
  records were read. The original hash-only non-hash rejection statement now links to the later shared
  hash/array dispatcher; the array contract preserves hash-root behavior, and its initial phase0 count
  is explicitly historical. The exact current public control replaces the older hash-card probe string.
- Managed `PERL5LIB= prove -Iperl t/actionir_ast_parser.t` passes 23 top-level tests. Three public Get
  controls return hash depths `{a:1,arr:1,b:{y:2}}`, array depths `[[2],1,1]`, and scalar `[null,0]`
  (no callback effect), all without a context error. Opposite-family containers are leaves within the
  selected traversal. Exact command: `docs/knowledge/perl-hash-tree-traversal-callback-frame.md`.
- No runtime/book edits or new runtime defect are claimed. Codebase/book remain No, and `.3.2.27`
  continues the source at 4912–5942; previously owned repairs retain their prerequisite sequence.

### Helper fallback, numeric dispatch, and bounded contract evidence at `.3.2.27`

- Activated from clean `a32cf42245dc97ec31d4e8f6b89d10c658bf2718` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed 4912–5140, 5141–5390, 5391–5625, 5626–5810, and 5811–5942 without truncation.
  Whole-file baseline identity and 1,031 lines / 64,411 bytes agree with `.31`'s forward reading.
- Read AST-versus-compatibility entry dispatch and trace decisions, rule/gap/source/capture helpers, string
  transforms and concatenation, scalar Numeric calls versus inline aggregate reducers, string predicates,
  emptiness/read/collection paths, and the slice prefix. The slice body continues in `.3.2.28`.
- Existing AST value/call/aggregate/fallback, helper-retirement, scalar-numeric admission, and Unicode-digit
  evidence were read. Four existing cards now distinguish completed function/statement migrations from
  earlier milestones, retired spellings from current constructors/bindings, and the 55-case numeric
  admission from the later `.20` disagreement outside that fixture. Previously owned `.16`/`.17` gaps
  remain open; no broad helper correctness or resolved Unicode-digit defect is claimed.
- Managed `PERL5LIB= prove -Iperl t/scalar_numeric_contract.t` passes nine top-level tests. Public descriptors
  for malformed substr/count and an unknown value call each report one unresolved helper with zero raw
  dependency; the registered value call reports zero of both. The exact successful command follows.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
for my $c(
 ['substr_arity','return(substr("abc"))',1],
 ['count_arity','return(count(1,2))',1],
 ['unknown_value','return(unregistered_probe("x"))',1],
 ['registered_value','return(normalize(" x "))',0]
){
 my $spec="fn normalize(value) { return(trim(value)) }\nTop::\n /x/ -> Top { $c->[1] }\n";
 my %ctx;my $d=LinkedSpec::Get(\$spec,return_descriptor=>1,runtime_ctx_ref=>\%ctx);
 die "$c->[0] descriptor" unless ref($d) eq 'HASH';
 my $m=$d->{spec}{Top}{meta}{action_rewriter};my $raw=$m->{raw_perl_dependency_count}//0;my $unresolved=$m->{unresolved_helper_count}//0;
 print JSON::PP->new->canonical->encode({case=>$c->[0],raw=>$raw,unresolved=>$unresolved}),"\n";
 die "$c->[0] metadata mismatch" unless $raw==0 && $unresolved==$c->[2];
}
PERL
```

- Managed map generation emitted child setpgid EPERM, then completed successfully. A subsequent child
  PID/PGID control matches; the original final group is unobserved. Wrapper 308–314 assumes group identity
  from the child PID. Existing `.7` now owns establishment verification; its Knowledge card preserves exact
  warning/control and unresolved timing, with the two older lifecycle records linked to the limitation.
- Source and public book remain unchanged. Codebase/book remain No; `.3.2.28` owns 5943–7245.

### Collection helpers, constructors, and tagged-record divergence at `.3.2.28`

- Activated from clean `e4716fcf55042846646e654190a68cca11ee57d2` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed 5943–6230, 6231–6530, 6531–6810, 6811–7070, and 7071–7245 without truncation.
  Whole-file baseline identity and 1,303 lines / 64,878 bytes agree with `.31`'s forward pass.
- Read array bounds/concat/split/tagged/sort/membership helpers, hash views/transforms, coalesce/copy,
  constructors and source-slot reads, mutation/return payload lowering, assignment bridges, receiver
  splitting/family registries, and the legacy array-chain normalizer. Later family normalizers follow next.
- Existing constructor/retirement, alias-history, uniform-binding, tagged-record, and split Knowledge was
  read. Historical bare-name selector teaching now points to structural retirement; alias implementation
  instructions and next-frontier wording are explicitly historical. A new question indexes why an outer
  copy remains unchanged after the tested nested write rebinds its original through BindingRuntime.
- Three public controls pass: literal constructors, copy followed by nested mutation, and combined array/
  hash helper results. The exact successful control and captured-source filter follow.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical->allow_nonref;
for my $case (
 ['constructors','value = 7; return([array("foo"), hash("foo",value)])',[['foo'],{foo=>7}]],
 ['copy_independence','original = {"nested":{"x":1}}; snapshot = copy(original); original["nested"]["x"] = 2; return([original,snapshot])',[{nested=>{x=>2}},{nested=>{x=>1}}]],
 ['collection_hash','items=[1,2,3,4]; meta={"b":2,"a":1}; return([items.slice(1,2),items.take_last(2),meta.sorted_keys(),meta.pick_keys("b")])',[[2,3],[3,4],['a','b'],{b=>2}]]
){
 my $spec="Top::\n /x/ -> Top { $case->[1] }\n";my %ctx;my $src='';
 my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src);
 die "$case->[0] compile" unless ref($p) eq 'CODE';my $input='x';my $got=$p->(\$input);
 print $json->encode({case=>$case->[0],result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 if($case->[0] eq 'copy_independence'){for my $line(split /\n/,$src){print "$line\n" if $line =~ /__ls_copy_value/}}
 die "$case->[0] mismatch" unless $json->encode($got) eq $json->encode($case->[2]) && !defined($ctx{last_error});
}
PERL
```

- Tagged-record diagnosis uses two Perl Get/source controls and the same specs through fresh PUC Lua CLI.
  For `a,b,`, Perl makes two records, with carried increments 1/2 and final counter 2; PUC makes three
  records with field 1 and counter 1. Ordinary split retains the trailing empty item on both.
  For empty input, Perl yields no records, counter 0, and no ordinary split items; PUC yields one empty
  record, counter 1, and one ordinary empty item. All controls succeed without a Perl context error.
- Generated Perl and MethodLowering 6068–6075 put fields inside map and omit the split trailing-empty
  limit. Lua interpreter 1093–1106 appends the suffix; 1897–1907 and 1926–1940 split already-evaluated
  arguments and copy fields. Diagnostic source reads covered Lua 1082–1145 and 1840–1970; they do not
  complete Lua reading. Helper-reference 1163–1166 confirms the current once-only public claim.
- New `.33.1` owns all-runtime/native/generated impact and authoritative contract review; `.33.2` owns
  the resulting fix and regression/public coverage. Fresh evidence is only Perl and PUC Lua here;
  LuaJIT and the other backends remain unprobed. Exact paired commands/results live in
  `docs/knowledge/tagged-record-evaluation-and-split-drift.md`; the two Lua records link that limitation.
- No runtime or public-book edit was made. Codebase/book remain No; `.3.2.29` reads the suffix and
  ProgressiveSpanDispatch next, before the remaining prerequisite checkpoints and owned repairs.

### Receiver normalization suffix and private progressive ActionIR at `.3.2.29`

- Activated from clean `86673c75a56b869e80c7613345f9c0963c013e8b` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed MethodLowering 7246–7505, 7506–7775, and 7776–8057 and all 165 ProgressiveSpanDispatch
  lines without truncation. Exact whole-file baseline identity passes; owned ranges total 977 lines /
  36,165 bytes, agreeing with `.31`'s forward coverage. This adds no duplicate physical-reading credit.
- The suffix covers number/string/hash receiver family normalization, terminal and arity branches,
  AST-first array-end and hash/nested assignment mutation bridges, set_key/push fallback precedence,
  regex substitution, and return_undef. Uniform-binding branches precede retained host-slot fallbacks.
- ProgressiveSpanDispatch exclusively owns its assignment statement. Static validation decodes literal
  parser/top identities, checks normalized spelling and a bare span binding, and lowers valid operands
  to the invocation-owned runtime. Invalid static operands remain available for diagnostic ownership.
- Read existing progressive authority/carrier/admission and recurring/public-closeout Knowledge plus
  optional-scope collision Knowledge before source diagnosis. Three older progressive cards now point
  to the completed private six-runtime boundary, while their dated admission evidence remains historical.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/progressive_span_dispatch_perl_contract.t`
  passes 129 assertions. `bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py`
  passes rollout 9/9/116 and public 6/12/10/60. Other runtime routes are not rerun by this reading checkpoint.
- No runtime, public-book, or policy behavior changes. Codebase/book remain No; `.3.2.30` follows.

### Source-span rewrite orchestration and scanner ownership at `.3.2.30`

- Activated from clean `3c1a955a1669469697dd3325c1dcde74c684e76f` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed RewritePipeline 1–245, 246–485, and 486–745, Scanner 1–90, and FlowRules 1–175 /
  176–338 without truncation. Exact whole-file baseline identity passes for all three files: 1,173 lines /
  41,839 bytes. This checkpoint adds no duplicate physical-reading credit to `.31`.
- RewritePipeline rejects removed aggregate selectors structurally, inserts implicit-if closures and
  newline terminators, guards ambiguous unmatched event rewrites, and applies contract lowering by
  source-span replacement. Original-source lookup tracks separators; replacement searches the current
  rewritten text from zero. Unbalanced if/switch stacks return the original code after tracing.
- Scanner lazily obtains ScannerCore and preserves the caller error state. FlowRules scans if/elseif/
  else/while/switch families, nested case/default branches, printing/exit/return helpers, and exact
  standalone bare or parenthesized next. Internal scanner IDs do not establish public helper admission.
- Checked existing AST seam/inventory/fallback, scanner-family, pipeline-trace, function execution,
  and quoted-rewrite Knowledge first. ScannerCore 1–223 was additionally re-read to reconcile its registry:
  staged, progressive, recognition, basic, pipeline, flow, legacy. Five dynamically scoped callbacks are
  shared; the first defined response, including an empty array, owns the contract and stops dispatch.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/trace_actionir_pipeline.t` passes five
  top-level tests. A managed ScannerCore callable registry/JSON census reports all seven owners in order;
  `rg --files perl/LinkedSpec/ActionIR/Scanner` finds the five actual family modules. The scanner Knowledge
  record preserves a direct callable reverify command; the old four-family/six-file census is superseded.
- Four existing records reconcile the seven-owner architecture, registered function/value-drop support,
  retired alias/selector history, completed fallback audit, and the known `.18` lexical rewrite limitation.
  No fresh all-backend or complete defect-free claim follows from this bounded trace proof.
- No source, public-book, or policy changes. Codebase/book remain No; `.3.2.31` follows.

### Legacy and primitive scanner coverage with current push precedence at `.3.2.31`

- Activated from clean `6f113221546d579cae647069e19b9bfa3a8c4f81` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed LegacyRules 1–310, 311–610, 611–905, and 906–1179 plus PrimitiveBasicRules 1–254
  without truncation. Exact whole-file baseline identity passes: 1,433 lines / 41,163 bytes, with no
  duplicate physical-reading credit beyond `.31`.
- LegacyRules owns call/child-push/return scanning, capture slices and marks, cursor/input projections,
  entry/match groups and positions, and cursor controls. Call scanning avoids the specific recognition/
  observation child positions. PrimitiveBasicRules owns host-shaped assignment/call/push/return patterns,
  statement-based bare return/exit/declaration/destructuring/substitution/position controls, and gap helpers.
- Read current scanner architecture, fallback audit, uniform-binding, mutation-slot, scalar-seam, and
  historical bare-variable gap Knowledge before interpretation. Three old records needed current storage
  and child-push qualification; their dated milestone evidence remains historical.
- Three public Get controls pass scalar source assignment, harray values carried through array append /
  keyed mutation, and typed array return. Generated `push(Child,items)` checks for a compiled Child handler;
  absent one, it appends the value of items to binding Child. Exact successful controls follow.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical->allow_nonref;
for my $case (
 ['scalar_source','name="ok";out=name;return(out)','ok'],
 ['typed_mutation','items=[];value={"n":1};key="k";meta={};items += value;meta[key]=value;return([items,meta])',[[{n=>1}],{k=>{n=>1}}]],
 ['return_forms','value=[1,2];return(value)',[1,2]]
){
 my $spec="Top::\n /x/ -> Top { $case->[1] }\n";my %ctx;
 my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx);
 die "$case->[0] compile" unless ref($p) eq 'CODE';my $input='x';my $got=$p->(\$input);
 print $json->encode({case=>$case->[0],result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 die "$case->[0] mismatch" unless $json->encode($got) eq $json->encode($case->[2]) && !defined($ctx{last_error});
}
print LinkedSpec::call_spec_handler_subst('Top','push(Child,items)'),"\n";
PERL
```

- Existing `perl-uniform-binding-runtime` already records the handler-first contract. The generated branch
  agrees with MethodLowering 1253–1265 and the existing static-rule precedence fixture at
  `t/uniform_binding_contract.t` 231–248. Two public controls independently pass both branches:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical;
my @cases=(
 ['binding_only',"Top::\n /x/ -> Top { items=[];value=\"v\";push(items,value);return(items) }\n",'x',['v']],
 ['registered_rule',"Top::\n I { items=[\"unchanged\"];outputs=[] }\n /x/ -> Done { push(items,outputs);return([items,outputs]) }\nitems::\n /x/ I { return(\"child-result\") }\nDone::\n /x/\n",'xx',[['unchanged'],['child-result']]]
);
for my $case (@cases){
 my %ctx;my $p=LinkedSpec::Get(\$case->[1],runtime_ctx_ref=>\%ctx);
 die "$case->[0] compile" unless ref($p) eq 'CODE';my $input=$case->[2];my $got=$p->(\$input);
 print $json->encode({case=>$case->[0],result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 die "$case->[0] mismatch" unless $json->encode($got) eq $json->encode($case->[3]) && !defined($ctx{last_error});
}
PERL
```

- Binding-only result is `["v"]`; registered rule result is `[["unchanged"],["child-result"]]`.
  All five Get controls leave context error clear. This is an existing documented precedence rule, not a
  new runtime defect or repair; Rust and the other backends are not reverified by this checkpoint.
- Mutation-slot and scalar-seam cards now distinguish their historical separate storage from current
  uniform typed values and retired selector syntax. The fallback audit links the same handler-first
  choice, removing its unconditional child-call claim. Codebase/book remain No; `.3.2.32` follows.

### Pipeline, recognition, staged marker, and splitting ownership at `.3.2.32`

- Activated from clean `b1108cbb18c5cd347912a4ce44f86b289958abef` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed PrimitivePipelineRules 1–285 / 286–571, RecognitionTransactionRules 1–124,
  StagedParseJob 1–220 / 221–393, and StatementSplit 1–44 without truncation. ScannerCore 1–223 was
  re-read during `.3.2.30` registry diagnosis in this same reading run. Exact baseline identity for all
  five files passes: 1,355 lines / 48,756 bytes, with no duplicated physical-reading credit over `.31`.
- Pipeline scanning combines raw helper patterns with statement-based mutation/value-drop recognition,
  balanced receiver/index parsing, nested-access AST fallback, and array pipeline-plan extraction.
  Recognition scanning preserves exact result/token/operand fields for observation and transaction forms;
  the generic assignment scanner excludes their assignment spellings.
- StagedParseJob owns one exclusive scalar assignment, validates literal option keys/policies/capabilities,
  builds direct entry/match or ordered cat text plans, and lowers inert marker construction with only
  the needed private match information. Parser resolution and scheduling remain separate runtime owners.
- StatementSplit validates its trim dependency and lazily delegates to Core under OwnerDispatch error
  preservation. ScannerCore's seven-owner/five-dependency registry is already indexed under `.3.2.30`.
- Read marker/provenance, carrier/admission, public parse-job, recognition integration, and known token
  validation Knowledge before reconciliation. The marker card's non-public authoring claim was stale
  after `.14.7.9`; exact assignment authoring is public while its carrier/authority stays private and the
  generic helper inventory excludes parse_job. Recognition inventory prose now uses the current census
  and links `.21`'s separately reproduced lexical/order defects.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t`
  passes 143 top-level checks. `bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py`
  passes nine rollout legs / 123 neutral mutations plus public 6/17/10/129.
- `bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py` passes
  138 ActionIR rows (134 current + four dedicated), 250 calls, 58 rejected mutations, and 9/9 rollout.
  `bash tools/project_data_run.sh env PERL5LIB= perl tools/check_language_capability_coverage.pl` passes
  250 current calls and 126 independently covered public Perl contracts. Other runtime routes are not rerun.
- No runtime, public-book, or policy changes. The finite proofs do not close known `.18`/`.21` repairs;
  codebase/book remain No and `.3.2.33` follows.

### Statement splitting, lazy trace, and value-expression ownership at `.3.2.33`

- Activated from clean `9be547af99c2a9c99757eb0986d3292ad64b3a50` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed StatementSplit/Core 1–235 / 236–419, StatementSplit/Mode 1–214, Trace 1–124,
  and ValueExpr 1–240 / 241–460 / 461–666 without truncation. Exact baseline identity passes for
  all four files: 1,423 lines / 47,678 bytes; this adds no duplicate physical-reading credit over `.31`.
- Core owns top-level separator detection, nested quote/regex/delimiter state, attached control tails,
  and trailing statement emission. Mode's line-comment state clears on LF alone. RewritePipeline's
  pending newline insertion uses the previous rewritten endpoint, including any trailing inline comment.
- Twelve distinct public Get/Core/substitution combinations cover no comment, inline comment, an explicit
  semicolon before a comment, and a standalone comment under LF/CRLF/CR. No-comment controls return ok
  for all three. Inline LF/CRLF produces no result with a context error; explicit/standalone LF/CRLF pass.
  Every commented CR form loses the return without a context error. Process exit zero and Get returning a
  CODE wrapper do not establish handler compilation; invocation result, error, and emitted source are checked.
- Repeated the three inline cases with dump_parser_source. LF/CRLF emits `$name = "ok" # note;`
  followed by `return $name`: the generated separator is hidden in comment text and handler compilation fails.
  CR leaves the comment and return in one split statement and emitted host comment. `.34.1` owns lexical
  separator placement; `.34.2` owns comment state plus emitted newline handling. Other runtimes were not probed.
  Exact commands and observations live in `docs/knowledge/perl-comment-newline-lowering-drift.md`.
- Read prior separator, attached-control, lazy-trace exception-state, and compact-lowerer Knowledge first.
  Qualified both universal separator claims and the trace/value owner record. ActionIR::Trace wraps calls in
  OwnerDispatch error preservation and stays lazy; that wrapper fact does not close direct callback defect `.24`.
  ValueExpr retains legacy access/selector heuristics beside scalar binding reads and method/flow delegation;
  legacy private branches do not redefine the current typed-AST access contract.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/trace_actionir_compact_lowerers.t`
  passes four top-level tests. Required memory, Knowledge, history, and review checks precede landing.
- No runtime, public-book, or policy edits. Reading codebase/book remains No; `.3.2.34` follows.

### Binding, callable, codeblock, and gap runtime boundaries at `.3.2.34`

- Activated from clean `ab4b1f1e5fbe33a0df4d3c643375e5e22ca6b98f` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed BindingRuntime 1–225 / 226–422, CallableContract 1–135, CodeblockRuntime 1–210 /
  211–403, InterMatchGapRuntime 1–291, and MCPContract 1–13 without truncation. Exact baseline identity
  passes: 1,264 lines / 39,889 bytes across four whole files and the 390-byte MCP header. No duplicate
  physical-reading credit is added over `.31`; the embedded MCP data begins at byte 391 in `.3.2.35`.
- BindingRuntime owns runtime selector kinds, atomic copied nested writes with dense array creation,
  identity-based active receiver guards, root-kind map traversal, and scalar-held array/hash operations.
  Existing `.19`/`.20`/`.33` defects remain owned; no broader deep-clone or host-object safety claim is made.
- CallableContract exposes copied builtin acceptance metadata and typed final-user-parameter validation;
  contextual arguments preserve typed body/source spans, and runtime projection yields a codeblock literal.
  CodeblockRuntime interprets its supported AST, invokes explicit dynamic bindings, copies arguments, restores
  prior parameter values after body execution, and diagnoses recursion/arity/callability. Nonparameter writes
  still use the direct slot path already implicated by `.19` receiver-guard evidence.
- Six public Get controls show direct true/false are JSON booleans while literals evaluated in cb() become
  numeric 1/0 and a dynamic literal array becomes [1,0]. A passed-in true remains typed. All contexts report
  no error. call_spec_handler_subst plus decoded embedded record preserves boolean AST kind/source; only
  CodeblockRuntime's boolean evaluation branch converts it to numeric values. `.35` owns focused repair.
  Exact commands are in `docs/knowledge/perl-codeblock-boolean-literal-kind-drift.md`; other runtimes and
  independently loaded generated-parser executions were not measured for these controls.
- InterMatchGapRuntime attaches candidate/tail/cursor state to the existing recognition guard, checks
  post-child cursor monotonicity, qualifies entry-slot provenance against the active parent, and returns
  detached gap spans through the source-location owner. The old Perl implementation card's pending rollout
  prose is now explicitly historical; current public language and six-runtime rollout belong to recurrence.
- Read binding, callable/variadic/final-block, primitive/logical, gap plan/recurrence, and MCP generated-binding
  Knowledge before reconciliation. One new boolean fact and three qualified records preserve the boundaries.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/callable_codeblock_literal_contract.t
  t/inter_match_gap_capture_perl_contract.t` passes 134 top-level tests across two files.
  `bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py` passes 9/0/63
  and public 8/15/10/34, plus Rust/Dart/Julia/Lua admission mutations 10/10/10/16. This finite proof does
  not close the separate `.19` receiver or `.35` literal defect.
- No runtime, public-book, or policy edits. Codebase/book remains No; `.3.2.35` follows.

### Embedded MCP canonical frame and tool-schema prefix at `.3.2.35`

- Activated from clean `19b0a7c4d3f02f875b015bbb46816d8e6313886b` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed MCPContract.pm bytes 391–8582 / 8583–16774 / 16775–24966 / 24967–33158 without
  truncation, exactly 32,768 bytes. Full-file identity matches the reading baseline; the fragment SHA-256 is
  `7846664315f28f00563a9dac88632f47f5c8fbf531ff10215724620764f2df19`. No duplicate physical-reading
  credit is added over `.31`; the remaining embedded fragments and executable suffix have their own leaves.
- Read the data-only binding format, canonical cancellation/capability/query/discovery and error frames,
  five native discovery identities, restricted capability projection, semantic rejection, and the two
  tool-schema prefix. Request metadata, opaque handle syntax, paging/budget/source fields, typed response
  records/relations, and native semantic diagnostics remain embedded contract data, not new server behavior.
- Read generated-binding, implementation-admission, recurring all-twenty, and stdio-contract Knowledge first.
  Qualified the Perl card's obsolete current 1/5 implementation and 1/6 runtime claim as historical;
  the current ledger remains 5/5 + 6/6, shared rollout complete, 141 mutations, with no status movement.
- Six artifact controls compare the canonical capability/query/restricted/semantic-rejection text with
  structuredContent and confirm isError=false, including native ok=false. Handle-unavailable and policy-denied
  tool failures have isError=true and no structuredContent. The exact managed probe is preserved in
  `docs/knowledge/perl-mcp-decoded-server.md`; it does not claim fresh dispatch or six-runtime execution.
- `bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py` reports the full 83,411-byte
  binding byte-fresh. `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl
  t/mcp_contract_perl_binding.t` passes five top-level tests. `bash tools/run_python_project_data.sh
  tools/check_mcp_implementation_admission.py` passes current 5/5 + 6/6 complete/141 governance.
- One Knowledge record reconciles topology and response-layer ownership. No runtime, public-book, policy,
  protocol, or admission changes; codebase/book remains No and `.3.2.36` follows.

### Embedded MCP policy, corpus, and schema authority at `.3.2.36`

- Activated from clean `4b9036222f16892a29de29d9ef01660048d0b918` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed MCPContract.pm bytes 33159–41350 / 41351–49542 / 49543–57734 / 57735–65926
  without truncation, exactly 32,768 bytes. Full-file baseline identity passes; fragment SHA-256 is
  `5b77ebfcc05b4bf50d90ad0891f87665cc3709c45579df37452a5e76e280dc10`. This adds no duplicate
  physical-reading credit over `.31`; the embedded suffix begins at byte 65927 under `.3.2.37`.
- Read the end of canonical tool/error frames, digest-pinned neutral artifact references, authority fences,
  canonical JSON, component-wise lowering policy, handle/authorization/expiry rules, protocol/request metadata,
  native identities, shutdown, and fixed tools. Corpus data includes exact frame order, four unavailable-handle
  states, ten lifecycle cases, four policy cases, ten raw-byte cases, and the closed schema through the query
  request prefix. These are generated data owners; fresh native transport execution is not claimed.
- Read ADR 0055 and the existing all-twenty blocker/repair Knowledge before reconciliation. The embedded
  deployment policy explicitly limits pre-dispatch denial to supplied overlay components; unsupplied components
  remain native dispatch and native portable response. This is the already-implemented all-twenty correction,
  not a new contract decision. `.5` startup alignment now explicitly owns qualifying the earlier ADR section 5
  wording without erasing its historical evidence or changing the accepted runtime boundary.
- A managed Python comparison decodes MCPContract line 14 and checks its `contract`, `schema`, and `corpus`
  against their three neutral JSON owners; all values match. Direct assertions confirm the 72-key recordFacts
  enum, query contract `{minLength:1,maxLength:128,type:string,x-linkedspec-maxUtf8Bytes:128}`, explicit overlay
  enforcement, native handling of unsupplied components, and current validation count 76.
- `bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py` passes
  35 canonical frames / 10 raw inputs / 10 lifecycle cases and exact artifact digests. The subsequent
  `bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py` passes 35/10/10/76.
  No materialization --write, runtime consumer, protocol modification, or new oracle is introduced.
- Reconciled the stdio card's stale current 68 count to 76 and the all-twenty card's old public-closeout
  chronology, with current embedded evidence and ADR-alignment ownership. No runtime, public-book, or
  policy edit; codebase/book remains No and `.3.2.37` follows.

### Embedded MCP schema suffix, semantic payloads, and digests at `.3.2.37`

- Activated from clean `c3dadd4b6321902d8f64ad9f50adab6978e73b92` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed MCPContract.pm bytes 65927–74118 / 74119–83273 without truncation, exactly
  17,347 bytes. Full-file baseline identity passes; suffix SHA-256 is
  `0c3751e106207329bacee0b2b0dfde9916242054364fcac63f493df47670c616`. Together with `.3.2.35`/
  `.3.2.36` this completes the 82,883-byte embedded JSON line. The 138-byte executable/accessor suffix at
  lines 15–21 remains in `.3.2.38`. No duplicate physical-reading credit is added over `.31`.
- Read query/record/relation/snapshot/schema suffix, typed shape and signature structures, source references,
  exact native identities, tool definitions, error/success shells, fixed-order tool list, and root schema union.
  The payload suffix holds default/restricted capabilities, graph-list rules, and invalid-operation results,
  their exact source query/projection provenance, and response/source SHA-256 values.
- Read MCP plan/contract/recurring Knowledge before reconciliation. The four transport payload examples
  preserve three native responses (including ok=false) and one declared restricted capability projection;
  they do not substitute for the separate all-twenty native/MCP consumers. Added that boundary and exact
  managed digest reverify command to `docs/knowledge/perl-native-mcp-server-plan.md`.
- The managed Python probe verifies canonical encoded embedded JSON equals the stored line and hashes to
  header `a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001`. The payload collection
  equals its neutral JSON owner; all four canonical response hashes and all seven referenced source-artifact
  hashes match. `bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py` independently
  reports the complete 83,411-byte generated binding byte-fresh.
- This is source/data comprehension and identity proof; native queries, server dispatch, and the already
  passing five-test binding suite from `.3.2.35` are not rerun. No runtime, public-book, policy, protocol,
  or admission changes. Codebase/book remains No and `.3.2.38` follows.

### MCP schema, registry, wire, and numeric runtime ownership at `.3.2.38`

- Activated from clean `c38afa72b3390e408c55ed849225c42ad9e70eae` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Re-reviewed MCPContract 15–21, MCPContractRuntime 1–165 / 166–300, MCPServer 1–225 / 226–435 /
  436–648, MCPWire 1–215 / 216–419, and Numeric 1–110 without truncation. Exact baseline identity passes:
  1,484 lines / 51,303 bytes. The 138-byte MCPContract suffix completes that module's per-leaf reading;
  this adds no duplicate physical-reading credit over `.31`.
- MCPContractRuntime checks the embedded digest, lazily decodes the data, clones outputs through canonical
  JSON, validates the closed schema profile, and builds response shells. Server state lives behind object
  identity, registers preexisting native indexes, extracts policy/default/source-availability fields,
  validates authorization digests and monotonic expiry, tracks explicit policy-component presence, and
  holds prepared response identity through wire flush/cancellation cleanup. Corrected earlier five-scalar
  wording in both MCP ownership cards: the extracted projection data also includes defaults/availability.
- MCPWire owns bounded LF/CRLF framing, EOF/overlong drainage, strict UTF-8, duplicate decoded-key preflight,
  raw numeric-id syntax/range, schema-checked canonical output, and fixed optional I/O diagnostics. It delegates
  dispatch to the same server path. No formal constant-time or arbitrary-host-object guarantee is inferred.
- Six initial decoded controls, then the same six repeated on decoded and in-memory stdio routes, show exact
  response identity. Unknown method plus missing metadata yields -32601; old version plus missing required
  clientCapabilities yields -32022. Known current/missing-metadata controls yield -32602. Source checks method
  first, protocol next, and full request schema later, unlike ADR 0055 section 6's earlier metadata step.
  The current static suite consumes separate canonical failures; that does not prove combined precedence.
  `.36.1` owns authority/six-runtime census, `.36.2` bounded repair decomposition, and `.36.3` public closeout.
  Exact public probe and table live in `docs/knowledge/perl-mcp-validation-error-order-drift.md`.
- Read current MCP plan/decoded/contract/ADR/repair and numeric/Unicode Knowledge first. Numeric owns helper
  arity, scalar conversion, finite arithmetic, half-away rounding, signed modulo, and normalized results;
  `.20` still owns the recorded Unicode-digit/coercion mismatch. No new authority choice or numeric fix.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/mcp_server_perl_dispatch.t
  t/mcp_server_perl_stdio.t t/mcp_server_perl_admission.t` passes 31 top-level tests across three files.
  `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/scalar_numeric_contract.t` passes nine.
  `bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py` passes 55 cases / 18 helpers.
  Other runtime consumers are not rerun; passing existing suites closes neither `.20` nor `.36`.
- One new and three updated Knowledge records preserve findings and ownership. No runtime, public-book,
  policy, protocol, or admission edits. Codebase/book remains No; `.3.2.39` follows.

### Legacy plugin and progressive invocation authority ownership at `.3.2.39`

- Activated from clean `34af111fcd5be5f5e09fd89b516a0782a20c20f8` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read PluginBridge 1–199, PluginRegistry 1–130, ProgressiveSpanDispatch 1–230 / 231–460 / 461–700 /
  701–937, Policy 1–58, and Runtime 1–172 without truncation while the preceding checkpoint hooks completed.
  Activation then verified the clean boundary and exact unchanged baseline: 1,496 lines / 52,208 bytes.
  This checkpoint adds no duplicate physical-reading credit over intake `.31`.
- Retrieved plugin transition and progressive authority/carrier/recurrence/public Knowledge before source
  work; then completed the large audit-plan card in two bounded reads after a combined output truncated. Read
  ADR 0080 in full and the relevant neutral policy/fixture/checker and test ranges for the ceiling question.
- PluginBridge validates explicit names, normalizes AUTOLOAD suffixes, resolves registered callbacks first,
  and lazy-loads legacy fallback through OwnerDispatch. PluginRegistry owns process-local registration,
  replacement, sorted bulk iteration, lookup/presence, and clearing; no transactional bulk claim is inferred.
  An isolated public facade control verifies two registrations, argument-preserving dispatch, callback lookup,
  replacement, clear count two, invalid-name rejection, caller error-state preservation, and no PPlugin load.
- Progressive core owns exact immutable entry metadata and copied source state behind opaque object identity;
  source views use scalar coordinates, bounded same-source spans, rebasing, and callback expiry. It checks
  registry/top-rule authority, capability/policy intersections, shared cancellation/deadline/remaining steps,
  decreasing-span/depth/call limits, and transaction exclusion. Result copying preserves booleans and rejects
  cycles/live-looking fields/unsupported references. Policy validates canonical nodes after rule-table creation;
  Runtime requires exact host options, fresh invocation state and localized descriptors, and defers live
  recognition-transaction lookup until dispatch. Scalar/list/void callback context is preserved.
- Six small private-authority controls show computed ceilings are weaker than enforced limits. With ten
  remaining steps and effective max_steps/max_result_nodes one, cost two and [1,2,3] both succeed; cost eleven
  still rejects against remaining budget. A callback can read its source view with detail none, and a thrown
  57-byte diagnostic retains source text with diagnostic ceiling eight. Exact callback effective metadata
  agrees with the supplied minima. Source roots are the remaining-only cost check, uncounted result copier,
  and raw child-error text copy; the effective fields are calculated but not used at those boundaries.
  Callback input visibility needs authority review distinct from outward diagnostic containment.
- `.37.1` owns resource census and bounded repair decomposition, `.37.2` diagnostic/source-detail repair,
  and `.37.3` decision/book/Knowledge plus recurring closeout. One new and four updated Knowledge records
  preserve the controls, qualify universal claims, and keep historical admission evidence dated.
- Managed `prove -q -Iperl t/progressive_span_dispatch_perl_authority.t
  t/progressive_span_dispatch_perl_contract.t` passes 138 top-level tests. The managed neutral checker passes
  9/9/116 and public 6/12/10/60. These finite fixtures do not close `.37`. Other runtime consumers, legacy
  fallback execution, and full Phase 0 are not rerun. No runtime, public-book, protocol, policy, or admission
  edits. Codebase/book remains No; `.3.2.40` follows.

### Recognition snapshots, token lifecycle, and static effect closure at `.3.2.40`

- Activated from clean `800fc5a4598de78b235dffaf1cdbde9e28e13c27` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read RecognitionTransaction 1–230 / 231–460 / 461–655 and Policy 1–140 / 141–269 without truncation
  while the preceding checkpoint hooks completed. Activation then verified clean HEAD and exact unchanged
  baseline identity: 924 lines / 33,632 bytes. No duplicate physical-reading credit over intake `.31`.
- Retrieved private authority, integration, known lexical/compilation-order defect, and public-closeout
  Knowledge before source reading; then read the neutral Knowledge owner and relevant token/fixture ranges.
  The core keeps source/invocation/generation/token records behind opaque handles, stages acceptance separately
  from payload, copies cursor/boundary/mark snapshots, and cleans active transactions on leave/destruction.
  Rejected recursive-observation identities reserve monotonic ids without entering another frame.
- Static Policy checks transaction shape and IF-family terminal path counts before recursive effect closure.
  Canonical CALL/RECOGNIZE_ONCE and dependency references feed a fixed point over closed effects; missing
  callees, fallback/unresolved helpers, and unknown nodes contribute unknown effects. Current progressive/
  staged dispatch nodes remain forbidden. The raw token scan and interpolated /o expression remain known
  `.21` defects; this checkpoint reads their exact mechanism and does not claim repair.
- Six private-authority controls complete commit or rollback, advance owner state to cursor six/boundary
  five/mark m four, then reuse the terminal token. Same-frame cases reject and preserve new state. Both
  cross-frame and cross-source routes reject but restore the obsolete zero/zero/empty-mark checkpoint,
  for four destructive restoration cases across the two terminal kinds.
- Source roots the discrepancy: source/invocation checks precede invalidated-state rejection and call
  `_restore_and_invalidate`; that helper assigns an active owner's snapshot before `_invalidate` notices
  the token was already invalidated. Existing cross-owner tests cover live tokens that should restore.
  These new controls do not prove authored reachability or other-runtime behavior.
  `.38.1` owns all-operation/ownership census and bounded repair; `.38.2` owns neutral/runtime/book/
  Knowledge and recurring closeout. One new and three updated Knowledge records retain exact controls.
- `bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl
  t/recognition_transaction_perl_authority.t t/recognition_transaction_perl_contract.t` passes 59 top-level
  tests across two files. The managed neutral checker passes 138 node rows / 250 calls / 58 mutations,
  9/9 rollout, public 3/26/45, guide 1/14/18, and current backend admission guards. Other runtime consumers
  are not rerun; existing proof closes neither `.21` nor `.38`. No runtime, public-book, protocol, policy,
  or admission edits. Codebase/book remains No; `.3.2.41` follows.

### Recognition integration, runtime observers, and required history rollover at `.3.2.41`

- Activated from clean `e548ce4be5d3164ab8be54dc3d63dece2dda0ffb` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read RecognitionTransactionRuntime 1–230 / 231–460 / 461–681, RecursiveObservationPolicy 1–71,
  RuntimeLogical 1–96, RuntimeDiagnosticOutput 1–247, and RuntimeSemanticObservation 1–174 without truncation.
  The first three owners were read while prior hooks completed; remaining source followed clean activation.
  Exact baseline identity passes: 1,269 lines / 39,210 bytes. No duplicate physical-reading credit over `.31`.
- Retrieved recognition integration, diagnostic/logical/recursive/semantic observation Knowledge before source
  reading; later checked current recursive/typed public closeout and semantic admission. Runtime integrates
  private source-local authority with real cursor/boundary/marks, weak invocation guards, recognition and
  observation scopes, gap snapshots, selected matches, and ephemeral completion records. Static observation
  policy validates a bare target and existing named callee. Nine-field observations separate outcome from payload.
- Eight public Get controls compare direct and recognized true/false/one/zero. Direct booleans retain JSON
  boolean kind, while recognition commit converts them to numeric one/zero; numeric controls agree and all
  contexts have zero errors. `finish_commit` explicitly performs the conversion, and the existing final-path
  consumer expects numeric zero for commit_false. `.39` owns typed-contract review, census, bounded repairs,
  and public/recurring closeout separately from the dynamic-codeblock defect `.35`.
- Four public typed-exit controls retain exact status seven and zero context errors. Exit before the attempt
  and after explicit rollback leaves cursor zero; exit after a successful uncommitted attempt leaves cursor
  two, as does exit after commit. `_finish_guard` lets private leave restore then discards context without
  applying that restored snapshot to actual registers. `.40.1` owns synchronization repair and all-state/
  all-abort census; `.40.2` owns documentation and recurrence. Other register/carrier/runtime outcomes remain
  unmeasured here. This public unwind defect is separate from private post-terminal restoration under `.38`.
- Diagnostic delivery owns typed events, rendering, synchronous sinks, and exact control-error identity.
  Logical truth owns reference/boolean/host-flag distinctions and returns typed booleans; argument laziness
  belongs to lowering. Semantic observation uses separate sink/error slots, decoded-UTF8 versus raw-byte
  input hashing, early no-sink return, and typed event construction; derived-index validation owns trust.
  Reconciled dated recursive-public and semantic-admission pending claims against current neutral evidence.
- Managed Perl recursive-observation, diagnostic-output, logical-helper, and semantic-runtime-observation
  suites pass 137 top-level tests across four files. Typed governance passes 14/0/231 with recursive public
  6/6/10 and combined 8/8/6/10; semantic passes six fixture groups/twenty queries/128 mutations/9 rollout/6
  admission; diagnostic passes 3 helpers/11 render/6 scenarios/8 complete/20 mutations; logical passes
  17 truthiness/10 helper/3 effect/8 complete/19 public documents/14 forbidden claims/26 mutations.
- Required CHANGES rollover follows ADR 0069 at this checkpoint's 90% boundary. The owned capacity review
  uses only the finite file/manifest slots needed, a newly indexed ADR 0104, independent exact clean-source
  preservation, and unchanged byte/root/segment/aggregate limits. Exact measurements follow below before
  staging. This infrastructure boundary requires receipt-bound canonical CI; ordinary prior leaves did not.
  The root reaches 464/512 lines. Segment 4984 preserves clean e548ce4b source lines 248–459: 212 lines /
  19,054 bytes, SHA-256 d720d564937dc8d5f5d14a2942335ec874a481dda01e8824b2956a0742e9c69f, source blob
  daf0f6f1a571377da88009f340a844ff627ff10f. Independent source/blob/hash/count and prior segment-record
  comparisons pass; the header segment count alone increases. An initial ad hoc verifier wrongly treated
  the manifest header as a segment; the corrected schema-aware comparison proves exact preservation.
  After root-only EOF blank-line normalization, current root is 251 lines / 18,276 bytes and manifest
  28 lines / 15,887 bytes. Collection totals 29 files / 48,131 lines / 3,467,471 bytes. ADR 0104 changes
  only max_files 28 to 29 and manifest max_lines 27 to 28; every other pressure control stays unchanged.
- Two runtime defect cards and six updated ownership/status records preserve the focused conclusions.
  History capacity has its separate Knowledge record. No runtime, public-book, protocol, or admission edits;
  codebase/book remains No. The next checkpoint is `.3.2.42`.

### Semantic call/index ownership and complete physical book coverage at `.3.2.42`

- Activated from clean `da8185b94972441b07034eece644cc7efd14dc97` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read SemanticCallProjection 1–240 / 241–500 / 501–753 and SemanticIndex 1–220 / 221–395
  completely during the preceding frozen canonical run. Exact source identity passes: 1,148 lines /
  37,003 bytes. This comprehension checkpoint does not duplicate .31's physical Perl-reading credit.
- Reconciled authored definition ordering, bounded function-shape propagation, typed call traversal,
  function-before-helper resolution, separate staged payload/job/result provenance, shared generated-v2
  identity, and detached private projections. The opaque index retains copied source/outcome/projection,
  delegates queries without parser execution, and derives independent observation snapshots.
  Existing .22 still owns the empty-function early return; no passing snapshot closes that defect.
- Managed foundation/call/query tests pass three files / twenty top-level tests in 39 wall seconds.
  Current neutral semantic proof passes 6 fixture groups / 20 exact queries / 128 mutations / 9 complete
  rollout rows / 6 complete admission rows. The preceding canonical generated-source proof is retained
  against unchanged inputs; no extra full gate is run for this ordinary evidence checkpoint.
- Complete physical mdBook coverage is recorded separately below. Verified current paragraphs were
  compared with existing Knowledge, public controls, exact contract reader/marker/denial loops, and the
  current neutral proof. .41.1–.41.8 own bounded book reconciliation; .28/.29/.30 keep their prior scopes.
  Historical snapshots remain dated. Other lifecycle/helper/representation questions remain assessment
  candidates until exact tools and authority establish their behavior.
- An initial public mode control's error-free assumption failed, triggering complete diagnosis. Nine
  final Get cases cover all eight mode/descriptor combinations plus invalid generate-only source. The
  three descriptor-plus-mode combinations return the compiler's successful undef but acquire a false
  runtime_owner/run_get_pipeline error. parse_only produces no generated source; the other generated
  paths capture 8,806 bytes for the exact small fixture. Invalid source keeps compiler validation
  attribution. Forced parse-only bootstrap output was captured in memory.
- Eight isolated ParserFactory callback controls reproduce the same three false errors at its own
  compile_spec validator and failed trace decision, independently of Runtime. Full Runtime history
  86d6511c7 introduces descriptor-first validation; April 9 c5ba9fe57 renames the checked key from return_descr to return_descriptor without changing priority.
  Compiler checks parse_only, generate_only, then descriptor. .42 owns both validator repairs and full
  public named-source coverage, with exact matrices in its Knowledge card.
- Four input/direct controls return cursor zero for empty input, ordinary non-spec text, and ordinary
  leading space; leading blank/comment input returns eight publicly and zero through the descriptor
  handler. All contexts are error-free. Runtime's one public-entry skip loop and Compiler's scalar-ref
  guard explain why the book's every-handler skip and document-as-spec restrictions are false.
- Forward .3.2.44 diagnosis uses four public Get/query twins: every parser returns seven without
  errors, but explicit header-inline I has zero lifecycle records and following-line I has one.
  Both bare-body controls have no explicit I record. Two outward descriptors have identical public
  metadata and expose no lifecycle body fields. _scan_source recognizes a header and skips its tail;
  lifecycle projection uses only captured members. Source 460–505 / 568–710 and the complete
  155-line static test were read after the public tools. .43 owns exact member/span authority,
  all-six-runtime census, bounded repair and regressions; other runtimes were not measured here.
- The previously consumed macOS progressive-launch sample and eventual passing test are preserved in
  their existing Knowledge owner, with exact sample SHA and exact-path cleanup evidence. It proves the
  sampled pre-main loader boundary, not a newly controlled kernel/policy cause.
- Additional supporting source reads include ParserFactory 1–85 / 275–368, Compiler 1780–1938,
  Runtime 115–154, phase0 9865–9975, .githooks/pre-commit 1–27 (EOF), and
  knowledge-map/scripts/check_knowledge_map.sh 1–90. These are bounded supporting ranges, not full
  verification/tooling lane completion.
- During the preceding long gate, prepared evidence was saved at
  .linkedspec-data/scratch/startup46-preparation-20260906.json: 148,121 bytes, SHA-256
  9617f5c29d41c552f020997afc82083b0c17b8107a8f9d2bb48e2dcc9414dc99, with exact readback.
  It is temporary recovery data, not a substitute for these task/Knowledge/Git records. After this
  checkpoint commits, verify that exact size/hash and delete only that file, then prove its absence.
- No runtime, public-book, policy, protocol, or infrastructure edit occurs. Roadmap and physical mdBook
  reading are Yes; codebase reading is No and formal .4 alignment remains pending. Next .3.2.43 reads
  the query, runtime-projection, and source-map owners.
- The preceding exact staged canonical gate passed at base e548ce4be5d3164ab8be54dc3d63dece2dda0ffb,
  candidate SHA-256 494bab842b8b16dc553c8de43ff97ca5d2e0fa3a147f103d6bf8d3fdc624f0e4.
  Both primary CLI environments pass 66/66; Phase 0 passes 1,032 tests in 1,051 wall seconds.
  The default gate exited zero; optional local gates and recurring matrices were not enabled.
  Commit da8185b94972441b07034eece644cc7efd14dc97 exists after the configured pre-commit gate;
  the repeated post-commit pointer and exact promoted HEAD receipt pass, and the brief is zero bytes.
  The final commit-command output was lost across context compaction, so its stdout is not claimed.

### Complete physical mdBook reading preserved at `.3.2.42`

The `.3.2.41` staged canonical candidate remained frozen while read-only preparation completed every
remaining book range. The fourteen complete files and two partial ranges of one local-CI file recorded
under `.31` account for 640,041 bytes; this pass adds exactly 1,316,541 disjoint bytes. All 50 tracked
book files, including configuration and SUMMARY, are fully read: 1,956,582 bytes. These are file counts,
not fifty prose chapters. The earlier two partial ranges do not mean two partial files.

Every chapter was consumed in bounded untruncated outputs. Final independent verification reconciles all
64 interval records, their SHA-256 digests, contiguous complete line coverage without overlaps or holes,
the exact 50-path set, and current bytes against reading baseline
`baeb984e36a94a15951cd23d4c52def5064cdaca`. All checks pass. Git plus this complete path/range ledger
remains the inventory; no duplicate manifest is introduced. Previously truncated outputs received no
credit until their exact ranges were reread.

The following thirty-six files now join the fourteen complete files listed under `.31`. Every range is
1 through the stated EOF. The local-CI row includes its two earlier partial ranges exactly once.

| Book path below `docs/linkedspec-book/` | Full lines; bytes |
| --- | ---: |
| `src/overview/design-rationale.md` | 259; 16,310 |
| `src/overview/project-status.md` | 1,641; 182,688 |
| `src/user-model/spec-files-and-rule-paragraphs.md` | 318; 13,457 |
| `src/user-model/worked-spec-walkthrough.md` | 342; 12,718 |
| `src/user-model/rule-modes-and-parse-modes.md` | 896; 39,736 |
| `src/user-model/regex-in-spec.md` | 290; 13,692 |
| `src/user-model/blind-calls-and-parser-orchestration.md` | 469; 13,945 |
| `src/user-model/runtime-context-and-tracing.md` | 625; 25,247 |
| `src/public-api/get-and-get-parser.md` | 682; 31,740 |
| `src/public-api/descriptor-introspection.md` | 642; 31,584 |
| `src/dsl/action-model-and-helper-surface.md` | 228; 11,189 |
| `src/dsl/actionir-lowering-mental-model.md` | 193; 9,901 |
| `src/dsl/declaration-helper-reference.md` | 93; 2,612 |
| `src/dsl/fluent-and-block-forms.md` | 541; 17,474 |
| `src/dsl/capture-marks-and-source-locations.md` | 1,431; 93,808 |
| `src/dsl/source-boundary-helper-reference.md` | 648; 34,135 |
| `src/compiler/pipeline-overview.md` | 637; 43,440 |
| `src/compiler/staged-ast-enrichment.md` | 958; 57,285 |
| `src/compiler/compiled-state-model.md` | 289; 15,178 |
| `src/compiler/generated-handlers-and-dispatch.md` | 525; 31,655 |
| `src/compiler/diagnostics.md` | 267; 12,299 |
| `src/specs-and-corpora/shipped-specs-and-corpora.md` | 334; 16,423 |
| `src/specs-and-corpora/lispish-spec-walkthrough.md` | 425; 9,522 |
| `src/specs-and-corpora/ebnf-spec-walkthrough.md` | 786; 23,758 |
| `src/specs-and-corpora/tablegrep-spec-walkthrough.md` | 96; 4,959 |
| `src/specs-and-corpora/portmap-spec-walkthrough.md` | 118; 4,746 |
| `src/specs-and-corpora/pplugin-spec-walkthrough.md` | 101; 5,894 |
| `src/architecture/owner-tree.md` | 625; 45,849 |
| `src/architecture/structured-format-program.md` | 178; 11,906 |
| `src/appendix/formal-grammar.md` | 1,308; 71,322 |
| `src/appendix/runtime-semantics.md` | 759; 37,484 |
| `src/appendix/backend-handoff.md` | 2,923; 217,400 |
| `src/development/local-ci-and-regression.md` | 2,048; 146,113 |
| `src/development/macos-rust-launch-latency.md` | 26; 1,686 |
| `src/development/codegen-inspector.md` | 53; 2,518 |
| `src/development/documentation-workflow.md` | 232; 10,360 |

Physical reading is Yes; `.4` remains pending formal alignment with the unread codebase and review of
subsequent changes. `.41.1`–`.41.8` own the additional book repair lanes, coordinated with existing
`.28`/`.29`/`.30`; `.42` owns the independently reproduced combined-mode validator defect.
Verified paragraph/checker mechanisms and exact public controls live in
`docs/knowledge/startup-public-teaching-checker-blind-spots.md` and
`docs/knowledge/perl-get-mode-result-validation-precedence-drift.md`.
Other lifecycle/helper/representation assertions remain explicitly bounded assessment candidates,
not unmeasured runtime defect claims. No public-book, runtime, or policy changes occurred.

### Semantic query, observation, and source-map boundaries at `.3.2.43`

- Activated from clean `dde05b657eea91fd03b6ae14dfc2366156942583` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read SemanticQuery 1–230 / 231–440 / 441–596, SemanticRuntimeProjection 1–214, and
  SemanticSourceMap 1–172 completely during the preceding frozen canonical run; the two smaller
  owners were reread while the preceding checkpoint's hooks ran. Current exact baseline identity
  passes for all three owners: 982 lines / 35,427 bytes. This does not duplicate .31 physical credit.
- Query validation receives cloned plain data, canonicalizes operation-specific paging/traversal and
  evidence selection, and applies source/digest ceilings at the outward boundary. Source mapping
  validates strict UTF-8 text/byte equivalence, exact character boundaries, LF-based coordinates,
  and ASCII integer ranges. It keeps source authority private rather than deleting it at construction.
- Derived runtime projection validates exact native event shape, one final successful entry result,
  and selecting-rule/regex-slot topology before cloning static state and appending ordered records.
  It uses static shapes; existing .20 owns Unicode-digit validation concerns.
- Compared explain accounting with neutral evaluator 1158–1245: both reserve the decision record
  and use the remaining record budget for evidence, then derive explained_by relations and depth-one
  cost. This resolves a proposed Perl-only discrepancy; it does not establish an unmeasured broad
  request contract or a new defect. Relation traversal retains separate multi-budget accounting.
- The prior exact canonical gate at da8185b9 passes query 9, runtime observation 106, foundation 5,
  and neutral 6 fixtures / 20 queries / 128 mutations, with 9/9 rollout and 6/6 admission. Source,
  those three test files, the neutral checker, and model are byte-identical to that candidate. Existing
  proof is retained; no unnecessary new full gate or unchanged runtime test repetition occurs.
- Four Knowledge owners now record source-map/derived-projection comprehension and qualify July
  rollout, capability, Phase 0, and four-backend privacy milestones as dated history. Current counts
  are explicitly tied to the consumed September 6 canonical evidence.
- After .3.2.42 committed as dde05b657eea91fd03b6ae14dfc2366156942583 with nine passing doctrines
  and a passing post-commit pointer, its brief was cleared and Git was clean. The exact 148,121-byte
  preparation spool matched SHA-256 9617f5c29d41c552f020997afc82083b0c17b8107a8f9d2bb48e2dcc9414dc99
  and expected owners before deletion. Only that file was removed; absence was rechecked here.
- Roadmap and physical book reading remain Yes; codebase reading remains No and formal .4 alignment
  stays pending. This checkpoint changes only task/Knowledge/live continuity; .3.2.44 is next.

### Static semantic evidence and precise failure classification at `.3.2.44`

- Activated from clean `7a97647c9317bdd60b8aa7de0986ecf837bccdfb` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read SemanticStaticProjection 1–235 / 236–460 / 461–700 / 701–880 / 881–1067 completely
  during the frozen canonical run. Exact current baseline identity passes: 1,067 lines / 34,029 bytes.
  The complete 155-line static test was read; its five top-level tests passed in the preceding canonical
  candidate and the current source/test bytes are unchanged. This does not duplicate .31 physical credit.
- Reconciled descriptor-authoritative compiled topology, source-authoritative authored forms and spans,
  independent duplicate/indexed regex identities, private source retention, function masking, canonical
  record/relation ordering, and call-projector delegation. Existing .22 and .43 retain their known gaps.
- Reverified .23 through public Get and public list queries. The first minimal fixtures selected
  recognition_attempt_count and explicit-arrow final descriptor failure, not the original intended escape
  and bare missing-rule cases; both nevertheless show the same false dependency classification. The
  corrected two-case matrix reaches recognition_token_escape and bare_edge_target_undefined exactly.
- For the escape, the semantic diagnostic retains recognition_token_escape and the original message.
  A separate dependency_resolution decision and dependency_target_missing explanation invent a blank
  target and emit the line-418 uninitialized warning. The bare missing-rule control correctly maps to
  unknown_rule_reference, preserves Missing source bytes 6–13, and emits no warning. Forced compile
  logs were captured in memory. The original whole-diagnostic-replacement wording was too broad;
  this measured correction refines .31 and the existing .23 acceptance without claiming a repair.
- After public tools, reread failed-projection 294–436 and compiled components 437–508. The code
  retains supplied diagnostic code/summary with one intentional bare-edge mapping, then unconditionally
  creates dependency decision/explanation rows. Exact matrix, warning, and source evidence are in the
  existing compile-failure Knowledge card. No generated/MCP/backend behavior was remeasured here.
- The earlier four explicit/bare inline/multiline controls and two outward descriptors remain valid:
  every parser returns seven, but only explicit multiline I yields its lifecycle record. .43 owns the
  header-tail scanner repair; bare controls do not justify inventing an explicit marker.
- TOOLBOX section 1 still directs rejection of the already-supported bare block. The current lifecycle
  Knowledge/ADR contract and earlier public controls establish the stale instruction. The standalone
  checker passes 9 placements / 4 duplicate forms / 6 ownership cases / 3 malformed twins / 6 routes /
  15 public documents / 7 denials / 14 mutations; its exact 15-path reader omits TOOLBOX. Reader 1–90
  and contract-validation 144–164 were read; public-contract JSON was fully inspected. .41.6 now owns
  correction and claim/path coverage. Other lifecycle assessment candidates remain unverified.
- Three existing Knowledge records preserve these boundaries. Supporting test reads include recognition
  authority 252–292, contract 295–318, and the small semantic failed.spec fixture after public controls.
  Required roadmap/physical-book reading remain Yes, codebase No; formal .4 and all repairs stay pending.
  No runtime, public-book, TOOLBOX, checker, policy, or protocol edits occur. Next .3.2.45.

### Typed source authority and compatibility projections at `.3.2.45`

- Activated from clean `78e0ee6b1d719a1113bf6ad0e351d890fb88ea52` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read SourceLocation 1–240 / 241–475 / 476–700 completely during the frozen canonical run,
  then reread all 1–215 / 216–475 / 476–700 while the preceding checkpoint's hooks ran. Exact
  baseline identity passes: 700 lines / 21,209 bytes; .31 physical credit is not counted again.
- The authority snapshots decoded source and scalar-boundary line/column/strict-UTF-8 byte evidence.
  Separate inside-out value stores retain monotonic authority identity and detached position/span/derived
  records without live authority or text references. The authority validates and materializes, copies
  ordered provenance, and preserves four structured value errors with privacy-filtered context.
- Runtime helpers reuse match-info authority while preserving scalar cursor/mark storage, primitive
  results, absence values, and existing shallow capture-container copies. Nonnegative in-bounds slices
  materialize typed spans; other starts/widths deliberately retain host substr compatibility. This is
  existing behavior, not an expanded typed authoring or deep-copy contract.
- Retrieved the canonical typed-source Knowledge home before reading, then reconciled its relevant
  160–245 Perl/boundary and 275–290 final-closeout sections plus metadata. A prior truncated whole-card
  output is not credited as complete reading of unrelated backend history. The existing near-capacity
  home now links to a focused compatibility card; its general authority record remains canonical.
- The prior exact canonical gate at da8185b9 passes typed values/projections/recursive observation:
  three files / eighteen tests / twenty-eight wall seconds, plus neutral 14 complete / 0 pending /
  231 mutations. Current source, all three test files, checker, and contract are byte-identical;
  retained proof suffices for this unchanged-source reading checkpoint. CI registration 810–820
  was read to confirm the exact three-suite boundary, without claiming a complete tooling-lane read.
- Pre-commit correctly rejected a 67,175-byte Knowledge card against its unchanged 65,536-byte cap;
  its clean-HEAD size was already 65,511. Routed new compatibility detail to
  docs/knowledge/perl-source-location-slice-compatibility.md, kept a direct parent link, and replaced
  the duplicated long reverify recipe with the existing six-authority composition command. The complete
  33-line driver was read; this is documentation routing, not a newly run combined gate or limit change.
- No new defect or behavior change is established. Roadmap and physical mdBook remain Yes; codebase
  remains No and formal .4 alignment/repairs stay pending. Next .3.2.46 reads staged AST authority.

### Staged authority and bounded marker-lifetime investigation at `.3.2.46`

- Activated from clean `cd0a1babed392001c5d372a39e84a96d0b979bc0` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read StagedASTEnrichment 1–225 / 226–455 / 456–690 / 691–925 / 926–1165 /
  1166–1375 / 1376–1498 completely during the frozen canonical run. Exact baseline identity passes:
  1,498 lines / 49,952 bytes. The suffix remains .3.2.47-owned; no duplicate .31 physical credit.
- Retrieved and fully read marker/provenance, current-depth, recursive, and carrier Knowledge owners.
  Reconciled pure pre-registered resolution, normalized top/job/cache identity, policy narrowing, complete
  target preparation, typed ordering, fresh callback state, bounded detached results, all stitch/failure
  modes, breadth-first recursion, active-chain decrease checks, shared resources, and source rebasing.
  Corrected the recursive card's stale deliberately-unrouted phrase to its admitted carrier boundary.
- A typed-path numeric-string concern was resolved by the already-read suffix's JSON-kind-aware integer
  predicate; string keys and integer indices remain distinct. No corresponding defect is claimed.
- Investigated whether retired marker addresses could be confused with new markers. The public Get
  parent uses the exact admitted assignment carrier; callbacks create decreasing payload markers with
  enough limits for 24 calls. Sixteen ordinary allocation trials, four weak-reference trials, and four
  trials allocating up to 128 candidate markers each step all complete 24 calls, return done, and retain
  no error. Actual address reuse was not observed. Unretained weak references show only the current
  child alive during each later callback and zero remaining after completion; held controls retain 23.
- An isolated local substitute for only the scheduler's imported marker refaddr preserves distinct live
  identities and reuses a numeric slot only after its weak reference clears. Two unretained trials stop
  at three calls with an unprocessed Marker and no error; two retained-marker controls finish 24.
  This is a controlled identity-lifetime counterexample, not observed native allocator reuse. The
  intentional local symbol replacement produces Perl's used-once compile notice in the harness only.
- After public controls, reread scheduler 151–225 / 324–570 / 785–815: processed/lineage scalar keys
  outlive released marker objects and skip a returned identity already marked processed. Supporting
  suffix reads 1645–1738 / 1770–1858 and StagedParseJob 80–130 / 314–352 clarify detachment and
  actual private destructor ownership. .44 owns stable-identity repair, independent regressions, and
  other-backend census; no installed runtime, test, protocol, book, or contract was modified.
- One new risk card preserves all four exact commands and result boundaries; three existing staged
  Knowledge owners link current semantics and unchanged proof. The prior canonical staged Perl consumer
  passes 143 tests and neutral proof is 9/9/123 plus public 6/17/10/129. Current source, consumer,
  checker, and contract bytes match the measured candidate; no new full gate was run.
- Supporting consumer reads cover 1–241 / 245–279 / 1393–1522 / 1875–2020, with the exact
  resolution snapshot fully inspected. The complete Runtime seam 1–120 was read; its formal checkpoint
  remains next. These supporting reads do not close the overall test/tooling/native reading lanes.
- The preceding Knowledge containment correction committed as cd0a1babed392001c5d372a39e84a96d0b979bc0
  after all nine doctrines and the post-commit pointer passed; its brief is empty and activation was clean.
  Roadmap/physical mdBook remain Yes; codebase No and formal .4/repairs remain pending. Next .3.2.47.

### Staged suffix, runtime, marker policy, and legacy registry at `.3.2.47`

- Activated from clean `7c2d6ee0d54350667b5cf15c4d634bb9d3efe9d2` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Completely reread StagedASTEnrichment 1499–1760 / 1761–2013, Runtime 1–120,
  StagedParseJob 1–352, StagedParseJobPolicy 1–59, and StagedParserRegistry 1–328. All five
  ranges retain exact baseline identity: 1,374 lines / 43,289 bytes. This closes the queued
  comprehension checkpoint; the physical bytes were already credited in .31.
- Retrieved and fully read the registry/dispatch, function-body-v1, marker/provenance, and general-v2
  boundary Knowledge owners before reconciling mechanisms. The legacy registry normalizes and sorts
  one collected depth, invokes resolve/load/compile/execute for every job, and records a cache key;
  it contains no memoized compiled-plan cache. Its policy strings are transport metadata until the
  separate trusted function-body stitch. General v2 remains a separate caller-frozen authority.
- Read exact runtime configuration keys, fresh per-invocation authority, preserved cancellation/clock
  identities, cloned ordinary configuration, input-reference identity, transaction-active lookup,
  and post-parent enrich_recursively. Marker state is detached into a private side table and deleted
  on destruction; materialized source data retains no source authority. Static policy validates only
  dedicated marker events and reports the first declaration diagnostic.
- Read target identity checks, typed paths, all stitch modes, child diagnostic sanitization/rebasing,
  bounded plain-result detachment with allowed opaque markers, cycle rejection, exact job digests,
  JSON-kind-aware integer checks, expiring execution context, and private error/authority cleanup.
  Existing .44 owns retired marker identity risk; no additional failure or native reuse is claimed.
- Exact current Perl source, staged/phase0 consumers, staged checker, and neutral contract match the
  consumed da8185b9 canonical checkpoint. Retain its Perl 143, neutral 9/9/123, public 6/17/10/129
  and Phase 0 1,032 results without rerunning unchanged runtime suites or treating them as new proof.
- The prior leaf committed as 7c2d6ee0d54350667b5cf15c4d634bb9d3efe9d2 after all nine doctrines and
  post-commit pointer passed; brief was cleared and clean status verified before activation.
  Roadmap/physical book remain Yes, codebase No, formal .4 and tracked repairs pending. Next .3.2.48.

### Trace owner and exact lazy exception-state boundary at `.3.2.48`

- Activated from clean `6654c0dfd057112c3942f06635926c4dd4625985` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read Trace 1–260 / 261–521 completely: 521 lines / 16,259 bytes, SHA-256
  f8041e80c7f8342a0497710b130a14085c3dddd0d1ee67eeb04f51dd196ffe22, exact baseline equality.
  This is comprehension reconciliation of physical reading already preserved in .31.
- Retrieve Trace formatting/control, generated branch helper, lazy exception-state, OwnerDispatch,
  and facade Knowledge before tracing the seam. Read TOOLBOX trace guidance, the complete 130-line
  branch-helper test, OwnerDispatch 1–115 / 195–225, and HandlerVariantEmitter 580–625 as support.
- Twenty managed in-memory controls cross direct/OwnerDispatch calls, incoming string/object errors,
  and quiet/plain/success/throw/nested detail. Direct quiet/plain preserve state; direct success/nested
  clear it, throwing detail replaces it. Every wrapped call preserves the incoming value/object identity.
  All branch results remain true, quiet emits nothing and calls zero callbacks, active callbacks run once,
  and throwing/nested details are present. Exact command/results live in the existing .24 Knowledge card.
- The helper test's outer eval proves non-escape and branch-result retention, not preservation of an
  incoming exception. Narrow the existing broad parser-behavior claim and make .24's acceptance distinguish
  protected wrappers from direct generated-owner calls. Do not infer unmeasured parser-context failure.
- Current focused proof: three generated helper/nonrep/rep suites pass 11 top-level tests in 23 seconds.
  Trace/Perl dependencies, primary CLI and conformance consumer bytes are unchanged from da8185b9.
  Its two 66-case CLI environments remain retained prior proof; qualify the CLI card's old July 61-case
  and Rust-next wording as historical rather than rerunning unchanged canonical CI.
- Confirm configuration/environment precedence, scope indentation, escaped mark excerpts, sink routing,
  lazy Data::Dumper through the preserving seam, and log_dump's explicit enforce_level distinction.
  No runtime, tests, public book, protocol, sink policy, or contract changes. .24 remains pending.
- Prior commit 6654c0dfd057112c3942f06635926c4dd4625985 passed all nine doctrines/post-pointer;
  brief was cleared and clean status verified before activation. Roadmap/physical book Yes; codebase No,
  formal .4 and repair prerequisites remain pending. Next .3.2.49.

### First generated Unicode table range and authoritative regeneration at `.3.2.49`

- Activated from clean `69e221bf67d8a3289dd3f0ade35e52ff8d1b9f25` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Intake .31 already physically consumed every byte of UnicodeCaseMapping 1–1500 in smaller
  complete ranges. Reconcile that durable reading without duplicate physical credit. Current range is
  1,500 lines / 32,073 bytes, SHA-256 a75e182640627d042dd282ef7257d5ae1ec20431abad1a7fb316498b6abd02a1;
  entire source remains baseline-identical. The suffix checkpoints remain separately pending.
- Retrieve the Unicode data, Perl/Rust, Dart/Julia, and six-runtime parity Knowledge owners plus ADR
  0027. Read the entire current 287-line checker and 88-line Perl consumer; revisit generated header
  1–110, the 1490–1505 seam, and evaluator 3790–3835 as supporting comprehension of pinned data.
  This does not credit unread upstream/generator/native files or close their future reading lanes.
- Current managed offline checker regenerates JSON plus Perl/Rust/Dart/Julia/Lua source in an owned
  temporary directory and byte-compares all six files; its independent evaluator passes 12 fixtures.
  Counts remain 1,563 lower / 1,581 upper mappings, 158 Cased / 464 Case_Ignorable ranges. Update
  two Knowledge bodies that still described only the earlier Perl/Rust generated-file coverage.
- Current managed Perl consumer passes 52 tests in 13 seconds across direct conversions, compiled
  helper/receiver/array forms for all fixtures, three pinned metadata fields, and emitted dependency text.
  The dependency assertion is not fresh-process generated execution. Other backend native consumers
  are not rerun. No table/generator/data/version/locale/normalization or public-book changes occur.
- Record that first-fragment lower mappings include full dotted-I combining output and intentional
  identity mappings; tables are generated authority, not hand-maintained edits. Hash checks establish
  current identity; prior complete reading establishes coverage. No new defect is claimed.
- The prior leaf committed as 69e221bf67d8a3289dd3f0ade35e52ff8d1b9f25 with nine doctrines/post-pointer
  passing, brief cleared, and clean status before activation. Roadmap/physical mdBook Yes; codebase No,
  formal .4 and repairs pending. Next .3.2.50.

### Middle generated Unicode range and precise reading status at `.3.2.50`

- Activated from clean `a32114213ec20ab003551fc428566b345c3cc8dd` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- The complete 1501–3000 physical reading is already durable under .31. Reconcile its 1,500 lines /
  32,854 bytes with exact baseline SHA-256 02b460974dd06064b0af0ea3ac7ff1164ffc53e2ee71c1721dd5a4f652c68f1f.
  Revisit the 1501–1625 lower/upper seam and 2988–3005 boundary; no duplicate coverage credit.
- This range finishes lower mappings and opens the upper table. Full sharp-s expansion is intentional
  under ADR 0027. Contextual property ranges and evaluator remain the next checkpoint, with earlier
  supporting reading retained. No data, generator, normalization, locale, or behavior change occurs.
- Exact table, generator/upstream, neutral contract, checker and consumer bytes match a3211421.
  Retain its consumed five-module regeneration/12 neutral fixtures and 52 Perl tests; no fresh peer
  execution or unchanged-suite rerun. Update the canonical Perl/Rust Knowledge with the precise range.
- Retrieve startup inventory Knowledge and clarify its stale book-reading status: physical mdBook
  reading is complete across 50 files under .31/.3.2.42; formal .4 alignment is still pending.
  Codebase reading remains No and no unread first-party input receives credit.
- Prior a32114213ec20ab003551fc428566b345c3cc8dd passed all nine doctrines/post-pointer;
  brief cleared and clean status verified before activation. Next .3.2.51.

### Final Unicode properties and scalar casing evaluator at `.3.2.51`

- Activated from clean `78b272ec9e307092bee162dfdae87abbef778c18` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile .31's complete physical reading of UnicodeCaseMapping 3001–3835: 835 lines /
  17,404 bytes; exact baseline SHA-256 319a14861db1ff096bb78caecd6bc307fd1a0e38c2bd86680adefc64d8e8b31f.
  The three checkpoints now account for the complete 3,835-line / 82,331-byte file without gaps or
  duplicate physical credit. Revisit 3150–3180 / 3310–3342 / 3770–3835 to reconcile property seams.
- Canonical Unicode Knowledge and ADR 0027 bind full mappings, original-input Final Sigma context,
  binary-searched Cased/Case_Ignorable ranges, scalar iteration, identity fallback, and no normalization.
  Decode and read the exact algorithm/context records and all 12 neutral fixtures, including six
  sigma controls. This is not full reading credit for the large neutral JSON or generator.
- Current table/generator/upstream/contract/checker/consumer bytes remain unchanged from a3211421;
  retain its five-module byte regeneration, 12 neutral fixtures, and 52 Perl tests. No fresh native
  peer, generated-process, input-kind, locale, or normalization claim is added.
- Read-only preflight of the preceding .3.2.50 candidate measures task storage at 100 files /
  76,699 lines / 7,789,885 bytes against 128 / 80,000 / 8,388,608. General task-member limits
  are 8,000 lines / 1,048,576 bytes; special 5,000-line caps are future-parity-only. Record the
  dated census in inventory Knowledge; remeasure resulting storage before the native ownership split.
- Prior 78b272ec9e307092bee162dfdae87abbef778c18 passed nine doctrines/post-pointer; brief cleared
  and clean status verified before activation. Roadmap/physical mdBook Yes; codebase No and formal
  alignment/repairs remain pending. Next .3.2.52.

### Generated XID classifier and named-slot identity at `.3.2.52`

- Activated from clean `bea31562b2548eb2d1faf896edace1c3e918f00c` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile .31's complete 855-line / 17,340-byte UnicodeXIDContinue reading. Exact baseline
  SHA-256 is db2185e0a2366849c126d76b27ad5591eee9463ea5e825e815e9feabe97b8947. Revisit
  header/ranges 1–80 and predicate tail 815–855 without duplicate physical credit.
- Retrieve Unicode rule-label and self-hosted-boundary Knowledge, ADR 0051, gap origin/executable-plan
  and closed recurring/public Knowledge. Read direct consumers Validation 550–610 / 695–722 and
  RuleIR 548–585. They use complete-string XID membership, then independently reserve ASCII digit-only
  slot names. The production point predicate receives unpacked scalars; arbitrary numeric-string
  internal-point input is not admitted by this evidence. .20 retains its separate numeric review.
- Read checker support 1–99 / 157–242 / 285–316 and decode the actual policy plus positive,
  negative, and distinct fixture fields. This does not close the remaining 992-line checker, large
  neutral JSON, generator, self-hosted grammar, or native reading lanes.
- Managed current Unicode checker passes 806 ranges, nine positive/eight negative fixtures, two
  distinct pairs. A separate direct Perl control executes 3,224 range endpoints/adjacent gaps,
  all 17 fixtures, and both exact-identity pairs without warnings. Exact command is durable in
  Unicode Knowledge. Classifier execution is distinct from checker byte/topology assertions.
- Correct three canonical Knowledge owners: the Perl classifier's named-slot reuse; stale gap-origin
  pending-public status; and executable-plan future entry_slot/admission wording. Preserve dated
  implementation chronology explicitly. Fresh gap governance passes 9/0/63 plus public 8/15/10/34;
  source, consumers, checker and contract match da8185b9, retaining its Perl124 rather than rerunning it.
- No runtime, tests, generated tables, language policy, or public-book changes. Prior
  bea31562b2548eb2d1faf896edace1c3e918f00c passed nine doctrines/post-pointer; brief cleared and
  clean status verified before activation. Roadmap/physical book Yes; codebase No and .4/repairs pending.
  Next .3.2.53.

### Function metadata and legacy plugin/path configuration at `.3.2.53`

- Activated from clean `bdf491a56b9ce6461a6e3ed2c924de6e0af9e2eb` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Completely reread UserFunctionRegistry 1–200 / 201–390 / 391–580 / 581–773, PPlugin 1–331,
  PathSearch 1–47 and env.conf 1–51. All four baseline identities pass: 1,202 lines / 45,829 bytes.
  Physical coverage was already credited under .31; this closes its queued comprehension checkpoint.
- Retrieve registry, spec-owned parser, variadic, final-codeblock, and plugin boundary Knowledge.
  Reconcile cached spec-owned definition parsing and restored loading guard; exact fixed/v2 signatures
  and typed final metadata across body records; deterministic ordinal job identity; narrow staged body
  dispatch; collisions/parameters; and newline-preserving stripping. Outward typed codeblock v3 is
  separate from internal fixed-v1 metadata and the version-1 registry container.
- Read all 174 lines of the variadic consumer plus codeblock metadata subtest 346–397. Current
  managed suites pass 76 top-level tests in 29 seconds; neutral signature 3 definitions/9 calls/7
  invalid definitions and codeblock 7/11/9/7/4/8/23 pass. No full codeblock-test reading credit or
  new generated-process claim is inferred from the variadic emitted-text assertions.
- Git counts 13 tracked .plg files, all parked under noncore/plugin; correct the older 19-file
  current claim. Default legacy discovery uses cwd and root plugin/, ordered files, and a cached
  registry. PathSearch caches recursive directories and hash-deduplicates matches without a stable
  precedence guarantee. env.conf retains legacy program/system-tool settings. Neither broad legacy
  discovery nor configured callbacks/services/cleanup are executed. Prior registered bridge proof
  remains supported by unchanged bridge/registry/facade bytes.
- No runtime, grammar, descriptor, configuration, or public-book changes. Prior
  bdf491a56b9ce6461a6e3ed2c924de6e0af9e2eb passed nine doctrines/post-pointer, then brief/clean checks.
  Roadmap/physical book Yes; codebase No and formal alignment/repairs remain pending. Next .3.2.54.

### Legacy comparison, HTML rendering, and constraint conversion at `.3.2.54`

- Activated from clean `bd0573533e45fdd903255fb959e3c1f7e5971a27` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Completely reread gdcheck 1–225 / 226–431, htmlcss_driver 1–166, and ptchange 1–242:
  839 lines / 22,702 bytes. Exact baseline identities pass; the three raw 0xb5 comment bytes are escaped
  in the reading output without source conversion. Physical coverage was already preserved by .31.
- Retrieve .25/.26's canonical diagnostic cards before interpretation. Three managed syntax checks pass;
  nine fresh assertions reproduce four signed-tolerance twins, duplicate removal/addition, and DEFAULT
  cardinalities zero/one/two. These assert observed defects, not desired behavior. Persist the exact command
  in the existing gdcheck card. Retain prior argv-list ptchange evidence after exact source identity.
- Reconcile key/column masks and config readers; HTML class/custom-color emission, sorted scripted cells,
  added/removed script dispatch, and table-order output; false-path mixed pin/port Cartesian expansion,
  untouched-span reinsertion, and conditional clock-script output. No HTML callbacks or ptchange output
  workflow is executed by syntax checks. Existing repairs .25/.26 remain pending.
- Own .3.2.55 before writing the next pointer: independently close Perl coverage and decompose all Rust
  bytes with pressure proof and canonical CI. No new Rust reading credit is claimed. The Perl parent stays
  active until that closeout; all other codebase lanes and .4/.5 remain incomplete.
- Prior bd0573533e45fdd903255fb959e3c1f7e5971a27 passed all nine doctrines and post-pointer verification;
  brief was zero and tree clean before activation. No runtime, configuration, or public-book changes.

### Perl parent closeout and exhaustive Rust reading ownership at `.3.2.55`

- Activated from clean `888d8ca20983667ef427446e8fddf03f6eb5c8a2` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Activated from the completed utility checkpoint; independent source-interval verification covers all
  89 Perl files / 2,133,690 bytes through EOF once, with no missing path or current delta. All 54 preceding
  checkpoint subjects exist in Git: 53 source-reading leaves and one decomposition checkpoint. Their
  largest budgets are 1,500 lines/fragments and 65,506 bytes. .31's physical ledger and each comprehension
  checkpoint remain the evidence; enumeration alone is not substituted for reading.
- Close only the Perl reading parent. Existing repair owners .7–.30 and .32–.44 remain pending; no
  runtime, public-book, policy, or whole-codebase completion is claimed. Roadmap and physical mdBook are
  Yes; other source lanes and formal .4/.5 reconciliation remain incomplete.
- Own all 412 baseline Rust paths / 3,533,382 bytes in .3.3.1–.3.3.66, with .3.3.67 parent closeout.
  Independent candidate and rendered Scope audits require exact contiguous/disjoint coverage, current
  baseline identity, both empty corpus inputs, and each hard budget. Total 89,242 lines/fragments includes
  the split MCP logical line; it is not a distinct-line count. Remove the draft's standalone header-only
  group by keeping all six header lines with the first MCP payload window; the final plan has 66 groups.
- Inspect split context, distinguishing declaration/test boundaries from method/data/embedded-grammar
  continuations. Prefix-only display of oversized Unicode lines is planning context, not source credit.
  Shared native acceptance requires surrounding context, exact suffix ownership, Knowledge-first tools,
  untruncated physical reading, defect ownership and per-checkpoint commits. Persist both independent
  audit commands in the existing inventory card; no second manifest or new runtime tool is installed.
- Final resulting task pressure is recorded below. All existing member and collection limits remain;
  later slices must remeasure evidence growth. No partition or policy-cap increase is implied.
- The exact staged candidate requires canonical tools/run_ci_local.sh for this parent closeout. Keep it
  frozen during the gate, consume the final status, verify its receipt, then commit and clear the brief.
  Prior 888d8ca20983667ef427446e8fddf03f6eb5c8a2 passed all nine doctrines/post-pointer and clean/brief checks.

- Resulting .3.2.55 candidate pressure: 100 files / 77,867 lines / 7,874,864 bytes;
  2,133 lines and 513,744 bytes remain within the existing aggregate caps.

### Rust lockfile reading and durable forward diagnostic intake at `.3.3.1`

- Activated from clean `611d7b5c1a53fa8c38fb8fcc17e2304dc21ca63a` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Physically read rust/.gitignore 1–3 and Cargo.lock 1–1493 in six untruncated windows while the
  preceding canonical candidate was frozen; its commit body preserves that preparation. Reconcile only
  this owned group now: 1,496 lines / 37,995 bytes, exact baseline identity and budget proof.
- Ignore-file SHA-256: 3c190dc8bc9f793ca5c8d1e5f01b329ea63b2853bc9e8a3e18da63f7fb10c5b5;
  lock prefix: 387c9d18efd9f56bbbbcb63aee878314a8c86ad772a717366becfbc925e1cbd6.
- Retrieve dependency/local-storage Knowledge first. Lock v4 pins 199 unique package identities:
  195 registry checksums and four local records. rgx/pgen source remains excluded; Git owns the relative
  dependency pin. Cargo.lock remains tracked despite its ignore pattern. No fetch, upgrade, or cache move.
- Append the exact lock census to existing storage Knowledge. Qualify its older cache byte/file/hash
  values as July 26 evidence, not a fresh cache census. Suffix 1494–1850 stays assigned to .3.3.2.
- Intake the forward .3.3.3 diagnosis into new repair .45 before other durable edits: malformed I/E
  blocks warn, disappear, and report successful compile/invoke, including typed nested-write/bang errors.
  Eleven managed CLI controls plus the exact compiler branch establish the cause. Store the reproducer in
  its Knowledge card; fix all relevant block routes and public teaching after .3/.4/.5. No repair closes.
- Activate the Rust parent and advance one checkpoint only. Later physical preparation in the preceding
  commit body still needs its own comprehension/delta checkpoint. Roadmap Yes; codebase No; physical
  mdBook Yes with formal alignment pending. Prior canonical receipt and post-commit proof are retained.
- Preserve completed core diagnostics from forward .3.3.6 in repairs .46/.47: UTF-8 clipping can panic,
  and compiler validation rejects space/tab-only bang arguments accepted by its parser. The exact
  isolated core program, linked artifact hash, and removed scratch are in the preceding commit body;
  the earlier whole-spec timeout is not proof of either defect's public CLI behavior.
- Preceding canonical gate and receipt pass: both primary CLI environments 66/66, Phase 0 1,032/1,032
  in 1,066 seconds; optional whole-backend/matrix routes remain explicitly skipped. Commit 611d7b5c
  passes all nine doctrines/post-pointer and promotes the exact receipt. The brief was cleared and Git clean.
- The separate forward .3.3.7 regex-boundary harness timed out while compiling after 180 seconds;
  its source never ran. The subprocess was reaped and exact owned scratch absence verified. This does not
  establish a parser defect or a canonical-gate failure; the bounded native CLI comparison is separate.
- Four direct native CLI controls now establish the separate regex-newline defect: unflagged regex plus
  newline warns and returns null, while semicolon, adjacent-flag/newline, and string/newline return seven.
  parse_regex consumes whitespace then the following identifier as suffix flags; .45's fallback drops
  the invalidated I block. Create .49 before adding its exact evidence to the shared Knowledge card.
  The failed core-harness compilation is not credited as a running test. All diagnostic jobs are consumed.
- The director put reporting aside. No report artifact or .48 leaf was created; preceding commit body
  preserves the returned app reference and corrected guidance. Continue the original LinkedSpec batch.

### Rust manifest, AST, callable prefix and requirement evidence at `.3.3.2`

- Activated from clean `08149577237224e96053ee3116fb8bb8164be5a5` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile the six fully read forward scopes preserved in 611d7b5c's commit body. Cargo.lock now has
  both prefix and suffix checkpoints through EOF; a whole-file metadata census alone never supplied reading
  credit. This group is 1,483 lines / 59,455 bytes and all six current files remain baseline-identical.
- rust/Cargo.lock 1494–1850: 9236 bytes; SHA-256 2e25e0908f0af692ab4aa61f9dbea230096c8688f5d8a5e41c79a9aa61a6a549.
- rust/Cargo.toml 1–18: 427 bytes; SHA-256 4f85f31df8b2228a18e44f22e9a9e276f6ca91943becea7f7025b70d564cbe81.
- rust/README.md 1–484: 27733 bytes; SHA-256 6da3d72eca80a4caef1de6063523f8c95f7a8c86dc60b4434ca7aba9858e9f3e.
- rust/linkedspec-core/Cargo.toml 1–14: 363 bytes; SHA-256 4e1b8f9d81bc30eaee3c2243bf5142fb3b26a51f60f9c99e91fd5e10dda709ed.
- rust/linkedspec-core/src/ast.rs 1–360: 12809 bytes; SHA-256 1bc180bef4445edfd797c69ea1064639ce53df7407b1629b914f8bce73b4d9d8.
- rust/linkedspec-core/src/callable_contract.rs 1–250: 8887 bytes; SHA-256 e8e989a4b9cb754b3f20a092d9de903150ec83411c9f08ac33d72548c89b7feb.
- The two-crate workspace shares version 0.1.0, edition 2024, and a relative local rgx dependency.
  AST defaults include empty function metadata and inline source identity; line SourceSpan remains distinct
  from callable character spans. Typed signatures, final parameter kinds, staged payload/job/body AST,
  edge selectors/provenance, and legacy serializable body kinds remain explicit rather than inferred.
- Callable contracts cover builtin helper/receiver forms and declared final codeblock parameters. Prefix
  normalization checks the registry and processes functions plus lifecycle/action/blind blocks, retaining
  staged statement-extension metadata and rejecting statement-count changes. Candidate arity/placement and
  eager-block restoration are distinct; recursive visitor/restoration suffix 251–394 remains .3.3.3-owned.
- Locked offline Cargo metadata again resolves 199 packages: required local rgx-core/pgen declare 1.95,
  while README line 472 claims 1.85+. Registry rows above 1.85 include platform-specific packages and must
  not be collapsed into an experimentally proven universal minimum. No excluded dependency source read,
  fetch, upgrade, old compiler run, or supported-minimum promotion is claimed. .41.7 owns correction.
- Extend .41.2/.41.7 before Knowledge changes. README current subset/63-case wording needs reconciliation
  against the unconditional 105-case generated classifier and 66-case primary authority; direct Cargo
  examples need managed root routing. The generated classifier is not claimed as a fresh default-canonical
  execution here. AST comments misdescribe Default as OR+ and & as choice; current getters and neutral
  authority retain default minimum 0 versus OR+ 1 and Single's AND family. Source repairs stay gated.
- Keep cache measurements explicitly dated; record complete lock reading separately from the static
  metadata fact. Refresh relevant Knowledge source paths/reverify routing without changing executable
  tools. All prior compiler repairs .45–.47/.49 remain pending. No runtime or public-book change.

### Rust callable traversal and compiler validation reading at `.3.3.3`

- Activated from clean `9e6550871739a2d9942267db93fab47fa8f3088e` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile the two complete forward reading ranges retained in 611d7b5c's commit body: 1,499 lines /
  56,169 bytes. Both complete current files remain identical to the reading baseline.
- rust/linkedspec-core/src/callable_contract.rs 251–394: 5081 bytes; SHA-256
  67524f185979b05c6b96535aab95ef7dff11985b08d6a27b26c6986b9df6c58f.
- rust/linkedspec-core/src/compiler.rs 1–1355: 51088 bytes; SHA-256
  cda6903239dd6fd23727c0338e300d727c3268e561f6e4ccad751bc9b01fae0a.
- Callable traversal restores parenthesized ordinary block values and visits nested calls, assignments,
  access paths, mutation callbacks, arrays, blocks/codeblocks, and fluent arguments. Dedicated recognition,
  progressive, and staged nodes retain their own validators rather than being reparsed by this visitor.
- Compilation constructs functions/rules, normalizes callable contracts, rejects removed selectors and
  malformed typed write/mutation carriers, then resolves dispatch selectors/dependencies before later
  recognition, progressive/staged, and slot-identity validation. Traced compilation mirrors these phases.
- Recognition validation collects rule/function reachability and examines recognize_once attempts for
  recognition-observation binding-write effects and progressive/staged effects. The shared expression walker covers functions and every
  lifecycle/action/blind code slot. Aggregate-selector validation also reparses deferred edge-fluent arguments;
  unrelated legacy parse failures on that path are not asserted as new selector failures.
- Nested-write validation checks addressable roots, character spans, typed segments and source projections;
  mutation validation checks callback and continuation order. The established whitespace-only empty-call
  mismatch remains .47-owned. Function parse errors propagate; rule code still warns/drops other failures
  outside five governed diagnostic markers. The exact .45 controls remain diagnostic evidence, not a repair claim.
- Only repeated I blocks append statements during lowering; the other six lifecycle fields are single slots.
  Regex action adjacency is physical-line dependent, and nonregex members reset it. AND bare edges lower
  into blind dispatch and OR/default bare edges into action dispatch; explicit selectors retain provenance.
  Conditional/split/raw/plain forms are not compiled by these match arms.
- Existing callable, cursor, selector, typed-write, progressive, descriptor and parser-boundary Knowledge
  supplies canonical homes. Record the clarified phase order and lifecycle lowering in rust-core-compilation-boundaries; no runtime/public
  book changes and no fresh native-suite execution are claimed by the neutral checks.

### Rust regex resolution and outward projection reading at `.3.3.4`

- Activated from clean `87065401fab5eeb076ff6795d2aa0af957a4b63b` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile four fully read forward scopes preserved in 611d7b5c's commit body: 1,481 lines /
  57,687 bytes. Compiler reading now reaches EOF; all four complete current files match the baseline.
- rust/linkedspec-core/src/compiler.rs 1356–2153: 33416 bytes; SHA-256
  32d23a302261057a3b07cb25eb6aeeeb49c1d55c3b5fc43291b3b434e8e0343e.
- rust/linkedspec-core/src/descriptor.rs 1–465: 16895 bytes; SHA-256
  d0a089263e72be9c359bce09abfb5b0602d5e5774c159097faa252ff8bb245c8.
- rust/linkedspec-core/src/entry_rule.rs 1–113: 4101 bytes; SHA-256
  0de08149c4b3f73a8d41443151764aad6e1474e4aee4c8166eb85e890c560c22.
- rust/linkedspec-core/src/error.rs 1–105: 3275 bytes; SHA-256
  a25c2a569810a215cfcf79d0053f38d94e99e6930164709670f8d3c858b52519.
- Named selectors resolve before dependency expansion and retain authored selector/slot provenance.
  External edge-only targets append child patterns; self-targets reuse parent slots. Later compiled slot
  validation rejects missing/out-of-range action targets despite earlier warning/skip branches. Existing
  .41.2 owns stale comments that say self-edges duplicate patterns or imply skipped targets are accepted.
- Inline compiler tests cover association, named/numeric selectors, self references, function versus rule
  parse errors, family bounds, fluent/action/blind/lifecycle lowering, and the shipped JSON example. Reading
  these tests is not a fresh test run. Existing .45 continues to own the malformed-rule fallback.
- Descriptor projection uses pure BTree-backed maps and four root fields, source/dependency order, normalized
  cursor metadata, exactly five semantic edge keys and separate selector metadata. Legacy missing-ref
  fallback orders action refs before blind refs. Typed functions use version 3 for parameter kinds, 2 for
  signatures, and 1 for legacy metadata. Source paths and staged payloads remain authored projections.
- A descriptor's deterministic last-definition handling of supplied compiled state is distinct from the
  supported native source pipeline: the earlier asserted CLI control rejects duplicate authored labels.
  Do not infer duplicate-source acceptance from a projection helper's map policy.
- Entry resolution borrows ordered immutable state: structural emptiness precedes explicit lookup, then
  the first authored marker and first authored rule provide defaults. PortableDiagnostic stores sorted
  fields and LinkedSpecError::diagnostic retains its typed payload. Neither selection nor projection changes
  authored is_top. Existing descriptor, entry, and slot-identity Knowledge owns these boundaries.
- Neutral slot/entry checks reverify their contract surfaces without claiming fresh native, generated,
  emitted, or full optional Rust gate execution. No runtime or public-book change.

### Rust expression carrier and statement parser reading at `.3.3.5`

- Activated from clean `cd0e4ff4b74f2a815d9574964c5a29894a8b89ff` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile the fully read forward expr.rs prefix preserved in 611d7b5c's commit body: lines 1–1496,
  1,496 lines / 57,175 bytes; SHA-256 51b266fcd7e51daa7b34d67ce1ff7c806e745ec3efdf4e27d3218c1ba615191e.
  The complete current file remains baseline-identical; suffix reading is separately owned.
- Typed Expr state distinguishes eager values, inert callable/contextual blocks, expression-segment
  nested writes, structured mutation callbacks/continuations, recognition nodes, and staged parse-job
  declarations. Authored source and half-open character spans remain separate from the parser's byte cursor.
  Display is debug formatting and does not provide source round-trip or serialization guarantees.
- Recursive selector and recognition scans walk typed nested values, blocks and callbacks. Callable
  signatures enforce ASCII parameter identity, reserved/duplicate checks and final-rest placement.
- Staged declarations require literal pair-hash options with closed keys and policies; capability IDs
  are unique/sorted. Direct capture indices are finite nonnegative integral usize values, while nested
  nonempty cat plans flatten in authored order. These are inert declaration/AST boundaries, not live
  parser authority; existing staged-provenance Knowledge owns the accepted runtime consumption paths.
- The statement parser retains line/semicolon separation and six bare control markers. Attached if/switch
  forms normalize toward existing statement markers, and while retains a body block. The switch parser
  continues beyond this range; no suffix credit or fresh native execution is inferred from contract checks.
- Existing callable, staged, write/mutation, block, hash, and control-flow Knowledge supplies canonical
  homes. Clarify source-coordinate/debug-display evidence and completed generic callable normalization
  without reopening historical runtime implementation. All .45–.47/.49 repairs stay pending.
- Focused neutral staged/write checks plus exact coverage and continuity proof own this documentation
  checkpoint. No runtime, generated-format, public-book or policy change.
- The managed metadata wording update repeated the known child-setpgid EPERM warning (PID 19381), then
  exited 0 with the intended file edit. Consulted project-data-liveness-permission-denial; .7 already owns
  group-establishment verification. That child's actual PGID was not captured, so no group-failure or
  lifecycle-correctness inference is made. No recovery/purge was run.

### Rust expression continuation and existing boundary repairs at `.3.3.6`

- Activated from clean `2af9c32143a084c1a8296321c3babe1d4a5b3e1f` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile the fully read forward expr.rs continuation retained in 611d7b5c's commit body: lines
  1497–2957, 1,461 lines / 54,270 bytes; SHA-256
  a1cfca66a53c6f8d5704e137213d8605d1c08e4826f72872376f2d1d5461e440.
  The complete current file remains baseline-identical. Remaining suffix begins at line 2958.
- Attached controls and nested callable candidates retain their containing character base. Parenthesized
  block candidates fall back to ordinary eager blocks where callable metadata does not claim them.
- Nested-write scanning retains expression segments, addressable ASCII roots, authored source and spans,
  and statement separators. Mutation parsing requires the immediate bang and empty trimmed parentheses,
  captures the typed callback and continuation in authored order, and rejects bang continuation.
- Scalar assignment specializes dispatch_span and parse_job into typed declaration nodes. Expression
  dispatch distinguishes symbolic helpers, regexes, assignments, literals, accesses and typed forms.
  Hash keys are parsed as expressions; quoted keys establish literal identity. No key-loss defect is
  inferred from the value of an unbound bare-key expression. Brace classification prioritizes exact {|,
  then empty/hash-pair payloads, then ordinary eager blocks.
- Read the exact UTF-8 diagnostic slice at pos+40 and mutation source-boundary checks against the
  previously measured controls in rust-action-parser-boundary-defects. .46 owns the confirmed isolated
  core panic; its earlier whole-spec timeout still has no established shared cause. .47 owns whitespace
  accepted by parsing but rejected by compiled source projection. .45 owns warning/drop of malformed
  rule blocks, including these typed parse failures. No fix, new panic route, or fresh native run is claimed.
- Refresh the existing mutation and hash Knowledge with these precise boundaries and managed reverify
  routing. Neutral mutation checks verify their declared contract only; they do not close the observed
  acceptance gaps or rerun all native/generated consumers. No runtime or public-book change.

### Rust lexical boundaries and expression test reading at `.3.3.7`

- Activated from clean `cbd871c6a6ae53dd91e5eddbd4c73b8fefda0cd7` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Reconcile the fully read forward expr.rs range preserved in 611d7b5c's commit body: lines 2958–4454,
  1,497 lines / 56,871 bytes; SHA-256
  83ff42b72d5dd9222751deb14c81e889da99c2c937ceb0b0e388f32e3f180788.
  The complete current file remains baseline-identical; remaining expression tests begin at line 4455.
- Callable literals preserve authored body/source and containing character-base spans. Brace scanning
  skips quoted/regex literals; top-level hash classification excludes namespace and nested colons while
  retaining retired fat-arrow recognition solely to route source to the rejection diagnostic.
- Dedicated recognition intrinsics require static bare operands and exact call(rule) shape. Established
  helper/receiver trailing blocks use the builtin callable forms and exact arities; candidate mode instead
  defers complete-registry normalization. Postfix literal-string keys remain distinct from expression indexes.
- Keyword-name recognition is ASCII; ordinary names permit Unicode alphanumeric characters and colons.
  Strings retain authored escaped content. Numeric parsing accepts signed integer/decimal prefixes without
  swallowing following fluent chains. These are lexical/source facts, not new cross-backend promises.
- Regex literal parsing consumes suffix letters after skipping whitespace. The already measured .49
  defect loses a newline before a following identifier; the .45 rule-block fallback then hides the parse
  failure. Preserve the four native CLI controls recorded at .3.3.1, and the separate preliminary core
  build timeout which never ran its source. No failed-build success, fresh .49 native run or repair is claimed.
- Inline tests cover keyword AST, call-result access, statement versus value marker forms, attached
  if/switch/while separators, trailing-block contexts, scalar/append/nested-write nodes, and expression
  hash keys. Reading test definitions does not execute them.
- Reconcile existing arithmetic/hash/callable Knowledge and the completed assignment-closure pointer;
  preserve historical roadmap chronology as historical. Record lexical distinctions without duplicating
  the canonical .49 defect evidence. No runtime, public-book, generated-format or policy change.
- A new six-control managed Rust CLI/Perl Toolbox lowering matrix isolates adjacent-colon loss after bare
  hash keys. Four controls return {"a":7}; key:7/key: 7 return null with expected-colon warnings. Perl
  lowers all six valid forms. parse_name consumes the separator before parse_hash_literal expects it;
  .45 then drops the initializer. Add repair .50 before Knowledge.
- The first computed-key control used invalid-on-Perl cat(key), so replace it with cat(key, "").
  Root-cause the arity difference separately: on a valid explicit-edge fixture, a constant and two-argument
  cat agree on both runtimes, while cat("a") returns "a" on Rust and null on Perl. Perl lowering requires
  two arguments; Rust engine.rs 8213–8222 has no arity guard. Add .51 before Knowledge, coordinated with .28.5.
- The earlier no-edge Perl E cases both returned zero and cannot establish cat behavior; .27 already
  owns that handler divergence. No zero-argument or other-backend outcome is inferred. Additional diagnostic
  source coverage is engine.rs 8198–8245 and MethodLowering.pm 5315–5340, without broader reading credit.
- Preserve exact commands and observed values in rust-hash-separator-and-cat-arity-defects. Public helper
  spelling and dynamic-key authority are checked; both new repairs remain gated on .3/.4/.5.

### Rust expression-test completion and core parser entry reading at `.3.3.8`

- Activated from clean `d3fd3c404cfaa6d6813a26641b0cd0d12e5c9ac7` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Physically read expr.rs 4455–5819 in five untruncated ranges, lib.rs 1–27, and parser.rs 1–78.
  Total 1,470 lines / 57,396 bytes; all three complete current files equal the reading baseline.
- Range SHA-256 values, respectively: abc37154ddf9e2c55f6f5ed53e08d988a95a57c770e037ed19d4813f5606ca9f;
  89a45085bb23b29b06a3b367a9e220b9f5e05605675935b6d4a98d0b15d0d4ab;
  c230bb65e4318fab648fd36fb033e4a2e5d23cdea0d76d677a4b041744d77d19.
- Remaining expression tests cover colon migration diagnostics, expression-valued and shape blocks,
  literal boundaries, typed nested writes, fluent receiver forms, numeric/symbol callees, assignment values,
  parser errors/separators, and selected Display/serde reconstruction. The expression file is now fully read.
- The nested-write test asserts exact non-ASCII source/character spans and complete serde equality;
  older trailing serde tests instead check decode success or statement count, and fluent Display tests
  inspect selected structure. Preserve these assertion limits in the existing callable-state Knowledge card.
- Core lib.rs exposes its component modules and derives VERSION from CARGO_PKG_VERSION. The parser prefix
  collects rule headers/body elements and returns an empty function registry; the existing user-function
  registry card identifies the runtime spec-defined adapter that populates functions. No missing-feature
  inference or new adapter execution follows from reading the rule-only parser.
- Reconcile the current write rollout against its dated neutral updates: all five backend implementations,
  six-runtime recurrence and public closeout have completed. Clarify the stale pre-implementation path prose
  and the Rust card's former pending paragraph, retaining original native-test dates and managed reverify commands.
- Qualify the older duck-typed assignment card's explicit aggregate-selector/storage teaching as historical,
  linking current uniform-binding retirement. Own the misleading until_target_inference_leaf test name under
  .41.6 before Knowledge; its valid AssignScalar assertion does not reopen completed implementation.
- Fresh neutral write/callable/uniform checks validate their authorities only. Known .45–.47 and .49–.51
  runtime repairs remain pending; no runtime, public-book, policy or generated-format change.

### Rust body-parser reading and bounded lexical diagnosis at `.3.3.9`

- Activated from clean `2bdea14f8b54abd7e79b2d66f023b8fdb89fbaa1` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read parser.rs 79–1574 in six untruncated ranges: 1,496 lines / 49,733 bytes;
  SHA-256 77358d16bbbad32395002c3109196e91f13fb5d58ad8c492ca5fbe5be80ced9f.
  The complete current file equals baseline. The remaining parser tests begin at line 1575.
- Trace wrapping calls the ordinary parser. Headers use pinned Unicode labels, stop modes at whitespace
  or slash and restore unknown tokens. Inline/body parsing share element classification but differ in
  unsupported-suffix retention. Action grouped selectors are shared/final-label-adjacent; bare selectors
  are per-target with optional space; blind edges retain their separate numeric-index grammar.
- Body classification orders named/anonymous regexes, action/blind edges, lifecycle, gap/split directives,
  conditional/fluent syntax, standalone I and complete-line bare edges. Block extraction retains authored
  source separately from normalized interior. Attached branch and multiline fluent helpers have distinct
  quote/regex/completeness boundaries, so their shared names do not prove equivalent lexical behavior.
- After Knowledge/Toolbox review, ten paired Rust CLI/Perl Get controls isolate compact space/tab rejection,
  quoted-parenthesis truncation and invalid header-suffix loss. Compact no-space and braced controls execute
  the intended I return on both runtimes. Own .52.1/.52.2 and .53 before Knowledge; .53 also owns reviewing
  the unreachable advanced && !consumed_line branch without claiming a separately observed runtime failure.
- The raw-regex brace control fails on both runtimes, so do not classify it as a Rust-only issue. Three
  accepted matches controls show quoted-pattern and /x/ success (Rust true / Perl 1), but /}/ fails Rust
  compilation and returns Perl null with rule_handler_compile for Top/_default. No boolean parity claim.
- Three direct primary-bootstrap dumps independently show full control ICODE payloads but the /}/ payload
  truncated to return(matches("}", / with source ending inside the regex. All report ok=1 and position 67.
  Perl CURLY_BRACE offers only brace/quoted-string alternatives; Rust outer collection and validation
  similarly omit regex state. Own .54.1/.54.2 plus later cross-backend/public .54.3, coordinated with the
  distinct existing attached-tail repair .9. Other backends and generated execution remain unmeasured here.
- Four direct Perl lowering controls preserve raw regex assignments and quoted/spaced return text. The
  attempted parser_source_ref capture produced no snippets and establishes no emitted-source evidence.
  The direct bootstrap owner and native results provide the causal proof. Exact commands live in
  rust-body-parser-lexical-boundary-defects; all subprocesses completed without timeout.
- Additional diagnostic source reads cover validation.rs 1056–1079/1080–1190 and Perl BootstrapSpec/Core.pm
  734–821/1079–1106/1130–1211 plus the BootstrapSpec.pm facade. They do not replace queued validation reading.
- Fresh neutral standalone/cursor/Unicode proof remains green while these concrete controls fail. Preserve
  the uncovered boundaries and source mechanisms, update existing standalone/header/attached-tail Knowledge,
  and retain the earlier .45–.47/.49–.51 repairs. No implementation, policy or public-book change.

### Rust parser-test, trace and numeric-conversion reading at `.3.3.10`

- Activated from clean `236aa4d7a3ebd29a669bf653aacd204abfbb3a5b` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read parser.rs 1575–2084 (510 lines / 17,297 bytes),
  trace.rs 1–715 (715 / 21,960) and types.rs 1–241 (241 / 7,880): 1,466 lines / 47,137 bytes total.
  Respective SHA-256 values are 038cb36896049a23e531552924551bacf062f37df3ef2633fd5fe1d5fd6a3498,
  bc18a16e2b4ab8a12663d93824ce80868237f2365f4d8ff797ea2b30ae8ca421 and
  752211002be552941faeb1ed9ae8eda839183db633eaa047d5fb72f133615680. Complete current files equal baseline.
  The parser is now read through EOF; types continues at line 242 in the next leaf.
- Remaining parser tests cover header-rest compact edges, multiline fluent/control blocks, attached
  branches, compact I calls, quoted braces/operators, mode/blind-edge and regex-slot order. Those selected
  assertions do not close .52-.54 lexical cases discovered in the preceding checkpoint.
- Core trace uses positive integer thresholds, injectable environment lookup and quiet defaults.
  File routing, mirror fallback and construction-time append/reset are separate from event gating.
  Fallible emission methods return I/O errors, while trace_decision discards its emission result and
  preserves the boolean. No new normative sink policy is inferred; typed diagnostic-output sinks differ.
- Managed locked/offline single-thread core trace target: 7/7. The build retains normal dependency
  warnings without suppression. Read-only inspection of known project PIDs proves the run remained live
  despite the unprivileged run listing saying abandoned, matching existing .7. No recovery, purge,
  signing or cache manipulation; toolchain executables are required read-only host dependencies.
- Compilation finishes in 17m10s. At 03:41:27.472 +0200, the test binary launched at 03:39:55.031
  has 112 KiB footprint and all 800 one-second samples at _dyld_start. This locates the sampled interval
  before Rust main without proving an OS cause. The earlier compiler sample failed after its PID exited.
  Both exact paths are absent after fully consuming/hash-verifying/removing the 32-line / 1,015-byte
  test report. macos-rust-first-launch-validation-latency preserves the command, hash and dated bounds.
- RuntimeValue keeps f64 numbers, ordered hash entries and inert typed codeblocks. Raw serde and to_json
  are distinct conversions. Generic as_number/as_bool/nonempty/len are not proof of strict helper policy.
  Four paired Rust CLI/Perl Get cases all exit zero with empty stderr, Rust compile/invoke success and
  no Perl exceptions/last_error: 42 agrees; signed 1e20 saturates to signed i64 limits only on Rust;
  two-argument cat of positive 1e20 returns full decimal text on Rust versus "1e+20" on Perl.
- Engine execute_value_with_context calls RuntimeValue::to_json before the primary CLI serializes JSON.
  The finite integral branch casts directly to i64. Own .55.1 value-preserving conversion plus related
  to_str/len/Display consumer audit; only direct numeric output is freshly measured. The full scalar-text
  authority contains only -0.0, 1.0 and 1.25 numeric examples, so .55.2 must reconcile reference spelling
  before frozen authority changes; .55.3 owns later public/cross-backend/generated closeout.
- Additional causal source reads include engine 1930–1952/2656–2686 and primary_cli 318–347. Reading
  types 242–538 for the Display audit does not replace the next activated range's coverage proof.
  Exact four-case command/results and proof limits live in rust-large-number-conversion-defect.
- Fresh neutral scalar-numeric 55 cases / 18 helpers and cursor 36 spellings / 18 edges / 8 parent-child
  cases / 60 mutations pass. These fixtures do not cover the newly measured magnitude boundary.
  Existing cat arity .51 and strict helper input .20 remain separate repairs.
- Trace Knowledge now points to completed August .5.2/.5.4 repairs instead of stale pending state;
  historical native and canonical results are dated, reverify commands are managed and unsuppressed,
  and scalar-text fixture claims are bounded. The separate primary CLI trace adapter's 61-case milestone
  is dated, with later canonical 66-case evidence retained separately from this reading leaf. No runtime, policy, contract or public-book edit.

### Rust compiled-type, Unicode and validation-entry reading at `.3.3.11`

- Activated from clean `90321cca4c5f7d460ef66a3e19df871d3a85abbb` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read types.rs 242–538 (297 lines / 12,071 bytes), unicode_rule_label.rs 1–850 (850 / 20,086)
  and validation.rs 1–352 (352 / 13,337): 1,499 lines / 45,494 bytes total. Respective SHA-256 values:
  095766545512956f67d3545377f236184c3b461457fed63d1b548faafe374ffd,
  28f1a8ffefd324a9191e8cd1bc26dad85ffa7eb6d97edf58106156311d3d114c and
  1522eab988b4919cda627dbdddbfb86480a5f5897d79ee9d3b0a9c66bc72dc36. Complete files equal baseline.
  Types and Unicode are now read through EOF; validation continues at 353 in the next leaf.
- RuntimeValue Display's integral cast remains in .55.1's existing audit, with no additional native
  failure claimed. Compiled action/dependency records retain numeric/named/unindexed selector provenance,
  resolved target slot, authored source identity and line defaults; blind entries retain their distinct
  child/code/fluent carrier. Serde defaults preserve omitted legacy fields without establishing validity.
- CompiledRule retains authored family, regex rows, gap directives, dependencies and lifecycle ASTs;
  cursor_policy is derived solely from mode.is_and, never an independently mutable cursor field.
  Compiled user functions retain typed body plus authored source and optional staged/signature carriers.
  CompiledSpec's vector lookup and authored top marker do not perform effective entry resolution.
- Read all 806 inclusive Unicode ranges and all classifier functions. Binary search uses the pinned
  Unicode 17 scalar intervals; complete labels reject empty, and char_indices plus len_utf8 makes
  longest-prefix slicing boundary-safe. No host property lookup, normalization or folding is introduced.
  Fresh managed regeneration checks the JSON/five classifiers/portable regex class at 806/9/8/2.
- Ordinary and traced AST validators list the same thirteen non-strict passes in the same order,
  followed conditionally by unused-rule checking. This does not make trace I/O infallible. These AST
  passes are separate from compiled callable/regex validation documented in the compiler card.
  Labels are rechecked across declaration/action/blind/bare roles; function registry checks name
  collisions, variadic signature shape and parameter validity/uniqueness/reservations separately.
- Existing .41.2 now explicitly owns the stale numbered module-doc reference and incomplete pass
  inventory. Strict Knowledge's six-check and 237-test counts are dated June evidence, not current
  inventory. Cursor admission's 3/5, 68-file and 34-mutation counts are likewise dated; its broad
  entry-selection-only options sentence is narrowed to the actual global-cursor removal.
- Neutral cursor proof passes 36 spellings / 18 edge / 8 parent-child cases, 74 migration files,
  8 complete / 0 pending and 60 mutations. Duplicate-slot proof passes 5 fixtures / 2 diagnostics /
  6 runtime rows / 7 complete + 0 pending / 59 mutations. No native admission matrix is rerun.
  Update existing Knowledge and continuity; no implementation, policy, public-book or contract change.

### Rust static-validation and descriptor-test reading at `.3.3.12`

- Activated from clean `75ce8db839888a5091d25ee4e5e1c3c501daf3b8` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read validation.rs 353–1541 (1,189 lines / 43,751 bytes), descriptor_test.rs 1–286 (286 / 10,574)
  and rule_local_cursor_normalization_test.rs 1–15 (15 / 519): 1,490 lines / 54,844 bytes.
  Respective SHA-256 values: ae31b86aacae09d160e6b95b4717697f108cf7a53fc2ad7c3ad3158b464b030d,
  3beeedc86c3066001aff5d441bb259d472c4dee9ff7123e40c074d4b6e223da8 and
  c2fc5cb2e8ec50e0852aef1365eea1cb27cb798a32a1af677bb3dd374ffaf78c. Whole files equal baseline.
  Validator and descriptor consumer are now read through EOF; cursor test continues at line 16.
- Function names/params use separate ASCII identifier rules. The registry checks helper/control/lifecycle/
  runtime collisions and variadic signatures, but its helper list is manual. After Knowledge/Toolbox
  retrieval, four paired native controls use identical definitions and real explicit-edge execution:
  custom_value returns sentinel on both; trim definitions fail on both; gap_text and entry_slot execute
  their user bodies on Rust but fail Perl function_registry with exact built-in collision details.
- Own .56 before Knowledge: reference-authority/diagnostic inventory, Rust validation repair and governed
  recurrence, then public/backend/carrier closeout. The Rust validator omits both helper names; engine
  eval_expr resolves registered functions before ordinary eager-helper fallback. Perl's registry delegates
  to MethodLowering's known-value-call resolver. Other helper names and generated routes are unmeasured.
  Exact command and outcomes live in rust-user-function-helper-reservation-gap.
- Slot metadata validates declaration names/duplicates, skips nonexistent target rules to preserve their
  established undefined-reference stage, and resolves numeric/named/malformed action selectors. Capture-gap
  checks reject duplicates and legacy markers and require seek/repetition/action ownership without local
  parent-regex adjacency. Their frozen neutral checks pass at 9 complete / 0 pending, 63 semantic mutations,
  34 public mutations, with the existing admission mutation populations unchanged.
- A second bounded diagnosis finds AND bare validation tests only the old numeric index. Five paired native
  cases reject Child[0] but accept Child, Child[word], Child[missing] and Child[!]. Accepted Rust cases
  return ["selected"]; Perl returns null even for plain Child, so do not classify a new return-path defect.
  Four independent Perl public descriptors erase each accepted selector into the same blind Child row,
  null regex_index and no resolved_slot_edges.
- Own .57 before Knowledge: complete-selector diagnostic authority, separate Rust/Perl normalization
  repairs and later supported-route/public closeout. Rust parsing retains Named/Invalid but sets index
  only for Numeric; slot validation skips AND bare edges, edge-shape validation checks index only, and
  compilation emits an unindexed dependency/child call. Perl RuleIR likewise tests defined(index) then
  drops selector provenance from blind and normalized records. ADR 0044 keeps selection action-owned.
  Exact native and descriptor commands live in and-bare-nonnumeric-selector-loss; .27 remains separate.
- Other validation passes derive mixed ownership after bare normalization, reject the retained Raw member
  only for the same-line I remainder, and balance lifecycle authored outer source or legacy interior.
  The brace scanner's missing regex state is already .54-owned. Regex literals compile through rgx as
  a required read-only dependency; no rgx source reading or compatibility expansion is claimed.
- Strict unused references include action/blind/bare targets, preserve declaration order and add no entry
  exemption. Managed locked/offline single-thread core validation passes all 21 tests with 180 filtered,
  after a 1m38s build and 0.82s test execution. No sample was taken for this run's silent interval; do not
  infer its exact cause from the earlier trace run. Every native/probe process is consumed.
- The four descriptor test functions assert selected models/orders/staged fields and exact schemas,
  compiled-state round-trip equality, all 36 cursor families and positive edge rows, and deterministic
  last-definition projection. Existing descriptor Knowledge already separates that direct projection
  test from public duplicate-source rejection; no descriptor runtime rerun or new duplicate-rule claim.
- Root neutral proof passes 8 selection / 3 failure / 3 strict cases and 54 mutations; cursor proof passes
  36/18/8 at 74 files, 8 complete / 0 pending and 60 mutations. Update registry, bare-edge, strict and gap
  Knowledge with dated limits. No source implementation, public book, policy or authority contract changes.

- Required `COMMIT.md` rollover archives exact clean activation lines 253–458: segment 4983,
  206 lines / 17,316 bytes, SHA-256 274cdb2ddc2b6672965d365d2cb98b0f7800db1e84f491bb2ec4436c2d98a6d1.
  Independent source-blob/hash/prefix proof passes; all prior manifest rows are byte-identical. After the
  current record update and one-newline mutable-root EOF normalization, root 255 lines / 26,100 bytes,
  manifest 24 lines / 14,394 bytes,
  collection 25 files / 25,411 lines / 2,715,309 bytes. Prior pressure fails only files 25/24
  and manifest lines 24/23. Indexed ADR 0105 admits those two finite slots before the route mutation;
  every other ceiling, pattern, authority, lifecycle and immutable segment is unchanged. This necessary
  storage-infrastructure step selects canonical tier; exact staged receipt, all doctrines and memory
  checks must pass before commit. Public-book/runtime semantics remain unchanged.

### Core integration tests and bounded-child authority prefix at `.3.3.13`

- Activated from clean `1d3715fc70e36e97a8c3be1b114edf9f2e706a11` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read all six owned ranges without truncation: 1,495 lines / 52,012 bytes. Every complete file and owned range remains identical to baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. The five initial files reach EOF; bounded-child authority ends after invocation fields at 778, with constructor/dispatch/helpers owned by `.3.3.14`.

| Repository-root source | Inclusive lines | Bytes | Range SHA-256 |
| --- | --- | --- | --- |
| `rust/linkedspec-core/tests/rule_local_cursor_normalization_test.rs` | 16–314 | 11,666 | `38bbb0759cda553948675c376dafc180f34e1b4c3baa92a132a142c58394fe3e` |
| `rust/linkedspec-core/tests/types_test.rs` | 1–222 | 7,203 | `4f038028a41a9984e64515e74672882f7ed3710a63f3c12de97ab0c2edb5bda7` |
| `rust/linkedspec-core/tests/unicode_rule_label_contract.rs` | 1–155 | 5,721 | `87c3c10bf41315945a00cf0bd48fa39b4de10228a6d8468d1f9c75305cc8ca13` |
| `rust/linkedspec-runtime/Cargo.toml` | 1–20 | 533 | `84f14febdd52e5f482f99e8c8724025f09e544e586e44a9f27c4afc62ae04c35` |
| `rust/linkedspec-runtime/src/bin/linkedspec-rust.rs` | 1–21 | 648 | `2bccab116d4fc9a90fb22f23b1f3af9ba482a1c079525584d457166d44089fba` |
| `rust/linkedspec-runtime/src/bounded_child_parse_authority.rs` | 1–778 | 26,241 | `d62af837c6ad5d0833c9aefc8ea7abaae3f0fdd14a4a006f023f13aeb9b4fa15` |

- Cursor tests consume governed families, edge cases and ownership sets, compare selected portable diagnostic fields and dispatch ownership, and preserve physical-line bare recognition. Compiled serde checks are selected projections, not universal equality. Existing `.57` nonnumeric AND bare-selector loss remains outside those fixtures.
- Type tests cover ParseMode serde, selected compiled identity/policy fields, small-number JSON, typed truth, numeric parsing, nonempty and length examples. Their eight tests do not prove every value variant or complete compiled equality; `.55` large-number loss remains owned. The older logical Knowledge card's no-codeblock claim is qualified against the already current inert Codeblock owner.
- Unicode tests pin the contract/version/hash and selected positive/negative/prefix cases, exact action/blind/bare identities, and distinct-label compilation. The shared action selector example is parse-only. Invalid-source proof rejects only an invalid full declaration identity, not every malformed source; programmatic negatives cover declaration and action roles. Existing `.53` source-acceptance ownership remains separate.
- Runtime manifest dependencies remain unchanged. The primary binary delegates OS arguments, writes stdout before stderr, exits one on either write failure, and otherwise preserves the delegated status.
- The bounded-child prefix owns immutable logical registry records, typed register/load denials, Arc-identity cancellation, the caller clock, opaque execution seeds and shared invocation state. Callback-view clones share expiry and rebase bounded local positions/spans through the original source authority; diagnostic cloning enforces its serialized-byte ceiling. Invocation construction, dispatch ordering, authority narrowing and result/helper validation remain in the unread suffix. Existing `.41.2` owns the stale pre-carrier argument comment.
- Managed native command `bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline --jobs 1 -p linkedspec-core --test rule_local_cursor_normalization_test --test types_test --test unicode_rule_label_contract` exits zero: cursor 5/5 in 1.13s, types 8/8 in 0.00s, Unicode 5/5 in 0.20s, all with zero failures, ignored or filtered tests. Separate compilation is 21m16s. The retained log `.linkedspec-data/scratch/startup72-core-integration.log` is 800043 bytes / 14132 lines, SHA-256 `8aeb382fabebd30d7763513615b2bfbe25be5ee7219bdc95f201641e2236ff16`.
- Managed neutral checks pass cursor 36/18/8/60, Unicode 806/9/8/2, logical 17 truth/10 helper/3 effect/26 mutations, and progressive 9/9 with 116 contract/60 public mutations. These do not rerun the separate private cfg-enabled authority consumer or every backend route.
- Consume `.3.3.12`'s completed exact canonical proof: base `75ce8db839888a5091d25ee4e5e1c3c501daf3b8`, staged SHA-256 `ac76420b0965d071cb2318925d1f4088e427ec2d594869517be16fbb7209f4c6`, receipt promoted to `1d3715fc70e36e97a8c3be1b114edf9f2e706a11`. All nine doctrines, six-family process locality, five relocation anchors, CLI 66/66 twice and Phase 0 1,032/1,032 in 1,142 seconds pass. Twenty-five optional gates/matrices were skipped.
- The aborted restricted attempt supplies no receipt; existing host-execution guidance is made visible in MEMORY. Eight fully consumed pre-main samples distinguish six aborted-attempt observations from two permitted-run observations without a new OS-cause claim. After identity/count/hash verification and the tracked Knowledge intake, only those eight reports (8,636 bytes / 256 lines) were removed and all ten expected-absence paths verified. Full accepted log identity and sample tables are in `docs/knowledge/macos-rust-first-launch-validation-latency.md`.
- The same canonical checker reports 76 MCP transport mutations while TOOLBOX section 4.10 twice claims 68. Existing `.41.7` owns those current-count corrections; historical milestones and optional-matrix limits remain explicit. No new runtime defect, source/public repair, policy change, target/cache cleanup, or recovery/purge occurs. Codebase remains No; physical book Yes, formal alignment pending.

### Child invocation, diagnostic types and engine definitions at `.3.3.14`

- Activated from clean `9922602583033684ec22466d0b1f3b4669ba497d` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read all four owned ranges without truncation: 1,494 lines / 50,413 bytes; full files and ranges match baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. The authority suffix and both diagnostic files reach EOF. Engine stops after `NestedWriteFailure` variants; its implementation and subsequent constructors/entrypoints remain `.3.3.15` and later.

| Repository-root source | Inclusive lines | Bytes | Range SHA-256 |
| --- | --- | --- | --- |
| `rust/linkedspec-runtime/src/bounded_child_parse_authority.rs` | 779–1639 | 28,104 | `f9f29a44a58ea963e422a3e1077cacc2b216c8cb74d55bef36ad368262e3c722` |
| `rust/linkedspec-runtime/src/diagnostic.rs` | 1–127 | 5,269 | `091f341e9dba870072723ec1f0509be93645cd42b533fe4a1d39796f7228e2ef` |
| `rust/linkedspec-runtime/src/diagnostic_output.rs` | 1–112 | 3,792 | `8df1c9b681bb15f30e535931249face6308575c17671b17aa0edf5af3056e7d3` |
| `rust/linkedspec-runtime/src/engine.rs` | 1–394 | 13,248 | `7a274b862455ad5ada9fc1711bae20372c7dc7cd51d6f675168970ae5950b061` |

- Invocation construction validates decoded source identity, positive depth/call limits and active-chain spans. Dispatch validates literal identities, exact span/source, transaction state, registry/top/capability/policy/resource limits, decreasing-span chain and token/budget/time before charging shared state. Callback return/unwind pops the chain and invalidates every view clone. Successful non-null results recheck cancellation/deadline and detach under node limits; false remains data.
- Resolved the zero-diagnostic-ceiling concern against private fields and the mandatory positive `ProgressiveCeilings::new` constructor. The existing private test explicitly asserts `éé` becomes `?` under one byte. Supporting constructor and test context is read, not a new native execution. Existing `.37.1`/`.37.2` retain nested resource and source-detail interpretation/census; no new runtime defect is established here.
- Diagnostic definitions preserve boxed structured context alongside the compatibility message. The current optional inventory includes code, entry, helper/arity, regex-slot and callable/cycle fields; every absent Option omits serialization. Sink clones share Rc/RefCell callback state, concrete sink errors retain identity, and Runtime/Sink/Exit delegate Display/source. Delivery and deepest-rule capture callsites retain later reading/native owners.
- Engine prefix defines ordered target/slot identity, explicit-action collection families, strict ASCII decimal finite numeric conversion, diagnostic/logical/gap arity, four-field ExecutionOptions and evaluated nested-write segments/failures. The current options card now includes semantic observation plus two doc-hidden execution seeds and qualifies old CLI milestones. Definitions do not prove full invocation isolation or all helper ordering callsites.
- Fresh managed neutral commands `tools/check_progressive_span_dispatch_contract.py`, `tools/check_typed_source_location_contract.py`, `tools/check_diagnostic_output_contract.py` and `tools/check_scalar_numeric_contract.py` all pass through `bash tools/run_python_project_data.sh`: progressive 9/9 with 116 contract/60 public mutations; typed source 14/0 with 231 mutations; diagnostics 3 helpers/11 render rows/6 scenarios/8 complete/20 mutations; numeric 55 cases/18 helpers.
- The unchanged-source four-carrier canonical result at `1d3715fc` remains dated native evidence. No private cfg-enabled authority, diagnostic delivery or complete engine native suite is freshly claimed by this documentation leaf. Four existing Knowledge owners are reconciled; runtime, public book and policy remain unchanged. Codebase No; physical book Yes, formal alignment pending.

### Generated engine loops and split boundaries at `.3.3.15`

- Activated from clean `7d6c9f8b52f7417175725950a62afa8310c647d5` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine lines 395–1894 in five complete 300-line chunks: 1,500 lines / 56,911 bytes; full-file and range identity match baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Range SHA-256 is `3dcd4d3eb399242762e8cdf4a70a554ee200066cc9d8c665d69bc99cc747b6c6`. This completes `GeneratedPlanExecutor` and starts `Engine` construction through `spec_name`; `.3.3.16` owns line 1895 onward.
- Nested-write/receiver diagnostic formatters retain typed failure fields, evaluated path and authored Unicode-scalar spans. SavedMatchState covers entry/local groups, spans, presence and capture offsets. Byte-to-char and next-boundary helpers require valid internal boundaries; scalar substring helpers iterate characters. Literal/regex and mutation-target adapters remain distinct.
- Generated families route to action/blind loops with source/family/rule traces, ordered target/slot identity, semantic match observations, child accumulator truncation and entry-slot propagation. Wrappers manage recursion, variable scopes and recognition frames around Result return. Action execution keeps flagged candidate-before-LS/commit-after-LE/tail timing and unflagged LS-before-selection, explicit collection, AND sequence and repetition/progress guards.
- Blind execution distinguishes repeated AND sequence completion from repeated OR choice and ordinary AND accumulation from OR first-match behavior; recognition outcome is separate from trace truth text. Saved return/match data restores on normal and explicit-return paths. This source checkpoint does not assert universal error-recovery restoration, native emitter freshness or completion of later engine bodies.
- Managed locked/offline CLI build passes in 16m27s. Seven identical Rust/Perl pure-split specs produce five empty-source/empty-delimiter differences and two equal controls; all fourteen compared commands exit zero without stderr. Rust literal splitting uses host string behavior; its regex loop emits the initial empty slice before a zero-width match. Perl dumped handlers use split with -1 and omit that initial field. The separate public helper arm at 8415–8444 confirms delegation. Existing .33.1 owns contract census and .33.2 explicitly owns pure-split repair/recurrence. Full cases, hashes and commands are in `docs/knowledge/tagged-record-evaluation-and-split-drift.md`; other runtimes/carriers remain unmeasured here. An initial collector's optional-trace JSON assumption was corrected after a raw protocol control; only its empty output file was removed.
- Seven managed neutral checks pass: write 5/7 syntax, 11 successes, 16 structural failures and 105 mutations; receiver mutation 4/14/5 syntax, 10 successes, eight pre-commit failures and 167 + 592 mutations; cursor 36/18/8/60; gap 9/0/63/public34; duplicate slots 5/2/59; recognition 138/250/58; generated metadata ten families, strict Rust 105/105 and census 100/0/0. The neutral v1 checker label does not change Rust artifact format 2.
- Updated existing Knowledge owners and kept historical native evidence dated. Public/runtime/policy repairs remain gated on startup prerequisites. Codebase No; physical book Yes, formal alignment pending.

### Engine invocation routes and native entry dispatch at `.3.3.16`

- Activated from clean `69dacfc66475fe2458ab9ba35dc67e1d3d2d0a23` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine lines 1895–3394 in five complete 300-line chunks: 1,500 lines / 60,181 bytes; full-file and range identity match baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Range SHA-256 `ef31712d5bd310e7ed44778a3821dc484891cc9ea0086693374d1fdd9aaeb3ee`. The native blind loop is complete; `.3.3.17` owns the regex loop from 3395 onward.
- Fresh contexts preserve accumulator/direct projections and optional trace, diagnostic, semantic and authority channels. Root errors use validate_spec/no_rules_defined or select_entry_rule/entry_rule_not_found; later child lookup stays separate. The diagnostic finish adapter prioritizes retained Sink, then Exit, then Runtime; generated trace replay preserves Sink/Exit outcomes.
- Native direct entry starts staged authority and installs observation/child authority before typed-write/slot checks and root resolution. Generated contexts expect caller-validated input; supporting source-emitter 355–420 and 997–1030 confirm typed-write/receiver validation before emission and after decode. Parent semantic result precedes staged completion, so it does not certify enrichment or trace success. No combined failure is freshly measured here.
- Native dispatch balances recursion, recognition and variable frames around Result; body errors capture attribution before unwind, child accumulator additions are truncated, and passive action terminals are skipped. Selected matches retain ordered slot identity, entry/local captures and scalar observation positions. Blind repeated AND/OR, ordinary AND value collection, lifecycle order and progress checks remain distinct. Existing .41.2 owns stale own-regex comments; no blanket error-restoration guarantee is inferred.
- Four fresh managed neutral checks pass: root 8 selections/3 failures/3 strict/7 complete/54 mutations; semantic 6 groups/20 queries/128 mutations/9 complete/6 admitted; diagnostics 3 helpers/11 render rows/6 scenarios/8 complete/20 mutations; staged 9 rollout/123 mutations plus public6/17/10/129. Native results remain dated; five existing Knowledge cards are reconciled. Codebase No; physical book Yes, formal alignment and runtime/public/policy repairs stay pending.

### Native action loops and nested-write coordination at `.3.3.17`

- Activated from clean `b06b27cfef0b30487b32de29b5e2b8dbe8801d6e` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine lines 3395–4887 in four 300-line chunks and one 293-line chunk: 1,493 lines / 60,008 bytes; full-file and range identity match baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Range SHA-256 `10bef263c4791d83770e194ef19fc0fa8c5c9894e075433f0109d06a201c018c`. The native loop, dependency scanners, fluent action execution, statement controls and nested-write coordinator/classifier are complete; `.3.3.18` owns the recursive container-write body from 4888.
- Native regex execution derives cursor policy per iteration; flagged candidate-before-LS, commit-after-LE/before-IT and successful terminal tails preserve unflagged ordering. Repeated AND tracks slot sequence separately from complete repetitions. Explicit action values collect per hit, lifecycle returns retain whole-rule control, and minimum/progress/normal-return paths remain distinct.
- Eager child-call/retv scans traverse current typed arguments and callbacks but ignore inert literal construction. Direct observation/self-edge branches avoid implicit pre-dispatch; other blocks either scope the prior child result or run before child dispatch. Fluent push preserves matching child slot identity; statement gating, symbolic switch cases, condition-before-limit while, I-phase direct-binding tracking and typed array transforms retain their separate boundaries.
- Nested writes evaluate segments left-to-right then RHS before classification and binding snapshot. Classification retains authored spans and evaluated path prefixes; the coordinator publishes only after recursive construction succeeds. Recursive helper internals and full guard/evaluator bodies remain later reading. Four native diagnostic controls confirm dense append/gap behavior and a saturated write index: exact 2^64 is reported as usize::MAX, while the next representable larger value is an invalid selector. Existing .55.1 owns repair; hashes, retained harness and precise limits are in the numeric Knowledge card. Three prior CLI controls expose only generic invocation failure.
- Six managed neutral checks pass: gap 9 complete/63 semantic/34 public mutations; repeated result 8 modes/10 specials/8 complete/54 mutations; write 5/7 syntax/11 successes/16 structural failures/105 mutations; binding 11 migrations/7 executions/6 invalid selectors/8 constructors; callable 7 literals/11 calls/23 mutations; logical 17 truthiness/10 helpers/3 effects/26 mutations. Historical native/carrier counts remain dated. Codebase No; physical book Yes, formal alignment and runtime/public/policy repairs remain pending.

### Recursive writes and expression invocation scopes at `.3.3.18`

- Activated from clean `1f38a1eae9fda6c487d32e0fad783f15f6f67d9e` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine lines 4888–6385 in four 300-line chunks and one 298-line chunk: 1,498 lines / 58,503 bytes; full-file and range identity match baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Range SHA-256 `ccca6acdfb4fd3c40a827d0fc600effd2d6d446ce76224504e4cc0919ed8e0e0`. Recursive writer, array-end/child-push helpers, guard/site scanner, full expression dispatch, user-function/codeblock invocation and method classifiers are complete. `.3.3.19` owns the trailing-block chain continuation from 6386; bang traversal and context identity internals remain unread.
- Recursive writes build missing intermediates from the following selector, reject kind conflicts and array gaps with exact path/span context, and publish only through the preceding coordinator on success. Read access keeps its separate numeric-coercion/undef behavior. Array-end mutations start only on bare receivers and pass their updated array to subsequent value calls; child-push resolves compiled-rule dispatch before its destination and may reuse the scoped child result.
- Expression guards precede evaluation and delegate active target identity to RuntimeContext. Source scanning supplies first-per-attempt diagnostic sites with Unicode-scalar conversion, not identity authority. Expression dispatch keeps lazy controls, typed progressive/staged/recognition nodes, eager user-function arguments, inert codeblock construction and receiver families separate. Recognize-once cancels its scope on child error; observation finishes and stores its descriptor before returning the child Result.
- Named functions take/restore all caller stores around fresh fixed/rest bindings; callable values install/restore parameters individually around the caller's other stores. Both clean up after body Result. Complete body evaluation, helper fallback, context identity and traversal internals retain later owners. Five Knowledge owners distinguish current source observations from dated native/carrier evidence; the user-function corpus count is historical and the codeblock card points to the subsequently completed generic normalization.
- Four managed neutral checks pass: write 5/7 syntax/11 successes/16 structural failures/105 mutations; bang 4/14/5 syntax, 10 successes/8 pre-commit failures/167 base + 592 composition mutations; callable 7 literals/11 calls/23 mutations; binding 11 migrations/7 executions/6 invalid selectors/8 constructors. No fresh native run, runtime change or new defect claim; codebase No, physical book Yes and formal alignment/repairs remain pending.

### Receiver traversal and final-assignment guard diagnosis at `.3.3.19`

- Activated from clean `acbadc0fce4abdc03585c0fd26c9a1f7545958e2` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine lines 6386–7878 in four 300-line chunks and one 293-line chunk: 1,493 lines / 55,743 bytes; full-file and range identity match baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Range SHA-256 `f6072a21e05fe62ac2e290ec8815226d99ed0dddb2f9153dec25b0ea14cf073e`. Complete trailing-block routing, pure/bang traversal and callback frames, all receiver value-chain bodies, value-block/while/final-expression evaluation, helper with and scalar-target resolution; `.3.3.20` starts the next target/helper window at 7879.
- Pure hash traversal is sorted-key DFS through hashes only; arrays recurse by index through arrays only. Cross-kind aggregates are leaves. Walk returns the snapshot, map rebuilds without revisiting replacements, reduce threads its accumulator. Callback/initial-value expressions evaluate before root-kind dispatch; contextual callbacks take zero positional arguments, explicit callables take the leaf/receiver, and temporary frames restore after Result.
- Bang traversal activates resolved identity, rebuilds the original shape, releases its guard on callback failure, publishes after complete success, then releases before continuation. Dynamic receiver calls retain family/terminal checks, numeric arity gates and join_values argument placement. Value blocks skip inactive branches, handle local returns before final-value evaluation, and propagate loop returns separately from ordinary continuation.
- Six paired Rust primary CLI/Perl Get cases plus six direct native diagnostic cases confirm final scalar/nested same-receiver assignments bypass Rust's guard; nonfinal/explicit-return controls reject and an unrelated final assignment agrees. eval_block_final_expr dispatches these assignments directly, omitting eval_expr's guard; nonfinal statements keep their own guard. New .58.1-.3 own repair, carrier recurrence and public closeout after prerequisites. Exact sources/values/diagnostics/spans/artifact hashes live in rust-final-value-assignment-receiver-guard-gap; no generated or other-backend result is inferred.
- Four managed neutral checks pass: bang 167 base/592 composition mutations; write 5/7 syntax/11 successes/16 structural failures/105 mutations; callable 7 literals/11 calls/23 mutations; logical 17 truthiness/10 helpers/3 effects/26 mutations. Manifest census is 105, not a fresh corpus execution. Six Knowledge owners retain dated native proof and qualified claims. A one-second compiler sample locates all 798 worker frames in procedural-macro dlopen/fcntl; compilation and six probes later complete without intervention. Sample/image inventory retained, exact observation in existing latency card. Codebase No, physical book Yes, formal alignment and runtime/public/policy repairs pending.

### Helper dispatch and substitution composition diagnosis at `.3.3.20`

- Activated from clean `14a66b821d3ebb64eb91781ebd44e0b80e1f2030` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine 7879–9278 in five 250-line chunks and one 150-line chunk: 1,400 lines / 65,528 bytes, full-file and range identity equal to baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; range SHA-256 `efaac6843678440f2636d90bcaa523911a2e43f37a4e4eeb5d7f5d6ae57248fb`. Complete target/aggregate argument and raw-name resolvers plus the helper prefix. The range ends inside match_end_line; .3.3.21 owns its suffix and later helper arms.
- Bare target admission is explicit; aggregate consumers use private snapshots or scalar-held aggregates according to binding kind. Only explicit flat forms splice list/hash contexts. Raw rule/mark/capture identifiers retain symbolic identity. The central helper validates numeric arity, snapshots trace context, and dispatches assignment, return, constructors, copies, child calls, gap/capture, substitution, splitting, string transforms and diagnostic output.
- Entry/match/anonymous/named capture helpers route through typed span/position authority; successful take operations advance boundary state only after valid reads. Noncursor readers stop at local match start, cursor forms at cursor, rest forms at input end. Rule-local mark copy deletes the destination when its source is unavailable. capture_until_boundary compiles valid named-rule patterns, selects the earliest next boundary, and advances only after a valid typed span; no valid boundary rule yields undef.
- Ten paired Rust primary/Perl Get cases separate four ordinary flag controls, four active-receiver calls and two unrelated callback writes. Bare-g ordinary substitutions agree. Quoted flags diverge in Perl; all six callback calls become unsupported-helper sentinels with unresolved=1/ready=0, while Rust executes substitution and omits active-receiver protection. Lowered/generated text pins the Perl statement/value dispatch gap, and Rust receiver_write_attempt plus direct set_scalar pins the guard omission. .59.1-.59.4 own flags/lowering, target guard, carrier recurrence and public closure; .58 remains the separate final-assignment repair. Exact sources, results, error type/stage and hashes live in regex-substitution-callback-and-flag-discrepancies.
- Four managed neutral checks pass: typed source 14/0/231 with 92 helpers/7 aliases; gap 9/0/63 plus public 8/15/10/34; diagnostic output 3 helpers/11 render cases/6 scenarios/8 complete/20 mutations; binding 11 migrations/7 executions/6 invalid selectors/8 constructors. Five existing Knowledge cards are reconciled and one added; .41.2 owns stale target/rule-label comments. No compiler or unconsumed job remains. Native generated/other-backend coverage is not inferred. Roadmap Yes, codebase No, physical book Yes; formal alignment and repairs remain pending.

### Helper completion and slice/scalar boundary diagnosis at `.3.3.21`

- Activated from clean `19e943a4b7cbe68a5f538ff3f0ef17c54fc549f3` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine 9279–10777 in five 250-line chunks and one 249-line chunk: 1,499 lines / 59,677 bytes. Full-file/range identity equals baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; range SHA-256 `5fddd27a6b96bc622094a58f78d0fe597a9d721d2388d6b43992f58a523e7f3d`. Complete match_end_line suffix, remaining helper implementation, and test-module prefix through the unknown-helper table; `.3.3.22` starts the scalar/capture test group at 10778.
- Local match presence gates match length/offset/group results; optional coordinate inputs use typed authority independently. String length preserves array cardinality but string transforms coerce through to_str. Scalar arithmetic uses strict numeric conversion and finite-result normalization; min/max reject any invalid array item, while sum/avg/median/range filter generic numeric conversions. Array selection returns copies, equality/search use text, explicit flat forms retain contextual splicing, merge_hash updates existing keys, and hash view helpers preserve their specific order/default policies.
- Cursor control delegates to typed context. and/or consume already-evaluated operands; if/elseif/while evaluate raw conditions and selected bodies. Switch compares its coerced subject with case labels rather than using truthiness. While checks its condition before the iteration ceiling. Unknown helper fallback tries bound codeblocks, uses typed failure inside an active codeblock, and otherwise warns/returns undef. Knowledge corrects an overbroad switch-truthiness sentence.
- Six paired array-slice controls show valid/exact-end agreement and four Rust panics where Perl returns []; a seventh Rust-only large-count case overflows start+n. Eleven total paired cases include five scalar vectors: literal undef and unbound identifier null both reveal seven transform discrepancies and false-input predicate/empty-old replacement drift; empty-string transforms agree. Twelve descriptors are ready/unresolved=0; exact lowerings/generated source show Perl bounds/defined/empty-needle guards. .60.1-.60.3 and .61.1-.61.3 own repairs, carrier proof and public closure. New slice/scalar cards retain 72 artifacts/360,400 bytes plus manifest identity. No generated execution or other-backend result is inferred.
- Test reading distinguishes value versus wrapper assertions, entry selection, recursive observation binding before error propagation, lifecycle/REP, blind calls, declarations and unknown fallback. Some legacy smoke tests assert only shape or marker membership; reading them does not prove exact order, repetition count or accumulator content. Three managed neutral checks pass: logical 17 truthiness/10 helpers/3 effects/26 mutations; scalar numeric 55 cases/18 helpers; typed source 14/0/231 with 92 helpers/7 aliases. Four existing Knowledge owners reconcile and two are added. All jobs are consumed; no compiler ran. Roadmap Yes, codebase No, physical book Yes; formal alignment and runtime/public/policy repairs remain pending.

### Capture/control test reading and default-selection diagnosis at `.3.3.22`

- Activated from clean `bcc2b2abd9d59ab76b3796227bee0102c5472fae` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine 10778–12246 in five 250-line chunks and one 219-line chunk: 1,469 lines / 52,089 bytes. Full-file/range identity equals baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; range SHA-256 `d74f74006d1009d4732dcde8aa1795e334541f22cb9c3207c2c3920b55de3ee8`. All owned source bytes are read; next begins nested-write tests at 12247.
- Exact assertions distinguish whole-match text, captures-only compacted indexing, absent null, named reads/maps and numeric presence. Control tests check branch values and skipped exit_now bodies; some save/restore retry tests only check success, and return_undef-after-return only checks outer shape. Those weaker assertions do not prove the behavior suggested by their names. Extend .41.2 to stale entry/local identity comments.
- Unicode tests check character substring/slice/position/column/length values. Input-end line/column, named marks, deletion/reversal, and anonymous span/take families pin their individual endpoints and post-read cursor advances. Explicit OR{1,1} fixtures isolate a single seek. Boundary capture checks both annotations and the first cursor/rest; callable failure restores the previous parameter and active identity. No fresh native unit run is inferred from reading.
- Five paired Rust primary/live Perl Get controls confirm coalesce skips defined empty text/aggregates and both coalesce variants execute later assignment operands. Perl keeps the selected defined value and skips later assignments. Source shows omitted lazy dispatch, the coalesce nonempty test, and recursive Perl conditional lowering. Five descriptors are ready/unresolved=0; actual generated/lowered captures retain conditionals. .62.1-.62.4 own definedness/laziness, receiver routes, permanent carrier/backend recurrence and public canonical closure. Aggregate contract admission remains explicitly pending.
- The ephemeral original Perl collector stringified JSON booleans; a Boolean-preserving rerun proves this was an observer artifact, not Perl false-kind drift. Retain both versions and use only typed results for product claims. New coalesce Knowledge plus four reconciled owners retain exact limits and a 40-file/158,215-byte artifact manifest. Three managed neutral contracts pass: logical 26 mutations, typed source 14/0/231, rule-local cursor 36 spellings/60 mutations. All jobs are consumed; no compiler ran. Roadmap Yes, codebase No, physical book Yes; formal alignment and runtime/public/policy repairs remain pending.

### Engine suffix, regex wrappers and nonzero-cursor context at `.3.3.23`

- Activated from clean `fe3cabf1934eaf7181745091f7a5d423c991b895` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read engine 12247–12694 (448 lines/17,318 bytes; SHA-256 `24430ed2a65031d349f6a20d0e8f521d9f8d49da1bc6ccd5666ac6499c192716`), complete helpers.rs (850/33,507; `850047e85f82e0ab3799e02960c245c49077ab3e7bde593c83887b187bffeb3e`) and runtime lib.rs (66/2,440; `3f69d8e02549bf76d3f3495935403b6f87b65f0e9a14c74885f4412b2f64112c`). All 1,364 lines/53,265 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Engine comprehension is complete; next reads embedded MCP contract bytes.
- Nested-write tests assert exact segment/RHS order, structural error fields and preservation of RHS effects without partial publication. Detachment tests mutate all four value carriers independently; expression failures assert the completed prefix and read exclusions retain original state. Receiver tests assert callback rollback with unrelated effects, release via a successful second invocation, post-commit continuation failure and selected guard-before-evaluation routes. Those tests do not cover .58/.59 final-assignment/substitution exceptions.
- Regex wrappers normalize ASCII named captures, lower-unbounded quantifiers and one leading positive flag toggle, retain individual compiled slots and wrap each branch for combined choice. Extraction separates internal groups from compact participating captures/absolute spans and named values. Tests check ties, duplicate required slots, optional/empty captures and normalization; reading does not imply fresh native execution. Public lib exports include source_emitter and hidden staged generated-consumer authority; .41.2 already owns its stale no-generation sentence. Reconcile the old emitter card's 8/91 milestone with admitted 105 coverage.
- Six informative collected-rule pairs on xhello show plain agreement and five Rust discrepancies for ^, input-start, positive/negative fixed lookbehind and word boundary after consuming x. helpers.rs slices input[pos..] in all three matching implementations; Perl LinkedRE retains the original scalar/pos. Six generated/descriptor captures preserve both dispatch slots and three ready/unresolved=0 rule records. .63.1-.63.4 own whole-input seek repair, consume/required slots, carrier/backend recurrence and public closure. Only ordinary choice seek is freshly exercised. The initial six null-only chain probes are retained as inconclusive observation scaffolds, not parity proof.
- New regex-context Knowledge plus six reconciled owners retain exact source/limits and 37-file/618,941-byte evidence manifest. Three managed neutral contracts pass: writes 105 mutations; receiver mutation 167/592; slot identity five fixtures/two diagnostics/59 mutations. Exact result/error and source/descriptor assertions pass. No compiler ran and all jobs are consumed. Roadmap Yes, codebase No, physical book Yes; formal alignment and runtime/public/policy repairs remain pending.

### Embedded MCP contract prefix and generator identity at `.3.3.24`

- Activated from clean `71e6df55437e017af6719de0d5dab3ff42330ae7` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read module lines 1–6 (297 bytes; SHA-256 `15bd59bda5fca3d501c833233048c1c469b1a9e763203ad6cf74d588240c43f2`) and file bytes 298–65536 of line 7 (65,239 bytes; `265dc365798d2970032cfe024b9fa0fc014d7fefbff6c6c16f4d2c2ab83f0ce0`) in eight 8,000-byte segments plus one 1,239-byte segment. All 65,536 owned bytes/full module equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. The final fragment ends inside semanticQueryRequest.additionalProperties; .3.3.25 begins at file byte 65537. Full-module machine identity does not claim suffix physical reading.
- Read all canonical frames, contract manifest, corpus and schema prefix: server discovery and two read-only tools; canonical semantic text plus structured content; semantic ok=false separate from transport isError; fixed error envelopes; lowering-only explicit policy overlays; opaque host-registered handles; metadata/transport ceilings and EOF lifecycle. Corpus retains 35 ordered canonical frames, ten raw cases, ten lifecycle cases, four handle states and four policy cases. The visible tool schemas retain 72 fact keys, 128-character/UTF-8-byte contract strings, exact budget/page ceilings and read-only annotations.
- Supporting complete reads: tools/generate_rust_mcp_contract.py 52 lines/1,822 bytes SHA-256 `081e231298aad254499681fbfc04a5be0e343358896770d865a39b7a5c49f7ca`; tools/mcp_contract_binding.py 138/5,192 SHA-256 `c1290d629cb471f5bc27cbc1ed9b745128a8bed95ecfa31a5ad1ca84018dad36`; both baseline-identical. The builder verifies exact seven-path/digest inventory, root containment, object decoding and canonical frame order/encoding. The renderer hashes canonical JSON and selects safe Rust raw delimiters. Default generator mode checks bytes; only --write rewrites.
- Fresh managed generators confirm Rust 83,225 bytes and Perl 83,411. Exact decoded reproduction verifies Rust module hash `7473a113474d090a1304ffc0d419de18b6b97c10639e7a484e5625abc83e7ece`, embedded JSON 82,882 bytes/hash `a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001`, and manifest hash `e068519994a7d4fb8e4c8ece0e277a470f48204d4c670f915ba49052a52630b3`. Four success-frame text/structured pairs are exactly equal; two Knowledge owners qualify old sizes and retain current scope. Neutral transport 35/10/10/76 and admission 5/5+6/6 complete/141 pass. No native server or six-runtime execution is rerun, no compiler ran, and all jobs are consumed. Roadmap Yes, codebase No, physical book Yes; startup alignment and repairs remain pending.

### MCP bundle suffix, frozen schema runtime and registry dispatch at `.3.3.25`

- Activated from clean `83b9bfe3435d5c8a71303dc1a48081a0bca61aed` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read mcp_contract.rs file bytes 65537–83225 (17,689 bytes; SHA-256 `107aa4596c942253f445b4969bbf0d1d2bdbf86e2c8a964820ba15b4c9456c2e`), complete mcp_contract_runtime.rs 1–582 (19,931 bytes; `a048e41cac8a701a90c0189688576f24dabe6e19e490bef6eb8e957886a59a21`), and mcp_server.rs 1–769 (27,514 bytes; `190dc4430715ea23174db46f150bbef5978e79c417ca2f4492f6799a6667fa01`). All 1,352 lines/fragments and 65,134 bytes/full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range was read without truncation. The complete generated MCP module is now physically read.
- The bundle suffix completes semantic schemas, recursive shapes, tool/error shells, four semantic payloads and seven hashes. OnceLock verifies the frozen binding once; callers receive clones. The bounded validator implements exact local refs, recursion 256, object/array/composition rules, character/byte limits and two specific patterns rather than general JSON Schema. Server registration validates host index capabilities, authorization/clock/capacity/expiry and lowering-only explicit policy, then creates a unique handle in at most sixteen attempts. Prepared dispatch, cancellation and shutdown retain/clear ownership deliberately; direct dispatch clears after response creation.
- Rust source confirms the already-owned `.36` order discrepancy: unknown method, then unsupported version, then complete named schema. ADR 0058 still references ADR 0055 metadata-first ordering. Existing Knowledge and `.36.1` now include this bounded source evidence; the dated six Perl paired controls remain distinct from unexecuted mixed-failure Rust controls.
- The exact existing native entropy/clock/panic test passes 1/1 (177 filtered; 2.43 test seconds, 524.920 total, reported build 6m10s) with --exact --nocapture. Its private synthetic panic returns fixed -32603 while captured stderr prints the fixture text and source location; the server source installs no panic hook. The assertion covers returned JSON only. New Knowledge `rust-mcp-caught-panic-stderr-gap` and `.64.1`–`.64.4` own host/library output scope, bounded repair, isolated-process recurrence and public/canonical closure. This does not demonstrate external panic reachability, real-data disclosure, or other-runtime behavior. Captured stderr 798,784 bytes SHA-256 `7faf686c80974299e418a53af61d8034329ba65317c706d13992218010bf1bc2`; stdout 192 bytes `4f4ab0684f4f3998ded7103755a7cb0020b1d8f3fc1e97d2454daa364f7d4b11`; exact command/status and hashes are durable in the fact card.
- Managed Rust binding is byte-fresh (83,225); neutral transport 35/10/10/76 and admission 5/5+6/6 complete/141 pass. Dependency build warnings remain separately owned (1,870 pgen/26 rgx-core). All native/neutral jobs and results are consumed; no artifact recovery/purge or runtime/public/policy repair occurs. Roadmap Yes, codebase No, physical book Yes; startup alignment and queued repairs remain pending.

### MCP server suffix, strict wire and EOF byte boundary at `.3.3.26`

- Activated from clean `d495001609729b0a753a2a1a1551aacbd6089ffa` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read mcp_server.rs 770–1342 (573 lines; 20,152 bytes; SHA-256 `38ff83e81b71e22e93697d11b2691d52d0985e87edbee813c2ca24a6ed5f67ee`), complete mcp_wire.rs 1–759 (25,848 bytes; `261136a3af1acde8135152d60a6947cecceddc574fa1d4167f7ed60927c83c15`), and primary_cli.rs 1–168 (5,296 bytes; `af9a39d488ba049ef264ad31f8ced17e7a8e283880379c9dc985eb1b1cf88fdc`). All 1,500 lines/51,296 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range read without truncation. Server and wire are now physically complete.
- Server suffix projects lowering-only capabilities, checks explicit source/digest/page/budget components and preserves omitted native diagnostics. Tests use dispatch counters for six denied changes, plus registry and cancellation ownership. Wire retains bounded fixed chunks, decoded duplicate-key/depth/escape/number/id evidence, canonical LF output and prepared lifetime through flush; ordinary I/O failure clears ownership and emits only optional fixed text. Its dispatch-only catch extends `.64.1` source scope, without claiming arbitrary Read/Write panic coverage. CLI prefix separates output bytes/status and implements trace routing/reset/append/flush; remaining event/parser source stays next.
- Six existing native wire tests pass (172 filtered; 0.03 test seconds; 280.452 total, reported 2m42s build), including ordinary EOF and maximum CRLF separately. Twelve independently valid padded discovery frames around 1,048,576 bytes across EOF/LF/CRLF isolate a missing combined boundary: Rust accepts 1,048,577 bytes at EOF, Perl rejects -32700; all other eleven pairs agree. All calls reach normal EOF with one response and no optional log; Rust responses are exact canonical LF, compiler/program stderr empty. The root cause is retained maximum+1 CR allowance going directly through Rust EOF/decode without a final length check; Perl decode independently checks length. Supporting Perl MCPWire.pm 1–175 and MCPServer.pm 274–340 are baseline-identical; the initial unsupported log_handle diagnostic was corrected to log before any accepted cases ran.
- New Knowledge `rust-mcp-final-eof-byte-limit-gap` and `.65.1`–`.65.3` own Rust repair, delimiter/chunk/size recurrence plus six-runtime census, and public/canonical closure. Exact paired results 2,250 bytes SHA-256 `6df59fc3c3c5c61aed49f5acb976539c00035a7093333f0d38b1c68bd34fb23b`; scratch retains 44 files/3,996,953 bytes plus 6,144-byte manifest `315fbebf2999b26bd528703cc3c338613f5c4b3536b5b28604e4160abc29ace4`. Probe uses verified existing runtime rlib `7cbddb91b8c3043adaf709ae4344f94cf0b17f80e25569456445285648f8c972`, managed compilation 35.867 seconds after the unit job, public execution 0.468. No other-runtime or unbounded acceptance is inferred.
- Neutral transport 35/10/10/76 and implementation/admission complete 5/5+6/6/141 pass. Existing pgen/rgx-core build warnings remain independently owned. Rust MCP, panic-output and trace Knowledge owners now reflect precise source/proof limits. All jobs and results are consumed; no artifact recovery/purge or runtime/public/policy repair occurs. Roadmap Yes, codebase No, physical book Yes; startup alignment and repairs remain pending.

### Primary CLI completion and recognition authority prefix at `.3.3.27`

- Activated from clean `03f4577ae239c2e7015f03554b77b0eb95d523d1` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read primary_cli.rs 169–796 (628 lines; 20,657 bytes; SHA-256 `71eda498bf259b4a1e8417e6f4053b55a9fdde9c91711da6761d5cb8ad063b66`) and recognition_transaction.rs 1–872 (29,643 bytes; `dfedf17926e9398947f808724f52fcbfc3ea244d30f26c371ff632117ab396b1`). All 1,500 lines/50,300 bytes/full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range read without truncation. Primary CLI is now physically complete. Supporting recognition helpers 1387–1454 add 68 lines/2,030 bytes (`fc0d0cb1df36fd724a62147b3f353aef026883fb85ef26372aad22d0b85723dc`) without claiming the intervening runtime adapter read.
- CLI preserves exact manual option/error policy, removed parse-mode rejection, strict UTF-8, native named/file compilation versus inline parse/validate/compile, deferred input load, direct result execution and LF JSON. Medium trace includes source/input/top rule only; thresholds, UTF-8 byte escaping, trace sinks and executable-before-cwd repository discovery stay adapter-owned. The verified existing primary binary `ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a` passes 66/66 shared default cases in 60.311 seconds with empty runner stderr. POSIX and broader Rust gates are not rerun; no Cargo/rustc build occurs.
- Recognition authority owns checked monotonic generations, Arc source identity, Rc invocation state with weak token/frame links, detached cursor/boundary/mark snapshots, separate matched/payload-presence state, one attempt and explicit terminal transitions. Its nine allowed/eleven rejected effect vocabulary propagates through recursive fixed points; progress depends on cursor advancement. Unlike the measured Perl .38 defect, supporting restore_and_invalidate returns on Invalidated before modifying saved frame state. Existing `.38.1` and Knowledge now record this source boundary; no fresh Rust six-case post-terminal or authored/carrier execution is claimed.
- Fresh neutral recognition passes 138 node rows/250 calls/58 mutations, token 8/17, effects 6, marks 6, progress 8, rollout 9/9, public 3/26/45, guide 1/14/18, and current admission guards. Knowledge updates qualify historical 61-case CLI/3-of-9 recognition milestones and route Rust reverify through managed Cargo. CLI log `.linkedspec-data/scratch/startup86-cli-recognition/cli-stdout.log` 3,386 bytes SHA-256 `ec285ccb6f3db8052e02a29c46a978f51923f85bbb2fb16e156d31deae44160e`; command/status records retain exact invocation and exit evidence.
- The known process-group setup warning recurred during the prior slice's successful managed documentation correction; intended bytes were verified and actual PGID was not captured. The existing `.7` fact now preserves that bounded recurrence without a new causal claim or cleanup authorization. All current jobs/results are consumed; no artifact recovery/purge or runtime/public/policy repair occurs. Roadmap Yes, codebase No, physical book Yes; startup alignment and repair prerequisites remain pending.

### Recognition runtime completion and RuntimeContext source connections at `.3.3.28`

- Activated from clean `faa0aaee322dfbcb645e65200a8df292923ce5fe` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read recognition_transaction.rs 873–1547 (675 lines; 22,527 bytes; SHA-256 `a34a9b01b664ba66bbeb14ce6ca6a04e37614f30e860000985babbdf665660cd`) and runtime.rs 1–821 (34,295 bytes; `01b045dc00443ce00d8844e53105a27c21db69e95f08b26eab5f2e27eeb3fb92`). All 1,496 lines/56,822 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; each range read without truncation. Recognition transaction source is now complete.
- Live frames preserve cursor/boundary/marks plus private gap cursor, edge ordinal and candidate snapshots; rollback restores both. Entry-slot lineage checks parent invocation, active candidate and target rule. Commit rejects cursor regression; tail spans reach input end. RuntimeContext uses immutable Arc source and Rc parse authority with byte cursor registers, private marks, binding stores and explicit match-presence state. Entry/leave manage prior same-label mark buckets; public gap helpers project through typed source authority. Three gap unit tests were read, not freshly executed.
- Independently decoded catalogs contain exactly 92 unique helpers (47 capture/mark, 30 entry/match, 11 input/cursor, four cursor-control) and seven aliases with canonical targets. Fresh neutral recognition passes 138/250/58 at complete 9/9, gap nine complete/zero pending/63 semantic mutations with public 8/15/10/34, and typed source 14 complete/zero pending/231 mutations. No fresh Cargo/rustc/native recognition or alias proof is claimed.
- The recursive incoming JSON bridge and progressive/typed-record consumers join the existing `.55.1` conversion inventory without a new measured failure or reachable fallback-to-zero claim. Four canonical Knowledge owners distinguish source inventory/current neutral proof from historical native milestones. All jobs/results consumed; no runtime/public/policy repair, artifact recovery or purge. Roadmap Yes, codebase No, physical book Yes; startup alignment and policy prerequisites remain pending.

### Context observations, projections and typed binding stores at `.3.3.29`

- Activated from clean `de52680260dc660195cbfcf479e53c94b14bda3e` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read runtime.rs 822–2318 (1,497 lines; 49,031 bytes; SHA-256 `1cca319df4eaba99b77293203301ab0e55b341366c1cffdd357699d694dbec42`) in six untruncated ranges. Full file and owned range equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`.
- Recognition/observation adapters use local completion bases and the last matching callee; pending entry disarms after entry and pre-entry rejection reserves attempted-child identity. Detached nine-field observations distinguish rejected/aborted/accepted/failed, projecting accepted exit only on success. Source position/span adapters validate byte boundaries, clamp optional scalar coordinates/slices, sort detached capture maps and preserve absent invalid spans. Structured diagnostic capture is first-wins; output, semantic observation and buffered trace channels remain separate.
- Scalar/array/hash writes ensure binding identity and current bare kind. Declaration/scoped entry replace identity; scoped entry saves prior state and removes competing stores/descriptor overrides. Restoration internals remain the next window. Receiver guards resolve current identity rather than spelling, without closing .58/.59 dispatch gaps. Absent/Undef differs from bound Undef for aggregate mutation; bare pop returns the updated detached array while private pop returns the removed element. The saturating u64 identity allocator is source inventory only, with no measured exhaustion claim.
- Fresh focused neutral checks pass typed source 14 complete/zero pending/231 mutations, binding 11/7/6/8, write105, map167/592 and diagnostic3/11/6/8/20. Six Knowledge owners now qualify historical rollout/no-codegen wording and preserve exact source-versus-native scope. All jobs consumed; no fresh native runtime run, repair, public/policy change, recovery or purge. Roadmap Yes, codebase No, physical mdBook Yes; formal alignment and prerequisites remain pending.

### Context and semantic foundation completion with binding identity diagnosis at `.3.3.30`

- Activated from clean `98be3c19a761c81d0875d5e16a5bdada7eca1b10` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read runtime.rs 2319–2737 (419 lines/14,862 bytes; SHA-256 `8bf7a1de8c3d51e1769ef76a0d9d9717ad2fdff162f27f25d14cf05a7aa3621f`), semantic_index.rs 1–692 (25,946 bytes; `586f8a3804a1d68670453d508aa6400be8670196dbfb8fed4a78828cc31c5824`) and call_projection.rs 1–383 (12,604 bytes; `2699a196570566f1fbf6660cbf86d7b8ec22a970f0948eb61b7e0276f5d02286`). All 1,494 lines/53,412 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; all ranges untruncated. RuntimeContext and the semantic-index foundation are physically complete; bounded supporting source hashes remain in the retained manifest.
- Context restoration preserves/removes all scalar/array/hash, bare-kind, identity and descriptor-read surfaces; user functions move their store bundle while scoped bindings restore snapshots. Return values, action-edge results and recursion/cursor controls retain separate channels. SemanticIndex validates options, copies strict UTF-8, maps exact scalar/byte boundaries, captures compiled-or-failed source authority and offers ceiling-checked cloned projections without executing the target parser. Call projection merges source-ordered definitions and begins typed call/binding traversal; its remaining body is next.
- Six paired public SemanticIndex queries independently assert compiled snapshots, empty diagnostics, binding IDs and source excerpts. Rust/Perl agree for no function (zero records), unused function with one assignment (five records), two repeated writes and three distinct names. Three/four same-name writes expose Rust suffixes 0/1/1 and 0/1/1/1 versus Perl 0/1/2 and 0/1/2/3; all repeated suffix-1 records materialize the final RHS excerpt/span. Rust counts keys in a latest-binding map, which stays at one, then overwrites the repeated source-ref key. Perl uses a separate occurrence counter. New `.66.1`–`.66.3` own repair, query/carrier census and public/canonical closure; existing `.22` now includes Rust's separately measured empty-function gate.
- Probe compilation 335.326 seconds and execution 7.702 seconds exit 0; Perl 11.203 seconds exits 0; all stderr files empty. Verified runtime rlib remains `7cbddb91b8c3043adaf709ae4344f94cf0b17f80e25569456445285648f8c972`. Scratch `.linkedspec-data/scratch/startup89-semantic-bindings/` retains 37 files/35,637,599 bytes plus 7,182-byte manifest SHA-256 `d165a6e0a96f69406d61b51b5c9f274b34d396d0ae02f418364715bf89b4ff07`; paired assertions 3,110 bytes `14a227c09c40083cc5cff1a00dce688ed7ac566cc9296a0ac28a9d0cfa08f956`. No paging/get/relations, function-local repeat or other-runtime repetition result is inferred.
- Fresh neutral semantic6/20/128 with rollout9/0/admission6/0, callable7/11/23 and binding11/7/6/8 pass despite the new native query cases. One new/five updated Knowledge owners preserve source/current/historical scope; parent children now link existing .64/.65 as well as .66. Existing .41.2 owns stale semantic-index API comments. All jobs consumed; no runtime/public/policy repair, recovery or purge. Roadmap Yes, codebase No, physical mdBook Yes; formal alignment and startup prerequisites remain pending.

### Semantic call completion and independent signature/container evidence at `.3.3.31`

- Activated from clean `c7134e4dc3f0baa484f30b7b6019a36944da56c8` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read call_projection.rs 384–1288 (905 lines/29,888 bytes; SHA-256 `e971382f829d5e0c7fdcf3c9fcc9b5cb8c383066a0982447f04bf35379efe683`) and query.rs 1–589 (20,532 bytes; `a4cab55f188f209aa89c75d21b5828e2be4ddc63ba2907dceb09abe745866d62`). All 1,494 lines/50,420 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range untruncated. Call projection is physically complete. Read all 435 lines of ADR 0049 and bounded Perl call/explanation sources to reconcile normative evidence and source mechanisms.
- Call projection retains source-ordered definitions, bounded function-shape propagation, exact scalar-to-byte staged body checks, shell matching, explicit staged relations and shared generated-plan family. Its call scanner handles ASCII names, quoted strings and balanced parentheses. Query prefix defines typed shapes/defaults, projection-only operation dispatch, logical costs and exact validation through source ceilings; operation constraints and helper bodies remain the next window. Existing .22/.66 causes remain distinct.
- Six paired public Rust/Perl queries compile and succeed with no diagnostics. Both emit call_signature_accepts for zero/two arguments while the same response declares fixed arity one. Both omit trim inside an array RHS, although direct/nested trim controls appear. Five complete responses equal; the sixth differs only because Rust's array binding source is null while Perl retains its exact RHS. Independent signature/count checks and six Perl Get controls establish the bounded counterexamples: arity0/2 return null, arity1/direct/nested return x, array returns [x], all without exceptions/stderr. No Rust target-execution or other-runtime behavior is inferred.
- Both explanation builders format acceptance without checking compatibility; both typed call walkers stop on non-call containers. Rust additionally obtains binding source only from an emitted RHS call. New `.67.1`–`.67.4` own signature evidence, composite traversal/source, independent carrier/backend recurrence and public/canonical closeout. Source/query proof uses the verified .89 probe without a new compiler run; Rust queries 7.057 seconds, Perl queries 11.115, Perl Get 11.056, each exit0 with empty stderr.
- Scratch `.linkedspec-data/scratch/startup90-semantic-call-evidence/` retains 36 files/210,609 bytes plus 7,246-byte manifest SHA-256 `ace19ad5c4d9d7868b413017894086e7ff62eac3ca9badc12b27a44cf0cfc2d1`; independent assertions 2,084 bytes `01ffb7cbe877993595a1ebfef98c232070e3d73b92bcb99b123a91ffbbab71f4`. Neutral semantics pass six groups/20 queries/128 mutations, rollout9/0/admission6/0. One new/three existing Knowledge cards preserve precise limits. All jobs consumed; no runtime/public/policy repair, recovery or purge. Roadmap Yes, codebase No, physical mdBook Yes; formal alignment/prerequisites remain pending.

### Query and runtime projection completion with independent failure controls at `.3.3.32`

- Activated from clean `cc23abb97f54388e3aad505f32c636cdd5bfb740` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read query.rs 590–1003 (414 lines/13,758 bytes; SHA-256 `7713323eb7c6f02e57c40eee59a6b8dc4179eec1ef8ece5f1468aaeec6eb1781`), runtime_projection.rs 1–273 (9,816 bytes; `f6c771e25c969001b700655ef983f84333b7cb28fa6eca16ba4b259a2267c79d`) and static_projection.rs 1–808 (26,571 bytes; `1ec4cbd6eadf2f98fcb12cbfadc74e1b6963b993d1b97cd6860a681a32d2dba9`). All 1,495 lines/50,145 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range read untruncated. Query/runtime projection are physically complete.
- Query helpers enforce operation/filter combinations, primary-stream after-id pages, direction/kind breadth-first traversal, logical prefix budgets and structural source/fact projection. Runtime derivation validates typed event combinations, exactly one final succeeded entry result, stable identity format and existing selecting rule/slot topology; it clones/canonicalizes retained records and cannot replay input. Static prefix cross-correlates parsed/scanned/compiled owners and gates dependency explanations specifically on unknown_rule_reference; suffix scanners/shapes remain next.
- Four native constructor/query controls preserve correct missing-rule and invalid-slot failure evidence. Child[5] is caught by resolve_selector before the broad compiled-slot mapping, retaining regex_slot_index_out_of_range, exact arrow source and no false dependency decision. Child[0] compiles. The source-only suspected wrong missing-rule normalization is ruled out for this ordinary route; .23 records that limit.
- The token-return control unexpectedly compiles. Four follow-up query and paired Get/CLI cases establish two clean forbidden-use counterexamples: return(tx) and active copied=tx; both Rust CLI results are null with exit0/empty stderr, while Perl rejects recognition_token_escape. Legal return("ok") agrees. Rust stores Undef alongside a separately held token and ordinary variable reads never call reject_escape; the existing negative test invokes that private authority directly. New .68 owns authored rejection/carrier recurrence/public proof, not an observed token-object leak.
- A newline-only copy separately triggers a separator error at byte84 and the known .45 warning/drop; its semicolon twin isolates token handling. parse_var_or_call consumes whitespace before suffix lookahead without restoring the plain-variable newline. New .69 owns source-preserving separator repair and ordinary non-token/carrier controls; intended-body execution is not inferred from the warned case.
- Scratch `.linkedspec-data/scratch/startup91-semantic-failure/` covers 71 files/35,587,020 bytes plus 11,923-byte manifest SHA-256 `771a5f9bc682e9875a4bdb128ae1c39e292579d77f6c2204df5cedba544f4467`; independent assertions 455 bytes `975c9bb37c2bf1b42814974c73a4d0452ab298c8b923cf48838f5d1e36a67b5b`. Native probe compilation42.778s/initial run5.313s, exit0/empty stderr; all subsequent jobs consumed. Neutral semantic6/20/128 at9/0,6/0, diagnostic3/11/6/8/20 and recognition138/250/58 at9/9 pass. Two new/five existing Knowledge cards retain exact evidence and limits; no runtime/public/policy repair or recovery/purge. Roadmap Yes, codebase No, physical mdBook Yes; formal alignment pending.

### Static projection and event types completion with grouped-edge evidence at `.3.3.33`

- Activated from clean `c7c62c967091910dbb5fb8ea7d7c3df48ed37b41` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read static_projection.rs 809–1720 (912 lines/29,634 bytes; SHA-256 `e52ac33b7531021b1f7210cf8a6a9caf576a3b1afd92d88072b220431dd7343b`), semantic_observation.rs 1–133 (4,751 bytes; `5f570ff4a9d33aebe0c525afea6a6ae226e885e483e34ca486202e717a3c5e16`) and source_emitter.rs 1–437 (15,991 bytes; `61b041c8b26ff0ff793d31c24f3b3aff5b6b2b81dabc35880b259a27094cb9dc`). All 1,482 lines/50,376 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range read untruncated. Static projector and event/sink types are physically complete.
- Static scanning groups parsed members by line, tracks leading regex/quotes and bracket depth, resolves captured byte/scalar spans, derives explicit repetition and first known return/edge shapes, then sorts records by kind/order/id and relations by endpoint ranks/kind/id. Nine current internal tests were read, not freshly run. Event constructors separate slot/result fields, hash exact UTF-8 bytes and directly invoke a shared Rc/RefCell synchronous callback. Emitter prefix defines typed metadata/errors, ten families/five seek/five consume, two decode aliases, and pre-serialization identity/typed-write/slot validation; module bodies and later plan validation remain next.
- Five paired public queries isolate grouped projection errors. With -> ChildLong | Child[1], Rust marks both edges direct; renaming only ChildLong to Other restores Child's indexed form. Its helper searches the first label substring. Perl loses the second expanded edge's source/index because it joins flattened descriptor edges to one physical scanned member and extracts only that member's first target. Separate indexed members retain correct source/index facts on both. Three paired Get/CLI controls on b return "b" normally without warnings, proving the grouped block still executes.
- Two initial per-target-index groups compile as one blockless Rust edge versus two Perl edges. Rust parses labels before one final selector, then discards the unrecognized action remainder; this is construction/projection evidence, not target execution. New .70.1-.3 own exact grouped correlation, complete accepted grammar/remainder handling, and independent backend/carrier/public recurrence. No new selector syntax is adopted. Source-based selects_regex incompleteness is a source consequence; no fresh relations/observation derivation is claimed.
- Scratch startup92-semantic-target-index retains 17 files/51,409 bytes plus 2,609-byte manifest SHA-256 `3fb86ddcf0e1d0b09c35bb7b3b2cdd459b4b9f05ad401ce5594a7d18959a1955`; startup92-semantic-group-selector retains 39 files/90,984 bytes plus 6,124-byte manifest `252da991f555c3d798d6f88e79b638ce3efaacf6c91507f6794e824921c42ef7`, both beneath `.linkedspec-data/scratch/`. Independent assertions455bytes `dc3f6d9fc5697af6d32d499d73315857dc34a87c02ec251f814f323a2f00b5f4`. Verified existing probes/CLI reused with distinct recorded logical names; no full-response equality or new compilation claim.
- Semantic6/20/128 at9/0,6/0, cursor36/18/8/60 and generated metadata10families/strictRust105 pass. Query runtimes Rust2.551/3.824s, Perl10.897/12.078s; Get11.180s and CLI1.279/1.233/1.246s. All jobs consumed. One new/four existing Knowledge cards preserve exact limits; no runtime/public/policy repair, recovery or purge. Roadmap Yes, codebase No, physical mdBook Yes; formal alignment remains pending.

### Emitter completion, source authority prefix and native generated boundaries at `.3.3.34`

- Activated from clean `d3fd048f37bfa90fe371ef78e174a85ae008aff8` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read source_emitter.rs 438–1466 (1,029 lines/38,547 bytes; SHA-256 `777590070ae77d55f68f0dc673423a1af9dcb8e4b7f99f289219131d27ad785e`) and source_location.rs 1–464 (14,836 bytes; `3d0c9ca29b41093bb9eacf2b79e0f8aa37d6e8eb299f5e454e31267d752eb5a9`). All 1,493 lines/53,383 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every owned range read untruncated. Emitter physically complete; source materialization remains next.
- Adapters preserve contract-before-decode, typed write/slot/plan validation, selected-entry context and distinct sink/exit errors. Plan checks count/ordered labels/known matching family; two aliases are accepted only for matching families. Typed source values are private and authority-bound with checked unique IDs and exact UTF-8 scalar/LF coordinate tables. Three existing Knowledge cards record these bounds; selected Rust sections of the large rollout card were read after its whole output truncated, not falsely counted as full-card reading.
- Eight native identity controls emit seven modules and reject empty identity; three ASCII/quoted-whitespace/Unicode modules compile, four control-character modules fail because JSON escapes are emitted as Rust literals. Two actual executable modules/five roles each show ordinary parse siblings all return ["ok"], but recognition plain parse returns "ok" while default-options/disabled-trace/no-sink siblings return ["ok"]. .71/.72 own literal encoding, adapter coherence and the rewrite's unused import; 34 other dead-code warnings belong to uncalled roles in private probe modules. New cards retain exact causes and repair acceptance; no runtime/public repair is claimed.
- Scratch startup93-generated-boundaries holds 66 files/68,030,768 bytes plus a 13,446-byte manifest SHA-256 `efca34731a315b8f34dbd92d02d9be4ffd00f172fb3b40ef91abda228f795580`; independent assertions: 689 bytes `33d25d8edb7bb7c799465e949ab0c5c94e722a55c10da99fee5609df1e585f64`. Probe compile/run: 283.710/10.529s, runner: 110.168/1.373s; all outcomes consumed, libraries rehashed. Generated10families/strictRust105, cursor36/18/8/60, typed14/0/231 pass. No compiler delay cause, recovery, purge or fresh full gate claimed. Roadmap Yes/codebase No/physical mdBook Yes; formal alignment pending.

### Source materialization and loader completion with function projection at `.3.3.35`

- Activated from clean `39cdef6598a5cea1702bb13b2c794c9fbbfb2b47` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read source_location.rs 465–561 (97 lines/2,951 bytes; SHA-256 `38c645f896c1583e22a1b0767d1cb44e6c8c4a772b7dd8a66fcb678a1c2ebb5a`), spec_loader.rs 1–564 (17,279 bytes; `849dc6ae9775c693f7c112b6ed9bcbf5370e22f7f3d9bb3e07e3307ace9e2131`) and spec_parser.rs 1–836 (30,993 bytes; `084d6e35ed31dc11f3b6800daf6354c27b54a28a5129b4ab5a708f8cf7eaac60`). All 1,497 lines/51,223 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range read untruncated. Source authority and loader physically complete.
- Sealed materialization accepts Span/DerivedText, rechecks authority/source/range and emits provenance-indexed errors before detached text. Loader retains explicit roots, stable lexical candidate order, first regular file, Unicode path checks, strict UTF-8 and distinct pipeline stages. Full ADR0026 and native resolution cards reconcile historical Julia fallback wording; no resolution-policy change or new native loader execution is claimed. Current relative root paths are joined as supplied; cwd explicitly anchors cwd/exact relative candidates.
- Definition projection executes the embedded grammar, validates fixed/signature/final-codeblock forms and exact scalar body/source correspondence, normalizes function parent paths/job IDs, then dispatches actionir-body.spec jobs with fixed policies. Stripping preserves scalar positions and CR/LF, not multibyte byte length; signature/error helper suffix remains next. One new/four existing Knowledge cards record source facts and bounded dated claims; the rollout card hit 66,112/65,536 bytes, so its exact new Rust authority sections move to a focused card with a retained pointer. Fresh resolution14/9/4, typed14/0/231, diagnostic3/11/6/8/20 and staged9legs/123base+129public mutations pass; all jobs complete. No new repair, native/full gate, runtime/public/policy change, recovery or purge. Roadmap Yes/codebase No/physical mdBook Yes; formal alignment pending.

### Spec parser completion and staged authority prefix at `.3.3.36`

- Activated from clean `b6f6085c50a7a7ee8bf2b33a3e861e6d3c86b83c` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read spec_parser.rs 837–1022 (186 lines/6,357 bytes; SHA-256 `b94ca8b8ea63aebd258b5567b897429be974edd0f7c121a6846206487986e309`) and staged_ast_enrichment.rs 1–1267 (44,706 bytes; `7a479df9743d8e66ee2ceca7abde2a04dd3bb96d067e7330ff4d40194297fc2d`). All 1,453 lines/51,063 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; every range read untruncated. Spec parser physically complete.
- Signature helpers enforce exact six-field/version/arity/rest shape and typed scalar fields; definition-error presentation selects codeblock-specific messages and source-line/node context. Existing .55.1 adds private usize_field's checked-u64 versus finite-integral-f64 cast boundary and actual AST producers to its inventory; no new reachable function/numeric failure is measured. Frozen staged registry validates prepared entries/callback bindings, hashes opaque logical snapshot data, resolves only prepared candidates and narrows versions/top/capabilities/policies/detail/ceilings. Cache lookup stores only immutable compiled plans; key construction and lower helpers remain later.
- Context views separate detached local state from live invocation/job budgets and expiry; seed starts fresh registry/authority and rejects active recognition at completion. Current-depth execution prepares/sorts/validates before callbacks on an unpublished AST. Recursive coordinator creates counters once, validates each complete depth and schedules settled children next; detailed execution, safe points, cycle/decrease, detachment and rebasing helpers remain next. Five Knowledge cards retain exact scope. Fresh staged9legs/123base+129public mutations, typed14/0/231 and scalar55cases/18helpers pass; all jobs complete. No new runtime/public/policy repair, native/full gate, recovery or purge. Roadmap Yes/codebase No/physical mdBook Yes; formal alignment pending.

### Staged execution and bounded native counterexamples at `.3.3.37`

- Activated from clean `90ae57bb9814118c3fe041c0723d841d7feabb44` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read staged_ast_enrichment.rs 1268–2766 completely: 1,499 lines/53,102 bytes, SHA-256 `cb7d7f15fa8178e78ebcbc994486ea7c60df4ec30370736ebd42ee444eccd990`; range/full file equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Identity/cache fields, typed queue order, dispatch/safe-point authority, callback expiry, detachment, failure settlement, cycle/decrease, diagnostic rebasing and stitching are reconciled in bounded Knowledge cards; final validators remain next.
- Independent public host API probes assert 28 paired Perl/Rust target records: duplicate sibling targets reject after one callback, duplicate replacement succeeds and overwrites after two, queued-marker overlap rejects after one; distinct destinations and shared appends preserve both results. Root-only markers reject before callbacks without adopting root replacement as a feature. New .73 owns complete target reservation and corrects prior complete-depth wording.
- Twelve Rust returned-marker/control records isolate deep-key bypass and an invalid two-MAX-segment provenance panic. Backtrace identifies strictly_decreases:2121; ordinary forbidden-key records reject and valid recursive markers succeed. New .74 owns validation and checked provenance arithmetic. Six budget records show ordinary exhaustion rejects, one remaining succeeds, but MAX/MAX runs once with unchanged total; .75 owns saturating admission. No external data, release/backend extrapolation or runtime repair claim. Local manifest 48files/2,885,337bytes, SHA-256 `b87f41e3f3c796ff80a6a10df8cd2d6c8372eb866e3764323c1b88ee5cd6c218`; independent assertions `459cbd58c047336e9036c5e87eebc371fbfa6406ae692740438f8a5f67dddb42`. All jobs consumed, three new/three existing Knowledge owners reconciled. Fresh staged123base+129public and typed14/0/231 pass; no full gate/recovery/purge. Roadmap Yes/codebase No/physical mdBook Yes; formal alignment pending.

### Staged source completion and generated Unicode prefix at `.3.3.38`

- Activated from clean `77cad4543e72ab304ce2a66b26a876b02cd6d3c4` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read staged_ast_enrichment.rs 2767–3058 (9,634 bytes; SHA-256 `834cfb562377519aee92c2868e90e5ad564ba78eb0295cb289964bc5ca5265b5`), staged_parse_job.rs 1–290 (11,273; `5f5aad25051a97d03d93008b214ba1652e7e6cf7243b884668ae18f8460fd61d`), staged_parser_registry.rs 1–712 (24,568; `5509da5b6729544894f7158b9e5a8540f76191cca8620c71518e91eb5571f023`) and unicode_case_mapping.rs 1–206 (5,313; `00c0ec0fcd97c4d6208ab8fe99957565274fa5e0056af7f120be27b869055e57`). All 1,500 lines/50,788 bytes and full files equal baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`; all ranges read untruncated. Three staged source files physically complete.
- Final v2 candidate/string/numeric/digest validators and recursive canonical hashing are reconciled. Declaration provenance uses exact direct/derived shapes and live source-authorized positions/materialization, distinct from .74's returned JSON boundary. Legacy v1 normalizes/sorts the full queue, invokes the same four built-in phases with optional trace, constructs cache-key records without a plan store and leaves policy enforcement to function integration. Existing .55.1 inventories its floating usize conversion without a new measured failure. Six existing Knowledge cards retain exact scope.
- The generated Unicode prefix pins contract/version/digest and opens sorted lower mappings, including dotted-I expansion and identity entries. Fresh offline regeneration byte-compares neutral JSON and all five backend modules and verifies 1,563 lower/1,581 upper, 158/464 properties and twelve fixtures; staged123base+129public and typed14/0/231 also pass. No new native/carrier/full-gate result, runtime/public/policy repair, recovery or purge. Roadmap Yes/codebase No/physical mdBook Yes; formal alignment pending.

- Mandatory rollover and capacity: exact segment 4983 source/blob/hash/count and unchanged-prior-manifest proof passes. ADR0106 changes only 29→30 collection files, 28→29 manifest lines and 16,384→16,463 manifest bytes; final staged canonical receipt is required before landing. The current book links the governed store and contains no stale numeric manifest limit.

### Unicode lower-map completion and canonical evidence at `.3.3.39`

- Activated from clean `eba1a0edb14463e737003025a8d66ffa4f853801` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read unicode_case_mapping.rs 207–1706 completely in five untruncated ranges: 1,500 lines / 38,103 bytes, SHA-256 `285db242fb8cd77506627568d96f91fd09a5ae4fefad69426331f730f4ea928d`; full file/range equal baseline. Lower table complete through supplementary entries; upper prefix includes non-invertible full expansions. The contextual evaluator remains unread. Fresh Unicode generation and twelve neutral fixtures pass with counts1563/1581/158/464.
- Consumed .3.3.38 canonical exit0 and exact receipt promoted to `eba1a0edb14463e737003025a8d66ffa4f853801`: all nine doctrines, mandatory consumers/locality/five relocated anchors, CLI66/66 twice, Phase0 1032/1032 in1100s; 25 optional gates skipped. The existing macOS launch Knowledge card records the full log hash/size and both fully consumed, retained 32-line samples; their pre-main frames do not establish an OS cause or sampling workaround.
- Five existing Knowledge cards preserve mapping semantics, exact completed verification and static-probe evidence scope. Rerunning the .3.3.37 statically linked probe cannot prove a later runtime repair without rebuilding and verifying library identities. No new defect, runtime/public-book/policy repair, recovery or purge; roadmap Yes/codebase No/physical mdBook Yes, formal .4 alignment pending.

### Unicode upper-map completion at `.3.3.40`

- Activated from clean `fe6d2638c8aa5cecebc214ce33c07c8b1a770278` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read unicode_case_mapping.rs 1707–3156 completely in five untruncated ranges: 1,450 lines / 37,746 bytes; SHA-256 `53e3bf1abba654fbab0a398f277c467e627fdc5b2d57388616d48504ffbd1f01`. Full file and range equal baseline. The upper map is now complete through U+1E943; ordered combining expansions, ligatures and many-to-one casing preserve the pinned contract, with no normalization or inverse-conversion promise.
- Existing Unicode Knowledge reconciled. Git confirms generation/runtime inputs unchanged since .3.3.39; its five-module regeneration and twelve neutral fixtures remain retained proof. Property ranges/contextual evaluator await .3.3.41. No new runtime test, defect, public-book/policy repair, recovery or purge; roadmap Yes/codebase No/physical mdBook Yes, formal .4 pending.

### Complete Unicode reading and final batch checkpoint at `.3.3.41`

- Activated from clean `f3a26cd55982e9b5285349b38bc9b96eb8b9666e` after the prior commit, passing post-commit pointer, and empty-brief/clean-status verification.
- Read unicode_case_mapping.rs 3157–3859 completely (703 lines / 16,474 bytes; SHA-256 `d87280ba0efce3ba229fbf2f064a6c82f549d808d9b04fdebe583912d2a74f8d`) and callable_codeblock_literal_contract.rs 1–791 (791 lines / 27,469 bytes; SHA-256 `7b867d0449c8b168d28d85b994ceb97ba2c075130d63c455d76fdbd7b1d54e21`). All six chunks are untruncated; full files/ranges equal baseline. All 3,859 Unicode lines / 97,636 bytes are now read. Binary-searched properties, original-scalar Final Sigma context and full mappings agree with the completed Perl evaluator.
- Callable prefix reading distinguishes exact native/reconstructed records from generated error-code substring assertions, inert state from invocation, and source inspection from emitted execution. The contextual suite prefix covers descriptor/body/job metadata and eleven route results; the eager-block test only starts at the boundary. Four existing Knowledge cards preserve these limits. Fresh Unicode regeneration/12 fixtures and callable 7/11/9/7/4/8/23 checks pass; no new native callable execution is claimed by reading.
- Independent Git census verifies all 99 preceding first-parent batch commits after `a5d5dcd2955aaaa41166bd87de6bdc39a4502bc4`, with each recorded leaf/hash in order. Item 100 requires exact staged canonical CI before landing; the completed gate summary/log identity belongs in its commit body, and the promoted exact-HEAD receipt governs final clean push. No new defect, runtime/public-book/policy repair, recovery or purge; codebase reading remains No and formal .4 alignment is pending.

### Callable completion, named marks and corpus prefix at `.3.3.42`

- Clean activation `fb307dae35d0ecfdcbb4b29e65bec36855d6971b`; all 56 owned scopes read in four untruncated groups, 1,500 lines / 45,529 baseline-identical bytes. Callable suffix SHA-256 `d3a518d533d0a4b28dd118a1ff36c39725213304586f1633ef22f7da8d1ec894`; named-mark consumer `00750f546668f63acd29ddcf732f869262f6ea9833ae503ae9b82e5a9d6dccce`.
- Callable suffix completes eager-block preservation, typed-final-value diagnostic fields, standalone contextual execution and semantic signatures. Named-mark assertions cover native/reconstructed/validated generated-plan values plus emitted source inspection; this consumer does not independently compile its emitted source. Existing Knowledge owns these exact limits.
- Corpus prefix includes autoexist, six capability families, vhistory, two EBNF fixtures and hlink; hlink_curly_brace source line 29 and its input remain `.3.3.43`. Corpus values remain frozen evidence, not fresh runtime results. Callable and named-mark neutral checks pass; no production/public repair is claimed.
- Exact routed task census at activation is 100 files / 79,955 lines / 8,146,914 bytes; the 80,000-line limit requires duplicate-chronology compaction under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5` before continued reading. All limits remain unchanged.
- Director requests assessment of parameterized/generic rules: preserve a proposed investigation after the clean containment pivot, covering grammar-rule parameters and separate runtime value parameters; no language implementation is authorized by that question.

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
- The completed 100-item batch is derived from Git: `git log --reverse --first-parent --format="%h %s" a5d5dcd2955aaaa41166bd87de6bdc39a4502bc4..fb307dae35d0ecfdcbb4b29e65bec36855d6971b`. Leaf `.1` belongs to the preceding checkpoint.
- `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.5` verified all 100 ordinal/leaf/hash identities before removing the duplicate enumeration; exact comparison provenance is in `docs/knowledge/startup-task-chronology-compaction.md`.

### Corpus continuation at `.3.3.43`

All 53 owned scopes are read: HLink delimiter/raw text, Liberty scalar/complex attributes, Lispish aggregation, portmap shape variants, explicit empty plugin input, literals, register fields, SimEnv and the spec.spec prefix through line 145. Stored JSON is an oracle, not fresh runtime proof. The scoped audit digest is `d7cd64ee375d24d370de3831e140c9aae425f1b75657b292d1daf178394e4c13`; forward reading through `.66` remains in d6f37492 until individually reconciled.

## Decisions

- `2026-09-13` .3.7.0: Freeze 21 complete supporting groups under existing capacity; exact prior startup Scope records grant no supporting-file reading credit. Continue authorized read-only work while reusing compatible dependencies.

- `2026-09-11`: .3.5.0 uses a separate bounded Julia member because the 572-line minimum plan exceeds startup member headroom. All 52 scopes are fixed before reading; no limit increase or source-reading credit. Future history capacity belongs to JULIA-STARTUP-READING.4.

- `2026-09-06`: The director explicitly excluded `rgx` from this reading pass; the exclusion includes its nested
  dependencies and does not remove first-party Rust code or tests from scope.
- `2026-09-06`: After being asked to choose between a reading checkpoint and keeping every file unchanged, the
  director authorized proceeding and delegated the choice. This permits the narrow startup-tracking commit
  before full reading, resolving the session's no-document-edits prerequisite for startup tracking only.
  Implementation and unrelated documentation changes remain gated.
- `2026-09-06`: Keep detailed progress here and a short pointer in layer A; preserve the existing implementation
  destination. The checkpoint does not alter repository doctrine or make reading a substitute for production work.

- `2026-09-08`: DBINP authoring discussion is proposed under `PARSER-AUTHORING-APIS`; approved format coverage remains parked under its existing tree. Preserve the required LinkedSpec/RGX/PGEN dependency build chain; generated dependency state alone is not a blocker.

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
- `.16.1`/`.16.2` own confirmed emptiness expression drift and literal/host-slot leakage after `.15`.

- `.17`–`.30` own the additional confirmed runtime/tool/public/evidence gaps preserved in intake `.31`;
  existing lifecycle debt remains under its original card and gains `.27` implementation ownership.

- `.80.1-.4` own correct dependency build reuse; `.81.1/.81.2` own newer-OS startup diagnosis and conditional repair.
  Both retain startup .3/.4/.5 prerequisites; intake .80.0 authorizes no source repair or OS mitigation.

## Verification Log

- `2026-09-13` .3.7.0: Supporting-source inventory .3.7.0 reconciles all 158 baseline-identical files under conf, tablescript, noncore, specs and ebnf: 25,612 LF delimiters, 25,613 fragments and 964,256 bytes. SUPPORTING-SOURCE-READING owns 21 pending groups/174 disjoint ranges; independent Git, current-delta and published-task reconstruction pass with every group within 1,500 fragments /65,536 bytes. No exact earlier startup Scope coverage is credited; physical reading is 0/21. The resulting decomposition uses existing controls, preserves all repairs and changes no source. Lua reading remains closed under ADR0119; next supporting .1.1 reads configuration. No dependency compilation or canonical gate is run; full codebase/book/policy prerequisites and later verification remain.

- `2026-09-12` .3.6.0: Lua decomposition freezes 51 pending reading children across 99 baseline-identical files: 71,268 physical lines, 71,269 fragments and 2,732,450 bytes. The independent 149-range audit includes two UTF-8-safe byte windows for an oversized generated MCP line. No source comprehension is claimed. The current plan fits unchanged limits; comparable Julia reading growth exceeds remaining Knowledge capacity. LUA-STARTUP-READING.4.1 prepares a coherent capacity disposition before reading. All previous reading, repairs and verification requirements remain intact.

- `2026-09-11` .3.5.0: Startup .3.5.0 freezes Julia reading into 52 owned children / 146 ranges across all 95 baseline-identical files: 75,984 lines / 2,693,170 bytes. Independent reconstruction verifies every byte and range digest; physical Julia reading remains 0/52. A separate bounded JULIA-STARTUP-READING member fits existing controls; .4 owns future history/capacity pressure. Dart reading is closed under ADR0114, with all 69 repairs and its failed gate retained. Next Julia .1.1 reads the manifests and first README range.

- `2026-09-08` `.3.3.67`: Exact scope and independent committed-child/mode/delta/repair/Knowledge continuity audits PASS. All 66 reading children and 141 touched fact paths are durable; 34 post-Perl repair owners retain 90 pending nodes / 73 pending leaves. Final receipt-bound canonical CI governs parent landing; outcome and exact log identity are retained in the commit. Next containment .7 precedes Dart ownership/reading.

- `2026-09-08` `.3.3.66`: Four exact scope/baseline identities PASS. Managed neutral Unicode806/9/8/2, binding11/7/6/8, callable-signature3/9/7 and write5/7/11/16/3/3/8/105 PASS. Existing cards distinguish native/generated-helper execution, strict-loader compilation, emitted-text inspection and the one independently compiled write fixture; no new native run is inferred. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.65`: Five exact scope/baseline identities PASS. Typed neutral 3/7/6/3, 92+7 and14/0/231; Unicode17 five-module byte comparison with12 fixtures; lifecycle9/4/6/3 and14 mutations PASS. Four existing Knowledge cards distinguish runtime/generated-helper execution, emitted-text inspection, catalogs and historical test counts; no new runtime/carrier run is inferred. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.64`: Both scope/baseline identities PASS; staged neutral governance PASS at 9 rollout legs / 123 base / 129 public mutations. Recursive/carrier Knowledge distinguishes historical admission from the completed .61 native run and retains .73–.75/.78. Standalone prefix includes native execution helpers; no emitted compilation is inferred from that prefix. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.63`: Exact three-scope identities PASS; native-resolution neutral 14/9/4 and staged neutral 9 legs / 123 base / 129 public mutations PASS. Three Knowledge cards reconcile child status, loader fixture types and current-depth policy/panic proof while preserving .71/.73–.78 repair ownership. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.62`: Exact three-scope identities reconcile admission, source-boundary aliases and emitter prefix; neutral semantic proof and pinned routing/history child-status controls pass. The preceding .61 canonical result is retained with exact log/receipt identity; no optional-gate rerun is inferred. Actual pending .79 owns the reproduced routing signal-status defect. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.61`: Four exact scopes PASS (1,461 lines / 52,200 bytes); semantic governance PASS 6/20/128 with rollout 9/0 and admission 6/0. Independent emitted assertions are precisely qualified. Mandatory engineering-notes rollover and exact finite capacity admission require staged canonical proof; commit body/receipt retain the completed run. Knowledge, memory, histories, diff and doctrine hooks govern canonical landing.
- `2026-09-08` `.3.3.60`: Seven exact scopes PASS (1,472 lines / 49,181 bytes). Managed cursor contract PASS at 8 complete / 0 pending, 6 runtime legs and 60 mutations. Reading facts preserve named-selector repair .57 and historical/current cursor boundaries. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.59`: Five exact scopes PASS (1,487 lines / 48,937 bytes). Managed root contract check PASS at 7 complete / 0 pending and 54 mutations. Historical/current Knowledge reconciliation preserves source-inspection versus independently compiled emitted proof. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.58`: Three scope/baseline identities PASS (1,471 lines / 49,296 bytes). Both exact-source manifest construction probes exit 0; relative controls resolve the same runtime crate, original Drop removes both workspaces and managed scratch is removed. Nine absolute writers and five relative source controls are inventoried; actual repair .78 follows required reading. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.57`: Four exact scopes and progressive/punctuation/recognition proof-boundary reconciliation pass; the known contains arity exception is explicit. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.56`: Four exact scopes and MCP/progressive test-boundary reconciliation pass; canonical completion records resolve dated admission wording. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.55`: Two exact scopes and mutation/MCP assertion-boundary reconciliation pass; known .58/.59 and .77 repair limits remain explicit. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.54`: Three exact scopes, both explicit emitted status guards and the bounded codeblock-row skip are verified from unchanged source. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.53`: Two exact scopes, integration EOF and test-route/Knowledge reconciliation pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.52`: Exact range/source identity and retained test-boundary comprehension pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.51`: Exact scopes/source pins and six source-extracted classifier controls pass their expected outcomes; managed scratch is removed. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.50`: Six exact baseline scopes and canonical Knowledge/test-boundary reconciliation pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.49`: 202 exact scopes, one explicit empty, 67 decoded JSON files, 68 manifest-owned cases and unchanged grammar mirror pass. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.48`: Exact range and complete mirror identity pass; unchanged .44 Unicode proof applies. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.47`: Four exact scopes, fixture JSON and unchanged canonical mirrors pass; .44 Unicode proof remains applicable. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.46`: Four exact scopes, JSON decode and unchanged mirror identities pass; .44 Unicode proof remains applicable. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.45`: exact range and complete canonical mirror identity pass; unchanged .44 Unicode proof applies. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.44`: four exact baseline scopes and JSON decode pass; all grammar mirrors match and the Unicode contract passes. Knowledge, memory, histories, diff and doctrine hooks govern focused landing.
- `2026-09-08` `.3.3.43`: exact 53-scope baseline audit, 18 JSON decodes/105 unique manifest cases, twelve paired Perl Get observations and exact callee lowering; Knowledge, memory, histories, diff and doctrine hooks govern focused landing.

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
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.21` | Exact reading/identity; pipeline trace; public emptiness/host-seed controls; required rollover/hash | PASS five trace tests and bounded controls; ADR 0103 exact staged canonical proof required before landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.21` | Canonical process-locality failure; same no-op initialization control in restricted/permitted execution; unchanged full oracle outside harness | Restricted control exits 71; permitted control and full six-family oracle PASS. Exact full canonical rerun remains required; no receipt from failed attempt. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.21` | Exact full canonical rerun, receipt, all nine doctrines, post-commit pointer and brief/status | PASS at `17d3e919`; mandatory chain, both CLI 66/66, Phase 0 1,032; optional flags unset/skipped. No pending job. |
| `2026-09-06` | `SESSION-STARTUP-READING.31` | Source/card/path and unique-ID audit; exact staged scope; Knowledge/memory/all nine doctrines; both history checks; diff review | PASS: 89 unchanged Perl files, 38 new unique IDs, 33 queued checkpoints pending, 14 new cards; no public/source changes. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.22` | Exact full-file reading/identity; authored-value/legacy arity controls; Knowledge reconciliation; focused continuity | PASS bounded controls and baseline identity; final staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.23` | Exact prefix/full-file identity; existing Knowledge milestone reconciliation; managed MethodLowering trace suite; focused continuity | PASS four top-level tests and prefix identity; required staged commit gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.24` | Exact range/full-file identity; signature/retirement Knowledge; variadic function suite; public mixed-path read; focused continuity | PASS 66 tests and error-free one result; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.25` | Exact range/full-file identity; function/callable Knowledge; eight Get/source/descriptor controls; focused continuity | PASS diagnostic controls; caller-local shadowing reproduced and repair .32 owned; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.26` | Exact range/full-file identity; block/receiver/traversal Knowledge; AST parser suite; three public root controls; focused continuity | PASS 23 tests and hash/array/scalar controls; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.27` | Exact range/full-file identity; AST/fallback/retirement/numeric Knowledge; scalar numeric suite; four public descriptors; focused continuity | PASS nine tests and four expected diagnostic counts; known Unicode-digit repair remains open; required gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.28` | Exact range/full-file identity; constructor/collection/mutation Knowledge; three public controls; paired Perl/PUC tagged controls; focused continuity | PASS bounded controls; tagged/split divergence rooted and .33 review/repair owned; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.29` | Exact range/full-file identity; progressive and normalization Knowledge; managed 129-assertion carrier consumer and neutral 9/9 checker; focused continuity | PASS; private six-runtime closeout pointers reconciled; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.30` | Exact range/full-file identity; scanner/AST/trace Knowledge; managed five-test pipeline suite and seven-dispatcher census; focused continuity | PASS; four Knowledge boundaries reconciled and known lexical repair linked; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.31` | Exact range/full-file identity; legacy/bare-read/uniform Knowledge; five public Get controls and generated handler-first source; focused continuity | PASS; existing push precedence confirmed and three historical records reconciled; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.32` | Exact range/full-file identity; pipeline/staged/recognition Knowledge; managed 143-check staged consumer, two neutral checkers and language inventory; focused continuity | PASS bounded Perl/neutral proof; two authoring/inventory records reconciled; required staged gates precede landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.33` | Exact range/full-file identity; separator/trace Knowledge; four compact trace tests; twelve public newline/comment cases plus dumped-source repeats; focused continuity | PASS reading/trace controls; comment failures reproduced and owned by `.34.1`/`.34.2`; one new/three qualified cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.34` | Exact baseline ranges; binding/callable/codeblock/gap Knowledge; managed 134 callable/gap tests; neutral gap 9/0/63 and public 8/15/10/34; six boolean controls and emitted AST; focused continuity | PASS reading and existing focused suites; boolean-literal defect rooted and owned by `.35`; one new/three qualified cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.35` | Exact 32768-byte fragment/full-file baseline identity; MCP binding/admission Knowledge; managed generator, five binding tests, six frame controls, admission complete/141; focused continuity | PASS bounded fragment and focused proof; one Knowledge card reconciles current topology and response-layer examples. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.36` | Exact fragment/full-file identity; MCP/ADR/repair Knowledge; three embedded-neutral equality checks and repaired-field controls; ordered materializer/validator35/10/10/76; focused continuity | PASS bounded contract data and neutral proof; two records reconcile; historical ADR clarification task-owned under `.5`. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.37` | Exact suffix/full-file identity; MCP plan/contract Knowledge; canonical bundle/header, neutral payload, four response and seven source digests; managed binding freshness; focused continuity | PASS embedded suffix and digest/freshness controls; one Knowledge card records payload versus recurring-proof boundaries. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.38` | Exact baseline ranges; MCP/numeric Knowledge; 31 MCP and nine numeric tests; neutral 55/18; six decoded then six paired decoded/stdio precedence controls; focused continuity | PASS reading and existing suites; documented precedence discrepancy rooted and owned by `.36`; one new/three updated cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.39` | Exact baseline ranges; plugin/progressive Knowledge and ADR 0080; managed 138 tests and neutral 9/9/116 plus public 6/12/10/60; public plugin and six ceiling controls; focused continuity | PASS reading and existing proof; resource/diagnostic enforcement gaps rooted and owned by `.37`; one new/four updated cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.40` | Exact baseline ranges; recognition authority/integration/neutral Knowledge; managed 59 tests and 138/250/58 at 9/9; six post-terminal controls; focused continuity | PASS reading and existing proof; obsolete snapshot restoration rooted and repair-owned by `.38`; one new/three updated cards. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.41` | Exact source baseline; 137 Perl tests; typed/semantic/diagnostic/logical neutral proof; eight value/four exit controls; required history rollover and exact-source proof; staged canonical boundary | PASS focused reading/probes; `.39`/`.40` own defects; ADR 0104 finite history capacity requires final staged canonical receipt before landing. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.42` | Exact source/book identities; 20 semantic tests; neutral semantic/generated proof; four input/direct, nine Get, and eight isolated factory controls; Knowledge and focused continuity; four inline-lifecycle and two descriptor controls | PASS reading and finite controls; physical mdBook Yes, codebase No; .41/.42/.43 own repairs without premature implementation. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.43` | Exact 982-line baseline and unchanged prior-proof inputs; retained 9/106/5 tests and neutral 6/20/128; four Knowledge reconciliations; exact consumed-spool cleanup; focused continuity | PASS scoped reading and retained proof; July milestones dated; codebase still No; no runtime changes. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.44` | Exact static-source/test identity; retained five-test proof; two exact plus two initial public failure controls; retained inline/descriptor evidence; standalone neutral 15/7/14; precise Knowledge and focused continuity | PASS scoped reading and controls; retained diagnostic versus fabricated explanation distinguished; .23/.41.6 refined without runtime changes. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.45` | Exact 700-line source and prior-proof identities; retained three-suite 18-test/typed 14/0/231 evidence; scoped Knowledge reconciliation; memory/Knowledge/doctrines/history and staged review | PASS reading and unchanged evidence; authority/value privacy and compatibility boundaries retained; no behavior change. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.46` | Exact 1,498-line baseline and unchanged staged inputs; retained 143 and 9/9/123 plus public proof; 24 native and four modeled lifetime controls; four Knowledge owners; focused continuity | PASS bounded reading/native controls; isolated recycling counterexample tracked as .44 with native non-reproduction explicit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.47` | Five complete ranges and exact baseline; unchanged staged runtime/consumer/checker/contract identity; four Knowledge owners; focused continuity | PASS bounded reading and retained proof; legacy metadata/general authority boundary explicit; .44 remains owned. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.48` | Complete Trace/baseline; 20 direct/wrapped exception controls; three generated suites 11 tests; unchanged CLI proof; Knowledge and focused continuity | PASS focused reading and tests; .24 retained with direct/wrapper distinction and exact object-identity evidence. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.49` | Prior full first-range reading + exact identity; ADR0027 and full checker/consumer; offline five-module regeneration/12 fixtures; Perl52; focused continuity | PASS; current regeneration coverage corrected, generated/carrier proof scoped, no new physical credit. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.50` | Prior complete middle-range reading; exact baseline and unchanged inputs; retained regeneration/12 fixtures/Perl52; Knowledge status; focused continuity | PASS; generated semantics unchanged; physical book/formal alignment distinction corrected. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.51` | Complete prior final range + exact identity; evaluator/12 fixtures; unchanged regeneration/Perl52; dated pressure census; Knowledge and focused continuity | PASS; complete case-table comprehension accounted; no runtime or generated-data change. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.52` | Complete prior XID range + baseline; ADR0051/consumer seams; Unicode806/9/8/2; direct3224/17/2; gap9/0/63/public8/15/10/34; focused continuity | PASS; generated classifier and current named-slot admission reconciled; historical stages retained. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.53` | Four complete files + baseline; 76 callable tests; neutral signature/codeblock; tracked plugin census13; canonical Knowledge and focused continuity | PASS; current registry metadata and legacy corpus/discovery boundaries reconciled. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.54` | Three complete files + exact baseline; three managed syntax checks; nine gdcheck diagnostic assertions; canonical utility Knowledge; focused continuity | PASS; final queued Perl utility checkpoint reconciled; .25/.26 remain unrepaired. |
| `2026-09-06` | `SESSION-STARTUP-READING.3.2.55` | Independent Perl coverage/54 commit identities; Rust candidate and task Scope audits; current deltas; resulting pressure; memory/Knowledge/history; exact staged canonical CI | PASS coverage and ownership; canonical receipt required before parent-closeout landing. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.1` | Exact two-range reading/baseline; 199-package lock census; retained eleven CLI/isolated core controls and four regex-boundary controls; task-first repairs .45–.47 and .49; preceding canonical receipt; focused continuity | PASS reading and bounded diagnostic evidence; Rust parent active; all four new repairs pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.2` | Six exact reading ranges/current-baseline proof; locked offline 199-package metadata; neutral cursor 36/18/8/60; existing Knowledge; .41.2/.41.7 ownership; focused continuity | PASS reading/metadata/neutral proof; requirement and source-comment repairs pending; codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.3` | Two exact reading ranges/current-baseline proof; existing callable/compiler Knowledge; neutral callable 7/11/9/7/4/8/23; selector zero-positive/20 classified; .45/.47 ownership; focused continuity | PASS reading and focused contract proof; compiler repairs remain pending; whole-codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.4` | Four exact reading ranges/current-baseline proof; descriptor/entry/slot Knowledge; neutral slot 5/2/59 and entry 8/3/3/54; .41.2 comment ownership; retained native duplicate rejection; focused continuity | PASS reading and focused neutral proof; source/public-comment repairs pending; codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.5` | Exact prefix/current-baseline proof; callable/staged/write/control Knowledge; neutral staged 123/129 mutations and write 5/7/11/16/3/3/8/105; retained .45–.47/.49; focused continuity | PASS reading and focused neutral proof; expression suffix and native repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.6` | Exact continuation/current-baseline proof; mutation/hash/callable Knowledge; neutral mutation 4/14/5/10/8/6/1 and 167+592 mutations; retained .45/.46/.47 controls; focused continuity | PASS reading and neutral contract proof; source boundary repairs remain pending with unchanged diagnostic limits. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.7` | Exact lexical range/current-baseline proof; callable 7/11/9/7/4/8/23; six asserted Rust/Perl-lowering hash controls; three paired native cat controls; .50/.51 task-first ownership; .49 limits; focused continuity | PASS reading and bounded diagnosis; .50/.51 repairs pending; whole-codebase reading still No. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.8` | Three exact ranges/current-baseline proof; write 5/7/11/16/3/3/8/105; callable 7/11/9/7/4/8/23; uniform 11/7/6/8; historical Knowledge and .41.6 ownership; focused continuity | PASS reading and neutral proof; parser suffix and all runtime repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.9` | Exact parser range/current-baseline proof; standalone 9/4/6/3/6/15/7/14; cursor 36/18/8/60; Unicode 806/9/8/2; ten paired body and three matches controls; four lowering/three bootstrap controls; .52-.54 ownership; focused continuity | PASS reading and bounded diagnosis; compact fluent/header/regex-brace repairs pending with exact evidence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.10` | Exact parser/trace/type range and baseline proof; managed core trace 7/7; numeric 55/18; cursor 36/18/8/60; four paired native number controls; .55 ownership; trace closure/fixture Knowledge; focused continuity | PASS bounded reading and diagnosis; value and scalar-text repairs remain pending under .55. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.11` | Exact three-range/current-baseline proof; Unicode 806/9/8/2; cursor 36/18/8/60; duplicate slots 5/2/59; derived-state/AST-pass Knowledge; .41.2 comment ownership; focused continuity | PASS reading and neutral proof; remaining validator/native suites and all repair leaves stay separately owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.12` | Exact three-range/current-baseline proof; core validation 21/21; gap 9/0/63/public34; root 8/3/3/54; cursor 36/18/8/60; four paired registry/five paired AND/four descriptor controls; .56/.57 ownership; lossless segment 4983; ADR 0105; exact staged canonical proof | PASS bounded reading and lossless archive proof; .56/.57 remain pending; exact canonical receipt required before landing. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.13` | Exact six-range/baseline proof; managed core cursor 5/5 + types 8/8 + Unicode 5/5; cursor/Unicode/logical/progressive neutral proof; finalized prior canonical intake; eight capture identities and ten absence checks; Knowledge/history/memory/all doctrines and diff | PASS bounded source/contract proof and diagnostic intake; constructor/dispatch suffix and existing repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.14` | Four-range/current-baseline identity; four managed neutral contracts; ceiling constructor/private-field and one-byte assertion source review; Knowledge/history/memory/all doctrines/diff | PASS bounded reading and neutral proof; prior native evidence remains dated, .37 review and engine suffix stay owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.15` | Exact engine-range/current-baseline identity; seven managed neutral checks; managed CLI build and seven paired split cases (five differences/two equal controls), .33 ownership and exact log/binary hashes; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS source/neutral proof and bounded split diagnosis; .33 owns contract review and repair; engine continuation stays pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.16` | Exact range/current-baseline proof; four managed neutral contracts; generated validation and invocation order reading; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded source and neutral proof; .41.2 owns stale comments, engine regex loop remains pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.17` | Exact source identity; six managed neutral contracts; four native diagnostic controls/field assertions and exact retained artifacts; .55.1 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading/neutral proof and exact index diagnosis; .55.1 repair and recursive writer continuation remain owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.18` | Exact source identity; four managed neutral contracts; invocation/guard/write Knowledge review; history/memory/derived Knowledge/staged diff/all nine pre-commit doctrines | PASS bounded reading/neutral proof; preserve later traversal/context/body ownership. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.19` | Exact source identity; four managed neutral contracts; 6 paired primary cases + 6 direct diagnostic cases with independent values/codes/spans; .58 ownership; consumed compiler sample; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading and exact guard-gap diagnosis; .58 owns repair/carrier/public closure. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.20` | Exact source identity; four managed neutral contracts; ten paired primary values/errors; ten lowered/generated captures; six callback descriptors; .59 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading and exact substitution diagnosis; .59 owns repairs and recurrence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.21` | Exact source identity; three managed neutral contracts; eleven paired values/errors plus Rust-only overflow; twelve ready descriptors/source captures; exact scalar kinds/panic-site assertions; .60/.61 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded reading and exact slice/scalar diagnosis; .60/.61 own repairs and recurrence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.22` | Complete source identity; five paired exact values/effects/JSON kinds; five ready source/descriptor captures; logical/typed/cursor neutral contracts; .62 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded capture/control reading and coalesce diagnosis; .62 owns runtime/carrier/public repair. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.23` | Full source identity; six informative and six inconclusive retained pairs; six three-rule descriptors/generated captures; exact sequence/error assertions; write/mutation/slot neutral proof; .63 ownership; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded engine/helper/export reading; .63 owns confirmed nonzero-cursor regex context repair. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.24` | Untruncated 65,536-byte source read/current-baseline identity; two byte-fresh generators; neutral transport/admission; decoded bundle/frame/schema assertions; supporting source identity; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS generated MCP prefix and authority identity; runtime/suffix reading remains next. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.25` | Untruncated scope/baseline identity; managed binding/neutral MCP; exact native panic test and captured stdout/stderr; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS reading checkpoint; .36 source evidence extended; new .64 owns confirmed synthetic panic-output gap. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.26` | Complete baseline scope; six native wire tests; twelve paired public size/delimiter cases; canonical-output and source-cause assertions; neutral MCP; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS bounded source reading; .65 owns confirmed one-byte final EOF discrepancy; .64 wire source scope extended. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.27` | Exact baseline source/helper coverage; verified existing CLI 66/66 default; neutral recognition/current guards; source-bounded .38 comparison; Knowledge/history/memory/staged diff/all nine pre-commit doctrines | PASS CLI/recognition reading; current trace/admission facts reconciled and Rust invalidation helper guard qualified. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.28` | Exact baseline coverage; recognition 138/250/58, gap 9/0/63, typed source 14/0/231; 92/7 source catalogs; Knowledge/history/memory/staged diff/all nine doctrines | PASS recognition adapter and RuntimeContext reading; gap/alias milestones and .55.1 incoming conversion inventory reconciled. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.29` | Exact baseline coverage; typed14/0/231, binding11/7/6/8, write105, map167/592, diagnostic20; Knowledge/history/memory/staged diff/all nine doctrines | PASS context observation/projection/store reading; current Knowledge and private-versus-bare mutation boundaries reconciled. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.30` | Baseline scope/supporting proof; six paired public queries/exact IDs and excerpts; semantic6/20/128, callable23, binding11/7/6/8; Knowledge/history/memory/staged diff/all nine doctrines | PASS bounded reading and root cause; new .66 owns repeated binding-ID/source overwrite, .22 gains Rust evidence. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.31` | Baseline scope; ADR0049/source review; six paired query and six Get controls; independent signature/count/source assertions; semantic6/20/128; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; .67 owns false signature acceptance and composite-call/source omissions. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.32` | Baseline scope; complete query/runtime and static prefix reading; eight native queries/four paired Get-CLI controls; independent assertions; semantic/diagnostic/recognition neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; normal slot diagnostic correct; .68 token-use and .69 newline repairs owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.33` | Baseline scope; static/event/emitter reading; five paired query and three paired Get-CLI controls; independent source/index assertions; semantic/cursor/generated neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; .70 owns grouped source/selector correlation and complete remainder handling. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.34` | Baseline scope; seven identity module compiles/two executable modules/ten results; independent assertions; generated/cursor/typed-source neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading/root cause; .71 literal encoding and .72 recognition parse coherence owned. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.35` | Baseline scope; complete source authority/loader and function projection reading; ADR0026/Knowledge reconciliation; resolution/typed/diagnostic/staged neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading; complete source authority/loader and accurate historical resolution provenance. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.36` | Baseline scope; spec parser helper completion and staged registry/seed/coordinator reading; .55.1 source inventory; staged/typed/scalar neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading; five bounded Knowledge cards preserve exact authority scope and existing numeric audit. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.37` | Baseline reading; paired target/returned-marker/budget assertions and backtrace; library/artifact hashes; staged/typed neutral proof; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading and bounded diagnostic assertions; defects remain explicitly pending under .73/.74/.75. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.38` | Four baseline-identical source ranges; three staged files complete; six Knowledge/.55.1 reconciliation; Unicode/staged/typed checks; Knowledge/history/memory/staged diff/all nine doctrines | PASS reading and generated/neutral checks; existing returned-marker and numeric repairs remain pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.39` | Five complete ranges/baseline identity; Unicode generation/12 fixtures; prior canonical receipt/log/two sample identities; five Knowledge cards; memory/history/diff/nine doctrines | PASS reading and evidence reconciliation; .3.3.38 canonical PASS at eba1a0ed; skipped optional results not refreshed. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.40` | Five complete upper-map ranges; baseline and retained-generation input identity; Unicode Knowledge; memory/history/diff/nine doctrines | PASS reading and retained-proof scope; upper map complete, evaluator remains pending. |
| `2026-09-07` | `SESSION-STARTUP-READING.3.3.41` | Exact two-file reading/baseline identity; complete Unicode coverage; callable assertion scope; Unicode/callable neutral checks; four Knowledge cards; 99-commit batch census; memory/history/diff and receipt-bound canonical gate | PASS focused reading and census; exact staged canonical receipt required before landing, with final result in the commit body. |
| `2026-09-08` | `SESSION-STARTUP-READING.3.3.42` | Exact scoped reading/baseline identity; callable/named-mark neutral checks; Knowledge, memory, histories, diff and all doctrines | PASS focused reading; pressure maintenance owns the next clean pivot. |

Current CI intake, `2026-09-10` / `SESSION-STARTUP-READING.80.0`: eleven public build stages
(dependency-internal details removed September20), both successful samples and failed compiler-sample outcome, prior-record preservation,
Knowledge/book/memory/history/whitespace and all nine doctrines pass. Preceding canonical `bef5dafd` passes
CLI66x2 and Phase0 1032/1032; 1163 seconds is Phase0 only, with 25 optional gates skipped.

## Commit Log

- `2026-09-13` .3.7.0: `SESSION-STARTUP-READING.3.7.0 - own exact supporting-source reading ranges`; activation 735f0337883baef5ac4422976879d09725e0e8ea; next supporting .1.1 after clean proof and empty brief.

- `2026-09-12` .3.6.0: `SESSION-STARTUP-READING.3.6.0 - freeze exact Lua reading ownership and capacity intake`.

- .3.5.0: `SESSION-STARTUP-READING.3.5.0 - freeze exact bounded Julia reading plan`.

Each canonical task node owns its exact `Commit` subject and retained completion note. Query landed history with `git log --all --format="%h %s" --fixed-strings --grep="SESSION-STARTUP-READING."`; this replaces the proven duplicate 102-row table.

## Changelog

- `2026-09-13` .3.7.0: Decompose all supporting sources into exact bounded reading owners; preserve prior work, unread-source honesty and dependency reuse.

- `2026-09-12` .3.6.0: Freeze exact Lua reading ownership and route the measured capacity intake; all prior evidence and repairs remain.

- `2026-09-11`: .3.5.0 freezes the exact 52-child Julia plan and capacity ownership; first reading is JULIA-STARTUP-READING.1.1.

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
- `2026-09-06`: `.3.2.21` completes four files, owns emptiness/literal repairs `.16`, and preserves required
  notes history under finite ADR 0103 capacity; MethodExpr follows canonical checkpoint landing.
- `2026-09-06`: `.31` preserves forward reading and source-confirmed findings from the canonical wait,
  owns repairs `.17`–`.30`, indexes the JSON observation artifact, and routes back to queued MethodExpr.
- `2026-09-06`: `.3.2.22` closes MethodExpr comprehension, indexes its scope normalizer, and qualifies
  dated migration spellings. Queued checkpoints continue with the MethodLowering prefix.
- `2026-09-06`: `.3.2.23` records MethodLowering prefix comprehension and qualifies dated Knowledge rollout notes;
  four trace tests pass, and `.3.2.24` continues the next prefix range.
- `2026-09-06`: `.3.2.24` records signature/local-binding and statement-bridge comprehension, validates 66 variadic
  tests plus a current mixed-path read, and reconciles retired-syntax Knowledge; next `.3.2.25`.
- `2026-09-06`: `.3.2.25` reads value/function dispatch, preserves eight caller-scope controls, and owns repair `.32`;
  existing execution Knowledge is qualified, with `.3.2.26` next.
- `2026-09-06`: `.3.2.26` reads block/receiver/tree dispatch, validates 23 AST tests and three root controls, and
  reconciles existing traversal Knowledge; `.3.2.27` is next.
- `2026-09-06`: `.3.2.27` reads helper fallback and numeric/string/collection paths, passes nine numeric tests and
  four descriptor controls, and qualifies existing AST/numeric Knowledge; next `.3.2.28`.
- `2026-09-06`: `.3.2.28` reads collection/constructor/mutation paths, passes three value controls, and preserves
  paired Perl/PUC tagged-record drift with `.33.1`/`.33.2` ownership; `.3.2.29` follows.
- `2026-09-06`: `.3.2.29` reads the lowering suffix and private progressive scanner; the 129-assertion Perl consumer and
  9/9/116 neutral proof pass, three Knowledge pointers reconcile, and `.3.2.30` follows.
- `2026-09-06`: `.3.2.30` reads rewrite orchestration and scanner/flow surfaces; five trace tests and seven-dispatcher
  census pass, four Knowledge records reconcile, and `.3.2.31` follows.
- `2026-09-06`: `.3.2.31` reads legacy/basic scanners, passes five public controls and generated handler-first push
  inspection, reconciles three historical records, and advances to `.3.2.32`.
- `2026-09-06`: `.3.2.32` reads pipeline/recognition/staged/splitting owners, passes 143 staged checks and neutral/
  language proof, reconciles two Knowledge records, and advances to `.3.2.33`.
- `2026-09-06`: `.3.2.33` reads splitter/trace/value owners, passes four trace tests, roots comment/newline failures in
  twelve controls, creates `.34.1`/`.34.2`, and advances to `.3.2.34`.
- `2026-09-06`: `.3.2.34` reads binding/callable/codeblock/gap owners and MCP header, passes 134 tests and neutral gap
  proof, roots dynamic boolean kind loss under `.35`, and advances to `.3.2.35`.
- `2026-09-06`: `.3.2.35` reads the first MCP data fragment, passes binding freshness/five tests/six frame controls/
  complete-141 admission proof, reconciles one Knowledge card, and advances to `.3.2.36`.
- `2026-09-06`: `.3.2.36` reads MCP policy/corpus/schema data, passes exact embedded-neutral identity and 35/10/10/76
  proof, reconciles two records and ADR alignment ownership, and advances to `.3.2.37`.
- `2026-09-06`: `.3.2.37` reads the MCP schema/payload suffix, verifies canonical bundle and four/seven response/source
  digests plus binding freshness, updates one Knowledge card, and advances to `.3.2.38`.
- `2026-09-06`: `.3.2.38` reads MCP/numeric owners, passes 31 MCP/nine numeric and neutral 55/18 proof, reproduces
  competing-error order across two routes, owns `.36`, and advances to `.3.2.39`.
- `2026-09-06`: `.3.2.39` reads plugin/progressive owners, passes 138 tests and neutral/public proof, records facade and ceiling
  controls, owns `.37` repairs, and advances to `.3.2.40`.
- `2026-09-06`: `.3.2.40` reads recognition core/static policy, passes 59 tests and neutral/public proof, reproduces six
  post-terminal controls, owns `.38`, and advances to `.3.2.41`.
- `2026-09-06`: `.3.2.41` reads runtime observers, passes 137 tests and four neutral checks, owns `.39`/`.40`, and performs
  required change-history rollover with ADR 0104; next `.3.2.42` after exact staged canonical proof.
- `2026-09-06`: `.3.2.42` reads semantic call/index owners, preserves complete 50-file book reading, and owns .41/.42/.43 repairs with exact public and isolated controls.
- `2026-09-06`: `.3.2.43` completes query/runtime-projection/source-map comprehension, qualifies historical Knowledge milestones, and verifies exact preparation-spool cleanup.
- `2026-09-06`: `.3.2.44` reads static semantic projection, refines .23 to preserved diagnostics with fabricated dependency evidence, and attaches stale TOOLBOX lifecycle guidance to .41.6.
- `2026-09-06`: `.3.2.45` completes the typed source-location owner and compatibility adapter reading with exact baseline and retained proof.
- `2026-09-06`: `.3.2.46` reads staged authority, reconciles routed recursion, and owns .44's modeled identity-recycling risk with exact native and isolated controls.
- `2026-09-06`: `.3.2.47` completes staged runtime and legacy registry reading, records fresh authority/private marker lifetime, and separates legacy cache-key metadata from general scheduling.
- `2026-09-06`: `.3.2.48` completes Trace reading, records 20 direct/wrapped string/object controls and 11 generated tests, and qualifies exception-state and historical CLI claims.
- `2026-09-06`: `.3.2.49` reconciles the first Unicode table range from complete .31 reading, refreshes five-module regeneration coverage, and records 52 current Perl tests.
- `2026-09-06`: `.3.2.50` reconciles the middle Unicode mapping range and clarifies physical mdBook completion versus pending formal alignment in inventory Knowledge.
- `2026-09-06`: `.3.2.51` reconciles final Unicode mapping/property/evaluator coverage and records the dated task-storage census before native planning.
- `2026-09-06`: `.3.2.52` reconciles the generated XID classifier, records direct boundary/fixture proof, and corrects stale named-slot/gap admission Knowledge.
- `2026-09-06`: `.3.2.53` reconciles spec-owned function metadata, completes legacy plugin/path/config reading, and records current callable proof and the parked plugin census.
- `2026-09-06`: `.3.2.54` completes legacy utility comprehension and preserves existing repair evidence; owns the Perl closeout and Rust decomposition before advancing.
- `2026-09-06`: `.3.2.55` closes Perl reading after independent coverage reconciliation and owns all Rust reading ranges; existing repairs and whole-codebase reading remain pending.
- `2026-09-07`: `.3.3.1` reconciles the first Rust reading group and owns forward malformed-block acceptance, Unicode diagnostic panic, parser/compiler whitespace mismatch, and regex-newline loss as .45–.47 and .49; no repair is closed.
- `2026-09-07`: `.3.3.2` reconciles Rust manifests, complete AST, and callable-contract prefix; records locked toolchain-declaration drift and mode comments under existing documentation repairs.
- `2026-09-07`: `.3.3.3` reconciles callable traversal and compiler validation/lowering; retains existing fail-closed and mutation repair ownership.
- `2026-09-07`: `.3.3.4` reconciles regex resolution, descriptor projection, entry precedence and portable diagnostics; owns stale self-edge comments and preserves native duplicate rejection.
- `2026-09-07`: `.3.3.5` reconciles typed expression carriers and statement parsing; preserves staged declaration authority and exact source-coordinate boundaries.
- `2026-09-07`: `.3.3.6` reconciles expression parsing, nested writes/mutations and brace classification; links existing UTF-8 and whitespace defects without overstating runtime proof.
- `2026-09-07`: `.3.3.7` reconciles lexical/test reading and owns confirmed adjacent hash-colon loss and cat arity divergence under .50/.51; retains prior regex repair limits.
- `2026-09-07`: `.3.3.8` completes expression-test reading and core entry prefix; qualifies old reconstruction, assignment and rollout claims without changing runtime.
- `2026-09-07`: `.3.3.9` reads rule-body parsing and owns .52-.54 lexical repairs, preserving paired native and exact bootstrap truncation evidence without runtime changes.
- `2026-09-07`: `.3.3.10` reads remaining parser tests, core trace and types prefix; owns .55 value/text repair and reconciles dated trace closure and scalar fixture coverage.
- `2026-09-07`: `.3.3.11` completes compiled-type/Unicode reading and validator entry order; reconciles dated cursor/strict evidence and owns stale validation comments under .41.2.
- `2026-09-07`: `.3.3.12` completes static validator and descriptor-test reading; owns .56 helper shadowing and .57 nonnumeric bare-selector loss with paired native/descriptor controls; performs required lossless notes rollover and finite ADR 0105 capacity admission under exact staged canonical verification.
- `2026-09-07`: `.3.3.13` reads all six group-13 ranges, retains verification limits and suffix ownership, records the completed prior canonical gate, and verifies exact consumed-capture cleanup; existing claim repairs remain owned.
- `2026-09-07`: `.3.3.14` reads group 14 completely, resolves the zero-ceiling concern at the private positive constructor, updates current options/diagnostic Knowledge, and retains exact engine suffix and native-proof limits.
- `2026-09-07`: `.3.3.15` reads the complete group-15 engine range, records generated-loop and diagnostic/helper boundaries, and preserves exact split controls with existing .33 repair ownership.
- `2026-09-07`: `.3.3.16` reads all group-16 bytes, reconciles invocation/diagnostic/observation boundaries, and retains .41.2 comment repair plus the native regex-loop continuation.
- `2026-09-07`: `.3.3.17` reads group 17 completely, reconciles native action/control and write coordination, and retains exact numeric-boundary repair plus recursive-write continuation ownership.
- `2026-09-07`: `.3.3.18` reads group 18 completely, reconciles recursive writes, guards and callable scopes, and retains trailing-block/traversal continuation ownership.
- `2026-09-07`: `.3.3.19` reads group 19 completely, owns final-assignment receiver-guard repair .58, and preserves exact native/reference controls plus compiler-wait evidence.
- `2026-09-07`: `.3.3.20` reads group 20 completely, owns substitution repair .59, reconciles capture/helper Knowledge, and retains exact primary/lowering evidence.
- `2026-09-07`: `.3.3.21` completes helper reading, owns slice/scalar repairs .60/.61, and retains eleven paired controls plus one Rust-only overflow case.
- `2026-09-07`: `.3.3.22` reads capture/control tests, owns coalesce repair .62, and preserves five typed paired controls.
- `2026-09-07`: `.3.3.23` completes engine/helper/export reading, owns regex context repair .63, and retains six informative paired controls.
- `2026-09-07`: `.3.3.24` reads the first 65,536 generated MCP bytes and reconciles exact binding identity and proof limits.
- `2026-09-07`: `.3.3.25` completes the embedded MCP module/runtime prefix and owns caught-panic process-output repair .64.
- `2026-09-07`: `.3.3.26` completes MCP server/wire reading, reads primary trace prefix, and owns EOF byte-limit repair .65.
- `2026-09-07`: `.3.3.27` completes primary CLI reading, reads recognition authority/effects/progress, and reconciles .38 source scope and current Knowledge.
- `2026-09-07`: `.3.3.28` completes recognition adapters, reads RuntimeContext source connections and reconciles gap/alias/conversion Knowledge.
- `2026-09-07`: `.3.3.29` reads context observations/projections/stores and reconciles six Knowledge owners without a new runtime defect claim.
- `2026-09-07`: `.3.3.30` completes RuntimeContext/semantic foundation, adds Rust .22 evidence and owns repeated semantic binding identity repair .66.
- `2026-09-07`: `.3.3.31` completes semantic call reading, reads query prefix and owns signature/composite-call evidence repairs .67.
- `2026-09-07`: `.3.3.32` completes query/runtime projection and owns .68 authored token-use/.69 variable-newline repairs.
- `2026-09-07`: `.3.3.33` completes static/event reading and owns grouped semantic source/index and parser-remainder repairs .70.
- `2026-09-07`: `.3.3.34` completes emitter reading and owns generated literal and recognition adapter repairs .71/.72.
- `2026-09-07`: `.3.3.35` completes source authority/loader reading and reconciles staged function projection plus dated resolution evidence.
- `2026-09-07`: `.3.3.36` completes spec parser and reads staged registry/seed/coordinator; .55.1 retains another source conversion boundary.
- `2026-09-07`: `.3.3.37` reads staged execution and owns measured target reservation, returned-marker validation and exhausted-counter repairs .73/.74/.75.
- `2026-09-07`: `.3.3.38` completes all three staged source files, starts pinned Unicode mappings and expands existing .55.1 source inventory.
- `2026-09-07`: `.3.3.39` completes Unicode lower-map reading and preserves canonical .3.3.38 plus bounded sample/probe evidence.
- `2026-09-07`: `.3.3.40` completes the Unicode upper map and preserves exact reading and retained-proof scope.
- `2026-09-07`: `.3.3.41` completes Unicode module reading and bounds callable consumer coverage at the final 100-item batch checkpoint.

- `2026-09-08`: `.3.3.42` completes reading; pressure owner `.5` precedes `.3.3.43`, and the generic-rule question remains proposed intake.
- `2026-09-08`: `.3.3.43` reconciles corpus reading, owns SimEnv dispatch .76 and preserves proposed parser-authoring investigations.

- `2026-09-08`: `.3.3.44` reconciles self-hosted grammar reading and four-mirror freshness; next `.3.3.45`.
- `2026-09-08`: `.3.3.45` reconciles physical label boundaries and edge grammar fields; next `.3.3.46`.
- `2026-09-08`: `.3.3.46` reconciles comment-skip and minimal-rule reading; next `.3.3.47`.
- `2026-09-08`: `.3.3.47` reconciles minimal-rule and user-function reading; next `.3.3.48`.
- `2026-09-08`: `.3.3.48` reconciles user-function edge grammar reading; next `.3.3.49`.
- `2026-09-08`: `.3.3.49` reconciles Terse and legacy corpus reading; next `.3.3.50`.
- `2026-09-08`: `.3.3.50` reconciles corpus and diagnostic consumer reading; next `.3.3.51`.
- `2026-09-08`: `.3.3.51` reconciles classifier reading and owns verifier repair .77; next `.3.3.52`.
- `2026-09-08`: `.3.3.52` reconciles integration control and traversal reading; next `.3.3.53`.
- `2026-09-08`: `.3.3.53` completes integration reading and checkpoints gap capture; next `.3.3.54`.
- `2026-09-08`: `.3.3.54` completes gap and logical consumer reading; next `.3.3.55`.
- `2026-09-08`: `.3.3.55` completes mutation consumer and checkpoints MCP admission; next `.3.3.56`.
- `2026-09-08`: `.3.3.56` completes MCP tests and checkpoints progressive authority; next `.3.3.57`.
- `2026-09-08`: `.3.3.57` completes progressive and punctuation consumer reading; next `.3.3.58`.
- `2026-09-08`: `.3.3.58` completes recognition/observation reading and owns emitted-manifest portability repair .78; next `.3.3.59`.
- `2026-09-08`: `.3.3.59` completes root-selection consumer reading and qualifies historical rollout evidence; next `.3.3.60`.
- `2026-09-08`: `.3.3.60` completes cursor/diagnostic consumer reading and starts semantic-foundation tests; next `.3.3.61`.
- `2026-09-08`: `.3.3.61` completes semantic consumer reading and performs required engineering-notes rollover; next `.3.3.62`.
- `2026-09-08`: `.3.3.62` completes admission/emitter boundary reading and owns verifier signal repair .79; next `.3.3.63`.
- `2026-09-08`: `.3.3.63` completes emitter/loader/staged-prefix reading and corrects classifier proof scope; next `.3.3.64`.
- `2026-09-08`: `.3.3.64` completes staged recursive/carrier reading and starts standalone-lifecycle tests; next `.3.3.65`.
- `2026-09-08`: `.3.3.65` completes lifecycle/trace/typed/casing reading with precise carrier proof; next `.3.3.66`.
- `2026-09-08`: `.3.3.66` completes final Rust contract consumers; only parent closeout remains; next `.3.3.67`.
- `2026-09-08`: `.3.3.67` closes complete Rust reading; preserves pending repairs and routes Dart capacity first; next `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7`.
- `2026-09-10`: `.80.0` preserves CI build/watch/startup evidence, creates gated `.80` and `.81` repairs, and returns to Dart `.1.37` without implementation or reading credit.
