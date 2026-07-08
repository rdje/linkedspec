---
id: perl-hash-tree-traversal-callback-frame
title: "SPEC-FORMAT-TERSE.12.2 - Perl hash-tree traversal receiver blocks bind scalar callbacks with aggregate mirrors."
answers:
  - "where does Perl lower map_leaves walk_leaves reduce_leaves receiver blocks"
  - "why does hash tree callback binding create array value and hash value lexicals"
  - "how do array(value) and hash(value) work inside map_leaves callback blocks on Perl"
  - "what variables are scoped inside Perl hash tree traversal callbacks"
  - "does map_leaves traverse Perl hashes in sorted key order"
  - "are arrays traversed recursively by Perl map_leaves"
  - "why did non hash scalar receiver need to avoid hash(name) coercion for map_leaves"
  - "what helper handles SPEC-FORMAT-TERSE.12.2 Perl traversal lowering"
date: 2026-07-08
status: current
tags: [spec-format-terse, hash-tree, trailing-block, method-lowering, perl, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.12.2 adds receiver trailing-block parsing in perl/LinkedSpec/ActionIR/AST/Parser.pm and hash-tree receiver lowering in perl/LinkedSpec/ActionIR/MethodLowering.pm. The phase0 subtest spec_format_terse_12_2_perl_hash_tree_traversal_receiver_blocks locks sorted traversal, array leaves, non-hash undef behavior, scoped callback restoration, and generated-source residue."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $spec=qq{Top::\\n /x/ -> Done { meta = { \"b\" : { \"y\" : \"B\" }, \"a\" : \"A\", \"arr\" : [\"u\",\"v\"] }; return(array(meta.map_leaves() { return(cat(join_values(\"/\", array(path)), \"=\", if(count(array(value)), join_values(\"\", array(value)), else(value)))) }, meta.reduce_leaves(\"\") { return(cat(acc, key)) }, meta.walk_leaves() { seen += join_values(\"/\", array(path)); return(value) }.count_keys(), array(seen))) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p=LinkedSpec::Get(\\$spec); my $in=\"xhello\"; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), \"\\n\";'"
---

# Perl Hash-Tree Traversal Callback Frame

`SPEC-FORMAT-TERSE.12.2` is the Perl reference implementation for receiver attached-block traversal:

- `hash_value.walk_leaves() { ... }`
- `hash_value.map_leaves() { ... }`
- `hash_value.reduce_leaves(initial) { ... }`

The lowering lives in `perl/LinkedSpec/ActionIR/MethodLowering.pm` inside the hash-receiver chain path. It builds
immediate recursive traversal closures over hash-root/hash-interior values, iterating each hash's keys with `sort
keys`. Arrays are leaves, not traversal nodes. Non-hash receivers return `undef` without running callbacks.

Each callback block gets scoped lexical bindings for the portable `.12` variables:

- `value`
- `key`
- `path`
- `depth`
- `acc` for `reduce_leaves` only

Perl's current block lowerer can resolve `array(value)` and `hash(value)` through aggregate lexicals, not only the
scalar slot. For that reason the generated callback frame also mirrors aggregate views (`@value`, `%value`, `@path`,
`@acc`, `%acc`) from the scalar runtime values. This is a Perl-lowering compatibility detail; the `.spec` contract
still exposes scalar callback names whose runtime values may be arrays or hashes.

One important guard: scalar-held hash receivers for these methods must not be coerced through `hash(name)`.
Otherwise a non-hash scalar receiver such as `thing = "x"; thing.map_leaves() { ... }` would look like an empty
hash and fail to return `undef`.
