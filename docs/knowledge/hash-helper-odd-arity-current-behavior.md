---
id: hash-helper-odd-arity-current-behavior
title: "Hash helper odd-arity direct constructor calls return undef on current Perl; spell trailing null values explicitly."
answers:
  - "why does hash(\"a\", 1, \"missing\") return null"
  - "does hash helper fill an odd final key with undef"
  - "how should I write a hash key with an undef value"
  - "is hash(\"a\", 1, \"missing\") portable"
  - "what is the verified hash helper odd arity behavior"
date: 2026-07-08
status: current
tags: [spec-lang-reference, hash-helper, helper-contract-catalog, perl-reference]
evidence: "SPEC-LANG-REFERENCE.5.4 probes for helper-contract-catalog.md found that direct odd-arity hash constructor calls are not the portable trailing-undef spelling on the current Perl reference. `call_spec_handler_subst(\"value\", q{return(hash(\"a\", 1, \"missing\"))})` lowers to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash` and the standard two-rule demo wrapper returns `[null]`. Explicit paired arguments work: `hash(\"a\", 1, \"missing\", undef)` returns `[{\"a\":1,\"missing\":null}]`. A list-context splice also currently produces the trailing undef value: `hash(flat_array(array(\"a\", 1, \"missing\")))` returns `[{\"a\":1,\"missing\":null}]`. The helper catalog now documents paired direct arguments plus explicit `undef` for null-valued trailing keys."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $J=JSON::PP->new->canonical(1)->allow_nonref(1); for my $stmt (q{return(hash(\"a\", 1, \"missing\"))}, q{return(hash(\"a\", 1, \"missing\", undef))}, q{return(hash(flat_array(array(\"a\", 1, \"missing\"))))}) { my $lower=LinkedSpec::call_spec_handler_subst(\"value\", $stmt); $lower =~ s/\\n/\\\\n/g; print \"$stmt => $lower\\n\"; my $spec=qq{demo::\\n -> value .push\\n LX { return(copy(array(demo))) }\\n\\nvalue : /x/\\n I { $stmt }\\n}; my $p=LinkedSpec::Get(\\$spec, top_rule=>\"demo\", parse_mode=>\"consume\"); my $in=\"x\"; print \"run=\", $J->encode($p->(\\$in)), \"\\n\"; }'"
---

Use paired direct arguments for `hash(...)` constructor calls. When a key should intentionally have an undefined
value, spell that value explicitly:

```text
hash("a", 1, "missing", undef)
```

Do not rely on `hash("a", 1, "missing")` as the portable spelling. On the current Perl reference that direct
odd-arity call is treated as an unsupported helper shape and returns `undef`.
