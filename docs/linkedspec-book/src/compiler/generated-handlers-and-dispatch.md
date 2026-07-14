# Generated Handlers and Dispatch

LinkedSpec generates rule handlers dynamically, but the project has been moving away from opaque, repeatedly-evaled behavior toward a cleaner and more attributable runtime model.

The dispatch **model** in this chapter is backend-neutral: a compiled dependency-regex alternation selects a matched index, the handler dispatches to the corresponding child rule, generated handlers carry stable identity labels, and handler generation is a two-phase **variant builder → HandlerIR → backend emitter** flow. That HandlerIR / backend-emitter seam is precisely the multi-backend decoupling point — a structured intermediate representation that holds everything an emitter needs without raw host-language source (see [Backend Handoff](../appendix/backend-handoff.md)). The concrete utilities and encodings named below — `LinkedRE::or`, `perl/LinkedRE.pm`, the `LinkedSpec::generated_handler:` label spelling, `HandlerVariantEmitter.pm`, `JSON::PP`, `pos($$STRING)`, and the `$BACKEND` package variable — are the **Perl reference backend's** implementation of that model.

## Important themes

- generated handlers are attributed to rule labels and variants
- top-level parser invocation keeps structured entrypoint identity
- dispatch uses compiled dependency regexes explicitly
- runtime failures are normalized into structured error channels

## Backend-neutral generated-source contract

Generated source is a public capability, not merely an internal implementation
detail. Contract v1 is executable at
`capability_conformance/generated_source_contract.json` and deliberately fixes
semantic roles rather than host-language spelling.

Every backend must accept a compiled specification plus stable source identity,
emit deterministic host-language source, independently compile or load it, and
offer ordinary and traced execution. The source model is Unicode scalar text;
when persisted by the current contract, its byte encoding is strict UTF-8. It
carries contract, format-version, and source-identity markers. Perl,
Rust, Dart, and Julia source bytes are not expected to match: their host APIs
remain idiomatic and their source syntax remains native. Results, diagnostics,
trace roles, identity, and plan validation must match.

The generated family plan contains ordered `label` / `family` rows and covers
default and OR acode; AND single-acode and ordered acode sequence; AND and OR
bcode; repetition acode and bcode; and repetition-AND acode and bcode.

Before execution, the backend rejects row-count, label, family, and unknown-
family mismatches. Generated-source failures use stable emission, compile/load,
plan-validation, and execution stages with source identity and available rule/
family attribution.

Conformance remains interpreter-first. The neutral direct fixture proves result,
trace roles, and identity. The initial generated corpus subset contains eight
named fixtures; Rust must broaden to the complete 105-case manifest, while new
emitters prove the accepted subset plus every structural family. The interpreter
manifest stays the primary correctness oracle.

Rust's source-emitter now implements contract-v1 identity, metadata, and typed
errors. Native callers use
`emit_rust_source_v1(&compiled, "path/to/input.spec")`; the generated module
exports contract/version/identity constants, `metadata()`, and typed `execute`
and `execute_with_trace` roles. `GeneratedSourceError` records the portable
stage, code, summary, identity, and available rule/family/detail attribution;
`GeneratedSourceError::compile_failed(...)` projects the caller-owned Rust
compiler/load boundary into that same record.

The original `emit_rust_source(&compiled) -> Result<String, String>` remains a
compatibility adapter with `<inline>` identity. Generated `parse` and
`parse_with_trace` likewise retain raw-string diagnostics, so adopting v1 does
not silently alter existing Rust callers.

Rust now emits a separate `GeneratedPlanRow` table with exact neutral family
strings, plus `plan()` and `validate_plan(...)`. Count, label, known-family
mismatch, and arbitrary unknown-family mutations have distinct pre-execution
codes. The legacy typed enum table remains private to compatibility adapters;
its historical `Repetition` marker is not a v1 family.

