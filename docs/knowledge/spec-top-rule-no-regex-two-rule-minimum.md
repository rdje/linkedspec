---
id: spec-top-rule-no-regex-two-rule-minimum
title: "Superseded historical card: no-regex top plus normal matcher rules is a stream-parser idiom, not the .spec validity doctrine; current doctrine is :: entry marker with the same feature surface as :"
answers:
  - "why must I not put a regex on the top rule"
  - "is no regex on top still the LinkedSpec rule"
  - "is a valid .spec required to have two rules"
  - "was the two-rule minimum doctrine superseded"
  - "was the no-regex top rule doctrine superseded"
  - "how do I write a minimal stream-style worked .spec example for the book"
date: 2026-07-08
status: superseded
tags: [spec-language, structure, top-rule, authoring, SPEC-LANG-REFERENCE, ADR-0010]
evidence: "ADR 0010 (2026-06-23) accepted the current model: `::` is an entry marker for the rule entered first; the top rule is otherwise an ordinary rule. SPEC-LANG-REFERENCE.8 reverified on 2026-07-08 that a regex-bearing `Entry::` and a selected regex-bearing `Body:` with the same default body both return `\"foo\"`, and `Entry::AND` / selected `Body:AND` with the same regex slots both return `{name:\"name\",value:\"value\"}`. Therefore the old 'top has no regex / valid spec needs >=2 rules / never put a regex on the top rule' doctrine is superseded as a validity claim. The two-rule no-regex top wrapper remains a recommended stream-of-records teaching idiom because the shipped specs commonly use a top accumulator wrapper plus regex-owning matcher rules."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $J=JSON::PP->new->canonical(1)->allow_nonref(1); my $s=\"Entry:: /foo/ -> Entry { return(match_text()) }\\n\\nBody: /foo/ -> Body { return(match_text()) }\\n\"; for my $top (qw(Entry Body)) { my %c; my $p=LinkedSpec::Get(\\$s, top_rule=>$top, parse_mode=>\"seek\", runtime_ctx_ref=>\\%c); print $top,\" \",$J->encode($p->(\\\"xxfoo\\\")),\"\\n\" }'"
---

# Superseded No-Regex Top Doctrine

This card is kept because many historical notes and searches use its old name. Its old
claim is **superseded**.

## Current Doctrine

`::` is the **entry marker**: it identifies the rule a backend enters first. Once selected,
that rule has the same feature surface as a `:` rule. It may carry regex slots, take rule
modes such as `AND` or `OR`, use action or blind-call edges, and participate in recursion.
A complete `.spec` still needs an entry marker so a backend knows where to start, but a
regex-bearing `::` rule is valid.

The canonical current home is [[top-rule-is-ordinary-rule-entered-first]] and ADR
[0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md).

## What Remains Useful

The two-rule, no-regex top shape remains a good **stream-of-records idiom**:

```text
demo::  -> value  .push
LX { return(copy(array(demo))) }

value : /(\w+) (\w+)/  I.return(cat(entry_group(0), "-", entry_group(1)))
```

Input `hello world` returns `["hello-world"]` when run through `LinkedSpec::Get`.
The top rule dispatches and returns its accumulator; the child matcher owns the regex
and reads the entering match with `entry_group(N)`.

Use this idiom when the parser should scan a stream and collect repeated child payloads.
Do **not** describe it as a validity minimum or as a ban on regex-bearing `::` rules.

## Historical Claims Retired

These statements are no longer current doctrine:

- "The top rule has no regex."
- "A valid `.spec` needs at least two rules."
- "Never put a regex on the top rule."
- "Regex-on-top examples are malformed."

The real distinction is narrower and simpler: `::` marks the rule entered first; `:` does
not.

## Links

- Current doctrine: [[top-rule-is-ordinary-rule-entered-first]]
- Match-reader footgun for regex-bearing top rules: [[top-rule-reads-own-match-with-match-family]]
- Recursion/termination: [[top-rule-recursion-forward-progress-guard]]
