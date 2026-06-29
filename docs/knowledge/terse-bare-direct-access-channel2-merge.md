---
id: terse-bare-direct-access-channel2-merge
title: "SPEC-FORMAT-TERSE.1.5.5.2 — bare direct-access path atoms were merged into Channel 2, then landed under SPEC-FORMAT-TERSE.1.2.3.3.3."
answers:
  - "why was SPEC-FORMAT-TERSE.1.5.5.2 superseded"
  - "where is foo[\"a\"][z] tracked now"
  - "why not implement bare direct access [z] locally"
  - "what is the next Channel 2 leaf after direct access"
date: 2026-06-29
status: confirmed
tags: [dsl, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, channel-2, task-tree]
evidence: "After SPEC-FORMAT-TERSE.1.5.5.1 landed, a focused TOOLBOX reverify showed that explicit direct access lowered but bare `[z]` still needed the Channel 2 value-read design. Therefore SPEC-FORMAT-TERSE.1.5.5.2 was superseded/merged into SPEC-FORMAT-TERSE.1.2.3 instead of implementing a direct-access-local `[z]` rule. SPEC-FORMAT-TERSE.1.2.3.3.3 later landed the accepted subset: non-reserved bare direct-access path atoms are scalar array-index reads, so `return(foo[\"a\"][9][\"b\"][z])` lowers to `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`; scalaref historical path spelling remains unchanged."
reverify: "rg -n 'SPEC-FORMAT-TERSE.1.5.5.2|SPEC-FORMAT-TERSE.1.2.3.3.3|terse-direct-access-bare-path-atoms' docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/terse-bare-direct-access-channel2-merge.md docs/knowledge/terse-direct-access-bare-path-atoms.md && perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(foo[\"a\"][9][\"b\"][z])}, q{return(foo[\"a\"][9][\"b\"][scalar(z)])}, q{return(scalaref(foo,{\"a\"}[9]{\"b\"}[z]))}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }'"
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

That leaf owned Channel 2 design/splitting for value-position bare-word reads plus RHS-shape/type inference.
The direct path-atom portion has since landed under [[terse-direct-access-bare-path-atoms]]; this card remains
the historical reason `.1.5.5.2` did not implement `[z]` locally.