The neutral fixture also locks result projection. Typed v1 `execute` and
`execute_with_trace` return the direct top-rule value, matching the public
native/CLI value contract. Legacy `parse` and `parse_with_trace` retain Rust's
historical accumulator envelope. The three portable generated-rule enter,
family-decision, and exit roles carry source/rule/family context beside native
`rust_runtime:generated_plan:*` detail. The Perl/Rust baseline is admitted.
Perl is pass. Rust's staged classifier now proves all 105 interpreter fixtures
through v1 emission, one isolated host compile, and separate generated tests
with exact direct/compatibility results. That diagnostic is 105/105 green;
Zero-failure closeout found no repair mechanism. The classifier is now an
unconditional ordinary runtime-package test, contract checking prevents it
from becoming ignored or conditional, and complete admission gates pass. Rust
generated source is therefore admitted pass.

```rust
use linkedspec_runtime::source_emitter::{
    GeneratedSourceError, emit_rust_source_v1,
};

let generated = emit_rust_source_v1(&compiled, "specs/example.spec")?;
let host_failure = GeneratedSourceError::compile_failed(
    "specs/example.spec",
    "rustc rejected generated.rs",
);
assert_eq!(host_failure.source_identity, "specs/example.spec");
# Ok::<(), Box<dyn std::error::Error>>(())
```

Dart now has the contract-v1 scaffold too. Native callers pass the compiled
state and identity to `emitDartSourceV1(...)`; `emitDartSource(...)` is the
`<inline>` compatibility adapter. The emitter uses the effective compiled
function/rule order to build a normalized specification, then emits a Dart
library with metadata plus `execute(...)` and `executeWithTrace(...)` direct-
value roles. Generated execution failures retain the source identity and the
requested rule when available.

```dart
final compiled = compileSpec(parseSpec(source));
final generated = emitDartSourceV1(
  compiled,
  'specs/example.spec',
);

try {
  // Persist `generated` as UTF-8 in a caller-owned Dart package, then import it.
} on GeneratedSourceException catch (error) {
  print(error.toJson());
}
```

The generated file is Unicode Dart source. Its normalized specification
payload is serialized to strict UTF-8 and embedded as Base64, which preserves
arbitrary Unicode and prevents Dart `$` interpolation from changing the data.
This is an encoding choice at the generated-file boundary: Unicode itself is
not synonymous with UTF-8, and UTF-16/UTF-32 are other Unicode encodings.

The scaffold proof creates a caller-owned temporary package and private package
cache, resolves offline, analyzes the emitted library, runs its direct result,
checks structured execution failure, and deletes the package/cache.

Dart now also emits `plan()` and `validatePlan(...)`. The ordered plan uses the
same ten family strings listed above. Row-count, label, known-family mismatch,
and unknown-family errors are distinct and occur before parser execution. Once
validated, each typed family controls whether that rule takes the acode/regex
or bcode/blind structural executor; the plan is not merely descriptive.

Generated traced execution adds `generated_rule_enter`,
`generated_family_decision`, and `generated_rule_exit` beside Dart's richer
native trace. One isolated host package compiles and runs all ten families
against native interpreter values.

Dart admission now consumes the contract's exact eight-case list rather than
copying a backend-local list. Every fixture—including staged user-function
execution—must first equal its checked-in interpreter result. One isolated
offline host package then analyzes and runs the eight emitted libraries with
exact values, metadata, plans, portable trace roles, and source identity. The
contract checker locks that test path and proof shape. Dart generated source is
therefore admitted pass.

Julia now exposes the first contract-v1 scaffold through
`emit_julia_source_v1(compiled, "specs/example.spec")` and the `<inline>`
compatibility adapter `emit_julia_source(compiled)`. The generated native
module exposes contract/version/identity metadata plus direct-value `execute`
and `execute_with_trace` entrypoints. Emission reconstructs the effective
ordered specification from compiled state and recompiles it through Julia's
ordinary public AST/compiler pipeline; native interpreter and CLI behavior do
not change.

```julia
compiled = compile_spec(parse_spec(source))
generated = emit_julia_source_v1(compiled, "specs/example.spec")

# Persist `generated` as UTF-8 in caller-owned storage, then load it.
include("generated_parser.jl")
value = LinkedSpecGeneratedParser.execute(input)
```

