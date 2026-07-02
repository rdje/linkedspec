# STAGED-LINKED-PARSING: Staged linked parse graph architecture

## Metadata

- Tree ID: `STAGED-LINKED-PARSING`
- Status: `active`
- Roadmap lane: `Overall roadmap — .spec language model / parser composition`
- Created: `2026-07-02`
- Last updated: `2026-07-02`
- Owner: repo-local workflow

## Goal

Make LinkedSpec's staged parser-composition model explicit and executable: a
stage-N `.spec` may parse only the structure that is easy to anchor, emit raw
text islands with source provenance, and route each island to one or more
next-stage `.spec` parsers that refine those payloads into deeper AST nodes.

## Non-Goals

- Do not add runtime parser-dispatch implementation in the first leaf.
- Do not add a permanent user-function grammar to the bootstrap parser.
- Do not replace the current user-function MVP surface.
- Do not conflate spec-file inclusion/composition with staged payload parsing.

## Acceptance Criteria

- The staged linked parsing doctrine is recorded as a durable decision.
- The task tree distinguishes spec imports/composition from staged parse
  dispatch.
- The public mdBook explains that `spec.spec` is the first loaded grammar for
  `.spec` language evolution and that later parsers derive from extracted
  payloads, not competing bootstrap grammar.
- Follow-up leaves are named for implementation planning: spec imports,
  parse-job annotations/metadata, parser registry/dispatch, and diagnostics.
- Live docs, roadmap, Knowledge Map, and memory are updated.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `STAGED-LINKED-PARSING`
  Status: `active`
  Goal: Adopt and then implement staged linked parsing as a first-class
    LinkedSpec architecture.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `STAGED-LINKED-PARSING.1`
  Status: `done`
  Goal: Adopt the staged linked parsing doctrine before implementation.
  Acceptance: Add ADR, task-tree index, mdBook architecture text, Knowledge
    Map fact, live-doc/roadmap/memory updates, and future-leaf split.
  Verification: **DONE 2026-07-02.** Added ADR `0012`, task-tree index row,
    roadmap/live-doc/memory entries, mdBook overview/design-rationale/pipeline
    and backend-handoff updates, and Knowledge Map fact
    `staged-linked-parsing-architecture`. Checks passed: `mdbook build
    docs/linkedspec-book`, `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.1 - adopt staged linked parsing doctrine`

- ID: `STAGED-LINKED-PARSING.2`
  Status: `done`
  Goal: Design spec-file imports/composition.
  Acceptance: Define import/include semantics, naming, dependency resolution,
    cycle diagnostics, and public syntax before code.
  Verification: **DONE 2026-07-02.** Added ADR `0013` for the
    language-neutral import/composition contract: future file-scope
    `import "path.spec" as alias` and `include "path.spec"` directives,
    qualified imported references, structured include merges, deterministic
    resolution, source-aware diagnostics, cycle/collision errors, descriptor
    fingerprinting, and an explicit not-yet-implemented status. Updated the
    mdBook, roadmap/live docs, task index, and Knowledge Map. Checks passed:
    `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.2 - specify spec import composition contract`

- ID: `STAGED-LINKED-PARSING.3`
  Status: `done`
  Goal: Design staged parse-job annotations and AST payload metadata.
  Acceptance: Define how a rule/action marks extracted text as a parse job,
    including node kind, parser spec id, top rule, source span, and failure
    policy.
  Verification: **DONE 2026-07-02.** Added ADR `0014` for the
    design-only `parse_job(text_expr, options)` annotation contract. The
    marker produces a stage-N AST value plus neutral sidecar metadata:
    deterministic job id, parent AST path, node kind, payload kind, exact
    text, source span/provenance, parser spec id, optional top rule, result
    policy, and failure policy. Result policies are `replace_marker`,
    `replace_field`, `sibling_field`, and `append_child`; failure policies are
    `fail`, `keep_text`, and `diagnostic_node`. Updated the mdBook,
    roadmap/live docs, task index, and Knowledge Map. Checks passed:
    `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.3 - specify staged parse-job annotations`

