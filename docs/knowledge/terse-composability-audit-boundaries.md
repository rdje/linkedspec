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
evidence: "SPEC-FORMAT-TERSE.2.3.4 audit on 2026-06-30 showed pure value-helper composition lowers cleanly with explicit aggregate wrappers: `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))` returns 2 with ActionIR ready metadata, and `terse_2_3_4_deep_pure_helper_composition` locked that boundary. The same audit found Rust returned 1 for `merge_hash(hash_copy(base), overlay)` because bare `overlay` was evaluated as a scalar before `merge_hash` saw evaluated hash args. SPEC-FORMAT-TERSE.2.3.4.1 fixed that Rust parity gap by snapshotting bare working variables only in hash-consuming and array-consuming helper slots; `terse_2_3_4_1_bare_hash_helper_arg_composition` and `terse_2_3_4_1_bare_array_helper_arg_composition` now pass. SPEC-FORMAT-TERSE.2.3.4.2 fixed the Perl inline value-control gap: `return(if(...))`, assignment RHS `if(...)`, `return(switch(...))`, assignment RHS `switch(...)`, and fluent `.return(if(...))` / `.return(switch(...))` now return the selected branch payload on the Perl reference, including nested helper predicates/branches and expression-valued block branches. The new `terse_2_3_4_2_inline_if_value_control` and `terse_2_3_4_2_inline_switch_value_control` oracle fixtures pass, and Rust corpus_oracle passes with 46 fixtures. The portable assertion is the selected payload value, not any mandatory `?...:` tag string. Receiver-dot array mutations remain statement-only and are tracked separately by SPEC-FORMAT-TERSE.2.3.5."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $json=JSON::PP->new->canonical(1)->allow_nonref(1); for my $expr (q{return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay)))))}, q{return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay))))))}, q{return(count(drop_front(sorted(items))))}, q{return(if(1, \"yes\", else(\"no\")))}, q{return(switch(\"a\", case(\"a\", \"yes\"), default(\"no\")))}) { print \"$expr => \", LinkedSpec::call_spec_handler_subst(\"Top\", $expr), \"\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
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
count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))
count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay))))
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

- `.2.3.5`: value-returning/chained receiver-dot methods. Existing array end methods are statement-only.
