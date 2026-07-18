# LinkedSpec — Rust Variant

A Rust implementation of the [LinkedSpec](https://github.com/rdje/linkedspec) progressive-extraction parser DSL.

## What This Is

The `rust/` directory contains a Cargo workspace with two crates:

| Crate | Purpose |
|-------|---------|
| `linkedspec-core` | `.spec` parser, compiler, validation, HandlerIR types, expression AST |
| `linkedspec-runtime` | Handler execution engine, regex dispatch, helper functions, lifecycle interpreter, generated-source scaffold |

The Rust variant primarily interprets its compiled structural contract at runtime: the engine walks compiled rule
specifications and executes regex matching, child rule dispatch, and lifecycle code as direct Rust function calls.
It also exposes a generated-source path (`linkedspec_runtime::source_emitter`) that emits a Rust module embedding a
`CompiledSpec`, source identity, contract metadata, a validated rule-family plan, and typed `execute(input)` plus
compatible string-returning `parse(input)` entry points. Generated parsers now route through a
plan-aware executor: default, OR acode, AND acode, AND bcode, OR bcode, REP acode, REP bcode, REP-AND acode, and
REP-AND bcode families run directly. The generated-source test harness validates every supported structural family
and a manifest-backed corpus subset; the full 105-fixture corpus remains the interpreter oracle gate.

### Generated Rust source

New native callers should use the typed v1 API and supply the identity that owns the compiled input:

```rust
use linkedspec_runtime::source_emitter::{
    GeneratedSourceError, emit_rust_source_v1,
};

let source = emit_rust_source_v1(&compiled, "specs/example.spec")?;

// If a caller's Rust compiler rejects the emitted module, project that host
// boundary into the same portable generated-source error contract.
let compile_error = GeneratedSourceError::compile_failed(
    "specs/example.spec",
    "rustc exited with status 1",
);
assert_eq!(compile_error.source_identity, "specs/example.spec");
# Ok::<(), Box<dyn std::error::Error>>(())
```

The generated module exports exact contract id, format version, source identity, and `metadata()`. Its typed
`execute`/`execute_with_trace` entrypoints return the direct top-rule value or `GeneratedSourceError`; legacy
`parse`/`parse_with_trace` retain their original accumulator result and `String` error API. `plan()` exposes exact
ordered `label`/neutral-family rows, and `validate_plan(...)` distinguishes count, label, known-family mismatch,
and unknown-family failures before execution. Portable generated-rule enter/family/exit trace roles appear beside
the richer native trace. `emit_rust_source(&compiled)` remains a compatibility adapter using `<inline>` identity.

## Quick Start

```bash
cd rust/
cargo build
cargo test
```

From the repository root, `bash tools/run_rust_local.sh` is the focused operational gate. It checks formatting,
runs the complete `linkedspec-core` package before the complete `linkedspec-runtime` package, builds the primary
command, and runs the shared byte-exact CLI manifest in default and POSIX option environments. During the staged
rule-local cursor migration the package tests are green and the primary leg is intentionally 51/63 until
`FUTURE-PARITY-BACKLOG.9.1.4.6` removes the retired global option/trace projection.

Rust execution is current through `.9.1.4.3`. The parser retains complete-line and header-rest bare edges as
typed nodes; validation derives AND bare edges as blind calls and OR/default bare edges as action edges, rejects
undefined/mixed/index/group shapes with portable code/stage/fields, and compilation preserves that ownership in
the corresponding dispatch table. Compact `|` is authored OR and compact `&` is authored AND. Normal live,
loaded, and ordinary JSON-reconstructed rules derive seek/consume from the rule being entered; compiled rules no
longer store an independently mutable policy, and the staged caller option cannot override live behavior.
Descriptor v1, generated-source v1-to-v2 migration, and public option/CLI removal remain staged under
`.9.1.4.4-.6` through explicit compatibility adapters.

### Compiled descriptor introspection

Rust exposes the backend-neutral outward descriptor directly from its in-memory compiled state:

```rust
use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;

let spec = parse_spec("Top::\n -> Child\n\nChild:\n /x/\n")?;
let compiled = compile(&spec)?;

let typed = compiled.descriptor_state();
assert_eq!(typed.meta.descriptor_model, "compiled_descriptor_state");
assert_eq!(typed.meta.compiled_rule_order, ["Top", "Child"]);
assert_eq!(typed.spec["Top"].dependency_refs[0].label, "Child");

let json = compiled.to_descriptor_json()?;
assert!(json.get("dependency_regex_map").is_some());
# Ok::<(), Box<dyn std::error::Error>>(())
```

`descriptor_state()` returns typed, serializable records from `linkedspec_core::descriptor`;
`to_descriptor_json()` returns the same public `spec` / `functions` / `dependency_regex_map` / `meta` projection
as JSON. Neither API depends on `linkedspec-runtime` or launches a subprocess. Runtime execution continues to use
`CompiledSpec` directly.

### Structured runtime diagnostics

Native Rust callers can opt into the backend-neutral diagnostic record without changing existing string-returning
code:

```rust
use linkedspec_runtime::engine::Engine;

let engine = Engine::new(compiled)
    .with_spec_name("Example")
    .with_spec_path("/specs/Example.spec");

match engine.execute_with_diagnostics("input") {
    Ok(value) => println!("{value}"),
    Err(error) => {
        eprintln!("{}", error.message());
        eprintln!("failing rule: {:?}", error.diagnostic().rule_label);
        eprintln!("{}", error.to_json()?);
    }
}
# Ok::<(), Box<dyn std::error::Error>>(())
```

`RuntimeExecutionError` keeps the original message and a serializable `RuntimeDiagnostic` with `type`, `stage`,
`owner_stage`, `summary`, `detail`, and available spec/top/rule/handler identity. Use
`execute_value_with_diagnostics(...)` for direct entry-rule values. Existing `execute(...)` / `execute_value(...)`
remain compatible `Result<_, String>` adapters over the same path; successful JSON values are identical.

## Architecture

```
.spec file
    │
    ▼
┌──────────────────────────┐
│  linkedspec-core         │
│  ├─ parser.rs            │  → AST (SpecFile, Rule, BodyElement)
│  ├─ validation.rs        │  → validates rules, edges, regexes
│  ├─ compiler.rs          │  → CompiledSpec (HandlerIR-like)
│  ├─ expr.rs              │  → expression parser (CodeBlock)
│  └─ types.rs             │  → shared types (RuntimeValue, ParseMode)
└──────────┬───────────────┘
           │ CompiledSpec
           ▼
┌──────────────────────────┐
│  linkedspec-runtime      │
│  ├─ engine.rs            │  → lifecycle loop, helper dispatch
│  ├─ helpers/regex_engine │  → regex alternation (seek/consume)
│  ├─ runtime.rs           │  → RuntimeContext (variable store)
│  ├─ source_emitter.rs    │  → generated Rust module emitter + family plan
│  └─ helpers/             │  → 80+ helper functions
└──────────┬───────────────┘
           │
           ▼
       JSON output
```

## Lifecycle Loop

For non-repeating rules: `I → LS → match → (acode dispatch) → LE → E`
For repeating rules: `I → loop { LS → match → LE → IT } → EX → E`
On no-match: `I → LS → no match → LX → E`

## Supported Helpers (v0.1)

The engine implements 80+ helpers covering:

- **Working variables and assignment**: Bare typed bindings carry scalar, array, harray, or codeblock values; use `name = value` or `set(name, value)`, including `set(items, [])` and `set(meta, {})`
- **Unknown helper fallback**: helper-looking calls outside the current contract return `undef` through the generic unknown-helper path rather than a name-specific retired-helper implementation
- **Arrays**: `array`, `copy`, `push`, explicit `is_nonempty(...)` guard plus `push(...)`, `count`
- **Scalars**: bare scalar reads, `coalesce`, `coalesce_nonempty`, `cat`
- **Capture**: `entry_text`, `entry_group`, `entry_groups`, `entry_len`
- **Match**: `match_text`, `match_group`, `match_groups`, `match_len`
- **Control flow**: `return`, `return_undef`, `exit_now`, `next`
- **Strings**: `trim`, `lowercase`, `uppercase`, `length`, `substr`, `split`, `split_each`, `trim_each`, `lowercase_each`, `uppercase_each`, `filter_nonempty`, `filter_match`, `uniq`, `sorted`, `reversed`, `take`, `take_last`, `drop_front`, `drop_back`, `slice`, `contains`, `index_of`, `is_empty`, `is_nonempty`, `is_defined`, `is_undefined`, `join_values`, `flat_array`, `concat_arrays`
- **String matching**: `starts_with`, `ends_with`, `contains_substr`, `matches`, `replace_substr`, `rm_prefix`, `rm_suffix`
- **Hashes**: `hash`, `copy`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `sorted_values`, `count_keys`, `has_key`, `flat_hash`; direct nested access reads fields from scalar-held hash/array payloads
- **Arithmetic**: `num_add`, `num_sub`, `num_mul`, `num_div`, `num_mod`, `num_abs`, `num_floor`, `num_ceil`, `num_round`, `num_min`, `num_max`, `num_clamp`, `num_sum`, `num_avg`, `num_median`, `num_range`
- **Cursor/position**: `cursor_pos`, `cursor_line`, `cursor_col`, `cursor_rest`, `cursor_rest_len`, `input_text`, `input_len`, `input_slice`
- **Marks/capture**: anonymous start/bridge, slice/line/column/position, stable and advancing cursor/rest reads;
  named mark creation, input boundaries, copy/existence/position, stable and advancing from/between reads, and
  anonymous-to-named capture bridging. Bare mark arguments remain symbolic identifiers; quoted names are also
  accepted.
- **Debug**: `print`, `say`, `print_each`
- **Dispatch**: `call`

## Logical Helpers

`and`, `or`, and `not` are ordinary eager boolean value helpers. `and` and `or` require at least one positional
operand; `not` requires exactly one. The runtime validates those arities before evaluating an operand, so
`and()` and `not(false, side_effect())` fail with `helper_arity_mismatch` without running `side_effect()`.
After a valid call is admitted, every operand evaluates exactly once from left to right—even after a decisive
false `and` value or true `or` value.

`RuntimeValue::as_bool` is the shared typed truth seam for those helpers and lazy `if`/`switch`/`while` controls.
Null, false, numeric zero, empty strings, and empty arrays/harrays are false. Nonzero numbers, every nonempty
string (including `"0"` and `"false"`), and nonempty aggregates are true. A typed codeblock is true without being
invoked; this does not activate the separately owned explicit callable-literal syntax.

```text
Top::
 /x/
 E {
   seen = []
   eager = or(true, { push(seen, "still-runs"); return(false) })
   lazy = if(false, { push(seen, "skipped"); return(true) }, { return(false) })
   return(hash("eager", eager, "lazy", lazy, "seen", copy(seen)))
 }
```

The result is `{"eager":true,"lazy":false,"seen":["still-runs"]}`. Native and serialized execution, generated
plans, typed `execute_generated_parser_v1` / traced v1, compatibility direct/traced calls, and independently
compiled emitted `execute`/`execute_with_trace`/`parse`/`parse_with_trace` roles preserve that behavior. Typed v1
returns the direct top-rule value; compatibility roles intentionally retain their historical parse-output array.
Shared primary case `success_logical_helpers_eager` passes every backend command in default and POSIX
environments. Run the whole recurring cross-backend proof from the repository root with
`bash tools/check_logical_helper_five_backend.sh`.

## Diagnostic Output Events

Parser-authored `print`, `say`, and `print_each` use a caller-owned typed event channel; they never write host
stdout/stderr directly. Arity rejects before effects (`print`/`say` need at least one argument; `print_each` needs
two or three), valid arguments evaluate once left-to-right, and an absent sink stays quiet. Native top-rule and
direct-value execution accept the optional sink explicitly through `execute_with_diagnostic_output` and
`execute_value_with_diagnostic_output`:

```rust
use linkedspec_runtime::{RuntimeDiagnosticOutputEvent, RuntimeDiagnosticOutputSink};
use std::{cell::RefCell, convert::Infallible, rc::Rc};

let events = Rc::new(RefCell::new(Vec::<RuntimeDiagnosticOutputEvent>::new()));
let captured = Rc::clone(&events);
let sink = RuntimeDiagnosticOutputSink::new(move |event| {
    captured.borrow_mut().push(event);
    Ok::<(), Infallible>(())
});

let output = engine.execute_with_diagnostic_output(input, Some(&sink))?;
let value = engine.execute_value_with_diagnostic_output(input, &options, Some(&sink))?;
```

Each `RuntimeDiagnosticOutputEvent` has exactly `helper_name`, `rule_label`, and Unicode `message`. Rich events
stay outside `RuntimeDiagnostic`, native trace, parse values, and the primary command. The typed
`RuntimeDiagnosticOutputExecutionError` keeps ordinary runtime failure, the caller's concrete sink error, and
`RuntimeExitNow { status }` distinct.

Emitted modules preserve legacy `execute`/`execute_with_trace` signatures and add paired
`execute_with_diagnostic_output` and `execute_with_trace_and_diagnostic_output` entrypoints:

```rust
let value = generated_parser::execute_with_diagnostic_output(input, Some(&sink))?;
let traced = generated_parser::execute_with_trace_and_diagnostic_output(
    input,
    trace_config,
    Some(&sink),
)?;
```

Compatibility generated roles likewise expose `parse_with_diagnostic_output` and
`parse_with_trace_and_diagnostic_output`. Their `GeneratedDiagnosticOutputExecutionError` preserves generated-
source attribution, compatibility failure, caller sink error, and typed immediate exit as separate outcomes.

## Relationship to Perl Reference

The Perl reference implementation lives at `perl/LinkedSpec.pm`. The Rust variant:

- Uses the **same** `.spec` file format (parses all 21 shipped specs)
- Uses the **same** lifecycle model (I/LS/LE/E/EX/IT/LX blocks)
- Uses the **same** regex dispatch semantics (seek/consume modes)
- Uses the **same** rule modes (AND, OR, OR+, AND+, bounded, *, +, ?, &, |)
- **Does not** generate Perl code or use `eval` — the default runtime path interprets `CompiledSpec` directly
- Provides generated Rust source that embeds `CompiledSpec` plus a validated family plan; default/OR/AND acode and
  AND/OR/REP acode-bcode families now execute directly through the plan-aware generated executor, with an
  all-family compile/run matrix plus a curated manifest-backed corpus-subset proof
- **Does not** implement the legacy plugin system (`.plg` files, `PPlugin`)

## Test Corpus

All 21 shipped `.spec` files from the parent `specs/` directory are parsed, validated, and compiled as part of the test suite. The integration test covers:

- Full pipeline: parse → validate → compile → execute
- Recursive grammars (self-referencing rules with multi-entrypoint dispatch)
- Lifecycle marker ordering (I, LS, LE, IT, LX, EX, E)
- Blind-call dispatch (AND rules with sequential `=> child` edges)
- REP bounds (OR{N,M}, *, +, bounded repetition)

## Building

Requirements: Rust 1.85+ (edition 2024).

```bash
cd rust/
cargo build
cargo test
cargo clippy
cargo build --release
```

## License

MIT OR Artistic-2.0 (same as the Perl reference).
