# PHASE6-DOCUMENTATION: Phase 6 Documentation and Adoption

## Metadata

- Tree ID: `PHASE6-DOCUMENTATION`
- Status: `active`
- Roadmap lane: `Phase 6`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Owner: repo-local workflow

## Goal

Maintain and expand project documentation so every user-facing surface, architecture decision, and workflow convention is clearly explained, current at each commit, and usable for both new users and returning maintainers.

## Non-Goals

- New DSL features or behavior changes.
- Self-hosted grammar (Phase 7).

## Acceptance Criteria

- `USER_GUIDE.md` covers practical patterns, anti-patterns, and major DSL families with extensive worked examples.
- `ARCHITECTURE_STATE.md` is refreshed after each major structural change.
- `DEVELOPMENT_NOTES.md` records architecture rationale.
- `MEMORY.md` and `LIVE_ACHIEVEMENT_STATUS.md` are updated per slice.
- `docs/linkedspec-book/` reflects the current public understanding of LinkedSpec.
- Doc paths use repo-root-relative references (regression-locked).
- Phase 6 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE6-DOCUMENTATION`
  Status: `active`
  Goal: `Maintain project documentation at production quality.`
  Children: `PHASE6-DOCUMENTATION.1`, `PHASE6-DOCUMENTATION.2`, `PHASE6-DOCUMENTATION.3`, `PHASE6-DOCUMENTATION.4`, `PHASE6-DOCUMENTATION.5`, `PHASE6-DOCUMENTATION.6`, `PHASE6-DOCUMENTATION.7`, `PHASE6-DOCUMENTATION.8`

- ID: `PHASE6-DOCUMENTATION.1`
  Status: `done`
  Goal: `Inventory documentation coverage: map each user-facing DSL surface, architecture component, and workflow to its current doc coverage, identify thin spots, and name the highest-priority backfill leaf.`
  Acceptance: `Task file lists doc gaps with priority ordering, and the next executable documentation leaf is defined.`
  Verification: `2026-05-17: Full inventory complete (see inventory section below). Audited 30 mdBook chapters, 10 USER_GUIDE files, 6 live docs, ARCHITECTURE_STATE.md, and README.md. Found 7 doc gaps: LinkedRE zero docs, Validation.pm thin, public API incomplete, book/USER_GUIDE silos, overview chapters thin, ActionIR lowering thin, per-spec walkthroughs incomplete. Created 7 follow-on leaves (.2–.8). Full suite: Files=1, Tests=1007, PASS (no code changes).`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.2`
  Status: `done`
  Goal: `Document LinkedRE.pm: add a section to ARCHITECTURE_STATE.md covering its API (or, oredRE), its consumers (Compiler, SpecEntry, BootstrapSpec::Core), and its role as the regex composition utility. Optionally add a brief mention in the book where regex dispatch is discussed.`
  Acceptance: `LinkedRE.pm has a dedicated section in ARCHITECTURE_STATE.md. Its API contract, purpose, and consumers are clearly stated.`
  Verification: `2026-05-17: Added 11-line LinkedRE section to ARCHITECTURE_STATE.md under "What the Main Owners Do." Covers both functions (or, oredRE), position-tracking mechanism, seek vs consume modes, match-info return shape, three consumers and their local wrapper names, OwnerDispatch loading, and re 'eval' pragma. Added 3-line explanatory note to book's generated-handlers-and-dispatch.md linking code examples to the LinkedRE utility. Full suite: Files=1, Tests=1007, PASS (no code changes).`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.3`
  Status: `done`
  Goal: `Document Validation.pm DSL validation surface. Add a section to ARCHITECTURE_STATE.md covering its 1,368-line surface: envelope validation, rule-paragraph validation, edge-target validation, reference diagnostics (unused/undefined rules), strict_syntax mode, and how to debug validation failures. Optionally expand the book's pipeline-overview.md Stage 2 paragraph.`
  Acceptance: `Validation.pm has a substantive section in ARCHITECTURE_STATE.md covering its validation checks, error categories, and debugging guidance. The book's pipeline-overview.md Stage 2 section is expanded beyond the current one-paragraph treatment.`
  Verification: `2026-05-17: Expanded Validation section in ARCHITECTURE_STATE.md from 4 bullets to a 30-line entry covering all 5 public entry points (validate_spec_content, validate_dsl_syntax, validate_dependency_regex_references, validate_compiled_descriptor_state, validate_rule_definition), error reporting path, context helpers, rule-label parser, edge scanner, strict_syntax mode, and debugging guidance. Expanded book's pipeline-overview.md Stage 2 from a 4-line paragraph to a 16-line structured description covering the three validation layers (envelope, paragraph-level, cross-reference) with error payload routing. Full suite: Files=1, Tests=1007, PASS (no code changes).`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.4`
  Status: `done`
  Goal: `Complete public API documentation in the book. Add chapters or sections covering the trace API band (configure_trace, trace_enter, trace_exit, trace_decision, log_output, log_dump, should_dump) and the registry maintenance band (register_plugin, register_plugins, clear_registered_plugins). Document whether legacy transition methods (run_plugin, get_plugin, dispatch_plugin_autoload_name, AUTOLOAD) are public or internal.`
  Acceptance: `Book's Public API section covers all 4 facade bands or explicitly declares some as internal. A reader can discover every public method on the LinkedSpec facade.`
  Verification: `2026-05-17: Created public-api/trace-api.md (7 entry points documented: configure_trace, trace_enter, trace_exit, trace_decision, log_output, log_dump, should_dump, plus verbosity levels, trace state variables, and scope-chain diagram). Created public-api/plugin-registry.md (3 registry methods, 4 legacy transition methods with status note). Updated get-and-get-parser.md with build_compiled_rule_table and call_spec_handler_subst documentation. Updated SUMMARY.md to add both new chapters. Full suite: Files=1, Tests=1007, PASS (no code changes).`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.5`
  Status: `done`
  Goal: `Bridge the book and USER_GUIDE cross-linking gap. Add cross-references from relevant book chapters to USER_GUIDE files and from USER_GUIDE.md to the book. Ensure readers following either path can discover the other.`
  Acceptance: `At least 5 book chapters link to relevant USER_GUIDE files. USER_GUIDE.md links to the book. Readers following either documentation path can discover the other surface.`
  Verification: `2026-05-17: Added "Deeper reference" cross-links to 5 book chapters (action-and-lifecycle-placement → USER_GUIDE_Contracts + EmittedPerl, capture-marks-and-source-locations → USER_GUIDE_Contracts, source-boundary-helper-reference → USER_GUIDE_Contracts, declaration-helper-reference → USER_GUIDE_DeclareMethod, actionir-lowering-mental-model → 4 USER_GUIDE files). Added book link to USER_GUIDE.md with reading-order guidance. Combined with existing action-model-and-helper-surface links, now 6 book chapters cross-reference USER_GUIDE files. Full suite: Files=1, Tests=1007, PASS (no code changes — doc-only leaf).`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.6`
  Status: `pending`
  Goal: `Expand the four overview chapters (what-is-linkedspec.md, design-rationale.md, documentation-layers.md, project-status.md) from 153 total lines to substantive entry points. what-is-linkedspec should clearly state the project's value proposition. design-rationale should explain the key architectural decisions. project-status should reflect current roadmap state.`
  Acceptance: `Each overview chapter is at least 50 lines of substantive prose. A new reader landing on the book index gets a clear picture of what LinkedSpec is, why it was built this way, and what state it's in.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.7`
  Status: `pending`
  Goal: `Expand ActionIR lowering pipeline conceptual documentation. Expand actionir-lowering-mental-model.md (95 lines) and action-model-and-helper-surface.md (76 lines) to cover the full lowering pipeline (Scanner → StatementSplit → CanonicalEvents → RewritePipeline → FlowExpr/ValueExpr/ControlFlow/MethodLowering/DeclareMethod/ArrayPipeline/EmittedPerl).`
  Acceptance: `The two ActionIR book chapters together exceed 300 lines. A reader understands the lowering pipeline stages, contract families, and how ActionIR relates to the DSL surface.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE6-DOCUMENTATION.8`
  Status: `pending`
  Goal: `Backfill per-spec walkthroughs for the highest-value remaining shipped specs. Priority order: vhdl.spec (largest at 3500+ lines), one tablegrep/portmap/simenv spec, one plugin-family spec (pplugin/tkgui). Add walkthrough chapters to the book's specs-and-corpora section.`
  Acceptance: `At least 3 new per-spec walkthrough chapters exist in the book. Each covers: how to run the parser, output shape, rule inventory with role table, and descriptor readiness. The shipped-specs-and-corpora chapter's reading order is updated.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE6-DOCUMENTATION.6` | `pending` | Overview chapters are the entry point; thin entry points lose readers. |
