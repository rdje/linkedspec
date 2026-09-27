# Bounded nested-tree readiness

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1`, verified 2026-09-27 from clean `fa8b0e8af`.

The grammar at `tests/language-readiness/nested-tree/grammar.spec` and its independently authored
`cases.json` remain unchanged. The six accepted inputs cover empty input/list, nested scope, multiple forms,
CRLF and supplementary Unicode. Seven malformed inputs cover trailing/interstitial text, skipped prefix,
missing inner/outer close, a bare document atom and an unmatched close. This small language has no string,
comment, escape or standard-format conformance claim.

## Current reconciliation

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3`. The native checkpoint and all backend carrier children
are complete. This milestone closes only the bounded nesting objective; its exact staged canonical receipt
governs landing. Context-dependent matching (.1.1.3.2), lossless child parsing (.1.1.3.3), gap selection and the
structured-format readiness gate remain open. The dated sections below preserve how the evidence accumulated.

| Runtime | Verified carrier routes | Retained parser routes | Immediate typed rejection/recovery transitions | Proof source |
| --- | ---: | ---: | ---: | --- |
| Perl | 2 | 2 | 28 | `t/nested_tree_readiness.t`, native variant loop and fresh child artifact loop |
| Rust | 6 | 4 | 56 | `rust/linkedspec-runtime/tests/nested_tree_readiness.rs`, in-process and emitted tests; shared `rust_checks.rs` |
| Dart | 6 | 4 | 56 | `dart/test/nested_tree_readiness_test.dart`; shared `dart_checks.dart` |
| Julia | 5 | 2 | 28 | nesting testset in `julia/test/source_emitter_test.jl`; shared `julia_checks.jl` |
| PUC Lua | 5 | 2 | 28 | nesting block in `lua/test/rule_local_cursor_generated_source_test.lua`; shared `lua_checks.lua` |
| LuaJIT | 5 | 2 | 28 | same Lua consumer executed under the second ABI |

Shared checkers reside in `tests/language-readiness/nested-tree/`. Each route executes the original grammar 40
times: two rounds of six accepted cases and seven rejection/immediate-success pairs. Each also exercises three
separate grammar mutations. These are repeated executions of13 authored cases, not a large independent corpus.
All carrier rejection checks require the runtime's typed exit with status1 and reject successful null-like values.
The original native text adapter's Rust Display limitation remains unchanged.

Perl retains the native closure and loads each emitted module once before its sequence. Rust and Dart retain
native and reconstructed engines in both native and generated-plan modes. Julia and both Lua ABIs retain only
native and reconstructed engines. Their remaining public v2/emitted entry routes create an engine per call:
subsequent success there proves call isolation, not restoration of an existing engine. Perl's descriptor proves
all five rules ActionIR-ready; emitted metadata/source identities and plan validators provide the other stated
carrier checks. These distinct public surfaces are not one universal descriptor API.

### Authoring cost and limits

The unchanged grammar has 33 physical lines (29 nonblank), five rules, five rule-regex slots and eight outgoing
edges. Counts describe this source, not a complexity or performance benchmark.

| Concern | Authored mechanism and source location | Assessment |
| --- | --- | --- |
| Recursive structure and local state | `grammar.spec` List entry/recursive edge, lines19–24: save `start`, build `items`, recursively call List, return a typed harray | Direct composition; parent bindings survive nested calls in the authored oracle. |
| Complete recognition | Top entry prefix guard lines3–6; Invalid edges11/25; Top end-position guard12–15; List end rejection26 | Explicit guard work in several lifecycle locations. The duplicated Invalid edge and separate prefix guard are authoring costs of this grammar. |
| AST and provenance | List return24 and Atom return29 explicitly construct kind, span, items/text | Predictable but verbose; all values and half-open Unicode scalar positions are authored. Container kind belongs to the value, independent of binding spelling. |
| Failure reporting | `exit_now(1)` at the guards and catch-all edges | Exact typed rejection is verified; reason-specific messages, expected-token lists and error recovery are not supplied by this grammar. |
| Oracle sensitivity | Prefix removal, removal of both Invalid edges, list-start replacement in each shared checker | Each mutation creates the intended wrong acceptance or span; this is targeted sensitivity, not exhaustive mutation coverage. |

