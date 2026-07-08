---
id: entry-match-divergence-verified-shape
title: "Entry-vs-local-match examples should use a no-regex top dispatcher into an ordered child rule; later child slots read match_* while entry_* still reads the entering slot"
answers:
  - "how do I write a verified entry_text vs match_text divergence example"
  - "how do I demonstrate entry_* and match_* reading different spans"
  - "why should entry-vs-match docs use an ordered child rule"
  - "what shape verifies entry_named(head) and match_named(value) divergence"
  - "what is the working entry/match helper catalog example"
date: 2026-07-08
status: confirmed
tags: [spec-language, mdbook, helpers, entry-match, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.5.5 probes found that the durable, verified teaching shape is a no-regex top dispatcher (`Top:: -> Name .push`) plus an ordered child (`Name:AND`) whose first slot enters the rule and whose final slot returns. On input `name=Alpha`, `entry_text()` / `entry_named(head)` read `name` while `match_text()` / `match_named(value)` read `Alpha`. The helper catalog and source-boundary pages were updated to this shape."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $J=JSON::PP->new->canonical(1)->allow_nonref(1); my $s=q{Top::\n -> Name .push\n LX { return(copy(array(Top))) }\n\nName:AND\n /(?<head>name)/\n /\\s*=\\s*/\n /(?<value>[A-Za-z_]+)/\n -> Name[1] { eq = match_text(); }\n -> Name[2] { return(hash(\"entry_text\", entry_text(), \"entry_named\", entry_named(head), \"local_text\", match_text(), \"local_named\", match_named(value), \"separator\", trim(eq))) }\n}; my $p=LinkedSpec::Get(\\$s, top_rule=>\"Top\", parse_mode=>\"consume\"); my $in=\"name=Alpha\"; print $J->encode($p->(\\$in)),\"\\n\";'"
---

# Entry/Match Divergence Verified Shape

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.5.5`).** The reliable public example for
`entry_*` versus `match_*` divergence is:

```text
Top::
 -> Name .push
 LX { return(copy(array(Top))) }

Name:AND
 /(?<head>name)/
 /\s*=\s*/
 /(?<value>[A-Za-z_]+)/
 -> Name[1] { eq = match_text(); }
 -> Name[2] {
   return(hash(
     "entry_text", entry_text(),
     "entry_named", entry_named(head),
     "local_text", match_text(),
     "local_named", match_named(value),
     "separator", trim(eq)
   ))
 }
```

Input `name=Alpha` returns a single hash in the top accumulator. `entry_text()` and
`entry_named(head)` read the first slot that entered the `Name` rule (`name`).
`match_text()` and `match_named(value)` read the later local slot whose action is
currently running (`Alpha`).

Use this ordered-child shape in docs when teaching the helper-family split. It avoids
depending on an ambiguous parent action that both dispatches a child and calls the child
again.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.5.5`)
- Public contract: `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`
- Related pages: `docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md`,
  `docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md`
