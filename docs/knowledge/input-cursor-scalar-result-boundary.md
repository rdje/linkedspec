---
id: input-cursor-scalar-result-boundary
title: Readonly input and cursor scalar results need typed composition before legacy substitution
answers:
  - can input_text split into an indexed String entry directly
  - why does cursor_rest coalesce leave an undefined host helper
  - why does a named input reader default work while its direct chain fails
  - which task owns input and cursor scalar result continuations
  - why can a scalar set_key block produce invalid Perl despite ready metadata
  - why does quoted match_has fail while a bare capture name works
  - did the first context scalar probe inspect the correct rule metadata
  - how does Rust guard direct input reader results and preserve malformed call policies
  - do Dart input reader guards preserve malformed call count policies
  - how do Julia input reader results retain actual kinds through with
  - why do malformed Lua input readers retain typed arity errors
date: 2026-10-27
status: bounded27/28.1/29.1 repairs complete; remaining function boundary29.2 next; full admission separate
tags: [perl, fluent, source-location, input, cursor, scalar]
evidence: "TYPE23.1.7 public native/fresh/Value descriptor/substitution packets at af1fda392; input-cursor-results.md and current typed source-location contracts."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/input_cursor_results_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/input_cursor_results_test.lua"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/input_cursor_results_test.jl\")'"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/input_cursor_results_test.dart"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test input_cursor_results"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/input_cursor_result_continuations.t"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_context_scalar_results.pl named_input_cursor_defaults direct_input_cursor_defaults input_cursor_consumer_rejection"
---