| 2 | `PHASE6-DOCUMENTATION.7` | `pending` | ActionIR lowering is the DSL's engine; 171 lines for 2,000+ lines of code is too thin. |
| 3 | `PHASE6-DOCUMENTATION.4` | `pending` | Public API is the contract with users; incomplete coverage misleads. |
| 4 | `PHASE6-DOCUMENTATION.5` | `pending` | Book and USER_GUIDE are parallel silos; cross-links fix discoverability. |
| 5 | `PHASE6-DOCUMENTATION.6` | `pending` | Overview chapters are the entry point; thin entry points lose readers. |
| 6 | `PHASE6-DOCUMENTATION.7` | `pending` | ActionIR lowering is the DSL's engine; 171 lines for 2,000+ lines of code is too thin. |
| 7 | `PHASE6-DOCUMENTATION.8` | `pending` | Per-spec walkthroughs are the most user-visible content; only 2 of 14+ mature specs covered. |

## Decisions

- `2026-05-17`: Completed PHASE6-DOCUMENTATION.5 — bridged book/USER_GUIDE cross-linking. Added cross-references to 5 additional book chapters. USER_GUIDE.md now links to the book. 6 book chapters now cross-reference USER_GUIDE files.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.4 — completed public API documentation. Created 2 new book chapters (trace-api.md, plugin-registry.md). Book's Public API section now documents all 4 facade bands: trace (7 methods + verbosity levels + state variables), compile/runtime (Get, get_parser, build_compiled_rule_table, call_spec_handler_subst), registry (3 methods), legacy transition (4 methods with status note). Updated SUMMARY.md.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.3 — documented Validation.pm. Expanded ARCHITECTURE_STATE.md section from 4 bullets to 30-line entry covering all public entry points. Expanded book pipeline-overview.md Stage 2 from 4 lines to 16-line structured description of three validation layers.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.2 — documented LinkedRE.pm. Added 11-line section to ARCHITECTURE_STATE.md covering or/oredRE API, position-tracking, seek vs consume, match-info shape, three consumers, OwnerDispatch loading. Added 3-line explanatory note to book's generated-handlers-and-dispatch.md.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.1 inventory (see inventory section below). 30 mdBook chapters, 10 USER_GUIDE files, 6 live docs, ARCHITECTURE_STATE.md, README.md audited. 7 doc gaps found: LinkedRE zero docs, Validation.pm thin, public API incomplete, book/USER_GUIDE silos, overview chapters thin, ActionIR lowering thin, per-spec walkthroughs incomplete. Created 7 follow-on leaves (.2–.8) ordered by impact-to-effort ratio.
- `2026-05-16`: Created task tree. Documentation is maintained live per the documentation quality contract in `ROADMAP.md`.

