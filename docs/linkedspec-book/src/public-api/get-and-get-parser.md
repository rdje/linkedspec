# `Get(...)` and `get_parser(...)`

These are the two public entry points most readers should know first.

## `LinkedSpec::Get(...)`

`Get(...)` is the inline compile path. It works from in-memory spec content and is convenient for direct parser construction, experiments, and tooling flows.

## `LinkedSpec::get_parser(...)`

`get_parser(...)` is the file-oriented path. It resolves a named spec, loads it, compiles it, and returns a parser.

## Why both exist

They serve different usage patterns:

- `Get(...)` is great for inline or tooling-oriented work
- `get_parser(...)` is great for repo/spec-name based workflows

Internally, both flow into the same broader runtime/compiler story, but they carry different setup responsibilities and diagnostics seams.