Existing direct match/input String split flows and bare capture-presence helpers
work. Named input/cursor defaults yield ALPHA/11/!/1; direct defaults instead fail
emitted compilation near )[ and simpler cursor_rest coalesce/cat leaves a host
coalesce call. Input scalar take/set_key block operands also fail near {{, with
Value raw0/unresolved0/ready1. MethodLowering's typed Call fallback lacks several
getters known only to later Contracts substitution; failed fluent lowering then
leaves DSL alongside emitted source. Existing legacy consumer dispatch lacks the
actual-result guard and leaves a set_key key block authored.27.1 owns proper
reader/result composition through existing getter owners, without cursor effects.

The first six-case instrument inspected Top rather than action-bearing Value.
Its exact bytes/stdout/stderr plus refinement writer remain in the first gzip
capsule, and are not action-bearing readiness proof. Corrected nine-case and three
input/cursor packets inspect Value. Native child errors can be diagnostic stdout
with an outer [null] result; fresh compiled/execute channels distinguish failure.
The original preludes and existing SESSION7 setpgid EPERM are retained/disclosed.

Constant literal/named/context scalar take/set_key roots retain legacy []/Hash
policies, while cat/add scalar prefixes enable clean null guards.28.1 owns policy
assessment and actual block-key compiler repair before admission. Quoted capture
names leave known host calls with ready metadata; bare names lower. Contracts'
bare-only rewrite/unresolved patterns explain this distinction.29.1 owns intended
static syntax/lowering-or-rejection/readiness and book clarification before
admission. Neither finding is treated as a successful null read or fixed here.

Frozen target/shared fixture and independent27 children preserve eleven readonly
input/cursor readers, signatures/bounds/kinds/source order/defaults and compatible
String/Number/inter-type methods. No new helper/type/AST field/callback/write/copy
or legacy root policy is selected. Full admission stays23.4.


Perl27.1 shares the ten zero-argument getter bodies with native contract rewriting
and uses the existing input_slice lowering. Exactly eleven static source shapes
now enable typed actual-result dispatch. A first candidate repairs ordinary reader
chains but loses origin through the legacy trailing-with source rebuild. The
retained candidate/repaired AST/substitution packet shows the raw block Hash key
before repair. Folding only reader-owned with prefixes through existing AST nodes
retains that origin, including fluent prefixes, without changing parser/schema.

Five new native/fresh/Value raw0/unresolved0/ready1 groups pass; expanded with
controls also pass independently for Array/Hash/Bool results and outer restoration.
Shared all-spelling output, empty/zero/kinds, source SWC/snapshots, lazy defaults,
String split/signed/String transitions, typed Number index and operand skips hold.
Direct defaults13 and source-location contract4 pass. No cursor/bounds/projection,
callback/control/free/named legacy policy or generated field changes. Rust27.2
independently follows; full23.4/28.1/29.1/registration/pressure owners remain.


Rust27.2 independently records three failing result cases and a healthy source/
default/named/snapshot case. All routes already preserve reader values/coordinates,
lazy defaults and with's returned container/Bool kinds and outer restoration.
Missing static source ownership bypasses existing actual-kind guards in ordinary
and trailing-block dispatch. One predicate for ten zero-argument readers and
two-argument input_slice now enables those guards at both entrypoints. Four new
cases pass native/restored CompiledSpec/plan with Top/Value rows; computed six
also pass. Shared all-spelling SWC/positions/kinds/lazy/split/signed values, Number
selectors, actual returned with kinds and scope are preserved; operands skip.
Malformed input_text-extra/missing-input_slice counts10/0 and bound/flat counts0
remain. No getter/parser/source-coordinate/bounds/serde/free-arity/callback policy
change. Offline compile/rustfmt pass; Dart27.3 independently follows.


Dart27.3 independently observes three RED result cases and one healthy source/
default/named/snapshot case. Existing getters/coordinates/with returned kinds work;
only the static source flag is absent. Ten zero-argument readers plus two-argument
input_slice, matching sourceMethod/name and no trailing block, now enable the
existing kindGuardedResult through with/bridges. Four execution cases pass native/
restoredSpec/plan and computed seven also pass, plus format/fatal analysis. Shared
SWC/positions/kinds/lazy/split/signed data, Number indices, returned with Array/
Hash/Bool and outer scope hold; consumer operands skip. Dart malformed reader
counts0/0 and bound/flat counts0 remain; the initial borrowed Rust malformed
oracle was corrected before final unchanged-production RED. No getter/parser/
source coordinate/bounds/codec/free/callback policy change; Julia27.4 follows.


Julia27.4 independently observes nine RED route comparisons and three healthy
source/default/named/snapshot controls. A static ten-zero-argument/two-argument-
input_slice predicate, matching name/source_method and excluding trailing blocks,
now enables the existing kind_guarded_result through with/bridges. All12 new
native/plan/fresh strict Bool/Number/String/null/container comparisons and
computed25 pass, with --depwarn=error and normal registration. Shared SWC/
positions/kinds/lazy/split/signed values, Number indices and returned with Array/
Hash/Bool/outer restoration hold; operands skip. Malformed reader/bound/flat
counts0 remain. No getter/parser/coordinate/bounds/compiled/free/callback policy
change; safe Lua27.5 follows.


Safe Lua27.5 independently records nine RED result comparisons per available host,
with healthy source/default/named/snapshot and malformed-source controls. A new
function field in the existing private receiver table reuses INPUT_CURSOR_HELPERS
and name/source_method/no-trailing/zero-two operand shapes to enable existing
kind_guarded_result. No new chunk locals or getter/table/schema changes. Four
execution groups pass native/plan/fresh on PUC5.5.1/LuaJIT2.1.1788460057, plus two
source-error groups on those routes. Lua malformed input_text/input_slice retain
native helper_arity_mismatch fields and generated message text, unlike other
backends' legacy counts. Shared SWC/positions/kinds/lazy/split/signed data, Number
indices, returned with Array/Hash/Bool/outer scope and operand skips pass; scalar
counts yield null and bound/flat counts0 remain. Direct computed six groups and
luac/loadfile/normal registration pass. All bounded27 children complete;28.1 then
29.1 follow before admission, with declared5.4/full23.4/pressure/registration separate.


28.1 resolves the broader first-consumer policy from aggregate snapshot authority:
legacy []/constructed-Hash fallbacks stay. It repairs eager set_key block keys and
source/key/value staging, including a real before-to-after key snapshot defect;
working native/fresh metadata and required/cold helper passthrough controls pass.
Current mechanism/target belongs to terse-hash-receiver-value-chains.md and
set-key-operands.md. Capture-name29.1 remains next before admission.


29.1 completes ordinary static bare/quoted named capture lowering and explicit
unsupported shapes. It also confirms an input_text pure function could read caller
x with ready metadata; the accepted parser-state ban now fences the four named and
eleven input/cursor readers touched here, retaining explicit caller arguments.
Mixed named function probes fail/unready and are not successful frame controls.
Current details belong to static-named-capture-lowering-and-function-fence.md;
remaining family/context purity is independently owned29.2 before admission.
