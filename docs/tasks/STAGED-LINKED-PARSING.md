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
  Status: `active`
  Goal: Replace host-language user-function definition parsing with a
    spec-defined parser AST, then preserve that AST as the source-provenance
    payload for later parse-job dispatch.
  Children: `.5.3.1` (Perl reference), `.5.3.2` (remaining host-language
    bridge retirement, starting Rust)

- ID: `STAGED-LINKED-PARSING.5.3.1`
  Status: `done`
  Goal: Perl reference — consume a spec-defined user-function definition AST.
  Acceptance: `specs/user_function_definition.spec` is the executable grammar
    owner for `fn name(params) { body }` definition shells; it returns a
    source-ordered `function_definition` AST with parsed params, arity, exact
    source/body text, source/body spans, source-slice provenance, and neutral
    `body_payload`; the Perl registry consumes that AST rather than raw-scanning
    definition syntax; focused tests assert the predicted returned AST shape
    across many definition variations; the grammar uses linked opener/closer
    body rules where they make the definition parser easier to read or more
    predictable, while still allowing focused regex rules for local lexical
    tokens.
  Verification: **DONE 2026-07-02.** Added
    `specs/user_function_definition.spec` and direct AST-shape tests for
    zero-arg, whitespace-param, multi-param, multiline, nested-brace,
    string-brace, regex-brace, direct-shape, assignment, hash-index,
    adjacent-nested-brace, malformed, and unbalanced-body cases. The new spec
    uses direct `[...]` / `{ ... }` shapes and receiver/bare-variable forms; it
    does not use `declare(...)`, `array(...)`, `scalar(...)`, `hash(...)`, or
    `scalaref(...)`. `LinkedSpec::UserFunctionRegistry` now loads that spec
    parser, executes it over the source spec, validates the returned AST,
    post-annotates the source-order parent path, and strips definitions before
    bootstrap parsing. The previous raw Perl function-definition scanner
    helpers were removed. Runtime user-function execution remains unchanged
    after the definition AST is returned and the existing ActionIR body AST is
    stitched in. The uncommitted Rust raw-parser payload expansion was removed
    from this slice. A first monolithic-body regex draft was replaced before
    commit after the focused variation test exposed a runtime hang; the active
    spec now follows LinkedSpec's existing opener/closer plus linked-body-rule
    idiom. Generated-handler debug confirmed `body_brace` starts only on `{`
    and `function_definition[1]` owns the outer `}` close edge; focused tests
    lock both adjacent nested braces and unbalanced nested-body diagnostics.
    Checks passed: `perl -Iperl -c perl/LinkedSpec/UserFunctionRegistry.pm`,
    `perl -Iperl -c t/phase0_regression.t`, direct parser AST probes,
    generated-handler debug dump, focused descriptor payload probe,
    `perl -Iperl t/phase0_regression.t` (phase0 1016 green), `mdbook build
    docs/linkedspec-book`, `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh`.
  Commit: `STAGED-LINKED-PARSING.5.3.1 - consume spec-defined function AST in Perl`

- ID: `STAGED-LINKED-PARSING.5.3.2`
  Status: `done`
  Goal: Retire remaining host-language user-function definition parser bridges,
    starting with Rust, so user-defined function definitions are parsed only by
    the spec-defined parser contract.
  Acceptance: No backend maintains a competing raw grammar owner for
    `fn name(params) { body }` definition shells; Rust and any other active
    backend consume the same implementation-language-neutral AST contract from
    `specs/user_function_definition.spec` or a derived spec parser; parity
    tests prove direct `[...]` / `{ ... }` shape literals and returned
    `function_definition` AST shape are supported on the active variants;
    further grammar simplification is accepted when it improves readability or
    predictability, without treating complex regexes as forbidden when they are
    the cleanest local extractor.
  Verification: **DONE 2026-07-02.** Rust no longer owns a raw parser for
    top-level `fn name(params) { body }` shells. The core Rust rule parser
    rejects leading `fn` source and leaves `SpecFile.functions` empty for
    rule-only parsing; `linkedspec-runtime::spec_parser` now loads
    `specs/user_function_definition.spec`, executes it through the Rust
    runtime, validates the returned neutral `function_definition` /
    `function_definition_error` AST shape, strips definition spans, and attaches
    the resulting `FunctionDefinition` records before validation/compile.
    Rust preserves the returned `body_payload` into `CompiledUserFunction`.
    Runtime support needed by that spec was locked: PCRE-style named captures
    and leading inline flag toggles are normalized safely before composed RGX
    alternations, regex-literal delimiters work in `split`/`split_each`, bare
    `entry_named(name)` / `match_named(name)` read named capture keys, compact
    multiline lifecycle fluent chains such as `I.return({ ... })` collect their
    full argument before lowering, rule-local anonymous capture starts at the
    child entry end, and self-recursive finalizer edges such as
    `-> function_definition[1] { return(...) }` execute their block without
    seeking a later close. Focused Rust tests assert the exact returned AST
    shape across compact, spaced-param, multiline, nested-brace, string-brace,
    regex-brace, direct-shape, and malformed variants, plus the minimal
    edge-only `I.return(...).push(...)` regression. Checks passed:
    `cargo fmt`; focused Rust tests for `spec_defined_user_function_parser_*`,
    regex delimiter splitting, inline flag/named-capture normalization,
    edge-only scanner/child-I-return, `terse_2_3_2_`, named capture helpers,
    core parser, core user functions, shipped-spec parse/compile, and
    `cargo test -q -p linkedspec-runtime --test corpus_oracle`. Commit-gate
    checks also passed: `mdbook build docs/linkedspec-book`,
    `knowledge-map/scripts/check_knowledge_map.sh`,
    `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`,
    `git diff --check`, and `bash tools/run_ci_local.sh` (phase0 1016 green).
  Commit: `STAGED-LINKED-PARSING.5.3.2 - retire Rust raw function parser`

