# USER GUIDE
This guide explains LinkedSpec in two layers:
1. as a progressive extraction parser DSL, and
2. as a lowering-driven action DSL whose helper forms are rewritten into canonical ActionIR and then emitted into backend code.

For current LinkedSpec work, the second layer matters the most. If you want `.spec` files that stay backend-neutral and portable across future non-Perl backends, you should understand the lowering surface and keep `.spec` authoring on the canonical method-like DSL rather than on raw Perl fragments.

## Internal Compiler Model Note
For advanced compiler/descriptor work, one naming point is now explicit:
- returned descriptors now expose `dependency_regex_map`,
- per-rule compiled rule info now exposes `dependency_refs`,
- and the preferred internal compiler model is now "dependency-regex state",
- so current architecture/docs should be read as:
  - `compiled_spec_state`
  - `compiled_dependency_regex_state`
  - `compiled_descriptor_state`

That distinction matters because the project is refactoring toward clearer state models, not preserving every historical struct name as the best long-term mental model. Current public/compiler docs should now describe the outward derived-regex payload as `dependency_regex_map` and the rule-local dependency-reference list as `dependency_refs`.

## Authoring Contract
The project direction is now explicit:
- `.spec` files are intended to become 100% raw-Perl-free,
- raw Perl inside `.spec` is obsolete compatibility debt, not an acceptable long-term authoring surface,
- and any remaining raw Perl occurrences should be treated as migration blockers to flag and replace with language-agnostic DSL equivalents.

That matters because the long-term goal is not “Perl, but cleaner.” It is a backend-neutral `.spec` language that can be implemented by LinkedSpec backends in Rust and other languages too.

## Why this guide is split
The lowering surface is now large enough that a single giant guide becomes hard to navigate. This top-level guide is the map; the detailed lowering references live in focused module-oriented guides.

Detailed lowering references:
- [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md)
- [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md)
- [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md)
- [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md)
- [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md)
- [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md)
- [`USER_GUIDE_ActionIR_ArrayPipeline.md`](USER_GUIDE_ActionIR_ArrayPipeline.md)
- [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md)
- [`USER_GUIDE_RuleModesAndSplit.md`](USER_GUIDE_RuleModesAndSplit.md)

Read this file first, then jump into the specific module guide that matches the lowering family you are using.
For exhaustive review of the current lowering contract, including emitted Perl for every supported helper and compatibility construct, read [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md) alongside the module guides.

## What LinkedSpec Is
LinkedSpec compiles `.spec` files from `specs/` into dynamic parsers.
Those parsers match recursive, regex-anchored grammars and return AST/data structures defined by rule actions.

LinkedSpec is intentionally strong at:
- nested and recursive constructs,
- staged coarse-to-fine parsing,
- extraction-oriented parsing where anchor rules and follow-up passes matter more than strict token-by-token grammar purity.

## `.spec` Files Are Paragraph-Oriented
One of the easiest ways to understand LinkedSpec is to stop thinking of a `.spec` file as a line-oriented mini-language.

The better mental model is:
- a `.spec` file is a sequence of rule paragraphs,
- each rule paragraph starts with one rule-start token,
- and that rule paragraph continues until the next rule-start token or end of file.

The only hard structural anchor for a rule paragraph is the first token:

```text
rule_name:
top_rule::
```

Once that rule-start token appears, the rest of the paragraph belongs to that same rule until another rule starts.

That top-level rule-start idea matters literally. A `word:` line only starts a new rule paragraph when the parser is back at top level. If you are still inside an open action/lifecycle/code block, label-like lines stay part of that block instead of silently starting a new rule.

Example:

```text
Top::
 /a/ -> Next {
label:
 return(array("?Top:", array_copy(array(Top))))
 }

Next::
 /b/ { return(array("?Next:", array_copy(array(Next)))) }
```

Here `label:` is block content inside `Top`, not the start of a new `label` rule paragraph.

Current frontend validation also rejects malformed extra-colon starts like `rule_name:::` before bootstrap parse. Supported rule starts remain the normal `rule_name:` and `rule_name::` forms plus their documented rule-mode suffixes.
Current frontend validation also rejects stray preamble text before the first rule paragraph: after leading blank lines and `#` comments, the first real line must be a rule start.
Current frontend validation also treats rule starts as top-level only, so rule-like lines inside open `{ ... }` blocks are no longer misclassified as new rules.
Current frontend validation also rejects rule paragraphs that leave an open `{`, `(`, or `[` construct unclosed by end of file, instead of silently treating that unfinished block as acceptable paragraph content.

Worded rule modes must also use their exact supported spellings:
- `AND`
- `AND+`
- `AND{...}`
- `OR`
- `OR+`
- `OR{...}`

Malformed glued forms like `rule_name:ORX` and `rule_name::ANDX` are rejected early too, rather than being treated as “close enough” prefixes of the supported labels.

Edge target names follow that same exactness rule:
- `-> rule-extra` is invalid,
- `=> rule-extra` is invalid,
- and current frontend validation rejects those malformed glued target suffixes early instead of silently prefix-parsing them as `rule`.

In practice that means a rule paragraph can contain:
- one or more regex tokens like `/.../`,
- lifecycle blocks like `I { ... }`, `LS { ... }`, `LE { ... }`, `LX { ... }`,
- action edges like `-> child`, `-> child[idx]`, `-> child { ... }`,
- and blind-call edges like `=> helper`, which directly invoke another rule as a parser step instead of selecting one of the current rule's regex slots.

The important point is that, after the rule-start token, those elements are paragraph members, not a rigid line-by-line grammar with one forced ordering.
That still does not mean “arbitrary text is valid there.” At top level inside a rule paragraph, validation now expects supported paragraph members such as regexes, lifecycle/code blocks, action edges, blind calls, split markers, multiline fluent continuation lines (including dot-prefixed carrier lines and method-like continuation body/control lines), or the next rule start. Stray text like `random garbage` at top level inside a rule paragraph is rejected early, and the same rule now applies to same-line rule headers too: after `rule:` / `rule::` and any leading same-line regex cluster, the rest of that header must also begin with a supported paragraph member rather than arbitrary filler text. The current split-marker spellings are also explicit there now: valid forms are preferred `@capture_slice`, named `@mark(name)`, and compatibility aliases `@capture_from_here` / `@move_pos`; malformed `@...` marker spellings are rejected early.

### The natural convention versus the real grammar
There is a natural house style that most specs follow:
- rule start token first,
- then one or more regexes,
- then `I`,
- then action edges,
- then later lifecycle blocks where they make sense.

That style is natural because it reads well and mirrors how people think about the rule.

But the real grammar is more flexible:
- after the leading `rule:` or `rule::`,
- regexes, lifecycles, and edges belong to the same rule paragraph,
- and their order is not artificially locked down by the file format.

That flexibility is part of the supported contract, not an accidental side effect. Regression coverage now explicitly locks representative action-rule and blind-call rule paragraphs where those members are interleaved after the leading rule label.

The regex count should stay open-ended too:
- most rules use one regex,
- many use two,
- some use three,
- and the format should not pretend there is a tiny fixed maximum.

### A conventional rule paragraph

```text
pair:&
 /[A-Za-z_]\w*/
 /\s*=\s*/
 /[^,\n]+/
 I {declare(scalar, retv)}
 -> child_rule
 LX {return(scalar(retv))}
```

This is the common style:
- rule label,
- regexes,
- setup lifecycle,
- edges,
- later lifecycle.

### The same paragraph model in freer order

```text
pair:&
 I {declare(scalar, retv)}
 /[A-Za-z_]\w*/
 -> child_rule
 /\s*=\s*/
 LX {return(scalar(retv))}
 /[^,\n]+/
```

That is not the style most people should prefer for readability, but it illustrates the real file model:
- the rule still starts at `pair:&`,
- all following paragraph members still belong to `pair`,
- and the rule still ends only when the next rule label starts or the file ends.

### The same paragraph model on one line

Because the rule body is paragraph-based rather than line-based, the same rule can also be written on one physical line:

```text
pair:& /[A-Za-z_]\w*/ /\s*=\s*/ /[^,\n]+/ I {declare(scalar, retv)} -> child_rule LX {return(scalar(retv))}
```

The same thing is true for blind-call rules:

```text
wrapper::AND I {declare(scalar, retv)} => header => body => trailer LX {return(scalar(retv))}
```

That is usually less readable than the multiline form, so it should not be the default house style. But it is still real supported syntax:
- the rule still starts at the leading `pair:&` or `wrapper::AND`,
- the rest of the line is still just that same rule paragraph,
- and same-line versus multiline layout does not change the structural meaning of the rule.

The same validation rule now applies across both layouts too:
- current DSL validation checks regex-token syntax on multiline rule paragraphs,
- current DSL validation checks regex-token syntax on same-line rule paragraphs,
- so malformed `/.../` rule tokens are reported before bootstrap parse instead of only surfacing later as parser failure.

### Why this matters
This paragraph-oriented view demystifies `.spec` files:
- they are not trying to be hard to parse,
- they are not a deeply context-sensitive line grammar,
- and they are easier to reason about when you first identify rule starts and then treat everything until the next rule start as one rule body.

So the practical reading rule is simple:
1. find `rule:` or `rule::`,
2. keep collecting that rule’s regexes, lifecycles, and edges,
3. stop only when the next rule starts or the file ends.

That is a large part of why LinkedSpec specs are easy to parse structurally even when the rules themselves are doing sophisticated extraction work.

## The Most Important Concept: Lowering
When you write helper-style action code such as:

```text
I {declare(array, items); declare(scalar, retv)}
-> child {assign(scalar(retv), call(child)); push_value(array(items), scalar(retv))}
-> child[1] {return(array("?Top:", array_copy(array(items))))}
```

LinkedSpec does **not** treat that as opaque text. Instead it tries to:
1. recognize supported helper/method constructs,
2. convert them into canonical ActionIR events/nodes,
3. lower those nodes into backend code.

That distinction matters because not all syntactically valid Perl inside a `{ ... }` block is equally portable.

### Portability tiers
Think about authoring styles in three tiers, but read tiers 2 and 3 as migration reality rather than desirable end-state authoring:

1. **Canonical helper-only lowering**
   - Best choice.
   - Uses helper forms like `declare(...)`, `assign(...)`, `return(payload)`, `if(...)`, `push_value(...)`, `array(...)`, `hash(...)`, `array_copy(...)`, compatibility `array_values(...)`, `hash_copy(...)`, `concat_arrays(...)`, `sorted(...)`, `join_values(...)`, `replace_substr(...)`, `rm_prefix(...)`, `rm_suffix(...)`, `concat(...)`, `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_mod(...)`, `num_clamp(...)`, `num_min(...)`, `num_max(...)`, `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`, `matches(...)`, `coalesce_nonempty(...)`, `index_of(...)`, `set_key(...)`, `rename_key(...)`, and so on.
   - This is the preferred style for backend-neutral `.spec` authoring.

2. **Helper shells with raw host expressions inside arguments**
   - Transitional only.
   - Example: `assign(scalar(pos_begin), pos $$STRING)` or `assign(scalar(part), substr($$STRING, ...))`.
   - The outer statement is canonical, but the inner expression is still host-language flavored.
   - Use only when no dedicated helper exists yet, and treat it as migration debt to remove rather than a desirable steady-state pattern.

3. **Legacy or raw compatibility forms**
   - Compatibility only.
  - Examples: `return call(rule)`, `push(rule)`, `$CAPTURE`, `capture_slice()`, `capture_slice_len()`, `capture_slice_until_cursor()`, `capture_slice_until_cursor_len()`, `capture_take_until_cursor()`, `capture_take_until_cursor_len()`, `capture_take_rest()`, `capture_take_rest_len()`, `capture_slice_pos()`, `capture_slice_line()`, `capture_slice_col()`, `start_capture_slice()`, `start_capture_slice_from(name)`, `capture_take()`, `capture_take_len()`, `capture_rest()`, `capture_rest_len()`, `capture_from(name)`, `capture_len_from(name)`, `capture_until_cursor_from(name)`, `capture_until_cursor_len_from(name)`, `capture_take_until_cursor_from(name)`, `capture_take_until_cursor_len_from(name)`, `capture_take_rest_from(name)`, `capture_take_rest_len_from(name)`, `capture_take(name)`, `capture_take_len_from(name)`, `capture_rest_from(name)`, `capture_rest_len_from(name)`, `capture_between(start_mark, end_mark)`, `capture_len_between(start_mark, end_mark)`, `capture_take_between(start_mark, end_mark)`, `capture_take_between_len(start_mark, end_mark)`, `mark_input_start(name)`, `mark_input_end(name)`, `mark_here(name)`, `mark_match_start(name)`, `mark_copy(target_mark, source_mark)`, `mark_capture_slice(name)`, `clear_mark(name)`, `mark_exists(name)`, `mark_pos(name)`, `mark_line(name)`, `mark_col(name)`, `cursor_pos()`, `cursor_line()`, `cursor_col()`, `cursor_rest()`, `cursor_rest_len()`, `input_text()`, `input_len()`, `input_end_pos()`, `input_end_line()`, `input_end_col()`, `entry_text()`, `entry_line()`, `entry_start_line()`, `entry_col()`, `entry_start_col()`, `entry_group(index)`, `entry_groups()`, `entry_named(name)`, `entry_has(name)`, `entry_map()`, `entry_len()`, `entry_start_pos()`, `entry_end_pos()`, `entry_end_line()`, `entry_end_col()`, `match_text()`, `match_line()`, `match_start_line()`, `match_col()`, `match_start_col()`, `match_group(index)`, `match_groups()`, `match_named(name)`, `match_has(name)`, `match_map()`, `match_len()`, `match_start_pos()`, `match_end_pos()`, `match_end_line()`, `match_end_col()`, `BACKTRACK()`, or older compatibility aliases such as `capture_from_rule_start()`.
   - These are important for migration and compatibility, but they are not the target authoring surface for a backend-neutral `.spec`.

## Typical Workflow
1. Write or update a `.spec` grammar.
2. Build a parser:
   - `my $parser = LinkedSpec::get_parser('my_spec_name');`
3. Parse data:
   - `my $ast = $parser->(\$input_string);`
   - Returned parser coderefs expect a `SCALAR` reference input. Passing a plain scalar, array ref, hash ref, or `undef` now fails explicitly at the top-level parser boundary instead of falling through to a lower-level Perl dereference error.
4. If the grammar is large or heterogeneous, run additional passes on captured substrings or substructures.
5. If you are working on backend-neutral migration, inspect the lowering metadata with `return_descriptor => 1`.

Validation note: when changing parser/compiler/runtime behavior, run `bash tools/run_ci_local.sh` from the repo root before pushing so the local phase-0 gate remains the source of truth; hosted GitHub Actions CI is currently disabled to preserve account minutes. Recent internal load-time cleanup means `LinkedSpec.pm` no longer imports `Data::Dumper` or `LinkedRE` at façade load time, its public façade wrappers now preserve caller `$@` across successful owner delegation, its public trace wrappers now preserve caller `$@` across successful owner delegation too, `Validation.pm`, `Resolver.pm`, `RuleIR.pm`, and `RuleIR::EmitContext.pm` now preserve caller `$@` across successful extracted-owner delegation too, the remaining thin owner delegates in `BootstrapSpec.pm`, `Runtime.pm`, `ActionIR::Scanner.pm`, `ActionIR::StatementSplit.pm`, and `ActionIR::CanonicalEvents.pm` now preserve caller `$@` across successful owner delegation too, `ActionRewriter.pm` now preserves caller `$@` across successful owner delegation for its dep-builder/helper/lowering/rewrite wrapper surface too, `SpecEntry.pm` now preserves caller `$@` across successful trace/dump helper delegation too, `Compiler.pm` now preserves caller `$@` across successful trace/dump/regex helper delegation too, `BootstrapSpec::Core.pm` now preserves caller `$@` across successful regex-helper delegation too, `Trace::_trace_stringify(...)` now preserves caller `$@` across successful dump formatting too, `PluginBridge.pm` now preserves caller `$@` across successful legacy runtime load/exec delegation too, `ParserFactory.pm` now preserves caller `$@` across successful lazy owner lookup and public parser-factory orchestration too, and the remaining extracted ActionIR dep-builder owners now preserve caller `$@` across successful callback-map lookup/build paths too. `Trace.pm` now lazy-loads `Data::Dumper` only when referenced values actually need structured dump formatting, `RuleIR.pm` now lazy-loads `Data::Dumper` only when debug execution-meta dumps actually need it, `SpecEntry.pm` now lazy-loads `Data::Dumper` only when high-verbosity rule-entry debug dumps actually need it, `SpecEntry.pm` now lazy-loads `RuleIR::EmitContext.pm` only when rule-entry compilation reaches emit-context assembly, `Compiler.pm` now lazy-loads `Data::Dumper` only when traced compiler dumps actually need it and now lazy-loads `LinkedRE` only when dependency-regex assembly actually needs it, `BootstrapSpec::Core.pm` now lazy-loads `LinkedRE` only when bootstrap registry construction or bootstrap scanner handlers actually need it, `Validation.pm` now lazy-loads `Trace.pm` only when validation errors or warnings actually emit trace output, `Resolver.pm` now lazy-loads `Trace.pm` only when invalid-spec or spec-resolution trace/error paths actually emit output, `RuleIR::EmitContext.pm` now lazy-loads `ActionIR::RewritePipeline.pm` and `ActionIR::Diagnostics.pm` when emit-context build paths need rewrite/diagnostic helpers, now keeps `ActionRewriter.pm` out of normal compile-time emit-context builds entirely, and now owns the façade compatibility rewrite entrypoint too, `ActionIR::Scanner.pm` now lazy-loads `ScannerCore.pm` only when contract scanning starts, `ActionIR::ScannerCore.pm` now lazy-loads its scanner rule packages only when scanning actually starts, `ActionRewriter.pm` now lazy-loads `ActionIR::Scanner.pm`, `ActionIR::CanonicalEvents.pm`, `ActionIR::Diagnostics.pm`, `ActionIR::StatementSplit.pm`, `ActionIR::Contracts.pm`, `ActionIR::RewritePipeline.pm`, `ActionIR::ControlFlow.pm`, `ActionIR::MethodLowering.pm`, and `ActionIR::DeclareMethod.pm` only when those helper families are used, `ActionIR::StatementSplit.pm` now lazy-loads `StatementSplit::Core.pm` only when statement splitting starts, `ActionIR::StatementSplit::Core.pm` now lazy-loads `StatementSplit::Mode.pm` only when splitting actually starts, and `ActionIR::CanonicalEvents.pm` now lazy-loads `CanonicalEvents::Core.pm` only when canonical-event building starts.
The same owner pattern now applies one level deeper too: `ActionIR::DeclareMethod.pm` and `ActionIR::Scanner.pm` lazy-load `ActionIR::MethodExpr.pm` while assembling their default callback maps, so `ActionRewriter.pm` no longer needs to preload `MethodExpr` just to build those dep-builder payloads.
The broader extracted ActionIR dep-builder family now follows that same rule: `ControlFlow`, `Diagnostics`, `RewritePipeline`, `Contracts`, `ValueExpr`, `ArrayPipeline`, `FlowExpr`, `MethodLowering`, `StatementSplit`, and `CanonicalEvents` all lazy-load their callback-owner packages while assembling default callback maps, so those owners no longer depend on the caller preloading the callback package first.
The remaining legacy `ActionRewriter` compatibility entrypoints now also share one internal EmitContext delegator instead of a long wall of bespoke wrappers, while `EmitContext::_rewrite_action_code_with_diagnostics(...)` preserves the historical two-argument rewrite-helper call shape for direct compatibility callers.

