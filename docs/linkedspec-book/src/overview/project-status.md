# Project Status

LinkedSpec is an actively evolving system. The current direction is not “freeze everything exactly as it once was.” The direction is to preserve the strengths that make LinkedSpec useful while modernizing the runtime, compiler, diagnostics, and documentation.

LinkedSpec is also a multi-backend system. The `.spec` language is the one universal contract; each backend is an execution platform that runs the same `.spec` files with identical semantics. The Perl implementation is the **reference backend** (the canonical behavioral oracle), and a Rust backend is the second execution platform. ADR 0021 schedules future full-parity backend work as Dart first, Julia second, and Lua third. ADR 0022 makes native in-memory host-language embedding the primary backend product surface; variant CLIs are thin adapters. ADR 0023 defines complete parity as identical user-observable capabilities/behavior and gives distinct backend executable names one exact primary CLI interface. Status below therefore distinguishes scoped milestones from complete parity.

Lua semantic introspection now has a composition-closed public static surface on both PUC Lua and LuaJIT. Opaque
source/outcome, exact static and calls/staging/generated projections, and index `capabilities`, typed `query`, and
raw `query_neutral` match all 19 static response digests plus 26 malformed-request boundaries. Seven committed
suites recompose at 1,492 assertions per ABI; complete Lua remains package 177/177, PUC primary 66x2, corpus
105/105, and repository-volume storage. No-change `.10.7.5.4` closes that parent without replacement behavior or
promotion.

Behavior-free runtime-observation audit `.10.7.6.0` is complete, and native capture `.10.7.6.1` now exposes an
optional invocation-local `semantic_observation_sink` on both Lua ABIs. Protected immutable slot events use the
accepted match's Unicode-scalar end before `accept_match`; one succeeded final event follows every normally built
result with exact shared-SHA input identity. Direct, loaded, normalized-AST reconstructed, execute-alias, and
traced convenience routes preserve results, cursors, trace, diagnostics, reentrancy, no-sink work, and exact
callback failure identity. Focused proof is 1,493 static/query plus 121 observation assertions per ABI; complete
Lua passes package 177/177, PUC primary 66x2, corpus 105/105, and 14-owner storage. Generated/emitted propagation
and observed-index derivation remain fenced for `.3` and `.2`, respectively. The neutral oracle remains 6 groups /
20 responses / 89 rejected mutations, rollout 5/9, and admission 4/6; generated-source v2/format 2 is unchanged.
Full signoff also passes primary 5x2x66, Unicode 10/10, all six no-drift ledgers, and canonical CI through Rust
1/1 in 77.88 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds, containment/moved-root proof, reference primary
66x2, and Phase 0 1,031/1,031 in 621 seconds.

ADR `0048` is now a closed language contract: explicit repetition collects one action-edge value per
accepted hit, lifecycle returns retain whole-rule authority, and pipe remains scalar choice. The executable
neutral contract covers eight mode cases and ten special cases. Its ten-role Perl and
15-role Rust/Dart/Julia/dual-ABI Lua admissions are composed by one recurring driver, so rollout is
closed. Every backend classifies bare `OR` as minimum-one repetition and collects action returns per hit across
native/generated routes without changing lifecycle authority, scalar pipe, or generated-source v2. The driver
also proves the exact `["A","B"]` primary result across five commands and two environments plus all three support
ledgers. Repeated-action rollout is closed at 8 complete / 0 pending with 54 rejected mutations. Run
`tools/check_repeated_action_result_five_backend.sh` for the exact six-runtime recurring proof.

The separately completed ADR `0046` root-selection contract says an explicit selector, including
`--top-rule NAME`, wins over authored markers; otherwise the first authored `::` wins; without a marker, the first
authored rule wins. The backend-neutral executable contract rejects 54 drift mutations, and final
recurring/public admission closes rollout at 7 complete / 0 pending. Composed
Perl, Rust, Dart, Julia, and dual-ABI Lua backends implement native, loaded/reconstructed, generated-direct/traced, emitted where available,
descriptor, diagnostics, runtime/request trace, strict, and primary-command routes while preserving authored
marker identity. Their root-selection admissions established 65 primary cases in both option environments,
including exact first-marker, markerless, explicit/unknown, and request-trace outcomes; the repeated-action
recurring projection adds the 66th case. Rust, Dart, Julia, and Lua additionally have topology-checked
15-role consumers that each execute every declared admission role exactly once. Dart core `.9.1.1.2.3.1` accepts markerless
one-or-more-rule sources, resolves explicit > first marker > first rule once before user code, reports portable
zero/unknown failures, preserves descriptor marker identity, and passed the then-current 65-case primary suite twice. Route
leaf `.3.2` now proves loaded/normalized and generated/emitted direct/traced reuse, low
requested/effective/basis trace, portable failures, unchanged generated-v2 identity, and contract-first rejection.
Admission `.3.3` locks driver/case topology and advances Dart after a 270-test package gate, 65x2 primary proof,
and 105/105 corpus proof. Julia core `.9.1.1.2.4.1` accepts markerless one-or-more-rule source, centralizes exact
explicit/first-marker/first-rule selection before user code, returns portable zero/unknown identities, preserves
strict authored-edge analysis, and publishes immutable descriptor root identity. Its neutral-consuming focused
suite passes. Route leaf `.4.2` proves loaded/normalized and generated/emitted direct/traced reuse, low requested/
effective/basis trace, portable loader/generated failures, and generated-plan-first validation through 57
assertions. That route leaf measured shared primary at 32/65 in both option environments and corpus 105/105; its
33 cursor-owned help/usage/request-trace failures are now removed by Julia cursor `.9.1.6.5`. Dart composed cursor
admission `.9.1.5.6` closes its backend parent with one exact
15-role consumer, package 271, primary 65x2, corpus 105, and neutral 67-file / 4-of-8 / 39-mutation governance.
Clean commit `7aa9c578` lands that admission. Behavior-free Julia cursor preflight `.9.1.6.0` is verified, and
normalization `.9.1.6.1` now classifies every authored family, retains every governed bare-edge shape as typed AST,
emits the six portable edge diagnostics, and lowers family-derived ownership into compiled action/blind tables.
Intrinsic runtime `.9.1.6.2` now derives cursor plus sequence/choice once at every live, loaded-default,
normalized, recursive, and traced rule entry. Children rederive from their own family. Descriptor `.9.1.6.3` now
publishes cursor v1 plus per-rule family/policy/ownership/edge facts with direct/normalized/loaded byte identity.
Generated-source `.9.1.6.4` now emits v2/format 2, derives the exact family policy, rejects v1 before payload
reconstruction, and removes the private v1 engine. Public-option `.9.1.6.5` now removes engine/loader/corpus/
primary global ownership, returns targeted API/CLI diagnostics, omits the help/request-trace field, and preserves
`--top-rule`. Cursor admission `.6` composes one exact 15-role Julia cursor consumer. Root admission `.4.3` now
adds a separate exact 15-role root-selection consumer over every neutral/native/composed/diagnostic/trace/primary
route; authored selection fixtures return from entry lifecycle `I` so their distinct results prove which rule was
entered. Complete Julia is 3,428, shared primary is 65/65 twice, corpus is 105/105, cursor governance remains
67/5+3/44 at Julia admission. Lua/LuaJIT public-option removal and composed cursor admission are implemented. The
cursor consumer passes 119/119 per ABI at its 69/6+2/49 admission boundary. Recurring cursor admission and public
no-drift now compose Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, selected 5x2x5 primary cases, support ledgers, and
the current public surface at 75 migration files / 8 complete + 0 pending / 60 rejected mutations. Run
`bash tools/check_rule_local_cursor_five_backend.sh` for the exact recurring proof. A separate shared-source root consumer
executes its exact 15 roles on each ABI: topology RED 3/3x2 becomes 139/139x2, package 177/177x2, primary
65/65x4, and corpus 105/105x2. Final recurring/public admission closes root governance at 7 complete / 0 pending
with 54 rejected mutations and a 25-document public contract. Run
`bash tools/check_root_rule_selection_five_backend.sh` for the composed six-runtime plus selected 5x2x6 proof.
Canonical local CI passes the complete 65-case reference command suite in both option environments and Phase 0
1,031/1,031 in 642 seconds.

Duplicate regex-slot identity is closed across all current runtime legs. Behavior-free audit
`FUTURE-PARITY-BACKLOG.9.1.8.1.0` proves that compiled rules, descriptors, and generated-v2 payloads retain two
identical authored slots, but ordered execution diverges afterward. Perl and Rust match one combined alternation,
report the first duplicate branch, and reject it when a later sequence slot was required; their native/generated
ordered fixture returns `null`. Dart, Julia, PUC Lua, and LuaJIT match the required slot directly and return
`ordered-ok`. Every runtime resolves duplicate OR/choice ties to the first authored slot. Repeated evidence shows
the same original Perl failure and dual-ABI Lua success, while a non-identical Perl repeated control remains exact.
The audit changes no runtime behavior. Neutral `.1` now adopts ADR `0047` and executable
`linkedspec-duplicate-regex-slot-identity-v1`: ordered execution matches its required structural slot, repeated
AND resets its sequence, and choice uses earliest start then first-authored priority. Five fixtures, two
diagnostics, and six runtime inventory rows. Perl `.2` now matches required compiled rows directly for ordinary,
repeated, and cross-target AND actions while preserving first-authored choice. Descriptor identity, exact slot
trace, both typed diagnostics, loaded execution, and independently loaded generated v2 source are locked by one
12-role consumer. Generated v2 embeds `dependency_slot_map` execution payload without widening its
`{label,family}` plan. Rust `.3` now retains individually compiled patterns for known ordered steps in both
ordinary and generated-plan execution, leaves combined choice intact, validates malformed compiled slots before
native/generated execution, publishes descriptor/emitted contract identity, and passes one exact 15-role
admission over all five fixtures plus loaded/reconstructed, artifact, trace, primary, and diagnostic routes.
Although Dart already returned the correct fixture values, `.4` removes its internal single-pattern recompile+
reindex approximation. Ordered execution now calls an explicit authored-alternative matcher that returns the
required index directly; choice retains earliest-start/first-authored priority. Shared compiled-state validation,
descriptor metadata, emitted-v2 identity, native/generated `regex_slot_selected` trace, primary execution, and
both portable diagnostics pass one exact 15-role consumer. Generated source still embeds normalized-spec JSON and
keeps its `{label,family}` plan unchanged. At the Dart boundary, governance was 4 complete + 3 pending with 36
rejected mutations.
Julia `.5` replaces its behavior-preserving singleton-match/reindex seam with direct authored-alternative
matching. Shared compiled-state validation, descriptor/emitted identity, native/generated slot trace, primary,
and typed diagnostics pass one module-isolated exact 15-role consumer; generated source still reconstructs
normalized `SpecFile` JSON and keeps the minimal plan. Dual-ABI Lua `.6` preserves the same direct-slot contract
through one shared 15-role consumer on PUC Lua and LuaJIT. Final `.7` adds no semantic path: it composes all six
runtime admissions, selected 5x2x1 primary proof, and support ledgers through
`tools/check_duplicate_regex_slot_identity_five_backend.sh`. Governance is 7 complete / 0 pending with 59
rejected mutations and a 22-document public contract. Julia signoff passes package 3,549, primary 65x2, corpus
105/105, and canonical Phase 0 1,031/1,031 in 623 seconds. Rust signoff passes the complete Rust package and both 105-case
oracle/classifier layers, exact primary 65x2, Knowledge Map/mdBook/doctrines, and canonical Phase 0 1,031/1,031
in 619 seconds.

Behavior-free Lua preflight `.9.1.1.2.5.0` proves PUC Lua and LuaJIT have the same boundary. The shared primary
manifest is exactly 31/65 in both default and POSIX environments on each ABI: markerless default is the sole
root-owned failure, while 22 help/usage and 11 request-trace failures belong to cursor migration `.9.1.7`. Each
complete package has 176 passing groups plus the one cursor help mismatch, and each corpus is 105/105. Ordered
native/reconstructed/generated-v1 fallback already exists behind marker-required validation. Work is therefore
frozen as core `.5.1`, composed routes `.5.2`, cursor `.9.1.7`, then exact 15-role admission `.5.3`. New authored
selection fixtures use entry lifecycle `I`; the fixed request-trace fixture retains its canonical `E` bytes.

