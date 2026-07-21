# Capability conformance inventory

`manifest.json` is the machine-readable census of current user-observable LinkedSpec capabilities across the five
admitted backends. It complements, rather than replaces, the executable 105-fixture interpreter corpus and the
66-case primary CLI manifest.

`semantic_introspection_contract.json` (`linkedspec-semantic-introspection-contract-v1`) makes ADRs `0049` and
`0050` executable before any backend is admitted. Its neutral model fixes `linkedspec-semantic-model-v1` and
`linkedspec-semantic-query-v1`: exact record/relation/fact vocabularies, staged payload/job/result records,
snapshot-local ids/order, value and target shapes, request/response envelopes, deterministic directional
traversal, page/record/relation/depth budgets, source ceilings/redactions/UTF-8 spans/digests, failed-compilation
and caller-owned runtime snapshots, explanations, rollout inventory, and the handle-only MCP boundary. Run
`python3 tools/check_semantic_introspection_contract.py`; the checker derives 20 digest-locked responses across
six fixture groups and reports 65 rejected mutations. Static rule facts are independently derived from
`rule_local_cursor_contract.json`: default/OR family normalizes to `or`/`seek`, rules without compiled edges use
`none`, and a failed default-family bare edge retains family-derived `action`. Three coordinated model-plus-hash
mutations prove response-digest self-consistency cannot hide those facts. Generated artifact identity/family is
also cross-checked against that contract's generated-source-v2 authority: the calls fixture emits `default`, and
both illegal and coordinated valid-but-wrong family mutations fail. Every semantic spec name is independently
derived from its caller-registered fixture logical name after removing `.spec`; the calls snapshot is therefore
`calls_and_staging`, and direct plus coordinated old-name mutations fail. Neutral rollout is 2 complete / 7 pending;
native backend admission is 1 complete / 5 pending. No parser, compiler, runtime, descriptor, generated-source,
CLI, trace, or MCP behavior was added by the neutral contract. Behavior-free Perl audit `.10.3.0` maps strict source,
descriptor, typed ActionIR, staged, structured failure, generated-plan, and missing runtime-observation authorities.
Perl foundation `.10.3.1` implements opaque in-memory construction, strict source normalization/mapping, and
immutable compiled-or-failed outcomes. Static leaf `.10.3.2.1` adds a private clone-safe projection whose graph,
privacy full/limited, failed-compilation, and runtime-static records/relations deep-equal the neutral model after
source references are materialized. `PERL5LIB= prove -Iperl t/semantic_index_perl_static_projection.t` checks
deterministic ids/order, duplicate and self-indexed slots, normalized failure evidence, immutable copies, JSON
booleans, and absence of host-object/path leakage. Calls leaf `.10.3.3.1.1` adds a second recurring private test:
`PERL5LIB= prove -Iperl t/semantic_index_perl_calls_projection.t` deep-equals all 22 corrected records and 25
relations, locks source-preorder/nested calls, resolution evidence, shapes, staged direction, shared generated-v2
identity, Unicode coordinates, interleaved function masking, immutable plain-data copies, and absence of host IR or
generated implementation text. Query leaf `.10.3.4` adds
`PERL5LIB= prove -Iperl t/semantic_index_perl_query.t`: native `$index->capabilities` and `$index->query(...)`
match all 19 static canonical response digests, plus strict request/error, privacy, paging, traversal, budget/cost,
clone/silence, and no-recompile/no-path proof. Runtime leaf `.10.3.5` adds typed invocation-local slot/result
capture plus immutable post-execution derivation. `PERL5LIB= prove -Iperl
t/semantic_index_perl_runtime_observation.t` matches the twentieth exact response across native, loaded,
captured/emitted generated direct/Get/traced, and validated-plan roles while proving failure identity and
trace/diagnostic non-interference. Composed admission `.10.3.6` adds
`PERL5LIB= prove -Iperl t/semantic_introspection_perl_admission.t`: one exact 12-role consumer covers source
normalization, all compiled/failed/runtime snapshots, direct/loaded/generated/traced observations, native and
neutral JSON, every one of the 20 response digests, privacy/page/budget/error/explain behavior, no-execute
immutability, and stale-host-leak denial. The checker requires its path, ordered role inventory, canonical driver,
tracked registration, Perl admission/rollout promotion, and eight new path/role/driver/registration/admission
mutations. Only Perl advances; the other five runtime admissions remain pending.

