---
id: perl-capture-slice-delimiter-seek-boundary
title: "Perl reference delimiter capture with capture_slice() needs a seek-capable close step when body text separates opener and closer; consume-mode child close checks do not skip the body"
answers:
  - "why does a delimiter capture_slice child rule return null in consume mode"
  - "how do I write a Perl delimiter capture_slice example with a no-regex top wrapper"
  - "does capture_slice work for BEGIN body END examples in the Perl reference"
  - "what parse mode is needed for a minimal opener/body/closer capture_slice example"
  - "how can a no-regex Top wrapper demonstrate capture_slice"
date: 2026-07-08
status: confirmed
tags: [perl, mdbook, capture-slice, parse-mode, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.10.5.10 verified through LinkedSpec::Get: `Top:: -> Body .push / LX { return(copy(array(Top))) }` plus `Body: /BEGIN/ /END/ -> Body[1] { return(hash(\"body\", trim(capture_slice()))) }` returns `[{\"body\":\"body\"}]` for `BEGIN body END` with `parse_mode=>\"seek\"`, but the same shape returns `[null]` with `parse_mode=>\"consume\"`. Trace showed the child close step checked at the cursor after the opener and took the no-match path instead of skipping over body text. The shipped hlink parser has the same seek-shaped delimiter capture behavior (`[abc]` -> `[\"abc\"]`)."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $J=JSON::PP->new->canonical(1)->allow_nonref(1); my $s=q{Top::\\n -> Body .push\\n LX { return(copy(array(Top))) }\\n\\nBody: /BEGIN/ /END/\\n -> Body[1] { return(hash(\"body\", trim(capture_slice()))) }\\n}; for my $mode (qw(seek consume)) { my $p=LinkedSpec::Get(\\$s, top_rule=>\"Top\", parse_mode=>$mode); my $input=\"BEGIN body END\"; print \"$mode=\",$J->encode($p->(\\$input)),\"\\n\" }'"
---

# Perl delimiter `capture_slice()` examples are seek-shaped

A minimal no-regex top wrapper can demonstrate `capture_slice()` without putting regex
slots under `::`:

```text
Top::
 -> Body .push
 LX { return(copy(array(Top))) }

Body: /BEGIN/ /END/
 -> Body[1] { return(hash("body", trim(capture_slice()))) }
```

With seek-mode matching, `BEGIN body END` returns:

```json
[{"body":"body"}]
```

The same minimal shape returns `[null]` under consume mode when body text separates the
opener and closer. The child close regex is checked at the cursor after the opener; in
consume mode it cannot skip over the body text to find the closer. That is an authoring
shape issue, not a `capture_slice()` helper failure.

This fact matters for book examples: use this delimiter capture example as a seek-mode
worked example, or explicitly model the intervening body tokens when demonstrating
consume-mode parsing.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] leaf `.10.5.10`
- Book: `docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md`
- Related: [[rust-anonymous-capture-slice-family]], [[spec-top-rule-no-regex-two-rule-minimum]]
