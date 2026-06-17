# SPEC-LANG-REFERENCE: Complete, variant-agnostic, example-rich book coverage of the entire `.spec` language

## Metadata

- Tree ID: `SPEC-LANG-REFERENCE`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-17`
- Last updated: `2026-06-17` (`.5` split + `.5.1` done — helper-catalog audit: 0 public-API completeness gaps, 2 variant-neutrality sigil leaks fixed; example-density gap (0 examples / ~140 helpers) decomposed into per-family sub-leaves `.5.2`–`.5.5`; `mdbook build` exit 0; frontier → `.5.2`)
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
  Children: `.1`–`.4` (done), `.5` (active: `.5.1` done, `.5.2`–`.5.5` pending), `.6`, `.7`, `.8`

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
  Children: `.5.1` (done), `.5.2`, `.5.3`, `.5.4`, `.5.5`

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
  Status: `pending`
  Goal: Worked examples — Scalar + Numeric helper families
  Acceptance: ≥1 compile-verified `.spec` example per family added to the Scalar and Numeric
  sections of `helper-contract-catalog.md`, with several more for high-frequency helpers; every
  example built through `LinkedSpec::Get` before asserting behavior. `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

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

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `SPEC-LANG-REFERENCE.1` | `done` | Audit complete (2026-06-17) — surface inventory + book coverage map synthesized above; decomposed into `.2`–`.8` |
| — | `SPEC-LANG-REFERENCE.2` | `done` | regex-first-class chapter landed (2026-06-17), verified against `LinkedRE.pm`/`Contracts.pm`/rgx; fixed a capture-indexing contradiction across 3 book files |
| — | `SPEC-LANG-REFERENCE.3` | `done` | output/return-shape contract landed in `runtime-semantics.md §5` (2026-06-17), verified vs oracle corpus + live Perl run; tagged shape framed as an OPTIONAL convention per user feedback |
| — | `SPEC-LANG-REFERENCE.4` | `done` | grouped-target example (edges chapter) + entry-vs-match divergence example (capture chapter), both compile-verified (2026-06-17) |
| — | `SPEC-LANG-REFERENCE.5.1` | `done` | helper-catalog audit (2026-06-17): 0 public-API completeness gaps; 2 variant-neutrality sigil leaks fixed; example-density gap decomposed into `.5.2`–`.5.5` |
| 1 | `SPEC-LANG-REFERENCE.5.2` | `pending` | **next** — worked examples: Scalar + Numeric families (compile-verified) |
| 2 | `SPEC-LANG-REFERENCE.5.3` | `pending` | worked examples: Array family (largest) |
| 3 | `SPEC-LANG-REFERENCE.5.4` | `pending` | worked examples: Hash + Control Flow families |
| 4 | `SPEC-LANG-REFERENCE.5.5` | `pending` | worked examples: Declaration, Capture/Mark, Entry/Match, Input, Call families (closes `.5`) |
| 5 | `SPEC-LANG-REFERENCE.6` | `pending` | capture/mark cross-example + remaining thin spots |
| 6 | `SPEC-LANG-REFERENCE.7` | `pending` | KM fact cards for the durable subjects |
| 7 | `SPEC-LANG-REFERENCE.8` | `pending` | finalize — whole-book consistency + close |

## Decisions

- `2026-06-17`: Created tree to own the user request (comprehensive variant-agnostic `.spec`
  documentation + KM cards). Per the splitting discipline, the first leaf is an audit that
  produces the decomposition rather than guessing gap-filling leaves up front. The audit is
  gathered read-only (codebase surface inventory ∥ book coverage map via parallel agents) and
  synthesized into the gap list here.

## Open Questions

