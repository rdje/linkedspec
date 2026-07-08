---
id: hlink-scalarref-oracle-gap
title: hlink_substitution bracket/mixed scalar-ref oracle gap is resolved; bracket payloads now return neutral strings and the Rust corpus includes hlink_bracket_body plus hlink_mixed_bracket_brace
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
  - "when did hlink_bracket_body enter the Rust oracle corpus"
  - "when did hlink_mixed_bracket_brace enter the Rust oracle corpus"
  - "is the hlink scalar-ref oracle gap resolved"
date: 2026-07-03
status: superseded
tags: [rust, oracle, corpus, hlink-substitution, RUST-PARITY]
evidence: "RUST-PARITY.7.3.3.1 read specs/hlink_substitution.spec, existing hlink corpus fixtures, and phase0 hlink_substitution_parser_smoke. Perl then returned [\\'abc'] for [abc] and a mixed array containing a scalar ref for foo[bar]{baz}; JSON::PP refused scalar refs with 'cannot encode reference to scalar'. The {abc} case returned a plain string payload ['{abc}'] and RUST-PARITY.7.3.3.2 added hlink_curly_brace. RUST-PARITY.7.3.3.3 then proved Rust also lacked the scalar-ref action branch, so bracket/mixed fixtures were deferred. SPEC-SOURCE-TERSE-CLOSEOUT.1 superseded that blocker by migrating specs/hlink_substitution.spec::substitute_statement2[1] to return(capture_slice()). Perl now returns ['abc'] for [abc] and ['foo','bar','{baz}'] for foo[bar]{baz}; tools/gen_oracle_corpus.pl includes hlink_bracket_body and hlink_mixed_bracket_brace; the manifest case_count is 99; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference passes over all 99 fixtures."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $p=LinkedSpec::get_parser(\"hlink_substitution\"); for my $input (\"[abc]\",\"foo[bar]{baz}\") { my $copy=$input; my $v=$p->(\\$copy); print JSON::PP->new->canonical(1)->encode($v),\"\\n\" }'; rg -n 'return\\(capture_slice\\(\\)\\)|hlink_bracket_body|hlink_mixed_bracket_brace|\"case_count\" : 99' specs/hlink_substitution.spec tools/gen_oracle_corpus.pl rust/linkedspec-runtime/tests/corpus/manifest.json; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# hlink_substitution Scalar-Reference Oracle Gap

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.3.1`); superseded 2026-07-08 by
`SPEC-SOURCE-TERSE-CLOSEOUT.1`.** The original scalar-reference oracle gap is closed.

Historical state:

- `{abc}` returned a plain string payload and entered the corpus as `hlink_curly_brace`.
- `[abc]` returned a Perl scalar reference (`[\'abc']`).
- `foo[bar]{baz}` returned a mixed array containing that scalar-reference bracket payload.

Current state:

- `substitute_statement2[1]` returns `capture_slice()` directly.
- `[abc]` returns `["abc"]`.
- `foo[bar]{baz}` returns `["foo","bar","{baz}"]`.
- `hlink_bracket_body` and `hlink_mixed_bracket_brace` are checked-in oracle fixtures in
  the 99-fixture Rust corpus.

The owned leaves are:

- `RUST-PARITY.7.3.3.2`: done — added the JSON-safe curly-brace fixture.
- `RUST-PARITY.7.3.3.3`: done — deferred bracket/mixed fixtures with Perl JSON
  failure and Rust action-branch evidence.
- `RUST-PARITY.7.3.3.4`: superseded — no neutral scalar-ref contract is needed for
  this hlink path because the shipped spec now emits neutral string payloads.
