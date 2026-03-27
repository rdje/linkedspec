# ARCHITECTURE STATE
Live architecture snapshot for LinkedSpec.

This document is the current high-level technical reading of the project shape. It is meant to steer implementation, record important architectural judgments, and give future sessions a fast way to re-enter the codebase with the right mental model.

## Status
- Last refreshed: `2026-03-27`
- Scope of this snapshot:
  - `perl/LinkedSpec.pm`
  - the main owner modules it dispatches into
  - the ActionIR lowering subtree
  - the current legacy plugin/runtime branch

## Maintenance Policy
- Treat this as a live document, not a one-off memo.
- Refresh it at the start of a new session when the current architectural reading has changed materially or when a new deep codebase pass produces a better model.
- Update it when package ownership, major runtime boundaries, compile/lowering seams, or strategic judgments shift.
- Keep it aligned with:
  - `README.md` for discoverability,
  - `ROADMAP.md` for execution direction,
  - `DEVELOPMENT_NOTES.md` for rationale,
  - `MEMORY.md` for interruption-safe continuity.

## Executive Summary
- `perl/LinkedSpec.pm` is now a deliberately thin lazy facade rather than the real implementation center.
- Its static import tree is intentionally shallow; the real architecture is the lazy owner tree it dispatches into.
- `LinkedSpec::OwnerDispatch` is now the small shared seam for thin-wrapper lazy loading, callback/value lookup, and delegated owner calls.
- The practical core path is:
  - `ParserFactory -> Runtime -> Compiler`
- The frontend syntax/bootstrapping truth still concentrates in:
  - `BootstrapSpec::Core`
  - `Validation`
- Rule compilation and emitted runtime behavior still concentrate in:
  - `SpecEntry`
  - `RuleIR`
  - `RuleIR::EmitContext`
- Backend-neutral action semantics now largely live in:
  - `LinkedSpec::ActionIR::*`
- `RuntimeContext` is one of the cleanest and most important boundaries in the tree.
- Dynamic plugin loading is still present in the public facade, but current project direction treats it as legacy-removal territory rather than a feature family to preserve.

## LinkedSpec Facade Reading
`perl/LinkedSpec.pm` does almost no real work itself. Its main roles are:

- expose the public API,
- lazily load owner modules,
- preserve `$@` across owner dispatch through `LinkedSpec::OwnerDispatch`,
- normalize flat option pairs,
- re-export trace-oriented globals from `LinkedSpec::Trace`.

Its direct static imports are intentionally narrow:
- `File::Basename` at `BEGIN` time for local path setup,
- `LinkedSpec::OwnerDispatch` for shared lazy owner dispatch.

That means the important import tree is the runtime owner tree, not the `use` list in `LinkedSpec.pm` itself.

The facade surface currently falls into four bands.

### Trace Surface
- `configure_trace`
- `trace_enter`
- `trace_exit`
- `trace_decision`
- `log_output`
- `log_dump`
- `should_dump`

### Compile/Runtime Surface
- `Get`
- `spec_descr`
- `call_spec_handler_subst`
- `get_parser`

### Registry Maintenance Surface
- `register_plugin`
- `register_plugins`
- `clear_registered_plugins`

### Legacy Transition Surface
- `run_plugin`
- `get_plugin`
- `dispatch_plugin_autoload_name`
- `AUTOLOAD`

The important conclusion is that `LinkedSpec.pm` should be read as a facade and routing layer, not as the place where most semantics live anymore.

One supporting detail matters now: the repeated thin-wrapper plumbing for lazy package loading, callback/value lookup, delegated owner calls, and `$@` preservation is no longer reimplemented separately in each owner. `LinkedSpec.pm`, `LinkedSpec::Trace`, `Runtime.pm`, `ParserFactory.pm`, `BootstrapSpec.pm`, `BootstrapSpec::Core`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR.pm`, `RuleIR::EmitContext.pm`, `Resolver.pm`, `Validation.pm`, and `ActionRewriter.pm` now share that seam through `LinkedSpec::OwnerDispatch`, and the same seam is now also being spent inside active ActionIR owners such as `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::StatementSplit::Core`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ControlFlow`, `LinkedSpec::ActionIR::Contracts`, `LinkedSpec::ActionIR::MethodLowering`, and `LinkedSpec::ActionIR::DeclareMethod`.