## PHASE6-DOCUMENTATION.1 Inventory (2026-05-17)

### Survey Scope

Audited the complete LinkedSpec documentation surface across 5 layers:

| Layer | Count | Scope |
| --- | --- | --- |
| mdBook chapters | 30 | All chapters in `docs/linkedspec-book/src/` |
| USER_GUIDE files | 10 | `USER_GUIDE.md` + 9 `USER_GUIDE_*.md` files |
| Live docs | 6 | CHANGES.md, DEVELOPMENT_NOTES.md, MEMORY.md, LIVE_ACHIEVEMENT_STATUS.md, ROADMAP.md, ROADMAP_V2.md |
| Architecture | 1 | ARCHITECTURE_STATE.md (665 lines) |
| Entry point | 1 | README.md |

### mdBook Chapter Quality

All 30 chapters are substantive — zero stubs. Line counts by section:

**Overview (4 chapters, 153 lines total):**
| Chapter | Lines | Assessment |
| --- | --- | --- |
| what-is-linkedspec.md | 29 | Thin — one paragraph + short list |
| design-rationale.md | 50 | Thin — four bullet points |
| documentation-layers.md | 55 | Adequate — explains doc separation |
| project-status.md | 19 | Thin — brief acknowledgment |

**User Model (5 chapters, 1,829 lines):** All substantive. rule-modes-and-parse-modes.md (514 lines) is the most thorough chapter in the book. blind-calls-and-parser-orchestration.md (439 lines) and runtime-context-and-tracing.md (441 lines) are complete. worked-spec-walkthrough.md (290 lines) is a solid tutorial.

