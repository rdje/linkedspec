# MDBOOK-VARIANT-AGNOSTIC: Audit and Remediate mdBook for Variant-Agnostic Language

## Metadata

- Tree ID: `MDBOOK-VARIANT-AGNOSTIC`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-16`
- Last updated: `2026-06-16` (`.5` done)
- Owner: repo-local workflow

## Goal

Make the mdBook (`docs/linkedspec-book/src/`) variant-agnostic: describe LinkedSpec concepts,
DSL syntax, semantics, and helper contracts in language-neutral terms that apply equally to
all backend variants (Perl, Rust, Julia, Dart, …). Implementation-specific details are
minimized in user-facing chapters and clearly labeled when present.

## Non-Goals

- Rewriting the book from scratch
- Removing all mention of Perl — the Perl implementation is the reference and architecture
  chapters legitimately reference it
- Changing the repo's internal continuity docs (CHANGES.md, DEVELOPMENT_NOTES.md, etc.)
- Adding new technical content — this is about language framing, not new features

## Acceptance Criteria

- User-facing overview chapters (what-is-linkedspec, design-rationale, project-status)
  describe LinkedSpec as a multi-backend system with Perl as reference implementation
- User-model chapters (spec-files, rule-paragraphs, etc.) use `.spec` DSL syntax examples
  without implying a single backend
- DSL chapters describe helper contracts and semantics in backend-neutral terms
- Public API chapters acknowledge Perl API while framing it as one backend's surface
- Architecture chapters remain accurate about the Perl owner tree while distinguishing
  between "Perl implementation detail" and "LinkedSpec concept"
- Book builds cleanly (mdBook build succeeds)
- Live docs updated (CHANGES.md, ROADMAP_V2.md, MEMORY.md)
- Each completed leaf committed through `COMMIT.md`

## Task Tree

- ID: `MDBOOK-VARIANT-AGNOSTIC`
  Status: `active`
  Goal: Audit and remediate mdBook for variant-agnostic language
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `MDBOOK-VARIANT-AGNOSTIC.1`
  Status: `done`
  Goal: Complete audit — catalog every Perl-centric sentence, paragraph, and section across all source files
  Acceptance: Audit document listing each file, the Perl-specific passages, and a recommended remediation for each
  Verification: `done` — deterministic per-file leakage scan over all 41 `src/**.md` files + targeted reads; full per-file catalog recorded in "## Audit Findings (.1)" below
  Commit: `MDBOOK-VARIANT-AGNOSTIC.1 — complete variant-agnostic audit of the mdBook`

- ID: `MDBOOK-VARIANT-AGNOSTIC.2`
  Status: `done`
  Goal: Remediate overview chapters — index.md, what-is-linkedspec.md, design-rationale.md, documentation-layers.md, project-status.md
  Acceptance: Overview chapters rewritten to be variant-agnostic; Perl framed as reference implementation
  Verification: `done` — all 5 overview pages reframed: `.spec` = the one universal contract, Perl = reference backend, Rust = second backend (vocabulary aligned with `appendix/backend-handoff.md` + ADR 0006). `index.md` gained a multi-backend frame; `what-is-linkedspec.md` reframed (3 audit passages: L3 "compiler for Perl", L27 `Get`, L52 "coderef" now backend-labelled); `design-rationale.md` dropped the `LinkedSpec.pm`-258-line/`OwnerDispatch` specifics for the thin-facade principle and updated the backend-neutral section (Rust now a real backend); `documentation-layers.md` labelled USER_GUIDE as the Perl reference emission contract; `project-status.md` fixed phase drift (0–7 → 0–9, added Phase 8 multi-backend handoff + Phase 9 Rust variant) and added a multi-backend framing note + Ongoing rows. `mdbook build` exit 0.
  Commit: `MDBOOK-VARIANT-AGNOSTIC.2 — reframe overview chapters as variant-agnostic (.spec = universal contract; Perl = reference backend)`

- ID: `MDBOOK-VARIANT-AGNOSTIC.3`
  Status: `done`
  Goal: Remediate user-model chapters — spec-files-and-rule-paragraphs.md, worked-spec-walkthrough.md, rule-modes-and-parse-modes.md, blind-calls-and-parser-orchestration.md, runtime-context-and-tracing.md
  Acceptance: User-model chapters use .spec DSL syntax, not Perl API calls, as primary examples
  Verification: `done` — applied the `.2` demote-don't-delete convention: each REMEDIATE page leads with the backend-neutral concept and labels its runnable blocks as the Perl reference backend's surface. `worked-spec-walkthrough.md`: added a global backend-neutral frame after the intro, retitled "Running it inline with `Get(...)`" → "Running it inline" (concept-first, `Get` demoted to the Perl-reference example), reframed the `Data::Dumper` note, and changed "raw Perl payload" → "raw host-language payload". `runtime-context-and-tracing.md`: added a top frame stating the context object + `last_error` schema + owner/stage + handler labels + trace levels/modes are backend-neutral contracts while the passing mechanics / `$@` / trace API / `LINKEDSPEC_*` env vars are the Perl reference surface; demoted "caller-provided hash" → "caller-provided object (a hash in the Perl reference backend)", the two `$@` mentions, and the "generated Perl source and `eval`" line. `spec-files-and-rule-paragraphs.md`: replaced the raw `return { kind => "top" }` payload with helper-DSL `return(hash("kind", "top"))` and rewrote the accompanying note (no longer "raw Perl label"). **Audit refinement:** `rule-modes-and-parse-modes.md` was classified CLEAN in `.1` but actually carried a genuine Perl-API block ("## Public option shape", L468–494) — reframed `parse_mode` as a backend-neutral compile option with the Perl block labelled. `blind-calls-and-parser-orchestration.md` confirmed genuinely CLEAN (0 Perl-API signals). `mdbook build` exit 0.
  Commit: `MDBOOK-VARIANT-AGNOSTIC.3 — reframe user-model chapters as variant-agnostic (.spec contract first; Perl = reference backend)`

- ID: `MDBOOK-VARIANT-AGNOSTIC.4`
  Status: `done`
  Goal: Remediate public API chapters — get-and-get-parser.md, descriptor-introspection.md, trace-api.md, plugin-registry.md
  Acceptance: API chapters clearly label Perl as one backend; mention Rust API entry points where applicable
  Verification: `done` — resolved the Open Question in favour of Option A (per-chapter backend frame, not relocation). `get-and-get-parser.md`: added a chapter frame (two entry points + all options are backend-neutral roles; `LinkedSpec::Get`/`get_parser` + coderef are the Perl reference surface); "raw Perl error strings" → "raw host-language error strings". `descriptor-introspection.md`: framed the descriptor shape/fields as a backend-neutral contract while labelling the encoding (`sub { ... }` handler, `qr/.../` regex, coderef) as the Perl reference representation, with a follow-up note under the example. `trace-api.md`: framed the trace *model* (levels, enter/exit scopes, decisions, routing) as backend-neutral while labelling the concrete API + `use LinkedSpec` constants + package-variable/typeglob state surface as Perl-reference; `Data::Dumper` → "dumper-style … (e.g. Perl's `Data::Dumper`)". `plugin-registry.md` (LABEL): added a "Perl reference backend, deprecated" banner clarifying the registry/`.plg`/`PPlugin` machinery is not part of the `.spec` contract and a new backend need not implement it. `mdbook build` exit 0.
  Commit: `MDBOOK-VARIANT-AGNOSTIC.4 — reframe public-api chapters as variant-agnostic (entry points/options/trace/descriptor = contract; Perl = reference surface)`

- ID: `MDBOOK-VARIANT-AGNOSTIC.5`
  Status: `done`
  Goal: Remediate DSL and compiler/architecture chapters — action-model, lowering, helpers, pipeline, state-model, handlers, diagnostics, owner-tree
  Acceptance: DSL chapters use backend-neutral contract language; architecture chapters distinguish concept from Perl implementation
  Verification: `done` — re-grepped all 14 in-scope pages for genuine Perl-API signals (did NOT trust `.1` CLEAN tags blindly); caught 3 leaks the `.1` audit had tagged CLEAN: `fluent-and-block-forms.md` (`ControlFlow.pm` + generated-Perl `do { my $switch_var; my $hit_var; if … }`), `source-boundary-helper-reference.md` BACKTRACK section (`pos($$STRING) = $LSPOS - length $LMATCH` mechanics), and a backend-specific "current byte offset" in `action-model-and-helper-surface.md`. Applied the `.2`/`.3`/`.4` demote-don't-delete convention. **Compiler (4):** `pipeline-overview.md` (frame: 7 stages backend-neutral; `LinkedSpec::Validation`/`Get`/`Runtime::run_get`/`pos($$input_ref)` = Perl reference), `compiled-state-model.md` (frame: state records + fields neutral; `sub {…}`/`qr/.../` = Perl encoding), `generated-handlers-and-dispatch.md` (frame: dispatch model + variant-builder→HandlerIR→backend-emitter seam neutral and = the multi-backend decoupling point; `LinkedRE::or`/`HandlerVariantEmitter.pm`/`JSON::PP`/`pos`/`$BACKEND` = Perl reference), `diagnostics.md` (frame: structured `last_error` contract + owner/stage families neutral; `Get(..., runtime_ctx_ref)` + `LinkedSpec::generated_handler:Top` spelling = Perl reference). **DSL (3):** `actionir-lowering-mental-model.md` (frame: scan→split→canonicalize→lower→emit neutral; `ActionIR::*` owner names/counts = Perl reference; diagram `EmittedPerl`→`Emit`), `fluent-and-block-forms.md`, `source-boundary-helper-reference.md`, `action-model-and-helper-surface.md` ("byte offset"→"cursor position"). **Architecture (1):** `owner-tree.md` — added a "Perl reference implementation" banner (LABEL; content kept per Non-Goals). Confirmed genuinely CLEAN: `declaration-helper-reference` (raw Perl already framed as the legacy form), `capture-marks-and-source-locations`, `value-container-flow-helper-reference`, `values-containers-and-flow-helpers`, `action-and-lifecycle-placement`. `mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0.
  Commit: `MDBOOK-VARIANT-AGNOSTIC.5 — reframe DSL + compiler/architecture chapters as variant-agnostic`

- ID: `MDBOOK-VARIANT-AGNOSTIC.6`
  Status: `pending`
  Goal: Remediate appendix, specs-and-corpora, and development chapters
  Acceptance: Appendix and walkthrough chapters framed for multi-backend readers; development chapters explain Perl is reference
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-VARIANT-AGNOSTIC.7`
  Status: `pending`
  Goal: Final verification — build book, cross-check all chapters, update live docs
  Acceptance: mdBook build succeeds; cross-chapter consistency verified; ROADMAP_V2.md, CHANGES.md, MEMORY.md updated
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MDBOOK-VARIANT-AGNOSTIC.6` | `pending` | Appendix (mostly LABEL) + the 6 corpus walkthroughs (Perl driver blocks) |
| 2 | `MDBOOK-VARIANT-AGNOSTIC.7` | `pending` | Final build + cross-chapter consistency + docs sync |

(`.1`, `.2`, `.3`, `.4`, `.5` complete — removed from frontier.)

## Audit Findings (.1)

`.1` deliverable. Method: deterministic leakage scan over **all 41** `docs/linkedspec-book/src/**.md`
files for Perl-syntax/module/API signals (`::`, `Data::Dumper`, `coderef`, `hashref`, `qr/`,
`=~`, `$@`, `my $/@/%`, `use LinkedSpec`, `sub {`, `.pm`, `.plg`, `PPlugin`, `eval`, …), then
targeted reads to characterise each hit. **Important caveat:** in the DSL/grammar chapters the
`::` and `:AND` matches are overwhelmingly **`.spec` rule-labels and rule-mode suffixes**
(`Token::AND`, `Top::`, `Next::`) — these are DSL syntax, NOT Perl package names, so those
chapters are effectively CLEAN despite high raw counts.

Classification key:
- **CLEAN** — already variant-agnostic (high raw counts are DSL labels / legit "reference impl" mentions).
- **REMEDIATE** — user-facing chapter presents the Perl API/syntax/modules as the primary surface; must reframe (Perl = one clearly-labelled backend example).
- **LABEL** — architecture/development/appendix chapter that legitimately references Perl (per Non-Goals); keep content, add a clear "Perl reference implementation" frame.

| File | Class | Nature of Perl leakage (line refs) | Remediation | Leaf |
| --- | --- | --- | --- | --- |
| `index.md` | CLEAN | none (0 hits) | — | — |
| `SUMMARY.md` | CLEAN | none (0 hits) | — | — |
| `overview/what-is-linkedspec.md` | REMEDIATE | L3 "compiler for Perl"; L27 `LinkedSpec::Get(\$spec)`; L52 "coderef" | Reframe Perl as reference impl; describe Get/get_parser abstractly | `.2` |
| `overview/design-rationale.md` | REMEDIATE(light) | L58 `LinkedSpec.pm is 258 lines … OwnerDispatch` | Drop module name/line count; keep thin-facade principle | `.2` |
| `overview/documentation-layers.md` | CLEAN/LABEL | 1 architecture mention | Acceptable; verify framing | `.2` |
| `overview/project-status.md` | CLEAN/LABEL | Phase/Perl-reference mentions | Acceptable; confirm "Perl = reference" framing | `.2` |
| `user-model/spec-files-and-rule-paragraphs.md` | REMEDIATE(light) | one raw-Perl label example (`return { kind => "top" }`) | Replace with helper-DSL form | `.3` |
| `user-model/worked-spec-walkthrough.md` | REMEDIATE(heavy) | entire walkthrough via Perl API (`use LinkedSpec`, `my $spec`, `LinkedSpec::Get(\$spec)`, `$parser->(\$input)`, `Data::Dumper`, Perl descriptor introspection, `%ctx`) | Rewrite to teach `.spec`+execution model; Perl as one labelled backend block | `.3` |
| `user-model/rule-modes-and-parse-modes.md` | CLEAN | 35 hits = DSL rule-modes (`:AND`, `Token::AND`) | none (false positives) | `.3` |
| `user-model/blind-calls-and-parser-orchestration.md` | CLEAN | 25 hits mostly DSL labels | spot-confirm; minor if any | `.3` |
| `user-model/runtime-context-and-tracing.md` | REMEDIATE(heavy) | Perl hash/ref examples (`my %ctx`, `\%ctx`, `ref($ctx) eq 'HASH'`), `Data::Dumper`, `parser_source_ref => \$…` | Describe context as an abstract object; move Perl specifics to a labelled backend note | `.3` |
| `public-api/get-and-get-parser.md` | REMEDIATE(heavy) | whole chapter is the Perl API (`use LinkedSpec`, `LinkedSpec::Get/get_parser`, `$parser->(\$input)`) | Reframe as "public entry points"; Perl shown as reference backend's surface | `.4` |
| `public-api/descriptor-introspection.md` | REMEDIATE | `LinkedSpec::Get(…, return_descriptor=>1)`, `qr/.../`, `sub {…}` shape | Describe descriptor shape abstractly; Perl as one encoding | `.4` |
| `public-api/trace-api.md` | REMEDIATE(heavy) | Perl API + package vars `$LinkedSpec::DUMP_VERBOSITY`, "typeglob aliasing", `eval` | Abstract the trace API; labelled backend note for Perl state vars | `.4` |
| `public-api/plugin-registry.md` | LABEL | Perl-centric but explicitly DEPRECATED transition surface | Lowest priority; add backend label, keep deprecation note | `.4` |
| `dsl/action-model-and-helper-surface.md` | CLEAN(light) | conceptual "raw Perl" mentions | fine | `.5` |
| `dsl/actionir-lowering-mental-model.md` | REMEDIATE/LABEL | Perl owner names `ActionIR::Scanner/ScannerCore/Contracts (2,110 lines, 158 contracts)` | Frame as reference-impl lowering model or label clearly | `.5` |
| `dsl/declaration-helper-reference.md` | CLEAN | 10 hits = DSL labels | none | `.5` |
| `dsl/fluent-and-block-forms.md` | CLEAN | backend-neutral (excellent) | none | `.5` |
| `dsl/action-and-lifecycle-placement.md` | CLEAN | hits = `Token::AND` DSL labels | none | `.5` |
| `dsl/capture-marks-and-source-locations.md` | CLEAN | `Top::AND` DSL label | none | `.5` |
| `dsl/source-boundary-helper-reference.md` | CLEAN | DSL labels | none | `.5` |
| `dsl/value-container-flow-helper-reference.md` | CLEAN | 12 hits mostly DSL/labels | spot-confirm | `.5` |
| `dsl/values-containers-and-flow-helpers.md` | CLEAN | `Token::` DSL label | none | `.5` |
| `compiler/pipeline-overview.md` | REMEDIATE/LABEL | Perl module names + line counts (`Validation 1,368 lines`, `build_compiled_rule_table(...)`) | Generic stage names; label Perl specifics | `.5` |
| `compiler/compiled-state-model.md` | REMEDIATE(light) | Perl data-structure depiction (`sub {}`, `qr/.../`) | Describe state model abstractly | `.5` |
| `compiler/generated-handlers-and-dispatch.md` | REMEDIATE/LABEL | heavy Perl (`LinkedRE::or($STRING, $$descr{…})`, `HandlerVariantEmitter.pm`, `JSON::PP`, `pos($$STRING)`, `$BACKEND`) | Abstract dispatch concept; label reference-impl handler emitter | `.5` |
| `compiler/diagnostics.md` | REMEDIATE | `my %ctx; LinkedSpec::Get(...)` examples; `handler_source_label => 'LinkedSpec::generated_handler:Top'` | Abstract the API; KEEP structured last_error/label as contract | `.5` |
| `architecture/owner-tree.md` | LABEL | ~500 lines of Perl owner-tree narrative (90 hits, highest volume) | Retitle/banner as "Perl reference-implementation architecture"; keep content (Non-Goal permits) | `.5` |
| `appendix/formal-grammar.md` | CLEAN | hits = DSL labels (`Top::`, `Next::`) | none | `.6` |
| `appendix/helper-contract-catalog.md` | CLEAN | 2 hits; backend-neutral — ready for Rust/Julia/Dart | none (gold standard) | `.6` |
| `appendix/runtime-semantics.md` | LABEL(light) | `LinkedRE::or`, `generated_handler:<label>`; mostly DSL labels | add backend label | `.6` |
| `appendix/backend-handoff.md` | LABEL | "hashref AST" in diagram; chapter is intentionally about backend handoff | natural home for "Perl = reference" framing | `.6` |
| `specs-and-corpora/shipped-specs-and-corpora.md` | REMEDIATE | Perl driver blocks + large `.plg`/package-owner Perl-impl narrative (`HTTP::FileAccess`, `QC::Flow`, `PPlugin->get`) | Keep corpus listing; label/relocate the plugin-owner Perl detail; reframe invocation | `.6` |
| `specs-and-corpora/lispish-spec-walkthrough.md` | REMEDIATE | Perl driver + `perl/Lispish.pm` helper API | Frame as reference backend; abstract invocation | `.6` |
| `specs-and-corpora/ebnf-spec-walkthrough.md` | REMEDIATE | Perl driver; L582 shows a raw-Perl action edge intrinsic to that spec | Reframe driver; explain raw-Perl edge as legacy/compat-surface | `.6` |
| `specs-and-corpora/tablegrep-spec-walkthrough.md` | REMEDIATE | Perl driver + Perl-ish AST dumps (`{type => 'TERM', …}`) | Abstract invocation/output rendering | `.6` |
| `specs-and-corpora/pplugin-spec-walkthrough.md` | REMEDIATE/LABEL | intrinsically about parsing Perl `.plg` files (`eval`, `coderef`, `PPlugin`) | Some Perl inherent to the subject; frame clearly, keep `eval`/compat-surface explanation | `.6` |
| `specs-and-corpora/portmap-spec-walkthrough.md` | REMEDIATE | Perl driver block | Reframe invocation; output abstractly | `.6` |
| `development/local-ci-and-regression.md` | LABEL | legit Perl-repo CI (`perl -c`, `Validation.pm`, `t/phase0_regression.t`) | Acceptable per Non-Goals; minor "Perl reference" framing note | `.6` |
| `development/documentation-workflow.md` | CLEAN | 1 hit | none | `.6` |

Summary: ~18 CLEAN · ~19 REMEDIATE · ~5 LABEL (some files counted in two buckets where a
light remediation plus labelling both apply). Two structural notes for downstream leaves:
1. **The DSL reference section is in better shape than raw counts suggest** — `helper-contract-catalog.md`
   is already the backend-neutral gold standard; most `dsl/*` pages are CLEAN. Leaf `.5`'s real work
   is the **compiler chapters** + the **owner-tree LABEL**, not the helper references.
2. **The 6 corpus walkthroughs all share one pattern**: a `use LinkedSpec; my $parser = …; $parser->(\$input)`
   Perl driver block. Leaf `.6` should reframe these uniformly (one shared "how to run a `.spec` in the
   reference backend" convention) rather than per-file ad hoc.

Corrected scope note: leaf `.1` originally estimated "27 source files"; the book actually has **41**
`src/**.md` files (39 content pages + `SUMMARY.md` + `index.md`). All 41 were audited.

## Decisions

- `2026-06-16`: Created task tree. Audit-first approach to avoid piecemeal edits that create inconsistency. Overview chapters prioritized because they set the reader's mental frame.
- `2026-06-16` (`.1`): Audit complete. Key finding — `::`/`:AND` in DSL/grammar chapters are `.spec`
  rule-labels/modes, not Perl, so those chapters are CLEAN; genuine leakage concentrates in the
  Perl-API user-facing chapters (overview, public-api, two user-model pages, compiler chapters) and
  the 6 corpus walkthroughs. Adopted a 3-way classification (CLEAN / REMEDIATE / LABEL) so that
  architecture/dev/appendix chapters keep their legitimate Perl references behind a clear
  reference-implementation label (per Non-Goals) rather than being stripped.

## Open Questions

- ~~`.4` framing choice: inline "reference backend" callout vs. relocate the Perl API into a
  dedicated subsection?~~ **Resolved (`.4`, 2026-06-16): Option A — per-chapter backend frame.**
  Rationale: consistent with the `.2`/`.3` demote-don't-delete convention; a single chapter-top
  frame labels every Perl block at once; preserves each chapter's value as the Perl reference API
  documentation; avoids the heading/anchor churn and lost pedagogical flow of relocation.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `MDBOOK-VARIANT-AGNOSTIC.1` | deterministic leakage scan over all 41 `src/**.md` files + targeted reads; per-file catalog produced; `scripts/check_memory_architecture.sh` exit 0 | PASS |
| `2026-06-16` | `MDBOOK-VARIANT-AGNOSTIC.2` | remediated 5 overview pages; `mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0 | PASS |
| `2026-06-16` | `MDBOOK-VARIANT-AGNOSTIC.3` | remediated 4 user-model pages (1 confirmed CLEAN); caught a `.1` audit miss (`rule-modes-and-parse-modes.md` had a real Perl-API block); `mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0 | PASS |
| `2026-06-16` | `MDBOOK-VARIANT-AGNOSTIC.4` | remediated all 4 public-api pages (Option A frames); `mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0 | PASS |
| `2026-06-16` | `MDBOOK-VARIANT-AGNOSTIC.5` | re-grepped all 14 in-scope pages (caught 3 leaks `.1` tagged CLEAN); remediated 4 compiler + 4 DSL pages + 1 architecture banner (5 confirmed CLEAN); `mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0 | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MDBOOK-VARIANT-AGNOSTIC.1` | `MDBOOK-VARIANT-AGNOSTIC.1 — complete variant-agnostic audit of the mdBook` | Audit recorded in "## Audit Findings (.1)" |
| `MDBOOK-VARIANT-AGNOSTIC.2` | `MDBOOK-VARIANT-AGNOSTIC.2 — reframe overview chapters as variant-agnostic (.spec = universal contract; Perl = reference backend)` | 5 overview pages remediated; frontier advanced to `.3` |
| `MDBOOK-VARIANT-AGNOSTIC.3` | `MDBOOK-VARIANT-AGNOSTIC.3 — reframe user-model chapters as variant-agnostic (.spec contract first; Perl = reference backend)` | 4 user-model pages remediated (+1 confirmed CLEAN); audit miss corrected; frontier advanced to `.4` |
| `MDBOOK-VARIANT-AGNOSTIC.4` | `MDBOOK-VARIANT-AGNOSTIC.4 — reframe public-api chapters as variant-agnostic (entry points/options/trace/descriptor = contract; Perl = reference surface)` | 4 public-api pages remediated (Option A); Open Question resolved; frontier advanced to `.5` |
| `MDBOOK-VARIANT-AGNOSTIC.5` | `MDBOOK-VARIANT-AGNOSTIC.5 — reframe DSL + compiler/architecture chapters as variant-agnostic` | 4 compiler + 4 DSL pages reframed + `owner-tree` banner; 3 `.1`-CLEAN misses caught; frontier advanced to `.6` |

## Changelog

- `2026-06-16`: Created task tree.
- `2026-06-16`: Completed `.1` — full per-file variant-agnostic audit (41 files), 3-way classification,
  per-leaf remediation map; frontier advanced to `.2`.
- `2026-06-16`: Completed `.2` — reframed all 5 overview pages (`index`, `what-is-linkedspec`,
  `design-rationale`, `documentation-layers`, `project-status`) so the `.spec` file is the one
  universal contract and Perl is the reference backend (Rust = second backend). Fixed a phase
  drift in `project-status` (0–7 → 0–9; added Phase 8 multi-backend handoff + Phase 9 Rust
  variant). `mdbook build` exit 0. Frontier advanced to `.3`.
- `2026-06-16`: Completed `.3` — reframed the user-model chapters (`worked-spec-walkthrough`,
  `runtime-context-and-tracing`, `spec-files-and-rule-paragraphs`, `rule-modes-and-parse-modes`)
  to lead with the `.spec` contract and label runnable blocks as the Perl reference backend's
  surface; replaced the lone raw-host-language payload with helper DSL. Refined the `.1` audit:
  `rule-modes-and-parse-modes` was not fully CLEAN (had a real Perl-API "Public option shape"
  block) — remediated; `blind-calls-and-parser-orchestration` confirmed CLEAN. `mdbook build`
  exit 0. Frontier advanced to `.4`.
- `2026-06-16`: Completed `.4` — reframed the 4 public-api chapters (`get-and-get-parser`,
  `descriptor-introspection`, `trace-api`, `plugin-registry`) with per-chapter backend frames
  (Option A, resolving the Open Question): the two entry points + their options, the descriptor
  shape/fields, and the trace model are backend-neutral contracts, while the concrete
  signatures/encodings/constants/state vars are the Perl reference surface; `plugin-registry`
  got a "Perl reference backend, deprecated — not part of the `.spec` contract" banner.
  `mdbook build` exit 0. Frontier advanced to `.5`.
- `2026-06-16`: Completed `.5` — reframed the DSL + compiler/architecture chapters. Re-grepped
  all 14 in-scope pages rather than trusting the `.1` CLEAN tags, and caught 3 genuine Perl-API
  leaks the audit had mis-tagged CLEAN (`fluent-and-block-forms` `ControlFlow.pm`/`do { … }`,
  `source-boundary-helper-reference` BACKTRACK `pos($$STRING) = …` mechanics, `action-model-and-helper-surface`
  "byte offset"). Compiler 4 (`pipeline-overview`, `compiled-state-model`,
  `generated-handlers-and-dispatch`, `diagnostics`) + DSL 4 (`actionir-lowering-mental-model`,
  `fluent-and-block-forms`, `source-boundary-helper-reference`, `action-model-and-helper-surface`)
  got backend-neutral frames demoting concrete Perl behind a "Perl reference backend" label;
  `architecture/owner-tree` got a "Perl reference implementation" banner (content kept per
  Non-Goals). 5 pages confirmed genuinely CLEAN. `mdbook build` exit 0. Frontier advanced to `.6`.
