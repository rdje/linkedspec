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

## Default-entry markers are ordinary rules

The double colon is an authored **default-entry marker**, not a special construct.
Without an explicit selector, the first `Rule::` is entered before any ordinary rule.
An explicit selector may instead enter any declared rule. In every other respect a marked
rule is an **ordinary rule**: it can carry a regex, take any rule mode, dispatch with
`->`/`=>` edges, and be recursive — exactly like a single-colon rule. The runnable stream
examples in this book still use the clearer two-rule shape: a no-regex default entry that
dispatches to normal matcher rules.

Two long-standing recommendations are therefore **idiom, not engine law**:

- *"Write a no-regex top rule plus one or more normal rules that carry the regex"* — the
  two-rule shape (a `::` dispatch loop that `.push`es and an `LX` that returns the
  accumulator). It is the clean shape for a **stream of records**, and most chapters use
  it, but it is a style choice, not a requirement.
- *"Rule modes are body-rule-only"* — a top rule may carry a mode (`Document::AND`,
  `Stream::OR+`, …) just like a body rule.

A **single recursive document** can be expressed with a recursive top rule directly,
instead of being forced through a stream-of-records dispatcher.

### Entry-selection precedence and current rollout

An explicit entry selector has highest priority. On the shared primary command,
`--top-rule NAME` may select any declared rule—including an ordinary single-colon rule—and
wins even when the source contains one or more `Rule::` markers. Without an explicit
selector, the first authored `Rule::` in definition order wins; without a marker, the first
authored rule wins.

The composed Perl, Rust, Dart, and Julia backends implement all three branches across their admitted native,
loaded/reconstructed, generated/emitted, traced, diagnostic, and primary-command routes. Their hand-authored
selection fixtures return distinct values from entry lifecycle `I`, which directly proves which rule was entered;
an `E` block can coincidentally return the same final value after a successful match and is weaker evidence.

Lua core now exposes the same order on PUC Lua and LuaJIT: validation accepts one-or-more-rule markerless source,
one compiled-state resolver selects before runtime context/user code, zero/unknown failures are portable, and the
descriptor preserves authored marker identity. Its hand-authored regressions use `I` for direct entry evidence.
Loaded source, normalized reconstruction, generated-v1 direct/traced, and freshly emitted direct/traced calls now
reuse that resolver without adding selection fields to generated plans. Low trace and portable wrapper failures
carry the same requested/effective/basis or stage/code identity on both ABIs. Cursor migration and final Lua
admission are now complete under `.9.1.7` and `.9.1.1.2.5.3`. One exact shared-source 15-role consumer passes
139/139 on each ABI, package 177/177x2, primary 65/65x4, and corpus 105/105x2. Markerless execution is implemented
and final recurring/public no-drift closes rollout at 7 complete / 0 pending. Run
`bash tools/check_root_rule_selection_five_backend.sh` for the composed six-runtime and selected-primary proof.
Cursor public no-drift is separately closed at 74 migration files, 8 complete / 0 pending, and 60 rejected
mutations; rule-local cursor behavior is defined by authored family, not a caller option.

### Reading the match: `entry_*` versus `match_*` on a top rule

