# SPEC-LANG-REFERENCE: Complete, variant-agnostic, example-rich book coverage of the entire `.spec` language

## Metadata

- Tree ID: `SPEC-LANG-REFERENCE`
- Status: `done` / `closed`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-17`
- Last updated: `2026-07-08` (`.8` done: final consistency/closeout corrected stale top-rule doctrine
  drift and closed the tree. The June 17 no-regex/two-rule-minimum correction is historical and was superseded by ADR
  `0010` on 2026-06-23: `::` marks the rule entered first; after entry selection, `::` and `:` share
  the same regex/mode/action feature surface. The no-regex top wrapper remains a stream-parser idiom,
  not a validity rule.)
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
  Status: `done` / `closed`
  Goal: Complete + variant-agnostic + example-rich book coverage of the whole `.spec` language
  Children: `.1`–`.7` (done, including `.5.1`–`.5.5`; `.5.3.1`/`.5.4.1` deferred),
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE`.

- ID: `SPEC-LANG-REFERENCE.1`
  Status: `done`
  Goal: Audit — enumerate the complete `.spec` surface from authoritative sources and map the
  Acceptance: a recorded inventory of every `.spec` construct (with its authoritative source),
  Commit: `SPEC-LANG-REFERENCE.1 — audit: full .spec surface inventory + book coverage map; decompose into .2-.8`; prior node reference: `SPEC-LANG-REFERENCE.1` (see Commit Log); retained completion note: Also creates the owning tree + registers it in docs/TASK_TREE.md (ownership-first, folded into the first leaf per repo convention). Audit only — no book change
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.1`.

- ID: `SPEC-LANG-REFERENCE.2`
  Status: `done`
  Goal: Document **regex in `.spec` as a first-class concept** (CRITICAL gap) — a backend must
  Acceptance: a user-facing treatment (new `user-model` chapter and/or expanded
  Commit: `SPEC-LANG-REFERENCE.2 — book: regex as a first-class concept (new user-model chapter) + fix capture-indexing drift`; prior node reference: `SPEC-LANG-REFERENCE.2` (see Commit Log); retained completion note: New `user-model/regex-in-spec.md` + `SUMMARY.md`; `formal-grammar.md §3.1` capture-group/flags expansion; corrected the `entry_group`/`match_group` indexing contradiction in `helper-contract-catalog.md`, `overview/what-is-linkedspec.md`, `formal-grammar.md`, `source-boundary-helper-reference.md`. All facts verified vs `LinkedRE.pm`/`Contracts.pm`/rgx/shipped specs
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.2`.

- ID: `SPEC-LANG-REFERENCE.3`
  Status: `done`
  Goal: Document the **output / return-value shape contract** (CRITICAL gap) in
  Acceptance: a new section defining what a `.spec` parser returns — the top rule's value, the
  Commit: `SPEC-LANG-REFERENCE.3` (see Commit Log)
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.3`.

- ID: `SPEC-LANG-REFERENCE.4`
  Status: `done`
  Goal: Add worked examples for the MAJOR/MEDIUM clarity gaps — grouped shared-code targets
  Acceptance: a worked example of a grouped shared-code action edge (multiple targets, one
  Commit: `SPEC-LANG-REFERENCE.4 — book: grouped action-edge targets (edges chapter) + entry-vs-match divergence (capture chapter)`; prior node reference: `SPEC-LANG-REFERENCE.4` (see Commit Log); retained completion note: Grouped-target section in `action-and-lifecycle-placement.md` (ebnf-grounded) + divergence section in `capture-marks-and-source-locations.md`; both examples compile-verified. Divergence documented at reader-wiring level (top-level I/O entangled with hard accumulator axes — not fabricated)
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.4`.

- ID: `SPEC-LANG-REFERENCE.5`
  Status: `done`
  Goal: Helper-contract catalog **completeness + variant-neutrality + examples** sweep
  Acceptance: confirm every helper family in `perl/LinkedSpec/ActionIR/Contracts.pm` is
  Children: `.5.1` (done), `.5.2` (done), `.5.3`, `.5.4`, `.5.5`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.5`.

- ID: `SPEC-LANG-REFERENCE.5.1`
  Status: `done`
  Goal: Completeness confirmation + variant-neutrality fixes + decomposition
  Acceptance: a read-only completeness audit (every `Contracts.pm` helper id vs the catalog),
  Commit: `SPEC-LANG-REFERENCE.5.1 — helper-catalog audit: 0 completeness gaps, fix 2 variant-neutrality sigil leaks, decompose example work into .5.2-.5.5`; prior node reference: `SPEC-LANG-REFERENCE.5.1` (see Commit Log); retained completion note: Confirmed 0 public-API gaps; fixed `$name`/`$rule_label` sigil leaks in `helper-contract-catalog.md`; split `.5` into per-family example sub-leaves. mdbook build exit 0
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.5.1`.