- ID: `STAGED-LINKED-PARSING.5.4`
  Status: `done`
  Goal: Add the minimal neutral parse-job marker/sidecar prototype.
  Acceptance: Function-body payloads can be represented as staged parse jobs
    with deterministic job id, parser spec identity, top rule, result policy,
    failure policy, and source-aware diagnostics; the observable shape remains
    implementation-language neutral.
  Verification: **DONE 2026-07-03.** `specs/user_function_definition.spec`
    now returns `body_parse_job` beside `body_payload` for each
    `function_definition` AST node. The sidecar is neutral metadata only: it
    carries `kind = parse_job`, a deterministic job id, parent AST path,
    `parser_spec_id = actionir-body.spec`, `top_rule = action_block`,
    `result_policy = replace_field`, `result_field = body_ast`,
    `failure_policy = fail`, exact body text, source span, and diagnostic
    owner. The Perl registry and Rust runtime adapter validate the returned
    sidecar, normalize source-order parent paths and job ids once the function
    ordinal is known, preserve the sidecar through descriptor / parsed /
    compiled function state, and continue using the existing ActionIR body AST
    bridge for execution. No staged parser registry or dispatch queue was
    implemented in this leaf. Checks passed: `perl -c perl/LinkedSpec.pm`,
    `perl -c -Iperl t/phase0_regression.t`, direct
    `specs/user_function_definition.spec` AST probe, Perl descriptor
    `body_parse_job` probe, `cargo fmt --manifest-path
    rust/linkedspec-core/Cargo.toml`, `cargo fmt --manifest-path
    rust/linkedspec-runtime/Cargo.toml`, `RUSTFLAGS=-Awarnings cargo test
    --manifest-path rust/linkedspec-runtime/Cargo.toml
    spec_defined_user_function_parser -- --nocapture`,
    `RUSTFLAGS=-Awarnings cargo test --manifest-path
    rust/linkedspec-core/Cargo.toml user_function -- --nocapture`, and
    `prove -v -Iperl t/phase0_regression.t` (phase0 1016 green).
  Commit: `STAGED-LINKED-PARSING.5.4 - add function-body parse-job sidecar`

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
| 1 | `STAGED-LINKED-PARSING.5.5` | `pending` | Add the minimal registry/dispatch path for one next-stage spec now that function-body payloads carry neutral parse-job metadata. |

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
- `2026-07-02`: `specs/user_function_definition.spec` is the focused executable
  grammar owner for top-level user-function definition shells. It returns
  source-ordered `function_definition` AST nodes with exact source/body text,
  parsed params, arity, source/body spans, source-slice provenance, and a
  neutral `body_payload`. New parser specs must use the modern direct-shape /
  receiver surface where implemented, not legacy typed-wrapper ceremony.
- `2026-07-02`: Consuming the spec-defined AST in one backend is not enough to
  close the language-neutral contract. Remaining host-language user-function
  definition parser bridges, starting with Rust's pre-existing bridge, are
  explicit debt under `.5.3.2`.
- `2026-07-02`: Complex regexes are allowed when they are the cleanest local
  extractor, but the first monolithic-body `function_definition` matcher was
  hard to read and triggered a focused variation-test hang. The `.5.3.1`
  implementation therefore uses LinkedSpec's opener/closer plus linked
  body-island rules for the function body, while keeping small regex rules for
  local lexical tokens.
- `2026-07-03`: Function-definition AST nodes now carry both `body_payload`
  and `body_parse_job`. `body_payload` remains the exact neutral text island;
  `body_parse_job` is the neutral parse-intent sidecar naming
  `actionir-body.spec`, top rule `action_block`, result field `body_ast`,
  failure policy `fail`, source span, and deterministic job id. The sidecar is
  preserved in Perl descriptors and Rust parsed/compiled function state, but
  it is not dispatched yet.

## Open Questions

