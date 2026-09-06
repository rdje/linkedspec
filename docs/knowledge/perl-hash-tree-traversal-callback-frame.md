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
reverify: "perl -0777 -ne 'print $1 if /^```bash\\n(.*?)^```/ms' docs/knowledge/perl-hash-tree-traversal-callback-frame.md | bash"
---

# Perl Hash-Tree Traversal Callback Frame

`SPEC-FORMAT-TERSE.12.2` is the Perl reference implementation for receiver attached-block traversal:

- `hash_value.walk_leaves() { ... }`
- `hash_value.map_leaves() { ... }`
- `hash_value.reduce_leaves(initial) { ... }`

The lowering lives in `perl/LinkedSpec/ActionIR/MethodLowering.pm` inside the hash-receiver chain path. It builds
immediate recursive traversal closures over hash-root/hash-interior values, iterating each hash's keys with `sort
keys`. Within a hash-root traversal, arrays are leaves. The original `.12.2` non-hash rejection
boundary was extended by `.13.2`: array roots now recurse through arrays, treating hashes as leaves; scalar
receivers still return `undef` without callbacks. See [[perl-array-tree-traversal-callback-frame]] and
[[array-tree-traversal-contract]] for the current shared runtime dispatch.

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

The September 6 `.3.2.26` reading checkpoint reverified the root distinction through public Get.
Hash-root mapping visits its array child once; array-root mapping visits its hash child once. A scalar
receiver returns null with its callback side-effect flag still zero. The AST parser suite passes 23 tests.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical->allow_nonref;
for my $case (
 ['hash_root','meta = {"b":{"y":"B"},"a":"A","arr":["u","v"]}; return(meta.map_leaves() { return(depth) })',{a=>1,arr=>1,b=>{y=>2}}],
 ['array_root','items = [["a"],{"k":"v"},"z"]; return(items.map_leaves() { return(depth) })',[[2],1,1]],
 ['scalar_root','seen = 0; item = "x"; mapped = item.map_leaves() { seen = 1; return(value) }; return([mapped,seen])',[undef,0]]
){
 my $spec="Top::\n /x/ -> Top { $case->[1] }\n";my %ctx;
 my $parser=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx);die "$case->[0] compile" unless ref($parser) eq 'CODE';
 my $input='x';my $got=$parser->(\$input);
 print $json->encode({case=>$case->[0],result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 die "$case->[0] contract mismatch" unless $json->encode($got) eq $json->encode($case->[2]) && !defined($ctx{last_error});
}
PERL
```
