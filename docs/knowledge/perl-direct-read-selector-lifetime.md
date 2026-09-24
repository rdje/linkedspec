---
id: perl-direct-read-selector-lifetime
title: "Perl direct reads retain their receiver across selector rebinding"
answers:
  - "why does a Perl direct-read probe disagree with the compiled parser after a selector rebinds its receiver"
  - "can an unused saved binding change a Perl direct-read result"
  - "which task repairs Perl selector receiver lifetime"
date: 2026-09-24
status: repaired under SESSION-STARTUP-READING.89; native and fresh generated controls verified
tags: [perl, bindings, read, selectors, lifetime, SESSION-STARTUP-READING]
evidence: "Public Get and fresh emitted execution return null for sole-owned receiver rebinding. Keeping the old array or nested child in an otherwise unused binding changes the result to old2/old1. Public call_spec_handler_subst and B::Concise of its compiled output put the receiver dereference before the selector. Exact sources, observations and operation trace are retained in docs/checkpoints/SESSION-STARTUP-READING.89-selector-lifetime.json."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t"
---

The baseline at `5e72c32b0f185783a8b6b597561e1470ce03c8f7` has two
related direct-read defects. Raw dereferences create missing containers (see
[[perl-direct-read-autovivification-gap]]). Separately, a selector can rebind the
receiver after its dereference has begun, and the eventual result depends on
whether another reference retains that original container.

```text
document = ["old0", "old1", "old2"]
observed = document[set(document, ["new0", "new1"]).count()]
```

Before repair, public Get and fresh emitted parsers return null for `observed`. Adding
`saved = document` before the read changes `observed` to `"old2"`, while the
new `document` is `["new0","new1"]` in both cases. The analogous nested
read returns null without a retained child and `"old1"` with it. The generated
handler has ordinary lexicals and raw dereferences; no tied-binding mechanism
explains the difference. The compiled operation trace reaches the receiver before
executing the selector. The retention controls isolate the missing lifetime
protection during that interval; they do not establish a Perl toolchain defect.

An initial standalone string-eval probe kept its input array in a case record,
so it observed the retained result. This was insufficient to establish the
behavior of a complete authored parser. The repair must test both ownership
conditions through native and fresh emitted execution.

Startup `.89` now guards the read cursor and retains its observed value
through selector execution. Sole-owned and retained cases both return `old2` /
`old1`; the authored receiver rebinding still occurs. The tests separately assert
selector count/order, propagated failures, binding presence and reference identity.
This is a Perl repair; it does not define a new portable ordering contract for
selectors that mutate their receiver. The read-purity book section states that
boundary and recommends evaluating effectful selectors before portable reads.