Run its structural and ownership gate from the repository root:

```bash
perl tools/check_capability_conformance.pl
```

Statuses mean:

- `pass`: current source plus executable evidence supports the contract;
- `partial`: an implementation or proof boundary is incomplete and has an explicit task owner;
- `gap`: the documented capability is absent and has an explicit task owner.

Every capability lists canonical contract sources and backend-specific evidence paths. The checker rejects unknown
fields/statuses/backends, duplicate ids, missing evidence paths, unowned partial/gap states, missing task-tree owner
ids, absolute paths, and future/excluded surfaces without an owner. Current language behavior belongs in
`capabilities`; deprecated or genuinely not-yet-adopted directions belong in `excluded_or_future`.

`outward_descriptor_contract.json` is the executable shared schema for the public compiled-descriptor projection.
Its `required_meta_keys` remains the explicitly named `legacy_global_v0` default for unmigrated backends, while
`meta_contract_variants.rule_local_cursor_v1` requires `cursor_contract`, forbids `parse_mode`, and fixes the v1
identity for migrated backends. Perl consumes that variant as of `.9.1.3.3`, Rust as of `.9.1.4.4`, Dart as
of `.9.1.5.3`, Julia as of `.9.1.6.3`, and Lua on both supported ABIs as of `.9.1.7.3`.
Its `function_record_variants` object is the authoritative three-way union: fixed-v1 stores `params`/`arity`,
variadic-v2 stores `signature`, and final-codeblock-v3 stores `params`/`arity` plus exact final-only
`parameter_kinds`. `tools/check_callable_signature_contract.py` rejects schema/order/version/storage/policy drift.
Perl, Rust, Dart, Julia, and Lua descriptor tests consume the applicable exact variants so a backend-specific
serialization convention cannot silently become public API. Final-codeblock-v3 admission by Perl and Lua does not
promote the separately future generic callable-codeblock capability.

`rule_local_cursor_contract.json` makes ADR `0044` executable before behavior rollout. Run
`python3 tools/check_rule_local_cursor_contract.py` to validate 36 exact rule-family spellings, 18 bare/explicit/
indexed/grouped/block/fluent/reserved edge cases, six post-normalization ownership sets, eight parent/child call
mechanisms, both structural replacements for retired global cross-combinations, exact API/CLI removal diagnostics,
per-rule descriptor metadata, generated-source v2 family derivation, and the dependency-ordered migration ledger.
The checker currently owns an exact 72-file migration inventory and rejects 56 representative semantic, topology,
diagnostic, generated, consumer-omission, recurring-gate, inventory, and admission mutations. A 14-role Perl consumer composes
live default/AND, descriptor v1, emitted v2, generated direct/trace, loaded spec, mixed parent/child, recursion,
both structural replacements, dynamic removal, primary command, and all portable diagnostic codes. Canonical CI
runs that consumer. A separate 15-role Rust consumer composes native default/AND, ordinary serialized, loaded,
descriptor-v1, emitted-v2, generated direct/trace, mixed/recursive, structural, static-removal, primary, and
portable-diagnostic projections. The checker requires every role marker plus the canonical/default-to-optional-
Rust driver topology. A separate 15-role Dart consumer composes native default/AND, normalized, loaded, descriptor,
emitted/generated direct/trace, mixed/recursive, structural, static-removal, primary, and diagnostic roles. The
checker locks each marker, the complete Dart test command, canonical tracked input, and optional backend-driver
registration. A separate 15-role Julia consumer composes the same normalized topology over current Julia native,
loaded, descriptor-v1, emitted/generated-v2, trace, composition, removal, primary, and diagnostic projections.
The checker locks its markers, complete package driver, canonical tracked input, and optional backend registration.
One Lua consumer composes the same 15 normalized roles and runs unchanged on both PUC Lua and LuaJIT. The checker
locks its markers, both backend-driver invocations, canonical tracked input, and optional backend registration.
`neutral_contract_and_inventory`, `perl_reference`, `rust_parity`, `dart_backend`, `julia_backend`,
`lua_dual_abi`, `recurring_five_backend_gate`, and `public_no_drift` are complete, so rollout is
8 complete / 0 pending. Run
`bash tools/check_rule_local_cursor_five_backend.sh` for the recurring Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT
composition, selected 5x2x5 primary projection, and support ledgers. Canonical local CI exposes the same
all-toolchain leg behind `LINKEDSPEC_RUN_CURSOR_MATRIX=1`. The public contract requires current README, guide,
API/backend, roadmap, task, architecture, mdBook, ADR, and Knowledge Map surfaces and rejects exact stale-current
claims; the checker rejects 60 semantic, topology, recurring, public, and rollout drift mutations. The shared generated-source-v1
capability ledger remains the semantic convergence baseline while current Perl, Rust, Dart, Julia, and Lua
emitters use v2. Lua's dedicated dual-ABI generated-v2 proof passes 106 assertions per ABI under `.9.1.7.4`;
its composed admission now passes 119 assertions per ABI under `.9.1.7.6`.

