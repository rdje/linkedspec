# NONCURRENT-HELPER-CODE-PURGE: Remove Non-Current Helper Spellings From Code

## Metadata

- Tree ID: `NONCURRENT-HELPER-CODE-PURGE`
- Status: `active`
- Roadmap lane: `.spec language evolution / codebase no-drift`
- Created: `2026-07-09`
- Last updated: `2026-07-09`
- Owner: repo-local workflow

## Goal

Remove explicit non-current helper spelling support, diagnostics, fixtures, labels, and source references from
the Perl and Rust codebases so removed helper names are not recognized, specially parsed, or preserved as
runtime/test/tool source surface. Helper-looking calls outside the current contract must flow through generic
unknown-helper handling, not through a name-specific removal compatibility layer.

## Non-Goals

- Do not change current helper semantics or accepted current aliases.
- Do not broaden the `.spec` language or add compatibility aliases.
- Do not rewrite historical project documentation in this tree unless it blocks code/test verification.
- Do not touch the Dart `.3.3` function-registry work until this directive is either exhausted or explicitly
  reprioritized after a clean commit boundary.

## Acceptance Criteria

- Perl source no longer contains explicit recognition paths, diagnostic helpers, or source-preservation logic for
  the non-current helper spelling set owned by `SPEC-FORMAT-TERSE.8`.
- Rust source no longer contains explicit recognition paths, diagnostic helpers, or source-preservation logic for
  the same non-current helper spelling set.
- Active Perl/Rust tests and tool-generated fixtures no longer embed those spellings as helper calls or code
  examples; equivalent current-surface tests use current spellings or generic invented unknown-helper names.
- Checked-in `.spec` grammar labels, helper strings, and generated corpus inputs are renamed or migrated where
  they collide with removed helper names, with expected-output drift reviewed deliberately.
- Focused scans over `perl/`, `rust/`, `t/`, `tools/`, `bin/`, and `specs/` are clean for the owned spelling set,
  excluding only generic language words that are not helper names in context.
