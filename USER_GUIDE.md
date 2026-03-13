# USER GUIDE
This guide explains LinkedSpec in two layers:
1. as a progressive extraction parser DSL, and
2. as a lowering-driven action DSL whose helper forms are rewritten into canonical ActionIR and then emitted into backend code.

For current LinkedSpec work, the second layer matters the most. If you want `.spec` files that stay backend-neutral and portable across future non-Perl backends, you should understand the lowering surface and prefer canonical helper forms over raw Perl fragments.

## Why this guide is split
The lowering surface is now large enough that a single giant guide becomes hard to navigate. This top-level guide is the map; the detailed lowering references live in focused module-oriented guides.

Detailed lowering references:
- [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md)
- [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md)
- [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
- [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)
- [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md)
- [`USER_GUIDE_ActionIR_ArrayPipeline.md`](USER_GUIDE_ActionIR_ArrayPipeline.md)
- [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md)

Read this file first, then jump into the specific module guide that matches the lowering family you are using.
For exhaustive review of the current lowering contract, including emitted Perl for every supported helper and compatibility construct, read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md) alongside the module guides.

## What LinkedSpec Is
LinkedSpec compiles `.spec` files from `specs/` into dynamic parsers.
Those parsers match recursive, regex-anchored grammars and return AST/data structures defined by rule actions.

LinkedSpec is intentionally strong at:
- nested and recursive constructs,
- staged coarse-to-fine parsing,
- extraction-oriented parsing where anchor rules and follow-up passes matter more than strict token-by-token grammar purity.

## The Most Important Concept: Lowering
When you write helper-style action code such as:

```text
I {declare(array, items); declare(scalar, retv)}
-> child {assign(scalar(retv), call(child)); push_value(array(items), scalar(retv))}
-> child[1] {return(array("?Top:", array_copy(array(items))))}
```

LinkedSpec does **not** treat that as opaque text. Instead it tries to:
1. recognize supported helper/method constructs,
2. convert them into canonical ActionIR events/nodes,
3. lower those nodes into backend code.

That distinction matters because not all syntactically valid Perl inside a `{ ... }` block is equally portable.

### Portability tiers
Think about authoring styles in three tiers:

1. **Canonical helper-only lowering**
   - Best choice.
   - Uses helper forms like `declare(...)`, `assign(...)`, `return(payload)`, `if(...)`, `push_value(...)`, `array(...)`, `hash(...)`, `array_copy(...)`, compatibility `array_values(...)`, `join_values(...)`, and so on.
   - This is the preferred style for backend-neutral `.spec` authoring.

2. **Helper shells with raw host expressions inside arguments**
   - Still useful and often unavoidable today.
   - Example: `assign(scalar(pos_begin), pos $$STRING)` or `assign(scalar(part), substr($$STRING, ...))`.
   - The outer statement is canonical, but the inner expression is still host-language flavored.
   - Use when no dedicated helper exists yet, but do it consciously.

3. **Legacy or raw compatibility forms**
   - Works for existing Perl specs.
   - Examples: `return call(rule)`, `push(rule)`, `$CAPTURE`, `BACKTRACK()`, or older raw wrappers such as `$retv = call(rule)`.
   - These are important for compatibility, but new backend-neutral specs should prefer the newer helper surface where possible.

## Typical Workflow
1. Write or update a `.spec` grammar.
2. Build a parser:
   - `my $parser = LinkedSpec::get_parser('my_spec_name');`
3. Parse data:
   - `my $ast = $parser->(\$input_string);`
4. If the grammar is large or heterogeneous, run additional passes on captured substrings or substructures.
5. If you are working on backend-neutral migration, inspect the lowering metadata with `return_descr => 1`.