Lua core `.5.1` now removes that validation blocker on both ABIs. Empty/comment-only source remains an empty parser
envelope; validation accepts one-or-more-rule markerless source and returns typed `no_rules_defined` /
`validate_spec` for zero rules. One compiled-state resolver applies explicit selector > first authored marker >
first authored rule before runtime context or user code, and an unknown selector returns
`entry_rule_not_found` / `select_entry_rule`. Definition order and authored `is_top` stay immutable, strict-unused
remains authored-edge-only, and descriptors publish `linkedspec-root-rule-selection-v1`. Focused core proof passes
99 assertions per ABI. Route leaf `.5.2` now proves loaded source, normalized-AST reconstruction, generated-v1
direct/traced execution, and freshly persisted emitted direct/traced execution all reuse that resolver. Generated
artifacts remain contract v1/format 1 with the minimal ordered `{label, family}` plan; plan validation still
precedes selection. Loader zero-rule failures retain `no_rules_defined` / `validate_spec`, generated zero/unknown
failures retain the corresponding portable stage/code, and unrelated validation remains generic. Low
`lua_runtime:entry_rule_selection` decisions record requested/effective/basis on success and requested/`<none>`/
stage/code on failure. Focused route proof passes 101 assertions per ABI; package execution remains 176/177 with
only the cursor help mismatch, shared primary is exactly 32/65 in all four ABI/environment legs, and corpus is
105/105 per ABI. Route closeout passes canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in
643 seconds. Cursor and exact dual-ABI admission then completed; final public no-drift subsequently closed the
root rollout at 7/0.
Cursor generated-source leaf `.9.1.7.4` subsequently advances new Lua artifacts to v2/format 2 while preserving
that root-selection route and minimal plan.

Behavior-free Lua cursor preflight `.9.1.7.0` now makes that pending boundary exact on both PUC Lua and LuaJIT.
All 36 authored family headers parse, but only 34 classify correctly because compact `|` still enters the AND
family. One engine-wide default seek policy makes 22/36 family rows intrinsic. Of the 13 expected-success edge
rows only five compile, and of four expected-success ownership sets only the two all-explicit sets compile; bare
members remain raw syntax and none of the seven invalid edge/set rows has its portable diagnostic code. Mixed
parent/child execution is 4/8 and the structural replacements are 1/2. Normalized and loaded engines inherit the
same global option, rule trace has no derived cursor policy, descriptors retain global seek, and generated source
remains v1/format 1. Package proof is 176/177 per ABI, all four ABI/environment primary legs are 32/65, corpus is
105/105 per ABI, and neutral governance stays 67 files / 5 complete + 3 pending / 44 mutations. No executable
behavior or shared fixture changes in the preflight; `.9.1.7.1-.6` retain the dependency order normalization,
normal runtime, descriptor v1, generated v2, option removal, and dual-ABI admission.

Lua normalization `.9.1.7.1` now closes the first implementation step identically on PUC Lua and LuaJIT. Compact
`|` is authored OR/default; complete-line and header-rest bare plain/index/group/block/fluent candidates retain
typed provenance and nullable authored indices; lifecycle markers keep lexical priority; forward targets resolve
after all labels are known; and explicit edges keep written ownership. Validation emits the exact six neutral
edge codes with governed stage/fields, while valid family-derived ownership lowers into existing compiled
action/blind tables. The exact contract proof moves from 44/166 RED failures to 258/258 green assertions per ABI;
all five focused consumers pass 936 assertions per ABI. Package remains 176/177 with only staged help, all four
primary legs remain 32/65, corpus remains 105/105 per ABI, and cursor governance was 67/5+3/44 at normalization. Runtime now
uses that normalized identity in `.9.1.7.2`: omitted-policy live, loaded, normalized, recursive, and traced entries
derive AND-consume/sequence or OR-default-seek/choice independently, including all eight child mechanisms and both
structural replacements. Its exact proof moves from 44/110 RED failures to 110/110 per ABI, and six focused
consumers total 1,046 assertions per ABI; registering that consumer makes governance 68/5+3/44. Explicit
outer policy remains a compatibility seam until `.5`; before the `.4` contract bump, generated-source v1 retained
historical seek plus legacy family interpretation. Descriptor still
uses cursor v1 as of `.9.1.7.3`: root metadata has the neutral contract rather than a global mode, and each rule
projects normalized family, policy, ownership, and exact ordered semantic edges. Direct, normalized, and loaded
bytes agree, and focused proof passes 875 assertions per ABI. Generated source is now v2/format 2 as of `.4`: it
derives cursor/structure from the minimal family plan, classifies compact pipe as OR, and rejects v1 before payload
decoding. Its identical 44/106 RED is now 106/106 green per ABI and makes eight focused consumers total 2,027;
governance moves only to 69/5+3/44. Public-option `.5` then deletes caller-global engine state and removes the
override from parse, loaded, corpus, generated, primary-help, and request-trace routes. Snake/camel legacy keys
fail with `prepare_options` / `parse_mode_override_removed` before input or user code; the retired CLI spelling
returns its exact usage exit 2; and `--top-rule` retains priority over authored `Rule::`. Its 75/96 dual-ABI RED
becomes 96/96, the complete package passes 177/177 per ABI, and all four primary legs pass 65/65. Governance is
68/5+3/44 at removal. Composed admission `.6` then runs one exact 15-role consumer on each ABI: native default/AND,
normalized, loaded, descriptor v1, emitted/generated v2 direct/trace, mixed/recursive, both structural
replacements, static/dynamic removal, primary, and all portable diagnostics. Exact pre-contract RED is 3/3 per
ABI and green is 119/119 per ABI; governance advances only Lua to 69/6+2/49. Descriptor canonical proof passes
through Phase 0 1,031/1,031 in 621 seconds; the subsequent generated-v2 canonical closeout passes the same 1,031
tests in 644 seconds with Knowledge Map 630/4,622.

Julia normalization now passes 353 contract-driven assertions over all 36 family spellings, all 18 edge rows, and
all six ownership sets. Compact `|` is OR/default; complete-line and header-rest bare references preserve omitted
versus authored `[0]` indices, blocks, fluents, forward targets, source form, and lifecycle precedence. Validation
returns the exact neutral stage/code/fields for undefined, indexed/grouped AND, mixed ownership, indexed blind,
and blockless grouped-action failures. Compiled state exposes the derived family/policy and lowers valid bare edges
into its existing action/blind tables. Normal execution now passes 104 contract-driven assertions: all 36 family
spellings on live and normalized routes, all eight mixed parent/child mechanisms, both structural replacements,
loaded-default behavior, recursion, and trace attribution. AND consumes/sequences; OR/default seeks/chooses; each
child rederives. Descriptor v1 has no descriptor-global field and projects exact semantic edge rows; its focused
suite passes 809. Generated v2 retains only ordered label/family rows, derives five seek and five consume policies,
and passes focused assertions across direct, traced, accepted-subset, and fresh-loaded routes. Public removal
leaves only low-level seek/consume matcher primitives and deliberately rejects legacy high-level options before
execution. One exact consumer now composes all 15 governed roles. Package execution passes 3,291 assertions,
primary is 65/65 twice, corpus is 105/105, and governance is 67/5+3/44. Julia alone advances at admission; Lua,
recurring admission, and public no-drift remain pending.

## Completed phases

Phases 0–9 of the modernization roadmap are done:

