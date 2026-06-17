# SPEC-LANG-REFERENCE: Complete, variant-agnostic, example-rich book coverage of the entire `.spec` language

## Metadata

- Tree ID: `SPEC-LANG-REFERENCE`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-17`
- Last updated: `2026-06-17` (`.1` audit done — 8/10 surface areas well-covered; 2 critical gaps (regex-first-class `.2`, output-shape `.3`) + minor gaps; decomposed into `.2`–`.8`; frontier → `.2`)
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
  Children: `.1` (done), `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`

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
  Status: `pending`
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
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.3`
  Status: `pending`
  Goal: Document the **output / return-value shape contract** (CRITICAL gap) in
  `appendix/runtime-semantics.md`
  Acceptance: a new section defining what a `.spec` parser returns — the top rule's value, the
  implicit accumulator model, the canonical one-level wrap, the tagged-shape convention
  (`["?rule:", [...]]`), and how `return(...)` interacts with the accumulator — grounded in the
  `docs/knowledge/rust-perl-output-oracle.md` card + shipped specs, with worked input→output
  examples so a backend does not reverse-engineer it from the corpus. `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.4`
  Status: `pending`
  Goal: Add worked examples for the MAJOR/MEDIUM clarity gaps — grouped shared-code targets
  (`-> A | B { ... }`) and an entry-vs-local-match divergence scenario
  Acceptance: a worked example of a grouped shared-code action edge (multiple targets, one
  block) in the edges chapter; a worked example showing when `entry_*` and `match_*` return
  different values (multi-regex-slot / dispatched-child case) in the capture/lifecycle chapter;
  examples valid against the grammar; `mdbook build` exit 0.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-LANG-REFERENCE.5`
  Status: `pending`
  Goal: Helper-contract catalog **completeness + variant-neutrality** sweep
  Acceptance: confirm every helper family in `perl/LinkedSpec/ActionIR/Contracts.pm` is
  represented in `appendix/helper-contract-catalog.md` with a backend-neutral behavioral
  contract (signature + semantics + edge cases) and at least one example; separate any
  Perl-implementation note from the contract; add examples where the catalog is example-poor.
  May split further during implementation if the surface is large. `mdbook build` exit 0.
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
| 1 | `SPEC-LANG-REFERENCE.2` | `pending` | **next** — regex as a first-class concept (CRITICAL); verify the engine's required regex feature set against `LinkedRE.pm`/rgx before asserting it |
| 2 | `SPEC-LANG-REFERENCE.3` | `pending` | output/return-shape contract (CRITICAL); ground in `docs/knowledge/rust-perl-output-oracle.md` + shipped specs |
| 3 | `SPEC-LANG-REFERENCE.4` | `pending` | worked examples: grouped shared-code targets + entry-vs-local-match divergence |
| 4 | `SPEC-LANG-REFERENCE.5` | `pending` | helper-catalog completeness + variant-neutrality sweep |
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

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-LANG-REFERENCE.1` | `SPEC-LANG-REFERENCE.1 — audit: full .spec surface inventory + book coverage map; decompose into .2-.8` | Also creates the owning tree + registers it in docs/TASK_TREE.md (ownership-first, folded into the first leaf per repo convention). Audit only — no book change |

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
