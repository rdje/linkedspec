# Action and Lifecycle Placement

This chapter explains where action blocks and lifecycle blocks sit in a LinkedSpec rule.

Read [Declaration Helper Reference](declaration-helper-reference.md) first if you mainly need to know where to put working state. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) when you need the helper expressions that run inside these blocks.

The short version:

- `I { ... }` is the normal rule-entry setup location.
- `-> Rule[index] { ... }` is the normal action attached to a matched local slot.
- `LS { ... }` and `LE { ... }` are advanced local-slot hooks around local-match/action processing in regex-driven handler shapes.
- `LX { ... }` is the local no-match/failure path hook.
- `IT { ... }`, `EX { ... }`, and `E { ... }` are advanced iteration/finalization hooks for collection-shaped handlers.

Use the simple forms first. Reach for the advanced lifecycle hooks only when the rule really needs placement-specific behavior.

## Rule paragraph members

A rule paragraph can contain several kinds of members:

| Member | Example | Meaning |
| --- | --- | --- |
| Regex slot | `/[A-Za-z_]+/` | match one local token or anchor. |
| Action edge | `-> Token[0] { ... }` | run action code for a matched local slot. |
| Helper chain action edge | `-> Token[0] .return(hash(...))` | compact method-chain form of an action edge. |
| Empty action edge | `-> Token` | dispatch to the target rule with default call behavior. |
| Blind-call edge | `=> Child` / `=> Child { ... }` | call another rule as part of the rule body without tying the body to one regex slot action. |
| Lifecycle block | `I { ... }` | run placement-specific setup or hook code. |
| Split/mark marker | `@capture_slice` / `@mark(body_start)` | emit a placement-specific source-boundary update. |

Example:

```text
Token::AND
 I {
   declare(hash, meta=hash("kind", "token"));
   declare(scalar, text);
 }
 /[A-Za-z_]+/
 -> Token[0] {
   assign(scalar(text), lowercase(trim(entry_text())));
   assign(hash(meta), set_key(hash(meta), "text", scalar(text)));
   return(hash_copy(hash(meta)));
 }
```

The structure is:

- the rule starts at `Token::AND`
- `I { ... }` declares rule-owned working state
- `/[A-Za-z_]+/` is local regex slot `0`
- `-> Token[0] { ... }` runs when slot `0` is the current local match

## `I { ... }`: rule-entry setup

Use `I { ... }` for state that belongs to one invocation of the rule.

Typical uses:

- declare accumulators
- declare a child-result scalar such as `retv`
- initialize metadata that all return paths should share
- start a capture slice when the rule should begin with a known boundary

Example:

```text
List::AND
 I {
   declare(array, items);
   declare(scalar, retv);
   declare(hash, meta=hash("kind", "list"));
 }
 Item
 Item
 -> List[0] {
   assign(scalar(retv), call(Item));
   push_value(array(items), scalar(retv));
 }
 -> List[1] {
   assign(scalar(retv), call(Item));
   push_value(array(items), scalar(retv));
   return(set_key(hash(meta), "items", array_copy(array(items))));
 }
```

`I { ... }` is usually the right place for declarations because it runs before later action-edge logic needs those variables.

## Action edges: `-> Rule[index] { ... }`

Action edges attach code to one local match slot.

Example:

```text
Name::AND
 /name/
 /\s*=/
 /[A-Za-z_]+/
 -> Name[2] {
   return(hash("kind", "name", "value", entry_text()));
 }
```

Here `Name[2]` refers to the third local regex slot in the rule. Slot numbering is zero-based.

Use an action edge when:

- the rule should transform the current match into a value
- the action needs `entry_text()`, `entry_group(...)`, `match_text()`, or source-location helpers
- the action should call another rule and store the returned value
- the action should return the final payload for the rule

Action bodies should use helper statements:

```text
assign(scalar(name), entry_text());
push_value(array(items), scalar(retv));
return(hash("kind", "name", "value", scalar(name)));
```

Prefer those forms over raw Perl assignment, push, and return statements in new examples.

## Method-chain action edges

Short helper-only action edges can be written as method chains.

Example:

```text
/[A-Za-z_]+/ -> Name[0]
  .declare(scalar, text)
  .assign(scalar(text), lowercase(trim(entry_text())))
  .return(hash("kind", "name", "text", scalar(text)));
```

This lowers through the same helper surface as the block form:

