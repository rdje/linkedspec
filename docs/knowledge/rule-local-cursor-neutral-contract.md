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
date: 2026-07-17
status: accepted neutral contract; Perl implemented through API/CLI removal, composed admission pending
tags: [dsl, cursor, parse-mode, bare-edge, contract, migration, descriptor, generated-source, parity]
evidence: "FUTURE-PARITY-BACKLOG.9.1.2 adds linkedspec-rule-local-cursor-v1 plus an independent offline checker. It derives and checks 36 exact family spellings, 18 edge normalization/error cases, six post-normalization ownership sets, eight parent/child mechanisms, two structural cross-combination replacements, option/CLI removal, per-rule descriptor facts, generated-source v2 family mapping, and eight portable diagnostics. The tracked-content scan owns exactly 72 migration files after Perl API/CLI .9.1.3.5 makes nine shared byte fixtures and seven Perl tests token-free while GeneratedSource gains the portable emitter error. The checker rejects 27 mutations. Rollout remains 1 complete / 7 pending until composed backend admission."
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
files and currently owns 72 after Perl descriptor/generated/API/CLI migration retires
the now-token-free `CompilerState.pm`, `SpecEntry.pm`, and generated-handlers
chapter, and after reconciling
the action/lifecycle chapter token removed by `ccf4cad7`, then retires sixteen
Perl/shared paths while adding `GeneratedSource.pm`'s portable emitter error. Files are partitioned
once, in dependency order, among `.9.1.2-.9`. An unowned
new file or a listed file that loses every migration token fails the checker,
so backend leaves must deliberately update the inventory as they migrate.

Perl preflight `.9.1.3.0` corrected one ordering detail without changing the 91-
file set or runtime semantics: the ten shared manifest/help/usage/trace files
whose bytes change when the canonical reference removes `--parse-mode` migrate
with Perl `.9.1.3.5`, because the mandatory local gate runs that reference suite
twice. Shared CLI documentation and final symmetric admission remain `.9.1.8`-
owned. See [[perl-rule-local-cursor-rollout-boundaries]].

Only `neutral_contract_and_inventory` is admitted in the composed rollout
ledger. Perl implementation is current through API/CLI removal, while its
composed admission remains pending; Rust, Dart, Julia,
dual-ABI Lua, recurring five-backend admission, and
public no-drift follow. Generated-source v1 and the 63-case primary interface
remain the unmigrated-backend/shared baseline until their owners land.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[and-or-cursor-ownership-audit]], and [[rule-local-cursor-ownership-decision]].
