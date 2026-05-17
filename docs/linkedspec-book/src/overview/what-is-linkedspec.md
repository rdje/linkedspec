# What LinkedSpec Is

LinkedSpec is a progressive extraction parser DSL and compiler for Perl.

It takes `.spec` files — a compact, rule-paragraph language — and compiles them into ready-to-call parser coderefs. Those parsers match structured input, extract meaningful regions, and return AST payloads defined by the spec author.

## What LinkedSpec is good at

LinkedSpec compiles `.spec` files into parsers that excel at:

- recursive and nested structures (Lisp-like forms, config languages, hardware descriptions)
- coarse-to-fine extraction flows (find interesting regions first, then parse inside them)
- regex-anchored parsing (anchor on strong tokens/signatures, recurse downward)
- fast parser prototyping (write rules, add actions, invoke — no code generation step)

It is intentionally not trying to be a strict, textbook EBNF parser-generator clone. The design center is practical extraction and recognition, not exhaustive ambiguity resolution.

## How it works at a glance

A `.spec` file is organized as rule paragraphs. Each rule has:

- a label and mode (e.g., `Top::` for the entry point, `Child:AND+` for repeated matching)
- optional regex anchors (`/pattern/`)
- action edges (`-> ChildRule { ... }`) or blind-call edges (`=> helper { ... }`)
- lifecycle blocks (`I`, `E`, `EX`, `IT`, `LS`, `LE`, `LX`) for setup, teardown, and state management

The compiler (via `LinkedSpec::Get(\$spec)`) parses the `.spec`, builds compiled rule state, derives dependency-regex dispatch data, optionally builds a compiled descriptor for introspection, and returns a parser coderef. Callers invoke that coderef with input text and get back AST data structures.

## Example: a minimal key/value parser

```text
Top::AND+
 /(\w+)=(\w+)/ -> Top[0] {
   return(hash("key", entry_group(1), "val", entry_group(2)));
 }
```

This one-rule spec matches one or more `key=value` pairs, extracts both groups per match, and returns a hash per match.

## Where LinkedSpec fits

LinkedSpec is especially useful when:

- you want to parse a language or format without building a full compiler frontend
- your inputs have recognizable anchors that let you skip uninteresting regions
- you need structured AST output from parser rules, not just a match/no-match result
- you want to prototype parser behavior quickly and iterate on rules
- the real-world structure of your inputs matters more than formal grammar compliance

## What comes out of it

The normal outcome of `LinkedSpec::Get(...)` or `LinkedSpec::get_parser(...)` is a parser coderef. Call it with input text to get AST output.

The compiler can also expose a compiled descriptor — a structured data payload containing rule tables, dependency-regex maps, and metadata — for tooling, diagnostics, and introspection.

Parser compilation, the public API, and descriptor introspection are covered in detail later in the book.
