---
id: and-single-acode-edge-return-dropped
title: Single-slot AND rule drops its action-edge return → returns the empty accumulator [] (a regression in _emit_and_single_acode_handler, not intended design)
answers:
  - "why does a single-slot AND rule return [] instead of the returned value"
  - "why does Pair::AND -> Pair[0] { return(...) } output []"
  - "why is the action-edge return dropped for a single-regex AND rule"
  - "is the single-slot AND self-edge return-to-[] behavior intended or a bug"
  - "what is the AND_SINGLE_ACODE handler variant and why does it ignore the edge return"
  - "how do I make an AND rule surface a computed value in .spec"
  - "which .spec rule forms surface a return value as the top-level parser output"
  - "why does LX/E return get ignored on a single-slot AND rule"
date: 2026-06-17
status: confirmed
tags: [perl-reference, codegen, handler-variant, regression, AND_SINGLE_ACODE, SPEC-LANG-REFERENCE, output-shape]
evidence: "SPEC-LANG-REFERENCE.10 investigation (2026-06-17), read-only, all claims verified against live LinkedSpec::Get runs + the generated handler source + git. A single-regex-slot AND rule with an action edge selects handler variant AND_SINGLE_ACODE (perl/LinkedSpec/RuleIR.pm:42, `$regex_count == 1 ? 'AND_SINGLE_ACODE' : 'AND_ACODE'`); built by _emit_and_single_acode_handler (perl/LinkedSpec/HandlerVariantEmitter.pm:564-630). The bug: the loop at lines 575-582 computes `$transformed` for each edge acode but NEVER `push`es it into @acodes_transformed, so _build_acodes_dispatch_block(\\@acodes_transformed) (line 583) gets an empty list, the edge dispatch is omitted, and the handler unconditionally ends `return \\@${label}_collect;` (line 628) — the never-written accumulator → output []. Provenance: introduced by the MEDIUM-IMPACT.3.4.x family (148c746 'apply return→assignment in AND_SINGLE_ACODE emitter', finalized 7fec186); the sibling _emit_and_acode_seq_handler got the same edit WITH its push, proving the omission was an oversight. Already flagged as a known gap in docs/knowledge/specentry-perl-coupling-inventory.md:234 ('Key gap: AND_SINGLE_ACODE and AND_ACODE lack E-block support... Adding E-block to AND_SINGLE_ACODE would fix MEDIUM-IMPACT.3.4'). No t/phase0_regression.t assertion pins the [] runtime value as intended (single-regex-AND sites assert only metadata/descriptor/compilation)."
reverify: "perl -Iperl -MLinkedSpec -e 'my $s=\"T::AND\\n /(\\\\w+)=(\\\\w+)/ -> T[0] { return(2) }\\n\"; my $p=LinkedSpec::Get(\\$s); my $in=\"a=b\"; my $v=$p->(\\$in); print defined($v)&&ref($v)eq\"ARRAY\"&&!@$v ? \"STILL_BUGGY_empty_array\\n\":\"CHANGED: \".(ref($v)||$v).\"\\n\"'"
---

# Single-slot AND drops its edge return → `[]` (AND_SINGLE_ACODE regression)

**Confirmed 2026-06-17 (SPEC-LANG-REFERENCE.10 investigation).** A `.spec` parser returns
the top rule's value. For a **single-regex-slot AND rule** with a self-referencing action
edge that returns a value, the value is silently dropped and the parser returns the empty
accumulator `[]`:

```text
Pair::AND
 /(\w+)=(\w+)/ -> Pair[0] { return(array("?pair:", match_group(0), match_group(1))) }
```
Input `key=val` → `[]` (NOT `["?pair:","key","val"]`). Holds under default / `consume` /
`seek` parse modes. Even a terminal `LX { return(...) }` / `E { return(...) }` on a
single-slot AND rule does not surface a value (that variant has no E-block return path).

## Root cause (codegen)

`perl/LinkedSpec/HandlerVariantEmitter.pm` `_emit_and_single_acode_handler` (lines 564-630):
the loop at **575-582** builds `$transformed` for each edge acode but **never pushes it**
into `@acodes_transformed`, so `_build_acodes_dispatch_block(\@acodes_transformed)`
(line 583) receives an empty list, the edge if/elsif dispatch is omitted, and the handler
unconditionally ends `return \@${label}_collect;` (line 628) over a never-written accumulator.

This is an **accidental regression**, not intended: introduced by the **MEDIUM-IMPACT.3.4.x**
emitter rework (`148c746` → `7fec186`); the sibling `_emit_and_acode_seq_handler` received
the same return→assignment edit **with** its `push` (and has its own separate `\$"`
list-separator bug on the return→assignment `s///e`). The gap is pre-documented in
[[specentry-perl-coupling-inventory]] ("AND_SINGLE_ACODE and AND_ACODE lack E-block support").
No regression test pins the `[]` value as intended.

## Idiomatic forms that DO surface a value (verified)

Use these in `.spec` and in book examples that assert a concrete top-level output:

- **OR self-ref edge** (recommended for a single value): `T:: /(\w+)=(\w+)/ -> T { return(hash("k", match_group(0), "v", match_group(1))) }` → `{"k":"answer","v":"42"}` (variant `OR_ACODE`).
- **Multi-slot AND, single closing-slot return**: `T::AND /(\w+)/ /=/ /(\w+)/ -> T[2] { return(array(...)) }` → the array (one acode on a multi-regex rule routes through the `_default` emitter).
- **REP accumulate**: `T::+ /(\w+)/ -> T { return(match_group(0)) }` over `a b c` → `["a","b","c"]`.

Do **not** use the single-slot `::AND … -> Rule[0] { return(...) }` self-edge form to assert
an output until the engine gap is fixed.

## Resolution status

Open fork `SPEC-LANG-REFERENCE.10` (engine-fix vs doc-rewrite). If engine-fix: restore the
dropped `push` + wire the edge result into the collect/return tail (the coupling-inventory
card recommends adding E-block support to `AND_SINGLE_ACODE`), fix the sibling `\$"` bug in
`_emit_and_acode_seq_handler`, run the full `t/phase0_regression.t` gate, and mirror in the
Rust variant for [[cross-variant-output-parity]]. The change is localized to
`HandlerVariantEmitter.pm` (two emitter functions) on the Perl side.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (`.10` fork)
- Related: [[specentry-perl-coupling-inventory]], [[rust-perl-output-oracle]], [[handler-ir-design]]
- Files: `perl/LinkedSpec/HandlerVariantEmitter.pm` (564-630, 635-683, 715-732),
  `perl/LinkedSpec/RuleIR.pm:26-49`, `perl/LinkedSpec/SpecEntry.pm:117-234`