`root_rule_selection_contract.json` (`linkedspec-root-rule-selection-v1`) makes ADR `0046` executable without
claiming markerless execution before the
backends admit it. Run `python3 tools/check_root_rule_selection_contract.py` to validate explicit selector > first
authored `::` > first authored `:` precedence, eight successful selections, three structural/selector failures,
three strict-unused graph cases, authored `is_top` identity, native/loaded/reconstructed/generated/emitted/trace/
primary projections, and the exact five-backend audit. The checker topology-locks the Perl core/routes consumers,
the exact 15-role Rust, Dart, Julia, and Lua admission consumers, configured CI/backend execution, first-marker/
markerless/explicit/unknown primary cases, and default/explicit request trace. Final admission adds the composed
six-runtime recurring gate, a 25-document public contract, and both roadmap projections as required current-state
inputs while rejecting 54 semantic, topology, recurring, public, and rollout drift mutations. Rollout is 7
complete / 0 pending: neutral decision, composed Perl, Rust, Dart, Julia, dual-ABI Lua, and final recurring/public
no-drift are admitted. Perl records marker-
optional validation, exact explicit/first-marker/first-rule resolution, markerless fallback, immutable descriptor
`is_top`, and the same resolution across loaded, generated-direct, generated-traced, and generated `Get` execution. Generated artifacts
retain ordered authored entry state separately from their minimal label/family plan, and an invocation-local
selector overrides an emission-time configured selector. Root-selection established 65 reference-first cases,
including exact first-marker and markerless-default bytes beside explicit and unknown selection; repeated-action
recurring proof adds the 66th shared case. Rust now carries
the same marker-optional resolver through native, loaded, serialized/reconstructed, generated direct/traced, and
emitted direct/traced execution. Existing generated signatures remain intact; option-bearing siblings accept
per-invocation `ExecutionOptions`, return portable zero/unknown selection failures, and keep the selector out of
authored descriptor identity and the minimal family plan. One omission-sensitive Rust consumer composes all 15
neutral, native, loaded/reconstructed, generated/emitted, descriptor, diagnostic, trace, and primary roles exactly
once; the Rust primary command passes all 66 cases in default and POSIX option environments. Dart now has the same
exact 15-role admission topology across loaded/normalized/generated/emitted/trace/diagnostic paths. Its package-
wide driver passes 270 tests, the shared command passes 65/65 in both option environments, and the corpus passes
105/105. Julia core `.4.1` consumes every neutral selection/failure/strict row, accepts markerless
one-or-more-rule sources, reports portable zero/unknown failures, and publishes the descriptor contract without
advancing rollout; native/root-primary proof is exactly 32/65 twice with only the 33 cursor-owned cases remaining.
Julia route `.4.2` proves loaded/normalized and generated/emitted direct/traced execution, low requested/effective/
basis trace, portable loader/generated failures, and plan-first rejection through 57 assertions. Dart cursor
admission is clean at `7aa9c578`; Julia cursor `.9.1.6` now implements and composes exact normalization, live
execution, descriptor v1, generated-source v2, public/CLI option removal, and one 15-role admission. Shared Julia
primary is exact at 65/65 twice. Julia root admission `.4.3` composes the contract through one exact 15-role
consumer; its authored selection fixtures use entry lifecycle returns so the result proves which rule was entered
rather than merely which successful match exited. Lua/LuaJIT use the same exact source on both ABIs. Run
`bash tools/check_root_rule_selection_five_backend.sh` for the recurring native/composed proof and selected
5x2x6 primary projection; canonical CI exposes it behind `LINKEDSPEC_RUN_ROOT_RULE_MATRIX=1`.
The final root-selection ledger is 7 complete / 0 pending.

