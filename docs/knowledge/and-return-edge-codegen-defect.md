---
id: and-return-edge-codegen-defect
title: An AND rule with multiple indexed edges and a return(...) edge emits invalid handler Perl (SCALAR(0x…)Rule) — real codegen defect, not stale tests
answers:
  - "why does an AND rule with a return edge fail to compile"
  - "what is the SCALAR(0x...)Top / near \")Top\" codegen error"
  - "why do capture/mark/cursor/entry helpers return undef or empty []"
  - "why does multi_rule_parsers return [] instead of the action payload"
  - "are the phase0 capture/mark back-half failures stale or real"
  - "Bareword found where operator expected at LinkedSpec::generated_handler AND_ACODE"
date: 2026-06-19
status: current
tags: [codegen, and-rule, handler-emitter, regression-gate, phase0]
evidence: "PHASE0-BACKHALF-TRIAGE.1 (2026-06-19): 63 of 173 back-half failures; bisection V1–V4 + dumped generated source"
reverify: "perl -Iperl -e 'require LinkedSpec; my $s=\"Top::AND\\n /a/\\n /b/\\n -> Top[0] { assign(scalar(x), 1) }\\n -> Top[1] { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},parse_mode=>q{consume},runtime_ctx_ref=>\\%c); my $in=q{ab}; my $a=$p->(\\$in); print defined($a)?qq{ast def\\n}:qq{ast UNDEF\\n}; print $c{last_error}{detail}//q{},qq{\\n}'"
---

Established by `PHASE0-BACKHALF-TRIAGE.1` (read-only triage, 2026-06-19). A latent **reference-engine
codegen defect** surfaced (not caused) when the phase0 back half stopped being masked by the
`RTLUTILS-REGEX-HANG`. Accounts for **63 of the 173** back-half failures.

**Trigger:** an `AND` rule with **multiple indexed edges** (`-> Rule[0]`, `-> Rule[1]`, …) where an
edge action contains a lowered `return(...)` payload. The `<Rule>:AND_ACODE` handler emitter replaces
the lowered payload with a **stringified SCALAR ref concatenated with the rule label**:
```
} elsif ($$minfo{index} == 1) {
   SCALAR(0x841821b88)Top = [[@items]]
}
```

**Two symptoms:**
- **Top rule** → Perl syntax error `Bareword found where operator expected … near ")Top" (Missing
  operator before Top?)` → `rule_handler_compile:<Rule> => SKIPPED` → `$parser->(\$in)` returns `undef`.
- **Child rule** (reached via `call`) → compiles but **drops the return payload** → returns `[]`.

**Bisection (engine bytes unchanged):** single-edge AND + capture/mark = OK; multi-edge AND with all
`assign` edges = OK; multi-edge AND + a `return` edge = BROKEN. The per-edge helper lowering itself is
valid (`capture_from(name)` → a well-formed `do { … substr … }`; `return(array("?Top:", …))` →
`return ["?Top:", …]`). The bug is in the AND **multi-branch handler assembly** (emitter), not the
helper lowering. NORMAL (`::`) rules are unaffected.

**Why it matters:** every capture/mark/cursor/entry/current_match source-boundary helper test
(`named_mark_*`, `anonymous_capture_*`, `cursor_*`, `entry_and_match_*`, `whole_input_*`,
`current_match_*`) exercises the helpers via this exact pattern, so all fail. These are **REAL** —
re-blessing the author-written `'?Top:'`/`'?Child:'` expectations would mask the bug. The capture/mark
helper FEATURE is effectively unusable in multi-edge AND rules until this is fixed.

**Likely site:** `perl/LinkedSpec/HandlerVariantEmitter.pm` / `perl/LinkedSpec/SpecEntry.pm` AND-acode
branch assembly (the per-index collector-assignment codegen, where the collector variable name is a
stringified ref instead of `$<name>`).

Fix is tracked as `PHASE0-BACKHALF-TRIAGE.3` (blocked on user authorization to touch the reference
engine — see [[do-not-fix-reference-engine]] if present). Related: [[andplusplus-lx-parser-hang]],
[[handler-ir-design]], [[runtime-input-boundary-validation-regression]].
