---
id: terse-merge-hash-bare-overlay-boundary
title: "merge_hash accepts bare typed harray bindings in both base and overlay positions"
answers:
  - "can merge_hash(base, overlay) use bare hash working variables"
  - "does merge_hash accept a bare first harray argument"
  - "what is the canonical terse merge_hash bare overlay spelling"
  - "does merge_hash accept bare overlay as a hash snapshot"
  - "how should I replace merge_hash(hash_copy(base), overlay)"
  - "why is copy hash base obsolete merge guidance"
  - "is hash base accepted after aggregate selector retirement"
date: 2026-07-13
status: confirmed
tags: [dsl, hash, helper, spec-format-terse, oracle, mdbook]
evidence: "LUA-BACKEND-PARITY.4.3.5.3.0 revalidated the contract after FUTURE-PARITY-BACKLOG.12.1 uniform binding and selector retirement superseded the 2026-07-04 boundary. Current Perl returns `2` for both `merge_hash(base, overlay)` and `merge_hash(copy(base), overlay)`, and lowers the bare form to `{%base, %overlay}`. Exact `hash(base)` now rejects with `aggregate_selector_removed`. The checked-in neutral corpus already uses bare-first merge with expected `2`; its selected case passes Dart and Julia, and the full Rust oracle passes all 105 fixtures."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'for my $expr (q{merge_hash(base, overlay)}, q{merge_hash(copy(base), overlay)}) { my $spec = qq{Top::\\n /x/ -> Done { set_key(base, \"b\", 2); set_key(base, \"a\", 1); set_key(overlay, \"c\", 3); return(count(drop_front(sorted_keys($expr)))) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p = LinkedSpec::Get(\\$spec); my $in = q{xhello}; my $r = $p->(\\$in); die \"$expr drifted\\n\" unless $r == 2; }' && cd dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case terse_2_3_4_deep_pure_helper_composition && cd .. && bash tools/run_julia_project_data.sh --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case terse_2_3_4_deep_pure_helper_composition && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# `merge_hash` bare typed-binding contract

The canonical current spelling is:

```text
merge_hash(base, overlay)
```

Both names are evaluated as their bound harray values. `merge_hash(copy(base), overlay)` is equivalent when an
explicit base snapshot makes the intent clearer; all transform forms remain pure and already copy their inputs.
Later arguments override earlier keys.

The former `copy(hash(base))` guidance is obsolete. Exact `hash(base)` is a removed aggregate-selector shape and
must be rejected before execution. This card originally recorded a real July 4 boundary, but July 12 uniform
binding plus selector retirement superseded it across the admitted runtimes.