## Rule Anatomy Refresher
Minimal skeleton:

```text
top_rule::
 -> subrule_a
 -> subrule_b
 LX { return \@top_rule }

subrule_a: /.../
subrule_b: /.../
```

Most important syntax elements:
- Entry rule: `name::`
- Regular rule: `name:`
- Current rule-mode suffixes:
  - `name:&`
  - `name:AND`
  - `name:AND+`
  - `name:|`
  - `name:+`
  - `name:*`
  - `name:?`
  - `name:OR`
  - `name:OR{2}`
  - `name:OR{2,4}`
  - `name:OR{2,}`
  - `name:OR{,4}`
- Regex pattern(s): `/.../`
- Split-boundary cursor:
  - `@capture_slice`
  - `@mark(name)`
  - compatibility aliases: `@capture_from_here`, `@move_pos`
- Branch edges:
  - `-> rule`
  - `-> rule[idx]`
  - `-> rule { ... }`
  - `-> rule .method(args).method2(args)`
- Lifecycle/non-action blocks:
  - `I { ... }`
  - `LS { ... }`
  - `LE { ... }`
  - `LX { ... }`
  - also supported in advanced specs: `E`, `EX`, `IT`

Use `@capture_slice` when one moving anonymous capture boundary is enough at the rule-paragraph level. Use `capture_slice()` when the rule wants the old raw `$IPOS` capture pattern explicitly without introducing a named checkpoint first. Use `capture_slice_len()` when the rule wants the numeric width of that same anonymous capture-boundary span without materializing the substring itself; `capture_slice_length()` remains supported as a longer alias, and older `capture_from_rule_start()` / `capture_len_from_rule_start()` spellings remain supported for compatibility. Use `capture_slice_until_cursor()` when the rule wants that same anonymous left boundary but wants the right edge to be the live parser cursor instead of the current match edge, and `capture_slice_until_cursor_len()` when it only needs the width of that same through-cursor span. Use `capture_take_until_cursor()` when the rule wants that same anonymous through-cursor span and also wants the anonymous boundary to roll forward afterward, and `capture_take_until_cursor_len()` when the same rolling through-cursor flow is right but the rule only needs width metadata rather than the captured text. Use `capture_take_len()` when the rule wants the current anonymous current-edge span width and also wants the anonymous boundary to roll forward afterward, without materializing the captured text. Use `capture_take_rest()` when the rule wants the current anonymous boundary to run all the way through end-of-input and also wants that anonymous boundary to roll forward to end-of-input afterward, and `capture_take_rest_len()` when the same rolling tail flow is right but the rule only needs width metadata rather than the captured text. Use `capture_slice_pos()` when the rule should read the numeric position of that same current anonymous capture boundary directly as data, `capture_slice_line()` when the rule should read the 1-based line number where that same anonymous capture slice currently starts, and `capture_slice_col()` when the rule should read the 1-based column where that same anonymous capture slice currently starts. Use `start_capture_slice()` when the rule should begin a new anonymous capture slice explicitly from inside a lifecycle or action block, instead of spelling `assign(s(IPOS), cursor_pos())` directly; `capture_slice_here()` remains supported as a compatibility alias. Use `start_capture_slice_from(name)` when a stored named checkpoint should become the active anonymous capture boundary again, so later same-rule logic can keep using the concise anonymous helper family after restoring that remembered left edge. Use `capture_take()` when the rule should read the current anonymous capture slice and then advance that anonymous boundary to the current parser position for later same-rule reads. Use `capture_rest()` when the rule should read from the current anonymous capture boundary through end-of-input, and `capture_rest_len()` when it only needs that remaining width; `capture_rest_length()` remains supported as a longer compatibility alias. Use `@mark(name)` when the checkpoint meaning deserves a real name, when more than one checkpoint may coexist inside the same rule, or when the same rule needs several stable named left edges. Use `capture_from(name)` when that named checkpoint should stay stable, `capture_len_from(name)` when the rule should read the numeric width of that same current-edge span without materializing the substring itself, `capture_until_cursor_from(name)` when the rule should keep that same named checkpoint as the left edge but stop at the live parser cursor instead of the current match edge, `capture_until_cursor_len_from(name)` when it only needs the width of that same named-mark through-cursor span, `capture_take_until_cursor_from(name)` when a later same-rule action should both return the current through-cursor span and advance that named checkpoint to the live parser cursor, `capture_take_until_cursor_len_from(name)` when the same rolling through-cursor flow is right but the rule only needs the width of that named-mark span, `capture_take_len_from(name)` when a later same-rule action should both return the width of the current span and advance that named checkpoint to the current parser position, `capture_take_rest_from(name)` when a later same-rule action should both return the named-mark tail through end-of-input and advance that named checkpoint to end-of-input, `capture_take_rest_len_from(name)` when the same rolling tail flow is right but the rule only needs the width of that named-mark tail, `capture_take(name)` when a later same-rule action should both return the current span and advance that named checkpoint like a named split cursor, `capture_rest_from(name)` when the rule should keep that same named checkpoint as the left edge but read all the way through end-of-input instead of stopping at the current match edge, `capture_rest_len_from(name)` when it only needs the width of that same named-mark tail, `capture_between(start_mark, end_mark)` when the rule should read the span between two explicit named checkpoints instead of using the current match as the right edge, `capture_len_between(start_mark, end_mark)` when the rule should read the numeric width of that same explicit two-mark span instead of materializing the substring, `capture_take_between(start_mark, end_mark)` when that same explicit two-mark read should also advance the start mark to the stored end mark afterward, and `capture_take_between_len(start_mark, end_mark)` when that same explicit rolling two-mark flow is right but the rule only needs width metadata rather than the span text itself. Use `mark_input_start(name)` when the rule should remember the absolute start of the current input under an explicit named checkpoint, `mark_input_end(name)` when the rule should remember the absolute end of the current input under an explicit named checkpoint even if the live parser cursor is still earlier, `mark_here(name)` when the rule should move that named checkpoint explicitly without bundling the write into the read itself, `mark_match_start(name)` when the rule should store the left edge of the current match rather than the post-match parser position, `mark_copy(target_mark, source_mark)` when the rule should copy one remembered boundary into another named checkpoint explicitly, `mark_capture_slice(name)` when the current anonymous capture boundary deserves a stable explicit name before later anonymous reads move again, `clear_mark(name)` when the rule should drop that named checkpoint explicitly before later reads, `mark_exists(name)` when the rule should branch or record metadata based on whether that named checkpoint is currently present, `mark_pos(name)` when the rule should read the stored numeric checkpoint position itself, `mark_line(name)` when the rule should read the 1-based line number of that named checkpoint directly without round-tripping through the numeric position first, and `mark_col(name)` when the rule should read the 1-based column of that named checkpoint directly. Use `cursor_pos()` when the rule should read the current parser cursor position directly as data, `cursor_line()` when the rule should read the current parser cursor line directly as data, `cursor_col()` when the rule should read the current parser cursor column directly as data, `cursor_rest()` when the rule should read the remaining text from the live parser cursor through end-of-input directly as data, and `cursor_rest_len()` when the rule should read the numeric width of that same live parser-cursor tail directly as data. Use `input_text()` when the rule should read the whole current input string directly as data regardless of the live parser cursor, current rule entry, or current local match, `input_len()` when the rule should read the width of that same whole current input directly as data without spelling raw `$$STRING` or `length($$STRING)` inline, `input_end_pos()` when the rule should read that same whole-input right edge as one explicit absolute boundary position, and `input_end_line()` / `input_end_col()` when the rule should read the human-readable whole-input right-edge location directly even while the live parser cursor is still earlier. Use `entry_text()` when the rule should read the current immediate match text directly as data, `entry_line()` when the rule should read the current immediate match line directly as data, `entry_start_line()` when the same immediate-match left-edge line should be named more explicitly, `entry_col()` when the rule should read the current immediate match column directly as data, `entry_start_col()` when the same immediate-match left-edge column should be named more explicitly, `entry_group(index)` when the rule should read one immediate-match capture group directly as data, `entry_len()` when the rule should read the current immediate match width directly as data, `entry_start_pos()` when the rule should read the left edge of the current immediate match directly as data, `entry_end_pos()` when the rule should read the right edge of the current immediate match directly as data, `entry_end_line()` when the rule should read the 1-based line number of that immediate-match right edge directly as data, and `entry_end_col()` when the rule should read the 1-based column number of that immediate-match right edge directly as data. Use `match_text()` when the rule should read the current local match text directly as data, `match_line()` when the rule should read the current local match line directly as data, `match_start_line()` when the same current-local-match left-edge line should be named more explicitly, `match_col()` when the rule should read the current local match column directly as data, `match_start_col()` when the same current-local-match left-edge column should be named more explicitly, `match_group(index)` when the rule should read one current-local-match capture group directly as data, `match_len()` when the rule should read the current local match width directly as data, `match_start_pos()` when the rule should read the left edge of the current local match directly as data, `match_end_pos()` when the rule should read the right edge of the current local match directly as data, `match_end_line()` when the rule should read the 1-based line number of that current-local-match right edge directly as data, and `match_end_col()` when the rule should read the 1-based column number of that current-local-match right edge directly as data. The long-form split/rule-mode guide now includes worked examples for anonymous capture-slice reads, anonymous capture-slice length reads, anonymous capture-slice through-cursor reads, anonymous capture-slice through-cursor width reads, advancing anonymous through-cursor width reads, advancing anonymous current-edge width reads, advancing anonymous end-of-input tail reads, advancing anonymous end-of-input tail-width reads, anonymous capture-slice position reads, anonymous capture-slice line reads, anonymous capture-slice column reads, explicit anonymous capture-boundary movement, advancing anonymous capture-boundary reads, anonymous/named capture-boundary bridge flow, anonymous capture-boundary tail reads, live parser-cursor tail reads through end-of-input, whole-input text reads, whole-input width reads, whole-input right-edge position reads, whole-input right-edge line/column reads, named-mark through-cursor reads, named-mark through-cursor width reads, advancing named-mark through-cursor width reads, advancing named-mark current-edge width reads, named-mark tail reads through end-of-input, named-mark tail-width reads through end-of-input, advancing named-mark tail reads through end-of-input, advancing named-mark tail-width reads through end-of-input, same-rule named capture, current-edge span-length reads, explicit two-mark span-length reads, advancing explicit two-mark width reads, explicit named-boundary copy after length reads, absolute input-start and input-end named checkpoints, advancing separator-delimited capture, explicit two-mark spans, advancing explicit two-mark spans, left-edge end markers, same-name reuse across different rules, missing-mark behavior, explicit numeric position reads, explicit named-checkpoint line reads, explicit named-checkpoint column reads, direct current-immediate-match text reads, direct current-immediate-match line reads, direct current-immediate-match explicit start-line reads, direct current-immediate-match column reads, direct current-immediate-match explicit start-column reads, direct current-immediate-match group reads, direct current-immediate-match width reads, direct current-immediate-match boundary reads including their right-edge line/column companions, direct current-local-match text reads, direct current-local-match line reads, direct current-local-match explicit start-line reads, direct current-local-match column reads, direct current-local-match explicit start-column reads, direct current-local-match group reads, direct current-local-match width reads, direct current-local-match boundary reads including their right-edge line/column companions, direct current-cursor position reads, direct current-cursor line reads, direct current-cursor column reads, direct current-cursor tail reads, direct flow branching on named-mark presence, and direct immediate/local named-capture presence checks and map snapshots.
Use `entry_named(name)` when the rule should read one immediate-match named capture directly as data, and use `match_named(name)` when the rule should read one current-local named capture directly as data. Use `entry_has(name)` / `match_has(name)` when the rule should ask whether those immediate/local named captures are present without snapshotting the whole hash first. Use `entry_map()` / `match_map()` when the rule should snapshot the whole immediate/local named-capture hash instead of just one key. Compatibility aliases `entry_named_map()` / `match_named_map()` remain supported, but the shorter `entry_map()` / `match_map()` forms are now the preferred teaching surface. Those helpers are the named-capture companions to `entry_group(index)` / `match_group(index)` and `entry_groups()` / `match_groups()`, so normal user-facing specs no longer need raw `%IMATCH_HASH` or `%LMATCH_HASH` access just to read or probe named regex captures.
Use `entry_groups()` when the rule should snapshot the whole immediate-match capture-group list directly as data, and use `match_groups()` when the rule should snapshot the whole current-local capture-group list directly as data. Those helpers are the list-level companions to `entry_group(index)` and `match_group(index)`.

Documentation style note: the user guides should prefer backend-neutral helper syntax in code blocks where possible. Perl-specific lowering is still documented, but it belongs in the emitted-reference guides rather than being the default teaching surface for normal usage examples.

### Action-edge target indexing
One important rule-body detail is that action edges target regex slots by index.

The first regex of a rule has a special default meaning:

```text
-> rule
```

means the same thing as:

```text
-> rule[0]
```

In other words:
- `-> rule` means “match the first regex of `rule`,”
- `-> rule[0]` is the explicit spelling of that same default,
- `-> rule[1]` means “match the second regex of `rule`,”
- and in general `-> rule[N]` means “match the `(N+1)`th regex of `rule`.”

The important practical nuance is how this is normally used in real specs:
- `rule[N]` is usually used inside the definition of that same rule,
- because it is mainly a way to choose among that rule’s own regex entry slots during self-recursive parsing,
- while cross-rule edges usually stay on the first entrypoint and are written simply as `-> other_rule` or, less commonly, `-> other_rule[0]`.

Representative example:

```text
A:
 /[A-Za-z_]\w*/
 /"(?:[^"\\]|\\.)*"/
 /\d+/
 /[^\s,;]+/
 -> A
 -> A[1]
 -> A[2]
 -> A[3]

B:
 -> A
```

The practical reading is:
- inside `A`, plain `-> A` means `-> A[0]`, so it recurses through the first regex,
- `-> A[1]` targets the second regex of `A`,
- `-> A[2]` targets the third regex of `A`,
- `-> A[3]` targets the fourth regex of `A`,
- and a different rule such as `B` will usually just use `-> A` to enter `A` through its first regex entrypoint.

So the mechanical rule is general, but the normal authoring pattern is narrower:
- use `-> A`, `-> A[1]`, `-> A[2]`, `-> A[3]`, ... inside rule `A` when `A` is recursive and needs to choose among its own regex slots,
- use `-> B` or `-> B[0]` from another rule when you simply want rule `B`'s default first entrypoint,
- and treat cross-rule `-> B[N]` with `N > 0` as unusual rather than normal authoring style.

When multiple action-edge targets need the same structured code block, you can factor them into one grouped target list:

```text
semantic_annotation: /@(\w+)\s*:\s*/
-> semantic_annotation | grammar_rule {
  BACKTRACK()
  my $c = $CAPTURE
  $c =~ s/\s*$//o
  return ['semantic_annotation', [$IMATCH_LIST[0], $c]]
}
```

That grouped surface is now part of the supported `.spec` contract:
- `-> A | B { ... }` means “attach this same code block to both action-edge targets,”
- `-> A[1] | B[2] { ... }` uses the same idea when later regex slots need the shared block,
- and the bootstrap/compiler path expands that grouped form into ordinary separate action edges internally, so runtime semantics stay the same as if you had written one `-> ... { ... }` line per target.

The current scope is intentionally explicit:
- grouped action-edge targets are supported for the shared structured code-block form,
- they count as multiple action edges for rule planning and validation purposes,
- and they are meant for code-block factorization rather than for introducing a new action-edge execution model.

There is no tiny DSL-fixed cap here. If a rule genuinely needs four, five, or more regex slots, the indexing model stays the same:
- `-> rule[3]` means the fourth regex,
- `-> rule[4]` means the fifth regex,
- and so on.

Current frontend validation now rejects malformed edge-target indexing before bootstrap parse too:
- `-> rule[]` is invalid,
- `-> rule[abc]` is invalid,
- `-> rule-extra` is invalid because action-edge target names use word characters only unless they continue with a supported fluent/action suffix,
- `-> rule_a | rule_b` is invalid unless the grouped targets share an explicit `{ ... }` code block,
- `-> { ... }` is invalid because action edges must name a target rule,
- `=> { ... }` is invalid because blind calls must name a child rule,
- `=> rule-extra` is invalid because blind-call target names must stay plain rule identifiers,
- and `=> rule[0]` is invalid because regex-slot indexing belongs to action edges, not blind calls.