- **Phase 0**: Regression safety net — `t/phase0_regression.t` covers all 21 shipped specs with a green `1031`-test baseline; every `.spec` compiles at `language_agnostic_ready_ratio == 1.0000` (zero compatibility-surface rules).
- **Phase 1**: Thin facade + owner dispatch — `LinkedSpec.pm` is a lazy public facade over owner modules that route through uniform `OwnerDispatch`; the former `ActionRewriter.pm` forwarding shim was deleted (118 lines).
- **Phase 1A**: Thin-façade modularization — `LinkedSpec.pm` delegated into focused owner modules (`Trace`, `Validation`, `Resolver`, `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `RuleIR`, `EmitContext`); the shared `OwnerDispatch` seam replaced per-owner lazy-loading wrappers.
- **Phase 2**: DSL frontend hardening — rule-label parsing, inside-block rejection, extra-colon rejection, fluent-continuation recognition, `strict_syntax` mode, construct-recognition alignment with bootstrap grammar.
- **Phase 3**: Execution semantics — seek/consume parse modes documented; explicit cursor controls are local cursor operations, not systemic backtracking; forward-moving non-backtracking model stated.
- **Phase 4**: Capture/mark API — 163 contracts across 6 families verified, compat aliases documented, mark-helper reference complete.
- **Phase 5**: Runtime diagnostics — structured last_error is the single diagnostics channel; handler compile warnings routed through trace instead of stderr; eval minimized to one handler compilation; trace bridging from compile scopes into runtime handler scopes.
- **Phase 6**: Documentation and adoption — the book you are reading. All identified documentation gaps closed (LinkedRE, Validation, public API, cross-linking, overviews, ActionIR lowering, per-spec walkthroughs).
- **Phase 7**: Self-hosted `spec.spec` grammar — LinkedSpec parses its own `.spec` language through the DSL itself. `spec.spec` compiles at `language_agnostic_ready_ratio == 1.0000` with regression coverage; it is the required change surface for `.spec` language evolution.
- **Phase 8**: Multi-backend specification and handoff — the `.spec` language, runtime semantics, helper contracts, and HandlerIR are specified backend-neutrally, so a backend can be built in any language without reading the reference source. The multi-backend vision — the same `.spec` files, the same semantics, and the same test corpus across all backends — is recorded in ADR 0006. This phase was specification-only (no behavioral code change).
- **Phase 9**: Rust variant — a second execution backend. The Rust workspace (`rust/`: `linkedspec-core` + `linkedspec-runtime`) carries its own `.spec` parser, compiler, runtime engine, and helper surface, and runs `.spec` files compiled from the same universal contract. It is operational in interpreted mode, and the current manifest-backed Rust oracle is green over 105 fixtures plus manifest drift guards. The generated-source path proves direct execution for the current structural families plus a curated manifest-backed corpus subset.

The active Dart backend follows the same interpreter-first path. It now has source parsing, validation,
compiled-spec state, runtime interpretation, staged user-function body parsing, exact-arity user-function runtime
execution, and a controlled executable corpus harness whose full checked-in 105-fixture manifest passes through Dart
execute mode. The final shipped-spec/parser-smoke
window is now 31/31 green after the structural regex closeout following the regex-dialect, helper/action,
recursion/default-mode, portmap result-shape, hlink delimiter/capture, helper mutation/text-normalization, and
legacy accumulator and public-parser leading-trivia bridges. Basic
Dart regex-dialect bridging is now in place for POSIX character classes, inline/scoped flags, possessive
quantifier markers, lower-bound `{,n}` quantifiers, and Python-style named captures. Scoped flag groups are accepted
by lifting their options to Dart `RegExp`. The missing helper/action bridge is also in place for direct
capture-slice helpers, diagnostic output helpers, logical helpers, `exit_now`, and quoted helper-call delimiter
parsing. Dart now also resolves tclite-style action-edge regex dispatch, scopes explicit aggregate resets per rule
invocation, refreshes `retv` from `call(...)`, and appends into scalar-held lists created by assignments such as
`items = []`. Statement-form `substr(...)` / `regex_subst(...)` mutations, explicit
`split(target, ...)` replacement, and entry/local line helpers are also implemented, and Dart mirrors the
Perl public parser's leading blank/comment-line skip before the top rule. The tclite, recursive top-rule, hlink,
tablegrep, simenv, `lib_reader`, `regdef`, `ds_vhistory`, Lispish, EBNF, and spec.spec parser-smoke fixtures now
pass. Bounded structural matchers handle the exact shipped recursive/DEFINE/`\K` PCRE forms, and action-edge
`push(child, index)` preserves EBNF logging payloads. Dart full-corpus parity is now 105/105 green, and the focused
Dart local gate is available through `tools/run_dart_local.sh` or opt-in `LINKEDSPEC_RUN_DART=1` local CI.

The Method-like DSL migration track is also complete: all 21 shipped specs are at zero compatibility-surface rules, 100+ helpers across 10 families are regression-locked, current helper names are the only documented helper surface, and fluent/block equivalence is verified. Current setup and read forms use direct assignments, `set(...)`, bare scalar reads, `array(...)`, `hash(...)`, `push(...)`, `copy(...)`, and `return(...)`. Unknown typed calls in return/value positions diagnose through the generic unknown-helper path instead of emitting generated host-language calls, while unregistered standalone function-shaped statements remain explicit raw compatibility debt. Top-level `fn name(args) { ... }` definition shells are parsed by `specs/user_function_definition.spec` and projected through the active user-function registry, with versioned signature data, source/body spans, body source, neutral `body_payload`, neutral `body_parse_job`, and body AST recorded. The parse-job sidecar now dispatches through the minimal staged registry provider for `actionir-body.spec` / `action_block`, and the returned `action_block` AST is stitched into `body_ast`; general public `parse_job(...)` authoring remains future work. On Perl, Rust, Dart, Julia, and Lua, registered exact-v1 and final-rest-v2 user-function calls execute in value positions, compatible receiver chains, and standalone discard statements: positional arguments evaluate eagerly in the caller, fixed params and a fresh rest array bind in a fresh function-local scope, and the result is the final expression or `return(expr)` payload. Lua additionally executes declared final contextual codeblock slots in the current isolated function frame with cleanup-safe caller restoration and typed arity/keyword/recursion/staging/callback failures. Recursive and unsupported function-body forms remain fenced as diagnostics. The accepted definition surface is explicit-paren, braced `fn` with optional final `...rest`; alternate spellings, omitted zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/currying, and function namespaces remain deferred extension topics.

## Backbone items

Three backbone items tracked major structural modernization — all done:

1. Declarative bootstrap grammar registry replacing positional bootstrap coupling (done)
2. Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases (done)
3. Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting (done)

## Ongoing

- **Documentation and book sync** — the book is kept aligned with the codebase as features land and surfaces evolve.
- **Variant-agnostic documentation** — this book is being aligned so it describes the `.spec` contract, DSL, and helper semantics backend-neutrally, with the Perl implementation shown as the reference backend rather than as "the" implementation.
- **Inter-match gap capture direction** — ADR `0045` recovers historical “super split” as automatic prefix/interstitial source-gap access around repeated OR/default action edges. Target rules own referenced regex slots and lifecycle code; the enclosing rule owns selection and gap orchestration. The accepted future `@capture_gaps` spelling and spacing-insensitive `name=/regex/` → `Rule[name]` slot contract are not implemented; their neutral contract/rollout remains dependency-gated behind the active rule-local cursor program. The same audit records existing marker drift: Perl anonymous scope is rule-level, Lua's is preceding-slot-local, and Rust/Dart/Julia do not execute marker members natively.
- **Future backend parity backlog** - `FUTURE-PARITY-BACKLOG` owns deferred/future work. Lua input/live-cursor
  controls `.4.3.7.1` pass 115/115, all 16 anonymous capture calls `.4.3.7.2` pass 116/116, and non-consuming
  earliest-boundary `.4.3.7.5` passes 117/117 on PUC Lua and LuaJIT. Complete named-mark `.17.1-.17.5` align and
  admit one exact seven-helper Unicode/rule-local contract at 246 shared names with 122 independently checked
  public Perl contracts. Lua `.4.3.7.3` extends that one store across governed named writers, spans, two-mark reads,
  and anonymous/named bridges at 120/120; placement-sensitive `.4.3.7.4` executes typed post-action split/named-
  mark slot events at 121/121; exhaustive `.4.3.7.6` closes 62/62 current calls plus four markers. Lua `.4.3.8`
  emits eager ordered Unicode diagnostic messages through an optional per-parse typed caller sink, stays quiet by
  default and parse-result neutral, retains immediate `exit_now`, and passes 122/122 on both ABIs. Exhaustive
  `.4.3.9.0` then probes all 246 names: 230 reach an owner, thirteen are intentional statement/receiver-only
  surfaces, and eager `and`/`or`/`not` are the exact missing family. `.4.3.9.1` executes them eagerly; permanent
  `.4.3.9.2` closes all-name ownership as exact 233 function forms plus thirteen documented non-function forms,
  focuses direct `call(rule)`, and passes 125/125 on both ABIs. Parent `.4.3` is closed. Planning-only `.4.4.0`
  separates structured runtime failures, trace controls/sinks, runtime events, and no-drift. `.4.4.1` adds neutral
  typed runtime diagnostics with optional spec identity, specific stages, deepest-rule/handler preservation,
  deterministic JSON, and unchanged success output at 126/126. `.4.4.2` adds typed ordered trace controls/events,
  documented environment config, caller-owned stdout/route/mirror sinks with reset/append, and result-neutral
  runtime wrappers at 128/128. `.4.4.3` adds exact rule/regex/dispatch/recursion/lifecycle/cursor/boundary/mark-
  capture events at 129/129; `.4.4.4` closes scoped runtime no-drift and parent `.4.4`. Minimal staged dispatch
  `.5.1.1` passes 130/130; fixed-v1 execution `.5.1.2` passes 133/133. Variadic-v2 state `.5.1.3.1` preserves the
  exact signature union and minimum/unbounded registry resolution at 136/136. Fresh rest-array runtime `.5.1.3.2`
  then executes the unchanged neutral fixture, copied mixed/empty values, receiver chains, and typed failures at
  139/139. Final contextual metadata `.5.1.4.1` canonicalizes exact `callback: codeblock` state through shell,
  staged records, typed AST, registry, and compiled state, rejects all four invalid declarations, and normalizes
  both contextual spellings without promoting harrays. Runtime `.5.1.4.2` executes those zero-positional blocks in
  the current isolated function frame, restores outer stores, preserves static callable precedence, composes
  results, and keeps callback failures typed. Portable resolution/loading `.5.2.1` then adds typed requests,
  deterministic direct candidates, in-process bytes, strict UTF-8 preservation, and structured errors. Automatic
  spec-defined function parsing `.5.2.2` then resolves and compiles the bundled grammar once and composes typed
  output without a raw scanner. Loaded-source composition `.5.2.3` now returns typed exact identity/source/compiled
  state, maps neutral source-pipeline errors, and creates named/path-attributed engines. Both ABIs pass 153/153
  with public status `native-spec-pipeline-v1`; no-drift `.5.2.4` closes parent `.5.2` without behavior change.
  Planning `.5.3.0` splits exact outward descriptors, full native-loading/frontend/compiler/function/staged/runtime
  trace, and admission. Decision `.5.3.0.1` plus ADR `0041` now defines exact final-codeblock outward descriptor
  v3 over fixed `params`/`arity` plus final-only `parameter_kinds`, and preserved the four-backend all-pass census
  until sole Lua admission owner `.8.4`. `.5.3.1` now makes the executable descriptor contract authoritative for
  fixed-v1, variadic-v2, and final-codeblock-v3; Lua emits all three exact records with identical staged metadata,
  and Perl's existing final-codeblock projection is correctly labeled v3. `.5.3.2` now passes one caller-owned
  emitter through resolution/loading, all frontend/compiler/function/staged phases, engine creation, and runtime.
  Exact ordered events, sinks, filters, balanced errors, no hidden factory use, and traced/untraced identity pass
  155/155 on both ABIs with status `native-full-pipeline-trace-v1`. Census-preserving no-drift `.5.3.3` closes
  parents `.5.3`/`.5` without source/status/behavior/test/manifest change. Controlled/core planning `.6.1.0`
  measured exact offsets 0-39 plus 99-104 at 45/46 on both ABIs. Typed nested-path repair `.6.1.1` preserves
  key/index container requirements, governed segment/RHS evaluation order, and atomic failed writes; unchanged
  offset 20 and both windows now pass 46/46 while focused suites pass 157/157. Reusable library execution `.6.1.2`
  now validates before selection, composes automatic parse/validate/compile/source-identified runtime execution,
  compares exact wrapped typed JSON, and records every selected success/failure. Controlled proof passes 160/160
  on both ABIs while the CLI stays validation-only. Core admission `.6.1.3` permanently locks exact offsets 0-39
  at 40/40 with exact wrapped outputs and endpoint 1/1. Governed admission `.6.1.4` permanently locks exact
  offsets 99-104 at 6/6 with endpoints `2,1,2,1,5,5`; both focused suites pass 162/162 and parent `.6.1` closes.
  Advanced/shipped planning `.6.2.0` measures offsets 40-98 identically at 50/59 on both ABIs. Debug trace and
  canonical Perl generated-source/descriptor probes route nine residuals to four current mechanisms: action-edge
  child-call double dispatch, receiver-copy value loss, missing flat-array hash splicing, and public leading-trivia
  initialization. Repairs `.6.2.1-.4`, successor measurement `.6.2.5`, and exact permanent admission `.6.2.6` are
  split. Action-edge `.6.2.1` now caches matching current-edge calls, skips passive-terminal re-search, and leaves
  unrelated calls direct. Three HLink, two EBNF, and SimEnv fixtures pass unchanged; both ABI suites pass 163/163
  and the exact window reaches 56/59. Receiver-copy `.6.2.2` now deep-copies the one evaluated fluent value,
  preserves typed continuations, and closes the unchanged hash-receiver fixture. Both suites pass 164/164 and the
  window reaches 57/59. Flat-array hash splicing `.6.2.3` now consumes direct/receiver `flat_array(...)` results as
  ordered key/value tokens for `hash(...)` and `harray(...)`, closes unchanged `pplugin_empty`, and raises the
  window to 58/59. Public leading-trivia initialization `.6.2.4` now moves cursor/register state past only complete
  leading blank or `#` comment lines, preserves indexed reads, closes unchanged history, and raises the window to
  59/59 on both ABIs at 165/165. Successor remeasurement `.6.2.5` independently validates the full 105-case
  manifest and confirms exact offsets 40-98 at 59/59 with zero failures on both ABIs. Permanent `.6.2.6` locks
  all 59 literal names, unchanged wrapped outputs, matches, and exact byte/character endpoints at 166/166 per ABI.
  Complete-manifest `.6.3` then executes all 105 fixtures without selectors through the production library and
  separate developer runner, with exact order/output, 105 passes, zero failures, and exit classes 0/1/2. Both ABI
  suites pass 167/167, public status is `runtime-corpus-full`, parent `.6` closes, and primary parser CLI adapter
  `.7.1` then replaces the exit-2 scaffold with the exact thin native command. Options, strict UTF-8,
  named/file/inline execution, canonical JSON, stable phase failures/exits, and canonical phase trace pass 169/169
  per ABI. Admission `.7.2` makes shared CLI 61x2 recurring and extends the warmed matrix to 5x2x61. Status is
  `runtime-corpus-primary-cli`; final no-drift `.7.3` closes parent `.7`. Planning `.8.1.0` corrects the old
  v1/v2-only generated scaffold scope against outward descriptor v3. Emitter core `.8.1.1` now preserves exact
  fixed-v1/variadic-v2/final-codeblock-v3 effective state in deterministic native Lua with strict metadata,
  portable errors, and direct/traced value roles. `.8.1.2` now proves persisted valid/corrupt modules in fresh PUC
  Lua/LuaJIT hosts, including exact result/trace/failure observations and cleanup. The capability census remained
  four-backend 64/0/0 until `.8.4`, which now admits Lua all-pass at 80/0/0.
  Diagnostic-output planning `.5.1.0` and neutral contract `.5.1.1` are complete. Perl native `.5.1.2` and Rust
  native `.5.1.3` are admitted rollout legs: both deliver typed Unicode events through optional invocation-local
  caller sinks, remain quiet without one, enforce arity before effects, preserve sink failures, and use typed
  immediate-exit control. Dart native `.5.1.4` and Julia native `.5.1.5` now provide the same quiet parse-scoped
  typed event seam while preserving exact caller failures outside ordinary runtime wrappers; Julia rich events
  are also separate from native trace. Lua native `.5.1.6` passes 109 fixture assertions on both ABIs, preserves
  arbitrary sink-failure identity, and separates `RuntimeExitNow` from ordinary runtime errors. Generated/primary
  `.5.1.7` now extends every direct/traced emitted role with an idiomatic optional or paired sink, preserves
  caller failures and typed exit across generated framing, and locks quiet canonical JSON through the shared
  five-backend/two-environment 62nd CLI case. Recurring gate `.5.1.8` now composes the neutral model, six native+
  generated consumers, selected quiet 5x2x1 projection, and generated-source/capability/corpus ledgers under one
  topology-checked driver; the expanded default matrix now runs 5x2x63. Public no-drift `.5.1.9` locks 16
  authoritative documents, nine forbidden stale claims, five-backend native/generated examples, and 20 drift
  mutations. The ledger is 8 complete / 0 pending and parent `.5.1` is closed. Completed planning audit `.5.2.0` splits
  Perl logical keyword lowering plus Dart evaluation/empty-`and` and five-backend truthiness/arity drift before
  behavior. It proves Perl condition-only laziness versus broken direct values, Dart short-circuiting, eager
  Rust/Julia/Lua execution, and three truthiness profiles; `.5.2.1-.9` own neutral policy, each backend,
  generated/primary projection, recurring proof, and public no-drift. Neutral `.5.2.1` now adopts ADR `0043` and
  checks `linkedspec-logical-helper-v1`: at-least-one eager `and`/`or`, exact-one eager `not`, pre-effect arity
  diagnostics, typed null/boolean/finite-number/string/aggregate/codeblock truth, boolean receiver results, and
  lazy-control separation. Its 17 truth rows, ten helper cases, three effect scenarios, deterministic fixtures,
  and 22 semantic/topology mutations pass offline. Perl `.5.2.2` supplies typed logical ActionIR/runtime behavior across native,
  live, and standalone-emitted execution. Rust `.5.2.3` now aligns the shared condition/helper truth seam,
  pre-effect logical arity, native structured fields, and native/serialized/generated-plan/direct/compiled-
  emitted roles. Dart `.5.2.4` now removes helper short-circuit and empty-call drift through one typed
  helper/control seam, pre-effect arity, eager values, logical-only structured fields, and native/normalized/
  generated-plan/standalone-emitted/primary proof. Julia `.5.2.5` preserves its typed eager truth seam and adds
  exact arity plus native/normalized/generated-plan/standalone-emitted/primary proof. Lua `.5.2.6` aligns the
  same truth/arity contract through native/reconstructed/generated-plan/emitted/primary proof on both ABIs.
  Generated/primary `.5.2.7` now proves all available direct/traced generated roles, exact values/effects/failure
  metadata, Rust's typed direct-value versus legacy compatibility-output split, and common case
  `success_logical_helpers_eager` through all five commands under default and POSIX options. Recurring `.5.2.8`
  now composes the neutral checker, six exact native/generated consumers, selected 5x2x1 case, support ledgers,
  and opt-in canonical-CI leg under one omission-checked driver. Public no-drift `.5.2.9` locks the authoritative
  guide, backend, status, capability, CLI, task/live, and Knowledge Map surfaces plus four public mutation classes.
  Rollout is 8 complete / 0 pending and parent `.5.2` is closed.
  Director-priority cursor audit `.9.1.0` then establishes that public/global `parse_mode` rewrites every nested
  rule and exposes an uncovered default-AND parity split: Perl/Dart/Julia/Lua seek while Rust follows compiled
  AND-consume behavior. Explicit seek/consume agrees on all five, and the two cross-combinations remain
  semantically meaningful, but the audit recommends intrinsic OR/default seek plus AND consume and no global
  override. The director has since confirmed rule-local ownership: parent mode never propagates to or overrides a
  child. ADR `0044` supplies the exact ratification. Neutral `.9.1.2` now checks 36 family spellings, 18 edge
  cases, eight parent/child mechanisms, and a token-derived migration inventory. Perl rollout is split into
  `.9.1.3.0-.6`; verified preflight
  maps the bootstrap/RuleIR/emitter/descriptor/generated/CLI boundaries and assigns reference-breaking shared
  byte fixtures to the reference CLI slice so canonical CI never relies on a hidden compatibility flag or skip.
  Perl `.9.1.3.1` now retains typed complete-line bare candidates, resolves forward declarations, normalizes
  AND to blind ownership and OR/default to action ownership, preserves lifecycle priority, emits portable
  normalization diagnostics, and publishes derived per-rule family/cursor/ownership metadata. Live slice
  `.9.1.3.2` makes normal handlers spend those policies independently. Descriptor `.9.1.3.3` now publishes the
  v1 cursor identity, removes root global-mode metadata, and projects ordered resolved-edge facts. Generated-source
  `.9.1.3.4` now emits/validates Perl v2, derives the exact five seek/five consume family map, removes the separate
  legacy artifact handler, and rejects v1 reconstruction with mandatory `.spec` regeneration. API/CLI `.9.1.3.5`
  now rejects dynamic overrides at `prepare_options`, removes the flag from help/request trace, returns targeted
  usage exit 2, and keeps all 63 reference cases. The Perl-admission inventory reached 72 after sixteen completed Perl test and
  shared byte owners become token-free while `GeneratedSource.pm` gains the portable emitter-removal envelope.
  Admission `.9.1.3.6` composes all of that behavior through 14 exact live/descriptor/emitted/generated/loaded/
  trace/diagnostic/recursive/structural/primary roles, registers the consumer in canonical CI, and observes all
  eight portable diagnostic codes. The checker rejects 29 drift mutations and advances only `perl_reference`, so
  rollout reached 2 complete / 6 pending there. Rust preflight `.9.1.4.0` changes no executable behavior and records the
  exact prior boundary: compact `|` was misclassified, complete-line bare edges were ignored, compiled/
  descriptor/generated state owned global cursor facts, generated source was v1, and primary conformance was
  51/63 in both environments. Gate-hardening `.9.1.4.1` runs the complete core package before runtime; verified
  normalization `.9.1.4.2` proves 189 unit, three descriptor, five normalization, and eight type tests. It classifies compact `|` as
  authored OR, retains complete-line/header-rest bare edges as typed AST, derives action/blind ownership, lowers
  typed dispatch tables, and emits neutral portable diagnostics. Verified `.9.1.4.3` removes mutable compiled
  policy and makes normal live, loaded, and ordinary reconstructed execution derive seek/consume from each entered
  family across action, blind, direct call, and recursion. Verified descriptor `.9.1.4.4` now publishes cursor-v1
  identity, normalized family/policy, aggregate ownership, and ordered semantic edge rows across direct, loaded,
  and reconstructed state, with no root/rule global fields. Generated `.9.1.4.5` now emits and reconstructs v2
  from one minimal label/family plan, derives all ten policies, rejects v1, and passes the exhaustive 105-case
  classifier plus focused and canonical signoff. Implemented public option/CLI removal `.6` deletes the global
  runtime/option state, retains entry-rule selection only, returns the targeted retired-flag usage error, removes
  the request-trace field, and passes all 63 primary cases in both environments. Focused and canonical signoff
  pass at commit `2bba1e91`. Composed admission `.7` now declares one exact 15-role Rust consumer over native
  default/AND, ordinary serialized, loaded, descriptor-v1, emitted-v2, generated direct/trace, mixed/recursive,
  both structural replacements, static removal, primary, and all portable diagnostic/removal outcomes. The
  checker requires every role marker plus canonical/default-to-optional-Rust registration, rejects 34 mutations,
  and advances only `rust_parity`. The inventory remains 68 files and rollout is 3/5; complete focused Rust proof
  and canonical signoff are green at clean commit `288da21a`; the Rust parent is closed. Dart preflight `.9.1.5.0`
  records all governed/non-token seams, compact-pipe/bare-edge/global-policy drift, descriptor/generated v1 state,
  104/104 focused plus 105/105 corpus proof, and the exact staged 244/1 package plus 30/63x2 primary boundary.
  Implementation is dependency-ordered across `.1-.6`; no Dart behavior changed in the preflight. Normalization
  `.9.1.5.1` now gives compact `|` its authored OR identity, retains complete-line/header-rest bare references as
  typed AST, derives action ownership for OR/default and blind ownership for AND, lowers both into compiled
  dispatch tables, and exposes the neutral portable diagnostics through Dart validation. A named legacy runtime
  adapter preserved the staged pre-`.2` execution boundary. Dart `.9.1.5.2` now removes that compiled adapter and
  derives AND-consume / OR-default-seek plus sequence/choice independently at every normal rule entry. All 36
  family spellings, eight mixed parent/child mechanisms, and both structural replacements agree across live,
  loaded, normalized-JSON, recursion, and trace routes. Descriptor `.9.1.5.3` now removes root global metadata and
  publishes cursor-v1 identity plus exact family/policy/ownership/ordered-edge/source facts across direct,
  normalized-JSON, and loaded projection. Generated-source `.9.1.5.4` now emits v2/format 2, retains only ordered
  label/family rows, derives all ten policies and structures, and rejects v1 before reconstruction with exact
  identities and regeneration guidance. Public option/CLI `.9.1.5.5` now removes engine, loader, corpus, staged-
  parser, help, execution, and request-trace global state; `--parse-mode` returns the targeted usage error. Dart
  passed 260 package tests, the then-63-case primary manifest in both environments, and 105/105 corpus fixtures.
  Root-selection core `.9.1.1.2.3.1` removes the preflight's marker-required validation block, preserves an
  empty/comment-only parser envelope for portable zero-rule validation, applies one ordered resolver before user
  code, publishes the root descriptor identity without rewriting `is_top`, and passes 266 package tests plus
  65/65 primary cases twice and 105/105 corpus fixtures. Route `.3.2` now proves loaded/normalized and
  generated/emitted direct/traced composition, portable diagnostics, low selection basis trace, and unchanged
  generated v2 identity; package proof reaches 269. Topology admission remains `.3.3`. The inventory
  contracts to 66 files with all 34 mutations. Canonical signoff repeats Perl admission 288, reference primary
  63x2, and Phase 0 1,031/1,031 in 627 seconds; only composed admission remains `.6`.
  This remains alongside `.5`'s
  switch/range, alias, loop/`next`, constructor/transform, `start_capture_slice()` result, and zero-argument
  `capture_until_boundary()` decisions. General user-function final `callback: codeblock` declaration/execution
  and outward descriptor v3 are current in Lua; first-class callable block values remain `.11.7`;
  generated Lua accepted-subset proof closes under `.8.3`, and five-backend census/handoff `.8.4` is complete.
- **Lua staged-function frontier** - Planning `.5.1.0` separates minimal action-body dispatch `.5.1.1`, fixed-v1
  runtime `.5.1.2`, variadic-v2 metadata/runtime `.5.1.3`, contextual final-codeblock metadata/runtime `.5.1.4`,
  and no-drift `.5.1.5`. `.5.1.1` provides stable job execution, the governed ActionIR-body provider/cache identity,
  immutable `body_ast` stitching, and composed shell dispatch at 130/130 on both ABIs. `.5.1.2` adds registry-first
  fixed calls, copied fresh stores, local returns, composition, and typed failure fences at 133/133. `.5.1.3.1`
  then preserves exact v1/v2 state, validates all seven invalid definitions, and resolves at or above the fixed
  prefix at 136/136. `.5.1.3.2` binds fresh copied rest arrays and executes the exact shared fixture at 139/139;
  `.5.1.4.1` preserves final codeblock metadata and contextual normalization at 142/142; `.5.1.4.2` executes the
  dynamic contextual path at 146/146; and `.5.1.5` closes the parent after correcting one stale README claim.
  Planning `.5.2.0` proves the current runtime can execute `specs/user_function_definition.spec`, then splits
  resolve/load `.5.2.1`, automatic spec-defined function parsing `.5.2.2`, full composition `.5.2.3`, and no-drift
  `.5.2.4`. Full composition is complete at 153/153, `.5.2.4` closes parent `.5.2`, exact descriptors `.5.3.1`
  and full trace `.5.3.2` are complete at 155/155, and `.5.3.3` closes parents `.5.3`/`.5`. Corpus planning
  `.6.1.0`, typed segment-kind repair `.6.1.1`, and reusable executor `.6.1.2` are complete; controlled executor
  proof passes 160/160 on both ABIs; ordered core admission `.6.1.3` then locks 40/40 at endpoint 1/1 and raises
  both suites to 161/161. Governed capability/no-drift `.6.1.4` locks the remaining owned 6/6 window, raises both
  suites to 162/162, closes `.6.1`, and activates `.6.2`.
  Generated Lua remains `.8`, and explicit callable literals/bound
  calls remain `.11.7`.
- **Post-parity structured-text program** - ADRs `0034`, `0037`, and `0038` plus `STRUCTURED-TEXT-FORMAT-PROGRAM` map all 91 eligible rows in the Unicode structured-text catalog. Each format's composed `.spec` graph is the sole parser source and is dynamically compiled for immediate use on every backend; host source/caches are derivative only. The catalog becomes requirements evidence for reusable neutral `.spec` evolution: a format-discovered mechanism must reach exact Perl/Rust/Dart/Julia/Lua parity before that format continues. JSON/XML/YAML/HTML/Markdown/RDF foundations are reused; conditional formats use named profiles; text-to-AST stays distinct from evaluation/domain semantics; HTML owns a full WHATWG tokenizer/tree-builder lane; accuracy, Unicode, diagnostics, conformance, separate cold-construction/warm-reuse/parse measurements, and correlated compile/runtime trace with exact emission-only rule filters are required. A separate non-blocking `NATIVE-PARSER-ACCELERATOR` horizon may later derive measured backend-native artifacts, but the dynamic parser remains primary, oracle, and fallback and Perl acceleration is not required. Lua `.8.4` satisfies the full-backend parity prerequisite; readiness leaf `.1` remains pending explicit activation and no format implementation has started.
- **Planned Rust mutation testing** - ADR `0039` and `RUST-MUTATION-TESTING` adopt `cargo-mutants` as an explicit test-strength campaign, never a per-commit/pre-commit/ordinary-local-CI gate. The list-only baseline is 3,333 candidates across 19 files; no mutant has executed and no score is claimed. A safe manual surface and targeted pilot must precede any resource-guarded milestone/release sharding. Every survivor receives a durable disposition and true gaps gain behavior-focused tests; the generated Unicode table is the initial provenance-backed exclusion.
- **Planned backend implementation companions** - ADR `0040` and `BACKEND-COMPANION-BOOKS` retain this book as
  the sole normative source for language semantics, portable behavior, and shared contracts, while planning one
  independently buildable companion for Perl, Rust, Dart, Julia, and Lua. Those optional guides will explain
  user-relevant native setup/APIs/embedding, implementation architecture, diagnostics/trace, generated/native
  artifacts, performance/deployment, troubleshooting, and exact variant limitations. A read-only inventory,
  shared template, cross-links, canonical-owner metadata, and drift checks precede migration; implementation waits
  for current backend parity and no companion scaffold exists yet.
- **Planned write-vivification and explicit receiver mutation** - ADR `0036` and `FUTURE-PARITY-BACKLOG.19`
  reserve a post-current-parity extension. Nested assignments may create only missing containers whose kind is
  unambiguous from the next evaluated segment; reads remain pure, existing wrong-kind values are not coerced, and
  arrays remain dense. `map_leaves!` is the only v1 bang candidate and will atomically rebind a bare named receiver
  after successful original-shape/root-kind traversal. Current nested writes do not autovivify, current parsers do
  not accept bang methods, and `.19.1-.19.7` remain pending neutral/backend/admission work.
  All 13 ordinary harray names close at 103/103 through `.4.3.5.5` on both Lua ABIs. Sorted arrays continue
  through array receivers, count/membership are terminal, and mutation-result/pure-receiver prose is guarded.
  Eager blocks, lazy inline controls, attached/marker if and switch, and attached while close through
  `.4.3.6.3.3`; metadata-governed built-in final blocks/scoped `with` close at 112/112 through `.4.3.6.4`.
  Neutral contract `.16.1`, all five backend implementations through
  Lua `.16.6`, and public/capability admission `.16.7` are complete at 64/0/0 with one recurring
  five-backend/two-Lua-ABI command. Lua callback work is split at `.4.3.6.5.1.0`; reference authored-value repair
  `.1.1` is done, harray execution `.1.2` passes 113/113, and shared root-kind array execution `.5.2` closes at
  114/114. No-drift/dependency routing `.4.3.6.6` closes the parent. Capture/cursor audit `.4.3.7.0` splits six
  executable mechanisms plus no-drift; Unicode input/cursor views and explicit controls `.4.3.7.1` pass 115/115
  on both Lua ABIs. All 16 anonymous capture helpers `.4.3.7.2` then pass 116/116 with byte-safe state and
  character-unit public values; earliest-boundary `.4.3.7.5` passes 117/117. `FUTURE-PARITY-BACKLOG.17` owns the
  seven-helper complete-mark contract and gate hardening; `.17.1-.17.3` align Perl/Rust/Dart/Julia, and Lua
  `.17.4` now passes native/serialized execution at 119/119 on PUC Lua and LuaJIT. Final `.17.5` admits 246 shared
  names and independently checks all 122 public Perl contracts; parent `.17` is complete. Lua `.4.3.7.3` then
  executes the remaining governed named-span and bridge family through that store at 120/120. Placement-
  sensitive `.4.3.7.4` then executes typed post-action marker events at 121/121, and exhaustive capture/cursor
  no-drift `.4.3.7.6` was activated by that earlier slice.
  Implicit child-push side effects are included in the closed Lua array family, but their expression result is not
  yet portable: Perl exposes its host push count and Lua exposes the updated implicit accumulator. Backlog `.5`
  owns normalization; current authoring uses implicit child push as a statement.
- **Punctuation-light zero-argument calls** - ADR 0033 and `FUTURE-PARITY-BACKLOG.16.0` preserve the general
  `callee(args)` grammar while adopting a bounded convergence target: bare standalone `else`, `endif`, `default`,
  `endcase`, `endswitch`, and `next`, plus a final zero-argument receiver segment. The audit found partial existing
  support rather than five-backend parity. Neutral contract `.16.1` now locks six standalone and four receiver
  equivalences, retained value reads, exclusions, arity delegation, and one portable fixture. Calibration `.16.2.0`
  corrected the required-argument example from `drop_front` to `contains` after subtracting the implicit receiver
  slot. Perl `.16.2.1`, Rust `.16.3`, Dart `.16.4`, Julia `.16.5`, and Lua `.16.6` consume the aliases with typed
  AST equivalence, unchanged exclusions, and exact native execution; Rust additionally proves serialized/emitted
  paths, Dart/Julia prove emitted-state reconstruction, and Lua proves public SpecFile JSON reconstruction on both
  ABIs. Rust/Dart/Julia/Lua pre-existing `.contains()` missing-argument outcomes are owned by helper backlog `.5`.
  Lua generated-source preservation remains `.8.1-.8.4`; `.16.7` admits and closes the current syntax. Parenthesis-free `if`/`while`
  condition headers are explicitly outside this lane.
- **Uniform-binding selector retirement is complete** - every construct yields scalar, array, harray, or codeblock; unused expression values are silently discarded; callable signatures govern trailing codeblocks; runtime value type drives dispatch. `FUTURE-PARITY-BACKLOG.12.1` removed spec-facing `array(IDENTIFIER)` / `hash(IDENTIFIER)` namespace, typed-read, and mutation semantics. A boundary-correct inventory found 600 exact forms in 82 tracked specs; neutral contract `.12.1.1` fixes bare mutation, precedence, results, diagnostics, and constructor classification. All five backends execute that contract; migration removed all 600 file-backed occurrences and all 1,356 positive embedded-source occurrences. Perl, Rust, Dart, Julia, and Lua reject exact selectors before execution with the portable diagnostic. Cross-variant `.12.1.8.6` locks those five boundaries and zero runtime selector compatibility in canonical CI. Public admission `.12.1.9` plus backend-README follow-up `.12.1.10` established the discovered guard; it now covers all 57 root/component/mdBook files at zero current examples.
- **Structural, progressive, and staged authoring clarification** - typical `.spec` authoring uses small readable
  zero/one/two-regex rules for coordination, leaves, and entry/exit boundaries; deep recursion belongs in linked
  action-edge OR and blind-call AND structure rather than recursive regexes. Progressive parsing means invoking
  loaded specs over cursor-relative extracted text during a parse; staged parsing means refining selected fields
  after an AST level returns. ADR `0012` and the function-body `body_parse_job` prototype are the current base. ADR
  `0056` now adopts one future immutable source-location algebra across cursor, capture, recursion, segmentation,
  and composition: Unicode-scalar positions, half-open spans, ordered provenance, bounded recognition-only cursor
  transactions, recursive entry/match/exit observations, progress checks, and span-native parser dispatch. It adds
  no current syntax or behavior. General contract/implementation/six-runtime admission remains future work under
  `FUTURE-PARITY-BACKLOG.14.1-.14.8`; ADR `0045` separately retains gap syntax/lifecycle ownership. The EBNF
  recursive-regex and portmap complex-regex walkthrough wording is tracked audit/migration evidence, not the target
  general authoring idiom.
- **Semantic introspection / MCP direction** - ADRs `0049`/`0050` and completed neutral leaf `.10.2` make
  `linkedspec-semantic-model-v1` / `linkedspec-semantic-query-v1` executable before backend behavior. Six fixture
  groups and 20 digest-locked queries cover normalized graph/call/shape/staged/generated/diagnostic/explanation/
  runtime facts, deterministic ids/order/traversal/pages/cost, and structural source privacy; the checker rejects
  81 mutations. ADR `0050` separates staged payload/job/result records from generated artifacts, and descriptors
  remain reusable input rather than the wire model. Perl `.10.3.1-.10.3.6` and Rust `.10.4.1-.10.4.6` each ship
  opaque strict in-memory construction, exact byte/scalar source mapping, clone-safe static/call/staged/generated
  projection, all 19 static queries, typed invocation-local runtime observation for the twentieth answer, and one
  exact 12-role admission consumer. Dart now also has exact private source/static/call/staged/generated projection:
  `.10.5.3.2` completes all 22 calls records / 25 relations with distinct payload/job/result and selected generated
  handler-plan provenance, and `.10.5.3.3` composition-closes that final private surface. Query audit `.10.5.4.0`
  fixes fresh detached normalized projection as the only evaluator authority, reconciles 19 static digests plus 26
  neutral validation boundaries, and splits record/source `.1`, traversal/limits `.2`, public typed/raw-neutral
  `.3`, and closeout `.4`. Typed kernel `.10.5.4.1` now matches nine exact static responses through immutable
  package-private capabilities/list/get/explain/source-privacy behavior. Traversal/limits `.10.5.4.2` adds exact
  directional breadth-first relations, canonical pages, logical budgets/costs, and all 16 successful static
  responses. Public `.10.5.4.3` now exports `capabilities`, typed `query`, and raw-neutral `queryNeutral` through
  one evaluator at all 19 static digests and 26 validation boundaries; `.10.5.4.4` composition-closes that parent
  on committed code. Behavior-free runtime audit `.10.5.5.0` now freezes the post-match slot and successful final-
  result seams, absent-sink/no-query boundary, generated-wrapper exception passthrough, immutable derivation, and
  `.1-.4` dependency order. Typed live capture `.10.5.5.1` now exports immutable v1 slot/result events plus an
  invocation-local callback across direct/loaded/reconstructed/traced/generated-plan engine routes, with exact
  Unicode-scalar positions, input identity, failure identity, and no result/trace/diagnostic drift. Immutable
  observed-index derivation `.10.5.5.2` now validates detached static topology, returns a separate canonical
  execution/event/`observed_as` snapshot, preserves the base index, and matches the twentieth digest. Generated/
  emitted direct and traced propagation `.10.5.5.3` now preserves exact events, outputs, diagnostic events, trace
  bytes, exit omission, and caller callback identity through public helpers and isolated emitted libraries without
  changing v2/format 2. Composition closeout `.10.5.5.4` now closes the runtime-observation parent on committed
  semantic 39/39, adjacent runtime 24/24, complete Dart, and neutral/public proof without promotion. Exact composed
  Dart admission `.10.5.6` is complete through one 12-role consumer. Julia's Unicode prerequisite `.10.6.1` and
  opaque strict source/compiled-or-failed foundation `.10.6.2` are now composition-closed at focused 220 and Julia
  7,762/primary/105 without query, runtime observation, target execution, or semantic promotion. Static planning
  `.10.6.3.0` freezes all five private targets; graph implementation `.10.6.3.1` now retains one recursively
  immutable projection behind the opaque index and deep-equals the exact compiled graph at 12 records, 14
  relations, and seven source references. It scans complete authored members, correlates typed compiled edges and
  lifecycles, excludes compiler-inserted cross-rule parent matchers, retains duplicate/self-indexed slots,
  normalizes Default/And/Single/Pipe repetition, and returns only fresh detached data through a private test seam.
  New 70/focused 290 and Julia 7,832/primary/105 pass without a public projection/query accessor, path or host
  object, second parse, target execution, format change, rollout, or admission movement. Remaining-target leaf
  `.10.6.3.2` now deep-equals privacy text 4/3, privacy identity 4/3, failed 6/4, and runtime-static 7/8. It keeps
  Julia's native failure unchanged beneath projection-only portable normalization and proves repeated-lifecycle
  occurrence identity, no execution/events, generic failure fallback, fresh detached copies, tuple immutability,
  private omission, and host denial. New 99/focused 389 and Julia 7,931/primary/105 pass with 5x2x66, all ten
  Unicode legs, unchanged ledgers, and canonical Rust 78.27s + Dart 1/1 + primary 66x2 + Phase 0 1,031/697s.
  All five private static targets now compose under no-change closeout `.10.6.3.3`: committed focused 389,
  complete Julia 7,931/primary/105, 5x2x66, all ten Unicode legs, unchanged ledgers, and canonical Rust 80.89s +
  Dart 1/1 + primary 66x2 + Phase 0 1,031/653s pass without replacement code. Parent `.10.6.3` is closed without
  promotion. Behavior-free calls/staging/generated `.10.6.4.0` now freezes exact 22 records / 25 relations:
  existing static base 6/6, typed core 18/16, staged/generated completion +4/+9. It maps registry definitions,
  typed function/edge Action AST plus contracts, copied source correlation, staged sidecars, and retained selected
  generated-v2 plan without execution or trace. Implementation is split as private core `.1`, completion `.2`,
  and no-change closeout `.3`; query/runtime/admission remain `.5-.7` and no promotion occurs in planning. Plan
  signoff passes focused 389, Julia 7,931/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, KM 684/5,231,
  and canonical Rust 77.84s + Dart 1/1 + primary 66x2 + Phase 0 1,031/625s.
  Typed core `.10.6.4.1` now privately implements exact non-staged 18/16 from accepted typed registry/function/
  edge Action AST and contracts. It locks authored order/source, nested calls, user-before-helper resolution,
  fixed/rest signatures, conservative shapes, binding/decision relations, recursive freeze, detached copies, and
  host/no-execution fences. Quote/regex-aware bounded scanning maps typed preorder to exact Unicode-safe source.
  New 79/focused 468, Julia 8,010/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust
  77.41s + Dart 1/1 + primary 66x2 + Phase 0 1,031/622s pass. mdBook/KM 685/5,252 and exact 1,618,660-KiB
  cleanup preserving 517 Pgen artifacts pass. Staged/generated `.10.6.4.2` now completes the same private graph at
  exact 22/25. It validates native function payload/job/body-result correlation, emits three deliberately neutral
  staged records with all directed provenance, validates the retained generated-v2 contract/identity/full order/
  unique selected row, and emits only the selected handler-plan family. Native sidecars, body AST, generated
  implementation, paths, execution, trace, and sinks remain private. New 62/focused 530, Julia
  8,072/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 76.95s + Dart 1/1 + primary
  66x2 + Phase 0 1,031/622s pass. Closeout `.3` now recomposes all six committed semantic suites at focused 530,
  Julia 8,072/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 77.68s + Dart 1/1 +
  primary 66x2 + Phase 0 1,031/622s without replacement code. Parent `.10.6.4` is composition-closed without
  public query, observation, format, rollout, or admission movement. Behavior-free query audit `.10.6.5.0` now
  freezes one fresh detached private projection as the evaluator's sole authority, all 19 static hashes and 26
  malformed raw-neutral boundaries, exact immutable typed/raw-neutral vocabulary, Julia's explicit `Bool` versus
  `Integer` validation fence, and private record/source `.1` / traversal-limit `.2` / public completion `.3` /
  no-change closeout `.4`. Runtime events remain `.10.6.6`; the audit changes no behavior or promotion.
  Full audit proof passes neutral 6/20/81, focused Julia 530 plus detached 22/25/10, Julia 8,072/primary/105,
  primary 5x2x66, ten Unicode legs, unchanged ledgers, canonical Rust/Dart admission + primary 66x2 + Phase 0
  1,031/655s, book/KM 687/5,277, doctrines, and exact 1,812,240-KiB cleanup preserving 517 Pgen artifacts.
  Private kernel `.10.6.5.1` now defines the complete immutable query vocabulary and evaluates nine exact static
  capabilities/list/get/explain/source cases behind an unexported seam. It consumes exactly one fresh detached
  projection clone and cannot reach retained source/compiler/staged/AST/IR/generated/runtime/trace/path/host state.
  Tuple-backed object/array values remain recursively immutable and every JSON conversion is fresh. New
  100/focused 630, Julia 8,172/primary/105, primary 5x2x66, ten Unicode legs, and unchanged governance pass.
  At the `.1` boundary, traversal/pages/budgets/costs and ten remaining static hashes were assigned to `.2`; raw
  validation and public exposure stayed `.3`. Canonical Rust 80.95s + Dart 1/1 + primary 66x2 + Phase 0
  1,031/662s, book/KM 688/5,287, doctrines, and
  exact 1,613,088-KiB cleanup preserving 517 Pgen artifacts pass.
  Private completion `.10.6.5.2` now adds exact outgoing/incoming/both filter-constrained breadth-first relations,
  canonical after-id pages, record/relation/depth budgets, deterministic incomplete prefixes, and logical costs
  over that same detached evaluator. It deduplicates relation ids and visited frontier records, restores canonical
  output order, gives relation ceilings diagnostic precedence over depth, and reserves an explain decision's record
  budget unit. The remaining ten and therefore all 19 static hashes pass at new 118/focused 748 and complete Julia
  8,290/primary/105. At that historical boundary, query values/functions and raw validation/public exposure stayed
  `.3`; runtime events stay `.10.6.6`. Full primary 5x2x66, ten Unicode legs, unchanged ledgers, canonical Rust 82.53s +
  Dart 1/1 + primary 66x2 + Phase 0 1,031/647s, book/KM 689/5,298, doctrines, and exact 1,613,224-KiB cleanup
  preserving 517 Pgen artifacts pass.
  Public completion `.10.6.5.3` now exports the immutable query vocabulary plus `semantic_capabilities`, typed
  `semantic_query`, and raw-neutral `semantic_query_neutral`. Both paths share one exact validator/evaluator and
  one detached materialization. They match all 19 static hashes, while the raw path accepts dictionaries or direct
  `JSON3.Object` input and locks all 26 malformed envelopes including Julia Boolean/numeric separation. New
  315/focused 1,063 and complete Julia 8,605/primary/105 pass with clone/privacy/non-execution/host-denial proof.
  Runtime observation remains `.10.6.6`, rollout/admission stay unchanged, and no-change closeout `.10.6.5.4` is
  dependency-ordered after the clean public commit. Full primary 5x2x66, ten Unicode legs, canonical Rust 79.96s + Dart 1/1 + primary
  66x2 + Phase 0 1,031/634s, mdBook/KM 690/5,307, doctrines, and exact 1,613,820-KiB cleanup preserving all 517
  Pgen artifacts pass.
  No-change `.10.6.5.4` now recomposes all nine committed semantic suites at focused 1,063, reruns complete Julia
  8,605/primary/105, primary 5x2x66, all ten Unicode legs, and every unchanged ledger, and closes parent `.10.6.5`
  without production/replacement-test/API/format/runtime/promotion change. Runtime authority planning begins in
  `.10.6.6.0` only after the closeout commit is clean. Canonical Rust 79.55s + Dart 1/1 + primary 66x2 + Phase 0
  1,031/635s, book/KM 690/5,307, doctrines, and exact 1,613,872-KiB cleanup preserving 517 Pgen artifacts pass.
  Behavior-free runtime audit `.10.6.6.0` now freezes Julia's exact accepted-slot and successful-result capture
  seams, the still-old pre-effect context-cursor hazard, separate trace/diagnostic authority, no-sink allocation/
  hashing fence, generated broad-catch callback-identity pass-through, detached static derivation, twentieth digest,
  and `.1-.4` dependency order. Direct, loaded, reconstructed, generated-plan, fresh emitted, and traced probes
  converge on the same runtime seams. The audit changes no production/test/API/format/runtime behavior or semantic
  rollout/admission; typed direct capture `.10.6.6.1` follows only after its clean commit.
  Typed direct capture `.10.6.6.1` now exports immutable v1 regex-slot/final-result events and threads an optional
  invocation-local sink through runtime parse/execute, traced convenience, loaded/reconstructed engines, and
  validated generated-plan direct/traced helpers. Accepted-slot positions use the matched end converted to a
  Unicode-scalar offset; final success uses the completed result cursor and exact UTF-8 input SHA-256. With no
  sink, capture allocates and hashes nothing; callback failures retain exact identity, failure/exit omit final results, and result/
  cursor/trace/diagnostic values remain unchanged. New 66/focused 1,129 and complete Julia 8,671/primary/105 pass.
  Immutable derivation `.10.6.6.2` now exports `with_execution_observation`, validates the typed sequence solely
  against detached static rule/edge/slot evidence, and creates a fresh `has_execution=true` snapshot with canonical
  execution/event/`observed_as` records. Typed/raw-neutral query matches the twentieth digest; malformed and
  unsupported topology rejects without execution or host authority. New 157/focused 1,286 and complete Julia
  8,828/primary/105 pass. Generated/emitted propagation `.10.6.6.3` now adds that same sink to fresh direct/traced
  wrappers. Public helpers, a freshly included module, and an isolated host preserve canonical events/twentieth
  digest, exact callback identity, exit omission, results, diagnostics, and trace bytes at new 51/focused 1,337 and
  complete Julia 8,879/primary/105. Generated source remains deterministic v2/format 2 with the unchanged
  `{label, family}` plan. Full primary 5x2x66, ten Unicode legs, canonical Rust 79.78s + Dart 1/1 + primary 66x2
  + Phase 0 1,031/637s, book/KM 694/5,348, doctrines, and exact 1,749,080-KiB cleanup preserving 517 Pgen
  artifacts pass. No-change `.10.6.6.4` now recomposes the twelve committed owners at focused 1,337 plus complete
  Julia/matrix/Unicode/canonical proof and closes `.10.6.6` without production/replacement-test/API/format/runtime
  or promotion change; rollout/admission stay 4/9 and 3/6, and exact admission `.10.6.7` remains pending.
  Queries cannot compile, execute, enable trace, read paths, or expose host IR. All six native runtime targets are
  now admitted and recurring proof is complete at rollout 7/9, native admission 6/6, and 105 rejected mutations.
  ADR `0054` makes MCP one exact contract with native Perl, Rust, Dart, Julia, and Lua server
  implementations; the same Lua source is admitted separately on PUC Lua and LuaJIT. ADR `0055` selects stable
  modern MCP `2026-07-28` over stdio, with per-request metadata, mandatory discovery, explicit handles, two
  read-only tools, and no legacy initialization/session/ping. MCP owns no semantic or filesystem behavior.
  Machine leaf `.10.9.1.1` pins one shared schema/payload/corpus/canonical-frame bundle and deterministic
  materializer. Independent leaf `.10.9.1.2` now proves 28 accepted/seven rejected frames, raw and stateful
  outcomes, and 68 mutations without importing the materializer. No-change `.10.9.1.3` now requires both programs
  in canonical CI, runs materialization before independent validation, rejects omission/order drift, and closes
  the neutral contract. ADR `0057` and behavior-free Perl audit `.10.9.2.0` now freeze an in-process
  `LinkedSpec::MCPServer`, generated filesystem-free contract binding, strict duplicate-safe wire, OS CSPRNG/
  monotonic handle lifecycle, authorization/policy seams, and `.1-.4` implementation/admission order. Perl
  registry/decoded dispatch `.10.9.2.1` completely implements and verifies the generated binding, private schema
  runtime, secure handle lifecycle, exact tools, and cancellation. Strict stdio/lifecycle `.10.9.2.2` now adds
  bounded duplicate-safe frames, canonical output, cancellation through flush, sanitized logging, and exact
  EOF/I/O cleanup; canonical signoff is complete. Exact Perl admission `.10.9.2.3` now composes one twelve-role
  consumer and a separate implementation/admission ledger at 1/5 implementations + 1/6 runtimes with rollout
  pending and 28 rejected mutations; focused and canonical proof are green. No-change Perl closeout `.10.9.2.4`
  is complete from clean `28f84826`; focused and canonical committed-owner recomposition close parent `.10.9.2`
  before later native servers `.10.9.3-.7`. Completed behavior-free Rust preflight `.10.9.3.0` and ADR `0058`
  freeze the Rust seams. `.10.9.3.1` now provides shared verified-bundle generation, a formatter-stable embedded
  Rust binding, frozen schema runtime, and public decoded `linkedspec-runtime::McpServer` over caller-owned
  `Arc<SemanticIndex>` values. Its OS entropy, digest-only authorization, monotonic expiry, bounded capacity,
  lowering-only policy, exact native payloads, panic sanitation, cancellation, and release boundaries pass focused
  corpus proof. Strict stdio `.10.9.3.2` adds bounded duplicate-safe borrowed-stream framing, canonical emission,
  cancellation through flush, and exact EOF/I/O cleanup. Exact twelve-role admission `.10.9.3.3` now advances
  only Rust to 2/5 implementations + 2/6 runtimes, keeps shared rollout pending, and rejects 39 mutations;
  no-change `.10.9.3.4` recomposes the committed owners under focused/canonical proof and closes parent `.10.9.3`.
  Dart `.10.9.4` is next after the clean closeout commit. Any future aggregator or legacy adapter is separately
  owned after `.10.10` and may only route/translate transport.

  ADR `0051` and Rust prerequisite `.10.4.0.2` pin rule labels to Unicode 17.0.0 `XID_Continue` at every position
  with exact case- and normalization-sensitive scalar identity. Dart audit `.10.5.0` proves its typed compiler,
  ActionIR, staged sidecars, diagnostics, generated-v2 plan, and runtime seams are reusable, while exact source
  mapping, normalized projection/query, and typed observation are new adapter work. It also finds that current
  host-`\w` declarations reject `Töp`, action/blind references silently truncate it to `T`, bare references remain
  raw, and external invalid labels bypass validation. Shared `.10.5.0.1.0-.1` now generate/guard one pinned class,
  consume it at all 12 first-authoritative `specs/spec.spec` label sites, and make Dart directly execute current
  lifecycle/bare-edge forms. Corpus freshness `.10.5.0.1.2` now keeps all four `spec_spec_*` inputs byte-identical
  to canonical source and composes five-backend current-grammar proof. Dart `.10.5.0.2.0-.1` generate and consume
  the native classifier/scanner; `.10.5.0.2.2` proves all positive/distinct identities through compiled,
  generated, reconstructed, emitted, selector, diagnostic, trace, loader, and command routes. `.10.5.0.2.3`
  exhausts all eight negative fixtures across external AST/source/no-prefix/primary routes and locks unrelated
  identifier grammars. Composed `.4` passes complete Dart and canonical signoff and closes the prerequisite at
  unchanged then-current semantic rollout 3/9 and admission 2/6. Source/static/calls/query/runtime/admission
  subsequently complete through `.10.5.6`; the prerequisite itself did not promote a ledger.
  Governance follow-up `.22` separately tracks a stable home for immutable cross-contract status markers.
- **Callable codeblock design** - ADR 0031 and completed `.11.1` supersede the narrow abstraction chosen by the
  closed `SPEC-FORMAT-TERSE.14` MVP. Callable literals use `{|args| body }` (`{|| body }` for zero params), may use
  final `...rest`, and execute later through `cb(args)` in dynamic caller context without lexical capture. The
  exact `{|` prefix distinguishes them from `{}`/`{ key : value }` harrays and eager `{ statements }` block
  expressions. `with` remains an ordinary block-taking helper. Neutral schema/fixtures `.11.2` are adopted and
  checked. Perl now preserves the typed record and executes `cb(args)` through dynamic caller bindings: arguments
  evaluate before copied fixed/rest parameters bind, prior parameter values restore, nonparameter mutation stays
  visible, return/chaining/discard work, and typed arity/keyword/not-callable/recursion failures are exposed through
  runtime context. ADR 0032 declares the final contextual slot as `name: codeblock`; it has no nested argument
  list because explicit `{|params| ...}` values own their signatures. Perl `.11.3.3.2` now preserves that metadata
  and normalizes equivalent attached/parenthesized helper, typed user-function, and receiver contextual forms;
  `.11.3.4` closes Perl diagnostics/docs/no-drift; cross-backend behavior remains future after active `.12.1`
  removes spec-facing aggregate selectors.
- **Dart backend parity** - `DART-BACKEND-PARITY` is complete only for the scoped interpreter-first Dart milestone. Its strategy is
  interpreter-first over typed `.spec` and helper/action AST plus compiled-spec state, with generated Dart source
  deferred to a future split source-emitter lane rather than required for the current conformance claim. The repo now has a `dart/` backend package with a Dart-specific CLI,
  manifest/corpus IO validation, source-level AST/data types with JSON round-trip coverage, a core `.spec` rule
  parser with shipped-spec plus rule-only corpus parser coverage, frontend validation/strict-syntax checks,
  spec-returned function-definition projection, typed ActionIR helper/action parsing, ActionIR contract
  resolution, a user-function registry seam, a compiled-spec state model, runtime matching primitives, and the
  first runtime rule interpreter. Dart ActionIR parsing covers calls, literals, access, shape literals,
  assignments, block values, attached controls, receiver chains, trailing blocks, and standalone value-drop
  statements; the resolver records current canonical helper/control contracts and generic diagnostics over those
  typed nodes. With a `UserFunctionRegistry`, exact-arity user calls classify before helper fallback while
  wrong-arity registered calls report user-function arity diagnostics. `compileSpec(...)` builds ordered
  `CompiledSpec` / `CompiledRule` state, structured dependency-regex data, mode metadata, lifecycle/action
  `ActionBlock` payloads, function projection, and descriptor-shaped `spec` / `functions` /
  `dependency_regex_map` / `meta` JSON. Runtime matching supports seek/consume modes, stable alternative identity,
  capture and named-capture records, char-offset projections, entry/local match registers, cursor state, and
  zero-progress detection. `LinkedSpecRuntimeEngine` now executes default/AND/OR/repetition rule families with
  action-edge and blind-call child dispatch, lifecycle blocks, explicit returns, `retv`, accumulators, bounded
  repetition, zero-progress cutoffs, and recursion cutoffs. Its evaluator now also preserves
  scalar/array/hash/null/boolean/number shapes through assignment and wrapper snapshots, supports `hash(...)`,
  `set(hash(...), ...)`, hash-index mutation, nested reads, non-numeric map keys, aggregate `copy(...)`,
  named/map/position capture helpers, string/scalar helpers, explicit `str_*` lexical comparisons, numeric helpers,
  numeric aliases/symbol callees, compatible string/number receiver chains, array helper family breadth, regex
  split/filter bridges, delimiter-first `join_values`, array numeric reducers, updated-value array end mutations,
  hash helper family breadth, hash receiver chains, statement/value mutation boundaries, nested value-path
  assignment with no-autovivification failure behavior, explicit flat-style hash splicing, expression-valued
  blocks with block-local return, attached and inline structured controls,
  helper/receiver `with` trailing blocks, hash/array tree traversal receiver callbacks, `save_cursor()` /
  `restore_cursor()` stack semantics, `rewind_match_start()` / `rewind_entry_start()` anchor rewinds, and
  char-based cursor/input helpers, `capture_until_boundary(rule[, ...])` non-consuming structural boundary
  capture. Runtime failures now expose structured Dart `RuntimeDiagnostic` payloads through
  `RuntimeInterpreterException.diagnostic` with stable owner/stage/rule/source attribution. Dart also has ordered
  trace levels, `LinkedSpecTraceConfig`, event/scope primitives, stdout/routed-file/mirror sinks with
  reset/truncate behavior, and traced runtime entrypoints that preserve parse output while emitting a parse-scope
  event. Dart runtime tracing now also emits rule scopes, regex match/no-match decisions, action/blind child
  dispatch decisions, lifecycle block marks, cursor-control marks, recursion-cutoff decisions, and
  `capture_until_boundary(...)` source-boundary marks. The diagnostics/trace no-drift sweep is closed. Dart now
  also has the minimal staged parser registry for function-body parse jobs: `actionir-body.spec` resolves to the
  built-in `action_block` provider, dispatch records carry the staged cache key and compiled parser shape, queued
  jobs execute in stable order, and the returned `action_block` JSON is stitched into `body_ast`. Dart registered
  exact-arity user-function calls now execute before helper fallback with eager caller-side arguments, fresh
  function-local scalar/array/hash stores, final-expression or local-return results, receiver-chain continuation,
  standalone discard, and direct/mutual recursion diagnostics. Dart now also preserves neutral staged function
  descriptor shapes through parsed functions, compiled registry jobs, descriptor `body_payload`,
  `body_parse_job`, stitched `body_ast`, function-order metadata, and runtime output. Dart now also treats empty
  array/hash returns as successful non-null rule matches, uses child-rule match bits for blind dispatch, and
  executes marker-form `if(...)` / `elseif(...)` / `else()` / `endif()` statement chains as grouped branches. It
  also preserves assignment expressions inside helper arguments, supports plain fallback values in inline
  `if(...)`, evaluates numeric aggregate reducers over bare arrays, and follows scalar-held list/map readback for
  `name`, `name`, and `copy(name)`. Append-style mutations now update scalar-held lists before
  aggregate fallback, and `call(...)` refreshes the runtime `retv` channel. The full checked-in 105-fixture corpus
  passes through Dart execute mode. The top-level `fn` corpus
  function fixtures obtain `function_definition` nodes from `specs/user_function_definition.spec` and staged body
  projection rather than a Dart raw scanner. The final shipped-spec/parser-smoke window is split after a 2/31
  diagnostic run and is now 31/31 green. The basic regex-dialect bridge, helper/action bridge,
  recursive/default-mode bridge, portmap result-shape bridge, hlink delimiter/capture bridge, and helper
  mutation/text-normalization bridge are done, the legacy accumulator bridge closes `regdef`, and the public-parser
  leading-trivia bridge closes `ds_vhistory`; bounded structural matchers close the exact shipped PCRE structural
  forms. The green corpus gate is wired into a focused Dart local gate and optional local-CI path. Generated Dart
  source is explicitly deferred to a future source-emitter lane with scaffold, family-plan, direct-family execution,
  and curated-corpus proof prerequisites. Dart's backend-local corpus CLI implementation is complete:
  `bin/linkedspec_dart.dart` owns help text plus a `corpus` command that validates or executes the manifest-backed
  corpus through Dart parse/compile/runtime, while `bin/corpus_runner.dart` remains a compatibility wrapper. The
  strict-interface audit has since shown this is not yet the shared parser CLI contract. No active Dart frontier
  remains in its original scoped tree; global `.1.5.3`, `.1.6`, and `.3` own complete CLI/capability/codegen parity.
- **Julia backend parity** - `JULIA-BACKEND-PARITY` is the active second future-backend lane. It starts from the
  Dart lesson: interpreter-first over typed `.spec` and helper/action AST plus compiled-spec state, with generated
  Julia source left as a later proof decision. `JULIA-BACKEND-PARITY.1.1` verified Homebrew Julia 1.12.6 against the
  official current stable release. `JULIA-BACKEND-PARITY.1.2` created the repo-owned `julia/` package scaffold:
  package metadata, committed manifest, `LinkedSpecJulia` module, Julia-specific CLI, corpus-runner stub, README
  commands, and smoke tests. `JULIA-BACKEND-PARITY.1.3` adds JSON3-backed manifest IO and drift/file guards over
  the checked-in 99-fixture corpus while `--execute` still reports not implemented. `JULIA-BACKEND-PARITY.2.1`
  adds source AST/data types and JSON round-trip coverage for spec files, functions, source spans, staged parse
  jobs, rule modes, body elements, edges, and fluent calls. `JULIA-BACKEND-PARITY.2.2` adds `parse_spec(...)` for
  core rule paragraphs: headers/modes, regex slots, lifecycle blocks, action/blind-call edges, fluent
  continuations, markers, comments, and block boundaries. `JULIA-BACKEND-PARITY.2.3` adds `validate_spec(...)`
  for top-rule presence, duplicate labels/functions, function registry collisions, raw fallback rejection, edge
  consistency, undefined references, regex-slot bounds, regex structure, and strict unused-rule behavior.
  `JULIA-BACKEND-PARITY.2.4` consumes the neutral `function_definition` / `function_definition_error` node shape
  owned by `specs/user_function_definition.spec`, validates staged sidecars, strips function spans before rule
  parsing, and keeps direct `parse_spec(...)` rule-only. `JULIA-BACKEND-PARITY.3.1` adds typed ActionIR parsing
  for calls, literals, variables, direct/nested access, shape literals, assignments, block values, structured
  controls, receiver chains, trailing blocks, standalone value-drop statements, and raw fallback nodes.
  `JULIA-BACKEND-PARITY.3.2` adds `resolve_action_block_contracts(...)`,
  `resolve_action_statement_contracts(...)`, `resolve_action_expression_contracts(...)`,
  `canonical_action_helper_name(...)`, and `is_known_action_ir_call_name(...)` for canonical ActionIR
  helper/control contract records and generic unknown-helper/raw diagnostics. `JULIA-BACKEND-PARITY.3.3` adds
  `UserFunctionRegistry`, staged body parse-job queue projection, immutable `body_ast` stitching, and registry-aware
  exact-arity user-call classification before helper fallback. `JULIA-BACKEND-PARITY.3.4` adds
  `compile_spec(...)`, `CompiledSpec`, `CompiledRule`, `CompiledDependencyRegexState`, and
  `CompiledDescriptorState` for ordered compiled rules, dependency refs, dependency-regex rows, mode metadata,
  lifecycle/action payload ASTs with registry-aware contracts, function registry projection, and descriptor-shaped
  JSON. `JULIA-BACKEND-PARITY.4.1` adds stable native-PCRE alternatives, seek/consume selection, full and compact
  captures, named captures, character and line/column projection, cursor/capture anchors, separate entry/local
  match registers, and zero-progress detection. `JULIA-BACKEND-PARITY.4.2` adds first compiled-rule execution for
  default/AND/OR/repetition modes, lifecycle flow/events, action/blind children, `retv`, explicit returns, narrow
  accumulators/capture reads, output projection, repetition bounds, zero-progress termination, and recursion
  cutoffs. `JULIA-BACKEND-PARITY.4.3.0` splits the broader evaluator by mechanism: core stores/captures,
  string/numeric helpers, arrays, hashes, value/control/block/callback execution, and no-drift closeout.
  `JULIA-BACKEND-PARITY.4.3.1` adds scalar/array/hash stores, bare and typed snapshots, structural
  assignments/access, final checked no-autovivification nested writes, and entry/local capture maps and positions.
  `JULIA-BACKEND-PARITY.4.3.2` adds current string/scalar and numeric helpers, retained regex flags, word and
  symbol aliases, invalid-input boundaries, and compatible receiver chains through one canonical dispatcher.
  `JULIA-BACKEND-PARITY.4.3.3` adds copied array pipelines, string/regex/split bridges, flattening and numeric
  terminals, typed split replacement, and updated-value named/scalar-held end mutations.
  `JULIA-BACKEND-PARITY.4.3.4` adds copied hash views and pure transformations, compatible receiver chains,
  statement-only named set-key mutation, direct hash-index assignment, base/overlay-aware merge resolution, and
  explicit flat-style splicing while preserving ordinary nested maps.
  `JULIA-BACKEND-PARITY.4.3.5` adds expression-valued blocks with local returns, attached and marker controls,
  lazy inline branches, deterministic while guards, immediate helper/receiver with-blocks, and scoped hash/array
  walk/map/reduce callbacks with lazy non-aggregate failure.
  `JULIA-BACKEND-PARITY.4.3.6` confirms helper/value no-drift at 567 assertions without a runtime correction;
  package status remains `runtime-value-control-tree`, and central helper-catalog examples use semicolons only as
  same-line separators.
  `JULIA-BACKEND-PARITY.4.4` adds explicit LIFO cursor save/restore, entry/local anchor rewinds, synchronized
  live/register cursor updates, character-based cursor/input helpers, and earliest usable non-consuming
  named-rule boundary capture with EOF and unresolved-rule behavior.
  `JULIA-BACKEND-PARITY.4.5.0` splits diagnostics/trace into structured diagnostics, trace controls/events/sinks,
  runtime instrumentation, and no-drift closeout before implementation code.
  `JULIA-BACKEND-PARITY.4.5.1` exports neutral-field structured runtime diagnostics on exceptions, preserves
  optional spec identity and child rule/handler attribution, and leaves successful parse output unchanged.
  `JULIA-BACKEND-PARITY.4.5.2` adds ordered trace levels, environment/config controls, structured events/scopes/
  decisions/logs/dumps, stdout/route/mirror sinks with reset, and output-preserving traced runtime entrypoints.
  `Pkg.instantiate()`, `Pkg.test()`, CLI help/status, and corpus validation commands pass with a writable depot.
  `JULIA-BACKEND-PARITY.4.5.3` adds rule scopes, regex decisions, action/blind child dispatch, lifecycle marks,
  recursion cutoffs, cursor transitions, and source-boundary events while preserving untraced output. The full
  suite passes with 631 assertions and package status is `runtime-trace-events`. `.4.5.4` closes diagnostics/trace
  no-drift without a source correction. `.5.1` adds deterministic built-in ActionIR-body registry dispatch,
  portable cache/compiled/result records, immutable JSON `body_ast` stitching, and a composed staged shell API.
  `.5.2` resolves registered exact-arity functions before helper fallback, evaluates arguments in caller scope,
  executes cached ActionIR bodies with fresh scalar/array/hash stores, restores caller stores, returns final
  expressions or local-return payloads, composes receiver chains, discards standalone results, and diagnoses
  direct/mutual recursion. `.5.3` then locks neutral function payload provenance, normalized parse jobs, stitched
  ActionIR bodies, and descriptor function order/count through the same executable compiled state. `.6.1` now adds
  controlled library corpus execution with manifest-to-runtime composition, one-level wrapped structural output
  comparison, optional trace lines, structured diagnostic retention, and all-fixture reporting. The full suite
  passes with 715 assertions and package status `runtime-controlled-corpus` at that boundary. `.6.2.0` splits the
  rollout, and `.6.2.1` adds ordered named/offset/limit selection plus bounded runner PASS/FAIL reporting. `.6.2.2`
  proves starter fixtures 0–39 green at 40/40 without production or fixture changes. `.6.2.3` proves non-function
  windows 40–56, 58–59, and 62–67 green at 25/25 unchanged and routes offsets 57, 60, and 61 to `.6.2.5`. Full
  tests pass with 757 assertions and status `runtime-corpus-middle` at that boundary. `.6.2.4.0` measures and
  splits shipped-spec/parser-smoke fixtures 68–98 at 10/31. `.6.2.4.1` adds the complete direct anonymous capture
  family, closes three hlink delimiter cases, and routes EBNF logging to structural output. Full tests pass with
  766 assertions and status `runtime-corpus-capture-boundaries` at that boundary. `.6.2.4.2.1` adds eager logical
  helpers, closes three portmap cases plus tablegrep, and routes portmap constant's helper-regex `o` flag residual.
  `.6.2.4.2.3` then centralizes helper regex flags and closes portmap constant. `.6.2.4.2.2` adds trace-routed,
  parse-result-neutral diagnostic output and advances simenv/history beyond unsupported `print`. `.6.2.4.3`
  scopes explicit aggregate resets per recursive rule invocation and closes all three recursive top-rule cases.
  `.6.2.4.4` adds action-edge child-push result reuse/indexing, closes all four spec.spec smokes, and routes EBNF
  quote-only statement mutation. `.6.2.4.5.1` adds immediate explicit/default `exit_now(...)` termination and
  structured runtime attribution, advancing simenv to its earlier statement-form scalar-mutation prerequisite.
  `.6.2.4.5.2` then adds statement-context scalar regex mutation, closes both EBNF, both lib_reader, and simenv,
  and preserves pure numeric slicing. `.6.2.4.5.3` then mirrors public-parser leading blank/comment skipping and
  closes history without weakening indexed reads. `.6.2.4.6` adds one permanent full-window regression over
  offsets 68–98: 31/31 exact outputs with stable endpoints and zero failures. `.6.2.5` then executes the checked-in
  user-function definition spec over top-level `fn` source, normalizes its neutral nodes, and reuses existing staged
  body parsing. All three routed fixtures pass. `.6.3` then runs the complete validated manifest as one ordered
  library gate and enables unbounded CLI execution; both are 99/99 green with exact outputs. Full tests pass with
  840 assertions and status `runtime-corpus-full`. `.6.4` has since added focused optional-SDK verification, and
  `.7.1` has closed public commands, native examples, status, and limitation alignment. `.7.2` has since deferred
  the separate generated-source proof to `FUTURE-PARITY-BACKLOG.3`. `.7.3.0` split strict user-facing parity after proving current CLI drift;
  `.7.3.1` ratifies ADR `0023` and cross-backend routing. `.7.3.2.0` has since split Julia CLI work,
  `.7.3.2.1` closes optional shared-emitter trace coverage, and `.7.3.2.2` closes exact options, subcommand/
  positional rejection, named resolution, and source/input loading. `.7.3.2.3` now closes native rule/function
  primary execution and recursively key-sorted direct JSON. `.7.3.2.4` now closes phase-ordered failures, stable
  stderr/exit, and stdout/route/mirror/file/reset/emoji behavior with 75 focused assertions; 1,023 package
  assertions and 99/99 pass. `.7.3.2.5` now adds nine direct process families and focused-gate delegation; status
  is `runtime-corpus-primary-cli`, and `.7.3.3` closes honest local no-drift. The later governed current-surface
  gate was 239 names and 105/105 exact fixtures across all four corpus variants. Audit `.17.0` then showed that
  seven additional helpers advertised by the current named-mark reference are outside those inventories and
  corpus fixtures; `.17.1` aligns Perl/Rust, `.17.2` aligns Dart, `.17.3` aligns Julia through
  native/generated/CLI routes, and Lua `.17.4` passes native/serialized execution at 119/119 on PUC Lua and LuaJIT.
  `.17.5` admits those helpers at 246 shared names and independently checks all 122 public Perl contracts. Public
  generated source remains
  deferred to `.3`; global CLI identity `.1.5` and language-surface `.1.6.1` are closed, while remaining outward
  API capability leaves under `.1.6` still block a complete Julia capability-parity claim.
- **Non-current helper code purge** - `NONCURRENT-HELPER-CODE-PURGE` is closed. Perl source cleanup, Rust source cleanup, active test/tool/generated fixture and checked-in `.spec` migration, and final no-drift scans are complete. Retired helper-looking calls use generic unknown-helper fallback behavior, active generic-unknown-helper tests use invented helper names, and active helper-call/label/tag scans are clean.
- **Generated-source convergence** — closed for Perl, Rust, Dart, and Julia when the census reached 60/0/0; punctuation-light admission later raised the four-backend census to 64/0/0, and Lua `.8.4` now makes the broader live census five-backend 80/0/0. The interpreter oracle remains primary. All five backends pass the shared contract-v1 semantic capability ledger, while current Perl, Rust, Dart, Julia, and Lua artifacts identify generated-source v2 for rule-local cursor reconstruction. Rust's strict recurring classifier compiles/runs all 105 generated fixtures. Dart, Julia, and Lua each have exact ten-family routing, four plan rejections, portable trace roles, isolated all-family proof, and contract-sourced interpreter-first 8/105 host admission; Lua runs fresh PUC Lua and LuaJIT hosts, derives cursor policy without serializing it, rejects stale v1 before payload reconstruction, and preserves exact v1/v2/v3 callable state. Host-source bytes may differ; observations may not.
- **Lifecycle-family audit** — verified complete (2026-06-14). All 7 lifecycle markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`) have full semicolon-light structured authoring coverage. Newlines separate top-level helper statements; a semicolon separates adjacent statements on one physical line and is not required after the last statement. No lifecycle-specific semantic gaps found.
- **Terse `.spec` format evolution** — the active language-evolution track now supports auto-existing working variables, canonical helper renames (`set`, `cat`, `copy`), scalar/array/hash mutation operators, typed primitive literals, newline-or-semicolon statement separators, direct nested access such as `payload["children"][0]["name"]`, nested value-path assignment such as `payload["children"][0]["name"] = value`, attached-block `if`/`when`/`switch`/`while` control flow, inline value `if`/`switch` in `return(...)`, assignment RHS, and fluent `.return(...)`, deep pure-helper composition, array receiver-dot value chains such as `items.sorted().drop_front(2).first()` and `items.uniq().join_values(",")`, hash receiver-dot value chains such as `meta.set_key("stage", "normalized").sorted_keys().join_values(",")`, string receiver-dot value chains such as `raw.trim().lowercase().replace_substr("-", "_")` and `raw.trim().split("-").trim_each().join_values("|")`, number receiver-dot value chains such as `score.abs().ceil().add(2).clamp(0, 10)` and `count(parts).gt(0)`, function-style numeric aliases such as `add(2, mul(3, 4))` and `gt(count(parts), 0)`, arithmetic symbol callees such as `+(2, *(3,4))`, comparison symbol callees such as `>(count(parts), 0)` and `==("2", "2")`, explicit string comparison helpers such as `str_eq(trim(kind), "word")` and `str_gt("2", "10")`, scalar assignment value expressions such as `return(name = "ok")`, `return(=(other, "ok"))`, and `=(raw, " text ").trim()`, aggregate assignment value expressions such as `return(items = [value])`, `return(set(meta, { key : value }))`, and `=(items, [value]).count()`, mutation assignment value expressions such as `return(items += value)`, `return(meta[key] = value)`, `(items += value).count()`, and `(meta[key] = value).count_keys()`, expression-valued block receivers such as `{ [3, 1, 2] }.sorted().join_values(",")`, `{ " a-b " }.trim().split("-").count()`, `{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`, helper-function form and receiver-method form trailing block arguments on Perl and Rust such as `with(value) { return(cat(value, "!")) }` and `" a-b ".trim().with() { return(value.split("-")) }.count()`, hash-tree receiver block traversal methods such as `tree.map_leaves() { return(cat(join_values("/", path), "=", value)) }`, `tree.walk_leaves() { paths += join_values("/", path) }`, and `tree.reduce_leaves(0) { return(acc.add(1)) }`, array-tree receiver block traversal methods such as `items.map_leaves() { return(cat(join_values("/", path), "=", value)) }`, `items.walk_leaves() { paths += join_values("/", path) }`, and `items.reduce_leaves(0) { return(acc.add(1)) }`, bare aggregate working-variable snapshots in supported hash- and array-consuming helper slots such as `merge_hash(copy(base), overlay)` and `count(drop_front(sorted(items)))`, and bare scalar reads in return/assignment source slots, mutation key/RHS slots, direct path atoms, direct shape-literal values such as `[value]` and `{ "kind" : value }`, `if`/`while` conditions, numeric/comparison helper args, and switch subjects. Switch case labels remain literal tag positions: `switch(kind)` reads scalar `kind`, while `case(word)` matches the literal `"word"`. It also supports exact-arity user functions such as `fn normalize(value) { return(trim(value)) }` and `fn no_args() { return("ok") }`, with calls usable as values, receiver-chain receivers, or standalone discarded statements on Perl, Rust, Dart, and Julia. Direct RHS shape literals bind typed values on bare assignment targets (`items = [value]`, `meta = { key : value }`); exact one-identifier aggregate selectors are removed. Examples include `return(i)`, `set(out, if(is_nonempty(flag), "yes", else("no")))`, `out = switch(kind, case("word", "word"), default("other"))`, `return(name = "ok")`, `items += value`, `return(items += value)`, `items.sorted().first()`, `meta.set_key("stage", "normalized").count_keys()`, `raw.trim().split("-").lowercase_each().join_values("_")`, `score.abs().round().gt(3)`, `gt(count(parts), 0)`, `+(2, *(3,4))`, `str_eq(lowercase(trim(kind)), "word")`, `meta[key] = value`, `return(meta[key] = value)`, `payload["children"][i]`, `return([value, { "key" : value }])`, `return(with("x") { return(cat(value, "!")) })`, `return(" x ".with() { return(cat(value, "!")) }.trim())`, `return({ "a" : "A", "b" : { "y" : "B" } }.map_leaves() { return(cat(join_values("/", path), "=", value)) })`, `return(["a", ["b"]].map_leaves() { return(cat(join_values("/", path), "=", value)) })`, `return(normalize(" x "))`, `words(" go ").join_values("|")`, `switch(kind) { case("word") { return("word") } default { return("other") } }`, `items = [value]`, and `meta = { key : value }`. Function syntax remains the explicit-paren, braced `fn` MVP; alternate spellings, optional zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/currying, and namespaces are deferred. The comparison migration is complete through symbol callees: `str_*` is shipped and preferred for lexical string comparisons, while bare comparison words and comparison symbol callees are numeric aliases over `num_*`. Scalar, aggregate, array append, and hash-index mutation expression-valued assignment are shipped under `SPEC-FORMAT-TERSE.3.3.1` through `.3.3.3`, with legacy assignment spelling cleanup closed by `.3.3.4`; current cross-backend trailing block arguments are intentionally limited to immediate helper-function `with(...)`, receiver-method `.with()`, and tree traversal receiver methods `walk_leaves`, `map_leaves`, and `reduce_leaves`, not closures or delayed callbacks.
- **Shipped-spec terse-source migration** — complete. Current shipped specs, broader public examples, and checked-in corpus/test-spec examples prefer auto-existing working variables, operator assignment/reset forms, `set(...)`, `push(...)`, `copy(...)`, and `cat(...)`. Deleted helper spellings are no longer part of the current contract surface.

## What this means for readers

- Some older historical names appear in repo history and older notes. The active code path uses the current vocabulary.
- The current public and architectural explanations in this book prefer the active surfaces, not the oldest historical vocabulary.
- For the most current implementation status, the repo's `ROADMAP_V2.md` and `ARCHITECTURE_STATE.md` remain the fastest-changing references. This book absorbs that understanding over time in a more stable, explanatory form.

The project is healthy, actively maintained, and moving in a clear direction. Each phase leaves the codebase in a more explainable, more trustworthy state than it found it.
