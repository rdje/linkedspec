# Capability conformance inventory

`manifest.json` is the machine-readable census of current user-observable LinkedSpec capabilities across the five
admitted backends. It complements, rather than replaces, the executable 105-fixture interpreter corpus and the
61-case primary CLI manifest.

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
Its `function_record_variants` object is the authoritative three-way union: fixed-v1 stores `params`/`arity`,
variadic-v2 stores `signature`, and final-codeblock-v3 stores `params`/`arity` plus exact final-only
`parameter_kinds`. `tools/check_callable_signature_contract.py` rejects schema/order/version/storage/policy drift.
Perl, Rust, Dart, Julia, and Lua descriptor tests consume the applicable exact variants so a backend-specific
serialization convention cannot silently become public API. Final-codeblock-v3 admission by Perl and Lua does not
promote the separately future generic callable-codeblock capability.

`scalar_text_contract.json` fixes the portable `cat` conversion boundary across Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT. It preserves strings, spells booleans as `1`/`0`, normalizes finite decimal text, and makes null plus
the non-text value kinds propagate null. The executable fixture covers current portable source values; codeblock is
normatively non-text while explicit final-codeblock call syntax remains separately owned.

`diagnostic_output_contract.json` adopts ADR `0042`'s backend-neutral `print`/`say`/`print_each` event boundary
without claiming backend admission early. It fixes exact one-plus/two-or-three arities, arity-before-evaluation,
once-only left-to-right effects, diagnostic scalar rendering, call/item grouping, newline and decoration text,
empty/wrong-kind behavior, Unicode order, structural-result neutrality, quiet execution, synchronous caller sink
failure, immediate `exit_now`, generated propagation, and the quiet ADR `0024` primary-CLI projection. Validate
the 11 rendering rows, five invalid arities, six semantic scenarios, and eight explicitly pending rollout legs
offline with `python3 tools/check_diagnostic_output_contract.py`. The checker independently evaluates the model and
rejects eight representative drift mutations; backend-specific behavior evidence remains owned by
`FUTURE-PARITY-BACKLOG.5.1.2-.9`.

`scalar_numeric_contract.json` fixes strict scalar numeric helper inputs, arities, invalid-to-null results, numeric
comparison truth, half-away rounding, min/max/clamp, division, and signed integer modulo. Its deterministic case
list also renders one backend-neutral `.spec` fixture. Validate schema, independent evaluator results, and rendered
source offline with `python3 tools/check_scalar_numeric_contract.py`. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
consume the unchanged 55 cases; `bash tools/check_scalar_numeric_six_runtime.sh` is the composed admission proof.

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