```text
/[A-Za-z_]+/
-> Name[0] {
  declare(scalar, text);
  assign(scalar(text), lowercase(trim(entry_text())));
  return(hash("kind", "name", "text", scalar(text)));
}
```

Use chains when they stay short. Use blocks when the rule contains branching, multiple updates, or examples meant to teach the shape.

Action-edge continuations are also portable when they stay edge-scoped:

```text
-> Item .push
-> Item .push(items)
-> Item .if(s(on)).push(Item, items).else().return_undef().endif()
-> Item[1] .return(array("?items:", array_copy(array(Item))))
```

`-> Item .push` dispatches the matched child and appends the child rule return to the
current rule accumulator named after the current rule. `-> Item .push(items)` dispatches
the same child and appends the child return to the `items` accumulator. `.push(Item, items)`
is the explicit child-and-target form used inside fluent flow chains. `-> Item[1] .return(expr)`
returns `expr` for that action edge without separately dispatching the close-edge child.

Action edges can also use receiver-fluent attached `when/otherwise` blocks when a short conditional payload is
clearer than a full structured block:

```text
-> Item.when(is_defined(scalar(retv))) {
  return(scalar(retv))
}.otherwise {
  return("missing")
}
```

The no-dot fallback tail is equivalent:

```text
-> Item.when(is_defined(scalar(retv))) {
  return(scalar(retv))
} otherwise {
  return("missing")
}
```

Lifecycle markers accept the same branch shape, for example `I.when(cond) { ... }.otherwise { ... }`.
They also accept compact receiver chains for short ordered lifecycle statement lists:

```text
token : /[A-Za-z_]\w*/
 I.declare(scalar, text)
  .set(text, lowercase(entry_text()))
  .return(hash("kind", "token", "text", scalar(text)))
```

That form is equivalent to `I { declare(...); set(...); return(...) }`: each method in the
chain executes as a lifecycle statement for the receiver marker.

## Empty action edges

An empty action edge is a compact call shape:

```text
-> Child
```

It means the rule includes the child dispatch without writing an explicit action body. This is useful when the default behavior is enough.

When the parent needs to inspect or reshape the child result, use the explicit helper form instead:

```text
-> Parent[0] {
  declare(scalar, retv);
  assign(scalar(retv), call(Child));
  return(hash("kind", "parent", "child", scalar(retv)));
}
```

The explicit form is better for public examples because it shows where the child result goes and how the return payload is shaped.

## Grouped action-edge targets

One action block can be **shared across several target rules** by joining the targets with `|`:

```text
-> RuleA | RuleB { ... }
```

The shared block is bound to every listed target, so the same action runs for whichever target the dispatch resolves to. Use this when two (or more) alternative child rules should be handled identically and duplicating the block would be the only other option.

Grouped action-edge targets require that shared `{ ... }` block. The block-less form `-> RuleA | RuleB` is invalid; use separate edges when there is no shared action to factor.

A shipped example is `ebnf.spec`, whose `semantic_annotation` rule shares one action across two targets:

```text
semantic_annotation: /@(\w+)\s*:\s*/
-> semantic_annotation | grammar_rule {
  BACKTRACK();
  declare(scalar, c=capture_slice());
  substr(s(c), "\s*$", "", o);
  substr(s(c), "^\"|\"$", "", go);
  return(a("semantic_annotation", a(entry_group(0), s(c))));
}
```

Here the identical cleanup-and-return code applies whether the dispatch lands on
`semantic_annotation` or `grammar_rule` — the targets are alternatives, and the block sees
whichever one matched. Use grouped targets when:

- two or more alternative child rules need the **identical** action, and
- duplicating the block would otherwise be the only way to express it.

The grouped-target form is defined in the
[Formal `.spec` Grammar §3.2](../appendix/formal-grammar.md).

## Blind-call edges

Blind-call edges use `=>`:

```text
=> Child
```

They are often used in ordered wrapper rules:

```text
Wrapper::AND
 I { declare(scalar, retv); }
 => Header
 => Body
 => Trailer
 LX { return(scalar(retv)); }
```

Use this family when the rule needs a child-rule call as part of the body rather than one local regex-slot action.

The full parser-orchestration model for `=>`, including rule-label semantics and post-call processing, is documented in [Blind Calls and Parser Orchestration](../user-model/blind-calls-and-parser-orchestration.md).

