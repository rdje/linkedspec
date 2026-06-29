---
id: terse-bare-working-vars-engine-gaps
title: "SPEC-FORMAT-TERSE.1.2 ground truth — how the Perl reference engine treats BARE (un-wrapped) working variables TODAY, in three distinct behaviors. (1) ARG-POSITION: a bare name in a type-implying helper arg position already LOWERS to the correctly-sigil'd variable (`assign(count, v)`→`$count = v`; `push_value(items,..)`/`.push(items)`→`push @items, ..`) — ValueExpr's `_extract_*_symbol_name` accept a bare `^(\\w+)$` — BUT it gets NO auto-`my`, because the .1.1.1 collector matches only WRAPPED `scalar/array/hash(NAME)`; so a bare var used only in arg positions is a leaky PACKAGE global (the exact .1.1.1 hazard, still open for bare forms). (2) VALUE-POSITION: a bare word in a value/return slot is NOT recognized as a variable read — `return(count)`→`return count ;` (a non-strict bareword, not `$count`). (3) WRAPPED refs DO get the auto-`my` (.1.1.1: `scalar(count)` no-declare→`my $count;`, `array(items)`→`my @items;`). So .1.2 decomposes into two inference channels: Channel 1 = arg-position auto-existence (extend the collector); Channel 2 = value-position bare-word variable reads + RHS-shape (`[]`→array,`{}`→hash) inference (var/call/literal disambiguation, couples with .1.5 literals)."
answers:
  - "what does a bare (un-wrapped) working variable lower to in the perl engine today"
  - "does assign(name, val) accept a bare name without a scalar() wrapper"
  - "does return(bareword) treat the bare word as a variable read or a bareword in linkedspec"
  - "why does a bare working variable used only in arg positions leak across parser invocations"
  - "does the SPEC-FORMAT-TERSE.1.1.1 auto-var collector handle bare (un-wrapped) names"
  - "what are the channels / sub-leaves of SPEC-FORMAT-TERSE.1.2 (remove wrappers + type inference)"
  - "where is the sigil chosen for a bare working variable in a helper arg position"
  - "how does push(child, target) / .push(items) decide the bare target is an array"
  - "what is the engine ground truth for removing the scalar/array/hash wrappers in .spec"
  - "why is SPEC-FORMAT-TERSE.1.2 split into a Perl reference change plus a Rust parity follow-on"
  - "does name[key] = value close Channel 2 bare value-position reads"
date: 2026-06-24
status: confirmed
tags: [engine, codegen, dsl, variables, wrappers, type-inference, spec-format-terse, SPEC-FORMAT-TERSE, ActionIR, EmitContext]
evidence: "TOOLBOX `dump_parser_source` probes 2026-06-24 (`perl -Iperl -MLinkedSpec`, `generate_only`+`runtime_ctx_ref`, dump-don't-guess; scratchpad probe_terse_1_2.pl + isolated one-liners). Confirm `perl -Iperl` loads `perl/LinkedSpec.pm` (stale `PERL5LIB=.../pgen/fx/perl` present — see [[rtlutils-regex-hang]]/TOOLBOX §6.5). (A) `top:: -> w { assign(scalar(count), entry_group(0)) } LX { return(scalar(count)) }` (no declare) → preamble emits `my $count;` then `$count = do {...}` / `return $count ;` (the .1.1.1 wrapped path). (B) same spec with BARE `count` (`assign(count,..)`/`return(count)`) → `assign` LHS lowers to `$count = do {...}` (ValueExpr `_extract_scalar_symbol_name` `^(\\w+)$` fallback, ValueExpr.pm:59) but `return(count)` lowers to the bareword `return count ;` (NOT `$count`) AND there is NO `my $count;` → leaky package global (collector regex `\\b(scalar|array|hash|s|a|h)\\s*\\(\\s*NAME\\s*\\)` at EmitContext.pm:810 matches only wrapped forms). (C) `push_value(array(items),..)` (no declare) → `my @items;` + `push @items, ..` + `return [@items]` (the .1.1.1 array path). (D) fluent `.push(items)` bare target → `push @items, &{...w}(...)`; its `my @items;` comes from the LX's WRAPPED `array_copy(array(items))`, not the bare target. Engine sites: collector + sigil table `LinkedSpec::RuleIR::EmitContext` (`%AUTO_WORKING_VAR_WRAPPER_SIGIL` EmitContext.pm:701, `_collect_auto_working_var_decls` 789, `build_rule_ir_emit_context` 901); bare-name extraction `LinkedSpec::ActionIR::ValueExpr` (`_extract_scalar/array/hash_symbol_name` 45/69/93, `_infer_scalar_container_kind` 331 heuristic for 2-arg `scalar(container,key)`); wrapper sigil helper `LinkedSpec::ActionIR::MethodLowering::_wrapper_method_to_sigil` (56). Shipped specs use wrappers pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash 36), so .1.2 keeps wrappers as accepted aliases (gradual migration, ADR 0007) — wrappers become OPTIONAL, not removed."
reverify: "perl -Iperl -MLinkedSpec -e 'my $s=\"top::\\n -> w { assign(count, entry_group(0)) }\\n LX { return(count) }\\n\\nw : /(\\\\w+)/  I.return(entry_group(0))\\n\"; my %c; LinkedSpec::Get(\\$s, top_rule=>\"top\", parse_mode=>\"seek\", generate_only=>1, dump_parser_source=>1, runtime_ctx_ref=>\\%c); print ${$c{parser_source_chunks_ref}}'  # expect `return count ;` (bareword, not \\$count) and NO `my \\$count;` -> the Channel 1 + Channel 2 gaps"
---