**DSL (8 chapters, 2,848 lines):** All substantive. Four reference chapters (declaration, action-lifecycle, source-boundary, value-container-flow) paired with four mental-model chapters. The value-container-flow-helper-reference.md (951 lines) is the largest chapter. actionir-lowering-mental-model.md (95 lines) and action-model-and-helper-surface.md (76 lines) are the thinnest.

**Compiler (4 chapters, 528 lines):** All substantive. pipeline-overview.md (140 lines) covers all 8 stages. compiled-state-model.md (140 lines) covers the three state models. diagnostics.md (134 lines) covers structured errors. generated-handlers-and-dispatch.md (114 lines) covers handler concepts but not emission details.

**Architecture (1 chapter, 497 lines):** owner-tree.md is the most comprehensive single chapter — covers every owner, OwnerDispatch, and the legacy plugin branch.

**Public API (2 chapters, 257 lines):** get-and-get-parser.md (136 lines) covers `Get` and `get_parser`. descriptor-introspection.md (121 lines) covers descriptor projection. Only covers 2 of 4 facade bands (trace and registry bands missing).

**Specs and Corpora (3 chapters, 1,486 lines):** ebnf-spec-walkthrough.md (761 lines) and lispish-spec-walkthrough.md (423 lines) are thorough. shipped-specs-and-corpora.md (303 lines) inventories all 19 specs but explicitly notes only 2 have walkthroughs.

**Development (2 chapters, 340 lines):** Both substantive. documentation-workflow.md (166 lines) and local-ci-and-regression.md (174 lines) cover contributor workflow comprehensively.

### USER_GUIDE Files (14,611 lines total)

USER_GUIDE files provide detailed ActionIR lowering documentation at ~5x the depth of book DSL chapters. They cover every major ActionIR contract family:

| File | Lines | Covers |
| --- | --- | --- |
| USER_GUIDE.md | 1,537 | Entry point + architectural notes |
| USER_GUIDE_ActionIR_Contracts.md | 3,305 | Full contract catalog |
| USER_GUIDE_ActionIR_EmittedPerlReference.md | 2,448 | Emitted Perl contracts |
| USER_GUIDE_RuleModesAndSplit.md | 2,545 | Rule modes and split boundaries |
| USER_GUIDE_ActionIR_MethodLowering.md | 1,830 | Method lowering pipeline |
| USER_GUIDE_ActionIR_ScalarAggregateMethods.md | 2,273 | Scalar/aggregate reference |
| USER_GUIDE_ActionIR_ControlFlow.md | 748 | Control flow contracts |
| USER_GUIDE_ActionIR_FlowExpr.md | 626 | Flow expression lowering |
| USER_GUIDE_ActionIR_ArrayPipeline.md | 328 | Array pipeline lowering |
| USER_GUIDE_ActionIR_ValueExpr.md | 293 | Value expression lowering |
| USER_GUIDE_ActionIR_DeclareMethod.md | 223 | Declaration method lowering |

