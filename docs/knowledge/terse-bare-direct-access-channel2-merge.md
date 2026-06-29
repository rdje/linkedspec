---
id: terse-bare-direct-access-channel2-merge
title: "SPEC-FORMAT-TERSE.1.5.5.2 — bare direct-access path atoms are merged into Channel 2 value-position reads."
answers:
  - "why was SPEC-FORMAT-TERSE.1.5.5.2 superseded"
  - "where is foo[\"a\"][z] tracked now"
  - "why not implement bare direct access [z] locally"
  - "what is the next Channel 2 leaf after direct access"
  - "does foo[\"a\"][9][\"b\"][z] work after explicit direct access"
date: 2026-06-29
status: confirmed
tags: [dsl, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, channel-2, task-tree]
evidence: "After SPEC-FORMAT-TERSE.1.5.5.1 landed, a focused TOOLBOX reverify showed `return(foo[\"a\"][9][\"b\"][scalar(z)])` lowers to `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`, while `return(foo[\"a\"][9][\"b\"][z])` remains raw as `return foo[\"a\"][9][\"b\"][z]` and `return(z)` remains the bareword `return z`. Rust retains the parser test `parse_direct_nested_access_rejects_bare_segments`, which rejects bare direct-access path atoms as Channel 2-reserved. Therefore SPEC-FORMAT-TERSE.1.5.5.2 was superseded/merged into new SPEC-FORMAT-TERSE.1.2.3 instead of implementing a direct-access-local `[z]` rule."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(foo[\"a\"][9][\"b\"][scalar(z)])}, q{return(foo[\"a\"][9][\"b\"][z])}, q{return(z)}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_direct_nested_access_rejects_bare_segments -- --nocapture"
---

# Bare Direct Access Merged Into Channel 2

`SPEC-FORMAT-TERSE.1.5.5.2` did not implement a direct-access-only meaning for bare path atoms such as:

```text
foo["a"][9]["b"][z]
```

That spelling needs the same value-position bare-word-read model as:

```text
return(z)
```

Implementing `[z]` locally would decide scalar/array/hash reads and key-vs-index behavior before the global
Channel 2 design has defined those semantics for return payloads, RHS expressions, hash keys, and helper
value slots.

The owning leaf is now:

```text
SPEC-FORMAT-TERSE.1.2.3
```

That leaf owns Channel 2 design/splitting for value-position bare-word reads plus RHS-shape/type inference.