- ID: `STAGED-LINKED-PARSING.4`
  Status: `done`
  Goal: Design parser registry and dynamic next-stage dispatch.
  Acceptance: Define deterministic parser lookup/loading, cache keys, version
    boundaries, and how multiple payload kinds in one stage route to different
    next-stage specs.
  Verification: **DONE 2026-07-02.** Added ADR `0015` for the
    design-only staged parser registry and dispatch queue contract. The
    registry exposes neutral `resolve`, `load`, `compile`, and `execute`
    operations; resolution order covers parent import aliases/composed
    identities, declaring-spec-relative paths, configured search roots, and
    registry providers. Cache keys include normalized spec identity, content
    digest, import/include graph fingerprint, selected top rule, `.spec`
    language version, helper/action contract version, staged parsing contract
    version, and backend capabilities. Dispatch uses a stable queue ordered by
    parent AST path, source span, and job id; active-chain cycles repeat spec
    identity/top rule/payload digest/source span. Updated the mdBook,
    roadmap/live docs, task index, and Knowledge Map. Checks passed:
    `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.4 - specify staged parser registry dispatch`

- ID: `STAGED-LINKED-PARSING.5`
  Status: `active`
  Goal: Split and implement the first narrow staged-parsing prototype.
  Children: `.5.1`, `.5.2`, `.5.3`, `.5.4`, `.5.5`, `.5.6`
  Acceptance: Pick one self-contained payload family, parse it through a
    staged next-spec path, preserve source provenance, keep the contract 100%
    implementation-language neutral, and prove diagnostics plus parity gates.
  Verification: `active`
  Commit: `pending`

- ID: `STAGED-LINKED-PARSING.5.1`
  Status: `done`
  Goal: Select the first staged-prototype payload family and split executable
    implementation leaves.
  Acceptance: Choose the first self-contained payload family; record why it is
    narrow enough; make backend neutrality a hard acceptance condition for all
    prototype leaves; add/update ADR, task-tree, roadmap, mdBook, live docs,
    memory, and Knowledge Map with no runtime code change.
  Verification: **DONE 2026-07-02.** Split `.5` into executable leaves
    `.5.1` through `.5.6`, selected user-function body text as the first
    staged prototype payload family, added ADR `0016` for the mandatory
    implementation-language-neutrality rule, added Knowledge Map fact
    `staged-prototype-function-body-selection`, and synced the mdBook,
    roadmap/live docs, task index, and memory. No runtime code changed.
    Checks passed: `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.5.1 - select staged prototype payload family`