- `.5.5` owns the first registry/dispatch path that will execute the
  function-body parse job. `.5.4` only records and preserves neutral metadata.

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
| `2026-07-02` | `STAGED-LINKED-PARSING.5.3.1` | `perl -Iperl -c perl/LinkedSpec/UserFunctionRegistry.pm`; `perl -Iperl -c t/phase0_regression.t`; direct `specs/user_function_definition.spec` AST probes; generated-handler debug dump; focused descriptor payload probe; `perl -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — `specs/user_function_definition.spec` returns the predicted function-definition AST shape with linked body-island rules; `body_brace` does not consume the outer close edge; malformed/unbalanced definitions return diagnostic AST nodes; Perl registry consumes the spec-returned AST; legacy Perl scanner helpers removed; remaining Rust bridge retirement is split to `.5.3.2`. |
| `2026-07-02` | `STAGED-LINKED-PARSING.5.3.2` | `cargo fmt`; focused Rust `spec_defined_user_function_parser_*`; helper/runtime parity checks; Rust corpus oracle; `mdbook build docs/linkedspec-book`; `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — Rust consumes `specs/user_function_definition.spec` AST output and no longer owns a raw `fn` definition parser bridge; active Perl/Rust backends share the neutral definition-shell AST contract. |
| `2026-07-03` | `STAGED-LINKED-PARSING.5.4` | `perl -c perl/LinkedSpec.pm`; `perl -c -Iperl t/phase0_regression.t`; direct spec AST probe; descriptor `body_parse_job` probe; `cargo fmt --manifest-path rust/linkedspec-core/Cargo.toml`; `cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml`; `RUSTFLAGS=-Awarnings cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml spec_defined_user_function_parser -- --nocapture`; `RUSTFLAGS=-Awarnings cargo test --manifest-path rust/linkedspec-core/Cargo.toml user_function -- --nocapture`; `prove -v -Iperl t/phase0_regression.t` | PASS — function-definition ASTs now carry neutral `body_parse_job` sidecars; Perl and Rust validate, normalize, and preserve them without implementing dispatch; phase0 passes with 1016 top-level tests. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `STAGED-LINKED-PARSING.1` | `STAGED-LINKED-PARSING.1 - adopt staged linked parsing doctrine` | ADR/book/KM/live-doc architecture adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.2` | `STAGED-LINKED-PARSING.2 - specify spec import composition contract` | ADR/book/KM/live-doc design adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.3` | `STAGED-LINKED-PARSING.3 - specify staged parse-job annotations` | ADR/book/KM/live-doc design adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.4` | `STAGED-LINKED-PARSING.4 - specify staged parser registry dispatch` | ADR/book/KM/live-doc design adoption; no runtime code change. |
| `STAGED-LINKED-PARSING.5.1` | `STAGED-LINKED-PARSING.5.1 - select staged prototype payload family` | Payload-family selection and prototype split; no runtime code change. |
| `STAGED-LINKED-PARSING.5.2` | `STAGED-LINKED-PARSING.5.2 - audit function definition AST shape` | Function-definition AST-shape audit and neutral target contract; no runtime code change. |
| `STAGED-LINKED-PARSING.5.3.1` | `STAGED-LINKED-PARSING.5.3.1 - consume spec-defined function AST in Perl` | `specs/user_function_definition.spec` returns the definition AST; Perl registry consumes it and no longer raw-scans function definition syntax. |
| `STAGED-LINKED-PARSING.5.3.2` | `STAGED-LINKED-PARSING.5.3.2 - retire Rust raw function parser` | Rust consumes the spec-defined definition AST and no longer owns a competing raw `fn` definition parser. |
| `STAGED-LINKED-PARSING.5.4` | `STAGED-LINKED-PARSING.5.4 - add function-body parse-job sidecar` | Function-body payloads now carry neutral `body_parse_job` metadata in Perl descriptors and Rust parsed/compiled function state; dispatch remains pending. |

## Changelog

- `2026-07-02`: `.1` done — staged linked parsing adopted as language-neutral doctrine; frontier moves to `.2`.
- `2026-07-02`: `.2` done — spec import/composition contract specified before implementation; frontier moves to `.3`.
- `2026-07-02`: `.3` done — staged parse-job annotation and metadata contract specified before implementation; frontier moves to `.4`.
- `2026-07-02`: `.4` done — staged parser registry/dispatch contract specified before implementation; frontier moves to `.5`.
- `2026-07-02`: `.5.1` done — broad prototype split; function-body payload selected as first staged prototype target; all follow-up leaves must stay implementation-language neutral; frontier moves to `.5.2`.
- `2026-07-02`: `.5.2` done — function-definition AST-shape audit captured wrapper-top harness, named-capture requirement, current zero-arg/regex-brace gaps, neutral target AST/provenance shape, and variation matrix; frontier moves to `.5.3`.
- `2026-07-02`: `.5.3.1` done — `specs/user_function_definition.spec` returns the predicted user-function definition AST shape and the Perl registry consumes that spec-returned AST instead of raw-scanning function definition syntax; frontier moves to `.5.3.2`.
- `2026-07-02`: `.5.3.2` done — Rust consumes the same spec-returned user-function definition AST contract and no longer owns a raw definition parser bridge; frontier moves to `.5.4`.
- `2026-07-03`: `.5.4` done — function-body payloads now carry neutral `body_parse_job` sidecars with deterministic ids, parser identity, top rule, result/failure policies, exact text, and source spans; frontier moves to `.5.5`.
