---
id: user-function-parser-state-boundary
title: Pure functions reject known parser-state helpers while accepting explicit caller values
answers:
  - can a Rust pure function read caller captures or input_text
  - can a Dart pure function read caller captures or input_text
  - can a Julia pure function read caller captures or input_text
  - which Lua hosts verify parser-state function rejection
  - why does swapping function locals not isolate parser state
  - where is the Perl Rust pure function parser-state boundary enforced
  - does a function name starting entry or capture get rejected
  - can a pure function receive an entry_group value explicitly
  - which backends have the repaired parser-state function fence
  - can a Perl pure function call a parser rule or read gap_text
  - can a Rust pure function call a parser rule or read gap_text
  - can a Dart pure function call a parser rule or read gap_text
  - why are call and gap accessors outside the projection catalog still forbidden
date: 2026-10-27
status: all five bounded catalogued-helper backends repaired on recorded hosts; noncatalogued contexts and full admission open
tags: [functions, purity, parser-state, perl, rust]
evidence: "TYPE29.2.1 Perl13 focused groups; independent Rust29.2.2 first-native RED3/healthy1, then new4 plus direct capture4/input4 GREEN; exact retained intake packets."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/user_function_parser_state_boundary.t t/user_function_parser_context_boundary.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test user_function_parser_state_boundary --test user_function_parser_context_boundary"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/user_function_parser_state_boundary_test.dart test/user_function_parser_context_boundary_test.dart"
---

Accepted SPEC-FORMAT-TERSE.4.2.3/Phase0 entry_text negative forbids implicit parser
state in pure function bodies. Local variable isolation does not isolate parser
capture/input/mark/cursor registers. Independent public Perl and Rust probes
observe caller data before the bounded repairs; do not infer other backend bugs.

Perl Contracts derives known names from its code-owned source projection rows
plus compatibility aliases. MethodLowering checks the active function stack at
typed/legacy value and statement owners, returning existing unsupported markers
and unready metadata. See static-named-capture-lowering-and-function-fence for
static-name details and earlier reader repair29.1.

Rust Engine checks existing parser-state helper names at eager expression-call
entry, before arity/operand evaluation, using RuntimeContext's existing active
function stack through a crate-local query. Existing mark/capture membership and
explicit source/position/cursor spellings define the boundary. It returns an
ordinary descriptive function execution error; no new compiled/diagnostic schema.

Pure helpers, local assignments, nested pure calls and prefix-named user functions
such as entry_custom/capture_custom remain valid. Reader results passed explicitly
from ordinary caller actions remain valid because those arguments precede entry
to the callee's active function scope. This changes no callback vocabulary/rights.

Exact programs, source-layout refinement and actual RED limits live in
function-state-boundaries.md and the Perl/Rust intake packets under
docs/checkpoints/type-operation-inventory. Rust's three negative groups stop at
their first native route/case; later loop cases and restored/generated routes are
GREEN controls, not historical RED claims. Independent Dart/Julia/safe Lua and
rule-dispatch/private context/deferred/full admission remain owned29.2/23.4.

Dart29.2.3 independently observes three first-native negative successes contrary
to the ban; the pure-value group already passes. Interpreter now caches the known
names from existing sourceLocationProjectionRows/compatibility aliases and checks
activeUserFunctions at _evaluateCall entry before operands/statement handling.
Existing RuntimeInterpreterException names the forbidden helper; no new API/schema
or duplicate source list. Four new native/restored-SpecFile/plan groups plus direct
capture4/input4 pass, total12; selected fatal analysis/format clean. The exact
tracked test and Dart intake packet retain RED first-case limits. Julia/safe Lua
and complete context admission remain open.

Julia29.2.4 independently records45 missing-purity failures over15 authored sources
on native/plan/fresh, with3 healthy explicit-value assertions. Interpreter derives
a private cached Set from SourceLocation projection/compatibility catalogs and
checks active_user_functions before call operands/statement handling, throwing
existing RuntimeInterpreterException. All48 new and direct input12/capture12 pass
under depwarn=error; normal runner registration is present. The Julia intake
packet retains actual per-route values/errors; null-valued context reads are not
claimed non-null leaks. Safe Lua and complete context admission remain open.

Safe Lua29.2.5 independently reproduces missing rejection for15 authored controls
on native/plan/fresh per available PUC5.5.1/LuaJIT2.1.1788460057 host, with3 healthy
pure positives. Initial save_cursor(point) is corrected to current zero-arg form
before final unchanged-production RED; exact original/refined source/hosts/logs
are retained. A cache field on existing typed_source derives known names from
projection/alias catalogs; evaluate_call rejects active-function calls before
operands with existing errors/helper_name, adding no persistent chunk locals.
All controls plus direct input/capture/source-arity checks pass on both hosts;
normal registration and luac/loadfile full-runner syntax only pass. Declared5.4
remains separately owned. All five bounded catalogued-helper children are done;
29.2.6 next assesses noncatalogued call/gap/indirect roles before parent closure.

Noncatalogued parser-context29.2.6.1: Perl independently dispatches Child and reads
caller gap text/kind/span/incoming child slot in pure functions with ready metadata.
The five current parser-context roles call/entry_slot/gap_span/gap_text/gap_kind are
now explicit members of the existing Contracts predicate, reusing MethodLowering
guards/markers with raw0/unready diagnostics and no parser data. New six native/fresh
groups RED3/healthy3 become GREEN6, plus prior function-boundary4. Ordinary parser
results and gap/slot values remain valid explicit arguments. Other backends require
independent repair assessment. function-parser-context-boundaries.md and its Perl
intake own exact source/RED and known OR/LX instrument refinement; the stale neutral
executable example is separately owned29.2.6.6 before admission.

Noncatalogued Rust context29.2.6.2 independently returns child/gap text/incoming
slot records in three first-native RED groups, with ordinary explicit values
healthy. Engine adds the five current parser-context roles to its existing guard;
four new native/restored/plan and four prior function-state tests pass, plus
rustfmt/offline compile. The exact Rust packet discloses initial static plan-label
lifetime harness failure/correction and first-case RED limits. No new schema or
runtime path; ordinary parser results/gap/slot values remain explicit arguments.
Independent Dart/Julia/safe Lua context children and stale example.6 remain open.

Noncatalogued Dart context29.2.6.3 independently returns child/gaps/slot records in
three first-native RED groups, with explicit values healthy. The existing private
cache gains five current roles and reuses its pre-operand function guard. Known
helper switch dispatch precedes bound-codeblock fallback, preserving builtin roles
without a prefix or runtime-value permission inference. New4/prior4 tests pass
native/restored-SpecFile/plan, with clean format/fatal selected analysis. Exact
Dart packet discloses first-case RED limits. Independent Julia/safe Lua contexts
and stale neutral example.6/full context admission remain open.