That exactness rule is intentional:
- supported action-edge continuations like `-> rule[idx]`, `-> rule.method`, `-> rule { ... }`, and grouped shared-block forms like `-> rule_a | rule_b { ... }` are still valid,
- action-edge fluent continuations must actually name a method after the dot, so malformed starts like `-> rule.` and `-> rule..push(...)` are rejected during validation,
- blind-call fluent continuations must also actually name a method after the dot, so malformed starts like `=> rule.` and `=> rule..return(...)` are rejected during validation,
- but glued punctuation suffixes like `-> rule-extra` are rejected early instead of being misread as plain `-> rule`,
- while blind-call targets stay plain rule names, so `=> rule`, `=> rule { ... }`, `=> rule.method(...)`, and `=> rule .method(...)` are valid but glued punctuation forms like `=> rule-extra` are not.

An explicit side-by-side equivalence example can help:

```text
A::
 /a/ -> A   { return(array("?A:", array_copy(array(A)))) }
 /b/ -> A[1] { return(array("?A:", array_copy(array(A)))) }
```

and:

```text
A::
 /a/ -> A[0] { return(array("?A:", array_copy(array(A)))) }
 /b/ -> A[1] { return(array("?A:", array_copy(array(A)))) }
```

mean the same thing for the recursive first slot:
- both use the first regex as the recursive entry,
- both use the second regex as the later terminating entry,
- and the only difference is whether the first-slot index is written implicitly or explicitly.

That is why the first regex of a rule matters so much in practice: plain `-> rule` is shorthand for “use that rule’s first regex entrypoint,” and indexed forms are mainly the self-recursive escape hatch for the other regex slots of that same rule.

For the worked long-form guide to the current rule-label sigils, blind-call `=> child_rule` orchestration patterns, and split-boundary behavior, read [`USER_GUIDE_RuleModesAndSplit.md`](USER_GUIDE_RuleModesAndSplit.md). That guide explains today’s supported `:&`, explicit `AND`, explicit `AND+`, `:|`, `:+`, `:*`, `:?`, explicit `OR`, bounded `OR{...}` forms, bounded `AND{...}` forms, advanced blind-call wrapper shapes, preferred `@capture_slice`, and named `@mark(name)` in one place, while also documenting compatibility aliases `@capture_from_here` / `@move_pos`, preferred anonymous capture helpers `capture_slice()` / `capture_slice_len()` / `capture_slice_until_cursor()` / `capture_slice_until_cursor_len()` / `capture_take_until_cursor()` / `capture_take_until_cursor_len()` / `capture_take_len()` / `capture_take_rest()` / `capture_take_rest_len()` / `capture_slice_pos()` / `capture_slice_line()` / `capture_slice_col()`, explicit anonymous capture-boundary move helper `start_capture_slice()`, explicit named-to-anonymous bridge helper `start_capture_slice_from(name)`, compatibility alias `capture_slice_here()`, explicit anonymous capture-boundary advancing helper `capture_take()`, explicit anonymous capture-boundary tail helpers `capture_rest()` / `capture_rest_len()` with compatibility aliases `capture_slice_length()` / `capture_rest_length()` / `capture_from_rule_start()` / `capture_len_from_rule_start()`, `capture_from(name)` as the stable named-read helper, `capture_len_from(name)` as the stable current-edge length helper, `capture_until_cursor_from(name)` as the stable named-mark through-cursor helper, `capture_until_cursor_len_from(name)` as the stable named-mark through-cursor width helper, `capture_take_until_cursor_from(name)` / `capture_take_until_cursor_len_from(name)` as the advancing named-mark through-cursor helpers, `capture_take_len_from(name)` as the advancing named-mark current-edge width helper, `capture_take_rest_from(name)` / `capture_take_rest_len_from(name)` as the advancing named-mark tail helpers through end-of-input, `capture_take(name)` as the advancing named-read helper, `capture_rest_from(name)` as the stable named-mark tail helper through end-of-input, `capture_rest_len_from(name)` as the stable named-mark tail-width helper through end-of-input, `capture_between(start_mark, end_mark)` as the explicit two-mark span helper, `capture_len_between(start_mark, end_mark)` as the explicit two-mark span-length helper, `capture_take_between(start_mark, end_mark)` as the explicit two-mark span plus advancing-start helper, `capture_take_between_len(start_mark, end_mark)` as the explicit two-mark width plus advancing-start helper, `mark_here(name)` as the explicit post-match named-write helper, `mark_entry_start(name)` / `mark_entry_end(name)` as the explicit immediate-entry boundary writers, `mark_match_start(name)` / `mark_match_end(name)` as the explicit current-match boundary writers, `mark_copy(target_mark, source_mark)` as the explicit named-boundary copy helper, `mark_capture_slice(name)` as the explicit anonymous-to-named bridge helper, `clear_mark(name)` as the explicit named-clear helper, `mark_exists(name)` as the explicit named-presence helper, `mark_pos(name)` as the explicit named-position read helper, `mark_line(name)` as the explicit named-line read helper, `mark_col(name)` as the explicit named-column read helper, `cursor_pos()` as the explicit current-cursor position read helper, `cursor_line()` as the explicit current-cursor line read helper, `cursor_col()` as the explicit current-cursor column read helper, `cursor_rest()` / `cursor_rest_len()` as the explicit current-cursor tail text/width read helpers, `input_text()` / `input_len()` / `input_end_pos()` as the explicit whole-input text/width/right-edge-position read helpers, `input_end_line()` / `input_end_col()` as the explicit whole-input right-edge line/column read helpers, `entry_text()` as the explicit current-immediate-match text read helper, `entry_line()` / `entry_start_line()` as the explicit current-immediate-match start-line read helpers, `entry_col()` / `entry_start_col()` as the explicit current-immediate-match start-column read helpers, `entry_group(index)` as the explicit current-immediate-match positional capture-group read helper, `entry_groups()` as the explicit current-immediate-match capture-group-list read helper, `entry_named(name)` as the explicit current-immediate-match named-capture read helper, `entry_map()` as the preferred explicit current-immediate-match named-capture-hash read helper with compatibility alias `entry_named_map()`, `entry_len()` as the explicit current-immediate-match width read helper, `entry_start_pos()` as the explicit current-immediate-match left-edge read helper, `entry_end_pos()` / `entry_end_line()` / `entry_end_col()` as the explicit current-immediate-match right-edge position/line/column read helpers, `match_text()` as the explicit current-local-match text read helper, `match_line()` / `match_start_line()` as the explicit current-local-match start-line read helpers, `match_col()` / `match_start_col()` as the explicit current-local-match start-column read helpers, `match_group(index)` as the explicit current-local-match positional capture-group read helper, `match_groups()` as the explicit current-local-match capture-group-list read helper, `match_named(name)` as the explicit current-local-match named-capture read helper, `match_map()` as the preferred explicit current-local-match named-capture-hash read helper with compatibility alias `match_named_map()`, `match_len()` as the explicit current-local-match width read helper, `match_start_pos()` as the explicit current-local-match left-edge read helper, `match_end_pos()` / `match_end_line()` / `match_end_col()` as the explicit current-local-match right-edge position/line/column read helpers, and several worked checkpoint/capture examples.

## Where Lowered Constructs Can Appear
Lowered constructs are not limited to one place.

### 1. Action blocks on edges

```text
-> child { assign(scalar(retv), call(child)); push_value(array(items), scalar(retv)) }
```

### 2. Chained action edges

```text
-> child .declare(scalar, name).assign(scalar(name), CAPTURE).return_array(node, array(scalar(name)))
```

### 3. Lifecycle blocks

```text
I  {declare(array, items); declare(scalar, flag)}
LS {print("loop start\n")}
LE {assign(scalar(flag), IMATCH)}
LX {return(array_copy(array(items)))}
```

### 4. Chained lifecycle forms

```text
I.declare(array, items).declare(scalar, flag)
LX.if(is_nonempty(array(items))).return(array_copy(array(items))).else().return_undef().endif()
```

### Fluent chains and `{...}` blocks are meant to be equivalent
Long-term, the backend-neutral goal is not "remove braces." It is:
- remove raw Perl dependence,
- keep method-like DSL semantics explicit,
- and allow those semantics to be authored in either of these equivalent forms:

```text
-> child .m1(...).m2(...).mk(...)
```

```text
-> child { m1(...); m2(...); mk(...) }
```

If a `{...}` block contains only method-like DSL statements, it is part of the intended backend-neutral surface, not a legacy escape hatch.
If a `{...}` block contains raw Perl, that is migration debt to remove rather than syntax we want to preserve.
Inside those method-only structured blocks, semicolons are accepted but no longer required between top-level method statements.
That same optional-semicolon rule now applies on lifecycle structured blocks too, including marker-style control flow across `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
It is also now regression-locked on generic helper-only blocks, not just control-flow examples, so both `{ m1(...)\n m2(...) }` and lifecycle forms across `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX` are part of the supported semicolon-light surface.
Treat the current examples as representative, not as the intended limit. The lifecycle families covered by that rule are `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`: if semicolon-light structured authoring applies to one lifecycle block family, it is intended to apply to the others too unless an explicit documented exception is introduced. Generic helper-only semicolon-light coverage is now regression-locked across that full family, and marker-style semicolon-light control-flow coverage is now regression-locked across that full family too.

### Nested method composition should be unlimited
Method arguments are intended to support unlimited nested method composition.

That means the backend-neutral target surface includes both:
- fluent sequencing at the statement level,
- and arbitrarily nested method composition inside argument lists.

Those two dimensions are meant to lower into the same canonical IR regardless of whether the outer surface is fluent chaining or a structured `{...}` block.

That equivalence target also extends inside control-flow bodies:
- `if(...)` / `elseif(...)` branches,
- and `switch(...)` / `case(...)` action bodies
should support the same fluent-versus-structured method-like authoring equivalence.

Documentation policy note:
- the guides should state this capability explicitly,
- and use representative examples where helpful,
- treat the guides and worked examples as part of the end-user contract for supported surfaces,
- not try to enumerate every possible nesting shape.

If you want the long-form teaching guide for that policy, read [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md). That guide focuses specifically on string, integer, float-like, array, and hash composition with many worked examples rather than module-by-module lowering notes.

That equivalence is no longer just aspirational wording: helper-only fluent action chains and structured `{...}` action blocks are now regression-locked to identical lowered action output, and helper-only lifecycle chains with nested composed arguments are now regression-locked to identical lowered lifecycle output.

This first lock is intentionally scoped. It does not yet claim that every nested method-composition shape is already equivalent across every possible return-payload or helper context.

One more supported slice is now locked too: nested array-pipeline composition inside `return(array(...))` lowers cleanly, and the fluent versus structured method surfaces now agree on the migration metadata for that return-payload shape as well.

Collection-valued nested array-pipeline composition is now locked on a broader supported surface too: `declare(array, ...)`, `assign(array(...), ...)`, and nested hash/array payload values all accept the same helper-only pipeline composition, and the fluent versus structured lifecycle forms agree on that metadata as well.

That supported collection-valued surface now extends to broader hash/object-oriented shapes too: `declare(hash, ...)`, `assign(hash(...), ...)`, `push_value(array(...), hash(...))`, and `return_array(..., hash(...))` all accept the same nested helper-only collection composition, and the fluent versus structured lifecycle forms agree on that metadata there as well.

That supported collection-hash shape is now locked on action-edge surfaces too: fluent `-> rule .m1(...).m2(...)` and structured `-> rule { m1(...); m2(...); }` forms now agree on compiled action output and migration metadata for that supported chain.

Supported branch-local control-flow slices are now locked too: fluent and structured method-like forms agree on migration metadata inside `if(...)` / `elseif(...)` / `else()` branches and `switch(...)` / `case(...)` / `default()` bodies for supported general-`return(...)` payload chains.

That supported branch-local control-flow equivalence is now locked on lifecycle surfaces too, not just action edges: chained forms like `LX.if(...).m(...).endif()` and structured lifecycle blocks like `LX { if(...); m(...); endif() }` now agree on lowering and migration metadata for the supported payload shapes.

Supported multi-step method sequences inside action-edge control-flow bodies are locked too, not just single payload-return branches: fluent and structured forms now agree on compiled output and migration metadata when branch bodies contain supported helper sequences such as `declare(...)`, `push_value(...)`, `say(...)`, and `return_*` combinations.

That same supported multi-step branch-local equivalence is now locked on lifecycle surfaces too: `LX.if(...).declare(...).push_value(...).return_*...endif()` and the structured `LX { if(...); declare(...); push_value(...); return_*... endif() }` form, as well as the parallel `switch/case` forms, now agree on lowered lifecycle output and migration metadata for those supported helper sequences.

Inline composite `switch(..., case(...), default(...))` forms are now locked on both action-edge and lifecycle surfaces too: fluent and structured authoring agree not only for marker-style `case()/default()/endswitch()` flow, but also for supported inline `case(...)` and `default(...)` action sequences inside the `switch(...)` argument list itself.

That inline-composite switch surface now has its first structured branch-body extension too: `case(value, { ... })` and `default({ ... })` are supported alongside the older explicit action-list form, so compact inline dispatch can still carry semicolonless structured helper sequences without falling back to raw Perl.

That same switch surface now supports attached-block branch sugar too: `case(value) { ... }`, `default() { ... }`, and the lighter `default { ... }` alias all lower to the same canonical result as the structured-argument `case(value, { ... })` / `default({ ... })` form, and structured marker-style `switch(...) ... case(...) ... default() ... endswitch()` blocks now accept the same attached branch bodies on both action-edge and lifecycle surfaces.

That same family now has a block-bodied outer switch form too: `switch(expr) { case(value) { ... } default { ... } }` lowers equivalently to the inline composite switch attached-branch-block surface on both action-edge and lifecycle blocks. Treat it as the structured outer-body sibling of the already-supported inline composite switch forms rather than as marker-style `endswitch()` sugar.

Inside that outer block, you can now use either attached branch blocks or plain marker branches. In other words, both `case(value) { ... }` / `default { ... }` and the lighter `case(value) ... default ...` style are part of the supported outer attached-block switch surface.

That same outer attached-block switch family now allows mixed per-branch carriers too. In practice that means shapes like `switch(expr) { case("A") { ... } case("B") ... default { ... } }` are supported on both structured and final-call fluent surfaces, so one branch can use an attached block while the next uses a lighter plain marker body without forcing the whole switch into one carrier style.

That same outer attached-block switch surface is now available as the final call on fluent action-edge and lifecycle chains too. In practice that means surfaces like `-> rule .switch(expr) { ... }` and `I.switch(expr) { ... }` now lower through the same canonical switch path as the structured outer-block baseline instead of dropping the branch body.

The attached-block composite `if(...)` surface got the same punctuation-light follow-up: `if(cond) { ... } elseif(cond2) { ... } else() { ... }` still works, and `else { ... }` is now accepted as an equivalent lower-friction alias for the final branch body. That same attached-block composite `if(...)` surface is now available as the final call on fluent action-edge and lifecycle chains too, so surfaces like `-> rule .if(cond) { ... } elseif(cond2) { ... } else { ... }` and `I.if(cond) { ... } elseif(cond2) { ... } else { ... }` now lower through the same canonical path as the structured baseline instead of dropping the trailing branches.

That same attached-block composite `if(...)` family now allows mixed per-branch carriers too. In practice that means shapes like `if(cond) { ... } elseif(cond2) ... else { ... }` are supported on both structured and final-call fluent surfaces, so each branch can choose either an attached block or a lighter plain marker body without forcing the whole chain into one carrier style.

Those attached switch branch blocks are real structured block contexts, not just flat helper carriers. In practice that means they can now hold nested marker-style flow such as `if(...) ... endif()` while preserving the same zero-fallback, zero-unresolved migration metadata as the already-supported flat branch-body forms.

That same structured-context rule now has explicit regression coverage for nested marker-style switch flow too. An attached switch branch block can itself contain `switch(...) ... case(...) ... default() ... endswitch()` and still preserve the same language-agnostic rewrite readiness on both action-edge and lifecycle surfaces.

That same attached-switch structured-context rule now covers the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, not only the simpler single-`case(...)` marker-switch shape.

That broader nested marker-switch shape is now parity-locked across the two inline-switch structured branch-body carriers too. `case(value, { ... })` and `case(value) { ... }` now lower identically there on both action-edge and lifecycle surfaces, not just on the earlier flat helper-only branch-body baseline.

That same parity contract now explicitly includes the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting shape too. The two supported inline-switch structured branch-body carriers stay aligned there as well, on both action-edge and lifecycle surfaces.

That same inline-switch branch-carrier parity now also covers nested composite `if(...)` / `elseif(...)` flow when those inner branches themselves carry the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting shape. `case(value, { ... })` and `case(value) { ... }` stay aligned there too on both action-edge and lifecycle surfaces.

The marker-style outer switch surface now has the matching parity lock too. Plain `case(value)` branch bodies and attached `case(value) { ... }` branch bodies stay aligned for that same deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract, on both action-edge and lifecycle surfaces.

That same marker-style branch-carrier parity now also covers nested composite `if(...)` / `elseif(...)` flow when those inner branches themselves carry that deeper alternating marker `if(...) ... switch(...) ... endif()` nesting shape. Plain `case(value)` branches and attached `case(value) { ... }` branches stay aligned there too on both action-edge and lifecycle surfaces.

That same deeper alternating marker contract now spans the two outer switch families themselves too. An attached `case(value) { ... }` or `default() { ... }` branch block now stays aligned between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms on both action-edge and lifecycle surfaces.

That same outer-switch-family parity contract now also covers nested composite `if(...)` / `elseif(...)` flow when those inner branches themselves carry the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting shape. Attached `case(value) { ... }` and `default() { ... }` branch blocks stay aligned there too between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms on both action-edge and lifecycle surfaces.

That same broader nested marker-switch shape is now parity-locked on structured marker-style outer switch surfaces too. Plain marker branches like `case(value)` / `default()` and attached branch-block sugar like `case(value) { ... }` / `default() { ... }` now lower identically there on both action-edge and lifecycle surfaces, not just on the earlier flat helper-only branch-body baseline.

That same broader nested multi-`case(...)` marker-switch shape now spans the two outer switch families themselves too. Attached branch blocks `case(value) { ... }` and `default() { ... }` now stay aligned there between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms on both action-edge and lifecycle surfaces.

That same cross-family parity now covers the broader nested multi-`case(...)` inline-composite `switch(...)` shape too. Attached branch blocks `case(value) { ... }` and `default() { ... }` now stay aligned there between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms on both action-edge and lifecycle surfaces.

That same local structured-branch parity now covers nested composite `if(...)` / `elseif(...)` flow on inline composite switch surfaces too. Structured argument carriers `case(value, { ... })` / `default({ ... })` and attached branch-block carriers `case(value) { ... }` / `default() { ... }` now stay aligned there on both action-edge and lifecycle surfaces, not only on nested switch-only bodies.

That same local structured-branch parity now covers the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside those nested composite `if(...)` / `elseif(...)` branches on inline composite switch surfaces too. The two inline composite switch branch-body carriers now stay aligned there on both action-edge and lifecycle surfaces, not only on the plain nested composite-if shape.

That same local structured-branch parity now also covers the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside those nested composite `if(...)` / `elseif(...)` branches on inline composite switch surfaces too. The two inline composite switch branch-body carriers now stay aligned there on both action-edge and lifecycle surfaces, not only across attached switch branch blocks.

That same local structured-branch parity now covers nested composite `if(...)` / `elseif(...)` flow on marker-style outer switch surfaces too. Plain marker branches like `case(value)` / `default()` and attached branch-block sugar like `case(value) { ... }` / `default() { ... }` now stay aligned there on both action-edge and lifecycle surfaces, not only on nested switch-only bodies.

That same local structured-branch parity now covers the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside those nested composite `if(...)` / `elseif(...)` branches on marker-style outer switch surfaces too. Plain marker branches and attached branch-block sugar now stay aligned there on both action-edge and lifecycle surfaces, not only on the plain nested composite-if shape.

That same local structured-branch parity now also covers the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside those nested composite `if(...)` / `elseif(...)` branches on marker-style outer switch surfaces too. Plain marker branches and attached branch-block sugar now stay aligned there on both action-edge and lifecycle surfaces, not only across attached switch branch blocks.

That same cross-family parity now covers nested composite `if(...)` / `elseif(...)` flow too. Attached branch blocks `case(value) { ... }` and `default() { ... }` now stay aligned there between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms on both action-edge and lifecycle surfaces, not only on bare nested-switch bodies.

That same structured-context rule now covers nested composite `if(...)` forms there too. An attached switch branch block can hold either inline composite `if(cond, ..., elseif(...), else(...))` flow or the attached-block composite form `if(cond) { ... } elseif(cond2) { ... } else() { ... }`, on both inline composite and marker-style outer switch surfaces, while preserving the same zero-fallback, zero-unresolved migration metadata.

That same attached-switch structured-context rule is now locked one level deeper too. On both outer switch families, attached switch branch blocks preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow.

That same deeper attached-switch parity now covers nested marker-style `switch(...) ... endswitch()` flow inside those deeper `if/elseif/else` branches too, not only nested inline-composite `switch(...)` flow.

That same attached-switch parity now covers the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside those deeper `if/elseif/else` branches too, not only the simpler single-`case(...)` nested inline-switch shape.

That broader multi-`case(...)` nested inline-switch parity now spans both outer switch families too: inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms now both preserve the same inner composite-`if/elseif/else` parity on that broader nested shape.

That same broader nested inline-switch shape now has a direct outer-family lock too on the common attached branch-block carrier: an attached `case(value) { ... }` or `default() { ... }` branch block now stays aligned between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms even when those deeper branch bodies mix inline composite and attached-block composite `if/elseif` surfaces around that multi-`case(...)` nested inline switch shape.

That same deeper attached-switch parity now covers the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, across both outer switch families, not only the simpler single-`case(...)` marker-switch shape.

That same broader nested marker-switch shape now has the matching direct outer-family lock too on the common attached branch-block carrier: an attached `case(value) { ... }` or `default() { ... }` branch block now stays aligned between inline composite outer `switch(...)` forms and marker-style outer `switch(...) ... endswitch()` forms even when those deeper branch bodies mix inline composite and attached-block composite `if/elseif` surfaces around that multi-`case(...)` nested marker-style switch shape.

More generally, marker-style `if(...) ... endif()` and marker-style `switch(...) ... endswitch()` are intended to allow arbitrarily deep mutual nesting in structured block contexts. The current regression suite now locks a representative deeper alternating chain across action-edge and the full lifecycle family, and the same deeper alternating contract is now also pinned inside attached switch branch blocks plus both structured inline and attached-block composite `if(...)` branch bodies. In other words, the language does not impose a fixed semantic nesting cap here; the only practical limits are the usual runtime recursion and resource ceilings.

That same attached-switch structured-context rule now covers nested inline-composite `switch(...)` forms there too. An attached `case(value) { ... }` or `default() { ... }` branch block can itself carry inline-composite `switch(...)` flow on both outer switch families and still preserve the same language-agnostic rewrite readiness.

That nested composite-`if(...)` contract is now locked more deeply too. Inside attached switch branch blocks, both outer switch families now have explicit regression coverage not only for simple nested `if/else` composite forms, but also for the deeper `if/elseif/else` composite shape.

That nested inline-composite `switch(...)` contract is now locked more deeply too. Inside attached switch branch blocks, both outer switch families now have explicit regression coverage not only for the simple one-`case(...)` nested switch shape, but also for broader nested inline switches with multiple `case(...)` arms plus `default(...)`.

That same deeper nested inline-switch coverage now exists inside composite `if(...)` branch bodies too. Both the structured inline composite `if(...)` branch-block form and the attached-block composite `if(...)` form are now regression-locked not only for the simpler one-`case(...)` nested inline switch shape, but also for broader nested inline switches with multiple `case(...)` arms plus `default(...)`.

The `if(...)` family now has the matching structured attached-block form too. Inside an action-edge `{ ... }` block or any lifecycle block (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`), you can write `if(cond) { ... } elseif(cond2) { ... } else() { ... }` and get the same canonical lowering and migration metadata as the already-supported inline composite `if(cond, ..., elseif(...), else(...))` surfaces. That same attached-block composite surface is now also available as the final call on fluent action-edge and lifecycle chains. Treat it as a supported final-call fluent control-flow surface, not as permission for unconstrained marker-style flow outside structured contexts.