Key finding: Only ONE book chapter (action-model-and-helper-surface.md) links to USER_GUIDE files. Zero USER_GUIDE files link to the book. They are parallel documentation silos.

### Module Documentation Coverage

| Module | Lines | Book | USER_GUIDE | ARCHITECTURE |
| --- | --- | --- | --- | --- |
| LinkedSpec.pm | 286 | owner-tree.md section | None dedicated | "LinkedSpec Facade Reading" (substantive) |
| Compiler.pm | 1,176 | pipeline-overview.md (140L) | None | Subsection (lines 345-383) |
| CompilerState.pm | 400+ | compiled-state-model.md | None | Subsection (lines 384-402) |
| SpecEntry.pm | 934 | generated-handlers (114L) | None | Brief subsection |
| Validation.pm | 1,368 | 1 paragraph in pipeline | None | Brief subsection |
| Runtime.pm | ~200 | runtime-context chapter | None | Brief subsection |
| RuntimeContext.pm | 384 | runtime-context chapter | None | Very thorough (15 bullets) |
| ParserFactory.pm | ~250 | get-and-get-parser.md | None | Adequate subsection |
| LinkedRE.pm | 56 | **ZERO** | **ZERO** | **ZERO** |
| ActionIR/Contracts.pm | 2,176 | Passing mention only | Full (Contracts.md) | One sentence |
| ActionIR internal (6 modules) | ~1,200 | Mention by name in owner-tree | Thin/indirect | Mention in ActionIR Reading |

### Live Docs and Workflow Docs

All live docs (MEMORY.md, CHANGES.md, DEVELOPMENT_NOTES.md, LIVE_ACHIEVEMENT_STATUS.md) are workflow artifacts with roles clearly documented in COMMIT.md sections 2-5 and TASK_TREE.md "Relationship To Live Docs." README.md layers them under "internal execution/continuity docs."

Workflow docs (COMMIT.md, SESSION_BOOTSTRAP.md, TASK_TREE.md, TASK_TREE_README.md, TEMPLATE.md) are collectively complete. TEMPLATE.md could benefit from inline field guidance but is functional as a copyable skeleton given TASK_TREE.md is the operating spec.

### Gap Summary (Priority Ordered)

1. **LinkedRE.pm — zero documentation** (highest impact-to-effort ratio): 56-line core regex utility used by Compiler, SpecEntry, BootstrapSpec::Core. No book mention, no ARCHITECTURE_STATE section. → `.2`
2. **Validation.pm — 1,368 lines, 1 paragraph of docs**: Largest completely undocumented module. Users hit validation failures first; no guidance on what errors mean or how to debug. → `.3`
3. **Public API incomplete**: Book covers 2 of 4 facade bands. Trace API (`configure_trace` etc.) and registry API (`register_plugin` etc.) have zero book coverage. → `.4`
4. **Book/USER_GUIDE cross-linking gap**: One link from book to USER_GUIDE; zero from USER_GUIDE to book. Readers following either path won't discover the other. → `.5`
5. **Overview chapters thin**: 153 lines across 4 chapters. Entry point for new readers but barely contains useful content. → `.6`
6. **ActionIR lowering pipeline thin**: 171 lines of conceptual docs for 2,000+ lines across 6+ modules. → `.7`
7. **Per-spec walkthroughs incomplete**: 2 of 14+ mature specs covered. vhdl.spec (largest at 3500+ lines) has no walkthrough. → `.8`

## Open Questions

