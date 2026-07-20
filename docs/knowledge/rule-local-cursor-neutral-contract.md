---
id: rule-local-cursor-neutral-contract
title: "The rule-local cursor target is executable and every current migration file has an ordered owner"
answers:
  - "where is the executable rule local cursor contract"
  - "how many parse mode migration files exist"
  - "which leaf owns each parse_mode migration surface"
  - "how many rule family spellings does the cursor checker cover"
  - "how many bare edge cases does the cursor checker cover"
  - "what is the rule local cursor rollout status"
  - "does the neutral cursor contract change backend behavior"
  - "how do I run the rule local cursor checker"
  - "why is the rule local cursor migration inventory 87 files"
  - "which commit left the cursor migration inventory stale"
  - "how many Perl cursor admission roles exist"
  - "what is the rule local cursor rollout after Perl admission"
  - "why is the rule local cursor migration inventory 74 files"
  - "why is the rule local cursor migration inventory 73 files"
  - "how many Rust cursor admission roles exist"
  - "what is the rule local cursor rollout after Rust admission"
  - "why is the rule local cursor migration inventory 66 files"
  - "why is the rule local cursor migration inventory 67 files"
  - "why is the rule local cursor migration inventory 68 files"
  - "how many Dart cursor admission roles exist"
  - "what is the rule local cursor rollout after Dart admission"
  - "how many Julia cursor admission roles exist"
  - "what is the rule local cursor rollout after Julia admission"
date: 2026-07-18
status: accepted neutral contract; Perl, Rust, Dart, Julia, and dual-ABI Lua admitted at 6 complete / 2 pending
tags: [dsl, cursor, parse-mode, bare-edge, contract, migration, descriptor, generated-source, parity]
evidence: "FUTURE-PARITY-BACKLOG.9.1.2 adds linkedspec-rule-local-cursor-v1 plus an independent offline checker over 36 family spellings, 18 edges, six ownership sets, eight parent/child mechanisms, two structural replacements, removal, descriptors, generated v2, and eight diagnostics. Perl .9.1.3.6 adds a 14-role contract-declared consumer and canonical registration. Rust .9.1.4.7 adds a 15-role consumer and advances only rust_parity. Dart .9.1.5.6 adds a governed 15-role consumer and reaches 67 files, 4 complete / 4 pending, and 39 mutations. Julia .9.1.6.6 adds its governed 15-role consumer, advances only julia_backend, retains 67 files, and reaches 5 complete / 3 pending with 44 effective mutations."
evidence_update_2026_07_19_lua_runtime: "Lua runtime leaf .9.1.7.2 registers its new dual-ABI execution consumer, moving inventory from 67 to 68 files without advancing the pending lua_dual_abi rollout row or changing the 44 effective mutations."
evidence_update_2026_07_19_lua_generated_v2: "Lua generated-source leaf .9.1.7.4 registers its dedicated dual-ABI consumer, moving inventory from 68 to 69 files without advancing the pending lua_dual_abi rollout row or changing the 44 effective mutations."
evidence_update_2026_07_19_lua_admission: "Lua admission .9.1.7.6 adds one exact 15-role consumer run on PUC Lua and LuaJIT, advances only lua_dual_abi, and locks both driver legs plus canonical optional registration. Exact pre-contract RED is 3/3 per ABI and green is 119/119 per ABI. Governance is 69 migration files, 6 complete / 2 pending, and 49 mutations."
evidence_update_2026_07_19_root_governance: "Final root-selection public no-drift adds its neutral contract and independent checker to the cursor inventory because both scan the parse-mode-named mdBook chapter. The current inventory is therefore 71 files; cursor rollout remains 6 complete / 2 pending with 49 mutations."
reverify: "python3 tools/check_rule_local_cursor_contract.py; perl tools/check_capability_conformance.pl; perl tools/check_generated_source_contract.pl"
---

`capability_conformance/rule_local_cursor_contract.json` is the executable
projection of ADR `0044`. Its independent checker is
`tools/check_rule_local_cursor_contract.py`.

The neutral contract covers:

- 36 exact top/body family spellings and derived AND=`consume`,
  OR/default=`seek` policy;
