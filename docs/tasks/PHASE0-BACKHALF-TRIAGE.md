# PHASE0-BACKHALF-TRIAGE: triage the ~173 pre-existing back-half core-engine test failures

## Metadata

- Tree ID: `PHASE0-BACKHALF-TRIAGE`
- Status: `active` (created 2026-06-19)
- Roadmap lane: `Overall roadmap — regression-gate health (back-half core failures)`
- Created: `2026-06-19`
- Last updated: `2026-06-21` (`.2.2.2.2` **DONE** — 4 `return_a`/`return_m` subtests re-blessed to canonical `.return(1).return(array("?Top:", entry_groups()))` + subtest-1 `RETURN_A`/`RETURN_M`→`RETURN` node re-bless, TEST-ONLY; phase0 30→26, `comm` set-diff = exactly the 4 cleared, 0 regressions. Cluster B1 (`.2.2.2`) fully done. Frontier → `.2.3`)
- Owner: repo-local workflow

## Goal

`t/phase0_regression.t`'s back half was dark for a long time behind the `RTLUTILS-REGEX-HANG` +
the legacy-island hangs. With those cleared (`LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE`), the suite
now runs the back half and reveals **173 pre-existing core-engine test failures** (structural/shape
mismatches + 2 codegen/validation defects; 0 missing-module errors). **Not caused by that work** —
engine bytes unchanged; the tests simply never ran. Determine, per cluster and with evidence, whether
each is a **STALE test** (written for engine behavior that has since evolved by intent — fix = re-bless
the expected value) or a **REAL** defect (engine produces wrong output vs its documented contract — fix
= the engine), then report scope/effort. A green `t/phase0_regression.t` unblocks the
`SPEC-FORMAT-TERSE` gate + the Rust/Julia/Dart parity (the regression baseline IS the cross-variant
contract).

## Non-Goals

- Re-litigating the quarantine (`NONCORE-QUARANTINE`, done).
- Touching the reference Perl engine in `.1` (read-only triage). `.3`/`.4` propose engine fixes; per
  [[feedback_do-not-fix-reference-engine]] those need explicit user authorization to touch `perl/`.

## Triage result (`.1`, read-only — DONE 2026-06-19)

> **CORRECTION (2026-06-19 — user directives: "if not broke don't fix" + "do not break the reference Perl
> engine").** The "REAL → engine-fix" framing below is **SUPERSEDED / overclaimed**. The 65 non-stale
> failures are **NOT confirmed reference defects** — there is only an OBSERVED bad-codegen *symptom* for
> an explicit `:AND`/`::AND` multi-slot rule with a `return`-bearing indexed edge (parser builds, then
> emits invalid Perl `SCALAR(0x…)Rule` ⇒ returns `undef`/`[]`). Whether that is a genuine defect vs.
> tests exercising a **non-conformant / undocumented construct is UNRESOLVED**: `:AND` is documented, but
> (a) NO shipped spec uses explicit `:AND` (all default mode), (b) the failing specs put regex on a `::`
> top rule which `formal-grammar.md` marks "Body rule only", and (c) the book's only `:AND` example
> (`ThirdChild:AND`, formal-grammar.md:625) uses call edges `-> A/-> B`, **not** a `return` edge. **The
> reference engine is FROZEN.** `.3`/`.4` must NOT touch `perl/` unless a fully BOOK-CONFORMANT `:AND`
> spec is OBJECTIVELY shown to break AND the user authorizes. Default remedy for the 65 = re-bless/retire
> the tests (TEST-ONLY). "Defect #2 (input-boundary)" was sub-agent-claimed and NOT verified. **The 108
> STALE verdicts stand and are test-only.** Read this banner over the section below.
>
> **UPDATE (2026-06-21 — authorization given; see ADR `0008`).** A fresh session re-verified BOTH
> defects objectively, read-only: (1) the book's OWN `:AND` worked example
> (`user-model/rule-modes-and-parse-modes.md:124-133`) breaks with the `SCALAR(0x…)Pair`/`near ")Pair"`
> codegen error — so a documented-but-self-inconsistent `:AND` example does break; (2) Defect #2 is now
> CONFIRMED (`Not a SCALAR reference at … Runtime.pm line 126`, empty `last_error`). The user then
> **authorized BOTH engine fixes** (ADR `0008`). Root cause of #1 is now pinned to a `\$"`-vs-`"\$"`
> substitution typo in `HandlerVariantEmitter.pm` (`_emit_and_acode_seq_handler` /
> `_emit_and_single_acode_handler`). The book's non-conformant `:AND` example is ALSO corrected (docs
> lane) so the surface and the fixed engine agree. The engine-frozen doctrine otherwise stands.

Authoritative run: `perl -Iperl t/phase0_regression.t` → **173 failing subtests / 707 passing**
(reached subtest 880/959 before the background run was terminated, exit 144 mid-subtest-881; the 173
matches the known deterministic count). Full TAP captured to `/tmp/phase0_triage.tap` (transient).

### Verdict by cluster (all 173 reconciled)

