---
id: hash-literal-dynamic-key-contract
title: "Direct hash literals use evaluated key expressions; quote fixed field names."
answers:
  - "does direct hash literal syntax support dynamic keys"
  - "are bare hash literal keys fixed strings"
  - "how do I write a fixed field name in a direct hash literal"
  - "can a computed helper call be a hash literal key"
  - "what did SPEC-FORMAT-TERSE.10 decide"
  - "does SPEC-FORMAT-TERSE.10 require new parser behavior"
date: 2026-07-08
status: current
tags: [spec-format-terse, hash-literal, dynamic-key, perl, rust, mdbook, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.10.1 ratified existing behavior from the colon hash-literal and bare-read work instead of adding new parser/runtime code. Direct hash literals use `{ key_expr : value_expr }`; the key expression is evaluated and stringified at runtime. A bare key such as `{ key : value }` reads scalar `key`, so fixed object fields must be quoted as `{ \"kind\" : value }`. Computed helper expressions such as `{ cat(prefix,suffix) : value }` are valid keys. Perl lowering probes produce `$key => $value` and computed `cat(...) => $value`; a direct runtime probe returns dynamic `stage` keys. Rust parses hash-literal keys with `parse_expr()` before the top-level `:` and evaluates them with `to_str()`."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $stmt (q{set(key,\"stage\"); set(value,\"ok\"); return({ key : value })}, q{set(prefix,\"sta\"); set(suffix,\"ge\"); set(value,\"ok\"); return({ cat(prefix,suffix) : value, \"fixed\" : key })}, q{return({ \"key\" : value })}) { print \"STMT: $stmt\\n\"; print LinkedSpec::call_spec_handler_subst(\"Top\", $stmt), \"\\n---\\n\" } my $spec=qq{Top::\\n /x/ -> Done { set(key,\"stage\"); set(value,\"ok\"); set(prefix,\"sta\"); set(suffix,\"ge\"); return(array({ key : value }, { cat(prefix,suffix) : value, \"fixed\" : key }, { \"key\" : value })) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p=LinkedSpec::Get(\\$spec); my $in=\"xhello\"; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), \"\\n\";' && rg -n 'parse_hash_literal|Expr::HashLiteral|to_str\\(\\)' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

# Hash-Literal Dynamic Key Contract

`SPEC-FORMAT-TERSE.10.1` closed the dynamic/computed direct hash-literal key question without changing engine
behavior.

The current contract is:

```text
{ key_expr : value_expr }
```

The key side is an evaluated value expression. A bare name reads the scalar value of that name:

```text
set(key, "stage");
set(value, "ok");
return({ key : value });       # {"stage": "ok"}
```

Computed helper expressions are accepted as keys:

```text
set(prefix, "sta");
set(suffix, "ge");
return({ cat(prefix, suffix) : value });
```

Quote fixed field names:

```text
return({ "kind" : "token" });
```

Old direct hash-literal fat arrows remain retired; use `:` in current `.spec` source.