In new public examples, prefer the more explicit child-result pattern unless the rule is specifically teaching blind-call behavior:

```text
assign(scalar(retv), call(Child));
push_value(array(children), scalar(retv));
```

That pattern makes the dataflow visible.

## Local match variables inside action placement

Action and local lifecycle code can read match-local context through helper methods.

Prefer:

```text
entry_text()
entry_group(0)
entry_groups()
entry_line()
entry_col()
match_text()
match_group(0)
match_line()
match_col()
```

over raw variables such as `LMATCH`, `IMATCH`, or manual capture-list indexing in new public examples.

Use `entry_*` helpers when the action wants the immediate match that led into the action or rule. Use `match_*` helpers when the action is explicitly about the current local match being processed. The [Source Boundary Helper Reference](source-boundary-helper-reference.md) documents the exact `entry_*` and `match_*` families.

## `LS { ... }` and `LE { ... }`: local-slot hooks

`LS { ... }` and `LE { ... }` are advanced hooks around local slot processing in regex-driven handler shapes.

Practical model:

```text
local match found
LS { ... }
matching action edge runs
LE { ... }
continue matching
```

Use `LS { ... }` when code must run after the local match is known but before the action body for that slot.

Use `LE { ... }` when code must run after local action processing for a slot and before the handler continues.

Important caveat: if an action body returns from the rule, later hook code in that same generated path does not get a chance to run. Do not rely on `LE { ... }` for cleanup that must happen after a `return(...)` action.

Example:

```text
Delimited::AND
 I { declare(scalar, body); }
 /\{/
 @mark(body_start)
 /[^}]*/
 /\}/
 -> Delimited[2] {
   assign(scalar(body), capture_from(body_start));
   return(hash("kind", "delimited", "body", scalar(body)));
 }
```

The `@mark(body_start)` marker is implemented as a later local-end placement update. That means an action on the same slot should not expect the newly written mark yet. Read it from a later slot.

## Lifecycle blocks are statement blocks

Lifecycle blocks execute statements for their side effects and return-channel writes. They do
not yield the value of their final statement as an implicit block result.

```text
Top::
 I {
   set(out, "from_i");
   set(ignored, "not_a_return");
 }
 /x/
 E {
   return(hash("out", scalar(out), "ignored", scalar(ignored)));
 }
```

The final `set(ignored, ...)` statement mutates `ignored`, but the rule returns only because the
later `E { return(...) }` block writes the return channel. A top-level lifecycle `return(expr)` is
different from `return(expr)` inside an expression-valued block: the lifecycle form writes the
surrounding rule/action return channel, while the expression-valued block form yields only that
local block's value.

## `LX { ... }`: local no-match/failure path

`LX { ... }` is the local no-match or local failure hook for handler paths that otherwise default to `return undef`.

Example:

```text
MaybeName::OR
 I { declare(hash, meta=hash("kind", "maybe_name")); }
 LX {
   return(hash("kind", "missing_name"));
 }
 /[A-Za-z_]+/
 -> MaybeName[0] {
   return(set_key(hash(meta), "name", entry_text()));
 }
```

Use `LX { ... }` only when a rule should deliberately shape its local failure value. If the rule should simply fail to match, omit `LX { ... }` and let the default failure path return `undef`.

This is an advanced hook. A surprising `LX { ... }` can make a parser look successful when the intended behavior was failure. Document the intent when you use it.

## `IT { ... }`, `EX { ... }`, and `E { ... }`: iteration and finalization hooks

These lifecycle hooks are for collection-shaped or rule-finalization behavior. Their exact placement depends on the generated handler variant selected for the rule mode and rule body shape.

Practical model:

| Hook | Practical meaning | Common use |
| --- | --- | --- |
| `IT { ... }` | iteration item hook | customize what happens after one repeated item is accepted. |
| `EX { ... }` | repetition exit hook | customize what happens when a repetition stops after satisfying its minimum. |
| `E { ... }` | rule end/finalization hook | customize the final value for a completed handler path. |

Example:

```text
Items:*
 I {
   declare(array, items);
   declare(scalar, item);
 }
 /[A-Za-z_]+/
 -> Items[0] {
   assign(scalar(item), entry_text());
 }
 IT {
   push_value(array(items), scalar(item));
 }
 E {
   return(hash("kind", "items", "items", array_copy(array(items))));
 }
```

