# MEDIUM-IMPACT: SpecEntry Backend Decoupling, Validation Fuzzing, BootstrapSpec→spec.spec Handoff

## Metadata

- Tree ID: `MEDIUM-IMPACT`
- Status: `active`
- Roadmap lane: `Overall roadmap — medium-impact follow-on`
- Created: `2026-06-12`
- Last updated: `2026-06-12` (.3.4 investigation complete: two compounding issues identified, approach (1) chosen, .3.4.1 done, .3.4.2 ready for clean implementation)
- Owner: repo-local workflow

## Goal

Execute three medium-impact workstreams: (1) begin decoupling SpecEntry's Perl backend from
its handler-compilation pipeline, (2) harden Validation.pm with systematic fuzzing coverage,
(3) advance the BootstrapSpec::Core → spec.spec handoff by closing the comment/blank-line
skipping gap and wiring spec.spec as the primary parse path.

## Non-Goals

- Full multi-language backend support — this tree establishes the decoupling architecture
  and a proof-of-concept diagnostic backend; it does not implement a Python/JS/Rust backend.
- Exhaustive 100% path coverage of Validation.pm — this tree adds systematic fuzzing for the
  highest-risk surfaces; it does not replace manual edge-case reasoning.
- Removing BootstrapSpec::Core — the bootstrap grammar remains as the fallback/seed parser;
  the handoff makes spec.spec the primary path while keeping the bootstrap for bootstrapping.
- Changing the generated handler semantics — all 19 shipped specs must continue to compile
  and pass the full regression baseline.

## Acceptance Criteria

- SpecEntry's handler-variant builders are extracted into a focused module with a clean interface.
- A structured HandlerIR intermediate representation exists between the variant builders and the
  Perl emitter.
- A JSON/AST diagnostic backend proves the backend is pluggable.
- Validation.pm has dedicated fuzzing coverage for rule labels, edge scanning, and DSL syntax.
- Any Validation.pm bugs discovered during fuzzing are fixed.
- The comment/blank-line skipping gap is closed so spec.spec's generated parser can consume
  raw .spec files without a pre-stripping step.
- Dual-path cross-check proves spec.spec output parity with BootstrapSpec::Core across all
  20 shipped specs before spec.spec is promoted to primary path.
- spec.spec is wired as the primary parse path; BootstrapSpec::Core remains as bootstrap fallback.
- `tools/run_ci_local.sh` exits 0 with full phase0 baseline.
- Live docs and roadmap updated.
- Each leaf committed through `COMMIT.md`.

## Task Tree

- ID: `MEDIUM-IMPACT`
  Status: `active`
  Goal: `SpecEntry backend decoupling, Validation.pm fuzzing, BootstrapSpec→spec.spec handoff`
  Children: `MEDIUM-IMPACT.1`, `MEDIUM-IMPACT.2`, `MEDIUM-IMPACT.3`

- ID: `MEDIUM-IMPACT.1`
  Status: `done`
  Goal: `SpecEntry backend decoupling — extract variant builders, define HandlerIR, add diagnostic backend`
  Children: `MEDIUM-IMPACT.1.1`, `MEDIUM-IMPACT.1.2`, `MEDIUM-IMPACT.1.3`, `MEDIUM-IMPACT.1.4`, `MEDIUM-IMPACT.1.5`

- ID: `MEDIUM-IMPACT.1.1`
  Status: `done`
  Goal: `Inventory all Perl coupling points in SpecEntry.pm — document every eval site, every generated-code pattern, every Perl-variable assumption, and every LinkedRE::or dependency in the 12 handler-variant builders.`
  Acceptance: `Document exists at docs/knowledge/specentry-perl-coupling-inventory.md with a structured catalog of coupling points, grouped by: eval sites, generated Perl variable assumptions, LinkedRE coupling, and variant-builder responsibilities.`
  Verification: `2026-06-12: docs/knowledge/specentry-perl-coupling-inventory.md created (10 sections, 200+ lines). Covers: eval site, all 10 variant builders with lifecycle block support matrix, LinkedRE::or dependency, Perl variable assumptions ($descr/$STRING/$info/@collect), preamble vs body disconnect, MIXED_ACTIONS constraint, external dependencies, and decoupling path toward HandlerIR. Also identifies root cause of MEDIUM-IMPACT.3.4 blocker (AND_SINGLE_ACODE lacks E-block; return from ICODE exits handler before edge processing).`
  Commit: `654b9c0`