# `.1.2` ground truth: bare (un-wrapped) working variables in the Perl engine

**Confirmed 2026-06-24** via `dump_parser_source` probes (`SPEC-FORMAT-TERSE.1.2` ground-truth pass;
direction ratified in ADR [0007](../decisions/0007-spec-format-terse-direction.md)). This is the engine
grounding for the terse-format leaf "remove container wrappers + add type inference", and the reason that
leaf was split by inference channel (Perl-first + Rust parity). Builds on
[[working-vars-no-strict-need-my-lexical]] (the `.1.1` wrapped-form scoping model).

## Update (2026-06-24): Channel 1 CLOSED by `.1.2.1`

Behavior (1) below is now **fixed for the unambiguous first-arg value-helper positions**. `SPEC-FORMAT-TERSE.1.2.1`
extended the `.1.1.1` collector `_collect_auto_working_var_decls` (`perl/LinkedSpec/RuleIR/EmitContext.pm`)
with a second pass that also scans the literal-masked RAW blocks for a **bare** working var in a type-implying
first-arg position and emits the **position-implied** `my`: `assign(NAME, …)` → `my $NAME` (scalar — the
assign target always lowers scalar-first), `push_value(NAME, …)` / `push_nonempty(NAME, …)` → `my @NAME`
(array). The `\s*,` after the bare name keeps a WRAPPED target (`scalar(x)`/`array(x)`) on the wrapped path
(no double-collection); both dedup to one `my`. All 20 shipped specs stayed byte-identical; +3 phase0 locks
(`spec_format_terse_1_2_1_*`) → phase0 971 green, gate EXIT 0. **Still open (Channel 2):** the child-append
`push(Rule[, target])` / fluent `.push(target)` target (first arg is a rule name — ambiguous) and the bare
**hash** target (no clean bare arg position — `set_key(name,…)` is a value-position read), plus value-position
bare-word reads (`return(count)` still a bareword) + RHS-shape inference.

**Rust lockstep parity (`.1.2.2`) DONE 2026-06-24 — and unlike `.1.1.2`, it REQUIRED a Rust engine change.**
`.1.1.2` (wrapped auto-existence) needed no engine change because the interpreter's per-parse `RuntimeContext`
HashMaps auto-vivify. But a *bare* arg-position target was NOT being mapped to the working variable: Rust's
`resolve_scalar_target`/`resolve_array_target` (`rust/linkedspec-runtime/src/engine.rs`) only extracted the
name from a WRAPPED `scalar(VAR)`/`array(VAR)` Call; a bare `Expr::Variable` fell through to `val.to_str()`
(the evaluated value → `""`), so `assign(v,"ok")` set scalar `""` and `scalar(v)` read Undef. Probe (dump):
bare scalar → `[null]`, bare array → `[[]]` (vs wrapped `["ok"]` / `[["a","b"]]`). **Fix:** both resolvers now
also accept a bare `Expr::Variable` target and return its name (mirroring the Perl `^(\w+)$` fallback); the
HashMap then auto-vivifies it. Scoped to the Channel-1 target positions via an `allow_bare` flag — `true` for
`push_value`/`push_nonempty`, `false` for the value-position reads `array_copy`/`hash_copy` (those are Channel
2). Locked with 2 oracle fixtures (`autoexist_{scalar,array}_bare_arg`, Rust == Perl reference) + 4
`terse_1_2_2_*` integration tests; cargo 248→252 green, clippy zero-new, phase0 971 (Perl untouched), gate
EXIT 0. The `.1.2.1` change is now landed against the universal contract on both variants.

**Update 2026-06-29 (`SPEC-FORMAT-TERSE.1.3.3`):** the specific bare **hash target** case now has a clean
type-implying statement position: `set_key(NAME, key, value)` mutates working hash `NAME` and auto-supplies
`my %NAME` on Perl; Rust mirrors it with a top-level statement handler. This does not close Channel 2
value-position reads: `return(name)` is still a bareword/scalar ambiguity, and bare hash value reads still need
the later Channel 2 / literal-shape work.

