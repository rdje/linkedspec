# PHASE2-DSL-FRONTEND: Phase 2 DSL Frontend Hardening

## Metadata

- Tree ID: `PHASE2-DSL-FRONTEND`
- Status: `active`
- Roadmap lane: `Phase 2`
- Created: `2026-05-16`
- Last updated: `2026-05-16` (PHASE2-DSL-FRONTEND.1 completed)
- Owner: repo-local workflow

## Goal

Complete deterministic DSL frontend validation so that no malformed `.spec`
token, rule header, edge target, action fluent, block delimiter, or split
marker is silently accepted or skipped by the parser.

## Non-Goals

- Execution semantics changes (Phase 3).
- Capture/mark API formalization (Phase 4).
- Runtime/compiler backend modernization (Phase 5).
- Self-hosted `.spec` grammar (Phase 7).

## Acceptance Criteria

- Deterministic DSL validation for all shipped `specs/*.spec`.
- No silent token-loss in strict mode.
- High-quality error messages with rule/source context for every validation rejection.
- Compatibility mode or explicit migration path for legacy `.spec` authoring patterns.
- Phase 2 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE2-DSL-FRONTEND`
  Status: `active`
  Goal: `Complete deterministic DSL frontend hardening.`
  Children: `PHASE2-DSL-FRONTEND.1`, `PHASE2-DSL-FRONTEND.2`, `PHASE2-DSL-FRONTEND.3`, `PHASE2-DSL-FRONTEND.4`, `PHASE2-DSL-FRONTEND.5`, `PHASE2-DSL-FRONTEND.6`

- ID: `PHASE2-DSL-FRONTEND.1`
  Status: `completed`
  Goal: `Inventory current DSL frontend validation coverage: list every validation point, error surface, known gap, and the next hardening priority.`
  Acceptance: `The task file documents each currently-rejected malformed pattern, maps them to the owning validation code, lists remaining silent-acceptance gaps, and names the next executable leaves.`
  Verification: `2026-05-16: inventory complete (see below)`
  Commit: `Docs: inventory Phase 2 DSL frontend validation coverage`

- ID: `PHASE2-DSL-FRONTEND.2`
  Status: `completed`
  Goal: `Close the validate_dsl_syntax / bootstrap_parse drift gap: add regression coverage for every supported DSL construct that bootstrap parses but validate_dsl_syntax does not explicitly recognize.`
  Acceptance: `phase0_regression.t grows targeted cases for each construct identified in PHASE2-DSL-FRONTEND.1 gap list (fluent continuations, block-nested rule patterns, grouped-edge variants, mode spellings). No validation rejections of shipped specs/*.spec.`
  Verification: `2026-05-16: 6 new subtests (20 test assertions) added after line 9542. All pass. Full suite: Files=1, Tests=995, PASS.`
  Commit: `Tests: regression-lock full validate_dsl_syntax / bootstrap_parse construct alignment`

- ID: `PHASE2-DSL-FRONTEND.3`
  Status: `pending`
  Goal: `Hardening: promote undefined-rule-reference and unused-rule warnings to strict-mode errors behind an explicit strict_syntax option defaulting off for backwards compatibility.`
  Acceptance: `When strict_syntax => 1 is passed, validate_dsl_syntax rejects undefined rule references and unused rules as errors instead of logging warnings. Shipped specs pass with strict_syntax off (default).`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE2-DSL-FRONTEND.4`
  Status: `completed`
  Goal: `Hardening: add top-level-only rule-start detection inside open blocks so that rule-like lines inside unclosed { } blocks are rejected instead of accepted as new rules.`
  Acceptance: `validate_dsl_syntax rejects rule-label lines when edge_scan_depth > 0 (inside open blocks). Regression coverage for this case. No false rejections of block-nested rule references or edge targets.`
  Verification: `2026-05-16: Added inside-block rule-label detection in Validation.pm line 611-620. When edge_scan_depth > 0, calls _parse_rule_label_line; if it matches, reports "Rule definition not allowed inside open block." Updated 2 existing tests, added 5 new regression subtests. Verified zero shipped specs contain rule-label-like lines inside blocks. Full suite: Files=1, Tests=1004, PASS.`
  Commit: `Fix: reject rule-label lines inside open blocks in validate_dsl_syntax`

- ID: `PHASE2-DSL-FRONTEND.5`
  Status: `completed`
  Goal: `Hardening: reject malformed extra-colon rule starts ('RuleName:::' and similar) that currently may parse as rule labels with empty tails.`
  Acceptance: `validate_dsl_syntax rejects rule lines with three or more colons after the label. Regression coverage.`
  Verification: `2026-05-16: Extra-colon rejection already in place via _parse_rule_label_line invalid_mode flag. Expanded existing regression test from 1 case to 14 edge cases (triple colon, quadruple colon, colon-space-colon, double-colon-space-colon, space variations, mode-suffix+colon, bounded-OR+colon). Verified all 14 patterns rejected. Full suite: Files=1, Tests=1004, PASS.`
  Commit: `Tests: expand extra-colon rule-label rejection regression coverage`

- ID: `PHASE2-DSL-FRONTEND.6`
  Status: `completed`
  Goal: `Verify and regression-lock full fluent-continuation surface: ensure _looks_like_supported_rule_paragraph_member_line recognizes all fluent spellings the bootstrap parser accepts (method chains, post-call dot continuations, nested arg blocks).`
  Acceptance: `Every fluent continuation form that bootstrap_parse accepts without error is also recognized as supported by _looks_like_supported_rule_paragraph_member_line. Regression coverage for each form.`
  Verification: `2026-05-16: 4 new subtests (20 assertions) added. All lifecycle markers (I, LS, LE, E, EX, IT, LX) with fluent chains. Deeply nested 5+ call chains. Quoted args with nested function calls. Empty-args method calls. Full suite: Files=1, Tests=999, PASS.`
  Commit: `Tests: regression-lock full fluent-continuation surface recognition`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE2-DSL-FRONTEND.1` | `completed` | Inventory done. |
| 2 | `PHASE2-DSL-FRONTEND.2` | `completed` | Drift gap closed with 6 new regression subtests. |
| 3 | `PHASE2-DSL-FRONTEND.6` | `completed` | Fluent-continuation surface verified and regression-locked with 4 new subtests. |
| 4 | `PHASE2-DSL-FRONTEND.4` | `completed` | Inside-block rule-start detection gap closed with explicit rejection and 5 new regression subtests. |
| 5 | `PHASE2-DSL-FRONTEND.5` | `completed` | Extra-colon rejection already in place; expanded regression from 1 to 14 edge cases. |
| 6 | `PHASE2-DSL-FRONTEND.3` | `pending` | Promote reference warnings to strict-mode errors (lowest risk, changes behavior). |

## Decisions

- `2026-05-16`: Created task tree with one inventory leaf. Phase 2 hardening continues from the existing shipped validation points.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.1 inventory. Identified 20+ validation points across 4 validation functions in `perl/LinkedSpec/Validation.pm` (lines 1-1333), 5 known gaps, and 5 next executable hardening leaves (PHASE2-DSL-FRONTEND.2 through .6). The active compile path runs `validate_spec_content` → `validate_dsl_syntax` → `bootstrap_parse` → `build_compiled_rule_table` → `build_dependency_regex_map` → `validate_dependency_regex_references`, orchestrated from `Compiler.pm` lines 604-790.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.2. Added 6 regression subtests (20 assertions) to `t/phase0_regression.t` after line 9542: zero-arg flow markers with blocks (`else { }`, `endif { }`, `default { }`, `endcase { }`, `endswitch { }`), method-empty blind-code-block with full fluent chain (`=> Helper.if(scalar(on)).push(items).return_undef().endif`), lifecycle fluent-chain with attached if/elseif/else branches (`I.if(scalar(on)) { }.elseif(scalar(alt)) { }.else { }`), three-target grouped action-edge (`-> A | B | C { }`), action-edge with regex-slot index and fluent chain (`-> Child[1].push(item).return_payload()`), and full 19-spec validation pass regression. Full suite: Files=1, Tests=995, PASS.

## PHASE2-DSL-FRONTEND.1 Inventory (2026-05-16)

### Validation Surface Map

All frontend validation lives in `perl/LinkedSpec/Validation.pm` (1333 lines). Four public entrypoints plus private helpers.

#### 1. `validate_spec_content($spec_content, $option)` — lines 143-219
Envelope validation. Called first in the compile pipeline (`Compiler.pm` line 606).

| # | Check | Line(s) | Rejection message |
| --- | --- | --- | --- |
| 1 | Non-SCALAR ref input | 147-150 | "Invalid spec content type" |
| 2 | Empty spec content | 152-155 | "Spec content is empty" |
| 3 | First non-blank/non-comment line must be a valid rule | 166-189 | "Spec file must start with a rule definition" or "Malformed rule label syntax" |
| 4 | At least one rule must exist | 199-207 | "Spec file must start with a rule definition" |
| 5 | At least one top rule (`::` syntax) must exist | 209-217 | "Spec file must define a top rule with '::'" |
| 6 | Stray preamble before first rule paragraph | 166-188 | "Spec file must start with a rule definition" |

#### 2. `validate_dsl_syntax($spec_content, $option)` — lines 521-709
Per-line rule-paragraph DSL validation with block-depth tracking. Called second in the compile pipeline (`Compiler.pm` line 685).

| # | Check | Line(s) | Rejection message |
| --- | --- | --- | --- |
| 7 | Malformed rule label syntax (bad mode spelling) | 549-558 | "Malformed rule label syntax" |
| 8 | Duplicate rule definition | 562-572 | "Duplicate rule definition: '<name>'" |
| 9 | Unsupported same-line rule-header filler (after rule start or leading regex cluster) | 574-576, 799-811 | "Unsupported same-line rule header content" |
| 10 | Invalid regex on rule header line (trailing unescaped slash) | 786-797 | "Invalid regex pattern: /..." |
| 11 | Stray unmatched closing delimiter (`}`, `]`, `)`) in rule paragraph | 1137-1148 | "Unexpected closing delimiter '<char>' in rule paragraph" |
| 12 | Action edge (`->`) missing target rule | 1162-1172 | "Action edge is missing a target rule" |
| 13 | Blind-call edge (`=>`) missing target rule | 1150-1160 | "Blind-call edge is missing a target rule" |
| 14 | Grouped action-edge targets (`-> A \| B`) without shared `{ }` block | 1174-1184 | "Grouped action-edge targets require a shared code block" |
| 15 | Blind-call with indexed target (`=> Rule[idx]`) | 1186-1196 | "Blind-call targets do not support regex-slot indexing" |
| 16 | Blind-call malformed target suffix (glued non-word chars) | 1198-1208 | "Malformed blind-call target syntax" |
| 17 | Blind-call malformed fluent suffix (`.` not followed by method name) | 1210-1220 | "Malformed blind-call fluent suffix syntax" |
| 18 | Action-edge malformed target suffix (glued non-word chars) | 1222-1232 | "Malformed action-edge target syntax" |
| 19 | Action-edge malformed fluent suffix (`.` not followed by method name) | 1234-1244 | "Malformed action-edge fluent suffix syntax" |
| 20 | Action-edge malformed regex-slot index (non-digit in `[index]`) | 1246-1255 | "Malformed action-edge target syntax" |
| 21 | Stray preamble before first rule (non-rule, non-blank, non-comment line before any rule) | 600-608 | "Spec file must start with a rule definition" |
| 22 | Unsupported top-level garbage inside rule paragraph | 615-625 | "Unsupported top-level rule paragraph content" |
| 23 | Malformed `@...` split-marker spelling | 611-614, 1257-1268 | "Malformed split marker syntax" |
| 24 | Mixed action (`->`) and blind-call (`=>`) code blocks in same rule | 540-547, 637-644, 649-656 | "Cannot mix ACTION (->) and BLIND CALL (=>) code blocks" |
| 25 | Unclosed rule block at EOF (open `{`, `(`, `[`) | 658-660, 1270-1285 | "Unclosed rule block before end of file" |
| 26 | Invalid regex pattern in rule paragraph body | 662-691 | "Invalid regex pattern: /..." |
| 27 | Undefined rule references (rules referenced but never defined) | 702-706 | Warning only: "Rules referenced but not defined: ..." |
| 28 | Unused rules (rules defined but never referenced) | 697-700 | Warning only: "Unused rules detected: ..." |

#### 3. `validate_rule_definition($rule_name, $rule_def)` — lines 222-251
Compiled rule-record validation. Called during dependency-regex validation.

| # | Check | Line(s) | Rejection message |
| --- | --- | --- | --- |
| 29 | Non-HASH rule definition | 225-228 | "Invalid rule definition for '<name>'" |
| 30 | Missing `handler` field | 230-233 | "Rule '<name>' missing required 'handler' field" |
| 31 | Non-ARRAY `re` field | 235-239 | "Rule '<name>' 're' field must be an array" |
| 32 | Invalid regex in `re` array (fails `eval { qr/.../ }`) | 241-247 | "Invalid regex in rule '<name>' at index N" |

#### 4. `validate_dependency_regex_references($dep_map, $spec, $option)` — lines 513-519
Dependency-reference consistency validation. Called after descriptor assembly.

| # | Check | Line(s) | Rejection message |
| --- | --- | --- | --- |
| 33 | Non-HASH dependency-regex map | 315-324 | "Invalid dependency-regex structure" |
| 34 | Non-HASH spec/rules-by-label | 326-335 | "Invalid spec structure" |
| 35 | Dependency regex references non-existent rule | 365-376 | "Dependency regex references non-existent rule '<name>'" |
| 36 | Invalid dependency regex entry (not compiled `Regexp`) | 378-389 | "Invalid dependency regex entry for rule '<name>'" |
| 37 | Invalid dependency entry format (missing `label` or `idx` keys) | 420-431 | "Invalid dependency entry at index N for rule '<name>'" |
| 38 | Dependency ref to non-existent rule (via `dependency_refs`) | 433-445 | "Dependency entry references non-existent rule '<ref>'" |
| 39 | Invalid regex index (out of bounds for target rule's `re` array) | 447-460 | "Invalid regex index N for rule '<ref>'" |

### Compile-Pipeline Orchestration (Compiler.pm lines 585-790)

The compiler runs validation in this sequence:
1. `validate_spec_content` (line 606) — envelope: content type, non-empty, first line is rule, has top rule
2. `validate_dsl_syntax` (line 685) — rule-paragraph scan: edges, blocks, modes, regexes, references
3. `bootstrap_parse` — actual recursive-descent parse via hardcoded grammar in `BootstrapSpec::Core`
4. `build_compiled_rule_table` — compile parsed rules into compiled-spec state
5. `build_dependency_regex_map` — derive dependency regexes from compiled-spec state
6. `validate_dependency_regex_references` — cross-rule dependency consistency

Failure at any stage writes structured `last_error` into `RuntimeContext` with `stage`, `summary`, `detail`, `rule_label`, and `handler_source_label` fields. The `parse_only` + `test_expectation => 'fail'` path allows expected validation failures without aborting.

### Known Gaps

**Gap 1: `validate_dsl_syntax` / `bootstrap_parse` drift.**
The validator uses a linear depth-tracking scan (`_scan_rule_edges_in_fragment`). The bootstrap parser uses recursive-descent through a hardcoded grammar. If the validator doesn't recognize a construct the parser handles, two failures are possible:
- **False positive**: validator rejects something the parser would accept → shipped specs break
- **False negative**: validator accepts something the parser silently ignores → malformed input leaks through
The `_looks_like_supported_rule_paragraph_member_line` helper (lines 711-727) defines what the validator considers valid paragraph content. If this list drifts from what the bootstrap grammar actually handles, gaps open. Specific unverified constructs include: fluent post-call continuations with nested parens, block-attached method chains, and certain lifecycle marker spellings.

**Gap 2: Silent token loss in bootstrap parser.**
The bootstrap grammar (`BootstrapSpec::Core`, 851 lines) operates through regex matching. Unmatched tokens between recognized constructs are silently consumed/skipped rather than reported as errors. The `validate_dsl_syntax` pass is the main defense against this, but if it misses a malformed pattern, the bootstrap parser will not catch it either. There is no post-parse verification that every input character was consumed by a grammar rule.

**Gap 3: Undefined/unused rule references are warnings, not errors.**
`validate_dsl_syntax` lines 697-706 log warnings for undefined rule references and unused rules but return success. A spec referencing a non-existent rule will pass validation and fail later (during bootstrap parse or runtime). There is no `strict` mode to upgrade these to hard errors.

**Gap 4: Rule-like lines inside open blocks may be accepted as new rules.**
`validate_dsl_syntax` line 536 checks `$current_rule->{edge_scan_depth} == 0` before trying to parse a line as a rule label. But `_looks_like_malformed_rule_label_line` at line 591 is only checked when `$at_rule_top_level` is true. A line that looks like a valid rule label inside an open `{ }` block could be parsed as a new rule definition instead of being rejected.

**Gap 5: No strict-mode option for forward-facing validation policy.**
All validation is on/off — there are no graduated strictness levels. An opt-in `strict_syntax` option would allow hardening without breaking existing `.spec` files.

### Next Hardening Priorities (ordered)

1. **PHASE2-DSL-FRONTEND.2**: Close the `validate_dsl_syntax` / `bootstrap_parse` drift gap — ensure every bootstrap-accepted construct has explicit validator recognition. Regression-lock with targeted test cases. This is the highest-priority gap because it's the primary defense against silent token loss.

2. **PHASE2-DSL-FRONTEND.6**: Verify `_looks_like_supported_rule_paragraph_member_line` covers all fluent-continuation spellings the bootstrap parser accepts. Add missing patterns. Regression-lock.

3. **PHASE2-DSL-FRONTEND.4**: Close the inside-block rule-start detection gap. A rule-like line inside `{ }` must not be accepted as a new rule definition.

4. **PHASE2-DSL-FRONTEND.5**: Reject malformed extra-colon rule starts (`RuleName:::` and similar).

5. **PHASE2-DSL-FRONTEND.3**: Add `strict_syntax` option to promote undefined/unused rule reference warnings to hard errors.

### Bootstrap Frontend Truth

`BootstrapSpec::Core` (851 lines) defines the hardcoded grammar. Key frontend-relevant areas:
- `_parse_method_call_chain` (line 48): parses `.method(args)` fluent chains; returns `undef` on parse failure
- `_render_method_call_chain` (line 101): renders parsed chains into handler code
- `build_bootstrap_spec`: constructs the full grammar descriptor with all rule regexes and handler coderefs
- The grammar is self-bootstrapping: it parses `.spec` files that define the parser for `.spec` files
- Error handling: only 3 explicit `die` calls (lines 796, 811 — missing bootstrap rule id, empty start-token registry). Most parse failures are silent nil returns.

### Regression Coverage Status

The main regression file is `t/phase0_regression.t`. Validation-specific test cases found at lines:
- 371-380: `validate_spec_content` lazy Trace loading
- 7101-7104: validation functions are NOT called when the code path bypasses them
- 8411-8412: validation accepts explicit mode spellings and blind-call surfaces
- 8695-9033: multiple `validate_dsl_syntax` test blocks covering stray preamble, malformed rule labels, unsupported paragraph content, duplicate rules, mixed modes, and various edge-target errors

19 shipped `.spec` files in `specs/` exercise the validation+compile path.

## Open Questions

- Should strict mode be default for new `.spec` files or opt-in? (Pending decision — deferred to PHASE2-DSL-FRONTEND.3.)
- Should the bootstrap parser gain explicit post-parse coverage tracking (report which input character ranges were consumed by at least one grammar rule)? This would close Gap 2 but is a significant bootstrap change.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-16` | `PHASE2-DSL-FRONTEND.1` | Read all of `perl/LinkedSpec/Validation.pm` (1333 lines). Catalogued 39 validation checks across 4 public entrypoints + private helpers. Read compiler orchestration in `Compiler.pm` lines 570-790. Reviewed `BootstrapSpec::Core.pm` (851 lines) for bootstrap-level error handling. Checked `ROADMAP_V2.md` line 390 claim against actual code. Identified 5 concrete gaps with owning code references. Defined 5 next executable hardening leaves. | Pass |
| `2026-05-16` | `PHASE2-DSL-FRONTEND.2` | Added 6 regression subtests (20 assertions). Compared `_looks_like_supported_rule_paragraph_member_line` patterns against all 14 bootstrap grammar start-token regexes. Verified all 19 shipped specs pass both validation passes. Full suite: Files=1, Tests=995, PASS. | Pass |
| `2026-05-16` | `PHASE2-DSL-FRONTEND.6` | Added 4 regression subtests (20 assertions). Tested all 7 lifecycle markers (I/LS/LE/E/EX/IT/LX) with fluent chains. Tested deeply nested 5+ call chains, quoted args with nested parens, empty-args method calls. Full suite: Files=1, Tests=999, PASS. | Pass |
| `2026-05-16` | `PHASE2-DSL-FRONTEND.4` | Added inside-block rule-label rejection (Validation.pm line 611-620). Updated 2 existing tests, added 5 new regression subtests (bare rule label, top-rule label, mode-suffix labels, non-rule-label content accepted, nested blocks). Verified zero shipped specs contain rule-label-like lines inside blocks. Full suite: Files=1, Tests=1004, PASS. | Pass |
| `2026-05-16` | `PHASE2-DSL-FRONTEND.5` | Extra-colon rejection already functional via `_parse_rule_label_line` `invalid_mode` flag. Expanded existing regression test from 1 case (`Top:::`) to 14 edge cases (triple colon, quadruple colon, colon-space-colon, double-colon-space-colon, space variations, mode-suffix+colon, bounded-OR+colon, tab separator). All 14 patterns rejected. Full suite: Files=1, Tests=1004, PASS. | Pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PHASE2-DSL-FRONTEND.1` | `Docs: inventory Phase 2 DSL frontend validation coverage` | 39 validation checks mapped, 5 gaps identified, 5 next leaves defined |
| `PHASE2-DSL-FRONTEND.2` | `Tests: regression-lock validate_dsl_syntax / bootstrap_parse construct alignment` | 6 subtests, 20 assertions, full suite 995 tests PASS |
| `PHASE2-DSL-FRONTEND.6` | `Tests: regression-lock full fluent-continuation surface recognition` | 4 subtests, 20 assertions, full suite 999 tests PASS |
| `PHASE2-DSL-FRONTEND.4` | `Fix: reject rule-label lines inside open blocks in validate_dsl_syntax` | 5 new subtests, 2 updated, full suite 1004 tests PASS |
| `PHASE2-DSL-FRONTEND.5` | `Tests: expand extra-colon rule-label rejection regression coverage` | Expanded existing test from 1 to 14 edge cases, full suite 1004 PASS |

## Changelog

- `2026-05-16`: Created task tree from `docs/tasks/TEMPLATE.md`.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.1 inventory. Mapped 39 validation checks across 4 functions in `perl/LinkedSpec/Validation.pm`, identified 5 concrete gaps with owning code references, defined 5 next hardening leaves (PHASE2-DSL-FRONTEND.2 through .6). Updated current frontier.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.2. Added 6 regression subtests (20 assertions) to `t/phase0_regression.t`: zero-arg flow markers with blocks, method-empty blind-code-block fluent chains, lifecycle fluent-chains with attached flow, three-target grouped action-edges, action-edges with index+fluent chain, and all-shipped-specs validation regression. Full suite: Files=1, Tests=995, PASS.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.6. Added 4 regression subtests (20 assertions) to `t/phase0_regression.t`: all lifecycle markers with fluent chains (I/LS/LE/E/EX/IT/LX each with `.if(scalar(on)) { ... }`), deeply nested fluent chain (5+ calls: `.coalesce().trim().lowercase().length().push()`), fluent chain with quoted args and nested parens (`.if(contains_substr(scalar(tag), \"critical\"))`), and empty-args fluent chain (`.push().return_undef()`). Full suite: Files=1, Tests=999, PASS.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.4. Added inside-block rule-label detection in `Validation.pm` (lines 611-620): when `edge_scan_depth > 0`, calls `_parse_rule_label_line` and if it matches, reports "Rule definition not allowed inside open block" with the owning rule label. Updated 2 existing tests (`validation_only_treats_rule_starts_as_top_level_inside_open_action_blocks` → `validation_rejects_rule_label_lines_inside_open_blocks`, `parser_build_allows_rule_like_lines_inside_open_action_blocks` → `parser_build_rejects_rule_like_lines_inside_open_action_blocks`). Added 5 new regression subtests: bare rule-label inside block, top-rule label inside block, mode-suffix labels inside block (AND+/OR+/OR{2,4}), non-rule-label content acceptance, and deeply nested block rejection. Verified zero shipped specs contain rule-label-like lines inside open blocks. Full suite: Files=1, Tests=1004, PASS.
- `2026-05-16`: Completed PHASE2-DSL-FRONTEND.5. Extra-colon rule-label rejection was already functional via `_parse_rule_label_line`'s `invalid_mode` flag (line 70-71 in Validation.pm). Expanded existing regression test from 1 case (`Top:::`) to 14 edge cases: triple colon, quadruple colon, colon-space-colon, double-colon-space-colon, space-triple-colon, triple-colon with same-line regex, double-colon AND+ extra colon, colon OR+ extra colon, colon-space-colon AND+, colon AND+ space colon, colon bounded-OR colon, colon-space-double-colon, space-colon-space-colon, and double-colon-space-colon regex. All 14 patterns correctly rejected. Full suite: Files=1, Tests=1004, PASS.