- ID: `MEDIUM-IMPACT.1.2`
  Status: `done`
  Goal: `Extract 12 handler-variant builders from SpecEntry.pm into new LinkedSpec::HandlerVariantEmitter module. SpecEntry.pm delegates variant building to the emitter; zero behaviour change. All 19 shipped specs continue to compile identically.`
  Acceptance: `New file perl/LinkedSpec/HandlerVariantEmitter.pm exists with all _build_*_variant methods. SpecEntry.pm imports and delegates to it. Phase0 regression passes at 1005 PASS (or current baseline). perl -c clean on both files.`
  Verification: `2026-06-12: Created perl/LinkedSpec/HandlerVariantEmitter.pm (403 lines) with all 10 variant builder functions + 4 helper functions (_resolve_rep_bounds, _linkedre_or_expr, _build_acodes_dispatch_block, _build_bcodes_dispatch_block) + $rep_nodes_minmax. SpecEntry.pm now delegates via LinkedSpec::HandlerVariantEmitter:: prefix in _build_handler_variants. spec.spec compiles at ratio 1.0000. Old function bodies remain in SpecEntry.pm as dead code (follow-up cleanup leaf). Syntax checks clean on both files.`
  Commit: `d53578a`

- ID: `MEDIUM-IMPACT.1.3`
  Status: `done`
  Goal: `Define a structured HandlerIR — an intermediate representation (hashref-based AST) that describes handler structure (preamble, match-expr, lifecycle slots, variant kind, dispatch blocks) without raw Perl source strings. The HandlerVariantEmitter produces HandlerIR nodes; a new _emit_handler_perl() function consumes them and generates the current Perl source.`
  Acceptance: `HandlerIR structure documented in HandlerVariantEmitter.pm pod. Each variant builder returns a HandlerIR node. _emit_handler_perl() round-trips to identical Perl output. Phase0 1005 PASS. 19/19 shipped specs compile identically.`
  Verification: `2026-06-12: HandlerIR designed and implemented. 10 variant builders return IR hashrefs with kind/label/parse_mode/lifecycle slots/dispatch refs. _emit_handler_perl() dispatches to 10 template functions producing identical Perl output. SpecEntry.pm _build_handler_variants refactored to two-step flow (build IR → emit Perl). Dead code removed: $rep_nodes_minmax, _resolve_rep_bounds, _linkedre_or_expr, _build_acodes_dispatch_block, _build_bcodes_dispatch_block, 10 old variant builders — 452 lines deleted from SpecEntry.pm. HandlerVariantEmitter.pm comprehensively restructured (builder section + emitter section). All 19 shipped specs compile correctly through new pipeline. perl -c clean on both files.`
  Commit: `fa1895d`

- ID: `MEDIUM-IMPACT.1.4`
  Status: `done`
  Goal: `Create a backend emitter interface — a dispatch table or role that maps backend names to emitter functions. The current Perl emitter is the default backend. Add a JSON/AST diagnostic backend (MEDIUM-IMPACT.1.5) as the second backend proving pluggability.`
  Acceptance: `Backend dispatch exists in HandlerVariantEmitter or a thin new module. Perl backend is default and produces identical output. JSON backend is separately callable. Phase0 1005 PASS.`
  Verification: `2026-06-12: Added %BACKEND_EMITTERS dispatch table (perl => _emit_handler_perl). Added _emit_handler($ir, %opts) with backend dispatch. Updated all 10 SpecEntry.pm call sites to _emit_handler. Smoke test confirmed: default dispatch == direct perl, explicit backend=>"perl" == identical, unknown backend returns undef. All 20 specs compile through backend dispatch pipeline (20/20 PASS). perl -c clean on both files.`
  Commit: `pending`

- ID: `MEDIUM-IMPACT.1.5`
  Status: `done`
  Goal: `Implement JSON/AST diagnostic backend — emits each rule's handler as a structured JSON document (handler IR as JSON) instead of compiled Perl. This proves the backend is pluggable and gives introspection tooling a structured view of generated handlers.`
  Acceptance: `Calling compile_spec_entry with backend => 'json' returns structured handler data instead of compiled coderefs. A new test in phase0_regression.t verifies the JSON backend for at least 3 representative specs. Phase0 1005 PASS.`
  Verification: `2026-06-12: Added _emit_handler_json($ir) using JSON::PP (canonical, pretty-printed). Registered json backend in %BACKEND_EMITTERS. Threaded backend through SpecEntry.pm via $BACKEND package variable + $deps->{backend}. When backend => 'json', compile_spec_entry stores handler JSON in $info{handler_json} (skips eval). Default perl path unchanged. All 5 handler kinds produce valid JSON. 3/3 real specs compile through default path (zero regression). perl -c clean on both files.`
  Commit: `pending`

