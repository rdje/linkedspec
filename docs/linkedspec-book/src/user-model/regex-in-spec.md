# Regex in `.spec`

Every LinkedSpec rule ultimately matches input with **regular expressions**. A `.spec`
file is *regex-anchored*: rules recognize input by anchoring on regex literals, then
transfer to child rules and run actions. Understanding regex is therefore central to
understanding `.spec`.

This chapter is the mental model. For the exact grammar of a regex literal, see
[Formal `.spec` Grammar §3.1](../appendix/formal-grammar.md). For the capture-reading
helpers in full, see [Capture, Marks, and Source Locations](../dsl/capture-marks-and-source-locations.md)
and the [Source Boundary Helper Reference](../dsl/source-boundary-helper-reference.md).

Everything here is part of the **backend-neutral `.spec` contract**. The runnable
snippets use the Perl reference backend, but a Rust/Dart/Julia/Lua backend matches the same
patterns with the same results.

## The regex literal

A regex literal is written between forward slashes:

```text
/pattern/
```

- The **delimiter** is `/`. To put a literal forward slash *inside* the pattern, escape
  it as `\/` (for example `/a\/b/` matches `a/b`).
- The **pattern body** is an ordinary regular expression in the host engine's dialect:
  character classes, quantifiers, groups, anchors, alternation, lookaround, and so on.
- **Flags are written inline**, inside the pattern, with modifier groups such as `(?i)`
  (case-insensitive), `(?m)` (multi-line `^`/`$`), and `(?s)` (dot matches newline), or
  scoped forms like `(?s:…)`. The shipped corpus uses exactly this style — `ebnf.spec`
  opens a rule with `/(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=/` and `Lispish.spec` uses
  `(?s:.*?)`. The `.spec` layer adds no flag system of its own on top of the pattern.

A minimal no-regex entry rule that dispatches to a keyword matcher:

```text
Top::
 -> Keyword .push
LX { return(copy(array(Top))) }

Keyword:
 /foo/ I.return(entry_text())
```

On input `foo`, this returns `["foo"]`.

## Regex slots: more than one pattern per rule

A rule paragraph may contain **several** regex literals. Each is a numbered **slot**, in
source order, starting at `0`:

```text
ThirdChild:AND
 /first/ -> A
 /second/ -> B
```

Here `/first/` is slot `0` and `/second/` is slot `1`. How the slots combine is decided
by the **rule mode** (see [Rule Modes and Parse Modes](rule-modes-and-parse-modes.md)):

- In an **AND** rule, the slots form an **ordered sequence**: slot `0`, then slot `1`, …
  each must match in turn.
- In an **OR** rule, the slots are **alternatives**: the engine tries them and the first
  that matches wins. The engine records **which** alternative matched, and that decision
  drives dispatch.

An action edge targets a specific slot. `-> Rule` is shorthand for `-> Rule[0]`;
`-> Rule[N]` selects slot `N` (mainly used for same-rule recursive entry):

```text
Name:AND
 /alpha/ -> Name[0] { ... }
 /beta/  -> Name[1] { ... }
```

> The matched-alternative index is an internal dispatch signal — it selects which
> edge/branch runs. It is *not* exposed as a capture-reader helper; read matched text and
> groups with the helpers below.

## Anchoring: `seek` versus `consume`

Where a regex is *allowed* to match is controlled by the runtime **parse mode**:

- **`seek`** (the default): the pattern may match **anywhere ahead** of the cursor — the
  parser can skip leading text to reach the next anchor. This is what makes LinkedSpec
  good at coarse-to-fine extraction.
- **`consume`**: the pattern must match **contiguously at the cursor** (`\G`-anchored).