`duplicate_regex_slot_identity_contract.json` (`linkedspec-duplicate-regex-slot-identity-v1`) makes ADR `0047`
executable before backend repair. Duplicate regex text remains legal and never replaces typed target-rule plus
regex-index identity. Ordered execution matches its already-required structural slot; repeated AND resets that
sequence per iteration. Choice evaluates all eligible slots, prefers the earliest start, and breaks equal-start
ties toward the first authored slot. Five exact fixtures cover same-rule ordered and choice duplicates, repeated
duplicates, a non-duplicate repeated control, and cross-target duplicates. The contract also fixes two portable
invariants, descriptor and trace identity, unchanged generated-source v2/format 2, the six-runtime mechanism
inventory, migration paths, and the seven-leg rollout. Run
`python3 tools/check_duplicate_regex_slot_identity_contract.py`; it independently evaluates the selection model
and reports 59 rejected mutations spanning semantic, fixture, diagnostic, artifact, inventory, rollout,
recurring, public, closure, admission, and CI drift.
mutations. Perl `.2` is composed-admitted through 12 exact roles. Rust `.3` is composed-admitted through 15 exact
roles covering native, reconstructed, loaded, descriptor, emitted/generated, native/generated trace, primary,
all five neutral fixtures, and typed diagnostics. Rust matches required slots directly, retains combined choice,
publishes descriptor/emitted contract identity, and keeps generated v2 plans minimal. Dart `.4` is composed-
admitted through the same 15-role shape over direct authored-alternative matching, normalized-spec generated
payload, descriptor/emitted/trace identity, primary, and diagnostics. Julia `.5` is now admitted through a
module-isolated 15-role consumer over direct authored-alternative matching,
normalized-spec generated payload, descriptor/emitted/trace identity, primary, and diagnostics. Dual-ABI Lua
`.6` runs one unchanged 15-role consumer on PUC Lua and LuaJIT, replaces required-pattern/reindex with direct
authored-alternative matching, and preserves normalized-spec generated v2. The recurring driver
`tools/check_duplicate_regex_slot_identity_five_backend.sh` composes all six runtime legs, the selected 5x2x1
primary case, and generated/capability/language-coverage support ledgers. Governance is closed at
7 complete / 0 pending with 59 rejected mutations.

`repeated_action_result_contract.json` (`linkedspec-explicit-repetition-action-result-v1`) makes ADR `0048`
executable across all admitted backends. It fixes eight exact mode rows for `*`, `+`, `?`, bare `OR`,
`OR+`, exact/up-to bounded OR, and scalar pipe, plus ten cases for duplicate priority, nested/null values, fluent
returns, zero/below-minimum bounds, lifecycle authority, duplicate pipe, and blind bare-OR classification. Run:

```bash
python3 tools/check_repeated_action_result_contract.py
PERL5LIB= prove -Iperl t/repeated_action_result_perl_contract.t
bash tools/check_repeated_action_result_five_backend.sh
```

The checker independently evaluates results, cursors, and selected-slot order, locks exact source bytes,
descriptor and generated-source-v2 family facts, trace/route topology, the checked-in distinct-OR corpus bundle,
six-runtime mechanism inventory, exact recurring topology, and migration ownership, and rejects 44 drift
mutations. The Perl consumer composes ten roles: neutral model, live modes, special cases, loaded source,
descriptor, emitted source, generated direct, generated trace, primary CLI, and corpus bundle. Rust, Dart,
Julia, PUC Lua, and LuaJIT each run their exact 15-role admission; the shared Lua source runs once per ABI. The
recurring driver composes those six runtime legs, the contract-projected
`success_explicit_repeated_action_results` case through five commands in default and POSIX environments, and the
generated-source/capability/language-coverage ledgers. Canonical local CI runs the neutral checker and Perl
consumer unconditionally and exposes the all-toolchain composition behind
`LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX=1`. Repeated-action rollout is closed at 8 complete / 0 pending;
the public contract covers 25 current documents, denies 12 stale claims, and the checker rejects 54 drift mutations.
The exact recurring proof is `tools/check_repeated_action_result_five_backend.sh`.