List-context insertion helpers are locked too: fluent and structured authoring now agree on supported `flat_array(...)` and `flat_hash(...)` payload forms on both action-edge and lifecycle surfaces, so flat-list insertion stays part of the same method-like DSL equivalence contract rather than a one-off lowering quirk. The supported source side now also includes composed aggregate helpers such as `sorted_keys(...)`, `sorted_values(...)`, `pick_keys(...)`, and `hash_copy(...)`, not only one named working array or hash.

That same supported flat-list equivalence is now locked inside control-flow branch bodies too: fluent and structured `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` forms agree on `flat_array(...)` and `flat_hash(...)` return payloads on both action-edge and lifecycle surfaces.

Snapshot payload helpers are locked too: fluent and structured authoring now agree on supported `array_copy(...)` and compatibility `array_values(...)` payload forms on both action-edge and lifecycle surfaces, so snapshot-array payload construction stays inside the same method-like DSL equivalence contract as the preferred and compatibility spellings evolve.

That same supported snapshot-helper equivalence is now locked inside control-flow branch bodies too: fluent and structured `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` forms agree on `array_copy(...)` and `array_values(...)` return payloads on both action-edge and lifecycle surfaces.

String-join payload helpers are locked too: fluent and structured authoring now agree on supported `join_values(delimiter, array_expr)` payload forms on both action-edge and lifecycle surfaces, so joined-string payload construction stays inside the same method-like DSL equivalence contract rather than acting like a one-off scalar shortcut.

That same supported `join_values(...)` equivalence is now locked inside control-flow branch bodies too: fluent and structured `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` forms agree on joined-string return payloads on both action-edge and lifecycle surfaces. The supported source side is broader than one named array variable: projected arrays like `sorted_keys(...)`, `sorted_values(...)`, and array-valued fallback chains can now reduce straight into one scalar string as well.

Canonical `call(rule)` value capture is locked too: fluent and structured authoring now agree on supported `assign(scalar(retv), call(rule))` helper forms on both action-edge and lifecycle surfaces, so child-result capture stays inside the same backend-neutral method-like DSL equivalence contract rather than depending on raw assignment wrappers.

That same supported call-value equivalence is now locked inside control-flow branch bodies too: fluent and structured `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` forms agree on canonical `assign(scalar(retv), call(rule))` capture chains on both action-edge and lifecycle surfaces.

Nested accessor payloads are locked too: fluent and structured authoring now agree on supported `scalaref(base, path)` plus indexed/keyed `scalar(...)` payload reads on both action-edge and lifecycle surfaces, so path-following value composition stays inside the same backend-neutral method-like DSL equivalence contract.

Array-normalization pipelines are locked too: fluent and structured authoring now agree on representative `split(...) -> split_each(...) -> trim_each(...) -> filter_nonempty(...) -> return(array_copy(...))` flows on both action-edge and lifecycle surfaces, so multi-stage token cleanup stays inside the same backend-neutral method-like DSL equivalence contract instead of feeling like a one-off migration detail from the VHDL corpus.

Case-normalization and filter pipelines are locked too: fluent and structured authoring now agree on representative `assign(array(parts), filter_match(uniq(uppercase_each(array(IMATCH_LIST))), /^A/)) -> lowercase_each(array(parts)) -> return(array_copy(array(parts)))` flows on both action-edge and lifecycle surfaces, so uppercase/uniq/filter/lowercase cleanup is also part of the explicit backend-neutral method-like DSL contract rather than only low-level array-pipeline lowering machinery.

Defaulting/coalescing value helpers are now part of that explicit contract too: fluent and structured authoring now agree on representative `coalesce(...)` fallback chains across assignment sources, return payloads, and comparison inputs on both action-edge and lifecycle surfaces, so parser-oriented “first defined value wins” logic no longer needs to hide inside ad hoc raw fallback expressions.

That scalar-defaulting family is broader now too: `coalesce_nonempty(...)` lets `.spec` rules skip only missing or blank scalar values while still preserving `0` and other defined nonempty values, so “use the first real text after normalization” can stay inside the same functional expression layer without branching.

Definedness flow helpers are part of that same contract too: `is_defined(...)` and `is_undefined(...)` now give the DSL an explicit way to distinguish “missing” from “empty” across scalar fields, nested payload access, and fallback chains, instead of forcing users to blur presence checks together with `is_empty(...)` / `is_nonempty(...)`.

Scalar normalization helpers are part of that explicit contract too: `trim(...)`, `lowercase(...)`, and `uppercase(...)` now compose canonically across assignment sources, return payloads, and comparison inputs on both action-edge and lifecycle surfaces, so ordinary text cleanup can stay inside the backend-neutral value-expression layer instead of leaking into ad hoc raw string handling.

Pure scalar assembly is part of that same contract too: `concat(...)` now lets `.spec` rules build canonical string values from normalized scalar fragments across assignment sources, direct `return(payload)` expressions, and comparison inputs on both action-edge and lifecycle surfaces, so string construction no longer needs temporary array staging or ad hoc host-language interpolation.

Scalar boundary transforms are part of that same contract too: `rm_prefix(...)` and `rm_suffix(...)` now let `.spec` rules strip one literal leading or trailing marker from normalized scalar values across assignments, direct `return(payload)` expressions, and comparison inputs, so common name-cleanup work can stay inside pure value expressions instead of leaking into ad hoc raw string code.

Array-to-scalar reduction is part of that contract too: `count(...)` now lets `.spec` rules derive canonical size metadata from array variables and array-valued fallback expressions on both action-edge and lifecycle surfaces, so ordinary size-based branching and return metadata can stay inside the same parser-oriented expression layer.

Hash/object-to-scalar reduction is part of that contract too: `count_keys(...)` now lets `.spec` rules derive canonical key-count metadata from working hashes and hash-valued fallback expressions on both action-edge and lifecycle surfaces, so ordinary object-shape branching and return metadata can stay inside that same parser-oriented expression layer.

Hash/object key-presence checks are part of that contract too: `has_key(...)` now lets `.spec` rules ask whether a field exists at all, across working hashes and hash-valued fallback expressions on both action-edge and lifecycle surfaces, so object-shape checks no longer need to blur together with value-definedness checks.

Hash/object layering is part of that contract too: `merge_hash(...)` now lets `.spec` rules build one canonical merged object from working hashes, constructor hashes, and hash-valued fallback expressions on both action-edge and lifecycle surfaces, so parser-owned metadata normalization can stay inside the same functional, parser-oriented expression layer instead of leaking into ad hoc host-language object merging.

Hash/object snapshotting is part of that contract too: `hash_copy(...)` now lets `.spec` rules keep one stable nested object snapshot from a working hash or composed hash-valued expression on both action-edge and lifecycle surfaces, so nested payload construction and later helper composition can stay inside the same functional, parser-oriented expression layer instead of dropping into ad hoc host-language `{%hash}` copies.

Hash/object single-field update is part of that contract too: `set_key(...)` now lets `.spec` rules set one canonical field on working hashes and hash-valued expressions on both action-edge and lifecycle surfaces, so small object-shape adjustments can stay inside the same functional, parser-oriented expression layer instead of forcing a one-key merge wrapper or dropping into ad hoc host-language field assignment.

Hash/object single-field rename is part of that contract too: `rename_key(...)` now lets `.spec` rules rename one canonical field on working hashes and hash-valued expressions on both action-edge and lifecycle surfaces, so field-name normalization can stay inside the same functional, parser-oriented expression layer instead of forcing a manual delete-plus-set sequence or dropping into ad hoc host-language field reassignment.

Hash/object cleanup is part of that contract too: `drop_keys(...)` now lets `.spec` rules remove noisy fields from working hashes and hash-valued expressions on both action-edge and lifecycle surfaces, so canonical return-payload cleanup can stay inside the same functional, parser-oriented expression layer instead of mutating one source hash or dropping into ad hoc host-language delete logic.

Hash/object projection is part of that contract too: `pick_keys(...)` now lets `.spec` rules keep only one explicit field set from richer working hashes and hash-valued expressions on both action-edge and lifecycle surfaces, so stable outward-facing payload shapes can stay inside that same functional, parser-oriented expression layer instead of relying on ad hoc field-copy code.

Stable hash/object-to-array projection is part of that contract too: `sorted_keys(...)` now lets `.spec` rules derive one deterministic key-list array from working hashes and hash-valued expressions on both action-edge and lifecycle surfaces, so object-shape summaries can flow back into the array-oriented helper family without leaning on host-language hash iteration behavior.

Control-flow syntax itself is still open for ergonomics work. The guides currently show the syntax that is supported today, but that does not mean forms like `else();` and `endif()` are the final UX target; the roadmap explicitly keeps a follow-up open to revisit `if` / `else` / `switch` concrete syntax, reduce punctuation friction, and evaluate more natural block-style and inline-composite authoring forms.

One punctuation-reduction slice has already landed: in structured marker-style control-flow blocks, the zero-arg markers `else`, `endif`, `default`, `endcase`, and `endswitch` are now accepted as bare-keyword aliases for `else()`, `endif()`, `default()`, `endcase()`, and `endswitch()`.

That same punctuation-light treatment now explicitly covers fluent chains too: `.else`, `.endif`, `.default`, `.endcase`, and `.endswitch` are supported as lower-friction aliases for `.else()`, `.endif()`, `.default()`, `.endcase()`, and `.endswitch()` on both action-edge and lifecycle surfaces.

That follow-up is no longer only about future `switch(...)` work: the first inline composite `if(...)` slice is now supported too, so compact forms like `if(cond, action1(...), action2(...), elseif(cond2, ...), else(...))` already lower through the same canonical control-flow path as the older marker-style `if()/elseif()/else()/endif()` baseline.

That inline-composite `if(...)` surface now has its first structured branch-body extension too: `if(cond, { ... }, elseif(cond2, { ... }), else({ ... }))` is supported alongside the older explicit action-list form, so compact conditional flow can still carry semicolonless structured helper sequences without falling back to raw Perl.

That same structured branch-block path now keeps full rewrite readiness for nested marker-style switch flow too. In practice that means both `if(cond, { switch(...) ... endswitch() }, else({ ... }))` and `if(cond) { switch(...) ... endswitch() } else() { ... }` preserve zero fallback, zero unresolved-helper hits, and the same lifecycle-family parity as the simpler flat helper sequences.

That nested marker-style `switch(...) ... endswitch()` coverage inside composite-`if(...)` branch bodies now explicitly includes broader multi-`case(...)` shapes too, not only the simpler single-`case(...)` form.

That same composite-`if(...)` nested marker-switch contract now explicitly includes the deeper `if/elseif/else` branch shape too, not only the simpler `if/else` shape.

That same deeper composite-`if/elseif/else` branch shape is now regression-locked for nested inline-composite `switch(...)` flow too, not only nested marker-style `switch(...) ... endswitch()` flow.

That same deeper composite-`if/elseif/else` branch shape now covers the broader multi-`case(...)` nested inline-composite `switch(...)` form too, not only the simpler single-`case(...)` nested inline-switch shape.