- Focused Perl/Rust checks and the broader gate pass where the blast radius warrants it.
- Live docs, task-tree status, and Knowledge Map facts stay aligned after each leaf.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `NONCURRENT-HELPER-CODE-PURGE`
  Status: `active`
  Goal: Remove non-current helper spelling support/references from Perl and Rust code surfaces.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `NONCURRENT-HELPER-CODE-PURGE.1`
  Status: `done`
  Goal: Inventory and split the Perl/Rust code purge before implementation.
  Acceptance: Read-only scans identify the source/test/tool/spec owner categories; executable leaves are split
    before any parser/runtime code edits.
  Verification: **PASS 2026-07-09.** Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and
    `specs` show explicit non-current helper handling in Perl ActionIR owners, Rust runtime diagnostics, active
    test fixtures, oracle-generation tooling, inspection tooling, and checked-in `.spec` grammar labels/outputs.
    The broad string scan also produces many false positives from generic language words, so implementation leaves
    must use context-aware scans rather than blind replacement.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.1 - split code purge task tree`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2`
  Status: `active`
  Goal: Remove Perl source recognition and diagnostic paths for non-current helper spellings.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.1`
  Status: `done`
  Goal: Stop Perl current helper lowering from normalizing through old string/copy/assignment/append helper names.
  Acceptance: Current `cat(...)`, `copy(...)`, `set(...)`, and `push(...)` semantics lower through current method
    names; old source spellings in this family no longer have a name-specific parser/lowering/contract branch or
    diagnostic-only lowerer in the touched Perl ActionIR source owners.
  Verification: **PASS 2026-07-09.** Syntax checks pass for touched Perl owners:
    `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodExpr.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/FlowExpr.pm`,
    `perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/ControlFlow.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/DeclareMethod.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/Contracts.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`, and
    `perl -c -Iperl perl/LinkedSpec/ActionIR/RewritePipeline.pm`, plus
    `perl -c -Iperl perl/LinkedSpec/BootstrapSpec/Core.pm`. Focused tests/probes pass:
    `prove -q -Iperl t/actionir_ast_parser.t`,
    `prove -q -Iperl t/trace_actionir_compact_lowerers.t`,
    `PERL5LIB= prove -q -Iperl t/phase0_regression.t` (`1..1028`), direct
    `call_spec_handler_subst` probes for current `return(cat(...))`, `set(..., cat(...))`,
    `set(array(...), filter_match(...))`, `set(hash(...), hash(...))`, and
    `push(array(...), cat(...))`, plus a focused scan confirming no exact removed current-helper-family
    spellings or old concat temporary name remain in the touched Perl/test surfaces.
  Acceptance Checklist:
    - [x] **REPRODUCE / ISSUE** — `PERL5LIB= prove -q -Iperl t/phase0_regression.t` initially failed after
      current method names were preserved: current `set(...)` aggregate assignments returned raw helper text, and
      the test suite still expected name-specific diagnostics for deleted append/copy/string helper spellings.
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `call_spec_handler_subst` and
      `LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr` probes showed
      `perl/LinkedSpec/ActionIR/DeclareMethod.pm` still required a parsed old assignment method for
      `set(...)`, while `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `Contracts.pm`,
      `Scanner/PrimitivePipelineRules.pm`, and `RuleIR/EmitContext.pm` still carried source-owner branches for
      deleted current-helper-family spellings.
    - [x] **FIX** — Removed those name-specific compatibility/diagnostic branches, kept current
      `cat(...)`/`copy(...)`/`set(...)`/`push(...)` names through parsing/contracts/lowering, added a current-only
      `set(...)` top-level argument fallback for slash-regex payloads, and narrowed the bootstrap helper classifier.
    - [x] **ADDRESSED (verified)** — `call_spec_handler_subst` probes now lower current `return(cat(...))`,
      `set(..., cat(...))`, `set(array(...), filter_match(...))`, `set(hash(...), hash(...))`, and
      `push(array(...), cat(...))`; `rg -n` over touched Perl/test surfaces returns no deleted current-helper-family
      spellings or old concat temporaries.
    - [x] **NO REGRESSION** — Syntax checks pass for touched Perl owners plus `perl -c perl/LinkedSpec.pm` and
      `perl -c -Iperl t/phase0_regression.t`; `prove -q -Iperl t/actionir_ast_parser.t`,
      `prove -q -Iperl t/trace_actionir_compact_lowerers.t`, `PERL5LIB= prove -q -Iperl t/phase0_regression.t`,
      and `PERL5LIB= prove -v -Iperl t/phase0_regression.t` all PASS (`1..1028`).
    - [x] **LOCKSTEP** — `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `MEMORY.md`,
      `docs/TASK_TREE.md`, mdBook `docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md`,
      Knowledge Map fact cards, and this task tree are updated; `git diff --check`, `mdbook build
      docs/linkedspec-book`, `bash scripts/check_memory_architecture.sh`,
      `bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_task_tree_metadata.sh`, and
      `bash scripts/check_doctrines.sh` pass.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.2.1 - purge Perl current helper compatibility`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.2`
  Status: `done`
  Goal: Remove Perl declaration, return-family, and short-wrapper helper-specific source owner paths.
  Acceptance: Declaration helper spellings, old return-family helper spellings, and short/old scalar-wrapper
    helper spellings are no longer recognized through dedicated source-owner paths; current return, `return_undef`,
    auto-existing variable, assignment/reset, `array(...)`, `hash(...)`, and bare-read behavior still lowers.
  Verification: **PASS 2026-07-09.** Removed the Perl source-owner paths that parsed/lowered/contracted
    declaration helper spellings, old return-family helper spellings, and old short-wrapper spellings as
    dedicated helper surfaces. Current `return(...)`, `return_undef(...)`, `set(...)`, assignment/reset,
    auto-existing working variables, `array(...)`, `hash(...)`, and bare reads remain covered by the focused
    AST/compact-lowerer tests and full phase0 regression. Syntax checks pass for touched Perl owners and tests:
    `perl -c -Iperl perl/LinkedSpec/ActionIR/DeclareMethod.pm`,
    `perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm`,
    `perl -c -Iperl t/phase0_regression.t`, `perl -c -Iperl t/actionir_ast_parser.t`, and
    `perl -c -Iperl t/trace_actionir_compact_lowerers.t`. Focused tests pass:
    `prove -q -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t` and
    `PERL5LIB= prove -q -Iperl t/phase0_regression.t` (`1027` tests). Scoped scans over touched
    Perl/test surfaces confirm no exact helper-call recognition remains for the removed declaration,
    old return-family, or old short-wrapper spellings; residual matches are internal Perl implementation words
    such as lexical-declaration generation and ordinary `scalar(...)` Perl built-in usage, not DSL helper-call
    branches.
  Acceptance Checklist:
    - [x] **REPRODUCE / ISSUE** — Focused scans showed dedicated Perl ActionIR owner paths for removed
      declaration helper spellings, old return-family helper spellings, and old short-wrapper wrapper spellings.
    - [x] **ROOT CAUSE (WHY + WHERE)** — WHY/WHERE: `DeclareMethod.pm`, `RuleIR/EmitContext.pm`,
      `MethodLowering.pm`, `Contracts.pm`, scanner metadata, canonical events, rewrite-pipeline, and control-flow
      lookahead still carried source-owner branches or contract metadata for those removed helper-call spellings.
    - [x] **FIX** — Deleted the helper-specific extractor/lowerer/contract/scanner/canonical/rewrite/lookahead
      paths and rewrote focused tests to use current helper spellings or generic unknown helper names where the
      test is about generic diagnostics.
    - [x] **ADDRESSED (verified)** — Focused exact scans over touched Perl/test files show no helper-call
      source-owner paths for the removed declaration, old return-family, or old short-wrapper spellings.
    - [x] **NO REGRESSION** — Syntax checks, `t/actionir_ast_parser.t`,
      `t/trace_actionir_compact_lowerers.t`, and full `t/phase0_regression.t` pass.
    - [x] **LOCKSTEP** — mdBook helper/status chapters, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `MEMORY.md`,
      `docs/TASK_TREE.md`, the Knowledge Map fact, and this task tree are updated.
  Commit: `NONCURRENT-HELPER-CODE-PURGE.2.2 - purge Perl declaration and return helper paths`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.3`
  Status: `pending`
  Goal: Remove remaining Perl non-current helper IDs from contract/canonical/flow metadata.
  Acceptance: Perl contract scans and canonical event metadata only list current helper/control IDs or generic
    unknown-helper fallback paths.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.2.4`
  Status: `pending`
  Goal: Close Perl source purge scans and focused tests.
  Acceptance: Perl ActionIR parser/lowering/runtime source stops branching on the removed helper names; current
    helpers still lower; non-current helper-looking calls use generic unknown-helper behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.3`
  Status: `pending`
  Goal: Remove Rust source recognition and diagnostic paths for non-current helper spellings.
  Acceptance: Rust parser/runtime source stops branching on the removed helper names; current helpers still parse
    and execute; non-current helper-looking calls use generic unknown-helper behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.4`
  Status: `pending`
  Goal: Migrate active tests, tools, generated fixtures, and checked-in `.spec` labels away from non-current helper
    spellings.
  Acceptance: Active Perl/Rust test strings, tooling fixtures, generated corpus inputs, and checked-in `.spec`
    labels/source strings no longer carry the removed helper spellings except unavoidable generic-language false
    positives.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCURRENT-HELPER-CODE-PURGE.5`
  Status: `pending`
  Goal: Final no-drift scan and documentation closeout for the Perl/Rust code purge.
  Acceptance: Focused scans and gates prove no remaining code/test/tool/spec references to the removed helper
    spelling set, and live docs/KM record the current generic unknown-helper policy.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `NONCURRENT-HELPER-CODE-PURGE.2.3` | `pending` | Perl still has metadata/owner-name cleanup remaining after the source-owner path purge; close that before Rust source work. |

