# SPEC-LANG-REFERENCE: Complete, variant-agnostic, example-rich book coverage of the entire `.spec` language

## Metadata

- Tree ID: `SPEC-LANG-REFERENCE`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-17`
- Last updated: `2026-07-08` (`.10.5.20` done: ADR `0020` records lifecycle handler-shape
  drift as a documented current Perl-reference caveat until a separately-owned implementation/parity
  leaf authorizes behavior changes; `.10.5` whole-book scorch is complete and frontier returns to
  `.5.3` Array helper worked examples. Earlier **MAJOR
  CORRECTION** — user established that a `.spec` top (`::`) rule has NO regex; a valid spec needs >=2
  rules (top entry + >=1 normal `:` rule carrying the regex). Remediation remains documentation-only
  and owned by `.10.3`/`.10.5`; Perl reference untouched.)
- Owner: repo-local workflow

## Goal

Make the mdBook (`docs/linkedspec-book/`) **completely, accurately, and variant-agnostically**
document the **entire `.spec` language surface** — every construct a user can write in a `.spec`
file — with **abundant worked examples**, so a new backend (Julia, Dart, …) can be implemented
**from the book alone, without doing archaeology** in the Perl reference source. Add Knowledge
Map fact cards for the key durable `.spec`-language subjects so future sessions retrieve them
instead of re-deriving.

The surface to cover (authoritative sources in parentheses) includes at least:
- file/paragraph model: rule labels `:` (body) vs `::` (top), the paragraph model, regex
  clusters, same-line vs multiline interleaving (`BootstrapSpec/Core.pm`, `Validation.pm`).
- rule modes: `:AND`, `:OR`, `:&`, `:|`, `:+`, `:*`, `:?`, `:OR+`, `:AND+`, and the bounded
  `:AND{N,M}` / `:OR{N,M}` families (`Core.pm` mode-alias map; `Validation::_parse_rule_label_line`).
- parse modes: `seek` vs `consume` and cursor discipline (`runtime-semantics`).
- edges: action `->` vs blind `=>`, target indexing `-> rule[N]`, grouped shared-code targets,
  fluent continuations after edges, zero-progress guards (`Core.pm`, `Compiler.pm`).
- lifecycle markers: `I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX` — meaning, ordering, `retv`, the
  semicolon-light structured form and the fluent form.
- capture/mark surface: `@capture_slice`, `@mark(name)`, the anonymous and named capture-slice
  families, `mark_*`, `capture_*_from`/`_between`, input/entry/match readers.
- the full helper-contract catalog: every supported helper family + signatures + lowering
  identity (`ActionIR/Contracts.pm`; `appendix/helper-contract-catalog.md`).
- control flow: `if/elseif/else`, `switch/case/default`, nesting, fluent vs structured.
- runtime semantics: entry vs local match, `retv`, accumulator, return semantics, output shape.

## Non-Goals

- Changing the `.spec` language or any backend behavior — documentation only.
- Documenting Perl/Rust implementation internals as if they were the contract; everything
  user-facing must stay the variant-agnostic `.spec` contract (Perl = reference backend).
- Re-narrating git/roadmap history into the book.
- A second `spec.spec` — this is book prose + examples, not grammar code.

## Acceptance Criteria

- Every `.spec`-language construct (the surface above) is documented in the book with at least
  one worked example; high-frequency surfaces get several.
- No construct requires reading Perl/Rust source to understand or re-implement (no archaeology).
- All examples are valid against the shipped grammar / specs (no malformed `.spec` snippets).
- KM fact cards exist for the key durable subjects identified by the audit.
- `mdbook build` succeeds; `scripts/check_memory_architecture.sh` + KM gate pass.
- Each leaf committed via `COMMIT.md`.

## Task Tree

- ID: `SPEC-LANG-REFERENCE`
  Status: `active`
  Goal: Complete + variant-agnostic + example-rich book coverage of the whole `.spec` language
  Children: `.1`–`.4` (done), `.5` (active: `.5.1`–`.5.2` done, `.5.3`–`.5.5` pending), `.6`, `.7`,
  `.8`, `.9` (done — §5.5 drift fix, but used INVALID structure — superseded by `.10.4`), `.10`
  (**CORRECTED**: remediate structurally-invalid examples in `.5.2`/`.9`; NO engine bug; `.10.1`
  verdict superseded, `.10.2` superseded; remediation `.10.3`/`.10.5`; `.10.5.4.1` reactivated the
  paused scorch and `.10.5.20` is done; `.5.3` is the next helper-example leaf)

- ID: `SPEC-LANG-REFERENCE.1`
  Status: `done`
  Goal: Audit — enumerate the complete `.spec` surface from authoritative sources and map the
  book's current coverage (depth, example density, variant-neutrality) into a categorized gap
  list + a KM-card candidate list, which becomes the decomposition into concrete gap-filling
  leaves
  Acceptance: a recorded inventory of every `.spec` construct (with its authoritative source),
  a per-construct coverage verdict (well-covered / thin / missing / variant-leaking /
  example-poor) citing book file:line, a prioritized gap list, and a KM-card candidate list;
  concrete `.2…` leaves added to the frontier; no book content change in this leaf (audit only).
  Verification: Done — 2026-06-17. Two read-only audits (authoritative `.spec` surface
  inventory from `Core.pm`/`Validation.pm`/`Contracts.pm`/`spec.spec`/shipped specs ∥ book
  coverage map over all `user-model`/`dsl`/`compiler`/`appendix` chapters) synthesized into the
  "Audit Findings" section below. Result: **8 of 10 surface areas already WELL-COVERED** (rule
  labels, rule modes, parse modes, edges, lifecycle markers, capture/marks, helper catalog,
  control flow); the binding gaps are the **output/return-shape contract** and **regex as a
  first-class concept**, plus smaller clarity/example gaps. Decomposed into `.2`–`.8` (below).
  One inventory claim was rejected on verification: the surface agent called lifecycle markers
  `E`/`IT` "deprecated", which contradicts the completed `LIFECYCLE-FAMILY-AUDIT` (all 7 markers
  equivalent/supported) — NOT propagated. No book content changed (audit only).
  Commit: `SPEC-LANG-REFERENCE.1` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.2`
  Status: `done`
  Goal: Document **regex in `.spec` as a first-class concept** (CRITICAL gap) — a backend must
  know exactly what its regex engine has to support
  Acceptance: a user-facing treatment (new `user-model` chapter and/or expanded
  `appendix/formal-grammar.md`) of: `/pattern/` literal syntax + delimiter escaping; the
  multi-cluster ordered-sequence model; the capture-group ↔ `entry_group(N)`/`match_group(N)` /
  `entry_named(name)`/`match_named(name)` indexing relationship; and an explicit, **verified**
  statement of the regex feature set a backend must provide (alternation with position tracking
  per `LinkedRE`; numbered + named capture groups; which flags are/aren't part of the contract).
  Verify engine capabilities against `perl/LinkedRE.pm` + the rgx engine before asserting them
  (do NOT guess). Several worked examples; `mdbook build` exit 0.
  Verification: Done — 2026-06-17. New chapter `docs/linkedspec-book/src/user-model/regex-in-spec.md`
  (registered in `SUMMARY.md`) covering: `/pattern/` literal + `\/` escaping + inline `(?flags)`;
  regex slots/clusters → ordered-sequence (AND) vs alternatives (OR) + which-alternative branch
  tracking; `seek`/`consume` anchoring; numbered groups (**0-based, captures-only, compacted**),
  named groups, the compaction gotcha + named-group remedy, entry-vs-match; and a verified
  "regex feature set a backend must support" section. `appendix/formal-grammar.md §3.1` expanded
  with the capture-group contract + inline-flags clarification. **All engine facts verified
  against `perl/LinkedRE.pm` (`oredRE`/`_build_match_info`: `match_list = [grep defined $1..$N]`),
  the ActionIR lowering (`Contracts.pm` `entry_group`→`$IMATCH_LIST[N]`, `match_group`→`$LMATCH_LIST[N]`),
  the Rust `rgx` runtime (`CompiledAlternation` + `matched_branch_number` + per-branch `group_offset`),
  and cross-checked against shipped specs (`lib_reader.spec`/`tablegrep.spec`/`spec.spec` all use
  `entry_group(0)`=first capture).** Found + corrected a real capture-indexing **contradiction**:
  `helper-contract-catalog.md` claimed "index 0 is the full match" (wrong) while the walkthrough
  said 0 = first capture (right); fixed the catalog, fixed two buggy examples that used the wrong
  1-based convention (`overview/what-is-linkedspec.md`, `appendix/formal-grammar.md` Child rule),
  and added a captures-only/compacted clarifier to `source-boundary-helper-reference.md`. This
  closes the capture-group-mapping accuracy concern, so `.5` (helper-catalog sweep) need not
  re-litigate the indexing contract. `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.2` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.3`
  Status: `done`
  Goal: Document the **output / return-value shape contract** (CRITICAL gap) in
  `appendix/runtime-semantics.md`
  Acceptance: a new section defining what a `.spec` parser returns — the top rule's value, the
  implicit accumulator model, the canonical one-level wrap, the tagged-shape convention
  (`["?rule:", [...]]`), and how `return(...)` interacts with the accumulator — grounded in the
  `docs/knowledge/rust-perl-output-oracle.md` card + shipped specs, with worked input→output
  examples so a backend does not reverse-engineer it from the corpus. `mdbook build` exit 0.
  Verification: Done — 2026-06-17. Expanded `appendix/runtime-semantics.md §5` (renamed
  "Accumulator Convention" → "Accumulator and Output Shape") with four new subsections: §5.5
  *What a Parser Returns* (top rule's value, returned directly, no envelope) with three **verified**
  input→output pairs; §5.6 *The Output Shape Is the Author's Choice* (engine imposes **no output schema**; `["?<rule>:", …]`, tag-only form, `a(...)`
  / `flat_array(...)`, tag is a plain string with **no engine meaning** — presented as an **optional, older convention** (authors may use any output shape, or none), per user feedback 2026-06-17 that the tagged shape must not be shown as mandatory); §5.7 *`return(...)` versus the
  accumulator* (return = value channel; a child return is consumed explicitly, not auto-appended to
  the parent accumulator; canonical `return(a("?rule:", array_copy(a(acc))))`); §5.8 *Backend Output
  Reconciliation* (the one-level wrap — reference value is canonical; an accumulator-returning runtime
  wraps one level; oracle stores the reference value and compares against `[reference]`). **Grounded
  + verified, not guessed**: the two literal examples are frozen oracle-corpus fixtures
  (`rust/linkedspec-runtime/tests/corpus/proof_edge_{scalar,array}_literal/expected.json`); the tagged
  `["?pair:","key","val"]` example was produced by **running the Perl reference** (`LinkedSpec::Get`);
  the tagged convention was confirmed by grepping shipped specs (`ds_vhistory`/`portmap`/`vhdl`/`regdef`);
  the wrap + return-vs-accumulator contract is grounded in `docs/knowledge/rust-perl-output-oracle.md`.
  A hand-built accumulator example that returned `[undef,undef,undef]` was **discarded** rather than
  documented — repeated-rule accumulator mechanics are subtle, so only verified material was used.
  `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.3` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.4`
  Status: `done`
  Goal: Add worked examples for the MAJOR/MEDIUM clarity gaps — grouped shared-code targets
  (`-> A | B { ... }`) and an entry-vs-local-match divergence scenario
  Acceptance: a worked example of a grouped shared-code action edge (multiple targets, one
  block) in the edges chapter; a worked example showing when `entry_*` and `match_*` return
  different values (multi-regex-slot / dispatched-child case) in the capture/lifecycle chapter;
  examples valid against the grammar; `mdbook build` exit 0.
  Verification: Done — 2026-06-17. (1) Added a **Grouped action-edge targets** section to
  `dsl/action-and-lifecycle-placement.md` (`-> RuleA | RuleB { ... }`, one shared block bound to
  multiple targets), grounded in the shipped `ebnf.spec` `semantic_annotation` rule and the formal
  grammar §3.2; a minimal grouped-target spec was confirmed to **compile** (`LinkedSpec::Get` builds
  a parser). (2) Added a **When `entry_*` and `match_*` diverge** section to
  `dsl/capture-marks-and-source-locations.md` — a dispatched-child example (`Call`→`Inner` over
  `greet(world)`) where `entry_text()` reads the entering `greet(` match and `match_text()` reads the
  local `world` match, cross-linked to the source-boundary "Entry versus match example"; the example
  **compiles** (verified). **Verified, not guessed**: both examples were compiled through the Perl
  reference; the divergence semantics are grounded in the verified source wiring (`entry_*` = IMATCH /
  entering match, `match_*` = LMATCH / local match — from `.2`'s `Contracts.pm`/`SpecEntry.pm`/
  `HandlerVariantEmitter.pm` reading) and are consistent with the book's existing source-boundary
  example. **Honest scope note**: a clean *top-level runtime output* dump for the divergence was
  **not** fabricated — ~9 minimal accumulator/dispatch shapes were run and all collapsed to
  `[]`/`undef`/`0` (the documented hard accumulator-/child-return divergence axes in
  `docs/knowledge/rust-perl-output-oracle.md`), so the divergence is documented at the verified
  reader-wiring level (which span each family reads), matching the book's established style, rather
  than an unverified I/O. `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.4` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.5`
  Status: `active`
  Goal: Helper-contract catalog **completeness + variant-neutrality + examples** sweep
  Acceptance: confirm every helper family in `perl/LinkedSpec/ActionIR/Contracts.pm` is
  represented in `appendix/helper-contract-catalog.md` with a backend-neutral behavioral
  contract (signature + semantics + edge cases) and at least one example; separate any
  Perl-implementation note from the contract; add examples where the catalog is example-poor.
  **Split during implementation (the surface is large)** — see Audit Findings (`.5`) below.
  Children: `.5.1` (done), `.5.2` (done), `.5.3`, `.5.4`, `.5.5`

- ID: `SPEC-LANG-REFERENCE.5.1`
  Status: `done`
  Goal: Completeness confirmation + variant-neutrality fixes + decomposition
  Acceptance: a read-only completeness audit (every `Contracts.pm` helper id vs the catalog),
  the variant-neutrality fixes the audit flags, and the per-family example decomposition recorded
  as `.5.2`–`.5.x`. `mdbook build` exit 0.
  Verification: Done — 2026-06-17. A read-only audit (delegated) reconciled the `Contracts.pm`
  helper-id set against the catalog and found: **(completeness) ZERO public-API gaps** — all ~130
  public helpers are documented; the 158 (loose `\bid\b => '`) vs 146 (anchored) vs 140 (`###`
  headings) spread is **17 internal IR variants** (all map to documented DSL names, e.g.
  `capture_from_mark`→`capture_from(name)`) + **~11 deprecated `compatibility_surface => 1`
  contracts** (`my_declare_bare`/`exit_bare`/…, intentionally not public). **(variant-neutrality)
  2 Perl-sigil leaks** — `declare(scalar, name)` said "variable `$name`" (→ "named `name`") and
  `push(arr, child)` said "implicit accumulator `$rule_label`" (→ "named after the rule label");
  both fixed, and a whole-catalog re-sweep (`$`/`@`/`%` sigils + `lowers to`/`do {`/`Data::Dumper`/
  `JSON::PP`/`//gcp`) confirmed **no others**. **(examples) 0 `.spec` examples across all 10
  families / ~140 helpers** — the large remaining surface, decomposed into per-family example
  sub-leaves `.5.2`–`.5.5` (≥1 worked, compile-verified example per family; the original `.5`
  acceptance's "at least one example" is per-family). `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.5.1` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.5.2`
  Status: `done`
  Goal: Worked examples — Scalar + Numeric helper families
  Acceptance: ≥1 compile-verified `.spec` example per family added to the Scalar and Numeric
  sections of `helper-contract-catalog.md`, with several more for high-frequency helpers; every
  example built through `LinkedSpec::Get` before asserting behavior. `mdbook build` exit 0.
  Verification: Done — 2026-06-17. Added a shared **Worked examples** preamble to §2 (Scalar)
  and a back-reference in §5 (Numeric), then a **verified** `Example` to **every** helper in both
  families (17 Scalar + 18 Numeric = 35 helpers covered). **Every example was compile-AND-run
  verified through `LinkedSpec::Get`** with a scratch oracle-style driver (build parser → run on
  the documented input → JSON-encode the top-level value with the same `JSON::PP->canonical`
  encoder as `tools/gen_oracle_corpus.pl`); the driver was sanity-checked against the two frozen
  oracle fixtures (`proof_edge_{scalar,array}_literal`) and reproduced them exactly, so its outputs
  are the reference behavior — nothing guessed. **Two do-not-guess traps caught and avoided**:
  (1) the value-returning vs condition-only split — `is_defined`/`is_undefined` lower **only** via
  the control-flow path (`ActionIR/FlowExpr.pm` `_lower_flow_composite_expr`, NOT the value-expr
  regex set at `FlowExpr.pm:270`), so `return(is_defined(x))` dies with "Undefined subroutine"; they
  are documented in the verified `if (is_defined(x)) { … }` condition form with a "condition-only"
  usage note (`matches`/`starts_with`/`ends_with`/`contains_substr` ARE value-expressible and
  surface as `1`/`0`); (2) `num_sum(split(...))` returns `null` (the `split→num_sum` composition does
  not flatten here) — so the array-form reducers are documented with an explicit `array(...)` of
  capture groups / literals (verified: `num_sum(array(1,2,3,4))`→`10`), and `split` is left to the
  Array family (`.5.3`). The reliable doc scaffold is `Demo:: /<re>/ -> Demo { return(<expr>) }`
  (bare-`::` OR self-ref edge), confirmed by reproducing the frozen fixtures. `mdbook build` exit 0.
  **Discovered defect (NOT fixed here — owned by new leaf `.9`, no bundling):** the §5.5
  `runtime-semantics.md` "verified" Pair example (`Pair::AND … -> Pair[0] { return(array("?pair:",
  …)) }`) actually outputs `[]`, not the documented `["?pair:","key","val"]`; the tagged array is
  produced by the OR self-ref form `Pair:: … -> Pair { return(array(…)) }` (verified) — `.3`'s live
  run used a self-ref-OR shape that was mis-transcribed into the `AND`/`[0]` form.
  Commit: `SPEC-LANG-REFERENCE.5.2` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.5.3`
  Status: `pending`
  Goal: Worked examples — Array helper family (largest, ~33 helpers)
  Acceptance: ≥1 compile-verified example for the Array family plus several for high-frequency
  array helpers (`split`, `map`-likes, reducers, edge drops); built through `LinkedSpec::Get`.
  `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.5.4`
  Status: `pending`
  Goal: Worked examples — Hash + Control Flow helper families
  Acceptance: ≥1 compile-verified example per family (Hash + Control Flow), built through
  `LinkedSpec::Get`. `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.5.5`
  Status: `pending`
  Goal: Worked examples — Declaration, Capture/Mark, Entry/Match, Input, Call families
  Acceptance: ≥1 compile-verified example per remaining family, built through `LinkedSpec::Get`;
  closes `.5`. `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.6`
  Status: `pending`
  Goal: Capture/mark cross-example + any remaining thin spots
  Acceptance: one worked rule exercising the anonymous + named capture/mark families together
  (`@capture_slice`, `@mark(name)`, `capture_*_from`/`_between`, `mark_*`), plus any
  small thin-spot fixes the audit flagged; `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.7`
  Status: `pending`
  Goal: Knowledge Map fact cards for the durable `.spec`-language subjects
  Acceptance: KM cards (`docs/knowledge/<id>.md`, with `answers:` front-matter) for the key
  durable subjects — at least: the output/return-shape contract, the regex feature-set a
  backend must support, the rule-mode→semantics map (incl. `:&`/`:|`), lifecycle execution
  order + `retv`, the action-vs-blind edge/dispatch model, and the capture/mark family
  taxonomy; KM gate regenerates `KNOWLEDGE_MAP.md` and passes. (Cards may be written alongside
  their originating leaf; this leaf ensures full coverage.)
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.9`
  Status: `done`
  Goal: Correct the drifted "verified" output in `runtime-semantics.md` §5.5 (Pair example)
  Acceptance: change the §5.5 third example so its documented output matches a **re-verified**
  live run — the `["?pair:","key","val"]` output requires the OR self-ref form
  `Pair:: /(\w+)=(\w+)/ -> Pair { return(array("?pair:", match_group(0), match_group(1))) }`
  (the current `Pair::AND … -> Pair[0]` form actually returns `[]`). Re-run the corrected snippet
  through `LinkedSpec::Get` before asserting; check no other §5.5/§5.6 snippet has the same
  AND-`[N]`-self-edge drift; `mdbook build` exit 0. (Discovered during `.5.2`; high priority —
  a known-wrong "verified" example violates the no-drift doctrine.)
  Verification: Done — 2026-06-17. Re-verified with the scratch oracle driver: the **current**
  `Pair::AND … -> Pair[0] { return(array(…)) }` form outputs `[]` (reconfirmed under default,
  `consume`, AND `seek` — parse mode is NOT the variable); the **corrected** OR self-ref form
  `Pair:: … -> Pair { return(array("?pair:", match_group(0), match_group(1))) }` outputs
  `["?pair:","key","val"]` (verified default + consume). Fixed the §5.5 third example to that form
  and added a one-line note that the self-ref action edge (`-> Pair`) is what surfaces the return
  value (§5.7 cross-ref). §5.5/§5.6 sweep: the first two §5.5 examples are frozen Top→Done OR
  fixtures (correct); the §5.6 `object`/`manifest` snippets are `I.return` fluent on `:` body rules
  (a different construct, grounded in shipped specs — NOT the AND-`[N]`-self-edge class, left
  untouched; a faithful standalone reconstruction is entangled with entry-group seeding per the
  `.4` lesson, so not rewritten here). `mdbook build` exit 0. **Discovered a SYSTEMIC variant of
  this drift** (owned by new leaf `.10`, not bundled): the same single-slot `::AND … -> Rule[0]
  { return(...) }` form is used in **several other chapters that assert a concrete top-level output**
  — most importantly `user-model/worked-spec-walkthrough.md` (claims `{kind=>"pair",…}` for
  `answer = 42`; actually returns `[]`). Shipped specs DO use `-> Rule[N] { return(...) }` self-edges,
  but on **multi-slot** rules returning at the closing slot (often an accumulator snapshot), so the
  construct is real — the drift is specifically single-slot `::AND` self-edge examples claiming the
  `return` value as output.
  Commit: `SPEC-LANG-REFERENCE.9` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10`
  Status: `active`
  Goal: **CORRECTED (2026-06-17, user)** — Remediate the structurally-INVALID `.spec` examples
  (regex on the top rule / single-rule grammars) introduced in `.5.2`/`.9`, and retract the
  mis-diagnosed `.10.1` "engine bug" record. **There is NO engine bug.** The `[]` outputs were the
  result of invalid spec structure, not an `AND_SINGLE_ACODE` regression. See "CORRECTION" in
  Decisions below. The Perl reference is authoritative and is NOT to be touched
  ([[feedback_do-not-fix-reference-engine]]).
  Children: `.10.1` (done — investigation; its verdict is now **superseded** — see note), `.10.2`
  (**superseded** — the engine-fix-vs-doc fork is moot), `.10.3` (done — redid `.5.2` examples + both
  preambles with the verified 2-rule idiom), `.10.6` (done — retracted the inaccurate `[]` premise;
  rationale = the 2-rule authoring doctrine), `.10.5.4.1` (done — reactivated the paused scorch),
  `.10.5` (remediation active; `.10.5.5` next)

- ID: `SPEC-LANG-REFERENCE.10.1`
  Status: `done`
  Goal: Read-only root-cause investigation — is the single-slot-AND-self-edge-`return`→`[]`
  behavior an engine bug or intended reference behavior?
  Verification: Done — 2026-06-17. **NOTE — VERDICT SUPERSEDED 2026-06-17 by user correction.**
  The investigation traced the `[]` to a missing `push` in `_emit_and_single_acode_handler` and
  concluded "engine regression." **That conclusion was WRONG**, because the *premise* was wrong:
  the examples that returned `[]` are **structurally invalid** — they put a regex on the **top
  (`::`) rule** and/or use a single rule. A valid `.spec` has ≥2 rules (a top `::` entry rule with
  NO regex — the dispatch loop — plus ≥1 normal `:` rule carrying the regex); the top rule is
  entered without matching any regex (`BootstrapSpec/Core.pm:414,417` tag `::`→`_INITIAL`;
  `RuleIR.pm:193-195`; all 20 shipped specs have `regex_on_top=no`). So `[]` is the correct output
  for an invalid grammar, not an engine defect. The mis-diagnosis KM card
  (`and-single-acode-edge-return-dropped.md`) is **DELETED** and replaced by the correct card
  `spec-top-rule-no-regex-two-rule-minimum.md`. Lesson recorded in DEVELOPMENT_NOTES.
  Commit: `SPEC-LANG-REFERENCE.10.1` (investigation), corrected by the `.10` remediation commit.

- ID: `SPEC-LANG-REFERENCE.10.2`
  Status: `superseded`
  Goal: ~~Apply the engine-fix-vs-doc-rewrite resolution~~ — **SUPERSEDED** (2026-06-17). There is
  no engine bug and the Perl reference must not be touched, so the fork is moot. Replaced by the
  doc-remediation leaves `.10.3`–`.10.5`.
  Verification: n/a (superseded)
  Commit: n/a

- ID: `SPEC-LANG-REFERENCE.10.3`
  Status: `done`
  Goal: Redo the `.5.2` Scalar + Numeric helper examples **and the catalog "Worked examples"
  preamble** with VALID `.spec` structure
  Acceptance: replace the invalid `Demo:: /regex/ -> Demo { return(<expr>) }` scaffold (regex on the
  top rule) with the **verified** two-rule idiom — a top `::` entry rule (no regex) dispatching to a
  normal `:` rule that carries the regex and returns the helper value reading `entry_group(N)` (see
  the proven idiom in Decisions / KM card `spec-top-rule-no-regex-two-rule-minimum.md`). Re-verify
  EVERY example through `LinkedSpec::Get` (and re-derive its real output); update the preamble to
  teach the correct structure. `mdbook build` exit 0.
  Verification: Done — 2026-06-17. Rewrote the §2 (Scalar) + §5 (Numeric) "Worked examples" preambles
  and **all 33 helper examples** (17 Scalar + 16 Numeric) in `appendix/helper-contract-catalog.md` to
  the **verified two-rule idiom**: a top `demo::` entry rule (NO regex) `-> value .push` + terminal
  `LX { return(array_copy(a(demo))) }`, and a normal `value : /<re>/  I.return(<expr>)` rule reading
  **`entry_group(N)`** (not `match_group(N)`). Full `.spec` blocks (`concat`/`is_defined`/`trim`/
  `num_add`/`num_sum`) show the 2-rule form; `is_defined`/`is_undefined` keep the required
  `I { if (...) … }` block. **Every example was build-AND-run re-verified through `LinkedSpec::Get`**
  with a scratch harness that builds each spec from the exact book scaffold and JSON-encodes the
  output (`JSON::PP->canonical`), sanity-checked against the frozen `["hello-world"]` idiom. All 33
  produce the documented outputs, now the **top rule's one-element accumulator snapshot** (e.g.
  `["hello-world"]`, `[5]`, `[3.5]`, `[null]`, `[1]`/`[0]`) — the honest consequence of valid
  structure (the old invalid `Demo:: /re/ -> Demo {…}` form returned `[]`). **One do-not-guess fix:**
  `is_defined`'s `/(\w*)(\S*)/` matched twice (empty-matchable → two dispatch-loop hits →
  `["present","present"]`), corrected to `/(\w+)/` → `["present"]`. The only remaining `match_group`
  in the catalog is the §8 Entry/Match helper *reference* (correct, untouched). `mdbook build` exit 0
  (rendered HTML confirms the full blocks stay single code blocks with the required inter-rule blank
  line). self-check + KM gate pass. No Perl change.
  Commit: `SPEC-LANG-REFERENCE.10.3` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.4`
  Status: `superseded`
  Goal: ~~Redo the `.9` §5.5 `runtime-semantics.md` Pair example with valid structure~~ —
  **SUPERSEDED by `.10.5.16`** (2026-06-17). The whole-book scorch (`.10.5`) folds the §5.5 Pair fix
  into the per-file `runtime-semantics.md` leaf `.10.5.16`, which fixes all three §5.5 forms + the
  §5.6 fragments together. No separate work here.
  Verification: n/a (superseded)
  Commit: n/a

- ID: `SPEC-LANG-REFERENCE.10.5`
  Status: `active`
  Goal: **SCORCH THE WHOLE BOOK** (user directive 2026-06-17 — "the book shall not mislead; only
  truthful, valid code snippets") — exhaustively audit **EVERY** `.spec` code snippet across all of
  `docs/linkedspec-book/src/**` for (i) doctrine-validity (NO regex on a top `::` rule; ≥2 rules)
  and (ii) output-correctness (any claimed input→output matches a `LinkedSpec::Get` run), then
  remediate every misleading/invalid snippet. Audit-as-decomposition: the read-only hunt (`.10.5.1`)
  produced per-file fix sub-leaves `.10.5.2…` and **subsumes** the `.10.4` §5.5 Pair fix.
  **SCOPE DECISION (user, 2026-06-17): FULL BOOK-WIDE SCORCH** — rewrite *every* worked example
  (including the isolated DSL helper-illustration fragments) to the verified 2-rule idiom, and correct
  all wrong outputs. See the scope Decision below.
  Children: `.10.5.1` (done — audit + decomposition), `.10.5.2`–`.10.5.4` (done per-file fixes),
  `.10.5.4.1` (done — reactivation metadata), `.10.5.5`–`.10.5.19` (per-file fixes + finalize)

- ID: `SPEC-LANG-REFERENCE.10.5.1`
  Status: `done`
  Goal: Exhaustive read-only audit of every `.spec` snippet in `docs/linkedspec-book/src/**` +
  decomposition into per-file fix sub-leaves
  Acceptance: every `.spec` block classified (A: regex-on-`::` / single-rule doctrine violation; B:
  output drift; C: `::AND -> Rule[N]` broken shape; D: other; CLEAN) with file:line + claimed-vs-actual;
  fix sub-leaves `.10.5.2…` added to the frontier; no book change (audit only).
  Verification: Done — 2026-06-17. Fanned out **8 read-only `Explore` agents** over chapter groups
  (enumerate every `.spec` block → classify → run claimed-output snippets), then **personally
  ground-truthed every load-bearing finding** through a private `LinkedSpec::Get` driver (an audit
  agent had clobbered the shared scratch driver mid-run, so all agent ACTUAL_OUTPUT values were
  treated as hypotheses — cf. the `.10.6` transcription lesson). Established engine facts: `::` and
  `:` are **interchangeable on a non-first rule** (T1==T2==`[0]`); only the **first** rule is the
  top/entry (multiple `::` rules don't collide, T4); the `::`-no-regex rule is therefore an
  **authoring doctrine**, not a hard engine constraint (matches `.10.6`). Findings synthesized into
  "Audit Findings (`.10.5.1`)" below. Headline: the `Rule::AND /regex/ -> Rule[N] {return}` idiom is
  **pervasive (~105 `::`-mode rule headers across ~20 files)** and is doctrine-divergent twice over
  (regex on a `::` rule; the `::AND -> Rule[N]` shape returns `[]`). Two preliminary-hunt hypotheses
  were **overturned on re-verification**: the `ebnf-spec-walkthrough.md` "richer example" **does
  compile/parse** (matches its claimed output — CLEAN), and the §5.5 forms **run and return values**.
  User chose **full book-wide scorch** (AskUserQuestion, 2026-06-17). No book/Perl change. `mdbook`
  not rebuilt (no content change).
  Commit: `SPEC-LANG-REFERENCE.10.5.1` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.2`
  Status: `done`
  Goal: Fix `overview/what-is-linkedspec.md` minimal key/value example (`Top::AND+ /…/ -> Top[0]`,
  single-rule regex-on-top → compile-fail/`null`) → verified 2-rule idiom
  Acceptance: replaced with a top `::` entry rule (no regex) + normal `:` rule carrying the regex;
  re-verified through `LinkedSpec::Get` (e.g. `[{"key":"foo","val":"bar"},…]`); `mdbook build` exit 0.
  Verification: Done — 2026-06-17. Replaced the single-rule `Top::AND+ /(\w+)=(\w+)/ -> Top[0] {…}`
  block (regex on the top rule + `::AND -> Top[0]` self-edge → handler compile failure → `null`) with
  the verified 2-rule idiom: `top:: -> pair .push` / `LX { return(array_copy(a(top))) }` + a normal
  `pair:` rule carrying `/(\w+)=(\w+)/` in an `I { return(hash("key", entry_group(0), "val",
  entry_group(1))) }` block. **Extracted the exact block from the book file and ran it through
  `LinkedSpec::Get`**: input `foo=bar baz=qux` → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`
  (single `answer=42` → `[{"key":"answer","val":"42"}]`). Prose rewritten to teach the entry-rule
  (no regex) + normal-rule (regex) structure + the actual output, with cross-links to `regex-in-spec.md`
  and `spec-files-and-rule-paragraphs.md`. **Idiom note (verified):** the bare action-block form
  `pair: /re/ { return(...) }` (no `I`) returns `[0,0]` — the `I { … }` lifecycle block is required.
  `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.2` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.3`
  Status: `done`
  Goal: Fix `public-api/get-and-get-parser.md` "minimal example" (`Top::AND /foo/ -> Top[0]` → `[]`)
  → verified 2-rule idiom
  Acceptance: 2-rule form, re-verified output; `mdbook build` exit 0.
  Verification: Done — 2026-06-17. Replaced the inline `Get(...)` heredoc spec (`Top::AND /foo/ ->
  Top[0] { return(hash("kind","top","text",match_text())) }` → `[]`) with `top:: -> word .push` /
  `LX { return(array_copy(a(top))) }` + `word: /foo/ I { return(hash("kind","top","text",
  entry_text())) }`, added a `# $ast is [ { kind => "top", text => "foo" } ]` comment + a sentence
  teaching the two-rule shape. **Extracted from the book file + ran `LinkedSpec::Get`**: `foo` →
  `[{"kind":"top","text":"foo"}]`. **Caught a `match_text()`→`entry_text()` trap** (same family as
  `.10.3`): `match_text()` in the freshly-dispatched child returns `null` (`[{"kind":"top","text":
  null}]`); `entry_text()` (the entering match) returns `"foo"`. Only the one inline `.spec` heredoc
  on the page (the `get_parser` example uses a named spec, not inline `.spec`). `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.3` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.4`
  Status: `done`
  Goal: Fix `user-model/worked-spec-walkthrough.md` — convert the chapter's central single-rule
  `Pair::AND /…/ -> Pair[0]` example (→ `[]`, claims a `{kind:pair,…}` hash) to the 2-rule idiom and
  **re-derive every claimed input→output across the whole chapter**
  Acceptance: central example + all downstream claimed outputs re-verified through `LinkedSpec::Get`;
  `mdbook build` exit 0.
  Verification: Done — 2026-06-18. Rewrote the chapter to the verified 2-rule idiom: a `Top::` entry
  rule (no regex; `-> Pair .push` dispatch loop + `LX { return(array_copy(a(Top))) }`) plus a `Pair:`
  matcher rule carrying the regex in an `I { return(hash("kind","pair","name",entry_group(0),"value",
  trim(entry_group(1)))) }` block. **Every claimed output re-derived through `LinkedSpec::Get`** via a
  mode-aware driver (`/tmp/lsq_me/runpm.pl`, scalar-ref input, `JSON::PP->canonical`, sanity-checked vs
  the frozen `["hello-world"]` idiom): `answer = 42` (default/consume) → `[{"kind":"pair","name":
  "answer","value":"42"}]`; `junk answer = 42` consume → `[]`; same input seek → the pair; multi
  `a = 1, b = 2` → two-element list. The chapter's old single-hash output claim is corrected to a
  one-element **list** (the entry rule's accumulator snapshot). **Descriptor/ctx re-derived:**
  `ref eq HASH`, `meta.parse_mode eq 'consume'`, `exists spec{Pair}` all still hold; **`ctx{top_rule}`
  corrected `Pair`→`Top`** (the top rule is now the entry rule). `match_group`→`entry_group` throughout
  (the dispatched matcher's local match is unset; documented + cross-linked to the entry-vs-match
  divergence). Three traps caught: `:AND` mode on the matcher with a separated `I` block collapses the
  push to `[0]` (use a bare `:` matcher with regex+`I {` on one line); OR-with-`I`-block over alternative
  capture groups is fragile (`[null]`/`[]`) → the OR growth sketch is shown structurally, no output claim.
  **declare()/assign() removed** from the advanced "Evolving the spec" sketch per user direction
  (2026-06-18) — the `call(...)` dataflow teaching is preserved without them; they remain live in the
  reference engine and elsewhere in the book until `SPEC-FORMAT-TERSE` lands the terse forms.
  `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0. No Perl change.
  Commit: `SPEC-LANG-REFERENCE.10.5.4` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.4.1`
  Status: `done`
  Goal: Reactivate the paused whole-book scorch at the user's 2026-07-08 directive, without bundling
  the next book-content fix.
  Acceptance: central task-tree index, this task file, memory pointer, live status, changelog, and
  development notes all agree that the scorch is active again and `.10.5.5` is the next resumable leaf;
  no mdBook content or parser/runtime behavior changes in this metadata-only slice.
  Verification: Done — 2026-07-08. Updated durable coordination records to resolve the 2026-06-18
  pause and point the active frontier at `.10.5.5` (`user-model/spec-files-and-rule-paragraphs.md`).
  No book source, parser/runtime code, corpus, or Knowledge Map fact changed.
  Commit: `SPEC-LANG-REFERENCE.10.5.4.1` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.5`
  Status: `done`
  Goal: Fix `user-model/spec-files-and-rule-paragraphs.md` — the malformed label-in-block example
  (`Top::AND … label:` → DSL compile error) + the `Top::AND` regex-on-top sketches
  Acceptance: valid forms, re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced the page's runnable `Top::AND` minimal, label-in-block,
  same-line, and multiline examples with the verified 2-rule idiom (`Top:: -> Word .push` /
  `LX { return(copy(array(Top))) }` plus normal `Word:`/`Item:` matcher rules). Replaced the malformed
  bare `label:` block with a valid quoted `"label:"` helper value, and documented that a bare label-like
  line inside an open `{ ... }` block fails validation with `Rule definition not allowed inside open
  block`. The four replacement snippets were compile/run-verified through `LinkedSpec::Get`; the
  mdBook build exits 0 (`mdbook build docs/linkedspec-book`).
  Commit: `SPEC-LANG-REFERENCE.10.5.5` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.6`
  Status: `done`
  Goal: Fix `user-model/rule-modes-and-parse-modes.md` — convert all ~20 mode fragments off
  regex-on-`::` (use single-colon `:` normal rules for regex-carrying rules), reframe the "the same
  mode suffixes can appear after either colon form / both valid shapes" teaching to the doctrine
  (`::` = the single no-regex entry rule; `:` carries the regex), and fix the `Top:: /foo/` seek/
  consume examples
  Acceptance: no example puts a regex on a `::` rule; framing corrected; representative examples
  re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Reframed the rule-label surface so runnable examples use
  no-regex `Top::` entry/dispatcher rules and single-colon regex-carrying rules. Converted the
  regex-owning mode fragments (`Pair:&`, `Pair:AND`, `NameRun:+`, `TokenStream:OR`, bounded
  `OR{...}` and `AND{...}` families, and the mixed-edge `BadRule:` negative example) off `::`.
  Replaced the `Top:: /foo/` seek/consume snippets with the verified 2-rule wrapper (`Top:: -> Word
  .push` / `LX { return(copy(array(Top))) }` + `Word: /foo/ I.return(entry_text())`). Runtime probes:
  token stream `foo "bar"` → `["foo","bar"]`; `seek` over `junk foo` → `["foo"]`; `consume` over
  `junk foo` → `[]`; `consume` over `foo` → `["foo"]`. `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.6` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.7`
  Status: `done`
  Goal: Fix `user-model/regex-in-spec.md` — convert the `::`-with-regex fragments (`Top::`, `Pair::AND`,
  `Subdef::AND`, `Unit::AND`) to valid form while preserving the capture-group / compaction teaching
  Acceptance: doctrine-valid examples, re-verified; capture-indexing facts intact; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced the minimal `Top:: /foo/` example with a no-regex `Top::`
  wrapper dispatching to `Keyword:`. Reworked numbered, named, and compaction examples so regex-bearing
  rules use single-colon labels (`Pair:`, `Subdef:`, `Unit:`) and dispatched child rules read captures
  with `entry_group` / `entry_named`. Preserved the capture-indexing contract: 0-based captures-only
  groups, compacted non-participating numbered groups, and stable named-group reads. Runtime probes:
  `foo` → `["foo"]`; `foo=bar` → `[{"key":"foo","val":"bar"}]`; `alpha` →
  `[{"name":"alpha"}]`; numbered compaction `abc` → `[{"amount":"abc","name":null}]`, `12abc` →
  `[{"amount":"12","name":"abc"}]`; named groups `abc` →
  `[{"amount":null,"name":"abc"}]`, `12abc` → `[{"amount":"12","name":"abc"}]`.
  `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.7` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.8`
  Status: `done`
  Goal: Audit + fix `user-model/blind-calls-and-parser-orchestration.md` (blind-call `::` rules carry
  no regex — likely mostly clean; fix any regex-on-`::` and the `BadRule::` negative example framing)
  Acceptance: any regex-on-`::` removed; negative examples clearly marked; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Focused scan found the blind-call wrapper examples clean, but four
  regex-owning action-edge examples still used `::`: `Parent::AND`, `BadRule::AND`, `HeaderRule::AND`,
  and `Field::AND`. Converted them to single-colon labels while leaving no-regex blind-call wrappers
  (`Document::AND`, `Atom::|`, `LineStream::OR`, bounded blind-call streams, `Record::AND`, etc.)
  unchanged. Added a negative-example note that `BadRule:AND` uses single colon because it owns a regex
  slot; the illustrated error is mixing `->` and `=>`. Reverified the mixed-edge case with a valid
  `Top::` wrapper: validation reports `Cannot mix ACTION (->) and BLIND CALL (=>) code blocks`.
  The page scan reports no `::` header followed by a regex slot, and `mdbook build docs/linkedspec-book`
  exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.8` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.9`
  Status: `done`
  Goal: Fix `dsl/action-and-lifecycle-placement.md` worked examples (`Token::AND`, `List::AND`,
  `Name::AND`, `Delimited::AND`, `Block::AND`, `Tuple::AND`, `Pair::AND`, `MaybeName::OR`, `Items:*`,
  …) → 2-rule idiom (regex on `:` rules), preserving the grouped-target + lifecycle-placement teaching
  Acceptance: no regex on `::`; representative examples re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Converted regex-owning examples to normal `:` labels and tightened
  the chapter's entry-vs-local-slot model: dispatched entry-match transforms use `I { ... }` with
  `entry_text()` / `entry_group(...)`, while indexed local-slot actions use `match_text()` /
  `match_group(...)`. Replaced invalid bare child-rule lines in the Pair sketch with verified local-slot
  regex/action flow, corrected aggregate hash initialization (`set(hash(meta), { ... })` where examples later
  read `hash(meta)`), and changed the lifecycle statement-block example to explicit `return(...)`. Focused
  probes: `Name` later slots → `[{"entry":"name","kind":"name","separator":"=","value":"Alpha"}]`;
  `Token` entry `I` → `[{"kind":"token","text":"alpha"}]`; explicit lifecycle return →
  `[{"ignored":"not_a_return","out":"from_i"}]`; Pair slot flow → `{"kind":"pair","lhs":"answer","rhs":"42"}`.
  The page scan reports no `::` header followed by a regex slot; `mdbook build docs/linkedspec-book` and
  Knowledge Map check pass. A Perl handler-shape drift found during verification is tracked in Knowledge fact
  `perl-lifecycle-final-value-e-drift` and follow-up leaf `.10.5.20`.
  Commit: `SPEC-LANG-REFERENCE.10.5.9` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.10`
  Status: `done`
  Goal: Fix `dsl/capture-marks-and-source-locations.md` worked examples (`Top::AND`, `Call::AND`/
  `Inner::AND` divergence) → 2-rule idiom, preserving the entry-vs-match teaching
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced the `Top::AND` capture example with a no-regex `Top::`
  wrapper and normal `Body:` delimiter rule: `Top:: -> Body .push` / `LX { return(copy(array(Top))) }`
  plus `Body: /BEGIN/ /END/ -> Body[1] { return(hash("body", trim(capture_slice()))) }`. Runtime
  probe with `parse_mode=>"seek"` returns `[{"body":"body"}]` for `BEGIN body END`; the same minimal
  delimiter shape returns `[null]` under `consume`, so the seek-vs-consume caveat is recorded in
  Knowledge fact `perl-capture-slice-delimiter-seek-boundary`. Replaced the `Call::AND`/`Inner::AND`
  divergence sketch with a no-regex blind-call wrapper (`Top::AND => Call`) and normal regex-owning
  `Call:`/`Inner:` rules. Runtime probe over `greet(world)` returns
  `[{"outer":"greet","outer_name":"greet","inner":"world","inner_name":"world"}]`, preserving the
  entry-vs-match teaching without regex slots under `::`. The page scan reports no `::` header followed
  by a regex slot; `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.10` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.11`
  Status: `done`
  Goal: Fix `dsl/declaration-helper-reference.md` worked examples (`Token::AND`, `List::AND`) → 2-rule idiom
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced the `List::AND` accumulator example with a no-regex
  `List::` stream wrapper that owns `set(array(items), [])`, `retv`, and the final `LX` return, plus a
  normal `Item:` matcher (`/\s*[A-Za-z_]+/`) that returns one item record through `entry_text()`. Runtime
  probe over `alpha beta` returns `{"kind":"list","items":[{"text":"alpha"},{"text":"beta"}],"item_count":2}`.
  Replaced the regex-owning `Token::AND` metadata example with a no-regex `Top::` wrapper and normal
  `Token:` matcher; runtime probe over `Alpha` returns
  `[{"kind":"token","source":"Token","text":"alpha","text_length":5}]`. The page scan reports no `::`
  header followed by a regex slot; `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.11` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.12`
  Status: `done`
  Goal: Fix `dsl/source-boundary-helper-reference.md` worked examples (`Tuple::AND`, `Block::AND`,
  `Paren::AND`, `Pair::AND`, `Body::AND`, `AtEnd::AND`, `Top::AND`/`Child::AND`) → 2-rule idiom
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced every regex-owning `::AND` example with a no-regex
  `Top::AND => <Rule>` blind-call wrapper and a normal regex-owning `<Rule>:AND` (or `Call:`/`Child:`)
  rule. Added a short seek-mode note for delimiter-body examples, matching the caveat recorded in
  `perl-capture-slice-delimiter-seek-boundary`. Reduced the old three-segment Tuple/Body sketches to
  verified two-segment forms that still exercise `capture_take()`, `capture_slice()`,
  `mark_capture_slice(...)`, and `start_capture_slice_from(...)`. Focused probes:
  Tuple → `[["?Tuple:",["alpha","beta"]]]`; Block → `[{"body":"abc","body_start_col":2,"body_start_line":1}]`;
  Paren → `[{"body":"abc","col":2,"line":1}]`; Pair → `[{"left":"left","right":"right"}]`;
  Body bridge → `[{"first":"alpha","second":"beta","whole_body":"alpha,beta"}]`;
  AtEnd → `[{"cursor_pos":7,"prefix":"abc END","remaining":"","source_end_col":8,"source_end_line":1,"source_len":7}]`;
  entry-vs-match → `[{"entry_group_count":1,"entry_prefix":"foo","entry_text":"foo","local_group_count":1,"local_name":"bar","local_text":"bar"}]`.
  The page scan reports no `::` header followed by a regex slot; `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.12` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.13`
  Status: `done`
  Goal: Fix `dsl/value-container-flow-helper-reference.md` worked examples (`Token::AND`, `Node::AND`,
  `Sequence::AND`, `Kind::AND`, `FieldList::AND`, `logging_annotation:` already `:`) → 2-rule idiom
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced regex-owning `Token::AND`, `FieldList::AND`, and
  `Kind::AND` examples with no-regex `Top::` wrappers plus normal regex-owning `Token:`,
  `FieldList:`, and `Kind:` rules. Reworked the `Node::AND` and `Sequence::AND` examples as
  no-regex entry rules that dispatch to explicit `Child:` / `Item:` matchers, preserving the hash
  normalization and head/tail array teaching without relying on regex slots under `::` headers.
  Focused probes: Token → `[{"kind":"token","text":"alpha","text_length":5}]`;
  FieldList → `[{"field_count":2,"fields":["name","kind"],"first_field":"name","kind":"field_list"}]`;
  Kind → `[{"kind":"node","raw":"node"}]`;
  Node → `{"kind":"word","name":"Alpha","normalized_name":"alpha"}`;
  Sequence → `{"head":{"text":"alpha"},"item_count":2,"kind":"sequence","rest":[{"text":"beta"}]}`.
  The page scan reports no `::` header followed by a regex slot; `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.13` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.14`
  Status: `done`
  Goal: Fix the remaining DSL pages — `dsl/values-containers-and-flow-helpers.md` (`Token::`),
  `dsl/action-model-and-helper-surface.md` (`Top::`), `dsl/fluent-and-block-forms.md` (`Items::AND+`,
  `Toplevel:AND+`), and audit `dsl/actionir-lowering-mental-model.md` (helper-statement fragments)
  Acceptance: no regex on `::`; complete worked examples re-verified; isolated helper-statement
  fragments confirmed valid or wrapped; `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced the `Token::` practical pattern in
  `dsl/values-containers-and-flow-helpers.md` and the `Top:: /name=.../` tiny example in
  `dsl/action-model-and-helper-surface.md` with no-regex `Top::` wrappers plus normal
  regex-owning `Token:` / `Value:` rules. In `dsl/fluent-and-block-forms.md`, reduced the
  `Toplevel:AND+` lifecycle sketch to the lifecycle block fragment it was demonstrating, and
  rewrote the `Items::AND+` all-forms example as a no-regex `Items::` entry rule plus normal
  `Item:` matcher. Audited `dsl/actionir-lowering-mental-model.md`: the in-scope blocks are
  helper-statement or lowering-pipeline fragments, not runnable regex-owning spec examples, so
  no content change was needed. Focused probes: Token → `[{"col":1,"kind":"token","line":1,"text":"Alpha"}]`;
  Value → `[{"kind":"assignment","name":"alpha"}]`;
  Items `alpha` → `{"item":{"text":"alpha"},"kind":"singleton"}`;
  Items `alpha beta` → `{"first":{"text":"alpha"},"kind":"pair","second":{"text":"beta"}}`;
  Items `alpha beta gamma` → `{"count":3,"items":[{"text":"alpha"},{"text":"beta"},{"text":"gamma"}],"kind":"list"}`.
  The four-page scan reports no `::` header followed by a regex slot; `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.14` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.15`
  Status: `done`
  Goal: Fix `appendix/formal-grammar.md` — §1 paragraph-model example (`Top:: /a/ -> Next` + `Next:: /b/`)
  and §12 "complete example" (`DemoParser:: … /pattern1/ …` + undefined targets `A`/`B`) → valid forms
  Acceptance: doctrine-valid + compile/run-verified (or clearly-marked grammar meta-notation);
  `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Replaced the §1 paragraph-model example with a no-regex
  `Top::` entry rule that dispatches to normal regex-owning `Next:` and returns the paragraph
  result from `LX`. Reworked the §12 complete example so `DemoParser::` is a no-regex top rule,
  `Child:` owns the `hello` regex, `SecondChild:OR+` owns its repeated word regex/action, and
  `ThirdChild:AND` dispatches to defined `First:` and `Second:` matcher rules instead of
  undefined `A`/`B` targets. Focused probes: paragraph example `a` →
  `["?Top:",[["?Next:","a"]]]`; `DemoParser` on `hello Alice hello Bob` →
  `["?result:",["Alice","Bob"]]`; `SecondChild` on `one two` → `["one","two"]`;
  `ThirdChild` on `first second` → `["?third:",["first","second"]]`. The appendix scan reports
  no `::` header followed by a regex slot; `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.15` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.16`
  Status: `done`
  Goal: Fix `appendix/runtime-semantics.md` §5.5/§5.6 examples (the three `Top::`/`Pair::` regex-on-top
  forms incl. the **`.10.4` §5.5 Pair target**, and the §5.6 single `object:`/`manifest:` fragments)
  → 2-rule idiom; re-derive outputs. **Closes/subsumes `.10.4`.**
  Acceptance: doctrine-valid + re-verified outputs; `.10.4` marked superseded-by-`.10.5.16`;
  `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Rewrote all §5.5 parser-output examples to no-regex
  `Top::` wrappers dispatching to normal regex-owning `Done:` / `Pair:` rules, preserving the
  documented scalar, array, and tagged-pair output shapes. Replaced the §5.6 `object:` and
  `manifest:` single-rule fragments with complete no-regex `Top::` wrappers plus normal
  regex-owning body rules. The `.10.4` Pair target is closed here: the Pair example now reads
  `entry_group(0/1)` in the dispatched `Pair:` rule and returns that value through `Top`.
  Focused probes: scalar → `"scalar-ok"`; proof array → `["?proof:","ok"]`;
  pair → `["?pair:","key","val"]`; object → `["?object:","foo"]`;
  manifest → `["?manifest:"]`. The page scan reports no `::` header followed by a regex slot;
  `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.16` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.17`
  Status: `done`
  Goal: Fix `specs-and-corpora/tablegrep-spec-walkthrough.md` output drifts — `sens` is `=` not `=~`
  (regex captures only `([!=])`); the GROUP example output (`{"group":["internal"]}`) is misquoted
  Acceptance: claimed outputs corrected to verified `LinkedSpec::Get` runs of `specs/tablegrep.spec`;
  `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Re-ran the Perl reference parser through
  `LinkedSpec::get_parser('tablegrep')` and replaced the two output examples with JSON renderings
  of the actual ASTs. `field1 =~ /foo/` returns
  `[{"field":"field1","re":"foo","sens":"=","type":"TERM"}]`; grouped input
  `(field1 =~ /foo/ || field2 =~ /bar/)` returns
  `[{"group":[{"field":"field1","re":"foo","sens":"=","type":"TERM"},{"type":"OR_OP"},{"field":"field2","re":"bar","sens":"=","type":"TERM"}],"type":"GROUP"}]`.
  Also corrected the same page's stale descriptor helper list after checking the live spec and
  descriptor metadata: five rules ready, zero blocked, zero compatibility, zero raw, zero unresolved.
  `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.17` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.18`
  Status: `done`
  Goal: Fix `specs-and-corpora/portmap-spec-walkthrough.md` — the 5 output-shape examples claim flat
  `['?bare:','clk',undef,undef,undef]` etc.; actual is nested `["?bare:",["clk"]]` / `["?slice:",["addr","7","0"]]`
  Acceptance: every claimed output corrected to verified `specs/portmap.spec` runs (and any wrong
  input like `4'b1011` corrected); `mdbook build` exit 0.
  Verification: Done — 2026-07-08. Re-ran the Perl reference parser through
  `LinkedSpec::get_parser('portmap')` for all five documented output-shape examples. The current
  walkthrough already matches the live nested JSON shapes: `clk` ->
  `["?bare:",["clk"]]`, `bar[3]` -> `["?bit:",["bar","3"]]`,
  `addr[7:0]` -> `["?slice:",["addr","7","0"]]`, `0x1f` ->
  `["?constant:",["0x1f"]]`, and `{sig_a sig_b[7:0] 0x1f}` ->
  `["?concat:",[["?bare:",["sig_a"]],["?slice:",["sig_b","7","0"]],["?constant:",["0x1f"]]]]`.
  `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.18` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.19`
  Status: `done`
  Goal: Finalize the scorch — whole-book re-grep confirming **zero** regex-on-`::` example rules
  remain, every claimed I/O re-verified, `mdbook build` exit 0; close the planned `.10.5.2`–`.10.5.18`
  book-page sweep
  Acceptance: clean whole-book sweep; planned page-fix children `done`/`superseded`; any follow-up drift
  leaf remains separately tracked if it is not part of the page-scorch closeout.
  Verification: Done — 2026-07-08. Whole-book `rg` scans for same-line and immediately-following-line
  regex slots under `::` rule headers now return no matches across `docs/linkedspec-book/src`. The closeout
  sweep found and fixed three residual mdBook examples: the recursive `sexpr` example in
  `spec-files-and-rule-paragraphs.md`, the direct value-path and array-end-mutation examples in
  `helper-contract-catalog.md`, and the function-registry proof snippet in `compiler/pipeline-overview.md`.
  Focused `LinkedSpec::Get` probes verify the corrected outputs: `(a(b)c)` -> `[["a",["b"],"c"]]`,
  `(a) (b)` -> `[["a"],["b"]]`, direct value-path assignment -> `"updated"`, array end mutations ->
  `["a"]`, and the function proof -> `["x","ab",2,"v"]`. `mdbook build docs/linkedspec-book` exits 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.19` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.5.20`
  Status: `done`
  Goal: Resolve the lifecycle handler-shape drift found during `.10.5.9`: current Perl generated handlers
  can expose an `I` block's final host statement value when explicit `return(...)` is omitted, and a direct
  default-rule `I` + regex + `E` shape can omit the regex/E path in generated source, while existing Rust
  tests model the intended statement-block contract.
  Acceptance: decide whether this remains a documented Perl-reference caveat or becomes a backend/runtime
  fix task; update mdBook/KM/tests/task-tree records accordingly; keep the Perl reference untouched unless
  a separately-owned implementation leaf explicitly authorizes code changes.
  Verification: Done — 2026-07-08. Focused Perl probes reverified the caveat: the direct
  `Top:: I { set(out,...); set(ignored,"not_a_return") } /x/ E { return(hash(...)) }`
  shape returns `"not_a_return"`, a dispatched child without explicit `return(...)` returns
  `["not_a_return"]`, and `dump_parser_source` for the direct shape contains the `I` block's
  `not_a_return` statement while omitting the `hash("out",...)` `E` path. ADR `0020` records
  the policy: document this as a current Perl-reference caveat for language-reference closeout;
  any behavior normalization needs a separately-owned implementation/parity leaf. `runtime-semantics.md`
  now teaches explicit `return(...)` as the portable return channel, and KM fact
  `perl-lifecycle-final-value-e-drift` points to ADR `0020`. `mdbook build`, memory/task/doctrine,
  whitespace, and Knowledge Map checks pass.
  Commit: `SPEC-LANG-REFERENCE.10.5.20` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.10.6`
  Status: `done`
  Goal: Correct the durable record — retract the inaccurate "a regex-on-top / single-rule spec
  silently returns `[]`" sub-claim of the `.10` CORRECTION, and reframe the remediation rationale as
  the **authoring doctrine** (top `::` entry rule with no regex + ≥1 normal `:` rule), not an `[]` bug
  Acceptance: rewrite the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first (verified
  2-rule idiom; brief retraction; the only broken shape to avoid in examples is `::AND … -> Rule[N]`);
  add a superseding Decision here; correct the framing in CHANGES/DEVELOPMENT_NOTES/LIVE/MEMORY. No
  book-example change (the `.10.3` catalog already follows the doctrine). KM gate regenerates.
  Verification: Done — 2026-06-17. Ground-truth via `LinkedSpec::Get` established that the OR
  self-ref / cross-rule action-edge forms (the old `.5.2`/`.9` shape AND the §5.5 frozen oracle
  fixtures) **run and return their value** (`Greeting:: /…/ -> Greeting {return(concat(...))}` →
  `"hello-world"`; `Sum:: …` → `5`; `Pair:: …` → `["?pair:","key","val"]`), so the prior
  "regex-on-top → `[]`" premise was factually wrong; the ONLY shape returning `[]` is the explicit
  `::AND … -> Rule[N] { return(...) }` form (AND mode + slot index — the `.10.1` AND_SINGLE_ACODE
  finding, real but narrow). Rewrote the KM card doctrine-first with that retraction. **The 2-rule
  doctrine and `.10.3` stand** — they match all 20 shipped specs and [[feedback_spec-structure-top-plus-normal]];
  only the *rationale wording* changed (the examples violated the 2-rule authoring doctrine, they
  were not returning `[]`). self-check + KM gate pass (KM regenerates `KNOWLEDGE_MAP.md`). No Perl,
  no book-example change.
  Commit: `SPEC-LANG-REFERENCE.10.6` (see Commit Log)

- ID: `SPEC-LANG-REFERENCE.8`
  Status: `pending`
  Goal: Finalize — whole-book consistency + close
  Acceptance: full `mdbook build` exit 0; a cross-chapter consistency pass confirming every
  `.spec` construct from the `.1` inventory is documented with at least one example and no
  variant leakage; every example verified valid against the grammar; tree closed when all
  children are `done`/`deferred`.
  Verification: `pending`
  Commit: `pending`

## Audit Findings (`.1`, 2026-06-17)

Synthesis of two read-only audits (full surface inventory ∥ book coverage map). This is the
durable anti-archaeology artifact: it records the authoritative source for each surface area
and the book's coverage verdict, so a future session does not re-run the audit.

**Authoritative sources for the full `.spec` surface** (the completeness yardstick):
- Rule labels (`:` body / `::` top) + paragraph model: `perl/LinkedSpec/BootstrapSpec/Core.pm`
  (~410-491), `perl/LinkedSpec/Validation.pm` (`_parse_rule_label_line`, `_scan_rule_edges_in_fragment`).
- Rule modes (mode-alias map `&`→AND, `|`→OR, `+`/`*`/`?`; explicit `AND`/`OR`/`AND+`/`OR+`;
  bounded `:AND{N,M}`/`:OR{N,M}`): `Core.pm:345-408`, `Validation.pm:47-82`, `specs/spec.spec:39-43`.
- Regex literals/clusters: `Core.pm:516-527`, `specs/spec.spec:102-104`. Comments `#` /
  blank lines: `Core.pm:624-631`, `Validation.pm:163`.
- Edges (action `->` / blind `=>`, `[N]` indexing, grouped `A | B`, fluent continuations):
  `Core.pm:529-739`. Method-chain parsing: `Core.pm:42-127`.
- Lifecycle markers `I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`: `RuleIR/EmitContext.pm:550-557`,
  `specs/spec.spec:29-30`. (All 7 supported/equivalent per the completed `LIFECYCLE-FAMILY-AUDIT`
  — the surface agent's "E/IT deprecated" note is **wrong** and was not propagated.)
- Capture/mark/source-location surface (`@capture_slice`, `@mark(name)`, the anonymous +
  named capture-slice families, `mark_*`, `capture_*_from`/`_between`, `input_*`/`entry_*`/
  `match_*`/`cursor_*` readers): `Core.pm:686-699`, `perl/LinkedSpec/ActionIR/Contracts.pm`.
- Full helper-contract catalog (**158** contracts, `grep -cE "\bid\b => '" Contracts.pm`):
  `ActionIR/Contracts.pm`. Output/return shape: `docs/knowledge/rust-perl-output-oracle.md`
  + `appendix/runtime-semantics.md` §5.

**Coverage verdict (book) — 8/10 WELL-COVERED, 2 binding gaps + minor clarity gaps:**
- WELL-COVERED: rule labels, rule modes, parse modes (seek/consume), edges, lifecycle markers,
  capture/marks, helper catalog (structurally), control flow — all with examples + formal contracts.
- **GAP A (CRITICAL) → `.2`**: regex is defined only at the syntax level in
  `appendix/formal-grammar.md:111-127`; no mental model, no examples, and no statement of the
  regex feature set a backend must support (flags? named groups? capture↔`entry_group(N)`).
- **GAP B (CRITICAL) → `.3`**: the output/return-shape contract is undocumented — backends
  reverse-engineer the AST shape from `tests/corpus/`. (Authoritative material exists in the
  oracle KM card; just not surfaced in the book.)
- GAP C (MAJOR) → `.4`: grouped shared-code targets `-> A | B { ... }` defined in the formal
  grammar (`:131-141`) but no worked example.
- GAP D (MEDIUM) → `.4`: entry-vs-local-match is explained but lacks a divergence example.
- GAP E → `.5`: helper-catalog example density is uneven + some Perl-implementation notes are
  mixed into the backend-neutral contract (variant-leak to separate).
- GAP F (MINOR) → `.6`: no single worked example exercising the capture/mark families together.

**KM-card candidates → `.7`** (durable subjects worth retrieval): output/return-shape contract;
regex feature-set a backend must support; rule-mode→semantics map; lifecycle execution order +
`retv`; action-vs-blind edge/dispatch model; capture/mark family taxonomy.

## Audit Findings (`.10.5.1`, 2026-06-17) — whole-book `.spec`-snippet scorch

Method: 8 read-only `Explore` agents over chapter groups (enumerate → classify A/B/C/D/CLEAN → run
claimed-output snippets), then **every load-bearing finding personally re-verified** through a private
`LinkedSpec::Get` driver (the shared scratch driver was clobbered by an audit agent mid-run, so all
agent ACTUAL_OUTPUT values were treated as hypotheses; cf. the `.10.6` transcription lesson). All
"actual" values below are from my own ground-truth runs unless marked "(agent, re-verify at fix)".

**Engine facts established (so the fix leaves don't re-derive them):**
- `::` and `:` are **interchangeable on a non-first rule** — `child::AND /re/` and `child:AND /re/`
  compile + run identically (both `[0]` in the probe). Only the **first** rule is the top/entry; a
  second `::` rule does not collide. So **`::`-no-regex is an authoring doctrine, not a hard engine
  constraint** (consistent with `.10.6`'s retraction; the engine is permissive).
- The `Rule::AND /regex/ -> Rule[N] { return(...) }` shape (AND mode + slot self-edge) **drops its
  edge return → `[]`** (the `.10.1` `_emit_and_single_acode_handler` finding). This shape is used in
  **dozens** of book worked examples → those examples don't surface their `return(...)` value.

**Scale:** `grep` finds **~105 `Name::<mode>` rule headers** in book code blocks across ~20 files; the
`Rule::AND /regex/ -> Rule[N]` idiom is the book's pervasive worked-example shape.

**Classification key:** A = regex on a `::` rule / single-rule "complete" spec · B = claimed
input→output ≠ actual · C = `::AND -> Rule[N]` `[]` shape · D = other (won't compile / undefined
target) · CLEAN.

| File | Block(s) | Class | Claimed → Actual (verified) | Fix leaf |
| --- | --- | --- | --- | --- |
| `overview/what-is-linkedspec.md` | §"minimal kv parser" `Top::AND+ /…/ -> Top[0]` (single rule) | A+C+D | "returns a hash per match" → **compile error → `null`** | `.10.5.2` |
| `public-api/get-and-get-parser.md` | "minimal example" `Top::AND /foo/ -> Top[0]` | A+B+C | "runnable parser" → **`[]`** | `.10.5.3` |
| `user-model/worked-spec-walkthrough.md` | central `Pair::AND /…/ -> Pair[0]` (single rule, whole chapter) | A+B+C | `{kind:pair,name:answer,value:42}` → **`[]`** | `.10.5.4` |
| `user-model/spec-files-and-rule-paragraphs.md` | label-in-block `Top::AND … label:`; `Top::AND` sketches | A+D | "label belongs to the block" → **DSL compile error** (`Rule definition not allowed inside open block`, reverified 2026-07-08); fixed in `.10.5.5` | `.10.5.5` |
| `user-model/rule-modes-and-parse-modes.md` | ~20 mode fragments `Pair::&`/`::AND`/`::OR`/`Top:: /foo/`…; line 24 "both valid shapes" framing | A | regex on `::` throughout; `Top:: /foo/ -> Top` → **`null`**; fixed in `.10.5.6` | `.10.5.6` |
| `user-model/regex-in-spec.md` | `Top::` (l.38), `Pair::AND` (l.101), `Subdef::AND`, `Unit::AND` fragments | A | regex on `::` (capture-indexing teaching is correct); fixed in `.10.5.7` | `.10.5.7` |
| `user-model/blind-calls-and-parser-orchestration.md` | `Document::AND`/`Atom::|`… (blind-call, no regex); `BadRule::` negative | mostly CLEAN | blind-call `::` rules carry no regex; fixed stray action-edge regex-on-`::` examples in `.10.5.8` | `.10.5.8` |
| `dsl/action-and-lifecycle-placement.md` | `Token::AND`,`List::AND`,`Name::AND`,`Delimited::AND`,`Block::AND`,`Tuple::AND`,`Pair::AND`,`MaybeName::OR`,`Items:*` | A + drift caveat | regex on `::` fixed in `.10.5.9`; entry-vs-local-slot examples tightened; lifecycle final-value / direct-`E` Perl caveat recorded in KM | `.10.5.9` |
| `dsl/capture-marks-and-source-locations.md` | `Top::AND`; `Call::AND`/`Inner::AND` divergence | A | regex on `::` (entry-vs-match teaching correct) | `.10.5.10` |
| `dsl/declaration-helper-reference.md` | `Token::AND`,`List::AND` worked examples | A | regex on `::` | `.10.5.11` |
| `dsl/source-boundary-helper-reference.md` | `Tuple::AND`,`Block::AND`,`Paren::AND`,`Pair::AND`,`Body::AND`,`AtEnd::AND`,`Top::AND`/`Child::AND` | A | regex on `::` | `.10.5.12` |
| `dsl/value-container-flow-helper-reference.md` | `Token::AND`,`Node::AND`,`Sequence::AND`,`Kind::AND`,`FieldList::AND` (`logging_annotation:` is `:` → CLEAN) | A | regex on `::` | `.10.5.13` |
| `dsl/values-containers-and-flow-helpers.md` `+ action-model-and-helper-surface.md` `+ fluent-and-block-forms.md` `+ actionir-lowering-mental-model.md` | `Token::` (l.160); `Top::` (l.35); `Items::AND+`,`Toplevel:AND+`; helper-statement fragments | A | regex on `::`; isolated helper fragments are CLEAN | `.10.5.14` |
| `appendix/formal-grammar.md` | §1 `Top:: /a/ -> Next`; §12 `DemoParser:: … /pattern1/` (+ undefined `A`/`B`) | A+D | regex on `::`; §1 → `["?Top:",[]]` (agent) | `.10.5.15` |
| `appendix/runtime-semantics.md` | §5.5 three `Top::`/`Pair::` regex-on-top; §5.6 `object:`/`manifest:` single fragments | A | regex on `::` (forms run; doctrine-divergent); **folds `.10.4`** | `.10.5.16` |
| `specs-and-corpora/tablegrep-spec-walkthrough.md` | `field1 =~ /foo/` `sens`; GROUP example | B | `sens '=~'` → **`'='`**; group → **`{"group":["internal"]}`** | `.10.5.17` |
| `specs-and-corpora/portmap-spec-walkthrough.md` | 5 output-shape examples | B | flat `['?bare:','clk',undef,…]` → **nested `["?bare:",["clk"]]` / `["?slice:",["addr","7","0"]]`** | `.10.5.18` |

**Closeout residuals (`.10.5.19`, fixed):**

| File | Block(s) | Class | Drift fixed | Fix leaf |
| --- | --- | --- | --- | --- |
| `user-model/spec-files-and-rule-paragraphs.md` | recursive `sexpr:: /\(/ /\)/` example | A | regex on `::` in the recursion example; rewritten as no-regex `top::` wrapper plus normal recursive `sexpr:` rule | `.10.5.19` |
| `appendix/helper-contract-catalog.md` | direct value-path and array-end-mutation worked examples | A+B | `Top:: /x/` / `Done:: /[a-z]+/` examples rewritten to no-regex `Top:: -> Done`; direct value-path output corrected to `"updated"` and semicolon-separated terse statements restored | `.10.5.19` |
| `compiler/pipeline-overview.md` | function-registry runtime proof snippet | A | `Top:: /x/` / `Done:: /x/` proof rewritten to no-regex `Top:: -> Done`; function bodies use the verified `copy(array(...))` / `copy(hash(...))` forms | `.10.5.19` |

**Confirmed CLEAN (no fix needed after `.10.5.19`):** remaining `compiler/*`, `architecture/owner-tree.md`,
`development/*`; `public-api/{trace-api,plugin-registry,descriptor-introspection}.md`;
`appendix/helper-contract-catalog.md` §2/§5 worked examples (the `.10.3` 2-rule idiom, re-spot-checked);
`appendix/backend-handoff.md`; `specs-and-corpora/shipped-specs-and-corpora.md`;
`specs-and-corpora/lispish-spec-walkthrough.md` (faithful shipped-spec quotes + verified outputs);
`specs-and-corpora/pplugin-spec-walkthrough.md` (faithful + verified);
**`specs-and-corpora/ebnf-spec-walkthrough.md`** (the "richer example" **compiles + parses to its
claimed structure** — the preliminary-hunt "does not compile" hypothesis was **wrong**; faithful
shipped-spec quotes elsewhere). Isolated helper-statement / lifecycle / method-chain DSL fragments
(no rule label, no regex-on-`::`, no claimed output) are CLEAN teaching fragments — agent A4's
"Class D: missing rule wrapper" over-flagging is **rejected**; they will be confirmed valid (and
wrapped only where a complete worked example is intended) during the per-file fixes.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `SPEC-LANG-REFERENCE.1` | `done` | Audit complete (2026-06-17) — surface inventory + book coverage map synthesized above; decomposed into `.2`–`.8` |
| — | `SPEC-LANG-REFERENCE.2` | `done` | regex-first-class chapter landed (2026-06-17), verified against `LinkedRE.pm`/`Contracts.pm`/rgx; fixed a capture-indexing contradiction across 3 book files |
| — | `SPEC-LANG-REFERENCE.3` | `done` | output/return-shape contract landed in `runtime-semantics.md §5` (2026-06-17), verified vs oracle corpus + live Perl run; tagged shape framed as an OPTIONAL convention per user feedback |
| — | `SPEC-LANG-REFERENCE.4` | `done` | grouped-target example (edges chapter) + entry-vs-match divergence example (capture chapter), both compile-verified (2026-06-17) |
| — | `SPEC-LANG-REFERENCE.5.1` | `done` | helper-catalog audit (2026-06-17): 0 public-API completeness gaps; 2 variant-neutrality sigil leaks fixed; example-density gap decomposed into `.5.2`–`.5.5` |
| — | `SPEC-LANG-REFERENCE.5.2` | `done` | worked examples for all 17 Scalar + 18 Numeric helpers (2026-06-17), each compile-AND-run verified through `LinkedSpec::Get`; 2 do-not-guess traps caught; §5.5 drift defect found → `.9` |
| — | `SPEC-LANG-REFERENCE.9` | `done` | §5.5 Pair example corrected to the verified OR self-ref form (2026-06-17); surfaced a SYSTEMIC AND-`[0]`-self-edge output-drift across several chapters → `.10` |
| — | `SPEC-LANG-REFERENCE.10.1` | `done` | investigation (2026-06-17); **verdict SUPERSEDED** — no engine bug; the `[]` was invalid spec structure (regex on top rule). Bad KM card deleted + replaced |
| — | `SPEC-LANG-REFERENCE.10.2` | `superseded` | engine-fix-vs-doc fork is moot (no engine bug; reference untouched) |
| — | `SPEC-LANG-REFERENCE.10.3` | `done` | `.5.2` Scalar+Numeric examples + both catalog preambles redone with the verified 2-rule idiom (2026-06-17); all 33 re-verified through `LinkedSpec::Get`; outputs are the one-element accumulator snapshot; `mdbook build` exit 0 |
| — | `SPEC-LANG-REFERENCE.10.6` | `done` | corrected the durable record (2026-06-17): retracted the inaccurate "regex-on-top → `[]`" sub-claim (ground truth: those forms run and return values; only `::AND … -> Rule[N]` returns `[]`); KM card rewritten doctrine-first; rationale for `.10` = the 2-rule authoring doctrine, not an `[]` bug |
| — | `SPEC-LANG-REFERENCE.10.5.1` | `done` | **whole-book scorch AUDIT (2026-06-17)** — 8 read-only agents + personal ground-truth re-verification; findings table above; engine facts (`::`≡`:` on non-first rules; `::AND -> Rule[N]` → `[]`); ~105 `::`-mode headers across ~20 files; user chose FULL book-wide scorch; ebnf "richer example" cleared (compiles). Decomposed into `.10.5.2`–`.10.5.19` |
| — | `SPEC-LANG-REFERENCE.10.5.2` | `done` | `overview/what-is-linkedspec.md` minimal kv example → verified 2-rule idiom (2026-06-17); extracted-from-book run → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`; `mdbook build` exit 0 |
| — | `SPEC-LANG-REFERENCE.10.5.3` | `done` | `public-api/get-and-get-parser.md` minimal `Get` example → verified 2-rule idiom (2026-06-17); book-extracted run → `[{"kind":"top","text":"foo"}]`; caught `match_text()`→`entry_text()` (else `null`); `mdbook build` exit 0 |
| — | `SPEC-LANG-REFERENCE.10.5.4` | `done` | `worked-spec-walkthrough.md` rewritten to the verified 2-rule idiom (2026-06-18); every claimed output re-derived through `LinkedSpec::Get` (`answer = 42` → `[{"kind":"pair",…}]`; output corrected single-hash → one-element list; `ctx{top_rule}` `Pair`→`Top`); `match_group`→`entry_group`; declare/assign dropped per user pivot; `mdbook build` exit 0 |
| — | `SPEC-LANG-REFERENCE.10.5.4.1` | `done` | reactivated by user directive (2026-07-08); the 2026-06-18 `SPEC-FORMAT-TERSE` pause is resolved; no book content changed |
| — | `SPEC-LANG-REFERENCE.10.5.5` | `done` | `user-model/spec-files-and-rule-paragraphs.md` examples now use verified 2-rule forms; bare `label:` open-block validation error documented |
| — | `SPEC-LANG-REFERENCE.10.5.6` | `done` | `user-model/rule-modes-and-parse-modes.md` regex-owning mode examples now use single-colon labels; `Top:: /foo/` parse-mode snippets replaced with verified 2-rule wrapper |
| — | `SPEC-LANG-REFERENCE.10.5.7` | `done` | `user-model/regex-in-spec.md` examples now use no-regex `Top::` wrappers plus single-colon regex-bearing rules; capture compaction examples reverified |
| — | `SPEC-LANG-REFERENCE.10.5.8` | `done` | `user-model/blind-calls-and-parser-orchestration.md` blind-call `::` wrappers stayed no-regex; stray regex-owning action-edge examples now use single-colon labels |
| — | `SPEC-LANG-REFERENCE.10.5.9` | `done` | `dsl/action-and-lifecycle-placement.md` fixed 2026-07-08; lifecycle drift caveat tracked |
| — | `SPEC-LANG-REFERENCE.10.5.10` | `done` | `dsl/capture-marks-and-source-locations.md` fixed 2026-07-08; capture seek caveat tracked |
| — | `SPEC-LANG-REFERENCE.10.5.11` | `done` | `dsl/declaration-helper-reference.md` fixed 2026-07-08; List/Token examples reverified |
| — | `SPEC-LANG-REFERENCE.10.5.12` | `done` | `dsl/source-boundary-helper-reference.md` fixed 2026-07-08; seven examples reverified |
| — | `SPEC-LANG-REFERENCE.10.5.13` | `done` | `dsl/value-container-flow-helper-reference.md` fixed 2026-07-08; Token/FieldList/Node/Sequence/Kind examples reverified |
| — | `SPEC-LANG-REFERENCE.10.5.14` | `done` | remaining DSL pages fixed/audited 2026-07-08; Token/Value/Items examples reverified |
| — | `SPEC-LANG-REFERENCE.10.5.15` | `done` | `appendix/formal-grammar.md` §1 + §12 examples fixed 2026-07-08; four probes reverified |
| — | `SPEC-LANG-REFERENCE.10.5.16` | `done` | `appendix/runtime-semantics.md` §5.5/§5.6 fixed 2026-07-08; `.10.4` folded; five outputs reverified |
| — | `SPEC-LANG-REFERENCE.10.5.17` | `done` | `tablegrep-spec-walkthrough.md` output drift fixed 2026-07-08; parser outputs and descriptor metadata reverified |
| — | `SPEC-LANG-REFERENCE.10.5.18` | `done` | `portmap-spec-walkthrough.md` output-shape examples reverified 2026-07-08; current page already matches live nested JSON |
| — | `SPEC-LANG-REFERENCE.10.5.19` | `done` | planned page scorch finalized 2026-07-08; residual regex-on-`::` examples fixed; whole-book re-grep clean |
| — | `SPEC-LANG-REFERENCE.10.5.20` | `done` | lifecycle final-value / direct-`E` Perl handler drift resolved 2026-07-08 as a documented current Perl-reference caveat under ADR `0020` |
| — | `SPEC-LANG-REFERENCE.10.4` | `superseded` | folded into `.10.5.16` |
| 9 | `SPEC-LANG-REFERENCE.5.3` | `pending` | worked examples: Array family (largest) — resume after the scorch |
| 10 | `SPEC-LANG-REFERENCE.5.4` | `pending` | worked examples: Hash + Control Flow families |
| 11 | `SPEC-LANG-REFERENCE.5.5` | `pending` | worked examples: Declaration, Capture/Mark, Entry/Match, Input, Call families (closes `.5`) |
| 12 | `SPEC-LANG-REFERENCE.6` | `pending` | capture/mark cross-example + remaining thin spots |
| 13 | `SPEC-LANG-REFERENCE.7` | `pending` | KM fact cards for the durable subjects |
| 14 | `SPEC-LANG-REFERENCE.8` | `pending` | finalize — whole-book consistency + close |

## Decisions

- **`2026-07-08` — LIFECYCLE DRIFT DECISION (`.10.5.20`, ADR `0020`).**
  The lifecycle final-value/direct-`E` drift found during `.10.5.9` remains a documented current
  Perl-reference caveat for the language-reference closeout, not an implicit Perl engine-change
  authorization. Public and portable examples use explicit `return(...)`; the runtime semantics appendix
  now states that final statements in lifecycle blocks are not a portable implicit return channel. Any
  behavior normalization must be owned by a separate implementation/parity leaf with focused Perl locks,
  cross-variant review, and docs/KM updates.

- **`2026-07-08` — ACTION/LIFECYCLE PAGE FIX (`.10.5.9`) + DRIFT FOLLOW-UP.**
  The action/lifecycle placement chapter now treats regex-bearing snippets as normal `:` rule fragments,
  not top `::` rules. The page also distinguishes entry-match lifecycle code (`I { ... }` + `entry_*`)
  from later local-slot action edges (`-> Rule[index] { ... }` + `match_*`). During verification, TOOLBOX
  probes found a current Perl generated-handler caveat: omitted lifecycle `return(...)` can leak a final
  host statement value in some shapes, and direct default-rule `E { ... }` finalization can be omitted from
  generated source. The page documents explicit lifecycle `return(...)` as the safe public example style;
  Knowledge fact `perl-lifecycle-final-value-e-drift` and follow-up leaf `.10.5.20` own the broader drift.

- **`2026-07-08` — SPEC FILE PARAGRAPH PAGE FIX (`.10.5.5`).** The
  `user-model/spec-files-and-rule-paragraphs.md` page now follows the scorch doctrine for runnable
  stream examples: `Top::` is a no-regex entry rule that dispatches and returns its accumulator, and
  normal `:` matcher rules carry regexes and read the entering match with `entry_text()`. The old bare
  `label:` example is not valid block DSL; it is a validation error (`Rule definition not allowed
  inside open block`). The page now uses a valid quoted `"label:"` helper value to teach the
  block-boundary distinction, and the exact validation behavior is durable in Knowledge Map fact
  `rule-starts-open-block-validation`.

- **`2026-07-08` — SCORCH REACTIVATED (user directive, `.10.5.4.1`).** The 2026-06-18 pause caused
  by activating `SPEC-FORMAT-TERSE` is resolved. The whole-book language-reference scorch resumes at
  `.10.5.5`; this activation slice changes durable coordination state only and does not edit book
  content. The next implementation leaf remains the per-file fix for
  `user-model/spec-files-and-rule-paragraphs.md`.

- **`2026-06-17` — SCOPE: FULL BOOK-WIDE SCORCH (user decision, `.10.5.1`).** Faced with the audit
  finding that the `Rule::AND /regex/ -> Rule[N] {return}` idiom is **pervasive** (~105 `::`-mode rule
  headers across ~20 files) and that the audit agents disagreed on whether isolated helper-illustration
  fragments count as violations, the user was asked (AskUserQuestion) to choose the remediation breadth
  and selected **"Full book-wide scorch"**: rewrite **every** worked example — *including* the isolated
  DSL helper-illustration fragments — to the verified 2-rule idiom (top `::` entry rule with **no
  regex** + normal `:` rule(s) carrying the regex, reading `entry_group(N)`, surfacing values via the
  accumulator snapshot), and correct **all** wrong claimed outputs. Consequence: `.10.5.2`–`.10.5.18`
  each remediate one file (or coherent group); `.10.5.19` finalizes. The doctrine governs even though
  the engine is permissive (`::`≡`:` on non-first rules) — the book teaches the **authoring
  discipline**, not the engine's tolerance ([[feedback_spec-structure-top-plus-normal]], KM card
  `spec-top-rule-no-regex-two-rule-minimum.md`). Fragments that carry **no** regex and make **no**
  output claim (isolated helper-statement / lifecycle / method-chain sketches) stay as fragments;
  faithful shipped-spec quotes stay verbatim; only their claimed I/O is corrected.

- **`2026-06-17` — ENGINE FACTS for the scorch (`.10.5.1`, verified via `LinkedSpec::Get`).** (1) `::`
  and `:` are interchangeable on a **non-first** rule (`child::AND /re/` ≡ `child:AND /re/`); only the
  **first** rule is the top/`_INITIAL` entry; multiple `::` rules do not collide. So a regex on a `::`
  rule is a **doctrine** problem, not an engine error (the engine is permissive — matches `.10.6`).
  (2) The `Rule::AND /regex/ -> Rule[N] { return(...) }` shape (AND mode + slot self-edge) drops its
  edge return → `[]` (the `.10.1` `_emit_and_single_acode_handler` finding) — so the book's pervasive
  worked-example idiom both violates the doctrine **and** fails to surface its `return` value. The fix
  idiom is the verified `demo:: -> child .push` / `LX{return(array_copy(a(demo)))}` + `child : /re/
  I.return(<expr reading entry_group(N)>)` form.

- **`2026-06-17` — CORRECTION (user-established `.spec` structural invariant; supersedes the `.10.1`
  engine-bug verdict).** A `.spec` **top-level rule** (written with `::`) is the **entry point**:
  it is entered at startup and runs a `while(1)` loop that matches the regexes of the **non-top
  (`:`) rules** and dispatches to them. **The top rule has NO regex of its own.** Therefore a valid
  `.spec` has **at least two rules**: the `::` entry rule **plus** ≥1 normal `:` rule that carries
  the regex(es). Authoritative basis: `BootstrapSpec/Core.pm:414` (label line is anchored
  `\A LABEL (::|:) MODE \z` — no regex on the label) + `:417` (`::`→`_INITIAL`), `RuleIR.pm:193-195`
  (`_INITIAL`→`top_rule`), and an audit of all 20 `specs/*.spec` (every top rule `regex_on_top=no`).
  A regex-on-top-rule or single-rule spec is **malformed**; the engine is permissive and returns the
  empty top accumulator `[]` (NOT a bug). The Perl reference is authoritative and **must not be
  touched** ([[feedback_do-not-fix-reference-engine]]). Consequence: `.5.2` (35 examples + the
  catalog preamble) and `.9` (§5.5) used the invalid `Demo:: /regex/ -> Demo {…}` form and must be
  redone (`.10.3`/`.10.4`); other chapters audited in `.10.5`. KM card:
  `spec-top-rule-no-regex-two-rule-minimum.md`.
  **Proven minimal worked-example idiom** (verified via `LinkedSpec::Get`, modeled on
  `specs/lib_reader.spec` / `specs/tclite.spec`):
  ```text
  demo_top::  -> word_pair  .push
  LX {return(array_copy(a(demo_top)))}

  word_pair : /(\w+) (\w+)/  I.return(concat(entry_group(0), "-", entry_group(1)))
  ```
  Input `hello world` → `["hello-world"]`. KEY: the normal rule reads **`entry_group(N)`** (the
  entering match), NOT `match_group(N)` (local match, unset in the child's `I` block — the cause of
  an earlier `[null]`). The output is the top rule's accumulator snapshot (so one match → a
  one-element array); the per-match helper value here is `"hello-world"`.

- **`2026-06-17` — `.10.6` retraction (an engine-reality sub-claim of the CORRECTION above was
  inaccurate; the authoring doctrine stands).** Ground-truthing the CORRECTION's premise via
  `LinkedSpec::Get` showed that a regex on a `::` rule with an OR self-ref / cross-rule **action edge
  does run and return its value** — the old `.5.2`/`.9` examples returned the documented values, and
  the §5.5 frozen oracle fixtures (`Top:: /x/ -> Done {…}`) work. So the sub-claim "a regex-on-top /
  single-rule spec silently returns `[]`" was **wrong** and is retracted; the only shape returning
  `[]` is the explicit `::AND … -> Rule[N] { return(...) }` form (the `.10.1` finding). **This does
  NOT change the doctrine or `.10.3`:** a `.spec` is written as a top `::` entry rule (no regex) + ≥1
  normal `:` rule (per [[feedback_spec-structure-top-plus-normal]] and all 20 shipped specs), and
  `.10.4`/`.10.5` still reshape regex-on-top book examples to that form — but the **rationale is the
  authoring doctrine, not an `[]` bug**. There is no rationale for ever putting a regex on a top
  rule. KM card `spec-top-rule-no-regex-two-rule-minimum.md` rewritten doctrine-first.

- `2026-06-17`: Created tree to own the user request (comprehensive variant-agnostic `.spec`
  documentation + KM cards). Per the splitting discipline, the first leaf is an audit that
  produces the decomposition rather than guessing gap-filling leaves up front. The audit is
  gathered read-only (codebase surface inventory ∥ book coverage map via parallel agents) and
  synthesized into the gap list here.

## Open Questions

- (audit) Granularity of the gap-filling leaves — decided when `.1` completes (likely grouped
  by construct family: file/paragraph model, rule modes, parse modes, edges, lifecycle markers,
  capture/mark, helper families, control flow, runtime semantics, + a KM-cards leaf + finalize).
- ~~(`.10.5.20`, NON-BLOCKING FOLLOW-UP) Decide whether the Perl lifecycle final-value/direct-`E`
  handler-shape drift remains a documented reference caveat or becomes an implementation/parity task.~~
  **RESOLVED 2026-07-08 in ADR `0020` / `.10.5.20`:** documented caveat now; implementation/parity
  behavior changes require a separate owning leaf.
- ~~(`.10`, DECISION NEEDED — engine-fix vs doc-rewrite for the single-slot AND output drift)~~
  **RESOLVED / WITHDRAWN 2026-06-17.** The premise (an `AND_SINGLE_ACODE` engine bug) was wrong: the
  affected examples are **structurally invalid** (regex on the top rule / single-rule). There is no
  engine bug, the Perl reference is **not** to be touched, and the fix is purely documentation
  (rewrite the examples to the valid 2-rule idiom). See the CORRECTION in Decisions. The fork no
  longer exists.

## Blockers

- None. (`.10.2`'s "blocked-on-decision" is gone — superseded; the decision was withdrawn after the
  user's structural correction. The scorch is closed as of `.10.5.20`; resume at `.5.3`.)

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-17` | `SPEC-LANG-REFERENCE.1` | two read-only audits (surface inventory ∥ book coverage map) synthesized; cross-checked the "E/IT deprecated" claim vs `LIFECYCLE-FAMILY-AUDIT`; `scripts/check_memory_architecture.sh` | self-check exit 0; 8/10 surface areas WELL-COVERED; binding gaps = regex-first-class (`.2`) + output-shape (`.3`); minor gaps `.4`–`.6`; KM cards `.7`; finalize `.8`. Rejected the unverified E/IT-deprecated claim. No book change (audit only) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.2` | engine facts verified read-only against `perl/LinkedRE.pm`, `perl/LinkedSpec/ActionIR/Contracts.pm` (`entry_group`/`match_group`/`entry_named` lowering), `perl/LinkedSpec/BootstrapSpec/Core.pm` (`/pattern/` recognizer), `rust/linkedspec-runtime/src/helpers.rs` (rgx `CompiledAlternation`), and cross-checked vs shipped specs (`lib_reader`/`tablegrep`/`spec.spec`); `mdbook build` (pre + post); whole-book grep for capture-indexing drift | `mdbook build` exit 0 both times; new `regex-in-spec.md` chapter + `formal-grammar.md §3.1` expansion; **3 drift sites corrected** (wrong "index 0 = full match" claim + two examples using the 1-based convention); convention verified 0-based/captures-only/compacted |
| `2026-06-17` | `SPEC-LANG-REFERENCE.3` | output shapes verified vs frozen oracle-corpus fixtures (`rust/linkedspec-runtime/tests/corpus/proof_edge_{scalar,array}_literal`), a **live Perl-reference run** (`LinkedSpec::Get` on a `/(\w+)=(\w+)/` spec → `["?pair:","key","val"]`), and shipped-spec grep for the tagged convention; grounded the wrap + return-vs-accumulator in `docs/knowledge/rust-perl-output-oracle.md`; `mdbook build` | `mdbook build` exit 0; `runtime-semantics.md §5` expanded (§5.5–§5.8). A hand-built accumulator example (`[undef,undef,undef]`) was discarded — only verified material documented. Tagged shape reframed as OPTIONAL per user feedback (engine imposes no output schema) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.4` | both new examples **compiled** through `LinkedSpec::Get` (grouped target + `Call`→`Inner` divergence); ran ~9 minimal accumulator/dispatch shapes to attempt a top-level divergence I/O (all → `[]`/`undef`/`0`, the documented hard accumulator axes); divergence semantics grounded in `.2`'s verified source wiring + the existing source-boundary example; `mdbook build` | `mdbook build` exit 0; grouped-target section (`action-and-lifecycle-placement.md`) + entry-vs-match divergence section (`capture-marks-and-source-locations.md`). Divergence documented at the reader-wiring level (not a fabricated I/O) — honest scope note recorded |
| `2026-06-17` | `SPEC-LANG-REFERENCE.5.1` | delegated read-only catalog audit (`Contracts.pm` id set vs catalog); self-verified the 2 flagged sigil leaks at `helper-contract-catalog.md:13,159` + whole-catalog re-sweep for `$`/`@`/`%` sigils and `lowers to`/`do {`/`Data::Dumper`/`JSON::PP`/`//gcp`; `mdbook build` | `mdbook build` exit 0; **0 public-API completeness gaps** (158 ids = ~130 public + 17 internal IR variants + ~11 deprecated `compatibility_surface`); **2 sigil leaks fixed**, no others; example-density gap (0/~140) decomposed into `.5.2`–`.5.5` |
| `2026-06-17` | `SPEC-LANG-REFERENCE.5.2` | scratch oracle-style driver (`LinkedSpec::Get` → run parser on input → `JSON::PP->canonical` encode) over all 35 Scalar+Numeric examples; sanity-checked vs frozen fixtures `proof_edge_{scalar,array}_literal` (reproduced exactly); probed the value-vs-condition lowering split in `ActionIR/FlowExpr.pm`; `mdbook build` | `mdbook build` exit 0; 35/35 examples produce the documented outputs; `is_defined`/`is_undefined` documented condition-only (die as values); `split→num_sum` non-composition avoided (array-form reducers use explicit `array(...)`); **discovered** §5.5 Pair example outputs `[]` not the tagged array → owned by new leaf `.9` (not bundled) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.9` | scratch oracle driver: reconfirmed `Pair::AND … -> Pair[0]` → `[]` under default/`consume`/`seek`; confirmed corrected OR self-ref `-> Pair` → `["?pair:","key","val"]`; §5.5/§5.6 sweep; whole-book `grep -E '-> \w+\[0\]'` + `::AND` cross-scan; checked `worked-spec-walkthrough.md` claimed output + ground-truthed self-edge idiom vs shipped specs (`portmap`/`hlink_substitution`/`DT`); `mdbook build` | `mdbook build` exit 0; §5.5 Pair example fixed (+ §5.7 cross-ref note); §5.6 left untouched (different construct). **Found SYSTEMIC variant** — single-slot `::AND -> Rule[0] { return }` output drift in several chapters (notably `worked-spec-walkthrough.md` claims `{kind=>"pair",…}`, actually `[]`) → new leaf `.10`, **blocked on a user decision** (engine-bug vs doc-rewrite) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10.1` | delegated read-only codegen investigation (general-purpose agent, 42 tool-uses) + **self-verified the 3 load-bearing claims against source**: read `HandlerVariantEmitter.pm:564-630` (confirmed the missing `push` at 575-582), `git log -- HandlerVariantEmitter.pm` (confirmed MEDIUM-IMPACT.3.4.x provenance: `148c746`/`7fec186`), and `specentry-perl-coupling-inventory.md:234` (confirmed the pre-documented "lack E-block support" gap); behavioral matrix via `LinkedSpec::Get` (single-slot AND `LX`/`E`/edge `return` all → `[]`; OR self-ref + multi-slot-closing-slot + REP all surface values) | ~~VERDICT: accidental regression~~ — **SUPERSEDED** (see next row). The verdict was wrong because the premise was wrong (the examples are structurally invalid). |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10` (correction) | user established the `.spec` structural invariant (top `::` rule has no regex; valid spec ≥2 rules); verified vs `BootstrapSpec/Core.pm:414,417` (`::`→`_INITIAL`, label line anchored — no regex) + `RuleIR.pm:193-195` (`_INITIAL`→`top_rule`) + audit of all 20 `specs/*.spec` (every top rule `regex_on_top=no`); **proven the correct 2-rule worked-example idiom** via `LinkedSpec::Get` (`demo_top:: -> word_pair .push; LX{return(array_copy(a(demo_top)))}` + `word_pair : /(\w+) (\w+)/ I.return(concat(entry_group(0),"-",entry_group(1)))` → `["hello-world"]`; the child reads `entry_group` not `match_group`) | **NO engine bug** — the `[]` was invalid spec structure (regex on top rule / single-rule). Perl reference untouched. Deleted the bad KM card; wrote `spec-top-rule-no-regex-two-rule-minimum.md`. `.10.1` verdict + `.10.2` fork superseded; remediation `.10.3`/`.10.4`/`.10.5`. FRESH SESSION recommended |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10.3` | scratch harness builds each example from the exact book 2-rule scaffold + `LinkedSpec::Get` run + `JSON::PP->canonical` encode (sanity-checked vs the frozen `["hello-world"]` idiom); all 33 Scalar+Numeric examples re-derived; `mdbook build`; rendered-HTML check that the full blocks stay single code blocks; whole-catalog `match_group` grep | `mdbook build` exit 0; 33/33 produce the documented one-element-array outputs; `is_defined` regex fixed `/(\w*)(\S*)/`→`/(\w+)/` (empty-matchable double-match → `["present","present"]`); only remaining `match_group` is the §8 reference (correct). self-check + KM gate pass |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10.6` | ground-truth matrix via `LinkedSpec::Get` (OR self-ref / cross-rule action-edge regex-on-`::`-rule forms + the §5.5 frozen fixtures all run and return values; only `::AND … -> Rule[N]` → `[]`); KM-card rewrite; KM gate regenerates `KNOWLEDGE_MAP.md`; self-check | prior "regex-on-top → `[]`" premise disproven and retracted; KM card rewritten doctrine-first; doctrine + `.10.3` unchanged; KM gate + self-check pass; no Perl/book-example change |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10.5.1` | 8 read-only `Explore` agents over chapter groups (enumerate→classify→run); **personal re-verification of every load-bearing finding** via a private `LinkedSpec::Get` driver (shared driver clobbered by an agent mid-run → all agent ACTUAL_OUTPUT treated as hypotheses); engine probes (T1 `child::AND`≡T2 `child:AND`=`[0]`; T3 `Top:: /foo/ -> Top`=`null`; T4 two `::` rules OK); re-ran tablegrep/portmap/worked-walkthrough/ebnf; whole-book `::`-header grep; `scripts/check_memory_architecture.sh` | self-check exit 0. ~105 `::`-mode headers / ~20 files; idiom is doctrine-divergent + `[]`-shaped. Findings table recorded; 18 fix leaves `.10.5.2`–`.10.5.19` created. **2 preliminary-hunt hypotheses overturned:** ebnf "richer example" compiles+parses (CLEAN); §5.5 forms run+return. User chose full book-wide scorch. No book/Perl change |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10.5.2` | extracted the new block **from the book file** and ran it through `LinkedSpec::Get` (`foo=bar baz=qux`→`[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`; `answer=42`→`[{"key":"answer","val":"42"}]`); compared idiom forms (`I {return}` works, bare `{return}`→`[0,0]`); `mdbook build` | `mdbook build` exit 0; single-rule `Top::AND+ /…/ -> Top[0]` (regex-on-top → `null`) replaced with the verified 2-rule idiom + accurate prose/output + cross-links |
| `2026-06-17` | `SPEC-LANG-REFERENCE.10.5.3` | extracted the new `Get` heredoc spec **from the book file** + ran `LinkedSpec::Get` (`foo`→`[{"kind":"top","text":"foo"}]`); compared `match_text()`(→`null`) vs `entry_text()`(→`"foo"`); confirmed only one inline `.spec` heredoc on the page; `mdbook build` | `mdbook build` exit 0; `Top::AND /foo/ -> Top[0]` (→ `[]`) replaced with the verified 2-rule idiom using `entry_text()` + an output comment + a structure-teaching sentence |
| `2026-06-18` | `SPEC-LANG-REFERENCE.10.5.4` | rewrote the whole chapter to the 2-rule idiom (`Top::` entry + `Pair:` matcher); mode-aware `LinkedSpec::Get` driver re-derived every claimed I/O (default/consume `answer = 42`→`[{"kind":"pair","name":"answer","value":"42"}]`; consume `junk answer = 42`→`[]`; seek→the pair; multi `a = 1, b = 2`→2-element list); descriptor/ctx probe (`ref HASH`✓, `meta.parse_mode consume`✓, `spec{Pair}`✓, **`ctx{top_rule}` Pair→Top**); isolated the `:AND`+separated-`I`→`[0]` and OR-`I`-block→`[null]` traps; `mdbook build`; `scripts/check_memory_architecture.sh` | `mdbook build` exit 0; self-check exit 0. Single-rule `Pair::AND -> Pair[0]` (→`[]`, claimed a hash) replaced; output reframed single-hash→one-element list; `match_group`→`entry_group` (+ trap doc); **declare()/assign() removed** from the advanced sketch per user pivot (call(...) teaching kept). Surfaced the terse-format pivot → user activated `SPEC-FORMAT-TERSE`; scorch paused after this leaf. No Perl change |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.4.1` | durable coordination update only: task tree, central index, memory pointer, live status, changelog, and development notes | scorch reactivated by user directive; next active leaf is `.10.5.5`; no parser/runtime/source/book behavior changed |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.5` | four replacement snippets run through `LinkedSpec::Get` (minimal, label-in-block, compact same-line, multiline); explicit bad bare-`label:` probe; `mdbook build docs/linkedspec-book`; Knowledge Map fact card + regeneration | replacement snippets compile/run and return documented payloads; bare `label:` inside an open block reports `Rule definition not allowed inside open block`; mdBook build exit 0; new fact `rule-starts-open-block-validation` indexed |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.6` | representative runtime probes through `LinkedSpec::Get` (token-stream wrapper; `seek`/`consume` word wrapper); source-page scan for remaining `::` labels; `mdbook build docs/linkedspec-book` | token stream `foo "bar"` → `["foo","bar"]`; `seek` `junk foo` → `["foo"]`; `consume` `junk foo` → `[]`; `consume` `foo` → `["foo"]`; remaining `::` labels are no-regex entry/dispatcher examples; mdBook build exit 0 |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.7` | representative runtime probes through `LinkedSpec::Get` (keyword wrapper; numbered groups; named groups; numbered-compaction and named-compaction cases); source-page scan for remaining `::` labels; `mdbook build docs/linkedspec-book` | outputs match documented payloads: `["foo"]`, `[{"key":"foo","val":"bar"}]`, `[{"name":"alpha"}]`, numbered compaction `abc`→`[{"amount":"abc","name":null}]`, `12abc`→`[{"amount":"12","name":"abc"}]`, named groups stable; remaining `::` labels are no-regex wrappers; mdBook build exit 0 |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.8` | source-page scan for `::` headers followed by regex slots; wrapped mixed-edge negative probe through `LinkedSpec::Get`; `mdbook build docs/linkedspec-book` | scan reports no regex slot under a `::` header; mixed-edge probe logs `Cannot mix ACTION (->) and BLIND CALL (=>) code blocks`; mdBook build exit 0 |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.9` | focused `LinkedSpec::Get` probes for entry-match `I`, later-slot actions, explicit lifecycle return, and Pair slot flow; source-page scan for `::` headers followed by regex slots; `mdbook build docs/linkedspec-book`; Knowledge Map check | probes return documented payloads (`Name`, `Token`, lifecycle hash, Pair hash); scan reports no regex slot under a `::` header; mdBook build and Knowledge Map check exit 0; Perl lifecycle drift fact recorded |
| `2026-07-08` | `SPEC-LANG-REFERENCE.10.5.20` | focused Perl probes for direct default-rule `I`+regex+`E`, dispatched child lifecycle without explicit return, and `dump_parser_source`; ADR/KM/runtime-semantics updates; `mdbook build docs/linkedspec-book`; memory, task-tree, doctrine, whitespace, and Knowledge Map checks | direct shape returns `"not_a_return"`; dispatched child without explicit return returns `["not_a_return"]`; generated direct handler source includes the `I` final statement and omits the `E` hash-return path. ADR `0020` keeps this as a documented caveat until a separate implementation/parity leaf owns behavior normalization; gates pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-LANG-REFERENCE.1` | `SPEC-LANG-REFERENCE.1 — audit: full .spec surface inventory + book coverage map; decompose into .2-.8` | Also creates the owning tree + registers it in docs/TASK_TREE.md (ownership-first, folded into the first leaf per repo convention). Audit only — no book change |
| `SPEC-LANG-REFERENCE.2` | `SPEC-LANG-REFERENCE.2 — book: regex as a first-class concept (new user-model chapter) + fix capture-indexing drift` | New `user-model/regex-in-spec.md` + `SUMMARY.md`; `formal-grammar.md §3.1` capture-group/flags expansion; corrected the `entry_group`/`match_group` indexing contradiction in `helper-contract-catalog.md`, `overview/what-is-linkedspec.md`, `formal-grammar.md`, `source-boundary-helper-reference.md`. All facts verified vs `LinkedRE.pm`/`Contracts.pm`/rgx/shipped specs |
| `SPEC-LANG-REFERENCE.3` | `SPEC-LANG-REFERENCE.3 — book: output/return-value shape contract in runtime-semantics §5 (output is author's choice; optional tagged shape)` | Expanded `appendix/runtime-semantics.md §5` (§5.5–§5.8): top-rule value, output is author's choice (optional tagged convention per user feedback), return-vs-accumulator, one-level wrap. Verified vs oracle corpus + live Perl run + shipped specs |
| `SPEC-LANG-REFERENCE.4` | `SPEC-LANG-REFERENCE.4 — book: grouped action-edge targets (edges chapter) + entry-vs-match divergence (capture chapter)` | Grouped-target section in `action-and-lifecycle-placement.md` (ebnf-grounded) + divergence section in `capture-marks-and-source-locations.md`; both examples compile-verified. Divergence documented at reader-wiring level (top-level I/O entangled with hard accumulator axes — not fabricated) |
| `SPEC-LANG-REFERENCE.5.1` | `SPEC-LANG-REFERENCE.5.1 — helper-catalog audit: 0 completeness gaps, fix 2 variant-neutrality sigil leaks, decompose example work into .5.2-.5.5` | Confirmed 0 public-API gaps; fixed `$name`/`$rule_label` sigil leaks in `helper-contract-catalog.md`; split `.5` into per-family example sub-leaves. mdbook build exit 0 |
| `SPEC-LANG-REFERENCE.5.2` | `SPEC-LANG-REFERENCE.5.2 — book: compile-verified worked examples for all Scalar + Numeric helpers (helper-contract-catalog §2/§5)` | 35 helpers, each run-verified through `LinkedSpec::Get` against the oracle; shared runnable-spec preamble; condition-only note for `is_defined`/`is_undefined`; array-form reducers via explicit `array(...)`. Found §5.5 drift → new leaf `.9`. mdbook build exit 0 |
| `SPEC-LANG-REFERENCE.9` | `SPEC-LANG-REFERENCE.9 — book: fix drifted §5.5 Pair example output (AND-[0] self-edge returns [] not the tagged array)` | Corrected the §5.5 Pair example to the verified OR self-ref `-> Pair` form (+ §5.7 cross-ref). Surfaced a SYSTEMIC variant across chapters → new leaf `.10` (blocked on a user decision). mdbook build exit 0 |
| `SPEC-LANG-REFERENCE.10.1` | `SPEC-LANG-REFERENCE.10.1 — investigation: single-slot AND drops its edge return ([]) is a Perl-reference regression, not intended (KM card + verdict)` | Read-only root-cause investigation; VERDICT = accidental regression in `AND_SINGLE_ACODE` emitter (missing `push`); triple-verified vs source/git/card; KM card `and-single-acode-edge-return-dropped.md`. `.10.2` fix blocked on a user direction decision. No code/book change. **(Verdict later SUPERSEDED — see `.10` correction commit.)** |
| `SPEC-LANG-REFERENCE.10` (correction) | `SPEC-LANG-REFERENCE.10 — correction: top rule has no regex; .5.2/.9 examples are structurally invalid (not an engine bug); retract .10.1, plan remediation (.10.3-.5)` | User-established structural invariant (top `::` rule no regex; valid spec ≥2 rules), verified vs Core.pm/RuleIR.pm + 20-spec audit. Deleted the wrong KM card, added `spec-top-rule-no-regex-two-rule-minimum.md` with the proven 2-rule idiom. Superseded `.10.1` verdict + `.10.2`; added remediation leaves. NO Perl change. Repo handoff-ready; fresh session recommended |
| `SPEC-LANG-REFERENCE.10.3` | `SPEC-LANG-REFERENCE.10.3 — book: redo Scalar+Numeric helper examples + preambles with the valid 2-rule idiom (entry_group; re-verified outputs)` | Rewrote both `helper-contract-catalog.md` worked-examples preambles + all 33 examples to the top-entry-rule + normal-rule form reading `entry_group(N)`; every output re-derived through `LinkedSpec::Get`; outputs are the one-element accumulator snapshot. `mdbook build` exit 0 |
| `SPEC-LANG-REFERENCE.10.6` | `SPEC-LANG-REFERENCE.10.6 — record: retract the inaccurate "regex-on-top → []" premise; reframe the .10 rationale as the 2-rule authoring doctrine` | Rewrote the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first + superseding Decision + record-framing fixes; doctrine and `.10.3` unchanged. No Perl/book-example change |
| `SPEC-LANG-REFERENCE.10.5.1` | `SPEC-LANG-REFERENCE.10.5.1 — audit: whole-book .spec-snippet scorch (findings table + engine facts) → decompose into per-file fix leaves .10.5.2-.19` | Read-only audit (8 agents + personal ground-truth re-verify). ~105 `::`-mode headers across ~20 files; pervasive `Rule::AND /regex/ -> Rule[N]` idiom is doctrine-divergent + `[]`-shaped. User chose FULL book-wide scorch. ebnf "richer example" cleared. `.10.4` superseded by `.10.5.16`. No book/Perl change |
| `SPEC-LANG-REFERENCE.10.5.2` | `SPEC-LANG-REFERENCE.10.5.2 — book: fix what-is-linkedspec.md minimal kv example → verified 2-rule idiom` | Replaced the single-rule `Top::AND+ /…/ -> Top[0]` (regex-on-top → compile-fail/`null`) with `top:: -> pair .push` / `LX{return(array_copy(a(top)))}` + `pair: /(\w+)=(\w+)/ I{return(hash(…entry_group(0/1)…))}`; book-extracted run → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`; `mdbook build` exit 0 |
| `SPEC-LANG-REFERENCE.10.5.3` | `SPEC-LANG-REFERENCE.10.5.3 — book: fix get-and-get-parser.md minimal Get example → verified 2-rule idiom` | Replaced inline `Top::AND /foo/ -> Top[0] {…match_text()…}` (→ `[]`) with `top:: -> word .push` / `LX{return(array_copy(a(top)))}` + `word: /foo/ I{return(hash("kind","top","text",entry_text()))}`; book-extracted run → `[{"kind":"top","text":"foo"}]`; `match_text()`→`null` trap caught; `mdbook build` exit 0 |
| `SPEC-LANG-REFERENCE.10.5.4` | `SPEC-LANG-REFERENCE.10.5.4 — book: fix worked-spec-walkthrough.md → verified 2-rule idiom; re-derive whole-chapter outputs; drop declare/assign` | Central single-rule `Pair::AND -> Pair[0]` (→`[]`, claimed `{kind:pair,…}`) → `Top::` entry + `Pair:` matcher; every claimed I/O re-derived via `LinkedSpec::Get`; output corrected single-hash→one-element list; `match_group`→`entry_group`; `ctx{top_rule}` Pair→Top; declare()/assign() removed from the advanced sketch per the user terse-format pivot. `mdbook build` exit 0. **Whole-book scorch PAUSED here — user activated `SPEC-FORMAT-TERSE`.** |
| `SPEC-LANG-REFERENCE.10.5.4.1` | `SPEC-LANG-REFERENCE.10.5.4.1 — reactivate book scorch` | User reactivated `SPEC-LANG-REFERENCE`; durable coordination records now point to `.10.5.5` as the next book-content leaf. Metadata-only; no mdBook source or parser/runtime behavior changed |
| `SPEC-LANG-REFERENCE.10.5.5` | `SPEC-LANG-REFERENCE.10.5.5 — fix spec file paragraph examples` | `spec-files-and-rule-paragraphs.md` runnable examples now use the verified 2-rule idiom; the malformed bare `label:` block is replaced with valid quoted `"label:"` helper content plus the exact validation-error note. Four snippets verified through `LinkedSpec::Get`; mdBook build exit 0; Knowledge fact card added |
| `SPEC-LANG-REFERENCE.10.5.6` | `SPEC-LANG-REFERENCE.10.5.6 — fix rule mode and parse mode examples` | `rule-modes-and-parse-modes.md` regex-owning mode examples now use single-colon labels, the `::` framing teaches no-regex entry/dispatcher usage, and `Top:: /foo/` parse-mode snippets are replaced with the verified 2-rule wrapper. Runtime probes and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.7` | `SPEC-LANG-REFERENCE.10.5.7 — fix regex chapter examples` | `regex-in-spec.md` examples now use no-regex `Top::` wrappers plus single-colon regex-bearing rules. Numbered/named capture and compaction teaching is preserved with `entry_group` / `entry_named`; runtime probes and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.8` | `SPEC-LANG-REFERENCE.10.5.8 — fix blind-call orchestration examples` | `blind-calls-and-parser-orchestration.md` keeps no-regex blind-call `::` wrappers, converts regex-owning action-edge examples to single-colon labels, and clarifies the mixed-edge negative example. Scan/probe and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.9` | `SPEC-LANG-REFERENCE.10.5.9 — fix action and lifecycle placement examples` | `action-and-lifecycle-placement.md` now separates entry-match `I`/`entry_*` from local-slot action `match_*`, removes regex-on-`::` examples, corrects hash initialization, and records the Perl lifecycle handler drift caveat |
| `SPEC-LANG-REFERENCE.10.5.10` | `SPEC-LANG-REFERENCE.10.5.10 — fix capture and entry-match examples` | `capture-marks-and-source-locations.md` now uses a no-regex `Top::` wrapper plus normal `Body:` delimiter rule for the `capture_slice()` example, and a blind-call `Top::AND => Call` wrapper plus normal `Call:`/`Inner:` rules for entry-vs-match divergence. Seek-mode capture probe returns `[{"body":"body"}]`; blind-call probe returns `greet` vs `world`; Knowledge fact `perl-capture-slice-delimiter-seek-boundary` records the consume-mode caveat |
| `SPEC-LANG-REFERENCE.10.5.11` | `SPEC-LANG-REFERENCE.10.5.11 — fix declaration helper examples` | `declaration-helper-reference.md` now uses no-regex wrappers for accumulator and metadata examples: `List::` owns aggregate state while `Item:` owns the matcher, and `Top::` dispatches to regex-owning `Token:`. Runtime probes return the documented two-item list and token metadata outputs; page scan and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.12` | `SPEC-LANG-REFERENCE.10.5.12 — fix source-boundary examples` | `source-boundary-helper-reference.md` now uses no-regex `Top::AND` blind-call wrappers plus normal regex-owning rules for Tuple, Block, Paren, Pair, Body, AtEnd, and entry-vs-match examples. Seven focused probes return the documented source-boundary outputs; page scan and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.13` | `SPEC-LANG-REFERENCE.10.5.13 — fix value-container flow examples` | `value-container-flow-helper-reference.md` now uses no-regex wrappers or entry rules for Token, FieldList, Node, Sequence, and Kind examples, with regex slots moved to normal matcher rules. Five focused probes return the documented token, field-list, node-normalization, sequence head/tail, and switch-classification outputs; page scan and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.14` | `SPEC-LANG-REFERENCE.10.5.14 — fix remaining DSL examples` | `values-containers-and-flow-helpers.md`, `action-model-and-helper-surface.md`, and `fluent-and-block-forms.md` now avoid regex-bearing `::` examples for Token, Value, and Items. `actionir-lowering-mental-model.md` audited clean as helper/pipeline fragments only. Focused Token, Value, and Items probes pass; four-page scan and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.15` | `SPEC-LANG-REFERENCE.10.5.15 — fix formal grammar examples` | `formal-grammar.md` §1 and §12 now use no-regex top rules plus normal regex-owning matcher rules. The complete example defines every dispatch target and verifies DemoParser, SecondChild, and ThirdChild outputs; appendix scan and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.16` | `SPEC-LANG-REFERENCE.10.5.16 — fix runtime semantics examples` | `runtime-semantics.md` §5.5/§5.6 now uses no-regex `Top::` wrappers plus normal regex-owning `Done:`, `Pair:`, `object:`, and `manifest:` rules. The folded `.10.4` Pair target now returns the verified `entry_group` tagged array through `Top`; five focused outputs, page scan, and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.17` | `SPEC-LANG-REFERENCE.10.5.17 — fix tablegrep walkthrough outputs` | `tablegrep-spec-walkthrough.md` now shows verified JSON outputs for the simple term and grouped expression (`sens` is `=`), and its descriptor helper list matches the live spec. Parser probes, descriptor metadata probe, and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.18` | `SPEC-LANG-REFERENCE.10.5.18 — verify portmap walkthrough outputs` | `portmap-spec-walkthrough.md`'s five output-shape examples were rechecked against `LinkedSpec::get_parser('portmap')`; the current page already matches the live nested JSON for bare, bit, slice, constant, and concatenation cases. Parser probes and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.19` | `SPEC-LANG-REFERENCE.10.5.19 — finalize book scorch` | Whole-book closeout scans found and fixed the remaining regex-on-`::` mdBook examples in `spec-files-and-rule-paragraphs.md`, `helper-contract-catalog.md`, and `compiler/pipeline-overview.md`. Follow-up scans return no matches; focused parser probes and mdBook build pass |
| `SPEC-LANG-REFERENCE.10.5.20` | `SPEC-LANG-REFERENCE.10.5.20 — document lifecycle drift policy` | Lifecycle final-value/direct-`E` drift resolved as a documented current Perl-reference caveat under ADR `0020`; `runtime-semantics.md` teaches explicit `return(...)` as the portable return channel; KM fact updated; focused probes and gates pass |

## Changelog

- `2026-06-17`: Created task tree (ownership-first). Frontier → `.1` (audit / decomposition).
- `2026-06-17`: `.1` done — audit + decomposition. Two read-only agents inventoried the full
  `.spec` surface (`Core.pm`/`Validation.pm`/`Contracts.pm`/`spec.spec`/shipped specs) and
  mapped the book's coverage; synthesized in "Audit Findings". 8/10 surface areas already
  WELL-COVERED; binding gaps are regex-as-first-class (`.2`) and the output/return-shape
  contract (`.3`), plus grouped-targets / entry-vs-local-match examples (`.4`), helper-catalog
  completeness + variant-neutrality (`.5`), capture/mark cross-example (`.6`), KM cards (`.7`),
  finalize (`.8`). Rejected an unverified "E/IT deprecated" inventory claim (contradicts
  `LIFECYCLE-FAMILY-AUDIT`). Owning tree created + registered in this commit. Frontier → `.2`.
- `2026-06-17`: `.2` done — regex as a first-class concept. Added new chapter
  `docs/linkedspec-book/src/user-model/regex-in-spec.md` (registered in `SUMMARY.md`):
  `/pattern/` literal + `\/` escaping + inline `(?flags)`; regex slots/clusters → ordered
  sequence (AND) vs alternatives (OR) + branch tracking; `seek`/`consume` anchoring; numbered
  groups (0-based, captures-only, **compacted**) + the compaction gotcha + named-group remedy;
  entry-vs-match; and a verified "regex feature set a backend must support" section. Expanded
  `appendix/formal-grammar.md §3.1` with the capture-group contract + inline-flags clarification.
  Every engine fact was verified read-only against `perl/LinkedRE.pm`, the ActionIR lowering in
  `perl/LinkedSpec/ActionIR/Contracts.pm`, the `/pattern/` recognizer in `BootstrapSpec/Core.pm`,
  the Rust `rgx`-based runtime (`rust/linkedspec-runtime/src/helpers.rs`), and cross-checked
  against shipped specs — never guessed. Discovered and fixed a real **capture-indexing
  contradiction**: `helper-contract-catalog.md` said "index 0 is the full match" while the
  walkthrough (correctly) said index 0 is the first capture group; corrected the catalog and two
  buggy examples (`overview/what-is-linkedspec.md`, the `formal-grammar.md` Child rule) that used
  the wrong 1-based convention, and clarified `source-boundary-helper-reference.md`. `mdbook build`
  exit 0. Frontier → `.3` (output/return-shape contract).
- `2026-06-17`: `.3` done — output/return-value shape contract. Expanded
  `appendix/runtime-semantics.md §5` (renamed to "Accumulator and Output Shape") with §5.5
  *What a Parser Returns* (the top rule's value, returned directly with no envelope; three verified
  input→output pairs), §5.6 *The Output Shape Is the Author's Choice* (the engine imposes no output
  schema — any scalar/array/hash composition is valid; the `["?<rule>:", …]` tagged array is just an
  **optional, older convention** with no engine meaning), §5.7 *`return(...)` versus the accumulator*,
  and §5.8 *Backend Output Reconciliation* (the one-level wrap; reference value is canonical). Grounded
  + verified, not guessed: literal examples are frozen oracle-corpus fixtures, the tagged example was
  produced by running the Perl reference, the convention was confirmed by grepping shipped specs, and
  the wrap/return contract is from `docs/knowledge/rust-perl-output-oracle.md`. A hand-built accumulator
  example returning `[undef,undef,undef]` was discarded rather than guessed. **User feedback mid-leaf**:
  the tagged shape is an old, non-mandatory convention — reframed §5.6/§5.7 so the book states output
  shape is entirely the author's choice (saved as a durable feedback memory). `mdbook build` exit 0.
  Frontier → `.4` (grouped-target + entry-vs-local-match worked examples).
- `2026-06-17`: `.4` done — worked examples for the MAJOR/MEDIUM clarity gaps. (1) Added a
  *Grouped action-edge targets* section to `dsl/action-and-lifecycle-placement.md` (`-> A | B { ... }`,
  one shared block bound to multiple targets), grounded in `ebnf.spec`'s `semantic_annotation` rule and
  formal grammar §3.2; the minimal example compiles. (2) Added a *When `entry_*` and `match_*` diverge*
  section to `dsl/capture-marks-and-source-locations.md` — a dispatched-child example
  (`Call`→`Inner` over `greet(world)`: `entry_text()` reads the entering `greet(`, `match_text()` reads
  the local `world`), cross-linked to the source-boundary reference example; compiles. Both examples
  compile-verified through `LinkedSpec::Get`. **Honest scope note**: a clean top-level runtime I/O for
  the divergence was not fabricated — ~9 minimal accumulator/dispatch shapes all collapsed to
  `[]`/`undef`/`0` (the documented hard accumulator-/child-return divergence axes), so the divergence is
  documented at the verified reader-wiring level (which span each family reads), consistent with the
  book's existing style. `mdbook build` exit 0. Frontier → `.5` (helper-catalog completeness +
  variant-neutrality sweep).
- `2026-06-17`: `.5` **split** + `.5.1` done. A delegated read-only audit reconciled the
  `Contracts.pm` helper-id set against `appendix/helper-contract-catalog.md`: **0 public-API
  completeness gaps** (the 158/146/140 spread is 17 internal IR variants that map to documented DSL
  names + ~11 deprecated `compatibility_surface` contracts); **2 variant-neutrality Perl-sigil leaks**
  (`declare`'s "`$name`" → "named `name`"; `push`'s "`$rule_label`" → "named after the rule label"),
  both fixed and a whole-catalog re-sweep confirmed no others; and **0 `.spec` examples across all 10
  families / ~140 helpers** — the large remaining surface. Per the splitting discipline (and the leaf's
  own "may split" note), decomposed the example work into per-family sub-leaves `.5.2` (Scalar+Numeric),
  `.5.3` (Array), `.5.4` (Hash+Control Flow), `.5.5` (Declaration/Capture-Mark/Entry-Match/Input/Call),
  each adding ≥1 compile-verified example per family. `.5.1` shipped the audit + variant-neutrality fixes
  + decomposition (the ownership-first slice). `mdbook build` exit 0. Frontier → `.5.2`.
- `2026-06-17`: `.5.2` done — verified worked examples for the **Scalar (§2)** and **Numeric (§5)**
  helper families in `helper-contract-catalog.md`. Added a shared **Worked examples** preamble (the
  runnable `Demo:: /<re>/ -> Demo { return(<expr>) }` scaffold; output = the parser's top-level value;
  booleans → `1`/`0`, undef → `null`) and an `Example` to **all 35 helpers** (17 Scalar + 18 Numeric),
  with full `.spec` blocks for the high-frequency ones (`concat`, `trim`, `num_add`, `num_sum`) and the
  required `if (...)` block for the condition-only predicates. **Every example was build-AND-run verified
  through `LinkedSpec::Get`** (scratch oracle-style driver, sanity-checked against the frozen
  `proof_edge_{scalar,array}_literal` fixtures — reproduced exactly, so outputs are reference behavior,
  not guesses). **Two do-not-guess traps caught:** (1) `is_defined`/`is_undefined` lower only on the
  control-flow path (`ActionIR/FlowExpr.pm`), so they are documented condition-only — `return(is_defined(x))`
  dies; (2) `num_sum(split(...))` returns `null`, so array-form reducers are documented with explicit
  `array(...)` (split deferred to the Array family `.5.3`). **Discovered defect** (owned separately, not
  bundled): the §5.5 `runtime-semantics.md` Pair example outputs `[]`, not the documented tagged array
  → new leaf `.9`. `mdbook build` exit 0. Frontier → `.9` (no-drift priority) then `.5.3`.
- `2026-06-17`: `.9` done — corrected the §5.5 `runtime-semantics.md` Pair example. Reconfirmed the
  `Pair::AND … -> Pair[0] { return(array(…)) }` form returns `[]` under default/`consume`/`seek`, and
  the OR self-ref `Pair:: … -> Pair { return(array("?pair:", match_group(0), match_group(1))) }` form
  returns the documented `["?pair:","key","val"]`; swapped the example to that form + added a §5.7
  cross-ref note that the self-ref edge surfaces the return value. §5.5/§5.6 swept (frozen Top→Done
  fixtures correct; §5.6 `I.return`-on-`:`-rule snippets are a different, shipped-spec-grounded
  construct, left untouched). **The fix surfaced a SYSTEMIC variant of the drift**: the same single-slot
  `::AND -> Rule[0] { return(...) }` form is used in several other chapters that ALSO assert a concrete
  top-level output (notably the canonical `worked-spec-walkthrough.md`, claiming `{kind=>"pair",…}` for
  `answer = 42`; actually `[]`). Ground-truthed against shipped specs: `-> Rule[N] { return(...) }`
  self-edges are real, but on **multi-slot** rules returning at the closing slot (often an accumulator
  snapshot), so the construct is valid — the drift is single-slot `::AND` self-edge examples claiming
  the `return` value as output. Owned by new leaf `.10`, **blocked on a user decision** (engine-bug-fix
  vs doc-rewrite; surfaced to the user). `mdbook build` exit 0. Frontier → `.10` (blocked) then `.5.3`.
- `2026-06-17`: `.10` split + `.10.1` done — root-cause investigation (the user chose "investigate
  first, then recommend; hold the loop"). A delegated read-only codegen agent + my own verification of
  its 3 load-bearing claims established the **VERDICT: the single-slot `::AND -> Rule[0] { return }` → `[]`
  behavior is an accidental REGRESSION in the Perl reference, not intended.** Root cause:
  `_emit_and_single_acode_handler` (`perl/LinkedSpec/HandlerVariantEmitter.pm:564-630`) computes the
  transformed edge acode in the loop at 575-582 but **never `push`es it** into `@acodes_transformed`, so
  the edge dispatch is empty and the handler returns the never-written accumulator (`return \@collect`,
  628) → `[]`. Introduced by the MEDIUM-IMPACT.3.4.x emitter rework (`148c746`/`7fec186`); the sibling
  `_emit_and_acode_seq_handler` got the same edit WITH its `push` (oversight); pre-documented as a gap in
  `specentry-perl-coupling-inventory.md:234`; no test pins `[]` as intended. Verified idiomatic
  value-surfacing forms (OR self-ref, multi-slot closing-slot return, REP). KM card
  `and-single-acode-edge-return-dropped.md` written. `.10` split into `.10.1` (investigation, done) +
  `.10.2` (the fix, **blocked on a user DIRECTION decision**: engine-fix vs doc-rewrite vs both — if
  engine-fix, it's a dedicated engine tree, not doc work). No code/book change. PNT loop remains held
  by the user; next selectable `.5.3` once `.10` direction is set.
- `2026-06-17`: **MAJOR CORRECTION (user).** The user established the `.spec` structural invariant: a
  **top (`::`) rule has NO regex** — it is the `_INITIAL` entry/dispatch loop that matches the regexes
  of the **non-top (`:`) rules**; a valid `.spec` needs **≥2 rules** (top entry + ≥1 normal rule
  carrying the regex). Verified vs `BootstrapSpec/Core.pm:414,417`, `RuleIR.pm:193-195`, and an audit
  of all 20 `specs/*.spec` (every top rule has no regex). **This invalidates the premise of `.10.1`:**
  the single-rule `::AND -> Rule[0] { return }` examples returned `[]` because they are **structurally
  invalid** (regex on the top rule), NOT an `AND_SINGLE_ACODE` engine bug. There is **no engine bug**;
  the **Perl reference must not be touched** ([[feedback_do-not-fix-reference-engine]]). Consequence:
  `.5.2`'s 35 examples + catalog preamble and `.9`'s §5.5 example are structurally invalid and must be
  redone with the **verified 2-rule idiom** (top entry rule + normal rule reading `entry_group(N)` —
  see Decisions / KM card `spec-top-rule-no-regex-two-rule-minimum.md`; proven `["hello-world"]`).
  Deleted the mis-diagnosis KM card `and-single-acode-edge-return-dropped.md`; superseded `.10.1`
  verdict + `.10.2` fork; added remediation leaves `.10.3`/`.10.4`/`.10.5`. No Perl or book-example
  change in THIS slice (records + correction only). **FRESH SESSION recommended**; repo handoff-ready.
- `2026-06-17`: `.10.3` done — redid the `.5.2` Scalar (§2) + Numeric (§5) worked-examples preambles
  and all 33 helper examples in `helper-contract-catalog.md` with the **verified 2-rule idiom** (top
  `demo::` entry rule with NO regex `-> value .push` + `LX { return(array_copy(a(demo))) }`; normal
  `value : /<re>/  I.return(<expr>)` reading `entry_group(N)`), replacing the structurally-invalid
  `Demo:: /re/ -> Demo { return(<expr>) }` scaffold (regex on the top rule). Every example was
  build-AND-run re-verified through `LinkedSpec::Get` (scratch harness builds each spec from the exact
  book scaffold; sanity-checked vs the frozen `["hello-world"]` idiom); outputs are now the top rule's
  one-element accumulator snapshot (e.g. `["hello-world"]`, `[5]`, `[3.5]`, `[null]`, `[1]`/`[0]`).
  Caught + fixed an empty-matchable-regex double-match (`is_defined` `/(\w*)(\S*)/` → `/(\w+)/`).
  `mdbook build` exit 0 (rendered HTML verified). No Perl change. Frontier → `.10.4` (redo `.9` §5.5
  Pair example with valid 2-rule structure).
- `2026-06-17`: `.10.6` done — corrected the durable record. Ground-truthing the `.10` CORRECTION's
  premise via `LinkedSpec::Get` showed the OR self-ref / cross-rule action-edge regex-on-`::`-rule
  forms (the old `.5.2`/`.9` shape and the §5.5 frozen oracle fixtures) **run and return their value**
  (`"hello-world"`, `5`, `["?pair:","key","val"]`), so the "regex-on-top → `[]`" sub-claim was wrong
  and is retracted; the only shape returning `[]` is `::AND … -> Rule[N] { return }` (the `.10.1`
  finding). Rewrote the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first with the
  retraction. **The 2-rule authoring doctrine and `.10.3` stand** (matching all 20 shipped specs +
  [[feedback_spec-structure-top-plus-normal]]); only the remediation *rationale* is corrected — the
  examples violated the 2-rule doctrine, not that they returned `[]`. There is no rationale for
  putting a regex on a top rule. KM gate regenerates `KNOWLEDGE_MAP.md`; self-check passes. No Perl,
  no book-example change. Frontier still → `.10.4`.
- `2026-06-17`: **`.10.5` scope broadened** (user directive — "scorch the book to hunt down book
  examples; the book shall not mislead, only truthful + valid code snippets"). `.10.5` is now a
  **whole-book** exhaustive audit of every `.spec` snippet (doctrine-validity + output-correctness)
  → remediation — an audit-as-decomposition producing fix sub-leaves `.10.5.1…` and subsuming the
  `.10.4` §5.5 Pair fix. Frontier repointed → `.10.5`. **Preliminary fan-out hunt** (4 of 5 read-only
  verifying agents reported before the session exited — NOT authoritative; re-run fresh next session)
  **confirms the scorch is warranted: regex-on-top / single-rule violations are WIDESPREAD** — many
  across `user-model/rule-modes-and-parse-modes.md`, `user-model/regex-in-spec.md`, the
  `dsl/*-helper-reference.md` pages, `dsl/capture-marks-*`, `dsl/source-boundary-*`; plus specific
  high-value confirmed items: `user-model/worked-spec-walkthrough.md` claims `{kind=>"pair",…}` for
  `answer = 42` but actually returns `[]` (Class B); `public-api/get-and-get-parser.md` "minimal
  example" is a single-rule regex-on-top `Top::AND` → `[]` (Class A/B); `appendix/runtime-semantics.md`
  §5.5 puts a regex on a `::` rule in all three examples (incl. the two "frozen oracle fixtures"
  `Top:: /x/ -> Done`). **Confirmed CLEAN:** the `.10.3` helper-catalog §2/§5 worked examples
  (re-verified) and the lispish/pplugin/shipped-specs walkthroughs (faithful shipped-spec quotes).
  specs-and-corpora drift to fix: `portmap-spec-walkthrough.md` (5 output-shape examples — flat-with-
  `undef` claimed vs actual nested arrays like `["?bare:",["clk"]]`), `tablegrep-spec-walkthrough.md`
  (`sens` field claims `=~` but the regex captures only `=`), `ebnf-spec-walkthrough.md` (the
  `@generate:`-led "richer example" does not compile — Class D). EVERY flagged item must be RE-VERIFIED
  during remediation (agent findings are hypotheses — cf. this session's `.10.6` lesson; one agent even
  reported the §5.5 Pair as `null` where a direct run gave `["?pair:","key","val"]`, a transcription
  sensitivity to resolve per-fix). Read-only record/plan update only — no book/Perl change.
- `2026-06-17`: **`.10.5` split + `.10.5.1` done — whole-book scorch AUDIT.** Ran the fresh exhaustive
  hunt: **8 read-only `Explore` agents** over chapter groups, then **personally ground-truthed every
  load-bearing finding** through a private `LinkedSpec::Get` driver (an audit agent had overwritten the
  shared scratch driver mid-run, so all agent ACTUAL_OUTPUT values were treated as hypotheses — the
  `.10.6` lesson held). Established **engine facts** (probed, not guessed): `::` and `:` are
  interchangeable on a non-first rule (`child::AND /re/` ≡ `child:AND /re/` = `[0]`); only the first
  rule is the top/entry (multiple `::` rules don't collide); `Top:: /foo/ -> Top` → `null`; so
  `::`-no-regex is an **authoring doctrine**, not a hard engine constraint. **Headline:** the
  `Rule::AND /regex/ -> Rule[N] {return}` idiom is **pervasive — ~105 `::`-mode rule headers across
  ~20 files** — and is doctrine-divergent (regex on `::`) **and** the shape that returns `[]`.
  Findings synthesized into "Audit Findings (`.10.5.1`)". **Two preliminary-hunt hypotheses overturned
  on re-verification:** `ebnf-spec-walkthrough.md`'s "richer example" **does** compile + parse to its
  claimed structure (CLEAN — the "does not compile" claim was wrong), and the §5.5 forms run + return
  values. Verified drifts: `tablegrep` `sens` = `=` (not `=~`); `portmap` outputs are nested
  (`["?bare:",["clk"]]`) not flat. **User decision (AskUserQuestion): FULL BOOK-WIDE SCORCH** — rewrite
  every worked example (incl. isolated DSL helper fragments) to the 2-rule idiom + correct all outputs.
  Decomposed into per-file fix leaves `.10.5.2`–`.10.5.19`; `.10.4` superseded by `.10.5.16`. No
  book/Perl change (audit only). Frontier → `.10.5.2` (`what-is-linkedspec.md` minimal example).
- `2026-06-17`: `.10.5.2` done — fixed `overview/what-is-linkedspec.md`'s "minimal key/value parser"
  example. The old `Top::AND+ /(\w+)=(\w+)/ -> Top[0] { return(hash(…)) }` was a single rule with a
  regex on the top rule **and** the `::AND -> Top[0]` self-edge → the handler **failed to compile** and
  the parser returned `null` (the prose claimed "returns a hash per match"). Replaced with the verified
  2-rule idiom (`top:: -> pair .push` / `LX { return(array_copy(a(top))) }` + a normal `pair:` rule
  carrying the regex in an `I { return(hash("key", entry_group(0), "val", entry_group(1))) }` block) and
  rewrote the prose to teach the entry-rule-(no-regex)/normal-rule-(regex) structure with the real
  output + cross-links. **Verified by extracting the exact block from the book file** and running it
  through `LinkedSpec::Get`: `foo=bar baz=qux` → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`.
  Idiom note: the bare action-block form `pair: /re/ { return }` (no `I`) returns `[0,0]` — the `I{…}`
  block is required. `mdbook build` exit 0. Frontier → `.10.5.3` (`public-api/get-and-get-parser.md`).
- `2026-06-17`: `.10.5.3` done — fixed `public-api/get-and-get-parser.md`'s inline `Get(...)` minimal
  example. The heredoc spec `Top::AND /foo/ -> Top[0] { return(hash("kind","top","text",match_text())) }`
  is regex-on-top + `::AND -> Top[0]` → `[]` (presented as a working minimal example). Replaced with
  the 2-rule idiom (`top:: -> word .push` / `LX { return(array_copy(a(top))) }` + `word: /foo/ I {
  return(hash("kind","top","text",entry_text())) }`), added a `# $ast is [ { kind => "top", text =>
  "foo" } ]` comment + a structure-teaching sentence. **Verified by extracting the heredoc from the
  book file** and running `LinkedSpec::Get`: `foo` → `[{"kind":"top","text":"foo"}]`. Caught the
  `match_text()`→`entry_text()` trap (the dispatched child's local match is unset → `match_text()`
  gives `null`; `entry_text()` reads the entering match → `"foo"`). `mdbook build` exit 0. Frontier →
  `.10.5.4` (`user-model/worked-spec-walkthrough.md`).
- `2026-06-18`: `.10.5.4` done — rewrote `user-model/worked-spec-walkthrough.md` to the verified
  2-rule idiom. The chapter's central single-rule `Pair::AND /…/ -> Pair[0] { return(hash(…)) }`
  returns `[]` while the prose claimed a `{kind:pair,name:answer,value:"42"}` hash; replaced it with a
  `Top::` entry rule (no regex; `-> Pair .push` + `LX { return(array_copy(a(Top))) }`) plus a `Pair:`
  matcher rule (`I { return(hash("kind","pair","name",entry_group(0),"value",trim(entry_group(1)))) }`).
  **Re-derived every claimed I/O** with a mode-aware `LinkedSpec::Get` driver: `answer = 42`
  (default/consume) → `[{"kind":"pair","name":"answer","value":"42"}]`; `junk answer = 42` consume →
  `[]`, seek → the pair; `a = 1, b = 2` → a 2-element list. Corrected the chapter's single-hash output
  claim to a one-element **list** (the entry rule's accumulator snapshot); `match_group`→`entry_group`
  throughout (+ the dispatched-child trap); descriptor checks still hold but **`ctx{top_rule}` Pair→Top**.
  **User mid-leaf pivot (2026-06-18):** flagged `declare()`/`assign()` (slated for removal in
  `SPEC-FORMAT-TERSE`) — removed them from the advanced "Evolving the spec" sketch (kept the `call(...)`
  teaching). Verified they are still **live** in the reference engine + shipped specs, and the removal
  tree `SPEC-FORMAT-TERSE` was `proposed`, not done. The user then chose (AskUserQuestion) to **activate
  `SPEC-FORMAT-TERSE` now**, so the whole-book scorch is **PAUSED after this leaf** (the terse migration
  will re-sweep every book example in lockstep with the engine). `mdbook build` exit 0; self-check exit
  0. No Perl change. Frontier → SCORCH PAUSED; pivot to `SPEC-FORMAT-TERSE.0` (ratify + ADR).
- `2026-07-08`: `.10.5.4.1` done — user reactivated `SPEC-LANG-REFERENCE`. Durable coordination
  records now resolve the 2026-06-18 pause and set `.10.5.5` as the next active scorch leaf. Metadata
  only; no mdBook source, parser/runtime code, corpus, or Knowledge Map facts changed. Frontier →
  `.10.5.5` (`user-model/spec-files-and-rule-paragraphs.md` malformed label-in-block + `Top::AND`
  sketches).
- `2026-07-08`: `.10.5.5` done — fixed
  `docs/linkedspec-book/src/user-model/spec-files-and-rule-paragraphs.md`. The minimal, block-boundary,
  same-line, and multiline examples now use the verified 2-rule idiom (`Top::` dispatch/accumulator +
  normal matcher rules with regexes and `entry_text()`). The malformed bare `label:` block example is
  replaced with a valid quoted `"label:"` helper value and an explicit validation-error note. Added
  Knowledge fact `rule-starts-open-block-validation`. Frontier → `.10.5.6`
  (`user-model/rule-modes-and-parse-modes.md` mode fragments + "both valid shapes" framing).
- `2026-07-08`: `.10.5.6` done — fixed
  `docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md`. Regex-owning rule-mode examples
  now use single-colon labels (`Pair:AND`, `TokenStream:OR`, bounded `AND{...}`/`OR{...}`, etc.);
  `::` examples are no-regex entry/dispatcher or blind-call compositions. The old "both valid shapes"
  framing now teaches the two-rule documentation idiom while preserving the engine nuance that the top
  rule is ordinary at runtime. The `Top:: /foo/` seek/consume snippets are replaced with a verified
  `Top::` + `Word:` wrapper: seek `junk foo` returns `["foo"]`, consume `junk foo` returns `[]`, and
  consume `foo` returns `["foo"]`. `mdbook build` exit 0. Frontier → `.10.5.7`
  (`user-model/regex-in-spec.md` regex-on-`::` fragments).
- `2026-07-08`: `.10.5.7` done — fixed
  `docs/linkedspec-book/src/user-model/regex-in-spec.md`. The minimal keyword, numbered-group,
  named-group, and compaction examples now use no-regex `Top::` wrappers where complete snippets are
  needed and single-colon regex-bearing child rules (`Keyword:`, `Pair:`, `Subdef:`, `Unit:`). The
  capture teaching remains intact: numbered groups are 0-based, captures-only, and compacted; named
  groups stay stable when optional groups are absent. Runtime probes confirm the documented keyword,
  pair, named capture, numbered-compaction, and named-compaction outputs. `mdbook build` exit 0.
  Frontier → `.10.5.8` (`user-model/blind-calls-and-parser-orchestration.md` audit/fix).
- `2026-07-08`: `.10.5.8` done — fixed
  `docs/linkedspec-book/src/user-model/blind-calls-and-parser-orchestration.md`. The actual blind-call
  examples were clean no-regex `::` wrappers; four action-edge examples that owned regex slots now use
  single-colon labels (`Parent:AND`, `BadRule:AND`, `HeaderRule:AND`, `Field:AND`). The mixed-edge
  negative example now explicitly says the single-colon label is deliberate and the error is mixing
  `->` with `=>`. A focused scan reports no `::` header followed by a regex slot; the wrapped negative
  probe logs the expected mixed-edge validation error. `mdbook build` exit 0. Frontier → `.10.5.9`
  (`dsl/action-and-lifecycle-placement.md` worked examples).
- `2026-07-08`: `.10.5.9` done — fixed
  `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`. Regex-bearing examples now use
  normal `:` rule labels, entry-match transforms are taught with `I { ... }` plus `entry_*`, and local-slot
  action edges use `match_*`. Corrected stale examples that used bare child-rule lines, scalar shape
  assignment before `hash(meta)` reads, and direct lifecycle `E` finalization as if it were universally
  stable. Focused probes verified the corrected `Name`, `Token`, lifecycle, and Pair examples; page scan
  reports no `::` header followed by a regex slot; `mdbook build` exit 0. Found and tracked a current Perl
  lifecycle handler-shape caveat in Knowledge fact `perl-lifecycle-final-value-e-drift` and follow-up leaf
  `.10.5.20`. Frontier → `.10.5.10` (`dsl/capture-marks-and-source-locations.md` worked examples).
- `2026-07-08`: `.10.5.18` done — reverified
  `docs/linkedspec-book/src/specs-and-corpora/portmap-spec-walkthrough.md` against the live
  `specs/portmap.spec` Perl reference. The five documented output examples already match current
  backend output: bare, bit, slice, constant, and concatenation cases are nested tagged arrays rather
  than flat `undef`-padded records. `mdbook build` exit 0. Frontier → `.10.5.19`
  (planned whole-book closeout sweep).
- `2026-07-08`: `.10.5.19` done — finalized the planned whole-book scorch. Closeout scans found
  three residual regex-on-`::` examples and fixed them in
  `user-model/spec-files-and-rule-paragraphs.md`, `appendix/helper-contract-catalog.md`, and
  `compiler/pipeline-overview.md`. Focused `LinkedSpec::Get` probes verify the corrected `sexpr`,
  direct value-path, array end-mutation, and function-registry outputs. Whole-book regex-on-`::`
  re-greps are clean and `mdbook build` exits 0. Frontier → `.10.5.20`
  (lifecycle handler-shape drift follow-up).
- `2026-07-08`: `.10.5.20` done — resolved the lifecycle handler-shape drift follow-up as a
  documented current Perl-reference caveat under ADR `0020`, not as an implicit backend change.
  Reverified that the direct default-rule `I`+regex+`E` shape returns `"not_a_return"` and its
  generated source omits the `E` hash-return path, while a dispatched child without explicit return
  returns `["not_a_return"]`. `runtime-semantics.md` now says portable lifecycle/action values come
  from explicit `return(...)`; KM fact `perl-lifecycle-final-value-e-drift` points to ADR `0020`.
  Frontier → `.5.3` (Array helper worked examples).
