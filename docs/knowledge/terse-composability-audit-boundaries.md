---
id: terse-composability-audit-boundaries
title: SPEC-FORMAT-TERSE.2.3.4/.2.3.4.1 composability boundaries
answers:
  - "is full Lisp style composability portable today"
  - "do all helpers support unlimited nested composition"
  - "does Rust support merge_hash hash_copy base overlay"
  - "why does merge_hash(hash_copy(base), overlay) return 1 on Rust"
  - "does Rust read bare hash variables in merge_hash arguments"
  - "does Rust read bare array variables in sorted arguments"
  - "does sorted(items) read a bare array working variable"
  - "does Perl return(if(...)) return the selected branch"
  - "are inline value if and switch portable"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.4"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.4.1"
date: 2026-06-30
status: current
tags: [spec-format-terse, composability, rust, perl, mdbook, oracle]
evidence: "SPEC-FORMAT-TERSE.2.3.4 audit on 2026-06-30 showed pure value-helper composition lowers cleanly with explicit aggregate wrappers: `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))` returns 2 with ActionIR ready metadata, and `terse_2_3_4_deep_pure_helper_composition` locked that boundary. The same audit found Rust returned 1 for `merge_hash(hash_copy(base), overlay)` because bare `overlay` was evaluated as a scalar before `merge_hash` saw evaluated hash args. SPEC-FORMAT-TERSE.2.3.4.1 fixed that Rust parity gap by snapshotting bare working variables only in hash-consuming and array-consuming helper slots; `terse_2_3_4_1_bare_hash_helper_arg_composition` and `terse_2_3_4_1_bare_array_helper_arg_composition` now pass and Rust corpus_oracle passes with 44 fixtures. Generated-source probes for Perl inline value controls still show `return(if(1, \"yes\", else(\"no\")))` lowers to a `do { if (...) { ... } }` shape that returns undef, and `return(switch(...))` similarly does not reliably return the selected branch value; nested predicate/branch helper forms can fail handler compilation. Receiver-dot array mutations remain statement-only and are tracked separately by SPEC-FORMAT-TERSE.2.3.5."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); for my $expr (q{return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay)))))}, q{return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay))))))}, q{return(count(drop_front(sorted(items))))}, q{return(if(1, \"yes\", else(\"no\")))}, q{return(switch(\"a\", case(\"a\", \"yes\"), default(\"no\")))}) { print \"$expr => \", LinkedSpec::call_spec_handler_subst(\"Top\", $expr), \"\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.4` is a completed audit/split leaf. `SPEC-FORMAT-TERSE.2.3.4.1` is the follow-up Rust
implementation leaf that closed the bare aggregate helper-argument parity gap.

Accepted today:

- Pure value-helper nesting is portable when helper argument kinds are explicit enough for both backends.
- Hash-consuming and array-consuming helper argument slots now accept bare working variables as snapshots on
  Perl and Rust.
- The green oracle forms are:

```text
count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))
count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay))))
count(drop_front(sorted(items)))
```

Closed and remaining splits:

- `.2.3.4.1`: done. Rust helper-context bare aggregate arguments are implemented for hash-consuming and
  array-consuming helper slots.
- `.2.3.4.2`: pending. Perl inline-composite value control lowering still needs to make selected branch values
  return in value positions. Rust already has lazy value `if`/`switch`; Perl generated handlers do not
  reliably return selected branch values in value positions today.

Still separate:

- `.2.3.5`: value-returning/chained receiver-dot methods. Existing array end methods are statement-only.
