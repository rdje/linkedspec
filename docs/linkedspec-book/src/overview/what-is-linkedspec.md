# What LinkedSpec Is

LinkedSpec is a progressive extraction parser DSL.

At a high level, it compiles `.spec` files into parsers that are good at:

- recursive and nested structures
- coarse-to-fine extraction flows
- regex-anchored parsing
- fast parser prototyping

It is intentionally not trying to be a strict, textbook EBNF parser-generator clone.

## The core idea

LinkedSpec is built around the idea that many practical parsers are easier to author when you can:

- anchor on useful regexes
- recurse into children where needed
- attach actions close to the rule structure
- and stage parsing progressively instead of pretending every input wants the same token-by-token treatment

That makes it especially suitable for parser prototyping, extraction-heavy workflows, and grammars where real-world structure matters more than formal grammar purity alone.

## What comes out of it

The normal outcome of a LinkedSpec compile is a parser coderef. Internally, the compiler can also expose richer descriptor/state information for tooling, diagnostics, and introspection.

Those parser and descriptor surfaces are covered later in the book.
