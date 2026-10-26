# Numeric comparison receiver results

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.15; implementation23.3.15.1-.5.
Existing short Number methods eq/ne/gt/ge/lt/le use the matching num_* helpers.
Their prior terminal boundary is intentional. The comprehensive fluent directive
adds compatible result continuations as a new feature, retaining free helper
names/signatures and lexical str_* comparisons as separate surfaces.

The scalar-numeric-v1 contract accepts finite numbers and untrimmed decimal
strings, rejects Boolean/null/container/malformed inputs, requires exactly two
free operands and returns numeric1/0 or null for invalid input. Preserve that
producer policy. One receiver RHS is required before source/operand effects.
Missing/extra receiver calls return null before effects; free arities are not
normalized. Evaluate source once, RHS once, then the result before consumer
operands, preserving captured values when later operands rebind the source.

Actual numeric/null results feed compatible scalar, numeric, text and generic
methods. Container-only consumers reject until an explicit bridge returns a
container. Targets:2.eq(2).cat("!")->1!,2.eq(3).coalesce_nonempty("late").cat("!")
->0!,2.eq(3).add(2)->2,2.eq(2).cat(",x").split(",").last().uppercase()->X.
Invalid numeric results remain null and can feed existing explicit default or
definedness consumers, e.g."x".eq(2).coalesce_nonempty(7).add(1)->8.
Cover six true/false pairs, canonical/word/symbol free controls, numeric String
inputs and invalid Bool/null/text/container controls; literal/named/selected/
count/length/reducer/Hash/function/default sources, repeated comparisons, false
presence, numeric selector use, bridges/scalar guards and SOC/once-only effects.
Deferred/callable vocabulary and full domain/context/portable admission stay23.4.
Canonical num_* method spellings are not added by this short-method result scope.

## Public Perl baseline

Retained probe_numeric_comparison_results.pl uses Get, substitution/dumps,
native and independently fresh emitted source. Six true/six false free results
are[1,1,1,1,1,1,0,0,0,0,0,0]. Decimal String02 and-.5 work; null/Bool/empty/junk/
Array/Hash and missing/extra free operands return null. Nested consumers produce
[1!,0!,2,X]. Existing terminal comparisons on named/first/length/Hash/default/
numeric String sources already produce1, preserving their numeric domain.

Short-method result continuations instead become null before source effects;
substitution lowers them to undef. Fluent effect case is[null,"",2], while its
nested producer/consumer already yields[1!,SOC,null]. Preserve that producer
capture rather than inventing a source defect. Invalid-result continuations
also stop; missing/extra receiver shapes already reject without effects.
MethodLowering _number_receiver_value_chain_return_family returns terminal for
six short comparisons and its preflight discards later links. Reuse existing
scalar result dispatch/guards while preserving helper mapping and shape checks.
Assess each other backend independently before classification or implementation.

Assessment setup: Corrected one extra closing parenthesis in the new nested
probe before recording the successful baseline. Optional canonical_flow probes
unpromised .num_* names and their current compile diagnostics; it is excluded
from normal focused replay and does not establish a promised receiver defect.
No production change or full backend/admission claim at this freeze.

## Bounded Perl implementation

23.3.15.1 classifies six short comparisons as scalar_result, keeping numeric
helper mapping and shape checks. Native/fresh shared RED becomes passing for
six pairs/numeric kinds, strict invalid inputs/defaults, source families and
SOC/once-only/result snapshots. Numeric flags still work as Array write indexes.
Two hidden bridge gaps also require shared dispatch: Number loop must consume
actual Array after split, and String prefix must hand short comparisons to the
scalar dispatcher. Public generated-handler residue and changed outer callback
calibration expose both; after repair59 focused shared/actual AST/Phase0/calibration
assertions pass. Seven ordinary outer rows intentionally update to0x/1x/read-once;
deferred and unknown-tail controls retain null/no-effects. Direct lexical/syntax
checks pass; other backends and full domain/context/portable admission remain.

## Bounded Rust implementation

23.3.15.2 independently confirms numeric1/0/strict-domain producers, free aliases,
nested SOC snapshots and numeric selector kinds on native/restored/plan. The
shared fixture/probe uses canonical -0.5 numeric literal beside String"-.5";
initial unsupported bare-.5 spelling was setup, not numeric producer RED.
Terminal fences and missing common one-RHS preflight explain shared null/SO/
twelve-effect RED. Comparisons now use existing scalar result/selected-value
handoff; obsolete Terminal state is removed. Dynamic bridges and actual source
captures remain correct. Eight focused numeric/direct/named-calibration Rust
tests and twelve shared Perl assertions pass with compilation/rustfmt. Actual
old integration expectation intentionally becomes[2,1]; full admission stays23.4.

## Bounded Dart implementation

23.3.15.3 independently confirms native/restored/plan numeric1/0/strict-domain
producers, free aliases, nested SOC and numeric selector kinds. Valid shared
continuations/bridges/defaults/source captures already work; only scalar Array[]
boundaries and24 malformed effects fail. A private canonical six-name set now
feeds common one-RHS and mayProduceScalar guards. Six focused numeric/direct
lexical/aggregate tests and fatal analysis/format pass after guard RED. Numeric
adapters/domains/free signatures and current alias surfaces stay unchanged;
Julia15.4 and complete domain/context/portable admission remain separate.

## Bounded Julia implementation

23.3.15.4 independently confirms native/plan/fresh numeric1/0/strict-domain and
canonical/word/symbol producers, numeric selector kinds and nested SOC. Valid
shared continuations/bridges/defaults/source captures already work; three shared
REDs expose scalar Array[] boundaries and24 malformed effects. Two existing tuple
additions implement common one-RHS and possible scalar-result guards.42 strict
focused numeric/direct lexical/aggregate assertions and compilation pass, including
explicit Number/not-Bool checks because Julia == accepts lookalikes. Numeric
adapters/domains/free signatures stay unchanged; safe Lua15.5/full admission follow.

## Bounded Lua implementation and rollout state

23.3.15.5 independently confirms numeric1/0/strict-domain/canonical-word-symbol
producers and nested SOC on PUC5.5.1/LuaJIT. The nonfinal-comparison fence and
missing RHS preflight explain null/SO/24-effect shared RED. Mark actual results
scalar and reuse is_comparison in one-RHS preflight; native/plan/fresh shared,
numeric selector, direct lexical/aggregate and exact actual numeric calibration
now pass on both hosts. Six former terminal_* values intentionally become2.
All five bounded implementations are targeted-checked. The safe calibration
parses valid grouped/class regex ASTs only; malformed native patterns/full
runner/declared5.4 and complete domain/context/portable admission stay separate.
