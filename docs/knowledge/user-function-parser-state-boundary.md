---
id: user-function-parser-state-boundary
title: Pure functions reject known parser-state helpers while accepting explicit caller values
answers:
  - can a Rust pure function read caller captures or input_text
  - can a Dart pure function read caller captures or input_text
  - can a Julia pure function read caller captures or input_text
  - why does swapping function locals not isolate parser state
  - where is the Perl Rust pure function parser-state boundary enforced
  - does a function name starting entry or capture get rejected
  - can a pure function receive an entry_group value explicitly
  - which backends have the repaired parser-state function fence
date: 2026-10-27
status: bounded Perl Rust Dart Julia repaired; independent safe Lua and full context admission open
tags: [functions, purity, parser-state, perl, rust]
evidence: "TYPE29.2.1 Perl13 focused groups; independent Rust29.2.2 first-native RED3/healthy1, then new4 plus direct capture4/input4 GREEN; exact retained intake packets."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/user_function_parser_state_boundary.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test user_function_parser_state_boundary"
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
