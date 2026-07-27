---
id: dart-lua-fixed-lookbehind-support
title: Dart and both Lua ABIs execute the fixed-width lookbehind used by spec.spec
answers:
  - does spec.spec use lookbehind
  - do Dart and Lua support spec.spec negative lookbehind
  - do both PUC Lua and LuaJIT support lookbehind
  - why do Lua patterns not determine LinkedSpec regex support
  - which engine handles Lua LinkedSpec lookbehind
  - is lookbehind a current spec.spec portability blocker
  - which regex engine does the current Rust variant use
date: 2026-07-11
status: current
tags: [regex, lookbehind, spec.spec, dart, lua, PCRE2, ECMAScript, portability]
evidence: "specs/spec.spec line 109 uses the one-character fixed-width negative lookbehind (?<!\\). LUA-BACKEND-PARITY.4.3.1 adds positive and negative lookbehind assertions to the shared native matcher test, which tools/run_lua_local.sh runs through separately compiled PUC Lua and LuaJIT PCRE2 modules. The installed Dart VM executes the real manifest case with `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case spec_spec_minimal_rule`: 1 passed, 0 failed. Dart's official RegExp API states Dart regex syntax/semantics follow ECMAScript. Rust imports rgx_core::Regex in parser/validation/runtime; RUST-FUNCTIONAL-PARITY records RGX as the adopted active engine with PCRE2-level features. Director clarification 2026-07-11 characterizes RGX as approximately 98% PCRE2 compatible."
reverify: "bash tools/run_lua_local.sh && (cd dart && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case spec_spec_minimal_rule)"
---

## Fact

`specs/spec.spec` line 109 uses `(?<!\\)` to require that a regex delimiter is
not immediately preceded by a backslash. This is a zero-width, one-character
fixed-width negative lookbehind.

Both supported Lua runtimes execute it. PUC Lua and LuaJIT load separately
compiled ABI modules, but both modules bind the same PCRE2 provider. Lua's
built-in pattern language is irrelevant to `.spec` regex semantics. The shared
gate permanently tests positive lookbehind, a successful negative lookbehind,
and rejection when the preceding backslash is present.

Dart's runtime matcher uses `dart:core RegExp`, whose official contract follows
ECMAScript syntax and semantics. More importantly, the real
`spec_spec_minimal_rule` corpus fixture containing the actual pattern passes the
installed Dart parse/compile/runtime path.

Therefore fixed-width lookbehind in current shipped specs is not a Dart or Lua
gap. This does not claim that every arbitrary or unbounded lookbehind form is
portable.

The Rust variant currently uses `rgx_core::Regex` in parser, validation, and
runtime—not the earlier basic `regex`-crate path. RGX was adopted specifically
for PCRE2-level features such as lookaround, backreferences, and subroutine
calls, and the project characterizes it as approximately 98% PCRE2 compatible.
References to the basic crate describe an earlier historical milestone, not the
current Rust engine.

Related facts: [[lua-runtime-matching-state]], [[dart-runtime-matching-state]],
[[spec-regex-feature-contract]], [[lua-runtime-core-value-capture-helpers]].