Generated Julia source is Unicode text. Canonical normalized-spec JSON and the
source identity are encoded as strict UTF-8 bytes and rendered as ASCII
hexadecimal, protecting arbitrary Unicode and Julia interpolation characters.
Unicode defines characters/code points; UTF-8, UTF-16, and UTF-32 are encoding
forms. LinkedSpec selects strict UTF-8 for this persisted boundary without
equating Unicode with UTF-8.

The scaffold proof runs valid and deliberately corrupted generated modules in
fresh processes from a caller-owned temporary project. Compiled modules are
disabled, the writable depot layer is private to the test, execution and typed
failures are exact, and the owned project/depot are deleted afterward. Julia
was the only generated-source capability gap before its family and manifest
proofs landed.

Julia's plan/direct layer is now implemented. `GeneratedRuleFamily` names the
same ten families as the neutral contract, while `GeneratedPlanRow` carries
ordered label/family pairs. `build_generated_rule_plan(...)` classifies
effective compiled rules; `validate_generated_rule_plan_v1(...)` rejects row-
count, label, known-family mismatch, and unknown-family mutations before any
parser action runs.

Validated families are not decorative. Every generated root and nested rule
entry reads the typed plan and selects regex/acode or blind/bcode structural
dispatch from that family; native interpreter calls still derive the same
choice from compiled structure. Generated traced execution adds
`generated_rule_enter`, `generated_family_decision`, and
`generated_rule_exit` with source/rule/family identity beside the native Julia
trace. One emitted module independently executes all ten families against
native interpreter values in a caller-owned offline host.

Julia admission consumes the contract's exact eight-case list. Every ordinary
or staged-function fixture equals its checked-in interpreter value before
emission. One fresh offline host loads the eight modules in separate namespaces
and checks exact values, metadata, ordered plans, trace roles, and source
identity before recursive cleanup. Contract checking locks the proof path,
count, ordering, independent load, tracing, cleanup, and absence of skips.
Julia generated source was admitted pass with all four implemented backends at
the then-current census 60/0/0. The broader live census may grow as later
capabilities are admitted.

## Why this matters

Dynamic generation is powerful, but without structure it becomes hard to trust.

LinkedSpec’s current direction is to keep the flexibility of generated handlers while making them:

- more inspectable
- more attributable
- more deterministic
- and less fragile

## What a generated handler is

A generated handler is the runtime implementation of one compiled rule.

At compile time, LinkedSpec takes the parsed rule paragraph and lowers it into runtime behavior:

```text
rule paragraph
  -> RuleIR
  -> emit context
  -> generated handler
  -> parser invocation path
```

The handler is where regex dispatch, child-rule calls, action code, lifecycle code, and returned payloads come together.

## Dispatch through dependency regexes

When a rule references child rules, LinkedSpec builds derived dependency-regex dispatch data.

The public descriptor name for that derived map is:

```text
dependency_regex_map
```

Generated handlers use it to dispatch efficiently:

```perl
LinkedRE::or($STRING, $$descr{dependency_regex_map}{Top}, $info)
```

In `consume` parse mode, the generated dispatch is contiguous:

```perl
LinkedRE::or($STRING, $$descr{dependency_regex_map}{Top}, 'consume', $info)
```

`LinkedRE::or` is the core regex composition utility (`perl/LinkedRE.pm`, 56 lines). It executes a compiled alternation of dependency regexes against the input string in either seek mode (matches anywhere) or consume mode (contiguous from the current cursor). The returned match-info hash carries an `index` field identifying which alternative matched, which the handler uses to select the correct child-rule dispatch path.

This is why dependency-regex state is part of the compiled descriptor model rather than a random sidecar.

## Handler identity

Generated handlers are attributed using stable labels.

The structured identity can include:

- rule label
- handler variant
- handler source label

The label-only form looks like:

```text
LinkedSpec::generated_handler:<rule_label>
```