| Cluster | Count | Verdict | Root cause |
| --- | --- | --- | --- |
| **A** parser-collection-shape (`or_plus_blind_call`, `explicit_and`, `blind_call_*`, `and_plus`, `bounded_and`) | 8 | **STALE** | engine returns each child's `return(1)` ⇒ `[1,1]`; test asserts retired auto-tag shape `[['?First:',[]],…]` |
| **B** `method_like` (incl. lifecycle/switch branch-block forms) | 75 | **STALE** | retired `return_a/return_m/return_ma/return_imatch/return_im/return_array` helpers + `RETURN_A/RETURN_M` nodes (COMPAT-ALIAS-RETIREMENT-V2, 2026-06-14). 20 use a retired helper in the spec body; 55 hard-code a retired node (`RETURN_A`) in the assertion. Branch-block canonical lowering itself is intended/working/book-documented. |
| **C** `emit_context` | 21 | **20 STALE + 1 REAL** | 20 = white-box seams that monkeypatch now-removed `LinkedSpec::Deps::*` (traps can't fire; only the retired-`return_a`-shape output asserts fail) + retired-helper passthrough + a stale `plan 89` (88 run) + one mis-authored re-bless (`a(IMATCH)`⇒`[IMATCH]` is correct). 1 REAL = `emit_context_lowers_push_nonempty_method_contract` test 13 (AND-codegen defect). |
| **D** capture/mark/cursor/entry/current_match/whole_input | 60 | **REAL** | AND-rule action-codegen defect (see Defect #1). |
| **F** descriptor/metadata migration-summary | 3 | **STALE** | specs use `return(1)`; tests expect it classified as a `return_a` blocker (unresolved). Engine correctly treats `return(1)` as a resolved plain return ⇒ ready, not blocked. |
| **G** singles | 6 | **2 STALE + 4 REAL** | 2 STALE = `return(1)` AST-shape re-bless (`bootstrap_registry_curly_brace_recursion_smoke`, `get_avoids_runtime_run_get_from_args_wrapper` — expect ARRAY, engine returns scalar `1`). 4 REAL: `anonymous_and_named_capture_boundaries_can_bridge_explicitly` + `multi_rule_parsers_default_to_first_rule_and_honor_explicit_top_rule_option` (Defect #1); `parser_invalid_input_fails_at_runtime_parser_boundary` + `get_parser_runtime_ctx_ref_records_invalid_input_ref_with_spec_identity` (Defect #2). |

**Totals: 108 STALE (re-bless) · 65 REAL (engine-fix), across 2 distinct engine defects.**

### REAL Defect #1 — AND-rule action-codegen (63 subtests: D=60, C `lowers_push` t13, G `anonymous_and_named_capture`, G `multi_rule_parsers`)

An `AND` rule with **multiple indexed edges** (`-> Rule[0]`, `-> Rule[1]`, …) where an edge action
contains a lowered `return(...)` payload emits broken `<Rule>:AND_ACODE`. Dumped generated source:
```
} elsif ($$minfo{index} == 1) {
   SCALAR(0x841821b88)Top = [[@items]]
}
```
The lowered payload is replaced by a **stringified SCALAR ref concatenated with the rule label**
(`SCALAR(0x…)Top = …`). Two symptoms:
- **Top rule** ⇒ Perl syntax error `Bareword found where operator expected … near ")Top" (Missing operator before Top?)` ⇒ `rule_handler_compile:<Rule> => SKIPPED` ⇒ parser returns `undef`.
- **Child rule** (reached via `call`) ⇒ compiles but **drops the return payload** ⇒ returns `[]`.

Bisection (engine bytes unchanged): single-edge AND + capture/mark = OK; multi-edge AND with all
`assign` edges (no `return`) = OK; multi-edge AND + a `return` edge = BROKEN. Per-edge helper lowering
(`capture_from`, `return(array(...))`, `assign`) is individually valid Perl — the bug is in the AND
multi-branch handler **assembly** (emitter), not the helper lowering. NORMAL (`::`) rules unaffected.
Likely site: `perl/LinkedSpec/HandlerVariantEmitter.pm` / `perl/LinkedSpec/SpecEntry.pm` AND-acode
branch assembly. See [[and-return-edge-codegen-defect]].

### REAL Defect #2 — input-boundary-validation regression (2 subtests: G `parser_invalid_input`, G `get_parser_runtime_ctx_ref`)

`perl/LinkedSpec/Runtime.pm:~126` (comment-skip wrapper added by `MEDIUM-IMPACT.3.2`, commit `d7294d0`)
runs `pos($$input_ref) = 0;` **before** delegating to the parser that holds the documented input-boundary
guard (`Compiler.pm:~1113`). For non-SCALAR-ref input it dies with a raw `Not a SCALAR reference at
… Runtime.pm line 126` instead of the friendly `Top-level parser expects a SCALAR reference input; got
ARRAY`, and `runtime_ctx->{last_error}` is never populated. (Agent-identified; confirm exact line at
fix time.) See [[runtime-input-boundary-validation-regression]].

## Acceptance Criteria (`.1`, read-only) — MET

- ✅ Complete failure inventory (173 names + got/expected) captured + bucketed.
- ✅ Per-cluster verdict (STALE re-bless vs REAL engine-fix), each backed by got/expected vs the
  documented contract + direct reproductions.
- ✅ Scope/effort: 108 re-bless vs 65 engine-fix (2 defects) + recommended fix order, decomposed into
  `.2`–`.5`. No code change.

## Task Tree

- ID: `PHASE0-BACKHALF-TRIAGE` · Status: `active` · Children: `.1` (done), `.2`, `.3` (done), `.4` (done), `.5`, `.6`
- ID: `PHASE0-BACKHALF-TRIAGE.1` · Status: `done` (2026-06-19)
  Goal: Read-only cluster-by-cluster stale-vs-real triage of the 173 failures, with evidence + scope.
  Acceptance: per-cluster verdict + scope/effort + recommended fix plan, decomposed into `.2+`. **Met.**
  Verification: full phase0 TAP run + 5 direct reproductions (cluster D bisection, capture/mark lowering,
    entry_and child-rule `[]`, return(1) AST shape) + 2 parallel read-only deep-dives (B; C+F+G).
  Commit: (this commit)
- ID: `PHASE0-BACKHALF-TRIAGE.2` · Status: `active` · Children: `.2.1`–`.2.4`
  Goal: Re-bless / retire the 108 STALE subtests against the current documented engine behavior.
  - ID: `.2.1` · Status: `done` (2026-06-21) — Cluster A: re-blessed parser-collection-shape to the
    current `[1,1]`-style child-return output (dropped the retired auto-tag `['?Rule:',[]]` expectation).
    **Actual count = 7, not the triaged "8"** — subtests 144/149/152/153/156/163/166
    (`or_plus_blind_call`/`explicit_and`/`blind_call_choice`/`blind_call_repeated_choice`/
    `blind_call_bounded_and_shorthand_repeated_choice_runtime`/`and_plus`/`bounded_and`). The triage's
    8th (`blind_call_fluent_post_call_chain_matches_block_form`, subtest 206) is actually a retired-
    `return_a` helper failure, so it re-buckets to cluster B (`.2.2`), not the auto-tag family.
    TEST-ONLY (13 `is_deeply` expecteds in `t/phase0_regression.t`; engine untouched). Got-values
    captured empirically (`Choice::OR+`/`::AND`/`::|`/`AND+`/`AND{N,M}` repros) before re-blessing.
  - ID: `.2.2` · Status: `active` · Children: `.2.2.1`, `.2.2.2` — Cluster B (76): re-bless the
    `method_like` family + the re-bucketed `blind_call_fluent_post_call_chain_matches_block_form`.
    **Split 2026-06-21** after read-only recon + empirical probing (too broad + partly judgment-heavy for
    one signoff slice). Recon classified the 76: **B1 = 18** (retired helper in the spec body),
    **B2 = 55** (retired `RETURN_A`/`RETURN_M` node token in an assertion, no helper in body), **BOTH = 3**
    (`method_like_action_chain_parses_into_multiple_helper_events` @39213,
    `method_like_full_lifecycle_inline_composite_switch_attached_branch_blocks_lower_equivalently` @20105,
    `method_like_lifecycle_inline_composite_switch_attached_branch_blocks_lower_equivalently` @17289).
    Empirical engine facts (see KM [[actionir-return-node-retired-to-return]]): the canonical return node
    is now **`RETURN`** (not `RETURN_A`/`RETURN_M`); the retired helpers `return_a/return_m/return_ma/
    return_imatch/return_im/return_array` fall to **`RAW_PERL` fallback** (`call_spec_handler_subst`
    returns them unchanged). **Scope hazard:** `RETURN_A` appears 90× across cluster B, cluster C
    (`emit_context`, 12400/12588/12628 → `.2.3`), and apparently-passing helper-event tests
    (39526/39553/39581) — **NOT a global search-replace**; scope every edit to a specific failing subtest.
  - ID: `.2.2.1` · Status: `done` (2026-06-21) — Cluster B2 (TEST-ONLY token re-bless). Re-blessed
    `RETURN_A` → `RETURN` across the failing pure-B2 `method_like*` subtests via a guarded one-pass
    transform of `t/phase0_regression.t`: **52 Form-A flips** (`scalar(grep { $_ eq 'RETURN_A' }
    @{$X->{canonical_action_ir_nodes}})`, X ∈ attached_meta/marker_meta/meta) + **19 Form-B hit-hash
    merges** (`RETURN += 1`, the adjacent `RETURN_A => 1` key deleted — RETURN_A retired→RETURN so the
    counts collapse into one `RETURN` key, never two colliding keys) + **2 stale description strings**
    (`…DECLARE/ASSIGN/RETURN/RETURN_A helper mix` → `…DECLARE/ASSIGN/RETURN helper mix` at @39384). The
    transform **asserted** every target's exact shape (Form-A count == 52; each Form-B `RETURN_A` adjacent
    to a `RETURN => N`) and refuses to write on any drift. **Excluded** (untouched, 17 `RETURN_A` remain):
    the 14 cluster-C `emit_context` sites (incl. the passing `helper_action_ir_events`/`helper_action_ir_nodes`
    kind sites → `.2.3`) + the 3 BOTH subtests (17354 @17289, 20177 @20105, 39209 @39213 → `.2.2.2`).
    **Actual cleared = 55** (matches the triaged B2 estimate). Engine/spec untouched.
  - ID: `.2.2.2` · Status: `done` (2026-06-21 — both children done; cluster B1 fully re-blessed, 21 phase0 failures cleared across `.2.2.2.1`+`.2.2.2.2`) · Children: `.2.2.2.1`, `.2.2.2.2` — Cluster B1 (21 = 18 helper-rewrite
    + 3 BOTH, judgment-heavy). **Split 2026-06-21** after a read-only recon (per-subtest helper map) + an
    archaeology agent that recovered & empirically verified the canonical rewrite of each retired helper
    (KM [[retired-return-helpers-canonical-rewrite]]). Recon mapped the 21 failing B1 subtests by retired
    helper: **17 use `return_array`** (incl. 2 BOTH @17289 + @20105) and **4 use `return_a`/`return_m`**
    (incl. the 3rd BOTH `method_like_action_chain_parses_into_multiple_helper_events` + `blind_call_fluent_
    post_call_chain_matches_block_form`). The two helper families have different blast radius: `return_array`
    is a **pure alias** (old output == canonical `return(array(...))` output, first label arg dropped,
    barewords auto-quoted → mostly an input-string rewrite, expected often already canonical), whereas
    `return_a`/`return_m` add a `"?L:"` tag + `array_copy(array(L))`/`entry_groups()` (the dumped shape
    changes → re-dump + re-bless required). Split accordingly.
  - ID: `.2.2.2.1` · Status: `done` (2026-06-21) — Cluster B1-array (17 `return_array` subtests). **Pre-implementation
    recon DONE 2026-06-21 (read-only) — execute mechanically from here.** Subtests at (post-`.2.2.1`)
    L16582/16636/16668/16709/16750/16794/16838/16879/16920/16963/17208/17289/17373/17419/20105/21720/21784.
    **CRITICAL SCOPE WARNING:** `return_array` appears **74× in the file = 34 in failing subtests / 40 in
    PASSING subtests**; the spec-body strings are **byte-identical** across failing+passing (the switch-case
    families), so this is **NOT a global replace — line-scope to the 17 ranges above**. Also **EXCLUDE** the
    cluster-C `emit_context_avoids_removed_linkedspec_lowering_facade` `return_array` site (~L12440, a
    `rewrite_action_code_for_compat` arg → belongs to `.2.3`) — it is inside a *failing* subtest but is NOT
    B1-array. Net targets: **33 spec-body occurrences + 1 subst-arg (L16601)**.
    **Forms (verified):** 9× `.return_array(…)` (fluent-chain tail), 9× `; return_array(…) }` (block tail),
    10× bare line `return_array(semantic_annotation, hash("items", array(events)))`, 5× `if(…)`-mixed inline,
    1× subst-arg (L16601: `call_spec_handler_subst('Top','return_array(Top, semantic_annotation, hash(…))')`).
    **Verified rewrite rule (empirically confirmed via `LinkedSpec::Get`):** spec-body
    `return_array(semantic_annotation, X)` → `return(array("semantic_annotation", X))` yields
    `fallback_count=0`/`raw_perl_dependency_count=0`/`ready=1` with fluent `ACODE`==block `ACODE` and equal
    node coverage. **These spec-body subtests pin NO literal output** (only fluent==block + `fallback==0` +
    `ready` + node-equality), so the rewrite passes regardless of label semantics — just apply it
    **identically to both the fluent and block specs**. The subst-arg L16601 rewrites the input to
    `return(array("semantic_annotation", hash(…)))` (drop the `Top` label); its `is(...)` expected
    (`return ["semantic_annotation", {…}]`) is **already canonical**. **Paren note:** `return(array(` opens
    two parens where `return_array(` opened one → add exactly **one** matching close paren at the
    return_array call's end (naive paren-count is safe: no parens inside the `"items"`/`/^[A-C]/` literals).
    Verify with `perl -c` + full-suite `comm` set-diff (cleared = exactly the 17; new = none). Mechanical
    but multi-form — a guarded line-scoped transform that asserts the occurrence count, like `.2.2.1`.
    **DONE 2026-06-21 (TEST-ONLY, `t/phase0_regression.t`; engine/spec untouched).** A guarded line-scoped
    transform (matching-paren-aware) rewrote **33 in-range occurrences** (the recon's "34" was off by one;
    real split = **74× file-wide → 32 spec-body + 1 subst-arg in-range, 41 left in passing/EmitContext sites**)
    of `return_array(<Top,> semantic_annotation, X)` → `return(array("semantic_annotation", X))` — drops the
    `Top` label only on the L16601 subst-arg, quotes the leading bareword, inserts exactly one matching close
    paren — scoped to the 17 subtest line-ranges, asserting `rewrites == in-range count` + file-wide
    `return_array(` delta == rewrites, die-before-write on drift; dry-run diff inspected in full before apply.
    **Recon correction:** the 2 BOTH subtests (`…lifecycle_inline_composite_switch_attached_branch_blocks`
    @17289, `…full_lifecycle_inline_composite_switch_attached_branch_blocks` @20105) do **not** "pin no literal
    output" — each pins a literal `canonical_action_ir_hits` hash carrying the now-stale `RETURN_A => 1`. That
    was the deferred `.2.2.1` Form-B merge: re-blessed `RETURN 2→3`, dropped `RETURN_A`, **empirically dumped**
    (`{…RETURN=>3…}`, fallback=0, ready=1, tag-independent I==LX) before writing — not assumed. L16601's pinned
    `is(...)` expected confirmed unchanged-and-canonical via `call_spec_handler_subst`. `perl -c` OK; full
    `perl -Iperl t/phase0_regression.t` **47 → 30 failing**; `comm` name set-diff = **exactly the 17 cleared,
    new-failure set empty**.
  - ID: `.2.2.2.2` · Status: `done` (2026-06-21) — Cluster B1-accumulator (4 subtests: `method_like_action_chain_
    parses_into_multiple_helper_events` @~39195 [BOTH], `method_like_fluent_and_structured_blocks_lower_
    equivalently` @~39213, `method_like_structured_blocks_accept_optional_semicolons` @~39276,
    `blind_call_fluent_post_call_chain_matches_block_form` @~6337). Rewrite `.return_a()`/`.return_m()` /
    `return_m(Top)` to the canonical tagged forms per KM [[retired-return-helpers-canonical-rewrite]]
    (`return_a(L)`→`return(array("?L:", array_copy(array(L))))`; `return_m(L)`→`return(array("?L:",
    entry_groups()))`), re-dump, and re-bless the dependent `is_deeply`/node-coverage assertions. **Per-test
    judgment:** some assert retired-*feature* coverage (`RETURN_A`/`RETURN_M` nodes from a chained return) —
    decide whether to re-bless to the canonical `RETURN` node (now a single node, so `.return_a().return_m()`
    yields `RETURN`×? — confirm the count) or retire the now-meaningless distinct-node assertion. The
    fluent-vs-block `ACODE`/`ICODE` equality assertions must also be re-checked. Highest risk; do after
    `.2.2.2.1`.
    **DONE 2026-06-21 (TEST-ONLY, `t/phase0_regression.t`; engine/spec untouched).** Ground-truth-first:
    a pre-flight probe (`LinkedSpec::Get`) settled every uncertainty before any edit. **Empirical findings:**
    (a) the no-arg chained `.return_a().return_m()` and the block `{ return(1); return_m(Top) }` both fall to
    `RAW_PERL` (fallback>0) — the failure cause; (b) `RETURN_A`/`RETURN_M` are retired into a single `RETURN`
    node, so subtest-1's distinct-node asserts test a dead feature; (c) the canonical chain
    `.return(1).return(array("?Top:", entry_groups()))` lowers identically to the block
    `{ return(1); return(array("?Top:", entry_groups())) }` (`fallback=0`, `ready=1`,
    `nodes=[IMATCH_GROUPS_READ, RETURN]`, `hits={IMATCH_GROUPS_READ=>1, RETURN=>2}`); (d) blind-call fluent
    `.return(1)` produces byte-identical BCODE to block `{ return(1) }`. **Rewrites (8 lines, 4 subtests):**
    `.return_a().return_m()` → `.return(1).return(array("?Top:", entry_groups()))` (×3, replace_all — exactly
    3 file-wide, all targets); block `return_m(Top)` → `return(array("?Top:", entry_groups()))` (×2, line-scoped
    — `return_m(Top)` is 3× file-wide but @39745 is a *passing* non-target, excluded); blind-call `.return_a()`
    → `.return(1)` (@6342); subtest-1's two `grep RETURN_A`/`grep RETURN_M` node asserts re-blessed to
    `grep RETURN` + `is(hits{RETURN}, 2)` (the distinct-variant feature is retired). **Scope:** the 4 passing
    `return_a(pipe_operator)` sites + `return_m(Top)`@39745 + `return_imatch`@12436 (→`.2.3`) + the negative
    source-assert @41730 all untouched. A pre-flight probe replicated **every assertion of all 4 subtests** →
    all PASS (plan counts unchanged). `perl -c` OK; full `perl -Iperl t/phase0_regression.t` **30 → 26
    failing**; `comm` name set-diff = **exactly the 4 cleared, new-failure set empty** (verified on a complete
    TAP reaching the corpus tail; an earlier run was SIGALRM-killed by transient external load-32 CPU
    contention — a fresh low-load run gave the clean diff).
  - ID: `.2.3` · Status: `pending` — Cluster C (20): re-bless/retire the `emit_context` white-box tests
    — fix the stale `plan` (88), re-bless `return_imatch`/`return_array` passthrough + the `a(IMATCH)`
    case, and **delete or rewrite** the seams that monkeypatch the removed `LinkedSpec::Deps::*` (they
    exercise a non-existent seam — prefer delete/rewrite over re-bless).
  - ID: `.2.4` · Status: `pending` — Cluster F (3) + Cluster G STALE (2): re-bless the `return(1)`
    migration-summary metadata (resolved, not blocked) + the `return(1)` AST-shape (scalar `1`).
- ID: `PHASE0-BACKHALF-TRIAGE.3` · Status: `done` (2026-06-21 — **authorized by ADR `0008`**)
  Goal: **Engine fix** — AND-rule action-codegen defect (#1). Fix the AND multi-branch handler
    assembly so a `return(...)` edge emits a valid collector assignment (not `SCALAR(0x…)<Rule>`).
    Unblocks 63 subtests + makes capture/mark/cursor/entry helpers usable in multi-edge AND rules.
  Root cause (confirmed 2026-06-21, fresh-session re-verify + generated-source dump):
    `HandlerVariantEmitter.pm` `_emit_and_acode_seq_handler` (multi-regex AND) and
    `_emit_and_single_acode_handler` (single-regex AND) use the mis-written substitution
    `s/\breturn\s*/\$" . $label . " = "/eg` — the bare `\$"` evaluates as a *reference to* the
    list-separator var `$"` (stringifies `SCALAR(0x…)`), where the correct form (already used at
    lines 524 & 594) is `"\$" . $label . " = "` (literal `$`). Generated-source dump for
    `named_mark_capture_from_reads_rule_local_checkpoint` shows `SCALAR(0x…)Top = [...]` and a
    `return \@Top_collect` that is never pushed to. The test contract expects the **raw edge payload**
    (`['?Top:','bar']`), i.e. an AND edge `return(X)` should make the handler **return X directly** —
    the transform-to-assignment+collect model (borrowed from REP) is wrong for a single-pass AND.
  Acceptance: book `Pair::AND` + the named-mark reproducer compile and return the author payload; the
    63 subtests pass; no NORMAL/`assign`-only-AND/bcode-AND/REP/OR regression; full phase0 re-run shows
    the 63 cleared. **MET.**
  Fix: `perl/LinkedSpec/HandlerVariantEmitter.pm` — `_emit_and_acode_seq_handler` +
    `_emit_and_single_acode_handler` now emit edge acodes verbatim (removed the broken
    `s/\breturn.../\$" . $label . " = "/eg` ref-stringification + the single-acode never-`push` drop).
  Verification (2026-06-21): `perl -c` clean (emitter + facade); reproducers return the raw author
    payload (`['?Top:','bar']`); full `perl -Iperl t/phase0_regression.t` = **173 → 111 failing (62
    cleared)** — all 60 cluster-D + named-G AND tests + C-t13 `push_nonempty` pass; remaining 111 =
    108 STALE (`.2.x`) + 2 Defect #2 (`.4`) + 1 `corpus_regression` tail (`.5`); zero regressions.
  Commit: (this commit)
- ID: `PHASE0-BACKHALF-TRIAGE.4` · Status: `done` (2026-06-21 — **authorized by ADR `0008`**)
  Goal: **Engine fix** — input-boundary-validation regression (#2). Make the `Runtime.pm` comment-skip
    wrapper guard its deref (or run the documented SCALAR-ref validation ahead of it) so invalid input
    yields the friendly boundary error + populated `runtime_ctx->{last_error}`. Unblocks 2 subtests.
    Defect #2 **re-confirmed objectively 2026-06-21**: `Not a SCALAR reference at … Runtime.pm line 126`
    with empty `last_error` (was unverified in the prior session). **MET.**
  Fix: `perl/LinkedSpec/Runtime.pm` — gate the `pos($$input_ref)=0` reset + leading-comment/blank-skip
    behind `if (ref($input_ref) eq 'SCALAR')` (mirrors `Compiler.pm:1109` `ref ne 'SCALAR'`) and always
    delegate to `$original_parser->($input_ref)`, so the documented inner guard fires for invalid input.
  Verification (2026-06-21): `perl -c` clean; reproducer → friendly error + populated `last_error`
    (`type=runtime_parser`), valid scalar-ref input still parses; full `perl -Iperl t/phase0_regression.t`
    = **111 → 109 failing**, set-diff vs post-`.3` = exactly the 2 Defect #2 subtests cleared, zero
    regressions. Blocker: **cleared 2026-06-21** (ADR `0008`).
  Commit: (this commit)
- ID: `PHASE0-BACKHALF-TRIAGE.5` · Status: `pending`
  Goal: Verify a fully green `t/phase0_regression.t` end-to-end (all 959 subtests), including the
    881–959 tail not observed in the `.1` run (the run was terminated at subtest 881; confirm no fresh
    hang at `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`/`corpus_regression`). Then flip the
    downstream gates (`SPEC-FORMAT-TERSE`, `LEGACY-VHDL-RETIRE.4/.5`, `NONCORE-QUARANTINE.V`).
  Verification: `pending`  ·  Commit: `pending`
- ID: `PHASE0-BACKHALF-TRIAGE.6` · Status: `pending` (added 2026-06-21)
  Goal: Book `:AND` reconciliation. With Defect #1 fixed, an `::AND` top rule carrying regex slots +
    indexed edges with a `return(...)` edge now compiles and returns the raw author payload (the engine
    contract the cluster-D/G tests encode). But `appendix/formal-grammar.md:66-78` marks every `:AND`
    mode "Body rule only" and `worked-spec-walkthrough.md:119-124` + `what-is-linkedspec.md:45` say a
    top `::` rule "carries no regex" — both now contradicted by the engine+tests. Reconcile the book so
    it neither misleads (the broken `Pair::AND` example) nor contradicts the engine, while preserving the
    recommended 2-rule idiom ([[spec-top-rule-no-regex-two-rule-minimum]]) as *style guidance* distinct
    from *engine capability*. Likely needs a short user policy check: document `::AND`+regex as a
    supported form vs. keep steering authors to the 2-rule idiom (or both — "supported but not idiomatic").
  Acceptance: no book `.spec` example is broken or doctrine-contradictory; the "Body rule only" /
    "no regex on top" claims are corrected or reframed as idiom; `mdbook build` exit 0; outputs verified
    via `LinkedSpec::Get`.
  Verification: `pending`  ·  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.3` | `done` 2026-06-21 | AND-codegen fix landed — 62 phase0 failures cleared, zero regressions. |
| — | `.4` | `done` 2026-06-21 | input-boundary guard landed — 2 cleared, zero regressions. Both engine defects now fixed. |
| — | `.2.1` | `done` 2026-06-21 | Cluster A re-bless (7, not 8) — 109 → 102 failing, `comm` set-diff = exactly the 7, zero regressions. TEST-ONLY. |
| — | `.2.2` | `active` (split 2026-06-21) | Cluster B (76) decomposed → `.2.2.1` (done) + `.2.2.2` (split). |
| — | `.2.2.1` | `done` 2026-06-21 | Cluster B2 re-bless — 55 pure-B2 `method_like*` cleared (102 → 47 failing), `comm` set-diff = exactly 55, zero real regressions (lone `parser_invalid_input` flake disproven by a clean re-run). TEST-ONLY. |
| — | `.2.2.2` | `active` (split 2026-06-21) | Cluster B1 (21) decomposed → `.2.2.2.1` (17 `return_array`) + `.2.2.2.2` (4 `return_a`/`return_m` incl. 3 BOTH), after recon + verified helper-mapping archaeology (KM [[retired-return-helpers-canonical-rewrite]]). |
| — | `.2.2.2.1` | `done` 2026-06-21 | Cluster B1-array re-bless — 33 `return_array`→`return(array("semantic_annotation",…))` rewrites + 2 BOTH literal hit-hash re-blesses (`RETURN_A`→`RETURN`), TEST-ONLY; phase0 47→30, `comm` set-diff = exactly the 17 cleared, 0 regressions. |
| — | `.2.2.2.2` | `done` 2026-06-21 | Cluster B1-accumulator re-bless — 4 `return_a`/`return_m` subtests rewritten to canonical `.return(1).return(array("?Top:", entry_groups()))` + subtest-1 `RETURN_A`/`RETURN_M`→`RETURN` node re-bless, TEST-ONLY; phase0 30→26, `comm` set-diff = exactly the 4 cleared, 0 regressions. |
| 1 | `.2.3` | `pending` | Cluster C `emit_context` ×20 (white-box; delete/rewrite removed-`Deps::*` monkeypatch seams + stale `plan` + passthrough re-bless). |
| 2 | `.2.4` | `pending` | Cluster F (3) + G STALE (2): `return(1)` migration-summary + AST-shape re-bless. |
| 3 | `.5` | `pending` | Green-phase0 verification (incl. the `corpus_regression` subtest-941 tail) + downstream gate flips. |
| 4 | `.6` | `pending` | Book `:AND` reconciliation: the now-fixed `::AND`+regex+return form vs the book's "Body rule only" / "no regex on top" idiom statements. |

Recommended order once authorized: `.3` → `.4` → `.2.1`–`.2.4` → `.5` (fix the engine first so re-bless
never freezes buggy output; the 108 stale expectations are independent of the engine fixes, so `.2.x`
can also proceed in parallel if the engine touch is deferred).

## Decisions

- `2026-06-19`: User chose "triage read-only first" (over fix-iteratively or defer). **Vindicated** —
  re-blessing cluster D (60) would have masked a real AND-codegen defect.
- `2026-06-19`: Triage complete. 108/173 STALE (re-bless), 65/173 REAL across 2 engine defects. The two
  big stale families trace to *intentional* engine changes (COMPAT-ALIAS-RETIREMENT-V2 retired the
  `return_*` helpers/`RETURN_A` nodes; `return(1)` is a plain resolved return). The engine is correct
  for all 108 stale cases. **Open decision (user):** authorize touching the reference engine for `.3`/`.4`
  (genuine codegen/validation bugs — invalid Perl + pre-empted validation, not docs-vs-reference drift).

## Open Questions

- ~~Authorize the reference-engine fixes (`.3`/`.4`)?~~ **RESOLVED 2026-06-21** — user authorized BOTH
  engine fixes (ADR `0008`); the engine-frozen doctrine otherwise stands (this is the named exception).
- Did subtests 881–959 run clean? The `.1` run stopped at 881; `MEMORY` claims a ~940–959 reach with 173
  total, implying 881+ are clean — confirm in `.5` with a longer-budget run.

## Blockers

- ~~`.3`/`.4` blocked pending user authorization to touch the reference Perl engine.~~ **CLEARED
  2026-06-21 (ADR `0008`).** Green phase0 (and `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` /
  `NONCORE-QUARANTINE.V`) stays blocked until both engine defects are fixed AND the 108 stale are
  re-blessed AND `.5` verifies the full 959-subtest run.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | `.1` | full phase0 TAP (173 fail/707 pass); cluster-D V1–V4 bisection; capture_from/return-array lowering isolation; entry_and child `[]` repro; 2 parallel read-only deep-dives (B; C+F+G) | `done` — 108 STALE / 65 REAL (2 defects) |
| `2026-06-21` | `.3` | `perl -c` (emitter+facade); generated-source dump; book `Pair::AND` + named-mark reproducers; 21-test AND contract catalog; full `perl -Iperl t/phase0_regression.t` | `done` — 173 → 111 failing (62 cleared, 0 regressions) |
| `2026-06-21` | `.4` | `perl -c` (`Runtime.pm`); invalid-ARRAY-input + valid-scalar-ref reproducers; full `perl -Iperl t/phase0_regression.t` + `comm -23` set-diff vs post-`.3` | `done` — 111 → 109 failing (exactly the 2 Defect #2 cleared, 0 regressions) |
| `2026-06-21` | `.2.1` | empirical got-value repros (`Choice::OR+`/`::AND`/`::\|`/`AND+`/`AND{N,M}`); `perl -c`; full `perl -Iperl t/phase0_regression.t` + `comm` full set-diff vs baseline | `done` — 109 → 102 failing (cleared = exactly the 7 cluster-A; new failures = none) |
| `2026-06-21` | `.2.2` | read-only recon (76 → B1=18 / B2=55 / BOTH=3, per-subtest line map) + empirical probe (`canonical_action_ir_nodes` = `RETURN`, not `RETURN_A`; retired `return_*` helpers → `RAW_PERL` passthrough) | `done` (split) — decomposed into `.2.2.1` (B2) + `.2.2.2` (B1); no test change this slice |
| `2026-06-21` | `.2.2.1` | guarded one-pass transform (52 Form-A grep flips + 19 Form-B hit-hash merges + 2 desc fixes; asserts shape or aborts); `perl -c` OK; full `perl -Iperl t/phase0_regression.t` + `comm` set-diff vs baseline ×2 runs | `done` — 102 → 47 failing; cleared = exactly 55 pure-B2; new-failure set empty. One after-only name (`parser_invalid_input…`, a Lispish `open3` subprocess test at line 4163, *before* all edits) was a CPU-contention flake — disproven by a clean re-run (ok 137). |
| `2026-06-21` | `.2.2.2` | read-only recon (21 B1 subtests → per-helper map: 17 `return_array` / 4 `return_a`/`return_m`) + archaeology agent recovering & empirically verifying the canonical rewrite of all 6 retired helpers (git `4e92503` diff + `call_spec_handler_subst` probes) | `done` (split) — decomposed into `.2.2.2.1` (array) + `.2.2.2.2` (accumulator); KM card [[retired-return-helpers-canonical-rewrite]]; no test change this slice |
| `2026-06-21` | `.2.2.2.1` | guarded matching-paren line-scoped transform (33 rewrites, asserts count/delta, die-on-drift) + dry-run full-diff inspection; empirical post-rewrite hit-hash dump for the 2 BOTH subtests; `call_spec_handler_subst` check of the L16601 pinned expected; `perl -c`; full `perl -Iperl t/phase0_regression.t` + `comm` name set-diff vs baseline | `done` — 47 → 30 failing; cleared = exactly the 17 B1-array (incl. both BOTH); new-failure set empty. TEST-ONLY. |
| `2026-06-21` | `.2.2.2.2` | pre-flight probe replicating every assertion of all 4 subtests (`LinkedSpec::Get`: ACODE/ICODE/BCODE equality, fallback, node coverage, hit counts) → all PASS; scope grep (passing `return_a(pipe_operator)`/`return_m(Top)`@39745 untouched); `perl -c`; full `perl -Iperl t/phase0_regression.t` (complete TAP to corpus tail) + `comm` name set-diff vs post-`.2.2.2.1` baseline | `done` — 30 → 26 failing; cleared = exactly the 4 (`blind_call_fluent…`, `action_chain…`, `fluent_and_structured_blocks…`, `structured_blocks…`); new-failure set empty. TEST-ONLY. (One earlier run SIGALRM-killed by transient external load-32 CPU contention; clean low-load re-run gave the diff.) |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `PHASE0-BACKHALF-TRIAGE.1 — read-only triage complete` | prior commit `3a6d25b`/`f3c8a9b` |
| `.3` | `PHASE0-BACKHALF-TRIAGE.3 — engine fix: AND-rule action-codegen defect (#1)` | commit `a410d93` |
| `.4` | `PHASE0-BACKHALF-TRIAGE.4 — engine fix: input-boundary-validation regression (#2)` | commit `b26a5c4` |
| `.2.1` | `PHASE0-BACKHALF-TRIAGE.2.1 — re-bless cluster A (7 parser-collection-shape, TEST-ONLY)` | commit `07c4eb7` |
| `.2.2` | `PHASE0-BACKHALF-TRIAGE.2.2 — split cluster B into .2.2.1 (B2 token re-bless) + .2.2.2 (B1 helper rewrites)` | commit `d5c2acf` |
| `.2.2.1` | `PHASE0-BACKHALF-TRIAGE.2.2.1 — re-bless cluster B2 (55 method_like RETURN_A→RETURN, TEST-ONLY)` | commit `b691c02` |
| `.2.2.2` | `PHASE0-BACKHALF-TRIAGE.2.2.2 — split cluster B1 into .2.2.2.1 (return_array) + .2.2.2.2 (return_a/return_m)` | commit `fc52288`; recon `91b5113` |
| `.2.2.2.1` | `PHASE0-BACKHALF-TRIAGE.2.2.2.1 — re-bless cluster B1-array (33 return_array→return(array), TEST-ONLY); 17 phase0 failures cleared` | commit `6b9288c` |
| `.2.2.2.2` | `PHASE0-BACKHALF-TRIAGE.2.2.2.2 — re-bless cluster B1-accumulator (4 return_a/return_m, TEST-ONLY); 4 phase0 failures cleared` | this commit |

## Changelog

- `2026-06-19`: Created after `NONCORE-QUARANTINE` exposed 173 pre-existing back-half core failures.
- `2026-06-19`: `.1` read-only triage **DONE** — full per-cluster verdict (108 STALE / 65 REAL across 2
  engine defects: AND-rule action-codegen + input-boundary-validation regression). Added `.2` (re-bless,
  4 sub-leaves), `.3` (AND-codegen fix, blocked on engine-touch OK), `.4` (input-boundary fix, blocked),
  `.5` (green-phase0 verification). Knowledge cards [[and-return-edge-codegen-defect]] +
  [[runtime-input-boundary-validation-regression]].
- `2026-06-21`: User **authorized BOTH engine fixes** (ADR `0008` — sanctioned scoped exception to the
  engine-frozen doctrine); `.3`/`.4` blockers cleared. Fresh session re-verified both defects objectively
  (incl. the book's OWN `Pair::AND` example breaking). `.3` **DONE** — fixed the AND-acode emitter
  (`\$"`→verbatim) in `HandlerVariantEmitter.pm`; full phase0 173 → 111 failing (62 cleared, 0
  regressions). KM card [[and-return-edge-codegen-defect]] → `resolved`. Frontier → `.4`.
- `2026-06-21`: `.4` **DONE** — fixed Defect #2 (input-boundary) in `Runtime.pm` (gate the `pos()`/skip
  block behind `ref eq 'SCALAR'`, always delegate to the inner guard); full phase0 111 → 109 failing
  (set-diff = exactly the 2 Defect #2 subtests, 0 regressions). Both reference-engine defects now fixed.
  KM card [[runtime-input-boundary-validation-regression]] → `resolved`. Added `.6` (book `:AND`
  reconciliation). Frontier → `.2.1` (re-bless the 108 STALE, TEST-ONLY).
- `2026-06-21`: `.2.1` **DONE** — re-blessed the cluster-A parser-collection-shape subtests (retired
  auto-tag `['?Rule:',[]]` → current child-return shape `[1,1]` / `1`) in `t/phase0_regression.t` only;
  engine untouched. **Cluster A = 7, not the triaged 8**: subtests 144/149/152/153/156/163/166; the
  triage's 8th (`blind_call_fluent_post_call_chain_matches_block_form`, subtest 206) is a retired-
  `return_a` helper failure → re-bucketed to cluster B (`.2.2`). 13 `is_deeply` expecteds re-blessed
  against empirically-dumped engine output. Full phase0 **109 → 102 failing**; `comm` full set-diff =
  exactly the 7 cleared, **zero regressions** (corpus tail still pending `.5`). Frontier → `.2.2`
  (cluster B `method_like` ×76, retired `return_*`/`RETURN_A`).
- `2026-06-21`: `.2.2` **SPLIT** (decomposition slice — no test change). Read-only recon classified the 76
  cluster-B subtests (B1=18 retired-helper-in-body / B2=55 retired-`RETURN_A`-token-in-assertion / BOTH=3,
  per-subtest line map); an empirical probe pinned the engine facts — the canonical return node is now
  `RETURN` (not `RETURN_A`/`RETURN_M`), and the `return_a/return_m/return_ma/return_imatch/return_im/
  return_array` helpers are retired → `RAW_PERL` passthrough. **Scope hazard:** `RETURN_A` appears 90×
  across cluster B, cluster C (`emit_context` → `.2.3`), and apparently-passing helper-event tests — so
  the re-bless is **not** a global search-replace. Split into `.2.2.1` (B2 token re-bless
  `RETURN_A`→`RETURN`, mechanical/scoped) and `.2.2.2` (B1 helper rewrites, judgment-heavy). New KM card
  [[actionir-return-node-retired-to-return]] records the durable facts. Frontier → `.2.2.1`.
- `2026-06-21`: `.2.2.1` **DONE** — re-blessed the 55 pure-B2 `method_like*` subtests (TEST-ONLY,
  `t/phase0_regression.t`; engine/spec untouched). A guarded one-pass transform applied **52 Form-A grep
  flips** (`scalar(grep { $_ eq 'RETURN_A' } @{$X->{canonical_action_ir_nodes}})` → `'RETURN'`) + **19
  Form-B hit-hash merges** (`RETURN += 1`, adjacent `RETURN_A => 1` deleted — the retired node renames to
  `RETURN`, so the two counts collapse into one key rather than colliding) + **2 stale description fixes**;
  it asserts each target's exact shape (Form-A == 52; each Form-B `RETURN_A` adjacent to a `RETURN => N`)
  and aborts before writing on any drift. **Excluded** (17 `RETURN_A` remain, untouched): the 14 cluster-C
  `emit_context` sites incl. the passing `helper_action_ir_events`/`helper_action_ir_nodes` kind sites
  (`.2.3`), and the 3 BOTH subtests (`.2.2.2`). **Full phase0 102 → 47 failing; `comm` set-diff (×2 runs)
  = exactly 55 cleared, new-failure set empty.** The lone after-only name (`parser_invalid_input_fails_at_
  runtime_parser_boundary`, a `Lispish` `open3` subprocess test at source line 4163 — *before* every edit,
  engine byte-identical) was a CPU-contention flake, disproven by a clean re-run (`ok 137`). Remaining 47 =
  20 `method_like` (B1+BOTH → `.2.2.2`) + 20 `emit_context` (`.2.3`) + 7 other (`.2.4`/`.5`). Frontier →
  `.2.2.2`.
- `2026-06-21`: `.2.2.2` **SPLIT** (decomposition slice — no test change). Read-only recon mapped the 21
  failing B1 subtests by retired helper (**17 `return_array`** incl. 2 BOTH @17289/@20105; **4 `return_a`/
  `return_m`** incl. the 3rd BOTH `method_like_action_chain…` + `blind_call_fluent…`). An archaeology agent
  recovered the original lowering of all six retired helpers from the COMPAT-ALIAS-RETIREMENT-V2.2 diff
  (`4e92503`) and **empirically verified** each canonical rewrite via `call_spec_handler_subst` probes — key
  finding: `return_array(L, e1, e2)` is a pure alias (`L` dropped, barewords auto-quoted, output ==
  `return(array(e1,e2))`), so the array family is mostly an input-rewrite, whereas `return_a`/`return_m`
  add a `"?L:"` tag + `array_copy(array(L))`/`entry_groups()` and need re-dump + re-bless. New KM card
  [[retired-return-helpers-canonical-rewrite]]. Split into `.2.2.2.1` (17 array, mechanical-ish) and
  `.2.2.2.2` (4 accumulator, judgment-heavy). Frontier → `.2.2.2.1`.
- `2026-06-21`: `.2.2.2.1` **pre-implementation recon** (read-only; no test change). Discovered a critical
  scoping hazard before editing: `return_array` appears **74× = 34 in failing / 40 in PASSING subtests**,
  with byte-identical spec-body strings across both (the switch-case families), so the rewrite **must be
  line-scoped to the 17 B1-array subtests — not a global replace**; and one "failing" `return_array` is
  actually a cluster-C `emit_context` site (~L12440 → `.2.3`), to be excluded. Classified the 33 spec-body
  occurrences into 4 forms (9 `.return_array` / 9 `; return_array }` / 10 bare / 5 `if`-mixed) + 1 subst-arg
  (L16601). **Empirically verified** the rewrite `return_array(semantic_annotation, X)` →
  `return(array("semantic_annotation", X))` gives `fallback=0`/`ready` with fluent==block; these subtests
  pin no literal output (only fluent==block + fallback==0 + ready), so the rewrite is shape-agnostic.
  Full execution plan recorded in the `.2.2.2.1` node. Recommended a **fresh session** for the multi-form
  paren-level surgery (signoff focus). Frontier stays → `.2.2.2.1`.
- `2026-06-21`: `.2.2.2.1` **DONE** (TEST-ONLY, `t/phase0_regression.t`; engine/spec untouched). A guarded
  matching-paren line-scoped transform rewrote **33 in-range** `return_array(<Top,> semantic_annotation, X)`
  → `return(array("semantic_annotation", X))` (recon's "34" was off-by-one; real split = 74× file-wide →
  33 in the 17 failing ranges / 41 in passing + EmitContext sites), asserting `rewrites == in-range count`
  and file-wide delta, die-before-write on drift; the full dry-run diff was inspected before apply.
  **Recon correction:** the 2 BOTH subtests (@17289, @20105) do NOT "pin no literal output" — each pins a
  literal `canonical_action_ir_hits` carrying stale `RETURN_A => 1`; that deferred `.2.2.1` Form-B merge was
  done here (`RETURN 2→3`, drop `RETURN_A`), **empirically dumped** before re-blessing. L16601's pinned
  `is(...)` expected confirmed unchanged-and-canonical. `perl -c` OK; full phase0 **47 → 30 failing**;
  `comm` name set-diff = exactly the 17 B1-array cleared (incl. both BOTH), **zero regressions**. Frontier
  → `.2.2.2.2` (4 `return_a`/`return_m` accumulator, re-dump + re-bless, highest risk). Book unaffected
  (internal IR-node names, not a user surface).
- `2026-06-21`: `.2.2.2.2` **DONE** (TEST-ONLY, `t/phase0_regression.t`; engine/spec untouched) — closes
  cluster B1 (`.2.2.2`). Ground-truth-first: a pre-flight probe replicated **every** assertion of all 4
  subtests via `LinkedSpec::Get` (ACODE/ICODE/BCODE equality, fallback, node coverage, hit counts) → all
  PASS, settling the judgment forks before editing. Rewrote `.return_a().return_m()` →
  `.return(1).return(array("?Top:", entry_groups()))` (×3, replace_all — exactly 3, all targets), block
  `return_m(Top)` → `return(array("?Top:", entry_groups()))` (×2, line-scoped — @39745 is a *passing*
  non-target, excluded), blind-call `.return_a()` → `.return(1)` (@6342); and re-blessed subtest-1's two
  retired `RETURN_A`/`RETURN_M` node greps to `grep RETURN` + `is(hits{RETURN}, 2)` (the distinct-variant
  feature is retired — `RETURN_A`/`RETURN_M` fold into a single `RETURN`, KM [[actionir-return-node-retired-to-return]]).
  The 4 passing `return_a(pipe_operator)` sites + `return_imatch`@12436 (→`.2.3`) + the negative
  source-assert @41730 untouched. `perl -c` OK; full phase0 **30 → 26 failing**; `comm` name set-diff =
  exactly the 4 cleared, **zero regressions** (complete TAP to the corpus tail). Verification was briefly
  blocked by transient external CPU contention (an unrelated `cargo`/`rustc` build pushed load to 32,
  exceeding the 10-min runner cap → SIGALRM); a fresh low-load run produced the clean diff. Remaining 26 =
  20 `emit_context` (`.2.3`) + 5 F/G (`.2.4`) + 1 `corpus_regression` tail (`.5`). Frontier → `.2.3`.
  Book unaffected.
