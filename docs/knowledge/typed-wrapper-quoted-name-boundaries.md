---
id: typed-wrapper-quoted-name-boundaries
title: "Aggregate typed wrappers read working variables only from bare name tokens: array(foo) reads array foo and hash(bar) reads hash bar; quoted strings remain constructor payloads, and terse constructors are direct shapes like [value] and { \"key\" : value }."
answers:
  - "does array(\"foo\") mean the same as array(foo)"
  - "does array('foo') mean the same as array(foo)"
  - "does hash(\"bar\") mean the same as hash(bar)"
  - "does hash('bar') mean the same as hash(bar)"
  - "are quoted aggregate wrapper names runtime scalar indirect lookups"
  - "how do I construct a one element array literal when the string is a valid variable name"
  - "how do I construct a one field hash literal with an identifier-like key"
  - "what task locked typed wrapper quoted-name boundaries"
date: 2026-07-01
status: current
tags: [spec-format-terse, wrappers, variables, array, hash, mdbook, rust-parity]
evidence: "SPEC-FORMAT-TERSE.2.3.5.6 locks the corrected aggregate typed-wrapper boundary on the Perl reference and Rust runtime. `array(foo)` and `hash(bar)` are explicit typed working-variable reads when the argument is a bare name token. Quoted strings are not aliases for those reads and are not scalar-indirect lookup: `array(\"foo\")` is a literal array payload, while hash constructors use quoted keys in key/value forms such as `hash(\"foo\", value)`. The user-facing terse constructor forms are direct shape literals (`[value]`, `{ \"key\" : value }`, `[]`, `{}`)."
evidence_update_2026_07_07: "SPEC-FORMAT-TERSE.8.4 retired Rust successful execution of short wrapper aliases `a(...)` / `h(...)`; Perl already diagnosed short wrapper aliases. Current authored examples use `array(...)`, `hash(...)`, direct shape literals, and bare scalar reads."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(count(array(foo)))}, q{return(count(array(\"foo\")))}, q{return(count(array('\\''foo'\\'')))}, q{return(count_keys(hash(bar)))}, q{return(count_keys(hash(\"bar\", 1)))}, q{return(count_keys(hash('\\''bar'\\'', 1)))}, q{return(count([\"foo\"]))}, q{return(count_keys({ \"bar\" : 1 }))}) { print \"$expr => \", LinkedSpec::call_spec_handler_subst(\"Top\", $expr), \"\\n\" }' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_3_5_6 --quiet && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime helpers_5_1_retired_terse_8_4_spellings_diagnose --quiet"
---

# Typed Wrapper Quoted-Name Boundaries

Confirmed for `SPEC-FORMAT-TERSE.2.3.5.6`.

Aggregate typed wrappers read a working variable only when the argument is a bare name token:

```text
array(foo)
hash(bar)
```

`array(foo)` reads the array/list working variable `foo`, and `hash(bar)` reads the hash/associative-array
working variable `bar`.

Quoted strings remain literal constructor payloads. They are not aliases for the bare-name reads and are not
runtime scalar indirection:

```text
array("foo")       # array payload containing "foo"
array('foo')       # array payload containing 'foo'
hash("foo", value) # hash constructor entry with fixed key "foo"
hash('foo', value) # hash constructor entry with fixed key 'foo'
```

If scalar `alias` contains `"foo"`, `array(alias)` reads the array named `alias`, not the array named `foo`.
`array("alias")` constructs a one-element array payload containing the string `"alias"`.

The preferred terse constructor surface is direct shape syntax:

```text
["literal"]
{ "key" : value }
[]
{}
```

Short aliases `a(...)` and `h(...)` are retired diagnostics on current runtimes, not compatibility spellings for
new or maintained specs.

## Links

- Task tree: [[SPEC-FORMAT-TERSE]] (`.2.3.5.6`).
- Related: [[working-vars-no-strict-need-my-lexical]], [[rust-working-vars-auto-vivify]].
