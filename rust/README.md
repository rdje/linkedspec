# LinkedSpec — Rust Implementation

A Rust variant of LinkedSpec, living alongside the Perl reference implementation (`perl/`).

## Status

**v0.1** — Core pipeline operational: parse `.spec` files, compile to HandlerIR,
execute via interpreted runtime engine. Passes unit tests.

## Architecture

```
┌──────────────┐     ┌──────────────┐
│ linkedspec-  │────▶│ linkedspec-  │
│ core         │     │ runtime      │
│              │     │              │
│ • Parser     │     │ • Engine     │
│ • Validator  │     │ • Helpers    │
│ • Compiler   │     │ • Runtime    │
│ • Types      │     │ • Regex      │
└──────────────┘     └──────────────┘
```

- **linkedspec-core**: `.spec` parser, validator, compiler, HandlerIR types.
  Zero runtime dependencies beyond `regex` and `serde`.

- **linkedspec-runtime**: Execution engine. Consumes HandlerIR nodes from core.
  Interprets handlers at runtime (not code-gen).

## Quick Start

```bash
# Build
cargo build

# Run tests
cargo test

# Run specific test
cargo test -p linkedspec-core
```

## Relationship to Perl Reference

The Perl implementation (`perl/LinkedSpec.pm`) is the **reference** — the canonical
behavioral oracle. The Rust implementation:

- Consumes the same `.spec` files (identical grammar).
- Targets identical parse results (validated against `tests/corpus/`).
- Uses the same HandlerIR specification (`docs/knowledge/handler-ir-design.md`).

### Design Decisions

- **Interpreted, not compiled**: Handlers are interpreted from HandlerIR at runtime
  rather than generating Rust source code. This avoids the `eval` problem.
- **Two crates**: Core (backend-agnostic) separated from Runtime (language-specific).
- **Regex crate**: Uses Rust's `regex` crate with `find_at` for position-anchored matching.

### Current Limitations

- Helper surface is partial — enough for the `simple_grammar` test corpus entry.
  Full 100+ helper surface planned for v0.2.
- Lifecycle code is pattern-matched rather than properly interpreted.
- No code-gen emitter (planned for v0.3 when HandlerIR is stable).
- Test corpus compliance is partial (3/3 entries seeded, validation pending).

## Specification Documents

See the mdBook appendix for full specifications:

- [Formal `.spec` Grammar](../docs/linkedspec-book/src/appendix/formal-grammar.md)
- [HandlerIR Specification](../docs/knowledge/handler-ir-design.md)
- [Helper Contract Catalog](../docs/linkedspec-book/src/appendix/helper-contract-catalog.md)
- [Runtime Semantics](../docs/linkedspec-book/src/appendix/runtime-semantics.md)
- [Backend Handoff](../docs/linkedspec-book/src/appendix/backend-handoff.md)

## License

MIT OR Artistic-2.0 (same as Perl reference).
