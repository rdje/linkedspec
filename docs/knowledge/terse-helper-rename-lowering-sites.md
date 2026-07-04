---
id: terse-helper-rename-lowering-sites
title: "SPEC-FORMAT-TERSE.1.4 ground truth — where the helper-rename targets assign/concat/array_copy/hash_copy are recognized + lowered (Perl reference AND Rust), the alias seam, and the three distinct shapes the terse renames set/cat/copy take. cat=pure rename via _normalize_method_name (MethodExpr.pm:19-26); set=STATEMENT-level (Contracts.pm:1749/1753 \\bassign\\s*\\( + DeclareMethod + MethodLowering._lower_assign_statement) — NOT reached by _normalize_method_name; copy=NOT a pure rename, it unifies array_copy/hash_copy and needs a dedicated dispatch resolving array-then-hash symbol kind. Rust: all four canonical helpers live in one Engine::call_helper() match (engine.rs assign@711, array_copy@735, concat@820, hash_copy@1833; aliases=pipe arms) — copy needs its own value-type-dispatch arm because a literal cannot repeat across the array_copy and hash_copy arms."
answers:
  - "where does assign / concat / array_copy / hash_copy lower in the perl engine"
  - "where are the four helper-rename targets recognized in the Rust engine"
  - "how do I add a new helper alias (set, cat, copy) to LinkedSpec"
  - "what is the alias-normalization seam for DSL helper names (_normalize_method_name)"
  - "does set(name,val) / cat(...) / copy(name) currently lower in the engine"
  - "why is copy(name) not just a rename alias of array_copy / hash_copy"
  - "how should a unified copy() resolve array vs hash"
  - "why is SPEC-FORMAT-TERSE.1.4 split into a Perl reference change plus a Rust parity follow-on"
  - "where is set recognized vs concat / array_copy (statement-level vs value-expr)"
  - "what does set / cat / copy lower to in linkedspec today"
