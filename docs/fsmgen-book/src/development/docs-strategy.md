# Documentation Strategy

This book is meant to become the comprehensive FSMGen documentation surface.

## What this first mdBook slice establishes

It establishes:

- a dedicated FSMGen book root,
- a navigable chapter hierarchy,
- a progressive reading order,
- and explicit places for both user-facing and internals-facing documentation.

## Expansion rule

Future documentation work should generally expand chapters in this order:

1. user-facing entrypoints,
2. configuration keys,
3. source syntax and examples,
4. generated output semantics,
5. internal model and architecture details,
6. troubleshooting and recipes.

## Quality bar

For this book, the standard should be:

- clear semantics,
- concrete examples,
- progressive depth,
- and enough cross-linking that a reader can move from “what is this?” to “how is this implemented?” without getting lost.

## Source alignment

When behavior changes in:

- `perl/FSMGen.pm`
- `plugin/fsmgen.plg`
- `perl/env.conf`
- related `conf/` files

the corresponding chapters in this book should be updated as part of the same change when the behavior is user-relevant.
