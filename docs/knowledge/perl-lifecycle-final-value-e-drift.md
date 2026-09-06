---
id: perl-lifecycle-final-value-e-drift
title: Current Perl generated-handler shapes can leak lifecycle final statement values and can omit direct default-rule E finalization
answers:
  - "why did a lifecycle block without return produce not_a_return"
  - "does Perl direct Top I regex E run the E block"
  - "can I rely on E finalization in a default regex rule"
  - "why should lifecycle examples use explicit return"
  - "can Perl lifecycle blocks leak the final statement value"
  - "is Perl lifecycle final-value drift a docs caveat or implementation task"
  - "which startup repair owns Perl direct default E finalization"
date: 2026-07-08
status: current
tags: [perl-reference, lifecycle, generated-handlers, mdbook, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.10.5.9 used the LinkedSpec TOOLBOX while fixing `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`. Runtime probes showed `Top:: I { set(out,\"from_i\"); set(ignored,\"not_a_return\") } /x/ E { return(hash(...)) }` returns `\"not_a_return\"` on the Perl reference. `dump_parser_source` for that shape emitted only the `I` block body; the `/x/` regex and `E` finalization path were absent from the generated default handler. A dispatched `Example: /x/ I { set(...); set(...) }` with no explicit return likewise surfaced `[\"not_a_return\"]`, while the same child with explicit `return(hash(...))` surfaced the intended hash. The mdBook page now warns that public lifecycle examples must use explicit `return(...)` and must not depend on host final-statement leakage or direct `E` finalization in handler-sensitive shapes."
evidence_update_2026_07_08_10520: "SPEC-LANG-REFERENCE.10.5.20 reverified the drift and recorded ADR 0020: this remains a documented current Perl-reference caveat for the language-reference closeout, not an implicit Perl engine-change authorization. Any behavior normalization for lifecycle final-value or direct-default-rule `E` handling needs a separately-owned implementation/parity leaf with focused locks."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); my $s=qq{Top::\\n I { set(out, \"from_i\"); set(ignored, \"not_a_return\") }\\n /x/\\n E { return(hash(\"out\", out, \"ignored\", ignored)) }\\n}; my $p=LinkedSpec::Get(\\$s, top_rule=>\"Top\", parse_mode=>\"consume\"); my $in=\"x\"; print $json->encode($p->(\\$in)),\"\\n\";'"
---

# Perl Lifecycle Final-Value / E Drift

Current Perl generated-handler behavior is narrower than the intended portable lifecycle contract in some shapes.

- A lifecycle block that omits explicit `return(...)` can expose the host-language value of its final statement.
- A direct default-rule shape such as `Top::` + `I` + regex + `E` can generate only the `I` body, so the `E` block is not a reliable teaching example for the current Perl reference.
- Public examples should make lifecycle return-channel writes explicit. Use `return(...)` when a lifecycle block is meant to produce a parser value; otherwise write the block only for side effects and do not infer a value from its final statement.

This is a current-backend caveat, not a portable language feature.

`SPEC-LANG-REFERENCE.10.5.20` records the decision in ADR 0020: keep this as a
documented caveat until a separate implementation/parity task explicitly owns any Perl
generated-handler behavior change.

The September 6 intake at `SESSION-STARTUP-READING.31` gives that implementation/parity work an explicit
owner: `SESSION-STARTUP-READING.27`, with separate contract/mode reconciliation, Perl repair, and carrier/book
closeout children. ADR 0020 remains the historical caveat decision; this intake does not normalize behavior.

At baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`, public controls with no outgoing edge and
`Top:: /x/ E { return(match_text()) }` return `0` on Perl and `"x"` on Julia. Explicit self-edge return
controls return `"x"` on both. Perl's no-edge E constant returns `0`; an I constant works; E after an edge
assignment returns null. Full generated-source inspection omits the direct regex/E path: the default builder
in `perl/LinkedSpec/HandlerVariantEmitter.pm` at 100–115 returns undef without action code, while
`perl/LinkedSpec/SpecEntry.pm` at 143–186 and 287–295 passes E code without a usable handler for that shape.
Julia's mode execution retains its own regex. These bounded observations require reconciling the intended
mode/lifecycle contract; they do not establish that Julia is wrong or authorize implicit self-matching changes.
