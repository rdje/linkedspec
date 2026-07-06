---
id: terse-string-method-surface-verified
title: SPEC-FORMAT-TERSE.7.2 string/scalar method surface verified
answers:
  - "does string substr need implementation"
  - "is substr already a receiver method on string scalars"
  - "what did SPEC-FORMAT-TERSE.7.2 verify"
  - "which string receiver methods are implemented"
  - "is regex substitution substr a receiver method"
  - "which task follows SPEC-FORMAT-TERSE.7.2"
date: 2026-07-06
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, string, substr, rust-parity]
evidence: "SPEC-FORMAT-TERSE.7.2 verified that the useful pure string/scalar receiver surface from .7.1 is already implemented on Perl and Rust, with no parser/runtime code change. Perl runtime probe returned [\"BCD\",\"BCD\",2] for receiver substr, helper substr, and split bridge evidence, and descriptor metadata was ready=1, fallback=0, raw=0, unresolved=0. Focused Rust `terse_2_3_5_3` tests pass. Existing mdBook docs already demonstrate `\"abcdef\".substr(1, 3).uppercase()` mapping to `uppercase(substr(\"abcdef\", 1, 3))`. After SPEC-FORMAT-TERSE.15.3/.15.4 retired colon scalar slots, statement regex substitution uses a bare target such as `substr(target, pattern, replacement, flags)`; it remains a mutation form, not a pure receiver method."
reverify: "perl -Iperl -MData::Dumper -MLinkedSpec -e 'my $spec = q{Top::\n /x/ -> Done { return(array(\"abcdef\".substr(1, 3).uppercase(), uppercase(substr(\"abcdef\", 1, 3)), \" a-b \".trim().split(\"-\").count())) }\n\nDone::\n /x/\n}; my $p = LinkedSpec::Get(\\$spec); my $input = \"x\"; print Dumper($p->(\\$input));' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_3_5_3 --quiet"
---

`SPEC-FORMAT-TERSE.7.2` closed the string/scalar method backfill leaf as already satisfied.

Pure string/scalar receiver methods already include:

- string-returning links: `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`,
  `concat`/`cat`, and `coalesce_nonempty`
- array bridge: `split(delim)`
- terminal links: `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches`

The focused Perl probe proves helper-form and method-form `substr` equivalence:

```text
"abcdef".substr(1, 3).uppercase()  -> "BCD"
uppercase(substr("abcdef", 1, 3))  -> "BCD"
" a-b ".trim().split("-").count()  -> 2
```

Descriptor metadata for that probe stays language-agnostic ready with zero fallback, raw, and unresolved-helper
counts. Focused Rust `terse_2_3_5_3` tests pass.

The regex-substitution form `substr(target, pattern, replacement, flags)` remains an explicit statement mutation,
not a pure string receiver method. The old colon-target spelling is retired with the rest of `:name`.

The next leaf is `SPEC-FORMAT-TERSE.7.3` for array/list, hash, and number receiver backfill audit.
