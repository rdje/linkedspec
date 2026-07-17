# Action and Lifecycle Placement

> **Perl reference edge default:** ADR `0044` keeps the explicit `->` and `=>`
> meanings documented in this chapter and adds mode-sensitive bare rule-edge
> lines during `.9.1.2-.9`: a bare child member resolves to blind-call ownership
> in AND-family rules and action-edge ownership in OR/default-family rules.
> Explicit cross-family markers remain legal; resolved ownership still cannot
> be mixed. Perl `.9.1.3.1` implements this line-level normalization before
> handler emission; other backends remain in the dependency-ordered rollout.

This chapter explains where action blocks and lifecycle blocks sit in a LinkedSpec rule.

Read [Declaration Helper Reference](declaration-helper-reference.md) first if you mainly need to know where to put working state. Read [Value, Container, and Flow Helper Reference](value-container-flow-helper-reference.md) when you need the helper expressions that run inside these blocks.

The short version:

- `I { ... }` is the normal rule-entry setup location.
- `-> Rule[index] { ... }` is the normal action attached to a matched local slot.
- `LS { ... }` and `LE { ... }` are advanced local-slot hooks around local-match/action processing in regex-driven handler shapes.
- `LX { ... }` is the local no-match/failure path hook.
- `IT { ... }`, `EX { ... }`, and `E { ... }` are advanced iteration/finalization hooks for collection-shaped handlers.

Use the simple forms first. Reach for the advanced lifecycle hooks only when the rule really needs placement-specific behavior.

Unless an example includes a `Top::` wrapper, treat it as a rule-paragraph fragment. Complete public examples should use the two-rule shape: a no-regex `::` entry rule dispatches to one or more normal `:` rules that own the regexes. In a dispatched normal rule, `I { ... }` sees the entry match, while `-> Rule[index] { ... }` actions run for later local slots in that rule.

Action-edge identity comes from the written target, never adjacency. `-> Document[2]` selects regex
slot 2 declared by `Document`, even when the enclosing rule is `Top`; a regex line immediately before
the edge does not trigger its block. Compact same-rule examples below place declarations and edges in
one paragraph, but their edges still resolve by explicit rule name and zero-based slot index.

## Rule paragraph members

A rule paragraph can contain several kinds of members:

| Member | Example | Meaning |
| --- | --- | --- |
| Regex slot | `/[A-Za-z_]+/` | match one local token or anchor. |
| Action edge | `-> Token[0] { ... }` | run action code for a matched local slot. |
| Helper chain action edge | `-> Token[0] .return(hash(...))` | compact method-chain form of a local-slot action edge. |
| Empty action edge | `-> Token` | dispatch to the target rule with default call behavior. |
| Blind-call edge | `=> Child` / `=> Child { ... }` | call another rule as part of the rule body without tying the body to one regex slot action. |
| Lifecycle block | `I { ... }` | run placement-specific setup or hook code. |
| Split/mark marker | `@capture_slice` / `@mark(body_start)` | request a backend-specific compatibility update; see the scope caveat below. |

Example:

```text
Name:AND /name/ /\s*=/ /[A-Za-z_]+/
 -> Name[1] {
   eq = match_text();
 }
 -> Name[2] {
   return(hash("kind", "name", "entry", entry_text(), "value", match_text()));
 }
```

The structure is:

- the rule starts at `Name:AND`
- `/name/` is the entry regex when a parent dispatches to `Name`
- `/\s*=/` and `/[A-Za-z_]+/` are later local slots
- `-> Name[1] { ... }` and `-> Name[2] { ... }` run when those local slots are the current match

## `I { ... }`: rule-entry setup

Use `I { ... }` for state that belongs to one invocation of the rule.

Typical uses:

- initialize accumulators
- initialize a child-result scalar such as `retv`
- initialize metadata that all return paths should share
- start a capture slice when the rule should begin with a known boundary

Example:

```text
Token: /[A-Za-z_]+/
 I {
   set(meta, { "kind" : "token" });
   text = lowercase(trim(entry_text()));
   return(set_key(meta, "text", text));
 }
```

`I { ... }` is usually the right place for initialization because it runs before later action-edge logic needs those variables. It is also the right place to transform the entry match of a dispatched child rule, because `entry_text()` and `entry_group(...)` are available there.

