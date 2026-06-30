---
id: terse-return-type-method-chaining-split
title: SPEC-FORMAT-TERSE.2.3.5 return-type method chaining split
answers:
  - "how is return-type method chaining split"
  - "does LinkedSpec support value-returning receiver-dot methods"
  - "are receiver-dot array mutations value returning"
  - "does return(items.pop_back()) work"
  - "does items.push_back(\"a\").push_back(\"b\") work"
  - "what is the next task after SPEC-FORMAT-TERSE.2.3.5"
  - "which leaf owns array receiver-dot value chains"
date: 2026-07-01
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, array, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5 completed the design/split before code. Perl TOOLBOX probes show statement-only receiver-dot array mutations lower today (`items.push_back(\"a\")` -> `push @items, \"a\"`, `items.pop_back()` -> `pop @items`), while value-position/chained receiver forms are not implemented (`return(items.pop_back())` remains raw, `set(out, items.push_back(\"a\"))` remains raw, and `items.push_back(\"a\").push_back(\"b\")` remains raw). Runtime probes compile the statement form and return [\"a\"], but value/chained forms hit undefined generated helper calls and return null. Rust source read shows `Expr::FluentChain` parsing exists, `execute_array_end_mutation_method_statement` handles only single-call statement mutations, and generic `eval_expr` for a fluent chain returns `undef`. The accepted future model is receiver-as-first-argument value chaining split by return family: `.2.3.5.1` array, `.2.3.5.2` hash, `.2.3.5.3` string, `.2.3.5.4` number. Existing `.1.6` mutating `push_back`/`push_front`/`pop_back`/`pop_front` behavior remains statement-only until an array child explicitly designs any destructive value-returning variant."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $s (q{items.push_back(\"a\")}, q{items.pop_back()}, q{return(items.pop_back())}, q{set(out, items.push_back(\"a\"))}, q{items.push_back(\"a\").push_back(\"b\")}, q{return(sorted(items))}) { my $out = eval { LinkedSpec::call_spec_handler_subst(q{Top}, $s) }; $out = q{ERR:}.$@ unless defined $out; chomp $out; print qq{--- $s\\n$out\\n}; }'"
---

`SPEC-FORMAT-TERSE.2.3.5` is a completed design/split leaf, not a runtime implementation.

Current ground truth:

- `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` are
  statement-level mutations over a named working array.
- Pop methods discard the removed value in that statement contract.
- `return(items.pop_back())`, `set(out, items.push_back("a"))`, and
  `items.push_back("a").push_back("b")` are not supported value/chained receiver forms today.

Accepted split:

1. `.2.3.5.1` array receiver-dot value chains.
2. `.2.3.5.2` hash receiver-dot value chains.
3. `.2.3.5.3` string receiver-dot value chains.
4. `.2.3.5.4` number receiver-dot value chains.

Implementation rule: future receiver-dot value chains must define their return family before code and prove
Perl/Rust parity with focused locks plus oracle fixtures. Do not broaden the existing `.1.6` mutation shortcut
silently.
