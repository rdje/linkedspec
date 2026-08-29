- ID: `FUTURE-PARITY-BACKLOG.11`
  Status: `done`
  Goal: Make codeblock a first-class callable value and correct trailing blocks to the generic final-codeblock model.
  Children: `.11.0`, `.11.1`, `.11.2`, `.11.3`, `.11.4`, `.11.5`, `.11.6`, `.11.7`, `.11.8`
  Acceptance: The director's four-kind model—scalar, array, harray, and codeblock—is durable; a callable signature,
    not a parser hard-code for a particular helper name, decides whether its final argument may be a codeblock;
    `call(args) { block }` is semantically equivalent to `call(args, { block })`, including receiver methods and
    user/helper functions; every implemented and future variant exposes identical parsing, validation, evaluation,
    diagnostics, and API behavior.

- ID: `FUTURE-PARITY-BACKLOG.11.0`
  Status: `done`
  Goal: Audit and capture the director's generic final-codeblock argument correction without changing behavior or
    pivoting from `.1.5.1.6.2`.
  Acceptance: Record current Perl/Rust/Dart/Julia behavior, the absent Lua implementation, the contradiction in
    closed `SPEC-FORMAT-TERSE.14`, the required syntax equivalence, and the explicit design question of retaining
    `with` as an ordinary block-taking helper versus removing it. Update roadmap/live docs, mdBook, resume pointer,
    and Knowledge Map; make no parser/runtime code change; keep `.1.5.1.6.2` active.
  Verification: **PASS 2026-07-10.** Knowledge Map generation/check, memory architecture, task-tree metadata,
    doctrine, whitespace, mdBook build, and generated-book cleanup pass. LinkedSpec lowering probes plus current
    task/source/test facts establish the narrow existing surface and parenthesized-form rejection. No parser,
    compiler, runtime, fixture, or backend behavior changed; `.1.5.1.6.2` remains active.
  Commit: `FUTURE-PARITY-BACKLOG.11.0 - capture generic trailing codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.1`
  Status: `done`
  Goal: Design and split generic final-codeblock argument parity before implementation.
  Acceptance: Define the four value kinds precisely, including whether public terminology is `harray` or the
    current `hash`; define the callable-signature declaration for final `codeblock`; make attached and
    parenthesized forms one canonical AST/IR shape; specify evaluation timing, block-local return, lexical/runtime
    context, receiver behavior, arity and non-final diagnostics, and hash-literal disambiguation; decide whether
    `with` remains as an ordinary helper, is migrated, or is removed; inventory every existing block-taking helper
    and method; split reference plus Rust/Dart/Julia/Lua parity and neutral conformance fixtures before code.
  Verification: **PASS 2026-07-12.** The director selected `{|args| ...}` over constructor/arrow/fn alternatives
    and selected dynamic caller context without lexical capture for the initial contract. ADR 0031 fixes exact
    `{|` prefix disambiguation from `{}`/`{ key : value }` harrays and `{ statements }` immediate blocks; `{|| ...}`
    is the zero-parameter literal and final `...rest` reuses ADR 0030. Codeblock construction stores typed
    signature/body/source only and executes nothing. `cb(args)` evaluates positional arguments once left-to-right,
    installs copied parameter/rest values as temporary bindings, executes against the caller's current nonparameter
    stores, restores parameter names, returns the block-local result, and rejects keyword calls, non-codeblock
    values, and recursion. Static helpers/controls/user functions retain resolution precedence over variable calls.
    `with` remains an ordinary block-taking helper. Neutral contract, Perl, Rust, Dart, Julia, and Lua-routing/
    closeout leaves are split before behavior code; callable checker, governance checks, and mdBook build pass.
  Later correction 2026-07-12 (`.11.3.3.0`/`.1`): this design fixed the semantic requirement but did not define
    the source/schema declaration for a final contextual codeblock parameter. ADR 0032 now selects final-only
    `name: codeblock`; it deliberately does not duplicate the supplied value's own signature.
  Commit: `FUTURE-PARITY-BACKLOG.11.1 - design callable codeblock literals`

- ID: `FUTURE-PARITY-BACKLOG.11.2`
  Status: `done`
  Goal: Adopt a backend-neutral callable-codeblock syntax, AST/signature schema, and executable fixture.
  Dependencies: `.11.1`
  Acceptance: ADR 0031's `{|params| body }` / `{|| body }` syntax, final `...rest`, exact prefix disambiguation,
    deferred construction, dynamic caller context, temporary copied params, ordered positional calls, block-local
    return, result chaining/discard, recursion/non-callable/keyword diagnostics, static-name precedence, contextual
    final-block sugar, and retained `with` behavior are machine-readable and independently checked before runtime
    changes. The contract distinguishes explicit callable literals from harrays and immediate block expressions and
    defines canonical AST/descriptor/generated-state fields without host closure/function objects.
  Verification: **PASS 2026-07-12.** `linkedspec-callable-codeblock-v1` contains seven canonical literals, eleven
    call cases, nine invalid literals, seven invalid calls, four contextual final-block cases, exact brace
    classification, typed AST fields, and one deterministic future `.spec`/result fixture. Its independent checker
    reuses the adopted signature parser, models dynamic stores/temporary restoration without a host closure,
    reproduces fixture source/results, and is wired into canonical local CI. The complete gate passes both 61-case
    CLI environments and Phase 0 `1..1030` in 716 seconds. Capability remains future-owned.
  Commit: `FUTURE-PARITY-BACKLOG.11.2 - adopt callable codeblock contract`

