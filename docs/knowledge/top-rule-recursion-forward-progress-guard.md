---
id: top-rule-recursion-forward-progress-guard
title: "Engine mechanics (TOP-RULE-AS-NORMAL.2.1): recursion re-enters through the SpecEntry runtime-handler closure (`&{$descr->{spec}{$rule}{handler}}(...)`), NOT the dump_parser_source artifact. The per-handler while(1)+LinkedRE::or /gc matching is already forward-progress-safe; the only engine-level hang is an unconditional NO-CONSUME self-recursion. A precise (rule,pos) non-progress cutoff in SpecEntry.pm terminates such cycles with zero phase0 regression. SEPARATE open gap: a recursive rule used AS the top/entry rule returns the wrong value (null) vs the same rule as a body rule (parses) — owned by .2.2."
answers:
  - "where does cross-rule call / recursion actually re-enter at runtime"
  - "is dump_parser_source the real runtime handler code"
  - "what makes the per-handler while(1) loop terminate (forward progress)"
  - "does a zero-width regex match hang the engine handler loop"
  - "what actually hangs the engine on recursion (no-consume cycle)"
  - "how is the forward-progress / consume-before-recurse termination guard implemented"
  - "where is the recursion termination guard in the code"
  - "does the recursion guard affect legitimate consume-before-recurse recursion"
  - "does a top-recursive grammar parse the same as the equivalent body-recursive grammar"
  - "why does a recursive rule as the top rule return null"
date: 2026-06-23
status: confirmed
tags: [engine, parser, top-rule, recursion, termination, forward-progress, SpecEntry, TOP-RULE-AS-NORMAL, ADR-0010]
evidence: "TOOLBOX probes 2026-06-23 (TOP-RULE-AS-NORMAL.2.1). (1) call_spec_handler_subst shows call(rule) lowers to `&{$$descr{spec}{$rule}{handler}}($descr,$STRING,$minfo)` (ActionIR/Contracts.pm:134, MethodLowering.pm:332); {handler} is the SpecEntry::_build_runtime_handler closure (SpecEntry.pm:438 stores it; line ~262 IS it) -- so EVERY cross-rule call + recursion goes through that one real-Perl closure. dump_parser_source emits a SIMPLIFIED standalone artifact (`&{$descr->{spec}{$rule}}`) that differs from the runtime (`{...}{handler}`). (2) LinkedRE::or: seek = `/(?{...})$re/gcp` (scans FORWARD to EOF -> returns undef); consume = `/\\G(?{...})$re/gcp` (Perl's repeated-zero-width-match prohibition + /gc). Battery of zero-width grammars (probe3/probe4, seek+consume) -- NONE hang. (3) The ONLY reproduced engine hang: `top:: /a/ I { return(call(top)) }` whose handler is an unconditional self-tail-call with NO match/while(1) (dependency_regex_map empty); it OOMs. (4) Fix: a (rule,pos) active-stack non-progress cutoff in the SpecEntry runtime-handler closure -- re-entry at a position already active for that rule => return undef. phase0 960->963 (3 new locks), full run_ci_local.sh EXIT 0, zero regression. (5) SEPARATE GAP: a recursive S-expression grammar with `sexpr::` as the top rule returns null on `(a(b)c)`, while the IDENTICAL inner rule reached via a no-consume `top:: -> sexpr {return(call(sexpr))}` wrapper returns `[\"a\",[\"b\"],\"c\"]` -- the off-by-one in who consumes the leading token. Owned by .2.2."
reverify: "perl -Iperl -MLinkedSpec -e 'my $s=\"sexpr:: /\\\\(/ /\\\\)/  I { declare(array, items) }\\n -> sexpr { push_value(a(items), call(sexpr)) }\\n -> atom { push_value(a(items), call(atom)) }\\n -> sexpr[1] { return(array_copy(a(items))) }\\n\\natom: /[A-Za-z0-9]+/ I.return(entry_text())\\n\"; my $p=LinkedSpec::Get(\\$s, top_rule=>\"sexpr\"); my $r=$p->(\\\"(a(b)c)\\\"); print defined $r ? \"def\" : \"null\", \"\\n\";'  # top form currently prints null (.2.2 gap); body form returns the nested AST"
---