## Action edges: `-> Rule[index] { ... }`

Action edges attach code to one regex slot declared by their named target rule. The enclosing rule
owns selection/action orchestration; the target rule owns the regex and retains its lifecycle code.

Example:

```text
Name:AND /name/ /\s*=/ /[A-Za-z_]+/
 -> Name[1] {
   eq = match_text();
 }
 -> Name[2] {
   return(hash("kind", "name", "separator", eq, "value", match_text()));
 }
```

Here `Name[2]` refers to the third regex slot in the rule. Slot numbering is zero-based, and `match_text()` reads the current local slot. When the rule is reached through a parent `-> Name` dispatch, the first regex (`/name/`) is the entry match and is available through `entry_text()`.

Use an action edge when:

- the rule should transform the current match into a value
- the action needs `match_text()`, `match_group(...)`, or source-location helpers for the current local slot
- the action should call another rule and store the returned value
- the action should return the final payload for the rule

Action bodies should use helper statements:

```text
name = match_text();
push(items, retv);
return(hash("kind", "name", "value", name));
```

Prefer those forms over raw Perl assignment, push, and return statements in new examples.

## Method-chain action edges

Short helper-only action edges can be written as method chains.
Whitespace after `->` is optional; examples usually include a space for readability,
but compact forms such as `->Item.push` and `Top::->Item.push` are valid.

Example:

```text
/[A-Za-z_]+/ -> Name[0]
  .set(text, lowercase(trim(match_text())))
  .return(hash("kind", "name", "text", text));
```

This lowers through the same helper surface as the block form:

```text
/[A-Za-z_]+/
-> Name[0] {
  text = lowercase(trim(match_text()));
  return(hash("kind", "name", "text", text));
}
```

Use chains when they stay short. Use blocks when the rule contains branching, multiple updates, or examples meant to teach the shape.

Action-edge continuations are also portable when they stay edge-scoped:

```text
-> Item .push
-> Item .push(items)
-> Item .if(on).push(Item, items).else().return_undef().endif()
-> Item[1] .return(array("?items:", copy(Item)))
```

`-> Item .push` dispatches the matched child and appends the child rule return to the
current rule accumulator named after the current rule. `-> Item .push(items)` dispatches
the same child and appends the child return to the `items` accumulator. `.push(Item, items)`
is the explicit child-and-target form used inside fluent flow chains. `-> Item[1] .return(expr)`
returns `expr` for that action edge without separately dispatching the close-edge child.

Action edges can also use receiver-fluent attached `when/otherwise` blocks when a short conditional payload is
clearer than a full structured block:

```text
-> Item.when(is_defined(retv)) {
  return(retv)
}.otherwise {
  return("missing")
}
```

The no-dot fallback tail is equivalent:

```text
-> Item.when(is_defined(retv)) {
  return(retv)
} otherwise {
  return("missing")
}
```

Lifecycle markers accept the same branch shape, for example `I.when(cond) { ... }.otherwise { ... }`.
They also accept compact receiver chains for short ordered lifecycle statement lists:

```text
token : /[A-Za-z_]\w*/
 I.set(text, lowercase(entry_text()))
  .return(hash("kind", "token", "text", text))
```

That form is equivalent to `I { text = lowercase(entry_text()); return(...) }`: each method in the
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
  retv = call(Child);
  return(hash("kind", "parent", "child", retv));
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

A compact grouped-edge example is a lexer-like rule where two child tokens
return the same normalized payload:

```text
token::
-> quoted_string | bare_word {
  return(hash("kind", "token", "text", retv));
}
```

Here the identical cleanup-and-return code applies whether the dispatch lands on
`quoted_string` or `bare_word` - the targets are alternatives, and the block sees
whichever child result was produced. Use grouped targets when:

- two or more alternative child rules need the **identical** action, and
- duplicating the block would otherwise be the only way to express it.

The grouped-target form is defined in the
[Formal `.spec` Grammar §3.2](../appendix/formal-grammar.md).

## Blind-call edges

Blind-call edges use `=>`:

```text
=> Child
```

Whitespace after `=>` is optional; `=>Child` is the same edge written compactly.

They are often used in ordered wrapper rules:

```text
Wrapper::AND
 I { retv = undef; }
 => Header
 => Body
 => Trailer
 LX { return(retv); }
```

