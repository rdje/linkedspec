---
id: rust-retired-array-aliases-not-added
title: The retired aliases tail/drop_last/flatten/array_values are NOT added to the Rust backend — parity means matching the Perl reference's recognized helper surface, and the reference no longer recognizes them
answers:
  - "should the Rust backend implement tail drop_last flatten array_values"
  - "does the Perl reference recognize tail drop_last flatten array_values"
  - "are tail drop_last flatten array_values recognized helpers"
  - "why is flat added to the Rust engine but not flatten"
  - "should a new backend implement the retired compatibility aliases"
  - "what does input_end_line and input_end_col compute in the Rust engine"
date: 2026-06-16
status: current
tags: [rust, parity, dsl, compat-aliases, helpers]
evidence: "RUST-PARITY.5.5.2 (2026-06-16): tail/drop_last/flatten/array_values absent from Perl helper-recognition regexes (BootstrapSpec/Core.pm:82, FlowExpr.pm:81,270, MethodLowering.pm:1627,1635), unused in 20 shipped specs, 0 phase0 locks; retired in COMPAT-ALIAS-RETIREMENT.1. Rust engine.rs adds only canonical flat + input_end_line/input_end_col."
reverify: "grep -c '\"flat\" =>' rust/linkedspec-runtime/src/engine.rs; grep -cE '\"tail\"|\"drop_last\"|\"flatten\"|\"array_values\"' rust/linkedspec-runtime/src/engine.rs"
---

The array-edge compatibility aliases `tail` (→`drop_front`), `drop_last` (→`drop_back`),
`flatten` (→`flat`), and `array_values` (→`array_copy`) were **retired** from the Perl
reference in `COMPAT-ALIAS-RETIREMENT.1` (see [[medium-term-alias-retirement-deferred]]).
The current Perl reference does not recognize them: they are absent from every
helper-recognition regex (`perl/LinkedSpec/BootstrapSpec/Core.pm:82`,
`perl/LinkedSpec/ActionIR/FlowExpr.pm:81,270`,
`perl/LinkedSpec/ActionIR/MethodLowering.pm:1627,1635`, which list canonical
`drop_front`/`drop_back`/`flat`/`flat_array`/`array_copy` only), unused in all 20 shipped
`specs/*.spec`, and not regression-locked in `t/phase0_regression.t` (grep count 0). The
book Helper Contract Catalog §Compatibility-Aliases also lists them under "Retired".

**Parity rule for any non-Perl backend:** the goal is matching the Perl reference's
*recognized* helper surface. Because the reference rejects these four aliases, a backend
that implemented them would **diverge** (accept specs the reference rejects), not converge.
So the Rust variant deliberately does **not** add `tail`/`drop_last`/`flatten`/`array_values`.
The catalog's note that "backends may implement them for compatibility" is permissive, not
required — and for a parity-locked backend the parity-correct choice is to leave them out.
Only the **canonical** `flat` (the splice helper `flatten` retired *to*) was genuinely
missing in Rust and was added in `RUST-PARITY.5.5.2`.

That same leaf also added the input-boundary readers, computed without storing marks
(char-based, [[rust-char-based-offsets]]): `input_end_line()` = `1 + (newline count over the
whole input)`; `input_end_col()` = char distance past the last newline, `+1` when the input
has none (parity with Perl `Contracts.pm` `_build_column_read_expr(pos_expr => length($$STRING))`).

Caveat (separate case): `entry_named_map`/`match_named_map` ARE present in Rust as
combined-arm retired aliases of `entry_map`/`match_map` (added in `RUST-PARITY.5.5.1`) — those
are named-capture map readers, not array-edge aliases, and were added before this rule was
settled; they read existing maps and are harmless. A known stale spot: `ROADMAP_V2.md` lines
256–262 still call `tail`/`drop_last` "compatibility alias … remain supported" (pre-retirement
text) — flagged for a Perl-side doc-sync correction.