The Julia cursor preflight recorded the historical starting differences without advancing rollout: compact `|`
was generated AND, every engine owned global seek, 11 edge rows remained raw, parent-child agreement was 5/8,
structural agreement was 1/2, and descriptor/generated cursor identities were absent. Current `.1-.4` proof now
covers all 36 family spellings, all 18 edge rows, 8/8 parent-child, 2/2 structural, cursor descriptor v1, and
generated-source v2 with contract-before-payload rejection. Public removal then deletes global engine/loader/
corpus/primary ownership while retaining low-level matcher primitives and targeted legacy diagnostics. Package
progression is 3,291, shared primary is 65/65 twice, corpus is 105/105, and governance was 67 / 5+3 / 44 at
Julia admission. Lua admission later advanced the ledger to 69 / 6+2 / 49, root-governance scanning moved the
inventory to 71, recurring admission established 72 / 7+1 / 56, the Julia duplicate-slot proof path advanced it
to 73, and duplicate-slot public governance added two parse-mode-chapter scanner paths under `.9.1.9`. Final
public no-drift closes the current boundary at 75 / 8+0 / 60.

Dart core leaf `.9.1.1.2.3.1` closes the preflight's 64/65 boundary: validation now
accepts markerless one-or-more-rule sources, one compiled resolver implements the exact precedence, native and
65x2 primary execution use it, zero/unknown selection failures have portable identities, strict-unused stays an
authored-edge analysis, and descriptors publish immutable `is_top` plus the root contract identity. Route leaf
`.3.2` proves loaded/normalized and generated/emitted direct/traced execution, low requested/effective/basis trace,
portable route failures, and stale-contract-first ordering without changing v2 identity. Admission `.3.3` adds one
contract-declared 15-role consumer, exact driver/case registration, and five additional omission mutations; Dart
is therefore admitted and rollout is 4 complete / 3 pending.

Julia admission `.4.3` applies the same omission-sensitive 15-role topology to the already-admitted core and
route mechanisms, including loaded/reconstructed, generated/emitted direct and traced, immutable descriptor,
portable diagnostics, selected-rule runtime failure identity, primary selection, and exact shared request-trace
bytes. The canonical and Julia package drivers own the consumer, and five additional mutations prevent its role,
consumer, shared-primary, driver, or rollout identity from silently regressing.
Focused composition passes 137; package 3,428, primary 65x2, corpus 105, and canonical Phase 0 1,031 in 616
seconds pass.

Perl preflight assigns the ten shared manifest/help/usage/trace byte fixtures to the reference migration leaf
`.9.1.3.5`: removing the reference option affected 35 cases in the then-63-case suite that local CI always
runs twice. That reference-first migration is now implemented; shared CLI documentation and final symmetric
five-backend admission remain `.9.1.8`-owned. This keeps
main green without an ignored flag, hidden compatibility route, or skipped case while backends roll forward in
dependency order.

`scalar_text_contract.json` fixes the portable `cat` conversion boundary across Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT. It preserves strings, spells booleans as `1`/`0`, normalizes finite decimal text, and makes null plus
the non-text value kinds propagate null. The executable fixture covers current portable source values; codeblock is
normatively non-text while explicit final-codeblock call syntax remains separately owned.

`diagnostic_output_contract.json` adopts ADR `0042`'s backend-neutral `print`/`say`/`print_each` event boundary
without claiming backend admission early. It fixes exact one-plus/two-or-three arities, arity-before-evaluation,
once-only left-to-right effects, diagnostic scalar rendering, call/item grouping, newline and decoration text,
empty/wrong-kind behavior, Unicode order, structural-result neutrality, quiet execution, synchronous caller sink
failure, immediate `exit_now`, generated propagation, and the quiet ADR `0024` primary-CLI projection. Validate
the 11 rendering rows, five invalid arities, six semantic scenarios, and the exact rollout ledger
offline with `python3 tools/check_diagnostic_output_contract.py`. The checker independently evaluates the model and
rejects 20 representative semantic, topology, public-document, and admission drift mutations. All five native
legs, generated/primary propagation, recurring admission, and public no-drift are complete: 8 complete / 0 pending.
The public contract additionally requires 16 current documentation surfaces and rejects nine exact stale
claims, so an old direct-host-output or pending-generated caveat cannot silently return. Run
`bash tools/check_diagnostic_output_five_backend.sh` for the composed Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT native+
generated proof, selected quiet five-command/default-POSIX case, and generated-source/capability/corpus ledgers.
Canonical local CI registers that all-toolchain leg behind `LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX=1` while auditing its
schema, topology, syntax, and tracked inputs on every ordinary run.