Use these hooks when the default collection behavior is not the shape you want. Otherwise prefer explicit action-edge returns or normal accumulator logic in action blocks because they are easier for readers to follow.

## Split and mark markers are placement-sensitive

Marker forms such as:

```text
@capture_slice
@mark(body_start)
```

are not ordinary return-value helpers. They are placement-sensitive rule members.

`@capture_slice` moves the anonymous capture boundary at that rule slot. `@mark(name)` stores a named checkpoint for later same-rule reads.

Example:

```text
Tuple::AND
 I { declare(array, parts); }
 /\(/
 @capture_slice
 /[^,]*/
 /,/
 /[^)]*/
 /\)/
 -> Tuple[2] {
   push_value(array(parts), capture_take());
 }
 -> Tuple[4] {
   push_value(array(parts), capture_slice());
   return(hash("kind", "tuple", "parts", array_copy(array(parts))));
 }
```

Use the helper-call form such as `start_capture_slice()` when the boundary move belongs inside an action or lifecycle block. Use the marker form when the grammar slot itself is the boundary.

## Choosing the right placement

Use this as the default decision guide:

| Goal | Prefer |
| --- | --- |
| Declare state shared by the rule | `I { declare(...) }` |
| Initialize metadata shared by return paths | `I { declare(hash, meta=hash(...)) }` |
| Transform one matched token | `-> Rule[index] { ... }` |
| Capture and reshape one child result | `assign(scalar(retv), call(Child))` inside an action body |
| Append repeated child results | `push_value(array(items), scalar(retv))` inside action/iteration logic |
| Mark a grammar boundary | `@mark(name)` or `@capture_slice` at the grammar slot |
| Move a boundary from code | `mark_here(name)` or `start_capture_slice()` inside a block |
| Return a shaped optional fallback | `LX { return(...) }`, used sparingly |
| Customize repetition collection | `IT { ... }`, `EX { ... }`, or `E { ... }`, used only when default behavior is not enough |

## Worked example: source span with a named mark

```text
Block::AND
 I {
   declare(hash, meta=hash("kind", "block"));
   declare(scalar, body);
 }
 /\{/
 @mark(body_start)
 /[^}]*/
 /\}/
 -> Block[2] {
   assign(scalar(body), capture_from(body_start));
   assign(hash(meta), set_key(hash(meta), "body", scalar(body)));
   assign(hash(meta), set_key(hash(meta), "body_start_line", mark_line(body_start)));
   return(hash_copy(hash(meta)));
 }
```

The placement logic is:

- `I { ... }` creates state for this rule invocation.
- The opening brace slot establishes the named mark for later use.
- The closing brace action reads from the earlier mark to the current local-match edge.
- The returned payload is shaped with value and source-location helpers.

## Worked example: explicit child-result dataflow

```text
Pair::AND
 I {
   declare(scalar, lhs);
   declare(scalar, rhs);
   declare(scalar, retv);
 }
 Name
 /\s*=\s*/
 Value
 -> Pair[0] {
   assign(scalar(retv), call(Name));
   assign(scalar(lhs), scalar(retv));
 }
 -> Pair[2] {
   assign(scalar(retv), call(Value));
   assign(scalar(rhs), scalar(retv));
   return(hash("kind", "pair", "lhs", scalar(lhs), "rhs", scalar(rhs)));
 }
```

The explicit `retv` assignments make the child-result flow visible. That is usually better than hiding the same logic behind empty edges when the parent rule needs to reshape the result.

## Practical guidance

- Put shared state in `I { ... }`.
- Put token-specific transformation in `-> Rule[index] { ... }`.
- Prefer helper statements inside action bodies; avoid raw Perl in new examples.
- Use method chains only when the action stays compact and readable.
- Treat `LS`, `LE`, `LX`, `IT`, `EX`, and `E` as advanced placement hooks, not as the normal way to write every rule.
- Use marker forms such as `@mark(name)` only when the grammar slot is the boundary; use helper-call forms inside blocks.
- Keep lifecycle examples explicit about why the hook is needed, because placement hooks can make parse behavior harder to infer if used casually.

## Deeper reference

For the full lifecycle-block contract catalog with emitted-Perl examples, see `USER_GUIDE_ActionIR_Contracts.md` and `USER_GUIDE_ActionIR_EmittedPerlReference.md` in the repo root. These are the exhaustive working references while the book continues growing.
