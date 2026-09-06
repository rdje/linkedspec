---
id: specentry-and-bcode-unbound-inputs
title: SpecEntry AND_BCODE handoff reads unbound package variables instead of explicit inputs
answers:
  - "why does SpecEntry AND_BCODE omit and_icode"
  - "does SpecEntry AND_BCODE depend on package globals"
  - "where are the AND_BCODE REs and and_icode handoff repaired"
date: 2026-09-06
status: confirmed private handoff defect; repair owned by SESSION-STARTUP-READING.10 after required reading
tags: [perl, specentry, handler-ir, diagnostics, defect, continuity]
evidence: "SESSION-STARTUP-READING.3.2.8 read all 600 SpecEntry lines at unchanged baeb984e, intercepted emitted HandlerIR with a process-local callback, compared absent versus localized package globals, and inspected a public Get descriptor/source control. Normal AND_BCODE omits both optional fields; local package state injects both despite unchanged explicit arguments. No public result defect or intended semantic repair is claimed."
reverify: "rg -n 'REs =>|defined[(][$]and_icode|my [$]and_icode_arg|my @REs|my [$]and_icode|sub _build_and_bcode' perl/LinkedSpec/SpecEntry.pm perl/LinkedSpec/HandlerVariantEmitter.pm"
---

`SpecEntry::_build_handler_variants` passes `REs => \@REs` and conditionally passes `$and_icode`
to `_build_and_bcode_variant`. Neither variable is lexical in that subroutine. The lexicals of those
names in the separate `compile_spec_entry` caller do not enter its scope. Since SpecEntry is non-strict,
the references resolve to `@LinkedSpec::SpecEntry::REs` and `$LinkedSpec::SpecEntry::and_icode`.
The explicit `and_icode` argument is separately used by the single-acode branch.

An isolated probe called the builder with `node_type => 'AND'`, `regex_count => 1`, empty acodes,
one `Child` bcode/call, empty dependency refs, `cursor_policy => 'consume'`, and
`and_icode => 'return "argument"'`. A localized emitter callback captured the constructed nodes:

| Local package state | AND_BCODE `REs` present | AND_BCODE `and_icode` |
| --- | --- | --- |
| Empty/undefined | No | Absent |
| `REs = (qr/z/)`, `and_icode = 'return "package-global"'` | Yes | Package-global string |

The same ordinary arguments produced an `and_single_acode` node with its supplied `and_icode`.
The AND_BCODE callee retains the optional fields when present, and its emitter uses them to activate
a legacy regex-match/I-block section. Supporting source read: HandlerVariantEmitter.pm 100–176 and 804–880.

A public `LinkedSpec::Get` descriptor/generated-source control accepted:

```text
Top::AND
 /a/ I { return("a-result") }
 => Child { return("child-result") }

Child:
 I { return("child-body") }
```

It selected `AND_BCODE`, recorded one regex and blind edge ownership, and emitted the child-call loop
without the optional match section or `a-result`. This is an observation, not proof that the parent
should match its own regex: entry alone must not self-match under ADR 0010. No public execution/result
failure was measured. The proven defect is the unintended dependency on package state.

Repair `.10` must establish the supported current extension boundary, eliminate unbound inputs, and
lock state independence while preserving entry and blind-call semantics. It must not blindly forward
fields to revive an obsolete match path. Full reading precedes that implementation and public-book review.
Related: [[specentry-perl-coupling-inventory]], [[top-rule-is-ordinary-rule-entered-first]],
[[rule-local-cursor-and-bare-edge-contract]].
