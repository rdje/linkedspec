---
id: hlink-scalarref-oracle-gap
title: hlink_substitution bracket/mixed fixtures are deferred because Perl emits scalar refs that JSON cannot encode and Rust cannot yet execute the scalar-ref action branch
answers:
  - "why can't hlink_substitution bracket fixtures be added directly to the JSON oracle"
  - "why are hlink bracket fixtures deferred"
  - "which hlink_substitution delimiter fixture is JSON safe"
  - "what blocks hlink_substitution [abc] oracle fixture"
  - "what blocks hlink_substitution mixed bracket brace oracle fixture"
  - "which leaf owns hlink scalar ref oracle representation"
  - "which leaf owns deferred hlink scalar-ref fixture support"
  - "what happens when Rust executes hlink [abc]"
  - "when did hlink_curly_brace enter the Rust oracle corpus"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, corpus, hlink-substitution, RUST-PARITY]
evidence: "RUST-PARITY.7.3.3.1 read specs/hlink_substitution.spec, existing hlink corpus fixtures, and phase0 hlink_substitution_parser_smoke. Perl returns [\\'abc'] for [abc] and a mixed array containing a scalar ref for foo[bar]{baz}; JSON::PP refuses scalar refs with 'cannot encode reference to scalar'. The {abc} case returns a plain string payload ['{abc}'] and is JSON-safe. RUST-PARITY.7.3.3.2 added hlink_curly_brace for {abc}; the generator now produces 66 fixtures and Rust corpus_oracle passes. RUST-PARITY.7.3.3.3 then probed Rust and found the bracket path is not only a JSON-representation gap: Rust has no scalar-ref RuntimeValue, and the shipped action payload return(\\(my $capt = capture_slice())) is rejected by the Rust action parser before [abc] falls through to unmatched-closing-bracket exit_now(2). Bracket/mixed fixtures are deferred to RUST-PARITY.7.3.3.4 until a neutral scalar-ref contract or hlink spec migration exists."
reverify: "perl -Iperl -MData::Dumper -MJSON::PP -MLinkedSpec -e 'my $p=LinkedSpec::get_parser(\"hlink_substitution\"); for my $input (\"[abc]\",\"foo[bar]{baz}\") { my $copy=$input; my $v=$p->(\\$copy); print \"INPUT=$input\\n\"; print Dumper($v); eval { print JSON::PP->new->canonical(1)->encode($v),\"\\n\" }; print \"JSON_ERR=$@\" if $@ }'; rg -n 'hlink_curly_brace|return\\(\\\\\\(my \\$capt = capture_slice\\(\\)\\)\\)|enum RuntimeValue|fn to_json|RUST-PARITY\\.7\\.3\\.3\\.4' tools/gen_oracle_corpus.pl specs/hlink_substitution.spec rust/linkedspec-core/src/types.rs docs/tasks/RUST-PARITY.md"
---

# hlink_substitution Scalar-Reference Oracle Gap

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.3.1`); updated by
`RUST-PARITY.7.3.3.2` and `.7.3.3.3`.** The remaining
`hlink_substitution` delimiter candidates do not all have the same oracle shape or Rust support.

- `{abc}` returns a plain string payload and can be represented directly in
  `expected.json`; this is now checked in as `hlink_curly_brace`.
- `[abc]` returns a Perl scalar reference (`[\'abc']`) in the reference AST.
- `foo[bar]{baz}` returns a mixed array containing that scalar-reference bracket
  payload.

`JSON::PP` refuses to encode scalar references, so bracket and mixed
`hlink_substitution` fixtures need an explicit cross-variant representation
decision before they enter the language-neutral JSON corpus. `.7.3.3.3` also showed
that current Rust cannot simply produce an equivalent bracket AST: the scalar-ref action
payload in `substitute_statement2` is rejected by the Rust action parser, and `[abc]`
then falls through to the shipped unmatched-closing-bracket `exit_now(2)` path.

The owned leaves are:

- `RUST-PARITY.7.3.3.2`: done — added the JSON-safe curly-brace fixture.
- `RUST-PARITY.7.3.3.3`: done — deferred bracket/mixed fixtures with Perl JSON
  failure and Rust action-branch evidence.
- `RUST-PARITY.7.3.3.4`: deferred — reopen only to define a neutral tagged
  scalar-ref JSON contract plus Rust support, or to migrate the hlink spec away
  from Perl scalar-ref AST values.
