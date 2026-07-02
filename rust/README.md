# LinkedSpec — Rust Variant

A Rust implementation of the [LinkedSpec](https://github.com/rdje/linkedspec) progressive-extraction parser DSL.

## What This Is

The `rust/` directory contains a Cargo workspace with two crates:

| Crate | Purpose |
|-------|---------|
| `linkedspec-core` | `.spec` parser, compiler, validation, HandlerIR types, expression AST |
| `linkedspec-runtime` | Handler execution engine, regex dispatch, helper functions, lifecycle interpreter |

The Rust variant interprets HandlerIR at runtime (no code generation) — the engine walks compiled rule specifications and executes regex matching, child rule dispatch, and lifecycle code as direct Rust function calls.

## Quick Start

```bash
cd rust/
cargo build
cargo test
```

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

- **Declarations**: `declare`, `assign`
- **Arrays**: `array`, `array_copy`, `push_value`, `push_nonempty`, `count`
- **Scalars**: `scalar`, `coalesce`, `coalesce_nonempty`, `concat`
- **Capture**: `entry_text`, `entry_group`, `entry_groups`, `entry_len`
- **Match**: `match_text`, `match_group`, `match_groups`, `match_len`
- **Control flow**: `return`, `return_undef`, `exit_now`, `next`
- **Strings**: `trim`, `lowercase`, `uppercase`, `length`, `substr`, `split`, `split_each`, `trim_each`, `lowercase_each`, `uppercase_each`, `filter_nonempty`, `filter_match`, `uniq`, `sorted`, `reversed`, `take`, `take_last`, `drop_front`, `drop_back`, `slice`, `contains`, `index_of`, `is_empty`, `is_nonempty`, `is_defined`, `is_undefined`, `join_values`, `flat_array`, `concat_arrays`
- **String matching**: `starts_with`, `ends_with`, `contains_substr`, `matches`, `replace_substr`, `rm_prefix`, `rm_suffix`
- **Hashes**: `hash`, `hash_copy`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `sorted_values`, `count_keys`, `has_key`, `flat_hash`; direct nested access reads fields from scalar-held hash/array payloads
- **Arithmetic**: `num_add`, `num_sub`, `num_mul`, `num_div`, `num_mod`, `num_abs`, `num_floor`, `num_ceil`, `num_round`, `num_min`, `num_max`, `num_clamp`, `num_sum`, `num_avg`, `num_median`, `num_range`
- **Cursor/position**: `cursor_pos`, `cursor_line`, `cursor_col`, `cursor_rest`, `cursor_rest_len`, `input_text`, `input_len`, `input_slice`
- **Marks/capture**: `start_capture_slice`, `capture_slice`, `capture_slice_len`, `capture_slice_line`, `capture_slice_pos`, `mark_here`, `mark_pos`, `mark_exists`, `capture_from`
- **Debug**: `print`, `say`, `print_each`
- **Dispatch**: `call`

## Relationship to Perl Reference

The Perl reference implementation lives at `perl/LinkedSpec.pm`. The Rust variant:

- Uses the **same** `.spec` file format (parses all 20 shipped specs)
- Uses the **same** lifecycle model (I/LS/LE/E/EX/IT/LX blocks)
- Uses the **same** regex dispatch semantics (seek/consume modes)
- Uses the **same** rule modes (AND, OR, OR+, AND+, bounded, *, +, ?, &, |)
- **Does not** generate Perl code or use `eval` — HandlerIR is interpreted directly
- **Does not** implement the legacy plugin system (`.plg` files, `PPlugin`)

## Test Corpus

All 20 shipped `.spec` files from the parent `specs/` directory are parsed, validated, and compiled as part of the test suite. The integration test covers:

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