- ID: `SPEC-LANG-REFERENCE.5.2`
  Status: `done`
  Goal: Worked examples — Scalar + Numeric helper families
  Acceptance: ≥1 compile-verified `.spec` example per family added to the Scalar and Numeric
  Commit: `SPEC-LANG-REFERENCE.5.2 — book: compile-verified worked examples for all Scalar + Numeric helpers (helper-contract-catalog §2/§5)`; prior node reference: `SPEC-LANG-REFERENCE.5.2` (see Commit Log); retained completion note: 35 helpers, each run-verified through `LinkedSpec::Get` against the oracle; shared runnable-spec preamble; condition-only note for `is_defined`/`is_undefined`; array-form reducers via explicit `array(...)`. Found §5.5 drift → new leaf `.9`. mdbook build exit 0
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.5.2`.

- ID: `SPEC-LANG-REFERENCE.5.3`
  Status: `done`
  Goal: Worked examples — Array helper family (largest, ~33 helpers)
  Acceptance: ≥1 compile-verified example for the Array family plus several for high-frequency
  Commit: `SPEC-LANG-REFERENCE.5.3 - add Array helper worked examples`; prior node reference: `SPEC-LANG-REFERENCE.5.3` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.5.3 — add Array helper worked examples`; retained completion note: `helper-contract-catalog.md` now has verified Array examples for constructor/copy/splice, selectors, edge slices, ordering, membership, split, pipelines, mutations, receiver chains, and array-tree traversal. KM fact `array-helper-return-shape-caveats` records split/pipeline shape-sensitive caveats; optional normalization deferred to `.5.3.1`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.5.3`.

- ID: `SPEC-LANG-REFERENCE.5.3.1`
  Status: `deferred`
  Goal: Optional implementation/parity follow-up for Array helper return-shape caveats discovered during
  `.5.3`: compact `I.return(split(...))` currently emits the old tagged shorthand shape on the Perl
  reference, direct `return(split_each(array(items), ...))` is shape-sensitive, and not every array
  pipeline-to-pure receiver continuation is portable.
  Acceptance: if activated, decide whether to keep these as documented current-backend caveats or normalize
  Perl/Rust behavior with focused regression locks, cross-variant oracle review, mdBook/KM updates, and an
  explicit implementation owner.
  Verification: Deferred — `.5.3` documents stable forms and records the caveat in KM; no engine behavior
  change is authorized in this documentation leaf.
  Commit: `deferred`

- ID: `SPEC-LANG-REFERENCE.5.4`
  Status: `done`
  Goal: Worked examples — Hash + Control Flow helper families
  Acceptance: ≥1 compile-verified example per family (Hash + Control Flow), built through
  Commit: `SPEC-LANG-REFERENCE.5.4 - add Hash and Control Flow worked examples`; prior node reference: `SPEC-LANG-REFERENCE.5.4` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.5.4 — add Hash and Control Flow worked examples`; retained completion note: `helper-contract-catalog.md` now has verified Hash examples for constructor/copy/splice, pure/mutating updates, sorted views, receiver chains, and hash-tree traversal, plus Control Flow examples for branch forms, `switch`, `while`, `next`, `return`, `return_undef`, and descriptor-verified `exit_now`. KM fact `hash-helper-odd-arity-current-behavior` records the direct odd-arity `hash(...)` caveat; optional normalization deferred to `.5.4.1`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.5.4`.

- ID: `SPEC-LANG-REFERENCE.5.4.1`
  Status: `deferred`
  Goal: Optional implementation/parity follow-up for direct odd-arity Hash helper constructor behavior found
  during `.5.4`: decide whether `hash("a", 1, "missing")` should remain a documented unsupported current
  shape or normalize to the same trailing-`undef` behavior as explicit `hash("a", 1, "missing", undef)` /
  list-context `hash(flat_array(...))`.
  Acceptance: if activated, make the policy explicit, add focused Perl/Rust regression locks, update the mdBook
  and Knowledge Map, and ensure direct constructor, list-splice, and hash-literal examples are aligned.
  Verification: Deferred — `.5.4` documents the current stable forms and records the caveat in KM; no engine
  behavior change is authorized in this documentation leaf.
  Commit: `deferred`

- ID: `SPEC-LANG-REFERENCE.5.5`
  Status: `done`
  Goal: Worked examples — Declaration, Capture/Mark, Entry/Match, Input, Call families
  Acceptance: ≥1 compile-verified example per remaining family, built through `LinkedSpec::Get`;
  Commit: `SPEC-LANG-REFERENCE.5.5 - add remaining helper-family worked examples`; prior node reference: `SPEC-LANG-REFERENCE.5.5` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.5.5 — add remaining helper-family worked examples`; retained completion note: `helper-contract-catalog.md` now has verified Declaration, Capture/Mark, Entry/Match, Input, and Call examples. Corrected stale entry-vs-match examples in the source-boundary chapters to the verified ordered-child shape and added KM fact `entry-match-divergence-verified-shape`. This closes the helper-catalog sweep `.5`; frontier advances to `.6`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.5.5`.

- ID: `SPEC-LANG-REFERENCE.6`
  Status: `done`
  Goal: Capture/mark cross-example + any remaining thin spots
  Acceptance: one worked rule exercising the anonymous + named capture/mark families together
  Commit: `SPEC-LANG-REFERENCE.6 - add capture/mark marker cross-example`; prior node reference: `SPEC-LANG-REFERENCE.6` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.6 — add capture/mark marker cross-example`; retained completion note: `source-boundary-helper-reference.md` and `action-and-lifecycle-placement.md` now include a verified marker-form cross-example for `@capture_slice`, `@mark(body_start)`, `mark_match_start(close_start)`, `capture_slice()`, `capture_from(...)`, and `capture_between(...)`. KM fact `split-boundary-marker-action-timing` records marker visibility timing; frontier advances to `.7`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.6`.

- ID: `SPEC-LANG-REFERENCE.7`
  Status: `done`
  Goal: Knowledge Map fact cards for the durable `.spec`-language subjects
  Acceptance: KM cards (`docs/knowledge/<id>.md`, with `answers:` front-matter) for the key
  Commit: `SPEC-LANG-REFERENCE.7 - add spec-language Knowledge Map cards`; prior node reference: `SPEC-LANG-REFERENCE.7` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.7 — add spec-language Knowledge Map cards`; retained completion note: Added canonical KM fact cards for output/return shape, regex backend feature contract, rule-mode semantics, lifecycle/`retv` order, and capture/mark taxonomy; extended `spec-edge-syntax-contract` for action-vs-blind dispatch retrieval. KM gate passes; frontier advances to `.8`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.7`.

- ID: `SPEC-LANG-REFERENCE.9`
  Status: `done`
  Goal: Correct the drifted "verified" output in `runtime-semantics.md` §5.5 (Pair example)
  Acceptance: change the §5.5 third example so its documented output matches a **re-verified**
  Commit: `SPEC-LANG-REFERENCE.9 — book: fix drifted §5.5 Pair example output (AND-[0] self-edge returns [] not the tagged array)`; prior node reference: `SPEC-LANG-REFERENCE.9` (see Commit Log); retained completion note: Corrected the §5.5 Pair example to the verified OR self-ref `-> Pair` form (+ §5.7 cross-ref). Surfaced a SYSTEMIC variant across chapters → new leaf `.10` (blocked on a user decision). mdbook build exit 0
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.9`.

