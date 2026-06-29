---
id: terse-direct-access-split-ground-truth
title: "SPEC-FORMAT-TERSE.1.5.5 ground truth — direct nested access must split before code: direct foo[...] lowering is invalid Perl today, scalaref remains the working explicit path, and bare path segments such as [z] belong with Channel 2 bare value-position reads."
answers:
  - "why is SPEC-FORMAT-TERSE.1.5.5 split before code"
  - "does foo[\"a\"][9][\"b\"][z] work as direct nested access"
  - "what is the first implementation leaf for direct nested access"
  - "why is a bare direct-access path segment like z deferred"
  - "how does direct nested access relate to Channel 2 bare value-position reads"
  - "what does scalaref lower to compared to direct foo bracket access"
date: 2026-06-29
status: confirmed
tags: [dsl, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, channel-2, actionir, rust, parser]
evidence: "KM retrieval first, then TOOLBOX probes on 2026-06-29. `call_spec_handler_subst(\"Top\", q{return(foo[\"a\"][9][\"b\"][scalar(z)])})` returns raw/invalid Perl-shaped `return foo[\"a\"][9][\"b\"][$z]`, while `return(scalaref(foo,{\"a\"}[9]{\"b\"}[scalar(z)]))` lowers to `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`. A generated-source/runtime probe with a populated `$foo` and `$z` produced handler compile failure near `][`, confirming direct bracket syntax is not a working Perl value expression. `return(foo[\"a\"][9][\"b\"][z])` and `scalaref(...[z])` leave `z` bare, matching the existing Channel 2 ground truth that bare value-position reads are not variables yet. Rust code-read: `linkedspec-core::Expr::IndexedVar` is single-level `name[index]`, and `linkedspec-runtime::Engine::eval_expr` reads only a named array by numeric index."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(foo[\"a\"][9][\"b\"][scalar(z)])}, q{return(foo[\"a\"][9][\"b\"][z])}, q{return(scalaref(foo,{\"a\"}[9]{\"b\"}[scalar(z)]))}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }'"
---

# `.1.5.5` Direct Nested Access Split Ground Truth

`SPEC-FORMAT-TERSE.1.5.5` is too broad to implement as one signoff slice because it combines two separate
problems:

- Direct bracket-path lowering/parsing for a nested value expression.
- Bare path-segment/value-position reads such as the final `[z]` in `foo["a"][9]["b"][z]`.

The first problem can be implemented and locked with explicit segment expressions. The second belongs with
Channel 2, where bare value-position words become variable reads and need type/sigil inference.

## Current Behavior

- `foo["a"][9]["b"][scalar(z)]` is not lowered to the existing dereference path. Perl currently emits
  invalid generated handler code shaped like `foo["a"][9]["b"][$z]`.
- `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` remains the working explicit form and lowers to
  `$foo->{"a"}->[9]->{"b"}->[$z]`.
- Bare segment `z` is not a variable read today. The existing `scalaref(...[z])` path preserves it as a bare
  atom, and direct access does the same.
- Rust currently parses/evaluates only one-level `name[index]` as an array lookup; it does not model mixed
  hash/array paths or any-depth access.

## Split Consequence

- `.1.5.5.1` owns direct nested access for explicit segment expressions, for example
  `foo["a"][9]["b"][scalar(z)]`.
- `.1.5.5.2` owns the bare-segment/Channel-2 coordination needed for the full brainstorm spelling
  `foo["a"][9]["b"][z]`.
