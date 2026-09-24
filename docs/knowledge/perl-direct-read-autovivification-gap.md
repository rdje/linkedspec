---
id: perl-direct-read-autovivification-gap
title: "Perl direct reads violate the write-only creation contract"
answers:
  - "can Perl direct reads create missing containers"
  - "why does reading a missing Perl path replace null or create an array"
  - "which task repairs Perl direct read purity"
  - "do the write vivification read exclusions hold through Perl Get"
date: 2026-09-24
status: confirmed defect; SESSION-STARTUP-READING.89 is next repair after containment .16
tags: [perl, bindings, arrays, read, autovivification, SESSION-STARTUP-READING]
evidence: "Six public Get/call_spec_handler_subst and Rust CLI observations are retained in docs/checkpoints/SESSION-STARTUP-READING.89-read-purity.json. Five Perl reads mutate the root or an intermediate; one existing-container control agrees. All six Rust results preserve expected state. No handler errors explain away the mutations."
reverify: "Replay the checkpoint source/input pairs through LinkedSpec::Get with runtime_ctx_ref and rust/target/debug/linkedspec-rust --inline-spec SOURCE --input x --trace low under tools/project_data_run.sh; compare the entire read/after object, not only the returned element."
---

ADR0036 and `write_vivification_contract.json` require reads to leave state
unchanged. The neutral `read_exclusion_cases` include an absent root and a missing
intermediate. The public book and earlier implementation cards repeated that
requirement as an unconditional implementation fact. Startup `.88` independently
checked it while reviewing its Rust indexed-read documentation and found a Perl
violation:

| State and read | Perl state afterward | Required state afterward |
| --- | --- | --- |
| absent `items`; `items[0]` | `[]` | absent/null observation |
| `items = undef`; `items[0]` | `[]` | `null` |
| `tree = {}`; `tree["missing"][0]` | `{"missing":[]}` | `{}` |
| `tree = []`; `tree[0][0]` | `[[]]` | `[]` |
| `tree = {"missing":undef}`; `tree["missing"][0]` | `{"missing":[]}` | `{"missing":null}` |

Each read returns null, so a result-only check misses the state mutation.
`tree = {"list":["a"]}; tree["list"][0]` returns `"a"` and preserves the
existing container on both engines. All six sources compile and run without a
Perl context error; Rust preserves the complete expected objects.

Toolbox lowering shows `$items->[0]`, `$tree->{"missing"}->[0]`, and
`$tree->[0]->[0]`. The first-party owner is
`perl/LinkedSpec/ActionIR/ValueExpr.pm::_lower_direct_nested_access_value_expr`:
it starts from the base lexical and concatenates raw `->{...}` / `->[...]`
dereferences without a non-creating read operation. Perl autovivification changes
the observed binding. This is separate from the Rust private-map defect repaired
by `.88`, and separate from Perl grouped-postfix owner `.87.4`.

`.89` owns restoring the existing contract, native/generated recurrence,
binding-presence/shape/identity checks, dynamic index evaluation, wrong-kind
controls, and an audit of actual runtime read-exclusion coverage. It follows
containment `.16` immediately, before `.51`; it is not an optional proposal.
No neutral expectation is weakened, and no Perl production repair is claimed yet.

Related: [[write-vivification-receiver-mutation-direction]],
[[write-vivification-perl-reference]], [[rust-single-index-read-bypasses-typed-binding]].