No new primitive is required by this bounded nesting result. Do not infer broader ease of authoring or language
completeness: context-dependent and lossless objectives still need execution before .1.1.4 selects improvements.
There is no quoted-string, escape, comment, standard-format, arbitrary-depth, resource-limit, cancellation,
performance or speculative AST-rollback proof here. Typed rejection followed by a fresh invocation is not
in-document error recovery. The known recognition-abort and other startup defects remain separately owned.
Dart's two SDK deprecations and Lua's malformed-regex path retain their existing owners; optional unfiltered
backend gates are not claimed by this milestone.

The reconciliation checkpoint audits every earlier carrier/repair source hash and 42 retained evidence logs.
The sole superseded source is the Lua storage script repaired by .1.1.3.1.2.2.6; its current hash matches that
repair checkpoint. All six native logs are also hash-checked. The later .7 warning repair re-ran Perl nesting
within its focused218 tests and complete Phase01033; the original grammar and cases stayed byte-exact.

## Public native results

| Runtime | Accepted cases | Rejected cases | Accepted parses through one engine | Error projection |
| --- | ---: | ---: | ---: | --- |
| Perl | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| Rust | 6 | 7 | 12 | published adapter Display: exit_now(1) |
| Dart | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| Julia | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| PUC Lua | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| LuaJIT | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |

All six public loaders compile the same grammar. Every accepted AST, scalar kind and half-open Unicode span
matches the authored oracle, first forward then in reverse order through one engine. Every rejected input
produces no result. The verifier hashes grammar, cases, public adapter and prepared product/config inputs
before and after execution. It uses the published integration APIs and does not inspect dependency internals.

Run each runtime after the corresponding public integration example is prepared:

```sh
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime perl
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime rust
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime dart
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime julia
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime puc
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime luajit
```

The Rust integration binary is rebuilt through the documented locked offline command. Dart uses the retained
integration package config; Julia uses its application-local project/depot with offline loading; both Lua ABIs
use their retained native modules. All project data remains on the repository volume. The verifier derives
paths from its current checkout; no persisted machine-specific path is required.

## Limits at the native checkpoint

The text adapters exit at the first rejection, so this trial does not prove recovery after rejection in the
same engine. Rust's Display output is also not typed-diagnostic evidence. The earlier Perl test separately
covers native/fresh emitted rejection recovery. Supported reconstructed/generated/emitted routes, descriptors,
and independent prefix/gap/span mutations were then assigned to `.1.1.3.1.2.2`. The completed child evidence
and canonical reconciliation above supersede that scheduling statement. The broad format campaign remains gated.

Exact source/product/log hashes are in `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1-verification.json`.

## Subsequent Perl carrier proof

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1` repairs emitted public-entry trivia drift exposed by the prefix
mutation. The separate `t/nested_tree_readiness.t` passes192 tests and verifies five ready rules,40 original
executions per native/fresh emitted route,14 immediate typed-rejection recoveries per route, three controlled
mutants,14 repeated entry cases and two child-entry controls. Focused274 and complete Phase01033 pass. At that checkpoint, other
backends' carriers and canonical parent reconciliation remained separate; the native adapter table above is unchanged.

## Subsequent Rust carrier proof

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2` adds `rust/linkedspec-runtime/tests/nested_tree_readiness.rs`
and shared `tests/language-readiness/nested-tree/rust_checks.rs`. Native and JSON-reconstructed engines each run
native and generated-plan execution: four retained-engine routes. Serialized v2 and freshly compiled emitted
modules add two routes that construct an engine per call. Each passes40 original executions (two rounds of six
accepts and seven reject/recovery pairs) and three controlled prefix/gap/span grammar mutations. Typed errors
require Exit with status1. Exact JSON values/kinds and Unicode spans match unchanged independent oracles.
Only the four retained-engine routes establish same-engine recovery:14 transitions each,56 total.

The emitted crate verifies four modules in four actual tests, v2 metadata/source identity and plan validation.
Its child process must exit successfully; a passing-test marker alone cannot establish success. Scratch data and
its separate target cache stay on the repository volume; its authored runtime dependency is relative. Two outer
Rust tests pass, together with three leading-trivia and one strict-document compatibility tests. Runtime code,
lockfile and original fixture are unchanged. Exact commands/hashes are in the leaf checkpoint; the native adapter
counts above are not relabeled as typed evidence. At that checkpoint, Dart, Julia and Lua carriers remained separate work.

