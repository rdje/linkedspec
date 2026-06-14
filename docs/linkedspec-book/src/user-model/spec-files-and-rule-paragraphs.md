# `.spec` Files and Rule Paragraphs

One of the most important LinkedSpec ideas is that `.spec` files are best understood as sequences of rule paragraphs.

## The mental model

Each rule paragraph starts with a rule-start token such as:

```text
rule_name:
top_rule::
```

Once that rule start is seen at top level, the rest of the paragraph belongs to that rule until the next top-level rule start or end of file.

This is a better mental model than thinking of `.spec` files as rigid line-by-line mini-programs.

## Minimal example

```text
Top::AND
 => Word

Word:AND
 /foo/ -> Word[0] {
   return(hash("kind", "word", "text", match_text()));
 }
```

This file contains two rule paragraphs:

- `Top::AND`
- `Word:AND`

`Top` is written with the double-colon form because it is intended as an entry-style rule in this example. `Word` is written with the single-colon form because it is a normal child rule.

The body of `Top` contains:

- one blind-call edge: `=> Word`

The body of `Word` contains:

- one regex anchor: `/foo/`
- one action edge: `-> Word[0] { ... }`

The action returns a structured helper-built payload rather than depending on the older compact `return_a(...)` helper style.

## Why it matters

This paragraph-oriented model helps explain why LinkedSpec is comfortable with:

- mixed regex and action content inside a rule paragraph
- lifecycle/code blocks
- recursive rule dispatch
- same-line and multiline authoring styles

It also explains why top-level validation matters so much: the parser has to know when a new rule really starts and when a label-like line is still just content inside an open block.

## Top-level rule starts versus block content

Rule starts are top-level constructs. A label-like line inside an open block is not a new rule.

```text
Top::AND
 /a/ -> Top[0] {
label:
 return { kind => "top" };
 }

Next:AND
 /b/ -> Next[0] {
   return(hash("kind", "next", "text", match_text()));
 }
```

Here `label:` belongs to the action block attached to `Top`. It does not start a new `label` rule because the parser is still inside the `{ ... }` block.

This example uses a raw Perl label only to show the block-boundary rule-start distinction. New payload-shaping code should prefer helper DSL forms like the `Next` rule's `return(hash(...))` action.

This matters because LinkedSpec allows rule bodies to carry real action and lifecycle blocks. If the frontend treated every `word:` token as a rule start, it would misread valid block content.

## What can appear inside a rule paragraph

A rule paragraph can include supported paragraph members such as:

- regex tokens such as `/.../`
- action edges such as `-> Child`
- blind-call edges such as `=> Child`
- action blocks such as `{ ... }`
- lifecycle blocks such as `I { ... }`, `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, and `LX { ... }`
- split/capture markers such as `@capture_slice` and `@mark(name)`
- method-like helper forms that lower through ActionIR

The exact set of supported forms is intentionally validated. Stray top-level text is not “mostly okay.” It should be rejected clearly so users do not accidentally depend on token loss or partial parsing.

## Same-line and multiline styles

LinkedSpec supports compact same-line authoring:

```text
Top::AND => Word
Word:AND /foo/ -> Word[0] { return(hash("kind", "word", "text", match_text())); }
```

It also supports the clearer multiline style:

```text
Top::AND
 => Word

Word:AND
 /foo/
 -> Word[0] {
   return(hash("kind", "word", "text", match_text()));
 }
```

The multiline style is usually better for non-trivial rules. It leaves room for lifecycle blocks, markers, helper chains, and comments without forcing readers to scan a dense one-liner.

## Conventional layout versus actual structure

Most `.spec` files naturally use this order:

```text
RuleName:
 /anchor/
 -> Child { ... }
```

That convention is useful, but the deeper point is that the rule paragraph is the unit of structure. Regexes, lifecycle blocks, edges, and helper forms are members of the paragraph.

So when reading a `.spec` file, ask:

- What rule paragraph am I in?
- Which top-level member comes next?
- Am I inside an open block, or back at paragraph top level?

Those questions will explain most of the syntax behavior more reliably than a strict line-oriented mental model.

## Where to go next

- Read [Worked `.spec` Walkthrough](worked-spec-walkthrough.md) for a small end-to-end inline parser.
- Read the rule-modes and parse-modes chapter next for execution behavior.
- Read [Action and Lifecycle Placement](../dsl/action-and-lifecycle-placement.md) when you need to know where action edges and lifecycle blocks run.
- Use the repo `USER_GUIDE.md` when you want the denser working reference while this book is still growing.
