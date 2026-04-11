# Owner Tree and Module Boundaries

LinkedSpec is no longer best understood as one large `LinkedSpec.pm` file.

The active architecture is deliberately owner-oriented: each important package is expected to own one part of the system, and cross-owner calls should make that ownership visible.

This matters because LinkedSpec is dynamic. It parses `.spec` source, compiles runtime handlers, rewrites action DSL, dispatches through dependency regexes, and preserves structured diagnostics across several boundaries. Without clear owners, those pieces become opaque implementation detail. With clear owners, they become a system that can be refactored safely.

## High-level reading

`LinkedSpec.pm` is now a thin facade.

It exposes the public API, then delegates into owners:

```text
LinkedSpec.pm
  -> LinkedSpec::ParserFactory
  -> LinkedSpec::Runtime
  -> LinkedSpec::Compiler
```

The practical core spine is:

```text
get_parser(...) -> ParserFactory -> Runtime -> Compiler
Get(...)        -> Runtime       -> Compiler
```

`get_parser(...)` is the file-oriented public path. It validates a spec name, resolves a `.spec` file, loads it, and then delegates compilation.

`Get(...)` is the source-oriented public path. It receives `.spec` source directly and delegates compilation.

Both paths converge on the runtime/compiler pipeline.

## Current owner tree

This is the public mental model for the core owner tree:

```text
LinkedSpec
  facade and public entrypoint

  OwnerDispatch
    shared lazy-loading, callback lookup, dependency bundles, and $@ preservation

  Trace
    trace configuration, verbosity gates, formatting, and trace sinks

  ParserFactory
    get_parser(...): name validation, spec resolution, loading, compile delegation

    Resolver
      named .spec lookup and file loading

    RuntimeContext
      spec identity and structured last_error payloads

    Runtime
      Get(...) orchestration and compile-pipeline delegation

      Compiler
        source validation, bootstrap parse, compiled states, descriptors, parser wrapper

        BootstrapSpec / BootstrapSpec::Core
          bootstrap parser for .spec syntax

        Validation
          early frontend validation and descriptor-state validation

        CompilerState
          compiled_spec_state, compiled_dependency_regex_state, compiled_descriptor_state

        SpecEntry
          per-rule generated handler construction

          RuleIR
            rule-level intermediate representation and handler metadata

          RuleIR::EmitContext
            bridge into ActionIR scanning/lowering and generated code emission

            ActionIR::*
              backend-neutral helper DSL scanning, canonicalization, contracts, and lowering

  PluginRegistry / PluginBridge / PPlugin
    legacy plugin transition branch, not the future architectural center
```

This tree is intentionally a reading guide, not a literal static import tree. LinkedSpec uses lazy loading, so the code that matters is often reached through owner dispatch rather than visible in one large `use` list.

## The facade owns routing, not semantics

`LinkedSpec.pm` is the public door.

It owns:

- public function names such as `Get(...)`, `get_parser(...)`, `configure_trace(...)`, and trace helpers,
- thin compatibility wrappers such as `build_compiled_rule_table(...)`,
- plugin compatibility entrypoints that still exist during the transition,
- routing into owner modules through `LinkedSpec::OwnerDispatch`.

It should not own:

- spec-file resolution,
- compile-pipeline semantics,
- generated handler construction,
- ActionIR lowering semantics,
- structured diagnostic payload construction,
- dependency-regex descriptor-state validation.

That separation is deliberate. When the facade stays thin, public API stability does not force the implementation to stay monolithic.

## `OwnerDispatch`

`LinkedSpec::OwnerDispatch` is plumbing, not product semantics.

It centralizes repeated owner-wrapper behavior:

- lazy package loading,
- callback lookup from an owner package,
- dependency callback map construction,
- mixed callback/value dependency bundle construction,
- `$@` preservation across successful delegated calls,
- uniform delegated owner calls.

This matters because many LinkedSpec owners are thin wrappers around deeper implementation packages. If each wrapper hand-rolls lazy loading and callback lookup, the project accumulates small inconsistencies. `OwnerDispatch` keeps that boilerplate in one place.

Delegated owner calls go through that same callback-loader route too: `dispatch_owner_call(...)` resolves its target through `require_pkg_cb(...)` before invoking the coderef. That keeps lazy loading, callback validation, list-context return preservation, and successful `$@` preservation on one shared path.

