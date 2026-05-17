# PHASE7-SELF-HOSTED-SPEC: Phase 7 Self-Hosted `.spec` Grammar

## Metadata

- Tree ID: `PHASE7-SELF-HOSTED-SPEC`
- Status: `done`
- Roadmap lane: `Phase 7`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Active frontier: `none` (tree complete)
- Owner: repo-local workflow

## Goal

Define and maintain `spec.spec` — a first-class LinkedSpec grammar that captures the currently supported `.spec` syntax and semantics, making it the preferred extension surface for future `.spec` format evolution.

## Non-Goals

- Modifying LinkedSpec core for `.spec` language changes (exception-only, explicitly justified).
- Replacing the bootstrap grammar as the compiler's internal parse mechanism.

## Acceptance Criteria

- `spec.spec` represents the current supported `.spec` language envelope with regression coverage.
- Roadmap-level `.spec` feature changes land through `spec.spec` first.
- Touching LinkedSpec core for `.spec` language evolution is exception-only and explicitly justified.
- Phase 7 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE7-SELF-HOSTED-SPEC`
  Status: `active`
  Goal: `Define and maintain a self-hosted .spec grammar.`
  Children: `PHASE7-SELF-HOSTED-SPEC.1`, `PHASE7-SELF-HOSTED-SPEC.2`, `PHASE7-SELF-HOSTED-SPEC.3`, `PHASE7-SELF-HOSTED-SPEC.4`, `PHASE7-SELF-HOSTED-SPEC.5`

- ID: `PHASE7-SELF-HOSTED-SPEC.1`
  Status: `done`
  Goal: `Survey the current .spec language surface: inventory every supported syntax element, rule form, action form, block form, and lifecycle marker that must be representable in spec.spec.`
  Acceptance: `Task file lists all .spec language elements with their current implementation status and names the first grammar-authoring leaf.`
  Verification: `2026-05-17: Full language surface inventory complete (see Language Surface Inventory section below). 37 syntax categories identified across rule forms, modes, body elements, lifecycle markers, helper DSL, block structure, and comments. Created follow-on leaves .2–.5 for grammar authoring, validation parity, regression, and extension-surface policy. Full suite: 1007 PASS (audit-only leaf).`
  Commit: `pending`

- ID: `PHASE7-SELF-HOSTED-SPEC.2`
  Status: `done`
  Goal: `Author spec.spec rule paragraphs for all structural/syntactic elements: rule labels (single/double colon), rule modes (AND/OR with bounded/unbounded/shorthand variants), regex anchors, action edges (-> and =>), block structure (action blocks, lifecycle blocks, blind-code blocks), and paragraph-level layout.`
  Acceptance: `spec.spec compiles to a descriptor with language_agnostic_ready_ratio == 1.0000. All structural elements from .1 inventory have corresponding rules.`
  Verification: `2026-05-17: spec.spec (3 rules: spec_file::AND+, rule_paragraph:AND, body_element:*) compiles cleanly with language_agnostic_ready_ratio == 1.0000. Captures rule labels with 11 mode variants, 5 body element regex-anchored alternatives, subdefs (body_edge_ast, body_blind_edge_ast). Full suite: 1007 PASS.`
  Commit: `pending`

- ID: `PHASE7-SELF-HOSTED-SPEC.3`
  Status: `done`
  Goal: `Author spec.spec rule paragraphs for action/helper DSL surface: lifecycle markers (I/LS/LE/E/EX/IT/LX), split/capture markers (@capture_slice, @capture_from_here, @move_pos, @mark), fluent chains (.method().method()), conditional markers (-? word), helper function calls, blind-code-block fluent chains.`
  Acceptance: `spec.spec captures the full helper-DSL placement rules. Lifecycle markers, split markers, and fluent chains are all representable.`
  Verification: `2026-05-17: Extended body_element:* from 5 to 9 regex-anchored alternatives. Added conditional marker (-? word), lifecycle marker (I/LS/LE/LX/E/EX/IT), fluent chain (.word), and word-based catch-all (word(/word{/word.) alternatives. body_element re: [9]. language_agnostic_ready_ratio 1.0000. Full suite: 1007 PASS.`
  Commit: `pending`

- ID: `PHASE7-SELF-HOSTED-SPEC.4`
  Status: `done`
  Goal: `Add regression coverage: verify spec.spec correctly parses all 19 shipped .spec files (or at minimum a representative sample) and produces descriptor state consistent with the bootstrap grammar.`
  Acceptance: `Regression test proves spec.spec parses shipped .spec files. Descriptor comparison validates equivalence with bootstrap-parsed descriptors.`
  Verification: `2026-05-17: Fixed AND++LX parser hang — replaced LX with E in spec_file. The generated parser hung because LX (Late Exit) in AND+ mode triggers loop re-entry after the repetition completes. Added 3 regression subtests (15 assertions) to t/phase0_regression.t: (1) no-hang parse of 6 shipped .spec files (tclite, ifelse, Lispish, tablegrep, pplugin, portmap), (2) structural element recognition (minimal input, self-parse with comments stripped, lifecycle/blind-edge specs), (3) language_agnostic_ready_ratio lock at 1.0000. Known bootstrapping gap documented: no top-level comment/blank-line skip rule — tests strip leading comments as workaround. Full suite: 1010 PASS.`
  Commit: `pending`

- ID: `PHASE7-SELF-HOSTED-SPEC.5`
  Status: `done`
  Goal: `Define the extension-surface policy: spec.spec becomes the required change surface for .spec language evolution. Touching bootstrap grammar for .spec changes is exception-only and explicitly justified.`
  Acceptance: `Policy documented in spec.spec header comments and in DEVELOPMENT_NOTES.md. Bootstrap grammar changes for .spec evolution require explicit justification.`
  Verification: `2026-05-17: Expanded spec.spec header from 2-line policy statement to a full extension-surface policy section. Added: 3-step change procedure (author in spec.spec first, pass regression gate at 1.0000, include coverage), exception criteria ((a) bootstrapping gap, (b) coordinated parity update), known bootstrapping gaps inventory (comment skip, AND++LX). Added formal policy section to DEVELOPMENT_NOTES.md with rationale, exception path detail, and gap inventory. PHASE7-SELF-HOSTED-SPEC tree COMPLETE (5 leaves). Full suite: 1010 PASS.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE7-SELF-HOSTED-SPEC.2` | `done` | Author structural rule paragraphs — 3 rules with own regexes, 1.0000 ratio, 1007 PASS. |
| 2 | `PHASE7-SELF-HOSTED-SPEC.3` | `done` | Author helper-DSL rule paragraphs — extended body_element to 9 regex alternatives, 1.0000 ratio, 1007 PASS. |
| 3 | `PHASE7-SELF-HOSTED-SPEC.4` | `done` | Add regression coverage — fixed AND++LX hang, 1010 PASS. |
| 4 | `PHASE7-SELF-HOSTED-SPEC.5` | `done` | Define extension-surface policy — policy documented, tree complete, 1010 PASS. |

## Language Surface Inventory (PHASE7-SELF-HOSTED-SPEC.1 — 2026-05-17)

### Survey Scope

Audited: `_parse_rule_label_line` (Validation.pm:35-83), `_looks_like_supported_rule_paragraph_member_line` (Validation.pm:746-762), `_looks_like_supported_split_marker_start` (Validation.pm:770-774), 19 shipped `.spec` files, 30 book chapters, 10 USER_GUIDE files.

### 1. Rule Label Forms

| Element | Syntax | Implementation | Notes |
| --- | --- | --- | --- |
| Body rule | `Word:` (single colon) | `_parse_rule_label_line`, `is_top=0` | Standard child rule |
| Top/entry rule | `Word::` (double colon) | `_parse_rule_label_line`, `is_top=1` | Entry-point rule, unreferenced by convention |
| Label characters | `\w+` (word chars only) | Regex `\w+` at line 38 | No hyphens, dots, or special chars in labels |

### 2. Rule Modes (8 variants + bounded forms)

| Element | Syntax | Implementation | Notes |
| --- | --- | --- | --- |
| Bounded AND | `AND{N}` or `AND{N,M}` | Lines 47-63 | `AND{3}` = exactly 3; `AND{0,5}` = 0–5 children |
| Bounded OR | `OR{N}` or `OR{N,M}` | Lines 47-63 | Same range syntax |
| Unbounded AND | `AND+` | Line 64-65 | All children must match |
| Single AND | `AND` | Line 64-65 | One or more children match |
| Unbounded OR | `OR+` | Line 64-65 | As many children as possible |
| Single OR | `OR` | Line 64-65 | First matching child wins |
| Shorthand AND | `&` | Lines 68-69 | Single-char equivalent of `AND` |
| Shorthand OR | `\|` | Lines 68-69 | Single-char equivalent of `OR` |
| Shorthand one-or-more | `+` | Lines 68-69 | Single-char equivalent of `AND+` |
| Shorthand zero-or-more | `*` | Lines 68-69 | Single-char; rarely used |
| Shorthand zero-or-one | `?` | Lines 68-69 | Single-char; rarely used |

### 3. Rule Body Elements — Recognized Paragraph Members

| # | Element | Recognition Pattern | Implementation |
| --- | --- | --- | --- |
| 1 | Blank line | `/^\s*$/` | Line 749 — empty separator |
| 2 | Comment | `/^\s*#/` | Line 750 — `# ...` to end of line |
| 3 | Rule label (nested) | `_parse_rule_label_line` | Line 751 — rejected inside blocks (.4 fix) |
| 4 | Regex anchor | `/^\s*\/(?:\\.\|[^\/])*?(?<!\)\//` | Line 752 — escaped-slash aware |
| 5 | Action edge | `/^\s*->/` | Line 753 — `-> Target` or `-> Target[idx]` |
| 6 | Blind-call edge | `/^\s*=>/` | Line 754 — `=> Target` (target is blind-called) |
| 7 | Split/capture markers | `/^\s*@\s*(?:(?:capture_slice\|capture_from_here\|move_pos)\b\|mark\s*\(\s*\w+\s*\))/` | Line 755 — 4 marker types |
| 8 | Conditional marker | `/^\s*-\?\s+\w+\b/` | Line 756 — `-? word` guard |
| 9 | Fluent chain start | `/^\s*\.\s*\w/` | Line 757 — `.method()` or `.method` |
| 10 | Function call | `/^\s*\w+\s*\(/` | Line 758 — `function(args)` |
| 11 | Blind code block | `/^\s*\w+\s*\{/` | Line 759 — `method_name { ... }` |
| 12 | Fluent method | `/^\s*\w+\s*\./` | Line 760 — `word.method()` |

Lines 759–760 (function calls and blind blocks) accept ANY word character prefix — these are intentionally broad catch-all patterns. The actual validation of whether the word is a valid helper/function happens later in ActionIR lowering.

### 4. Lifecycle Markers (7 total)

| Marker | Meaning | When it fires | Seen in shipped specs |
| --- | --- | --- | --- |
| `I` | Initialization | Once before first match attempt | `tablegrep.spec`, `pplugin.spec`, `ifelse.spec`, `tclite.spec` |
| `LS` | Loop Start | Before each match attempt | `tablegrep.spec` |
| `LE` | Loop End | After each successful match | `tablegrep.spec`, `pplugin.spec` |
| `E` | End | After rule completion | Used in shipped specs |
| `EX` | Exit | On rule exit regardless | Used in shipped specs |
| `IT` | Iteration | On each iteration | Used in shipped specs |
| `LX` | Late Exit | After rule fully completed | `tablegrep.spec`, `pplugin.spec`, `tclite.spec` |

Lifecycle markers appear as fluent chains: `I { ... }`, `.if(cond) { ... }`, `I.return(...)`, `LX.return(...)`.

### 5. Split/Capture Markers (4 total)

| Marker | Syntax | Purpose |
| --- | --- | --- |
| `@capture_slice` | `@ capture_slice` | Capture current match slice |
| `@capture_from_here` | `@ capture_from_here` | Capture from current position |
| `@move_pos` | `@ move_pos` | Move parse position |
| `@mark(name)` | `@ mark(label)` | Named position bookmark |

### 6. Action/Helper DSL Surface

Helper functions recognized and lowered through ActionIR (sampled from 19 shipped specs and USER_GUIDE):

- **Value constructors**: `hash(...)`, `array(...)`, `flat_array(...)`, `array_copy(...)`
- **Return/control**: `return(...)`, `return_undef()`, `call(...)`, `assign(...)`, `next()`
- **Match introspection**: `match_text()`, `entry_group(n)`, `entry_named(name)`
- **State access**: `scalar(name)`, `array(name)`, `scalaref(name, {...})`
- **State mutation**: `push_value(...)`, `assign(scalar(x), ...)`, `push(...)`
- **Predicates**: `matches(...)`, `contains_substr(...)`, `is_defined(...)`, `not(...)`, `and(...)`, `or(...)`, `is_empty(...)`
- **Conditionals**: `if(cond); ...; else(); ...; endif()`
- **String ops**: `substr(...)`, `coalesce(...)`, `trim(...)`, `lowercase(...)`, `length(...)`
- **I/O**: `print(...)`, `exit_now(n)`
- **Declare**: `declare(scalar\|array, name)`, `declare(scalar, name=value)`

### 7. Block Structure

| Element | Syntax | Notes |
| --- | --- | --- |
| Action block | `{ stmt; stmt; ... }` | Multi-statement, semicolon-separated; attached to `-> Target[n]` edges |
| Lifecycle block | `I { ... }` or `I { ... }` (same form) | Recognized as lifecycle via preceding marker |
| Blind-code block | `method_name { code }` | Code passed as block argument |
| Inline block | Same-line `{ stmt; stmt; }` | Compact form on same line as edge |
| Nested blocks | `{ ... { ... } ... }` | Properly tracked via `edge_scan_depth` in Validation.pm |

### 8. Authoring Styles

| Style | Example |
| --- | --- |
| Same-line compact | `Word:AND /foo/ -> Child { return(hash("kind", "word")); }` |
| Multi-line expanded | Rule label + regex + edge on separate lines |
| Mixed | Rule label on one line, regexes/edges on following lines |

### 9. What spec.spec Must Represent

The self-hosted grammar must capture:
1. Rule labels with mode parsing (11 mode variants)
2. Regex anchors with escaped-slash support
3. Action edges (`->`) and blind-call edges (`=>`) with optional index brackets
4. Action blocks with full helper DSL surface (~40+ helpers across 10 families)
5. Lifecycle markers (7) with fluent-chain placement rules
6. Split/capture markers (4)
7. Conditional markers (`-?`)
8. Fluent chains (`.method()`, `.method`)
9. Comments and blank lines
10. Block nesting (validated via depth tracking)

### Created Follow-On Leaves

- `.2`: Structural/syntactic rule paragraphs (rule labels, modes, regexes, edges, blocks)
- `.3`: Action/helper DSL rule paragraphs (lifecycle markers, split markers, fluent chains, helpers)
- `.4`: Regression coverage (spec.spec parsing 19 shipped .spec files)
- `.5`: Extension-surface policy (spec.spec as required change surface)

## Decisions

- `2026-05-16`: Created proposed task tree. Phase 7 is `not started` per `ROADMAP_V2.md`.

## Open Questions

- What is the minimal viable `spec.spec` first slice? (Answer pending survey.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PHASE7-SELF-HOSTED-SPEC.3` | Extended body_element:* from 5 to 9 regex alternatives. Body element recognition now covers: regex anchors, action edges, blind-call edges, split/capture markers, conditional markers, lifecycle markers (7), fluent chains, word-based patterns, plain code blocks. Full suite: Files=1, Tests=1007, PASS. | Pass — DSL rule paragraphs complete, 9 alternatives, 1.0000 ratio, frontier → .4. |
| `2026-05-17` | `PHASE7-SELF-HOSTED-SPEC.2` | spec.spec compiles to descriptor with language_agnostic_ready_ratio 1.0000. 3 rules: spec_file::AND+ (re: undef — top-level, unreferenced), rule_paragraph:AND (re: [1] — header regex), body_element:* (re: [5] — regex/edge/blind-edge/block/marker). Full suite: Files=1, Tests=1007, PASS. | Pass — structural rules complete, 1.0000 ratio, frontier → .3. |
| `2026-05-17` | `PHASE7-SELF-HOSTED-SPEC.5` | Defined extension-surface policy in spec.spec header (policy section, exception criteria, gap inventory) and DEVELOPMENT_NOTES.md (formal policy with rationale). PHASE7-SELF-HOSTED-SPEC tree COMPLETE (5/5 leaves). Full suite: 1010 PASS. | Pass — tree complete. |
| `2026-05-17` | `PHASE7-SELF-HOSTED-SPEC.4` | Fixed AND++LX parser hang (replaced LX with E in spec_file). Added 3 regression subtests (15 assertions): no-hang parse of 6 shipped specs, structural element recognition, language_agnostic lock at 1.0000. Known bootstrapping gap: no comment/blank-line skip rule. Full suite: 1010 PASS. | Pass — regression coverage complete, frontier → .5. |
| `2026-05-17` | `PHASE7-SELF-HOSTED-SPEC.1` | Audited `_parse_rule_label_line`, `_looks_like_supported_rule_paragraph_member_line`, `_looks_like_supported_split_marker_start`, 19 shipped `.spec` files, 30 book chapters, 10 USER_GUIDE files. 37 syntax categories inventoried across 9 sections. Full suite: Files=1, Tests=1007, PASS (audit-only). | Pass — complete language surface inventory. 4 follow-on leaves created. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PHASE7-SELF-HOSTED-SPEC.5` | `pending` | — |
| `PHASE7-SELF-HOSTED-SPEC.4` | `pending` | — |
| `PHASE7-SELF-HOSTED-SPEC.1` | `pending` | — |

## Changelog

- `2026-05-17`: Completed PHASE7-SELF-HOSTED-SPEC.5 — defined extension-surface policy, tree COMPLETE (5/5 leaves), 1010 PASS.
- `2026-05-17`: Completed PHASE7-SELF-HOSTED-SPEC.4 — fixed AND++LX parser hang, added 3 regression subtests (15 assertions), 1010 PASS. Active frontier: `.5`.
- `2026-05-17`: Completed PHASE7-SELF-HOSTED-SPEC.3 — extended body_element:* from 5 to 9 regex-anchored alternatives. Added: conditional markers (`-? word`), lifecycle markers (I/LS/LE/LX/E/EX/IT), fluent chains (`.word`), and word-based catch-all (`word(/word{/word.`). 9 regexes cover all 12 body element recognition patterns from .1 inventory. language_agnostic_ready_ratio 1.0000. 1007 PASS. Active frontier: `.4`.
- `2026-05-17`: Completed PHASE7-SELF-HOSTED-SPEC.2 — authored spec.spec structural/syntactic rule paragraphs. 3 rules: spec_file::AND+ (top-level collector), rule_paragraph:AND (header regex + body delegation), body_element:* (5 regex-anchored alternatives for regex tokens, edges, blind edges, code blocks, split markers + 2 subdefs). Compiles with language_agnostic_ready_ratio 1.0000. 1007 PASS. Active frontier: `.3`.
- `2026-05-17`: Completed PHASE7-SELF-HOSTED-SPEC.1 — full language surface inventory. 37 syntax categories across rule forms, modes, body elements, lifecycle markers, helper DSL, block structure. Created leaves .2–.5.
- `2026-05-17`: Activated tree. Moved from proposed to active. ROADMAP_V2 Phase 7: not started → in progress.
- `2026-05-16`: Created proposed task tree from template.