- ID: `FUTURE-PARITY-BACKLOG.11.3`
  Status: `done`
  Goal: Implement callable codeblock literals and generic final-codeblock calls on the Perl reference.
  Children: `.11.3.1`, `.11.3.2`, `.11.3.3`, `.11.3.4`
  Dependencies: `.11.2`
  Acceptance: Perl consumes the unchanged neutral contract without broad host coderef fallback or lexical capture;
    current hash/immediate-block semantics, user functions, helpers, receiver calls, and generated-source behavior
    remain stable.
  Verification: **PASS 2026-07-12.** Leaves `.11.3.1` through `.11.3.4` parse, preserve, invoke, normalize, and
    close callable codeblocks on the Perl reference without raw-host fallback, unresolved helpers, stored coderefs,
    lexical capture, parser method allowlists, or brace-classification drift. The final canonical proof passes the
    60/0/0 capability census, both 61-case CLI environments, and Phase 0 `1..1030`.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.1`
  Status: `done`
  Goal: Parse and lower typed callable-codeblock literal/signature values on Perl.
  Acceptance: `{|...|...}` is a dedicated typed AST value with exact spans/body/signature; assignment, copying,
    function arguments/results, and generated state preserve it without executing its body or confusing brace forms.
  Verification: **PASS 2026-07-12.** Exact `{|` recognition precedes current harray/eager-block classification.
    Valid literals expose only the neutral eight fields with typed body/signature and containing-expression spans;
    all nine malformed contract forms retain their exact codes. Canonical UTF-8 JSON serialized as ASCII hex
    reconstructs inert plain data in generated Perl, avoiding host closures, interpolation, and later rewrite
    mutation. Assignment/copy and user-function argument/result round trips pass 126 focused assertions; existing
    ActionIR parser tests remain green. Canonical CI passes 61x2 CLI and Phase 0 `1..1030`/575s. `cb(args)` remains
    intentionally owned by `.11.3.2`.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.1 - parse Perl callable codeblock literals`

- ID: `FUTURE-PARITY-BACKLOG.11.3.2`
  Status: `done`
  Goal: Execute Perl codeblock-variable calls with dynamic caller context.
  Acceptance: `cb(args)` resolution, ordered evaluation, copied temporary params/rest, restoration, caller-visible
    nonparameter mutation, block-local return, chain/discard, recursion and typed failures match the neutral fixture.
  Verification: **PASS 2026-07-12.** The unchanged neutral fixture passes in live and independently loaded
    generated execution. Static helper/user-function precedence, canonical value-drop classification, receiver
    continuation, copied fixed/rest arguments, restoration on success/failure, caller-visible mutation, local
    return, and typed arity/keyword/not-callable/recursion/body-call errors are locked. Focused callable/ActionIR/
    variadic/generated-source proof passes 97 top-level tests; canonical CI passes the 60/0/0 capability census,
    both 61-case CLI environments, and Phase 0 `1..1030` in 815 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.2 - execute Perl callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3`
  Status: `done`
  Goal: Generalize Perl final-codeblock call syntax through callable signatures.
  Children: `.11.3.3.0`, `.11.3.3.1`, `.11.3.3.2`
  Acceptance: Attached and parenthesized contextual final blocks normalize to the same callable-codeblock AST;
    helper/user-function/receiver signatures—not `with` name checks—govern acceptance, while `with` remains ordinary.
  Verification: **PASS 2026-07-12.** ADR 0032's final-only `name: codeblock` declaration is preserved through
    grammar, registry, descriptors, ActionIR normalization, runtime execution, and independently loaded generated
    source. Attached and parenthesized helper/user-function/receiver forms share one canonical argument shape.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3.0`
  Status: `done`
  Goal: Audit and split the missing final-codeblock signature-declaration contract before behavior code.
  Acceptance: LinkedSpec probes establish whether helpers, user functions, and receiver methods expose a typed
    final-codeblock declaration; any missing design choice is durably isolated before parser/lowering changes.
  Verification: **PASS 2026-07-12.** Attached and parenthesized `with` already parse to the same final `block_value`
    payload, but only the attached form is flagged. Fixed user-function records expose names/arity only, helper
    arities live in lowering tables, and receiver parsing is explicitly name-gated. No schema declares that a final
    parameter accepts contextual codeblock sugar. The audit initially overreached by also requesting a nested
    callback signature; director clarification in `.1` correctly leaves that signature on the value. Design leaf `.1`
    and implementation leaf `.2` are split; no behavior code changed.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.0 - split final codeblock signature declaration`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3.1`
  Status: `done`
  Goal: Define the callable declaration for a final contextual codeblock parameter.
  Acceptance: One backend-neutral declaration/schema covers helpers, user functions, and receiver methods; it
    leaves the callback's own parameter signature on the supplied codeblock value, remains compatible with
    duck-typed runtime values, rejects non-final declarations, and updates ADR/neutral contract before behavior.
  Verification: **PASS 2026-07-12.** Director clarification selects exact `callback: codeblock` with no nested
    argument list. ADR 0032 makes it final-only, keeps ordinary parameters duck-typed, leaves `{|params| ...}` as
    the sole owner of an explicit value's invocation signature, and defines contextual blocks as zero-positional
    dynamic-context values. The strict neutral checker passes 7 literals, 11 calls, 9 malformed literals, 7 invalid
    calls, 4 invalid declarations, and 8 helper/user-function/receiver contextual forms.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.1 - declare final codeblock parameters`

- ID: `FUTURE-PARITY-BACKLOG.11.3.3.2`
  Status: `done`
  Goal: Implement signature-governed attached/parenthesized final-codeblock normalization on Perl.
  Acceptance: Perl consumes `.1` without name-gated parser exceptions; equivalent helper/user-function/receiver
    spellings share canonical AST/IR, preserve harray/immediate blocks, execute through generated source, and
    produce typed declaration/arity/final-argument diagnostics.
  Verification: **PASS 2026-07-12.** The wrapper-free grammar emits fixed parameters plus the final codeblock name;
    registry validation projects exact ordered `params`/`arity`, and typed definitions plus both staged records
    preserve final `parameter_kinds`. `LinkedSpec::CallableContract` declares helper/receiver/user-function acceptance, generic
    receiver parsing no longer grants semantics by method name, and lowering gives attached/parenthesized
    contextual blocks one zero-positional `codeblock_argument`. Helper, typed user-function, receiver `with`, tree
    traversal, explicit literals, harray rejection, four declaration failures, and standalone generated execution
    pass focused proof; adjacent ActionIR/variadic/generated-source tests remain green.
    During implementation, director clarification reaffirmed that `set(target, value)` must evaluate to the
    target's post-assignment typed value for method chaining. Existing assignment-value probes agree, while the
    remaining `.spec`-facing `array(name)` / `hash(name)` namespace and mutation forms are scheduled for removal
    under `.12.1`; this leaf does not broaden into that public-surface migration.
    Direct Phase 0 passes all `1..1030` in 966 seconds after the wrapper-free grammar and immediate-`with`
    full-breadth preservation repairs. Canonical CI passes capability 60/0/0, CLI 61x2, and Phase 0 `1..1030` in
    916 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.3.2 - normalize Perl final codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.3.4`
  Status: `done`
  Goal: Close Perl callable-codeblock diagnostics, docs, and full-gate no-drift.
  Acceptance: Neutral/focused/Phase-0/CLI gates pass; no raw Perl, coderef leakage, harray drift, or undocumented
    compatibility remains before Rust parity.
  Verification: **PASS 2026-07-12.** Toolbox probes produce byte-equivalent lowering for attached and
    parenthesized helper/receiver forms, reject unknown receiver semantics after generic structural parsing, and
    expose the typed final parameter in user-function descriptors. Descriptor telemetry reports zero raw-host
    dependencies, fallbacks, compatibility rewrites, and unresolved helpers. Source scans find no parser method
    allowlist, captured environment, or stored coderef field. The four focused suites pass 100 tests; the neutral
    checker, 60/0/0 capability census, both 61-case CLI environments, Phase 0 `1..1030` in 916 seconds, doctrines,
    Knowledge Map, whitespace, and mdBook all pass on the committed Perl behavior.
  Commit: `FUTURE-PARITY-BACKLOG.11.3.4 - close Perl callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.4`
  Status: `done`
  Goal: Implement the unchanged callable-codeblock contract on Rust native and generated execution.
  Children: `.11.4.1`, `.11.4.2`, `.11.4.3`
  Dependencies: `.11.3`

- ID: `FUTURE-PARITY-BACKLOG.11.4.1`
  Status: `done`
  Goal: Add typed Rust callable-codeblock AST/signature/compiled/serialized state.
  Acceptance: Exact brace disambiguation, spans, signature/body data, validation, descriptors, and source emission
    round-trip without evaluating or encoding a Rust closure.
  Verification: **PASS 2026-07-30.** Exact neutral construction, Unicode/nested spans, diagnostics, inert runtime
    transport, compiled/generated/emitted state, semantic signature descriptors, and eager-dependency isolation
    pass the seven-test Rust contract; variadic 7/7, semantic query 5/5, complete core, and full Rust operational
    gates pass. Knowledge Map 759/6,156, mdBook, seven doctrines, and canonical CI through CLI 66x2, RAM 55%, and
    Phase 0 1,031/1,031 in 641 seconds pass. No dynamic invocation, generic final-block, MCP, or capability scope
    moves.
  Commit: `FUTURE-PARITY-BACKLOG.11.4.1 - construct Rust callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.4.2`
  Status: `done`
  Goal: Execute Rust codeblock-variable calls with neutral dynamic context and diagnostics.
  Acceptance: Ordered values, temporary copied bindings/rest, caller nonparameter stores, results, recursion,
    static-name precedence, and failures match Perl and the neutral fixture.
  Verification: **PASS 2026-07-30.** The neutral checker and Rust 13/13 contract cover all eleven valid calls,
    seven invalid calls, static precedence, copied/restored fixed/rest state, caller mutations, local results,
    recursion, and native/compiled/generated/emitted identity; variadic 7/7, semantic 5/5, and unknown-helper
    preservation pass. The complete Rust operational gate passes all packages, long classifiers, 197 integration
    cases, build, storage, and CLI 66x2. Knowledge Map 760/6,165, mdBook 79 files / 13,864 KiB, seven doctrines,
    and canonical CI through CLI 66x2, RAM 44%, and Phase 0 1,031/1,031 in 763 seconds pass with exact cleanup.
  Commit: `FUTURE-PARITY-BACKLOG.11.4.2 - execute Rust callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.4.3`
  Status: `done`
  Goal: Close Rust generic final-block equivalence, generated execution, oracle, docs, and full gates.
  Acceptance: Signature-governed attached/contextual forms and retained `with` pass native/generated/oracle paths.

- ID: `FUTURE-PARITY-BACKLOG.11.5`
  Status: `done`
  Goal: Implement the unchanged callable-codeblock contract on Dart native and generated execution.
  Children: `.11.5.1`, `.11.5.2`, `.11.5.3`
  Dependencies: `.11.4`

- ID: `FUTURE-PARITY-BACKLOG.11.5.1`
  Status: `done`
  Goal: Add typed Dart callable-codeblock AST/signature/serialized state and brace disambiguation.
  Verification: **PASS 2026-07-30.** Neutral 7/11/9/7/4/8 checker, focused Dart 8/8 plus 13 parser/
    variadic regressions, strict analysis, and complete Dart format/analyzer/362 tests/18-owner+47-package storage/
    CLI 66x2/corpus 105/105 pass. Knowledge Map 764/6,204, mdBook 79 files / 13,908 KiB, all seven doctrines,
    repository containment/moved-root, canonical CLI 66x2, RAM 56%, and Phase 0 1,031/1,031 in 645 seconds pass;
    exact rendered-output/empty-run cleanup passes.
  Commit: `FUTURE-PARITY-BACKLOG.11.5.1 - construct Dart callable codeblocks`

- ID: `FUTURE-PARITY-BACKLOG.11.5.2`
  Status: `done`
  Goal: Execute Dart codeblock-variable calls with neutral dynamic context and diagnostics.

- ID: `FUTURE-PARITY-BACKLOG.11.5.3`
  Status: `done`
  Goal: Close Dart generic final-block equivalence, generated execution, docs, and full gates.
  Verification: **PASS 2026-07-30.** Neutral 7/11/9/7/4/8 checker, focused callable 21/21, strict analysis,
    complete Dart format 95/0 + 375 tests + 19-owner/47-package storage + CLI 66x2 + corpus 105/105, Knowledge
    Map 766/6,218, mdBook 79 files / 13,944 KiB, all seven doctrines, canonical semantic/MCP admissions,
    containment/moved-root proof, CLI 66x2, RAM 58%, and Phase 0 1,031/1,031 in 646 seconds pass.
  Commit: `FUTURE-PARITY-BACKLOG.11.5.3 - close Dart final codeblocks`

### `FUTURE-PARITY-BACKLOG.11.5.3` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate only from clean `.11.5.2` commit `74725ff0` after its
  post-commit pointer proof, zero-byte brief, empty status, absent generated book/cache, and zero managed-run
  residue. Record `.11.5.3` before any roadmap correction or behavior edit; do not push before cadence 300.
- [x] **KNOWLEDGE / TOOL-LED BASELINE / DRIFT MAP** — Retrieve ADRs `0031`/`0032`, the neutral contextual cases,
  Rust metadata-owned normalization, Dart trailing-block/parser/function-registry/runtime/generated facts, and
  Toolbox probes. Freeze exact attached/parenthesized helper, typed-user-function, receiver, explicit-literal,
  harray-rejection, eager/control, descriptor, and emission behavior before implementation. Correct the measured
  stale `ROADMAP_V2.md` `.11.5.2` status under this no-drift/parent-closeout owner.
- [x] **ONE SIGNATURE-GOVERNED NORMALIZATION** — Admit only a final `name: codeblock` parameter and normalize
  equivalent attached plus parenthesized contextual blocks to one typed `codeblock_argument`; preserve the
  codeblock value's own signature, dynamic caller context, and the existing runtime executor. Do not invent a
  closure, callback runtime, syntax-specific executor, implicit positional parameter, or backend dialect.
- [x] **PRESERVE DISTINCT SURFACES / PORTABLE FAILURES** — Keep eager block expressions, harrays, attached
  controls, explicit `{|params| ...}` values, ordinary `with`, static callable precedence, and non-codeblock/
  unknown/malformed diagnostics exact. Unknown attached callees and non-final/typed-invalid declarations must not
  gain contextual semantics.
- [x] **NATIVE / SERIALIZED / GENERATED / EMITTED PROOF** — Consume all eight neutral contextual cases and exact
  mutation-sensitive Dart positives/negatives across parsed/compiled descriptors, normalized reconstruction,
  generated plans, independently compiled emitted Dart, user functions, helpers, receivers, and tree callbacks.
- [x] **SIGNOFF / DOCS / PARENT CLOSE / CLEAN HANDOFF** — Pass focused and complete Dart gates plus neutral,
  Knowledge Map, mdBook, all doctrines, and warranted canonical proof; synchronize both roadmaps, task/live docs,
  Dart docs, and public book; close parent `.11.5`; commit `.11.5.3`, clear the brief, prove clean, and only then
  activate Julia `.11.6.1`; capability/MCP promotion and push remain excluded.

Activation evidence 2026-07-30: `.11.5.2` lands at `74725ff0` as commit 113/300 from activation boundary
`5e80be32`. The hook proves committed `activation_commit == HEAD^1`; the brief is zero bytes, Git status is empty,
the rendered book and generated Python cache are absent, and the managed-run census is zero. Retrieval immediately
finds one bounded public-status drift: `ROADMAP_V2.md` still calls Dart dynamic invocation future while the primary
roadmap, task tree, live docs, mdBook, and committed implementation say it is complete. `.11.5.3` owns that
correction as part of its no-drift and Dart-parent closeout obligations; no behavior changes at activation.

Baseline/root-cause evidence 2026-07-30: the neutral checker passes at 7 literals / 11 calls / 9 invalid literals /
7 invalid calls / 4 invalid declarations / 8 contextual forms, and the existing Dart parser/function-registry/
staged/runtime/callable selection passes 89 tests. The shared `user_function_definition.spec` already emits exact
`fixed_params`, `codeblock_param`, and sole-entry `parameter_kinds` in a typed definition and both staged sidecars.
Dart's projection accepts only fixed-v1 `params`/`arity` or variadic-v2 `signature`; its AST/job/registry/descriptor
records therefore cannot retain descriptor-v3 intent. Action parsing immediately turns all attached function-form
blocks into trailing eager `block_value`, hard-codes receiver attachment to `with` plus three traversal names, and
leaves parenthesized blocks as ordinary eager values because the complete callable registry does not exist yet.
There is no post-registry normalization owner. The bounded repair is one metadata registry/pass that preserves
provenance, admits only an exact final `codeblock` slot, emits one zero-positional `codeblock_argument`, restores
ordinary eager blocks, rejects unknown attached callees, and reuses the `.11.5.2` dynamic executor. The durable
fact is `docs/knowledge/dart-generic-final-codeblock-gap.md`; no behavior changed during this measurement.

Mutation-sensitive RED evidence 2026-07-30: the focused Dart parser/callable selection retains 21 existing passes
and fails exactly five new obligations. Attached helper/receiver blocks remain `block_value` instead of a preserved
`contextual_codeblock_candidate`; the shared typed definition fails projection at missing legacy `params`; unknown
attached `custom` compiles instead of reporting `callable_contract_rejected`; contextual execution cannot construct;
and malformed typed declarations collapse to generic `invalid user function definition` instead of the four neutral
codes. The red suite also fixes the exact descriptor-v3 fields, all eight neutral contextual rows, canonical attached/
parenthesized AST pairs, native/reconstructed/generated results, eager/control preservation, and harray boundary
diagnostics before production changes.

Implementation/focused evidence 2026-07-30: Dart now projects the shared typed shell's exact fixed/final metadata
through immutable definition/job/registry state, both staged sidecars, semantic signatures, and the exact outward
descriptor-v3 field order. Action parsing records attached/parenthesized provenance without semantic authority;
one post-registry `callable_contract.dart` owner combines builtin helper/receiver contracts with typed user
functions, validates pre-codeblock arity, restores noncontract parenthesized blocks to eager values, rejects
unknown attached callees, and emits one zero-positional `codeblock_argument`. Helper/receiver `with`, hash/array
tree traversal, and typed user functions decode that value through the existing `.11.5.2` evaluator. Explicit
literal signatures, harrays, controls, eager blocks, static precedence, and portable failures remain distinct.
The implementation audit additionally catches and repairs callback lookup ordering when the callback variable is
itself named `value`, and keeps provisional registry construction out of the public trace.

Neutral proof remains 7 literals / 11 calls / 9 invalid literals / 7 invalid calls / 4 invalid declarations / 8
contextual forms. Focused parser/registry/runtime/callable proof passes 100 before final mutations; the dedicated
callable suite then passes 21 including descriptor-field, sidecar-drift, all-three-surface contextual-arity, and
callback-shadowing mutations. Strict analysis is clean. Complete package proof passes 375 tests after its first
run exposed and the focused trace regression test locked the duplicate-provisional-registry event repair. Native,
normalized reconstruction, generated-plan execution, and a fresh independently compiled emitted-Dart package all
produce the exact contextual fixture and invalid-call outcomes. Operational signoff passes formatting over 95
files with zero changes, strict analysis, 375 package tests, 19 repository-storage owners / 47 locked packages,
primary CLI 66x2, and corpus 105/105. Knowledge Map generation and checking pass at 766 facts / 6,218 question
keys; the mdBook renders 79 files / 13,944 KiB; memory, task metadata, all seven doctrines, and diff checks pass.
Canonical CI passes exact five-implementation/six-runtime MCP admission, semantic admission, repository
containment and moved-root execution, primary CLI 66x2, RAM 58%, and Phase 0 1,031/1,031 in 646 seconds before
reporting `local CI gate passed`. Exact generated-output and managed-run cleanup are the final pre-commit checks.
This closes `.11.5.3` and Dart parent `.11.5`; Julia `.11.6.1` may activate only after the workflow commit,
zero-byte brief, and clean-boundary proof.

### `FUTURE-PARITY-BACKLOG.11.5.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Run the neutral callable-codeblock checker and exact Dart probes to freeze the
  construction gap across parsed ActionIR, staged/compiled state, generated plans/source, and contextual brace
  recognition before implementation.
- [x] **ROOT CAUSE (WHY + WHERE)** — Use LinkedSpec/Dart structural tools and source inspection to identify the
  smallest missing typed value/parser/serialization owners; record the durable causal seam in the Knowledge Map.
- [x] **FIX** — Implement only inert `{|params| body }` / `{|| body }` construction, exact signature/source/span
  retention, serialized/generated preservation, and syntax disambiguation required for construction. Do not add
  dynamic variable invocation or generic contextual-final-block behavior owned by `.11.5.2-.3`.
- [x] **ADDRESSED (verified)** — Add mutation-sensitive Dart tests for valid/invalid literals, fixed/rest
  signatures, Unicode character-coordinate spans, nested braces/strings, eager-body isolation, and identity across
  every construction/serialization authority.
- [x] **NO REGRESSION** — Preserve ordinary eager blocks, harray literals, controls, helper/user-function calls,
  callable-signature v1/v2 behavior, public diagnostics, generated-source determinism, and non-Dart backends.
- [x] **LOCKSTEP / SIGNOFF / CLEAN HANDOFF** — Run focused Dart and neutral contracts, complete Dart operational
  proof, Knowledge Map, mdBook, all doctrines, and warranted canonical CI; update live docs; commit `.11.5.1`,
  clear the brief, prove clean, then activate `.11.5.2`. Do not push before cadence 300.

Activation 2026-07-30: clean correction closeout `0274d47f` closes
`MEMORY-COMMIT-POINTER-ENFORCEMENT.2` at 111/300 with an empty brief, zero retained managed runs, no mdBook output,
and exact post-commit `activation_commit == HEAD^1` proof. `.11.5.1` is the first Dart construction slice and owns
no runtime invocation, generic contextual-block closeout, capability promotion, other-backend change, or push.

Implementation evidence 2026-07-30: the pre-change Dart AST had only eager `ActionBlockValueExpr`,
`_parseBraceExpr` routed every non-harray brace there, and shared `CallableSignature.restParam` could not represent
fixed literal signatures. The repair adds exact `{|`-first typed literal/error nodes, nullable fixed/rest signature
state, containing-source propagation for Unicode-character literal/body spans, inert plain-map construction,
deferred-body contract/dependency treatment, public export, and semantic codeblock shapes. The ordinary compiled
ActionIR JSON and generated plan retain the record; emitted Dart reconstructs its normalized `SpecFile` and
re-enters the same parser/compiler/runtime. Eight contract-driven tests lock all brace classes/seven literals,
nine diagnostic codes, astral/nested spans, body non-execution, user-function transport, JSON/plan/emission
identity, eager-dependency isolation, semantic signature, the deliberate `.11.5.2` `cb()` exclusion, and the
non-null rest-name invariant for reconstructed variadic user functions despite the shared nullable signature type.

Signoff evidence 2026-07-30: complete Dart proof passes formatter (94 files / zero changes), strict analyzer,
362 tests, 18 storage owners / 47 locked packages, primary CLI 66x2, and corpus 105/105. Knowledge Map is
764 facts / 6,204 questions; mdBook is 79 files / 13,908 KiB; all seven doctrines pass. The canonical gate passes
the neutral callable-codeblock checker, semantic/MCP admissions, repository containment and moved-root anchors,
CLI 66x2, RAM 56%, and Phase 0 1,031/1,031 in 645 seconds. The rendered book is absent and its sole empty managed
run is removed exactly. No capability/MCP/other-backend status moved.

### `FUTURE-PARITY-BACKLOG.11.5.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / KNOWLEDGE FIRST** — Activate only from clean `.11.5.1` commit `5e80be32`, with the
  brief at zero bytes and generated residue absent; retrieve ADR `0031`, the neutral callable-codeblock contract,
  Perl/Rust dynamic-invocation facts, Dart inert-state and user-function/runtime facts, and Toolbox commands before
  any runtime edit.
- [x] **TOOL-LED DART BASELINE / GAP MAP** — Re-run the neutral checker and construction regression, then inspect
  exact call parsing, static resolution precedence, runtime stores/snapshots/return control, recursive copying,
  diagnostics, generated execution, and semantic projection. Record the smallest signoff-level implementation
  boundary before changing behavior.
- [x] **DYNAMIC INVOCATION / CALLER CONTEXT** — Resolve a governed bound codeblock only after controls, helpers,
  and registered user functions; evaluate positional arguments once left-to-right; recursively copy fixed/rest
  values into temporary bindings; restore same-name bindings on success/failure; expose other reads/mutations to
  caller stores; keep `return` invocation-local and allow ordinary result chaining/discard.
- [x] **PORTABLE FAILURES / RECURSION** — Preserve unknown-call behavior and emit exact typed arity, keyword,
  bound-non-codeblock, and direct/mutual active-recursion diagnostics with stable callable/cycle identity and no
  host fallback. Construction remains closure-free and inert.
- [x] **NATIVE / SERIALIZED / GENERATED PROOF** — Consume all eleven valid call cases, seven invalid call cases,
  and the exact neutral fixture through native, compiled-JSON reconstruction, generated-plan, and emitted-source
  authority without broadening generic contextual final blocks.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Pass focused and complete Dart gates plus warranted canonical
  proof; synchronize task/roadmap/live/Knowledge Map/mdBook/Dart docs; remove exact generated output; commit with
  `.11.5.2`, clear the brief, prove clean, and only then activate `.11.5.3`; do not push before cadence 300.

Activation 2026-07-30: clean construction commit `5e80be32` closes `.11.5.1` at 112/300 with an empty brief,
empty status, no rendered book, and zero retained managed runs. `.11.5.2` owns only explicit bound-variable call
execution, caller-context binding/result behavior, portable failures, and native/serialized/generated/emitted
proof. Generic contextual final blocks, capability/MCP promotion, other backends, root README, and push remain out
of scope.

Baseline evidence 2026-07-30: the neutral checker remains exact at 7 literals / 11 calls / 9 invalid literals /
7 invalid calls / 4 invalid declarations / 8 contextual forms, and the Dart construction regression remains 8/8.
Static controls, helpers, and registered user functions already precede the unsupported-call arm; user-function
arguments already evaluate once left-to-right; `_VariableSnapshot` plus scoped scalar entry/exit already provides
the required copied temporary fixed/rest bindings without the whole-store isolation used by user functions; and
`_executeValueBlockStatements` already supplies invocation-local return/final-expression results. The smallest
missing seam is therefore (1) a bound-name fallback after every static callable, (2) narrow colon-keyword parsing
for the governed rejection without reviving legacy assignment syntax, (3) one typed value-access expression so a
call result can feed existing key/index and fluent-chain machinery, and (4) callable-specific diagnostic fields
plus an ordered active-codeblock stack. Generated plans and emitted source already reconstruct and execute the
same compiled ActionIR, so they need proof rather than a separate runtime implementation.

Implementation evidence 2026-07-30: Dart now parses narrow `name: value` keyword arguments for governed
rejection and adds typed `value_access` for call-result key/index access before an ordinary receiver chain. The
runtime falls back to a bound name only after every existing static callable, validates the neutral plain-data
record, evaluates positional arguments once left-to-right, and uses the established scoped-variable snapshots in
reverse cleanup order for copied fixed/rest bindings. Retained typed body ActionIR is cached by exact literal
source; nonparameter stores remain live, results are copied before restoration, and an independent active-name
stack rejects direct/mutual recursion with ordered cycles. The public runtime diagnostic envelope now carries the
neutral callable/name/expected/got/value-kind/cycle fields. Fifteen contract-driven tests consume all eleven valid
and seven invalid call cases, the exact fixture, static precedence, once-only order, deep-copy isolation, native,
normalized reconstruction, generated-plan, and independently compiled emitted-Dart execution; the complete Dart
suite is green at 369 tests. The complete operational gate also passes format over 94 files with zero changes,
strict analysis, 19 storage owners / 47 locked packages, primary CLI 66x2, and corpus 105/105. Knowledge Map,
mdBook, doctrine, and canonical proof follow in the staged signoff checkpoints below.

Pre-canonical evidence 2026-07-30: Knowledge Map is synchronized at 765 facts / 6,213 question keys; the mdBook
renders 79 files / 13,920 KiB and is removed exactly afterward; all seven doctrines, memory architecture, task
metadata, neutral callable governance, and whitespace pass. Root `README.md` remains unchanged at 105 lines and
bounded `MEMORY.md` remains within its 60-line cap. This checkpoint preceded the canonical run recorded below.

Signoff evidence 2026-07-30: the canonical gate passes the generated MCP binding freshness checks, exact 5/5
implementation plus 6/6 runtime MCP admissions, semantic admissions, repository process containment, moved-root
anchors, primary CLI 66x2, RAM 56%, and Phase 0 1,031/1,031 in 650 seconds. All tests are successful, the local CI
gate reports PASS, the final mdBook renders 79 files / 13,924 KiB, and exact generated output/run cleanup leaves no
retained authority. Together with focused callable 15/15, parser/variadic 13/13, Dart 369/369, storage 19/47, and
corpus 105/105, `.11.5.2` is complete; only its workflow commit remains before `.11.5.3` may activate.

- ID: `FUTURE-PARITY-BACKLOG.11.6`
  Status: `done`
  Goal: Implement the unchanged callable-codeblock contract on Julia native and generated execution.
  Children: `.11.6.1`, `.11.6.2`, `.11.6.3`
  Dependencies: `.11.5`

- ID: `FUTURE-PARITY-BACKLOG.11.6.1`
  Status: `done`
  Goal: Add typed Julia callable-codeblock AST/signature/serialized state and brace disambiguation.

### `FUTURE-PARITY-BACKLOG.11.6.1` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate only from clean Dart closeout commit `bdae816a` after its
  post-commit activation-boundary proof, zero-byte brief, empty Git status, absent generated book/cache, and zero
  managed-run residue. Record this Julia leaf before any Julia behavior, test, roadmap, or documentation edit;
  do not push before cadence 300.
- [x] **KNOWLEDGE / TOOL-LED BASELINE** — Retrieve ADRs `0031`/`0032`, the neutral 7/11/9/7/4/8 contract, Julia's
  spec-driven function shell, typed v1/v2 definition/staged/registry state, ActionIR brace classifier, runtime value
  model, generated-v2 reconstruction, semantic projection, and Rust/Dart construction facts. Run the neutral
  checker and focused Julia parser/registry/generated probes before implementation.
- [x] **MUTATION-SENSITIVE RED / ROOT CAUSE** — Freeze exact valid/invalid literal, Unicode/nested span, harray/
  eager-block disambiguation, non-execution, user-function transport, serialization, generated/emitted, dependency,
  and semantic expectations. Use LinkedSpec/Julia structural tools to identify the smallest missing typed owners
  and write the durable causal fact before changing production behavior.
- [x] **INERT TYPED CONSTRUCTION** — Recognize exact `{|params| body }` / `{|| body }` before existing harray and
  eager-block brace routes. Preserve the neutral eight-field record, fixed/final-rest signature, typed ActionIR
  body, exact source, and containing-source half-open Unicode-character spans as plain serializable data. Do not
  execute the body, capture an environment, create a Julia closure, or add dynamic invocation.
- [x] **STATE / GENERATED / SEMANTIC IDENTITY** — Preserve the literal unchanged through assignment/copying,
  user-function arguments/results, compiled JSON reconstruction, generated plans, independently loaded emitted
  Julia, and semantic `codeblock` plus callable-signature projection. Treat retained bodies as deferred leaves for
  eager dependency and removed-surface scans.
- [x] **PRESERVE SURFACES / PORTABLE FAILURES** — Keep harrays, ordinary eager blocks, controls, static helpers/
  user functions, callable-signature v1/v2 behavior, and all nine neutral literal diagnostics exact. `cb(args)`
  remains exclusively `.11.6.2`; generic contextual final blocks remain `.11.6.3`; no capability/MCP movement.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Pass focused and complete Julia gates plus neutral, Knowledge
  Map, mdBook, all doctrines, and warranted canonical proof; synchronize task/roadmap/live docs, Julia docs, and
  public book; remove exact generated output; commit `.11.6.1`, clear the brief, prove clean, and only then activate
  `.11.6.2`. Root README and push remain unchanged.

Activation evidence 2026-07-30: Dart generic final-block closeout `.11.5.3` lands at `bdae816a` as commit 114/300
from clean activation boundary `74725ff0`. The hooks prove the pre-commit boundary and committed `HEAD^1`; the
brief is zero bytes, Git status is empty, the rendered book and Python cache are absent, and the managed-run census
is zero. `.11.6.1` owns Julia construction/state only; no Julia source, test, capability, MCP, root README, or push
changes occur at activation.

Baseline/root-cause evidence 2026-07-30: the neutral checker passes at 7 literals / 11 calls / 9 invalid literals /
7 invalid calls / 4 invalid declarations / 8 contextual forms. Existing focused Julia proof passes 55 variadic
user-function assertions, 13 generated accepted-subset assertions, 32 generated family plan/direct assertions,
and 20 generated-source scaffold assertions. The mutation-sensitive construction suite is RED: a compact probe
shows all 7/7 literals classified as `block_value` and all 9/9 required invalid-literal codes absent. The durable
fact `julia-callable-codeblock-construction-gap` records the exact parser, AST/signature, contract traversal,
runtime, semantic, and generated reconstruction owners before production behavior changes.

Implementation/Julia-gate evidence 2026-07-30: `CallableSignature` now admits null rest only as shared typed
state while user-function validation retains its non-null variadic invariant. Exact `{|` parsing produces the
neutral eight-field typed literal or one of all nine portable error nodes; ordinary harrays/eager blocks remain
unchanged. Contract and removed-selector scans treat valid bodies as deferred leaves, runtime construction returns
recursively copied serialized state without execution/capture, and static/call semantic projections expose the
exact codeblock signature. Generated plans, normalized reconstruction, and a freshly loaded emitted Julia module
reuse the same compiler/runtime path. The strengthened focused suite passes 239/239 across all seven literals,
nine invalid forms, nested/Unicode spans, user-function transport, nullable-signature isolation, eager-dependency
isolation, semantic binding, and native/reconstructed/generated/emitted identities. The complete package suite is
green. Its first operational run correctly found the new emitted-module test as an unregistered temporary owner;
the exact sorted storage manifest, Toolbox, Memory, and current storage facts now advance Julia 17 -> 18 and the
oracle passes. A subsequent uninterrupted `tools/run_julia_local.sh` passes the byte-fresh 120,030-byte MCP
binding, complete package suite, 18-owner/five-package storage proof, primary CLI conformance, and corpus 105/105.

Signoff evidence 2026-07-30: the corrected testset scoping retains the exact focused 239/239 result and the full
`Pkg.test()` suite exits 0. The neutral callable checker remains exact at 7 literals / 11 calls / 9 invalid
literals / 7 invalid calls / 4 invalid declarations / 8 contextual forms. Knowledge Map regeneration/check passes
at 768 facts / 6,235 question keys; the mdBook renders 79 files / 13,964 KiB; memory architecture, task metadata, whitespace,
and all seven doctrines pass. Canonical CI passes exact semantic and MCP admissions, repository process
containment and moved-root anchors, primary CLI 66x2, RAM 57%, and Phase 0 1,031/1,031 in 646 seconds before
reporting `local CI gate passed`. The workflow commit carries this completed state; `.11.6.2` may activate only
after the zero-byte brief, post-commit activation-boundary proof, clean Git status, and exact generated/run cleanup.

- ID: `FUTURE-PARITY-BACKLOG.11.6.2`
  Status: `done`
  Goal: Execute Julia codeblock-variable calls with neutral dynamic context and diagnostics.

### `FUTURE-PARITY-BACKLOG.11.6.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate only from clean construction commit `3a38338d`, after its
  post-commit activation-boundary proof, zero-byte brief, empty Git status, absent rendered book/cache, and zero
  retained managed runs. Record this leaf before any Julia behavior, test, roadmap, or public-doc edit; do not push
  before cadence 300.
- [x] **KNOWLEDGE / TOOL-LED BASELINE** — Retrieve ADR `0031`, the neutral callable-codeblock contract and
  fixture, Perl/Rust/Dart dynamic-invocation facts, Julia inert-state/function/runtime/generated/semantic facts,
  and the relevant Toolbox probes. Re-run neutral and construction checks, then use typed probes to map exact call
  parsing, static precedence, stores/scoped bindings, return control, recursive copy, diagnostics, result access,
  recursion, and generated execution before production edits.
- [x] **DYNAMIC INVOCATION / CALLER CONTEXT** — Resolve a governed bound codeblock only after controls, helpers,
  and registered user functions; evaluate positional arguments exactly once left-to-right; recursively copy
  fixed/rest values into temporary bindings; restore same-name scalar/array/harray state on success/failure; expose
  nonparameter reads/mutations to caller stores; keep `return` invocation-local and allow result access, chaining,
  and standalone discard.
- [x] **PORTABLE FAILURES / RECURSION** — Preserve unknown-call behavior and emit exact neutral arity, keyword,
  bound-non-codeblock, unknown-body-helper, and direct/mutual active-recursion diagnostics with stable callable/
  name/expected/got/value-kind/cycle fields and no host fallback. Construction remains closure-free and inert.
- [x] **NATIVE / SERIALIZED / GENERATED PROOF** — Consume all eleven valid call cases, seven invalid call cases,
  and the exact governed fixture through native, compiled-JSON reconstruction, generated-plan, and independently
  loaded emitted-source authority. Prove static precedence, once-only evaluation, recursive-copy isolation,
  cleanup after failure, caller mutation, parameter restoration, local results, and unchanged semantic state
  without broadening generic contextual final blocks.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Pass focused and complete Julia gates plus neutral, Knowledge
  Map, mdBook, all doctrines, and warranted canonical proof; synchronize task/roadmap/live docs, Julia docs, and
  public book; remove exact generated output; commit `.11.6.2`, clear the brief, prove clean, and only then activate
  `.11.6.3`. Root README, capability/MCP status, other backends, and push remain unchanged.

Activation evidence 2026-07-30: construction/state `.11.6.1` lands at `3a38338d` as commit 115/300 from clean
activation boundary `bdae816a`. The hook proves the staged pointer before commit and committed `HEAD^1` afterward;
the brief is zero bytes, Git status is empty, the rendered book and Python cache are absent, and the managed-run
census is zero. `.11.6.2` owns explicit bound-variable call execution and proof only; no Julia behavior, test,
capability, MCP, root README, or push change occurs at activation.

Baseline evidence 2026-07-30: the neutral checker remains exact at 7 literals / 11 calls / 9 invalid literals /
7 invalid calls / 4 invalid declarations / 8 contextual forms, Julia construction remains 239/239, and the
variadic callable focus remains 55/55. Typed ActionIR probes prove `cb(value: "x")` currently retains one
`raw_perl` positional argument, `cb(value = "x")` correctly retains one positional `assign_scalar`, and
`collector("p", "a", "b")["items"].length()` currently gives the fluent chain a `raw_perl` receiver. The exact
neutral fixture validates and compiles but stops at `reader()` with the untyped message `unsupported runtime
helper 'reader' in rule Top`; Julia has no active-codeblock stack or bound-codeblock fallback after static calls.
Existing `_RuntimeScopedBinding`, recursive `_runtime_copy`, `_execute_runtime_value_statements!`, caller stores,
and generated/reconstructed engine paths are the reusable authority. Knowledge card
`julia-callable-codeblock-dynamic-invocation-gap` makes this causal baseline durable. No production behavior has
changed at this checkpoint.

Implementation evidence 2026-07-30: Julia now owns typed colon keyword arguments without reclassifying positional
`name = value` assignment expressions, plus `ActionValueAccessExpr` for key/index access on an evaluated call
result before fluent continuation. Runtime bound-name fallback runs only after controls, helpers, and registered
user functions. It validates the plain eight-field record, evaluates positional arguments once in an explicit
left-to-right loop, caches the retained typed body by exact literal source, and uses reverse-unwound
`_RuntimeScopedBinding` frames for recursively copied fixed/rest values while leaving nonparameter caller stores
live. A separate ordered active-codeblock stack rejects direct/mutual recursion. The callable boundary catches
raised local returns before rule execution resumes. No closure, capture, host callback/fallback, or second
generated executor exists.

Regression evidence 2026-07-30: RED was 53 pass / 25 fail / 8 error against the missing typed seams. Final focused
proof is 125/125 dynamic plus unchanged 239/239 construction and 55/55 variadic. All eleven valid calls, seven
invalid calls, exact fixture, static precedence, once-only effects, recursive-copy isolation, success/failure
three-store restoration, live nonparameter mutation, nested local return, exact ordered cycles, and native,
normalized reconstructed, generated-plan, and freshly loaded emitted-source roles pass. The first complete
package run caught and prevented an over-broad diagnostic change: portable `unknown_helper` data now applies only
inside an active codeblock, while Julia's established ordinary unknown-helper record stays unchanged. The rerun
passes the complete package. `tools/run_julia_local.sh` passes the byte-fresh 120,030-byte MCP binding, package,
unchanged 18-owner/five-package repository-storage proof, primary CLI, and corpus 105/105. Neutral 7/11/9/7/4/8
also remains exact. At this Julia-local checkpoint, public/docs/governance/canonical signoff remained in progress;
capability/MCP status was unchanged.

Signoff evidence 2026-07-30: Knowledge Map regeneration/check passes at 770 facts / 6,251 question keys; the
mdBook renders 79 files / 13,972 KiB; memory architecture, task metadata, whitespace, root README stability, and
all seven doctrines pass. The fully authorized canonical rerun passes exact semantic and MCP admissions,
repository process containment through its nested macOS `sandbox-exec` boundary, moved-root anchors, primary CLI
66x2, RAM 57%, and Phase 0 1,031/1,031 in 655 seconds before `local CI gate passed`. The initial outer-sandboxed
attempt had reached the containment oracle but could not invoke nested `sandbox-exec`; it changed no tracked
state, and the authorized rerun proved the intended kernel boundary. Exact rendered-book and managed-run cleanup
passes. The workflow commit carries this completed leaf; `.11.6.3` may activate only after the zero-byte brief,
post-commit activation-boundary proof, clean Git status, and output census. Capability/MCP status, other backends,
root README, and push remain unchanged.

- ID: `FUTURE-PARITY-BACKLOG.11.6.3`
  Status: `done`
  Goal: Close Julia generic final-block equivalence, generated execution, docs, and full gates.

### `FUTURE-PARITY-BACKLOG.11.6.3` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate only from clean dynamic-invocation commit `bc85c0fa`
  after exact post-commit activation-boundary proof, zero-byte brief, empty Git status, absent rendered book/cache,
  and zero managed-run residue. Record this checklist before any roadmap, knowledge, behavior, test, or public-doc
  change; do not push before cadence 300.
- [x] **KNOWLEDGE / TOOL-LED BASELINE / DRIFT MAP** — Retrieve ADRs `0031`/`0032`, all eight neutral contextual
  cases and four invalid declarations, the completed Perl/Rust/Dart normalization facts, Julia typed function/
  staged/registry/descriptor/ActionIR/runtime/generated authorities, and the relevant Toolbox probes. Freeze exact
  attached/parenthesized helper, typed-user-function, receiver/tree, explicit-literal, harray, eager/control,
  descriptor, semantic, and emission behavior before production edits; make every durable causal fact searchable.
- [x] **ONE SIGNATURE-GOVERNED NORMALIZATION** — Preserve exact final-only `name: codeblock` declaration metadata
  through parsed definition, staged sidecars, registry, descriptors, and semantic state. Admit only governed
  helper/receiver contracts or the final typed user slot, and normalize equivalent attached/parenthesized forms to
  the existing plain zero-positional `codeblock_argument` consumed by the `.11.6.2` executor. Do not add a Julia
  closure, callback runtime, syntax-specific executor, implicit positional parameter, or backend dialect.
- [x] **PRESERVE DISTINCT SURFACES / PORTABLE FAILURES** — Keep eager block expressions, harrays, attached
  controls, explicit `{|params| ...}` values, ordinary static callable precedence, and existing diagnostics exact.
  Reject unknown attached callees, invalid/non-final codeblock declarations, wrong contextual value arity, and
  malformed metadata without granting semantics from parser spelling alone.
- [x] **NATIVE / SERIALIZED / GENERATED / EMITTED PROOF** — Consume all eight neutral contextual cases and
  mutation-sensitive Julia positives/negatives across parsed/compiled descriptors, staged-sidecar reconstruction,
  native runtime, generated plans, an independently loaded emitted Julia module, typed user functions, helpers,
  receivers, and hash/array tree callbacks. Prove all routes reuse one normalization authority and executor.
- [x] **SIGNOFF / DOCS / JULIA-PARENT CLOSE / CLEAN HANDOFF** — Pass focused and complete Julia gates plus neutral,
  Knowledge Map, mdBook, all doctrines, and warranted canonical proof; synchronize both roadmaps, task/live docs,
  Julia docs, capability guide, and public book; close parent `.11.6`; commit `.11.6.3`, clear the brief, prove
  clean, and only then activate four-backend no-drift/Lua routing `.11.7`. Capability/MCP promotion, other-backend
  behavior, root README, and push remain excluded.

Activation evidence 2026-07-30: `.11.6.2` lands at `bc85c0fa` as commit 116/300 from clean construction boundary
`3a38338d`. The hook proves staged `activation_commit == HEAD` before commit and committed
`activation_commit == HEAD^1` afterward; the brief is zero bytes, Git status is empty, rendered book and Python
cache are absent, and the managed-run census is zero. `.11.6.3` owns Julia generic contextual final-block
equivalence and Julia-parent closeout only. No Julia behavior, roadmap, capability/MCP state, other backend, root
README, or push changes at activation.

Baseline/root-cause evidence 2026-07-30: the neutral checker remains exact at 7 literals / 11 calls / 9 invalid
literals / 7 invalid calls / 4 invalid declarations / 8 contextual forms, and the committed Julia callable suites
remain 125/125 dynamic plus 239/239 construction. The shared definition parser already returns exact
`fixed_params` / `codeblock_param` / `parameter_kinds` records, but Julia rejects the governed declaration as a
missing legacy `params` array. Typed probes further freeze parenthesized helper `with` as an unsupported runtime
helper and unknown attached calls as parser-admitted but runtime-only failures. Source inspection through the
Toolbox/Knowledge-Map route proves that attached function blocks already retain provenance, receiver attachment
still hard-codes four method names, descriptors and staged state lack final-kind metadata, and helpers execute
immediate blocks outside the `.11.6.2` evaluator. The durable card `julia-generic-final-codeblock-gap` records the
smallest coherent repair: one post-registry metadata-governed normalizer plus final-value validation through the
existing executor. No production behavior has changed at this checkpoint.

Implementation/regression evidence 2026-07-30: Julia now retains final-only metadata through the definition,
staged payload/job, validator, registry, version-3 descriptor, generated effective state, and semantic signature.
One new `CallableContract.jl` owner combines builtin helper/receiver contracts with the complete user-function
registry and recursively normalizes only admitted attached/parenthesized blocks to the neutral zero-positional
`codeblock_argument`. Receiver attachment parsing is generic; unknown attached calls and wrong pre-block arities
fail at compilation, while eager blocks, controls, harrays, and explicit literal signatures remain distinct.
Helper/receiver `with`, typed functions, and hash/array tree traversal validate the plain final value and reuse the
`.11.6.2` executor with callback-before-context binding order. Native, compiled-JSON reconstructed, generated-plan,
and freshly loaded emitted Julia agree. Focused proof passes 125/125 dynamic + 118/118 contextual + 239/239
construction; the complete package passes after three intentionally invalid legacy runtime expectations advanced
to the new exact compile-time contract identities. No closure, host callback, second executor, capability/MCP
movement, other-backend change, root README edit, or push occurs. At this implementation checkpoint,
docs/governance/canonical signoff remained pending; the following checkpoint closes it.

Signoff evidence 2026-07-30: the neutral checker remains exact at 7 literals / 11 calls / 9 invalid literals /
7 invalid calls / 4 invalid declarations / 8 contextual forms. Julia focused proof remains 125/125 dynamic +
118/118 contextual + 239/239 construction; the complete package and one uninterrupted Julia-local gate pass the
byte-fresh 120,030-byte MCP binding, 18 storage owners / five locked package trees, primary CLI, and corpus
105/105. Knowledge Map regeneration/check passes at 771 facts / 6,256 question keys; the mdBook renders 79 files /
13,980 KiB and is removed exactly afterward; memory, task metadata, whitespace, root README stability, and all
seven doctrines pass. The definitive canonical wrapper exits 0 after exact semantic/MCP admissions, nested macOS
process containment, moved-root anchors, primary CLI 66x2, RAM 61%, and Phase 0 1,031/1,031 in 966 seconds, then
reports `local CI gate passed`. Exact generated/run cleanup passes; only the workflow landing boundary remains
before `.11.7` activation. Parent `.11.6` is closed without capability/MCP promotion, other-backend behavior, root README,
push, closure capture, host callbacks, or a second executor.

- ID: `FUTURE-PARITY-BACKLOG.11.7`
  Status: `done`
  Goal: Close four-backend callable-codeblock no-drift and route Lua to dependency-complete owners.
  Children: `.11.7.0`, `.11.7.1`, `.11.7.2`
  Dependencies: `.11.3`, `.11.4`, `.11.5`, `.11.6`
  Acceptance: Neutral capability data, docs/book/KM, native/generated proofs, and four admitted backends agree;
    Lua eager value/control/current-built-in work is acknowledged under `.4.3.6`, general user-function contextual
    block execution is routed through `.5.1`, and explicit callable literals/dynamic calls/generated obligations
    are added to dependency-complete Lua leaves without premature behavior claims. Lexical capture remains
    explicitly deferred and requires a new decision/task if later justified.

- ID: `FUTURE-PARITY-BACKLOG.11.7.0`
  Status: `done`
  Goal: Audit the four-backend no-drift surface and split dependency-complete Lua callable work before behavior code.
  Dependencies: `.11.3`, `.11.4`, `.11.5`, `.11.6`
  Acceptance: Knowledge Map facts, ADRs `0031`/`0032`/`0041`, the neutral fixture/checker, established Perl/Rust/
    Dart/Julia native/reconstructed/generated/emitted consumers, and current Lua eager/contextual/staged/generated
    authorities are inspected through the Toolbox route; exact existing and missing mechanisms are recorded;
    `.11.7` gains signoff-sized dependency-ordered children for recurring four-backend proof and public no-drift,
    while new parent `.11.8` gains separate construction, invocation, generated/emitted, and five-backend
    admission children without changing parser, compiler, runtime, descriptor, generated-source, capability, or
    MCP behavior.
  Verification: PASS — unchanged neutral/four-backend/Lua baselines, Knowledge Map 772/6,262, mdBook 79 files /
    13,984 KiB, all seven doctrines, and definitive canonical Phase 0 1,031/1,031 in 653 seconds are green.
  Commit: `FUTURE-PARITY-BACKLOG.11.7.0 - split callable no-drift and Lua routing`

### `FUTURE-PARITY-BACKLOG.11.7.0` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean Julia closeout `3767b8c3`, with
  the commit brief at zero bytes, no generated residue, and no behavior/public-status edit before this owner.
- [x] **KNOWLEDGE / CONTRACT RETRIEVAL** — Retrieve ADRs `0031`/`0032`/`0041`, the neutral contract/checker,
  existing callable Knowledge cards, all four completed backend owners, current public projections, and exact Lua
  eager/contextual/staged/generated owners before re-deriving implementation state.
- [x] **FOUR-BACKEND BASELINE / DRIFT MAP** — Prove the neutral 7/11/9/7/4/8 contract plus focused Perl, Rust,
  Dart, and Julia callable suites; identify the stale mixed capability exclusion and the absence of one recurring
  composed four-backend callable driver without promoting capability state.
- [x] **LUA TOOL-LED GAP MAP** — Probe exact Lua ActionIR rather than eyeballing `.spec`: explicit `{|...|...}`
  falls through to eager-block/raw fallback, colon keyword calls and call-result access lack typed nodes, and
  bound-name invocation has only the narrow zero-argument contextual-slot path. Reuse scoped bindings and the
  effective-spec emitter; do not add a closure, second executor, or second codec.
- [x] **DEPENDENCY-COMPLETE SPLIT BEFORE CODE** — Keep `.11.7.1-.2` behavior-free/four-backend-governance sized;
  route Lua construction, dynamic invocation, generated/emitted identity, and final five-backend admission to
  `.11.8.1-.4` after one detailed `.11.8.0` audit. Preserve static precedence, eager/control/contextual behavior,
  dual-ABI Lua, and explicit deferral of lexical capture.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Make the gap durable in the Knowledge Map; synchronize task
  index, roadmaps, architecture/live docs, Lua documentation, mdBook, and bounded memory; pass Lua baseline,
  focused four-backend proof, governance, mdBook, canonical CI, and exact cleanup; commit `.11.7.0`, clear the
  brief, prove clean, and only then activate recurring four-backend governance `.11.7.1`.

Activation evidence 2026-08-01: Julia closeout `.11.6.3` lands at `3767b8c3` as commit 117/300. The tree and
brief are clean/empty and no rendered book, Python cache, or managed-run residue is present. This leaf owns only
authority retrieval, exact current-state probes, causal documentation, and dependency-ordered task splitting.
No parser, compiler, runtime, descriptor, generated-source, capability, MCP, root README, or push change occurs.

Baseline evidence 2026-08-01: the neutral checker passes 7 literals / 11 calls / 9 invalid literals / 7 invalid
calls / 4 invalid declarations / 8 contextual forms. Focused Perl passes 10 subtests; Rust passes 18 tests; Dart
passes 21 tests; Julia passes dynamic 125/125, contextual 118/118, and construction 239/239. The canonical CI
currently registers the neutral checker and Perl consumer but has no exact recurring four-backend callable
composition. `capability_conformance/manifest.json` still describes Rust dynamic calls and Dart/Julia explicit
values as future even though their committed suites are complete, so `.11.7.1` must correct that exclusion while
leaving the genuinely absent Lua feature and capability admission pending.

Lua gap evidence 2026-08-01: an exact PUC-Lua ActionIR probe parses `{|left, ...rest| return(left) }` as an eager
`block_value` whose body is unsupported raw fallback, retains `cb("x")` only as an ordinary named call, treats
`cb(value: "x")` as unsupported raw positional syntax, and cannot type call-result access before fluent
continuation. `action_ast.lua` and copy/registry paths have contextual `codeblock_argument` but no explicit
eight-field literal. The interpreter eagerly executes `block_value` and invokes only a declared final contextual
slot with zero arguments; it has no post-static bound-codeblock dispatch, active general-codeblock stack, or
portable keyword/not-callable split. Existing `runtime_scoped_binding` and recursive value copy are the correct
temporary-binding authority. Existing source emission serializes and reconstructs one effective `SpecFile`, so
typed AST/schema support should travel through that owner rather than a new generated executor or codec.

Signoff evidence 2026-08-01: Knowledge Map generation/check passes 772 facts / 6,262 question keys; mdBook renders
79 files / 13,984 KiB; memory, task metadata, README stability, whitespace, and all seven doctrines pass. The
complete authorized canonical wrapper passes semantic/MCP admissions, nested kernel process containment,
moved-root proof, primary CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 653 seconds before reporting
`local CI gate passed`. An initial outer-sandboxed run reached the nested containment test but could not invoke
macOS `sandbox-exec`; the complete authorized rerun exercised and passed that required boundary. No production,
fixture, contract, capability, MCP, root README, or push change occurs; only the workflow landing, brief clearing,
clean-status proof, and activation of `.11.7.1` remain.

- ID: `FUTURE-PARITY-BACKLOG.11.7.1`
  Status: `done`
  Goal: Compose omission-sensitive recurring four-backend callable proof and correct neutral status drift.
  Dependencies: `.11.7.0`
  Acceptance: One repository-contained driver executes the unchanged neutral checker and exact focused Perl,
    Rust, Dart, and Julia consumers through project-data wrappers; canonical CI registers that driver exactly
    once. Checker/governance mutations reject missing backend roles, stale paths, lost registration, and premature
    Lua/five-backend admission. The mixed future exclusion names only Lua's measured explicit-literal/dynamic-call
    gap and routes it to `.11.8`; no runtime, descriptor, generated-source, capability row, or MCP behavior moves.
  Verification: PASS — direct and canonical composition pass neutral 7/11/9/7/4/8 + 17 governance mutations,
    Perl 10/10, Rust 18/18, Dart 21/21, and Julia 125/125 + 118/118 + 239/239; capability stays 80/0/0,
    Knowledge Map is 774/6,274, mdBook is 79 files / 13,992 KiB, all seven doctrines pass, and canonical Phase 0
    passes 1,031/1,031 in 825 seconds with the explicit local-CI marker.
  Commit: `FUTURE-PARITY-BACKLOG.11.7.1 - compose four-backend callable proof`

### `FUTURE-PARITY-BACKLOG.11.7.1` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean `.11.7.0` commit `2a9c6f15`
  (118/300), with a zero-byte brief and no rendered-book, bytecode, or managed-run residue.
- [x] **AUTHORITY RETRIEVAL BEFORE IMPLEMENTATION** — Retrieve the callable contract/checker and exact focused
  consumers, existing recurring multi-backend driver/checker patterns, canonical registration seam, project-data
  wrappers, mixed future exclusion, and relevant Knowledge cards before designing topology.
- [x] **ONE EXACT FOUR-BACKEND DRIVER** — Add one repository-contained driver that executes the unchanged neutral
  checker followed by exact focused Perl, Rust, Dart, and Julia consumers in governed order through repository-
  rooted project-data wrappers, with no duplicate semantic authority.
- [x] **OMISSION-SENSITIVE GOVERNANCE / CANONICAL COMPOSITION** — Make the checker reject missing/reordered roles,
  stale paths, duplicate or absent canonical registration, bypassed project-data routing, and premature Lua or
  five-backend admission; register the recurring driver exactly once in canonical local CI.
- [x] **EXCLUSION CORRECTION WITHOUT BEHAVIOR MOVEMENT** — Rewrite the mixed future exclusion to name only Lua's
  measured explicit-literal/general bound-call gap under `.11.8`; retain the 80/0/0 capability census and leave
  parser, compiler, runtimes, descriptors, generated source, fixtures, capability rows, and MCP behavior unchanged.
- [x] **FOCUSED / COMPLETE / DOCS / COMMIT / CLEAN HANDOFF** — Pass mutation-sensitive checker proof, the composed
  driver, backend regression gates, governance, mdBook, canonical CI, and exact cleanup; synchronize live docs,
  commit `.11.7.1`, clear the brief, prove clean, and only then activate public no-drift closeout `.11.7.2`.

Activation evidence 2026-08-01: behavior-free planning leaf `.11.7.0` lands at `2a9c6f15` with its post-commit
activation-boundary check green. Git status is empty, `git_message_brief.txt` is zero bytes, and rendered-book,
Python-bytecode, and managed-run residue are absent. This leaf owns recurring test/governance topology, canonical
composition, and stale exclusion correction only; Lua implementation remains `.11.8` and no public closeout,
capability promotion, MCP movement, root README edit, push, closure, or lexical-capture work is authorized.

Implementation evidence 2026-08-01: `tools/check_callable_codeblock_four_backend.sh` self-roots, enters managed
project storage, and runs the neutral checker before exact Perl, Rust, Dart, and Julia consumers through the
supported Python/Cargo/Dart/Julia wrappers plus managed Perl. The composed gate passes neutral 7/11/9/7/4/8,
Perl 10/10, Rust 18/18, Dart 21/21, and Julia dynamic 125/125 + contextual 118/118 + construction 239/239. The
checker locks ten roles per backend and rejects 17 missing/reordered backend/role, stale path, project-data bypass,
canonical omission/duplication/switch loss, and premature Lua/five-backend mutations. Canonical CI requires and
syntax-checks the driver and contains exactly one `LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX` execution branch.
The mixed exclusion now names only Lua explicit literals/general bound calls and owner `.11.8`; capability remains
80 pass / 0 partial / 0 gap. Workflow routing registers the driver as entrypoint 42 with no new temporary owner.
No parser/compiler/runtime/descriptor/generated-source/fixture/capability-row/MCP behavior changes.

Signoff evidence 2026-08-01: the routed driver passes directly and through its single canonical execution branch:
neutral 7/11/9/7/4/8 plus 17 rejected governance mutations, Perl 10/10, Rust 18/18, Dart 21/21, and Julia dynamic
125/125 + contextual 118/118 + construction 239/239. Capability remains 80 pass / 0 partial / 0 gap; project-data
routing passes at 42 entrypoints with no new allocator. Knowledge Map generation/check passes 774 facts / 6,274
question keys; mdBook renders 79 files / 13,992 KiB and is removed exactly afterward; memory, task metadata,
README stability, whitespace, and all seven doctrines pass. The complete authorized canonical wrapper passes
semantic/MCP admissions, nested process containment, moved-root anchors, primary CLI 66x2, RAM 54%, and Phase 0
1,031/1,031 in 825 seconds, then runs the callable matrix and reports `local CI gate passed`. No production,
fixture, capability-row, MCP, Lua, root README, lexical-capture, or push behavior moves. Only the workflow commit,
brief clearing, clean-status proof, and subsequent task-tree-first activation of `.11.7.2` remain.

- ID: `FUTURE-PARITY-BACKLOG.11.7.2`
  Status: `done`
  Goal: Close four-backend callable-codeblock public no-drift and hand off to Lua without behavior changes.
  Dependencies: `.11.7.1`
  Acceptance: Public backend/API docs, Lua routing, mdBook, roadmaps, ADR/KM/live status, recurring proof, and exact
    omission/status mutations agree that Perl/Rust/Dart/Julia are current while Lua explicit literals and general
    dynamic calls remain pending under `.11.8`; lexical capture remains deferred. Focused/canonical gates pass,
    parent `.11.7` closes, and `.11.8.0` activates only after a clean committed handoff. The mdBook is the sole
    user-facing specification surface: no known code, behavior, capability, roadmap, or backend-status drift may
    cross this leaf's commit boundary, and a rendered build is mandatory.
  Verification: PASS — 23 exact public documents, nine forbidden stale/premature claims, and three public
    omission mutations extend recurring governance to 20; neutral 7/11/9/7/4/8, Perl 10, Rust 18, Dart 21,
    Julia 125 + 118 + 239, capability 80/0/0, Knowledge Map 775/6,283, mdBook 79 files / 13,996 KiB, all seven
    doctrines, and canonical Phase 0 1,031/1,031 in 659 seconds plus the optional callable matrix pass.
  Commit: `FUTURE-PARITY-BACKLOG.11.7.2 - close callable public no-drift`

### `FUTURE-PARITY-BACKLOG.11.7.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean recurring-governance commit
  `c86f32fa` (119/300), with zero-byte brief and no rendered-book, bytecode, or managed-run residue.
- [x] **AUTHORITY RETRIEVAL BEFORE AUDIT** — Retrieve ADRs `0031`/`0032`/`0041`, the literal and recurring-gate
  Knowledge cards, executable checker/manifest, public projections, and established closed-capability marker
  doctrine before classifying any public statement.
- [x] **EXACT PUBLIC INVENTORY / DRIFT PROOF** — Inventory every backend/API guide, capability narrative, roadmap,
  task/index, live architecture, mdBook, Knowledge, and checker-owned current/future claim; prove omissions and
  stale completed-backend or premature Lua/five-backend claims fail closed.
- [x] **FOUR-BACKEND CURRENT / LUA-ONLY FUTURE LOCKSTEP** — Synchronize public authorities so Perl, Rust, Dart,
  and Julia explicit construction/dynamic/contextual/native/reconstructed/generated/emitted routes are current,
  while Lua explicit literals/general bound calls/generated identity/admission remain `.11.8`; keep lexical
  capture deferred and do not change production, fixture, capability-row, or MCP behavior.
- [x] **PARENT CLOSEOUT / LUA HANDOFF** — Close parent `.11.7`, preserve one stable public marker outside the
  mutable frontier, and make detailed Lua RED audit `.11.8.0` the single next action only after clean landing.
- [x] **FOCUSED / DOCS / CANONICAL / COMMIT / CLEAN HANDOFF** — Pass checker mutations, recurring driver,
  public/governance/book checks plus a rendered mdBook build, canonical CI, and exact cleanup; commit `.11.7.2`,
  clear the brief, and prove clean before activating `.11.8.0`. Treat the mdBook as the sole user-facing
  specification and allow no known code/status drift across the commit boundary.

Activation evidence 2026-08-01: recurring-governance leaf `.11.7.1` lands as `c86f32fa` (119/300) with its
post-commit pointer resolving to parent `2a9c6f15`. Git status is empty, `git_message_brief.txt` is zero bytes,
and rendered-book, Python-bytecode, and managed-run residue are absent. This leaf owns public inventory,
omission-sensitive no-drift, parent closeout, and the clean Lua handoff only. No parser/compiler/runtime/
descriptor/generated-source/fixture/capability-row/MCP, root README, lexical-capture, push, or Lua behavior change
is authorized.

Implementation evidence 2026-08-01: the neutral callable contract now owns an exact, duplicate-independent
23-document public inventory, one required current/future marker per document, and nine forbidden stale or
premature claims. The checker validates both the data file and its own expected projection, so deleting a
document from only the contract cannot make that document invisible. Three RED mutations prove document omission,
required-marker omission, and forbidden-claim omission fail; together with the 17 recurring topology/status
mutations, governance is 20. The first exact inventory run correctly failed on a missing `USER_GUIDE.md` marker;
after synchronizing the governed surfaces it passes. Public prose now states Perl/Rust/Dart/Julia current across
construction, invocation, contextual, native, reconstructed, generated, and emitted paths, while Lua contextual
forms remain current and explicit values/general bound calls/generated identity/admission remain `.11.8`.
Capability stays 80/0/0. No production, fixture, capability-row, MCP, Lua, or root README behavior changes.

Signoff evidence 2026-08-01: the neutral checker passes 7 literals / 11 calls / 9 invalid literals / 7 invalid
calls / 4 invalid declarations / 8 contextual forms plus all 20 governance mutations. The recurring driver passes
Perl 10, Rust 18, Dart 21, and Julia dynamic 125 + contextual 118 + construction 239; capability remains 80/0/0,
workflow routing/tool storage pass at 42 entrypoints, Knowledge Map generation/check passes 775 facts / 6,283
question keys, and the sole-facing mdBook renders 79 files / 13,996 KiB before exact removal. Memory, task,
README, whitespace, and all seven doctrines pass. The definitive authorized canonical wrapper passes exact
semantic/MCP admissions, nested process containment, moved-root anchors, CLI 66x2, RAM 62%, and Phase 0
1,031/1,031 in 659 seconds, then passes the optional callable matrix at neutral+20, Perl 10, Rust 18, Dart 21,
Julia 125+118+239 and reports `local CI gate passed`. Parent `.11.7` is closed; only workflow landing, brief
clearing, and clean proof remain before task-tree-first `.11.8.0` activation.

- ID: `FUTURE-PARITY-BACKLOG.11.8`
  Status: `done`
  Goal: Complete explicit callable-codeblock values and general dynamic invocation on Lua and LuaJIT.
  Children: `.11.8.0`, `.11.8.1`, `.11.8.2`, `.11.8.3`, `.11.8.4`
  Dependencies: `.11.7`
  Acceptance: Both Lua ABIs consume the unchanged neutral syntax, typed eight-field value, caller-context
    invocation, final-block equivalence, portable failures, serialized/generated identity, recurring proof, and
    public/capability admission without host closures, lexical capture, broad raw fallback, or a second executor.

- ID: `FUTURE-PARITY-BACKLOG.11.8.0`
  Status: `done`
  Goal: Freeze the dependency-complete Lua callable implementation plan from typed authority probes before code.
  Dependencies: `.11.7.2`
  Acceptance: Retrieve the exact parser/AST/schema/copy/registry/interpreter/scoped-binding/descriptor/semantic/
    generated/emitted/dual-ABI owners; reproduce every missing neutral mechanism and current preserved surface;
    define RED consumers, portable diagnostics, route identity, and signoff boundaries for `.11.8.1-.4` without
    changing production behavior.
  Verification: PASS — neutral 7/11/9/7/4/8+20, Lua 177/177 per ABI + CLI 66x2 + corpus 105/105, Knowledge Map
    776/6,291, mdBook 79 files / 14,008 KiB, all seven doctrines, canonical RAM 61% and Phase 0 1,031/1,031 in
    653 seconds, plus the exact Perl/Rust/Dart/Julia callable matrix are green with the explicit local-CI marker.
  Commit: `FUTURE-PARITY-BACKLOG.11.8.0 - freeze Lua callable plan`

- ID: `FUTURE-PARITY-BACKLOG.11.8.1`
  Status: `done`
  Goal: Add inert typed callable-codeblock literal construction and state preservation on Lua.
  Dependencies: `.11.8.0`
  Acceptance: `action_parser.lua` recognizes exact `{|params| body }` / `{|| body }` before harray/eager-block
    classification and `action_ast.lua` owns the neutral fixed/final-rest signature plus eight-field literal;
    containing Unicode-character spans and all nine malformed-literal codes are exact. Copy/registry/runtime-kind,
    compiled ActionIR JSON, function argument/result transport, deferred action-contract/removed-selector scans,
    semantic binding shape, generated plan, and emitted effective state preserve inert plain data without executing
    its body or creating a host closure. Begin one contract-driven focused Lua consumer and register its green
    construction leg unchanged on both ABIs in the complete Lua gate.
  Verification: **PASS 2026-08-01.** The focused consumer passes 168 assertions unchanged on PUC Lua and LuaJIT;
    the complete Lua gate preserves 177 legacy tests per ABI, primary CLI 66x2, corpus 105/105, and 16 storage
    owners. Neutral callable governance passes 7/11/9/7/4/8 plus 20 mutations; selector retirement passes with
    zero positive current examples; Knowledge Map is 777/6,301; the sole-facing mdBook renders 79 files /
    14,028 KiB; and all seven doctrines pass. Definitive canonical CI passes both primary environments at 66/66,
    RAM 58%, Phase 0 1,031/1,031, and the exact Perl 10 / Rust 18 / Dart 21 / Julia 125+118+239 callable matrix
    before `local CI gate passed`.
  Commit: `FUTURE-PARITY-BACKLOG.11.8.1 - construct inert Lua codeblocks`

### `FUTURE-PARITY-BACKLOG.11.8.1` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean behavior-free audit commit
  `7e02ecee` (121/300), with zero-byte brief and no rendered-book, bytecode, or managed-run residue before any
  parser, ActionIR, test, gate, or documentation edit.
- [x] **AUTHORITY RETRIEVAL / RED CONSUMER FIRST** — Reverify the frozen audit fact and exact Lua parser, AST,
  signature, copy/registry/runtime-kind, deferred traversal, semantic, compiled/generated/emitted, user-function,
  complete-gate, storage, and neutral-fixture owners; create the one contract-driven Lua consumer with RED proof
  on both ABIs before production behavior changes.
- [x] **EXACT TYPED LITERAL / PORTABLE FAILURES** — Recognize fixed, zero-parameter, and final-rest brace-pipe
  literals before harray/eager blocks; preserve the neutral eight fields, source, containing Unicode-character
  span, nullable signature, typed body, and all nine malformed-literal diagnostic codes without raw fallback.
- [x] **INERT STATE / DEFERRED TRAVERSAL / FUNCTION TRANSPORT** — Preserve recursively copied plain literal data
  through ActionIR copy/registry/runtime-kind, compiled JSON, generated plan, emitted effective state, semantic
  binding signature, and user-function argument/result transport. Deferred bodies must not execute or create
  eager action dependencies/removed-selector failures; no host closure or bound-call dispatch is authorized.
- [x] **DUAL-ABI FOCUSED / COMPLETE REGRESSION** — Make the same focused construction consumer green unchanged
  on PUC Lua and LuaJIT; register it in the complete Lua gate; preserve eager/control/harray/contextual/static-call
  behavior, CLI/corpus/storage boundaries, and reject ABI or route drift.
- [x] **LOCKSTEP DOCS / GATES / COMMIT / CLEAN HANDOFF** — Synchronize Lua API docs, Knowledge Map, task/index/
  roadmap/architecture/live/memory, and sole-facing mdBook with exact inert behavior and examples; pass focused,
  complete Lua, neutral/governance, rendered-book, doctrine, and warranted canonical gates; commit `.11.8.1`, clear
  the brief, prove exact cleanup/clean status, then activate `.11.8.2`; do not push.

Activation evidence 2026-08-01: behavior-free audit `.11.8.0` lands at `7e02ecee` as commit 121/300 with its
pre/post activation-boundary checks and all seven doctrines green. Git status is empty, `git_message_brief.txt` is
zero bytes, and rendered-book, Python-bytecode, and managed-run residue are absent. This leaf owns the one focused
Lua construction consumer plus exact inert parser/ActionIR/state/semantic preservation and complete-gate dual-ABI
registration. It authorizes no bound-name execution, colon-keyword/value-access work, portable call failures,
recursion stack, new generated/emitted route, capability-row/MCP/public admission, lexical capture, closure,
second codec/executor, root README edit, push, or task pivot.

Implementation evidence 2026-08-01: the first valid cross-ABI RED run reached the missing production boundary as
an absent typed `body_ast`; no production file had changed. Exact `{|` classification now precedes existing harray
and eager-block routing, and one `ActionCallableSignature`/`codeblock_literal` owner projects only the neutral
eight fields. Fixed, zero-parameter, and final-rest signatures, containing Unicode-character spans, nested
delimiters/literals, and all nine malformed codes are exact. Contract and removed-selector traversal stop at the
deferred literal while preserving eager/contextual behavior. Runtime copy, user-function transport, runtime kind,
compiled ActionIR JSON, generated-plan execution, emitted effective-`SpecFile` reconstruction, and semantic
bindings preserve inert typed data without a closure, codec, or executor. A strengthened copy-span assertion then
found and corrected a real offset-zero reparse bug by adding one parser-owned offset-preserving reparse seam.
The single focused consumer passes 168 assertions unchanged on PUC Lua and LuaJIT; the complete registered Lua
gate passes all 177 legacy tests per ABI, primary CLI 66x2, corpus 105/105, and 16-owner repository-storage proof.
The first canonical run then found one public no-drift violation in the new inert-body fixture: its deliberately
deferred body still spelled a retired aggregate selector, which the repository-wide executable-source scanner
correctly rejects even when unreachable. Removing that obsolete positive spelling preserves the deferred-body
contract proof without weakening the final selector-retirement invariant. The corrected uninterrupted canonical
run passes RAM 58%, Phase 0 1,031/1,031, neutral+20, and the Perl/Rust/Dart/Julia callable matrix before the exact
local-CI marker. Dynamic bound invocation, call-result access, colon-keyword diagnostics, and recursion remain
`.11.8.2`.

- ID: `FUTURE-PARITY-BACKLOG.11.8.2`
  Status: `done`
  Goal: Execute Lua bound callable-codeblock calls with dynamic caller context and portable failures.
  Dependencies: `.11.8.1`
  Acceptance: Add only colon-keyword call data and an evaluated-value access receiver; `name = value` remains a
    positional assignment expression. Controls, governed helpers, and registered functions retain static precedence
    before bound-name dispatch. Positional arguments evaluate exactly once left-to-right; existing
    `runtime_scoped_binding.run_frame` owns recursively copied fixed/rest bindings and reverse restoration across
    all three stores on success/failure while nonparameter caller stores stay live. One interpreter owns explicit
    and declared-final-block execution, invocation-local return, access/chaining/discard, and an ordered active
    codeblock stack. Keyword, arity, non-callable, unknown-body-helper, and direct/mutual recursion diagnostics use
    exact neutral fields on PUC Lua and LuaJIT without lexical capture or raw fallback.

### `FUTURE-PARITY-BACKLOG.11.8.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean inert-construction commit
  `86498cc7` (122/300), with zero-byte brief and no rendered-book, bytecode, or managed-run residue before any
  parser, interpreter, focused-test, gate, or documentation edit.
- [x] **AUTHORITY RETRIEVAL / INVOCATION RED** — Re-read ADR `0031`, the neutral calls/failures/fixture rows,
  admitted backend precedents, Lua construction/audit/scoped-binding/interpreter facts, and current static-call/
  contextual behavior; extend the existing focused consumer to exact dynamic RED on both ABIs before production.
- [x] **NARROW TYPED CALL DATA / STATIC PRECEDENCE** — Add only colon-keyword argument records and access rooted at
  an evaluated value; preserve `name = value` as a positional assignment expression and keep controls, helpers,
  and registered user functions ahead of bound-variable dispatch without broad raw fallback.
- [x] **ONE INTERPRETER / DYNAMIC CALLER FRAME** — Reuse the existing interpreter and
  `runtime_scoped_binding.run_frame` for once-only left-to-right arguments, recursively copied fixed/rest values,
  reverse restoration across all parameter stores, live nonparameter caller state, local return, discard, access,
  chaining, and declared-final-block equivalence; add no closure, capture, codec, or executor.
- [x] **PORTABLE FAILURES / ACTIVE STACK** — Produce the exact neutral keyword, arity, non-callable, unknown-name,
  unknown-body-helper, and ordered direct/mutual recursion diagnostics on PUC Lua and LuaJIT through one active
  codeblock stack, with no host exception fallback or route-specific behavior.
- [x] **DUAL-ABI / REGRESSION / LOCKSTEP** — Grow the same focused consumer unchanged on both ABIs; preserve eager,
  control, harray, contextual, registered-function, compiled/generated, CLI/corpus, and storage behavior; sync the
  sole-facing mdBook and live/KM/task/roadmap/memory surfaces; pass focused, complete Lua, neutral/governance,
  rendered-book, doctrines, and warranted canonical gates; commit/clear/prove clean before `.11.8.3`; do not push.

Activation evidence 2026-08-01: inert construction `.11.8.1` lands at clean commit `86498cc7` as 122/300 after
pre/post memory-boundary checks and all seven doctrines pass. Git status is empty, `git_message_brief.txt` is zero
bytes, and rendered-book, Python-bytecode, and managed-run residue are absent. This leaf may extend the existing
focused Lua consumer and the narrow parser/interpreter/scoped-binding authorities only for dynamic invocation,
result access, declared-final-block equivalence, exact failures, and recursion on both ABIs. It may not add
byte-fresh emitted execution/project-data ownership (`.11.8.3`), five-backend/capability/public/MCP admission
(`.11.8.4`), lexical capture, host closures/functions, a second codec/executor, root README edits, push, or pivot.

RED evidence 2026-08-01: Knowledge Map-first retrieval re-read ADR `0031`, all neutral call/failure/fixture rows,
the completed Perl/Rust/Dart/Julia precedents, and the Lua typed-audit, construction, contextual-final-block, scoped-
binding, parser, interpreter, diagnostic, semantic, and generated-route owners. The focused consumer now owns colon
keyword versus positional `name = value`, evaluated call-result access, all eleven call-case IDs, the exact neutral
fixture, static helper/function precedence, once-only ordering, copied nested parameters, declared-final explicit
literals, invocation-local nested return, all seven neutral failures, ordered mutual recursion, and registered-
function keyword policy. Its first production-free PUC run stops exactly at the absent evaluated receiver:
`collector("p")["items"].length()` parses as a fluent chain whose `receiver` has no typed receiver child. This is
the planned `.11.8.2` boundary; only the task-tree and RED consumer differ from clean activation.

Implementation evidence 2026-08-01: the parser now recognizes only top-level `name: value` call arguments as
typed keywords, retains `name = value` as a positional assignment, and shares one segment parser between named and
evaluated-value access. Removed-selector traversal, action-contract traversal, semantic call discovery, and the
runtime all consume the new `value_access` node. After all static helpers/controls and registered functions, one
bound-name path distinguishes codeblocks from other bound values, evaluates positional expressions once in order,
and passes copied fixed/final-rest values to the existing cleanup-safe `runtime_scoped_binding.run_frame`; the
typed retained body executes in the existing interpreter against live caller nonparameter stores. The former
contextual-only executor and stack are gone: explicit literals and declared final-block values share one local-
return path and one ordered `active_codeblocks` stack. Runtime diagnostics now project the neutral
`callable_name`/`expected`/`got`/`value_kind`/`name`/array-`cycle` fields. The first implementation run crossed Lua's
200-local chunk ceiling; grouping the new seams behind one local namespace restored PUC/LuaJIT compatibility
without splitting or duplicating the interpreter. Focused proof passes 232 assertions on each ABI. The complete
Lua gate initially caught two contextual-era wording/string-cycle expectations; moving those assertions to the
neutral structured form makes the uninterrupted rerun green: all 177 legacy TAP groups on both ABIs, CLI 66x2,
corpus 105/105, and all 16 repository-storage owners pass.

Signoff evidence 2026-08-01: neutral callable governance passes 7/11/9/7/4/8 plus 20 mutations, the callable-
signature checker passes 3/9/7, and capability conformance stays 80 pass / 0 partial / 0 missing without advancing
Lua's recurring/public admission. Knowledge Map generation/check passes 778 facts / 6,311 keys; the sole-facing
mdBook renders 79 files / 14,028 KiB; whitespace, memory/task metadata, and all seven doctrines pass. The first
canonical attempt reached the nested project-data-process containment check but the outer Codex sandbox denied
its inner `sandbox-exec` with status 71. The identical authorized rerun proves the relocated six-family process
driver, moved-root and outside-CWD behavior, both primary CLI environments at 66/66, RAM 51%, Phase 0 at
1,031/1,031 in 801 seconds, and the exact neutral+20 / Perl 10 / Rust 18 / Dart 21 / Julia 125+118+239 callable
matrix before `local CI gate passed`. Commit/brief cleanup and exact clean proof are the only remaining workflow
operations before task-tree-first `.11.8.3`; no push.
  Commit: `FUTURE-PARITY-BACKLOG.11.8.2 - invoke Lua callable codeblocks`

Later route-audit correction 2026-08-01 (`.11.8.3`): `.11.8.2` correctly closed ordinary bound invocation and
declared-final user-function execution, but its contextual-current narrative was one neutral form too broad. Exact
per-form PUC Lua probes show helper/receiver/user-function attached and parenthesized blocks plus explicit user-
function literals pass, while explicit literals passed to built-in `with` still reach the older `block_value`-
only final-helper executor and fail `final_argument_not_codeblock`. `.11.8.3` owns the narrow prerequisite repair
because honest emitted-route identity cannot preserve a native route that is not yet neutral-complete; the shared
callable executor, neutral syntax, and `.11.8.4` admission boundary remain unchanged.

- ID: `FUTURE-PARITY-BACKLOG.11.8.3`
  Status: `done`
  Goal: Prove Lua serialized, reconstructed, generated, and independently emitted callable execution identity.
  Dependencies: `.11.8.2`
  Acceptance: Extend the same focused Lua consumer, not a second oracle. The existing effective-`SpecFile`
    serializer/emitter carries the typed literal and one interpreter executes every neutral valid/invalid/dynamic/
    contextual case through native compilation, normalized `SpecFile` reconstruction, generated plan, and a
    byte-fresh independently loaded emitted module on both ABIs. Register the emitted-module allocator as the exact
    next Lua project-data owner. Mutation-sensitive proof denies closure capture, host function storage,
    route-specific codecs/executors, contextual/eager/control regressions, cleanup residue, and ABI drift.

### `FUTURE-PARITY-BACKLOG.11.8.3` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean dynamic-invocation commit
  `3f220f6c` (123/300), with zero-byte brief and no rendered-book, bytecode, or managed-run leaf residue before any
  emitted-route test, allocator, production, gate, or documentation edit.
- [x] **KNOWLEDGE / EMITTER / ROUTE RED RETRIEVAL** — Re-read the callable neutral fixture/failures, Lua typed-
  audit/construction/invocation facts, generated-source emitter/scaffold/fresh-process owners, existing focused
  consumer, and Lua project-data oracle; extend only the same consumer to an exact independently loaded emitted-
  route RED on both ABIs before production or allocator changes.
- [x] **ONE TYPED STATE / ONE INTERPRETER IDENTITY** — Prove native compiled execution, normalized `SpecFile`
  reconstruction, generated plan, and byte-fresh emitted module preserve every callable valid/invalid/dynamic/
  contextual case through existing `spec_ast.to_json`/`from_json`, compiler, and interpreter authorities. Add no
  closure, host function, route-specific codec/executor, payload rewrite, or generated-only semantic path.
- [x] **REPOSITORY-CONTAINED EMITTED ALLOCATOR** — Add the exact emitted-module temporary owner to the Lua project-
  data manifest/oracle, derive every path from repository-rooted managed storage, execute both PUC Lua and LuaJIT
  against fresh bytes, and prove cleanup plus rejection of off-volume/symlink or stale-artifact escape as warranted.
- [x] **MUTATION-SENSITIVE DUAL-ABI REGRESSION** — Keep one unchanged focused consumer on both ABIs; deny missing/
  stale emitted payloads, closure/function storage, second codecs/executors, route omission, ABI drift, ordinary
  eager/control/contextual regressions, and residue. Preserve complete Lua, CLI/corpus, and storage-owner gates.
- [x] **LOCKSTEP / SIGNOFF / COMMIT / CLEAN HANDOFF** — Synchronize Lua/API, Knowledge Map, task/index/roadmap/live/
  memory, and sole-facing mdBook surfaces; pass focused, complete Lua, neutral/governance, storage, rendered-book,
  doctrines, and warranted canonical gates; commit `.11.8.3`, clear the brief, prove clean, then activate only
  `.11.8.4`; do not push.

Activation evidence 2026-08-01: `.11.8.2` lands at clean commit `3f220f6c` as 123/300 after focused 232x2,
complete Lua 177 TAP groups per ABI, CLI 66x2, corpus 105/105, 16 storage owners, neutral+20, signatures,
capability 80/0/0, Knowledge Map 778/6,311, mdBook 79/14,028 KiB, all seven doctrines, canonical RAM 51%, Phase 0
1,031/1,031, and the exact four-backend callable matrix pass. Git status is empty, `git_message_brief.txt` is zero
bytes, rendered-book/Python-bytecode/run-leaf residue is absent, and the empty checkout run namespace is its
documented stable allocator parent. This leaf owns only route identity and the exact next Lua project-data owner;
five-backend recurring/public/capability/MCP admission was deliberately deferred to `.11.8.4` at this boundary,
while lexical capture, host closures,
second codecs/executors, root README edits, push, and unrelated memory-architecture work remain excluded.

RED/root-cause evidence 2026-08-01: Knowledge Map retrieval re-read the Lua callable audit/construction/invocation,
generated emitter/scaffold/fresh-host, and project-data owners before extending the same focused consumer. The
first production-free PUC run stops at `helper 'with' final argument must be a codeblock`. A LinkedSpec-owned exact
per-form compile/runtime probe reduces the failure to neutral `with("x", {|value| ...})` and receiver `.with`
explicit literals; attached/parenthesized helper/receiver/user-function blocks and explicit user-function literals
pass. `action_contracts` correctly leaves already typed literals unnormalized, and the general bound executor can
run them. The stale seam is `interpreter.final_codeblock_argument` plus `evaluate_with_block`, which accept only
`block_value` and execute `.block` directly. The smallest dependency repair is to evaluate/validate any final
codeblock value before installing the scoped `value`, then reuse the one callable executor with zero arguments for
contextual blocks and the scoped value for explicit/bound literals. The same rule applies to tree callbacks; no
new executor, codec, syntax, or generated route is authorized.

Implementation and focused GREEN evidence 2026-08-01: one `evaluate_final_codeblock` seam now resolves a final
callback before installing helper/tree scoped `value`, preserves authored contextual blocks as callable data, and
validates explicit or bound codeblock values. Built-in helper/receiver/tree callbacks and ordinary bound calls
share `callable_codeblock.execute_values`; distinct anonymous nested built-in callbacks have no recursive identity,
while a callback passed by variable retains that variable name through helper dispatch. The focused consumer proves the exact
neutral fixture/failures, invocation and contextual forms through native execution, canonical effective-`SpecFile`
reconstruction, generated-plan execution, and fresh emitted modules on PUC Lua and LuaJIT. It deliberately stores
a callback in the caller variable named `value`, nests `with`, rejects corrupt payload, compares exact emitted
bytes and generated wrapper/runtime details, denies plaintext host closure bodies, and proves cleanup on success
and injected failure. Both ABIs pass 449 assertions.

Storage and regression evidence 2026-08-01: the production-free storage RED reported the expected owner drift
from 16 to 17. The oracle now registers only the focused callable consumer and passes exact repository-device,
native-module/generated/trace, cleanup, and escape checks. The first complete Lua run exposed false recursion
`["with","with"]` when the shared executor tracked a built-in helper name as a bound callable identity. Omitting
helper-name tracking for anonymous final-block dispatch preserves dynamic direct/mutual recursion and restores
nested callbacks. A subsequent signoff audit added variable-bound helper recursion identity and its exact
`["callback","callback"]` cycle. Focused 449x2, core 177x2, and the uninterrupted complete gate now pass with CLI 66x2,
corpus 105/105, 17 owners, and `Lua local gate passed`. Admission is still exclusively `.11.8.4`.

Lockstep governance evidence 2026-08-01: after the book correctly moved emitted identity from future to current,
the callable public checker rejected its own stale formal-grammar marker. The contract and duplicate-independent
expectation now require the current `.11.8.3` marker, while `future.generic_final_codeblock` remains present and is
narrowed only from route-plus-admission to admission-only `.11.8.4`. The callable checker again passes all neutral
rows plus 20 mutations; capability remains exactly 80/0/0 and generated-source admission remains unchanged.

Signoff evidence 2026-08-01: focused proof passes 449 assertions on each ABI; complete Lua passes 177 TAP groups
per ABI, CLI 66x2, corpus 105/105, and 17 storage owners. Neutral callable governance passes 7 literals / 11 calls /
9 invalid literals / 7 invalid calls / 4 invalid declarations / 8 contextual forms plus 20 mutations; callable
signatures pass 3/9/7; capability and generated-source state remain unchanged at 80/0/0. Knowledge Map generation
and checking pass 779 facts / 6,322 question keys, the sole-facing mdBook renders 79 files / 14,048 KiB, whitespace,
memory/task metadata, and all seven doctrines pass. The definitive authorized canonical gate proves repository
containment and moved-root/outside-CWD execution, CLI 66x2, RAM 51%, Phase 0 1,031/1,031 in 809 seconds, and the
exact neutral+20 / Perl 10 / Rust 18 / Dart 21 / Julia 125+118+239 callable matrix before `local CI gate passed`.
Only the workflow landing, zero-byte brief, and exact clean proof remain before task-tree-first `.11.8.4`; no push.
  Commit: `FUTURE-PARITY-BACKLOG.11.8.3 - prove Lua emitted callable identity`

- ID: `FUTURE-PARITY-BACKLOG.11.8.4`
  Status: `done`
  Goal: Admit Lua into recurring five-backend callable conformance and close public no-drift.
  Dependencies: `.11.8.3`
  Acceptance: Replace the four-backend composition with one rooted, omission-sensitive five-backend driver that
    proves the unchanged neutral checker and exact Perl/Rust/Dart/Julia/Lua consumers, invoking the same Lua file
    on both ABIs from managed repository storage. Update checker topology/order/role/path/dual-ABI mutations and
    canonical registration exactly once; remove the Lua-only future exclusion and advance capability/public state
    only after exact proof. Public backend/API docs, Lua docs, sole-facing mdBook, roadmaps, ADR/KM/live status, and
    exclusion records agree; focused/complete/canonical gates pass; parent `.11.8` and callable parent `.11` close
    with lexical capture still explicitly excluded from version 1.

### `FUTURE-PARITY-BACKLOG.11.8.4` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean emitted-identity commit
  `917038e7` (124/300), with zero-byte brief and no rendered-book or managed-run leaf residue before any driver,
  checker, capability, exclusion, public, or canonical edit.
- [x] **KNOWLEDGE / GOVERNANCE / ROUTE RETRIEVAL** — Re-read the recurring/public/Lua-admission Knowledge cards,
  neutral contract/checker, existing four-backend driver, canonical registration, workflow/storage owners,
  capability/exclusion authorities, and exact Lua dual-ABI consumer before changing topology.
- [x] **ONE FIVE-BACKEND RECURRING DRIVER** — Replace the four-backend composition with one rooted driver that
  runs neutral, Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in exact order through supported project-data routes;
  keep one semantic consumer per backend and no duplicate Lua oracle.
- [x] **OMISSION-SENSITIVE GOVERNANCE / ADMISSION** — Update exact path/role/order/dual-ABI/canonical/storage/public
  mutations, remove only the satisfied generic-final-codeblock future exclusion, and advance only the governed
  callable recurring/public/capability state warranted by the five-backend proof.
- [x] **MUTATION-SENSITIVE REGRESSION** — Prove missing/reordered/duplicated backend or ABI legs, stale four-
  backend paths/claims, route bypass, exclusion residue, premature closure, and lexical-capture claims fail while
  focused consumers, complete backend gates, CLI/corpus, generated source, and capability census remain exact.
- [x] **LOCKSTEP / SIGNOFF / COMMIT / CLEAN HANDOFF** — Synchronize backend/API, Knowledge Map, task/index/roadmap/
  live/memory, and sole-facing mdBook surfaces; pass focused, five-backend, governance, storage, rendered-book,
  doctrines, and canonical gates; close `.11.8` and parent `.11`, commit `.11.8.4`, clear the brief, prove clean,
  then choose the next roadmap-aligned activity; do not push.

Activation evidence 2026-08-01: `.11.8.3` lands clean at `917038e7` as 124/300 after focused 449x2, complete Lua
177x2, CLI 66x2, corpus 105/105, 17 storage owners, neutral+20, signatures 3/9/7, capability 80/0/0, Knowledge Map
779/6,322, sole-facing mdBook 79/14,048 KiB, all seven doctrines, canonical RAM 51%, Phase 0 1,031/1,031 in 809
seconds, and the exact four-backend callable matrix. Pre/post memory-boundary hooks pass, Git status is empty,
`git_message_brief.txt` is zero bytes, rendered-book residue is absent, and the documented checkout allocator
parent is empty. This leaf alone owns five-backend recurring/public/capability admission and closure; it excludes
parser/compiler/runtime semantics, emitter format, lexical capture, MCP, root README, unrelated memory-
architecture work, history rewriting, and push.

Retrieval evidence 2026-08-01: before topology changes, Knowledge Map pointers re-opened the four-backend
recurring/public closeout, Lua emitted-route identity, Lua five-backend capability admission, neutral callable
contract/checker, ADR `0041`, the existing rooted driver, canonical optional branch, workflow-routing inventory,
capability manifest/exclusion, and the unchanged Lua consumer. The exact replacement boundary is one renamed
driver, the checker-owned topology with two ordered Lua runtime rows over one test file, one canonical/storage
registration, removal of only `future.generic_final_codeblock`, and omission-sensitive public-current markers.
The existing 16-capability five-backend census remains 80/0/0; this leaf completes the separately excluded
callable feature rather than inventing an unrelated seventeenth census row.

Implementation and composed-proof evidence 2026-08-01: the recurring driver is renamed exactly once to
`tools/check_callable_codeblock_five_backend.sh` and remains repository-rooted. It runs the unchanged neutral
checker, Perl, Rust, Dart, and Julia consumers in dependency order, then executes the same focused Lua consumer
through `tools/run_lua_project_data.sh` on PUC Lua and LuaJIT. The neutral checker owns the exact six-runtime/five-
backend topology, shared-Lua-path and dual-ABI identities, canonical registration, stale-driver denial, public
surface, and satisfied-exclusion absence with 22 mutation sentinels. Only `future.generic_final_codeblock` is
removed from the manifest; the existing 16-capability five-backend census is not expanded. The fresh composed run
passes neutral 7/11/9/7/4/8 plus 22 mutations, Perl 10, Rust 18, Dart 21, Julia 125+118+239, PUC Lua 449, and LuaJIT
449 before reporting that all five-backend callable contract and authority routes pass.

### `FUTURE-PARITY-BACKLOG.11.8.4` TOOLBOX.md Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `rg -n` over the old driver, canonical registration, manifest, and public contract
  showed a four-backend topology, no Lua consumer legs, and the still-present callable future exclusion; the first
  renamed-driver neutral run rejected the missing governed path before topology and public markers were updated.
- [x] **ROOT CAUSE (WHY + WHERE)** — Tool-backed inspection located an admission/governance seam, not a parser or
  runtime defect: `tools/check_callable_codeblock_contract.py` owned the exact topology and mutations,
  `tools/run_ci_local.sh` owned canonical registration, and `capability_conformance/manifest.json` owned the stale
  satisfied exclusion. The already-green Lua focused consumer was the implementation oracle for both ABIs.
- [x] **FIX** — Renamed one rooted composition driver, added ordered PUC Lua and LuaJIT project-data legs over the
  same consumer, expanded duplicate-independent governance to 22 mutations and 25 public documents, registered
  the new path exactly once, and removed only `future.generic_final_codeblock`.
- [x] **ADDRESSED (verified)** — `bash tools/check_callable_codeblock_five_backend.sh` passes neutral
  7/11/9/7/4/8 + 22 mutations, Perl 10, Rust 18, Dart 21, Julia 125+118+239, and Lua 449 on each ABI; workflow
  routing reports `PASS` from outside the repository CWD.
- [x] **NO REGRESSION** — `bash tools/run_lua_local.sh` reaches 177 TAP groups on each ABI, CLI 66x2, corpus
  105/105, 17 project-data owners, and `Lua local gate passed`; capability and generated-source checks remain
  exactly 80/0/0 with no new capability row.
- [x] **LOCKSTEP** — Backend/API/roadmap/live/task/Knowledge and sole-facing mdBook sources carry the same current
  five-backend boundary; the public checker passes all 22 mutations across 25 documents and Knowledge Map
  generation reports 780 facts / 6,328 question keys. Final render, all doctrines, and the corrected canonical
  gate pass; commit, brief clearing, and clean proof remain in the leaf workflow.

Focused integration evidence 2026-08-01: project-data workflow routing passes from outside the repository CWD and
reaches the renamed final LuaJIT branch through its expected missing-command probe. Capability conformance remains
16 capabilities / 80 pass / 0 partial / 0 gap, and the generated-source contract retains ten families plus the
strict 105/105 Rust census. The complete Lua gate passes 177 TAP groups per ABI, focused callable 449 per ABI, CLI
66x2, corpus 105/105, all 17 storage owners, generated/trace cleanup, and both native-module builds. A current-
surface no-drift scan finds no stale four-backend or pending-five-backend claim outside intentionally historical
superseded fact evidence and the checker's own denial sentinels; the new driver remains executable.

Final no-drift correction evidence 2026-08-01: a whole current-surface scan caught three stale projections in
`lua/README.md`, mdBook project status, and the canonical mdBook helper catalog. The helper catalog was also absent
from the duplicate-independent public inventory. The same leaf corrects the prose, raises governance 24→25
documents, adds path-scoped denials for all three stale claims, reconciles current Knowledge cards, regenerates
the map, and re-proves the composed five-backend driver. The final scan returns no current pending-`.11.8.4`
claim outside the checker's literal denial sentinels or explicitly dated/superseded history.

Signoff evidence 2026-08-01: Knowledge Map generation/checking passes 780 facts / 6,328 question keys, the
sole-facing mdBook renders 79 files / 14,052 KiB, shell syntax and whitespace are clean, and all seven doctrines
pass against the staged governed slice. An earlier pre-correction canonical attempt reached the representative
relocated-process oracle after every preceding check passed, then the outer Codex sandbox denied its nested
`sandbox-exec` with status 71. After the final no-drift correction, the definitive authorized rerun proves the
25-document contract, relocated six-family driver, all five moved/outside-CWD runtime anchors, CLI 66x2, RAM 54%,
and complete Phase 0 at 1,031/1,031. Its optional callable branch passes
neutral+22, Perl 10, Rust 18, Dart 21, Julia 125+118+239, PUC Lua 449, and LuaJIT 449 before `local CI gate passed`.
Parents `.11.8` and `.11` are closed with lexical capture still outside v1. Only workflow landing as 125/300,
brief clearing, rendered-book cleanup, and exact clean proof remain before task-tree-first `.24.0`; no push.
  Commit: `FUTURE-PARITY-BACKLOG.11.8.4 - admit five-backend callable codeblocks`

### `FUTURE-PARITY-BACKLOG.11.8.0` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Activate task-tree-first from clean four-backend public-closeout
  commit `e232609b` (120/300), with zero-byte brief and no rendered-book, bytecode, or managed-run residue.
- [x] **KNOWLEDGE / DECISION / TOOLBOX RETRIEVAL** — Retrieve the exact callable/Lua Knowledge cards, ADRs
  `0031`/`0032`/`0041`, neutral contract/checker/fixture, `TOOLBOX.md` probes, and prior Lua parser/runtime/generated
  authorities before re-deriving any structural or causal fact.
- [x] **TYPED AUTHORITY MAP / PRESERVED SURFACE** — Identify exact parser, ActionIR/schema/copy/registry, scoped-
  binding, interpreter, descriptor/semantic, serialized/generated/emitted, and dual-ABI owners; prove current
  eager/control/harray/contextual/static precedence behavior that `.11.8.1-.4` must not regress.
- [x] **MISSING-MECHANISM RED PROOF** — Reproduce every neutral construction/invocation/contextual/generated case
  that Lua still lacks through LinkedSpec-owned typed probes and focused consumers, including portable diagnostics,
  spans/signatures, once-only arguments, dynamic stores, copy/restore, recursion, results/access, and both ABIs.
- [x] **DEPENDENCY-COMPLETE IMPLEMENTATION PLAN** — Freeze exact smallest-change boundaries, RED-to-green consumer
  ownership, reuse seams, diagnostic identities, native/reconstructed/generated/emitted route identity, and
  signoff gates for `.11.8.1-.4`; prohibit host closures, lexical capture, broad raw fallback, a second codec,
  a second executor, premature capability admission, or behavior code in this audit.
- [x] **DOCS / VERIFICATION / COMMIT / CLEAN HANDOFF** — Write durable causal facts, synchronize task/index/roadmap/
  live/memory and the sole-facing mdBook, pass focused Lua baselines plus governance/rendered-book/canonical gates,
  commit `.11.8.0`, clear the brief, prove exact cleanup and clean status, then activate `.11.8.1`; do not push.

Activation evidence 2026-08-01: public closeout `.11.7.2` lands at `e232609b` as commit 120/300 with its pre/post
activation-boundary hooks and all seven doctrines green. Git status is empty, `git_message_brief.txt` is zero
bytes, and rendered-book, Python-bytecode, and managed-run residue are absent. This leaf owns retrieval, typed
probes, exact current/missing mechanism classification, RED consumer design, and dependency-complete planning
only. It authorizes no parser/compiler/runtime/descriptor/generated/fixture/capability-row/MCP behavior, root
README edit, lexical capture, push, or task pivot.

Retrieval and typed-authority evidence 2026-08-01: ADRs `0031`, `0032`, and `0041`; the neutral callable and
signature contracts/checkers; the four admitted backend consumers and Knowledge facts; Lua contextual/copy/
descriptor/generated facts; and the relevant Toolbox probes were read before source inspection. Exact owners are
`action_parser.lua` and `action_ast.lua` for typed syntax/state; `action_contracts.lua` and
`action_ast.find_removed_aggregate_selector` for deferred traversal; `interpreter.lua`,
`runtime_scoped_binding.lua`, and `user_function_registry.lua` for copy/call/frame authority;
`semantic_static_projection.lua` for binding/call shapes; `compiled_spec.lua`, `spec_ast.lua`, and
`source_emitter.lua` for one effective-`SpecFile` serialized/generated route; `tools/run_lua_local.sh` plus native
builders/wrappers for PUC Lua/LuaJIT proof. The function-oriented `spec_ast.CallableSignature` requires a non-null
rest name and is not the fixed-literal owner; the existing `ActionCallableSignature` is the correct nullable seam.

RED/preserved-surface evidence 2026-08-01: the unchanged neutral checker passes 7 brace/literal, 11 call, 9
invalid-literal, 7 invalid-call, 4 invalid-declaration, and 8 contextual cases. The complete Lua baseline passes
177/177 on PUC Lua and LuaJIT, CLI 66x2, corpus 105/105, and repository storage. An identical dual-ABI typed probe
shows fixed/zero/rest `{|` forms and all malformed forms collapsing to `block_value` plus `raw_perl`; construction
fails as `unsupported runtime ActionIR kind 'raw_perl'`. `cb(value: "x")` is raw positional data while
`cb(value = "x")` remains positional `assign_scalar`; `collector("p")["items"]` lacks an evaluated-call access
receiver, although a call already feeds an ordinary fluent chain. A transported contextual block executes only
through its declared zero-argument slot; the same escaped binding cannot dispatch generally. Bound scalar and
unbound calls share the unsupported-helper fallback, while a registered function still wins over a same-named
bound block. Existing eager block mutation, contextual execution, static precedence, harray classification, and
both ABIs remain unchanged.

Frozen implementation/consumer boundary 2026-08-01: one
`lua/test/callable_codeblock_literal_contract_test.lua` consumes the unchanged neutral JSON and grows across
`.11.8.1-.3` to own the same ten construction/context/invocation/failure/native/reconstructed/generated/emitted
roles as every admitted backend. `.1` adds only inert typed construction/state and complete-gate dual-ABI
registration; `.2` adds narrow colon keyword/value-access data plus post-static bound dispatch through existing
scoped bindings and one interpreter; `.3` proves normalized/generated/byte-fresh emitted identity and updates the
exact Lua storage-owner inventory; `.4` replaces the four-backend driver with one five-backend/dual-ABI recurring
composition, then and only then updates capability/exclusion/public status. No closure, captured environment,
second codec/executor, broad raw fallback, premature capability/MCP movement, root README edit, or behavior code
is permitted in this audit leaf. Durable fact `lua-callable-codeblock-typed-audit` owns this plan.

Signoff evidence 2026-08-01: focused proof passes the neutral 7 literals / 11 calls / 9 invalid literals / 7
invalid calls / 4 invalid declarations / 8 contextual forms and all 20 governance mutations. The complete Lua
gate remains green at 177/177 on each of PUC Lua and LuaJIT, primary CLI 66x2, corpus 105/105, and 16-owner
repository-storage proof. Knowledge Map generation/check passes 776 facts / 6,291 question keys; the sole-facing
mdBook renders 79 files / 14,008 KiB before exact removal; memory, task metadata, README stability, whitespace,
and all seven doctrines pass. The definitive authorized canonical wrapper passes semantic/MCP admissions,
containment, moved-root anchors, CLI 66x2, RAM 61%, and Phase 0 1,031/1,031 in 653 seconds, then runs the exact
callable matrix at neutral+20, Perl 10, Rust 18, Dart 21, and Julia 125+118+239 before reporting
`local CI gate passed`. No production, fixture, capability-row, MCP, root README, or push change occurs. Only the
workflow landing, brief clearing, clean proof, and task-tree-first `.11.8.1` activation remain.

### `FUTURE-PARITY-BACKLOG.11.4.1` Acceptance Checklist

- [x] **CLEAN OWNERSHIP / RETRIEVAL FIRST** — Activate `.11.4`/`.11.4.1` from clean semantic-parent commit
  `6cadd6a0`, zero-byte brief, and absent generated residue; retrieve ADRs `0031`/`0032`, the neutral callable-
  codeblock/signature contracts and checkers, Perl reference facts, current Rust parser/compiler/runtime/emitter
  owners, routing/storage constraints, and the intervening completed selector-retirement dependency.
- [x] **TOOL-LED BASELINE / EXACT GAP MAP** — Use the neutral checker, governed fixture, Rust typed-state tests,
  and LinkedSpec probes before editing behavior; classify exact parser, typed AST, signature, compiled-state,
  serialization, descriptor, and emitted-source gaps without guessing from `.spec` text.
- [x] **TYPED CONSTRUCTION / NO EXECUTION** — Recognize exact `{|params| body }` / `{|| body }` before harray and
  eager-block classification; preserve source/spans, fixed/rest signature, typed body, and stable diagnostics as
  inert Rust data; construct no host closure and execute no literal body or variable call in this leaf.
- [x] **STATE / DESCRIPTOR / EMISSION ROUND-TRIP** — Preserve the same typed record through compilation,
  serialization/descriptors, generated-plan state, and emitted Rust source with exact neutral fixture identity;
  keep contextual final-block execution, dynamic invocation, and generic equivalence owned by `.11.4.2-.3`.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Pass focused contract and Rust checks plus warranted broad
  gates, synchronize task/roadmap/live/Knowledge Map/mdBook/current Rust documentation, remove exact generated
  output, commit with `.11.4.1`, clear the brief, prove clean, and only then activate `.11.4.2`; do not push before
  cadence 300.

Baseline 2026-07-30: neutral `linkedspec-callable-codeblock-v1` passes 7 literals / 11 calls / 9 invalid literals /
7 invalid calls / 4 invalid declarations / 8 contextual forms. Rust `expr.rs` has only harray and eager
`BlockValue` brace branches, a fixed/variadic-function-oriented `CallableSignature`, and no deferred codeblock
`Expr`/`RuntimeValue`; therefore compiled JSON, public typed state, and emitted Rust have nothing to preserve.
`source_emitter.rs` already embeds the one serialized `CompiledSpec`, so the correct repair is to add typed state
at the parser/compiler boundary and prove the existing emitter carries it byte-for-byte—not add another codec.
Current `Engine::eval_expr` has no bound-value call dispatch, which is correct and remains untouched until
`.11.4.2`. Existing `BlockValue` callback execution and helper/method name gates remain `.11.4.3` closeout scope.

### `FUTURE-PARITY-BACKLOG.11.4.2` Acceptance Checklist

- [x] **CLEAN ACTIVATION / KNOWLEDGE FIRST** — Activate only from clean `.11.4.1` commit `91958022`, with the
  brief at zero bytes and generated residue absent; retrieve ADR `0031`, the neutral callable-codeblock contract,
  Perl dynamic-invocation fact, Rust inert-state fact, current function/call/runtime owners, and Toolbox commands
  before any runtime edit.
- [x] **TOOL-LED RUST BASELINE / GAP MAP** — Re-run the neutral checker and construction regression, then inspect
  exact call parsing, resolution precedence, runtime store/snapshot/return control, recursive-copy, diagnostics,
  generated execution, and semantic projection seams. Record the smallest signoff-level implementation boundary
  before changing behavior.
- [x] **DYNAMIC INVOCATION / CALLER CONTEXT** — Resolve a governed bound codeblock only after controls, helpers,
  and registered user functions; evaluate positional arguments once left-to-right; recursively copy fixed/rest
  values into temporary bindings; restore same-name bindings on success/failure; expose other reads/mutations to
  caller stores; keep `return` invocation-local and allow ordinary result chaining/discard.
- [x] **PORTABLE FAILURES / RECURSION** — Preserve unknown-call behavior and emit exact typed arity, keyword,
  bound-non-codeblock, and direct/mutual active-recursion diagnostics with stable callable/cycle identity and no
  host fallback. Construction remains closure-free and inert.
- [x] **NATIVE / SERIALIZED / GENERATED PROOF** — Consume all eleven valid call cases, seven invalid call cases,
  and the exact neutral fixture through native, compiled-JSON reconstruction, generated-plan, and emitted-source
  authority without broadening generic contextual final blocks.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Pass focused and complete Rust gates plus warranted canonical
  proof; synchronize task/roadmap/live/Knowledge Map/mdBook/Rust docs; remove exact generated output; commit with
  `.11.4.2`, clear the brief, prove clean, and only then activate `.11.4.3`; do not push before cadence 300.

Baseline 2026-07-30: the unchanged neutral checker passes 7 literals / 11 calls / 9 invalid literals / 7 invalid
calls / 4 invalid declarations / 8 contextual forms, and the Rust inert-construction regression remains 7/7.
The exact fixture reaches typed codeblock construction but its `collector(...)["items"].length()` result chain is
rejected because access paths can start only from a named binding; with that one expression diagnostically
simplified, every bound call follows the generic unknown-helper fallback and returns `undef`. `Arg::Keyword`
survives as dormant typed state, but its retired `name=expr` parser was deliberately purged; the adopted callable
surface therefore needs narrow `name: expr` recognition without reviving that legacy helper syntax. Static helper
match arms and the registered-function branch already precede the generic unknown arm, while
`RuntimeContext::enter_scoped_scalar_binding`, recursive owned-value cloning, `eval_block_value`, and the shared
serialized/generated `Engine` path provide the required caller-context, copy/restore, local-return, and one-runtime
seams. The smallest signoff boundary is consequently: add typed postfix value access and colon-keyword parsing;
dispatch bound codeblocks only from the generic unknown arm; add an active callable-name stack plus exact portable
failure fields; and prove the unchanged fixture/invalid cases through native, reconstructed, generated-plan, and
emitted execution. Deferred-body dependency scans already remain inert from `.11.4.1`, so semantic projection and
generic final-block normalization do not change here.

Implementation proof 2026-07-30: typed `value_access` lets a call result enter ordinary key/index access before a
receiver chain, and narrow `name: expr` call arguments restore the adopted keyword boundary without reviving
retired `name=expr`. The Rust engine now resolves a bound codeblock only from the existing generic-unknown arm,
after controls, helpers, and registered functions. It evaluates arguments once left-to-right, deep-copies fixed
and fresh-rest values into cleanup-safe temporary bindings, preserves dynamic nonparameter stores, returns the
local final expression/`return(...)`, and restores parameters plus active-call identity on success or failure.
Exact typed arity, keyword, non-codeblock, unknown-body-helper, and ordered direct/mutual recursion diagnostics
share the structured runtime envelope. The 13-test focused suite consumes the neutral fixture, all eleven valid
calls, all seven invalid calls, native state, compiled-JSON reconstruction, generated plans, and independently
compiled emitted Rust; it also proves standalone discard, static precedence, recursive copy, failure cleanup, and
colon-keyword user-function policy. Variadic 7/7, semantic query 5/5, and the existing generic unknown-helper unit
regression pass. Generic attached/parenthesized final-block normalization remains untouched for `.11.4.3`.

### `FUTURE-PARITY-BACKLOG.11.4.3` Acceptance Checklist

- [x] **CLEAN ACTIVATION / DURABLE HANDOFF** — Activate only from clean `.11.4.2` commit `ebb8301c`, with the
  brief at zero bytes and generated residue absent; update the task-tree frontier and bounded resume pointer before
  touching parser/runtime behavior.
- [x] **KNOWLEDGE / TOOL-LED BASELINE** — Retrieve ADRs `0031`/`0032`, neutral callable contracts/fixture, Perl
  generic-final-block facts, Rust construction/invocation facts, and current trailing-block parser/runtime owners;
  use the neutral checker and LinkedSpec probes to classify exact helper, user-function, receiver, and `with`
  behavior before editing.
- [x] **SIGNATURE-GOVERNED EQUIVALENCE** — Normalize `call(args) { block }` and `call(args, { block })` to the
  same typed final codeblock argument only where callable metadata accepts it; preserve ordinary eager blocks,
  harrays, retained immediate `with`, static-name precedence, and explicit codeblock-variable calls.
- [x] **NATIVE / GENERATED / ORACLE CLOSURE** — Prove every governed contextual form and rejection through native,
  compiled-JSON reconstruction, generated-plan, independently compiled emitted Rust, and neutral oracle identity;
  add no host closure, captured environment, backend dialect, or duplicated evaluator.
- [x] **NO-DRIFT REGRESSION** — Preserve all `.11.4.1-.2` literals, spans, dynamic caller stores, copy/restore,
  results/chaining/discard, failures/recursion, variadic functions, semantic projection, and generic unknown-helper
  behavior while completing the Rust contract surface.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Pass focused and complete Rust gates plus warranted canonical
  proof; synchronize task/roadmap/live/Knowledge Map/mdBook/Rust docs; remove exact generated output; commit with
  `.11.4.3`, clear the brief, prove clean, close parent `.11.4`, and only then activate Dart `.11.5.1`; do not push
  before cadence 300.

Activation 2026-07-30: clean dynamic-invocation commit `ebb8301c` closes `.11.4.2` at 106/300 with an empty brief,
empty status, and no mdBook/emitted-source residue. `.11.4.3` owns only generic signature-governed final-block
equivalence and Rust closeout.

Baseline 2026-07-30: ADRs `0031`/`0032`, the six callable-codeblock/normalization fact cards, the exact neutral
contract, Perl callable registry/runtime/lowering owners, and the Rust parser/compiler/runtime/emitter owners are
retrieved. The neutral checker passes 7 literals / 11 calls / 9 invalid literals / 7 invalid calls / 4 invalid
declarations / 8 contextual forms; the unchanged Rust callable suite passes 13/13. Tool-led inspection establishes
the exact gap: Rust still name-gates attached blocks to helper `with` and four receiver methods, stores immediate
callbacks as eager `BlockValue`, exposes no final `parameter_kinds`, cannot consume the staged typed-function AST,
and its `with`/tree runtime accepts only eager blocks. The correct repair is one core callable-contract registry,
generic structural candidates with source provenance, compiler normalization using builtin or typed-user metadata,
one typed `codeblock_argument`, and the existing dynamic codeblock executor—not parser allowlists, another evaluator,
or harray promotion. Invalid typed declarations must preserve the four neutral diagnostic codes, and typed final
values must reject non-codeblocks as `final_argument_not_codeblock` before function execution.

Implementation proof 2026-07-30: `linkedspec-core::callable_contract` is the single registry/normalization owner.
The compiler parse mode records attached and direct parenthesized candidates with exact character-coordinate
provenance, then complete builtin/user metadata admits only a declared final codeblock; the established public
`CodeBlock::parse` mode retains eager blocks and legacy diagnostics. Typed declarations flow from the staged
`user_function_definition.spec` AST through exact `parameter_kinds`, compiled state, descriptor v3, semantic
projection, generated plans, and emitted source. Helper `with`, receiver `with`, tree callbacks, and typed user
functions all enter the existing dynamic codeblock executor; explicit callable values retain authored signatures,
and non-codeblock final values fail as `final_argument_not_codeblock`.

Focused proof passes neutral 7 literals / 11 calls / 9 invalid literals / 7 invalid calls / 4 invalid declarations /
8 contextual forms, Perl oracle 10/10, Rust callable 18/18, descriptor integration 4/4, punctuation-light 5/5,
core 195/195, and production-library clippy under the repository warning policy. The first complete Rust run
exposed staged `action_block` envelope loss; normalization now merges semantic statements while preserving opaque
staged metadata. The second run exposed malformed bare-control diagnostic drift; the dedicated control parser now
retains the established statement-separator boundary without weakening valid controls. The final complete Rust
gate exits zero across every package, corpus oracle in 148.33 seconds, generated-source classifier in 192.45
seconds, 197 main integrations, semantic/MCP recurrences, emitted-source suites, build, the 195-package/17-owner
storage proof, and CLI 66/66 in both option environments. Knowledge Map generation/checking passes at 761 facts /
6,175 question keys, the mdBook renders 79 files / 13,880 KiB before exact output cleanup, and all seven doctrines
pass. Canonical CI exits zero with Phase 0 1,031/1,031 in 639 seconds and `[ci] local CI gate passed`. This closes
`.11.4.3` and Rust parent `.11.4`; Dart `.11.5.1` remains next only after commit, brief-clear, and clean proof.

### `FUTURE-PARITY-BACKLOG.11.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Current braces distinguish harrays and eager block expressions, but no portable
  initializer creates a callable codeblock variable and `cb()` cannot resolve a stored block value.
- [x] **ROOT CAUSE (WHY + WHERE)** — Current codeblocks are immediate/contextual AST payloads with name-gated
  runtime consumers; no literal signature, deferred body value, dynamic variable-call resolver, or capture policy
  crosses the spec grammar, ActionIR, descriptors, native runtimes, and generated source.
- [x] **FIX** — ADR 0031 adopts exact `{|params| body }`, `{|| body }`, optional final `...rest`, dynamic caller
  context, temporary copied parameter bindings, block-local return, static-name precedence, and retained `with`.
- [x] **ADDRESSED (verified)** — Neutral contract, four admitted backend rollouts, and Lua routing/no-drift have
  explicit dependency-ordered leaves before code; lexical capture is explicitly excluded from version 1.
- [x] **NO REGRESSION** — Planning only: no parser, runtime, descriptor, fixture, or generated behavior changed;
  current harray, eager block, `with`, traversal, function, CLI, corpus, and Lua numeric proofs remain authoritative.
- [x] **LOCKSTEP** — ADR/index, task tree/index, roadmaps, README/book, Knowledge Map, changes/notes/live, and memory
  agree that `.11.2` is the first executable-contract leaf.

### `FUTURE-PARITY-BACKLOG.11.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — ADR 0031 had no executable neutral artifact to prevent parser/runtime interpretation
  drift before five backend implementations.
- [x] **ROOT CAUSE (WHY + WHERE)** — Prose alone could not enforce exact brace classification, typed AST fields,
  signature reuse, dynamic invocation/restoration, diagnostic codes, or deterministic fixture bytes/results.
- [x] **FIX** — Add strict `linkedspec-callable-codeblock-v1` JSON plus an independent parser/classifier,
  invocation model, diagnostic validator, and fixture renderer/evaluator in canonical CI.
- [x] **ADDRESSED (verified)** — Seven literals, eleven calls, nine malformed literals, seven invalid calls, four
  contextual forms, three brace kinds, and the future source/result fixture pass the checker.
- [x] **NO REGRESSION** — This leaf admits no backend behavior; the capability remains future-owned by Perl parser
  leaf `.11.3.1`, and current harray/eager-block/named-immediate behavior remains authoritative.
- [x] **LOCKSTEP** — Contract README, capability owner, task/index, roadmaps, README/book, KM, live docs, and memory
  identify the adopted contract and active Perl implementation frontier.

### `FUTURE-PARITY-BACKLOG.11.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Direct ActionIR parsing classified `{|...|...}` as an immediate block and generated
  lowering had no inert typed value representation.
- [x] **ROOT CAUSE (WHY + WHERE)** — `AST/Parser.pm::_parse_brace_expr` only chose harray versus `block_value`, and
  `MethodLowering.pm` had no pure-data `codeblock_literal` branch. A first Data::Dumper prototype also proved unsafe:
  later rewrite/interpolation changed embedded source strings, so generated source could not preserve exact data.
- [x] **FIX** — Parse exact `{|` first into the neutral eight-field AST/signature record; preserve containing spans;
  emit canonical UTF-8 JSON as ASCII hex and decode to plain data at runtime; retain typed invalid-literal nodes.
- [x] **ADDRESSED (verified)** — The unchanged neutral contract drives 7 valid literals, 9 malformed forms, brace
  classification, inert construction, assignment/copy, and user-function argument/result checks (126 assertions).
- [x] **NO REGRESSION** — Existing ActionIR parser plus the new focused suite pass 26 top-level tests; harray and
  eager block cases retain their kinds; no variable-call invocation or dynamic execution is admitted in this leaf.
- [x] **LOCKSTEP** — Capability owner, task/index, roadmaps, README/book, KM, changes/notes/live, and memory route
  the remaining Perl invocation semantics to active `.11.3.2`.

### `FUTURE-PARITY-BACKLOG.11.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `LinkedSpec::call_spec_handler_subst(...)` lowers a bound `cb(args)` call to
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:cb`, and the unchanged neutral fixture cannot execute on Perl.
- [x] **ROOT CAUSE (WHY + WHERE)** — `ActionIR::MethodLowering` resolves governed helpers and registered user
  functions only; `RuleIR::EmitContext` does not expose scalar working bindings to a typed codeblock executor or
  traverse deferred codeblock bodies when collecting caller slots.
- [x] **FIX** — Add typed record invocation, deterministic ActionIR-body execution over explicit caller binding
  references, static-name precedence, copied temporary fixed/rest bindings, restoration, result/drop/chaining,
  and typed arity/not-callable/recursion failures without storing a Perl coderef in the record.
- [x] **ADDRESSED (verified)** — The contract-sourced Perl fixture and focused invalid-call probes reproduce the
  neutral results, visible nonparameter mutation, parameter restoration, and diagnostic payloads.
- [x] **NO REGRESSION** — Existing callable-literal, ActionIR, user-function, CLI, and Phase-0 gates reach their
  true stops with no new failure set; generated source remains independently executable.
- [x] **LOCKSTEP** — Task/index, capability state, roadmaps, README/book, Knowledge Map, changes/notes/live, and
  bounded memory state describe Perl invocation as current while final-block generalization remains `.11.3.3`.

### `FUTURE-PARITY-BACKLOG.11.3.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Toolbox lowering proves attached `with("x") { ... }` works while the structurally
  equivalent parenthesized `with("x", { ... })` still lowers to an unsupported-helper sentinel.
- [x] **ROOT CAUSE (WHY + WHERE)** — The AST payloads are already equivalent, but no callable schema declares a
  final contextual codeblock parameter: user functions carry only names/arity/rest,
  helpers carry lowering-local arity tables, and receiver parsing hard-codes four method names.
- [x] **FIX** — Split declaration design `.1` from Perl normalization/execution `.2`; do not infer callback intent
  from a body call, ordinary final parameter, parser callee name, or brace contents.
- [x] **ADDRESSED (verified)** — Durable task/KM records enumerate the missing call-parameter kind and route the
  required director choice to `.1`; `.1` corrects the audit's unnecessary nested-signature proposal.
- [x] **NO REGRESSION** — Read-only ActionIR/descriptor/lowering probes only; parser, registry, runtime, generated
  source, neutral fixtures, and current `with`/tree traversal behavior are unchanged.
- [x] **LOCKSTEP** — Task/index, capability owner, roadmaps, README/book, architecture/live docs, Knowledge Map,
  and bounded memory point to active declaration leaf `.11.3.3.1`.

### `FUTURE-PARITY-BACKLOG.11.3.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `.0` proves arity alone cannot authorize attached braces and the accepted design had
  no source/schema declaration for the final contextual-codeblock value kind.
- [x] **ROOT CAUSE (WHY + WHERE)** — The first proposal incorrectly duplicated a callback argument signature in
  the receiving slot even though explicit `{|params| ...}` values already own and enforce that signature.
- [x] **FIX** — ADR 0032 selects final-only `name: codeblock`, no nested argument list, zero-positional contextual
  blocks with dynamic caller context, and callable-registry metadata shared by helpers/functions/receiver methods.
- [x] **ADDRESSED (verified)** — The neutral checker locks the exact declaration, four invalid declarations, and
  eight equivalent/helper/user-function/receiver contextual cases while retaining literal-owned signatures.
- [x] **NO REGRESSION** — This is contract/docs/checker only: existing function grammar, descriptors, ActionIR,
  runtime, generated source, current `with`/traversal behavior, and all prior literal/call fixtures are unchanged.
- [x] **LOCKSTEP** — ADR/index, contract/README, task/index, roadmaps, README/book, KM, changes/notes/live, and
  memory agree that Perl behavior `.11.3.3.2` consumes the adopted declaration next.

### `FUTURE-PARITY-BACKLOG.11.3.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Toolbox lowering accepts attached `with(args) { ... }` but rejects its parenthesized
  equivalent; typed user-function syntax is not parsed, and receiver attached blocks are parser name-gated.
- [x] **ROOT CAUSE (WHY + WHERE)** — Function grammar/registry/descriptors lack final parameter kinds, ActionIR
  leaves contextual braces as `block_value`, and helper/receiver lowering dispatches directly on method names.
- [x] **FIX** — Preserve final `name: codeblock` metadata, normalize attached/parenthesized blocks to one typed
  `codeblock_argument`, move helper/receiver acceptance behind callable contracts, and execute contextual user
  callbacks as zero-positional dynamic-context codeblocks through generated source.
- [x] **ADDRESSED (verified)** — Focused helper/user-function/receiver probes cover equivalent AST, values,
  descriptors, explicit literals, harray rejection, typed declaration failures, and standalone generated execution.
- [x] **NO REGRESSION** — Existing fixed/variadic functions, `with`, hash/array traversal, literal invocation,
  ActionIR, CLI, and Phase-0 gates reach their true stops without raw Perl or name-gated parser residue.
- [x] **LOCKSTEP** — Task/index, capability state, roadmaps, README/book, Knowledge Map, changes/notes/live, and
  memory describe generic Perl final-block behavior as current before closeout `.11.3.4`.

### `FUTURE-PARITY-BACKLOG.11.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Audit the committed Perl callable-codeblock surface for raw host code/coderef
  leakage, harray promotion, parser method-name gates, untyped final-argument failures, and stale public caveats.
- [x] **ROOT CAUSE (WHY + WHERE)** — Classify any residue by grammar, callable metadata, normalization, runtime,
  generated-source, diagnostic, or documentation owner before changing behavior.
- [x] **FIX** — Repair only verified Perl closeout residue; do not expand the accepted neutral contract or begin
  Rust parity, Lua work, or spec-facing aggregate-wrapper retirement inside this leaf.
- [x] **ADDRESSED (verified)** — Neutral/focused/generated/CLI/Phase-0 proof and source scans cover declarations,
  contextual/explicit forms, harray rejection, closure-free records, generic parsing, and standalone generation.
- [x] **NO REGRESSION** — Canonical capability 60/0/0, CLI 61x2, Phase 0 `1..1030`, doctrines, Knowledge Map,
  whitespace, and mdBook reach their true stops on the final committed Perl state.
- [x] **LOCKSTEP** — Close `.11.3` as current Perl behavior, retain overall capability future ownership, and route
  the director-prioritized removal of `.spec` `array(name)` / `hash(name)` semantics to `.12.1` before Rust/Lua.

- ID: `FUTURE-PARITY-BACKLOG.12`
  Status: `done`
  Goal: Retire transitional compatibility surfaces after uniform expression and duck-typed binding semantics settle.
  Children: `.12.0`, `.12.1`
  Acceptance: Backward compatibility is temporary migration scaffolding, never a permanent language constraint;
    every retained compatibility surface has an explicit removal condition and owner. Bare variables carry one of
    scalar/array/harray/codeblock, calls and controls are expressions, runtime value type drives dispatch, and
    `array(name)`/`hash(name)` may not survive as alternate namespaces, type assertions, or mutation authority.
  Verification: **PASS 2026-07-12.** `.12.1.0-.10` retain their complete behavior/retirement/public proof;
    `.12.1.11` reconciles the later uniform-binding mutation-result rule across Perl behavior, all five focused
    backend suites, public/book/KM guidance, and a recurring 48-file surface checker.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.11 - align array end mutation results`

- ID: `FUTURE-PARITY-BACKLOG.12.0`
  Status: `done`
  Goal: Capture the director's uniform-expression, duck-typing, and compatibility-retirement doctrine.
  Acceptance: Record the doctrine and current wrapper/storage contradiction without changing active runtime
    behavior or pivoting mid-slice; keep Lua string closeout `.4.3.2.2.5.1` as the execution frontier.
  Verification: **PASS 2026-07-12.** Existing records already own expression-valued assignment, inline if/switch,
    user/helper calls, value-drop, and generic final-codeblock design. Audit confirms the remaining contradiction is
    spec-facing `array(name)`/`hash(name)` selecting alternate read and mutation semantics beside one duck-typed
    binding. This planning slice creates the missing retirement owner; no runtime behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.12.0 - capture compatibility retirement doctrine`

- ID: `FUTURE-PARITY-BACKLOG.12.1`
  Status: `done`
  Goal: Split and execute uniform binding plus spec-facing aggregate-selector retirement.
  Children: `.12.1.0`, `.12.1.1`, `.12.1.2`, `.12.1.3`, `.12.1.4`, `.12.1.5`, `.12.1.6`, `.12.1.7`,
    `.12.1.8`, `.12.1.9`, `.12.1.10`, `.12.1.11`
  Acceptance: Inventory every public and implementation compatibility surface and classify temporary migration
    versus current language; define one variable binding with runtime scalar/array/harray/codeblock identity; make
    pure and mutable helper/method dispatch consume that value without wrapper-selected storage;
    `array(IDENTIFIER)` and `hash(IDENTIFIER)` may not survive as namespace selectors, typed reads, mutation targets,
    or mutation authority; separately classify whether non-selector constructor calls remain or literals replace
    them; migrate wrapper-based targets such as `split(array(parts),...)` to unambiguous bare-target semantics;
    specify expression-valued if/switch/calls and silent value drop as universal invariants; assign
    Perl/Rust/Dart/Julia/Lua, corpus, mdBook, diagnostics, hard-retirement, and final no-drift leaves before behavior
    code.
  Verification: **PASS 2026-07-12.** `.12.1.0-.10` retain their recorded behavior/source/mdBook/capability proof.
    `.12.1.11` corrects current statement-only array-end prose and the corresponding Perl value-position ActionIR
    exclusion; five backends now lock independent saved updates and compatible continuation under one recurring
    public/KM checker.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.11 - align array end mutation results`

- ID: `FUTURE-PARITY-BACKLOG.12.1.0`
  Status: `done`
  Goal: Inventory and split exact spec-facing aggregate-selector retirement before behavior code.
  Acceptance: Count exact selector-shaped source uses separately from constructors; prove current selector-free
    read/mutation gaps with LinkedSpec tools; locate every backend recognition/dispatch seam; split neutral contract,
    five backend enablement leaves, source migration, hard retirement, and final no-drift before implementation.
  Verification: **PASS 2026-07-12; count corrected by `.12.1.7.1`.** There are 600 exact `array(IDENTIFIER)` /
    `hash(IDENTIFIER)` occurrences in 82 tracked `.spec` files, including 210 across 15 shipped specs. The original
    boundary-less scan reported 651/227 because it included 51/17 `flat_array(name)` suffixes. Immediate parents include 172
    `copy`, 158 `push`, 72 `set`, 50 `is_nonempty`, 13 `split`, and smaller mutation/read/helper families; 17 forms
    are receiver expressions. Toolbox lowering proves bare read/method forms already exist on Perl, while
    `push(items, value)` still selects child-rule semantics and `split(parts, source, delimiter)` is unsupported.
    Perl owns selector recognition through `ValueExpr`/`MethodLowering`/`EmitContext`; Rust through
    `resolve_array_target`/`resolve_hash_target` and constructor branches; Dart/Julia through their target-name
    helpers; Lua through `target_descriptor` and constructor branches. No behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.0 - split aggregate selector retirement`

- ID: `FUTURE-PARITY-BACKLOG.12.1.1`
  Status: `done`
  Goal: Adopt a neutral one-binding and aggregate-selector retirement contract before backend changes.
  Acceptance: Fix bare identifier read/write/mutation dispatch by runtime value, absent-binding auto-creation,
    static-rule precedence for ambiguous `push(name, value)`, three-argument mutable `split`, expression-valued
    mutation, and exact `set(target, value)` post-assignment target return. Reject exact selector-shaped calls as
    the future contract while separately classifying zero/multi/quoted/computed array/hash constructors. Provide a
    checked migration table and executable future fixtures without changing current backend behavior.
  Verification: **PASS 2026-07-12.** `linkedspec-uniform-binding-v1` plus its independent checker validate 11
    migration mappings, seven execution cases, six exact invalid selectors, eight retained constructor/literal
    classifications, and deterministic future fixture source/results. The contract fixes one observable typed
    binding, storage neutrality, post-assignment `set` results, updated mutation results, absent-target creation,
    wrong-kind diagnostics, static-rule push precedence, pure/mutable split arities, exact selector rejection, and
    `[value]` for the ambiguous one-element constructor. Canonical CI passes capability 60/0/0, both 61-case CLI
    environments, and Phase 0 `1..1030` in 875 seconds; no backend behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.1 - adopt uniform binding contract`

- ID: `FUTURE-PARITY-BACKLOG.12.1.2`
  Status: `done`
  Goal: Make the Perl reference execute the neutral selector-free binding and mutation contract.
  Acceptance: Bare reads, receivers, set, push/append, hash mutation, split, in-place collection helpers, copy,
    controls, calls, and chaining operate on one observable typed binding; static child-rule push keeps precedence;
    internal host storage layout remains unobservable. Old selectors stay temporary only until source migration.
  Verification: **PASS 2026-07-12.** `LinkedSpec::BindingRuntime` provides copy-on-write typed mutations, absent-
    target creation, and stable mismatch fields. Live and standalone generated fixtures cover set chaining, saved
    mutation results, push/append, mutable/pure split, hash/index updates, collection transforms, static-rule
    precedence, wrong-kind failure, and temporary wrapper compatibility. Focused ActionIR/contract proof passes 38
    tests; the neutral checker passes 11/7/6/8 cases; canonical CI passes doctrines, capability 60/0/0, both 61-case
    CLI environments, and Phase 0 `1..1030` in 821 seconds. No tracked selector source migrates in this leaf.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.2 - enable Perl uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.3`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Rust.
  Acceptance: Native/generated execution and diagnostics match the neutral fixture and Perl without exposing
    `resolve_array_target`/`resolve_hash_target` storage selection as public semantics.
  Verification: **PASS 2026-07-12.** `RuntimeContext` now owns narrow kind-checked bare array/harray mutation
    seams; native and generated-plan execution pass the future fixture, all seven neutral cases, saved independent
    updates, append, array-end result chaining/collection rebinding, static-rule precedence, and stable wrong-kind
    fields in 9 integration tests. Baseline proof found `undef` push results, missing collection rebinding, and
    silent wrong-kind retagging. The first full oracle then localized a statement-only append bypass; routing it
    through the same typed value seam restores the existing `["a", "b"]` fixture. The broad suite then exposed
    exactly one superseded statement-only array-end result lock, now migrated to the adopted updated-value contract.
    Complete Rust gates pass 137 unit, 105/105 oracle, 105/105 generated classification, 197 integration, focused
    suites/build, and CLI 61x2; strict Clippy has 16 pre-existing findings outside changed hunks. Canonical CI passes
    doctrines/contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0 `1..1030` in 786 seconds. Knowledge Map,
    mdBook, continuity, and whitespace checks pass. No selector source migrates; Dart `.12.1.4` activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.3 - enable Rust uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.4`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Dart.
  Acceptance: Bare `ActionVariableExpr` reads and all mutable/pure helper paths observe the same typed binding;
    native/generated/current corpus proof matches the neutral contract.
  Verification: **PASS 2026-07-12.** Dart bare reads now resolve the current typed value across private migration
    stores; kind-checked array/harray seams own push/append, mutable split, hash/index, array-end, and collection
    mutations with independent updated results, absent creation, stable mismatch fields, `set`/mutation chaining,
    and static-rule precedence. Native/generated proof passes the future fixture, seven neutral cases, and two
    extension cases in 9 tests. The first full gate exposed exactly two old boundaries: value-position array-end
    mutation expected `null`, and mixed wrapper/bare hash mutation hid the binding from bare merge. Both locks now
    assert the adopted value/alias semantics. Format/analyze, all 199 tests, generated packages, 105/105 corpus, and
    CLI 61x2 pass. Canonical CI passes doctrines/contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0
    `1..1030` in 892 seconds; docs/KM/governance/whitespace pass. No selector source migrates; Julia `.12.1.5`
    activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.4 - enable Dart uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.5`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Julia.
  Acceptance: `_read_runtime_store` remains the public read model while target/mutation paths converge on the same
    binding; native/generated/current corpus proof matches the neutral contract.
  Verification: **PASS 2026-07-12.** Julia now routes bare assignment, set, push/append, mutable split, hash/index,
    array-end, set-key, and standalone collection mutation through one typed binding seam while retaining private
    migration maps. Missing targets create only the required array/harray kind; incompatible values fail with stable
    `binding_kind_mismatch` fields; mutations return independent updated values and continue through receiver chains;
    static rules retain ambiguous-push precedence. The permanent 9-subtest native/generated suite passes 27/27
    assertions. Its unchanged baseline passed 11 and failed eight exact assertions covering array-end results,
    mutable split, collection rebinding, and wrong-kind rejection. The first full package runs exposed two stale
    locks: value-position `push_back` expected no update, and bare-first hash merge expected only the overlay after
    wrapper/bare mutations. Both now assert the adopted one-binding behavior. The complete Julia gate passes 1,311
    package assertions, CLI 61x2, and 105/105 corpus fixtures. Canonical CI passes doctrines and
    contracts, capability 60/0/0, Perl CLI 61x2, and Phase 0 `1..1030` in 865 seconds. No selector source migrates;
    Lua `.12.1.6` activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.5 - enable Julia uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.6`
  Status: `done`
  Goal: Implement the unchanged selector-free binding and mutation contract on Lua before resuming feature parity.
  Acceptance: Existing `lookup_binding` semantics extend through every admitted mutation/helper path; dual-ABI
    focused proof passes without keeping selector forms as a Lua compatibility requirement.
  Verification: **PASS 2026-07-12.** Lua now uses `lookup_binding` plus kind-checked array mutation seams for bare
    push/append, three-argument mutable split, array-end methods, and standalone collection rebinding; hash-index
    mutation rejects incompatible existing values, missing targets create only the required kind, and every mutation
    returns a copied updated binding. Static compiled rules retain ambiguous-push precedence. Minimal pure array
    dispatch supplies the unchanged fixture's `count`/`sorted`/`first`/`trim_each`/`filter_nonempty` continuations.
    Baseline dual-ABI proof passed two and failed seven of the nine exact cases; after repair all nine pass. The first
    full gate exposed one stale lock that required `array(target)` for statement split; it now asserts bare
    three-argument mutation while two-argument split remains pure. PUC Lua and LuaJIT each pass 85/85, the 105-case
    manifest remains exact, the CLI remains explicitly scaffolded, and backend status is
    `runtime-uniform-bindings`. The immediately prior canonical gate passes doctrines/contracts, capability 60/0/0,
    Perl CLI 61x2, and Phase 0 `1..1030` in 865 seconds. No selector source migrates in this leaf; `.12.1.7.1`
    activates.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.6 - enable Lua uniform bindings`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7`
  Status: `done`
  Goal: Migrate every tracked `.spec` and embedded source away from exact aggregate selectors.
  Children: `.12.1.7.1`, `.12.1.7.2`, `.12.1.7.3`
  Dependencies: `.12.1.2`, `.12.1.3`, `.12.1.4`, `.12.1.5`, `.12.1.6`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7.1`
  Status: `done`
  Goal: Migrate the 15 affected shipped specs and prove their reference/generated behavior.
  Verification: **PASS 2026-07-12.** Boundary-correct baseline is 210 exact occurrences, not the earlier
    boundary-less 227; all 15 shipped specs now scan at zero. Perl pure collection reads were harmonized with the
    scalar-held typed mutation binding after the migrated Lispish CLI exposed legacy `@name` reads. Focused
    live/generated uniform-binding proof passes; all 21 shipped descriptors compile at zero blocker/compatibility
    rules; default/POSIX CLI pass 61/61; mdBook/KM/doctrines pass; canonical Phase 0 passes `1..1031` in 573 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.7.1 - migrate shipped aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7.2`
  Status: `done`
  Goal: Migrate neutral/oracle/corpus `.spec` fixtures and regenerate only derived expectations.
  Verification: **PASS 2026-07-12.** The boundary-correct 390 occurrences in 67 files are removed: five in two
    capability fixtures, 366 in 62 Rust-oracle inputs, and 19 in three legacy corpus inputs. All tracked `*.spec`
    files now scan at zero exact selectors, capability mirrors are byte-identical, and the three intended
    one-element constructions use `[undef]`. Full migration exposed and repaired rule-local `I` initializer scope
    and empty implicit rule accumulators on Rust/Dart/Julia, plus Rust fluent action push and explicit-binding versus
    descriptor-alias behavior; permanent uniform-binding tests lock those seams. Perl live probes preserve the
    EBNF, recursive, and traversal values; Rust passes 105/105 interpreted and 105/105 generated corpus cases plus
    its full package gate; Dart and Julia pass their complete gates and 105/105 corpora; PUC Lua and LuaJIT each
    pass 85/85 while validating the exact 105-case manifest. Canonical doctrines/contracts, capability 60/0/0,
    CLI 61x2, and Phase 0 `1..1031` pass in 574 seconds; mdBook/KM/whitespace pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.7.2 - migrate file-backed selector fixtures`

- ID: `FUTURE-PARITY-BACKLOG.12.1.7.3`
  Status: `done`
  Goal: Migrate embedded test/tool/backend source strings and verify zero executable selector-shaped sources.
  Verification: **PASS 2026-07-12.** All 1,356 positive exact occurrences are removed from 25 embedded
    test/tool/backend source owners. The recurring executable-source checker reports zero positives and 25
    mechanically classified implementation/recognition occurrences reserved for hard retirement. Complete
    Rust, Dart, Julia, and dual-ABI Lua gates pass; focused Perl contracts and generated user-function probes
    pass; the regenerated oracle corpus contains all 105 fixtures. Standalone Phase 0 passes `1..1031` in 920
    seconds, and the canonical local gate passes capability 60/0/0, CLI 61x2, and Phase 0 `1..1031` in 918
    seconds. Knowledge Map, doctrines, task metadata, mdBook, and whitespace checks pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.7.3 - migrate embedded selector sources`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8`
  Status: `done`
  Goal: Hard-retire exact aggregate-selector syntax with one portable diagnostic.
  Children: `.12.1.8.1`, `.12.1.8.2`, `.12.1.8.3`, `.12.1.8.4`, `.12.1.8.5`, `.12.1.8.6`
  Dependencies: `.12.1.7`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.1`
  Status: `done`
  Goal: Reject exact selector-shaped calls at the Perl `.spec` boundary and remove public compatibility dispatch.
  Verification: **PASS 2026-07-12.** The canonical Perl ActionIR boundary now rejects every exact one-bare-
    identifier `array(...)` / `hash(...)` node with `aggregate_selector_removed surface=<...>
    identifier=<...> replacement=<...>` before lowering, including nested/dead rule code and unused user-function
    bodies. Live compilation reports compiler-pipeline failure; generated-source emission preserves the same
    detail. Zero/multi/quoted/computed constructors and direct literals remain valid. Focused Perl proof passes 41
    tests; the whitespace-aware executable-source scanner reports zero positives/19 classified recognizers; the
    regenerated 105-case oracle and Rust corpus replay pass; standalone and canonical Phase 0 each pass `1..1031`
    in 934 seconds, with canonical capability 60/0/0 and CLI 61x2.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.1 - hard-reject Perl aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.2`
  Status: `done`
  Goal: Reject exact selector-shaped calls at the Rust `.spec` boundary and remove public compatibility dispatch.
  Verification: **PASS 2026-07-12.** Recursive typed-AST detection plus whole-`CompiledSpec` validation rejects
    all six neutral exact-selector cases through ordinary/traced compilation, native execution, generated-source
    emission, v1 decode, and legacy generated adapters. Coverage includes dead/nested blocks, unused functions,
    and deferred edge-fluent arguments. The 15-case focused suite preserves all eight constructor/literal classes;
    the executable-source scanner reports zero positives/13 classified rejection sites. Full core/runtime/CLI,
    105 interpreted corpus, final 105 generated classification in 329.32 seconds, integration 197/197, canonical doctrines/capability/
    CLI/Phase 0, Knowledge Map, mdBook, formatting, and whitespace gates pass. Selector-specific Rust runtime
    read/target/assignment/receiver dispatch is gone, and wrapper-era test/corpus terminology is retired.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.2 - hard-reject Rust aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.3`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Dart and close the complete Dart no-drift gate.
  Children: `.12.1.8.3.1`, `.12.1.8.3.2`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.3.1`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Dart and delete selector-specific recognition/dispatch.
  Verification: Focused implementation proof passes 15/15; strict analysis is clean; the executable-source scan
    is zero-positive/14 classified. The complete Dart test leg reaches 203 passes with only two pre-existing
    `spec_spec_*` aggregate failures: shipped variadic `blkVFN` structural regex is not recognized by the Dart
    bridge that handles fixed `blkFN`. No selector test or changed runtime path fails. `.12.1.8.3.2` owns that
    independently bounded full-gate prerequisite before the parent closes.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.3.1 - hard-reject Dart aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.3.2`
  Status: `done`
  Goal: Restore Dart `spec.spec` variadic function-definition structural matching and close the complete gate.
  Acceptance: Extend the existing bounded shipped-pattern bridge from fixed `blkFN` to the exact variadic
    `blkVFN` family, preserving capture/named-capture shape; add focused matching proof; pass all four
    `spec_spec_*` smokes, the full Dart test/CLI/105-corpus gate, and selector retirement no-drift without adding a
    general recursive-regex claim.
  Verification: **PASS 2026-07-12.** The real four-case runner reproduced `blkVFN` as the sole invalid group.
    The bounded bridge now recognizes fixed `blkFN` and exact variadic `blkVFN`, uses separate fixed/variadic
    prefixes, returns name/fixed/rest/body captures, materializes empty optional-parameter slots so indices do not
    shift for zero/rest-only definitions, and exposes the matching named block. Focused matching plus
    selector tests pass 22; all four `spec_spec_*` cases pass. The authoritative Dart gate passes format, strict
    analysis, all 205 package tests, CLI 61x2, and all 105 corpus cases. Neutral/source checks remain green.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.3.2 - close Dart selector retirement`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.4`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Julia and delete selector-specific recognition/dispatch.
  Acceptance: Reject all six neutral exact-selector cases with the portable diagnostic at the complete compiled
    ActionIR boundary, including dead control bodies, deferred fluent calls, and unused user-function bodies;
    repeat validation at generated emission and plan/execution boundaries so caller-constructed compiled payloads
    cannot bypass it; retain all eight neutral constructor/literal classes; delete selector-only runtime reads,
    targets, receiver recognition, and split/transform dispatch; pass focused, source-scan, package, CLI, corpus,
    canonical local-CI, docs/Knowledge Map/doctrine, mdBook, cleanup, and whitespace gates.
  Verification: **PASS 2026-07-12.** All six neutral exact cases move from compiling to portable compile-time
    rejection. Recursive typed-ActionIR inspection covers every expression family; whole-compiled-state validation
    also parses valid deferred function bodies and fluent calls while preserving unrelated parse-failure timing.
    Native compile, generated emission, and generated plan/execution boundaries validate independently, including
    caller-constructed payloads. Selector-specific runtime reads, set/push/receiver targets, split/transform
    wrappers, and target recognizers are deleted. Focused proof passes 59/59 with all eight retained classes;
    executable scan is zero-positive/15 classified. The authoritative Julia gate passes 1,339 package assertions,
    CLI 61x2, and all 105 corpus fixtures; canonical local CI passes Phase 0 `1..1031` in 601 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.4 - hard-reject Julia aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.5`
  Status: `done`
  Goal: Reject exact selector-shaped calls on Lua and delete selector-specific recognition/dispatch.
  Acceptance: Reject all six neutral exact-selector cases with portable code/surface/identifier/replacement fields
    across complete compiled state, including dead control bodies, valid deferred fluent calls, and any registered
    unused user-function bodies; revalidate runtime-engine input so caller-mutated compiled tables cannot bypass
    rejection; retain all eight neutral constructor/literal classes; delete selector-only read, set/push/receiver,
    split/transform, and target-descriptor recognition; pass PUC Lua and LuaJIT focused/full suites, executable
    source scan, exact 105-manifest validation, docs/Knowledge Map/doctrine, mdBook, cleanup, and whitespace gates.
  Verification: **PASS 2026-07-12.** All six neutral exact cases move from compiling to portable typed rejection.
    Recursive ActionIR inspection covers every expression family; whole-compiled-state validation also parses valid
    deferred user-function bodies and fluent calls without changing unrelated parse failures. Compile and runtime-
    engine boundaries both validate, including caller-mutated compiled payloads. Selector-only array/hash reads,
    set/push/receiver targets, mutable split/transform wrappers, and descriptor branches are deleted. Both PUC Lua
    and LuaJIT pass 88/88 with all eight retained classes; the exact 105-manifest and CLI-scaffold checks pass;
    executable scan is zero-positive/19 classified.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.5 - hard-reject Lua aggregate selectors`

- ID: `FUTURE-PARITY-BACKLOG.12.1.8.6`
  Status: `done`
  Goal: Prove the portable diagnostic and zero selector recognizers/sources across all variants.
  Acceptance: Add a deterministic cross-variant checker that requires all five contract-driven six-case rejection
    suites, portable diagnostic/boundary anchors, and zero known selector runtime-dispatch symbols/patterns; compose
    the existing executable-source scan; register the checker in canonical local CI; remove stale compatibility
    comments; pass the checker, all five focused rejection suites (including dual Lua ABIs), docs/Knowledge Map/
    doctrine, mdBook, cleanup, and whitespace gates before closing hard-retirement parent `.12.1.8`.
  Verification: **PASS 2026-07-12.** One deterministic canonical checker requires all five backends to consume the
    same six invalid-selector cases and portable diagnostic fields, verifies each compiled-state admission
    boundary, forbids the known selector-only runtime symbols/patterns, and composes the executable-source scan.
    The audit found and removed one stale Perl compatibility comment. The checker passes with five backends, six
    rejected cases, eight retained constructor/literal classes, zero runtime compatibility paths, and zero
    executable positives/19 classified rejection occurrences. Focused proof passes Perl 11, Rust 15/15, Dart
    15/15, Julia 59/59, and Lua 88/88 on both PUC Lua and LuaJIT; the canonical local gate passes capability
    60/0/0, CLI 61x2, and Phase 0 `1..1031` in 616 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.8.6 - enforce selector retirement no-drift`

- ID: `FUTURE-PARITY-BACKLOG.12.1.9`
  Status: `done`
  Goal: Close uniform-binding docs, mdBook examples, Knowledge Map, capability, and complete no-drift gates.
  Acceptance: Public docs teach bare typed bindings and literals/retained constructors only; no compatibility
    caveat, current-facing example, positive executable test/source, diagnostic ambiguity, or backend admits
    selector semantics. Add a deterministic public-surface checker that distinguishes current normative guidance
    from durable historical/rejection evidence; retire the capability future exclusion; run the uniform-binding,
    aggregate-retirement, capability, docs/Knowledge Map/doctrine, mdBook, cleanup, whitespace, and canonical local
    gates; then close `.12.1` and activate the next roadmap-aligned PNT frontier.
  Verification: **PASS 2026-07-12.** The canonical public checker scans 47 root/capability/mdBook files, classifies
    31 exact mentions only as removed/rejected/migrated history, reports zero current examples, requires current
    bare set/push/copy guidance, forbids stale future/remaining-backend status, composes the five-backend runtime/
    source checker, and proves the capability future exclusion is absent. Capability remains 60/0/0; mdBook,
    Knowledge Map, doctrine, memory/task, cleanup, and whitespace gates pass. Canonical CI passes CLI 61x2 and
    Phase 0 `1..1031` in 626 seconds. Existing active Lua scalar-numeric leaf `.4.3.3.1.4` resumes.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.9 - admit selector-free public surface`

- ID: `FUTURE-PARITY-BACKLOG.12.1.10`
  Status: `done`
  Goal: Remove selector syntax from backend READMEs and close the public-checker coverage omission.
  Dependencies: `.12.1.9`
  Acceptance: Inventory every tracked backend README for exact selector-shaped guidance; classify history versus
    current examples; migrate current Rust/Dart/Julia/Lua authoring prose and snippets to bare typed bindings;
    expand the canonical public checker to discover backend READMEs from the repository rather than relying on a
    root/capability/mdBook-only list; require the expanded file count and zero current examples; preserve legitimate
    removed/rejected history; pass the composed selector/runtime/capability gate, relevant backend docs/tests,
    mdBook/Knowledge Map/doctrines/cleanup/whitespace, then re-close `.12.1`/`.12` and resume Lua numeric `.4.3.3.2`.
  Verification: **PASS 2026-07-12.** A commit-baseline scan found 14 exact positive forms across Rust, Dart,
    Julia, and Lua READMEs. Their runtime descriptions and examples now use bare typed set/copy/push/set-key/split
    forms. The canonical checker discovers all immediate component READMEs, asserts 56 public files and 31
    classified removed/history references, requires bare-binding anchors in all four backend documents, and
    reports zero current examples. It composes five-backend six-invalid/eight-retained/zero-runtime and zero-
    executable-positive/19-classified proof plus capability 60/0/0; docs/KM/doctrines/mdBook pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.10 - close backend README selector drift`

- ID: `FUTURE-PARITY-BACKLOG.12.1.11`
  Status: `done`
  Goal: Reconcile array-end mutation result documentation with the adopted uniform-binding contract.
  Dependencies: `.12.1.10`, `LUA-BACKEND-PARITY.4.3.4.0`
  Acceptance: Inventory every current public/KM/backend statement that says `push_back`/`push_front`/`pop_back`/
    `pop_front` are statement-only or return null/no value; preserve dated historical slice evidence while marking
    it superseded; document that all four methods mutate and yield an independent updated typed target, pop still
    discards the removed element, and continuations consume the updated array; correct Perl ActionIR's discovered
    value-position rejection so a named typed binding can return the update and feed a compatible array
    continuation while preserving exact push/pop arity and rejecting mutation on temporary receivers; replace the
    superseded statement-only regression lock; add a recurring checker against future normative drift; pass
    uniform-binding/five-backend/public/mdBook/KM/doctrine/cleanup/whitespace gates; re-close `.12.1`/`.12` and
    return to `LUA-BACKEND-PARITY.4.3.4.1`.
  Verification: **PASS 2026-07-12.** The 48-file checker requires 12 current updated-result anchors and classifies
    nine historical cards. Perl toolbox probes reproduced raw value-position calls and the generated
    `SpecEntry::push_back` failure; the runtime primitive already returned copied updates, while the fluent value
    lowerer excluded the four end methods. Named binding mutations now lower as assignment-valued arrays, preserve
    exact arity, feed compatible continuations, and diagnose temporary receivers. Focused proof passes Perl 12,
    Rust 16, Dart 16, Julia 61, and Lua 91/91 on PUC Lua and LuaJIT; Phase 0 passes `1..1031`, and
    selector/public/capability checks remain clean. Canonical local CI passes CLI 61x2 and Phase 0 `1..1031` in
    631 seconds; mdBook, Knowledge Map, doctrines, memory/task metadata, cleanup, and whitespace pass.
  Commit: `FUTURE-PARITY-BACKLOG.12.1.11 - align array end mutation results`

- ID: `FUTURE-PARITY-BACKLOG.13`
  Status: `done`
  Goal: Restore the codegen-inspector toolbox to the current thin-facade owner architecture.
  Children: `.13.1`
  Dependencies: `.12.1`
  Acceptance: `tools/inspect_spec_codegen.pl` invokes explicit owner APIs rather than facade AUTOLOAD/plugin
    fallback, all four documented snippet forms execute, and a recurring smoke test prevents owner extraction from
    silently breaking the inspector again.
  Verification: Completion is composed by `.13.1`; focused owner-routing, five-form execution, documentation,
    storage, doctrine, and rendered-book proof passes, while the exact staged canonical boundary is required before
    commit/push.
  Commit: `FUTURE-PARITY-BACKLOG.13.1 - restore codegen inspector`

- ID: `FUTURE-PARITY-BACKLOG.13.1`
  Status: `done`
  Goal: Rewire and regression-lock `tools/inspect_spec_codegen.pl` after the Phase 1A facade extraction.
  Dependencies: `.12.1`
  Activation: `2026-08-29` from exact clean pushed commit
    `82d0b85f25448489a1459b1eb563bcbf87d663c1`; five independent documented-form probes reproduce the two
    plugin-AUTOLOAD failures, and source/history locate the explicit current owners without requiring a public
    facade expansion.
  Verification tier: `canonical`
  Focused checks: Perl syntax; `t/inspect_spec_codegen.t`, `t/actionir_ast_parser.t`, and
    `t/trace_actionir_pipeline.t`; tool project-data storage; memory/task/Knowledge/document/README routing;
    doctrines; mdBook render/cleanup; diff hygiene.
  Canonical trigger: `tools/run_ci_local.sh` changes to admit the recurring smoke, so ADR `0073` requires one exact
    staged canonical receipt before commit and push.
  Verification: **FOCUSED PASS 2026-08-29.** The recurring smoke, ActionIR AST parser, trace pipeline, tool storage,
    memory/task/Knowledge/document/README routing, nine doctrines, mdBook render/cleanup, and diff hygiene pass.
    The first exact staged canonical attempt correctly catches the new mdBook page as public aggregate-selector
    inventory file 61 rather than the stale expected 60; the checker and all three canonical Knowledge owners now
    lock 61 files / 25 classified historical references / zero current examples. The composed executable scan also
    exposes stale 19-count prose: audit of commit `c8501d3a` proves `.10.7.2.2` intentionally added the 20th
    classified Lua semantic-compilation rejection fixture, so current evidence is zero positive / 20 classified.
    ADR `0073` designates the changed canonical-CI topology as an infrastructure boundary; commit/push require a
    corrected exact staged canonical receipt for this complete candidate.
  Commit: `FUTURE-PARITY-BACKLOG.13.1 - restore codegen inspector`

<!-- Source ranges and their immutable migration digest are recorded in docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl. -->