When the exact variant is known, the label can become more specific:

```text
LinkedSpec::generated_handler:<rule_label>:<handler_variant>
```

This identity is valuable because dynamic code needs attribution. If a generated handler fails, the user should not have to reverse-engineer the rule from a Perl stack string.

## RuleIR and emit context

Rule compilation passes through RuleIR and an emit context.

The emit context carries the normalized action/lifecycle material consumed by `SpecEntry`.

Important active fields include:

- `ACODEs`
- `BCODEs`
- `BCALLs`
- `DEPENDENCY_REFS`
- lifecycle chunks such as `icode`, `ecode`, `lxcode`, `lscode`, `lecode`
- action-rewriter metadata

The important naming point is `DEPENDENCY_REFS`. It describes rule dependency references carried from action-code edges into compiled rule info, where the outward rule field becomes `dependency_refs`.

## Why generated handlers still matter

LinkedSpec remains a dynamic parser system. Generated handlers keep it flexible and fast for the current Perl backend.

The modernization goal is not to pretend generation does not exist. The goal is to make generation:

- compiled once where possible
- structured around explicit state
- attributed in diagnostics
- backed by regression tests
- and less dependent on opaque runtime eval behavior

## HandlerVariantEmitter and HandlerIR

The `HandlerVariantEmitter` module (`perl/LinkedSpec/HandlerVariantEmitter.pm`, about 1.6k lines) is the handler code generator. It was extracted from `SpecEntry.pm` to keep variant construction and emission in one focused module. It operates in two phases: first, a variant builder produces a `HandlerIR` hashref AST describing the handler structure; second, a backend-specific emitter consumes the IR and produces the final output (Perl source, or JSON for diagnostics).

### HandlerIR: the intermediate representation

HandlerIR is a hashref-based AST that captures everything the emitter needs without raw Perl source strings. Its keys:

- `kind` — the variant kind (one of ten: `default`, `and_bcode`, `and_single_acode`, `and_acode_seq`, `or_bcode`, `or_acode`, `rep_bcode`, `rep_and_bcode`, `rep_and_acode`, `rep_acode`)
- `label` — the rule label
- `parse_mode` — `'seek'` or `'consume'`, controlling how `LinkedRE::or` matches
- Lifecycle blocks: `preamble` (icode), `lxcode` (loop exit / no-match), `lscode` (loop start / after match), `lecode` (loop end / before collection), `ecode` (end / exhaustion), `excode` (REP exhaustion fallback), `itcode` (REP per-iteration collection)
- Dispatch refs: `acodes_ref` (array of action-code strings), `bcodes_ref` (hash of call-name to bcode string), `bcalls_ref` (ordered list of bcode call names)
- Repetition bounds (REP variants only): `rep_min`, `rep_max`
- Sequence count (AND_ACODE_SEQ only): `acode_count`
- Optional: `and_icode` (per-regex I-block, for AND rules with a regex match), `REs` (regex array, for AND_BCODE with match)

### Ten variant builders

Each `_build_*_variant` function takes a normalized argument hash (label, parse mode, lifecycle code strings, dispatch refs, node type, and optional repetition bounds) and returns either a HandlerIR hashref or `undef` if preconditions are not met (e.g., no acodes present for an acode variant).

| Builder | Returns | When used |
|---|---|---|
| `_build_default_handler_variant` | `default` | Base case: acodes present |
| `_build_and_bcode_variant` / `_build_and_bcode_sequence_body` | `and_bcode` | AND rules with bcodes |
| `_build_and_single_acode_variant` | `and_single_acode` | AND rules with single regex + acodes or I-block |
| `_build_and_acode_variant` / `_build_and_acode_sequence_body` | `and_acode_seq` | AND rules with >1 regex and >1 acode |
| `_build_or_bcode_variant` / `_build_or_bcode_choice_body` | `or_bcode` | OR rules with bcodes |
| `_build_or_acode_variant` | `or_acode` | OR rules with acodes |
| `_build_rep_bcode_variant` | `rep_bcode` | REP rules (or default with bcodes), inner OR_BCODE |
| `_build_rep_and_bcode_variant` | `rep_and_bcode` | REP_AND rules with bcodes, inner AND_BCODE |
| `_build_rep_and_acode_variant` | `rep_and_acode` | REP_AND rules with acodes, inner AND_ACODE |
| `_build_rep_acode_variant` | `rep_acode` | REP rules with acodes, LinkedRE::or + acode dispatch |

