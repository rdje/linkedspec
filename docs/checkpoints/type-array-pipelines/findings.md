# Owned follow-up findings

Owner: TYPE-REFERENCE-BOOK.1.2.9; these are scheduled follow-up leaves, not extra
runtime repairs within9. Full public sources and diagnostics survive in
baseline-run.json.gz, candidate1-run.json.gz, candidate2-run.json.gz,
inspection.json.gz and kind-investigation2.json.gz.

- TYPE-REFERENCE-BOOK.1.2.13 (P1, immediately after9): lexical comparison adds POK
  to numeric scalars. Public native/fresh sorted results retain IOK+POK; an actual
  Storable clone drops IOK and emits strings. Deferred array-literal copying
  uses that clone. An ordinary and a deferred selected numeric index both reject
  array writes with nested_write_kind_conflict; numeric-literal controls retain
  IOK alone. Repair sort/copy kind preservation with scalar flags, public index
  consumers and serialized kind controls, retaining original95 reducer ownership.
- TYPE-REFERENCE-BOOK.1.2.10 (P2, after13): deferred sorted/take receivers reach
  unknown_helper at count/first, although both work in ordinary actions. Implement
  these two existing helper families with shapes, empty/kind/terminal/effect controls.
- TYPE-REFERENCE-BOOK.1.2.11 (P2, after10): registered fn select_items(items) with
  return(items.sorted().take(2)) is marked unresolved sorted; ordinary invocation
  returns[] and invocation from a codeblock raises user_function_body_unsupported.
  Separately, ordinary items.sorted().take(2).length() stays raw and calls a host
  sorted function; the deferred equivalent succeeds. Resolve the public lowering
  mechanisms with independent named-function and length-chain controls.
- TYPE-REFERENCE-BOOK.1.2.12 (P2, after11): a deferred chosen[0] = "changed" reaches
  unsupported_codeblock_actionir:assign_nested_access. Ordinary indexed assignment
  succeeds. Repair the typed write family with correct keys, copy/alias policy,
  effects, caller bindings and malformed-record controls.

Two preparation failures are not product defects: ordinary push(out,9) means a
child-rule push, so copy controls now mutate the returned array in the supported
caller; the first scalar-flag instrument could not serialize a blessed error.
Its exact failed source/run is retained in kind-investigation.json.gz; the corrected
instrument recursively preserves typed fields. No old output was overwritten.

Count/first confirmation at the final9 source is in followup-confirmation.json.gz: ordinary2/1; deferred unknown_helper:count/first. The older baseline stopped earlier at sorted.
