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

## Why it matters

This paragraph-oriented model helps explain why LinkedSpec is comfortable with:

- mixed regex and action content inside a rule paragraph
- lifecycle/code blocks
- recursive rule dispatch
- same-line and multiline authoring styles

It also explains why top-level validation matters so much: the parser has to know when a new rule really starts and when a label-like line is still just content inside an open block.

## Where to go next

- Read the rule-modes and parse-modes chapter next for execution behavior.
- Use the repo `USER_GUIDE.md` when you want the denser working reference while this book is still growing.