## Current Owner Tree
The current practical owner tree is:

```text
LinkedSpec
├─ LinkedSpec::OwnerDispatch
├─ LinkedSpec::Trace
├─ LinkedSpec::Runtime
│  ├─ LinkedSpec::RuntimeContext
│  └─ LinkedSpec::Compiler
│     ├─ LinkedSpec::Trace
│     ├─ LinkedRE
│     ├─ LinkedSpec::BootstrapSpec
│     │  └─ LinkedSpec::BootstrapSpec::Core
│     │     └─ LinkedRE
│     ├─ LinkedSpec::SpecEntry
│     │  ├─ LinkedSpec::RuleIR
│     │  ├─ LinkedSpec::RuleIR::EmitContext
│     │  │  ├─ LinkedSpec::ActionIR::RewritePipeline
│     │  │  ├─ LinkedSpec::ActionIR::MethodExpr
│     │  │  ├─ LinkedSpec::ActionIR::Scanner
│     │  │  │  └─ LinkedSpec::ActionIR::ScannerCore
│     │  │  │     ├─ Scanner::PrimitiveBasicRules
│     │  │  │     ├─ Scanner::PrimitivePipelineRules
│     │  │  │     ├─ Scanner::FlowRules
│     │  │  │     └─ Scanner::LegacyRules
│     │  │  ├─ LinkedSpec::ActionIR::CanonicalEvents
│     │  │  │  └─ CanonicalEvents::Core
│     │  │  ├─ LinkedSpec::ActionIR::Diagnostics
│     │  │  ├─ LinkedSpec::ActionIR::StatementSplit
│     │  │  │  └─ StatementSplit::Core
│     │  │  │     └─ StatementSplit::Mode
│     │  │  ├─ LinkedSpec::ActionIR::Contracts
│     │  │  ├─ LinkedSpec::ActionIR::FlowExpr
│     │  │  ├─ LinkedSpec::ActionIR::ArrayPipeline
│     │  │  ├─ LinkedSpec::ActionIR::ControlFlow
│     │  │  ├─ LinkedSpec::ActionIR::MethodLowering
│     │  │  ├─ LinkedSpec::ActionIR::DeclareMethod
│     │  │  ├─ LinkedSpec::ActionIR::ValueExpr
│     │  │  └─ LinkedSpec::Trace
│     │  ├─ LinkedSpec::Trace
│     │  └─ LinkedSpec::RuntimeContext
│     ├─ LinkedSpec::Validation
│     └─ LinkedSpec::RuntimeContext
├─ LinkedSpec::ParserFactory
│  ├─ LinkedSpec::RuntimeContext
│  ├─ LinkedSpec::Trace
│  ├─ LinkedSpec::Resolver
│  └─ LinkedSpec::Runtime
├─ LinkedSpec::PluginRegistry
└─ LinkedSpec::PluginBridge
   ├─ LinkedSpec::PluginRegistry
   └─ PPlugin
      └─ LinkedSpec
```

## What the Main Owners Do
### `LinkedSpec::Trace`
- owns trace state, indentation, formatting, verbosity, and output routing,
- lazily uses `Data::Dumper` only when needed,
- now also owns richer trace rendering such as mark-position pointer excerpts.

### `LinkedSpec::Runtime`
- owns the small orchestration layer around the compile pipeline,
- builds or normalizes runtime context,
- delegates into `Compiler`,
- writes fallback runtime-owner errors only when deeper owners did not already write a structured failure.

### `LinkedSpec::RuntimeContext`
- owns shared runtime state and structured error payload helpers,
- owns parser-source chunk capture helpers,
- carries `spec_name`, `spec_path`, `top_rule`, and `last_error`,
- is one of the cleanest and highest-value seams in the project.