The same rule behaves differently per mode — see
[Parse modes](rule-modes-and-parse-modes.md#parse-modes) for worked input examples.

## Capture groups

Capture groups are how a rule pulls structured pieces out of a match. `.spec` exposes
them through reader helpers. **This is the single most important detail to get right**, so
read it carefully.

### Numbered groups

A `(...)` group in the pattern is a **numbered capture**. In the common two-rule shape,
a no-regex `Top::` wrapper dispatches into a regex-bearing child rule, and the child reads
the entering captures with `entry_group(N)`. A post-match action attached directly to a
rule's own regex slot reads the local slot with `match_group(N)`. The
[entry-versus-match](#entry-versus-match) distinction is below.

```text
Top::
 -> Pair .push
LX { return(copy(array(Top))) }

Pair:
 /(\w+)=(\w+)/ I.return(hash("key", entry_group(0), "val", entry_group(1)))
```

The numbering follows three rules:

1. **Zero-based.** `entry_group(0)` is the **first** capture group, `entry_group(1)` the
   second, and so on. In the example, `entry_group(0)` is the `(\w+)` before `=` and
   `entry_group(1)` is the `(\w+)` after it. The same numbering applies to `match_group(N)`
   when you are reading a local post-match slot.
2. **Captures only — group `0` is *not* the whole match.** Unlike many regex libraries
   where group `0` means "the entire match", in `.spec` the group list holds *only* the
   parenthesised captures. To read the whole matched text, use `entry_text()` /
   `match_text()`.
3. **Compacted.** Capture groups that did **not** participate in the match are removed
   from the list, which **shifts the indices of the groups that follow** (see the gotcha
   below).

`entry_groups()` / `match_groups()` return the whole (compacted) capture list as an array.

### Named groups

A `(?<name>...)` group is a **named capture**. Read it by name (the name is a bareword,
not a quoted string):

```text
Subdef:
 /(?<subname>\w\S*)/ I.return(hash("name", entry_named(subname)))
```

- `entry_named(name)` / `match_named(name)` return the captured value, or `undef` if that
  name did not participate.
- `entry_has(name)` / `match_has(name)` return whether the name participated.
- `entry_map()` / `match_map()` return all named captures as a hash.

**Prefer named groups when a pattern has optional or alternative captures.** Names are
keyed by name, so they are *stable* — a group that does not participate simply reports
absent, and the others keep their names. Numbered groups, by contrast, are compacted
(next section).

### The compaction gotcha

Because non-participating numbered groups are dropped, indices are **positional in the
result, not in the pattern**:

```text
Unit:
 /(\d+)?([a-z]+)/ I.return(hash("amount", entry_group(0), "name", entry_group(1)))
```

Match this against `abc`:

- `(\d+)?` matched nothing (no leading digits), so it is dropped.
- `([a-z]+)` matched `abc`.
- The compacted list is therefore `["abc"]`: `entry_group(0)` is `"abc"`, and
  `entry_group(1)` is `undef`.

So `"amount"` becomes `"abc"` and `"name"` becomes `undef` — almost certainly not
intended. Against `12abc`, both groups participate and the mapping is the expected
`entry_group(0) == "12"`, `entry_group(1) == "abc"`.

The fix is to name the groups so absence does not shift anything:

```text
Unit:
 /(?<amount>\d+)?(?<name>[a-z]+)/ I.return(hash("amount", entry_named(amount), "name", entry_named(name)))
```

Now `abc` yields `amount => undef`, `name => "abc"`, and `12abc` yields `amount => "12"`,
`name => "abc"`, regardless of which optional groups fired.

### Entry versus match

There are two numbered/named capture families because there are two matches in play:

- **`entry_*`** reads the match that **entered** the current context — the regex match
  that dispatched into this rule/action. This is what the regex-bearing child rules above
  use when entered by a no-regex `Top::` wrapper.
- **`match_*`** reads the **current local** match being processed inside the rule, typically
  from a post-match edge action attached to that rule's own regex slot.

In simple one-slot flows they may point at the same text, but they are different channels.
They diverge in nested or dispatched rules, where the action runs against a local match
different from the one that brought it in. The full mental model and a side-by-side example live in
[Capture, Marks, and Source Locations](../dsl/capture-marks-and-source-locations.md).

## What a backend's regex engine must support

Because `.spec` is the universal contract, a backend in any language must provide a regex
engine with the capabilities below. This is the feature set defined by the Perl reference
engine (`LinkedRE`), the canonical behavioral oracle; a conforming backend reproduces the
same observable behavior (the Rust runtime, for example, builds these on the `rgx` engine):

1. **Position-tracked matching** — query and set the current match position, so matching
   resumes from the cursor.
2. **Two anchoring modes** — unanchored forward search (`seek`) and current-position
   anchoring (`consume`, i.e. `\G`).
3. **N-way alternation with branch identification** — combine a rule's regex slots into
   one alternation and report **which** alternative (0-based) matched. The Perl reference
   does this with embedded-code position tracking (`(?{$pos=N})`); the Rust runtime uses
   the engine's native matched-branch number. A backend whose engine lacks embedded-code
   tracking can iterate the alternatives individually instead.
4. **Numbered capture groups** — 0-based, **captures only** (the whole match is read
   separately), with **non-participating groups compacted out** of the list.
5. **Named capture groups** — read by name, with presence testable.
6. **Lookaround used by governed specs** — zero-width lookahead and fixed-width
   positive/negative lookbehind must execute where they occur. In particular,
   `spec.spec` uses the one-character negative assertion `(?<!\\)` to reject an
   escaped regex delimiter. PUC Lua/LuaJIT provide this through PCRE2, Dart
   through ECMAScript `RegExp`, and current Rust through RGX rather than Rust's
   default basic `regex` crate.

Determinism is required throughout: first-match-wins for alternation, and no reliance on
engine-specific group-iteration order. The [Backend Handoff](../appendix/backend-handoff.md)
chapter collects this alongside the other backend obligations.

## Where to go next

- [Rule Modes and Parse Modes](rule-modes-and-parse-modes.md) — how slots combine
  (AND/OR) and how `seek`/`consume` anchor them.
- [Capture, Marks, and Source Locations](../dsl/capture-marks-and-source-locations.md) —
  the full `entry_*` / `match_*` / `capture_*` / `mark_*` / `cursor_*` mental model.
- [Source Boundary Helper Reference](../dsl/source-boundary-helper-reference.md) — every
  capture/group reader with its result.
- [Formal `.spec` Grammar §3.1](../appendix/formal-grammar.md) — the exact syntax of regex
  clusters and slots.
- [Backend Handoff](../appendix/backend-handoff.md) — the full contract for building a new
  backend.
