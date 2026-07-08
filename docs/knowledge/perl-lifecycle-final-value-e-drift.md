---
id: perl-lifecycle-final-value-e-drift
title: Current Perl generated-handler shapes can leak lifecycle final statement values and can omit direct default-rule E finalization
answers:
  - "why did a lifecycle block without return produce not_a_return"
  - "does Perl direct Top I regex E run the E block"
  - "can I rely on E finalization in a default regex rule"
  - "why should lifecycle examples use explicit return"
  - "can Perl lifecycle blocks leak the final statement value"
date: 2026-07-08
status: current
tags: [perl-reference, lifecycle, generated-handlers, mdbook, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.10.5.9 used the LinkedSpec TOOLBOX while fixing `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`. Runtime probes showed `Top:: I { set(out,\"from_i\"); set(ignored,\"not_a_return\") } /x/ E { return(hash(...)) }` returns `\"not_a_return\"` on the Perl reference. `dump_parser_source` for that shape emitted only the `I` block body; the `/x/` regex and `E` finalization path were absent from the generated default handler. A dispatched `Example: /x/ I { set(...); set(...) }` with no explicit return likewise surfaced `[\"not_a_return\"]`, while the same child with explicit `return(hash(...))` surfaced the intended hash. The mdBook page now warns that public lifecycle examples must use explicit `return(...)` and must not depend on host final-statement leakage or direct `E` finalization in handler-sensitive shapes."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); my $s=qq{Top::\\n I { set(out, \"from_i\"); set(ignored, \"not_a_return\") }\\n /x/\\n E { return(hash(\"out\", out, \"ignored\", ignored)) }\\n}; my $p=LinkedSpec::Get(\\$s, top_rule=>\"Top\", parse_mode=>\"consume\"); my $in=\"x\"; print $json->encode($p->(\\$in)),\"\\n\";'"
---

# Perl Lifecycle Final-Value / E Drift

Current Perl generated-handler behavior is narrower than the intended portable lifecycle contract in some shapes.

- A lifecycle block that omits explicit `return(...)` can expose the host-language value of its final statement.
- A direct default-rule shape such as `Top::` + `I` + regex + `E` can generate only the `I` body, so the `E` block is not a reliable teaching example for the current Perl reference.
- Public examples should make lifecycle return-channel writes explicit. Use `return(...)` when a lifecycle block is meant to produce a parser value; otherwise write the block only for side effects and do not infer a value from its final statement.

This is a current-backend caveat, not a portable language feature.