### `LinkedSpec::ParserFactory`
- owns `get_parser(...)`,
- validates the requested spec name,
- resolves the target `.spec`,
- loads file content,
- prepares trace/runtime context,
- delegates actual compilation to the runtime/compiler path.

### `LinkedSpec::Resolver`
- is the real owner of named spec lookup,
- resolves direct paths first,
- tries module-relative spec paths next,
- falls back to `PathSearch` last.

This module, not the plugin branch, is the real home of the "ask for `foo`, get `foo.spec`" behavior.

### `LinkedSpec::Compiler`
- is the main compile pipeline coordinator,
- owns validation/bootstrap/descriptor-build orchestration,
- carries much of the compile-stage structured-diagnostics normalization,
- is one of the project's main implementation centers.

### `LinkedSpec::BootstrapSpec` and `LinkedSpec::BootstrapSpec::Core`
- own the hardcoded bootstrap grammar,
- parse `.spec` syntax before self-hosting is fully realized,
- also carry bootstrap-side parsing/rendering intelligence for method-chain and attached control-flow syntax normalization,
- remain a major syntax and safety hotspot.

### `LinkedSpec::Validation`
- owns frontend hardening before bootstrap or runtime failure,
- checks malformed rule starts, modes, split markers, edges, and top-level paragraph structure,
- remains strategically important because it is the earliest trustworthy barrier against bad DSL input.

### `LinkedSpec::SpecEntry`
- compiles parsed rule entries into generated runtime handler code,
- still assembles Perl source strings and `eval`s them,
- remains the clearest backend-portability ceiling in the current implementation.

### `LinkedSpec::RuleIR`
- owns rule-level intermediate structure and metadata planning,
- drives handler-variant selection and rule execution metadata.

### `LinkedSpec::RuleIR::EmitContext`
- is the bridge from rule IR into ActionIR scanning and lowering,
- is the main gateway into backend-neutral action rewriting,
- now also centralizes its internal ActionIR owner package registry and owner default-dependency lookup instead of hardwiring those contracts separately across dozens of local wrappers.

## ActionIR Reading
The ActionIR subtree is now large, but structurally it is much healthier than the older monolithic style.

Current reading:

- `MethodExpr`
  - parses method-like expressions.
- `Scanner` and `ScannerCore`
  - find helper-like and compatibility-like surfaces.
- scanner rule families are split deliberately:
  - `PrimitiveBasicRules`
  - `PrimitivePipelineRules`
  - `FlowRules`
  - `LegacyRules`
- `CanonicalEvents`
  - turns scanned helper hits into canonical event forms.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
- `Diagnostics`
  - tracks unresolved helpers, readiness, and compatibility-surface telemetry.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
- `StatementSplit`
  - owns safe statement splitting.
- `StatementSplit::Core`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy package loading of statement-split helper packages.
- `ScannerCore`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading of scanner-rule families.
  - now also centralizes the scanner-rule family registry and shared helper rebinding symbol list, so package-family loading and dependency rebinding no longer hardcode the same scanner-family contract in parallel.
  - now also centralizes the scanner dependency contract consumed by `Scanner::default_deps_for_package(...)`, so dependency assembly and dependency rebinding stay aligned under one owner instead of drifting in parallel.
- `Contracts`
  - is the contract catalog for supported helper surfaces and how they lower.
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, `DeclareMethod`, and `ValueExpr`
  - make up the main lowering families.
- `FlowExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `ArrayPipeline`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `ControlFlow`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `MethodLowering`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `DeclareMethod`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `ValueExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `RewritePipeline`
  - glues the scan, classify, and lower pipeline together.

The important judgment here is:
- the language-neutral `.spec` story does not live in `LinkedSpec.pm`,
- it lives mostly in `RuleIR::EmitContext` and the `ActionIR::*` subtree.

## Legacy Plugin Branch Reading
The current public facade still exposes a plugin/runtime branch, but the architecture direction has shifted.

### `LinkedSpec::PluginRegistry`
- owns the clean explicit in-memory registry surface.