## Decisions

- `2026-07-09`: The director clarified that removed helper spellings must not appear in new Dart code and must
  also be deleted from the Perl and Rust codebases. Because the Dart `.3.2` tree was dirty at the time, the
  pivot waited until `DART-BACKEND-PARITY.3.2` was committed clean.
- `2026-07-09`: This tree treats the `SPEC-FORMAT-TERSE.8` non-current helper set as the source of truth without
  re-encoding the spelling list into new implementation code.
- `2026-07-09`: Broad textual scans are diagnostic only. Several words in the historical denylist are common
  implementation terms, so each implementation leaf must confirm context before editing.

## Open Questions

- None blocking `.2`. The Perl source owners are visible from the read-only scan and can be edited first.

## Blockers

- None known before `.2`.

## Verification Log

- `2026-07-09` — `.2.1` removed Perl current-helper normalization through old string/copy/assignment names,
  removed the removed append-helper contract/scanner/lowering branches, renamed the current append lowerer to
  current `push` terminology, and updated AST tests to fabricate current helper AST calls only. Focused syntax,
  AST parser, compact-lowerer, direct current-helper probes, and removed-append scans pass.
- `2026-07-09` — `.2.2` removed Perl declaration/return/wrapper helper-call source-owner paths, rewrote active
  regression fixtures away from those spellings, and kept current return/setup/read behavior green. Focused syntax,
  AST parser, compact-lowerer, scoped exact scans, and full phase0 (`1027` tests) pass.

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.1` | Read-only scans over `perl`, `rust`, `t`, `tools`, `scripts`, `bin`, and `specs`; task-tree split. | PASS. Owner categories are known; implementation starts with Perl source. |
| `2026-07-09` | `NONCURRENT-HELPER-CODE-PURGE.2.2` | Perl syntax checks; `prove -q -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t`; `PERL5LIB= prove -q -Iperl t/phase0_regression.t`; scoped exact scans; mdBook helper/status scan. | PASS. Source-owner paths for the removed declaration, return-family, and short-wrapper helper-call spellings are gone from the touched Perl/test surfaces. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `NONCURRENT-HELPER-CODE-PURGE.1` | `NONCURRENT-HELPER-CODE-PURGE.1 - split code purge task tree` | Inventory/split before code edits. |
| `NONCURRENT-HELPER-CODE-PURGE.2.1` | `NONCURRENT-HELPER-CODE-PURGE.2.1 - purge Perl current helper compatibility` | Current `cat`/`copy`/`set`/`push` paths stay on current names. |
| `NONCURRENT-HELPER-CODE-PURGE.2.2` | `NONCURRENT-HELPER-CODE-PURGE.2.2 - purge Perl declaration and return helper paths` | Perl declaration/return/wrapper helper-call source-owner paths removed. |

## Changelog

- `2026-07-09`: Created task tree after the director's Perl/Rust code purge directive and split implementation
  into Perl source, Rust source, active tests/tools/spec fixtures, and final no-drift closeout.
