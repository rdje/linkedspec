---
id: lua-root-rule-selection-admission
title: "Lua root-rule selection is admitted through one exact shared-source 15-role consumer"
answers:
  - "is Lua root rule selection admitted"
  - "which root selection backends have variant parity"
  - "what root rule selection variant parity has been achieved"
  - "how many Lua root admission assertions pass"
  - "does the Lua root admission run on PUC Lua and LuaJIT"
  - "which roles does the Lua root selection admission cover"
  - "why do Lua root selection fixtures use lifecycle I instead of E"
  - "does the Lua request trace fixture still use lifecycle E"
  - "how many root rule selection drift mutations are rejected"
  - "what is the current root rule selection rollout"
  - "which shared primary cases does Lua root admission lock"
date: 2026-07-19
status: Lua admitted on PUC Lua and LuaJIT; final global rollout closed at 7 complete / 0 pending
tags: [lua, luajit, root-rule, top-rule, admission, topology, lifecycle, primary-cli, backend-parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.5.3 adds `lua/test/root_rule_selection_admission_test.lua`, one shared-source omission-sensitive consumer run unchanged by PUC Lua and LuaJIT. Its exact contract order is neutral selection, neutral failures, neutral strict, native, loaded, reconstructed, generated direct/traced, emitted-source direct/traced, descriptor, diagnostic, runtime trace, primary CLI, and primary request trace. Every `role_*` marker is unique and every declared role completes once. Hand-authored selection sources return distinct values from entry lifecycle `I`, proving which rule was entered before matching; the fixed shared request-trace source remains byte-identical and retains canonical `E`. The checker locks consumer and driver paths, exact ordered roles, both ABI invocations, canonical tracked input/optional driver registration, six shared manifest ids, Lua rollout, and five additional omission mutations. Exact pre-contract topology RED is 3/3 per ABI; green is 139/139 per ABI. Complete package is 177/177 per ABI, primary is 65/65 in all four ABI/default-POSIX legs, and corpus is 105/105 per ABI. Only Lua advances, so root governance is 6 complete / 1 pending with 44 rejected mutations. Final public no-drift remains `.9.1.1.2.6`."
evidence_update_2026_07_19_signoff: "Knowledge Map generation is 633 facts / 4,653 question keys; mdBook and all four doctrines pass. Canonical local CI passes root consumers 7+5, cursor admission 288, reference primary 65/65 twice, and Phase 0 1,031/1,031 in 641 seconds. Safe cleanup removes the generated book, Python cache, dedicated Julia compiled cache, and four completed LinkedSpec proof logs while retaining depot source, tracked rgx evidence, and unrelated temp artifacts."
evidence_update_2026_07_19_final_admission: "Final leaf `.9.1.1.2.6` preserves this exact Lua consumer and runs it unchanged under PUC Lua and LuaJIT inside `tools/check_root_rule_selection_five_backend.sh`. The global root-selection ledger is now 7 complete / 0 pending with 54 rejected mutations."
reverify: "bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
---

# Lua root-rule selection admission

Lua has no admission-only resolver. The consumer composes already-current parser, validator, compiled resolver,
runtime, loader, normalized reconstruction, generated/emitted v2, descriptor, diagnostics, trace, primary command,
and request-trace routes. The same Lua source runs on both supported ABIs, so ABI coverage is topology rather than
two semantic implementations.

The exact precedence remains explicit selector (including `--top-rule`) first, then the first authored `Rule::`,
then the first authored ordinary `Rule:` when no marker exists. Authored `is_top` stays immutable. Selection does
not create a strict-unused reference.

The admission distinguishes proof fixtures from fixed protocol fixtures. Hand-authored sources use `I` returns so
the chosen entry is observable before its own match. The shared request-trace source must remain byte-identical and
therefore retains `E`; that does not change the lifecycle recommendation for new selection-focused evidence.

This historically advanced the neutral rollout from 5/2 to 6/1. Final recurring/public no-drift `.9.1.1.2.6`
subsequently closed the global rollout at 7/0 without changing the Lua semantic owner.

Related: [[root-rule-selection-precedence]], [[lua-root-rule-selection-core]],
[[lua-root-rule-selection-routes]], and [[lua-rule-local-cursor-admission]].