Validation note: when changing parser/compiler/runtime behavior, run `bash tools/run_ci_local.sh` from the repo root before pushing so the local phase-0 gate matches GitHub CI. Recent internal load-time cleanup means `LinkedSpec.pm` no longer imports `Data::Dumper` or `LinkedRE` at façade load time, its public façade wrappers now preserve caller `$@` across successful owner delegation, its public trace wrappers now preserve caller `$@` across successful owner delegation too, `Validation.pm`, `Resolver.pm`, `RuleIR.pm`, and `RuleIR::EmitContext.pm` now preserve caller `$@` across successful extracted-owner delegation too, the remaining thin owner delegates in `BootstrapSpec.pm`, `Runtime.pm`, `ActionIR::Scanner.pm`, `ActionIR::StatementSplit.pm`, and `ActionIR::CanonicalEvents.pm` now preserve caller `$@` across successful owner delegation too, `ActionRewriter.pm` now preserves caller `$@` across successful owner delegation for its dep-builder/helper/lowering/rewrite wrapper surface too, `SpecEntry.pm` now preserves caller `$@` across successful trace/dump helper delegation too, `Compiler.pm` now preserves caller `$@` across successful trace/dump/regex helper delegation too, `BootstrapSpec::Core.pm` now preserves caller `$@` across successful regex-helper delegation too, `Trace::_trace_stringify(...)` now preserves caller `$@` across successful dump formatting too, and `PluginBridge.pm` now preserves caller `$@` across successful legacy runtime load/exec delegation too. `Trace.pm` now lazy-loads `Data::Dumper` only when referenced values actually need structured dump formatting, `RuleIR.pm` now lazy-loads `Data::Dumper` only when debug execution-meta dumps actually need it, `SpecEntry.pm` now lazy-loads `Data::Dumper` only when high-verbosity rule-entry debug dumps actually need it, `Compiler.pm` now lazy-loads `Data::Dumper` only when traced compiler dumps actually need it and now lazy-loads `LinkedRE` only when regex gdata assembly actually needs it, `BootstrapSpec::Core.pm` now lazy-loads `LinkedRE` only when bootstrap registry construction or bootstrap scanner handlers actually need it, `Validation.pm` now lazy-loads `Trace.pm` only when validation errors or warnings actually emit trace output, `Resolver.pm` now lazy-loads `Trace.pm` only when invalid-spec or spec-resolution trace/error paths actually emit output, `RuleIR::EmitContext.pm` now lazy-loads `ActionRewriter.pm` only when emit-context build paths actually need rewrite helpers, `ActionIR::Scanner.pm` now lazy-loads `ScannerCore.pm` only when contract scanning starts, `ActionIR::ScannerCore.pm` now lazy-loads its scanner rule packages only when scanning actually starts, `ActionRewriter.pm` now lazy-loads `ActionIR::MethodExpr.pm`, `ActionIR::Scanner.pm`, `ActionIR::CanonicalEvents.pm`, `ActionIR::Diagnostics.pm`, `ActionIR::StatementSplit.pm`, `ActionIR::Contracts.pm`, `ActionIR::RewritePipeline.pm`, `ActionIR::FlowExpr.pm`, `ActionIR::ArrayPipeline.pm`, `ActionIR::ValueExpr.pm`, `ActionIR::ControlFlow.pm`, `ActionIR::MethodLowering.pm`, and `ActionIR::DeclareMethod.pm` only when those helper families are used, `ActionIR::StatementSplit.pm` now lazy-loads `StatementSplit::Core.pm` only when statement splitting starts, `ActionIR::StatementSplit::Core.pm` now lazy-loads `StatementSplit::Mode.pm` only when splitting actually starts, and `ActionIR::CanonicalEvents.pm` now lazy-loads `CanonicalEvents::Core.pm` only when canonical-event building starts.

## Rule Anatomy Refresher
Minimal skeleton:

```text
top_rule::
 -> subrule_a
 -> subrule_b
 LX { return \@top_rule }

subrule_a: /.../
subrule_b: /.../
```

Most important syntax elements:
- Entry rule: `name::`
- Regular rule: `name:`
- Regex pattern(s): `/.../`
- Branch edges:
  - `-> rule`
  - `-> rule[idx]`
  - `-> rule { ... }`
  - `-> rule .method(args).method2(args)`
- Lifecycle/non-action blocks:
  - `I { ... }`
  - `LS { ... }`
  - `LE { ... }`
  - `LX { ... }`
  - also supported in advanced specs: `E`, `EX`, `IT`

## Where Lowered Constructs Can Appear
Lowered constructs are not limited to one place.

### 1. Action blocks on edges

```text
-> child { assign(scalar(retv), call(child)); push_value(array(items), scalar(retv)) }
```

### 2. Chained action edges

