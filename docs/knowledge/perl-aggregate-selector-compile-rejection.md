---
id: perl-aggregate-selector-compile-rejection
title: "Perl rejects exact aggregate selectors structurally before ActionIR lowering"
answers:
  - "how does Perl reject array name and hash name selectors"
  - "what is the Perl aggregate selector removed diagnostic"
  - "are aggregate selectors rejected inside dead code"
  - "are aggregate selectors rejected inside unused user functions"
  - "why was the unsupported ActionIR helper sentinel insufficient"
  - "which array and hash constructors remain valid on Perl"
  - "does generated Perl sigil storage count as a spec selector"
date: 2026-07-12
status: current
tags: [perl, actionir, compiler, bindings, compatibility, retirement, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.1 adds canonical AST validation in perl/LinkedSpec/ActionIR/RewritePipeline.pm and user-function registry validation in perl/LinkedSpec/UserFunctionRegistry.pm. All six neutral invalid-selector cases fail direct lowering, live compilation, and generated-source emission with exact portable fields; dead code and unused function bodies fail too. Eight retained constructor/literal classes execute. Focused proof passes 41 tests and standalone Phase 0 passes 1..1031."
reverify: "prove -Iperl t/uniform_binding_contract.t t/trace_emit_context_bridge.t t/trace_actionir_method_lowering.t t/actionir_ast_parser.t && bash tools/run_python_project_data.sh tools/check_executable_aggregate_selector_sources.py"
---

# Perl aggregate-selector compile rejection

Perl parses canonical ActionIR, walks the resulting AST for exact `array` or `hash` calls with one bare identifier,
and throws `aggregate_selector_removed surface=<array|hash> identifier=<name> replacement=<name>` before lowering.
The walk is structural, so whitespace, nesting, receiver continuations, and unreachable branches cannot bypass it.
Live parser construction reports the failure through the compiler pipeline, and generated-source emission preserves
the same diagnostic detail.

User-function bodies require a second boundary: the registry validates every normalized body when functions are
staged, including functions never called by a rule. Otherwise an unused function would never reach ordinary
ActionIR lowering and could retain removed syntax indefinitely.

The old unsupported-helper sentinel was not sufficient because it was generated Perl that could compile and yield
`undef`; hard retirement requires compilation itself to fail. Rejection is exact: `array()`, `array("items")`,
`array(copy(items))`, multi-argument arrays, `hash()`, valid key/value hashes, and direct `[...]` / `{ ... }`
literals remain valid. Generated Perl `$name`, `@name`, and `%name` are private backend implementation storage and
do not expose selector namespaces to `.spec` authors.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[spec-facing-aggregate-selector-retirement-inventory]].