`scalar_numeric_contract.json` fixes strict scalar numeric helper inputs, arities, invalid-to-null results, numeric
comparison truth, half-away rounding, min/max/clamp, division, and signed integer modulo. Its deterministic case
list also renders one backend-neutral `.spec` fixture. Validate schema, independent evaluator results, and rendered
source offline with `python3 tools/check_scalar_numeric_contract.py`. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
consume the unchanged 55 cases; `bash tools/check_scalar_numeric_six_runtime.sh` is the composed admission proof.

`logical_helper_contract.json` adopts ADR `0043`'s backend-neutral `and`/`or`/`not` value contract without
claiming backend admission early. `and` and `or` require at least one positional argument; `not` requires exactly
one. Invalid arity produces `helper_arity_mismatch` before any argument runs. Valid calls evaluate every argument
once left-to-right and return a real boolean, while `if`/`switch`/`while` remain lazy controls over the same typed
truthiness seam. Null, false, numeric zero, empty strings, and empty arrays/harrays are false; all other finite
numbers, nonempty strings (including `"0"` and `"false"`), nonempty aggregates, and codeblock values are true.
Testing a codeblock does not invoke it. The codeblock row is model/backend-unit evidence only until the separately
owned first-class literal program lands; this contract does not activate `{|...| ... }` syntax.

Run `python3 tools/check_logical_helper_contract.py` to validate 17 truthiness rows, ten helper cases, three eager
effect scenarios, receiver and lazy-control contrast, four pre-effect arity failures, deterministic embedded
fixtures, exact projection obligations, and 26 semantic/topology/public drift mutations. Perl consumes the neutral
artifact through typed ActionIR/runtime proof; Rust uses
its shared typed truth/arity seam plus native, serialized, generated-plan, and emitted proof; Dart uses one typed
helper/control seam plus native, normalized, generated-plan, standalone-emitted, and primary proof. Julia
preserves its typed eager helper/control seam and adds native, normalized, generated-plan, standalone-emitted,
primary, and exact diagnostic proof. Lua consumes the same contract through native, reconstructed, generated-plan,
emitted-module, primary, and exact diagnostic proof on PUC Lua and LuaJIT. Run
`bash tools/check_logical_helper_five_backend.sh` for the strict recurring composition: the checker, all six
backend/runtime consumers with their exact native/generated roles, `success_logical_helpers_eager` through the
5x2 selected primary matrix, and generated-source/capability/coverage ledgers. Canonical local CI exposes the
same all-toolchain leg with `LINKEDSPEC_RUN_LOGICAL_MATRIX=1`. Public no-drift additionally locks 20 authoritative
documents and 13 forbidden current claims. The current ledger is 8 complete / 0 pending and parent `.5.2` is
closed.

`callable_signature_contract.json` adopts the definition-time variadic user-function contract without claiming
cross-backend admission early. It selects `fn name(fixed, ...rest) { ... }`, keeps version-1 fixed definitions exact,
defines version-2 signature objects whose outward placement is sourced from the descriptor union, binds extras as one fresh typed array, rejects keyword/overload/host-splat
semantics, and locks representative purpose-specific helper/method arities. Validate its schema, definitions,
bindings, diagnostics, and deterministically rendered future `.spec` fixture with
`python3 tools/check_callable_signature_contract.py`. Perl, Rust, Dart, Julia, and Lua consume the unchanged
source/result/record contract through native and generated execution. Lua's exact signature/runtime and outward
descriptor variants close under `.5.1/.5.3.1`, while emitted variadic execution closes under `.8.2` and final
five-backend admission under `.8.4`.

`callable_codeblock_contract.json` adopts the future first-class callable-codeblock boundary without claiming
backend support early. Exact `{|fixed, ...rest| body }` syntax constructs deferred typed codeblock data; `cb(args)`
uses caller-time stores, temporary copied parameter bindings, block-local return, and static callable precedence.
Ordinary `{ statements }` remains an eager block value, while empty and top-level-colon brace forms remain harray
literals. The contract also fixes diagnostics, exact final-only `name: codeblock`, eight contextual helper/
user-function/receiver forms, and a deterministic future `.spec` fixture. Validate the schema, parser/classifier
model, neutral invocation model, and fixture offline with
`python3 tools/check_callable_codeblock_contract.py`. Backend admission remains future until the owned rollout
leaves supply generic final-block and cross-backend evidence. Perl now consumes the literal and invocation subset
through `prove -Iperl t/callable_codeblock_literal_contract.t`: exact AST/spans, inert canonical generated data,
assignment/copying, user-function preservation, dynamic caller execution, temporary fixed/rest restoration,
standalone discard, receiver continuation, static precedence, and typed failures pass. Generic Perl final-block
normalization audit `.11.3.3.0` found the declaration gap, ADR 0032 closes it in `.11.3.3.1`, and `.11.3.3.2`
preserves metadata plus executes equivalent attached/parenthesized helper/user-function/receiver contextual forms.
Perl construction, invocation, normalization, and closeout `.11.3` are complete. Lua's declared contextual
helper/user-function/receiver forms are also current, but explicit callable literals and arbitrary dynamic calls
remain future alongside Rust/Dart/Julia generic parity; the overall generic capability therefore stays excluded.

