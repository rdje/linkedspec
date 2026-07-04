---
id: terse-merge-hash-bare-overlay-boundary
title: "merge_hash supports a bare later hash argument, but the first argument still needs an explicit hash-valued expression."
answers:
  - "can merge_hash(base, overlay) use bare hash working variables"
  - "why does merge_hash(base, overlay) return empty"
  - "what is the canonical terse merge_hash bare overlay spelling"
  - "does merge_hash accept bare overlay as a hash snapshot"
  - "how should I replace merge_hash(hash_copy(base), overlay)"
date: 2026-07-04
status: confirmed
tags: [dsl, hash, helper, spec-format-terse, oracle, mdbook]
evidence: "During SPEC-FORMAT-TERSE.6.3, regenerating the oracle corpus after changing `merge_hash(hash_copy(base), overlay)` to `merge_hash(base, overlay)` changed the Perl reference expected value for `terse_2_3_4_1_bare_hash_helper_arg_composition` from `2` to `0`. Direct probes showed `merge_hash(hash_copy(base), overlay)`, `merge_hash(copy(hash(base)), overlay)`, and `merge_hash(hash(base), overlay)` return `2`, while `merge_hash(base, overlay)` returns `0`."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'for my $expr (q{merge_hash(hash_copy(base), overlay)}, q{merge_hash(base, overlay)}, q{merge_hash(copy(hash(base)), overlay)}, q{merge_hash(hash(base), overlay)}) { my $spec = qq{Top::\\n /x/ -> Done { set_key(base, \"b\", 2); set_key(base, \"a\", 1); set_key(overlay, \"c\", 3); return(count(drop_front(sorted_keys($expr)))) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p = LinkedSpec::Get(\\$spec); my $in = q{xhello}; my $r = $p->(\\$in); print \"$expr => \", JSON::PP->new->canonical->encode($r), \"\\n\"; }'"
---

# `merge_hash` bare overlay boundary

The current portable spelling for the bare-overlay fixture is:

```text
merge_hash(copy(hash(base)), overlay)
```

The first argument is an explicit hash-valued expression. The later `overlay` argument is the bare
working-hash snapshot locked by `SPEC-FORMAT-TERSE.2.3.4.1`.

Do not document or author `merge_hash(base, overlay)` as equivalent today; on the Perl reference it
returns the wrong value for the existing oracle probe.
