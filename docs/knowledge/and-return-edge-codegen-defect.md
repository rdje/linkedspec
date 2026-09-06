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
status: resolved
tags: [codegen, and-rule, handler-emitter, regression-gate, phase0]
evidence: "PHASE0-BACKHALF-TRIAGE.1 (2026-06-19): 63 of 173 back-half failures; bisection V1–V4 + dumped generated source. FIXED by PHASE0-BACKHALF-TRIAGE.3 (2026-06-21): full phase0 dropped 173→111 failing (62 cleared, all cluster-D + named-G AND-codegen tests now pass; zero regressions)."
reverify: bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=qq{Top::AND\n /a/\n /b/\n -> Top[0] { x = 1 }\n -> Top[1] { return(1) }\n};my $p=LinkedSpec::Get(\$s);die q{compile failed} unless ref($p) eq q{CODE};my $in=q{ab};print JSON::PP->new->encode($p->(\$in)),qq{\n};'
---

> **RESOLVED 2026-06-21 (`PHASE0-BACKHALF-TRIAGE.3`, authorized by ADR `0008`).** Root cause was a
> `\$"`-vs-`"\$"` substitution typo in `perl/LinkedSpec/HandlerVariantEmitter.pm`: both
> `_emit_and_acode_seq_handler` (multi-regex AND) and `_emit_and_single_acode_handler` (single-regex
> AND) rewrote an edge `return(...)` into a `$<label> =` assignment using `s/\breturn.../\$" . $label
> . " = "/eg`, where the bare `\$"` evaluates as a *reference to* the list-separator variable `$"`
> (stringifying `SCALAR(0x…)`) — the correct literal form `"\$"` is used at lines 524/594/928. The fix
> emits edge acodes **verbatim** (they are already lowered to `return [...]`), so a `return` edge
> surfaces the author payload directly — from the whole handler in a direct AND, or from the
> per-iteration coderef in a REP-AND (`_emit_rep_and_acode_handler` wraps the body in `sub { ... }`).
> This also fixed the single-acode handler's separate never-`push`ed-acode bug (edge action silently
> dropped → `[]`). All 21 cataloged AND-rule tests return the raw author payload as expected. The card
> below is the original (defect-present) reading, kept for history.

Reverified on 2026-09-06 under `SESSION-STARTUP-READING.3.2.14`: the indexed two-edge
control returns `1`. The command now omits retired `parse_mode`. The separate per-regex
I-block literal/scope defect is owned in [[perl-and-icode-literal-and-state-corruption]];
this historical explicit-edge fix remains resolved.

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