`complete_named_mark_contract.json` fixes the seven documented current named-mark helpers that were absent from
every governed backend inventory: entry/local start/end writers, line/column readers, and explicit clear. The
contract requires symbolic bare mark names, rule-label isolation, character-based public positions and locations,
and undef/zero behavior for absent reads and existence checks. Its exact Unicode parent/child fixture also proves
that a child cannot overwrite an identically named parent mark. Validate the schema, independent location model,
fixture rendering, and three drift mutations with `python3 tools/check_complete_named_mark_contract.py`. Perl
consumes the unchanged fixture through `prove -Iperl t/complete_named_mark_contract.t`, including live and
standalone generated execution. Rust consumes it through
`cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test complete_named_mark_contract`, including
native, serialized, emitted-plan, and generated execution. Dart consumes the same artifact through
`cd dart && dart test test/complete_named_mark_contract_test.dart`, including native, generated-plan,
emitted-state reconstruction, and primary-CLI execution. Its seven-name exact family view is retained after all
seven names join the aligned 246-name shared inventory. Julia consumes the same artifact through
`LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia bash tools/run_julia_local.sh` plus its focused exact contract. Lua
consumes it through `bash tools/run_lua_local.sh`, including native and serialized `SpecFile` reconstruction on
PUC Lua and LuaJIT. All five backends therefore resolve the seven helpers, and `.17.5` admits them into the shared
inventory. `tools/check_language_capability_coverage.pl` now supplements the 105 corpus fixtures with this exact
fixture, independently checks all 122 public identifier-shaped Perl contracts, and rejects nine explicitly
classified compatibility, legacy, and internal names so a symmetric omission cannot remain invisible.

`punctuation_light_zero_arg_contract.json` adopts ADR `0033`'s narrow syntax aliases without turning LinkedSpec
into a general parenthesis-free call language. It locks six standalone bare zero-argument markers, generic bare
final receiver segments, exact normalized AST equivalence with parenthesized forms, ordinary-identifier retention,
condition/helper/intermediate-receiver/trailing-block exclusions, existing method-contract resolution, and one
deterministically rendered portable `.spec` fixture. Validate the 6 standalone, 4 receiver, 6 invalid, and fixture
cases offline with `python3 tools/check_punctuation_light_zero_arg_contract.py`. Perl consumes the contract through
`prove -Iperl t/punctuation_light_zero_arg_contract.t`, covering typed AST equivalence, final-only receiver
parsing, unchanged exclusions and method resolution, canonical `next` lowering, and live plus standalone
generated execution. Rust consumes the same syntax/AST cases through
`rust/linkedspec-runtime/tests/punctuation_light_zero_arg_contract.rs`, including exact native, serialized,
emitted-source, generated-plan, and rebuilt-CLI fixture results. Dart consumes the same cases through
`dart/test/punctuation_light_zero_arg_contract_test.dart`, including exact native, generated-plan, emitted-state,
and CLI fixture results. Julia consumes the same cases through
`julia/test/punctuation_light_zero_arg_contract_test.jl`, including exact native, generated-plan, emitted-state,
and CLI fixture results. Rust, Dart, and Julia's pre-existing `.contains()` missing-argument outcomes remain helper
drift owned by `FUTURE-PARITY-BACKLOG.5`; each alias preserves its backend's parenthesized outcome. Lua consumes
the same AST/negative/native fixture cases inside `lua/test/run.lua` on PUC Lua and LuaJIT, including public
SpecFile JSON reconstruction; its matching `.contains()` drift is also owned by `.5`. Generated Lua source closes
independently through exact emitter/family/subset proof `.8.1-.8.3`; the punctuation-light row relies on its exact
AST/native/serialized proof and does not claim that this one fixture separately runs through emitted Lua. The
current syntax is admitted for all five backends under `language.punctuation_light_zero_argument_aliases`. The
composed recurring proof is `bash tools/check_punctuation_light_five_backend.sh`; it exercises Lua on both ABIs
without conflating serialized-state reconstruction with generated-source execution.
The JSON key `future_fixture` is retained as the version-1 schema name; the fixture itself is now admitted current.