- (audit) Granularity of the gap-filling leaves — decided when `.1` completes (likely grouped
  by construct family: file/paragraph model, rule modes, parse modes, edges, lifecycle markers,
  capture/mark, helper families, control flow, runtime semantics, + a KM-cards leaf + finalize).

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-17` | `SPEC-LANG-REFERENCE.1` | two read-only audits (surface inventory ∥ book coverage map) synthesized; cross-checked the "E/IT deprecated" claim vs `LIFECYCLE-FAMILY-AUDIT`; `scripts/check_memory_architecture.sh` | self-check exit 0; 8/10 surface areas WELL-COVERED; binding gaps = regex-first-class (`.2`) + output-shape (`.3`); minor gaps `.4`–`.6`; KM cards `.7`; finalize `.8`. Rejected the unverified E/IT-deprecated claim. No book change (audit only) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.2` | engine facts verified read-only against `perl/LinkedRE.pm`, `perl/LinkedSpec/ActionIR/Contracts.pm` (`entry_group`/`match_group`/`entry_named` lowering), `perl/LinkedSpec/BootstrapSpec/Core.pm` (`/pattern/` recognizer), `rust/linkedspec-runtime/src/helpers.rs` (rgx `CompiledAlternation`), and cross-checked vs shipped specs (`lib_reader`/`tablegrep`/`spec.spec`); `mdbook build` (pre + post); whole-book grep for capture-indexing drift | `mdbook build` exit 0 both times; new `regex-in-spec.md` chapter + `formal-grammar.md §3.1` expansion; **3 drift sites corrected** (wrong "index 0 = full match" claim + two examples using the 1-based convention); convention verified 0-based/captures-only/compacted |
| `2026-06-17` | `SPEC-LANG-REFERENCE.3` | output shapes verified vs frozen oracle-corpus fixtures (`rust/linkedspec-runtime/tests/corpus/proof_edge_{scalar,array}_literal`), a **live Perl-reference run** (`LinkedSpec::Get` on a `/(\w+)=(\w+)/` spec → `["?pair:","key","val"]`), and shipped-spec grep for the tagged convention; grounded the wrap + return-vs-accumulator in `docs/knowledge/rust-perl-output-oracle.md`; `mdbook build` | `mdbook build` exit 0; `runtime-semantics.md §5` expanded (§5.5–§5.8). A hand-built accumulator example (`[undef,undef,undef]`) was discarded — only verified material documented. Tagged shape reframed as OPTIONAL per user feedback (engine imposes no output schema) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.4` | both new examples **compiled** through `LinkedSpec::Get` (grouped target + `Call`→`Inner` divergence); ran ~9 minimal accumulator/dispatch shapes to attempt a top-level divergence I/O (all → `[]`/`undef`/`0`, the documented hard accumulator axes); divergence semantics grounded in `.2`'s verified source wiring + the existing source-boundary example; `mdbook build` | `mdbook build` exit 0; grouped-target section (`action-and-lifecycle-placement.md`) + entry-vs-match divergence section (`capture-marks-and-source-locations.md`). Divergence documented at the reader-wiring level (not a fabricated I/O) — honest scope note recorded |
| `2026-06-17` | `SPEC-LANG-REFERENCE.5.1` | delegated read-only catalog audit (`Contracts.pm` id set vs catalog); self-verified the 2 flagged sigil leaks at `helper-contract-catalog.md:13,159` + whole-catalog re-sweep for `$`/`@`/`%` sigils and `lowers to`/`do {`/`Data::Dumper`/`JSON::PP`/`//gcp`; `mdbook build` | `mdbook build` exit 0; **0 public-API completeness gaps** (158 ids = ~130 public + 17 internal IR variants + ~11 deprecated `compatibility_surface`); **2 sigil leaks fixed**, no others; example-density gap (0/~140) decomposed into `.5.2`–`.5.5` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-LANG-REFERENCE.1` | `SPEC-LANG-REFERENCE.1 — audit: full .spec surface inventory + book coverage map; decompose into .2-.8` | Also creates the owning tree + registers it in docs/TASK_TREE.md (ownership-first, folded into the first leaf per repo convention). Audit only — no book change |
| `SPEC-LANG-REFERENCE.2` | `SPEC-LANG-REFERENCE.2 — book: regex as a first-class concept (new user-model chapter) + fix capture-indexing drift` | New `user-model/regex-in-spec.md` + `SUMMARY.md`; `formal-grammar.md §3.1` capture-group/flags expansion; corrected the `entry_group`/`match_group` indexing contradiction in `helper-contract-catalog.md`, `overview/what-is-linkedspec.md`, `formal-grammar.md`, `source-boundary-helper-reference.md`. All facts verified vs `LinkedRE.pm`/`Contracts.pm`/rgx/shipped specs |
| `SPEC-LANG-REFERENCE.3` | `SPEC-LANG-REFERENCE.3 — book: output/return-value shape contract in runtime-semantics §5 (output is author's choice; optional tagged shape)` | Expanded `appendix/runtime-semantics.md §5` (§5.5–§5.8): top-rule value, output is author's choice (optional tagged convention per user feedback), return-vs-accumulator, one-level wrap. Verified vs oracle corpus + live Perl run + shipped specs |
| `SPEC-LANG-REFERENCE.4` | `SPEC-LANG-REFERENCE.4 — book: grouped action-edge targets (edges chapter) + entry-vs-match divergence (capture chapter)` | Grouped-target section in `action-and-lifecycle-placement.md` (ebnf-grounded) + divergence section in `capture-marks-and-source-locations.md`; both examples compile-verified. Divergence documented at reader-wiring level (top-level I/O entangled with hard accumulator axes — not fabricated) |
| `SPEC-LANG-REFERENCE.5.1` | `SPEC-LANG-REFERENCE.5.1 — helper-catalog audit: 0 completeness gaps, fix 2 variant-neutrality sigil leaks, decompose example work into .5.2-.5.5` | Confirmed 0 public-API gaps; fixed `$name`/`$rule_label` sigil leaks in `helper-contract-catalog.md`; split `.5` into per-family example sub-leaves. mdbook build exit 0 |

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
