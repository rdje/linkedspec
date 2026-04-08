# Building This Book

## Local build

From the repository root:

```bash
cd docs/fsmgen-book
mdbook build
```

## Local preview server

```bash
cd docs/fsmgen-book
mdbook serve
```

## Current local prerequisites

The base book builds with:

- `mdbook`

The current local environment already has:

- `mdbook v0.5.2`

## Mermaid diagrams

This book is structured so Mermaid can be added cleanly, but the current local environment does not include `mdbook-mermaid`.

If you want Mermaid diagrams to render natively instead of appearing as fenced code blocks, install:

```bash
cargo install mdbook-mermaid
```

and then wire the corresponding preprocessor configuration into `book.toml`.

## Build output

The generated HTML output is written under:

- `docs/fsmgen-book/book/`

That path is intentionally ignored by the local book-specific `.gitignore`.
