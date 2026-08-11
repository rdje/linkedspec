---
id: recognition-transaction-neutral-contract
title: The recognition-transaction contract covers 132 node rows, 246 call rows, and 44 mutations
answers:
  - "where is the executable neutral recognition transaction contract"
  - "how do I run the recognition transaction checker"
  - "how many ActionIR node effects does the transaction contract classify"
  - "how many current ActionIR node kinds are there"
  - "why are there 128 ActionIR nodes but 122 public Perl contracts"
  - "how many canonical call effects does the recognition transaction contract classify"
  - "what recognition transaction fixtures are executable"
  - "how are recursive rule effects checked for transactions"
  - "how many recognition transaction mutations are rejected"
  - "is recognition transaction syntax executable in a backend"
  - "what is the recognition transaction rollout status"
  - "which admitted recognition transaction consumers must update when rollout advances"
  - "does the neutral transaction checker change parser behavior"
date: 2026-08-10
status: current neutral authority; Perl, Rust, Dart, and Julia complete; Lua, recurring, and public-no-drift legs RED
tags: [cursor, transactions, recognition, actionir, effects, progress, marks, recursion, conformance]
evidence: "FUTURE-PARITY-BACKLOG.14.3.1.1 adds linkedspec-recognition-transaction-v1 plus an independent checker. The checker derives 128 live ActionIR node kinds from Perl and the same 246 current call names from Dart, Julia, and Lua; adds four future RECOGNITION_* rows; executes token 8/17, effect graphs 6, marks 6, progress 8, diagnostics 15; and rejects 40 semantic mutations. FUTURE-PARITY-BACKLOG.14.3.1.2.0 separately binds public sequence at 3 documents / 8 forbidden / 13 mutations."
evidence_update_2026_08_10_perl_admission: "FUTURE-PARITY-BACKLOG.14.3.2.3 promotes only Perl, binds its exact final-path consumer, and adds a complete-to-RED regression while retaining premature Rust promotion rejection. Current truth is 2/9 complete and 41 semantic mutations; the public projection independently advances to 3 documents / 8 forbidden claims / 14 mutations."
evidence_update_2026_08_10_rust_admission: "FUTURE-PARITY-BACKLOG.14.3.3.3 promotes only Rust after making its unchanged 12-test final-path consumer ordinary and canonical. Rust complete-to-RED plus premature Dart promotion raise semantic proof to 42 mutations and rollout to 3/9. Exhaustive stale-claim review advances the public projection to 3 documents / 11 forbidden claims / 25 mutations, the capability guide to 1/4/8, and exact Rust registration/dormancy proof to 8 mutations."
evidence_update_2026_08_11_dart_admission: "FUTURE-PARITY-BACKLOG.14.3.4.3 promotes only Dart after moving its unchanged integrated 10-test consumer into ordinary and canonical project-data-routed discovery. Dart complete-to-RED plus premature Julia promotion raise semantic proof to 43 mutations and rollout to 4/9. Public governance is 3 documents / 14 forbidden / 29 mutations; the capability guide is 1/6/10; exact Dart registration/privacy/dormancy proof rejects 13 mutations."
evidence_update_2026_08_11_julia_admission: "FUTURE-PARITY-BACKLOG.14.3.5.3 promotes only Julia after registering its unchanged 203-assertion consumer exactly once in ordinary and canonical repository-routed discovery. Julia complete-to-RED plus premature PUC Lua promotion raise semantic proof to 44 mutations and rollout to 5/9. Public governance is 3 documents / 17 forbidden / 33 mutations; the guide is 1/8/12; exact Julia registration/privacy/dormancy proof rejects 14 mutations."
evidence_update_2026_08_11_lua_red: "FUTURE-PARITY-BACKLOG.14.3.6.0 freezes one shared final-path Lua consumer with explicit authority/integration modes. PUC Lua and LuaJIT each parse both modes and stop only at the missing private linkedspec.recognition_transaction module. Twelve separate mutations lock dormancy, private lookup, stable failure, current neutral status, dual-ABI commands, absent ordinary/canonical registration, and absent facade export without changing 132/246/44 or rollout 5/9."
evidence_update_2026_08_11_cross_consumer_metadata: "The first atomic-196 canonical run proved that every admitted consumer snapshots mutable neutral metadata as well as backend behavior: Perl retained the pre-Dart status/availability and Rust retained the pre-Dart mutation/rollout/availability assertions. Updating both consumers closes that coupling without runtime changes; each later admission must update all earlier admitted consumer metadata assertions."
reverify: "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl --report"
---

The canonical artifact is `capability_conformance/recognition_transaction_contract.json`; its independently
implemented oracle is `tools/check_recognition_transaction_contract.py`. Canonical and focused execution route the
checker through repository-local project data:

```bash
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
```

The checker derives 128 unique current canonical ActionIR node kinds from
`perl/LinkedSpec/ActionIR/Contracts.pm`. It requires one base-effect row for each plus the four future dedicated
transaction nodes, for 132 total. This is a different census from the 122 public identifier-shaped Perl contracts
reported by `tools/check_language_capability_coverage.pl`: the latter counts public call-contract names after
classifying internal/compatibility names, not unique ActionIR node kinds.

The call-effect side derives the exact 246-name inventories independently from Dart, Julia, and Lua and requires
them to agree before comparing all rows. Both surfaces use the closed nine-allowed/eleven-rejected vocabulary and
fail on missing, duplicate, unknown, stale, or reclassified rows. Six call graphs—including direct and mutual
recursion—are evaluated to a fixed point so a transitive forbidden effect cannot hide behind a callee.

Executable semantic fixtures cover eight valid falsey-safe token outcomes, seventeen token/ownership failures,
six invocation-mark snapshot/isolation cases, eight repetition/direct/mutual-recursion progress cases, and fifteen
portable diagnostic records. Forty-four in-memory mutations cover schema, syntax, token/result, effects, inventories,
graphs, marks, progress, diagnostics, rollout, canonical registration, tracked input, freshness, and the
public-current boundary.

Neutral, Perl, Rust, Dart, and Julia are complete. PUC Lua, LuaJIT, recurring composition, and public no-drift
remain RED. Backend admission binds already integrated behavior without changing descriptor/schema, CLI,
semantic/MCP, capability, or unrelated helper behavior. The same canonical checker separately locks three public
transaction pages, seventeen forbidden milestone/current claims, and 33 in-memory sequence mutations; that
accounting remains distinct from the JSON's 44 semantic mutations. A one-document/eight-forbidden/twelve-mutation
guide guard, eight Rust-registration mutations, thirteen Dart registration/privacy/dormancy mutations, and
fourteen Julia registration/privacy/dormancy mutations remain separate.

Each admitted backend consumer also reads the current neutral artifact. Consequently a rollout promotion must
advance status, availability, mutation count, rollout paths, and later-RED assertions in every earlier admitted
consumer, even though their backend execution does not change. Canonical execution of those exact consumers is the
cross-consumer no-drift proof.