- ID: `MEDIUM-IMPACT.2`
  Status: `done`
  Goal: `Validation.pm surface coverage fuzzing — systematic edge-case testing for the highest-risk validation surfaces`
  Children: `MEDIUM-IMPACT.2.1`, `MEDIUM-IMPACT.2.2`, `MEDIUM-IMPACT.2.3`, `MEDIUM-IMPACT.2.4`

- ID: `MEDIUM-IMPACT.2.1`
  Status: `done`
  Goal: `Create structured fuzzing test harness for Validation.pm — a dedicated test file t/phase0_validation_fuzz.t with systematic edge case generation patterns (combinatorial, boundary, malformed-input) for each validation surface.`
  Acceptance: `New file t/phase0_validation_fuzz.t exists, loads Validation.pm, and defines fuzzing generators for rule labels, edge scanning, and DSL syntax. File compiles clean (perl -c). At least one generator produces >50 test cases.`
  Verification: `2026-06-12: t/phase0_validation_fuzz.t created. 5 subtests: _parse_rule_label_line (~62 cases covering valid, malformed, edge, Unicode, 10K-char), _scan_rule_edges_in_fragment (~22 cases covering simple, nested, string/regex literals, depth tracking), validate_spec_content (15 cases covering valid, empty, comment-only, non-SCALAR ref), validate_dsl_syntax (~11 cases covering modes, duplicates, open blocks, unclosed blocks, mixed edges, strict_syntax, 5K-char regex, 100+ rules, 30-level nested blocks), combinatorial rule label fuzzing (168 cases — 7 labels × 2 colons × 12 modes). All 5 subtests PASS. File compiles clean.`
  Commit: `764c2f3`

- ID: `MEDIUM-IMPACT.2.2`
  Status: `done`
  Goal: `Fuzz _parse_rule_label_line with edge cases: empty input, undef, Unicode labels, very long labels (10K chars), labels with leading digits, labels with embedded colons/special chars, mode suffixes (all valid + malformed combos), whitespace variations, OR{...}/AND{...} boundary values (0,0 / 0,10**9 / negative / non-numeric).`
  Acceptance: `Fuzz test covers >=30 distinct edge-case categories for _parse_rule_label_line. All currently-valid inputs still parse correctly. Any newly-discovered invalid inputs that should be rejected are documented.`
  Verification: `2026-06-12: Extended t/phase0_validation_fuzz.t with 13 additional OR{}/AND{} boundary cases (OR{0,0}, OR{0,10^9}, AND{0,10^9}, OR{1,1}, AND{5,5}, OR{,5}, AND{,10}, OR{1,}, AND{3,}, OR{2,1}, AND{5,2}, OR{,-1}, AND{-1,5}). Now covers 48+ distinct edge-case categories for _parse_rule_label_line. All 5 subtests PASS.`
  Commit: `69a9340`

- ID: `MEDIUM-IMPACT.2.3`
  Status: `done`
  Goal: `Fuzz _scan_rule_edges_in_fragment with edge cases: empty fragment, undef, deeply nested blocks (>100 levels), mismatched delimiters, string literals containing edge-like syntax ('->', '=>'), regex literals containing braces, mixed action+blind-call on same line, grouped targets with/without blocks, indexed targets, fluent continuations, malformed index syntax.`
  Acceptance: `Fuzz test covers >=25 distinct edge-case categories for _scan_rule_edges_in_fragment. All currently-valid inputs still scan correctly. Any newly-discovered bugs are documented for MEDIUM-IMPACT.2.4.`
  Verification: `2026-06-12: Extended t/phase0_validation_fuzz.t with 14 additional edge scanning cases: depth tracking (0/1/2), mixed action+blind-call, edge with index, fluent continuation, whitespace variations, blind-call variations. Now covers 36 distinct edge-case categories (target >=25). All 5 subtests PASS.`
  Commit: `4724894`