Use this family when the rule needs a child-rule call as part of the body rather than one local regex-slot action.

The full parser-orchestration model for `=>`, including rule-label semantics and post-call processing, is documented in [Blind Calls and Parser Orchestration](../user-model/blind-calls-and-parser-orchestration.md).

In new public examples, prefer the more explicit child-result pattern unless the rule is specifically teaching blind-call behavior:

```text
retv = call(Child);
push(children, retv);
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

Use `entry_*` helpers when code wants the match that entered the current rule, typically from `I { ... }` in a dispatched child. Use `match_*` helpers when an action is about the current local slot being processed. The [Source Boundary Helper Reference](source-boundary-helper-reference.md) documents the exact `entry_*` and `match_*` families.

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
Delimited:AND
 I {
   body = undef;
   body_text = undef;
 }
 /\{/
 /[^}]+/
 /\}/
 -> Delimited[0] {
   mark_here(body_start);
 }
 -> Delimited[1] {
   body_text = match_text();
 }
 -> Delimited[2] {
   body = capture_from(body_start);
   return(hash("kind", "delimited", "body", body));
 }
```

The opener action records the boundary after `{`, and the closing action reads
from that saved boundary to the current local-match edge. The middle action keeps
the body slot explicit in this consume-mode pattern. If you use the marker form
`@mark(body_start)`, read it from a later slot; an action on the same slot should
not expect the newly written mark yet.

## Lifecycle blocks are statement blocks

Lifecycle blocks should be written as statement blocks: use assignments and helper calls for side effects, and use `return(...)` when the rule or action should produce a value. Do not rely on the ordinary value of the final statement in a lifecycle block.

```text
Example: /x/
 I {
   set(out, "from_i");
   set(ignored, "not_a_return");
   return(hash("out", out, "ignored", ignored));
 }
```

The final `set(ignored, ...)` statement mutates `ignored`; the result is produced by the explicit
`return(...)`. A top-level lifecycle `return(expr)` is different from `return(expr)` inside an
expression-valued block: the lifecycle form writes the surrounding rule/action return channel,
while the expression-valued block form yields only that local block's value.

Portability note: current Perl reference handler shapes can expose a host-language final statement value when a lifecycle block omits an explicit return, and direct `E { ... }` finalization is handler-shape sensitive. Public examples should make lifecycle returns explicit and should not depend on final-statement leakage.

## `LX { ... }`: local no-match/failure path

`LX { ... }` is the local no-match or local failure hook for handler paths that otherwise default to `return undef`.

Example:

```text
MaybeName:OR
 I { set(meta, { "kind" : "maybe_name" }); }
 LX {
   return(hash("kind", "missing_name"));
 }
 /[A-Za-z_]+/
 -> MaybeName[0] {
   return(set_key(meta, "name", match_text()));
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
   items = [];
   item = undef;
 }
 /[A-Za-z_]+/
 -> Items[0] {
   item = match_text();
 }
 IT {
   push(items, item);
 }
 E {
   return(hash("kind", "items", "items", copy(items)));
 }
```

Use these hooks when the default collection behavior is not the shape you want. Otherwise prefer explicit action-edge returns or normal accumulator logic in action blocks because they are easier for readers to follow.

## Marker members currently differ by backend

Marker forms such as:

```text
@capture_slice
@mark(body_start)
```

are rule members, not ordinary return-value helpers, but they do not currently have one portable
execution contract. Perl treats the three anonymous spellings as one rule-level rolling switch;
Perl's named marker alone is guarded by the preceding regex index. Lua/LuaJIT treat both anonymous
and named markers as preceding-slot events. Rust, Dart, and Julia parse marker members but do not
execute them in their native runtime paths.

This example demonstrates Lua's current positional behavior only:

```text
Top::AND
 => MarkerBody

MarkerBody:AND
 /foo\(/
 @capture_slice
 @mark(body_start)
 /[A-Za-z]+/
 /\)/
 -> MarkerBody[0] {
   opened = 1;
 }
 -> MarkerBody[2] {
   mark_match_start(close_start);
   return(hash(
     "anonymous", capture_slice(),
     "named", capture_from(body_start),
     "between", capture_between(body_start, close_start),
     "body_start", mark_pos(body_start),
     "close_start", mark_pos(close_start)
   ))
 }
```

