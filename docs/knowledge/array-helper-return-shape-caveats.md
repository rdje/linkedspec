---
id: array-helper-return-shape-caveats
title: "Array helper return-shape caveats: compact I.return(split(...)) and direct pipeline returns are shape-sensitive on current Perl."
answers:
  - "why does I.return(split(...)) produce ?value"
  - "should split examples use I.return(split(...))"
  - "can I return split_each(array(items), \":\") directly"
  - "how should array pipeline helper examples return arrays"
  - "does items.uniq().sorted() work"
  - "what does push Child return in value position"
  - "is implicit child push result portable"
date: 2026-07-08
status: current
tags: [array-helpers, mdbook, perl-reference, receiver-chains, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.5.3 probes for helper-contract-catalog.md showed shape-sensitive Perl behavior. `I.return(split(entry_group(0), \",\"))` over `a,b,c` returns `[[\"?value:\",[\"a\",\"b\",\"c\"]]]`, while block form `I { return(split(entry_group(0), \",\")) }` and receiver form `I.return(entry_group(0).split(\",\"))` both return `[[\"a\",\"b\",\"c\"]]`. `call_spec_handler_subst(\"value\", q{return(split(entry_group(0), \",\"))})` lowers to a plain array-ref return, so the tagged result is specific to compact lifecycle shorthand. Array pipeline helpers over named arrays are reliable as receiver returns (`items.trim_each()`), assignment values (`set(out, split_each(array(items), \":\"))`), or mutation-plus-copy (`split_each(array(items), \":\"); return(copy(array(items)))`). Direct `return(split_each(array(items), \":\"))` returns `[4]` in the standard demo wrapper, not the array. Verified receiver chains include `items.sorted().drop_front(1).first()`, `items.uniq().join_values(\"|\")`, `items.filter_match(/^a/).join_values(\"|\")`, and `phrases.split_each(\"-\").filter_match(/^aa$/).count()`. The portable contract does not promise every pipeline-to-pure continuation: `items.uniq().sorted().join_values(\"|\")` returns `[null]` in the same probe."
evidence_update_2026_07_12_implicit_child_push_result: "LUA-BACKEND-PARITY.4.3.4.6 used LinkedSpec::Get plus call_spec_handler_subst on an action-edge child. Value-position Perl push(Child) lowers to the host push on the implicit array and returns count 1; Lua append_array_binding returns the updated implicit accumulator. Perl and Lua explicit-target push(Child, out) both return the updated out array under uniform binding. FUTURE-PARITY-BACKLOG.5 now owns normalization; current portable guidance uses implicit child push only as a statement."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); my @cases=([compact=>q{I.return( split(entry_group(0), \",\") )},q{a,b,c}],[block=>q{I { return(split(entry_group(0), \",\")) }},q{a,b,c}],[receiver=>q{I.return( entry_group(0).split(\",\") )},q{a,b,c}]); for my $c (@cases) { my ($name,$body,$input)=@$c; my $spec=qq{demo::\\n -> value .push\\n LX { return(copy(array(demo))) }\\n\\nvalue : /(.+)/\\n $body\\n}; my $p=LinkedSpec::Get(\\$spec, top_rule=>\"demo\", parse_mode=>\"consume\"); my $in=$input; print qq{$name => }. $json->encode($p->(\\$in)).qq{\\n}; } my @pipe=([direct=>q{set(array(items), [\"a:b\", \"c:d\"]); return(split_each(array(items), \":\"))}],[receiver=>q{set(array(items), [\"a:b\", \"c:d\"]); return(items.split_each(\":\"))}],[chain=>q{set(array(phrases), [\"aa-b\", \"cc-aa\"]); return(phrases.split_each(\"-\").filter_match(/^aa$/).count())}],[bad_chain=>q{set(array(items), [\"b\", \"a\", \"b\", \"c\"]); return(items.uniq().sorted().join_values(\"|\"))}]); for my $p (@pipe) { my ($name,$body)=@$p; my $spec=qq{demo::\\n -> value .push\\n LX { return(copy(array(demo))) }\\n\\nvalue : /x/\\n I { $body }\\n}; my $parser=LinkedSpec::Get(\\$spec, top_rule=>\"demo\", parse_mode=>\"consume\"); my $in=q{x}; print qq{$name => }. $json->encode($parser->(\\$in)).qq{\\n}; }'"
---

Use block `return(split(...))` or receiver `.split(...)` in runnable examples. For array
pipeline helpers, prefer receiver returns (`items.trim_each()`), assignment values, or
mutation-plus-copy from a named working array. Do not document direct
`return(split_each(array(items), ...))` as the portable array-returning form on current Perl.

Implicit child push is another explicit caveat: use `push(Child)` and `push(Child, index)` as statements. Their
side effects are portable, but their expression values are not—Perl currently exposes the host array length and
Lua exposes the updated implicit accumulator. Explicit-target child push returns the updated target. Backlog `.5`
owns the cross-backend result decision.