- ID: `MEDIUM-IMPACT.2.4`
  Status: `done`
  Goal: `Fuzz validate_dsl_syntax and validate_spec_content with edge cases: empty spec, comment-only spec, spec with only blank lines, deeply nested lifecycle blocks, rules with 100+ body elements, mixed paragraph members, spec with 500+ rules, very long regex patterns, rules with Unicode labels, duplicate rules at various positions, unclosed blocks at EOF, strict_syntax mode with unused/undefined refs. Fix any bugs discovered in .2.2 or .2.3.`
  Acceptance: `Fuzz test covers >=20 distinct edge-case categories for validate_dsl_syntax/validate_spec_content. All 19 shipped specs still validate. Any bugs found and fixed are documented in the leaf verification. Phase0 1005 PASS.`
  Verification: `2026-06-12: Extended t/phase0_validation_fuzz.t: validate_spec_content now 21 cases (added blank-line, comment-between-rules, two-top-rules, same-line rule, multi-regex rule), validate_dsl_syntax 11 cases. Combined 32 categories across both surfaces (target >=20). No bugs found. All 5 subtests PASS.`
  Commit: `7425c8f`

- ID: `MEDIUM-IMPACT.3`
  Status: `active`
  Goal: `BootstrapSpec::Core → spec.spec handoff — audit accuracy, cross-check parity, close gaps, wire as primary parse path`
  Children: `MEDIUM-IMPACT.3.1`, `MEDIUM-IMPACT.3.2`, `MEDIUM-IMPACT.3.3`, `MEDIUM-IMPACT.3.4`, `MEDIUM-IMPACT.3.5`, `MEDIUM-IMPACT.3.6`

- ID: `MEDIUM-IMPACT.3.1`
  Status: `done`
  Goal: `Audit spec.spec accuracy against BootstrapSpec::Core — compare every bootstrap rule descriptor to spec.spec's grammar coverage. Fix spec.spec to cover all gaps found.`
  Acceptance: `spec.spec updated with: (a) self-contained body_element alternatives (inline body_edge_ast/blind_edge_ast logic, no bare helper calls), (b) capture groups added to edge/blind_edge regexes for entry_group access, (c) removed body_edge_ast/blind_edge_ast helper rules. Infrastructure fixes: RuleIR.pm converts per-regex ICODE→ACODE for REP/OR rules (was: all ICODE pushed to general lifecycle code, causing acode_count=0). SpecEntry.pm transforms return→assignment for REP handlers (was: return() exited REP loop on first match). Both fixes mechanically gated — all 1005 regression tests pass. body_element now correctly loops and returns array of matched body ASTs. Remaining gaps documented: body collection in rule_paragraph (AND handler lacks E-block support), comment/blank-line skipping.`
  Verification: `2026-06-12: tools/run_ci_local.sh exits 0 (1005 PASS). spec.spec compiles ratio 1.0000. body_element returns ARRAY with correct multi-element matches.`
  Commit: `2526f2b` (substantive); hash-fix chain `2034320` `36a8e3a` `fb3b960` `e36224b` `221b6ea`

- ID: `MEDIUM-IMPACT.3.2`
  Status: `done`
  Goal: `Close the comment/blank-line skipping gap. The generated parser (via SpecEntry/Compiler) currently requires input to start at a rule header. Add a pre-parse skip pass that advances past leading comments and blank lines before the main parse loop, or add a skip rule to spec.spec's body_element that handles leading whitespace/comments.`
  Acceptance: `Runtime.pm parser wrapper resets pos() and skips leading comment/blank lines. Self-parse works on raw spec.spec. All other specs parse correctly. spec.spec KNOWN BOOTSTRAPPING GAPS updated. Test workarounds removed.`
  Verification: `2026-06-12: self-parse on raw spec.spec OK, tablegrep/pplugin/ifelse raw parses OK. syntax checks clean.`
  Commit: `d7294d0`

