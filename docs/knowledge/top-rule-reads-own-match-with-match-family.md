---
id: top-rule-reads-own-match-with-match-family
title: "Authoring mechanics (TOP-RULE-AS-NORMAL.4): a top (::) rule matching its OWN regex slots reads its match with the match_* family from a POST-MATCH edge action, NOT entry_*/an I-block. Nothing 'enters' a top rule, so entry_* is empty and an I-block runs before the rule matches; entry_text()/entry_group() on a top rule yield null. A dispatched body rule is the opposite (use entry_* — the parent's dispatch is the entering match). Also: a bare edge-less regex slot in an AND rule is a positional anchor that is NOT separately consumed/captured, so fold a separator like \\s*=\\s* into a slot explicitly selected by an edge."
answers:
  - "how does a top rule read its own regex match (match_* vs entry_*)"
  - "why does entry_text() / entry_group() return null on a top rule"
  - "why does an I-block on a top rule see no match"
  - "how do I read captures from a regex-on-top rule"
  - "does a regex on a top rule work and how do I get its value"
  - "entry_* vs match_* for a top rule vs a dispatched body rule"
  - "why does a bare middle regex slot in an AND rule not consume the separator"
  - "how do I write a working Pair::AND rule that returns name/value"
date: 2026-06-23
status: confirmed
tags: [spec-language, authoring, top-rule, regex, entry-vs-match, AND-mode, TOP-RULE-AS-NORMAL, ADR-0010]
evidence: "LinkedSpec::Get probes 2026-06-23 (TOP-RULE-AS-NORMAL.4, dump-don't-transcribe; scratchpad verify4b/4c/4d). (1) `Pair::AND` (top rule) with `/(name)\\s*=\\s*/ -> Pair[0] {set name=match_group(0)}` + `/(value)/ -> Pair[1] {return value=match_group(0)}` on `name = value` (consume) => {\"name\":\"name\",\"value\":\"value\"}. (2) The SAME shape with entry_text() instead of match_group(0) => {\"name\":null,\"value\":null} -- a top rule has no entering match. (3) A single-slot top rule with an I-block reading match_group/entry_group => {\"name\":null,\"value\":null} because I runs BEFORE the own-slot match (use a post-match edge or E/EX). (4) A bare edge-less middle slot `/\\s*=\\s*/` between two captured slots is NOT consumed: the value slot's match_text came back as ` = value` (the cursor had not advanced past `name`), so the separator must be folded into a slot that owns an edge (verified clean: name slot `/(name)\\s*=\\s*/`, value slot `/(value)/`). A dispatched body rule is the inverse: the worked-spec `Pair:` matcher reads entry_group(N) because the parent `Top:: -> Pair` dispatch is the entering match. Locked by phase0 `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $J=JSON::PP->new->canonical(1)->allow_nonref(1); my $s=\"Pair::AND\\n I { set(hash(pair), {}) }\\n /([A-Za-z_]\\\\w*)\\\\s*=\\\\s*/ -> Pair[0] { set(hash(pair), set_key(hash(pair), \\\"name\\\", match_group(0))); }\\n /([^,\\\\n]+)/ -> Pair[1] { return(set_key(hash(pair), \\\"value\\\", match_group(0))); }\\n\"; my $p=LinkedSpec::Get(\\$s, top_rule=>\"Pair\", parse_mode=>\"consume\"); print $J->encode($p->(\\\"name = value\\\")),\"\\n\";'  # => {\"name\":\"name\",\"value\":\"value\"}  (swap match_group(0)->entry_text() to see the null footgun)"
---

# A top rule reads its OWN regex match with `match_*`, not `entry_*`

**Confirmed 2026-06-23** (`TOP-RULE-AS-NORMAL.4`; model decided by ADR
[0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)). Refines the
"`::` is an entry marker, the top rule is otherwise ordinary" model
([[top-rule-is-ordinary-rule-entered-first]]) with the **authoring** consequence.

## `entry_*` (entering match) vs `match_*` (own match)

- A rule reached **by dispatch** (`Top:: -> Pair`) reads the **entering** match with the
  `entry_*` family — the parent's dispatch match is what matched, and it is already
  available when the child's `I` block runs. This is why the worked-spec `Pair:` matcher
  uses `entry_group(N)`.
- A **top rule has nothing that entered it.** So on a top rule `entry_*` is empty, and an
  `I` (init) block runs **before** the rule matches its own regex. `entry_text()` /
  `entry_group()` on a top rule therefore yield `null`. To read a top rule's **own** regex
  match, use a **post-match edge action** (`/re/ -> Self[N] { … match_group(0) … }`) and
  the `match_*` family.

```text
Pair::AND
 I { set(hash(pair), {}) }
 /([A-Za-z_]\w*)\s*=\s*/
 /([^,\n]+)/
 -> Pair[0] {
   set(hash(pair), set_key(hash(pair), "name", match_group(0)));
 }
 -> Pair[1] {
   return(set_key(hash(pair), "value", match_group(0)));
 }
```
`name = value` (parse mode `consume`) → `{ "name": "name", "value": "value" }`. Swapping
`match_group(0)` for `entry_text()` returns `{ "name": null, "value": null }` — the footgun
the book now warns against.

## Bare edge-less `AND` slots are positional anchors, not separately consumed

A bare regex slot with **no edge** in an `AND` rule (e.g. a middle `/\s*=\s*/`) is a
positional anchor that does not separately advance/capture: the next captured slot's
`match_*` still starts where the previous edge slot left the cursor. Fold a separator into
a slot explicitly selected by an edge (the `name` slot above eats `\s*=\s*`), rather than leaving it as
a standalone middle slot. (A bare-slot structural sketch with no action returns `null`
because no edge action returns a payload — it illustrates mode shape only.)

## Links

- Decision: [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)
- Tree: [[TOP-RULE-AS-NORMAL]] (`.4` book reconciliation)
- Book: `user-model/spec-files-and-rule-paragraphs.md` (entry-rule-is-ordinary section),
  `user-model/rule-modes-and-parse-modes.md` (the de-footgunned `Pair::AND` example),
  `appendix/formal-grammar.md` (§2.1 entry marker, §5.4 recursion/termination)
- Test lock: `t/phase0_regression.t` `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`
- Related: [[top-rule-is-ordinary-rule-entered-first]],
  [[top-rule-recursion-forward-progress-guard]], [[spec-top-rule-no-regex-two-rule-minimum]],
  [[spec-contract-is-unique]]
