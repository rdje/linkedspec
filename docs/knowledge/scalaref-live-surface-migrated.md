---
id: scalaref-live-surface-migrated
title: active specs, tests, corpus fixtures, and public docs no longer use scalaref examples
answers:
  - "do shipped specs still use scalaref"
  - "does the live surface still use scalaref"
  - "which leaf migrated scalaref"
  - "what replaced active scalaref examples"
  - "can working hashes be read with direct brackets"
date: 2026-07-02
status: confirmed
tags: [dsl, retirement, scalaref, direct-access, docs]
evidence: "SCALAREF-RETIREMENT.3 migrated shipped specs, checked-in Rust oracle inputs, focused tests, generator fixtures, user guides, and mdBook chapters away from active scalaref(...) and .scalaref(...) examples. SCALAREF-RETIREMENT.4 then removed implementation support and added focused negative tests. SCALAREF-RETIREMENT.5 swept the older root language-neutral tests/corpus fixtures and current-facing docs/KM wording. RUST-PARITY.7.2 later expanded the Rust corpus to 65 fixtures while preserving the migrated Lispish direct-access fixture. Phase0 passes with 1015 tests; active scalaref scans are clean except intentional negative locks."
reverify: "bash -lc '! rg -n \"scalaref\\(|\\.scalaref\\(\" specs tests/corpus rust/linkedspec-runtime/tests/corpus docs/linkedspec-book/src USER_GUIDE*.md tools/gen_oracle_corpus.pl rust/README.md'"
---

# `scalaref(...)` Live Surface Migration

`SCALAREF-RETIREMENT.3` moved the active live surface away from the legacy helper.
Shipped specs, checked-in corpus inputs, focused tests, the oracle generator, user
guides, and mdBook chapters no longer use active `scalaref(...)` or receiver-dot
`.scalaref(...)` examples.

Function-form payload reads now use direct nested access such as `retv["content"]`,
`retv[0]`, `first_capt[0]`, and `cur_object[1]`.

Receiver-dot field reads on named working hashes use `scalar(hash(name), key)`. Direct
bracket reads such as `retv["key"]` are for scalar variables intentionally holding a
hashref/arrayref payload, not for named working-hash value reads.

Implementation support was removed by `SCALAREF-RETIREMENT.4`, which also added focused
negative tests for the old function-form and receiver-dot spellings. `SCALAREF-RETIREMENT.5`
closed the remaining root corpus and current-facing prose drift.