# Top-rule recursion: the runtime re-entry seam, the forward-progress guard, and the value gap

**Confirmed 2026-06-23** (`TOP-RULE-AS-NORMAL.2.1`; engine change authorized by ADR
[0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)). Refines
[[top-rule-is-ordinary-rule-entered-first]] with the `.2` ground-truth.

## Where recursion actually re-enters (not what `dump_parser_source` shows)

`call(rule)` / `-> rule` edges lower to `&{$$descr{spec}{$rule}{handler}}($descr, $STRING, $minfo)`
(`ActionIR/Contracts.pm:134`, `MethodLowering.pm:332`). `{handler}` is the closure built by
`SpecEntry::_build_runtime_handler` (stored at `SpecEntry.pm:438`). So **every** cross-rule call and
**every** recursion (top or body) passes through that single real-Perl closure. The
`dump_parser_source` output is a **simplified standalone artifact** (`&{$descr->{spec}{$rule}}`, a
direct CODE deref) and does **not** match the runtime structure (`…{$rule}{handler}`, a HASH with a
handler slot) — read the lowering, not the dump, when reasoning about runtime recursion.

## The per-handler loop already makes forward progress

`LinkedRE::or` (`perl/LinkedRE.pm`): **seek** is `/(?{…})$re/gcp` (no `\G`) — it scans *forward* for
the next match and reaches EOF → `undef`; **consume** is `/\G(?{…})$re/gcp` — anchored, but Perl's
prohibition on a repeated zero-width match at the same position plus `/gc` prevents same-position
spinning. A battery of zero-width / lookahead grammars in both modes (`probe3`/`probe4`) **never
hangs**. So the `while(1)` handler loop is not the non-termination source.

## The real engine hang, and the guard

The one reproduced engine-level hang is an **unconditional no-consume self-recursion**:
`top:: /a/  I { return(call(top)) }` compiles to a handler that is literally
`sub { … return &{…top…{handler}}(…) }` — no match, no `while(1)`, empty `dependency_regex_map` — so it
recurses forever and OOMs. Fix (`perl/LinkedSpec/SpecEntry.pm`, the `_build_runtime_handler` closure):
a **(rule, pos) active-stack non-progress cutoff** — a file-lexical `%__ls_recursion_active` keyed by
`"$descr\0$label\0" . pos`; if a rule is re-entered at a position already active on its own recursion
stack, no input was consumed since the enclosing entry, so the handler returns `undef` to terminate the
branch. Pushed on entry / popped after the eval-wrapped invocation (balanced). Legitimate
consume-before-recurse recursion always advances `pos()` first, so the cutoff never fires for a
terminating grammar — **phase0 960 → 963** (3 new locks), `tools/run_ci_local.sh` **EXIT 0**, zero
regression.

## SEPARATE open gap (owned by `.2.2`): top re-entry returns the wrong value

A recursive S-expression grammar with `sexpr::` **as the top rule** returns `null` on `(a(b)c)`, while
the **identical** `sexpr` rule reached via a no-consume `top:: -> sexpr { return(call(sexpr)) }` wrapper
returns `["a",["b"],"c"]`. The handler source is the same; the divergence is the **entry alignment** —
who consumes the leading token (the body form's wrapper eats the outermost `(` before delegating; the
top form must match its own `(`, which makes the `-> sexpr` recurse edge fire on the open paren). This
is the genuine "make top re-entry behave identically to a body rule" work, **not** the termination
guard — it is owned by `TOP-RULE-AS-NORMAL.2.2`.

## Links

- Decision: [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)
- Tree: [[TOP-RULE-AS-NORMAL]] (`.2.1` guard done; `.2.2` top re-entry value correctness)
- Files: `perl/LinkedSpec/SpecEntry.pm` (`_build_runtime_handler` closure + `%__ls_recursion_active`),
  `perl/LinkedRE.pm` (`or`), `perl/LinkedSpec/ActionIR/Contracts.pm:134`, `t/phase0_regression.t` (3 locks)
- Related: [[top-rule-is-ordinary-rule-entered-first]], [[spec-top-rule-no-regex-two-rule-minimum]],
  [[lispish-corpus-catastrophic-backtracking]], [[cross-variant-output-parity]]