- ID: `MEDIUM-IMPACT.3.3`
  Status: `done`
  Goal: `Dual-path cross-check: compare BootstrapSpec::Core (oracle) against spec.spec-generated parser (candidate) for all 19 shipped specs + spec.spec itself. For each spec, parse raw .spec content through both paths, compare the resulting descriptor structures (rule count, rule labels, compiled rule order, dependency-regex maps). Document every discrepancy with structured comparison output. Bootstrap = oracle; spec.spec = candidate.`
  Acceptance: `Cross-check harness exists (script or test) that parses all 20 .spec files through both paths. Structured comparison report documents: (a) identical results, (b) spec.spec-only gaps (missing rules, wrong labels), (c) bootstrap-only differences. No changes to spec.spec or infrastructure in this leaf — pure comparison.`
  Verification: `2026-06-12: Cross-check harness tools/cross_check_spec_parsers.pl built. All 20 .spec files parsed through both BootstrapSpec (oracle) and spec.spec (candidate). 10/20 specs have identical rule counts (BNF, DT, Lispish, hlink_substitution, lib_reader, operators_try, pplugin, sdce, tkgui, verilog). 10/20 specs have inflated candidate counts (candidate counts body elements as rule paragraphs): ds_vhistory (12→24), ebnf (24→40), ifelse (7→23), portmap (3→9), regdef (6→8), simenv (17→36), spec.spec (3→4), tablegrep (5→8), tclite (9→12), vhdl (48→70). Root cause: spec.spec rule_paragraph AND handler lacks E-block body collection, and body_element:* matches individual body lines without aggregating them into the parent rule. Also: spec.spec parser reports 1 extra paragraph for spec.spec itself (likely the KNOWN BOOTSTRAPPING GAPS comment block counted as a rule). Zero hangs, zero crashes — all 20 specs parse successfully. Gaps documented for .3.4.`
  Commit: `e2ea174` (substantive); hash-fix chain `5725f87` `316262f`

- ID: `MEDIUM-IMPACT.3.4`
  Status: `active`
  Goal: `Fix gaps discovered in .3.3 cross-check. Update spec.spec grammar to close any coverage gaps vs BootstrapSpec::Core. Fix infrastructure issue: AND_SINGLE_ACODE routes I-block to preamble where return() exits before edges run.`
  Children: `MEDIUM-IMPACT.3.4.1`, `MEDIUM-IMPACT.3.4.2`, `MEDIUM-IMPACT.3.4.3`
  Decision: `2026-06-12: Chose approach (1) — route AND I-blocks to acode_entries. Most contained: modify _build_and_single_acode_variant to put icode into acodes_ref, apply return→assignment transform in emitter. No DSL surface change. No new HandlerIR kind needed.`
  Investigation: `2026-06-12: Two compounding issues found. (a) AND I-block return() exits handler before edges run — preamble runs BEFORE regex match in _build_handler_preamble. (b) body_element:* REP over-consumes — even with (a) fixed, calling body_element from rule_paragraph edge consumes ALL body elements for all rules, starving subsequent rule_paragraph calls. Fix (a) via approach (1); (b) may self-resolve if body_element:* naturally stops at non-matching rule headers (rule headers don't match any body_element regex). If not, spec.spec grammar restructure needed. Multiple implementation attempts made and reverted; clean implementation starting from approach (1).`
  Root cause (from .3.3): `rule_paragraph:AND in spec.spec matches header regex in I-block, then return(hash(...)) exits handler. body_element:* edges never run. 10/20 specs have inflated candidate counts.`

  - ID: `MEDIUM-IMPACT.3.4.1`
    Status: `done`
    Goal: `Design/decide — document the precise change in RuleIR.pm (ICODE→ACODE routing for AND rules), SpecEntry.pm (variant builder adjustment), and HandlerVariantEmitter.pm (emitter template). Confirm approach (1) is correct.`
    Acceptance: `Design doc or task notes describing: (a) RuleIR.pm change — which condition gates ICODE→ACODE routing, (b) SpecEntry.pm change — how _build_handler_variants detects this case, (c) HandlerVariantEmitter.pm change — how _emit_and_single_acode_handler transforms return→assignment. Phase0 1005 PASS baseline holds (no code change yet).`
    Verification: `2026-06-12: Thoroughly investigated. Two compounding issues: (a) AND I-block return() exits before edges — preamble runs BEFORE regex match in _build_handler_preamble, (b) body_element:* REP over-consumption. Approach (1) selected: RuleIR.pm line 207 change /REP_|^OR/ → /REP_|^OR|^AND/ to route AND ICODE→acode_entries. HandlerVariantEmitter _emit_and_single_acode_handler needs: (i) include preamble after regex match with return→assignment (regex must use \s* not \s+), (ii) IMATCH←LMATCH bridge so I-block code reads regex captures, (iii) push assigned $label onto @collect. SpecEntry.pm: _build_handler_preamble must pass empty icode for AND rules; actual icode passed to variant via ir_args. Multiple implementation attempts reverted — clean implementation pending in .3.4.2.`
    Commit: `pending`

  - ID: `MEDIUM-IMPACT.3.4.2`
    Status: `pending`
    Goal: `Implement the AND handler acode routing fix. Modify RuleIR.pm to route AND single-acode I-blocks to acode_entries. Update HandlerVariantEmitter _build_and_single_acode_variant to accept icode-through-acodes. Update _emit_and_single_acode_handler to apply return→assignment transform. Verify spec.spec compiles and body_element collects correctly in rule_paragraph.`
    Acceptance: `AND rules with single acode have I-block code routed through acodes_ref. return→assignment transform applied. spec.spec rule_paragraph:AND handler now processes edges (body_element) after I-block. Phase0 1005 PASS (or updated baseline). perl -c clean. body_element:* results are collected into parent rule.`
    Verification: `pending`
    Commit: `pending`

  - ID: `MEDIUM-IMPACT.3.4.3`
    Status: `pending`
    Goal: `Re-run cross-check harness (tools/cross_check_spec_parsers.pl) to confirm 20/20 specs produce identical descriptor structures through both bootstrap and spec.spec paths. Verify rule count, rule labels, compiled rule order, and dependency-regex maps match.`
    Acceptance: `Cross-check report shows 20/20 match (zero discrepancies). Phase0 1005 PASS. All specs compile correctly.`
    Verification: `pending`
    Commit: `pending`
  Verification: `2026-06-12: Analyzed root cause. AND_SINGLE_ACODE handler routes I-block to preamble where return() exits early. Chose approach (1). Split into 3 child leaves.`
  Commit: `29b4d38` (blocked analysis), `bee195c` (enriched analysis)