### `LinkedSpec::PluginBridge`
- is the transition bridge,
- checks explicit registration first,
- falls back to legacy behavior only when needed.

### `PPlugin`
- owns legacy `.plg` discovery,
- parses `.plg` files through the `pplugin` parser,
- caches discovered handlers,
- executes them dynamically.

Current project direction does not treat that branch as a target architecture.

The current intended direction is:
- keep deterministic named `.spec` resolution,
- treat dynamic `.plg` loading and plugin execution as legacy-removal territory,
- move executable helper logic into explicit package ownership outside `LinkedSpec::*`,
- keep LinkedSpec focused on parser/spec/runtime responsibilities.

## Strongest Current Boundaries
These are the seams that currently look healthiest and most worth preserving.

### 1. Thin `LinkedSpec.pm` facade
This is good architectural movement. The public entrypoint is no longer trying to own everything itself.

### 2. `ParserFactory -> Runtime -> Compiler`
This is the practical core spine of the system and gives a readable ownership model to parser construction.

### 3. `RuntimeContext`
This is one of the best extractions in the project so far. It reduced drift and made structured diagnostics much more coherent.

### 4. ActionIR modularization
The lowering stack is big, but it now has real sub-owners instead of one giant mixed-semantics file.

## Main Hotspots and Risks
### `BootstrapSpec::Core`
- dense syntax hotspot,
- difficult to change safely,
- still central until self-hosting is stronger.

### `SpecEntry`
- still relies on generated Perl source plus `eval`,
- strongest backend-portability ceiling,
- still a likely long-term refactor target.

### Public visibility of legacy plugin surface
- `run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`, and `AUTOLOAD` still sit in `LinkedSpec.pm`,
- even though the project direction now says dynamic plugin loading is not a core target to preserve.

### Repeated owner-dispatch boilerplate
- the lazy owner-dispatch style is working,
- and the broad thin-wrapper reduction has paid off,
- but a few internal owner registries and compatibility wrappers still need the same kind of consolidation when they surface as obvious duplication.

## Current Strategic Judgments
### 1. LinkedSpec is no longer best understood as a plugin-hosting framework
The clearer core story is:
- named `.spec` lookup,
- parser compilation,
- parser runtime,
- action lowering,
- diagnostics.

Dynamic plugin loading was historically useful, but it is not the architectural center anymore.

### 2. Spec/resource lookup and plugin loading should stay separate in our thinking
The justified behavior to preserve is:
- `get_parser('foo')` should locate `foo.spec` without path burden.

That does not imply that LinkedSpec must keep a dynamic plugin system.

### 3. Future portability still runs through `SpecEntry`
Even with a much stronger ActionIR story, runtime handler generation still bottoms out in emitted Perl and `eval`.

### 4. ActionIR maturity is now more about semantics and architecture than helper count
The helper family is much richer than it used to be. The bigger future wins are now around:
- cleaner semantics,
- lowering discipline,
- validation,
- self-hosting,
- and eventual backend decoupling.

## Suggested Session-Start Refresh Checklist
At the start of a future session, this document should be re-read and adjusted if any of the following changed:

- the public API surface of `LinkedSpec.pm`,
- the practical compile spine,
- the role of `RuntimeContext`,
- the biggest architectural hotspots,
- the status of `SpecEntry` code generation,
- the status of bootstrap/self-hosting,
- the status of the legacy plugin-removal track,
- or the project's own understanding of what LinkedSpec should and should not own.

## Bottom Line
Current best reading:

- `LinkedSpec.pm` is a facade,
- `ParserFactory`, `Runtime`, and `Compiler` are the practical parser-build spine,
- `BootstrapSpec::Core` and `Validation` still define much of the frontend truth,
- `SpecEntry` remains the biggest portability hotspot,
- `RuleIR` plus `ActionIR::*` are where backend-neutral action semantics really live,
- `RuntimeContext` is one of the strongest architectural boundaries in the project,
- and the legacy plugin branch should be treated as transition/removal machinery, not as the future identity of LinkedSpec.