Current thin wrapper callback lookup for `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, and `ActionIR::Scanner` goes through this shared callback-loader seam. The remaining direct callback probing under `RuleIR::EmitContext` is deliberately tied to its owner-key registry diagnostics rather than generic wrapper loading.

The design rule is:

```text
semantic ownership belongs to the target owner;
dispatch mechanics belong to OwnerDispatch.
```

## `ParserFactory`

`LinkedSpec::ParserFactory` owns the file-oriented public parser path:

```perl
my $parser = LinkedSpec::get_parser('vhdl');
```

Its job is to answer this question:

```text
How do we turn a requested spec name into a compiled parser?
```

That includes:

- validating the requested spec name,
- resolving it to a `.spec` path through `Resolver`,
- loading the spec content,
- preparing runtime context identity such as `spec_name` and `spec_path`,
- applying trace options for the parser-factory call,
- delegating actual compilation to `Runtime`.

`ParserFactory` should not compile rules itself. Once it has loaded `.spec` source, it hands the source to the same runtime/compiler path used by direct `Get(...)`.

## `Resolver`

`LinkedSpec::Resolver` owns named `.spec` lookup.

It is the home for behavior like:

```text
get_parser('vhdl') should be able to find specs/vhdl.spec
```

That responsibility is different from plugin lookup. Spec resolution should stay deterministic and file-oriented. It should not be confused with the legacy dynamic plugin system.

## `Runtime`

`LinkedSpec::Runtime` owns the source-oriented public path:

```perl
my $parser = LinkedSpec::Get(\$spec_source);
```

It prepares runtime context, normalizes mode expectations, delegates to the compiler pipeline, and writes fallback runtime-owner diagnostics only if a deeper owner did not already provide a better structured error.

The key rule is:

```text
Runtime orchestrates the call;
Compiler owns the compile semantics.
```

## `RuntimeContext`

`LinkedSpec::RuntimeContext` is one of the strongest boundaries in the current architecture.

It owns shared runtime state such as:

- `spec_name`,
- `spec_path`,
- `top_rule`,
- structured `last_error`,
- generated handler source labels,
- parser-source capture state when requested.

That state has to survive crossings between public API, parser factory, runtime owner, compiler, generated handlers, and parser invocation. Centralizing it prevents each owner from inventing its own partial context shape.

When a failure occurs, the preferred pattern is:

```text
the owner closest to the failure writes the richest payload;
outer owners preserve it unless no payload exists yet.
```

That is why `runtime_ctx->{last_error}` can keep useful fields such as `spec_path`, `top_rule`, `rule_label`, and `handler_source_label` instead of collapsing into a generic outer exception.

## `Compiler`

`LinkedSpec::Compiler` owns the compile pipeline.

Its public mental model is covered in the compiler chapter, but architecturally it is the owner that coordinates:

- source envelope validation,
- DSL syntax validation,
- bootstrap parsing,
- compiled rule-table construction,
- dependency-regex state construction,
- compiled descriptor-state assembly,
- descriptor-state validation,
- outward descriptor projection,
- parser coderef construction.

The important architectural move is that the compiler now works through explicit internal state records before projecting outward descriptor data.

The active internal records are:

- `compiled_spec_state`,
- `compiled_dependency_regex_state`,
- `compiled_descriptor_state`.

The public outward descriptor can still expose:

```perl
{
  spec => { ... },
  dependency_regex_map => { ... },
  meta => { ... },
}
```

But the compiler should not treat that outward projection as its own only source of truth.

## `CompilerState`

`LinkedSpec::CompilerState` owns the compiled state model.

It is the right home for questions like:

- What shape is a valid `compiled_spec_state`?
- How do we iterate compiled rules in deterministic order?
- How do we project compiled state to outward descriptor hashes?
- How do we build descriptor metadata from compiled state?
- How do we expose validation-friendly descriptor-state views?

This owner exists to avoid a bad pattern:

```text
Compiler.pm and Validation.pm both poking raw state hashes directly.
```

The preferred direction for this project is state-first and owner-first:

```text
Compiler coordinates.
CompilerState defines and reads compiler state.
Validation validates through owner-provided views.
```

## `BootstrapSpec` and `Validation`

`LinkedSpec::BootstrapSpec` and `LinkedSpec::BootstrapSpec::Core` own the bootstrap grammar used to parse `.spec` syntax.

That area is powerful and still a hotspot because LinkedSpec uses a bootstrap parser to parse the language used to define parsers.

One naming caveat is worth keeping straight: active compiler descriptors use compiled-state and dependency-regex terminology, and the bootstrap parser internals now use explicit `rule_descriptors` / `dispatch_state` terminology as well. Older `spec_descr` / `gdata` wording should be read as historical context or compatibility-test language, not as the active compiler descriptor model.

`LinkedSpec::Validation` owns early hardening before failures become confusing runtime behavior. It validates things like malformed rule starts, mode syntax, split markers, top-level paragraph shape, and descriptor-state dependency consistency.

The frontend rule is:

```text
reject malformed .spec structure as early and specifically as possible.
```

That keeps bad user input from drifting into generated code, generic Perl errors, or misleading runtime failures.

## `SpecEntry`, `RuleIR`, and `RuleIR::EmitContext`

`LinkedSpec::SpecEntry` compiles one parsed rule entry into generated runtime behavior.

It is where the current Perl backend still shows through most clearly: generated handler source is assembled and evaluated.

`LinkedSpec::RuleIR` owns rule-level intermediate representation and metadata planning.

`LinkedSpec::RuleIR::EmitContext` is the bridge from rule IR into action-helper scanning and lowering. It carries normalized action/lifecycle material such as:

- `ACODEs`,
- `BCODEs`,
- `BCALLs`,
- `DEPENDENCY_REFS`,
- lifecycle chunks,
- action-rewriter metadata.

The key architecture point is:

```text
SpecEntry emits the current backend.
RuleIR and ActionIR carry the path toward cleaner backend-neutral semantics.
```

## `ActionIR::*`

The `LinkedSpec::ActionIR::*` subtree is where the helper DSL becomes structured semantics.

Important families include:

- `MethodExpr` for parsing method-like helper expressions,
- `Scanner` and `ScannerCore` for finding helper and compatibility surfaces,
- scanner rule families such as `PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules`, and `LegacyRules`,
- `StatementSplit` for safe statement splitting,
- `CanonicalEvents` for canonical helper-event forms,
- `Contracts` for the supported helper contract catalog,
- `ValueExpr`, `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, and `DeclareMethod` for lowering families,
- `Diagnostics` for unresolved helper and compatibility-surface telemetry,
- `RewritePipeline` for gluing scan, classify, and lower phases together.

