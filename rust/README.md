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

- **Working variables and assignment**: auto-existing scalar/array/hash variables, `name = value`, `set(target, value)`, `set(array(name), [])`, `set(hash(name), {})`
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
