# How To Use This Book

This book is meant to support two different reading styles.

## Fast path

If you need to get productive quickly, read in this order:

1. [What FSMGen Is](./overview/what-is-fsmgen.md)
2. [Quick Start](./using/quickstart.md)
3. [Configuration Surfaces](./using/configuration.md)
4. [Inputs And Entrypoints](./using/inputs-and-entrypoints.md)
5. [Generated Output](./using/generated-output.md)

## Deep path

If you need to understand how FSMGen really works, continue with:

1. [FSM Source Model](./model/fsm-source-model.md)
2. [Hierarchy And Tops](./model/hierarchy-and-tops.md)
3. [Signals, Ports, Maps, And Overrides](./model/signals-ports-and-maps.md)
4. [Perl API Reference](./reference/perl-api.md)
5. [Plugin API Reference](./reference/plugin-api.md)

## Scope

This book is specifically about **FSMGen**.

It is not intended to duplicate the entire LinkedSpec parser DSL guide. When FSMGen depends on broader LinkedSpec behavior, this book should explain the dependency clearly and then point to the broader project docs only where that adds real value.

## Source-of-truth rule

For FSMGen-specific behavior, the active code surfaces are currently:

- `perl/FSMGen.pm`
- `plugin/fsmgen.plg`
- `perl/env.conf`
- `conf/vhdl_template.conf`
- `conf/xif.conf`

This book should stay aligned with those files.

## Documentation philosophy

The target style for this book is:

- beginner-friendly first,
- exact and technical when needed,
- and explicit about what is inferred from current code versus what is a stable user-facing contract.
