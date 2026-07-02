---
id: scalaref-retirement-inventory-contract
title: scalaref retirement inventory is complete; function form migrates to direct nested access, receiver-dot form uses named hash reads or temps
answers:
  - "how should scalaref be replaced"
  - "what replaces scalaref(retv, {content})"
  - "what replaces scalaref(retv, [0])"
  - "what replaces receiver dot scalaref"
  - "how many shipped specs still use scalaref"
  - "which leaf owns scalaref migration"
date: 2026-07-02
status: confirmed
tags: [dsl, retirement, scalaref, direct-access, migration]
evidence: "SCALAREF-RETIREMENT.2 inventory: rg found 16 function-form scalaref calls in shipped specs, live corpus/test/tool/doc implementation support, 332 mdBook/user-guide function-form references, and receiver-dot .scalaref examples. Perl call_spec_handler_subst proves retv[\"content\"], retv[\"children\"][0][\"name\"], cur_object[1], and first_capt[0] lower correctly. Rust direct-access parser/runtime focused tests pass."
reverify: "rg -n 'scalaref\\(' specs rust/linkedspec-runtime/tests/corpus docs/linkedspec-book/src USER_GUIDE*.md perl rust t tools && perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(retv[\"content\"])}, q{return(retv[\"children\"][0][\"name\"])}, q{return(cur_object[1])}) { print LinkedSpec::call_spec_handler_subst(\"Top\",$expr), \"\\n\" }'"
---

# `scalaref(...)` Retirement Inventory Contract

`SCALAREF-RETIREMENT.2` locked the replacement contract before code changes.

Function-form calls migrate directly:

- `scalaref(base, {field})` -> `base["field"]`
- `scalaref(base, [0])` -> `base[0]`
- `scalaref(base, {children}[0]{name})` -> `base["children"][0]["name"]`
- dynamic indexes can use `base["children"][i]` or `base["children"][scalar(i)]`

Receiver-dot `.scalaref(key)` is also in scope for retirement. For a named hash, use
`scalar(hash(meta), key)` or direct `meta[key]`. For an expression receiver, assign the
hash expression to a named hash temporary first, then read from that temporary.

Implementation support must remain until `SCALAREF-RETIREMENT.3` migrates shipped specs,
fixtures, tests, and public docs. Removal belongs to `SCALAREF-RETIREMENT.4`.