This is where much of the long-term portability story lives. The project can keep the current Perl backend while progressively making action semantics less dependent on raw Perl snippets.

## `Trace`

`LinkedSpec::Trace` owns trace configuration and rendering.

It is separate from `RuntimeContext` on purpose:

- `RuntimeContext` owns structured state and `last_error`,
- `Trace` owns optional visibility into what the system is doing.

That separation keeps diagnostics usable even when tracing is off.

## Legacy plugin branch

The public facade still exposes plugin-related entrypoints:

- `register_plugin(...)`,
- `register_plugins(...)`,
- `clear_registered_plugins(...)`,
- `run_plugin(...)`,
- `get_plugin(...)`,
- `dispatch_plugin_autoload_name(...)`,
- `AUTOLOAD`.

Architecturally, this branch should be read as transition machinery.

`LinkedSpec::PluginRegistry` owns explicit in-memory plugin registration.

`LinkedSpec::PluginBridge` checks explicit registration first and falls back to legacy behavior when needed. Its current compatibility plumbing uses the shared owner-dispatch seam for registered-plugin lookup, legacy `PPlugin` loading, and successful `$@` preservation, so even this transition branch follows the same wrapper discipline as the main runtime owners.

`PPlugin` owns the old `.plg` discovery/execution path. It reads legacy plugin files through explicit file IO, reports and skips unreadable or malformed files during registry construction, and still reaches back to `LinkedSpec::get_parser('pplugin')` to parse `.plg` files. That callback load now goes through the shared owner-dispatch seam instead of a local `require LinkedSpec` branch.

Repo-owned `.plg` files should not reach into `PPlugin->get(...)` directly. Shipped lookup callers now use `LinkedSpec::get_plugin(...)`, which keeps registry-first lookup and legacy fallback under `PluginBridge` while the `.plg` surface is being retired.