- ID: `STAGED-LINKED-PARSING.5.2`
  Status: `done`
  Goal: Audit the function-body staged-prototype seams before code.
  Acceptance: Map `specs/spec.spec` function-body extraction, current Perl/Rust
    temporary user-function bridges, body source/span records, diagnostics, and
    existing tests; derive the exact expected returned `function_definition` AST
    shape before implementation; inventory the function-definition variation
    matrix that must test the spec rule returning that AST; choose the dedicated
    small spec file/top rule used for focused AST-shape tests; identify the
    minimal next-stage spec/top-rule shape and the exact code seams to touch.
  Verification: **DONE 2026-07-02.** Read `specs/spec.spec`,
    `LinkedSpec::UserFunctionRegistry`, Rust parser/compiler/user-function
    structs, phase0 user-function locks, and Rust user-function parser/runtime
    tests; ran focused `LinkedSpec::Get` probes for direct-top, wrapper-top,
    whole-`specs/spec.spec`, named-capture, zero-arg, nested-body, quoted-brace,
    and regex-brace cases. Findings: (1) a direct top regex rule cannot read
    its own captures through `entry_group(...)`; the focused harness must use a
    tiny wrapper top rule that dispatches into a normal `function_definition`
    rule and collects results in `LX`; (2) the current numbered-capture
    `specs/spec.spec` rule mis-shapes zero-arg functions because optional
    captures are compacted, producing `params = "{ ... }"` and `body = null`;
    (3) the current body regex does not protect regex literals containing `{`
    or `}`, causing missed or truncated function bodies; (4) the Perl bridge
    preserves exact inner body text plus byte spans, while Rust trims
    `body_source` and records line spans only, so staged provenance must be a
    neutral contract rather than either storage shape. Added ADR `0017`,
    Knowledge Map fact `function-definition-staged-ast-audit`, mdBook/backend
    notes, live docs, roadmap, task index, and memory. No runtime code changed.
    Checks passed: `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1015 green).
  Commit: `STAGED-LINKED-PARSING.5.2 - audit function definition AST shape`

- ID: `STAGED-LINKED-PARSING.5.3`
  Status: `pending`
  Goal: Preserve source provenance for function-body payload parse jobs.
  Acceptance: Stage-N user-function records expose neutral body payload text,
    source span/provenance, parent AST path, function name, params, and payload
    kind without making Perl or Rust storage details part of the contract.
  Verification: `pending`
  Commit: `pending`

- ID: `STAGED-LINKED-PARSING.5.4`
  Status: `pending`
  Goal: Add the minimal neutral parse-job marker/sidecar prototype.
  Acceptance: Function-body payloads can be represented as staged parse jobs
    with deterministic job id, parser spec identity, top rule, result policy,
    failure policy, and source-aware diagnostics; the observable shape remains
    implementation-language neutral.
  Verification: `pending`
  Commit: `pending`

- ID: `STAGED-LINKED-PARSING.5.5`
  Status: `pending`
  Goal: Add the minimal registry/dispatch path for one next-stage spec.
  Acceptance: A deterministic registry resolves, loads, compiles, and executes
    the selected function-body parser spec/top rule through a stable queue,
    preserving neutral diagnostics and avoiding backend-specific semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `STAGED-LINKED-PARSING.5.6`
  Status: `pending`
  Goal: Prove the function-body staged prototype end to end.
  Acceptance: User-function bodies parse through the staged next-spec path,
    tests assert the predicted returned `function_definition` AST shape across
    a broad variation matrix of function definitions using a dedicated small
    spec file/top rule for focused AST-shape tests, current user-function
    semantics stay stable, source-provenance diagnostics are locked, public docs
    describe implemented behavior accurately, and Perl/Rust parity plus local
    gates pass.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `STAGED-LINKED-PARSING.5.3` | `pending` | The AST-shape audit identified the neutral function-definition payload/provenance shape; next preserve that source provenance in the implementation seam before parse-job dispatch. |

## Decisions

- `2026-07-02`: A LinkedSpec parse is allowed to be a staged graph rather than
  one monolithic grammar. Stage N may emit extracted text islands that later
  stages parse with one or more different specs.
- `2026-07-02`: Spec imports/composition and staged parse dispatch are separate
  features. Imports compose grammar/spec files; staged dispatch parses runtime
  payload text carried by AST nodes.
- `2026-07-02`: For `.spec` language evolution, `specs/spec.spec` is the first
  authoritative grammar. Permanent syntax such as user-defined functions must
  derive from that self-hosted grammar path, not from lasting bootstrap grammar.
- `2026-07-02`: Spec-file composition will use future file-scope directives:
  `import "path.spec" as alias` for qualified references and
  `include "path.spec"` for structured unqualified composition. This is
  grammar material reuse, not staged runtime payload parsing. Current shipped
  parsers do not yet accept those directives.
- `2026-07-02`: Staged runtime payloads will use a future
  `parse_job(text_expr, options)` marker that creates AST marker values plus
  neutral sidecar metadata. Current shipped parsers do not yet accept or
  execute that helper.
- `2026-07-02`: Staged parse jobs will dispatch through a deterministic
  registry and stable queue with explicit resolution order, cache keys,
  capability/version boundaries, isolated runtime contexts, result stitching,
  and cycle diagnostics. Current shipped parsers do not yet implement this
  queue.
- `2026-07-02`: Every staged linked parsing artifact is 100%
  implementation-language neutral: syntax, AST metadata, dispatch semantics,
  cache identities, diagnostics, tests, and docs must be specified over
  `.spec`/AST contracts rather than Perl5, Raku, Rust, Julia, Lua, Dart, Zig,
  Go, or any other host implementation.
- `2026-07-02`: The first prototype payload family is user-defined function
  body text. `specs/spec.spec` already extracts the body as a bounded text
  island, and current Perl/Rust bridges provide behavior to preserve while the
  staged path replaces bridge debt.
- `2026-07-02`: Function-body staged prototype tests must assert the predicted
  returned `function_definition` AST shape. Runtime behavior alone is not
  sufficient proof.
- `2026-07-02`: The spec-file rule that returns user-defined function AST must
  be tested thoroughly across many function-definition variations, including
  whitespace, zero/multiple parameters, nested bodies, strings, regex-looking
  text, comments or adjacent rules where applicable, and malformed definitions.
- `2026-07-02`: Function-definition AST-shape tests may and should use a
  dedicated small spec file/top rule focused on the user-function definition
  parser surface instead of only exercising the whole `specs/spec.spec` file.
- `2026-07-02`: The focused small-spec harness must use a wrapper top rule that
  dispatches to a normal `function_definition` rule; a direct top regex rule
  reads `entry_group(...)` as null because top rules have no entering match.
- `2026-07-02`: The current numbered-capture `specs/spec.spec`
  `function_definition` rule mis-shapes zero-arg functions and does not protect
  regex literals containing braces. The staged prototype must use named capture
  fields and exact source spans instead.
- `2026-07-02`: The target staged `function_definition` AST shape is
  source-ordered array elements with `type`, `name`, `params`, `arity`,
  `source_text`, `source_span`, exact inner `body_source`, `body_span`, a
  function-body parse job, and the staged `body_ast` once dispatch completes.

## Open Questions

- The exact implementation placement for the neutral source-span fields is
  deferred to `.5.3`.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-02` | `STAGED-LINKED-PARSING.1` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — mdBook builds; Knowledge Map is in sync; memory/doctrine/diff gates pass; full local CI passes with phase0 1015 green. |
