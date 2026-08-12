- ID: `FUTURE-PARITY-BACKLOG.14`
  Status: `active` (2026-07-29; architecture `.14.0.1` complete; contract `.14.1` pending)
  Goal: Ratify, document, and implementation-audit LinkedSpec's structural linked-rule, typed source-location,
    transactional cursor, lossless segmentation, and progressive/staged parser-composition authoring model.
  Children: `.14.0`, `.14.0.1`, `.14.1`, `.14.2`, `.14.3`, `.14.4`, `.14.5`, `.14.6`, `.14.7`, `.14.8`
  Acceptance: Public guidance teaches small readable boundary regexes and connected recursive rule structure;
    immutable typed positions/spans form one source-location algebra over invocation-local cursor state; bounded
    transactional cursor scopes preserve rule-local cursor ownership and prove progress; recursive boundaries and
    lossless segmentation retain exact provenance; progressive parsing composes loaded spec parsers over spans;
    staged parsing can enrich selected returned-AST fields with later spec-driven parses; static diagnostics,
    examples, five-backend admissions, and implementation claims remain proof-backed rather than aspirational.

- ID: `FUTURE-PARITY-BACKLOG.14.0`
  Status: `done`
  Goal: Capture the director's complete authoring model and split doctrine, progressive composition, staged AST
    enrichment, and implementation/no-drift audit before changing behavior or public claims.
  Verification: **PASS 2026-07-12.** ADR 0012 and the closed `STAGED-LINKED-PARSING` tree already own neutral
    parse jobs, many-next-spec dispatch design, and one narrow function-body prototype. In that prototype the
    user-function `.spec` owns the outer definition and bounded body extraction, while the `actionir-body.spec`
    job identity resolves to a built-in backend-native ActionIR parser adapter rather than an owning `.spec` file;
    it is staged parsing, not evidence that one `.spec` loads another. The director's clarification
    adds the missing simple-regex/linked-rule authoring doctrine and distinguishes active in-parse progressive
    composition from later returned-AST staged enrichment. Current public `parse_job(...)`, multiple parser
    families, arbitrary in-parse composition, and recursive queues remain unimplemented/future. The mdBook's
    portmap praise for one complex regex and EBNF recursive-regex description are explicit `.14.1/.14.4` audit
    evidence rather than silently accepted target idioms. No parser/runtime behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.14.0 - capture structural progressive parsing doctrine`

- ID: `FUTURE-PARITY-BACKLOG.14.0.1`
  Status: `done` (2026-07-29; behavior-free architecture adopted from clean `283dc841`)
  Goal: Capture the director-approved typed source-location and transactional cursor architecture, reconcile it
    with the existing structural/progressive/staged doctrine, and dependency-split it before syntax or behavior.
  Depends on: `.14.0`
  Acceptance: Adopt one immutable source-location algebra rather than another flat helper expansion; define exact
    architectural invariants for source identity, half-open Unicode-scalar positions/spans, provenance, extraction,
    bounded checkpoint/try/commit/rollback, progress, recursive entry/match/exit observation, span-native parser
    composition, lossless named-slot segmentation, and static safety diagnostics. Preserve the current helper
    surface as projections/compatibility, rule-local intrinsic seek/consume ownership, invocation-local authority,
    backend neutrality, and existing `INTER-MATCH-GAP-CAPTURE` ownership. Split contract, neutral fixtures,
    implementation, six-runtime admission, recurring proof, public examples, and no-drift before behavior code.

  #### Acceptance Checklist

  - [x] **CLEAN OWNED BASE** — Prove clean MCP-validator commit `283dc841`, zero-byte message brief, absent generated
    residue, and `.14.0.1` ownership before changing an ADR, roadmap, Knowledge Map card, or public documentation.
  - [x] **CANONICAL RECONCILIATION** — Retrieve and reconcile ADRs `0012`, `0044`, `0045`, Phase 4 capture/mark
    taxonomy, structural/progressive/staged doctrine, current backend cursor/capture facts, and queued gap capture.
  - [x] **SOTA ARCHITECTURE** — Freeze minimal immutable value types, provenance and coordinate rules, bounded
    transaction/progress semantics, recursive observation, span-native composition, lossless segmentation, and
    static error classes without choosing convenience syntax prematurely or adding hidden authority.
  - [x] **DEPENDENCY SPLIT / NO DUPLICATE OWNER** — Refine `.14.1-.14.8` so contract/fixtures precede behavior,
    existing inter-match-gap ownership composes rather than forks, each backend is separately admitted, and
    recurring/public no-drift close the program.
  - [x] **NO-OVERCLAIM** — Change no grammar, helper, parser/compiler/runtime, descriptor, generated format,
    semantic response, MCP surface, primary CLI, rollout, admission, or current feature-completeness claim.
  - [x] **LOCKSTEP SIGNOFF** — Synchronize ADR/index, task/index/frontier, roadmaps, architecture, Knowledge Map,
    mdBook, changes/development/live/memory; pass focused and canonical gates, exact cleanup, commit/brief/clean
    workflow, and do not push.

  Verification: **PASS 2026-07-29.** Clean base `283dc841`, zero-byte brief, absent generated residue, and owning
    leaf were proved before the ADR or public documentation moved. ADRs `0012`, `0014`, `0015`, `0044`, and `0045`,
    the Phase 3/4 contracts, current implementation, Knowledge Map, and mdBook were reconciled. ADR `0056` now
    freezes caller-authorized source identity, immutable zero-based Unicode-scalar positions, same-source half-open
    spans, ordered provenance, recognition-only invocation-local cursor transactions, read-only recursive
    boundaries, progress obligations, and authority-preserving span-native composition. Transactions add no
    systemic backtracking and cannot roll back user/AST/output/diagnostic/registry/external/host effects; ADR `0045`
    remains the exclusive gap syntax/lifecycle owner. `.14.1-.8` separate contract, implementation/admission,
    transaction safety, recursion/provenance, segmentation composition, progressive parsing, staged enrichment,
    and recurring/public proof. Focused mdBook, Knowledge Map 740/5,958, task/diff, six-doctrine, cursor
    36/18/8 over 75 files with 8/0 rollout and 60 mutations, capability 80/0/0, and semantic 6/20/105 at 7/9 + 6/6
    pass; storage 1,690/377,544/28 and tool locality 3/13/21 pass. Canonical CI passes Perl semantic admission 18,
    Rust 1/1 in 79.52 seconds, Dart 1/1, Julia 416/416 in 28.5 seconds, containment, moved-root proof, primary CLI
    66x2, RAM at 68%, and Phase 0 1,031/1,031 in 642 seconds. Cleanup removes the 13,244-KiB book and one empty run.
    No syntax, behavior, generated format, semantic/MCP/CLI surface, rollout, admission, or completeness claim moves.
  Commit: `FUTURE-PARITY-BACKLOG.14.0.1 - adopt typed source location algebra`

- ID: `FUTURE-PARITY-BACKLOG.14.1`
  Status: `done` / composition-closed (2026-08-01; `.14.1.0-.3` complete)
  Goal: Ratify the exact typed source-location algebra and neutral conformance fixtures while teaching simple-regex
    linked-rule structure, including zero/one/two-regex roles and graph-owned recursion.
  Children: `.14.1.0`, `.14.1.1`, `.14.1.2`, `.14.1.3`
  Acceptance: Audit current portable/helper/documentation authority before artifacts; freeze one versioned neutral
    schema, positive/negative fixtures, conversions, provenance/state-machine/current-helper projections,
    diagnostics, and mutation boundary; teach zero/one/two-regex linked structure and graph-owned recursion only
    from current proof; close through unchanged recomposition before `.14.2` backend implementation.

- ID: `FUTURE-PARITY-BACKLOG.14.1.0`
  Status: `done` (2026-08-01; signoff-complete from clean `24770ade`, intended 132/300, no push)
  Goal: Audit and freeze the dependency-complete executable neutral-contract plan before creating artifacts or
    changing public teaching.
  Depends on: `.14.0.1`, `.24.2`
  Acceptance: Retrieve ADR `0056` and the canonical Knowledge card before re-derivation; inventory existing
    neutral-contract conventions, current capture/mark/cursor helper projections, coordinate/provenance behavior,
    zero/one/two-regex structure, graph recursion, diagnostics, CI/storage routing, and contradictory public prose;
    use LinkedSpec toolbox/runtime evidence for behavioral claims; freeze exact `.1-.3` artifact/teaching/closeout
    boundaries without changing grammar, parser/compiler/runtime/emitter, fixtures, public claims, capability,
    semantic/MCP, root README, or mdBook source.

  ### `FUTURE-PARITY-BACKLOG.14.1.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove clean exclusion-public-closeout commit `24770ade`, zero-byte
    brief, synchronized Knowledge Map, absent rendered-book/bytecode/background residue, and activate this leaf
    task-tree-first before any implementation or other documentation change.
  - [x] **RETRIEVE / REVERIFY AUTHORITY** — Read ADR `0056`, its canonical Knowledge card, `.14.0-.14.0.1`, the
    relevant capture/mark/cursor facts, and current neutral-contract precedents before inspecting code or runtime.
  - [x] **TOOLBOX-LED CURRENT AUDIT** — Use the documented LinkedSpec probes plus exact source/test inventories to
    establish current helper projections, coordinate/provenance boundaries, rule-shape/recursion behavior, and
    contradiction candidates without guessing from `.spec` text.
  - [x] **FREEZE EXECUTABLE CONTRACT PLAN** — Specify exact paths, schema/version, fixtures, state-machine and
    diagnostic rows, mutation classes, independent validation, canonical/storage routing, and `.14.2` handoff.
  - [x] **FREEZE PUBLIC-TEACHING PLAN** — Inventory sole-facing pages and exact zero/one/two-regex plus graph-owned
    recursion claims; classify current truth versus future typed-value behavior and avoid wall-of-text additions.
  - [x] **NO BEHAVIOR / VERIFY / COMMIT / CLEAN** — Change only task/live/roadmap/KM/book status needed to preserve
    the audit plan; pass focused/book/doctrine/canonical gates, commit, clear the brief, and prove clean before
    neutral artifact implementation `.14.1.1`.

  Activation evidence 2026-08-01: exclusion public no-drift `.24.2` landed at `24770ade` as commit 131/300 with no
  push. Exact post-commit proof found empty status and staged/unstaged diffs, zero-byte brief, synchronized
  Knowledge Map 783/6,348, no rendered book or Python bytecode, and no background result. ADR `0056` and the
  Knowledge Map route the next PNT work to `.14.1`; this first child owns only behavior-free audit and executable
  plan refinement.

  Authority and TOOLBOX audit 2026-08-01: ADR `0056`, its canonical Knowledge card, ADRs `0010`, `0012`, `0014`,
  `0015`, `0044`, `0045`, the structural/capture/mark/top-rule Knowledge cards, and the existing rule-local cursor,
  duplicate-slot, callable, semantic, CI, and project-data contracts were retrieved before runtime probing.
  `LinkedSpec::Get` proves a zero-regex coordinator plus one-regex leaf returns `["foo","foo"]`, a regex-bearing
  selected entry rule is valid and returns `"foo"`, and the existing two-regex `sexpr` graph recursively returns
  `[["a",["b"],"c"]]` from `(a(b)c)`. `return_descriptor` reports the corresponding exact `0/1/2` regex counts,
  `or_default`/`seek` family policy, action ownership, and canonical ActionIR nodes. On decoded `é\n🙂x`, live
  `input_*`, `cursor_*`, `entry_*`, and `match_*` positions use four Unicode scalars over eight UTF-8 bytes; the
  observed boundaries are input `[0,4)`, entry newline `[1,2)`, and current match `🙂x` `[2,4)`. A second
  capture/mark probe over `é🙂x` proves character positions `0..3`, stable and advancing anonymous spans, named
  mark spans, and derived line/column reads. `call_spec_handler_subst` confirms those current Perl projections are
  still host `pos`/`length`/`substr` lowering rather than typed public values. Direct and mutual no-consume
  recursion terminate at the existing `(rule, position)` guard with `undef` and a trace decision, but no structured
  `last_error`; the future portable non-progress diagnostics therefore remain target contract, not current claims.

  Helper and documentation audit 2026-08-01, corrected by executable `.14.1.1` source proof: the aligned modern
  projection inventory is exactly 92 canonical calls: 47 capture/mark, 30 entry/match, 11 input/cursor, and four
  explicit cursor-control calls. Perl retains seven callable compatibility aliases (`capture_from_rule_start`,
  `capture_len_from_rule_start`, `capture_rest_length`, `capture_slice_here`, `capture_slice_length`,
  `entry_named_map`, `match_named_map`) plus separate legacy capture forms. `capture_take_slice` and
  `capture_take_slice_len` are two internal contract/scanner record ids whose recognized public spellings are the
  canonical `capture_take()` and `capture_take_len()`; live `call_spec_handler_subst` leaves the two internal names
  unresolved. The original nine-alias label conflated internal ids with callable spellings and is superseded by
  this exact seven-plus-two classification. Current semantic-introspection byte spans remain an adjacent versioned
  projection and are not silently changed into runtime typed values. The sole-facing book already marks typed
  positions/spans as future
  and accurately demonstrates recursive linked rules, but three places still praise a complex/recursive-regex
  style: `portmap-spec-walkthrough.md` (three passages), `ebnf-spec-walkthrough.md` (one passage), and
  `shipped-specs-and-corpora.md` (one reading-order description). They are current shipped-code descriptions, not
  false behavior claims, but `.14.1.2` must reframe them as compatibility examples rather than general guidance.

  Frozen executable plan 2026-08-01: `.14.1.1` creates
  `capability_conformance/typed_source_location_contract.json` with contract id
  `linkedspec-typed-source-location-v1` and independent validator
  `tools/check_typed_source_location_contract.py`. The exact neutral envelope contains three decoded-source
  fixtures, seven position conversions, six direct spans, three derived-text/provenance cases, eight invocation
  state transitions, eight checkpoint/try/commit/rollback transitions, six recursive-observation cases, four
  structural authoring cases, 92 ordered canonical helper projections, seven ordered callable compatibility
  aliases, two ordered internal contract ids, and 31 ordered diagnostic/negative cases. The diagnostic inventory
  covers the ADR's four value/provenance failures;
  four mark and four transaction-token validity failures; seven transaction lifecycle/authority failures; cursor
  regression, nullable repetition, direct/mutual recursion, and staged cycles; unavailable recursive boundaries;
  ambiguous/stale regex-slot identity; and four source/registry/capability/policy span-dispatch denials. No source
  spelling is selected. Thirty-six independent mutations cover envelope, coordinate, span/provenance, state,
  transaction, recursion, helper/alias, diagnostic, rollout, tracked-input, and canonical-registration drift.

  Storage and rollout plan 2026-08-01: the neutral checker runs only through
  `bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py`; `tools/run_ci_local.sh`
  requires both files as tracked inputs and runs that routed command as an ordinary canonical check. No new shell
  driver, cache, package store, temp root, or workflow is created. Fourteen ordered rollout legs preserve the
  dependency boundary: neutral contract `.14.1.1`; public structure `.14.1.2`; neutral/public recomposition
  `.14.1.3`; Perl plus Rust/Dart/Julia/PUC-Lua/LuaJIT admission `.14.2`; transaction safety `.14.3`; recursive
  observation `.14.4`; gap composition `.14.5`; progressive dispatch `.14.6`; staged enrichment `.14.7`; and
  recurring/public no-drift `.14.8`. `.14.1.1` updates only the capture/status/local-CI book pages needed to say
  the neutral contract exists while runtime values remain future. `.14.1.2` adds readable, separately rendered
  paragraphs to the rule-paragraph and regex chapters, reframes the three shipped-spec pages above, and updates
  project status; no long stitched prose blob is permitted. `.14.1.3` changes no artifact or teaching content.

  Verification: **PASS 2026-08-01.** The audit began from exact clean commit `24770ade` with no book/bytecode/
  background residue. ADR/Knowledge retrieval and the documented `LinkedSpec::Get`, `return_descriptor`, and
  `call_spec_handler_subst` probes establish the current Unicode, 0/1/2-regex, linked-recursion, helper, and
  non-progress boundaries recorded above. The frozen plan adds one canonical Knowledge card and changes only
  task/index/roadmap/live continuity surfaces; no `.spec`, production/test/fixture, executable contract, schema,
  capability, semantic/MCP, root README, or mdBook source moves. Knowledge Map passes at 784 facts / 6,362 question
  keys; the unchanged sole-facing book builds 79 files / 14,072 KiB; rule-local cursor remains 8/0/60 over 74 files
  and capability remains schema v2 / 16 capabilities / 80-0-0 / two exclusions / 24 manifest mutations / 12
  projections / six public mutations. Task metadata, diff/whitespace, and all seven doctrines pass. The canonical
  sequence passes compositionally: the in-workspace driver passed through semantic/MCP and tool-storage proof,
  the exact nested macOS containment proof then passed with required host permission after the enclosing sandbox
  denied `sandbox-exec`, and the remaining moved-root/outside-CWD, CLI 66x2, and Phase 0 1,031/1,031 tail passed
  independently. No project check failed. Generated book output is removed, the commit brief is cleared after
  landing, and exact clean proof precedes `.14.1.1` activation.
  Commit: `FUTURE-PARITY-BACKLOG.14.1.0 - freeze typed source location plan`

- ID: `FUTURE-PARITY-BACKLOG.14.1.1`
  Status: `done` (2026-08-01; signoff-complete from clean `c2d9eadf`, intended 133/300, no push)
  Goal: Implement the versioned neutral typed source-location contract, positive/negative fixtures, independent
    checker/mutations, and repository-routed canonical registration frozen by `.14.1.0`.
  Depends on: `.14.1.0`
  Acceptance: Create only `capability_conformance/typed_source_location_contract.json` and
    `tools/check_typed_source_location_contract.py` as new executable artifacts; use exact contract id/counts,
    helper/alias order, 31 diagnostic fixtures, 36 mutations, and 14 rollout legs frozen above; register both as
    tracked canonical inputs and run the checker only through `tools/run_python_project_data.sh`; document the
    neutral artifact in `capability_conformance/README.md` and the capture/status/local-CI book pages without
    claiming typed runtime values, selecting syntax, changing another schema/version, or adding a driver.

  ### `FUTURE-PARITY-BACKLOG.14.1.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.1.0` landed at `c2d9eadf` as 132/300 with no push,
    empty status/diffs, zero-byte brief, synchronized Knowledge Map, absent generated book/bytecode residue, and
    activate this leaf task-tree-first before artifact or documentation changes.
  - [x] **EXACT VERSIONED CONTRACT** — Create only the frozen v1 JSON artifact with exact identity, ordered
    fixtures/projections/aliases/diagnostics/rollout, count invariants, and no selected source spelling or backend
    implementation claim.
  - [x] **INDEPENDENT VALIDATOR / MUTATIONS** — Create the standalone Python checker with exact schema, semantic,
    cross-reference, ordering, count, negative-diagnostic, tracked-input, canonical-registration, and 36-mutation
    proof; reject each mutation independently.
  - [x] **REPOSITORY-ROUTED CANONICAL REGISTRATION** — Require both artifacts as tracked inputs and execute the
    checker only through `tools/run_python_project_data.sh` in `tools/run_ci_local.sh`; add no driver, cache,
    workflow, temp root, dependency, or off-volume output.
  - [x] **SOLE-FACING NEUTRAL STATUS** — Document the neutral artifact in `capability_conformance/README.md` and
    only the frozen capture/status/local-CI book pages, with readable separate paragraphs and explicit future
    runtime/syntax/backend boundaries.
  - [x] **VERIFY / COMMIT / CLEAN** — Pass direct checker, mutation count, storage/path guards, book build/link
    checks, all doctrines, and canonical CI; update continuity/KM, commit this leaf, clear the brief, and prove the
    clean boundary before public teaching `.14.1.2`.

  Activation evidence 2026-08-01: `.14.1.0` landed at `c2d9eadf` as commit 132/300 with no push. Exact post-commit
  proof found empty status and staged/unstaged diffs, zero-byte `git_message_brief.txt`, activation pointer
  `24770ade` resolving to `HEAD^1`, synchronized Knowledge Map 784/6,362, and no generated book or non-cache Python
  bytecode. `.14.1.1` is now the sole active frontier and owns the frozen neutral artifacts, canonical route, and
  truthful neutral-status documentation only.

  Audit correction 2026-08-01: the first executable checker correctly rejected the frozen nine-alias assumption.
  Source and live lowering proof show seven callable compatibility aliases plus two internal record ids:
  `capture_take_slice` and `capture_take_slice_len` name contract/scanner records, but those records recognize only
  canonical `capture_take()` and `capture_take_len()`; the internal names remain unresolved when authored. This
  leaf owns the correction across the neutral artifact, prior audit annotation, Knowledge card, continuity status,
  and later sole-facing neutral-status prose. No runtime behavior changed.

  Implementation evidence 2026-08-01: `linkedspec-typed-source-location-v1` now exists at the frozen JSON path.
  Its independent checker validates three decoded sources, seven conversions, six direct spans, three derived
  texts, eight invocation and eight transaction transitions, six recursive observations, four structural cases,
  92 helper projections, seven callable aliases, two internal ids, 31 diagnostics, 14 rollout legs, and 36
  independently rejected mutations. `tools/run_ci_local.sh` requires both new files as tracked inputs and invokes
  the checker unconditionally through `tools/run_python_project_data.sh`; the tool-storage inventory advances from
  27 to 28 routed Python entrypoints without a new driver or storage root.

  Sole-facing evidence 2026-08-01: the capture, project-status, and local-CI pages state that the neutral contract
  exists while syntax, public typed values, backend behavior, and the remaining 13 rollout legs are future. The
  complete book builds, and direct rendered-HTML inspection confirms each new prose unit is emitted as a distinct
  paragraph, heading, or preformatted block rather than a stitched blob. Browser viewport control is unavailable
  in this session, so no screenshot-level visual claim is made; the broader readability audit remains queued.

  Verification: **PASS 2026-08-01.** The direct routed checker passes all exact counts and independently rejects
  36 mutations, including coherent out-of-range transaction state. JSON/shell syntax, root-path portability,
  project-data locality over 1,793 governed files / 413,600 lines / 28 cases, tool storage over 28 Python
  entrypoints, Knowledge Map 784/6,363, task metadata, whitespace, complete mdBook build, and all seven doctrines
  pass. Direct rendered HTML confirms the three additions are separate structural elements. The definitive staged
  canonical gate passes every semantic/MCP, focused Perl, containment, moved-root/outside-CWD, and storage layer;
  both CLI matrices pass 66/66, RAM is 46%, and Phase 0 passes 1,031/1,031 in 644 seconds before
  `local CI gate passed`. The initial canonical attempt correctly rejected a missing governed `.24.2` public
  marker; restoring the exact marker made capability schema v2 / 80-0-0 / 24+6 mutations green before the complete
  rerun. Generated book output is removed; the landing commit, brief clearing, and exact clean proof precede
  `.14.1.2` activation in the intended handoff.
  Commit: `FUTURE-PARITY-BACKLOG.14.1.1 - add typed source location contract`

- ID: `FUTURE-PARITY-BACKLOG.14.1.2`
  Status: `done` (2026-08-01; signoff-complete from clean `e8f6198b`, intended 134/300, no push)
  Goal: Align sole-facing guidance for simple zero/one/two-regex linked-rule structure and graph-owned recursion
    with the executable neutral contract, clearly separating current authoring truth from future typed values.
  Depends on: `.14.1.1`
  Acceptance: Add one practical rule-shape section to `user-model/spec-files-and-rule-paragraphs.md`, reinforce
    small boundary regexes and graph-owned recursion in `user-model/regex-in-spec.md`, reframe the exact current
    complex/recursive-regex passages in the portmap and EBNF walkthroughs plus shipped-spec reading order, and
    update project status. Preserve every current shipped-code fact and executable example; teach zero-regex
    coordination, one-regex leaves, two-regex start/end nodes, regex-bearing entry validity, action-edge OR,
    blind-call AND, and consume-before-recurse as guidance rather than a syntactic maximum. Use short separate
    rendered paragraphs and lists, with no stitched wall-of-text section.

  ### `FUTURE-PARITY-BACKLOG.14.1.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.1.1` landed cleanly at `e8f6198b` as 133/300 with no
    push, empty status/diffs, zero-byte brief, synchronized Knowledge Map, absent generated book/bytecode, and no
    background result before activating this leaf task-tree-first.
  - [x] **RETRIEVE / REVERIFY PUBLIC AUTHORITY** — Retrieve the typed source-location Knowledge card and v1
    checker, then reverify the exact zero/one/two-regex, entry-rule, action-edge, blind-call, recursion, and five
    compatibility-passage claims through current toolbox/source evidence before editing the book.
  - [x] **TEACH SMALL LINKED RULE SHAPES** — Add practical, separately rendered guidance for zero-regex
    coordinators, one-regex leaves, two-regex start/end nodes, valid regex-bearing entries, action-edge OR,
    blind-call AND, and consume-before-recurse without inventing a syntactic maximum or future typed values.
  - [x] **REFRAME COMPATIBILITY MATERIAL** — Preserve every shipped portmap/EBNF/spec-corpus fact and example while
    reframing the exact five complex/recursive-regex praise passages as compatibility description, not preferred
    general authoring style.
  - [x] **SOLE-FACING READABILITY / STATUS** — Update project status, use short paragraphs/lists, build the complete
    book, and inspect exact rendered structure so no new section becomes a stitched prose blob; keep the broader
    non-urgent `MDBOOK-RENDERED-READABILITY` audit independently queued.
  - [x] **VERIFY / COMMIT / CLEAN** — Pass toolbox/public-marker checks, book build/link/rendered inspection,
    Knowledge/task/roadmap/live alignment, all doctrines, and canonical CI; commit, clear the brief, and prove the
    clean boundary before no-change recomposition `.14.1.3`.

  Activation evidence 2026-08-01: `.14.1.1` landed at `e8f6198b` as commit 133/300 with no push. Exact post-commit
  proof found empty status and staged/unstaged diffs, zero-byte `git_message_brief.txt`, activation pointer
  `c2d9eadf` resolving to `HEAD^1`, synchronized Knowledge Map 784/6,363, no rendered book or non-cache Python
  bytecode, and no background result. `.14.1.2` is now the sole active frontier and owns only the frozen public
  teaching/status pages plus their continuity alignment; no contract, checker, grammar, or runtime behavior.

  Retrieval/reverification evidence 2026-08-01: the typed source-location plan, structural authoring doctrine,
  action-edge contract, blind-call label contract, and `TOOLBOX.md` were read before public edits. The independent
  v1 checker remains exact at 3 sources, 7 positions, 6 direct spans, 3 derived texts, 8+8 state transitions, 6
  recursive observations, 4 structural cases, 92 helper projections, 7 callable aliases, 2 internal ids, 31
  diagnostics, 1 complete / 13 pending rollout, and 36 rejected mutations. Fresh `LinkedSpec::Get` execution
  returns `["foo","foo"]` for the zero-regex coordinator/one-regex leaf graph, `"foo"` for an ordinary selected
  regex-bearing `Entry::`, and `[["a",["b"],"c"]]` for the recursive two-regex `sexpr` graph. Fresh descriptors
  report exact regex counts `Top=0`, `Word=1`, `Entry=1`, and `sexpr=2`; existing blind-call descriptor locks prove
  zero-regex `:AND` sequencing remains `AND_BCODE` / `and_call_loop`, label-driven rather than implied by `=>`.
  Source inspection confirms the five teaching contradictions are three praise passages around the shipped five-
  capture `portmap` classifier, one factual recursive-regex passage for EBNF return payloads, and one reading-order
  description. The shipped implementations and examples remain current compatibility facts; only their use as
  preferred general guidance is stale.

  Public-teaching evidence 2026-08-01: the rule-paragraph guide adds one responsibility-led section with a rendered
  list for zero/one/two-regex roles, short separate paragraphs for regex-bearing entries and action-edge OR/default
  branching, a compiled zero-regex `Record:AND` blind-call example, and a direct bridge into the existing
  consume-before-recurse S-expression example. The regex guide now says recognition is regex-anchored while
  coordinators may contain none, teaches small boundary ownership, and preserves multiple-slot/host-regex support.
  All three portmap praise passages, the EBNF recursive-payload paragraph, and shipped reading-order entry now call
  their unchanged implementations compatibility facts rather than general recommendations. Project status records
  the documentation-only boundary and leaves typed runtime behavior future. The complete mdBook builds at 79 files
  / 14,120 KiB; generated HTML contains distinct `h2`, `ul`, `pre`, and sibling `p` elements for the additions.
  Browser viewport control is not exposed in this session, so this is a direct rendered-DOM claim, not a screenshot
  claim; the broader non-urgent `MDBOOK-RENDERED-READABILITY` audit remains queued.

  First canonical attempt 2026-08-01: the gate correctly stopped at capability conformance because the task-index
  refresh had displaced the governed exact markers `exclusion public closeout .24.2` and `Capability exclusion
  freshness is public-closed under FUTURE-PARITY-BACKLOG.24`. The active-frontier update now retains both closed-
  parent projections alongside `.14.1.2`; rerun the focused capability checker before the definitive full gate.

  Signoff evidence 2026-08-01: the repaired focused capability checker passes schema v2, 16 capabilities, 80/0/0
  backend states, two exclusions, 24 governance mutations, 12 governed projections, and six public mutations.
  Knowledge Map is synchronized at 784 facts / 6,363 questions; the complete 79-file / 14,120-KiB book builds and
  its affected DOM structure is inspected. All seven doctrines pass. The definitive canonical rerun passes the
  typed contract, semantic/MCP admissions, every focused Perl contract, project-data containment, moved-root and
  outside-CWD execution, CLI 66/66 in default and POSIX environments, RAM 48%, and Phase 0 1,031/1,031 in 640
  seconds before `local CI gate passed`. Generated book cleanup, commit, brief clearing, and exact clean proof
  precede `.14.1.3` activation.
  Commit: `FUTURE-PARITY-BACKLOG.14.1.2 - teach linked rule structure`

- ID: `FUTURE-PARITY-BACKLOG.14.1.3`
  Status: `done` (2026-08-01; signoff-complete from clean `336781d6`, intended 135/300, no push)
  Goal: Recompose the committed neutral contract, fixtures, mutations, CI route, and public teaching unchanged;
    close `.14.1` and hand the clean boundary to `.14.2` backend value/helper projection implementation.
  Depends on: `.14.1.2`
  Acceptance: Re-run the independent contract checker, book build/link/readability checks, doctrine suite, and
    canonical local CI from the clean `.14.1.2` commit; prove exact contract/count/public markers and zero stale
    praise without changing contract, checker, runtime, schema, helper, public teaching, or root README content;
    close parent `.14.1` and point one clean next action to `.14.2`.

  ### `FUTURE-PARITY-BACKLOG.14.1.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.1.2` landed cleanly at `336781d6` as 134/300 with no
    push, empty status/diffs, zero-byte brief, synchronized Knowledge Map, absent generated book/non-cache
    bytecode, and no unconsumed background result before activating this leaf task-tree-first.
  - [x] **RECOMPOSE NEUTRAL CONTRACT UNCHANGED** — Re-run the independent typed source-location checker and prove
    its exact fixtures, transitions, recursive/structural cases, projections, callable identities, diagnostics,
    rollout, and mutation counts without changing contract or checker content.
  - [x] **RECOMPOSE PUBLIC TEACHING UNCHANGED** — Rebuild/link-check the complete mdBook, verify the governed linked-
    rule claims and five compatibility passages, prove zero stale praise, and confirm rendered readability without
    changing public teaching content.
  - [x] **RECOMPOSE GOVERNANCE UNCHANGED** — Re-run Knowledge Map, task/roadmap/live alignment, all doctrines, and
    exact public/capability markers without changing runtime, schema, helper, root README, or unrelated content.
  - [x] **DEFINITIVE CANONICAL SIGNOFF** — Run the repository-routed canonical local CI from the committed
    `.14.1.2` state and record exact containment, moved-root, CLI, memory, and Phase 0 results.
  - [x] **CLOSE / COMMIT / CLEAN** — Close parent `.14.1`, point the single next action to `.14.2`, update bounded
    continuity only, commit per `COMMIT.md`, clear the brief, and prove the clean boundary before pivoting.

  Activation evidence 2026-08-01: `.14.1.2` landed at `336781d6` as commit 134/300 with no push. Exact post-commit
  proof found empty status and staged/unstaged diffs, zero-byte `git_message_brief.txt`, activation pointer
  `e8f6198b` resolving to `HEAD^1`, synchronized Knowledge Map 784/6,363, no generated book or non-cache Python
  bytecode, and no unconsumed background result. At activation, `.14.1.3` became the sole active frontier and owned
  no-change recomposition plus its eventual task/continuity closeout; no contract, checker, implementation, or
  book-content change was authorized.

  Focused recomposition evidence 2026-08-01: the committed contract/checker and all six public teaching pages plus
  root `README.md` are unchanged from `336781d6`. The independent checker passes exact 3/7/6/3 fixture counts, 8+8
  transitions, six recursive observations, four structural cases, 92 projections plus seven aliases and two
  internal ids, 31 diagnostics, 1/13 rollout, and 36 rejected mutations. Capability remains schema v2 / 80-0-0 / two
  exclusions / 24+6 mutations / 12 public projections. The book rebuilds at 79 files / 14,120 KiB; its only new
  cross-page link resolves to the generated `choose-rule-shapes-by-responsibility` id, retired praise strings are
  absent, and direct HTML shows separate `h2`, `ul`, `pre`, and sibling `p` elements. Knowledge Map 784/6,363,
  memory/task metadata, whitespace, and all seven doctrines pass with only this task-tree leaf dirty.

  Definitive signoff evidence 2026-08-01: repository-routed canonical CI passes all seven doctrines, every neutral
  contract and focused Perl consumer, semantic and MCP admissions, project-data containment, moved-root and outside-
  CWD execution, CLI 66/66 in both default and POSIX environments, RAM 53%, and Phase 0 1,031/1,031 in 639 seconds
  before `local CI gate passed`. Contract, checker, runtime/schema/helper sources, root README, and all public book
  sources remain unchanged from `336781d6`. Parent `.14.1` is composition-closed; generated-book cleanup, commit,
  brief clearing, and exact clean proof precede `.14.2` activation.
  Commit: `FUTURE-PARITY-BACKLOG.14.1.3 - close typed source location contract`

- ID: `FUTURE-PARITY-BACKLOG.14.2`
  Status: `done; composition-closed` (2026-08-09; completed through no-change child `.14.2.7`, atomic 170/300,
    no push)
  Goal: Implement immutable position/span/provenance values and current-helper projections in the Perl reference,
    then admit the same neutral contract independently in Rust, Dart, Julia, PUC Lua, and LuaJIT.
  Children: `.14.2.0`, `.14.2.0.1`, `.14.2.1-.14.2.7`; backend parents `.14.2.1-.5` each own audit, core,
    projection/route, and admission children.

- ID: `FUTURE-PARITY-BACKLOG.14.2.0`
  Status: `done` (2026-08-01; signoff-complete from clean `0d1b7378`; intended 136/300, no push)
  Goal: Resolve the typed-source rollout-ledger contradiction and freeze the dependency-complete six-runtime
    immutable-value/helper-projection implementation plan before behavior code.
  Depends on: `.14.1.3`
  Acceptance: Retrieve ADR `0056`, the typed-source Knowledge card, contract/checker, and adjacent live-ledger
    precedents before re-derivation. Root-cause why completed owners `.14.1.2-.3` remain `pending` in the executable
    rollout and why the Knowledge card still says public teaching is pending; decide and evidence whether rollout is
    immutable planning data or live admission state. Use LinkedSpec toolbox and exact backend source/test probes to
    freeze immutable position/span/provenance representation, current-helper projection compatibility, public/API
    boundary, generated/descriptor/semantic exclusions, diagnostics, per-backend admissions, recurring topology,
    RED-first tests, storage, and child dependencies. Change no runtime, contract/checker, public book, or root README.

  ### `FUTURE-PARITY-BACKLOG.14.2.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.1.3` landed cleanly at `0d1b7378` as 135/300 with no
    push, empty status/diffs, zero-byte brief, synchronized Knowledge Map, absent generated book/non-cache
    bytecode, and no unconsumed background result before activating this task-tree-first audit.
  - [x] **ROOT-CAUSE ROLLOUT TRUTH** — Compare the contract/checker and `.14.1` history with adjacent live-ledger
    precedents, reproduce the stale public-leg acceptance, and freeze the correction owner without guessing.
  - [x] **TOOLBOX-LED RUNTIME AUTHORITY AUDIT** — Establish each backend's current source/cursor/capture value
    representation and helper result shape through documented probes plus source/test anchors before design.
  - [x] **FREEZE VALUE / PROJECTION CONTRACT** — Specify immutable source/position/span/provenance runtime shapes,
    validation/slicing/conversion ownership, helper compatibility rules, diagnostics, and exclusions without
    selecting uncontracted DSL syntax or breaking existing scalar/text results silently.
  - [x] **FREEZE SIX-RUNTIME ADMISSION PLAN** — Specify exact RED fixtures, backend children, composed consumers,
    rollout promotions, recurring driver, canonical opt-in, public/live synchronization, and project-local storage.
  - [x] **VERIFY / COMMIT / CLEAN** — Update only task/decision/Knowledge/status planning surfaces warranted by the
    audit, run complete non-behavior gates, commit, clear the brief, and prove clean before `.14.2.0.1` correction.

  Activation finding 2026-08-01: clean `.14.1.3` commit `0d1b7378` composition-closes public owners `.14.1.2-.3`,
  yet `typed_source_location_contract.json` and its checker still require those two rollout legs as `pending`, the
  checker reports only 1 complete / 13 pending, `capability_conformance/README.md` repeats that claim, and the
  canonical Knowledge card still says public teaching is pending. The discrepancy is non-routine and potentially
  foundational because adjacent neutral contracts treat rollout as live admission state. This leaf owns root-cause
  and an evidence-bound correction plan before any `.14.2` runtime implementation.

  Activation evidence 2026-08-01: `.14.1.3` landed at `0d1b7378` as 135/300 with no push. Its post-commit handoff
  had empty status and staged/unstaged diffs, a zero-byte untracked brief, synchronized Knowledge Map 784/6,363,
  no generated book or non-cache Python bytecode, and no background result. This audit was then activated by the
  sole task-tree diff from that clean boundary; no runtime, contract, checker, README, or book file moved first.

  Rollout root cause 2026-08-01: rollout is live admission state, not immutable planning metadata. The contract
  serializes exact status/owner/runtime rows, the checker compares those rows byte-semantically through `ROLLOUT`,
  reports current complete/pending totals, and adjacent governed contracts promote the same kind of rows as their
  owners land. `.14.1.2` deliberately excluded the contract while completing `public_structure`; `.14.1.3`
  deliberately required the contract unchanged while completing `neutral_public_recomposition`. Those two local
  no-contract rules left no owner for the mandatory promotions, and the sole rollout mutation only proved that a
  pending row could not become complete early. The checker therefore accepted stale pending state after both
  owners actually closed. Correction `.14.2.0.1` must promote those two rows independently, report 3 complete / 11
  pending, replace the one early-completion mutation with two independent completed-to-pending regressions (37
  total), update every exact 1/13 status projection and the existing Knowledge card, and re-owner the five pending
  runtime legs to their exact admission leaves `.14.2.1.3-.14.2.5.3`. Runtime behavior remains unchanged.

  Runtime authority evidence 2026-08-01: `TOOLBOX.md` was read in full before exact source and focused consumer
  probes. Perl uses decoded-string scalar offsets in `$IPOS`, `pos $$STRING`, match registers, rule-local mark
  buckets, and a shared cursor stack; `ActionIR/Contracts.pm` currently lowers helpers to `substr`, `length`, and
  line/column expressions. `LinkedRE::_build_match_info` propagates the mark authority to child calls. Rust and
  shared Lua keep cursor, match, capture, mark, and cursor-stack offsets as UTF-8 bytes. Dart and Julia keep those
  registers as host code-unit offsets. All four non-Perl interpreters already convert public offsets/line/column to
  Unicode-scalar coordinates and return ordinary text/number/null values. Their `generated_source_identity` or
  `source_identity` fields identify generated spec artifacts and are not input-source identities. The exact
  complete-named-mark consumer passes on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; the complete Lua package is
  177/177 on both ABIs. This proves the current compatibility baseline and the conversion seams without inferring
  behavior from `.spec` text.

  Frozen value/projection boundary 2026-08-01: each backend gets one runtime-internal source authority that owns
  the mapping from an opaque caller-authorized `source_id` to immutable decoded text. A position contains only
  `source_id` plus zero-based Unicode-scalar offset. A direct span contains only `source_id`, scalar start/end, and
  one frozen provenance label; derived text contains policy `concatenate_in_order` plus an immutable ordered span
  sequence. Values never contain copied text, paths, regex/match objects, mutable parser state, or host references.
  The authority alone validates source membership/bounds/order, derives one-based line/column and UTF-8 byte
  coordinates, slices text on demand, and materializes derived text explicitly. Backend cursors and registers stay
  in their efficient proven host units—Perl/scalar, Rust+Lua/byte, Dart+Julia/code unit—and convert only at this
  boundary. The four `.14.2` diagnostics are `source_location_source_mismatch`,
  `source_location_position_out_of_range`, `source_location_reversed_span`, and
  `source_location_invalid_derived_provenance`, with the contract's exact context and no source-text leak. Mark
  lifetime, transaction, recursion, progress, gap, and span-dispatch diagnostics remain exclusively `.14.3-.7`.

  Current helper names and result shapes are compatibility projections, not typed-value returns: 92 canonical
  calls plus seven callable aliases must still return the same string, scalar offset/length, one-based line/column,
  collection, boolean, null/undef, or cursor-control statement result. Capture-group list/map/text projections keep
  their existing regex-group authority. Mark writes and anonymous-boundary writes create positions internally but
  preserve existing mutation timing and scope; `save_cursor`/`restore_cursor` remain compatibility operations, not
  the future transaction API. No new DSL spelling or top-level facade is introduced. The native value modules are
  backend runtime support surfaces for engine code and exact tests; they are not a promise that `Position` or
  `Span` becomes an authored helper. Generated spec identity stays separate. Descriptor schemas, generated-family
  identity, semantic/MCP responses, parse results, and span-native dispatch do not change in `.14.2`.

  Frozen six-runtime implementation/admission plan 2026-08-01:

  1. `.14.2.0.1` corrects only the audited live ledger, checker mutations, status docs/book, Knowledge card, and
     exact runtime admission owners. It leaves the neutral fixtures and runtime behavior unchanged.
  2. Each backend parent runs four commits in order: `.0` writes a failing exact consumer before implementation;
     `.1` adds the immutable source/value/conversion core; `.2` routes the 92 current helper projections through
     that core while preserving all result and mutation behavior; `.3` consumes the unchanged neutral fixture in
     native plus existing generated/serialized/emitted paths, binds its command/path/roles in the checker, promotes
     only its rollout row, updates truthful sole-facing support status, and passes complete backend/canonical gates.
  3. Core consumers must exercise all 3 sources, 7 conversions, 6 direct spans, 3 derived texts, empty and
     multi-source cases, and all four owned diagnostics. Projection consumers must cover the exact 92-row map and
     seven aliases, Unicode host-unit conversion, parent/child mark isolation, absent values, capture mutation,
     and save/restore no-drift. Perl uses `perl/LinkedSpec/SourceLocation.pm`, `ActionIR/Contracts.pm`, `RuleIR.pm`,
     `SpecEntry.pm`, `perl/LinkedRE.pm`, `t/typed_source_location_values.t`, and
     `t/typed_source_location_perl_contract.t`. Rust uses
     `rust/linkedspec-runtime/src/source_location.rs`, `runtime.rs`, `engine.rs`, `lib.rs`, and
     `rust/linkedspec-runtime/tests/typed_source_location_contract.rs`. Dart uses
     `dart/lib/src/runtime/source_location.dart`, `matching.dart`, `interpreter.dart`, and
     `dart/test/typed_source_location_contract_test.dart`. Julia uses `julia/src/runtime/SourceLocation.jl`,
     `Matching.jl`, `Interpreter.jl`, `julia/src/LinkedSpecJulia.jl`, and
     `julia/test/typed_source_location_contract_test.jl`. Shared Lua uses
     `lua/src/linkedspec/source_location.lua`, `matching.lua`, `interpreter.lua`,
     `lua/test/typed_source_location_contract_test.lua`, and `lua/test/run.lua`, with the same source executed on
     PUC Lua and LuaJIT.
  4. No descriptor schema change is planned: native and loaded generated/serialized/emitted plans converge on the
     same interpreter/helper routes. Any proof that a schema/version change is actually required stops that leaf,
     records the finding, and creates a separately owned descendant before changing it.
  5. `.14.2.6` adds one repository-rooted driver that runs neutral checker, Perl, Rust, Dart, Julia, PUC Lua, and
     LuaJIT in that exact order through project-data wrappers; the checker binds the six runtime roles, five
     consumer paths, exact commands, route multiplicity, and canonical opt-in. `.14.2.7` recomposes unchanged and
     closes this value/helper slice. `.14.8` retains final program-wide examples/tooling/no-drift ownership.

  All RED fixtures, caches, outputs, package stores, and recurring commands use existing repository-derived
  project-data routing. No `/tmp`, user-home cache, new external dependency, hosted workflow, or push is planned.

  Signoff evidence 2026-08-01: focused proof passes the unchanged typed-source checker at exact 3/7/6/3 sources/
  positions/spans/derived texts, 8+8 transitions, six recursive/four structural cases, 92+7+2 helper identities,
  31 diagnostics, 1/13 rollout, and 36 mutations. Exact complete-named-mark consumers pass on Perl, Rust, Dart,
  Julia, PUC Lua, and LuaJIT; the complete shared Lua package passes 177/177 on each ABI. Knowledge Map is
  785/6,375, memory and Knowledge architecture checks pass, and all seven doctrines pass. The first canonical
  attempt correctly rejected removal of the checker-owned `.24.2` task-index projections; restoring both exact
  markers made capability schema v2 / 80-0-0 / two exclusions / 24+6 mutations green. A sandboxed rerun then
  reached relocated execution and failed only because nested macOS `sandbox-exec` was denied with status 71. The
  definitive permission-authorized repository-routed rerun passes containment, moved-root/outside-CWD execution,
  semantic/MCP admissions, CLI 66/66 in both default and POSIX environments, RAM 56%, and Phase 0 1,031/1,031 in
  657 seconds before `local CI gate passed`. No contract, checker, runtime, schema/helper, root README, or mdBook
  source changed. Commit, brief clearing, and exact clean proof precede `.14.2.0.1` activation.
  Commit: `FUTURE-PARITY-BACKLOG.14.2.0 - freeze typed value rollout plan`

- ID: `FUTURE-PARITY-BACKLOG.14.2.0.1`
  Status: `done` (2026-08-01; signoff-complete from clean `5a294f39`; intended 137/300, no push)
  Goal: Apply the audited rollout/Knowledge truth correction with independent stale-status mutations and no runtime
    behavior, then hand the exact implementation boundary to Perl.
  Depends on: `.14.2.0`
  Acceptance: Promote `public_structure` and `neutral_public_recomposition` to complete, re-owner pending runtime
    legs to `.14.2.1.3-.14.2.5.3`, advance exact status to 3/11, and make both public legs independently
    regression-proof by completed-to-pending mutations. Update the existing typed-source Knowledge card, capability
    guide, live/roadmap/task truth, and every stale sole-facing rollout claim. Preserve all neutral fixtures,
    runtime/helper behavior, grammar, descriptor/schema, semantic/MCP, generated source, and root README.

  ### `FUTURE-PARITY-BACKLOG.14.2.0.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / EXACT INVENTORY** — Prove `.14.2.0` landed cleanly at `5a294f39`, retrieve the new
    rollout-plan and existing typed-source Knowledge cards, and inventory every current exact 1/13, public-pending,
    runtime-owner, and 36-mutation projection before edits.
  - [x] **CORRECT LIVE ROLLOUT TRUTH** — Promote only `public_structure` and `neutral_public_recomposition`, re-owner
    only the five pending backend rows to exact `.14.2.1.3-.14.2.5.3` admission leaves, and preserve all fixtures,
    roles, order, commands, and runtime behavior.
  - [x] **LOCK INDEPENDENT REGRESSIONS** — Replace the obsolete pending-to-complete rollout mutation with two
    completed-to-pending public-row mutations, bind 3/11 plus 37 mutations independently, and prove each mutation
    fails for the intended stale-state reason.
  - [x] **SYNCHRONIZE SOLE-FACING TRUTH** — Correct the capability guide, existing Knowledge fact, exact live/
    roadmap/task projections, and every stale mdBook statement while preserving root README and all behavior.
  - [x] **VERIFY / COMMIT / CLEAN** — Run focused contract/mutations, public marker census, mdBook build/rendered
    structure/link checks, Knowledge Map, all doctrines, canonical CI, commit per `COMMIT.md`, clear the brief, and
    prove clean before activating Perl RED `.14.2.1.0`.

  Activation evidence 2026-08-01: planning leaf `.14.2.0` landed at `5a294f39` as 136/300 with no push. Post-commit
  proof found empty status and staged/unstaged diffs, zero-byte `git_message_brief.txt`, activation pointer
  `0d1b7378` resolving to `HEAD^1`, synchronized Knowledge Map 785/6,375, no generated book or non-cache Python
  bytecode, and no unconsumed background result. This task-tree file is the sole activation diff from that clean
  boundary; no contract, checker, Knowledge fact, public document, runtime, or root README changed first.

  Implementation evidence 2026-08-01: Knowledge retrieval identified the neutral-contract and runtime-rollout
  cards before the exact current-claim census. Current stale projections were one capability-guide paragraph,
  three mdBook passages, and the neutral Knowledge status/prose; explicitly dated `.14.1.1-.3` landing evidence
  remains historical. The JSON and checker now promote only `public_structure` and
  `neutral_public_recomposition`, leave all 11 future rows pending, and re-owner the five backend rows to exact
  `.14.2.1.3-.14.2.5.3` admission leaves. Two separate completed-to-pending mutations each require the exact
  rollout mismatch diagnostic; the independent checker passes unchanged neutral counts at 3/7/6/3, 8+8, 6/4,
  92+7+2, and 31 diagnostics with current rollout 3/11 and 37 mutations. Capability, both Knowledge cards, and all
  three sole-facing pages now distinguish completed structural teaching from future typed values/runtime admission.
  Root README and every runtime/helper/schema/semantic/generated artifact remain unchanged.

  Verification tooling finding 2026-08-01: the first rendered-book build used a repository-relative custom
  `--dest-dir`. `tools/run_mdbook_local.sh` validated that relative path against `docs/linkedspec-book`, but it
  launches mdBook from the repository root, where mdBook resolved the same argument against a different base and
  attempted an off-repository path before the sandbox denied it. A runtime-derived absolute repository-scratch
  destination builds correctly. This validation/execution base mismatch is unrelated to typed-source truth and is
  not repaired while this tree is dirty; create a dedicated tracked task at the next clean boundary before other
  feature work.

  Signoff evidence 2026-08-01: the direct checker passes exact unchanged neutral 3/7/6/3, 8+8, 6/4, 92+7+2,
  and 31 diagnostics with current rollout 3 complete / 11 pending and 37 rejected mutations. Capability remains
  schema v2 / 80-0-0 / two exclusions / 24+6 mutations. Knowledge Map is 785/6,375, memory is 56/60, and all seven
  doctrines pass. The complete mdBook builds 79 files / 14,120 KiB; direct generated HTML proves each corrected
  statement is a separate paragraph. The in-app browser control surface was unavailable, so no viewport/screenshot
  claim is made. Definitive canonical CI passes containment, moved-root/outside-CWD execution, semantic/MCP
  admissions, CLI 66/66 in both default and POSIX environments, RAM 46%, and Phase 0 1,031/1,031 in 645 seconds
  before `local CI gate passed`. Root README and all runtime/helper/schema/semantic/generated behavior remain
  unchanged. Commit, brief clearing, generated-book cleanup, and exact clean proof precede creation of dedicated
  `MDBOOK-DESTINATION-ROOT-ALIGNMENT` tracking and then Perl `.14.2.1.0`.
  Commit: `FUTURE-PARITY-BACKLOG.14.2.0.1 - correct typed source rollout truth`

- ID: `FUTURE-PARITY-BACKLOG.14.2.1`
  Status: `completed` parent (all four Perl children landed; closure reverified by `.14.2.7`)
  Goal: Implement and admit the immutable typed source-location algebra in the Perl reference while preserving
    existing helper compatibility through explicit projections.
  Children: `.14.2.1.0` authority/RED audit; `.14.2.1.1` immutable value/conversion core; `.14.2.1.2` helper
    projections and owned runtime routes; `.14.2.1.3` exact composed Perl admission and rollout promotion.
  Acceptance: `.0` consumes the frozen fixture through failing `t/typed_source_location_values.t` and
    `t/typed_source_location_perl_contract.t`; `.1` adds `perl/LinkedSpec/SourceLocation.pm`; `.2` routes exact
    projection construction through `ActionIR/Contracts.pm`, `RuleIR.pm`, `SpecEntry.pm`, and `perl/LinkedRE.pm`
    without changing results; `.3` proves live/generated Unicode execution, registers the exact consumer, promotes
    only `perl_runtime`, and updates sole-facing support truth.

- ID: `FUTURE-PARITY-BACKLOG.14.2.1.0`
  Status: `done; signoff-complete` (2026-08-01; task-tree-first from clean `5d1f287d`,
    intended 140/300, no push)
  Goal: Reconfirm the Perl decoded-input/cursor/helper authorities and freeze executable RED consumers for the
    immutable value core and compatibility projection before production code.
  Depends on: `.14.2.0.1`; closed `MDBOOK-DESTINATION-ROOT-ALIGNMENT`
  Acceptance: Retrieve the typed-source runtime-rollout and neutral-contract Knowledge cards, ADR `0056`, contract/
    checker, and TOOLBOX before source archaeology. Use LinkedSpec probes plus exact source/test anchors to bind the
    current Perl scalar offset, decoded text, capture/mark/cursor-stack, helper-lowering, generated-route, diagnostic,
    and project-data seams. Add exact unregistered RED consumers `t/typed_source_location_values.t` and
    `t/typed_source_location_perl_contract.t` that consume the neutral fixture, fail only because the frozen module/
    projection interfaces do not exist yet, and introduce no implementation or canonical registration. Record the
    expected failures, mutation-resistant assertions, next `.1-.3` ownership, public/book boundary, and complete
    focused non-behavior signoff before commit/clean.
  Verification: exact RED and focused nonbehavior baselines, all doctrines, and canonical CI pass; continuity is
    synchronized for commit/clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.1.0 - lock Perl typed source RED`

  ### `FUTURE-PARITY-BACKLOG.14.2.1.0` Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Prove mdBook safety `.1` landed cleanly at `5d1f287d` as 139/300 with empty
    status/diffs, zero-byte brief, correct `HEAD^1` activation pointer, absent generated book/non-cache bytecode,
    and no background result; activate this leaf as the sole task-tree diff before source/test changes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve canonical Knowledge/ADR/contract/TOOLBOX authority first, then use
    LinkedSpec probes and exact source/test anchors to bind current decoded-source identity, scalar positions,
    capture/mark/cursor state, helper lowering, generated routes, and the precise missing typed seams.
  - [x] **FIX** — Add only two exact unregistered RED consumers, with shared neutral-fixture loading and explicit
    future module/projection interfaces; do not add production implementation, canonical registration, or a schema.
  - [x] **ADDRESSED (verified)** — Run each consumer and prove its nonzero status and diagnostic identify only the
    intended missing module/projection seam; prove current complete-named-mark/helper/generated baselines remain green.
  - [x] **NO REGRESSION** — Pass shell/Perl syntax where applicable, neutral contract/checker, capability, storage,
    memory, Knowledge, task metadata, all doctrines, and canonical CI while keeping the RED consumers unregistered.
  - [x] **LOCKSTEP** — Record exact RED/authority evidence, task/index/roadmap/architecture/change/development/live/
    memory continuity, and why sole-facing support truth remains unchanged until admission `.14.2.1.3`; update
    Knowledge for any durable causal fact established by the audit.

  Activation evidence 2026-08-01: `MDBOOK-DESTINATION-ROOT-ALIGNMENT.1` landed at `5d1f287d` as 139/300 with no
  push. Post-commit proof found empty status and staged/unstaged diffs, zero-byte `git_message_brief.txt`, activation
  pointer `33b0fb2c` resolving to `HEAD^1`, no generated book or non-cache Python bytecode, and no background
  result. This task-tree file is the sole activation diff; no Perl source, test, contract, checker, book, Knowledge,
  capability, root README, or runtime behavior changed first.

  Authority/root-cause evidence 2026-08-01: the runtime-rollout and neutral-contract Knowledge cards, ADR `0056`
  section 9, the complete neutral JSON/checker value/projection/diagnostic invariants, and `TOOLBOX.md` facade/
  lowering/descriptor/generated-source probes were retrieved before source inspection. Live
  `call_spec_handler_subst` still lowers position helpers directly to `$IPOS`, `$LSPOS`, `pos $$STRING`, and
  `length($$STRING)`; marks are rule-label buckets of scalar offsets and the cursor stack is a scalar-offset array.
  `return_descriptor` reports the expected canonical helper nodes with zero fallback, and generated handler source
  comes from the same lowering records. `SpecEntry::_build_handler_preamble` captures decoded Perl scalar position
  in `$IPOS`; `RuleIR::_collect_rule_ir` writes `@mark` offsets; `LinkedRE::_build_match_info` shares only the mark
  authority with child calls; and `SpecEntry::_build_runtime_handler` converts thrown handler errors to the current
  generic runtime-handler context. Generated-source identity remains spec-artifact identity, not input identity.
  Therefore the two exact missing seams are the absent `LinkedSpec::SourceLocation` decoded-source/value authority
  and absent `LinkedSpec::ActionIR::Contracts::typed_source_projection_rows` plus typed lowering routes. These
  consumers read tracked JSON only and allocate no cache, temporary workspace, or output.

  Frozen RED interface 2026-08-01: `t/typed_source_location_values.t` fixes
  `LinkedSpec::SourceLocation->new(sources => \%decoded_text)`, immutable `position`, `direct_span`, and
  `derived_text` constructors, detached `as_record` projections, authority-owned `coordinates`/`materialize`, and
  structured `LinkedSpec::SourceLocation::Error` values. It consumes all 3 sources, 7 conversions, 6 direct spans,
  3 derived cases including empty/multi-source provenance, caller-snapshot isolation, and exactly the four `.14.2`
  diagnostic codes/contexts/privacy rules. `t/typed_source_location_perl_contract.t` freezes the internal
  `typed_source_projection_rows` catalog as a detached exact 92-row snapshot, typed routes for all four helper
  families plus seven aliases, and unchanged live/generated complete-named-mark results. No facade/DSL spelling,
  descriptor schema, neutral contract, runtime implementation, or canonical registration is introduced.

  Exact RED/focused evidence 2026-08-01: the 302-line value consumer exits 2 before TAP with only
  `Can't locate LinkedSpec/SourceLocation.pm`; an in-memory constructor sentinel proves the whole file parses and
  reaches that future seam. The 168-line projection consumer parses cleanly and exits 1 with exactly one failed
  assertion of three, naming absent `typed_source_projection_rows`; its remaining future subtest is skipped. An
  exact repository census finds neither consumer registered outside this owning tree. The unchanged neutral
  checker passes 3/7/6/3, 8+8, 6/4, 92+7+2, 31 diagnostics, rollout 3/11, and 37 mutations. Existing complete named
  marks pass; rule-local cursor contract/descriptor/execution pass 288/31/85 tests; standalone generated source
  passes all six subtests. The first canonical attempt correctly stops at its tracked-input audit because new files
  under `t/` were still untracked. Canonically *unregistered* means tracked but absent from driver invocation, not
  absent from Git; staging the exact leaf preserves the intended RED exclusion and is required before the rerun.
  The staged rerun then passed doctrines, tracked-input, syntax, and memory-pointer proof before the capability
  checker rejected the refreshed task-index row for omitting its exact governed historical marker
  `exclusion public closeout .24.2`. Restoring that literal preserves both the prior `.24.2` public closeout and the
  current Perl frontier; focused capability proof passed before the definitive canonical rerun.

  Signoff evidence 2026-08-01: the definitive canonical rerun passes all seven doctrines, tracked-input and syntax
  audits, memory activation, capability 80/0/0, typed-source 3/11/37, storage/relocation, every composed semantic
  and MCP admission, both primary CLI environments at 66/66, RAM at 46% against the 88% ceiling, and Phase 0 at
  1,031/1,031 in 658 seconds before the exact `local CI gate passed` marker. The two RED consumers remain tracked
  but absent from canonical invocation, and no generated book or non-cache Python bytecode remains. Task, roadmap,
  architecture, changes, development, live status, memory, and the typed-source Knowledge fact are synchronized;
  sole-facing mdBook source and root README remain unchanged because public runtime admission is still owned by
  `.14.2.1.3`. Commit, brief clearing, and exact clean proof precede activation of immutable core `.14.2.1.1`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.1.1`
  Status: `done; signoff-complete` (2026-08-01; task-tree-first from clean `c912120b`, intended 141/300, no push)
  Goal: Implement the immutable Perl decoded-source authority and typed position/span/derived-text value core,
    making only the value RED consumer green while preserving the projection RED boundary for `.14.2.1.2`.
  Depends on: `.14.2.1.0`
  Acceptance: Retrieve the typed-source runtime-rollout Knowledge card and frozen value consumer before source
    work. Add only `perl/LinkedSpec/SourceLocation.pm` with one snapshot-owning decoded-source authority, immutable
    `Position`, `Span`, `DerivedText`, and structured `Error` values, detached `as_record` projections, exact
    scalar/UTF-8/UTF-16/line-column conversions, direct/derived materialization, and the four frozen diagnostic
    codes/contexts/privacy rules. Keep `typed_source_projection_rows` absent so the separate projection consumer
    remains RED for exactly its assigned seam. Add no helper routing, runtime registration, schema/DSL/facade,
    canonical invocation, public support claim, or unrelated cleanup. Pass the value consumer, preserve the exact
    projection RED, run focused existing baselines plus doctrines/canonical CI, synchronize durable/live records,
    commit, clear the brief, and prove clean before `.14.2.1.2`.
  Verification: immutable value GREEN, exact projection RED, focused compatibility, all doctrines, and canonical
    CI pass; continuity is synchronized for commit/clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.1.1 - add immutable Perl typed source core`

  ### `FUTURE-PARITY-BACKLOG.14.2.1.1` Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Prove `.14.2.1.0` landed at clean `c912120b` as 140/300 with empty status/diffs,
    zero-byte brief, activation parent `5d1f287d`, absent generated book/non-cache bytecode, and no background gate;
    activate this leaf as the sole task-tree diff before production changes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Re-retrieve the canonical Knowledge/ADR/fixture authority, enumerate every
    constructor, record, conversion, materialization, snapshot, immutability, error, and privacy assertion, and bind
    the smallest Perl module design without re-deriving already logged runtime projection facts.
  - [x] **FIX** — Implement only the decoded-source authority and immutable value/error core in
    `perl/LinkedSpec/SourceLocation.pm`; keep ActionIR projections and all runtime routes absent.
  - [x] **ADDRESSED (verified)** — Make all value-contract assertions green, including hostile bounds/source/
    provenance cases, while the projection consumer still fails only for absent `typed_source_projection_rows`.
  - [x] **NO REGRESSION** — Pass syntax, neutral typed-source, existing mark/cursor/generated baselines, capability,
    storage, memory, Knowledge, task metadata, all doctrines, and canonical CI.
  - [x] **LOCKSTEP** — Synchronize task/index/roadmap/architecture/change/development/live/memory and durable
    Knowledge without changing sole-facing mdBook support truth before admission `.14.2.1.3`.

  Activation evidence 2026-08-01: RED leaf `.14.2.1.0` landed at `c912120b` as 140/300 with no push. Its post-commit
  hook proves activation commit `5d1f287d` is `HEAD^1`; independent proof finds empty status and staged/unstaged
  diffs, zero-byte `git_message_brief.txt`, no generated book or non-cache Python bytecode, and no unconsumed local
  gate process. This task-tree file is the sole activation diff; no module, test, contract, checker, Knowledge,
  roadmap, book, root README, or runtime behavior changed first.

  Implementation evidence 2026-08-01: canonical Knowledge, ADR `0056` section 9, all 3/7/6/3 value fixtures, four
  diagnostic rows, and the committed RED consumer were re-retrieved before code. New
  `perl/LinkedSpec/SourceLocation.pm` follows the established private-state source-map pattern: the authority owns a
  caller-detached decoded-text snapshot and precomputed scalar-boundary line/column/UTF-8-byte tables. Opaque token
  values resolve through module-private state keyed by object address and a monotonic authority id; position/span/
  derived records contain only frozen neutral fields, derived values clone ordered span records, and every
  `as_record` is detached. The authority alone checks bounds/source/order/provenance and materializes text. Locked
  `LinkedSpec::SourceLocation::Error` hashes copy only the two authorized role fields plus exact diagnostic context,
  preventing decoded text, paths, parser/match state, or host references from crossing the error boundary.

  Focused evidence 2026-08-01: module syntax passes and the formerly RED value consumer passes all seven top-level
  groups, including seven coordinate conversions, six direct spans, three derived texts, 76 exact diagnostic/
  privacy assertions, and caller snapshot isolation. A lifecycle smoke additionally proves empty materialization,
  deep derived-record detachment, semantic immunity to token mutation, and locked errors. The projection consumer
  remains exact RED with one failed assertion of three naming only absent `typed_source_projection_rows`; its
  future body remains skipped. Neutral 3/11/37, complete marks, cursor 288/31/85, and all six generated-source
  subtests remain green. No ActionIR, runtime route, schema, registration, book, or root README changes.

  Signoff evidence 2026-08-01: the exact module/value/projection boundary, lifecycle smoke, neutral 3/11/37,
  complete named marks, cursor 288/31/85, generated source, capability schema v2 at 80/0/0 with two exclusions,
  24 governance mutations and 12+6 projections, memory, Knowledge Map 785/6,385, task metadata, and all seven
  doctrines pass. Definitive canonical CI additionally passes containment, moved-root/outside-CWD execution,
  every composed semantic and MCP admission, both primary CLI environments at 66/66, RAM at 47% against the 88%
  ceiling, and Phase 0 at 1,031/1,031 in 633 seconds before the exact `local CI gate passed` marker. The optional
  backend matrices remain intentionally outside the default canonical invocation; their owned admission suites
  passed earlier in the same gate. Sole-facing mdBook source and root README remain unchanged because internal
  projection and Perl runtime admission are still owned by `.14.2.1.2-.3`. Commit, brief clearing, and exact clean
  proof precede task-tree-first activation of projection leaf `.14.2.1.2`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.1.2`
  Status: `signoff-complete` (2026-08-01; task-tree-first from clean `2dceb96e`, intended 142/300, no push)
  Goal: Route every existing Perl source-boundary helper and callable alias through the immutable typed source core
    while preserving its exact external result, absence value, mutation behavior, and live/generated identity.
  Depends on: `.14.2.1.1`
  Acceptance: Retrieve the runtime-rollout Knowledge card, ADR `0056`, frozen projection consumer, neutral fixture,
    and TOOLBOX before source work. Add a detached exact 92-row
    `LinkedSpec::ActionIR::Contracts::typed_source_projection_rows` catalog and bind the four frozen helper families
    plus seven aliases to `LinkedSpec::SourceLocation` through the owned `ActionIR/Contracts.pm`, `RuleIR.pm`,
    `SpecEntry.pm`, and `perl/LinkedRE.pm` seams. Preserve decoded Perl scalar registers and all current helper
    results/absence/mutations, live versus standalone-generated execution, mark/cursor lifetimes, parser output,
    diagnostic behavior, and generated/descriptor schemas. Make the projection consumer fully green but leave it
    canonically unregistered until admission `.14.2.1.3`. Add no DSL/facade/public claim, schema change, semantic/
    MCP projection, root README or mdBook support prose, runtime rollout promotion, or unrelated cleanup. Pass exact
    focused consumers, existing source-boundary baselines, doctrines/canonical CI, synchronize durable/live records,
    commit, clear the brief, and prove clean before `.14.2.1.3`.
  Verification: exact 92-row/seven-alias projection consumer 3/3 and focused source/mark/cursor/generated baselines
    423/423 pass; definitive canonical CI passes CLI 66/66 twice, RAM 53%, and Phase 0 1,031/1,031 in 651 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.14.2.1.2 - route Perl typed source projections`

  ### `FUTURE-PARITY-BACKLOG.14.2.1.2` Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Prove immutable core `.14.2.1.1` landed cleanly at `2dceb96e` as 141/300 with
    empty status/diffs, zero-byte brief, activation parent `c912120b`, absent generated book/non-cache bytecode,
    and no background gate; activate this leaf as the sole task-tree diff before production work.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve canonical Knowledge/ADR/fixture/TOOLBOX authority, run the exact
    projection RED, and map each current ActionIR lowering, handler preamble, rule mark/cursor state, child-call
    sharing seam, and live/generated execution route without re-deriving facts already logged.
  - [x] **FIX** — Add the exact detached 92-row catalog and the smallest typed construction/projection plumbing for
    all four helper families and seven aliases; preserve scalar runtime registers and every external value.
  - [x] **ADDRESSED (verified)** — Make all three projection-consumer assertions green, prove every row/alias routes
    through the typed authority, and preserve exact live plus standalone-generated complete named-mark results.
  - [x] **NO REGRESSION** — Pass module/test syntax, value and projection consumers, neutral typed-source,
    mark/cursor/generated/helper baselines, capability, storage, memory, Knowledge, task metadata, all doctrines,
    and canonical CI while leaving the consumer unregistered.
  - [x] **LOCKSTEP** — Synchronize task/index/roadmap/architecture/change/development/live/memory and durable
    Knowledge without changing the sole-facing mdBook or rollout 3/11 truth before admission `.14.2.1.3`.

  Activation evidence 2026-08-01: immutable-core leaf `.14.2.1.1` landed at `2dceb96e` as 141/300 with no push.
  Post-commit proof finds parent `c912120b`, empty status and staged/unstaged diffs, zero-byte
  `git_message_brief.txt`, activation commit `c912120b` resolving to `HEAD^1`, no generated book or non-cache Python
  bytecode, and no unconsumed canonical/doctrine/typed-source process. This task-tree file is the sole activation
  diff; no ActionIR, RuleIR, SpecEntry, LinkedRE, test, Knowledge, roadmap, book, root README, or runtime behavior
  changed first.

  Reproduction/root-cause evidence 2026-08-01: the runtime-rollout Knowledge card, ADR `0056` section 9, complete
  92+7 projection JSON, committed RED consumer, and TOOLBOX lowering/descriptor/generated-source commands were
  retrieved before production inspection. The consumer exits 1 with exactly one failed assertion of three naming
  absent `typed_source_projection_rows`. Nine representative `call_spec_handler_subst` probes lower directly to
  `substr`, scalar arithmetic, raw mark buckets, `pos`, and the scalar cursor stack, with no typed route. A
  descriptor probe retains canonical `MATCH_TEXT_READ`, while independently emitted source contains no
  `LinkedSpec::SourceLocation` call. Exact source mapping finds the authority must initialize in
  `SpecEntry::_build_handler_preamble`, propagate with match state in `LinkedRE::_build_match_info`, wrap ActionIR
  compatibility projections in `ActionIR/Contracts.pm`, and round-trip rule-level `@mark`/anonymous-boundary writes
  in `RuleIR.pm`/the handler emitter. Existing raw scalar registers remain the external/mutation authority;
  capture-group text/list/map values remain owned by regex snapshots as frozen by `.14.2.0`.

  Implementation evidence 2026-08-01: `SpecEntry` now creates or reuses one `input` source authority before the
  handler initializes `$IPOS`; `LinkedRE` propagates that authority, source id, and the existing shared mark hash to
  child matches. The source module's internal `Runtime` boundary constructs typed positions/spans for text,
  length, offset, coordinate, capture-boundary, mark, cursor, and source projections while returning the exact
  legacy scalar/string/list/map/boolean/absence shapes. Mark and cursor stacks intentionally remain scalar storage,
  but every write/read crosses typed range validation. RuleIR `MOVE_POS`/`@mark`, both handler IMATCH bridges,
  nested MethodLowering entry/match/input expressions, and all contract helper lowerings use that boundary. Normal
  `input_slice` bounds materialize through a typed span; legacy negative/overrun Perl `substr` behavior stays an
  explicit compatibility fallback. The exact four-family 92-row catalog is rebuilt on every call, so caller
  mutation cannot alter canonical routing. No schema, generated-plan format, DSL/facade, registration, or public
  support claim changed.

  Focused evidence 2026-08-01: the strengthened projection consumer checks all 92 emitted projection functions,
  all seven aliases, catalog detachment, live complete named-mark output, and independently emitted/loaded source;
  all three top-level assertions and 202 nested assertions pass. The seven-suite source/value/mark/cursor/generated
  group passes 423/423 in 72 seconds. The first full Phase 0 migration run exposed only 88 stale emitted-text
  expectations; after exact baseline migration, a second run isolated one nested `entry_text` expectation, its
  direct one-case proof passed, and the authoritative rerun passes all 1,031 top-level tests in 662 seconds. All
  touched module/test syntax and `git diff --check` pass. The projection consumer remains intentionally outside
  canonical registration until `.14.2.1.3`.

  Signoff evidence 2026-08-01: neutral typed-source governance passes exact 3/7/6/3 value fixtures, 8+8 state
  transitions, six recursive/four structural cases, 92+7+2 identities, 31 diagnostics, rollout 3/11, and 37
  mutations. Capability remains schema v2 at 80/0/0 with two exclusions, 24 governance mutations, 12 governed
  projections, and six public mutations. Knowledge Map is 785/6,389; memory, task metadata, storage, whitespace,
  and all seven doctrines pass. The first canonical attempt exposed one stale exact `capture_slice` emitted-text
  expectation in the focused ActionIR suite; updating it to the typed `span_text` route restored 23/23. The next
  sandboxed run reached process-locality proof and failed only because Codex's enclosing sandbox denied nested
  macOS `sandbox-exec` with status 71. The identical permission-authorized canonical run passes the relocated
  six-family containment oracle, moved-root/outside-CWD execution, every composed semantic/MCP admission, CLI
  66/66 under both default and POSIX option environments, RAM 53% against the 88% ceiling, and Phase 0
  1,031/1,031 in 651 seconds before `local CI gate passed`. Root README, sole-facing mdBook, rollout 3/11,
  registration, schema, DSL/facade, and public support remain unchanged. Commit, brief clearing, and exact clean
  proof precede task-tree-first admission `.14.2.1.3`; no push.

- ID: `FUTURE-PARITY-BACKLOG.14.2.1.3`
  Status: `done; signoff-complete` (2026-08-01; task-tree-first from clean `98765354`, intended 143/300, no push)
  Goal: Admit the already implemented Perl typed source-location value/projection routes compositionally, promote
    only the `perl_runtime` rollout leg, and publish the exact sole-facing support truth without changing helper
    results or introducing authored typed-value syntax.
  Depends on: `.14.2.1.2`
  Acceptance: Retrieve the runtime-rollout Knowledge card, ADR `0056` section 9, neutral contract/checker, both
    committed Perl consumers, current canonical registration, and every sole-facing typed-source status passage
    before implementation. Register `t/typed_source_location_values.t` and
    `t/typed_source_location_perl_contract.t` as required, syntax-checked, unconditionally executed canonical Perl
    consumers. Promote only `perl_runtime` from pending to complete in the neutral artifact and independent checker,
    add one exact completed-to-pending Perl regression, and advance the locked mutation count and rollout summary
    from 3/11/37 to 4/10/38. Update the mdBook's capture/source-location mental model, project status, and canonical
    CI explanation so users can distinguish admitted internal Perl values/projections from absent public
    `Position`/`Span` objects, transaction syntax/behavior, other backend admissions, and later `.14.3-.8` work.
    Preserve all production runtime/helper code, external results, descriptor/generated schemas and identities,
    semantic/MCP and capability state, DSL/facade spellings, root README, and the independent nonurgent rendered-
    readability tree. Pass exact focused admission, neutral mutation proof, book build/rendered paragraph checks,
    doctrines/canonical CI, synchronize all durable/live records, commit, clear the brief, and prove clean before
    task-tree-first Rust `.14.2.2.0`.
  Verification: exact Perl composed admission passes 10 tests; rollout 4/10/38, mdBook build/rendered paragraphs,
    capability 80/0/0, all seven doctrines, repository containment/relocation, CLI 66x2, RAM 53%, and canonical
    Phase 0 1,031/1,031 in 650 seconds pass
  Commit: `FUTURE-PARITY-BACKLOG.14.2.1.3 - admit Perl typed source runtime`

  ### `FUTURE-PARITY-BACKLOG.14.2.1.3` Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Prove projection `.14.2.1.2` landed cleanly at `98765354` as 142/300 with empty
    status/diffs, zero-byte ignored brief, activation parent `2dceb96e`, no generated book/non-cache bytecode, and
    no background gate; activate this leaf as the sole task-tree diff before contract/checker/CI/book changes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve canonical Knowledge/ADR/contract/checker/consumer/CI/book authority,
    prove current runtime code and both consumers are green while registration and `perl_runtime` promotion alone
    remain absent, and inventory every sole-facing 3/11/future-Perl claim without archaeology.
  - [x] **FIX** — Register both consumers, promote only the Perl rollout row, add its independent regression and
    38-mutation lock, and update exact mdBook support/status/CI prose without production or public API behavior.
  - [x] **ADDRESSED (verified)** — Prove canonical registration is exact and unconditional, both consumers execute
    live/generated Unicode routes, neutral truth is 4 complete / 10 pending with 38 mutations, and rendered book
    paragraphs clearly separate admitted Perl internals from future authored values/backends/transaction work.
  - [x] **NO REGRESSION** — Pass consumer/checker syntax and focused execution, book validation/build, capability,
    storage, memory, Knowledge, task metadata, all doctrines, and definitive canonical CI with runtime code unchanged.
  - [x] **LOCKSTEP** — Synchronize contract/checker/CI/book/task/index/roadmaps/architecture/change/development/live/
    memory and durable Knowledge at 4/10/38; keep root README and unrelated future/readability trees unchanged.

  Activation evidence 2026-08-01: projection `.14.2.1.2` landed at `98765354` as 142/300 with no push. Its commit
  hook regenerated Knowledge Map 785/6,389, passed all seven doctrines, and proved activation `2dceb96e` as both
  pre-commit HEAD and post-commit `HEAD^1`. Post-commit proof finds empty status and staged/unstaged diffs, a
  zero-byte ignored `git_message_brief.txt`, exact parent `2dceb96e`, no generated book or non-cache Python
  bytecode, and no canonical/Phase-0/typed-source/mdBook process. This task-tree file is the sole activation diff;
  no contract, checker, canonical driver, consumer, book, Knowledge, roadmap, root README, or runtime behavior
  changed first.

  Root-cause evidence 2026-08-01: the runtime-rollout Knowledge card, ADR `0056` section 9, exact neutral JSON/
  checker rollout and mutation code, both committed consumers, canonical driver registration/syntax/execution
  sections, and all mdBook typed-source matches were retrieved before implementation. Both consumers already pass
  together at 10 top-level tests in 11 seconds and the neutral checker passes exact 3/7/6/3, 8+8, 6/4,
  92+7+2, 31 diagnostics, rollout 3/11, and 37 mutations. Exact CI scan proves neither consumer is required,
  syntax-checked, or executed. The sole-facing capture chapter, project-status opening and later roadmap list,
  local-CI chapter, and backend-handoff introduction still classify every runtime admission as future. Therefore
  admission needs only contract/checker truth, exact canonical registration, and those four book pages; no
  production source, helper result, test semantics, descriptor/schema, generated identity, or root README change
  is required.

  Signoff evidence 2026-08-01: both consumers are required, syntax-checked, and executed exactly once together by
  the canonical driver; their 10 tests pass in 11 seconds. The independent neutral checker reports exact 3/7/6/3,
  8+8, 6/4, 92+7+2, 31 diagnostics, rollout 4/10, and 38 mutations including the Perl completed-to-pending
  regression. A repository-local mdBook build succeeds and generated HTML inspection proves distinct paragraphs
  around rollout status, admitted Perl internals, remaining future work, and the canonical consumer command. The
  first definitive gate stopped only because a current task-index rewrite dropped the capability checker's exact
  historical `.24.2` marker; restoring that still-true phrase returned capability governance to schema v2,
  80/0/0, 24+6. The complete rerun passes all seven doctrines, typed admission, composed semantic/MCP consumers,
  repository containment and moved-root/outside-CWD proof, CLI 66/66 in both environments, RAM 53%, and Phase 0
  1,031/1,031 in 650 seconds before exact `[ci] local CI gate passed`. No production runtime/helper, result shape,
  scalar mark/cursor storage, schema/identity, DSL/facade, semantic/MCP, root README, or broad readability work
  changed. Commit, brief clearing, and exact clean proof precede task-tree-first Rust `.14.2.2.0`; no push.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2`
  Status: `completed` parent (all audit, correction, parity, RED, core, projection, and exact admission children
    landed; closure reverified by `.14.2.7`)
  Goal: Implement and independently admit the same neutral typed source-location algebra in Rust.
  Children: `.14.2.2.0` authority/split audit; `.14.2.2.0.1` neutral alias-target correction;
    `.14.2.2.0.2` five-alias Rust parity; `.14.2.2.0.3` exact typed-source RED; `.14.2.2.1` immutable
    value/conversion core; `.14.2.2.2` helper/unchanged loaded-generated-plan interpreter routes; `.14.2.2.3`
    exact admission/promotion.
  Acceptance: Use `source_location.rs`, `runtime.rs`, `engine.rs`, `lib.rs`, and
    `tests/typed_source_location_contract.rs`; retain byte registers, convert at the typed boundary, prove native/
    serialized/emitted/generated execution without schema change, bind the consumer, and promote only `rust_runtime`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.0`
  Status: `signoff-complete` (2026-08-07; authority audit/split verified from clean `82be51f0`, intended 144/300,
    no push)
  Goal: Map the exact Rust byte-offset, source-text, helper, native/loaded/reconstructed/generated, and diagnostic
    authorities; stop before freezing the RED when the supposedly unchanged helper baseline is false, make every
    discovered contradiction durable, and split exact prerequisite owners before any Rust behavior change.
  Depends on: `.14.2.1.3`, `.14.2.0`
  Acceptance: Retrieve the typed-source runtime-rollout Knowledge card, ADR `0056` section 9, neutral artifact and
    checker, admitted Perl consumer precedent, Rust runtime/source/generated/diagnostic Knowledge owners, Toolbox,
    exact Rust source and existing tests, complete Rust driver, and canonical registration before implementation.
    Prove current byte registers, caller-authorized decoded input owner, Unicode scalar/line/column/UTF-8 conversion
    seams, all 92 helper and seven alias routes, mark/cursor behavior, native plus loaded/reconstructed/emitted/
    generated convergence, exact structured-error boundary, Cargo test discovery, and every alias through executable
    probes rather than `.spec` inspection. If the seven-alias premise or neutral target identity is false, add no
    RED or implementation; record the exact Perl/Rust outputs, freeze dependency-ordered correction/parity/RED
    children, and preserve runtime, neutral contract/checker, schema/identity, public DSL/facade, semantic/MCP,
    capability, root README, and sole-facing mdBook behavior until those children activate from clean commits. Pass
    unchanged focused Rust/neutral baselines, storage/governance/canonical signoff, synchronize durable/live records,
    commit, clear the brief, and prove clean before `.14.2.2.0.1`.
  Verification: authority/executable probes, neutral 4/10/38, focused repeated-action 8/10/54 after exact durable
    handoff restoration, Knowledge Map 786/6,400, all seven doctrines, capability 80/0/0, composed semantic/MCP,
    repository containment/relocation, CLI 66/66 twice, RAM 43%, and Phase 0 1,031/1,031 in 681 seconds pass before
    `[ci] local CI gate passed`
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.0 - split Rust typed source prerequisites`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.0` Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Prove Perl admission `.14.2.1.3` landed cleanly at `82be51f0` as 143/300 with empty
    status/diffs, zero-byte ignored brief, activation parent `98765354`, no generated book/non-cache bytecode, and
    no background gate; activate this leaf as the sole task-tree diff before Rust consumer/source changes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Retrieve canonical neutral/ADR/Perl/Rust authorities and use Toolbox-first
    probes to map exact byte registers, decoded input ownership, conversion/helper/mark/cursor routes, composed
    execution variants, diagnostics, and current test/gate topology without archaeology.
  - [x] **SAFE SPLIT BEFORE RED** — Prove the supposedly unchanged seven-alias baseline is false, identify the two
    wrong neutral target names, and freeze `.0.1-.0.3` correction/parity/RED owners without adding a consumer or
    changing contract/runtime behavior first.
  - [x] **NO REGRESSION** — Preserve current Rust package/primary/generated/corpus behavior and all neutral,
    capability, storage, semantic/MCP, doctrine, and canonical results while the new consumer remains unregistered.
  - [x] **LOCKSTEP** — Synchronize task/index/roadmaps/architecture/change/development/live/memory and durable
    Knowledge; keep root README and sole-facing mdBook unchanged because no runtime admission exists.

  Activation evidence 2026-08-01: Perl admission `.14.2.1.3` landed at `82be51f0` as 143/300 with no push. Both
  activation-pointer hook phases pass against `98765354`, Knowledge Map is 785/6,392, and all seven doctrines pass.
  Post-commit proof finds empty status and staged/unstaged diffs, a zero-byte ignored `git_message_brief.txt`, exact
  parent `98765354`, no generated book or non-cache Python bytecode, and no canonical/Phase-0/typed-source/mdBook
  process. This task-tree file is the sole activation diff; no Rust consumer/source, contract/checker, book,
  Knowledge, roadmap, root README, or runtime behavior changed first.

  Rust RED-topology finding 2026-08-01: unlike the explicitly listed Perl `prove` inputs, Cargo automatically
  discovers every `rust/linkedspec-runtime/tests/*.rs` target because the package retains its default
  `autotests = true` behavior. Therefore the frozen path and the requirement to keep the RED outside the complete
  Rust/canonical gate cannot coexist as an ordinary active integration test. This leaf will put the entire new
  test crate behind a test-local `linkedspec_typed_source_red` custom `cfg` (with its lint allowance): ordinary
  package execution discovers a zero-test dormant target, while the exact focused RED command supplies
  `RUSTFLAGS='--cfg linkedspec_typed_source_red'` and classifies the missing core API. Core/projection leaves keep
  using that explicit command; admission `.14.2.2.3` removes the dormant boundary so ordinary Cargo discovery
  becomes the canonical binding. No Cargo manifest, feature, driver, production source, or existing test topology
  changes to manufacture the pre-admission boundary.

  Blocking alias finding 2026-08-01: the exact neutral inventory has 92 canonical helpers plus seven callable
  aliases. Source census finds all 92 canonical names in `engine.rs`, but Rust contains only `entry_named_map` and
  `match_named_map` among the aliases. Executable primary probes compile each of `capture_from_rule_start()`,
  `capture_len_from_rule_start()`, `capture_rest_length()`, `capture_slice_here()`, and `capture_slice_length()`
  yet return JSON null through the unknown-helper fallback. Toolbox `call_spec_handler_subst` proves Perl routes
  those same calls through `span_text`, `span_length`, or `capture_boundary_write_position`; `LinkedSpec::Get`
  returns numeric zero for the same minimal whole-input match. Thus Rust cannot both gain the contract's canonical
  five alias routes and preserve its current user-visible results, while `.14.2.0` explicitly requires both and
  excludes new DSL behavior. The fact is durable at [[rust-typed-source-compatibility-alias-gap]]. Freeze no RED
  alias expectation and change no Rust runtime until the director decides whether `.14.2.2.2` may absorb this
  five-alias parity repair or whether a separate prerequisite owner must close it first.

  Director decision and neutral-target root cause 2026-08-07: the director confirms Rust must implement the same
  five compatibility aliases with Perl-equivalent behavior; there is no intentional Rust-specific semantic. Exact
  Perl contracts and the sole-facing helper reference additionally prove the neutral artifact/checker's first two
  mappings are mislabeled: zero-argument `capture_from_rule_start()` aliases anonymous `capture_slice()`, not
  one-mark `capture_from(name)`, and `capture_len_from_rule_start()` aliases `capture_slice_len()`, not
  `capture_len_from(name)`. The other five neutral mappings are correct. This audit therefore closes by splitting
  `.0.1` to correct only those two neutral identities, `.0.2` to implement all five Rust aliases against exact Perl
  results across native/reconstructed/generated execution, and `.0.3` to freeze the originally planned typed-source
  RED after both prerequisites land cleanly. No contract or runtime change belongs in this audit commit.

  Signoff evidence 2026-08-07: the focused neutral checker remains exact at 4 complete / 10 pending / 38
  mutations, Knowledge Map regeneration/check passes at 786 facts / 6,400 question keys, capability remains
  schema v2 / 80-0-0 / 24+6, and all seven doctrines pass. The first canonical run correctly caught that the
  bounded `MEMORY.md` rewrite had omitted the still-enforced historical repeated-action next owner
  `FUTURE-PARITY-BACKLOG.10.1`; restoring that one durable marker returns its focused checker to 8 mode cases,
  10 special cases, 8 complete / 0 pending, and 54 rejected mutations. The complete permission-authorized restart
  then passes that checkpoint, every composed semantic/MCP and containment/relocation consumer, CLI 66/66 in both
  option environments, RAM 43%, and Phase 0 1,031/1,031 in 681 seconds before `[ci] local CI gate passed`.
  No executable contract, runtime, test, schema, mdBook, or root README behavior changed in this audit.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.0.1`
  Status: `signoff-complete` (2026-08-07; verified from clean `69179553`, intended 145/300, no push)
  Goal: Correct the two mislabeled neutral compatibility-alias targets before any Rust implementation consumes them.
  Depends on: `.14.2.2.0`
  Acceptance: Change only `capture_from_rule_start` from `capture_from` to `capture_slice` and
    `capture_len_from_rule_start` from `capture_len_from` to `capture_slice_len` in the neutral JSON and checker
    authority; keep seven aliases, every other fixture/count/rollout row, 38 mutations, runtime behavior, and the
    already-correct mdBook semantics unchanged. Add exact mutation/Perl-lowering proof if required to prevent another
    semantically plausible but arity-wrong target. Synchronize durable/live records, pass neutral/doctrine/canonical
    signoff, commit, clear the brief, and prove clean before `.0.2`.
  Verification: neutral 3/7/6/3 + 92+7+2 + 31 diagnostics + 4/10 rollout + 38 mutations; Perl focused 33/33;
    Knowledge Map 786/6,400; capability 80/0/0; all seven doctrines; composed semantic/MCP and containment/
    relocation proof; CLI 66/66 twice; RAM 50%; Phase 0 1,031/1,031; `[ci] local CI gate passed`
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.0.1 - correct neutral capture alias targets`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.0.1` Acceptance Checklist

  - [x] **REPRODUCE / AUTHORITY** — Reconfirm the neutral artifact/checker mismatch against exact Perl ActionIR
    records/lowering and the sole-facing zero-argument helper catalog before editing either authority.
  - [x] **CORRECT EXACTLY TWO TARGETS** — Map `capture_from_rule_start` to `capture_slice` and
    `capture_len_from_rule_start` to `capture_slice_len`; preserve all other aliases, rows, counts, and rollout.
  - [x] **LOCK SEMANTIC IDENTITY** — Make the checker verify exact compatibility-record diagnostic/lowering identity
    and reject regression to the arity-wrong named-mark targets without weakening any existing mutation.
  - [x] **NO RUNTIME / BOOK CHANGE** — Keep Perl/Rust/Dart/Julia/Lua execution, schemas, tests, rollout 4/10,
    38-mutation total, root README, and already-correct sole-facing mdBook semantics unchanged.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmaps/architecture/change/development/live/memory and
    Knowledge, pass focused neutral/Perl/governance/canonical checks, commit, clear the brief, and prove clean.

  Activation evidence 2026-08-07: prerequisite audit `.14.2.2.0` committed at `69179553` as 144/300 with no push.
  Its post-commit status and both diffs are empty, `git_message_brief.txt` is zero bytes, and no background result
  remains. This task-tree file is the sole activation diff before neutral artifact/checker or runtime changes.

  Implementation evidence 2026-08-07: the neutral JSON and checker now map only the two rule-start compatibility
  names to `capture_slice` and `capture_slice_len`. For each of the five non-scanner aliases, the checker extracts
  exact Perl records and requires the compatibility flag, canonical `diag_name`, identical `ir_node`, and identical
  ordered `SourceLocation::Runtime` call sequence; its alias-target mutation regresses the first row specifically
  to the old arity-wrong `capture_from`. The focused checker remains 3/7/6/3, 92+7+2, 31 diagnostics, rollout 4/10,
  and 38 rejected mutations. Perl contract syntax and the typed-value/projection plus ActionIR suites pass 33/33.
  No backend runtime, test, schema, root README, or already-correct mdBook source changed.

  Signoff evidence 2026-08-07: Knowledge Map remains 786/6,400, capability remains schema v2 / 80-0-0 / 24+6,
  all seven doctrines pass, and the historical capability/repeated-action closeout markers remain exact. The
  permission-authorized canonical restart passes the corrected neutral checker, both Perl typed-source consumers,
  every composed semantic/MCP consumer, repository containment and five-anchor relocation, CLI 66/66 in default
  and POSIX option environments, RAM 50%, and Phase 0 1,031/1,031 before `[ci] local CI gate passed`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.0.2`
  Status: `signoff-complete` (2026-08-07; verified from clean `767abfac`, intended 146/300, no push)
  Goal: Implement the five missing Rust source-boundary compatibility aliases with exact Perl-equivalent behavior.
  Depends on: `.14.2.2.0.1`
  Acceptance: Add exact RED-first native tests for all five aliases, Unicode widths, anonymous-boundary mutation,
    absence/reversed-span behavior, and canonical equivalence; then route `capture_from_rule_start` to
    `capture_slice`, `capture_len_from_rule_start` and `capture_slice_length` to `capture_slice_len`,
    `capture_rest_length` to `capture_rest_len`, and `capture_slice_here` to `start_capture_slice`. Prove native,
    ordinary serialized/reconstructed, generated-plan, and independently emitted-source results without changing
    preferred helper semantics, artifact/schema identity, semantic/MCP/capability contracts, or other backends.
    Update the sole-facing mdBook with truthful Rust parity and examples where needed, pass complete Rust/corpus/
    primary plus doctrine/canonical signoff, commit, clear the brief, and prove clean before `.0.3`.
  Verification: alias carrier 1/1; Rust complete/corpus/storage/CLI 66x2; neutral 4/10/38; Perl 10; mdBook;
    Knowledge Map 786/6,400; capability 80/0/0; all seven doctrines; composed semantic/MCP and containment/
    relocation proof; canonical CLI 66/66 twice; RAM 50%; Phase 0 1,031/1,031 in 653 seconds;
    `[ci] local CI gate passed`
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.0.2 - add Rust capture compatibility aliases`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.0.2` Acceptance Checklist

  - [x] **RED / PERL ORACLE** — Add an exact Rust consumer for all five aliases and prove the current implementation
    returns null or otherwise diverges while the corresponding Perl/canonical helpers establish expected values.
  - [x] **ONE DISPATCH SEMANTIC** — Route every alias through the existing canonical Rust helper arm so arity,
    Unicode-scalar length, absence/reversed-span handling, mutation, diagnostics, and trace behavior cannot fork.
  - [x] **ALL RUST CARRIERS** — Prove native `Engine`, serialized/reconstructed `CompiledSpec`, generated plan, and
    independently compiled emitted source return the same alias/canonical values without schema or identity change.
  - [x] **SOLE-FACING BOOK LOCKSTEP** — Update only the needed mdBook Rust-support statements/examples, build the
    real book, and inspect changed HTML paragraph separation while retaining the broader readability audit.
  - [x] **NO UNRELATED PROMOTION** — Preserve preferred helper semantics, typed-source rollout 4/10/38,
    capability/semantic/MCP state, other backends, root README, and every unrelated public surface.
  - [x] **SIGNOFF / CLEAN HANDOFF** — Synchronize live/durable records, pass focused/complete Rust, primary/corpus,
    neutral/doctrine/canonical gates, commit, clear the brief, and prove clean before `.0.3`.

  Activation evidence 2026-08-07: neutral correction `.14.2.2.0.1` committed at `767abfac` as 145/300 with no
  push. Post-commit status and both diffs are empty, `git_message_brief.txt` is zero bytes, and no background result
  remains. This task-tree file is the sole activation diff before Rust consumer, runtime, or mdBook changes.

  RED evidence 2026-08-07: new integration consumer
  `rust/linkedspec-runtime/tests/source_boundary_compatibility_aliases.rs` freezes all five aliases against their
  canonical helpers over Unicode input `é🙂  ab`, including `capture_slice_here` mutation/undef result, scalar
  lengths, and reversed-span undef. It covers native, reconstructed, generated-plan, and independently compiled
  emitted-source carriers. Before runtime changes, its focused Cargo run fails at the first native alias carrier:
  Rust reports all five helpers unknown and returns `[null,null,null,null,null]` instead of canonical
  `[null,"é🙂  ",4,4,6]` (one test failed, exit 101). The corrected neutral contract and Perl `Contracts.pm`
  canonical-event records establish the exact five alias targets; the consumer therefore exposes the audited Rust
  dispatch omission rather than inventing new semantics.

  Implementation/focused evidence 2026-08-07: `engine.rs` adds the five spellings only as alternative patterns
  on the existing `start_capture_slice`, `capture_slice`, `capture_slice_len`, and `capture_rest_len` arms; the
  same names enter the existing mark/capture trace classification. The exact consumer passes one test across
  native, reconstructed, generated-plan, and independently compiled emitted-source carriers. Existing anonymous
  capture `.5.5.4` tests remain green. The neutral checker remains 3/7/6/3, 92+7+2, 31 diagnostics, 4/10 rollout,
  and 38 mutations; both admitted Perl consumers pass 10 tests.

  Sole-facing evidence 2026-08-07: the source-boundary reference states exact Perl/Rust seven-alias support and
  includes the Unicode migration fixture; project status explicitly distinguishes this spelling repair from
  still-pending Rust typed values; formal grammar and the exhaustive helper catalog now list all five mappings.
  `tools/run_mdbook_local.sh` builds successfully. Generated HTML shows separate `<p>` blocks before the example,
  after the code block, and before the following delimiter guidance; the broader nonurgent rendered-readability
  task remains unchanged.

  Complete Rust evidence 2026-08-07: `tools/run_rust_local.sh` passes formatting, core/runtime unit and integration
  suites, the exact new all-carrier test, all 105 corpus specs, generated-source full-manifest classification,
  project-storage locality for 17 Rust owners, and the primary CLI at 66/66 under both default and POSIX option
  environments before `[rust-ci] Rust local gate passed`.

  Governance evidence 2026-08-07: the neutral checker remains 3/7/6/3, 92+7+2, 31 diagnostics, rollout 4/10,
  and 38 mutations; both admitted Perl consumers pass 10 tests; capability remains schema v2 / 80-0-0 / 24+6;
  Knowledge Map remains 786/6,400; all seven doctrines and the memory pointer pass. The diff contains no neutral
  contract, schema, capability, semantic/MCP, other-backend, root-README, or generated-book change.

  Signoff evidence 2026-08-07: the permission-authorized definitive gate passes all seven doctrines, both admitted
  Perl typed-source consumers, every composed semantic/MCP admission, project-data containment, relocated
  six-family IO, Rust moved-root execution, and four outside-CWD anchors. Canonical CLI passes 66/66 in both
  default and POSIX option environments, RAM is 50% against the 88% ceiling, and Phase 0 passes 1,031/1,031 in
  653 seconds before `[ci] local CI gate passed`. Commit, brief clearing, and exact clean proof remain before
  task-tree-first `.0.3` activation.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.0.3`
  Status: `signoff-complete` (2026-08-07; activated task-tree-first from clean `1a83a8df`, intended 147/300,
    no push; commit/clean boundary in progress)
  Goal: Freeze the exact dormant Rust typed-source RED consumer against the corrected seven-alias baseline.
  Depends on: `.14.2.2.0.2`
  Acceptance: Add only `rust/linkedspec-runtime/tests/typed_source_location_contract.rs` behind the audited
    pre-admission custom-cfg boundary. Require the 3/7/6/3 neutral value fixtures, empty/multi-source cases, four
    exact diagnostics, detached immutability/privacy, exact 92-helper/seven-alias inventory, Unicode byte-to-scalar
    conversion, parent/child mark isolation, absence/capture mutation/save-restore compatibility, and current native/
    reconstructed/generated result shapes. Classify the missing core `.1` before projection `.2`, keep ordinary
    Cargo/canonical discovery dormant until admission `.3`, change no production/neutral/public behavior, pass
    unchanged baselines and canonical signoff, commit, clear the brief, and prove clean before `.14.2.2.1`.
  Verification: ordinary Cargo zero-test discovery; explicit core cfg exact one-error `E0432` RED; formatting and
    whitespace; neutral 3/7/6/3 + 92+7+2 + 4/10/38; both admitted Perl consumers; complete Rust core/runtime/
    integration + 105 corpus + generated-source + 17-owner storage + CLI 66x2; mdBook; Knowledge Map 786/6,403;
    all seven doctrines; canonical CLI 66x2, RAM 49%/88%, Phase 0 1,031/1,031 in 653 seconds, exact local-CI pass
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.0.3 - lock Rust typed source RED`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.0.3` Acceptance Checklist

  - [x] **RETRIEVE / FREEZE EXACT AUTHORITY** — Reuse ADR `0056`, the neutral 3/7/6/3 fixtures, 92+7 alias
    inventory, four diagnostics, corrected alias parity, current Rust carrier behavior, and existing Knowledge/
    TOOLBOX evidence without re-deriving settled facts.
  - [x] **DORMANT CORE RED** — Add only the audited Rust typed-source consumer behind the pre-admission custom-cfg
    boundary and make its first failure name the absent immutable source authority/value core owned by `.1`.
  - [x] **DORMANT PROJECTION CONTRACT** — Freeze exact future helper projection, Unicode byte-to-scalar conversion,
    mark/cursor mutation, recursion/isolation, native/reconstructed/generated compatibility, privacy, and four-error
    expectations without implementing them or weakening current behavior.
  - [x] **NO PREMATURE ADMISSION** — Prove ordinary Cargo discovery and canonical CI remain green with the consumer
    dormant; preserve rollout 4/10/38, all seven current aliases, schemas, public/mdBook behavior, and other backends.
  - [x] **LOCKSTEP / SIGNOFF / CLEAN HANDOFF** — Synchronize durable/live records, pass focused RED-shape and current
    baselines plus doctrine/canonical signoff, commit, clear the brief, and prove clean before `.14.2.2.1`.

  Activation evidence 2026-08-07: Rust alias parity `.14.2.2.0.2` committed at `1a83a8df` as 146/300 with no push.
  Its post-commit status and both diffs are empty, `git_message_brief.txt` is zero bytes, and no background result
  remains. This task-tree file is the sole activation diff before adding or inspecting the dormant Rust consumer.

  Contract evidence 2026-08-07: the new integration target is entirely gated by test-local
  `linkedspec_typed_source_red`; its value half reads the unchanged neutral authority and freezes all 3 sources,
  7 scalar/line/column/UTF-8-byte conversions, 6 direct spans including empty text, 3 ordered derived cases
  including multiple sources, detached records, owned decoded text, and the exact four private errors. A nested
  `linkedspec_typed_source_projection_red` module separately freezes the detached exact 92-row/four-family catalog,
  seven corrected aliases, and unchanged Unicode parent/child mark, absence/clear, capture-boundary mutation, and
  cursor save/restore results across native, reconstructed, and generated-plan carriers. It adds no manifest,
  feature, production source, fixture, neutral artifact, or ordinary test registration.

  RED-shape evidence 2026-08-07: ordinary focused Cargo discovery passes with zero tests, proving the committed
  target remains dormant before admission. Supplying only `--cfg linkedspec_typed_source_red` exits 101 with one
  compiler error: `E0432` at the test import because `linkedspec_runtime::source_location` does not exist. The
  projection cfg is not active, so no `.2` failure obscures the missing immutable authority/value core owned by
  `.14.2.2.1`. Formatting and whitespace checks pass.

  Complete/canonical evidence 2026-08-07: `tools/run_rust_local.sh` passes all core/runtime/integration suites,
  the complete 105-spec corpus, full-manifest generated-source classification, project-storage locality for 17
  Rust owners, and primary CLI 66/66 under both default and POSIX option environments. The definitive
  `tools/run_ci_local.sh` then passes all seven doctrines, unchanged typed-source 3/7/6/3 + 92+7+2 + 4/10/38,
  both admitted Perl consumers, every semantic/MCP admission, repository containment/relocation, canonical CLI
  66/66 twice, RAM 49% against the 88% ceiling, and Phase 0 1,031/1,031 in 653 seconds before
  `[ci] local CI gate passed`. No production, neutral, schema, rollout, root-README, mdBook, or other-backend
  behavior moved. Commit, brief clearing, and exact clean proof remain as the workflow boundary before `.1`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.1`
  Status: `signoff-complete` (2026-08-07; activated task-tree-first from clean
    `7b4956e8`, intended 148/300, no push)
  Goal: Implement the immutable Rust source authority and typed `Position`/`Span`/derived-text value core so the
    base dormant consumer turns GREEN without routing any helper projection or admitting Rust runtime support.
  Depends on: `.14.2.2.0.3`
  Acceptance: Add `rust/linkedspec-runtime/src/source_location.rs` and export only that internal runtime-support
    module from `lib.rs`. Snapshot caller-authorized decoded sources into one authority; keep opaque values free of
    copied text, paths, parser/match state, and host references; detach every record projection; validate authority,
    source, bounds, order, and derived provenance; derive zero-based scalar offsets into one-based line/column and
    UTF-8 byte offsets; materialize direct and ordered multi-source text; emit only the four neutral private errors
    with exact required context. Turn the base custom-cfg consumer GREEN, prove the projection cfg still stops at
    the exact `.2`-owned missing catalog boundary, keep ordinary Cargo/canonical discovery green, and change no
    engine/helper route, cursor/mark register, external result, neutral/schema/rollout row, root README, mdBook
    claim, or other backend. Pass focused and complete Rust plus doctrine/canonical signoff, synchronize durable
    records, commit, clear the brief, and prove clean before `.14.2.2.2`.
  Verification: focused core 2/2 GREEN; ordinary target 0 tests; nested projection boundary exact one-error
    `E0432`; formatting, complete Rust/corpus/storage/CLI 66x2, sole-facing mdBook, all seven doctrines, canonical
    containment/relocation/CLI 66x2/RAM 53%/Phase 0 1,031 in 653 seconds pass; committed clean at `2d9401e2`
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.1 - implement Rust source location core`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.1` Acceptance Checklist

  - [x] **ACTIVATE / RETRIEVE** — Prove `.0.3` landed cleanly, activate only this leaf, and retrieve ADR `0056`,
    the typed-source Knowledge owner, neutral fixtures, dormant consumer, and exact Rust error/value precedents.
  - [x] **IMMUTABLE AUTHORITY / VALUES** — Add the owned decoded-source authority plus opaque detached `Position`,
    direct `Span`, and ordered derived-text values without ambient source or parser authority.
  - [x] **CONVERSION / MATERIALIZATION / ERRORS** — Pass all 3/7/6/3 fixtures, Unicode scalar/line/column/UTF-8
    conversions, empty/multi-source text, authority ownership, and four exact private diagnostics.
  - [x] **LAYER BOUNDARY** — Make only the core cfg GREEN; prove the nested projection cfg still identifies the
    absent 92-row/seven-alias `.2` interface without helper routing or admission.
  - [x] **LOCKSTEP / SIGNOFF / CLEAN HANDOFF** — Preserve ordinary/public/mdBook truth and rollout 4/10/38; pass
    Rust, doctrine, canonical, storage, and root-relative gates; commit/clear/prove clean before `.2`.

  Activation evidence 2026-08-07: dormant Rust RED `.14.2.2.0.3` committed at clean `7b4956e8` as 147/300 with
  no push. Post-commit status and both diffs are empty, `git_message_brief.txt` is zero bytes, the post-commit
  activation pointer resolves to `1a83a8df`, and no background result remains. This task-tree record is the sole
  activation diff before the immutable Rust module or export is added.

  Implementation evidence 2026-08-07: `source_location.rs` snapshots the caller's `BTreeMap` of decoded sources
  behind one monotonic opaque authority id. Each source precomputes scalar-boundary line, column, and UTF-8-byte
  tables. `Position`, direct `Span`, and ordered `DerivedText` expose only cloned detached JSON records; their
  private state contains ids, scalar offsets, provenance, and policy but no decoded text, path, parser/match state,
  authority reference, or host object. The authority is intentionally neither cloneable nor debug-printable. It
  alone validates values, derives coordinates, and materializes direct or ordered multi-source text. The only
  errors are the four neutral private records with exact phase, roles, and required context.

  Focused evidence 2026-08-07: the current source passes the base custom-cfg target 2/2 across all exact 3/7/6/3
  fixtures and four diagnostics. Ordinary Cargo discovery remains a zero-test target. Enabling the nested
  projection cfg exits 101 with exactly one `E0432`, naming only absent
  `typed_source_compatibility_aliases` and `typed_source_projection_rows` in `runtime`; no core name is missing.
  Formatting passes. No engine/helper route, mark/cursor register, external value, neutral/schema/rollout row,
  root README, sole-facing mdBook claim, or other backend changed.

  Broad Rust evidence 2026-08-07: `tools/run_rust_local.sh` passes core/runtime/integration and every focused
  suite, the 105-spec corpus, full-manifest generated-source classification, 17-owner storage locality, both
  66/66 primary CLI environments, and its exact terminal marker. The dedicated five-alias carrier contract also
  remains green.

  Lockstep/signoff evidence 2026-08-07: the unchanged 79-file sole-facing mdBook builds successfully and remains
  exact that Rust runtime admission is pending. All seven doctrine checks pass, including neutral 4/10/38 and
  Knowledge Map 786/6,406. Definitive canonical CI passes process containment, relocated/outside-CWD execution,
  composed semantic and MCP admission, CLI 66/66 in both option environments, RAM 53%, and Phase 0 1,031/1,031
  in 653 seconds before `[ci] local CI gate passed`. The first harnessed run reached containment but its nested
  `sandbox-exec` was denied by the outer sandbox; the authorized rerun proves that exact stage and every later
  stage green. The commit, brief clearing, and exact clean proof then landed as recorded below.

  Clean handoff evidence 2026-08-07: the leaf committed as intended 148/300 at `2d9401e2` with the exact subject.
  Both activation-pointer hook phases and all seven pre-commit doctrines pass. Post-commit status and staged/
  unstaged diffs are empty, `git_message_brief.txt` is zero bytes, and no background result remains. Projection
  `.14.2.2.2` may therefore activate task-tree-first from this exact boundary; no push occurred.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.2`
  Status: `done; signoff-complete` (2026-08-07; activated task-tree-first from clean
    `2d9401e2`, intended 149/300, no push)
  Goal: Project the immutable Rust source authority/values through every exact source-boundary helper route while
    preserving all existing external JSON results, byte-register behavior, serialized/generated identities, and
    the still-pending Rust admission boundary.
  Depends on: `.14.2.2.1`
  Acceptance: Use LinkedSpec's Toolbox and the dormant projection consumer to map the current input-text owner,
    byte-to-Unicode-scalar conversion seam, all 92 canonical helpers, seven compatibility aliases, named mark/
    capture/cursor state, and native/reconstructed/generated-plan execution. Add exact detached
    `typed_source_projection_rows()` and `typed_source_compatibility_aliases()` catalogs. Initialize one immutable
    authority per execution input and route helper boundary construction, coordinate validation, and source-text
    materialization through typed positions/spans/derived values without changing scalar byte registers, mark/
    cursor storage, public helper names/arities, success values, absence behavior, diagnostics, compiled or
    generated schemas/identities, neutral rollout 4/10/38, root README, sole-facing mdBook admission claims, or any
    other backend. Turn the nested cfg consumer GREEN across exact 92+7 catalog and Unicode mark/capture/cursor
    behavior on native, serialized/reconstructed, and generated-plan carriers; keep ordinary discovery at zero
    tests and leave canonical registration plus `rust_runtime` promotion exclusively to `.14.2.2.3`. Pass focused
    and complete Rust, storage/path, doctrine, mdBook, and canonical signoff; synchronize durable records; commit,
    clear the brief, and prove clean before `.14.2.2.3`.
  Verification: Toolbox route census complete; nested projection cfg 4/4 GREEN; base cfg 2/2; ordinary target
    zero-test; dedicated alias carrier 1/1; complete Rust/corpus/generated/storage/CLI 66x2 GREEN; sole-facing
    mdBook/HTML, neutral checker, Knowledge Map 786/6,409, and all seven doctrines GREEN; canonical CI GREEN with
    repository containment/relocation, CLI 66/66 twice, RAM 51%, and Phase 0 1,031/1,031 in 654 seconds; commit,
    brief clearing, and clean handoff complete
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.2 - route Rust typed source projections`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.2` Acceptance Checklist

  - [x] **ACTIVATE / RETRIEVE** — Prove `.1` landed cleanly at `2d9401e2` as 148/300 with empty status/diffs,
    zero-byte ignored brief, valid activation parent `7b4956e8`, no background gate, and activate only this leaf.
  - [x] **TOOLBOX ROUTE CENSUS** — Probe the exact input/source owner, byte/scalar conversion, 92+7 dispatch,
    mark/capture/cursor registers, and native/reconstructed/generated-plan convergence before implementation.
  - [x] **CATALOG / TYPED ROUTES** — Add detached exact catalogs and make every owned helper projection construct,
    validate, and materialize through one per-input immutable authority without changing external behavior.
  - [x] **UNCHANGED CARRIERS / ADMISSION BOUNDARY** — Pass the nested consumer on all required carriers, retain
    ordinary zero-test discovery, and leave registration plus rollout promotion exclusively to `.3`.
  - [x] **LOCKSTEP / SIGNOFF / CLEAN HANDOFF** — Preserve neutral/schema/book/backend truth, pass focused/full/
    canonical and locality gates, synchronize durable records, commit, clear the brief, and prove clean.

  Activation evidence 2026-08-07: immutable core `.14.2.2.1` landed cleanly at `2d9401e2` as intended 148/300
  with no push. Its pre/post activation-pointer checks and all seven doctrines pass; status plus both diffs are
  empty; the ignored brief is zero bytes; the committed activation parent is `7b4956e8`; and no background result
  remains. This task-tree file is the sole activation diff before any runtime, test, catalog, Knowledge, roadmap,
  mdBook, neutral artifact, or other project file changes.

  Toolbox census evidence 2026-08-07: one `RuntimeContext` is created per execution input and owns the decoded
  `input` plus UTF-8-byte cursor, entry/match spans, rule-scoped mark buckets, anonymous capture boundary, and
  cursor stack. Native execution, JSON reconstruction, generated-plan execution, and emitted Rust modules all
  converge on the same `Engine`/`RuntimeContext` helper dispatcher. The frozen neutral inventory is exactly 92
  canonical rows: 47 capture/mark, 30 entry/match, 11 input/cursor, and 4 cursor-control projections, plus seven
  callable aliases. No parallel generated-state or descriptor projection seam is required.

  Implementation evidence 2026-08-07: `RuntimeContext::new` snapshots `input` once into an opaque
  `SourceAuthority`; context clones share that exact authority identity through a private `Arc` wrapper. Existing
  registers remain UTF-8 byte offsets. Boundary methods convert those bytes to immutable scalar `Position` and
  `Span` values, then derive coordinates, lengths, and materialized text only through the authority. Mark writes,
  reads, anonymous capture mutation, input slicing (including compatibility truncation), and save/restore/rewind
  validate through the same boundary without altering storage or update timing. Capture-group projections retain
  their detached string/list/map/boolean behavior, matching the Perl runtime boundary. The two catalog functions
  return fresh exact 92-row and seven-alias JSON values; aliases still share canonical dispatch arms.

  Focused/broad evidence 2026-08-07: nested core+projection cfg passes 4/4, including exact catalog detachment and
  unchanged Unicode mark/capture/cursor results across native, reconstructed, and generated-plan carriers. Core-
  only cfg remains 2/2; ordinary discovery remains zero tests; the dedicated five-alias all-carrier contract passes
  1/1. Formatting passes. `tools/run_rust_local.sh` passes all unit/integration contracts, including 166 runtime
  unit tests and 197 main integration tests, the 105-spec corpus, full-manifest generated-source classification,
  17-owner storage locality, and CLI 66/66 under both default and POSIX option environments before its exact
  `[rust-ci] Rust local gate passed` marker. No neutral/schema/rollout row or canonical consumer registration moved;
  exact Rust admission remains `.14.2.2.3`.

  Lockstep/signoff evidence 2026-08-07: the neutral checker remains exact at 3/7/6/3, 92+7+2, 4/10 rollout,
  and 38 mutations. The sole-facing mdBook now distinguishes implemented-but-dormant Rust projections from admitted
  Perl and from future public values/transactions; a real repository-local build passes. Generated HTML places
  each changed status/capture/CI paragraph in a distinct `<p>`, and splits the backend-handoff callout into three
  paragraphs rather than one dense blob. Knowledge Map regenerates at 786 facts/6,409 questions. All seven
  doctrines pass. Definitive canonical CI passes composed semantic/MCP admissions, the relocated six-family
  project-data process proof, moved-root/outside-CWD execution across all five primary runtime anchors, CLI 66/66
  in both default and POSIX option environments, RAM 51% against the 88% threshold, and Phase 0 1,031/1,031 in
  654 seconds before `[ci] local CI gate passed`. The first managed-sandbox run reached the process proof but could
  not nest macOS `sandbox-exec`; the authorized rerun proves that exact stage and every later stage green. Only the
  durable commit, brief clearing, and clean proof remain.

  Clean handoff evidence 2026-08-07: the leaf landed as intended 149/300 at `3e28fc87` with the exact subject.
  The commit hook regenerated Knowledge Map at 786/6,409 and passed all seven doctrines; activation-pointer checks
  prove `2d9401e2` as both pre-commit HEAD and post-commit `HEAD^1`. Post-commit status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, the memory architecture check passes, and no background result
  remains. Exact admission `.14.2.2.3` therefore activates task-tree-first from this clean boundary; no push.

- ID: `FUTURE-PARITY-BACKLOG.14.2.2.3`
  Status: `signoff-complete` (2026-08-07; task-tree-first from clean `3e28fc87`, intended 150/300, no push;
    atomic commit pending)
  Goal: Admit the committed Rust typed source-location value/projection routes compositionally, promote only the
    `rust_runtime` rollout leg, and publish exact sole-facing support truth without changing helper results or
    introducing authored typed-value syntax.
  Depends on: `.14.2.2.2`
  Acceptance: Retrieve the runtime-rollout Knowledge card, ADR `0056` section 9, neutral artifact/checker, committed
    Rust consumer, current canonical registration, complete Rust gate, and every sole-facing typed-source status
    passage before implementation. Remove only the consumer's pre-admission custom-cfg dormancy so ordinary Cargo
    discovery executes its exact immutable-value and 92+7 projection proof, and register that consumer as a
    required unconditional canonical Rust admission leg. Promote only `rust_runtime` from pending to complete in
    the neutral artifact and independent checker, add one exact completed-to-pending Rust regression, and advance
    the locked rollout summary/mutation count from 4/10/38 to 5/9/39. Update the mdBook's capture/source-location
    mental model, project status, and canonical-CI explanation so users can distinguish admitted internal Perl and
    Rust values/projections from absent public `Position`/`Span` objects, transaction syntax/behavior, and the four
    pending Dart/Julia/PUC-Lua/LuaJIT runtimes. Preserve production runtime/helper code, UTF-8-byte registers,
    external results, descriptor/generated schemas and identities, semantic/MCP and capability state, DSL/facade
    spellings, root README, and the independent nonurgent rendered-readability tree. Pass exact ordinary/focused
    Rust admission, neutral mutation proof, complete Rust gate, book build/rendered paragraph checks, doctrines/
    canonical CI, synchronize durable/live records, commit, clear the brief, and prove clean before task-tree-first
    Dart authority/RED audit `.14.2.3.0`.
  Verification: exact ordinary and canonical Rust consumer 4/4, neutral 5/9/39, complete Rust 195 core + 166
    runtime unit + 197 integration + 105 corpus + generated-source + 17 storage owners + CLI 66x2, repository-
    local mdBook and distinct generated-HTML paragraph boundaries, Knowledge Map 786/6,411, all seven doctrines,
    capability 80/0/0, repository containment/relocation, canonical CLI 66x2, RAM 36%, and Phase 0 1,031/1,031 in
    669 seconds pass before `[ci] local CI gate passed`; commit, brief-clear, and clean-handoff proof remain
  Commit: `FUTURE-PARITY-BACKLOG.14.2.2.3 - admit Rust typed source runtime`

  ### `FUTURE-PARITY-BACKLOG.14.2.2.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove projection `.2` landed cleanly at `3e28fc87` as 149/300 with
    empty status/diffs, zero-byte ignored brief, valid activation parent `2d9401e2`, and no background gate; make
    this task-tree file the sole activation diff before consumer/contract/checker/CI/book changes.
  - [x] **RETRIEVE / ROOT CAUSE** — Use the Knowledge Map, ADR, neutral contract/checker, committed Rust consumer,
    Cargo discovery, complete Rust driver, canonical driver, and sole-facing book to prove registration and the
    `rust_runtime` row are the only remaining admission gaps.
  - [x] **REGISTER / PROMOTE EXACTLY ONCE** — Remove only test-local dormancy, execute the consumer ordinarily and
    once in canonical CI, promote only Rust, and lock rollout 5/9 with an independent 39th mutation.
  - [x] **ADDRESSED / USER TRUTH** — Prove immutable values and all 92+7 projections across native/reconstructed/
    generated carriers under ordinary and canonical execution, and teach admitted internal Rust support clearly.
  - [x] **NO REGRESSION** — Keep production source, byte registers, external behavior, schema/identity, capability,
    semantic/MCP, DSL/facade, root README, other backends, and unrelated readability work unchanged; pass focused,
    complete Rust, book, storage, doctrine, and definitive canonical gates.
  - [x] **LOCKSTEP / COMMIT / CLEAN** — Synchronize artifact/checker/CI/book/task/index/roadmaps/architecture/change/
    development/live/memory/Knowledge at 5/9/39; commit as 150/300, clear the brief, and prove clean before Dart.

  Activation evidence 2026-08-07: projection `.14.2.2.2` landed at `3e28fc87` as intended 149/300 with no push.
  Its commit hook regenerated Knowledge Map at 786 facts/6,409 questions, passed all seven doctrines, and proved
  activation `2d9401e2` as both pre-commit HEAD and post-commit `HEAD^1`. Post-commit status and staged/unstaged
  diffs are empty; the ignored brief is zero bytes; memory architecture passes; and no canonical, Phase 0, Rust,
  typed-source, or mdBook process remains. This task-tree file is the sole activation diff before any consumer,
  contract/checker, canonical driver, book, Knowledge, roadmap, root README, or runtime behavior change.

  Retrieval/root-cause evidence 2026-08-07: the Knowledge Map card, ADR `0056` section 9, neutral artifact/checker,
  complete Rust driver, canonical driver, exact Rust consumer, and all four sole-facing book passages agree on the
  boundary. The production Rust authority and 92+7 helper projection routes are already committed and preserve
  UTF-8-byte registers plus existing external results across native, reconstructed, and generated-plan carriers.
  Only two test-local custom-cfg guards suppress the consumer's four tests during ordinary Cargo discovery; the
  canonical driver requires and executes only the Perl consumers; and the neutral artifact/checker therefore keep
  only `rust_runtime` pending at 4 complete / 10 pending / 38 mutations. Admission needs no distinct Rust helper
  behavior and no production runtime change: remove those guards, bind the exact consumer once in canonical CI,
  promote that single row, add its completed-to-pending regression, and publish 5/9/39 truth.

  Checker-first RED/GREEN evidence 2026-08-07: the strengthened independent checker first expected 39 mutations,
  a completed Rust row, tracked/command registration, absent dormancy markers, and one Rust completed-to-pending
  regression. Against the unchanged artifact it exited 1 solely at `expected counts drifted`. GREEN changes only
  the artifact's mutation count and `rust_runtime` status, removes the two test-local cfg guards, and adds the
  consumer's exact required canonical command. The checker then passes exact 3/7/6/3 + 92+7+2 + 31 at 5/9/39,
  while ordinary offline Cargo passes all four immutable-value/projection tests. The four sole-facing book pages
  now distinguish admitted internal Perl/Rust support from absent public values/transactions and four pending
  backend runtimes, with explicit paragraph boundaries retained.

  Signoff evidence 2026-08-07: the complete Rust gate passes formatting, 195 core tests, 166 runtime unit tests,
  197 main integration tests, the exact ordinary four-test admission target, all 105 corpus specs, full-manifest
  generated-source classification, 17 storage owners, and CLI 66/66 in both option environments. A repository-
  local mdBook build succeeds; deterministic inspection of the generated HTML proves separate paragraph and code
  block elements around every changed passage, with no stitched prose blob. Knowledge Map is 786 facts/6,411
  question keys, and all seven doctrines pass. Definitive canonical CI then passes neutral 5/9/39 and the exact
  Rust 4/4 target, capability 80/0/0, every composed consumer, six-family repository containment, relocated and
  outside-CWD execution across all five primary runtime anchors, CLI 66/66 under both environments, RAM 36%
  against the 88% threshold, and Phase 0 1,031/1,031 in 669 seconds before `[ci] local CI gate passed`. No
  production source, external result, byte register, schema/identity, semantic/MCP/capability surface, authored
  DSL, root README, other backend, or unrelated readability implementation changed. The atomic commit, brief
  clearing, and clean proof precede Dart authority/RED `.14.2.3.0`; no push.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3`
  Status: `completed` parent (2026-08-07; Dart authority/split audit `.0` landed at `d3efe221`, alias parity `.0.1`
    landed at `7b76af71`, dormant typed RED `.0.2` landed at `58f4bb85`, immutable core `.1` landed at
    `f1b91426`, projection `.2` landed at `3513508a`, and admission `.3` landed at `c2a88218`)
  Goal: Implement and independently admit the same neutral typed source-location algebra in Dart.
  Children: `.14.2.3.0` authority/split audit; `.14.2.3.0.1` seven-alias Dart parity; `.14.2.3.0.2` exact
    typed-source RED; `.14.2.3.1` immutable value/conversion core; `.14.2.3.2` helper/unchanged loaded-generated-
    plan interpreter routes; `.14.2.3.3` exact admission/promotion.
  Acceptance: Use `source_location.dart`, `matching.dart`, `interpreter.dart`, and
    `typed_source_location_contract_test.dart`; retain code-unit registers, convert at the typed boundary, prove
    native/serialized/generated execution without schema change, bind the consumer, and promote only `dart_runtime`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3.0`
  Status: `done; signoff-complete` (2026-08-07; landed clean at `d3efe221` from `666751ae` as intended 151/300,
    no push)
  Goal: Map Dart's exact source text, code-unit cursor/mark/match registers, source-boundary helpers, loaded/
    reconstructed/generated-plan carriers, and diagnostic seams; stop before freezing the RED because the
    supposedly unchanged seven-alias baseline is false, and split exact prerequisite owners without changing
    production behavior or the 5/9/39 neutral rollout.
  Depends on: `.14.2.2.3`, `.14.2.0`
  Acceptance: Retrieve the typed-source runtime-rollout Knowledge card, ADR `0056` section 9, neutral artifact/
    checker, admitted Perl/Rust consumer precedents, Dart runtime/generated/diagnostic Knowledge owners, Toolbox,
    exact Dart source and existing tests, complete Dart driver, canonical registration, and sole-facing book before
    implementation. Prove the decoded-input owner, code-unit/scalar/line/column/UTF-8 conversion seams, all 92
    canonical helper and seven alias routes, cursor/mark/match/anonymous-boundary state, native plus loaded/
    reconstructed/generated convergence, structured-error boundary, package-test discovery, and current behavior
    through executable probes. The measured baseline is false: add no RED or production code; record the exact
    seven `unknown_helper` results and split `.0.1` Dart alias parity before `.0.2` typed RED. Preserve production
    code, public results, schema/identity, DSL/facade, semantic/MCP/capability state, neutral 5/9/39, root README,
    and sole-facing book behavior. Pass focused unchanged canonical-helper/complete Dart/storage/governance/
    canonical signoff, synchronize durable/live records, commit, clear the brief, and prove clean before `.0.1`.
  Verification: exact 92-known/7-unknown executable baseline; focused authority/carrier 87; complete Dart format
    95/0 + fatal analysis + package 375 + storage 19/47 + CLI 66x2 + corpus 105/105; neutral 5/9/39; Knowledge
    Map 786/6,417; unchanged repository-local mdBook build; all seven doctrines; definitive canonical capability
    80/0/0, typed 5/9/39 plus Rust 4/4, composed consumers, containment/relocation, CLI 66x2, RAM 39%, and Phase 0
    1,031/1,031 in 666 seconds pass; commit, brief-clear, and clean-handoff proof pending
  Commit: `FUTURE-PARITY-BACKLOG.14.2.3.0 - split Dart typed source prerequisites`

  ### `FUTURE-PARITY-BACKLOG.14.2.3.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove Rust admission `.14.2.2.3` landed at `666751ae` as 150/300
    with empty status/diffs, zero-byte ignored brief, activation parent `3e28fc87`, valid memory pointer, and no
    background verification; make this task-tree file the sole activation diff before Dart tests or records.
  - [x] **RETRIEVE / INVENTORY** — Use Knowledge Map, ADR, neutral contract/checker, Perl/Rust precedents, Toolbox,
    Dart source/tests/drivers, canonical registration, and book to map every authority, route, diagnostic, and claim.
  - [x] **EXECUTABLE BASELINE / ROOT CAUSE** — Probe all 92+7 spellings and relevant state/carrier behavior; prove
    exact code-unit and Unicode conversion facts, test discovery, missing typed seams, and any contradiction.
  - [x] **FREEZE RED OR SPLIT** — If premises hold, add one test-local dormant core/projection RED with exact
    failure and ordinary-green discovery; otherwise freeze prerequisite correction leaves without behavior code.
  - [x] **NO REGRESSION** — Keep production/public/schema/identity/DSL/semantic/MCP/capability/book/neutral state
    unchanged and pass focused, complete Dart, storage, doctrine, and definitive canonical gates.
  - [x] **LOCKSTEP / COMMIT / CLEAN** — Synchronize task/index/roadmaps/architecture/change/development/live/memory/
    Knowledge without overstating support; commit as 151/300, clear the brief, and prove clean before `.14.2.3.0.1`.

  Activation evidence 2026-08-07: Rust admission `.14.2.2.3` landed at `666751ae` as intended 150/300 with no push.
  Its commit hook regenerated Knowledge Map at 786 facts/6,411 question keys, passed all seven doctrines, and proved
  activation `3e28fc87` as both pre-commit HEAD and post-commit `HEAD^1`. Post-commit status and staged/unstaged
  diffs are empty; the ignored brief is zero bytes; memory architecture passes; and the process census finds no
  canonical, Phase-0, typed-source, Rust, or mdBook verification job. This task-tree file is the sole activation
  diff before any Dart consumer, production, neutral contract/checker, book, Knowledge, roadmap, or runtime change.

  Executable contradiction evidence 2026-08-07: one repository-local public-API probe read the neutral artifact,
  compared `isKnownActionIrCallName` plus `canonicalActionHelperName`, then invoked every alias through an ordinary
  compiled zero-regex rule. All 92 canonical names are known. All seven aliases — `capture_from_rule_start`,
  `capture_len_from_rule_start`, `capture_rest_length`, `capture_slice_here`, `capture_slice_length`,
  `entry_named_map`, and `match_named_map` — are unknown, canonicalize only to themselves, and fail at runtime with
  structured code `unknown_helper`, stage `callable_codeblock_invocation`, owner `dart_runtime`, and exact authored
  name. Canonical `capture_slice()` succeeds on the same primary route. The temporary probe was removed and status
  returned to the sole task-tree diff. Therefore `.0` adds no typed RED or production change: alias parity `.0.1`
  must establish canonical-equivalent behavior first, and exact dormant typed RED `.0.2` follows only after its
  clean commit.

  Authority/carrier evidence 2026-08-07: `_RuntimeExecutionContext` owns one decoded immutable `input`; its live
  cursor and cursor stack, `RuntimeMatchRegisters` entry/local matches and anonymous capture boundary, and rule-
  local mark buckets all store UTF-16 code-unit offsets. Existing helper edges convert to Unicode-scalar positions
  and lengths through the matching utilities and to one-based scalar line/column; `input_slice` converts authored
  scalar offsets back to code-unit boundaries before slicing. A separate private semantic-index source map already
  proves strict scalar/code-unit/UTF-8 boundaries, but it owns semantic-source identity and is not the runtime typed-
  source authority. The future exact runtime seam is absent `dart/lib/src/runtime/source_location.dart`; the exact
  consumer seam `dart/test/typed_source_location_contract_test.dart` is absent too. Loaded source creates the same
  engine from compiled state; normalized JSON reconstructs the typed AST before compilation; generated v2 direct/
  traced execution validates its minimal family plan then calls `executeGeneratedWithPlan`; emitted packages call
  those same APIs. No descriptor, generated format, or second interpreter is needed.

  Focused/complete evidence 2026-08-07: the exact action-contract, matching, interpreter, complete-named-mark,
  source-emitter, and spec-loader selection passes 87 tests, including generated state and isolated emitted-package
  execution. The neutral checker remains exact 3/7/6/3 + 92+7+2 + 31 at rollout 5/9/39. Complete Dart passes format
  95/0, fatal analysis, 375 package tests, the 19-owner/47-locked-package storage oracle, CLI 66/66 under both option
  environments, and all 105 corpus fixtures. Knowledge Map regenerates at 786 facts/6,417 question keys, and the
  repository-routed mdBook build passes without a source edit. The existing sole-facing reference is already exact:
  it assigns all seven aliases only to Perl/Rust and says other backend rollout remains separately tracked.

  Signoff evidence 2026-08-07: all seven doctrines pass and definitive canonical CI preserves capability 80/0/0,
  typed-source rollout 5/9/39, and the admitted Rust consumer at 4/4. Every composed semantic/MCP consumer,
  six-family repository containment, relocated and outside-CWD execution across all five primary anchors, and CLI
  66/66 in both option environments pass; RAM is 39% against the 88% threshold. Phase 0 passes 1,031/1,031 in
  666 seconds before `[ci] local CI gate passed`. No Dart production/test/book source, runtime result, neutral
  artifact, schema/identity, semantic/MCP/capability state, DSL, root README, or generated format changed. The
  atomic commit, ignored-brief clearing, and clean proof precede alias parity `.14.2.3.0.1`; no push.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3.0.1`
  Status: `completed` (`7b76af71`, 2026-08-07, 152/300, no push)
  Goal: Route Dart's seven neutral source-boundary compatibility aliases through the existing canonical helper
    names and runtime paths without adding a second semantic implementation.
  Depends on: `.14.2.3.0`, `.14.2.2.0.1`
  Acceptance: Add the exact seven alias-to-canonical mappings to Dart's typed ActionIR resolver/known-name surface;
    prove arity, structured diagnostics, Unicode values, anonymous-boundary mutation, reversed-span absence,
    named-capture maps, native/reconstructed/generated-plan/emitted execution, helper-catalog governance, and
    canonical equality. Preserve the 92 canonical routes, code-unit registers, schemas/identities, neutral 5/9/39,
    typed-source admission state, and sole-facing preferred-spelling guidance.
  Verification: checker-first RED/GREEN; alias 4/4; focused 91; complete Dart format 96/0, fatal analysis, package
    379, storage 20/47, CLI 66x2, corpus 105/105; language coverage 246/105/122; neutral 5/9/39; Knowledge Map
    786/6,419; mdBook 79/14,152 KiB plus rendered paragraph inspection; all seven doctrines; canonical capability
    80/0/0, typed 5/9/39, semantic/MCP consumers, containment/relocation, CLI 66x2, RAM 52%, Phase 0 1,031/1,031
    in 681 seconds, and exact local-CI pass marker. Atomic commit, brief-clear, and clean-handoff proof follow.
  Commit: `FUTURE-PARITY-BACKLOG.14.2.3.0.1 - add Dart source alias parity`

  ### `FUTURE-PARITY-BACKLOG.14.2.3.0.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove audit `.0` landed at `d3efe221` as 151/300 with parent
    `666751ae`, empty status/diffs, zero-byte brief, valid memory pointer, and no background verification; make
    this task-tree file the sole activation diff before Dart source/test/book changes.
  - [x] **CHECKER-FIRST RED** — Freeze the exact seven alias spellings, canonical targets, known-name state,
    diagnostics, representative Unicode/mutation/map values, and carrier matrix; prove failure against unchanged
    Dart production for only the missing alias mappings.
  - [x] **ONE ROUTE / EXACT BEHAVIOR** — Add only the seven mappings at the existing canonicalization/known-name
    seam, with no alias-specific runtime implementation or different typed semantics.
  - [x] **CARRIER / REGRESSION PROOF** — Prove canonical equality across native, reconstructed, generated-plan,
    emitted execution and exact arity/structured failures; pass complete Dart and neutral 5/9/39 unchanged.
  - [x] **BOOK / LOCKSTEP / SIGNOFF** — Keep preferred canonical spellings and runtime availability exact in the
    sole-facing book; synchronize live/durable records, pass doctrines/canonical CI, commit as 152/300, clear the
    brief, and prove clean before dormant typed RED `.14.2.3.0.2`.

  Activation evidence 2026-08-07: behavior-free audit `.14.2.3.0` landed at `d3efe221` as intended 151/300 with
  first parent `666751ae` and no push. The hook regenerated Knowledge Map at 786 facts/6,417 question keys, passed
  all seven doctrines, and proved the activation pointer against pre-commit HEAD and post-commit `HEAD^1`.
  Post-commit status and staged/unstaged diffs are empty, the ignored brief is zero bytes, memory architecture
  passes, and no canonical, Phase-0, Dart, typed-source, or mdBook verification process remains. This task-tree
  file is the sole activation diff before any production, test, neutral, Knowledge, roadmap, or book change.

  RED/GREEN evidence 2026-08-07: one new four-test consumer freezes all seven exact alias/target pairs, known-name
  and resolver contracts including preserved authored arity, unrelated structured `unknown_helper` diagnostics,
  Unicode text and scalar lengths, anonymous-boundary mutation, reversed-span absence, named entry/match maps, and
  native/reconstructed/generated-plan plus independently compiled emitted-package equality. Against unchanged
  production, the inventory test fails first at unknown `capture_from_rule_start`; the two carrier tests fail only
  at structured `unknown_helper` for `capture_slice_here`; and the unrelated-diagnostic test already passes.
  GREEN adds the seven names at the existing known/canonicalization seam and maps them to `capture_slice`,
  `capture_slice_len`, `capture_rest_len`, `start_capture_slice`, `capture_slice_len`, `entry_map`, and `match_map`.
  No interpreter branch or alias-specific semantic implementation was added.

  Governance/carrier evidence 2026-08-07: the language-capability checker still proves the intentionally shared
  Dart/Julia/Lua inventory at 246 names, while a separate Dart compatibility inventory and canonical map must now
  equal the neutral typed-source contract's seven pairs exactly. This keeps backend-specific compatibility names
  from inflating the shared inventory. The new consumer passes 4/4; the focused action/matching/interpreter/named-
  mark/emitter/loader/alias selection passes 91 tests; storage governance passes at 20 owners/47 locked packages;
  and the full Dart gate passes format 96/0, fatal analysis, 379 package tests, CLI 66x2, and corpus 105/105. The
  neutral typed-source checker remains 5 complete / 9 pending / 39 mutations. One accidental bare `dart test`
  command re-rooted the ignored package configuration into the user-global Pub cache; the managed wrapper then
  waited before discovery because its repository-local `PUB_CACHE` disagreed with that graph. An offline wrapped
  `pub get` restored all roots to the canonical repository cache; the exact user-cache active-root residue is zero;
  the storage oracle re-verifies the 20 owners/47 packages; and wrapped alias 4/4 completes in five seconds. All
  diagnostic processes/directories and the automatically emitted off-volume sample were removed exactly.

  Signoff evidence 2026-08-07: the sole-facing source-boundary reference, project status, local-CI guide, and
  backend handoff state that Perl, Rust, and Dart execute the seven compatibility names, preserve canonical
  spellings as preferred guidance, and keep Dart typed-value admission pending. Repository-routed mdBook build
  passes at 79 files/14,152 KiB; generated HTML inspection proves each changed passage remains a separate paragraph
  and the source example remains isolated from following prose. Knowledge Map regenerates at 786 facts/6,419
  question keys, memory architecture and all seven doctrines pass, and definitive canonical CI preserves
  capability 80/0/0 plus typed-source 5/9/39, executes all composed semantic/MCP consumers, proves repository
  containment and moved-root execution, passes CLI 66/66 twice, reports RAM 52%, and passes Phase 0 1,031/1,031
  in 681 seconds before `[ci] local CI gate passed`. No verification process remains; commit/brief/clean proof is
  the only remaining handoff step.

  Commit/handoff evidence 2026-08-07: atomic commit `7b76af71` lands with first parent `d3efe221`; the hook
  regenerates Knowledge Map at 786/6,419, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit `HEAD` and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is removed,
  and no canonical/background result remains to consume.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3.0.2`
  Status: `completed` (`58f4bb85`, 2026-08-07, 153/300, no push)
  Goal: Freeze one test-local dormant Dart typed source-location consumer after all 92 canonical helpers and seven
    aliases are an exact unchanged baseline.
  Depends on: `.14.2.3.0.1`
  Acceptance: Require the future immutable authority/value API, exact 3/7/6/3 fixtures, four private diagnostics,
    detached 92+7 catalogs, code-unit-to-scalar conversion, mark/capture/cursor behavior, and native/reconstructed/
    generated-plan carriers. Ordinary Dart discovery stays green; the explicit RED route fails only for the absent
    source-location core/projection seams. Add no production, neutral, rollout, schema, or public-book behavior.
  Verification: exact task-owned dormant consumer plus ordinary-green/explicit-RED proof; full Dart format 97/0,
    fatal analysis, package 379, storage 20/47, CLI 66x2, corpus 105/105; neutral 5/9/39; language coverage
    246/105/122; Knowledge Map 786/6,423; unchanged mdBook 79/14,152 KiB with generated-HTML block inspection;
    all seven doctrines; and definitive canonical capability 80/0/0, containment/relocation, CLI 66x2, RAM 39%,
    Phase 0 1,031/1,031 in 704 seconds, and exact pass marker all succeed. Commit, brief-clear, and clean handoff
    remain.
  Commit: `FUTURE-PARITY-BACKLOG.14.2.3.0.2 - freeze dormant Dart typed source RED`

  ### `FUTURE-PARITY-BACKLOG.14.2.3.0.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove alias parity landed at `7b76af71` as 152/300 with parent
    `d3efe221`, empty status/diffs, zero-byte brief, valid memory pointer, removed generated book, and no background
    verification; make this task-tree file the sole activation diff before consumer/live-doc changes.
  - [x] **EXACT DORMANT CONTRACT** — Freeze the neutral 3/7/6/3 values, four private diagnostics, detached 92+7
    catalogs, future immutable source authority/core/projection API, and exact carrier expectations in one test-local
    Dart consumer without weakening or duplicating the neutral artifact.
  - [x] **ORDINARY GREEN / EXPLICIT RED** — Keep ordinary Dart discovery green and provide one deliberate opt-in
    route that fails only at the missing typed source-location core/projection seams with exact diagnostics.
  - [x] **NO BEHAVIOR / TRUTHFUL LOCKS** — Change no Dart production, neutral rollout 5/9/39, schema/identity,
    semantic/MCP/capability, authored DSL, root README, or sole-facing public behavior; bind storage/checker
    governance only where required to make dormancy and future activation exact. Correct the retrieved neutral-plan
    Knowledge card's stale Perl-only/4-of-14 prose to committed Perl+Rust/5-of-14 truth without changing its artifact.
  - [x] **SIGNOFF / HANDOFF** — Pass focused and complete Dart, neutral proof, Knowledge Map, unchanged mdBook and
    rendered readability, all doctrines, canonical CI, then commit as 153/300, clear the brief, and prove clean
    before Dart immutable core `.14.2.3.1`.

  Activation evidence 2026-08-07: alias parity `.14.2.3.0.1` landed atomically at `7b76af71` as intended 152/300
  with first parent `d3efe221` and no push. Pre/post-commit memory-pointer phases, all seven hook doctrines, and
  Knowledge Map 786/6,419 pass. Status and both diffs are empty, the ignored brief is zero bytes, memory architecture
  passes, the verified generated book directory is absent, and the canonical CI session exited zero with no result
  left to consume. This task-tree file is the sole activation diff.

  Retrieval finding 2026-08-07: mandatory Knowledge Map lookup exposed a missed `.14.2.2.3` documentation refresh
  in `typed-source-location-neutral-contract-plan`: its front matter/title and closing prose still report only Perl
  plus 4/14, although the neutral artifact, runtime-rollout card, task tree, and canonical checker all report the
  committed Rust admission at 5 complete / 9 pending / 39 mutations. The active leaf owns this narrow durable
  correction alongside its otherwise behavior-free Knowledge synchronization; no neutral artifact or rollout row
  may move.

  Dormant-contract evidence 2026-08-07: `dart/test_dormant/typed_source_location_contract_test.dart` is the one
  conventional consumer named by the frozen parent plan, but its pre-admission directory is outside ordinary
  `dart test` discovery. One exact `analysis_options.yaml` entry excludes only this file while the future module is
  absent; there is no `skip`, conditional body, generated proxy, or production stub. The four tests consume the
  neutral JSON rather than copying its value cases: all three sources, seven coordinate conversions, six direct
  spans, three derived-text cases, authority snapshot/detached-record immutability, the four private diagnostics
  with required context/privacy, exact detached 92-row/four-family catalog, all seven aliases, complete named marks,
  capture-boundary alias mutation, and cursor save/rewind/restore. Native, reconstructed AST, and generated-plan
  carriers must retain existing results. The projection catalog uses two deliberately dynamic engine calls so,
  after core `.1` supplies the imported module, the same consumer advances to a precise absent-catalog RED for
  projection `.2` without changing files or prematurely selecting public typed-value syntax.

  RED/ordinary-green evidence 2026-08-07: the repository-routed explicit command accepts the out-of-discovery test
  path and exits 1 during loading. Its diagnostics name only missing
  `lib/src/runtime/source_location.dart` and the expected undefined `SourceLocationContext`, `SourceAuthority`,
  `Position`, `Span`, `DerivedTextPolicy`, and `SourceLocationException` symbols; no parser, alias, carrier, package,
  or runner failure appears. The same package passes fatal analysis with no issues and ordinary discovery remains
  exactly 379 tests, proving dormancy is real rather than a skipped admitted test. The neutral checker remains
  exact 3/7/6/3 + 92+7+2 + 31 at 5 complete / 9 pending / 39 mutations, and shared language coverage remains
  246 current names / 105 corpus plus one named-mark fixture / 122 independent public Perl contracts.

  Knowledge-freshness correction 2026-08-07: the neutral-plan card now reports committed Perl and Rust runtime
  admission, 5 of 14 complete legs, 9 pending, and 39 mutations; it retains the dated Perl-only 4/10/38 and Rust-
  prerequisite 4/10/38 evidence as history, adds the missing Rust-admission update, and changes no artifact,
  checker, rollout row, backend behavior, or sole-facing feature claim.

  Complete-Dart evidence 2026-08-07: the full repository-routed Dart gate passes format over 97 files with zero
  changes, fatal analysis with no issues, all 379 ordinarily discovered tests, 20 storage owners / 47 locked
  packages, the shared primary CLI contract 66/66 under both default and POSIX option environments, and all 105
  corpus fixtures before the exact `[dart-ci] Dart local gate passed` verdict. This confirms the dormant file is
  excluded from ordinary admission while every current Dart behavior and repository-local data route remains green.

  Signoff evidence 2026-08-07: the Knowledge Map regenerates at 786 facts / 6,423 question keys, memory architecture
  and all seven doctrines pass, and the repository-routed mdBook remains source-unchanged at 79 files / 14,152
  KiB. Deterministic generated-HTML inspection proves separate paragraph, list, table, and code-example elements
  around the current typed-source/alias claims; the in-app browser control surface was unavailable, so no screenshot
  claim is made. A sandboxed canonical attempt passes through language coverage and storage oracles, then macOS
  denies only its nested `sandbox-exec` containment probe with status 71. The required approved rerun passes that
  relocated six-family process probe, all five moved/outside-CWD primary anchors, capability 80/0/0, typed source
  5/9/39 plus Rust 4/4, every composed semantic/MCP consumer, CLI 66/66 twice, RAM 39% against 88%, and Phase 0
  1,031/1,031 in 704 seconds before exact `[ci] local CI gate passed`. No production, neutral artifact/row,
  schema/identity, semantic/MCP/capability, authored DSL, root README, or sole-facing book source changed. Atomic
  commit, brief clearing, and clean proof precede immutable Dart core `.14.2.3.1`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `58f4bb85` lands with first parent `7b76af71`; the hook
  regenerates Knowledge Map at 786/6,423, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit `HEAD` and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is absent,
  and the process census finds no canonical/background result left to consume.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3.1`
  Status: `completed` (`f1b91426`, 2026-08-07, 154/300, no push)
  Goal: Implement the immutable Dart source authority and typed `Position`/`Span`/derived-text value core so the
    first two frozen dormant tests turn GREEN without routing any helper projection or admitting Dart support.
  Depends on: `.14.2.3.0.2`
  Acceptance: Add `dart/lib/src/runtime/source_location.dart`. Snapshot caller-authorized decoded sources into one
    authority; keep immutable values free of copied text, paths, parser/match state, and host references; detach
    every record projection; validate authority, source, bounds, order, and derived provenance; convert zero-based
    Unicode-scalar offsets into one-based line/column and UTF-8-byte offsets while current Dart code-unit registers
    remain untouched; materialize direct and ordered multi-source text; and emit only the four neutral private
    errors with exact required context. Turn the two core tests GREEN by exact name selection, prove the full dormant
    consumer advances only to the `.2`-owned absent projection APIs, retain ordinary discovery at 379 tests, and
    change no engine/helper route, register, public result, neutral/schema/rollout row, root README, sole-facing
    mdBook claim, or other backend. Pass focused and complete Dart plus doctrine/canonical signoff, synchronize
    durable records, commit, clear the brief, and prove clean before `.14.2.3.2`.
  Verification: task-tree-only activation; focused core 2/2 GREEN; full dormant projection boundary exact RED;
    fatal analysis plus ordinary 379; format, complete Dart/storage/corpus/CLI 66x2; neutral checker, language
    coverage, Knowledge Map, sole-facing mdBook and rendered-block structure, all seven doctrines, and definitive
    canonical containment/relocation/CLI/Phase-0 signoff; atomic commit 154/300, brief clearing, and clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.3.1 - implement Dart source location core`

  ### `FUTURE-PARITY-BACKLOG.14.2.3.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove dormant RED `.0.2` landed at `58f4bb85` as 153/300 with
    parent `7b76af71`, empty status/diffs, zero-byte brief, valid memory pointer, absent generated book, and no
    background verification; make this task-tree file the sole activation diff before Dart source/test/live-doc
    changes.
  - [x] **RETRIEVE / CORE SHAPE** — Retrieve ADR `0056`, both typed-source Knowledge owners, the neutral artifact,
    frozen Dart consumer, and admitted Perl/Rust value-core precedents; map the exact Dart API and private diagnostic
    shape without re-deriving durable facts.
  - [x] **IMMUTABLE AUTHORITY / VALUES** — Add one owned decoded-source snapshot plus opaque immutable `Position`,
    direct `Span`, and ordered derived-text values with detached records and no ambient text/parser authority.
  - [x] **CONVERSION / MATERIALIZATION / ERRORS** — Pass all 3/7/6/3 fixtures, scalar/line/column/UTF-8 conversion,
    empty and multi-source materialization, authority ownership, and four exact private diagnostics.
  - [x] **LAYER BOUNDARY / LOCKSTEP** — Make only the two core tests GREEN; prove the full dormant consumer stops
    only at absent `.2` projection APIs; preserve ordinary/public/mdBook truth, rollout 5/9/39, code-unit registers,
    all 92+7 current helpers, schemas, aliases, and other backends.
  - [x] **SIGNOFF / CLEAN HANDOFF** — Pass focused, complete Dart, storage/path, mdBook/readability, Knowledge,
    doctrine, and canonical gates; synchronize durable/live records; commit/clear/prove clean before `.2`.

  Activation evidence 2026-08-07: dormant Dart RED `.14.2.3.0.2` committed atomically at `58f4bb85` as intended
  153/300 with first parent `7b76af71` and no push. Its hook regenerates Knowledge Map at 786/6,423 and passes all
  seven doctrines plus both memory-pointer phases. Post-commit status and staged/unstaged diffs are empty, the
  ignored brief is zero bytes, memory architecture passes, the generated book directory is absent, and no
  background result remains. This task-tree file is the sole activation diff before the immutable Dart module or
  any test/live-doc change.

  Retrieval/implementation evidence 2026-08-07: the Knowledge Map routes the Dart authority, dormant boundary,
  and host-unit questions to the typed-source runtime-rollout card; ADR `0056` section 9, the neutral artifact,
  frozen consumer, and admitted Perl/Rust modules agree on one authority and opaque scalar values. New
  `dart/lib/src/runtime/source_location.dart` copies the source map under a monotonic identity and precomputes
  scalar-indexed UTF-16, line, column, and UTF-8-byte boundaries. Final `Position`, direct `Span`, ordered
  `DerivedText`, detached `SourceCoordinates`, and private error records carry no decoded text, path, parser/match
  state, or engine/authority reference. The authority alone validates, converts valid code-unit boundaries, and
  materializes direct or `concatenate_in_order` text.

  Focused/layer evidence 2026-08-07: exact name selection passes the two immutable tests 2/2 across all 3 sources,
  7 conversions, 6 direct spans, 3 derived cases, copied authority ownership, detached records, and four exact
  privacy-filtered diagnostics. Removing the single analyzer exclusion leaves fatal analysis clean. The complete
  dormant file passes the two core tests and its independent carrier test, then records only one failure:
  `NoSuchMethodError` for absent `LinkedSpecRuntimeEngine.typedSourceProjectionRows()`. Thus `.2` owns the next
  boundary without a consumer rewrite. Ordinary discovery remains exactly 379/379.

  Broad/lockstep evidence 2026-08-07: complete Dart passes format 98 files / zero changes, fatal analysis, all 379
  ordinary tests, 20 storage owners / 47 locked packages, primary CLI 66/66 in default and POSIX option
  environments, all 105 corpus fixtures, and the exact Dart gate verdict. Neutral typed source remains 5 complete /
  9 pending / 39 mutations and language coverage remains 246 names / 105 corpus plus one named-mark fixture / 122
  independent Perl contracts. The source-unchanged sole-facing mdBook builds at 79 files / 14,152 KiB and its
  generated HTML retains separate typed-source status paragraphs and examples; the build artifact is removed.
  Knowledge Map regenerates at 786 facts / 6,427 question keys. No engine/helper route, UTF-16 register, 92+7
  result, schema/identity, semantic/MCP/capability state, authored DSL, root README, rollout row, or other backend
  changes.

  Signoff evidence 2026-08-07: memory architecture, Knowledge Map, and all seven registered doctrines pass.
  Definitive canonical CI preserves capability 80/0/0 and typed-source 5/9/39, executes the exact Rust 4/4
  consumer and every composed semantic/MCP admission, proves six-family project-data containment plus relocated
  and outside-CWD execution across all five primary anchors, and passes CLI 66/66 under both option environments.
  RAM is 61% against the 88% threshold; Phase 0 passes 1,031/1,031 in 686 seconds before the exact
  `[ci] local CI gate passed` marker and exit 0. The atomic commit, ignored-brief clearing, and clean handoff proof
  remain before task-tree-first projection `.14.2.3.2`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `f1b91426` lands with first parent `58f4bb85`; the hook
  regenerates Knowledge Map at 786/6,427, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit `HEAD` and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is absent,
  and the project-data run registry is empty. Projection `.14.2.3.2` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3.2`
  Status: `completed` (`3513508a`, 2026-08-07, 155/300, no push)
  Goal: Project the immutable Dart source authority/values through every exact source-boundary helper route while
    preserving all external values, UTF-16 code-unit registers, reconstructed/generated identities, and the
    still-pending Dart admission boundary.
  Depends on: `.14.2.3.1`
  Acceptance: Retrieve the typed-source Knowledge owner, ADR `0056`, neutral artifact/checker, dormant consumer,
    Dart engine/matching/carrier Knowledge owners, Toolbox probes, and admitted Perl/Rust projection precedents.
    Census the exact decoded-input owner, UTF-16-to-scalar boundary, 92 canonical helpers, seven aliases, rule-local
    marks, entry/match and anonymous capture boundaries, cursor stack, diagnostics, and native/reconstructed/
    generated-plan/emitted convergence before implementation. Add fresh detached
    `typedSourceProjectionRows()` and `typedSourceCompatibilityAliases()` catalogs. Initialize one immutable input
    authority per execution and route helper-boundary construction, validation, coordinates, source slicing, mark/
    capture/cursor operations, and derived materialization through typed values without changing live code-unit
    storage, names/arities, strings/numbers/maps/lists/booleans/absence values, mutation timing, diagnostics,
    schemas/identities, neutral rollout 5/9/39, root README, public DSL, sole-facing admission claims, or another
    backend. Turn the complete dormant consumer GREEN across exact 92+7 catalogs and all carriers; retain ordinary
    discovery at 379 and leave consumer registration plus `dart_runtime` promotion exclusively to `.14.2.3.3`.
    Pass focused and complete Dart, locality/path, mdBook/readability, Knowledge, doctrine, and canonical gates;
    synchronize durable records; commit, clear the brief, and prove clean before `.14.2.3.3`.
  Verification: task-tree-only activation; Toolbox route census; dormant projection 4/4 GREEN; core selection 2/2;
    ordinary 379; alias carrier 4/4; complete Dart/storage/corpus/CLI 66x2; neutral 5/9/39; language coverage;
    sole-facing mdBook and generated-block inspection; Knowledge Map; all seven doctrines; definitive canonical
    containment/relocation/CLI/Phase-0 signoff; atomic commit 155/300, brief clearing, and clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.3.2 - route Dart typed source projections`

  ### `FUTURE-PARITY-BACKLOG.14.2.3.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove core `.1` landed at `f1b91426` as 154/300 with parent
    `58f4bb85`, empty status/diffs, zero-byte ignored brief, valid post-commit memory pointer, absent generated
    book, and empty project-data run registry; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / TOOLBOX ROUTE CENSUS** — Follow Knowledge/ADR/neutral/consumer/Perl/Rust authorities and use
    LinkedSpec probes to map input ownership, code-unit/scalar conversion, all 92+7 routes, state, diagnostics, and
    carrier convergence before implementation.
  - [x] **CATALOG / ONE TYPED ROUTE** — Add detached exact catalogs and make every owned helper projection construct,
    validate, derive, and materialize through one per-input authority without a parallel semantics.
  - [x] **UNCHANGED RESULTS / CARRIERS / ADMISSION** — Pass the complete dormant consumer on native, reconstructed,
    generated-plan, and emitted paths; retain ordinary 379 and leave registration/rollout promotion only to `.3`.
  - [x] **LOCKSTEP / SIGNOFF / CLEAN HANDOFF** — Preserve schema/public/book/backend truth, update the sole-facing
    book only if current user understanding changes, pass focused/full/canonical/locality gates, synchronize all
    durable records, commit, clear the brief, and prove clean before `.3`.

  Activation evidence 2026-08-07: immutable Dart core `.14.2.3.1` landed atomically at `f1b91426` as intended
  154/300 with first parent `58f4bb85` and no push. Its hook regenerated Knowledge Map at 786/6,427, passed all
  seven doctrines, and proved the activation pointer in both Git phases. Post-commit status plus staged/unstaged
  diffs are empty, the ignored brief is zero bytes, memory architecture passes, the generated book is absent, and
  the project-data run registry reports zero retained runs. This task-tree file is the sole activation diff before
  any Dart runtime, test, Knowledge, roadmap, live-doc, neutral, mdBook, or other project change.

  Retrieval/census evidence 2026-08-07: Knowledge Map routes the settled authority, host-unit, alias, carrier,
  matching, trace, generated-v2, root-selection, and independent-inventory questions to their canonical cards.
  ADR `0056` section 9, the 92-row/four-family neutral catalog, frozen Dart consumer, and admitted Perl/Rust
  projection precedents agree on one input authority and compatibility-only external projections. Dart creates one
  `_RuntimeExecutionContext` inside `LinkedSpecRuntimeEngine._parse`; it owns decoded `input`, UTF-16 code-unit
  cursor/registers, rule-local mark buckets, anonymous capture boundary, and cursor stack. All helper evaluation
  converges on the one `_evaluateCall` switch. Native and reconstructed state instantiate the same engine;
  generated v2 validates its unchanged label/family plan and calls `executeGeneratedWithPlan`, which re-enters
  `_parse`; freshly emitted source calls the same `executeGeneratedParserV2` adapter. No descriptor, plan, loader,
  emitter, or second interpreter seam is needed.

  Executable pre-change proof 2026-08-07: the frozen carrier-only test passes 1/1 across complete named marks,
  cursor save/rewind/restore, aliases, native, reconstructed, and generated-plan routes. The dedicated alias suite
  passes 4/4 including a freshly compiled emitted package. Focused current capture/mark proof passes 5/5, including
  rule-local isolation and Unicode-scalar results over code-unit registers. Exact projection work therefore belongs
  in `source_location.dart` plus the existing engine/context/helper switch. The catalog is 47 capture/mark, 30
  entry/match, 11 input/cursor, and 4 cursor-control rows; capture-group collection/existence adapters remain
  detached pass-through shapes as in Rust, while source spans/positions, mark writes/reads, and cursor controls use
  the typed boundary. Retrieval also finds the dormant file's opening comment still describes the now-removed
  analyzer exclusion; this leaf owns correcting that test-local comment without changing the frozen assertions.

  Implementation/focused evidence 2026-08-07: `source_location.dart` now returns fresh detached copies of the
  exact 92-row catalog in 47/30/11/4 families plus all seven alias pairs. Every `_RuntimeExecutionContext` snapshots
  decoded `input` into one `SourceAuthority`. Typed adapter methods convert existing UTF-16 code-unit boundaries
  into scalar `Position`/`Span` values and route source text/slices, entry/local-match text and coordinates,
  anonymous capture spans, named-mark reads/writes, and cursor save/rewind/restore through authority validation and
  materialization. Capture-group collections/existence/deletion retain their detached pass-through shapes. The
  live cursor, entry/local match registers, rule-local mark buckets, anonymous boundary, and cursor stack still
  store code-unit offsets; no loader, generated-plan, emitter, descriptor, schema, or second interpreter changes.
  The test-local stale analyzer-exclusion comment is corrected without changing any assertion.

  Focused/broad evidence 2026-08-07: fatal analysis reports no issues. The complete dormant consumer passes 4/4,
  including exact core values/errors, detached 92+7 catalogs, complete named marks, cursor controls, native,
  reconstructed, and generated-plan behavior. The post-change matching/interpreter/named-mark/alias/emitter/loader
  selection passes 86/86, including freshly emitted alias execution. Ordinary discovery remains exactly 379/379.
  Complete Dart then passes format over 98 files with zero changes, fatal analysis, all 379 tests, 20 storage
  owners / 47 locked packages, CLI 66/66 in default and POSIX environments, all 105 corpus fixtures, and the exact
  Dart-gate verdict. The independent typed-source checker remains 5 complete / 9 pending / 39 mutations and
  language coverage remains 246 names / 105 corpus plus one named-mark fixture / 122 Perl contracts.

  Sole-facing lockstep evidence 2026-08-07: the capture/source-location mental model, project status, local-CI
  explanation, and backend handoff now distinguish implemented-but-dormant Dart values/projections from admitted
  Perl/Rust runtimes and still-pending Dart admission. The repository-routed mdBook builds 79 files / 14,164 KiB.
  Direct generated-HTML inspection proves each changed passage is a separate paragraph and examples remain
  separate code blocks; the generated book artifact is removed. No authored `Position`/`Span`, transaction,
  recursive-observation, schema, helper result, neutral rollout row, root README, or other backend claim moves.

  Signoff evidence 2026-08-07: Knowledge Map regenerates at 786 facts / 6,431 question keys; memory architecture
  and all seven registered doctrines pass. Definitive canonical CI preserves capability 80/0/0 and typed-source
  5/9/39, executes the admitted Rust typed-source consumer 4/4, byte-fresh MCP bindings, every composed semantic/
  MCP admission, all shared contracts, six-family project-data containment, and moved/outside-CWD execution across
  all five primary anchors. Primary CLI passes 66/66 under default and POSIX option environments; RAM is 68%
  against the 88% threshold. Phase 0 passes 1,031/1,031 in 677 seconds before exact `[ci] local CI gate passed`
  and exit 0. No generated book or background result remains. The atomic 155/300 commit, ignored-brief clearing,
  and clean proof precede task-tree-first admission `.14.2.3.3`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `3513508a` lands with first parent `f1b91426`; the hook
  regenerates Knowledge Map at 786/6,431, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is absent,
  and the project-data run registry is empty. Admission `.14.2.3.3` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.3.3`
  Status: `completed` (`c2a88218`, 2026-08-07, 156/300, no push)
  Goal: Admit the committed Dart immutable source-location values and exact 92+7 projection routes once through
    ordinary discovery, canonical CI, the neutral rollout ledger, and the sole-facing book without changing
    production runtime behavior.
  Depends on: `.14.2.3.2`
  Acceptance: Retrieve the runtime-rollout Knowledge card, ADR `0056` section 9, neutral artifact/checker, committed
    Dart consumer and complete-Dart/canonical registration, Rust admission precedent, and every sole-facing typed-
    source status passage before implementation. Move the one committed consumer from `dart/test_dormant/` into
    ordinary package discovery without changing its assertions; require and execute that exact wrapped four-test
    target once in canonical CI; promote only `dart_runtime` from pending to complete in the neutral artifact and
    independent checker; add one exact Dart completed-to-pending regression; and advance locked rollout truth from
    5/9/39 to 6/8/40. Update the mdBook's capture/source-location mental model, project status, canonical-CI
    explanation, and backend handoff so users can distinguish admitted internal Perl/Rust/Dart values/projections
    from absent public authored `Position`/`Span` values, transactions, and the pending Julia/PUC-Lua/LuaJIT
    runtimes. Preserve all production Dart source, UTF-16 code-unit registers, external helper results/mutations,
    diagnostic/trace behavior, descriptors/generated schemas and identities, semantic/MCP and capability state,
    DSL/facade spellings, root README, and other backends. Pass checker-first neutral RED/GREEN, exact ordinary and
    canonical Dart admission 4/4, complete Dart, language coverage, book build/rendered paragraphs, locality/path,
    Knowledge, doctrine, and definitive canonical gates; synchronize durable/live records; commit as 156/300,
    clear the brief, and prove clean before Julia authority/RED audit `.14.2.4.0`.
  Verification: task-tree-only activation; retrieval/root-cause proof; checker-first expected-count RED; exact
    ordinary/canonical Dart consumer 4/4; neutral 6/8/40; complete Dart format/analyzer/package 383/storage/corpus/
    CLI 66x2; language coverage; repository-local mdBook and generated-block inspection; Knowledge Map; all seven
    doctrines; definitive canonical containment/relocation/CLI/Phase-0 signoff; atomic commit 156/300, brief clear,
    and clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.3.3 - admit Dart typed source runtime`

  ### `FUTURE-PARITY-BACKLOG.14.2.3.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove projection `.2` landed at `3513508a` as 155/300 with parent
    `f1b91426`, empty status/diffs, zero-byte ignored brief, valid memory pointer, absent generated book, and empty
    project-data registry; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / ROOT CAUSE** — Use Knowledge/ADR/neutral/checker/consumer/drivers/Rust precedent/book evidence
    to prove discovery, canonical registration, and the `dart_runtime` row are the only remaining admission gaps.
  - [x] **REGISTER / PROMOTE EXACTLY ONCE** — Move the unchanged consumer into ordinary discovery, execute its exact
    target once canonically, promote only Dart, and lock rollout 6/8 with an independent 40th mutation.
  - [x] **PUBLIC TRUTH / NO REGRESSION** — Publish admitted internal Dart values/projections without claiming public
    typed values/transactions or changing production/results/registers/schema/semantic/MCP/capability/DSL/README/
    backend behavior; pass focused, complete Dart, book, storage, doctrine, and definitive canonical gates.
  - [x] **LOCKSTEP / COMMIT / CLEAN** — Synchronize artifact/checker/CI/book/task/index/roadmaps/architecture/change/
    development/live/memory/Knowledge at 6/8/40; commit as 156/300, clear the brief, and prove clean before Julia.

  Activation evidence 2026-08-07: projection `.14.2.3.2` landed atomically at `3513508a` as intended 155/300 with
  first parent `f1b91426` and no push. Its hook regenerated Knowledge Map at 786/6,431, passed all seven doctrines,
  and proved the activation pointer in both Git phases. Post-commit status plus staged/unstaged diffs are empty,
  the ignored brief is zero bytes, memory architecture passes, the generated book is absent, and the project-data
  registry reports zero retained runs. This task-tree file is the sole activation diff before any consumer move,
  neutral artifact/checker, canonical driver, book, Knowledge, roadmap, or other project change.

  Retrieval/root-cause evidence 2026-08-07: the canonical Knowledge owner, ADR `0056` section 9, neutral artifact,
  independent checker, complete four-test Dart consumer, canonical driver, Rust admission commit `666751ae`, and
  all four sole-facing book passages agree. Dart's immutable authority/value core and exact 92+7 projections are
  already implemented across native, reconstructed, generated-plan, and emitted execution. The sole remaining
  gaps are directory-based ordinary-discovery dormancy, absence of the exact consumer from canonical CI, and the
  one pending `dart_runtime` rollout row. No production Dart source, helper result, register, carrier, schema,
  semantic/MCP/capability surface, DSL, README, or other backend requires change.

  Checker-first/admission evidence 2026-08-07: the independently strengthened checker requires the ordinary Dart
  consumer path and exact repository-wrapped command, rejects any retained dormant path/comment, expects Dart
  complete at 6/8, and adds the 40th completed-to-pending mutation. Against the unchanged artifact it exits 1 at
  exact `expected counts drifted`. Moving the committed consumer into `dart/test/` and changing only its stale
  header, promoting only `dart_runtime`, recording 40 mutations, and registering its exact target turns the same
  checker GREEN at 6 complete / 8 pending / 40 mutations. The exact admitted consumer passes all 4/4 assertions.

  Dart/book evidence 2026-08-07: the authoritative complete Dart gate passes formatting over 98 files with zero
  changes, fatal analysis, ordinary package discovery at 383/383, 20 project-data owners / 47 locked packages,
  primary CLI 66/66 under default and POSIX option environments, and all 105 corpus fixtures. The sole-facing
  capture/source-location model, project status, local-CI explanation, and backend handoff now state that internal
  Perl/Rust/Dart values and 92+7 projections are admitted at 6/8/40 while public authored `Position`/`Span` values,
  transactions, recursive observation, and Julia/PUC-Lua/LuaJIT admissions remain future. The repository-routed
  book builds 79 files / 14,164 KiB; direct inspection of the four generated pages proves separate `<p>` elements
  and a separate Dart `<pre><code>` command block. The generated artifact is removed.

  Signoff evidence 2026-08-07: Knowledge Map regenerates at 786 facts / 6,432 question keys; memory architecture,
  whitespace, artifact absence, zero retained project-data runs, language coverage 246/105+1/122, and all seven
  registered doctrines pass. Definitive canonical CI independently reports capability 80/0/0 and typed source
  6/8/40; executes Perl 10, Rust 4/4, and the new exact Dart 4/4 typed-source consumers; validates byte-fresh MCP
  bindings and every composed semantic/MCP admission; proves six-family repository containment plus moved/outside-
  CWD execution across all five primary anchors; and passes primary CLI 66/66 under default and POSIX option
  environments. RAM is 73% against the 88% threshold. Phase 0 passes 1,031/1,031 in 685 seconds before exact
  `[ci] local CI gate passed` and exit 0. Atomic commit 156/300, ignored-brief clearing, and clean handoff proof
  remain before task-tree-first Julia `.14.2.4.0`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `c2a88218` lands with first parent `3513508a`; the hook
  regenerates Knowledge Map at 786/6,432, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is absent,
  and the project-data run registry is empty. Julia authority/RED audit `.14.2.4.0` may therefore activate
  task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4`
  Status: `completed` (`46612a72`, 2026-08-07, 162/300, no push)
  Goal: Implement and independently admit the same neutral typed source-location algebra in Julia.
  Children: `.14.2.4.0` authority/prerequisite-split audit; `.14.2.4.0.1` seven-alias Julia parity;
    `.14.2.4.0.2` exact typed-source RED; `.14.2.4.1` immutable value/conversion core; `.14.2.4.2` helper/
    unchanged loaded-emitted-plan interpreter routes; `.14.2.4.3` exact admission/promotion.
  Acceptance: Use `SourceLocation.jl`, `Matching.jl`, `Interpreter.jl`, `LinkedSpecJulia.jl`, and
    `typed_source_location_contract_test.jl`; retain code-unit registers, convert at the typed boundary, prove
    native/serialized/emitted execution without schema change, bind the consumer, and promote only `julia_runtime`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4.0`
  Status: `completed` (`57c62ce4`, 2026-08-07, 157/300, no push)
  Goal: Map Julia's exact decoded-source authority, native string-index cursor/mark/match registers, all 92+7
    source-boundary routes, loaded/reconstructed/generated/emitted carriers, diagnostic seams, and test discovery;
    freeze one exact dormant typed-source RED only if the measured compatibility baseline is sound, otherwise split
    prerequisite correction leaves without changing current behavior or neutral rollout 6/8/40.
  Depends on: `.14.2.3.3`, `.14.2.0`
  Acceptance: Retrieve the typed-source runtime-rollout Knowledge card, ADR `0056` section 9, neutral artifact/
    checker, admitted Perl/Rust/Dart consumers, Julia runtime/matching/generated/diagnostic Knowledge owners,
    Toolbox, exact Julia source and current tests, complete Julia driver, canonical registration, and every sole-
    facing typed-source passage before implementation. Prove the decoded-input owner; native index unit and exact
    scalar/line/column/UTF-8 conversion seams; all 92 canonical helpers plus seven aliases; cursor, mark, entry/local-
    match, anonymous-boundary, and save-stack state; native, normalized, loaded, reconstructed, generated-plan, and
    emitted convergence; structured-error boundary; ordinary package discovery; and current behavior with
    repository-routed executable probes. If every prerequisite holds, add one test-local dormant consumer outside
    ordinary discovery whose core/projection failures name only the absent future Julia typed API. If a premise is
    false, add no misleading RED or production code: record the exact contradiction and split narrowly owned
    prerequisites first. Preserve current production behavior, helper results/mutations, native registers, schemas/
    identities, semantic/MCP/capability state, DSL/facade, neutral 6/8/40, root README, sole-facing book truth, and
    all other backends. Pass focused unchanged helper/carrier proof, complete Julia/storage/corpus/CLI, language/
    neutral, book/readability, Knowledge, doctrine, and definitive canonical gates; synchronize durable/live
    records; commit as 157/300; clear the brief; and prove clean before the next exact Julia leaf.
  Verification: task-tree-only activation; Knowledge/Toolbox authority and 92+7 executable census; exact native-
    unit/conversion/state/carrier/root-cause proof; dormant RED or prerequisite split with ordinary discovery
    unchanged; focused and complete Julia/storage/corpus/CLI; neutral 6/8/40 and language coverage; sole-facing
    mdBook plus generated-block inspection; Knowledge Map; all seven doctrines; definitive canonical containment/
    relocation/CLI/Phase-0 signoff; atomic commit 157/300, brief clearing, and clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.4.0 - map Julia typed source boundary`

  ### `FUTURE-PARITY-BACKLOG.14.2.4.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove Dart admission `.14.2.3.3` landed at `c2a88218` as 156/300
    with parent `3513508a`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent generated
    book, and empty project-data registry; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / INVENTORY** — Use Knowledge Map, ADR, neutral/checker, admitted precedents, Toolbox, Julia
    source/tests/drivers, canonical registration, and book to map every authority, unit, route, carrier, diagnostic,
    and current claim before deriving or changing behavior.
  - [x] **EXECUTABLE BASELINE / ROOT CAUSE** — Probe all 92+7 spellings plus representative Unicode/state/carrier
    behavior and ordinary discovery; prove the exact missing typed seams and any contradictory prerequisite.
  - [x] **FREEZE RED OR SPLIT** — If premises hold, add one isolated dormant Julia core/projection RED with exact
    first failure and ordinary-green discovery; otherwise freeze narrowly owned prerequisites without behavior code.
  - [x] **NO REGRESSION / LOCKSTEP / CLEAN** — Preserve production/public/schema/DSL/semantic/MCP/capability/
    neutral/book/backend truth; pass focused/full/doctrine/canonical gates, synchronize records, commit as 157/300,
    clear the brief, and prove clean before the next Julia leaf.

  Activation evidence 2026-08-07: Dart admission `.14.2.3.3` landed atomically at `c2a88218` as intended 156/300
  with first parent `3513508a` and no push. Its hook regenerated Knowledge Map at 786 facts / 6,432 question keys,
  passed all seven doctrines, and proved the activation pointer in both Git phases. Post-commit status plus staged/
  unstaged diffs are empty, the ignored brief is zero bytes, memory architecture passes, the generated book is
  absent, and the project-data registry reports zero retained runs. This task-tree file is the sole activation
  diff before any Julia source, test, neutral artifact/checker, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval/authority evidence 2026-08-07: the Knowledge Map routes the typed-source rollout to
  `typed-source-location-runtime-rollout-plan` and Julia matching, cursor-boundary, rule-interpreter, generated-v2,
  and structured-diagnostic questions to their current Julia cards. ADR `0056` section 9, neutral artifact/checker,
  admitted Perl/Rust/Dart consumers, Toolbox, exact Julia source/tests/drivers, canonical registration, and all
  sole-facing typed-source passages agree on the boundary. `_RuntimeExecutionContext` copies the decoded `String`
  once and owns zero-based UTF-8 code-unit cursor, rule-local mark buckets, anonymous capture boundary, and cursor
  stack; `RuntimeMatchRegisters` owns entry/local matches over the same copied text. Matching converts only valid
  code-unit boundaries to Unicode-scalar offsets and one-based line/column. `SpecLoader`, normalized `SpecFile`
  reconstruction, generated-v2 plans, and emitted modules all compile into and re-enter `LinkedSpecRuntimeEngine`;
  `RuntimeInterpreterException.diagnostic` is the structured failure seam. Ordinary `Pkg.test()` discovery is the
  explicit include list in `julia/test/runtests.jl`. No `SourceLocation.jl`, typed-source consumer, source authority,
  Position/Span/DerivedText runtime core, typed projection catalog, Julia canonical typed-source registration, or
  Julia rollout promotion exists. The book accurately claims only Perl/Rust/Dart admission at 6/8/40 and explicitly
  leaves Julia pending.

  Executable contradiction evidence 2026-08-07: one repository-routed Julia probe reads the neutral artifact and
  proves all 92 canonical rows are unique and known. It then checks and executes every alias. Julia knows and
  canonicalizes zero of seven: `capture_from_rule_start`, `capture_len_from_rule_start`, `capture_rest_length`,
  `capture_slice_here`, `capture_slice_length`, `entry_named_map`, and `match_named_map` are absent from Julia source
  and tests; each preserves its own spelling instead of resolving to the frozen target and throws
  `RuntimeInterpreterException` at `runtime_execution` with exact `unsupported runtime helper '<name>' in rule Top`.
  The unchanged loaded/generated/carrier baseline passes loader 82/82, generated source 65/65, rule-local cursor
  104/104, and complete named marks 13/13. The project-data registry returns zero retained runs afterward. Because
  the supposedly unchanged 92+7 compatibility baseline is false, this leaf adds no misleading typed RED and no
  production behavior. Alias parity `.14.2.4.0.1` must land before exact dormant RED `.14.2.4.0.2`.

  Signoff evidence 2026-08-07: the complete unchanged Julia gate passes every package suite, proves 18 project-
  data owners and five locked package trees, passes primary CLI 66/66 under default and POSIX environments, and
  passes corpus 105/105. The neutral checker remains exact at 6 complete / 8 pending / 40 mutations; language
  coverage remains 246 current call names / 105 corpus plus one exact named-mark fixture / 122 independently
  covered Perl contracts. The sole-facing book already says Julia is pending and limits admitted values/projections
  and all seven executable aliases to Perl/Rust/Dart; its repository-routed build produces 79 files / 14,164 KiB,
  generated HTML retains separate paragraph elements at the audited passages, and the artifact is removed. The
  new alias-gap fact plus synchronized rollout fact regenerate Knowledge Map at 787 facts / 6,450 question keys;
  all seven doctrines pass.

  Definitive unrestricted canonical CI exits 0 after capability 80/0/0, typed source 6/8/40 with Perl 10 plus
  Rust/Dart 4/4, all composed semantic/MCP admissions, relocated six-family process containment, moved-root Rust
  plus four outside-CWD runtime anchors, primary CLI 66x2, RAM 79% against the 88% ceiling, Phase 0 1,031/1,031,
  and exact `[ci] local CI gate passed`. The first otherwise-green run stopped only because the session's outer
  sandbox denied the gate's own nested `sandbox-exec`; the exact unrestricted rerun proves the repository-owned
  containment path. Atomic commit 157/300, ignored-brief clearing, post-commit memory validation, and clean proof
  remain before task-tree-first alias parity `.14.2.4.0.1`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `57c62ce4` lands with first parent `c2a88218`; the hook
  regenerates Knowledge Map at 787/6,450, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is absent,
  and the project-data run registry is empty after removing the exact empty checkout parent recreated by the final
  check. Julia seven-alias parity `.14.2.4.0.1` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4.0.1`
  Status: `signoff-complete` (2026-08-07; task-tree-first from clean authority-audit commit `57c62ce4`, intended
    158/300, no push; atomic commit/clean handoff pending)
  Goal: Add exactly the seven neutral source-boundary compatibility spellings at Julia's existing known-name and
    canonicalization seam so every alias executes its preferred helper semantics without duplicating interpreter
    branches or admitting typed source values.
  Depends on: `.14.2.4.0`
  Acceptance: Retrieve the Julia alias-gap Knowledge owner, neutral alias rows/checker, exact Perl/Rust/Dart alias
    precedents, `ActionContracts.jl`, `Interpreter.jl`, generated-v2 carriers, complete named-mark/cursor tests,
    language coverage, canonical registration, and sole-facing book before implementation. Add exactly seven
    source-name-to-canonical mappings and make them known without widening the common 246-name inventory or adding
    a parallel runtime branch. Prove canonical contract resolution, exact unrelated-helper diagnostics, Unicode
    text/scalar widths, anonymous-boundary mutation and reversed-span absence, named-map shapes, and alias/canonical
    equality across native, loaded/reconstructed, generated-plan, and independently loaded emitted source. Preserve
    all canonical helper behavior, native code-unit registers, schemas/identities, neutral 6/8/40, Julia typed-source
    pending status, root README, other backends, and public typed/transaction claims. Pass focused/complete Julia,
    storage/corpus/CLI, language/neutral, book/readability, Knowledge, doctrine, and definitive canonical gates;
    commit, clear the brief, and prove clean before `.14.2.4.0.2`.
  Verification: exact seven-alias RED/GREEN consumer; 92+7 inventory and carrier equality; complete Julia and
    canonical no-drift; unchanged neutral 6/8/40 and public book truth
  Commit: `FUTURE-PARITY-BACKLOG.14.2.4.0.1 - add Julia source aliases`

  ### `FUTURE-PARITY-BACKLOG.14.2.4.0.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove audit `.14.2.4.0` landed at `57c62ce4` as 157/300 with
    parent `c2a88218`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent generated book,
    and empty project-data registry; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT RED** — Retrieve the Julia alias-gap and rollout Knowledge owners, neutral alias rows,
    Perl/Rust/Dart precedents, Julia known-name/canonicalization/runtime/carrier owners, Toolbox, focused/complete
    tests, canonical registration, and sole-facing book; freeze exact 0/7 known/canonical/executable RED before code.
  - [x] **MINIMAL ALIAS ADAPTER** — Add exactly seven alias-to-canonical mappings at the existing Julia contract
    seam, make them known through that single inventory, and add no alias-specific interpreter branch, common call-
    name widening, typed value/core/projection catalog, schema/identity, or unrelated helper behavior.
  - [x] **BEHAVIOR / CARRIER PROOF** — Prove all seven aliases equal their canonical targets for Unicode widths,
    anonymous capture boundary mutation and absence, named-map shapes, cursor restoration, and exact unrelated-name
    diagnostics across native, loaded/reconstructed, generated-plan, and independently loaded emitted execution.
  - [x] **NO REGRESSION / LOCKSTEP / CLEAN** — Preserve neutral 6/8/40, Julia pending status, production register
    units, external values, public book truth, README, semantic/MCP/capability, DSL, and other backends; pass focused,
    complete Julia/storage/corpus/CLI, language/neutral, book/readability, Knowledge, doctrine, canonical gates;
    synchronize records, commit as 158/300, clear the brief, and prove clean before `.14.2.4.0.2`.

  Activation evidence 2026-08-07: audit `.14.2.4.0` lands atomically at `57c62ce4` as intended 157/300 with first
  parent `c2a88218` and no push. Its hooks regenerate Knowledge Map at 787 facts / 6,450 question keys, pass all
  seven doctrines, and prove the activation pointer in both Git phases. Post-commit status plus staged/unstaged
  diffs are empty, the ignored brief is zero bytes, memory architecture passes, the generated book is absent, and
  the repository-managed run registry is empty. This task-tree file is the sole activation diff before any Julia
  production, test, neutral, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval/RED evidence 2026-08-07: Knowledge Map routes directly to the Julia alias-gap and runtime-rollout
  owners. The neutral 92+7 contract/checker, exact Perl/Rust/Dart precedents, Julia `ActionContracts.jl`, shared
  interpreter, loader/generated-v2 carriers, cursor/named-mark tests, language/canonical drivers, and sole-facing
  book establish one existing canonicalization seam and six already-supported preferred targets. The new ordinary
  consumer first fails at 11 pass / 4 fail / 2 error. An independent exact census proves 0/7 aliases known, 0/7
  canonicalized, and 7/7 compiled invocations failing with `RuntimeInterpreterException` detail
  `unsupported runtime helper '<name>' in rule Top`; the unrelated-name probe freezes that same structured
  `runtime_execution` / `julia_runtime` diagnostic before production code.

  Implementation/focused evidence 2026-08-07: `ActionContracts.jl` adds one private seven-row alias-to-canonical
  map, consults it before the existing numeric/current maps, and unions only its keys into the Julia known-name set.
  Every spelling therefore reaches the existing `capture_slice`, `capture_slice_len`, `capture_rest_len`,
  `start_capture_slice`, `entry_map`, or `match_map` branch; there is no alias-specific interpreter arm, shared
  246-name widening, typed source core/catalog, register, schema, identity, or other-backend change. The exact
  consumer passes 141/141 over resolver arity, Unicode scalar widths, anonymous-boundary mutation, reversed-span
  absence, named-map shapes, unrelated diagnostics, native, loaded, normalized/reconstructed, generated-plan, and
  independently loaded emitted modules. Language coverage independently locks both Dart's and Julia's exact seven
  mappings to the neutral contract while retaining 246 current names / 105 corpus plus one named-mark fixture /
  122 independently covered Perl contracts.

  First complete-gate classification 2026-08-07: the full Julia package, including the new 141 assertions, passes.
  The gate then correctly rejects project-storage census drift because the new carrier consumer uses repository-
  routed `mktempdir` but was not yet one of the 18 enumerated Julia temporary owners. Registering that exact path
  as owner 19 and changing only the explicit pass count makes the focused storage gate pass 19 owners / five
  locked package trees.

  Complete Julia evidence 2026-08-07: the fresh uninterrupted `tools/run_julia_local.sh` rerun exits 0. It proves
  the 120,030-byte generated MCP binding is fresh, passes the complete package including the 141 new assertions,
  passes all decoded/stdio/admission MCP consumers, verifies 19 project-data owners and five locked package trees,
  passes primary CLI conformance, and executes all 105 corpus fixtures before exact
  `[julia-ci] Julia local gate passed`. Independent focused reruns pass aliases 141/141, neutral typed source
  6/8/40, language coverage 246/105+1/122, and capability schema v2 / 80-0-0 / 24+6.

  Sole-facing evidence 2026-08-07: the source-boundary reference now says Perl/Rust/Dart/Julia execute all seven
  aliases and extends the Unicode migration fixture to Julia while explicitly separating callable spelling parity
  from still-pending Julia typed values/projections. Local-CI and backend-handoff pages state that both Dart and
  Julia mappings are checked against neutral without widening the shared inventory. The repository-routed book
  builds 79 files / 14,168 KiB; generated HTML shows distinct table, status paragraph, example paragraph, code
  block, replacement guidance, and following delimiter paragraph. The generated artifact is removed.

  Governance/signoff evidence 2026-08-07: Knowledge Map remains 787 facts / 6,450 question keys, all seven
  doctrines pass, whitespace is clean, and README remains unchanged. The definitive permission-authorized
  canonical gate executes the strengthened Julia mapping/route guard, capability 80/0/0, neutral typed source
  6/8/40 plus Perl 10 and Rust/Dart 4/4, every composed semantic/MCP admission, repository-contained relocated
  six-family IO, moved-root Rust, and four outside-CWD runtime anchors. Primary CLI passes 66/66 in default and
  POSIX option environments, RAM is 66% against the 88% ceiling, and Phase 0 passes 1,031/1,031 in 700 seconds
  before exact `[ci] local CI gate passed`. Atomic commit 158/300, brief clearing, post-commit validation, and clean
  proof remain before task-tree-first `.14.2.4.0.2`; no push.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4.0.2`
  Status: `completed` (`6d293ac0`, 2026-08-07, 159/300, no push)
  Goal: Freeze one dormant Julia consumer for the neutral immutable source values, four owned diagnostics, exact
    92 canonical projections plus seven now-callable aliases, and unchanged runtime carriers before production core
    implementation.
  Depends on: `.14.2.4.0.1`
  Acceptance: Start from clean alias parity. Add one test-local consumer outside `julia/test/runtests.jl` ordinary
    discovery. Its core mode must fail only for the absent future `SourceLocation.jl` API; its projection mode must
    remain independently nested behind the core and require exact 92+7 catalogs plus native/reconstructed/generated-
    plan behavior. Lock 3/7/6/3 value fixtures, four private errors, detached values, native host-unit conversion,
    rule-local marks, anonymous boundary, cursor stack, and unchanged external results without production, neutral,
    schema, canonical registration, or book-admission change. Pass ordinary complete Julia with the dormant file
    excluded, explicit RED diagnostics, storage/corpus/CLI, language/neutral, book/readability, Knowledge, doctrine,
    and definitive canonical gates; commit, clear the brief, and prove clean before `.14.2.4.1`.
  Verification: ordinary Julia remains green; explicit core/projection modes fail only on owned absent future APIs;
    neutral remains 6/8/40 and Julia remains pending
  Commit: `FUTURE-PARITY-BACKLOG.14.2.4.0.2 - freeze Julia typed source RED`

  ### `FUTURE-PARITY-BACKLOG.14.2.4.0.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove alias parity `.14.2.4.0.1` landed at `3a848631` as 158/300
    with parent `57c62ce4`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent generated
    book, and empty project-data registry; make this task-tree file the sole activation diff.
  - [x] **DECLARED-CHILD GRAPH REPAIR** — Instantiate the parent-declared but missing `.14.2.4.1-.3` task nodes
    for immutable core, projection routing, and exact admission before the RED consumer points at those next owners.
    Change no implementation ordering, rollout state, production behavior, or roadmap direction.
  - [x] **RETRIEVE / CURRENT BASELINE** — Retrieve the rollout/Julia Knowledge owners, neutral 3/7/6/3 values,
    four diagnostics, 92+7 catalogs, admitted Perl/Rust/Dart RED precedents, Julia source/runtime/carrier owners,
    Toolbox, ordinary/canonical discovery, storage census, and sole-facing pending claims before writing the consumer.
  - [x] **DORMANT CORE RED** — Add exactly one test-local consumer outside ordinary `runtests.jl` discovery whose
    base mode freezes immutable source authority/value semantics and fails only for absent future `SourceLocation.jl`
    APIs. Preserve ordinary package, production, neutral, analyzer/compiler, schema, and book behavior.
  - [x] **NESTED PROJECTION RED** — Independently nest projection mode behind core mode; require fresh detached
    exact 92+7 catalogs and current native/reconstructed/generated-plan results, and prove its first failure names
    only the absent projection API after the core exists. Add no canonical registration or production implementation.
  - [x] **NO REGRESSION / LOCKSTEP / CLEAN** — Preserve Julia alias parity, zero-based UTF-8 code-unit registers,
    neutral 6/8/40, pending Julia admission, sole-facing truth, README, semantic/MCP/capability, DSL, and other
    backends; pass ordinary complete Julia/storage/corpus/CLI, explicit RED diagnostics, language/neutral, book,
    Knowledge, doctrine, and definitive canonical gates; synchronize records, commit as 159/300, clear the brief,
    and prove clean before `.14.2.4.1`.

  Activation evidence 2026-08-07: alias parity `.14.2.4.0.1` lands atomically at `3a848631` as intended 158/300
  with first parent `57c62ce4` and no push. Its hooks regenerate Knowledge Map at 787 facts / 6,450 question keys,
  pass all seven doctrines, and validate the activation pointer in pre-commit and post-commit Git phases. Status plus
  staged/unstaged diffs are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes,
  the generated book is absent, and the exact empty managed-run parent recreated by final verification is removed.
  This task-tree file is the sole activation diff before any dormant Julia consumer, source, driver, storage census,
  neutral artifact/checker, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval graph finding 2026-08-07: parent `.14.2.4`, both roadmap projections, ADR `0056`, and the runtime-
  rollout Knowledge owner already prescribe `.14.2.4.1` immutable core, `.2` projection routing, and `.3` admission,
  but no detailed nodes for those three declared children existed in this task-tree file. This was an incomplete
  task representation rather than ambiguous direction. The exact nodes below restore the already-adopted order and
  boundaries before the dormant consumer is written; no new scope, behavior, or rollout claim is introduced.

  Retrieval/design evidence 2026-08-07: the canonical rollout and Julia Knowledge owners, ADR `0056` section 9,
  neutral 3/7/6/3 values and four private diagnostics, exact 47/30/11/4 projection families plus seven aliases,
  Perl/Rust/Dart RED consumers, Julia package/include/runtime/carrier authorities, Toolbox, storage census, and all
  sole-facing pending claims agree. Ordinary Julia discovery is only the explicit include list in
  `julia/test/runtests.jl`; native, reconstructed, and generated-v2-plan carriers converge on
  `LinkedSpecRuntimeEngine`. Julia already exports the parser-AST `SourceSpan`, so the future value vocabulary is
  frozen inside private `LinkedSpecJulia.SourceLocation`: this avoids a type collision and adds no public facade or
  authored spelling. Detailed `.14.2.4.1-.3` nodes now preserve that boundary and the already-declared rollout.

  Dormant-consumer evidence 2026-08-07: `julia/test/typed_source_location_contract_test.jl` is committed at its
  final test path but is absent from ordinary `runtests.jl` and canonical registration. Its explicit `core` mode
  freezes copied authority ownership; detached Position/Span/DerivedText/coordinate records; all 3/7/6/3 fixtures;
  and exactly the four owned, source-private diagnostics. Its independently selected `projection` mode is ordered
  strictly after the same core namespace and additionally freezes fresh detached exact 92+7 catalogs, complete
  named-mark scope/absence, anonymous-boundary mutation, cursor save/restore, aliases, and unchanged native,
  reconstructed, and generated-plan results. Neither mode uses temporary storage or changes production code.

  Exact RED/baseline evidence 2026-08-07: parsing the complete dormant file succeeds. Repository-routed `core` and
  `projection` commands each exit 1 with the sole current failure `UndefVarError: SourceLocation not defined in
  LinkedSpecJulia`; an invalid mode is rejected before contract evaluation. Projection API lookup occurs only after
  core lookup, so `.14.2.4.1` can make core green and expose the separately owned missing
  `typed_source_projection_rows` seam without rewriting the consumer. Ordinary alias proof remains 141/141; the
  neutral checker remains exactly 6 complete / 8 pending / 40 mutations; language coverage remains
  246 current / 105 corpus plus one named-mark fixture / 122 independent Perl contracts. The uninterrupted complete
  Julia gate passes the byte-fresh 120,030-byte MCP binding, all package tests with the dormant file omitted,
  storage 19 owners / five locked package trees, primary CLI, corpus 105/105, and exact
  `[julia-ci] Julia local gate passed`.

  Governance/signoff evidence 2026-08-07: the source-unchanged sole-facing mdBook builds 79 files / 14,168 KiB;
  generated HTML keeps its table, status paragraph, example paragraph, code block, replacement guidance, and
  following delimiter paragraph in distinct blocks while accurately leaving Julia values/projections pending. The
  Knowledge Map regenerates at 787 facts / 6,455 question keys, all seven doctrines pass, and whitespace is clean.
  Definitive canonical CI preserves capability 80/0/0, typed source 6/8/40 plus Perl 10 and Rust/Dart 4/4, every
  composed semantic/MCP admission, six-family project-data containment, repository relocation, moved-root Rust,
  and all four outside-CWD runtime anchors. Primary CLI passes 66/66 in both default and POSIX option environments,
  RAM is 62% against the 88% ceiling, and Phase 0 passes 1,031/1,031 in 705 wallclock seconds before exact
  `[ci] local CI gate passed`. Atomic commit 159/300, brief clearing, post-commit validation, and clean proof remain
  before task-tree-first immutable core `.14.2.4.1`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `6d293ac0` lands with first parent `3a848631`; the hook
  regenerates Knowledge Map at 787/6,455, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the generated book is absent, and the exact empty
  managed-run directory recreated by final verification is removed. Immutable Julia core `.14.2.4.1` may therefore
  activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4.1`
  Status: `completed` (`4d394752`, 2026-08-07, 160/300, no push)
  Goal: Implement one immutable Julia decoded-source authority plus Position, Span, DerivedText, context, policy,
    coordinate, validation, and materialization values for the neutral 3/7/6/3 fixtures and four private errors.
  Depends on: `.14.2.4.0.2`
  Acceptance: Add `julia/src/runtime/SourceLocation.jl`, include and expose only the internal API frozen by the
    dormant consumer, copy decoded sources into one opaque authority, retain scalar offsets in detached immutable
    values, precompute exact scalar/code-unit/line-column/UTF-8 boundary evidence, and keep decoded text plus host
    references private. Make only the dormant core selection pass; the nested projection selection must then fail
    solely for absent projection catalogs/routes. Preserve every runtime helper path, zero-based UTF-8 code-unit
    register, external result, schema/identity, neutral 6/8/40, ordinary discovery, and public book claim. Pass
    focused/complete Julia plus doctrine/canonical signoff, commit, clear the brief, and prove clean before `.2`.
  Verification: dormant core values/diagnostics green; nested projection mode has one exact owned missing-API failure;
    ordinary Julia and neutral rollout unchanged
  Commit: `FUTURE-PARITY-BACKLOG.14.2.4.1 - implement Julia source location core`

  ### `FUTURE-PARITY-BACKLOG.14.2.4.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove dormant RED `.14.2.4.0.2` landed at `6d293ac0` as 159/300
    with parent `3a848631`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent generated
    book, and empty project-data registry; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT API** — Retrieve the rollout/Julia authority Knowledge cards, ADR `0056`, neutral
    contract, frozen dormant consumer, Perl/Rust/Dart immutable-core precedents, current Julia module/export style,
    Toolbox, storage rules, and sole-facing pending claims before implementation.
  - [x] **PRIVATE IMMUTABLE CORE** — Add only `julia/src/runtime/SourceLocation.jl` and its internal module include.
    Copy decoded sources into one opaque authority; implement context, policy, Position, Span, DerivedText,
    coordinates, detached JSON, validation, and materialization without source text or host references in values.
  - [x] **NATIVE CONVERSION / FOUR ERRORS** — Convert Unicode-scalar offsets exactly to Julia UTF-8 code-unit,
    one-based line/column, and UTF-8-byte evidence; emit only the four frozen private diagnostics with exact context
    and no source/parser leakage.
  - [x] **CORE GREEN / PROJECTION RED** — Make explicit `core` mode pass all 3/7/6/3 values and diagnostics; prove
    `projection` mode advances to one exact missing projection-catalog API owned solely by `.14.2.4.2`.
  - [x] **NO REGRESSION / LOCKSTEP / CLEAN** — Preserve all current helper routes, zero-based UTF-8 code-unit
    registers, alias 141/141, neutral 6/8/40, pending Julia admission, schemas, sole-facing truth, README,
    semantic/MCP/capability, DSL, and other backends; pass focused/complete Julia/storage/corpus/CLI, book,
    Knowledge, doctrines, and definitive canonical CI; synchronize records, commit as 160/300, clear the brief,
    and prove clean before `.14.2.4.2`.

  Activation evidence 2026-08-07: dormant RED `.14.2.4.0.2` lands atomically at `6d293ac0` as intended 159/300
  with first parent `3a848631` and no push. Hooks regenerate Knowledge Map at 787/6,455, pass all seven doctrines,
  and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the generated book is
  absent, and the exact empty managed-run directory recreated by verification is removed. This task-tree file is
  the sole activation diff before any Julia source, module include/export, test expectation, storage census,
  neutral artifact/checker, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval/design evidence 2026-08-07: `KNOWLEDGE_MAP.md` routes Julia authority and rollout questions to the
  canonical typed-source and compatibility cards; ADR `0056` section 9, the neutral 3/7/6/3 plus four-diagnostic
  contract, the dormant consumer, and the admitted Perl/Rust/Dart cores agree. Julia uses immutable UTF-8 `String`
  storage and zero-based UTF-8 code-unit runtime registers; one private nested `SourceLocation` module can therefore
  own immutable copied text plus scalar-to-code-unit/line/column/byte tables without exporting or colliding with the
  existing parser `SourceSpan`. Position, Span, DerivedText, and coordinate values need only authority identity,
  source identity, scalar offsets/provenance/policy, and immutable ordered spans. Detached dictionaries are created
  only by `to_json`; the four exact `validate_value` diagnostics retain rule/invocation roles and required fields
  without decoded text, paths, parser state, or host references. Only the frozen core API and one module include
  belong here; projection catalogs, engine routing, public exports, ordinary discovery, and admission remain `.2-.3`.

  Core implementation evidence 2026-08-07: `julia/src/runtime/SourceLocation.jl` defines one private nested module
  included before matching/runtime code. `SourceAuthority` assigns a monotonic thread-safe identity and owns a
  sorted immutable tuple of copied decoded-source records; each record owns only immutable text plus scalar-boundary
  tuples for zero-based UTF-8 code units, one-based scalar line/column, and UTF-8 byte offsets. Position, Span,
  DerivedText, SourceCoordinates, context, and exception structs are immutable; typed values carry no decoded text,
  path, parser state, match object, or authority reference, and derived spans are an immutable tuple. Source slicing,
  coordinate derivation, bounds/source/order validation, and explicit concatenation stay authority-owned. Fresh
  `to_json` dictionaries cannot mutate the values; only the four frozen private `validate_value` codes are emitted.
  The module is not exported and does not add facade methods, projection catalogs, engine state, or helper routes.

  Focused GREEN/nested-RED evidence 2026-08-07: package precompilation and direct private-module load pass. Explicit
  `core` mode passes all 112 assertions over the 3/7/6/3 values, detached records, copied ownership, materialization,
  Unicode coordinates, and four exact diagnostics. Explicit `projection` mode now exits 1 only with
  `UndefVarError: typed_source_projection_rows not defined in LinkedSpecJulia` at the intentionally ordered lookup;
  it never reaches a value failure. Thus `.14.2.4.2` owns the exact next API without any consumer rewrite.

  Complete Julia/baseline evidence 2026-08-07: an uninterrupted `tools/run_julia_local.sh` exits 0 after proving
  the 120,030-byte MCP binding byte-fresh, passing every ordinary package test with the dormant consumer still
  omitted, verifying 19 project-data owners / five locked package trees, passing primary CLI process conformance,
  executing corpus 105/105, and printing exact `[julia-ci] Julia local gate passed`. Alias proof remains 141/141;
  neutral typed source remains 6/8/40; language coverage remains 246/105+1/122; capability remains schema v2 /
  80-0-0 / 24+6. Independent privacy proof shows the private module is not exported, parent projection APIs remain
  absent, and Position/Span/DerivedText field sets contain only identity, offsets, provenance/policy, and spans.
  Repository storage locality passes 1,808 governed files / 421,191 lines / 28 classifier cases.

  Governance/signoff evidence 2026-08-07: the source-unchanged sole-facing mdBook builds 79 files / 14,168 KiB;
  generated HTML keeps the pending-Julia status, migration example, commands, and following guidance in distinct
  paragraph/code blocks rather than one stitched blob. Knowledge Map regenerates at 787 facts / 6,459 question
  keys, all seven doctrines pass, memory architecture accepts activation commit `6d293ac0`, and whitespace is
  clean. The uninterrupted definitive canonical gate preserves capability 80/0/0, typed source 6/8/40 plus Perl
  10 and Rust/Dart 4/4, every composed semantic/MCP admission, six-family project-data containment, repository
  relocation, moved-root Rust, and all four outside-CWD runtime anchors. Primary CLI passes 66/66 in both default
  and POSIX option environments, RAM is 57% against the 88% ceiling, and Phase 0 passes 1,031/1,031 in 689
  wallclock seconds before exact `[ci] local CI gate passed`. Atomic commit 160/300, brief clearing, post-commit
  validation, and clean proof remain before task-tree-first projection routing `.14.2.4.2`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `4d394752` lands with first parent `6d293ac0`; the hook
  regenerates Knowledge Map at 787/6,459, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the generated book is absent, and the exact empty
  managed-run directory recreated by final verification is removed. Julia projection routing `.14.2.4.2` may
  therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4.2`
  Status: `completed` (`779e9757`, 2026-08-07, 161/300, no push)
  Goal: Route all 92 canonical Julia source-boundary helpers plus seven aliases through the immutable authority at
    the compatibility boundary while preserving established public results and live code-unit registers.
  Depends on: `.14.2.4.1`
  Acceptance: Give each `_RuntimeExecutionContext` one copied authority, add fresh detached exact 47/30/11/4
    projection catalogs plus seven aliases, and route source slicing/positions/coordinates, entry/local matches,
    anonymous capture boundaries, rule-local named marks, and cursor controls through typed validation and
    materialization. Preserve strings, numbers, collections, booleans, absence, mutation timing, trace behavior,
    native zero-based UTF-8 code-unit cursor/match/mark/capture/stack state, compiled/generated schemas, and source
    identity. Make the complete dormant consumer pass across native, reconstructed, and generated-plan carriers
    without ordinary/canonical registration or `julia_runtime` promotion; pass full signoff and clean before `.3`.
  Verification: dormant core/projection consumer green with exact 92+7 detached catalogs and unchanged carriers;
    neutral remains 6/8/40 and Julia remains pending
  Commit: `FUTURE-PARITY-BACKLOG.14.2.4.2 - route Julia typed source projections`

  ### `FUTURE-PARITY-BACKLOG.14.2.4.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove immutable core `.14.2.4.1` landed at `4d394752` as 160/300
    with parent `6d293ac0`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent generated
    book, and empty project-data run; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT ROUTE MAP** — Retrieve the neutral catalogs, dormant consumer, Julia authority/helper/
    state/carrier owners, admitted Perl/Rust/Dart projection precedents, Toolbox, and sole-facing pending claims;
    freeze the exact 92+7 typed projection and unchanged-result map before production edits.
  - [x] **AUTHORITY / DETACHED CATALOGS** — Give each execution context one copied source authority and expose fresh
    detached 47/30/11/4 canonical projection rows plus seven compatibility-alias rows without public export,
    ordinary registration, schema change, or mutable retained catalog state.
  - [x] **TYPED HELPER ROUTING** — Route all source slicing, position/coordinate, entry/local match, anonymous
    boundary, rule-local named-mark, and cursor-control helpers through typed construction, validation, and
    materialization while retaining native zero-based UTF-8 code-unit registers and mutation timing.
  - [x] **CARRIER / RESULT EQUALITY** — Make the complete dormant projection consumer pass for native,
    reconstructed, and generated-plan execution; preserve exact strings, numbers, booleans, collections, absence,
    trace behavior, compiled/generated identities, and current helper diagnostics.
  - [x] **NO REGRESSION / LOCKSTEP / CLEAN** — Preserve neutral 6/8/40, Julia pending status, ordinary discovery,
    sole-facing truth, README, semantic/MCP/capability, DSL, and other backends; pass focused/complete Julia,
    storage/corpus/CLI, book/readability, Knowledge, doctrines, and definitive canonical CI; synchronize records,
    commit as 161/300, clear the brief, and prove clean before `.14.2.4.3`.

  Activation evidence 2026-08-07: immutable core `.14.2.4.1` lands atomically at `4d394752` as intended 160/300
  with first parent `6d293ac0` and no push. Hooks regenerate Knowledge Map at 787/6,459, pass all seven doctrines,
  and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the generated book is
  absent, and the exact empty managed-run directory recreated by verification is removed. This task-tree file is
  the sole activation diff before any Julia runtime, dormant consumer, neutral, book, Knowledge, roadmap,
  live-doc, or other change.

  Retrieval/design evidence 2026-08-07: Knowledge Map routes typed-source questions to the rollout and Julia
  compatibility owners. ADR `0056` section 9, neutral JSON 47/30/11/4 plus seven-alias catalogs, the frozen dormant
  consumer, and admitted Perl/Rust/Dart precedents agree on one authority per input and typed conversion only at
  helper boundaries. Julia's `_RuntimeExecutionContext` owns decoded input plus zero-based UTF-8 code-unit cursor,
  entry/local match, anonymous capture, rule-local mark, and cursor-stack registers. Native, loaded/reconstructed,
  generated-plan, and emitted adapters converge on `LinkedSpecRuntimeEngine`; capture-group collections, existence,
  deletion, and maps remain detached compatibility pass-through shapes. Therefore the minimal route adds one
  private authority field, internal conversion helpers/catalog accessors, and no schema, facade, export, ordinary
  discovery, canonical registration, or neutral promotion.

  Projection implementation evidence 2026-08-07: every execution context now snapshots `input` into one private
  `SourceLocation.SourceAuthority`. Exact code-unit boundaries construct scalar Positions and Spans before text,
  length, offset, line/column, input-slice, entry/local-match, anonymous-boundary, named-mark, and cursor-control
  projections; source materialization remains authority-owned. Live cursor, match, capture, mark, and stack storage
  remains the existing zero-based UTF-8 code-unit integers, including established mutation timing and trace data.
  Fresh `typed_source_projection_rows(engine)` and `typed_source_compatibility_aliases(engine)` calls detach exact
  47/30/11/4 plus seven catalogs from immutable tuple constants. Neither function is exported, and no public type,
  helper spelling, schema/identity, compiled/generated plan, or source identity changes.

  Focused/carrier evidence 2026-08-07: explicit dormant core remains 112/112 and projection mode passes 127/127,
  including exact detached catalogs and unchanged native, normalized/reconstructed, and generated-plan results.
  The independent alias consumer remains 141/141 across native, loaded, reconstructed, generated-plan, and freshly
  emitted execution. Complete named marks pass 13/13 and rule-local cursor execution passes 104/104. The neutral
  checker remains 6 complete / 8 pending / 40 mutations, and language coverage remains 246/105+1/122.

  Complete Julia/book evidence 2026-08-07: uninterrupted `tools/run_julia_local.sh` proves the 120,030-byte MCP
  binding byte-fresh, passes every ordinary package suite while the typed consumer remains omitted, verifies 19
  project-data owners / five locked package trees, passes primary CLI and corpus 105/105, and prints exact
  `[julia-ci] Julia local gate passed`. The sole-facing mdBook now distinguishes implemented-but-unadmitted Julia
  projections in capture/source mental model, project status, canonical-CI guidance, and backend handoff. Its
  repository-routed build produces 79 files / 14,176 KiB; generated HTML retains status paragraphs, the executable
  pre-admission command, and following limitations in separate `<p>`/`<pre>` blocks, and the artifact is removed.

  Governance/signoff evidence 2026-08-07: Knowledge Map regenerates at 787 facts / 6,463 question keys; memory
  architecture, whitespace, task metadata, artifact absence, language coverage 246/105+1/122, and all seven
  registered doctrines pass. Definitive canonical CI independently preserves capability 80/0/0 and typed-source
  truth 6/8/40; executes Perl 10 plus Rust/Dart 4/4 typed-source consumers, every byte-fresh MCP binding, and all
  composed semantic/MCP admissions; proves six-family repository containment plus relocated/moved/outside-CWD
  execution; and passes primary CLI 66/66 under default and POSIX option environments. RAM is 64% against the 88%
  threshold. Phase 0 passes 1,031/1,031 in 680 wallclock seconds before exact `[ci] local CI gate passed` and exit
  0. Atomic commit 161/300, ignored-brief clearing, and clean handoff proof remain before task-tree-first admission
  `.14.2.4.3`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `779e9757` lands with first parent `4d394752`; the hook
  regenerates Knowledge Map at 787/6,463, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the generated book is absent, and the exact empty
  managed-run directory recreated by final verification is removed. Julia admission `.14.2.4.3` may therefore
  activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.4.3`
  Status: `completed` (`46612a72`, 2026-08-07, 162/300, no push)
  Goal: Admit the unchanged Julia typed-source consumer into ordinary and canonical discovery and promote only the
    neutral `julia_runtime` rollout row.
  Depends on: `.14.2.4.2`
  Acceptance: Move/include the assertion-identical consumer under `julia/test/runtests.jl`, require its tracked
    path and exact repository-routed command in canonical governance, remove dormant-only mode scaffolding, and
    promote only `julia_runtime` with an independent completed-to-pending mutation. Update the sole-facing book to
    admit Julia's internal values/projections without claiming authored Position/Span values, transactions, schema
    changes, or Lua support. Preserve production implementation, code-unit registers, helper results, carriers,
    semantic/MCP/capability state, DSL, README, and other backends; pass focused/complete/recurring/doctrine/
    canonical signoff, commit, clear the brief, and prove clean before Lua `.14.2.5.0`.
  Verification: ordinary/canonical Julia consumer green; only `julia_runtime` advances; public book and neutral
    counts/mutations match the exact admitted boundary
  Commit: `FUTURE-PARITY-BACKLOG.14.2.4.3 - admit Julia typed source runtime`

  ### `FUTURE-PARITY-BACKLOG.14.2.4.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove projection routing `.14.2.4.2` landed at `779e9757` as
    161/300 with parent `4d394752`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent
    generated book, and empty project-data run; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT ADMISSION MAP** — Retrieve the dormant consumer, Julia ordinary discovery, complete
    driver, neutral rollout artifact/checker, admitted Rust/Dart precedents, canonical command registry, project-
    storage owners, sole-facing pending claims, and Knowledge owners before changing registration.
  - [x] **ORDINARY JULIA ADMISSION** — Remove dormant-only mode scaffolding without changing assertions or
    production behavior, include the exact consumer once in `julia/test/runtests.jl`, and preserve repository-
    routed execution plus project-storage ownership.
  - [x] **CANONICAL / GOVERNANCE ADMISSION** — Require the tracked ordinary consumer path and one exact repository-
    routed Julia command in canonical governance; reject omission, duplication, stale dormancy, or an unwrapped
    command independently.
  - [x] **JULIA-ONLY ROLLOUT PROMOTION** — Promote only `julia_runtime`, add its completed-to-pending mutation, and
    preserve every other row, exact helper/value fixture, schema, semantic/MCP/capability surface, README, DSL,
    production runtime, native code-unit register, result, and carrier.
  - [x] **SOLE-FACING BOOK LOCKSTEP** — Update every affected mdBook surface from implemented-but-unadmitted to
    admitted Julia internal values/projections, retain the absence of public authored Position/Span/transaction
    claims, and keep rendered prose, commands, and limitations in separate readable blocks.
  - [x] **NO REGRESSION / CLEAN HANDOFF** — Pass focused and complete Julia, recurring neutral/language/storage/
    corpus/CLI, book/readability, Knowledge, all doctrines, and definitive canonical CI; synchronize durable/live
    records, commit as 162/300, clear the brief, and prove clean before Lua `.14.2.5.0`.

  Activation evidence 2026-08-07: projection routing `.14.2.4.2` lands atomically at `779e9757` as intended
  161/300 with first parent `4d394752` and no push. Hooks regenerate Knowledge Map at 787/6,463, pass all seven
  doctrines, and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/
  unstaged diffs are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the
  generated book is absent, and the exact empty managed-run directory recreated by verification is removed. This
  task-tree file is the sole activation diff before any Julia consumer/discovery/driver, neutral artifact/checker,
  book, Knowledge, roadmap, live-doc, or other change.

  Retrieval/design evidence 2026-08-07: Knowledge Map routes the admission question to the typed-source rollout
  card and ADR `0056`. The final-path Julia consumer is 483 lines with two top-level implementation testsets and
  two projection/carrier testsets; only one environment mode, one conditional, and stale dormancy comments keep
  the already-green assertions outside ordinary discovery. `julia/test/runtests.jl` is the explicit include owner,
  and the consumer allocates no temporary directory, so the exact 19-owner/five-package storage census does not
  widen. The admitted Dart precedent requires the tracked consumer, exact canonical command, ordinary discovery,
  stale-dormancy rejection, rollout promotion, and one independent complete-to-pending mutation. Julia needs the
  same checker/driver topology with its repository-routed wrapper. The five affected sole-facing book surfaces are
  capture/source mental model, method-reference status, project status, canonical-CI guidance, and backend
  handoff. Retrieval also proves `ROADMAP.md` stopped at the immutable-core boundary while `ROADMAP_V2.md` reached
  projection signoff; this leaf must repair both to the same admitted boundary.

  Admission implementation evidence 2026-08-07: the consumer now has no RED-mode environment read, validation,
  conditional projection block, or dormant wording; its assertion bodies and carrier fixtures are unchanged.
  `julia/test/runtests.jl` includes it exactly once. Canonical CI requires its tracked path and runs one exact
  repository-routed focused command. The independent checker requires both ordinary and canonical registration,
  rejects the three stale dormancy markers, promotes only `julia_runtime`, and adds Julia's completed-to-pending
  mutation. The neutral artifact/checker advance only from 6/8/40 to 7/7/41. Focused Julia passes 127/127, and the
  neutral checker reports the exact 3/7/6/3, 8+8, 6, 4, 92+7+2, 31, and 7/7/41 boundary.

  Book/continuity evidence 2026-08-07: the capture/source mental model, source-boundary helper reference, project
  status, local-CI guide, and backend handoff now report Julia's admitted internal values/projections at 7/7/41
  while retaining absent public authored Position/Span values, transactions, and PUC-Lua/LuaJIT support. The
  repository-routed build produces 79 files / 14,172 KiB. Direct generated-HTML inspection proves changed status
  prose, each Perl/Rust/Dart/Julia command, rollout result, and following limitations remain distinct `<p>` and
  `<pre>` blocks rather than one stitched blob; the generated book is then removed. Both roadmap projections now
  agree on admission after retrieval exposed their core/projection drift. The two Knowledge owners are current,
  and the derived map regenerates and validates at 787 facts / 6,467 question keys.

  Signoff evidence 2026-08-07: focused Julia passes 127/127; complete Julia passes its byte-fresh 120,030-byte MCP
  binding, every ordinary package suite including typed source 127/127 and aliases 141/141, storage 19/5, primary
  CLI, corpus 105/105, and exact Julia marker. Recurring neutral 7/7/41 and language 246/105+1/122 pass. The
  synchronized book passes as recorded above, Knowledge Map is 787/6,467, and all seven doctrines pass. Definitive
  canonical CI independently proves capability 80/0/0 and typed source 7/7/41; executes Perl 10, Rust/Dart 4/4,
  and Julia 127/127; validates byte-fresh MCP bindings and every composed semantic/MCP admission; proves six-family
  repository containment, relocation, moved-root Rust, and four outside-CWD runtime anchors; and passes primary
  CLI 66/66 under default and POSIX environments. RAM is 79% against the 88% threshold. Phase 0 passes
  1,031/1,031 in 716 seconds before exact `[ci] local CI gate passed` and exit 0. Atomic commit 162/300,
  ignored-brief clearing, and clean handoff proof remain before task-tree-first Lua `.14.2.5.0`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `46612a72` lands with first parent `779e9757`; the hook
  regenerates Knowledge Map at 787/6,467, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, memory architecture passes from the landed boundary, the rendered book artifact is absent,
  and the exact empty canonical-run directory is removed. Lua dual-ABI authority audit `.14.2.5.0` may therefore
  activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5`
  Status: `completed` (`5dcfc992`, 2026-08-09, through child `.3`, 168/300, no push)
  Goal: Implement one shared Lua typed source-location algebra and admit it independently on PUC Lua and LuaJIT.
  Children: `.14.2.5.0` dual-ABI authority/prerequisite-split audit; `.14.2.5.0.1` seven-alias shared Lua parity;
    `.14.2.5.0.2` exact dual-ABI typed-source RED; `.14.2.5.1` immutable shared core; `.14.2.5.2` helper/unchanged
    loaded-emitted-plan interpreter routes; `.14.2.5.3` exact dual-ABI admission/promotion.
  Acceptance: Use `source_location.lua`, `matching.lua`, `interpreter.lua`,
    `typed_source_location_contract_test.lua`, and `run.lua`; retain byte registers, convert at the typed boundary,
    prove native/serialized/emitted execution from the same shared source on both ABIs, bind both routes, and
    promote only `lua_dual_abi`.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5.0`
  Status: `completed` (`bdf9956f`, 2026-08-07, 163/300, no push)
  Goal: Map the shared Lua typed source-location authority, byte-based runtime registers, exact 92+7 helper surface,
    PUC-Lua/LuaJIT behavior, carrier convergence, diagnostics, discovery, and canonical boundary before freezing an
    honest dual-ABI RED or splitting any measured prerequisite correction.
  Depends on: `.14.2.4.3`, `.14.2.0`
  Acceptance: Retrieve the typed-source runtime-rollout Knowledge card, ADR `0056` section 9, neutral artifact/
    checker, admitted Perl/Rust/Dart/Julia consumers, Lua runtime/matching/generated/diagnostic Knowledge owners,
    Toolbox, exact shared Lua source/tests, both complete ABI routes, canonical registration, storage owners, and
    every sole-facing typed-source passage before implementation. Use LinkedSpec's own parser/runtime probes first
    and prove decoded-input ownership; byte cursor/mark/match units and exact scalar/line/column/UTF-8 conversion
    seams; all 92 canonical helpers plus seven aliases; cursor, mark, entry/local-match, anonymous-boundary, and
    save-stack state; native, serialized, generated-plan, emitted, and loaded convergence on both ABIs; structured-
    error boundary; ordinary package discovery; and current behavior through repository-routed executable probes.
    If every prerequisite holds, add one shared dormant final-path consumer outside ordinary/canonical discovery
    whose failures name only the absent future Lua typed API. If a premise is false, add no misleading RED or
    production code: record the exact contradiction and split the narrow prerequisite owner first. Preserve current
    production behavior, helper results/mutations, byte registers, schemas/identities, semantic/MCP/capability state,
    DSL/facade, neutral 7/7/41, root README, sole-facing book truth, and other backends; pass exact audit/complete-
    dual-ABI/recurring/book/Knowledge/doctrine/canonical signoff, commit, clear the brief, and prove clean before
    any correction or immutable core leaf.
  Verification: exact PUC-Lua and LuaJIT probes plus source/runtime topology evidence establish either one honest
    shared RED or one exact prerequisite split without production or public behavior change
  Commit: `FUTURE-PARITY-BACKLOG.14.2.5.0 - map Lua typed source boundary`

  ### `FUTURE-PARITY-BACKLOG.14.2.5.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove Julia admission `.14.2.4.3` landed at `46612a72` as 162/300
    with parent `779e9757`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent generated
    book, and empty project-data run; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT AUTHORITY MAP** — Follow the Knowledge Map and ADR before code archaeology; retrieve
    shared Lua runtime, matching, interpreter, loader/emitter, diagnostics, tests, storage, CI, and book owners.
  - [x] **DUAL-ABI EXECUTABLE AUDIT** — Measure the decoded-source owner, byte/scalar boundaries, exact 92+7 known/
    canonical/executable helpers, register mutations, carrier convergence, diagnostics, and discovery on both PUC
    Lua and LuaJIT through repository-routed commands.
  - [x] **HONEST RED OR PREREQUISITE SPLIT** — Freeze one shared dormant consumer only if every current premise is
    sound; otherwise preserve the failing evidence and split the smallest prerequisite without implementation.
  - [x] **NO REGRESSION / CLEAN HANDOFF** — Preserve production/public/neutral 7/7/41 and pass complete dual-ABI,
    recurring contracts, sole-facing book truth/readability, Knowledge, all doctrines, definitive canonical CI,
    atomic commit 163/300, brief clearing, and clean proof before any next leaf.

  Activation evidence 2026-08-07: Julia admission `.14.2.4.3` lands atomically at `46612a72` as intended 162/300
  with first parent `779e9757` and no push. Hooks regenerate Knowledge Map at 787/6,467, pass all seven doctrines,
  and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the generated book is
  absent, and the exact empty canonical-run directory is removed. This task-tree file is the sole activation diff
  before any Lua source/test, neutral artifact/checker, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval/authority evidence 2026-08-07: the Knowledge Map routes typed-source rollout to
  `typed-source-location-runtime-rollout-plan` and the shared Lua boundary to the matching-state, cursor/capture,
  generated-source, native-loading, and structured-diagnostic cards. ADR `0056` section 9, the neutral artifact and
  checker, admitted Perl/Rust/Dart/Julia consumers, Toolbox, exact shared source/tests/drivers, storage and
  canonical registration, and all sole-facing typed-source passages agree on the intended boundary. One validated
  decoded Lua string is stored in the invocation context and reused by `RuntimeMatchRegisters` and
  `RuntimeRegexMatch`. Cursor, entry/local-match, anonymous capture, named-mark, and save-stack positions remain
  zero-based UTF-8 byte offsets. `matching.lua` rejects non-boundaries and converts bytes to Unicode-scalar offsets
  or one-based line/column only at public helper/result seams. Native compilation, effective-SpecFile JSON
  reconstruction, loaded specs, generated-v2 plans, and emitted modules all compile into and re-enter the same
  `LinkedSpecRuntimeEngine` from one Lua-5.1-compatible source graph on PUC Lua and LuaJIT. Failures leave through
  `RuntimeInterpreterException.diagnostic`; ordinary discovery is the explicit shared-test command sequence in
  `tools/run_lua_local.sh`. No `source_location.lua`, typed-source consumer, immutable authority/value core, typed
  projection catalog, canonical Lua typed-source command, or rollout promotion exists. The sole-facing book
  accurately leaves both Lua ABIs pending at neutral 7/7/41.

  Dual-ABI contradiction evidence 2026-08-07: one identical repository-routed probe reads the neutral artifact on
  PUC Lua and LuaJIT and proves all 92 canonical rows in exact 47/30/11/4 families are unique, known, canonically
  stable, and contract-resolvable. All seven compatibility rows are absent from the known-name/canonicalization
  seam: `capture_from_rule_start`, `capture_len_from_rule_start`, `capture_rest_length`, `capture_slice_here`,
  `capture_slice_length`, `entry_named_map`, and `match_named_map` remain their authored names, resolve to
  `unknown_helper`, and compiled execution raises `RuntimeInterpreterException` with stage `runtime_execution`,
  owner `lua_runtime`, rule `Top`, and exact `unsupported runtime helper '<name>'` detail on both ABIs. Lua source
  and tests contain no authored alias occurrence; the private implementation function named `match_named_map` is
  only the canonical `entry_map`/`match_map` projector and does not admit the authored alias. The unchanged complete
  shared suite passes 177/177 per ABI, including Unicode matches/conversions, immutable register updates, exact
  input/cursor, anonymous capture, named marks/spans, serialized reconstruction, loaded specs, generated plans,
  emitted modules, structured failures, and the all-call runtime-owner census. Therefore this audit adds no
  misleading typed RED and no production/test behavior. Shared alias parity `.14.2.5.0.1` must land before exact
  dormant dual-ABI RED `.14.2.5.0.2`.

  Book/Knowledge/signoff evidence 2026-08-07: the source-unchanged sole-facing mdBook already says PUC Lua and
  LuaJIT typed-source values/projections and Lua alias rollout are pending. Its repository-routed build produces
  79 files / 14,172 KiB; direct generated-HTML inspection confirms Lua status, alias note, commands, and following
  limitations remain separate `<p>`/`<pre>` blocks rather than a stitched prose blob, and the artifact is removed.
  The new exact alias-gap fact plus updated rollout card regenerate Knowledge Map at 788 facts / 6,487 question
  keys. Complete `tools/run_lua_local.sh` proves the byte-fresh 83,166-byte MCP binding, all ordinary/focused suites
  at 177/177 independently on PUC Lua and LuaJIT, primary CLI 66/66 in default and POSIX environments, corpus
  105/105, storage 17 owners / three dual-ABI modules, and exact Lua pass marker. Neutral 7/7/41 and language
  coverage 246/105+1/122 remain unchanged; all seven doctrines pass.

  Definitive canonical CI independently preserves capability 80/0/0 and typed source 7/7/41; executes every
  admitted typed-source, byte-fresh MCP, and composed semantic/MCP consumer; proves six-family repository
  containment plus relocated/moved/outside-CWD execution; and passes primary CLI 66/66 under default and POSIX
  environments. RAM is 45% against the 88% threshold. Phase 0 passes 1,031/1,031 in 672 wallclock seconds before
  exact `[ci] local CI gate passed` and exit 0. No production, test, neutral artifact/checker, schema, semantic/MCP/
  capability, DSL, root README, sole-facing book source, or other-backend behavior changed. Atomic commit 163/300,
  ignored-brief clearing, and clean proof remain before task-tree-first alias parity `.14.2.5.0.1`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `bdf9956f` lands with first parent `46612a72`; the hook
  regenerates Knowledge Map at 788/6,487, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the rendered book is absent, and the exact empty
  canonical-run directory is removed. Seven-alias Lua parity `.14.2.5.0.1` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5.0.1`
  Status: `completed` (`0105bcc1`, 2026-08-07, 164/300, no push)
  Goal: Add exactly the seven neutral source-boundary compatibility spellings at Lua's existing shared known-name
    and canonicalization seams so PUC Lua and LuaJIT execute every alias through its preferred helper branch without
    widening the common 246-name inventory or admitting typed source values.
  Depends on: `.14.2.5.0`
  Acceptance: Retrieve the Lua alias-gap Knowledge owner, neutral alias rows/checker, exact Dart/Julia alias
    precedents, `action_call_names.lua`, `action_contracts.lua`, `interpreter.lua`, generated-v2 carriers, complete
    mark/cursor tests, language coverage, both ABI drivers, canonical registration, and sole-facing book before
    implementation. Add exactly one separate seven-name known-alias inventory and one exact canonical-name map;
    keep `CURRENT_CALL_NAMES`, `current_names()`, and `count()` at 246, and add no alias-specific interpreter branch.
    Prove exact contract resolution, unrelated-helper diagnostics, Unicode text/scalar widths, anonymous-boundary
    mutation and reversed-span absence, named-map shapes, and alias/canonical equality across native, loaded,
    reconstructed, generated-plan, and independently loaded emitted source on both ABIs. Extend independent
    language coverage to derive and bind Lua's seven pairs to the neutral contract. Preserve canonical helper
    behavior, byte registers, schemas/identities, neutral 7/7/41, Lua typed-source pending state, root README, other
    backends, and public typed/transaction claims. Pass focused/complete dual-ABI, storage/corpus/CLI, language/
    neutral, book/readability, Knowledge, doctrine, and definitive canonical gates; commit, clear the brief, and
    prove clean before `.14.2.5.0.2`.
  Verification: exact seven-alias RED/GREEN consumer on PUC Lua and LuaJIT; 92+7 inventory and carrier equality;
    complete Lua/canonical no-drift; unchanged neutral 7/7/41 and public book truth
  Commit: `FUTURE-PARITY-BACKLOG.14.2.5.0.1 - add Lua source aliases`

  ### `FUTURE-PARITY-BACKLOG.14.2.5.0.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove audit `.14.2.5.0` landed at `bdf9956f` as 163/300 with parent
    `46612a72`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent rendered book, and no
    managed-run residue; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT SEAM MAP** — Follow the Lua alias-gap Knowledge card and retrieve the neutral rows,
    Dart/Julia precedents, known/canonical name owners, interpreter branches, carrier routes, discovery, language
    coverage, complete dual-ABI gate, and sole-facing book before code.
  - [x] **EXECUTABLE SEVEN-ALIAS RED** — Lock 0/7 known/canonical and exact unsupported-helper behavior on both
    ABIs before production changes, including unrelated unknown-helper control and common inventory count 246.
  - [x] **SHARED NAME/CANONICAL REPAIR** — Add exactly seven compatibility names and their preferred targets at
    the shared recognition/canonicalization seams, with no alias-specific runtime branch or current-name widening.
  - [x] **DUAL-ABI CARRIER PARITY** — Prove alias/canonical equality, Unicode scalar widths, capture-boundary
    mutation, reversed-span absence, named maps, and native/loaded/reconstructed/generated/emitted execution on
    PUC Lua and LuaJIT.
  - [x] **COVERAGE / SOLE-FACING LOCKSTEP** — Bind Lua's seven pairs independently to neutral language coverage;
    keep typed source 7/7/41 and the book's pending-Lua/public-value claims exact with readable rendered blocks.
  - [x] **NO REGRESSION / CLEAN HANDOFF** — Pass focused/complete Lua, storage/corpus/CLI, language/neutral, book,
    Knowledge, all doctrines, definitive canonical CI, atomic commit 164/300, brief clearing, and clean proof before
    dormant RED `.14.2.5.0.2`.

  Activation evidence 2026-08-07: audit `.14.2.5.0` lands atomically at `bdf9956f` as intended 163/300 with first
  parent `46612a72` and no push. Hooks regenerate Knowledge Map at 788/6,487, pass all seven doctrines, and validate
  the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs are empty,
  `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the rendered book is absent, and
  the exact empty canonical-run directory is removed. This task-tree file is the sole activation diff before any
  Lua source/test, neutral checker, language coverage, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval/RED evidence 2026-08-07: the Knowledge Map routes the exact gap to
  `lua-typed-source-compatibility-alias-gap` and the rollout boundary to
  `typed-source-location-runtime-rollout-plan`. The neutral rows/checker, Dart/Julia precedents, shared Lua
  known/canonical owners, interpreter branches, five carrier routes, discovery/storage/canonical drivers, and all
  five sole-facing book passages were retrieved before production edits. One final-path consumer first passed all
  92 canonical-name assertions on both ABIs while failing exactly 62 of 572 assertions: only the seven aliases were
  unknown/noncanonical, their downstream carriers stopped at the existing unsupported-helper diagnostic, the
  unrelated-helper control remained exact, and the common current inventory remained 246.

  Implementation/focused evidence 2026-08-07: `action_call_names.lua` now owns a separate exact seven-name
  compatibility set and `action_contracts.lua` owns the exact preferred-name map. Known-name recognition and
  canonical resolution consume those structures before existing helper resolution; `CURRENT_CALL_NAMES`,
  `current_names()`, and `count()` remain 246, and the interpreter has no alias-specific branch. The ordinary
  consumer passes 638/638 on PUC Lua and 638/638 on LuaJIT across 92 canonical names, seven aliases, authored arity,
  Unicode text and reversed spans, capture-boundary mutation, named maps, unrelated diagnostics, and native,
  reconstructed, loaded, generated-plan, plus independently loaded emitted carriers. Independent language
  coverage derives Lua's seven pairs and binds them to neutral while remaining 246/105+1/122; neutral typed source
  stays 7/7/41. Syntax checks, both complete 177-test package runs, and storage 18/3 pass.

  Complete-Lua/book evidence 2026-08-07: `tools/run_lua_local.sh` proves the byte-fresh 83,166-byte MCP binding,
  the 638-assertion alias consumer and all 177 ordinary tests independently on both ABIs, primary CLI 66/66 in
  default and POSIX environments, all 105 corpus cases, 18 repository-local temporary owners, three dual-ABI
  native modules, and exact `[lua-ci] Lua local gate passed`. The sole-facing book is updated across helper
  reference, capture/source-location, project status, local CI, and backend handoff: Lua alias behavior is current
  while internal typed values/admission and public typed/transaction surfaces stay future. Its repository-routed
  build produces 79 files / 14,180 KiB; direct HTML inspection confirms separate paragraphs, code blocks, and
  following limitations on all five pages, and the generated artifact is removed. Knowledge Map regenerates at
  788 facts / 6,489 question keys. Definitive doctrine/canonical signoff remains before the atomic commit.

  Definitive canonical evidence 2026-08-07: the first staged attempt passed all seven doctrines, tracked-input,
  syntax, and memory-pointer proof, then correctly rejected the refreshed task-index row for dropping the exact
  governed historical markers `exclusion public closeout .24.2` and `Capability exclusion freshness is public-
  closed under FUTURE-PARITY-BACKLOG.24`. Restoring both still-true projections made focused capability proof pass
  schema v2 / 80-0-0 / two exclusions / 24 governance mutations / 12 projections / six public mutations. The
  definitive rerun preserves typed source 7/7/41; executes every admitted typed-source and composed semantic/MCP
  consumer; proves six-family repository containment plus relocated/moved/outside-CWD execution; and passes primary
  CLI 66/66 under default and POSIX environments. RAM is 59% against the 88% threshold. Phase 0 passes
  1,031/1,031 in 659 wallclock seconds before exact `[ci] local CI gate passed` and exit 0. Knowledge 788/6,489,
  all seven doctrines, staged/unstaged whitespace, and memory/task metadata pass. The leaf is signoff-complete for
  atomic commit 164/300; brief clearing and clean proof remain before `.14.2.5.0.2`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `0105bcc1` lands with first parent `bdf9956f`; the hook
  regenerates Knowledge Map at 788/6,489, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the rendered book is absent, and the exact empty
  canonical-run directory is removed. Dormant dual-ABI typed-source RED `.14.2.5.0.2` may therefore activate
  task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5.0.2`
  Status: `completed` (`1136b1f2`, 2026-08-07, 165/300, no push)
  Goal: Freeze one shared dormant Lua consumer for the neutral immutable source values, four owned diagnostics,
    exact 92 canonical projections plus seven now-callable aliases, and unchanged runtime carriers on both ABIs
    before production core implementation.
  Depends on: `.14.2.5.0.1`
  Acceptance: Start from clean alias parity. Add one test-local consumer outside `tools/run_lua_local.sh` ordinary
    discovery and canonical registration. Its core mode must fail on both PUC Lua and LuaJIT only for the absent
    future `linkedspec.source_location` API; projection mode must remain independently nested behind core and
    require exact 92+7 catalogs plus native/reconstructed/generated-plan behavior. Lock 3/7/6/3 value fixtures,
    four private errors, detached values, native byte/scalar conversion, rule-local marks, anonymous boundary,
    cursor stack, and unchanged external results without production, neutral, schema, or public-book admission
    change. Pass ordinary complete dual-ABI Lua with the dormant file excluded, exact explicit RED diagnostics,
    storage/corpus/CLI, language/neutral, book/readability, Knowledge, doctrine, and definitive canonical gates;
    commit, clear the brief, and prove clean before `.14.2.5.1`.
  Verification: ordinary Lua remains green on both ABIs; explicit core/projection modes fail only on owned absent
    future APIs; neutral remains 7/7/41 and `lua_dual_abi` remains pending
  Commit: `FUTURE-PARITY-BACKLOG.14.2.5.0.2 - freeze Lua typed source RED`

  ### `FUTURE-PARITY-BACKLOG.14.2.5.0.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove alias parity `.14.2.5.0.1` landed at `0105bcc1` as 164/300
    with parent `bdf9956f`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent rendered
    book, and no managed-run residue; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / FINAL-PATH DESIGN** — Follow the Lua alias/typed-source Knowledge owners and retrieve ADR
    `0056`, the neutral 3/7/6/3 value and four-error contract, admitted backend RED precedents, shared Lua
    authority/carriers, discovery/storage/canonical owners, and all sole-facing pending-Lua passages before code.
  - [x] **DORMANT CORE RED** — Add one tracked final-path consumer outside ordinary and canonical discovery whose
    explicit core mode parses fully on PUC Lua and LuaJIT and fails only for absent `linkedspec.source_location`.
  - [x] **NESTED PROJECTION RED** — Keep projection lookup strictly after the core namespace and freeze exact
    detached 92+7 catalogs plus native/reconstructed/generated-plan carrier expectations without adding runtime
    implementation or admission.
  - [x] **NO CURRENT-BEHAVIOR MOVEMENT** — Preserve ordinary dual-ABI Lua, all seven aliases, byte registers,
    external helper results/mutations, schemas/identities, neutral 7/7/41, `lua_dual_abi` pending, root README,
    other backends, and the book's public typed/transaction claims.
  - [x] **HANDOFF TREE COMPLETENESS** — Materialize the already parent-declared `.14.2.5.1-.3` core, projection,
    and admission records with exact dependencies and acceptance boundaries before `.0.2` hands off; those leaf
    records have never existed in Git and must not be left implicit at the next-session frontier.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass explicit exact RED modes, complete Lua with the consumer
    excluded, storage/corpus/CLI, language/neutral, sole-facing book readability, Knowledge, all doctrines,
    definitive canonical CI, atomic commit 165/300, brief clearing, and clean proof before immutable core `.1`.

  Activation evidence 2026-08-07: alias parity `.14.2.5.0.1` lands atomically at `0105bcc1` as intended 164/300
  with first parent `bdf9956f` and no push. Hooks regenerate Knowledge Map at 788/6,489, pass all seven doctrines,
  and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the rendered book is
  absent, and the exact empty canonical-run directory is removed. This task-tree file is the sole activation diff
  before any Lua source/test, neutral checker, storage/canonical driver, book, Knowledge, roadmap, live-doc, or
  other change.

  Retrieval/final-path evidence 2026-08-07: Knowledge Map routing led to ADR `0056`, the exact neutral contract
  and 7/7/41 rollout cards, the Lua alias/runtime-register/carrier authorities, and the final dormant Julia RED
  at commit `6d293ac0` before source reinspection. The Lua consumer will use explicit `core`/`projection` modes,
  require private `linkedspec.source_location` before any projection lookup, consume the neutral 3/7/6/3 fixtures
  and four private errors, and keep exact 92+7 catalogs plus native/reconstructed/generated-plan execution nested
  under projection mode. `tools/run_lua_local.sh` is an explicit test list and will omit the dormant consumer;
  `tools/run_ci_local.sh` has no Lua typed-source registration; the consumer needs no temporary storage owner.
  All five sole-facing pending-Lua passages were read and remain exact because this RED changes no user-visible
  behavior. History search and blame also prove parent `.14.2.5` has named `.1-.3` since planning commit
  `5a294f39` (with the detailed split refined at `bdf9956f`), but no explicit child record has ever existed; this
  slice owns materializing those already-declared handoff boundaries before activating `.1`.

  Consumer/RED evidence 2026-08-07: `lua/test/typed_source_location_contract_test.lua` syntax-loads independently
  on PUC Lua and LuaJIT. Explicit `core` and `projection` runs through `tools/run_lua_project_data.sh` each exit 1
  with the same sole stable line `Lua typed source RED: missing linkedspec.source_location`; all other require
  failures propagate. The require precedes exact projection-catalog lookup, which will next expose missing
  `typed_source_projection_rows` and then `typed_source_compatibility_aliases`. The dormant body consumes every
  neutral 3/7/6/3 value fixture, all four private errors and privacy fields, detached position and catalog records,
  Unicode-scalar/UTF-8-byte coordinates, exact unique 47/30/11/4 helper families and seven aliases, the complete
  named-mark fixture, anonymous-boundary mutation, cursor save/rewind/restore, and native/reconstructed/generated-
  plan carriers. The existing alias consumer remains green at 638/638 per ABI; neutral remains 7/7/41 and language
  coverage remains 246/105+1/122. The test creates no temporary directory, so storage-owner inventory need not
  widen. A new Knowledge fact makes this boundary retrievable.

  Complete/book/signoff evidence 2026-08-07: the full dual-ABI Lua gate preserves its byte-fresh 83,166-byte MCP
  binding, alias 638/638 and ordinary package 177/177 per ABI, primary CLI 66/66 under default and POSIX
  environments, corpus 105/105, storage 18 owners / three dual-ABI modules, and exact local-gate marker. The
  source-unchanged sole-facing book builds 79 files / 14,180 KiB; direct generated-HTML inspection confirms its
  pending-Lua status, alias guidance, rollout, commands, and following limitations remain separate paragraph,
  preformatted, and table blocks, then the artifact is removed. Knowledge Map is 789 facts / 6,504 question keys
  and all seven doctrines pass. The first canonical attempt reached project-data process proof before the outer
  execution sandbox denied nested macOS `sandbox-exec`; the exact focused containment gate passes with its required
  permission. One uninterrupted approved canonical rerun then preserves capability schema v2 at 80/0/0 and typed
  source 7/7/41; executes admitted typed-source plus every composed semantic/MCP consumer; proves six-family
  containment and relocated/moved/outside-CWD execution; passes primary CLI 66/66 twice; reports RAM 60% against
  88%; and passes Phase 0 1,031/1,031 in 667 wallclock seconds before exact `[ci] local CI gate passed` and exit 0.
  Production/runtime, ordinary discovery, aliases, registers, results, neutral/public truth, root README, and book
  source are unchanged. The leaf is signoff-complete for atomic commit 165/300; brief clearing and clean proof
  remain before `.14.2.5.1`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `1136b1f2` lands with first parent `0105bcc1`; the hook
  regenerates Knowledge Map at 789/6,504, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the rendered book is absent, and the exact empty
  managed-run directory is removed. Immutable shared Lua source-location core `.14.2.5.1` may therefore activate
  task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5.1`
  Status: `completed` (`e6a75830`, 2026-08-07, 166/300, no push)
  Goal: Implement the one shared immutable Lua decoded-source authority and typed Position, Span, and DerivedText
    value core required by the dormant consumer, identically on PUC Lua and LuaJIT, without routing helpers yet.
  Depends on: `.14.2.5.0.2`
  Acceptance: Add private `lua/src/linkedspec/source_location.lua` with one copied decoded-source authority,
    monotonic opaque authority identity, Unicode-scalar-to-UTF-8-byte/line/column boundary tables, immutable values
    carrying no text/path/parser/host reference, detached JSON records, same-source direct spans, ordered
    `concatenate_in_order` provenance, and only the four neutral value diagnostics. Make explicit `core` mode pass
    all exact 3/7/6/3 fixtures and errors on both ABIs while ordinary discovery remains unchanged. Projection mode
    must advance to the sole first missing `linkedspec.typed_source_projection_rows` API. Add no runtime-context
    authority, helper route, public facade/DSL/schema, neutral promotion, or book admission claim.
  Verification: core-mode dual-ABI GREEN; projection-mode exact next RED; complete ordinary dual-ABI no-drift;
    neutral remains 7/7/41 and `lua_dual_abi` pending
  Commit: `FUTURE-PARITY-BACKLOG.14.2.5.1 - add Lua typed source core`

  ### `FUTURE-PARITY-BACKLOG.14.2.5.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove dormant RED `.14.2.5.0.2` landed at `1136b1f2` as 165/300
    with parent `0105bcc1`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent rendered
    book, and no managed-run residue; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT VALUE SEAM** — Follow the Lua dormant-RED, neutral contract, runtime state, storage,
    and admitted Rust/Dart/Julia core Knowledge owners; inspect the dormant core assertions and shared Lua package
    conventions before production edits.
  - [x] **ONE COPIED SOURCE AUTHORITY** — Add one private Lua-5.1-compatible authority that snapshots decoded
    sources, assigns opaque monotonic identities, and owns scalar-to-UTF-8-byte plus one-based line/column tables.
  - [x] **IMMUTABLE DETACHED VALUES** — Implement Position, same-source ordered Span, and concatenate-in-order
    DerivedText values without decoded text or host/runtime references; return fresh detached JSON records.
  - [x] **FOUR PRIVATE DIAGNOSTICS** — Emit only the neutral source-mismatch, position-out-of-range, reversed-span,
    and invalid-derived-provenance diagnostics with exact context and no private source/path/parser/match fields.
  - [x] **CORE GREEN / PROJECTION NEXT RED** — Pass all exact 3/7/6/3 core fixtures on PUC Lua and LuaJIT while
    projection mode advances solely to missing `linkedspec.typed_source_projection_rows`.
  - [x] **NO ROUTING OR ADMISSION** — Preserve ordinary discovery, current UTF-8-byte registers, helper results,
    92+7 routing, schemas, neutral 7/7/41, `lua_dual_abi` pending, root README, and sole-facing admission claims.
  - [x] **REPAIR STALE STORAGE FACT** — Correct the general Lua project-data Knowledge card from its pre-alias
    17-owner prose to the exact current 18-owner manifest established by commit `0105bcc1` and the executable
    storage oracle; add no allocator or storage behavior.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused dual-ABI modes, complete Lua, storage/corpus/CLI,
    language/neutral, sole-facing book, Knowledge, all doctrines, definitive canonical CI, atomic commit 166/300,
    brief clearing, and clean proof before projection routing `.14.2.5.2`.

  Activation evidence 2026-08-07: dormant RED `.14.2.5.0.2` lands atomically at `1136b1f2` as intended 165/300
  with first parent `0105bcc1` and no push. Hooks regenerate Knowledge Map at 789/6,504, pass all seven doctrines,
  and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the rendered book is
  absent, and the exact empty managed-run directory is removed. This task-tree file is the sole activation diff
  before any Lua source, test, neutral checker, storage/canonical driver, book, Knowledge, roadmap, live-doc, or
  other change.

  Retrieval evidence 2026-08-07: Knowledge Map routing led to the dormant Lua RED, neutral 3/7/6/3 and four-error
  contract, complete runtime rollout plan, shared UTF-8-byte matching state, Lua project-data storage owner, and
  admitted Rust/Dart/Julia immutable-core precedents before production edits. The final consumer and Lua package
  conventions establish a private direct module API: one opaque-token store can keep all decoded text, authority
  identities, value fields, and diagnostics out of public tables while fresh `json.harray`/`json.array` records
  provide detached projections. Validated UTF-8 first-byte widths are sufficient to precompute zero-based byte
  boundaries and one-based scalar line/column tables identically on Lua 5.1 and LuaJIT. Retrieval also found one
  stale Knowledge projection: `lua-project-data-ssd-storage` still says 17 owners, while commit `0105bcc1` added
  the alias consumer to the executable manifest and `tools/test_lua_project_data_storage.sh` now proves exactly
  18. This leaf owns correcting that relevant fact without adding an allocator or changing storage behavior.

  Core implementation evidence 2026-08-07: new private `lua/src/linkedspec/source_location.lua` is shared unchanged
  by PUC Lua and LuaJIT and is deliberately absent from `lua/src/linkedspec/init.lua`. One `SourceAuthority` snapshots
  every caller string, validates UTF-8, assigns a monotonic exact-integer identity, and precomputes zero-based byte
  plus one-based scalar line/column data at every Unicode boundary. Empty opaque tokens use protected metatables and
  module-private weak-key state, so Position, Span, DerivedText, context, and exception values expose neither their
  records nor decoded text, paths, parser/match objects, runtime state, or authority objects. Fresh hybrid/array JSON
  records are detached. Direct spans require one source and ordered half-open offsets; derived text preserves only
  explicit `concatenate_in_order` spans. Authority-owned coordinate and materialization operations emit only the
  frozen source-mismatch, position-out-of-range, reversed-span, and invalid-derived-provenance records.

  Focused boundary evidence 2026-08-07: both production and dormant-consumer files syntax-load under PUC Lua and
  LuaJIT. The first implementation run exposed one exact contract-shape mismatch: the frozen consumer directly
  encodes `coordinates`, so the private API returns a fresh detached hybrid record rather than an opaque coordinate
  token. After that correction, explicit `core` mode passes all 133 assertions independently on both ABIs across
  the 3/7/6/3 fixtures, copied authority ownership, detachment, Unicode coordinates, materialization, and four exact
  diagnostics. Explicit `projection` mode exits 1 on each ABI solely with
  `Lua typed source RED: missing linkedspec.typed_source_projection_rows` at its intentionally ordered lookup.
  Independent dual-ABI opacity probes also prove tokens enumerate no fields, expose only protected metatable labels,
  reject normal field assignment, and remain unchanged after a detached JSON record is mutated.

  Ordinary/no-drift evidence 2026-08-07: complete `tools/run_lua_local.sh` exits 0 with byte-fresh 83,166-byte MCP
  binding, package 177/177 and compatibility aliases 638/638 independently on both ABIs, primary CLI 66/66 under
  default and POSIX environments, corpus 105/105, and exact `[lua-ci] Lua local gate passed`. Its integrated storage
  oracle proves the executable current census is 18 owners (17 Lua tests plus the complete runner) and three native
  modules per ABI. The relevant Knowledge card now records commit `0105bcc1` as the 17-to-18 transition instead of
  retaining its stale pre-alias prose; no allocation owner or storage code changes. Independent neutral proof stays
  7 complete / 7 pending / 41 mutations and language coverage stays 246 current names / 105 corpus plus one named-
  mark fixture / 122 independently covered public Perl contracts. Public init, interpreter/helper routes, byte
  registers, ordinary/canonical discovery, schemas, root README, and `lua_dual_abi` remain unchanged. Four book
  pages move only their project-status wording: private core implemented, projection routing/admission still pending.

  Book/Knowledge/governance evidence 2026-08-07: repository-routed mdBook builds 79 files / 14,180 KiB. Direct
  generated-HTML inspection proves the new private-core status, pending-routing limitation, and following material
  remain distinct paragraph/code blocks rather than one stitched blob; the exact generated artifact is removed.
  The dormant-core, runtime-rollout, and storage Knowledge owners now record the implementation and already-
  executable 18-owner storage truth; Knowledge Map regenerates and validates at 789 facts / 6,504 question keys.
  Memory architecture accepts activation commit `1136b1f2`, whitespace and task-tree metadata pass, and all seven
  enforced doctrines pass including root-relative paths, same-volume project data, and README stability.

  Definitive canonical evidence 2026-08-07: one uninterrupted approved `tools/run_ci_local.sh` exits 0 after
  preserving capability schema v2 at 80/0/0 and neutral typed source at 7/7/41; executing Perl 10, Rust 4/4, Dart
  4/4, and Julia 127/127 admitted typed-source consumers plus every byte-fresh MCP and composed semantic admission;
  proving six-family project-data containment, relocated execution, moved-root Rust, and four outside-CWD anchors;
  passing primary CLI 66/66 in default and POSIX environments; and reporting RAM 65% against the 88% threshold.
  Phase 0 passes 1,031/1,031 in 672 wallclock seconds before exact `[ci] local CI gate passed`. The leaf is signoff-
  complete for atomic commit 166/300; brief clearing, post-commit validation, and clean proof remain before task-
  tree-first projection routing `.14.2.5.2`; no push.

  Commit/handoff evidence 2026-08-07: atomic commit `e6a75830` lands with first parent `1136b1f2`; the hook
  regenerates Knowledge Map at 789/6,504, passes all seven doctrines, and validates the memory activation pointer
  against both pre-commit HEAD and post-commit `HEAD^1`. Status plus staged/unstaged diffs are empty, the ignored
  brief is zero bytes, post-commit memory architecture passes, the rendered book is absent, and the exact empty
  canonical-run directory is removed after its 0-KiB/no-content proof. Typed projection routing `.14.2.5.2` may
  therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5.2`
  Status: `completed` (`10e99190`, 2026-08-07, 167/300, no push)
  Goal: Route every shared Lua source-boundary helper and compatibility alias through the immutable typed boundary
    while preserving all UTF-8-byte registers, public results, and mutation timing on both ABIs.
  Depends on: `.14.2.5.1`
  Acceptance: Give each runtime execution input one source authority and route the exact 47/30/11/4 projection
    families plus seven aliases through typed construction, validation, coordinate conversion, slicing,
    materialization, anonymous-boundary state, rule-local named marks, capture boundaries, and cursor controls.
    Export fresh detached `typed_source_projection_rows(engine)` and `typed_source_compatibility_aliases(engine)`
    catalogs from the private Lua package seam. Keep cursor, entry/local match, anonymous boundary, named marks,
    and cursor stack as zero-based UTF-8 byte offsets; preserve all existing strings, numbers, arrays, maps,
    booleans, nulls, statement results, and mutation timing. Make the dormant projection consumer pass native,
    reconstructed, and generated-plan behavior on both ABIs; retain the dedicated alias consumer's loaded and
    independently emitted proof. Leave ordinary/canonical registration and neutral promotion exclusively `.3`.
  Verification: explicit core/projection dual-ABI GREEN; exact 92+7 catalogs; alias loaded/emitted no-drift;
    complete Lua/corpus/CLI/storage; neutral remains 7/7/41 and `lua_dual_abi` pending
  Commit: `FUTURE-PARITY-BACKLOG.14.2.5.2 - route Lua typed source projections`
  Commit: `10e99190`

  ### `FUTURE-PARITY-BACKLOG.14.2.5.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove immutable core `.14.2.5.1` landed at `e6a75830` as 166/300
    with parent `1136b1f2`, empty status/diffs, zero-byte brief, valid post-commit memory pointer, absent rendered
    book, and no managed-run residue; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / EXACT ROUTE MAP** — Follow the rollout, dormant-consumer, runtime-state, alias, carrier, and
    admitted Rust/Dart/Julia projection Knowledge owners; inspect the exact 47/30/11/4 helper classifications,
    seven aliases, current Lua execution context, and frozen projection assertions before production edits.
  - [x] **ONE INPUT AUTHORITY** — Give each runtime execution input exactly one copied `SourceAuthority`; ensure
    reconstructed, generated-plan, loaded, and emitted routes converge without serializing or duplicating it.
  - [x] **EXACT DETACHED CATALOGS** — Export fresh exact 92-row projection and seven-row compatibility catalogs at
    the private package seam with unique names, stable family/role/kind/provenance metadata, and no mutable aliasing.
  - [x] **TYPED HELPER ROUTING** — Route all position/span/text/length, entry/local-match, anonymous-boundary,
    rule-local named-mark, and cursor-control operations through typed construction, validation, coordinates, and
    materialization while retaining capture-group collection/existence/delete compatibility shapes.
  - [x] **REGISTER / RESULT / CARRIER NO-DRIFT** — Keep zero-based UTF-8-byte cursor, match, boundary, mark, and
    stack registers plus all strings, numbers, arrays, maps, booleans, nulls, results, and mutation timing exact on
    PUC Lua and LuaJIT across native, reconstructed, generated-plan, loaded, and independently emitted execution.
  - [x] **CORE + PROJECTION GREEN / ADMISSION PENDING** — Preserve dual-ABI core 133/133 and make the frozen
    projection body pass without consumer rewrite; leave ordinary/canonical discovery, neutral 7/7/41, and
    `lua_dual_abi` promotion exclusively to `.14.2.5.3`.
  - [x] **BOOK / KNOWLEDGE LOCKSTEP** — Document implemented-but-unadmitted Lua projections in the sole-facing
    book with direct rendered-block inspection; update task, Knowledge, roadmap, memory, and live docs without
    changing README, schemas, DSL, semantic/MCP/capability surfaces, or other backends.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused dual-ABI consumers, complete Lua/storage/corpus/CLI,
    language/neutral, book, Knowledge, all doctrines, definitive canonical CI, atomic commit 167/300, brief
    clearing, and clean proof before admission `.14.2.5.3`.

  Activation evidence 2026-08-07: immutable core `.14.2.5.1` lands atomically at `e6a75830` as intended 166/300
  with first parent `1136b1f2` and no push. Hooks regenerate Knowledge Map at 789/6,504, pass all seven doctrines,
  and validate the activation pointer in pre-commit and post-commit Git phases. Status plus staged/unstaged diffs
  are empty, `git_message_brief.txt` is zero bytes, post-commit memory architecture passes, the rendered book is
  absent, and the exact empty canonical-run directory is removed after proving it has no files and 0 KiB. This
  task-tree file is the sole activation diff before any Lua init/matching/interpreter/test, catalog, neutral,
  storage/canonical driver, book, Knowledge, roadmap, live-doc, or other change.

  Retrieval evidence 2026-08-07: the Knowledge Map routes this leaf to the typed-source rollout and dormant RED,
  Lua matching/register, anonymous-capture, governed-mark, cursor, alias, native-pipeline, and generated-plan
  owners. Their reverify evidence fixes one shared Lua-5.1-compatible interpreter, zero-based UTF-8-byte cursor,
  entry/local-match, anonymous-boundary, named-mark, and stack registers, plus native/loaded/reconstructed/
  generated/emitted convergence on `LinkedSpecRuntimeEngine`. The frozen consumer requires fresh detached exact
  47/30/11/4 projection rows and seven aliases, then compares unchanged native, reconstructed, and generated-plan
  results. The neutral JSON and admitted Rust/Dart/Julia implementations confirm that each projection vocabulary
  name is the typed operation/provenance boundary; capture-group collections/existence/deletion remain detached
  compatibility adapters. Lua's private core currently lacks runtime byte-to-scalar adapters and is not attached
  to `context(...)`, so this leaf owns exactly those private adapters, one per-input authority, shared dispatcher
  routing, and two package-seam catalog functions without ordinary/canonical admission.

  Implementation evidence 2026-08-07: private `source_location_runtime.lua` owns the exact static 47/30/11/4
  role map, seven compatibility aliases, fresh detached JSON projections, and one adapter over one copied `input`
  authority. The immutable core now resolves valid UTF-8 byte boundaries back to scalar positions and exposes
  private scalar-length/accessor operations. Every `context(...)` constructs exactly one adapter; no engine,
  compiled spec, register, generated plan, or serialized carrier retains it. The package seam validates the
  supplied engine before returning either fresh catalog.

  Routing evidence 2026-08-07: entry/local-match text, span lengths, offsets, and coordinates; whole input,
  scalar slices, cursor views; anonymous/named spans; mark/capture-boundary reads and writes; rule-slot marks; and
  save/restore/rewind targets now construct typed positions/spans and use authority-owned coordinates or
  materialization. Capture-group text/list/map/existence adapters retain their pre-existing detached compatibility
  shapes because the regex record owns those values, not source-boundary offsets. Cursor, entry/local match,
  capture start, mark buckets, and cursor stack remain the same zero-based UTF-8 byte numbers with unchanged write
  timing. The seven aliases still canonicalize before dispatch and therefore traverse the preferred typed route.

  Focused GREEN evidence 2026-08-07: core is 133/133 and projection is 240/240 independently on PUC Lua and
  LuaJIT; the unchanged projection consumer proves exact/detached 92+7 catalogs plus native, reconstructed, and
  generated-plan values. The dedicated alias consumer remains 638/638 per ABI, including loaded and independently
  emitted execution. An initial PUC load exposed the already-documented Lua 5.1 200-local chunk ceiling; composing
  the required module through one private table field and publishing adapters on that table restores syntax on
  both ABIs without behavior drift. Complete Lua passes byte-fresh MCP 83,166 bytes, package 177/177 per ABI,
  aliases 638/638 per ABI, CLI 66x2, corpus 105/105, storage 18/3, and its exact marker. Neutral remains 7/7/41
  and language remains 246/105+1/122; ordinary/canonical typed-source discovery remains unchanged for `.3`.

  Book/Knowledge evidence 2026-08-07: the sole-facing project-status, capture/source-location, helper-reference,
  and backend-handoff pages distinguish implemented private Lua projection from still-pending public typed values
  and admission. The local book build/link gate passes with 79 files / 14,188 KiB; direct generated-HTML inspection
  proves each changed status, runnable dual-ABI command block, following limitation, transaction section, and helper
  example occupies its own paragraph or code block instead of one stitched blob. Three existing Knowledge owners
  now preserve the implemented projection, admission boundary, and proven Lua 5.1 local-ceiling composition;
  regenerated retrieval remains exact at 789 facts / 6,504 question keys. README remains byte-unchanged.

  First canonical attempt 2026-08-07: capability conformance stopped before behavior suites because the active
  task-index refresh had shortened two governed historical closeout markers. Diffing the prior committed row and
  the checker's exact projection contract proved documentation wording drift, not a runtime or manifest defect.
  The refreshed row now retains both exact closed-parent markers — `Capability exclusion freshness is public-
  closed under FUTURE-PARITY-BACKLOG.24` and `exclusion public closeout .24.2 remains closed` — alongside this
  active frontier. Focused capability conformance must pass before restarting the definitive gate.

  Second canonical attempt 2026-08-07: the gate passed capability 80/0/0, neutral typed source 7/7/41, and exact
  Perl 10, Rust 4, Dart 4, and Julia 127 admitted typed-source consumers, then stopped at semantic public-current-
  state validation. Root-cause diff showed the same active roadmap-row compression had separated the governed
  exact phrase `128 mutations, rollout 9/9` in both roadmap projections. Restoring the complete historical semantic
  sentence preserves the existing 6-group / 20-response / 128-mutation / 9/9 / native-6/6 truth alongside the Lua
  frontier; no semantic artifact, model, runtime, or rollout state changed. Focused semantic validation must pass
  before another definitive restart.

  Definitive signoff evidence 2026-08-07: focused capability and semantic reruns pass exact 80/0/0 plus 6 fixture
  groups / 20 responses / 128 mutations / rollout 9/9 / native admission 6/6, and all seven doctrines pass. The
  third canonical run then completes uninterrupted: typed source remains 7/7/41 and executes exact Perl 10, Rust
  4, Dart 4, and Julia 127 consumers; all byte-fresh five-backend MCP bindings plus 5/5 implementations, 6/6
  runtimes, and 141 mutations pass; every composed semantic/MCP and adjacent behavior suite passes; six-family
  project data, relocated execution, moved-root Rust, and four outside-CWD anchors are exact. Primary CLI passes
  66/66 under default and POSIX environments, RAM is 65% against the 88% threshold, and Phase 0 passes 1,031/1,031
  in 662 wallclock seconds before exact `[ci] local CI gate passed`. The 79-file/14,188-KiB rendered book is removed
  after inspection; the sole canonical-run directory is empty/0 KiB and removed exactly. Atomic commit 167/300,
  brief clearing, post-commit pointer validation, and clean proof remain before `.14.2.5.3` activation.

  Commit/handoff evidence 2026-08-07: atomic commit `10e99190` lands with first parent `e6a75830`; the hook
  regenerates Knowledge Map at 789/6,504, passes all seven doctrines, and validates the activation pointer against
  pre-commit HEAD plus post-commit `HEAD^1`. Status and staged/unstaged diffs are empty, the ignored brief is zero
  bytes, post-commit memory architecture passes, the rendered book is absent, and the sole 0-KiB/no-file managed-
  run directory is removed exactly. Admission `.14.2.5.3` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.5.3`
  Status: `completed` (`5dcfc992`, 2026-08-09, 168/300, no push)
  Goal: Admit the unchanged shared Lua value/projection consumer on both PUC Lua and LuaJIT and promote only the
    neutral `lua_dual_abi` rollout leg.
  Depends on: `.14.2.5.2`
  Acceptance: Remove only the test-local RED selector, execute the consumer once per ABI from ordinary
    `tools/run_lua_local.sh` discovery, require its tracked path and exact two repository-routed commands in
    canonical CI, and strengthen the independent neutral checker against missing path, missing ABI, retained
    dormancy, command drift, and completed-to-pending Lua regression. Promote only `lua_dual_abi`, advance the live
    rollout from 7/7/41 to 8/6/42, and synchronize all live docs, sole-facing mdBook surfaces, Knowledge cards, and
    roadmap/task projections. Preserve helper results, byte-register storage, grammar, public typed/transaction/
    observation/dispatch surfaces, schemas/identities, semantic/MCP/capability state, root README, and every other
    rollout row.
  Verification: ordinary and canonical consumer once per ABI; neutral 8/6/42 plus independent Lua regression;
    complete dual-ABI/storage/corpus/CLI/book/Knowledge/doctrine/canonical signoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.5.3 - admit Lua typed source runtime`
  Commit: `5dcfc992`

  ### `FUTURE-PARITY-BACKLOG.14.2.5.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove projection `.14.2.5.2` landed at `10e99190` as 167/300 with
    first parent `e6a75830`, empty status/diffs, zero-byte brief, valid post-commit pointer, absent rendered book,
    and no managed-run residue; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / FREEZE ADMISSION DELTA** — Follow the Lua dormant-consumer, rollout, ordinary-discovery,
    canonical-registration, storage, and prior Perl/Rust/Dart/Julia admission owners before edits; prove the exact
    final-path consumer and implemented runtime stay unchanged outside test-local dormancy removal.
  - [x] **ORDINARY DUAL-ABI ADMISSION** — Remove only the consumer's RED selector and register the unchanged body
    exactly once for PUC Lua and once for LuaJIT in `tools/run_lua_local.sh`, retaining core 133 plus projection 240
    assertions and all existing Lua package/alias/corpus/CLI/storage results.
  - [x] **CANONICAL EXACT REGISTRATION** — Require the tracked consumer path and two exact repository-routed ABI
    commands in canonical CI; reject missing path, ABI, command drift, duplicate execution, or retained dormancy.
  - [x] **NEUTRAL PROMOTION / MUTATION** — Promote only `lua_dual_abi`, advance 7/7/41 to exact 8/6/42, and add an
    independent complete-to-pending Lua regression while every other rollout row and contract stays byte-exact.
  - [x] **NO-DRIFT / BOOK / KNOWLEDGE** — Preserve helpers, byte registers, values/mutations, grammar, public typed/
    transaction/observation/dispatch surfaces, schemas, semantic/MCP/capability state, README, and other backends;
    synchronize the sole-facing book, Knowledge, task/roadmap, memory, changes, development notes, and live status.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass ordinary/exact dual-ABI consumers, neutral 8/6/42, complete Lua/
    storage/corpus/CLI, book, Knowledge, all doctrines, definitive canonical CI, atomic commit 168/300, brief
    clearing, post-commit pointer validation, and clean proof before recurring composition `.14.2.6`.

  Activation evidence 2026-08-07: projection `.14.2.5.2` lands atomically at `10e99190` as 167/300 with first
  parent `e6a75830` and no push. Hooks regenerate Knowledge at 789/6,504, pass all seven doctrines, and validate
  pre/post-commit activation pointers. Status plus staged/unstaged diffs are empty, the brief is zero bytes, memory
  architecture passes, rendered book output is absent, and the exact empty managed-run directory is removed. This
  task-tree file is the sole activation diff before any consumer, driver, neutral artifact/checker, canonical,
  book, Knowledge, roadmap, memory, live-doc, or other change.

  Retrieval evidence 2026-08-07: the Knowledge Map routes this leaf to the dormant Lua typed-source consumer,
  runtime rollout, neutral contract, dual-ABI storage, shared matching/alias authorities, and prior Rust/Dart/Julia
  admissions. The final-path Lua consumer is already GREEN at 133 core assertions and 240 projection assertions on
  each ABI; its sole remaining test-local dormancy is `LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE` plus conditional
  projection lookup/execution and stale RED prose. `tools/run_lua_local.sh` is one repository-rooted managed run
  with explicit PUC and LuaJIT command lists, and `tools/run_lua_project_data.sh` is the exact targeted same-volume
  wrapper. Prior admissions prove the locked pattern: require the tracked final path, execute exact canonical
  repository-routed commands once, reject stale dormancy and command multiplicity in the independent checker,
  promote exactly one rollout row, and add its completed-to-pending mutation. Therefore this leaf changes no Lua
  production module or assertion body: it unconditionally binds the already-implemented catalogs, registers that
  same consumer once in each ordinary ABI list and once per ABI canonically, then advances only `lua_dual_abi`
  from pending to complete and 41 to 42 mutations.

  Focused admission evidence 2026-08-07: the test-local RED selector, conditional projection block, missing-module
  translation, and stale dormant prose are removed while the immutable value and projection assertion bodies stay
  exact. Both repository-routed focused commands pass 240/240 assertions. The independent checker requires the
  tracked final path, exact PUC and LuaJIT ordinary-driver command forms, exact two canonical wrapper commands,
  single occurrence of every registration, and absence of the RED selector/stale dormancy markers. It promotes
  only `lua_dual_abi`, independently rejects its completed-to-pending regression, and passes at exact 8 complete /
  6 pending / 42 mutations. The complete managed Lua gate then executes the consumer once per ABI and passes MCP
  83,166-byte freshness, package 177/177 and aliases 638/638 per ABI, CLI 66/66 under default and POSIX options,
  corpus 105/105, and storage 18 owners / three native modules. No production Lua file changes.

  Lockstep-drift root cause 2026-08-07: a full current-surface census finds `capability_conformance/README.md`
  still reporting correction `.14.2.0.1` truth (3/11/37 and every runtime pending). `git blame` fixes those lines
  to commits `e8f6198b`/`bd777ee8`; `git log` proves none of the subsequent Perl/Rust/Dart/Julia admission commits
  touched the artifact guide even though they updated the executable JSON/checker, Knowledge, and sole-facing
  book. This is accumulated documentation projection drift, not runtime or contract drift. The active all-live-doc
  acceptance owns its repair directly to exact 8/6/42 and all six runtime targets admitted, and this durable
  evidence prevents silently classifying the stale guide as current again.

  Lockstep evidence 2026-08-07: five sole-facing pages now admit the shared consumer once per PUC Lua/LuaJIT ABI
  while keeping authored Position/Span values, transactions, observations, dispatch, and recurring composition
  future. The repository-routed book builds 79 files / 14,184 KiB. Direct generated-HTML inspection proves each
  changed status, command, checker, limitation, and helper paragraph is a distinct `<p>` or `<pre>` block rather
  than a stitched blob. Knowledge regenerates and checks at 789 facts / 6,512 question keys, including searchable
  8/6/42 admission and artifact-guide drift-cause answers. Focused neutral 8/6/42, language 246/105+1/122,
  capability 80/0/0, semantic 6/20/128/9/9/6, MCP transport 35/10/10/76, memory, task metadata, diff/README,
  command multiplicity, and selector-absence checks pass. A broad stale scan finds only dated Julia-admission
  evidence fields, not current status/body prose. No production module, README, schema, DSL, semantic/MCP/
  capability artifact, or other backend changed; generated book cleanup precedes doctrine/canonical signoff.

  Signoff evidence 2026-08-07: the rendered book artifact is absent after its exact 79-file/14,184-KiB inspection;
  Knowledge regenerates/checks at 789 facts / 6,512 question keys, all seven doctrines pass, README remains exact,
  and definitive canonical CI exits zero. The canonical run preserves capability 80/0/0, typed source 8/6/42
  with Perl 10, Rust/Dart 4/4, Julia 127/127, and PUC Lua/LuaJIT 240/240, every byte-fresh MCP binding and composed
  semantic/MCP admission, six-family containment, relocated/moved/outside-CWD execution, and CLI 66/66 under both
  option environments. It reports RAM 75%, passes Phase 0 1,031/1,031 in 670 wall-clock seconds, emits the exact
  `[ci] local CI gate passed` marker, and exits zero. Atomic commit 168/300, brief clearing, post-commit pointer
  validation, managed-run cleanup, and clean proof remain before recurring composition `.14.2.6` can activate.

  Commit/handoff evidence 2026-08-09: atomic commit `5dcfc992` lands with first parent `10e99190`; its hook
  regenerates Knowledge at 789/6,512, passes all seven doctrines, and validates the activation pointer against
  pre-commit HEAD plus post-commit `HEAD^1`. Status and staged/unstaged diffs are empty, the ignored brief is zero
  bytes, post-commit memory architecture passes, the rendered book is absent, and managed-run residue is zero.
  Recurring composition `.14.2.6` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.2.6`
  Status: `done; signoff-complete` (2026-08-09; task-tree-first from clean dual-ABI admission commit `5dcfc992`,
    atomic commit intended as 169/300 with no push)
  Goal: Compose the six admitted runtime consumers, exact helper/value cases, support ledgers, and canonical opt-in
    behind one repository-routed recurring driver without duplicating final program-wide public no-drift `.14.8`.
  Depends on: `.14.2.5.3`
  Acceptance: Run neutral, Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in that exact order; bind six runtime roles,
    five consumer sources, exact supported commands, route multiplicity, tracked registration, and canonical opt-in
    through independent omissions. Add no new storage root or hosted workflow.
  Verification: exact recurring driver order and role/source/command topology; neutral artifact/checker mutation
    proof; canonical opt-in registration; five backend/six-runtime consumers; support ledgers; storage, book,
    Knowledge, doctrines, definitive canonical CI, atomic commit, and clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.2.6 - compose typed source runtime proof`

  ### `FUTURE-PARITY-BACKLOG.14.2.6` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove Lua admission `.14.2.5.3` landed at `5dcfc992` as 168/300
    with first parent `10e99190`, empty status/diffs, zero-byte brief, valid post-commit pointer, absent rendered
    book, and zero managed-run residue; make this task-tree file the sole activation diff.
  - [x] **RETRIEVE / FREEZE RECURRING BOUNDARY** — Follow the typed-source ADR, neutral/rollout Knowledge owners,
    all six admitted consumers, existing recurring-driver precedents, project-data storage, canonical opt-ins, and
    sole-facing current/future claims before changing executable topology.
  - [x] **EXACT REPOSITORY-ROUTED DRIVER** — Add one managed recurring driver that runs neutral first, then Perl,
    Rust, Dart, Julia, PUC Lua, and LuaJIT in exact order using the five existing consumer sources unchanged.
  - [x] **ROLE / SOURCE / COMMAND GOVERNANCE** — Bind six runtime roles, five tracked consumer paths, exact
    supported commands, route multiplicity, driver inputs, and independent omission/order/command mutations in the
    neutral artifact/checker while leaving the combined `.14.8` rollout row pending, preserving rollout at 8/6,
    and advancing mutation governance from the 42-admission baseline to 53.
  - [x] **CANONICAL OPT-IN** — Register the exact tracked driver once behind one explicit canonical opt-in without
    adding a default cost, hosted workflow, storage root, alternate driver, or implicit toolchain assumption.
  - [x] **NO-DRIFT / BOOK / KNOWLEDGE** — Preserve all runtime values, helper results, registers, schemas, DSL,
    semantic/MCP/capability state, README, and public `.14.8` no-drift ownership; synchronize the sole-facing book,
    Knowledge, task/roadmap, memory, changes, development notes, and live status.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass the exact recurring proof, every support ledger, storage/book/
    Knowledge/doctrines, definitive canonical CI, atomic commit 169/300, brief clearing, pointer validation, and
    clean proof before unchanged recomposition `.14.2.7`.

  Activation evidence 2026-08-09: Lua admission `.14.2.5.3` lands atomically at `5dcfc992` as 168/300 with first
  parent `10e99190` and no push. Hooks regenerate Knowledge at 789/6,512, pass all seven doctrines, and validate
  pre/post-commit activation pointers. Status plus staged/unstaged diffs are empty, the ignored brief is zero bytes,
  memory architecture passes, rendered book output is absent, and managed-run residue is zero. This task-tree file
  is the sole activation diff before any recurring driver, neutral artifact/checker, canonical, book, Knowledge,
  roadmap, memory, live-doc, or other change.

  Retrieval/root-cause evidence 2026-08-09: ADR `0056` sections 8-9, the `.14.2.0` frozen plan, current rollout
  Knowledge, and semantic/MCP/cursor recurring precedents establish composition as orchestration over unchanged
  admitted consumers. One apparent mismatch required history: the executable ledger has no `.14.2.6` rollout row,
  only pending `recurring_public_no_drift` owned by `.14.8`, whereas adjacent contracts promote a separate recurring
  leg. Blame and `git -S` prove the combined row originates in neutral commit `e8f6198b`; detailed plan `5a294f39`
  later froze `.14.2.6` as driver/topology binding and `.14.8` as final examples/tooling/no-drift, and correction
  `bd777ee8` deliberately changed only stale public rows and runtime owners. The original/current `.14.2.6`
  acceptance names roles, paths, commands, multiplicity, registration, and opt-in but no rollout promotion;
  `.14.8` explicitly owns recomposing recurring governance and completing public no-drift. Therefore this leaf
  adds a governed recurring topology while preserving the combined `.14.8` row pending and the 8/6 rollout from
  the 8/6/42 admission baseline. It must not invent a fifteenth rollout leg or prematurely consume `.14.8`.

  Implementation evidence 2026-08-09: `tools/check_typed_source_location_six_runtime.sh` enters the existing
  repository-derived managed run and executes neutral, Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, then the three
  support ledgers in exact fail-fast order. The JSON and independent checker model five backend consumer groups—
  two Perl paths, one Rust, one Dart, one Julia, and one shared Lua path—and bind them to six runtime routes because
  Lua executes independently on both ABIs. Exact driver/source/role/command/order/multiplicity/support/canonical
  markers are locked. Eleven independent topology mutations advance 42 to 53 while rollout remains exact 8/6;
  one mutation specifically rejects premature completion of the combined `.14.8` row.

  Canonical/storage evidence 2026-08-09: canonical CI rejects the driver while untracked, requires it once as an
  input and once inside the optional block, audits machine-specific paths, syntax-checks it, and executes it only
  behind exact `LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX=1`. The outside-CWD workflow-routing oracle includes the driver
  and proves missing-Julia failure cleanup through the existing project-data initializer. The driver owns no
  `mktemp`, cache, package store, alternative scratch root, hosted workflow, or default all-toolchain cost. Shell
  syntax, whitespace, focused neutral 8 complete / 6 pending / 53 mutations, and hostile routing proof pass.

  Lockstep evidence 2026-08-09: the artifact guide and toolbox expose the exact recurring command,
  five-source/six-route topology, 53-mutation result, canonical switch, and `.14.8` boundary. Five sole-facing
  pages teach the same current internal recurrence while retaining future authored values, transactions,
  observations, and progressive/staged dispatch. Each changed explanation is separated into paragraphs and code
  blocks at source; rendered HTML inspection remains before signoff. A dedicated Knowledge card makes the combined-
  row root cause and reverify commands searchable, and roadmap/task/memory/change/development/architecture/live
  projections align without changing root README or runtime/helper/schema behavior.

  Recurring/runtime and rendered-book evidence 2026-08-09: the complete new driver exits zero after neutral
  8/6/53, Perl 10 tests, Rust 4, Dart 4, Julia 127, PUC Lua 240, LuaJIT 240, and the exact generated-source,
  capability 80/0/0, and language 246/105+1/122 support authorities. The repository-routed mdBook builds 79 files /
  14,204 KiB. Direct generated-HTML inspection of all five changed pages proves the recurring explanation, command,
  canonical switch, topology, limitation, and following material are separate `<p>` and `<pre>` blocks; the
  rendered artifact is then removed exactly. The in-app browser control surface is unavailable in this session,
  so no screenshot-level claim is made. Knowledge regenerates/checks at 790 facts / 6,526 question keys; memory
  architecture, task metadata, README stability, shell syntax, whitespace, and focused routing remain green.

  Definitive signoff evidence 2026-08-09: all seven doctrines pass on the staged slice. The first restricted-
  harness canonical attempt reaches the representative process-I/O proof after every preceding section passes,
  then macOS `sandbox-exec` is denied by the outer harness with status 71. The approved canonical rerun crosses
  that exact boundary: relocated six-family containment passes, all five moved/outside-CWD anchors pass, both CLI
  environments pass 66/66, RAM is 78% below the 88% guard, and Phase 0 passes 1,031/1,031 in 669 wall-clock
  seconds. The run recognizes and default-skips the new `LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX` opt-in, emits exact
  `[ci] local CI gate passed`, and exits zero. Atomic commit 169/300, brief clearing, post-commit pointer proof,
  managed-run cleanup, and clean status proof are the mechanical landing steps before `.14.2.7` activation.

- ID: `FUTURE-PARITY-BACKLOG.14.2.7`
  Status: `done; signoff-complete` (2026-08-09; task-tree-first from clean recurring-proof commit `3ac89665`,
    atomic 170/300, no push)
  Goal: Recompose the committed rollout correction, five backend implementations, six runtime admissions, and
    recurring driver unchanged; close `.14.2` and hand one clean next action to transaction safety `.14.3`.
  Depends on: `.14.2.6`
  Acceptance: Prove the committed neutral values/projections, all six runtime admissions, exact recurring topology,
    support ledgers, and current public/future boundary compose without replacement implementation, contract,
    fixture, schema, helper, CLI, or rollout movement. Close `.14.2` only after lockstep book/Knowledge/live truth,
    definitive canonical signoff, atomic commit, and clean handoff.
  Verification: clean activation; Knowledge-first owner retrieval; committed-source/no-replacement census; exact
    six-runtime recurring driver; support/capability/language ledgers; sole-facing book render and paragraph-block
    inspection; Knowledge, memory, task metadata, README, doctrines, canonical CI, atomic commit, and clean proof
  Commit: `FUTURE-PARITY-BACKLOG.14.2.7 - recompose typed source value rollout`

  ### `FUTURE-PARITY-BACKLOG.14.2.7` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.2.6` landed atomically at `3ac89665` as 169/300 with
    first parent `5dcfc992`, empty status/diffs, zero-byte brief, valid post-commit pointer, absent rendered book,
    zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / FREEZE RECOMPOSITION BOUNDARY** — Follow ADR `0056`, the `.14.2.0` frozen implementation plan,
    current typed-source Knowledge owners, exact runtime admissions, recurring topology, and sole-facing claims;
    reject replacement implementation or premature `.14.8` public no-drift promotion.
  - [x] **COMMITTED OWNER RECOMPOSITION** — Run the unchanged neutral checker and exact neutral→Perl→Rust→Dart→
    Julia→PUC-Lua→LuaJIT→three-ledger driver; prove five consumer groups, six routes, 8/6/53 governance, 80/0/0
    capability, and 246/105+1/122 language coverage remain exact.
  - [x] **NO-REPLACEMENT / NO-DRIFT CENSUS** — Prove no production runtime, existing consumer, fixture, contract,
    schema, descriptor, helper result/register, DSL, CLI, root README, storage root, hosted workflow, or combined
    `.14.8` rollout row moves in this closeout.
  - [x] **LOCKSTEP / PARENT CLOSURE** — Synchronize task/roadmap/memory/change/development/architecture/live and the
    sole-facing book to the verified committed state; close `.14.2` while retaining transactions `.14.3` and final
    examples/tooling/no-drift `.14.8` as future owners.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused recurrence, rendered book, Knowledge/memory/task/README,
    all doctrines, definitive canonical CI, atomic commit 170/300, brief clearing, pointer validation, managed-run
    cleanup, and clean proof before `.14.3` activation.

  Activation evidence 2026-08-09: recurring composition `.14.2.6` lands atomically at `3ac89665` as 169/300 with
  first parent `5dcfc992` and no push. Its hook regenerates Knowledge at 790/6,526, passes all seven doctrines, and
  validates `activation_commit 5dcfc992` before and after commit. Status and staged/unstaged diffs are empty, the
  ignored brief is zero bytes, post-commit memory architecture and Knowledge freshness pass, rendered book output
  is absent, and managed-run census reports `found=0 removed=0 skipped=0`. This task-tree file is the sole activation
  diff before any closeout evidence, book, Knowledge, roadmap, memory, live-doc, or other change.

  Retrieval evidence 2026-08-09: ADR `0056` sections 8-9, the complete `.14.2.0` frozen plan, neutral-contract,
  runtime-rollout, and recurring-gate Knowledge owners all agree on one closeout boundary. Each backend already
  owns one admitted internal source authority/value/projection path; host-unit registers and external helper values
  remain unchanged; only four private value diagnostics belong to `.14.2`; and the committed driver is the exact
  recurrence authority. This leaf adds no replacement consumer, implementation, fixture, artifact, schema, helper,
  authored typed facade, transaction, progressive/staged dispatch, or rollout promotion. It recomposes 8/6/53 and
  closes `.14.2`; transactions remain `.14.3`, while the combined recurring/public no-drift row and public examples/
  tooling remain `.14.8`.

  Recomposition/no-replacement evidence 2026-08-09: the committed
  `tools/check_typed_source_location_six_runtime.sh` exits zero without changing a tracked executable owner. It
  reports neutral 8 complete / 6 pending / 53 mutations, Perl 10 tests, Rust 4, Dart 4, Julia 127, PUC Lua 240,
  LuaJIT 240, generated-source v1 with strict Rust 105/105, capability schema v2 at 80/0/0, and language coverage
  246 current names / 105 corpus + 1 exact named-mark fixture / 122 public Perl contracts. Immediately afterward,
  status and `git diff --name-only` contain only this task-tree file. No runtime, consumer, fixture, artifact,
  checker, schema, generated source, helper, CLI, README, storage, hosted-workflow, or `.14.8` row changed.

  Lockstep/render evidence 2026-08-09: ADR `0056` now records the internal six-runtime value/projection slice
  complete while retaining `.14.3-.8`; existing neutral, rollout, and recurring Knowledge owners record the same
  no-change closeout; parent/backend task summaries, both roadmaps, task index, memory, changes, development,
  architecture, and live status align. Five sole-facing pages add only isolated closeout paragraphs. The supported
  repository-routed mdBook build produces 79 files / 14,212 KiB, and direct HTML inspection proves every new status
  paragraph is its own `<p>` with preceding/following material in separate blocks. No screenshot claim is made
  because the in-app browser surface is unavailable. Knowledge remains exact at 790 facts / 6,526 question keys,
  memory is 52/60 lines, whitespace is clean, generated book output is removed, and the diff remains 18 task/ADR/
  Knowledge/book/live documents with no executable or root README path.

  Canonical/landing evidence 2026-08-09: all seven doctrines, six-family process containment, moved/outside-CWD
  execution, both reference CLI environments at 66/66, and the unchanged composed semantic/MCP/typed-source gates
  pass in the definitive approved local-CI run. RAM is 82% below the 88% guard; Phase 0 passes 1,031/1,031 in 691
  wall-clock seconds; optional typed-source execution is recognized and default-skipped after its focused exact
  run; the gate emits exact `[ci] local CI gate passed` and exits zero. Atomic commit 170/300, zero-byte brief,
  pointer validation, zero managed-run residue, and clean status/diffs complete the mechanical handoff. Parent
  `.14.2` is composition-closed; `.14.3` is the sole next activation and `.14.8` remains unconsumed.

- ID: `FUTURE-PARITY-BACKLOG.14.3`
  Status: `done; signoff-complete` (2026-08-11; public closeout `.8` is commit-ready as atomic 206/300 from clean
    recurring commit `e6893fd4`; exact doctrine/canonical proof passes; clean commit remains; no push)
  Goal: Specify and implement bounded checkpoint/try/commit/rollback cursor transactions plus exact progress,
    nullable-recursion, stale-mark, and cross-boundary safety diagnostics while composing, not re-owning, the
    already-admitted reversed-span value diagnostic.
  Depends on: `.14.2.7`
  Children: `.14.3.0-.14.3.8`; `.0` audits and freezes the contract/split before behavior, `.1` owns the executable
    neutral state machine, `.2-.6` own Perl/Rust/Dart/Julia/shared-Lua implementation and admission, `.7` owns
    six-runtime recurrence, and `.8` recomposes unchanged and closes this parent.

- ID: `FUTURE-PARITY-BACKLOG.14.3.0`
  Status: `done` (2026-08-09; task-tree-first behavior-free audit from clean `bef75489`, intended 171/300,
    no push)
  Goal: Audit current cursor/mark/recursion/repetition/effect semantics and freeze the dependency-complete neutral,
    syntax, diagnostic, backend, admission, recurrence, and closeout plan before transaction behavior changes.
  Depends on: `.14.2.7`
  Acceptance: Retrieve ADR `0056` and canonical Knowledge before inspection; use LinkedSpec's toolbox to map
    `save_cursor`/`restore_cursor`, anonymous boundaries, named-mark lifetime, rule invocation ownership, recursive
    and repeated progress, action/effect families, backend control paths, and current diagnostics. Reconcile the
    stale parent wording that repeats `reversed-span` ownership even though `.14.2` already owns and admits
    `source_location_reversed_span`; freeze `.14.3` interaction coverage without duplicating that diagnostic.
    Specify one bounded recognition-only transaction state machine, exact token lifetime/nesting/escape rules,
    commit/rollback visibility, effect barrier, progress obligations, portable diagnostic payloads, syntax/API
    decision point, RED-first fixtures, mutations, per-backend seams, independent admissions, recurring topology,
    storage, mdBook, and `.14.3.1-.8` dependencies. Change no runtime, DSL, neutral executable contract, schema,
    helper result/register, fixture, CLI, README, storage root, hosted workflow, or public-current behavior.
  Verification: clean activation and exact parent/subject proof; Knowledge-first retrieval; toolbox-led source and
    runtime probes; owner/diagnostic contradiction evidence; existing typed-source/mark/cursor/repetition/recursion
    focused gates; complete no-change census; Knowledge, memory, task metadata, sole-facing book, all doctrines,
    definitive canonical CI, atomic commit, brief clearing, pointer validation, managed-run cleanup, and clean proof
  Commit: `FUTURE-PARITY-BACKLOG.14.3.0 - audit cursor transaction safety`

  ### `FUTURE-PARITY-BACKLOG.14.3.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.2.7` landed atomically at `bef75489` as 170/300 with
    first parent `3ac89665`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer, fresh
    Knowledge, absent rendered book, zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / CURRENT AUTHORITY MAP** — Follow ADR `0056`, the typed-source direction and rollout Knowledge,
    existing rule-local cursor/mark/progress decisions, and toolbox entrypoints before re-deriving current behavior.
  - [x] **TOOLBOX-LED SEMANTIC AUDIT** — Map exact Perl/Rust/Dart/Julia/Lua owners and observable cursor, boundary,
    mark, recursion, repetition, call, action/effect, diagnostic, and generated/reconstructed behavior.
  - [x] **OWNERSHIP RECONCILIATION** — Root-cause the stale `reversed-span` phrase, retain the admitted `.14.2`
    diagnostic owner, and assign only transaction interaction plus mark/progress/cross-boundary failures to `.14.3`.
  - [x] **FREEZE CONTRACT / SPLIT** — Freeze the bounded recognition-only state machine, effect barrier, progress
    proof, diagnostics, fixtures/mutations, syntax decision, backend seams, admissions, recurrence, and `.1-.8`
    dependency/commit boundaries before executable work.
  - [x] **LOCKSTEP / NO-BEHAVIOR PROOF** — Synchronize ADR/Knowledge/task/roadmap/memory/live/book plan truth while
    proving production, executable neutral contract, fixtures, schemas, helper values/registers, CLI, README,
    storage, hosted workflows, and public-current behavior remain unchanged.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused current-behavior proof, book/Knowledge/memory/task/README,
    all doctrines, definitive canonical CI, atomic 171/300, brief clearing, pointer validation, managed-run cleanup,
    and clean proof before neutral contract `.14.3.1` activation.

  Activation evidence 2026-08-09: no-change value/helper closeout `.14.2.7` lands atomically at `bef75489` as
  170/300 with first parent `3ac89665` and exact subject
  `FUTURE-PARITY-BACKLOG.14.2.7 - recompose typed source value rollout`. Status plus staged/unstaged diffs are
  empty, the ignored brief is zero bytes, post-commit memory architecture validates `activation_commit 3ac89665`
  against `HEAD^1`, Knowledge is fresh, rendered book output is absent, and managed-run census reports
  `found=0 removed=0 skipped=0`. This task-tree file is the sole activation diff before audit evidence or any other
  change.

  Retrieval and ownership evidence 2026-08-09: ADR `0056`, the typed-source direction/rollout cards, rule-local
  cursor/mark decisions, recursion/progress records, current neutral artifact, and `TOOLBOX.md` were retrieved
  before source or runtime inspection. Git blame proves the parent diagnostic phrase came from architecture commit
  `64735109` on 2026-07-29, while the later `.14.2.0` plan commit `5a294f39` explicitly assigned
  `source_location_reversed_span` and the other three immutable-value diagnostics to `.14.2`. That later exact
  owner wins. `.14.3` owns only transaction interaction, mark lifetime, progress, and cross-rule/source failures;
  it must reuse rather than duplicate the admitted reversed-span record.

  Toolbox/current-behavior evidence 2026-08-09: `call_spec_handler_subst` lowers `save_cursor()` to
  `cursor_checkpoint_compatibility`, lowers `restore_cursor()` to a pop from `$info->{cursor_stack}`, and shows
  mark storage addressed by rule label. The documented `LinkedSpec::Get` example already passes a scalar reference;
  an earlier by-value probe failure was caller error, not a toolbox defect, so no false `.22` handoff is opened.
  A correct same-label recursive probe over `aa` returns numeric `2`: the child invocation overwrites the parent's
  `shared` mark because the current contract is `rule_label -> mark_name -> position`, not invocation identity.
  A direct no-consume `return(call(Top))` probe returns `undef`, emits the `(rule,position)` recursion-cut trace, and
  leaves `last_error` null. A bounded `OR{,3}` over `/x*/` returns one `"Z"` and stops without a diagnostic. These
  are measured current compatibility boundaries, not already-portable transaction/progress behavior.

  Backend authority evidence 2026-08-09: Perl carries `$info->{marks}` and `$info->{cursor_stack}` through generated
  handlers. Rust `RuntimeContext`, Dart `_RuntimeExecutionContext`, Julia `_RuntimeExecutionContext`, and Lua's
  runtime context likewise carry rule-label mark maps and one execution-global LIFO cursor stack. All five owners
  already save/restore immediate entry/local-match plus anonymous capture-boundary registers around child calls.
  Their recursion guards use active `(rule/entry, cursor)` keys and silently cut a repeated key; repetition loops
  break after an accepted zero-width iteration. Native/reconstructed/generated carriers re-enter these same runtime
  seams. Existing `save_cursor`/`restore_cursor` therefore cannot be renamed into transactions: they have no opaque
  owner/generation, snapshot only the cursor, and cannot diagnose escape, reuse, cross-invocation, or cross-source
  authority.

  Effect-model evidence 2026-08-09: `return_descriptor` for
  `state = "wrong"; mark_here(shared); call(Done); return(retv)` reports exact canonical `ASSIGN`, `MARK_HERE`,
  `CALL`, and `RETURN` nodes plus contract ids, but no purity/effect class. Semantic introspection exposes illustrative
  effect facts for only `trim`, `match_text`, and `return`; it is not a closed classification of the current 246
  call names or all ActionIR statement/control forms. Transaction admission must therefore add one independently
  checked, closed effect taxonomy and transitive call-graph analysis. Unknown/RAW_PERL, user/callable function,
  binding/aggregate/AST mutation, compatibility cursor-stack mutation, output/diagnostic, exit, registry/parser,
  external, and host effects fail closed before commit; pure reads/construction/control and typed cursor/boundary/
  invocation-mark writes are the only v1 candidates, with a runtime barrier as the dynamic backstop.

  Frozen v1 implementation plan 2026-08-09: each parse execution allocates monotonic non-reused invocation ids;
  each entered rule owns an invocation frame and generation. An opaque token binds source authority, rule identity,
  invocation id/generation, transaction id, and originating edge/job, and snapshots only cursor, anonymous boundary,
  and that invocation's named marks. V1 permits one active transaction per invocation: no nesting, aggregate/function
  storage, return/escape, caller unwind, alternative search, retry, or cross-rule/source use. Commit or rollback is
  single-use and invalidates the token. A recognition attempt executes one explicitly named rule path once; its
  return/control result remains staged until commit and is discarded on rollback. Exact authored spellings and
  staged-result exposure are deliberately selected in behavior-free `.14.3.1.0`, not guessed in this audit; they
  must remain visibly distinct from `save_cursor`/`restore_cursor` and preserve explicit `call(Rule)` semantics.

  Progress and diagnostic plan 2026-08-09: v1 proves cursor advance only; it selects no authored decreasing-measure
  API. A zero-width match remains representable outside a progress obligation, but a repetition or direct/mutual
  recursive edge that accepts without cursor advance emits the existing neutral nullable/direct/mutual progress
  code with exact source/rule/invocation/edge/start/end context. Transaction tokens use the existing eleven neutral
  unknown/stale/cross-invocation/invalidated/nesting/escape/double-terminal/effect/cross-rule/cross-source codes;
  mark-frame migration uses the four existing mark-lifetime codes. Staged-dispatch cycles remain `.14.7`; the four
  immutable-value diagnostics remain `.14.2`. RED consumers must lock current silent cutoff/one-hit baselines before
  each backend changes them.

  Frozen slice topology 2026-08-09: neutral parent `.1` splits behavior-free syntax/effect ratification `.1.0`,
  executable artifact/checker/mutations `.1.1`, and neutral/public-future closeout `.1.2`. Each backend parent
  `.2-.6` splits dormant RED `.0`, private invocation/token core `.1`, transaction/effect/progress integration `.2`,
  and independent ordinary/canonical admission `.3`; Lua owns one shared implementation and two ABI admissions.
  `.7` binds one exact six-runtime recurring route and promotes only transaction safety; `.8` recomposes unchanged,
  closes this parent, and hands off to `.14.4`. Every behavior slice updates the sole-facing book with separate
  readable paragraphs and exact current-versus-future claims.

  Final verification 2026-08-09: the focused Perl named-mark/cursor/repeated-result proof passes 301 assertions;
  typed source-location passes neutral 8 complete / 6 pending / 53 mutations plus Perl 10, Rust/Dart 4/4, Julia
  127, and PUC Lua/LuaJIT 240/240; repeated-action proof passes neutral 8/0/54 plus Perl 10, Rust/Dart 3/3, Julia
  162, and PUC Lua/LuaJIT 175/175. Capability remains 80/0/0 and language coverage remains 246 current names /
  105 corpus + 1 named-mark fixture / 122 public Perl contracts. The complete working census is documentation,
  Knowledge, task, decision, live, roadmap, and sole-facing book only. The repository-routed book builds 79 files /
  14,232 KiB, and generated HTML inspection proves the new headings and explanations render as distinct paragraphs,
  not a stitched blob; the generated book is then removed. Knowledge regenerates/checks at 791 facts / 6,538
  question keys, memory/task/README checks pass with README unchanged at 105/128 lines and 5,072/6,144 bytes, and
  all seven doctrines pass. The first restricted canonical run reaches the nested containment proof but receives
  environmental `sandbox-exec` status 71; the approved authoritative rerun passes containment, moved-root and four
  outside-CWD anchors, both CLI environments at 66/66, RAM 63% below the 88% guard, and Phase 0 1,031/1,031 in
  708 wall-clock seconds before exact `[ci] local CI gate passed` and exit zero. Atomic 171/300, zero-byte brief,
  pointer validation, zero managed-run residue, absent rendered book, and clean status/diffs complete the intended
  mechanical handoff; exact syntax/result/effect ratification `.14.3.1.0` is next.

- ID: `FUTURE-PARITY-BACKLOG.14.3.1`
  Status: `done; composition-closed` (2026-08-10; ratification, executable neutral authority, rendered repair, and
    fail-closed public-sequence guard complete through `.14.3.1.2.0`; intended atomic 183/300; no push)
  Goal: Adopt the versioned backend-neutral transaction/progress contract, exact fixtures, diagnostics, mutations,
    public future/current boundary, and canonical registration before backend behavior.
  Depends on: `.14.3.0`
  Children: `.14.3.1.0-.14.3.1.2`, plus public-sequence guard `.14.3.1.2.0`

- ID: `FUTURE-PARITY-BACKLOG.14.3.1.0`
  Status: `done; signoff-complete` (2026-08-09; task-tree-first from clean transaction-audit commit `c8fcea6f`,
    intended atomic 172/300, no push)
  Goal: Ratify exact authored transaction spellings, recognition-result exposure, closed effect taxonomy, token
    lifetime, invocation-mark migration, and cursor-only v1 progress rule without changing executable behavior.
  Depends on: `.14.3.0`
  Acceptance: Prove the clean `.14.3.0` handoff; retrieve ADR `0056`, the cursor-transaction audit, source-location
    direction, task-metadata boundary, and exact current ActionIR/runtime owners before choosing names. Freeze one
    grammar-owned authored transaction surface that is unmistakably distinct from compatibility
    `save_cursor`/`restore_cursor`, exposes match presence separately from falsey staged values, and preserves
    explicit `call(Rule)` semantics. Freeze the closed fail-closed ActionIR effect lattice and transitive callable
    rule, opaque token ownership/generation/single-terminal lifetime, invocation-scoped mark migration, and
    cursor-only v1 progress obligation with exact current-versus-future book language. Root-cause and repair the
    stale active-tree `Current Frontier` prose discovered during startup, retain a durable finding, and route the
    active-frontier enforcement gap to its own clean follow-up task. Change no executable source, neutral artifact,
    fixture, schema, generated carrier, CLI, README, storage root, hosted workflow, or current public behavior.
  Verification: **PASS 2026-08-09.** Clean activation and exact parent/subject proof; Knowledge-first retrieval;
    toolbox/source owner comparison; spelling ambiguity and falsey-result review; complete ActionIR category
    closure; token/mark/progress contradiction review; no-change census; rendered 79-file / 14,248-KiB mdBook;
    Knowledge 793 facts / 6,558 question keys; memory, task metadata, unchanged README 105/128 lines and
    5,072/6,144 bytes, all seven doctrines, typed-source/capability/language-coverage focused gates; and the
    definitive canonical gate all pass. Canonical proof includes both CLI environments at 66/66, RAM 58% below
    the 88% ceiling, moved-root/five-anchor containment, and Phase 0 1,031/1,031 in 672 wall-clock seconds before
    exact `[ci] local CI gate passed` and exit zero. Atomic commit, zero-byte brief, post-commit pointer/Knowledge,
    zero managed runs, absent rendered book, and clean status/diffs complete the mechanical handoff.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.1.0 - ratify cursor transaction contract`

  ### `FUTURE-PARITY-BACKLOG.14.3.1.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.3.0` landed atomically at `c8fcea6f` as 171/300 with
    first parent `bef75489`, exact subject, empty status/diffs, zero-byte brief, valid pointer, fresh Knowledge,
    absent rendered book, zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / CURRENT AUTHORITY** — Follow ADR `0056`, canonical Knowledge, and toolbox/source owners before
    selecting authored spellings, result shape, effects, token rules, invocation marks, or progress semantics.
  - [x] **RATIFY EXACT CONTRACT** — Freeze exact grammar, ActionIR nodes/effects, staged result, token state machine,
    invocation-mark migration, and cursor-only progress rule without executable behavior.
  - [x] **ROOT-CAUSE / ROUTE FRONTIER DRIFT** — Correct this file's stale authoritative frontier, preserve the
    causal finding, and create a clean follow-up owner for active-tree frontier freshness enforcement.
  - [x] **LOCKSTEP / NO-BEHAVIOR PROOF** — Synchronize decision, Knowledge, roadmap, live docs, task truth, and the
    sole-facing book while proving runtime, neutral executable artifacts, fixtures, schemas, CLI, README, storage,
    hosted workflow, and public-current behavior stay unchanged.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused and broad gates, atomic 172/300, brief clearing, pointer
    validation, managed-run cleanup, absent rendered book, and clean proof before `.14.3.1.1` activation.

  Activation evidence 2026-08-09: behavior-free transaction audit `.14.3.0` lands atomically at `c8fcea6f` as
  171/300 with first parent `bef75489` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.0 - audit cursor transaction safety`. Status plus staged/unstaged diffs are empty,
  the ignored brief is zero bytes, post-commit memory architecture validates `activation_commit bef75489` against
  `HEAD^1`, Knowledge is fresh, rendered book output is absent, and managed-run census reports
  `found=0 removed=0 skipped=0`. This task-tree file is the sole activation diff before contract evidence or any
  other change.

  Retrieval and current-authority evidence 2026-08-09: ADR `0056`, the cursor-direction and transaction-audit
  Knowledge cards, the exhaustive 246-name ActionIR fact, task-metadata gate boundary, `TOOLBOX.md`, current
  source-location neutral state machines/diagnostics, and the exact Perl/Rust/Dart/Julia/Lua cursor/mark owners
  were read before choosing names. Current `save_cursor`/`restore_cursor` remains a cursor-only compatibility
  stack; current marks remain rule-label buckets; `CALL` and falsey rule results have no public accepted-bit
  channel; and current ActionIR has canonical kinds/contracts but no closed effect field. The decision therefore
  cannot be implemented as helper aliases, payload truthiness, or an illustrative semantic-effect extension.

  Exact spelling/result decision 2026-08-09: accepted future authored code uses
  `tx = recognition_checkpoint()` followed by exactly one `recognize_once(tx, call(Rule))` and exactly one
  `recognition_commit(tx)` or `recognition_rollback(tx)` on every path. The four calls are grammar-owned dedicated
  `RECOGNITION_*` ActionIR nodes, not ordinary helpers. `recognize_once` treats its exact static `call(Rule)`
  operand specially so the call is not evaluated before the snapshot, executes the named rule path once, and
  returns a strict match boolean. The payload stays staged. Commit invalidates first, keeps recognized state, then
  yields the payload—including valid `false`, `0`, empty-string, or `undef`; rollback restores and discards. It is
  legal to rollback either a match or miss, and commit of a miss yields `undef` while the prior boolean remains the
  authoritative match fact. Neither terminal implicitly writes `retv`, accumulators, or visible match registers.

  Token/effect decision 2026-08-09: one token is bound directly to one bare rule-local linear slot and carries
  source, rule, invocation id/generation, transaction id, and origin. Copy, comparison, aggregate/function/
  codeblock storage, return/capture/serialization, retry, nesting, caller unwind, and cross-invocation/source use
  are rejected. Missing terminal, repeated attempt, or forbidden placement uses the existing transaction-escape
  family; terminal reuse retains exact double-terminal/invalidated-token ownership. The closed effect lattice has
  nine allowed atoms (`pure_value`, `source_read`, bounded `structured_control`, `rule_recognition`,
  `transaction_state`, matcher `cursor_advance`, `capture_boundary_write`, `invocation_mark_write`,
  `staged_return`) and eleven rejected families (binding, aggregate, AST/object, compatibility cursor, output,
  authored diagnostic, exit/unbounded control, dynamic callable, registry/staged, external/host, unknown/raw).
  Every ActionIR node and all 246 call contracts receive one base row in `.14.3.1.1`; composite/rule-call effects
  form a transitive fixed point, including recursive SCCs, and the runtime restores before a dynamic violation.

  Invocation-mark/progress decision 2026-08-09: every rule entry receives a fresh monotonic invocation frame and
  mark generation. Its anonymous boundary begins from the caller-visible position, its marks begin empty, and
  child exit propagates only normal accepted cursor/result state; same-label recursive frames cannot alias marks.
  Rollback restores only the owning-frame cursor/boundary/mark snapshot, commit keeps its writes, and frame exit
  invalidates its mark generation. V1 progress is exactly `end_offset > start_offset` for each accepted repetition
  iteration and each accepted direct/mutual recursive cycle edge. One-shot zero-width recognition remains legal;
  rolled-back candidates and variable/mark/AST/transaction changes never satisfy progress; no decreasing-measure
  authoring escape hatch is selected.

  Surfaced frontier-drift evidence 2026-08-09: this file's node states plus central index, roadmaps, architecture,
  memory, and Knowledge all named `.14.3.1.0`, but its own free-form authoritative frontier still named
  `.14.2.0.1`. `git blame` assigns that paragraph to `bd777ee8`; later typed-source/transaction commits advanced
  real truth without updating it. `scripts/check_task_tree_metadata.sh` passed because its documented low-noise
  boundary checks frontier status cells only for top-level completed trees plus two pending-node contradictions.
  The immediate prose and stale top metadata are repaired here. `TASK-TREE-METADATA-HYGIENE.5` is reopened as the
  separate pending owner for a low-false-positive active-tree freshness invariant after this leaf lands cleanly;
  Knowledge card `active-task-frontier-prose-drift` preserves the causal fact.

  Lockstep/no-behavior evidence 2026-08-09: the working census contains only decision, Knowledge, task/index,
  roadmap/live continuity, and sole-facing book paths. No production/compiler/runtime source, `.spec`, test,
  executable neutral artifact/checker, fixture, schema, generated carrier, capability/semantic/MCP data, CLI,
  README, storage tool, hosted workflow, or current public result changes. ADR `0056` and Knowledge carry the
  canonical future contract; the book labels the exact syntax accepted but unavailable, and its rendered HTML
  preserves the heading, code block, match/result explanation, effect paragraph, and current-feature warning as
  separate elements. Executable neutral ownership remains `.14.3.1.1`.

  Final verification evidence 2026-08-09: `git diff --check`, the exact no-change census, Knowledge regeneration
  and freshness at 793 facts / 6,558 question keys, memory/task/README stability, all seven doctrines, focused
  typed-source and language-capability proofs, and a real 79-source-file mdBook build at 14,248 KiB pass; rendered
  transaction sections were inspected and the generated book was removed. The approved definitive local CI gate
  passes moved-root containment, every maintained mandatory runtime/contract consumer, primary CLI 66/66 under
  both default and POSIX option environments, RAM 58% below 88%, and Phase 0 1,031/1,031 in 672 wall-clock seconds,
  ending with exact `[ci] local CI gate passed` and exit zero. The guarded managed-run tool reports
  `found=0 removed=0 skipped=0`; no background job remains. Commit/brief/pointer/status evidence is completed by
  the mechanical commit workflow before any task-tree pivot.

- ID: `FUTURE-PARITY-BACKLOG.14.3.1.1`
  Status: `done; landed` (2026-08-10; task-tree-first from clean bounded-document closeout commit `c26a9556`;
    landed at `e0cc7182` as atomic 181/300; no push)
  Goal: Add the independently executable neutral transaction/progress artifact, checker, positive/negative
    fixtures, ActionIR/effect rows, rollout topology, and exact mutation corpus.
  Depends on: `.14.3.1.0`
  Acceptance: Encode the ratified authored/static contract as one versioned backend-neutral executable authority;
    bind exact dedicated node kinds, token/result state machine, complete ActionIR/canonical-call base effects,
    transitive rule effects, invocation-mark and cursor-only progress semantics, portable diagnostics, fixture
    identities, rollout ownership, and fail-closed mutation proof; register the neutral checker in focused and
    canonical governance without enabling grammar, compiler, runtime, backend, generated-source, CLI, public,
    storage-root, or hosted-workflow behavior; align durable/public owners; pass signoff and land clean before
    unchanged neutral recomposition `.14.3.1.2`.
  Verification: exact artifact/schema/checker/fixture topology and generated freshness; positive/negative token,
    falsey-result, effect, mark-frame, repetition, recursion, diagnostic, and mutation cases; ActionIR/call-contract
    census closure; rollout/canonical/storage no-drift; book, Knowledge, memory, task metadata, README, doctrines,
    definitive local CI, atomic commit 181/300, brief clearing, pointer validation, residue cleanup, and clean proof
  Commit: `FUTURE-PARITY-BACKLOG.14.3.1.1 - add neutral recognition transaction contract`

  ### `FUTURE-PARITY-BACKLOG.14.3.1.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove bounded-document closeout `.4` landed at clean `c26a9556`
    as atomic 180/300 with first parent `921f0507`, exact subject, zero-byte brief, valid post-commit pointer,
    absent rendered book, zero managed-run residue, and this task-tree part as the sole first activation mutation.
  - [x] **RETRIEVE / FREEZE NEUTRAL BOUNDARY** — Follow ADR `0056`, the canonical transaction Knowledge card,
    `.14.3.0-.14.3.1.0` evidence, toolbox probes, current ActionIR/call-contract authorities, neutral-artifact
    precedents, canonical registration, project-data routing, and sole-facing future/current claims before design.
  - [x] **VERSIONED EXECUTABLE AUTHORITY / FIXTURES** — Add one deterministic backend-neutral artifact with an
    independently implemented checker and exact positive/negative fixtures for the four dedicated forms, strict
    match versus staged payload, linear token lifecycle, invocation marks, and cursor-only repetition/recursion.
  - [x] **CLOSED EFFECT / DIAGNOSTIC GOVERNANCE** — Classify every current ActionIR node and all canonical call
    contracts exactly once, compute composite and named-rule effects to a recursive fixed point, reject unknowns,
    and bind portable token/effect/progress diagnostics without illustrative or open-ended rows.
  - [x] **ROLLOUT / MUTATION / CANONICAL PROOF** — Freeze neutral/backend/recurring/public ownership and reject
    schema, topology, node, token, result, effect, call-graph, mark, progress, fixture, diagnostic, rollout,
    registration, and freshness drift through an exact mutation corpus registered in mandatory canonical CI.
  - [x] **NO RUNTIME OR PUBLIC ACTIVATION** — Prove no grammar, compiler, runtime, backend, generated carrier,
    `.spec`, corpus, CLI, capability, semantic/MCP, README, storage root, hosted workflow, or current-public claim
    changes; backend RED and implementation remain exclusively in `.14.3.2+`.
  - [x] **LOCKSTEP / SOLE-FACING BOOK** — Synchronize task/index, ADR status, Knowledge, architecture, roadmaps,
    continuity roots, changes/notes, and the mdBook's explicitly future/unavailable contract with rendered review.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused artifact/mutation/topology/freshness/no-drift checks,
    book, Knowledge/memory/task/README, all doctrines, definitive canonical CI, atomic 181/300, zero-byte brief,
    post-pointer and residue checks, and clean proof before `.14.3.1.2` activates task-tree-first.

  #### TOOLBOX Task-Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Show the ratified transaction contract has no executable neutral artifact yet and
    current ActionIR/call authorities expose no complete fail-closed effect/progress/token contract.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Use descriptor/lowering/source and repository contract probes to identify
    exact current node/call/progress owners and why helper aliases, payload truthiness, or sample effects are invalid.
  - [x] **FIX** — Implement only the independent neutral authority, checker, fixtures, topology, and mutations.
  - [x] **ADDRESSED (verified)** — Prove every accepted form/state/effect/mark/progress/diagnostic/rollout obligation
    is represented once and every rejected family fails deterministically.
  - [x] **NO REGRESSION** — Preserve current executable behavior, schemas, public surfaces, storage, and toolchains.
  - [x] **LOCKSTEP** — Land the exact artifact contract, task/public explanation, atomic commit, and clean handoff.

  Retrieval/reproduction evidence 2026-08-10: the clean parent has no
  `capability_conformance/recognition_transaction_contract.json` or matching checker. Knowledge-first retrieval
  followed ADR `0056`, the authored transaction and typed-source cards, `.14.3.0-.14.3.1.0`, neutral checker
  precedents, canonical/project-data owners, and the sole-facing book before design. Live source derives 128 unique
  current ActionIR node kinds; `tools/check_language_capability_coverage.pl --report` separately derives 246
  current cross-backend call names and 122 public identifier-shaped Perl contracts. The counts are different
  domains, so the durable neutral-contract card records the distinction rather than propagating a false 122-node
  assumption.

  Toolbox mechanism evidence 2026-08-10: `return_descriptor` reports canonical `RETURN` for an exact action;
  `call_spec_handler_subst` rejects the retired aggregate-selector spelling with `aggregate_selector_removed`;
  and `dump_parser_source` yields a 10,449-byte current handler containing direct `$IPOS`/mark/cursor machinery but
  no transaction state/effect/progress owner. `CALL` and ordinary falsey return payloads expose no separate
  authored accepted-bit channel. These mechanisms prove helper aliases, eager payload truthiness, or an
  illustrative sample-effect list cannot implement the ratified contract.

  Neutral implementation evidence 2026-08-10: `linkedspec-recognition-transaction-v1` encodes the four exact
  future forms, five-state token model, strict match/staged-payload separation, closed 9/11 effects, 128 current +
  four dedicated node rows, all 246 call rows, six recursive fixed-point effect graphs, invocation mark snapshots,
  cursor-only progress, fifteen diagnostics, nine exact rollout legs, and 40 named mutations. The independent
  checker re-derives live inventories, locks the base classification digests, executes token 8 positive / 17
  negative, marks 6, progress 8, rejects all 40 mutations, and is tracked/unconditionally routed through canonical
  project-local Python execution. Focused execution passes at neutral 1/9 complete.

  No-activation evidence 2026-08-10: the implementation census contains only the neutral artifact/checker,
  canonical registration/storage-entrypoint governance, task/index, ADR/Knowledge/architecture/roadmap/live
  documentation, capability guide, toolbox, and sole-facing book. It changes no grammar, compiler/runtime/backend,
  generated carrier, `.spec`/corpus, CLI, capability ledger, semantic/MCP surface, README, storage root, or hosted
  workflow. Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, recurring, and public legs stay exact RED owners.

  Final verification evidence 2026-08-10: focused artifact, mutation, inventory, language, storage, Knowledge,
  memory, task, README, doctrine, and real 79-source-file mdBook proofs pass, including rendered inspection and
  generated-book removal. The host-authorized definitive canonical gate passes all eight doctrines, the exact
  repository-contained six-family process-I/O proof, moved-root execution, primary CLI 66/66 in both default and
  POSIX option environments, RAM 55% below the 88% threshold, and Phase 0 1,031/1,031 in 675 wall-clock seconds,
  ending with `[ci] local CI gate passed`. The first sandboxed attempt reached the process-I/O proof but the outer
  harness denied its nested `sandbox-exec`; the unchanged host-authorized rerun passed that proof and the full gate.
  Commit, zero-byte brief, post-pointer, residue, absent-book, and clean-status evidence are completed mechanically
  before the next task-tree activation.

- ID: `FUTURE-PARITY-BACKLOG.14.3.1.2`
  Status: `done; landed` (2026-08-10; task-tree-first from clean neutral-authority commit `e0cc7182`; landed at
    `774516fa` as atomic 182/300; no push)
  Goal: Recompose the committed neutral authority and truthful public-future boundary unchanged before Perl RED.
  Depends on: `.14.3.1.1`
  Acceptance: Prove the committed recognition-transaction artifact, independent checker, live-derived inventories,
    canonical/storage registration, authored/static decision, Knowledge owners, rollout truth, and sole-facing
    future/current teaching compose unchanged except for an exact rendered-review correction if a stale milestone
    sequence contradicts the committed neutral state. Add no replacement artifact, checker, fixture, mutation, grammar,
    compiler, runtime, backend, generated carrier, `.spec`/corpus, CLI, schema, capability/semantic/MCP surface,
    storage root, hosted workflow, README, or current-public capability claim. If rendered review finds an
    enforcement gap, preserve its cause and open a separate guard leaf rather than widening this recomposition.
    Hand off cleanly to that guard, which alone may close `.14.3.1` before Perl RED `.14.3.2.0`.
  Verification: clean activation; Knowledge-first owner retrieval; committed-byte/no-replacement census; exact
    recognition checker and independent language inventories; canonical/storage route identity; public-current
    marker census; rendered mdBook review; Knowledge, memory, task metadata, README, doctrines, canonical CI,
    atomic commit 182/300, brief clearing, post-pointer, residue, absent-book, and clean-status proof
  Commit: `FUTURE-PARITY-BACKLOG.14.3.1.2 - repair neutral transaction status boundary`

  ### `FUTURE-PARITY-BACKLOG.14.3.1.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.3.1.1` landed atomically at `e0cc7182` as 181/300 with
    first parent `c26a9556`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer, fresh
    Knowledge, absent rendered book, zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / FREEZE RECOMPOSITION BOUNDARY** — Follow ADR `0056`, both transaction Knowledge cards,
    `.14.3.1.0-.1`, the committed artifact/checker and registration/storage owners, and sole-facing claims before
    running proof; reject replacement implementation or premature backend/public rollout.
  - [x] **COMMITTED NEUTRAL RECOMPOSITION** — Re-run the independent checker and live inventories; prove exact
    132 = 128 + 4 ActionIR rows, 246 call rows, token 8/17, graphs 6, marks 6, progress 8, diagnostics 15,
    40 mutations, and neutral 1/9 rollout without changing any executable owner.
  - [x] **NO-REPLACEMENT / PUBLIC-FUTURE CENSUS** — Prove committed artifact/checker/registration bytes and all
    grammar, compiler, runtime, backend, generated, CLI, schema, capability/semantic/MCP, README, storage, hosted,
    and public-current capability surfaces remain unchanged while the exact authored contract remains future-only;
    permit only the exact stale sequencing correction surfaced by rendered inspection.
  - [x] **ROOT-CAUSE / TRACK SEQUENCE DRIFT** — Trace any stale milestone sentence to its introducing and missed-
    update commits, correct it narrowly, preserve the causal fact in Knowledge/task evidence, and open guard leaf
    `.14.3.1.2.0` without changing the neutral checker or its exact 40-mutation contract in this slice.
  - [x] **LOCKSTEP / GUARDED HANDOFF** — Synchronize task/index, ADR/Knowledge, architecture, roadmaps,
    changes/notes, live/memory, and sole-facing book to the verified state; hand one clean next action to public-
    sequence guard `.14.3.1.2.0` without closing `.14.3.1` or activating Perl RED early.
  - [x] **VERIFY / COMMIT / CLEAN HANDOFF** — Pass focused and canonical proofs, rendered-book inspection,
    Knowledge/memory/task/README/doctrines, atomic 182/300, zero-byte brief, pointer/residue/absent-book checks, and
    clean status before `.14.3.2.0` activates task-tree-first.

  Activation evidence 2026-08-10: neutral-authority leaf `.14.3.1.1` lands atomically at full commit
  `e0cc71825b76548bb27ce01a66170ac00bd2406e` as 181/300 with first parent `c26a9556` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.1.1 - add neutral recognition transaction contract`. Its hook regenerates Knowledge
  at 801 facts / 6,629 question keys, passes all eight doctrines, and validates `activation_commit c26a9556`
  against `HEAD^1`. Post-commit memory-pointer and Knowledge checks pass; status and staged/unstaged diffs are
  empty; the ignored brief is zero bytes; generated book output is absent; managed-run recovery reports
  `found=0 removed=0 skipped=0`; and no background job remains. This task-tree file is the sole first activation
  mutation before index, evidence, public/durable status, or any other closeout change.

  Rendered-review finding 2026-08-10: the built capture/source page first says the neutral authority is executable,
  then two paragraphs later says “The neutral artifact/checker is next.” `git blame` assigns the stale sentence to
  ratification commit `7c2ff407`; implementation commit `e0cc7182` added the new executable-authority paragraph but
  did not update that older milestone-order sentence. The neutral checker governs its artifact's current-behavior
  boundary and exact 40 mutations, but it has no governed public milestone-sequence projection, so focused and
  canonical checks could not reject the contradiction. This leaf owns the exact prose repair and durable cause;
  `.14.3.1.2.0` separately owns a fail-closed public-sequence guard before Perl RED.

  Retrieval/recomposition evidence 2026-08-10: Knowledge-first review followed the neutral and authored contract
  cards into ADR `0056`, `.14.3.1.0-.1`, the JSON/checker, canonical and project-data registration, capability
  guide, toolbox, roadmaps, architecture, and all three sole-facing transaction passages. Before the rendered
  repair, `git rev-parse HEAD:<path>` and `git hash-object <path>` agreed for the artifact (`b292d8ca`), checker
  (`04e306be`), canonical driver (`ac661674`), storage proof (`0df08efc`), ADR, both Knowledge cards, and all three
  book sources. The unchanged checker passes 132 = 128 + 4 ActionIR rows, 246 call rows, token 8/17, six fixed-point
  graphs, six marks, eight progress cases, fifteen diagnostics, 40 rejected mutations, and rollout neutral 1/9.
  Independent language coverage remains 246 current names / 105+1 fixtures / 122 public Perl contracts, and the
  complete tool project-data proof passes without changing an executable owner.

  Public-boundary/render evidence 2026-08-10: direct HTML exposed the exact contradictory paragraph and `git blame`
  proved the `7c2ff407` introduction / `e0cc7182` missed-update chain. Only the stale capture/source sentence now
  changes: it says the neutral artifact/checker is executable while Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
  still require independent admission. Backend-handoff remains “neutral proof is not backend support”; project
  status remains 1/9 with every runtime, recurring, and public leg RED. The rebuilt book contains 79 files / 14,356
  KiB; the heading, checker command, target-only warning, corrected future/current paragraph, and following scope
  paragraph render as separate elements. `neutral artifact/checker is next` is absent, generated output is removed,
  and Knowledge regenerates to 802 facts / 6,633 question keys. No neutral artifact/checker/registration, grammar,
  compiler, runtime, backend, generated carrier, fixture, CLI, schema, capability/semantic/MCP, README, storage,
  hosted-workflow, or current authored-capability path changes.

  Definitive signoff evidence 2026-08-10: the staged-intent slice passes exact neutral/language/storage/public-
  boundary proofs, Knowledge 802/6,633, task metadata at 511 stable IDs, memory 58/60, README 105/5,057, document
  pressure, whitespace, and all eight doctrines. The host-authorized canonical gate passes the repository-contained
  relocated six-family process proof, moved-root Rust plus four outside-CWD anchors, every mandatory typed-source,
  MCP, semantic, cursor, contract, and focused Perl consumer, both primary CLI environments at 66/66, RAM 59%
  below the 88% threshold, and Phase 0 1,031/1,031 in 695 wall-clock seconds. It ends with exact
  `[ci] local CI gate passed` and exit zero. Atomic commit, brief clearing, post-pointer, Knowledge freshness,
  managed-run recovery, absent rendered book, and clean status complete mechanically before `.14.3.1.2.0` activates.

- ID: `FUTURE-PARITY-BACKLOG.14.3.1.2.0`
  Status: `done; signoff-complete` (2026-08-10; task-tree-first from clean public-boundary repair commit
    `774516fa`; intended atomic 183/300; no push; atomic commit/clean handoff pending)
  Goal: Add a fail-closed governed public milestone-sequence projection that rejects stale neutral-next claims,
    recompose the corrected boundary unchanged, close `.14.3.1`, and hand one clean next action to Perl RED.
  Depends on: `.14.3.1.2`
  Acceptance: Extend the existing recognition-transaction oracle with an independently counted public-sequence
    projection over an exact public-document inventory. Derive neutral/backend rollout truth from the committed
    artifact; require current executable-neutral, unavailable-authored-form, independent-backend-admission, and
    neutral-not-backend-support markers; reject stale neutral-next wording, false current capability, missing or
    duplicate paths/markers, inventory drift, and rollout contradiction through an exact in-memory mutation corpus.
    Keep the semantic artifact and its 40 mutations byte-exact, reuse the existing tracked/canonical/project-data
    route, change no grammar/compiler/runtime/backend/generated/fixture/CLI/schema/capability/semantic/MCP/README/
    storage-root/hosted-workflow behavior, recompose rendered public truth, close `.14.3.1`, and land clean before
    Perl RED `.14.3.2.0`.
  Verification: clean activation; Knowledge-first cause/owner retrieval; exact public inventory/marker design;
    positive and mutation proof with byte-exact semantic artifact; checker syntax/style/storage/canonical freshness;
    rendered mdBook and stale/current marker census; neutral/language/capability no-drift; Knowledge, memory, task,
    README, doctrines, canonical CI, atomic commit 183/300, brief clearing, pointer/residue/book/status clean proof
  Commit: `FUTURE-PARITY-BACKLOG.14.3.1.2.0 - govern transaction public sequence`

  ### `FUTURE-PARITY-BACKLOG.14.3.1.2.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.3.1.2` landed atomically at `774516fa` as 182/300 with
    first parent `e0cc7182`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer, fresh
    Knowledge, absent rendered book, zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / FREEZE PUBLIC-SEQUENCE BOUNDARY** — Follow the sequence-drift Knowledge card, ADR `0056`,
    `.14.3.1.1-.2`, the neutral artifact/checker, public-contract precedents, canonical/storage routes, and all
    current transaction passages before choosing paths, markers, forbidden claims, or mutation families.
  - [x] **FAIL-CLOSED PUBLIC PROJECTION** — Require one exact public inventory and marker matrix derived against
    artifact rollout truth; reject missing/duplicate/unknown paths or markers, stale neutral-next text, false
    current/backend capability, and rollout contradiction without weakening the semantic contract.
  - [x] **INDEPENDENT MUTATION / ROUTING PROOF** — Execute every public-sequence mutation in memory, keep the JSON
    and its exact 40 semantic mutations byte-identical, and prove the extended checker remains tracked,
    unconditionally canonical, repository-storage routed, fresh, and non-dormant.
  - [x] **RECOMPOSE / CLOSE PARENT** — Rebuild and inspect the corrected book, prove all three public pages and
    durable/live owners agree, close `.14.3.1`, and leave every runtime/recurring/public rollout leg RED.
  - [x] **NO REGRESSION / COMMIT-READY HANDOFF** — Pass focused and canonical proof, prepare exact atomic 183/300,
    and require zero-byte brief, pointer/Knowledge/residue/absent-book, and clean-status proof before `.14.3.2.0`
    activates task-tree-first.

  Activation evidence 2026-08-10: public-boundary repair `.14.3.1.2` lands atomically at full commit
  `774516faa7261cc2ccdacf793747373618458d7b` as 182/300 with first parent `e0cc7182` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.1.2 - repair neutral transaction status boundary`. Its hook regenerates Knowledge at
  802 facts / 6,633 question keys, passes all eight doctrines, and validates `activation_commit e0cc7182` against
  `HEAD^1`. Post-commit pointer and Knowledge checks pass; status and staged/unstaged diffs are empty; the ignored
  brief is zero bytes; generated book output is absent; managed-run recovery reports `found=0 removed=0 skipped=0`;
  and no background job remains. This task-tree file is the sole first activation mutation before index, checker,
  public, or durable-status changes.

  Implementation evidence 2026-08-10: Knowledge-first retrieval followed the sequence-drift and neutral-contract
  cards to ADR `0056`, the exact three sole-facing transaction pages, the committed JSON/checker, and the existing
  unconditional canonical/project-data route before implementation. The checker now derives neutral-complete and
  every-non-neutral-RED public truth from the artifact; requires one exact three-document inventory, exact-once
  executable/future/unavailable/admission markers, tracked-file proof, and eight forbidden stale/current claims;
  and rejects thirteen independently executed inventory/marker/claim/text/rollout mutations. Public mutation
  accounting remains separate from the unchanged forty semantic mutations. The JSON working file and `HEAD` are
  byte-identical at SHA-256 `f2c4f231282cdb4966a14f551c19869fe8edb7c5097ed5b5a3d35b47ccc93248`;
  the existing checker path, canonical registration, invocation, and project-data topology are unchanged. Focused
  checker syntax, exact output, tool-storage, language 246 / fixtures 105+1 / public Perl contracts 122, and
  capability 80/0/0 proofs pass. The rebuilt book contains 79 files / 14,356 KiB; direct HTML inspection confirms
  the guard as a distinct paragraph, the repaired executable-neutral sequence, neutral-not-backend-support, and
  1/9 RED status. Generated book output is removed.

  Definitive signoff evidence 2026-08-10: Knowledge is synchronized at 802 facts / 6,633 question keys; task
  metadata remains 511 stable IDs; memory stays within 58/60 lines; README is unchanged at 105/128 lines and
  5,057/6,144 bytes; bounded-history pressure, whitespace, and all eight doctrines pass. The host-authorized
  canonical gate passes every mandatory neutral, typed-source, semantic, MCP, cursor, capability, focused Perl,
  and storage consumer; the repository-contained relocated six-family process proof; moved-root Rust plus four
  outside-CWD anchors; and both primary CLI environments at 66/66. RAM is 68% below the 88% ceiling and Phase 0
  passes 1,031/1,031 in 672 wall-clock seconds before exact `[ci] local CI gate passed` and exit zero. Parent
  `.14.3.1` is composition-closed with neutral rollout 1/9 and every runtime/recurring/public leg still RED. Atomic
  commit 183/300, zero-byte brief, post-pointer, Knowledge freshness, managed-run recovery, absent-book, and clean
  status complete mechanically before Perl RED `.14.3.2.0` activates.

- ID: `FUTURE-PARITY-BACKLOG.14.3.2`
  Status: `complete` (2026-08-10; all four Perl recognition-transaction leaves are composition-complete through
    signoff-complete admission `.14.3.2.3`, commit-ready as atomic 187/300; Rust RED `.14.3.3.0` next; no push)
  Goal: Implement and independently admit the bounded recognition-only transaction/progress contract in the Perl
    reference without changing unrelated action, result, register, or rollback semantics.
  Depends on: `.14.3.1.2.0`
  Children: `.14.3.2.0-.14.3.2.3`

- ID: `FUTURE-PARITY-BACKLOG.14.3.2.0`
  Status: `complete` (2026-08-10; dormant Perl RED and definitive signoff complete from clean
    public-sequence/neutral-parent closeout `77872bfe` as atomic 184/300; no push)
  Goal: Freeze dormant Perl RED for tokens, recursive same-label mark frames, recognition attempts, effect barriers,
    progress diagnostics, source generation, and unchanged compatibility controls.
  Depends on: `.14.3.1.2.0`
  Acceptance: Retrieve the neutral transaction and cursor/runtime Knowledge owners, ADR `0056`, exact JSON/checker,
    current Perl ActionIR/compiler/runtime/generated-source seams, toolbox probes, existing dormant-RED precedents,
    and canonical/storage registration before writing tests. Freeze one tracked but canonically dormant Perl RED
    consumer that derives its expectations from the neutral artifact and covers all four authored forms, strict
    match/payload separation including falsey payloads, linear token lifetime/escape/nesting/cross-boundary rules,
    exactly-one static `call(Rule)` attempt, closed direct/transitive effect rejection, commit/rollback cursor and
    invocation-mark behavior including recursive same-label generations, repetition/recursive cursor-only progress,
    fifteen structured diagnostics, unchanged compatibility save/restore controls, and independently emitted source.
    Prove the consumer fails only at the intended unavailable grammar/implementation boundary; keep it absent from
    canonical invocation until `.14.3.2.3`; change no production grammar/compiler/runtime/backend/generated carrier,
    neutral artifact/checker, capability/semantic/MCP/CLI/schema, public-current claim, README, storage root, or
    hosted workflow; land clean before private Perl authority `.14.3.2.1` activates.
  Verification: clean activation; Knowledge/toolbox-first retrieval; exact current Perl source/runtime probes;
    neutral-derived consumer inventory and expectation audit; syntax plus deterministic intended RED evidence;
    compatibility and current-suite no-drift; tracked-but-dormant canonical/storage proof; Knowledge, memory, task,
    README, history, doctrines, canonical CI, atomic commit 184/300, brief clearing, pointer/residue/book/status clean
  Commit: `FUTURE-PARITY-BACKLOG.14.3.2.0 - freeze Perl transaction RED`

  ### `FUTURE-PARITY-BACKLOG.14.3.2.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.3.1.2.0` landed atomically at `77872bfe` as 183/300 with
    first parent `774516fa`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer, fresh
    Knowledge, absent rendered book, zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / PROBE CURRENT PERL BOUNDARY** — Follow Knowledge, ADR, neutral artifact/checker, toolbox, and
    dormant-RED precedents before using LinkedSpec probes to locate exact grammar/lowering/runtime/generated seams.
  - [x] **FREEZE NEUTRAL-DERIVED RED CONSUMER** — Add one exact tracked consumer covering syntax, tokens, attempts,
    effects, marks/recursion, progress, diagnostics, compatibility controls, and independently emitted source.
  - [x] **PROVE INTENDED DORMANCY** — Show syntax is valid, the consumer fails deterministically only because the
    transaction forms are unavailable, and it is absent from canonical invocation until Perl admission `.14.3.2.3`.
  - [x] **NO PRODUCTION OR PUBLIC MOVEMENT** — Prove all implementation, neutral, capability, semantic/MCP, CLI,
    README, storage, hosted-workflow, and current public transaction-support owners remain unchanged/RED.
  - [x] **NO REGRESSION / COMMIT-READY HANDOFF** — Pass focused/current/canonical proof, prepare atomic 184/300, and
    require brief/pointer/Knowledge/residue/absent-book/clean-status proof before `.14.3.2.1` activates task-tree-first.

  Activation evidence 2026-08-10: public-sequence guard `.14.3.1.2.0` lands atomically at full commit
  `77872bfe1bc57284f3198778d786c3a404e958b2` as 183/300 with first parent `774516fa` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.1.2.0 - govern transaction public sequence`. Its hook regenerates Knowledge at 802
  facts / 6,633 question keys, passes all eight doctrines, and validates `activation_commit 774516fa` against
  `HEAD^1`. Post-commit pointer and Knowledge checks pass; status and staged/unstaged diffs are empty; the ignored
  brief is zero bytes; generated book output is absent; managed-run listing reports `found=0 removed=0 skipped=0`;
  and no background job remains. This task-tree file is the sole first activation mutation before index, consumer,
  probes, or durable-status changes.

  Retrieval/probe evidence 2026-08-10: Knowledge lookup followed `cursor-transaction-safety-audit-plan`,
  `cursor-transaction-authored-contract`, `recognition-transaction-neutral-contract`,
  `perl-generated-source-contract-v2`, and the typed-source dormant-RED precedents before code/runtime probing.
  ADR `0056`, the exact JSON/checker, relevant Toolbox descriptor/lowering/generated-source/runtime-context probes,
  and existing final-path dormant consumers were read before the test was written. `call_spec_handler_subst`
  proves checkpoint, attempt, and commit become `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER` sentinels while rollback
  remains raw; compatibility `save_cursor`/`restore_cursor` still route through the typed source-location core.
  Exact `return_descriptor` construction succeeds rather than rejecting grammar. Its Top action reports
  `language_agnostic_action_ir_ready=0`, three unresolved helpers, one raw dependency, and no dedicated
  `RECOGNITION_CHECKPOINT`, `RECOGNIZE_ONCE`, `RECOGNITION_COMMIT`, or `RECOGNITION_ROLLBACK` nodes. Live execution
  reaches the same raw rollback boundary as a structured runtime-handler error; no exception escapes.

  Consumer/dormancy evidence 2026-08-10: final-path `t/recognition_transaction_perl_contract.t` syntax-checks and
  derives all four authored forms, 8 positive / 17 negative token fixtures, six effect graphs, six mark cases,
  eight progress cases, exact 9/11 effects, and all fifteen diagnostics from the neutral artifact. It passes 49
  assertions, fails exactly one assertion requiring the four dedicated language-agnostic nodes, and skips one
  future live/generated-source subtest. Repeated execution reports the byte-stable boundary: four missing nodes,
  unresolved helpers `[recognition_checkpoint,recognition_commit,recognize_once]`, and one raw dependency. The
  skipped body freezes falsey/miss/commit/rollback, cursor/mark state, unchanged compatibility cursor-stack
  controls, and independently emitted/loaded execution without creating a second current implementation.
  `tools/run_ci_local.sh` and all other ordinary/canonical registries contain zero references to the consumer;
  `.14.3.2.3` remains the sole admission owner.

  No-drift evidence 2026-08-10: the independent neutral oracle remains green at 132 ActionIR rows / 246 calls /
  token 8+17 / graphs 6 / marks 6 / progress 8 / diagnostics 15 / 40 semantic mutations plus the separate
  three-page/eight-forbidden/thirteen-mutation public sequence. Current typed-source values/projections,
  complete named marks, and generated-source tests pass together. Diffs contain no production Perl, grammar,
  neutral artifact/checker, canonical driver, capability/semantic/MCP/CLI/schema, README, storage, workflow, or
  mdBook source change. Knowledge card `perl-recognition-transaction-dormant-red` makes the exact causal boundary
  retrievable; the derived map advances to 803 facts / 6,643 question keys.

  Definitive signoff evidence 2026-08-10: the staged final-path consumer remains tracked but absent from every
  ordinary/canonical registry and keeps its deterministic 49-pass / one-fail / one-skip RED boundary. The complete
  host-authorized canonical gate passes all eight doctrines; every mandatory neutral, typed-source, semantic, MCP,
  cursor, capability, focused Perl, and storage consumer; repository-contained six-family process I/O; moved-root
  Rust plus four outside-CWD runtime anchors; and both primary CLI option environments at 66/66. RAM is 69% against
  the 88% ceiling, and Phase 0 passes 1,031/1,031 in 672 wall-clock seconds before the exact
  `[ci] local CI gate passed` marker. Production/public/mdBook inputs remain byte-unchanged, the real 79-file /
  14,356-KiB rendered book was inspected deterministically and removed, and no generated book output remains.
  Knowledge is synchronized at 803 facts / 6,643 question keys; memory stays at 60/60 lines; README remains
  105 lines / 5,057 bytes; task metadata, bounded-history pressure, whitespace, and all eight doctrines pass.
  Atomic 184/300 is commit-ready with `.14.3.2.1` retained as the next task-tree-first activation.

- ID: `FUTURE-PARITY-BACKLOG.14.3.2.1`
  Status: `complete` (2026-08-10; private authority implementation and definitive signoff complete from clean
    dormant-RED closeout `59306f37` as intended atomic 185/300; authored integration `.14.3.2.2` next; no push)
  Goal: Add private Perl invocation-frame, mark-generation, opaque-token, snapshot, and invalidation authority while
    leaving authored/current routes dormant.
  Depends on: `.14.3.2.0`
  Acceptance: Retrieve the neutral transaction, dormant Perl RED, cursor/runtime-context, named-mark, generated-
    source, and transaction-safety Knowledge owners plus ADR `0056` and Toolbox probes before implementation.
    Introduce one private Perl authority for invocation generations, same-label mark generations, opaque linear
    tokens, cursor/mark snapshots, separately staged match/payload state, exactly-once attempt state, and terminal
    commit/rollback invalidation. Keep the authority unreachable from authored grammar, ActionIR lowering, public
    runtime helpers, generated carriers, ordinary/canonical transaction admission, and public-current claims.
    Prove falsey payload preservation, miss state, nested/cross-invocation/token misuse rejection, recursive
    same-label isolation, commit/rollback restoration, and unchanged compatibility cursor-stack behavior through
    focused private tests. Change no neutral artifact/checker, grammar/compiler/ActionIR/generated source, backend
    ledger, CLI/schema/semantic/MCP/capability surface, README, storage root, hosted workflow, or current public
    behavior; land clean before authored/compiler/runtime integration `.14.3.2.2` activates task-tree-first.
  Verification: clean activation; Knowledge/toolbox-first retrieval; exact current runtime/context/mark ownership
    probes; focused private authority syntax/unit/lifecycle/misuse proof; dormant RED byte-result unchanged;
    compatibility/current-suite no-drift; canonical/storage/public source unchanged; Knowledge, memory, task,
    README, history, doctrines, canonical CI, atomic commit 185/300, brief clearing, pointer/residue/book/status clean
  Commit: `FUTURE-PARITY-BACKLOG.14.3.2.1 - add private Perl transaction authority`

  ### `FUTURE-PARITY-BACKLOG.14.3.2.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.3.2.0` landed atomically at `59306f37` as 184/300 with
    first parent `77872bfe`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer, fresh
    Knowledge, absent rendered book, zero managed-run residue, and this task-tree file as the sole activation diff.
  - [x] **RETRIEVE / PROBE PRIVATE OWNER SEAMS** — Follow the transaction, cursor, mark, runtime-context, dormant-
    RED, generated-source, ADR, and Toolbox owners before locating the narrow private authority integration seam.
  - [x] **IMPLEMENT PRIVATE TRANSACTION AUTHORITY** — Add one unreachable private owner for invocation/mark
    generations, opaque tokens, snapshots, staged match/payload, exactly-once attempts, and terminal invalidation.
  - [x] **PROVE LIFECYCLE / MISUSE CONTRACT** — Lock falsey/miss/commit/rollback, recursion and same-label marks,
    nested/cross-invocation misuse, stale/double/escaped token rejection, and compatibility-stack independence.
  - [x] **PRESERVE DORMANCY / PUBLIC BOUNDARY** — Keep the final-path RED byte-stable at its exact four-node
    boundary and change no authored, lowering, generated, canonical-admission, capability, or public-current route.
  - [x] **NO REGRESSION / COMMIT-READY HANDOFF** — Pass focused/current/canonical proof, prepare atomic 185/300, and
    require brief/pointer/Knowledge/residue/absent-book/clean-status proof before `.14.3.2.2` activates task-tree-first.

  Activation evidence 2026-08-10: dormant Perl RED `.14.3.2.0` lands atomically at full commit
  `59306f372e742a9e815c9b409d4502a8533b0fbd` as 184/300 with first parent `77872bfe` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.2.0 - freeze Perl transaction RED`. Its hook regenerates Knowledge at 803 facts /
  6,643 question keys, passes all eight doctrines, and validates `activation_commit 77872bfe` against `HEAD^1`.
  Post-commit pointer and Knowledge checks pass; status and staged/unstaged diffs are empty; the ignored brief is
  zero bytes; generated book output is absent; managed-run listing reports `found=0 removed=0 skipped=0`; and no
  background job remains. This task-tree file is the sole first activation mutation before index, probes, private
  implementation, tests, or durable-status changes.

  Retrieval/probe evidence 2026-08-10: Knowledge lookup followed `cursor-transaction-safety-audit-plan`,
  `cursor-transaction-authored-contract`, `recognition-transaction-neutral-contract`,
  `perl-recognition-transaction-dormant-red`, `complete-named-mark-perl-rust-parity`, and
  `perl-rule-local-cursor-rollout-boundaries` before source inspection. ADR `0056` transaction sections and
  Toolbox lowering/descriptor/runtime-context/generated-source probes were retrieved. The exact lowering probe
  still emits compatibility cursor-stack save/restore; a corrected scalar-reference runtime probe leaves
  `cursor_stack` and `last_error` absent; the current mark/cursor/generated suite passes 94 tests. The first probe
  intentionally failed input validation because it passed a scalar rather than the required scalar reference;
  the corrected probe passed, so no engine defect or expectation change was inferred.

  Implementation evidence 2026-08-10: new private `perl/LinkedSpec/RecognitionTransaction.pm` uses inside-out
  scalar handles for one source authority, invocation frame, and linear token. Monotonic non-reused invocation ids,
  mark generations, and transaction ids bind fresh same-label recursive mark tables plus cursor/boundary/mark
  snapshots. Attempt state separates one strict match bit from staged payload presence/value; commit invalidates
  before returning falsey-safe payload, while rollback and every dynamic misuse restore before invalidation.
  Typed immutable diagnostics expose only the exact neutral scalar fields. Frame/token/authority destruction also
  fails safe by restoring/invalidation and removing private stack ownership without emitting from destructors.

  Focused lifecycle/no-drift evidence 2026-08-10: `t/recognition_transaction_perl_authority.t` derives its
  fixture and diagnostic authority from the neutral JSON and passes 293 nested TAP assertions across opaque scalar
  storage, monotonic recursion frames, all eight positive token cases, all eight explicit escape classes, stale
  generations, retry/missing/double terminal, nesting, strict boolean, cross-invocation/source restoration, and
  compatibility-stack isolation. The initial test expected a missed commit to retain matched candidate state;
  neutral semantics require unchanged miss state, and the implementation already behaved correctly, so only that
  expectation was repaired. Canonical CI now tracks, syntax-checks, and executes this private unit consumer without
  registering the final-path dormant RED. Neutral remains 132/246, token 8/17, graphs 6, marks 6, progress 8,
  diagnostics 15, mutations 40, rollout 1/9, and public sequence 3/8/13. The dormant consumer remains byte-unchanged
  at 49 pass / one exact four-node failure / one skip; public facade, compiler, SpecEntry, RuntimeContext, ActionIR,
  GeneratedSource, README, capability/semantic/MCP/CLI/schema, and current authored behavior remain unchanged.

  Definitive signoff evidence 2026-08-10: the focused six-file current suite passes 112 tests, while the separately
  executed final-path consumer retains exactly 49 pass / one missing-four-node failure / one skip and remains absent
  from every ordinary/canonical registry. The neutral/public oracle remains 132/246, token 8/17, graphs 6, marks 6,
  progress 8, diagnostics 15, semantic mutations 40, rollout 1/9, and public sequence 3/8/13. The real rendered book
  contains 79 files / 14,356 KiB; deterministic HTML inspection proves the private-foundation/current-RED boundary,
  then exact generated output is removed. Knowledge is synchronized at 804 facts / 6,653 question keys; memory is
  60/60 lines; README remains 105 lines / 5,057 bytes; task partitions retain 511 stable ids; bounded history,
  whitespace, metadata, and all eight doctrines pass. The host-authorized canonical gate passes tracked-input and
  path audits, private authority execution, all six runtime admissions, repository-contained process I/O,
  moved-root plus four outside-CWD anchors, both primary CLI environments at 66/66, RAM 71% below the 88% ceiling,
  and Phase 0 at 1,031/1,031 in 688 wall-clock seconds before exact `[ci] local CI gate passed`. Atomic 185/300 is
  commit-ready with `.14.3.2.2` retained as the next task-tree-first activation.

- ID: `FUTURE-PARITY-BACKLOG.14.3.2.2`
  Status: `complete` (`e173bbcb`, 2026-08-10, atomic 186/300, no push; activated task-tree-first from clean
    private-authority closeout `8138bea5`, then completed implementation, focused proof, durable synchronization,
    rendered review, canonical signoff, commit, and clean handoff)
  Goal: Integrate the ratified Perl syntax, once-only recognition, staged result, static/runtime effect barrier,
    invocation marks, structured progress failures, and independently emitted generated source.
  Depends on: `.14.3.2.1`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.2.2 - integrate Perl recognition transactions`

  ### `FUTURE-PARITY-BACKLOG.14.3.2.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNER RETRIEVAL** — Prove private authority `.14.3.2.1` landed atomically at full
    commit `8138bea5718198e1a7ce89599c1ae84618dc5211`, activate only this leaf from its clean closeout, and retrieve
    the canonical ActionIR scanner/contract/canonical-event/rewrite owners, post-rule-table compiler validation
    seam, shared handler preamble and match-emission seams, runtime-context diagnostics, source-location mark
    authority, generated-source v2 carrier, private transaction authority, neutral JSON/checker, ADR 0056, and
    dormant final-path consumer before re-deriving or changing behavior.
  - [x] **FOUR DEDICATED ACTIONIR NODES / EXACT AUTHORED SHAPES** — Add scanner and lowering ownership for only
    `tx = recognition_checkpoint()`, `matched = recognize_once(tx, call(StaticRule))`,
    `payload = recognition_commit(tx)`, and statement-only `recognition_rollback(tx)`. Emit exactly
    `RECOGNITION_CHECKPOINT`, `RECOGNIZE_ONCE`, `RECOGNITION_COMMIT`, and `RECOGNITION_ROLLBACK`, preserve the
    static callee and direct bare local slots in canonical event arguments, prevent generic assignment/call
    rewrites from eagerly evaluating the operand or duplicating assignment nodes, and leave malformed/dynamic
    operands fail-closed with portable recognition diagnostics.
  - [x] **STATIC LINEARITY / EFFECT FIXED POINT** — Validate after the complete compiled rule table exists: one
    opaque token slot, exactly one attempt, an exact same-token terminal on every admitted structured path, no
    token escape or nesting, and an existing static callee. Classify every canonical ActionIR node through the
    neutral 132-node effect inventory, union named-rule effects transitively to a recursive fixed point, admit
    only the nine neutral effects, and reject forbidden or unknown effects before recognition with the exact
    portable `code/rule/origin/effect` fields. Do not promote Perl rollout or public-current availability.
  - [x] **INVOCATION / FALSEY-SAFE RUNTIME** — Bind one source-local transaction authority to handler-source
    invocation guards shared by live and emitted parsers; allocate monotonic frames/generations, replace and
    restore same-label recursive mark tables, synchronize real cursor/anonymous-boundary/invocation-mark state,
    execute the static child exactly once, and carry accepted/missed status on a dedicated channel separate from
    returned false, zero, empty, or undef payloads. Commit invalidates before retaining staged state/payload;
    rollback restores before invalidation; unwind reports a missing terminal without leaking a live token.
  - [x] **CURSOR-ONLY PROGRESS / STRUCTURED FAILURES** — Instrument accepted repetition iterations and direct or
    mutual recursive re-entry while a recognition attempt is active. Require `end_offset > start_offset` for
    those cases, allow a one-shot zero-width result, ignore binding/mark/transaction changes as progress, and
    throw the neutral `recognition_zero_progress_repetition` or
    `recognition_zero_progress_recursive_cycle` typed payload with its exact portable scalar fields in both live
    and independently emitted execution.
  - [x] **RED-FIRST FINAL-PATH PROOF** — Extend `t/recognition_transaction_perl_contract.t` before production
    implementation to lock dedicated event arguments, static/dynamic operand and effect failures, falsey-safe
    match/payload separation, commit/rollback cursor and mark behavior, recursive mark isolation, repetition and
    recursive progress failures, unchanged compatibility save/restore, exact once-only child execution, and
    standalone generated-source load/execute parity. First record the expanded deterministic RED boundary, then
    make that same final-path consumer GREEN without adding it to ordinary/canonical discovery (admission remains
    exclusively `.14.3.2.3`).
  - [x] **LIVE DOCS / SIGNOFF / ATOMIC CLOSEOUT** — Add the durable Knowledge fact, synchronize MEMORY/CHANGES/
    DEVELOPMENT_NOTES and the live mdBook with current private integration plus explicit dormancy, render and
    inspect the book, run focused syntax/unit/final-path/generated-source/neutral/doctrine checks and the
    definitive canonical local gate when warranted, commit exactly atomic 186/300 with the frozen subject, then
    require zero-byte brief, clean pointer/Knowledge/residue/absent-book/status proof before `.14.3.2.3` may
    activate task-tree-first; do not push before the 300-step batch closes.

  Activation evidence 2026-08-10: private authority `.14.3.2.1` lands at full commit
  `8138bea5718198e1a7ce89599c1ae84618dc5211` (`FUTURE-PARITY-BACKLOG.14.3.2.1 - add private Perl transaction
  authority`) with first parent `59306f372e742a9e815c9b409d4502a8533b0fbd`. Its definitive canonical gate passes
  every doctrine, 66/66 in both CLI option environments, RAM 71% below the 88% ceiling, and Phase 0 at
  1,031/1,031 in 688 seconds. Post-commit proof records zero-byte `git_message_brief.txt`, activation pointer
  `59306f37 == HEAD^1`, Knowledge 804 facts / 6,653 answers, no rendered book, no managed-run residue, and clean
  status/diffs. This leaf's retrieval follows Knowledge cards
  `recognition-transaction-neutral-contract`, `cursor-transaction-authored-contract`,
  `perl-recognition-transaction-private-authority`, `perl-recognition-transaction-dormant-red`,
  `actionir-lowering-stack`, `perl-actionir-ast-value-lowering-dispatcher`,
  `perl-actionir-ast-statement-call-lowering`, `perl-generated-source-contract-v2`, and
  `perl-rule-local-cursor-rollout-boundaries`; ADR 0056 §§3 and 11-13; and TOOLBOX lowering, descriptor,
  generated-source, runtime-context, and neutral-oracle probes. Direct probes confirm the parser already accepts
  the exact future spellings, but checkpoint/attempt/commit become unsupported-helper sentinels, rollback remains
  raw, and the final-path consumer is deterministically 49-pass / one-fail / one-skip. The complete rule table is
  the first seam with enough information for recursive effect closure; `_build_handler_preamble` and emitted raw
  handler bodies are the common live/generated invocation seam; `_build_lmatch_extraction` plus explicit miss
  sites are the payload-independent recognition channel; and the existing runtime wrapper's recursion guard must
  delegate to the typed transaction progress owner only while a recognition attempt is active.

  Expanded RED evidence 2026-08-10: the final-path consumer now freezes exact dedicated-event arguments, dynamic
  operand and direct/transitive/unknown effect rejection, typed cursor-only repetition progress, and the complete
  live/generated falsey-safe behavior before any production edit. `perl -Iperl -c` passes; the verbose consumer
  remains deterministically 49 pass / one fail / one skip across 51 outer assertions, with the sole failure still
  `missing nodes=[RECOGNITION_CHECKPOINT,RECOGNIZE_ONCE,RECOGNITION_COMMIT,RECOGNITION_ROLLBACK]`, unresolved
  checkpoint/attempt/commit, and one raw rollback dependency. The expanded integration subtest remains wholly
  dormant behind that one readiness boundary.

  Implementation evidence 2026-08-10: one transaction scanner family emits the four exact dedicated events and
  excludes their nested call/RHS text from legacy scanners. Contract lowering consumes canonical arguments without
  evaluating the static operand. `RecognitionTransactionPolicy` mirrors the closed neutral 132-node inventory,
  checks checkpoint/attempt/terminal order and structured terminal paths, rejects token escape/dynamic callees,
  and unions named-rule/dependency effects to a recursive fixed point only after established descriptor validation.
  `RecognitionTransactionRuntime` binds the unchanged private authority to source-local handler guards, replaces
  and restores recursive same-label marks, synchronizes cursor/boundary/marks, carries child acceptance separately
  from payload, and publishes completion records only during recognition scopes. Live and emitted handlers note
  match/miss state, use acceptance rather than falsey payload truthiness, and enforce typed repetition/direct/mutual
  recursive progress only inside recognition. Generated v2 source includes runtime support universally but carries
  local recognition regexes only for transaction specs and rethrows typed errors unchanged.

  Focused GREEN and compatibility-repair evidence 2026-08-10: the final-path consumer passes all 51 outer tests;
  its nested integration body covers the four exact event records, dynamic/ordering/effect rejection, all eight
  falsey/miss/commit/rollback fixtures, compatibility cursor controls, zero-width repetition, legal one-shot
  zero-width, direct/mutual recursion, and two independently loaded generated parsers. Private authority plus final
  path pass together, and generated-source plus repetition/nonrepetition trace tests pass. The first complete Phase
  0 run reached all 1,031 tests and found exactly two compatibility regressions: the transaction hook intercepted
  one malformed `dependency_refs` fixture before its established final-descriptor diagnostic, and transaction
  contracts displaced stable `call`-first metadata. Moving policy after descriptor validation, failing closed on
  malformed policy input, and restoring contract order reproduce both exact expected results; no transaction or
  neutral semantic expectation changed. Neutral remains 132/246, token 8/17, graphs 6, marks 6, progress 8,
  diagnostics 15, mutations 40, rollout 1/9, and public sequence 3/8/13.

  Recomposition evidence 2026-08-10: the repaired complete Phase 0 rerun passes 1,031/1,031 in 749 wall-clock
  seconds, including both previously failing compatibility owners. Public transaction governance passes at
  132/246, 40 semantic mutations, and 3/8/13 sequence proof; Knowledge is synchronized at 805 facts / 6,664
  question keys; MEMORY is exactly 60 lines; README remains 105 lines / 5,057 bytes; document history passes 34/34,
  task partitions pass 26/26 over 511 stable ids, and task metadata is consistent. The real book builds to 79 files
  / 14,364 KiB; deterministic rendered HTML inspection confirms separate coherent paragraphs for internal GREEN,
  unadmitted Perl, and cross-runtime future status on all three governed pages, then the generated book is removed.
  Artifact census retains only tracked diagnostic fixtures, project-local dependency/cache data, and active Rust
  incremental caches; none is an unowned disposable artifact. Managed-run listing is empty. Definitive staged
  canonical CI and atomic commit workflow remain.

  Canonical-coverage repair evidence 2026-08-10: the first definitive gate passed all earlier doctrine, neutral,
  typed-source, MCP, semantic-introspection, and portable regression stages, then stopped at exhaustive ActionIR
  language coverage because the four new identifier-shaped Perl contract diagnostics were not classified. They
  are grammar-owned intrinsics lowering to dedicated `RECOGNITION_*` nodes, not ordinary shared helper calls; adding
  them to the Dart/Julia/Lua inventories would have falsely promoted a Perl-only unadmitted implementation. The
  checker now classifies those exact four alongside the nine established compatibility/legacy/internal contracts,
  requires them to exist in Perl and remain absent from all shared inventories, and again passes at 246 current
  calls / 105 corpus + one named-mark fixture / 122 independently covered ordinary public Perl calls. The neutral
  transaction checker remains exact at 132 = 128 + 4 nodes and 246 call rows.

  Definitive signoff evidence 2026-08-10: the repaired staged tree passes all eight doctrines, tracked-input and
  path audits, every focused neutral/private/typed-source/semantic/MCP/regression contract, repository-contained
  six-family process I/O, Rust moved-root plus four outside-CWD anchors, and both primary CLI environments at
  66/66. RAM is 58% below the 88% ceiling. Phase 0 passes 1,031/1,031 in 727 wall-clock seconds before exact
  `[ci] local CI gate passed`. Knowledge regenerates at 805 facts / 6,665 question keys; the task partition remains
  26/26 over 511 stable ids; MEMORY is 60 lines; README remains 105 lines / 5,057 bytes; the rendered 79-file /
  14,364-KiB book has been inspected and removed. Atomic 186/300 is ready with the frozen subject; admission
  `.14.3.2.3` remains pending until this commit's clean post-commit handoff.

  Commit/handoff evidence 2026-08-10: atomic commit
  `e173bbcbfdc750f39714909a1a0ee720068e679d` lands with first parent
  `8138bea5718198e1a7ce89599c1ae84618dc5211` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.2.2 - integrate Perl recognition transactions`. Its hook regenerates Knowledge at
  805/6,665, passes all eight doctrines, and validates `activation_commit 8138bea5` against `HEAD^1`. Post-commit
  status and staged/unstaged diffs are empty; the ignored brief is zero bytes; the memory pointer, Knowledge, and
  task partitions pass; rendered book output is absent; the correct managed-run census reports zero residue; and
  no background job remains. Admission `.14.3.2.3` may therefore activate task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.14.3.2.3`
  Status: `complete` (2026-08-10; exact Perl-only admission and definitive signoff complete from clean integration
    closeout `e173bbcb`, commit-ready as atomic 187/300; Rust RED `.14.3.3.0` next; no push)
  Goal: Remove Perl dormancy, register exact ordinary/canonical proof, promote only Perl transaction admission, and
    synchronize current public guidance.
  Depends on: `.14.3.2.2`
  Acceptance: Retrieve the neutral transaction rollout, authored/static contract, integrated Perl authority,
    final-path consumer, canonical driver, public-sequence guard, admitted-runtime precedents, exact three governed
    book pages, storage owners, and ADR `0056` before changing registration. Prove the unchanged final-path consumer
    is GREEN but absent from canonical execution, then require, syntax-check, and execute that exact tracked
    consumer once in canonical CI. Promote only `perl` from RED to complete, add omission-sensitive
    canonical and completed-to-pending mutation proof, and advance current guidance on the three governed pages
    from implemented-but-unadmitted Perl to admitted Perl while retaining every other runtime, recurring, and final
    public-no-drift row as future. Preserve all production Perl/compiler/runtime/generated-source files, the 132
    node and 246 ordinary-call inventories, token/effect/mark/progress/diagnostic fixtures, helper results, runtime
    registers, descriptor/generated schemas and identities, semantic/MCP/capability/CLI surfaces, root README,
    project-data roots, and unrelated docs. Pass focused registration/rollout/public-sequence, language, book render
    inspection, doctrines, and definitive canonical signoff; synchronize durable/live records; commit atomically as
    187/300; clear the brief and prove clean before Rust RED `.14.3.3.0` activates task-tree-first.
  Verification: behavior-unchanged 51-test Perl consumer is exact-once canonical; only `perl` advances;
    other neutral counts and public/current guidance agree; focused, book, doctrine, and canonical gates pass
  Commit: `FUTURE-PARITY-BACKLOG.14.3.2.3 - admit Perl recognition transactions`

  ### `FUTURE-PARITY-BACKLOG.14.3.2.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove `.14.3.2.2` landed at full `e173bbcb` as atomic 186/300 with
    parent `8138bea5`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer, fresh
    Knowledge/task partitions, absent rendered book, zero managed-run residue, no background work, and only
    task-tree metadata changed to activate this leaf.
  - [x] **RETRIEVE / REPRODUCE EXACT ADMISSION BOUNDARY** — Follow Knowledge, ADR, neutral artifact/checker,
    integrated consumer, canonical-driver, public-sequence, admission-precedent, storage, and sole-facing owners;
    prove the 51-test consumer is GREEN, tracked, and absent from canonical execution while `perl` and
    current Perl support guidance remain pending.
  - [x] **EXACT CANONICAL REGISTRATION** — Require, syntax-check, and execute the behavior-unchanged final-path consumer once
    through the canonical Perl route; independently reject missing, duplicate, stale-dormant, or misrouted
    registration without broadening ordinary helper discovery or production behavior.
  - [x] **PERL-ONLY ROLLOUT / PUBLIC-CURRENT LOCKSTEP** — Promote only `perl`, add completed-to-RED
    regression coverage, and update exactly the three governed book pages to admit current Perl transaction
    support while every other runtime, recurring composition, and final public-no-drift row remains RED.
  - [x] **NO-DRIFT / RENDERED PROOF** — Preserve production source, neutral 132 nodes / 246 calls / token 8+17 /
    graphs 6 / marks 6 / progress 8 / diagnostics 15 / semantic fixtures, language 246/105+1/122, schemas,
    helper/register behavior, semantic/MCP/capability/CLI, README, storage, and unrelated docs; build, inspect, and
    remove the sole-facing book output.
  - [x] **SIGNOFF / ATOMIC CLEAN HANDOFF** — Synchronize task/index, roadmaps, CHANGES, DEVELOPMENT_NOTES, MEMORY,
    Knowledge, and mdBook; pass focused and definitive canonical gates; commit exactly atomic 187/300 with the
    frozen subject; clear the brief; and prove pointer/Knowledge/task/residue/book/status clean before Rust RED
    `.14.3.3.0` activates task-tree-first.

  Activation evidence 2026-08-10: Perl integration `.14.3.2.2` lands atomically at full commit
  `e173bbcbfdc750f39714909a1a0ee720068e679d` as 186/300 with first parent
  `8138bea5718198e1a7ce89599c1ae84618dc5211` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.2.2 - integrate Perl recognition transactions`. Its hook regenerates Knowledge at
  805 facts / 6,665 question keys, passes all eight doctrines, and validates `activation_commit 8138bea5` against
  `HEAD^1`. Post-commit status and staged/unstaged diffs are empty; `git_message_brief.txt` is zero bytes; pointer,
  Knowledge, and 26/26 task partitions over 511 stable ids pass; generated book output is absent; the correct
  managed-run census reports zero residue; and no background work remains. Only task-tree metadata changes in this
  activation before any contract/checker/canonical-driver/book/Knowledge/roadmap/live-doc or behavior file.

  Retrieval/boundary evidence 2026-08-10: Knowledge lookup followed
  `recognition-transaction-neutral-contract`, `cursor-transaction-authored-contract`,
  `perl-recognition-transaction-integration`, and the typed-source Perl admission precedent before inspecting the
  neutral JSON/checker, exact final-path consumer, canonical driver, ADR `0056`, storage routes, and all three
  governed mdBook pages. The unchanged consumer passes 51/51 in 10 seconds, is tracked, and has zero canonical
  references. The checker reports exact 132 = 128 + 4 ActionIR rows, 246 calls, token 8/17, graphs 6, marks 6,
  progress 8, diagnostics 15, 40 mutations, neutral-only rollout 1/9, and public sequence 3/8/13. The ledger-first
  promotion then produces one intentional RED—`neutral/backend status drifted`—before the oracle is updated.

  Admission implementation evidence 2026-08-10: only the `perl` row moves to complete and names
  `t/recognition_transaction_perl_contract.t`; every later runtime, recurring, and public-no-drift row remains RED.
  Canonical CI requires, syntax-checks, logs, and executes that exact consumer once through ordinary `prove`. The
  independent checker requires all four fragments exactly once, rejects premature Rust promotion, and adds a
  distinct Perl complete-to-RED mutation, advancing semantic proof to 41. Public governance now derives neutral +
  Perl complete with every later leg RED and independently rejects neutral regression, Perl regression, and
  premature Rust promotion, advancing to three documents / eight forbidden claims / fourteen mutations. The
  consumer's 49 behavior assertions are unchanged; only two neutral-only admission-metadata expectations advance,
  and all 51 tests pass. Language coverage remains exact at 246 current calls / 105+1 fixtures / 122 public Perl
  contracts. No production Perl/compiler/runtime/generated-source path is changed.

  Focused/no-drift/render evidence 2026-08-10: the independent checker is GREEN at exact 132/246, token 8/17,
  graphs 6, marks 6, progress 8, diagnostics 15, semantic mutations 41, rollout 2/9, and public sequence 3/8/14.
  Private authority, admitted transaction, generated source, complete named marks, and typed-source projection pass
  together at 71 tests in 41 seconds. Language remains 246/105+1/122; task metadata passes 26/26 over 511 stable
  ids; memory passes at 59/60 lines; Knowledge is current at 805 facts / 6,666 question keys; and production-path
  diff is empty. The repository-routed mdBook build produces 79 files / 14,368 KiB. Direct HTML inspection on all
  three governed pages confirms current Perl support, the exact canonical command, 2/9 rollout, remaining-runtime
  limitations, and following guidance in coherent separate paragraph/preformatted blocks; generated output is then
  removed.

  Definitive signoff evidence 2026-08-10: the complete host-authorized canonical gate requires, syntax-checks,
  logs, and executes the exact 51-test Perl admission consumer once and passes all eight doctrines; neutral and
  admission proof at 132 ActionIR rows / 246 calls / 41 rejected mutations / rollout 2/9; public sequence at three
  documents / eight forbidden claims / fourteen mutations; language coverage 246/105+1/122; the focused five-file
  Perl composition at 71 tests; all mandatory typed-source, semantic, MCP, cursor, capability, storage, and moved-
  root consumers; and both primary CLI environments at 66/66. RAM is 34% against the 88% ceiling, and Phase 0
  passes 1,031/1,031 in 733 wall-clock seconds before exact `[ci] local CI gate passed` and exit zero. Production
  implementation diff remains empty; Knowledge is current at 805 facts / 6,666 question keys; task metadata passes
  26/26 over 511 stable ids; MEMORY is within its 60-line bound; README remains 105 lines / 5,057 bytes; the
  rendered 79-file / 14,368-KiB book was inspected and removed. Atomic 187/300 is commit-ready with the frozen
  subject, and Rust RED `.14.3.3.0` remains the next task-tree-first activation after a clean post-commit handoff.

- ID: `FUTURE-PARITY-BACKLOG.14.3.3`
  Status: `complete` (2026-08-11; Rust admission `.14.3.3.3` signoff-complete from clean integration closeout
    `1cf2923a`, commit-ready as atomic 191/300; Dart RED `.14.3.4.0` next after landing; no push)
  Goal: Implement and independently admit exact Rust parity through its native/reconstructed/generated carriers.
  Depends on: `.14.3.2`
  Children: `.14.3.3.0-.14.3.3.3`

- ID: `FUTURE-PARITY-BACKLOG.14.3.3.0`
  Status: `complete` (2026-08-10; exact dormant Rust RED and definitive signoff complete from clean Perl-admission
    closeout `a0595411`, commit-ready as atomic 188/300; private authority `.14.3.3.1` next; no push)
  Goal: Freeze dormant Rust RED against the admitted Perl/neutral authority across native, reconstructed,
    generated-plan, and independently compiled emitted-source carriers.
  Depends on: `.14.3.2.3`
  Acceptance: Retrieve the admitted neutral/Perl transaction owners, ADR `0056`, Toolbox transaction and Rust
    probes, the dormant Rust typed-source precedent, current Rust ActionIR/parser/runtime/generated-source carrier
    seams, canonical/storage registration, and exact rollout/public guards before writing the consumer. Add one
    tracked but ordinary/canonical-dormant Rust consumer behind an audited test-local custom-cfg boundary. Derive
    its syntax, 132-node/246-call effect authority, 8+17 token cases, six effect graphs, six mark cases, eight
    progress cases, fifteen diagnostics, and compatibility controls from the neutral artifact while freezing
    native, reconstructed, generated-plan, and independently compiled emitted-source expectations. Prove ordinary
    Cargo and canonical discovery remain green, then run the cfg explicitly and show one deterministic first RED at
    the absent `.14.3.3.1` private Rust invocation/token/snapshot authority rather than at test syntax, fixtures, or
    an already-owned baseline. Preserve all production Rust and other-backend code, current Perl admission, neutral
    rollout 2/9 and 41 mutations, public sequence 3/8/14, 246/105+1/122 language coverage, typed-source/semantic/MCP/
    capability/CLI behavior, root README, mdBook current claims, storage roots, and hosted-workflow state. Pass
    focused RED-shape/current Rust, book, doctrine, and definitive canonical proof; synchronize durable records;
    commit atomically as 188/300; clear the brief and prove clean before private Rust authority `.14.3.3.1` activates.
  Verification: tracked consumer syntax and fixture derivation; ordinary zero-test dormancy; explicit cfg exact
    private-authority RED; unchanged recognition 132/246/41 + rollout 2/9 + public 3/8/14; current Rust/local and
    canonical gates; book/Knowledge/task/memory/storage no-drift; atomic clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.3.3.0 - freeze Rust transaction RED`

  ### `FUTURE-PARITY-BACKLOG.14.3.3.0` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove Perl admission `.14.3.2.3` landed at full `a0595411` as
    atomic 187/300 with parent `e173bbcb`, exact subject, empty status/diffs, zero-byte brief, valid post-commit
    pointer, fresh Knowledge/task partitions, absent rendered book, zero managed-run residue, no background work,
    and only task-tree metadata changed to activate this leaf.
  - [x] **RETRIEVE / PROBE RUST BOUNDARY** — Follow neutral, authored, Perl, typed-source RED, ADR, Toolbox, current
    Rust carrier, canonical, and storage owners; use exact structural/runtime probes before freezing a failure.
  - [x] **FREEZE NEUTRAL-DERIVED DORMANT RED** — Add one cfg-gated tracked Rust consumer covering syntax, effects,
    tokens, marks, progress, diagnostics, compatibility, and all four required Rust carriers.
  - [x] **PROVE FIRST INTENTIONAL BOUNDARY** — Keep ordinary Cargo/canonical discovery at zero active tests while
    explicit cfg execution fails deterministically first at the `.14.3.3.1` private-authority seam.
  - [x] **NO PREMATURE ROLLOUT OR BEHAVIOR** — Preserve production code, Perl/current public truth, rollout 2/9,
    41 semantic and 14 public mutations, all support ledgers, README/book claims, and storage/workflow boundaries.
  - [x] **SIGNOFF / ATOMIC CLEAN HANDOFF** — Synchronize task/index, roadmaps, CHANGES, DEVELOPMENT_NOTES, MEMORY,
    Knowledge, and mdBook; pass focused/current and definitive canonical gates; commit exactly atomic 188/300 with
    the frozen subject; clear the brief; and prove pointer/Knowledge/task/residue/book/status clean before `.1`.

  Activation evidence 2026-08-10: Perl admission `.14.3.2.3` lands at full commit
  `a0595411145cb85fb8b492c20c6f0c58fbbc5995` as atomic 187/300 with first parent
  `e173bbcbfdc750f39714909a1a0ee720068e679d` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.2.3 - admit Perl recognition transactions`. Its hook regenerates Knowledge at 805
  facts / 6,666 question keys, passes all eight doctrines, and validates `activation_commit e173bbcb` against
  `HEAD^1`. Post-commit status and staged/unstaged diffs are empty; `git_message_brief.txt` is zero bytes; memory,
  Knowledge, and 26/26 task partitions over 511 stable ids pass; generated book output is absent; the managed-run
  census reports zero residue; and no background work remains. Only task-tree metadata changes in this activation
  before any Rust consumer, production, contract, checker, canonical-driver, book, Knowledge, roadmap, or live-doc
  mutation.

  Authority and RED evidence 2026-08-10: the neutral, authored, Perl-admission, transaction-safety, typed-source
  dormant-consumer, ADR `0056`, Toolbox, Rust parser/ActionIR/runtime/source-emitter, canonical-registration, and
  project-data owners were retrieved before freezing the consumer. A direct current Rust CLI probe accepts the
  four exact forms only as generic calls, reports exactly four unknown-helper warnings for
  `recognition_checkpoint`, `recognize_once`, `recognition_commit`, and `recognition_rollback`, then returns
  `null`; Rust has no dedicated transaction nodes or private authority. The new final-path
  `rust/linkedspec-runtime/tests/recognition_transaction_contract.rs` derives the exact 132/246, 8+17, 6/6/8,
  fifteen-diagnostic, 41-mutation, and 2/9 rollout authority. Its outer
  `linkedspec_recognition_transaction_red` cfg freezes opaque monotonic invocation/frame/token/snapshot ownership,
  falsey-safe payload separation, mark rollback/commit, escape/lifecycle/authority errors, and unwind restoration;
  a nested `linkedspec_recognition_transaction_integration_red` cfg freezes dedicated lowering, effect/progress,
  native, reconstructed, generated-plan, independently compiled emitted-source, and compatibility expectations.

  Dormancy and first-boundary evidence 2026-08-10: ordinary offline Cargo discovers the tracked target and runs
  zero tests successfully. Explicit outer-cfg execution exits 101 with one compiler error only:
  `E0432 unresolved import linkedspec_runtime::recognition_transaction`; no nested integration, fixture, syntax,
  or competing API error appears. The consumer has zero references in `rust/Cargo.toml` and
  `tools/run_ci_local.sh`, so ordinary and canonical discovery remain dormant. Focused neutral proof remains 132
  ActionIR / 246 calls / 41 semantic mutations, rollout 2/9, and public sequence 3/8/14; language coverage remains
  246 / 105+1 / 122. Review also found that atomic 187 appended the current 2/9 capability-guide paragraph without
  removing its older 1/9/all-backends-unavailable paragraph. `git blame` assigns the current addition to
  `a0595411` and the stale retained text to `e0cc7182`. This leaf repairs that contradiction without changing the
  book or rollout and extends the same independent checker with a separate one-document/two-forbidden/six-mutation
  guide guard; the semantic 41 and public-sequence 14 mutation domains remain unchanged.

  Focused/no-drift/render evidence 2026-08-10: the independent checker is GREEN at exact 132 ActionIR rows / 246
  calls / token 8+17 / graphs 6 / marks 6 / progress 8 / diagnostics 15 / 41 semantic mutations / rollout 2/9,
  public sequence three documents / eight forbidden claims / fourteen mutations, and the separate capability-guide
  guard at one document / two forbidden claims / six mutations. Ordinary offline Cargo executes zero tests for the
  new target; explicit cfg still exits 101 at the sole `E0432`; `cargo fmt --check` and production/registration
  no-drift pass. The complete Rust local gate passes 195 core, 166 runtime, 105/105 corpus, 197 integration, the new
  dormant target at zero tests, and CLI 66/66 in both option environments. Language remains 246/105+1/122; task
  metadata passes 26/26 over 511 stable ids; Knowledge is current at 807 facts / 6,682 question keys; MEMORY stays
  within 60 lines; README remains 105 lines / 5,057 bytes; and all eight doctrines pass. The repository-routed
  mdBook build produces 79 files / 14,368 KiB; direct inspection confirms current Perl-only support and future Rust
  truth, and generated output is removed. The managed-run residue census is zero.

  Definitive signoff evidence 2026-08-10: an initial sandboxed canonical attempt passed through both CLI-focused
  suites but the outer harness denied the gate's own representative `sandbox-exec` proof with status 71. The same
  complete gate was rerun host-authorized from the beginning and passed all eight doctrines; exact recognition
  132/246/41, rollout 2/9, public 3/8/14, and guide 1/2/6; every mandatory typed-source, semantic, MCP, cursor,
  capability, repository-containment, and moved-root proof; and both primary CLI environments at 66/66. RAM is 55%
  against the 88% ceiling, and Phase 0 passes all 1,031 tests in 700 wall-clock seconds before exact
  `[ci] local CI gate passed` and exit zero. Production and canonical-registration diffs remain empty; Knowledge,
  task metadata, memory, README bounds, rendered-book cleanup, and managed residue remain exact. Atomic 188/300 is
  commit-ready with the frozen subject; `.14.3.3.1` remains pending until a clean post-commit handoff.

- ID: `FUTURE-PARITY-BACKLOG.14.3.3.1`
  Status: `complete` (2026-08-10; private authority and definitive signoff complete from clean dormant-RED
    closeout `cb9420b1`, commit-ready as intended atomic 189/300; integration `.14.3.3.2` next; no push)
  Goal: Add private Rust invocation-frame, mark-generation, opaque-token, snapshot, and invalidation authority with
    current public routes unchanged.
  Depends on: `.14.3.3.0`
  Acceptance: Retrieve the neutral transaction authority, ADR `0056`, admitted Perl private owner and consumer,
    Rust dormant RED, typed-source inside-out precedent, current Rust runtime value/error conventions, generated
    carrier boundaries, Toolbox probes, and canonical/storage owners before changing Rust source. Add one
    custom-cfg-only, public-to-the-integration-test but documentation-hidden Rust module that owns source-local
    monotonic invocation/frame/mark/token generations, detached cursor/boundary/mark snapshots, strict
    match-presence versus staged-payload presence/value, linear exactly-once attempt state, commit/rollback, and
    restore-before-invalidate misuse handling. Keep the module unreachable in ordinary builds and change no
    ActionIR node, scanner, parser, engine, RuntimeContext route, generated source, manifest, canonical driver,
    admitted Perl behavior, neutral artifact, rollout, or public-current claim. Make the existing outer cfg contract
    GREEN without enabling the nested integration cfg; prove ordinary Cargo still discovers zero active tests and
    the nested cfg now stops first at the `.14.3.3.2` dedicated lowering/runtime seam. Lock recursive same-label
    frame isolation, falsey payloads, miss/commit/rollback, stale/double/escaped/dropped token handling,
    cross-source/invocation misuse, unwind restoration, detached snapshots, opaque diagnostics, and monotonic
    non-reuse. Pass focused private/current Rust, explicit next-RED shape, complete Rust local, neutral/public/guide,
    book, Knowledge/task/memory/storage/doctrine, and definitive canonical proof; synchronize durable records;
    commit atomically as 189/300; clear the brief and prove clean before integration `.14.3.3.2` activates.
  Verification: clean activation; Knowledge/Toolbox-first retrieval; ordinary zero-test dormancy; explicit outer-cfg
    private authority GREEN; nested integration cfg exact next RED; unchanged recognition 132/246/41 + rollout 2/9
    + public 3/8/14 + guide 1/2/6; production/current-suite no-drift; book/Knowledge/task/memory/storage/doctrines;
    canonical CI; atomic clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.3.3.1 - add private Rust transaction authority`

  ### `FUTURE-PARITY-BACKLOG.14.3.3.1` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove dormant RED `.14.3.3.0` landed at full `cb9420b1` as atomic
    188/300 with parent `a0595411`, exact subject, empty status/diffs, zero-byte brief, valid post-commit pointer,
    fresh Knowledge/task partitions, absent rendered book, zero managed-run descendants, no background work, and
    this task-tree file as the sole first activation mutation.
  - [x] **RETRIEVE / PROBE PRIVATE RUST OWNER SEAMS** — Follow neutral, Perl, dormant-RED, typed-source, runtime,
    error, mark/snapshot, generated carrier, ADR, Toolbox, canonical, and storage owners before implementation.
  - [x] **IMPLEMENT CFG-PRIVATE TRANSACTION AUTHORITY** — Add the narrow source authority, invocation/frame/mark
    generations, opaque tokens, detached snapshots, staged result channels, terminal invalidation, and typed errors.
  - [x] **PROVE LIFECYCLE / MISUSE / NEXT BOUNDARY** — Make the outer contract GREEN across exact lifecycle and
    misuse cases while ordinary discovery stays zero-test and nested integration stops only at `.14.3.3.2`.
  - [x] **PRESERVE DORMANCY / PRODUCTION / PUBLIC TRUTH** — Change no ordinary Rust route or other backend and keep
    recognition 132/246/41, rollout 2/9, public 3/8/14, guide 1/2/6, README/book, and support ledgers exact.
  - [x] **SIGNOFF / ATOMIC CLEAN HANDOFF** — Synchronize task/index, roadmaps, CHANGES, DEVELOPMENT_NOTES, MEMORY,
    Knowledge, and mdBook; pass focused/current and definitive canonical gates; commit exactly atomic 189/300 with
    the frozen subject; clear the brief; and prove pointer/Knowledge/task/residue/book/status clean before `.2`.

  Activation evidence 2026-08-10: dormant Rust RED `.14.3.3.0` lands at full commit
  `cb9420b167467da55fca18008973b1cb94c00021` as atomic 188/300 with first parent
  `a0595411145cb85fb8b492c20c6f0c58fbbc5995` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.3.0 - freeze Rust transaction RED`. Its hook regenerates Knowledge at 807 facts /
  6,682 question keys, passes all eight doctrines, and validates `activation_commit a0595411` against `HEAD^1`.
  Post-commit status and staged/unstaged diffs are empty; `git_message_brief.txt` is zero bytes; memory, Knowledge,
  and 26/26 task partitions over 511 stable ids pass; generated book output is absent; the managed checkout
  container has zero run descendants; and no background work remains. This task-tree file is the sole first
  activation mutation before index, probes, Rust source/tests, checker, canonical driver, book, Knowledge, roadmap,
  or live-doc changes.

  Retrieval and first implementation-probe evidence 2026-08-10: Knowledge Map-first retrieval followed the neutral
  authority, Perl private owner/consumer, dormant Rust RED, cursor/transaction contract, typed-source rollout, ADR
  `0056`, Toolbox explicit-cfg command, source-location value/error conventions, and generated-carrier boundary. The
  first module-supplied compile then exposed a latent frozen-consumer defect that the prior missing-module `E0432`
  had masked: within each of two tests, a local `authority` binding shadowed the same-named constructor function, so
  later `authority(...)` expressions failed with `E0618` before any private-authority assertion could run. This leaf
  owns the narrow dormant-test-only constructor rename required to recover the already-frozen semantic assertions.
  With that compile blocker removed, five of six outer tests pass; the remaining neutral-count test reads six
  nonexistent abbreviated keys even though the governed contract has always exposed `canonical_call_contracts`,
  `token_positive_cases`, `token_negative_cases`, `effect_graph_cases`, `mark_cases`, and `progress_cases`. The same
  test-only recovery therefore owns correcting those JSON field paths while retaining every expected number. That
  rerun reaches the final neutral assertion and shows the same drift once more: nonexistent top-level `syntax` was
  used instead of canonical `authored_surface`, and its required current-availability member was omitted. Recover
  the assertion against the complete governed object. No fixture, behavioral expectation, discovery, integration
  boundary, production route, or rollout truth may change.

  Private-authority and next-boundary evidence 2026-08-10: the new documentation-hidden
  `rust/linkedspec-runtime/src/recognition_transaction.rs` is reachable only when the existing outer custom cfg is
  explicitly selected. One `Rc<RefCell<_>>` authority owns the test-only single-thread invocation stack while an
  `Arc<SourceAuthority>` pointer supplies exact cross-source identity. Opaque handles expose no clone/debug value;
  authority-local counters never reuse invocation, mark-generation, or transaction identities; snapshots detach
  cursor/boundary/marks; and match presence stays independent of optional staged payload. Retry, nesting, escape,
  cross-source/invocation misuse, unwind, authority drop, and token drop restore the owning snapshot before terminal
  invalidation. Commit copies the falsey-safe payload only after retaining staged frame state and invalidating the
  token. The recovered consumer now passes 7/7 under the outer cfg, including explicit nesting and token-drop
  restoration; ordinary Cargo still executes exactly zero tests. The nested two-cfg build reaches `.14.3.3.2` and
  fails only at missing `classify_recognition_effects`, `validate_recognition_progress`, and dedicated
  `RecognitionCheckpoint`, `RecognizeOnce`, and `RecognitionRollback` expression variants. No private-authority
  error remains.

  Focused Rust evidence 2026-08-10: `cargo fmt --check` passes. Strict Clippy passes for the new module after
  allowing only eight pre-existing runtime-crate lint categories; dependency warnings remain confined to the
  existing `pgen`/`rgx` trees. The complete `tools/run_rust_local.sh` gate passes 195 core unit tests, 166 runtime
  unit tests, 105/105 corpus-oracle fixtures, 197 integration cases, all other focused runtime groups, the dormant
  target at zero ordinary tests, the Rust project-data/storage proof, primary binary build, and both CLI matrices
  at 66/66 before exact `[rust-ci] Rust local gate passed`.

  Cfg-lint scope evidence 2026-08-10: a direct ordinary Cargo check proves Rust diagnoses the custom predicate
  before an item-level `allow(unexpected_cfgs)` can take effect. Manifest or build-script registration would make
  the cfg an ordinary build input and violate this leaf's frozen no-manifest/no-build-route boundary. The crate-
  level allowance is therefore retained with an explicit reason string; source/no-registration proof continues to
  lock the two exact predicates and their dormant test-only use.

  First canonical attempt 2026-08-10: the gate stopped in doctrine enforcement before product tests because this
  leaf's focused/cfg-lint evidence had been appended after the earlier task-partition index refresh. The checker
  reported exact `.14` line-count, byte-count, and digest drift plus the consequent stable-id lookup failure; README
  routing failed only because it composes that same freshness verifier. Regenerate the mutable task index after
  this final evidence, rerun task metadata and README stability, then rerun the complete canonical gate from the
  beginning. No implementation, contract, book, runtime, or storage assertion failed.

  Definitive signoff evidence 2026-08-10: after regenerating the task partition from the final evidence, task
  metadata and README routing returned GREEN and the complete host-authorized canonical rerun passed from the
  beginning. It passes all eight doctrines; exact recognition 132/246/41, rollout 2/9, public 3/8/14, and guide
  1/2/6; every mandatory typed-source, semantic-introspection, MCP, cursor, capability, project-data containment,
  and moved-root/outside-CWD consumer; and both primary CLI option environments at 66/66. RAM is 65% against the
  88% ceiling, and Phase 0 passes 1,031/1,031 in 701 wall-clock seconds before exact `[ci] local CI gate passed`
  and exit zero. The independent outer cfg remains 7/7, ordinary discovery remains zero-test, the nested cfg still
  reaches only `.14.3.3.2`, and the complete Rust local gate remains GREEN. Knowledge is synchronized at 807 facts
  / 6,684 question keys; task metadata passes 26/26 over 511 stable ids; MEMORY and README remain bounded; the
  inspected 79-file / 14,376-KiB book output is removed; and no production route, manifest, canonical registration,
  support ledger, or rollout changed. Atomic 189/300 is commit-ready with the frozen subject; integration
  `.14.3.3.2` remains pending until the clean post-commit boundary.

- ID: `FUTURE-PARITY-BACKLOG.14.3.3.2`
  Status: `complete` (2026-08-10; integration and definitive signoff complete from clean private-authority
    closeout `fd8a1934`, commit-ready as intended atomic 190/300; admission `.14.3.3.3` next; no push)
  Goal: Integrate exact Rust syntax/runtime/effect/progress parity through native, reconstructed, generated-plan,
    and independently compiled emitted-source carriers.
  Depends on: `.14.3.3.1`
  Acceptance: Retrieve the neutral transaction authority, ADR `0056`, admitted Perl implementation, frozen Rust
    consumer, cfg-private Rust authority, current Rust scanner/ActionIR/parser/runtime/source-emitter carriers,
    typed-source values, Toolbox probes, and canonical/storage owners before implementation. Add the four dedicated
    non-eager recognition transaction forms to Rust scanning, ActionIR reconstruction, static effect/progress
    policy, live runtime state, generated-plan execution, and independently compiled emitted source. Bind the
    existing private authority to real cursor, anonymous-boundary, invocation-mark, child-acceptance, and falsey-
    safe staged-payload channels without widening public APIs or enabling ordinary discovery. Make the nested cfg
    consumer GREEN across native, reconstructed, generated-plan, and fresh emitted-source carriers while the outer
    cfg remains 7/7 and ordinary Cargo remains zero-test. Preserve Perl, other backends, neutral artifact, rollout
    2/9, public sequence 3/8/14, guide 1/2/6, current Rust authored-support claims, manifest/canonical dormancy,
    helper results/registers, schemas, CLI, README, mdBook truth, storage roots, and hosted-workflow state. Pass
    focused integration/current Rust, complete Rust local, neutral/public/guide, book, Knowledge/task/memory/
    storage/doctrine, and definitive canonical proof; synchronize durable records; commit atomically as 190/300;
    clear the brief and prove clean before Rust admission `.14.3.3.3` activates.
  Verification: clean activation; Knowledge/Toolbox-first retrieval; nested cfg exact integration GREEN; outer cfg
    7/7 and ordinary zero-test dormancy; unchanged recognition 132/246/41 + rollout 2/9 + public 3/8/14 + guide
    1/2/6; current-suite/no-registration no-drift; book/Knowledge/task/memory/storage/doctrines; canonical CI;
    atomic clean handoff
  Commit: `FUTURE-PARITY-BACKLOG.14.3.3.2 - integrate Rust recognition transactions`

  ### `FUTURE-PARITY-BACKLOG.14.3.3.2` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove private authority `.14.3.3.1` landed at full `fd8a1934` as
    atomic 189/300 with parent `cb9420b1`, exact subject, empty status/diffs, zero-byte brief, valid post-commit
    pointer, fresh Knowledge/task partitions, absent rendered book, zero managed-run descendants, no background
    work, and this task-tree file as the sole first activation mutation.
  - [x] **RETRIEVE / PROBE RUST INTEGRATION SEAMS** — Follow neutral, Perl, frozen RED, private authority,
    typed-source, scanner/ActionIR/runtime/emitter, ADR, Toolbox, canonical, and storage owners before implementation.
  - [x] **INTEGRATE DEDICATED STATIC AND LIVE SEMANTICS** — Add exact non-eager nodes, recursive effect closure,
    cursor-only progress, invocation/mark/token binding, falsey-safe completion, and terminal cleanup.
  - [x] **PROVE ALL FOUR RUST CARRIERS** — Make nested native, reconstructed, generated-plan, and independently
    compiled emitted-source assertions GREEN without enabling the target in ordinary or canonical discovery.
  - [x] **PRESERVE CURRENT ROUTES / PUBLIC TRUTH** — Keep ordinary suites, Perl/other backends, rollout 2/9,
    public 3/8/14, guide 1/2/6, manifests, canonical registration, README/book, APIs, and storage boundaries exact.
  - [x] **SIGNOFF / ATOMIC CLEAN HANDOFF** — Synchronize task/index, roadmaps, CHANGES, DEVELOPMENT_NOTES, MEMORY,
    Knowledge, and mdBook; pass focused/current and definitive canonical gates; commit exactly atomic 190/300 with
    the frozen subject; clear the brief; and prove pointer/Knowledge/task/residue/book/status clean before `.3`.

  Activation evidence 2026-08-10: private Rust transaction authority `.14.3.3.1` lands at full commit
  `fd8a19341d7f682636104d778ef7c2b5db5baa41` as atomic 189/300 with first parent
  `cb9420b167467da55fca18008973b1cb94c00021` and exact subject
  `FUTURE-PARITY-BACKLOG.14.3.3.1 - add private Rust transaction authority`. Its hook regenerates Knowledge at 807
  facts / 6,684 question keys, passes all eight doctrines, and validates `activation_commit cb9420b1` against
  `HEAD^1`. Post-commit status and staged/unstaged diffs are empty; `git_message_brief.txt` is zero bytes; memory,
  Knowledge, and 26/26 task partitions over 511 stable ids pass; generated book output is absent; the verified-
  empty hook run container is removed and the managed-run census is zero; and no background result remains. This
  task-tree file is the sole first activation mutation before index, retrieval/probes, Rust source/tests, checker,
  canonical driver, book, Knowledge, roadmap, or live-doc changes.

  Integration and focused-carrier evidence 2026-08-10: behind the nested integration cfg, the expression parser
  normalizes only the four complete static shapes to dedicated `RecognitionCheckpoint`, `RecognizeOnce`,
  `RecognitionCommit`, and `RecognitionRollback` variants after parsing their arguments, so the static child rule
  is preserved without eager generic-call execution. Recursive structural discovery covers every expression/block
  carrier and serde reconstruction preserves the variants. The private authority now exposes the exact neutral
  recursive-effect fixed point and cursor-progress fixture validator, plus a cfg-private live adapter whose frames
  synchronize the actual cursor, anonymous boundary, and current invocation's same-label mark bucket. Native and
  generated-plan engines enter/leave those frames, publish child acceptance independently from payload truthiness,
  and restore unfinished snapshots before returning terminal failures. Structural AST inspection switches only a
  transaction-bearing emitted module's compatibility `parse` function to its direct effective-engine route;
  ordinary emitted modules retain the established path.

  The first full nested execution exposed one dormant harness defect after compilation reached the independent
  emitted project: its repository-local child manifest sat beneath the parent workspace but neither joined nor
  excluded it. Adding the standard empty `[workspace]` marker makes the transient project self-owned without
  changing any assertion or persisted project-data root. The same run then exposed two frozen-plan aliases and the
  emitted compatibility projection of the transaction result; exact cfg-private aliases plus structural direct
  routing resolve those carrier seams. After cleanup of outer-only unused/dead cfg paths, final focused proof is
  nested 12/12, outer authority 7/7, and ordinary discovery 0 tests. All changed-crate warnings are absent in those
  three states; remaining diagnostic output belongs to the pre-existing `pgen`/`rgx` dependencies.

  Current-route and complete-Rust evidence 2026-08-10: strict changed-crate Clippy passes with only the explicit
  pre-existing core/runtime categories allowed; its one new finding, a needless cfg-branch `return`, was removed.
  The neutral oracle remains exactly 132/246/41, rollout 2/9, public 3/8/14, and guide 1/2/6 after the sole-facing
  book update. Manifests and the canonical driver have no recognition-consumer registration diff. The complete
  `tools/run_rust_local.sh` gate passes 195 core and 166 runtime unit tests, 105/105 corpus cases, 197 integration
  tests, every specialized consumer, ordinary recognition discovery at zero tests, the 17-owner project-data and
  relocation proof, binary build, and CLI 66/66 in both default and POSIX option environments before exact
  `[rust-ci] Rust local gate passed`. The repository-routed mdBook build produces 79 files / 14,388 KiB; rendered
  inspection confirms cfg-private Rust integration and unchanged Perl-only admission, then generated output is
  removed. `rust/target/test-workspaces` has no emitted-project residue.

  Definitive signoff evidence 2026-08-10: after the final code, tests, sole-facing book, Knowledge, task, roadmap,
  and live-doc synchronization, `tools/run_ci_local.sh` passes all eight doctrines, mandatory neutral and admitted
  cross-runtime contracts, repository-local storage and moved-root proofs, primary CLI 66/66 in both default and
  POSIX option environments, RAM 45% below the 88% ceiling, and Phase 0 1,031/1,031 in 735 wall-clock seconds before
  exact `[ci] local CI gate passed`. The final tracked state still has no recognition manifest/canonical-driver
  registration, so nested 12/12 integration remains cfg-private, outer authority remains 7/7, ordinary discovery
  remains zero-test, and admission is owned exclusively by `.14.3.3.3` after atomic 190 lands cleanly.

- ID: `FUTURE-PARITY-BACKLOG.14.3.3.3`
  Status: `complete` (2026-08-11; exact Rust admission and definitive signoff complete from clean integration
    closeout `1cf2923a`, commit-ready as atomic 191/300; Dart RED `.14.3.4.0` next after landing; no push)
  Goal: Remove Rust dormancy, register ordinary/canonical proof, and promote only Rust transaction admission.
  Depends on: `.14.3.3.2`
  Acceptance: Retrieve all neutral/Rust/canonical/public/storage owners; prove the unchanged nested consumer 12/12
    while dormant; remove both cfgs; register the exact ordinary/canonical target; promote only Rust; lock regressions,
    premature Dart, public/guide drift, and admission topology; preserve behavior, 132/246 inventories, fixtures,
    schemas/APIs/CLI/README/storage; pass Rust/book/doctrine/canonical proof and land clean atomic 191/300.
  Verification: unchanged Rust 12-test consumer exact-once; only Rust advances; all governed counts and gates pass
  Commit: `FUTURE-PARITY-BACKLOG.14.3.3.3 - admit Rust recognition transactions`

  ### `FUTURE-PARITY-BACKLOG.14.3.3.3` Acceptance Checklist

  - [x] **CLEAN ACTIVATION / OWNERSHIP** — Prove `1cf2923a`/`fd8a1934`, exact subject, clean state, zero brief, valid maps/pointer, no residue/background work, and sole task-first mutation.
  - [x] **RETRIEVE / REPRODUCE** — Follow every owner; prove explicit 12/12 and zero ordinary/canonical discovery.
  - [x] **REGISTER / PROMOTE** — Remove both cfgs, run exact-once ordinary/canonical, promote only Rust, and lock topology.
  - [x] **PUBLIC / NO-DRIFT** — Advance only governed current guidance and preserve production, schemas, surfaces, README, storage, and later RED legs.
  - [x] **SIGNOFF / CLEAN** — Sync durable layers; pass Rust/book/doctrine/canonical gates; land atomic 191/300 clean.

  Evidence 2026-08-10/11: clean activation `1cf2923aa749594a8c56903418fe5749134f6872`/`fd8a1934` (atomic 190) had Knowledge 808/6,693, eight doctrines, valid pointer/maps, zero brief/residue/background work, and sole task-first mutation. Retrieval proved nested 12/12 and ordinary zero; admission removed both cfgs, retained the internal authority, and registered that exact 12/12 target once. Checker proof is semantic 132/246/42, rollout 3/9, public 3/11/25, guide 1/4/8, Rust admission 8; a first ordinary run caught stale consumer expectations, then Rust format/Clippy/local passed (core 195, runtime 166, CLI 66x2). Book 79/14,380 KiB rendered Perl+Rust current with clean block structure; browser control was unavailable, so no visual claim is made. After an outer-sandbox containment denial and isolated authorized pass, one uninterrupted authorized canonical run passed eight doctrines, Perl 51, Rust 12, containment/relocation, CLI 66x2, RAM 77%, and Phase 0 1,031 in 739 seconds. Atomic 191 is clean `02c612f5`.

- ID: `FUTURE-PARITY-BACKLOG.14.3.4`
  Status: `complete` (2026-08-11; all four Dart transaction children landed cleanly through atomic 196/300
    `38318827`; no push)
  Goal: Implement and independently admit exact Dart parity while retaining native UTF-16 register compatibility.
  Depends on: `.14.3.3`
  Children: `.14.3.4.0-.14.3.4.3`
- ID: `FUTURE-PARITY-BACKLOG.14.3.4.0`
  Status: `complete` (2026-08-11; corrective atomic 192 and dormant Dart RED atomic 193 landed cleanly)
  Goal: Establish a sound neutral boundary, then freeze dormant Dart RED across all carriers.
  Depends on: `.14.3.3.3`
  Children: `.14.3.4.0.0-.14.3.4.0.1`
- ID: `FUTURE-PARITY-BACKLOG.14.3.4.0.0`
  Status: `complete` (2026-08-11; clean atomic 192/300 `b1c59d03`; no push)
  Goal: Repair the neutral transaction policy that canonically enforced a stale Perl-only current boundary after Rust admission.
  Depends on: `.14.3.3.3`
  Acceptance: Derive `policy.current_boundary` from rollout truth, reject the stale duplicate literal, preserve all
    governed counts/surfaces, and pass complete signoff.
  Verification: blame proves `02c612f5` omitted the field; repaired checker rejects stale prose; eight doctrines,
    semantic 132/246/42, capability 80/0/0, CLI 66x2, RAM 45%, and Phase 0 1,031 in 721 sec pass.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.4.0.0 - repair transaction boundary policy`
  Evidence: policy/current/checker truth is neutral+Perl+Rust 3/9; `b1c59d03` landed exact no-drift proof cleanly.
- ID: `FUTURE-PARITY-BACKLOG.14.3.4.0.1`
  Status: `complete` (2026-08-11; clean atomic 193/300 `3a29b34e`; no push)
  Goal: Freeze dormant Dart RED across native, reconstructed, generated-plan, and freshly emitted carriers.
  Depends on: `.14.3.4.0.0`
  Acceptance: Freeze one final-path dormant exact-contract consumer at only missing private authority; preserve
    production/UTF-16/counts/public/canonical/storage truth and pass complete signoff.
  Verification: explicit RED reaches only absent module/types; Dart 383, book 79/14,380 KiB, eight doctrines,
    semantic 128/9/9, capability 80/0/0, CLI 66x2, and Phase 0 1,031 in 700 sec pass.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.4.0.1 - freeze Dart transaction RED`
  Evidence: `3a29b34e` landed exact dormant RED with zero brief/status/residue and valid pointer/maps.
- ID: `FUTURE-PARITY-BACKLOG.14.3.4.1`
  Status: `complete` (2026-08-11; atomic 194/300 from clean activation `3a29b34e`; no push)
  Goal: Add private Dart invocation-frame, mark-generation, opaque-token, snapshot, and invalidation authority.
  Depends on: `.14.3.4.0`
  Acceptance: Implement/prove the private authority, stop at exact `.2` seams, preserve all current truth, and sign off.
  Verification: default 6/4 and enabled four-seam RED; Dart 383, book 79/14,392 KiB, eight doctrines, CLI 66x2,
    RAM 65%, and Phase 0 1,031/1,031 in 697 sec pass unchanged.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.4.1 - add private Dart transaction authority`
  Evidence: clean `f6f154c6` lands unexported authority plus owner-21 repair with valid pointer/maps and zero residue.
- ID: `FUTURE-PARITY-BACKLOG.14.3.4.2`
  Status: `complete` (2026-08-11; clean atomic 195/300 `bee6cf45`; no push)
  Goal: Integrate exact Dart syntax/runtime/effect/progress parity through all required carriers.
  Depends on: `.14.3.4.1`
  Acceptance: Integrate four dedicated nodes plus policy/runtime carriers; stay dormant/unexported and sign off.
  Verification: enabled 10/10, default 6/4, Dart 100/383/21/47/66x2/105, book 79/14,396 KiB, eight doctrines,
    RAM 64%, and Phase 0 1,031/1,031 pass without rollout movement.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.4.2 - integrate Dart recognition transactions`
  Evidence: clean `bee6cf45` lands private integration with valid pointer/maps, zero residue, and `.3` next.
- ID: `FUTURE-PARITY-BACKLOG.14.3.4.3`
  Status: `complete` (2026-08-11; clean atomic 196/300 `38318827`; no push)
  Goal: Remove Dart dormancy, register ordinary/canonical proof, and promote only Dart transaction admission.
  Depends on: `.14.3.4.2`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.4.3 - admit Dart recognition transactions`
  Evidence: exact consumer 10/10; neutral 132/246/43 at rollout 4/9; public 3/14/29; guide 1/6/10; Dart
    100/393/21/47/66x2/105; book 79/14,396 KiB; all doctrines; RAM 60%; Phase 0 1,031/1,031 in 694 sec. Clean
    `38318827` retains the private authority, aligned Perl/Rust metadata, valid maps/pointer, and zero residue.
- ID: `FUTURE-PARITY-BACKLOG.14.3.5`
  Status: `complete` (2026-08-11; all four Julia transaction children are signoff-complete through commit-ready
    atomic 200/300 from clean `0d15f8c2`; shared Lua RED `.14.3.6.0` follows only after landing; no push)
  Goal: Implement and independently admit exact Julia parity while retaining native code-unit register compatibility.
  Depends on: `.14.3.4`
  Children: `.14.3.5.0-.14.3.5.3`
- ID: `FUTURE-PARITY-BACKLOG.14.3.5.0`
  Status: `complete` (2026-08-11; clean atomic 197/300 `8db3aeee`; no push)
  Goal: Freeze dormant Julia RED across native, reconstructed, generated-plan, and independently loaded emitted
    module carriers.
  Depends on: `.14.3.4.3`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.5.0 - freeze Julia transaction RED`
  Evidence: clean `8db3aeee` freezes both modes solely at absent private authority with Julia typed source 127,
    storage 19/5, CLI 66x2, corpus 105, RAM 60%, and Phase 0 1,031/1,031 in 724 sec; exact maps/pointer, zero
    residue, and no production/discovery/rollout movement.

- ID: `FUTURE-PARITY-BACKLOG.14.3.5.1`
  Status: `complete` (2026-08-11; clean atomic 198/300 `923285aa`; no push)
  Goal: Add private Julia invocation-frame, mark-generation, opaque-token, snapshot, and invalidation authority
    while retaining native code-unit registers and current routes.
  Depends on: `.14.3.5.0`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.5.1 - add private Julia transaction authority`
  Evidence: clean `923285aa` lands non-exported authority at 155/155; integration stops at zero dedicated nodes and
    absent effect/progress/runtime routes. Julia 127/19/5/66x2/105, book 79/14,404 KiB, eight doctrines, RAM 68%,
    and canonical Phase 0 1,031/1,031 in 747 sec pass with recognition 132/246/43 and rollout 4/9 unchanged.

- ID: `FUTURE-PARITY-BACKLOG.14.3.5.2`
  Status: `complete` (2026-08-11; atomic 199/300 from clean activation `923285aa`; no push)
  Goal: Integrate exact Julia syntax/runtime/effect/progress parity through all required carriers.
  Depends on: `.14.3.5.1`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.5.2 - integrate Julia recognition transactions`
  Evidence: four private non-eager nodes plus recursive effect/cursor-progress policy and one authority-backed
    native/reconstructed/generated-plan/emitted adapter pass integration 203/203 and authority 155/155. Julia
    typed source 127/storage 19/5/CLI/corpus 105, book 79/14,404 KiB, eight doctrines, CLI 66x2, RAM 65%, and
    canonical Phase 0 1,031/1,031 in 731 sec pass; rollout stays 4/9 and discovery/export remain dormant.
- ID: `FUTURE-PARITY-BACKLOG.14.3.5.3`
  Status: `complete` (2026-08-11; definitive signoff complete and commit-ready as atomic 200/300 from clean
    activation `0d15f8c2`; no push)
  Goal: Remove Julia dormancy, register ordinary/canonical proof, and promote only Julia transaction admission.
  Depends on: `.14.3.5.2`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.5.3 - admit Julia recognition transactions`
  Evidence: exact Julia 203/203 is ordinary/canonical once without selector/conditional dormancy; the namespace
    remains private/unexported. Neutral 132/246/44 at rollout 5/9, public 3/17/33, guide 1/8/12, Perl 51/51, Rust
    12/12, Dart 10/10, complete Julia package/primary/corpus 105, book 79/14,404 KiB, all eight doctrines, CLI 66x2,
    RAM 69%, and canonical Phase 0 1,031/1,031 in 738 sec pass through the exact success marker; Lua/later remain RED.
- ID: `FUTURE-PARITY-BACKLOG.14.3.6`
  Status: `complete` (2026-08-11; admission `.3` signoff-complete as atomic 204/300 from `70b4ed04`; no push)
  Goal: Implement one shared Lua transaction/progress core and independently admit it on PUC Lua and LuaJIT.
  Depends on: `.14.3.5`
  Children: `.14.3.6.0-.14.3.6.3`
- ID: `FUTURE-PARITY-BACKLOG.14.3.6.0`
  Status: `complete` (2026-08-11; clean atomic 201/300 `6a8ec091`; no push)
  Goal: Freeze one shared dual-ABI dormant final-path RED.
  Depends on: `.14.3.5.3`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.6.0 - freeze Lua transaction RED`
  Evidence: four modes stopped at missing authority; 12 mutations and full signoff passed; clean `6a8ec091`.
- ID: `FUTURE-PARITY-BACKLOG.14.3.6.1`
  Status: `complete` (2026-08-11; clean atomic 202/300 `d87dcac3`; no push)
  Goal: Add one shared private Lua invocation/mark/snapshot/linear-token authority.
  Depends on: `.14.3.6.0`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.6.1 - add private Lua transaction authority`
  Evidence: authority 187x2, 22+12 mutations, and full signoff passed; clean `d87dcac3`.
- ID: `FUTURE-PARITY-BACKLOG.14.3.6.2`
  Status: `complete` (2026-08-11; clean atomic 203/300 `70b4ed04`; no push)
  Goal: Integrate syntax/runtime/effect/progress parity across all carriers on both Lua ABIs.
  Depends on: `.14.3.6.1`
  Commit: `FUTURE-PARITY-BACKLOG.14.3.6.2 - integrate Lua recognition transactions`
  Evidence: authority 187x2, integration 243x2, 22+19+12 mutations, full signoff, and clean `70b4ed04`.
- ID: `FUTURE-PARITY-BACKLOG.14.3.6.3`
  Status: `complete` (2026-08-11; signoff-complete atomic 204/300 from clean `70b4ed04`; no push)
  Goal: Remove Lua dormancy, register one consumer exactly once per ABI in ordinary/canonical proof, and promote PUC Lua plus LuaJIT transaction admission independently.
  Depends on: `.14.3.6.2`
  Acceptance: Retrieve the Lua integration and admitted backend authorities before edits; remove only RED selector/dormancy scaffolding; register the unchanged consumer exactly once per ABI in ordinary/canonical routes; promote only those two rollout legs and exact ledgers while keeping the API private.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.6.3 - admit Lua recognition transactions`
  Checklist: [x] clean activation/task ownership; [x] authority/predecessor audit; [x] remove dormancy; [x] ordinary
    dual-ABI registration; [x] canonical registration; [x] governance/mutations; [x] no-drift; [x] docs/signoff.
  Evidence: PUC/LuaJIT 243x2, Lua package 177x2, CLI 66x2, corpus 105, checker 46/38/14 + Lua 22, book
    79 files/14,412 KiB, Knowledge 818/6,792, all eight doctrines, RAM 65%, and Phase 0 1,031/1,031 in 758 sec pass.
- ID: `FUTURE-PARITY-BACKLOG.14.3.7`
  Status: `done` (2026-08-11; signoff-complete atomic 205/300 from clean `1aedfe98`; no push)
  Goal: Bind the unchanged neutral and five-backend/six-runtime consumers into one exact repository-routed recurring proof with omission/order/multiplicity/storage/canonical governance.
  Depends on: `.14.3.6`
  Acceptance: Add one fail-fast project-data-routed driver over the neutral checker, exact Perl/Rust/Dart/Julia/PUC Lua/LuaJIT consumers, and support ledgers; lock driver/CI/order/path/multiplicity/storage topology, promote only recurring, preserve public no-drift RED and every runtime/API/schema/CLI/README boundary, then pass focused/book/doctrine/canonical signoff.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.7 - compose recognition transaction proof`
  Checklist: [x] clean activation/task ownership; [x] authority/topology audit; [x] driver/CI route; [x] governance/mutations; [x] focused six-runtime proof; [x] no-drift/docs/book; [x] doctrine/canonical signoff.
  Evidence: driver passes Perl 51, Rust 12, Dart 10, Julia 207, Lua 246x2, support ledgers, and routing; checker 58 at rollout 8/9, public 3/23/42, guide 1/12/16; book 79/14,428, Knowledge 819/6,803, eight doctrines, CLI 66x2, RAM 62%, and canonical Phase 0 1,031/1,031 in 745 seconds pass. No runtime/API/schema/CLI/README behavior changes; `.14.3.8` follows only after clean atomic 205.
- ID: `FUTURE-PARITY-BACKLOG.14.3.8`
  Status: `done; signoff-complete` (2026-08-11; atomic 206/300 from clean recurring commit `e6893fd4`; no push)
  Goal: Recompose the committed contract, six runtime admissions, recurring authority, support ledgers, and public boundary unchanged; close `.14.3` and hand off cleanly to recursive observation `.14.4`.
  Depends on: `.14.3.7`
  Acceptance: Retrieve and hash the committed authorities first; promote only final public no-drift, reject stale/current projection drift, re-run the exact six-runtime/support composition and broader gates, close `.14.3`, and preserve parser/runtime/facade/schema/CLI/README behavior.
  Commit: `FUTURE-PARITY-BACKLOG.14.3.8 - close recognition transaction rollout`
  Checklist: [x] clean activation/task ownership; [x] committed-authority retrieval; [x] public no-drift governance; [x] exact recomposition; [x] activity/roadmap/book/live closeout; [x] doctrine/canonical signoff.
  Evidence: committed hashes retained; driver passes Perl 51, Rust 12, Dart 10, Julia 207, Lua 246x2 plus support ledgers; checker 132/246/58 at 9/9, public 3/26/45, guide 1/14/18; book 79/14,428, Knowledge 820/6,813, eight doctrines, CLI 66x2, RAM 60%, and Phase 0 1,031/1,031 in 722 seconds pass without runtime/API/CLI/README movement.

- ID: `FUTURE-PARITY-BACKLOG.14.4`
  Status: `active` (2026-08-12; behavior-free audit `.0` activated from clean transaction closeout `3ac018f8`); Goal: Expose immutable recursive rule entry/match/accepted-exit positions and bounded parent/child provenance without allowing a parent to override the child's intrinsic cursor policy or retaining backend/runtime objects; Children: `.14.4.0`, corrective prerequisite `.14.4.0.1`, then `.14.4.1-.14.4.8` in neutral, Perl, Rust, Dart, Julia, shared-Lua, recurring, and public order.
- ID: `FUTURE-PARITY-BACKLOG.14.4.0`
  Status: `done; signoff-complete` (2026-08-12; task-tree-first from clean `3ac018f8`; intended atomic 207/300; no push); Goal: Audit the current five-backend/six-runtime recursive entry/local-match/accepted-exit and caller/child seams, then freeze portable observation values, invocation/provenance identity, intrinsic cursor-policy invariants, recursion/cycle/error boundaries, carrier/API exclusions, and exact corrective/`.1-.8` ownership without behavior; Depends on: `.14.3.8`; Acceptance: retrieve ADR `0056`, Knowledge cards, task history, and toolbox first; probe actual runtime mechanisms and source locations rather than infer them; record hashes/current divergences and an executable neutral-plan boundary; synchronize roadmap/ADR/book/live/Knowledge; change no parser/compiler/runtime/backend/schema/facade/CLI/README behavior; pass focused/book/doctrine/canonical signoff and land clean before `.14.4.0.1`; Commit: `FUTURE-PARITY-BACKLOG.14.4.0 - audit recursive source observation`; Checklist: [x] clean activation/task ownership; [x] canonical authority retrieval; [x] LinkedSpec-tool runtime audit; [x] portable contract/diagnostic/split freeze; [x] roadmap/ADR/book/live/Knowledge alignment; [x] no-behavior proof; [x] doctrine/canonical signoff; Finding: `direct_nonprogress` self-parents despite monotonic non-reused invocation identity because the checker compares exact fixture rows but enforces no distinct/order/cycle invariant; `.14.4.0.1` owns correction before executable observation work; Evidence: committed blobs neutral `7663edf5/80b85e86`, Perl `07ff872d/2cc9cefa/a020f1c1`, Rust `5801b30f/d7f39fcb/1bf17d9b`, Dart `770a183e/0867a6de/534ad289`, Julia `bf55e355/aa060778/9f1390d4`, Lua `5ad6f644/2b8f4050/6982f7b9/11d8e464`; LinkedSpec probes prove edge/direct entry and child family policy; focused typed source six-runtime, recognition 132/246/58, cursor 36/18/8, book 79/14,460 KiB, Knowledge 821/6,826, all eight doctrines, containment/relocation including the six-family process sandbox, CLI 66x2, RAM 59%, and canonical Phase 0 1,031/1,031 in 832 seconds pass through the exact local-CI success marker.
- ID: `FUTURE-PARITY-BACKLOG.14.4.0.1`
  Status: `done; signoff-complete` (2026-08-12; task-tree-first from clean audit commit `2c968259`; intended atomic 208/300; no push); Goal: Correct the direct/mutual non-progress neutral invocation-lineage fixtures and make the checker reject self-parent, reused identity, invalid parent ordering, and cyclic bounded provenance before `.14.4.1` extends the executable observation authority; Depends on: `.14.4.0`; Acceptance: preserve the six observation roles and current behavior/public boundary; allocate each rejected attempted child a distinct monotonic identity from the existing invocation authority with the active frame as parent; add exact RED/positive/mutation proof; synchronize durable docs and land clean; Commit: `FUTURE-PARITY-BACKLOG.14.4.0.1 - correct recursive observation lineage`; Checklist: [x] clean activation/task ownership; [x] committed-authority retrieval; [x] RED lineage-invariant proof; [x] fixture/checker correction; [x] mutation and focused proof; [x] roadmap/ADR/book/live/Knowledge alignment; [x] doctrine/canonical signoff; Evidence: exact RED against the committed textual fixture reports `recursive invocation identity must be a positive integer`; corrected six-role neutral proof passes 57/57 mutations; direct/mutual rejected attempts are children `9`/`11` under active parents `8`/`10`; composed proof passes Perl 10, Rust/Dart 4/4, Julia 127, PUC Lua/LuaJIT 240/240, generated-source strict Rust 105/105, capability 80/0/0, and language 246 current / 105 corpus + 1 named-mark / 122 public Perl; book 79/14,460 KiB, Knowledge 821/6,826, all eight doctrines, containment/relocation including the six-family process sandbox, CLI 66x2, RAM 34%, and canonical Phase 0 1,031/1,031 in 739 seconds pass through exact local-CI success.
- ID: `FUTURE-PARITY-BACKLOG.14.4.1`
  Status: `done; signoff-complete` (2026-08-12; task-tree-first from clean lineage commit `53c687d3`; intended atomic 209/300; no push); Goal: Make the neutral recursive-observation contract executable over the existing invocation authority, selecting exact authored accessors/carrier projection and deterministic entry, local-match, accepted-exit, failure, abort, and pre-entry rejection transitions without runtime implementation; Depends on: `.14.4.0.1`; Acceptance: retrieve committed neutral/ADR/Knowledge/toolbox authorities first; add bounded state-machine fixtures and independent validation for action-edge/direct entry, zero-regex absence, terminal local-match replacement, accepted-only exit, all four outcomes, fresh rejected-child provenance, detach/no-history behavior, and child-owned cursor policy; add reason-checked mutations and typed diagnostics; preserve rollout 8/6 plus every runtime/API/schema/semantic/MCP/CLI/README boundary; synchronize task/roadmap/live/Knowledge/mdBook; pass focused/composed/book/doctrine/canonical proof; Commit: `FUTURE-PARITY-BACKLOG.14.4.1 - execute neutral recursive observation`; Checklist: [x] clean activation/task ownership; [x] committed authority retrieval; [x] exact RED; [x] syntax/carrier freeze; [x] 33-transition machine; [x] diagnostics/reason-checked mutations; [x] six-runtime/no-drift composition; [x] roadmap/ADR/Knowledge/book/live alignment; [x] doctrine/canonical signoff; Evidence: exact RED first failed on missing ordered contract fields; neutral proof passes 8+8+33 transitions, six recursive observations, 33 diagnostics, and all 70 mutations at unchanged rollout 8/6; composed proof passes Perl 10, Rust/Dart 4/4, Julia 127, PUC Lua/LuaJIT 240/240, strict generated Rust 105/105, capability 80/0/0, and language 246 current / 105 corpus + 1 named mark / 122 public Perl; rendered book, Knowledge 821/6,831, all eight doctrines, six-family containment, repository relocation, CLI 66x2, RAM 35%, and canonical Phase 0 1,031/1,031 in 714 seconds pass through exact local-CI success without runtime/API/schema/semantic/MCP/CLI/README movement.
- ID: `FUTURE-PARITY-BACKLOG.14.4.2`
  Status: `done; signoff-complete` (2026-08-12; task-tree-first from clean neutral commit `6e3b77c0`; intended atomic 210/300; no push); Goal: Implement and admit the exact private Perl recursive-observation authority and selected carrier/accessor surface from neutral `.1`; Depends on: `.14.4.1`; Acceptance: retrieve the committed neutral/Perl invocation, generated-handler, carrier, test, CI, ADR, Knowledge, and Toolbox authorities before implementation; add the exact private authority, authored lowering, runtime detach, ordinary/canonical consumer, rollout/no-drift/storage governance, and positive/failure/abort/rejection/cursor/history proof while preserving child payloads, generated-handler family/cursor ownership, and every non-Perl/runtime/public/schema/semantic/MCP/CLI/README boundary; synchronize docs/book/live/Knowledge; pass focused/composed/book/doctrine/canonical signoff; Commit: `FUTURE-PARITY-BACKLOG.14.4.2 - admit Perl recursive observation`; land clean before Rust `.14.4.3`; Checklist: [x] clean activation/task ownership; [x] committed authority retrieval; [x] exact final-path RED; [x] dedicated ActionIR/static policy; [x] private invocation/runtime/detach implementation; [x] live/generated final-path consumer; [x] rollout/effect/language no-drift; [x] exact six-runtime typed-source composition; [x] book/Knowledge/doctrine/canonical signoff; Evidence: the RED consumer first failed because the special form lowered through unsupported generic call/assignment handling. Focused GREEN passes 17 Perl typed-source tests including seven recursive-observation groups, transaction authority/contract, generated-source, and ActionIR regressions. Neutral governance passes 8+8+33 / 71 at rollout 8/6 with only Perl on the pending observation row; recognition passes 133 = 129+4 / 246 / 58; language passes 246/105+1/122. The exact six-runtime typed-source driver passes Perl 17, Rust/Dart 4/4, Julia 127, Lua 240/240 per ABI, generated-source 105/105, capability 80/0/0, and language coverage. Canonical proof first stopped at Rust's stale 128-node neutral snapshot, then the focused recurring route exposed Dart's paired 132 aggregate. Exhaustive review aligned the metadata-only live/aggregate assertions to 129/133 in Rust, Dart, Julia, and Lua without changing transaction behavior or rollout. Definitive signoff passes rendered book 79/14,508 KiB, Knowledge 822/6,843, all eight doctrines, repository containment/relocation, CLI 66x2, RAM 50%, Phase 0 1,031/1,031 in 723 seconds, and the complete six-runtime typed-source opt-in through exact `[ci] local CI gate passed` with exit 0.
- ID: `FUTURE-PARITY-BACKLOG.14.4.3`
  Status: `done; signoff-complete` (2026-08-12; task-tree-first from clean Perl-admission commit `2d937d83`; intended atomic 211/300; no push); Goal: Implement and admit the exact private Rust recursive-observation authority across native, reconstructed, generated-plan, and emitted carriers; Depends on: `.14.4.2`; Acceptance: retrieve the committed neutral/Perl/Rust invocation, carrier, emitted-source, test, CI, ADR, Knowledge, and Toolbox authorities before implementation; write exact final-path RED before production edits; reuse the source-local monotonic invocation authority and detached nine-field carrier semantics; preserve UTF-8-byte registers, child-owned family policy, falsey payloads, typed failures, cursor/mark behavior, and history absence; execute every neutral positive/failure/abort/rejection/cursor/detach case across native, reconstructed, generated-plan, and independently compiled emitted carriers; promote only Rust; lock ordinary/canonical/storage/public no-drift; synchronize task/roadmap/live/Knowledge/mdBook; pass focused/composed/book/doctrine/canonical signoff; commit as `FUTURE-PARITY-BACKLOG.14.4.3 - admit Rust recursive observation`; clear the brief and land clean before Dart `.14.4.4`; Checklist: [x] clean activation/task ownership; [x] committed authority retrieval; [x] exact final-path RED; [x] private Rust node/policy/authority/runtime implementation; [x] four-carrier execution; [x] rollout/effect/language no-drift; [x] exact six-runtime composition; [x] roadmap/ADR/Knowledge/book/live alignment; [x] doctrine/canonical signoff; [x] atomic commit/clean handoff; Evidence: clean activation boundary `2d937d83`; no Rust behavior changed before ownership. Knowledge retrieval followed the canonical recursive-observation audit, Perl admission, Rust transaction, and typed-source rollout cards before code archaeology. ADR 0056 sections 19-22, the exact neutral contract/checker, TOOLBOX recurring/transaction routes, Perl final-path consumer/runtime, and Rust Expr/parser/invocation/runtime/action-edge/generated-plan/emitter/final-path seams agree that one dedicated static form must reuse the existing invocation authority, publish one ephemeral detached completion, preserve byte-register child policy and payloads, and route emitted source through the effective engine without a second stack or history. The new ordinary-discovery final-path consumer first reaches exact RED at Rust `E0599`: `Expr::ObserveRecognition` does not exist. No production source was edited before this absent dedicated-node boundary was captured. GREEN adds one serialized `ObserveRecognition` node; fail-closed target/operand and rule/function effect closure; parent/rejected identity from the existing authority; pending-entry-only observation scopes; ephemeral typed completion/detachment; rule-local target binding; action-edge single dispatch; and the effective emitted-source route. Review found and corrected two latent defects before signoff: the executable availability sentence still falsely denied all runtime admission after Perl, and a scope that remained armed after successful entry could misclassify a later ordinary child self-call. Exact regressions now lock current Perl/Rust availability, nested ordinary-cutoff separation, and bind-before-error propagation. Focused final-snapshot proof passes the internal abort-binding test plus all seven native/reconstructed/generated-plan/emitted observation tests; the combined Rust transaction/observation/typed-source run passes 12+7+4. Exact six-runtime composition passes Perl 17, Rust observation 7 plus typed source 4, Dart 4, Julia 127, PUC Lua/LuaJIT 240/240, generated-source strict Rust 105/105, capability 80/0/0, and language 246/105+1/122. The rendered book passes 79 files / 14,512 KiB, Knowledge passes 823 facts / 6,856 question keys, recognition stays 129+4/246/58, and all eight doctrines pass. A raw all-target `-D warnings` probe exposed 16 unrelated pre-existing core lints; the task-introduced `unused_mut` was removed, and repository canonical CI remains the lint/test authority. The first canonical invocation correctly stopped at the tracked-input guard before staging the new consumer. The staged canonical run then exposed cross-contract drift because the new observation-only action-edge branches raised the governed `collect_or_return_action_value!` seam from eight to ten occurrences. Root-cause review against the repeated-action Knowledge authority showed observation and existing self-finalizer edges share the same execute/collect path; consolidating those conditions restores the exact eight-seam topology without changing single-dispatch observation or repetition collection semantics. Focused rerun passes recursive observation 7/7 and repeated-action behavior 3/3 after the repair. Definitive signoff passes exact six-runtime typed-source composition, five-backend repeated-action composition, containment/relocation, CLI 66x2, RAM 46%, and canonical Phase 0 1,031/1,031 in 744 seconds through exact `[ci] local CI gate passed` with exit 0.
- ID: `FUTURE-PARITY-BACKLOG.14.4.4`
  Status: `pending`; Goal: Implement and admit the exact private Dart recursive-observation authority across native, reconstructed, generated-plan, and emitted carriers; Depends on: `.14.4.3`; Acceptance: reuse the source-local monotonic invocation authority, preserve UTF-16 registers and child policy, execute the neutral cases, promote only Dart, lock ordinary/canonical/storage/public no-drift, synchronize docs, and land clean before Julia.
- ID: `FUTURE-PARITY-BACKLOG.14.4.5`
  Status: `pending`; Goal: Implement and admit the exact private Julia recursive-observation authority across native, reconstructed, generated-plan, and emitted carriers; Depends on: `.14.4.4`; Acceptance: reuse the source-local monotonic invocation authority, preserve code-unit registers and child policy, execute the neutral cases, promote only Julia, lock ordinary/canonical/storage/public no-drift, synchronize docs, and land clean before Lua.
- ID: `FUTURE-PARITY-BACKLOG.14.4.6`
  Status: `pending`; Goal: Implement one shared Lua-5.1-compatible recursive-observation authority and admit it independently on PUC Lua and LuaJIT across all carriers; Depends on: `.14.4.5`; Acceptance: reuse the source-local monotonic authority, preserve UTF-8-byte registers and child policy, execute the neutral cases once per ABI, promote only both Lua rows, lock ordinary/canonical/storage/public no-drift, synchronize docs, and land clean before recurrence.
- ID: `FUTURE-PARITY-BACKLOG.14.4.7`
  Status: `pending`; Goal: Compose the unchanged neutral and five-backend/six-runtime recursive-observation consumers plus support ledgers into one exact repository-routed recurring proof; Depends on: `.14.4.6`; Acceptance: bind sources/routes/commands/order/multiplicity/storage/canonical registration, promote only recurrence, reject topology drift, preserve public RED and runtime/API/schema/CLI/README behavior, synchronize docs, and land clean before public closeout.
- ID: `FUTURE-PARITY-BACKLOG.14.4.8`
  Status: `pending`; Goal: Complete recursive-observation public projection/no-drift and close `.14.4` without widening the exact neutral surface; Depends on: `.14.4.7`; Acceptance: promote only the selected public row, reject stale/current prose and premature surface drift, recompose all six runtimes/support ledgers, synchronize examples/Toolbox/Knowledge/mdBook/roadmaps/live docs, pass definitive gates, close the parent, and land clean before `.14.5` or another eligible activity.

- ID: `FUTURE-PARITY-BACKLOG.14.5`
  Status: `pending`
  Goal: Compose stable named regex-slot identity and the separately owned `INTER-MATCH-GAP-CAPTURE` contract into
    lossless prefix/gap/tail span segmentation without duplicating its syntax, lifecycle, or compatibility owner.
- ID: `FUTURE-PARITY-BACKLOG.14.6`
  Status: `pending`
  Goal: Specify and implement span-native progressive in-parse invocation of loaded specs at arbitrary safe points,
    preserving source provenance, diagnostic coordinates, policy ceilings, cancellation, and zero implicit paths.
- ID: `FUTURE-PARITY-BACKLOG.14.7`
  Status: `pending`
  Goal: Specify and implement staged AST enrichment where later loaded specs parse selected exact spans returned by
    an earlier AST level and stitch typed results through deterministic parse jobs.

- ID: `FUTURE-PARITY-BACKLOG.14.8`
  Status: `pending`
  Goal: Recompose six-runtime admissions and recurring governance, close examples/tooling/mdBook/Knowledge Map
    alignment, reject stale-helper and unsafe-cursor drift, and complete public no-drift for the full authoring model.

<!-- Source ranges and their immutable migration digest are recorded in docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl. -->
