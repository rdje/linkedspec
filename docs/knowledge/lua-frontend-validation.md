---
id: lua-frontend-validation
title: Lua validates parsed source ASTs and exact function-name reservations before compilation
answers:
  - does Lua validate parsed spec ASTs
  - where is the Lua spec validator
  - what does Lua validate_spec check
  - does Lua support strict syntax validation
  - does Lua reject duplicate labels and bad edge targets
  - how many helper names are reserved against Lua user functions
  - does Lua validation execute parsers or runtime behavior
date: 2026-07-11
status: current
tags: [lua, validation, parser, AST, strict-syntax, ActionIR, functions]
evidence: "LUA-BACKEND-PARITY.2.3 adds spec_validator.lua and action_call_names.lua; .2.4 composes function projection; .3.1-.3.3 add typed ActionIR/contracts/registry. The current local gate passes 50/50 on both runtimes, 21 shipped and 102 rule-only corpus validations; the cross-language checker proves exactly 239 names."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl"
---

Public `linkedspec.validate_spec(spec, options)` accepts a typed `SpecFile`. It checks top-rule presence, duplicate
rules/functions, user-function identifiers/params/arity and collisions, raw fallback lines, mixed action/blind
edges, grouped action targets without shared code, undefined targets, regex-slot bounds, and lightweight regex
structure. Failures are typed `SpecValidationException` values with stable messages. Success returns no value.

`validate_spec(spec, { strict_syntax = true })` additionally rejects unused rules. Parsing stays permissive, so a
caller can inspect its AST before choosing validation. Validation does not compile ActionIR or execute source.

`lua/src/linkedspec/action_call_names.lua` reserves exactly all 239 current helper/control and alias names against
user-function definitions. `tools/check_language_capability_coverage.pl` now compares that set with Dart and Julia,
then retains its Perl-contract, mdBook, and 105-fixture coverage checks. The module is now shared by validation and
Lua ActionIR contracts; there is no arbitrary Lua-global fallback.

Focused validation found and fixed a parser defect in empty-body header detection: labels such as `Child:` now
start rules instead of becoming raw body text. All 21 shipped specs and all 102 rule-only corpus sources validate
on PUC Lua and LuaJIT. Three top-level function shells remain owned by `.2.4`.

Related facts: [[lua-core-spec-parser]], [[lua-frontend-ast-json-contract]], [[lua-actionir-contract-resolver]],
[[dart-frontend-validation]], [[julia-frontend-validation]], [[text-to-ast-backend-doctrine]].