date: 2026-07-04
status: confirmed
tags: [engine, dsl, helpers, aliases, rename, actionir, spec-format-terse, SPEC-FORMAT-TERSE, MethodLowering, rust, parity]
evidence: "TOOLBOX `call_spec_handler_subst` probes 2026-06-24 (`perl -Iperl -MLinkedSpec`, dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm` loads over the stale `PERL5LIB` — TOOLBOX §6.5). BEFORE (the historical gap): `assign(scalar(x),1)`→`$x = 1` but `set(scalar(x),1)`→`set(scalar(x), 1)` (passthrough); `concat(\"a\",\"b\")`→`do { my @__ls_concat_parts = (\"a\", \"b\"); ... join('', @__ls_concat_parts) : undef }` but `cat(\"a\",\"b\")`→`cat(\"a\",\"b\")` (passthrough); `array_copy(a(items))`→`[@items]` but `copy(a(items))`→`copy([items])` (partial — inner `a(items)` lowers but `copy` is unknown); `hash_copy(h(m))`→`{%m}` but `copy(h(m))`→`copy(h(m))` (passthrough). Perl recognition+lowering sites at that leaf: assign was STATEMENT-level (`ActionIR/Contracts.pm` + DeclareMethod + MethodLowering); concat was value-expr; array_copy/hash_copy had separate sigil lowerers. .1.4.1 landed Perl recognition at every canonical-name site; .1.4.2 landed Rust parity. SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file assign(...) and scalar(...) wrapper spelling; current reverify checks the surviving terse names `set`, `cat`, and remembered-kind `copy`."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{set(x, 1)},q{return(cat(\"a\",\"b\"))},q{items = [\"a\"]; return(copy(items))},q{meta = { key => \"v\" }; return(copy(meta))}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_4_2 && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle"
---

# `.1.4` ground truth: where the helper renames land, on both variants

**Confirmed 2026-06-24** via `call_spec_handler_subst` probes + code-read (`SPEC-FORMAT-TERSE.1.4`
ground-truth pass; direction ratified in ADR [0007](../decisions/0007-spec-format-terse-direction.md)).
This is the engine grounding for the terse-format leaf "helper renames `assign`→`set`, `concat`→`cat`,
`array_copy`/`hash_copy`→`copy`", and the reason that leaf was split by variant (Perl-first `.1.4.1` +
Rust parity `.1.4.2`). Direction per ADR 0007: the **new terse names become canonical**, the **old names
stayed deprecated aliases that lower identically** at that point. `SPEC-FORMAT-TERSE.6.2.3.2` later retired
authored spec-file `assign(...)` and the current surface uses `set(...)`, `cat(...)`, and `copy(...)`.

## Status — `.1.4` CLOSED on both variants (2026-06-29)

Both halves are now **done**. `.1.4.1` landed the Perl reference: `set`/`cat`/`copy` lowered
**byte-identically** to the then-supported old names in every position (proven by
`call_spec_handler_subst` parity across 15+ composed forms + a real-spec end-to-end run + the all-20-spec
byte-identical proof; +4 phase0 locks → 975 green; full gate EXIT 0). `.1.4.2` landed Rust
`Engine::call_helper()` parity: `set` and `cat` are pipe-arm aliases, and `copy` is a unified array/hash
value-copy arm locked by Perl-oracle fixtures and integration tests. The site map below is the implementation
ground truth (now extended to recognize the aliases at each site).

### The original gap (pre-`.1.4.1`, for the record)

Before the leaf, all three terse spellings passed through unrecognized — `set(scalar(x),1)`→passthrough
(vs `assign`→`$x = 1`), `cat("a","b")`→passthrough (vs `concat`→the concat do-block),
`copy(a(items))`→`copy([items])` partial / `copy(h(m))`→passthrough (vs `array_copy`→`[@items]` /
`hash_copy`→`{%m}`).

### What `.1.4.1` changed (the full recognition-site set the aliases now cover)

- **`cat`→`concat`** + **`set`→`assign`**: added to the parse-time alias seam `_normalize_method_name`
  (`ActionIR/MethodExpr.pm`), so every parse-based dispatch treats them as the canonical name.
- **`set` (statement-level, raw-text scans)**: extended `\bassign\s*\(`→`\b(?:assign|set)\s*\(` at the
  three raw-text recognizers — the `assign_value` contract (`ActionIR/Contracts.pm`), its IR-event scanner
  `_scan_contract_assign_value` (`ActionIR/Scanner/PrimitivePipelineRules.pm`), and the bare-arg auto-`my`
  collector (`RuleIR/EmitContext.pm` — `.1.2.1` parity, so a bare `set(name,…)` auto-exists like `assign`).
- **`copy` (unified array-vs-hash)**: a dedicated `copy` dispatch in `_lower_method_value_expr`
  (`ActionIR/MethodLowering.pm`, array symbol first then hash, guarded by the `*_symbol_expr_re`), plus
  `copy` added to the array/hash declare-initializer recognizers (`ActionIR/DeclareMethod.pm` 136/163), the
  return-payload guard+rewriter helper lists (`MethodLowering` 1650/1658), and — to keep `copy` first-class
  in array-vs-hash type inference (reducers/coalesce) — the four `looks_like_{array,hash}_value_expr`
  recognizers (`MethodLowering` + `FlowExpr`), which resolve `copy(X)`'s kind array-first.
- **`cat`/`copy` (composite/source positions)**: added to the FlowExpr value-expr prefix list (`FlowExpr.pm`
  :270, the assignment-source path) and `cat` to the bootstrap general-payload gate (`BootstrapSpec/Core.pm`).

## Three distinct implementation shapes (why one alias does not cover the leaf)

1. **`cat`→`concat` is a PURE rename.** The clean home is the alias-normalization seam
   `_normalize_method_name` (`perl/LinkedSpec/ActionIR/MethodExpr.pm:19-26`), applied at
   `MethodExpr.pm:162` *before* lowering — the same seam that already maps `s`→`scalar`, `a`→`array`,
   `h`→`hash`. `concat` is a VALUE-expression method (`MethodLowering._lower_method_value_expr:538`), so a
   normalized `cat` reaches it. *(Confirm the value-expr path runs through `_normalize_method_name` with a
   probe before relying on it.)* The retired `tail`/`drop_last`/`flatten`/`array_values` aliases used the
   **other** historical pattern — inline `|| $method eq 'alias'` conditionals — and were removed in
   `COMPAT-ALIAS-RETIREMENT.1` (commit `802dbe3`); see [[rust-retired-array-aliases-not-added]].

2. **`set`→`assign` is STATEMENT-level — not reached by `_normalize_method_name` alone.** `assign` is
   recognized by the raw-text regex `\bassign\s*\(` at `ActionIR/Contracts.pm:1749/1753` and lowered via
   `ActionIR/DeclareMethod._lower_assign_method_statement` (244-263) → `ActionIR/MethodLowering._lower_assign_statement`
   (1677-1714) ⇒ `$sym = src`. Probe shows `set(...)` is **fully** unrecognized (not even partially
   lowered), so `set` must be added to the statement-level recognition itself (extend the Contracts.pm
   recognition / DeclareMethod dispatch). `.1.4.1` resolves the exact seam with `dump_parser_source`
   (statement-level recognition relative to `_normalize_method_name`).

3. **`copy` is NOT a pure rename — it unifies `array_copy` + `hash_copy`.** `array_copy` lowers to
   `[@sym]` (`MethodLowering:1553`) and `hash_copy` to `{%sym}` (`MethodLowering:1533`) — different sigils.
   A single `copy(name)` must resolve the symbol's kind at lowering time: add a dedicated `copy` dispatch
   in `_lower_method_value_expr` that tries `extract_array_symbol_name` (→ `[@name]`) then
   `extract_hash_symbol_name` (→ `{%name}`).

## Rust parity (`.1.4.2`) sites — LANDED 2026-06-29

All four canonical helpers live in **one** `Engine::call_helper()` match in
`rust/linkedspec-runtime/src/engine.rs` (`assign`@711, `array_copy`@735, `concat`@820, `hash_copy`@1833;
there is NO helper recognition in the parser/compiler crates). Aliases are **inline pipe-separated match
arms** (`"array" | "a"`, `"scalar" | "s"`, `"push_value" | "push"`). `.1.4.2` landed:

- `set`: pipe onto the assign arm — `"assign" | "set" => { … }`.
- `cat`: pipe onto the concat arm — `"concat" | "cat" => { … }`.
- `copy`: a **separate** value-type-dispatching arm (`RuntimeValue::Array(a)` → clone array,
  `RuntimeValue::Hash(h)` → clone hash, else resolve the named target) — a literal **cannot** repeat across
  the `array_copy` and `hash_copy` arms, so `copy` gets its own arm (this matches the Perl array-then-hash
  resolution). The hash-target side uses `resolve_hash_target`, and `hash`/`h` with one bare variable now
  returns the named runtime hash so `copy(h(m))` == `hash_copy(h(m))`. Locked with oracle fixtures +
  integration tests mirroring `.1.2.2`.

## Why this splits `.1.4`

A Perl-reference engine change and its lockstep Rust-parity obligation (ADR
[0006](../decisions/0006-multi-backend-vision.md)) are separable and touch **unrelated ownership areas**
(Perl `ActionIR/*` + `t/phase0_regression.t` + book vs Rust `engine.rs` + oracle corpus + cargo tests),
which `COMMIT.md` forbids bundling — exactly mirroring `.1.1`→`.1.1.1`/`.1.1.2` and
`.1.2`→`.1.2.1`/`.1.2.2`. `.1.4` is now a closed container; the next terse frontier is `.1.3`.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] (leaf `.1.4` → `.1.4.1` Perl / `.1.4.2` Rust parity).
- Direction: [0007](../decisions/0007-spec-format-terse-direction.md) (terse direction, gradual-alias);
  [0006](../decisions/0006-multi-backend-vision.md) (lockstep all variants);
  [0002](../decisions/0002-all-target-actionir-ready-invariant.md) (ratio 1.0000).
- Related: [[terse-bare-working-vars-engine-gaps]] (the `.1.2` ground-truth pass that this mirrors),
  [[rust-retired-array-aliases-not-added]] (the two historical alias patterns; parity = match the
  reference's recognized surface), [[retired-return-helpers-canonical-rewrite]] (`call_spec_handler_subst`
  as the lowering probe), [[actionir-lowering-stack]], [[spec-format-brainstorm-rounds-1-3]].
