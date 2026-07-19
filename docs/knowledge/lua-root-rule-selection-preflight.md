---
id: lua-root-rule-selection-preflight
title: "Lua root-selection preflight: one validation blocker, one resolver seam, and cursor-ordered admission"
answers:
  - "what currently blocks markerless root selection on Lua"
  - "where should Lua entry rule selection be implemented"
  - "does Lua already fall back to the first rule"
  - "how many Lua primary root selection cases pass before implementation"
  - "which Lua primary CLI failures belong to root selection versus cursor migration"
  - "do PUC Lua and LuaJIT differ on root selection"
  - "what order should Lua root selection and cursor work use"
  - "does Lua generated source already preserve root definition order"
  - "which lifecycle should root selection fixtures use"
date: 2026-07-18
status: historical preflight superseded by implemented core/routes/cursor and admitted `.9.1.1.2.5.3`
tags: [lua, luajit, root-rule, top-rule, entry-selection, generated-source, descriptor, trace, primary-cli, ADR-0046, FUTURE-PARITY-BACKLOG]
evidence: "Behavior-free leaf `.9.1.1.2.5.0` retrieves ADR 0046, the neutral/admitted consumers, Lua architecture cards, Toolbox, drivers, and primary owners, then measures real disposable PUC Lua and LuaJIT adapters. Both ABIs are identical. Native explicit ordinary and later-marker selectors work; default selects the first marker. When validation is bypassed, markerless native, normalized-state reconstruction, and generated direct/traced execution already select the first authored rule because ordered state and the runtime helper preserve that fallback. The validator currently requires `Rule::`, so validated markerless source, loaded source, and emitted markerless source cannot reach it. Empty and comment-only source also fail in the parser; non-rule garbage correctly remains a parse failure. Unknown selection and zero-rule bypass retain legacy untyped failures. Descriptor state preserves `definition_order` and authored `is_top` but lacks `entry_rule_contract`; low trace records only effective `top_rule`, not requested/effective/basis. Generated source remains v1/format 1 with a minimal ordered label/family plan and must not change during root routes. Strict-unused already uses authored edges only once marker validation is bypassed."
process_boundary: "The shared 65-case primary manifest is exactly 31/65 in PUC Lua and LuaJIT with `POSIXLY_CORRECT` unset and set. `success_markerless_first_authored_rule` is the sole root-owned failure. The other 33 are cursor-owned: 22 help/usage cases and 11 medium-or-higher request-trace cases. Core `.5.1` must improve only the root row to 32/65; cursor `.9.1.7` later removes the remaining 33. Complete package execution is identically 176 passing groups plus the one cursor help failure per ABI, and corpus execution is 105/105 per ABI. Behavior-free canonical closeout exits 0 after root consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 609 seconds."
implementation_order: "The frozen dependency order is root core/descriptor `.5.1`, loaded/reconstructed/generated-v1/emitted/trace/diagnostic routes `.5.2`, cursor migration `.9.1.7` depending on `.5.2`, then exact root topology admission `.5.3` depending on both `.5.2` and `.9.1.7`. Core selection belongs in one compiled-state resolver and must run before runtime context or user code. Parser empty/comment-only envelopes feed typed one-or-more-rule validation; loader/generated adapters preserve portable zero/unknown identity without specializing unrelated validation failures. Authored selection fixtures use distinct entry-lifecycle `I` returns because that proves the selected rule was entered; the fixed shared request-trace source retains its canonical `E` bytes."
evidence_update_2026_07_18_core: "Core leaf `.9.1.1.2.5.1` now implements the frozen parser/validation/resolver/failure/descriptor/strict boundary identically on PUC Lua and LuaJIT. Focused proof is 99 assertions per ABI; package execution is 176/177 with only the cursor-help mismatch; all four default/POSIX primary legs are exactly 32/65 with only the 33 cursor-owned mismatches; corpus is 105/105 per ABI. Follow [[lua-root-rule-selection-core]] for current mechanism and proof. Composed routes `.5.2`, cursor `.9.1.7`, and admission `.5.3` remain pending; rollout stays 5/7."
evidence_update_2026_07_19_admission: "The frozen order is now complete. Core `.5.1`, routes `.5.2`, cursor `.9.1.7`, and exact shared-source admission `.5.3` pass on both ABIs. Current proof is admission 139/139x2, package 177/177x2, primary 65/65x4, corpus 105/105x2, root 6/1/44, and canonical Phase 0 1,031/1,031 in 641 seconds. Follow [[lua-root-rule-selection-admission]]."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_root_rule_selection_contract.py && bash tools/run_primary_cli_matrix.sh"
---

# Lua root-rule selection preflight

Lua did not need a new ordering model. Its authored rule order, `is_top` markers, default helper, normalized
state, and v1 generated plan already preserved enough information for ADR 0046. Core `.5.1` has now removed the
marker-required validation blocker and centralized selection identity/failures; see [[lua-root-rule-selection-core]].

The safe implementation split is deliberately narrow:

1. `.5.1` makes empty/comment-only input reach validation, validates one-or-more rules instead of one-or-more
   markers, adds the compiled resolver, selects before context/user code, projects portable failures and the
   descriptor contract, and proves strict no-drift on both ABIs.
2. `.5.2` proves loaded, reconstructed, generated-v1 direct/traced, emitted, diagnostic, and low-trace routes use
   the same resolver without changing generated artifact identity.
3. Cursor `.9.1.7` owns the 22 help/usage and 11 request-trace mismatches and its generated-v2 migration.
4. `.5.3` composes the exact 15 roles on both ABIs and admits Lua only after both semantic tracks are current.

Do not classify the matching `E` and `I` final values as equivalent lifecycle evidence. `I` directly establishes
entry; `E` can return the same value only after successful matching. Hand-authored selection fixtures therefore
use `I`, while an already frozen shared request-trace fixture remains byte-stable.