| `2026-07-02` | `STAGED-LINKED-PARSING.2` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — mdBook builds; Knowledge Map is in sync; memory/doctrine/diff gates pass; full local CI passes with phase0 1015 green. |
| `2026-07-02` | `STAGED-LINKED-PARSING.3` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — mdBook builds; Knowledge Map is in sync; memory/doctrine/diff gates pass; full local CI passes with phase0 1015 green. |
| `2026-07-02` | `STAGED-LINKED-PARSING.4` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — mdBook builds; Knowledge Map is in sync; memory/doctrine/diff gates pass; full local CI passes with phase0 1015 green. |
| `2026-07-02` | `STAGED-LINKED-PARSING.5.1` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — broad prototype leaf split; function-body payload selected; ADR `0016`, mdBook, Knowledge Map, roadmap/live docs, task index, and memory synced; no runtime code change; full local CI passes with phase0 1015 green. |
| `2026-07-02` | `STAGED-LINKED-PARSING.5.2` | `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — function-definition AST-shape audit recorded; wrapper-top small-spec harness, named-capture requirement, zero-arg/regex-brace current gaps, neutral AST/provenance target, ADR `0017`, mdBook, Knowledge Map, roadmap/live docs, task index, and memory synced; no runtime code change; full local CI passes with phase0 1015 green. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `STAGED-LINKED-PARSING.1` | `STAGED-LINKED-PARSING.1 - adopt staged linked parsing doctrine` | ADR/book/KM/live-doc architecture adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.2` | `STAGED-LINKED-PARSING.2 - specify spec import composition contract` | ADR/book/KM/live-doc design adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.3` | `STAGED-LINKED-PARSING.3 - specify staged parse-job annotations` | ADR/book/KM/live-doc design adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.4` | `STAGED-LINKED-PARSING.4 - specify staged parser registry dispatch` | ADR/book/KM/live-doc design adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.5.1` | `STAGED-LINKED-PARSING.5.1 - select staged prototype payload family` | Payload-family selection and prototype split; no runtime code change. |
| `STAGED-LINKED-PARSING.5.2` | `STAGED-LINKED-PARSING.5.2 - audit function definition AST shape` | Function-definition AST-shape audit and neutral target contract; no runtime code change. |

## Changelog

- `2026-07-02`: `.1` done — staged linked parsing adopted as language-neutral doctrine; frontier moves to `.2`.
- `2026-07-02`: `.2` done — spec import/composition contract specified before implementation; frontier moves to `.3`.
- `2026-07-02`: `.3` done — staged parse-job annotation and metadata contract specified before implementation; frontier moves to `.4`.
- `2026-07-02`: `.4` done — staged parser registry/dispatch contract specified before implementation; frontier moves to `.5`.
- `2026-07-02`: `.5.1` done — broad prototype split; function-body payload selected as first staged prototype target; all follow-up leaves must stay implementation-language neutral; frontier moves to `.5.2`.
- `2026-07-02`: `.5.2` done — function-definition AST-shape audit captured wrapper-top harness, named-capture requirement, current zero-arg/regex-brace gaps, neutral target AST/provenance shape, and variation matrix; frontier moves to `.5.3`.
