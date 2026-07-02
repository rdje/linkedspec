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

## The top (`::`) rule is an ordinary rule, entered first

The double colon is an **entry marker**, not a special construct. `top_rule::` says
"this is the rule a backend enters first." In every other respect a top rule is an
**ordinary rule**: it can carry a regex, take any rule mode, dispatch with `->`/`=>`
edges, and be recursive — exactly like a single-colon rule. The minimal example below
even writes its top rule as `Top::AND` (a mode on a top rule), and other chapters show
`Top::AND /a/ -> Top[0]` (a regex on a top rule); both are legal.

Two long-standing recommendations are therefore **idiom, not engine law**:

- *"Write a no-regex top rule plus one or more normal rules that carry the regex"* — the
  two-rule shape (a `::` dispatch loop that `.push`es and an `LX` that returns the
  accumulator). It is the clean shape for a **stream of records**, and most chapters use
  it, but it is a style choice, not a requirement.
- *"Rule modes are body-rule-only"* — a top rule may carry a mode (`Top::AND`,
  `Stream::OR+`, …) just like a body rule.

A **single recursive document** can be expressed with a recursive top rule directly,
instead of being forced through a stream-of-records dispatcher.

### Reading the match: `entry_*` versus `match_*` on a top rule

A rule reached **by dispatch** reads the *entering* match with the `entry_*` family
(the parent's dispatch is what matched). A **top rule has nothing that entered it**, so
on a top rule the `entry_*` family is empty and an `I` (init) block runs *before* the
rule matches its own regex. To read a top rule's **own** regex match, use a **post-match
edge action** and the `match_*` family:

```text
Pair::AND
 I { declare(hash, pair) }
 /([A-Za-z_]\w*)\s*=\s*/ -> Pair[0] {
   set(hash(pair), set_key(hash(pair), "name", match_group(0)));
 }
 /([^,\n]+)/ -> Pair[1] {
   return(set_key(hash(pair), "value", match_group(0)));
 }
```

On input `name = value` (parse mode `consume`) this returns
`{ "name": "name", "value": "value" }`. (A bare edge-less regex slot in an `AND` rule is
an anchor that is not separately consumed, so fold a separator like `\s*=\s*` into an
adjacent slot that owns an edge, as the name slot does here.)

### Recursion and termination (consume before you recurse)

Recursion is just an edge or a `call(...)` that re-enters a rule — including the top
rule. The one requirement is **forward progress**: every recursive cycle must consume
input before it recurses. A rule that re-enters itself at the **same input position**
without consuming anything is a non-progressing cycle; the engine **cuts** such a
re-entry (it yields `undef`) so the parser terminates instead of hanging. Idiomatic
recursion consumes first — for example a parenthesis rule matches `(`, recurses, then
matches `)` — and is never affected by the cut.

A recursive rule used **as the top rule** is still an ordinary accumulating rule, so —
like any accumulating top rule — it needs an `LX` block to surface its accumulator when
the input is exhausted:

```text
sexpr:: /\(/ /\)/  I { declare(array, items) }
 -> sexpr     { push_value(array(items), call(sexpr)) }
 -> atom      { push_value(array(items), call(atom)) }
 -> sexpr[1]  { return(array_copy(array(items))) }
LX { return(array_copy(array(items))) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
```

With the `LX`, input `(a(b)c)` returns `[["a",["b"],"c"]]` and `(a) (b)` returns
`[["a"],["b"]]` — the top rule accumulates the **sequence** of top-level forms. Without
the `LX`, the same top rule returns `null` (a bare accumulating top rule returns `undef`
at end of input); the `null` is the missing-`LX` authoring case, not an engine fault.

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
 return(hash("kind", "top"));
 }

Next:AND
 /b/ -> Next[0] {
   return(hash("kind", "next", "text", match_text()));
 }
```

Here `label:` belongs to the action block attached to `Top`. It does not start a new `label` rule because the parser is still inside the `{ ... }` block.

The `label:` line is here only to show the block-boundary rule-start distinction: a label-like line inside an open `{ ... }` block is block content, not a new top-level rule. Both rules use the same helper-DSL payload form (`return(hash(...))`), so nothing in this example is backend-specific.

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
