# Blind Calls and Parser Orchestration

> **Perl reference shorthand:** ADR `0044` makes a complete bare child member
> in an AND-family rule shorthand for the `=>` forms taught here. In an
> OR/default-family rule the same bare member becomes a `->` action edge.
> Explicit `=>` remains legal in OR/default and explicit `->` remains legal in
> AND. Parent family never changes a child's intrinsic cursor policy. This syntax
> is fully admitted on Perl through `.9.1.3.6`. Rust `.9.1.4.2` now retains and
> validates the same bare forms as typed AST and lowers their family-derived
> ownership; Rust live rule-local execution, descriptor/generated artifacts,
> CLI removal, and later backends remain in `.9.1.4-.9`.

Blind calls are LinkedSpec's parser-orchestration edge family.

They use `=>`:

```text
=> ChildRule
```

Read that as "call `ChildRule` as the next parser step." This is different from an action edge:

```text
-> ChildRule
```

Read that as "the enclosing rule owns action-edge selection, and this edge selects the regex slot declared by `ChildRule` (slot zero when unindexed)."

The distinction matters because `=>` changes who owns the next match. With `->`, the enclosing rule selects a regex slot identified by the action edge's target rule and index. With `=>`, the child parser owns the matching step and the parent acts as the composition shell.

## Why blind calls exist

Blind calls are useful when a parent rule is mostly about composition:

- wrapper rules that present a clearer public entry point over several child rules,
- ordered orchestration where several child parsers must run in sequence,
- choice wrappers where several child parsers should be tried as alternatives,
- repeated child-parser streams,
- staged extraction where an outer parser coordinates child parsers that own the real local anchors.

They are not a replacement for ordinary action edges. If the parent rule needs to inspect a local regex match with `entry_text()`, `entry_group(...)`, source-location helpers, or a slot-specific action, an ordinary `-> Rule[index] { ... }` action edge is usually the right tool.

Historical “super split” is not a blind-call use case. It is automatic inter-match gap capture in a
repeated OR/default action rule whose `-> Rule[index]` edges select regex slots owned by their target
rules. See [Capture, Marks, and Source Locations](../dsl/capture-marks-and-source-locations.md).

## Supported surface

The current blind-call surface supports these forms:

```text
=> Child
=> Child { ... }
=> Child.method(...)
=> Child .method(...).method2(...)
```

The target must be a plain rule name. These forms are intentionally invalid:

```text
=> { ... }
=> Child-extra
=> Child[0]
=> Child.
=> Child..return(...)
```

The invalid cases fail for different reasons:

- `=> { ... }` has no target rule.
- `=> Child-extra` glues punctuation onto the target name.
- `=> Child[0]` tries to apply regex-slot indexing to a parser-step edge.
- `=> Child.` and `=> Child..return(...)` start malformed fluent suffixes.

Slot indexing belongs to regex/action edges:

```text
Name: /[A-Za-z_]+/

Top::
 -> Name[0] { return(call(Name)) }
```

Here `Name` owns the regex slot and its lifecycle; `Top` owns action selection. Slot indexing does not
belong to blind calls, because the child parser owns the next matching step.

## Rule labels still decide composition

`=> Child` only says that the parent calls a child parser. The parent rule label still decides whether those child calls behave as sequence, choice, repeated choice, or repeated sequence.

This is the central blind-call rule:

- `Record::AND` with blind calls is ordered orchestration.
- `Atom::|` with blind calls is wrapper choice.
- `Stream::OR` with blind calls is repeated choice.
- `ChunkStream::AND+` with blind calls is repeated ordered sequence.
- Bare `Rule:` or `Rule::` with blind calls stays in the historical repeated-choice baseline family, not implicit `AND`.

Do not infer sequence semantics from the presence of `=>`. If you want sequence, write `:&`, `:AND`, `:AND+`, or `:AND{...}` explicitly.

## Ordered wrapper rules

Use `:AND` or `:&` when the parent exists to call child parsers in order.

```text
Document::AND
 => Header
 => Body
 => Trailer

Header:
 /HEADER:[^\n]*/ -> Header {
   return(hash("kind", "header", "text", entry_text()));
 }

Body:
 /BODY:[^\n]*/ -> Body {
   return(hash("kind", "body", "text", entry_text()));
 }

Trailer:
 /TRAILER:[^\n]*/ -> Trailer {
   return(hash("kind", "trailer", "text", entry_text()));
 }
```

Practical reading:

- `Document` calls `Header` first.
- If `Header` succeeds, `Document` calls `Body`.
- If `Body` succeeds, `Document` calls `Trailer`.
- If any required child step fails, the ordered wrapper fails.
- The parent result follows the ordered child-result shape unless post-call logic reshapes it.

The compact sigil form is equivalent in intent:

```text
Document::&
 => Header
 => Body
 => Trailer
```

Use `:AND` in public examples and new complex specs when the worded spelling makes intent clearer. Use `:&` when local style already makes the sigil obvious.

## Single-choice wrappers

Use `:|` when the parent should try child parsers as alternatives.

```text
Atom::|
 => QuotedString
 => IntegerLiteral
 => Identifier

QuotedString:
 /"(?:[^"\\]|\\.)*"/ -> QuotedString {
   return(hash("kind", "quoted_string", "text", entry_text()));
 }

IntegerLiteral:
 /\d+/ -> IntegerLiteral {
   return(hash("kind", "integer", "text", entry_text()));
 }

Identifier:
 /[A-Za-z_]\w*/ -> Identifier {
   return(hash("kind", "identifier", "text", entry_text()));
 }
```

Practical reading:

- Try `QuotedString`.
- If it fails, try `IntegerLiteral`.
- If it fails, try `Identifier`.
- Return the successful child parser's result.
- If no child parser succeeds, the wrapper fails.

Use this shape when the child rules already know how to parse themselves and the parent only exists to name the choice set.

## Repeated-choice wrappers

Use `:OR`, `:OR+`, `:+`, or `:OR{...}` when each iteration should pick one successful child parser and then repeat.

```text
LineStream::OR
 => HeaderLine
 => BodyLine
 => BlankLine

HeaderLine:
 /H:[^\n]*(?:\n|$)/ -> HeaderLine {
   return(hash("kind", "header_line", "text", entry_text()));
 }

BodyLine:
 /B:[^\n]*(?:\n|$)/ -> BodyLine {
   return(hash("kind", "body_line", "text", entry_text()));
 }

BlankLine:
 /\s*(?:\n|$)/ -> BlankLine {
   return(hash("kind", "blank_line", "text", entry_text()));
 }
```

Practical reading:

- On the first iteration, try `HeaderLine`, then `BodyLine`, then `BlankLine`.
- Keep the first child that succeeds for that iteration.
- Repeat the same child-choice process for the next iteration.
- Stop when no child parser succeeds or when the label's upper bound is reached.
- Require at least one successful iteration for `:OR`, `:OR+`, and `:+`.

The historical bare-label form is also repeated-choice oriented:

```text
LineStream::
 => HeaderLine
 => BodyLine
 => BlankLine
```

Prefer the explicit `:OR` or `:OR+` spelling in new teaching material because it makes the repeated-choice contract visible at the label.

Bounded repeated choice works the same way, but the label also counts successful iterations:

```text
TwoOrThreeLines::OR{2,3}
 => HeaderLine
 => BodyLine
 => BlankLine
```

This requires at least two successful child-choice iterations and stops after at most three.

Zero-lower-bound forms are valid when zero child hits are meaningful:

```text
OptionalPrefixes::OR{,2}
 => PlusPrefix
 => MinusPrefix
```

This allows zero, one, or two successful child-choice iterations. Use this shape carefully inside repeated parents because an empty success is still a real success. LinkedSpec guards against zero-progress loops, but the grammar should still make the empty case intentional and documented.

## Repeated ordered wrappers

Use `:AND+` or `:AND{...}` when the whole child-call sequence should repeat as a group.

```text
SectionStream::AND+
 => SectionHeader
 => SectionBody

SectionHeader:
 /section\s+[A-Za-z_]\w*\s*\n/ -> SectionHeader {
   return(hash("kind", "section_header", "text", entry_text()));
 }

SectionBody:
 /(?:[^\n]+\n)+/ -> SectionBody {
   return(hash("kind", "section_body", "text", entry_text()));
 }
```

Practical reading:

- One iteration is `SectionHeader`, then `SectionBody`.
- The next iteration starts again at `SectionHeader`.
- `:AND+` requires at least one complete section group.

Use bounded `AND` forms when the number of complete child-call groups matters:

```text
TwoToFourSections::AND{2,4}
 => SectionHeader
 => SectionBody
```

This requires at least two complete `SectionHeader` plus `SectionBody` groups and stops after four.

The important distinction from repeated choice is that `AND{2,4}` counts complete ordered groups. It does not choose one child per iteration.

## Post-call processing

A blind call can include post-call code:

```text
Wrapper::AND
 => Child { return(array("?Wrapper:", copy(Wrapper))) }

Child:
 /child/ -> Child { return(array("?Child:", copy(Child))) }
```

The lowering model is:

```text
call Child
store the child result as the current blind-call entry
run the attached post-call block
```

Fluent post-call chains are compact sugar over the same idea:

```text
Wrapper::AND
 => Child .return(array("?Wrapper:", copy(Wrapper)))

Child:
 /child/ -> Child { return(array("?Child:", copy(Child))) }
```

The fluent example above is equivalent in lowered meaning to the explicit block form:

```text
Wrapper::AND
 => Child { return(array("?Wrapper:", copy(Wrapper))) }
```

Use fluent post-call chains only when they remain short and obvious. Use an explicit block when the post-call logic needs more than one or two steps.

The examples above use explicit `return(array(...))` payloads because the returned shape is visible at the call site. For more complex shaping, prefer helper-style action blocks or explicit child-result dataflow:

```text
ChildAnchor: /child-anchor/

Parent:AND
 I {
   retv = undef;
   children = [];
 }
 -> ChildAnchor {
   retv = call(Child);
   push(children, retv);
   return(hash("kind", "parent", "children", copy(children)));
 }
```

That ordinary action-edge pattern is not a blind call; it is often clearer when the parent needs to reshape child data in a very specific way.

## Do not mix `->` and `=>` in one rule

One rule body should use one edge family.

This is invalid:

```text
Header: /header/
Body: /body/

BadRule:AND
 -> Header
 => Body
```

The reason is semantic, not cosmetic. `-> Header` says the enclosing rule selects the regex slot
declared by `Header` through its action-edge matcher. `=> Body` says the enclosing rule directly
invokes `Body` as a parser step. Mixing both in one rule makes execution ownership unclear:

- which matcher owns input progress,
- which result shape should the parent return,
- whether repeated grouping applies to target-slot selection or child parser calls,
- whether failure should be interpreted as local regex failure or child parser failure.

Split the rule instead.

If the enclosing rule selects target regex slots, keep it action-edge oriented:

```text
Header: /header/
 I { return(hash("kind", "header", "text", entry_text())) }

HeaderRule:AND
 -> Header {
   return(call(Header));
 }
```

If the parent orchestrates child parsers, keep it blind-call oriented:

```text
Record::AND
 => Header
 => Body
 => Trailer
```

## Paragraph placement and formatting

Blind-call members can appear with normal lifecycle members such as `I { ... }` and `LX { ... }`:

```text
Record::AND
 I { retv = undef; }
 => Header
 => Body
 => Trailer
 LX { return(retv); }
```

Same-line packing is also supported:

```text
Record::AND I { retv = undef; } => Header => Body => Trailer LX { return(retv); }
```

Prefer the multiline form in public documentation and new specs. It makes the parser-step order visible and leaves room to explain why each child rule exists.

## Choosing `=>` versus `call(Child)`

Use a blind call when the parent rule's body is mostly made of child parser steps:

```text
Record::AND
 => Header
 => Body
 => Trailer
```

Use `call(Child)` inside an action edge when the parent has its own local regex slots and needs an explicit child result for helper logic:

```text
Field:AND
 I { retv = undef; }
 /field\s+/ -> Field[0] {
   retv = call(Name);
   return(hash("kind", "field", "name", retv));
 }

Name:
 /[A-Za-z_]\w*/ -> Name {
   return(entry_text());
 }
```

The first shape is parser orchestration. The second shape is local regex-driven action logic that happens to call a child parser as part of its action.

Both are useful. The best authoring choice is not "always blind call"; it is choosing the edge family that makes ownership and result flow obvious.

## Practical checklist

Use blind calls when:

- the parent is a wrapper or composition shell,
- child rules own their own anchors and local parsing,
- the parent body is naturally described as child parser steps,
- the composition mode is visible in the parent label.

Avoid blind calls when:

- the parent needs slot-specific local match helpers,
- the parent and child matching responsibilities are mixed,
- one rule would need both `->` and `=>`,
- the return payload needs complex reshaping that is clearer as explicit `retv = call(Child)` dataflow.

When you do use blind calls:

- say `:AND` or `:&` for ordered orchestration,
- say `:|` for one wrapper choice,
- say `:OR`, `:OR+`, `:+`, or `:OR{...}` for repeated child-choice streams,
- say `:AND+` or `:AND{...}` for repeated ordered child-call groups,
- keep targets as plain rule names,
- prefer multiline formatting for readability,
- use post-call chains sparingly and blocks when the logic becomes substantial.