`uniform_binding_contract.json` adopts the selector-free one-binding target contract before backend behavior
changes. A bare identifier reads its current scalar, array, harray, or codeblock value; `set(name, value)` returns
that binding's post-assignment typed value; mutable helpers use bare targets and return updated values; absent
array/harray mutations create only the required kind; incompatible existing kinds fail with
`binding_kind_mismatch`. Static rule names retain precedence for ambiguous `push(name, target)` syntax, while
three-argument `split(name, source, delimiter)` is the mutable form and two-argument `split(source, delimiter)` is
pure. Exact `array(IDENTIFIER)` / `hash(IDENTIFIER)` calls are removed and reject with
`aggregate_selector_removed`, even when a one-element constructor was intended (`[IDENTIFIER]` is the replacement).
Zero/multi/quoted/computed constructor calls remain separately valid under version 1. Validate 11 migrations,
seven execution cases, six invalid selectors, eight constructor classifications, and deterministic future source/
results offline with `python3 tools/check_uniform_binding_contract.py`. Perl `.12.1.2`, Rust `.12.1.3`, Dart
`.12.1.4`, Julia `.12.1.5`, and Lua `.12.1.6` execute the contract. All tracked file-backed and embedded sources
are migrated. Perl `.12.1.8.1`, Rust `.12.1.8.2`, Dart `.12.1.8.3`, Julia `.12.1.8.4`, and Lua `.12.1.8.5`
hard-reject the removed exact selectors before execution. Cross-variant `.12.1.8.6` locks their shared contract,
boundaries, and zero runtime compatibility. The uniform-binding selector retirement is admitted by `.12.1.9`.
Follow-up `.12.1.10` extends its recurring public checker to all immediate component READMEs: 56 public files are
locked at 27 genuine classified removed/history references and zero current examples, including explicit bare-binding
anchors in the Rust, Dart, Julia, and Lua READMEs.
Closed follow-up `.12.1.11` reconciles older statement-only array-end result prose and Perl value-position lowering
with the already-admitted updated-value contract. `python3 tools/check_uniform_binding_mutation_result_surface.py`
gates the public book/backend summaries, current backend fact anchors, and explicitly classified historical cards.

`generated_source_contract.json` is the versioned semantic contract for host-language source emission. It fixes
compiled-spec-plus-identity input, deterministic source markers, independent compile/load, execute and traced-
execute roles, the ten structural families, plan rejection, stable generated-source errors, one direct behavior
fixture, the accepted eight-case generated subset, and the 105-case interpreter oracle. It explicitly does not
require identical host API names, source syntax, or bytes. Run:

```bash
perl tools/check_generated_source_contract.pl
```

The census intentionally records proof quality separately from implementation belief. Passing the 105-case corpus
does not by itself prove every helper and API described by the mdBook; `FUTURE-PARITY-BACKLOG.1.6.1` owns that
coverage mapping. Generated source was first owned by `FUTURE-PARITY-BACKLOG.3` and Lua completion by
`LUA-BACKEND-PARITY.8`. `.3.1.0` demonstrated
why execution proof matters by exposing Perl's lost dependency indexes; `.3.1.2` repairs that mechanism and passes
focused contract proof. Rust v1 identity/metadata/errors plus exact neutral plan/direct result/trace roles align.
Admission `.3.1.3.3` promotes Perl to pass. Rust's staged full-manifest classifier is an unconditional recurring
105/105 gate, and `.3.2.2` admits it. Dart `.3.3.1-.3` and Julia `.3.4.1-.3` bind deterministic ten-family source
to the exact accepted eight-case interpreter-first isolated-host proof and are admitted. Lua `.8.1-.8.3` now adds
exact v1/v2/v3 emission, dual-ABI isolation, ten-family execution, and the same contract-ordered 8/105 proof in
fresh PUC Lua/LuaJIT hosts; the checker owns Lua's path/order/proof/trace/cleanup registration. Sole admission
owner `.8.4` now adds Lua to every row in one all-pass expansion. The current census is 80 pass / zero partial /
zero gap across five admitted backends, and the satisfied Lua-backend and variadic-function exclusions are retired.