That same deeper composite-`if/elseif/else` branch shape now covers the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` form too, not only the simpler single-`case(...)` marker-switch shape.

That nested-switch support is broader than marker-style `switch(...) ... endswitch()` now. The same composite-`if(...)` branch-body surfaces are regression-locked for nested inline-composite `switch(...)` forms too, including the attached switch-branch sugar `case(value) { ... }` / `default() { ... }`.

Those inline composite control-flow forms are now regression-locked across the full lifecycle family too, not only on the earlier `LX` proof point. That means `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX` all now carry the same lifecycle-wide support for:
- inline composite `if(cond, ..., elseif(...), else(...))`
- structured inline-composite `if(cond, { ... }, elseif(..., { ... }), else({ ... }))`
- inline composite `switch(expr, case(...), default(...))`
- structured inline-composite `switch(expr, case(value, { ... }), default({ ... }))`
- attached-block inline-composite `switch(expr, case(value) { ... }, default() { ... })`
- attached-block marker-style `switch(expr) case(value) { ... } default() { ... } endswitch()`

One boundary is now explicit in the roadmap too: marker-style `if(...) ... endif()` and `switch(...) ... endswitch()` are being treated as structured-block-context syntax, not as a permanently free-standing fluent surface. That means they belong inside method-only structured blocks such as action-edge `{ ... }`, lifecycle blocks like `I { ... }` / `LS { ... }` / `LE { ... }` / `E { ... }` / `EX { ... }` / `IT { ... }` / `LX { ... }`, and nested structured branch bodies like `case(value, { ... })` or `case(value) { ... }`. By contrast, self-contained composite forms such as `switch(expr, case(...), default(...))` and `if(cond, ..., elseif(...), else(...))` remain single-call control-flow forms.

## Runtime Match Values You Will See Repeatedly
A lot of lowering examples refer to a small set of parser runtime values.

- `IMATCH`
  - the current immediate match text.
- `cursor_line()`
  - helper form that reads the current parser cursor line directly when an explicit helper spelling is clearer than manual newline counting.
- `entry_text()`
  - helper form that reads the current immediate match text directly when an explicit helper spelling is clearer than the bare runtime value.
- `entry_line()`
  - helper form that reads the current immediate match line directly when an explicit helper spelling is clearer than manual newline counting around `IMATCH`.
- `entry_start_line()`
  - explicit start-edge alias for `entry_line()` when the surrounding helper family should read symmetrically with `entry_start_pos()` and `entry_end_*()`.
- `entry_col()`
  - helper form that reads the current immediate match column directly when an explicit helper spelling is clearer than manual same-line arithmetic around the immediate-match start edge.
- `entry_start_col()`
  - explicit start-edge alias for `entry_col()` when the surrounding helper family should read symmetrically with `entry_start_pos()` and `entry_end_*()`.
- `entry_group(index)`
  - helper form that reads one capture group from the current immediate match directly when an explicit helper spelling is clearer than bare `IMATCH_LIST` indexing.
- `entry_groups()`
  - helper form that snapshots the whole current immediate-match capture-group list directly when an explicit helper spelling is clearer than `array(IMATCH_LIST)`.
- `entry_named(name)`
  - helper form that reads one named capture from the current immediate match directly when an explicit helper spelling is clearer than bare `IMATCH_HASH` lookup.
- `entry_map()`
  - preferred helper form that snapshots the whole current immediate-match named-capture hash directly when an explicit helper spelling is clearer than passing raw `IMATCH_HASH` around.
- `entry_named_map()`
  - compatibility alias for `entry_map()`.
- `entry_len()`
  - helper form that reads the width of the current immediate match directly when an explicit helper spelling is clearer than bare runtime value arithmetic.
- `entry_start_pos()`
  - helper form that reads the left edge of the current immediate match directly when an explicit helper spelling is clearer than the bare runtime value arithmetic.
- `entry_end_pos()`
  - helper form that reads the right edge of the current immediate match directly when an explicit helper spelling is clearer than the bare runtime value arithmetic.
- `entry_end_line()`
  - helper form that reads the 1-based line number of the right edge of the current immediate match directly when an explicit helper spelling is clearer than manual newline counting around `entry_end_pos()`.
- `entry_end_col()`
  - helper form that reads the 1-based column number of the right edge of the current immediate match directly when an explicit helper spelling is clearer than manual same-line arithmetic around `entry_end_pos()`.
- `LMATCH`
  - the latest closing-side match text.
- `match_text()`
  - helper form that reads the current local match text directly when an explicit helper spelling is clearer than the bare runtime value.
- `match_line()`
  - helper form that reads the current local match line directly when an explicit helper spelling is clearer than manual newline counting around `LMATCH`.
- `match_start_line()`
  - explicit start-edge alias for `match_line()` when the surrounding helper family should read symmetrically with `match_start_pos()` and `match_end_*()`.
- `match_col()`
  - helper form that reads the current local match column directly when an explicit helper spelling is clearer than manual same-line arithmetic around the local-match start edge.
- `match_start_col()`
  - explicit start-edge alias for `match_col()` when the surrounding helper family should read symmetrically with `match_start_pos()` and `match_end_*()`.
- `match_group(index)`
  - helper form that reads one capture group from the current local match directly when an explicit helper spelling is clearer than bare `LMATCH_LIST` indexing.
- `match_groups()`
  - helper form that snapshots the whole current local-match capture-group list directly when an explicit helper spelling is clearer than `array(LMATCH_LIST)`.
- `match_named(name)`
  - helper form that reads one named capture from the current local match directly when an explicit helper spelling is clearer than bare `LMATCH_HASH` lookup.
- `match_map()`
  - preferred helper form that snapshots the whole current local named-capture hash directly when an explicit helper spelling is clearer than passing raw `LMATCH_HASH` around.
- `match_named_map()`
  - compatibility alias for `match_map()`.
- `match_len()`
  - helper form that reads the width of the current local match directly when an explicit helper spelling is clearer than bare runtime value arithmetic.
- `match_end_pos()`
  - helper form that reads the right edge of the current local match directly when an explicit helper spelling is clearer than the bare runtime value arithmetic.
- `match_end_line()`
  - helper form that reads the 1-based line number of the right edge of the current local match directly when an explicit helper spelling is clearer than manual newline counting around `match_end_pos()`.
- `match_end_col()`
  - helper form that reads the 1-based column number of the right edge of the current local match directly when an explicit helper spelling is clearer than manual same-line arithmetic around `match_end_pos()`.
- `IMATCH_LIST`
  - the capture list from the current regex.
- `CAPTURE`
  - helper token representing the substring between current parser positions.
- `IPOS`
  - current start/input position marker.
- `LSPOS`
  - current latest scanner position marker.
- `$$STRING`
  - the input string reference.

Examples:

```text
assign(scalar(name), scalar(IMATCH))
assign(scalar(line_now), cursor_line())
assign(scalar(token), entry_text())
assign(scalar(entry_line_num), entry_line())
assign(array(parts), entry_groups())
assign(scalar(kind), entry_named(kind))
assign(scalar(entry_width), entry_len())
assign(scalar(match_line_num), match_line())
assign(scalar(content), CAPTURE)
return(array("?node:", scalar(IMATCH_LIST, 0), scalar(IMATCH_LIST, 1)))
assign(scalar(pos_begin), pos $$STRING)
```

Concise container aliases are supported too:
- `s(...)` = `scalar(...)`
- `a(...)` = `array(...)`
- `h(...)` = `hash(...)`

These are still LinkedSpec DSL forms, not Perl sigils.

```text
assign(s(name), entry_text())
assign(a(parts), entry_groups())
return(h("kind", entry_named(kind), "parts", a("A", "B")))
```

## Quick Navigation by Task
If you are trying to do one of these jobs, read the matching guide first.

### I need declarations or initialized working state
Start with [`USER_GUIDE_ActionIR_DeclareMethod.md`](USER_GUIDE_ActionIR_DeclareMethod.md).

Typical patterns:
- `declare(array, items)`
- `declare(scalar, flag=or(scalar(on), scalar(off)))`
- `declare(hash, by_name=hash("kind", scalar(kind)))`

### I need value constructors, nested return payloads, or `call(...)` as a value source
Start with [`USER_GUIDE_ActionIR_MethodLowering.md`](USER_GUIDE_ActionIR_MethodLowering.md).

Typical patterns:
- `array(...)`
- `hash(...)`
- `scalaref(...)`
- `scalar(sorted_keys(...), 0)`
- `scalar(merge_hash(...), "kind")`
- `scalar(set_key(...), "stage")`
- `scalar(rename_key(...), "stage")`
- `length(...)`
- `replace_substr(...)`
- `rm_prefix(...)`
- `rm_suffix(...)`
- `concat(...)`
- `starts_with(...)`
- `ends_with(...)`
- `contains_substr(...)`
- `join_values(...)`
- `first(...)`
- `last(...)`
- `index_of(...)`
- `take(...)`
- `take(..., n)`
- `slice(..., start)`
- `slice(..., start, n)`
- `take_last(...)`
- `take_last(..., n)`
- `drop_front(...)`
- `drop_front(..., n)`
- `drop_back(...)`
- `drop_back(..., n)`
- compatibility `tail(...)`
- compatibility `tail(..., n)`
- compatibility `drop_last(...)`
- compatibility `drop_last(..., n)`
- `concat_arrays(...)`
- `array_copy(...)`
- `hash_copy(...)`
- `flat_array(...)`
- `assign(scalar(retv), call(rule))`
- `return(array(...))`

### I need a long scalar/array/hash composition cookbook with many examples
Start with [`USER_GUIDE_ActionIR_ScalarAggregateMethods.md`](USER_GUIDE_ActionIR_ScalarAggregateMethods.md).

Typical patterns:
- string scalars from `scalar(...)`, `CAPTURE`, `concat(...)`, and `join_values(...)`
- one-step reads from composed aggregates via `scalar(sorted_keys(...), 0)` and `scalar(merge_hash(...), "kind")`
- single-field object updates via `set_key(hash_expr, key_expr, value_expr)`
- single-field object renames via `rename_key(hash_expr, old_key_expr, new_key_expr)`
- nonempty scalar fallback chains via `coalesce_nonempty(value1, value2, ..., valueN)`
- scalar metadata from `length(scalar_expr)`
- scalar literal rewrites from `replace_substr(scalar_expr, needle_expr, replacement_expr)`
- scalar boundary rewrites from `rm_prefix(scalar_expr, prefix_expr)` and `rm_suffix(scalar_expr, suffix_expr)`
- scalar prefix/suffix flags from `starts_with(scalar_expr, prefix_expr)` and `ends_with(scalar_expr, suffix_expr)`
- scalar substring-membership flags from `contains_substr(scalar_expr, needle_expr)`
- scalar emptiness flags from `is_empty(value_expr)` and `is_nonempty(value_expr)` inside both assignments and `return(payload)`
- boundary scalars from `first(array_expr)` and `last(array_expr)`
- first-match scalar indices from `index_of(array_expr, needle_expr)` over direct and composed array-valued expressions
- prefix arrays from `take(array_expr)` and counted prefix arrays from `take(array_expr, scalar(take_count))`
- middle-window arrays from `slice(array_expr, scalar(slice_start))` and bounded middle-window arrays from `slice(array_expr, scalar(slice_start), scalar(slice_count))`
- suffix arrays from `take_last(array_expr)` and counted suffix arrays from `take_last(array_expr, scalar(take_last_count))`
- front-drop arrays from `drop_front(array_expr)` and counted front-drop arrays from `drop_front(array_expr, scalar(skip_count))`
- back-drop arrays from `drop_back(array_expr)` and counted back-drop arrays from `drop_back(array_expr, scalar(drop_count))`
- compatibility tail arrays from `tail(array_expr)` and counted compatibility tail arrays from `tail(array_expr, scalar(skip_count))`
- compatibility trailing-drop arrays from `drop_last(array_expr)` and counted compatibility trailing-drop arrays from `drop_last(array_expr, scalar(drop_count))`
- pure array layering via `concat_arrays(array_expr, array_expr, ...)`
- deterministic array sorting via `sorted(array_expr)` over direct or composed array-valued expressions
- pure array order inversion via `reversed(array_expr)` over direct or composed array-valued expressions
- integer/float-like scalars carried through `declare(...)`, `assign(...)`, and `num_*` comparisons
- array constructors and snapshots via `array(...)` and `array_copy(...)`
- hash/object constructors and snapshots via `hash(...)` and `hash_copy(...)`
- stable hash/object summaries via `sorted_keys(...)` and `sorted_values(...)`
- array membership flags via `contains(array_expr, value_expr)`
- aggregate-shape emptiness checks via `is_empty(sorted_values(...))` and `is_nonempty(pick_keys(...))`
- nested reads via `scalar(array(...), idx)` and `scalaref(...)`
- deep Lisp-style composition inside `declare(...)`, `assign(...)`, `return(...)`, `if(...)`, and `switch(...)`

### I need assignment semantics or special assignment sources
Start with [`USER_GUIDE_ActionIR_ValueExpr.md`](USER_GUIDE_ActionIR_ValueExpr.md).

Typical patterns:
- `assign(scalar(name), CAPTURE)`
- `assign(scalar(retv), call(Leaf))`
- `assign(array(items), array(scalar(retv)))`
- `assign(hash(by_name), hash("k", scalar(v)))`

### I need boolean/comparison expressions
Start with [`USER_GUIDE_ActionIR_FlowExpr.md`](USER_GUIDE_ActionIR_FlowExpr.md).

Typical patterns:
- `or(...)`, `and(...)`, `not(...)`
- `is_empty(...)`, `is_nonempty(...)`
- `eq/ne/gt/ge/lt/le`
- `num_eq/...`
- `matches(...)`
- `contains_substr(...)`
- `eq(replace_substr(...), "...")`

### I need `if/else` or `switch/case` lowering
Start with [`USER_GUIDE_ActionIR_ControlFlow.md`](USER_GUIDE_ActionIR_ControlFlow.md).

Typical patterns:
- `if(...); ... else(); ... endif()`
- `switch(...); case(...); default(); endswitch()`
- `switch(expr, case(...), default(...))`
- `say(...)`, `print(...)`, `return_undef()`

### I need array tokenization or array post-processing
Start with [`USER_GUIDE_ActionIR_ArrayPipeline.md`](USER_GUIDE_ActionIR_ArrayPipeline.md).

Typical patterns:
- `split(...)`
- `split_each(...)`
- `trim_each(...)`
- `filter_nonempty(...)`
- `lowercase_each(...)`, `uppercase_each(...)`
- `uniq(...)`
- `filter_match(...)`

### I need legacy helper wrappers or capture/backtrack helpers
Start with [`USER_GUIDE_ActionIR_Contracts.md`](USER_GUIDE_ActionIR_Contracts.md).

Typical patterns:
- `call(rule)` as a standalone dispatch helper
- `push(rule)` / `push(rule, target)`
- `return_a`, `return_m`, `return_ma`
- `return_imatch`, `return_array`
- `$CAPTURE`, `capture_if(...)`, `BACKTRACK()`, `IBACKTRACK()`

Important boundary:
- `BACKTRACK()` and `IBACKTRACK()` are local cursor-rewind helpers.
- They are not a full parser-engine backtracking facility.
- LinkedSpec currently assumes a mostly forward-moving rule/runtime model, so well-written `.spec` files should rely on explicit rule structure and only use local backtrack helpers where needed.

### I need the exact emitted Perl for every currently supported construct
Start with [`USER_GUIDE_ActionIR_EmittedPerlReference.md`](USER_GUIDE_ActionIR_EmittedPerlReference.md).

This is the exhaustive review document. It covers:
- preferred canonical helper forms,
- older compatibility helpers such as `return_a`, `return_m`, `return_ma`, `capture_if`, and raw call wrappers,
- classified pass-through idioms that are preserved verbatim but still count as canonical ActionIR rather than `RAW_PERL` fallback.

## Most Common Canonical Patterns
These are the patterns you will use over and over again.

### Pattern 1: declare state, call a child, keep the result

```text
I {declare(array, items); declare(scalar, retv)}
-> child {
  assign(scalar(retv), call(child));
  push_value(array(items), scalar(retv))
}
```

Use this when you need the child result more than once, or when you need to branch on it before deciding where to store it.

### Pattern 2: assign a captured substring and return a structured node

```text
I {declare(scalar, content)}
-> block[1] {
  assign(scalar(content), CAPTURE);
  return(hash("type", "BLOCK", "content", scalar(content)))
}
```

Use this when you are closing a delimited construct and want a canonical object/hash payload.

### Pattern 3: accumulate tokens, then snapshot them in a return payload

```text
I {declare(array, parts)}
-> piece {push_value(array(parts), scalar(IMATCH))}
-> Top[1] {return(array("?Top:", array_copy(array(parts))))}
```

Prefer `array_copy(array(parts))` when you want a **snapshot array payload**.
`array_values(array(parts))` remains supported as the older compatibility spelling.

### Pattern 4: flatten an existing array into a constructor

```text
return(array("?node:", flat_array(IMATCH_LIST)))
```

Use `flat_array(...)` when you want **list-context insertion**, not an array snapshot. That now works both for one named working array and for composed array-valued helper expressions such as `sorted_keys(...)`.

That distinction is important:
- `array_copy(array(items))` means “make an array payload from the current array contents.”
- `flat_array(items)` means “splice the array elements into the surrounding constructor.”
- `flat_array(sorted_keys(hash(meta)))` means “compute a stable key-list array first, then splice those items into the surrounding constructor.”

### Pattern 5: backend-neutral recursive accumulator flow
This is the shape now used in `Lispish::parenthesis`:

```text
I {declare(array, word, tail); declare(scalar, retv, head, has_head)}

-> parenthesis {
  if(is_nonempty(array(word)))
    if(is_empty(scalar(has_head)))
      assign(scalar(head), join_values("", array(word)))
      assign(scalar(has_head), 1)
    else
      push_value(array(tail), join_values("", array(word)))
    endif
    assign(array(word), array())
  endif

  assign(scalar(retv), call(parenthesis))
  if(is_empty(scalar(has_head)))
    assign(scalar(head), scalar(retv))
    assign(scalar(has_head), 1)
  else
    push_value(array(tail), scalar(retv))
  endif
}
```

The important idea is not just recursion; it is the **canonical replacement** of older raw wrappers like `$retv = call(parenthesis)` with `assign(scalar(retv), call(parenthesis))`.

## How To Inspect Lowering
### Snippet inspection utility
Use `tools/inspect_spec_codegen.pl` when you want to see the generated Perl and canonical action-IR for a specific snippet.

Examples:
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'I.declare(array, items).declare(scalar, retv)'`
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'assign(scalar(retv), call(Leaf))'`
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'if(is_nonempty(array(items))); return(array_copy(array(items))); else(); return_undef(); endif()'`

The tool is especially useful when you are deciding between two equivalent-looking helper forms and want to confirm which one actually lowers canonically.

### Descriptor introspection with `return_descriptor => 1`
Use descriptor mode when you want to inspect rule readiness, migration metadata, or the current compiled-descriptor topology.

Typical shape:

```perl
my $descr = LinkedSpec::get_parser('Lispish', return_descriptor => 1);
my $meta  = $descr->{spec}{parenthesis}{meta}{action_rewriter};
```

High-value fields:
- `raw_perl_dependency_count`
- `raw_perl_dependency_statements`
- `unresolved_helper_count`
- `compatibility_surface_count`
- `compatibility_surface_statements`
- `compatibility_surface_contract_ids`
- `canonical_action_ir_nodes`
- `helper_action_ir_nodes`
- `language_agnostic_action_ir_ready`

Descriptor summary fields:
- `meta.action_rewriter_migration.language_agnostic_blocked_rule_count`
- `meta.action_rewriter_migration.language_agnostic_blocked_rules_by_priority`
- `meta.action_rewriter_migration.language_agnostic_top_blocked_rule`
- `meta.action_rewriter_migration.compatibility_surface_rule_count`
- `meta.action_rewriter_migration.compatibility_surface_ready_rule_count`
- `meta.action_rewriter_migration.compatibility_surface_rules_by_priority`
- `meta.action_rewriter_migration.compatibility_surface_top_rule`

Descriptor topology fields:
- `meta.descriptor_model`
- `meta.definition_order`
- `meta.compiled_rule_order`
- `meta.redefined_rule_labels`

That distinction is intentional:
- `language_agnostic_action_ir_ready = 1` means the rule no longer depends on RAW_PERL fallback or unresolved helpers,
- but a nonzero `compatibility_surface_count` still means the rule is relying on older compatibility-shaped syntax that should eventually move to canonical method-like DSL forms.

That compatibility lane now covers both:
- Perl-shaped pass-through syntax such as bare `return` / `exit` and other classified compatibility idioms,
- and older helper wrappers such as `return_a`, `return_m`, `return_ma`, `return_imatch`, `return_array`, `capture_if`, and raw call-wrapper forms.

There is one important internal-model change behind that outer descriptor shape now:

- the compiler no longer treats the legacy rule-label => info hash as its own working source of truth,
- the internal compiled-state model now lives in `LinkedSpec::CompilerState` instead of being split between `Compiler.pm` and `Validation.pm`,
- it first builds an explicit internal `compiled_spec_state`,
- default `build_dependency_regex_map(...)` now derives combined regex/dependency data from that state and can expose the result as an explicit internal `compiled_dependency_regex_state`,
- and the outward descriptor `{ spec => ..., dependency_regex_map => ... }` is now a projection of that richer internal model.

The current state-derived metadata is intentionally exposed at the descriptor boundary too:

- `meta.descriptor_model` is currently `compiled_spec_state_v1`,
- `meta.definition_order` preserves the full rule-definition sequence, including repeated labels before last-definition-wins collapse,
- `meta.compiled_rule_order` preserves the first-seen deterministic unique compiled rule order,
- `meta.redefined_rule_labels` records labels that were defined more than once while keeping the historical last-definition-wins rule map semantics.

That same state-first rule now also reaches descriptor-level migration summary generation:

- `meta.action_rewriter_migration` is now built from compiled-spec state directly rather than by bouncing back through a compatibility `spec` hash first,
- non-priority summary rule lists such as `language_agnostic_ready_rules` and `compatibility_surface_ready_rules` therefore now follow source rule order,
- while explicit priority views such as `language_agnostic_blocked_rules_by_priority` and `compatibility_surface_rules_by_priority` keep their separate triage ordering rules.

One more state-first seam now sits behind that same outer descriptor shape:

- final descriptor assembly first builds an internal `compiled_descriptor_state`,
- that state keeps the compiled-spec state plus explicit compiled-dependency-regex state together as one compiler-owned record,
- generated-descriptor validation now consumes that compiled descriptor state directly,
- that validation no longer routes back through the historical legacy `validate_dependency_regex_references(...)` entrypoint on the active compiler path,
- and only after that does the compiler project the outward `{ spec => ..., dependency_regex_map => ..., meta => ... }` descriptor.

That internal seam is mostly for compiler quality and refactor safety, but it does have one practical contract improvement:

- malformed compiled dependency-regex-map callback output is now rejected directly at final descriptor assembly with specific contract detail,
- instead of drifting further into later generated-descriptor validation before the actual shape problem is identified.

So the active compiler path now stays on one explicit internal descriptor model from:

- compiled-spec state,
- to compiled descriptor state,
- through generated-descriptor validation,
- and only then back out to the compatibility descriptor surface that older callers still consume.

Lower-level callers that already hold parsed bootstrap entries can also use `LinkedSpec::build_compiled_rule_table($entries)`. The default rule-compilation callback is owned internally by `LinkedSpec::Compiler`, so you only need to pass an explicit callback when you are intentionally overriding rule compilation behavior; normal callers should not depend on the older `LinkedSpec::spec_entry(...)` façade helper. The historical `LinkedSpec::spec_descr(...)` name is no longer part of the active surface.

If you want the compiler's richer internal model directly, `build_compiled_rule_table(...)` now also accepts `{ return_state => 1 }` and returns the explicit compiled-spec state record instead of the historical compatibility hash:

```perl
my $state = LinkedSpec::build_compiled_rule_table($entries, { return_state => 1 });

# Current shape:
# {
#   kind => 'compiled_spec_state',
#   version => 1,
#   definition_order => [ ... ],
#   compiled_rule_order => [ ... ],
#   rules_by_label => { ... },
#   redefined_rule_labels => [ ... ],
# }
```

That low-level state is mainly for advanced tooling and refactor work. Normal callers should still prefer `return_descriptor => 1`, which keeps the stable outer descriptor contract while exposing the useful state-derived metadata in `meta`.

`build_dependency_regex_map(...)` now follows the same pattern on its low-level seam. By default it returns the outward `dependency_regex_map` hash, while `{ return_state => 1 }` returns explicit compiled-dependency-regex state instead:

```perl
my $dependency_regex_state = LinkedSpec::Compiler::build_dependency_regex_map($state, { return_state => 1 });

# Current shape:
# {
#   kind => 'compiled_dependency_regex_state',
#   version => 1,
#   source_rule_order => [ ... ],
#   compiled_label_order => [ ... ],
#   dependency_regex_by_label => { ... },
# }
```

That lower-level state is mainly useful for advanced tooling and refactor work. Normal callers should still prefer `return_descriptor => 1` unless they are intentionally working inside compiler-owned seams.

The same refactor is now complete on the compatibility bridge too:

- when low-level compiler seams still receive or return historical compatibility hashes, the active path now normalizes those values through `LinkedSpec::CompilerState`,
- so that owner now defines not only the explicit state records themselves, but also the bridge from legacy compatibility shape into that state model,
- and `Compiler.pm` no longer carries a second local copy of that conversion logic beside the state owner.

That same owner boundary now covers read-side state access too:

- compiler trace/logging reads such as compiled-spec definition order and duplicate-label lists now go through `LinkedSpec::CompilerState` accessors,
- generated-descriptor validation now also consumes one owner-provided descriptor-state validation view from `LinkedSpec::CompilerState`, so rule rows, dependency-regex rows, and by-label lookup are assembled once at the owner boundary instead of being rebuilt through repeated owner dispatch from inside validation loops,
- and that validation logic now also goes through one shared validation-view engine in `Validation.pm`, so the legacy `validate_dependency_regex_references(...)` surface and the newer descriptor-state validation surface no longer carry separate copies of the same dependency-regex/rule consistency checks,
- ordered compiled-rule iteration now also goes through one `LinkedSpec::CompilerState` view rather than rebuilding it ad hoc from `compiled_rule_order + rules_by_label`,
- and compiled-spec dependency lookup during `build_dependency_regex_map(...)` now also goes through `LinkedSpec::CompilerState` helpers rather than direct compiler-side rule-map probing,
- while compiled-descriptor metadata assembly now also goes through `LinkedSpec::CompilerState` rather than `Compiler.pm` mutating owner metadata locally,
- and the `action_rewriter_migration` summary itself is now shaped inside `LinkedSpec::CompilerState` too, with `Compiler.pm` only tracing that owner-produced result,
- so `Compiler.pm` and `Validation.pm` no longer need to reach into raw compiled-state fields directly on the active path.

If you want the same structured diagnostics continuity there, `build_compiled_rule_table(...)` now also accepts an optional third argument hash like `{ runtime_ctx_ref => \$ctx }`. On that low-level surface, `build_compiled_rule_table(...)` now returns `undef` and records a normal `compiler_pipeline:build_compiled_rule_table` payload in that shared runtime context not only when a custom `compile_spec_entry(...)` callback throws or returns a malformed descriptor tuple, but also when the low-level contract itself is malformed before or during rule iteration, such as an invalid non-CODE `compile_spec_entry` callback, a non-ARRAY parsed-entry container, or a malformed individual parsed entry inside that container.

Likewise, final descriptor assembly keeps its dependency-regex compilation defaults inside `LinkedSpec::Compiler`; normal callers do not need to provide a separate `build_dependency_regex_map` callback or depend on an older `LinkedSpec::build_dependency_regex_map(...)` façade helper.

The same applies to the full compile pipeline: `LinkedSpec::Compiler::run_get_pipeline(...)` owns its default bootstrap-parse and rule-compilation callbacks internally, while `LinkedSpec::Runtime::run_get(...)` only provides the mutable runtime context needed for parser-source capture and `top_rule` propagation. `Runtime.pm` now lazy-loads `Compiler.pm` only when `run_get(...)` is actually invoked, `Compiler.pm` now lazy-loads `Trace.pm` only when `build_compiled_rule_table(...)`, `build_dependency_regex_map(...)`, or `run_get_pipeline(...)` actually starts traced compiler work, `Compiler.pm` now lazy-loads `BootstrapSpec.pm`, `SpecEntry.pm`, and `Validation.pm` only when the active compile path needs them, `BootstrapSpec.pm` now lazy-loads `BootstrapSpec::Core.pm` only when bootstrap grammar state is actually needed, `SpecEntry.pm` now lazy-loads `RuleIR.pm` only when `compile_spec_entry(...)` actually compiles a parsed rule, `SpecEntry.pm` now lazy-loads `Trace.pm` only when `compile_spec_entry(...)` actually enters traced rule compilation, `RuleIR.pm` now lazy-loads `Trace.pm` only when RuleIR diagnostics actually emit output, `RuleIR.pm` now lazy-loads `RuleIR::EmitContext.pm` only when emit-context assembly is actually needed, `RuleIR::EmitContext.pm` now lazy-loads `Trace.pm` only when unresolved-helper diagnostics actually emit output, builds its rewrite callback bundle from the extracted `ActionIR::*` owners directly, and therefore no longer loads `ActionRewriter.pm` as part of normal `Get(...)`/`compile_spec_entry(...)` compilation. The façade compatibility helper now follows that same owner path: `LinkedSpec::call_spec_handler_subst(...)` lazy-loads `RuleIR::EmitContext` rather than `ActionRewriter`, while `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` remains as a backward-compatible wrapper for direct legacy callers. `ActionRewriter`’s remaining ControlFlow, DeclareMethod, MethodExpr, FlowExpr, ArrayPipeline, MethodLowering, and ValueExpr compatibility helpers now route through `RuleIR::EmitContext` too, so require-only consumers keep `EmitContext.pm`, `ControlFlow.pm`, `DeclareMethod.pm`, `MethodExpr.pm`, `FlowExpr.pm`, `ArrayPipeline.pm`, `MethodLowering.pm`, and `ValueExpr.pm` unloaded until those helper paths are actually used. `ActionIR::Scanner.pm` now lazy-loads `ScannerCore.pm` only when contract scanning actually starts. Use `LinkedSpec::Get(...)` or `LinkedSpec::Runtime::run_get(...)`; the older raw-argument runtime wrapper and runtime `compile_spec_entry(...)` wrapper are no longer part of the active surface.

The public façade now follows the same pattern for tracing: plain `require LinkedSpec` keeps `Trace.pm` unloaded until you actually call `LinkedSpec::configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`, `trace_decision(...)`, `log_output(...)`, `log_dump(...)`, or `should_dump(...)`. The longstanding façade trace-state variables (`$LinkedSpec::DUMP_VERBOSITY`, `$LinkedSpec::TRACE_LOG_FILE`, and related settings) remain the compatibility surface.

Bootstrap parsing is now owned exclusively by `LinkedSpec::BootstrapSpec` on the active path; callers should not depend on older compiler-local bootstrap helper internals.

For focused helper-rewrite inspection, use the compatibility shim `LinkedSpec::call_spec_handler_subst(...)`. That façade entrypoint now routes through `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)`, so focused helper rewrites stay on the same extracted owner path as runtime emit-context rewriting while keeping `ActionRewriter` out of the façade load path. The same owner boundary now applies one layer lower too: `LinkedSpec::ActionRewriter` keeps the direct lower-level lowering helper surface, but its generic rewrite-orchestration wrappers now hand off to `RuleIR::EmitContext` instead of re-owning contract scan / unresolved-helper / canonical-build / canonicalize / split / rewrite-rule / diagnostic-accumulation / lower-from-canonical dispatch locally. Its stale local `_trim_action_ir_value(...)` helper is gone too, so whitespace trimming now stays on `EmitContext` and the extracted `ActionIR::*` owners only. Older internal `LinkedSpec::_...` action-rewriter, ActionIR-lowering, trace/runtime, RuleIR, and descriptor-assembly helpers are no longer part of the active surface.