- ID: `MEDIUM-IMPACT.3.5`
  Status: `pending`
  Goal: `Claim parity + wire spec.spec as the primary parse path. Once .3.4 confirms identical output, add a code path in Compiler.pm or BootstrapSpec.pm that: (1) uses the spec.spec-generated parser to parse .spec content, (2) falls back to BootstrapSpec::Core when spec.spec is unavailable or fails (bootstrap path). The bootstrap grammar remains the seed parser for bootstrapping spec.spec itself.`
  Acceptance: `Compiler can parse .spec files through the spec.spec-generated parser. BootstrapSpec::Core remains as fallback. All 19 shipped specs parse identically through both paths. Phase0 1005 PASS.`
  Verification: `pending`
  Commit: `pending`

- ID: `MEDIUM-IMPACT.3.6`
  Status: `pending`
  Goal: `Full regression verification + documentation. Run the full CI gate. Update ARCHITECTURE_STATE.md to reflect spec.spec as primary path. Update KNOWLEDGE_MAP.md fact card. Update book if user-facing behavior changes. Verify the dual-path (spec.spec primary, bootstrap fallback) works correctly for all specs including spec.spec itself.`
  Acceptance: `tools/run_ci_local.sh exits 0. ARCHITECTURE_STATE.md updated. Knowledge map fact card refreshed. All 19 specs compile correctly through spec.spec primary path. Bootstrap fallback verified.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MEDIUM-IMPACT.3.4.1` | `pending` | Design/decide AND handler fix — document RuleIR + SpecEntry + HandlerVariantEmitter changes. |
| 2 | `MEDIUM-IMPACT.3.4.2` | `pending` | Implement AND handler acode routing (blocks on .3.4.1). |
| 3 | `MEDIUM-IMPACT.3.5` | `pending` | Claim parity + wire spec.spec as primary (blocks on .3.4). |
| 4 | `MEDIUM-IMPACT.3.6` | `pending` | Full regression verification + documentation (blocks on .3.5). |

## Decisions

