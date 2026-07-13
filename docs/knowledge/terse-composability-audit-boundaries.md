---
id: terse-composability-audit-boundaries
title: SPEC-FORMAT-TERSE.2.3.4/.2.3.4.1/.2.3.4.2 composability boundaries
answers:
  - "is full Lisp style composability portable today"
  - "do all helpers support unlimited nested composition"
  - "does Rust support merge_hash hash_copy base overlay"
  - "why does merge_hash(hash_copy(base), overlay) return 1 on Rust"
  - "does Rust read bare hash variables in merge_hash arguments"
  - "does Rust read bare array variables in sorted arguments"
  - "does sorted(items) read a bare array working variable"
  - "does Perl return(if(...)) return the selected branch"
  - "does Perl return(switch(...)) return the selected branch"
  - "are inline value if and switch portable"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.4"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.4.1"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.3.4.2"
date: 2026-06-30
status: current
tags: [spec-format-terse, composability, rust, perl, mdbook, oracle]
evidence: "SPEC-FORMAT-TERSE.2.3.4/.1/.2 establish pure aggregate composition and inline value-control boundaries. The original audit routed then-statement-only array-end methods separately. FUTURE-PARITY-BACKLOG.12.1.1-.6 later supersede that result boundary with updated arrays and compatible continuation across all five backends."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); for my $expr (q{return(count(drop_front(sorted_keys(merge_hash(copy(hash(base)), overlay)))))}, q{return(count(drop_front(sorted_keys(merge_hash(copy(hash(base)), hash(overlay))))))}, q{return(count(drop_front(sorted(items))))}, q{return(if(1, \"yes\", else(\"no\")))}, q{return(switch(\"a\", case(\"a\", \"yes\"), default(\"no\")))}) { print \"$expr => \", LinkedSpec::call_spec_handler_subst(\"Top\", $expr), \"\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.4` is a completed audit/split leaf. `SPEC-FORMAT-TERSE.2.3.4.1` is the follow-up Rust
implementation leaf that closed the bare aggregate helper-argument parity gap. `SPEC-FORMAT-TERSE.2.3.4.2`
is the follow-up Perl reference leaf that closed inline value-control lowering.

Accepted today:

- Pure value-helper nesting is portable when helper argument kinds are explicit enough for both backends.
- Hash-consuming and array-consuming helper argument slots now accept bare working variables as snapshots on
  Perl and Rust.
- Inline-composite `if(...)` and `switch(...)` are portable lazy value expressions in supported value positions:
  `return(...)`, assignment RHS, and fluent `.return(...)`.
- The green oracle forms are:

```text
count(drop_front(sorted_keys(merge_hash(copy(hash(base)), hash(overlay)))))
count(drop_front(sorted_keys(merge_hash(copy(hash(base)), overlay))))
count(drop_front(sorted(items)))
if(is_nonempty(flag), cat("y", "es"), else("no"))
switch(kind, case("a", "bad"), case("b", cat("y", "es")), default("no"))
```

Closed and remaining splits:

- `.2.3.4.1`: done. Rust helper-context bare aggregate arguments are implemented for hash-consuming and
  array-consuming helper slots.
- `.2.3.4.2`: done. Perl inline-composite value-control lowering now returns selected branch payloads in
  supported value positions. Tests/oracles assert payload values; incidental compatibility tag strings are not
  part of this feature's contract.

Still separate:

- `.2.3.5`: value-returning/chained receiver-dot methods. Its original statement-only array-end boundary was later
  superseded by uniform binding; see [[uniform-binding-array-end-result-supersession]].