```text
-> child .declare(scalar, name).assign(scalar(name), CAPTURE).return_array(node, array(scalar(name)))
```

### 3. Lifecycle blocks

```text
I  {declare(array, items); declare(scalar, flag)}
LS {print("loop start\n")}
LE {assign(scalar(flag), IMATCH)}
LX {return(array_copy(array(items)))}
```

### 4. Chained lifecycle forms

```text
I.declare(array, items).declare(scalar, flag)
LX.if(is_nonempty(array(items))).return(array_copy(array(items))).else().return_undef().endif()
```

## Runtime Match Values You Will See Repeatedly
A lot of lowering examples refer to a small set of parser runtime values.

- `IMATCH`
  - the current immediate match text.
- `LMATCH`
  - the latest closing-side match text.
- `IMATCH_LIST`
  - the capture list from the current regex.
- `CAPTURE`
  - helper token representing the substring between current parser positions.
- `IPOS`
  - current start/input position marker.
- `LSPOS`
  - current latest scanner position marker.
- `$$STRING`
  - the input string reference.

Examples:

```text
assign(scalar(name), scalar(IMATCH))
assign(scalar(content), CAPTURE)
return(array("?node:", scalar(IMATCH_LIST, 0), scalar(IMATCH_LIST, 1)))
assign(scalar(pos_begin), pos $$STRING)
```

## Quick Navigation by Task
If you are trying to do one of these jobs, read the matching guide first.

### I need declarations or initialized working state
Start with [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md).

Typical patterns:
- `declare(array, items)`
- `declare(scalar, flag=or(scalar(on), scalar(off)))`
- `declare(hash, by_name=hash("kind", scalar(kind)))`

### I need value constructors, nested return payloads, or `call(...)` as a value source
Start with [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md).

Typical patterns:
- `array(...)`
- `hash(...)`
- `scalaref(...)`
- `join_values(...)`
- `array_copy(...)`
- `flat_array(...)`
- `assign(scalar(retv), call(rule))`
- `return(array(...))`

### I need assignment semantics or special assignment sources
Start with [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md).

Typical patterns:
- `assign(scalar(name), CAPTURE)`
- `assign(scalar(retv), call(Leaf))`
- `assign(array(items), array(scalar(retv)))`
- `assign(hash(by_name), hash("k", scalar(v)))`

### I need boolean/comparison expressions
Start with [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md).

Typical patterns:
- `or(...)`, `and(...)`, `not(...)`
- `is_empty(...)`, `is_nonempty(...)`
- `eq/ne/gt/ge/lt/le`
- `num_eq/...`
- `matches(...)`

### I need `if/else` or `switch/case` lowering
Start with [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md).

Typical patterns:
- `if(...); ... else(); ... endif()`
- `switch(...); case(...); default(); endswitch()`
- `switch(expr, case(...), default(...))`
- `say(...)`, `print(...)`, `return_undef()`

### I need array tokenization or array post-processing
Start with [`USER_GUIDE_ActionIR_ArrayPipeline.md`](USER_GUIDE_ActionIR_ArrayPipeline.md).

Typical patterns:
- `split(...)`
- `split_each(...)`
- `trim_each(...)`
- `filter_nonempty(...)`
- `lowercase_each(...)`, `uppercase_each(...)`
- `uniq(...)`
- `filter_match(...)`

### I need legacy helper wrappers or capture/backtrack helpers
Start with [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md).

Typical patterns:
- `call(rule)` as a standalone dispatch helper
- `push(rule)` / `push(rule, target)`
- `return_a`, `return_m`, `return_ma`
- `return_imatch`, `return_array`
- `$CAPTURE`, `capture_if(...)`, `BACKTRACK()`, `IBACKTRACK()`

