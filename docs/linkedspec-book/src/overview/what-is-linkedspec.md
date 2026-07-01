# What LinkedSpec Is

LinkedSpec is a progressive extraction parser DSL. The `.spec` language is its universal contract; a LinkedSpec *backend* compiles those `.spec` files into ready-to-call parsers. The Perl implementation is the reference backend (the canonical behavioral oracle), and additional backends (such as Rust) run the same `.spec` files with identical semantics.

A `.spec` file is a compact, rule-paragraph language. A backend compiles it into a runnable parser (a coderef in the Perl reference backend). Those parsers match structured input, extract meaningful regions, and return AST payloads defined by the spec author.

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

A backend's compiler parses the `.spec`, builds compiled rule state, derives dependency-regex dispatch data, optionally builds a compiled descriptor for introspection, and returns a runnable parser. Callers invoke that parser with input text and get back AST data structures. (In the Perl reference backend the entry point is `LinkedSpec::Get(\$spec)`; other backends expose an equivalent entry point.)

## Example: a minimal key/value parser

```text
top::
 -> pair .push

LX { return(array_copy(array(top))) }

pair:
 /(\w+)=(\w+)/ I {
   return(hash("key", entry_group(0), "val", entry_group(1)));
 }
```

This is a two-rule spec — the **recommended idiom** for stream-of-records parsing (a
`::` dispatch loop plus a normal rule that carries the regex):

- The **entry rule** `top::` carries **no regex of its own**. It is the dispatch loop: it repeatedly hands off to `pair` and `.push`es each result onto its accumulator, then `LX` returns a snapshot of that accumulator when the input is exhausted.
- The **`pair` rule** carries the regex. On each match it returns a hash built from the two capture groups — `entry_group(0)` is the first group, `entry_group(1)` the second (group numbering is 0-based and captures-only; see [Regex in `.spec`](../user-model/regex-in-spec.md)).

For input `foo=bar baz=qux` the parser returns `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]` — one hash per matched pair, collected by the entry rule. (In this idiom the regex lives on the normal `:` rule, not the `::` entry rule. That is a style choice, not a rule: `::` is just an *entry marker*, and a top rule is otherwise an ordinary rule that may carry a regex, take a mode, or recurse — see [.spec Files and Rule Paragraphs](../user-model/spec-files-and-rule-paragraphs.md).)

## Where LinkedSpec fits

LinkedSpec is especially useful when:

- you want to parse a language or format without building a full compiler frontend
- your inputs have recognizable anchors that let you skip uninteresting regions
- you need structured AST output from parser rules, not just a match/no-match result
- you want to prototype parser behavior quickly and iterate on rules
- the real-world structure of your inputs matters more than formal grammar compliance

## What comes out of it

The normal outcome of compiling a `.spec` is a runnable parser. Call it with input text to get AST output. (In the Perl reference backend that parser is a coderef returned by `LinkedSpec::Get(...)` or `LinkedSpec::get_parser(...)`; other backends return the equivalent runnable parser for their language.)

The compiler can also expose a compiled descriptor — a structured data payload containing rule tables, dependency-regex maps, and metadata — for tooling, diagnostics, and introspection.

Parser compilation, the public API, and descriptor introspection are covered in detail later in the book.