## Subsequent Dart carrier proof

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3` adds `dart/test/nested_tree_readiness_test.dart` and shared
`tests/language-readiness/nested-tree/dart_checks.dart`. Native and SpecFile-JSON reconstructed engines each run
native and generated-plan execution: four retained-engine routes. Public v2 and independently loaded emitted
modules construct an engine per call. All six pass 40 original executions and three grammar mutations. Every
rejection requires RuntimeExitNow status1; a returned value, including null, fails. Exact recursive JSON-kind,
value and Unicode-span checks use the unchanged authored oracles. Retained engines prove 56 recovery transitions.

The repository-local emitted package uses a relative Dart dependency, offline resolution, fatal analysis and a
fresh process. All three commands require exit0; its exact completion report follows execution of four modules,
40 original calls and three mutations. New tests2 and existing emitter/document tests58 pass. Changed-file fatal
analysis and zero-change formatting pass. Whole-package analysis exits2 with only the known two deprecated_implement
warnings at matching.dart:732/1203, owned by DART-STARTUP-READING.2.25. Runtime, lockfile and fixture are unchanged;
no complete component-gate success is claimed. At that checkpoint, Julia and Lua carrier proof was next.

## Subsequent Julia carrier proof

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4` extends `julia/test/source_emitter_test.jl` and adds shared
`tests/language-readiness/nested-tree/julia_checks.jl`. Native and SpecFile-JSON reconstructed engines provide two
retained routes. Generated v2 for each compiled form and fresh emitted modules provide three per-call routes.
All five pass40 original executions and three mutations; the two retained engines prove28 immediate recoveries.
The checker distinguishes JSON boolean and number kinds despite Julia's Bool subtype, preserves exact spans and
requires RuntimeExitNow status1; successful nothing does not count as rejection. No private runtime keyword is used.

Four fresh emitted modules validate metadata/plans and execute under the existing offline private-depot host.
The first new host failed29/30 because world-age warnings preceded its successful JSON report. Captured warnings
identified direct reads of newly included bindings; latest-world binding lookup and invocation fix the harness.
Final report parsing remains exact, with no warning filtering. The child exits successfully and scratch cleanup
is verified. Focused proof passes new30, existing emitter65 and strict-document128 assertions (223 total).
Storage retains22 existing temporary owners and five package trees; original grammar/cases/runtime/manifests are
unchanged. At that checkpoint, Lua and canonical parent reconciliation remained.

## Subsequent Lua/LuaJIT carrier proof

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5` extends the existing
`lua/test/rule_local_cursor_generated_source_test.lua` consumer and adds shared `lua_checks.lua` beside the fixture.
Each ABI proves five routes: native and SpecFile-JSON reconstructed engines, v2 entry for each compiled form and
fresh emitted modules. All five pass40 original calls and three mutations. Only the two native routes retain an
engine, proving28 immediate recoveries per ABI. Every rejected input requires typed RuntimeExitNow status1.
Canonical JSON compares tagged arrays/objects, numbers/strings/booleans and exact Unicode spans.

The existing managed owner writes four modules and launches the exact selected ABI with inherited source/native
paths. Metadata/plans and completion are exact; child status must succeed, stderr must be empty and the owned
workspace must disappear. Each ABI passes133 v2 assertions (106 existing plus27 new),51 strict-document cases,
27 round trips and24 post-rejection recovery checks. Runtime, original fixture and adapters are unchanged.

Storage verification completes19-owner/three-module dual-ABI/device/owned-cleanup checks, but its legacy-residue
census reports a permission error while the script still returns0/PASS. At that checkpoint, new P1 .1.1.3.1.2.2.6 owned immediate repair
and controlled failure proof before canonical reconciliation. This is not successful legacy-census evidence or
an unfiltered full Lua gate; LUA-STARTUP-READING.2.3 still owns the malformed-regex native path separately.

## Subsequent storage verification repair

SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6 preserves the earlier incomplete census as failed evidence and repairs
its conditional error handling. Thirty exact process/output assertions and the real dual-ABI19-owner oracle pass.
An adjacent audit preserves24 original Perl allocators and registers the two later managed tests plus this new
regression, producing a verified27. Exact staged canonical proof governs infrastructure landing; this adds no
parser or format capability. The current .1.1.3.1.2.3 reconciliation above includes this repair without changing its original evidence.
