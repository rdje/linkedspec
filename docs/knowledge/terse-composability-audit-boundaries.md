---
id: terse-composability-audit-boundaries
title: SPEC-FORMAT-TERSE.2.3.4 composability audit boundaries
answers:
  - "is full Lisp style composability portable today"
  - "do all helpers support unlimited nested composition"
  - "does Rust support merge_hash hash_copy base overlay"
  - "why does merge_hash(hash_copy(base), overlay) return 1 on Rust"
  - "does Rust read bare hash variables in merge_hash arguments"
  - "does Perl return(if(...)) return the selected branch"
  - "are inline value if and switch portable"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.4"
date: 2026-06-30
status: current
tags: [spec-format-terse, composability, rust, perl, mdbook, oracle]
evidence: "SPEC-FORMAT-TERSE.2.3.4 audit on 2026-06-30. TOOLBOX Perl probes showed pure value-helper composition lowers cleanly with explicit aggregate wrappers: `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))` returns 2 with ActionIR ready metadata. The new oracle fixture `terse_2_3_4_deep_pure_helper_composition` locks that portable subset, and Rust corpus_oracle passes with 42 fixtures. A diagnostic fixture using the book-shaped bare hash argument `merge_hash(hash_copy(base), overlay)` returned Perl 2 but Rust 1 because Rust evaluates bare `overlay` as a scalar before `merge_hash` sees only evaluated `RuntimeValue::Hash` arguments. Generated-source probes for Perl inline value controls showed `return(if(1, \"yes\", else(\"no\")))` lowers to a `do { if (...) { ... } }` shape that returns undef, and `return(switch(...))` similarly does not reliably return the selected branch value; nested predicate/branch helper forms can fail handler compilation. Receiver-dot array mutations remain statement-only and are tracked separately by SPEC-FORMAT-TERSE.2.3.5."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); for my $expr (q{return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay)))))}, q{return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay))))))}, q{return(if(1, \"yes\", else(\"no\")))}, q{return(switch(\"a\", case(\"a\", \"yes\"), default(\"no\")))}) { print \"$expr => \", LinkedSpec::call_spec_handler_subst(\"Top\", $expr), \"\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.4` is a completed audit/split leaf, not an implementation leaf.

Accepted today:

- Pure value-helper nesting is portable when helper argument kinds are explicit enough for both backends.
- The green oracle form is:

```text
count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))
```

Split before code:

- `.2.3.4.1`: Rust helper-context aggregate bare reads. The Perl reference accepts
  `merge_hash(hash_copy(base), overlay)` as a hash merge, but Rust currently reads bare `overlay` as a scalar
  before `merge_hash` sees evaluated arguments.
- `.2.3.4.2`: Perl inline-composite value control lowering. Rust already has lazy value `if`/`switch`; Perl
  generated handlers do not reliably return selected branch values in value positions today.

Still separate:

- `.2.3.5`: value-returning/chained receiver-dot methods. Existing array end methods are statement-only.