### I need the exact emitted Perl for every currently supported construct
Start with [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

This is the exhaustive review document. It covers:
- preferred canonical helper forms,
- older compatibility helpers such as `return_a`, `return_m`, `return_ma`, `capture_if`, and raw call wrappers,
- classified pass-through idioms that are preserved verbatim but still count as canonical ActionIR rather than `RAW_PERL` fallback.

## Most Common Canonical Patterns
These are the patterns you will use over and over again.

### Pattern 1: declare state, call a child, keep the result

```text
I {declare(array, items); declare(scalar, retv)}
-> child {
  assign(scalar(retv), call(child));
  push_value(array(items), scalar(retv))
}
```

Use this when you need the child result more than once, or when you need to branch on it before deciding where to store it.

### Pattern 2: assign a captured substring and return a structured node

```text
I {declare(scalar, content)}
-> block[1] {
  assign(scalar(content), CAPTURE);
  return(hash("type", "BLOCK", "content", scalar(content)))
}
```

Use this when you are closing a delimited construct and want a canonical object/hash payload.

### Pattern 3: accumulate tokens, then snapshot them in a return payload

```text
I {declare(array, parts)}
-> piece {push_value(array(parts), scalar(IMATCH))}
-> Top[1] {return(array("?Top:", array_copy(array(parts))))}
```

Prefer `array_copy(array(parts))` when you want a **snapshot array payload**.
`array_values(array(parts))` remains supported as the older compatibility spelling.

### Pattern 4: flatten an existing array into a constructor

```text
return(array("?node:", flat_array(IMATCH_LIST)))
```

Use `flat_array(...)` when you want **list-context insertion**, not an array snapshot.

That distinction is important:
- `array_copy(array(items))` means “make an array payload from the current array contents.”
- `flat_array(items)` means “splice the array elements into the surrounding constructor.”

### Pattern 5: backend-neutral recursive accumulator flow
This is the shape now used in `Lispish::parenthesis`:

```text
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}

-> parenthesis {
  if(is_nonempty(array(word)));
    if(is_empty(scalar(has_head)));
      assign(scalar(head), join_values("", array(word)));
      assign(scalar(has_head), 1);
    else();
      push_value(array(tail), join_values("", array(word)));
    endif();
    assign(array(word), array());
  endif();

  assign(scalar(retv), call(parenthesis));
  if(is_empty(scalar(has_head)));
    assign(scalar(head), scalar(retv));
    assign(scalar(has_head), 1);
  else();
    push_value(array(tail), scalar(retv));
  endif()
}
```

The important idea is not just recursion; it is the **canonical replacement** of older raw wrappers like `$retv = call(parenthesis)` with `assign(scalar(retv), call(parenthesis))`.

## How To Inspect Lowering
### Snippet inspection utility
Use `tools/inspect_spec_codegen.pl` when you want to see the generated Perl and canonical action-IR for a specific snippet.

Examples:
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'I.declare(array, items).declare(scalar, retv)'`
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'assign(scalar(retv), call(Leaf))'`
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'if(is_nonempty(array(items))); return(array_copy(array(items))); else(); return_undef(); endif()'`

The tool is especially useful when you are deciding between two equivalent-looking helper forms and want to confirm which one actually lowers canonically.

### Descriptor introspection with `return_descr => 1`
Use descriptor mode when you want to inspect rule readiness or migration metadata.

Typical shape:

```perl
my $descr = LinkedSpec::get_parser('Lispish', return_descr => 1);
my $meta  = $descr->{spec}{parenthesis}{meta}{action_rewriter};
```

High-value fields:
- `raw_perl_dependency_count`
- `raw_perl_dependency_statements`
- `unresolved_helper_count`
- `canonical_action_ir_nodes`
- `helper_action_ir_nodes`
- `language_agnostic_action_ir_ready`

Descriptor summary fields:
- `meta.action_rewriter_migration.language_agnostic_blocked_rule_count`
- `meta.action_rewriter_migration.language_agnostic_blocked_rules_by_priority`
- `meta.action_rewriter_migration.language_agnostic_top_blocked_rule`

Lower-level callers that already hold parsed bootstrap entries can also use `LinkedSpec::spec_descr($entries)`. The default rule-compilation callback is owned internally by `LinkedSpec::Compiler`, so you only need to pass an explicit callback when you are intentionally overriding rule compilation behavior; normal callers should not depend on the older `LinkedSpec::spec_entry(...)` façade helper.

Likewise, final descriptor assembly keeps its `gdata` compilation defaults inside `LinkedSpec::Compiler`; normal callers do not need to provide a separate `spec_gdata` callback or depend on an older `LinkedSpec::spec_gdata(...)` façade helper.

The same applies to the full compile pipeline: `LinkedSpec::Compiler::run_get_pipeline(...)` owns its default bootstrap-parse and rule-compilation callbacks internally, while `LinkedSpec::Runtime::run_get(...)` only provides the mutable runtime context needed for parser-source capture and `top_rule` propagation. `Runtime.pm` now lazy-loads `Compiler.pm` only when `run_get(...)` is actually invoked, `Compiler.pm` now lazy-loads `Trace.pm` only when `spec_descr(...)`, `spec_gdata(...)`, or `run_get_pipeline(...)` actually starts traced compiler work, `Compiler.pm` now lazy-loads `BootstrapSpec.pm`, `SpecEntry.pm`, and `Validation.pm` only when the active compile path needs them, `BootstrapSpec.pm` now lazy-loads `BootstrapSpec::Core.pm` only when bootstrap grammar state is actually needed, `SpecEntry.pm` now lazy-loads `RuleIR.pm` only when `compile_spec_entry(...)` actually compiles a parsed rule, `SpecEntry.pm` now lazy-loads `Trace.pm` only when `compile_spec_entry(...)` actually enters traced rule compilation, `RuleIR.pm` now lazy-loads `Trace.pm` only when RuleIR diagnostics actually emit output, `RuleIR.pm` now lazy-loads `RuleIR::EmitContext.pm` only when emit-context assembly is actually needed, `RuleIR::EmitContext.pm` now lazy-loads `Trace.pm` only when unresolved-helper diagnostics actually emit output, and `ActionIR::Scanner.pm` now lazy-loads `ScannerCore.pm` only when contract scanning actually starts. Use `LinkedSpec::Get(...)` or `LinkedSpec::Runtime::run_get(...)`; the older raw-argument runtime wrapper and runtime `compile_spec_entry(...)` wrapper are no longer part of the active surface.

The public façade now follows the same pattern for tracing: plain `require LinkedSpec` keeps `Trace.pm` unloaded until you actually call `LinkedSpec::configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`, `trace_decision(...)`, `log_output(...)`, `log_dump(...)`, or `should_dump(...)`. The longstanding façade trace-state variables (`$LinkedSpec::DUMP_VERBOSITY`, `$LinkedSpec::TRACE_LOG_FILE`, and related settings) remain the compatibility surface.

Bootstrap parsing is now owned exclusively by `LinkedSpec::BootstrapSpec` on the active path; callers should not depend on older compiler-local bootstrap helper internals.

For focused helper-rewrite inspection, use the compatibility shim `LinkedSpec::call_spec_handler_subst(...)`. Older internal `LinkedSpec::_...` action-rewriter, ActionIR-lowering, trace/runtime, RuleIR, and descriptor-assembly helpers are no longer part of the active surface.

Contract scanning internals are now owned by `LinkedSpec::ActionIR::Scanner` and `LinkedSpec::ActionIR::ScannerCore`; scanner-rule dependency rebinding and dispatch ordering no longer live inline in `scan_contract_ir_events(...)`, and the scanner default callback map now lives in `LinkedSpec::ActionIR::Scanner::default_deps_for_package(...)` instead of `LinkedSpec::Deps`. Statement splitting follows the same pattern: `LinkedSpec::ActionIR::StatementSplit` now owns its default callback map through `default_deps_for_package(...)` instead of relying on `LinkedSpec::Deps`. Canonical helper-event assembly now does too: `LinkedSpec::ActionIR::CanonicalEvents` owns its default callback map through `default_deps_for_package(...)`, so the active canonical-event path no longer depends on the older `LinkedSpec::Deps` builder. Helper diagnostics now follow the same owner pattern: `LinkedSpec::ActionIR::Diagnostics` owns its default callback map through `default_deps_for_package(...)`, so unresolved-helper and helper-event scans no longer depend on the older `LinkedSpec::Deps` diagnostics builder. Rewrite orchestration now does as well: `LinkedSpec::ActionIR::RewritePipeline` owns its default callback map through `default_deps_for_package(...)`, so canonical-IR-driven helper rewriting no longer depends on the older `LinkedSpec::Deps` rewrite-pipeline builder. Specialized declare/assign method lowering follows the same owner pattern: `LinkedSpec::ActionIR::DeclareMethod` now owns its ActionRewriter-facing default callback map through `default_deps_for_package(...)`, so the active declare-method path no longer depends on the older `LinkedSpec::Deps` builder. Contract construction now does too: `LinkedSpec::ActionIR::Contracts` owns its ActionRewriter-facing default callback map through `default_deps_for_package(...)`, so the active lowering-contract path no longer depends on the older `LinkedSpec::Deps` contract builder. Value-expression lowering now follows the same owner pattern: `LinkedSpec::ActionIR::ValueExpr` owns its default callback map through `default_deps_for_package(...)`, so scalar-access and scalaref lowering no longer depend on the older `LinkedSpec::Deps` value-expression builder. Flow-expression lowering now does too: `LinkedSpec::ActionIR::FlowExpr` owns its default callback map through `default_deps_for_package(...)`, so boolean/comparison flow lowering no longer depends on the older `LinkedSpec::Deps` flow-expression builder. Array-pipeline planning and lowering now follow the same owner pattern: `LinkedSpec::ActionIR::ArrayPipeline` owns its default callback map through `default_deps_for_package(...)`, so array-pipeline transforms no longer depend on the older `LinkedSpec::Deps` array-pipeline builder. Control-flow lowering now does too: `LinkedSpec::ActionIR::ControlFlow` owns its default callback map through `default_deps_for_package(...)`, so branch/output lowering no longer depends on the older `LinkedSpec::Deps` control-flow builder. Method/value/assignment/return lowering now follows the same owner pattern: `LinkedSpec::ActionIR::MethodLowering` owns its default callback map through `default_deps_for_package(...)`, so the broad method-lowering surface no longer depends on the older `LinkedSpec::Deps` method-lowering builder. Treat `LinkedSpec::ActionRewriter` plus the extracted ActionIR owner modules as the active path, not the older split dependency wiring.

`LinkedSpec::ActionRewriter` itself also no longer imports `LinkedSpec::Deps` at module load time, and `LinkedSpec::ParserFactory` has absorbed the last parser-factory dep builder too, so require-only consumers stay on the extracted owner modules without loading `LinkedSpec::Deps` at all.

Likewise, validation and DSL-error handling now stay on `LinkedSpec::Validation`; normal callers should not depend on the older `LinkedSpec::get_dsl_context(...)`, `report_dsl_error(...)`, `validate_*`, or `extract_regex_literals_from_rule_rhs(...)` facade wrappers.

## Legacy Plugin Bridge
Generated parsers may still call legacy plugin handlers through `LinkedSpec::AUTOLOAD`. That compatibility path now delegates straight into `LinkedSpec::PluginBridge::_dispatch_autoload(...)`, which normalizes `LinkedSpec::method_name` into the explicit plugin name `method_name` and then delegates runtime execution through the bridge's explicit-name owner path `_dispatch_plugin_name(...)`. The bridge's default legacy load/exec behavior is also now named explicitly inside `LinkedSpec::PluginBridge` via `_load_legacy_plugin_runtime(...)` and `_exec_legacy_plugin(...)`, rather than being hidden in inline closures. The bridge remains legacy-only while the project moves toward explicit package-based plugin APIs.

The current legacy `.plg` adapter in `PPlugin` still searches the working directory and the project `plugin/` directory, but it now enumerates those roots explicitly, lists `.plg` files in deterministic cwd-first sorted order, builds the cached registry through an explicit `_build_plugin_registry(...)` helper, initializes that cache through `_load_legacy_registry()` plus explicit default deps, lazy-loads `LinkedSpec` only when the default `pplugin` parser callback is actually needed, and exposes normalized-name execution through `exec_plugin_name(...)`. Repo-owned callers that already know explicit plugin names now use that owner path directly. The older `PPlugin::exec(...)` entry remains compatibility glue for mixed-name callers. Treat that as compatibility behavior, not the long-term plugin architecture.

## Runtime Options
`LinkedSpec::Get(\$spec, %options)` supports:
- `parse_only => 1`
- `generate_only => 1`
- `return_descr => 1`
- `dump_parser_source => 1`
- `parser_source_ref => \$out`

## `get_parser(...)` Lookup Behavior
`LinkedSpec::get_parser('name')` resolves parser specs in this order:
1. If argument is already a valid file path, use it directly.
2. Try `name.spec` directly if available.
3. Try module-relative `../specs/name.spec`.
4. If still unresolved, fall back to `PathSearch`.

`LinkedSpec::get_parser('name', %options)` keeps the public flat key/value call style. The wrapper normalizes those pairs before parser-factory dispatch; odd trailing option lists still fall back to an empty option set for backward compatibility.

Public callers should continue to treat `LinkedSpec::get_parser(...)` as the stable entrypoint. Trace/spec-resolution/compile defaults are owned internally by `LinkedSpec::ParserFactory`, and local/module-relative lookup is owned by `LinkedSpec::Resolver`, so callers do not need to wire those dependencies themselves. The older `LinkedSpec::Deps` module is no longer part of the active parser-factory path, `Resolver` is loaded lazily only when parser-factory default deps are actually resolved, and the broader compile/plugin pipeline (`ParserFactory`, `Runtime`, `Compiler`, `ActionRewriter`, `PluginBridge`) is now lazy-loaded from the façade only when the corresponding public entrypoints actually need it.

## Tracing and Debugging
LinkedSpec supports multi-level tracing.

Supported levels:
- `none`
- `low`
- `medium`
- `high`
- `debug`

Runtime API examples:
- `LinkedSpec::configure_trace(trace_level => 'high')`
- `LinkedSpec::configure_trace(trace_level => 'debug', trace_emoji => 1)`
- `LinkedSpec::configure_trace(trace_log_file => 'trace.log')`
- `LinkedSpec::configure_trace(trace_log_file => 'trace.log', trace_log_mode => 'route')`
- `LinkedSpec::configure_trace(trace_log_file => 'trace.log', trace_log_mode => 'mirror')`

Per-call options:
- `trace_level => 'none|low|medium|high|debug'`
- `trace_log_file => 'trace.log'`
- `trace_log_mode => 'route|mirror|stdout'`
- `trace_reset_log => 1`
- `trace_emoji => 1`
- `debug => 1`
- `quiet => 1`

Environment variables:
- `LINKEDSPEC_TRACE_LEVEL`
- `LINKEDSPEC_TRACE_FILE`
- `LINKEDSPEC_TRACE_MIRROR_STDOUT`
- `LINKEDSPEC_TRACE_RESET_FILE`
- `LINKEDSPEC_TRACE_EMOJI`

Trace messages include:
- timestamp,
- trace level,
- file name,
- function name,
- line number,
- indentation for nested flow scopes,
- decision events (`TAKEN` / `SKIPPED`).

## Strong Recommendations for New Specs
If backend neutrality matters, these are the defaults you should follow.

1. Prefer `declare(...)` over raw `my` declarations.
2. Prefer `assign(...)` over raw assignment wrappers.
3. Prefer `assign(scalar(retv), call(rule))` over `$retv = call(rule)`.
4. Prefer `push_value(array(target), value)` over raw `push @target, ...` when you already have a value expression.
5. Prefer `return(payload)` with `array(...)`, `hash(...)`, `array_copy(...)`, legacy `array_values(...)`, and `flat_*` helpers over ad hoc Perl data literals when possible.
6. Prefer helper control-flow markers (`if`, `elseif`, `else`, `endif`, `switch`, `case`, `default`) over raw Perl branch scaffolding when possible.
7. Prefer `array_copy(array(name))` for snapshot payloads, keep `array_values(array(name))` only as compatibility syntax, and use `flat_array(name)` / `flat_hash(name)` for list-context insertion.
8. Use snippet inspection and `return_descr` metadata to verify that the rule stays language-agnostic-action-IR ready.

## Known Caveats and Nuances
- `return(payload)` is the preferred general return form, but method-chain `.return(...)` detection is still more conservative than block-form `return(payload)`.
- Helper shells can still contain raw backend expressions; this is sometimes practical, but it is less portable than pure helper-only authoring.
- Legacy compatibility wrappers are still important because many existing specs depend on them. Keep them in mind when reading old specs, but do not default to them in new code.
- Some old specs are still extraction-oriented and permissive; that is part of LinkedSpec's intended character, not automatically a bug.

## Versioning and Compatibility
Treat existing specs as compatibility contracts.
When changing lowering behavior:
- preserve current AST shapes unless there is a deliberate migration,
- add regression locks when a new lowering surface is introduced,
- prefer canonical helper surfaces over expanding raw fallback.