**Update 2026-06-29 (`SPEC-FORMAT-TERSE.1.3.4.1`):** scalar operator assignment adds another clean
type-implying statement position: `NAME = value` mutates working scalar `NAME` and auto-supplies `my $NAME`
on Perl; Rust parses it as a statement-only scalar assignment and mutates the per-parse scalar map. This is
still a target-position rule only. It does not make `return(NAME)` a variable read and does not infer array or
hash kinds from right-hand-side shapes.

**Update 2026-06-29 (`SPEC-FORMAT-TERSE.1.3.4.2`):** array operator append adds another clean type-implying
statement position for the **target only**: `NAME += expr` mutates working array `NAME` and auto-supplies
`my @NAME` on Perl; Rust parses it as a statement-only array append and mutates the per-parse array map. The
RHS still follows the existing value-expression rules. `NAME += scalar(value)` is accepted, but bare RHS
`NAME += value` is deliberately not accepted because Channel 2 still owns bare value-position reads.

**Update 2026-06-29 (`SPEC-FORMAT-TERSE.1.3.4.3`):** hash-index assignment adds another clean type-implying
statement position for the **target only**: `NAME[key_expr] = value_expr` mutates working hash `NAME` and
auto-supplies `my %NAME` on Perl; Rust parses it as a statement-only hash-index assignment and mutates the
per-parse hash map. The key and RHS still follow existing value-expression rules. `NAME[scalar(key)] =
scalar(value)` is accepted, but bare key/RHS identifiers such as `NAME[key] = "v"` and `NAME["k"] = value` are
deliberately not accepted because Channel 2 still owns bare value-position reads.

## The three behaviors (dump-don't-guess)

A working variable referenced **only through a wrapper** is the `.1.1.1` path and already works. The
question for `.1.2` is what happens to a **bare** (un-wrapped) name. Three distinct behaviors:

1. **Arg position — lowers right, but leaks.** A bare name in a type-implying helper arg position is
   already lowered to the correctly-sigil'd variable: `assign(count, v)` → `$count = v` (ValueExpr
   `_extract_scalar_symbol_name`'s `^(\w+)$` fallback, `ValueExpr.pm:59`); `push_value(items, ..)` /
   `-> w.push(items)` → `push @items, ..`. **But it gets no auto-`my`**: the `.1.1.1` collector regex
   (`\b(scalar|array|hash|s|a|h)\s*\(\s*NAME\s*\)`, `EmitContext.pm:810`) matches only **wrapped**
   refs, so a bare var used *only* in arg positions has no preamble `my` → it is a **leaky package
   global** (generated handlers are non-strict — the exact hazard `.1.1.1` fixed, still open for bare
   forms). This is **Channel 1**.

2. **Value position — not a variable read at all.** A bare word in a value/return slot is **not**
   recognized as a variable: `return(count)` lowers to the bareword `return count ;` (NOT `$count`).
   Making bare words read as variables requires var-vs-call-vs-literal disambiguation and a sigil with
   no wrapper to read it from → RHS-shape inference (`[]`→array, `{}`→hash, number/string/call→scalar).
   This is **Channel 2** (couples with `.1.5` literal `[]`/`{}` syntax).

3. **Wrapped — already auto-exists.** `scalar(count)` (no declare) → `my $count;`; `array(items)` →
   `my @items;` (the `.1.1.1` result; `%AUTO_WORKING_VAR_WRAPPER_SIGIL`, `EmitContext.pm:701`).

## Why this splits `.1.2`

- **Channel 1 (`.1.2.1` Perl + `.1.2.2` Rust)** is self-contained and a direct extension of `.1.1.1`:
  also collect bare names in type-implying arg positions and emit the position-implied-sigil `my`,
  closing the leaky-global gap. Lowest risk; the value lowering is already correct.
- **Channel 2 (`.1.2.3`+)** is the harder half (value-position reads + RHS-shape inference), couples
  with `.1.5`, and is added once `.1.2.1` lands — not pre-published, to avoid vague placeholders.
- Wrappers stay **accepted aliases** during migration (gradual, ADR 0007); shipped specs use them
  pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash 36), so they must keep compiling
  byte-identically.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] (leaf `.1.2` → `.1.2.1` Perl / `.1.2.2` Rust parity; Channel 2 follow-on).
- Builds on: [[working-vars-no-strict-need-my-lexical]] (`.1.1` scoping/non-strict model),
  [[rust-working-vars-auto-vivify]] (`.1.1.2` Rust interpreter auto-vivify).
- Decision: [0007](../decisions/0007-spec-format-terse-direction.md) (terse direction, gradual-alias);
  [0006](../decisions/0006-multi-backend-vision.md) (lockstep all variants);
  [0002](../decisions/0002-all-target-actionir-ready-invariant.md) (ratio 1.0000).
- Related: [[actionir-lowering-stack]], [[emitcontext-owner-registry]],
  [[phase0-all-target-actionir-ready-invariant]], [[spec-format-brainstorm-rounds-1-3]].
