# FUTURE-PARITY-BACKLOG: Future parity backlog and backend rollout

## Metadata

- Tree ID: `FUTURE-PARITY-BACKLOG`
- Status: `active`
- Roadmap lane: `Overall roadmap - future parity backlog`
- Created: `2026-07-09`
- Last updated: `2026-08-27` (progressive `.14.6`, staged neutral `.14.7.0-.2`, complete Perl `.14.7.3.0-.4`,
  Rust `.14.7.4.0-.4`, and Dart `.14.7.5.0-.4` are closed; Julia dormant `.14.7.6.0` is committed and
  marker/provenance `.14.7.6.1` is focused-signoff-complete with `.2` next after its atomic commit)
- Owner: repo-local workflow

## Goal

Own the deferred backlog surfaced after the language-reference closeout, with the first lane
driving new backend implementations toward full parity with the Perl reference backend and the
Rust backend. Backend rollout order is fixed by director directive and ADR `0021`: Dart first,
then Julia, then Lua. The backlog also parks later architecture arcs that need design ownership
before implementation.

## Non-Goals

- Do not implement backend code in the tracking slice `.0`.
- Do not weaken the universal `.spec` contract or create per-backend dialects.
- Do not treat Perl plugin machinery as part of the backend-neutral contract.
- Do not normalize documented behavior caveats until their own leaves are activated.
- Do not infer parenthesis-free condition headers such as `if condition { ... }` or `while condition { ... }`
  from punctuation-light zero-argument markers; that separate idea remains deferred pending an ambiguity audit.

## Acceptance Criteria

- The twenty-five backlog directions are represented as owned task-tree lanes, including compatibility retirement,
  repair of the codegen-inspector toolbox regression discovered while proving selector-source migration, and the
  director's structural linked-rule plus progressive/staged parser-composition authoring model and rule-level bare
  lifecycle-block shorthand.
- The backend lane schedules Dart, Julia, and Lua in that order, all with full parity goals.
- Every backend is primarily a native in-memory library for its host language. Variant CLIs are secondary thin
  adapters and may not become the only complete product surface or own CLI-only semantics.
- Each backend implementation track owns a distinct LinkedSpec executable name for that variant; every such
  executable exposes the identical command structure, options/meanings, positional arguments, outputs/errors, and
  exit semantics. No variant may substitute a backend-specific product interface.
- The spec-derived parser/stimuli roundtrip idea is recorded as future design work, with `.spec` kept as the
  sole semantic source of truth for both parser construction and generated stimuli.
- The director's AND/OR edge-default correction is recorded as future design work: AND rules should default bare
  entries to blind-call sequence semantics, while OR rules should default bare entries to action-edge regex
  dispatch semantics.
- Deep semantic introspection is recorded as a first-class, backend-neutral in-memory API direction with a thin
  MCP projection; backend IR must not leak into or fragment the public semantic model.
- The trailing-codeblock correction records `codeblock` alongside scalar, array, and harray as a language value
  kind; for callables whose signature accepts a final codeblock, `call(args) { ... }` and
  `call(args, { ... })` must be equivalent on helper, user-function, and receiver-method surfaces in every variant.
- The director's variadic-callable direction is recorded: callable purpose governs exact versus unbounded arity,
  and user-defined functions gain one explicit grammar-owned definition-time variadic signature after audit.
- The director's parser-authoring doctrine is recorded: simple zero/one/two-regex rules form a linked structural
  graph; recursion belongs in rule connections rather than recursive regexes; cursor-relative extraction enables
  in-parse parser composition; and returned AST fields may be parsed again by later spec-driven stages.
- Universal `.spec` authoring is governed as terse, readable, and highly expressive: remove redundant ceremony,
  preserve semantic signal and typed diagnostics, and prefer orthogonal reusable composition over format-specific
  or host-language escape hatches.
- Portable deep-write creation and explicit receiver mutation have a separate parity-gated owner: reads never
  vivify, arrays remain dense, wrong-kind values are never coerced, and `!` is restricted to a true mutating twin.