On Lua/LuaJIT, with seek cursor policy, input `foo(alpha)` returns
`[{"anonymous":"alpha","between":"alpha","body_start":4,"close_start":9,"named":"alpha"}]`.
The opener slot establishes both the anonymous boundary and the named mark after
its action runs; the closing slot can then read the same span through
`capture_slice()`, `capture_from(...)`, and `capture_between(...)`.

Lua preserves these markers as typed compiled rule-slot events, including
`@capture_from_here` and `@move_pos` as compatibility spellings for the anonymous
boundary. It applies each event after the owning slot's action/child dispatch and
before `LE`, matching the timing above. Malformed marker names and trailing marker
fragments are rejected rather than silently ignored.

Use explicit helper calls such as `start_capture_slice()` and `mark_here(name)` when portable timing
matters. Marker members remain compatibility surfaces until `INTER-MATCH-GAP-CAPTURE.1` reconciles
their scope. Historical automatic rule-level gap rolling is documented separately as the future
`@capture_gaps` contract.

## Choosing the right placement

Use this as the default decision guide:

| Goal | Prefer |
| --- | --- |
| Initialize state shared by the rule | `I { items = []; retv = undef }` |
| Initialize metadata shared by return paths | `I { set(meta, { "kind" : "node" }) }` |
| Transform one matched token | `-> Rule[index] { ... }` |
| Capture and reshape one child result | `retv = call(Child)` inside an action body |
| Append repeated child results | `push(items, retv)` inside action/iteration logic |
| Mark or move a boundary portably | `mark_here(name)` or `start_capture_slice()` inside a block |
| Maintain a backend-specific marker member | `@mark(name)` / `@capture_slice`, only with the backend-scope caveat above |
| Return a shaped optional fallback | `LX { return(...) }`, used sparingly |
| Customize repetition collection | `IT { ... }`, `EX { ... }`, or `E { ... }`, used only when default behavior is not enough |

## Worked example: source span with a named mark

```text
Block:AND
 I {
   set(meta, { "kind" : "block" });
   body = undef;
   body_text = undef;
 }
 /\{/
 /[^}]+/
 /\}/
 -> Block[0] {
   mark_here(body_start);
 }
 -> Block[1] {
   body_text = match_text();
 }
 -> Block[2] {
   body = capture_from(body_start);
   set(meta, set_key(meta, "body", body));
   set(meta, set_key(meta, "body_start_line", mark_line(body_start)));
   return(copy(meta));
 }
```

The placement logic is:

- `I { ... }` creates state for this rule invocation.
- The opening brace slot establishes the named mark for later use.
- The body slot is explicit, so consume-mode matching advances through it before
  the closing delimiter action.
- The closing brace action reads from the earlier mark to the current local-match edge.
- The returned payload is shaped with value and source-location helpers.

## Worked example: explicit child-result dataflow

```text
Pair:AND /[A-Za-z_]+/ /\s*=\s*/ /\d+/
 -> Pair[0] {
   lhs = match_text();
 }
 -> Pair[1] {
   sep = match_text();
 }
 -> Pair[2] {
   rhs = match_text();
   return(hash("kind", "pair", "lhs", lhs, "rhs", rhs));
 }
```

The explicit assignments make the value flow visible. That is usually better than hiding the same logic behind empty edges when the rule needs to reshape the result.

## Practical guidance

- Put shared state in `I { ... }`.
- Put entry-match transformation in `I { ... }`; put later local-slot transformation in `-> Rule[index] { ... }`.
- Prefer helper statements inside action bodies; avoid raw Perl in new examples.
- Use method chains only when the action stays compact and readable.
- Treat `LS`, `LE`, `LX`, `IT`, `EX`, and `E` as advanced placement hooks, not as the normal way to write every rule.
- Use marker forms such as `@mark(name)` only when the grammar slot is the boundary; use helper-call forms inside blocks.
- Keep lifecycle examples explicit about why the hook is needed, because placement hooks can make parse behavior harder to infer if used casually.

## Deeper reference

For the full lifecycle-block contract catalog with emitted-Perl examples, see `USER_GUIDE_ActionIR_Contracts.md` and `USER_GUIDE_ActionIR_EmittedPerlReference.md` in the repo root. These are the exhaustive working references while the book continues growing.