- ID: `SPEC-LANG-REFERENCE.10`
  Status: `done`
  Goal: **HISTORICAL CORRECTION (2026-06-17, superseded in doctrine by ADR `0010`)** — Remediate
  Children: `.10.1` (done — investigation; its verdict is now **superseded** — see note), `.10.2`
  Commit: `SPEC-LANG-REFERENCE.10 — correction: top rule has no regex; .5.2/.9 examples are structurally invalid (not an engine bug); retract .10.1, plan remediation (.10.3-.5)`; table label: `SPEC-LANG-REFERENCE.10` (correction); retained completion note: User-established structural invariant (top `::` rule no regex; valid spec ≥2 rules), verified vs Core.pm/RuleIR.pm + 20-spec audit. Deleted the wrong KM card, added `spec-top-rule-no-regex-two-rule-minimum.md` with the proven 2-rule idiom. Superseded `.10.1` verdict + `.10.2`; added remediation leaves. NO Perl change. Repo handoff-ready; fresh session recommended
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10`.

- ID: `SPEC-LANG-REFERENCE.10.1`
  Status: `done`
  Goal: Read-only root-cause investigation — is the single-slot-AND-self-edge-`return`→`[]`
  Commit: `SPEC-LANG-REFERENCE.10.1 — investigation: single-slot AND drops its edge return ([]) is a Perl-reference regression, not intended (KM card + verdict)`; prior node reference: `SPEC-LANG-REFERENCE.10.1` (investigation), corrected by the `.10` remediation commit.; retained completion note: Read-only root-cause investigation; VERDICT = accidental regression in `AND_SINGLE_ACODE` emitter (missing `push`); triple-verified vs source/git/card; KM card `and-single-acode-edge-return-dropped.md`. `.10.2` fix blocked on a user direction decision. No code/book change. **(Verdict later SUPERSEDED — see `.10` correction commit.)**
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.1`.

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
  Acceptance: replace the invalid `Demo:: /regex/ -> Demo { return(<expr>) }` scaffold (regex on the
  Commit: `SPEC-LANG-REFERENCE.10.3 — book: redo Scalar+Numeric helper examples + preambles with the valid 2-rule idiom (entry_group; re-verified outputs)`; prior node reference: `SPEC-LANG-REFERENCE.10.3` (see Commit Log); retained completion note: Rewrote both `helper-contract-catalog.md` worked-examples preambles + all 33 examples to the top-entry-rule + normal-rule form reading `entry_group(N)`; every output re-derived through `LinkedSpec::Get`; outputs are the one-element accumulator snapshot. `mdbook build` exit 0
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.3`.

- ID: `SPEC-LANG-REFERENCE.10.4`
  Status: `superseded`
  Goal: ~~Redo the `.9` §5.5 `runtime-semantics.md` Pair example with valid structure~~ —
  Commit: n/a
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.4`.

- ID: `SPEC-LANG-REFERENCE.10.5`
  Status: `done`
  Goal: **SCORCH THE WHOLE BOOK** (user directive 2026-06-17 — "the book shall not mislead; only
  Children: `.10.5.1` (done — audit + decomposition), `.10.5.2`–`.10.5.4` (done per-file fixes),
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5`.

- ID: `SPEC-LANG-REFERENCE.10.5.1`
  Status: `done`
  Goal: Exhaustive read-only audit of every `.spec` snippet in `docs/linkedspec-book/src/**` +
  Acceptance: every `.spec` block classified (A: regex-on-`::` / single-rule doctrine violation; B:
  Commit: `SPEC-LANG-REFERENCE.10.5.1` (see Commit Log)
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.1`.

- ID: `SPEC-LANG-REFERENCE.10.5.2`
  Status: `done`
  Goal: Fix `overview/what-is-linkedspec.md` minimal key/value example (`Top::AND+ /…/ -> Top[0]`,
  Acceptance: replaced with a top `::` entry rule (no regex) + normal `:` rule carrying the regex;
  Commit: `SPEC-LANG-REFERENCE.10.5.2 — book: fix what-is-linkedspec.md minimal kv example → verified 2-rule idiom`; prior node reference: `SPEC-LANG-REFERENCE.10.5.2` (see Commit Log); retained completion note: Replaced the single-rule `Top::AND+ /…/ -> Top[0]` (regex-on-top → compile-fail/`null`) with `top:: -> pair .push` / `LX{return(array_copy(a(top)))}` + `pair: /(\w+)=(\w+)/ I{return(hash(…entry_group(0/1)…))}`; book-extracted run → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`; `mdbook build` exit 0
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.2`.

- ID: `SPEC-LANG-REFERENCE.10.5.3`
  Status: `done`
  Goal: Fix `public-api/get-and-get-parser.md` "minimal example" (`Top::AND /foo/ -> Top[0]` → `[]`)
  Acceptance: 2-rule form, re-verified output; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.3 — book: fix get-and-get-parser.md minimal Get example → verified 2-rule idiom`; prior node reference: `SPEC-LANG-REFERENCE.10.5.3` (see Commit Log); retained completion note: Replaced inline `Top::AND /foo/ -> Top[0] {…match_text()…}` (→ `[]`) with `top:: -> word .push` / `LX{return(array_copy(a(top)))}` + `word: /foo/ I{return(hash("kind","top","text",entry_text()))}`; book-extracted run → `[{"kind":"top","text":"foo"}]`; `match_text()`→`null` trap caught; `mdbook build` exit 0
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.3`.

- ID: `SPEC-LANG-REFERENCE.10.5.4`
  Status: `done`
  Goal: Fix `user-model/worked-spec-walkthrough.md` — convert the chapter's central single-rule
  Acceptance: central example + all downstream claimed outputs re-verified through `LinkedSpec::Get`;
  Commit: `SPEC-LANG-REFERENCE.10.5.4 — book: fix worked-spec-walkthrough.md → verified 2-rule idiom; re-derive whole-chapter outputs; drop declare/assign`; prior node reference: `SPEC-LANG-REFERENCE.10.5.4` (see Commit Log); retained completion note: Central single-rule `Pair::AND -> Pair[0]` (→`[]`, claimed `{kind:pair,…}`) → `Top::` entry + `Pair:` matcher; every claimed I/O re-derived via `LinkedSpec::Get`; output corrected single-hash→one-element list; `match_group`→`entry_group`; `ctx{top_rule}` Pair→Top; declare()/assign() removed from the advanced sketch per the user terse-format pivot. `mdbook build` exit 0. **Whole-book scorch PAUSED here — user activated `SPEC-FORMAT-TERSE`.**
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.4`.

- ID: `SPEC-LANG-REFERENCE.10.5.4.1`
  Status: `done`
  Goal: Reactivate the paused whole-book scorch at the user's 2026-07-08 directive, without bundling
  Acceptance: central task-tree index, this task file, memory pointer, live status, changelog, and
  Commit: `SPEC-LANG-REFERENCE.10.5.4.1 - reactivate book scorch`; prior node reference: `SPEC-LANG-REFERENCE.10.5.4.1` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.4.1 — reactivate book scorch`; retained completion note: User reactivated `SPEC-LANG-REFERENCE`; durable coordination records now point to `.10.5.5` as the next book-content leaf. Metadata-only; no mdBook source or parser/runtime behavior changed
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.4.1`.

- ID: `SPEC-LANG-REFERENCE.10.5.5`
  Status: `done`
  Goal: Fix `user-model/spec-files-and-rule-paragraphs.md` — the malformed label-in-block example
  Acceptance: valid forms, re-verified; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.5 - fix spec file paragraph examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.5` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.5 — fix spec file paragraph examples`; retained completion note: `spec-files-and-rule-paragraphs.md` runnable examples now use the verified 2-rule idiom; the malformed bare `label:` block is replaced with valid quoted `"label:"` helper content plus the exact validation-error note. Four snippets verified through `LinkedSpec::Get`; mdBook build exit 0; Knowledge fact card added
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.5`.

- ID: `SPEC-LANG-REFERENCE.10.5.6`
  Status: `done`
  Goal: Fix `user-model/rule-modes-and-parse-modes.md` — convert all ~20 mode fragments off
  Acceptance: no example puts a regex on a `::` rule; framing corrected; representative examples
  Commit: `SPEC-LANG-REFERENCE.10.5.6 - fix rule mode and parse mode examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.6` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.6 — fix rule mode and parse mode examples`; retained completion note: `rule-modes-and-parse-modes.md` regex-owning mode examples now use single-colon labels, the `::` framing teaches no-regex entry/dispatcher usage, and `Top:: /foo/` parse-mode snippets are replaced with the verified 2-rule wrapper. Runtime probes and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.6`.

- ID: `SPEC-LANG-REFERENCE.10.5.7`
  Status: `done`
  Goal: Fix `user-model/regex-in-spec.md` — convert the `::`-with-regex fragments (`Top::`, `Pair::AND`,
  Acceptance: doctrine-valid examples, re-verified; capture-indexing facts intact; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.7 - fix regex chapter examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.7` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.7 — fix regex chapter examples`; retained completion note: `regex-in-spec.md` examples now use no-regex `Top::` wrappers plus single-colon regex-bearing rules. Numbered/named capture and compaction teaching is preserved with `entry_group` / `entry_named`; runtime probes and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.7`.

- ID: `SPEC-LANG-REFERENCE.10.5.8`
  Status: `done`
  Goal: Audit + fix `user-model/blind-calls-and-parser-orchestration.md` (blind-call `::` rules carry
  Acceptance: any regex-on-`::` removed; negative examples clearly marked; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.8 - fix blind-call orchestration examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.8` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.8 — fix blind-call orchestration examples`; retained completion note: `blind-calls-and-parser-orchestration.md` keeps no-regex blind-call `::` wrappers, converts regex-owning action-edge examples to single-colon labels, and clarifies the mixed-edge negative example. Scan/probe and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.8`.

- ID: `SPEC-LANG-REFERENCE.10.5.9`
  Status: `done`
  Goal: Fix `dsl/action-and-lifecycle-placement.md` worked examples (`Token::AND`, `List::AND`,
  Acceptance: no regex on `::`; representative examples re-verified; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.9 - fix action and lifecycle placement examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.9` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.9 — fix action and lifecycle placement examples`; retained completion note: `action-and-lifecycle-placement.md` now separates entry-match `I`/`entry_*` from local-slot action `match_*`, removes regex-on-`::` examples, corrects hash initialization, and records the Perl lifecycle handler drift caveat
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.9`.

- ID: `SPEC-LANG-REFERENCE.10.5.10`
  Status: `done`
  Goal: Fix `dsl/capture-marks-and-source-locations.md` worked examples (`Top::AND`, `Call::AND`/
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.10 - fix capture and entry-match examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.10` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.10 — fix capture and entry-match examples`; retained completion note: `capture-marks-and-source-locations.md` now uses a no-regex `Top::` wrapper plus normal `Body:` delimiter rule for the `capture_slice()` example, and a blind-call `Top::AND => Call` wrapper plus normal `Call:`/`Inner:` rules for entry-vs-match divergence. Seek-mode capture probe returns `[{"body":"body"}]`; blind-call probe returns `greet` vs `world`; Knowledge fact `perl-capture-slice-delimiter-seek-boundary` records the consume-mode caveat
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.10`.

- ID: `SPEC-LANG-REFERENCE.10.5.11`
  Status: `done`
  Goal: Fix `dsl/declaration-helper-reference.md` worked examples (`Token::AND`, `List::AND`) → 2-rule idiom
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.11 - fix declaration helper examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.11` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.11 — fix declaration helper examples`; retained completion note: `declaration-helper-reference.md` now uses no-regex wrappers for accumulator and metadata examples: `List::` owns aggregate state while `Item:` owns the matcher, and `Top::` dispatches to regex-owning `Token:`. Runtime probes return the documented two-item list and token metadata outputs; page scan and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.11`.

- ID: `SPEC-LANG-REFERENCE.10.5.12`
  Status: `done`
  Goal: Fix `dsl/source-boundary-helper-reference.md` worked examples (`Tuple::AND`, `Block::AND`,
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.12 - fix source-boundary examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.12` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.12 — fix source-boundary examples`; retained completion note: `source-boundary-helper-reference.md` now uses no-regex `Top::AND` blind-call wrappers plus normal regex-owning rules for Tuple, Block, Paren, Pair, Body, AtEnd, and entry-vs-match examples. Seven focused probes return the documented source-boundary outputs; page scan and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.12`.

- ID: `SPEC-LANG-REFERENCE.10.5.13`
  Status: `done`
  Goal: Fix `dsl/value-container-flow-helper-reference.md` worked examples (`Token::AND`, `Node::AND`,
  Acceptance: doctrine-valid + re-verified; `mdbook build` exit 0.
  Commit: `SPEC-LANG-REFERENCE.10.5.13 - fix value-container flow examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.13` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.13 — fix value-container flow examples`; retained completion note: `value-container-flow-helper-reference.md` now uses no-regex wrappers or entry rules for Token, FieldList, Node, Sequence, and Kind examples, with regex slots moved to normal matcher rules. Five focused probes return the documented token, field-list, node-normalization, sequence head/tail, and switch-classification outputs; page scan and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.13`.

- ID: `SPEC-LANG-REFERENCE.10.5.14`
  Status: `done`
  Goal: Fix the remaining DSL pages — `dsl/values-containers-and-flow-helpers.md` (`Token::`),
  Acceptance: no regex on `::`; complete worked examples re-verified; isolated helper-statement
  Commit: `SPEC-LANG-REFERENCE.10.5.14 - fix remaining DSL examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.14` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.14 — fix remaining DSL examples`; retained completion note: `values-containers-and-flow-helpers.md`, `action-model-and-helper-surface.md`, and `fluent-and-block-forms.md` now avoid regex-bearing `::` examples for Token, Value, and Items. `actionir-lowering-mental-model.md` audited clean as helper/pipeline fragments only. Focused Token, Value, and Items probes pass; four-page scan and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.14`.

- ID: `SPEC-LANG-REFERENCE.10.5.15`
  Status: `done`
  Goal: Fix `appendix/formal-grammar.md` — §1 paragraph-model example (`Top:: /a/ -> Next` + `Next:: /b/`)
  Acceptance: doctrine-valid + compile/run-verified (or clearly-marked grammar meta-notation);
  Commit: `SPEC-LANG-REFERENCE.10.5.15 - fix formal grammar examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.15` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.15 — fix formal grammar examples`; retained completion note: `formal-grammar.md` §1 and §12 now use no-regex top rules plus normal regex-owning matcher rules. The complete example defines every dispatch target and verifies DemoParser, SecondChild, and ThirdChild outputs; appendix scan and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.15`.

- ID: `SPEC-LANG-REFERENCE.10.5.16`
  Status: `done`
  Goal: Fix `appendix/runtime-semantics.md` §5.5/§5.6 examples (the three `Top::`/`Pair::` regex-on-top
  Acceptance: doctrine-valid + re-verified outputs; `.10.4` marked superseded-by-`.10.5.16`;
  Commit: `SPEC-LANG-REFERENCE.10.5.16 - fix runtime semantics examples`; prior node reference: `SPEC-LANG-REFERENCE.10.5.16` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.16 — fix runtime semantics examples`; retained completion note: `runtime-semantics.md` §5.5/§5.6 now uses no-regex `Top::` wrappers plus normal regex-owning `Done:`, `Pair:`, `object:`, and `manifest:` rules. The folded `.10.4` Pair target now returns the verified `entry_group` tagged array through `Top`; five focused outputs, page scan, and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.16`.

- ID: `SPEC-LANG-REFERENCE.10.5.17`
  Status: `done`
  Goal: Fix `specs-and-corpora/tablegrep-spec-walkthrough.md` output drifts — `sens` is `=` not `=~`
  Acceptance: claimed outputs corrected to verified `LinkedSpec::Get` runs of `specs/tablegrep.spec`;
  Commit: `SPEC-LANG-REFERENCE.10.5.17 - fix tablegrep walkthrough outputs`; prior node reference: `SPEC-LANG-REFERENCE.10.5.17` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.17 — fix tablegrep walkthrough outputs`; retained completion note: `tablegrep-spec-walkthrough.md` now shows verified JSON outputs for the simple term and grouped expression (`sens` is `=`), and its descriptor helper list matches the live spec. Parser probes, descriptor metadata probe, and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.17`.

- ID: `SPEC-LANG-REFERENCE.10.5.18`
  Status: `done`
  Goal: Fix `specs-and-corpora/portmap-spec-walkthrough.md` — the 5 output-shape examples claim flat
  Acceptance: every claimed output corrected to verified `specs/portmap.spec` runs (and any wrong
  Commit: `SPEC-LANG-REFERENCE.10.5.18 - verify portmap walkthrough outputs`; prior node reference: `SPEC-LANG-REFERENCE.10.5.18` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.18 — verify portmap walkthrough outputs`; retained completion note: `portmap-spec-walkthrough.md`'s five output-shape examples were rechecked against `LinkedSpec::get_parser('portmap')`; the current page already matches the live nested JSON for bare, bit, slice, constant, and concatenation cases. Parser probes and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.18`.

- ID: `SPEC-LANG-REFERENCE.10.5.19`
  Status: `done`
  Goal: Finalize the scorch — whole-book re-grep confirming **zero** regex-on-`::` example rules
  Acceptance: clean whole-book sweep; planned page-fix children `done`/`superseded`; any follow-up drift
  Commit: `SPEC-LANG-REFERENCE.10.5.19 - finalize book scorch`; prior node reference: `SPEC-LANG-REFERENCE.10.5.19` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.19 — finalize book scorch`; retained completion note: Whole-book closeout scans found and fixed the remaining regex-on-`::` mdBook examples in `spec-files-and-rule-paragraphs.md`, `helper-contract-catalog.md`, and `compiler/pipeline-overview.md`. Follow-up scans return no matches; focused parser probes and mdBook build pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.19`.

- ID: `SPEC-LANG-REFERENCE.10.5.20`
  Status: `done`
  Goal: Resolve the lifecycle handler-shape drift found during `.10.5.9`: current Perl generated handlers
  Acceptance: decide whether this remains a documented Perl-reference caveat or becomes a backend/runtime
  Commit: `SPEC-LANG-REFERENCE.10.5.20 - document lifecycle drift policy`; prior node reference: `SPEC-LANG-REFERENCE.10.5.20` (see Commit Log); table reference: `SPEC-LANG-REFERENCE.10.5.20 — document lifecycle drift policy`; retained completion note: Lifecycle final-value/direct-`E` drift resolved as a documented current Perl-reference caveat under ADR `0020`; `runtime-semantics.md` teaches explicit `return(...)` as the portable return channel; KM fact updated; focused probes and gates pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.5.20`.

- ID: `SPEC-LANG-REFERENCE.10.6`
  Status: `done`
  Goal: Correct the durable record — retract the inaccurate "a regex-on-top / single-rule spec
  Acceptance: rewrite the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first (verified
  Commit: `SPEC-LANG-REFERENCE.10.6 — record: retract the inaccurate "regex-on-top → []" premise; reframe the .10 rationale as the 2-rule authoring doctrine`; prior node reference: `SPEC-LANG-REFERENCE.10.6` (see Commit Log); retained completion note: Rewrote the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first + superseding Decision + record-framing fixes; doctrine and `.10.3` unchanged. No Perl/book-example change
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.10.6`.

- ID: `SPEC-LANG-REFERENCE.8`
  Status: `done`
  Goal: Finalize — whole-book consistency + close, including the current top-rule doctrine
  Acceptance: full `mdbook build` exit 0; a cross-chapter consistency pass confirming every
  Commit: `SPEC-LANG-REFERENCE.8 - correct top-rule doctrine drift and close language reference`; table reference: `SPEC-LANG-REFERENCE.8 — correct top-rule doctrine drift and close language reference`; retained completion note: Reaffirmed ADR `0010` as current doctrine (`::` marks the entered-first rule; `::`/`:` share the feature surface after entry selection), converted the old no-regex/two-rule-minimum card into a superseded redirect, aligned mdBook/toolbox/task/live docs, and closed the language-reference tree. Focused parity probes, mdBook, KM, memory, task-tree metadata, doctrine, and whitespace gates pass
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.27`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree SPEC-LANG-REFERENCE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.27 --id SPEC-LANG-REFERENCE.8`.

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
| — | `SPEC-LANG-REFERENCE.5.3` | `done` | Array helper worked examples added 2026-07-08; split/pipeline return-shape caveats documented and tracked |
| — | `SPEC-LANG-REFERENCE.5.3.1` | `deferred` | optional implementation/parity follow-up for split/pipeline return-shape caveats; not PNT-active unless explicitly activated |
| — | `SPEC-LANG-REFERENCE.5.4` | `done` | Hash + Control Flow helper worked examples added 2026-07-08; direct odd-arity hash constructor caveat documented and tracked |
| — | `SPEC-LANG-REFERENCE.5.4.1` | `deferred` | optional implementation/parity follow-up for direct odd-arity `hash(...)`; not PNT-active unless explicitly activated |
| — | `SPEC-LANG-REFERENCE.5.5` | `done` | worked examples added for Declaration, Capture/Mark, Entry/Match, Input, and Call families; helper-catalog sweep `.5` closes (2026-07-08) |
| 11 | `SPEC-LANG-REFERENCE.6` | `done` | capture/mark cross-example + marker-placement thin spots fixed 2026-07-08 |
| 12 | `SPEC-LANG-REFERENCE.7` | `done` | durable `.spec`-language KM fact cards completed 2026-07-08 |
| — | `SPEC-LANG-REFERENCE.8` | `done` | final consistency/closeout completed 2026-07-08; stale top-rule doctrine drift corrected to ADR `0010`, gates pass, tree closed |

## Decisions

- **`2026-07-08` — TOP-RULE DOCTRINE DRIFT CORRECTION (`.8`).**
  User reminder during closeout re-established the current doctrine chronology: the June 17
  "top `::` rule has no regex / valid spec needs at least two rules" correction was superseded by
  ADR `0010` on 2026-06-23. Current doctrine: `::` is the entry marker for the rule entered first;
  after entry selection, `::` and `:` rules have the same regex, mode, edge, lifecycle, and recursion
  feature surface. A complete `.spec` still needs a `::` entry marker so there is a default start rule,
  but a regex-bearing `::` rule is valid. The no-regex top wrapper remains a useful stream-of-records
  idiom, not a validity minimum. `.8` owns correcting current-facing task/KM/book/toolbox wording and
  preserving the old card as a superseded historical redirect.

- **`2026-07-08` — DURABLE SPEC-LANGUAGE KM RETRIEVAL (`.7`).**
  The `.spec` language reference now has canonical Knowledge Map cards for the audit-required
  durable subjects: output/return shape, regex backend feature set, rule-mode semantics, lifecycle
  order plus `retv`, action-vs-blind dispatch, and capture/mark taxonomy. Existing narrower
  backend/parity cards remain as related links rather than replacement homes. `spec-edge-syntax-contract`
  was extended instead of duplicated because it already owns the edge syntax contract.

- **`2026-07-08` — MARKER-FORM CAPTURE/MARK TIMING (`.6`).**
  The public capture/mark cross-example uses a verified seek-mode delimiter shape: an opener action
  is followed by `@capture_slice` and `@mark(body_start)`, and a later closing-delimiter action reads
  the same body span through `capture_slice()`, `capture_from(body_start)`, and
  `capture_between(body_start, close_start)` after calling `mark_match_start(close_start)`. For exact
  timing inside an action or lifecycle block, public examples now prefer helper-call forms such as
  `start_capture_slice()` and `mark_here(...)`. KM fact `split-boundary-marker-action-timing` records
  the generated-source/root-cause evidence so future sessions do not re-derive marker visibility.

- **`2026-07-08` — HASH + CONTROL FLOW EXAMPLES + HASH CONSTRUCTOR CAVEAT (`.5.4`).**
  The Hash and Control Flow helper catalog now documents verified current forms: hash constructor/copy/splice,
  pure and mutating hash updates, sorted views, receiver chains, hash-tree traversal, inline/marker/attached
  branches, `switch`, `while`, `next`, `return`, and `return_undef`. `exit_now(2)` is documented from descriptor
  metadata rather than run, because running it intentionally exits the parser process. During verification,
  TOOLBOX probes found direct odd-arity `hash("a", 1, "missing")` lowers to an unsupported-helper sentinel and
  returns `undef` on the current Perl reference; explicit `undef` and list-splice forms are the documented
  current forms. KM fact `hash-helper-odd-arity-current-behavior` records the caveat, and optional behavior
  normalization is deferred to `.5.4.1`.

- **`2026-07-08` — ARRAY HELPER EXAMPLES + SHAPE-SENSITIVE RETURN CAVEATS (`.5.3`).**
  The Array helper catalog now documents verified current forms: pure array values, receiver chains,
  statement/mutation pipelines, and array-tree traversal outputs all use complete two-rule examples or
  compact examples plugged into the verified `demo::` scaffold. During verification, TOOLBOX probes found
  shape-sensitive current Perl behavior around compact `I.return(split(...))`, direct returns of named-array
  pipeline helpers, and unsupported pipeline-to-pure receiver continuations. The book documents stable
  receiver/block/assignment forms and KM fact `array-helper-return-shape-caveats` records the caveat. Optional
  behavior normalization is deferred to `.5.3.1` and is not authorized by this documentation leaf.

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
  rule was recorded here as a **doctrine** problem, not an engine error (historical note: ADR `0010`
  later superseded that doctrine and made `::`/`:` feature parity current).
  (2) The `Rule::AND /regex/ -> Rule[N] { return(...) }` shape (AND mode + slot self-edge) drops its
  edge return → `[]` (the `.10.1` `_emit_and_single_acode_handler` finding) — so the book's pervasive
  worked-example idiom both violates the doctrine **and** fails to surface its `return` value. The fix
  idiom is the verified `demo:: -> child .push` / `LX{return(array_copy(a(demo)))}` + `child : /re/
  I.return(<expr reading entry_group(N)>)` form.

- **`2026-06-17` — HISTORICAL CORRECTION (superseded by ADR `0010` as validity doctrine; still
  supersedes the `.10.1` engine-bug verdict).** This entry records the old correction for provenance.
  Current doctrine is the June 23 ADR `0010` model: `::` marks the rule entered first, and after entry
  selection `::` and `:` share the same feature surface. The historical June 17 correction said that
  the top `::` rule should be a no-regex entry/dispatch loop, so a valid spec needed a top wrapper plus
  at least one normal matcher rule. That validity claim is no longer current. Its original cited basis
  was `BootstrapSpec/Core.pm:414` (label line is anchored
  `\A LABEL (::|:) MODE \z` — no regex on the label) + `:417` (`::`→`_INITIAL`), `RuleIR.pm:193-195`
  (`_INITIAL`→`top_rule`), and an audit of all 20 `specs/*.spec` (every top rule `regex_on_top=no`).
  The historical conclusion was that regex-on-top or single-rule specs were malformed and should be
  rewritten to the two-rule idiom. That conclusion is superseded as a validity claim, but the
  remediation still produced valid stream-parser examples. The Perl reference remained untouched
  ([[feedback_do-not-fix-reference-engine]]). Consequence then: `.5.2` (35 examples + the catalog
  preamble) and `.9` (§5.5) were redone in `.10.3`/`.10.4`; other chapters were audited in `.10.5`.
  KM card:
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

- **`2026-06-17` — `.10.6` retraction (historical; later superseded further by ADR `0010`).**
  This retracted the false "`regex-on-top -> []`" mechanism but still kept the then-active no-regex
  authoring doctrine. ADR `0010` later superseded that doctrine too. Ground-truthing the CORRECTION's
  premise via
  `LinkedSpec::Get` showed that a regex on a `::` rule with an OR self-ref / cross-rule **action edge
  does run and return its value** — the old `.5.2`/`.9` examples returned the documented values, and
  the §5.5 frozen oracle fixtures (`Top:: /x/ -> Done {…}`) work. So the sub-claim "a regex-on-top /
  single-rule spec silently returns `[]`" was **wrong** and is retracted; the only shape returning
  `[]` is the explicit `::AND … -> Rule[N] { return(...) }` form (the `.10.1` finding). At that time
  this did not change the no-regex authoring doctrine; as of ADR `0010` and `.8`, that doctrine is
  historical and the two-rule wrapper is only a stream-parser idiom. KM card
  `spec-top-rule-no-regex-two-rule-minimum.md` is now a superseded redirect.

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

- None. `.8` closeout is active; no user decision is currently blocking it.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-08` | `SPEC-LANG-REFERENCE.8` | focused `LinkedSpec::Get` parity probes (`Entry::` vs selected `Body:` default + `AND` bodies); current-facing stale-doctrine scan; Knowledge Map regeneration/check; `mdbook build docs/linkedspec-book`; memory, task-tree metadata, doctrine, and whitespace checks | ADR `0010` reaffirmed as current doctrine: `::` marks the rule entered first and shares the `:` feature surface after entry selection. Old no-regex/two-rule-minimum card is now a superseded redirect; mdBook/toolbox/task/live docs aligned; tree closed |
| `2026-06-17` | `SPEC-LANG-REFERENCE.1` | two read-only audits (surface inventory ∥ book coverage map) synthesized; cross-checked the "E/IT deprecated" claim vs `LIFECYCLE-FAMILY-AUDIT`; `scripts/check_memory_architecture.sh` | self-check exit 0; 8/10 surface areas WELL-COVERED; binding gaps = regex-first-class (`.2`) + output-shape (`.3`); minor gaps `.4`–`.6`; KM cards `.7`; finalize `.8`. Rejected the unverified E/IT-deprecated claim. No book change (audit only) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.2` | engine facts verified read-only against `perl/LinkedRE.pm`, `perl/LinkedSpec/ActionIR/Contracts.pm` (`entry_group`/`match_group`/`entry_named` lowering), `perl/LinkedSpec/BootstrapSpec/Core.pm` (`/pattern/` recognizer), `rust/linkedspec-runtime/src/helpers.rs` (rgx `CompiledAlternation`), and cross-checked vs shipped specs (`lib_reader`/`tablegrep`/`spec.spec`); `mdbook build` (pre + post); whole-book grep for capture-indexing drift | `mdbook build` exit 0 both times; new `regex-in-spec.md` chapter + `formal-grammar.md §3.1` expansion; **3 drift sites corrected** (wrong "index 0 = full match" claim + two examples using the 1-based convention); convention verified 0-based/captures-only/compacted |
| `2026-06-17` | `SPEC-LANG-REFERENCE.3` | output shapes verified vs frozen oracle-corpus fixtures (`rust/linkedspec-runtime/tests/corpus/proof_edge_{scalar,array}_literal`), a **live Perl-reference run** (`LinkedSpec::Get` on a `/(\w+)=(\w+)/` spec → `["?pair:","key","val"]`), and shipped-spec grep for the tagged convention; grounded the wrap + return-vs-accumulator in `docs/knowledge/rust-perl-output-oracle.md`; `mdbook build` | `mdbook build` exit 0; `runtime-semantics.md §5` expanded (§5.5–§5.8). A hand-built accumulator example (`[undef,undef,undef]`) was discarded — only verified material documented. Tagged shape reframed as OPTIONAL per user feedback (engine imposes no output schema) |
| `2026-06-17` | `SPEC-LANG-REFERENCE.4` | both new examples **compiled** through `LinkedSpec::Get` (grouped target + `Call`→`Inner` divergence); ran ~9 minimal accumulator/dispatch shapes to attempt a top-level divergence I/O (all → `[]`/`undef`/`0`, the documented hard accumulator axes); divergence semantics grounded in `.2`'s verified source wiring + the existing source-boundary example; `mdbook build` | `mdbook build` exit 0; grouped-target section (`action-and-lifecycle-placement.md`) + entry-vs-match divergence section (`capture-marks-and-source-locations.md`). Divergence documented at the reader-wiring level (not a fabricated I/O) — honest scope note recorded |
| `2026-06-17` | `SPEC-LANG-REFERENCE.5.1` | delegated read-only catalog audit (`Contracts.pm` id set vs catalog); self-verified the 2 flagged sigil leaks at `helper-contract-catalog.md:13,159` + whole-catalog re-sweep for `$`/`@`/`%` sigils and `lowers to`/`do {`/`Data::Dumper`/`JSON::PP`/`//gcp`; `mdbook build` | `mdbook build` exit 0; **0 public-API completeness gaps** (158 ids = ~130 public + 17 internal IR variants + ~11 deprecated `compatibility_surface`); **2 sigil leaks fixed**, no others; example-density gap (0/~140) decomposed into `.5.2`–`.5.5` |
| `2026-06-17` | `SPEC-LANG-REFERENCE.5.2` | scratch oracle-style driver (`LinkedSpec::Get` → run parser on input → `JSON::PP->canonical` encode) over all 35 Scalar+Numeric examples; sanity-checked vs frozen fixtures `proof_edge_{scalar,array}_literal` (reproduced exactly); probed the value-vs-condition lowering split in `ActionIR/FlowExpr.pm`; `mdbook build` | `mdbook build` exit 0; 35/35 examples produce the documented outputs; `is_defined`/`is_undefined` documented condition-only (die as values); `split→num_sum` non-composition avoided (array-form reducers use explicit `array(...)`); **discovered** §5.5 Pair example outputs `[]` not the tagged array → owned by new leaf `.9` (not bundled) |
| `2026-07-08` | `SPEC-LANG-REFERENCE.5.3` | focused `LinkedSpec::Get` oracle driver for Array value examples, statement/mutation pipeline examples, split return-shape variants, receiver-chain variants, and array-tree traversal; `call_spec_handler_subst` probes for split/pipeline lowering; mdBook/KM/live-doc updates; `mdbook build docs/linkedspec-book`; memory, task-tree, doctrine, whitespace, and Knowledge Map checks | documented Array examples return the recorded outputs; caveats confirmed: compact `I.return(split(...))` tags as `"?value:"`, block/receiver split returns plain arrays, direct `return(split_each(array(items), ...))` returns count-shaped output, and documented receiver chains stick to verified continuations. Gates pass |
| `2026-07-08` | `SPEC-LANG-REFERENCE.5.4` | focused `LinkedSpec::Get` oracle driver for Hash examples, hash-tree traversal examples, Control Flow branch/loop/return examples, and `next()` repetition control; `call_spec_handler_subst` probes for direct odd-arity `hash(...)`; descriptor probe for `exit_now(2)` canonical metadata; mdBook/KM/live-doc updates; `mdbook build docs/linkedspec-book`; memory, task-tree, doctrine, whitespace, and Knowledge Map checks | documented Hash and Control Flow examples return the recorded outputs; direct `hash("a", 1, "missing")` is documented as a current unsupported-helper caveat with explicit `undef` / list-splice stable forms; `exit_now(2)` descriptor reports ready `EXIT` metadata without running the terminating path. Gates pass |
| `2026-07-08` | `SPEC-LANG-REFERENCE.5.5` | focused `LinkedSpec::Get` oracle driver for Declaration, Capture/Mark, Entry/Match, Input, and Call examples; stale entry-vs-match page examples re-probed and corrected to a verified ordered-child shape; KM fact card + regeneration; mdBook/live-doc updates; `mdbook build docs/linkedspec-book`; memory, task-tree, doctrine, whitespace, and Knowledge Map checks | documented remaining helper-family examples return the recorded outputs; helper-catalog sweep `.5` closes. `capture-marks-and-source-locations.md` and `source-boundary-helper-reference.md` now use the verified `Top:: -> Name .push` + `Name:AND` entry/local-match divergence shape, and KM fact `entry-match-divergence-verified-shape` records the pattern. Gates pass |
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

Canonical task-node Commit fields retain every consolidated table label, reference and note. Exact source and
Git comparison are owned by `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6`; no acceptance or verification field changes.
The following historical captions remain in table form because the strict consolidation match did not resolve them.

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-LANG-REFERENCE.3` | `SPEC-LANG-REFERENCE.3 — book: output/return-value shape contract in runtime-semantics §5 (output is author's choice; optional tagged shape)` | Expanded `appendix/runtime-semantics.md §5` (§5.5–§5.8): top-rule value, output is author's choice (optional tagged convention per user feedback), return-vs-accumulator, one-level wrap. Verified vs oracle corpus + live Perl run + shipped specs |
| `SPEC-LANG-REFERENCE.10.5.1` | `SPEC-LANG-REFERENCE.10.5.1 — audit: whole-book .spec-snippet scorch (findings table + engine facts) → decompose into per-file fix leaves .10.5.2-.19` | Read-only audit (8 agents + personal ground-truth re-verify). ~105 `::`-mode headers across ~20 files; pervasive `Rule::AND /regex/ -> Rule[N]` idiom is doctrine-divergent + `[]`-shaped. User chose FULL book-wide scorch. ebnf "richer example" cleared. `.10.4` superseded by `.10.5.16`. No book/Perl change |

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
- `2026-07-08`: `.5.3` done — added verified Array helper worked examples to
  `appendix/helper-contract-catalog.md`: pure array values, selectors, edge slices, ordering,
  membership, split, statement/mutation pipelines, receiver chains, and array-tree traversal now have
  concrete outputs. Probes found shape-sensitive current Perl forms around compact
  `I.return(split(...))`, direct `return(split_each(array(items), ...))`, and unsupported
  pipeline-to-pure receiver continuations; the book documents stable forms and KM fact
  `array-helper-return-shape-caveats` records the caveat. Optional behavior normalization is deferred
  to `.5.3.1`; frontier → `.5.4` (Hash + Control Flow helper worked examples).
- `2026-07-08`: `.5.4` done — added verified Hash and Control Flow helper worked examples to
  `appendix/helper-contract-catalog.md`. Hash examples now cover constructor/copy/splice, pure and
  mutating hash updates, sorted views, receiver chains, block receivers, and hash-tree traversal.
  Control Flow examples now cover inline/marker/attached branch forms, `switch`, `while`, `next`,
  `return`, and `return_undef`; `exit_now(2)` is descriptor-verified without running the terminating
  path. Probes found direct odd-arity `hash("a", 1, "missing")` returns `undef` via an unsupported-helper
  sentinel on current Perl, so the book documents explicit `undef` / list-splice stable forms and KM fact
  `hash-helper-odd-arity-current-behavior` records the caveat. Optional normalization is deferred to
  `.5.4.1`; frontier → `.5.5` (Declaration, Capture/Mark, Entry/Match, Input, Call examples).
- `2026-07-08`: `.5.5` done — added verified worked examples for the remaining helper families:
  declaration replacements (`name = value` plus explicit aggregate resets), anonymous capture cursor
  reads, named marks with `capture_between(...)`, entry-vs-local-match readers, whole-input readers,
  and `call(child)`. Focused `LinkedSpec::Get` probes verified every documented output. While probing,
  corrected stale entry-vs-match snippets in `capture-marks-and-source-locations.md` and
  `source-boundary-helper-reference.md` to the verified ordered-child shape (`Top:: -> Name .push` +
  `Name:AND` later-slot action). KM fact `entry-match-divergence-verified-shape` records the durable
  pattern. Helper-catalog sweep `.5` closes; frontier → `.6` (capture/mark cross-example + remaining
  thin spots).
- `2026-07-08`: `.6` done — added the capture/mark cross-example to
  `source-boundary-helper-reference.md` and `action-and-lifecycle-placement.md`, exercising
  `@capture_slice`, `@mark(body_start)`, `mark_match_start(close_start)`, `capture_slice()`,
  `capture_from(body_start)`, and `capture_between(body_start, close_start)` in one verified rule.
  Corrected marker-placement thin spots in `action-and-lifecycle-placement.md` by using
  `mark_here(...)` inside opener actions when exact block-local timing is required. KM fact
  `split-boundary-marker-action-timing` records the durable visibility rule. Frontier → `.7`
  (durable `.spec`-language KM fact-card coverage).
- `2026-07-08`: `.7` done — added canonical KM fact cards for `.spec` output/return shape,
  regex backend feature contract, rule-mode semantics, lifecycle/`retv` order, and capture/mark
  taxonomy; extended the existing edge syntax card with action-vs-blind dispatch retrieval keys.
  Regenerated `KNOWLEDGE_MAP.md`; required question spot-checks route to the expected facts and
  the KM gate passes. Frontier → `.8` (final whole-book consistency + close).
- `2026-07-08`: `.8` done — corrected stale top-rule doctrine drift and closed
  `SPEC-LANG-REFERENCE`. User reminder re-established the chronology: the June 17 no-regex/two-rule
  correction is historical and ADR `0010` (2026-06-23) is current doctrine. Focused probes confirmed
  equivalent regex-bearing `Entry::` and selected `Body:` default/`AND` bodies return matching outputs.
  The old no-regex card is now a superseded redirect; current-facing mdBook/toolbox/task/live docs
  say `::` marks the rule entered first and otherwise shares the `:` feature surface. mdBook, KM,
  memory, task-tree metadata, doctrine, and whitespace gates pass. Tree closed.