- ~~Which user-facing DSL families have the thinnest documentation?~~ Resolved: inventory complete. LinkedRE.pm (zero docs), Validation.pm (1 paragraph), and ActionIR lowering pipeline (171 lines for 2,000+ lines of code) are the thinnest areas. Public API is incomplete (2/4 bands documented). Book and USER_GUIDE are parallel silos.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PHASE6-DOCUMENTATION.5` | Verified 5 new cross-reference sections added to book chapters. Verified USER_GUIDE.md links to the book. Verified existing action-model-and-helper-surface links preserved. Full suite: Files=1, Tests=1007, PASS (no code changes — doc-only leaf). | Pass — 6 book chapters + USER_GUIDE.md now cross-reference each other. |
| `2026-05-17` | `PHASE6-DOCUMENTATION.4` | Verified 2 new book chapters created (trace-api.md 115 lines, plugin-registry.md 72 lines). Verified all 4 facade bands now documented. Verified SUMMARY.md updated. Verified get-and-get-parser.md updated with build_compiled_rule_table/call_spec_handler_subst. Full suite: Files=1, Tests=1007, PASS (no code changes — doc-only leaf). | Pass — book Public API section now covers all facade bands. |
| `2026-05-17` | `PHASE6-DOCUMENTATION.3` | Verified ARCHITECTURE_STATE.md Validation section covers all 5 public entry points with structured descriptions, error reporting path, debugging guidance. Verified book Stage 2 covers three validation layers with error payload routing. Syntax check passes. Full suite: Files=1, Tests=1007, PASS (no code changes — doc-only leaf). | Pass — largest undocumented module now has substantive architecture and book coverage. |
| `2026-05-17` | `PHASE6-DOCUMENTATION.2` | Verified ARCHITECTURE_STATE.md LinkedRE section covers both functions, consumers, and loading. Verified book generated-handlers chapter references LinkedRE with explanatory note. Syntax check passes. Full suite: Files=1, Tests=1007, PASS (no code changes — doc-only leaf). | Pass — 56-line utility now has substantive documentation in both architecture and book layers. |
| `2026-05-17` | `PHASE6-DOCUMENTATION.1` | Audited 30 mdBook chapters, 10 USER_GUIDE files, 6 live docs, ARCHITECTURE_STATE.md, README.md. Assessed content quality vs line count for each. Cross-referenced modules against doc coverage. Verified no code changes needed (doc-only inventory). Full suite: Files=1, Tests=1007, PASS. | Pass — 7 gaps found, 7 follow-on leaves created. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PHASE6-DOCUMENTATION.5` | `pending` | — |
| `PHASE6-DOCUMENTATION.4` | `Docs: complete public API documentation in book` | — |
| `PHASE6-DOCUMENTATION.3` | `Docs: document Validation.pm DSL validation surface` | — |
| `PHASE6-DOCUMENTATION.2` | `Docs: document LinkedRE.pm regex composition utility` | — |
| `PHASE6-DOCUMENTATION.1` | `Docs: inventory Phase 6 documentation surface` | — |

## Changelog

- `2026-05-17`: Completed PHASE6-DOCUMENTATION.5 — bridged book/USER_GUIDE cross-linking. 6 book chapters now cross-reference USER_GUIDE files. USER_GUIDE.md links to the book.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.4 — completed public API docs. Created 2 new book chapters. All 4 facade bands now documented.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.3 — documented Validation.pm. Expanded ARCHITECTURE_STATE.md and book pipeline-overview Stage 2.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.2 — documented LinkedRE.pm. Added section to ARCHITECTURE_STATE.md and explanatory note to book's generated-handlers chapter.
- `2026-05-17`: Completed PHASE6-DOCUMENTATION.1 inventory. 30 chapters, 10 USER_GUIDE files, 6 live docs, ARCHITECTURE_STATE.md, README.md audited. 7 doc gaps found. Created follow-on leaves .2–.8.
- `2026-05-16`: Created task tree from template.