Repetition bounds are resolved by `_resolve_rep_bounds`, which maps node types (`REP_PLUS` → `[1, 10^9]`, `REP_STAR` → `[0, 10^9]`, `REP_OPT` → `[0, 1]`, `REP_OR_PLUS` → `[1, 10^9]`) or accepts explicit `rep_min` / `rep_max` overrides.

### Backend dispatch

`_emit_handler($ir, %opts)` dispatches by backend name through the `%BACKEND_EMITTERS` hash. The default backend is `perl`.

**Perl backend** (`_emit_handler_perl`). Dispatches on `kind` to one of ten template functions (`_emit_default_handler`, `_emit_and_bcode_handler`, etc.). Each template assembles a Perl source string from HandlerIR fields using helper functions:

- `_linkedre_or_expr` — builds the `LinkedRE::or(...)` call expression from label and parse mode
- `_build_acodes_dispatch_block` — builds the `if/elsif` chain over `$$minfo{index}` values
- `_build_bcodes_dispatch_block` — builds the `if/elsif` chain over `$call` values
- `_build_lmatch_extraction` — emits the common `$LMATCH`, `@LMATCH_LIST`, `%LMATCH_HASH`, `$LINDEX`, `$LSPOS` extraction block

REP variants (rep_bcode, rep_and_bcode, rep_and_acode) compose inner handlers as anonymous coderefs (`$or_code`, `$and_code`) with progress-detection guards that check whether `pos($$STRING)` advanced between iterations.

Generated Perl templates also route branch decisions through `LinkedSpec::Trace::trace_generated_handler_branch(...)`.
At `debug` trace level, non-repetition templates report match/no-match, acode/bcode dispatch, AND sequence, `LX`,
and child-result decisions. Repetition templates report loop entry, per-iteration success/failure, min-satisfied
stops, max-bound continuation/cutoff, and the bcode REP zero-progress cutoff. These trace calls return the original
branch boolean, so tracing should not change parser behavior.

**JSON diagnostic backend** (`_emit_handler_json`). Uses `JSON::PP` (Perl core since 5.14) with canonical key ordering and pretty printing. It strips `undef` and empty values, producing a clean serialized HandlerIR document. The backend is selected by setting the `$BACKEND` package variable in `SpecEntry.pm` (line 19) to `'json'`, or by passing `backend => 'json'` to `_build_handler_variants`.

### The and_icode mechanism

For AND rules that combine a regex match with per-regex I-block code, `HandlerVariantEmitter` supports an `and_icode` field on the HandlerIR. When present:

1. The emitter injects an `IMATCH ← LMATCH` bridge so I-block code can read regex captures through `$IMATCH`, `@IMATCH_LIST`, `%IMATCH_HASH`, `$IINDEX`, and `$IPOS`.
2. `return` statements in the I-block code are rewritten to `$label =` assignments, so the handler collects the result in `@collect` instead of exiting early.
3. The collected value is pushed onto `@collect` after the I-block code runs.

This mechanism avoids `MIXED_ACTIONS` and is supported in `and_bcode`, `and_single_acode`, and `and_acode_seq` variant kinds.

### Full compilation flow

```
RuleIR
  → EmitContext (normalized lifecycle/action material)
  → SpecEntry::_build_handler_variants
  → HandlerVariantEmitter::_build_*_variant  (produces HandlerIR)
  → HandlerVariantEmitter::_emit_handler      (backend dispatch)
  → _emit_handler_perl                        (Perl source string)
    or _emit_handler_json                     (JSON diagnostic output)
```