Package-backed plugin extraction is already underway. `Plugin::String`, `Plugin::CGI`, and `Plugin::HTTP` own small helper surfaces that used to live only in `.plg` files. `Plugin::GenericFilter` now owns the generic table grouping actions too: `group_by`, `group_by_port`, `group_by_ioclock`, and `group_byRE`. `Plugin::MSOffice` owns the historical Excel-start helper, and `Plugin::VHDLConst` owns the historical VHDL constant-evaluation helpers. That means repo-owned callers can name normal package owners instead of constructing plugin strings and asking the bridge or legacy runtime to look them up.

The `plugin/genericfilter.plg` file no longer exists. It had already become only compatibility registration after `Plugin::GenericFilter` took over the implementation, and it was deleted once no repo-owned caller still needed the legacy `genericfilter_*` names.

Not every extracted package owner should keep such a wrapper. `Plugin::String`, `Plugin::CGI`, `Plugin::GenericFilter`, `Plugin::MSOffice`, and `Plugin::VHDLConst` now have no repo-owned legacy plugin caller left for their old registration names, so `plugin/string.plg`, `plugin/cgi.plg`, `plugin/genericfilter.plg`, `plugin/msoffice.plg`, and `plugin/vhdconst_eval.plg` have been removed. That is the healthier destination: normal package owner first, temporary `.plg` bridge only when a concrete remaining caller still needs it, then deletion.

The same point also applies to the package namespace itself. `Plugin::*` is a tactical migration scaffold, not a final taxonomy. The former `yesno.plg` prompt helper first moved into a package owner so the `.plg` file could disappear, then graduated immediately into `InteractivePrompt::yes_no(...)` because interactive prompting is a clearer domain than "plugin". Future extractions should make the same judgment: keep `Plugin::*` only while the behavior genuinely belongs to plugin compatibility or has no clearer owner yet.

The HTTP migration shows the same distinction advancing from helper subdefs to real legacy actions. `Plugin::HTTP` now owns `httplink`, `set_http_hostport`, `set_http_localhost`, the former `http` file-link action through `print_file_links_for_conf(...)`, the former `lighttpd` action through `run_lighttpd_for_conf(...)`, and the former Apache `httpd` action through `run_httpd_for_conf(...)`; `plugin/http.plg`, `plugin/lighttpd.plg`, and `plugin/httpd.plg` are gone. Repo-owned `.plg` callers now call `Plugin::HTTP` directly for HTTP helper behavior.

The current direction is not to make dynamic plugin loading the identity of LinkedSpec. The healthier core story is:

```text
named .spec lookup
parser compilation
parser runtime
ActionIR helper semantics
structured diagnostics
```

## How to route a change

Use this practical map when deciding where work belongs:

- Public API wrapper or backward-compatibility facade: `LinkedSpec.pm`.
- File-oriented parser construction: `ParserFactory`.
- Spec-name validation, path resolution, and file loading: `Resolver`.
- Direct source compilation orchestration: `Runtime`.
- Shared runtime identity and structured errors: `RuntimeContext`.
- Compile-pipeline stage ownership: `Compiler`.
- Compiled state shape, metadata, and projection: `CompilerState`.
- `.spec` syntax bootstrap parsing: `BootstrapSpec::Core`.
- Early source validation and descriptor consistency validation: `Validation`.
- Per-rule handler source generation: `SpecEntry`.
- Rule-level intermediate representation: `RuleIR`.
- Action helper scanning/lowering bridge: `RuleIR::EmitContext`.
- Helper DSL contracts and backend-neutral lowering: `ActionIR::*`.
- Trace formatting and verbosity: `Trace`.
- Legacy plugin compatibility: `PluginRegistry`, `PluginBridge`, and `PPlugin`.

## Why this structure exists

The goal is to reduce monolithic behavior and make the system easier to reason about:

- narrower ownership boundaries
- clearer lazy-load behavior
- less duplicated wrapper logic
- more explicit state and validation seams

The current strongest boundaries are:

- the thin `LinkedSpec.pm` facade,
- the `ParserFactory -> Runtime -> Compiler` spine,
- the `RuntimeContext` structured state boundary,
- the `CompilerState` compiled-state owner,
- the `ActionIR::*` lowering subtree.

The current main hotspots are:

- `BootstrapSpec::Core`, because it owns dense bootstrap syntax behavior,
- `SpecEntry`, because generated Perl handler source and `eval` still define the current backend ceiling,
- the legacy plugin branch, because it remains publicly visible while no longer being the future architectural center.

For the denser implementation-maintenance snapshot, the repo's `ARCHITECTURE_STATE.md` remains the internal working companion to this public chapter.