- 18 deterministic bare/explicit/block/fluent/index/group/reserved edge
  fixtures and six complete rule ownership sets;
- eight parent/child pairs across blind calls, action edges, explicit calls,
  and recursion, always deriving child policy from the child family;
- ordered-landmark and anchored-choice structural replacements;
- exact dynamic-option and primary-CLI removal failures;
- descriptor `cursor_contract` / per-rule `cursor_policy` facts;
- generated-source v2's exact five seek plus five consume families without a
  serialized cursor override; and
- eight portable diagnostic shapes.

The migration inventory scans tracked and candidate files under the executable,
contract, test, CLI-fixture, and current public-document roots. It began at 91
files and reached 73 after Perl descriptor/generated/API/CLI migration retires
the now-token-free `CompilerState.pm`, `SpecEntry.pm`, and generated-handlers
chapter, and after reconciling
the action/lifecycle chapter token removed by `ccf4cad7`, then retires sixteen
Perl/shared paths while adding `GeneratedSource.pm`'s portable emitter error, adds the Rust v1 source-emitter
compatibility adapter and contract-driven execution suite during `.9.1.4.3`, and retires token-free
`descriptor.rs` during `.9.1.4.4`. Generated-source v2 then removes two more token owners, and public option/
CLI/documentation migration reaches 68 files during `.9.1.4.5-.6`; composed admission `.7` retains that exact
count. Dart public removal `.9.1.5.5` then retires four former option-owner paths and adds its governed source-
removal test plus the now-explicit public Dart migration guidance, producing a 66-file boundary. Dart admission
then adds its governed consumer because that executable proof itself names the retired diagnostic surface, producing
the 67-file inventory. Julia admission retains that count because its new consumer is the governed proof path
added by the promotion. Files are partitioned
once, in dependency order, among `.9.1.2-.9`. An unowned
new file or a listed file that loses every migration token fails the checker,
so backend leaves must deliberately update the inventory as they migrate.

Lua runtime `.9.1.7.2` adds its governed execution consumer because the proof itself names the staged
`parse_mode` compatibility seam. That produces the current 68-file inventory without advancing rollout.
Lua generated-source `.9.1.7.4` adds its governed v2 consumer because that proof names both the retired v1 API and
the still-staged public override field. That produces the current 69-file inventory without advancing rollout.
Final root-selection public governance then adds two cross-contract scanner paths that name the parse-mode mdBook
chapter. The exact current inventory is 71 files without advancing cursor rollout or changing its mutations.

Perl preflight `.9.1.3.0` corrected one ordering detail without changing the 91-
file set or runtime semantics: the ten shared manifest/help/usage/trace files
whose bytes change when the canonical reference removes `--parse-mode` migrate
with Perl `.9.1.3.5`, because the mandatory local gate runs that reference suite
twice. Shared CLI documentation and final symmetric admission remain `.9.1.8`-
owned. See [[perl-rule-local-cursor-rollout-boundaries]].

`neutral_contract_and_inventory`, `perl_reference`, `rust_parity`, `dart_backend`, `julia_backend`, and
`lua_dual_abi` are admitted in the composed rollout ledger.
The Perl consumer declares 14 exact roles; the Rust consumer declares 15 native/serialized/loaded/descriptor/
emitted/generated/trace/composition/removal/primary/diagnostic roles. Dart separately declares 15 native/normalized/
loaded/descriptor/emitted/generated/trace/composition/removal/primary/diagnostic roles. The checker requires every
marker plus each canonical/backend registration seam. Julia separately declares the same exact 15-role topology;
the checker locks its complete package driver and optional canonical registration too. Lua declares the same
15-role normalized topology and runs it on both ABIs; the checker locks both invocations and optional canonical
registration. Its 49 mutations reject topology, role, driver, inventory, or rollout drift. Recurring five-backend
admission and public no-drift follow. Generated-source v1 remains the historical unmigrated-backend baseline.
The shared primary interface reached 63 cases during cursor rollout and is now a current 65-case five-backend
projection after root-selection admission.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[and-or-cursor-ownership-audit]], and [[rule-local-cursor-ownership-decision]].
