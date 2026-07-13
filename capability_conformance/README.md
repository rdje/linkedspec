# Capability conformance inventory

`manifest.json` is the machine-readable census of current user-observable LinkedSpec capabilities across the four
implemented backends. It complements, rather than replaces, the executable 105-fixture interpreter corpus and the
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
Perl, Rust, Dart, and Julia descriptor tests consume the same exact top-level, metadata, and function-record field
sets so a backend-specific serialization convention cannot silently become public API.

`scalar_text_contract.json` fixes the portable `cat` conversion boundary across Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT. It preserves strings, spells booleans as `1`/`0`, normalizes finite decimal text, and makes null plus
the non-text value kinds propagate null. The executable fixture covers current portable source values; codeblock is
normatively non-text while explicit final-codeblock call syntax remains separately owned.

`scalar_numeric_contract.json` fixes strict scalar numeric helper inputs, arities, invalid-to-null results, numeric
comparison truth, half-away rounding, min/max/clamp, division, and signed integer modulo. Its deterministic case
list also renders one backend-neutral `.spec` fixture. Validate schema, independent evaluator results, and rendered
source offline with `python3 tools/check_scalar_numeric_contract.py`. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
consume the unchanged 55 cases; `bash tools/check_scalar_numeric_six_runtime.sh` is the composed admission proof.

`callable_signature_contract.json` adopts the definition-time variadic user-function contract without claiming
cross-backend admission early. It selects `fn name(fixed, ...rest) { ... }`, keeps version-1 fixed definitions exact,
defines version-2 signature records, binds extras as one fresh typed array, rejects keyword/overload/host-splat
semantics, and locks representative purpose-specific helper/method arities. Validate its schema, definitions,
bindings, diagnostics, and deterministically rendered future `.spec` fixture with
`python3 tools/check_callable_signature_contract.py`. Perl, Rust, Dart, and Julia consume the unchanged
source/result/record contract through native and generated execution. Lua remains explicitly future under
`LUA-BACKEND-PARITY.5.1`, with descriptor admission in `.5.3` and generated preservation/execution in `.8`.

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
Perl construction, invocation, normalization, and closeout `.11.3` are complete. Rust/Dart/Julia/Lua parity keeps
the overall capability future-owned under the remaining backend rollout leaves.

`punctuation_light_zero_arg_contract.json` adopts ADR `0033`'s narrow syntax aliases without turning LinkedSpec
into a general parenthesis-free call language. It locks six standalone bare zero-argument markers, generic bare
final receiver segments, exact normalized AST equivalence with parenthesized forms, ordinary-identifier retention,
condition/helper/intermediate-receiver/trailing-block exclusions, existing method-contract resolution, and one
deterministically rendered future `.spec` fixture. Validate the 6 standalone, 4 receiver, 6 invalid, and fixture
cases offline with `python3 tools/check_punctuation_light_zero_arg_contract.py`. Backend admission remains future
under `FUTURE-PARITY-BACKLOG.16.2-.16.7`; `.16.1` defines the neutral contract only.

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
coverage mapping. Generated source remains separately owned by `FUTURE-PARITY-BACKLOG.3`. `.3.1.0` demonstrated
why execution proof matters by exposing Perl's lost dependency indexes; `.3.1.2` repairs that mechanism and passes
focused contract proof. Rust v1 identity/metadata/errors plus exact neutral plan/direct result/trace roles align.
Admission `.3.1.3.3` promotes Perl to pass. Rust's staged full-manifest classifier is now an unconditional recurring
105/105 gate, and `.3.2.2` admits it. Rust generated source passes. Dart `.3.3.1`/`.3.3.2` add deterministic
emission and exact ten-family direct execution; `.3.3.3` binds the exact accepted eight-case list to recurring
interpreter-first isolated host proof and admits Dart. The current census is therefore 59 pass / zero partial /
one gap; Julia remains owned by `.3.4`.