- The central task-tree index points at the current frontier.
- ADR, roadmap, mdBook, Knowledge Map, and live docs no longer contradict the backend order or
  Lua adoption decision.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `FUTURE-PARITY-BACKLOG`
  Status: `active`
  Goal: Own the future parity backlog after the closed language-reference/terse-format trees.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`, `.10`, `.11`, `.12`, `.13`, `.14`,
  `.15`, `.16`, `.17`, `.18`, `.19`, `.20`, `.21`, `.22`, `.23`, `.24`

### Semantic Part Index

The stable root is a bounded current index. Every task ID remains unchanged and lives in exactly one semantic
part; superseded frontier narrative plus legacy global verification, commit, and changelog logs live in the
immutable history part. The strict machine index is `docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl`.

| Stable task prefix | Owning part |
| --- | --- |
| `.0-.8` | [`FUTURE-PARITY-BACKLOG.00-08.md`](FUTURE-PARITY-BACKLOG.00-08.md) |
| `.9` | [`FUTURE-PARITY-BACKLOG.09.md`](FUTURE-PARITY-BACKLOG.09.md) |
| `.10`, `.10.0-.6` | [`FUTURE-PARITY-BACKLOG.10.0-6.md`](FUTURE-PARITY-BACKLOG.10.0-6.md) |
| `.10.7-.10` | [`FUTURE-PARITY-BACKLOG.10.7-10.md`](FUTURE-PARITY-BACKLOG.10.7-10.md) |
| `.11-.13` | [`FUTURE-PARITY-BACKLOG.11-13.md`](FUTURE-PARITY-BACKLOG.11-13.md) |
| `.14`, `.14.0-.14.6.4` | [`FUTURE-PARITY-BACKLOG.14.md`](FUTURE-PARITY-BACKLOG.14.md) |
| `.14.6.5-.14.8` | [`FUTURE-PARITY-BACKLOG.14.6.5-8.md`](FUTURE-PARITY-BACKLOG.14.6.5-8.md) |
| `.15-.24` | [`FUTURE-PARITY-BACKLOG.15-24.md`](FUTURE-PARITY-BACKLOG.15-24.md) |
| Legacy global history | [`FUTURE-PARITY-BACKLOG.history.md`](FUTURE-PARITY-BACKLOG.history.md) |

Retrieve the bounded owner of any stable ID from any working directory:

```bash
perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.3.1.1
```

Update same-commit mutable-part counts and digests after an owning task edit:

```bash
perl tools/update_task_tree_index.pl --tree FUTURE-PARITY-BACKLOG
```

## Current Frontier

**Authoritative frontier (2026-08-27):** progressive `.14.6` is closed at six-runtime private behavior,
recurrence, and public no-drift. Staged audit/diagnostic/neutral `.14.7.0-.2` are committed; Perl `.3`, Rust `.4`,
and Dart `.5` each privately implement and admit the complete marker/provenance, caller-frozen authority,
breadth-first recursion, fresh native/reconstructed/generated/emitted carriers, and exact ordinary/canonical
consumer. Neutral governance is now 92 mutations with those three backends complete. Julia `.14.7.6.0-.1` freeze
and implement its still-dormant private declaration boundary: only exact scalar assignment-form `parse_job(...)`
lowers to an exclusive inert marker; native regex capture offsets prove Unicode-scalar direct/ordered-derived
provenance; and all four logical routes agree on detached data. The consumer is 131 GREEN/one exact `.2` authority/
cache/policy RED and remains absent from ordinary/canonical discovery. Julia rollout, v1/v2 formats, public/outward
behavior, and the neutral 92-mutation count do not move. `.14.7.6.2` is next; shared Lua `.7`, recurrence `.8`,
public `.9`, recomposition `.10`, and combined program-wide `.14.8` retain their frozen owners.

**Historical frontier (2026-07-29):** Lua Unicode prerequisite `.10.7.1` and opaque source/outcome parent
`.10.7.2` are composition-closed. The root constructor owns strict copied UTF-8, portable SHA-256, exact private
coordinates, four ceilings, one retained compiled-or-failed authority, native/fallback diagnostic, entry, and
generated-v2 plan without caller path or target execution on either ABI. Behavior-free static-authority audit
`.10.7.3.0` froze the exact five targets and authority/source/normalization boundary. Private graph `.10.7.3.1`
and all four remaining targets in implementation child `.10.7.3.2.1.1` are complete. Process-oracle correction
`PROJECT-DATA-SSD-ROOTING.6` and final canonical closeout `.10.7.3.2.1.2` close `.10.7.3.2`; no-change committed-
owner recomposition `.10.7.3.3` passes every complete gate and closes `.10.7.3`. Behavior-free calls/staging/
generated authority audit `.10.7.4.0` now freezes exact 6/6 -> 18/16 -> 22/25 ownership and all typed/staged/
generated/source/privacy authorities without changing behavior. Typed core `.10.7.4.1` implements exact private
18/16/10, staged/generated `.10.7.4.2` completes exact private 22/25/10, and no-change `.10.7.4.3` recomposes all
six committed suites at focused 920 per ABI under complete gates. Parent `.10.7.4` is composition-closed;
behavior-free immutable-query authority audit `.10.7.5.0` now freezes one fresh detached authority, exact public
vocabulary, all 19 complete static hashes, 26 malformed raw boundaries, explicit dual-ABI JSON/numeric policy,
source projection, traversal/pages/budgets/costs, and `.1-.4` order without behavior change. Private immutable
non-traversal `.10.7.5.1` now matches nine exact hashes with protected recursive values and one detached
materialization at focused 1,080 per ABI without a public query name. Private traversal/pages/budgets/costs
`.10.7.5.2` now completes all 19 static hashes at query 283/focused 1,204 per ABI with no public query name.
Raw-neutral/public completion `.10.7.5.3` now exposes both paths at all 19 hashes and 26 malformed boundaries at
query 571/focused 1,492 per ABI. No-change committed-owner recomposition `.10.7.5.4` passes from clean public
commit `65cb13da` and composition-closes parent `.10.7.5`. Behavior-free runtime-observation authority audit
`.10.7.6.0` is fully verified from clean closeout commit `abe75fe4`; it freezes accepted match-end and normally
returned result seams, no-sink/callback policy, every dual-ABI route, detached static-only derivation, and exact
twentieth digest. Typed direct capture `.10.7.6.1` is fully verified at focused 1,614 per ABI and complete
cross-backend gates. Immutable observed-index derivation `.10.7.6.2` is fully verified at focused 1,884 per ABI
and complete gates. Generated/emitted propagation `.10.7.6.3` is fully verified from clean `ca6d635e`; public/
fresh-emitted direct/traced and isolated dual-ABI proof passes new 80/focused 1,964 per ABI plus complete Lua and
cross-backend signoff. No-change composition `.10.7.6.4` passes unchanged ten-owner focused 1,964 per ABI from
clean `04ab4fec` plus complete lockstep proof and composition-closes parent `.10.7.6`. Exact ordered dual-ABI
admission `.10.7.7` is complete from clean planning commit `e5a547ac`: one unchanged twelve-role source passes
408 assertions on each ABI and all eleven semantic owners pass 2,372 per ABI. Parent `.10.7` is closed.
Semantic governance is now 6/20/105 at rollout 7/9 and admission 6/6. Recurring composition `.10.8` is complete:
one repository-routed driver composes the six admitted consumers, three 5x2 primary no-drift cases, and three
support ledgers without a seventh semantic model or new CLI surface. Director-approved behavior-free MCP
architecture leaf `.10.9.0` is complete from clean `75c9ac5`: ADR `0054` freezes one exact contract, five native
implementations, six runtime admissions, and routing-only deferral of any aggregator. Canonical CI passes through
Phase 0 1,031/1,031. Exact contract parent `.10.9.1` is split before artifacts; behavior-free official-protocol
audit and decision `.10.9.1.0` is complete from clean architecture commit `9a8761ea`. Machine-readable contract
artifacts `.10.9.1.1` are complete from clean policy commit `b0492488`: one digest-pinned manifest, closed schema,
four semantic payloads, 35 canonical frames, ten raw cases, ten lifecycle cases, and a deterministic materializer
freeze the exact backend-neutral bytes without a server. Independent validator/mutations `.10.9.1.2` are complete
from clean `20741bbd`: one separate self-contained validator classifies 28 accepted and seven rejected frames,
executes ten lifecycle cases, and rejects 68 named mutations across 14 categories without importing the
materializer or adding a server. Director-approved behavior-free `.14.0.1` is complete from clean `283dc841`:
ADR `0056` freezes one typed source-location/cursor algebra and splits exact neutral contract through six-runtime/
public no-drift under `.14.1-.8` without changing syntax or behavior. No-change MCP closeout `.10.9.1.3` is
complete from clean `64735109`: canonical CI requires tracked artifacts, runs materialization before independent
validation, and rejects omission/order drift. Parent `.10.9.1` is closed without a server or semantic/CLI behavior.
Perl implementation/admission `.10.9.2` is parent-closed from clean no-change commit `4473a812` at 1/5
implementations + 1/6 runtimes. Behavior-free Rust preflight `.10.9.3.0` and ADR `0058` freeze generated binding,
native registry/decoded dispatch, strict stdio, admission, and closeout seams. Rust `.10.9.3.1-.3` implement and
admit the exact server, advancing only Rust to 2/5 implementations + 2/6 runtimes with rollout pending and 39
mutations. No-change `.10.9.3.4` recomposes every committed neutral, Perl, and Rust owner from clean `13d9ce17`;
focused and canonical proof pass through Phase 0 1,031/1,031 and close parent `.10.9.3` without behavior or status
movement. Behavior-free Dart MCP audit `.10.9.4.0` is complete from clean Rust closeout `7f44d2a1`; ADR `0059`
freezes native/generated/security/wire/admission ownership and the `.1-.4` split without behavior or ledger
movement. Dart `.10.9.4.1-.3` implement and admit its generated binding, decoded server, strict stdio, and exact
consumer; no-change `.10.9.4.4` closes that parent. Julia `.10.9.5.0-.4` likewise plans, implements, admits, and
recomposes its committed owners, advancing the ledger to 4/5 implementations + 4/6 runtimes before closing.
Shared Lua `.10.9.6.0-.4` now provides one Lua-5.1-compatible generated/runtime/server/wire graph plus one
unchanged 202-assertion consumer independently admitted on PUC Lua and LuaJIT. Canonical signoff passes at 5/5
implementations + 6/6 runtimes, rollout pending, with 114 rejected mutations; the no-change committed-owner
closeout closes parent `.10.9.6`, and recurring composition `.10.9.7` is next. Typed source-location `.14.1`
remains pending.

## Decisions

- `2026-08-01`: Lua callable construction and invocation will compose existing authorities in dependency order.
  `ActionCallableSignature` owns nullable literal signatures; `runtime_scoped_binding.run_frame` owns copied and
  exception-safe parameter frames; the existing interpreter owns explicit and contextual bodies; and effective-
  `SpecFile` serialization/emission owns every reconstructed/generated route. Colon syntax is the sole keyword
  form; `name = value` remains a positional assignment. One focused dual-ABI consumer grows through `.11.8.1-.3`,
  and only `.11.8.4` may promote five-backend public/capability state. Closures, lexical capture, broad raw
  fallback, a second codec, and a second executor are excluded.
- `2026-07-29`: Perl native MCP uses one public in-process `LinkedSpec::MCPServer` over an already-created opaque
  index. A generated data-only binding consumes the exact neutral contract without runtime paths or a hand-copied
  second contract; private contract-runtime and wire modules own schema values and strict stdio. Production uses
  exact OS entropy and monotonic expiry with no weak fallback. Authorization is a bounded host-owned byte string;
  only its SHA-256 digest is retained and fixed 32-byte comparison is used without claiming formal Perl-level
  constant time. Registry/dispatch `.1`, wire/lifecycle `.2`, exact admission/ledger `.3`, and no-change closeout
  `.4` remain dependency-ordered.
- `2026-07-16`: `.5.1.2` installs the optional Perl diagnostic sink in invocation-local descriptor slots used by
  generated live handlers. Sink failures and `RuntimeExitNow` are marked by exact thrown-value identity so nested
  handler and top-parser eval wrappers rethrow them before ordinary parser-error normalization. Independently
  emitted entrypoint option propagation remains `.5.1.7`; the native repair does not widen that later claim.
- `2026-07-13`: `.16.7` admits punctuation-light aliases as a current four-census-backend capability and records
  Lua's typed/serialized/native dual-ABI proof alongside it. This is not a claim that the overall Lua backend or
  generated Lua source is complete. The recurring composed command deliberately runs every implemented syntax
  path; future Lua emission remains `.8.1-.8.4`. Current examples migrate selectively, while parenthesized twins
  remain valid documentation and exact shipped-source walkthroughs keep spelling the source they describe.
- `2026-07-13`: `.16.6` narrows Lua's parser-ahead identifier fallback instead of layering another exception over
  it. Only a terminal receiver segment without a trailing block may omit `()`; exact bare `next` is a call only in
  statement construction. Lua `.contains()` without a needle remains `0` like Rust/Dart/Julia and stays owned by
  `.5`; `.16.6` changes syntax only.
- `2026-07-13`: Lua `.16.6` cannot honestly claim generated-source execution because no Lua emitter exists yet.
  `LUA-BACKEND-PARITY.8.1-.8.4` already owns deterministic emission, execution, and admission. This syntax leaf
  therefore proves typed AST, serialized SpecFile/ActionIR state, and native behavior on PUC Lua/LuaJIT; later generated
  source must preserve that normalized state without moving emitter architecture into `.16`.
- `2026-07-13`: `.16.5` uses Julia's explicit statement and terminal-segment contexts rather than adding a new
  general call production. Bare `next` is a call only as a complete statement; value-position `next` remains a
  variable. A generic receiver identifier becomes a zero-argument call only when final. Julia's existing
  `.contains()` no-needle result remains `0`, matching `.contains()` and staying owned with Rust/Dart drift by `.5`.
- `2026-07-13`: `.16.4` uses Dart's explicit statement and terminal-segment contexts rather than adding a new
  general call production. Bare `next` is a call only as a complete statement; value-position `next` remains a
  variable. A generic receiver identifier becomes a zero-argument call only when final. Dart's existing
  `.contains()` no-needle result remains `0`, matching `.contains()` and staying owned with Rust's drift by `.5`.
- `2026-07-13`: `.16.3` keeps syntax convergence separate from pre-existing helper semantics. Rust bare and
  parenthesized terminal calls share one typed empty-argument node and therefore the same runtime outcome.
  Rust `.contains()` currently defaults the absent needle and returns `0`, unlike Perl's arity rejection; `.5`
  owns that helper normalization, while `.16.3` neither hides nor changes it.
- `2026-07-13`: `.16.2.0` corrects, rather than changes, the neutral receiver-arity example. Receiver-authored
  arity subtracts the implicit receiver slot from canonical function-form helper arity. `drop_front` therefore
  permits zero authored arguments; `contains` truthfully demonstrates one required authored argument. The
  punctuation-light syntax decision and every backend behavior remain unchanged.
- `2026-07-13`: ADR `0033` adopts a narrow punctuation-light exception to the general `callee(args)` grammar:
  bare `else`/`endif`/`default`/`endcase`/`endswitch`/`next` where their zero-argument statement calls are valid,
  plus a generic bare final ActionIR receiver segment. It explicitly excludes parenthesis-free condition headers,
  calls with arguments, intermediate generic bare receiver calls, general helper/user-function calls, and attached
  final-codeblock calls. Existing parenthesized spellings remain valid.
- `2026-07-09`: Director directive schedules future backend parity as Dart first, then Julia,
  then Lua, with the goal of full parity with Perl5 and Rust. ADR `0021` records the durable
  scope change and supersedes the earlier "Lua blocked pending decision" wording.
- `2026-07-09`: The tracking slice `.0` is documentation/task ownership only. No backend scaffold
  or runtime code is created until `.1.1` is selected and split.
- `2026-07-09`: `.1.1` selects an interpreter-first Dart parity strategy and delegates executable Dart
  work to `docs/tasks/DART-BACKEND-PARITY.md`. Generated Dart source is a later proof lane after
  interpreter/corpus parity, not the primary gate.
- `2026-07-09`: Director directive: each LinkedSpec backend variant should have a distinct CLI. Dart records
  this as `DART-BACKEND-PARITY.7.3` / `.7.4`; Julia and Lua planning leaves must include equivalent
  variant-specific CLI ownership when activated. The 2026-07-10 clarification preserves distinct executable names
  but requires their complete user-facing interfaces to be identical.
- `2026-07-09`: `DART-BACKEND-PARITY.7.5` closes the scoped interpreter-first Dart milestone. Future backend
  rollout returned to this backlog tree; `FUTURE-PARITY-BACKLOG.1.2` then split/scaffolded Julia planning.
  No Julia or Lua code changes were made in the Dart closeout.
- `2026-07-09`: `.1.2` creates `docs/tasks/JULIA-BACKEND-PARITY.md` and selects an interpreter-first Julia
  parity strategy. Generated Julia source is a later proof decision, not the primary gate. Executable Julia work
  starts with `JULIA-BACKEND-PARITY.1.1` toolchain/package-layout preflight.
- `2026-07-09`: Director brainstorm captured: a future closed-loop validation arc should explore deriving both
  a parser for `foo` and a stimuli generator for that parser solely from `foo.spec`, making `.spec` the sole source
  of truth. This is parked under `.8.1` and is not the current Julia rollout pivot.
- `2026-07-09`: Director correction captured: future `.spec` design should swap the earlier optional-marker idea.
  AND rules should default bare entries to blind-call sequence semantics, while OR/default rules should default
  bare entries to action-edge regex dispatch semantics. This is parked under `.9.1` and is not the current Julia
  rollout pivot.
- `2026-07-10`: Director clarification: the reason for multiple LinkedSpec backends is native in-memory use from
  Rust, Dart, Julia, Lua, and later host languages. ADR `0022` makes host-process parse/compile/execute APIs the
  primary backend completion gate. Distinct CLIs remain useful thin adapters and may not own exclusive semantics.
- `2026-07-10`: `JULIA-BACKEND-PARITY.7.2` defers generated Julia source to this tree's `.3` generated-source
  breadth lane. `.3` now explicitly owns separate Rust breadth and Dart/Julia emitter splits with scaffold/harness,
  family-plan, direct structural-family, and curated corpus proof prerequisites. Current Julia conformance remains
  the native in-memory interpreter's 99/99 gate.
- `2026-07-10`: Director clarification: distinct backend executable names must expose the exact same user-facing
  CLI API, including command structure, option names/meanings, positional arguments, outputs/errors, and exit
  semantics; every variant must have the same user-observable feature set and behavior. Julia `.7.3.0` proves the
  current surfaces drift and splits contract/routing, Julia repair, and honest no-drift work.
- `2026-07-10`: ADR `0023` ratifies exact user-observable capability/behavior and primary-CLI identity. Delegated
  `.1.5.0` closes through `JULIA-BACKEND-PARITY.7.3.1`; `.1.5.1`–`.1.5.4` own the current-backend CLI repairs,
  `.1.6` owns the full public capability census, and `.3` is mandatory for complete parity because Rust exports
  source emission publicly. Julia `.7.3.2` remains first to preserve the current task-tree sequence.
- `2026-07-10`: Julia `.7.3.2.0` splits primary CLI alignment after source audit found five mechanisms: compile/
  parser/staged trace coverage, exact arguments and source/input resolution, execution/canonical JSON, normalized
  errors/trace routing, and direct-command conformance. `.7.3.2.1` is active; no implementation changed.
- `2026-07-10`: Delegated Julia `.7.3.2.1` closes compile/parser/function-shell/staged trace propagation through
  the existing emitter and sinks. The 868-assertion package suite, CLI smokes, and 99/99 corpus gate pass;
  `.7.3.2.2` is active for exact arguments and source/input loading.
- `2026-07-10`: Delegated Julia `.7.3.2.2` replaces the rollout primary commands with exact ADR `0023` options,
  positional/subcommand rejection, deterministic named resolution, and exact source/input loading. `.7.3.2.3`
  now executes rule/function source through the native pipeline and emits recursively key-sorted direct JSON;
  `.7.3.2.4` locks stable phase-ordered failures plus the trace sink/reset/emoji matrix. `.7.3.2.5` now locks nine
  direct process families and `runtime-corpus-primary-cli`; 1,017 assertions and 99/99 pass. `.7.3.3` then closes
  the outer audit without declaring complete parity. Julia remains active/delegated to `.1.5`, `.1.6`, and `.3`.
- `2026-07-10`: Delegated Julia `.7.3.3` corrects a stale mdBook limitation sentence and proves current surfaces
  agree on the exact local milestone and remaining global obligations. PNT now advances to `.1.5.1`; Lua remains
  gated behind current-backend CLI/capability/generated-source convergence.
- `2026-07-10`: `.1.5.3.0` proves Dart's 0/61 primary-command gap is an adapter replacement, not a missing
  language pipeline. `bin/corpus_runner.dart` retains the corpus workflow. The primary command will reuse staged
  full-spec parsing, validation/compilation, direct-value execution, top-rule/global-mode controls, and rich native
  trace, while exact process/loading, results/failures, portable trace, and closeout remain separate leaves.
- `2026-07-10`: `.1.5.3.1` replaces the corpus primary with exact arguments/help/resolution/strict UTF-8 and stable
  phase bytes, reaching 29/61 in both option environments. A native probe exposed the staged extractor's no-`fn`
  no-match as an erroneous failure; no definitions now correctly returns an empty list. Source U+FEFF is preserved
  and rejected before Dart frontend trimming can erase it. `.2` owns the 11 direct results; `.3` owns 21 trace cases.
- `2026-07-10`: `.1.5.3.2` spends Dart's existing native engine controls and direct `value`, not the corpus
  `[value]` wrapper. Recursive key sorting plus compact UTF-8 JSON closes all 11 success results; quiet trace also
  passes without records, producing a 41/61 baseline whose 20 residuals are exclusively canonical trace.
- `2026-07-10`: `.1.5.3.3` adds the ADR `0024` adapter trace independently of rich native Dart trace. Exact levels,
  records, UTF-8 counts, escaping, emoji, sinks, reset/append, persistence, and failure projection close all 20
  residuals; Dart reaches 61/61 default/POSIX and `.4` owns recurring verification/no-drift only.
- `2026-07-10`: `.1.5.3.4` makes both 61-case environments part of the focused Dart gate alongside 151 tests and
  99/99 corpus. The broader gate passes through Phase 0 `1..1028`; parent `.1.5.3` closes and global four-backend
  identity `.1.5.4` becomes active without changing help, fixture, or runtime semantics.
- `2026-07-10`: `.1.5.4.0` measures warmed Julia at 13/61: all ordinary results plus silent trace pass. The 48
  residuals are shared help, strict invalid UTF-8 plus phase-only stderr, and canonical trace. Cold precompile
  progress is toolchain ambient and must be handled by driver warmup. `.1`/`.2` repair Julia; `.3` owns one matrix.
- `2026-07-10`: `.1.5.4.1` makes the Julia primary boundary exact without changing native semantics: shared help,
  raw-byte strict UTF-8 file validation, and phase-only stderr advance both option environments from 13 to 42/61.
  The remaining 19 cases are exclusively canonical trace under active `.1.5.4.2`.
- `2026-07-10`: `.1.5.4.2` replaces only Julia primary trace projection with ADR `0024`'s deterministic phases.
  Native rich trace remains intact. Julia reaches 61/61 default/POSIX, and `.1.5.4.3` becomes the sole active leaf
  for warmup plus a recurring four-command identity gate.
- `2026-07-10`: `.1.5.4.3` installs `tools/run_primary_cli_matrix.sh` as the single recurring 4x2x61 proof, including
  Rust build, Dart preparation/warmup, and Julia project warmup. Focused Rust/Dart/Julia gates and the broader
  Phase 0 gate pass; exact CLI parent `.1.5` closes and capability census `.1.6` becomes active.
- `2026-07-10`: `.1.6.0` separates complete capability parity from green CLI/corpus subsets. A validated
  15-capability/60-state matrix owns language-proof coverage, Rust descriptor/diagnostics, native named/file
  resolution, Dart full-pipeline trace, and generated-source residuals without treating future/legacy surfaces as
  accidental current requirements.
- `2026-07-10`: `.1.5.1.0` proves Perl's primary adapter is parser-oriented but not strict/deterministic enough to
  be the neutral executable reference. Fixture infrastructure, arguments, success/IO, failures, and trace/gate are
  separate leaves; `.1.5.1.1` became active there and has since closed the runner/help baseline. No behavior changed
  in the split.
- `2026-07-10`: `.1.5.1.1` adopts `cli_conformance/manifest.json` plus one arbitrary-command Perl runner as the
  reusable cross-backend fixture architecture. Explicit placeholders represent command/runner inputs; they do not
  authorize backend-specific expected outputs. Exact generated workspace files are part of schema version 1 so
  later trace cases do not require a schema fork. `.1.5.1.2` became active there and has since closed strict Perl
  arguments.
- `2026-07-10`: `.1.5.1.2` removes ambient option-parser policy from Perl's public command. Exact shared parsing is
  manual and case-sensitive; usage-template variables are manifest data and cannot override reserved runner inputs.
  Twenty-two cases pass under both default and POSIX environments; `.1.5.1.3` has since closed successful IO/control.
- `2026-07-10`: `.1.5.1.3` adds seven portable success cases without changing Perl behavior. Named/file/inline
  source, literal/file input, top-rule, seek/consume, nested canonical JSON, exact input newline bytes, empty
  stderr, exit `0`, and one record newline are locked. `.1.5.1.4` has since closed operational failures/stdout purity.
- `2026-07-10`: `.1.5.1.4` adds four exact phase-ordered failures and normalizes the untraced adapter boundary.
  Compilation precedes input; compile/input/invocation emit one shared heading, empty stdout, exit `1`, and no
  files. Ambient backend trace state cannot opt the primary command in; `.1.5.1.5` has since closed explicit trace.
- `2026-07-10`: `.1.5.1.5` adopts ADR `0024` and closes canonical trace at 20 exact trace / 53 total cases. The
  timestamped multi-megabyte backend stream becomes a concise portable phase protocol while native tracing remains
  rich. Signoff also exposes a pre-existing UTF-8 argv-to-JSON mojibake boundary, now owned by active `.1.5.1.6`;
  Rust `.1.5.2` stays pending until the Perl/shared reference boundary is exact.
- `2026-07-10`: `.1.5.1.6.2` strictly decodes Perl argv/source/input, preserves normalization/BOM/newlines,
  recursively emits UTF-8 JSON once, and keeps invalid files in compilation/input-load phases. Eight exact
  Unicode/invalid families raise the shared suite to 61/61 in default/POSIX environments. `.6.3` becomes active
  for final reference no-drift; Unicode is the logical model and UTF-8 the selected boundary encoding.
- `2026-07-10`: `.1.5.1.6.3` reconciles every live reference surface at 61 cases, keeps pre-fix/53-case evidence
  explicitly historical, closes parents `.1.5.1.6` and `.1.5.1`, and activates Rust `.1.5.2` against the unchanged
  manifest. No implementation or expected bytes change in this closeout.
- `2026-07-10`: Director clarification corrects the closed `.14` abstraction: scalar, array, harray, and codeblock
  are the four object/value kinds, and a signature accepting a final codeblock must make `call(args) { block }`
  equivalent to `call(args, { block })` across helper/user-function/receiver surfaces and all variants. Current
  Perl/Rust/Dart/Julia behavior remains name-specific; Lua is absent. `.11.0` captures this without pivoting, and
  `.11.1` owns canonical design, parity splitting, terminology, and whether `with` remains or is removed.

## Open Questions

- None blocking. Semantic design/neutral, admitted Perl/Rust/Dart, shared Unicode grammar closure, Julia Unicode
  and source/outcome foundations, and Julia's five-target private static projection are composition-closed through
  no-change leaf `.10.6.3.3` at clean commit `4a580295`. Behavior-free calls/staging/generated authority plan
  `.10.6.4.0` is a complete verified candidate from that commit; typed core `.10.6.4.1` waits for a clean plan commit.
  Root selection, rule-local cursor, duplicate regex-slot identity, and repeated-action result
  shape remain closed across neutral, all five backends, dual-ABI Lua, recurring composition, and public no-drift.
- Non-blocking documentation-test finding from `.5.1.3` signoff: the canonical `mdbook build` passes, but the
  optional `mdbook test` command treats an intentionally partial Rust embedding example and an untyped
  architecture diagram in `appendix/backend-handoff.md` as Rust doctests, producing two pre-existing failures.
  This leaf does not relabel or rewrite unrelated fences; a future documentation-testing owner should decide
  whether executable Rust examples gain hidden setup/`no_run` or illustrative fences become `text`/`ignore`.
- Generic explicit callable values/dynamic calls and remaining Rust/Dart/Julia callable-codeblock parity remain
  future-owned; contextual declared Lua helper/user-function/receiver forms are current and no longer an exclusion.
- Aggregate selectors are already retired across all five backends; their historical implementation sequence is
  retained below only as evidence.

## Blockers

- None. Exclusion public closeout `.24.2` is signoff-complete from clean `b576c646`; commit, brief clearing, and
  exact clean proof precede structural source-location contract `.14.1`.

<!-- Historical verification, commit, and changelog evidence continues through the indexed history part. -->