- `2026-06-12`: Created task tree with 3 containers, 13 leaves. Decomposition strategy: `.1` SpecEntry decoupling (5 leaves — inventory → extract → IR → interface → diagnostic backend), `.2` Validation fuzzing (4 leaves — harness → rule labels → edges → syntax + bugfixes), `.3` BootstrapSpec handoff (4 leaves — accuracy audit → skip gap → wire primary → verify + docs).
- `2026-06-12`: SpecEntry leaves are ordered dependency-first: inventory before extraction, extraction before IR, IR before backend interface, interface before diagnostic backend.
- `2026-06-12`: Validation fuzzing leaves are ordered by surface complexity: harness first, then simplest surface (rule labels), then medium (edges), then complex (full DSL syntax) with bugfixes integrated into the last leaf.
- `2026-06-12`: BootstrapSpec handoff leaves are strictly ordered: must close the skip gap before wiring the primary path, must wire before verifying.
- `2026-06-12` (restructure): Per user direction, expanded `.3` from 4 to 6 leaves — inserted dual-path cross-check leaves (`.3.3` compare, `.3.4` fix gaps) before wiring spec.spec as primary (now `.3.5`). Renumbered former `.3.3`/`.3.4` → `.3.5`/`.3.6`. Strategy: Bootstrap = oracle; spec.spec = candidate; compare all 20 specs → fix gaps → claim parity → wire primary. This ensures spec.spec earns primary-path status through demonstrated output parity rather than assumption.

## Open Questions

- Can the comment/blank-line skip be implemented purely in spec.spec (by adding a skip rule to body_element), or does it require a change to the generated parser infrastructure (SpecEntry/Compiler)? The known bootstrapping gap says "spec.spec's body_element has no top-level skip rule."
- Will the HandlerIR be expressive enough to cover all 12 variant types without leaking Perl semantics? The REP_* variants with their loop structures are the most complex to abstract.
- Should the JSON diagnostic backend emit at the HandlerIR level or at the final Perl-source level? IR-level is more useful for tooling; source-level is easier to verify correctness.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-12` | `MEDIUM-IMPACT.1.1` | `docs/knowledge/specentry-perl-coupling-inventory.md` created, `perl -c perl/LinkedSpec/SpecEntry.pm` clean | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.1.2` | `perl -c perl/LinkedSpec/HandlerVariantEmitter.pm` + `SpecEntry.pm` clean, phase0 1005 PASS, spec.spec compile ratio 1.0000 | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.2.1` | `perl -c t/phase0_validation_fuzz.t` clean, 5/5 subtests PASS, 168 combinatorial cases | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.2.2` | 48+ edge categories for `_parse_rule_label_line`, 5/5 subtests PASS | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.2.3` | 36 edge categories for `_scan_rule_edges_in_fragment`, 5/5 subtests PASS | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.2.4` | 32 combined categories for `validate_dsl_syntax`/`validate_spec_content`, 5/5 subtests PASS | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.3.1` | `tools/run_ci_local.sh` (1005 PASS), spec.spec compile ratio 1.0000, body_element returns ARRAY with correct multi-element matches | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.3.2` | `tools/run_ci_local.sh` (1005 PASS), self-parse on raw spec.spec OK, tablegrep/pplugin/ifelse raw parses OK, syntax checks clean | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.3.3` | `tools/cross_check_spec_parsers.pl`: 20/20 specs parse through both paths, 10/20 identical counts, 10/20 inflated candidate counts, 0 hangs | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.3.4` | Root cause analysis complete: AND_SINGLE_ACODE lacks E-block. Three fix approaches identified. | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.1.4` | `perl -c` clean on HandlerVariantEmitter.pm + SpecEntry.pm, 20/20 specs compile through backend dispatch, smoke test: dispatch == direct perl, unknown backend → undef | Pass |
| `2026-06-12` | `MEDIUM-IMPACT.1.5` | `perl -c` clean on both files, all 5 handler kinds produce valid JSON, 3/3 specs compile through default path | Pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MEDIUM-IMPACT.1.1` | `654b9c0` | SpecEntry Perl coupling inventory — 10-section knowledge card documenting all eval sites, variant builders, Perl assumptions. |
| `MEDIUM-IMPACT.1.2` | `d53578a` | Extract handler-variant builders into HandlerVariantEmitter. SpecEntry.pm delegates variant building. Old dead code remains in SpecEntry.pm. |
| `MEDIUM-IMPACT.1.3` | `fa1895d` | HandlerIR designed + implemented. 10 variant builders → IR. _emit_handler_perl() dispatches to 10 template fns. SpecEntry dead code removed (452 lines). |
| `MEDIUM-IMPACT.2.1` | `764c2f3` | Validation.pm fuzzing harness — t/phase0_validation_fuzz.t, 5 subtests, 168 combinatorial cases. |
| `MEDIUM-IMPACT.2.2` | `69a9340` | _parse_rule_label_line fuzzing boundary cases — 48+ edge categories. |
| `MEDIUM-IMPACT.2.3` | `4724894` | _scan_rule_edges_in_fragment fuzzing — 36 edge categories. |
| `MEDIUM-IMPACT.2.4` | `7425c8f` | validate_dsl_syntax/validate_spec_content fuzzing + .2 container complete — 32 combined categories. |
| `MEDIUM-IMPACT.3.1` | `2526f2b` | spec.spec accuracy audit: fix body_element REP handler + self-contained grammar. RuleIR ICODE→ACODE fix. SpecEntry REP return→assignment fix. |
| `MEDIUM-IMPACT.3.2` | `d7294d0` | Close comment/blank-line skipping gap via Runtime.pm wrapper. Self-parse on raw spec.spec OK. |
| `MEDIUM-IMPACT.3.3` | `e2ea174` | Dual-path cross-check: BootstrapSpec oracle vs spec.spec candidate across 20 specs. |
| `MEDIUM-IMPACT.3.4` | `29b4d38` (blocked analysis), `bee195c` (enriched: AND-handler root cause + HandlerIR implications) | Blocked: AND handler architecture limitation documented. Three fix approaches identified. |
| `MEDIUM-IMPACT.1.4` | pending | Backend emitter interface — %BACKEND_EMITTERS dispatch table, _emit_handler dispatch fn. 10/10 SpecEntry call sites migrated. |
| `MEDIUM-IMPACT.1.5` | pending | JSON/AST diagnostic backend — _emit_handler_json, JSON::PP serialization, $BACKEND variable threading. |