Contract scanning internals are now owned by `LinkedSpec::ActionIR::Scanner` and `LinkedSpec::ActionIR::ScannerCore`; scanner-rule dependency rebinding and dispatch ordering no longer live inline in `scan_contract_ir_events(...)`, and the scanner default callback map now lives in `LinkedSpec::ActionIR::Scanner::default_deps_for_package(...)` instead of `LinkedSpec::Deps`. `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local scanner callback bundle, so the active emit-context contract-scanning path stays on the extracted scanner owner too. Statement splitting follows the same pattern: `LinkedSpec::ActionIR::StatementSplit` now owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local statement-split callback bundle. Canonical helper-event assembly now does too: `LinkedSpec::ActionIR::CanonicalEvents` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local canonical-event callback bundle, so the active canonical-event path no longer depends on the older `LinkedSpec::Deps` builder. Helper diagnostics now follow the same owner pattern: `LinkedSpec::ActionIR::Diagnostics` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local diagnostics callback bundle, so unresolved-helper and helper-event scans no longer depend on the older `LinkedSpec::Deps` diagnostics builder. Rewrite orchestration now does as well: `LinkedSpec::ActionIR::RewritePipeline` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of treating rewrite-rule assembly as a private local dep bundle, so canonical-IR-driven helper rewriting no longer depends on the older `LinkedSpec::Deps` rewrite-pipeline builder or a private emit-context callback map. Specialized declare/assign method lowering follows the same owner pattern: `LinkedSpec::ActionIR::DeclareMethod` now owns its ActionRewriter-facing default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local declare-method callback bundle, so active declare-method lowering no longer depends on either the older `LinkedSpec::Deps` builder or a private emit-context map. Contract construction now does too: `LinkedSpec::ActionIR::Contracts` owns its ActionRewriter-facing default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local contracts callback bundle, so the active lowering-contract path no longer depends on either the older `LinkedSpec::Deps` contract builder or a private emit-context map. Value-expression lowering now follows the same owner pattern: `LinkedSpec::ActionIR::ValueExpr` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local value-expression callback bundle, so scalar-access and scalaref lowering no longer depend on the older `LinkedSpec::Deps` value-expression builder. Flow-expression lowering now does too: `LinkedSpec::ActionIR::FlowExpr` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local flow-expression callback bundle, so boolean/comparison flow lowering no longer depend on the older `LinkedSpec::Deps` flow-expression builder. Array-pipeline planning and lowering now follow the same owner pattern: `LinkedSpec::ActionIR::ArrayPipeline` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local array-pipeline callback bundle, so array-pipeline transforms no longer depend on the older `LinkedSpec::Deps` array-pipeline builder. Control-flow lowering now does too: `LinkedSpec::ActionIR::ControlFlow` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local control-flow callback bundle. Method/value/assignment/return lowering now follows the same owner pattern: `LinkedSpec::ActionIR::MethodLowering` owns its default callback map through `default_deps_for_package(...)`, and `LinkedSpec::RuleIR::EmitContext` now resolves that owner map directly instead of hand-building its own local method-lowering callback bundle, so the broad method-lowering surface no longer depends on the older `LinkedSpec::Deps` method-lowering builder. Treat `LinkedSpec::RuleIR::EmitContext` plus the extracted ActionIR owner modules as the active helper-rewrite path, with `LinkedSpec::ActionRewriter` retained as compatibility wrapper surface for direct legacy callers.

`LinkedSpec::ActionRewriter` itself also no longer imports `LinkedSpec::Deps` at module load time, and `LinkedSpec::ParserFactory` has absorbed the last parser-factory dep builder too, so require-only consumers stay on the extracted owner modules without loading `LinkedSpec::Deps` at all.

Likewise, validation and DSL-error handling now stay on `LinkedSpec::Validation`; normal callers should not depend on the older `LinkedSpec::get_dsl_context(...)`, `report_dsl_error(...)`, `validate_*`, or `extract_regex_literals_from_rule_rhs(...)` facade wrappers.

## Legacy Plugin Bridge
LinkedSpec now also has an explicit registered-plugin surface for the modernization track:

```text
LinkedSpec::register_plugin('synthetic_plugin', sub { ... })
LinkedSpec::register_plugins({
  plugin_one => sub { ... },
  plugin_two => sub { ... },
})
LinkedSpec::run_plugin('synthetic_plugin', @args)
```

`LinkedSpec::run_plugin(name, @args)` is now the preferred explicit dispatch path. It sends the explicit plugin name through `LinkedSpec::PluginBridge::_dispatch_plugin_name(...)` directly, without relying on method-name extraction. The bridge checks `LinkedSpec::PluginRegistry` first, so if an explicit registered handler exists, that handler runs directly and the legacy `.plg` runtime is not loaded for that dispatch. `LinkedSpec::clear_registered_plugins()` is also available when tests or embedding code want to reset the explicit registry.

`LinkedSpec::get_plugin(name)` is the explicit handler-lookup companion to `run_plugin(name, @args)`. It returns the registered handler coderef when one exists, otherwise it lazy-loads the legacy runtime and returns the legacy plugin coderef through the same bridge policy. Prefer this when a caller needs to keep or pass around the plugin callback instead of executing it immediately.

`LinkedSpec::dispatch_plugin_autoload_name($autoload_name, @args)` is the narrow compatibility companion for legacy module-owned `AUTOLOAD` shims that still receive a fully-qualified Perl autoload name and need bridge normalization, but should not call `PPlugin` directly anymore. Treat that helper as transition-only; it exists so old wrapper modules can centralize their handoff under `LinkedSpec::PluginBridge` while the project moves away from `AUTOLOAD` as a primary plugin API.

Generated parsers may still call legacy plugin handlers through `LinkedSpec::AUTOLOAD`. That compatibility path now delegates straight into `LinkedSpec::PluginBridge::_dispatch_autoload(...)`, which normalizes `LinkedSpec::method_name` into the explicit plugin name `method_name` and then delegates runtime execution through the bridge's explicit-name owner path `_dispatch_plugin_name(...)`. The bridge's default legacy load/exec behavior is also now named explicitly inside `LinkedSpec::PluginBridge` via `_load_legacy_plugin_runtime(...)` and `_exec_legacy_plugin(...)`, rather than being hidden in inline closures. Treat `AUTOLOAD` as compatibility glue only; the intended long-term surface is explicit `run_plugin(...)` dispatch plus package/registry ownership.

The current legacy `.plg` adapter in `PPlugin` still searches the working directory and the project `plugin/` directory, but it now enumerates those roots explicitly, lists `.plg` files in deterministic cwd-first sorted order, reads each plugin file through an explicit file-reader helper, builds the cached registry through an explicit `_build_plugin_registry(...)` helper, initializes that cache through `_load_legacy_registry()` plus explicit default deps, lazy-loads the default `pplugin` parser callback through the shared `LinkedSpec::OwnerDispatch` seam only when that callback is actually needed, and exposes normalized-name execution through `exec_plugin_name(...)`. Unreadable or malformed `.plg` files are reported and skipped during legacy registry construction, and successful partial registry builds preserve the caller's prior `$@` instead of leaking stale parser state into the embedding process. Repo-owned callers that already know explicit plugin names should prefer `LinkedSpec::run_plugin(...)` for immediate execution or `LinkedSpec::get_plugin(...)` when they need a callback, instead of calling `PPlugin` directly. The repo-owned `plugin/*.plg` lookup callers have now been moved off direct `PPlugin->get(...)`; that spelling is reserved for the compatibility bridge/adapter internals while they still exist. The bridge now prefers the explicit registered-plugin registry before falling back to this legacy `.plg` path. The older `PPlugin::exec(...)` entry remains compatibility glue for mixed-name callers. Treat that as compatibility behavior, not the long-term plugin architecture.

The `GenericFilter` grouping helpers are now package-owned too. `Table::GenericFilter` owns the `group_by`, `group_by_port`, `group_by_ioclock`, and `group_byRE` actions used by `HUtils::GenericFilter(...)` and `TableSort::GenericFilter(...)`. Repo-owned Perl callers no longer construct `genericfilter_*` plugin names or route those calls through `LinkedSpec::run_plugin(...)` / `LinkedSpec::get_plugin(...)`, and the old `plugin/genericfilter.plg` wrapper plus short-lived `Plugin::GenericFilter` scaffold have now been deleted. This is the preferred migration shape for extracted plugin behavior: keep real executable logic in a normal package owner, keep `.plg` wrappers only where compatibility still needs the old names, and avoid direct `PPlugin` access in new code.

That last clause is intentional. A `.pm` owner does not automatically require a permanent `.plg` shadow. `Text::VariableSubstitution`, `HTML::PathLinks`, non-plugin owner `InteractivePrompt`, and domain owners `VHDL::ConstantEval`, `MSOffice::Excel`, and `Table::GenericFilter` are now pure package-owner surfaces for their repo-owned helper behavior: `plugin/string.plg`, `plugin/cgi.plg`, `plugin/genericfilter.plg`, `plugin/msoffice.plg`, `plugin/vhdconst_eval.plg`, and `plugin/yesno.plg` are no longer part of the shipped legacy plugin corpus. Use this as the direction for future extractions: keep `.plg` only while a real remaining legacy caller needs the old registration name, and treat `Plugin::*` as migration scaffolding rather than a permanent namespace when a clearer non-plugin/domain owner exists.

The same rule also applies inside mixed legacy files. The former real historical `http` action now lives in `HTTP::FileAccess::print_file_links_for_conf(...)`, the former real historical `lighttpd` action now lives in `HTTP::FileAccess::run_lighttpd_for_conf(...)`, and the former historical Apache `httpd` action now lives in `HTTP::FileAccess::run_httpd_for_conf(...)`, so `plugin/http.plg`, `plugin/lighttpd.plg`, and `plugin/httpd.plg` are no longer shipped as legacy registry wrappers. Repo-owned `.plg` code now calls `HTTP::FileAccess::url_for_path(...)`, `HTTP::FileAccess::set_hostport(...)`, or `HTTP::FileAccess::set_localhost(...)` directly when it needs HTTP file-access behavior.

Internal helper subdefinitions in mixed legacy files follow the same rule too. The visible `qc_summary` action still lives in `plugin/qc_summary.plg`, but its private row-merging helper no longer appears as `qc_summary_merge` in the dynamic plugin registry. That behavior now lives in `QC::Summary::append_merged_rows(...)`, and the `.plg` action calls the package owner directly instead of using `LinkedSpec::get_plugin('qc_summary_merge')`.

The setup/hold timing helpers now follow the same rule across two mixed legacy files. The visible `setup_hold_tmax_tmin` action still lives in `plugin/setup_hold_tmax_tmin.plg`, and the visible `tssio` action still lives in `plugin/tssio.plg`, but their private timing formulas no longer appear as `DxCy`, `DiCi`, `DiCo`, `DoCi`, `DoCo`, `tss_setup_hold`, or `tss_tmax_tmin` dynamic plugin registrations. That behavior now lives in `Timing::SetupHold`, and those `.plg` actions call the package owner directly.

STAN/report-timing backend setup follows it as well. The visible STAN backend actions still live in `plugin/stan_backend.plg`, and related legacy actions in `plugin/skew.plg` plus `plugin/duty_cycle_degradation.plg` still exist, but the private setup helper no longer appears as `stan_backend_start` in the dynamic plugin registry. That behavior now lives in `Timing::StanBackend::start(...)`, preserving the launch banner, HTTP host/port setup, and `stan_backend_table2ss` configuration load while letting repo-owned callers name the timing-domain owner directly.

The STAN OMAP2430C backend frequency-detail helpers follow the same rule and also show the naming cleanup policy. The visible `old_default` action still lives in `plugin/stan_omap2430c_backend.plg`, but its private helpers no longer appear as misspelled dynamic plugin names such as `freqency_detailed`, `freqency_detailed_paths`, `drive_freqency_detailed`, or `get_freqency_detailed_fname`, and its port-timing traversal callback no longer appears as `portiming`. That behavior now lives in `Timing::StanOmap2430cBackend` behind corrected callable names such as `filter_port_timing_paths(...)`, while historical LOF section strings and data keys keep their existing spelling where external files may depend on them.

Parser lookup follows the same principle. The old one-line `plugin/spec.plg` `_get_parser` shim is gone; use `LinkedSpec::get_parser('Name')` or `LinkedSpec::Get(...)` directly rather than treating parser lookup as a plugin action.

Generic plugin lookup follows it too. The old one-line `plugin/plugin.plg` shim is gone; code that genuinely needs a callback lookup should call `LinkedSpec::get_plugin($name)` directly and handle an unresolved name explicitly, for example with `// sub {}` when a no-op fallback is intentional.

Small utility wrappers follow the same rule. The old `plugin/table.plg` wrapper is gone; code that wants to split a flat list into fixed-width rows should call `Table::list2table(...)` directly instead of relying on a `list_2table` plugin action. The unused `table_2ss` action is not kept as a permanent compatibility name without a real caller.

Office automation helpers follow it too. The old `plugin/msoffice.plg` wrapper is gone; code that needs the historical Excel automation helper should call `MSOffice::Excel::start()` directly. That package owns the lazy `Win32::OLE` dependency boundary instead of hiding it behind an unqualified `excel_start` plugin action.

VHDL constant helpers follow it as well. The old `plugin/vhdconst_eval.plg` wrapper is gone; code that needs VHDL constant extraction or hash-value substitution should call `VHDL::ConstantEval::evaluate_constant_values(...)` or `VHDL::ConstantEval::substitute_hash_values(...)` directly. The former print action exists as `VHDL::ConstantEval::print_constant_values_for_conf(...)`, not as a legacy plugin registration.

Interactive prompt helpers follow the same rule, but with the extra cleanup step already taken. The old `plugin/yesno.plg` wrapper is gone, and the short-lived `Plugin::Prompt` scaffold is gone too; code that needs the historical yes/no confirmation helper should call `InteractivePrompt::yes_no(...)` directly. Empty input still means "yes", while the package owner now also handles no-branch array callbacks correctly instead of preserving the old inline typo from the legacy `.plg` body.

## Runtime Options
`LinkedSpec::Get(\$spec, %options)` supports:
- `parse_only => 1`
- `generate_only => 1`
- `return_descriptor => 1`
- `parse_mode => 'seek' | 'consume'`
- `top_rule => 'RuleName'`
- `dump_parser_source => 1`
- `parser_source_ref => \$out`
- `runtime_ctx_ref => \$ctx` or `runtime_ctx_ref => \%ctx` for advanced runtime-state capture

`LinkedSpec::Get(\$spec, %options)` keeps the public flat key/value call style. The wrapper normalizes those pairs before runtime dispatch; odd trailing option lists fall back to an empty option set for backward compatibility.
If `top_rule` is omitted, LinkedSpec now uses the first parsed rule paragraph as the default top-level entry.
`parse_only` and `generate_only` are successful introspection modes, not failure signals. They intentionally return `undef` on success, and when `runtime_ctx_ref` is present they should leave `$ctx->{last_error}` clear unless some earlier compile stage actually failed.

`parse_mode` now controls the runtime matching discipline for generated handlers:
- `seek`
  - the historical default
  - progressive matching that can skip forward to a later anchor
- `consume`
  - contiguous matching at the current input position
  - later anchors are not searched automatically if the current position does not match

`parse_mode` is a different axis from rule mode:
- `seek` / `consume`
  - cursor discipline: may it scan forward to the next anchor, or must it start exactly here?
- `OR` / `AND`
  - rule composition: are alternatives being tried, or are ordered steps being composed?

So future implementation should keep these concepts independent:
- `OR + seek`
  - try alternatives, and let matching scan forward to the next anchor
- `OR + consume`
  - try alternatives, but require one of them to match at the current position
- `AND + seek`
  - require ordered steps, while still allowing the next step to scan forward
- `AND + consume`
  - require ordered steps, and require each next step to continue contiguously

At the intuition level, `seek` can feel more extraction-like and `consume` can feel more grammar-like, but they are not aliases for `OR` and `AND`.

If `parse_mode` is omitted, LinkedSpec keeps the old behavior and treats it as `seek`.
If you ask for `return_descriptor => 1`, the generated descriptor now also exposes the selected mode at `$descr->{meta}{parse_mode}`.

`runtime_ctx_ref` is an opt-in diagnostics/introspection hook. You can pass either:
- a scalar slot like `\$ctx`, in which case LinkedSpec stores the live per-run runtime context hashref there before compilation continues,
- or a direct shared hashref like `\%ctx` / `$ctx_hashref`, in which case LinkedSpec reuses and updates that existing hash in place.

Typical uses:
- inspect `top_rule` after successful descriptor/parser generation,
- inspect `parser_source_chunks_ref` when you are already using parser-source capture,
- inspect structured failure context at `$ctx->{last_error}` after a compile failure,
- and inspect structured runtime execution failures there after a returned parser coderef hits a handler error.

When you reuse the same shared runtime context across multiple calls, LinkedSpec now refreshes that identity state deliberately instead of letting older file-oriented fields bleed forward:
- inline `LinkedSpec::Get(...)` / `LinkedSpec::Runtime::run_get(...)` clears stale `spec_name` and `spec_path` before compiling inline spec text, and it reseeds the requested `top_rule` early when one is provided so setup/validation failures can still report the intended parser entrypoint,
- file-oriented `LinkedSpec::get_parser(...)` refreshes `spec_name`, clears stale `spec_path`, and replaces stale `top_rule` with the requested one when provided before parser-factory resolution starts.
- if parser-source capture is enabled, the shared `parser_source_chunks_ref` buffer is cleared at the start of each compile while keeping the same shared arrayref alive, so a later run reports only the current parser source instead of appending stale chunks from an earlier compile.
- if a reused shared context already carries stale parser-source capture and `LinkedSpec::get_parser(...)` then fails before compilation even begins, that stale parser-source buffer is cleared during parser-factory preparation too, so an early file-resolution failure does not leave old parser source looking like output from the current call.

That means a later inline failure will not accidentally report the `spec_name` / `spec_path` from an earlier `get_parser(...)` call, a later `get_parser(...)` resolution failure will not accidentally inherit the `spec_path` from a previously resolved parser, and early failure payloads can still carry the caller-requested `top_rule` when one was already known before parser selection.

The current structured failure payload is intentionally small and stable:
- `$ctx->{last_error}{type}`
- `$ctx->{last_error}{stage}`
- `$ctx->{last_error}{owner_stage}`
- `$ctx->{last_error}{summary}`
- `$ctx->{last_error}{detail}`
- `$ctx->{last_error}{spec_name}`
- `$ctx->{last_error}{spec_path}`
- `$ctx->{last_error}{top_rule}`

Some compile-time failures may also add:
- `$ctx->{last_error}{rule_label}`
- `$ctx->{last_error}{handler_source_label}`

Runtime execution failures may also add:
- `$ctx->{last_error}{rule_label}`
- `$ctx->{last_error}{handler_variant}`
- `$ctx->{last_error}{handler_source_label}`

Example:

```perl
my $ctx;
my $descr = LinkedSpec::Get(
  \$spec_content,
  return_descriptor => 1,
  runtime_ctx_ref => \$ctx,
);

if (!defined $descr && ref($ctx) eq 'HASH' && ref($ctx->{last_error}) eq 'HASH') {
  warn "compile failed at stage $ctx->{last_error}{owner_stage}: $ctx->{last_error}{summary}\n";
}
```

Direct shared-hashref form is useful when you want to seed caller-owned fields and keep them in the same structure:

```perl
my %ctx = (request_id => 'abc123');
my $parser = LinkedSpec::get_parser(
  'grammar_name',
  runtime_ctx_ref => \%ctx,
);

if (ref($ctx{last_error}) eq 'HASH') {
  warn "request $ctx{request_id} failed at $ctx{last_error}{owner_stage}\n";
}
```

The same hook also works through `LinkedSpec::get_parser(...)`. On that file-oriented path it now covers both:
- parser-factory setup failures before normal validation/resolution starts, such as invalid injected callback/dependency wiring,
- parser-factory failures before compilation starts, such as invalid spec names, missing spec files, or file-load failures,
- compiler failures after the spec file has been loaded,
- and runtime handler failures after the returned parser coderef is invoked.

Compiler-owned exceptions that happen while turning parsed rule entries into the compiled descriptor now also flow through that same channel instead of bypassing it as raw dies. In practice, if a validation callback throws, if bootstrap parse throws, if `compile_spec_entry(...)` throws while `build_compiled_rule_table(...)` is building rule descriptors, or if final descriptor assembly / generated-descriptor validation throws while building the dependency-regex map, `last_error` is populated with the same `compiler_pipeline` payload family and the relevant `stage` (`validate_spec_content`, `validate_dsl_syntax`, `bootstrap_parse`, `build_compiled_rule_table`, `build_final_descriptor`, or `validate_dependency_regex_references`).

That same story now reaches the standalone low-level `build_compiled_rule_table(...)` helper too when you opt into `runtime_ctx_ref => \$ctx`. A thrown custom `compile_spec_entry(...)` callback, a malformed non-throwing descriptor tuple, an invalid non-CODE callback contract, a malformed non-ARRAY parsed-entry container, or a malformed individual parsed entry there now all normalize into `compiler_pipeline:build_compiled_rule_table`. When rule iteration has already started, that payload preserves the active parsed `rule_label` when known; when failure happens earlier, or when the malformed entry itself has no usable parsed label, it still falls back to the selected `top_rule` for the same label-scoped `handler_source_label` identity `LinkedSpec::generated_handler:<rule_label>` or `LinkedSpec::generated_handler:<top_rule>`.

When the failure happens during `compiler_pipeline:validate_spec_content`, the structured payload can now also preserve the validator’s specific `summary` and the full formatted DSL error text in `detail`, instead of collapsing back to the old generic “Input envelope validation failed” banner. If the validator already knows a malformed first-rule label at that early seam, the same payload can also preserve `rule_label`; if no rule label is available yet but the caller already selected a `top_rule`, that same seam now still preserves the label-only `handler_source_label` form `LinkedSpec::generated_handler:<top_rule>` so the intended entrypoint identity is not lost before rule attribution begins. When the failure happens during `compiler_pipeline:validate_dsl_syntax`, the structured payload can now likewise preserve `rule_label` when the validator still knows which rule paragraph owns the failing DSL line. On that false-return seam the compiler now also keeps the validator’s more specific `summary` plus the full formatted DSL error text in `detail`, instead of collapsing back to the old generic “Rule-level DSL syntax validation failed” banner, and if rule attribution is still unavailable that seam now falls back to the selected `top_rule` for the same label-only `handler_source_label`. When the failure happens during `compiler_pipeline:build_compiled_rule_table`, the structured payload can now also preserve `rule_label` when the compiler still knows which parsed rule entry was being compiled at that moment, and if no rule label is available there the same seam now also falls back to the selected `top_rule` for that label-only `handler_source_label`. On malformed non-throwing `compile_spec_entry(...)` return shapes, that same seam now also preserves specific tuple-shape detail such as `compile_spec_entry returned invalid descriptor tuple: label=undef, info=undef` or `compile_spec_entry returned invalid descriptor tuple: label='Top', info=ARRAY`, instead of collapsing back to the older generic “Rule descriptor build failed while compiling parsed spec entries” wrapper. Likewise, when `compiler_pipeline:build_final_descriptor` fails inside default `build_dependency_regex_map(...)`, the payload can preserve `rule_label` for the active rule whose combined regex dependencies were being built, and if no active rule has been attributed yet that seam now also falls back to the selected `top_rule` for the same label-only `handler_source_label`. That same final-descriptor seam now also preserves explicit default-`build_dependency_regex_map(...)` contract detail on malformed descriptor shapes, such as `build_dependency_regex_map expects rule 'Top' dependency_refs to be ARRAY ref; got SCALAR`, instead of leaking a generic Perl reference error from deep inside dependency-regex-map assembly. The same attribution now reaches one stage later too: if `compiler_pipeline:validate_dependency_regex_references` rejects the generated descriptor by returning false while the validation seam still knows the owning compiled rule, the payload can preserve that `rule_label` and carry a more specific owning-rule `detail` string instead of only the old generic “returned false” fallback. That same `validate_dependency_regex_references` stage can now also preserve `rule_label` when a nested rule-local validation call throws while the seam still knows which compiled rule it was validating, and when validation already knows the exact failing dependency-regex/rule-check cause it now reuses that more specific validation `summary` too instead of always collapsing back to the generic “Generated parser validation failed” banner. If no rule label is available at that later validation seam either, it now falls back to the selected `top_rule` for the same label-only `handler_source_label` so late generic failures still keep one stable generated-handler identity.

Those same compile-time attributed failures can now also carry `handler_source_label` when LinkedSpec knows the failing rule label even before an exact handler variant has been selected. That now includes malformed-first-rule `validate_spec_content` false returns, rule-attributed `validate_dsl_syntax` false returns, and the later `build_compiled_rule_table`, `build_final_descriptor`, plus attributed `validate_dependency_regex_references` seams. In all of those cases the structured payload uses the stable synthetic label `LinkedSpec::generated_handler:<rule_label>`, which gives callers one direct generated-handler identity string for logging and attribution without forcing them to reconstruct it from `rule_label` manually. That makes compile-time failures easier to attribute without scraping `detail` just to discover which rule was active.

Compiler-owned setup failures before that main validation/parse flow now use the same channel too. If the compiler cannot prepare its callback/runtime-owner surface cleanly, for example because `bootstrap_parse` resolved to an invalid non-CODE value, `last_error` is populated as `compiler_pipeline` at stage `prepare_pipeline` instead of falling through to the generic runtime-owner fallback. When the selected `top_rule` is already known at that seam, that same payload now also preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>`, so even compiler setup failures can still be tied back to the intended parser entrypoint without scraping `detail`.

The runtime owner now normalizes one higher-level fallback seam on the inline path too. If `LinkedSpec::Runtime::run_get(...)` or the public `LinkedSpec::Get(...)` facade catches a raw die coming back from `Compiler::run_get_pipeline(...)`, or if that delegated compiler path returns `undef` on a real failure path without writing its own structured payload first, `last_error` is populated with a `runtime_owner` payload at stage `run_get_pipeline`. If the deeper compiler/runtime owner already wrote a structured `last_error` payload before dying or before returning `undef`, that deeper payload is preserved and not overwritten by the runtime wrapper. The same boundary is now strict about malformed defined results too: normal inline compilation only treats a parser coderef as success, `return_descriptor => 1` only treats a descriptor hash as success, and `parse_only` / `generate_only` only treat `undef` as success. Malformed defined return shapes now preserve specific detail such as `run_get_pipeline returned invalid parser value: HASH; expected CODE` or `run_get_pipeline returned invalid parse_only value: HASH; expected undef` instead of drifting outward as bogus success values. When the selected `top_rule` is already known at that fallback seam, the same `runtime_owner` payload now also preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>`, so even a runtime-owner fallback can still be tied back to the intended parser entrypoint without scraping `detail`. Successful `parse_only` and `generate_only` calls are excluded from that fallback rule: they still return `undef` by design, but they should leave the failure channel clear.

The parser-factory owner now has the same kind of explicit setup stage too. If `LinkedSpec::ParserFactory::run_get_parser(...)` cannot prepare its callback/trace/dependency surface cleanly, for example because `trace_enter` or another required callback resolved to a non-CODE value, `last_error` is populated as `parser_factory` at stage `prepare_parser_factory` instead of letting that setup seam escape as a raw owner die. The same pre-compile parser-factory seams now also preserve the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` whenever the selected `top_rule` is already known there, so `prepare_parser_factory`, `validate_spec_name`, `resolve_spec_path`, and `load_spec_content` failures can still be tied back to the intended parser entrypoint without reconstructing that label from separate fields. Later in that same file-oriented path, the compile boundary now also treats only a real parser coderef as a successful default `compile_spec(...)` result, only a descriptor hash as a successful `return_descriptor => 1` result, and only `undef` as a successful `parse_only` / `generate_only` result. A silent `undef` on a real failure path still preserves the stable fallback detail `compile_spec returned undef without structured runtime context`, and malformed defined values now preserve specific shape detail like `compile_spec returned invalid parser value: HASH; expected CODE` or `compile_spec returned invalid generate_only value: ARRAY; expected undef` instead of drifting outward as a bogus parser object or collapsing back to a generic wrapper string. When the selected `top_rule` is already known at that parser-factory compile seam, those same fallback payloads now also preserve the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>`, so file-oriented compile failures can still be tied back to the intended parser entrypoint without reconstructing that label from separate fields.

That means the `last_error` payload is now largely self-contained:
- `type` tells you which owner family raised the error (`parser_factory`, `compiler_pipeline`, or `runtime_owner` on compile-time failure paths today),
- `stage` gives the owner-local failure step,
- `owner_stage` gives the stable combined identifier,
- and `spec_name` / `spec_path` / `top_rule` travel with the payload when that information is known.

For runtime execution failures, the same payload also tells you which compiled rule failed:
- `top_rule` names the selected parser entrypoint when one was available,
- `type` is currently `runtime_handler` for inner compiled-handler eval failures or `runtime_parser` for higher-level top-rule resolution/invocation failures,
- `rule_label` names the failing compiled rule,
- and `handler_variant` tells you which handler family was active when the eval-visible failure happened.

For runtime execution failures, the structured payload now also carries `handler_source_label` when the failing path can still be tied to generated rule-handler source. That value uses a stable synthetic label of the form `LinkedSpec::generated_handler:<rule_label>:<handler_variant>`.

For generated-handler compile failures specifically (`runtime_handler` at stage `rule_handler_compile`), the preserved `detail` text still includes that same synthetic source label too. That keeps the raw Perl compile text easier to read while also exposing the label directly as structured data instead of forcing callers to scrape `detail`.

That same `handler_source_label` is now also carried on `runtime_parser` failures when the top-level parser still knows which compiled rule handler it was resolving or invoking. If the exact handler variant is known, the payload uses the fuller `LinkedSpec::generated_handler:<rule_label>:<handler_variant>` label; if only the top-rule label is known at that boundary, the payload still preserves the shorter `LinkedSpec::generated_handler:<rule_label>` form. So if the compiled descriptor entry for the selected top rule is missing, if the top-rule handler coderef is missing, or if a top-rule handler dies at the outer parser boundary, callers can still recover a stable generated-handler identity directly from structured diagnostics.

That `runtime_parser` family now covers both:
- `resolve_top_rule_handler` when a returned parser coderef cannot find a usable selected top rule or handler coderef to invoke,
- `validate_input_ref` when a returned parser coderef is invoked with something other than a `SCALAR` reference input,
- and `invoke_top_rule` when the selected top-rule handler itself dies at the outer parser-call boundary.

That means the parser-entry contract is now explicit too: top-level parser coderefs expect the same `\$input_string` shape that the generated handlers already use internally. If you accidentally pass something else, the failure stays at the parser boundary with targeted structured detail like `Top-level parser expects a SCALAR reference input; got ARRAY`, plus the same `top_rule`, `rule_label`, `handler_variant`, `handler_source_label`, and file-backed `spec_path` continuity that other `runtime_parser` failures already preserve.

On the successful path, `runtime_ctx->{last_error}` should be treated as a failure-only channel. The returned parser now clears stale inner `runtime_handler` payloads if a later path in the same top-level invocation succeeds and returns a defined AST, so callers do not have to special-case old inner backtracking failures after a successful parse.

## `get_parser(...)` Lookup Behavior
`LinkedSpec::get_parser('name')` resolves parser specs in this order:
1. If argument is already a valid file path, use it directly.
2. Try `name.spec` directly if available.
3. Try module-relative `../specs/name.spec`.
4. If still unresolved, fall back to `PathSearch`.

`LinkedSpec::get_parser('name', %options)` keeps the public flat key/value call style. The wrapper normalizes those pairs before parser-factory dispatch; odd trailing option lists still fall back to an empty option set for backward compatibility. File-oriented callers can use the same `parse_mode => 'seek' | 'consume'` and `top_rule => 'RuleName'` options there too, and they flow into the generated descriptor/runtime parser behavior the same way as on `LinkedSpec::Get(...)`.

`get_parser(...)` also accepts `runtime_ctx_ref => \$ctx` for diagnostics continuity. On success, the captured context exposes the resolved `spec_path` and later runtime-owned fields like `top_rule`. On failure before compilation starts, it exposes a parser-factory `last_error` payload; on failure during compilation, the same shared context is upgraded to the compiler-pipeline `last_error` payload or, when the runtime owner has to supply a fallback because the delegated compiler path came back empty, to `runtime_owner:run_get_pipeline`; and if a returned parser later hits a runtime execution failure, that same shared context is upgraded again to a `runtime_handler` or `runtime_parser` payload depending on where the failure surfaced. That continuity now includes top-level parser invocation failures too: after `get_parser(...)` has already resolved and loaded a spec file, a later `runtime_parser` failure still preserves the resolved `spec_path`, selected `top_rule`, and generated-handler identity in the shared runtime context instead of dropping back to a file-less runtime-only view.

That continuity now covers parser-factory callback exceptions too. If `validate_spec_name(...)`, `resolve_spec_path(...)`, `load_spec_content(...)`, or the delegated `compile_spec(...)` callback throws, `get_parser(...)` now returns `undef` and records the corresponding parser-factory failure stage in `last_error` instead of leaking a raw callback die. The same parser-factory rule now also preserves owner-specific false-return details on the front door: if `validate_spec_name(...)` rejects the requested parser name without throwing, `last_error` now keeps the validator’s own `summary` and `detail` instead of collapsing back to a generic “validate_spec_name rejected the requested parser name” wrapper, if the real resolver returns `undef` during `resolve_spec_path(...)`, `last_error` now keeps the resolver’s own summary/detail like `Spec path not found` or `Spec path is not a file` instead of collapsing back to a generic “Spec resolution failed” wrapper, and if the real resolver returns `undef` during `load_spec_content(...)`, `last_error` now keeps the resolver’s own file-open summary/detail like `Unable to open spec file '...'` plus the `OS Error: ...` text instead of collapsing back to a generic “Spec file load failed” wrapper. The same compile-stage rule still applies to silent `undef` returns too: if the delegated `compile_spec(...)` path comes back `undef` without first writing a deeper structured payload, parser-factory records its own `parser_factory:compile_spec` fallback; if the deeper compile/runtime owner already wrote a structured `last_error` payload before throwing or before returning `undef`, that deeper payload is preserved rather than being overwritten by a generic parser-factory wrapper error. That means the newer compiler-side handler-attribution rules carry through the same file-oriented path as well: even on a later generic compiler failure such as an unattributed `build_final_descriptor` die after the file has already resolved and loaded, `get_parser(...)` now preserves the selected `top_rule`, resolved `spec_path`, and the same label-only `handler_source_label` form `LinkedSpec::generated_handler:<top_rule>` instead of letting that identity disappear at the parser-factory boundary.

The compiler-owned side now follows that same idea on malformed non-throwing bootstrap results too. If `bootstrap_parse(...)` throws, `last_error` records `compiler_pipeline:bootstrap_parse` with the thrown text as before; if it returns a malformed success-shape instead, `last_error` now keeps a specific result-shape detail like `bootstrap_parse returned undef while reporting parse_success=1` or `bootstrap_parse returned HASH while reporting parse_success=1; expected ARRAY` instead of collapsing back to one generic “bad intermediate representation” detail string. When the selected `top_rule` is already known at that seam, those same `bootstrap_parse` payloads now also preserve the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>`, so early compiler parse failures line up with the same structured handler-attribution story as later compile/runtime failures.

Public callers should continue to treat `LinkedSpec::get_parser(...)` as the stable entrypoint. Trace/spec-resolution/compile defaults are owned internally by `LinkedSpec::ParserFactory`, and local/module-relative lookup is owned by `LinkedSpec::Resolver`, so callers do not need to wire those dependencies themselves. The older `LinkedSpec::Deps` module is no longer part of the active parser-factory path, `Resolver` is loaded lazily only when parser-factory default deps are actually resolved, and the broader compile/plugin pipeline (`ParserFactory`, `Runtime`, `Compiler`, `PluginBridge`, plus `RuleIR::EmitContext` for the compatibility rewrite shim) is now lazy-loaded from the façade only when the corresponding public entrypoints actually need it.

## Tracing and Debugging
LinkedSpec supports multi-level tracing.

Supported levels:
- `none`
- `low`
- `medium`
- `high`
- `debug`

Runtime API examples:
- `LinkedSpec::configure_trace(trace_level => 'high')`
- `LinkedSpec::configure_trace(trace_level => 'debug', trace_emoji => 1)`
- `LinkedSpec::configure_trace(trace_log_file => 'trace.log')`
- `LinkedSpec::configure_trace(trace_log_file => 'trace.log', trace_log_mode => 'route')`
- `LinkedSpec::configure_trace(trace_log_file => 'trace.log', trace_log_mode => 'mirror')`

Per-call options:
- `trace_level => 'none|low|medium|high|debug'`
- `trace_log_file => 'trace.log'`
- `trace_log_mode => 'route|mirror|stdout'`
- `trace_reset_log => 1`
- `trace_emoji => 1`
- `debug => 1`
- `quiet => 1`

Environment variables:
- `LINKEDSPEC_TRACE_LEVEL`
- `LINKEDSPEC_TRACE_FILE`
- `LINKEDSPEC_TRACE_MIRROR_STDOUT`
- `LINKEDSPEC_TRACE_RESET_FILE`
- `LINKEDSPEC_TRACE_EMOJI`

Trace messages include:
- timestamp,
- trace level,
- file name,
- function name,
- line number,
- indentation for nested flow scopes,
- decision events (`TAKEN` / `SKIPPED`).

When you invoke a returned parser coderef, trace output now also includes an explicit top-level parser invocation scope:
- `ENTER LinkedSpec::parser_invoke:<top_rule>`
- `DECISION resolve_top_rule_handler => TAKEN|SKIPPED`
- `DECISION invoke_top_rule:<top_rule> => TAKEN|SKIPPED`
- nested `LinkedSpec::rule_handler:<rule_label>` scopes for the actual rule execution
- `EXIT LinkedSpec::parser_invoke:<top_rule>`

That gives runtime traces one clean bridge between compile-time tracing and the inner rule-handler scopes, which makes top-level parser invocation problems much easier to follow.

At high/debug trace levels, named-mark writes now also expose their exact stored checkpoint position visually:
- `@mark(name)`,
- `mark_here(name)`,
- `mark_entry_start(name)`,
- `mark_entry_end(name)`,
- `mark_match_start(name)`,
- `mark_match_end(name)`,
- the advancing write inside `capture_take(name)`,
- and the advancing write inside `capture_take_between(start_mark, end_mark)`

all emit a short input excerpt plus a caret on the next line under the stored position, so staged-extraction rules are easier to inspect when you need to confirm whether a checkpoint is post-match or current-match-left-edge.

## Strong Recommendations for New Specs
If backend neutrality matters, these are the defaults you should follow.

1. Prefer `declare(...)` over raw `my` declarations.
2. Prefer `assign(...)` over raw assignment wrappers.
3. Prefer `assign(scalar(retv), call(rule))` over `$retv = call(rule)`.
4. Prefer `push_value(array(target), value)` over raw `push @target, ...` when you already have a value expression.
5. Prefer `return(payload)` with `array(...)`, `hash(...)`, `array_copy(...)`, legacy `array_values(...)`, `hash_copy(...)`, and `flat_*` helpers over ad hoc Perl data literals when possible.
6. Prefer helper control-flow markers (`if`, `elseif`, `else`, `endif`, `switch`, `case`, `default`) over raw Perl branch scaffolding when possible.
7. Prefer `array_copy(array(name))` for snapshot array payloads, prefer `hash_copy(hash(name))` for snapshot object payloads, keep `array_values(array(name))` only as compatibility syntax, and use `flat_array(...)` / `flat_hash(...)` for list-context insertion over either direct working aggregates or composed aggregate helper expressions.
8. Use snippet inspection and `return_descriptor` metadata to verify that the rule stays language-agnostic-action-IR ready.

## Known Caveats and Nuances
- `return(payload)` is the preferred general return form, but method-chain `.return(...)` detection is still more conservative than block-form `return(payload)`.
- Helper shells can still contain raw backend expressions; this is sometimes practical, but it is less portable than pure helper-only authoring.
- Legacy compatibility wrappers are still important because many existing specs depend on them. Keep them in mind when reading old specs, but do not default to them in new code.
- Some old specs are still extraction-oriented and permissive; that is part of LinkedSpec's intended character, not automatically a bug.

## Versioning and Compatibility
Treat existing specs as compatibility contracts.
When changing lowering behavior:
- preserve current AST shapes unless there is a deliberate migration,
- add regression locks when a new lowering surface is introduced,
- prefer canonical helper surfaces over expanding raw fallback.