A rule reached **by dispatch** reads the *entering* match with the `entry_*` family
(the parent's dispatch is what matched). A **top rule has nothing that entered it**, so
on a top rule the `entry_*` family is empty and an `I` (init) block runs *before* the
rule matches its own regex. To read a top rule's **own** regex match, use a **post-match
edge action** and the `match_*` family:

```text
Pair::AND
 I { pair = {} }
 /([A-Za-z_]\w*)\s*=\s*/
 /([^,\n]+)/
 -> Pair[0] {
   set(pair, set_key(pair, "name", match_group(0)));
 }
 -> Pair[1] {
   return(set_key(pair, "value", match_group(0)));
 }
```

On input `name = value` (parse mode `consume`) this returns
`{ "name": "name", "value": "value" }`. The two declarations belong to `Pair`; the later
`Pair[0]` and `Pair[1]` targets select them explicitly. Their code blocks are not attached by textual
adjacency. The separator `\s*=\s*` belongs in the first declared slot because that slot consumes it.

### Recursion and termination (consume before you recurse)

Recursion is just an edge or a `call(...)` that re-enters a rule. The one requirement is
**forward progress**: every recursive cycle must consume input before it recurses. A rule
that re-enters itself at the **same input position**
without consuming anything is a non-progressing cycle; the engine **cuts** such a
re-entry (it yields `undef`) so the parser terminates instead of hanging. Idiomatic
recursion consumes first — for example a parenthesis rule matches `(`, recurses, then
matches `)` — and is never affected by the cut.

When a recursive rule is dispatched from the top entry rule, the top rule still needs
an `LX` block to surface its accumulator when the input is exhausted:

```text
top::
 -> sexpr .push
LX { return(copy(top)) }

sexpr: /\(/ /\)/  I { items = [] }
 -> sexpr     { push(items, call(sexpr)) }
 -> atom      { push(items, call(atom)) }
 -> sexpr[1]  { return(copy(items)) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
```

With the top-rule `LX`, input `(a(b)c)` returns `[["a",["b"],"c"]]` and `(a) (b)` returns
`[["a"],["b"]]` — the top rule accumulates the **sequence** of top-level forms. Without
the `LX`, the same top wrapper returns `null` (a bare accumulating top rule returns
`undef` at end of input); the `null` is the missing-`LX` authoring case, not an engine
fault.

## Minimal example

```text
Top::
 -> Word .push

LX { return(copy(Top)) }

Word:
 /foo/ I {
   return(hash("kind", "word", "text", entry_text()))
 }
```

This file contains two rule paragraphs:

- `Top::`
- `Word:`

`Top` is written with the double-colon form because it is the entry rule in this
example. `Word` is written with the single-colon form because it is a normal matcher
rule.

The body of `Top` contains:

- one dispatch edge: `-> Word .push`
- one `LX` lifecycle block that returns the entry rule accumulator

The body of `Word` contains:

- one regex anchor: `/foo/`
- one `I { ... }` lifecycle block that reads the entering match with `entry_text()`

The action returns a structured helper-built payload rather than depending on the older compact `return_a(...)` helper style.

## Why it matters

This paragraph-oriented model helps explain why LinkedSpec is comfortable with:

- mixed regex and action content inside a rule paragraph
- lifecycle/code blocks
- recursive rule dispatch
- same-line and multiline authoring styles

It also explains why top-level validation matters so much: the parser has to know when a new rule really starts and when a label-like line is still just content inside an open block.

## Top-level rule starts versus block content

Rule starts are top-level constructs. Inside an open block, colon-bearing text must still
be valid helper DSL; it is not parsed as a new top-level rule.

```text
Top::
 -> Item .push
 -> Next .push

LX { return(copy(Top)) }

Item:
 /a/ I {
   return(hash(
     "kind", "top",
     "label:", "inside block"
   ))
 }

Next:
 /b/ I {
   return(hash("kind", "next", "text", entry_text()))
 }
```

Here `"label:"` is a quoted helper value inside the `Item` lifecycle block. It is not
a rule start because rule starts are only recognized at paragraph top level.

A bare `label:` line inside the same open `{ ... }` block would not become a rule, but
it also would not be valid helper DSL. The compiler rejects that form with a "Rule
definition not allowed inside open block" validation error and asks you to close the
preceding block before starting the next rule. Both rules above use the same helper-DSL
payload form (`return(hash(...))`), so nothing in this example is backend-specific.

This matters because LinkedSpec allows rule bodies to carry real action and lifecycle
blocks. If the frontend treated every colon-bearing helper value as a rule start, it
would misread valid block content.

## What can appear inside a rule paragraph

A rule paragraph can include supported paragraph members such as:

- regex tokens such as `/.../`
- action edges such as `-> Child`
- blind-call edges such as `=> Child`
- mode-sensitive bare rule references such as `Child`, `Child { ... }`, or
  `Child.return(...)`: AND-family paragraphs normalize them as blind calls,
  while OR/default-family paragraphs normalize them as action edges
- action blocks such as `{ ... }`
- lifecycle blocks such as `I { ... }`, `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, and `LX { ... }`
- split/capture markers such as `@capture_slice` and `@mark(name)`
- method-like helper forms that lower through ActionIR

The exact set of supported forms is intentionally validated. Stray top-level text is not “mostly okay.” It should be rejected clearly so users do not accidentally depend on token loss or partial parsing.

A bare reference is recognized only as the first member of a physical body line or as the first member in a rule
header's body rest. This keeps `Child.return(...)` convenient without reinterpreting arbitrary same-line suffixes
after another paragraph member. All rule labels are collected before bare targets are validated, so forward
references work. Lifecycle names keep lexical priority: write an explicit `-> I` or `=> I` when a rule is actually
named `I`. Grouped and indexed bare forms still obey the ownership rules described in
[Rule Modes and Cursor Policy](rule-modes-and-parse-modes.md#current-cursor-policies).

## Same-line and multiline styles

LinkedSpec supports compact same-line authoring:

```text
Top:: -> Word .push
LX { return(copy(Top)) }
Word: /foo/ I { return(hash("kind", "word", "text", entry_text())) }
```

It also supports the clearer multiline style:

```text
Top::
 -> Word .push

LX { return(copy(Top)) }

Word:
 /foo/
 I {
   return(hash("kind", "word", "text", entry_text()))
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
- Read the rule-modes and cursor-policy chapter next for execution behavior.
- Read [Action and Lifecycle Placement](../dsl/action-and-lifecycle-placement.md) when you need to know where action edges and lifecycle blocks run.
- Use the repo `USER_GUIDE.md` when you want the denser working reference while this book is still growing.