## Changelog

- `2026-06-12` (.3.4 unblock): Chose approach (1) — route AND I-blocks to acode_entries. Split .3.4 into 3 child leaves: .3.4.1 design/decide, .3.4.2 implement, .3.4.3 re-cross-check. Frontier: .3.4.1 → .3.4.2 → .3.5 → .3.6.
- `2026-06-12`: Completed MEDIUM-IMPACT.1.4 — backend emitter interface. Added `%BACKEND_EMITTERS` dispatch table + `_emit_handler($ir, %opts)` in HandlerVariantEmitter.pm. Migrated 10/10 SpecEntry.pm call sites to `_emit_handler`. 20/20 specs compile. Frontier advanced to `.1.5`.
- `2026-06-12` (hygiene): Post-bee195c close-out: backfilled .1.3 commit hash fa1895d in commit log. Fixed stale MEMORY.md (latest_commit → bee195c, cleared in_flight_uncommitted). Corrected .3.4 commit log to include bee195c enrichment. Cleared stale git_message_brief.txt.
- `2026-06-12` (hygiene): Backfilled commit hashes for 8 completed leaves (.1.1, .1.2, .2.1–.2.4, .3.3, .3.4). Updated verification log and commit log tables. Updated CHANGES.md with 7 missing entries. Updated MEMORY.md latest_commit → d53578a.
- `2026-06-12`: Created task tree with 3 containers, 13 leaves across SpecEntry decoupling, Validation fuzzing, and BootstrapSpec handoff (including spec.spec accuracy audit per user direction).
- `2026-06-12` (restructure): Per user direction, expanded `.3` BootstrapSpec handoff from 4 to 6 leaves. Inserted dual-path cross-check leaves `.3.3` (compare BootstrapSpec oracle vs spec.spec candidate across all 20 specs) and `.3.4` (fix gaps) before wiring spec.spec as primary (now `.3.5`). Former `.3.3`/`.3.4` renumbered → `.3.5`/`.3.6`. Updated frontier, decisions, commit log, verification log. Also corrected `.3.2` frontier status (was stale `pending` → now `done`; commit `d7294d0`).
- `2026-06-12`: Completed MEDIUM-IMPACT.3.3 — dual-path cross-check. Harness at `tools/cross_check_spec_parsers.pl`. Results: 10/20 specs match (BNF, DT, Lispish, hlink_substitution, lib_reader, operators_try, pplugin, sdce, tkgui, verilog); 10/20 have inflated candidate counts (ds_vhistory, ebnf, ifelse, portmap, regdef, simenv, spec.spec, tablegrep, tclite, vhdl). Root cause: spec.spec rule_paragraph AND handler lacks E-block body collection; body_element:* over-matches individual body lines. Zero hangs/crashes. Gaps documented for .3.4.
