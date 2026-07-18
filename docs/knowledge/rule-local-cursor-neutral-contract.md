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
date: 2026-07-18
status: accepted neutral contract; Perl and Rust admitted, Dart implemented through public removal at 3 complete / 5 pending
tags: [dsl, cursor, parse-mode, bare-edge, contract, migration, descriptor, generated-source, parity]
evidence: "FUTURE-PARITY-BACKLOG.9.1.2 adds linkedspec-rule-local-cursor-v1 plus an independent offline checker over 36 family spellings, 18 edges, six ownership sets, eight parent/child mechanisms, two structural replacements, removal, descriptors, generated v2, and eight diagnostics. Perl .9.1.3.6 adds a 14-role contract-declared consumer and canonical registration. Rust .9.1.4.3-.6 moves the census from 72 through 74/73/71 to 68; admission .7 adds a token-free 15-role consumer and advances only rust_parity. Dart public removal .9.1.5.5 makes four former option-owner paths token-free and governs the source-removal test plus public Dart guidance, contracting inventory to 66 files at 3 complete / 5 pending while all 34 mutations remain effective."
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
removal test plus the now-explicit public Dart migration guidance, producing the current 66-file inventory. Files are partitioned
once, in dependency order, among `.9.1.2-.9`. An unowned
new file or a listed file that loses every migration token fails the checker,
so backend leaves must deliberately update the inventory as they migrate.

Perl preflight `.9.1.3.0` corrected one ordering detail without changing the 91-
file set or runtime semantics: the ten shared manifest/help/usage/trace files
whose bytes change when the canonical reference removes `--parse-mode` migrate
with Perl `.9.1.3.5`, because the mandatory local gate runs that reference suite
twice. Shared CLI documentation and final symmetric admission remain `.9.1.8`-
owned. See [[perl-rule-local-cursor-rollout-boundaries]].

`neutral_contract_and_inventory`, `perl_reference`, and `rust_parity` are admitted in the composed rollout ledger.
The Perl consumer declares 14 exact roles; the Rust consumer declares 15 native/serialized/loaded/descriptor/
emitted/generated/trace/composition/removal/primary/diagnostic roles. The checker requires every marker plus each
canonical registration seam, and its 34 mutations reject topology, role, driver, inventory, or rollout drift.
Dart implementation is current through public removal but remains pending until its composed `.9.1.5.6` consumer
admits the backend. Julia, dual-ABI Lua, recurring five-backend admission, and public no-drift follow. Generated-
source v1 remains the unmigrated-backend baseline, while the 63-case primary interface is current on Perl, Rust,
and Dart.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[and-or-cursor-ownership-audit]], and [[rule-local-cursor-ownership-decision]].
