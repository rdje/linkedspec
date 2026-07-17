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
date: 2026-07-17
status: accepted neutral contract; backend rollout pending
tags: [dsl, cursor, parse-mode, bare-edge, contract, migration, descriptor, generated-source, parity]
evidence: "FUTURE-PARITY-BACKLOG.9.1.2 adds linkedspec-rule-local-cursor-v1 plus an independent offline checker. It derives and checks 36 exact family spellings, 18 edge normalization/error cases, six post-normalization ownership sets, eight parent/child mechanisms, two structural cross-combination replacements, option/CLI removal, per-rule descriptor facts, generated-source v2 family mapping, and eight portable diagnostics. A tracked-content scan owns exactly 91 current parse_mode/parseMode/parse-mode migration files in dependency order across neutral/shared, Perl, Rust, Dart, Julia, Lua, admission, and public closeout leaves. The checker rejects 27 mutations. Rollout is 1 complete / 7 pending; no backend behavior changes in this leaf."
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
contract, test, CLI-fixture, and current public-document roots. Its exact 91
files are partitioned once, in dependency order, among `.9.1.2-.9`. An unowned
new file or a listed file that loses every migration token fails the checker,
so backend leaves must deliberately update the inventory as they migrate.

Only `neutral_contract_and_inventory` is complete. Perl, Rust, Dart, Julia,
dual-ABI Lua, recurring five-backend admission, and public no-drift remain
pending. Existing global option behavior, generated-source v1, descriptors,
and the 63-case primary interface remain current until those owners land.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[and-or-cursor-ownership-audit]], and [[rule-local-cursor-ownership-decision]].
